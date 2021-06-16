let Person =
      { fName : Text
      , lName : Text
      , email : Optional Text
      , title : Optional Text
      }

let default = { email = None Text, title = None Text }

in  { Type = Person, default }
