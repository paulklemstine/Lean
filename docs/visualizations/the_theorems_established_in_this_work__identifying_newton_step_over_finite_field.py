def newton_step(coeffs, x, p):
    deriv = [(i*coeffs[i])%p for i in range(1,len(coeffs))]
    fx = sum(c*pow(x,i,p) for i,c in enumerate(coeffs)) % p
    fpx = sum(c*pow(x,i,p) for i,c in enumerate(deriv)) % p
    if fpx == 0: return x
    return (x - fx * pow(fpx, p-2, p)) % p