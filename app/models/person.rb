class Person < ActiveRecord::Base
  attr_accessible :name, :date_of_birth

  validates :name, :presence => true
  validates :date_of_birth, allow_nil: true, format: {
    with: /\A\d{4}(-\d{1,2}(-\d{1,2})?)?\z/
  }

  has_many :relationships, :dependent => :destroy
  has_many :reverse_relationships, :dependent => :destroy, class_name: 'Relationship', foreign_key: 'related_person_id'

  def all_relationships
    relationships | reverse_relationships
  end

  def name 
    @name = "#{first_name} #{middle_name} #{last_name} "
  end

  def born 
    dob.to_s(:pretty) if present? rescue ''
  end

  def died
    dod.to_s(:pretty) if present? rescue ''
  end

  def age
    if dob.present? and dod.present?
      ((dod.year*12+dod.month) - (dob.year*12+dob.month))/12
    else 
      ''
    end
  end

  def spouses
    spouse = []
    self.all_relationships.each do |filter|
      if filter.person_id == self.id && filter.relationship_type_id == 2 
        spouse << (Person.find filter.related_person_id)
      elsif filter.related_person_id == self.id && filter.relationship_type_id == 2
        spouse << (Person.find filter.person_id)
      end
    end
    return spouse
  end


  def parents
    parents = []
    self.all_relationships.each do |filter|
      if filter.related_person_id == self.id && filter.relationship_type_id == 1
        parents << (Person.find filter.person_id)
      end
    end
    return parents
  end

  def children
    children = []
    self.all_relationships.each do |filter|
      if filter.person_id == self.id && filter.relationship_type_id == 1
        children << (Person.find filter.related_person_id)
      end
    end
    return children
  end
end

