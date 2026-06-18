# Future Directions: Robertson–Seymour for Matroids

The module `Catalog/Bridges/MatroidMinorWQO.lean` isolates the *logical core* of
the Robertson–Seymour program and ports it from graphs to matroid minors. It
proves, unconditionally and in full generality, the implication

> **well-quasi-ordering of a minor-closed universe ⇒ a finite excluded-minor
> characterization of every sub-property,**

both in the abstract (`excludedMinor_characterization`) and specialized to the
matroid minor order `≤m` (`matroid_excludedMinor_characterization`,
`matroid_class_excludedMinors_finite`). It also pins down the *necessity* of the
WQO hypothesis (`not_wellQuasiOrdered_discrete`: an infinite antichain — the
signature pathology of non-representable matroids — breaks finiteness). The hard,
domain-specific content that remains is the WQO hypothesis itself for concrete
matroid classes. The directions below are concrete, falsifiable next steps that
build directly on these theorems.

## 1. Ternary excluded minors are exactly {F₇, F₇*, non-Pappus} — a verified finite list

The theorem `matroid_class_excludedMinors_finite` says: *if* the ternary
(`𝔽₃`-representable) matroids are well-quasi-ordered by `≤m`, *then* the excluded
minors for ternary representability form a finite set. The next step is to feed
the conjectured finite list back in: formalize the three known excluded minors
(the Fano plane `F₇`, its dual `F₇*`, and the non-Pappus matroid) as explicit
`Matroid (Fin n)` objects and prove, by finite enumeration, that every rank-3
matroid on ≤ 9 elements avoiding all three as minors *is* `𝔽₃`-representable.

**The key insight is** that `mem_iff_forall_excludedMinors_not_le` reduces the
infinite-looking property "ternary-representable" to a *finite minor test* once
the obstruction list is known, so the conjecture becomes a bounded, decidable
enumeration rather than an analytic statement. **Why now?** Mathlib now has a
complete matroid minor API (`contract`, `delete`, `IsMinor`, duality) and
`Matroid.IsMinor` is a `PartialOrder`; the only missing primitive is a concrete
`𝔽₃`-representation predicate, which is a finite linear-algebra check over a
3-element field — exactly the kind of `Decidable` statement current automation
handles well.

## 2. The minor order restricted to a fixed rank is a well-quasi-order

Rather than attacking WQO for *all* representable matroids at once, fix the rank
`r` and the field `𝔽_q` and prove that `{M : Matroid (Fin n) | M.rank = r}` is
`PartiallyWellOrderedOn (· ≤ ·)` as `n → ∞`. Plugging this into
`matroid_class_excludedMinors_finite` yields a finite excluded-minor list *within
each rank stratum*.

**The key insight is** that bounded-rank `𝔽_q`-representable matroids embed into a
fixed Grassmannian over a finite field, so an infinite sequence of them lands in a
space carrying a natural product/Dickson structure — and Mathlib already proves
`WellQuasiOrdered.prod` and `WellQuasiOrdered.pi` (Dickson's lemma). **Why now?**
The Dickson/Higman infrastructure landed in Mathlib's `Order.WellQuasiOrder`, so a
rank-stratified WQO can be assembled from existing product-WQO lemmas instead of
being proved from scratch; this is the most realistic first instance of the
conjecture to mechanize.

## 3. Antichain duality: excluded minors of a property and of its dual

Matroid duality `M ↦ M✶` is an order-*reversing* involution on the minor order
(`contract` and `delete` swap under `✶`). Conjecture: for a minor-closed `S`, the
excluded minors of the *dual-closed* property `S✶ := {M | M✶ ∈ S}` are exactly the
duals of the excluded minors of `S`, giving a bijection
`excludedMinors S ≃ excludedMinors S✶`.

**The key insight is** that `excludedMinors` is defined purely from the order
`<`, so an order anti-automorphism must carry minimal-non-members to
maximal-... — wait, to minimal non-members of the dual — turning the finiteness of
one obstruction set into finiteness of the other *for free*. **Why now?** Mathlib's
`Matroid.Dual` is a full-fledged involution with the contraction/deletion duality
lemmas already proved, so this is a clean order-theoretic transport that reuses
`excludedMinors_isAntichain` and `excludedMinors_finite` verbatim.

## 4. Graphs as binary matroids: deriving the graph corollary from the matroid one

The classical Robertson–Seymour corollary for graphs ("every minor-closed graph
class has finitely many forbidden minors") should be *recovered* as the `q = 2`
instance of `matroid_class_excludedMinors_finite`, via the cycle matroid functor
`G ↦ M(G)` which sends graph minors to matroid minors. Formalize this functor and
prove it is minor-monotone; then graph-WQO ⇒ binary-matroid-WQO on the image.

**The key insight is** that the functor `G ↦ M(G)` is an order embedding from the
graph-minor poset into `(Matroid, ≤m)`, so well-quasi-ordering and excluded-minor
finiteness *pull back along it* — one abstract theorem covers both worlds. **Why
now?** Mathlib has `SimpleGraph`, a developing graph-minor vocabulary, and now a
matroid minor order; building the cycle-matroid bridge would be the first formal
link between the two minor theories and would let the single Lean theorem in this
module subsume the graph case.

## 5. From finite obstruction sets to a complexity dichotomy

If a class `𝒞` has a finite excluded-minor set `O`, then membership in any
minor-closed `S ⊆ 𝒞` is testable by checking finitely many minors (this is the
content of `mem_iff_forall_excludedMinors_not_le`). Conjecture: this yields a
uniform polynomial-time *membership oracle* once each "is `N` a minor of `M`?"
query is polynomial for fixed `N`, mirroring the graph-minor `O(n³)` algorithm.

**The key insight is** that the membership iff in this module is *quantified over
a finite set*, so it is not merely an existence statement — it is an explicit
algorithm template whose only inputs are the (finite) obstruction list and a minor
test. **Why now?** The catalog already contains complexity-flavored bridge work
(e.g. proof-search and digraph walk-counting bounds in `Catalog/Bridges/Basic.lean`),
so connecting the excluded-minor finiteness theorem here to a formal
fixed-parameter-tractability statement is a natural cross-domain synthesis that
turns a structural theorem into an algorithmic guarantee.
