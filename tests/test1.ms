set Message ("Welcome to CS305.")
set Name ("Deniz")

Mail from derya@mail.com:

    send ["Hello!"] to [("Ayse", ayse@mail.com), 
    (mehmet@mail.com), ("Mehmet", mehmet@mail.com)]

    schedule @ [03/10/2021, 16:00]:
        send [Message] to [("Beril", beril@mail.com.tr)]
        send ["Thank you 
        very much."] to [(Name, deniz@mail.com.tr)]
    end schedule
    
end Mail


Mail from derya@sabanciuniv.edu:

    schedule @ [02/10/2021, 16:00]:
        send ["Good morning!"] to [(ali@mail.com),
        ("Ferhat Kaya", ferhat@mail.com),
        ("Ali", ali@mail.com)]
    end schedule
    
end Mail

Mail from derya@mail.com:

    schedule @ [03/10/2021, 04:00]:
        send ["How are you?"] to [("Omer", omer@mail.com)]
    end schedule

end Mail