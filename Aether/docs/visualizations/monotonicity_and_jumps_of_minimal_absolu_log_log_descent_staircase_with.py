"""Log-log descent staircase of sigma5 with jump positions marked."""
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

def fib(n):
    a,b=0,1
    for _ in range(n): a,b=b,a+b
    return a
def lucas(n):
    a,b=2,1
    for _ in range(n): a,b=b,a+b
    return a

ns = list(range(1, 41))
vals = [sigma5(n) for n in ns]
fam = set()
for m in range(1, 12):
    fam |= {5*fib(m), lucas(m), 2*lucas(m)}

plt.figure(figsize=(11, 6))
plt.loglog(ns, vals, '-', color='slategray', alpha=0.5)
plt.loglog(ns, vals, 'o', color='slategray', ms=4)
jx = [n for n in ns if n in fam]
jy = [sigma5(n) for n in jx]
plt.loglog(jx, jy, 's', color='crimson', ms=8, label='jump positions $5F_m,L_m,2L_m$')
plt.xlabel('n (log)'); plt.ylabel(r'$\sigma_5(n)$ (log)')
plt.title('Self-similar descent staircase of $\\sigma_5$')
plt.legend(); plt.grid(alpha=0.3, which='both'); plt.tight_layout()
plt.savefig('sigma5_loglog.png', dpi=150)
print('wrote sigma5_loglog.png')
