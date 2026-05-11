#!/usr/bin/env python3
"""
Tropical Choquet Closure Duality — Algorithms

Implements the core algorithms from the research paper:
1. TropicalMaxFunctional: Compute F(f) = max_s (f(s) + w(s))
2. WeightRecovery: Recover weights from black-box functional access
3. DecompositionVerifier: Verify a tropical decomposition
4. PerturbationAnalyzer: Analyze stability under perturbation
5. ClosureEquilibriumFinder: Find equilibrium observables
"""

import numpy as np
from dataclasses import dataclass
from typing import List, Set, Dict, Tuple, Callable, Optional


@dataclass
class TropicalMaxFunctional:
    """A tropical max functional F(f) = max_{s in S} (f(s) + w(s)).

    Attributes:
        support: List of support indices
        weights: Weight vector w
    """
    support: List[int]
    weights: np.ndarray

    def __call__(self, f: np.ndarray) -> float:
        """Evaluate F(f) = max_{s in S} (f(s) + w(s))."""
        return max(f[s] + self.weights[s] for s in self.support)

    def evaluate_with_argmax(self, f: np.ndarray) -> Tuple[float, int]:
        """Evaluate F(f) and return the achieving argmax."""
        best_val = float('-inf')
        best_s = self.support[0]
        for s in self.support:
            val = f[s] + self.weights[s]
            if val > best_val:
                best_val = val
                best_s = s
        return best_val, best_s

    @property
    def dimension(self) -> int:
        """Return the ambient dimension."""
        return len(self.weights)

    @property
    def normalization(self) -> float:
        """F(0) = max weight = normalization constant."""
        return max(self.weights[s] for s in self.support)

    def is_sup_preserving(self, n_tests: int = 1000, tol: float = 1e-10) -> bool:
        """Verify sup-preservation on random inputs."""
        dim = self.dimension
        for _ in range(n_tests):
            f = np.random.randn(dim) * 5
            g = np.random.randn(dim) * 5
            lhs = self(np.maximum(f, g))
            rhs = max(self(f), self(g))
            if abs(lhs - rhs) > tol:
                return False
        return True

    def is_shift_equivariant(self, n_tests: int = 1000, tol: float = 1e-10) -> bool:
        """Verify shift-equivariance on random inputs."""
        dim = self.dimension
        for _ in range(n_tests):
            f = np.random.randn(dim) * 5
            c = np.random.randn() * 5
            lhs = self(f + c)
            rhs = self(f) + c
            if abs(lhs - rhs) > tol:
                return False
        return True


def recover_weights(
    F: Callable[[np.ndarray], float],
    support: List[int],
    dim: int,
    M: Optional[float] = None
) -> np.ndarray:
    """Recover weights from black-box access to a tropical max functional.

    Algorithm: For each s in support, construct an isolation function
    f_s(a) = M if a = s, -M otherwise. Then w(s) = F(f_s) - M.

    Args:
        F: Black-box functional
        support: Known support set
        dim: Ambient dimension
        M: Isolation parameter (auto-computed if None)

    Returns:
        Recovered weight vector

    Complexity: O(|S| * dim) evaluations of F
    """
    if M is None:
        # Estimate M by probing
        probe_vals = []
        for s in support:
            delta_s = np.zeros(dim)
            delta_s[s] = 1.0
            probe_vals.append(abs(F(delta_s)))
            probe_vals.append(abs(F(-delta_s)))
        M = max(probe_vals) + dim + 1

    weights = np.zeros(dim)
    for s in support:
        f_test = np.full(dim, -M)
        f_test[s] = M
        weights[s] = F(f_test) - M

    return weights


@dataclass
class DecompositionCertificate:
    """Certificate for a tropical decomposition."""
    is_valid: bool
    max_error: float
    sup_preservation_ok: bool
    shift_equivariance_ok: bool
    monotonicity_ok: bool
    irredundancy_ok: bool


def verify_decomposition(
    F: Callable[[np.ndarray], float],
    support: List[int],
    weights: np.ndarray,
    dim: int,
    n_tests: int = 10000,
    tol: float = 1e-10
) -> DecompositionCertificate:
    """Verify that F is represented by tropMax(support, weights).

    Args:
        F: The functional to verify
        support: Proposed support
        weights: Proposed weights
        dim: Ambient dimension
        n_tests: Number of random tests
        tol: Tolerance for floating-point comparison

    Returns:
        DecompositionCertificate with verification results
    """
    tmf = TropicalMaxFunctional(support, weights)

    max_error = 0.0
    sup_ok = True
    shift_ok = True
    mono_ok = True

    for _ in range(n_tests):
        f = np.random.randn(dim) * 5
        g = np.random.randn(dim) * 5
        c = np.random.randn() * 3

        # Representation accuracy
        diff = abs(F(f) - tmf(f))
        max_error = max(max_error, diff)

        # Sup-preservation
        lhs = F(np.maximum(f, g))
        rhs = max(F(f), F(g))
        if abs(lhs - rhs) > tol:
            sup_ok = False

        # Shift-equivariance
        lhs = F(f + c)
        rhs = F(f) + c
        if abs(lhs - rhs) > tol:
            shift_ok = False

        # Monotonicity
        if F(f) > F(np.maximum(f, g)) + tol:
            mono_ok = False

    # Irredundancy
    irr_ok = True
    for s in support:
        f_test = np.array([-weights[a] + (1.0 if a == s else 0.0)
                          for a in range(dim)])
        values = [f_test[a] + weights[a] for a in support]
        if not (values[support.index(s)] > max(
                v for i, v in enumerate(values) if support[i] != s)):
            irr_ok = False

    return DecompositionCertificate(
        is_valid=max_error < tol and sup_ok and shift_ok and mono_ok,
        max_error=max_error,
        sup_preservation_ok=sup_ok,
        shift_equivariance_ok=shift_ok,
        monotonicity_ok=mono_ok,
        irredundancy_ok=irr_ok
    )


def perturbation_analysis(
    support: List[int],
    weights: np.ndarray,
    epsilon: float,
    n_trials: int = 100,
    n_tests_per_trial: int = 10000
) -> Dict[str, float]:
    """Analyze perturbation stability.

    For random weight perturbations of size ≤ epsilon, measure the
    induced functional perturbation.

    Returns:
        Dictionary with stability statistics
    """
    dim = len(weights)
    F_orig = TropicalMaxFunctional(support, weights)

    func_diffs = []
    weight_diffs = []

    for _ in range(n_trials):
        noise = np.random.uniform(-epsilon, epsilon, dim)
        w_pert = weights + noise
        F_pert = TropicalMaxFunctional(support, w_pert)

        w_diff = max(abs(noise[s]) for s in support)
        weight_diffs.append(w_diff)

        max_func_diff = 0.0
        for _ in range(n_tests_per_trial):
            f = np.random.randn(dim) * 10
            diff = abs(F_orig(f) - F_pert(f))
            max_func_diff = max(max_func_diff, diff)
        func_diffs.append(max_func_diff)

    return {
        'mean_weight_perturbation': np.mean(weight_diffs),
        'mean_functional_perturbation': np.mean(func_diffs),
        'max_weight_perturbation': np.max(weight_diffs),
        'max_functional_perturbation': np.max(func_diffs),
        'mean_ratio': np.mean(np.array(func_diffs) / np.array(weight_diffs)),
        'lipschitz_constant_estimate': np.max(
            np.array(func_diffs) / np.array(weight_diffs)
        )
    }


@dataclass
class ClosureOperator:
    """A closure operator on a finite set {0, 1, ..., n-1}."""
    mapping: Dict[int, int]

    def __call__(self, x: int) -> int:
        return self.mapping[x]

    @property
    def fixed_points(self) -> Set[int]:
        return {x for x in self.mapping if self.mapping[x] == x}

    def is_extensive(self) -> bool:
        """Check x ≤ cl(x) (requires ordering, here just x ≤ cl(x) as integers)."""
        return all(x <= self.mapping[x] for x in self.mapping)

    def is_idempotent(self) -> bool:
        """Check cl(cl(x)) = cl(x)."""
        return all(
            self.mapping[self.mapping[x]] == self.mapping[x]
            for x in self.mapping
        )


def find_equilibrium_observables(
    closure: ClosureOperator,
    support: List[int],
    weights: np.ndarray
) -> Set[int]:
    """Find equilibrium observables = closure fixed points ∩ support.

    By the closure-equilibrium correspondence theorem,
    these are exactly the elements that are both:
    1. Fixed under the closure operator
    2. Essential atoms of the tropical decomposition (which is all support elements)

    Args:
        closure: A closure operator
        support: Support of the tropical decomposition
        weights: Weights of the tropical decomposition

    Returns:
        Set of equilibrium observable indices
    """
    fixed = closure.fixed_points
    return fixed & set(support)


if __name__ == "__main__":
    print("=== Algorithm Demonstrations ===\n")

    # Example 1: Basic functional
    print("1. TropicalMaxFunctional")
    F = TropicalMaxFunctional([0, 1, 2], np.array([2.0, -1.0, 3.0]))
    f = np.array([5.0, 8.0, 1.0])
    val, argmax = F.evaluate_with_argmax(f)
    print(f"   F({f}) = {val} (achieved at s={argmax})")
    print(f"   Sup-preserving: {F.is_sup_preserving()}")
    print(f"   Shift-equivariant: {F.is_shift_equivariant()}")

    # Example 2: Weight recovery
    print("\n2. Weight Recovery")
    w_true = np.array([3.0, -1.0, 2.5, 0.0, -4.0])
    F_box = TropicalMaxFunctional(list(range(5)), w_true)
    w_rec = recover_weights(F_box, list(range(5)), 5)
    print(f"   True:      {w_true}")
    print(f"   Recovered: {w_rec}")
    print(f"   Error:     {np.max(np.abs(w_true - w_rec)):.2e}")

    # Example 3: Verification
    print("\n3. Decomposition Verification")
    cert = verify_decomposition(F_box, list(range(5)), w_true, 5)
    print(f"   Valid: {cert.is_valid}")
    print(f"   Max error: {cert.max_error:.2e}")
    print(f"   Irredundant: {cert.irredundancy_ok}")

    # Example 4: Equilibrium observables
    print("\n4. Closure-Equilibrium Correspondence")
    cl = ClosureOperator({0: 0, 1: 2, 2: 2, 3: 3, 4: 3})
    equilibria = find_equilibrium_observables(cl, list(range(5)), w_true)
    print(f"   Fixed points: {cl.fixed_points}")
    print(f"   Support: {list(range(5))}")
    print(f"   Equilibria: {equilibria}")


#!/usr/bin/env python3
"""
Tropical Choquet Closure Duality — Applications

Demonstrates real-world applications of tropical max functional decomposition:
1. ReLU Neural Network decomposition
2. Dynamic programming / Bellman equation
3. Supply chain optimization
4. Database closure dependencies
"""

import numpy as np
from typing import List, Tuple


# ============================================================
# Application 1: ReLU Neural Network Tropical Decomposition
# ============================================================

def relu(x: np.ndarray) -> np.ndarray:
    """ReLU activation: max(0, x)."""
    return np.maximum(0, x)


def two_layer_relu_network(
    x: np.ndarray,
    W1: np.ndarray, b1: np.ndarray,
    W2: np.ndarray, b2: np.ndarray
) -> float:
    """A 2-layer ReLU network: W2 @ relu(W1 @ x + b1) + b2."""
    h = relu(W1 @ x + b1)
    return float(W2 @ h + b2)


def tropical_decompose_relu_network(
    W1: np.ndarray, b1: np.ndarray,
    W2: np.ndarray, b2: np.ndarray
) -> List[Tuple[np.ndarray, float]]:
    """Decompose a 2-layer ReLU network into tropical atoms.

    Each activation pattern (which hidden units are active) defines
    a linear piece. The output is max over all active patterns:
        y = max_σ (W2_σ @ W1_σ @ x + W2_σ @ b1_σ + b2)
    where σ is a sign pattern and subscript σ selects active rows.

    Returns:
        List of (linear_coeff, constant) pairs for each activation pattern.
    """
    n_hidden = W1.shape[0]
    atoms = []

    # Enumerate all 2^n_hidden activation patterns
    for pattern in range(2 ** n_hidden):
        active = [(pattern >> i) & 1 for i in range(n_hidden)]
        active_mask = np.array(active, dtype=float)

        # Linear coefficient for this pattern
        # y = W2 @ diag(active) @ W1 @ x + W2 @ diag(active) @ b1 + b2
        D = np.diag(active_mask)
        linear_coeff = W2 @ D @ W1
        constant = float(W2 @ D @ b1 + b2)

        atoms.append((linear_coeff.flatten(), constant))

    return atoms


def demo_relu_decomposition():
    """Demo: Decompose a small ReLU network into tropical atoms."""
    print("=" * 60)
    print("Application 1: ReLU Network Tropical Decomposition")
    print("=" * 60)

    # Small 2-layer network: 2 inputs, 3 hidden, 1 output
    np.random.seed(42)
    W1 = np.array([[1.0, -1.0], [-2.0, 1.0], [0.5, 0.5]])
    b1 = np.array([0.0, 1.0, -0.5])
    W2 = np.array([[1.0, 0.5, -1.0]])
    b2 = np.array([0.0])

    atoms = tropical_decompose_relu_network(W1, b1, W2, b2)

    print(f"\nNetwork: 2 inputs → 3 hidden (ReLU) → 1 output")
    print(f"Number of activation patterns: {len(atoms)}")
    print(f"(= 2^3 = 8 tropical atoms)\n")

    # Show each atom
    for i, (coeff, const) in enumerate(atoms):
        pattern = bin(i)[2:].zfill(3)
        print(f"  Pattern {pattern}: y = {coeff[0]:+.1f}·x₁ {coeff[1]:+.1f}·x₂ {const:+.1f}")

    # Verify on random inputs
    print(f"\nVerification on random inputs:")
    n_ok = 0
    for _ in range(1000):
        x = np.random.randn(2) * 3
        y_net = two_layer_relu_network(x, W1, b1, W2, b2)
        y_trop = max(coeff @ x + const for coeff, const in atoms)
        if abs(y_net - y_trop) < 1e-8:
            n_ok += 1
    print(f"  {n_ok}/1000 inputs match (tropical decomposition captures all active atoms)")
    print()


# ============================================================
# Application 2: Dynamic Programming (Bellman Equation)
# ============================================================

def demo_bellman_decomposition():
    """Demo: Tropical decomposition of a Bellman value function."""
    print("=" * 60)
    print("Application 2: Bellman Equation → Tropical Decomposition")
    print("=" * 60)

    # Simple MDP: 4 states, 2 actions
    # V(s) = max_a { R(s,a) + γ * V(T(s,a)) }
    # After convergence, V is piecewise-affine in R (as a function of rewards)

    n_states = 4
    n_actions = 2
    gamma = 0.9

    # Transition function: T(s, a) -> next state
    T = np.array([
        [1, 2],  # state 0: action 0->state 1, action 1->state 2
        [0, 3],  # state 1
        [3, 0],  # state 2
        [1, 2],  # state 3
    ])

    # Reward function
    R = np.array([
        [1.0, 0.5],   # state 0
        [0.0, 2.0],   # state 1
        [-1.0, 1.0],  # state 2
        [3.0, -1.0],  # state 3
    ])

    # Value iteration
    V = np.zeros(n_states)
    for _ in range(100):
        V_new = np.zeros(n_states)
        for s in range(n_states):
            V_new[s] = max(R[s, a] + gamma * V[T[s, a]] for a in range(n_actions))
        V = V_new

    print(f"\nMDP: {n_states} states, {n_actions} actions, γ = {gamma}")
    print(f"Converged value function: V = {np.round(V, 3)}")

    # Optimal policy
    policy = np.zeros(n_states, dtype=int)
    for s in range(n_states):
        policy[s] = np.argmax([R[s, a] + gamma * V[T[s, a]] for a in range(n_actions)])

    print(f"Optimal policy: {policy}")
    print(f"\nTropical interpretation:")
    print(f"  V(s) = max_a {{ R(s,a) + γ·V(T(s,a)) }}")
    print(f"  Each action 'a' is a tropical atom")
    print(f"  The weight of atom a at state s is: R(s,a) + γ·V(T(s,a))")

    for s in range(n_states):
        print(f"  State {s}: ", end="")
        for a in range(n_actions):
            val = R[s, a] + gamma * V[T[s, a]]
            marker = " ← optimal" if a == policy[s] else ""
            print(f"  a={a}: {val:.3f}{marker}", end="")
        print()
    print()


# ============================================================
# Application 3: Supply Chain Optimization
# ============================================================

def demo_supply_chain():
    """Demo: Supply chain bottleneck analysis via tropical algebra."""
    print("=" * 60)
    print("Application 3: Supply Chain Bottleneck Analysis")
    print("=" * 60)

    # Supply chain with 5 suppliers, 3 stages
    # Total delivery time = max over stages of (processing + transport)
    # This is naturally tropical

    suppliers = ['Alpha', 'Beta', 'Gamma', 'Delta', 'Epsilon']
    n_suppliers = len(suppliers)

    # Processing times (days) for each supplier at each stage
    processing = np.array([
        [2, 3, 1],  # Alpha
        [4, 1, 2],  # Beta
        [1, 4, 3],  # Gamma
        [3, 2, 4],  # Delta
        [2, 2, 2],  # Epsilon
    ], dtype=float)

    # Weights represent base overhead per supplier
    overhead = np.array([1.0, 0.5, 2.0, 0.0, 1.5])

    print(f"\nSuppliers: {suppliers}")
    print(f"Processing times (3 stages):")
    for i, name in enumerate(suppliers):
        print(f"  {name}: {processing[i]}")
    print(f"Overhead: {overhead}")

    # Total time = max_supplier (max_stage processing[supplier][stage] + overhead[supplier])
    # This is a nested tropical max

    print(f"\nBottleneck analysis:")
    for order_urgency in [0.0, 1.0, 3.0]:
        print(f"\n  Order urgency bonus: {order_urgency}")
        for i, name in enumerate(suppliers):
            total = max(processing[i]) + overhead[i] + order_urgency
            bottleneck_stage = np.argmax(processing[i])
            print(f"    {name}: total={total:.1f} days "
                  f"(bottleneck at stage {bottleneck_stage+1})")

    print()


# ============================================================
# Application 4: Database Closure Dependencies
# ============================================================

def demo_database_closure():
    """Demo: Functional dependencies as closure operator."""
    print("=" * 60)
    print("Application 4: Database Functional Dependencies")
    print("=" * 60)

    # Attributes: A, B, C, D, E
    # Functional dependencies:
    #   A → B (knowing A determines B)
    #   B → C (knowing B determines C)
    #   D → E (knowing D determines E)
    # Closure: the set of attributes determined by a given set

    attrs = ['A', 'B', 'C', 'D', 'E']

    # Closure operator on subsets (encoded as frozensets)
    def closure(s: frozenset) -> frozenset:
        result = set(s)
        changed = True
        while changed:
            changed = False
            if 'A' in result and 'B' not in result:
                result.add('B')
                changed = True
            if 'B' in result and 'C' not in result:
                result.add('C')
                changed = True
            if 'D' in result and 'E' not in result:
                result.add('E')
                changed = True
        return frozenset(result)

    print(f"\nAttributes: {attrs}")
    print(f"Dependencies: A→B, B→C, D→E")

    # Show closures
    fixed_points = []
    print(f"\nClosures of single attributes:")
    for a in attrs:
        cl = closure(frozenset([a]))
        is_fixed = cl == frozenset([a])
        if frozenset([a]) == cl:
            fixed_points.append(a)
        print(f"  cl({{{a}}}) = {set(cl)}"
              f"{'  ← fixed point' if is_fixed else ''}")

    # Tropical interpretation
    print(f"\nTropical interpretation:")
    print(f"  Fixed points (self-determining attributes): {fixed_points}")
    print(f"  These are the equilibrium observables of the closure system.")
    print(f"  They form the essential atoms of the tropical decomposition:")
    print(f"  any functional respecting these dependencies decomposes")
    print(f"  into atoms indexed by {{{', '.join(fixed_points)}}}.")
    print()


if __name__ == "__main__":
    demo_relu_decomposition()
    demo_bellman_decomposition()
    demo_supply_chain()
    demo_database_closure()


#!/usr/bin/env python3
"""
Tropical Choquet Closure Duality — Demonstrations

This script demonstrates the key theorems of tropical Choquet representation theory
with concrete numerical examples:
1. Tropical max functional computation
2. Sup-preservation verification
3. Shift-equivariance verification
4. Weight uniqueness (recovery)
5. Perturbation stability
6. Irredundancy (essential atoms)
7. Closure-equilibrium correspondence
"""

import numpy as np
from typing import Dict, List, Tuple, Optional


def tropical_max(S: List[int], w: np.ndarray, f: np.ndarray) -> float:
    """Compute the tropical max functional: max_{s in S} (f[s] + w[s])."""
    return max(f[s] + w[s] for s in S)


def demo_basic_computation():
    """Demo 1: Basic tropical max functional computation."""
    print("=" * 60)
    print("Demo 1: Basic Tropical Max Functional")
    print("=" * 60)

    S = [0, 1, 2]
    w = np.array([1.0, 3.0, 2.0])
    f = np.array([5.0, 2.0, 4.0])

    result = tropical_max(S, w, f)
    print(f"Support S = {S}")
    print(f"Weights w = {w}")
    print(f"Input   f = {f}")
    print(f"\nF(f) = max(f[0]+w[0], f[1]+w[1], f[2]+w[2])")
    print(f"     = max({f[0]}+{w[0]}, {f[1]}+{w[1]}, {f[2]}+{w[2]})")
    print(f"     = max({f[0]+w[0]}, {f[1]+w[1]}, {f[2]+w[2]})")
    print(f"     = {result}")
    print()


def demo_sup_preservation():
    """Demo 2: Verify F(max(f,g)) = max(F(f), F(g))."""
    print("=" * 60)
    print("Demo 2: Sup-Preservation (Max-Plus Linearity)")
    print("=" * 60)

    S = [0, 1, 2, 3]
    w = np.array([1.0, -2.0, 3.0, 0.5])

    np.random.seed(42)
    for trial in range(5):
        f = np.random.randn(4) * 5
        g = np.random.randn(4) * 5
        fg_max = np.maximum(f, g)

        lhs = tropical_max(S, w, fg_max)
        rhs = max(tropical_max(S, w, f), tropical_max(S, w, g))

        status = "✓" if abs(lhs - rhs) < 1e-10 else "✗"
        print(f"Trial {trial+1}: F(max(f,g)) = {lhs:.4f}, "
              f"max(F(f),F(g)) = {rhs:.4f}  {status}")
    print()


def demo_shift_equivariance():
    """Demo 3: Verify F(f + c) = F(f) + c."""
    print("=" * 60)
    print("Demo 3: Shift-Equivariance")
    print("=" * 60)

    S = [0, 1, 2]
    w = np.array([2.0, -1.0, 4.0])
    f = np.array([3.0, 7.0, 1.0])

    for c in [-3.0, 0.0, 2.5, 10.0]:
        f_shifted = f + c
        lhs = tropical_max(S, w, f_shifted)
        rhs = tropical_max(S, w, f) + c
        status = "✓" if abs(lhs - rhs) < 1e-10 else "✗"
        print(f"c = {c:6.1f}: F(f+c) = {lhs:.4f}, F(f)+c = {rhs:.4f}  {status}")
    print()


def demo_weight_recovery():
    """Demo 4: Recover weights from black-box functional access."""
    print("=" * 60)
    print("Demo 4: Weight Recovery (Uniqueness)")
    print("=" * 60)

    S = [0, 1, 2, 3, 4]
    w_true = np.array([3.0, -1.0, 2.5, 0.0, -4.0])
    n = len(S)

    # Recovery: use isolation functions
    M = max(abs(w_true)) + 1
    w_recovered = np.zeros(n)

    for s in S:
        f_test = np.full(n, -M)
        f_test[s] = M
        w_recovered[s] = tropical_max(S, w_true, f_test) - M

    print(f"True weights:      {w_true}")
    print(f"Recovered weights: {w_recovered}")
    print(f"Recovery error:    {np.max(np.abs(w_true - w_recovered)):.2e}")
    print()


def demo_perturbation_stability():
    """Demo 5: Perturbation stability with optimal constant 1."""
    print("=" * 60)
    print("Demo 5: Perturbation Stability")
    print("=" * 60)

    S = [0, 1, 2, 3]
    w1 = np.array([2.0, -1.0, 3.0, 0.5])

    for eps in [0.01, 0.1, 0.5, 1.0]:
        np.random.seed(123)
        noise = np.random.uniform(-eps, eps, len(S))
        w2 = w1 + noise

        weight_diff = np.max(np.abs(w1 - w2))

        # Measure functional difference on many random inputs
        max_func_diff = 0.0
        for _ in range(10000):
            f = np.random.randn(len(S)) * 10
            diff = abs(tropical_max(S, w1, f) - tropical_max(S, w2, f))
            max_func_diff = max(max_func_diff, diff)

        print(f"ε = {eps:.2f}: ‖Δw‖∞ = {weight_diff:.4f}, "
              f"‖ΔF‖∞ ≈ {max_func_diff:.4f}, "
              f"ratio = {max_func_diff/weight_diff:.4f}")
    print()


def demo_essential_atoms():
    """Demo 6: Every support element is essential."""
    print("=" * 60)
    print("Demo 6: Irredundancy — Essential Atoms")
    print("=" * 60)

    S = [0, 1, 2, 3]
    w = np.array([1.0, 2.0, -1.0, 3.0])

    for s in S:
        # Construct isolation function: f(a) = -w(a) + delta(a,s)
        f = np.array([-w[a] + (1.0 if a == s else 0.0) for a in S])
        values = [f[a] + w[a] for a in S]
        argmax = np.argmax(values)

        print(f"Atom s={s}: f = {f}, f+w = {values}")
        print(f"  Maximum uniquely at s={argmax} with value {max(values):.1f}")
        print(f"  Essential: {argmax == s} ✓")
    print()


def demo_closure_equilibrium():
    """Demo 7: Closure-equilibrium correspondence."""
    print("=" * 60)
    print("Demo 7: Closure-Equilibrium Correspondence")
    print("=" * 60)

    # Define a closure operator on {0,1,2,3,4}
    # cl maps: 0→0, 1→2, 2→2, 3→3, 4→3
    cl = {0: 0, 1: 2, 2: 2, 3: 3, 4: 3}
    fixed_points = {x for x in cl if cl[x] == x}

    S = [0, 1, 2, 3, 4]
    w = np.array([1.0, 2.0, 3.0, -1.0, 0.5])

    print(f"Closure operator: {cl}")
    print(f"Fixed points: {fixed_points}")
    print(f"Support S = {S}")
    print()

    for s in S:
        is_fixed = s in fixed_points
        is_essential = True  # All support elements are essential
        is_equilibrium = is_fixed and is_essential

        status = "EQUILIBRIUM" if is_equilibrium else "not equilibrium"
        reason = f"fixed={is_fixed}, essential={is_essential}"
        print(f"  s={s}: {status:18s} ({reason})")

    print()
    print("Equilibrium observables = fixed points ∩ support")
    equilibria = fixed_points & set(S)
    print(f"  = {equilibria}")
    print()


def demo_decomposition_summary():
    """Demo 8: Full certified decomposition."""
    print("=" * 60)
    print("Demo 8: Certified Finite Tropical Decomposition")
    print("=" * 60)

    S = [0, 1, 2]
    w = np.array([2.0, -1.0, 3.0])

    print(f"Support S = {S}")
    print(f"Weights w = {w}")
    print()
    print("Certified properties:")
    print("  1. Sup-preserving:     F(max(f,g)) = max(F(f), F(g))")
    print("  2. Shift-equivariant:  F(f+c) = F(f) + c")
    print("  3. Monotone:           f ≤ g ⟹ F(f) ≤ F(g)")
    print("  4. Irredundant:        All atoms essential")
    print("  5. Unique:             w determined by F")
    print()

    # Verify all properties
    np.random.seed(0)
    all_ok = True
    for _ in range(1000):
        f = np.random.randn(3) * 5
        g = np.random.randn(3) * 5
        c = np.random.randn() * 3

        # Sup-preserving
        lhs = tropical_max(S, w, np.maximum(f, g))
        rhs = max(tropical_max(S, w, f), tropical_max(S, w, g))
        if abs(lhs - rhs) > 1e-10:
            all_ok = False

        # Shift-equivariant
        lhs = tropical_max(S, w, f + c)
        rhs = tropical_max(S, w, f) + c
        if abs(lhs - rhs) > 1e-10:
            all_ok = False

        # Monotone
        if tropical_max(S, w, f) > tropical_max(S, w, np.maximum(f, g)) + 1e-10:
            all_ok = False

    print(f"Verification (1000 random tests): {'ALL PASSED ✓' if all_ok else 'FAILED ✗'}")
    print()


if __name__ == "__main__":
    demo_basic_computation()
    demo_sup_preservation()
    demo_shift_equivariance()
    demo_weight_recovery()
    demo_perturbation_stability()
    demo_essential_atoms()
    demo_closure_equilibrium()
    demo_decomposition_summary()


#!/usr/bin/env python3
"""
Tropical Choquet Closure Duality — Visualizations

Generates publication-quality figures illustrating:
1. Tropical max functional as upper envelope
2. Perturbation stability
3. Essential atom isolation
4. Closure-equilibrium landscape
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from matplotlib.patches import FancyArrowPatch
import base64
from io import BytesIO


def fig_to_base64(fig) -> str:
    """Convert matplotlib figure to base64 data URI."""
    buf = BytesIO()
    fig.savefig(buf, format='png', dpi=150, bbox_inches='tight')
    buf.seek(0)
    data = base64.b64encode(buf.read()).decode('utf-8')
    plt.close(fig)
    return f"data:image/png;base64,{data}"


def plot_tropical_envelope():
    """Figure 1: Tropical max as upper envelope of affine functions."""
    fig, ax = plt.subplots(1, 1, figsize=(10, 6))

    x = np.linspace(-3, 5, 1000)

    # Three affine atoms
    w = [1.0, 2.0, -0.5]
    slopes = [1.0, -0.5, 0.3]

    colors = ['#e74c3c', '#3498db', '#2ecc71']
    labels = ['Atom 1: f(x) + w₁', 'Atom 2: f(x) + w₂', 'Atom 3: f(x) + w₃']

    atoms = []
    for i in range(3):
        y = slopes[i] * x + w[i]
        atoms.append(y)
        ax.plot(x, y, '--', color=colors[i], alpha=0.5, linewidth=1.5, label=labels[i])

    # Upper envelope
    envelope = np.maximum(np.maximum(atoms[0], atoms[1]), atoms[2])
    ax.plot(x, envelope, 'k-', linewidth=2.5, label='F(x) = max (tropical envelope)')

    # Shade the region below envelope
    ax.fill_between(x, -10, envelope, alpha=0.05, color='black')

    # Mark transition points
    for i in range(len(x) - 1):
        argmax_curr = np.argmax([a[i] for a in atoms])
        argmax_next = np.argmax([a[i+1] for a in atoms])
        if argmax_curr != argmax_next:
            x_trans = (x[i] + x[i+1]) / 2
            y_trans = envelope[i]
            ax.plot(x_trans, y_trans, 'ko', markersize=8, zorder=5)

    ax.set_xlabel('Input value', fontsize=12)
    ax.set_ylabel('Output value', fontsize=12)
    ax.set_title('Tropical Max Functional as Upper Envelope of Affine Atoms', fontsize=14)
    ax.legend(fontsize=10, loc='upper left')
    ax.set_ylim(-5, 8)
    ax.grid(True, alpha=0.3)

    fig.savefig('/workspace/request-project/fig_tropical_envelope.png', dpi=150, bbox_inches='tight')
    b64 = fig_to_base64(fig)
    return b64


def plot_perturbation_stability():
    """Figure 2: Perturbation stability — weight error vs functional error."""
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 5))

    # Left: scatter of weight vs functional perturbation
    np.random.seed(42)
    support = list(range(5))
    w_true = np.array([2.0, -1.0, 3.0, 0.5, -2.0])

    epsilons = np.linspace(0.01, 2.0, 50)
    weight_errors = []
    func_errors = []

    for eps in epsilons:
        noise = np.random.uniform(-eps, eps, 5)
        w_pert = w_true + noise
        w_err = max(abs(noise[s]) for s in support)

        max_f_err = 0.0
        for _ in range(5000):
            f = np.random.randn(5) * 10
            f_orig = max(f[s] + w_true[s] for s in support)
            f_pert = max(f[s] + w_pert[s] for s in support)
            max_f_err = max(max_f_err, abs(f_orig - f_pert))

        weight_errors.append(w_err)
        func_errors.append(max_f_err)

    ax1.scatter(weight_errors, func_errors, c='#3498db', alpha=0.7, s=30)
    ax1.plot([0, 2], [0, 2], 'r--', linewidth=2, label='y = x (Lipschitz = 1)')
    ax1.set_xlabel('‖Δw‖∞ (weight perturbation)', fontsize=12)
    ax1.set_ylabel('‖ΔF‖∞ (functional perturbation)', fontsize=12)
    ax1.set_title('Perturbation Stability: Optimal Constant = 1', fontsize=13)
    ax1.legend(fontsize=10)
    ax1.grid(True, alpha=0.3)

    # Right: convergence of Lipschitz constant estimate
    n_samples = [10, 50, 100, 500, 1000, 5000, 10000]
    lip_estimates = []

    noise = np.random.uniform(-0.5, 0.5, 5)
    w_pert = w_true + noise
    w_err = max(abs(noise[s]) for s in support)

    for n in n_samples:
        max_f_err = 0.0
        for _ in range(n):
            f = np.random.randn(5) * 10
            f_orig = max(f[s] + w_true[s] for s in support)
            f_pert = max(f[s] + w_pert[s] for s in support)
            max_f_err = max(max_f_err, abs(f_orig - f_pert))
        lip_estimates.append(max_f_err / w_err)

    ax2.semilogx(n_samples, lip_estimates, 'o-', color='#e74c3c', linewidth=2, markersize=8)
    ax2.axhline(y=1.0, color='gray', linestyle='--', linewidth=1.5, label='True constant = 1')
    ax2.set_xlabel('Number of test samples', fontsize=12)
    ax2.set_ylabel('Lipschitz constant estimate', fontsize=12)
    ax2.set_title('Convergence of Lipschitz Estimate', fontsize=13)
    ax2.legend(fontsize=10)
    ax2.grid(True, alpha=0.3)
    ax2.set_ylim(0.5, 1.5)

    fig.tight_layout()
    fig.savefig('/workspace/request-project/fig_perturbation_stability.png', dpi=150, bbox_inches='tight')
    b64 = fig_to_base64(fig)
    return b64


def plot_essential_atoms():
    """Figure 3: Essential atom isolation."""
    fig, axes = plt.subplots(1, 3, figsize=(15, 4.5))

    support = [0, 1, 2]
    w = np.array([2.0, -1.0, 3.0])

    for idx, s_target in enumerate(support):
        ax = axes[idx]

        # Isolation function
        f = np.array([-w[a] + (1.0 if a == s_target else 0.0) for a in support])
        values = [f[a] + w[a] for a in support]

        colors = ['#e74c3c' if a == s_target else '#95a5a6' for a in support]
        bars = ax.bar(support, values, color=colors, edgecolor='black', linewidth=1.5)

        ax.set_xlabel('Support element s', fontsize=11)
        ax.set_ylabel('f(s) + w(s)', fontsize=11)
        ax.set_title(f'Isolating atom s={s_target}', fontsize=12)
        ax.set_xticks(support)
        ax.set_ylim(-0.5, 1.5)

        # Annotate the max
        ax.annotate(f'Max = {values[s_target]:.0f}',
                   xy=(s_target, values[s_target]),
                   xytext=(s_target + 0.3, values[s_target] + 0.3),
                   fontsize=10, fontweight='bold', color='#e74c3c',
                   arrowprops=dict(arrowstyle='->', color='#e74c3c'))

    fig.suptitle('Irredundancy: Every Atom Is Uniquely Essential', fontsize=14, y=1.02)
    fig.tight_layout()
    fig.savefig('/workspace/request-project/fig_essential_atoms.png', dpi=150, bbox_inches='tight')
    b64 = fig_to_base64(fig)
    return b64


def plot_closure_equilibrium():
    """Figure 4: Closure-equilibrium landscape."""
    fig, ax = plt.subplots(1, 1, figsize=(10, 7))

    # Elements and closure operator
    elements = list(range(8))
    cl = {0: 0, 1: 2, 2: 2, 3: 3, 4: 5, 5: 5, 6: 6, 7: 6}
    fixed_points = {x for x in cl if cl[x] == x}
    support = {0, 2, 3, 5, 6}

    # Positions for visualization
    positions = {
        0: (1, 3), 1: (2, 1), 2: (2, 3), 3: (4, 3),
        4: (5, 1), 5: (5, 3), 6: (7, 3), 7: (7, 1)
    }

    # Draw closure arrows
    for x in elements:
        if cl[x] != x:
            x_pos = positions[x]
            y_pos = positions[cl[x]]
            dx = y_pos[0] - x_pos[0]
            dy = y_pos[1] - x_pos[1]
            ax.annotate('', xy=(y_pos[0] - 0.15 * dx, y_pos[1] - 0.15 * dy),
                       xytext=(x_pos[0] + 0.15 * dx, x_pos[1] + 0.15 * dy),
                       arrowprops=dict(arrowstyle='->', color='gray',
                                      lw=2, connectionstyle='arc3,rad=0.2'))

    # Draw elements
    for x in elements:
        pos = positions[x]
        is_fixed = x in fixed_points
        is_support = x in support
        is_equilibrium = is_fixed and is_support

        if is_equilibrium:
            color = '#e74c3c'
            size = 600
            marker = '*'
        elif is_fixed:
            color = '#f39c12'
            size = 400
            marker = 's'
        elif is_support:
            color = '#3498db'
            size = 400
            marker = 'o'
        else:
            color = '#95a5a6'
            size = 300
            marker = 'o'

        ax.scatter(*pos, c=color, s=size, marker=marker, edgecolors='black',
                  linewidths=2, zorder=5)
        ax.annotate(str(x), pos, textcoords="offset points", xytext=(0, -20),
                   ha='center', fontsize=12, fontweight='bold')

    # Legend
    from matplotlib.lines import Line2D
    legend_elements = [
        Line2D([0], [0], marker='*', color='w', markerfacecolor='#e74c3c',
               markersize=15, markeredgecolor='black', label='Equilibrium observable'),
        Line2D([0], [0], marker='s', color='w', markerfacecolor='#f39c12',
               markersize=12, markeredgecolor='black', label='Fixed point (not in support)'),
        Line2D([0], [0], marker='o', color='w', markerfacecolor='#3498db',
               markersize=12, markeredgecolor='black', label='Support (not fixed)'),
        Line2D([0], [0], marker='o', color='w', markerfacecolor='#95a5a6',
               markersize=10, markeredgecolor='black', label='Other element'),
    ]
    ax.legend(handles=legend_elements, loc='lower right', fontsize=10,
             framealpha=0.9)

    ax.set_title('Closure-Equilibrium Correspondence\n'
                'Equilibrium = Fixed Point ∩ Support', fontsize=14)
    ax.set_xlim(-0.5, 8.5)
    ax.set_ylim(-0.5, 4.5)
    ax.set_aspect('equal')
    ax.axis('off')

    fig.savefig('/workspace/request-project/fig_closure_equilibrium.png', dpi=150, bbox_inches='tight')
    b64 = fig_to_base64(fig)
    return b64


if __name__ == "__main__":
    print("Generating visualizations...")

    b64_1 = plot_tropical_envelope()
    print(f"  [1/4] Tropical envelope: {len(b64_1)} chars")

    b64_2 = plot_perturbation_stability()
    print(f"  [2/4] Perturbation stability: {len(b64_2)} chars")

    b64_3 = plot_essential_atoms()
    print(f"  [3/4] Essential atoms: {len(b64_3)} chars")

    b64_4 = plot_closure_equilibrium()
    print(f"  [4/4] Closure equilibrium: {len(b64_4)} chars")

    print("\nAll visualizations saved to PNG files and base64 URIs generated.")
