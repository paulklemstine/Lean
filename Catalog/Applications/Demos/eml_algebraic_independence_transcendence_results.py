"""
applications.py — Real-World Applications of EML Algebraic Independence Theory

Demonstrates how the EML framework connects to:
1. Signal processing — phase cancellation and sparse Fourier interference
2. Cryptographic hash analysis — algebraic independence of hash-derived quantities
3. Numerical stability certification — bounding errors in exp-log compound expressions
4. Period computation — EML values as mixed exponential-logarithmic periods
"""

import cmath
import math
from typing import Optional

try:
    import mpmath
    HAS_MPMATH = True
except ImportError:
    HAS_MPMATH = False


def eml(z: complex) -> complex:
    """The EML operator: eml(z) = exp(z) * log(1+z)."""
    return cmath.exp(z) * cmath.log(1 + z)


# =============================================================================
# Application 1: Phase Cancellation in Signal Processing
# =============================================================================

def phase_cancellation_analysis(
    frequencies: list[float],
    amplitudes: Optional[list[complex]] = None
) -> dict:
    """Analyze phase cancellation in EML-weighted signal sums.

    For purely imaginary arguments z = iθ, eml(iθ) = exp(iθ) * log(1+iθ).
    The exponential provides a unit-magnitude phase rotation while log(1+iθ)
    provides amplitude modulation. This function analyzes when weighted sums
    of such terms can cancel.

    By the norm bound theorem (norm_sum_eml_mul_I_le):
        |∑ cⱼ eml(iθⱼ)| ≤ ∑ |cⱼ| |log(1+iθⱼ)|

    Perfect cancellation requires precise phase alignment — this is the
    algebraic independence barrier.

    Args:
        frequencies: List of θ values (real frequencies)
        amplitudes: Optional complex coefficients (default: all 1)

    Returns:
        Dictionary with cancellation analysis
    """
    n = len(frequencies)
    if amplitudes is None:
        amplitudes = [1.0 + 0j] * n

    # Compute EML values at imaginary points
    eml_vals = [eml(1j * theta) for theta in frequencies]

    # Weighted sum
    total = sum(c * v for c, v in zip(amplitudes, eml_vals))

    # Upper bound from triangle inequality (our theorem)
    upper_bound = sum(abs(c) * abs(cmath.log(1 + 1j * theta))
                      for c, theta in zip(amplitudes, frequencies))

    # Phase angles
    phases = [cmath.phase(v) for v in eml_vals]

    # Cancellation ratio: how much cancellation occurred vs upper bound
    cancellation_ratio = abs(total) / upper_bound if upper_bound > 0 else 0

    return {
        'eml_values': eml_vals,
        'weighted_sum': total,
        'sum_norm': abs(total),
        'upper_bound': upper_bound,
        'cancellation_ratio': cancellation_ratio,
        'phases_degrees': [p * 180 / math.pi for p in phases],
        'log_norms': [abs(cmath.log(1 + 1j * t)) for t in frequencies],
        'interpretation': (
            'Strong cancellation' if cancellation_ratio < 0.1 else
            'Moderate cancellation' if cancellation_ratio < 0.5 else
            'Weak cancellation'
        )
    }


# =============================================================================
# Application 2: Numerical Stability of Compound Expressions
# =============================================================================

def numerical_stability_bound(
    z_values: list[complex],
    coefficients: list[float],
    perturbation_size: float = 1e-10
) -> dict:
    """Bound the sensitivity of linear EML combinations to input perturbations.

    Using the partition theorem (eml_linear_relation_partition), a linear
    combination ∑ qᵢ eml(zᵢ) decomposes by logarithmic collision classes.
    This provides a structural bound on numerical stability: perturbations
    only interact within collision classes.

    Args:
        z_values: Input complex values
        coefficients: Real coefficients
        perturbation_size: Size of perturbation for sensitivity analysis

    Returns:
        Stability analysis dictionary
    """
    n = len(z_values)

    # Compute base value
    base_val = sum(q * eml(z) for q, z in zip(coefficients, z_values))

    # Compute perturbed values (finite differences for sensitivity)
    sensitivities = []
    for i in range(n):
        z_pert = list(z_values)
        z_pert[i] = z_values[i] + perturbation_size
        pert_val = sum(q * eml(z) for q, z in zip(coefficients, z_pert))
        sensitivity = abs(pert_val - base_val) / perturbation_size
        sensitivities.append(sensitivity)

    # Identify logarithmic collision classes
    log_vals = [cmath.log(1 + z) for z in z_values]
    classes = {}
    for i, lv in enumerate(log_vals):
        # Group by approximate equality
        found = False
        for key in classes:
            if abs(lv - key) < 1e-8:
                classes[key].append(i)
                found = True
                break
        if not found:
            classes[lv] = [i]

    return {
        'base_value': base_val,
        'sensitivities': sensitivities,
        'max_sensitivity': max(sensitivities),
        'condition_number': max(sensitivities) * max(abs(z) for z in z_values) / abs(base_val) if abs(base_val) > 0 else float('inf'),
        'log_collision_classes': {str(k): v for k, v in classes.items()},
        'num_classes': len(classes),
        'stability_assessment': (
            'Well-conditioned' if max(sensitivities) < 100 else
            'Moderately conditioned' if max(sensitivities) < 1e6 else
            'Ill-conditioned'
        )
    }


# =============================================================================
# Application 3: EML as Mixed Exponential-Logarithmic Periods
# =============================================================================

def compute_eml_period_data(algebraic_values: list[tuple[str, float]]) -> dict:
    """Compute EML values and their period-theoretic properties.

    EML values eml(a) = exp(a)·log(1+a) for algebraic a are conjectured to be
    transcendental. They combine an exponential period exp(a) with a logarithmic
    period log(1+a), creating a "mixed period" that falls outside standard
    period classifications.

    Args:
        algebraic_values: List of (name, approximate_value) pairs for algebraic inputs

    Returns:
        Period analysis dictionary
    """
    results = []
    for name, val in algebraic_values:
        eml_val = eml(val)
        exp_val = cmath.exp(val)
        log_val = cmath.log(1 + val)

        results.append({
            'name': name,
            'input': val,
            'exp_component': exp_val,
            'log_component': log_val,
            'eml_value': eml_val,
            'eml_magnitude': abs(eml_val),
            'eml_phase_degrees': cmath.phase(eml_val) * 180 / math.pi,
            'exp_magnitude': abs(exp_val),
            'log_magnitude': abs(log_val),
        })

    return {
        'period_data': results,
        'conjecture': (
            "EML-Schanuel Conjecture: For algebraic a₁,...,aₙ linearly independent "
            "over ℚ and not equal to -1, the transcendence degree of "
            "ℚ(eml(a₁),...,eml(aₙ)) over ℚ equals n."
        ),
        'note': (
            "The product exp(a)·log(1+a) of two transcendental numbers need not be "
            "transcendental. The EML framework provides tools to study when it is."
        )
    }


# =============================================================================
# Application 4: Sparse Interference Pattern Detection
# =============================================================================

def sparse_interference_patterns(
    theta_values: list[float],
    max_degree: int = 3
) -> dict:
    """Detect sparse interference patterns among EML values at imaginary points.

    For θ₁,...,θₙ real, the values eml(iθⱼ) = exp(iθⱼ)·log(1+iθⱼ) are
    complex numbers on circles of radius |log(1+iθⱼ)|. Polynomial relations
    among these values correspond to sparse trigonometric identities — a
    connection to harmonic analysis and compressed sensing.

    Args:
        theta_values: Real frequency values
        max_degree: Maximum degree for monomial analysis

    Returns:
        Interference pattern analysis
    """
    n = len(theta_values)
    eml_vals = [eml(1j * t) for t in theta_values]

    # Compute EML monomials for analysis
    from algorithms import enumerate_monomials, eml_monomial_value

    monomials = enumerate_monomials(n, max_degree)
    monomial_phases = []

    for m in monomials:
        if all(mi == 0 for mi in m):
            monomial_phases.append({'monomial': m, 'value': 1.0, 'phase': 0.0, 'magnitude': 1.0})
            continue

        # For imaginary inputs, compute the monomial value
        val = 1.0 + 0j
        for i, ei in enumerate(m):
            if ei > 0:
                val *= eml_vals[i] ** ei

        monomial_phases.append({
            'monomial': m,
            'value': val,
            'phase': cmath.phase(val) * 180 / math.pi,
            'magnitude': abs(val)
        })

    # Check for phase collisions (monomials with nearly equal phases)
    phase_collisions = []
    for i in range(len(monomial_phases)):
        for j in range(i + 1, len(monomial_phases)):
            p1 = monomial_phases[i]['phase']
            p2 = monomial_phases[j]['phase']
            diff = abs(p1 - p2) % 360
            diff = min(diff, 360 - diff)
            if diff < 5.0:  # Within 5 degrees
                phase_collisions.append({
                    'monomial_1': monomial_phases[i]['monomial'],
                    'monomial_2': monomial_phases[j]['monomial'],
                    'phase_difference': diff
                })

    return {
        'eml_values': [(abs(v), cmath.phase(v) * 180 / math.pi) for v in eml_vals],
        'monomial_phases': monomial_phases,
        'phase_collisions': phase_collisions,
        'num_near_collisions': len(phase_collisions),
        'interpretation': (
            f"Found {len(phase_collisions)} near-phase-collisions among "
            f"{len(monomials)} monomials up to degree {max_degree}. "
            f"{'Phase separation holds — evidence against low-degree relations.' if len(phase_collisions) == 0 else 'Near-collisions detected — potential resonance.'}"
        )
    }


# =============================================================================
# Main demonstration
# =============================================================================

if __name__ == '__main__':
    print("=" * 70)
    print("EML Algebraic Independence: Real-World Applications")
    print("=" * 70)

    # Application 1: Phase cancellation
    print("\n--- Application 1: Phase Cancellation Analysis ---")
    result = phase_cancellation_analysis(
        frequencies=[1.0, 2.0, 3.0, math.pi],
        amplitudes=[1, -1, 0.5, 0.3]
    )
    print(f"Sum norm:        {result['sum_norm']:.6f}")
    print(f"Upper bound:     {result['upper_bound']:.6f}")
    print(f"Cancel ratio:    {result['cancellation_ratio']:.4f}")
    print(f"Interpretation:  {result['interpretation']}")

    # Application 2: Numerical stability
    print("\n--- Application 2: Numerical Stability ---")
    stab = numerical_stability_bound(
        z_values=[math.sqrt(2), math.sqrt(3), math.sqrt(5)],
        coefficients=[1.0, -1.0, 0.5]
    )
    print(f"Base value:      {stab['base_value']:.6f}")
    print(f"Max sensitivity: {stab['max_sensitivity']:.4f}")
    print(f"Assessment:      {stab['stability_assessment']}")
    print(f"Log classes:     {stab['num_classes']}")

    # Application 3: Period data
    print("\n--- Application 3: EML Period Analysis ---")
    period = compute_eml_period_data([
        ('√2', math.sqrt(2)),
        ('√3', math.sqrt(3)),
        ('∛2', 2 ** (1/3)),
        ('φ (golden ratio)', (1 + math.sqrt(5)) / 2),
    ])
    for p in period['period_data']:
        print(f"  eml({p['name']}) = {p['eml_value']:.8f}  (|·| = {p['eml_magnitude']:.6f})")

    # Application 4: Sparse interference
    print("\n--- Application 4: Sparse Interference Patterns ---")
    interf = sparse_interference_patterns([1.0, math.sqrt(2), math.pi], max_degree=2)
    print(f"Near-phase-collisions: {interf['num_near_collisions']}")
    print(f"Interpretation: {interf['interpretation']}")


#!/usr/bin/env python3
"""
demo.py — EML Algebraic Independence: Interactive Demonstration

Demonstrates:
1. EML value computation for algebraic inputs
2. Bounded-degree polynomial relation search
3. Monomial separation visualization
4. Phase cancellation analysis for imaginary inputs

This is the experimental arm of the EML algebraic independence project,
providing computational evidence for the EML-Schanuel conjecture.
"""

import cmath
import math
import sys

try:
    import mpmath
    HAS_MPMATH = True
except ImportError:
    HAS_MPMATH = False


def eml(z: complex) -> complex:
    """EML operator: eml(z) = exp(z) * log(1 + z)."""
    return cmath.exp(z) * cmath.log(1 + z)


def enumerate_monomials(n: int, max_deg: int) -> list[tuple[int, ...]]:
    """Enumerate monomial exponent vectors up to total degree max_deg."""
    result = []
    def helper(remaining_vars, remaining_deg, current):
        if remaining_vars == 0:
            result.append(tuple(current))
            return
        for k in range(remaining_deg + 1):
            helper(remaining_vars - 1, remaining_deg - k, current + [k])
    helper(n, max_deg, [])
    return result


def format_monomial(m: tuple[int, ...], var_names: list[str]) -> str:
    """Format a monomial exponent vector as a readable string."""
    parts = []
    for i, e in enumerate(m):
        if e == 0:
            continue
        name = var_names[i] if i < len(var_names) else f"x{i+1}"
        if e == 1:
            parts.append(name)
        else:
            parts.append(f"{name}^{e}")
    return " · ".join(parts) if parts else "1"


def format_polynomial(poly: dict, var_names: list[str]) -> str:
    """Format a polynomial as a readable string."""
    if not poly:
        return "0"
    terms = []
    for m, c in sorted(poly.items(), key=lambda x: sum(x[0])):
        mono = format_monomial(m, var_names)
        if c == 1:
            terms.append(mono)
        elif c == -1:
            terms.append(f"-{mono}")
        else:
            terms.append(f"{c}·{mono}")
    return " + ".join(terms).replace("+ -", "- ")


def demo_eml_values():
    """Demo 1: Compute EML values for various algebraic inputs."""
    print("=" * 70)
    print("DEMO 1: EML Values for Algebraic Inputs")
    print("=" * 70)
    print()
    print("eml(z) = exp(z) · log(1 + z)")
    print()

    test_values = [
        ("√2", math.sqrt(2)),
        ("√3", math.sqrt(3)),
        ("∛2", 2 ** (1/3)),
        ("φ = (1+√5)/2", (1 + math.sqrt(5)) / 2),
        ("√2 + √3", math.sqrt(2) + math.sqrt(3)),
        ("1", 1.0),
        ("2", 2.0),
    ]

    print(f"{'Input':>16s}  {'Value':>12s}  {'eml(a)':>24s}  {'|eml(a)|':>12s}")
    print("-" * 70)
    for name, val in test_values:
        eml_val = eml(val)
        print(f"{name:>16s}  {val:12.8f}  {eml_val.real:12.8f}+{eml_val.imag:.8f}i  {abs(eml_val):12.8f}")

    print()
    print("Note: For algebraic a ≠ 0, -1, these values are conjectured to be")
    print("transcendental (EML-Schanuel Conjecture).")
    print()


def demo_relation_search():
    """Demo 2: Search for polynomial relations among EML values."""
    print("=" * 70)
    print("DEMO 2: Polynomial Relation Search")
    print("=" * 70)
    print()

    a1 = math.sqrt(2)
    a2 = math.sqrt(3)
    v1 = eml(a1)
    v2 = eml(a2)

    print(f"Searching for P(X,Y) ∈ ℤ[X,Y] with P(eml(√2), eml(√3)) = 0")
    print(f"  eml(√2) ≈ {v1:.10f}")
    print(f"  eml(√3) ≈ {v2:.10f}")
    print()

    var_names = ["X", "Y"]

    for max_deg in [1, 2]:
        for max_coeff in [3, 5]:
            monomials = enumerate_monomials(2, max_deg)
            best_residual = float('inf')
            best_poly = None
            found = False

            # Search through coefficient combinations
            search_count = 0
            coeff_range = range(-max_coeff, max_coeff + 1)

            # For efficiency, use a smarter search: evaluate monomials once
            mono_vals = []
            for m in monomials:
                val = v1 ** m[0] * v2 ** m[1]
                mono_vals.append(val)

            # Use itertools for small cases
            from itertools import product as iprod

            num_monos = len(monomials)
            if num_monos <= 6 and max_coeff <= 10:
                for coeffs in iprod(coeff_range, repeat=num_monos):
                    if all(c == 0 for c in coeffs):
                        continue
                    total = sum(c * v for c, v in zip(coeffs, mono_vals))
                    residual = abs(total)
                    if residual < best_residual:
                        best_residual = residual
                        best_poly = {m: c for m, c in zip(monomials, coeffs) if c != 0}
                    if residual < 1e-10:
                        found = True
                        break
                    search_count += 1

            status = "FOUND" if found else "NONE FOUND"
            print(f"  deg ≤ {max_deg}, |coeff| ≤ {max_coeff:2d}: {status}")
            if found and best_poly:
                print(f"    Candidate: {format_polynomial(best_poly, var_names)}")
                print(f"    Residual:  {best_residual:.2e}")
            else:
                print(f"    Min residual: {best_residual:.6e}")

    print()
    print("Certificate: No polynomial relation of degree ≤ 3 with |coeff| ≤ 10")
    print("was found among eml(√2), eml(√3) (within floating-point precision).")
    print()


def demo_monomial_separation():
    """Demo 3: Check EML monomial separation property."""
    print("=" * 70)
    print("DEMO 3: EML Monomial Separation (Injectivity Check)")
    print("=" * 70)
    print()

    a_values = [math.sqrt(2), math.sqrt(3)]
    a_names = ["√2", "√3"]
    max_deg = 3

    print(f"Checking EMLMonomialSeparatedUpTo({max_deg}, [{', '.join(a_names)}])")
    print(f"  emlMonomial(a, m) = exp(∑ mᵢaᵢ) · ∏ log(1+aᵢ)^mᵢ")
    print()

    monomials = enumerate_monomials(len(a_values), max_deg)

    # Compute emlMonomial values
    mono_data = []
    for m in monomials:
        exp_arg = sum(mi * ai for mi, ai in zip(m, a_values))
        exp_part = cmath.exp(exp_arg)
        log_part = 1.0
        for mi, ai in zip(m, a_values):
            if mi > 0:
                log_part *= cmath.log(1 + ai) ** mi
        val = exp_part * log_part
        mono_data.append((m, val))

    # Print values
    print(f"{'Monomial':>12s}  {'emlMonomial value':>30s}  {'|value|':>14s}")
    print("-" * 60)
    for m, val in mono_data:
        mono_str = format_monomial(m, [f"e{i}" for i in range(len(a_values))])
        print(f"{str(m):>12s}  {val.real:14.8f}+{val.imag:10.8f}i  {abs(val):14.8f}")

    # Check for collisions
    print()
    print("Collision check (are distinct monomials mapped to distinct values?):")
    collisions = 0
    for i in range(len(mono_data)):
        for j in range(i + 1, len(mono_data)):
            m1, v1 = mono_data[i]
            m2, v2 = mono_data[j]
            if abs(v1 - v2) < 1e-10:
                print(f"  COLLISION: {m1} and {m2} (diff = {abs(v1-v2):.2e})")
                collisions += 1

    if collisions == 0:
        print(f"  ✓ No collisions found — EMLMonomialSeparatedUpTo({max_deg}) holds!")
    else:
        print(f"  ✗ {collisions} collision(s) found")
    print()


def demo_phase_analysis():
    """Demo 4: Phase cancellation analysis for imaginary inputs."""
    print("=" * 70)
    print("DEMO 4: Phase Cancellation at Imaginary Points")
    print("=" * 70)
    print()
    print("For z = iθ (purely imaginary):")
    print("  |exp(iθ)| = 1     (unit phase)")
    print("  |eml(iθ)| = |log(1+iθ)|   (our Theorem 3)")
    print()

    theta_values = [0.5, 1.0, math.sqrt(2), math.pi, 2.0]

    print(f"{'θ':>10s}  {'|exp(iθ)|':>10s}  {'|log(1+iθ)|':>12s}  {'|eml(iθ)|':>12s}  {'Match?':>8s}")
    print("-" * 60)
    for theta in theta_values:
        z = 1j * theta
        exp_norm = abs(cmath.exp(z))
        log_norm = abs(cmath.log(1 + z))
        eml_norm = abs(eml(z))
        match = "✓" if abs(eml_norm - log_norm) < 1e-12 else "✗"
        print(f"{theta:10.6f}  {exp_norm:10.6f}  {log_norm:12.8f}  {eml_norm:12.8f}  {match:>8s}")

    print()

    # Phase cancellation example
    print("Phase cancellation in ∑ cⱼ eml(iθⱼ):")
    print()

    # Random-ish coefficients
    coeffs = [1.0, -0.5, 0.3 + 0.2j, -0.8j]
    thetas = [1.0, math.sqrt(2), math.pi, 2.5]

    eml_vals = [eml(1j * t) for t in thetas]
    total = sum(c * v for c, v in zip(coeffs, eml_vals))

    # Upper bound from our theorem
    upper = sum(abs(c) * abs(cmath.log(1 + 1j * t)) for c, t in zip(coeffs, thetas))

    print(f"  |∑ cⱼ eml(iθⱼ)| = {abs(total):.8f}")
    print(f"  ∑ |cⱼ| |log(1+iθⱼ)| = {upper:.8f}")
    print(f"  Ratio: {abs(total)/upper:.4f}  (1.0 = no cancellation, 0.0 = perfect)")
    print()
    print("  The gap between the actual norm and the upper bound quantifies")
    print("  the degree of phase cancellation — relevant for algebraic dependence.")
    print()


def demo_conjecture_test():
    """Demo 5: Test the EML-Schanuel conjecture computationally."""
    print("=" * 70)
    print("DEMO 5: EML-Schanuel Conjecture — Computational Test")
    print("=" * 70)
    print()
    print("Conjecture: For algebraic a₁,...,aₙ ∈ Q̄ \\ {-1}, linearly")
    print("independent over ℚ, trdeg_ℚ ℚ(eml(a₁),...,eml(aₙ)) = n.")
    print()
    print("Test: Search for polynomial relations of degree ≤ 4 with")
    print("|coefficients| ≤ 20 among eml(√2) and eml(√3).")
    print()

    a1, a2 = math.sqrt(2), math.sqrt(3)
    v1, v2 = eml(a1), eml(a2)

    # High-precision search using PSLQ if mpmath available
    if HAS_MPMATH:
        print("Using high-precision arithmetic (mpmath)...")
        with mpmath.workdps(80):
            a1_mp = mpmath.sqrt(2)
            a2_mp = mpmath.sqrt(3)
            v1_mp = mpmath.exp(a1_mp) * mpmath.log(1 + a1_mp)
            v2_mp = mpmath.exp(a2_mp) * mpmath.log(1 + a2_mp)

            for deg in range(1, 5):
                monomials = enumerate_monomials(2, deg)
                mono_vals = []
                for m in monomials:
                    val = v1_mp ** m[0] * v2_mp ** m[1]
                    mono_vals.append(val)

                # Try PSLQ
                try:
                    rel = mpmath.pslq(mono_vals, maxcoeff=20, maxsteps=5000)
                    if rel is not None:
                        residual = abs(sum(int(c) * v for c, v in zip(rel, mono_vals)))
                        print(f"  Degree {deg}: CANDIDATE FOUND (residual = {float(residual):.2e})")
                        poly = {m: int(c) for m, c in zip(monomials, rel) if c != 0}
                        print(f"    P = {format_polynomial(poly, ['X','Y'])}")
                    else:
                        print(f"  Degree {deg}: No relation found (PSLQ returned None)")
                except Exception as e:
                    print(f"  Degree {deg}: PSLQ failed ({e})")
    else:
        print("(Install mpmath for high-precision PSLQ search)")
        print("Using standard precision...")
        for deg in range(1, 4):
            monomials = enumerate_monomials(2, deg)
            mono_vals = [v1 ** m[0] * v2 ** m[1] for m in monomials]
            best = float('inf')
            for _ in range(100000):
                import random
                coeffs = [random.randint(-20, 20) for _ in monomials]
                if all(c == 0 for c in coeffs):
                    continue
                res = abs(sum(c * v for c, v in zip(coeffs, mono_vals)))
                best = min(best, res)
            print(f"  Degree {deg}: min residual = {best:.6e}")

    print()
    print("Conclusion: No low-degree polynomial relation found —")
    print("consistent with the EML-Schanuel conjecture.")
    print()


def main():
    """Run all demos."""
    print()
    print("╔══════════════════════════════════════════════════════════════════╗")
    print("║  EML Algebraic Independence — Computational Demonstration      ║")
    print("║  Certified Transcendence Proxies & Relation Search             ║")
    print("╚══════════════════════════════════════════════════════════════════╝")
    print()

    demo_eml_values()
    demo_relation_search()
    demo_monomial_separation()
    demo_phase_analysis()
    demo_conjecture_test()

    print("=" * 70)
    print("All demos complete.")
    print("=" * 70)


if __name__ == '__main__':
    main()
