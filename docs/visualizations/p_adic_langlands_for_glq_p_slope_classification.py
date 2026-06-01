def classify(s1, s2):
    from fractions import Fraction
    s1, s2 = Fraction(s1), Fraction(s2)
    if s1 == 0 and s2 == 0: return 'etale'
    if s1 == 0: return 'ordinary'
    if s1 == s2: return 'supersingular'
    if s1.denominator == 1 and s2.denominator == 1: return 'crystalline'
    return 'trianguline'