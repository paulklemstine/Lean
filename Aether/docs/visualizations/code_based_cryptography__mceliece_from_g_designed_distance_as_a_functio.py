import matplotlib.pyplot as plt

n = 6960
ks = list(range(1, n))
dist = [n - k + 1 for k in ks]
tau = [(n - k) // 2 for k in ks]
rate = [k / n for k in ks]

fig, ax = plt.subplots(figsize=(8, 5))
ax.plot(rate, dist, label='minimum distance n-k+1', color='navy')
ax.plot(rate, tau, label='correction radius floor((n-k)/2)', color='green')
ax.set_xlabel('code rate k/n')
ax.set_ylabel('coordinates')
ax.set_title('GRS designed distance vs. rate (n=6960)')
ax.legend()
ax.grid(True, alpha=0.3)
plt.tight_layout()
plt.savefig('grs_distance_rate.png', dpi=150)
print('wrote grs_distance_rate.png')