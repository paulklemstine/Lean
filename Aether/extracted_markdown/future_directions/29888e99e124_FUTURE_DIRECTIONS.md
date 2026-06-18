# Future Directions: Entropy-Bounded Computation (EBC)

This cycle established a fully formal, `sorry`-free core for the **Entropy-Bounded
Computation** framework in `Catalog/Computation/EntropyBoundedComputation.lean`.
We model one deterministic computational step as a function between finite *state
spaces* and define `EBC.entropy S := Real.logb 2 (Fintype.card S)`, the Shannon
entropy (in bits) of the uniform distribution over states. On this skeleton we
proved the structural laws of information under computation:

* `entropy_nonneg`, `entropy_eq_zero_of_card_one` (ground facts),
* `entropy_reversible_invariant` (bijections preserve entropy — reversibility),
* `entropy_prod` (additivity over independent product spaces),
* `entropy_le_of_surjective` (a deterministic map cannot create entropy — a
  data-processing / second-law inequality), and
* `landauer_erasure_pos` / `landauer_erasure_eq` (Landauer's principle: erasing a
  multi-state space to a point dissipates strictly positive entropy).

These results generalize `Computation/EntropyBridge.lean`, which only bounded
*cardinality* through injective encodings: we promote log-cardinality to a
genuine real-valued entropy functional and prove its algebra. The directions
below extend that functional toward an information-theoretic theory of
computation that is mechanically checkable end to end.

---

## Direction 1 — Entropy is subadditive under arbitrary deterministic maps

Strengthen `entropy_le_of_surjective` by dropping surjectivity: for **any**
`f : S → T` the image `Set.range f` is the genuine reachable output space, and
`entropy (Set.range f) ≤ entropy S`, with equality iff `f` is injective. This
turns the second-law inequality into an exact accounting: the *entropy defect*
`entropy S − entropy (Set.range f)` is precisely the information irreversibly
discarded by the step.

**The key insight is** that for finite types `Fintype.card (Set.range f) ≤
Fintype.card S` always holds (`Set.card_range_le`), and equality is exactly
`Function.Injective f` — so the entire reversibility/irreversibility dichotomy is
already encoded in the cardinality of the range, with no probability theory
required.

**Why now?** We already have `entropy_le_of_surjective` and
`entropy_reversible_invariant` as the two extreme cases (surjective and
bijective); the general statement is the natural interpolation between them and
needs only `Set.range`/`Finset.image` cardinality lemmas that are present in
Mathlib, so it is reachable in a single cycle.

## Direction 2 — Compositional cost: entropy defect is additive along pipelines

Define `defect f := entropy S − entropy (Set.range f)` and prove that for a
pipeline `g ∘ f` the total dissipated entropy is bounded by the sum of stage
defects: `defect (g ∘ f) ≤ defect f + defect g`, with equality when the stages
do not "re-merge" already-merged states. This is the EBC analogue of additivity
of thermodynamic cost along a process.

**The key insight is** that `Set.range (g ∘ f) = g '' (Set.range f)`, so the
two-stage cardinality collapse factors through the intermediate space, letting
the telescoping `entropy S − entropy (range (g∘f))` split exactly at the
intermediate entropy `entropy (Set.range f)`.

**Why now?** `entropy_prod` already proves the additive law for *independent*
composition; the *sequential* additivity law is the missing dual, and with
Direction 1's defect functional in hand it becomes a short telescoping argument.

## Direction 3 — A Landauer lower bound on erased bits

Promote `landauer_erasure_pos` to a quantitative bound: any computation that
collapses `S` onto a target of size `k` dissipates at least
`Real.logb 2 (Fintype.card S) − Real.logb 2 k` bits, and resetting `n`
independent bits (`S = (Fin 2)^n` reduced to a point) costs exactly `n` bits.
This is the discrete, fully verified form of Landauer's `kT ln 2` per bit.

**The key insight is** that the per-bit cost `n` arises from iterating
`entropy_prod` over an `n`-fold product `(Fin 2)^n`, giving `entropy = n`
exactly, so the "one bit erased ⇒ one bit dissipated" slogan becomes a literal
equation rather than an inequality.

**Why now?** `entropy_prod` gives additivity and `landauer_erasure_pos` gives
positivity; combining them over a finite power is a clean induction, and the
exact `entropy ((Fin 2)^n) = n` identity is the headline corollary that makes the
framework quantitative.

## Direction 4 — From uniform entropy to Shannon entropy of distributions

Replace the uniform-distribution assumption by a probability mass function
`p : S → ℝ≥0` and define `H p := −∑ x, p x * Real.logb 2 (p x)`, recovering
`EBC.entropy S` as the maximum `H p = entropy S` attained at the uniform `p`
(maximum-entropy principle). Then re-prove the EBC laws (data processing,
subadditivity) at this finer resolution.

**The key insight is** that `entropy S` is exactly the `log`-cardinality upper
bound `H p ≤ Real.logb 2 (Fintype.card S)` from Jensen/Gibbs' inequality, so the
current uniform theory is precisely the *tight* boundary of the distributional
theory — every theorem proved here is the equality case of a sharper inequality.

**Why now?** Mathlib already carries convexity of `x ↦ x log x` and finite
Jensen-type lemmas; anchoring the new `H p` theory to the already-proven
`entropy S` as its maximum gives a verified sanity check at every step and a
clear target value for the maximum-entropy theorem.

## Direction 5 — Reversible cores and the cost of embedding irreversible maps

Every irreversible `f : S → T` can be made reversible by enlarging the state
space (the Bennett embedding): there is an injection `S ↪ T × G` with
`entropy (T × G) = entropy S`, where `G` (the "garbage" register) absorbs exactly
the discarded `defect f` bits. Formalize this and prove that the minimal garbage
entropy equals the defect of Direction 1.

**The key insight is** that adding a garbage register of size
`Fintype.card S / Fintype.card (Set.range f)` restores injectivity, and by
`entropy_prod` its entropy is *additive*, so the minimal reversible embedding has
garbage entropy exactly equal to the entropy lost — reversibility is recovered at
precisely, and only at, the thermodynamic cost predicted by Landauer.

**Why now?** `entropy_reversible_invariant` (reversible = entropy-preserving) and
`entropy_prod` (additivity) are exactly the two ingredients the Bennett
construction needs; with Direction 1's defect functional this becomes the capstone
theorem unifying reversibility, composition, and Landauer cost in one statement.
