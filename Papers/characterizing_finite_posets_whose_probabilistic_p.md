# Computational Evidence

Target combinatorial condition (the "RB shape" whose two conjuncts the Jung–Tix
characterization requires of a finite poset `P`):

```
RBShape P  ≡  (P has a least element)  ∧  (undirected Hasse graph of P is a tree)
```

We probe, on small finite posets, whether either conjunct *by itself* forces the
other / forces RB-shape. All numbers below are for the *undirected Hasse graph*
(vertices = elements, edges = covering pairs).

## Small-case table

| Poset (n elements)              | least elt? | #Hasse edges | connected? | acyclic? | tree? | RB-shape? |
|---------------------------------|:----------:|:------------:|:----------:|:--------:|:-----:|:---------:|
| 1-element                       | yes        | 0            | yes        | yes      | yes   | **yes**   |
| 2-chain (`Bool`)                | yes        | 1            | yes        | yes      | yes   | **yes**   |
| 2-antichain (`Anti2`)           | **no**     | 0            | no         | yes      | no    | no        |
| 3-chain                         | yes        | 2            | yes        | yes      | yes   | yes       |
| "V" / Λ (a,b < c)               | **no**     | 2            | yes        | yes      | yes   | no        |
| diamond `2×2` (`Bool × Bool`)   | yes        | 4            | yes        | **no**   | no    | no        |

## What the table shows (counterexample hunt)

* **Least element is NOT sufficient for RB-shape.** The diamond `Bool × Bool`
  has a least element `(false,false)` but its Hasse graph has 4 edges on 4
  vertices with a 4-cycle `(ff)–(tf)–(tt)–(ft)–(ff)`, so it is not a tree
  (Euler: a tree on 4 vertices has 3 edges). This is the classical Jung–Tix
  diamond obstruction. → Formalized as `least_not_sufficient_for_rbShape`.

* **Acyclicity (forest) is NOT sufficient for a least element.** The 2-antichain
  is edgeless, hence acyclic, but has two incomparable minimal elements and no
  least element. → Formalized as `forest_not_sufficient_for_hasLeast`.

* **Even a genuine tree Hasse graph does not force a least element** (the "V"
  poset: connected tree of 2 edges, but `a,b` incomparable minimal, no least).
  This is now formalized as `tree_not_sufficient_for_hasLeast`, with
  `v3_hasseGraph_isTree : (hasseGraph V3).IsTree` proving the full tree property
  (connected *and* acyclic), sharpening the antichain (forest) witness.

* **The condition is not vacuous:** chains are RB-shaped (`bool_rbShape` for the
  2-chain).

## Edge-count sanity (Euler characteristic)

For a finite poset with a least element the Hasse graph is connected, so it is a
tree **iff** `#edges = n - 1`. Checks:
* diamond: `#edges = 4`, `n - 1 = 3` → not a tree ✗ (matches disproof).
* chains: `#edges = n - 1` → tree ✓.

## OEIS

No integer sequence is central to this qualitative structural question, so no
OEIS lookup applies. (The number of finite posets on `n` labelled points is
A001035, but it is not used here.)

## Note on mechanized computation

Lean's `SimpleGraph.edgeFinset` uses a non-computable `Fintype` instance, so the
edge counts above were verified by hand / by the structural Lean proofs rather
than by `#eval`. The covering relations and the least-element facts on the
concrete posets `Bool × Bool`, `Bool`, and `Anti2` are discharged by `decide` in
the Lean development.
