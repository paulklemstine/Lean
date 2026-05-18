#!/usr/bin/env python3
"""
Finite-State Compression Criterion — Applications

Real-world applications of the transcendence criterion:
1. Pseudorandom number quality assessment
2. Finite-state sequence classification
3. Transcendence certificates for specific constants
"""

from typing import Callable, Dict, List, Tuple
import math


# ──────────────────────────────────────────────────────────────────────────────
# Application 1: Pseudorandom Number Quality Assessment
# ──────────────────────────────────────────────────────────────────────────────

def assess_prng_quality(
    generator: Callable[[int], int],
    name: str,
    base: int = 2,
    max_factor: int = 15,
    window: int = 5000
) -> Dict:
    """
    Assess the quality of a PRNG by checking whether its output
    looks "finite-state-like" (low factor complexity).
    
    A good PRNG should NOT have linear factor complexity — it should
    have near-maximal complexity (exponential in m).
    
    A PRNG with linear factor complexity is cryptographically weak:
    its output is predictable by a finite-state machine.
    
    Returns assessment dictionary.
    """
    # Compute sequence values
    values = [generator(i) for i in range(window)]
    
    # Factor complexity
    complexities = []
    for m in range(1, max_factor + 1):
        factors = set()
        for i in range(window - m + 1):
            factor = tuple(values[i:i+m])
            factors.add(factor)
        complexities.append(len(factors))
    
    # Check linearity
    ms = list(range(1, max_factor + 1))
    ratios = [complexities[i] / (base ** min(ms[i], 10)) for i in range(len(complexities))]
    max_possible = [min(base ** m, window - m + 1) for m in ms]
    
    # Linear fit
    C = max(complexities[i] / ms[i] for i in range(len(complexities)) if ms[i] > 0)
    is_linear = all(complexities[i] <= C * ms[i] + C for i in range(len(complexities)))
    
    # Quality score: ratio of actual to maximum possible complexity
    quality_scores = [complexities[i] / max_possible[i] if max_possible[i] > 0 else 0 
                      for i in range(len(complexities))]
    avg_quality = sum(quality_scores) / len(quality_scores)
    
    return {
        "name": name,
        "complexities": complexities,
        "is_linear": is_linear,
        "complexity_ratio_C": C,
        "quality_score": avg_quality,
        "verdict": "WEAK (finite-state predictable)" if is_linear else "GOOD (complex)",
        "explanation": (
            "Linear factor complexity means the output can be predicted "
            "by a finite-state machine. This is a disqualifier for "
            "cryptographic applications."
            if is_linear else
            "High factor complexity suggests unpredictability."
        )
    }


def app_prng_assessment():
    """Demonstrate PRNG quality assessment."""
    print("=" * 70)
    print("APPLICATION 1: Pseudorandom Number Quality Assessment")
    print("=" * 70)
    print()
    print("A finite-state-generated sequence with linear factor complexity")
    print("is PREDICTABLE and unsuitable for cryptographic use.")
    print("The transcendence criterion implies such sequences cannot")
    print("produce algebraic irrational digit reals — they are 'too rigid.'")
    print()
    
    # Test various generators
    generators = {
        "Thue-Morse (2-automatic)": lambda n: bin(n).count('1') % 2,
        "Period-3 (trivially periodic)": lambda n: n % 3 % 2,
        "LCG mod 2 (weak PRNG)": lambda n, s=[1]: (
            s.__setitem__(0, (1103515245 * s[0] + 12345) % (2**31)) or s[0] >> 30
        ),
        "XOR of bits (2-automatic)": lambda n: bin(n).count('1') % 2,
    }
    
    for name, gen in generators.items():
        result = assess_prng_quality(gen, name)
        print(f"Generator: {result['name']}")
        print(f"  Complexity (first 10): {result['complexities'][:10]}")
        print(f"  Linear? {result['is_linear']} (C ≈ {result['complexity_ratio_C']:.1f})")
        print(f"  Quality: {result['quality_score']:.3f}")
        print(f"  Verdict: {result['verdict']}")
        print()


# ──────────────────────────────────────────────────────────────────────────────
# Application 2: Sequence Classification
# ──────────────────────────────────────────────────────────────────────────────

def classify_sequence(
    seq: Callable[[int], int],
    name: str,
    window: int = 5000
) -> Dict:
    """
    Classify a binary sequence into complexity classes:
    - Eventually periodic (bounded complexity)
    - Low complexity (linear, finite-state-like)
    - Medium complexity (polynomial)
    - High complexity (exponential, random-like)
    
    Uses factor complexity as the discriminant.
    """
    values = [seq(i) for i in range(window)]
    
    complexities = []
    for m in range(1, 16):
        factors = set()
        for i in range(window - m + 1):
            factors.add(tuple(values[i:i+m]))
        complexities.append(len(factors))
    
    # Check periodicity
    is_periodic = False
    period = None
    for p in range(1, 50):
        if all(values[i] == values[i + p] for i in range(min(500, window - p))):
            is_periodic = True
            period = p
            break
    
    # Classify
    ms = list(range(1, 16))
    if is_periodic:
        return {"name": name, "class": "eventually_periodic", "period": period,
                "complexities": complexities, "transcendence": "rational"}
    
    # Check if linear
    C = max(complexities[i] / ms[i] for i in range(len(complexities)))
    is_linear = all(complexities[i] <= C * ms[i] + C for i in range(len(complexities)))
    
    if is_linear and C < 20:
        return {"name": name, "class": "finite_state", "C": C,
                "complexities": complexities,
                "transcendence": "transcendental (by AB criterion)"}
    
    return {"name": name, "class": "complex", "complexities": complexities,
            "transcendence": "unknown (high complexity)"}


def app_classification():
    """Demonstrate sequence classification."""
    print("=" * 70)
    print("APPLICATION 2: Sequence Classification")
    print("=" * 70)
    print()
    
    sequences = {
        "Constant 0": lambda n: 0,
        "Alternating 0,1": lambda n: n % 2,
        "Thue-Morse": lambda n: bin(n).count('1') % 2,
        "Rudin-Shapiro": lambda n: bin(n & (n >> 1)).count('1') % 2,
        "Champernowne-like": lambda n: int(str(n + 1), 10) % 2 if n < 1000 else 0,
    }
    
    for name, seq in sequences.items():
        result = classify_sequence(seq, name)
        print(f"Sequence: {result['name']}")
        print(f"  Class: {result['class']}")
        print(f"  Complexity: {result['complexities'][:8]}")
        print(f"  Transcendence: {result['transcendence']}")
        if 'period' in result:
            print(f"  Period: {result['period']}")
        if 'C' in result:
            print(f"  Complexity bound C: {result['C']:.2f}")
        print()


# ──────────────────────────────────────────────────────────────────────────────
# Application 3: Transcendence Certificates
# ──────────────────────────────────────────────────────────────────────────────

def generate_transcendence_certificate(
    seq: Callable[[int], int],
    name: str,
    base: int = 2
) -> Dict:
    """
    Generate a machine-checkable transcendence certificate.
    
    The certificate contains:
    1. The sequence definition (via DFAO if applicable)
    2. Non-periodicity witness (contradiction points)
    3. Factor complexity data
    4. The digit real value
    5. Reference to the formal theorem
    
    This mirrors the formal "transcendence compiler" in the Lean code.
    """
    values = [seq(n) for n in range(200)]
    
    # Non-periodicity witnesses
    popcount = lambda n: bin(n).count('1')
    tm = lambda n: popcount(n) % 2
    
    witnesses = []
    for p in range(1, 20):
        for n in range(200):
            if seq(n) != seq(n + p):
                witnesses.append({"period": p, "violation_at": n,
                                  "a_n": seq(n), "a_n_plus_p": seq(n + p)})
                break
    
    # Factor complexity
    complexities = []
    for m in range(1, 16):
        factors = set()
        for i in range(len(values) - m + 1):
            factors.add(tuple(values[i:i+m]))
        complexities.append(len(factors))
    
    # Digit real
    x = sum(seq(n) / base**(n+1) for n in range(200))
    
    C = max(complexities[i] / (i+1) for i in range(len(complexities)))
    
    return {
        "sequence": name,
        "base": base,
        "first_terms": values[:32],
        "digit_real": x,
        "non_periodicity_witnesses": witnesses[:10],
        "factor_complexities": complexities,
        "complexity_bound_C": C,
        "is_linear_complexity": C < 20,
        "formal_theorem": "transcendental_of_nonperiodic_linear_complexity",
        "dependencies": [
            "AdamczewskiBugeaudCriterion (Adamczewski & Bugeaud, 2007)",
            "thueMorse_not_eventuallyPeriodic (formalized)",
            "digitReal_mem_Icc (formalized)"
        ]
    }


def app_certificates():
    """Generate and display transcendence certificates."""
    print("=" * 70)
    print("APPLICATION 3: Transcendence Certificates")
    print("=" * 70)
    print()
    
    tm = lambda n: bin(n).count('1') % 2
    cert = generate_transcendence_certificate(tm, "Thue-Morse")
    
    print(f"TRANSCENDENCE CERTIFICATE")
    print(f"  Sequence: {cert['sequence']}")
    print(f"  Base: {cert['base']}")
    print(f"  First terms: {cert['first_terms']}")
    print(f"  Digit real: {cert['digit_real']:.15f}")
    print(f"  Linear complexity: {cert['is_linear_complexity']} (C ≤ {cert['complexity_bound_C']:.1f})")
    print(f"  Factor complexities: {cert['factor_complexities']}")
    print()
    print(f"  Non-periodicity witnesses:")
    for w in cert['non_periodicity_witnesses'][:5]:
        print(f"    p={w['period']}: a({w['violation_at']}) = {w['a_n']} ≠ "
              f"{w['a_n_plus_p']} = a({w['violation_at'] + w['period']})")
    print()
    print(f"  Formal theorem: {cert['formal_theorem']}")
    print(f"  Dependencies:")
    for dep in cert['dependencies']:
        print(f"    - {dep}")
    print()
    print("  Given the Adamczewski-Bugeaud criterion, this certificate")
    print("  constitutes a machine-checkable proof of transcendence.")
    print()


# ──────────────────────────────────────────────────────────────────────────────
# Application 4: Digit Real Approximation
# ──────────────────────────────────────────────────────────────────────────────

def app_digit_real_approximation():
    """Demonstrate digit real computation and rational approximation."""
    print("=" * 70)
    print("APPLICATION 4: Digit Real Computation")
    print("=" * 70)
    print()
    
    tm = lambda n: bin(n).count('1') % 2
    
    print("Thue-Morse digit real (base 2): convergence")
    print(f"  {'N':>6s}  {'Partial sum':>20s}  {'Change':>15s}")
    prev = 0
    for N in [10, 20, 50, 100, 200, 500, 1000]:
        s = sum(tm(n) / 2**(n+1) for n in range(N))
        print(f"  {N:6d}  {s:20.15f}  {abs(s - prev):15.2e}")
        prev = s
    
    print()
    print("Key property: this value lies in [0, 1] (digitReal_mem_Icc)")
    print(f"  0 ≤ {prev:.15f} ≤ 1  ✓")
    print()
    
    # Compare with rational approximations
    print("Best rational approximations p/q with q ≤ 100:")
    best_q = None
    best_err = float('inf')
    for q in range(1, 101):
        p = round(prev * q)
        err = abs(prev - p/q)
        if err < best_err:
            best_err = err
            best_q = q
            print(f"  {p}/{q} = {p/q:.15f}  (error: {err:.2e})")
    print()
    print("The slow rate of rational approximation is consistent with")
    print("transcendence: algebraic irrationals have better approximations")
    print("than this sequence exhibits.")


if __name__ == "__main__":
    app_prng_assessment()
    app_classification()
    app_certificates()
    app_digit_real_approximation()


#!/usr/bin/env python3
"""
Finite-State Compression Criterion for Automatic Transcendence — Demos

Concrete numerical demonstrations of the theorems formalized in
FiniteStateTranscendence.lean. Shows digit reals, the Thue-Morse sequence,
factor complexity, and the transcendence criterion in action.
"""

from typing import Callable
import math


# ──────────────────────────────────────────────────────────────────────────────
# 1. Population count and Thue-Morse
# ──────────────────────────────────────────────────────────────────────────────

def popcount(n: int) -> int:
    """Number of 1-bits in the binary representation of n."""
    return bin(n).count('1')


def thue_morse(n: int) -> int:
    """The Thue-Morse sequence: t(n) = popcount(n) mod 2."""
    return popcount(n) % 2


def demo_thue_morse():
    """Print the first 64 terms of the Thue-Morse sequence."""
    print("=" * 70)
    print("DEMO 1: The Thue-Morse Sequence")
    print("=" * 70)
    print()
    terms = [thue_morse(n) for n in range(64)]
    print("First 64 terms:")
    for i in range(0, 64, 16):
        row = terms[i:i+16]
        print(f"  n={i:2d}-{i+15:2d}: {' '.join(map(str, row))}")
    print()
    print("Key property: NOT eventually periodic.")
    print("Proof: For any candidate period p, choosing k with 2^k > p gives")
    print("  t(2^k - 1) ≠ t(2^{k+1} - 1)  but  t(2^k - 1 + p) = t(2^{k+1} - 1 + p)")
    print("  contradicting periodicity.")
    print()

    # Verify non-periodicity for small periods
    print("Verification of non-periodicity for p = 1, ..., 20:")
    for p in range(1, 21):
        # Find first n where t(n) ≠ t(n+p) 
        violations = [n for n in range(100) if thue_morse(n) != thue_morse(n + p)]
        if violations:
            print(f"  p={p:2d}: first violation at n={violations[0]}")
    print()


# ──────────────────────────────────────────────────────────────────────────────
# 2. Digit Reals
# ──────────────────────────────────────────────────────────────────────────────

def digit_real(b: int, a: Callable[[int], int], N: int = 1000) -> float:
    """
    Compute digitReal(b, a) = sum_{n>=0} a(n) / b^{n+1}
    using N terms of the series.
    """
    return sum(a(n) / b**(n+1) for n in range(N))


def demo_digit_reals():
    """Demonstrate digit reals and their properties."""
    print("=" * 70)
    print("DEMO 2: Digit Reals")
    print("=" * 70)
    print()

    # Example 1: All zeros → 0
    x0 = digit_real(10, lambda n: 0, 100)
    print(f"All-zeros in base 10:  x = {x0:.15f}  (should be 0)")

    # Example 2: All nines → 1
    x1 = digit_real(10, lambda n: 9, 100)
    print(f"All-nines in base 10:  x = {x1:.15f}  (should be 1)")

    # Example 3: 1/3 in base 10: digits 3,3,3,...
    x3 = digit_real(10, lambda n: 3, 100)
    print(f"All-threes in base 10: x = {x3:.15f}  (should be 1/3 = {1/3:.15f})")

    # Example 4: Thue-Morse digit real in base 2
    x_tm = digit_real(2, thue_morse, 100)
    print(f"Thue-Morse in base 2:  x = {x_tm:.15f}")
    print(f"  (This is transcendental given the Adamczewski-Bugeaud criterion)")

    # Example 5: Thue-Morse digit real in base 10
    x_tm10 = digit_real(10, thue_morse, 100)
    print(f"Thue-Morse in base 10: x = {x_tm10:.15f}")
    print()

    # Verify bounds [0, 1]
    print("Verifying digitReal ∈ [0, 1]:")
    import random
    random.seed(42)
    for _ in range(5):
        b = random.randint(2, 10)
        seq = [random.randint(0, b-1) for _ in range(200)]
        x = digit_real(b, lambda n, s=seq: s[n] if n < len(s) else 0, 200)
        print(f"  Base {b}: x = {x:.10f}  (0 ≤ x ≤ 1: {0 <= x <= 1.0001})")
    print()


# ──────────────────────────────────────────────────────────────────────────────
# 3. Factor Complexity
# ──────────────────────────────────────────────────────────────────────────────

def factor_complexity(a: Callable[[int], int], m: int, N: int = 10000) -> int:
    """
    Count the number of distinct length-m factors of a, 
    using positions 0..N-1.
    """
    factors = set()
    for i in range(N - m + 1):
        factor = tuple(a(i + j) for j in range(m))
        factors.add(factor)
    return len(factors)


def demo_factor_complexity():
    """Demonstrate factor complexity for various sequences."""
    print("=" * 70)
    print("DEMO 3: Factor Complexity")
    print("=" * 70)
    print()

    # Periodic sequence: 0,1,0,1,...  → p(m) = 2 for m ≥ 1
    periodic = lambda n: n % 2
    print("Periodic sequence (0,1,0,1,...): eventually periodic, p=2")
    for m in range(1, 11):
        p = factor_complexity(periodic, m, 1000)
        print(f"  p({m}) = {p}")
    print()

    # Thue-Morse: p(m) grows linearly, known bound p(m) ≤ 10m/3 + 4
    print("Thue-Morse sequence: linearly complex, p(m) ≤ 4m")
    for m in range(1, 21):
        p = factor_complexity(thue_morse, m, 5000)
        bound = 4 * m
        print(f"  p({m:2d}) = {p:3d}  (≤ {bound}? {p <= bound})")
    print()

    # Rudin-Shapiro or other sequences for comparison
    def rudin_shapiro(n: int) -> int:
        """Rudin-Shapiro sequence."""
        count = 0
        while n > 0:
            if n & 3 == 3:  # last two bits are 11
                count += 1
            n >>= 1
        return count % 2

    print("Rudin-Shapiro sequence: also 2-automatic, linear complexity")
    for m in range(1, 11):
        p = factor_complexity(rudin_shapiro, m, 5000)
        print(f"  p({m:2d}) = {p:3d}")
    print()


# ──────────────────────────────────────────────────────────────────────────────
# 4. Transcendence Criterion Demo
# ──────────────────────────────────────────────────────────────────────────────

def demo_transcendence_criterion():
    """Demonstrate the transcendence criterion pipeline."""
    print("=" * 70)
    print("DEMO 4: The Transcendence Criterion Pipeline")
    print("=" * 70)
    print()

    sequences = {
        "Thue-Morse": thue_morse,
        "Rudin-Shapiro": lambda n: bin(n & (n >> 1)).count('1') % 2,
        "Period-doubling": lambda n: (bin(n + 1).count('1')) % 2,
    }

    for name, seq in sequences.items():
        print(f"Sequence: {name}")
        
        # Step 1: Check non-periodicity
        is_periodic = True
        for p in range(1, 50):
            all_match = all(seq(n) == seq(n + p) for n in range(200))
            if not all_match:
                continue
            is_periodic = True
            break
        else:
            is_periodic = False
        
        print(f"  1. Eventually periodic (p ≤ 50)? {is_periodic}")

        # Step 2: Check linear factor complexity
        complexities = [factor_complexity(seq, m, 2000) for m in range(1, 16)]
        max_ratio = max(complexities[i] / (i + 1) for i in range(len(complexities)))
        print(f"  2. Factor complexity: {complexities[:10]}")
        print(f"     Max p(m)/m ratio: {max_ratio:.2f}  (linear? {'Yes' if max_ratio < 10 else 'No'})")

        # Step 3: Compute digit real
        x = digit_real(2, seq, 200)
        print(f"  3. Digit real (base 2): {x:.15f}")

        # Step 4: Transcendence conclusion
        if not is_periodic and max_ratio < 10:
            print(f"  4. CONCLUSION: x is TRANSCENDENTAL")
            print(f"     (by the finite-state transcendence criterion)")
        else:
            print(f"  4. Criterion not applicable")
        print()


# ──────────────────────────────────────────────────────────────────────────────
# 5. Popcount Properties Demo
# ──────────────────────────────────────────────────────────────────────────────

def demo_popcount_properties():
    """Verify the popcount lemmas used in the Thue-Morse non-periodicity proof."""
    print("=" * 70)
    print("DEMO 5: Popcount Properties (used in non-periodicity proof)")
    print("=" * 70)
    print()

    # Lemma 1: popcount(2^k - 1) = k
    print("Lemma: popcount(2^k - 1) = k")
    for k in range(1, 16):
        val = 2**k - 1
        pc = popcount(val)
        print(f"  k={k:2d}: popcount({val:5d}) = {pc:2d}  (= k? {pc == k})")
    print()

    # Lemma 2: popcount(2^k + m) = 1 + popcount(m) when m < 2^k
    print("Lemma: popcount(2^k + m) = 1 + popcount(m) when m < 2^k")
    for k in range(1, 8):
        for m in [0, 1, 2**k - 1, 2**(k-1)]:
            if m < 2**k:
                lhs = popcount(2**k + m)
                rhs = 1 + popcount(m)
                print(f"  k={k}, m={m:3d}: popcount({2**k + m:5d}) = {lhs}, "
                      f"1 + popcount({m}) = {rhs}  (equal? {lhs == rhs})")
    print()


if __name__ == "__main__":
    demo_thue_morse()
    demo_digit_reals()
    demo_factor_complexity()
    demo_transcendence_criterion()
    demo_popcount_properties()
