import matplotlib.pyplot as plt

primes = [2, 3, 5, 7, 11]
Kmax = 12
plt.figure(figsize=(11, 6))
for p in primes:
    ks = list(range(1, Kmax + 1))
    vals = []
    s = 1.0
    term = 1.0
    for k in ks:
        term /= p
        s += term
        vals.append(s)
    plt.plot(ks, vals, marker='o', label=f'A({p}^k), ceiling p/(p-1)={p/(p-1):.3f}')
plt.axhline(2.0, color='black', ls='--', lw=1, label='perfection (A=2)')
plt.xlabel('exponent k'); plt.ylabel('A(p^k)')
plt.title('Prime powers are strictly deficient: A(p^k) < p/(p-1) <= 2')
plt.legend(); plt.tight_layout(); plt.savefig('primepow_deficiency.png', dpi=150)
print('saved primepow_deficiency.png')