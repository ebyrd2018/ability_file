class Ability
	include CanCan::Ability

	def initialize(user)
		# set user to new user if not logged in
		user ||= User.new # i.e., a guest user

		# set authorizations for different user roles
		if user.role? :admin
			# can do everything
			can :manage, :all

		elsif user.role? :parent
			can :read, Camp 

			can :show, [Instructor, Location]

			can :show, User do |u|  
        		u.id == user.id
      		end

      		can :show, Family do |f|
      			user.family == f 
      		end

			can :update, User do |u|
      			u.id == user.id 
      		end

      		can :update, Family do |f|
      			user.family == f
      		end

			can :manage, Student do |this_student|
				my_students = user.family.students.map(&:id)
				my_students.include? this_student.id
			end

			can :create, Registration

			can :read, Registration do |r|
				user.id == r.family.id
			end

			can :destroy, Registration do |r|
				r.payment.nil?
			end

		elsif user.role? :instructor
			# can read everything about curriculums, camps, and locations
			can :read, Camp 

			can :show, [Instructor, Location]

			# can read their own profile
			can :show, User do |u|  
        		u.id == user.id
      		end

      		can :show, Instructor do |i|
      			user.instructor == i
      		end

      		can :edit, User do |u|
      			u.id == user.id
      		end

      		can :edit, Instructor do |i|
      			user.instructor == i 
      		end

      		can :update, User do |u|
      			u.id == user.id 
      		end

      		can :update, Instructor do |i| 
      			user.instructor == i
      		end
		
			# can read a list of students and their details in their camps
			can :read, Student do |this_student|  
        		my_students = user.instructor.camps.all.map {|c| c.students.all.map{|s| s.id}}.flatten
        		my_students.include? this_student.id
      		end

			# can read associated family info for students they can view
			can :read, Family do |this_family|
				my_families = user.instructor.camps.all.map {|c| c.students.all.map{|s| s.family.id}}.flatten
				my_families.include? this_family.id
			end

		else
			# guests can read camp and curriculum info
			can :read, Camp 

			can :show, [Instructor, Location]

			can :create, [Family, User]
		end
	end
end
