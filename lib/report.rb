# frozen_string_literal: true

require 'json'
require 'text-table'
require 'word_wrap'
require_relative 'report/colorize'

# Reporting class. Used to save to json and display on output
class Report
  PRIORITY_TO_COLOR = { 'High' => :red, 'Medium' => :yellow }.freeze
  MAX_MESSAGE_WIDTH = 100

  attr_reader :issues

  def initialize(issues)
    @issues = issues
  end

  # Dump issues to json and save as file
  def save_as(target_path)
    File.write(target_path, dump)
    puts "SUCCESS: Report saved in #{target_path}"
  end

  def sort_issues
    priority = %w[Critical High Medium Low Unknown].freeze

    dedupe_issues!(@issues)
    @issues.sort_by! { |issue| priority.index(issue.priority) || priority.size }
  end

  def dump
    sort_issues.map(&:to_hash).to_json
  end

  # outputs human readable report on standard output
  def output
    if @issues.empty?
      puts 'No security vulnerability.'.colorize(:green)
    else
      yies = @issues.size == 1 ? 'y' : 'ies'
      puts "Security vulnerabilit#{yies} found :"
      table = Text::Table.new
      table.head = %w[Priority Tool Identifier URL]

      sort_issues.each_with_index do |issue, index|
        color = PRIORITY_TO_COLOR[issue.priority]
        priority = issue.priority || ''
        table.rows << [priority.colorize(color), issue.tool, issue.cve, issue.url]
        add_text_to_table(table, issue.message) unless issue.message.nil?
        add_text_to_table(table, "Solution: #{issue.solution}") unless issue.solution.nil?
        unless issue.file.nil?
          location = "In #{issue.file}" + (issue.line.nil? ? '' : " line #{issue.line}")
          table.rows << [{ value: location, colspan: 4 }]
        end
        table.rows << :separator unless index == @issues.size - 1
      end

      puts table
      puts "#{@issues.size} security vulnerabilit#{yies}.".colorize(:red)
    end
  end

  private

  # Avoid reporting the same issue from multiple tools
  # Dedupe based on the CVE identifier only for now
  def dedupe_issues!(issues)
    # Tools with best metadata come first
    tools_priority = %i[bundler_audit npm_audit retire gemnasium].freeze

    issues.group_by(&:cve).each do |cve, duplicates|
      next unless cve

      # Keep the issue from the tool with best metadata
      duplicates.sort_by! { |dup| tools_priority.index(dup.tool) || 999 }
      first = duplicates.shift

      # Aggregates all tools in a new property
      first.tools = [first.tool]
      duplicates.each do |dup|
        # Do not aggregate multiple occurences from the same tool
        next if first.tools.include? dup.tool
        first.tools << dup.tool
        # Remove duplicate
        issues.delete dup
      end
    end
  end

  # Adds a potentially long text to a table, wrapping on words as
  # necessary
  def add_text_to_table(table, text)
    lines = WordWrap.ww(text, MAX_MESSAGE_WIDTH).split("\n")
    lines.each do |line|
      table.rows << [{ value: line, colspan: 4 }]
    end
  end
end
