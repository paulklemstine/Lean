"""
demo.py — Numerical demonstrations of the Merkle-Damgard monoid-action theory.

This self-contained script illustrates, with concrete toy compression functions
over small finite state spaces, the main results of the package:

  * merkleDamgard / domain extension          (Thm 2.3)
  * joint injectivity of foldl                 (Thm 3.1)
  * collision resistance preservation          (Thm 3.2)
  * the collision reduction                    (Thm 3.3)
  * constructive convergence                   (Thm 3.4)
  * length-extension vulnerability             (Thm 3.5)
  * Merkle-Damgard strengthening (padding)     (Thm 3.7)
  * messages as state transformations (mdEnd)  (Def 4.1, Thm 4.3)
  * the homomorphism mdHom (anti-hom -> hom)   (Thm 5.2)
  * faithful action = IV-free collision res.   (Thm 6.1)
  * the failing converse                       (Thm 7.1)
  * tree hashing collision resistance          (Thm 8.2)

All functions are inlined and use only the standard library.

Run:  python demo.py
"""

from __future__ import annotations

from itertools import product
from typing import Callable, Dict, List, Optional, Tuple, Union

# A compression function maps (state, block) -> state.
Compress = Callable[[int, int], int]


# --------------------------------------------------------------------------- #
# Core construction (Section 2)
# --------------------------------------------------------------------------- #
def merkle_damgard(f: Compress, iv: int, msg: List[int]) -> int:
    """Left fold of the blocks of `msg` into `iv` using `f` (Definition 2.1)."""
    state = iv
    for block in msg:
        state = f(state, block)
    return state


def domain_extension_holds(f: Compress, iv: int,
                           m1: List[int], m2: List[int]) -> bool:
    """Verify Theorem 2.3: H(iv, m1 ++ m2) == H(H(iv, m1), m2)."""
    lhs = merkle_damgard(f, iv, m1 + m2)
    mid = merkle_damgard(f, iv, m1)
    rhs = merkle_damgard(f, mid, m2)
    return lhs == rhs


# --------------------------------------------------------------------------- #
# Toy compression functions over Z_n
# --------------------------------------------------------------------------- #
def make_injective_compress(n: int) -> Compress:
    """
    A compression function over states/blocks in Z_n that is injective as a
    pair function (a, b) -> f(a, b).  We use a bijection Z_n x Z_n -> Z_(n*n)
    reduced back into a wider range; to stay within a usable state space we
    instead embed the pair: f(a, b) = a * n + b  taking states in Z_(n*n).
    """
    def f(a: int, b: int) -> int:
        return a * n + b
    return f


def is_pair_injective(f: Compress, states: List[int], blocks: List[int]) -> bool:
    """Check whether (a, b) -> f(a, b) is injective on the given domains."""
    seen: Dict[int, Tuple[int, int]] = {}
    for a in states:
        for b in blocks:
            v = f(a, b)
            if v in seen:
                return False
            seen[v] = (a, b)
    return True


# --------------------------------------------------------------------------- #
# Collision search (Sections 3.1-3.3)
# --------------------------------------------------------------------------- #
def find_md_collision(f: Compress, iv: int, blocks: List[int],
                      length: int) -> Optional[Tuple[List[int], List[int]]]:
    """
    Brute-force search for two distinct equal-length messages colliding under
    merkle_damgard(f, iv, .).  Returns the colliding pair or None.
    """
    digests: Dict[int, List[int]] = {}
    for combo in product(blocks, repeat=length):
        msg = list(combo)
        d = merkle_damgard(f, iv, msg)
        if d in digests and digests[d] != msg:
            return digests[d], msg
        digests[d] = msg
    return None


def extract_compress_collision(
    f: Compress, iv: int, m1: List[int], m2: List[int]
) -> Optional[Tuple[Tuple[int, int], Tuple[int, int]]]:
    """
    Given an MD collision on equal-length messages (Thm 3.3), walk both folds
    in lockstep and return the first compression-function collision
    (a1, b1) != (a2, b2) with f(a1, b1) == f(a2, b2).
    """
    assert len(m1) == len(m2)
    s1, s2 = iv, iv
    for b1, b2 in zip(m1, m2):
        out1, out2 = f(s1, b1), f(s2, b2)
        if (s1, b1) != (s2, b2) and out1 == out2:
            return (s1, b1), (s2, b2)
        s1, s2 = out1, out2
    return None


def constructive_convergence(
    f: Compress, a1: int, a2: int, msg: List[int]
) -> Optional[Tuple[int, int, int]]:
    """
    Theorem 3.4: if a1 != a2 but folding `msg` from both converges, return a
    step (s1, s2, b) with s1 != s2 and f(s1, b) == f(s2, b).
    """
    s1, s2 = a1, a2
    for b in msg:
        if s1 != s2 and f(s1, b) == f(s2, b):
            return s1, s2, b
        s1, s2 = f(s1, b), f(s2, b)
    return None


# --------------------------------------------------------------------------- #
# Length extension and strengthening (Sections 3.4)
# --------------------------------------------------------------------------- #
def length_extension(f: Compress, iv: int,
                     known_hash: int, suffix: List[int]) -> int:
    """
    Theorem 3.5: an attacker who knows H(iv, m) (but not m) can compute
    H(iv, m ++ suffix) as H(known_hash, suffix).
    """
    return merkle_damgard(f, known_hash, suffix)


def length_prefix_pad(msg: List[int]) -> List[int]:
    """An injective, length-regular-by-block padding: prefix the length, then
    pad with a sentinel to a fixed width.  (For demo purposes we fix a max
    width; injectivity holds because the original length is encoded.)"""
    max_len = 8
    sentinel = -1
    body = msg + [sentinel] * (max_len - len(msg))
    return [len(msg)] + body


def md_strengthen(f: Compress, pad: Callable[[List[int]], List[int]],
                  iv: int, msg: List[int]) -> int:
    """Definition 3.6: hash the padded message."""
    return merkle_damgard(f, iv, pad(msg))


# --------------------------------------------------------------------------- #
# The algebra: messages as state transformations (Sections 4-6)
# --------------------------------------------------------------------------- #
def md_end(f: Compress, msg: List[int]) -> Callable[[int], int]:
    """
    Definition 4.1: the state transformation induced by `msg`, as a callable
    a -> merkle_damgard(f, a, msg).  This is an element of Function.End and
    needs no closed finite state space (injective f has an open image).
    """
    return lambda a: merkle_damgard(f, a, msg)


def compose_end(g: Callable[[int], int],
                h: Callable[[int], int]) -> Callable[[int], int]:
    """Monoid multiplication in Function.End: (g * h)(a) = g(h(a))."""
    return lambda a: g(h(a))


def anti_homomorphism_holds(f: Compress, m1: List[int], m2: List[int],
                            test_states: List[int]) -> bool:
    """
    Theorem 4.3:  mdEnd(m1 ++ m2) == mdEnd(m2) * mdEnd(m1)   (composition
    reversed -- the reason mdHom lands in the *opposite* monoid).  Equality of
    transformations is checked pointwise on `test_states`.
    """
    lhs = md_end(f, m1 + m2)
    rhs = compose_end(md_end(f, m2), md_end(f, m1))
    return all(lhs(a) == rhs(a) for a in test_states)


def faithful_on_length(f: Compress, blocks: List[int], length: int,
                       test_states: List[int]) -> bool:
    """
    Theorem 6.1: faithfulness on equal-length words -- distinct equal-length
    messages induce distinct state transformations (probed on `test_states`).
    Returns True iff faithful.
    """
    seen: Dict[Tuple[int, ...], List[int]] = {}
    for combo in product(blocks, repeat=length):
        msg = list(combo)
        key = tuple(md_end(f, msg)(a) for a in test_states)
        if key in seen and seen[key] != msg:
            return False
        seen[key] = msg
    return True


# --------------------------------------------------------------------------- #
# The converse fails (Section 7)
# --------------------------------------------------------------------------- #
def converse_counterexample() -> Tuple[Compress, List[int], List[int], int]:
    """
    Theorem 7.1: a NON-injective compression function whose action is
    nevertheless faithful on equal-length words, because the block alphabet
    has a single element (so equal-length words are automatically identical).
    Returns (f, states, blocks, length).
    """
    states = [0, 1]
    blocks = [0]               # single-block alphabet
    # f ignores the state -> not pair-injective ( f(0,0) == f(1,0) ).
    def f(a: int, b: int) -> int:
        return 0
    return f, states, blocks, 3


# --------------------------------------------------------------------------- #
# Tree hashing (Section 8)
# --------------------------------------------------------------------------- #
Tree = Union["Leaf", "Node"]


class Leaf:
    def __init__(self, value: int) -> None:
        self.value = value


class Node:
    def __init__(self, left: "Tree", right: "Tree") -> None:
        self.left = left
        self.right = right


def tree_hash(leaf_map: Callable[[int], int],
              combine: Callable[[int, int], int], t: Tree) -> int:
    """Definition 8.1: bottom-up Merkle-tree hash."""
    if isinstance(t, Leaf):
        return leaf_map(t.value)
    return combine(tree_hash(leaf_map, combine, t.left),
                   tree_hash(leaf_map, combine, t.right))


def same_shape(s: Tree, t: Tree) -> bool:
    """Whether two trees have identical shape (ignoring leaf values)."""
    if isinstance(s, Leaf) and isinstance(t, Leaf):
        return True
    if isinstance(s, Node) and isinstance(t, Node):
        return same_shape(s.left, t.left) and same_shape(s.right, t.right)
    return False


# --------------------------------------------------------------------------- #
# Driver
# --------------------------------------------------------------------------- #
def main() -> None:
    print("=" * 70)
    print("Merkle-Damgard as a Monoid Action -- numerical demonstrations")
    print("=" * 70)

    n = 3
    f = make_injective_compress(n)          # pair-injective over Z_n blocks
    blocks = list(range(n))
    states = list(range(n * n + n))         # enough room for reachable states
    iv = 0

    # --- Domain extension (Thm 2.3) ---
    print("\n[Thm 2.3] Domain extension  H(iv, m1++m2) = H(H(iv,m1), m2)")
    m1, m2 = [1, 2], [0, 2]
    print(f"  m1={m1}, m2={m2}: holds = {domain_extension_holds(f, iv, m1, m2)}")

    # --- Pair injectivity + preservation (Thm 3.1, 3.2) ---
    print("\n[Thm 3.1/3.2] Injective compression -> no equal-length collision")
    print(f"  f pair-injective on domains = "
          f"{is_pair_injective(f, list(range(n)), blocks)}")
    col = find_md_collision(f, iv, blocks, length=3)
    print(f"  collision among length-3 messages: {col}  (None = injective)")

    # --- Collision reduction (Thm 3.3) on a deliberately weak f ---
    print("\n[Thm 3.3] Collision reduction on a NON-injective compression")
    weak = lambda a, b: (a + b) % 4       # many pair collisions
    wcol = find_md_collision(weak, iv, [0, 1, 2, 3], length=2)
    print(f"  MD collision (equal length): {wcol}")
    if wcol:
        p = extract_compress_collision(weak, iv, wcol[0], wcol[1])
        print(f"  extracted compression collision (a1,b1),(a2,b2): {p}")
        if p:
            (a1, b1), (a2, b2) = p
            print(f"    f{(a1, b1)} = {weak(a1, b1)} = {weak(a2, b2)} = f{(a2, b2)}")

    # --- Constructive convergence (Thm 3.4) ---
    print("\n[Thm 3.4] Constructive convergence from distinct start states")
    # 0 and 4 differ, but (a+b)%4 collapses them at the first block.
    cc = constructive_convergence(weak, 0, 4, [2])
    print(f"  a1=0, a2=4, msg=[2]: step (s1,s2,b) = {cc}")

    # --- Length extension (Thm 3.5) ---
    print("\n[Thm 3.5] Length-extension attack (no padding)")
    secret = [1, 0, 2]
    known = merkle_damgard(f, iv, secret)
    suffix = [2, 1]
    forged = length_extension(f, iv, known, suffix)
    honest = merkle_damgard(f, iv, secret + suffix)
    print(f"  H(secret)={known}; forged H(secret++suffix)={forged}; "
          f"honest={honest}; match={forged == honest}")

    # --- Strengthening (Thm 3.7) ---
    print("\n[Thm 3.7] Merkle-Damgard strengthening kills length extension")
    a = md_strengthen(f, length_prefix_pad, iv, [1])
    b = md_strengthen(f, length_prefix_pad, iv, [1, 1])
    print(f"  padded hashes of [1] and [1,1] differ: {a != b}")

    # --- Algebra: anti-homomorphism (Thm 4.3) ---
    print("\n[Thm 4.3] Anti-homomorphism: mdEnd(m1++m2) = mdEnd(m2) o mdEnd(m1)")
    print(f"  holds = {anti_homomorphism_holds(f, m1, m2, states)}")

    # --- Faithful action = IV-free collision resistance (Thm 6.1) ---
    print("\n[Thm 6.1] Faithful action on equal-length words (injective f)")
    print(f"  faithful (length 3) = {faithful_on_length(f, blocks, 3, states)}")

    # --- Converse fails (Thm 7.1) ---
    print("\n[Thm 7.1] Converse fails: non-injective f, yet faithful action")
    cf, cstates, cblocks, clen = converse_counterexample()
    pair_inj = is_pair_injective(cf, cstates, cblocks)
    faithful = faithful_on_length(cf, cblocks, clen, cstates)
    print(f"  f pair-injective = {pair_inj}; faithful on length {clen} = {faithful}")
    print("  (single-block alphabet -> equal-length words automatically equal)")

    # --- Tree hashing (Thm 8.2) ---
    print("\n[Thm 8.2] Tree collision resistance on a fixed shape")
    leaf_map = lambda v: v + 1
    combine = lambda l, r: l * 100 + r          # injective on small digests
    t1 = Node(Leaf(1), Node(Leaf(2), Leaf(3)))
    t2 = Node(Leaf(1), Node(Leaf(2), Leaf(9)))
    print(f"  same shape = {same_shape(t1, t2)}")
    print(f"  hashes: {tree_hash(leaf_map, combine, t1)} vs "
          f"{tree_hash(leaf_map, combine, t2)}  (distinct trees -> distinct)")

    print("\n" + "=" * 70)
    print("All demonstrations completed.")
    print("=" * 70)


if __name__ == "__main__":
    main()
