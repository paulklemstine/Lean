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

N = 300
xs = list(range(1, N + 1))
tn = [totient(n) for n in xs]
tn1 = [totient(n + 1) for n in xs]
coll = [n for n in xs if totient(n) == totient(n + 1)]
plt.figure(figsize=(12, 6))
plt.plot(xs, tn, lw=0.8, label='phi(n)')
plt.plot(xs, tn1, lw=0.8, alpha=0.6, label='phi(n+1)')
plt.scatter(coll, [totient(n) for n in coll], color='red', zorder=5,
            label='collisions phi(n)=phi(n+1)')
plt.xlabel('n'); plt.ylabel('totient value')
plt.title('Unit-shift totient collisions up to %d' % N)
plt.legend(); plt.tight_layout(); plt.savefig('collisions.png', dpi=150)
print('saved collisions.png; collisions:', coll)
