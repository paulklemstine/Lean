import matplotlib.pyplot as plt
from math import comb, log2

def isd(n, k, t):
    return log2(comb(n, t)) - log2(comb(n - k, t))

def pk_mb(n, k):
    return ((k * (n - k) + 7) // 8) / 1e6

sets = [('Cat1', 3488, 2720, 64), ('Cat3', 4608, 3360, 96),
        ('Cat5', 6960, 5413, 119), ('Cat5+', 8192, 6528, 128)]
labels = [s[0] for s in sets]
work = [isd(n, k, t) for _, n, k, t in sets]
size = [pk_mb(n, k) for _, n, k, t in sets]

fig, ax1 = plt.subplots(figsize=(8, 5))
ax1.bar(labels, work, color='steelblue', alpha=0.7)
ax1.axhline(256, color='crimson', linestyle='--', label='256-bit target')
ax1.set_ylabel('ISD work factor (log2)')
ax2 = ax1.twinx()
ax2.plot(labels, size, 'o-', color='darkorange', label='public key (MB)')
ax2.set_ylabel('public key size (MB)')
ax1.set_title('McEliece: security vs. key size')
ax1.legend(loc='upper left')
ax2.legend(loc='lower right')
plt.tight_layout()
plt.savefig('mceliece_tradeoff.png', dpi=150)
print('wrote mceliece_tradeoff.png')