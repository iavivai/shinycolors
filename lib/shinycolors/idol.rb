# frozen_string_literal: true

require 'yaml'
require 'active_support/core_ext/hash'
require './lib/shinycolors/unit'

module ShinyColors
  class Idol
    class NotFoundError < StandardError; end

    def initialize(name:, cv:, age:, birthplace:, birthday:, nickname_key:, nickname_kana:)
      @name = name
      @cv = cv
      @age = age
      @birthplace = birthplace
      @birthday = birthday
      @nickname_key = nickname_key
      @nickname_kana = nickname_kana
    end

    attr_reader :name, :cv, :age, :birthplace, :birthday, :nickname_key, :nickname_kana

    class << self
      def all
        return @all unless @all.nil?

        @all = YAML.load_file('./data/idol.yml').each_with_object({}) do |(_, values), result|
          result.merge!(values['idols'])
        end.deep_symbolize_keys!
      end

      def names
        all.keys
      end

      def nicknames
        all.each_with_object({}) do |(fullname, values), result|
          values[:nickname_key]&.each { |nickname| result.merge!({ nickname => fullname }) }
        end
      end

      def find(name)
        h = all[name]
        raise(NotFoundError) if h.nil?

        new(**h)
      end

      def display(name)
        idol = find(name)
        puts <<~PRETTY
          名前:   #{idol.name}
          cv:     #{idol.cv}
          年齢:   #{idol.age}
          出身地: #{idol.birthplace}
          誕生日: #{idol.birthday}
        PRETTY
      end
    end

    def nickname
      nickname_kana
    end

    def unit_name
      Unit.all.find do |_, values|
        values[:idols].key?(key_name)
      end.last[:name]
    end

    alias unit unit_name

    private

    def key_name
      Idol.all.find do |_, values|
        name == values[:name]
      end.first
    end
  end
end
