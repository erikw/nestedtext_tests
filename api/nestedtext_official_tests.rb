require "json"

module NestedTextOfficialTests
  extend self

  def load_test_cases
    official_dir = File.expand_path(File.dirname(__FILE__) + "/..")
    cases_dir = official_dir + "/test_cases"

    cases = []
    Dir.each_child(cases_dir) do |case_dir|
      cases << TestCase.new(case_dir, "#{cases_dir}/#{case_dir}")
    end

    cases
  end

  def select_load_success(cases)
    cases.select { |caze| caze.load_success? }
  end

  def select_load_error(cases)
    cases.select { |caze| caze.load_error? }
  end

  def select_dump_success(cases)
    cases.select { |caze| caze.dump_success? }
  end

  def select_dump_error(cases)
    cases.select { |caze| caze.dump_error? }
  end

  class TestCase
    attr_reader :name, :path

    def initialize(name, path)
      super()
      @name = name
      @path = path
      @case = {}
      determine_test_types
    end

    def load_success?
      !@case&.[](:load)&.[](:out).nil?
    end

    def load_error?
      !@case&.[](:load)&.[](:err).nil?
    end

    def dump_sucess?
      !@case&.[](:dump)&.[](:out).nil?
    end

    def dump_error?
      !@case&.[](:dump)&.[](:err).nil?
    end

    def [](key)
      @case[key]
    end

    private

    def determine_test_types
      load_in =  @path + "/load_in.nt"
      load_out = @path + "/load_out.json"
      load_err = @path + "/load_err.json"
      dump_in =  @path + "/dump_in.json"
      dump_out = @path + "/dump_out.nt"
      dump_err = @path + "/dump_err.json"

      if File.exist?(load_in)
        @case[:load] = { in: { path: load_in } }

        if File.exist?(load_out) && File.exist?(load_err)
          raise "For a load_in.nt case, only one of load_out.json and load_err.json can exist!"
        elsif File.exist?(load_out)
          @case[:load][:out] = { path: load_out, data: JSON.load_file(load_out) }
        elsif File.exist?(load_err)
          @case[:load][:err] = { path: load_out, data: JSON.load_file(load_err) }
        else
          raise "For a load_in.nt case, one of load_out.json and load_err.json must exist!"
        end
      end

      if File.exist?(dump_in)
        @case[:dump] = { in: { path: dump_in, data: JSON.load_file(dump_in) } }

        if File.exist?(dump_out) && File.exist?(dump_err)
          raise "For a dump_in.json case, only one of dump_out.nt and dump_err.json can exist!"
        elsif File.exist?(dump_out)
          @case[:dump][:out] = { path: dump_out }
        elsif File.exist?(dump_err)
          @case[:dump][:err] = { path: dump_out, data: JSON.load_file(dump_err) }
        else
          raise "For a dump_in.json case, one of dump_out.json and dump_err.json must exist!"
        end
      end
    end
  end
end
