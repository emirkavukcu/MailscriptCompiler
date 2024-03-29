Mail from root@mail.com:
    schedule @ [08/12/1365, 00:00]:
        send ["1"] to [("A", a@mail.com)]
    end schedule
    schedule @ [08/12/1365, 12:05]:
        send ["2"] to [("B", b@mail.com)]
    end schedule
    schedule @ [01/12/1365, 23:59]:
        send ["3"] to [("C", b@mail.com)]
    end schedule
end Mail