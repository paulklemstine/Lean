#!/usr/bin/env python3
"""
Certified Mathematical Significance Theory — Applications

Real-world applications of the significance framework:
1. Library quality assessment
2. Contribution ranking
3. Conservative extension detection
4. Adaptive quality gates
"""

from algorithms import (
    ProofTerm, AxiomTerm, AppTerm, LamTerm, PairTerm,
    proof_size, proof_height,
    compute_significance, compute_significance_from_proofs,
    compute_package_depth, is_master_class_contribution,
    evaluate_quality_gate, check_strict_advancement,
    make_dependency_closure, ClosureOperator
)
import random
random.seed(123)


def random_proof(max_depth: int = 5) -> ProofTerm:
    """Generate a random proof term."""
    if max_depth <= 1 or random.random() < 0.3:
        return AxiomTerm(random.randint(0, 99))
    c = random.choice(["app", "lam", "pair"])
    if c == "app":
        return AppTerm(random_proof(max_depth - 1), random_proof(max_depth - 1))
    elif c == "lam":
        return LamTerm(random_proof(max_depth - 1))
    else:
        return PairTerm(random_proof(max_depth - 1), random_proof(max_depth - 1))


# ═══════════════════════════════════════════════════════════════════════════
# Application 1: Library Quality Assessment
# ═══════════════════════════════════════════════════════════════════════════

print("=" * 70)
print("APPLICATION 1: Library Quality Assessment")
print("=" * 70)

# Simulate three libraries of different quality
libraries = {
    "Shallow Library": [random_proof(2) for _ in range(20)],
    "Mixed Library": [random_proof(random.randint(2, 6)) for _ in range(20)],
    "Deep Library": [random_proof(6) for _ in range(20)],
}

print(f"\n{'Library':<20} {'Theorems':>8} {'Significance':>13} {'Avg Size':>9} "
      f"{'Max Size':>9} {'Avg Height':>11} {'Depth':>6}")
print("-" * 80)

for name, proofs_list in libraries.items():
    proofs = {i: p for i, p in enumerate(proofs_list)}
    K = set(proofs.keys())
    sizes = [proof_size(p) for p in proofs_list]
    heights = [proof_height(p) for p in proofs_list]
    sig = compute_significance_from_proofs(proofs, K)
    depth = compute_package_depth(proofs, K)
    print(f"{name:<20} {len(K):>8} {sig:>13} {sum(sizes)/len(sizes):>9.1f} "
          f"{max(sizes):>9} {sum(heights)/len(heights):>11.1f} {depth:>6}")

# Quality gate comparison
thresholds = [50, 200, 500, 1000]
print(f"\nQuality Gate Results:")
print(f"{'Library':<20}", end="")
for t in thresholds:
    print(f"  τ={t:>4}", end="")
print()
for name, proofs_list in libraries.items():
    proofs = {i: p for i, p in enumerate(proofs_list)}
    K = set(proofs.keys())
    weights = {i: proof_size(proofs[i]) for i in K}
    print(f"{name:<20}", end="")
    for t in thresholds:
        gate = evaluate_quality_gate(weights, t, K)
        symbol = "  ✓   " if gate else "  ✗   "
        print(symbol, end="")
    print()


# ═══════════════════════════════════════════════════════════════════════════
# Application 2: Contribution Ranking
# ═══════════════════════════════════════════════════════════════════════════

print("\n" + "=" * 70)
print("APPLICATION 2: Contribution Ranking")
print("=" * 70)

# Existing library
existing = {i: random_proof(4) for i in range(10)}
K = set(existing.keys())
weights = {i: proof_size(existing[i]) for i in K}
current_sig = compute_significance(weights, K)
current_depth = compute_package_depth(existing, K)

print(f"\nExisting library: {len(K)} theorems, significance = {current_sig}, "
      f"depth = {current_depth}")

# Candidate contributions
candidates = {10 + i: random_proof(random.randint(2, 8)) for i in range(5)}
print(f"\nCandidate Ranking:")
print(f"{'Candidate':>10} {'Size':>6} {'Height':>7} {'Δσ':>6} {'Master?':>8}")
print("-" * 45)

ranked = sorted(candidates.items(), key=lambda x: proof_size(x[1]), reverse=True)
for cid, proof in ranked:
    s = proof_size(proof)
    h = proof_height(proof)
    delta_sig = s  # For additive significance, Δσ = w(a) = size(π(a))
    master = s > current_depth
    print(f"{cid:>10} {s:>6} {h:>7} {delta_sig:>6} {'★ YES' if master else 'no':>8}")


# ═══════════════════════════════════════════════════════════════════════════
# Application 3: Conservative Extension Detection
# ═══════════════════════════════════════════════════════════════════════════

print("\n" + "=" * 70)
print("APPLICATION 3: Conservative Extension Detection")
print("=" * 70)

# Dependency DAG for a small theory
deps = {
    0: set(),           # Axiom 0 (no deps)
    1: set(),           # Axiom 1
    2: {0},             # Depends on 0
    3: {0, 1},          # Depends on 0 and 1
    4: {2, 3},          # Depends on 2 and 3
    5: {1},             # Depends on 1
    6: {4, 5},          # Depends on 4 and 5
    7: {0},             # Depends on 0
    8: {6, 7},          # Depends on 6 and 7
    9: {3},             # Depends on 3
}

cl = make_dependency_closure(deps)

# Start with a base theory and check extensions
base = {0, 1, 2}
print(f"\nBase theory: {sorted(base)}")
print(f"Closure: {sorted(cl.close(base))}")

for candidate in [3, 4, 5, 6, 7, 8, 9]:
    is_nc = cl.is_nonconservative(base, candidate)
    cl_base = cl.close(base)
    cl_ext = cl.close(base | {candidate})
    new_theorems = cl_ext - cl_base
    status = "NONCONSERVATIVE" if is_nc else "conservative"
    print(f"  Add {candidate}: {status:>16} "
          f"(new: {sorted(new_theorems) if new_theorems else '∅'})")


# ═══════════════════════════════════════════════════════════════════════════
# Application 4: Adaptive Quality Gates
# ═══════════════════════════════════════════════════════════════════════════

print("\n" + "=" * 70)
print("APPLICATION 4: Adaptive Quality Gates")
print("=" * 70)

# Threshold grows with library size: τ(n) = c·n requires average weight ≥ c
c_values = [3, 5, 10]

library_proofs = {i: random_proof(random.randint(2, 7)) for i in range(30)}
weights = {i: proof_size(library_proofs[i]) for i in library_proofs}

print(f"\nLibrary growth with adaptive thresholds:")
print(f"{'|K|':>5}", end="")
for c in c_values:
    print(f"  τ={c}·n (pass?)", end="")
print(f"  {'Avg weight':>10}")
print("-" * 75)

K = set()
for a in sorted(library_proofs.keys()):
    K.add(a)
    sig = compute_significance(weights, K)
    avg_w = sig / len(K)
    print(f"{len(K):>5}", end="")
    for c in c_values:
        threshold = c * len(K)
        gate = sig >= threshold
        print(f"  {'✓':>8}        " if gate else f"  {'✗':>8}        ", end="")
    print(f"  {avg_w:>10.1f}")
    if len(K) >= 15:
        break  # Show first 15 steps

print("\nKey insight: adaptive threshold τ(n) = c·n accepts iff average weight ≥ c.")
print("This prevents quality dilution from many shallow theorems.")


print("\n" + "=" * 70)
print("All applications complete.")
print("=" * 70)


#!/usr/bin/env python3
"""
Certified Mathematical Significance Theory — Demonstrations

Concrete numerical examples illustrating the theorems on significance
monotonicity, strict advancement, proof-term complexity, and quality gates.
"""

import random
random.seed(42)


# ── Proof Term Data Structure ────────────────────────────────────────────

class ProofTerm:
    """Abstract syntax tree for proof terms."""
    pass

class Axiom(ProofTerm):
    def __init__(self, n: int):
        self.n = n
    def __repr__(self):
        return f"Ax({self.n})"

class App(ProofTerm):
    def __init__(self, p: ProofTerm, q: ProofTerm):
        self.p, self.q = p, q
    def __repr__(self):
        return f"App({self.p}, {self.q})"

class Lam(ProofTerm):
    def __init__(self, p: ProofTerm):
        self.p = p
    def __repr__(self):
        return f"Lam({self.p})"

class Pair(ProofTerm):
    def __init__(self, p: ProofTerm, q: ProofTerm):
        self.p, self.q = p, q
    def __repr__(self):
        return f"Pair({self.p}, {self.q})"


def size(t: ProofTerm) -> int:
    if isinstance(t, Axiom):
        return 1
    elif isinstance(t, App):
        return size(t.p) + size(t.q) + 1
    elif isinstance(t, Lam):
        return size(t.p) + 1
    elif isinstance(t, Pair):
        return size(t.p) + size(t.q) + 1

def height(t: ProofTerm) -> int:
    if isinstance(t, Axiom):
        return 1
    elif isinstance(t, App):
        return max(height(t.p), height(t.q)) + 1
    elif isinstance(t, Lam):
        return height(t.p) + 1
    elif isinstance(t, Pair):
        return max(height(t.p), height(t.q)) + 1


def random_proof_term(max_depth: int = 5) -> ProofTerm:
    if max_depth <= 1 or random.random() < 0.3:
        return Axiom(random.randint(0, 9))
    choice = random.choice(["app", "lam", "pair"])
    if choice == "app":
        return App(random_proof_term(max_depth - 1), random_proof_term(max_depth - 1))
    elif choice == "lam":
        return Lam(random_proof_term(max_depth - 1))
    else:
        return Pair(random_proof_term(max_depth - 1), random_proof_term(max_depth - 1))


# ── Significance on Knowledge States ─────────────────────────────────────

def significance(weights: dict, K: set) -> int:
    """Significance of knowledge state K under weight function."""
    return sum(weights.get(a, 0) for a in K)


def quality_gate(weights: dict, threshold: int, K: set) -> bool:
    """Boolean quality gate: accepts if significance ≥ threshold."""
    return threshold <= significance(weights, K)


def package_depth(proofs: dict, K: set) -> int:
    """Maximum proof significance across all theorems in K."""
    if not K:
        return 0
    return max(size(proofs[a]) for a in K)


# ── Demo 1: Monotonicity of Significance ─────────────────────────────────

print("=" * 60)
print("DEMO 1: Significance Monotonicity")
print("=" * 60)

universe = list(range(10))
weights = {i: random.randint(1, 20) for i in universe}
print(f"Universe: {universe}")
print(f"Weights:  {weights}")

K = set()
print(f"\nBuilding knowledge state incrementally:")
for a in universe:
    old_sig = significance(weights, K)
    K.add(a)
    new_sig = significance(weights, K)
    print(f"  Add theorem {a} (weight {weights[a]}): "
          f"σ = {old_sig} → {new_sig}  "
          f"(Δ = +{new_sig - old_sig}, monotone: {new_sig >= old_sig})")

# Verify monotonicity over random subsets
print(f"\nVerifying monotonicity on 500 random subset pairs...")
violations = 0
for _ in range(500):
    k1 = random.randint(0, 10)
    k2 = random.randint(k1, 10)
    S1 = set(random.sample(universe, k1))
    S2 = S1 | set(random.sample(universe, min(k2, len(universe))))
    if significance(weights, S1) > significance(weights, S2):
        violations += 1
print(f"  Violations: {violations} / 500 (expected: 0)")


# ── Demo 2: Strict Advancement ────────────────────────────────────────────

print("\n" + "=" * 60)
print("DEMO 2: Strict Advancement via Positive-Weight Insertion")
print("=" * 60)

K = set()
for a in [3, 7, 1, 9, 5]:
    old_sig = significance(weights, K)
    K_new = K | {a}
    new_sig = significance(weights, K_new)
    strict = old_sig < new_sig
    print(f"  Insert theorem {a}: σ({sorted(K)}) = {old_sig} < "
          f"σ({sorted(K_new)}) = {new_sig}? {strict}")
    K = K_new


# ── Demo 3: Proof-Term Height ≤ Size ──────────────────────────────────────

print("\n" + "=" * 60)
print("DEMO 3: Height ≤ Size for Random Proof Terms")
print("=" * 60)

n_samples = 10000
all_valid = True
ratios = []
for _ in range(n_samples):
    t = random_proof_term(max_depth=8)
    s, h = size(t), height(t)
    if h > s:
        all_valid = False
    ratios.append(h / s)

print(f"  Tested {n_samples} random proof terms")
print(f"  height ≤ size in all cases: {all_valid}")
print(f"  Average height/size ratio: {sum(ratios)/len(ratios):.4f}")
print(f"  Min ratio: {min(ratios):.4f}, Max ratio: {max(ratios):.4f}")

# Show a few examples
print(f"\n  Sample proof terms:")
for _ in range(5):
    t = random_proof_term(max_depth=4)
    print(f"    {t}")
    print(f"      size = {size(t)}, height = {height(t)}, "
          f"height ≤ size: {height(t) <= size(t)}")


# ── Demo 4: Quality Gate ──────────────────────────────────────────────────

print("\n" + "=" * 60)
print("DEMO 4: Quality Gate Monotonicity")
print("=" * 60)

threshold = 50
print(f"Threshold τ = {threshold}")
K = set()
gate_passed = False
for a in universe:
    K.add(a)
    sig = significance(weights, K)
    gate = quality_gate(weights, threshold, K)
    status = "ACCEPT ✓" if gate else "REJECT ✗"
    if gate and not gate_passed:
        status += " ← first acceptance!"
        gate_passed = True
    print(f"  K = {sorted(K)}: σ = {sig}, gate: {status}")


# ── Demo 5: Package Depth ─────────────────────────────────────────────────

print("\n" + "=" * 60)
print("DEMO 5: Package Depth and Master-Class Contributions")
print("=" * 60)

proofs = {i: random_proof_term(max_depth=3 + i % 4) for i in universe}
print("Proof sizes:", {i: size(proofs[i]) for i in universe})

K = set()
for a in universe:
    old_depth = package_depth(proofs, K) if K else 0
    K.add(a)
    new_depth = package_depth(proofs, K)
    proof_size = size(proofs[a])
    is_master = proof_size > old_depth
    label = " ★ MASTER-CLASS" if is_master else ""
    print(f"  Add theorem {a} (proof size {proof_size}): "
          f"depth {old_depth} → {new_depth}{label}")


# ── Demo 6: Closure Operator ──────────────────────────────────────────────

print("\n" + "=" * 60)
print("DEMO 6: Closure Operators and Nonconservative Extension")
print("=" * 60)

# Simple closure: if you know theorem i, you also know all j < i
def closure(K: set) -> set:
    if not K:
        return set()
    return set(range(max(K) + 1))

K = {2, 5}
print(f"K = {sorted(K)}")
print(f"cl(K) = {sorted(closure(K))}")

a = 8
K_ext = K | {a}
print(f"K ∪ {{{a}}} = {sorted(K_ext)}")
print(f"cl(K ∪ {{{a}}}) = {sorted(closure(K_ext))}")
print(f"Nonconservative? cl(K) ⊊ cl(K ∪ {{{a}}}): "
      f"{closure(K) < closure(K_ext)}")
print(f"|cl(K)| = {len(closure(K))} < |cl(K ∪ {{{a}}})| = "
      f"{len(closure(K_ext))}: {len(closure(K)) < len(closure(K_ext))}")

# Conservative extension example
b = 3  # already in cl(K) = {0,1,2,3,4,5}
K_cons = K | {b}
print(f"\nK ∪ {{{b}}} = {sorted(K_cons)}")
print(f"cl(K ∪ {{{b}}}) = {sorted(closure(K_cons))}")
print(f"Conservative? cl(K) = cl(K ∪ {{{b}}}): "
      f"{closure(K) == closure(K_cons)}")


print("\n" + "=" * 60)
print("All demonstrations complete.")
print("=" * 60)


#!/usr/bin/env python3
"""
Certified Mathematical Significance Theory — Visualizations

Generates publication-quality charts as PNG files and base64 data URIs.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
import random
import base64
import io
import json

random.seed(42)
np.random.seed(42)

# Style
plt.rcParams.update({
    'figure.facecolor': 'white',
    'axes.facecolor': '#f8f9fa',
    'axes.grid': True,
    'grid.alpha': 0.3,
    'font.size': 11,
    'axes.titlesize': 14,
    'axes.labelsize': 12,
})

# ── Proof Term helpers ────────────────────────────────────────────────────

class PT:
    pass
class Ax(PT):
    def __init__(self, n=0): self.n = n
class Ap(PT):
    def __init__(self, p, q): self.p, self.q = p, q
class La(PT):
    def __init__(self, p): self.p = p
class Pa(PT):
    def __init__(self, p, q): self.p, self.q = p, q

def sz(t):
    if isinstance(t, Ax): return 1
    if isinstance(t, Ap): return sz(t.p) + sz(t.q) + 1
    if isinstance(t, La): return sz(t.p) + 1
    if isinstance(t, Pa): return sz(t.p) + sz(t.q) + 1

def ht(t):
    if isinstance(t, Ax): return 1
    if isinstance(t, Ap): return max(ht(t.p), ht(t.q)) + 1
    if isinstance(t, La): return ht(t.p) + 1
    if isinstance(t, Pa): return max(ht(t.p), ht(t.q)) + 1

def rpt(d=5):
    if d <= 1 or random.random() < 0.3: return Ax(random.randint(0,9))
    c = random.choice(["a","l","p"])
    if c == "a": return Ap(rpt(d-1), rpt(d-1))
    if c == "l": return La(rpt(d-1))
    return Pa(rpt(d-1), rpt(d-1))


def fig_to_base64(fig):
    buf = io.BytesIO()
    fig.savefig(buf, format='png', dpi=150, bbox_inches='tight')
    buf.seek(0)
    return "data:image/png;base64," + base64.b64encode(buf.read()).decode('utf-8')


visualizations = []

# ═══════════════════════════════════════════════════════════════════════════
# Figure 1: Significance Monotonicity
# ═══════════════════════════════════════════════════════════════════════════

fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(12, 5))

# Left: incremental growth
universe = list(range(15))
weights = {i: random.randint(1, 15) for i in universe}
K = set()
steps = []
sigs = []
for a in universe:
    K.add(a)
    steps.append(len(K))
    sigs.append(sum(weights[x] for x in K))

ax1.fill_between(steps, sigs, alpha=0.3, color='#2196F3')
ax1.plot(steps, sigs, 'o-', color='#1565C0', linewidth=2, markersize=6)
ax1.set_xlabel('Number of theorems in K')
ax1.set_ylabel('Significance σ(K)')
ax1.set_title('Significance Growth (Monotone)')

# Annotate threshold
threshold = 60
ax1.axhline(y=threshold, color='#E53935', linestyle='--', linewidth=1.5, label=f'Threshold τ={threshold}')
cross_idx = next(i for i, s in enumerate(sigs) if s >= threshold)
ax1.annotate(f'Gate opens at |K|={cross_idx+1}',
            xy=(cross_idx+1, sigs[cross_idx]),
            xytext=(cross_idx+3, sigs[cross_idx]-15),
            arrowprops=dict(arrowstyle='->', color='#E53935'),
            color='#E53935', fontsize=10)
ax1.legend()

# Right: random subset verification
n_tests = 1000
sig_diffs = []
for _ in range(n_tests):
    k = random.randint(0, 15)
    S1 = set(random.sample(universe, k))
    extra = random.randint(0, 15 - k)
    S2 = S1 | set(random.sample([x for x in universe if x not in S1], min(extra, len(universe) - len(S1))))
    s1 = sum(weights.get(x, 0) for x in S1)
    s2 = sum(weights.get(x, 0) for x in S2)
    sig_diffs.append(s2 - s1)

ax2.hist(sig_diffs, bins=30, color='#4CAF50', alpha=0.7, edgecolor='white')
ax2.axvline(x=0, color='#E53935', linewidth=2, linestyle='--', label='σ(K₂) - σ(K₁) ≥ 0')
ax2.set_xlabel('σ(K₂) - σ(K₁) for K₁ ⊆ K₂')
ax2.set_ylabel('Frequency')
ax2.set_title(f'Monotonicity Verification ({n_tests} tests)')
ax2.legend()

plt.tight_layout()
fig.savefig('/workspace/request-project/fig1_monotonicity.png', dpi=150, bbox_inches='tight')
visualizations.append({"name": "Significance Monotonicity", "data": fig_to_base64(fig)})
plt.close()


# ═══════════════════════════════════════════════════════════════════════════
# Figure 2: Height vs Size
# ═══════════════════════════════════════════════════════════════════════════

fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(12, 5))

sizes, heights = [], []
for _ in range(5000):
    t = rpt(8)
    sizes.append(sz(t))
    heights.append(ht(t))

ax1.scatter(sizes, heights, alpha=0.15, s=8, color='#7B1FA2')
max_s = max(sizes)
ax1.plot([0, max_s], [0, max_s], 'r--', linewidth=2, label='height = size (upper bound)')
ax1.set_xlabel('Proof Size')
ax1.set_ylabel('Proof Height')
ax1.set_title('Height ≤ Size (Theorem C₁)')
ax1.legend()
ax1.set_xlim(0, min(max_s, 200))
ax1.set_ylim(0, min(max(heights), 200))

# Ratio distribution
ratios = [h/s for s, h in zip(sizes, heights) if s > 0]
ax2.hist(ratios, bins=50, color='#AB47BC', alpha=0.7, edgecolor='white')
ax2.axvline(x=1.0, color='#E53935', linewidth=2, linestyle='--', label='Ratio = 1 (bound)')
ax2.set_xlabel('Height / Size Ratio')
ax2.set_ylabel('Frequency')
ax2.set_title('Distribution of Height/Size Ratio')
ax2.legend()

plt.tight_layout()
fig.savefig('/workspace/request-project/fig2_height_vs_size.png', dpi=150, bbox_inches='tight')
visualizations.append({"name": "Height vs Size", "data": fig_to_base64(fig)})
plt.close()


# ═══════════════════════════════════════════════════════════════════════════
# Figure 3: Package Depth Evolution
# ═══════════════════════════════════════════════════════════════════════════

fig, ax = plt.subplots(figsize=(10, 5))

proofs = {i: rpt(3 + (i * 7 % 5)) for i in range(20)}
proof_sizes = {i: sz(proofs[i]) for i in proofs}

K = set()
depth_trace = []
sig_trace = []
master_points = []

for a in range(20):
    old_depth = max((proof_sizes[x] for x in K), default=0)
    K.add(a)
    new_depth = max(proof_sizes[x] for x in K)
    depth_trace.append(new_depth)
    sig_trace.append(sum(proof_sizes[x] for x in K))
    if proof_sizes[a] > old_depth and a > 0:
        master_points.append((a + 1, new_depth))

x_vals = list(range(1, 21))
ax.step(x_vals, depth_trace, where='mid', color='#1565C0', linewidth=2.5, label='Package Depth')
ax.bar(x_vals, [proof_sizes[i] for i in range(20)], alpha=0.3, color='#42A5F5', label='Individual proof size')

for mx, my in master_points:
    ax.annotate('★', xy=(mx, my), fontsize=16, ha='center', va='bottom', color='#FF6F00')

ax.set_xlabel('Theorem Added (order)')
ax.set_ylabel('Complexity')
ax.set_title('Package Depth Evolution (★ = Master-Class Contribution)')
ax.legend()

plt.tight_layout()
fig.savefig('/workspace/request-project/fig3_package_depth.png', dpi=150, bbox_inches='tight')
visualizations.append({"name": "Package Depth Evolution", "data": fig_to_base64(fig)})
plt.close()


# ═══════════════════════════════════════════════════════════════════════════
# Figure 4: Quality Gate Phase Diagram
# ═══════════════════════════════════════════════════════════════════════════

fig, ax = plt.subplots(figsize=(8, 6))

n_theorems = np.arange(1, 31)
avg_weights = np.arange(1, 21)

X, Y = np.meshgrid(n_theorems, avg_weights)
threshold = 100

# Significance = n * avg_w (expected value)
Z = (X * Y >= threshold).astype(float)

ax.contourf(X, Y, Z, levels=[-0.5, 0.5, 1.5], colors=['#FFCDD2', '#C8E6C9'], alpha=0.7)
ax.contour(X, Y, X * Y, levels=[threshold], colors=['#E53935'], linewidths=2)

ax.set_xlabel('Number of Theorems |K|')
ax.set_ylabel('Average Weight per Theorem')
ax.set_title(f'Quality Gate Phase Diagram (τ = {threshold})')

# Labels
ax.text(5, 15, 'ACCEPT\n(σ ≥ τ)', fontsize=14, ha='center', color='#2E7D32', fontweight='bold')
ax.text(20, 3, 'REJECT\n(σ < τ)', fontsize=14, ha='center', color='#C62828', fontweight='bold')

# Boundary curve: n * w = threshold => w = threshold / n
n_curve = np.linspace(5, 30, 100)
w_curve = threshold / n_curve
ax.plot(n_curve, w_curve, 'r-', linewidth=2, label=f'σ = τ = {threshold}')
ax.legend(fontsize=11)

plt.tight_layout()
fig.savefig('/workspace/request-project/fig4_quality_gate.png', dpi=150, bbox_inches='tight')
visualizations.append({"name": "Quality Gate Phase Diagram", "data": fig_to_base64(fig)})
plt.close()


# ═══════════════════════════════════════════════════════════════════════════
# Figure 5: Closure Growth
# ═══════════════════════════════════════════════════════════════════════════

fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(12, 5))

# Dependency DAG closure growth
deps = {}
for i in range(20):
    n_deps = min(i, random.randint(0, 3))
    deps[i] = set(random.sample(range(i), n_deps)) if i > 0 and n_deps > 0 else set()

def closure(K):
    result = set(K)
    queue = list(K)
    while queue:
        a = queue.pop()
        for d in deps.get(a, set()):
            if d not in result:
                result.add(d)
                queue.append(d)
    return result

K = set()
raw_sizes = []
closed_sizes = []
for a in range(20):
    K.add(a)
    raw_sizes.append(len(K))
    closed_sizes.append(len(closure(K)))

ax1.plot(range(1, 21), raw_sizes, 's-', color='#FF9800', linewidth=2, label='|K| (raw)')
ax1.plot(range(1, 21), closed_sizes, 'o-', color='#4CAF50', linewidth=2, label='|cl(K)| (closed)')
ax1.fill_between(range(1, 21), raw_sizes, closed_sizes, alpha=0.2, color='#4CAF50')
ax1.set_xlabel('Theorems Added')
ax1.set_ylabel('Set Size')
ax1.set_title('Raw vs Closed Knowledge State')
ax1.legend()

# Conservative vs nonconservative
nc_count = 0
c_count = 0
nc_deltas = []
c_deltas = []
K = set()
for a in range(20):
    cl_before = closure(K)
    K.add(a)
    cl_after = closure(K)
    delta = len(cl_after) - len(cl_before)
    if cl_before < cl_after:
        nc_count += 1
        nc_deltas.append(delta)
    else:
        c_count += 1
        c_deltas.append(delta)

labels = ['Nonconservative\n(expands closure)', 'Conservative\n(closure unchanged)']
counts = [nc_count, c_count]
colors = ['#4CAF50', '#BDBDBD']
bars = ax2.bar(labels, counts, color=colors, edgecolor='white', linewidth=2)
ax2.set_ylabel('Count')
ax2.set_title('Extension Types in Growing Library')
for bar, count in zip(bars, counts):
    ax2.text(bar.get_x() + bar.get_width()/2, bar.get_height() + 0.3,
            str(count), ha='center', fontsize=14, fontweight='bold')

plt.tight_layout()
fig.savefig('/workspace/request-project/fig5_closure.png', dpi=150, bbox_inches='tight')
visualizations.append({"name": "Closure Growth Analysis", "data": fig_to_base64(fig)})
plt.close()


# Save visualization data for JSON package
with open('/workspace/request-project/viz_data.json', 'w') as f:
    json.dump(visualizations, f)

print(f"Generated {len(visualizations)} visualizations.")
print("Files: fig1_monotonicity.png, fig2_height_vs_size.png, fig3_package_depth.png,")
print("       fig4_quality_gate.png, fig5_closure.png")
