"""Numerical demonstration of the Bridge Theorem:

    h_q(n) = 0   <=>   every nonzero cyclic code in F_q^n has a full-weight codeword.

We work over a prime field F_p (p prime) and the space V = F_p^n indexed by
Z/nZ.  Everything is brute-forced over small parameters, so the two sides of the
equivalence can be computed *independently* and then compared:

  * The covering side, h_q(n) = 0, is decided via hyperplanes: since every proper
    subspace lies inside a hyperplane and "covering" is preserved under enlarging
    a subspace, h_q(n) = 0 holds iff no hyperplane ker<a,.> (a != 0) is
    cyclically covering.

  * The coding side is decided by enumerating cyclic codes.  Over a field,
    F_p[x]/(x^n - 1) is a principal ideal ring, so every cyclic code is the span
    of the rotations of a single generator; we enumerate all such codes and test
    each nonzero one for a full-weight codeword.

We also verify the "core bridge" directly: for a fixed a, the hyperplane
ker<a,.> is covering iff the cyclic code Phi_a(V) omits every full-weight word.

Run:  python demo.py
"""

from __future__ import annotations

from itertools import product
from typing import Dict, List, Sequence, Set, Tuple

Vec = Tuple[int, ...]


# ---------------------------------------------------------------------------
# Field / space primitives over F_p, V = F_p^n indexed by Z/nZ
# ---------------------------------------------------------------------------
def all_vectors(p: int, n: int) -> List[Vec]:
    """Every word in V = F_p^n."""
    return [tuple(v) for v in product(range(p), repeat=n)]


def rot(x: Vec, k: int) -> Vec:
    """Cyclic shift: (rot_k x)_i = x_{i+k}  (indices mod n)."""
    n = len(x)
    return tuple(x[(i + k) % n] for i in range(n))


def rotations(x: Vec) -> List[Vec]:
    """All n cyclic shifts of x."""
    return [rot(x, k) for k in range(len(x))]


def rev(x: Vec) -> Vec:
    """Coordinate reversal: (rev x)_i = x_{-i}."""
    n = len(x)
    return tuple(x[(-i) % n] for i in range(n))


def pair(a: Vec, x: Vec, p: int) -> int:
    """Standard pairing <a, x> = sum_i a_i x_i  in F_p."""
    return sum(ai * xi for ai, xi in zip(a, x)) % p


def phi(a: Vec, x: Vec, p: int) -> Vec:
    """Correlation transform: Phi_a(x)_k = <a, rot_k x>."""
    n = len(x)
    return tuple(pair(a, rot(x, k), p) for k in range(n))


def is_full_weight(c: Vec) -> bool:
    """True iff every coordinate is nonzero."""
    return all(ci != 0 for ci in c)


# ---------------------------------------------------------------------------
# Linear algebra over F_p: RREF as a canonical subspace fingerprint
# ---------------------------------------------------------------------------
def rref(rows: Sequence[Vec], p: int) -> Tuple[Vec, ...]:
    """Reduced row echelon form of the span of `rows` over F_p.

    Returns the tuple of nonzero pivot rows, a canonical representative of the
    subspace they span.
    """
    n = len(rows[0]) if rows else 0
    mat: List[List[int]] = [list(r) for r in rows]
    pivot_row = 0
    for col in range(n):
        sel = None
        for r in range(pivot_row, len(mat)):
            if mat[r][col] % p != 0:
                sel = r
                break
        if sel is None:
            continue
        mat[pivot_row], mat[sel] = mat[sel], mat[pivot_row]
        inv = pow(mat[pivot_row][col], p - 2, p)  # Fermat inverse
        mat[pivot_row] = [(v * inv) % p for v in mat[pivot_row]]
        for r in range(len(mat)):
            if r != pivot_row and mat[r][col] % p != 0:
                f = mat[r][col]
                mat[r] = [(a - f * b) % p for a, b in zip(mat[r], mat[pivot_row])]
        pivot_row += 1
        if pivot_row == len(mat):
            break
    basis = [tuple(row) for row in mat if any(v % p != 0 for v in row)]
    return tuple(sorted(basis))


def span_words(basis: Sequence[Vec], p: int) -> List[Vec]:
    """All words in the subspace spanned by `basis`."""
    if not basis:
        n = 0
        return [tuple()]
    n = len(basis[0])
    words: Set[Vec] = set()
    for coeffs in product(range(p), repeat=len(basis)):
        w = [0] * n
        for c, b in zip(coeffs, basis):
            for i in range(n):
                w[i] = (w[i] + c * b[i]) % p
        words.add(tuple(w))
    return list(words)


# ---------------------------------------------------------------------------
# Covering side:  deciding h_q(n) = 0
# ---------------------------------------------------------------------------
def covering_ker(a: Vec, p: int) -> bool:
    """Is the hyperplane ker<a,.> cyclically covering?

    True iff every word x has some rotation with <a, rot_k x> = 0, equivalently
    (core bridge) iff Phi_a(V) omits every full-weight word.
    """
    n = len(a)
    for x in all_vectors(p, n):
        if not any(pair(a, rot(x, k), p) == 0 for k in range(n)):
            return False
    return True


def h_zero(p: int, n: int) -> bool:
    """Decide h_q(n) = 0 via hyperplanes: no nonzero a gives a covering ker."""
    zero = (0,) * n
    for a in all_vectors(p, n):
        if a == zero:
            continue
        if covering_ker(a, p):
            return False
    return True


# ---------------------------------------------------------------------------
# Coding side:  the full-weight property
# ---------------------------------------------------------------------------
def all_cyclic_codes(p: int, n: int) -> List[Tuple[Vec, ...]]:
    """All cyclic codes, as canonical RREF bases.

    Over a field every cyclic code is generated by a single word, so the span of
    the rotations of some generator sweeps out all of them.
    """
    codes: Set[Tuple[Vec, ...]] = set()
    for c in all_vectors(p, n):
        codes.add(rref(rotations(c), p))
    return list(codes)


def code_has_full_weight(basis: Sequence[Vec], p: int) -> bool:
    """Does the cyclic code with the given basis contain a full-weight word?"""
    return any(is_full_weight(w) for w in span_words(basis, p))


def full_weight_property(p: int, n: int) -> bool:
    """Does every nonzero cyclic code contain a full-weight codeword?"""
    for basis in all_cyclic_codes(p, n):
        if not basis:  # the zero code
            continue
        if not code_has_full_weight(basis, p):
            return False
    return True


# ---------------------------------------------------------------------------
# Direct check of the core bridge for a fixed a
# ---------------------------------------------------------------------------
def phi_image(a: Vec, p: int) -> Tuple[Vec, ...]:
    """Canonical basis of the cyclic code Phi_a(V)."""
    n = len(a)
    return rref([phi(a, x, p) for x in all_vectors(p, n)], p)


def core_bridge_holds(a: Vec, p: int) -> bool:
    """Verify: ker<a,.> covering  <=>  Phi_a(V) has no full-weight word."""
    left = covering_ker(a, p)
    right = not code_has_full_weight(phi_image(a, p), p)
    return left == right


# ---------------------------------------------------------------------------
# Demonstrations
# ---------------------------------------------------------------------------
def demo_equivalence_table() -> None:
    """Independently compute both sides and confirm they always agree."""
    print("=" * 70)
    print("Bridge Theorem:  h_q(n)=0   <=>   full-weight property")
    print("=" * 70)
    print(f"{'q':>3} {'n':>3} | {'h_q(n)=0':>10} {'full-weight':>12} {'match':>7}")
    print("-" * 70)
    cases = [(2, 2), (2, 3), (2, 4), (2, 5), (3, 2), (3, 3), (3, 4), (5, 2), (5, 3)]
    for p, n in cases:
        hz = h_zero(p, n)
        fw = full_weight_property(p, n)
        print(f"{p:>3} {n:>3} | {str(hz):>10} {str(fw):>12} "
              f"{('OK' if hz == fw else 'FAIL'):>7}")


def demo_binary_length_three() -> None:
    """The canonical failure: F_2^3 and the even-weight code."""
    print("\n" + "=" * 70)
    print("Worked example: F_2, n = 3  (even-weight code)")
    print("=" * 70)
    p, n = 2, 3
    even = rref([(1, 1, 0), (0, 1, 1)], p)  # {x : x0+x1+x2 = 0}
    words = sorted(span_words(even, p))
    print("Even-weight code C_ev =", ["".join(map(str, w)) for w in words])
    print("Full-weight codeword in C_ev? ", code_has_full_weight(even, p),
          "(the only candidate 111 is absent)")
    a = (1, 1, 1)
    print("Hyperplane ker<(1,1,1),.> cyclically covering? ", covering_ker(a, p))
    print("=> full-weight property fails, so h_2(3) != 0.  Computed h_2(3)=0? ",
          h_zero(p, n))


def demo_core_bridge() -> None:
    """Check the core bridge over all directions a for several (q, n)."""
    print("\n" + "=" * 70)
    print("Core bridge check:  ker<a,.> covering  <=>  Phi_a(V) full-weight-free")
    print("=" * 70)
    for p, n in [(2, 3), (2, 4), (3, 3)]:
        zero = (0,) * n
        ok = all(core_bridge_holds(a, p)
                 for a in all_vectors(p, n) if a != zero)
        print(f"q={p}, n={n}:  holds for all nonzero a?  {ok}")


def demo_phi_generates_code() -> None:
    """Phi_{rev(c)}(V) equals the cyclic code generated by c."""
    print("\n" + "=" * 70)
    print("Phi_{rev(c)}(V) = <c> (cyclic code generated by c)")
    print("=" * 70)
    p, n = 3, 4
    for c in [(1, 0, 0, 0), (1, 2, 0, 0), (1, 1, 1, 1)]:
        gen_code = rref(rotations(c), p)
        phi_code = phi_image(rev(c), p)
        print(f"c={c}:  Phi_rev image == <c>?  {gen_code == phi_code}")


if __name__ == "__main__":
    demo_equivalence_table()
    demo_binary_length_three()
    demo_core_bridge()
    demo_phi_generates_code()
