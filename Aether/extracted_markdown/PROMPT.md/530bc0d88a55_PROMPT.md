
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

**Title**: The discrete-Hodge program has, over its earlier cycles, built the *geometric/de
**Domain**: Novelty
**Mathematical framing**: # Future Directions — Hodge Spectral Duality, Seventh Cycle

## Synthesis

The discrete-Hodge program has, over its earlier cycles, built the *geometric/decomposition*
layer (`HodgeFullDecomposition`: the split Dirichlet energy `⟨x,Lx⟩ = ‖Dx‖² + ‖Eᵀx‖²`, the
discrete Hodge theorem `harmonic ⇔ closed ∧ coclosed`, and image orthogonality from `∂∂=0`)
and the *operator/solvability* layer (`HodgeGreenOperator`, `HodgeResolutionIdentity`).

This cycle adds the **Duality & Representation** layer. The new file `HodgeSpectralDuality.lean`
isolates a *single* boundary matrix `D` and exhibits its two Gram-Laplacians — the up-Laplacian
`Dᵀ D` on the source cochains and the down-Laplacian `D Dᵀ` on the target cochains — as two
representations of *one* spectral object. The boundary map is shown to be a self-dual pairing
(`hodge_adjunction`: `⟨Dx,y⟩ = ⟨x,Dᵀy⟩`), and from this single adjunction we derive:

* **trace duality** (`hodge_trace_duality`): equal sum of squared singular values;
* **explicit eigenvector dictionaries** (`eigvec_transfer_up_down`, `eigvec_transfer_down_up`):
  `D` and `Dᵀ` carry nonzero-eigenvalue eigenvectors back and forth;
* the **capstone isospectrality** (`hodge_spectral_duality`): `Dᵀ D` and `D Dᵀ` have *identical
  nonzero spectra*.

This is the discrete avatar of the analytic fact that `∂` and its adjoint `∂*` share their
nonzero singular values — the representation-theoretic heart of Hodge theory, now available as
an elementary, determinant-free statement about matrices over `ℝ`.

## Results Summary

| Theorem | Statement | Role |
|---|---|---|
| `hodge_adjunction` | `⟨Dx, y⟩ = ⟨x, Dᵀy⟩` | the duality pairing intertwining both Laplacians |
| `hodge_trace_duality` | `tr(Dᵀ D) = tr(D Dᵀ)` | representation-level invariant |
| `eigvec_transfer_up_down` | nonzero `μ`-eigvec `v` of `Dᵀ D` ↦ nonzero `μ`-eigvec `Dv` of `D Dᵀ` | forward dictionary |
| `eigvec_transfer_down_up` | dual transfer via `Dᵀ` | backward dictionary |
| `hodge_spectral_duality` | `nonzeroSpectrum (Dᵀ D) = nonzeroSpectrum (D Dᵀ)` | **capstone** isospectrality |

All five are proven `sorry`-free, depending only on `propext`, `Classical.choice`, `Quot.sound`.

## Research Directions

### 1. Eigenvalue *multiplicity* duality, not just set equality

The current capstone equates the nonzero spectra *as sets*. The sharper, falsifiable claim is
that `D` induces a **linear isomorphism** `ker(DᵀD − μ) ≅ ker(DDᵀ − μ)` for every `μ ≠ 0`, so the
geometric multiplicities agree exactly. The key insight is that the transfer maps `v ↦ Dv` and
`w ↦ Dᵀw` are *mutually inverse up to the scalar `μ`* on the nonzero eigenspaces:
`Dᵀ(Dv) = (DᵀD)v = μv`, so `(1/μ)Dᵀ ∘ D = id` on the `μ`-eigenspace. Why now? The eigenvector
dictionaries `eigvec_transfer_up_down`/`_down_up` already supply both maps; only the scalar-inverse
bookkeeping and a `Submodule`-level packaging remain, which is a contained linear-algebra task.

### 2. The zero eigenvalue is the *only* obstruction — a discrete index theorem

Set-level isospectrality deliberately excludes `μ = 0`, where the kernels `ker(DᵀD) = ker D` and
`ker(DDᵀ) = ker Dᵀ` genuinely differ in dimension. The key insight is that this discrepancy is
*exactly* the rank-nullity defect: `dim ker D − dim ker Dᵀ = n − m` while the nonzero spectra match
with multiplicity, giving a one-line **discrete index theorem** `χ = n − m = dim ker D − dim ker Dᵀ`.
Why now? With Direction 1 establishing nonzero-multiplicity equality, the alternating count of all
eigenvalues telescopes, and Mathlib's `Matrix.rank` / rank-nullity lemmas close the remaining gap.

### 3. Functional calculus transports across the duality

Because `DᵀD` and `DDᵀ` share nonzero spectra, *any* spectral function should commute with the
boundary map on the orthogonal complement of the kernel: `f(DDᵀ) ∘ D = D ∘ f(DᵀD)` for polynomials
`f`, and then for the heat semigroup `exp(−t·L)` and resolvents `(L − z)⁻¹`. The key insight is that
the intertwining `DDᵀ ∘ D = D ∘ DᵀD` (already the engine of `eigvec_transfer_up_down`) lifts verbatim
to any polynomial by induction, since `D` commutes with the recursion. Why now? This connects the
present duality to the existing `HodgeResolutionIdentity` and `HodgeGreenOperator` resolvent layer,
turning two separate cycles into one functional-calculus statement.

### 4. Bipartite/singular-value bridge to the expander catalog

The pair `(DᵀD, DDᵀ)` is the adjacency-squared of the bipartite graph whose biadjacency matrix is
`D`. The key insight is that `hodge_spectral_duality` is precisely the statement that a bipartite
graph's nonzero adjacency spectrum is symmetric and determined by its singular values, so the
present file is a Hodge-theoretic restatement of the spectral input used in
`Algebra/ClassicalGroupExpanders` and `Algebra/ExpanderWalk`. Why now? A shared `singularValue`
abstraction would let the expander-mixing results consume `hodge_trace_duality` directly as the
"sum of squared singular values" bound, a genuine cross-domain bridge.

### 5. Coupled message passing converges at the *same* rate on both layers

In simplicial/higher-order message passing the up- and down-Laplacians drive diffusion on adjacent
cochain degrees. The key insight is that isospectrality forces the *spectral gaps* (smallest nonzero
eigenvalue) of `DᵀD` and `DDᵀ` to coincide, so a coupled scheme alternating between the two layers
inherits a single, shared contraction factor `1 − μ_min`. Why now? `HodgeMessagePassingConvergence`
already has the per-layer linear-rate machinery; combining it with the present `nonzeroSpectrum`
equality yields a falsifiable prediction — equal asymptotic convergence rate on both layers — that
can be checked numerically before being formalized.

**Concept description**: # Future Directions — Hodge Spectral Duality, Seventh Cycle

## Synthesis

The discrete-Hodge program has, over its earlier cycles, built the *geometric/decomposition*
layer (`HodgeFullDecomposition`: the split Dirichlet energy `⟨x,Lx⟩ = ‖Dx‖² + ‖Eᵀx‖²`, the
discrete Hodge theorem `harmonic ⇔ closed ∧ coclosed`, and image orthogonality from `∂∂=0`)
and the *operator/solvability* layer (`HodgeGreenOperator`, `HodgeResolutionIdentity`).

This cycle adds the **Duality & Representation** layer. The new file `HodgeSpectralDuality.lean`
isolates a *single* boundary matrix `D` and exhibits its two Gram-Laplacians — the up-Laplacian
`Dᵀ D` on the source cochains and the down-Laplacian `D Dᵀ` on the target cochains — as two
representations of *one* spectral object. The boundary map is shown to be a self-dual pairing
(`hodge_adjunction`: `⟨Dx,y⟩ = ⟨x,Dᵀy⟩`), and from this single adjunction we derive:

* **trace duality** (`hodge_trace_duality`): equal sum of squared singular values;
* **explicit eigenvector dictionaries** (`eigvec_transfer_up_down`, `eigvec_transfer_down_up`):
  `D` and `Dᵀ` carry nonzero-eigenvalue eigenvectors back and forth;
* the **capstone isospectrality** (`hodge_spectral_duality`): `Dᵀ D` and `D Dᵀ` have *identical
  nonzero spectra*.

This is the discrete avatar of the analytic fact that `∂` and its adjoint `∂*` share their
nonzero singular values — the representation-theoretic heart of Hodge theory, now available as
an elementary, determinant-free statement about matrices over `ℝ`.

## Results Summary

| Theorem | Statement | Role |
|---|---|---|
| `hodge_adjunction` | `⟨Dx, y⟩ = ⟨x, Dᵀy⟩` | the duality pairing intertwining both Laplacians |
| `hodge_trace_duality` | `tr(Dᵀ D) = tr(D Dᵀ)` | representation-level invariant |
| `eigvec_transfer_up_down` | nonzero `μ`-eigvec `v` of `Dᵀ D` ↦ nonzero `μ`-eigvec `Dv` of `D Dᵀ` | forward dictionary |
| `eigvec_transfer_down_up` | dual transfer via `Dᵀ` | backward dictionary |
| `hodge_spectral_duality` | `nonzeroSpectrum (Dᵀ D) = nonzeroSpectrum (D Dᵀ)` | **capstone** isospectrality |

All five are proven `sorry`-free, depending only on `propext`, `Classical.choice`, `Quot.sound`.

## Research Directions

### 1. Eigenvalue *multiplicity* duality, not just set equality

The current capstone equates the nonzero spectra *as sets*. The sharper, falsifiable claim is
that `D` induces a **linear isomorphism** `ker(DᵀD − μ) ≅ ker(DDᵀ − μ)` for every `μ ≠ 0`, so the
geometric multiplicities agree exactly. The key insight is that the transfer maps `v ↦ Dv` and
`w ↦ Dᵀw` are *mutually inverse up to the scalar `μ`* on the nonzero eigenspaces:
`Dᵀ(Dv) = (DᵀD)v = μv`, so `(1/μ)Dᵀ ∘ D = id` on the `μ`-eigenspace. Why now? The eigenvector
dictionaries `eigvec_transfer_up_down`/`_down_up` already supply both maps; only the scalar-inverse
bookkeeping and a `Submodule`-level packaging remain, which is a contained linear-algebra task.

### 2. The zero eigenvalue is the *only* obstruction — a discrete index theorem

Set-level isospectrality deliberately excludes `μ = 0`, where the kernels `ker(DᵀD) = ker D` and
`ker(DDᵀ) = ker Dᵀ` genuinely differ in dimension. The key insight is that this discrepancy is
*exactly* the rank-nullity defect: `dim ker D − dim ker Dᵀ = n − m` while the nonzero spectra match
with multiplicity, giving a one-line **discrete index theorem** `χ = n − m = dim ker D − dim ker Dᵀ`.
Why now? With Direction 1 establishing nonzero-multiplicity equality, the alternating count of all
eigenvalues telescopes, and Mathlib's `Matrix.rank` / rank-nullity lemmas close the remaining gap.

### 3. Functional calculus transports across the duality

Because `DᵀD` and `DDᵀ` share nonzero spectra, *any* spectral function should commute with the
boundary map on the orthogonal complement of the kernel: `f(DDᵀ) ∘ D = D ∘ f(DᵀD)` for polynomials
`f`, and then for the heat semigroup `exp(−t·L)` and resolvents `(L − z)⁻¹`. The key insight is that
the intertwining `DDᵀ ∘ D = D ∘ DᵀD` (already the engine of `eigvec_transfer_up_down`) lifts verbatim
to any polynomial by induction, since `D` commutes with the recursion. Why now? This connects the
present duality to the existing `HodgeResolutionIdentity` and `HodgeGreenOperator` resolvent layer,
turning two separate cycles into one functional-calculus statement.

### 4. Bipartite/singular-value bridge to the expander catalog

The pair `(DᵀD, DDᵀ)` is the adjacency-squared of the bipartite graph whose biadjacency matrix is
`D`. The key insight is that `hodge_spectral_duality` is precisely the statement that a bipartite
graph's nonzero adjacency spectrum is symmetric and determined by its singular values, so the
present file is a Hodge-theoretic restatement of the spectral input used in
`Algebra/ClassicalGroupExpanders` and `Algebra/ExpanderWalk`. Why now? A shared `singularValue`
abstraction would let the expander-mixing results consume `hodge_trace_duality` directly as the
"sum of squared singular values" bound, a genuine cross-domain bridge.

### 5. Coupled message passing converges at the *same* rate on both layers

In simplicial/higher-order message passing the up- and down-Laplacians drive diffusion on adjacent
cochain degrees. The key insight is that isospectrality forces the *spectral gaps* (smallest nonzero
eigenvalue) of `DᵀD` and `DDᵀ` to coincide, so a coupled scheme alternating between the two layers
inherits a single, shared contraction factor `1 − μ_min`. Why now? `HodgeMessagePassingConvergence`
already has the per-layer linear-rate machinery; combining it with the present `nonzeroSpectrum`
equality yields a falsifiable prediction — equal asymptotic convergence rate on both layers — that
can be checked numerically before being formalized.

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
