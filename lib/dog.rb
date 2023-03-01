class Dog
    attr_accessor :name, :breed, :id

    # has a name and a breed
    # has an id that defaults to `nil` on initialization
    def initialize(name:, breed:, id: nil)
        @name = name
        @breed = breed
        @id = id
    end

    # creates the dogs table in the database
    def self.create_table
        sql = <<-SQL
        CREATE TABLE IF NOT EXISTS dogs (
            id INTEGER PRIMARY KEY,
            name TEXT,
            breed TEXT
        )
        SQL
        
        DB[:conn].execute(sql)
    end
    
    # drops the dogs table from the database
    def self.drop_table
        sql = <<-SQL
            DROP TABLE IF EXISTS dogs
        SQL

        DB[:conn].execute(sql)
    end

    # returns an instance of the dog class
    # saves an instance of the dog class to the database and then sets the given dogs `id` attribute
    def save
        sql = <<-SQL
            INSERT INTO dogs (name, breed)
            VALUES (?,?)

        SQL

        DB[:conn].execute(sql, self.name, self.breed)

        # you can use @id instead of self.id
        @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
        

        self
    end

    # create a new dog object and uses the #save method to save that dog to the database
    # returns a new dog object
    def self.create(name:, breed:)
        dog = Dog.new(name:name, breed:breed)
        dog.save
    end

    # creates an instance with corresponding attribute values
    def self.new_from_db(row)
       Dog.new(id: row[0], name: row[1], breed: row[2])
    end

    # returns an array of Dog instances for all records in the dogs table
    def self.all
        sql = <<-SQL
            SELECT * FROM dogs
        SQL

        DB[:conn].execute(sql).map do |row|
            self.new_from_db(row)
        end
    end

    # returns an instance of dog that matches the name from the DB
    def self.find_by_name(name)
        sql = <<-SQL
            SELECT * FROM dogs
            WHERE name = ?
            LIMIT 1
        SQL

        DB[:conn].execute(sql, name).map do |row|
            self.new_from_db(row)
        end.first
    end

    # returns a new dog object by id
    def self.find(id)
        sql = <<-SQL
            SELECT * FROM dogs
            WHERE id = ?
            LIMIT 1
        SQL

        DB[:conn].execute(sql, id).map do |row|
            self.new_from_db(row)
        end.first
    end

end