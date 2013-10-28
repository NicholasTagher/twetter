require 'spec_helper'

describe RetweetsController do
  let(:tweet) { FactoryGirl.create(:tweet) }

  context "when a user is not logged in" do
    describe "POST create" do
      subject { response }

      before { post :create, :retweet => { :tweet_id => tweet.id } }

      it { should_not be_successful }
    end
  end

  context "when a user is logged in" do
    let(:user) { FactoryGirl.create(:user) }

    before { sign_in user }

    describe "POST create" do
      context "when passed a valid tweet id" do
        it "should create the retweet" do
          expect {
            post :create, :retweet => { :tweet_id => tweet.id }
          }.to change{ Retweet.count }.by(1)
        end

        it "should set a success notice" do
          post :create, :retweet => { :tweet_id => tweet.id }
          flash[:success].should == "You retweeted: #{tweet.content}"
        end
      end

      context "when passed an invalid tweet id" do
        it "should not create the retweet" do
          expect {
            post :create, :retweet => { :tweet_id => -1 }
          }.to_not change{ Retweet.count }
        end

        it "should set an error notice" do
          post :create, :retweet => { :tweet_id => -1 }
          flash[:error].should == "We're sorry. You are unable to retweet that post."
        end
      end

      context "when a return_to param is provided" do
        let(:return_to) { 'http://thinkful.com' }

        subject { response }

        before { post :create, :retweet => { :tweet_id => tweet.id }, :return_to => return_to }

        it { should redirect_to return_to }
      end

      context "when no return_to param is provided" do
        subject { response }

        before { post :create, :retweet => { :tweet_id => tweet.id } }

        it { should redirect_to root_path }
      end
    end
  end
end
