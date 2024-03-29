set Outgoing ("This is a message.")

Mail from cs305@mail.com:
    set Outgoing ("CS 305")
    send ["Hello!"] to [("Daniel", daniel@mail.com),
    ("Ahmet", mehmet@mail.com), (mehmet@mail.com)]

    schedule @ [02/12/2021, 12:00]:
        send ["Good morning!"] to [(ali@mail.com),
        ("John Doe", john@mail.com), ("Ali", ali@mail.com)]
    end schedule

    
end Mail

set newMessage ("Thank you.")

Mail from cs305@mail.com:

    set Name ("Omer")
    schedule @ [28/11/2021, 04:00]:
        send [Outgoing] to [(Name, omer@mail.com)]
    end schedule

    send [newMessage] to [("u1", u1@x.com), (u2@x.com),
    (u1@x.com), (u1@x.com), (Name, u1@x.com)]

end Mail