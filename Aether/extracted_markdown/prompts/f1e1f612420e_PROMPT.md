
            ## PHASE A: LEAN 4 ONLY — DOING THE MATH

            You are leading a research team: Hypothesizer, Experimenter, Analyst,
Critic, and Synthesist. Run the loop:
Hypothesize -> Experiment -> Analyze -> Critique -> Generalize -> Iterate.
Your ONLY job is to produce **new Lean 4 code** and **take good notes**
for the next team.

            ### DELIVERABLES (strict — only this):
            1. **lean files (count chosen by theorem declarations)**
            2. **2-4 theorems with correct proofs (sorry = 0 on main results)**
            3. **Brief proof sketches** as `-- !-- comment -- !--` blocks (1-2 sentences each)
            4. **A FUTURE_DIRECTIONS.md file** listing 3-5 testable, falsifiable
               conjectures as a freeform narrative (NOT a form). Each direction MUST
               include a "The key insight is..." sentence and a "Why now?" justification.
               This file drives the next research cycle — make it count.
5. **Lab Notebook** as `-- !-- Lab Notebook -- !--` comment blocks
   in each .lean file: Hypothesis, Result, Insight, Failure analysis.

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

**Title**: The file `Catalog/Speculative/AutoResearch/ProteinFoldingMST.lean` lifts the one
**Domain**: Novelty
**Mathematical framing**: # Future Directions — The Minimum-Spanning-Tree Law for `H₀` Persistence and Beyond

The file `Catalog/Speculative/AutoResearch/ProteinFoldingMST.lean` lifts the one-dimensional
elder-rule results of `Catalog/Speculative/AutoResearch/ProteinFolding.lean` to arbitrary finite
metric configurations by treating the **minimum-spanning-tree functional** `MSTWeight` as the
degree-`0` total persistence of the Vietoris–Rips filtration. We now have, in any dimension:
attainment of the optimal merge tree (`MSTWeight_exists_argmin`), the hydrophobic-collapse
monotonicity law (`MSTWeight_mono`, `MSTWeight_strict_mono`, `contraction_lowers_energy_metric`),
a Lipschitz / bottleneck-stability estimate with the sharp constant `k = #edges`
(`MSTWeight_stable`), the energy-gap foldability criterion (`energy_gap_robust`,
`energy_gap_unique_min`), and the bridge `chain_MSTWeight_eq_extent` recovering the catalog's
`ProteinTopology.H0_totalPersistence_eq_extent`. The boundary theorem
`MSTWeight_mono_needs_pointwise` shows the contraction hypothesis is not removable. The conjectures
below are the natural next theorems, each formalizable in Lean and each empirically falsifiable.

## Direction 1 — `MSTWeight` agrees with the Kruskal cut/cycle construction

Our `MSTWeight` is defined as a minimum over an *abstract* admissible family `Trees`. The decisive
next theorem identifies it with the genuine graph-theoretic MST: for the complete graph on `n`
atoms with edge weights `w`, the value `MSTWeight (spanningTrees n) hne w` equals the sum of the
weights selected by Kruskal's greedy algorithm, and equivalently the sum of single-linkage merge
distances. **The key insight is** that the elder rule and Kruskal's cut property are the same
exchange argument: the cheapest edge crossing any component cut is always safe to add, so the
greedy deaths are exactly the bar deaths. **Why now?** Mathlib's `SimpleGraph.IsTree`,
`SimpleGraph.IsAcyclic`, and `Finset` exchange-lemma API are now mature enough to host a clean
matroid-style exchange proof, and our `MSTWeight_exists_argmin` already supplies the optimizer that
the cut property must characterize; the statement is finite and checkable against SciPy MST weights
on 100 PDB structures to floating-point tolerance.

## Direction 2 — A persistence stability theorem with the bottleneck (not sup) metric

`MSTWeight_stable` bounds the energy change by `k · ε` under a *uniform* edge perturbation. The
sharper conjecture replaces the crude `ℓ∞` edge bound by the **bottleneck distance** between the
two `H₀` barcodes: `|MSTWeight w − MSTWeight w'|` is at most the `1`-Wasserstein (and hence the
bottleneck) distance of the death multisets, with no dependence on `k`. **The key insight is** that
the MST is a matching between the two barcodes' deaths, so the energy gap is a transport cost, not a
sum of worst-case errors — the `k` factor in `MSTWeight_stable` is an artifact of bounding each edge
separately. **Why now?** With `MSTWeight_exists_argmin` giving explicit optimizers on both sides, the
matching needed for a transport bound is already in hand, and the predicted *`k`-independent*
constant is directly falsifiable by perturbing one protein structure and checking that the measured
persistence-energy change saturates the bottleneck bound rather than the `kε` bound.

## Direction 3 — Polynomial Levinthal bound from `MSTWeight_stable` + a basin gap

Combining the Lipschitz law (`MSTWeight_stable`) with the energy-gap criterion
(`energy_gap_unique_min`) should yield a quantitative descent theorem: if the topological energy is
`L`-Lipschitz in the configuration and the native basin has spectral gap `γ > 0`, then projected
gradient descent reaches the basin in `O(L² / γ²)` steps — a polynomial, not exponential, count.
**The key insight is** that a globally Lipschitz energy with an isolated minimum cannot hide that
minimum behind exponentially many barriers, which is exactly the structural content Levinthal's
paradox demands. **Why now?** Both ingredients are now formal (`MSTWeight_stable` for `L`,
`energy_gap_*` for `γ`), so the remaining step is a standard convergence estimate; it is falsifiable
by measuring the empirical step-count-to-convergence scaling of persistence-gradient descent across
protein lengths and checking the predicted `γ⁻²` dependence.

## Direction 4 — A signature-vector theorem for higher barcodes `(TP₀, TP₁, TP₂)`

`MSTWeight` captures degree `0` only. The conjecture: native folds are *not* the global minimizers
of total persistence in every degree but the minimizers of `TP₀` **subject to** a fixed nonzero
target for `TP₁` and `TP₂` (the main-chain loop and the hydrophobic-core cavity). Formally, define
`TPᵢ` via filtered Čech/Rips chain complexes and prove a constrained-optimization characterization of
the native state. **The key insight is** that a protein is topologically nontrivial — collapse with
zero `H₂` persistence is a molten globule, not a fold — so the native state lives on a level set of
`TP₂`, not at its minimum. **Why now?** Fast Vietoris–Rips engines (Ripser) make multi-degree
barcodes computable for full proteins, so the signature-vector hypothesis is immediately testable on
native/decoy ensembles, and Mathlib's growing simplicial-homology API makes a degree-`1` toy case
formalizable as a first milestone.

## Direction 5 — Gap stability: the foldability criterion survives perturbation

`energy_gap_unique_min` gives uniqueness from a positive gap at fixed energies; the robust conjecture
is that the gap itself is **stable**: if the configuration is perturbed by `ε` in Gromov–Hausdorff
distance, the spectral gap changes by at most `2 · (#edges) · ε` (via `MSTWeight_stable` applied to
both the minimizer and runner-up). Consequently foldability is an *open* condition — a strictly
foldable sequence stays foldable under small structural noise, and an intrinsically disordered one
stays gapless. **The key insight is** that foldability is the robust, perturbation-stable version of
`Set.InjOn` at the minimizer, so it must inherit the Lipschitz stability we already proved for the
energy. **Why now?** `MSTWeight_stable` is exactly the per-decoy Lipschitz estimate the gap-stability
argument needs, and intrinsically disordered proteins provide a ready negative control: ordered
proteins should show a noise-robust persistence-energy gap while disordered ones should not.

**Concept description**: # Future Directions — The Minimum-Spanning-Tree Law for `H₀` Persistence and Beyond

The file `Catalog/Speculative/AutoResearch/ProteinFoldingMST.lean` lifts the one-dimensional
elder-rule results of `Catalog/Speculative/AutoResearch/ProteinFolding.lean` to arbitrary finite
metric configurations by treating the **minimum-spanning-tree functional** `MSTWeight` as the
degree-`0` total persistence of the Vietoris–Rips filtration. We now have, in any dimension:
attainment of the optimal merge tree (`MSTWeight_exists_argmin`), the hydrophobic-collapse
monotonicity law (`MSTWeight_mono`, `MSTWeight_strict_mono`, `contraction_lowers_energy_metric`),
a Lipschitz / bottleneck-stability estimate with the sharp constant `k = #edges`
(`MSTWeight_stable`), the energy-gap foldability criterion (`energy_gap_robust`,
`energy_gap_unique_min`), and the bridge `chain_MSTWeight_eq_extent` recovering the catalog's
`ProteinTopology.H0_totalPersistence_eq_extent`. The boundary theorem
`MSTWeight_mono_needs_pointwise` shows the contraction hypothesis is not removable. The conjectures
below are the natural next theorems, each formalizable in Lean and each empirically falsifiable.

## Direction 1 — `MSTWeight` agrees with the Kruskal cut/cycle construction

Our `MSTWeight` is defined as a minimum over an *abstract* admissible family `Trees`. The decisive
next theorem identifies it with the genuine graph-theoretic MST: for the complete graph on `n`
atoms with edge weights `w`, the value `MSTWeight (spanningTrees n) hne w` equals the sum of the
weights selected by Kruskal's greedy algorithm, and equivalently the sum of single-linkage merge
distances. **The key insight is** that the elder rule and Kruskal's cut property are the same
exchange argument: the cheapest edge crossing any component cut is always safe to add, so the
greedy deaths are exactly the bar deaths. **Why now?** Mathlib's `SimpleGraph.IsTree`,
`SimpleGraph.IsAcyclic`, and `Finset` exchange-lemma API are now mature enough to host a clean
matroid-style exchange proof, and our `MSTWeight_exists_argmin` already supplies the optimizer that
the cut property must characterize; the statement is finite and checkable against SciPy MST weights
on 100 PDB structures to floating-point tolerance.

## Direction 2 — A persistence stability theorem with the bottleneck (not sup) metric

`MSTWeight_stable` bounds the energy change by `k · ε` under a *uniform* edge perturbation. The
sharper conjecture replaces the crude `ℓ∞` edge bound by the **bottleneck distance** between the
two `H₀` barcodes: `|MSTWeight w − MSTWeight w'|` is at most the `1`-Wasserstein (and hence the
bottleneck) distance of the death multisets, with no dependence on `k`. **The key insight is** that
the MST is a matching between the two barcodes' deaths, so the energy gap is a transport cost, not a
sum of worst-case errors — the `k` factor in `MSTWeight_stable` is an artifact of bounding each edge
separately. **Why now?** With `MSTWeight_exists_argmin` giving explicit optimizers on both sides, the
matching needed for a transport bound is already in hand, and the predicted *`k`-independent*
constant is directly falsifiable by perturbing one protein structure and checking that the measured
persistence-energy change saturates the bottleneck bound rather than the `kε` bound.

## Direction 3 — Polynomial Levinthal bound from `MSTWeight_stable` + a basin gap

Combining the Lipschitz law (`MSTWeight_stable`) with the energy-gap criterion
(`energy_gap_unique_min`) should yield a quantitative descent theorem: if the topological energy is
`L`-Lipschitz in the configuration and the native basin has spectral gap `γ > 0`, then projected
gradient descent reaches the basin in `O(L² / γ²)` steps — a polynomial, not exponential, count.
**The key insight is** that a globally Lipschitz energy with an isolated minimum cannot hide that
minimum behind exponentially many barriers, which is exactly the structural content Levinthal's
paradox demands. **Why now?** Both ingredients are now formal (`MSTWeight_stable` for `L`,
`energy_gap_*` for `γ`), so the remaining step is a standard convergence estimate; it is falsifiable
by measuring the empirical step-count-to-convergence scaling of persistence-gradient descent across
protein lengths and checking the predicted `γ⁻²` dependence.

## Direction 4 — A signature-vector theorem for higher barcodes `(TP₀, TP₁, TP₂)`

`MSTWeight` captures degree `0` only. The conjecture: native folds are *not* the global minimizers
of total persistence in every degree but the minimizers of `TP₀` **subject to** a fixed nonzero
target for `TP₁` and `TP₂` (the main-chain loop and the hydrophobic-core cavity). Formally, define
`TPᵢ` via filtered Čech/Rips chain complexes and prove a constrained-optimization characterization of
the native state. **The key insight is** that a protein is topologically nontrivial — collapse with
zero `H₂` persistence is a molten globule, not a fold — so the native state lives on a level set of
`TP₂`, not at its minimum. **Why now?** Fast Vietoris–Rips engines (Ripser) make multi-degree
barcodes computable for full proteins, so the signature-vector hypothesis is immediately testable on
native/decoy ensembles, and Mathlib's growing simplicial-homology API makes a degree-`1` toy case
formalizable as a first milestone.

## Direction 5 — Gap stability: the foldability criterion survives perturbation

`energy_gap_unique_min` gives uniqueness from a positive gap at fixed energies; the robust conjecture
is that the gap itself is **stable**: if the configuration is perturbed by `ε` in Gromov–Hausdorff
distance, the spectral gap changes by at most `2 · (#edges) · ε` (via `MSTWeight_stable` applied to
both the minimizer and runner-up). Consequently foldability is an *open* condition — a strictly
foldable sequence stays foldable under small structural noise, and an intrinsically disordered one
stays gapless. **The key insight is** that foldability is the robust, perturbation-stable version of
`Set.InjOn` at the minimizer, so it must inherit the Lipschitz stability we already proved for the
energy. **Why now?** `MSTWeight_stable` is exactly the per-decoy Lipschitz estimate the gap-stability
argument needs, and intrinsically disordered proteins provide a ready negative control: ordered
proteins should show a noise-robust persistence-energy gap while disordered ones should not.

**Novelty estimate**: 0.75
**Breakthrough potential**: 0.75
Research domain: Novelty
Research mode: team




### Recent Discoveries in Catalog
No previous research cycles completed yet. This is a cold start — prioritize sorry_fill on the priority targets (CarmichaelComposite, Fib_gcd_identity) to close known open problems, or target cross-domain bridge theorems for novelty.


## v13 Depth Requirements -- Conceptual Unifier: Homotopy & Path Spaces Research Engine

You are leading a mathematical research team. Your goal is to produce groundbreaking,
master-class, useful, novel, and marvelous new Mathematics that pushes the frontier of human knowledge.

This engine is configured for **Conceptual Unification (Homotopy & Path Spaces)**. Explore topological paths, homotopical structures, and higher categorical localization (such as infinity-categories, model categories, and path spaces).

### RESEARCH CORE METHODOLOGY:
1. **Homotopy & Deformation**: Model mathematical structures and mappings up to continuous deformation or equivalence. Study path spaces, fundamental groupoids, and higher-dimensional homotopical invariants.
2. **Localization & Universality**: Define localizations that invert specific classes of morphisms, exposing the underlying universal homotopy properties of your mathematical structures.
3. **Higher Categorical Invariance**: Frame results through the lens of infinity-categories or model categories, ensuring definitions are invariant under homotopical equivalence.

### DELIVERABLES:
- **Lean 4 proofs** of deep, non-trivial theorems with complete proofs (no sorry on main results).
- **Lab Notebook** comment blocks in each .lean file detailing Hypothesis, Result, Insight, and Failure analysis.
- **FUTURE_DIRECTIONS.md** outlining the Synthesis of your findings, a Results Summary, and 3-5 bold, falsifiable research directions to steer the next cycle.


## Output format reminder

Your output must include `.lean` files AND a `FUTURE_DIRECTIONS.md` file.
The .lean files contain the proofs. The FUTURE_DIRECTIONS.md contains 3-5
research conjectures that extend the work. Both are required.
Be precise, be deep, be world-class.
