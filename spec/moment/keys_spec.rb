require 'spec_helper'
require 'moment'
require 'fileutils'

describe Moment::Keys do
  before {FileUtils.cp(".aws_credentials", ".aws_credentials.orig")}
  after {FileUtils.mv(".aws_credentials.orig", ".aws_credentials")}
  let(:access_key_id){"access_id"}
  let(:secret_key){"secret_key"}
  let(:new_key){Moment::Keys.new(access_key_id, secret_key)}
  it "should create a new set of keys from a access_key_id and secret_key_id" do
    new_key.access_key_id.should eq(access_key_id)
    new_key.secret_key.should eq(secret_key)
  end

  it "should install then return the correct installed keys" do
    new_key.install
    retreived_key = Moment::Keys.installed
    retreived_key.access_key_id.should eq new_key.access_key_id
    retreived_key.secret_key.should eq new_key.secret_key
  end

  it "should set permissions on the file to user-only read/write" do
    new_key.install
    File.stat(Moment::Keys.install_filename).mode.to_s(8)[3..5].should eq "600"
  end

end