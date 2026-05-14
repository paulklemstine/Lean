"""
Tropical Attention: Applications

Real-world applications of the tropical attention theory to transformer analysis,
including attention sink detection, layer convergence diagnosis, and robustness
certification.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from algorithms import (
    tropical_matrix_multiply,
    lse_matrix_multiply,
    softmax_attention,
    tropical_attention,
    compute_dominance_gap,
    certified_perturbation_radius,
    tropical_linear_iterate,
    tropical_spectral_bound,
)


def simulate_transformer_layer(n_tokens: int, d_model: int, n_layers: int, tau: float):
    """
    Simulate a multi-layer transformer and analyze tropical convergence.

    This demonstrates how the tropical spectral bound governs depth-wise
    behavior of attention scores.
    """
    print("=" * 70)
    print(f"APPLICATION 1: Multi-Layer Transformer Tropical Analysis")
    print(f"  {n_tokens} tokens, d={d_model}, {n_layers} layers, τ={tau}")
    print("=" * 70)

    np.random.seed(123)
    Q = np.random.randn(n_tokens, d_model) * 0.5
    K = np.random.randn(n_tokens, d_model) * 0.5
    V = np.random.randn(n_tokens, d_model) * 0.5

    scores = Q @ K.T
    max_entry = np.max(scores)
    print(f"\nInitial score matrix max entry: {max_entry:.4f}")
    print(f"Tropical spectral bound: {tropical_spectral_bound(scores):.4f}")

    x = np.max(scores, axis=1)  # Row maxima as initial state
    print(f"\nLayer-wise sup of tropical iterates:")
    print(f"{'Layer':>6} | {'sup(T^t x)':>12} | {'Bound':>12} | {'Gap':>12}")
    print("-" * 50)

    for t in range(n_layers + 1):
        iterate = tropical_linear_iterate(scores, x, t)
        actual = np.max(iterate)
        bound = np.max(x) + t * max_entry
        print(f"{t:6d} | {actual:12.4f} | {bound:12.4f} | {bound - actual:12.4f}")


def detect_attention_sinks(scores: np.ndarray, threshold: float = 0.0):
    """
    Detect attention sinks in a score matrix using tropical dominance analysis.

    An attention sink is a column that dominates all rows by a positive gap.

    Returns list of (column_index, dominance_gap, certified_radius) tuples.
    """
    n = scores.shape[0]
    sinks = []
    for j in range(n):
        gap = compute_dominance_gap(scores, j)
        if gap > threshold:
            radius = certified_perturbation_radius(scores, j)
            sinks.append((j, gap, radius))
    return sorted(sinks, key=lambda x: -x[1])  # Sort by gap descending


def attention_sink_analysis():
    """
    APPLICATION 2: Detect and certify attention sinks in synthetic transformer data.
    """
    print("\n" + "=" * 70)
    print("APPLICATION 2: Attention Sink Detection and Certification")
    print("=" * 70)

    np.random.seed(456)
    n_tokens = 10

    # Simulate a score matrix where token 0 is a sink (e.g., BOS token)
    scores = np.random.randn(n_tokens, n_tokens)
    # Boost column 0 to create a sink
    scores[:, 0] += 5.0

    print(f"\nScore matrix ({n_tokens}×{n_tokens}) with boosted column 0:")
    sinks = detect_attention_sinks(scores)

    if sinks:
        print(f"\nDetected sinks:")
        for col, gap, radius in sinks:
            print(f"  Column {col}: gap δ = {gap:.4f}, certified radius = {radius:.4f}")
        print(f"\n→ Column {sinks[0][0]} is the dominant sink.")
        print(f"  Perturbations up to {sinks[0][2]:.4f} in L∞ norm cannot break the sink.")
    else:
        print("  No dominant sink detected.")

    # Show softmax concentration at different temperatures
    print(f"\nSoftmax weight on sink column at different temperatures:")
    for tau in [2.0, 1.0, 0.5, 0.1, 0.01]:
        shifted = scores / tau - np.max(scores / tau, axis=1, keepdims=True)
        W = np.exp(shifted)
        W = W / W.sum(axis=1, keepdims=True)
        min_weight = np.min(W[:, 0])
        print(f"  τ = {tau:5.2f}: min softmax weight on sink = {min_weight:.8f}")


def tropical_compression_analysis():
    """
    APPLICATION 3: Tropical compression criterion for transformer layers.

    If the tropical spectral radius is small, deep layers converge and can
    be compressed (depth collapse).
    """
    print("\n" + "=" * 70)
    print("APPLICATION 3: Tropical Depth-Collapse Criterion")
    print("=" * 70)

    np.random.seed(789)

    for scenario, scale in [("Low energy", 0.1), ("Medium energy", 1.0), ("High energy", 5.0)]:
        n = 8
        A = np.random.randn(n, n) * scale
        x = np.zeros(n)

        rho = tropical_spectral_bound(A)
        print(f"\n{scenario} (scale={scale}):")
        print(f"  Tropical spectral bound ρ(A) = {rho:.4f}")

        iterates_sup = []
        current = x.copy()
        for t in range(20):
            iterates_sup.append(np.max(current))
            current = np.array([np.max(A[i, :] + current) for i in range(n)])

        growth_rate = (iterates_sup[-1] - iterates_sup[0]) / 19 if len(iterates_sup) > 1 else 0
        print(f"  Empirical growth rate: {growth_rate:.4f}")
        print(f"  Bound ratio (empirical/theoretical): {growth_rate / rho:.4f}" if rho > 0 else "")

        if growth_rate < 0.1:
            print(f"  → COMPRESSIBLE: layers converge, depth can be reduced")
        else:
            print(f"  → NON-TRIVIAL: layers produce meaningful computation")


def robustness_certification():
    """
    APPLICATION 4: Certify robustness of attention head selection.
    """
    print("\n" + "=" * 70)
    print("APPLICATION 4: Certified Robustness of Attention Selection")
    print("=" * 70)

    np.random.seed(101)
    n = 6
    d = 4

    Q = np.random.randn(n, d)
    K = np.random.randn(n, d)
    V = np.random.randn(n, d)

    scores = Q @ K.T

    # Find the natural argmax structure
    argmax = np.argmax(scores, axis=1)
    print(f"\nOriginal argmax per row: {argmax}")

    # Check dominance gaps per row
    print(f"\nPer-row analysis:")
    min_gap = float('inf')
    for i in range(n):
        winner = argmax[i]
        gap = scores[i, winner] - np.sort(scores[i])[-2]  # Gap to second-best
        min_gap = min(min_gap, gap)
        print(f"  Row {i}: winner={winner}, gap to 2nd={gap:.4f}")

    print(f"\nMinimum row gap: {min_gap:.4f}")
    print(f"Certified L∞ radius for all selections: {min_gap / 4:.4f}")

    # Test perturbation robustness
    radius = min_gap / 4
    n_tests = 1000
    stable = 0
    for _ in range(n_tests):
        pert = np.random.uniform(-radius, radius, scores.shape)
        new_argmax = np.argmax(scores + pert, axis=1)
        if np.all(new_argmax == argmax):
            stable += 1

    print(f"\nEmpirical verification ({n_tests} random perturbations within radius):")
    print(f"  Selection preserved: {stable}/{n_tests} ({100*stable/n_tests:.1f}%)")


if __name__ == "__main__":
    simulate_transformer_layer(n_tokens=8, d_model=4, n_layers=10, tau=1.0)
    attention_sink_analysis()
    tropical_compression_analysis()
    robustness_certification()
    print("\n" + "=" * 70)
    print("All applications completed successfully.")
    print("=" * 70)


"""
Tropical Attention: Demonstrations of the Core Theorems

This script demonstrates the mathematical results connecting transformer attention
to tropical (max-plus) matrix algebra with concrete numerical examples.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt

np.random.seed(42)


def trop_mul(X, Y):
    """Max-plus tropical matrix product: (X ⊙ Y)_{ij} = max_k (X_{ik} + Y_{kj})."""
    m, n = X.shape
    _, p = Y.shape
    result = np.full((m, p), -np.inf)
    for i in range(m):
        for j in range(p):
            result[i, j] = np.max(X[i, :] + Y[:, j])
    return result


def lse_mul(tau, X, Y):
    """Log-sum-exp matrix product at temperature τ."""
    m, n = X.shape
    _, p = Y.shape
    result = np.zeros((m, p))
    for i in range(m):
        for j in range(p):
            exponents = (X[i, :] + Y[:, j]) / tau
            # Numerically stable log-sum-exp
            max_exp = np.max(exponents)
            result[i, j] = tau * (max_exp + np.log(np.sum(np.exp(exponents - max_exp))))
    return result


def softmax_weights(S, tau):
    """Compute softmax attention weight matrix at temperature τ."""
    n = S.shape[0]
    W = np.zeros((n, n))
    for i in range(n):
        exps = np.exp(S[i, :] / tau)
        W[i, :] = exps / np.sum(exps)
    return W


# ============================================================
# Demo 1: Theorem A — LSE approximates tropical multiplication
# ============================================================
print("=" * 70)
print("DEMO 1: Log-Sum-Exp ↔ Tropical Matrix Product (Theorem A)")
print("=" * 70)

m, n, p = 4, 5, 3
X = np.random.randn(m, n) * 2
Y = np.random.randn(n, p) * 2

T = trop_mul(X, Y)
theoretical_bound = np.log(n)

print(f"\nMatrix dimensions: X is {m}×{n}, Y is {n}×{p}")
print(f"Theoretical bound: τ * log({n}) = τ * {theoretical_bound:.4f}")
print(f"\n{'τ':>10} | {'max |LSE - Trop|':>18} | {'τ·log(n)':>10} | {'Bound holds?':>12}")
print("-" * 60)

for tau in [10.0, 5.0, 2.0, 1.0, 0.5, 0.1, 0.01]:
    L = lse_mul(tau, X, Y)
    max_diff = np.max(np.abs(L - T))
    bound = tau * theoretical_bound
    holds = "✓" if max_diff <= bound + 1e-10 else "✗"
    print(f"{tau:10.3f} | {max_diff:18.6f} | {bound:10.6f} | {holds:>12}")

print("\n→ As τ → 0, the LSE product converges to the tropical product.")
print("→ The error is always bounded by τ·log(n), confirming Theorem A.")


# ============================================================
# Demo 2: Theorem B — Softmax → argmax as τ → 0
# ============================================================
print("\n" + "=" * 70)
print("DEMO 2: Softmax Attention Converges to Argmax Selection (Theorem B)")
print("=" * 70)

n_tokens = 6
d = 4

# Create score matrix with a clear argmax per row
S = np.random.randn(n_tokens, n_tokens)
# Make the argmax structure clear by boosting one entry per row
for i in range(n_tokens):
    winner = (i + 1) % n_tokens  # deterministic unique winner per row
    S[i, winner] += 5.0

argmax_indices = np.argmax(S, axis=1)
print(f"\nScore matrix argmax per row: {argmax_indices}")

print(f"\n{'τ':>10} | {'max weight on argmax':>22} | {'min weight on argmax':>22}")
print("-" * 60)

for tau in [5.0, 2.0, 1.0, 0.5, 0.1, 0.01, 0.001]:
    W = softmax_weights(S, tau)
    argmax_weights = [W[i, argmax_indices[i]] for i in range(n_tokens)]
    print(f"{tau:10.4f} | {max(argmax_weights):22.10f} | {min(argmax_weights):22.10f}")

print("\n→ As τ → 0, all softmax weight concentrates on the argmax.")
print("→ This is Theorem B: softmax attention → tropical selector.")


# ============================================================
# Demo 3: Theorem D — Dominant Column = Attention Sink
# ============================================================
print("\n" + "=" * 70)
print("DEMO 3: Dominant Column Creates Attention Sink (Theorem D)")
print("=" * 70)

n_tokens = 8
j_star = 2  # The sink token
delta = 3.0  # Dominance gap

# Create score matrix where column j_star dominates by δ
S_sink = np.random.randn(n_tokens, n_tokens)
for i in range(n_tokens):
    max_other = max(S_sink[i, j] for j in range(n_tokens) if j != j_star)
    S_sink[i, j_star] = max_other + delta + np.random.rand()

print(f"\nSink token: j* = {j_star}, dominance gap δ = {delta:.1f}")
print(f"Argmax per row: {np.argmax(S_sink, axis=1)}")
print(f"All rows select j*: {all(np.argmax(S_sink, axis=1) == j_star)}")

V = np.random.randn(n_tokens, 4)
print(f"\nV[j*] = {V[j_star]}")

for tau in [1.0, 0.1, 0.01]:
    W = softmax_weights(S_sink, tau)
    output = W @ V
    max_deviation = np.max(np.abs(output - np.tile(V[j_star], (n_tokens, 1))))
    print(f"τ = {tau:6.3f}: max |output_i - V[j*]| = {max_deviation:.2e}"
          f"  (bound: {(n_tokens-1)*np.exp(-delta/tau):.2e})")

print("\n→ Under dominance, all attention outputs converge to V[j*].")
print("→ The sink is a tropical fixed point: applying attention again gives the same result.")


# ============================================================
# Demo 4: Theorem E — Iterate Growth Bound
# ============================================================
print("\n" + "=" * 70)
print("DEMO 4: Tropical Iterate Growth (Theorem E)")
print("=" * 70)

n = 5
A = np.random.randn(n, n)
x = np.random.randn(n)
max_entry = np.max(A)

print(f"\nMatrix max entry: {max_entry:.4f}")
print(f"Initial sup(x): {np.max(x):.4f}")

print(f"\n{'t':>5} | {'sup(T^t x)':>12} | {'sup(x) + t*maxEntry':>22} | {'Bound holds?':>12}")
print("-" * 60)

current = x.copy()
for t in range(8):
    actual_sup = np.max(current)
    bound = np.max(x) + t * max_entry
    holds = "✓" if actual_sup <= bound + 1e-10 else "✗"
    print(f"{t:5d} | {actual_sup:12.4f} | {bound:22.4f} | {holds:>12}")
    # Apply tropical linear map
    next_val = np.array([np.max(A[i, :] + current) for i in range(n)])
    current = next_val

print("\n→ sup of iterates grows at most linearly with rate maxEntry(A).")
print("→ This is the tropical spectral radius bound (Theorem E).")


# ============================================================
# Demo 5: Robustness — Perturbation stability
# ============================================================
print("\n" + "=" * 70)
print("DEMO 5: Certified Robustness of Tropical Attention (Robustness Theorem)")
print("=" * 70)

n_tokens = 6
j_star = 0
delta = 4.0

S_robust = np.random.randn(n_tokens, n_tokens)
for i in range(n_tokens):
    max_other = max(S_robust[i, j] for j in range(n_tokens) if j != j_star)
    S_robust[i, j_star] = max_other + delta

certified_radius = delta / 4

print(f"\nDominance gap δ = {delta:.1f}")
print(f"Certified perturbation radius: δ/4 = {certified_radius:.2f}")
print(f"After perturbation, remaining gap ≥ δ/2 = {delta/2:.2f}")

n_trials = 1000
n_broken = 0
for _ in range(n_trials):
    perturbation = np.random.uniform(-certified_radius, certified_radius, (n_tokens, n_tokens))
    S_perturbed = S_robust + perturbation
    if not all(np.argmax(S_perturbed, axis=1) == j_star):
        n_broken += 1

print(f"\nRandom perturbations within certified radius ({n_trials} trials):")
print(f"  Sink preserved: {n_trials - n_broken}/{n_trials}")
print(f"  Sink broken:    {n_broken}/{n_trials}")
print("\n→ Within the certified radius, the tropical argmax is provably stable.")


# ============================================================
# Demo 6: Multi-head componentwise factorization
# ============================================================
print("\n" + "=" * 70)
print("DEMO 6: Multi-Head Tropical Attention = Componentwise (Theorem C)")
print("=" * 70)

h_heads = 3
n_tokens = 4
d = 3

print(f"\n{h_heads} attention heads, {n_tokens} tokens, dimension {d}")

for r in range(h_heads):
    S_head = np.random.randn(n_tokens, n_tokens) * 3
    V_head = np.random.randn(n_tokens, d)
    argmax = np.argmax(S_head, axis=1)
    trop_output = V_head[argmax]
    print(f"\nHead {r}: argmax per row = {argmax}")
    print(f"  Tropical output = V[argmax] (each row selects independently)")

print("\n→ Multi-head tropical attention = independent per-head computation.")
print("→ This is the product semiring structure (Theorem C).")

print("\n" + "=" * 70)
print("All demos completed successfully.")
print("=" * 70)


"""
Tropical Attention: Visualizations

Generate publication-quality figures illustrating the core theorems.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from matplotlib.gridspec import GridSpec
import base64
from io import BytesIO


def fig_to_base64(fig):
    """Convert matplotlib figure to base64 data URI."""
    buf = BytesIO()
    fig.savefig(buf, format='png', dpi=150, bbox_inches='tight')
    buf.seek(0)
    data = base64.b64encode(buf.read()).decode('utf-8')
    plt.close(fig)
    return f"data:image/png;base64,{data}"


def viz_lse_convergence():
    """Figure 1: LSE → Tropical convergence as τ → 0."""
    np.random.seed(42)
    m, n, p = 4, 8, 3
    X = np.random.randn(m, n) * 2
    Y = np.random.randn(n, p) * 2

    T = np.max(X[:, :, None] + Y[None, :, :], axis=1)

    tau_values = np.logspace(-2, 1.5, 50)
    errors = []
    bounds = []

    for tau in tau_values:
        sums = X[:, :, None] + Y[None, :, :]
        max_vals = np.max(sums / tau, axis=1, keepdims=True)
        shifted = sums / tau - max_vals
        L = tau * (max_vals.squeeze(1) + np.log(np.sum(np.exp(shifted), axis=1)))
        errors.append(np.max(np.abs(L - T)))
        bounds.append(tau * np.log(n))

    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 5))

    ax1.loglog(tau_values, errors, 'b-', linewidth=2, label='Actual max error')
    ax1.loglog(tau_values, bounds, 'r--', linewidth=2, label=r'Bound: $\tau \cdot \ln(n)$')
    ax1.set_xlabel(r'Temperature $\tau$', fontsize=13)
    ax1.set_ylabel(r'$\| \mathrm{LSE}_\tau - \mathrm{Trop} \|_\infty$', fontsize=13)
    ax1.set_title('Theorem A: LSE → Tropical Convergence', fontsize=14)
    ax1.legend(fontsize=12)
    ax1.grid(True, alpha=0.3)
    ax1.set_xlim(tau_values[0], tau_values[-1])

    ratios = [e / b for e, b in zip(errors, bounds)]
    ax2.semilogx(tau_values, ratios, 'g-', linewidth=2)
    ax2.set_xlabel(r'Temperature $\tau$', fontsize=13)
    ax2.set_ylabel('Error / Bound ratio', fontsize=13)
    ax2.set_title('Tightness of the Bound', fontsize=14)
    ax2.axhline(y=1.0, color='r', linestyle='--', alpha=0.5, label='Bound = 1')
    ax2.grid(True, alpha=0.3)
    ax2.legend(fontsize=12)
    ax2.set_ylim(0, 1.1)

    fig.suptitle('Log-Sum-Exp Approximation to Tropical Matrix Product', fontsize=15, y=1.02)
    fig.tight_layout()
    fig.savefig('fig_lse_convergence.png', dpi=150, bbox_inches='tight')
    return fig_to_base64(fig)


def viz_softmax_concentration():
    """Figure 2: Softmax weight concentration as τ → 0."""
    np.random.seed(42)
    n = 6
    S = np.random.randn(n, n)
    # Create unique argmax per row
    for i in range(n):
        winner = (i + 2) % n
        S[i, winner] += 4.0

    tau_values = np.logspace(-2, 1, 100)
    max_weights = []  # Weight on argmax
    entropy_values = []

    for tau in tau_values:
        shifted = S / tau - np.max(S / tau, axis=1, keepdims=True)
        W = np.exp(shifted)
        W = W / W.sum(axis=1, keepdims=True)

        argmax = np.argmax(S, axis=1)
        weights_on_max = [W[i, argmax[i]] for i in range(n)]
        max_weights.append(np.min(weights_on_max))

        # Shannon entropy
        entropy = -np.sum(W * np.log(W + 1e-30)) / n
        entropy_values.append(entropy)

    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 5))

    ax1.semilogx(tau_values, max_weights, 'b-', linewidth=2)
    ax1.set_xlabel(r'Temperature $\tau$', fontsize=13)
    ax1.set_ylabel('Min weight on argmax', fontsize=13)
    ax1.set_title('Theorem B: Softmax → Argmax Concentration', fontsize=14)
    ax1.axhline(y=1.0, color='r', linestyle='--', alpha=0.5)
    ax1.grid(True, alpha=0.3)

    ax2.semilogx(tau_values, entropy_values, 'purple', linewidth=2)
    ax2.set_xlabel(r'Temperature $\tau$', fontsize=13)
    ax2.set_ylabel('Mean row entropy (nats)', fontsize=13)
    ax2.set_title('Attention Entropy Collapse', fontsize=14)
    ax2.grid(True, alpha=0.3)

    fig.suptitle('Softmax Attention Tropicalization', fontsize=15, y=1.02)
    fig.tight_layout()
    fig.savefig('fig_softmax_concentration.png', dpi=150, bbox_inches='tight')
    return fig_to_base64(fig)


def viz_attention_sink():
    """Figure 3: Attention sink formation under dominant column."""
    np.random.seed(42)
    n = 8
    j_star = 2

    fig, axes = plt.subplots(1, 3, figsize=(16, 5))

    for idx, delta in enumerate([0.5, 2.0, 5.0]):
        S = np.random.randn(n, n)
        for i in range(n):
            max_other = max(S[i, j] for j in range(n) if j != j_star)
            S[i, j_star] = max_other + delta

        tau_values = np.logspace(-2, 1, 50)
        weights_on_sink = []

        for tau in tau_values:
            shifted = S / tau - np.max(S / tau, axis=1, keepdims=True)
            W = np.exp(shifted)
            W = W / W.sum(axis=1, keepdims=True)
            weights_on_sink.append(np.mean(W[:, j_star]))

        ax = axes[idx]
        ax.semilogx(tau_values, weights_on_sink, 'b-', linewidth=2,
                     label=f'Mean W[:,{j_star}]')
        ax.axhline(y=1.0, color='r', linestyle='--', alpha=0.5)
        ax.set_xlabel(r'Temperature $\tau$', fontsize=12)
        ax.set_ylabel('Mean attention on sink', fontsize=12)
        ax.set_title(f'δ = {delta}', fontsize=13)
        ax.set_ylim(0, 1.1)
        ax.grid(True, alpha=0.3)

    fig.suptitle(f'Theorem D: Attention Sink (j* = {j_star}) at Different Gaps',
                 fontsize=14, y=1.02)
    fig.tight_layout()
    fig.savefig('fig_attention_sink.png', dpi=150, bbox_inches='tight')
    return fig_to_base64(fig)


def viz_iterate_growth():
    """Figure 4: Tropical iterate growth bound."""
    np.random.seed(42)
    n = 6
    n_steps = 15

    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 5))

    for scale, color, label in [(0.5, 'blue', 'Small entries'),
                                 (1.0, 'green', 'Medium entries'),
                                 (2.0, 'red', 'Large entries')]:
        A = np.random.randn(n, n) * scale
        x = np.zeros(n)
        max_entry = np.max(A)

        sups = []
        bounds = []
        current = x.copy()
        for t in range(n_steps):
            sups.append(np.max(current))
            bounds.append(np.max(x) + t * max_entry)
            current = np.array([np.max(A[i, :] + current) for i in range(n)])

        ax1.plot(range(n_steps), sups, '-o', color=color, markersize=4,
                linewidth=2, label=f'{label} (actual)')
        ax1.plot(range(n_steps), bounds, '--', color=color, alpha=0.5,
                linewidth=1.5, label=f'{label} (bound)')

    ax1.set_xlabel('Iteration t', fontsize=13)
    ax1.set_ylabel(r'$\sup_i\, (T_A^{[t]} x)_i$', fontsize=13)
    ax1.set_title('Theorem E: Tropical Iterate Growth', fontsize=14)
    ax1.legend(fontsize=9, ncol=2)
    ax1.grid(True, alpha=0.3)

    # Growth rate comparison
    scales = np.linspace(0.1, 3.0, 20)
    theoretical_rates = []
    empirical_rates = []

    for scale in scales:
        A = np.random.randn(n, n) * scale
        x = np.zeros(n)
        max_entry = np.max(A)
        theoretical_rates.append(max_entry)

        current = x.copy()
        for _ in range(20):
            current = np.array([np.max(A[i, :] + current) for i in range(n)])
        empirical_rates.append(np.max(current) / 20)

    ax2.plot(scales, empirical_rates, 'b-o', markersize=4, linewidth=2, label='Empirical rate')
    ax2.plot(scales, theoretical_rates, 'r--', linewidth=2, label='Bound: maxEntry(A)')
    ax2.set_xlabel('Matrix scale', fontsize=13)
    ax2.set_ylabel('Growth rate per iteration', fontsize=13)
    ax2.set_title('Spectral Bound Tightness', fontsize=14)
    ax2.legend(fontsize=12)
    ax2.grid(True, alpha=0.3)

    fig.suptitle('Deep Transformer Convergence via Tropical Spectral Radius', fontsize=15, y=1.02)
    fig.tight_layout()
    fig.savefig('fig_iterate_growth.png', dpi=150, bbox_inches='tight')
    return fig_to_base64(fig)


def viz_robustness_regions():
    """Figure 5: Certified robustness regions for attention sinks."""
    np.random.seed(42)
    n = 5
    j_star = 0

    S = np.random.randn(n, n)
    for i in range(n):
        max_other = max(S[i, j] for j in range(n) if j != j_star)
        S[i, j_star] = max_other + 4.0

    delta = min(S[i, j_star] - max(S[i, j] for j in range(n) if j != j_star) for i in range(n))
    certified_radius = delta / 4

    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 5))

    # Perturbation magnitude vs sink preservation
    epsilons = np.linspace(0, delta * 0.8, 50)
    n_trials = 200
    preservation_rates = []

    for eps in epsilons:
        preserved = 0
        for _ in range(n_trials):
            pert = np.random.uniform(-eps, eps, S.shape)
            S_pert = S + pert
            if all(np.argmax(S_pert, axis=1) == j_star):
                preserved += 1
        preservation_rates.append(preserved / n_trials)

    ax1.plot(epsilons, preservation_rates, 'b-', linewidth=2)
    ax1.axvline(x=certified_radius, color='r', linestyle='--', linewidth=2,
               label=f'Certified radius = δ/4 = {certified_radius:.2f}')
    ax1.axvline(x=delta/2, color='orange', linestyle='--', linewidth=1.5,
               label=f'δ/2 = {delta/2:.2f}')
    ax1.set_xlabel('Perturbation magnitude (L∞)', fontsize=13)
    ax1.set_ylabel('Sink preservation rate', fontsize=13)
    ax1.set_title('Certified Robustness Region', fontsize=14)
    ax1.legend(fontsize=11)
    ax1.grid(True, alpha=0.3)

    # Remaining gap as function of perturbation
    remaining_gaps = [max(0, delta - 2 * eps) for eps in epsilons]
    ax2.plot(epsilons, remaining_gaps, 'g-', linewidth=2)
    ax2.axhline(y=0, color='black', linewidth=0.5)
    ax2.axvline(x=certified_radius, color='r', linestyle='--', linewidth=2,
               label=f'Certified radius')
    ax2.fill_between(epsilons, 0, remaining_gaps, alpha=0.1, color='green')
    ax2.set_xlabel('Perturbation magnitude (L∞)', fontsize=13)
    ax2.set_ylabel('Remaining dominance gap', fontsize=13)
    ax2.set_title('Gap Erosion Under Perturbation', fontsize=14)
    ax2.legend(fontsize=11)
    ax2.grid(True, alpha=0.3)

    fig.suptitle('Tropical Attention Robustness Certification', fontsize=15, y=1.02)
    fig.tight_layout()
    fig.savefig('fig_robustness.png', dpi=150, bbox_inches='tight')
    return fig_to_base64(fig)


if __name__ == "__main__":
    print("Generating visualizations...")
    b1 = viz_lse_convergence()
    print(f"  fig_lse_convergence.png ({len(b1)} chars base64)")
    b2 = viz_softmax_concentration()
    print(f"  fig_softmax_concentration.png ({len(b2)} chars base64)")
    b3 = viz_attention_sink()
    print(f"  fig_attention_sink.png ({len(b3)} chars base64)")
    b4 = viz_iterate_growth()
    print(f"  fig_iterate_growth.png ({len(b4)} chars base64)")
    b5 = viz_robustness_regions()
    print(f"  fig_robustness.png ({len(b5)} chars base64)")
    print("All visualizations generated successfully.")
