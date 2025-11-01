require 'find'
require 'json'
require 'digest'

def collect_files(root, ignore: [])
  files = []
  return files unless Dir.exist?(root)

  Find.find(root) do |path|
    next if ignore.any? { |pattern| File.fnmatch?(pattern, path, File::FNM_PATHNAME | File::FNM_EXTGLOB) }

    if File.file?(path)
      stat = File.lstat(path)
      files << {
        path: path,
        size: stat.size,
        inode: stat.ino
      }
    end
  end

  files
end

def file_hash(path)
  Digest::SHA256.file(path).hexdigest
rescue
  nil
end

def find_duplicates(files)
  groups = []
  files.group_by { |f| f[:size] }.each do |size, same_size|
    next if same_size.size < 2

    same_size.group_by { |f| file_hash(f[:path]) }.each do |hash, same_hash|
      next if same_hash.size < 2

      groups << {
        size_bytes: size,
        saved_if_dedup_bytes: size * (same_hash.size - 1),
        files: same_hash.map { |f| f[:path] }
      }
    end
  end
  groups
end

def write_json_report(scanned_files, groups, path = "duplicates.json")
  report = {
    scanned_files: scanned_files,
    groups: groups
  }
  File.write(path, JSON.pretty_generate(report))
end


files = collect_files("C:/Users/Lenovo/RubyMineProjects", ignore: ["*/.git/*", "*/tmp/*"])
puts "Зібрано #{files.size} файлів"

groups = find_duplicates(files)
puts "Знайдено #{groups.size} груп дублікатів"

write_json_report(files.size, groups)

puts "Звіт створено: duplicates.json"
