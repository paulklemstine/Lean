"""Descending staircase: sigma5(n) and its golden-ratio plateaus."""
import cmath, math
import matplotlib.pyplot as plt

W5 = cmath.exp(2j * cmath.pi / 5)

def sigma5(n, tol=1e-9):
    best = None
    for a0 in range(n+1):
        for a1 in range(n+1-a0):
            for a2 in range(n+1-a0-a1):
                for a3 in range(n+1-a0-a1-a2):
                    a4 = n-a0-a1-a2-a3
                    m = abs(a0+a1*W5+a2*W5**2+a3*W5**3+a4*W5**4)
                    if m > tol and (best is None or m < best):
                        best = m
    return best

ns = list(range(1, 31))
vals = [sigma5(n) for n in ns]
phi = (1+math.sqrt(5))/2

plt.figure(figsize=(11, 6))
for r in range(5):
    xs = [n for n in ns if n % 5 == r]
    ys = [sigma5(n) for n in xs]
    plt.step(xs, ys, where='mid', marker='o', label=f'n = {r} (mod 5)')
for k in range(0, 5):
    plt.axhline(phi**-k, ls='--', lw=0.6, color='gray')
    plt.text(30.2, phi**-k, f'$\\varphi^{{-{k}}}$', va='center', fontsize=9)
plt.xlabel('n'); plt.ylabel(r'$\sigma_5(n)$')
plt.title('Minimal non-vanishing modulus of sums of $n$ fifth roots of unity')
plt.legend(); plt.grid(alpha=0.3); plt.tight_layout()
plt.savefig('sigma5_staircase.png', dpi=150)
print('wrote sigma5_staircase.png')
