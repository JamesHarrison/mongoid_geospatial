# encoding: utf-8
module Mongoid #:nodoc:
  module Criterion #:nodoc:

    # WithinSpecial criterion is used when performing #within with symbols to get
    # get a shorthand syntax for where clauses.
    #
    # @example Conversion of a simple to complex criterion.
    #   { :field => { "$within" => {'$center' => [20,30]} } }
    #   becomes:
    #   { :field.within(:center) => [20,30] }
    class WithinSpatial < Complex

      # Convert input to query for box, polygon, center, and centerSphere
      #
      # @example
      #   within = WithinSpatial.new(opts[:key] => 'point', :operator => 'center')
      #   within.to_mongo_query({:point => [20,30], :max => 5, :unit => :km}) #=>
      #
      # @param [Hash,Array] input Variable to conver to query
      def to_mongo_query(input)
        if ['box','polygon'].include?(@operator)
          input = input.values if input.kind_of?(Hash)
          if input.respond_to?(:map)
            input.map! do |v|
              v.respond_to?(:to_xy) ? v.to_xy : v
            end
          else
            input
          end
        elsif ['center','centerSphere'].include?(@operator)

          if input.kind_of?(Hash) || input.kind_of?(ActiveSupport::OrderedHash)
            raise ':point required to make valid query' unless input[:point]
            input[:point] = input[:point].to_xy if input[:point].respond_to?(:to_xy)
            if input[:max]
              input[:max] = input[:max].to_f

              if unit = Mongoid::Geospatial.earth_radius[input[:unit]]
                unit *= Mongoid::Geospatial::RAD_PER_DEG unless operator =~ /sphere/i
                input[:unit] = unit
              end

              input[:max] = input[:max]/input[:unit].to_f if input[:unit]

              input = [input[:point],input[:max]]
            else
              input = input[:point]
            end
          end

          if input.kind_of? Array
            input[0] = input[0].to_xy if input[0].respond_to?(:to_xy)
          end

        end
        {'$within' => {"$#{@operator}"=>input} }
      end
    end
  end
end

