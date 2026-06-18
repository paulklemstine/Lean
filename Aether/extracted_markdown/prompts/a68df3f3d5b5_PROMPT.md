            # Phase A Research Mission v17: Follow-up conjectures arising from `Catalog/Bridges/RipsTropicalFunctor.lean`, w

            ## Concept
            **Domain**: Physics
            **Research mode**: team
            **Title**: Follow-up conjectures arising from `Catalog/Bridges/RipsTropicalFunctor.lean`, w
            **Description**: # Future Directions — Rips Filtrations ↔ Tropical Valuation Objects

Follow-up conjectures arising from `Catalog/Bridges/RipsTropicalFunctor.lean`, which
established:

* a concrete max-plus model `tropMaxPlus : TropicalValuationObject (WithBot ℝ)` of the
  catalog's abstract tropical valuation structure;
* **simplex-count monotonicity** `simplexCount_monotone` (the functorial action on the
  poset `(ℝ, ≤)`);
* the **bridge** `rips_complete_iff_tropBirthSum_le`: the Rips 1-skeleton is complete at
  scale `ε` iff the tropical (max-plus) sum of edge births is `≤ ε`;
* saturation `simplexCount_eq_max_iff` and metric functoriality
  `tropBirthSum_mono_of_lipschitz_surj`.

Each conjecture below is stated to be *falsifiable* and directly formalizable in Lean.

---

## Conjecture 1 (Tropical connectivity threshold = spanning-tree max edge)

For a finite pseudometric space `α`, the **connectivity threshold**
`εc = inf {ε | (ripsGraph α ε).Connected}` equals the tropical (max-plus) *minimum over
spanning trees of the maximum edge*, i.e. the minimax path value:
`εc = ⊓_{T spanning tree} ⊔_{e ∈ T} dist e`.
Equivalently, `εc` is the largest edge on the minimum spanning tree (the "bottleneck").

* **Testable form**: define `connThreshold α` via `Connected` and prove it equals
  `Finset`-level minimax over the complete weighted graph; for the 4-point example
  `{0,1,3,7} ⊂ ℝ`, `εc = 3`.
* **Why bold**: it would make tropical algebra compute the *single-linkage clustering*
  dendrogram, linking `MetricFiltration` π₀-behavior to the tropical semiring exactly.

## Conjecture 2 (Tropical-sum subadditivity under metric products)

For finite pseudometric spaces `α`, `β` with the sup (ℓ∞) product metric on `α × β`,
`tropBirthSum (α × β) = max (tropBirthSum α) (tropBirthSum β)`
(tropical addition is preserved by products), while for the ℓ¹ product metric one only
has `tropBirthSum (α × β) ≤ tropBirthSum α + tropBirthSum β` (tropical multiplication
gives an upper bound).

* **Testable form**: two equalities/inequalities in `WithBot ℝ`; the ℓ∞ case should be a
  clean `Finset.sup` distribution lemma.
* **Why bold**: it turns the catalog's "`add = max`, `mul = +`" dictionary into a *metric
  product law*, i.e. a monoidal-functor statement for the Rips→Tropical functor.

## Conjecture 3 (Monotone count determines the tropical threshold)

The simplex-count function `simplexCount α : ℝ → ℕ` determines `tropBirthSum α`:
`tropBirthSum α = sInf {ε | simplexCount α ε = #(univ.offDiag)}` (with the convention that
the set is all of `ℝ` exactly above the threshold, giving `⊥` when `α` has `≤ 1` point).

* **Testable form**: an `sInf`/`csInf` characterization combining
  `simplexCount_saturates_iff_tropBirthSum_le` with right-continuity of `simplexCount`.
* **Why bold**: it shows the *integer* persistence invariant (a counting functor) recovers
  the *tropical* invariant — a discrete-to-tropical reconstruction theorem in miniature.

## Conjecture 4 (Functor laws: identity and composition of contractions)

The assignment `X ↦ tropBirthSum X` together with the morphism action of Conjecture-style
1-Lipschitz surjections satisfies the functor laws up to the order `≤`:
`tropBirthSum` is preserved by isometric bijections (`dist (f x)(f y) = dist x y`,
`f` bijective ⟹ equality) and the contraction bound composes:
if `g ∘ f` is a 1-Lipschitz surjection through a 1-Lipschitz surjection, the threshold
bounds chain. Formally, isometric bijections induce `tropBirthSum α = tropBirthSum β`.

* **Testable form**: strengthen `tropBirthSum_mono_of_lipschitz_surj` to an equality under
  bijective isometries, and prove a 2-step composition corollary.
* **Why bold**: it upgrades the current one-sided functoriality to a genuine *invariance*
  theorem, certifying `tropBirthSum` as an isometry invariant of finite metric spaces.

## Conjecture 5 (Higher simplices: k-clique counts are jointly monotone and tropical)

Let `cliqueCount α k ε` be the number of `(k+1)`-cliques (`k`-simplices of the
Vietoris–Rips complex) at scale `ε`. Then for every `k`, `cliqueCount α k` is monotone in
`ε`, and the Rips complex contains the full `k`-skeleton at scale `ε` iff
`tropBirthSum α ≤ ε` (the *same* tropical threshold governs all dimensions, because a
clique is present iff all its edges are).

* **Testable form**: define `k`-clique finsets, prove monotonicity (generalizing
  `simplexCount_monotone`) and a single-threshold completeness criterion generalizing
  `simplexCount_eq_max_iff`.
* **Why bold**: it predicts that the *entire* Vietoris–Rips complex (all dimensions)
  collapses to one tropical scalar `tropBirthSum α` at the completeness scale, extending
  the 1-skeleton bridge to a full-complex functor into the tropical valuation object.

            **Mathematical framing**: # Future Directions — Rips Filtrations ↔ Tropical Valuation Objects

Follow-up conjectures arising from `Catalog/Bridges/RipsTropicalFunctor.lean`, which
established:

* a concrete max-plus model `tropMaxPlus : TropicalValuationObject (WithBot ℝ)` of the
  catalog's abstract tropical valuation structure;
* **simplex-count monotonicity** `simplexCount_monotone` (the functorial action on the
  poset `(ℝ, ≤)`);
* the **bridge** `rips_complete_iff_tropBirthSum_le`: the Rips 1-skeleton is complete at
  scale `ε` iff the tropical (max-plus) sum of edge births is `≤ ε`;
* saturation `simplexCount_eq_max_iff` and metric functoriality
  `tropBirthSum_mono_of_lipschitz_surj`.

Each conjecture below is stated to be *falsifiable* and directly formalizable in Lean.

---

## Conjecture 1 (Tropical connectivity threshold = spanning-tree max edge)

For a finite pseudometric space `α`, the **connectivity threshold**
`εc = inf {ε | (ripsGraph α ε).Connected}` equals the tropical (max-plus) *minimum over
spanning trees of the maximum edge*, i.e. the minimax path value:
`εc = ⊓_{T spanning tree} ⊔_{e ∈ T} dist e`.
Equivalently, `εc` is the largest edge on the minimum spanning tree (the "bottleneck").

* **Testable form**: define `connThreshold α` via `Connected` and prove it equals
  `Finset`-level minimax over the complete weighted graph; for the 4-point example
  `{0,1,3,7} ⊂ ℝ`, `εc = 3`.
* **Why bold**: it would make tropical algebra compute the *single-linkage clustering*
  dendrogram, linking `MetricFiltration` π₀-behavior to the tropical semiring exactly.

## Conjecture 2 (Tropical-sum subadditivity under metric products)

For finite pseudometric spaces `α`, `β` with the sup (ℓ∞) product metric on `α × β`,
`tropBirthSum (α × β) = max (tropBirthSum α) (tropBirthSum β)`
(tropical addition is preserved by products), while for the ℓ¹ product metric one only
has `tropBirthSum (α × β) ≤ tropBirthSum α + tropBirthSum β` (tropical multiplication
gives an upper bound).

* **Testable form**: two equalities/inequalities in `WithBot ℝ`; the ℓ∞ case should be a
  clean `Finset.sup` distribution lemma.
* **Why bold**: it turns the catalog's "`add = max`, `mul = +`" dictionary into a *metric
  product law*, i.e. a monoidal-functor statement for the Rips→Tropical functor.

## Conjecture 3 (Monotone count determines the tropical threshold)

The simplex-count function `simplexCount α : ℝ → ℕ` determines `tropBirthSum α`:
`tropBirthSum α = sInf {ε | simplexCount α ε = #(univ.offDiag)}` (with the convention that
the set is all of `ℝ` exactly above the threshold, giving `⊥` when `α` has `≤ 1` point).

* **Testable form**: an `sInf`/`csInf` characterization combining
  `simplexCount_saturates_iff_tropBirthSum_le` with right-continuity of `simplexCount`.
* **Why bold**: it shows the *integer* persistence invariant (a counting functor) recovers
  the *tropical* invariant — a discrete-to-tropical reconstruction theorem in miniature.

## Conjecture 4 (Functor laws: identity and composition of contractions)

The assignment `X ↦ tropBirthSum X` together with the morphism action of Conjecture-style
1-Lipschitz surjections satisfies the functor laws up to the order `≤`:
`tropBirthSum` is preserved by isometric bijections (`dist (f x)(f y) = dist x y`,
`f` bijective ⟹ equality) and the contraction bound composes:
if `g ∘ f` is a 1-Lipschitz surjection through a 1-Lipschitz surjection, the threshold
bounds chain. Formally, isometric bijections induce `tropBirthSum α = tropBirthSum β`.

* **Testable form**: strengthen `tropBirthSum_mono_of_lipschitz_surj` to an equality under
  bijective isometries, and prove a 2-step composition corollary.
* **Why bold**: it upgrades the current one-sided functoriality to a genuine *invariance*
  theorem, certifying `tropBirthSum` as an isometry invariant of finite metric spaces.

## Conjecture 5 (Higher simplices: k-clique counts are jointly monotone and tropical)

Let `cliqueCount α k ε` be the number of `(k+1)`-cliques (`k`-simplices of the
Vietoris–Rips complex) at scale `ε`. Then for every `k`, `cliqueCount α k` is monotone in
`ε`, and the Rips complex contains the full `k`-skeleton at scale `ε` iff
`tropBirthSum α ≤ ε` (the *same* tropical threshold governs all dimensions, because a
clique is present iff all its edges are).

* **Testable form**: define `k`-clique finsets, prove monotonicity (generalizing
  `simplexCount_monotone`) and a single-threshold completeness criterion generalizing
  `simplexCount_eq_max_iff`.
* **Why bold**: it predicts that the *entire* Vietoris–Rips complex (all dimensions)
  collapses to one tropical scalar `tropBirthSum α` at the completeness scale, extending
  the 1-skeleton bridge to a full-complex functor into the tropical valuation object.





### Recent Discoveries in Catalog
No previous research cycles completed yet. This is a cold start — prioritize sorry_fill on the priority targets (CarmichaelComposite, Fib_gcd_identity) to close known open problems, or target cross-domain bridge theorems for novelty.


            ## v17 Research Core Methodology — Concise Scientific Loop

Lead a 4-role team: Hypothesizer, Experimenter, Analyst, Critic.
Loop: Hypothesize → Experiment → Analyze → Critique → Synthesize.

1. **Hypothesize**: 5–7 falsifiable conjectures; ≥2 surprising.
2. **Experiment**: Prove or disprove in Lean 4; prioritize surprise.
3. **Analyze**: Document what survived, failed, and why.
4. **Critique**: Check for triviality, missing sorries, weak assumptions.
5. **Synthesize**: Clean Lean files + FUTURE_DIRECTIONS.md (3–5 testable
   conjectures, each with "The key insight is..." and "Why now?").

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
