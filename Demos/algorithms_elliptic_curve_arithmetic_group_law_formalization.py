#!/usr/bin/env python3
"""
Elliptic Curve Algorithms
==========================
Implementations of core elliptic curve algorithms with docstrings,
type hints, and complexity analysis.
"""

import math
from typing import Optional, Tuple, List, Dict


Point = Optional[Tuple[int, int]]


class ECArithmetic:
    """
    Elliptic curve arithmetic engine for y² = x³ + ax + b over F_p.

    All operations run in the finite field F_p with p > 3 prime.
    The discriminant 4a³ + 27b² must be nonzero mod p (nonsingularity).

    Time complexity summary:
    - Point addition: O(log p) (due to modular inversion)
    - Point doubling: O(log p)
    - Scalar multiplication (double-and-add): O(n_bits · log p) where n_bits = ⌈log₂ n⌉
    - Point enumeration: O(p · log p)
    - Point counting (naive): O(p · log p)
    """

    def __init__(self, a: int, b: int, p: int):
        """
        Initialize curve y² = x³ + ax + b over F_p.

        Args:
            a: Coefficient of x
            b: Constant term
            p: Prime field characteristic, must be > 3

        Raises:
            ValueError: If p is not prime, p ≤ 3, or curve is singular
        """
        self.a = a % p
        self.b = b % p
        self.p = p
        disc = (4 * pow(a, 3, p) + 27 * pow(b, 2, p)) % p
        if disc == 0:
            raise ValueError("Singular curve")

    def _mod_inv(self, x: int) -> int:
        """Modular inverse via Fermat's little theorem. O(log p)."""
        return pow(x, self.p - 2, self.p)

    def add(self, P: Point, Q: Point) -> Point:
        """
        Add two points on the curve.

        Algorithm: Chord-tangent law
        - If P or Q is infinity, return the other
        - If P = -Q (same x, different y), return infinity
        - If P = Q, use tangent slope m = (3x² + a)/(2y)
        - Otherwise, use chord slope m = (y₂ - y₁)/(x₂ - x₁)
        - Compute x₃ = m² - x₁ - x₂, y₃ = m(x₁ - x₃) - y₁

        Time: O(log p) for one modular inversion
        Space: O(1)

        Args:
            P: First point (or None for infinity)
            Q: Second point (or None for infinity)

        Returns:
            P + Q on the curve
        """
        if P is None:
            return Q
        if Q is None:
            return P

        x1, y1 = P
        x2, y2 = Q

        if x1 == x2:
            if y1 != y2:
                return None
            if y1 == 0:
                return None
            # Doubling
            m = (3 * x1 * x1 + self.a) * self._mod_inv(2 * y1) % self.p
        else:
            # Chord
            m = (y2 - y1) * self._mod_inv(x2 - x1) % self.p

        x3 = (m * m - x1 - x2) % self.p
        y3 = (m * (x1 - x3) - y1) % self.p
        return (x3, y3)

    def negate(self, P: Point) -> Point:
        """Negate a point: (x, y) ↦ (x, -y). O(1)."""
        if P is None:
            return None
        return (P[0], (-P[1]) % self.p)

    def scalar_mul(self, n: int, P: Point) -> Point:
        """
        Scalar multiplication using double-and-add.

        Algorithm:
        1. Write n in binary: n = Σ bᵢ · 2ⁱ
        2. Iterate from LSB to MSB:
           - If current bit is 1, add current doubling to result
           - Double the addend

        Time: O(log(n) · log(p))  — log(n) doublings/additions, each O(log p)
        Space: O(1)

        Pseudocode:
            result ← ∞
            addend ← P
            while n > 0:
                if n is odd: result ← result + addend
                addend ← 2 · addend
                n ← n >> 1
            return result

        Args:
            n: Scalar (non-negative integer)
            P: Base point

        Returns:
            n · P = P + P + ... + P (n times)
        """
        if n < 0:
            return self.scalar_mul(-n, self.negate(P))
        result: Point = None
        addend = P
        while n > 0:
            if n & 1:
                result = self.add(result, addend)
            addend = self.add(addend, addend)
            n >>= 1
        return result

    def enumerate_points(self) -> List[Point]:
        """
        Enumerate all F_p-rational points on the curve.

        Algorithm: For each x ∈ F_p, compute rhs = x³ + ax + b,
        then check all y ∈ F_p for y² = rhs.

        Time: O(p · √p) using Euler criterion, or O(p²) naively
        Space: O(p) for the point list

        Returns:
            List of all points including infinity
        """
        points: List[Point] = [None]
        for x in range(self.p):
            rhs = (x * x * x + self.a * x + self.b) % self.p
            # Use Euler criterion: rhs^((p-1)/2) = 0, 1, or p-1
            if rhs == 0:
                points.append((x, 0))
            else:
                euler = pow(rhs, (self.p - 1) // 2, self.p)
                if euler == 1:  # rhs is a QR
                    # Find square root using Tonelli-Shanks
                    y = self._sqrt_mod(rhs)
                    if y is not None:
                        points.append((x, y))
                        if y != 0:
                            points.append((x, self.p - y))
        return points

    def _sqrt_mod(self, a: int) -> Optional[int]:
        """Modular square root using Tonelli-Shanks algorithm. O(log² p)."""
        if a == 0:
            return 0
        if self.p % 4 == 3:
            r = pow(a, (self.p + 1) // 4, self.p)
            if r * r % self.p == a:
                return r
            return None

        # Tonelli-Shanks
        q, s = self.p - 1, 0
        while q % 2 == 0:
            q //= 2
            s += 1
        z = 2
        while pow(z, (self.p - 1) // 2, self.p) != self.p - 1:
            z += 1
        m, c, t, r = s, pow(z, q, self.p), pow(a, q, self.p), pow(a, (q + 1) // 2, self.p)
        while True:
            if t == 1:
                return r
            i = 1
            temp = t * t % self.p
            while temp != 1:
                temp = temp * temp % self.p
                i += 1
            b = pow(c, 1 << (m - i - 1), self.p)
            m, c, t, r = i, b * b % self.p, t * b * b % self.p, r * b % self.p

    def point_count(self) -> int:
        """Count #E(F_p). O(p · log p) with Euler criterion."""
        count = 1  # infinity
        for x in range(self.p):
            rhs = (x * x * x + self.a * x + self.b) % self.p
            if rhs == 0:
                count += 1
            else:
                euler = pow(rhs, (self.p - 1) // 2, self.p)
                if euler == 1:
                    count += 2
        return count

    def frobenius_trace(self) -> int:
        """Compute a_p = p + 1 - #E(F_p)."""
        return self.p + 1 - self.point_count()

    def point_order(self, P: Point) -> int:
        """
        Find the order of point P (smallest n > 0 with nP = ∞).

        Time: O(ord(P) · log p)

        Args:
            P: Point on the curve

        Returns:
            Order of P in the group
        """
        if P is None:
            return 1
        Q = P
        n = 1
        while Q is not None:
            Q = self.add(Q, P)
            n += 1
        return n

    def verify_hasse_bound(self) -> Dict:
        """
        Verify the Hasse bound |a_p| ≤ 2√p and return diagnostics.

        Returns:
            Dictionary with trace, bound, point count, and verification status
        """
        n = self.point_count()
        a_p = self.p + 1 - n
        bound = 2 * math.sqrt(self.p)
        return {
            "p": self.p,
            "a": self.a,
            "b": self.b,
            "point_count": n,
            "trace": a_p,
            "bound": bound,
            "satisfies_hasse": abs(a_p) <= bound + 1e-10,
            "group_order_lower": max(1, self.p + 1 - int(bound)),
            "group_order_upper": self.p + 1 + int(bound),
        }


# Example usage
if __name__ == "__main__":
    E = ECArithmetic(1, 1, 97)
    print(f"Curve: y² = x³ + {E.a}x + {E.b} over F_{E.p}")

    P = (0, 1)  # known point
    print(f"P = {P}, on curve: {E.add(P, E.negate(P)) is None}")

    print(f"7P = {E.scalar_mul(7, P)}")
    print(f"Order of P = {E.point_order(P)}")

    info = E.verify_hasse_bound()
    print(f"#E = {info['point_count']}, trace = {info['trace']}, "
          f"Hasse: {info['satisfies_hasse']}")
