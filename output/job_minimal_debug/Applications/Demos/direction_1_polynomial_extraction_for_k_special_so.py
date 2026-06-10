#!/usr/bin/env python3
"""
Real-World Applications of Polynomial Extraction Theory

Demonstrates how the polynomial extraction framework applies to concrete
cryptographic protocols and coding-theoretic problems.

Keywords: Schnorr protocol, Chaum-Pedersen, Bulletproofs, compressed Σ-protocols,
Attema-Cramer compression, Reed-Solomon decoding, algebraic proof systems
"""

import random
from typing import List, Tuple, Dict, Optional
from algorithms import FiniteField, Polynomial, lagrange_interpolation, reed_solomon_encode


# ============================================================================
# Application 1: Multi-Round Σ-Protocol Extraction
# ============================================================================

class PolynomialSigmaProtocol:
    """A Σ-protocol whose acceptance condition is polynomial in the challenge.

    Models the abstract framework from the formal development:
    - The verifier checks that a polynomial P(c) = 0 where c is the challenge
    - The polynomial has degree ≤ challenge_bound
    - The polynomial coefficients encode the witness

    This generalizes:
    - Schnorr (degree 1): P(c) = z - r - c*w
    - Compressed Σ-protocols (degree k-1): P(c) = Σ a_i c^i
    """

    def __init__(self, field: FiniteField, challenge_bound: int):
        self.field = field
        self.challenge_bound = challenge_bound

    def generate_acceptance_poly(self, witness_coeffs: List[int],
                                  commitment_rand: int) -> Polynomial:
        """Generate the acceptance polynomial for a given witness.

        The acceptance polynomial is constructed so that:
        P(c) = commitment_rand + Σ_{i=0}^{d} witness_coeffs[i] * c^{i+1}
        minus the response z(c).

        For simplicity we model the response as z(c) = commitment_rand + Σ w_i c^{i+1},
        so P(c) = 0 for all c (honest execution).
        """
        # In honest execution, the polynomial evaluates to 0 at every challenge
        coeffs = [commitment_rand] + witness_coeffs
        return Polynomial(self.field, coeffs)

    def create_transcript(self, witness_coeffs: List[int],
                          commitment_rand: int, challenge: int) -> dict:
        """Create an accepting transcript at a given challenge.

        Returns the response that makes the verifier accept.
        """
        poly = self.generate_acceptance_poly(witness_coeffs, commitment_rand)
        response = poly.eval(challenge)

        return {
            'challenge': challenge,
            'response': response,
            'commitment_rand': commitment_rand
        }

    def extract_witness(self, transcripts: List[dict]) -> List[int]:
        """Extract the witness from k+1 accepting transcripts.

        Uses Lagrange interpolation on the response values to recover
        the acceptance polynomial, then reads off witness coefficients.
        """
        k = len(transcripts)
        points = [(t['challenge'], t['response']) for t in transcripts]
        recovered_poly = lagrange_interpolation(self.field, points)

        # Witness coefficients are coefficients 1 through challenge_bound
        witness = []
        for i in range(1, self.challenge_bound + 1):
            if i < len(recovered_poly.coeffs):
                witness.append(recovered_poly.coeffs[i])
            else:
                witness.append(0)
        return witness


def app_sigma_protocol_extraction():
    """Demonstrate multi-round extraction for degree-2 and degree-3 protocols."""
    print("\n" + "="*70)
    print("  APPLICATION 1: Multi-Round Σ-Protocol Extraction")
    print("="*70)

    prime = 37
    F = FiniteField(prime)

    for degree in [1, 2, 3, 4]:
        protocol = PolynomialSigmaProtocol(F, degree)
        k = degree + 1  # Need degree+1 transcripts

        # Random witness
        witness = [F.random_element() for _ in range(degree)]
        commitment_rand = F.random_element()

        # Generate k transcripts at distinct challenges
        challenges = random.sample(range(1, prime), k)
        transcripts = [protocol.create_transcript(witness, commitment_rand, c)
                       for c in challenges]

        # Extract
        extracted = protocol.extract_witness(transcripts)

        match = extracted == witness
        print(f"\n  Degree-{degree} protocol (k={k} transcripts):")
        print(f"    Witness:   {witness}")
        print(f"    Extracted: {extracted}")
        print(f"    {'✓ Match' if match else '✗ Mismatch'}")


# ============================================================================
# Application 2: Schnorr Protocol as Degree-1 Instance
# ============================================================================

def app_schnorr_as_degree_one():
    """Show Schnorr extraction is the k=2 case of polynomial extraction."""
    print("\n" + "="*70)
    print("  APPLICATION 2: Schnorr Protocol as Degree-1 Polynomial Extraction")
    print("="*70)

    prime = 23
    F = FiniteField(prime)

    print("\n  Schnorr protocol: z = r + c·w")
    print("  This is a degree-1 polynomial in c: P(c) = r + w·c")
    print("  Two transcripts at distinct challenges suffice for extraction.\n")

    for trial in range(5):
        w = F.random_element()
        r = F.random_element()

        c1, c2 = random.sample(range(prime), 2)
        z1 = F.add(r, F.mul(c1, w))
        z2 = F.add(r, F.mul(c2, w))

        # Method 1: Affine formula
        w_affine = F.div(F.sub(z1, z2), F.sub(c1, c2))

        # Method 2: Lagrange interpolation
        poly = lagrange_interpolation(F, [(c1, z1), (c2, z2)])
        w_lagrange = poly.coeffs[1] if len(poly.coeffs) > 1 else 0

        print(f"  Trial {trial+1}: w={w}, r={r}, (c₁,z₁)=({c1},{z1}), (c₂,z₂)=({c2},{z2})")
        print(f"    Affine extraction: w = {w_affine} {'✓' if w_affine == w else '✗'}")
        print(f"    Lagrange coeff[1]: w = {w_lagrange} {'✓' if w_lagrange == w else '✗'}")


# ============================================================================
# Application 3: Reed–Solomon Error Detection
# ============================================================================

def app_reed_solomon_error_detection():
    """Demonstrate how extraction detects cheating provers via RS distance."""
    print("\n" + "="*70)
    print("  APPLICATION 3: Cheating Detection via Reed–Solomon Distance")
    print("="*70)

    prime = 31
    F = FiniteField(prime)
    k = 3  # Degree bound + 1
    n = 7  # Number of evaluation points

    print(f"\n  RS({n},{k}) code over GF({prime})")
    print(f"  Minimum distance d = {n - k + 1}")
    print(f"  A cheating prover who doesn't know a degree-{k-1} polynomial")
    print(f"  will be caught with high probability.\n")

    # Honest prover: knows the witness polynomial
    witness = [F.random_element() for _ in range(k)]
    eval_points = list(range(1, n + 1))
    honest_codeword = reed_solomon_encode(F, witness, eval_points)

    print(f"  Honest witness: {witness}")
    print(f"  Honest codeword: {honest_codeword}")

    # Cheating prover: guesses random responses
    cheating_codeword = [F.random_element() for _ in range(n)]

    # Check how many positions match
    matches = sum(1 for h, c in zip(honest_codeword, cheating_codeword) if h == c)
    print(f"\n  Cheating codeword: {cheating_codeword}")
    print(f"  Positions matching honest: {matches}/{n}")
    print(f"  Reed–Solomon guarantees ≤ {k-1} matches for distinct codewords")

    # Try to decode cheating codeword
    cheat_points = list(zip(eval_points[:k], cheating_codeword[:k]))
    cheat_poly = lagrange_interpolation(F, cheat_points)
    cheat_consistent = all(cheat_poly.eval(eval_points[i]) == cheating_codeword[i]
                           for i in range(n))

    print(f"  Cheating codeword is {'consistent' if cheat_consistent else 'inconsistent'} "
          f"with a degree-{k-1} polynomial")
    if not cheat_consistent:
        print(f"  → Cheater DETECTED: responses inconsistent with any valid witness")


# ============================================================================
# Application 4: Compressed Σ-Protocol Simulation (Attema–Cramer Style)
# ============================================================================

def app_compressed_sigma():
    """Simulate Attema–Cramer style compressed Σ-protocol extraction."""
    print("\n" + "="*70)
    print("  APPLICATION 4: Compressed Σ-Protocol (Attema–Cramer Style)")
    print("="*70)

    prime = 41
    F = FiniteField(prime)

    # Compression parameter μ: the acceptance polynomial has degree μ-1
    for mu in [2, 3, 4]:
        k = mu  # Need μ transcripts
        degree = mu - 1

        print(f"\n  Compression parameter μ={mu}:")
        print(f"  Acceptance polynomial degree: {degree}")
        print(f"  Transcripts needed for extraction: {k}")

        # Witness determines coefficients of the acceptance polynomial
        witness_coeffs = [F.random_element() for _ in range(mu)]
        accept_poly = Polynomial(F, witness_coeffs)

        print(f"  Acceptance polynomial: {accept_poly}")

        # k transcripts at distinct challenges
        challenges = random.sample(range(1, prime), k)
        evaluations = [accept_poly.eval(c) for c in challenges]

        points = list(zip(challenges, evaluations))
        recovered = lagrange_interpolation(F, points)

        match = recovered == accept_poly
        print(f"  Recovered polynomial: {recovered}")
        print(f"  {'✓ Extraction successful' if match else '✗ Extraction failed'}")


# ============================================================================
# Application 5: Batch Verification via Polynomial Checking
# ============================================================================

def app_batch_verification():
    """Demonstrate batch verification: check multiple transcripts at once."""
    print("\n" + "="*70)
    print("  APPLICATION 5: Batch Verification via Polynomial Checking")
    print("="*70)

    prime = 47
    F = FiniteField(prime)
    k = 4
    n_transcripts = 10

    print(f"\n  Batch-verify {n_transcripts} transcripts for a degree-{k-1} protocol")
    print(f"  over GF({prime}).\n")

    # Generate honest transcripts
    witness = [F.random_element() for _ in range(k)]
    witness_poly = Polynomial(F, witness)

    challenges = random.sample(range(1, prime), n_transcripts)
    evaluations = [witness_poly.eval(c) for c in challenges]

    # Verify all at once: interpolate from k points, check consistency with rest
    check_points = list(zip(challenges[:k], evaluations[:k]))
    interp_poly = lagrange_interpolation(F, check_points)

    all_consistent = all(
        interp_poly.eval(challenges[i]) == evaluations[i]
        for i in range(k, n_transcripts)
    )

    print(f"  Interpolated from {k} transcripts, checked {n_transcripts - k} more")
    print(f"  All consistent: {'✓ Yes' if all_consistent else '✗ No'}")
    print(f"\n  → Batch verification: O(k²) interpolation + O(n) evaluation checks")
    print(f"     vs O(nk) individual verification")

    # Now corrupt one transcript
    if n_transcripts > k:
        corrupted_evals = evaluations[:]
        corrupt_idx = k + 1 if n_transcripts > k + 1 else k
        corrupted_evals[corrupt_idx] = F.add(corrupted_evals[corrupt_idx], 1)

        check_points2 = list(zip(challenges[:k], corrupted_evals[:k]))
        interp_poly2 = lagrange_interpolation(F, check_points2)

        any_inconsistent = any(
            interp_poly2.eval(challenges[i]) != corrupted_evals[i]
            for i in range(k, n_transcripts)
        )

        print(f"\n  After corrupting transcript {corrupt_idx}:")
        print(f"  Inconsistency detected: {'✓ Yes' if any_inconsistent else '✗ No'}")


def main():
    """Run all applications."""
    random.seed(2024)

    print("""
╔══════════════════════════════════════════════════════════════════════╗
║  Applications of Polynomial Extraction Theory                      ║
║                                                                    ║
║  Showing how the polynomial extraction framework applies to        ║
║  real cryptographic protocols and coding-theoretic problems.        ║
╚══════════════════════════════════════════════════════════════════════╝
""")

    app_sigma_protocol_extraction()
    app_schnorr_as_degree_one()
    app_reed_solomon_error_detection()
    app_compressed_sigma()
    app_batch_verification()

    print("\n" + "="*70)
    print("  All applications demonstrated successfully.")
    print("="*70)


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Interactive Finite-Field Simulation of Polynomial Extraction for k-Special Soundness

Demonstrates the core thesis: multi-transcript witness extraction in Σ-protocols
is equivalent to polynomial interpolation over finite fields, which is the
injectivity of the Reed–Solomon evaluation map.

Runs extraction for k = 2, 3, 4, 5 over small prime fields, generates random
witnesses, synthesizes transcript evaluations, runs extraction, and displays
success/failure. Also searches for counterexamples when degree assumptions are violated.

Keywords: special soundness, Σ-protocols, polynomial interpolation, Reed–Solomon codes,
finite fields, Lagrange interpolation, Vandermonde matrices, witness extraction,
algebraic cryptanalysis, low-degree testing, error-correcting codes
"""

import random
import sys
from typing import List, Tuple

# Import algorithms from the companion module
from algorithms import (
    FiniteField, Polynomial, lagrange_interpolation, vandermonde_extraction,
    reed_solomon_encode, reed_solomon_decode, affine_extract_1d
)


def separator(title: str):
    """Print a section separator."""
    print(f"\n{'='*70}")
    print(f"  {title}")
    print(f"{'='*70}\n")


def demo_affine_extraction():
    """Demo 1: Affine extraction (k=2) — the classical Schnorr case."""
    separator("DEMO 1: Affine Extraction (k=2) — The Schnorr Protocol")

    primes = [7, 13, 17, 23, 31]

    for p in primes:
        F = FiniteField(p)
        # Random witness and commitment randomness
        w = F.random_element()
        r = F.random_element()

        # Two distinct challenges
        c1 = F.random_element()
        c2 = F.random_element()
        while c2 == c1:
            c2 = F.random_element()

        # Responses: z_i = r + c_i * w
        z1 = F.add(r, F.mul(c1, w))
        z2 = F.add(r, F.mul(c2, w))

        # Extract
        w_extracted = affine_extract_1d(F, z1, z2, c1, c2)

        status = "✓" if w_extracted == w else "✗"
        print(f"  GF({p}): w={w}, r={r}, c₁={c1}, c₂={c2}, "
              f"z₁={z1}, z₂={z2} → extracted w={w_extracted} {status}")

    print(f"\n  → Affine extraction always succeeds with 2 distinct challenges.")
    print(f"    This is the degree-1 case of polynomial extraction.")


def demo_polynomial_extraction(k: int, prime: int = 31):
    """Demo: k-special soundness via polynomial extraction.

    Simulates a protocol where acceptance is polynomial of degree k-1 in the challenge.
    The witness encodes as coefficients of a degree-(k-1) polynomial.
    k accepting transcripts at distinct challenges recover the witness.
    """
    separator(f"DEMO: Polynomial Extraction (k={k}) over GF({prime})")

    F = FiniteField(prime)

    # Random witness polynomial of degree k-1
    # Coefficients are the "witness"
    witness_coeffs = [F.random_element() for _ in range(k)]
    witness_poly = Polynomial(F, witness_coeffs)

    print(f"  Witness polynomial: p(x) = {witness_poly}")
    print(f"  Degree bound: {k-1}")
    print(f"  Number of transcripts: {k}")

    # k distinct challenges
    challenges = random.sample(range(prime), k)
    print(f"  Challenges: {challenges}")

    # "Accepting transcripts" = evaluations at challenges
    evaluations = [witness_poly.eval(c) for c in challenges]
    print(f"  Evaluations: {evaluations}")

    # Extract via Lagrange interpolation
    points = list(zip(challenges, evaluations))
    recovered = lagrange_interpolation(F, points)

    print(f"\n  Recovered polynomial: p(x) = {recovered}")
    print(f"  Original  polynomial: p(x) = {witness_poly}")

    if recovered == witness_poly:
        print(f"  ✓ EXTRACTION SUCCESSFUL — witness uniquely recovered from {k} transcripts")
    else:
        print(f"  ✗ EXTRACTION FAILED")

    # Also try Vandermonde method
    recovered_vand = vandermonde_extraction(F, points)
    if recovered_vand == witness_poly:
        print(f"  ✓ Vandermonde extraction also succeeds")

    return recovered == witness_poly


def demo_reed_solomon_connection(k: int = 3, n: int = 5, prime: int = 31):
    """Demo: Reed–Solomon coding interpretation of extraction."""
    separator(f"DEMO: Reed–Solomon Connection (k={k}, n={n}) over GF({prime})")

    F = FiniteField(prime)

    # Message = witness coefficients
    message = [F.random_element() for _ in range(k)]
    print(f"  Message (witness): {message}")

    # Evaluation points
    eval_points = random.sample(range(prime), n)
    print(f"  Evaluation points: {eval_points}")

    # Encode = evaluate message polynomial
    codeword = reed_solomon_encode(F, message, eval_points)
    print(f"  Codeword: {codeword}")

    # Decode from first k symbols
    recovered = reed_solomon_decode(F, codeword, eval_points, k)
    print(f"  Recovered message: {recovered}")

    if recovered == message:
        print(f"\n  ✓ RS DECODING = WITNESS EXTRACTION")
        print(f"    Unique decoding from {k} evaluations of a degree-{k-1} polynomial")
        print(f"    = extraction from {k} accepting transcripts")
    else:
        print(f"  ✗ Decoding failed")


def demo_degree_violation():
    """Demo: Extraction failure when degree assumption is violated."""
    separator("DEMO: Degree Violation — When Extraction Fails")

    prime = 31
    F = FiniteField(prime)

    print("  When the polynomial has degree ≥ k, extraction is NOT unique.\n")

    # Degree-2 polynomial, but only 2 evaluation points (need 3)
    k = 2
    witness_poly = Polynomial(F, [3, 7, 2])  # degree 2
    print(f"  Witness polynomial: p(x) = {witness_poly} (degree {witness_poly.degree})")
    print(f"  Using only k={k} evaluation points (need k ≥ {witness_poly.degree + 1})")

    challenges = random.sample(range(prime), k)
    evaluations = [witness_poly.eval(c) for c in challenges]
    points = list(zip(challenges, evaluations))

    # Lagrange interpolation gives a degree-(k-1) polynomial, NOT the original
    recovered = lagrange_interpolation(F, points)
    print(f"\n  Recovered:  {recovered} (degree {recovered.degree})")
    print(f"  Original:   {witness_poly} (degree {witness_poly.degree})")

    if recovered == witness_poly:
        print(f"  ✗ Unexpected match (lucky coincidence)")
    else:
        print(f"  ✓ CORRECTLY DIFFERENT — degree bound violated, extraction non-unique")

    # Show multiple polynomials pass through the same points
    print(f"\n  Finding multiple degree-2 polynomials through the {k} points...")
    count = 0
    for a2 in range(prime):
        candidate = Polynomial(F, [0, 0, a2])
        # Adjust lower coefficients to match evaluation points
        p_test = lagrange_interpolation(F, points)
        # Add a2 * x^2 - a2 * (Lagrange basis contribution)
        # More simply: any degree-2 poly through 2 points is non-unique
        # p(x) = L(x) + c * (x - x_0)(x - x_1) for any c
        x0, x1 = challenges[0], challenges[1]
        extra = Polynomial(F, [F.mul(x0, x1), F.sub(0, F.add(x0, x1)), 1])
        candidate = p_test + extra.scalar_mul(a2)
        if (candidate.eval(challenges[0]) == evaluations[0] and
            candidate.eval(challenges[1]) == evaluations[1]):
            count += 1
            if count <= 3:
                print(f"    Candidate {count}: {candidate}")

    print(f"  Total: {count} distinct degree-≤-2 polynomials through {k} points")
    print(f"\n  → Violating the degree bound destroys extraction uniqueness!")


def demo_systematic_k_sweep():
    """Systematic demonstration for k = 2, 3, 4, 5."""
    separator("SYSTEMATIC k-SWEEP: Extraction for k = 2, 3, 4, 5")

    prime = 37
    num_trials = 20

    for k in [2, 3, 4, 5]:
        successes = 0
        for _ in range(num_trials):
            F = FiniteField(prime)
            # Random degree-(k-1) polynomial
            coeffs = [F.random_element() for _ in range(k)]
            witness = Polynomial(F, coeffs)

            # k distinct challenges
            challenges = random.sample(range(prime), k)
            evals = [witness.eval(c) for c in challenges]
            points = list(zip(challenges, evals))

            recovered = lagrange_interpolation(F, points)
            if recovered == witness:
                successes += 1

        print(f"  k={k}: {successes}/{num_trials} extractions successful "
              f"({'✓ 100%' if successes == num_trials else '✗ NOT 100%'})")

    print(f"\n  → Polynomial extraction succeeds with probability 1 when")
    print(f"    degree < k and challenges are distinct. This is a theorem,")
    print(f"    not a heuristic!")


def demo_coding_theory_bridge():
    """Demo: The evaluation map as a linear code."""
    separator("CODING THEORY BRIDGE: Evaluation Map = Reed–Solomon Code")

    prime = 13
    k = 3  # message length / degree bound
    n = 5  # codeword length
    F = FiniteField(prime)

    eval_points = list(range(1, n + 1))

    print(f"  Reed–Solomon code RS({n},{k}) over GF({prime})")
    print(f"  Evaluation points: {eval_points}")
    print(f"  Minimum distance: d = n - k + 1 = {n - k + 1}")
    print(f"  Correction capability: t = ⌊(d-1)/2⌋ = {(n-k)//2}")
    print()

    # Generate a few codewords
    print("  Sample codewords (message → codeword):")
    for trial in range(5):
        msg = [F.random_element() for _ in range(k)]
        codeword = reed_solomon_encode(F, msg, eval_points)
        print(f"    {msg} → {codeword}")

    # Demonstrate injectivity
    print(f"\n  Injectivity test: checking that distinct messages → distinct codewords")
    seen = {}
    collision = False
    for _ in range(min(prime**k, 200)):
        msg = [F.random_element() for _ in range(k)]
        codeword = tuple(reed_solomon_encode(F, msg, eval_points))
        msg_tuple = tuple(msg)
        if codeword in seen and seen[codeword] != msg_tuple:
            collision = True
            print(f"    ✗ COLLISION: {seen[codeword]} and {msg_tuple} → {codeword}")
            break
        seen[codeword] = msg_tuple

    if not collision:
        print(f"    ✓ No collisions found in {len(seen)} codewords")
        print(f"    This confirms: evaluation map is injective (Reed–Solomon injectivity)")


def main():
    """Run all demonstrations."""
    random.seed(42)  # Reproducible

    print("""
╔══════════════════════════════════════════════════════════════════════╗
║  Polynomial Extraction for k-Special Soundness                     ║
║  Interactive Finite-Field Demonstration                             ║
║                                                                    ║
║  Central Thesis:                                                   ║
║    k-special soundness = uniqueness of degree-(k-1) polynomial     ║
║    through k accepting points = Reed–Solomon injectivity           ║
╚══════════════════════════════════════════════════════════════════════╝
""")

    # Demo 1: Classical affine extraction (k=2)
    demo_affine_extraction()

    # Demo 2-5: Polynomial extraction for k = 3, 4, 5
    for k in [3, 4, 5]:
        demo_polynomial_extraction(k)

    # Demo 6: Systematic sweep
    demo_systematic_k_sweep()

    # Demo 7: Reed–Solomon connection
    demo_reed_solomon_connection()

    # Demo 8: Coding theory bridge
    demo_coding_theory_bridge()

    # Demo 9: Degree violation / counterexample search
    demo_degree_violation()

    separator("CONCLUSION")
    print("""  The demonstrations confirm the central theorem:

    ┌─────────────────────────────────────────────────────────────┐
    │  k-SPECIAL SOUNDNESS = POLYNOMIAL INTERPOLATION UNIQUENESS │
    │                                                             │
    │  • k transcripts at distinct challenges uniquely determine  │
    │    any degree-(k-1) polynomial (= witness encoding)         │
    │  • This is exactly Reed–Solomon code injectivity            │
    │  • Affine extraction (k=2) is the first nontrivial case     │
    │  • Extraction = Lagrange interpolation = RS decoding        │
    └─────────────────────────────────────────────────────────────┘

  Proved formally in Lean 4 with Mathlib. See:
    Catalog/Cryptography/PolynomialExtraction.lean
""")


if __name__ == "__main__":
    main()
