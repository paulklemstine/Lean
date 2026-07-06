"""Numerical demonstrations for the discrete fundamental group of a cubical set.

This module illustrates the results of "Discrete Homotopy Groups of
Quasisymmetric Cubical Sets" with concrete, self-contained computations.

We model the one-square example. A square has four boundary edges, indexed
0, 1, 2, 3. Edges 0, 1, 2 are the spanning-tree edges (declared trivial),
and edge 3 is the closing generator.

Elements of the free group on the four edges are represented as reduced words:
a word is a tuple of (edge_index, sign) letters, where sign is +1 or -1, with
no adjacent inverse pair (freely reduced). We implement:

  * free multiplication and reduction,
  * the spanning-tree quotient (delete tree letters),
  * the winding-number homomorphism onto the integers (hollow square),
  * the filled-square quotient (everything collapses to the identity),
  * the filling surjection sending the winding number to zero.

Running this file prints a report demonstrating each theorem.
"""

from __future__ import annotations

from typing import List, Tuple

# A letter is (edge_index, sign); a Word is a freely-reduced list of letters.
Letter = Tuple[int, int]
Word = List[Letter]

TREE_EDGES: Tuple[int, ...] = (0, 1, 2)  # spanning-tree edges, declared trivial
CLOSING_EDGE: int = 3                     # the honest generator of the hollow square


def free_reduce(word: Word) -> Word:
    """Freely reduce a word by cancelling adjacent inverse pairs.

    Runs in linear time using a stack; the result is the unique reduced word.
    """
    stack: Word = []
    for edge, sign in word:
        if stack and stack[-1][0] == edge and stack[-1][1] == -sign:
            stack.pop()
        else:
            stack.append((edge, sign))
    return stack


def free_mul(a: Word, b: Word) -> Word:
    """Multiply two words in the free group and reduce the result."""
    return free_reduce(list(a) + list(b))


def free_inv(word: Word) -> Word:
    """Return the inverse of a word in the free group."""
    return [(edge, -sign) for edge, sign in reversed(word)]


def gen(edge: int, power: int = 1) -> Word:
    """Return the reduced word for a single generator raised to an integer power."""
    sign = 1 if power >= 0 else -1
    return free_reduce([(edge, sign)] * abs(power))


def collapse_tree(word: Word) -> Word:
    """Apply the spanning-tree relations: delete every tree-edge letter.

    Geometrically, traversing a spanning-tree edge encloses no hole, so it is
    set to the identity. The remaining word lives in the hollow-square group.
    """
    return free_reduce([(e, s) for (e, s) in word if e not in TREE_EDGES])


def winding_number(word: Word) -> int:
    """Evaluate the winding-number homomorphism onto the integers.

    This is the homomorphism of Theorem 6.1: tree edges map to 0, and the
    closing edge 3 maps to 1. On a general word it returns the signed count of
    occurrences of the closing edge. Two loops are discretely homotopic in the
    HOLLOW square iff they have the same winding number.
    """
    return sum(sign for edge, sign in word if edge == CLOSING_EDGE)


def hollow_equal(u: Word, v: Word) -> bool:
    """Decide discrete homotopy of two loops in the HOLLOW square.

    The hollow-square group is free on the closing generator (isomorphic to the
    integers), so equality is detected by the winding number.
    """
    return winding_number(u) == winding_number(v)


def filled_equal(u: Word, v: Word) -> bool:
    """Decide discrete homotopy of two loops in the FILLED square.

    Filling adds the boundary relation g0 g1 g2 g3 = 1; combined with the tree
    relations this forces g3 = 1. Every loop is null-homotopic, so ALL words are
    equal in the filled-square group.
    """
    return True  # the group is trivial


def boundary_word() -> Word:
    """The oriented boundary word of the square: edge 0, 1, 2, then 3."""
    return free_reduce([(0, 1), (1, 1), (2, 1), (3, 1)])


def demo_hollow_nontrivial() -> None:
    """Theorem 6.1: the hollow square has nontrivial fundamental group (= Z)."""
    print("=" * 70)
    print("Theorem 6.1  --  The hollow square detects a hole (pi_1 = Z)")
    print("=" * 70)
    b = boundary_word()
    print(f"boundary word b            = {b}")
    print(f"after tree collapse        = {collapse_tree(b)}")
    print(f"winding number w(b)        = {winding_number(collapse_tree(b))}")
    print("Since w(b) = 1 != 0 = w(identity), the boundary loop is NONTRIVIAL.")
    # Powers of the boundary give all of Z:
    windings = [winding_number(collapse_tree(gen(3, k))) for k in range(-3, 4)]
    print(f"windings of g3^k, k=-3..3  = {windings}")
    print("The invariant surjects onto every integer: the group is infinite cyclic.\n")


def demo_filled_trivial() -> None:
    """Theorem 6.2: filling the square collapses the group to a point."""
    print("=" * 70)
    print("Theorem 6.2  --  The filled square is contractible (pi_1 = 1)")
    print("=" * 70)
    b = boundary_word()
    print("Filling imposes b = g0 g1 g2 g3 = 1.")
    print("Tree relations give g0 = g1 = g2 = 1, so b reduces to g3 = 1.")
    print(f"boundary word b            = {b}")
    print("After imposing tree + boundary relations, every generator is trivial.")
    # In the filled group, any two loops are equal:
    u = free_mul(gen(3, 5), gen(0, 2))
    v = gen(3, -7)
    print(f"u = g3^5 g0^2, v = g3^-7 :  filled_equal(u, v) = {filled_equal(u, v)}")
    print("All loops are null-homotopic: the group has a single element.\n")


def demo_filling_surjection() -> None:
    """Theorem 6.3 / 5.1: filling induces a surjection Z ->> 1 killing g3."""
    print("=" * 70)
    print("Theorem 6.3  --  Filling collapses: a surjection Z -->> 1")
    print("=" * 70)
    print("phi sends each edge generator to itself; the target is trivial.")
    for k in range(-2, 3):
        source = winding_number(collapse_tree(gen(3, k)))
        target = 0  # image in the trivial filled group
        print(f"  g3^{k:>2}:  hollow class = {source:>2}  --phi-->  filled class = {target}")
    print("The winding-number generator g3 (a generator of Z) is sent to 1.")
    print("Filling can only CREATE null-homotopies, never destroy them.\n")


def demo_functoriality() -> None:
    """Theorem 5.1: monotonicity of relations gives a generator-preserving map."""
    print("=" * 70)
    print("Theorem 5.1  --  Functoriality under 2-cube inclusion")
    print("=" * 70)
    print("R_hollow = {g0, g1, g2}  subset of  R_filled = {g0, g1, g2, g0g1g2g3}.")
    print("Hollow winding numbers partition loops into Z-many classes;")
    print("the induced map merges them all into one class (surjection onto 1).")
    samples = [gen(3, 1), gen(3, 2), free_mul(gen(3, 1), gen(0, 1)), []]
    print("loop                     hollow class     filled class")
    for w in samples:
        print(f"  {str(w):<22} {winding_number(collapse_tree(w)):>6}"
              f"            {'0 (trivial)':>11}")
    print("A surjection can merge classes but never invent a new one.\n")


def main() -> None:
    print()
    print("#" * 70)
    print("# Discrete fundamental group of a cubical set: the one-square example")
    print("#" * 70)
    print()
    demo_hollow_nontrivial()
    demo_filled_trivial()
    demo_filling_surjection()
    demo_functoriality()
    print("All demonstrations completed.")


if __name__ == "__main__":
    main()
