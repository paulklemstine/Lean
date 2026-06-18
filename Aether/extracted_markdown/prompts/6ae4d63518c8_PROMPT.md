            # Phase A Research Mission v16: These conjectures continue the research cycle begun in

            ## Concept
            **Domain**: Combinatorics
            **Research mode**: team
            **Title**: These conjectures continue the research cycle begun in
            **Description**: # Future Directions: Metric Filtration Rank Profiles as Tropical Valuation Objects

These conjectures continue the research cycle begun in
`Catalog/Tropical/MetricFiltrationRankProfiles.lean`, which proves that the rank
profile `rankEndo T i k = finrank (range (transEndo T i k))` of a discrete
filtration (single–ambient–space model) is squeezed between a min-plus
submultiplicative upper bound (`rankEndo_submult`, `trop_rankEndo_submult`) and a
Frobenius/Sylvester additive lower bound (`rankEndo_sylvester`), and that the
classical TDA rank invariant `rankIv` is monotone under interval restriction
(`rankIv_mono_restrict`).

Each conjecture below is stated so that it can be turned directly into a Lean
`theorem ... := by sorry` skeleton.

## C1 — Dependent-family generalisation
The whole theory should lift from the single-ambient-space model (all spaces
equal to `V`) to a genuine persistence module `X : ℕ → Type` with step maps
`step i : X i →ₗ[K] X (i+1)`. Conjecture: with transitions defined by
`Nat.add`-recursion and the codomain transport `Nat.add_assoc ▸ ·`, the
statements `rankEndo_submult`, `rankEndo_sylvester`, and `rankIv_mono_restrict`
hold verbatim, where `finrank V` in the Sylvester bound is replaced by
`finrank (X (i+k))` (the dimension of the *intermediate* space). Testable:
formalize `structure PersMod` with instance fields and re-prove the sandwich.

## C2 — Möbius/barcode nonnegativity (structure theorem)
For `i ≤ j`, define the box (mixed second difference)
`mult T i j = rankIv T i j - rankIv T (i-1) j - rankIv T i (j+1) + rankIv T (i-1) (j+1)`.
Conjecture: `0 ≤ mult T i j` for every persistence module over a field (with the
convention `rankIv T i j = 0` for `i > j`). Equivalently, the rank invariant of a
pointwise-finite-dimensional persistence module is the cumulative-rank transform
of a nonnegative barcode multiplicity (Möbius inversion over the interval poset).
This is the formal content of "rank invariant ⟺ barcode" and would require a
two-dimensional Sylvester/diamond inequality strengthening `rankEndo_sylvester`.

## C3 — Tropical idempotency / ultrametric law for the persistent rank
Let `ρ T i = ⨅ k, rankEndo T i k` be the stable (persistent) rank from level `i`,
shown to exist by `rankEndo_eventually_const`. Conjecture: `ρ` satisfies the
tropical *idempotent* law `ρ T i = rankEndo T i k` for all `k ≥ N(i)`, and the
two-variable persistent rank `R∞ T i j := ⨅ m, rankIv T i (j+m)` is an
**ultrametric-style valuation**: `R∞ T i k ≥ min (R∞ T i j) (R∞ T j k)` reversed,
i.e. `R∞ T i k ≤ min (R∞ T i j) (R∞ T j k)` with equality whenever the middle
level `j` is past the stabilisation threshold. This pins down exactly when the
min-plus submultiplicativity `rankEndo_submult` is an equality.

## C4 — Tropical-semiring homomorphism, not merely lax
`trop_rankEndo_submult` shows `tropRank` is a *lax* (sub-multiplicative) morphism
into `Tropical (WithTop ℕ)`. Conjecture: it is a genuine semiring *homomorphism*
(equality in submultiplicativity, `rankEndo T i (k+l) = min (rankEndo T i k)
(rankEndo T (i+k) l)`) **iff** every step map `T (i+m)` for `0 ≤ m < k+l` is
either injective on the relevant image or has rank governed entirely by one
endpoint — precisely, iff no rank is lost in the "interior" of the interval.
Formalize the iff and characterize the equality locus combinatorially (it should
match the set of barcode death-times in `[i, i+k+l]`).

## C5 — Stability / Lipschitz bound in the tropical metric
Equip rank profiles with the tropical (min-plus) sup-metric
`d(R, R') = sup_{i,k} |R i k - R' i k|`. Conjecture: if two filtrations `T, T'`
have step maps that agree except at a single index `m` where
`finrank (range (T m)) = finrank (range (T' m)) ± 1`, then
`d(rankEndo_T, rankEndo_T') ≤ 1`. More generally, the rank profile is
1-Lipschitz with respect to the number of altered steps — a discrete tropical
analogue of the persistence stability theorem. Testable as a Lean theorem
bounding `|rankEndo T i k - rankEndo T' i k|` by the number of indices where the
step ranks differ.

            **Mathematical framing**: # Future Directions: Metric Filtration Rank Profiles as Tropical Valuation Objects

These conjectures continue the research cycle begun in
`Catalog/Tropical/MetricFiltrationRankProfiles.lean`, which proves that the rank
profile `rankEndo T i k = finrank (range (transEndo T i k))` of a discrete
filtration (single–ambient–space model) is squeezed between a min-plus
submultiplicative upper bound (`rankEndo_submult`, `trop_rankEndo_submult`) and a
Frobenius/Sylvester additive lower bound (`rankEndo_sylvester`), and that the
classical TDA rank invariant `rankIv` is monotone under interval restriction
(`rankIv_mono_restrict`).

Each conjecture below is stated so that it can be turned directly into a Lean
`theorem ... := by sorry` skeleton.

## C1 — Dependent-family generalisation
The whole theory should lift from the single-ambient-space model (all spaces
equal to `V`) to a genuine persistence module `X : ℕ → Type` with step maps
`step i : X i →ₗ[K] X (i+1)`. Conjecture: with transitions defined by
`Nat.add`-recursion and the codomain transport `Nat.add_assoc ▸ ·`, the
statements `rankEndo_submult`, `rankEndo_sylvester`, and `rankIv_mono_restrict`
hold verbatim, where `finrank V` in the Sylvester bound is replaced by
`finrank (X (i+k))` (the dimension of the *intermediate* space). Testable:
formalize `structure PersMod` with instance fields and re-prove the sandwich.

## C2 — Möbius/barcode nonnegativity (structure theorem)
For `i ≤ j`, define the box (mixed second difference)
`mult T i j = rankIv T i j - rankIv T (i-1) j - rankIv T i (j+1) + rankIv T (i-1) (j+1)`.
Conjecture: `0 ≤ mult T i j` for every persistence module over a field (with the
convention `rankIv T i j = 0` for `i > j`). Equivalently, the rank invariant of a
pointwise-finite-dimensional persistence module is the cumulative-rank transform
of a nonnegative barcode multiplicity (Möbius inversion over the interval poset).
This is the formal content of "rank invariant ⟺ barcode" and would require a
two-dimensional Sylvester/diamond inequality strengthening `rankEndo_sylvester`.

## C3 — Tropical idempotency / ultrametric law for the persistent rank
Let `ρ T i = ⨅ k, rankEndo T i k` be the stable (persistent) rank from level `i`,
shown to exist by `rankEndo_eventually_const`. Conjecture: `ρ` satisfies the
tropical *idempotent* law `ρ T i = rankEndo T i k` for all `k ≥ N(i)`, and the
two-variable persistent rank `R∞ T i j := ⨅ m, rankIv T i (j+m)` is an
**ultrametric-style valuation**: `R∞ T i k ≥ min (R∞ T i j) (R∞ T j k)` reversed,
i.e. `R∞ T i k ≤ min (R∞ T i j) (R∞ T j k)` with equality whenever the middle
level `j` is past the stabilisation threshold. This pins down exactly when the
min-plus submultiplicativity `rankEndo_submult` is an equality.

## C4 — Tropical-semiring homomorphism, not merely lax
`trop_rankEndo_submult` shows `tropRank` is a *lax* (sub-multiplicative) morphism
into `Tropical (WithTop ℕ)`. Conjecture: it is a genuine semiring *homomorphism*
(equality in submultiplicativity, `rankEndo T i (k+l) = min (rankEndo T i k)
(rankEndo T (i+k) l)`) **iff** every step map `T (i+m)` for `0 ≤ m < k+l` is
either injective on the relevant image or has rank governed entirely by one
endpoint — precisely, iff no rank is lost in the "interior" of the interval.
Formalize the iff and characterize the equality locus combinatorially (it should
match the set of barcode death-times in `[i, i+k+l]`).

## C5 — Stability / Lipschitz bound in the tropical metric
Equip rank profiles with the tropical (min-plus) sup-metric
`d(R, R') = sup_{i,k} |R i k - R' i k|`. Conjecture: if two filtrations `T, T'`
have step maps that agree except at a single index `m` where
`finrank (range (T m)) = finrank (range (T' m)) ± 1`, then
`d(rankEndo_T, rankEndo_T') ≤ 1`. More generally, the rank profile is
1-Lipschitz with respect to the number of altered steps — a discrete tropical
analogue of the persistence stability theorem. Testable as a Lean theorem
bounding `|rankEndo T i k - rankEndo T' i k|` by the number of indices where the
step ranks differ.





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
