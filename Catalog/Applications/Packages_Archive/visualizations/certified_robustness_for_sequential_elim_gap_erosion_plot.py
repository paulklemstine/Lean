import math, random
try:
    import matplotlib.pyplot as plt
    HAS_MPL = True
except ImportError:
    HAS_MPL = False

def round_loser(s): return min(s, key=lambda k: (s[k], k))
def min_gap(s):
    a, g = dict(s), math.inf
    while len(a) > 1:
        lo = round_loser(a)
        g = min(g, min(v for k,v in a.items() if k!=lo) - a[lo])
        del a[lo]
    return g

scores = {0: 1.0, 1: 3.5, 2: 2.0, 3: 5.0, 4: 4.2}
gamma = min_gap(scores)
epsilons = [i * 0.02 for i in range(25)]
theoretical = [gamma - 2*e for e in epsilons]

rng = random.Random(42)
empirical = []
for e in epsilons:
    gaps = []
    for _ in range(500):
        p = {k: v + rng.uniform(-e, e) for k, v in scores.items()}
        gaps.append(min_gap(p))
    empirical.append(min(gaps))

if HAS_MPL:
    fig, ax = plt.subplots(figsize=(8, 5))
    ax.plot(epsilons, theoretical, 'b-', lw=2, label='Theoretical bound (γ − 2ε)')
    ax.plot(epsilons, empirical, 'ro', ms=4, label='Empirical minimum gap')
    ax.axhline(0, color='gray', ls='--', lw=0.5)
    ax.axvline(gamma/2, color='red', ls=':', lw=1, label=f'Critical ε = γ/2 = {gamma/2:.2f}')
    ax.set_xlabel('Perturbation ε')
    ax.set_ylabel('Minimum gap')
    ax.set_title('Gap Erosion Under Perturbation')
    ax.legend()
    plt.tight_layout()
    plt.savefig('gap_erosion.png', dpi=150)
    print('Saved gap_erosion.png')
else:
    print('matplotlib not available; printing data')
    for e, t, emp in zip(epsilons, theoretical, empirical):
        print(f'ε={e:.2f}  bound={t:.3f}  empirical={emp:.3f}')
