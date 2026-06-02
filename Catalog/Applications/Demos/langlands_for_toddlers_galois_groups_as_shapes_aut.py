#!/usr/bin/env python3
"""
Langlands for GL₁: Shape-Color Correspondence Demo

Demonstrates the bijection between quadratic fields Q(√d) and
quadratic Dirichlet characters χ_D via the Jacobi/Kronecker symbol.
"""

from math import gcd

def jacobi_symbol(a: int, n: int) -> int:
    """Compute the Jacobi symbol (a/n) for odd positive n."""
    if n <= 0 or n % 2 == 0:
        raise ValueError(f"n must be odd and positive, got {n}")
    a = a % n
    result = 1
    while a != 0:
        while a % 2 == 0:
            a //= 2
            if n % 8 in (3, 5):
                result = -result
        a, n = n, a
        if a % 4 == 3 and n % 4 == 3:
            result = -result
        a = a % n
    return result if n == 1 else 0


def quad_disc(d: int) -> int:
    """Fundamental discriminant of Q(√d) for squarefree d."""
    return d if d % 4 == 1 else 4 * d


def is_squarefree(n: int) -> bool:
    """Check if n is squarefree."""
    if n == 0:
        return False
    n = abs(n)
    for p in range(2, int(n**0.5) + 1):
        if n % (p * p) == 0:
            return False
    return True


def kronecker_character(D: int, n: int) -> int:
    """Kronecker symbol (D/n), extending Jacobi to even n."""
    if n == 0:
        return 1 if abs(D) == 1 else 0
    if n < 0:
        n = -n
        if D < 0:
            return -kronecker_character(D, n)
        return kronecker_character(D, n)
    
    result = 1
    # Handle factor of 2
    while n % 2 == 0:
        n //= 2
        if D % 2 == 0:
            result = 0
            return 0
        elif D % 8 in (1, 7):
            pass  # (D/2) = 1
        else:
            result *= -1  # (D/2) = -1
    
    if n == 1:
        return result
    return result * jacobi_symbol(D, n)


# ============================================================
# Demo 1: The Shape-Color Dictionary
# ============================================================
print("=" * 60)
print("DEMO 1: Shape-Color Dictionary for Quadratic Fields")
print("=" * 60)
print()

squarefree_d = [-7, -3, -2, -1, 2, 3, 5, 6, 7, 10, 11, 13]
print(f"{'d':>4} | {'D=quadDisc(d)':>14} | {'Q(√d)':>10} | Splitting of first primes")
print("-" * 70)

for d in squarefree_d:
    D = quad_disc(d)
    field = f"Q(√{d})"
    primes = [3, 5, 7, 11, 13]
    symbols = []
    for p in primes:
        if p == 2:
            continue
        j = jacobi_symbol(D, p) if p > 2 else 0
        if j == 1:
            symbols.append(f"{p}:split")
        elif j == -1:
            symbols.append(f"{p}:inert")
        else:
            symbols.append(f"{p}:ram")
    print(f"{d:>4} | {D:>14} | {field:>10} | {', '.join(symbols)}")

print()

# ============================================================
# Demo 2: Bi-multiplicativity Verification
# ============================================================
print("=" * 60)
print("DEMO 2: Bi-multiplicativity J(a₁a₂, b₁b₂) = product")
print("=" * 60)
print()

test_cases = [
    (3, 7, 5, 11),
    (2, 5, 3, 7),
    (11, 13, 7, 9),
    (-1, 3, 5, 7),
    (6, 7, 11, 13),
]

all_pass = True
for a1, a2, b1, b2 in test_cases:
    lhs = jacobi_symbol(a1 * a2, b1 * b2)
    rhs = (jacobi_symbol(a1, b1) * jacobi_symbol(a1, b2) *
           jacobi_symbol(a2, b1) * jacobi_symbol(a2, b2))
    ok = "✓" if lhs == rhs else "✗"
    if lhs != rhs:
        all_pass = False
    print(f"  J({a1}·{a2}, {b1}·{b2}) = {lhs:>2},  "
          f"J({a1},{b1})·J({a1},{b2})·J({a2},{b1})·J({a2},{b2}) = {rhs:>2}  {ok}")

print(f"\nAll bi-multiplicativity checks passed: {all_pass}")
print()

# ============================================================
# Demo 3: Shape-Color Reciprocity
# ============================================================
print("=" * 60)
print("DEMO 3: Shape-Color Reciprocity J(a,b)·J(b,a) = (-1)^((a/2)(b/2))")
print("=" * 60)
print()

reciprocity_tests = [
    (3, 5), (3, 7), (5, 7), (5, 11), (7, 11),
    (3, 11), (5, 13), (7, 13), (11, 13), (3, 13),
]

all_pass = True
for a, b in reciprocity_tests:
    if a % 2 == 0 or b % 2 == 0 or gcd(a, b) != 1:
        continue
    lhs = jacobi_symbol(a, b) * jacobi_symbol(b, a)
    exp = (a // 2) * (b // 2)
    rhs = (-1) ** exp
    ok = "✓" if lhs == rhs else "✗"
    if lhs != rhs:
        all_pass = False
    transparent = "transparent" if a % 4 == 1 or b % 4 == 1 else "non-trivial sign"
    print(f"  J({a:>2},{b:>2})·J({b:>2},{a:>2}) = {lhs:>2},  "
          f"(-1)^({a//2}·{b//2}) = {rhs:>2}  {ok}  [{transparent}]")

print(f"\nAll reciprocity checks passed: {all_pass}")
print()

# ============================================================
# Demo 4: Non-triviality — Quadratic Non-residues
# ============================================================
print("=" * 60)
print("DEMO 4: Non-triviality — Every Odd Prime Has Non-residues")
print("=" * 60)
print()

for p in [3, 5, 7, 11, 13, 17, 19, 23, 29, 31]:
    residues = [a for a in range(1, p) if jacobi_symbol(a, p) == 1]
    non_residues = [a for a in range(1, p) if jacobi_symbol(a, p) == -1]
    print(f"  p = {p:>2}: QR = {residues}, QNR = {non_residues}")
    assert len(residues) == (p - 1) // 2, f"Expected {(p-1)//2} QRs for p={p}"
    assert len(non_residues) == (p - 1) // 2, f"Expected {(p-1)//2} QNRs for p={p}"

print(f"\n  Verified: for each odd prime p, exactly (p-1)/2 residues and (p-1)/2 non-residues.")
print()

# ============================================================
# Demo 5: Discriminant Injectivity
# ============================================================
print("=" * 60)
print("DEMO 5: Discriminant Injectivity (Different Shapes → Different Colors)")
print("=" * 60)
print()

discs = {}
for d in range(-100, 101):
    if d == 0 or not is_squarefree(d):
        continue
    D = quad_disc(d)
    if D in discs:
        print(f"  COLLISION: quadDisc({d}) = quadDisc({discs[D]}) = {D}")
        break
    discs[D] = d
else:
    print(f"  No collisions among {len(discs)} squarefree d ∈ [-100, 100].")
    print(f"  Discriminant map is injective (as proved in Lean).")

print()

# ============================================================
# Demo 6: Character Sum Conjecture Test
# ============================================================
print("=" * 60)
print("DEMO 6: Character Sum Bound |S_N| ≤ √|D| · log(|D|)")
print("=" * 60)
print()

from math import sqrt, log

violations = 0
for d in range(-50, 51):
    if d == 0 or not is_squarefree(d):
        continue
    D = quad_disc(d)
    if abs(D) <= 2:
        continue
    bound = sqrt(abs(D)) * log(abs(D))
    partial_sum = 0
    max_sum = 0
    for n in range(1, abs(D) * 10 + 1):
        if n % 2 == 0:
            # Use Kronecker extension
            partial_sum += kronecker_character(D, n)
        elif gcd(n, abs(D)) > 1:
            pass  # χ(n) = 0
        else:
            partial_sum += jacobi_symbol(D, n)
        max_sum = max(max_sum, abs(partial_sum))
    
    status = "✓" if max_sum <= bound else "✗ VIOLATION"
    if max_sum > bound:
        violations += 1
    if abs(d) <= 10:  # Print details for small d
        print(f"  D = {D:>4}: max |S_N| = {max_sum:>5.0f}, bound = {bound:>6.1f}  {status}")

print(f"\n  Violations found: {violations}")
print(f"  Conjecture {'SUPPORTED' if violations == 0 else 'VIOLATED'} for |d| ≤ 50")

print()
print("=" * 60)
print("All demos complete.")
print("=" * 60)


#!/usr/bin/env python3
"""
Visualization: Character Values Heatmap

Displays the Jacobi symbol J(D, p) as a heatmap where rows are
discriminants (shapes) and columns are primes (evaluation points).
Red = split (+1), blue = inert (-1), gray = ramified (0).
"""

import matplotlib.pyplot as plt
import matplotlib.colors as mcolors
import numpy as np
from math import gcd


def jacobi_symbol(a: int, n: int) -> int:
    if n <= 0 or n % 2 == 0:
        raise ValueError(f"n must be odd and positive, got {n}")
    a = a % n
    result = 1
    while a != 0:
        while a % 2 == 0:
            a //= 2
            if n % 8 in (3, 5):
                result = -result
        a, n = n, a
        if a % 4 == 3 and n % 4 == 3:
            result = -result
        a = a % n
    return result if n == 1 else 0


def quad_disc(d: int) -> int:
    return d if d % 4 == 1 else 4 * d


def is_squarefree(n: int) -> bool:
    if n == 0:
        return False
    n = abs(n)
    for p in range(2, int(n**0.5) + 1):
        if n % (p * p) == 0:
            return False
    return True


def sieve_primes(n: int) -> list:
    is_prime = [True] * (n + 1)
    is_prime[0] = is_prime[1] = False
    for i in range(2, int(n**0.5) + 1):
        if is_prime[i]:
            for j in range(i*i, n + 1, i):
                is_prime[j] = False
    return [i for i in range(2, n + 1) if is_prime[i]]


# Parameters
d_values = [d for d in range(-20, 21) if d != 0 and is_squarefree(d)]
primes = [p for p in sieve_primes(60) if p > 2]

# Build heatmap data
D_values = [quad_disc(d) for d in d_values]
data = np.zeros((len(d_values), len(primes)))

for i, d in enumerate(d_values):
    D = quad_disc(d)
    for j, p in enumerate(primes):
        data[i, j] = jacobi_symbol(D, p)

# Create figure
fig, ax = plt.subplots(figsize=(14, 10))

# Custom colormap: blue (-1), light gray (0), red (+1)
cmap = mcolors.ListedColormap(['#3366CC', '#DDDDDD', '#CC3333'])
bounds = [-1.5, -0.5, 0.5, 1.5]
norm = mcolors.BoundaryNorm(bounds, cmap.N)

im = ax.imshow(data, cmap=cmap, norm=norm, aspect='auto', interpolation='nearest')

# Labels
ax.set_xticks(range(len(primes)))
ax.set_xticklabels([str(p) for p in primes], fontsize=8)
ax.set_yticks(range(len(d_values)))
ax.set_yticklabels([f"d={d}, D={quad_disc(d)}" for d in d_values], fontsize=7)

ax.set_xlabel("Prime p", fontsize=12)
ax.set_ylabel("Quadratic Field Q(√d), Discriminant D", fontsize=12)
ax.set_title("Shape-Color Correspondence: Splitting of Primes in Quadratic Fields\n"
             "Red = Split (+1) | Gray = Ramified (0) | Blue = Inert (-1)", fontsize=13)

# Colorbar
cbar = plt.colorbar(im, ax=ax, ticks=[-1, 0, 1])
cbar.set_label("Kronecker Symbol χ_D(p)")
cbar.set_ticklabels(["Inert (-1)", "Ramified (0)", "Split (+1)"])

plt.tight_layout()
plt.savefig("character_heatmap.png", dpi=150, bbox_inches='tight')
plt.show()
print("Saved to character_heatmap.png")


#!/usr/bin/env python3
"""
Visualization: Character Sum Trajectories

Plots the partial sums S_N = Σ_{n=1}^{N} χ_D(n) for several discriminants D,
showing the bounded oscillation predicted by the Pólya-Vinogradov inequality.
"""

import matplotlib.pyplot as plt
import numpy as np
from math import gcd, sqrt, log


def jacobi_symbol(a: int, n: int) -> int:
    if n <= 0 or n % 2 == 0:
        raise ValueError(f"n must be odd and positive, got {n}")
    a = a % n
    result = 1
    while a != 0:
        while a % 2 == 0:
            a //= 2
            if n % 8 in (3, 5):
                result = -result
        a, n = n, a
        if a % 4 == 3 and n % 4 == 3:
            result = -result
        a = a % n
    return result if n == 1 else 0


def quad_disc(d: int) -> int:
    return d if d % 4 == 1 else 4 * d


def character_value(D: int, n: int) -> int:
    if n <= 0:
        return 0
    if gcd(n, abs(D)) > 1:
        return 0
    # Factor out powers of 2
    temp = n
    twos = 0
    while temp % 2 == 0:
        temp //= 2
        twos += 1
    
    chi = 1
    if twos > 0:
        if D % 2 == 0:
            return 0
        chi_2 = 1 if D % 8 in (1, 7) else -1
        chi = chi_2 ** twos
    
    if temp > 1:
        chi *= jacobi_symbol(D, temp)
    
    return chi


# Parameters
discriminants = [
    (-1, -4, "Q(√-1)"),
    (2, 8, "Q(√2)"),
    (-3, -3, "Q(√-3)"),
    (5, 5, "Q(√5)"),
    (-7, -7, "Q(√-7)"),
    (13, 13, "Q(√13)"),
]

N_max = 500

fig, axes = plt.subplots(2, 3, figsize=(15, 8))
axes = axes.flatten()

for idx, (d, D, label) in enumerate(discriminants):
    ax = axes[idx]
    
    # Compute partial sums
    partial_sums = []
    running = 0
    for n in range(1, N_max + 1):
        running += character_value(D, n)
        partial_sums.append(running)
    
    ns = np.arange(1, N_max + 1)
    ax.plot(ns, partial_sums, linewidth=0.8, color='#2244AA', alpha=0.8)
    
    # Pólya-Vinogradov bound
    if abs(D) > 1:
        bound = sqrt(abs(D)) * log(abs(D))
        ax.axhline(y=bound, color='red', linestyle='--', alpha=0.5, linewidth=1)
        ax.axhline(y=-bound, color='red', linestyle='--', alpha=0.5, linewidth=1)
    
    ax.axhline(y=0, color='gray', linestyle='-', alpha=0.3)
    ax.set_title(f"{label}, D={D}", fontsize=11)
    ax.set_xlabel("N")
    ax.set_ylabel("S_N = Σχ_D(n)")
    ax.set_xlim(1, N_max)

plt.suptitle("Character Sum Trajectories: Bounded Oscillation\n"
             "Red dashes = Pólya-Vinogradov bound √|D|·log|D|", fontsize=13)
plt.tight_layout()
plt.savefig("character_sums.png", dpi=150, bbox_inches='tight')
plt.show()
print("Saved to character_sums.png")


#!/usr/bin/env python3
"""
Visualization: Quadratic Reciprocity as Shape-Color Duality

Shows the symmetry J(a,b) vs J(b,a) for coprime odd integers,
highlighting the correction sign (-1)^((a/2)(b/2)).
"""

import matplotlib.pyplot as plt
import numpy as np
from math import gcd


def jacobi_symbol(a: int, n: int) -> int:
    if n <= 0 or n % 2 == 0:
        return 0
    a = a % n
    result = 1
    while a != 0:
        while a % 2 == 0:
            a //= 2
            if n % 8 in (3, 5):
                result = -result
        a, n = n, a
        if a % 4 == 3 and n % 4 == 3:
            result = -result
        a = a % n
    return result if n == 1 else 0


# Build the reciprocity matrix
N = 30
odds = list(range(3, 2 * N + 4, 2))  # odd numbers from 3 to ~60

# Matrix 1: J(a, b)
# Matrix 2: J(b, a)  
# Matrix 3: Product J(a,b)*J(b,a) vs (-1)^(...)

fig, axes = plt.subplots(1, 3, figsize=(18, 6))

n = len(odds)
mat_Jab = np.zeros((n, n))
mat_Jba = np.zeros((n, n))
mat_product = np.zeros((n, n))

for i, a in enumerate(odds):
    for j, b in enumerate(odds):
        if gcd(a, b) == 1:
            mat_Jab[i, j] = jacobi_symbol(a, b)
            mat_Jba[i, j] = jacobi_symbol(b, a)
            product = jacobi_symbol(a, b) * jacobi_symbol(b, a)
            expected = (-1) ** ((a // 2) * (b // 2))
            mat_product[i, j] = 1 if product == expected else -1
        else:
            mat_Jab[i, j] = 0
            mat_Jba[i, j] = 0
            mat_product[i, j] = 0

import matplotlib.colors as mcolors
cmap = mcolors.ListedColormap(['#3366CC', '#EEEEEE', '#CC3333'])
bounds = [-1.5, -0.5, 0.5, 1.5]
norm = mcolors.BoundaryNorm(bounds, cmap.N)

axes[0].imshow(mat_Jab, cmap=cmap, norm=norm, aspect='equal', interpolation='nearest')
axes[0].set_title("Shape View: J(a, b)", fontsize=12)
axes[0].set_xlabel("b (odd)")
axes[0].set_ylabel("a (odd)")

axes[1].imshow(mat_Jba, cmap=cmap, norm=norm, aspect='equal', interpolation='nearest')
axes[1].set_title("Color View: J(b, a)", fontsize=12)
axes[1].set_xlabel("b (odd)")

cmap2 = mcolors.ListedColormap(['#FF6600', '#EEEEEE', '#00AA00'])
axes[2].imshow(mat_product, cmap=cmap2, norm=norm, aspect='equal', interpolation='nearest')
axes[2].set_title("Reciprocity Check\nGreen = verified, Gray = coprime", fontsize=12)
axes[2].set_xlabel("b (odd)")

for ax in axes:
    step = max(1, n // 8)
    ax.set_xticks(range(0, n, step))
    ax.set_xticklabels([str(odds[i]) for i in range(0, n, step)], fontsize=8)
    ax.set_yticks(range(0, n, step))
    ax.set_yticklabels([str(odds[i]) for i in range(0, n, step)], fontsize=8)

plt.suptitle("Quadratic Reciprocity as Shape-Color Duality", fontsize=14, y=1.02)
plt.tight_layout()
plt.savefig("reciprocity_duality.png", dpi=150, bbox_inches='tight')
plt.show()
print("Saved to reciprocity_duality.png")
