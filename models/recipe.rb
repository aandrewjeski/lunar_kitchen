class Recipe
  attr_reader :id, :name, :instructions, :description, :ingredients
  def initialize(name, id, instructions = nil, description = nil, ingredients = nil)
    @name = name
    @id = id
    @instructions = instructions
    @description = description
    @ingredients = ingredients
  end


  def self.db_connection
    begin
      connection = PG.connect(dbname: 'recipes')

      yield(connection)

    ensure
      connection.close
    end
  end

  def self.all
    recipe_element = []
    db_connection do |conn|
      @recipes = conn.exec('SELECT * FROM recipes ORDER BY name;')
    end
    @recipes.each do |recipe|
      recipe_element << Recipe.new(recipe["name"], recipe["id"])
    end
    recipe_element
  end

  def self.find(params)

    sql = "SELECT recipes.name AS name,
      recipes.id AS id, recipes.instructions AS instructions, recipes.description AS description, ingredients.name AS ingredients
      FROM recipes
      JOIN ingredients ON recipes.id = ingredients.recipe_id
      WHERE recipes.id = $1"

    recipes_info = db_connection do |conn|
      conn.exec_params(sql,[params])
    end



    ingredients = []
    recipes_info.each do |recipe|
      ingredients << Ingredient.new(recipe["ingredients"])
    end


    Recipe.new(recipes_info[0]["name"], recipes_info[0]["id"], recipes_info[0]["instructions"] || "This recipe doesn't have any instructions.", recipes_info[0]["description"] || "This recipe doesn't have a description.", ingredients)
  end
end
