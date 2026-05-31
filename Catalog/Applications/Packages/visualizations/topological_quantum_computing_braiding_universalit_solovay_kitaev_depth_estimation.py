def solovay_kitaev_depth(eps0, target):
    n = 0
    while eps0 ** (1.5 ** n) >= target and n < 100:
        n += 1
    return n