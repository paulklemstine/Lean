def check_wa(s1, s2, h1, h2):
    from fractions import Fraction
    s1, s2 = Fraction(s1), Fraction(s2)
    if s1 + s2 != Fraction(h1 + h2): return False
    if s1 < Fraction(h1): return False
    return True