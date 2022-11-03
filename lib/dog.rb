class Dog

attr_accessor :id, :name, :breed

def initialize(id: nil, name:, breed:)
    @id = id
    @name = name
    @breed = breed
end

# drop table class method
def self.drop_table
    sql = <<-SQL
    DROP TABLE IF EXISTS dogs
    SQL
    DB[:conn].execute(sql)

end


# self.create_table
def self.create_table
sql = <<-SQL
CREATE TABLE IF NOT EXISTS dogs(
    id INTEGER PRIMARY KEY,
    name TEXT,
    breed TEXT
)
SQL
DB[:conn].execute(sql)
end

# save method,calling save will insert a new record into the database and return the instance
def save
    if self.id
        self.update
    else
    sql = <<-SQL
     INSERT INTO dogs(name, breed) 
     VALUES (?, ?)
    SQL
    DB[:conn].execute(sql, self.name, self.breed)
    self.id =DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
end
self
end

# .create method; creates new row in the database,returns new instance of the Dog class
def self.create(name:, breed:)
    dog = Dog.new(name: name, breed: breed)
    dog.save
end

# .new_from_db;return an array from the database
def self.new_from_db(row)
 self.new(id: row[0], name: row[1], breed: row[2])
end

# self.all method,returns all records in the database as ruby objects
def self.all
sql = <<-SQL
  SELECT * FROM dogs 
SQL

DB[:conn].execute(sql).map do |row|
self.new_from_db(row)
end
end
# self.find_by_name method,returns records in the database that match the creteria
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

# self.find(id),takes in an id,returns a single dog instance that corresponds
def self.find(id)
    sql = <<-SQL
    SELECT * FROM dogs 
    WHERE dogs.id = ?
    LIMIT 1

    SQL
    DB[:conn].execute(sql, id).map do |row|
       self.new_from_db(row)
     end.first
end

end
