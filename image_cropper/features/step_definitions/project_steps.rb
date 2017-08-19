
Given(/^there is 1 project$/) do
  @project = Project.find_by_name 'Doraemon'
  @project ||= FactoryGirl.create :project, user_id: @user.id, isactive: true
  @project.isactive = true
  @project.save
end

Given(/^there is 1 project image$/) do
  @project_image = FactoryGirl.create :project_image, project_id: @project.id
end

Then(/^I should see a project form$/) do
  expect(page).to have_selector('form input#project_name')
  expect(page).to have_selector('form textarea#project_description')
  expect(page).to have_selector('form input#project_images')
  expect(page).to have_selector('form select#project_crop_points')
  expect(page).to have_selector('form input#project_isactive')
end

When(/^I submit the project information$/) do
  fill_in 'Name', with: 'Doraemon' if @project.nil?
  fill_in 'Description', with: 'I am now testing.'
  select('4 Points', :from => 'project[crop_points]')
  attach_file("project_images", "#{Rails.root.to_s}/public/doraemon1.jpg")
  click_button 'Submit'
end

Then(/^I should see the project information$/) do
  @project = Project.first
  expect(page).to have_css 'div#project_name', text: @project.name
  expect(page).to have_css 'div#project_description', text: @project.description
  expect(page).to have_css 'div#project_crop_points', text: @project.crop_points
  expect(page).to have_css 'div#project_isactive', text: @project.isactive
  expect(page).to have_css 'div#project_user', text: @project.user.name
end

Then(/^I should see the project in the list$/) do
  rows = find("table").all('tr')
  rows.map { |r| r.all('td.project_name').map { |c|
    expect(c.text.strip).to eq(@project.name)
  } }
end

When(/^I click the edit link in the project list$/) do
  find(:xpath, "//*[@id='edit_project_#{@project.id}']").click
end

When(/^I click the assign link in the project list$/) do
  find(:xpath, "//*[@id='assign_project_#{@project.id}']").click
end

When(/^I click the delete link in the project list$/) do
  expect(page).to have_css('tr', text: /#{@project.name}/)
  find(:xpath, "//*[@id='delete_project_#{@project.id}']").click
  page.evaluate_script('window.confirm = function() { return true; }')
end

Then(/^the project should be deleted from the project list$/) do
  expect(page).not_to have_css('tr', text: /#{@project.name}/)
end

When(/^I click the download link in the project list$/) do
  page.find('tr', text: /#{@project.name}/).find('a', text: /Download/).click
end

Then(/^I should see a zip file$/) do
  expect(page.response_headers['Content-Type']).to eq("application/zip")
end

Then(/^I should see a tag list for the project$/) do
  expect(page).to have_css('div', text: /Tags/)
end

Then(/^the tag list for the project should (not )?be empty$/) do |neg|
  css = 'li.token-input-token'
  if neg.blank?
    expect(page).not_to have_css(css)
  else
    expect(page).to have_css(css)
  end
end

When(/^I add the tag to the project$/) do
  fill_token_input 'project_tag_tokens', with: @tag.name
  click_button('Submit')
end

Then(/^I should see the tag in the tag list for the project$/) do
  expect(page).to have_css('div#project_tags', text: /#{@tag.name}/)
end

Then(/^I should see the tag(s)? in the tag tokeninput list for the project$/) do |plural|
  @project.tags.each do |tag|
    expect(page).to have_css('li.token-input-token', text: /#{tag.name}/)
  end
end

Given(/^the project has (\d+) tag(s)?$/) do |num, plural|
  (0..num.to_i-1).each do |i|
    tag = FactoryGirl.create :tag
    @project.tags << tag
  end
  @project.save
end

When(/^I delete the tag from the project$/) do
  delete_token_input 'project_tag_tokens', with: @project.tags.first.name
end

Given(/^there are (\d+) crops for the project image$/) do |num|
  num = num.to_i
  #click_link @user.name
  #click_link "Sign Out"
  save_user = @user
  #@user = @cropper
  #visit '/users/sign_in'
  #submit_login_form
  @project_crop_images = []
  x = 0
  (0..num-1).each do |i|
    pci = ProjectCropImage.new project_image_id: @project_image.id, user_id: @cropper.id, image: "#{i}.jpg", tag_id: @project.tags.first.id
    coords = [{x: x, y: 0}, {x: x+300, y: 0}, {x: x+300, y: 300}, {x: x, y: 300}]
    coords.each do |coord|
      pci.project_crop_image_cords.push(ProjectCropImageCord.new x: coord[:x], y: coord[:y])
    end
    pci.save!
    @project_crop_images.push pci
    x = x + 100
  end
  #click_link @user.name
  #click_link "Sign Out"
  #@user = save_user
  #visit '/users/sign_in'
  #submit_login_form
end

Given(/^the project image files are synced$/) do
  projects_path = Rails.application.config.projects_dir
  test_image_path = File.join(Rails.root, 'public', 'doraemon1.jpg')
  system("mkdir -p #{projects_path}")
  Dir.chdir projects_path
  system("rm -rf #{@project.name}")
  system("mkdir #{@project.name}")
  Dir.chdir @project.name
  @project.users.each do |pu|
    system("mkdir #{pu.id}")
  end
  @project.project_images.each do |pi|
    system("cp #{test_image_path} #{pi.image}")
    pi.project_crop_images.each do |pci|
      uid = pci.user.id
      file_path = File.join(projects_path, @project.name, uid.to_s, pci.image)
      system("cp #{test_image_path} #{file_path}")
    end
  end
  Dir.chdir Rails.root
end

Then(/^I should see the download link in the project list$/) do
  expect(page).to have_css('tr', text: /#{@project.name}/)
  anchor = find('tr', text: /#{@project.name}/).find('a', text: /Download/)
  @download_link = anchor['href']
end

When(/^I open the downloaded ZIP file$/) do
  system("rm -rf #{Rails.root}/tmp/downloads/*")
  within('tr', text: /#{@project.name}/) do
    click_link('Download images')
  end
  Timeout.timeout(10) do
    while Dir.glob("#{Rails.root}/tmp/downloads/*").size == 0
      sleep 1
    end
  end
  files = Dir.glob("#{Rails.root}/tmp/downloads/*")
  expect(files.size).to eql(1)
  found = false
  yaml_found = false
  expected = "#{@project.name}/CNN/#{@project_image.image.gsub(/\.jpg$/,'')}.txt"
  expected_yaml = "#{@project.name}/#{@project.name}.yml"
  Zip::File.open(files[0]) do |zipfile|
    zipfile.each do |thisfile|
      if thisfile.to_s == expected
        found = true
        @cnn_file_content = thisfile.get_input_stream.read
      end
      if thisfile.to_s == expected_yaml
        yaml_found = true
        @yaml_file_content = thisfile.get_input_stream.read
      end
    end
  end
  expect(found).to be(true)
  expect(yaml_found).to be(true)
end

Then(/^I should see a CNN text file for the project image$/) do
  expect(@cnn_file_content).not_to be(nil)
  expect(@cnn_file_content.lines.count).to eql(@project_image.project_crop_images.size)
end

Then(/^I should see a YML file for the project$/) do
  expect(@yaml_file_content).not_to be(nil)
end
