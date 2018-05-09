Given /^I wait "(.*)" seconds to let things settle$/ do |time|
  sleep(time.to_i)
end

And /^I GET "(.*)"$/ do | path |
  #https://reqres.in
  url = "https://reqres.in#{path}"
  HttpUtils.instance.get(url)
  JsonApi.instance.last_fetched_json=HttpUtils.instance.content
  puts JsonApi.instance.last_fetched_json
end

Then /^the JSON response code should be "(.*)"$/ do |code|
  HttpUtils.instance.response_code.should eq code
end

Then /^the JSON should have text matching value "([^"]*)" at path "([^"]*)"$/ do |value, path|
  JsonApi.instance.value_at_path( path ).to_s.should eq value
end

And /^the returned user details should contain text matching value "(.*)" at path "(.*)"$/ do |expected_value , path|
  details = JSON.parse(JsonApi.instance.last_fetched_json).values_at("data")[0]
  unless details.values_at(path).to_s.include?(expected_value.to_s)
    throw Exception.new("Expected to see a value of #{expected_value} at path #{path} but I got #{details.values_at(path).to_s}")
  end
end

And /^the returned resource details should contain text matching value "(.*)" at path "(.*)" for resource "(.*)"$/ do |expected_value , path, node|
  details = JSON.parse(JsonApi.instance.last_fetched_json).values_at("data")[0][node.to_i]
  unless details.values_at(path).to_s.include?(expected_value.to_s)
    throw Exception.new("Expected to see a value of #{expected_value} at path #{path} but I got #{details.values_at(path).to_s}")
  end
end

When /^I POST the request to create a new user at path "(.*)" with name "(.*)" and role "(.*)"$/ do | path, name , role |
  url = "https://reqres.in#{path}"
  header = {  }
  body = {"name" => name, "job" => role}
  HttpUtils.instance.post( url , body , header )
  JsonApi.instance.last_fetched_json = HttpUtils.instance.content
end

Given /^I PUT the request to update user at path "(.*)" with name "(.*)" and role "(.*)"$/ do | path, name, role |
  url = "https://reqres.in#{path}"
  header = {  }
  body = {"name" => name, "job" => role}
  HttpUtils.instance.put( url , body , header )
  JsonApi.instance.last_fetched_json = HttpUtils.instance.content
end

Given /^I DELETE the user at path "(.*)"$/ do |path|
  url = "https://reqres.in#{path}"
  header = {  }
  HttpUtils.instance.delete( url,  header )
  JsonApi.instance.last_fetched_json = HttpUtils.instance.content
end