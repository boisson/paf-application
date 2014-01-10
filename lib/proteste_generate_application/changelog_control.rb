require 'csv'
module ProtesteGenerateApplication
  class ChangelogControl
    # columns of file
    # 0 = date
    # 1 = author email
    # 2 = task number
    # 3 = solution

    ENVIRONMENT_RELATION = {
      development: :dev,
      staging: :apr,
      acceptance: :apr,
      approval: :apr,
      production: :prd
    }
    def self.insert(environment,user_email, ticket_number, solution)
      changelog_control = self.new(environment)
      changelog_control.insert_on_top(user_email, ticket_number, solution)
      changelog_control.save
    end

    def initialize(environment = nil)
      if environment
        @environment  = ENVIRONMENT_RELATION[environment.to_sym] || environment.to_sym
        @file_name    = "changelog.#{@environment}"
      else
        @file_name    = "CHANGELOG"
      end
    end

    def insert_on_top(user_email, ticket_number, solution)
      rows
      @rows.insert(0,[Time.now.strftime('%Y-%m-%d'),user_email,ticket_number, solution])
    end

    def rows
      @rows ||= rows_of_file(@file_name)
    end

    def rows_of_file(file)
      rows = []
      if File.exists?(file)
        CSV.foreach(file, col_sep: ';', force_quotes: true) do |row|
          begin
            next if row.size == 0
            rows << row
          rescue
          end
        end
      end
      rows
    end

    def rows_by_date
      return @rows_by_date if @rows_by_date
      @rows_by_date        = {}
      rows_sorted_by_date  = rows.sort_by{|t| t[0]}.reverse
      rows_grouped_by_date = rows_sorted_by_date.group_by{|t| t[0]}
      rows_grouped_by_date.each do |task_date, group_by_date|
        @rows_by_date[task_date] ||= []
        rows_grouped_by_task = group_by_date.group_by{|t| t[2]}
        rows_grouped_by_task.each do |task_number, group_by_task|
          if task_number == ""
            group_by_task.each do |row|
              @rows_by_date[task_date] << row
            end
          else
            @rows_by_date[task_date] << group_by_task.first
          end
        end
      end
      @rows_by_date
    end

    def save
      CSV.open(@file_name, 'wb', col_sep: ';', force_quotes: true) do |csv|
        rows.each do |row|
          csv << row
        end
      end
      true
    rescue => e
      puts e.message
      false
    end

    def merge(environment_merged)
      environment_merged  = ENVIRONMENT_RELATION[environment_merged.to_sym] || environment_merged.to_sym
      rows_merged         = rows_of_file("changelog.#{environment_merged}") + rows
      rows_merged         = rows_merged.sort_by{|t| t[0]}
      rows_merged_by_task = rows_merged.group_by{|t| t[2]}
      new_rows = []
      rows_merged_by_task.each do |task_number, row_grouped|
        if task_number == ""
          row_grouped.each do |row|
            new_rows << row
          end
        else
          new_rows << row_grouped.first
        end
      end
      @rows = new_rows
      save
    end


  end
end