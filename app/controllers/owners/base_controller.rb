class Owners::BaseController < ApplicationController
  before_action :require_owner
end
