class User < ActiveRecord::Base
  attr_accessor :skip_password_validation
  has_many :orders
  has_many :rentals
  has_many :user_roles
  has_many :roles, through: :user_roles

  has_secure_password

  validates :username, presence: true
  validates :name, presence: true
  validates :password, presence: true, unless: :skip_password_validation

  scope :pending,       -> { where owner_status: 'pending' }
  scope :active_owners,       -> { where owner_status: 'active' }

  def platform_admin?
    roles.exists?(title: "platform_admin")
  end

  def owner?
    roles.exists?(title: "owner")
  end

  def registered_user?
    roles.exists?(title: "registered_user")
  end

  def update_role
    if owner_status == "active" && roles.first.title == "registered_user"
      self.roles.first.update_attributes(title: "owner")
    elsif owner_status == "inactive" && roles.first.title == "registered_user"
      self.roles.first.update_attributes(title: "owner")
    elsif owner_status == "" && roles.first.title == "owner"
      self.roles.first.update_attributes(title: "registered_user")
    else
    end
  end

  def toggle_rentals(status)
    if status == "inactive"
      rentals.update_all(status: "inactive")
    else
      rentals.update_all(status: "active")
    end
  end

  def active?
    owner_status == "active"
  end

  def rental_owner?(rental)
    self.rentals.include?(rental)
  end

  def show_options?(rental)
    (self.owner? && self.rental_owner?(rental)) || self.platform_admin?
  end
end
