def verify_bayes(a, b, n):
    from fractions import Fraction
    pab = Fraction(len(a&b), len(b))
    pba = Fraction(len(a&b), len(a))
    pa = Fraction(len(a), n)
    pb = Fraction(len(b), n)
    return pab * pb == pba * pa