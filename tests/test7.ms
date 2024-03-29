set Message ("Welcome to CS305.")
Mail from nermin@mail.com:
    schedule @ [27/10/2021, 07:48]:
        send [Message] to [("Kerem", kerem@mail.com.tr)]
    end schedule

    set Message ("Our project is due tomorrow.")

    send [Message] to [("Mine", mine@mail.com),
    (selim@mail.com)]
 
end Mail

Mail from nermin@sabanciuniv.edu:

end Mail

Mail from serkan@sabanciuniv.edu:
    set UserName ("There is a meeting at 3pm.")
    schedule @ [02/10/2021, 16:00]:
        send [MorningMessage] to [(ali@mail.com),
        ("John Doe", emre@mail.com),
        (UserName, ali@mail.com)]
        send ["How are you?"] to [("Omer", omer@mail.com)]
    end schedule
end Mail