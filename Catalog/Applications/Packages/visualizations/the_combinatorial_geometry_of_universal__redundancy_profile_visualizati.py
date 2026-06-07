import math
try:
    import matplotlib
    matplotlib.use('Agg')
    import matplotlib.pyplot as plt
except ImportError:
    print('matplotlib not available')
    exit(0)

def redundancy_number(A, L, r):
    return sum(math.comb(L, i) * (A - 1) ** i for i in range(min(r, L) + 1))

fig, axes = plt.subplots(1, 3, figsize=(15, 5))
configs = [(2, 16, 'Binary'), (4, 16, 'Quaternary'), (25, 16, 'Babel (25)')]
for ax, (A, L, title) in zip(axes, configs):
    radii = list(range(L + 1))
    lib = A ** L
    profile = [redundancy_number(A, L, r) / lib for r in radii]
    ax.plot(radii, profile, 'b-o', markersize=4, linewidth=2)
    ax.fill_between(radii, profile, alpha=0.2)
    ax.set_xlabel('Hamming Radius r')
    ax.set_ylabel('Fraction of Library')
    ax.set_title(f'{title} Library (A={A}, L={L})')
    ax.set_ylim(0, 1.05)
    ax.axhline(y=0.5, color='red', linestyle='--', alpha=0.5, label='50%')
    ax.legend()
    ax.grid(True, alpha=0.3)
plt.suptitle('Redundancy Profile: From Isolation to Universality', fontsize=14, fontweight='bold')
plt.tight_layout()
plt.savefig('redundancy_profile.png', dpi=150, bbox_inches='tight')
print('Saved redundancy_profile.png')