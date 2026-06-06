def find_survivors(theories_with_niches):
    from fractions import Fraction
    niche_max = {}
    for t, niche in theories_with_niches:
        f = Fraction(t[2]*t[1], t[0]**2)
        niche_max[niche] = max(niche_max.get(niche, f), f)
    return [(t,n) for t,n in theories_with_niches if Fraction(t[2]*t[1],t[0]**2) >= niche_max[n]]