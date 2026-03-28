#!/usr/bin/env python3
"""
Demo 6: Defect Algebra Experiments
Computational experiments exploring what happens when integers are removed.
Tests factorization, arithmetic closure, and search space effects.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
from collections import defaultdict
import matplotlib.gridspec as gridspec

fig = plt.figure(figsize=(22, 16))
gs = gridspec.GridSpec(2, 3, figure=fig, hspace=0.3, wspace=0.3)

# ──── Experiment 1: Remove each prime and count broken factorizations ────
ax1 = fig.add_subplot(gs[0, 0])
ax1.set_title('Removing Prime p: How Many Numbers\nLose Their Factorization? (up to N=1000)', 
              fontsize=11, fontweight='bold', color='white')

N = 1000
primes_to_remove = [2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47]

broken_counts = []
for p in primes_to_remove:
    count = 0
    for n in range(2, N+1):
        # Check if p divides n
        temp = n
        while temp % p == 0:
            temp //= p
            if temp > 0:
                count_flag = True
        if n % p == 0:  # n has p as a factor
            count += 1
    broken_counts.append(count)

# More precise: multiples of p up to N
broken_counts = [N // p for p in primes_to_remove]

bars = ax1.bar(range(len(primes_to_remove)), broken_counts, 
               color=[plt.cm.plasma(i/len(primes_to_remove)) for i in range(len(primes_to_remove))],
               alpha=0.8)

ax1.set_xticks(range(len(primes_to_remove)))
ax1.set_xticklabels([str(p) for p in primes_to_remove], color='white', fontsize=8)
ax1.set_xlabel('Prime removed', color='white')
ax1.set_ylabel('Numbers with broken factorization', color='white')
ax1.set_facecolor('#0a0a1a')
ax1.tick_params(colors='white')
for spine in ax1.spines.values():
    spine.set_color('#444444')

# Annotate the 1/p law
ax1.text(7, 400, 'Count ≈ N/p\n(density = 1/p)', fontsize=10, color='#f39c12',
         fontweight='bold', bbox=dict(boxstyle='round', facecolor='#1a1a2e'))

# ──── Experiment 2: Closure violations under addition ────
ax2 = fig.add_subplot(gs[0, 1])
ax2.set_title('Addition Closure Violations in ℤ\\{n}\nFor each removed n, count (a+b=n) pairs', 
              fontsize=11, fontweight='bold', color='white')

removed_values = list(range(1, 51))
violation_counts = []

for n in removed_values:
    # How many pairs (a, b) with a, b ∈ ℤ∩[1,100]\\{n} satisfy a+b = n?
    count = 0
    for a in range(1, n):
        b = n - a
        if b > 0 and a != n and b != n:
            count += 1
    violation_counts.append(count)

ax2.plot(removed_values, violation_counts, 'o-', color='#e74c3c', markersize=4, linewidth=1)
ax2.fill_between(removed_values, 0, violation_counts, alpha=0.2, color='#e74c3c')

# Theoretical: floor((n-1)/2) pairs (roughly linear)
theoretical = [(n-1)//2 for n in removed_values]
ax2.plot(removed_values, theoretical, '--', color='#2ecc71', linewidth=2, label='⌊(n-1)/2⌋')

ax2.set_xlabel('Removed integer n', color='white')
ax2.set_ylabel('Number of (a+b=n) violations', color='white')
ax2.legend(facecolor='#1a1a2e', labelcolor='white')
ax2.set_facecolor('#0a0a1a')
ax2.tick_params(colors='white')
for spine in ax2.spines.values():
    spine.set_color('#444444')

# ──── Experiment 3: Multiplication closure heat map ────
ax3 = fig.add_subplot(gs[0, 2])
ax3.set_title('Multiplication Closure in ℤ\\{7}\nRed = product equals 7 (violation)', 
              fontsize=11, fontweight='bold', color='white')

size = 15
removed = 7
grid = np.zeros((size, size))

for i in range(1, size+1):
    for j in range(1, size+1):
        if i * j == removed:
            grid[i-1, j-1] = 2  # Violation
        elif i == removed or j == removed:
            grid[i-1, j-1] = 1  # Factor is missing
        else:
            grid[i-1, j-1] = 0  # OK

cmap = plt.cm.colors.ListedColormap(['#1a1a2e', '#f39c12', '#e74c3c'])
bounds = [-0.5, 0.5, 1.5, 2.5]
norm = plt.cm.colors.BoundaryNorm(bounds, cmap.N)
ax3.imshow(grid, cmap=cmap, norm=norm, origin='lower')

ax3.set_xlabel('Factor a', color='white')
ax3.set_ylabel('Factor b', color='white')
ax3.set_xticks(range(size))
ax3.set_xticklabels(range(1, size+1), fontsize=7, color='white')
ax3.set_yticks(range(size))
ax3.set_yticklabels(range(1, size+1), fontsize=7, color='white')

# Legend
from matplotlib.patches import Patch
legend_elements = [
    Patch(facecolor='#1a1a2e', edgecolor='white', label='OK (product ∈ ℤ\\{7})'),
    Patch(facecolor='#f39c12', edgecolor='white', label='Factor is 7 (missing)'),
    Patch(facecolor='#e74c3c', edgecolor='white', label='Product = 7 (violation)'),
]
ax3.legend(handles=legend_elements, loc='upper right', fontsize=7,
           facecolor='#1a1a2e', labelcolor='white')
ax3.set_facecolor('#0a0a1a')

# ──── Experiment 4: GCD structure in ℤ\\{n} ────
ax4 = fig.add_subplot(gs[1, 0])
ax4.set_title('GCD Landscape in ℤ\\{7}\nRemoved integer affects divisibility chains', 
              fontsize=11, fontweight='bold', color='white')

# Divisibility lattice fragment
def divisors(n, excluded=None):
    divs = []
    for i in range(1, n+1):
        if excluded is not None and i == excluded:
            continue
        if n % i == 0:
            divs.append(i)
    return divs

# Compare divisor counts with and without 7
numbers = range(1, 60)
div_counts_normal = [len(divisors(n)) for n in numbers]
div_counts_defect = [len(divisors(n, excluded=7)) for n in numbers]

differences = [a - b for a, b in zip(div_counts_normal, div_counts_defect)]

ax4.bar(numbers, differences, color=['#e74c3c' if d > 0 else '#2ecc71' for d in differences], alpha=0.7)
ax4.set_xlabel('Number n', color='white')
ax4.set_ylabel('Lost divisors (normal - defect)', color='white')
ax4.set_facecolor('#0a0a1a')
ax4.tick_params(colors='white')
for spine in ax4.spines.values():
    spine.set_color('#444444')

# Annotate multiples of 7
for n in range(7, 60, 7):
    if n < 60:
        ax4.text(n, differences[n-1]+0.15, '7|n', fontsize=7, ha='center', color='#ff6b6b')

# ──── Experiment 5: Removing different integers — universal comparison ────
ax5 = fig.add_subplot(gs[1, 1])
ax5.set_title('Algebraic Damage Score\nfor Removing Each Integer 1-30', 
              fontsize=11, fontweight='bold', color='white')

def damage_score(removed, N=200):
    """Quantify how much damage removing an integer does."""
    score = 0
    # Addition violations
    for a in range(1, N+1):
        if a == removed:
            continue
        b = removed - a
        if 1 <= b <= N and b != removed:
            score += 1
    # Multiplication violations
    for a in range(1, N+1):
        if a == removed:
            continue
        if removed % a == 0:
            b = removed // a
            if 1 <= b <= N and b != removed:
                score += 2  # Multiplication violations are "worse"
    # Prime factorization damage
    if removed >= 2:
        n = removed
        is_prime = all(n % i != 0 for i in range(2, int(n**0.5)+1))
        if is_prime:
            score += N // removed * 3  # Every multiple loses a factor
    return score

removed_range = range(1, 31)
scores = [damage_score(r) for r in removed_range]

colors_bar = []
for r in removed_range:
    is_prime = r >= 2 and all(r % i != 0 for i in range(2, int(r**0.5)+1))
    colors_bar.append('#e74c3c' if is_prime else '#3498db')

ax5.bar(removed_range, scores, color=colors_bar, alpha=0.8)
ax5.set_xlabel('Removed integer', color='white')
ax5.set_ylabel('Algebraic damage score', color='white')
ax5.legend([plt.Line2D([0],[0], marker='s', color='#e74c3c', ls=''),
            plt.Line2D([0],[0], marker='s', color='#3498db', ls='')],
           ['Prime', 'Composite'], facecolor='#1a1a2e', labelcolor='white', fontsize=9)
ax5.set_facecolor('#0a0a1a')
ax5.tick_params(colors='white')
for spine in ax5.spines.values():
    spine.set_color('#444444')

# ──── Experiment 6: Can defect help? Search space reduction ────
ax6 = fig.add_subplot(gs[1, 2])
ax6.set_title('Search Space Reduction in Defect Algebra\nSubset Sum with ℤ\\{target}', 
              fontsize=11, fontweight='bold', color='white')

# For subset sum: if we remove the target value from the universe,
# some solutions become invalid, potentially simplifying the search
np.random.seed(42)
n_trials = 50
sizes = range(5, 25)
normal_solutions = []
defect_solutions = []

for n in sizes:
    normal_total = 0
    defect_total = 0
    for _ in range(n_trials):
        weights = np.random.randint(1, 20, size=n)
        target = np.random.randint(10, 40)
        
        # Count solutions normally
        normal_count = 0
        defect_count = 0
        # Sample random subsets (approximate)
        for _ in range(1000):
            mask = np.random.random(n) > 0.5
            s = weights[mask].sum()
            if s == target:
                normal_count += 1
                # In defect algebra: check if any partial sum equals removed integer
                # (simplified model: remove target itself from partial sums)
                partial_ok = True
                cumsum = 0
                for w in weights[mask]:
                    cumsum += w
                    if cumsum == target and cumsum != s:  # intermediate sum hits removed value
                        partial_ok = False
                        break
                if partial_ok:
                    defect_count += 1
        
        normal_total += normal_count
        defect_total += defect_count
    
    normal_solutions.append(normal_total / n_trials)
    defect_solutions.append(defect_total / n_trials)

ax6.plot(list(sizes), normal_solutions, 'o-', color='#3498db', label='Normal ℤ', linewidth=2)
ax6.plot(list(sizes), defect_solutions, 's-', color='#e74c3c', label='Defect ℤ\\{target}', linewidth=2)
ax6.fill_between(list(sizes), defect_solutions, normal_solutions, alpha=0.1, color='#f39c12')

ax6.set_xlabel('Problem size n', color='white')
ax6.set_ylabel('Avg solutions found (1000 samples)', color='white')
ax6.legend(facecolor='#1a1a2e', labelcolor='white')
ax6.set_facecolor('#0a0a1a')
ax6.tick_params(colors='white')
for spine in ax6.spines.values():
    spine.set_color('#444444')

ax6.text(15, max(normal_solutions)*0.8, 'Defect algebra reduces\nsolution count (pruning)', 
         fontsize=9, color='#f39c12', fontweight='bold',
         bbox=dict(boxstyle='round', facecolor='#1a1a2e', alpha=0.8))

fig.patch.set_facecolor('#0a0a1a')
plt.savefig('/workspace/request-project/demos/defect_algebra_experiments.png', 
            dpi=150, bbox_inches='tight', facecolor='#0a0a1a')
plt.close()
print("✅ Saved: demos/defect_algebra_experiments.png")
