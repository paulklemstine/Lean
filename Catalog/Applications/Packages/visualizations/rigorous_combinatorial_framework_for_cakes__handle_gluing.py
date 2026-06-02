def handle_glue(g1, b1, n1, g2, b2, n2):
    assert b1 >= 1 and b2 >= 1
    return (g1+g2+1, b1+b2-2, n1+n2)