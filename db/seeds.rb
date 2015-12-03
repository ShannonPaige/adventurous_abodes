class Seed
  def self.start
    seed = Seed.new
    seed.generate_rental_types
    seed.generate_rentals
    seed.generate_roles
    seed.generate_platform_admin
    seed.generate_owners
    seed.generate_registered_users
    seed.add_rental_properties_to_owners
    seed.generate_reservations
  end

  def generate_rental_types
    rental_types = ["Castle",
                    "Dungeon",
                    "Shack",
                    "Treehouse",
                    "Penthouse",
                    "Spaceship",
                    "Submarine",
                    "Mansion",
                    "Capsule",
                    "Igloo",
                    "Attic",
                    "Storage Container"]

    rental_types.each do |rental_type|
      RentalType.create!(name: rental_type)
      puts "Rental Type #{rental_type} created!"
    end
  end

  def generate_rentals
    rental_types = RentalType.all
    rental_types.each do |rental_type|
      50.times do |i|
        name  = "#{Faker::Name.first_name}'s #{rental_type.name}"
        description = Faker::Lorem.paragraph
        price = Faker::Commerce.price
        status = "active"
        # image_file_name = ""
        # image_content_type = ""
        # image_file_size = ""
        # image_updated_at = ""
        # image = ""
        rental = rental_type.rentals.create!(name: name,
                                            description: description,
                                            price: price,
                                            status: status)
        puts "#{rental_type} #{i+1} created!"
      end
    end
  end

  def generate_roles
    role_titles = %w(platform_admin owner registered_user)

    role_titles.each do |title|
      Role.create!(title: title)
    end
  end

  def generate_platform_admin
    platform_admin =  User.create!(username: "jorge@turing.io",  name: "Platform Admin",   password: "password")
    platform_admin.roles  << Role.find_by(title: "platform_admin")
    puts "Platform Admin created!"
  end

  def generate_owners
    owner_role = Role.find_by(title: "owner")
    250.times do |i|
      name  = Faker::Name.first_name
      username = "andrew@turing.io"
      password = "password"
      image_url = Faker::Avatar.image
      owner = User.create!(name: name,
                          username: username,
                          password: password,
                          image_url: image_url)
      owner.roles << owner_role
      puts "Owner #{i+1} created!"
    end
  end

  def generate_registered_users
    registered_user = User.create!(username: "josh@turing.io", name: "Registered User",       password: "password")
    registered_user.roles << Role.find_by(title: "registered_user")
    puts "Registered User 1 created!"

    registered_user = Role.find_by(title: "registered_user")
    99.times do |i|
      name  = Faker::Name.first_name
      username = Faker::Internet.email(name)
      password = "password"
      image_url = Faker::Avatar.image
      user = User.create!(name:     name,
                   username: username,
                   password: password,
                   image_url: image_url)
      user.roles << registered_user
      puts "Registered User #{i+2} created!"
    end
  end



  def add_rental_properties_to_owners
    j = 1
    owners = User.joins(:roles).where("title = ?", "owner")
    owners.each do |owner|
      rental_one = Rental.find(j)
      rental_two = Rental.find(j+1)
      owner.rentals << rental_one
      owner.rentals << rental_two
      j += 2
      puts "Added 2 rentals to #{owner.name}"
    end
  end

  def generate_reservations
    users = User.joins(:roles).where("title = ?", "registered_user")
    users.each do |user|
      10.times do |i|
        status = "active"
        total = Faker::Commerce.price
        order = user.orders.create!(total: total,
                              status: status)
        add_rentals(order)
        puts "Order #{i+1}: Order for #{user.name} created!"
      end
    end
  end

  private

    def add_rentals(order)
      2.times do |i|
        rental = Rental.find(Random.new.rand(1..500))
        rental_id = rental.id
        order_id = order.id
        reservation = Reservation.create!(order_id: order_id,
                                          rental_id: rental_id)
        puts "Added rental to order #{i}."
      end
    end
end

Seed.start
