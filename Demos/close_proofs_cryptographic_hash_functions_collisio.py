"""
demo.py — Numerical demonstrations of the Merkle-Damgard collision-resistance
results, mirroring the machine-verified theorems.

Everything is self-contained: a toy state/block model, a left-fold hash, an
injective compression function, the collision reduction, the constructive
collision extractor, the length-extension identity, and Merkle-Damgard
strengthening. Run `python demo.py` to see all demonstrations.

The objects below correspond to the formal development:
  merkle_damgard            <->  merkleDamgard f iv msg := msg.foldl f iv
  domain_extension          <->  merkleDamgard_append (Theorem 3.3)
  is_compression_injective  <->  Function.Injective (Function.uncurry f)
  md_collision_to_compress  <->  md_collision_implies_compress_collision (Thm 5.2)
  foldl_convergence         <->  foldl_convergence (Theorem 6.1)
  length_extension          <->  length_extension_property (Theorem 7.1)
  md_strengthen             <->  mdStrengthen (Definition 8.1)
"""

from __future__ import annotations

from itertools import product
from typing import Callable, Hashable, Iterable, Optional, Sequence, Tuple, TypeVar

State = TypeVar("State", bound=Hashable)
Block = TypeVar("Block", bound=Hashable)


# ---------------------------------------------------------------------------
# Core construction: Merkle-Damgard as a left fold (Definition 3.1)
# ---------------------------------------------------------------------------
def merkle_damgard(
    f: Callable[[State, Block], State],
    iv: State,
    msg: Sequence[Block],
) -> State:
    """Iterate the compression function f over the message starting from iv."""
    state = iv
    for block in msg:
        state = f(state, block)
    return state


def domain_extension_holds(
    f: Callable[[State, Block], State],
    iv: State,
    m1: Sequence[Block],
    m2: Sequence[Block],
) -> bool:
    """Theorem 3.3: H(m1 ++ m2) == H_{H(m1)}(m2)."""
    lhs = merkle_damgard(f, iv, list(m1) + list(m2))
    rhs = merkle_damgard(f, merkle_damgard(f, iv, m1), m2)
    return lhs == rhs


# ---------------------------------------------------------------------------
# Injectivity check over a finite test domain
# ---------------------------------------------------------------------------
def is_compression_injective(
    f: Callable[[State, Block], State],
    states: Iterable[State],
    blocks: Iterable[Block],
) -> bool:
    """Check that (state, block) |-> f(state, block) is injective on a finite grid."""
    seen: dict = {}
    for s, b in product(list(states), list(blocks)):
        out = f(s, b)
        if out in seen and seen[out] != (s, b):
            return False
        seen[out] = (s, b)
    return True


# ---------------------------------------------------------------------------
# Theorem 6.1: constructive collision extraction along two chains
# ---------------------------------------------------------------------------
def foldl_convergence(
    f: Callable[[State, Block], State],
    a1: State,
    a2: State,
    msg: Sequence[Block],
) -> Optional[Tuple[State, State, Block]]:
    """
    Given a1 != a2 with H_{a1}(msg) == H_{a2}(msg), walk both chains and return
    the first step (s1, s2, b) with s1 != s2 and f(s1, b) == f(s2, b).
    Returns None if the hypotheses are not met.
    """
    if a1 == a2:
        return None
    if merkle_damgard(f, a1, msg) != merkle_damgard(f, a2, msg):
        return None
    s1, s2 = a1, a2
    for b in msg:
        if f(s1, b) == f(s2, b):
            return (s1, s2, b)  # collision step found
        s1, s2 = f(s1, b), f(s2, b)
    return None  # unreachable given the hypotheses


# ---------------------------------------------------------------------------
# Theorem 5.2: reduce a full-hash collision to a compression collision
# ---------------------------------------------------------------------------
def md_collision_to_compress(
    f: Callable[[State, Block], State],
    iv: State,
    m1: Sequence[Block],
    m2: Sequence[Block],
) -> Optional[Tuple[Tuple[State, Block], Tuple[State, Block]]]:
    """
    Given distinct equal-length messages with the same Merkle-Damgard hash,
    return distinct compression inputs (p1, p2) with f(*p1) == f(*p2).
    """
    if len(m1) != len(m2) or list(m1) == list(m2):
        return None
    if merkle_damgard(f, iv, m1) != merkle_damgard(f, iv, m2):
        return None
    s1, s2 = iv, iv
    for b1, b2 in zip(m1, m2):
        p1, p2 = (s1, b1), (s2, b2)
        if p1 != p2 and f(*p1) == f(*p2):
            return (p1, p2)
        s1, s2 = f(s1, b1), f(s2, b2)
    return None


# ---------------------------------------------------------------------------
# Theorem 7.1: length-extension identity / attack
# ---------------------------------------------------------------------------
def length_extension(
    f: Callable[[State, Block], State],
    known_digest: State,
    suffix: Sequence[Block],
) -> State:
    """
    Compute H(m1 ++ suffix) knowing only h = H(m1), NOT m1 itself.
    This is the length-extension attack: H(m1 ++ s) == H_{h}(s).
    """
    return merkle_damgard(f, known_digest, suffix)


# ---------------------------------------------------------------------------
# Definition 8.1 / Theorem 8.2: Merkle-Damgard strengthening
# ---------------------------------------------------------------------------
def md_strengthen(
    f: Callable[[State, Block], State],
    pad: Callable[[Sequence[Block]], Sequence[Block]],
    iv: State,
    msg: Sequence[Block],
) -> State:
    """Strengthened hash: hash the padded message."""
    return merkle_damgard(f, iv, pad(msg))


# ===========================================================================
# A concrete toy instance
# ===========================================================================
MOD = 257  # a prime; states and blocks are residues mod MOD


def f_injective(state: int, block: int) -> int:
    """
    A compression function that is injective as a pair map on Z_MOD x Z_MOD',
    where blocks are taken from {0, 1} so we can recover (state, block).
    Encoding: f(s, b) = 2*s + b  (mod a large modulus) keeps it injective for
    s in range and b in {0,1}.
    """
    return 2 * state + block


def f_lossy(state: int, block: int) -> int:
    """A deliberately collision-PRONE compression function (mod MOD)."""
    return (state + block) % MOD


def pad_with_length(msg: Sequence[int]) -> Tuple[int, ...]:
    """
    Length-regular injective padding: append the length, then pad with the
    sentinel -1 up to a fixed width. Injective and constant output length
    for the bounded inputs used in the demo (matches the SHA-style length tag).
    """
    width = 8
    body = list(msg) + [len(msg)]
    assert len(body) <= width
    return tuple(body + [-1] * (width - len(body)))


# ===========================================================================
# Demonstrations
# ===========================================================================
def demo_hashing_and_domain_extension() -> None:
    print("=" * 70)
    print("DEMO 1: Hashing and the domain-extension law (Theorem 3.3)")
    print("=" * 70)
    iv = 5
    m1 = [1, 0, 1, 1]
    m2 = [0, 1]
    print(f"  H(iv={iv}, {m1})        = {merkle_damgard(f_injective, iv, m1)}")
    print(f"  H(iv={iv}, {m1}++{m2}) = {merkle_damgard(f_injective, iv, m1 + m2)}")
    ok = domain_extension_holds(f_injective, iv, m1, m2)
    print(f"  domain-extension identity holds: {ok}")
    print()


def demo_injectivity() -> None:
    print("=" * 70)
    print("DEMO 2: Injectivity of the compression function")
    print("=" * 70)
    states = range(0, 64)
    blocks = [0, 1]
    inj = is_compression_injective(f_injective, states, blocks)
    lossy = is_compression_injective(f_lossy, states, blocks)
    print(f"  f_injective injective on grid: {inj}")
    print(f"  f_lossy     injective on grid: {lossy}")
    print()


def demo_collision_reduction() -> None:
    print("=" * 70)
    print("DEMO 3: Collision reduction (Theorem 5.2)")
    print("=" * 70)
    iv = 0
    # f_lossy collides: f(s, b) = (s+b) mod MOD. Find equal-length messages
    # that collide. E.g. swapping order of additions of {1, 256}.
    m1 = [1, 256]
    m2 = [256, 1]
    h1 = merkle_damgard(f_lossy, iv, m1)
    h2 = merkle_damgard(f_lossy, iv, m2)
    print(f"  m1={m1}, m2={m2}")
    print(f"  H(m1)={h1}, H(m2)={h2}, collision: {h1 == h2 and m1 != m2}")
    coll = md_collision_to_compress(f_lossy, iv, m1, m2)
    if coll:
        (p1, p2) = coll
        print(f"  extracted compression collision: f{p1} = {f_lossy(*p1)} "
              f"= f{p2} = {f_lossy(*p2)}, with {p1} != {p2}: {p1 != p2}")
    print()


def demo_constructive_convergence() -> None:
    print("=" * 70)
    print("DEMO 4: Constructive convergence (Theorem 6.1)")
    print("=" * 70)
    # Two distinct start states that converge under f_lossy with same message.
    a1, a2 = 0, MOD  # 0 and 257 are distinct ints but congruent mod MOD after one step
    msg = [3, 7, 2]
    print(f"  a1={a1}, a2={a2}, msg={msg}")
    print(f"  H_a1(msg)={merkle_damgard(f_lossy, a1, msg)}, "
          f"H_a2(msg)={merkle_damgard(f_lossy, a2, msg)}")
    step = foldl_convergence(f_lossy, a1, a2, msg)
    if step:
        s1, s2, b = step
        print(f"  collision step: states {s1} != {s2}, same block {b}, "
              f"f({s1},{b})={f_lossy(s1, b)} = f({s2},{b})={f_lossy(s2, b)}")
    print()


def demo_length_extension() -> None:
    print("=" * 70)
    print("DEMO 5: Length-extension attack (Theorem 7.1)")
    print("=" * 70)
    iv = 9
    secret = [1, 1, 0, 1]          # attacker does NOT know this
    h = merkle_damgard(f_injective, iv, secret)  # attacker only sees h
    suffix = [0, 1, 1]
    forged = length_extension(f_injective, h, suffix)
    genuine = merkle_damgard(f_injective, iv, secret + suffix)
    print(f"  published digest h = {h}  (secret hidden)")
    print(f"  attacker forges H(secret ++ {suffix}) = {forged}")
    print(f"  genuine  H(secret ++ {suffix})        = {genuine}")
    print(f"  forgery succeeds without knowing secret: {forged == genuine}")
    print()


def demo_strengthening() -> None:
    print("=" * 70)
    print("DEMO 6: Merkle-Damgard strengthening (Theorem 8.2)")
    print("=" * 70)
    iv = 0
    # Different-length messages that would be a prefix issue without padding.
    m1 = [1]
    m2 = [1, 0]
    print(f"  raw  H({m1}) = {merkle_damgard(f_injective, iv, m1)}, "
          f"raw H({m2}) = {merkle_damgard(f_injective, iv, m2)}")
    s1 = md_strengthen(f_injective, pad_with_length, iv, m1)
    s2 = md_strengthen(f_injective, pad_with_length, iv, m2)
    print(f"  padded(m1) = {pad_with_length(m1)} -> {s1}")
    print(f"  padded(m2) = {pad_with_length(m2)} -> {s2}")
    print(f"  strengthened hashes differ for different messages: {s1 != s2}")
    print()


def main() -> None:
    demo_hashing_and_domain_extension()
    demo_injectivity()
    demo_collision_reduction()
    demo_constructive_convergence()
    demo_length_extension()
    demo_strengthening()
    print("All demonstrations complete.")


if __name__ == "__main__":
    main()
