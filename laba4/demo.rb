class Ingredient
  attr_reader :name, :base_unit, :calories_per_unit

  def initialize(name, base_unit, calories_per_unit)
    @name = name.to_s
    @base_unit = base_unit
    @calories_per_unit = calories_per_unit.to_f
  end
end

module UnitConverter
  MASS = [:g, :kg]
  VOLUME = [:ml, :l]
  PCS = [:pcs]

  def self.to_base(qty, unit, base_unit)
    unit = unit.to_sym
    base_unit = base_unit.to_sym

    if MASS.include?(unit) && MASS.include?(base_unit)
      return convert_mass_to_base(qty, unit, base_unit)
    elsif VOLUME.include?(unit) && VOLUME.include?(base_unit)
      return convert_volume_to_base(qty, unit, base_unit)
    elsif PCS.include?(unit) && PCS.include?(base_unit)
      return qty.to_f * 1.0
    else
      raise ArgumentError.new("Заборонено конвертувати між масою та об'ємом або невідповідні одиниці (#{unit} -> #{base_unit})")
    end
  end

  def self.convert_mass_to_base(qty, unit, base_unit)
    qty = qty.to_f
    if unit == base_unit
      qty
    elsif unit == :kg && base_unit == :g
      qty * 1000.0
    elsif unit == :g && base_unit == :kg
      qty / 1000.0
    else
      qty
    end
  end

  def self.convert_volume_to_base(qty, unit, base_unit)
    qty = qty.to_f
    if unit == base_unit
      qty
    elsif unit == :l && base_unit == :ml
      qty * 1000.0
    elsif unit == :ml && base_unit == :l
      qty / 1000.0
    else
      qty
    end
  end
end

class Recipe
  attr_reader :name, :steps, :items
  def initialize(name, steps = [], items = [])
    @name = name.to_s
    @steps = steps
    @items = items
  end

  def need
    result = Hash.new(0.0)
    @items.each do |it|
      ing = it[:ingredient]
      qty = it[:qty]
      unit = it[:unit]
      base_qty = UnitConverter.to_base(qty, unit, ing.base_unit)
      result[ing.name] += base_qty
    end
    result
  end
end

class Pantry
  def initialize
    @store = Hash.new(0.0)
  end

  def add(ingredient, qty, unit)
    raise ArgumentError.new("ingredient має бути Ingredient") unless ingredient.is_a?(Ingredient)
    base_qty = UnitConverter.to_base(qty, unit, ingredient.base_unit)
    @store[ingredient.name] += base_qty
  end

  def available_for(ingredient)
    @store[ingredient.name] || 0.0
  end
end

class Planner
  def self.plan(recipes, pantry, price_list, ingredients_index)
    total_need = Hash.new(0.0)
    recipes.each do |r|
      need = r.need
      need.each do |name, qty|
        total_need[name] += qty
      end
    end

    report = {}
    total_calories = 0.0
    total_cost = 0.0

    total_need.each do |name, need_qty|
      ing = ingredients_index[name]
      unless ing
        raise ArgumentError.new("Не знайдено Ingredient для #{name}")
      end
      have_qty = pantry.available_for(ing)
      deficit = [need_qty - have_qty, 0.0].max
      price_per_unit = price_list[name] || 0.0
      cost = need_qty * price_per_unit
      calories = need_qty * ing.calories_per_unit

      report[name] = {
        need: need_qty,
        have: have_qty,
        deficit: deficit,
        unit: ing.base_unit,
        cost: cost,
        calories: calories
      }

      total_calories += calories
      total_cost += cost
    end

    { report: report, total_calories: total_calories, total_cost: total_cost }
  end
end

ingredients = {}

ingredients["яйце"] = Ingredient.new("яйце", :pcs, 72.0)
ingredients["молоко"] = Ingredient.new("молоко", :ml, 0.06)
ingredients["борошно"] = Ingredient.new("борошно", :g, 3.64)
ingredients["паста"] = Ingredient.new("паста", :g, 3.5)
ingredients["соус"] = Ingredient.new("соус", :ml, 0.2)
ingredients["сир"] = Ingredient.new("сир", :g, 4.0)


pantry = Pantry.new
pantry.add(ingredients["борошно"], 1, :kg)   # 1 kg -> 1000 g
pantry.add(ingredients["молоко"], 0.5, :l)   # 0.5 l -> 500 ml
pantry.add(ingredients["яйце"], 6, :pcs)
pantry.add(ingredients["паста"], 300, :g)
pantry.add(ingredients["сир"], 150, :g)

price_list = {
  "борошно" => 0.02,
  "молоко" => 0.015,
  "яйце" => 6.0,
  "паста" => 0.03,
  "соус" => 0.025,
  "сир" => 0.08
}

omlet = Recipe.new("Омлет", ["Збити яйця, додати молоко і борошно, смажити"], [
  { ingredient: ingredients["яйце"], qty: 3, unit: :pcs },
  { ingredient: ingredients["молоко"], qty: 100, unit: :ml },
  { ingredient: ingredients["борошно"], qty: 20, unit: :g }
])

pasta_recipe = Recipe.new("Паста", ["Зварити пасту, додати соус, посипати сиром"], [
  { ingredient: ingredients["паста"], qty: 200, unit: :g },
  { ingredient: ingredients["соус"], qty: 150, unit: :ml },
  { ingredient: ingredients["сир"], qty: 50, unit: :g }
])

recipes = [omlet, pasta_recipe]

result = Planner.plan(recipes, pantry, price_list, ingredients)

puts "---- План (потрібно / є / дефіцит) ----"
result[:report].each do |name, info|
  need = format("%.2f", info[:need])
  have = format("%.2f", info[:have])
  deficit = format("%.2f", info[:deficit])
  unit = info[:unit].to_s
  puts "#{name}: потрібно #{need} #{unit} / є #{have} #{unit} / дефіцит #{deficit} #{unit}"
end

puts "---------------------------------------"
puts "Total calories: #{format('%.2f', result[:total_calories])} kcal"
puts "Total cost: #{format('%.2f', result[:total_cost])} (од.)"


