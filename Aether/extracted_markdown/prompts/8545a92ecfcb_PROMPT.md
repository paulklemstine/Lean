
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

**Title**: The file `TropicalModuliDimension.lean` formalises the **numerical backbone** of
**Domain**: Novelty
**Mathematical framing**: # Future Directions — Tropical Moduli Spaces and the Tropical Torelli Map

## Synthesis

The file `TropicalModuliDimension.lean` formalises the **numerical backbone** of the
tropical moduli space of curves `M_g^trop`.  A combinatorial type — a connected
stable weighted graph with edge lengths forgotten — is encoded as a `StableType`
carrying its invariants `(vert0, vertPos, edges, weight, genus)` together with three
linear structural relations: the *genus formula* `g + v = e + 1 + W`, the *stability*
inequality `3v ≤ 2W + 2e` (stability summed against the handshake lemma), and
*connectedness* `v ≤ e + 1`.  From this encoding the classical dimension theory of
Brannetti–Melo–Viviani / Caporaso falls out as linear arithmetic, and the
top-dimensional cones are realised by *honest* 3-regular `SimpleGraph`s through
Mathlib's `sum_degrees_eq_twice_card_edges`.

The governing discovery is that, once the handshake lemma is applied, the entire
dimension theory of `M_g^trop` is **linear over the integers**: every headline result
is `omega` after the geometry is recorded additively (so no truncated `ℕ`-subtraction
ever appears).

## Results Summary

* `StableType.vertex_bound` — `v ≤ 2g − 2`.
* `StableType.edge_bound` — `e ≤ 3g − 3` (the dimension of `M_g^trop`).
* `StableType.jacobianDim_eq` / `jacobianDim_nonneg` — the tropical Jacobian has
  dimension `b₁ = g − W ≥ 0`; the tropical Torelli map factors through it.
* `StableType.weight_le_genus`, `StableType.tree_genus_zero` — the genus-`0` picture
  (`b₁ = 0` ⇔ weight-`0` tree) as a degenerate stratum.
* `stableTypes_finite` — for fixed `g`, only finitely many types: the fan is finite.
* `trivalent_dimension` — every finite 3-regular simple graph satisfies
  `|V| = 2b₁ − 2`, `|E| = 3b₁ − 3`; with `topType g` / `topType_edge_bound_sharp`
  showing the edge bound is sharp for every `g ≥ 2`.

All main results are `sorry`-free and depend only on `propext`, `Classical.choice`,
`Quot.sound`.

## Bold, Falsifiable Research Directions

### 1. A genuine `Fintype` of isomorphism classes of genus-`g` stable graphs
`stableTypes_finite` bounds only the invariant vector `(vert0, vertPos, edges, weight)`.
Upgrade this to a `Fintype` instance on isomorphism classes of realising weighted
`SimpleGraph`s of genus `g`, quotienting by `SimpleGraph.Iso`.  **The key insight is**
that `vertex_bound` and `edge_bound` confine every type to graphs on the fixed finite
vertex set `Fin (2g − 2)` with at most `3g − 3` edges, so the classes inject into the
finite power set of edges — finiteness is purely combinatorial, no analysis needed.
*Why now?* The arithmetic skeleton is proved and axiom-clean, so only the bookkeeping
of attaching a realising graph remains, and Mathlib's `SimpleGraph`/`Fintype` API
supports it directly.

### 2. The tropical Jacobian as a positive-semidefinite quadratic form
Replace the scalar `jacobianDim` by the edge-length quadratic form
`Q_G(γ) = Σ_e ℓ(e)·γ(e)²` on the cycle lattice `ℤ^{b₁}`.  Conjecture: `Q_G` is always
PSD, and positive definite exactly when all `ℓ(e) > 0`, so the Torelli image lands in
the PSD cone `A_g^trop`.  **The key insight is** that `Q_G` is a `Finset.sum` of
non-negative terms, so PSD-ness is a `positivity`-style argument rather than spectral
theory, with `jacobianDim_eq` already pinning the rank to `b₁`.  *Why now?* The exact
rank target `b₁ = g − W` is in hand, so pairing it with an explicit sum-of-squares
closes the "factors through the Jacobian" half of the Torelli statement.

### 3. Edge contraction and the pure `(3g − 3)`-dimensional face poset
Define edge contraction `StableType → StableType` (length `→ 0`): it drops `edges` by
one and either merges two vertices or shifts a `vert0` into `vertPos`.  Conjecture:
contraction preserves genus exactly and makes `M_g^trop` a *pure* `(3g − 3)`-dimensional
generalized cone complex, with `topType g` at the top.  **The key insight is** that
contraction preserves the additive genus identity `g + v = e + 1 + W` term-by-term, so
genus-preservation is a structural `omega` fact definable directly on `StableType`.
*Why now?* The genus invariant is already a field equation `omega` tracks, so the
contraction map and its invariance can be defined and verified mechanically — the first
formal handle on the boundary stratification.

### 4. Finiteness of Torelli fibers via the cographic matroid
The Caporaso–Viviani theorem says the tropical Torelli map has finite fibers governed
by the *cographic matroid* of the graph.  Formalizable form: two `StableType`s with the
same Jacobian form share a cographic matroid, and only finitely many graphs share a
matroid.  **The key insight is** that the matroid depends only on the finite edge set,
so "same matroid ⇒ finite fiber" is `stableTypes_finite` intersected with a decidable
matroid-equality predicate — a finite-to-finite refinement, not a new compactness
argument.  *Why now?* `stableTypes_finite` supplies the ambient finiteness and Mathlib's
`Matroid` library makes the cographic matroid expressible, turning fiber-finiteness into
a concrete filtering of an existing finite set.

### 5. `M_g^trop` as a contractible metric realisation of the Berkovich skeleton
Equip each cone `σ_G = ℝ_{≥0}^{E(G)}` with the tropical `ℓ^∞` metric, glue along
contractions (Direction 3), and prove the resulting metric space is contractible and of
pure dimension `3g − 3` — the metric shadow of "`M_g^trop` is the Berkovich skeleton of
`M_g`".  **The key insight is** that contractibility comes from the tropical *scaling
homotopy* `ℓ ↦ t·ℓ` toward the cone apex, i.e. max-plus homogeneity, which composes the
dimension formula `edge_bound` with a one-parameter rescaling.  *Why now?* The dimension
formula and the rescaling are both elementary and in reach of Mathlib's topology library,
turning a deep algebraic-geometry statement into a metric-geometry gluing problem.

**Concept description**: # Future Directions — Tropical Moduli Spaces and the Tropical Torelli Map

## Synthesis

The file `TropicalModuliDimension.lean` formalises the **numerical backbone** of the
tropical moduli space of curves `M_g^trop`.  A combinatorial type — a connected
stable weighted graph with edge lengths forgotten — is encoded as a `StableType`
carrying its invariants `(vert0, vertPos, edges, weight, genus)` together with three
linear structural relations: the *genus formula* `g + v = e + 1 + W`, the *stability*
inequality `3v ≤ 2W + 2e` (stability summed against the handshake lemma), and
*connectedness* `v ≤ e + 1`.  From this encoding the classical dimension theory of
Brannetti–Melo–Viviani / Caporaso falls out as linear arithmetic, and the
top-dimensional cones are realised by *honest* 3-regular `SimpleGraph`s through
Mathlib's `sum_degrees_eq_twice_card_edges`.

The governing discovery is that, once the handshake lemma is applied, the entire
dimension theory of `M_g^trop` is **linear over the integers**: every headline result
is `omega` after the geometry is recorded additively (so no truncated `ℕ`-subtraction
ever appears).

## Results Summary

* `StableType.vertex_bound` — `v ≤ 2g − 2`.
* `StableType.edge_bound` — `e ≤ 3g − 3` (the dimension of `M_g^trop`).
* `StableType.jacobianDim_eq` / `jacobianDim_nonneg` — the tropical Jacobian has
  dimension `b₁ = g − W ≥ 0`; the tropical Torelli map factors through it.
* `StableType.weight_le_genus`, `StableType.tree_genus_zero` — the genus-`0` picture
  (`b₁ = 0` ⇔ weight-`0` tree) as a degenerate stratum.
* `stableTypes_finite` — for fixed `g`, only finitely many types: the fan is finite.
* `trivalent_dimension` — every finite 3-regular simple graph satisfies
  `|V| = 2b₁ − 2`, `|E| = 3b₁ − 3`; with `topType g` / `topType_edge_bound_sharp`
  showing the edge bound is sharp for every `g ≥ 2`.

All main results are `sorry`-free and depend only on `propext`, `Classical.choice`,
`Quot.sound`.

## Bold, Falsifiable Research Directions

### 1. A genuine `Fintype` of isomorphism classes of genus-`g` stable graphs
`stableTypes_finite` bounds only the invariant vector `(vert0, vertPos, edges, weight)`.
Upgrade this to a `Fintype` instance on isomorphism classes of realising weighted
`SimpleGraph`s of genus `g`, quotienting by `SimpleGraph.Iso`.  **The key insight is**
that `vertex_bound` and `edge_bound` confine every type to graphs on the fixed finite
vertex set `Fin (2g − 2)` with at most `3g − 3` edges, so the classes inject into the
finite power set of edges — finiteness is purely combinatorial, no analysis needed.
*Why now?* The arithmetic skeleton is proved and axiom-clean, so only the bookkeeping
of attaching a realising graph remains, and Mathlib's `SimpleGraph`/`Fintype` API
supports it directly.

### 2. The tropical Jacobian as a positive-semidefinite quadratic form
Replace the scalar `jacobianDim` by the edge-length quadratic form
`Q_G(γ) = Σ_e ℓ(e)·γ(e)²` on the cycle lattice `ℤ^{b₁}`.  Conjecture: `Q_G` is always
PSD, and positive definite exactly when all `ℓ(e) > 0`, so the Torelli image lands in
the PSD cone `A_g^trop`.  **The key insight is** that `Q_G` is a `Finset.sum` of
non-negative terms, so PSD-ness is a `positivity`-style argument rather than spectral
theory, with `jacobianDim_eq` already pinning the rank to `b₁`.  *Why now?* The exact
rank target `b₁ = g − W` is in hand, so pairing it with an explicit sum-of-squares
closes the "factors through the Jacobian" half of the Torelli statement.

### 3. Edge contraction and the pure `(3g − 3)`-dimensional face poset
Define edge contraction `StableType → StableType` (length `→ 0`): it drops `edges` by
one and either merges two vertices or shifts a `vert0` into `vertPos`.  Conjecture:
contraction preserves genus exactly and makes `M_g^trop` a *pure* `(3g − 3)`-dimensional
generalized cone complex, with `topType g` at the top.  **The key insight is** that
contraction preserves the additive genus identity `g + v = e + 1 + W` term-by-term, so
genus-preservation is a structural `omega` fact definable directly on `StableType`.
*Why now?* The genus invariant is already a field equation `omega` tracks, so the
contraction map and its invariance can be defined and verified mechanically — the first
formal handle on the boundary stratification.

### 4. Finiteness of Torelli fibers via the cographic matroid
The Caporaso–Viviani theorem says the tropical Torelli map has finite fibers governed
by the *cographic matroid* of the graph.  Formalizable form: two `StableType`s with the
same Jacobian form share a cographic matroid, and only finitely many graphs share a
matroid.  **The key insight is** that the matroid depends only on the finite edge set,
so "same matroid ⇒ finite fiber" is `stableTypes_finite` intersected with a decidable
matroid-equality predicate — a finite-to-finite refinement, not a new compactness
argument.  *Why now?* `stableTypes_finite` supplies the ambient finiteness and Mathlib's
`Matroid` library makes the cographic matroid expressible, turning fiber-finiteness into
a concrete filtering of an existing finite set.

### 5. `M_g^trop` as a contractible metric realisation of the Berkovich skeleton
Equip each cone `σ_G = ℝ_{≥0}^{E(G)}` with the tropical `ℓ^∞` metric, glue along
contractions (Direction 3), and prove the resulting metric space is contractible and of
pure dimension `3g − 3` — the metric shadow of "`M_g^trop` is the Berkovich skeleton of
`M_g`".  **The key insight is** that contractibility comes from the tropical *scaling
homotopy* `ℓ ↦ t·ℓ` toward the cone apex, i.e. max-plus homogeneity, which composes the
dimension formula `edge_bound` with a one-parameter rescaling.  *Why now?* The dimension
formula and the rescaling are both elementary and in reach of Mathlib's topology library,
turning a deep algebraic-geometry statement into a metric-geometry gluing problem.

**Novelty estimate**: 0.75
**Breakthrough potential**: 0.75
Research domain: Novelty
Research mode: team




### Recent Discoveries in Catalog
No previous research cycles completed yet. This is a cold start — prioritize sorry_fill on the priority targets (CarmichaelComposite, Fib_gcd_identity) to close known open problems, or target cross-domain bridge theorems for novelty.


## v11 Depth Requirements -- Algorithmic & Constructive Research Engine

You are leading a mathematical research team. Your goal is to produce groundbreaking,
master-class, useful, novel, and marvelous new Mathematics that pushes the frontier of human knowledge.

This engine is configured for **Algorithmic & Constructive Generation**. Prioritize concrete computation, explicit witness constructions, and algorithmic content.

### RESEARCH CORE METHODOLOGY:
1. **Constructive Witness Extraction**: Whenever asserting that an object exists, focus on constructing it explicitly. Avoid non-constructive classical axioms (like double negation elimination or classical choice) unless absolutely necessary.
2. **Computational Verification**: Build definitions that can be computationally evaluated (`#eval` or `decide`). Connect abstract algebra/topology directly to effective algorithms and discrete models.
3. **Algorithmic Complexity**: Focus on the computational power and structures of your mathematical objects, proving properties about their stability, convergence, or decidability.

### DELIVERABLES:
- **Lean 4 proofs** of deep, non-trivial theorems with complete proofs (no sorry on main results).
- **Lab Notebook** comment blocks in each .lean file detailing Hypothesis, Result, Insight, and Failure analysis.
- **FUTURE_DIRECTIONS.md** outlining the Synthesis of your findings, a Results Summary, and 3-5 bold, falsifiable research directions to steer the next cycle.


## Output format reminder

Your output must include `.lean` files AND a `FUTURE_DIRECTIONS.md` file.
The .lean files contain the proofs. The FUTURE_DIRECTIONS.md contains 3-5
research conjectures that extend the work. Both are required.
Be precise, be deep, be world-class.
