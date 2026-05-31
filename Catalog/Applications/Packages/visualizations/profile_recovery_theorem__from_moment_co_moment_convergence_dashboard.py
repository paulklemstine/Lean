import math
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt

def catalan_number(n):
    return math.comb(2*n, n) // (n+1)

def wigner_moment(k):
    return float(catalan_number(k//2)) if k%2==0 else 0.0

def moment_distance(m1, m2, K):
    return sum(abs(m1(k)-m2(k))/math.factorial(k) for k in range(K))

fig, axes = plt.subplots(1, 3, figsize=(18, 5))
ks = list(range(16))
axes[0].semilogy(ks, [catalan_number(k) for k in ks], 'bo-', label='C_k')
axes[0].semilogy(ks, [4**k for k in ks], 'r^--', label='4^k')
axes[0].set_title('Catalan vs 4^k'); axes[0].legend(); axes[0].grid(True, alpha=0.3)
K=8; ns=list(range(1,201))
dists=[moment_distance(lambda k,n=n: wigner_moment(k)+math.sin(k*n)/(n+1), wigner_moment, K) for n in ns]
axes[1].plot(ns, dists, 'b-', alpha=0.7); axes[1].set_title('Moment Distance Convergence'); axes[1].grid(True, alpha=0.3)
partial=[]; s=0
for n in range(1,31):
    m2n=wigner_moment(2*n)
    if m2n>0: s+=m2n**(-1.0/(2*n))
    partial.append(s)
axes[2].plot(range(1,31), partial, 'b-o', ms=4); axes[2].set_title('Carleman Partial Sums'); axes[2].grid(True, alpha=0.3)
plt.tight_layout(); plt.savefig('profile_recovery_viz.png', dpi=150)
print('Saved profile_recovery_viz.png')