# Future Directions: Proof-Theoretic Ordinal Analysis V

## Synthesis

This cycle closed the two longest-standing gaps in the `OrdinalTheory` framework: the
*metric* defect and the *order* defect.

On the metric side, `Pythagorean/ProofTheoreticOrdinalsNatMetric.lean` repairs the failure
of the triangle inequality for the catalog quasi-metric `depthDist`. The catalog had proved
(`depthDist_triangle_general_false`) that with PTOs `ω+1, ω, 0` the inequality breaks, since
the *outer* sum `1 + ω = ω` absorbs the defect. We define

  `natDepthDist T₁ T₂ := (pto T₁ - pto T₂) ♯ (pto T₂ - pto T₁)`   (`♯ = Ordinal.nadd`)

and prove the **unconditional triangle inequality** `natDepthDist_triangle`
(`natDepthDist T₁ T₃ ≤ natDepthDist T₁ T₂ ♯ natDepthDist T₂ T₃`), together with symmetry
(`natDepthDist_comm`), vanishing on the diagonal (`natDepthDist_self`), and faithfulness
(`natDepthDist_eq_zero_iff`). Strikingly, `natDepthDist_eq_depthDist` shows the new metric
is *identical* to `depthDist` as a function — because any two ordinals are comparable, one
difference is always `0` — so the only thing that changed is the combining operation in the
triangle law, upgraded from the non-commutative `+` to the commutative natural sum `♯`. The
mathematical heart is the pure-ordinal inequality `Ordinal.sub_le_nadd_sub`:
`x - z ≤ (x - y) ♯ (y - z)`.

On the order side, `Pythagorean/ProofTheoreticOrdinalsQuotient.lean` packages the chain of
theories modulo PTO-equivalence. We prove `pto` is surjective (`pto_surjective`), that the
inclusion order *coincides* with the PTO order up to ties (`pto_le_iff`, via the load-bearing
`lt_pto_imp_lt_incl`), and that the quotient map `ptoQuotEquiv : PtoQuot ≃ Ordinal` is a
bijection under which inclusion becomes the ordinal order (`ptoQuot_le_iff_incl`). The
natural-sum metric is a *faithful* invariant on this quotient: distinct classes are at
strictly positive distance (`natDepthDist_pos_of_ne`).

## Results Summary

- `Ordinal.sub_le_nadd_sub` — the natural-sum triangle inequality for ordinal subtraction.
- `natDepthDist_triangle` — unconditional triangle inequality; `natDepthDist` is a genuine
  `Ordinal`-valued pseudometric.
- `natDepthDist_eq_depthDist`, `natDepthDist_comm`, `natDepthDist_self`,
  `natDepthDist_eq_zero_iff` — coincidence with `depthDist`, symmetry, diagonal, faithfulness.
- `pto_surjective`, `lt_pto_imp_lt_incl`, `pto_le_iff` — surjectivity and the order bridge.
- `ptoQuotEquiv`, `ptoQuot_le_iff_incl` — the PTO-quotient *is* `Ordinal`, order and all.
- `natDepthDist_pos_of_ne` — metric separation of distinct PTO-classes.

## Direction 1 — Upgrade `PtoQuot` to a bundled `LinearOrder`/`CompleteLattice` and `ptoQuotEquiv` to an `OrderIso`

We have the bijection `ptoQuotEquiv : PtoQuot ≃ Ordinal` and the order bridge `pto_le_iff`,
but `PtoQuot` carries no order *instance* yet. The next step is to transport the
`ConditionallyCompleteLinearOrderBot` structure of `Ordinal` along `ptoQuotEquiv`, giving
`PtoQuot` a `LinearOrder` (indeed a complete lattice) for which `ptoQuotEquiv` is a literal
`OrderIso`, and to verify that the resulting `≤` is *exactly* the relation induced by theory
inclusion (`Quotient.lift₂` of `· ≤ ·`). The key insight is that `pto_le_iff` already proves
the inclusion-induced relation and the PTO order agree on representatives, so the descended
order is automatically well-defined, antisymmetric, and total — the `OrderIso` is then forced.
Why now? With surjectivity and the order bridge in hand, the only remaining work is
`Quotient.lift₂` plumbing and `Equiv.toOrderIso`-style transport; no new ordinal mathematics
is required.

**Testable conjecture (falsifiable).** There is an `OrderIso PtoQuot Ordinal` extending
`ptoQuotEquiv`, and the order it induces on `PtoQuot` equals
`Quotient.lift₂ (· ≤ ·)` of theory inclusion; consequently `PtoQuot` is a complete lattice
whose meet/join are the images of `OrdinalTheory.meet`/`join`. (Falsified if any pair of
representatives has `T₁ ⊆ T₂` while `pto T₁ > pto T₂`, which `pto_monotone` forbids.)

## Direction 2 — `natDepthDist` is an honest `Ordinal`-valued metric, not merely a pseudometric, on `PtoQuot`

`natDepthDist` is a pseudometric on `OrdinalTheory` and is *faithful* on the quotient
(`natDepthDist_pos_of_ne`). The natural next theorem is that the descended distance
`PtoQuot → PtoQuot → Ordinal` is a genuine **metric**: it vanishes *iff* the two points are
equal in `PtoQuot`. The key insight is that the quotient is built precisely to identify the
fibers on which `natDepthDist` vanishes, so `natDepthDist_eq_zero_iff` becomes
`d q₁ q₂ = 0 ↔ q₁ = q₂` after descending along `Quotient.lift₂`. Why now? Both ingredients
already exist — the descent is well-defined because `natDepthDist` depends only on PTOs, and
faithfulness gives the `↔`. The remaining content is identifying the descended `Ordinal`
metric with the transported absolute-difference metric
`(α, β) ↦ (α - β) ♯ (β - α)` on `Ordinal` itself.

**Testable conjecture (falsifiable).** `natDepthDist` descends to a function
`PtoQuot → PtoQuot → Ordinal` satisfying `d q₁ q₂ = 0 ↔ q₁ = q₂`, `d q₁ q₂ = d q₂ q₁`, and
`d q₁ q₃ ≤ d q₁ q₂ ♯ d q₂ q₃`, and equals `(ptoQuotEquiv q₁ - ptoQuotEquiv q₂) ♯
(ptoQuotEquiv q₂ - ptoQuotEquiv q₁)`. (Falsified if any two distinct classes have descended
distance `0`, contradicting `natDepthDist_pos_of_ne`.)

## Direction 3 — Bridge the abstract chain to `ONote` below ε₀ for *decidable* comparison

The quotient `PtoQuot` is order-isomorphic to all of `Ordinal`, which is not computable. The
computable counterpart is the linear order on `ONote` (ordinal notations below ε₀). The key
insight is that `pto_ofOrdinal_succ` (and the catalog `pto_ofOrdinal_limit`) compute
`pto (ofOrdinal α)` on the Cantor-normal-form landmarks, so `n ↦ ofOrdinal n.repr` is a
strictly monotone map `ONote → OrdinalTheory` whose composite with `pto` is `ONote.repr` on
limit/zero notations; this yields a *decidable* PTO comparison for the theories it hits. Why
now? `ONote.repr` is total and `ONote` has a `DecidableLinearOrder`; combined with our
`pto_le_iff`, comparison of two `ofOrdinal n.repr` theories reduces to `ONote.cmp`, which is
executable.

**Testable conjecture (falsifiable).** The map `n ↦ OrdinalTheory.ofOrdinal n.repr` is
strictly monotone from `(ONote, <)` into `(OrdinalTheory, ⊆)`, and for limit notations
`pto (ofOrdinal n.repr) = n.repr`; hence `#eval ONote.cmp m n` decides inclusion of the
corresponding theories. (Falsified by any `m < n` in `ONote` with
`ofOrdinal m.repr ⊄ ofOrdinal n.repr`.)

## Direction 4 — Fast-growing hierarchies as computational witnesses of PTO

The catalog asks for a computational witness that a theory "knows" an ordinal. The key
insight is that the canonical theory `ofOrdinal α` has `provablyWO = Iio α`, so the Mathlib
fast-growing function `fastGrowing` (on `ONote`) should be "provably total in `ofOrdinal α`"
exactly for indices below the PTO `α`; the order bridge `pto_le_iff` and surjectivity
`pto_surjective` pin down the boundary index precisely. Why now? We can now construct, for
each ordinal `α`, a *named* theory (`ofOrdinal (α+1)`, via `pto_ofOrdinal_succ`) with PTO
exactly `α`, so the statement "`fastGrowing` total below the PTO" has a concrete carrier and
its boundary is `pto`, not an abstract supremum.

**Testable conjecture (falsifiable).** There is a computable `ONote → OrdinalTheory` whose
value at `n` has `provablyWO = {β | β < n.repr}` and PTO `n.repr`, and `fastGrowing` at index
`a` is "provably total" in this theory iff `a.repr < n.repr`. (Falsified by exhibiting an
index `a` with `a.repr ≥ n.repr` whose `fastGrowing` is still provably total, or vice versa.)

## Direction 5 — A genuine `PseudoMetricSpace`/`EMetricSpace`-style typeclass for ordinal-valued distances

`natDepthDist` satisfies every metric axiom but lands in `Ordinal`, not `ℝ≥0∞`, so it is not
an instance of Mathlib's `PseudoMetricSpace`. The key insight is that `Ordinal` with `♯` is a
commutative, cancellative, ordered monoid, exactly the algebraic data needed for a
*generalized* (monoid-valued) metric; abstracting `PseudoMetricSpace` over such a value monoid
would make `natDepthDist` a bona fide instance and let Mathlib's metric API (balls, uniform
continuity, isometries) apply to proof-theoretic ordinals. Why now? Our four metric axioms
for `natDepthDist` (symmetry, diagonal, faithfulness, `♯`-triangle) are precisely the axioms
such a typeclass would demand, so the abstraction can be *validated* against a worked example
on day one rather than developed in a vacuum.

**Testable conjecture (falsifiable).** There is a `class GenMetricSpace (V : Type*)
[OrderedAddCommMonoid V] (X : Type*)` with distance in `V`, symmetry, `d x y = 0 ↔ x = y`
(on the faithful quotient), and `d x z ≤ d x y + d y z`, for which `(PtoQuot, natDepthDist)`
with `V = (Ordinal, ♯)` is an instance, and the induced "isometry" notion makes
`ptoQuotEquiv` an isometry onto `(Ordinal, |·-·|_♯)`. (Falsified if the `♯`-triangle fails for
the descended distance, which `natDepthDist_triangle` forbids.)
