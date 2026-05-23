def gauss_lemma_legendre(a, p):
    a = a % p
    if a == 0: return 0
    half = p // 2
    n = sum(1 for k in range(1, (p-1)//2+1) if (a*k)%p > half)
    return (-1) ** n