import math
try:
    import matplotlib
    matplotlib.use('Agg')
    import matplotlib.pyplot as plt
except ImportError:
    print('matplotlib not available')
    exit()
ns = list(range(1, 31))
b = 2
search = [max(0, (n - n//2 - 1)) for n in ns]
verif = [math.log2(n) if n > 0 else 0 for n in ns]
fig, ax = plt.subplots(figsize=(10, 6))
ax.plot(ns, search, 'r-o', linewidth=2, label='Search cost (log2)')
ax.plot(ns, verif, 'b-s', linewidth=2, label='Verification cost (log2)')
ax.fill_between(ns, verif, search, alpha=0.2, color='red')
ax.set_xlabel('Proof length n')
ax.set_ylabel('Cost (log2 scale)')
ax.set_title('The Exponential Search-Verification Gap')
ax.legend()
ax.grid(True, alpha=0.3)
plt.savefig('search_gap.png', dpi=150)
print('Saved search_gap.png')