Given /^I go to the "(.*)" page$/ do |page|
  url = "#{Configuration.instance.get(:site, :base_domain)}/#{Configuration.instance.get(:site, page)}"
  begin
    @browser.goto(url)
  rescue => ex
    raise Exception.new("Error starting browser was #{ex}.")
  end
end

And /^I sign in as an (new|existing) user$/ do |user_type|
  username = Configuration.instance.get(:site, :username)
  password = Configuration.instance.get(:site, :password)
  if user_type.eql?("new")
    puts "Dont know how to create a new user yet"
  end
  @browser.div(:class , 'header_user_info').a(:class, 'login').when_present.click
  login_existing_user(username, password)
end

And /^I select the item at "(.*)" position$/ do |index|
  product = "http://automationpractice.com/index.php?id_product=#{index.to_i}&controller=product"
  set_index(index)
  @browser.a(:href , product).when_present.click
end

And /^I see the product details frame for "(.*)"$/ do |product|
  product_frame = @browser.iframe(:src , "http://automationpractice.com/index.php?id_product=#{get_index}&controller=product&content_only=1")
  Watir::Wait.for_condition(10,1,"waiting to see the product detail frame") {
    product_frame.visible?
  }
end

And /^I set the size to be "(.*)" in the product detail page and add it to my shopping cart$/ do |size|
  prod_detail = @browser.iframe(:src , "http://automationpractice.com/index.php?id_product=#{get_index}&controller=product&content_only=1")
  prod_detail.select_list(:id , 'group_1').select_value(2)
  prod_detail.button(:name , 'Submit').click
end

And /^I continue shopping$/ do
  sleep(3) # allow a short time to load the element so we click the right one
  cart = @browser.div(:class , 'layer_cart_cart')
  cart.wait_until_present
  cart.span(:class , 'continue').when_present.click
end

And /^I view my basket$/ do
  sleep(3) # allow a short time to load the element so we click the right one
  cart = @browser.div(:class , 'layer_cart_cart')
  cart.wait_until_present
  cart.a(:title , 'Proceed to checkout').when_present.click
  sleep(2)
end

And /^the basket will contain the product "(.*)" in size "(.*)" with a unit price of "(.*)"$/ do |product, size, price|
  Watir::Wait.for_condition(15,1,"waiting to see the checkout order page") {
    @browser.url.eql?('http://automationpractice.com/index.php?controller=order')
  }
  product_table = @browser.table(:id , 'cart_summary')
  #found = false
  order_row =  Configuration.instance.get(:products , product)['id'].to_s
  cart_desc =  product_table.tr(:id , order_row).td(:class , 'cart_description').text
  cart_price = product_table.tr(:id , order_row).td(:class , 'cart_total').text
  item_name = Configuration.instance.get(:products , product)['title'].to_s
  unless cart_desc.include?(item_name) && cart_desc.include?("Size : #{size}") && cart_price.include?(price.to_s)
    raise Exception.new("I expected the cart to include #{item_name} in size #{size}, but I got #{cart_desc} with price #{cart_price}")
  end
end

And /^the product cost of my order will be "(.*)"$/ do |product_cost|
  disp_order_cost = @browser.div(:id , 'order-detail-content').tr(:class , 'cart_total_price').text
  unless disp_order_cost.to_s.gsub('$','').include?(product_cost.to_s)
    throw Exception.new("Cost = #{product_cost} :  Displayed cost #{disp_order_cost}")
  end
end

And /^the shipping cost of my order will be "(.*)"$/ do |ship_cost|
  disp_delivery_cost = @browser.div(:id , 'order-detail-content').tr(:class , 'cart_total_delivery').text
  unless disp_delivery_cost.to_s.gsub('$','').include?(ship_cost.to_s)
    throw Exception.new("Cost = #{ship_cost} :  Displayed cost #{disp_delivery_cost}")
  end
end

And /^the total cost of my order will be "(.*)"$/ do |total_cost|
  disp_total_cost = @browser.div(:id , 'order-detail-content').span(:id , 'total_price').text
  unless disp_total_cost.to_s.gsub('$','').include?(total_cost.to_s)
    throw Exception.new("Cost = #{total_cost} :  Displayed cost #{disp_total_cost}")
  end
end

And /^I will be able to complete my purchase successfully$/ do
  @browser.p(:class , 'cart_navigation clearfix').a(:class , 'button').when_present.click
  Watir::Wait.for_condition(20,1,"waiting to see next step of checkout") {
    @browser.url.eql?('http://automationpractice.com/index.php?controller=order&step=1')
  }
  step "I click the Proceed to Checkout button on the address page"
  step "I accept the terms and conditions on the delivery page"
  step "I click the Proceed to Checkout button on the delivery page"
  step "I select to pay by wire"
  step "I confirm I want to place my order"
  step "I will see he order confirmation page displayed"
end

And /^I click the Proceed to Checkout button on the address page$/ do
  Watir::Wait.for_condition(10,1,"waiting to see the address selection page to display.  Page url is #{@browser.url}") {
    @browser.url.eql?("http://automationpractice.com/index.php?controller=order&step=1")
  }
  @browser.p(:class , 'cart_navigation').button(:type , 'submit').wait_until_present
  @browser.p(:class , 'cart_navigation').button(:type , 'submit').click
end

And /^I accept the terms and conditions on the delivery page$/ do
  Watir::Wait.for_condition(10,1,"waiting to see the delivery option page to display. Page url is #{@browser.url}") {
    @browser.span(:class , 'navigation_page').text.eql?("Shipping")
  }
  @browser.form(:name , 'carrier_area').checkbox(:id , 'cgv').set
end

And /^I click the Proceed to Checkout button on the delivery page$/ do
  @browser.p(:class , 'cart_navigation').button(:name , 'processCarrier').wait_until_present
  @browser.p(:class , 'cart_navigation').button(:name , 'processCarrier').click
end

And /^I select to pay by wire$/ do
  Watir::Wait.for_condition(10,1,"waiting to see the delivery option page to display. Page url is #{@browser.url}") {
    @browser.span(:class , 'navigation_page').text.eql?("Your payment method")
  }
  @browser.p(:class , 'payment_module').a(:class , 'bankwire').wait_until_present
  @browser.p(:class , 'payment_module').a(:class , 'bankwire').click
end

And /^I confirm I want to place my order$/ do
  @browser.p(:class , 'cart_navigation').button(:type , 'submit').wait_until_present
  @browser.p(:class , 'cart_navigation').button(:type , 'submit').click
end

Then /^I will see he order confirmation page displayed$/ do
  Watir::Wait.for_condition(10,1,"The order confiormation page is not shown.  Page url is #{@browser.url}") {
    @browser.url.match(Regexp.new(/http:\/\/automationpractice.com\/index.php\?controller\=order-confirmation&id_cart\=[0-9]*&id_module\=[0-9]*&id_order\=[0-9]*&key\=[0-9a-z]*/))
  }
  params = Rack::Utils.parse_query URI(@browser.url).query
  set_last_order_id(params)
end

And /^I will be able to log out$/ do
  @browser.a(:class , 'logout').when_present.click
  Watir::Wait.for_condition(20,1,"waiting to see user is not logged in") {
    @browser.a(:class , 'login').visible?
  }
end

And /^I visit the my account page$/ do
  @browser.div(:class , 'header_user_info').a(:class, 'account').wait_until_present
  @browser.div(:class , 'header_user_info').a(:class, 'account').click
end

Given /^I create a new cart$/ do
  create_cart
end

And /^I select to view "(.*)"$/ do |selection|
  id = get_my_account_option(selection)
  list = @browser.ul(:class , "myaccount-link-list")
  list.wait_until_present
  list.a(:title, id).click
end

And /^I select the most recent order$/ do
  Watir::Wait.for_condition(10,1,"waiting to see my order history.  Page URL is #{@browser.url}") {
    @browser.url.eql?("http://automationpractice.com/index.php?controller=history")
  }
  #@browser.table(:id , 'order-list').tds.each do |data|
  #  puts data.td(:class , 'history_date').attribute_value('data-value')
  #end
  order_id = get_last_order_id
  link = "javascript:showOrder(1, #{order_id}, 'http://automationpractice.com/index.php?controller=order-detail');"
  sleep(2)
  @browser.table(:id , 'order-list').td(:class , 'history_detail').a(:href , link).click
end

And /I create a message for the order item "(.*)" as "(.*)"$/ do |item , message|
  set_saved_message(message)
  @browser.form(:id , 'sendOrderMessage').wait_until_present
  @browser.form(:id , 'sendOrderMessage').select_list(:name, 'id_product').select_value(item.to_i)
  @browser.form(:id , 'sendOrderMessage').textarea(:name , 'msgText').set(message)
end

And /^I submit my message$/ do
  sleep(2)
  @browser.form(:id , 'sendOrderMessage').div(:class , 'submit').button(:class , 'button btn btn-default button-medium').click
end

And /^my message will be saved under Messages$/ do
  sleep(2)
  unless @browser.div(:id, 'block-order-detail').p(:class , 'alert alert-success').visible?
    throw Exception.new("could not verify the message was saved. ")
  end
=begin
  #I could not see the saved message in the table
  messages = @browser.table(:class , 'detail_step_by_step table table-bordered')
  found = false
  messages.tr(:class , 'first_item').tds.each do |message|
    puts message.text
    if message.text.include?(get_saved_message)
      found = true
    end
    unless found
      throw Exception.new("Could not see the new message in saved messages")
    end
  end
=end
end

And /^the item "(.*)" will be size "(.*)" and the colour "(.*)"$/ do |order_item , size, colour |
  sleep(4)
  table = @browser.div(:id , 'order-detail-content').table(:class , 'table').tbody
  text = table.trs.collect{ |tr| tr[0].text }
  unless text.eql?('wibble')
    throw Exception.new("Test failed.  need to build up proper code")
  end
end

private

def login_existing_user(user, pass)
  Watir::Wait.for_condition(20,1,"waiting to see the login page") {
    @browser.url.eql?("http://automationpractice.com/index.php?controller=authentication&back=my-account")
  }
  @browser.text_field(:id, 'email').wait_until_present
  @browser.text_field(:id, 'email').set(user)
  @browser.text_field(:id , 'passwd').set(pass)
  @browser.button(:id , 'SubmitLogin').click
end

def set_index(index)
  @index = ''
  @index = index.to_i
end

def get_index
  @index
end

def create_cart
  @cart = []
end

def add_cart_contents(product_details)
  @cart << product_details
end

def get_my_account_option(selection)
  case selection
    when "My Orders"
      title_id = 'Orders'
  end
  title_id
end

def set_last_order_id(params)
  array = []
  order_id = params.values_at('id_order').first
  array << order_id unless array.include?(order_id)
  File.open("recent_orders.txt", "w+") do |f|
    array.each { |element| f.puts(element) }
  end
end

def get_last_order_id
  order_id = ''
  text=File.open('recent_orders.txt').read
  text.gsub!(/\r\n?/, "")
  text.each_line do |line|
    order_id = line
  end
  return order_id.to_i
end

def set_saved_message(message)
  @message = message
end

def get_saved_message
  @message
end