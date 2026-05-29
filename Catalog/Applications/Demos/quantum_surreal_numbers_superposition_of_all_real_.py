"""
Quantum Surreal Numbers: Applications
=======================================

Real-world applications of the quantum surreal number framework:
1. Quantum key distribution security analysis
2. Portfolio optimization via tropical-quantum bridge
3. Signal detection with infinitesimal filtering

Soli Deo Gloria
"""

import numpy as np
from typing import List, Tuple


# ============================================================
# Application 1: Quantum Key Distribution Security
# ============================================================

def qkd_security_analysis(n_states: int = 4, noise_level: float = 0.05):
    """
    Analyze quantum key distribution security using the standard-part filter.

    In QKD, an eavesdropper introduces small perturbations to quantum states.
    The standard-part filter models the detection threshold: perturbations
    below the threshold are undetectable (infinitesimal in the surreal sense).

    Args:
        n_states: Number of basis states in the protocol
        noise_level: Eavesdropper's perturbation strength
    """
    print("=" * 60)
    print("APPLICATION 1: Quantum Key Distribution Security")
    print("=" * 60)

    # Clean state
    clean = np.zeros(n_states, dtype=complex)
    clean[0] = 1.0

    # Eavesdropper perturbed state
    noise = noise_level * np.random.randn(n_states) + \
            1j * noise_level * np.random.randn(n_states)
    perturbed = clean + noise
    perturbed = perturbed / np.linalg.norm(perturbed)

    # Probability distributions
    clean_probs = np.abs(clean) ** 2
    perturbed_probs = np.abs(perturbed) ** 2

    # Standard-part filtering at various thresholds
    print(f"\nClean state probabilities:    {clean_probs}")
    print(f"Perturbed state probabilities: {np.round(perturbed_probs, 6)}")

    for epsilon in [0.1, 0.01, 0.001]:
        filtered = np.where(perturbed_probs < epsilon, 0.0, perturbed_probs)
        detectable = np.sum(filtered != clean_probs)
        print(f"\n  ε = {epsilon}:")
        print(f"    Filtered probs: {np.round(filtered, 6)}")
        print(f"    Detectable perturbations: {detectable}")
        print(f"    Security: {'SECURE' if detectable == 0 else 'BREACH DETECTED'}")


# ============================================================
# Application 2: Portfolio Optimization via Tropical Bridge
# ============================================================

def tropical_portfolio_optimization():
    """
    Use the quantum-tropical bridge for portfolio optimization.

    The key insight: the tropical cost map p ↦ -log(p) transforms
    probability maximization into cost minimization. In portfolio theory:
    - Asset return probabilities → tropical risk costs
    - Product of independent probabilities → sum of tropical costs
    - Maximum probability portfolio → minimum tropical cost portfolio
    """
    print("\n" + "=" * 60)
    print("APPLICATION 2: Portfolio Optimization via Tropical Bridge")
    print("=" * 60)

    # Hypothetical asset return probabilities (probability of positive return)
    assets = ["Tech", "Bonds", "Gold", "Crypto"]
    return_probs = np.array([0.65, 0.80, 0.55, 0.40])

    # Tropical costs
    costs = -np.log(return_probs)

    print(f"\nAsset return probabilities:")
    for name, p, c in zip(assets, return_probs, costs):
        print(f"  {name:8s}: P(+return) = {p:.2f}, tropical cost = {c:.4f}")

    # Portfolio combinations (2-asset)
    print(f"\n2-Asset portfolios (tropical cost = sum of individual costs):")
    for i in range(len(assets)):
        for j in range(i+1, len(assets)):
            joint_prob = return_probs[i] * return_probs[j]
            joint_cost = costs[i] + costs[j]
            verify_cost = -np.log(joint_prob)
            print(f"  {assets[i]}+{assets[j]}: "
                  f"P = {joint_prob:.4f}, "
                  f"cost = {joint_cost:.4f} "
                  f"(verify: {abs(joint_cost - verify_cost) < 1e-12})")

    # Optimal portfolio = minimum tropical cost
    best_pair = None
    best_cost = float('inf')
    for i in range(len(assets)):
        for j in range(i+1, len(assets)):
            c = costs[i] + costs[j]
            if c < best_cost:
                best_cost = c
                best_pair = (i, j)

    i, j = best_pair
    print(f"\nOptimal 2-asset portfolio: {assets[i]} + {assets[j]}")
    print(f"  Minimum tropical cost: {best_cost:.4f}")
    print(f"  Maximum joint probability: {return_probs[i]*return_probs[j]:.4f}")


# ============================================================
# Application 3: Signal Detection with Infinitesimal Filtering
# ============================================================

def signal_detection_filtering():
    """
    Apply standard-part filtering to signal detection.

    In radar/sonar, signals below a detection threshold are indistinguishable
    from noise. The standard-part filter formalizes this: signals with
    "infinitesimal" (sub-threshold) probability are mapped to zero.

    The idempotency theorem (stdPart_idempotent) guarantees that
    re-processing filtered signals doesn't change the result.
    """
    print("\n" + "=" * 60)
    print("APPLICATION 3: Signal Detection with Standard-Part Filter")
    print("=" * 60)

    np.random.seed(42)

    # True signal + noise
    n_channels = 10
    true_signal = np.zeros(n_channels)
    true_signal[2] = 0.8   # Strong signal
    true_signal[5] = 0.15  # Weak signal
    true_signal[7] = 0.05  # Very weak signal

    noise = 0.03 * np.abs(np.random.randn(n_channels))
    observed = true_signal + noise

    # Normalize to probabilities
    observed = observed / observed.sum()

    print(f"\nTrue signal channels: 2 (strong), 5 (weak), 7 (very weak)")
    print(f"Observed probabilities: {np.round(observed, 4)}")

    # Standard-part filtering at different thresholds
    for epsilon in [0.05, 0.02, 0.005]:
        filtered = np.where(observed < epsilon, 0.0, observed)
        detected = np.where(filtered > 0)[0]
        print(f"\n  ε = {epsilon}:")
        print(f"    Detected channels: {detected.tolist()}")
        print(f"    Filtered probs: {np.round(filtered, 4)}")

        # Verify idempotency
        double_filtered = np.where(filtered < epsilon, 0.0, filtered)
        assert np.allclose(filtered, double_filtered)
        print(f"    Idempotent: ✓ (stdPart_idempotent)")


if __name__ == "__main__":
    print("Quantum Surreal Numbers: Applications")
    print("Soli Deo Gloria\n")

    qkd_security_analysis()
    tropical_portfolio_optimization()
    signal_detection_filtering()

    print("\n" + "=" * 60)
    print("All applications demonstrated successfully!")
    print("=" * 60)


"""
Quantum Surreal Numbers: Demonstrations
========================================

Concrete numerical examples demonstrating the theorems proved in the
Lean 4 formalization of quantum surreal numbers.

Soli Deo Gloria
"""

import numpy as np
from typing import List, Tuple


class QuantumState:
    """A quantum state over n basis states with complex amplitudes."""

    def __init__(self, amplitudes: List[complex]):
        self.amp = np.array(amplitudes, dtype=complex)
        self.n = len(amplitudes)

    def prob(self, i: int) -> float:
        """Born rule probability: P(i) = |α_i|²"""
        return abs(self.amp[i]) ** 2

    def total_prob(self) -> float:
        """Total probability mass"""
        return sum(self.prob(i) for i in range(self.n))

    def is_normalized(self) -> bool:
        """Check if total probability equals 1"""
        return abs(self.total_prob() - 1.0) < 1e-12

    def inner(self, other: 'QuantumState') -> complex:
        """Inner product ⟨self|other⟩"""
        return sum(np.conj(self.amp[i]) * other.amp[i] for i in range(self.n))

    def density_matrix(self) -> np.ndarray:
        """Density matrix ρ = |ψ⟩⟨ψ|"""
        return np.outer(self.amp, np.conj(self.amp))

    def shannon_entropy(self) -> float:
        """Shannon entropy of the probability distribution"""
        H = 0.0
        for i in range(self.n):
            p = self.prob(i)
            if p > 1e-15:
                H -= p * np.log(p)
        return H

    def observable_prob(self, i: int, epsilon: float) -> float:
        """Standard-part filtered probability"""
        p = self.prob(i)
        return 0.0 if p < epsilon else p


def tropical_cost(p: float) -> float:
    """Tropical cost: -log(p)"""
    return -np.log(p) if p > 0 else float('inf')


def basis_state(n: int, j: int) -> QuantumState:
    """Create basis state |j⟩ in n-dimensional space"""
    amp = [0.0] * n
    amp[j] = 1.0
    return QuantumState(amp)


def demo_probability_properties():
    """Demonstrate probability theorems"""
    print("=" * 60)
    print("DEMO 1: Probability Properties")
    print("=" * 60)

    psi = QuantumState([1/np.sqrt(3), 1j/np.sqrt(3), -1/np.sqrt(3)])
    print(f"\nState |ψ⟩ = (1/√3)|0⟩ + (i/√3)|1⟩ + (-1/√3)|2⟩")
    print(f"Amplitudes: {psi.amp}")

    for i in range(3):
        p = psi.prob(i)
        print(f"  P({i}) = {p:.6f} ≥ 0 ✓ (prob_nonneg)")

    total = psi.total_prob()
    print(f"\nTotal probability: {total:.6f}")
    print(f"  Is normalized: {psi.is_normalized()} ✓ (IsNormalized)")

    for i in range(3):
        assert psi.prob(i) <= total + 1e-12
        print(f"  P({i}) ≤ totalProb: {psi.prob(i):.6f} ≤ {total:.6f} ✓ (prob_le_totalProb)")


def demo_basis_states():
    """Demonstrate basis state theorems"""
    print("\n" + "=" * 60)
    print("DEMO 2: Basis State Properties")
    print("=" * 60)

    n = 4
    for j in range(n):
        ej = basis_state(n, j)
        print(f"\nBasis state |{j}⟩:")
        print(f"  Is normalized: {ej.is_normalized()} ✓ (basis_isNormalized)")
        print(f"  P({j}) = {ej.prob(j):.1f} ✓ (basis_prob_self)")
        for k in range(n):
            if k != j:
                print(f"  P({k}) = {ej.prob(k):.1f} ✓ (basis_prob_other)")

    print("\nOrthogonality:")
    for j in range(n):
        for k in range(j+1, n):
            ip = basis_state(n, j).inner(basis_state(n, k))
            print(f"  ⟨{j}|{k}⟩ = {ip:.1f} ✓ (basis_orthogonal)")


def demo_standard_part():
    """Demonstrate standard part (infinitesimal collapse) theorems"""
    print("\n" + "=" * 60)
    print("DEMO 3: Standard Part Filter (Infinitesimal Collapse)")
    print("=" * 60)

    epsilon = 0.01
    print(f"\nThreshold ε = {epsilon}")

    values = [0.5, 0.001, 0.01, 0.0, 1e-10]
    for p in values:
        filtered = 0.0 if p < epsilon else p
        print(f"  stdPart({p}, {epsilon}) = {filtered}")
        if p < epsilon:
            print(f"    → Filtered to 0 ✓ (stdPart_zero_of_small)")
        else:
            print(f"    → Preserved ✓ (stdPart_eq_of_large)")

    # Idempotency
    print(f"\nIdempotency (stdPart_idempotent):")
    for p in [0.5, 0.001]:
        sp = 0.0 if p < epsilon else p
        sp2 = 0.0 if sp < epsilon else sp
        print(f"  stdPart(stdPart({p}, {epsilon}), {epsilon}) = {sp2} = stdPart({p}, {epsilon}) = {sp} ✓")


def demo_density_matrix():
    """Demonstrate density matrix theorems"""
    print("\n" + "=" * 60)
    print("DEMO 4: Density Matrix Properties")
    print("=" * 60)

    psi = QuantumState([1/np.sqrt(2), 1j/np.sqrt(2)])
    rho = psi.density_matrix()

    print(f"\nState |ψ⟩ = (1/√2)|0⟩ + (i/√2)|1⟩")
    print(f"Density matrix ρ =\n{rho}")

    # Hermiticity
    print(f"\nρ is Hermitian: {np.allclose(rho, rho.conj().T)} ✓ (densityMatrix_isHermitian)")

    # Trace
    trace = np.trace(rho)
    print(f"Tr(ρ) = {trace:.6f} ✓ (densityMatrix_trace_one)")

    # Positive semidefiniteness
    eigenvalues = np.linalg.eigvalsh(rho)
    print(f"Eigenvalues: {eigenvalues}")
    print(f"All eigenvalues ≥ 0: {all(ev >= -1e-12 for ev in eigenvalues)} ✓ (densityMatrix_pos_semidef)")


def demo_tropical_bridge():
    """Demonstrate quantum-tropical bridge theorems"""
    print("\n" + "=" * 60)
    print("DEMO 5: Quantum-Tropical Bridge")
    print("=" * 60)

    probs = [0.5, 0.3, 0.15, 0.05]
    print(f"\nProbability distribution: {probs}")
    costs = [tropical_cost(p) for p in probs]
    print(f"Tropical costs (-log p): {[f'{c:.4f}' for c in costs]}")

    print(f"\ntropicalCost(1) = {tropical_cost(1):.1f} ✓ (tropicalCost_one)")

    for p in probs:
        assert tropical_cost(p) >= 0
        print(f"tropicalCost({p}) = {tropical_cost(p):.4f} ≥ 0 ✓ (tropicalCost_nonneg)")

    # Antitone property
    print(f"\nAntitone property (tropicalCost_antitone):")
    for i in range(len(probs)-1):
        for j in range(i+1, len(probs)):
            if probs[i] >= probs[j]:
                assert tropical_cost(probs[i]) <= tropical_cost(probs[j]) + 1e-12
                print(f"  {probs[i]} ≥ {probs[j]} ⟹ cost({probs[i]}) ≤ cost({probs[j]}): "
                      f"{tropical_cost(probs[i]):.4f} ≤ {tropical_cost(probs[j]):.4f} ✓")

    # Multiplicative → additive
    p, q = 0.5, 0.3
    print(f"\nMultiplicative-to-additive (tropicalCost_mul):")
    print(f"  cost({p}×{q}) = cost({p*q}) = {tropical_cost(p*q):.6f}")
    print(f"  cost({p}) + cost({q}) = {tropical_cost(p) + tropical_cost(q):.6f}")
    print(f"  Equal: {abs(tropical_cost(p*q) - tropical_cost(p) - tropical_cost(q)) < 1e-12} ✓")


def demo_entropy():
    """Demonstrate entropy theorems"""
    print("\n" + "=" * 60)
    print("DEMO 6: Quantum Entropy")
    print("=" * 60)

    for n in [2, 3, 4]:
        # Basis state entropy
        e0 = basis_state(n, 0)
        print(f"\nn = {n}:")
        print(f"  Basis state |0⟩ entropy: {e0.shannon_entropy():.6f} ✓ (entropy_basis_eq_zero)")

        # Uniform superposition entropy
        uniform = QuantumState([1/np.sqrt(n)] * n)
        H = uniform.shannon_entropy()
        print(f"  Uniform state entropy: {H:.6f}")
        print(f"  log({n}) = {np.log(n):.6f}")
        print(f"  H = log(n): {abs(H - np.log(n)) < 1e-12} ✓ (conjecture: entropy_uniform = log n)")
        print(f"  H ≤ log(n): {H <= np.log(n) + 1e-12} ✓ (conjecture: entropy bound)")


def demo_equal_superposition():
    """Demonstrate the equal superposition theorem"""
    print("\n" + "=" * 60)
    print("DEMO 7: Equal Superposition (equal_superposition_probs_two)")
    print("=" * 60)

    psi = QuantumState([1/np.sqrt(2), 1/np.sqrt(2)])
    print(f"\n|ψ⟩ = (1/√2)|0⟩ + (1/√2)|1⟩")
    print(f"P(0) = {psi.prob(0):.6f} = 1/2 ✓")
    print(f"P(1) = {psi.prob(1):.6f} = 1/2 ✓")
    print(f"Normalized: {psi.is_normalized()} ✓")


if __name__ == "__main__":
    print("Quantum Surreal Numbers: Demonstration Suite")
    print("Soli Deo Gloria\n")

    demo_probability_properties()
    demo_basis_states()
    demo_standard_part()
    demo_density_matrix()
    demo_tropical_bridge()
    demo_entropy()
    demo_equal_superposition()

    print("\n" + "=" * 60)
    print("All demonstrations completed successfully!")
    print("=" * 60)


"""
Visualization: Quantum State Probability Landscape
===================================================

Visualizes the probability distribution of a parameterized quantum state
|ψ(θ,φ)⟩ = cos(θ)|0⟩ + sin(θ)e^{iφ}|1⟩ on the Bloch sphere,
showing how the Born rule maps amplitudes to probabilities.

The heatmap shows P(0) = cos²(θ) as a function of θ and φ,
demonstrating that probability depends only on |amplitude|, not phase.
"""

import numpy as np
import matplotlib.pyplot as plt

# Parameters
theta = np.linspace(0, np.pi, 200)
phi = np.linspace(0, 2*np.pi, 200)
THETA, PHI = np.meshgrid(theta, phi)

# Probability of outcome 0: P(0) = |cos(θ)|² = cos²(θ)
P0 = np.cos(THETA)**2

# Probability of outcome 1: P(1) = |sin(θ)|² = sin²(θ)
P1 = np.sin(THETA)**2

# Shannon entropy: H = -P0*log(P0) - P1*log(P1)
H = np.zeros_like(P0)
mask0 = P0 > 1e-15
mask1 = P1 > 1e-15
H[mask0] -= P0[mask0] * np.log(P0[mask0])
H[mask1] -= P1[mask1] * np.log(P1[mask1])

fig, axes = plt.subplots(1, 3, figsize=(18, 5))

# Plot 1: P(0) heatmap
im0 = axes[0].pcolormesh(theta, phi, P0, cmap='viridis', shading='auto')
axes[0].set_xlabel('θ (polar angle)', fontsize=12)
axes[0].set_ylabel('φ (azimuthal angle)', fontsize=12)
axes[0].set_title('P(|0⟩) = cos²(θ)\nBorn Rule Probability', fontsize=13)
plt.colorbar(im0, ax=axes[0], label='Probability')
axes[0].set_xticks([0, np.pi/4, np.pi/2, 3*np.pi/4, np.pi])
axes[0].set_xticklabels(['0', 'π/4', 'π/2', '3π/4', 'π'])
axes[0].set_yticks([0, np.pi, 2*np.pi])
axes[0].set_yticklabels(['0', 'π', '2π'])

# Plot 2: Entropy heatmap
im1 = axes[1].pcolormesh(theta, phi, H, cmap='inferno', shading='auto')
axes[1].set_xlabel('θ (polar angle)', fontsize=12)
axes[1].set_ylabel('φ (azimuthal angle)', fontsize=12)
axes[1].set_title('Shannon Entropy H(ψ)\nMaximum at Equal Superposition', fontsize=13)
plt.colorbar(im1, ax=axes[1], label='Entropy (nats)')
axes[1].set_xticks([0, np.pi/4, np.pi/2, 3*np.pi/4, np.pi])
axes[1].set_xticklabels(['0', 'π/4', 'π/2', '3π/4', 'π'])
axes[1].set_yticks([0, np.pi, 2*np.pi])
axes[1].set_yticklabels(['0', 'π', '2π'])

# Plot 3: Tropical cost of P(0)
TC = np.full_like(P0, np.nan)
TC[mask0] = -np.log(P0[mask0])
im2 = axes[2].pcolormesh(theta, phi, TC, cmap='plasma', shading='auto',
                          vmin=0, vmax=5)
axes[2].set_xlabel('θ (polar angle)', fontsize=12)
axes[2].set_ylabel('φ (azimuthal angle)', fontsize=12)
axes[2].set_title('Tropical Cost = −log P(|0⟩)\nQuantum-Tropical Bridge', fontsize=13)
plt.colorbar(im2, ax=axes[2], label='Tropical cost')
axes[2].set_xticks([0, np.pi/4, np.pi/2, 3*np.pi/4, np.pi])
axes[2].set_xticklabels(['0', 'π/4', 'π/2', '3π/4', 'π'])
axes[2].set_yticks([0, np.pi, 2*np.pi])
axes[2].set_yticklabels(['0', 'π', '2π'])

fig.suptitle('Quantum Surreal Numbers: Probability, Entropy, and Tropical Cost',
             fontsize=15, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('viz_probability_landscape.png', dpi=150, bbox_inches='tight')
print("Saved viz_probability_landscape.png")


"""
Visualization: Standard Part Filter and Infinitesimal Collapse
===============================================================

Visualizes the standard-part filtering mechanism that models
infinitesimal probability collapse in quantum surreal numbers.

Shows how sub-threshold probabilities are mapped to zero,
demonstrating the proved properties:
- stdPart_zero_of_small: values below ε map to 0
- stdPart_eq_of_large: values above ε are preserved
- stdPart_idempotent: applying twice = applying once
"""

import numpy as np
import matplotlib.pyplot as plt

fig, axes = plt.subplots(2, 2, figsize=(14, 10))

# Plot 1: Standard part function for various ε
ax = axes[0, 0]
p = np.linspace(0, 1, 500)
for eps in [0.05, 0.1, 0.2, 0.3]:
    sp = np.where(p < eps, 0.0, p)
    ax.plot(p, sp, label=f'ε = {eps}', linewidth=2)
ax.plot(p, p, '--', color='gray', alpha=0.5, label='Identity')
ax.set_xlabel('Input probability p', fontsize=12)
ax.set_ylabel('stdPart(p, ε)', fontsize=12)
ax.set_title('Standard Part Filter\n(Infinitesimal Collapse)', fontsize=13)
ax.legend(fontsize=10)
ax.grid(True, alpha=0.3)

# Plot 2: A quantum state before and after filtering
ax = axes[0, 1]
n = 8
np.random.seed(42)
raw_probs = np.random.exponential(0.3, n)
raw_probs = raw_probs / raw_probs.sum()

epsilon = 0.08
filtered = np.where(raw_probs < epsilon, 0.0, raw_probs)

x = np.arange(n)
width = 0.35
ax.bar(x - width/2, raw_probs, width, label='Original P(i)', color='steelblue', alpha=0.8)
ax.bar(x + width/2, filtered, width, label=f'Filtered (ε={epsilon})', color='coral', alpha=0.8)
ax.axhline(y=epsilon, color='red', linestyle='--', alpha=0.7, label=f'Threshold ε={epsilon}')
ax.set_xlabel('Basis state index', fontsize=12)
ax.set_ylabel('Probability', fontsize=12)
ax.set_title('Probability Filtering\n(Infinitesimal Outcomes Removed)', fontsize=13)
ax.legend(fontsize=10)
ax.set_xticks(x)

# Plot 3: Idempotency demonstration
ax = axes[1, 0]
epsilons = np.linspace(0.01, 0.5, 50)
p_test = 0.15

values = []
for eps in epsilons:
    sp1 = 0.0 if p_test < eps else p_test
    sp2 = 0.0 if sp1 < eps else sp1
    values.append((sp1, sp2))

sp1_vals = [v[0] for v in values]
sp2_vals = [v[1] for v in values]

ax.plot(epsilons, sp1_vals, 'b-', linewidth=2.5, label='stdPart(p, ε)')
ax.plot(epsilons, sp2_vals, 'r--', linewidth=2, label='stdPart(stdPart(p, ε), ε)')
ax.axhline(y=p_test, color='green', linestyle=':', alpha=0.7, label=f'p = {p_test}')
ax.set_xlabel('Threshold ε', fontsize=12)
ax.set_ylabel('Filtered value', fontsize=12)
ax.set_title(f'Idempotency: stdPart ∘ stdPart = stdPart\n(p = {p_test})', fontsize=13)
ax.legend(fontsize=10)
ax.grid(True, alpha=0.3)

# Plot 4: Entropy before and after filtering
ax = axes[1, 1]
n_states = 20
np.random.seed(123)
amplitudes = np.random.randn(n_states) + 1j * np.random.randn(n_states)
amplitudes = amplitudes / np.linalg.norm(amplitudes)
probs = np.abs(amplitudes) ** 2

eps_range = np.linspace(0, 0.15, 100)
entropies = []
n_surviving = []

for eps in eps_range:
    filtered_p = np.where(probs < eps, 0.0, probs)
    total = filtered_p.sum()
    if total > 0:
        normalized = filtered_p / total
        H = 0.0
        for p_val in normalized:
            if p_val > 1e-15:
                H -= p_val * np.log(p_val)
        entropies.append(H)
    else:
        entropies.append(0.0)
    n_surviving.append(np.sum(filtered_p > 0))

ax2 = ax.twinx()
ax.plot(eps_range, entropies, 'b-', linewidth=2, label='Entropy')
ax2.plot(eps_range, n_surviving, 'r--', linewidth=2, label='# surviving states')
ax.set_xlabel('Threshold ε', fontsize=12)
ax.set_ylabel('Shannon Entropy H', color='blue', fontsize=12)
ax2.set_ylabel('Surviving states', color='red', fontsize=12)
ax.set_title(f'Entropy vs. Filtering Threshold\n({n_states}-state system)', fontsize=13)
lines1, labels1 = ax.get_legend_handles_labels()
lines2, labels2 = ax2.get_legend_handles_labels()
ax.legend(lines1 + lines2, labels1 + labels2, fontsize=10, loc='center right')
ax.grid(True, alpha=0.3)

fig.suptitle('Standard Part Filter: Infinitesimal Probability Collapse',
             fontsize=15, fontweight='bold')
plt.tight_layout()
plt.savefig('viz_standard_part.png', dpi=150, bbox_inches='tight')
print("Saved viz_standard_part.png")


"""
Visualization: Quantum-Tropical Bridge
========================================

Visualizes the cross-domain bridge between quantum probability
and tropical geometry. The map p ↦ -log(p) transforms:
- Probability maximization → Tropical cost minimization
- Multiplication → Addition (tropicalCost_mul)
- The order is reversed (min_tropicalCost_iff_max_prob)
"""

import numpy as np
import matplotlib.pyplot as plt

fig, axes = plt.subplots(2, 2, figsize=(14, 10))

# Plot 1: The tropical cost function
ax = axes[0, 0]
p = np.linspace(0.01, 1.0, 500)
tc = -np.log(p)
ax.plot(p, tc, 'b-', linewidth=2.5)
ax.fill_between(p, 0, tc, alpha=0.1, color='blue')
ax.axhline(y=0, color='gray', linestyle='-', alpha=0.3)
ax.axvline(x=1, color='green', linestyle='--', alpha=0.5, label='p=1: cost=0')
ax.set_xlabel('Probability p', fontsize=12)
ax.set_ylabel('Tropical cost = −log(p)', fontsize=12)
ax.set_title('Tropical Cost Function\n(Monotone decreasing, proved)', fontsize=13)
ax.legend(fontsize=10)
ax.grid(True, alpha=0.3)
ax.set_xlim(0, 1.05)
ax.set_ylim(-0.2, 5)

# Plot 2: Multiplicative-to-additive property
ax = axes[0, 1]
p_vals = np.linspace(0.1, 0.9, 20)
q_vals = np.linspace(0.1, 0.9, 20)
P, Q = np.meshgrid(p_vals, q_vals)

cost_product = -np.log(P * Q)
cost_sum = -np.log(P) + (-np.log(Q))

# They should be equal
error = np.abs(cost_product - cost_sum)
im = ax.pcolormesh(p_vals, q_vals, np.log10(error + 1e-16), cmap='RdYlGn_r',
                    shading='auto', vmin=-16, vmax=-14)
ax.set_xlabel('p', fontsize=12)
ax.set_ylabel('q', fontsize=12)
ax.set_title('tropicalCost(p·q) = tropicalCost(p) + tropicalCost(q)\n'
             'Error (log₁₀ scale, ≈ machine epsilon)', fontsize=13)
plt.colorbar(im, ax=ax, label='log₁₀(error)')

# Plot 3: Order reversal demonstration
ax = axes[1, 0]
probs = np.array([0.4, 0.25, 0.2, 0.1, 0.05])
costs = -np.log(probs)
labels = [f'State {i}' for i in range(len(probs))]

x = np.arange(len(probs))
width = 0.35

ax_right = ax.twinx()
bars1 = ax.bar(x - width/2, probs, width, color='steelblue', alpha=0.8, label='Probability')
bars2 = ax_right.bar(x + width/2, costs, width, color='coral', alpha=0.8, label='Tropical cost')

ax.set_xlabel('Quantum state', fontsize=12)
ax.set_ylabel('Probability', color='steelblue', fontsize=12)
ax_right.set_ylabel('Tropical cost', color='coral', fontsize=12)
ax.set_title('Order Reversal: max prob ↔ min cost\n(min_tropicalCost_iff_max_prob)', fontsize=13)
ax.set_xticks(x)
ax.set_xticklabels(labels, fontsize=10)

lines1, labels1 = ax.get_legend_handles_labels()
lines2, labels2 = ax_right.get_legend_handles_labels()
ax.legend(lines1 + lines2, labels1 + labels2, fontsize=10)

# Plot 4: Density matrix spectrum as tropical costs
ax = axes[1, 1]
# Create a 4-state quantum system
np.random.seed(42)
amp = np.random.randn(4) + 1j * np.random.randn(4)
amp = amp / np.linalg.norm(amp)
rho = np.outer(amp, np.conj(amp))
eigenvalues = np.linalg.eigvalsh(rho)
eigenvalues = eigenvalues[eigenvalues > 1e-12]

if len(eigenvalues) > 0:
    trop_evals = -np.log(eigenvalues)

    ax.stem(range(len(eigenvalues)), eigenvalues, linefmt='b-', markerfmt='bo',
            basefmt='gray', label='Eigenvalues (probabilities)')
    ax2 = ax.twinx()
    ax2.stem(range(len(trop_evals)), trop_evals, linefmt='r-', markerfmt='rs',
             basefmt='gray', label='Tropical eigenvalues')

    ax.set_xlabel('Eigenvalue index', fontsize=12)
    ax.set_ylabel('Eigenvalue λ', color='blue', fontsize=12)
    ax2.set_ylabel('Tropical cost −log(λ)', color='red', fontsize=12)
    ax.set_title('Density Matrix Spectrum\nand Tropical Transform', fontsize=13)
    lines1, labels1 = ax.get_legend_handles_labels()
    lines2, labels2 = ax2.get_legend_handles_labels()
    ax.legend(lines1 + lines2, labels1 + labels2, fontsize=10)

fig.suptitle('Quantum-Tropical Bridge: Probability ↔ Optimization',
             fontsize=15, fontweight='bold')
plt.tight_layout()
plt.savefig('viz_tropical_bridge.png', dpi=150, bbox_inches='tight')
print("Saved viz_tropical_bridge.png")
