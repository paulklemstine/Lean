
            ## PHASE A: LEAN 4 ONLY — DOING THE MATH

            You are a world-class mathematician. Your ONLY job in this cycle is
to produce **new Lean 4 code that extends the frontier of mathematics**.

            ### DELIVERABLES (strict — only this):
            1. **lean files (count chosen by the Plan)**
            2. **2-4 theorems with correct proofs (sorry = 0 on main results)**
            3. **Brief proof sketches** as `-- !-- comment -- !--` blocks (1-2 sentences each)
            4. **A FUTURE_DIRECTIONS.md file** listing 3-5 testable, falsifiable
               conjectures as a freeform narrative (NOT a form). Each direction MUST
               include a "The key insight is..." sentence and a "Why now?" justification.
               This file drives the next research cycle — make it count.

            ### DO NOT OUTPUT (Phase B handles these — if your work passes quality bar):
            - NO `ARTICLE.md`
            - NO `RESEARCH_PAPER.md`
            - NO `demo.py` / `algorithms.py`
            - NO HTML widgets
            - NO `PACKAGE.json`
            - NO prose for human readers (except FUTURE_DIRECTIONS.md)

            ### WHY THIS NARROW:
            The Lean 4 file IS the deliverable. A self-contained Lean file with
            3-5 world-class theorems is worth more than 30K characters of prose
            about trivial results. Focus 100% of your compute on the math.
            If your work is genuinely world-class, the packaging step is dispatched
            automatically and cheaply.

            ### CATALOG SYNTHESIS (required — read the catalog context below):
            The Catalog Context and Recent Discoveries sections list existing theorems
            already proven in this project. You MUST analyze these and combine concepts
            from the catalog with the research direction above. Specifically:

            1. **Identify relevant catalog theorems** — Which existing results connect
               to your research direction? Cite them by name in your proof sketches.
            2. **Build on catalog foundations** — Your theorems should EXTEND or
               GENERALIZE catalog results, not reprove them from scratch. Use `import`
               and reference existing definitions and lemmas where possible.
            3. **Combine concepts across domains** — The most valuable theorems connect
               ideas from different catalog domains (e.g., applying algebraic structures
               to topological problems, or using combinatorial arguments in number theory).
               Look for cross-domain connections in the catalog context.
            4. **Avoid duplication** — Check the catalog context before proving. If a
               similar result already exists, extend it rather than reproving it.


## Concept

**Title**: The new file `Catalog/MachineLearning/PerturbedGeneralization.lean` bridges the
**Domain**: MachineLearning
**Mathematical framing**: # Future Directions: Perturbation-Stable Generalization Bounds

The new file `Catalog/MachineLearning/PerturbedGeneralization.lean` bridges the
catalog's two previously disconnected machine-learning strands: the
compression/Occam bound (`MachineLearning.CompressionGeneralization`:
`occamBound`, `occam_sample_complexity`, `overparam_invariance`) and the
architecture-perturbation theory (`MachineLearning.Generalization`:
`archDistReal`, `archDistReal_triangle`). The pivot is that `occamBound` is an
*isometry in its empirical-risk coordinate* (`occamBound_dist_eq`), so risk
stability transfers verbatim to guarantee stability
(`arch_perturbed_bound`, `perturbed_sample_complexity`). The following
conjectures push that bridge further.

## 1. Two-sided isometry collapse for ensembles

**Conjecture.** For an ensemble of `m` models with identical complexity `C` and
empirical risks `R₁,…,Rₘ`, the certified bound of the *risk-averaged* model
equals the average of the certified bounds plus a single shared penalty; i.e.
`occamBound (avg R) C n δ = avg (fun i => occamBound (Rᵢ) C n δ)`.

The key insight is that since the penalty term is constant in `R`, the bound map
is affine, and affine maps commute with convex averaging exactly — there is no
Jensen gap, unlike for genuinely nonlinear capacity measures.

**Why now?** `occamBound_gap_indep_empRisk` already isolates the penalty as
`R`-independent; the averaging identity is one `Finset.sum` manipulation away and
would give the first *exact* (not merely upper-bounded) ensemble generalization
identity in the catalog.

## 2. Lipschitz-budget triangle inequality across architecture chains

**Conjecture.** If empirical risk is `L`-Lipschitz in `archDistReal`, then along
a chain `a → b → c` the certified-bound shift is subadditive:
`occamBound (emp c) C n δ ≤ occamBound (emp a) C n δ + L·(archDistReal a b + archDistReal b c)`.

The key insight is that the catalog's `archDistReal_triangle` plus the isometry
`occamBound_perturb_le` compose, so the metric structure on architectures is
inherited *with the same Lipschitz constant* by the space of certified
guarantees.

**Why now?** `arch_perturbed_bound` already handles a single edit; chaining it
through `archDistReal_triangle` (already proven in the catalog) turns the bound
into a genuine pseudmetric morphism, enabling multi-step neural-architecture
search with cumulative certified stability.

## 3. Tightness / necessity of the perturbation budget

**Conjecture.** The `+η` term in `perturbed_sample_complexity` is tight: there
exists an `L`-Lipschitz risk functional and architectures `a, b` with
`L·archDistReal a b = η` for which `occamBound (emp b) C n δ = emp a + ε + η`,
so no smaller perturbation slack is valid in general.

The key insight is that the isometry property forces the worst case to be
achieved by a risk functional that saturates the Lipschitz inequality linearly,
making the bound an equality rather than a strict inequality.

**Why now?** The forward bound is proven; the matching lower bound only needs a
single explicit `emp := fun x => L * archDistReal a x` witness, turning an
inequality into a sharp characterization and ruling out spurious improvements.

## 4. Confidence-budget exchange (δ ↔ ε ↔ η trade-off surface)

**Conjecture.** Fixing the certified target `emp a + τ`, the admissible region
of `(δ, ε, η, n)` satisfying `perturbed_sample_complexity` forms a downward-closed
set whose Pareto frontier is described by
`ε + η = τ` and `n = (C + log(1/δ))/(2ε²)`, giving an explicit exchange rate
`dn/dη = (C + log(1/δ))/(τ − η)³` between perturbation tolerance and data.

The key insight is that because the penalty enters only through `ε` and the
perturbation only through `η`, the two budgets are *separable*, so the trade-off
surface factorizes into a data term and a robustness term with no cross-coupling.

**Why now?** All ingredients (`penalty_le_of_sample`, `perturbed_sample_complexity`)
are formalized; differentiating the closed-form inversion is elementary calculus
already supported in Mathlib, and it would yield the first quantitative
data-vs-robustness exchange theorem in the catalog.

## 5. PAC-Bayes lift of the isometry

**Conjecture.** Replacing the point hypothesis by a posterior `Q` and the
complexity `C` by the KL divergence `KL(Q‖P)`, the resulting PAC-Bayes Occam
bound remains an isometry in the *expected* empirical risk `𝔼_{h∼Q}[R(h)]`, so
`perturbed_sample_complexity` lifts verbatim with `archDistReal` replaced by a
Wasserstein distance between posteriors.

The key insight is that the empirical-risk coordinate enters the PAC-Bayes bound
linearly through an expectation, and expectation preserves the affine-translation
structure that powers the entire isometry argument.

**Why now?** The catalog already contains PAC-Bayes scaffolding
(`MachineLearning.Catoni`); composing it with the isometry lemmas here is the
natural next step and would unify compression, perturbation, and PAC-Bayes
generalization under a single Lipschitz-transfer principle.

**Concept description**: # Future Directions: Perturbation-Stable Generalization Bounds

The new file `Catalog/MachineLearning/PerturbedGeneralization.lean` bridges the
catalog's two previously disconnected machine-learning strands: the
compression/Occam bound (`MachineLearning.CompressionGeneralization`:
`occamBound`, `occam_sample_complexity`, `overparam_invariance`) and the
architecture-perturbation theory (`MachineLearning.Generalization`:
`archDistReal`, `archDistReal_triangle`). The pivot is that `occamBound` is an
*isometry in its empirical-risk coordinate* (`occamBound_dist_eq`), so risk
stability transfers verbatim to guarantee stability
(`arch_perturbed_bound`, `perturbed_sample_complexity`). The following
conjectures push that bridge further.

## 1. Two-sided isometry collapse for ensembles

**Conjecture.** For an ensemble of `m` models with identical complexity `C` and
empirical risks `R₁,…,Rₘ`, the certified bound of the *risk-averaged* model
equals the average of the certified bounds plus a single shared penalty; i.e.
`occamBound (avg R) C n δ = avg (fun i => occamBound (Rᵢ) C n δ)`.

The key insight is that since the penalty term is constant in `R`, the bound map
is affine, and affine maps commute with convex averaging exactly — there is no
Jensen gap, unlike for genuinely nonlinear capacity measures.

**Why now?** `occamBound_gap_indep_empRisk` already isolates the penalty as
`R`-independent; the averaging identity is one `Finset.sum` manipulation away and
would give the first *exact* (not merely upper-bounded) ensemble generalization
identity in the catalog.

## 2. Lipschitz-budget triangle inequality across architecture chains

**Conjecture.** If empirical risk is `L`-Lipschitz in `archDistReal`, then along
a chain `a → b → c` the certified-bound shift is subadditive:
`occamBound (emp c) C n δ ≤ occamBound (emp a) C n δ + L·(archDistReal a b + archDistReal b c)`.

The key insight is that the catalog's `archDistReal_triangle` plus the isometry
`occamBound_perturb_le` compose, so the metric structure on architectures is
inherited *with the same Lipschitz constant* by the space of certified
guarantees.

**Why now?** `arch_perturbed_bound` already handles a single edit; chaining it
through `archDistReal_triangle` (already proven in the catalog) turns the bound
into a genuine pseudmetric morphism, enabling multi-step neural-architecture
search with cumulative certified stability.

## 3. Tightness / necessity of the perturbation budget

**Conjecture.** The `+η` term in `perturbed_sample_complexity` is tight: there
exists an `L`-Lipschitz risk functional and architectures `a, b` with
`L·archDistReal a b = η` for which `occamBound (emp b) C n δ = emp a + ε + η`,
so no smaller perturbation slack is valid in general.

The key insight is that the isometry property forces the worst case to be
achieved by a risk functional that saturates the Lipschitz inequality linearly,
making the bound an equality rather than a strict inequality.

**Why now?** The forward bound is proven; the matching lower bound only needs a
single explicit `emp := fun x => L * archDistReal a x` witness, turning an
inequality into a sharp characterization and ruling out spurious improvements.

## 4. Confidence-budget exchange (δ ↔ ε ↔ η trade-off surface)

**Conjecture.** Fixing the certified target `emp a + τ`, the admissible region
of `(δ, ε, η, n)` satisfying `perturbed_sample_complexity` forms a downward-closed
set whose Pareto frontier is described by
`ε + η = τ` and `n = (C + log(1/δ))/(2ε²)`, giving an explicit exchange rate
`dn/dη = (C + log(1/δ))/(τ − η)³` between perturbation tolerance and data.

The key insight is that because the penalty enters only through `ε` and the
perturbation only through `η`, the two budgets are *separable*, so the trade-off
surface factorizes into a data term and a robustness term with no cross-coupling.

**Why now?** All ingredients (`penalty_le_of_sample`, `perturbed_sample_complexity`)
are formalized; differentiating the closed-form inversion is elementary calculus
already supported in Mathlib, and it would yield the first quantitative
data-vs-robustness exchange theorem in the catalog.

## 5. PAC-Bayes lift of the isometry

**Conjecture.** Replacing the point hypothesis by a posterior `Q` and the
complexity `C` by the KL divergence `KL(Q‖P)`, the resulting PAC-Bayes Occam
bound remains an isometry in the *expected* empirical risk `𝔼_{h∼Q}[R(h)]`, so
`perturbed_sample_complexity` lifts verbatim with `archDistReal` replaced by a
Wasserstein distance between posteriors.

The key insight is that the empirical-risk coordinate enters the PAC-Bayes bound
linearly through an expectation, and expectation preserves the affine-translation
structure that powers the entire isometry argument.

**Why now?** The catalog already contains PAC-Bayes scaffolding
(`MachineLearning.Catoni`); composing it with the isometry lemmas here is the
natural next step and would unify compression, perturbation, and PAC-Bayes
generalization under a single Lipschitz-transfer principle.

**Novelty estimate**: 0.75
**Breakthrough potential**: 0.75
Research domain: MachineLearning
Research mode: team




### Recent Discoveries in Catalog
No previous research cycles completed yet. This is a cold start — prioritize sorry_fill on the priority targets (CarmichaelComposite, Fib_gcd_identity) to close known open problems, or target cross-domain bridge theorems for novelty.


## v6 Depth Requirements — Correct Proofs First

You are working on the frontier of mathematics. Your goal is to produce
Lean 4 code that COMPILES and PROVES non-trivial results. A correct proof
of one good theorem is worth more than 5 theorems with `sorry`.

### STEP 1: BRIEF PLAN (2-3 lines)

Before writing Lean code, state:
- **Strategy**: New structure (Grothendieck) OR extend existing result (Cauchy)
- **Theorems**: List the 2-4 theorems you will prove (one sentence each)
- **Why non-trivial**: One sentence explaining the key insight

### STEP 2: PROVE THEOREMS (correctness > completeness)

Write Lean 4 proofs that COMPILE. Every theorem should have:
- A complete proof (no `sorry` for the main result)
- A brief proof sketch as a comment (1-2 sentences)
- An `example` block showing the theorem in action (if practical)

For your BEST theorem, also provide:
- A generalization or strengthening (can use `sorry` if proving it would take too long)
- A boundary case or counterexample showing where the result fails

You do NOT need full PEGB on every theorem. Deep PEGB on your best theorem
and solid proofs on the rest is the target.

### STEP 3: Anti-patterns (avoid these)

These tactics indicate trivial proofs that add no value:
- `native_decide` / `decide` / `norm_num` / `rfl` — unless genuinely proving a numeric fact
- `simp only []` with no simp set specified
- `sorry` on the main theorem statement

`omega`, `linarith`, and `Aesop` are fine for supporting lemmas.
`sorry` is fine for generalizations and boundary cases.

### STEP 4: Novelty

Your theorems should be genuinely new. If a statement appears in a textbook,
generalize it. If you cannot formalize a concept rigorously, pick a different topic.

### Output format

Your output must include `.lean` files AND a `FUTURE_DIRECTIONS.md` file.
The .lean files contain the proofs. The FUTURE_DIRECTIONS.md contains 3-5
research conjectures that extend the work. Both are required.


## Output format reminder

Your output must include `.lean` files AND a `FUTURE_DIRECTIONS.md` file.
The .lean files contain the proofs. The FUTURE_DIRECTIONS.md contains 3-5
research conjectures that extend the work. Both are required.
Be precise, be deep, be world-class.
