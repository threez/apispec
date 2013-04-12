require File.expand_path(File.join(File.dirname(__FILE__), 'spec_helper'))

EXAMPLE_DIR = File.expand_path(File.join(File.dirname(__FILE__), "..", "example"))

describe APISpec::Generator do
  let(:generator) { described_class.new :workspace => EXAMPLE_DIR }
  
  context "parsed" do
    before { generator.parse_files! }

    context "#print_tree" do
      let(:tree) { generator.namespace.print_tree() }
      subject { tree }
      
      it { should include('Namespace  (Nodes: 6)') }
      it { should include('  Namespace Account (Nodes: 7)') }
      it { should include('    User => Object User') }
      it { should include('    UserRest => Interface UserRest') }
      it { should include('    firstname => Field firstname') }
      it { should include('    id => Field id') }
      it { should include('    lastname => Field lastname') }
      it { should include('    login => Field login') }
      it { should include('    password => Field password') }
      it { should include('  Folder => Object Folder') }
      it { should include('  FolderID => Field folder_id') }
      it { should include('  Folders => Interface Folders') }
      it { should include('  SystemCheck => Interface SystemCheck') }
      it { should include('  UserID => Field X-User') }
    end
  
    it "should be possible to find fields using there path" do
      generator.namespace.find_field("Account.User").should_not be_nil
      generator.namespace.find_field("Folder").should_not be_nil
      generator.namespace.find_field("UserID").should_not be_nil
    end
    
    it "raises error if something is already definded" do
      expect { generator.parse_files! }.to \
        raise_error(APISpec::Namespace::AlreadyDefinedError)
    end
  end
end
