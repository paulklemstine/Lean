# Future Directions — Hilbert's Sixth Problem: Axiomatic Probability

This cycle extended the finitely additive Kolmogorov axiomatization in
`Physics/KolmogorovAxioms.lean` with a self-contained calculus of conditional
probability and higher union/intersection bounds in
`Physics/KolmogorovConditional.lean`. The new results — the law of total
probability (`prob_total_two`), the multiplication rule (`condProb_mul`), Bayes'
theorem (`condProb_bayes`), the total-probability form of the Bayes denominator
(`prob_total_condProb`), three-event inclusion–exclusion
(`prob_inclusion_exclusion_three`), and the Bonferroni lower bound
(`prob_biInter_ge`) — all flow purely from the three axioms `nonneg`,
`prob_univ`, `additive`. Below are conjectures for the next cycle, each
falsifiable inside this same finitely additive framework.

## 1. General finite inclusion–exclusion (the Poincaré formula)

**Conjecture.** For any finite family `A : Fin n → Set Ω`,
`P (⋃ i, A i) = ∑_{∅ ≠ S ⊆ Fin n} (-1)^(|S|+1) · P (⋂ i ∈ S, A i)`.

The key insight is that the two-event modular law `prob_modular` is the `n = 2`
instance of a single alternating-sum identity, and the proof should be a
`Finset.induction` whose step peels off one event using `prob_modular` together
with distributivity `(⋃ i, A i) ∩ Aₙ = ⋃ i, (A i ∩ Aₙ)`, exactly mirroring the
manual three-event combination already carried out in
`prob_inclusion_exclusion_three`. Why now? We have just verified the base and the
`n = 3` case by hand, so the inductive bookkeeping is the only remaining
obstacle; formalizing it turns three ad-hoc lemmas into one reusable theorem and
yields the Bonferroni *upper* bounds (partial-sum truncations) as immediate
corollaries of `prob_biInter_ge`'s alternating refinement.

## 2. Independence is preserved under complementation

**Conjecture.** Define events `A`, `B` to be independent when
`P (A ∩ B) = P A · P B`. Then independence of `A, B` implies independence of each
of the pairs `(A, Bᶜ)`, `(Aᶜ, B)`, `(Aᶜ, Bᶜ)`.

The key insight is that `prob_total_two A B` rewrites `P (A ∩ Bᶜ) = P A − P (A∩B)`,
so substituting the product `P A · P B` and factoring gives
`P A · (1 − P B) = P A · P Bᶜ` via `prob_compl`. Why now? Both ingredients —
total probability and the complement rule — are already proved and combine in two
`linarith`/`ring` steps; this is the smallest genuinely new *structural* notion
(stochastic independence) that the axioms support, and it is the gateway to
conditional independence and Bayesian networks.

## 3. A finitely additive Bayesian update is a probability assignment

**Conjecture.** Fix `B` with `P B ≠ 0`. The map `Q A := condProb K A B` is itself
a `KolmogorovSpace` on `Ω` (it satisfies `nonneg`, `Q univ = 1`, and finite
additivity).

The key insight is that conditioning is *normalization of a restriction*:
`Q (A₁ ∪ A₂) = P((A₁∪A₂)∩B)/P B`, and `(A₁∪A₂)∩B = (A₁∩B)∪(A₂∩B)` is a disjoint
union whenever `A₁, A₂` are disjoint, so `additive` for `Q` reduces to `additive`
for `K` divided by the constant `P B`; normalization is `condProb_mul` with
`A = univ`. Why now? `condProb` and `condProb_mul` are in hand, so packaging the
posterior as a first-class `KolmogorovSpace` is mostly plumbing — and it is the
precise statement that "Bayesian updating stays within the axioms," the
conceptual payoff of Hilbert's sixth problem for inference.

## 4. Continuity at ∅ characterizes σ-additivity (the bridge to measures)

**Conjecture.** A finitely additive `KolmogorovSpace` extends to a Mathlib
`MeasureTheory.IsProbabilityMeasure` if and only if it is *continuous at ∅*:
for every decreasing chain `Aₙ` of events with `⋂ₙ Aₙ = ∅`, `P (Aₙ) → 0`.

The key insight is that countable additivity is equivalent to finite additivity
plus downward continuity at the empty set (the classical Kolmogorov continuity
theorem), and our `prob_mono` already gives that `P (Aₙ)` is a bounded monotone
sequence so only the limit value is in question. Why now? Mathlib supplies the
target structure `MeasureTheory.Measure`/`IsProbabilityMeasure`, and our
finitely additive layer is exactly the hypothesis side of Carathéodory-style
extension; bridging the two would connect this hand-rolled axiomatization to the
full measure-theoretic library rather than leaving them as parallel universes.

## 5. The valuation/lattice view: probability as a modular monotone valuation

**Conjecture.** The assignment `P` is a *valuation* on the Boolean algebra
`Set Ω` in the order-theoretic sense — monotone (`prob_mono`) and modular
(`prob_modular`) — and conversely every `[0,1]`-valued normalized monotone
modular valuation that is additive on disjoint joins is a `KolmogorovSpace`.

The key insight is that `prob_modular` is *literally* the defining identity of a
lattice valuation `v(x ⊔ y) + v(x ⊓ y) = v(x) + v(y)`, so probability theory is a
special chapter of valuation theory on distributive lattices, which in turn is
the entry point to topos-/locale-theoretic probability. Why now? We have proved
both the monotonicity and the modular law as standalone theorems, so the forward
direction is immediate; stating and proving the converse would expose the
*minimal* lattice-theoretic axioms behind Kolmogorov's set-theoretic ones and
make explicit the topos-theoretic connection flagged in the original concept.
