#!/usr/bin/env python3
"""
applications.py — Real-world applications of path space cardinality theory.

Demonstrates connections between cubical path-space cardinal invariants and:
  1. Brownian bridge sample space structure
  2. Polynomial approximation of continuous paths
  3. Symmetry-invariant path ensembles
  4. Path integral discretization

Keywords: Brownian bridge, Wiener measure, path integrals, polynomial
          interpolation, symmetry invariance, cubical homotopy
"""

import numpy as np
from typing import List, Tuple, Callable, Optional


# ─────────────────────────────────────────────────────────────────
# Application 1: Brownian Bridge Path Sampling
# ─────────────────────────────────────────────────────────────────

def brownian_bridge_sample(a: float, b: float, n_steps: int = 100,
                           seed: Optional[int] = None) -> Tuple[np.ndarray, np.ndarray]:
    """Sample a Brownian bridge from a to b on [0,1].

    A Brownian bridge is a Brownian motion conditioned on B(0)=a, B(1)=b.
    It can be expressed as:
        B(t) = a + (b-a)*t + W(t) - t*W(1)
    where W is a standard Brownian motion.

    This is exactly the affine-perturbation decomposition!
    The term W(t) - t*W(1) is an endpoint-zero function, demonstrating
    that Brownian bridge samples live in the perturbation space
    EndpointZeroFun.

    Returns:
        t_grid, bridge_values
    """
    rng = np.random.default_rng(seed)
    dt = 1.0 / n_steps
    t_grid = np.linspace(0, 1, n_steps + 1)

    # Generate Brownian motion
    increments = rng.normal(0, np.sqrt(dt), size=n_steps)
    W = np.concatenate([[0], np.cumsum(increments)])

    # Brownian bridge = affine path + endpoint-zero perturbation
    perturbation = W - t_grid * W[-1]  # endpoint-zero: pert(0)=0, pert(1)=0
    bridge = a + (b - a) * t_grid + perturbation

    return t_grid, bridge


try:
    from typing import Optional
except ImportError:
    pass


def demo_brownian_bridge():
    """Demonstrate Brownian bridges as affine perturbations."""
    print("APPLICATION 1: Brownian Bridge as Affine Perturbation")
    print("=" * 55)

    a, b = 1.0, 3.0
    n_samples = 5

    print(f"  Endpoints: a={a}, b={b}")
    print(f"  Generating {n_samples} Brownian bridge samples...\n")

    for i in range(n_samples):
        t, bridge = brownian_bridge_sample(a, b, n_steps=1000, seed=i)
        affine = a + (b - a) * t
        perturbation = bridge - affine

        print(f"  Sample {i+1}:")
        print(f"    B(0) = {bridge[0]:.6f} (should be {a})")
        print(f"    B(1) = {bridge[-1]:.6f} (should be {b})")
        print(f"    Perturbation at 0: {perturbation[0]:.2e}")
        print(f"    Perturbation at 1: {perturbation[-1]:.2e}")
        print(f"    Max |perturbation|: {np.max(np.abs(perturbation)):.4f}")

    print("\n  Key insight: Every Brownian bridge sample decomposes as")
    print("    B(t) = [affine path] + [endpoint-zero perturbation]")
    print("  This is exactly the pathOverEquivEndpointZeroFun equivalence!")


# ─────────────────────────────────────────────────────────────────
# Application 2: Polynomial Approximation of Continuous Paths
# ─────────────────────────────────────────────────────────────────

def polynomial_path_approximation(path_fn: Callable, degree: int,
                                   a: float, b: float) -> Callable:
    """Approximate a continuous path by a normalized polynomial.

    Uses least-squares fitting on Chebyshev nodes, preserving
    the endpoint constraints p(0)=a, p(1)=b exactly.

    This connects to Stone-Weierstrass: polynomials are dense
    in C([0,1], ℝ), and our normalized subfamily is dense in
    the endpoint-conditioned subspace.
    """
    # Sample on Chebyshev nodes
    n = max(degree * 3, 50)
    k = np.arange(1, n + 1)
    t_nodes = 0.5 * (1 - np.cos(np.pi * (2*k - 1) / (2*n)))

    # Compute residual (endpoint-zero part)
    residual = path_fn(t_nodes) - a - (b - a) * t_nodes

    # Fit endpoint-zero polynomial: sum c_k * t^k * (1-t)
    n_coeffs = degree - 1
    basis = np.column_stack([
        t_nodes**(k+1) * (1 - t_nodes) for k in range(n_coeffs)
    ])

    coeffs, _, _, _ = np.linalg.lstsq(basis, residual, rcond=None)

    def approx(t):
        result = a + (b - a) * t
        for k, c in enumerate(coeffs):
            result += c * t**(k+1) * (1 - t)
        return result

    return approx


def demo_polynomial_approximation():
    """Demonstrate polynomial approximation of smooth paths."""
    print("\n\nAPPLICATION 2: Polynomial Approximation of Continuous Paths")
    print("=" * 60)

    a, b = 0.0, 1.0
    # A smooth path that isn't polynomial
    smooth_path = lambda t: t + 0.3 * np.sin(2 * np.pi * t)

    t_eval = np.linspace(0, 1, 1001)
    true_values = smooth_path(t_eval)

    print(f"  Target path: γ(t) = t + 0.3·sin(2πt)")
    print(f"  γ(0) = {smooth_path(np.array([0.0]))[0]:.6f}, "
          f"γ(1) = {smooth_path(np.array([1.0]))[0]:.6f}\n")

    for degree in [3, 5, 8, 12, 20]:
        approx = polynomial_path_approximation(smooth_path, degree, a, b)
        approx_values = approx(t_eval)
        error = np.max(np.abs(true_values - approx_values))

        # Verify endpoints
        ep0 = approx(np.array([0.0]))[0]
        ep1 = approx(np.array([1.0]))[0]

        print(f"  Degree {degree:2d}: sup error = {error:.2e}, "
              f"p(0)={ep0:.6f}, p(1)={ep1:.6f}")

    print("\n  Convergence demonstrates: normalized polynomials approximate")
    print("  arbitrary smooth paths while preserving endpoint constraints.")


# ─────────────────────────────────────────────────────────────────
# Application 3: Symmetry-Invariant Path Ensembles
# ─────────────────────────────────────────────────────────────────

def demo_symmetry_invariance():
    """Demonstrate that translation/scaling preserve path statistics."""
    print("\n\nAPPLICATION 3: Symmetry-Invariant Path Ensembles")
    print("=" * 50)

    rng = np.random.default_rng(42)
    n_paths = 1000
    t_grid = np.linspace(0, 1, 201)
    a, b = 0.0, 1.0

    # Generate random endpoint-zero perturbations
    perturbations = []
    for _ in range(n_paths):
        n_coeffs = rng.integers(2, 6)
        coeffs = rng.normal(0, 0.5, size=n_coeffs)
        f_values = np.zeros_like(t_grid)
        for k, c in enumerate(coeffs):
            f_values += c * t_grid * (1 - t_grid) * t_grid**k
        perturbations.append(f_values)

    perturbations = np.array(perturbations)

    # Original paths
    paths = a + (b - a) * t_grid[None, :] + perturbations

    # Translate by c = 5
    c = 5.0
    translated_paths = paths + c

    # Compute statistics
    orig_mean = np.mean(paths, axis=0)
    trans_mean = np.mean(translated_paths, axis=0)
    orig_std = np.std(paths, axis=0)
    trans_std = np.std(translated_paths, axis=0)

    mean_shift = np.mean(trans_mean - orig_mean)
    std_diff = np.max(np.abs(trans_std - orig_std))

    print(f"  Generated {n_paths} random paths from a={a} to b={b}")
    print(f"  Translation: c = {c}")
    print(f"\n  Mean shift (should be {c}): {mean_shift:.6f}")
    print(f"  Max std deviation change: {std_diff:.2e}")
    print(f"\n  Key insight: Translation shifts the mean by c but preserves")
    print(f"  the variance structure — standard deviations are identical.")
    print(f"  This is because translation is a cubical equivalence that")
    print(f"  acts bijectively on path spaces (translationPathEquiv).")


# ─────────────────────────────────────────────────────────────────
# Application 4: Discretized Path Integral Intuition
# ─────────────────────────────────────────────────────────────────

def demo_path_integral():
    """Illustrate path integral discretization via cardinality."""
    print("\n\nAPPLICATION 4: Path Integral Discretization")
    print("=" * 45)

    a, b = 0.0, 1.0

    print("""
  In quantum mechanics, path integrals sum over all paths:

      ⟨b|e^{-iHt}|a⟩ = ∫ Dγ · e^{iS[γ]}

  where S[γ] is the action along path γ.

  Our cardinality theorem tells us the "size" of this integral:
  - The path space PathOver(ℝ, ℝ, a, b) is as large as ℝ → ℝ
  - Every path decomposes as: γ = affine_path + perturbation
  - The perturbation lives in EndpointZeroFun

  For numerical approximation, we discretize:
""")

    for n_steps in [5, 10, 20, 50, 100]:
        # Discretized paths: fix values at n_steps interior points
        # Each interior point has ℝ degrees of freedom
        # Total degrees of freedom: n_steps - 1 (minus endpoints)
        n_free = n_steps - 1
        print(f"  {n_steps:3d} steps → {n_free:3d} free variables "
              f"→ integration over ℝ^{n_free}")

    print("""
  As n_steps → ∞, the discrete ℝ^n approximation converges to
  the full function space. The formal cardinality result
  PathOver ≃ EndpointZeroFun provides the precise ambient space
  for this limit.
""")

    # Numerical quadrature example: harmonic oscillator
    print("  Example: Harmonic oscillator path integral")
    print("  Action S[γ] = ∫₀¹ ½(γ'² - ω²γ²) dt")

    omega = 1.0
    n_steps = 50
    dt = 1.0 / n_steps
    t = np.linspace(0, 1, n_steps + 1)
    rng = np.random.default_rng(42)

    n_samples = 10000
    actions = []
    for _ in range(n_samples):
        # Random perturbation
        perturbation = np.zeros(n_steps + 1)
        for k in range(1, n_steps):
            perturbation[k] = rng.normal(0, 0.3)
        # Enforce endpoints
        perturbation[0] = 0
        perturbation[-1] = 0

        path = a + (b - a) * t + perturbation
        # Compute action (trapezoidal rule)
        velocity = np.diff(path) / dt
        pos_mid = 0.5 * (path[:-1] + path[1:])
        lagrangian = 0.5 * (velocity**2 - omega**2 * pos_mid**2)
        action = np.sum(lagrangian) * dt
        actions.append(action)

    actions = np.array(actions)
    print(f"\n  Sampled {n_samples} paths with {n_steps} steps")
    print(f"  Action statistics:")
    print(f"    Mean:   {np.mean(actions):.4f}")
    print(f"    Std:    {np.std(actions):.4f}")
    print(f"    Min:    {np.min(actions):.4f}")
    print(f"    Max:    {np.max(actions):.4f}")


# ─────────────────────────────────────────────────────────────────
# MAIN
# ─────────────────────────────────────────────────────────────────

if __name__ == "__main__":
    print("╔" + "═" * 58 + "╗")
    print("║  PATH SPACE APPLICATIONS — CROSS-DOMAIN CONNECTIONS    ║")
    print("╚" + "═" * 58 + "╝\n")

    demo_brownian_bridge()
    demo_polynomial_approximation()
    demo_symmetry_invariance()
    demo_path_integral()

    print("=" * 60)
    print("ALL APPLICATIONS DEMONSTRATED SUCCESSFULLY")
    print("=" * 60)


#!/usr/bin/env python3
"""
demo.py — Path Space Cardinality Invariants: Visualization and Exploration

Demonstrates the key ideas behind the formal proof that cubical path spaces
over ℝ have the cardinality of the full function space ℝ → ℝ:
  1. Normalized polynomial paths satisfying endpoint constraints
  2. Affine-perturbation encoding (endpoint-zero functions → paths)
  3. Translation invariance of path spaces
  4. The "cardinality sandwich" argument

Keywords: cubical path spaces, continuum cardinality, polynomial interpolation,
          Brownian bridge, path integrals, function-space semantics
"""

import numpy as np
import json
from typing import List, Tuple, Callable

# ─────────────────────────────────────────────────────────────────
# 1. Normalized Polynomial Path Generation
# ─────────────────────────────────────────────────────────────────

def generate_normalized_polynomial(degree: int, rng=None) -> np.ndarray:
    """Generate a random polynomial p of given degree with p(0)=0, p(1)=1.

    We parameterize: p(t) = t + sum_{k=2}^{degree} c_k * t^k * (1 - t)
    which automatically satisfies p(0)=0. We then adjust so p(1)=1.

    Actually, a cleaner approach: let q(t) be any degree-d polynomial with
    q(0) = 0, q(1) = 1. Write p(t) = t + sum_{k=2}^d c_k * t*(1-t)*t^{k-2}.
    Then p(0) = 0 and p(1) = 1 automatically.

    Returns coefficients [c_0, c_1, ..., c_degree] in the standard basis.
    """
    if rng is None:
        rng = np.random.default_rng()

    # Start with the affine path t → t (coeffs [0, 1, 0, ...])
    # Add a perturbation in the kernel of endpoint evaluation:
    # perturbation(t) = sum_{k=1}^{degree-1} a_k * t^k * (1-t)
    # which satisfies pert(0) = 0 and pert(1) = 0

    coeffs = np.zeros(degree + 1)
    coeffs[1] = 1.0  # affine part: t

    # Add random endpoint-zero perturbations
    for k in range(1, degree):
        a_k = rng.normal(0, 1.0)
        # t^k * (1-t) = t^k - t^{k+1}
        if k <= degree:
            coeffs[k] += a_k
        if k + 1 <= degree:
            coeffs[k + 1] -= a_k

    return coeffs


def eval_polynomial(coeffs: np.ndarray, t: np.ndarray) -> np.ndarray:
    """Evaluate polynomial with given coefficients at points t."""
    result = np.zeros_like(t)
    for k, c in enumerate(coeffs):
        result += c * t**k
    return result


def demo_polynomial_paths():
    """Generate and display random normalized polynomial paths."""
    print("=" * 70)
    print("DEMO 1: Random Normalized Polynomial Paths")
    print("  Polynomials p with p(0)=0 and p(1)=1, degrees 2-10")
    print("=" * 70)

    rng = np.random.default_rng(42)
    t = np.linspace(0, 1, 101)

    for degree in [2, 3, 5, 8, 10]:
        coeffs = generate_normalized_polynomial(degree, rng)
        values = eval_polynomial(coeffs, t)
        print(f"\n  Degree {degree}: p(0) = {values[0]:.6f}, p(1) = {values[-1]:.6f}")
        print(f"    Coefficients: {coeffs.round(4)}")
        print(f"    Range: [{values.min():.4f}, {values.max():.4f}]")

        # Verify endpoint constraints
        assert abs(values[0]) < 1e-10, f"p(0) != 0 for degree {degree}"
        assert abs(values[-1] - 1) < 1e-10, f"p(1) != 1 for degree {degree}"

    print("\n  ✓ All polynomials satisfy p(0)=0 and p(1)=1")


# ─────────────────────────────────────────────────────────────────
# 2. Affine-Perturbation Encoding
# ─────────────────────────────────────────────────────────────────

def affine_path(a: float, b: float, t: np.ndarray) -> np.ndarray:
    """The affine (linear interpolation) path from a to b."""
    return a + (b - a) * t


def perturb_affine(a: float, b: float, f: Callable, t: np.ndarray) -> np.ndarray:
    """Affine-perturbation: γ(t) = a + (b-a)*t + f(t), where f(0)=f(1)=0."""
    return a + (b - a) * t + f(t)


def endpoint_zero_function(coeffs: np.ndarray) -> Callable:
    """Create an endpoint-zero function from coefficients:
    f(t) = sum_k c_k * t * (1-t) * t^k
    Automatically satisfies f(0) = 0 and f(1) = 0.
    """
    def f(t):
        result = np.zeros_like(t)
        for k, c in enumerate(coeffs):
            result += c * t * (1 - t) * t**k
        return result
    return f


def demo_affine_perturbation():
    """Demonstrate the affine-perturbation encoding."""
    print("\n" + "=" * 70)
    print("DEMO 2: Affine-Perturbation Encoding")
    print("  Path(t) = a + (b-a)*t + f(t),  where f(0)=f(1)=0")
    print("=" * 70)

    a, b = 2.0, 5.0
    t = np.linspace(0, 1, 101)
    rng = np.random.default_rng(123)

    print(f"\n  Endpoints: a = {a}, b = {b}")
    print(f"  Affine path: γ₀(t) = {a} + {b-a}*t")

    # Generate several perturbations
    for i in range(5):
        n_coeffs = rng.integers(2, 6)
        coeffs = rng.normal(0, 1, size=n_coeffs)
        f = endpoint_zero_function(coeffs)

        path_values = perturb_affine(a, b, f, t)
        print(f"\n  Perturbation {i+1}: {n_coeffs} coefficients")
        print(f"    γ(0) = {path_values[0]:.6f}  (should be {a})")
        print(f"    γ(1) = {path_values[-1]:.6f}  (should be {b})")
        print(f"    Range: [{path_values.min():.4f}, {path_values.max():.4f}]")

        assert abs(path_values[0] - a) < 1e-10
        assert abs(path_values[-1] - b) < 1e-10

    print("\n  ✓ All perturbations preserve endpoints a and b")


# ─────────────────────────────────────────────────────────────────
# 3. Translation Invariance
# ─────────────────────────────────────────────────────────────────

def demo_translation_invariance():
    """Demonstrate that translation preserves path structure."""
    print("\n" + "=" * 70)
    print("DEMO 3: Translation Invariance")
    print("  translatePath(c)(γ)(t) = γ(t) + c")
    print("=" * 70)

    a, b = 1.0, 3.0
    c = 7.0
    t = np.linspace(0, 1, 101)

    coeffs = np.array([2.0, -1.5, 0.8])
    f = endpoint_zero_function(coeffs)
    original_path = perturb_affine(a, b, f, t)
    translated_path = original_path + c

    print(f"\n  Original: a={a}, b={b}")
    print(f"  Translation: c={c}")
    print(f"  Translated: a+c={a+c}, b+c={b+c}")
    print(f"\n  Original γ(0) = {original_path[0]:.6f}")
    print(f"  Original γ(1) = {original_path[-1]:.6f}")
    print(f"  Translated γ(0) = {translated_path[0]:.6f}")
    print(f"  Translated γ(1) = {translated_path[-1]:.6f}")

    # Verify the translated path has correct endpoints
    assert abs(translated_path[0] - (a + c)) < 1e-10
    assert abs(translated_path[-1] - (b + c)) < 1e-10

    # Verify bijection: translating and then un-translating recovers original
    recovered = translated_path - c
    max_error = np.max(np.abs(recovered - original_path))
    print(f"\n  Round-trip error (translate then un-translate): {max_error:.2e}")
    assert max_error < 1e-12

    print("  ✓ Translation is invertible — confirms bijection on path spaces")


# ─────────────────────────────────────────────────────────────────
# 4. Injectivity Verification on Sampled Coefficients
# ─────────────────────────────────────────────────────────────────

def demo_injectivity():
    """Numerically confirm injectivity of the perturbation encoding."""
    print("\n" + "=" * 70)
    print("DEMO 4: Injectivity of Affine-Perturbation Encoding")
    print("  Different f,g ⟹ different paths")
    print("=" * 70)

    a, b = 0.0, 1.0
    t_grid = np.linspace(0, 1, 1001)
    rng = np.random.default_rng(999)

    N = 200  # number of random pairs to test
    min_separation = float('inf')

    for _ in range(N):
        c1 = rng.normal(0, 1, size=4)
        c2 = rng.normal(0, 1, size=4)
        if np.allclose(c1, c2):
            continue

        f1 = endpoint_zero_function(c1)
        f2 = endpoint_zero_function(c2)

        path1 = perturb_affine(a, b, f1, t_grid)
        path2 = perturb_affine(a, b, f2, t_grid)

        separation = np.max(np.abs(path1 - path2))
        min_separation = min(min_separation, separation)

    print(f"\n  Tested {N} random coefficient pairs")
    print(f"  Minimum path separation: {min_separation:.6e}")
    print(f"  ✓ All distinct perturbations produce distinct paths")
    assert min_separation > 1e-10


# ─────────────────────────────────────────────────────────────────
# 5. Cardinality Narrative
# ─────────────────────────────────────────────────────────────────

def demo_cardinality_narrative():
    """Print the cardinality sandwich argument."""
    print("\n" + "=" * 70)
    print("DEMO 5: Cardinality Sandwich — Why #PathOver = #(ℝ → ℝ)")
    print("=" * 70)

    print("""
  THE CARDINALITY SANDWICH ARGUMENT
  ══════════════════════════════════

  We want to determine the exact cardinality of the path space

      PathOver(ℝ, ℝ, a, b) = { p : ℝ → ℝ | p(0) = a, p(1) = b }

  STEP 1 — LOWER BOUND (injection from ℝ)
  ─────────────────────────────────────────
  For each c ∈ ℝ, define f_c(t) = c·t·(1-t).
  Then f_c(0) = 0 and f_c(1) = 0, so

      γ_c(t) = a + (b-a)·t + c·t·(1-t)

  is a valid path from a to b. The map c ↦ γ_c is injective
  (evaluate at t=1/2 to separate). Therefore:

      #ℝ ≤ #PathOver(ℝ, ℝ, a, b)

  STEP 2 — UPPER BOUND (projection to ℝ → ℝ)
  ────────────────────────────────────────────
  Every path p is a function ℝ → ℝ satisfying two constraints.
  Forgetting those constraints gives an injection:

      #PathOver(ℝ, ℝ, a, b) ≤ #(ℝ → ℝ)

  STEP 3 — EQUIVALENCE WITH ENDPOINT-ZERO FUNCTIONS
  ──────────────────────────────────────────────────
  The map p ↦ (t ↦ p(t) - a - (b-a)·t) is a bijection

      PathOver(ℝ, ℝ, a, b) ≃ { f : ℝ → ℝ | f(0)=0, f(1)=0 }

  with inverse f ↦ (t ↦ a + (b-a)·t + f(t)).

  STEP 4 — INVARIANCE
  ───────────────────
  Cubical equivalences (e.g., translation, scaling) transport
  path spaces bijectively, preserving this cardinality.
  This is the infinite-cardinal generalization of the finite
  pathCount_invariant theorem.

  CONCLUSION
  ──────────
  The path space is exactly as large as the endpoint-zero function
  space — a continuum-indexed family of perturbations of the
  affine path. This is the cardinal skeleton on which Brownian
  bridge measures, path integrals, and cubical homotopy semantics
  are built.
""")


# ─────────────────────────────────────────────────────────────────
# MAIN
# ─────────────────────────────────────────────────────────────────

if __name__ == "__main__":
    print("\n" + "╔" + "═" * 68 + "╗")
    print("║  PATH SPACE CARDINALITY INVARIANTS — COMPUTATIONAL DEMONSTRATION  ║")
    print("╚" + "═" * 68 + "╝\n")

    demo_polynomial_paths()
    demo_affine_perturbation()
    demo_translation_invariance()
    demo_injectivity()
    demo_cardinality_narrative()

    print("=" * 70)
    print("ALL DEMOS COMPLETED SUCCESSFULLY")
    print("=" * 70)
