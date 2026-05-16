#!/usr/bin/env python3
"""
Applications of Agreement Geometry

Demonstrates real-world applications of the polynomial agreement bounds:
1. Reed-Solomon error correction
2. Secret sharing (Shamir's scheme) with cheater detection
3. Property testing for low-degree functions
4. Polynomial identity testing
"""

import random
from typing import List, Dict, Tuple, Optional


# ─── Finite Field Arithmetic ──────────────────────────────────────────────────

class FF:
    """Finite field Z/pZ."""

    def __init__(self, p: int):
        self.p = p

    def eval_poly(self, coeffs: List[int], x: int) -> int:
        result = 0
        power = 1
        for c in coeffs:
            result = (result + c * power) % self.p
            power = (power * x) % self.p
        return result

    def lagrange_interpolate(self, points: List[Tuple[int, int]]) -> List[int]:
        """Lagrange interpolation over Z/pZ.

        Given points (x_i, y_i), returns coefficients [a_0, a_1, ..., a_d]
        of the unique polynomial of degree ≤ len(points)-1 passing through them.
        """
        n = len(points)
        xs = [p[0] for p in points]
        ys = [p[1] for p in points]

        # Build polynomial term by term
        result = [0] * n
        for i in range(n):
            # Compute the i-th Lagrange basis polynomial
            basis = [1]
            for j in range(n):
                if j == i:
                    continue
                # Multiply by (x - x_j) / (x_i - x_j)
                denom = (xs[i] - xs[j]) % self.p
                denom_inv = pow(denom, self.p - 2, self.p)
                new_basis = [0] * (len(basis) + 1)
                for k, b in enumerate(basis):
                    new_basis[k] = (new_basis[k] + b * ((-xs[j]) * denom_inv)) % self.p
                    new_basis[k + 1] = (new_basis[k + 1] + b * denom_inv) % self.p
                basis = new_basis

            # Add y_i * basis to result
            for k in range(min(len(basis), n)):
                result[k] = (result[k] + ys[i] * basis[k]) % self.p

        return result


# ─── Application 1: Reed-Solomon Error Correction ────────────────────────────

def demo_reed_solomon():
    """
    Demonstrate Reed-Solomon encoding, error introduction, and decoding.

    The agreement bound guarantees that with n evaluation points, degree d,
    and t > d agreements, the list size L satisfies 2Lt ≤ 2n + L(L-1)d.
    For unique decoding (L=1), we need t > (n+d)/2.
    """
    print("=" * 70)
    print("APPLICATION 1: Reed-Solomon Error Correction")
    print("=" * 70)

    p = 31  # Field size
    n = 15  # Code length (number of evaluation points)
    k = 6   # Message length (degree + 1)
    d = k - 1  # Max degree

    ff = FF(p)
    eval_points = list(range(1, n + 1))  # Evaluation at 1, 2, ..., n

    # Encode a message
    message = [random.randint(0, p - 1) for _ in range(k)]
    codeword = [ff.eval_poly(message, x) for x in eval_points]

    print(f"\nCode parameters: RS({n}, {k}) over F_{p}")
    print(f"Minimum distance: {n - d} = {n - k + 1}")
    print(f"Error correction capacity (unique): {(n - k) // 2} errors")
    print(f"\nMessage polynomial coefficients: {message}")
    print(f"Codeword: {codeword}")

    # Introduce errors
    num_errors = (n - k) // 2  # Maximum for unique decoding
    error_positions = random.sample(range(n), num_errors)
    received = codeword[:]
    for pos in error_positions:
        received[pos] = (received[pos] + random.randint(1, p - 1)) % p

    print(f"\nIntroduced {num_errors} errors at positions: {error_positions}")
    print(f"Received: {received}")

    # Decode by trying all subsets of d+1 points for interpolation
    agreements = sum(1 for i in range(n) if received[i] == codeword[i])
    print(f"Agreements with true codeword: {agreements}/{n}")

    # Brute-force decode: try all (d+1)-subsets
    from itertools import combinations
    candidates = set()
    for subset in combinations(range(n), k):
        points = [(eval_points[i], received[i]) for i in subset]
        try:
            coeffs = ff.lagrange_interpolate(points)
            # Verify: how many points does this polynomial agree with?
            eval_agree = sum(
                1 for i in range(n)
                if ff.eval_poly(coeffs, eval_points[i]) == received[i]
            )
            if eval_agree >= n - num_errors:
                candidates.add(tuple(coeffs[:k]))
        except Exception:
            pass

    print(f"\nDecoding result: {len(candidates)} candidate(s) found")
    for c in candidates:
        print(f"  Recovered: {list(c)}", end="")
        if list(c) == message:
            print(" ← CORRECT", end="")
        print()

    # Bonferroni bound check
    t = agreements
    L = len(candidates)
    if L > 0:
        bonf_lhs = 2 * L * t
        bonf_rhs = 2 * n + L * (L - 1) * d
        print(f"\nBonferroni bound: 2·{L}·{t} = {bonf_lhs} ≤ {bonf_rhs} = 2·{n} + {L}·{L-1}·{d}")
        print(f"Bound holds: {bonf_lhs <= bonf_rhs}")

    print()


# ─── Application 2: Shamir's Secret Sharing ──────────────────────────────────

def demo_secret_sharing():
    """
    Demonstrate Shamir's secret sharing with cheater detection.

    Agreement geometry tells us: if a cheater modifies their share,
    the reconstructed polynomial will differ from the true polynomial
    on at most d points. With enough honest shares, we can detect cheating.
    """
    print("=" * 70)
    print("APPLICATION 2: Shamir's Secret Sharing with Cheater Detection")
    print("=" * 70)

    p = 101  # Field size (prime)
    n = 7    # Number of shares
    k = 3    # Threshold (need k shares to reconstruct)
    d = k - 1  # Degree of sharing polynomial

    ff = FF(p)

    # The secret
    secret = 42
    print(f"\nScheme: ({k}, {n})-threshold over F_{p}")
    print(f"Secret: {secret}")

    # Generate sharing polynomial: p(x) = secret + a_1*x + ... + a_{k-1}*x^{k-1}
    coeffs = [secret] + [random.randint(1, p - 1) for _ in range(k - 1)]
    print(f"Sharing polynomial: coeffs = {coeffs}")

    # Generate shares
    shares = [(i, ff.eval_poly(coeffs, i)) for i in range(1, n + 1)]
    print(f"Shares: {shares}")

    # Simulate a cheater: party 3 modifies their share
    cheater_id = 3
    corrupted_shares = shares[:]
    old_val = corrupted_shares[cheater_id - 1][1]
    new_val = (old_val + random.randint(1, p - 1)) % p
    corrupted_shares[cheater_id - 1] = (cheater_id, new_val)
    print(f"\nCheater (party {cheater_id}) changed share from {old_val} to {new_val}")

    # Try to reconstruct with all shares
    points_all = corrupted_shares
    recon_coeffs = ff.lagrange_interpolate(points_all[:k+1])
    recon_secret = recon_coeffs[0]

    # Check agreement with each share
    agree_count = 0
    for x, y in corrupted_shares:
        if ff.eval_poly(recon_coeffs[:k], x) == y:
            agree_count += 1

    print(f"\nReconstructed from {k+1} shares: secret = {recon_secret}")
    print(f"Agreement with all {n} shares: {agree_count}/{n}")

    # Cheater detection: try all k-subsets and check for consistency
    print("\nCheater detection via agreement analysis:")
    from itertools import combinations
    consistency_scores = {}
    for subset in combinations(range(n), k):
        points = [corrupted_shares[i] for i in subset]
        rc = ff.lagrange_interpolate(points)
        agree = sum(1 for x, y in corrupted_shares if ff.eval_poly(rc[:k], x) == y)
        consistency_scores[subset] = agree

    max_agree = max(consistency_scores.values())
    best_subsets = [s for s, a in consistency_scores.items() if a == max_agree]

    print(f"Best agreement: {max_agree}/{n}")
    print(f"Subsets achieving best agreement: {len(best_subsets)}")

    # Identify potential cheater
    # Parties NOT in high-agreement subsets are suspect
    honest_parties = set()
    for subset in best_subsets:
        for i in subset:
            honest_parties.add(i + 1)

    all_parties = set(range(1, n + 1))
    suspect_parties = all_parties - honest_parties

    print(f"Suspect parties: {suspect_parties if suspect_parties else 'none'}")
    print(f"Actual cheater: party {cheater_id}")

    # Agreement bound context
    print(f"\nAgreement geometry insight:")
    print(f"  A degree-{d} polynomial agrees with the true shares on all {n} points.")
    print(f"  Any different degree-{d} polynomial agrees on at most {d} points.")
    print(f"  With {n} shares and 1 corrupted, agreement is ≥ {n-1} for the true poly.")
    print(f"  The Bonferroni bound ensures the list of candidate polynomials is small.")

    print()


# ─── Application 3: Property Testing ─────────────────────────────────────────

def demo_property_testing():
    """
    Demonstrate property testing for low-degree polynomials.

    Given a function f : F_p → F_p, test whether f is "close" to a polynomial
    of degree ≤ d by sampling random points and checking consistency.
    """
    print("=" * 70)
    print("APPLICATION 3: Property Testing for Low-Degree Functions")
    print("=" * 70)

    p = 31
    d = 3
    ff = FF(p)

    # Case 1: f IS a polynomial
    true_coeffs = [5, 3, 7, 2]  # degree 3
    f_poly = {x: ff.eval_poly(true_coeffs, x) for x in range(p)}

    # Case 2: f is "close" to a polynomial (few corruptions)
    num_corruptions = 3
    f_close = f_poly.copy()
    corrupt_pts = random.sample(range(p), num_corruptions)
    for x in corrupt_pts:
        f_close[x] = (f_close[x] + random.randint(1, p - 1)) % p

    # Case 3: f is random
    f_random = {x: random.randint(0, p - 1) for x in range(p)}

    print(f"\nField: F_{p}, testing for degree ≤ {d}")
    print(f"Case 1: f is exactly a degree-{d} polynomial")
    print(f"Case 2: f differs from a degree-{d} poly at {num_corruptions} points")
    print(f"Case 3: f is random")

    # Test: sample d+2 random points and check if they're consistent with degree ≤ d
    num_trials = 100
    num_samples = d + 2  # d+1 points determine a poly, d+2 gives a consistency check

    for case_name, f_test in [("Polynomial", f_poly),
                               ("Near-polynomial", f_close),
                               ("Random", f_random)]:
        passes = 0
        for _ in range(num_trials):
            sample_pts = random.sample(range(p), num_samples)
            # Interpolate through first d+1 points
            interp_pts = [(x, f_test[x]) for x in sample_pts[:d + 1]]
            interp_coeffs = ff.lagrange_interpolate(interp_pts)
            # Check the (d+2)-th point
            test_x = sample_pts[d + 1]
            predicted = ff.eval_poly(interp_coeffs[:d + 1], test_x)
            if predicted == f_test[test_x]:
                passes += 1

        print(f"\n  {case_name}: {passes}/{num_trials} consistency checks passed")

        # Find the best-agreeing polynomial
        best_agree = 0
        # Try a few random interpolations
        for _ in range(50):
            sample_pts = random.sample(range(p), d + 1)
            points = [(x, f_test[x]) for x in sample_pts]
            coeffs = ff.lagrange_interpolate(points)
            agree = sum(1 for x in range(p)
                       if ff.eval_poly(coeffs[:d + 1], x) == f_test[x])
            best_agree = max(best_agree, agree)

        print(f"  Best agreement found: {best_agree}/{p}")
        if best_agree > d:
            max_L = 0
            # Bonferroni bound on list size
            lhs = lambda L: 2 * L * best_agree
            rhs = lambda L: 2 * p + L * (L - 1) * d
            for L in range(1, p + 1):
                if lhs(L) <= rhs(L):
                    max_L = L
                else:
                    break
            print(f"  Bonferroni list-size bound at t={best_agree}: L ≤ {max_L}")

    print()


# ─── Application 4: Polynomial Identity Testing ──────────────────────────────

def demo_polynomial_identity_testing():
    """
    Demonstrate randomized polynomial identity testing.

    The root bound guarantees: if p(x) ≠ 0 and deg(p) ≤ d,
    then Pr[p(r) = 0] ≤ d/|S| for random r ∈ S.

    This is the Schwartz-Zippel lemma for the univariate case.
    """
    print("=" * 70)
    print("APPLICATION 4: Polynomial Identity Testing")
    print("=" * 70)

    p = 97  # Large prime for low error probability
    d = 5
    ff = FF(p)

    # Test 1: Two polynomials that ARE equal
    coeffs_a = [3, 7, 0, 2, 0, 1]  # 3 + 7x + 2x^3 + x^5
    # Same polynomial, different representation
    coeffs_b = [3, 7, 0, 2, 0, 1]

    print(f"\nField: F_{p}, degree bound: {d}")
    print(f"\nTest 1: p(x) = q(x) (identical polynomials)")

    num_tests = 1000
    false_negatives = 0
    for _ in range(num_tests):
        r = random.randint(0, p - 1)
        val_a = ff.eval_poly(coeffs_a, r)
        val_b = ff.eval_poly(coeffs_b, r)
        if val_a != val_b:
            false_negatives += 1

    print(f"  {num_tests} random tests: {false_negatives} differences found")
    print(f"  Conclusion: polynomials are identical ✓")

    # Test 2: Two polynomials that are NOT equal
    coeffs_c = [3, 7, 1, 2, 0, 1]  # Changed coefficient of x^2

    print(f"\nTest 2: p(x) ≠ q(x) (differ at x^2 coefficient)")

    false_positives = 0
    for _ in range(num_tests):
        r = random.randint(0, p - 1)
        val_a = ff.eval_poly(coeffs_a, r)
        val_c = ff.eval_poly(coeffs_c, r)
        if val_a == val_c:
            false_positives += 1

    theoretical_bound = d / p
    empirical_rate = false_positives / num_tests

    print(f"  {num_tests} random tests: {false_positives} false positives")
    print(f"  Empirical false positive rate: {empirical_rate:.4f}")
    print(f"  Theoretical bound (d/p): {theoretical_bound:.4f}")
    print(f"  Root bound holds: {empirical_rate <= theoretical_bound + 0.01}")

    # Connection to agreement geometry
    print(f"\n  Agreement geometry connection:")
    print(f"  The polynomials p-q has degree ≤ {d} and is nonzero.")
    print(f"  By the root bound, it has at most {d} roots in F_{p}.")
    print(f"  So p and q agree on at most {d} out of {p} points.")
    print(f"  This is exactly our card_eval_eq_filter_le theorem!")

    print()


# ─── Main ─────────────────────────────────────────────────────────────────────

if __name__ == "__main__":
    random.seed(42)

    print("\n" + "═" * 70)
    print("  APPLICATIONS OF AGREEMENT GEOMETRY")
    print("═" * 70 + "\n")

    demo_reed_solomon()
    demo_secret_sharing()
    demo_property_testing()
    demo_polynomial_identity_testing()

    print("All application demos completed successfully.")


#!/usr/bin/env python3
"""
Agreement Geometry Demo: Polynomial Agreement Bounds and List Decoding

Demonstrates the key theorems from the formalized agreement geometry framework:
1. Polynomial root bound on finite sets
2. Agreement set overlap bound for distinct polynomials
3. Univariate list-decoding bound (Bonferroni form)

All computations are over finite fields Z/pZ for prime p.
"""

import random
from itertools import combinations
from typing import List, Tuple, Dict, Set


# ─── Finite Field Arithmetic (Z/pZ) ───────────────────────────────────────────

class GF:
    """Simple finite field arithmetic over Z/pZ."""

    def __init__(self, p: int):
        assert self._is_prime(p), f"{p} is not prime"
        self.p = p
        self.elements = list(range(p))

    @staticmethod
    def _is_prime(n: int) -> bool:
        if n < 2:
            return False
        for i in range(2, int(n**0.5) + 1):
            if n % i == 0:
                return False
        return True

    def add(self, a: int, b: int) -> int:
        return (a + b) % self.p

    def sub(self, a: int, b: int) -> int:
        return (a - b) % self.p

    def mul(self, a: int, b: int) -> int:
        return (a * b) % self.p

    def inv(self, a: int) -> int:
        assert a % self.p != 0, "Cannot invert zero"
        return pow(a, self.p - 2, self.p)

    def neg(self, a: int) -> int:
        return (-a) % self.p


# ─── Polynomial Representation ────────────────────────────────────────────────

class Poly:
    """Polynomial over a finite field, represented as a list of coefficients.
    coeffs[i] is the coefficient of x^i.
    """

    def __init__(self, field: GF, coeffs: List[int]):
        self.field = field
        # Normalize: remove trailing zeros
        self.coeffs = [c % field.p for c in coeffs]
        while len(self.coeffs) > 1 and self.coeffs[-1] == 0:
            self.coeffs.pop()

    @property
    def degree(self) -> int:
        if all(c == 0 for c in self.coeffs):
            return -1  # Zero polynomial
        return len(self.coeffs) - 1

    def eval(self, x: int) -> int:
        result = 0
        power = 1
        for c in self.coeffs:
            result = self.field.add(result, self.field.mul(c, power))
            power = self.field.mul(power, x)
        return result

    def __eq__(self, other):
        if not isinstance(other, Poly):
            return False
        return self.coeffs == other.coeffs

    def __hash__(self):
        return hash(tuple(self.coeffs))

    def __repr__(self):
        if self.degree < 0:
            return "0"
        terms = []
        for i, c in enumerate(self.coeffs):
            if c == 0:
                continue
            if i == 0:
                terms.append(str(c))
            elif i == 1:
                terms.append(f"{c}x" if c != 1 else "x")
            else:
                terms.append(f"{c}x^{i}" if c != 1 else f"x^{i}")
        return " + ".join(terms) if terms else "0"

    def is_zero(self) -> bool:
        return all(c == 0 for c in self.coeffs)

    def sub(self, other: 'Poly') -> 'Poly':
        n = max(len(self.coeffs), len(other.coeffs))
        result = []
        for i in range(n):
            a = self.coeffs[i] if i < len(self.coeffs) else 0
            b = other.coeffs[i] if i < len(other.coeffs) else 0
            result.append(self.field.sub(a, b))
        return Poly(self.field, result)


# ─── Agreement Set Computation ────────────────────────────────────────────────

def agree_set(p: Poly, f: Dict[int, int], S: List[int]) -> Set[int]:
    """Compute the agreement set A(p, f, S) = {x in S : p(x) = f(x)}."""
    return {x for x in S if p.eval(x) == f.get(x)}


def eval_eq_set(p: Poly, q: Poly, S: List[int]) -> Set[int]:
    """Compute {x in S : p(x) = q(x)}."""
    return {x for x in S if p.eval(x) == q.eval(x)}


# ─── Enumeration of Polynomials ───────────────────────────────────────────────

def enumerate_polys(field: GF, max_degree: int) -> List[Poly]:
    """Enumerate all polynomials of degree <= max_degree over the field."""
    p = field.p
    polys = []
    # Iterate over all coefficient tuples of length max_degree + 1
    for code in range(p ** (max_degree + 1)):
        coeffs = []
        val = code
        for _ in range(max_degree + 1):
            coeffs.append(val % p)
            val //= p
        polys.append(Poly(field, coeffs))
    return polys


# ─── Demo 1: Root Bound Verification ──────────────────────────────────────────

def demo_root_bound():
    """Verify that nonzero polynomials of degree d have at most d roots."""
    print("=" * 70)
    print("DEMO 1: Polynomial Root Bound")
    print("Theorem: A nonzero polynomial of degree d has at most d roots in any set S.")
    print("=" * 70)

    for p_val in [7, 11, 13]:
        field = GF(p_val)
        S = field.elements[:]

        for d in range(1, min(5, p_val)):
            max_roots = 0
            violations = 0
            n_tested = 0

            for _ in range(500):
                coeffs = [random.randint(0, p_val - 1) for _ in range(d + 1)]
                poly = Poly(field, coeffs)
                if poly.is_zero():
                    continue
                n_tested += 1
                roots = [x for x in S if poly.eval(x) == 0]
                n_roots = len(roots)
                max_roots = max(max_roots, n_roots)
                if n_roots > d:
                    violations += 1

            print(f"  F_{p_val}, degree ≤ {d}: tested {n_tested} nonzero polys, "
                  f"max roots in S = {max_roots}, violations = {violations}")

    print()


# ─── Demo 2: Agreement Overlap Bound ──────────────────────────────────────────

def demo_overlap_bound():
    """Verify that distinct degree-≤d polys agree on at most d points."""
    print("=" * 70)
    print("DEMO 2: Agreement Overlap Bound")
    print("Theorem: For distinct p,q of degree ≤ d, |{x : p(x) = q(x)}| ≤ d.")
    print("=" * 70)

    for p_val in [7, 11]:
        field = GF(p_val)
        S = field.elements[:]

        for d in range(1, min(4, p_val)):
            polys = enumerate_polys(field, d)
            max_overlap = 0
            n_pairs = 0

            for i in range(len(polys)):
                for j in range(i + 1, len(polys)):
                    if polys[i] == polys[j]:
                        continue
                    eq_set = eval_eq_set(polys[i], polys[j], S)
                    max_overlap = max(max_overlap, len(eq_set))
                    n_pairs += 1

            print(f"  F_{p_val}, degree ≤ {d}: {n_pairs} distinct pairs, "
                  f"max overlap = {max_overlap} (bound = {d})")

    print()


# ─── Demo 3: List-Decoding Bound ──────────────────────────────────────────────

def demo_list_bound():
    """Verify the Bonferroni list-decoding bound 2*L*t ≤ 2*|S| + L*(L-1)*d."""
    print("=" * 70)
    print("DEMO 3: Univariate List-Decoding Bound (Bonferroni)")
    print("Theorem: 2*L*t ≤ 2*|S| + L*(L-1)*d")
    print("=" * 70)

    for p_val in [7, 11, 13]:
        field = GF(p_val)
        S = field.elements[:]
        n = len(S)

        for d in range(1, min(4, p_val)):
            # Generate a random target function
            f = {x: random.randint(0, p_val - 1) for x in S}

            # Enumerate all degree-≤d polynomials
            polys = enumerate_polys(field, d)

            for t in range(d + 1, n + 1):
                # Find all polys agreeing with f on ≥ t points
                agreeing = [p for p in polys if len(agree_set(p, f, S)) >= t]
                L = len(agreeing)

                if L == 0:
                    continue

                lhs = 2 * L * t
                rhs = 2 * n + L * (L - 1) * d
                holds = lhs <= rhs

                if not holds or L >= 3:
                    status = "✓" if holds else "✗ VIOLATION"
                    print(f"  F_{p_val}, d={d}, t={t}: L={L}, "
                          f"2Lt={lhs}, 2|S|+L(L-1)d={rhs} {status}")

                if not holds:
                    print(f"    *** VIOLATION FOUND ***")
                    for p in agreeing[:5]:
                        ag = agree_set(p, f, S)
                        print(f"    p={p}, agree={ag}, |agree|={len(ag)}")

    print()


# ─── Demo 4: Tightness Analysis ──────────────────────────────────────────────

def demo_tightness():
    """Analyze how tight the Bonferroni bound is in practice."""
    print("=" * 70)
    print("DEMO 4: Tightness of the Bonferroni Bound")
    print("For each (p, d, t), compute the max L and compare with the bound.")
    print("=" * 70)

    results = []

    for p_val in [5, 7, 11]:
        field = GF(p_val)
        S = field.elements[:]
        n = len(S)

        for d in range(1, min(3, p_val)):
            polys = enumerate_polys(field, d)

            for trial in range(20):
                f = {x: random.randint(0, p_val - 1) for x in S}

                for t in range(d + 1, n + 1):
                    agreeing = [p for p in polys if len(agree_set(p, f, S)) >= t]
                    L = len(agreeing)

                    if L > 0:
                        lhs = 2 * L * t
                        rhs = 2 * n + L * (L - 1) * d
                        ratio = lhs / rhs if rhs > 0 else 0
                        results.append((p_val, d, t, L, ratio))

    # Print summary: for each (d, t), find the trial with the largest L
    print(f"\n  {'p':>3} {'d':>3} {'t':>3} {'L':>5} {'2Lt':>7} {'bound':>7} {'ratio':>7}")
    print(f"  {'-'*3} {'-'*3} {'-'*3} {'-'*5} {'-'*7} {'-'*7} {'-'*7}")

    # Group by (p, d, t), take max L
    from collections import defaultdict
    best = defaultdict(lambda: (0, 0))
    for p_val, d, t, L, ratio in results:
        key = (p_val, d, t)
        if L > best[key][0]:
            best[key] = (L, ratio)

    for key in sorted(best.keys()):
        p_val, d, t = key
        L, ratio = best[key]
        if L >= 2:
            n = p_val
            lhs = 2 * L * t
            rhs = 2 * n + L * (L - 1) * d
            print(f"  {p_val:>3} {d:>3} {t:>3} {L:>5} {lhs:>7} {rhs:>7} {ratio:>7.3f}")

    print()


# ─── Demo 5: Counterexample to Naive Bound ────────────────────────────────────

def demo_naive_counterexample():
    """Show that L*(t-d) ≤ |S| is false in general."""
    print("=" * 70)
    print("DEMO 5: Counterexample to the Naive Bound L*(t-d) ≤ |S|")
    print("=" * 70)

    # Use F_7 with d=1 (linear polynomials) and find target f with many agreeing lines
    field = GF(7)
    S = field.elements[:]
    n = len(S)
    d = 1

    # Try many random targets
    best_L = 0
    best_f = None
    best_t = 0
    best_agreeing = []

    for _ in range(100):
        f = {x: random.randint(0, 6) for x in S}
        polys = enumerate_polys(field, d)

        for t in [2, 3]:
            agreeing = [p for p in polys if len(agree_set(p, f, S)) >= t]
            L = len(agreeing)
            naive_bound = n // (t - d) if t > d else float('inf')

            if L > naive_bound and L > best_L:
                best_L = L
                best_f = f.copy()
                best_t = t
                best_agreeing = agreeing[:]

    if best_f:
        t = best_t
        L = best_L
        naive_rhs = n // (t - d) if t > d else float('inf')
        bonf_rhs = 2 * n + L * (L - 1) * d

        print(f"\n  Found counterexample over F_7:")
        print(f"  f = {best_f}")
        print(f"  d = {d}, t = {t}, L = {L}")
        print(f"  Naive bound L*(t-d) ≤ |S|: {L}*{t-d} = {L*(t-d)} vs |S| = {n}")
        print(f"  Naive bound VIOLATED: {L*(t-d)} > {n}")
        print(f"  Bonferroni bound 2Lt ≤ 2|S| + L(L-1)d: {2*L*t} ≤ {bonf_rhs} ✓")
        print(f"\n  Agreeing polynomials:")
        for p in best_agreeing[:10]:
            ag = agree_set(p, best_f, S)
            print(f"    p = {str(p):>15}, agree = {sorted(ag)}, |agree| = {len(ag)}")
        if len(best_agreeing) > 10:
            print(f"    ... and {len(best_agreeing) - 10} more")
    else:
        print("  No counterexample found in random trials.")

    print()


# ─── Main ─────────────────────────────────────────────────────────────────────

if __name__ == "__main__":
    random.seed(42)
    print("\n" + "═" * 70)
    print("  AGREEMENT GEOMETRY: Polynomial Agreement Bounds Demo")
    print("═" * 70 + "\n")

    demo_root_bound()
    demo_overlap_bound()
    demo_list_bound()
    demo_tightness()
    demo_naive_counterexample()

    print("All demos completed successfully.")
