# Computational Evidence

Deliverable: `Catalog/Novelty/GreedyTamariPlaneTreeBridge.lean`.

The formalized cross-domain bridge states, among other things:

> The number of **plane (planar, ordered) trees** with `n + 1` nodes equals the
> number of **Dyck lattice paths** of semilength `n`, and both equal `catalan n`.

## 1. Small-case calculations

Let `p(k)` = number of plane trees with `k` nodes, `d(n)` = number of Dyck paths
of semilength `n`. Our theorems give `p(n+1) = d(n) = catalan n`.

By hand, plane trees with `k` nodes (root drawn as `•`, children ordered
left-to-right):

* `k = 1`: `•`  — 1 tree  → `catalan 0 = 1`.
* `k = 2`: `•—•`  — 1 tree → `catalan 1 = 1`.
* `k = 3`: root with two children, or root with one child that has one child
  — 2 trees → `catalan 2 = 2`.
* `k = 4`: 5 trees → `catalan 3 = 5`.
* `k = 5`: 14 trees → `catalan 4 = 14`.

## 2. Machine-checked enumeration

Because the file proves an explicit `Equiv` (`planeTreeEquivDyck`) between plane
trees with `n+1` nodes and binary trees with `n` internal nodes, we can count
the equinumerous family `Tree.treesOfNumNodesEq n` directly in Lean (this
enumeration does *not* go through the closed form of `catalan`):

```lean
#eval (List.range 8).map (fun n => (Tree.treesOfNumNodesEq n).card)
-- [1, 1, 2, 5, 14, 42, 132, 429]

#eval (List.range 8).map (fun n => Nat.centralBinom n / (n + 1))
-- [1, 1, 2, 5, 14, 42, 132, 429]
```

The two lists agree, confirming the enumeration equals the Catalan numbers.

## 3. OEIS

The sequence `1, 1, 2, 5, 14, 42, 132, 429, …` is the **Catalan numbers**,
[OEIS A000108](https://oeis.org/A000108). It simultaneously counts:
ordered (plane) trees, binary trees, and Dyck paths — precisely the three
families bridged here.

## 4. Counterexample hunt

The main statements are equalities of cardinalities `card {plane trees, n+1 nodes}
= card {Dyck paths, semilength n} = catalan n`. They are proved unconditionally
by transporting `Mathlib`'s binary-tree/Dyck-word/Catalan results along a
constructive bijection, so there is nothing to refute. The enumeration in §2
serves as an independent numerical cross-check and finds no discrepancy for
`n = 0, …, 7`.
