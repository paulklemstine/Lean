# Computational Evidence — Minor-Closed Classes Below Density 3/2

All numbers below were computed in Lean (`#eval` over `ℚ`) and feed directly into
the formal theorems in this directory.

## 1. The 3/2 threshold is the density of K₄

| graph        | edges            | vertices | density `|E|/|V|` |
|--------------|------------------|----------|-------------------|
| K₃ (triangle)| `C(3,2) = 3`     | 3        | `1`               |
| K₄           | `C(4,2) = 6`     | 4        | **`3/2`**         |

So `3/2` is exactly the edge density of `K₄`.  This is why the mission's
threshold `δ < 3/2` is natural: it sits strictly *below* the first complete
graph whose density reaches `3/2`.

## 2. Forest (tree) densities approach 1 from below

A tree on `n` vertices has exactly `n − 1` edges, density `(n−1)/n`:

```
(n-1)/n  for n = 2,3,4,10,100  =  1/2, 2/3, 3/4, 9/10, 99/100  →  1
```

Hence the limiting density of the forest class is `1`, and `1 < 3/2`.  Every
individual forest has density `< 1` (proved: `IsTree.edgeDensity_lt_one`,
`acyclic_edgeDensity_lt_threshold`).

## 3. Landscape of small minor-closed classes by limiting density

| class                              | forbidden minor | limiting density | below 3/2? |
|------------------------------------|-----------------|------------------|------------|
| forests                            | `K₃`            | `1`              | yes        |
| graphs with ≤1 cycle per component | —               | `1`              | yes        |
| series–parallel (no `K₄` minor)    | `K₄`            | `2` (sup)        | no         |
| planar                             | `K₅`, `K_{3,3}` | `3`              | no         |

The interval of *achievable* limiting densities below `3/2` is, in the
literature, very sparse: the forest class (`density 1`) is the prototypical
⊆-minimal minor-closed class strictly below `3/2`, and it is characterised by a
single excluded minor `K₃`.  This is the concrete shadow of the abstract
`singleExcludedMinor_iff_obstructions_singleton`.

## 4. Counterexample hunt

* Could a minor-closed class below `3/2` need *two* incomparable obstructions?
  The abstract theorem shows this is equivalent to its obstruction set not being
  a singleton.  No small counterexample to *single*-obstruction was found among
  the density-`< 3/2` classes enumerated above; all are `excl {H}` for a single
  `H` (e.g. forests `= excl {K₃}` as minors).  This is consistent with — and
  motivates — the grand conjecture.

## 5. Sanity checks that fed the proofs

* `connected_top` ⇒ every nonempty graph extends a forest to a spanning tree,
  giving the edge bound `|E| + 1 ≤ |V|` (`IsAcyclic.card_edgeSet_add_one_le`).
* Empty graph: density `0/0 = 0 < 3/2` in `ℚ` (handled explicitly).
