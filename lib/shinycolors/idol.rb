# frozen_string_literal: true

require 'yaml'
require 'active_support/core_ext/hash'
require './lib/shinycolors/unit'

module ShinyColors
  class Idol
    class NotFoundError < StandardError; end

    def initialize(name:, cv:, age:, blood_type:, birthday:, zodiac_sign:, dominant_hand:,
                   birthplace:, hobby:, special_skills:, nickname_key:, nickname_kana:, key_name:)
      @name = name
      @cv = cv
      @age = age
      @blood_type = blood_type
      @birthday = birthday
      @zodiac_sign = zodiac_sign
      @dominant_hand = dominant_hand
      @birthplace = birthplace
      @hobby = hobby
      @special_skills = special_skills
      @nickname_key = nickname_key
      @nickname_kana = nickname_kana
      @key_name = key_name
    end

    attr_reader :name, :cv, :age, :blood_type, :birthday, :zodiac_sign, :dominant_hand,
                :birthplace, :hobby, :special_skills, :nickname_key, :nickname_kana, :key_name

    class << self
      def all
        data.map do |key, values|
          values[:key_name] = key
          new(**values)
        end
      end

      def names
        data.keys
      end

      def nicknames
        data.each_with_object({}) do |(fullname, values), result|
          values[:nickname_key]&.each { |nickname| result.merge!({ nickname => fullname }) }
        end
      end

      def find(name)
        h = data[name]
        raise(NotFoundError) if h.nil?

        h[:key_name] = name
        new(**h)
      end

      def sample
        all.sample
      end

      private

      def data
        return @data unless @data.nil?

        @data = YAML.load_file('./data/idol.yml').each_with_object({}) do |(_, values), result|
          result.merge!(values['idols'])
        end.deep_symbolize_keys!
      end
    end

    def ==(other)
      key_name == other.key_name
    end

    def nickname
      nickname_kana
    end

    def unit_name
      Unit.all.select do |unit|
        unit.idols.include?(self)
      end.first.name
    end

    # TODO: to module.
    def display
      puts <<~TEXT
          名前: #{name}
            CV: #{cv}
          年齢: #{age}
        血液型: #{blood_type}
        誕生日: #{birthday}
          星座: #{zodiac_sign}
        利き手: #{dominant_hand}
        出身地: #{birthplace}
          趣味: #{hobby}
          特技: #{special_skills}
      TEXT
    end
  end
end
