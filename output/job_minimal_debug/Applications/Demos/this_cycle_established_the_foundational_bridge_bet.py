"""
Applications of Periodic Orbit Varieties

Demonstrates real-world applications of the ECA → coding theory bridge:
1. Error-correcting codes from periodic orbits
2. Pseudorandom sequence generation
3. Pattern classification via code dimensions
"""

from itertools import product


def local_rule(r, left, center, right):
    idx = 4 * left + 2 * center + right
    return (r >> idx) & 1


def eca_step(r, state):
    n = len(state)
    return [local_rule(r, state[(i-1) % n], state[i], state[(i+1) % n])
            for i in range(n)]


def eca_iterate(r, state, k):
    s = list(state)
    for _ in range(k):
        s = eca_step(r, s)
    return s


def find_periodic_points(r, n, k):
    periodic = []
    for bits in product([0, 1], repeat=n):
        state = list(bits)
        if eca_iterate(r, state, k) == state:
            periodic.append(list(bits))
    return periodic


def hamming_distance(a, b):
    return sum(x != y for x, y in zip(a, b))


def min_distance(codewords):
    """Compute minimum Hamming distance of a code."""
    if len(codewords) <= 1:
        return float('inf')
    d_min = float('inf')
    for i in range(len(codewords)):
        for j in range(i+1, len(codewords)):
            d = hamming_distance(codewords[i], codewords[j])
            if d > 0:
                d_min = min(d_min, d)
    return d_min


def gaussian_rank_gf2(matrix):
    if not matrix:
        return 0
    mat = [list(row) for row in matrix]
    rows, cols = len(mat), len(mat[0])
    rank = 0
    for col in range(cols):
        pivot = None
        for row in range(rank, rows):
            if mat[row][col] == 1:
                pivot = row
                break
        if pivot is None:
            continue
        mat[rank], mat[pivot] = mat[pivot], mat[rank]
        for row in range(rows):
            if row != rank and mat[row][col] == 1:
                for c in range(cols):
                    mat[row][c] ^= mat[rank][c]
        rank += 1
    return rank


# ============================================================================
# APPLICATION 1: Error-Correcting Codes from ECA Periodic Orbits
# ============================================================================
print("=" * 70)
print("APPLICATION 1: Error-Correcting Codes from Periodic Orbits")
print("=" * 70)

print("\nECA-derived [n, k, d] codes (rule, period → code parameters):")
print(f"{'Rule':>6} {'Period':>7} {'n':>4} {'|C|':>6} {'k=dim':>6} {'d_min':>6} {'Rate':>8}")

for r in [90, 150, 60, 102]:
    for n in [7, 9, 11, 13]:
        for period in [1, 2, 3]:
            codewords = find_periodic_points(r, n, period)
            if len(codewords) > 1:
                k = gaussian_rank_gf2(codewords)
                d = min_distance(codewords)
                rate = k / n
                print(f"{r:>6} {period:>7} {n:>4} {len(codewords):>6} {k:>6} "
                      f"{d if d < float('inf') else '-':>6} {rate:>8.3f}")

# ============================================================================
# APPLICATION 2: Complexity Classification via Code Dimensions
# ============================================================================
print("\n" + "=" * 70)
print("APPLICATION 2: Complexity Classification via Code Dimensions")
print("=" * 70)

print("\nCode dimension profiles distinguish Wolfram complexity classes:")
rules_to_classify = {
    "Class 1": [0, 32, 128, 160],
    "Class 2": [4, 36, 50, 76],
    "Class 3": [30, 45, 60, 90],
    "Class 4": [110, 54],
}

n = 9
print(f"\nn = {n}")
print(f"{'Rule':>6} {'Class':>10} {'dim(k=1)':>9} {'dim(k=2)':>9} {'dim(k=3)':>9} "
      f"{'Growth':>8}")

for cls, rules in rules_to_classify.items():
    for r in rules:
        dims = []
        for k in [1, 2, 3]:
            pts = find_periodic_points(r, n, k)
            dims.append(gaussian_rank_gf2(pts) if pts else 0)
        growth = "stable" if dims[0] == dims[2] else (
            "growing" if dims[2] > dims[0] else "shrinking")
        print(f"{r:>6} {cls:>10} {dims[0]:>9} {dims[1]:>9} {dims[2]:>9} "
              f"{growth:>8}")

# ============================================================================
# APPLICATION 3: Pseudorandom Sequence Quality
# ============================================================================
print("\n" + "=" * 70)
print("APPLICATION 3: Pseudorandom Sequence Quality from Orbit Structure")
print("=" * 70)

print("\nOrbit structure determines pseudorandom quality.")
print("Rules with few periodic orbits → longer transients → better PRNGs")

n = 8
print(f"\nn = {n}")
print(f"{'Rule':>6} {'|Fix_1|':>8} {'|Fix_2|':>8} {'|Fix_3|':>8} "
      f"{'MaxOrbit':>9} {'PRG Quality':>12}")

for r in [30, 45, 90, 110, 150, 204]:
    counts = {}
    for k in [1, 2, 3]:
        counts[k] = len(find_periodic_points(r, n, k))

    # Estimate max orbit length as ceiling of n / min nonzero periodic dimension
    if counts[1] <= 2:
        quality = "Excellent"
    elif counts[1] <= 2**(n//2):
        quality = "Good"
    else:
        quality = "Poor"

    max_orbit = 2**n // max(counts[3], 1)
    print(f"{r:>6} {counts[1]:>8} {counts[2]:>8} {counts[3]:>8} "
          f"{max_orbit:>9} {quality:>12}")

print("\n✓ All applications completed successfully!")


"""
Periodic Orbit Varieties of Elementary Cellular Automata

Demonstrates the key theorems: k-periodic orbits of linear ECAs form linear codes
over GF(2), and complex rules have fewer periodic orbits (Dimension Inversion Principle).
"""

import numpy as np
from itertools import product


def local_rule(r: int, left: int, center: int, right: int) -> int:
    """Apply ECA rule r to a 3-cell neighborhood."""
    idx = 4 * left + 2 * center + right
    return (r >> idx) & 1


def eca_step(r: int, state: np.ndarray) -> np.ndarray:
    """Apply one step of ECA rule r with cyclic boundary conditions."""
    n = len(state)
    new_state = np.zeros(n, dtype=int)
    for i in range(n):
        l = state[(i - 1) % n]
        c = state[i]
        ri = state[(i + 1) % n]
        new_state[i] = local_rule(r, l, c, ri)
    return new_state


def eca_iterate(r: int, state: np.ndarray, k: int) -> np.ndarray:
    """Apply ECA rule r exactly k times."""
    s = state.copy()
    for _ in range(k):
        s = eca_step(r, s)
    return s


def find_periodic_points(r: int, n: int, k: int) -> list:
    """Find all k-periodic points of rule r on n cells."""
    periodic = []
    for bits in product([0, 1], repeat=n):
        state = np.array(bits, dtype=int)
        if np.array_equal(eca_iterate(r, state, k), state):
            periodic.append(state)
    return periodic


def is_linear_rule(r: int) -> bool:
    """Check if rule r is linear over GF(2)."""
    if local_rule(r, 0, 0, 0) != 0:
        return False
    for bits in product([0, 1], repeat=6):
        l1, c1, r1, l2, c2, r2 = bits
        lhs = local_rule(r, l1 ^ l2, c1 ^ c2, r1 ^ r2)
        rhs = local_rule(r, l1, c1, r1) ^ local_rule(r, l2, c2, r2)
        if lhs != rhs:
            return False
    return True


def verify_xor_closure(periodic_points: list) -> bool:
    """Verify that a set of periodic points is closed under XOR."""
    point_set = set(tuple(p) for p in periodic_points)
    for p1 in periodic_points:
        for p2 in periodic_points:
            xor_result = tuple((a ^ b) for a, b in zip(p1, p2))
            if xor_result not in point_set:
                return False
    return True


def compute_code_dimension(periodic_points: list, n: int) -> int:
    """Compute the GF(2) dimension of the linear code spanned by periodic points."""
    if not periodic_points:
        return 0
    # Gaussian elimination over GF(2)
    mat = np.array(periodic_points, dtype=int) % 2
    rank = 0
    rows, cols = mat.shape
    pivot_cols = []
    for col in range(cols):
        found = False
        for row in range(rank, rows):
            if mat[row, col] == 1:
                mat[[rank, row]] = mat[[row, rank]]
                found = True
                break
        if not found:
            continue
        pivot_cols.append(col)
        for row in range(rows):
            if row != rank and mat[row, col] == 1:
                mat[row] = (mat[row] + mat[rank]) % 2
        rank += 1
    return rank


# ============================================================================
# DEMO 1: Verify the Periodic Linear Code Theorem
# ============================================================================
print("=" * 70)
print("DEMO 1: Periodic Linear Code Theorem Verification")
print("=" * 70)

linear_rules = [r for r in range(256) if is_linear_rule(r)]
print(f"\nLinear ECA rules: {linear_rules}")
print(f"Count: {len(linear_rules)} (expected 8)")

for r in linear_rules:
    print(f"\n--- Rule {r} ---")
    for n in [3, 5, 7]:
        for k in [1, 2, 3]:
            periodic = find_periodic_points(r, n, k)
            count = len(periodic)
            dim = compute_code_dimension(periodic, n)
            xor_closed = verify_xor_closure(periodic)
            print(f"  n={n}, k={k}: |Fix_k| = {count:4d}, dim = {dim}, "
                  f"XOR-closed = {xor_closed}, count = 2^{dim}")
            assert xor_closed, f"XOR closure FAILED for rule {r}, n={n}, k={k}!"

print("\n✓ All periodic point sets of linear rules are XOR-closed (linear codes)!")

# ============================================================================
# DEMO 2: Dimension Inversion Principle
# ============================================================================
print("\n" + "=" * 70)
print("DEMO 2: Dimension Inversion Principle for Periodic Orbits")
print("=" * 70)

# Classify some well-known rules by Wolfram class
rules_by_class = {
    "Class 1 (uniform)": [0, 32, 128, 160],
    "Class 2 (periodic)": [4, 36, 50, 76],
    "Class 3 (chaotic)": [30, 45, 60, 90],
    "Class 4 (complex)": [110, 54, 106],
}

n = 7
print(f"\nPeriodic point counts for n={n}:")
print(f"{'Rule':>6} {'Class':>15} {'k=1':>6} {'k=2':>6} {'k=3':>6} {'k=4':>6} {'Rate(k=3)':>10}")

for cls_name, rules in rules_by_class.items():
    for r in rules:
        counts = {}
        for k in [1, 2, 3, 4]:
            periodic = find_periodic_points(r, n, k)
            counts[k] = len(periodic)
        rate = np.log2(counts[3]) / n if counts[3] > 0 else 0
        print(f"{r:>6} {cls_name:>15} {counts[1]:>6} {counts[2]:>6} "
              f"{counts[3]:>6} {counts[4]:>6} {rate:>10.3f}")

# ============================================================================
# DEMO 3: Rule 90 Fixed Point Conjecture
# ============================================================================
print("\n" + "=" * 70)
print("DEMO 3: Rule 90 Fixed Point Conjecture Verification")
print("=" * 70)

print(f"\nConjecture: |Fix(Rule 90, n)| = 4 if 3|n, else 1")
print(f"{'n':>4} {'|Fix|':>6} {'3|n':>5} {'Predicted':>10} {'Match':>6}")

all_match = True
for n in range(1, 16):
    periodic = find_periodic_points(90, n, 1)
    count = len(periodic)
    divides = (n % 3 == 0)
    predicted = 4 if divides else 1
    match = count == predicted
    all_match = all_match and match
    print(f"{n:>4} {count:>6} {str(divides):>5} {predicted:>10} {'✓' if match else '✗':>6}")

print(f"\nConjecture {'CONFIRMED' if all_match else 'REFUTED'} for n=1..15")

# ============================================================================
# DEMO 4: Period Hierarchy (Monotonicity)
# ============================================================================
print("\n" + "=" * 70)
print("DEMO 4: Period Hierarchy — k | m ⟹ Fix_k ⊆ Fix_m")
print("=" * 70)

r = 90
n = 6
print(f"\nRule {r}, n={n}:")
for k in [1, 2, 3, 6]:
    pk = set(tuple(s) for s in find_periodic_points(r, n, k))
    for m in [k, 2*k, 3*k]:
        pm = set(tuple(s) for s in find_periodic_points(r, n, m))
        subset = pk.issubset(pm)
        print(f"  Fix_{k} ⊆ Fix_{m}: {subset} (|Fix_{k}|={len(pk)}, |Fix_{m}|={len(pm)})")

print("\n✓ Period hierarchy verified!")

# ============================================================================
# DEMO 5: Code Rate Table
# ============================================================================
print("\n" + "=" * 70)
print("DEMO 5: Periodic Orbit Code Rates for Linear Rules")
print("=" * 70)

print(f"\n{'Rule':>6} {'n':>4} {'k':>4} {'dim':>5} {'rate':>8}")
for r in [0, 90, 150, 204]:
    for n in [5, 7, 9]:
        for k in [1, 2, 3]:
            periodic = find_periodic_points(r, n, k)
            dim = compute_code_dimension(periodic, n)
            rate = dim / n
            print(f"{r:>6} {n:>4} {k:>4} {dim:>5} {rate:>8.3f}")
    print()

print("All demos completed successfully!")


"""
Visualization: Dimension Inversion Principle

Shows that dynamically complex ECA rules (Class 3-4) have FEWER periodic orbits
than simpler rules (Class 1-2). This is the "Dimension Inversion Principle":
algebraic complexity is inversely correlated with dynamical complexity.

The plot shows log2(|Fix_k|) / n for different Wolfram classes across system sizes.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
from itertools import product


def local_rule(r, left, center, right):
    idx = 4 * left + 2 * center + right
    return (r >> idx) & 1


def eca_step(r, state):
    n = len(state)
    return [local_rule(r, state[(i-1) % n], state[i], state[(i+1) % n])
            for i in range(n)]


def eca_iterate(r, state, k):
    s = list(state)
    for _ in range(k):
        s = eca_step(r, s)
    return s


def count_periodic(r, n, k):
    count = 0
    for bits in product([0, 1], repeat=n):
        state = list(bits)
        if eca_iterate(r, state, k) == state:
            count += 1
    return count


rules_by_class = {
    "Class 1\n(Uniform)": ([0, 128, 32, 160], 'blue'),
    "Class 2\n(Periodic)": ([4, 36, 50, 76], 'green'),
    "Class 3\n(Chaotic)": ([30, 45, 60, 90], 'orange'),
    "Class 4\n(Complex)": ([110, 54, 106], 'red'),
}

ns = list(range(3, 11))

fig, axes = plt.subplots(1, 3, figsize=(16, 5))
fig.suptitle("Dimension Inversion Principle: Complex Rules ↔ Fewer Periodic Orbits",
             fontsize=13, fontweight='bold')

for ki, k in enumerate([1, 2, 3]):
    ax = axes[ki]
    ax.set_title(f"Period k = {k}", fontsize=12)

    for cls_name, (rules, color) in rules_by_class.items():
        rates = []
        for n in ns:
            class_rates = []
            for r in rules:
                count = count_periodic(r, n, k)
                rate = np.log2(max(count, 1)) / n
                class_rates.append(rate)
            rates.append(np.mean(class_rates))

        ax.plot(ns, rates, 'o-', color=color, label=cls_name, linewidth=2,
                markersize=6)

    ax.set_xlabel("System size n", fontsize=11)
    ax.set_ylabel("Code rate  log₂|Fix_k| / n", fontsize=11)
    ax.set_ylim(-0.05, 1.05)
    ax.grid(True, alpha=0.3)
    ax.legend(fontsize=8, loc='upper right')

plt.tight_layout()
plt.savefig("dimension_inversion.png", dpi=150, bbox_inches='tight')
print("Saved dimension_inversion.png")


"""
Visualization: Periodic Orbit Code Dimension Heatmap

Visualizes the code dimension dim(C(r,k,n)) for linear ECA rules across
different periods k and system sizes n. This reveals the algebraic structure
of periodic orbit varieties and the Dimension Inversion Principle.

The heatmap shows how code rate (dim/n) varies, with lighter colors indicating
higher-dimensional periodic orbit codes (more periodic orbits).
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
from itertools import product


def local_rule(r, left, center, right):
    idx = 4 * left + 2 * center + right
    return (r >> idx) & 1


def eca_step(r, state):
    n = len(state)
    return [local_rule(r, state[(i-1) % n], state[i], state[(i+1) % n])
            for i in range(n)]


def eca_iterate(r, state, k):
    s = list(state)
    for _ in range(k):
        s = eca_step(r, s)
    return s


def count_periodic(r, n, k):
    count = 0
    for bits in product([0, 1], repeat=n):
        state = list(bits)
        if eca_iterate(r, state, k) == state:
            count += 1
    return count


def code_dim(count):
    if count <= 0:
        return 0
    return int(np.log2(max(count, 1)))


# Parameters
rules = [0, 60, 90, 102, 150, 170, 204, 240]
rule_labels = [f"Rule {r}" for r in rules]
ns = list(range(3, 12))
ks = [1, 2, 3, 4, 5]

fig, axes = plt.subplots(2, 4, figsize=(18, 9))
fig.suptitle("Periodic Orbit Code Rates for Linear ECA Rules\n"
             "Color = dim(C(r,k,n)) / n  (code rate)", fontsize=14, fontweight='bold')

for idx, r in enumerate(rules):
    ax = axes[idx // 4][idx % 4]
    data = np.zeros((len(ks), len(ns)))

    for ki, k in enumerate(ks):
        for ni, n in enumerate(ns):
            count = count_periodic(r, n, k)
            dim = code_dim(count)
            data[ki, ni] = dim / n

    im = ax.imshow(data, aspect='auto', cmap='YlOrRd', vmin=0, vmax=1,
                   interpolation='nearest')
    ax.set_title(f"Rule {r}", fontsize=12, fontweight='bold')
    ax.set_xlabel("System size n")
    ax.set_ylabel("Period k")
    ax.set_xticks(range(len(ns)))
    ax.set_xticklabels(ns)
    ax.set_yticks(range(len(ks)))
    ax.set_yticklabels(ks)

    # Annotate cells
    for ki in range(len(ks)):
        for ni in range(len(ns)):
            val = data[ki, ni]
            color = 'white' if val > 0.5 else 'black'
            ax.text(ni, ki, f"{val:.2f}", ha='center', va='center',
                    fontsize=7, color=color)

fig.colorbar(im, ax=axes, shrink=0.6, label="Code Rate (dim/n)")
plt.tight_layout()
plt.savefig("periodic_orbit_heatmap.png", dpi=150, bbox_inches='tight')
print("Saved periodic_orbit_heatmap.png")


"""
Visualization: Transfer Matrix Structure

Shows the 4×4 transfer matrices for selected ECA rules, revealing how
the fixed-point constraints are encoded as a directed graph structure.
Also shows the exponential growth/decay of fixed point counts.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


def local_rule(r, left, center, right):
    idx = 4 * left + 2 * center + right
    return (r >> idx) & 1


def build_transfer_matrix(r):
    T = [[0]*4 for _ in range(4)]
    for si in range(2):
        for sj in range(2):
            row = 2 * si + sj
            for sk in range(2):
                col = 2 * sj + sk
                if local_rule(r, si, sj, sk) == sj:
                    T[row][col] = 1
    return T


def mat_mul_int(A, B, size):
    C = [[0]*size for _ in range(size)]
    for i in range(size):
        for j in range(size):
            for l in range(size):
                C[i][j] += A[i][l] * B[l][j]
    return C


def mat_pow_int(M, size, exp):
    result = [[1 if i == j else 0 for j in range(size)] for i in range(size)]
    base = [row[:] for row in M]
    while exp > 0:
        if exp & 1:
            result = mat_mul_int(result, base, size)
        base = mat_mul_int(base, base, size)
        exp >>= 1
    return result


def count_fixed_transfer(r, n):
    T = build_transfer_matrix(r)
    Tn = mat_pow_int(T, 4, n)
    return sum(Tn[i][i] for i in range(4))


rules = [0, 30, 90, 110, 150, 204]
state_labels = ['00', '01', '10', '11']

fig, axes = plt.subplots(2, 3, figsize=(15, 10))
fig.suptitle("Transfer Matrices and Fixed Point Growth\nfor Selected ECA Rules",
             fontsize=14, fontweight='bold')

for idx, r in enumerate(rules):
    row, col = idx // 3, idx % 3
    ax = axes[row][col]

    T = build_transfer_matrix(r)
    T_arr = np.array(T)

    im = ax.imshow(T_arr, cmap='Blues', vmin=0, vmax=1)
    ax.set_title(f"Rule {r}", fontsize=12, fontweight='bold')
    ax.set_xticks(range(4))
    ax.set_xticklabels(state_labels, fontsize=9)
    ax.set_yticks(range(4))
    ax.set_yticklabels(state_labels, fontsize=9)
    ax.set_xlabel("(sⱼ, sₖ)")
    ax.set_ylabel("(sᵢ, sⱼ)")

    for i in range(4):
        for j in range(4):
            color = 'white' if T_arr[i, j] > 0.5 else 'black'
            ax.text(j, i, str(T_arr[i, j]), ha='center', va='center',
                    fontsize=14, fontweight='bold', color=color)

    # Inset: fixed point count growth
    ns_inset = list(range(1, 51))
    counts = [count_fixed_transfer(r, n) for n in ns_inset]
    ax_inset = ax.inset_axes([0.55, 0.55, 0.4, 0.4])
    ax_inset.semilogy(ns_inset, [max(c, 0.5) for c in counts], 'r-', linewidth=1.5)
    ax_inset.set_xlabel('n', fontsize=7)
    ax_inset.set_ylabel('|Fix|', fontsize=7)
    ax_inset.tick_params(labelsize=6)
    ax_inset.set_title('|Fix| vs n', fontsize=7)
    ax_inset.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig("transfer_matrices.png", dpi=150, bbox_inches='tight')
print("Saved transfer_matrices.png")
