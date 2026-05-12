#!/usr/bin/env python3
"""
Algorithms for Berggren–Lattice Reduction Duality

Implements the core algorithms from the research paper:
1. Triple-to-form attachment
2. Berggren tree generation and descent
3. Gauss reduction for binary quadratic forms
4. Reduction duality verification
5. Short-basis certificate construction
"""

import math
from typing import Tuple, List, Optional, Dict
from dataclasses import dataclass


# ─── Data Types ───────────────────────────────────────────────────────────────

@dataclass(frozen=True)
class PrimitiveTriple:
    """A primitive Pythagorean triple (a, b, c) with a² + b² = c²."""
    a: int
    b: int
    c: int

    def __post_init__(self):
        assert self.a > 0 and self.b > 0 and self.c > 0
        assert self.a**2 + self.b**2 == self.c**2
        assert math.gcd(self.a, self.b) == 1
        assert (self.a + self.b) % 2 == 1

    @property
    def is_berggren_reduced(self) -> bool:
        """Berggren-reducedness: a ≤ b."""
        return self.a <= self.b

    @property
    def height(self) -> int:
        """Berggren height = hypotenuse."""
        return self.c


@dataclass(frozen=True)
class BinaryQuadraticForm:
    """A positive-definite binary quadratic form Q(x,y) = Ax² + Bxy + Cy²."""
    A: int
    B: int
    C: int

    def __post_init__(self):
        assert self.A > 0
        assert 4 * self.A * self.C - self.B**2 > 0

    @property
    def discriminant(self) -> int:
        """Discriminant D = B² - 4AC."""
        return self.B**2 - 4 * self.A * self.C

    @property
    def pos_disc(self) -> int:
        """Positive-definiteness discriminant 4AC - B²."""
        return 4 * self.A * self.C - self.B**2

    @property
    def is_gauss_reduced(self) -> bool:
        """Check Gauss-reducedness: |B| ≤ A, A ≤ C, A=C → B ≥ 0."""
        return (abs(self.B) <= self.A and
                self.A <= self.C and
                (self.A != self.C or self.B >= 0))

    def evaluate(self, x: int, y: int) -> int:
        """Evaluate Q(x, y)."""
        return self.A * x**2 + self.B * x * y + self.C * y**2


@dataclass
class ShortBasisCertificate:
    """A short-basis certificate for a binary quadratic form."""
    form: BinaryQuadraticForm
    gauss_reduced: bool
    minkowski_bound_holds: bool
    basis_vector_1_norm_sq: int  # = A (first coefficient)
    basis_vector_2_norm_sq: int  # = C (second coefficient)


# ─── Berggren Generators ─────────────────────────────────────────────────────

def berggren_L(t: PrimitiveTriple) -> PrimitiveTriple:
    """Apply Berggren L generator."""
    a, b, c = t.a, t.b, t.c
    return PrimitiveTriple(a - 2*b + 2*c, 2*a - b + 2*c, 2*a - 2*b + 3*c)


def berggren_M(t: PrimitiveTriple) -> PrimitiveTriple:
    """Apply Berggren M generator."""
    a, b, c = t.a, t.b, t.c
    return PrimitiveTriple(a + 2*b + 2*c, 2*a + b + 2*c, 2*a + 2*b + 3*c)


def berggren_R(t: PrimitiveTriple) -> PrimitiveTriple:
    """Apply Berggren R generator."""
    a, b, c = t.a, t.b, t.c
    return PrimitiveTriple(-a + 2*b + 2*c, -2*a + b + 2*c, -2*a + 2*b + 3*c)


ROOT = PrimitiveTriple(3, 4, 5)


# ─── Algorithm 1: Triple-to-Form Attachment ───────────────────────────────────

def triple_to_form(t: PrimitiveTriple) -> BinaryQuadraticForm:
    """Canonical form attachment: (a, b, c) ↦ (c, b-a, c).

    Complexity: O(1) arithmetic operations.

    The form Q(x,y) = cx² + (b-a)xy + cy² is always positive definite
    with discriminant -(3c² + 2ab).
    """
    return BinaryQuadraticForm(A=t.c, B=t.b - t.a, C=t.c)


# ─── Algorithm 2: Berggren Tree Generation ────────────────────────────────────

def generate_berggren_tree(max_hypotenuse: int) -> List[PrimitiveTriple]:
    """Generate all primitive Pythagorean triples with c ≤ max_hypotenuse.

    Uses BFS traversal of the Berggren tree starting from (3, 4, 5).
    Each node has exactly 3 children, all with strictly larger hypotenuse.

    Complexity: O(N) where N is the number of triples with c ≤ max_hypotenuse.
    Space: O(N) for the output list.

    Returns: Sorted list of PrimitiveTriple objects.
    """
    result = []
    queue = [ROOT]

    while queue:
        t = queue.pop(0)
        if t.c > max_hypotenuse:
            continue
        result.append(t)
        for gen in [berggren_L, berggren_M, berggren_R]:
            try:
                child = gen(t)
                if child.c <= max_hypotenuse:
                    queue.append(child)
            except (AssertionError, ValueError):
                pass

    return sorted(result, key=lambda t: (t.c, t.a))


# ─── Algorithm 3: Berggren Descent ───────────────────────────────────────────

def berggren_parent(t: PrimitiveTriple) -> Optional[Tuple[str, PrimitiveTriple]]:
    """Find the Berggren parent of t.

    Returns (generator_name, parent) or None if t is the root.

    Complexity: O(1) arithmetic operations.
    """
    if t == ROOT:
        return None

    a, b, c = t.a, t.b, t.c
    c_parent = 3*c - 2*a - 2*b

    # Try each inverse transform
    candidates = [
        ('L', (a + 2*b - 2*c, -2*a - b + 2*c, c_parent)),
        ('M', (a + 2*b - 2*c, 2*a + b - 2*c, c_parent)),
        ('R', (-a - 2*b + 2*c, 2*a + b - 2*c, c_parent)),
    ]

    for name, (pa, pb, pc) in candidates:
        if pa > 0 and pb > 0 and pc > 0 and pa**2 + pb**2 == pc**2:
            try:
                parent = PrimitiveTriple(pa, pb, pc)
                return (name, parent)
            except AssertionError:
                continue

    return None


def berggren_descent_path(t: PrimitiveTriple) -> List[Tuple[str, PrimitiveTriple]]:
    """Compute the full descent path from t to the root (3, 4, 5).

    Complexity: O(c) steps worst case, O(log c) typical.

    Returns: List of (inverse_generator_name, ancestor) pairs.
    """
    path = []
    current = t
    while current != ROOT:
        result = berggren_parent(current)
        if result is None:
            break
        gen_name, parent = result
        path.append((gen_name, parent))
        current = parent
    return path


# ─── Algorithm 4: Gauss Reduction ────────────────────────────────────────────

def gauss_reduce(f: BinaryQuadraticForm) -> BinaryQuadraticForm:
    """Apply Gauss reduction to a positive-definite binary quadratic form.

    Repeatedly:
    1. Replace B by B mod 2A (centered, so |B'| ≤ A)
    2. If A > C, swap A and C (and negate B if needed)

    Complexity: O(log(max(A,C)/min(A,C))) steps.

    Returns: The unique Gauss-reduced form equivalent to f.
    """
    A, B, C = f.A, f.B, f.C

    while True:
        # Step 1: Reduce B modulo 2A
        if A > 0:
            # B' = B - 2A * round(B / (2A))
            q = round(B / (2 * A))
            B_new = B - 2 * A * q
            # Update C accordingly: C' = A*q² - B*q + C
            C = A * q * q - B * q + C
            B = B_new

        # Step 2: If A > C, swap
        if A > C:
            A, C = C, A
            B = -B
        elif A == C and B < 0:
            B = -B

        # Check if reduced
        if abs(B) <= A and A <= C and (A != C or B >= 0):
            break

    return BinaryQuadraticForm(A, B, C)


# ─── Algorithm 5: Reduction Duality Verification ─────────────────────────────

def verify_duality(t: PrimitiveTriple) -> Dict:
    """Verify the Berggren–Gauss reduction duality for a single triple.

    Returns a dictionary with verification results.
    """
    form = triple_to_form(t)
    br = t.is_berggren_reduced
    gr = form.is_gauss_reduced

    # Key inequality: |b - a| < c
    abs_diff = abs(t.b - t.a)
    key_ineq = abs_diff < t.c

    # Discriminant formula
    expected_disc = -(3 * t.c**2 + 2 * t.a * t.b)
    disc_correct = form.discriminant == expected_disc

    return {
        'triple': (t.a, t.b, t.c),
        'form': (form.A, form.B, form.C),
        'berggren_reduced': br,
        'gauss_reduced': gr,
        'duality_holds': br == gr,
        'key_inequality': key_ineq,
        'discriminant': form.discriminant,
        'expected_discriminant': expected_disc,
        'discriminant_correct': disc_correct,
    }


# ─── Algorithm 6: Short-Basis Certificate ────────────────────────────────────

def short_basis_certificate(t: PrimitiveTriple) -> Optional[ShortBasisCertificate]:
    """Construct a short-basis certificate for a Berggren-reduced triple.

    The certificate witnesses:
    1. The attached form is Gauss-reduced.
    2. The Minkowski bound 3A² ≤ 4(4AC - B²) holds.

    Returns None if the triple is not Berggren-reduced.
    """
    if not t.is_berggren_reduced:
        return None

    form = triple_to_form(t)
    minkowski = 3 * form.A**2 <= 4 * form.pos_disc

    return ShortBasisCertificate(
        form=form,
        gauss_reduced=form.is_gauss_reduced,
        minkowski_bound_holds=minkowski,
        basis_vector_1_norm_sq=form.A,
        basis_vector_2_norm_sq=form.C,
    )


# ─── Algorithm 7: Form Reconstruction ────────────────────────────────────────

def reconstruct_triple(form: BinaryQuadraticForm) -> Optional[PrimitiveTriple]:
    """Attempt to reconstruct a primitive triple from its attached form.

    For a form (A, B, C) in the Berggren image (where A = C),
    we have c = A, b - a = B, and a² + b² = c².

    Solving: let d = B, c = A.
    Then b = a + d, and a² + (a+d)² = c².
    So 2a² + 2ad + d² = c².
    a = (-d ± sqrt(2c² - d²)) / 2.

    Returns None if the form is not in the Berggren image.
    """
    if form.A != form.C:
        return None

    c = form.A
    d = form.B  # d = b - a

    # 2a² + 2ad + d² = c²
    # a = (-d + sqrt(2c² - d²)) / 2
    disc = 2 * c**2 - d**2
    if disc < 0:
        return None

    sqrt_disc = int(math.isqrt(disc))
    if sqrt_disc * sqrt_disc != disc:
        return None

    if (-d + sqrt_disc) % 2 != 0:
        return None

    a = (-d + sqrt_disc) // 2
    b = a + d

    if a <= 0 or b <= 0:
        return None

    try:
        return PrimitiveTriple(a, b, c)
    except AssertionError:
        return None


# ─── Main ─────────────────────────────────────────────────────────────────────

if __name__ == "__main__":
    print("Berggren–Lattice Reduction Duality: Algorithm Demonstrations")
    print("=" * 60)

    # Generate triples
    triples = generate_berggren_tree(500)
    print(f"\nGenerated {len(triples)} primitive triples with c ≤ 500")

    # Verify duality for all
    all_valid = True
    for t in triples:
        result = verify_duality(t)
        if not result['duality_holds']:
            print(f"  DUALITY FAILURE at {result['triple']}!")
            all_valid = False
    print(f"Duality verified for all {len(triples)} triples: {'✓' if all_valid else '✗'}")

    # Verify reconstruction for all
    all_reconstructed = True
    for t in triples:
        form = triple_to_form(t)
        recovered = reconstruct_triple(form)
        if recovered is None or (recovered.a, recovered.b, recovered.c) != (t.a, t.b, t.c):
            print(f"  RECONSTRUCTION FAILURE at ({t.a}, {t.b}, {t.c})!")
            all_reconstructed = False
    print(f"Reconstruction verified for all {len(triples)} triples: {'✓' if all_reconstructed else '✗'}")

    # Descent paths
    print("\nSample descent paths:")
    for t in triples[10:15]:
        path = berggren_descent_path(t)
        path_str = f"({t.a},{t.b},{t.c})"
        for name, ancestor in path:
            path_str += f" →{name} ({ancestor.a},{ancestor.b},{ancestor.c})"
        print(f"  {path_str}")

    # Short-basis certificates
    reduced_triples = [t for t in triples if t.is_berggren_reduced]
    certs_valid = all(
        short_basis_certificate(t) is not None and
        short_basis_certificate(t).minkowski_bound_holds
        for t in reduced_triples
    )
    print(f"\nShort-basis certificates valid for all {len(reduced_triples)} reduced triples: "
          f"{'✓' if certs_valid else '✗'}")
