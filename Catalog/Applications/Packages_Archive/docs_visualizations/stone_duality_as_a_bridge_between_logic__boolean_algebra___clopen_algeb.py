import matplotlib.pyplot as plt
from itertools import combinations

def visualize_iso(n: int = 3) -> None:
    elems = list(range(1 << n))
    levels = {}
    for e in elems:
        levels.setdefault(bin(e).count('1'), []).append(e)
    fig, ax = plt.subplots(figsize=(7, 6))
    pos = {}
    for lvl, group in levels.items():
        for k, e in enumerate(sorted(group)):
            x = k - (len(group) - 1) / 2
            pos[e] = (x, lvl)
    for a in elems:
        for b in elems:
            if bin(b).count('1') == bin(a).count('1') + 1 and (a & b) == a:
                xa, ya = pos[a]; xb, yb = pos[b]
                ax.plot([xa, xb], [ya, yb], c='gray', lw=0.8, zorder=1)
    for e in elems:
        x, y = pos[e]
        subset = sorted(i for i in range(n) if (e >> i) & 1)
        ax.scatter([x], [y], s=600, c='gold', zorder=2)
        ax.annotate('{' + ','.join(map(str, subset)) + '}',
                    (x, y), ha='center', va='center', fontsize=8)
    ax.set_title('B (= 2^3)  ≅  Clopens(StoneSpace B)\n'
                 'each node = element = its clopen image D(b)')
    ax.axis('off'); plt.tight_layout(); plt.show()

if __name__ == '__main__':
    visualize_iso()
