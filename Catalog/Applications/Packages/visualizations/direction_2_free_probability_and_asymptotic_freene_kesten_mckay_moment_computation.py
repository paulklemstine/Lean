from math import comb

def catalan(n):
    return comb(2*n, n) // (n+1)

def kesten_mckay_moment(d, k):
    if k == 0: return 1.0
    return float(catalan(k) * d * (d-1)**(k-1))

# Example: d=4
for k in range(6):
    print(f"mu_{{2*{k}}} = {kesten_mckay_moment(4, k)}")