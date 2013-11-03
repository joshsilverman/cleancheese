require 'test_helper'
include FuzzyTime

describe FuzzyTime do
  describe '#convert_fuzzy_datetime_str_to_datetime' do
    it 'returns nil for empty str' do
      convert_fuzzy_datetime_str_to_datetime('').must_equal nil
    end

    it 'returns nil for bad str' do
      convert_fuzzy_datetime_str_to_datetime('asdf').must_equal nil
    end

    {"in 3 days" => 3.days, 
     "in three days" => 3.days,
     "in 3 weeks" => 3.weeks,
     "in four weeks" => 4.weeks,
     "next week" => 1.week,
     "tomorrow" => 1.day }.each do |fuzzy_time, delta|
      it "returns a #{Time.now + delta} when given #{fuzzy_time}" do
        date = convert_fuzzy_datetime_str_to_datetime fuzzy_time

        date_i = (Time.now + delta).to_i
        assert_in_delta date.to_i, date_i, 1
      end
    end
  end

  describe '#strip_complete_by_str' do
    it 'returns nil for empty str' do
      strip_complete_by_str('').must_equal ''
    end

    it 'returns input str if no fuzzy time exp in str' do
      strip_complete_by_str('asdf').must_equal 'asdf'
    end

    {"asdfa in 3 days" => 'asdfa', 
     "asdfb in three days" => 'asdfb',
     "asdfc in 3 weeks" => 'asdfc',
     "asdfd in four weeks" => 'asdfd',
     "asdfe next week" => 'asdfe',
     "asdff tomorrow" => 'asdff' }.each do |str_w_fuzzy_time, str|
      it "returns a #{str} when given #{str_w_fuzzy_time}" do
        strip_complete_by_str(str_w_fuzzy_time).must_equal str
      end
    end
  end
end