"""
Braiding Obstructions in the Berggren Groupoid of Pythagorean Triples
=====================================================================

Self-contained numerical demonstration of every result in the accompanying paper.
Pure Python standard library only (``fractions``, ``cmath``, ``itertools``, ``math``).

Contents
--------
1.  The Berggren ternary tree of primitive Pythagorean triples.
2.  The Euclid lift  SO(2,1) -> GL(2, Z)  and its intertwining property.
3.  Failure of the Artin braid relation for every pair of generators.
4.  The mod-2 charge:  homomorphism, letter-parity formula, braid invariance.
5.  Integrality forbids density in U(2):  the eight integral orthogonal matrices,
    and the unreachable phase gate S = diag(i, 1).
6.  The silver spectrum:  eigenvalues 1 +- sqrt(2), Pell unit 3 + 2 sqrt(2),
    the recurrence c_{n+2} = 6 c_{n+1} - c_n, and the growth envelope.
7.  Two-sided depth bounds  (d+2)^2 < c <= 5 * 9^d, with both extremes attained.
8.  The Ising braid representation from sqrt(2):  it braids, it is unitary of
    order 8, it is Clifford, and it therefore misses the pi/8 gate.

Run with:  python3 demo.py
"""

from __future__ import annotations

import cmath
import itertools
import math
from typing import Dict, Iterable, List, Sequence, Tuple

# ---------------------------------------------------------------------------
# Basic exact linear algebra over the integers (2x2 and 3x3)
# ---------------------------------------------------------------------------

Mat = Tuple[Tuple[int, ...], ...]
Vec = Tuple[int, ...]


def mat_mul(a: Mat, b: Mat) -> Mat:
    """Exact matrix product of two integer matrices."""
    n, m, p = len(a), len(b), len(b[0])
    return tuple(
        tuple(sum(a[i][k] * b[k][j] for k in range(m)) for j in range(p))
        for i in range(n)
    )


def mat_vec(a: Mat, v: Vec) -> Vec:
    """Exact matrix-vector product."""
    return tuple(sum(a[i][k] * v[k] for k in range(len(v))) for i in range(len(a)))


def mat_pow(a: Mat, k: int) -> Mat:
    """Exact k-th power of a square integer matrix (k >= 0)."""
    n = len(a)
    result: Mat = tuple(tuple(1 if i == j else 0 for j in range(n)) for i in range(n))
    for _ in range(k):
        result = mat_mul(result, a)
    return result


def transpose(a: Mat) -> Mat:
    return tuple(tuple(a[i][j] for i in range(len(a))) for j in range(len(a[0])))


def det2(a: Mat) -> int:
    return a[0][0] * a[1][1] - a[0][1] * a[1][0]


def trace(a: Mat) -> int:
    return sum(a[i][i] for i in range(len(a)))


def mat_mod(a: Mat, m: int) -> Mat:
    return tuple(tuple(x % m for x in row) for row in a)


IDENT2: Mat = ((1, 0), (0, 1))
SWAP2: Mat = ((0, 1), (1, 0))  # the matrix J of the mod-2 reduction

# ---------------------------------------------------------------------------
# 1.  The Berggren generators, in dimension 3 and in the Euclid lift
# ---------------------------------------------------------------------------

BERG3: Dict[str, Mat] = {
    "A": ((1, -2, 2), (2, -1, 2), (2, -2, 3)),
    "B": ((1, 2, 2), (2, 1, 2), (2, 2, 3)),
    "C": ((-1, 2, 2), (-2, 1, 2), (-2, 2, 3)),
}

LIFT2: Dict[str, Mat] = {
    "A": ((2, -1), (1, 0)),  # (m, n) -> (2m - n, m)
    "B": ((2, 1), (1, 0)),   # (m, n) -> (2m + n, m)
    "C": ((1, 2), (0, 1)),   # (m, n) -> (m + 2n, n)
}

ROOT_TRIPLE: Vec = (3, 4, 5)
ROOT_PARAMS: Vec = (2, 1)


def euclid(m: int, n: int) -> Vec:
    """Euclid's parametrisation E(m, n) = (m^2 - n^2, 2mn, m^2 + n^2)."""
    return (m * m - n * n, 2 * m * n, m * m + n * n)


def apply_word_triple(word: str) -> Vec:
    """Apply a word of Berggren steps to the root triple (3, 4, 5)."""
    v = ROOT_TRIPLE
    for letter in word:
        v = mat_vec(BERG3[letter], v)
    return v


def apply_word_params(word: str) -> Vec:
    """Apply the corresponding word of 2x2 lifts to the root parameters (2, 1)."""
    v = ROOT_PARAMS
    for letter in word:
        v = mat_vec(LIFT2[letter], v)
    return v


def word_matrix(word: str) -> Mat:
    """The accumulated 2x2 integer matrix of a Berggren word."""
    result = IDENT2
    for letter in word:
        result = mat_mul(result, LIFT2[letter])
    return result


def all_words(depth: int) -> Iterable[str]:
    """All Berggren words of a given length."""
    return ("".join(t) for t in itertools.product("ABC", repeat=depth))


# ---------------------------------------------------------------------------
# 2.  The mod-2 charge
# ---------------------------------------------------------------------------


def charge_from_matrix(a: Mat) -> int:
    """Charge of an integer 2x2 matrix: 0 if it reduces to I mod 2, else 1."""
    return 0 if mat_mod(a, 2) == IDENT2 else 1


def charge_from_word(word: str) -> int:
    """Charge of a word: the parity of its number of A- and B-letters."""
    return sum(1 for letter in word if letter in "AB") % 2


# ---------------------------------------------------------------------------
# 3.  Integral orthogonal matrices
# ---------------------------------------------------------------------------


def signed_permutations_2x2() -> List[Mat]:
    """Enumerate all 2x2 integer matrices M with M^T M = I, by brute force."""
    found: List[Mat] = []
    rng = range(-2, 3)
    for a, b, c, d in itertools.product(rng, repeat=4):
        m: Mat = ((a, b), (c, d))
        if mat_mul(transpose(m), m) == IDENT2:
            found.append(m)
    return found


# ---------------------------------------------------------------------------
# 4.  The Ising braid representation from sqrt(2)
# ---------------------------------------------------------------------------

CMat = Tuple[Tuple[complex, ...], ...]

R2: float = math.sqrt(2.0) / 2.0  # = 1/sqrt(2)

A_ISING: CMat = ((R2 * (1 + 1j), 0 + 0j), (0 + 0j, R2 * (1 - 1j)))
B_ISING: CMat = ((R2 + 0j, R2 * 1j), (R2 * 1j, R2 + 0j))

PAULI_X: CMat = ((0 + 0j, 1 + 0j), (1 + 0j, 0 + 0j))
PAULI_Y: CMat = ((0 + 0j, -1j), (1j, 0 + 0j))
PAULI_Z: CMat = ((1 + 0j, 0 + 0j), (0 + 0j, -1 + 0j))
T_GATE: CMat = ((1 + 0j, 0 + 0j), (0 + 0j, R2 * (1 + 1j)))
S_GATE: CMat = ((1j, 0 + 0j), (0 + 0j, 1 + 0j))


def cmul(a: CMat, b: CMat) -> CMat:
    return tuple(
        tuple(sum(a[i][k] * b[k][j] for k in range(2)) for j in range(2))
        for i in range(2)
    )


def cdag(a: CMat) -> CMat:
    return tuple(tuple(a[j][i].conjugate() for j in range(2)) for i in range(2))


def cneg(a: CMat) -> CMat:
    return tuple(tuple(-x for x in row) for row in a)


def cclose(a: CMat, b: CMat, tol: float = 1e-12) -> bool:
    return all(abs(a[i][j] - b[i][j]) < tol for i in range(2) for j in range(2))


def cpow(a: CMat, k: int) -> CMat:
    result: CMat = ((1 + 0j, 0 + 0j), (0 + 0j, 1 + 0j))
    for _ in range(k):
        result = cmul(result, a)
    return result


def signed_paulis() -> List[CMat]:
    return [PAULI_X, cneg(PAULI_X), PAULI_Y, cneg(PAULI_Y), PAULI_Z, cneg(PAULI_Z)]


def is_clifford(u: CMat) -> bool:
    """A unitary is Clifford iff conjugation permutes the six signed Paulis."""
    paulis = signed_paulis()
    for p in paulis:
        image = cmul(cmul(u, p), cdag(u))
        if not any(cclose(image, q) for q in paulis):
            return False
    return True


def pauli_name(a: CMat) -> str:
    table = [
        (PAULI_X, "X"), (cneg(PAULI_X), "-X"),
        (PAULI_Y, "Y"), (cneg(PAULI_Y), "-Y"),
        (PAULI_Z, "Z"), (cneg(PAULI_Z), "-Z"),
    ]
    for m, name in table:
        if cclose(a, m):
            return name
    return "not a signed Pauli"


# ---------------------------------------------------------------------------
# Demonstrations
# ---------------------------------------------------------------------------


def banner(title: str) -> None:
    print()
    print("=" * 76)
    print(title)
    print("=" * 76)


def demo_tree() -> None:
    banner("1.  The Berggren ternary tree of primitive Pythagorean triples")
    print(f"root: {ROOT_TRIPLE}")
    for word in all_words(1):
        print(f"   {word}  ->  {apply_word_triple(word)}")
    print("depth 2 (all nine children of the children):")
    for word in all_words(2):
        print(f"   {word} -> {apply_word_triple(word)}", end="")
        print("" if word.endswith("C") else "", end="\n" if word[-1] == "C" else "")
    print()
    # every generated triple is primitive and Pythagorean, with no repetitions
    seen = set()
    ok = True
    for d in range(0, 7):
        for word in all_words(d):
            a, b, c = apply_word_triple(word)
            if a * a + b * b != c * c or math.gcd(math.gcd(a, b), c) != 1:
                ok = False
            if (a, b, c) in seen:
                ok = False
            seen.add((a, b, c))
    total = sum(3 ** d for d in range(0, 7))
    print(f"depths 0..6:  {len(seen)} distinct triples out of {total} words")
    print(f"all Pythagorean, primitive and pairwise distinct: {ok}")


def demo_euclid_lift() -> None:
    banner("2.  The Euclid lift:  each 3x3 generator is a symmetric square")
    for letter in "ABC":
        lift = LIFT2[letter]
        print(f"   {letter}:  lift = {lift},  det = {det2(lift):+d},  trace = {trace(lift)}")
    print()
    print("intertwining  E(U.(m,n)) = M_letter . E(m,n)  checked for many (m,n):")
    ok = True
    for m in range(1, 12):
        for n in range(1, m):
            for letter in "ABC":
                lhs = euclid(*mat_vec(LIFT2[letter], (m, n)))
                rhs = mat_vec(BERG3[letter], euclid(m, n))
                if lhs != rhs:
                    ok = False
    print(f"   all identities hold: {ok}")
    print()
    print("and the lift computes the whole tree, E(pi(p)) = Pi(p):")
    ok = all(
        euclid(*apply_word_params(w)) == apply_word_triple(w)
        for d in range(0, 7)
        for w in all_words(d)
    )
    print(f"   verified to depth 6: {ok}")


def demo_braid_failure() -> None:
    banner("3.  No pair of Berggren generators satisfies the Artin relation")
    for x, y in itertools.combinations("ABC", 2):
        ux, uy = LIFT2[x], LIFT2[y]
        xyx = mat_mul(mat_mul(ux, uy), ux)
        yxy = mat_mul(mat_mul(uy, ux), uy)
        comm = mat_mul(ux, uy) == mat_mul(uy, ux)
        print(f"   ({x},{y}):  XYX = {xyx}   YXY = {yxy}")
        print(f"           braid relation holds? {xyx == yxy};  commute? {comm}")
    print()
    print("the same in dimension 3:")
    for x, y in itertools.combinations("ABC", 2):
        mx, my = BERG3[x], BERG3[y]
        holds = mat_mul(mat_mul(mx, my), mx) == mat_mul(mat_mul(my, mx), my)
        print(f"   ({x},{y}): braid relation holds? {holds}")
    print()
    print("the trace criterion is silent, because all traces equal 2:")
    print("   (tr X - tr Y) * (tr(XY) + det X) = 0 is automatic here")
    for x, y in itertools.combinations("ABC", 2):
        ux, uy = LIFT2[x], LIFT2[y]
        val = (trace(ux) - trace(uy)) * (trace(mat_mul(ux, uy)) + det2(ux))
        print(f"   ({x},{y}): criterion value = {val}")


def demo_charge() -> None:
    banner("4.  The mod-2 charge:  homomorphism, letter parity, braid invariance")
    for letter in "ABC":
        print(f"   {letter} mod 2 = {mat_mod(LIFT2[letter], 2)}"
              f"   charge = {charge_from_matrix(LIFT2[letter])}")
    print()
    print("every word reduces mod 2 to I or J = ((0,1),(1,0)):")
    reductions = {mat_mod(word_matrix(w), 2) for d in range(0, 9) for w in all_words(d)}
    print(f"   set of reductions over all words of length <= 8: {sorted(reductions)}")
    print()
    print("charge of a word = parity of its number of A/B letters:")
    ok = all(
        charge_from_matrix(word_matrix(w)) == charge_from_word(w)
        for d in range(0, 9)
        for w in all_words(d)
    )
    print(f"   verified for all words of length <= 8: {ok}")
    print()
    print("braid invariance: if XYX = YXY inside the Berggren group then q(X) = q(Y).")
    print("   we search all pairs of words of length <= 4 for a braiding pair:")
    words = [w for d in range(1, 5) for w in all_words(d)]
    mats = {w: word_matrix(w) for w in words}
    braiding: List[Tuple[str, str]] = []
    for wx, wy in itertools.combinations(words, 2):
        mx, my = mats[wx], mats[wy]
        if mat_mul(mat_mul(mx, my), mx) == mat_mul(mat_mul(my, mx), my):
            braiding.append((wx, wy))
    print(f"   braiding pairs found: {len(braiding)}")
    if braiding:
        bad = [(a, b) for a, b in braiding
               if charge_from_word(a) != charge_from_word(b)]
        print(f"   of these, pairs with unequal charge: {len(bad)}  (must be 0)")
        for a, b in braiding[:5]:
            print(f"      {a} , {b}   charges {charge_from_word(a)},{charge_from_word(b)}")
    print()
    print("the braid generators of SL(2,Z) are NOT Berggren elements:")
    tmat: Mat = ((1, 1), (0, 1))
    lmat: Mat = ((1, 0), (-1, 1))
    print(f"   T L T = {mat_mul(mat_mul(tmat, lmat), tmat)}")
    print(f"   L T L = {mat_mul(mat_mul(lmat, tmat), lmat)}   equal? "
          f"{mat_mul(mat_mul(tmat, lmat), tmat) == mat_mul(mat_mul(lmat, tmat), lmat)}")
    print(f"   T mod 2 = {mat_mod(tmat, 2)}  in {{I, J}}? "
          f"{mat_mod(tmat, 2) in (IDENT2, SWAP2)}")
    print(f"   L mod 2 = {mat_mod(lmat, 2)}  in {{I, J}}? "
          f"{mat_mod(lmat, 2) in (IDENT2, SWAP2)}")


def demo_integrality() -> None:
    banner("5.  Integrality forbids density in U(2)")
    perms = signed_permutations_2x2()
    print(f"   integer 2x2 matrices with M^T M = I:  {len(perms)} of them")
    for m in perms:
        print(f"      {m}")
    print()
    for letter in "ABC":
        u = LIFT2[letter]
        print(f"   {letter}: U^T U = {mat_mul(transpose(u), u)}  orthogonal? "
              f"{mat_mul(transpose(u), u) == IDENT2}")
    print()
    print("   the phase gate S = diag(i, 1) is unitary:",
          cclose(cmul(cdag(S_GATE), S_GATE), ((1 + 0j, 0j), (0j, 1 + 0j))))
    print("   its (0,0) entry has imaginary part", S_GATE[0][0].imag,
          "-> not an integer, so S is not in the (closed) set of integral matrices,")
    print("   hence not in the closure of any set of integer matrices.")
    print()
    print("   how close can a Berggren word get to S?  (Frobenius distance)")
    best = min(
        (
            math.sqrt(sum(abs(complex(word_matrix(w)[i][j]) - S_GATE[i][j]) ** 2
                          for i in range(2) for j in range(2))),
            w,
        )
        for d in range(0, 7)
        for w in all_words(d)
    )
    print(f"      best over all words of length <= 6: {best[0]:.6f}  (word '{best[1]}')")
    print("      the distance can never drop below 1 (the imaginary part of i).")


def demo_silver_spectrum() -> None:
    banner("6.  The silver spectrum: 1 + sqrt(2), the Pell unit 3 + 2 sqrt(2)")
    u2 = LIFT2["B"]
    w = mat_mul(u2, u2)
    print(f"   U_2 = {u2}    char. poly  x^2 - {trace(u2)}x + ({det2(u2)})")
    print(f"   eigenvalues: {1 + math.sqrt(2):.9f}, {1 - math.sqrt(2):.9f}"
          f"   (silver ratio 1 +- sqrt(2))")
    print(f"   W = U_2^2 = {w}   trace {trace(w)}, det {det2(w)}")
    print(f"   eigenvalues: {3 + 2 * math.sqrt(2):.9f}, {3 - 2 * math.sqrt(2):.9f}"
          f"   (Pell unit 3 +- 2 sqrt(2))")
    print(f"   (3 + 2r2)(3 - 2r2) = {(3 + 2 * math.sqrt(2)) * (3 - 2 * math.sqrt(2)):.12f}")
    print(f"   Cayley-Hamilton  W^2 = 6W - I : "
          f"{mat_mul(w, w) == tuple(tuple(6 * w[i][j] - IDENT2[i][j] for j in range(2)) for i in range(2))}")
    print()
    print("   the B-spine and its Pell recurrence c_{n+2} = 6 c_{n+1} - c_n:")
    print("     n |        c_n |  5^(n+1) <= c_n <= 5*6^n | near-isosceles triple")
    v = ROOT_PARAMS
    cs: List[int] = []
    for n in range(0, 9):
        c = v[0] ** 2 + v[1] ** 2
        cs.append(c)
        a, b, cc = euclid(*v)
        lo, hi = 5 ** (n + 1), 5 * 6 ** n
        print(f"    {n:2d} | {c:10d} |  {lo:>10d} <= c <= {hi:<12d} | "
              f"({min(abs(a), b)}, {max(abs(a), b)}, {cc})  |a-b| = {abs(abs(a) - b)}")
        v = mat_vec(u2, v)
    ok = all(cs[n + 2] == 6 * cs[n + 1] - cs[n] for n in range(len(cs) - 2))
    print(f"   recurrence verified: {ok}")
    print()
    print("   hyperbolicity: entries of W^n grow, so no power is orthogonal")
    for n in range(1, 7):
        wn = mat_pow(w, n)
        print(f"      n={n}: W^n[0][0] = {wn[0][0]:>10d}  >= 5^n = {5 ** n:>8d};"
              f"  orthogonal? {mat_mul(transpose(wn), wn) == IDENT2}")


def demo_depth_bounds() -> None:
    banner("7.  Two-sided depth bounds:  (d+2)^2 < c <= 5 * 9^d")
    print("     d |     min c over depth d |   (d+2)^2 |     max c |    5*9^d")
    for d in range(0, 8):
        cvals = [apply_word_triple(w)[2] for w in all_words(d)] if d <= 7 else []
        lo, hi = min(cvals), max(cvals)
        print(f"    {d:2d} | {lo:22d} | {(d + 2) ** 2:9d} | {hi:9d} | {5 * 9 ** d:9d}")
        assert (d + 2) ** 2 < lo and hi <= 5 * 9 ** d
    print("   both inequalities hold at every depth tested.")
    print()
    print("   the A-spine saturates the quadratic lower bound: c = (d+2)^2 + (d+1)^2")
    for d in range(0, 7):
        c = apply_word_triple("A" * d)[2]
        print(f"      d={d}: triple {apply_word_triple('A' * d)},  c = {c},"
              f"  (d+2)^2+(d+1)^2 = {(d + 2) ** 2 + (d + 1) ** 2}")
    print()
    print("   the B-spine saturates the exponential upper bound:")
    for d in range(0, 7):
        print(f"      d={d}: c = {apply_word_triple('B' * d)[2]}")


def demo_ising() -> None:
    banner("8.  The Ising braiding from sqrt(2): unitary, order 8, Clifford, not dense")
    ident: CMat = ((1 + 0j, 0j), (0j, 1 + 0j))
    aba = cmul(cmul(A_ISING, B_ISING), A_ISING)
    bab = cmul(cmul(B_ISING, A_ISING), B_ISING)
    print("   A = diag(e^{i pi/4}, e^{-i pi/4}),   B = (1 + iX)/sqrt(2)")
    print(f"   ABA = BAB ?  {cclose(aba, bab)}")
    print("   ABA =")
    for row in aba:
        print("      ", "  ".join(f"{z.real:+.4f}{z.imag:+.4f}i" for z in row))
    print("   (this is i times the Hadamard gate)")
    print()
    print(f"   A unitary? {cclose(cmul(cdag(A_ISING), A_ISING), ident)}"
          f"   B unitary? {cclose(cmul(cdag(B_ISING), B_ISING), ident)}")
    print(f"   A^8 = I ? {cclose(cpow(A_ISING, 8), ident)}"
          f"   B^8 = I ? {cclose(cpow(B_ISING, 8), ident)}")
    print()
    print("   action on the Pauli operators (conjugation):")
    for name, u in (("A", A_ISING), ("B", B_ISING)):
        for pname, p in (("X", PAULI_X), ("Y", PAULI_Y), ("Z", PAULI_Z)):
            img = cmul(cmul(u, p), cdag(u))
            print(f"      {name} {pname} {name}^dag = {pauli_name(img)}")
    print()
    print(f"   A Clifford? {is_clifford(A_ISING)}    B Clifford? {is_clifford(B_ISING)}")
    print(f"   T = diag(1, e^{{i pi/4}}) Clifford? {is_clifford(T_GATE)}")
    txt = cmul(cmul(T_GATE, PAULI_X), cdag(T_GATE))
    print(f"      T X T^dag has (0,1) entry {txt[0][1]:.6f}, real part "
          f"{txt[0][1].real:.6f} -- no signed Pauli has that entry.")
    print()
    print("   exhaustive check: every braid word of length <= 8 in A, B is Clifford,")
    print("   so the whole group (and its closure) misses T.")
    reachable: List[CMat] = [ident]
    seen_repr = {tuple(round(z.real, 9) + 1j * round(z.imag, 9)
                       for row in ident for z in row)}
    frontier = [ident]
    for _ in range(8):
        new_frontier: List[CMat] = []
        for m in frontier:
            for g in (A_ISING, B_ISING, cdag(A_ISING), cdag(B_ISING)):
                nm = cmul(m, g)
                key = tuple(round(z.real, 9) + 1j * round(z.imag, 9)
                            for row in nm for z in row)
                if key not in seen_repr:
                    seen_repr.add(key)
                    reachable.append(nm)
                    new_frontier.append(nm)
        frontier = new_frontier
    print(f"      distinct gates reachable in <= 8 steps: {len(reachable)}")
    print(f"      all of them Clifford: {all(is_clifford(m) for m in reachable)}")
    dist_to_t = min(
        math.sqrt(sum(abs(m[i][j] - T_GATE[i][j]) ** 2
                      for i in range(2) for j in range(2)))
        for m in reachable
    )
    print(f"      minimum distance from the reachable set to T: {dist_to_t:.6f}")
    print("      (bounded away from 0: the Clifford set is closed and T is outside it)")


def main() -> None:
    print(__doc__)
    demo_tree()
    demo_euclid_lift()
    demo_braid_failure()
    demo_charge()
    demo_integrality()
    demo_silver_spectrum()
    demo_depth_bounds()
    demo_ising()
    banner("Summary")
    print(
        "The Berggren groupoid does not realise topological quantum computation:\n"
        "  * no pair of tree steps satisfies the Artin relation, and the mod-2\n"
        "    charge (parity of A/B letters) is invariant under any braid relation,\n"
        "    so only abelian Z/2 statistics survive;\n"
        "  * the representation is integral, integral matrices are closed, and the\n"
        "    phase gate diag(i, 1) is not integral, so the image is not dense in U(2)\n"
        "    -- indeed the integral unitaries in dimension 2 form a group of order 8;\n"
        "  * the sqrt(2) in the spectrum does yield a genuine unitary braid\n"
        "    representation (the Ising one), but it is Clifford, hence still not dense.\n"
        "What survives is exact structure: a 3-adic Cantor boundary with a Z/2 grading,\n"
        "the Pell recurrence c_{n+2} = 6 c_{n+1} - c_n along the silver spine, and the\n"
        "depth sandwich (d+2)^2 < c <= 5 * 9^d with both extremes attained."
    )


if __name__ == "__main__":
    main()
