Mail from cs305@mail.com:

    send ["Hello!"] to [("Daniel", daniel@mail.com),
    (username, mehmet@mail.com), (mehmet@mail.com)]

    send ["Bye."] to [(gamze@mail.com)]

    schedule @ [18/04/2022, 06:30]:
        send [Message] to [("Beril", beril@mail.com.tr)]
    end schedule

end Mail


Mail from cs305@sabanciuniv.edu:

    schedule @ [02/12/2021, 23:00]:
        send ["Good morning!"] to [(ali@mail.com),
        ("Ferhat Yilmaz", ferhat@mail.com), ("Ali", ali@mail.com)]
    end schedule

    send ["These are the files."] to [(user_45@mail.co.uk),
    (Name_2, user_45@mail.co.uk)]
end Mail