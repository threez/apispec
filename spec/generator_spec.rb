require File.expand_path(File.join(File.dirname(__FILE__), 'spec_helper'))

EXAMPLE_DIR = File.expand_path(File.join(File.dirname(__FILE__), "..", "example"))

describe APISpec::Generator do
  before(:each) do
    @generator = APISpec::Generator.new
    @generator.working_directory = EXAMPLE_DIR
  end
  
  it "should be possible to parse the example" do
    @generator.parse_files!
  end
  
  it "should be possible to parse the example" do
    @generator.parse_files!
    puts @generator.namespace.print_tree()
  end
  
  it "should be possible to find fields using there path" do
    @generator.parse_files!
    field = @generator.namespace.find_field("Header.X-User")
    
    field = @generator.namespace.find_field("Header.Quota.X-QuotaSize")
    # ...
    field = @generator.namespace.find_field("Mail.attachments")
  end
end