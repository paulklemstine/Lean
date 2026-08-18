"""
Seed-compressible Pythagorean data: fingerprinting, routing, seed recovery.

A self-contained numerical demonstration of the results on generator-produced
streams of Pythagorean triples under the three Barning-Berggren moves

    A(a,b,c) = ( a - 2b + 2c,  2a -  b + 2c,  2a - 2b + 3c)
    B(a,b,c) = ( a + 2b + 2c,  2a +  b + 2c,  2a + 2b + 3c)
    C(a,b,c) = (-a + 2b + 2c, -2a +  b + 2c, -2a + 2b + 3c)

Everything below runs on exact integer arithmetic; no external dependencies.

Demonstrated results
--------------------
1. Universal order-3 fingerprint (Cayley-Hamilton): every linear readout of an
   orbit obeys y(t+3) = tr(M) y(t+2) - c2(M) y(t+1) + det(M) y(t).
   Taps (1,-3,3) on the unipotent branches A, C; (-1,5,5) on the Pell branch B.
2. Sharpness: linear complexity of the hypotenuse stream is 3 on A and C, 2 on B.
3. Exact reproduction: three observed symbols regenerate the whole stream.
4. Conserved branch signatures: c-b frozen on A, c-a frozen on C, |b-a| on B.
5. Sound/complete/exact transition classifier.
6. Coverage: every normalised primitive triple is generator output, for exactly
   one control word; the sign-test decoder recovers it and replay reproduces it.
7. Rarity: the reach of the seed compressor from a bounded seed box is bounded
   independently of the file length.
8. Rate dichotomy: 5*3^k <= hyp(B^k) but hyp(A^k) = 2k^2+6k+5 <= 2(k+2)^2;
   and hyp(path(w)) <= 5*7^|w| for every control word.
"""

from __future__ import annotations

from fractions import Fraction
from itertools import product
from math import gcd
from typing import Dict, List, Optional, Sequence, Tuple

Triple = Tuple[int, int, int]
Matrix = Tuple[Tuple[int, int, int], ...]

ROOT: Triple = (3, 4, 5)

MAT: Dict[str, Matrix] = {
    "A": ((1, -2, 2), (2, -1, 2), (2, -2, 3)),
    "B": ((1, 2, 2), (2, 1, 2), (2, 2, 3)),
    "C": ((-1, 2, 2), (-2, 1, 2), (-2, 2, 3)),
}


# ----------------------------------------------------------------------------
# Basic linear algebra on 3x3 integer matrices
# ----------------------------------------------------------------------------
def apply_matrix(m: Matrix, p: Triple) -> Triple:
    """Matrix-vector product on a triple."""
    return tuple(m[i][0] * p[0] + m[i][1] * p[1] + m[i][2] * p[2] for i in range(3))  # type: ignore[return-value]


def step(s: str, p: Triple) -> Triple:
    """Apply one Berggren control symbol."""
    return apply_matrix(MAT[s], p)


def apply_word(w: str, p: Triple = ROOT) -> Triple:
    """Apply a whole control word, left to right, starting from p."""
    for s in w:
        p = step(s, p)
    return p


def orbit(s: str, p: Triple, n: int) -> List[Triple]:
    """The first n states of the orbit of a fixed move from seed p."""
    out = [p]
    for _ in range(n - 1):
        out.append(step(s, out[-1]))
    return out


def trace(m: Matrix) -> int:
    return m[0][0] + m[1][1] + m[2][2]


def det3(m: Matrix) -> int:
    return (
        m[0][0] * (m[1][1] * m[2][2] - m[1][2] * m[2][1])
        - m[0][1] * (m[1][0] * m[2][2] - m[1][2] * m[2][0])
        + m[0][2] * (m[1][0] * m[2][1] - m[1][1] * m[2][0])
    )


def c2(m: Matrix) -> int:
    """Sum of the principal 2x2 minors."""
    return (
        (m[0][0] * m[1][1] - m[0][1] * m[1][0])
        + (m[0][0] * m[2][2] - m[0][2] * m[2][0])
        + (m[1][1] * m[2][2] - m[1][2] * m[2][1])
    )


def char_taps(m: Matrix) -> Tuple[int, int, int]:
    """Order-3 LFSR taps (tau0, tau1, tau2) predicted by Cayley-Hamilton."""
    return (det3(m), -c2(m), trace(m))


def is_pythagorean(p: Triple) -> bool:
    return p[0] ** 2 + p[1] ** 2 == p[2] ** 2


# ----------------------------------------------------------------------------
# Fingerprinting
# ----------------------------------------------------------------------------
def readout(stream: Sequence[Triple], u: Tuple[int, int, int]) -> List[int]:
    """A linear observation u.(a,b,c) of a stream of triples."""
    return [u[0] * p[0] + u[1] * p[1] + u[2] * p[2] for p in stream]


def satisfies_taps(y: Sequence[int], taps: Sequence[int]) -> bool:
    """Check y(t+d) = sum_i taps[i] y(t+i) over all available windows."""
    d = len(taps)
    return all(
        y[t + d] == sum(taps[i] * y[t + i] for i in range(d))
        for t in range(len(y) - d)
    )


def minimal_recurrence(y: Sequence[int], max_order: int = 6) -> Optional[Tuple[int, Tuple[Fraction, ...]]]:
    """Shortest linear recurrence fitting y exactly (exact rational Gaussian
    elimination; the role played by Berlekamp-Massey over a field)."""
    for d in range(0, max_order + 1):
        rows = len(y) - d
        if rows < d + 1:            # need strictly more equations than unknowns
            return None
        a = [[Fraction(y[t + i]) for i in range(d)] + [Fraction(y[t + d])] for t in range(rows)]
        sol = _solve_exact(a, d)
        if sol is not None:
            return d, sol
    return None


def _solve_exact(aug: List[List[Fraction]], nvars: int) -> Optional[Tuple[Fraction, ...]]:
    """Solve an over-determined exact linear system, or return None."""
    rows = [r[:] for r in aug]
    pivots: List[int] = []
    r = 0
    for col in range(nvars):
        piv = next((i for i in range(r, len(rows)) if rows[i][col] != 0), None)
        if piv is None:
            continue
        rows[r], rows[piv] = rows[piv], rows[r]
        pv = rows[r][col]
        rows[r] = [x / pv for x in rows[r]]
        for i in range(len(rows)):
            if i != r and rows[i][col] != 0:
                f = rows[i][col]
                rows[i] = [x - f * yv for x, yv in zip(rows[i], rows[r])]
        pivots.append(col)
        r += 1
    for i in range(r, len(rows)):
        if rows[i][nvars] != 0:
            return None                       # inconsistent: no such recurrence
    if len(pivots) < nvars:
        return None                           # under-determined: refuse to guess
    sol = [Fraction(0)] * nvars
    for i, col in enumerate(pivots):
        sol[col] = rows[i][nvars]
    return tuple(sol)


def lfsr_replay(seed: Sequence[int], taps: Sequence[int], n: int) -> List[int]:
    """Regenerate n symbols from the d-symbol seed and the taps."""
    y = list(seed)
    while len(y) < n:
        y.append(sum(taps[i] * y[len(y) - len(taps) + i] for i in range(len(taps))))
    return y[:n]


# ----------------------------------------------------------------------------
# Routing
# ----------------------------------------------------------------------------
def which_move(p: Triple, q: Triple) -> Optional[str]:
    """The transition classifier: sound, complete, exact on positive legs."""
    for s in ("A", "B", "C"):
        if step(s, p) == q:
            return s
    return None


def branch_invariants(stream: Sequence[Triple]) -> Dict[str, bool]:
    """Cheap conserved-quantity probe: which branch is admissible?"""
    cb = {p[2] - p[1] for p in stream}
    ca = {p[2] - p[0] for p in stream}
    ba = {abs(p[1] - p[0]) for p in stream}
    return {"A": len(cb) == 1, "C": len(ca) == 1, "B": len(ba) == 1}


def classify_stream(stream: Sequence[Triple]) -> Optional[str]:
    """Route a stream: the unique branch explaining every transition, if any."""
    if len(stream) < 2:
        return None
    labels = {which_move(stream[t], stream[t + 1]) for t in range(len(stream) - 1)}
    return labels.pop() if len(labels) == 1 and None not in labels else None


# ----------------------------------------------------------------------------
# Seed recovery for the full ternary code
# ----------------------------------------------------------------------------
def _minor(m: Matrix, row: int, col: int) -> int:
    """Determinant of the 2x2 matrix obtained by deleting a row and a column."""
    rs = [i for i in range(3) if i != row]
    cs = [j for j in range(3) if j != col]
    return m[rs[0]][cs[0]] * m[rs[1]][cs[1]] - m[rs[0]][cs[1]] * m[rs[1]][cs[0]]


def inverse3(m: Matrix) -> Matrix:
    """Exact inverse of a unimodular integer 3x3 matrix (adjugate / determinant)."""
    d = det3(m)
    return tuple(  # type: ignore[return-value]
        tuple(((-1) ** (i + j)) * _minor(m, j, i) // d for j in range(3)) for i in range(3)
    )


INV: Dict[str, Matrix] = {s: inverse3(MAT[s]) for s in MAT}


def parent_step(q: Triple) -> Optional[str]:
    """Three sign tests: which control symbol produced q?"""
    for s in ("A", "B", "C"):
        r = apply_matrix(INV[s], q)
        if r[0] > 0 and r[1] > 0:
            return s
    return None


def decode_seed(q: Triple, fuel: int = 10_000) -> str:
    """Peel control symbols off an observed triple until reaching the root."""
    word: List[str] = []
    while fuel > 0 and q != ROOT:
        s = parent_step(q)
        if s is None:
            break
        word.append(s)
        q = apply_matrix(INV[s], q)
        fuel -= 1
    return "".join(reversed(word))


def is_tree_triple(p: Triple) -> bool:
    a, b, c = p
    return is_pythagorean(p) and a > 0 and b > 0 and gcd(a, b) == 1 and a % 2 == 1


def all_tree_triples(limit: int) -> List[Triple]:
    """Brute-force enumeration of normalised primitive triples with c <= limit."""
    out = []
    for c in range(1, limit + 1):
        for a in range(1, c):
            bb = c * c - a * a
            b = int(round(bb ** 0.5))
            if b * b == bb and b > 0 and is_tree_triple((a, b, c)):
                out.append((a, b, c))
    return out


# ----------------------------------------------------------------------------
# Demonstrations
# ----------------------------------------------------------------------------
def banner(title: str) -> None:
    print("\n" + "=" * 74)
    print(title)
    print("=" * 74)


def demo_taps() -> None:
    banner("1. Characteristic data of the three generators -> LFSR taps")
    for s in ("A", "B", "C"):
        m = MAT[s]
        print(f"  branch {s}:  tr = {trace(m):>2}   c2 = {c2(m):>3}   det = {det3(m):>2}"
              f"   =>  taps (tau0,tau1,tau2) = {char_taps(m)}")
    print("  characteristic polynomials: A, C -> (x-1)^3 ;  B -> (x+1)(x^2-6x+1)")


def demo_fingerprint() -> None:
    banner("2. Every linear readout of every orbit obeys the predicted taps")
    observables = [(1, 0, 0), (0, 1, 0), (0, 0, 1), (1, 1, 1), (3, -7, 5)]
    seeds = [ROOT, (5, 12, 13), (20, 21, 29), (8, 15, 17)]
    for s in ("A", "B", "C"):
        taps = char_taps(MAT[s])
        ok = all(
            satisfies_taps(readout(orbit(s, p, 12), u), taps)
            for u in observables
            for p in seeds
        )
        print(f"  branch {s}: taps {taps} hold for {len(observables)} observables "
              f"x {len(seeds)} seeds -> {ok}")


def demo_orbits() -> None:
    banner("3. Closed forms and the two growth regimes")
    for s in ("A", "B", "C"):
        o = orbit(s, ROOT, 6)
        print(f"  {s}-orbit from (3,4,5): " + "  ".join(str(p) for p in o))
    print("\n  A-branch predicted (2t+3, 2t^2+6t+4, 2t^2+6t+5):",
          [(2 * t + 3, 2 * t * t + 6 * t + 4, 2 * t * t + 6 * t + 5) for t in range(6)]
          == orbit("A", ROOT, 6))
    print("  C-branch predicted (4t^2+8t+3, 4t+4, 4t^2+8t+5):     ",
          [(4 * t * t + 8 * t + 3, 4 * t + 4, 4 * t * t + 8 * t + 5) for t in range(6)]
          == orbit("C", ROOT, 6))
    hyp_b = [p[2] for p in orbit("B", ROOT, 8)]
    print("  B-branch hypotenuses:", hyp_b)
    print("  Pell recurrence c(t+2) = 6c(t+1) - c(t):",
          satisfies_taps(hyp_b, (-1, 6)))
    print("  ratios ->", [round(hyp_b[i + 1] / hyp_b[i], 4) for i in range(4)],
          " (limit 3 + 2*sqrt(2) = 5.8284)")


def demo_complexity() -> None:
    banner("4. Sharpness: linear complexity is a branch classifier")
    for s in ("A", "B", "C"):
        y = [p[2] for p in orbit(s, ROOT, 12)]
        res = minimal_recurrence(y)
        assert res is not None
        d, coeffs = res
        pretty = tuple(int(x) if x.denominator == 1 else x for x in coeffs)
        print(f"  branch {s}: hypotenuse stream {y[:5]}...  minimal order = {d}, "
              f"coefficients {pretty}")
    print("  => complexity 3 on the unipotent branches A, C;  2 on the Pell branch B")


def demo_exact_reproduction() -> None:
    banner("5. Exact reproduction: three symbols regenerate the whole stream")
    n = 30
    for s in ("A", "B", "C"):
        taps = char_taps(MAT[s])
        y = readout(orbit(s, (20, 21, 29), n), (2, -1, 4))
        replay = lfsr_replay(y[:3], taps, n)
        print(f"  branch {s}: seed {y[:3]} + taps {taps} reproduces {n} symbols "
              f"exactly -> {replay == y}")
        print(f"            file = {n} integers up to {max(abs(v) for v in y)}, "
              f"seed = 3 integers + 2-bit label")


def demo_invariants_and_routing() -> None:
    banner("6. Conserved signatures and the transition classifier")
    for s in ("A", "B", "C"):
        st = orbit(s, ROOT, 8)
        inv = branch_invariants(st)
        print(f"  {s}-orbit: admissible branches by invariant probe = "
              f"{[k for k, v in inv.items() if v]};  classifier says {classify_stream(st)}")
    print("\n  Separation on a positive-leg triple p = (3,4,5):")
    print(f"    Ap = {step('A', ROOT)}, Bp = {step('B', ROOT)}, Cp = {step('C', ROOT)}"
          f"  pairwise distinct -> {len({step(s, ROOT) for s in 'ABC'}) == 3}")
    print("\n  Negative benchmark items:")
    const = [ROOT] * 5
    print(f"    constant stream (3,4,5)^5 is an orbit? {classify_stream(const)}")
    parents = [p for p in all_tree_triples(60) if any(step(s, p) == (6, 8, 10) for s in "ABC")]
    brute = [
        p for p in product(range(1, 40), repeat=3)
        if p[0] > 0 and p[1] > 0 and any(step(s, p) == (6, 8, 10) for s in "ABC")
    ]
    print(f"    positive-leg parents of (6,8,10) found by brute force: {brute or 'none'}"
          f"  (tree-triple parents: {parents or 'none'})")
    print("    => (6,8,10) has no admissible parent: the control-word code cannot reach it")


def demo_coverage_and_decoder() -> None:
    banner("7. Coverage: every normalised primitive triple is generator output")
    triples = all_tree_triples(200)
    ok, worst = True, (0, "")
    for p in triples:
        w = decode_seed(p)
        if apply_word(w) != p:
            ok = False
        if len(w) > worst[0]:
            worst = (len(w), w)
    print(f"  normalised primitive triples with c <= 200: {len(triples)}")
    print(f"  decoded and replayed exactly for all of them: {ok}")
    print(f"  longest recovered control word: '{worst[1]}' (length {worst[0]})")
    print("\n  examples (triple -> control word -> replay):")
    for p in triples[:8]:
        w = decode_seed(p)
        print(f"    {str(p):>16} -> '{w or 'epsilon':<6}' -> {apply_word(w)}"
              f"   |w| <= (c-5)/4 = {(p[2] - 5) // 4}: {len(w) <= (p[2] - 5) / 4}")
    words = ["", "A", "B", "C", "AB", "BA", "CBA", "ABCABC", "BBB", "AAA"]
    images = [apply_word(w) for w in words]
    print(f"\n  unique decodability on {len(words)} sample words: "
          f"{len(set(images)) == len(words)}")


def demo_rarity() -> None:
    banner("8. Rarity: the reach of the seed compressor does not grow with n")
    for N in (1, 2, 3):
        box = [p for p in product(range(-N, N + 1), repeat=3)]
        for n in (2, 3, 4):
            reach = {tuple(orbit(s, p, n)) for s in "ABC" for p in box}
            total = len(box) ** n
            print(f"  N={N}, n={n}: |reach| = {len(reach):>6} <= 3(2N+1)^3 = "
                  f"{3 * (2 * N + 1) ** 3:>6};   candidate files = {total:>10}"
                  f";   covered fraction = {len(reach) / total:.3e}")
    print("  the bound 3(2N+1)^3 is independent of n, while the candidate count "
          "grows like ((2N+1)^3)^n")


def demo_rate_dichotomy() -> None:
    banner("9. Rate dichotomy: identical detectability, opposite profitability")
    print("   k |        hyp(B^k) |  5*3^k |  hyp(A^k) | 2(k+2)^2 | bits(hyp) | seed bits")
    print("  ---+-----------------+--------+-----------+----------+-----------+-----------")
    for k in range(0, 11):
        hb = apply_word("B" * k)[2]
        ha = apply_word("A" * k)[2]
        seed_bits = round(k * 1.585)          # k ternary symbols
        print(f"  {k:>2} | {hb:>15} | {5 * 3 ** k:>6} | {ha:>9} | {2 * (k + 2) ** 2:>8} |"
              f" {hb.bit_length():>9} | {seed_bits:>9}")
    print("\n  B-branch: seed is logarithmic in the data  -> genuine compression")
    print("  A-branch: hyp(A^k) = 2k^2+6k+5, so |seed| ~ sqrt(c/2) -> expansion")
    ok = all(apply_word(w)[2] <= 5 * 7 ** len(w)
             for L in range(6) for w in map("".join, product("ABC", repeat=L)))
    print(f"  universal ceiling hyp(path(w)) <= 5*7^|w| over all words of length <= 5: {ok}")
    lo = all(5 * 3 ** k <= apply_word("B" * k)[2] for k in range(15))
    print(f"  Pell lower bound 5*3^k <= hyp(B^k) for k <= 14: {lo}")


def demo_end_to_end() -> None:
    banner("10. End-to-end: compress, decompress, verify bit-for-bit")
    files = {
        "A-orbit x 50 from (3,4,5)": orbit("A", ROOT, 50),
        "B-orbit x 20 from (3,4,5)": orbit("B", ROOT, 20),
        "C-orbit x 50 from (8,15,17)": orbit("C", (8, 15, 17), 50),
        "constant stream x 50": [ROOT] * 50,
        "table of primitive triples": all_tree_triples(60),
    }
    for name, f in files.items():
        s = classify_stream(f)
        if s is None:
            print(f"  {name:<30} -> model-compressible (no generator explains it)")
            continue
        seed = f[0]
        replay = orbit(s, seed, len(f))
        raw_bits = sum(max(1, x.bit_length()) for p in f for x in p)
        seed_bits = sum(max(1, x.bit_length()) for x in seed) + 2
        print(f"  {name:<30} -> seed-compressible: branch {s}, seed {seed}, "
              f"exact replay {replay == f}, {raw_bits} bits -> {seed_bits} bits "
              f"(x{raw_bits / seed_bits:.1f})")


def main() -> None:
    print(__doc__)
    demo_taps()
    demo_fingerprint()
    demo_orbits()
    demo_complexity()
    demo_exact_reproduction()
    demo_invariants_and_routing()
    demo_coverage_and_decoder()
    demo_rarity()
    demo_rate_dichotomy()
    demo_end_to_end()
    print("\nAll demonstrations completed.\n")


if __name__ == "__main__":
    main()
