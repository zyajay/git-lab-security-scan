# frozen_string_literal: true

# Generic structure for any security issue found by analyzer
class Issue
  ATTRIBUTES = %w[tool tools fingerprint message url cve file line priority solution].freeze

  def initialize
    # Inititalize attributes and set up accessors
    ATTRIBUTES.each do |attr|
      singleton_class.class_eval { attr_accessor attr }
      instance_variable_set(('@' + attr).to_sym, nil)
    end
  end

  # Compare issues by their attributes values to allow deduplication
  def ==(other)
    other.class == self.class && other.state == state
  end
  alias eql? ==

  def hash
    state.hash
  end

  def to_hash
    hash = {}

    instance_variables.each do |var|
      # Build a hash with values that are not nil
      value = instance_variable_get(var)
      hash[var.to_s.delete('@')] = value unless value.nil?
    end

    hash
  end

  protected

  def state
    ATTRIBUTES.map { |attr| instance_variable_get('@' + attr) }
  end
end
