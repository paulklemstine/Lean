"""
demo.py — The Berggren-Lorentz Monoid: Discrete Lorentz Symmetry of Pythagorean Triples

Self-contained numerical demonstration of the results proved in
Catalog/Algebra/BerggrenLorentz/Core.lean.

Key facts demonstrated:
  * Pythagorean triples are integer points on the Minkowski light cone
        Q(a,b,c) = a^2 + b^2 - c^2 = 0.
  * The three Berggren matrices A, B, C preserve the Lorentz metric
        diag(1,1,-1): i.e.  M^T Q_L M = Q_L,  so M in O(2,1;Z).
  * det(A,B,C) = (+1, -1, +1);  tr(A,B,C) = (3, 5, 3).
  * Child maps preserve the Pythagorean property exactly (in fact preserve Q
    on all of Z^3).
  * Hypotenuse growth bounds: 3c <= hypB <= 7c, sharpened to 5c < hypB on the
    cone, giving O(log c) tree depth.
  * Generators are non-commutative; inverses are integer matrices.

Run:  python demo.py
No third-party dependencies (pure standard library).
"""

from __future__ import annotations

from typing import List, Tuple, Dict

Vec3 = Tuple[int, int, int]
Mat3 = List[List[int]]

# --------------------------------------------------------------------------
# Core data: the three Berggren generators and the Minkowski metric.
# --------------------------------------------------------------------------

MAT_A: Mat3 = [[1, -2, 2], [2, -1, 2], [2, -2, 3]]
MAT_B: Mat3 = [[1, 2, 2], [2, 1, 2], [2, 2, 3]]
MAT_C: Mat3 = [[-1, 2, 2], [-2, 1, 2], [-2, 2, 3]]

INV_A: Mat3 = [[1, 2, -2], [-2, -1, 2], [-2, -2, 3]]
INV_B: Mat3 = [[1, 2, -2], [2, 1, -2], [-2, -2, 3]]
INV_C: Mat3 = [[-1, -2, 2], [2, 1, -2], [-2, -2, 3]]

METRIC_Q: Mat3 = [[1, 0, 0], [0, 1, 0], [0, 0, -1]]

GENERATORS: Dict[str, Mat3] = {"A": MAT_A, "B": MAT_B, "C": MAT_C}


# --------------------------------------------------------------------------
# Linear algebra over the integers (exact).
# --------------------------------------------------------------------------

def mat_mul(m: Mat3, n: Mat3) -> Mat3:
    """Exact 3x3 integer matrix product."""
    return [[sum(m[i][k] * n[k][j] for k in range(3)) for j in range(3)]
            for i in range(3)]


def mat_vec(m: Mat3, v: Vec3) -> Vec3:
    """Apply a 3x3 matrix to a column vector."""
    return tuple(sum(m[i][k] * v[k] for k in range(3)) for i in range(3))  # type: ignore


def transpose(m: Mat3) -> Mat3:
    return [[m[j][i] for j in range(3)] for i in range(3)]


def det3(m: Mat3) -> int:
    """Exact determinant of a 3x3 integer matrix."""
    return (m[0][0] * (m[1][1] * m[2][2] - m[1][2] * m[2][1])
            - m[0][1] * (m[1][0] * m[2][2] - m[1][2] * m[2][0])
            + m[0][2] * (m[1][0] * m[2][1] - m[1][1] * m[2][0]))


def trace3(m: Mat3) -> int:
    return m[0][0] + m[1][1] + m[2][2]


def identity3() -> Mat3:
    return [[1 if i == j else 0 for j in range(3)] for i in range(3)]


# --------------------------------------------------------------------------
# Lorentz form and Pythagorean predicate.
# --------------------------------------------------------------------------

def lorentz_Q(v: Vec3) -> int:
    """Lorentzian quadratic form Q(a,b,c) = a^2 + b^2 - c^2."""
    a, b, c = v
    return a * a + b * b - c * c


def is_pythag(v: Vec3) -> bool:
    """A triple is Pythagorean iff it lies on the light cone Q = 0."""
    return lorentz_Q(v) == 0


def preserves_lorentz(m: Mat3) -> bool:
    """Check M^T Q_L M = Q_L  (membership in O(2,1;Z))."""
    return mat_mul(mat_mul(transpose(m), METRIC_Q), m) == METRIC_Q


# --------------------------------------------------------------------------
# Child maps (explicit coordinate formulas matching the Lean defs).
# --------------------------------------------------------------------------

def child_A(v: Vec3) -> Vec3:
    a, b, c = v
    return (a - 2 * b + 2 * c, 2 * a - b + 2 * c, 2 * a - 2 * b + 3 * c)


def child_B(v: Vec3) -> Vec3:
    a, b, c = v
    return (a + 2 * b + 2 * c, 2 * a + b + 2 * c, 2 * a + 2 * b + 3 * c)


def child_C(v: Vec3) -> Vec3:
    a, b, c = v
    return (-a + 2 * b + 2 * c, -2 * a + b + 2 * c, -2 * a + 2 * b + 3 * c)


# --------------------------------------------------------------------------
# Berggren tree generation.
# --------------------------------------------------------------------------

def berggren_tree(max_hyp: int, seed: Vec3 = (3, 4, 5)) -> List[Vec3]:
    """Depth-first enumeration of all primitive triples with hypotenuse <= max_hyp.

    Terminates because each child strictly increases the hypotenuse
    (Theorem hypB_strict_growth and friends); depth is O(log max_hyp).
    """
    out: List[Vec3] = []
    stack: List[Vec3] = [seed]
    while stack:
        v = stack.pop()
        if v[2] > max_hyp:
            continue
        out.append(v)
        for child in (child_A(v), child_B(v), child_C(v)):
            if child[2] <= max_hyp:
                stack.append(child)
    return out


def climb_to_root(v: Vec3) -> List[str]:
    """Recover the unique A/B/C path from a triple back to the root (3,4,5).

    Uses integer inverses; at each step exactly one inverse keeps all
    coordinates positive and strictly decreases the hypotenuse.
    Returns the path read root->leaf.
    """
    path: List[str] = []
    cur = v
    while cur != (3, 4, 5):
        for name, inv in (("A", INV_A), ("B", INV_B), ("C", INV_C)):
            cand = mat_vec(inv, cur)
            if all(x > 0 for x in cand) and cand[2] < cur[2]:
                path.append(name)
                cur = cand
                break
        else:  # pragma: no cover - should not happen for valid primitive triples
            raise ValueError(f"no valid parent for {v}")
    return list(reversed(path))


# --------------------------------------------------------------------------
# Demonstrations.
# --------------------------------------------------------------------------

def demo_lorentz_membership() -> None:
    print("=" * 70)
    print("1.  Berggren generators lie in O(2,1;Z):  M^T diag(1,1,-1) M = M")
    print("=" * 70)
    for name, m in GENERATORS.items():
        print(f"   {name}: preserves Lorentz metric = {preserves_lorentz(m)}, "
              f"det = {det3(m):+d}, trace = {trace3(m)}")
    print(f"   Inverses preserve metric: "
          f"A={preserves_lorentz(INV_A)}, B={preserves_lorentz(INV_B)}, "
          f"C={preserves_lorentz(INV_C)}")
    print(f"   det signature (expected (+1,-1,+1)): "
          f"({det3(MAT_A):+d},{det3(MAT_B):+d},{det3(MAT_C):+d})")
    print(f"   trace signature (expected (3,5,3)):  "
          f"({trace3(MAT_A)},{trace3(MAT_B)},{trace3(MAT_C)}),  sum = "
          f"{trace3(MAT_A)+trace3(MAT_B)+trace3(MAT_C)}")


def demo_inverses() -> None:
    print()
    print("=" * 70)
    print("2.  Integer inverses:  M * M^{-1} = I")
    print("=" * 70)
    for name, m, inv in (("A", MAT_A, INV_A), ("B", MAT_B, INV_B),
                         ("C", MAT_C, INV_C)):
        ok = mat_mul(m, inv) == identity3() and mat_mul(inv, m) == identity3()
        print(f"   {name} * {name}^-1 = I : {ok}")


def demo_noncommutativity() -> None:
    print()
    print("=" * 70)
    print("3.  Non-commutativity (free monoid -> unique tree addresses)")
    print("=" * 70)
    print(f"   AB != BA : {mat_mul(MAT_A, MAT_B) != mat_mul(MAT_B, MAT_A)}")
    print(f"   BC != CB : {mat_mul(MAT_B, MAT_C) != mat_mul(MAT_C, MAT_B)}")
    print(f"   AC != CA : {mat_mul(MAT_A, MAT_C) != mat_mul(MAT_C, MAT_A)}")
    print(f"   eigenvalue 1?  det(I-A)={det3(sub(identity3(),MAT_A))}, "
          f"det(I-B)={det3(sub(identity3(),MAT_B))}, "
          f"det(I-C)={det3(sub(identity3(),MAT_C))}")


def sub(m: Mat3, n: Mat3) -> Mat3:
    return [[m[i][j] - n[i][j] for j in range(3)] for i in range(3)]


def demo_tree() -> None:
    print()
    print("=" * 70)
    print("4.  The Berggren tree: every primitive triple, exactly once")
    print("=" * 70)
    seed: Vec3 = (3, 4, 5)
    print(f"   seed (3,4,5) on cone Q=0 : {is_pythag(seed)}")
    print(f"   children of (3,4,5):")
    for fn, label in ((child_A, "A"), (child_B, "B"), (child_C, "C")):
        ch = fn(seed)
        print(f"      child_{label} = {ch}, Pythagorean = {is_pythag(ch)}, "
              f"Q preserved = {lorentz_Q(ch) == lorentz_Q(seed)}")
    triples = berggren_tree(max_hyp=120)
    triples_sorted = sorted(triples, key=lambda t: t[2])
    print(f"   all {len(triples)} primitive triples with hypotenuse <= 120:")
    for t in triples_sorted:
        print(f"      {t}   (Q = {lorentz_Q(t)})")


def demo_growth() -> None:
    print()
    print("=" * 70)
    print("5.  Hypotenuse growth bounds:  3c <= hypB <= 7c,  5c < hypB on cone")
    print("=" * 70)
    for v in [(3, 4, 5), (5, 12, 13), (20, 21, 29), (7, 24, 25)]:
        a, b, c = v
        hb = child_B(v)[2]
        print(f"   ({a},{b},{c}): hypB = {hb};  "
              f"3c={3*c} <= {hb} <= 7c={7*c} : {3*c <= hb <= 7*c};  "
              f"5c={5*c} < {hb} : {5*c < hb}")


def demo_path_recovery() -> None:
    print()
    print("=" * 70)
    print("6.  Path recovery (climb to root via integer inverses)")
    print("=" * 70)
    for v in [(5, 12, 13), (7, 24, 25), (55, 48, 73), (15, 8, 17), (119, 120, 169)]:
        # verify v really is reachable / Pythagorean
        path = climb_to_root(v)
        # replay forward to confirm
        cur: Vec3 = (3, 4, 5)
        fns = {"A": child_A, "B": child_B, "C": child_C}
        for step in path:
            cur = fns[step](cur)
        print(f"   {v}: address = {''.join(path) or '(root)'};  "
              f"forward replay matches = {cur == v}")


def main() -> None:
    print("Berggren-Lorentz Monoid : Discrete Lorentz Symmetry of Pythagorean Triples")
    demo_lorentz_membership()
    demo_inverses()
    demo_noncommutativity()
    demo_tree()
    demo_growth()
    demo_path_recovery()
    print()
    print("All numerical checks reflect the machine-verified theorems in Core.lean.")


if __name__ == "__main__":
    main()
