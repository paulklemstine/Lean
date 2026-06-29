#!/usr/bin/env python3
"""
Horseshoe Dynamics and Computational Universality — Demonstration

Demonstrates the key results:
1. Orbit realization in symbolic shift spaces
2. Boolean function encoding via shift orbits
3. Entropy computation for full shifts
4. Sub-horseshoe extraction
5. Parity function encoding
"""

import math
from typing import Callable


def symbolic_shift(sequence: list[int], steps: int = 1) -> list[int]:
    """Apply the shift map σ to a sequence (left shift by `steps`)."""
    return sequence[steps:] + [0] * steps


def realize_word(word: list[int], d: int, total_len: int = 20) -> list[int]:
    """
    Orbit Realization: construct a bi-infinite sequence realizing a given word.
    Pads with 0 outside the word range.
    """
    n = len(word)
    sequence = []
    for i in range(total_len):
        if 0 <= i < n:
            sequence.append(word[i])
        else:
            sequence.append(0)
    return sequence


def encode_boolean_function(
    f: Callable[[tuple[bool, ...]], bool],
    n: int,
    input_vec: tuple[bool, ...]
) -> list[int]:
    """
    Boolean Encoding: encode input-output pair as a symbolic orbit.
    Position i (0 ≤ i < n) encodes input bit i.
    Position n encodes f(input).
    """
    orbit = []
    for i in range(n):
        orbit.append(1 if input_vec[i] else 0)
    orbit.append(1 if f(input_vec) else 0)
    # Pad remaining positions
    orbit.extend([0] * 10)
    return orbit


def parity(bits: tuple[bool, ...]) -> bool:
    """Parity function: True if even number of True bits."""
    return sum(1 for b in bits if b) % 2 == 0


def word_count(d: int, n: int) -> int:
    """Number of distinct words of length n over d symbols."""
    return d ** n


def entropy_rate(d: int, n: int) -> float:
    """Topological entropy rate: log(d^n) / n = log(d)."""
    if n == 0:
        return 0.0
    return math.log(d ** n) / n


def sub_horseshoe_embed(sequence: list[int], k: int, d: int) -> list[int]:
    """
    Sub-horseshoe extraction: embed a k-symbol sequence into a d-symbol sequence.
    Maps symbol j in Fin(k) to symbol j in Fin(d) (identity embedding).
    """
    assert k <= d, f"Cannot embed {k}-shift into {d}-shift"
    return [s % d for s in sequence]  # Already valid since s < k ≤ d


def main():
    print("=" * 60)
    print("HORSESHOE DYNAMICS AND COMPUTATIONAL UNIVERSALITY")
    print("=" * 60)

    # 1. Orbit Realization
    print("\n--- 1. Orbit Realization Theorem ---")
    word = [1, 0, 1, 1, 0]
    orbit = realize_word(word, d=2, total_len=15)
    print(f"Word to realize: {word}")
    print(f"Constructed orbit: {orbit}")
    print(f"First {len(word)} symbols match: {orbit[:len(word)] == word}")

    # 2. Shift Map
    print("\n--- 2. Shift Map Iteration ---")
    print(f"Original orbit:   {orbit}")
    for i in range(1, 4):
        shifted = symbolic_shift(orbit, steps=i)
        print(f"After {i} shift(s):   {shifted}")

    # 3. Boolean Encoding
    print("\n--- 3. Boolean Function Encoding ---")
    n = 4
    print(f"Encoding PARITY on {n} bits:")
    for bits in [(False, False, False, False),
                 (True, False, False, False),
                 (True, True, False, False),
                 (True, True, True, False),
                 (True, True, True, True)]:
        encoded = encode_boolean_function(parity, n, bits)
        bit_str = ''.join('1' if b else '0' for b in bits)
        print(f"  Input: {bit_str} → PARITY={parity(bits)} → Orbit: {encoded[:n+1]}")

    # 4. Entropy Characterization
    print("\n--- 4. Entropy Characterization ---")
    for d in [2, 3, 5, 10]:
        print(f"  d={d}:")
        for n_val in [1, 5, 10, 100]:
            rate = entropy_rate(d, n_val)
            exact = math.log(d)
            print(f"    n={n_val:3d}: log(d^n)/n = {rate:.6f}, log(d) = {exact:.6f}, "
                  f"match: {abs(rate - exact) < 1e-10}")

    # 5. Word Count and Subsystem Bounds
    print("\n--- 5. Subsystem Entropy Bounds ---")
    d, k = 5, 3
    for n_val in [1, 2, 3, 4, 5]:
        wk = word_count(k, n_val)
        wd = word_count(d, n_val)
        print(f"  n={n_val}: W({k},{n_val})={wk:5d} ≤ W({d},{n_val})={wd:5d}  "
              f"(ratio: {wk/wd:.4f})")

    # 6. Sub-horseshoe Extraction
    print("\n--- 6. Sub-horseshoe Extraction ---")
    k_seq = [0, 1, 2, 0, 1]
    d_val = 5
    embedded = sub_horseshoe_embed(k_seq, k=3, d=d_val)
    print(f"  3-symbol sequence: {k_seq}")
    print(f"  Embedded in 5-shift: {embedded}")
    print(f"  Shift commutes: {symbolic_shift(embedded) == sub_horseshoe_embed(symbolic_shift(k_seq), 3, d_val)}")

    # 7. Computational Universality Demo
    print("\n--- 7. Computational Universality ---")
    print("Every Boolean function on n bits can be encoded by the 2-shift.")

    def majority(bits: tuple[bool, ...]) -> bool:
        return sum(1 for b in bits if b) > len(bits) / 2

    def xor_first_last(bits: tuple[bool, ...]) -> bool:
        return bits[0] != bits[-1]

    for name, func in [("PARITY", parity), ("MAJORITY", majority), ("XOR_FIRST_LAST", xor_first_last)]:
        n = 3
        print(f"\n  Function: {name} on {n} bits")
        all_inputs = [(b2, b1, b0)
                      for b2 in [False, True]
                      for b1 in [False, True]
                      for b0 in [False, True]]
        for bits in all_inputs:
            encoded = encode_boolean_function(func, n, bits)
            bit_str = ''.join('1' if b else '0' for b in bits)
            print(f"    {bit_str} → {func(bits)} → orbit prefix: {encoded[:n+1]}")

    print("\n" + "=" * 60)
    print("All demonstrations completed successfully.")
    print("=" * 60)


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualization: Entropy of Full Shifts

Plots the entropy characterization: h_top(Σ_d) = log(d)
and the convergence of log(W(d,n))/n → log(d).
"""

import math
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


def word_count(d: int, n: int) -> int:
    return d ** n


def entropy_rate(d: int, n: int) -> float:
    if n == 0:
        return 0.0
    return math.log(word_count(d, n)) / n


def main():
    fig, axes = plt.subplots(1, 3, figsize=(15, 5))

    # Plot 1: Entropy rate convergence
    ax = axes[0]
    ns = list(range(1, 21))
    for d in [2, 3, 5, 8]:
        rates = [entropy_rate(d, n) for n in ns]
        ax.plot(ns, rates, 'o-', label=f'd={d}', markersize=4)
        ax.axhline(y=math.log(d), color='gray', linestyle='--', alpha=0.3)
    ax.set_xlabel('Word length n')
    ax.set_ylabel('log(d^n) / n')
    ax.set_title('Entropy Rate = log(d)\n(exact for all n > 0)')
    ax.legend()
    ax.grid(True, alpha=0.3)

    # Plot 2: Word count growth
    ax = axes[1]
    ns = list(range(1, 11))
    for d in [2, 3, 5]:
        counts = [word_count(d, n) for n in ns]
        ax.semilogy(ns, counts, 's-', label=f'd={d}', markersize=5)
    ax.set_xlabel('Word length n')
    ax.set_ylabel('Word count W(d,n) = d^n')
    ax.set_title('Exponential Growth of Word Count')
    ax.legend()
    ax.grid(True, alpha=0.3)

    # Plot 3: Subsystem entropy bound
    ax = axes[2]
    d_max = 10
    ds = list(range(1, d_max + 1))
    n_fixed = 5
    for k in [1, 2, 3, 5]:
        ratios = [word_count(min(k, d), n_fixed) / word_count(d, n_fixed) for d in ds]
        ax.plot(ds, ratios, 'D-', label=f'k={k} subsystem', markersize=5)
    ax.set_xlabel('Ambient shift degree d')
    ax.set_ylabel(f'W(k,{n_fixed}) / W(d,{n_fixed})')
    ax.set_title(f'Subsystem Entropy Bound (n={n_fixed})')
    ax.legend()
    ax.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('entropy_visualization.png', dpi=150, bbox_inches='tight')
    print("Saved entropy_visualization.png")


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualization: Horseshoe Map and Symbolic Dynamics

Visualizes the Smale horseshoe construction and its symbolic coding.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as patches
import numpy as np


def draw_horseshoe_construction(ax):
    """Draw the stretch-and-fold horseshoe construction."""
    # Original square
    rect = patches.Rectangle((0.1, 0.1), 0.3, 0.3, linewidth=2,
                              edgecolor='blue', facecolor='lightblue', alpha=0.5)
    ax.add_patch(rect)
    ax.text(0.25, 0.25, 'D', fontsize=14, ha='center', va='center', color='blue')

    # Arrow
    ax.annotate('', xy=(0.55, 0.25), xytext=(0.45, 0.25),
                arrowprops=dict(arrowstyle='->', lw=2, color='black'))
    ax.text(0.5, 0.32, 'f', fontsize=14, ha='center', style='italic')

    # Stretched and folded (horseshoe shape)
    # Vertical strip 1
    rect1 = patches.Rectangle((0.6, 0.1), 0.08, 0.3, linewidth=2,
                               edgecolor='red', facecolor='lightyellow', alpha=0.7)
    ax.add_patch(rect1)
    ax.text(0.64, 0.25, '0', fontsize=10, ha='center', va='center')

    # Vertical strip 2
    rect2 = patches.Rectangle((0.82, 0.1), 0.08, 0.3, linewidth=2,
                               edgecolor='red', facecolor='lightyellow', alpha=0.7)
    ax.add_patch(rect2)
    ax.text(0.86, 0.25, '1', fontsize=10, ha='center', va='center')

    # Connecting arc (horseshoe bend)
    theta = np.linspace(0, np.pi, 50)
    arc_x = 0.75 + 0.11 * np.cos(theta)
    arc_y = 0.4 + 0.05 * np.sin(theta)
    ax.plot(arc_x, arc_y, 'r-', linewidth=2)

    ax.set_xlim(0, 1)
    ax.set_ylim(0, 0.55)
    ax.set_aspect('equal')
    ax.set_title('Smale Horseshoe: Stretch and Fold', fontsize=12)
    ax.axis('off')


def draw_symbolic_coding(ax):
    """Draw the symbolic coding of orbits."""
    # Show a few orbits with their symbolic codings
    orbits = [
        ([0, 1, 0, 1, 0, 1, 0], 'alternating'),
        ([0, 0, 0, 0, 0, 0, 0], 'fixed point'),
        ([1, 1, 0, 1, 0, 0, 1], 'chaotic'),
        ([1, 0, 0, 1, 1, 0, 1], 'encoded'),
    ]

    colors = {'0': '#3498db', '1': '#e74c3c'}

    for idx, (orbit, label) in enumerate(orbits):
        y = 0.85 - idx * 0.22
        ax.text(0.02, y, label + ':', fontsize=9, va='center', family='monospace')
        for j, sym in enumerate(orbit):
            x = 0.3 + j * 0.09
            color = colors[str(sym)]
            rect = patches.FancyBboxPatch((x - 0.03, y - 0.06), 0.06, 0.12,
                                           boxstyle="round,pad=0.01",
                                           facecolor=color, alpha=0.7)
            ax.add_patch(rect)
            ax.text(x, y, str(sym), fontsize=10, ha='center', va='center',
                    color='white', fontweight='bold')

    # Time axis
    for j in range(7):
        x = 0.3 + j * 0.09
        ax.text(x, 0.98, f't={j}', fontsize=8, ha='center', color='gray')

    ax.set_xlim(0, 1)
    ax.set_ylim(0, 1.05)
    ax.set_title('Symbolic Coding of Orbits', fontsize=12)
    ax.axis('off')


def draw_boolean_encoding(ax):
    """Draw the Boolean encoding via symbolic orbits."""
    # Show how PARITY is encoded
    examples = [
        ((0, 0, 0), True, [0, 0, 0, 1]),
        ((1, 0, 0), False, [1, 0, 0, 0]),
        ((1, 1, 0), True, [1, 1, 0, 1]),
        ((1, 1, 1), False, [1, 1, 1, 0]),
    ]

    colors = {0: '#3498db', 1: '#e74c3c'}

    ax.text(0.5, 0.95, 'PARITY₃ Encoding', fontsize=12, ha='center',
            fontweight='bold')
    ax.text(0.15, 0.85, 'Input', fontsize=10, ha='center', color='gray')
    ax.text(0.5, 0.85, '→', fontsize=14, ha='center')
    ax.text(0.75, 0.85, 'Orbit', fontsize=10, ha='center', color='gray')

    for idx, (inp, out, orbit) in enumerate(examples):
        y = 0.72 - idx * 0.2
        # Input
        inp_str = ''.join(str(b) for b in inp)
        ax.text(0.15, y, inp_str, fontsize=11, ha='center', family='monospace')

        # Arrow
        ax.text(0.35, y, '→', fontsize=12, ha='center')

        # Orbit symbols
        for j, sym in enumerate(orbit):
            x = 0.5 + j * 0.1
            color = colors[sym]
            alpha = 0.9 if j < 3 else 0.5
            rect = patches.FancyBboxPatch((x - 0.035, y - 0.06), 0.07, 0.12,
                                           boxstyle="round,pad=0.01",
                                           facecolor=color, alpha=alpha)
            ax.add_patch(rect)
            ax.text(x, y, str(sym), fontsize=10, ha='center', va='center',
                    color='white', fontweight='bold')

        # Labels
        labels = ['i₀', 'i₁', 'i₂', 'out']
        for j, lbl in enumerate(labels):
            x = 0.5 + j * 0.1
            ax.text(x, y - 0.09, lbl, fontsize=7, ha='center', color='gray')

    ax.set_xlim(0, 1)
    ax.set_ylim(0, 1)
    ax.set_title('Boolean Encoding via Shift Orbits', fontsize=12)
    ax.axis('off')


def main():
    fig, axes = plt.subplots(1, 3, figsize=(16, 5))

    draw_horseshoe_construction(axes[0])
    draw_symbolic_coding(axes[1])
    draw_boolean_encoding(axes[2])

    plt.tight_layout()
    plt.savefig('horseshoe_visualization.png', dpi=150, bbox_inches='tight')
    print("Saved horseshoe_visualization.png")


if __name__ == "__main__":
    main()
