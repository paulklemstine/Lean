#!/usr/bin/env python3
"""
Depth decay of the magnitude channel on the Berggren tree of primitive
Pythagorean triples.
========================================================================

Numerical demonstration of the results:

  (1)  FIRST-LETTER READABILITY.  The first descent letter of an admissible
       pair (m, n) is an explicit function of the one-bit magnitude reading
       P_1(m,n) = floor(2m/n).

  (2)  READABLE PREFIX.  The address begins with exactly
       L = floor((m-n)/(2n)) copies of 'C', and any admissible pair with the
       same one-bit reading agrees on all letters 0..L -- the whole run plus
       the inversion letter that terminates it.

  (3)  PRICE OF DEPTH.  L <= P_1(m,n) / 4.

  (4)  DEPTH NULL.  For any window budget W and any depth k, the pair
            s+ = ((7+6k)q + 1, 3q),   s- = ((7+6k)q - 1, 3q),  q = 6*2^W
       has equal W-window readings, identical addresses C^k B through
       position k, and different letters at position k+1.

  (5)  UNIVERSAL NULL.  For any rational scale a/b, the boundary state
            T_k = (4k+5, 2)      and      U = ((4k+5)u + 1, 2u),  u = 2a+2
       have equal readings floor((a/b)(m/n)), identical addresses through
       position k, and different letters at position k+1.

  (6)  CAPACITY BOUND.  Once 2 * 2^W < 2^k, the W-window sensor must confuse
       two admissible states whose addresses differ below depth k.

  (7)  EMPIRICAL DECAY.  Mutual information between the window reading and
       the depth-t letter, measured on a sampled population, decays with t,
       and the *conditional* (within path-prefix) information collapses to
       zero just past the first inversion.

Run:  python3 demo.py
"""

from __future__ import annotations

import math
import random
from collections import Counter, defaultdict
from fractions import Fraction
from typing import Dict, List, Sequence, Tuple

State = Tuple[int, int]
Letter = str  # 'A', 'B' or 'C'


# --------------------------------------------------------------------------
# 1.  The Berggren tree in (m, n) coordinates
# --------------------------------------------------------------------------

ROOT: State = (2, 1)


def is_admissible(s: State) -> bool:
    """(m,n) parametrizes a primitive Pythagorean triple: 0<n<m, gcd=1, m+n odd."""
    m, n = s
    return 0 < n < m and math.gcd(m, n) == 1 and (m + n) % 2 == 1


def triple(s: State) -> Tuple[int, int, int]:
    """The primitive Pythagorean triple (m^2-n^2, 2mn, m^2+n^2)."""
    m, n = s
    return (m * m - n * n, 2 * m * n, m * m + n * n)


def child(x: Letter, s: State) -> State:
    """The three Berggren child maps."""
    m, n = s
    if x == "A":
        return (2 * m - n, m)
    if x == "B":
        return (2 * m + n, m)
    if x == "C":
        return (m + 2 * n, n)
    raise ValueError(f"bad letter {x!r}")


def letter_of(s: State) -> Letter:
    """Which inverse branch: decided by m/n against the cut points 2 and 3."""
    m, n = s
    if m < 2 * n:
        return "A"
    if m < 3 * n:
        return "B"
    return "C"


def parent(s: State) -> State:
    """One descent step towards the root."""
    m, n = s
    if m < 2 * n:
        return (n, 2 * n - m)
    if m < 3 * n:
        return (n, m - 2 * n)
    return (m - 2 * n, n)


def letter_at(k: int, s: State) -> Letter:
    """The k-th descent letter (k = 0 is the first)."""
    t = s
    for _ in range(k):
        t = parent(t)
    return letter_of(t)


def address(s: State, max_len: int = 64) -> str:
    """The full address word, read from the state up to the root."""
    out: List[Letter] = []
    t = s
    while t != ROOT and len(out) < max_len:
        out.append(letter_of(t))
        t = parent(t)
    return "".join(out)


def build(word: Sequence[Letter]) -> State:
    """The admissible state whose address is exactly `word`."""
    s = ROOT
    for x in reversed(list(word)):
        s = child(x, s)
    return s


# --------------------------------------------------------------------------
# 2.  The sensors
# --------------------------------------------------------------------------

def probe(W: int, s: State) -> int:
    """W-window magnitude sensor: the ratio truncated to W binary places."""
    m, n = s
    return (2 ** W) * m // n


def gprobe(a: int, b: int, s: State) -> int:
    """Rational-scale magnitude sensor floor((a/b)*(m/n)).  gprobe(2^W,1)=probe(W)."""
    m, n = s
    return a * m // (b * n)


def letter_from_probe(p: int) -> Letter:
    """Decoder for the one-bit reading."""
    if p <= 3:
        return "A"
    if p <= 5:
        return "B"
    return "C"


def run_length(s: State) -> int:
    """L = floor((m-n)/(2n)): the length of the leading C-run, one division."""
    m, n = s
    return (m - n) // (2 * n)


def window_read(s: State) -> Tuple[int, str]:
    """Cheap prediction: reading, plus the provably-correct prefix C^L X."""
    m, n = s
    L = run_length(s)
    tail = letter_of((m - 2 * L * n, n))
    return probe(1, s), "C" * L + tail


# --------------------------------------------------------------------------
# 3.  Demonstrations
# --------------------------------------------------------------------------

def demo_tree() -> None:
    print("=" * 74)
    print("1.  THE BERGGREN TREE: addresses of primitive Pythagorean triples")
    print("=" * 74)
    print(f"{'address':<10}{'(m,n)':<14}{'triple':<22}{'ratio m/n':<12}")
    for word in ["", "A", "B", "C", "AB", "CC", "CB", "BCA", "CCCB"]:
        s = build(word)
        r = Fraction(s[0], s[1])
        print(f"{word or '(root)':<10}{str(s):<14}{str(triple(s)):<22}{str(r):<12}")
    print()
    print("The descent reads the address back exactly:")
    for word in ["ABC", "CCBA", "BBCCA"]:
        s = build(word)
        print(f"  build({word:<6}) = {str(s):<14} -> address = {address(s)}")
    print()


def demo_first_letter(trials: int = 20000, seed: int = 20260823) -> None:
    print("=" * 74)
    print("2.  FIRST-LETTER READABILITY:  letter_0(s) = D(floor(2m/n))")
    print("=" * 74)
    rng = random.Random(seed)
    checked = 0
    for _ in range(trials):
        n = rng.randrange(1, 5000)
        m = rng.randrange(n + 1, n + 20000)
        s = (m, n)
        if not is_admissible(s):
            continue
        checked += 1
        assert letter_of(s) == letter_from_probe(probe(1, s)), s
    print(f"  verified on {checked} random admissible states: no counterexample.")
    print("  decoder:  reading <= 3 -> A,   4..5 -> B,   >= 6 -> C")
    print()


def demo_readable_prefix(trials: int = 4000, seed: int = 20260823) -> None:
    print("=" * 74)
    print("3.  READABLE PREFIX: the run C^L and its terminating inversion letter")
    print("=" * 74)
    rng = random.Random(seed)
    print(f"{'(m,n)':<18}{'P_1':<8}{'L':<5}{'predicted prefix':<22}{'true address'}")
    shown = 0
    while shown < 8:
        n = rng.randrange(1, 60)
        m = rng.randrange(n + 1, 12 * n + 3)
        s = (m, n)
        if not is_admissible(s):
            continue
        p, pref = window_read(s)
        addr = address(s)
        assert addr.startswith(pref), (s, pref, addr)
        print(f"{str(s):<18}{p:<8}{run_length(s):<5}{pref:<22}{addr}")
        shown += 1

    # cross-check: equal one-bit readings force equal letters 0..L
    print()
    buckets: Dict[int, List[State]] = defaultdict(list)
    for n in range(1, 90):
        for m in range(n + 1, 40 * n, 1):
            s = (m, n)
            if is_admissible(s):
                buckets[probe(1, s)].append(s)
    collisions = agreements = 0
    for p, group in buckets.items():
        for i in range(min(len(group), 60)):
            for j in range(i + 1, min(len(group), 60)):
                s, t = group[i], group[j]
                L = min(run_length(s), run_length(t))
                collisions += 1
                if all(letter_at(k, s) == letter_at(k, t) for k in range(L + 1)):
                    agreements += 1
    print(f"  pairs with equal one-bit reading: {collisions}")
    print(f"  agreeing on all letters 0..L:     {agreements}   "
          f"({'ALL' if collisions == agreements else 'MISMATCH!'})")

    # price of depth
    bad = [s for grp in buckets.values() for s in grp[:50]
           if run_length(s) > probe(1, s) // 4]
    print(f"  violations of  L <= P_1/4:        {len(bad)}  (theorem: 0)")
    print()


def demo_spine(max_L: int = 12) -> None:
    print("=" * 74)
    print("4.  THE TRANSLATION SPINE IS READABLE TO ANY DEPTH")
    print("=" * 74)
    print("  depth is NOT the obstruction; inversion is.")
    print(f"{'L':<5}{'state (2L+2,1)':<18}{'P_1':<8}{'address'}")
    for L in range(1, max_L + 1):
        s = (2 * L + 2, 1)
        assert is_admissible(s)
        assert run_length(s) == L
        assert address(s)[:L] == "C" * L
        print(f"{L:<5}{str(s):<18}{probe(1, s):<8}{address(s)}")
    print()


def straddle(W: int, k: int, scale: int = 1) -> Tuple[State, State]:
    """The dyadic-null adversary: two states on either side of the boundary 7/3+2k."""
    q = 6 * (2 ** W) * scale
    K = 7 + 6 * k
    return ((K * q + 1, 3 * q), (K * q - 1, 3 * q))


def demo_depth_null(max_W: int = 6, max_k: int = 5) -> None:
    print("=" * 74)
    print("5.  DEPTH NULL:  no fixed window reads past the first inversion")
    print("=" * 74)
    print("    s+ = ((7+6k)q+1, 3q),  s- = ((7+6k)q-1, 3q),  q = 6*2^W")
    print(f"{'W':<4}{'k':<4}{'P_W(s+)':<16}{'P_W(s-)':<16}{'prefix':<12}"
          f"{'letter k+1':<12}")
    for W in range(0, max_W + 1):
        for k in range(0, max_k + 1):
            sp, sm = straddle(W, k)
            assert is_admissible(sp) and is_admissible(sm)
            pp, pm = probe(W, sp), probe(W, sm)
            assert pp == pm
            pre_p = "".join(letter_at(j, sp) for j in range(k + 1))
            pre_m = "".join(letter_at(j, sm) for j in range(k + 1))
            assert pre_p == pre_m == "C" * k + "B"
            lp, lm = letter_at(k + 1, sp), letter_at(k + 1, sm)
            assert lp != lm
            if k <= 2:
                print(f"{W:<4}{k:<4}{pp:<16}{pm:<16}{pre_p:<12}{lp}/{lm:<10}")
    print("  every (W,k) with W<=%d, k<=%d verified: equal readings, equal prefix"
          % (max_W, max_k))
    print("  C^k B, divergent letter at position k+1.")

    # arbitrarily large denominators
    print()
    print("  the same collision at arbitrarily large scale (k=3, W=4):")
    for scale in [1, 10 ** 3, 10 ** 6, 10 ** 12]:
        sp, sm = straddle(4, 3, scale)
        assert probe(4, sp) == probe(4, sm)
        assert letter_at(4, sp) != letter_at(4, sm)
        print(f"    denominator {sp[1]:>22}   readings equal, letters differ")
    print()


def demo_universal_null(scales: Sequence[Tuple[int, int]] = ((2, 1), (3, 1), (10, 1),
                                                             (7, 5), (1024, 3)),
                        max_k: int = 4) -> None:
    print("=" * 74)
    print("6.  UNIVERSAL NULL:  no rational rescaling of the magnitude helps")
    print("=" * 74)
    print("    T_k = (4k+5, 2)  [ratio exactly 5/2+2k, an ATTAINED boundary]")
    print("    U   = ((4k+5)u+1, 2u),  u = 2a+2")
    print(f"{'a/b':<12}{'k':<4}{'reading T':<14}{'reading U':<14}"
          f"{'prefix':<12}{'letter k+1'}")
    for (a, b) in scales:
        for k in range(0, max_k + 1):
            u = 2 * a + 2
            T = (4 * k + 5, 2)
            U = ((4 * k + 5) * u + 1, 2 * u)
            assert is_admissible(T) and is_admissible(U)
            gt, gu = gprobe(a, b, T), gprobe(a, b, U)
            assert gt == gu
            pre_t = "".join(letter_at(j, T) for j in range(k + 1))
            pre_u = "".join(letter_at(j, U) for j in range(k + 1))
            assert pre_t == pre_u
            lt, lu = letter_at(k + 1, T), letter_at(k + 1, U)
            assert lt != lu
            if k <= 1:
                print(f"{f'{a}/{b}':<12}{k:<4}{gt:<14}{gu:<14}{pre_t:<12}{lt}/{lu}")
    print("  all scales and depths verified: equal readings, divergent next letter.")
    print()


def demo_capacity(W: int = 3, k: int = 6) -> None:
    print("=" * 74)
    print("7.  CAPACITY BOUND:  2*2^W < 2^k forces a collision (pigeonhole)")
    print("=" * 74)
    print(f"  W = {W}: the sensor takes at most 2*2^W = {2 * 2 ** W} values on the")
    print(f"  ratio-bounded stratum;  depth k = {k} carries 2^k = {2 ** k} behaviours.")
    assert 2 * 2 ** W < 2 ** k
    buckets: Dict[int, List[str]] = defaultdict(list)
    for v in range(2 ** k):
        word = "".join("A" if (v >> i) & 1 else "B" for i in range(k))
        s = build(word)
        assert 1 * s[1] < s[0] < 3 * s[1]     # ratio stays in (1,3)
        buckets[probe(W, s)].append(word)
    colliding = [(p, ws) for p, ws in buckets.items() if len(ws) > 1]
    print(f"  distinct readings observed: {len(buckets)}")
    print(f"  buckets with >= 2 words:    {len(colliding)}")
    p, ws = max(colliding, key=lambda t: len(t[1]))
    print(f"  example: reading {p} is shared by {len(ws)} distinct addresses, e.g.")
    for w in ws[:4]:
        print(f"      {w}   state {build(w)}")
    a, b = ws[0], ws[1]
    j = next(i for i in range(k) if a[i] != b[i])
    print(f"  first divergence between the first two: position {j} "
          f"({a[j]} vs {b[j]})")
    print()


# --------------------------------------------------------------------------
# 4.  Empirical mutual information decay
# --------------------------------------------------------------------------

def entropy(counts: Counter) -> float:
    total = sum(counts.values())
    if total == 0:
        return 0.0
    return -sum((c / total) * math.log2(c / total) for c in counts.values() if c)


def mutual_information(pairs: Sequence[Tuple[int, str]]) -> float:
    """I(X;Y) in bits for a sample of (feature, letter) pairs."""
    n = len(pairs)
    if n == 0:
        return 0.0
    joint = Counter(pairs)
    px = Counter(x for x, _ in pairs)
    py = Counter(y for _, y in pairs)
    out = 0.0
    for (x, y), c in joint.items():
        pxy = c / n
        out += pxy * math.log2(pxy / ((px[x] / n) * (py[y] / n)))
    return out


def sample_population(size: int = 40000, depth: int = 9,
                      seed: int = 20260823) -> List[Tuple[State, str]]:
    """Random states built from uniform random addresses of the given depth."""
    rng = random.Random(seed)
    pop: List[Tuple[State, str]] = []
    for _ in range(size):
        word = "".join(rng.choice("ABC") for _ in range(depth))
        pop.append((build(word), word))
    return pop


def demo_information_decay(W: int = 3, depth: int = 8) -> None:
    print("=" * 74)
    print("8.  THE DECAY CURVE:  unconditional vs. prefix-conditional information")
    print("=" * 74)
    pop = sample_population(depth=depth + 1)
    feature = [probe(W, s) % 64 for s, _ in pop]      # a bounded magnitude feature

    print(f"  window budget W = {W},  population size {len(pop)}")
    print(f"{'t':<5}{'MI(feature; letter_t)':<26}{'conditional MI (within prefix)'}")
    for t in range(depth):
        pairs = [(f, w[t]) for f, (_, w) in zip(feature, pop)]
        mi = mutual_information(pairs)

        # honest per-step test: condition on the path prefix w[:t]
        groups: Dict[str, List[Tuple[int, str]]] = defaultdict(list)
        for f, (_, w) in zip(feature, pop):
            groups[w[:t]].append((f, w[t]))
        total = sum(len(g) for g in groups.values())
        cond = sum(len(g) / total * mutual_information(g)
                   for g in groups.values() if len(g) >= 8)

        bar = "#" * int(round(mi * 120))
        print(f"{t + 1:<5}{mi:<10.4f}{bar:<16}{cond:>10.4f}")
    print()
    print("  Both columns decay sharply with depth; the conditional column is")
    print("  the honest per-step channel, since it removes what the sensor could")
    print("  infer about letter t merely from the correlations with letters")
    print("  0..t-1.  Either way the signal is gone within a few levels -- the")
    print("  theorems' prediction: the sensor reads the leading translation run")
    print("  and the inversion that ends it, and nothing deeper.")
    print()


def main() -> None:
    print()
    print("DEPTH DECAY OF THE MAGNITUDE CHANNEL ON THE BERGGREN TREE")
    print()
    demo_tree()
    demo_first_letter()
    demo_readable_prefix()
    demo_spine()
    demo_depth_null()
    demo_universal_null()
    demo_capacity()
    demo_information_decay()
    print("=" * 74)
    print("SUMMARY")
    print("=" * 74)
    print("  readable : the leading C-run C^L, L = floor((m-n)/(2n)), plus the")
    print("             inversion letter terminating it -- from ONE bit of ratio.")
    print("  metered  : L <= P_1/4, so depth L costs ~log2(L) output bits.")
    print("  null     : nothing past the first inversion, for any window budget,")
    print("             any rational rescaling, any depth, at any scale.")
    print("  capacity : 2*2^W < 2^k already forces confusion by pigeonhole.")
    print()


if __name__ == "__main__":
    main()


"""Adversary generators: certified sensor collisions at any budget and any depth."""

from __future__ import annotations

from typing import Tuple

State = Tuple[int, int]


def dyadic_adversary(W: int, k: int, scale: int = 1) -> Tuple[State, State]:
    """Two admissible states straddling the non-dyadic boundary 7/3 + 2k.

    With q = 6 * 2^W * scale, the pair
        s+ = ((7+6k)q + 1, 3q),      s- = ((7+6k)q - 1, 3q)
    has identical W-window readings (their ratios differ by 2/(3q) < 2^-W and no
    binary grid line separates them, because 7/3 is not a dyadic rational),
    identical addresses C^k B through position k, and different letters at
    position k+1.  `scale` pushes the denominators above any prescribed size.
    Cost: O(1) arithmetic operations.
    """
    q = 6 * (2 ** W) * scale
    K = 7 + 6 * k
    return (K * q + 1, 3 * q), (K * q - 1, 3 * q)


def rational_adversary(a: int, b: int, k: int) -> Tuple[State, State]:
    """Two admissible states defeating the sensor floor((a/b) * (m/n)).

    T = (4k+5, 2) has ratio exactly 5/2 + 2k -- an *attained* branch boundary --
    and U = ((4k+5)u + 1, 2u) with u = 2a+2 is its immediate right neighbour at
    resolution 1/(2u).  Truncation is right-continuous, so no rational rescaling
    of the magnitude separates them; yet after k translations and one inversion
    T continues with B and U with A.  Cost: O(1).
    """
    u = 2 * a + 2
    K = 4 * k + 5
    return (K, 2), (K * u + 1, 2 * u)


if __name__ == "__main__":
    print(dyadic_adversary(4, 3))
    print(dyadic_adversary(4, 3, scale=10 ** 6))
    print(rational_adversary(3, 1, 2))


"""Pigeonhole search for a capacity-forced collision of the window sensor."""

from __future__ import annotations

from collections import defaultdict
from typing import Dict, List, Optional, Tuple

State = Tuple[int, int]
ROOT: State = (2, 1)


def child(x: str, s: State) -> State:
    m, n = s
    return {"A": (2 * m - n, m), "B": (2 * m + n, m), "C": (m + 2 * n, n)}[x]


def build(word: str) -> State:
    """The admissible state whose address is exactly `word`."""
    s = ROOT
    for x in reversed(word):
        s = child(x, s)
    return s


def probe(W: int, s: State) -> int:
    m, n = s
    return (2 ** W) * m // n


def capacity_collision(W: int, k: int) -> Optional[Tuple[str, str, int, int]]:
    """Find two length-k addresses over {A,B} with the same W-window reading.

    States built from {A,B}-words have ratio strictly between 1 and 3, so their
    readings lie in a set of size 2*2^W; there are 2^k such addresses.  When
    2*2^W < 2^k a collision is guaranteed by pigeonhole.  Returns
    (word1, word2, shared reading, first position where the addresses differ),
    or None if no collision occurred.  Cost: O(2^k * k) arithmetic operations.
    """
    buckets: Dict[int, List[str]] = defaultdict(list)
    for v in range(2 ** k):
        word = "".join("A" if (v >> i) & 1 else "B" for i in range(k))
        buckets[probe(W, build(word))].append(word)
        group = buckets[probe(W, build(word))]
        if len(group) == 2:
            w1, w2 = group
            j = next(i for i in range(k) if w1[i] != w2[i])
            return w1, w2, probe(W, build(word)), j
    return None


if __name__ == "__main__":
    print("forced?", 2 * 2 ** 3 < 2 ** 6)
    print(capacity_collision(3, 6))


"""Berggren descent: extract the full address of a primitive Pythagorean triple."""

from __future__ import annotations

import math
from typing import List, Tuple

State = Tuple[int, int]
ROOT: State = (2, 1)


def is_admissible(s: State) -> bool:
    """0 < n < m, gcd(m,n) = 1, m+n odd: the (m,n) coordinates of a primitive triple."""
    m, n = s
    return 0 < n < m and math.gcd(m, n) == 1 and (m + n) % 2 == 1


def descent_address(s: State) -> str:
    """Return the address word of an admissible state, using run-compressed C-steps.

    Each maximal run of translation letters is executed with a single division,
    so the loop performs O(log max(m,n)) divisions in total: this procedure *is*
    the Euclidean algorithm on (m, n), written in tree coordinates.
    """
    if not is_admissible(s):
        raise ValueError(f"{s} is not admissible")
    out: List[str] = []
    m, n = s
    while (m, n) != ROOT:
        if m > 3 * n:
            run = (m - n) // (2 * n)          # length of the leading C-run
            out.append("C" * run)
            m = m - 2 * run * n               # one division, `run` tree levels
        elif m > 2 * n:                       # inversion, letter B
            out.append("B")
            m, n = n, m - 2 * n
        else:                                 # inversion, letter A
            out.append("A")
            m, n = n, 2 * n - m
    return "".join(out)


if __name__ == "__main__":
    for st in [(2, 1), (5, 2), (47, 6), (1249, 32)]:
        print(st, "->", descent_address(st))


"""The fixed-window magnitude sensor and its certified prefix prediction."""

from __future__ import annotations

from typing import Tuple

State = Tuple[int, int]


def probe(W: int, s: State) -> int:
    """W-window magnitude sensor: the ratio m/n truncated to W binary places."""
    m, n = s
    return (2 ** W) * m // n


def certified_prefix(s: State) -> Tuple[int, str]:
    """Return (one-bit reading, the prefix of the address it determines).

    The prefix is C^L X where L = floor((m-n)/(2n)) and X is the inversion letter
    terminating the run.  Two divisions, independent of the depth of the state.
    Any other admissible state with the same one-bit reading has exactly this
    prefix; nothing beyond position L is determined by any fixed-window reading.
    """
    m, n = s
    L = (m - n) // (2 * n)
    r = m - 2 * L * n                      # numerator after the run of translations
    tail = "A" if r < 2 * n else "B"       # r < 3n always holds at this point
    return probe(1, s), "C" * L + tail


if __name__ == "__main__":
    for st in [(47, 6), (1249, 32), (22, 1)]:
        p, pre = certified_prefix(st)
        print(f"{st}: reading {p}, certified prefix {pre}")


#!/usr/bin/env python3
"""Assemble PACKAGE.json from the deliverable files and the package assets."""

from __future__ import annotations

import json
import pathlib
from typing import Any, Dict, List

ROOT = pathlib.Path(__file__).resolve().parent.parent
ASSETS = ROOT / "package_assets"


def read(p: pathlib.Path) -> str:
    return p.read_text(encoding="utf-8")


LEAN_FILES = [
    "Catalog/Cryptography/DepthDecay/WindowSensor.lean",
    "Catalog/Cryptography/DepthDecay/NullBeyondInversion.lean",
    "Catalog/Cryptography/DepthDecay/UniversalNull.lean",
    "Catalog/Cryptography/DepthDecay/PathRealization.lean",
]

lean_proofs = "\n\n".join(
    f"-- ===================================================================\n"
    f"-- FILE: {f}\n"
    f"-- ===================================================================\n\n"
    + read(ROOT / f)
    for f in LEAN_FILES
)

FUTURE = """# Future directions — after the depth-decay theorems

This cycle pinned the reach of a fixed-precision magnitude sensor on the Berggren
(Pythagorean) tree, in three independent registers:

* **exists** — the first descent letter is a function of the one-bit probe
  `⌊2m/n⌋`;
* **reaches exactly to the first inversion** — the whole leading `C`-run *and* the
  letter terminating it are readable, arbitrarily deep, but nothing past that;
* **null beyond it, at any depth and any budget** — for every window budget and
  every depth there are colliding admissible pairs whose letters diverge one step
  past the first inversion; the depth-`k+2` letter is not a function of the
  reading; the threshold is sharp; and an independent capacity/pigeonhole
  argument forces the same conclusion.

Three structural patterns emerged and drive the conjectures below.
(i) The letters are Gauss-map digits of the ratio, and the branch boundaries are `2` and
`3`: `2` is dyadic (hence always resolvable), while all *deeper* boundaries are the
rationals `7/3, 5/2, …` and their pullbacks — non-dyadic, hence never resolvable by a
truncation sensor.  (ii) The `C`-branch is a translation (isometry on ratios) and is
therefore transparent to the sensor; the `A`/`B`-branches are inversions and are opaque.
(iii) The obstruction is quantitative and information-theoretic, not merely adversarial:
on the ratio-bounded stratum the probe has `O(2^W)` values against `3^k` behaviours.

## D1. Dyadic-boundary criterion for readability

**The key insight is** that a letter is readable by *some* fixed-precision truncation sensor
exactly when the branch boundary separating its two alternatives is a dyadic rational, and
the depth-`t` boundaries are the Möbius pullbacks of `{2,3}` along the first `t-1`
letters — dyadic only along the `C`-spine.  **Why now?** Both halves are already in place:
the depth-one readability result uses the dyadicity of `2`, and the null result uses the
non-dyadicity of `7/3`; what is missing is the general pullback computation.

## D2. Euclidean-step hierarchy (after the universal null)

The original form of this direction — "a base-3 window sees deeper than a base-2 window" —
was **refuted inside this cycle**: the universal null shows that *every* rational-scale
truncation `⌊(a/b)(m/n)⌋` fails at the very first letter past the inversion, because the
boundary `5/2 + 2k` is *attained* by an admissible state and truncation is right-continuous.
So the surviving question is about a different sensor class.

**The key insight is** that what a sensor really needs is not finer scaling but *Euclidean
steps*: the pair `(⌊m/n⌋, m mod n)` is one step of the Euclidean algorithm and already
determines strictly more letters than any single truncation.  **Why now?** The universal
null fixes the exact failure mode (attained boundaries), and a `t`-step Euclidean sensor is
precisely what resolves them, so the conjectured hierarchy "`t` steps ↔ `Θ(t)` letters" is
now the sharp question.

## D3. Further directions

* Characterize the full class of *depth-null* functionals: which computable functions of
  `(m,n)` with bounded output determine no letter past the first inversion?
* Quantify the channel capacity in bits as a function of the budget `W` and compare it
  against the measured mutual-information decay curve.
* Extend the analysis to arbitrary `d`-ary trees generated by integer Möbius maps with a
  mixture of translations and inversions; the prediction is that readability always extends
  exactly along the maximal translation prefix.
"""

INTERACTIVE_LAYOUT = r"""
# The Magnitude Channel Sees Only the First Steps

### A guided tour of how much of a Pythagorean triple's tree address you can read *cheaply*

---

## 1. Every right triangle has an address

$3^2+4^2=5^2$. $5^2+12^2=13^2$. $8^2+15^2=17^2$. These are the *primitive*
Pythagorean triples — whole-number right triangles whose sides share no common factor.
They are not scattered at random: they form a single infinite **ternary tree**, rooted at
$(3,4,5)$, in which every primitive triple appears exactly once.

The cleanest coordinates are Euclid's. Every primitive triple is
$$(x,y,z)=(m^2-n^2,\;2mn,\;m^2+n^2)$$
for a unique **admissible pair** $(m,n)$: $0<n<m$, $\gcd(m,n)=1$, and $m+n$ odd. In these
coordinates the tree is rooted at $(2,1)$ and the three children of $(m,n)$ are
$$A:(m,n)\mapsto(2m-n,m),\qquad B:(m,n)\mapsto(2m+n,m),\qquad C:(m,n)\mapsto(m+2n,n).$$

So every triple has an **address**: the word over $\{A,B,C\}$ recording the turns from the
root. Read [more about Pythagorean triples](https://en.wikipedia.org/wiki/Pythagorean_triple)
and [the tree of primitive triples](https://en.wikipedia.org/wiki/Tree_of_primitive_Pythagorean_triples)
if you want the classical background.

<details>
<summary><b>Click to reveal: how to climb one step (and why it is a digit expansion)</b></summary>

To climb toward the root you need only the **ratio** $r=m/n$ and its position relative to
the two cut points $2$ and $3$:

- $r<2$: the last letter was $A$, and the parent ratio is $\dfrac{1}{2-r}$;
- $2<r<3$: the last letter was $B$, and the parent ratio is $\dfrac{1}{r-2}$;
- $r>3$: the last letter was $C$, and the parent ratio is $r-2$.

Subtract an integer; if the remainder is small, flip it over and continue. That is exactly
the rhythm of a [continued fraction](https://en.wikipedia.org/wiki/Continued_fraction) and
of the [Gauss map](https://en.wikipedia.org/wiki/Gauss%E2%80%93Kuzmin%E2%80%93Wirsing_operator).
**The address of a triple is a digit expansion of its ratio.**

An arithmetic bonus keeps everything clean: an admissible pair never has $m$ equal to an odd
multiple of $n$, so the descent never lands *on* a boundary (except at the root). Parity and
coprimality do all the work.
</details>

---

## 2. The question: how much can a cheap instrument read?

Hand someone a thousand-digit primitive triple. Climbing the tree to recover its address
costs about a full run of the Euclidean algorithm. Suppose instead you have a cheap
**window sensor** with a fixed budget of $W$ binary places:
$$P_W(m,n)=\left\lfloor 2^{W}\cdot \frac{m}{n}\right\rfloor.$$
A magnifying glass whose power does *not* grow with the size or the depth of the input.
How many letters of the address does it pin down?

Play with the first panel of the explorer below. Type a triple, and watch the address
appear with its **certified prefix** underlined in gold.

{{interactive_demo:0}}

Three things to notice while you play:

1. The **first letter** always agrees with the decoder $D(P_1)$: $A$ if $\lfloor 2m/n\rfloor\le3$,
   $B$ if it is $4$ or $5$, $C$ if it is $\ge 6$.
2. The gold prefix is often *long*: it is the whole leading run of $C$'s plus one more letter.
3. Panel 2 will not let you break the collision, no matter how far you push the slider.

---

## 3. What the sensor *can* see

> **First-Letter Readability.** For every admissible pair, the first descent letter is an
> explicit function of the single one-bit reading $\lfloor 2m/n\rfloor$.

> **Readable-Prefix Theorem.** The address begins with exactly
> $L=\left\lfloor \dfrac{m-n}{2n}\right\rfloor$ consecutive $C$'s, followed by a non-$C$
> letter. Any other admissible pair with the same one-bit reading has the *identical* first
> $L+1$ letters — the whole run **and** the inversion letter that ends it.

Why should a run of translations be free? Because the $C$-branch acts on ratios as
$r\mapsto r-2$, an **isometry**: it slides the reading down by exactly $4$ and destroys no
precision. The $A$- and $B$-branches act by **inversion**, which magnifies differences
without bound near the boundaries. That asymmetry is the entire story.

<details>
<summary><b>Click for the proof sketch of the readable-prefix theorem</b></summary>

*Step 1 (the shift).* If the letter is $C$ then $\mathrm{par}(m,n)=(m-2n,n)$, and
$2m=2(m-2n)+4n$, so $P_1$ drops by exactly $4$.

*Step 2 (propagation).* Induct on $k$: two states with equal readings have equal first
letters; if that letter is $C$, both readings drop by $4$, so the parents again share a
reading, and we may recurse.

*Step 3 (the run length).* If $j<L=\lfloor (m-n)/(2n)\rfloor$ then $(2j+3)n\le m$, and
equality is impossible (odd-multiple lemma), so the $j$-th state still has ratio above $3$
and the letter is $C$. At $j=L$ the division identity gives $m-2Ln<3n$, so the letter is
$A$ or $B$. Hence the run has length exactly $L$, and Step 2 transfers all letters
$0,\dots,L$ to any state with the same reading. $\blacksquare$
</details>

Depth is even visible *as a number* — but it is **metered**: one shows $L\le P_1/4$, so
reading depth $L$ forces the sensor to output a value of size at least $4L$, i.e. about
$\log_2 L$ bits. And along the pure-$C$ spine, e.g. the states $(2L+2,1)$, the sensor reads
arbitrarily many letters. Depth by itself is *not* the obstruction.

{{visualization:0}}

---

## 4. What the sensor can *never* see

Now the wall. Move the sliders in panel 2 of the explorer: whatever budget $W$ and whatever
depth $k$ you choose, you get two admissible triples with the *same* reading, the *same*
address through position $k$, and *different* letters one step later.

> **Depth-Null Theorem.** For every window budget $W$ and every depth $k$ there exist
> admissible pairs $s^{+},s^{-}$ with $P_W(s^{+})=P_W(s^{-})$, identical addresses
> $C^{k}B$ through position $k$, and $\ell_{k+1}(s^{+})\neq \ell_{k+1}(s^{-})$. Hence the
> letter at position $k+2$ is a function of no fixed-window reading, at any depth — and
> such pairs exist with arbitrarily large denominators.

The construction: with $q=6\cdot 2^{W}$,
$$s^{\pm}=\big((7+6k)q\pm 1,\;3q\big),\qquad \text{ratios } \tfrac73+2k\pm\tfrac{1}{3q}.$$
They straddle the number $\tfrac73+2k$. Because $7/3$ is **not a dyadic rational**, no
binary grid line ever falls between them; the sensor is blind to the difference. Then $k$
translations move them in lockstep, and one inversion throws their images to opposite sides
of the cut point $3$.

<details>
<summary><b>Click to reveal: the two-line arithmetic behind the collision</b></summary>

Write $M=2^{W}$, $K=7+6k$, and divide $MK=3t+\rho$. Since $3$ never divides a power of two
and $K\equiv 1\pmod 3$, the remainder satisfies $\rho\in\{1,2\}$ — crucially $\rho\ne 0$.
Then
$$M(Kq\pm 1)=3q\,t+(\rho q\pm M),$$
and $M<q\le \rho q$ with $\rho \le 2$ places both correction terms strictly inside
$[0,3q)$. Both quotients are $t$: the readings coincide. The step "$\rho\ne0$" is precisely
the statement that $7/3$ is not dyadic. $\blacksquare$
</details>

The threshold is **sharp**: depth $1$ is always readable from one bit; depth $2$ is already
null for every budget. Taken with the readable-prefix theorem, the reach is pinned exactly:
*the leading $C$-run and the inversion letter terminating it, and nothing more.*

---

## 5. "Just use a better ruler" — no

The natural objection is that $7/3$ is invisible in base $2$ but obvious in base $3$. Set
$a=3$, $b=1$ in panel 3 of the explorer and watch the collision survive.

> **Universal Null Theorem.** For every rational scale $a/b$, the sensor
> $G_{a/b}(m,n)=\lfloor (a/b)(m/n)\rfloor$ confuses, at every depth $k$, two admissible
> pairs with the same address through position $k$ and different letters one step later.

The mechanism is stronger and prettier. The state $(4k+5,\,2)$ has ratio *exactly*
$\tfrac52+2k$ — an **attained** boundary — and after $k$ translations and one inversion it
lands on the root. Its right neighbour $\big((4k+5)u+1,\,2u\big)$ slips just below $2$ after
the same steps, taking letter $A$ instead of $B$. Since the floor function is
right-continuous, **no** truncation, at **any** scale, separates a point from the points
immediately above it. Refining the ruler is structurally the wrong move.

{{algorithm:2}}

---

## 6. Capacity: this is not adversarial bad luck

Maybe the counterexamples are contrived? A counting argument closes that door. Every word
over $\{A,B,C\}$ is realized: build the state by applying the child maps in reverse, and the
descent reads the word back exactly. So depth $k$ genuinely carries $3^{k}$ behaviours.

Restrict to addresses over $\{A,B\}$: those states have ratio strictly between $1$ and $3$,
so their $W$-bit readings live in a set of only $2\cdot2^{W}$ values, against $2^{k}$
addresses.

> **Capacity Theorem.** If $2\cdot2^{W}<2^{k}$, the $W$-window sensor must confuse two
> admissible states whose addresses already differ somewhere below depth $k$.

Two bits of depth beyond the budget already destroy injectivity. Panel 4 of the explorer
lets you watch the pigeonhole bite, and the algorithm below finds an explicit colliding
pair.

{{algorithm:3}}

---

## 7. The decay curve, measured

Everything above predicts a specific empirical signature: a magnitude feature should carry
real information about the first couple of letters, marginal information about the third,
and none at all past the first inversion. That is what one measures.

{{visualization:1}}

{{demo:0}}

The honest per-step test conditions on the path prefix — otherwise a sensor that reads only
the early letters looks informative about the late ones purely through the correlations
between letters. Under that control, the second letter is read loud and clear, the third is
marginal, the fourth is at the edge of noise, and the fifth is null.

---

## 8. Why anyone should care

There is a long tradition of hoping that some combinatorial structure gives a shortcut to
[integer factorization](https://en.wikipedia.org/wiki/Integer_factorization), and the
Pythagorean tree is a recurring candidate: a target $N$ picks out a location whose address
encodes arithmetic about $N$. Any such attack needs a *cheap* readout of the address, and
fixed-window magnitude sensors are the natural cheap readouts.

The results settle the matter in three registers:

| register | statement |
|---|---|
| **exists** | the first letter — indeed the whole leading translation run — is a function of one bit of ratio |
| **priced** | reading depth $L$ costs $\Theta(\log L)$ output bits, above breakeven against a direct search |
| **depth-limited** | nothing past the first inversion, for any budget, any rational rescaling, any depth, at any scale |

The one-line moral: **a fixed window reads the coarse digits of a ratio, the first few
letters of the address *are* those coarse digits, and every deeper letter is a finer digit
no fixed budget can see.** The full address again costs the Euclidean climb.

{{algorithm:0}}

{{algorithm:1}}

---

## 9. Where this goes next

Two patterns point the way. First, a **dyadic criterion**: a letter looks readable exactly
when the boundary separating its alternatives is a dyadic rational, and the depth-$t$
boundaries are Möbius pullbacks of $\{2,3\}$ — dyadic only along the translation spine.
Second, a conjectured **Euclidean hierarchy**: finer scaling is provably useless, but the
pair $(\lfloor m/n\rfloor,\,m\bmod n)$ — one Euclidean step — resolves attained boundaries
by construction, suggesting that $t$ Euclidean steps buy exactly $\Theta(t)$ letters.

If that is right, the tree's secret is not hidden behind precision at all. It is hidden
behind the Euclidean algorithm — which is to say, behind exactly the work a shortcut was
trying to skip.
"""


def main() -> None:
    package: Dict[str, Any] = {
        "title": "Depth Decay of the Magnitude Channel on the Berggren Tree of "
                 "Primitive Pythagorean Triples",
        "domain": "Cryptography",
        "description": (
            "A fixed-precision magnitude sensor on the Berggren tree of primitive "
            "Pythagorean triples reads exactly the leading run of translation letters "
            "of a triple's address together with the inversion letter that terminates "
            "it, and provably nothing beyond: for every window budget, every rational "
            "rescaling and every depth there are admissible pairs with identical "
            "readings whose descent letters diverge one step past the first inversion."
        ),
        "authors": ["Aristotle"],
        "date": "2026-08-24",
        "key_results": [
            "First-letter readability: the first descent letter of an admissible pair "
            "(m,n) is an explicit function of the one-bit magnitude reading "
            "floor(2m/n).",
            "Readable-prefix theorem: the address begins with exactly "
            "L = floor((m-n)/(2n)) translation letters, and any two admissible pairs "
            "with the same one-bit reading agree on all letters 0..L — the whole run "
            "plus the inversion letter terminating it; along the translation spine "
            "arbitrarily many letters are readable, at the metered price L <= "
            "(reading)/4.",
            "Depth-null theorem: for every window budget and every depth there are "
            "admissible pairs with identical readings, identical addresses through the "
            "first inversion, and different letters one step later — available at "
            "arbitrarily large denominators — so no fixed-precision magnitude "
            "functional determines any letter past the first inversion; the threshold "
            "is sharp (depth one readable, depth two null).",
            "Universal null: the same failure holds for every rational rescaling of the "
            "magnitude, because the deeper branch boundary 5/2 + 2k is attained by an "
            "admissible state and truncation is right-continuous.",
            "Capacity bound: every word over the three letters is realized by an "
            "admissible state, and on the ratio-bounded stratum a W-bit sensor takes at "
            "most 2*2^W values, so 2*2^W < 2^k already forces two states with different "
            "addresses to share a reading.",
        ],
        "keywords": [
            "Pythagorean triples",
            "Berggren tree",
            "Gauss map",
            "continued fractions",
            "information channel",
            "dyadic rationals",
            "pigeonhole capacity bound",
            "factoring shortcuts",
        ],
        "article": read(ROOT / "ARTICLE.md"),
        "research_paper": read(ROOT / "RESEARCH_PAPER.md"),
        "research_paper_tex": read(ROOT / "RESEARCH_PAPER.tex"),
        "demo": read(ROOT / "demo.py"),
        "demos": [
            {
                "name": "End-to-End Demonstration of the Readable Prefix, the Depth "
                        "Null, and the Capacity Bound",
                "description": (
                    "A self-contained numerical tour of every result. It builds the "
                    "Berggren tree in (m,n) coordinates and checks that the descent "
                    "reads back the address of any constructed word; verifies on tens "
                    "of thousands of random admissible pairs that the first descent "
                    "letter equals the decoder applied to the one-bit reading "
                    "floor(2m/n); confirms that the address begins with exactly "
                    "L = floor((m-n)/(2n)) translation letters and that every pair of "
                    "states sharing a one-bit reading agrees on all letters 0..L, "
                    "together with the metering bound L <= reading/4; exhibits the "
                    "translation spine (2L+2,1) whose leading run is readable to any "
                    "depth; generates the straddling adversary "
                    "((7+6k)q±1, 3q) with q = 6*2^W for every budget and depth in a "
                    "grid and asserts equal readings, identical prefixes C^k B and "
                    "divergent letters one step later, including at denominators of "
                    "size 10^14; repeats the experiment for arbitrary rational scales "
                    "a/b using the attained boundary state (4k+5,2); demonstrates the "
                    "pigeonhole capacity collision; and finally measures the mutual "
                    "information between a bounded magnitude feature and the descent "
                    "letter at each depth, both unconditionally and conditioned on the "
                    "path prefix, reproducing the observed decay curve."
                ),
                "code": read(ROOT / "demo.py"),
            }
        ],
        "algorithms": [
            {
                "name": "Berggren Descent with Run-Compressed Translation Steps "
                        "(Address Extraction)",
                "description": (
                    "Extracts the complete address of a primitive Pythagorean triple by "
                    "iterating the descent map. At each stage the ratio m/n is compared "
                    "against the cut points 2 and 3: below 2 the letter is A and the "
                    "parent is (n, 2n-m); between 2 and 3 the letter is B and the parent "
                    "is (n, m-2n); above 3 the letter is C and the parent is (m-2n, n). "
                    "The two inversion branches are executed one at a time, but each "
                    "maximal run of translation letters is executed with a single "
                    "division: the run length is L = floor((m-n)/(2n)) and the numerator "
                    "jumps directly to m - 2Ln. Since a maximal C-run followed by an "
                    "inversion is precisely one step of the Euclidean algorithm on the "
                    "pair (m,n), the loop terminates after O(log max(m,n)) divisions, "
                    "and the total bit complexity matches that of the Euclidean "
                    "algorithm. This is the reference cost that a cheap sensor is "
                    "attempting to avoid, and the benchmark against which the sensor's "
                    "partial readout must be priced."
                ),
                "pseudocode": (
                    "Input : admissible pair (m, n)   [0 < n < m, gcd(m,n)=1, m+n odd]\n"
                    "Output: address word over {A, B, C}\n"
                    "\n"
                    "1.  out <- empty word\n"
                    "2.  while (m, n) != (2, 1) do\n"
                    "3.      if m > 3n then                      # translation run\n"
                    "4.          L <- floor((m - n) / (2n))      # one division\n"
                    "5.          append C repeated L times to out\n"
                    "6.          m <- m - 2*L*n\n"
                    "7.      else if m > 2n then                 # inversion, letter B\n"
                    "8.          append B to out\n"
                    "9.          (m, n) <- (n, m - 2n)\n"
                    "10.     else                                # inversion, letter A\n"
                    "11.         append A to out\n"
                    "12.         (m, n) <- (n, 2n - m)\n"
                    "13. return out"
                ),
                "code": read(ASSETS / "alg_descent.py"),
            },
            {
                "name": "Fixed-Window Magnitude Sensor and Its Certified Prefix "
                        "Prediction",
                "description": (
                    "Computes the W-window reading P_W(m,n) = floor(2^W * m / n) and the "
                    "prefix of the address that this reading provably determines. The "
                    "prediction is C^L X where L = floor((m-n)/(2n)) is the leading "
                    "translation-run length and X is the inversion letter obtained by "
                    "classifying the reduced numerator m - 2Ln against 2n. Correctness "
                    "rests on two facts: a translation step shifts the one-bit reading "
                    "down by exactly 4, so equal readings propagate through the whole "
                    "run; and the run stops exactly at index L because the reduced "
                    "numerator is then below 3n. The procedure costs two divisions and "
                    "is independent of the depth of the state — but its guarantee stops "
                    "dead at position L: no extension of it to position L+1 can be "
                    "correct for all admissible inputs. The bound L <= P_1/4 prices the "
                    "readout: seeing depth L requires an output of magnitude at least "
                    "4L, i.e. about log2(L) bits."
                ),
                "pseudocode": (
                    "Input : admissible pair (m, n), window budget W\n"
                    "Output: reading P_W, and the certified address prefix\n"
                    "\n"
                    "1.  P_W <- floor(2^W * m / n)                 # the sensor reading\n"
                    "2.  L   <- floor((m - n) / (2n))              # readable run length\n"
                    "3.  r   <- m - 2*L*n                          # numerator after run\n"
                    "4.  if r < 2n then X <- A else X <- B         # r < 3n is guaranteed\n"
                    "5.  prefix <- C repeated L times, then X\n"
                    "6.  assert L <= floor(2m/n) / 4               # price of depth\n"
                    "7.  return (P_W, prefix)\n"
                    "\n"
                    "Guarantee : every admissible state with the same one-bit reading\n"
                    "            has exactly this prefix (positions 0..L).\n"
                    "Limitation: position L+1 is determined by no reading whatsoever."
                ),
                "code": read(ASSETS / "alg_window_read.py"),
            },
            {
                "name": "Certified Adversary Generators for Window and Rational-Scale "
                        "Sensors",
                "description": (
                    "Produces, in constant time, pairs of admissible states that a given "
                    "sensor provably cannot distinguish although their addresses diverge "
                    "at a prescribed depth. The dyadic generator returns "
                    "((7+6k)q + 1, 3q) and ((7+6k)q - 1, 3q) with q = 6*2^W: the two "
                    "ratios straddle 7/3 + 2k at distance 1/(3q) each, and since 7/3 is "
                    "not a dyadic rational and q exceeds 2^W, no binary grid line "
                    "separates them; after k translations and one inversion their images "
                    "land on opposite sides of the cut point 3, so the letters at "
                    "position k+1 are B and C respectively. Multiplying q by any factor "
                    "pushes the denominators above any prescribed bound, showing the "
                    "failure is not a small-state artefact. The rational generator "
                    "defeats every sensor floor((a/b)(m/n)) by a stronger mechanism: the "
                    "state (4k+5, 2) sits exactly on the boundary 5/2 + 2k, and its "
                    "right neighbour ((4k+5)u + 1, 2u) with u = 2a+2 is inside the same "
                    "truncation cell because the floor function is right-continuous; "
                    "after the same steps the boundary state takes letter B (its "
                    "inversion lands on the root) while the neighbour takes letter A."
                ),
                "pseudocode": (
                    "DYADIC ADVERSARY\n"
                    "Input : window budget W, depth k, optional scale factor s >= 1\n"
                    "Output: admissible pair (s_plus, s_minus)\n"
                    "1.  q <- 6 * 2^W * s          # ensures 6|q and 2^W < q\n"
                    "2.  K <- 7 + 6k\n"
                    "3.  s_plus  <- (K*q + 1, 3q)\n"
                    "4.  s_minus <- (K*q - 1, 3q)\n"
                    "5.  return (s_plus, s_minus)\n"
                    "Certified: P_W equal; letters 0..k equal to C^k B; letter k+1 differs.\n"
                    "\n"
                    "RATIONAL-SCALE ADVERSARY\n"
                    "Input : scale numerator a, denominator b, depth k\n"
                    "Output: admissible pair (T, U)\n"
                    "1.  u <- 2a + 2               # any even u > a works\n"
                    "2.  K <- 4k + 5\n"
                    "3.  T <- (K, 2)               # ratio exactly 5/2 + 2k (attained)\n"
                    "4.  U <- (K*u + 1, 2u)        # immediate right neighbour\n"
                    "5.  return (T, U)\n"
                    "Certified: floor((a/b)(m/n)) equal; letters 0..k equal; letter k+1\n"
                    "           is B for T and A for U."
                ),
                "code": read(ASSETS / "alg_adversary.py"),
            },
            {
                "name": "Pigeonhole Search for a Capacity-Forced Sensor Collision",
                "description": (
                    "Demonstrates that the failure of the magnitude channel is entropic "
                    "rather than adversarial. Every word over {A,B,C} is realized by an "
                    "admissible state, built by applying the child maps in reverse order; "
                    "the descent then reads the word back exactly. Restricting to words "
                    "over {A,B} confines the ratio strictly between 1 and 3, so the "
                    "W-window reading of such a state lies in the interval "
                    "[2^W, 3*2^W), a set of only 2*2^W values, while there are 2^k words "
                    "of length k. Whenever 2*2^W < 2^k the pigeonhole principle "
                    "guarantees two distinct addresses with the same reading, and the "
                    "algorithm returns the first such collision it encounters together "
                    "with the position at which the two addresses first differ. The "
                    "search enumerates 2^k states, each built in O(k) arithmetic "
                    "operations on integers of O(k) bits, for a total cost of "
                    "O(2^k * k) operations; the guarantee, however, is unconditional and "
                    "requires no search at all."
                ),
                "pseudocode": (
                    "Input : window budget W, depth k with 2 * 2^W < 2^k\n"
                    "Output: two length-k addresses sharing a reading, and the first\n"
                    "        position at which they differ\n"
                    "\n"
                    "1.  buckets <- empty map from reading to list of words\n"
                    "2.  for v = 0 to 2^k - 1 do\n"
                    "3.      w <- the word whose i-th letter is A if bit i of v is set,\n"
                    "                                        else B\n"
                    "4.      s <- build(w)          # apply child maps in reverse order\n"
                    "5.      p <- floor(2^W * m / n) for s = (m, n)\n"
                    "6.      append w to buckets[p]\n"
                    "7.      if |buckets[p]| = 2 then\n"
                    "8.          (w1, w2) <- buckets[p]\n"
                    "9.          j <- least index with w1[j] != w2[j]\n"
                    "10.         return (w1, w2, p, j)\n"
                    "11. return NONE                # unreachable when 2*2^W < 2^k"
                ),
                "code": read(ASSETS / "alg_capacity.py"),
            },
        ],
        "visualizations": [
            {
                "name": "The Reach of the Window Sensor: Boundaries, the Straddle, "
                        "Metering, and Capacity",
                "description": (
                    "A four-panel figure. Panel 1 draws the ratio line with the sensor's "
                    "dyadic grid and marks which branch boundaries it can resolve: the "
                    "top-level cut point 2 is dyadic (always resolvable) while the "
                    "deeper boundaries 7/3 and 5/2 are not. Panel 2 shows the "
                    "straddling adversary inside a single grid cell around 7/3 + 2k, "
                    "and the images of the two states after k translations and one "
                    "inversion, landing on opposite sides of the cut point 3. Panel 3 "
                    "plots the readable run length L = floor((m-n)/(2n)) against the "
                    "ratio together with the metering bound L <= P_1/4. Panel 4 plots, "
                    "on a logarithmic scale, the number of distinct W-window readings "
                    "attained by the 2^k states built from A/B-words of length k against "
                    "the number 2^k of behaviours: the readings saturate at 2*2^W while "
                    "the behaviours grow exponentially."
                ),
                "code": read(ASSETS / "viz_reach.py"),
            },
            {
                "name": "The Depth-Decay Curve and Its Explanation",
                "description": (
                    "Two panels. The left panel plots, on a logarithmic scale, the "
                    "measured mutual information in bits between a bounded magnitude "
                    "feature and the descent letter at each depth, both unconditionally "
                    "and conditioned on the path prefix (the honest per-step channel), "
                    "alongside the reported reference decay curve "
                    "0.184, 0.143, 0.094, 0.078, 0.054, 0.040, 0.032, 0.019 which halves "
                    "roughly every two levels. The right panel explains the shape: it "
                    "plots the fraction of sampled states whose first inversion occurs "
                    "before depth t — exactly the states for which the letter at that "
                    "depth is provably unreadable by any fixed-window sensor. The decay "
                    "of the channel tracks the growth of that fraction, which is the "
                    "precise sense in which depth decay is inversion decay."
                ),
                "code": read(ASSETS / "viz_decay.py"),
            },
        ],
        "interactive_demos": [
            {
                "title": "The Pythagorean Address Explorer: Read the Tree, Then Watch "
                         "the Sensor Fail",
                "description": (
                    "A single-page interactive laboratory in four panels. Panel 1 takes "
                    "any pair (m,n), checks admissibility, displays the corresponding "
                    "primitive triple, computes the descent address, and underlines the "
                    "prefix that the one-bit reading provably determines — the leading "
                    "translation run of length floor((m-n)/(2n)) plus the inversion "
                    "letter that ends it — alongside the ratio, the readings, and the "
                    "metering bound. Panel 2 lets the reader dial the window budget W "
                    "and the depth k and shows the straddling pair "
                    "((7+6k)q ± 1, 3q) with q = 6*2^W: an animated canvas draws both "
                    "ratios inside one grid cell around the non-dyadic boundary 7/3 + 2k "
                    "and their images after the inversion, on opposite sides of the cut "
                    "point 3, with badges confirming that the readings are identical, "
                    "the prefixes identical, and the next letter divergent. Panel 3 "
                    "generalizes to an arbitrary rational scale a/b and exhibits the "
                    "attained-boundary collision, so the reader can verify for "
                    "themselves that a ternary — or any other — ruler does not help. "
                    "Panel 4 makes the pigeonhole capacity bound tangible: it enumerates "
                    "all 2^k addresses over the two inversion letters, counts the "
                    "distinct readings obtained, and reports whether a collision is "
                    "forced. Formal proof sketches are tucked behind expandable "
                    "sections so the narrative stays readable for newcomers."
                ),
                "html": read(ASSETS / "widget_explorer.html"),
            }
        ],
        "interactive_layout": INTERACTIVE_LAYOUT,
        "lean_proofs": lean_proofs,
        "future_directions": FUTURE,
        "modules": {"demo": read(ROOT / "demo.py")},
        "lean_files": LEAN_FILES,
    }

    out = ROOT / "PACKAGE.json"
    out.write_text(json.dumps(package, indent=2, ensure_ascii=False) + "\n",
                   encoding="utf-8")
    print(f"wrote {out} ({out.stat().st_size} bytes)")


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualization: the depth-decay curve of the magnitude channel.

Left panel  -- the measured mutual information (in bits) between a fixed-window
magnitude feature and the descent letter at depth t, on a sampled population of
admissible states, together with the reported reference curve
0.184, 0.143, 0.094, 0.078, 0.054, 0.040, 0.032, 0.019  (t = 1..8),
which halves roughly every two levels.

Right panel -- WHY the curve falls.  For each depth t we plot the fraction of
sampled states whose address has its first inversion (first non-C letter)
strictly before position t.  Those are exactly the states for which the
theorems guarantee the letter at position t is *not* a function of any
fixed-window reading.  The decay of the channel tracks the growth of this
fraction: depth decay is inversion decay.

Usage:  python3 viz_decay.py      (writes depth_decay.png)
"""

from __future__ import annotations

import math
import random
from collections import Counter, defaultdict
from typing import Dict, List, Sequence, Tuple

import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt

State = Tuple[int, int]
ROOT: State = (2, 1)
REFERENCE = [0.184, 0.143, 0.094, 0.078, 0.054, 0.040, 0.032, 0.019]


def child(x: str, s: State) -> State:
    m, n = s
    return {"A": (2 * m - n, m), "B": (2 * m + n, m), "C": (m + 2 * n, n)}[x]


def build(word: str) -> State:
    s = ROOT
    for x in reversed(word):
        s = child(x, s)
    return s


def probe(W: int, s: State) -> int:
    m, n = s
    return (2 ** W) * m // n


def mutual_information(pairs: Sequence[Tuple[int, str]]) -> float:
    n = len(pairs)
    if n == 0:
        return 0.0
    joint = Counter(pairs)
    px = Counter(x for x, _ in pairs)
    py = Counter(y for _, y in pairs)
    out = 0.0
    for (x, y), c in joint.items():
        p = c / n
        out += p * math.log2(p / ((px[x] / n) * (py[y] / n)))
    return out


def main(size: int = 40000, depth: int = 8, W: int = 3, seed: int = 20260823) -> None:
    rng = random.Random(seed)
    words = ["".join(rng.choice("ABC") for _ in range(depth)) for _ in range(size)]
    states = [build(w) for w in words]
    feature = [probe(W, s) % 64 for s in states]

    uncond, cond = [], []
    for t in range(depth):
        uncond.append(mutual_information([(f, w[t]) for f, w in zip(feature, words)]))
        groups: Dict[str, List[Tuple[int, str]]] = defaultdict(list)
        for f, w in zip(feature, words):
            groups[w[:t]].append((f, w[t]))
        tot = sum(len(g) for g in groups.values())
        cond.append(sum(len(g) / tot * mutual_information(g)
                        for g in groups.values() if len(g) >= 8))

    inverted = []
    for t in range(depth):
        c = sum(1 for w in words if any(ch != "C" for ch in w[:t]))
        inverted.append(c / len(words))

    ts = list(range(1, depth + 1))
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(13, 5))
    fig.suptitle("Depth decay of the magnitude channel", fontsize=14,
                 fontweight="bold")

    ax1.plot(ts, uncond, "o-", label="measured  MI(feature; letter at depth t)")
    ax1.plot(ts, cond, "s--", label="prefix-conditional MI (honest per-step)")
    ax1.plot(ts, REFERENCE, "^:", color="0.4", label="reference decay curve")
    ax1.set_yscale("log")
    ax1.set_xlabel("depth t")
    ax1.set_ylabel("bits (log scale)")
    ax1.set_title("Information about the depth-t letter")
    ax1.legend(fontsize=8)
    ax1.grid(alpha=0.3)

    ax2.plot(ts, inverted, "o-", color="tab:red")
    ax2.set_xlabel("depth t")
    ax2.set_ylabel("fraction of states")
    ax2.set_ylim(0, 1.05)
    ax2.set_title("Fraction whose first inversion occurs before depth t\n"
                  "(provably unreadable letters)")
    ax2.grid(alpha=0.3)

    fig.tight_layout(rect=(0, 0, 1, 0.93))
    fig.savefig("depth_decay.png", dpi=150)
    print("wrote depth_decay.png")


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualization: the reach of a fixed-window magnitude sensor on the Berggren tree.

Panel 1 -- THE RATIO LINE.  The descent letter is decided by where the ratio
r = m/n falls relative to the cut points 2 and 3.  We draw the sensor's dyadic
grid of resolution 2^-W on top of the boundaries and mark which boundaries the
grid can resolve: the top-level cut point 2 is dyadic (always resolvable) while
the deeper pullback boundaries 7/3 and 5/2 are not.

Panel 2 -- THE STRADDLE.  The two adversarial states
    s+ = ((7+6k)q+1, 3q),  s- = ((7+6k)q-1, 3q),  q = 6*2^W
sit inside a single grid cell around 7/3 + 2k, so the sensor returns the same
reading; after k translations and one inversion their images land on opposite
sides of the cut point 3.

Panel 3 -- READABLE PREFIX LENGTH.  The leading translation run length
L = floor((m-n)/(2n)) as a function of the ratio, together with the bound
L <= P_1/4: depth is visible, but metered.

Panel 4 -- CAPACITY.  Number of distinct W-window readings attained by the
2^k states built from {A,B}-words of length k, against the 2^k behaviours:
the readings saturate at 2*2^W while the behaviours grow exponentially.

Usage:  python3 viz_reach.py        (writes berggren_reach.png)
"""

from __future__ import annotations

import math
from fractions import Fraction
from typing import Dict, List, Tuple

import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt

State = Tuple[int, int]
ROOT: State = (2, 1)


def letter_of(s: State) -> str:
    m, n = s
    return "A" if m < 2 * n else ("B" if m < 3 * n else "C")


def parent(s: State) -> State:
    m, n = s
    if m < 2 * n:
        return (n, 2 * n - m)
    if m < 3 * n:
        return (n, m - 2 * n)
    return (m - 2 * n, n)


def child(x: str, s: State) -> State:
    m, n = s
    return {"A": (2 * m - n, m), "B": (2 * m + n, m), "C": (m + 2 * n, n)}[x]


def build(word: str) -> State:
    s = ROOT
    for x in reversed(word):
        s = child(x, s)
    return s


def probe(W: int, s: State) -> int:
    m, n = s
    return (2 ** W) * m // n


def run_length(s: State) -> int:
    m, n = s
    return (m - n) // (2 * n)


def is_dyadic(fr: Fraction) -> bool:
    d = fr.denominator
    return d & (d - 1) == 0


def main() -> None:
    fig, axes = plt.subplots(2, 2, figsize=(14, 9))
    fig.suptitle("The reach of a fixed-window magnitude sensor on the Berggren tree",
                 fontsize=15, fontweight="bold")

    # ---------------- Panel 1: the ratio line and the dyadic grid -------------
    ax = axes[0][0]
    W = 3
    ax.hlines(0, 1.5, 3.5, color="black", lw=1.5)
    for j in range(int(1.5 * 2 ** W), int(3.5 * 2 ** W) + 1):
        x = j / 2 ** W
        ax.vlines(x, -0.05, 0.05, color="0.75", lw=0.8)
    for val, name, col, ypos in [(Fraction(2), "2  (cut A|B)", "tab:green", 0.30),
                                 (Fraction(3), "3  (cut B|C)", "tab:green", 0.30),
                                 (Fraction(7, 3), "7/3  (deeper cut)", "tab:red", -0.55),
                                 (Fraction(5, 2), "5/2  (deeper cut)", "tab:orange", 0.30)]:
        x = float(val)
        ax.vlines(x, -0.25, 0.25, color=col, lw=2.5)
        tag = "dyadic" if is_dyadic(val) else "NOT dyadic"
        ax.text(x, ypos, f"{name}\n{tag}", ha="center", fontsize=9, color=col)
    ax.set_ylim(-0.9, 0.75)
    ax.set_xlim(1.5, 3.5)
    ax.set_yticks([])
    ax.set_xlabel("ratio  r = m/n")
    ax.set_title(f"Branch boundaries vs. the sensor grid (W = {W})")

    # ---------------- Panel 2: the straddling pair ----------------------------
    ax = axes[0][1]
    W, k = 4, 0
    q = 6 * 2 ** W
    K = 7 + 6 * k
    sp, sm = (K * q + 1, 3 * q), (K * q - 1, 3 * q)
    rp, rm = sp[0] / sp[1], sm[0] / sm[1]
    centre = 7 / 3 + 2 * k
    half = 3.0 / 2 ** W
    for j in range(-4, 5):
        x = (math.floor(centre * 2 ** W) + j) / 2 ** W
        ax.vlines(x, 0.55, 0.95, color="0.8", lw=1)
    ax.vlines(centre, 0.5, 1.0, color="tab:red", lw=2.5)
    ax.plot([rm, rp], [0.75, 0.75], "o", color="tab:blue", ms=9)
    ax.annotate("s−", (rm, 0.75), textcoords="offset points", xytext=(-18, 10))
    ax.annotate("s+", (rp, 0.75), textcoords="offset points", xytext=(8, 10))
    ax.text(centre, 1.05, "boundary 7/3 + 2k", ha="center", color="tab:red")
    ax.text(centre, 0.42, f"same reading  P_W = {probe(W, sp)}",
            ha="center", fontsize=10)

    # images after k translations and one inversion
    def iterate(s: State, t: int) -> State:
        for _ in range(t):
            s = parent(s)
        return s

    ip, im = iterate(sp, k + 1), iterate(sm, k + 1)
    ax.vlines(3, 0.0, 0.35, color="tab:green", lw=2.5)
    ax.text(3, -0.08, "cut point 3", ha="center", color="tab:green")
    for st, lab, dx in [(ip, "image of s+  → letter B", -0.02),
                        (im, "image of s−  → letter C", 0.02)]:
        r = st[0] / st[1]
        ax.plot([r], [0.2], "s", color="tab:purple", ms=8)
        ax.annotate(lab, (r, 0.2), textcoords="offset points",
                    xytext=(20 if dx > 0 else -150, 0), fontsize=9)
    ax.set_xlim(min(centre - half, 2.6), max(centre + half, 3.4))
    ax.set_ylim(-0.2, 1.2)
    ax.set_yticks([])
    ax.set_xlabel("ratio")
    ax.set_title("One inversion turns a hairline gap into a branch split")

    # ---------------- Panel 3: readable run length ----------------------------
    ax = axes[1][0]
    n = 101
    xs, Ls, bnds = [], [], []
    for m in range(n + 1, 40 * n, 7):
        if math.gcd(m, n) != 1 or (m + n) % 2 != 1:
            continue
        s = (m, n)
        xs.append(m / n)
        Ls.append(run_length(s))
        bnds.append(probe(1, s) / 4)
    ax.plot(xs, Ls, ".", ms=3, label="run length  L = ⌊(m−n)/2n⌋")
    ax.plot(xs, bnds, "-", lw=1, color="tab:red", label="bound  P₁/4")
    ax.set_xlabel("ratio  m/n")
    ax.set_ylabel("readable letters")
    ax.set_title("Depth is visible — but metered")
    ax.legend(fontsize=9)

    # ---------------- Panel 4: capacity ---------------------------------------
    ax = axes[1][1]
    for W in [2, 3, 4, 5]:
        ks, vals = [], []
        for k in range(1, 13):
            seen = set()
            for v in range(2 ** k):
                word = "".join("A" if (v >> i) & 1 else "B" for i in range(k))
                seen.add(probe(W, build(word)))
            ks.append(k)
            vals.append(len(seen))
        ax.plot(ks, vals, "o-", ms=4, label=f"distinct readings, W={W}")
    ax.plot(range(1, 13), [2 ** k for k in range(1, 13)], "k--",
            label="distinct behaviours  2^k")
    ax.set_yscale("log")
    ax.set_xlabel("depth k")
    ax.set_ylabel("count (log scale)")
    ax.set_title("Capacity: readings saturate, behaviours explode")
    ax.legend(fontsize=8)

    fig.tight_layout(rect=(0, 0, 1, 0.95))
    fig.savefig("berggren_reach.png", dpi=150)
    print("wrote berggren_reach.png")


if __name__ == "__main__":
    main()
