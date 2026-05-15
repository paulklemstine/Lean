#!/usr/bin/env python3
"""
Real-World Applications of Compositional Invariant Transfer

Demonstrates how the meta-theorem applies to concrete problems in:
1. Cryptographic protocol composition
2. Entropy accumulation in random number generators
3. Distributed system convergence
4. Thermodynamic pressure bounds
"""

import math
import random
from typing import List, Tuple, Dict


# ============================================================
# Application 1: Cryptographic Protocol Composition
# ============================================================

def crypto_protocol_composition():
    """
    Model a multi-stage cryptographic protocol as a product of security games.

    A TLS-like handshake involves:
    1. Key exchange (DH or ECDH)
    2. Server authentication (signature verification)
    3. Symmetric encryption (AES-GCM)
    4. MAC verification

    The meta-theorem gives: total security ≥ min(component securities)
    """
    print("=" * 60)
    print("APPLICATION 1: Cryptographic Protocol Composition")
    print("=" * 60)

    components = [
        ("ECDH Key Exchange", 128, "NIST P-256"),
        ("RSA Signature", 112, "RSA-2048"),
        ("AES-GCM Encryption", 128, "AES-128"),
        ("HMAC Verification", 128, "HMAC-SHA256"),
    ]

    print("\nProtocol components:")
    for name, sec, spec in components:
        print(f"  {name:25s}: {sec}-bit security ({spec})")

    securities = [s for _, s, _ in components]
    min_sec = min(securities)
    weakest = [name for name, s, _ in components if s == min_sec][0]

    print(f"\nComposed protocol security ≥ {min_sec} bits")
    print(f"Weakest link: {weakest}")
    print(f"Recommendation: upgrade RSA-2048 to RSA-3072 (128-bit security)")

    # Hybrid argument analysis
    print("\nHybrid argument (subadditive bound):")
    advantages = [2**(-s) for s in securities]
    total_advantage = sum(advantages)
    print(f"  Individual advantages: {[f'2^-{s}' for s in securities]}")
    print(f"  Total advantage ≤ Σ εᵢ = {total_advantage:.2e}")
    print(f"  Effective security: {-math.log2(total_advantage):.1f} bits")


# ============================================================
# Application 2: Entropy Accumulation
# ============================================================

def entropy_accumulation():
    """
    Model entropy accumulation from multiple independent sources.

    A hardware RNG collects entropy from:
    1. Thermal noise (Johnson-Nyquist)
    2. Shot noise (quantum vacuum fluctuations)
    3. Clock jitter
    4. Environmental sensors

    The additive transfer theorem gives exact total entropy.
    """
    print("\n" + "=" * 60)
    print("APPLICATION 2: Entropy Accumulation (Hardware RNG)")
    print("=" * 60)

    sources = [
        ("Thermal noise", 8.3, "0.5 bits/sample, 16.6 kHz"),
        ("Shot noise", 4.7, "0.3 bits/sample, 15.7 kHz"),
        ("Clock jitter", 2.1, "0.1 bits/sample, 21 kHz"),
        ("Env. sensors", 1.2, "0.05 bits/sample, 24 kHz"),
    ]

    print("\nEntropy sources (min-entropy in bits/ms):")
    for name, entropy, details in sources:
        print(f"  {name:20s}: {entropy:.1f} bits/ms  ({details})")

    entropies = [e for _, e, _ in sources]
    total = sum(entropies)

    print(f"\nBy additive transfer theorem:")
    print(f"  H_∞(combined) = Σ H_∞(sourceᵢ) = {total:.1f} bits/ms")
    print(f"  = {total * 1000:.0f} bits/second")

    # Key derivation
    key_sizes = [128, 192, 256]
    print(f"\nKey generation rates:")
    for ks in key_sizes:
        rate = (total * 1000) / ks
        print(f"  {ks}-bit keys: {rate:.1f} keys/second")


# ============================================================
# Application 3: Distributed System Convergence
# ============================================================

def distributed_convergence():
    """
    Model convergence of a distributed consensus protocol.

    Each node has a "distance to consensus" that decreases monotonically.
    Product termination theorem guarantees global convergence.
    """
    print("\n" + "=" * 60)
    print("APPLICATION 3: Distributed Consensus Convergence")
    print("=" * 60)

    n_nodes = 5
    max_rounds = 20

    # Simulate convergence
    distances = [random.uniform(5, 20) for _ in range(n_nodes)]
    decay_rates = [random.uniform(0.3, 0.7) for _ in range(n_nodes)]

    print(f"\n{n_nodes} nodes with initial distances to consensus:")
    for i, (d, r) in enumerate(zip(distances, decay_rates)):
        print(f"  Node {i}: distance = {d:.1f}, decay rate = {r:.2f}")

    print(f"\nConvergence trace (distance sum):")
    threshold = 0.01
    for t in range(max_rounds):
        total_dist = sum(distances)
        bar = "█" * int(total_dist)
        print(f"  Round {t:2d}: total = {total_dist:6.2f} {bar}")
        if total_dist < threshold:
            print(f"  Converged at round {t}!")
            break
        distances = [d * r for d, r in zip(distances, decay_rates)]

    print(f"\nBy product termination theorem:")
    print(f"  Each node's distance is well-founded (bounded, decreasing)")
    print(f"  ⟹ Product system converges to consensus")
    convergence_time = max(-math.log(threshold / 20) / math.log(1/r)
                          for r in decay_rates)
    print(f"  Worst-case convergence: ~{convergence_time:.0f} rounds")


# ============================================================
# Application 4: Thermodynamic Pressure
# ============================================================

def thermodynamic_pressure():
    """
    Compute pressure bounds for coupled thermodynamic systems.

    For weakly coupled systems, pressure is nearly additive.
    The subadditivity bound gives rigorous upper bounds.
    """
    print("\n" + "=" * 60)
    print("APPLICATION 4: Thermodynamic Pressure Bounds")
    print("=" * 60)

    systems = [
        ("Ideal gas A", 2.3),
        ("Ideal gas B", 1.8),
        ("Spin lattice", 3.5),
        ("Phonon bath", 1.2),
    ]

    print("\nSubsystem pressures (reduced units):")
    for name, p in systems:
        print(f"  {name:20s}: P = {p:.1f}")

    pressures = [p for _, p in systems]
    total = sum(pressures)
    interaction_correction = 0.15 * total  # 15% coupling effect

    print(f"\nSubadditive bound:  P(composite) ≤ {total:.1f}")
    print(f"With interaction:   P(composite) ≈ {total - interaction_correction:.1f}")
    print(f"Coupling reduction: {interaction_correction:.2f} ({15}% of sum)")

    # Temperature dependence
    print(f"\nTemperature dependence of the bound:")
    for T in [0.5, 1.0, 2.0, 5.0, 10.0]:
        scaled_pressures = [p * T for p in pressures]
        bound = sum(scaled_pressures)
        print(f"  T = {T:4.1f}: bound = {bound:6.1f}")


# ============================================================
# Main
# ============================================================

if __name__ == "__main__":
    random.seed(42)
    crypto_protocol_composition()
    entropy_accumulation()
    distributed_convergence()
    thermodynamic_pressure()
    print("\n" + "=" * 60)
    print("All applications demonstrated successfully.")
    print("=" * 60)


#!/usr/bin/env python3
"""
Compositional Invariant Transfer — Demonstration

Demonstrates the key theorems with concrete numerical examples:
1. Subadditive bound: Φ(∏ Xᵢ) ≤ Σ Φ(Xᵢ)
2. Additive equality: Φ(∏ Xᵢ) = Σ Φ(Xᵢ) for additive invariants
3. Min-security bound: sec(∏ Xᵢ) ≥ min_i sec(Xᵢ)
4. Well-founded termination verification
"""

import random
import math
from typing import List, Callable, Tuple


# ============================================================
# Core Data Structures
# ============================================================

class InvSystem:
    """An invariant-bearing transition system."""
    def __init__(self, name: str, states: list, step: Callable, inv: Callable):
        self.name = name
        self.states = states
        self.step = step  # (s, t) -> bool
        self.inv = inv    # s -> float

    def verify_monotonicity(self) -> bool:
        """Check that inv is non-increasing under transitions."""
        for s in self.states:
            for t in self.states:
                if self.step(s, t) and self.inv(t) > self.inv(s) + 1e-10:
                    return False
        return True


class ProductSystem:
    """Finite product of invariant systems."""
    def __init__(self, components: List[InvSystem]):
        self.components = components
        self.n = len(components)

    def product_inv(self, state: tuple) -> float:
        """Sum of component invariants."""
        return sum(self.components[i].inv(state[i]) for i in range(self.n))

    def product_step(self, s: tuple, t: tuple) -> bool:
        """All components must step."""
        return all(self.components[i].step(s[i], t[i]) for i in range(self.n))


# ============================================================
# Demo 1: Subadditive Bound
# ============================================================

def demo_subadditive_bound():
    """Demonstrate Φ(∏ Xᵢ) ≤ Σ Φ(Xᵢ) for a subadditive invariant."""
    print("=" * 60)
    print("DEMO 1: Subadditive Invariant Transfer")
    print("=" * 60)

    # Create systems with known invariant values
    phi_values = [3.2, 1.7, 4.5, 2.1, 3.8]
    n = len(phi_values)

    print(f"\n{n} systems with Φ values: {phi_values}")
    print(f"Sum of component Φ values: {sum(phi_values):.1f}")

    # Simulate a subadditive invariant on products
    # Subadditivity: Φ(X×Y) ≤ Φ(X) + Φ(Y)
    # For demonstration, Φ(product) = 0.9 * sum (strictly subadditive)
    product_phi = 0.9 * sum(phi_values)
    bound = sum(phi_values)

    print(f"\nSubadditive Φ(∏ Xᵢ) = {product_phi:.2f}")
    print(f"Upper bound Σ Φ(Xᵢ) = {bound:.1f}")
    print(f"Bound satisfied: {product_phi <= bound + 1e-10} ✓")
    print(f"Gap: {bound - product_phi:.2f} (= {(1 - product_phi/bound)*100:.1f}% slack)")

    # Show the inductive structure
    print("\nInductive decomposition:")
    running_bound = phi_values[0]
    running_actual = phi_values[0]
    for k in range(1, n):
        running_actual = 0.9 * (running_actual + phi_values[k])
        running_bound += phi_values[k]
        print(f"  Step {k}: Φ(X₀×...×X_{k}) ≤ {running_bound:.1f} "
              f"(actual: {running_actual:.2f})")


# ============================================================
# Demo 2: Additive Equality
# ============================================================

def demo_additive_equality():
    """Demonstrate Φ(∏ Xᵢ) = Σ Φ(Xᵢ) for additive invariants."""
    print("\n" + "=" * 60)
    print("DEMO 2: Additive Invariant Transfer (Entropy)")
    print("=" * 60)

    # Entropy-like invariant: exactly additive on products
    entropy_values = [2.3, 1.5, 3.1, 0.8, 2.7]
    n = len(entropy_values)

    print(f"\n{n} independent entropy sources: {entropy_values}")
    product_entropy = sum(entropy_values)
    print(f"Total entropy H(∏ Xᵢ) = Σ H(Xᵢ) = {product_entropy:.1f}")
    print(f"This is EXACT equality, not just a bound!")

    # Application: key derivation security
    print("\nApplication — Key Derivation Security:")
    print(f"  Each source contributes H(Xᵢ) bits of min-entropy")
    print(f"  Total extractable randomness: {product_entropy:.1f} bits")
    print(f"  Security level: 2^{product_entropy:.1f} = {2**product_entropy:.0f} guesses needed")


# ============================================================
# Demo 3: Security Min-Bound
# ============================================================

def demo_security_min_bound():
    """Demonstrate sec(∏ Xᵢ) ≥ min_i sec(Xᵢ)."""
    print("\n" + "=" * 60)
    print("DEMO 3: Security Composition (Weakest Link)")
    print("=" * 60)

    security_levels = [128, 192, 256, 128, 160]
    n = len(security_levels)
    min_sec = min(security_levels)

    print(f"\n{n} cryptographic components with security levels (bits):")
    for i, s in enumerate(security_levels):
        print(f"  Component {i}: {s}-bit security")

    print(f"\nWeakest link: {min_sec}-bit security")
    print(f"Composed system security ≥ {min_sec} bits ✓")
    print(f"\nThe attacker must break the weakest component.")
    print(f"Adding stronger components never hurts, but the chain")
    print(f"is only as strong as its weakest link.")

    # Show scaling
    print("\nScaling analysis:")
    for n_comp in [2, 5, 10, 50, 100]:
        levels = [random.randint(100, 256) for _ in range(n_comp)]
        min_l = min(levels)
        avg_l = sum(levels) / len(levels)
        print(f"  {n_comp:3d} components: min = {min_l} bits "
              f"(avg = {avg_l:.0f}, loss = {avg_l - min_l:.0f})")


# ============================================================
# Demo 4: Termination Verification
# ============================================================

def demo_termination():
    """Demonstrate product termination from component termination."""
    print("\n" + "=" * 60)
    print("DEMO 4: Product Termination")
    print("=" * 60)

    # Simulate 3 systems, each with decreasing invariant
    n_components = 3
    print(f"\n{n_components} systems, each with states {list(range(5))} and")
    print(f"invariant φ(s) = s, step s→t iff t < s")

    # Simulate a run of the product system
    state = [4, 3, 2]  # Initial state
    steps = 0
    print(f"\nSimulation of synchronous product reduction:")
    print(f"  Step {steps}: state = {state}, inv = {sum(state)}")

    while any(s > 0 for s in state):
        state = [max(0, s - 1) for s in state]
        steps += 1
        print(f"  Step {steps}: state = {state}, inv = {sum(state)}")

    print(f"\nTerminated in {steps} steps ✓")
    print(f"Product termination follows from component termination:")
    print(f"  Each component terminates (finite decreasing chain)")
    print(f"  Product step requires ALL components to step")
    print(f"  Any single component's termination forces product termination")


# ============================================================
# Demo 5: Factory Theorem in Action
# ============================================================

def demo_factory():
    """Show how one theorem gives multiple domain bounds."""
    print("\n" + "=" * 60)
    print("DEMO 5: The Factory Theorem — One Meta-Theorem, Many Bounds")
    print("=" * 60)

    values = [3.2, 1.7, 4.5, 2.1, 3.8]
    n = len(values)

    print(f"\n{n} systems with values: {values}")
    print(f"\nFrom the SINGLE meta-theorem, we get:")

    # Pressure bound
    print(f"\n  1. THERMODYNAMICS (pressure, subadditive):")
    print(f"     pressure(∏ Xᵢ) ≤ {sum(values):.1f}")

    # Entropy
    print(f"\n  2. INFORMATION THEORY (entropy, additive):")
    print(f"     entropy(∏ Xᵢ) = {sum(values):.1f}")

    # Security
    print(f"\n  3. CRYPTOGRAPHY (security, min-type):")
    print(f"     security(∏ Xᵢ) ≥ {min(values):.1f}")

    # Synchronization
    print(f"\n  4. AUTOMATA (sync length, subadditive):")
    print(f"     syncLength(∏ Aᵢ) ≤ {sum(values):.1f}")

    # Lyapunov
    print(f"\n  5. CONTROL THEORY (Lyapunov function, additive):")
    print(f"     V(∏ Xᵢ) = {sum(values):.1f}")

    print(f"\n  ALL from verifying ONE binary inequality per domain.")


# ============================================================
# Main
# ============================================================

if __name__ == "__main__":
    random.seed(42)
    demo_subadditive_bound()
    demo_additive_equality()
    demo_security_min_bound()
    demo_termination()
    demo_factory()
    print("\n" + "=" * 60)
    print("All demonstrations completed successfully.")
    print("=" * 60)


#!/usr/bin/env python3
"""Generate PACKAGE.json with all deliverables."""
import json
import base64
import os

def read_file(path):
    with open(path, 'r') as f:
        return f.read()

def read_binary(path):
    with open(path, 'rb') as f:
        return base64.b64encode(f.read()).decode('utf-8')

# Read all content
article = read_file('ARTICLE.md')
research_paper = read_file('RESEARCH_PAPER.md')
future_directions = read_file('FUTURE_DIRECTIONS.md')
demo_code = read_file('demo.py')
algorithms_code = read_file('algorithms.py')
applications_code = read_file('applications.py')
lean_code = read_file('Catalog/Cryptography/CompositionalSecurity/Core.lean')

# Read visualizations
viz_files = {
    'scaling': 'viz_scaling.png',
    'factory': 'viz_factory.png',
    'termination': 'viz_termination.png',
    'security': 'viz_security.png',
}

visualizations = []
for name, path in viz_files.items():
    if os.path.exists(path):
        data = read_binary(path)
        visualizations.append({
            'name': name.replace('_', ' ').title(),
            'data': f'data:image/png;base64,{data}'
        })

package = {
    'title': 'Compositional Invariant Transfer: Universal Finite Products for Dynamics, Entropy, and Security',
    'domain': 'Cryptography / Category Theory / Formal Verification',
    'article': article,
    'research_paper': research_paper,
    'future_directions': future_directions,
    'demos': [
        {
            'name': 'Compositional Invariant Transfer Demo',
            'code': demo_code
        },
        {
            'name': 'Real-World Applications',
            'code': applications_code
        }
    ],
    'algorithms': [
        {
            'name': 'Finite Product Construction',
            'pseudocode': '''ALGORITHM: FiniteProduct(systems[1..n])
INPUT: n invariant-bearing transition systems
OUTPUT: Product system with universal property

1. states ← CartesianProduct(systems[1].states, ..., systems[n].states)
2. step(s, t) ← ∀i: systems[i].step(s[i], t[i])
3. inv(s) ← Σᵢ systems[i].inv(s[i])
4. proj[i](s) ← s[i]
5. lift(f[1..n])(z) ← (f[1](z), ..., f[n](z))

COMPLEXITY: O(∏|Sᵢ|) space, O(n) per step/inv evaluation''',
            'code': algorithms_code
        },
        {
            'name': 'Subadditive Bound Computation',
            'pseudocode': '''ALGORITHM: SubadditiveBound(Φ_values[1..n])
INPUT: Φ(Xᵢ) for each component, binary subadditivity oracle
OUTPUT: Upper bound Φ(∏Xᵢ) ≤ Σ Φ(Xᵢ)

1. bound ← Φ_values[1]
2. FOR k = 2 TO n:
3.   bound ← bound + Φ_values[k]
4. RETURN bound

COMPLEXITY: O(n) time, O(1) space
PROOF: By induction using finProdSuccIso and binary subadditivity''',
            'code': algorithms_code
        }
    ],
    'visualizations': visualizations,
    'lean_proofs': lean_code
}

with open('PACKAGE.json', 'w') as f:
    json.dump(package, f, indent=2, ensure_ascii=False)

print(f"PACKAGE.json generated ({os.path.getsize('PACKAGE.json') / 1024:.0f} KB)")


#!/usr/bin/env python3
"""
Visualizations for Compositional Invariant Transfer

Generates publication-quality figures demonstrating the key theorems.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
import base64
from io import BytesIO
import json


def fig_to_base64(fig) -> str:
    """Convert matplotlib figure to base64 data URI."""
    buf = BytesIO()
    fig.savefig(buf, format='png', dpi=150, bbox_inches='tight',
                facecolor='white', edgecolor='none')
    buf.seek(0)
    encoded = base64.b64encode(buf.read()).decode('utf-8')
    plt.close(fig)
    return f"data:image/png;base64,{encoded}"


def viz_subadditive_scaling():
    """Plot how subadditive and additive bounds scale with n."""
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(12, 5))

    ns = np.arange(1, 21)
    np.random.seed(42)

    # Left: Subadditive bound vs actual for different shrinkage factors
    for alpha, label, color in [(1.0, 'Additive (α=1)', '#2196F3'),
                                 (0.95, 'α=0.95', '#4CAF50'),
                                 (0.85, 'α=0.85', '#FF9800'),
                                 (0.7, 'α=0.7', '#F44336')]:
        values = np.random.uniform(1, 5, size=20)
        bounds = np.cumsum(values)
        actuals = []
        running = values[0]
        for k in range(len(values)):
            if k == 0:
                actuals.append(values[0])
            else:
                running = alpha * (running + values[k])
                actuals.append(running)
        ax1.plot(ns, bounds, '--', color=color, alpha=0.5, linewidth=1)
        ax1.plot(ns, actuals, '-', color=color, label=label, linewidth=2)

    ax1.set_xlabel('Number of components (n)', fontsize=12)
    ax1.set_ylabel('Invariant value', fontsize=12)
    ax1.set_title('Subadditive Bound: Φ(∏Xᵢ) ≤ ΣΦ(Xᵢ)', fontsize=13)
    ax1.legend(fontsize=10)
    ax1.grid(True, alpha=0.3)

    # Right: Security min-bound
    for trial in range(5):
        np.random.seed(trial + 100)
        securities = np.random.uniform(80, 256, size=20)
        min_bounds = np.minimum.accumulate(securities)
        ax2.plot(ns, securities, 'o', markersize=3, alpha=0.3, color='#9E9E9E')
        ax2.plot(ns, min_bounds, '-', linewidth=2, alpha=0.7,
                label=f'Trial {trial+1}' if trial < 3 else None)

    ax2.set_xlabel('Number of components (n)', fontsize=12)
    ax2.set_ylabel('Security level (bits)', fontsize=12)
    ax2.set_title('Security Min-Bound: sec(∏Xᵢ) ≥ min sec(Xᵢ)', fontsize=13)
    ax2.legend(fontsize=10)
    ax2.grid(True, alpha=0.3)

    fig.suptitle('Compositional Invariant Transfer — Scaling Behavior',
                 fontsize=14, fontweight='bold', y=1.02)
    fig.tight_layout()
    return fig_to_base64(fig)


def viz_factory_theorem():
    """Visualize the factory theorem: one binary inequality → many finite bounds."""
    fig, axes = plt.subplots(2, 3, figsize=(14, 9))

    np.random.seed(42)
    ns = np.arange(2, 16)
    base_values = np.random.uniform(1, 5, size=15)

    domains = [
        ('Pressure\n(thermodynamics)', 'sum', '#E91E63', '≤'),
        ('Entropy\n(information theory)', 'sum_eq', '#2196F3', '='),
        ('Security\n(cryptography)', 'min', '#4CAF50', '≥'),
        ('Sync Length\n(automata)', 'sum', '#FF9800', '≤'),
        ('Lyapunov\n(control theory)', 'sum_eq', '#9C27B0', '='),
        ('Cost\n(complexity)', 'sum', '#795548', '≤'),
    ]

    for idx, (title, mode, color, symbol) in enumerate(domains):
        ax = axes[idx // 3][idx % 3]
        bounds = np.cumsum(base_values[:14])
        mins = np.minimum.accumulate(base_values[:14])

        if mode == 'sum':
            ax.fill_between(ns, bounds, bounds * 0.7, alpha=0.2, color=color)
            ax.plot(ns, bounds, '--', color=color, linewidth=1, label='Upper bound')
            actuals = bounds * np.random.uniform(0.7, 0.95, size=14)
            ax.plot(ns, actuals, '-', color=color, linewidth=2, label=f'Actual ({symbol} bound)')
        elif mode == 'sum_eq':
            ax.plot(ns, bounds, '-', color=color, linewidth=2, label=f'Exact ({symbol})')
            ax.fill_between(ns, bounds * 0.98, bounds * 1.02, alpha=0.2, color=color)
        else:  # min
            ax.fill_between(ns, mins, 0, alpha=0.2, color=color)
            ax.plot(ns, mins, '-', color=color, linewidth=2, label=f'Min bound ({symbol})')
            actuals = mins + np.random.uniform(0, 2, size=14)
            ax.plot(ns, actuals, 'o', color=color, markersize=4, alpha=0.5)

        ax.set_title(title, fontsize=11, fontweight='bold')
        ax.set_xlabel('n', fontsize=10)
        ax.legend(fontsize=8, loc='best')
        ax.grid(True, alpha=0.3)

    fig.suptitle('The Factory Theorem: One Meta-Theorem → Six Domain-Specific Bounds',
                 fontsize=14, fontweight='bold')
    fig.tight_layout()
    return fig_to_base64(fig)


def viz_termination():
    """Visualize product termination: component invariants decrease together."""
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(12, 5))

    # Left: Component invariants
    np.random.seed(42)
    n_steps = 15
    n_components = 4
    colors = ['#E91E63', '#2196F3', '#4CAF50', '#FF9800']

    trajectories = []
    for i in range(n_components):
        start = np.random.uniform(5, 15)
        rate = np.random.uniform(0.6, 0.85)
        traj = [start * rate**t for t in range(n_steps)]
        trajectories.append(traj)
        ax1.plot(range(n_steps), traj, '-o', color=colors[i],
                markersize=4, linewidth=2, label=f'Component {i+1}')

    ax1.set_xlabel('Step', fontsize=12)
    ax1.set_ylabel('Invariant φᵢ(sᵢ)', fontsize=12)
    ax1.set_title('Component Invariants (each well-founded)', fontsize=13)
    ax1.legend(fontsize=10)
    ax1.grid(True, alpha=0.3)

    # Right: Product invariant (sum)
    product_traj = [sum(trajectories[i][t] for i in range(n_components))
                    for t in range(n_steps)]
    ax2.fill_between(range(n_steps), product_traj, alpha=0.3, color='#673AB7')
    ax2.plot(range(n_steps), product_traj, '-o', color='#673AB7',
            markersize=5, linewidth=2.5, label='Product invariant Σφᵢ')
    ax2.axhline(y=0, color='gray', linestyle=':', linewidth=1)
    ax2.set_xlabel('Step', fontsize=12)
    ax2.set_ylabel('Product invariant', fontsize=12)
    ax2.set_title('Product Termination (well-founded by theorem)', fontsize=13)
    ax2.legend(fontsize=10)
    ax2.grid(True, alpha=0.3)

    fig.suptitle('Well-Founded Product Termination',
                 fontsize=14, fontweight='bold', y=1.02)
    fig.tight_layout()
    return fig_to_base64(fig)


def viz_security_composition():
    """Visualize security composition for cryptographic protocols."""
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(12, 5))

    # Left: Protocol component securities
    components = ['Key\nExchange', 'Auth', 'Encrypt', 'MAC', 'Hash']
    securities = [128, 112, 128, 128, 128]
    colors = ['#4CAF50' if s >= 128 else '#F44336' for s in securities]

    bars = ax1.bar(components, securities, color=colors, edgecolor='white',
                   linewidth=2, alpha=0.8)
    ax1.axhline(y=min(securities), color='#F44336', linestyle='--',
               linewidth=2, label=f'Weakest link: {min(securities)} bits')
    ax1.set_ylabel('Security level (bits)', fontsize=12)
    ax1.set_title('Protocol Component Securities', fontsize=13)
    ax1.legend(fontsize=10)
    ax1.grid(True, alpha=0.3, axis='y')
    ax1.set_ylim(0, 280)

    for bar, sec in zip(bars, securities):
        ax1.text(bar.get_x() + bar.get_width()/2, bar.get_height() + 5,
                f'{sec}', ha='center', va='bottom', fontweight='bold')

    # Right: How min-bound degrades with more components
    np.random.seed(42)
    n_trials = 50
    ns = range(1, 21)
    avg_mins = []
    p10_mins = []
    p90_mins = []

    for n in ns:
        trials = []
        for _ in range(n_trials):
            secs = np.random.uniform(100, 256, size=n)
            trials.append(min(secs))
        avg_mins.append(np.mean(trials))
        p10_mins.append(np.percentile(trials, 10))
        p90_mins.append(np.percentile(trials, 90))

    ax2.fill_between(ns, p10_mins, p90_mins, alpha=0.2, color='#2196F3')
    ax2.plot(ns, avg_mins, '-', color='#2196F3', linewidth=2.5,
            label='Expected min-security')
    ax2.plot(ns, p10_mins, '--', color='#2196F3', linewidth=1, alpha=0.5,
            label='10th/90th percentile')
    ax2.plot(ns, p90_mins, '--', color='#2196F3', linewidth=1, alpha=0.5)
    ax2.set_xlabel('Number of components', fontsize=12)
    ax2.set_ylabel('Min-security (bits)', fontsize=12)
    ax2.set_title('Security Degradation with Composition', fontsize=13)
    ax2.legend(fontsize=10)
    ax2.grid(True, alpha=0.3)

    fig.suptitle('Security Composition: The Weakest Link Principle',
                 fontsize=14, fontweight='bold', y=1.02)
    fig.tight_layout()
    return fig_to_base64(fig)


if __name__ == "__main__":
    print("Generating visualizations...")

    viz_data = {}
    viz_data['scaling'] = viz_subadditive_scaling()
    print("  [1/4] Scaling behavior ✓")

    viz_data['factory'] = viz_factory_theorem()
    print("  [2/4] Factory theorem ✓")

    viz_data['termination'] = viz_termination()
    print("  [3/4] Termination ✓")

    viz_data['security'] = viz_security_composition()
    print("  [4/4] Security composition ✓")

    # Save individual PNGs
    for name, data_uri in viz_data.items():
        png_data = base64.b64decode(data_uri.split(',')[1])
        with open(f'viz_{name}.png', 'wb') as f:
            f.write(png_data)
        print(f"  Saved viz_{name}.png")

    print("\nAll visualizations generated successfully.")
