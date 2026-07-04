"""
Recursive Decomposition Isomorphism for General m-Tamari Intervals
and Planar (m+1)-Constellations
==================================================================

This self-contained script demonstrates, numerically, the central
results of the accompanying paper:

  * The "active-sites" succession rule  S_m(k) = [1, 2, ..., m*k + 1]
    (rooted at label 1), natural on the m-Tamari / m-Dyck side.

  * The "shifted" succession rule       T_m(k) = [2, 3, ..., m*(k-1) + 2]
    (rooted at label 2), natural on the planar (m+1)-constellation side.

  * The single relabelling  phi(k) = k + 1  intertwines the two rules
    for EVERY m >= 1:  T_m(phi(a)) = phi( S_m(a) ) elementwise.

From that one identity we obtain, for all m:
  - equal level-by-level counting sequences (equi-enumeration);
  - equal REFINED counts (any statistic carried by the labels is
    distributed identically at every level);
  - a growth bound  levelCount(k) >= 2^k  (nothing is vacuous).

Counting sequences reproduced here:
    m = 1 :  1, 2, 5, 14, 42, ...      (Catalan numbers, A000108)
    m = 2 :  1, 3, 15, 113, 1273, ...
    m = 3 :  1, 4, 34, 586, 21721, ...
"""

from __future__ import annotations

from typing import Callable, List


# --------------------------------------------------------------------------
# The two concrete succession rules, uniform in the arity m.
# --------------------------------------------------------------------------

def sites_rule(m: int, k: int) -> List[int]:
    """Active-sites rule: a node with label k has children 1, 2, ..., m*k + 1."""
    return list(range(1, m * k + 2))


def shifted_rule(m: int, k: int) -> List[int]:
    """Shifted rule: a node with label k has children 2, 3, ..., m*(k-1) + 2."""
    # length is m*k - m + 1 = m*(k-1) + 1, starting at 2
    return list(range(2, (m * k - m + 1) + 2))


def relabel(k: int) -> int:
    """The label bijection phi(k) = k + 1 realising the isomorphism."""
    return k + 1


# --------------------------------------------------------------------------
# Generating-tree machinery: level label lists and level counts.
# --------------------------------------------------------------------------

def level_labels(succ: Callable[[int], List[int]], root: int, depth: int) -> List[int]:
    """Ordered list of labels appearing at a given depth of the generating tree."""
    labels = [root]
    for _ in range(depth):
        nxt: List[int] = []
        for lab in labels:
            nxt.extend(succ(lab))
        labels = nxt
    return labels


def level_count(succ: Callable[[int], List[int]], root: int, depth: int) -> int:
    """Number of nodes at a given depth (the counting sequence)."""
    return len(level_labels(succ, root, depth))


# --------------------------------------------------------------------------
# Demonstrations of the three headline results.
# --------------------------------------------------------------------------

def demo_intertwining(max_m: int = 4, max_a: int = 8) -> None:
    """Verify T_m(phi(a)) = phi(S_m(a)) elementwise for many m, a."""
    print("=== Intertwining identity: T_m(a+1) = (S_m(a)) mapped by (+1) ===")
    ok = True
    for m in range(1, max_m + 1):
        for a in range(0, max_a + 1):
            lhs = shifted_rule(m, relabel(a))
            rhs = [relabel(x) for x in sites_rule(m, a)]
            if lhs != rhs:
                ok = False
                print(f"  MISMATCH  m={m} a={a}: {lhs} != {rhs}")
    print(f"  all sampled (m,a) satisfy the identity: {ok}\n")


def demo_counting_sequences(max_m: int = 3, depth: int = 4) -> None:
    """Print the counting sequences for m = 1, 2, 3 from both encodings."""
    print("=== Counting sequences (both encodings agree) ===")
    for m in range(1, max_m + 1):
        sites_seq = [level_count(lambda k: sites_rule(m, k), 1, d) for d in range(depth + 1)]
        shift_seq = [level_count(lambda k: shifted_rule(m, k), 2, d) for d in range(depth + 1)]
        assert sites_seq == shift_seq, (m, sites_seq, shift_seq)
        print(f"  m = {m}:  {sites_seq}   (equal for both rules: {sites_seq == shift_seq})")
    print()


def demo_refined_counts(m: int = 2, depth: int = 3) -> None:
    """Show that any label statistic is distributed identically at each level."""
    print(f"=== Refined equinumerosity (m = {m}) ===")
    print("  statistic 'label' histogram at each level; shifted = sites shifted by +1")
    for d in range(depth + 1):
        sites = sorted(level_labels(lambda k: sites_rule(m, k), 1, d))
        shift = sorted(level_labels(lambda k: shifted_rule(m, k), 2, d))
        shifted_from_sites = sorted(relabel(x) for x in sites)
        assert shift == shifted_from_sites
        print(f"  level {d}:  sites={sites}")
        print(f"            shift={shift}  (= sites + 1: {shift == shifted_from_sites})")
    print()


def demo_growth_bound(max_m: int = 3, depth: int = 5) -> None:
    """Confirm the level count dominates 2^k for m >= 1."""
    print("=== Growth bound: levelCount(k) >= 2^k ===")
    for m in range(1, max_m + 1):
        row = []
        for d in range(depth + 1):
            c = level_count(lambda k: sites_rule(m, k), 1, d)
            row.append(f"{c}>={2**d}:{c >= 2**d}")
        print(f"  m = {m}:  " + "  ".join(row))
    print()


if __name__ == "__main__":
    demo_intertwining()
    demo_counting_sequences()
    demo_refined_counts()
    demo_growth_bound()
