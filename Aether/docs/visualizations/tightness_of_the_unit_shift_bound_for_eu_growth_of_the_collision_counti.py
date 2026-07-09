import matplotlib.pyplot as plt

def prime_factorization(n):
    f, d, m = {}, 2, n
    while d * d <= m:
        while m % d == 0:
            f[d] = f.get(d, 0) + 1; m //= d
        d += 1 if d == 2 else 2
    if m > 1: f[m] = f.get(m, 0) + 1
    return f

def totient(n):
    if n == 1: return 1
    r = 1
    for p, e in prime_factorization(n).items():
        r *= p ** (e - 1) * (p - 1)
    return r

X = 1000
xs, ys, c = list(range(1, X + 1)), [], 0
for n in xs:
    if totient(n) == totient(n + 1): c += 1
    ys.append(c)
plt.figure(figsize=(12, 6))
plt.step(xs, ys, where='post')
plt.axvline(194, ls='--', color='gray'); plt.axvline(975, ls='--', color='gray')
plt.title('S1phi(x): collision count up to x')
plt.xlabel('x'); plt.ylabel('S1phi(x)')
plt.tight_layout(); plt.savefig('S1phi.png', dpi=150)
print('S1phi(194)=', ys[193], ' S1phi(975)=', ys[974])
