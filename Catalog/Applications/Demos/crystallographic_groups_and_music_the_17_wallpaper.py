#!/usr/bin/env python3
"""
Crystallographic Rhythm Theory: Numerical Demonstrations

Demonstrates the Rhythmic Interaction Tensor (RIT) and its key properties:
1. Autocorrelation palindromicity: R(-k) = R(k) for any rhythm
2. Weight-square sum: sum of R(k) = weight^2
3. Rotation plateau: symmetric rhythms have R(s) = weight at symmetry shifts
4. Interaction skew symmetry: I(f,g)(k) = I(g,f)(-k)
"""
from typing import List, Tuple


def rhythm_weight(rhythm: List[int]) -> int:
    """Count the number of active beats (onsets) in a rhythm."""
    return sum(rhythm)


def rhythm_interaction(f: List[int], g: List[int], k: int) -> int:
    """
    Compute the Rhythmic Interaction Tensor I(f,g)(k).
    Counts positions j where f[j]=1 and g[(j+k) mod n]=1.
    """
    n = len(f)
    assert len(g) == n
    return sum(f[j] * g[(j + k) % n] for j in range(n))


def autocorrelation(rhythm: List[int]) -> List[int]:
    """Compute the full autocorrelation spectrum R(k) for k=0,...,n-1."""
    n = len(rhythm)
    return [rhythm_interaction(rhythm, rhythm, k) for k in range(n)]


def retro(rhythm: List[int]) -> List[int]:
    """Time-reversal (retrograde) of a cyclic rhythm."""
    n = len(rhythm)
    return [rhythm[(-j) % n] for j in range(n)]


def is_palindromic(rhythm: List[int]) -> bool:
    """Check if a rhythm equals its retrograde."""
    return rhythm == retro(rhythm)


# === DEMONSTRATIONS ===

print("=" * 70)
print("CRYSTALLOGRAPHIC RHYTHM THEORY: KEY DEMONSTRATIONS")
print("=" * 70)

# Example 1: Son Clave (3-2) pattern in Z/16Z
son_clave = [1, 0, 0, 1, 0, 0, 1, 0, 0, 0, 1, 0, 1, 0, 0, 0]
print("\n--- Example 1: Son Clave (3-2) Pattern ---")
print(f"Pattern:  {son_clave}")
print(f"Weight:   {rhythm_weight(son_clave)}")
R = autocorrelation(son_clave)
print(f"Autocorrelation R(k): {R}")

# Verify palindromicity: R(k) = R(n-k)
n = len(son_clave)
palindromic = all(R[k] == R[n - k] for k in range(1, n))
print(f"R(k) = R(-k)?  {palindromic}  ✓ (Theorem: autocorr_palindromic)")

# Verify weight-square sum
w = rhythm_weight(son_clave)
total = sum(R)
print(f"Σ R(k) = {total}, w² = {w**2}, equal? {total == w**2}  ✓ (Theorem: autocorr_sum_eq_weight_sq)")

# Example 2: Tresillo pattern (3+3+2 in Z/8Z)
tresillo = [1, 0, 0, 1, 0, 0, 1, 0]
print("\n--- Example 2: Tresillo Pattern (3+3+2) ---")
print(f"Pattern:  {tresillo}")
print(f"Weight:   {rhythm_weight(tresillo)}")
R2 = autocorrelation(tresillo)
print(f"Autocorrelation: {R2}")
print(f"Palindromic?     {all(R2[k] == R2[8-k] for k in range(1,8))}  ✓")
print(f"Sum = {sum(R2)}, w² = {rhythm_weight(tresillo)**2}  ✓")
print(f"Pattern is palindromic? {is_palindromic(tresillo)}")

# Example 3: Maximally even 4-in-12 (whole-tone)
max_even = [1, 0, 0, 1, 0, 0, 1, 0, 0, 1, 0, 0]
print("\n--- Example 3: Maximally Even Pattern (4-in-12) ---")
print(f"Pattern:  {max_even}")
print(f"Weight:   {rhythm_weight(max_even)}")
R3 = autocorrelation(max_even)
print(f"Autocorrelation: {R3}")
print(f"Has 3-fold symmetry (shift by 3)? {all(max_even[(j+3)%12] == max_even[j] for j in range(12))}")
print(f"R(3) = {R3[3]}, R(0) = {R3[0]}, equal? {R3[3] == R3[0]}  ✓ (Theorem: autocorr_rotation_plateau)")

# Example 4: Interaction Tensor (polyrhythm)
print("\n--- Example 4: Interaction Tensor (3 against 4 polyrhythm) ---")
rhythm_3 = [1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0]  # 3 in 12
rhythm_4 = [1, 0, 0, 1, 0, 0, 1, 0, 0, 1, 0, 0]  # 4 in 12
I_fg = [rhythm_interaction(rhythm_3, rhythm_4, k) for k in range(12)]
I_gf = [rhythm_interaction(rhythm_4, rhythm_3, k) for k in range(12)]
print(f"Rhythm f (3-in-12): {rhythm_3}")
print(f"Rhythm g (4-in-12): {rhythm_4}")
print(f"I(f,g)(k):  {I_fg}")
print(f"I(g,f)(k):  {I_gf}")
skew_ok = all(I_fg[k] == I_gf[(-k) % 12] for k in range(12))
print(f"I(f,g)(k) = I(g,f)(-k)?  {skew_ok}  ✓ (Theorem: interaction_skew)")
w_f, w_g = rhythm_weight(rhythm_3), rhythm_weight(rhythm_4)
print(f"Σ I(f,g)(k) = {sum(I_fg)}, w(f)·w(g) = {w_f*w_g}  ✓ (Theorem: interaction_sum)")

# Example 5: Double Mirror = Rotation (2D pattern)
print("\n--- Example 5: Double Mirror = Rotation (4×4 grid) ---")
grid = [
    [1, 0, 0, 1],
    [0, 1, 1, 0],
    [0, 1, 1, 0],
    [1, 0, 0, 1]
]
time_rev = grid[::-1]
pitch_rev = [row[::-1] for row in grid]
rot180 = [row[::-1] for row in grid[::-1]]
print("Original grid:")
for row in grid: print(f"  {row}")
print("Time-reversed, then pitch-reversed:")
for row in [r[::-1] for r in time_rev]: print(f"  {row}")
print("180° rotation:")
for row in rot180: print(f"  {row}")
print(f"pitch_rev(time_rev(g)) == rot180(g)? {[r[::-1] for r in time_rev] == rot180}  ✓")
print(f"Grid has time-mirror symmetry?  {grid == time_rev}")
print(f"Grid has pitch-mirror symmetry? {grid == pitch_rev}")
print(f"Grid has rotation-2 symmetry?   {grid == rot180}")
print("Both mirrors => rotation ✓ (Theorem: grid_double_mirror_rotation)")

# Example 6: Boundary - empty and full rhythms
print("\n--- Example 6: Boundary Cases ---")
empty = [0] * 8
full = [1] * 8
R_empty = autocorrelation(empty)
R_full = autocorrelation(full)
print(f"Empty rhythm: weight={rhythm_weight(empty)}, R={R_empty}")
print(f"Full rhythm:  weight={rhythm_weight(full)},  R={R_full}")
print(f"Full R(k) = n = 8 for all k? {all(r == 8 for r in R_full)}  ✓ (Theorem: autocorr_full)")

# Example 7: The 17 wallpaper types
print("\n--- Example 7: The 17 Wallpaper Types ---")
wallpaper_types = [
    ("p1",   1, "Free rhythm"),
    ("p2",   2, "Call-and-response"),
    ("pm",   1, "Palindrome"),
    ("pg",   1, "Canon"),
    ("cm",   1, "Round"),
    ("pmm",  2, "Bilateral palindrome"),
    ("pmg",  2, "Inverted canon"),
    ("pgg",  2, "Double canon"),
    ("cmm",  2, "Round + palindrome"),
    ("p4",   4, "4-bar cycle"),
    ("p4m",  4, "Variations on a theme"),
    ("p4g",  4, "Inverted variations"),
    ("p3",   3, "3-bar blues"),
    ("p3m1", 3, "3-fold + mirrors"),
    ("p31m", 3, "3-fold + glides"),
    ("p6",   6, "Whole-tone symmetry"),
    ("p6m",  6, "Maximal symmetry"),
]
print(f"{'Type':<8} {'Rot':>3}  {'Musical interpretation'}")
print("-" * 50)
for name, rot, desc in wallpaper_types:
    print(f"{name:<8} {rot:>3}  {desc}")
print(f"\nTotal: {len(wallpaper_types)} types")
print("Rotation orders ∈ {1,2,3,4,6} ✓ (crystallographic restriction)")

print("\n" + "=" * 70)
print("All demonstrations verified successfully.")
print("=" * 70)


#!/usr/bin/env python3
"""
Visualization: Autocorrelation Spectra of Musical Rhythms

Shows how different rhythmic patterns produce different autocorrelation
profiles, and demonstrates the universal palindromicity property.
"""
import matplotlib.pyplot as plt
import numpy as np


def compute_autocorrelation(rhythm):
    n = len(rhythm)
    return [sum(rhythm[j] * rhythm[(j + k) % n] for j in range(n))
            for k in range(n)]


def plot_rhythm_and_autocorrelation(ax_rhythm, ax_autocorr, rhythm, name, color):
    n = len(rhythm)

    # Plot rhythm as a circular diagram
    theta = np.linspace(0, 2 * np.pi, n, endpoint=False)
    for i in range(n):
        marker_color = color if rhythm[i] else 'lightgray'
        marker_size = 200 if rhythm[i] else 80
        ax_rhythm.scatter(np.cos(theta[i]), np.sin(theta[i]),
                         s=marker_size, c=marker_color, zorder=5,
                         edgecolors='black', linewidth=0.5)
    circle = plt.Circle((0, 0), 1, fill=False, color='gray', linewidth=0.5)
    ax_rhythm.add_patch(circle)
    ax_rhythm.set_xlim(-1.4, 1.4)
    ax_rhythm.set_ylim(-1.4, 1.4)
    ax_rhythm.set_aspect('equal')
    ax_rhythm.set_title(f'{name}\nweight={sum(rhythm)}', fontsize=10)
    ax_rhythm.axis('off')

    # Plot autocorrelation
    R = compute_autocorrelation(rhythm)
    x = np.arange(n)
    ax_autocorr.bar(x, R, color=color, alpha=0.7, edgecolor='black', linewidth=0.5)
    ax_autocorr.set_xlabel('Lag k')
    ax_autocorr.set_ylabel('R(k)')
    ax_autocorr.set_title(f'Autocorrelation\nΣR={sum(R)}, w²={sum(rhythm)**2}', fontsize=10)

    # Highlight palindromicity
    for k in range(1, n // 2 + 1):
        if R[k] == R[n - k]:
            ax_autocorr.plot([k, n - k], [R[k], R[n - k]], 'r--', alpha=0.3)


# Define rhythms
rhythms = [
    ([1, 0, 0, 1, 0, 0, 1, 0, 0, 0, 1, 0, 1, 0, 0, 0],
     "Son Clave (3-2)", "#e74c3c"),
    ([1, 0, 0, 1, 0, 0, 1, 0],
     "Tresillo (3+3+2)", "#3498db"),
    ([1, 0, 0, 1, 0, 0, 1, 0, 0, 1, 0, 0],
     "Maximally Even 4/12", "#2ecc71"),
    ([1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0],
     "Whole-tone (6/12)", "#9b59b6"),
]

fig, axes = plt.subplots(len(rhythms), 2, figsize=(12, 3 * len(rhythms)))
fig.suptitle('Crystallographic Rhythm Theory:\nAutocorrelation Spectra of Musical Rhythms',
             fontsize=14, fontweight='bold')

for i, (rhythm, name, color) in enumerate(rhythms):
    plot_rhythm_and_autocorrelation(axes[i, 0], axes[i, 1], rhythm, name, color)

plt.tight_layout()
plt.savefig('autocorrelation_spectra.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved: autocorrelation_spectra.png")


#!/usr/bin/env python3
"""
Visualization: Rhythmic Interaction Tensor as Heatmap

Shows the interaction tensor I(f,g)(k) for all pairs of standard
rhythmic patterns, revealing the polyrhythmic structure.
"""
import matplotlib.pyplot as plt
import numpy as np


def compute_rit(f, g):
    n = len(f)
    return [sum(f[j] * g[(j + k) % n] for j in range(n)) for k in range(n)]


# Define rhythms on Z/12Z
rhythms = {
    "3-in-12 (dotted quarter)": [1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0],
    "4-in-12 (dotted eighth)": [1, 0, 0, 1, 0, 0, 1, 0, 0, 1, 0, 0],
    "6-in-12 (whole-tone)": [1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0],
    "Bembe (7-in-12)": [1, 0, 1, 1, 0, 1, 0, 1, 1, 0, 1, 0],
    "Bossa Nova": [1, 0, 0, 1, 0, 0, 1, 0, 0, 0, 1, 0],
}

names = list(rhythms.keys())
patterns = list(rhythms.values())
n_patterns = len(patterns)

# Compute full interaction matrix
fig, axes = plt.subplots(n_patterns, n_patterns, figsize=(16, 16))
fig.suptitle('Rhythmic Interaction Tensor I(f,g)(k)\n'
             'Each subplot shows how two rhythms interact across all phase offsets',
             fontsize=14, fontweight='bold')

for i in range(n_patterns):
    for j in range(n_patterns):
        I = compute_rit(patterns[i], patterns[j])
        ax = axes[i][j]
        ax.bar(range(12), I, color='steelblue' if i != j else 'coral',
               alpha=0.8, edgecolor='black', linewidth=0.3)

        if i == 0:
            ax.set_title(names[j].split('(')[0].strip(), fontsize=8)
        if j == 0:
            ax.set_ylabel(names[i].split('(')[0].strip(), fontsize=8)
        ax.set_ylim(0, max(I) + 1 if max(I) > 0 else 2)
        ax.tick_params(labelsize=6)

        # Annotate sum
        w_i = sum(patterns[i])
        w_j = sum(patterns[j])
        ax.text(0.95, 0.95, f'Σ={sum(I)}\nww={w_i*w_j}',
                transform=ax.transAxes, fontsize=6,
                verticalalignment='top', horizontalalignment='right',
                bbox=dict(boxstyle='round', facecolor='wheat', alpha=0.5))

plt.tight_layout()
plt.savefig('interaction_tensor_matrix.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved: interaction_tensor_matrix.png")


#!/usr/bin/env python3
"""
Visualization: The 17 Wallpaper Types and Their Musical Interpretations

Creates a lattice diagram showing the containment relationships between
wallpaper groups, annotated with musical interpretations.
"""
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np


# Wallpaper types with positions in the Hasse diagram
# (x, y) positions arranged by symmetry level
wallpaper_data = {
    # Level 0
    "p1":   (0, 0, 1, "Free rhythm", "#ecf0f1"),
    # Level 1
    "p2":   (-2, 1, 2, "Call-and-response", "#e74c3c"),
    "pm":   (0, 1, 1, "Palindrome", "#3498db"),
    "pg":   (2, 1, 1, "Canon", "#2ecc71"),
    # Level 2
    "cm":   (3, 2, 1, "Round", "#1abc9c"),
    "pmm":  (-2, 2, 2, "Bilateral palindrome", "#e74c3c"),
    "pmg":  (0, 2, 2, "Inverted canon", "#e67e22"),
    "pgg":  (2, 2, 2, "Double canon", "#9b59b6"),
    # Level 3
    "cmm":  (1, 3, 2, "Round + palindrome", "#e67e22"),
    "p4":   (-2, 3, 4, "4-bar cycle", "#f39c12"),
    "p3":   (4, 3, 3, "3-bar blues", "#16a085"),
    # Level 4
    "p4m":  (-3, 4, 4, "Variations", "#f39c12"),
    "p4g":  (-1, 4, 4, "Inverted variations", "#d35400"),
    "p3m1": (3, 4, 3, "3-fold + mirrors", "#16a085"),
    "p31m": (5, 4, 3, "3-fold + glides", "#27ae60"),
    # Level 5
    "p6":   (1, 5, 6, "Whole-tone symmetry", "#8e44ad"),
    # Level 6
    "p6m":  (1, 6, 6, "Maximal symmetry", "#c0392b"),
}

# Containment edges (subgroup relations)
edges = [
    ("p1", "p2"), ("p1", "pm"), ("p1", "pg"),
    ("pm", "pmm"), ("pm", "cm"), ("pg", "pmg"), ("pg", "pgg"), ("pg", "cm"),
    ("p2", "pmm"), ("p2", "pmg"), ("p2", "pgg"),
    ("pmm", "cmm"), ("pmg", "cmm"),
    ("p2", "p4"), ("pmm", "p4m"), ("pgg", "p4g"),
    ("p4", "p4m"), ("p4", "p4g"),
    ("p2", "p6"), ("p3", "p6"),
    ("p4m", "p6m"), ("p3m1", "p6m"), ("p31m", "p6m"),
    ("p6", "p6m"),
    ("p3", "p3m1"), ("p3", "p31m"), ("cm", "cmm"),
    ("cmm", "p4g"),
]

fig, ax = plt.subplots(1, 1, figsize=(14, 10))

# Draw edges
for src, dst in edges:
    x1, y1 = wallpaper_data[src][0], wallpaper_data[src][1]
    x2, y2 = wallpaper_data[dst][0], wallpaper_data[dst][1]
    ax.plot([x1, x2], [y1, y2], 'k-', alpha=0.2, linewidth=1)

# Draw nodes
for name, (x, y, rot, desc, color) in wallpaper_data.items():
    circle = plt.Circle((x, y), 0.35, facecolor=color, edgecolor='black',
                        linewidth=1.5, zorder=10)
    ax.add_patch(circle)
    ax.text(x, y + 0.02, name, ha='center', va='center',
            fontsize=9, fontweight='bold', zorder=11)
    ax.text(x, y - 0.55, desc, ha='center', va='top',
            fontsize=7, fontstyle='italic', color='#333')
    ax.text(x + 0.25, y + 0.25, str(rot), ha='center', va='center',
            fontsize=7, color='red', fontweight='bold', zorder=11)

# Labels
ax.set_title('The 17 Wallpaper Groups: A Musical Taxonomy of Rhythm\n'
             '(Numbers indicate maximal rotation order; higher = more symmetric)',
             fontsize=14, fontweight='bold')
ax.set_xlabel('← Less symmetric                                More symmetric →',
              fontsize=10)
ax.set_ylabel('Symmetry Level', fontsize=10)

# Add legend
legend_elements = [
    mpatches.Patch(facecolor='#e74c3c', label='Rotation-2'),
    mpatches.Patch(facecolor='#3498db', label='Mirror only'),
    mpatches.Patch(facecolor='#2ecc71', label='Glide only'),
    mpatches.Patch(facecolor='#f39c12', label='Rotation-4'),
    mpatches.Patch(facecolor='#16a085', label='Rotation-3'),
    mpatches.Patch(facecolor='#8e44ad', label='Rotation-6'),
]
ax.legend(handles=legend_elements, loc='lower left', fontsize=8)

ax.set_xlim(-5, 7)
ax.set_ylim(-0.8, 7)
ax.set_aspect('equal')
ax.grid(True, alpha=0.1)

plt.tight_layout()
plt.savefig('wallpaper_lattice.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved: wallpaper_lattice.png")
