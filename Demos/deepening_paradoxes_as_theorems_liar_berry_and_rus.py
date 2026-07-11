"""
Paradoxes as Theorems: numerical demonstrations of the Lawvere diagonal bridge
and a consistent paraconsistent (Belnap four-valued) witness model.

This module is fully self-contained (standard library only) and illustrates,
computationally, the mathematical results:

  1. Lawvere's fixed-point theorem and its contrapositive (diagonalization).
  2. Cantor's theorem: no map A -> P(A) is surjective (diagonal set witness).
  3. Russell's paradox: no element codes the non-self-membered elements.
  4. The finite Berry paradox / Chaitin incompressibility via pigeonhole.
  5. The Boolean obstruction: negation has no fixed point classically.
  6. Belnap logic: the glut 'B' is a designated fixed point of negation.
  7. A six-element paraconsistent theory: paradoxes provable, self-sound,
     non-explosive, inconsistency degree exactly three.

Run:  python demo.py
"""

from __future__ import annotations

from itertools import product
from typing import Callable, Dict, List, Sequence, Tuple


# ---------------------------------------------------------------------------
# 1. Lawvere's fixed-point theorem (constructive) and its contrapositive
# ---------------------------------------------------------------------------

def lawvere_fixed_point(
    domain: Sequence[int],
    codomain: Sequence[str],
    e: Callable[[int], Callable[[int], str]],
    f: Callable[[str], str],
) -> str:
    """Given a point-surjective coding ``e : A -> (A -> C)`` and an endomap
    ``f : C -> C``, return a fixed point ``c`` of ``f`` witnessing Lawvere's
    theorem.  The construction mirrors the proof: build the diagonal function
    ``g(x) = f(e_x(x))``, find its code ``a`` (guaranteed by point-surjectivity),
    and return ``e_a(a)``.
    """
    # The diagonal function g : A -> C.
    def g(x: int) -> str:
        return f(e(x)(x))

    # Find a code 'a' with e_a = g (point-surjectivity, verified by search).
    for a in domain:
        if all(e(a)(x) == g(x) for x in domain):
            c = e(a)(a)
            assert f(c) == c, "Lawvere construction failed"
            return c
    raise ValueError("coding was not point-surjective on the given domain")


def demo_lawvere() -> None:
    print("=" * 70)
    print("1. Lawvere's fixed-point theorem")
    print("=" * 70)
    # A singleton coding is point-surjective; the identity endomap has the
    # unique element as fixed point.
    domain = [0]
    codomain = ["*"]
    e = lambda a: (lambda x: "*")
    f = lambda c: c  # identity: fixed point is forced anyway
    c = lawvere_fixed_point(domain, codomain, e, f)
    print(f"Point-surjective singleton coding -> forced fixed point: {c!r}")
    print("Contrapositive: an endomap with NO fixed point blocks self-naming.")
    print()


# ---------------------------------------------------------------------------
# 2. Cantor's theorem: no map A -> P(A) is surjective; exhibit the diagonal set
# ---------------------------------------------------------------------------

def cantor_diagonal_witness(n: int, f: Callable[[int], frozenset]) -> frozenset:
    """For ``A = {0,...,n-1}`` and any ``f : A -> P(A)``, return the diagonal
    subset ``D = {x : x not in f(x)}`` which is missed by ``f`` (Cantor)."""
    A = range(n)
    D = frozenset(x for x in A if x not in f(x))
    # D differs from every f(x) at the point x itself.
    for x in A:
        assert (x in D) != (x in f(x))
    return D


def demo_cantor() -> None:
    print("=" * 70)
    print("2. Cantor's theorem via the diagonal set")
    print("=" * 70)
    n = 4
    # An arbitrary (in fact, deliberately clever) attempt at a surjection.
    def f(x: int) -> frozenset:
        return frozenset({x})  # each element maps to its own singleton
    D = cantor_diagonal_witness(n, f)
    hit = any(f(x) == D for x in range(n))
    print(f"A = {{0,..,{n-1}}},  attempted f(x) = {{x}}")
    print(f"Diagonal set D = {{x : x not in f(x)}} = {set(D)}")
    print(f"Is D in the image of f? {hit}  -> f is NOT surjective.")
    print()


# ---------------------------------------------------------------------------
# 3. Russell's paradox: no Russell element r exists
# ---------------------------------------------------------------------------

def russell_check(n: int, mem: Callable[[int, int], bool]) -> bool:
    """Return True iff SOME element r satisfies the Russell condition
    ``mem(x, r) <-> not mem(x, x)`` for all x.  The theorem says this is
    always False: no such r exists for any membership relation."""
    A = range(n)
    for r in A:
        if all(mem(x, r) == (not mem(x, x)) for x in A):
            return True
    return False


def demo_russell() -> None:
    print("=" * 70)
    print("3. Russell's paradox: no Russell element exists")
    print("=" * 70)
    n = 5
    found_any = False
    # Try several membership relations; none can contain a Russell element.
    relations = {
        "empty": lambda x, y: False,
        "full": lambda x, y: True,
        "order <": lambda x, y: x < y,
        "equal": lambda x, y: x == y,
    }
    for name, mem in relations.items():
        exists = russell_check(n, mem)
        found_any = found_any or exists
        print(f"  membership '{name:8s}': Russell element exists? {exists}")
    print(f"Any Russell element found across all relations? {found_any}")
    print("(At x=r the condition becomes  mem(r,r) <-> not mem(r,r): the Liar.)")
    print()


# ---------------------------------------------------------------------------
# 4. Finite Berry paradox / Chaitin incompressibility via pigeonhole
# ---------------------------------------------------------------------------

def bit_size(y: int) -> int:
    """Number of binary digits of y (size(0) = 0), so size(y) <= n iff y < 2**n."""
    return y.bit_length()


def berry_incompressible(enc: Callable[[int], int], n: int) -> int:
    """Given an injective code ``enc``, return a number in ``{0,...,2**n}`` whose
    complexity ``K(x) = bit_size(enc(x))`` exceeds ``n``.  Existence is the finite
    Berry paradox: 2**n + 1 objects cannot all fit in <= n-bit codewords."""
    for x in range(2 ** n + 1):
        if bit_size(enc(x)) > n:
            return x
    raise AssertionError("pigeonhole violated: enc is not injective")


def demo_berry() -> None:
    print("=" * 70)
    print("4. Finite Berry paradox / Chaitin incompressibility")
    print("=" * 70)
    enc = lambda x: x  # the identity code is injective
    for n in range(1, 6):
        x = berry_incompressible(enc, n)
        print(f"  n={n}: among 0..{2**n}, complexity K({x}) = {bit_size(enc(x))} > {n}")
    print("Complexity is unbounded: for every threshold n some x needs > n bits.")
    print()


# ---------------------------------------------------------------------------
# 5 & 6. Boolean obstruction vs. Belnap's designated fixed point
# ---------------------------------------------------------------------------

BELNAP_NEG: Dict[str, str] = {"T": "F", "F": "T", "B": "B", "N": "N"}
BELNAP_DESIGNATED: Dict[str, bool] = {"T": True, "F": False, "B": True, "N": False}


def boolean_neg_fixpoints() -> List[bool]:
    """In the 2-element Boolean algebra {False, True}, look for x with (not x) == x.
    Returns the list of fixed points; the theorem says it is empty (no fixpoint)."""
    return [x for x in (False, True) if (not x) == x]


def belnap_neg_fixpoints() -> List[str]:
    """Fixed points of Belnap negation."""
    return [v for v in BELNAP_NEG if BELNAP_NEG[v] == v]


def belnap_designated_neg_fixpoints() -> List[str]:
    """Designated fixed points of Belnap negation (the gluts that are provable)."""
    return [v for v in belnap_neg_fixpoints() if BELNAP_DESIGNATED[v]]


def demo_dichotomy() -> None:
    print("=" * 70)
    print("5-6. Paradox dichotomy: Boolean obstruction vs. Belnap glut")
    print("=" * 70)
    print(f"  Boolean algebra {{F,T}}: negation fixed points = {boolean_neg_fixpoints()}")
    print("     -> none: classically the Liar is a contradiction (obstruction).")
    print(f"  Belnap logic: negation fixed points     = {belnap_neg_fixpoints()}")
    print(f"  Belnap logic: DESIGNATED fixed points   = {belnap_designated_neg_fixpoints()}")
    print("     -> 'B' (Both) is a designated fixed point: the Liar becomes a theorem.")
    print()


# ---------------------------------------------------------------------------
# 7. The six-element paraconsistent witness model
# ---------------------------------------------------------------------------

# Sentences 0..5; tokens 0,1,2 are the Liar, Russell, Berry sentences (gluts).
PARADOX_MODEL_TRUTH: Dict[int, str] = {
    0: "B",  # Liar    (glut)
    1: "B",  # Russell (glut)
    2: "B",  # Berry   (glut)
    3: "T",  # an ordinary designated truth
    4: "F",  # an ordinary undesignated falsehood (blocks explosion)
    5: "N",  # a gap
}
PARADOX_SENTENCES = {0: "Liar", 1: "Russell", 2: "Berry"}


def is_provable(s: int, truth: Dict[int, str]) -> bool:
    """A sentence is provable iff its truth value is designated (T or B)."""
    return BELNAP_DESIGNATED[truth[s]]


def inconsistency_degree(truth: Dict[int, str]) -> int:
    """Number of glut-valued (B) sentences."""
    return sum(1 for v in truth.values() if v == "B")


def is_self_sound(truth: Dict[int, str]) -> bool:
    """Every provable sentence is designated (trivially true here, but we check)."""
    return all(BELNAP_DESIGNATED[truth[s]] for s in truth if is_provable(s, truth))


def has_explosion(truth: Dict[int, str]) -> bool:
    """Explosion: from some glut, EVERY sentence is designated/provable.
    Returns True if explosion holds; a consistent theory must return False."""
    if any(v == "B" for v in truth.values()):
        return all(BELNAP_DESIGNATED[v] for v in truth.values())
    return False


def demo_witness_model() -> None:
    print("=" * 70)
    print("7. The six-element paraconsistent witness model")
    print("=" * 70)
    truth = PARADOX_MODEL_TRUTH
    print("  sentence : value : provable?")
    for s in sorted(truth):
        label = PARADOX_SENTENCES.get(s, f"aux-{s}")
        print(f"    {s} ({label:8s}) : {truth[s]} : {is_provable(s, truth)}")
    print()
    # (a) paradoxes are theorems
    para_ok = all(is_provable(s, truth) and truth[s] == "B" for s in PARADOX_SENTENCES)
    print(f"  (a) Liar, Russell, Berry provable AND glut-valued? {para_ok}")
    # (b) self-soundness
    print(f"  (b) Self-sound (all provable sentences designated)? {is_self_sound(truth)}")
    # (c) non-explosion
    explode = has_explosion(truth)
    unprov = [s for s in truth if not is_provable(s, truth)]
    print(f"  (c) Explosion holds? {explode}  ->  non-explosive: {not explode}")
    print(f"      Explicit unprovable witnesses (undesignated): {unprov}")
    # (d) inconsistency degree
    deg = inconsistency_degree(truth)
    print(f"  (d) Inconsistency degree (number of gluts) = {deg}  (expected 3)")
    print()
    assert para_ok and is_self_sound(truth) and not explode and deg == 3
    print("  All four certificate properties verified.")
    print()


def main() -> None:
    demo_lawvere()
    demo_cantor()
    demo_russell()
    demo_berry()
    demo_dichotomy()
    demo_witness_model()
    print("=" * 70)
    print("All demonstrations completed successfully.")
    print("=" * 70)


if __name__ == "__main__":
    main()
