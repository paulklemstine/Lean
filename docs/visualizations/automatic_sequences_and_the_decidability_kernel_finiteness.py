"""
Visualization: Kernel Finiteness — The Signature of Automaticity

Shows the k-kernel of the Thue-Morse sequence compared to a non-automatic
sequence, illustrating how kernel finiteness characterizes automaticity.
"""

import numpy as np
import matplotlib.pyplot as plt


def bit_sum(n):
    count = 0
    while n > 0:
        count += n & 1
        n >>= 1
    return count


def thue_morse(n):
    return bit_sum(n) % 2


def collatz_parity(n):
    """Collatz sequence parity — conjectured to be non-automatic."""
    if n == 0:
        return 0
    steps = 0
    while n != 1 and steps < 1000:
        if n % 2 == 0:
            n //= 2
        else:
            n = 3 * n + 1
        steps += 1
    return steps % 2


def compute_kernel_element(seq_func, k, e, r, n_points):
    """Compute the kernel element (e, r): n -> seq(k^e * n + r)."""
    ke = k ** e
    return [seq_func(ke * m + r) for m in range(n_points)]


fig, axes = plt.subplots(2, 2, figsize=(14, 10))
fig.suptitle('Kernel Finiteness: The Signature of Automatic Sequences', 
             fontsize=16, fontweight='bold')

n_points = 50
k = 2

# Panel 1: Thue-Morse kernel elements
ax = axes[0, 0]
ax.set_title('Thue-Morse 2-Kernel Elements', fontsize=12)

seen_patterns = {}
colors = plt.cm.Set2(np.linspace(0, 1, 8))
color_idx = 0

for e in range(5):
    ke = k ** e
    for r in range(ke):
        vals = compute_kernel_element(thue_morse, k, e, r, n_points)
        pattern = tuple(vals)
        if pattern not in seen_patterns:
            seen_patterns[pattern] = (e, r, colors[color_idx % len(colors)])
            color_idx += 1
        c = seen_patterns[pattern][2]
        alpha = 0.8 if (e, r) == seen_patterns[pattern][:2] else 0.15
        lw = 2 if (e, r) == seen_patterns[pattern][:2] else 0.5
        ax.step(range(n_points), [v + 0.01 * (e * ke + r) for v in vals], 
               where='mid', color=c, alpha=alpha, linewidth=lw)

ax.set_xlabel('m')
ax.set_ylabel('Value')
ax.text(25, 0.5, f'{len(seen_patterns)} distinct\nkernel elements', 
       fontsize=14, fontweight='bold', ha='center', va='center',
       bbox=dict(boxstyle='round', facecolor='wheat', alpha=0.8))

# Panel 2: Kernel element count vs exponent
ax = axes[0, 1]
ax.set_title('Kernel Size vs. Exponent Depth', fontsize=12)

tm_counts = []
for max_e in range(8):
    patterns = set()
    for e in range(max_e + 1):
        ke = k ** e
        for r in range(ke):
            vals = tuple(compute_kernel_element(thue_morse, k, e, r, 30))
            patterns.add(vals)
    tm_counts.append(len(patterns))

ax.plot(range(8), tm_counts, 'o-', color='#4CAF50', linewidth=2, markersize=8,
       label='Thue-Morse (automatic)')
ax.axhline(y=2, color='#4CAF50', linestyle='--', alpha=0.5, label='Theoretical bound = 2')

# For comparison: digit sum mod 3 (3-automatic, checked with base 3)
ds3_counts = []
def digit_sum_mod3(n):
    s = 0
    while n > 0:
        s += n % 3
        n //= 3
    return s % 3

for max_e in range(6):
    patterns = set()
    for e in range(max_e + 1):
        ke = 3 ** e
        for r in range(ke):
            vals = tuple([digit_sum_mod3(ke * m + r) for m in range(30)])
            patterns.add(vals)
    ds3_counts.append(len(patterns))

ax.plot(range(6), ds3_counts, 's-', color='#2196F3', linewidth=2, markersize=8,
       label='Digit sum mod 3 (3-automatic)')
ax.axhline(y=3, color='#2196F3', linestyle='--', alpha=0.5, label='Theoretical bound = 3')

ax.set_xlabel('Maximum exponent e')
ax.set_ylabel('Distinct kernel elements')
ax.legend(fontsize=9)
ax.set_ylim(0, max(max(tm_counts), max(ds3_counts)) + 2)

# Panel 3: Thue-Morse kernel as heatmap
ax = axes[1, 0]
ax.set_title('Kernel Heatmap: All (e,r) Pairs', fontsize=12)

max_e_heat = 4
all_vals = []
labels_y = []
for e in range(max_e_heat + 1):
    ke = k ** e
    for r in range(ke):
        vals = compute_kernel_element(thue_morse, k, e, r, 40)
        all_vals.append(vals)
        labels_y.append(f'({e},{r})')

heatmap = np.array(all_vals)
im = ax.imshow(heatmap, cmap='binary', aspect='auto', interpolation='nearest')
ax.set_xlabel('m')
ax.set_ylabel('(e, r)')
ax.set_yticks(range(len(labels_y)))
ax.set_yticklabels(labels_y, fontsize=7)
plt.colorbar(im, ax=ax, label='Value')

# Panel 4: Summary diagram
ax = axes[1, 1]
ax.set_title('The Eilenberg Characterization', fontsize=12)
ax.axis('off')

# Draw Venn-like diagram
circle1 = plt.Circle((0.35, 0.55), 0.25, fill=True, facecolor='#C8E6C9', 
                     edgecolor='#2E7D32', linewidth=2, alpha=0.8)
circle2 = plt.Circle((0.65, 0.55), 0.35, fill=True, facecolor='#BBDEFB', 
                     edgecolor='#1565C0', linewidth=2, alpha=0.5)
circle3 = plt.Circle((0.5, 0.55), 0.45, fill=True, facecolor='#FFF9C4', 
                     edgecolor='#F57F17', linewidth=2, alpha=0.3)

ax.add_patch(circle3)
ax.add_patch(circle2)
ax.add_patch(circle1)

ax.text(0.25, 0.55, 'Eventually\nPeriodic', ha='center', va='center', fontsize=9)
ax.text(0.55, 0.55, 'k-Automatic\n(finite kernel)', ha='center', va='center', fontsize=10, fontweight='bold')
ax.text(0.85, 0.55, 'All\nSequences', ha='center', va='center', fontsize=9, alpha=0.7)

ax.text(0.5, 0.05, 
       'Eilenberg\'s Theorem:\nA sequence is k-automatic ⟺ its k-kernel is finite\n\n'
       'Finite kernel ≤ n states → decidable properties\n'
       'Infinite kernel → potential undecidability',
       ha='center', va='bottom', fontsize=10, style='italic',
       bbox=dict(boxstyle='round', facecolor='lightyellow', alpha=0.9))

plt.tight_layout()
plt.savefig('viz_kernel.png', dpi=150, bbox_inches='tight')
print("Saved viz_kernel.png")
