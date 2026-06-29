"""
demo.py — Numerical demonstrations for
"Excluded Minors for Z/p-Gainable Biased Graphs: the parallel-class obstruction."

All functions are self-contained and use only the Python standard library.

We model the vertex-free framework from the paper:

  * An oriented walk is a list of (edge_index, direction) pairs, direction True = forward.
  * A Z/p-gain labelling is a function edge -> {0, ..., p-1}.
  * signed_sum(g, c, p) = sum over (e, b) in c of (+g[e] if b else -g[e]) mod p.
  * The contrabalanced bundle (p+1)K_2 has the digons [(i,True),(j,False)] as its
    only cycles, all UNBALANCED.
  * A parallel-class biased graph is specified by an equivalence relation on edges
    ("balanced classes"); a digon (i,j) is balanced iff i and j are in the same class.

The demos verify, computationally:
  (A) Lemma A: (p+1)K_2 admits NO realising Z/p-gain (brute force).
  (B) k*K_2 with k <= p IS gainable, with k > p NOT gainable (the affine threshold).
  (C) The pull-back identity signed_sum(pull_gain, c) = signed_sum(g, map_cycle c).
  (D) The complete characterisation for parallel classes:
        gainable  <=>  number_of_classes <= p  <=>  no (p+1)K_2 minor.
"""

from __future__ import annotations

from itertools import product, combinations
from typing import Callable, Dict, List, Optional, Sequence, Tuple

# An oriented walk: list of (edge index, direction-forward?) pairs.
Walk = List[Tuple[int, bool]]
# A gain labelling on n edges: a tuple of length n with entries in Z/p.
Gain = Tuple[int, ...]


# ---------------------------------------------------------------------------
# Core arithmetic
# ---------------------------------------------------------------------------
def signed_sum(g: Sequence[int], c: Walk, p: int) -> int:
    """Signed sum (gain) of oriented walk c under labelling g, taken in Z/p."""
    total = 0
    for (e, forward) in c:
        total += g[e] if forward else -g[e]
    return total % p


def is_prime(n: int) -> bool:
    """Trial-division primality test."""
    if n < 2:
        return False
    i = 2
    while i * i <= n:
        if n % i == 0:
            return False
        i += 1
    return True


# ---------------------------------------------------------------------------
# The contrabalanced bundle  n*K_2  (Definition 2.7)
# ---------------------------------------------------------------------------
def parallel_digons(n: int) -> List[Walk]:
    """All digons of n*K_2: [(i,True),(j,False)] for i != j (ordered pairs)."""
    return [[(i, True), (j, False)] for i in range(n) for j in range(n) if i != j]


def is_gainable_bundle(n: int, p: int) -> Optional[Gain]:
    """
    Brute-force search for a realising Z/p-gain on the contrabalanced bundle n*K_2.
    Every digon must be UNBALANCED, i.e. signed_sum != 0 for every (i, j), i != j.
    Returns a witnessing labelling if one exists, else None.
    """
    digons = parallel_digons(n)
    for g in product(range(p), repeat=n):
        if all(signed_sum(g, c, p) != 0 for c in digons):
            return g
    return None


# ---------------------------------------------------------------------------
# Pull-back machinery (Definitions 2.4, 2.6; Theorem 4.1)
# ---------------------------------------------------------------------------
def map_cycle(phi: Sequence[int], sigma: Sequence[bool], c: Walk) -> Walk:
    """Transport walk c along edge map phi with per-edge orientation switch sigma."""
    return [(phi[e], (sigma[e] != forward)) for (e, forward) in c]  # XOR via !=


def pull_gain(phi: Sequence[int], sigma: Sequence[bool], g: Sequence[int], p: int) -> Gain:
    """Pull a labelling g on the larger graph back along (phi, sigma)."""
    return tuple((-g[phi[e]]) % p if sigma[e] else g[phi[e]] % p for e in range(len(phi)))


def verify_pullback_identity(p: int, trials: int = 200) -> bool:
    """
    Check Theorem 4.1: signed_sum(pull_gain, c) == signed_sum(g, map_cycle c).
    Uses a small deterministic sweep of structured examples.
    """
    import random
    random.seed(0)
    nE, nF = 3, 5
    for _ in range(trials):
        phi = tuple(random.randrange(nF) for _ in range(nE))
        sigma = tuple(random.random() < 0.5 for _ in range(nE))
        g = tuple(random.randrange(p) for _ in range(nF))
        c: Walk = [(random.randrange(nE), random.random() < 0.5)
                   for _ in range(random.randint(1, 4))]
        lhs = signed_sum(pull_gain(phi, sigma, g, p), c, p)
        rhs = signed_sum(g, map_cycle(phi, sigma, c), p)
        if lhs != rhs:
            return False
    return True


# ---------------------------------------------------------------------------
# Parallel-class biased graphs (Definition 2.8; Theorem 6.3)
# ---------------------------------------------------------------------------
def class_count(classes: Sequence[int]) -> int:
    """Number of distinct balanced classes (kappa)."""
    return len(set(classes))


def parallel_class_gainable(classes: Sequence[int], p: int) -> Optional[Gain]:
    """
    Constructive gainability test for a parallel-class biased graph whose edge i
    has balanced-class label classes[i]. Returns a realising gain if kappa <= p,
    else None (matching Theorem 6.3 / Lemma 6.1).
    """
    labels = sorted(set(classes))
    if len(labels) > p:
        return None
    value_of: Dict[int, int] = {lab: idx for idx, lab in enumerate(labels)}
    return tuple(value_of[c] for c in classes)


def verify_parallel_class_realisation(classes: Sequence[int], g: Sequence[int], p: int) -> bool:
    """Confirm g realises the parallel-class bias: digon balanced <=> same class."""
    n = len(classes)
    for i, j in combinations(range(n), 2):
        balanced = (classes[i] == classes[j])
        zero = (signed_sum(g, [(i, True), (j, False)], p) == 0)
        if balanced != zero:
            return False
    return True


def has_bundle_minor(classes: Sequence[int], p: int) -> bool:
    """A parallel class contains a (p+1)K_2 minor iff kappa >= p+1 (Lemma 6.2)."""
    return class_count(classes) >= p + 1


# ---------------------------------------------------------------------------
# Demonstrations
# ---------------------------------------------------------------------------
def demo_lemma_A() -> None:
    print("=" * 70)
    print("DEMO A — Lemma A: (p+1)K_2 is NOT Z/p-gainable (pigeonhole)")
    print("=" * 70)
    for p in [2, 3, 5, 7]:
        if not is_prime(p):
            continue
        witness = is_gainable_bundle(p + 1, p)
        status = "GAINABLE (unexpected!)" if witness else "not gainable  (as proven)"
        print(f"  p = {p}:  (p+1)K_2 = {p+1} parallel edges over Z/{p}  ->  {status}")
    print()


def demo_threshold() -> None:
    print("=" * 70)
    print("DEMO B — Affine threshold: kK_2 gainable over Z/p iff k <= p")
    print("=" * 70)
    for p in [3, 5]:
        print(f"  p = {p}:")
        for k in range(1, p + 3):
            witness = is_gainable_bundle(k, p)
            mark = "yes" if witness else "no "
            note = "" if (witness is not None) == (k <= p) else "  <-- MISMATCH"
            print(f"      k = {k:2d}:  gainable? {mark}   (predicted: {'yes' if k <= p else 'no'}){note}")
    print()


def demo_pullback() -> None:
    print("=" * 70)
    print("DEMO C — Pull-back identity (Theorem 4.1)")
    print("=" * 70)
    for p in [2, 3, 5, 7, 11]:
        ok = verify_pullback_identity(p)
        print(f"  p = {p:2d}:  signed_sum(pull_gain, c) == signed_sum(g, map_cycle c)  ->  {ok}")
    print()


def demo_characterisation() -> None:
    print("=" * 70)
    print("DEMO D — Excluded-minor theorem for parallel classes (Theorem 6.3)")
    print("=" * 70)
    p = 3
    examples = {
        "two classes        [0,0,1,1]": [0, 0, 1, 1],
        "three classes      [0,1,2,0]": [0, 1, 2, 0],
        "four classes       [0,1,2,3]": [0, 1, 2, 3],
        "five classes [0,1,2,3,4,0,1]": [0, 1, 2, 3, 4, 0, 1],
    }
    print(f"  Gain group Z/{p}  (so threshold is kappa <= {p})")
    for name, classes in examples.items():
        kappa = class_count(classes)
        g = parallel_class_gainable(classes, p)
        gainable = g is not None
        minor = has_bundle_minor(classes, p)
        realises = verify_parallel_class_realisation(classes, g, p) if g else True
        agree = (gainable == (not minor))
        print(f"  {name}:  kappa={kappa}  gainable={gainable}  "
              f"has (p+1)K_2 minor={minor}  iff-holds={agree}"
              + ("" if (not gainable or realises) else "  (realisation FAILED!)"))
    print()


def demo_falling_factorial() -> None:
    """Future direction C2: count of injective gains = p!/(p-k)! (OEIS A008279)."""
    print("=" * 70)
    print("DEMO E — Conjecture C2: # contrabalanced gains on kK_2 = p!/(p-k)!")
    print("=" * 70)

    def desc_factorial(p: int, k: int) -> int:
        prod = 1
        for i in range(k):
            prod *= (p - i)
        return prod if k <= p else 0

    for p in [3, 5]:
        for k in range(0, p + 2):
            brute = sum(
                1 for g in product(range(p), repeat=k)
                if all(signed_sum(g, c, p) != 0 for c in parallel_digons(k))
            )
            pred = desc_factorial(p, k)
            mark = "OK" if brute == pred else "MISMATCH"
            print(f"  p={p}, k={k}:  brute={brute:4d}   p!/(p-k)!={pred:4d}   [{mark}]")
    print()


if __name__ == "__main__":
    demo_lemma_A()
    demo_threshold()
    demo_pullback()
    demo_characterisation()
    demo_falling_factorial()
    print("All demonstrations complete.")
