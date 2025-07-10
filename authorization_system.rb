class User
  attr_reader :name, :role

  def initialize(name, role)
    @name = name
    @role = Role.new(role)
  end

  def can?(action, resource)
    @role.can?(action, resource)
  end

  def to_s
    "#{@name} (#{@role})"
  end
end

class Role
  ROLES = {
    student: {
      permissions: {
        courses: [:view],
        assignments: [:view, :submit]
      }
    },
    teacher: {
      permissions: {
        courses: [:view, :create, :edit],
        assignments: [:view, :create, :edit, :grade],
        students: [:view, :grade]
      }
    },
    admin: {
      permissions: {
        all: [:manage]
      }
    }
  }

  def initialize(role_name)
    @role_name = role_name.to_sym
    unless ROLES.key?(@role_name)
      raise ArgumentError, "Invalid role: #{role_name}"
    end
  end

  def can?(action, resource)
    permissions = ROLES[@role_name][:permissions]
    

    if permissions.key?(:all) && permissions[:all].include?(:manage)
      return true
    end


    if permissions.key?(resource)
      permissions[resource].include?(action.to_sym)
    else
      false
    end
  end

  def to_s
    @role_name.to_s.capitalize
  end
end

if __FILE__ == $0
  student = User.new("Alice", :student)
  teacher = User.new("Mr. Smith", :teacher)
  admin = User.new("Principal", :admin)

  puts "#{student}:"
  puts "  Can view courses? #{student.can?(:view, :courses)}"
  puts "  Can grade assignments? #{student.can?(:grade, :assignments)}"
  puts "  Can create courses? #{student.can?(:create, :courses)}"

  puts "\n#{teacher}:"
  puts "  Can grade assignments? #{teacher.can?(:grade, :assignments)}"
  puts "  Can create courses? #{teacher.can?(:create, :courses)}"
  puts "  Can manage everything? #{teacher.can?(:manage, :all)}"

  puts "\n#{admin}:"
  puts "  Can manage courses? #{admin.can?(:manage, :courses)}"
  puts "  Can delete users? #{admin.can?(:delete, :users)}"
end