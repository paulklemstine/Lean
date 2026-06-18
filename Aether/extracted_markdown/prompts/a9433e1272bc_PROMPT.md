
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

**Title**: First rigorous, machine-checked skeleton of the
**Domain**: Applications
**Mathematical framing**: # FUTURE_DIRECTIONS — Biological Topology: Protein Folding as Persistent-Homology Optimization

## Synthesis

This cycle built the first rigorous, machine-checked skeleton of the
"folding-as-topological-optimization" program. Working in `Barcode.lean`, we
modelled a persistence barcode as a finite list of birth/death intervals
`(bᵢ, dᵢ)` and isolated the single functional the whole program rests on —
**total persistence** `T(B) = ∑ᵢ (dᵢ - bᵢ)` — then proved its core algebraic and
analytic structure. The key structural insight that emerged is that total
persistence behaves like a genuine *physical energy*: it is **extensive**
(`totalPersistence_append`: additive over disjoint feature sets), **bounded below
by a ground state** (`totalPersistence_nonneg` together with
`totalPersistence_eq_zero_iff`, which pins the minimum value `0` to *exactly* the
featureless/degenerate barcodes), **homogeneous of degree 1** under metric
rescaling (`totalPersistence_scale`, so the optimizer is unit-independent), and
**Lipschitz-stable** under coordinate noise (`totalPersistence_stability`, the
discrete L¹ stability of diagrams). Existence of an optimizer over a finite
discretized conformation space is then immediate (`nativeFold_exists`), which is
the well-posedness half of Levinthal's paradox.

The most important *negative* result is `nativeFold_not_unique`: the Critic's
explicit counterexample showing that a symmetric energy admits **distinct global
minimizers**. This is decisive for the original concept text, which claimed a
"provably unique minimum." That claim is false as stated; what is canonical is
the minimal *energy value*, not the minimizing *configuration*. Any honest
formalization of the folding conjecture must therefore quantify over energy, or
quotient configurations by symmetry, before uniqueness can even be posed.

Structurally, the cycle revealed that the entire program decouples into two
independent layers: (1) a *combinatorial/analytic* layer about the barcode
functional itself (everything proved here, requiring no homology), and (2) a
*geometric* layer that actually computes the barcode from a point cloud
(Vietoris–Rips / minimum spanning tree), which we deliberately deferred. The
clean separation means future cycles can attack layer (2) — the genuinely hard
topology — while reusing layer (1) verbatim as a black-box energy calculus.

## Results Summary

- `totalPersistence_append`: **proved** — total persistence is additive over barcode concatenation, making it an extensive energy.
- `totalPersistence_nonneg`: **proved** — valid barcodes have nonnegative total persistence (energy bounded below by the ground state).
- `totalPersistence_eq_zero_iff`: **proved** — total persistence is zero iff every bar is degenerate; the global minimum value is attained exactly by featureless barcodes.
- `totalPersistence_scale`: **proved** — total persistence is homogeneous of degree 1 under metric rescaling, so the optimal fold is independent of distance units.
- `totalPersistence_stability`: **proved** — discrete L¹ stability: matched perturbations of births/deaths change the energy by at most the total coordinate perturbation (robustness to noise).
- `nativeFold_exists`: **proved** — over any finite nonempty configuration space a global energy minimizer ("native fold") exists; the well-posedness resolution of Levinthal's paradox.
- `nativeFold_not_unique`: **disproved (uniqueness)** — explicit counterexample with two distinct global minimizers; refutes the "provably unique minimum" form of the conjecture.

## Research Directions

### Direction 1: Total persistence equals minimum-spanning-tree weight in degree 0
**Hypothesis**: For a finite metric space, the degree-0 Vietoris–Rips total
persistence (excluding the single infinite bar) equals the total edge weight of
a minimum spanning tree of the complete distance graph. Formally, define
`H0Barcode (d : Fin n → Fin n → ℝ)` from the filtration of connected components
and prove `totalPersistence (H0Barcode d) = mstWeight d`.
**The key insight is** that 0-dimensional persistence is not abstract homology at
all — it is exactly the greedy single-linkage clustering whose merge heights are
the MST edge weights, so the topological energy reduces to a classical
combinatorial optimum that Mathlib's order/graph theory can reach.
**Test**: Prove the identity for `n ≤ 4` by `decide`/explicit enumeration first,
then prove the general statement by induction following Kruskal's algorithm.
**Why now**: This cycle already proved the entire barcode-side calculus
(additivity, nonnegativity, the ground-state characterization); the only missing
piece is the *constructor* `H0Barcode`, so the hard analytic lemmas are done.
**If true**: Total persistence in degree 0 becomes *computable and minimizable in
polynomial time*, giving the first provably tractable instance of the folding
energy and a concrete bridge to `Catalog`'s combinatorial results.
**If false**: The discrepancy would localize exactly which filtration convention
(open vs. closed balls, ties in distances) breaks the clustering picture.

### Direction 2: Strict monotonicity — every genuine feature strictly raises the energy
**Hypothesis**: If `B'` is obtained from a valid barcode `B` by extending one
bar's death (`d_i ↦ d_i + ε`, `ε > 0`), then `totalPersistence B < totalPersistence B'`,
and more generally total persistence is strictly monotone under the bar-wise
partial order.
**The key insight is** that `totalPersistence_eq_zero_iff` already shows the
minimum is *isolated at the boundary*; promoting this to a strict-monotonicity
theorem turns "the fold minimizes persistence" from a non-strict into a strict
variational principle, which is what uniqueness-up-to-symmetry needs.
**Test**: Prove `totalPersistence_lt_of_le_of_exists_lt` from `totalPersistence_append`
plus a single strict summand, then derive the one-bar corollary.
**Why now**: Additivity and nonnegativity (both proved this cycle) are precisely
the lemmas a strict-monotonicity argument decomposes into.
**If true**: Gives a clean "no wasted topology" principle — the native fold has
no removable features — and is the missing ingredient for a symmetry-quotiented
uniqueness theorem.
**If false**: Would reveal degenerate directions in barcode space along which the
energy is flat, sharpening the `nativeFold_not_unique` phenomenon.

### Direction 3: Bottleneck vs. L¹ stability — which metric controls folding robustness?
**Hypothesis**: The L¹ stability constant proved here
(`totalPersistence_stability`) is *not* improvable to the bottleneck (L∞) metric:
there exist barcode pairs with arbitrarily small bottleneck distance but total
persistence gap bounded below by a constant times the number of bars.
**The key insight is** that the classical Cohen-Steiner–Edelsbrunner stability
theorem controls *bottleneck* distance, whereas total persistence is an L¹
quantity; this cycle's matched-perturbation bound is L¹-tight, so the two
notions must diverge, and quantifying the divergence tells us which experimental
errors actually threaten a fold prediction.
**Test**: Construct a family `B_n, B'_n` (many bars each perturbed by `1/n`) and
prove `bottleneck B_n B'_n → 0` while `|T(B_n) - T(B'_n)| ≥ c`.
**Why now**: We have an exact L¹ bound to compare against; the counterexample is a
finite list construction in the same idiom as `nativeFold_not_unique`.
**If true**: Establishes that total persistence is the *fragile* invariant and
suggests folding-energy predictors should report bottleneck-stable summaries
instead.
**If false**: Total persistence would inherit bottleneck stability, making it a
strictly better-behaved energy than currently believed.

### Direction 4: Weighted / p-total persistence and a Hölder stability hierarchy
**Hypothesis**: For `p ≥ 1` define `T_p(B) = (∑ᵢ (dᵢ - bᵢ)^p)^{1/p}`. Then `T_p`
is monotone decreasing in `p`, satisfies `T_p ≤ T_1`, and admits an L^p matched
stability bound generalizing `totalPersistence_stability` (the `p = 1` case).
**The key insight is** that the proof of `totalPersistence_stability` only used
the triangle inequality bar-by-bar; replacing it with Minkowski's inequality
should lift the whole argument to every `p`, yielding a one-parameter family of
folding energies whose `p → ∞` limit is the single longest bar (the dominant
topological feature).
**Test**: Prove `T_p` monotonicity via `Finset`/`List` power-mean inequalities in
Mathlib, then port the stability induction using `abs_rpow` and Minkowski.
**Why now**: The `p = 1` theorems are complete and modular; the generalization is
a controlled stress test of exactly which steps are `p`-specific.
**If true**: Provides a tunable energy interpolating between "all features
matter" (`p=1`) and "only the deepest feature matters" (`p=∞`), matching the
biological intuition that one hydrophobic-core loop dominates the fold.
**If false**: Pinpoints the `p` at which convexity fails, bounding the usable
range of weighted persistence energies.

### Direction 5: Symmetry-quotient uniqueness — recovering the conjecture's intent
**Hypothesis**: Although `nativeFold_not_unique` refutes naive uniqueness, the
minimizer *is* unique modulo the symmetry group acting on configurations: if two
configurations both minimize total persistence and have equal barcodes, they lie
in one orbit of rigid motions / relabelings.
**The key insight is** that this cycle separated "minimal energy" (canonical)
from "minimizing configuration" (non-canonical); the right object is the
quotient, and the counterexample shows the quotient is unavoidable rather than a
bug.
**Test**: Formalize a group action `G ↷ Config` with `bar (g • x) = bar x`, then
state and attempt `∀ x y, IsMin x → IsMin y → bar x = bar y → ∃ g, y = g • x`
(left as a `conjecture` with `sorry`).
**Why now**: We have a precise, proved statement of non-uniqueness to react to,
and the energy's degree-1 homogeneity (`totalPersistence_scale`) already shows it
is invariant under the most basic symmetry (global scaling).
**If true**: Restores a rigorous, defensible version of the AlphaFold-motivated
claim that contact-map topology *determines* the fold.
**If false**: Would exhibit genuinely topologically-identical but
geometrically-distinct folds — a striking statement about the limits of
contact-map-based structure prediction.

**Concept description**: # FUTURE_DIRECTIONS — Biological Topology: Protein Folding as Persistent-Homology Optimization

## Synthesis

This cycle built the first rigorous, machine-checked skeleton of the
"folding-as-topological-optimization" program. Working in `Barcode.lean`, we
modelled a persistence barcode as a finite list of birth/death intervals
`(bᵢ, dᵢ)` and isolated the single functional the whole program rests on —
**total persistence** `T(B) = ∑ᵢ (dᵢ - bᵢ)` — then proved its core algebraic and
analytic structure. The key structural insight that emerged is that total
persistence behaves like a genuine *physical energy*: it is **extensive**
(`totalPersistence_append`: additive over disjoint feature sets), **bounded below
by a ground state** (`totalPersistence_nonneg` together with
`totalPersistence_eq_zero_iff`, which pins the minimum value `0` to *exactly* the
featureless/degenerate barcodes), **homogeneous of degree 1** under metric
rescaling (`totalPersistence_scale`, so the optimizer is unit-independent), and
**Lipschitz-stable** under coordinate noise (`totalPersistence_stability`, the
discrete L¹ stability of diagrams). Existence of an optimizer over a finite
discretized conformation space is then immediate (`nativeFold_exists`), which is
the well-posedness half of Levinthal's paradox.

The most important *negative* result is `nativeFold_not_unique`: the Critic's
explicit counterexample showing that a symmetric energy admits **distinct global
minimizers**. This is decisive for the original concept text, which claimed a
"provably unique minimum." That claim is false as stated; what is canonical is
the minimal *energy value*, not the minimizing *configuration*. Any honest
formalization of the folding conjecture must therefore quantify over energy, or
quotient configurations by symmetry, before uniqueness can even be posed.

Structurally, the cycle revealed that the entire program decouples into two
independent layers: (1) a *combinatorial/analytic* layer about the barcode
functional itself (everything proved here, requiring no homology), and (2) a
*geometric* layer that actually computes the barcode from a point cloud
(Vietoris–Rips / minimum spanning tree), which we deliberately deferred. The
clean separation means future cycles can attack layer (2) — the genuinely hard
topology — while reusing layer (1) verbatim as a black-box energy calculus.

## Results Summary

- `totalPersistence_append`: **proved** — total persistence is additive over barcode concatenation, making it an extensive energy.
- `totalPersistence_nonneg`: **proved** — valid barcodes have nonnegative total persistence (energy bounded below by the ground state).
- `totalPersistence_eq_zero_iff`: **proved** — total persistence is zero iff every bar is degenerate; the global minimum value is attained exactly by featureless barcodes.
- `totalPersistence_scale`: **proved** — total persistence is homogeneous of degree 1 under metric rescaling, so the optimal fold is independent of distance units.
- `totalPersistence_stability`: **proved** — discrete L¹ stability: matched perturbations of births/deaths change the energy by at most the total coordinate perturbation (robustness to noise).
- `nativeFold_exists`: **proved** — over any finite nonempty configuration space a global energy minimizer ("native fold") exists; the well-posedness resolution of Levinthal's paradox.
- `nativeFold_not_unique`: **disproved (uniqueness)** — explicit counterexample with two distinct global minimizers; refutes the "provably unique minimum" form of the conjecture.

## Research Directions

### Direction 1: Total persistence equals minimum-spanning-tree weight in degree 0
**Hypothesis**: For a finite metric space, the degree-0 Vietoris–Rips total
persistence (excluding the single infinite bar) equals the total edge weight of
a minimum spanning tree of the complete distance graph. Formally, define
`H0Barcode (d : Fin n → Fin n → ℝ)` from the filtration of connected components
and prove `totalPersistence (H0Barcode d) = mstWeight d`.
**The key insight is** that 0-dimensional persistence is not abstract homology at
all — it is exactly the greedy single-linkage clustering whose merge heights are
the MST edge weights, so the topological energy reduces to a classical
combinatorial optimum that Mathlib's order/graph theory can reach.
**Test**: Prove the identity for `n ≤ 4` by `decide`/explicit enumeration first,
then prove the general statement by induction following Kruskal's algorithm.
**Why now**: This cycle already proved the entire barcode-side calculus
(additivity, nonnegativity, the ground-state characterization); the only missing
piece is the *constructor* `H0Barcode`, so the hard analytic lemmas are done.
**If true**: Total persistence in degree 0 becomes *computable and minimizable in
polynomial time*, giving the first provably tractable instance of the folding
energy and a concrete bridge to `Catalog`'s combinatorial results.
**If false**: The discrepancy would localize exactly which filtration convention
(open vs. closed balls, ties in distances) breaks the clustering picture.

### Direction 2: Strict monotonicity — every genuine feature strictly raises the energy
**Hypothesis**: If `B'` is obtained from a valid barcode `B` by extending one
bar's death (`d_i ↦ d_i + ε`, `ε > 0`), then `totalPersistence B < totalPersistence B'`,
and more generally total persistence is strictly monotone under the bar-wise
partial order.
**The key insight is** that `totalPersistence_eq_zero_iff` already shows the
minimum is *isolated at the boundary*; promoting this to a strict-monotonicity
theorem turns "the fold minimizes persistence" from a non-strict into a strict
variational principle, which is what uniqueness-up-to-symmetry needs.
**Test**: Prove `totalPersistence_lt_of_le_of_exists_lt` from `totalPersistence_append`
plus a single strict summand, then derive the one-bar corollary.
**Why now**: Additivity and nonnegativity (both proved this cycle) are precisely
the lemmas a strict-monotonicity argument decomposes into.
**If true**: Gives a clean "no wasted topology" principle — the native fold has
no removable features — and is the missing ingredient for a symmetry-quotiented
uniqueness theorem.
**If false**: Would reveal degenerate directions in barcode space along which the
energy is flat, sharpening the `nativeFold_not_unique` phenomenon.

### Direction 3: Bottleneck vs. L¹ stability — which metric controls folding robustness?
**Hypothesis**: The L¹ stability constant proved here
(`totalPersistence_stability`) is *not* improvable to the bottleneck (L∞) metric:
there exist barcode pairs with arbitrarily small bottleneck distance but total
persistence gap bounded below by a constant times the number of bars.
**The key insight is** that the classical Cohen-Steiner–Edelsbrunner stability
theorem controls *bottleneck* distance, whereas total persistence is an L¹
quantity; this cycle's matched-perturbation bound is L¹-tight, so the two
notions must diverge, and quantifying the divergence tells us which experimental
errors actually threaten a fold prediction.
**Test**: Construct a family `B_n, B'_n` (many bars each perturbed by `1/n`) and
prove `bottleneck B_n B'_n → 0` while `|T(B_n) - T(B'_n)| ≥ c`.
**Why now**: We have an exact L¹ bound to compare against; the counterexample is a
finite list construction in the same idiom as `nativeFold_not_unique`.
**If true**: Establishes that total persistence is the *fragile* invariant and
suggests folding-energy predictors should report bottleneck-stable summaries
instead.
**If false**: Total persistence would inherit bottleneck stability, making it a
strictly better-behaved energy than currently believed.

### Direction 4: Weighted / p-total persistence and a Hölder stability hierarchy
**Hypothesis**: For `p ≥ 1` define `T_p(B) = (∑ᵢ (dᵢ - bᵢ)^p)^{1/p}`. Then `T_p`
is monotone decreasing in `p`, satisfies `T_p ≤ T_1`, and admits an L^p matched
stability bound generalizing `totalPersistence_stability` (the `p = 1` case).
**The key insight is** that the proof of `totalPersistence_stability` only used
the triangle inequality bar-by-bar; replacing it with Minkowski's inequality
should lift the whole argument to every `p`, yielding a one-parameter family of
folding energies whose `p → ∞` limit is the single longest bar (the dominant
topological feature).
**Test**: Prove `T_p` monotonicity via `Finset`/`List` power-mean inequalities in
Mathlib, then port the stability induction using `abs_rpow` and Minkowski.
**Why now**: The `p = 1` theorems are complete and modular; the generalization is
a controlled stress test of exactly which steps are `p`-specific.
**If true**: Provides a tunable energy interpolating between "all features
matter" (`p=1`) and "only the deepest feature matters" (`p=∞`), matching the
biological intuition that one hydrophobic-core loop dominates the fold.
**If false**: Pinpoints the `p` at which convexity fails, bounding the usable
range of weighted persistence energies.

### Direction 5: Symmetry-quotient uniqueness — recovering the conjecture's intent
**Hypothesis**: Although `nativeFold_not_unique` refutes naive uniqueness, the
minimizer *is* unique modulo the symmetry group acting on configurations: if two
configurations both minimize total persistence and have equal barcodes, they lie
in one orbit of rigid motions / relabelings.
**The key insight is** that this cycle separated "minimal energy" (canonical)
from "minimizing configuration" (non-canonical); the right object is the
quotient, and the counterexample shows the quotient is unavoidable rather than a
bug.
**Test**: Formalize a group action `G ↷ Config` with `bar (g • x) = bar x`, then
state and attempt `∀ x y, IsMin x → IsMin y → bar x = bar y → ∃ g, y = g • x`
(left as a `conjecture` with `sorry`).
**Why now**: We have a precise, proved statement of non-uniqueness to react to,
and the energy's degree-1 homogeneity (`totalPersistence_scale`) already shows it
is invariant under the most basic symmetry (global scaling).
**If true**: Restores a rigorous, defensible version of the AlphaFold-motivated
claim that contact-map topology *determines* the fold.
**If false**: Would exhibit genuinely topologically-identical but
geometrically-distinct folds — a striking statement about the limits of
contact-map-based structure prediction.

**Novelty estimate**: 0.75
**Breakthrough potential**: 0.75
Research domain: Applications
Research mode: team




### Recent Discoveries in Catalog
No previous research cycles completed yet. This is a cold start — prioritize sorry_fill on the priority targets (CarmichaelComposite, Fib_gcd_identity) to close known open problems, or target cross-domain bridge theorems for novelty.


## v7 Depth Requirements — Structured Proofs with Completeness Gates

You are producing Lean 4 code on the mathematical frontier. Your output must
be COMPILABLE and your proofs must be COMPLETE. A single correct proof of a
non-trivial result is worth more than 5 theorems with `sorry`.

### STEP 1: THEOREM DECLARATIONS (required — before any code)

List every theorem you intend to prove. For each, state:
- **Name**: The Lean declaration name
- **Statement**: One-sentence informal statement
- **Status**: `proved` | `conjecture` | `proved_with_lemma_sorry`
- **Why non-trivial**: One sentence on the key mathematical insight

Example:
1. `cantorPairing_surjective`: Cantor pairing is surjective — proved — constructive inverse
2. `cantorPairing_injective`: Cantor pairing is injective — proved — diagonal argument
3. `cantorPairing_bijection`: Cantor pairing is a bijection — proved_with_lemma_sorry — follows from 1+2

### STEP 2: PROVE THEOREMS (completeness gate)

Every theorem declared as `proved` MUST have a complete, compiling Lean proof.
No `sorry` on the main result. If you cannot complete a proof, change its status
to `conjecture` or `proved_with_lemma_sorry` and explain why.

For `proved_with_lemma_sorry`:
- The theorem statement must be complete (no sorry in the statement)
- `sorry` is allowed ONLY in supporting lemmas, never the main proof
- A comment must explain what the sorry replaces and why it's deferred

For your BEST theorem, also provide:
- A generalization or strengthening (can use sorry if proving would take too long)
- A boundary case or counterexample showing where the result fails

### STEP 3: Anti-patterns (reject these)

These tactics indicate trivial proofs:
- `native_decide` / `decide` / `norm_num` / `rfl` — unless genuinely proving a numeric fact
- `simp only []` with no simp set specified
- `sorry` on any theorem declared as `proved`

`omega`, `linarith`, and `Aesop` are fine for supporting lemmas.
`sorry` is fine for conjectures and generalizations.

### STEP 4: Novelty

Your theorems must be genuinely new. If a statement appears in a textbook,
generalize it. If you cannot formalize a concept rigorously, pick a different topic.

### Output format

Your output must include:
1. `.lean` files with the proofs (structured as declared in Step 1)
2. `FUTURE_DIRECTIONS.md` with 3-5 research conjectures extending the work

Both are required. Missing FUTURE_DIRECTIONS.md = automatic quality penalty.


## Output format reminder

Your output must include `.lean` files AND a `FUTURE_DIRECTIONS.md` file.
The .lean files contain the proofs. The FUTURE_DIRECTIONS.md contains 3-5
research conjectures that extend the work. Both are required.
Be precise, be deep, be world-class.
