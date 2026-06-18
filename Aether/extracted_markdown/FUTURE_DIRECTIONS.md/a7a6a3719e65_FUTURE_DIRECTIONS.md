# Future Directions: Proof-Theoretic Ordinal Analysis II

This cycle established the structural backbone of the `OrdinalTheory` framework
(file `Pythagorean/ProofTheoreticOrdinalsLattice.lean`, extending the catalog file
`Catalog/Pythagorean/ProofTheoreticOrdinals.lean`). The main new results are:

- **Totality of inclusion** (`provablyWO_subset_total`, `le_total_theory`): any two
  `OrdinalTheory`s are comparable — the space of theories is a *chain*, not merely a
  poset. This is sharper than the catalog's observation that `pto` is not an order
  embedding.
- **`pto` is a lattice homomorphism** (`pto_meet_eq_min` together with
  `pto_join_eq_max`): the proof-theoretic ordinal preserves both meet and join.
- **Exact chain additivity of the depth metric** (`depthDist_chain_additive`): along a
  chain `T₁ ≤ T₂ ≤ T₃`, `depthDist T₁ T₃ = depthDist T₁ T₂ + depthDist T₂ T₃` exactly
  — not merely sub-additively. The directed triangle inequality
  (`depthDist_directed_triangle`) is a corollary.
- **Failure of the unconditional triangle inequality**
  (`depthDist_triangle_general_false`): with PTOs `ω+1, ω, 0` the inequality breaks,
  since `1 + ω = ω < ω+1`. So `depthDist` is a genuinely *directed* quasi-metric.
- **PTO fibers are order-convex** (`pto_constant_on_interval`): if the endpoints of an
  interval share a PTO, the PTO is constant throughout it.

The directions below extend these results.

## 1. The complete-lattice / `LinearOrder` instance up to PTO-equivalence

We proved inclusion is total (`le_total_theory`) and that `meet`/`join` realize the
infimum/supremum. The natural next step is to package `OrdinalTheory` modulo the
equivalence "same `provablyWO`" as a genuine `LinearOrder`, and then show that the
quotient by *PTO-equivalence* (`T₁ ~ T₂ ↔ pto T₁ = pto T₂`) is order-isomorphic to the
image of `pto` in the ordinals. The key insight is that the fiber-convexity theorem
`pto_constant_on_interval` already shows each PTO-fiber is an interval of the chain, so
the quotient map collapses intervals to points and is automatically monotone and
injective on the quotient — exactly the data of an order embedding. Why now? With
totality in hand, the only obstruction to a `LinearOrder`/`CompleteLattice` instance is
bookkeeping about the `provablyWO`-equivalence, which `pto_meet_eq_min` and
`pto_join_eq_max` make routine.

**Testable conjecture**: The quotient of `OrdinalTheory` by PTO-equivalence carries a
`LinearOrder` for which `pto` descends to an order embedding into `Ordinal`, and each
equivalence class is a bounded interval (hence a complete sublattice) of the inclusion
chain.

## 2. A normalized, genuine pseudometric refining `depthDist`

`depthDist_triangle_general_false` shows the raw depth distance is only a *directed*
quasi-metric because ordinal addition absorbs on the left (`1 + ω = ω`). The key
insight is that the *natural (Hessenberg) ordinal sum* `⊕` is commutative and strictly
monotone, so replacing `+` by `⊕` in the definition of `depthDist` should restore the
full triangle inequality while still agreeing with `depthDist` on chains (where
`depthDist_chain_additive` already gives exact additivity). Why now? Mathlib provides
`Ordinal.nadd` (natural addition) with commutativity and monotonicity lemmas, and our
chain-additivity result pins down the value that any correct metric must take on
comparable triples — so the only thing to check is the genuinely non-comparable case,
which `nadd`'s commutativity is designed to handle.

**Testable conjecture**: Defining `natDepthDist T₁ T₂ := (pto T₁ - pto T₂) ⊕ (pto T₂ - pto T₁)`
with `⊕ = Ordinal.nadd` yields an honest `Ordinal`-valued pseudometric (symmetry,
vanishing on the diagonal, and the unconditional triangle inequality all hold), and it
coincides with `depthDist` whenever the two theories are comparable.

## 3. Connecting the abstract chain to `ONote` below ε₀

The totality result says abstract theories form a chain; the computable counterpart is
the linear order on `ONote` (ordinal notations below ε₀). The key insight is that
`pto_ofOrdinal_succ` and `pto_ofOrdinal_limit` together compute the PTO of every
`ofOrdinal α` for α in Cantor normal form, so the map `n ↦ ofOrdinal n.repr` from
`ONote` to `OrdinalTheory` has PTO exactly `n.repr` and is therefore an order-preserving
injection of `ONote` into our theory chain. Why now? With both the successor and limit
PTO computations available, the induction on Cantor normal form needed to evaluate
`pto (ofOrdinal n.repr)` has all its base/step cases discharged, making the `ONote`
bridge a finite assembly job rather than new theory.

**Testable conjecture**: `n ↦ OrdinalTheory.ofOrdinal n.repr` is a strictly monotone map
`ONote → OrdinalTheory` (w.r.t. `ONote`'s order and theory inclusion) whose composite
with `pto` equals `ONote.repr`, giving a *decidable* PTO comparison for the theories it
hits.

## 4. Fast-growing hierarchies as computational witnesses of PTO

Direction 4 of the catalog asks for a computational witness that a theory "knows" an
ordinal. The key insight is that `pto_constant_on_interval` and `le_total_theory` let us
define, for each theory `T`, the canonical boundary ordinal `pto T` past which the
fast-growing function `f_α` (Mathlib `ONote.fastGrowing`) ceases to be "provably total"
in `T`; the fiber-convexity then guarantees this boundary is well-defined on each
PTO-class. Why now? The contrapositive half-saturation lemma (catalog
`pto_le_of_not_mem`) already characterizes the boundary ordinal exactly, so the only new
content is to identify it with the domain on which `fastGrowing` is provably total.

**Testable conjecture**: There is a computable `ONote → OrdinalTheory` whose value at `n`
has `provablyWO = {β | β < n.repr}` and whose PTO equals `n.repr`; moreover `f_α` is
"provably total" in this theory exactly for `α` below the PTO.

## 5. Anti-symmetry up to PTO and a partial order on metric classes

`depthDist_eq_zero_iff` (catalog) says depth distance vanishes iff PTOs agree, and our
`depthDist_chain_additive` says distance accumulates additively along chains. The key
insight is that these two facts make `pto` a *faithful* isometric invariant on the
quotient chain: distinct PTO-classes are at strictly positive depth, and the depth
between adjacent classes is the ordinal "gap" between their PTOs. Why now? The
combination of fiber-convexity (`pto_constant_on_interval`) and exact additivity means
the metric structure descends cleanly to the PTO-quotient with no defect, so the
quotient is literally `(range pto, ordinal gap)` — a concrete, fully computable metric
space whenever the PTOs lie below ε₀.

**Testable conjecture**: On the PTO-quotient, `depthDist` descends to the function
`(α, β) ↦ (α - β) + (β - α)` on `range pto ⊆ Ordinal`, and this descended function is an
injective isometric invariant separating all distinct classes.
