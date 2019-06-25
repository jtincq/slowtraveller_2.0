class Destination < ApplicationRecord
  has_many :labels, dependent: :destroy
end
