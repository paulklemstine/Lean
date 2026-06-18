
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

**Title**: This cycle promoted the *Hodge–Betti dimension count* of `HodgeBettiRank.lean` f
**Domain**: Novelty
**Mathematical framing**: # Future Directions — Hodge–Laplacian Message Passing, Fourth Cycle

## Synthesis

This cycle promoted the *Hodge–Betti dimension count* of `HodgeBettiRank.lean` from a numerical
equality to two genuinely structural theorems, completing the local-to-global core of the
spectral-depth / full-Hodge-decomposition program at the operator level.

* **`HodgeThreeWayDecomposition.lean` — the strong (three-way) Hodge decomposition
  (Research Direction 2).** For a two-step cochain complex `U --e--> V --d--> W` with the chain
  condition `d ∘ e = 0`, the middle cochain space splits as a triple **orthogonal direct sum**
  `V = range d* ⊕ range e ⊕ ker Δ` (coexact ⊕ exact ⊕ harmonic). The three summands are pairwise
  orthogonal (`range_e_le_orthogonal_range_adjoint_d`, `harmonic_le_orthogonal_range_e`,
  `harmonic_le_orthogonal_range_adjoint_d`), they jointly span `V` (`hodge_three_way_span`), and
  their dimensions add to `dim V` (`hodge_three_way_finrank`). The structural engine is the Hodge
  split of the *closed* space `range e ⊔ ker Δ = ker d` (`closed_eq_exact_sup_harmonic`), built
  from the relative orthogonal complement law and the coexact identity `(ker d)ᗮ = range d*`
  (`orthogonal_ker_d_eq_range_adjoint_d`).

* **`HodgeIsomorphism.lean` — the Hodge isomorphism `harmonic ≅ cohomology`
  (Research Direction 1).** The Hodge–Betti *equidimensionality* `dim (ker Δ) = dim ker d − rank e`
  is upgraded to a canonical **linear isomorphism** `(ker d / range e) ≃ₗ ker Δ`
  (`hodgeCohomologyEquiv`): every cohomology class contains *exactly one* harmonic representative.
  This is split into existence (`harmonic_representative_exists`: every closed cochain is exact plus
  harmonic) and uniqueness (`harmonic_representative_unique`, from `harmonic_inf_exact_eq_bot`:
  harmonic ∩ exact `= 0`). The two combine, inside the ambient module `↥(ker d)`, into the
  complementarity `hodge_isCompl`, which `Submodule.quotientEquivOfIsCompl` turns into the explicit
  equivalence.

The unifying picture is now sharp: message passing is a deformation retraction onto the harmonic
core; the harmonic core *is* the cohomology — not merely equidimensional with it, but canonically
isomorphic — and the cochain space splits orthogonally into exact, coexact, and harmonic channels.

## Results summary

| Theorem | File | Statement |
|---|---|---|
| `orthogonal_ker_d_eq_range_adjoint_d` | ThreeWay | `(ker d)ᗮ = range d*` |
| `closed_eq_exact_sup_harmonic` | ThreeWay | `range e ⊔ ker Δ = ker d` |
| `hodge_three_way_span` | ThreeWay | `range d* ⊔ range e ⊔ ker Δ = ⊤` |
| `hodge_three_way_finrank` | ThreeWay | `dim range d* + dim range e + dim ker Δ = dim V` |
| `harmonic_inf_exact_eq_bot` | Isomorphism | `ker Δ ⊓ range e = ⊥` |
| `harmonic_representative_exists` | Isomorphism | every closed cochain `= e u + h`, `h` harmonic |
| `harmonic_representative_unique` | Isomorphism | one harmonic representative per class |
| `hodge_isCompl` | Isomorphism | `range e`, `ker Δ` complementary inside `ker d` |
| `hodgeCohomologyEquiv` | Isomorphism | **Hodge isomorphism** `(ker d / range e) ≃ₗ ker Δ` |

All proofs depend only on `propext`, `Classical.choice`, `Quot.sound`.

## Research directions

### 1. The Hodge isomorphism is an isometry for the quotient norm
`hodgeCohomologyEquiv` is currently a *linear* equivalence `(ker d / range e) ≃ₗ ker Δ`. Conjecture:
it is in fact an **isometry**, i.e. the harmonic representative is the unique minimal-norm element of
its cohomology class, and `‖[x]‖ = ‖P x‖` where `P` is the orthogonal projection onto `ker Δ`.
Falsifiable: any closed cochain whose harmonic part has strictly larger norm than some other class
representative would refute it. **The key insight is** that `harmonic_representative_exists` writes
`x = e u + h` with `h ⊥ e u` (because `harmonic_le_orthogonal_range_e` gives `h ⊥ range e`), so
Pythagoras yields `‖x‖² = ‖e u‖² + ‖h‖² ≥ ‖h‖²` with equality iff `e u = 0`; hence the harmonic
representative is the norm-minimizer and the class norm equals `‖h‖`. **Why now?** Both halves are
theorems already: `harmonic_inf_exact_eq_bot` for uniqueness of the minimizer and
`harmonic_le_orthogonal_range_e` for the orthogonality that powers Pythagoras, so only the quotient
`Submodule.norm_mk`/`norm_quotient` comparison remains.

### 2. The harmonic projector as an idempotent on the cochain space
The three-way split `hodge_three_way_span` + `hodge_three_way_finrank` makes `ker Δ` an orthogonal
direct summand of `V`. Conjecture: the orthogonal projection `P : V →ₗ V` onto `ker Δ` satisfies
`P ∘ P = P`, `range P = ker Δ`, `ker P = range d* ⊔ range e`, and `P` commutes with `Δ`
(`P ∘ Δ = Δ ∘ P = 0`). Falsifiable by exhibiting a cochain `x` with `P (P x) ≠ P x` or
`P (Δ x) ≠ 0`. **The key insight is** that `closed_eq_exact_sup_harmonic` together with
`harmonic_le_orthogonal_range_e` identifies `ker Δ` as the orthogonal complement of
`range d* ⊔ range e` inside `V`, so `P = Submodule.orthogonalProjection (ker Δ)` and the idempotency
plus kernel description follow from `Submodule.orthogonalProjection` API on the proven decomposition.
**Why now?** `hodge_three_way_span` gives the spanning and `harmonic_le_orthogonal_range_adjoint_d`
/ `harmonic_le_orthogonal_range_e` give that the complement is exactly the other two summands, so the
projector is pinned down with no new geometry.

### 3. Euler characteristic as a telescoping alternating sum of harmonic dimensions
For a finite cochain complex `0 → V₀ → V₁ → … → Vₙ → 0`, conjecture the discrete **Hodge–Euler
theorem**: `Σ (−1)ᵏ dim(ker Δₖ) = Σ (−1)ᵏ dim Vₖ`, identifying the analytic Euler characteristic
(alternating sum of Betti numbers) with the combinatorial one. Falsifiable by any finite complex whose
harmonic Euler sum differs from its space Euler sum. **The key insight is** that the per-degree
identity `dim(ker Δₖ) = dim ker dₖ − rank eₖ` (a direct corollary of `hodge_betti`) combined with
rank–nullity `rank dₖ + dim ker dₖ = dim Vₖ` makes the consecutive `rank` terms cancel in pairs once
summed with alternating signs (the boundary identification `eₖ = dₖ₊₁` shares each rank between two
degrees). **Why now?** `hodge_betti` supplies every per-degree input, so the global statement is a
finite alternating-sum induction over `Finset.range n` using only `Module.finrank` arithmetic already
in Mathlib — no further analysis.

### 4. Message passing converges to the harmonic projector at the spectral-gap rate
Conjecture: for an admissible step `0 < α < 2/λ_max` the iterate `(id − αΔ)^[k]` converges to the
projector `P` of Direction 2, with `‖(id − αΔ)^[k] x − P x‖ ≤ ρᵏ ‖x − P x‖` for
`ρ = max|1 − αλ|` over nonzero Hodge eigenvalues `λ`. Falsifiable by a complex with an eigenvalue
outside `(0, 2/α)` that fails to contract. **The key insight is** that the three-way decomposition
(Direction 2) makes `ker Δ` and its complement simultaneously `Δ`-invariant; on the harmonic block
`Δ = 0` so the iterate is fixed, while on the complement the self-adjoint `Δ` (it is symmetric by the
`hodgeLap_quadform` energy split) has strictly positive eigenvalues, giving geometric contraction
with the stated `ρ`. **Why now?** With `P` available from Direction 2 and the finite-dimensional
spectral theorem for the symmetric `Δ`, the limit assembles from `id = P + (id − P)`, and the tight
logarithmic clock `hodgeDepth_tight` (previous cycle) already pins the exact rate.

### 5. Functoriality: chain maps induce maps on harmonic spaces
Conjecture: a morphism of two-step complexes (a commuting ladder of linear maps between
`U --e--> V --d--> W` and `U' --e'--> V' --d'--> W'`) induces a well-defined linear map on harmonic
spaces `ker Δ → ker Δ'` that agrees, under `hodgeCohomologyEquiv`, with the induced map on cohomology.
Falsifiable by a chain map whose harmonic-space map fails to commute with the cohomology map through
the isomorphism. **The key insight is** that `hodgeCohomologyEquiv` is *canonical* (built from
orthogonal complementation, not a choice of basis), so naturality reduces to checking that the middle
map sends closed cochains to closed cochains and exact to exact — exactly the two squares of the
ladder — after which `Submodule.mapQ` provides the induced cohomology map and the equivalence
transports it. **Why now?** The isomorphism is now a concrete `LinearEquiv` rather than a dimension
count, so `LinearMap.mapQ`/`Submodule.mapQ` can be composed with it directly, making functoriality a
diagram chase over already-proven complementarity rather than a fresh construction.

**Concept description**: # Future Directions — Hodge–Laplacian Message Passing, Fourth Cycle

## Synthesis

This cycle promoted the *Hodge–Betti dimension count* of `HodgeBettiRank.lean` from a numerical
equality to two genuinely structural theorems, completing the local-to-global core of the
spectral-depth / full-Hodge-decomposition program at the operator level.

* **`HodgeThreeWayDecomposition.lean` — the strong (three-way) Hodge decomposition
  (Research Direction 2).** For a two-step cochain complex `U --e--> V --d--> W` with the chain
  condition `d ∘ e = 0`, the middle cochain space splits as a triple **orthogonal direct sum**
  `V = range d* ⊕ range e ⊕ ker Δ` (coexact ⊕ exact ⊕ harmonic). The three summands are pairwise
  orthogonal (`range_e_le_orthogonal_range_adjoint_d`, `harmonic_le_orthogonal_range_e`,
  `harmonic_le_orthogonal_range_adjoint_d`), they jointly span `V` (`hodge_three_way_span`), and
  their dimensions add to `dim V` (`hodge_three_way_finrank`). The structural engine is the Hodge
  split of the *closed* space `range e ⊔ ker Δ = ker d` (`closed_eq_exact_sup_harmonic`), built
  from the relative orthogonal complement law and the coexact identity `(ker d)ᗮ = range d*`
  (`orthogonal_ker_d_eq_range_adjoint_d`).

* **`HodgeIsomorphism.lean` — the Hodge isomorphism `harmonic ≅ cohomology`
  (Research Direction 1).** The Hodge–Betti *equidimensionality* `dim (ker Δ) = dim ker d − rank e`
  is upgraded to a canonical **linear isomorphism** `(ker d / range e) ≃ₗ ker Δ`
  (`hodgeCohomologyEquiv`): every cohomology class contains *exactly one* harmonic representative.
  This is split into existence (`harmonic_representative_exists`: every closed cochain is exact plus
  harmonic) and uniqueness (`harmonic_representative_unique`, from `harmonic_inf_exact_eq_bot`:
  harmonic ∩ exact `= 0`). The two combine, inside the ambient module `↥(ker d)`, into the
  complementarity `hodge_isCompl`, which `Submodule.quotientEquivOfIsCompl` turns into the explicit
  equivalence.

The unifying picture is now sharp: message passing is a deformation retraction onto the harmonic
core; the harmonic core *is* the cohomology — not merely equidimensional with it, but canonically
isomorphic — and the cochain space splits orthogonally into exact, coexact, and harmonic channels.

## Results summary

| Theorem | File | Statement |
|---|---|---|
| `orthogonal_ker_d_eq_range_adjoint_d` | ThreeWay | `(ker d)ᗮ = range d*` |
| `closed_eq_exact_sup_harmonic` | ThreeWay | `range e ⊔ ker Δ = ker d` |
| `hodge_three_way_span` | ThreeWay | `range d* ⊔ range e ⊔ ker Δ = ⊤` |
| `hodge_three_way_finrank` | ThreeWay | `dim range d* + dim range e + dim ker Δ = dim V` |
| `harmonic_inf_exact_eq_bot` | Isomorphism | `ker Δ ⊓ range e = ⊥` |
| `harmonic_representative_exists` | Isomorphism | every closed cochain `= e u + h`, `h` harmonic |
| `harmonic_representative_unique` | Isomorphism | one harmonic representative per class |
| `hodge_isCompl` | Isomorphism | `range e`, `ker Δ` complementary inside `ker d` |
| `hodgeCohomologyEquiv` | Isomorphism | **Hodge isomorphism** `(ker d / range e) ≃ₗ ker Δ` |

All proofs depend only on `propext`, `Classical.choice`, `Quot.sound`.

## Research directions

### 1. The Hodge isomorphism is an isometry for the quotient norm
`hodgeCohomologyEquiv` is currently a *linear* equivalence `(ker d / range e) ≃ₗ ker Δ`. Conjecture:
it is in fact an **isometry**, i.e. the harmonic representative is the unique minimal-norm element of
its cohomology class, and `‖[x]‖ = ‖P x‖` where `P` is the orthogonal projection onto `ker Δ`.
Falsifiable: any closed cochain whose harmonic part has strictly larger norm than some other class
representative would refute it. **The key insight is** that `harmonic_representative_exists` writes
`x = e u + h` with `h ⊥ e u` (because `harmonic_le_orthogonal_range_e` gives `h ⊥ range e`), so
Pythagoras yields `‖x‖² = ‖e u‖² + ‖h‖² ≥ ‖h‖²` with equality iff `e u = 0`; hence the harmonic
representative is the norm-minimizer and the class norm equals `‖h‖`. **Why now?** Both halves are
theorems already: `harmonic_inf_exact_eq_bot` for uniqueness of the minimizer and
`harmonic_le_orthogonal_range_e` for the orthogonality that powers Pythagoras, so only the quotient
`Submodule.norm_mk`/`norm_quotient` comparison remains.

### 2. The harmonic projector as an idempotent on the cochain space
The three-way split `hodge_three_way_span` + `hodge_three_way_finrank` makes `ker Δ` an orthogonal
direct summand of `V`. Conjecture: the orthogonal projection `P : V →ₗ V` onto `ker Δ` satisfies
`P ∘ P = P`, `range P = ker Δ`, `ker P = range d* ⊔ range e`, and `P` commutes with `Δ`
(`P ∘ Δ = Δ ∘ P = 0`). Falsifiable by exhibiting a cochain `x` with `P (P x) ≠ P x` or
`P (Δ x) ≠ 0`. **The key insight is** that `closed_eq_exact_sup_harmonic` together with
`harmonic_le_orthogonal_range_e` identifies `ker Δ` as the orthogonal complement of
`range d* ⊔ range e` inside `V`, so `P = Submodule.orthogonalProjection (ker Δ)` and the idempotency
plus kernel description follow from `Submodule.orthogonalProjection` API on the proven decomposition.
**Why now?** `hodge_three_way_span` gives the spanning and `harmonic_le_orthogonal_range_adjoint_d`
/ `harmonic_le_orthogonal_range_e` give that the complement is exactly the other two summands, so the
projector is pinned down with no new geometry.

### 3. Euler characteristic as a telescoping alternating sum of harmonic dimensions
For a finite cochain complex `0 → V₀ → V₁ → … → Vₙ → 0`, conjecture the discrete **Hodge–Euler
theorem**: `Σ (−1)ᵏ dim(ker Δₖ) = Σ (−1)ᵏ dim Vₖ`, identifying the analytic Euler characteristic
(alternating sum of Betti numbers) with the combinatorial one. Falsifiable by any finite complex whose
harmonic Euler sum differs from its space Euler sum. **The key insight is** that the per-degree
identity `dim(ker Δₖ) = dim ker dₖ − rank eₖ` (a direct corollary of `hodge_betti`) combined with
rank–nullity `rank dₖ + dim ker dₖ = dim Vₖ` makes the consecutive `rank` terms cancel in pairs once
summed with alternating signs (the boundary identification `eₖ = dₖ₊₁` shares each rank between two
degrees). **Why now?** `hodge_betti` supplies every per-degree input, so the global statement is a
finite alternating-sum induction over `Finset.range n` using only `Module.finrank` arithmetic already
in Mathlib — no further analysis.

### 4. Message passing converges to the harmonic projector at the spectral-gap rate
Conjecture: for an admissible step `0 < α < 2/λ_max` the iterate `(id − αΔ)^[k]` converges to the
projector `P` of Direction 2, with `‖(id − αΔ)^[k] x − P x‖ ≤ ρᵏ ‖x − P x‖` for
`ρ = max|1 − αλ|` over nonzero Hodge eigenvalues `λ`. Falsifiable by a complex with an eigenvalue
outside `(0, 2/α)` that fails to contract. **The key insight is** that the three-way decomposition
(Direction 2) makes `ker Δ` and its complement simultaneously `Δ`-invariant; on the harmonic block
`Δ = 0` so the iterate is fixed, while on the complement the self-adjoint `Δ` (it is symmetric by the
`hodgeLap_quadform` energy split) has strictly positive eigenvalues, giving geometric contraction
with the stated `ρ`. **Why now?** With `P` available from Direction 2 and the finite-dimensional
spectral theorem for the symmetric `Δ`, the limit assembles from `id = P + (id − P)`, and the tight
logarithmic clock `hodgeDepth_tight` (previous cycle) already pins the exact rate.

### 5. Functoriality: chain maps induce maps on harmonic spaces
Conjecture: a morphism of two-step complexes (a commuting ladder of linear maps between
`U --e--> V --d--> W` and `U' --e'--> V' --d'--> W'`) induces a well-defined linear map on harmonic
spaces `ker Δ → ker Δ'` that agrees, under `hodgeCohomologyEquiv`, with the induced map on cohomology.
Falsifiable by a chain map whose harmonic-space map fails to commute with the cohomology map through
the isomorphism. **The key insight is** that `hodgeCohomologyEquiv` is *canonical* (built from
orthogonal complementation, not a choice of basis), so naturality reduces to checking that the middle
map sends closed cochains to closed cochains and exact to exact — exactly the two squares of the
ladder — after which `Submodule.mapQ` provides the induced cohomology map and the equivalence
transports it. **Why now?** The isomorphism is now a concrete `LinearEquiv` rather than a dimension
count, so `LinearMap.mapQ`/`Submodule.mapQ` can be composed with it directly, making functoriality a
diagram chase over already-proven complementarity rather than a fresh construction.

**Novelty estimate**: 0.75
**Breakthrough potential**: 0.75
Research domain: Novelty
Research mode: team




### Recent Discoveries in Catalog
No previous research cycles completed yet. This is a cold start — prioritize sorry_fill on the priority targets (CarmichaelComposite, Fib_gcd_identity) to close known open problems, or target cross-domain bridge theorems for novelty.


## v14 Depth Requirements -- Conceptual Unifier: Local-to-Global Sheaves Research Engine

You are leading a mathematical research team. Your goal is to produce groundbreaking,
master-class, useful, novel, and marvelous new Mathematics that pushes the frontier of human knowledge.

This engine is configured for **Conceptual Unification (Local-to-Global Sheaves)**. Explore sheaf theory, local-to-global translations, and cohomological obstructions.

### RESEARCH CORE METHODOLOGY:
1. **Local-to-Global Translation**: Construct sheaves or presheaves to describe local properties that glue together to form global structures. Check if local solutions can be extended globally.
2. **Obstruction Theory & Cohomology**: Use cohomology groups or obstruction classes to mathematically measure the failure or boundaries of local-to-global extensions.
3. **Stalk-Level Reduction**: Reduce complex global proofs to stalk-level computations or local neighborhood verifications, using algebraic localization or geometric limits.

### DELIVERABLES:
- **Lean 4 proofs** of deep, non-trivial theorems with complete proofs (no sorry on main results).
- **Lab Notebook** comment blocks in each .lean file detailing Hypothesis, Result, Insight, and Failure analysis.
- **FUTURE_DIRECTIONS.md** outlining the Synthesis of your findings, a Results Summary, and 3-5 bold, falsifiable research directions to steer the next cycle.


## Output format reminder

Your output must include `.lean` files AND a `FUTURE_DIRECTIONS.md` file.
The .lean files contain the proofs. The FUTURE_DIRECTIONS.md contains 3-5
research conjectures that extend the work. Both are required.
Be precise, be deep, be world-class.
