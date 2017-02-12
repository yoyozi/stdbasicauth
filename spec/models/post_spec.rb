require 'rails_helper'

RSpec.describe Post, type: :model do

  before(:all) do 
  	@post = Post.new(body: "My body", title: "My Title")
  end

  it "Should have matching body" do 
  	expect(@post.body).to eq("My body")
  end

  it "Should have matching title" do 
  	expect(@post.title).to eq("My Title")
  end

end
