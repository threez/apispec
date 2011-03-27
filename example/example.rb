field "X-User", "UserID" do
  desc "The users email address"
  example "test@example.com"
end

field "folder_id", "FolderID" do
  desc "unique id of folder for user"
end

object "Folder" do
  fields "FolderID"
  example :text, %q{
    asd
  }
end

interface "Folders" do
  base_uri "http://example.com/mail-rest"
  
  get 'folders' do
    desc "returns the list of folders"
  
    request do
      headers "UserID"
    end
    
    response do
      example :json, %q|
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
      array "Folder"
    end
  end
  
  get 'folder/:folder_id' do
    desc "returns the mail header objects of the requested Folder"
  
    request do
      headers "UserID"
      params "FolderID"
    end
    
    response do
      object "Folder"
    end
  end
end
