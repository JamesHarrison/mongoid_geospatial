class Alarm
  include Mongoid::Document
  include Mongoid::Geospatial

  field :radius,  type: Circle
  field :area,    type: Box
  field :spot,    type: Point, sphere: true

  spatial_scope :spot
end
