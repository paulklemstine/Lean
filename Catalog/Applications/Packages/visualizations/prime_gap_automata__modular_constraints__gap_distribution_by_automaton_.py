import matplotlib.pyplot as plt
import numpy as np

def is_prime(n):
    if n < 2: return False
    if n < 4: return True
    if n % 2 == 0 or n % 3 == 0: return False
    i = 5
    while i*i <= n:
        if n%i == 0 or n%(i+2) == 0: return False
        i += 6
    return True

def next_prime(n):
    c = n + 1
    if c <= 2: return 2
    if c % 2 == 0: c += 1
    while not is_prime(c): c += 2
    return c

p = 5
g0, g1 = [], []
while p < 50000:
    q = next_prime(p)
    gap = q - p
    if p % 6 == 1: g0.append(gap)
    else: g1.append(gap)
    p = q

fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6), sharey=True)
bins = np.arange(0, 42, 2)
ax1.hist(g0, bins=bins, color='steelblue', edgecolor='black', alpha=0.8)
ax1.set_title('State 0: p ≡ 1 (mod 6)')
ax1.set_xlabel('Gap size')
ax1.set_ylabel('Frequency')
ax2.hist(g1, bins=bins, color='coral', edgecolor='black', alpha=0.8)
ax2.set_title('State 1: p ≡ 5 (mod 6)')
ax2.set_xlabel('Gap size')
fig.suptitle('Prime Gap Distribution by Automaton State', fontsize=16)
plt.tight_layout()
plt.savefig('gap_dist.png', dpi=150)
plt.close()