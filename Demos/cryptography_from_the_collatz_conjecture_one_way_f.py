"""
demo.py — Numerical demonstrations for
"Cryptography from the Collatz Conjecture: A Formally Verified Separation of
One-Wayness and Collision Resistance"

This script is fully self-contained (standard library only) and reproduces the
key results of the formalization:

  * T(1) = T(8) = 4                         (single-step Collatz collision)
  * mdHash(collatzCompress, 0, [1]) = ... = [8]   (hash collision)
  * extraction of a compression-function collision from the hash collision
  * a census of small compression collisions (pigeonhole inevitability)
  * empirical backward-tree growth vs. the naive 2^a bound

Run:  python demo.py
"""

from __future__ import annotations

from typing import Callable, List, Tuple, Optional, Set, Dict


# ---------------------------------------------------------------------------
# Core definitions (mirroring the Lean source)
# ---------------------------------------------------------------------------

def collatz_step(n: int) -> int:
    """The Collatz step map T:  n/2 if n is even, 3n+1 if n is odd.

    Mirrors the Lean definition `T`.
    """
    if n % 2 == 0:
        return n // 2
    return 3 * n + 1


def collatz_compress(s: int, b: int) -> int:
    """The additive Merkle-Damgard compression function: T(s + b).

    Mirrors the Lean definition `collatzCompress`.
    """
    return collatz_step(s + b)


def md_hash(f: Callable[[int, int], int], iv: int, msg: List[int]) -> int:
    """The Merkle-Damgard iterated hash: left-fold f over the blocks from iv.

    Mirrors the Lean definition `mdHash`.
    """
    state = iv
    for block in msg:
        state = f(state, block)
    return state


# ---------------------------------------------------------------------------
# Demonstration 1 — the single-step Collatz collision  (T_one_eq_T_eight)
# ---------------------------------------------------------------------------

def demo_single_step_collision() -> None:
    t1 = collatz_step(1)   # 1 is odd  -> 3*1 + 1 = 4
    t8 = collatz_step(8)   # 8 is even -> 8 / 2   = 4
    print("== Single-step collision (T_one_eq_T_eight) ==")
    print(f"  T(1) = {t1}   (1 is odd:  3*1 + 1)")
    print(f"  T(8) = {t8}   (8 is even: 8 / 2)")
    print(f"  T(1) == T(8) : {t1 == t8}")
    assert t1 == t8 == 4
    print()


# ---------------------------------------------------------------------------
# Demonstration 2 — the hash collision  (collatzHash_collision_value)
# ---------------------------------------------------------------------------

def demo_hash_collision() -> None:
    m1: List[int] = [1]
    m2: List[int] = [8]
    h1 = md_hash(collatz_compress, 0, m1)
    h2 = md_hash(collatz_compress, 0, m2)
    print("== Hash collision (collatzHash_collision_value) ==")
    print(f"  mdHash(collatzCompress, 0, {m1}) = {h1}")
    print(f"  mdHash(collatzCompress, 0, {m2}) = {h2}")
    print(f"  distinct messages? {m1 != m2}   equal length? {len(m1) == len(m2)}")
    print(f"  collision? {h1 == h2}")
    assert m1 != m2 and len(m1) == len(m2) and h1 == h2
    print()


# ---------------------------------------------------------------------------
# Demonstration 3 — collision extraction  (md_collision_extract)
# ---------------------------------------------------------------------------

def extract_compression_collision(
    f: Callable[[int, int], int],
    iv: int,
    m1: List[int],
    m2: List[int],
) -> Optional[Tuple[Tuple[int, int], Tuple[int, int]]]:
    """Constructive Merkle-Damgard collision extraction.

    Given distinct equal-length messages that hash to the same value, returns a
    compression-function collision ((s1, b1), (s2, b2)) with (s1,b1) != (s2,b2)
    and f(s1, b1) = f(s2, b2). Mirrors the proof of `md_collision_extract`:
    compare last blocks; if they (with their chaining states) differ, that is the
    collision, otherwise recurse on the strictly shorter prefixes.
    """
    assert len(m1) == len(m2), "messages must have equal length"
    a, b = list(m1), list(m2)
    while a and b:
        p1, last1 = a[:-1], a[-1]
        p2, last2 = b[:-1], b[-1]
        s1 = md_hash(f, iv, p1)
        s2 = md_hash(f, iv, p2)
        if (s1, last1) != (s2, last2):
            assert f(s1, last1) == f(s2, last2)
            return (s1, last1), (s2, last2)
        a, b = p1, p2
    return None  # unreachable for distinct valid inputs


def demo_extraction() -> None:
    m1, m2 = [1], [8]
    result = extract_compression_collision(collatz_compress, 0, m1, m2)
    print("== Collision extraction (md_collision_extract) ==")
    assert result is not None
    (s1, b1), (s2, b2) = result
    print(f"  extracted compression collision:")
    print(f"    (s, b)   = ({s1}, {b1})   -> collatzCompress = {collatz_compress(s1, b1)}")
    print(f"    (s', b') = ({s2}, {b2})   -> collatzCompress = {collatz_compress(s2, b2)}")
    print(f"  inputs distinct? {(s1, b1) != (s2, b2)}   "
          f"outputs equal? {collatz_compress(s1, b1) == collatz_compress(s2, b2)}")
    print()


# ---------------------------------------------------------------------------
# Demonstration 4 — collision census  (compression_collision_of_card)
# ---------------------------------------------------------------------------

def demo_collision_census(bound: int = 12) -> None:
    """Enumerate compression collisions among inputs 0..bound-1 to illustrate
    the pigeonhole inevitability of collisions."""
    seen: Dict[int, Tuple[int, int]] = {}
    collisions: List[Tuple[Tuple[int, int], Tuple[int, int], int]] = []
    for s in range(bound):
        for b in range(bound):
            v = collatz_compress(s, b)
            if v in seen and seen[v] != (s, b):
                collisions.append((seen[v], (s, b), v))
            else:
                seen.setdefault(v, (s, b))
    print(f"== Collision census (compression_collision_of_card), inputs < {bound} ==")
    print(f"  found {len(collisions)} colliding input pairs; first few:")
    for (i1, i2, v) in collisions[:8]:
        print(f"    collatzCompress{i1} = collatzCompress{i2} = {v}")
    print()


# ---------------------------------------------------------------------------
# Demonstration 5 — backward-tree growth vs the naive 2^a bound
# ---------------------------------------------------------------------------

def a_step_preimages(target: int, a: int, search_bound: int) -> Set[int]:
    """All n in [0, search_bound) with T^[a](n) = target."""
    result: Set[int] = set()
    for n in range(search_bound):
        x = n
        for _ in range(a):
            x = collatz_step(x)
        if x == target:
            result.add(n)
    return result


def demo_backward_tree(target: int = 1, max_a: int = 8, search_bound: int = 4096) -> None:
    print("== Backward-tree growth vs naive 2^a bound ==")
    print(f"  counting n < {search_bound} with T^[a](n) = {target}")
    print(f"  {'a':>3} | {'#preimages':>11} | {'2^a':>6}")
    print("  " + "-" * 28)
    for a in range(1, max_a + 1):
        count = len(a_step_preimages(target, a, search_bound))
        print(f"  {a:>3} | {count:>11} | {2 ** a:>6}")
    print("  (true counts grow like c^a with c < 2, well below the naive 2^a)")
    print()


# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------

def main() -> None:
    print("Collatz-based hash: a formally verified collision-resistance failure")
    print("=" * 68)
    print()
    demo_single_step_collision()
    demo_hash_collision()
    demo_extraction()
    demo_collision_census()
    demo_backward_tree()
    print("All demonstrations completed successfully.")


if __name__ == "__main__":
    main()
