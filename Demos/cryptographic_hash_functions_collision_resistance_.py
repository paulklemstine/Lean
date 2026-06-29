"""
Collision Resistance from Hard Problems: The Claw-Free Route through
Merkle-Damgard.

Numerical companion to the formal development. Every function is self-contained
and type-hinted. The demos exercise the *main theorems*:

  * md_collision_extract            -- an equal-length MD collision yields a
                                       compression collision (Algorithm A).
  * claw_iff_compression_collision  -- for injective permutations, compression
                                       collisions ARE claws (Theorem 3.5).
  * clawFree_mdHash_injOn_length    -- claw-freeness lifts to injectivity of the
                                       iterated hash (the headline reduction).
  * compression_collision_of_card   -- collisions always exist (pigeonhole).
  * concrete_claw / concrete_*      -- the explicit Z/2 non-vacuity witness.

Run:  python demo.py
"""

from __future__ import annotations

from itertools import product
from typing import Callable, Dict, List, Optional, Tuple

State = int
Block = bool

# --------------------------------------------------------------------------- #
#  Core constructions (mirroring the Lean definitions)
# --------------------------------------------------------------------------- #


def md_hash(
    f: Callable[[State, Block], State], iv: State, msg: List[Block]
) -> State:
    """Merkle-Damgard iterated hash: left-fold f over the message blocks.

    Mirrors `mdHash f iv msg = msg.foldl f iv`.
    """
    s = iv
    for b in msg:
        s = f(s, b)
    return s


def claw_compress(
    g0: Callable[[State], State], g1: Callable[[State], State]
) -> Callable[[State, Block], State]:
    """The Damgard one-bit-block compression function.

    Mirrors `clawCompress g0 g1 s b = bif b then g1 s else g0 s`.
    """

    def f(s: State, b: Block) -> State:
        return g1(s) if b else g0(s)

    return f


def is_claw(
    g0: Callable[[State], State],
    g1: Callable[[State], State],
    x: State,
    y: State,
) -> bool:
    """Mirrors `IsClaw g0 g1 x y := g0 x = g1 y`."""
    return g0(x) == g1(y)


# --------------------------------------------------------------------------- #
#  Search routines (constructive content of the proofs)
# --------------------------------------------------------------------------- #


def find_claw(
    g0: Callable[[State], State],
    g1: Callable[[State], State],
    domain: List[State],
) -> Optional[Tuple[State, State]]:
    """Exhaustively search for a claw (x, y) with g0 x = g1 y over `domain`."""
    for x in domain:
        for y in domain:
            if is_claw(g0, g1, x, y):
                return (x, y)
    return None


def find_compression_collision(
    f: Callable[[State, Block], State], domain: List[State]
) -> Optional[Tuple[Tuple[State, Block], Tuple[State, Block]]]:
    """Find a compression collision: distinct (s, b) != (s', b') with equal
    output. Realizes the witness of `HasCompressionCollision`."""
    seen: Dict[State, Tuple[State, Block]] = {}
    for s, b in product(domain, (False, True)):
        out = f(s, b)
        if out in seen and seen[out] != (s, b):
            return (seen[out], (s, b))
        seen.setdefault(out, (s, b))
    return None


def extract_compression_collision(
    f: Callable[[State, Block], State],
    iv: State,
    m1: List[Block],
    m2: List[Block],
) -> Tuple[Tuple[State, Block], Tuple[State, Block]]:
    """Algorithm A: turn an equal-length MD collision into a compression
    collision, walking from the last block inward (proof of
    `md_collision_extract`)."""
    assert len(m1) == len(m2), "messages must have equal length"
    assert m1 != m2, "messages must differ"
    assert md_hash(f, iv, m1) == md_hash(f, iv, m2), "inputs must collide"

    a, b = list(m1), list(m2)
    while True:
        # chaining values feeding the final block of each (current) message
        c1 = md_hash(f, iv, a[:-1])
        c2 = md_hash(f, iv, b[:-1])
        in1, in2 = (c1, a[-1]), (c2, b[-1])
        if in1 != in2:
            assert f(*in1) == f(*in2)
            return (in1, in2)
        # equal last inputs => strictly shorter equal-length colliding prefixes
        a, b = a[:-1], b[:-1]


def collision_to_claw(
    collision: Tuple[Tuple[State, Block], Tuple[State, Block]]
) -> Tuple[State, State]:
    """Algorithm B: convert a compression collision of clawCompress into a claw,
    using the differing bits (proof of `clawCompress_collision_to_claw`)."""
    (s, b), (s2, b2) = collision
    if b == b2:
        raise ValueError(
            "same-bit collision: only possible if a permutation is non-injective"
        )
    # differing bits: orient so the 'false' side is g0 and 'true' side is g1.
    return (s, s2) if (b is False and b2 is True) else (s2, s)


# --------------------------------------------------------------------------- #
#  A concrete claw-free-style instance: affine permutations mod n
# --------------------------------------------------------------------------- #


def affine_perm(a: int, c: int, n: int) -> Callable[[State], State]:
    """x -> a*x + c (mod n). A permutation iff gcd(a, n) = 1."""

    def g(x: State) -> State:
        return (a * x + c) % n

    return g


# --------------------------------------------------------------------------- #
#  Demonstrations
# --------------------------------------------------------------------------- #


def demo_concrete_z2_witness() -> None:
    """Non-vacuity witness over Z/2 (concrete_claw / concrete_compression_*)."""
    print("=" * 70)
    print("DEMO 1: Explicit Z/2 witness  (concrete_claw)")
    print("=" * 70)
    n = 2
    g0 = affine_perm(1, 0, n)  # identity  (g0Ex)
    g1 = affine_perm(1, 1, n)  # x + 1     (g1Ex)
    dom = list(range(n))
    claw = find_claw(g0, g1, dom)
    print(f"  g0 = id, g1 = (.+1) on Z/{n}")
    print(f"  claw found: (x, y) = {claw}  =>  g0(x)={g0(claw[0])}, "
          f"g1(y)={g1(claw[1])}")
    f = claw_compress(g0, g1)
    coll = find_compression_collision(f, dom)
    print(f"  induced compression collision: {coll}")
    assert claw is not None and is_claw(g0, g1, *claw)
    # The Lean witness `concrete_claw` is the specific claw g0(1) = 1 = g1(0).
    assert is_claw(g0, g1, 1, 0) and g0(1) == 1 == g1(0)
    print("  -> Lean `concrete_claw` witness verified: g0(1) = 1 = g1(0).\n")


def demo_iff_collision_equals_claw() -> None:
    """Theorem 3.5: for injective permutations, collision <=> claw."""
    print("=" * 70)
    print("DEMO 2: Collision <=> Claw equivalence  (claw_iff_compression_collision)")
    print("=" * 70)
    n = 7
    g0 = affine_perm(2, 1, n)  # gcd(2,7)=1 -> permutation
    g1 = affine_perm(3, 5, n)  # gcd(3,7)=1 -> permutation
    dom = list(range(n))
    f = claw_compress(g0, g1)

    claw = find_claw(g0, g1, dom)
    coll = find_compression_collision(f, dom)
    print(f"  affine permutations mod {n}: g0=2x+1, g1=3x+5")
    print(f"  claw:               {claw}")
    print(f"  compression collision: {coll}")
    # forward: claw -> collision
    x, y = claw
    assert f(x, False) == f(y, True)
    # backward: collision -> claw (Algorithm B)
    recovered = collision_to_claw(coll)
    assert is_claw(g0, g1, *recovered)
    print(f"  collision -> claw (Algorithm B): {recovered}  (verified)\n")


def demo_md_extraction_headline() -> None:
    """Headline: build an MD collision, extract a compression collision, and
    turn it into a claw (md_collision_extract + clawFree_mdHash_injOn_length)."""
    print("=" * 70)
    print("DEMO 3: MD collision -> compression collision -> claw  (Algorithm C)")
    print("=" * 70)
    n = 7
    g0 = affine_perm(2, 1, n)
    g1 = affine_perm(3, 5, n)
    f = claw_compress(g0, g1)
    iv = 0

    # Construct equal-length messages that collide by extending a 1-block
    # compression collision with a shared suffix (length-extension structure).
    base = find_compression_collision(f, list(range(n)))
    (s, b), (s2, b2) = base
    # We need messages that *reach* states s and s2 at the same position. Search
    # short equal-length message pairs for a genuine full-hash collision.
    found: Optional[Tuple[List[Block], List[Block]]] = None
    for L in range(1, 5):
        seen: Dict[State, List[Block]] = {}
        for bits in product((False, True), repeat=L):
            msg = list(bits)
            h = md_hash(f, iv, msg)
            if h in seen and seen[h] != msg:
                found = (seen[h], msg)
                break
            seen.setdefault(h, msg)
        if found:
            break

    assert found is not None, "expected a collision to exist (pigeonhole)"
    m1, m2 = found
    print(f"  iv={iv}, equal-length colliding messages:")
    print(f"    m1 = {[int(x) for x in m1]}  ->  hash {md_hash(f, iv, m1)}")
    print(f"    m2 = {[int(x) for x in m2]}  ->  hash {md_hash(f, iv, m2)}")
    coll = extract_compression_collision(f, iv, m1, m2)
    print(f"  extracted compression collision: {coll}")
    claw = collision_to_claw(coll)
    assert is_claw(g0, g1, *claw)
    print(f"  -> claw: {claw}  g0({claw[0]})={g0(claw[0])} = "
          f"g1({claw[1]})={g1(claw[1])}  (verified)\n")


def demo_pigeonhole_inevitability() -> None:
    """Theorem 2.6: every compression function on a finite domain with >1 block
    has a collision (compression_collision_of_card)."""
    print("=" * 70)
    print("DEMO 4: Collisions are inevitable  (compression_collision_of_card)")
    print("=" * 70)
    n = 5
    dom = list(range(n))
    # A few arbitrary (not necessarily permutation) compression functions.
    funcs: Dict[str, Callable[[State, Block], State]] = {
        "f(s,b)=(s*s + 3b) mod n": lambda s, b: (s * s + 3 * int(b)) % n,
        "f(s,b)=(2s + b) mod n": lambda s, b: (2 * s + int(b)) % n,
        "f(s,b)=(s xor b) mod n": lambda s, b: (s ^ int(b)) % n,
    }
    for name, f in funcs.items():
        coll = find_compression_collision(f, dom)
        status = "collision " + str(coll) if coll else "NONE (impossible!)"
        print(f"  {name:28s}: {status}")
        assert coll is not None
    print("  -> as the pigeonhole theorem guarantees, all have collisions.\n")


def main() -> None:
    print("\nClaw-Free Hashing: numerical demonstrations of the main theorems\n")
    demo_concrete_z2_witness()
    demo_iff_collision_equals_claw()
    demo_md_extraction_headline()
    demo_pigeonhole_inevitability()
    print("All demonstrations completed and self-verified.")


if __name__ == "__main__":
    main()
