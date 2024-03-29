set Message ("This message sent via MailScript program.")
/*
    This is a multiline comment
    /* 
        This is a nested multiline comment
    */

*/
set Name ("Ali")
Mail from username@sabanciuniv.edu:
    schedule @ [04/07/2024, 00:00]:
        send [Message] to [(Name, deniz@mail.com.tr)]
    end schedule
end Mail

/* This is a multiline comment with no closing tag
/* The rest of the program is treated as comment

Mail from username@sabanciuniv.edu:
    schedule @ [04/07/2024, 00:00]:
        send ["Hi"] to [(selin@mail.com)]
    end schedule
end Mail