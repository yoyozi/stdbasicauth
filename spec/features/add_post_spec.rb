require 'rails_helper'

RSpec.feature "adding posts" do 


	scenario ' allow a user to add a post, fixture test' do 	

		# Instead of commented below we use a factory
		posts = create(:post)

		visit new_post_path

		fill_in "Title", with: "My Title"
		fill_in "Body", with: "My body"

		click_on("Create Post")

		expect(page).to have_content("My Title")
		expect(page).to have_content("My body")

	end	


	scenario ' allow a user to add a post, factory test' do 	

		# Instead of commented below we use a factory
		post = create(:post)

		visit post_path(post)

		expect(page).to have_content("My new title")
		expect(page).to have_content("My new body")

	end	

end