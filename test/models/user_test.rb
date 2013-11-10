require 'test_helper'

describe 'User' do
  describe '#has_many :epics' do
    it 'is valid without epics' do
      user = User.new

      user.valid?.must_equal true
    end

    it 'is valid with epics' do
      user = User.create
      epic = Epic.create

      epic.user = user
      epic.save

      user.epics.empty?.wont_equal true
      user.valid?.must_equal true
    end
  end

  describe '#sms' do
    it 'returns post' do
      skip('INC')
    end
  end

  describe '#todays_goal' do
    it 'returns goal if incomplete one exists' do
      skip('INC')
    end

    it 'returns nil if incomplete doesnt exists' do
      skip('INC')
    end
  end
end