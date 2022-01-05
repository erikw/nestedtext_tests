module NestedTextOfficialTests
  extend self

  def load_test_cases
    official_dir = File.expand_path(File.dirname(__FILE__) + "/..")
    cases_dir = official_dir + "/test_cases"

    cases = []
    Dir.each_child(cases_dir) do |case_dir|
      cases << TestCase.new(case_dir)
    end

    cases
  end

  class TestCase
    attr_reader :name

    def initialize(name)
      @name = name
    end
  end
end
