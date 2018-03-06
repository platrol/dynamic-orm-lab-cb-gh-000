require_relative "../config/environment.rb"
require 'active_support/inflector'
require "pry"
class InteractiveRecord

  def self.table_name
    self.to_s.downcase.pluralize
  end

  def self.column_names
    DB[:conn].results_as_hash = true
    sql = "PRAGMA table_info('#{self.table_name}')"
    colum_data = DB[:conn].execute(sql)
    colum_name = []

    colum_data.each do |colum|
      colum_name << colum['name']
    end
    colum_name
  end


  def initialize(options={})

    options.each do |key, value|
      self.send("#{key}=", value)
    end
  end

  def table_name_for_insert
    self.class.table_name
  end

  def col_names_for_insert
    self.class.column_names.delete_if{|c| c == 'id'}.join(", ")
  end

  def values_for_insert
    values = []
    self.class.column_names.each do |column|
      values << "'#{self.send(column)}'" unless self.send(column) == nil
  end
  values.join(", ")
end


  def save
    sql = "INSERT INTO #{table_name_for_insert} (#{col_names_for_insert}) VALUES (#{values_for_insert})"
    DB[:conn].execute(sql)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_name_for_insert}")[0][0]
  end

  def self.find_by_name(name)
    sql = "SELECT * FROM #{table_name} WHERE name = '#{name}'"
    DB[:conn].execute(sql).flatten
  end

  def self.find_by(row)
    value = row.values.first.class == Fixnum ?  row.values.first : "'#{row.values.first}'"
      sql = "SELECT * FROM #{table_name} WHERE  #{row.keys.first} = #{value};"
      DB[:conn].execute(sql)
    end
    
end
