require 'spec_helper'
require 'capybara/rspec'

describe "the views for people", :type => :request do
  before(:all) do
    @person = Person.create(:first_name => "John", :last_name => "Doe")
    number_a = @person.phone_numbers.create(:number => "1234567")
    number_b = @person.phone_numbers.create(:number => "7654321")
    @person.email_addresses.create(:address => "john@doe.com")
    @person.email_addresses.create(:address => "doe@john.com")
  end

  describe "when looking at the list of people" do
    before(:all) do
      visit people_path
    end
      
    it "should display email addresses" do
      @person.email_addresses.each do |email_address|
        page.should have_selector('li', :text => email_address.address)
      end
    end
  end
 
  describe "when looking at a single person" do
    before(:each) do
      visit person_path(@person)
    end

    it "should have delete links for each email address" do
      @person.email_addresses.each do |email_address|
        page.should have_link("delete_email_address_#{email_address.id}")
      end
    end

    it "should have an add email address link" do
      page.should have_link("new_email_address")      
    end

    it "should go to the new email address form when the link is clicked" do
      click_link "new_email_address"
      current_path.should == new_email_address_path
    end

    it "should display each of the email addresses" do
      @person.email_addresses.each do |email_address|
        page.should have_selector('li', :text => email_address.address)
      end
    end

    it "should have edit links for each phone number" do        
      @person.phone_numbers.each do |phone_number|
        page.should have_link("edit", :href => edit_phone_number_path(phone_number))
      end
    end
    
    it "should have delete links for each phone number" do
      @person.phone_numbers.each do |phone_number|
        page.should have_link("delete", :href => phone_number_path(phone_number))
      end      
    end
    
    it "should show the person after deleting a phone number" do
      target = @person.phone_numbers.first
      page.click_link("delete_phone_number_#{target.id}")
      current_path.should == person_path(@person)
      page.should_not have_link("delete", :href => phone_number_path(target))
    end
    
    it "should show the person after deleting an email address" do
      target = @person.email_addresses.first
      page.click_link("delete_email_address_#{target.id}")
      current_path.should == person_path(@person)
      page.should_not have_link("delete_email_address_#{target.id}")
    end
  end
end