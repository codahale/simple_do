require File.dirname(__FILE__) + '/spec_helper'

require "simple_do"

describe DataObjects::Simple do
  describe "initializing with a database.yml filename" do
    before(:each) do
      @db = DataObjects::Simple.new("spec/database.yml", "development")
    end

    it "should load the specified environment's connection options" do
      @db.options.should == { :adapter => "sqlite3", :database => "db/blah.sqlite3" }
      @db.uri.should == "sqlite3:db/blah.sqlite3"
    end

    it "should load the appropriate DataObjects driver" do
      DataObjects.constants.should include("Sqlite3")
    end
  end

  describe "establishing a connection" do
    it "should create a new DataObjects::Connection for the specified database" do
      @db = DataObjects::Simple.new("spec/database.yml", "development")
      DataObjects::Connection.should_receive(:new).with("sqlite3:db/blah.sqlite3").and_return("conn")
      @db.connection.should == "conn"
    end
  end

  describe "selecting values" do
    before(:each) do
      @db = DataObjects::Simple.new("spec/database.yml", "development")
      @reader = stub(:reader, :next! => nil, :close => nil)
      @command = stub(:command, :execute_reader => @reader)
      @connection = stub(:connection, :create_command => @command)
      DataObjects::Connection.stub!(:new).and_return(@connection)
    end

    it "should create a command for the given SQL query" do
      @connection.should_receive(:create_command).with("SELECT * FROM table").and_return(@command)
      @db.select("SELECT * FROM table")
    end

    it "should set the command's return types" do
      @command.should_receive(:set_types).with([Integer, String])
      @db.select("SELECT id, name FROM table WHERE id = ?", [Integer, String])
    end

    it "should execute a reader for the command" do
      @command.should_receive(:execute_reader).and_return(@reader)
      @db.select("SELECT * FROM table")
    end

    it "should pass all bind variables to the reader" do
      @command.should_receive(:execute_reader).with(1).and_return(@reader)
      @db.select("SELECT name FROM table WHERE id = ?", nil, 1)
    end

    it "should iterate over the reader's values and return an array of them" do
      @reader.should_receive(:next!).and_return(true, true, nil)
      @reader.should_receive(:values).and_return([1], [2])
      @db.select("SELECT * FROM table").should == [[1], [2]]
    end

    it "should log the query" do
      logger = mock(:logger)
      logger.should_receive(:debug).with("  \e[4;36;1mSQL:\e[0m   \e[0;1mSELECT name FROM table WHERE id = ? \e[0;47;30;1m[1]\e[0m\e[0m")
      @db.logger = logger
      @db.select("SELECT name FROM table WHERE id = ?", nil, 1)
    end
  end

  describe "executing non-select queries" do
    before(:each) do
      @db = DataObjects::Simple.new("spec/database.yml", "development")
      @result = stub(:result)
      @command = stub(:command, :execute_non_query => @result)
      @connection = stub(:connection, :create_command => @command)
      DataObjects::Connection.stub!(:new).and_return(@connection)
    end

    it "should create a command for the given SQL query" do
      @connection.should_receive(:create_command).with("DELETE FROM table").and_return(@command)
      @db.execute("DELETE FROM table")
    end

    it "should execute the command as a non-query" do
      @command.should_receive(:execute_non_query).and_return(@result)
      @db.execute("DELETE FROM table")
    end

    it "should pass the bind variables to the command" do
      @command.should_receive(:execute_non_query).with(1).and_return(@result)
      @db.execute("DELETE FROM table WHERE id = ?", 1)
    end

    it "should return the result of the query" do
      @db.execute("DELETE FROM table").should == @result
    end

    it "should log the query" do
      logger = mock(:logger)
      logger.should_receive(:debug).with("  \e[4;36;1mSQL:\e[0m   \e[0;1mDELETE FROM table WHERE id = ? \e[0;47;30;1m[1]\e[0m\e[0m")
      @db.logger = logger
      @db.execute("DELETE FROM table WHERE id = ?", 1)
    end
  end
end