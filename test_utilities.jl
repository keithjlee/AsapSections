function w_section_maker(d, b, tf, tw)

    d_web = d - 2tf
    b_free_flange = (b - tw) / 2

    p1 = [tw/2, d_web/2]
    p2 = p1 + [b_free_flange, 0.]
    p3 = p2 + [0., tf]
    p4 = p3 - [b, 0.]
    p5 = p4 - [0., tf]
    p6 = p5 + [b_free_flange, 0.]
    p7 = p6 - [0., d_web]
    p8 = p7 - [b_free_flange, 0.]
    p9 = p8 - [0., tf]
    p10 = p9 + [b, 0.]
    p11 = p10 + [0., tf]
    p12 = p11 - [b_free_flange, 0.]

    return hcat(p1, p2, p3, p4, p5, p6, p7, p8, p9, p10, p11, p12)
end