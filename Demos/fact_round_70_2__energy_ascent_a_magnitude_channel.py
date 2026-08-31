"""
Energy-Ascent: the Berggren branch letter is exactly a leg-ratio band.
=====================================================================

Numerical companion to the paper "A Magnitude Channel that Reads the
Berggren Branch Letter".  Everything below is self-contained: only the
Python standard library is used.

The demonstrations, in order:

  1.  The three Barning-Hall generators and their descent inverses.
  2.  BAND = LETTER.  Enumerating the tree of primitive Pythagorean
      triples and checking, for every node, that the leg-ratio band
      4a < 3b  /  3b <= 4a and 3a <= 4b  /  4b < 3a
      names exactly the last generator applied.
  3.  FULL WORD DECODING.  Iterating the band-selected descent recovers
      the entire generator word of a triple.
  4.  RESIDUE SEAL.  For each modulus M, two primitive triples that are
      componentwise congruent mod M but carry different letters.
  5.  THE FERMAT WINDOW.  The offset  s(p,q) = (p+q)/2 - sqrt(pq),  its
      two-sided bounds, its degree-one homogeneity, and the hit-rate
      table by letter.
  6.  THE MECHANISM THEOREM.  Above scale 112*W a window hit forces the
      middle band; the constant is sharp to two units (explicit witness
      at scale 110*W).
  7.  THE CEILING.  A middle-band family that no fixed window ever sees.
"""

from __future__ import annotations

from fractions import Fraction
from math import gcd
from typing import Iterator, List, Tuple

Triple = Tuple[int, int, int]

# ---------------------------------------------------------------------------
# 1.  Generators and descents
# ---------------------------------------------------------------------------

def B1(t: Triple) -> Triple:
    """First Barning-Hall generator."""
    a, b, c = t
    return (a - 2 * b + 2 * c, 2 * a - b + 2 * c, 2 * a - 2 * b + 3 * c)


def B2(t: Triple) -> Triple:
    """Second (middle) Barning-Hall generator."""
    a, b, c = t
    return (a + 2 * b + 2 * c, 2 * a + b + 2 * c, 2 * a + 2 * b + 3 * c)


def B3(t: Triple) -> Triple:
    """Third Barning-Hall generator."""
    a, b, c = t
    return (-a + 2 * b + 2 * c, -2 * a + b + 2 * c, -2 * a + 2 * b + 3 * c)


GENERATORS = (B1, B2, B3)


def invB1(t: Triple) -> Triple:
    """Descent inverting B1."""
    a, b, c = t
    return (a + 2 * b - 2 * c, -2 * a - b + 2 * c, -2 * a - 2 * b + 3 * c)


def invB2(t: Triple) -> Triple:
    """Descent inverting B2."""
    a, b, c = t
    return (a + 2 * b - 2 * c, 2 * a + b - 2 * c, -2 * a - 2 * b + 3 * c)


def invB3(t: Triple) -> Triple:
    """Descent inverting B3."""
    a, b, c = t
    return (-a - 2 * b + 2 * c, 2 * a + b - 2 * c, -2 * a - 2 * b + 3 * c)


DESCENTS = (invB1, invB2, invB3)


def is_pt(t: Triple) -> bool:
    a, b, c = t
    return a * a + b * b == c * c


def is_primitive(t: Triple) -> bool:
    a, b, _ = t
    return gcd(a, b) == 1


# ---------------------------------------------------------------------------
# 2.  The branch letter as a ratio band
# ---------------------------------------------------------------------------

def branch_letter(a: int, b: int) -> int:
    """The branch letter read off the leg ratio alone.

    0 when a/b < 3/4, 2 when a/b > 4/3, and 1 in the middle band.
    """
    if 4 * a < 3 * b:
        return 0
    if 4 * b < 3 * a:
        return 2
    return 1


def descend(t: Triple) -> Triple:
    """The descent selected by the ratio band of the legs."""
    return DESCENTS[branch_letter(t[0], t[1])](t)


def enumerate_tree(depth: int) -> Iterator[Tuple[Triple, List[int]]]:
    """Breadth-first enumeration of the tree, each node with its word.

    The word is stored leftmost-letter-last, i.e. word[0] is the last
    generator applied.
    """
    frontier: List[Tuple[Triple, List[int]]] = [((3, 4, 5), [])]
    yield frontier[0]
    for _ in range(depth):
        nxt: List[Tuple[Triple, List[int]]] = []
        for t, w in frontier:
            for i, gen in enumerate(GENERATORS):
                child = (gen(t), [i] + w)
                nxt.append(child)
                yield child
        frontier = nxt


def demo_band_equals_letter(depth: int = 9) -> None:
    print("=" * 74)
    print("2.  BAND = LETTER  (the exact control, over the whole tree)")
    print("=" * 74)
    total = mismatch = 0
    bad_pt = bad_prim = 0
    for t, w in enumerate_tree(depth):
        if not w:
            continue
        total += 1
        if branch_letter(t[0], t[1]) != w[0]:
            mismatch += 1
        if not is_pt(t):
            bad_pt += 1
        if not is_primitive(t):
            bad_prim += 1
    print(f"  nodes checked (depth <= {depth}) : {total}")
    print(f"  band != last generator letter  : {mismatch}")
    print(f"  non-Pythagorean nodes          : {bad_pt}")
    print(f"  non-primitive nodes            : {bad_prim}")
    print("  -> the letter is a deterministic function of the leg ratio.\n")

    print("  A few nodes, with exact ratio a/b and its band:")
    for t, w in list(enumerate_tree(2))[1:10]:
        r = Fraction(t[0], t[1])
        print(f"    {str(t):>22}   a/b = {str(r):>9} = {float(r):.4f}"
              f"   letter {branch_letter(t[0], t[1])}   word {w}")
    print()


def demo_ratio_invariance() -> None:
    print("=" * 74)
    print("2b. THE LETTER IS A FUNCTION OF THE RATIO ONLY")
    print("=" * 74)
    for (a, b) in [(3, 4), (20, 21), (5, 12), (8, 15)]:
        letters = {branch_letter(k * a, k * b) for k in (1, 2, 7, 1000, 10**6)}
        print(f"    legs proportional to ({a},{b}): letters over scalings = {letters}")
    print("  -> scaling the legs never changes the letter.\n")


# ---------------------------------------------------------------------------
# 3.  Full word decoding
# ---------------------------------------------------------------------------

def apply_word(word: List[int], t: Triple = (3, 4, 5)) -> Triple:
    """Apply a generator word, leftmost letter last."""
    for i in reversed(word):
        t = GENERATORS[i](t)
    return t


def read_word(n: int, t: Triple) -> List[int]:
    """Read n letters by iterating the band-selected descent."""
    out: List[int] = []
    for _ in range(n):
        out.append(branch_letter(t[0], t[1]))
        t = descend(t)
    return out


def demo_word_decoding(trials: int = 20000, max_len: int = 14,
                       seed: int = 20260823) -> None:
    import random
    print("=" * 74)
    print("3.  FULL WORD DECODING")
    print("=" * 74)
    rng = random.Random(seed)
    ok = 0
    root_ok = 0
    for _ in range(trials):
        n = rng.randint(1, max_len)
        w = [rng.randrange(3) for _ in range(n)]
        t = apply_word(w)
        if read_word(n, t) == w:
            ok += 1
        s = t
        for _ in range(n):
            s = descend(s)
        if s == (3, 4, 5):
            root_ok += 1
    print(f"  random words decoded exactly : {ok}/{trials}")
    print(f"  descents landing on (3,4,5)  : {root_ok}/{trials}")
    w = [1, 0, 2, 2, 1, 0]
    t = apply_word(w)
    print(f"\n  example word {w}")
    print(f"    triple  {t}")
    print(f"    decoded {read_word(len(w), t)}")
    print("  -> three linear comparisons per level recover the whole word.\n")


# ---------------------------------------------------------------------------
# 4.  The residue seal
# ---------------------------------------------------------------------------

def fam(m: int) -> Triple:
    """The family (m^2 - 1, 2m, m^2 + 1); primitive when m is even."""
    return (m * m - 1, 2 * m, m * m + 1)


def demo_residue_seal(moduli: Tuple[int, ...] = (3, 9, 27, 81, 16, 105)) -> None:
    print("=" * 74)
    print("4.  RESIDUE SEAL: congruent triples with different letters")
    print("=" * 74)
    print(f"  {'M':>5}  {'witness (m^2-1, 2m, m^2+1)':>34}  {'letters':>9}  cong?")
    for M in moduli:
        m = 2 + 2 * M
        t = fam(m)
        cong = all((x - y) % M == 0 for x, y in zip(t, (3, 4, 5)))
        l0 = branch_letter(3, 4)
        l1 = branch_letter(t[0], t[1])
        assert is_pt(t) and is_primitive(t) and cong and l0 != l1
        print(f"  {M:>5}  {str(t):>34}  {l0} vs {l1}    {cong}")
    print("  -> no congruence datum of any modulus predicts the letter.\n")


# ---------------------------------------------------------------------------
# 5.  The Fermat window
# ---------------------------------------------------------------------------

def fermat_offset(p: int, q: int) -> float:
    """s(p,q) = (p+q)/2 - sqrt(pq): distance from sqrt(N) to the crossing."""
    from math import sqrt
    return (p + q) / 2.0 - sqrt(float(p) * float(q))


def offset_bounds(p: int, q: int) -> Tuple[float, float]:
    """The proved two-sided bounds on the Fermat offset."""
    from math import sqrt
    lo = (q - p) ** 2 / (4.0 * (p + q))
    hi = (q - p) ** 2 / (8.0 * sqrt(float(p) * float(q)))
    return lo, hi


def in_window(p: int, q: int, W: int) -> bool:
    """Exact integer test for s(p,q) <= W (no floating point)."""
    # s <= W  <=>  (p+q)/2 - W <= sqrt(pq); handle the sign of the left side.
    lhs2 = p + q - 2 * W          # 2*((p+q)/2 - W)
    if lhs2 <= 0:
        return True
    return lhs2 * lhs2 <= 4 * p * q


def demo_window_geometry() -> None:
    print("=" * 74)
    print("5.  THE FERMAT WINDOW AS A POSITIONAL SENSOR")
    print("=" * 74)
    print("  offset bounds  (q-p)^2/(4(p+q))  <=  s  <=  (q-p)^2/(8 sqrt(pq))")
    print(f"  {'(p,q)':>20} {'lower':>14} {'offset s':>14} {'upper':>14}")
    for (p, q) in [(3, 4), (20, 21), (119, 120), (696, 697), (5, 12), (9, 40)]:
        lo, hi = offset_bounds(p, q)
        s = fermat_offset(p, q)
        assert lo - 1e-9 <= s <= hi + 1e-9
        print(f"  {str((p, q)):>20} {lo:>14.6f} {s:>14.6f} {hi:>14.6f}")

    print("\n  degree-one homogeneity: s(l*p, l*q) = l*s(p,q)")
    for l in (1, 3, 10, 1000):
        print(f"    l = {l:>5}:  s = {fermat_offset(l * 20, l * 21):.6f}"
              f"   l*s(20,21) = {l * fermat_offset(20, 21):.6f}")
    print("  -> the *relative* offset depends only on the ratio q/p.\n")


def demo_hit_rate_table(depth: int = 12, windows: Tuple[int, ...] = (1, 16, 4096)) -> None:
    print("=" * 74)
    print("5b. HIT RATE BY LETTER, in the regime q >= 112*W")
    print("=" * 74)
    nodes = [t for t, w in enumerate_tree(depth) if w]
    print(f"  {'W':>6} | {'letter 0':>9} {'letter 1':>9} {'letter 2':>9}   (sample sizes)")
    for W in windows:
        hits = [0, 0, 0]
        tot = [0, 0, 0]
        for (a, b, c) in nodes:
            p, q = (a, b) if a <= b else (b, a)
            if q < 112 * W:
                continue
            L = branch_letter(a, b)
            tot[L] += 1
            if in_window(p, q, W):
                hits[L] += 1
        rates = [hits[i] / tot[i] if tot[i] else float("nan") for i in range(3)]
        print(f"  {W:>6} | {rates[0]:>9.3f} {rates[1]:>9.3f} {rates[2]:>9.3f}   {tuple(tot)}")
    print("  -> the two outer columns are exact zeros: that is the mechanism theorem.")
    print("     The middle column stays bounded away from 1: that is the ceiling.\n")


# ---------------------------------------------------------------------------
# 6.  The mechanism theorem and its sharp constant
# ---------------------------------------------------------------------------

def demo_mechanism_and_sharpness() -> None:
    print("=" * 74)
    print("6.  MECHANISM: a hit above scale 112*W forces the middle band")
    print("=" * 74)
    nodes = [t for t, w in enumerate_tree(12) if w]
    violations = 0
    checked = 0
    for W in (1, 4, 16, 256, 4096):
        for (a, b, c) in nodes:
            p, q = (a, b) if a <= b else (b, a)
            if q < 112 * W:
                continue
            if in_window(p, q, W):
                checked += 1
                if branch_letter(a, b) != 1:
                    violations += 1
    print(f"  hits above threshold examined : {checked}")
    print(f"  hits with a non-middle letter : {violations}")

    p, q, c, W = 752604, 1004653, 1255285, 9133
    print("\n  Sharpness witness (scale 110*W, letter 0, yet a genuine hit):")
    print(f"    triple ({p}, {q}, {c}),  W = {W}")
    print(f"    Pythagorean : {is_pt((p, q, c))}")
    print(f"    primitive   : {is_primitive((p, q, c))}")
    print(f"    scale q/W   : {q / W:.4f}   (>= 110)")
    print(f"    offset s    : {fermat_offset(p, q):.4f}   <= W = {W}: "
          f"{in_window(p, q, W)}")
    print(f"    letter      : {branch_letter(p, q)}   (not the middle letter)")
    print("  -> no threshold <= 110*W can work; the constant 112 is sharp to two units.\n")


# ---------------------------------------------------------------------------
# 7.  Spine and ceiling
# ---------------------------------------------------------------------------

def spine(n: int) -> Triple:
    """The B2-spine: iterate the middle generator from the root."""
    t = (3, 4, 5)
    for _ in range(n):
        t = B2(t)
    return t


def noisy(k: int) -> Triple:
    """A middle-band family whose leg gap grows like k^2."""
    return (20 * k * k + 4 * k, 21 * k * k + 10 * k + 1, 29 * k * k + 10 * k + 1)


def demo_spine_and_ceiling() -> None:
    print("=" * 74)
    print("7.  THE SPINE (always seen) AND THE CEILING (never seen)")
    print("=" * 74)
    print("  B2-spine: legs differ by 1, so every member is a W = 1 hit.")
    print(f"  {'n':>3} {'triple':>34} {'gap':>5} {'offset':>12} {'W=1 hit':>8}")
    for n in range(6):
        a, b, c = spine(n)
        p, q = (a, b) if a <= b else (b, a)
        print(f"  {n:>3} {str((a, b, c)):>34} {abs(a - b):>5} "
              f"{fermat_offset(p, q):>12.6f} {str(in_window(p, q, 1)):>8}")

    print("\n  The 'noisy' family: middle band forever, but leg gap ~ k^2.")
    print(f"  {'k':>4} {'triple':>40} {'letter':>7} {'offset':>12} {'W=1 hit':>8}")
    for k in (2, 4, 8, 16, 32):
        a, b, c = noisy(k)
        assert is_pt((a, b, c))
        print(f"  {k:>4} {str((a, b, c)):>40} {branch_letter(a, b):>7} "
              f"{fermat_offset(a, b):>12.4f} {str(in_window(a, b, 1)):>8}")
    print("  -> the letter never determines the window bit: the channel is one-way.\n")


def demo_dependence_inequality(depth: int = 11, W: int = 4096) -> None:
    print("=" * 74)
    print("8.  POSITIVE DEPENDENCE, in exact counting form")
    print("=" * 74)
    fam_ = []
    for t, w in enumerate_tree(depth):
        if not w:
            continue
        a, b, c = t
        p, q = (a, b) if a <= b else (b, a)
        if q < 112 * W:
            continue
        fam_.append((p, q, branch_letter(a, b), in_window(p, q, W)))
    n = len(fam_)
    n_letter = sum(1 for *_, L, h in fam_ if L == 1)
    n_hit = sum(1 for *_, L, h in fam_ if h)
    n_both = sum(1 for *_, L, h in fam_ if h and L == 1)
    print(f"  family size            |F| = {n}")
    print(f"  letter-1 count               = {n_letter}")
    print(f"  hit count                    = {n_hit}")
    print(f"  hit AND letter-1 count       = {n_both}")
    print(f"  claim: (letter)(hit) < (both)(|F|)")
    print(f"         {n_letter * n_hit} < {n_both * n}   -> "
          f"{n_letter * n_hit < n_both * n}")
    if n and n_hit:
        print(f"  P(letter=1)        = {n_letter / n:.4f}")
        print(f"  P(letter=1 | hit)  = {n_both / n_hit:.4f}")
    print("  -> conditioning on a hit strictly raises the letter-1 frequency.\n")


def main() -> None:
    print("\nENERGY-ASCENT: a magnitude channel that reads the Berggren letter\n")
    demo_band_equals_letter()
    demo_ratio_invariance()
    demo_word_decoding()
    demo_residue_seal()
    demo_window_geometry()
    demo_hit_rate_table()
    demo_mechanism_and_sharpness()
    demo_spine_and_ceiling()
    demo_dependence_inequality()
    print("All demonstrations completed.")


if __name__ == "__main__":
    main()
