#!/usr/bin/env python3
"""
Tropical Attention Theory: Applications

Demonstrates real-world applications of the tropical attention framework:
1. Attention sink detection and analysis
2. Head redundancy detection via tropical comparison
3. Layer collapse prediction via iterate growth
4. Certified robustness of attention under perturbation
5. Tropical compression of attention patterns
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt


def softmax(scores: np.ndarray, tau: float = 1.0) -> np.ndarray:
    """Row-wise softmax at temperature τ."""
    shifted = scores - np.max(scores, axis=1, keepdims=True)
    exps = np.exp(shifted / tau)
    return exps / np.sum(exps, axis=1, keepdims=True)


def tropical_row_normalize(S: np.ndarray) -> np.ndarray:
    """Tropical (zero-temperature) row normalization: S - row_max."""
    return S - np.max(S, axis=1, keepdims=True)


def tropical_max_plus_multiply(A, B):
    m, n = A.shape
    _, p = B.shape
    C = np.full((m, p), -np.inf)
    for i in range(m):
        for k in range(p):
            C[i, k] = np.max(A[i, :] + B[:, k])
    return C


def trop_attention_op(A, x):
    n = A.shape[0]
    return np.array([np.max(A[i, :] + x) - np.max(A[i, :]) for i in range(n)])


# ============================================================
# Application 1: Attention Sink Detection
# ============================================================
print("=" * 70)
print("APPLICATION 1: Attention Sink Detection in Transformers")
print("=" * 70)

np.random.seed(42)
n_tokens = 8

# Simulate a transformer score matrix where token 0 is a sink (e.g., [BOS])
S = np.random.randn(n_tokens, n_tokens)
# Make column 0 dominant (attention sink)
S[:, 0] += 4.0

print(f"\nScore matrix (with sink at token 0):")
print(np.round(S, 2))

# Compute softmax at various temperatures
for tau in [1.0, 0.5, 0.1]:
    attn = softmax(S, tau)
    print(f"\nSoftmax attention (τ={tau}):")
    print(f"  Mean weight on sink token: {np.mean(attn[:, 0]):.4f}")
    print(f"  Max weight on sink token:  {np.max(attn[:, 0]):.4f}")

# Tropical limit
trop_norm = tropical_row_normalize(S)
trop_argmax = np.argmax(S, axis=1)
print(f"\nTropical limit (τ→0):")
print(f"  All rows select token: {trop_argmax}")
print(f"  Is token 0 a universal sink? {np.all(trop_argmax == 0)}")

# Compute dominance gap
gaps = []
for i in range(n_tokens):
    row_max = S[i, 0]
    second_max = np.max(np.delete(S[i, :], 0))
    gaps.append(row_max - second_max)
print(f"  Dominance gaps per row: {[f'{g:.2f}' for g in gaps]}")
print(f"  Minimum gap (certified radius): {min(gaps):.2f}")


# ============================================================
# Application 2: Head Redundancy Detection
# ============================================================
print("\n" + "=" * 70)
print("APPLICATION 2: Head Redundancy via Tropical Comparison")
print("=" * 70)

n_heads = 4
n_tok = 6

# Simulate multi-head attention scores
head_scores = []
for h in range(n_heads):
    S_h = np.random.randn(n_tok, n_tok)
    if h == 2:  # Head 2 is a copy of head 0 + small noise
        S_h = head_scores[0] + 0.1 * np.random.randn(n_tok, n_tok)
    head_scores.append(S_h)

# Compare tropical patterns (row argmaxes)
print("\nTropical attention patterns (row argmaxes):")
patterns = []
for h in range(n_heads):
    pattern = np.argmax(head_scores[h], axis=1)
    patterns.append(pattern)
    print(f"  Head {h}: {pattern}")

# Detect redundancy
for i in range(n_heads):
    for j in range(i + 1, n_heads):
        match = np.sum(patterns[i] == patterns[j]) / n_tok
        print(f"  Heads {i}-{j} agreement: {match:.0%}" +
              (" ← REDUNDANT" if match > 0.8 else ""))


# ============================================================
# Application 3: Layer Collapse Prediction
# ============================================================
print("\n" + "=" * 70)
print("APPLICATION 3: Layer Collapse via Tropical Iterate Growth")
print("=" * 70)

n_layer = 5
# Simulate normalized attention matrices for multiple layers
A_layers = []
for l in range(n_layer):
    A_l = np.random.randn(n_layer, n_layer)
    # Normalize rows tropically
    A_l = A_l - np.max(A_l, axis=1, keepdims=True)
    A_layers.append(A_l)

# Compose layers tropically
x0 = np.zeros(n_layer)
print(f"\nInitial state: x₀ = {x0}")
print(f"\nLayer-by-layer tropical composition:")

x = x0.copy()
for l in range(n_layer):
    x = trop_attention_op(A_layers[l], x)
    spread = np.max(x) - np.min(x)
    print(f"  After layer {l+1}: x = {np.round(x, 3)}, spread = {spread:.4f}")

# Multiple iterations of the SAME matrix
A_single = A_layers[0]
max_entry = np.max(A_single)
print(f"\nRepeated application of single layer (maxEntry = {max_entry:.2f}):")
x = np.array([1.0, 0.5, 0.0, -0.5, -1.0])
for t in range(8):
    spread = np.max(x) - np.min(x)
    x_copy = x.copy()
    x = trop_attention_op(A_single, x)
    print(f"  t={t}: spread = {spread:.4f}")


# ============================================================
# Application 4: Certified Robustness
# ============================================================
print("\n" + "=" * 70)
print("APPLICATION 4: Certified Robustness of Attention Selection")
print("=" * 70)

n_rob = 5
S_clean = np.random.randn(n_rob, n_rob)
# Make one column dominant with known gap
dominant_col = 2
S_clean[:, dominant_col] += 3.0

# Compute gaps
min_gap = np.inf
for i in range(n_rob):
    gap = S_clean[i, dominant_col] - np.max(np.delete(S_clean[i, :], dominant_col))
    min_gap = min(min_gap, gap)

certified_radius = min_gap / 4.0

print(f"\nClean score matrix dominant column: {dominant_col}")
print(f"Minimum dominance gap δ: {min_gap:.4f}")
print(f"Certified perturbation radius: δ/4 = {certified_radius:.4f}")

# Test with perturbations of increasing magnitude
epsilons = [0.1, 0.5, 1.0, certified_radius * 0.9, certified_radius * 1.1, 2.0]
for eps in epsilons:
    n_trials = 100
    n_stable = 0
    for _ in range(n_trials):
        perturbation = np.random.uniform(-eps, eps, (n_rob, n_rob))
        S_pert = S_clean + perturbation
        if np.all(np.argmax(S_pert, axis=1) == dominant_col):
            n_stable += 1
    certified = eps <= certified_radius
    print(f"  ε = {eps:.3f}: {n_stable}/{n_trials} stable  "
          f"{'✓ CERTIFIED' if certified else '○ NOT CERTIFIED'}")


# ============================================================
# Application 5: Tropical Compression
# ============================================================
print("\n" + "=" * 70)
print("APPLICATION 5: Tropical Compression of Attention Patterns")
print("=" * 70)

n_comp = 8
S_full = np.random.randn(n_comp, n_comp)

# Full softmax attention
attn_full = softmax(S_full)
print(f"\nFull softmax attention matrix ({n_comp}×{n_comp}):")
print(f"  Non-zero entries: {np.sum(attn_full > 1e-10)}")
print(f"  Storage: {attn_full.size} floats")

# Tropical compression: store only argmax per row + max values
argmaxes = np.argmax(S_full, axis=1)
max_vals = np.max(S_full, axis=1)
print(f"\nTropical compression (argmax per row):")
print(f"  Argmaxes: {argmaxes}")
print(f"  Storage: {2 * n_comp} values (argmax + max_val)")
print(f"  Compression ratio: {attn_full.size / (2 * n_comp):.1f}×")

# Reconstruct approximate attention from tropical skeleton
attn_trop = np.zeros_like(attn_full)
for i in range(n_comp):
    attn_trop[i, argmaxes[i]] = 1.0

# Measure quality
agreement = np.sum(np.argmax(attn_full, axis=1) == argmaxes) / n_comp
print(f"  Argmax agreement with full softmax: {agreement:.0%}")

# Top-k tropical (keeping top 2 per row)
k = 2
print(f"\nTop-{k} tropical compression:")
top_k_indices = np.argsort(S_full, axis=1)[:, -k:]
attn_topk = np.zeros_like(attn_full)
for i in range(n_comp):
    for j in top_k_indices[i]:
        attn_topk[i, j] = np.exp(S_full[i, j]) / np.sum(np.exp(S_full[i, top_k_indices[i]]))
fro_error = np.linalg.norm(attn_full - attn_topk, 'fro')
print(f"  Frobenius error vs full softmax: {fro_error:.4f}")
print(f"  Storage: {3 * k * n_comp} values")
print(f"  Compression ratio: {attn_full.size / (3 * k * n_comp):.1f}×")


# ============================================================
# Generate application visualization
# ============================================================
fig, axes = plt.subplots(2, 2, figsize=(14, 10))
fig.suptitle('Tropical Attention: Applications', fontsize=16, fontweight='bold')

# Plot 1: Sink detection
ax = axes[0, 0]
S_plot = np.random.RandomState(42).randn(6, 6)
S_plot[:, 0] += 3.0
for tau_idx, tau in enumerate([2.0, 0.5, 0.1, 0.01]):
    attn = softmax(S_plot, tau)
    ax.bar(np.arange(6) + tau_idx * 0.2, attn[0, :], width=0.18,
           label=f'τ={tau}', alpha=0.8)
ax.set_xlabel('Token index')
ax.set_ylabel('Attention weight (row 0)')
ax.set_title('Sink Formation as τ → 0')
ax.legend(fontsize=8)
ax.grid(True, alpha=0.3)

# Plot 2: Layer collapse
ax = axes[0, 1]
A_collapse = np.random.RandomState(44).randn(5, 5)
A_collapse = A_collapse - np.max(A_collapse, axis=1, keepdims=True)
spreads = []
x_lc = np.array([2.0, 1.0, 0.0, -1.0, -2.0])
for t in range(20):
    spreads.append(np.max(x_lc) - np.min(x_lc))
    x_lc = trop_attention_op(A_collapse, x_lc)
ax.plot(spreads, 'b-o', markersize=4)
ax.set_xlabel('Layer depth')
ax.set_ylabel('Value spread (max - min)')
ax.set_title('Projective Contraction (Layer Collapse)')
ax.grid(True, alpha=0.3)

# Plot 3: Robustness certification
ax = axes[1, 0]
eps_range = np.linspace(0, 3, 30)
stability = []
S_rob = np.random.RandomState(45).randn(5, 5)
S_rob[:, 2] += 3.0
for eps in eps_range:
    n_trials = 200
    n_ok = 0
    for _ in range(n_trials):
        pert = np.random.uniform(-eps, eps, S_rob.shape)
        if np.all(np.argmax(S_rob + pert, axis=1) == 2):
            n_ok += 1
    stability.append(n_ok / n_trials)

min_gap_r = np.min([S_rob[i, 2] - np.max(np.delete(S_rob[i, :], 2)) for i in range(5)])
cert_rad = min_gap_r / 4

ax.plot(eps_range, stability, 'g-', linewidth=2)
ax.axvline(x=cert_rad, color='r', linestyle='--', label=f'Certified radius = {cert_rad:.2f}')
ax.set_xlabel('Perturbation magnitude ε')
ax.set_ylabel('Fraction with stable argmax')
ax.set_title('Certified Robustness of Tropical Selection')
ax.legend()
ax.grid(True, alpha=0.3)

# Plot 4: Compression quality
ax = axes[1, 1]
ns = [4, 8, 16, 32, 64]
comp_ratios = []
fro_errors_list = []
for n_c in ns:
    S_c = np.random.RandomState(46).randn(n_c, n_c)
    attn_exact = softmax(S_c)
    argmaxes_c = np.argmax(S_c, axis=1)
    attn_approx = np.zeros_like(attn_exact)
    for i in range(n_c):
        attn_approx[i, argmaxes_c[i]] = 1.0
    fro_errors_list.append(np.linalg.norm(attn_exact - attn_approx, 'fro') / n_c)
    comp_ratios.append(n_c * n_c / (2 * n_c))

ax.plot(ns, fro_errors_list, 'mo-', linewidth=2, markersize=6)
ax.set_xlabel('Sequence length n')
ax.set_ylabel('Normalized Frobenius error')
ax.set_title('Tropical Compression Error')
ax.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('tropical_attention_applications.png', dpi=150, bbox_inches='tight')
print("\n✓ Application visualization saved to tropical_attention_applications.png")


#!/usr/bin/env python3
"""
Tropical Attention Theory: Demonstrations

Concrete numerical examples showing that log-sum-exp attention converges
to max-plus (tropical) matrix multiplication as temperature τ → 0⁺.

Demonstrates:
1. Scalar LSE convergence to max
2. Log-softmax convergence to tropical row normalization
3. LSE matrix composition converging to tropical matrix product
4. Multi-head componentwise tropicalization
5. Sink fixed-point behavior
6. Iterate growth bounds
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt

np.set_printoptions(precision=6, suppress=True)


def lse(a: np.ndarray, tau: float) -> float:
    """Temperature-scaled log-sum-exp: τ * log(Σ exp(aᵢ/τ))"""
    # Numerically stable version
    m = np.max(a)
    return m + tau * np.log(np.sum(np.exp((a - m) / tau)))


def tropical_max(a: np.ndarray) -> float:
    """Max-plus identity: max(a)"""
    return np.max(a)


def trop_mul_max(A: np.ndarray, B: np.ndarray) -> np.ndarray:
    """Max-plus tropical matrix product: C[i,k] = max_j(A[i,j] + B[j,k])"""
    m, n = A.shape
    _, p = B.shape
    C = np.zeros((m, p))
    for i in range(m):
        for k in range(p):
            C[i, k] = np.max(A[i, :] + B[:, k])
    return C


def lse_mul(A: np.ndarray, B: np.ndarray, tau: float) -> np.ndarray:
    """LSE matrix product: C[i,k] = τ * log(Σ_j exp((A[i,j]+B[j,k])/τ))"""
    m, n = A.shape
    _, p = B.shape
    C = np.zeros((m, p))
    for i in range(m):
        for k in range(p):
            vals = A[i, :] + B[:, k]
            C[i, k] = lse(vals, tau)
    return C


def trop_attention_op(A: np.ndarray, x: np.ndarray) -> np.ndarray:
    """Tropical attention operator: T_A(x)_i = max_j(A[i,j]+x[j]) - max_j(A[i,j])"""
    n = A.shape[0]
    result = np.zeros(n)
    for i in range(n):
        result[i] = np.max(A[i, :] + x) - np.max(A[i, :])
    return result


def trop_lin(A: np.ndarray, x: np.ndarray) -> np.ndarray:
    """Tropical linear map: (T_A x)_i = max_j(A[i,j] + x[j])"""
    n = A.shape[0]
    return np.array([np.max(A[i, :] + x) for i in range(n)])


# ============================================================
# Demo 1: Scalar LSE convergence
# ============================================================
print("=" * 70)
print("DEMO 1: Scalar log-sum-exp converges to max as τ → 0⁺")
print("=" * 70)

a = np.array([1.0, 3.0, 2.0, 0.5])
true_max = np.max(a)
taus = [10.0, 5.0, 2.0, 1.0, 0.5, 0.1, 0.01, 0.001]

print(f"\nVector a = {a}")
print(f"True max = {true_max}")
print(f"\n{'τ':>10} {'LSE(a,τ)':>15} {'|LSE - max|':>15} {'τ·log(n)':>12}")
print("-" * 55)
for tau in taus:
    lse_val = lse(a, tau)
    err = abs(lse_val - true_max)
    bound = tau * np.log(len(a))
    print(f"{tau:10.4f} {lse_val:15.8f} {err:15.8e} {bound:12.8f}")

print("\n✓ Error is always ≤ τ·log(n), and → 0 as τ → 0⁺")


# ============================================================
# Demo 2: Log-softmax → tropical row normalization
# ============================================================
print("\n" + "=" * 70)
print("DEMO 2: Log-softmax converges to tropical row normalization")
print("=" * 70)

n = 4
S = np.array([
    [2.0, 5.0, 1.0, 3.0],
    [4.0, 1.0, 6.0, 2.0],
    [3.0, 3.0, 3.0, 7.0],
    [1.0, 2.0, 0.0, 1.0]
])

# Tropical row normalization: S[i,j] - max_k S[i,k]
row_maxes = np.max(S, axis=1, keepdims=True)
trop_normalized = S - row_maxes

print(f"\nScore matrix S =\n{S}")
print(f"\nTropical row normalization (S - row_max) =\n{trop_normalized}")

for tau in [1.0, 0.1, 0.01]:
    log_softmax = np.zeros_like(S)
    for i in range(n):
        lse_val = lse(S[i, :], tau)
        log_softmax[i, :] = S[i, :] - lse_val
    print(f"\nLog-softmax at τ = {tau}:")
    print(log_softmax)
    print(f"  Max absolute error: {np.max(np.abs(log_softmax - trop_normalized)):.8e}")


# ============================================================
# Demo 3: LSE composition → tropical matrix product
# ============================================================
print("\n" + "=" * 70)
print("DEMO 3: LSE composition converges to tropical matrix product")
print("=" * 70)

A = np.array([
    [1.0, 3.0, 2.0],
    [4.0, 0.0, 1.0],
    [2.0, 2.0, 5.0]
])
B = np.array([
    [3.0, 1.0, 0.0],
    [0.0, 4.0, 2.0],
    [1.0, 0.0, 3.0]
])

C_trop = trop_mul_max(A, B)
print(f"\nA =\n{A}")
print(f"\nB =\n{B}")
print(f"\nTropical product (max-plus) A ⊗ B =\n{C_trop}")

for tau in [1.0, 0.1, 0.01, 0.001]:
    C_lse = lse_mul(A, B, tau)
    err = np.max(np.abs(C_lse - C_trop))
    print(f"  τ = {tau:8.4f}: LSE product error = {err:.8e}")


# ============================================================
# Demo 4: Multi-head componentwise tropicalization
# ============================================================
print("\n" + "=" * 70)
print("DEMO 4: Multi-head attention tropicalizes componentwise")
print("=" * 70)

h = 2  # number of heads
A_heads = [
    np.array([[1.0, 2.0], [3.0, 0.0]]),
    np.array([[0.0, 4.0], [1.0, 1.0]])
]
B_heads = [
    np.array([[2.0, 1.0], [0.0, 3.0]]),
    np.array([[1.0, 0.0], [2.0, 1.0]])
]

print("\nHead 0: A =", A_heads[0].tolist(), "B =", B_heads[0].tolist())
print("Head 1: A =", A_heads[1].tolist(), "B =", B_heads[1].tolist())

for r in range(h):
    C_trop_r = trop_mul_max(A_heads[r], B_heads[r])
    print(f"\nHead {r} tropical product = {C_trop_r.tolist()}")
    for tau in [0.1, 0.01]:
        C_lse_r = lse_mul(A_heads[r], B_heads[r], tau)
        err = np.max(np.abs(C_lse_r - C_trop_r))
        print(f"  τ = {tau}: error = {err:.8e}")


# ============================================================
# Demo 5: Sink fixed-point behavior
# ============================================================
print("\n" + "=" * 70)
print("DEMO 5: Attention sink as tropical fixed point")
print("=" * 70)

n = 4
s = 1  # sink token index
# Build A where column s dominates every row
A_sink = np.array([
    [2.0, 5.0, 1.0, 3.0],
    [1.0, 6.0, 0.0, 2.0],
    [3.0, 7.0, 2.0, 4.0],
    [0.0, 4.0, 1.0, 1.0]
])

print(f"\nMatrix A with dominant column s={s}:")
print(A_sink)
print(f"Column {s} dominates: {all(A_sink[i, s] >= A_sink[i, j] for i in range(n) for j in range(n))}")

# Zero vector is always a fixed point
x_zero = np.zeros(n)
Tx_zero = trop_attention_op(A_sink, x_zero)
print(f"\nT_A(0) = {Tx_zero}  (should be all zeros)")

# Constant vector is a projective fixed point
for c in [1.0, -2.5, 3.14]:
    x_const = np.full(n, c)
    Tx_const = trop_attention_op(A_sink, x_const)
    print(f"T_A({c}) = {Tx_const}  (should be all {c})")

# Show additive homogeneity
x = np.array([1.0, 0.0, -1.0, 2.0])
c = 3.0
Tx = trop_attention_op(A_sink, x)
Txc = trop_attention_op(A_sink, x + c)
print(f"\nT_A(x) = {Tx}")
print(f"T_A(x + {c}) = {Txc}")
print(f"T_A(x) + {c} = {Tx + c}")
print(f"Match: {np.allclose(Txc, Tx + c)}")


# ============================================================
# Demo 6: Iterate growth bound
# ============================================================
print("\n" + "=" * 70)
print("DEMO 6: Tropical iterate growth bound")
print("=" * 70)

A_iter = np.array([
    [1.0, 2.0, 0.0],
    [3.0, -1.0, 1.0],
    [0.0, 2.0, 4.0]
])
x0 = np.array([1.0, 0.0, -1.0])

max_entry = np.max(A_iter)
sup_x0 = np.max(x0)
print(f"\nA =\n{A_iter}")
print(f"x₀ = {x0}")
print(f"maxEntry(A) = {max_entry}")
print(f"sup(x₀) = {sup_x0}")

print(f"\n{'t':>5} {'sup(T^t x)':>15} {'Bound':>15} {'Bound - sup':>15}")
print("-" * 55)
x = x0.copy()
for t in range(8):
    sup_val = np.max(x)
    bound = sup_x0 + t * max_entry
    print(f"{t:5d} {sup_val:15.4f} {bound:15.4f} {bound - sup_val:15.4f}")
    x = trop_lin(A_iter, x)

print("\n✓ sup(T^t x) ≤ sup(x₀) + t · maxEntry(A) for all t")


# ============================================================
# Generate visualization
# ============================================================
fig, axes = plt.subplots(2, 2, figsize=(14, 10))
fig.suptitle('Tropical Attention Theory: Key Results', fontsize=16, fontweight='bold')

# Plot 1: LSE convergence
ax = axes[0, 0]
a_vals = np.array([1.0, 3.0, 2.0, 0.5])
true_m = np.max(a_vals)
tau_range = np.logspace(-3, 1, 100)
lse_vals = [lse(a_vals, t) for t in tau_range]
errors = [abs(v - true_m) for v in lse_vals]
bounds = [t * np.log(len(a_vals)) for t in tau_range]

ax.loglog(tau_range, errors, 'b-', linewidth=2, label='|LSE(a,τ) - max(a)|')
ax.loglog(tau_range, bounds, 'r--', linewidth=2, label='τ · log(n)')
ax.set_xlabel('Temperature τ')
ax.set_ylabel('Error')
ax.set_title('Theorem 1: LSE → max as τ → 0⁺')
ax.legend()
ax.grid(True, alpha=0.3)

# Plot 2: Matrix product convergence
ax = axes[0, 1]
A_demo = np.random.RandomState(42).randn(4, 4)
B_demo = np.random.RandomState(43).randn(4, 4)
C_exact = trop_mul_max(A_demo, B_demo)
tau_range2 = np.logspace(-3, 1, 50)
mat_errors = []
for t in tau_range2:
    C_approx = lse_mul(A_demo, B_demo, t)
    mat_errors.append(np.max(np.abs(C_approx - C_exact)))

ax.loglog(tau_range2, mat_errors, 'g-', linewidth=2, label='sup|LSE·B - A⊗B|')
ax.loglog(tau_range2, [t * np.log(4) for t in tau_range2], 'r--', linewidth=2, label='τ · log(n)')
ax.set_xlabel('Temperature τ')
ax.set_ylabel('Max error')
ax.set_title('Theorem 2: LSE composition → tropical product')
ax.legend()
ax.grid(True, alpha=0.3)

# Plot 3: Iterate growth
ax = axes[1, 0]
A_g = np.array([[1.0, 2.0, 0.0], [3.0, -1.0, 1.0], [0.0, 2.0, 4.0]])
x_g = np.array([1.0, 0.0, -1.0])
max_e = np.max(A_g)
sup_x = np.max(x_g)
ts = list(range(12))
sups = []
x_curr = x_g.copy()
for t in ts:
    sups.append(np.max(x_curr))
    x_curr = trop_lin(A_g, x_curr)
bounds_g = [sup_x + t * max_e for t in ts]

ax.plot(ts, sups, 'bo-', linewidth=2, markersize=6, label='sup(T^t x)')
ax.plot(ts, bounds_g, 'r--', linewidth=2, label='sup(x) + t·maxEntry(A)')
ax.set_xlabel('Iterations t')
ax.set_ylabel('Value')
ax.set_title('Theorem 5: Tropical iterate growth bound')
ax.legend()
ax.grid(True, alpha=0.3)

# Plot 4: Sink convergence in softmax
ax = axes[1, 1]
A_s = np.array([
    [2.0, 5.0, 1.0, 3.0],
    [1.0, 6.0, 0.0, 2.0],
    [3.0, 7.0, 2.0, 4.0],
    [0.0, 4.0, 1.0, 1.0]
])
tau_range3 = np.logspace(-2, 1, 50)
sink_weights = []
for t in tau_range3:
    # Softmax weight on column 1 (sink) for row 0
    scores = A_s[0, :]
    exps = np.exp(scores / t)
    weight_sink = exps[1] / np.sum(exps)
    sink_weights.append(weight_sink)

ax.semilogx(tau_range3, sink_weights, 'purple', linewidth=2, label='P(sink | row 0)')
ax.axhline(y=1.0, color='r', linestyle='--', alpha=0.5, label='Tropical limit = 1')
ax.set_xlabel('Temperature τ')
ax.set_ylabel('Attention weight')
ax.set_title('Theorem 4: Sink token absorbs attention')
ax.legend()
ax.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('tropical_attention_results.png', dpi=150, bbox_inches='tight')
plt.savefig('tropical_attention_results.svg', bbox_inches='tight')
print("\n✓ Visualization saved to tropical_attention_results.png/svg")
