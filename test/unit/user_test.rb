require 'test_helper'

class UserTest < ActiveSupport::TestCase
  setup do
    @user = users(:user1)
  end

  test "User#load_friends should create new friend" do
    json = JSON.parse '[{"name": "user6", "uid": "16"}, {"name": "user2", "uid": "12"}, {"name": "user3", "uid": "13"}, {"name": "user4", "uid": "14"}, {"name": "user5", "uid": "15"}]'
    assert_difference "@user.friends.count" do
      @user.load_friends json
    end
    assert_equal 5, @user.friends.count
  end

  test "User#load_friends should update friend if exits" do
    json = JSON.parse '[{"name": "user2 new name", "uid": "22"}, {"name": "user3", "uid": "23"}, {"name": "user4", "uid": "24"}]'
    @user.load_friends json
    assert_equal 1, @user.friends.where(:name => "user2 new name").count
  end

  test "User#load_friends should remove friendship if not present" do
    json = JSON.parse '[{"name": "user2", "uid": "32"}]'
    @user.load_friends json
    assert_equal 1, @user.friends.count
  end

  test "User#credits should return all credits" do
    assert_equal 2, @user.credits.count
  end

  test "User#debits should return all debits" do
    assert_equal 2, @user.credits.count
  end

  test "User#credits_for should return credits for friend" do
    user2 = users(:user2)
    credits = @user.credits_for user2
    assert_equal 1, credits.count
  end

  test "User#debits_for should return credits for friend" do
    user2 = users(:user2)
    debits = @user.debits_for user2
    assert_equal 1, debits.count
  end

  test "User#balance_for should return balance" do
    user2 = users(:user2)
    assert_equal(5, @user.balance_for(user2))
  end

  test "User#balance should return user balance" do
    assert_equal 9.99 + 3.99 - 4.99, @user.balance 
  end

  test "User#debts_for should return debts for friend" do
    friend = users(:user2)
    assert_equal 2, @user.debts_for(friend).count
  end

  test "User#debts should return all user debts" do
    @user.credits.create :user_to => users(:user2), :value => 10, :description => "Lunch"
    assert_equal 4, @user.debts.count
  end

  test "User#friends_sorted should be ordered by debts count and names" do
    user5 = users(:user5)
    user5.name = 'aaaaaaname'
    user5.save
    
    friends = @user.friends_sorted
    assert_equal 2, friends[0].id 
    assert_equal 3, friends[1].id 
    assert_equal 5, friends[2].id 
    assert_equal 4, friends[3].id 
  end

  test "User#friends_sorted should order debt count only for user-friend debts" do
    user1 = users(:user1) 
    user1.name = "z"
    user1.save

    user5 = users(:user5)
    friends = user5.friends_sorted
    assert_equal 2, friends[0].id
    assert_equal 1, friends[1].id
  end

  test "User#friends_search should return all friends for empty string" do
    friends = @user.friends_search ""
    assert_equal 4, friends.count
  end

  test "User#friends_search should return friends with name matching pattern" do
    friends = @user.friends_search "2 na"
    assert_equal 1, friends.count

    friends = @user.friends_search "name"
    assert_equal 4, friends.count

    friends = @user.friends_search "qewr"
    assert_equal 0, friends.count
  end
end
