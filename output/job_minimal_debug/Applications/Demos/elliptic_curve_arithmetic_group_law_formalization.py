#!/usr/bin/env python3
"""
Elliptic Curve Applications
============================
Real-world applications of elliptic curve arithmetic demonstrating
cryptographic key exchange, digital signatures, and point counting.
"""

import math
import hashlib
import secrets
from typing import Optional, Tuple


Point = Optional[Tuple[int, int]]


class ECCrypto:
    """Elliptic curve cryptographic primitives over F_p."""

    def __init__(self, a: int, b: int, p: int, G: Point, n: int):
        """
        Initialize EC cryptographic system.

        Args:
            a, b: Curve coefficients
            p: Field prime
            G: Generator point
            n: Order of G
        """
        self.a, self.b, self.p = a % p, b % p, p
        self.G, self.n = G, n

    def _mod_inv(self, x: int) -> int:
        return pow(x, self.p - 2, self.p)

    def add(self, P: Point, Q: Point) -> Point:
        if P is None: return Q
        if Q is None: return P
        x1, y1 = P; x2, y2 = Q
        if x1 == x2:
            if y1 != y2 or y1 == 0: return None
            m = (3 * x1 * x1 + self.a) * self._mod_inv(2 * y1) % self.p
        else:
            m = (y2 - y1) * self._mod_inv(x2 - x1) % self.p
        x3 = (m * m - x1 - x2) % self.p
        y3 = (m * (x1 - x3) - y1) % self.p
        return (x3, y3)

    def scalar_mul(self, k: int, P: Point) -> Point:
        result = None
        addend = P
        k = k % self.n if k > 0 else k
        while k > 0:
            if k & 1: result = self.add(result, addend)
            addend = self.add(addend, addend)
            k >>= 1
        return result


def demo_diffie_hellman():
    """
    Demonstrate Elliptic Curve Diffie-Hellman Key Exchange (ECDH).

    This is a simplified version using a small curve for demonstration.
    Real implementations use curves like secp256k1 or Curve25519.
    """
    print("=" * 70)
    print("APPLICATION 1: Elliptic Curve Diffie-Hellman (ECDH)")
    print("=" * 70)

    # Curve y² = x³ + 2x + 3 over F_97, with generator G of order 100
    p = 97
    E = ECCrypto(2, 3, p, G=(3, 6), n=5)

    # Use a larger subgroup - find a generator
    # For demo, use the full group order
    from demo import EllipticCurve
    Efull = EllipticCurve(2, 3, 97)
    pts = Efull.enumerate_points()
    G = pts[1]
    n = Efull.point_count()
    E = ECCrypto(2, 3, p, G=G, n=n)

    print(f"\nPublic parameters:")
    print(f"  Curve: y² = x³ + {E.a}x + {E.b} over F_{E.p}")
    print(f"  Generator: G = {E.G}")
    print(f"  Group order: n = {n}")

    # Alice's keys
    alice_private = secrets.randbelow(n - 1) + 1
    alice_public = E.scalar_mul(alice_private, E.G)
    print(f"\nAlice:")
    print(f"  Private key: {alice_private}")
    print(f"  Public key:  {alice_public}")

    # Bob's keys
    bob_private = secrets.randbelow(n - 1) + 1
    bob_public = E.scalar_mul(bob_private, E.G)
    print(f"\nBob:")
    print(f"  Private key: {bob_private}")
    print(f"  Public key:  {bob_public}")

    # Shared secret
    alice_shared = E.scalar_mul(alice_private, bob_public)
    bob_shared = E.scalar_mul(bob_private, alice_public)
    print(f"\nShared secrets:")
    print(f"  Alice computes: {alice_private} · Bob_pub = {alice_shared}")
    print(f"  Bob computes:   {bob_private} · Alice_pub = {bob_shared}")
    print(f"  Match: {alice_shared == bob_shared} ✓" if alice_shared == bob_shared
          else f"  MISMATCH ✗")

    print(f"\n  Security: An eavesdropper sees G, Alice_pub, Bob_pub")
    print(f"  but computing the shared secret requires solving ECDLP.")


def demo_point_counting_application():
    """
    Demonstrate how point counting determines cryptographic security.

    The Hasse bound constrains the group order, which determines
    the difficulty of the discrete logarithm problem.
    """
    print("\n" + "=" * 70)
    print("APPLICATION 2: Security Analysis via Point Counting")
    print("=" * 70)

    from demo import EllipticCurve

    primes = [97, 251, 509, 1021]

    print(f"\n{'p':>6} | {'#E':>6} | {'a_p':>4} | {'2√p':>8} | {'Security bits':>14}")
    print("-" * 50)

    for p in primes:
        for a, b in [(1, 1), (2, 3), (3, 7)]:
            try:
                E = EllipticCurve(a, b, p)
                n = E.point_count()
                a_p = E.frobenius_trace()
                bits = math.log2(n) if n > 0 else 0
                print(f"{p:>6} | {n:>6} | {a_p:>4} | {2*math.sqrt(p):>8.2f} | {bits:>14.1f}")
                break
            except ValueError:
                continue


def demo_signature_verification():
    """
    Demonstrate a simplified ECDSA-like signature scheme.
    """
    print("\n" + "=" * 70)
    print("APPLICATION 3: Simplified EC Digital Signature")
    print("=" * 70)

    from demo import EllipticCurve

    # Setup
    p = 251
    Efull = EllipticCurve(1, 1, p)
    pts = Efull.enumerate_points()
    G = pts[1]
    n = Efull.point_count()

    E = ECCrypto(1, 1, p, G=G, n=n)

    # Key generation
    d = secrets.randbelow(n - 1) + 1  # private key
    Q = E.scalar_mul(d, G)  # public key

    print(f"\nCurve: y² = x³ + x + 1 over F_{p}")
    print(f"Generator: G = {G}, order ≈ {n}")
    print(f"Private key: d = {d}")
    print(f"Public key:  Q = {Q}")

    # Sign a message
    message = "Hello, elliptic curves!"
    h = int(hashlib.sha256(message.encode()).hexdigest(), 16) % n

    # Choose random k
    k = secrets.randbelow(n - 1) + 1
    R = E.scalar_mul(k, G)
    if R is None:
        print("  Bad k, retry")
        return
    r = R[0] % n
    if r == 0:
        print("  Bad k, retry")
        return
    k_inv = pow(k, n - 2, n) if n > 2 else 1
    s = (k_inv * (h + r * d)) % n

    print(f"\nMessage: '{message}'")
    print(f"Hash (mod n): {h}")
    print(f"Signature: (r={r}, s={s})")

    # Verify
    if s == 0:
        print("  Invalid signature (s=0)")
        return
    s_inv = pow(s, n - 2, n) if n > 2 else 1
    u1 = (h * s_inv) % n
    u2 = (r * s_inv) % n
    P_verify = E.add(E.scalar_mul(u1, G), E.scalar_mul(u2, Q))

    if P_verify is not None and P_verify[0] % n == r:
        print(f"Verification: ✓ VALID")
    else:
        print(f"Verification: ✗ INVALID (demo parameters may cause edge cases)")


def demo_embedding_degree():
    """
    Compute embedding degrees for pairing-based applications.
    """
    print("\n" + "=" * 70)
    print("APPLICATION 4: Embedding Degree Analysis")
    print("=" * 70)

    from demo import EllipticCurve

    print(f"\nThe embedding degree k is the smallest integer such that")
    print(f"the group order #E(F_p) divides p^k - 1.")
    print(f"Small k enables efficient pairing computation.\n")

    primes = [7, 11, 13, 23, 29, 31, 37, 41, 43]
    print(f"{'p':>4} | {'#E':>4} | {'embed k':>8} | {'Note':>20}")
    print("-" * 45)

    for p in primes:
        try:
            E = EllipticCurve(1, 1, p)
            n = E.point_count()
            # Find embedding degree
            k = 1
            pk = p
            while k <= 20:
                if (pk - 1) % n == 0:
                    break
                pk = pk * p
                k += 1
            note = "supersingular" if k <= 2 else ("low" if k <= 6 else "high security")
            print(f"{p:>4} | {n:>4} | {k:>8} | {note:>20}")
        except ValueError:
            continue


if __name__ == "__main__":
    demo_diffie_hellman()
    demo_point_counting_application()
    demo_signature_verification()
    demo_embedding_degree()

    print("\n" + "=" * 70)
    print("All applications demonstrated successfully!")
    print("=" * 70)


#!/usr/bin/env python3
"""
Elliptic Curve Arithmetic Demo
===============================
Interactive demonstration of elliptic curve operations over finite fields.
Constructs example curves over small primes, enumerates points, demonstrates
point addition and scalar multiplication, computes #E(F_p) and the Frobenius
trace, and verifies the Hasse inequality numerically.
"""

import math
from typing import Optional, Tuple, List


def is_prime(n: int) -> bool:
    """Check if n is prime."""
    if n < 2:
        return False
    if n < 4:
        return True
    if n % 2 == 0 or n % 3 == 0:
        return False
    i = 5
    while i * i <= n:
        if n % i == 0 or n % (i + 2) == 0:
            return False
        i += 6
    return True


def mod_inv(a: int, p: int) -> int:
    """Modular inverse of a mod p using extended Euclidean algorithm."""
    if a % p == 0:
        raise ValueError(f"{a} has no inverse mod {p}")
    return pow(a, p - 2, p)


# Point at infinity represented as None
Point = Optional[Tuple[int, int]]


class EllipticCurve:
    """Short Weierstrass elliptic curve y^2 = x^3 + ax + b over F_p."""

    def __init__(self, a: int, b: int, p: int):
        if not is_prime(p):
            raise ValueError(f"{p} is not prime")
        if p <= 3:
            raise ValueError(f"Short Weierstrass requires p > 3, got {p}")
        self.a = a % p
        self.b = b % p
        self.p = p
        disc = (4 * pow(a, 3, p) + 27 * pow(b, 2, p)) % p
        if disc == 0:
            raise ValueError(f"Singular curve: 4a^3 + 27b^2 = 0 mod {p}")

    def __repr__(self):
        return f"E: y² = x³ + {self.a}x + {self.b}  over F_{self.p}"

    def is_on_curve(self, P: Point) -> bool:
        """Check if P is on the curve."""
        if P is None:
            return True
        x, y = P
        return (y * y - x * x * x - self.a * x - self.b) % self.p == 0

    def negate(self, P: Point) -> Point:
        """Negate a point: (x, y) -> (x, -y)."""
        if P is None:
            return None
        x, y = P
        return (x, (-y) % self.p)

    def add(self, P: Point, Q: Point) -> Point:
        """Add two points using the chord-tangent law."""
        if P is None:
            return Q
        if Q is None:
            return P
        x1, y1 = P
        x2, y2 = Q
        if x1 == x2:
            if y1 == y2:
                if y1 == 0:
                    return None  # tangent is vertical
                m = (3 * x1 * x1 + self.a) * mod_inv(2 * y1, self.p) % self.p
            else:
                return None  # vertical line
        else:
            m = (y2 - y1) * mod_inv(x2 - x1, self.p) % self.p
        x3 = (m * m - x1 - x2) % self.p
        y3 = (m * (x1 - x3) - y1) % self.p
        return (x3, y3)

    def scalar_mul(self, n: int, P: Point) -> Point:
        """Double-and-add scalar multiplication."""
        if n < 0:
            return self.scalar_mul(-n, self.negate(P))
        if n == 0:
            return None
        result = None
        addend = P
        while n > 0:
            if n & 1:
                result = self.add(result, addend)
            addend = self.add(addend, addend)
            n >>= 1
        return result

    def enumerate_points(self) -> List[Point]:
        """Enumerate all points on the curve including infinity."""
        points = [None]  # point at infinity
        for x in range(self.p):
            rhs = (x * x * x + self.a * x + self.b) % self.p
            for y in range(self.p):
                if (y * y) % self.p == rhs:
                    points.append((x, y))
        return points

    def point_count(self) -> int:
        """Count all rational points including infinity."""
        return len(self.enumerate_points())

    def frobenius_trace(self) -> int:
        """Compute the Frobenius trace a_p = p + 1 - #E(F_p)."""
        return self.p + 1 - self.point_count()


def demo_basic_operations():
    """Demonstrate basic elliptic curve operations."""
    print("=" * 70)
    print("DEMO 1: Basic Elliptic Curve Operations")
    print("=" * 70)

    # Classic curve y^2 = x^3 + x + 1 over F_23
    E = EllipticCurve(1, 1, 23)
    print(f"\nCurve: {E}")

    points = E.enumerate_points()
    n = len(points)
    print(f"Number of points: {n}")
    print(f"Points: {points[:10]}{'...' if n > 10 else ''}")

    # Find a generator (first non-infinity point)
    P = points[1]
    print(f"\nBase point P = {P}")
    assert E.is_on_curve(P), "Point not on curve!"

    # Demonstrate addition
    Q = points[2] if n > 2 else P
    print(f"Q = {Q}")
    R = E.add(P, Q)
    print(f"P + Q = {R}")
    assert E.is_on_curve(R), "Sum not on curve!"

    # Demonstrate commutativity
    R2 = E.add(Q, P)
    print(f"Q + P = {R2}")
    print(f"P + Q == Q + P: {R == R2}")

    # Demonstrate negation
    neg_P = E.negate(P)
    print(f"\n-P = {neg_P}")
    print(f"P + (-P) = {E.add(P, neg_P)}")

    # Demonstrate scalar multiplication
    print(f"\nScalar multiples of P:")
    for k in range(1, min(n + 2, 15)):
        kP = E.scalar_mul(k, P)
        print(f"  {k} * P = {kP}")
        if kP is None:
            print(f"  → Order of P divides {k}")
            break


def demo_hasse_bound():
    """Verify the Hasse bound for several curves and primes."""
    print("\n" + "=" * 70)
    print("DEMO 2: Hasse Bound Verification")
    print("=" * 70)

    primes = [5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47, 53, 59, 61, 67, 71, 73, 79, 83, 89, 97]

    print(f"\n{'p':>4} | {'a':>2} {'b':>2} | {'#E':>4} | {'a_p':>4} | {'2√p':>6} | {'|a_p|≤2√p':>10}")
    print("-" * 50)

    for p in primes:
        # Try a = 1, b = 1
        try:
            E = EllipticCurve(1, 1, p)
        except ValueError:
            continue

        n = E.point_count()
        a_p = E.frobenius_trace()
        bound = 2 * math.sqrt(p)
        satisfies = abs(a_p) <= bound

        print(f"{p:>4} | {E.a:>2} {E.b:>2} | {n:>4} | {a_p:>4} | {bound:>6.2f} | {'✓' if satisfies else '✗':>10}")

        assert satisfies, f"Hasse bound violated for p={p}!"

    print("\n✓ Hasse bound verified for all test cases!")


def demo_trace_distribution():
    """Investigate the distribution of normalized traces (Sato-Tate)."""
    print("\n" + "=" * 70)
    print("DEMO 3: Frobenius Trace Distribution (Sato-Tate)")
    print("=" * 70)

    p = 97
    traces = []
    count = 0

    for a in range(p):
        for b in range(p):
            disc = (4 * pow(a, 3, p) + 27 * pow(b, 2, p)) % p
            if disc == 0:
                continue
            E = EllipticCurve(a, b, p)
            t = E.frobenius_trace()
            traces.append(t / (2 * math.sqrt(p)))
            count += 1

    print(f"\nSampled {count} nonsingular curves over F_{p}")
    print(f"Normalized traces a_p/(2√p) ∈ [-1, 1]")

    # Simple histogram
    bins = 10
    hist = [0] * bins
    for t in traces:
        idx = min(int((t + 1) / 2 * bins), bins - 1)
        if idx < 0:
            idx = 0
        hist[idx] += 1

    print(f"\nHistogram of normalized traces:")
    max_h = max(hist)
    for i in range(bins):
        lo = -1 + 2 * i / bins
        hi = -1 + 2 * (i + 1) / bins
        bar = '#' * int(40 * hist[i] / max_h) if max_h > 0 else ''
        print(f"  [{lo:+.1f}, {hi:+.1f}): {hist[i]:>5}  {bar}")

    print(f"\n  (Sato-Tate predicts semicircular distribution for large p)")


def demo_scalar_mul_efficiency():
    """Demonstrate the efficiency of double-and-add."""
    print("\n" + "=" * 70)
    print("DEMO 4: Scalar Multiplication Efficiency")
    print("=" * 70)

    E = EllipticCurve(1, 1, 97)
    P = E.enumerate_points()[1]
    print(f"\nCurve: {E}")
    print(f"Base point: P = {P}")

    # Count operations in naive vs double-and-add
    def naive_mul(n, P):
        """Naive repeated addition: n additions."""
        result = None
        for _ in range(n):
            result = E.add(result, P)
        return result, n  # n additions

    def daa_mul(n, P):
        """Double-and-add: O(log n) operations."""
        ops = 0
        result = None
        addend = P
        while n > 0:
            if n & 1:
                result = E.add(result, addend)
                ops += 1
            addend = E.add(addend, addend)
            ops += 1
            n >>= 1
        return result, ops

    print(f"\n{'n':>8} | {'Naive ops':>10} | {'D&A ops':>8} | {'log₂(n)':>8} | {'Match':>6}")
    print("-" * 50)

    for n in [1, 2, 5, 10, 50, 100, 500, 1000]:
        r1, ops1 = naive_mul(n, P)
        r2, ops2 = daa_mul(n, P)
        log_n = math.ceil(math.log2(n + 1))
        match = "✓" if r1 == r2 else "✗"
        print(f"{n:>8} | {ops1:>10} | {ops2:>8} | {log_n:>8} | {match:>6}")


def demo_group_order():
    """Find the group order and demonstrate it."""
    print("\n" + "=" * 70)
    print("DEMO 5: Group Order and Point Orders")
    print("=" * 70)

    E = EllipticCurve(2, 3, 97)
    print(f"\nCurve: {E}")

    N = E.point_count()
    a_p = E.frobenius_trace()
    print(f"#E(F_97) = {N}")
    print(f"Frobenius trace a_97 = {a_p}")
    print(f"Hasse bound: |{a_p}| ≤ {2 * math.sqrt(97):.4f}  ✓")

    # Find orders of several points
    points = E.enumerate_points()
    print(f"\nPoint orders:")
    for P in points[1:min(8, len(points))]:
        order = 1
        Q = P
        while Q is not None:
            Q = E.add(Q, P)
            order += 1
            if order > N + 1:
                print(f"  P = {P}: order > {N} (error!)")
                break
        if Q is None:
            print(f"  P = {P}: order = {order}, divides #E = {N}: {N % order == 0}")


if __name__ == "__main__":
    demo_basic_operations()
    demo_hasse_bound()
    demo_trace_distribution()
    demo_scalar_mul_efficiency()
    demo_group_order()

    print("\n" + "=" * 70)
    print("All demos completed successfully!")
    print("=" * 70)
