module FuzzyTime

  # @todo move to lib/support
  def convert_fuzzy_datetime_str_to_datetime complete_by_str    
    tomorrow_match = complete_by_str.match time_exprs[:tommorow]
    next_week_match = complete_by_str.match time_exprs[:next_week]
    in_n_days_match = complete_by_str.match time_exprs[:in_n_days]
    in_n_weeks_match = complete_by_str.match time_exprs[:in_n_weeks]
    in_str_n_days_match = complete_by_str.match time_exprs[:in_str_n_days]
    in_str_n_weeks_match = complete_by_str.match time_exprs[:in_str_n_weeks]

    if tomorrow_match
      Time.now + 1.day
    elsif next_week_match
      Time.now + 1.week
    elsif in_n_days_match
      Time.now + in_n_days_match[1].to_i.days
    elsif in_n_weeks_match
      Time.now + in_n_weeks_match[1].to_i.weeks
    elsif in_str_n_days_match
      number_of_days = str_nums.index in_str_n_days_match[1]
      Time.now + number_of_days.days
    elsif in_str_n_weeks_match
      number_of_weeks = str_nums.index in_str_n_weeks_match[1]
      Time.now + number_of_weeks.weeks
    else
      nil
    end
  end

  def strip_complete_by_str str
    stripped_str = str
    time_exprs.values.each do |expr|
      stripped_str = stripped_str.gsub expr, ''
    end
    stripped_str
  end

  private

    def str_nums
      ['zero','one','two','three','four','five','six','seven','nine','ten']
    end

    def time_exprs 
      @@_time_exprs ||= {tommorow: Regexp.new(/ ?tomorrow/),
       next_week: Regexp.new(/ ?next week/),
       in_n_days: Regexp.new(/ ?in ([0-9]+) days/),
       in_n_weeks: Regexp.new(/ ?in ([0-9]+) weeks/),
       in_str_n_days: Regexp.new(/ ?in (#{str_nums.join('|')}) days/),
       in_str_n_weeks: Regexp.new(/ ?in (#{str_nums.join('|')}) weeks/)
      }
    end
end