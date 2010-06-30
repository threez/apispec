require "apispec"
DEFAULT_FORMAT = :json

module Fields
  UserID = APISpec::Field.new do
    name "X-User"
    desc "The users email address"
    example "test@example.com"
  end

  FolderID = APISpec::Field.new do
    name "folder_id"
    desc "unique id of folder for user"
  end
end

module Objects
  Folder = APISpec::Object.new do
    name "Folder"
    fields Fields::FolderID
    example DEFAULT_FORMAT, %q{
      asd
    }
  end
end

Folders = APISpec::Interface.new do
  name "Folders"
  base_uri "http://example.com/mail-rest"
  
  get 'folders' do
    desc "returns the list of folders"
  
    request do
      headers Fields::UserID
    end
    
    response do
      example DEFAULT_FORMAT, %q|
{
  "Kreditkarte" : "Xema",
  "Nummer"      : "1234-5678-9012-3456",
  "Inhaber"       : {
    "Name"        : "Reich",
    "Vorname"     : "Rainer",
    "Geschlecht"  : "männlich",
    "Vorlieben"   : [ "Reiten", "Schwimmen", "Lesen" ],
    "Alter"       : null
  },
  "Deckung"     : 2e+6,
  "Währung"     : "EURO"
}
      |
      content [Objects::Folder]
    end
  end
  
  get 'folder/:folder_id' do
    desc "returns the mail header objects of the requested Folder"
  
    request do
      headers Fields::UserID
      params Fields::FolderID
    end
    
    response do
      content Objects::Folder
    end
  end
end

APISpec::Generator.create("folders.html", Folders)