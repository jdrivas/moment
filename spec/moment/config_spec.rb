require 'spec_helper'
require 'moment'

TEST_CONFIG_CONTENT = <<EOS
---
# TEST CONFIGFILE
:environments:
  :production: 
    :endpoint: moment-test
    :repo: git@github.com:jdrivas/moment-test-site.git
    :branch: master

  :staging: 
    :endpoint: staging.moment-test
    :repo: git@github.com:jdrivas/moment-test-site.git
    :branch: staging

:directory: my-test-site
EOS

# Note we're using fakefs for a file system.
describe Moment::Configuration, :fakefs do

  let(:test_config_name){".moment.yaml"}
  before do 
    Moment.stub(:default_configuration_path).and_return(test_config_name)
  end

  it "sets the default configuration path correctly" do
    Moment::get_configuration.file_name.should eq test_config_name
  end

  it "creates a new configuration file." do
    Moment::create_configuration()
    File.exist?(test_config_name).should be_true
  end

  it "throws an error if you try to create a configuration file with a directory in the path that doesn't exist" do
    expect{Moment::create_configuration(false, "foo/.bar")}.to raise_error
  end

  describe "test the default configuration" do
    before { Moment::create_configuration}

    it "should read the default config file" do
      c = Moment.get_configuration.configuration
      c[:environments][:production][:endpoint].should eq "moment-site"
      c[:environments][:staging][:endpoint].should eq "staging.moment-site"
    end
  end

  describe "test an existing configuration" do

    before {File.open(test_config_name, "w") { |f| f.puts TEST_CONFIG_CONTENT}}

    it "reads an existing config file" do
      c = Moment::get_configuration.configuration
      c[:environments][:production][:endpoint].should eq "moment-test"
      c[:environments][:production][:branch].should eq "master"
      c[:environments][:production][:repo].should eq "git@github.com:jdrivas/moment-test-site.git"
      c[:directory].should eq "my-test-site"
    end

    it "will not overwrite an eixsting configuration file" do
      expect {Moment::create_configuration}.to raise_error
    end

    it "will overwrite an existing configuration if you ask nicely" do
      Moment::create_configuration(true)
      c = Moment::get_configuration.configuration
      c[:environments][:production][:endpoint].should eq "moment-site"
      c[:environments][:production][:branch].should eq "master"
      c[:environments][:production][:repo].should eq "git@github.com:my_git_account/moment-test-site.git"
      c[:directory].should eq "my_site"
      c[:environments][:staging][:endpoint].should eq "staging.moment-site"
    end

  end
end
