#!/usr/bin/env python3
"""
Dark Mathematics: Applications

Real-world applications of fast-growing hierarchies and
witness complexity theory.
"""

import sys
sys.setrecursionlimit(10000)


# ============================================================
# Application 1: Termination Bounds for Recursive Programs
# ============================================================

def analyze_termination_bound(program_name: str, recursive_depth: int) -> dict:
    """Classify the termination complexity of a recursive program.

    Programs whose termination proofs require transfinite induction
    correspond to higher darkness levels. This connects the abstract
    hierarchy to software verification.

    Args:
        program_name: Description of the program
        recursive_depth: Nesting depth of recursion

    Returns:
        Analysis dictionary with darkness level and bound

    Example:
        >>> result = analyze_termination_bound("simple loop", 1)
        >>> result['darkness_level']
        0
    """
    # Map recursion patterns to darkness levels
    if recursive_depth <= 1:
        level = 0
        bound_desc = "Linear: O(n)"
    elif recursive_depth == 2:
        level = 1
        bound_desc = "Quadratic-like: O(n²)"
    elif recursive_depth == 3:
        level = 2
        bound_desc = "Polynomial: O(n^k)"
    else:
        level = min(recursive_depth, 5)
        bound_desc = f"Super-polynomial: Level {level} in fast-growing hierarchy"

    return {
        'program': program_name,
        'recursive_depth': recursive_depth,
        'darkness_level': level,
        'bound_description': bound_desc,
        'implication': (
            f"Termination proof requires induction up to ω^{level}" if level <= 3
            else f"Termination proof requires ordinals beyond ω^ω"
        )
    }


# ============================================================
# Application 2: Ramsey Theory Witness Bounds
# ============================================================

def ramsey_lower_bound(k: int) -> int:
    """Compute the exponential lower bound for R(k,k).

    The diagonal Ramsey number R(k,k) satisfies R(k,k) ≥ 2^(k/2).
    This places Ramsey witnesses at darkness level ≥ 1, since
    exponential growth exceeds all polynomials.

    Args:
        k: Ramsey parameter

    Returns:
        Lower bound 2^(k//2)

    Example:
        >>> ramsey_lower_bound(6)
        8
        >>> ramsey_lower_bound(10)
        32
    """
    return 2 ** (k // 2)


def ramsey_darkness_analysis():
    """Analyze the darkness level of Ramsey number witnesses."""
    print("Ramsey Number Lower Bounds and Darkness Levels")
    print("=" * 50)
    print()
    print(f"{'k':>4} {'2^(k/2)':>10} {'k^2':>10} {'k^3':>10} {'Darkness':>10}")
    print("-" * 50)

    for k in range(3, 21):
        lb = ramsey_lower_bound(k)
        k2 = k ** 2
        k3 = k ** 3
        if lb > k3:
            darkness = "≥ 3"
        elif lb > k2:
            darkness = "≥ 2"
        elif lb > k:
            darkness = "≥ 1"
        else:
            darkness = "0"
        print(f"{k:>4} {lb:>10} {k2:>10} {k3:>10} {darkness:>10}")


# ============================================================
# Application 3: Information-Theoretic Bounds
# ============================================================

def kolmogorov_darkness(n: int) -> str:
    """Classify a number's "information darkness".

    Numbers whose Kolmogorov complexity exceeds log(n) are
    "informationally dark" — they cannot be compressed.
    This connects information theory to the darkness hierarchy:
    the proportion of dark numbers approaches 1 as n grows.

    Args:
        n: Number to classify

    Returns:
        Classification string
    """
    import math
    if n <= 1:
        return "trivial"

    log_n = math.log2(n)
    # Simple heuristic: check if n has a short description
    # Numbers with patterns are "light", random numbers are "dark"

    # Check if n is a power of 2
    if n & (n - 1) == 0:
        return f"light (power of 2, complexity ≈ {math.log2(log_n):.1f} bits)"

    # Check if n is a factorial
    fact = 1
    for i in range(1, 20):
        fact *= i
        if fact == n:
            return f"light (factorial {i}!, complexity ≈ {math.log2(i):.1f} bits)"

    # Check if n is a Fibonacci number
    a, b = 0, 1
    idx = 0
    while b < n:
        a, b = b, a + b
        idx += 1
    if b == n:
        return f"light (Fibonacci F_{idx}, complexity ≈ {math.log2(idx):.1f} bits)"

    # Default: assume high complexity
    return f"dark (complexity ≈ {log_n:.1f} bits)"


# ============================================================
# Application 4: Busy Beaver Connection
# ============================================================

def busy_beaver_darkness():
    """Show the connection between Busy Beaver and darkness levels.

    The Busy Beaver function BB(n) grows faster than any
    computable function, placing it at "infinite darkness level".
    Known values:
        BB(1) = 1
        BB(2) = 6
        BB(3) = 21
        BB(4) = 107
        BB(5) ≥ 47,176,870
    """
    print()
    print("Busy Beaver and the Darkness Hierarchy")
    print("=" * 50)
    print()

    known_bb = {1: 1, 2: 6, 3: 21, 4: 107}
    bb5_lower = 47_176_870

    print("Known Busy Beaver values:")
    for n, bb in known_bb.items():
        # Compare with fast-growing hierarchy
        fg_vals = [(k, fast_grow_closed(k, n)) for k in range(5)]
        level = "∞"
        for k, fg in fg_vals:
            if fg >= bb:
                level = f"≤ {k}"
                break
        print(f"  BB({n}) = {bb:>12} (darkness level {level})")

    print(f"  BB(5) ≥ {bb5_lower:>12} (darkness level: beyond all finite levels)")
    print()
    print("The Busy Beaver function is the 'ultimate dark function':")
    print("it grows faster than any level in the fast-growing hierarchy,")
    print("and is not computable — the darkest possible mathematical object.")


def fast_grow_closed(k: int, n: int) -> int:
    """Closed-form fast-growing hierarchy."""
    if k == 0:
        return n + 1
    elif k == 1:
        return n + 2
    elif k == 2:
        return 2 * n + 3
    elif k == 3:
        return 2 ** (n + 3) - 3
    else:
        if n == 0:
            return fast_grow_closed(k - 1, 1)
        else:
            return fast_grow_closed(k - 1, fast_grow_closed(k, n - 1))


if __name__ == "__main__":
    # Application 1: Termination bounds
    print("APPLICATION 1: Termination Bounds for Recursive Programs")
    print("=" * 60)
    programs = [
        ("Simple loop (for i in range(n))", 1),
        ("Nested loops (bubble sort)", 2),
        ("Divide-and-conquer (mergesort)", 2),
        ("Ackermann-style recursion", 4),
        ("Hydra game", 5),
    ]
    for name, depth in programs:
        result = analyze_termination_bound(name, depth)
        print(f"  {result['program']}")
        print(f"    Darkness level: {result['darkness_level']}")
        print(f"    Bound: {result['bound_description']}")
        print(f"    {result['implication']}")
        print()

    # Application 2: Ramsey theory
    print()
    ramsey_darkness_analysis()

    # Application 3: Information darkness
    print()
    print("APPLICATION 3: Information-Theoretic Darkness")
    print("=" * 60)
    test_numbers = [2, 8, 42, 64, 120, 144, 233, 997, 1024, 3571]
    for n in test_numbers:
        classification = kolmogorov_darkness(n)
        print(f"  {n:>6}: {classification}")

    # Application 4: Busy Beaver
    busy_beaver_darkness()


#!/usr/bin/env python3
"""
Dark Mathematics: Demonstrations of the Fast-Growing Hierarchy
and Darkness Levels

This demo illustrates the core mathematical concepts from the
Dark Mathematics formalization:
1. The fast-growing (Ackermann/Wainer) hierarchy
2. Darkness level dominance
3. The diagonal function's super-hierarchy growth
"""


def fast_grow(k: int, n: int) -> int:
    """Compute the fast-growing hierarchy function.

    Level 0: successor function (n + 1)
    Level k+1: iterate level k starting from fastGrow k 1

    This is equivalent to the Ackermann function.

    >>> fast_grow(0, 5)
    6
    >>> fast_grow(1, 5)
    7
    >>> fast_grow(2, 5)
    13
    """
    if k == 0:
        return n + 1
    elif n == 0:
        return fast_grow(k - 1, 1)
    else:
        return fast_grow(k - 1, fast_grow(k, n - 1))


def tower2(n: int) -> int:
    """Tower of 2s of height n: 2↑↑n.

    >>> tower2(0)
    1
    >>> tower2(1)
    2
    >>> tower2(2)
    4
    >>> tower2(3)
    16
    """
    if n == 0:
        return 1
    return 2 ** tower2(n - 1)


def demonstrate_hierarchy():
    """Show the growth rates at different levels."""
    print("=" * 60)
    print("THE FAST-GROWING HIERARCHY")
    print("=" * 60)
    print()

    # Level 0: successor
    print("Level 0 (successor): f₀(n) = n + 1")
    for n in range(8):
        print(f"  f₀({n}) = {fast_grow(0, n)}")

    print()

    # Level 1: +2
    print("Level 1: f₁(n) = n + 2")
    for n in range(8):
        print(f"  f₁({n}) = {fast_grow(1, n)}")

    print()

    # Level 2: 2n + 3
    print("Level 2: f₂(n) = 2n + 3")
    for n in range(8):
        val = fast_grow(2, n)
        formula = 2 * n + 3
        assert val == formula, f"Mismatch at n={n}: {val} != {formula}"
        print(f"  f₂({n}) = {val}")

    print()

    # Level 3: 2^(n+3) - 3
    print("Level 3: f₃(n) = 2^(n+3) - 3  [EXPONENTIAL]")
    for n in range(8):
        val = fast_grow(3, n)
        formula = 2 ** (n + 3) - 3
        assert val == formula, f"Mismatch at n={n}: {val} != {formula}"
        print(f"  f₃({n}) = {val}")

    print()

    # Level 4 (only small values - grows extremely fast)
    print("Level 4: [SUPER-EXPONENTIAL - grows too fast to display]")
    for n in range(5):
        val = fast_grow(4, n)
        print(f"  f₄({n}) = {val}")


def demonstrate_dominance():
    """Show how each level eventually dominates the previous."""
    print()
    print("=" * 60)
    print("DARKNESS HIERARCHY: STRICT DOMINANCE")
    print("=" * 60)
    print()
    print("Theorem: For each k, fastGrow(k+1) eventually dominates fastGrow(k)")
    print()

    for k in range(4):
        print(f"Level {k} vs Level {k+1}:")
        for n in range(6):
            fk = fast_grow(k, n)
            fk1 = fast_grow(k + 1, n)
            ratio = fk1 / fk if fk > 0 else float('inf')
            dominant = "✓" if fk1 > fk else "✗"
            print(f"  n={n}: f_{k}(n)={fk:>8}, f_{k+1}(n)={fk1:>8},"
                  f" ratio={ratio:.2f} {dominant}")
        print()


def demonstrate_diagonal():
    """Show the diagonal function n ↦ fastGrow(n, n) dominates all levels."""
    print("=" * 60)
    print("THE DIAGONAL: ABSOLUTE DARKNESS")
    print("=" * 60)
    print()
    print("Theorem: n ↦ f_n(n) eventually dominates every fixed level k")
    print()
    print("The diagonal function:")
    for n in range(5):
        val = fast_grow(n, n)
        print(f"  f_{n}({n}) = {val}")
    print()

    print("Comparison with fixed levels:")
    for k in range(4):
        print(f"  Level {k}: ", end="")
        for n in range(5):
            fk = fast_grow(k, n)
            diag = fast_grow(n, n)
            symbol = "≤" if fk <= diag else ">"
            print(f"f_{k}({n})={fk} {symbol} f_{n}({n})={diag}  ", end="")
        print()


def demonstrate_polynomial_dominance():
    """Show that the Ackermann function dominates all polynomials."""
    print()
    print("=" * 60)
    print("ACKERMANN vs POLYNOMIALS: TRANSCENDENCE")
    print("=" * 60)
    print()
    print("Theorem: For each d, ackermann(d+2, n) > n^(d+1) for large n")
    print()

    for d in range(4):
        print(f"d={d}: ackermann({d+2}, n) vs n^{d+1}")
        for n in range(1, 8):
            ack = fast_grow(d + 2, n)
            poly = n ** (d + 1)
            dominant = "✓" if ack > poly else "✗"
            print(f"  n={n}: ack({d+2},{n})={ack:>10},"
                  f" n^{d+1}={poly:>10} {dominant}")
        print()


def demonstrate_darkness_density():
    """Show the darkness density conjecture."""
    print("=" * 60)
    print("DARKNESS DENSITY CONJECTURE")
    print("=" * 60)
    print()
    print("Conjecture: For k ≥ 2, f_{k+1}(n) > 2·f_k(n) for large enough n")
    print()

    # k=0: fails (proven in Lean)
    print("k=0 (DISPROVED):")
    for n in range(5):
        f1 = fast_grow(1, n)
        f0 = fast_grow(0, n)
        check = "✓" if f1 > 2 * f0 else "✗"
        print(f"  n={n}: f₁({n})={f1}, 2·f₀({n})={2*f0} {check}")
    print("  → Always fails since (n+2) < 2(n+1)")

    print()

    # k=2: succeeds (proven in Lean)
    print("k=2 (PROVED for n ≥ 2):")
    for n in range(5):
        f3 = fast_grow(3, n)
        f2 = fast_grow(2, n)
        check = "✓" if f3 > 2 * f2 else "✗"
        print(f"  n={n}: f₃({n})={f3}, 2·f₂({n})={2*f2} {check}")


if __name__ == "__main__":
    demonstrate_hierarchy()
    demonstrate_dominance()
    demonstrate_diagonal()
    demonstrate_polynomial_dominance()
    demonstrate_darkness_density()

    print()
    print("=" * 60)
    print("All demonstrations complete.")
    print("=" * 60)


#!/usr/bin/env python3
"""
Visualization 3: The Diagonal — Absolute Darkness

Visualizes the diagonal function n ↦ f_n(n), which grows faster
than any fixed level in the hierarchy. This represents "absolute
darkness" — the mathematical analogue of a singularity where
witness complexity escapes all finite classification.
"""
import numpy as np
import matplotlib.pyplot as plt


def fast_grow_closed(k, n):
    """Closed-form fast-growing hierarchy."""
    if k == 0:
        return n + 1
    elif k == 1:
        return n + 2
    elif k == 2:
        return 2 * n + 3
    elif k == 3:
        return 2 ** (n + 3) - 3
    return None


def fast_grow_recursive(k, n, depth=0, max_depth=100):
    """Recursive computation with depth limit."""
    if depth > max_depth:
        return float('inf')
    if k == 0:
        return n + 1
    elif n == 0:
        return fast_grow_recursive(k - 1, 1, depth + 1, max_depth)
    else:
        inner = fast_grow_recursive(k, n - 1, depth + 1, max_depth)
        if inner == float('inf'):
            return float('inf')
        return fast_grow_recursive(k - 1, inner, depth + 1, max_depth)


fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))

# Panel 1: Diagonal vs fixed levels
n_vals = np.arange(0, 5)
colors = ['#90CAF9', '#81C784', '#FFB74D', '#EF5350', '#CE93D8', '#000000']

# Plot fixed levels
for k in range(4):
    vals = []
    for n in n_vals:
        v = fast_grow_closed(k, int(n))
        vals.append(v if v is not None else float('nan'))
    ax1.semilogy(n_vals, vals, 'o--', color=colors[k], linewidth=1.5,
                 markersize=8, alpha=0.6, label=f'Level {k}: $f_{k}(n)$')

# Plot diagonal
diag_vals = []
for n in n_vals:
    v = fast_grow_closed(int(n), int(n))
    if v is None:
        v = fast_grow_recursive(int(n), int(n))
    diag_vals.append(v)

ax1.semilogy(n_vals, diag_vals, 's-', color='black', linewidth=3,
             markersize=10, label=r'Diagonal: $f_n(n)$', zorder=5)

ax1.set_xlabel('n', fontsize=12)
ax1.set_ylabel('Value (log scale)', fontsize=12)
ax1.set_title('The Diagonal Escapes Every Level', fontsize=13)
ax1.legend(fontsize=9)
ax1.grid(True, alpha=0.3)

# Add annotation
ax1.annotate('f₃(3) = 61',
             xy=(3, 61), xytext=(3.3, 15),
             fontsize=9,
             arrowprops=dict(arrowstyle='->', color='red'))
ax1.annotate('Diagonal: f₃(3) = 61\n(same point!)',
             xy=(3, 61), xytext=(1.5, 500),
             fontsize=9, color='black',
             arrowprops=dict(arrowstyle='->', color='black'))

# Panel 2: Growth rate comparison (heatmap style)
ax2_data = np.zeros((5, 8))
labels_grid = [['' for _ in range(8)] for _ in range(5)]

for k in range(5):
    for n in range(8):
        v = fast_grow_closed(k, n)
        if v is None:
            try:
                v = fast_grow_recursive(k, n, max_depth=50)
            except RecursionError:
                v = float('inf')
        if v == float('inf') or v > 1e15:
            ax2_data[k][n] = 15
            labels_grid[k][n] = '∞'
        else:
            ax2_data[k][n] = np.log10(max(v, 1))
            if v < 10000:
                labels_grid[k][n] = str(int(v))
            else:
                labels_grid[k][n] = f'{v:.0e}'

im = ax2.imshow(ax2_data, cmap='YlOrRd', aspect='auto',
                interpolation='nearest')

# Add value labels
for k in range(5):
    for n in range(8):
        text_color = 'white' if ax2_data[k][n] > 8 else 'black'
        ax2.text(n, k, labels_grid[k][n], ha='center', va='center',
                 fontsize=7, color=text_color, fontweight='bold')

# Highlight diagonal
for i in range(min(5, 8)):
    ax2.add_patch(plt.Rectangle((i - 0.5, i - 0.5), 1, 1,
                                fill=False, edgecolor='blue',
                                linewidth=3))

ax2.set_xlabel('n (input)', fontsize=12)
ax2.set_ylabel('k (level)', fontsize=12)
ax2.set_title('Fast-Growing Hierarchy Values\n(Blue boxes = diagonal)',
              fontsize=13)
ax2.set_xticks(range(8))
ax2.set_yticks(range(5))
ax2.set_yticklabels([f'Level {k}' for k in range(5)])

cbar = plt.colorbar(im, ax=ax2, label='log₁₀(value)')

plt.suptitle('Absolute Darkness: The Diagonal Function Escapes All Finite Levels',
             fontsize=14, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('viz_diagonal.png', dpi=150, bbox_inches='tight')
print("Saved viz_diagonal.png")


#!/usr/bin/env python3
"""
Visualization 2: Darkness Dominance Ratios

Visualizes the ratio f_{k+1}(n) / f_k(n) for successive levels,
showing how the dominance gap widens. This illustrates the strict
hierarchy theorem: each darkness level is qualitatively harder
than the previous one.
"""
import numpy as np
import matplotlib.pyplot as plt


def fast_grow_closed(k, n):
    """Closed-form fast-growing hierarchy."""
    if k == 0:
        return n + 1
    elif k == 1:
        return n + 2
    elif k == 2:
        return 2 * n + 3
    elif k == 3:
        return 2 ** (n + 3) - 3
    return None


fig, axes = plt.subplots(1, 3, figsize=(15, 5))
colors = ['#2196F3', '#4CAF50', '#FF9800']
titles = [
    r'$f_1(n) / f_0(n)$: Level 0→1',
    r'$f_2(n) / f_1(n)$: Level 1→2',
    r'$f_3(n) / f_2(n)$: Level 2→3',
]

for idx, k in enumerate(range(3)):
    ax = axes[idx]
    n_max = 12 if k < 2 else 10
    n_vals = np.arange(0, n_max)

    ratios = []
    for n in n_vals:
        fk = fast_grow_closed(k, int(n))
        fk1 = fast_grow_closed(k + 1, int(n))
        ratios.append(fk1 / fk if fk > 0 else 0)

    bars = ax.bar(n_vals, ratios, color=colors[idx], alpha=0.7, edgecolor='white')

    # Color bars differently when ratio > 2 (density conjecture)
    for i, (bar, ratio) in enumerate(zip(bars, ratios)):
        if ratio > 2:
            bar.set_facecolor('#F44336')
            bar.set_alpha(0.8)

    ax.axhline(y=2, color='red', linestyle='--', alpha=0.5,
               label='Density threshold (ratio = 2)')
    ax.axhline(y=1, color='gray', linestyle='-', alpha=0.3)

    ax.set_xlabel('n', fontsize=11)
    ax.set_ylabel('Ratio', fontsize=11)
    ax.set_title(titles[idx], fontsize=12)
    ax.legend(fontsize=8)
    ax.grid(True, alpha=0.2, axis='y')

    if k == 2:
        ax.set_yscale('log')
        ax.set_ylabel('Ratio (log scale)', fontsize=11)

# Add explanatory text
fig.text(0.5, -0.05,
         'Red bars: ratio exceeds 2 (darkness density threshold).\n'
         'The exponential jump at Level 2→3 shows why level 3 darkness '
         'is qualitatively different.',
         ha='center', fontsize=10, style='italic',
         bbox=dict(boxstyle='round', facecolor='lightyellow', alpha=0.8))

plt.suptitle('Darkness Dominance: How Fast Does Each Level Outgrow the Previous?',
             fontsize=14, fontweight='bold')
plt.tight_layout()
plt.savefig('viz_dominance.png', dpi=150, bbox_inches='tight')
print("Saved viz_dominance.png")


#!/usr/bin/env python3
"""
Visualization 1: The Fast-Growing Hierarchy

Visualizes the growth rates of different levels of the fast-growing
hierarchy, showing how each level eventually dominates the previous one.
This is the core visual representation of the "darkness hierarchy" —
each level represents a deeper layer of mathematical unknowability.
"""
import numpy as np
import matplotlib.pyplot as plt


def fast_grow_closed(k, n):
    """Closed-form fast-growing hierarchy."""
    if k == 0:
        return n + 1
    elif k == 1:
        return n + 2
    elif k == 2:
        return 2 * n + 3
    elif k == 3:
        return 2 ** (n + 3) - 3
    return None


# Create figure with two panels
fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))

# Panel 1: Linear scale (levels 0-2)
n_vals = np.arange(0, 15)
colors = ['#2196F3', '#4CAF50', '#FF9800', '#F44336', '#9C27B0']
labels = [
    r'Level 0: $f_0(n) = n+1$ (successor)',
    r'Level 1: $f_1(n) = n+2$ (addition)',
    r'Level 2: $f_2(n) = 2n+3$ (multiplication)',
]

for k in range(3):
    vals = [fast_grow_closed(k, int(n)) for n in n_vals]
    ax1.plot(n_vals, vals, 'o-', color=colors[k], linewidth=2,
             markersize=6, label=labels[k])

ax1.set_xlabel('n', fontsize=12)
ax1.set_ylabel('f_k(n)', fontsize=12)
ax1.set_title('Fast-Growing Hierarchy (Linear Scale)', fontsize=14)
ax1.legend(fontsize=9, loc='upper left')
ax1.grid(True, alpha=0.3)
ax1.set_xlim(-0.5, 14.5)

# Panel 2: Log scale (levels 0-3)
n_vals2 = np.arange(0, 12)
labels2 = labels + [r'Level 3: $f_3(n) = 2^{n+3}-3$ (exponential)']

for k in range(4):
    vals = [fast_grow_closed(k, int(n)) for n in n_vals2]
    ax2.semilogy(n_vals2, vals, 'o-', color=colors[k], linewidth=2,
                 markersize=6, label=labels2[k])

# Add reference lines
poly_vals = [int(n)**3 + 1 for n in n_vals2]
ax2.semilogy(n_vals2, poly_vals, '--', color='gray', linewidth=1.5,
             alpha=0.7, label=r'Reference: $n^3+1$')

ax2.set_xlabel('n', fontsize=12)
ax2.set_ylabel('f_k(n) [log scale]', fontsize=12)
ax2.set_title('Fast-Growing Hierarchy (Log Scale)', fontsize=14)
ax2.legend(fontsize=9, loc='upper left')
ax2.grid(True, alpha=0.3)
ax2.set_xlim(-0.5, 11.5)

# Add annotation about darkness levels
ax2.annotate('Each level is a\n"layer of darkness"',
             xy=(8, fast_grow_closed(3, 8)),
             xytext=(5, 10),
             fontsize=10,
             arrowprops=dict(arrowstyle='->', color='red'),
             bbox=dict(boxstyle='round,pad=0.3', facecolor='lightyellow'))

plt.suptitle('The Darkness Hierarchy: Layers of Mathematical Unknowability',
             fontsize=15, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('viz_hierarchy.png', dpi=150, bbox_inches='tight')
print("Saved viz_hierarchy.png")
