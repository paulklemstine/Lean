"""
Visualization: Persistence Barcodes from Prime-Indexed Arithmetic Data

Illustrates how topological persistence constructions applied to
Frobenius orbit data create distinctive barcodes for different curves.
"""

import numpy as np
import matplotlib.pyplot as plt


def is_prime(n):
    if n < 2: return False
    if n < 4: return True
    if n % 2 == 0 or n % 3 == 0: return False
    i = 5
    while i * i <= n:
        if n % i == 0 or n % (i + 2) == 0: return False
        i += 6
    return True


def count_points(a, b, p):
    count = 1
    for x in range(p):
        rhs = (x**3 + a * x + b) % p
        if rhs == 0:
            count += 1
        elif pow(rhs, (p - 1) // 2, p) == 1:
            count += 2
    return count


def compute_barcode(traces):
    """Build persistence barcode from trace sign changes."""
    intervals = []
    current_sign = None
    birth = 0
    for i, t in enumerate(traces):
        s = 1 if t > 0 else (-1 if t < 0 else 0)
        if current_sign is None:
            current_sign = s
            birth = i
        elif s != current_sign and s != 0:
            intervals.append((birth, i))
            current_sign = s
            birth = i
    intervals.append((birth, len(traces)))
    return intervals


def main():
    fig, axes = plt.subplots(2, 2, figsize=(14, 10))
    fig.suptitle('Persistence Barcodes from Prime-Indexed Arithmetic Data',
                 fontsize=14, fontweight='bold')

    curves = {
        r'$y^2=x^3-x$ (rat. pt.)': (-1, 0),
        r'$y^2=x^3+1$ (rat. pt.)': (0, 1),
        r'$y^2=x^3-x+1$': (-1, 1),
        r'$y^2=x^3+2x+3$': (2, 3),
    }

    primes = [p for p in range(7, 500) if is_prime(p)]
    colors = ['#2196F3', '#FF5722', '#4CAF50', '#9C27B0']

    all_traces = {}
    for name, (a, b) in curves.items():
        disc = -16 * (4 * a**3 + 27 * b**2)
        valid_p = [p for p in primes if disc % p != 0]
        traces = [p + 1 - count_points(a, b, p) for p in valid_p]
        all_traces[name] = traces

    # Plot 1-2: Barcodes for first two curves
    for idx, (name, traces) in enumerate(list(all_traces.items())[:2]):
        ax = axes[0, idx]
        intervals = compute_barcode(traces[:60])

        for i, (b, d) in enumerate(intervals):
            ax.barh(i, d - b, left=b, height=0.6, color=colors[idx], alpha=0.7,
                    edgecolor='black', linewidth=0.5)
        ax.set_xlabel('Prime index')
        ax.set_ylabel('Feature')
        ax.set_title(f'Barcode: {name}')
        ax.set_xlim(-1, 62)

    # Plot 3: Overlay barcodes comparison
    ax = axes[1, 0]
    y_offset = 0
    for idx, (name, traces) in enumerate(all_traces.items()):
        intervals = compute_barcode(traces[:60])
        for i, (b, d) in enumerate(intervals):
            ax.barh(y_offset + i, d - b, left=b, height=0.5,
                    color=colors[idx], alpha=0.6, label=name if i == 0 else None)
        y_offset += len(intervals) + 1

    ax.set_xlabel('Prime index')
    ax.set_title('All Barcodes Compared')
    ax.legend(fontsize=7, loc='upper right')

    # Plot 4: Persistence statistics
    ax = axes[1, 1]
    names_short = ['E1', 'E2', 'E3', 'E4']
    stats = []
    for name, traces in all_traces.items():
        intervals = compute_barcode(traces[:60])
        total = sum(d - b for b, d in intervals)
        longest = max(d - b for b, d in intervals)
        num = len(intervals)
        stats.append((num, total, longest))

    x = np.arange(len(names_short))
    width = 0.25
    ax.bar(x - width, [s[0] for s in stats], width, label='# intervals',
           color='steelblue', alpha=0.8)
    ax.bar(x, [s[1]/10 for s in stats], width, label='total pers./10',
           color='coral', alpha=0.8)
    ax.bar(x + width, [s[2] for s in stats], width, label='longest',
           color='forestgreen', alpha=0.8)
    ax.set_xticks(x)
    ax.set_xticklabels(names_short)
    ax.set_title('Persistence Statistics')
    ax.legend(fontsize=8)

    plt.tight_layout()
    plt.savefig('persistence_barcodes.png', dpi=150, bbox_inches='tight')
    print("Saved persistence_barcodes.png")


if __name__ == "__main__":
    main()
