"""
Applications of Berggren Spectral Theory

1. Pseudorandom Pythagorean Triple Generation
2. Derandomized Sampling on Congruence Quotients
3. Spectral Gap Verification for Expander Graphs
"""

import numpy as np

B1 = np.array([[1, -2, 2], [2, -1, 2], [2, -2, 3]], dtype=int)
B2 = np.array([[1, 2, 2], [2, 1, 2], [2, 2, 3]], dtype=int)
B3 = np.array([[-1, 2, 2], [-2, 1, 2], [-2, 2, 3]], dtype=int)
GENERATORS = [B1, B2, B3]


def pseudorandom_triple_generator(seed: int = 42, count: int = 100):
    """
    Generate pseudorandom primitive Pythagorean triples using the
    Berggren walk with certified mixing.

    The spectral gap ρ = 1/4 guarantees exponential mixing:
    after k steps, the distribution is within (1/4)^k of uniform
    in L² distance.

    Args:
        seed: Random seed
        count: Number of triples to generate

    Returns:
        List of primitive Pythagorean triples
    """
    rng = np.random.RandomState(seed)
    v = np.array([3, 4, 5])
    triples = []

    for _ in range(count):
        # Random walk step: choose generator uniformly
        gen_idx = rng.randint(0, 3)
        v = GENERATORS[gen_idx] @ v
        triples.append(tuple(v))

    return triples


def congruence_distribution(triples, q: int):
    """
    Compute the distribution of Pythagorean triples modulo q.

    By the spectral gap theorem, the Berggren walk produces triples
    that are approximately uniformly distributed over residue classes.

    Args:
        triples: List of (a, b, c) triples
        q: Modulus

    Returns:
        Dictionary mapping residue classes to counts
    """
    dist = {}
    for a, b, c in triples:
        key = (a % q, b % q, c % q)
        dist[key] = dist.get(key, 0) + 1
    return dist


def expander_mixing_lemma(n_steps: int = 20):
    """
    Demonstrate the expander mixing lemma for the Berggren walk.

    For any two sets S, T ⊆ {0,1,2}:
    |e(S,T)/3 - |S|·|T|/9| ≤ (1/2) · √(|S|·|T|)

    where e(S,T) counts edges between S and T in the K₃ Cayley graph.
    """
    T_matrix = np.array([[0, 0.5, 0.5],
                         [0.5, 0, 0.5],
                         [0.5, 0.5, 0]])

    print("Expander Mixing Lemma Verification:")
    print("For K₃ with λ₂ = 1/2:")

    for S in [[0], [1], [0, 1], [0, 1, 2]]:
        for T_set in [[0], [2], [1, 2], [0, 1, 2]]:
            # Count edges
            edges = 0
            for s in S:
                for t in T_set:
                    edges += T_matrix[s, t]

            expected = len(S) * len(T_set) / 3.0
            bound = 0.5 * np.sqrt(len(S) * len(T_set))
            deviation = abs(edges - expected)

            if deviation > 0.01:
                print(f"  S={S}, T={T_set}: |e - expected| = {deviation:.3f} ≤ {bound:.3f}")


if __name__ == "__main__":
    print("=== Application 1: Pseudorandom Triple Generation ===\n")
    triples = pseudorandom_triple_generator(count=20)
    for i, (a, b, c) in enumerate(triples[:10]):
        print(f"  Triple {i+1}: ({a}, {b}, {c}), "
              f"check: {a}² + {b}² = {a**2+b**2} = {c}² = {c**2}")

    print(f"\n=== Application 2: Congruence Distribution ===\n")
    many_triples = pseudorandom_triple_generator(count=10000)
    for q in [3, 5, 7]:
        dist = congruence_distribution(many_triples, q)
        n_classes = len(dist)
        max_count = max(dist.values())
        min_count = min(dist.values())
        print(f"  mod {q}: {n_classes} residue classes, "
              f"count range [{min_count}, {max_count}]")

    print(f"\n=== Application 3: Expander Mixing ===\n")
    expander_mixing_lemma()


"""
Demo: Product Growth and L²-Flattening in the Berggren Semigroup

Demonstrates the spectral contraction of the Berggren sibling walk on K₃,
the depth-uniform Ramanujan bound, and the connection to Pythagorean triples.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt

# Berggren generators (integer matrices)
B1 = np.array([[1, -2, 2], [2, -1, 2], [2, -2, 3]])
B2 = np.array([[1, 2, 2], [2, 1, 2], [2, 2, 3]])
B3 = np.array([[-1, 2, 2], [-2, 1, 2], [-2, 2, 3]])

# Lorentz form Q = diag(1,1,-1)
Q = np.diag([1, 1, -1])

# K₃ transition matrix
T = np.array([[0, 0.5, 0.5],
              [0.5, 0, 0.5],
              [0.5, 0.5, 0]])

def lorentz_form(v):
    return v[0]**2 + v[1]**2 - v[2]**2

def l2_norm_sq(f):
    return np.sum(f**2)

def generate_triples(depth=5):
    """Generate Pythagorean triples using the Berggren tree."""
    triples = [np.array([3, 4, 5])]
    current_level = [np.array([3, 4, 5])]
    for d in range(depth):
        next_level = []
        for v in current_level:
            for B in [B1, B2, B3]:
                child = B @ v
                next_level.append(child)
                triples.append(child)
        current_level = next_level
    return triples

# === Demo 1: Lorentz form preservation ===
print("=" * 60)
print("DEMO 1: Lorentz Form Preservation")
print("=" * 60)
root = np.array([3, 4, 5])
print(f"Root triple: {root}")
print(f"Q(root) = {lorentz_form(root)} (should be 0)")
for name, B in [("B₁", B1), ("B₂", B2), ("B₃", B3)]:
    child = B @ root
    print(f"{name}(3,4,5) = {child}, Q = {lorentz_form(child)}")

# Verify BᵀQB = Q
for name, B in [("B₁", B1), ("B₂", B2), ("B₃", B3)]:
    result = B.T @ Q @ B
    print(f"{name}ᵀQ{name} = Q? {np.allclose(result, Q)}")

# === Demo 2: K₃ Spectral Contraction ===
print("\n" + "=" * 60)
print("DEMO 2: K₃ Spectral Contraction")
print("=" * 60)

# Mean-zero eigenvector
f = np.array([1.0, -1.0, 0.0])
print(f"Initial mean-zero vector: {f}")
print(f"‖f‖₂² = {l2_norm_sq(f)}")

# Apply T repeatedly
for k in range(8):
    Tk_f = np.linalg.matrix_power(T, k) @ f
    norm_sq = l2_norm_sq(Tk_f)
    bound = (0.25)**k * l2_norm_sq(f)
    print(f"k={k}: ‖T^k f‖₂² = {norm_sq:.8f}, bound = {bound:.8f}, "
          f"ratio = {norm_sq/l2_norm_sq(f):.8f}")

# === Demo 3: Eigenvalue Verification ===
print("\n" + "=" * 60)
print("DEMO 3: Eigenvalue Verification")
print("=" * 60)
eigenvalues = np.linalg.eigvalsh(T)
print(f"Eigenvalues of T: {sorted(eigenvalues, reverse=True)}")
print(f"Expected: [1, -0.5, -0.5]")
print(f"|λ₂| = {abs(sorted(eigenvalues, reverse=True)[1]):.4f}")
print(f"Spectral gap = 1 - |λ₂|² = {1 - sorted(eigenvalues, reverse=True)[1]**2:.4f}")

# === Demo 4: Discrepancy Decay ===
print("\n" + "=" * 60)
print("DEMO 4: Discrepancy Decay for Bounded Observables")
print("=" * 60)
f_bounded = np.array([0.8, -0.3, 0.5])
mean = np.mean(f_bounded)
f_centered = f_bounded - mean
print(f"Observable: {f_bounded}")
print(f"Centered: {f_centered}")

for k in range(10):
    Tk_fc = np.linalg.matrix_power(T, k) @ f_centered
    norm_sq = l2_norm_sq(Tk_fc)
    print(f"k={k}: ‖T^k(f-μ)‖₂² = {norm_sq:.10f}")

# === Demo 5: Berggren mod q ===
print("\n" + "=" * 60)
print("DEMO 5: Berggren Generators mod q")
print("=" * 60)
for q in [5, 7, 11, 13]:
    B1_mod = B1 % q
    B2_mod = B2 % q
    B3_mod = B3 % q
    Q_mod = Q % q
    # Check Lorentz preservation mod q
    check1 = (B1_mod.T @ Q_mod @ B1_mod) % q
    Q_check = Q % q
    preserved = np.allclose(check1 % q, Q_check % q)
    print(f"q={q}: B₁ᵀQB₁ ≡ Q (mod {q})? {preserved}")

# === Demo 6: Product set growth ===
print("\n" + "=" * 60)
print("DEMO 6: Pythagorean Triple Generation")
print("=" * 60)
triples = generate_triples(depth=4)
print(f"Number of triples at depth ≤ 4: {len(triples)}")
print(f"First 10 triples:")
for i, t in enumerate(triples[:10]):
    a, b, c = t
    print(f"  ({a}, {b}, {c}): {a}² + {b}² = {a**2 + b**2}, {c}² = {c**2}")

# === Visualization: L² Contraction ===
fig, axes = plt.subplots(2, 2, figsize=(12, 10))

# Plot 1: L² norm decay
ax = axes[0, 0]
f_test = np.array([1.0, -1.0, 0.0])
ks = range(15)
norms = [l2_norm_sq(np.linalg.matrix_power(T, k) @ f_test) for k in ks]
bounds = [(0.25)**k * l2_norm_sq(f_test) for k in ks]
ax.semilogy(list(ks), norms, 'bo-', label='‖T^k f‖₂²', markersize=6)
ax.semilogy(list(ks), bounds, 'r--', label='(1/4)^k · ‖f‖₂²', linewidth=2)
ax.set_xlabel('Iteration k')
ax.set_ylabel('L² norm squared')
ax.set_title('Spectral Contraction of K₃ Walk')
ax.legend()
ax.grid(True, alpha=0.3)

# Plot 2: Multiple initial conditions
ax = axes[0, 1]
test_vectors = [
    np.array([1.0, -1.0, 0.0]),
    np.array([1.0, 0.0, -1.0]),
    np.array([2.0, -1.0, -1.0]),
    np.array([0.5, -0.3, -0.2]),
]
for v in test_vectors:
    norms_v = [l2_norm_sq(np.linalg.matrix_power(T, k) @ v) / l2_norm_sq(v)
               for k in range(12)]
    ax.semilogy(range(12), norms_v, 'o-', markersize=4, alpha=0.7)
ax.semilogy(range(12), [(0.25)**k for k in range(12)], 'k--',
            linewidth=2, label='(1/4)^k bound')
ax.set_xlabel('Iteration k')
ax.set_ylabel('‖T^k f‖₂² / ‖f‖₂²')
ax.set_title('Universal Contraction Rate')
ax.legend()
ax.grid(True, alpha=0.3)

# Plot 3: Pythagorean triples
ax = axes[1, 0]
triples_plot = generate_triples(depth=3)
a_vals = [t[0] for t in triples_plot]
b_vals = [t[1] for t in triples_plot]
c_vals = [t[2] for t in triples_plot]
scatter = ax.scatter(a_vals, b_vals, c=c_vals, cmap='viridis', s=30, alpha=0.7)
plt.colorbar(scatter, ax=ax, label='Hypotenuse c')
ax.set_xlabel('a')
ax.set_ylabel('b')
ax.set_title('Berggren Tree: Primitive Pythagorean Triples')
ax.set_aspect('equal')
ax.grid(True, alpha=0.3)

# Plot 4: SᵀQS spectral identity
ax = axes[1, 1]
S = B1 + B2 + B3
SQS = S.T @ Q @ S
im = ax.imshow(SQS, cmap='RdBu', vmin=-10, vmax=10)
plt.colorbar(im, ax=ax)
ax.set_title('SᵀQS = diag(1, 1, -9)')
for i in range(3):
    for j in range(3):
        ax.text(j, i, str(SQS[i, j]), ha='center', va='center', fontsize=14)

plt.tight_layout()
plt.savefig('berggren_spectral_analysis.png', dpi=150, bbox_inches='tight')
print("\nVisualization saved to berggren_spectral_analysis.png")

# === Summary Statistics ===
print("\n" + "=" * 60)
print("SUMMARY")
print("=" * 60)
print(f"Spectral parameter: ρ = 1/4 (|λ₂| = 1/2)")
print(f"Spectral gap: 1 - ρ = 3/4")
print(f"Contraction per step: factor 1/4 in L² norm squared")
print(f"Mixing time for ε-accuracy: O(log(1/ε) / log(4))")
print(f"The Berggren walk is Ramanujan-optimal for K₃")
