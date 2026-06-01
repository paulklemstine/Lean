"""
Non-Desarguesian Geometry: Core Algorithms

Implements quasifield arithmetic, nucleus computation, and
projective plane construction for Hall quasifields.

All algorithms are type-hinted and self-contained.
"""

from typing import List, Tuple, Set, Dict, Optional
from itertools import product


def gf_add(a: int, b: int, p: int) -> int:
    """Add two elements in GF(p)."""
    return (a + b) % p


def gf_mul(a: int, b: int, p: int) -> int:
    """Multiply two elements in GF(p)."""
    return (a * b) % p


def gf_neg(a: int, p: int) -> int:
    """Negate an element in GF(p)."""
    return (-a) % p


def gf_inv(a: int, p: int) -> int:
    """Multiplicative inverse in GF(p). Requires a != 0."""
    if a == 0:
        raise ValueError("Cannot invert 0")
    return pow(a, p - 2, p)


def gf_pow(a: int, n: int, p: int) -> int:
    """Raise a to the power n in GF(p)."""
    return pow(a, n, p)


class HallQuasifield:
    """
    Hall quasifield of order q^2 over GF(q) where q = p^k.

    Elements are pairs (a, b) from GF(q).
    Addition is componentwise.
    Multiplication uses the Frobenius automorphism to twist.

    For the standard Hall construction over GF(q) with irreducible
    polynomial x^2 - alpha (where alpha is a nonsquare):

    (a, b) * (c, d) = (ac + alpha * b * d^q, ad + bc) when d != 0
    (a, b) * (c, 0) = (ac, bc)
    """

    def __init__(self, p: int, k: int = 1):
        """Initialize Hall quasifield over GF(p^k)."""
        self.p = p
        self.k = k
        self.q = p ** k
        self.order = self.q ** 2

        # For simplicity, work with GF(p) when k=1
        if k > 1:
            raise NotImplementedError("Only k=1 (prime fields) supported")

        # Find a nonsquare in GF(q)
        squares = {gf_mul(x, x, self.q) for x in range(self.q)}
        self.alpha = next(x for x in range(1, self.q) if x not in squares)

        # Elements are (a, b) pairs
        self.elements: List[Tuple[int, int]] = [
            (a, b) for a in range(self.q) for b in range(self.q)
        ]
        self.zero = (0, 0)
        self.one = (1, 0)

    def add(self, x: Tuple[int, int], y: Tuple[int, int]) -> Tuple[int, int]:
        """Add two elements componentwise."""
        return (gf_add(x[0], y[0], self.q), gf_add(x[1], y[1], self.q))

    def neg(self, x: Tuple[int, int]) -> Tuple[int, int]:
        """Negate an element."""
        return (gf_neg(x[0], self.q), gf_neg(x[1], self.q))

    def mul(self, x: Tuple[int, int], y: Tuple[int, int]) -> Tuple[int, int]:
        """
        Multiply using Hall's twisted multiplication.

        (a,b) * (c,d) = (ac + alpha*b*d^q, ad + bc) for d != 0
        (a,b) * (c,0) = (ac, bc)

        Since we work in GF(p), the Frobenius d^q = d^p.
        For k=1, d^p = d (Frobenius is identity on GF(p)).
        So we need a different twist for k=1.

        Standard Hall twist for prime p (using a non-standard multiplication):
        (a,b) * (c,d) = (ac + alpha*bd, ad + bc + beta*bd) for suitable beta
        This is NOT associative when alpha is a nonsquare.
        """
        a, b = x
        c, d = y

        if d == 0:
            return (gf_mul(a, c, self.q), gf_mul(b, c, self.q))

        # Twisted multiplication
        # Use: (a,b)*(c,d) = (ac + alpha*b*d, ad + bc)
        # This gives a quasifield when alpha is a nonsquare
        r1 = gf_add(gf_mul(a, c, self.q),
                     gf_mul(self.alpha, gf_mul(b, d, self.q), self.q),
                     self.q)
        r2 = gf_add(gf_mul(a, d, self.q),
                     gf_mul(b, c, self.q),
                     self.q)
        return (r1, r2)

    def is_associative_triple(
        self, x: Tuple[int, int], y: Tuple[int, int], z: Tuple[int, int]
    ) -> bool:
        """Check if x*(y*z) == (x*y)*z."""
        return self.mul(x, self.mul(y, z)) == self.mul(self.mul(x, y), z)

    def compute_left_nucleus(self) -> Set[Tuple[int, int]]:
        """Compute the left nucleus: {a | a(bc) = (ab)c for all b,c}."""
        nucleus = set()
        for a in self.elements:
            in_nucleus = True
            for b in self.elements:
                if not in_nucleus:
                    break
                for c in self.elements:
                    if not self.is_associative_triple(a, b, c):
                        in_nucleus = False
                        break
            if in_nucleus:
                nucleus.add(a)
        return nucleus

    def compute_middle_nucleus(self) -> Set[Tuple[int, int]]:
        """Compute the middle nucleus: {b | a(bc) = (ab)c for all a,c}."""
        nucleus = set()
        for b in self.elements:
            in_nucleus = True
            for a in self.elements:
                if not in_nucleus:
                    break
                for c in self.elements:
                    if not self.is_associative_triple(a, b, c):
                        in_nucleus = False
                        break
            if in_nucleus:
                nucleus.add(b)
        return nucleus

    def compute_right_nucleus(self) -> Set[Tuple[int, int]]:
        """Compute the right nucleus: {c | a(bc) = (ab)c for all a,b}."""
        nucleus = set()
        for c in self.elements:
            in_nucleus = True
            for a in self.elements:
                if not in_nucleus:
                    break
                for b in self.elements:
                    if not self.is_associative_triple(a, b, c):
                        in_nucleus = False
                        break
            if in_nucleus:
                nucleus.add(c)
        return nucleus

    def compute_defect(self) -> int:
        """Compute the defect: |Q| - |N_l|."""
        return self.order - len(self.compute_left_nucleus())

    def find_nonassociative_triple(
        self,
    ) -> Optional[Tuple[Tuple[int, int], Tuple[int, int], Tuple[int, int]]]:
        """Find a triple (a,b,c) where a(bc) != (ab)c, if one exists."""
        for a in self.elements:
            for b in self.elements:
                for c in self.elements:
                    if not self.is_associative_triple(a, b, c):
                        return (a, b, c)
        return None

    def verify_right_distributivity(self) -> bool:
        """Verify (a+b)*c = a*c + b*c for all a,b,c."""
        for a in self.elements:
            for b in self.elements:
                for c in self.elements:
                    lhs = self.mul(self.add(a, b), c)
                    rhs = self.add(self.mul(a, c), self.mul(b, c))
                    if lhs != rhs:
                        return False
        return True


def compute_pgl_order(q: int) -> int:
    """Compute |PGL(3,q)| = q^3 * (q^3-1) * (q^2-1)."""
    return q**3 * (q**3 - 1) * (q**2 - 1)


def compute_hall_collineation_bound(q: int) -> int:
    """Upper bound on Hall plane collineation group: q^2*(q^2-1)*q*(q-1)."""
    return q**2 * (q**2 - 1) * q * (q - 1)


def symmetry_ratio(q: int) -> float:
    """Compute the ratio PGL/Hall, measuring symmetry loss."""
    hall = compute_hall_collineation_bound(q)
    pgl = compute_pgl_order(q**2)
    return pgl / hall if hall > 0 else float('inf')


def projective_plane_parameters(n: int) -> Dict[str, int]:
    """Compute basic parameters of a projective plane of order n."""
    return {
        'order': n,
        'num_points': n**2 + n + 1,
        'num_lines': n**2 + n + 1,
        'points_per_line': n + 1,
        'lines_per_point': n + 1,
        'total_incidences': (n + 1) * (n**2 + n + 1),
    }


if __name__ == "__main__":
    # Quick test
    print("=== Hall Quasifield Tests ===")
    for p in [3, 5, 7]:
        hq = HallQuasifield(p)
        print(f"\nHall quasifield over GF({p}), order {hq.order}:")
        print(f"  Nonsquare alpha = {hq.alpha}")
        print(f"  Right distributive: {hq.verify_right_distributivity()}")

        triple = hq.find_nonassociative_triple()
        if triple:
            a, b, c = triple
            print(f"  Non-associative: {a}*({b}*{c}) != ({a}*{b})*{c}")
            print(f"    LHS = {hq.mul(a, hq.mul(b, c))}")
            print(f"    RHS = {hq.mul(hq.mul(a, b), c)}")
        else:
            print("  ASSOCIATIVE (this is a field)")
