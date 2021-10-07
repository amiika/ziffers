module Ziffers
  class ZiffHash < Hash

      def eql?(other_hash)
        @@set_keys.filter {|key| self[key] == other_hash[key]} == @@set_keys
      end

      def hash
          self[:degree].hash
      end

  end
end
