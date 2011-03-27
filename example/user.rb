namespace "Account" do
  field("id")        { type :integer }
  field("firstname") { example "John" }
  field("lastname")  { example "Doe" }
  field("login")     { example "john.doe" }
  field("password")  { example "secretxxx" }
  
  object "User" do
    fields "Account.id", "Account.firstname", "Account.lastname", 
           "Account.login", "Account.password"
    example_file :json, "datagram/user.json"
  end
  
  interface "UserRest" do
    base_uri "/account"
    
    get "users/" do
      response do
        array "Account.User" 
        example_file :json, "datagram/user.json"
      end
    end  
  end
end

interface "SystemCheck" do
  get "check" do
    desc "returns true if the system is ok otherwise false"
    
    response do
      example :text, "OK"
    end
  end
end