            # Phase A Research Mission v18: `Catalog/Bridges/FunctorialTropicalPythagorean.lean` (0 sorr

            ## Concept
            **Domain**: Probability
            **Research mode**: team
            **Title**: `Catalog/Bridges/FunctorialTropicalPythagorean.lean` (0 sorr
            **Description**: # FUTURE DIRECTIONS — Functorial Tropical Ultrametric from Pythagorean Lorentz Triples

This cycle produced `Catalog/Bridges/FunctorialTropicalPythagorean.lean` (0 sorries, only
standard axioms). It builds the canonical **tree ultrametric** `d` on the boundary
`Addr = ℕ → Fin 3` of the ternary Berggren tree, proves it is a genuine ultrametric
(`d_ultra`), realizes the three Berggren generators as exact `(1/2)`-similarities
(`d_cons_same`, `d_cons_diff`), records the tropical min-plus core
(`firstDiff_ge_min`, `firstDiff_cons_tropical`), the depth↔log-hypotenuse growth law
(`seed_hyp_growth`, `bchild_iter_hyp_growth`), and a functorial bridge into the catalog
valuation-reconstruction functor via Gaussian integers (`gaussianSupportCarrier`,
`gaussian_reconstruct_ultrametric`).

The following conjectures are **bold but testable** in Lean, each with the partial evidence
already established this cycle.

## C1. Metric-space packaging and compactness (Cantor space)
**Conjecture.** `(Addr, d)` underlies a Mathlib `MetricSpace` that is **complete** and
**compact** (a Cantor space), with `d` an ultrametric (`IsUltrametricDist`).
*Evidence.* `d_self`, `d_comm`, `d_eq_zero_iff`, `d_triangle`, `d_ultra`, `d_le_one` are all
proved — these are exactly the metric/ultrametric axioms. *Test.* Assemble a
`PseudoMetricSpace`/`MetricSpace` instance, register `IsUltrametricDist`, then prove
totally-bounded + complete ⇒ compact. Falsifiable: it fails iff some Cauchy address
sequence has no limit, which it cannot since coordinates stabilize.

## C2. Hausdorff dimension of the Berggren boundary = log 3 / log 2
**Conjecture.** The Berggren branch IFS `{cons 0, cons 1, cons 2}` satisfies the open-set
condition with three `(1/2)`-similarities, so `dimH (Set.univ : Set Addr) = log 3 / log 2`.
*Evidence.* `d_cons_same` (ratio exactly `1/2`) and `d_cons_diff` (images pairwise at
distance `1`, hence disjoint clopen balls) give the contraction ratios and separation.
*Test.* Build the self-similar covering by depth-`n` cylinders (there are `3^n`, each of
diameter `2^{-n}`) and bound the Hausdorff measure two-sidedly. Falsifiable by exhibiting a
covering of smaller/larger exponent.

## C3. Two-sided depth–size law along every ray
**Conjecture.** There exist constants `0 < α ≤ β` such that every primitive Pythagorean
triple reached at Berggren tree depth `n` has hypotenuse `c` with
`α · ρ_min^n ≤ c ≤ β · ρ_max^n`, where `ρ_min, ρ_max` are the minimal/maximal
hypotenuse-expansion factors of the generators `A, B, C`; consequently metric depth is
`Θ(log c)` and `d`-balls of radius `2^{-n}` correspond to hypotenuse scale windows.
*Evidence.* `bchild_iter_hyp_growth` / `seed_hyp_growth` prove the lower bound `c·3^n ≤ hyp`
along the all-`B` ray (`ρ = 3`). *Test.* Establish per-generator upper bounds
(e.g. `hyp ≤ 7c` from `BerggrenLorentz.hypB_upper_bound`) and combine over arbitrary words.
Falsifiable by a word whose hypotenuse escapes the geometric window.

## C4. The Berggren monoid acts by ultrametric endomorphisms (categorical action)
**Conjecture.** Each generator `cons k` extends to a non-expansive endomorphism of an object
of the `CategoricalTropicalUltrametric` category, and word composition is functorial, so the
free Berggren monoid embeds into the endomorphism monoid of that object; the min-plus
`firstDiff` valuation is the exact order-dual of a max-plus `TropicalValuationObject`.
*Evidence.* `cons_contraction` (`1/2`-Lipschitz), `firstDiff_cons_tropical`
(tropical-multiplication law), and the existing functoriality theorems
`tropicalization_map_comp`, `valuationReconstruct_map_comp`. *Test.* Define the dual
min-plus object and a faithful monoid homomorphism `BerggrenWord → End(·)`. Falsifiable if
some relation collapses two distinct words (it should not — Berggren generators are free).

## C5. Nontrivial `(1+i)`-adic valuation refines the Gaussian bridge
**Conjecture.** Replacing the support valuation by the `(1+i)`-adic valuation `v` on `ℤ[i]`
gives a *nontrivial* ultrametric whose value on the Gaussian encoding `m + n·i` of a
primitive triple `(m²−n², 2mn, m²+n²)` equals the `2`-adic valuation of the even leg `2mn`;
i.e. `v` reads off the power of `2` dividing the even leg.
*Evidence.* `gaussian_norm_eq` (norm `= m²+n²` = hypotenuse) and `gaussian_norm_mul`
(multiplicativity) fix the arithmetic; the support valuation `gval` is the trivial endpoint
of this family. *Test.* Define `v` via `multiplicity (1+i)` or `Zsqrtd` factorization and
prove the even-leg identity. Falsifiable on any explicit triple where the `(1+i)`-adic
valuation and the even-leg `2`-adic valuation disagree.

            **Mathematical framing**: # FUTURE DIRECTIONS — Functorial Tropical Ultrametric from Pythagorean Lorentz Triples

This cycle produced `Catalog/Bridges/FunctorialTropicalPythagorean.lean` (0 sorries, only
standard axioms). It builds the canonical **tree ultrametric** `d` on the boundary
`Addr = ℕ → Fin 3` of the ternary Berggren tree, proves it is a genuine ultrametric
(`d_ultra`), realizes the three Berggren generators as exact `(1/2)`-similarities
(`d_cons_same`, `d_cons_diff`), records the tropical min-plus core
(`firstDiff_ge_min`, `firstDiff_cons_tropical`), the depth↔log-hypotenuse growth law
(`seed_hyp_growth`, `bchild_iter_hyp_growth`), and a functorial bridge into the catalog
valuation-reconstruction functor via Gaussian integers (`gaussianSupportCarrier`,
`gaussian_reconstruct_ultrametric`).

The following conjectures are **bold but testable** in Lean, each with the partial evidence
already established this cycle.

## C1. Metric-space packaging and compactness (Cantor space)
**Conjecture.** `(Addr, d)` underlies a Mathlib `MetricSpace` that is **complete** and
**compact** (a Cantor space), with `d` an ultrametric (`IsUltrametricDist`).
*Evidence.* `d_self`, `d_comm`, `d_eq_zero_iff`, `d_triangle`, `d_ultra`, `d_le_one` are all
proved — these are exactly the metric/ultrametric axioms. *Test.* Assemble a
`PseudoMetricSpace`/`MetricSpace` instance, register `IsUltrametricDist`, then prove
totally-bounded + complete ⇒ compact. Falsifiable: it fails iff some Cauchy address
sequence has no limit, which it cannot since coordinates stabilize.

## C2. Hausdorff dimension of the Berggren boundary = log 3 / log 2
**Conjecture.** The Berggren branch IFS `{cons 0, cons 1, cons 2}` satisfies the open-set
condition with three `(1/2)`-similarities, so `dimH (Set.univ : Set Addr) = log 3 / log 2`.
*Evidence.* `d_cons_same` (ratio exactly `1/2`) and `d_cons_diff` (images pairwise at
distance `1`, hence disjoint clopen balls) give the contraction ratios and separation.
*Test.* Build the self-similar covering by depth-`n` cylinders (there are `3^n`, each of
diameter `2^{-n}`) and bound the Hausdorff measure two-sidedly. Falsifiable by exhibiting a
covering of smaller/larger exponent.

## C3. Two-sided depth–size law along every ray
**Conjecture.** There exist constants `0 < α ≤ β` such that every primitive Pythagorean
triple reached at Berggren tree depth `n` has hypotenuse `c` with
`α · ρ_min^n ≤ c ≤ β · ρ_max^n`, where `ρ_min, ρ_max` are the minimal/maximal
hypotenuse-expansion factors of the generators `A, B, C`; consequently metric depth is
`Θ(log c)` and `d`-balls of radius `2^{-n}` correspond to hypotenuse scale windows.
*Evidence.* `bchild_iter_hyp_growth` / `seed_hyp_growth` prove the lower bound `c·3^n ≤ hyp`
along the all-`B` ray (`ρ = 3`). *Test.* Establish per-generator upper bounds
(e.g. `hyp ≤ 7c` from `BerggrenLorentz.hypB_upper_bound`) and combine over arbitrary words.
Falsifiable by a word whose hypotenuse escapes the geometric window.

## C4. The Berggren monoid acts by ultrametric endomorphisms (categorical action)
**Conjecture.** Each generator `cons k` extends to a non-expansive endomorphism of an object
of the `CategoricalTropicalUltrametric` category, and word composition is functorial, so the
free Berggren monoid embeds into the endomorphism monoid of that object; the min-plus
`firstDiff` valuation is the exact order-dual of a max-plus `TropicalValuationObject`.
*Evidence.* `cons_contraction` (`1/2`-Lipschitz), `firstDiff_cons_tropical`
(tropical-multiplication law), and the existing functoriality theorems
`tropicalization_map_comp`, `valuationReconstruct_map_comp`. *Test.* Define the dual
min-plus object and a faithful monoid homomorphism `BerggrenWord → End(·)`. Falsifiable if
some relation collapses two distinct words (it should not — Berggren generators are free).

## C5. Nontrivial `(1+i)`-adic valuation refines the Gaussian bridge
**Conjecture.** Replacing the support valuation by the `(1+i)`-adic valuation `v` on `ℤ[i]`
gives a *nontrivial* ultrametric whose value on the Gaussian encoding `m + n·i` of a
primitive triple `(m²−n², 2mn, m²+n²)` equals the `2`-adic valuation of the even leg `2mn`;
i.e. `v` reads off the power of `2` dividing the even leg.
*Evidence.* `gaussian_norm_eq` (norm `= m²+n²` = hypotenuse) and `gaussian_norm_mul`
(multiplicativity) fix the arithmetic; the support valuation `gval` is the trivial endpoint
of this family. *Test.* Define `v` via `multiplicity (1+i)` or `Zsqrtd` factorization and
prove the even-leg identity. Falsifiable on any explicit triple where the `(1+i)`-adic
valuation and the even-leg `2`-adic valuation disagree.





### Recent Discoveries in Catalog
No previous research cycles completed yet. This is a cold start — prioritize sorry_fill on the priority targets (CarmichaelComposite, Fib_gcd_identity) to close known open problems, or target cross-domain bridge theorems for novelty.


            ## v16 Research Core Methodology — Scientific Team Loop

You are the Principal Investigator leading a research team with four
roles: **Hypothesizer**, **Experimenter**, **Analyst**, and **Critic**.
Run the following loop and record notes at each stage.

### Stage 1 — Hypothesize (team: Hypothesizer)
Brainstorm 5–7 falsifiable conjectures about the topic. At least two
must be surprising or counter-intuitive. Rank them by expected
scientific impact, not by ease of proof.

### Stage 2 — Experiment (team: Experimenter)
For each conjecture, attempt to prove it in Lean 4 or disprove it with
a concrete counterexample. Prioritize the most surprising conjectures
first. If a proof is beyond reach, prove the strongest lemma you can
and mark the remaining step with exactly one `sorry` that is clearly
documented.

### Stage 3 — Analyze (team: Analyst)
Summarize what survived, what failed, and **why** failures failed.
Distinguish "true but hard", "false", and "needs a different
definition". These insights are as valuable as the proofs.

### Stage 4 — Critique / Adversarial Review (team: Critic)
Before finalizing, challenge every theorem:
- Is any theorem trivial (True, definitional equality, `native_decide`)?
- Does every main theorem have 0 sorries?
- Do the results genuinely extend the attached catalog files?
- Are there hidden assumptions or corner cases that break the claim?
If you find a weakness, fix it or replace the theorem with a guarded
version and explain the boundary.

### Stage 5 — Synthesize (team: Principal Investigator)
Combine the verified results into clean, compiling Lean 4 files.
Write a `FUTURE_DIRECTIONS.md` that lists 3–5 **bold, testable**
conjectures derived from Stage 3 and Stage 4. Each conjecture must
include a "The key insight is..." sentence and a "Why now?"
justification.

### Perpetual Scientific Iteration (do not stop at first synthesis)
When the research team comes together with results, do not stop. Treat the synthesized findings as the next problem statement and immediately run the full scientific-method loop again: hypothesize, experiment, review, synthesize, critique. Repeat this cycle continuously within the available context window, refining, deepening, and cross-checking until forced to emit output. Use Aristotle to its fullest.

### Mode-Specific Mission: prove
Your team is proving a targeted theorem. The Hypothesizer breaks
the main claim into lemmas; the Experimenter proves each lemma;
the Analyst ensures the pieces assemble into the main result;
the Critic tries to break the proof with edge cases. Main results
must have 0 sorries.


            ### Anti-Trivial Guardrails (non-negotiable)
The following are NOT acceptable as main results:
- Theorems of the form `theorem name {X : Type*} [Inhabited X] : True := by trivial`.
- Definition-only theorems or definitional equalities proved by `rfl`.
- Results whose entire proof is `simp`, `norm_num`, `decide`, or `native_decide`.
- Wrapper types that rename existing definitions.
- Re-proving existing catalog theorems with minor notation changes.

Every main theorem must use at least one insight-bearing tactic or
technique such as `induction`, `by_contra`, `field_simp`, `ring_nf`,
`omega`, `linarith`, `rcases`, or a custom helper lemma.


            ### Deliverables & Acceptance Criteria
1. **Lean 4 files** (2–4 files in the appropriate `Catalog/<domain>/` subtree).
   - Main theorems must be fully proved (0 sorries).
   - Each file must contain `-- !-- Lab Notes -- !--` blocks documenting
     the team loop: Hypothesis, Experiment, Analysis, Critique, Synthesis.
2. **FUTURE_DIRECTIONS.md** with 3–5 bold, falsifiable conjectures derived
   from the cycle's findings. Each must have a "The key insight is..."
   sentence and a "Why now?" justification.

### Strictly Forbidden in Phase A
- `ARTICLE.md`, `RESEARCH_PAPER.md`, `demo.py`, HTML widgets, `PACKAGE.json`.
- Prose for human readers other than Lab Notes and FUTURE_DIRECTIONS.md.


            ## Self-Critique Checklist (perform before final output)
            Review your candidate output and answer each item. If the answer is
            unsatisfactory, revise the output before returning it.

            - [ ] No theorem is trivial (True, Inhabited-only, native_decide-only, etc.).
            - [ ] Every main theorem has 0 sorries.
            - [ ] At least one theorem imports or uses results from the attached catalog.
            - [ ] Lab Notes blocks contain real hypotheses, results, insights, and failure analysis.
            - [ ] FUTURE_DIRECTIONS.md conjectures are derived from this cycle's findings.
            - [ ] Every future direction includes a "The key insight is..." sentence and a "Why now?" justification.

            ## Output Format Reminder
            Return `.lean` files and `FUTURE_DIRECTIONS.md` only. Focus all compute
            on the mathematics.
