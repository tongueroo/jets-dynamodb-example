ENV["TEST"] = "1"
ENV["JETS_ENV"] ||= "test"
# Ensures aws api never called. Fixture home folder does not contain ~/.aws/credentails
ENV['HOME'] = "spec/fixtures/home"

# Work around dynamodb-local assumpion that AWS_ACCESS_KEY_ID is set
# https://community.rubyonjets.com/t/running-rspec-over-dynomite-model-with-local-dynamodb-instance-results-in-missingcredentialserror/31/5
if ENV['DYNAMODB_TEST_AWS_SECRET_ACCESS_KEY']
  ENV['AWS_SECRET_ACCESS_KEY'] = ENV['DYNAMODB_TEST_AWS_SECRET_ACCESS_KEY']
end
if ENV['DYNAMODB_TEST_AWS_ACCESS_KEY_ID']
  ENV['AWS_ACCESS_KEY_ID'] = ENV['DYNAMODB_TEST_AWS_ACCESS_KEY_ID']
end
ENV['AWS_REGION'] ||= 'us-west-2'

require "byebug"
require "fileutils"
require "jets"

abort("The Jets environment is running in production mode!") if Jets.env == "production"
Jets.boot



module Helpers
  def payload(name)
    JSON.load(IO.read("spec/fixtures/payloads/#{name}.json"))
  end
end

RSpec.configure do |c|
  c.include Helpers
end
