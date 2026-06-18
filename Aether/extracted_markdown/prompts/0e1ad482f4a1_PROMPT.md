
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

**Title**: This cycle's artifact is `Catalog/MachineLearning/NTKSpectral.lean`. It is self-
**Domain**: Novelty
**Mathematical framing**: # Future Directions: NTK Spectral Convergence

This cycle's artifact is `Catalog/MachineLearning/NTKSpectral.lean`. It is self-contained:
because this was a cold start (no prior `NTKCore` existed in the catalog), it folds in the
core NTK Gram / gradient-descent definitions and then opens the contractivity "black box"
spectrally, one eigenmode at a time.

## Synthesis

Generic statements of neural-tangent-kernel convergence hide all of their content inside an
opaque contractivity constant `c < 1`. The question driving this cycle was: *can that black
box be opened spectrally, and how much of the standard NTK convergence-rate story is
actually elementary once you look along a single eigenvector?* The answer turned out to be:
almost all of it. The gradient-descent update operator `I - ηK` is **diagonal in any
eigenbasis of `K`** — along an eigenvector `v` with eigenvalue `λ` it acts as the pure
scalar `1 - ηλ` (`gdUpdateOp_mulVec_eigenvector`). Consequently the residual obeys an
*exact* (not merely bounded) geometric law `‖uₜ‖ = |1 - ηλ|ᵗ ‖v‖`
(`gdResidual_eigenvector_norm`), and mode stability collapses to the scalar window
`0 < ηλ < 2` (`eigenvalue_stable_iff`). This reduces the entire per-mode rate analysis to
real-scalar facts, which is why the whole file is short and axiom-clean.

The genuinely non-trivial result is the **optimal learning-rate** triple. At
`η* = 2/(μ+L)` both extreme modes of a spectrum `[μ, L]` contract by exactly the
inverse-condition-number factor `(L-μ)/(L+μ)` (`optimalRate_contraction`); this factor is
`< 1` precisely because `μ > 0` (`optimalRate_lt_one`); and — the optimality direction —
*no* step size beats it on the worse of the two modes (`optimalRate_minimizes`). The
minimization proof hinges on the η-free linear combination `L(1-ημ) - μ(1-ηL) = L - μ`,
after which the triangle inequality forces `(L+μ)·max ≥ L|1-ημ| + μ|1-ηL| ≥ L-μ`. Finally
the PSD structure (`ntkGramMatrix_posSemidef`) was bridged to Mathlib's Hermitian
eigenvalue API (`ntkGram_eigenvalues_nonneg`), so the eigenvalues feeding the stability
window are provably nonnegative, and the capstone (`ntk_eigen_convergence`) assembles the
exact decay law plus the `< 1` rate for a genuine NTK mode.

What we deliberately did **not** attempt: the global operator-norm identity
`‖I - ηK‖ = maxᵢ |1 - ηλᵢ|`. That requires expanding an *arbitrary* vector in the
eigenbasis of `K` and is heavy in Mathlib's spectral-theorem API. The structural insight of
this cycle is that every bit of the *dynamics* lives along eigenvectors, so capturing the
mathematics exactly per-mode is both cheaper and more informative than a coarse
operator-norm bound — and it is exactly the per-mode picture that the next directions need.

## Results Summary

- `gdUpdateOp_mulVec_eigenvector` — `I - ηK` acts as the scalar `1 - ηλ` on eigenvectors.
- `gdResidual_eigenvector` — the residual along an eigenvector is exactly `(1 - ηλ)ᵗ v`.
- `gdResidual_eigenvector_norm` — exact geometric norm law `‖uₜ‖ = |1 - ηλ|ᵗ ‖v‖`.
- `gdResidual_eigenvector_decay` — any per-mode bound `|1-ηλ| ≤ c` upgrades to `‖uₜ‖ ≤ cᵗ‖v‖`.
- `eigenvalue_stable_iff` — a mode is strictly contractive iff `0 < ηλ < 2`.
- `optimalRate_contraction` — at `η* = 2/(μ+L)` both extreme modes contract by `(L-μ)/(L+μ)`.
- `optimalRate_lt_one` — that optimal factor is `< 1` exactly because `μ > 0`.
- `optimalRate_minimizes` — no step size beats `(L-μ)/(L+μ)` on the worse extreme mode.
- `ntkGramMatrix_posSemidef` / `ntkGram_eigenvalues_nonneg` — the Gram spectrum is `≥ 0`.
- `ntk_eigen_convergence` — capstone: exact geometric decay with an explicit `< 1` rate.

## Research Directions

### Direction 1 — Operator norm equals spectral radius for the symmetric update operator

The conjecture is that for symmetric `K` with eigenvalues `λᵢ`, the Euclidean operator norm
of the update map satisfies `‖(I - ηK).mulVec v‖ ≤ (maxᵢ |1 - ηλᵢ|) · ‖v‖` for *every* `v`,
so that `K` is contractive with the explicit constant `c = maxᵢ |1 - ηλᵢ|`. The test is
mechanical: expand an arbitrary `v` in an orthonormal eigenbasis via
`Matrix.IsHermitian.spectral_theorem`, apply the per-mode identity
`gdUpdateOp_mulVec_eigenvector` coordinatewise, and bound the resulting Parseval sum by the
maximum, then discharge the contractivity predicate. The key insight is that this cycle
already proved the per-mode *action exactly*, so the only missing ingredient is the
orthonormal-eigenbasis expansion — which is precisely what `Matrix.IsHermitian` packages.
Why now? Because the per-mode law is now a theorem rather than a heuristic, the global bound
reduces to a finite-dimensional Pythagoras argument rather than analysis. If true, it
eliminates the opaque `c` from every NTK convergence statement; if false, the failure would
localize to how the Euclidean norm on `Fin n → ℝ` interacts with `mulVec`, exposing a
coordinate subtlety worth knowing.

### Direction 2 — Strict positive-definiteness from independent feature gradients

The conjecture is that `ntkGramMatrix Φ` is positive *definite* (all eigenvalues `> 0`, a
genuine spectral gap `μ > 0`) **iff** the feature rows of `Φ` are linearly independent —
the overparameterization condition `n ≤ p`. The test routes through the factorization
`ntkGramMatrix Φ = Φ Φᵀ` and the kernel of `Φᵀ`: `PosDef` is equivalent to that kernel being
trivial, which is exactly row-independence, and `PosDef` then yields `0 < eigenvalues i`.
The key insight is that `ntkGram_eigenvalues_nonneg` already gives the `≥ 0` half, so the
entire remaining gap is upgrading non-strict to strict via an injectivity/rank statement
about `Φ`. Why now? Because every `optimalRate_*` theorem and the capstone currently take
`μ > 0` (equivalently `λ > 0`) as a *hypothesis*; this direction converts it into a
*checkable rank condition on the network*, turning assumptions into theorems about real
models. If false, a PSD-but-singular Gram with independent rows would reveal a subtlety in
the Gram/rank correspondence over `ℝ`.

### Direction 3 — Whole-vector convergence rate from the spectral gap

The conjecture is the textbook global NTK rate: if `K` is symmetric with all eigenvalues in
`[μ, L]`, `0 < μ ≤ L`, and `η = 2/(μ+L)`, then for *every* initial residual `u₀`,
`‖gdResidual K η u₀ t‖ ≤ ((L-μ)/(L+μ))ᵗ · ‖u₀‖`. The test composes Direction 1 (operator-norm
bound) with `optimalRate_contraction` and `optimalRate_lt_one`, then iterates `t` times.
The key insight is that the two ingredients — the optimal scalar rate (proved this cycle)
and the operator-norm reduction (Direction 1) — compose purely mechanically, with no new
mathematics in their conjunction. Why now? Because exactly one of the two pieces is already
formal and the other is a known Mathlib expansion; their product is the first *fully
explicit, condition-number-driven* NTK convergence theorem formalized end to end. If false,
it would mean the worst-case per-mode rate is not attained simultaneously across all initial
conditions, signalling a real gap between per-mode and global behavior.

### Direction 4 — Multi-output / block NTK via general index types

The conjecture is that re-deriving the entire file with the scalar index `Fin n` replaced by
an arbitrary `Fintype ι` (e.g. `ι = Fin n × Fin k` for `k`-class outputs) leaves every
theorem true verbatim. The test is to generalize `ntkGramMatrix`, `gdUpdateOp`, `gdResidual`
and the spectral lemmas to `[Fintype ι] [DecidableEq ι]` and re-run the proofs; the block
Gram structure is still `Φ Φᵀ`, so PSD-ness and nonnegative eigenvalues should transfer
unchanged. The key insight is that none of this cycle's proofs ever touch the linear order
or cardinality of `Fin n` — they manipulate only `mulVec`, `smul`, and scalars — so the
development is already secretly index-agnostic. Why now? Because the proofs exist and are
short, this is a cheap robustness stress-test rather than new theory. If false, the point of
failure pinpoints exactly which lemma secretly depended on `Fin n`, which is precisely the
information needed before any larger generalization.

### Direction 5 — Loss decay rate and the PL / strong-convexity bridge

The conjecture is that with `K = ntkGramMatrix Φ` positive definite (gap `μ > 0`) and
squared loss `𝓛(u) = ½‖u‖²` on the residual, gradient descent satisfies
`𝓛(uₜ) ≤ (1 - ημ)^{2t} 𝓛(u₀)`, i.e. linear convergence of the *loss*, not just the
residual. The test squares the residual bound (from Direction 3, or directly the per-mode
law `gdResidual_eigenvector_norm`) and identifies `1 - ημ` as the slowest-decaying mode,
relating `𝓛(uₜ)` to `‖uₜ‖²`. The key insight is that `gdResidual_eigenvector_norm` already
gives the *exact squared norm per mode*, so the loss — a sum of these squares — inherits the
rate as a one-line corollary once the spectral gap (Direction 2) is in hand. Why now?
Because the exact per-mode squared-norm is already a theorem, the loss-rate statement needs
no new dynamics, only summation. If true, it connects the NTK picture to the
Polyak–Łojasiewicz / strong-convexity view of optimization, opening a bridge to the
convex-optimization corner of the catalog. If false, the discrepancy between residual-rate
and loss-rate would reveal a cross-term the naive squaring argument misses.

**Concept description**: # Future Directions: NTK Spectral Convergence

This cycle's artifact is `Catalog/MachineLearning/NTKSpectral.lean`. It is self-contained:
because this was a cold start (no prior `NTKCore` existed in the catalog), it folds in the
core NTK Gram / gradient-descent definitions and then opens the contractivity "black box"
spectrally, one eigenmode at a time.

## Synthesis

Generic statements of neural-tangent-kernel convergence hide all of their content inside an
opaque contractivity constant `c < 1`. The question driving this cycle was: *can that black
box be opened spectrally, and how much of the standard NTK convergence-rate story is
actually elementary once you look along a single eigenvector?* The answer turned out to be:
almost all of it. The gradient-descent update operator `I - ηK` is **diagonal in any
eigenbasis of `K`** — along an eigenvector `v` with eigenvalue `λ` it acts as the pure
scalar `1 - ηλ` (`gdUpdateOp_mulVec_eigenvector`). Consequently the residual obeys an
*exact* (not merely bounded) geometric law `‖uₜ‖ = |1 - ηλ|ᵗ ‖v‖`
(`gdResidual_eigenvector_norm`), and mode stability collapses to the scalar window
`0 < ηλ < 2` (`eigenvalue_stable_iff`). This reduces the entire per-mode rate analysis to
real-scalar facts, which is why the whole file is short and axiom-clean.

The genuinely non-trivial result is the **optimal learning-rate** triple. At
`η* = 2/(μ+L)` both extreme modes of a spectrum `[μ, L]` contract by exactly the
inverse-condition-number factor `(L-μ)/(L+μ)` (`optimalRate_contraction`); this factor is
`< 1` precisely because `μ > 0` (`optimalRate_lt_one`); and — the optimality direction —
*no* step size beats it on the worse of the two modes (`optimalRate_minimizes`). The
minimization proof hinges on the η-free linear combination `L(1-ημ) - μ(1-ηL) = L - μ`,
after which the triangle inequality forces `(L+μ)·max ≥ L|1-ημ| + μ|1-ηL| ≥ L-μ`. Finally
the PSD structure (`ntkGramMatrix_posSemidef`) was bridged to Mathlib's Hermitian
eigenvalue API (`ntkGram_eigenvalues_nonneg`), so the eigenvalues feeding the stability
window are provably nonnegative, and the capstone (`ntk_eigen_convergence`) assembles the
exact decay law plus the `< 1` rate for a genuine NTK mode.

What we deliberately did **not** attempt: the global operator-norm identity
`‖I - ηK‖ = maxᵢ |1 - ηλᵢ|`. That requires expanding an *arbitrary* vector in the
eigenbasis of `K` and is heavy in Mathlib's spectral-theorem API. The structural insight of
this cycle is that every bit of the *dynamics* lives along eigenvectors, so capturing the
mathematics exactly per-mode is both cheaper and more informative than a coarse
operator-norm bound — and it is exactly the per-mode picture that the next directions need.

## Results Summary

- `gdUpdateOp_mulVec_eigenvector` — `I - ηK` acts as the scalar `1 - ηλ` on eigenvectors.
- `gdResidual_eigenvector` — the residual along an eigenvector is exactly `(1 - ηλ)ᵗ v`.
- `gdResidual_eigenvector_norm` — exact geometric norm law `‖uₜ‖ = |1 - ηλ|ᵗ ‖v‖`.
- `gdResidual_eigenvector_decay` — any per-mode bound `|1-ηλ| ≤ c` upgrades to `‖uₜ‖ ≤ cᵗ‖v‖`.
- `eigenvalue_stable_iff` — a mode is strictly contractive iff `0 < ηλ < 2`.
- `optimalRate_contraction` — at `η* = 2/(μ+L)` both extreme modes contract by `(L-μ)/(L+μ)`.
- `optimalRate_lt_one` — that optimal factor is `< 1` exactly because `μ > 0`.
- `optimalRate_minimizes` — no step size beats `(L-μ)/(L+μ)` on the worse extreme mode.
- `ntkGramMatrix_posSemidef` / `ntkGram_eigenvalues_nonneg` — the Gram spectrum is `≥ 0`.
- `ntk_eigen_convergence` — capstone: exact geometric decay with an explicit `< 1` rate.

## Research Directions

### Direction 1 — Operator norm equals spectral radius for the symmetric update operator

The conjecture is that for symmetric `K` with eigenvalues `λᵢ`, the Euclidean operator norm
of the update map satisfies `‖(I - ηK).mulVec v‖ ≤ (maxᵢ |1 - ηλᵢ|) · ‖v‖` for *every* `v`,
so that `K` is contractive with the explicit constant `c = maxᵢ |1 - ηλᵢ|`. The test is
mechanical: expand an arbitrary `v` in an orthonormal eigenbasis via
`Matrix.IsHermitian.spectral_theorem`, apply the per-mode identity
`gdUpdateOp_mulVec_eigenvector` coordinatewise, and bound the resulting Parseval sum by the
maximum, then discharge the contractivity predicate. The key insight is that this cycle
already proved the per-mode *action exactly*, so the only missing ingredient is the
orthonormal-eigenbasis expansion — which is precisely what `Matrix.IsHermitian` packages.
Why now? Because the per-mode law is now a theorem rather than a heuristic, the global bound
reduces to a finite-dimensional Pythagoras argument rather than analysis. If true, it
eliminates the opaque `c` from every NTK convergence statement; if false, the failure would
localize to how the Euclidean norm on `Fin n → ℝ` interacts with `mulVec`, exposing a
coordinate subtlety worth knowing.

### Direction 2 — Strict positive-definiteness from independent feature gradients

The conjecture is that `ntkGramMatrix Φ` is positive *definite* (all eigenvalues `> 0`, a
genuine spectral gap `μ > 0`) **iff** the feature rows of `Φ` are linearly independent —
the overparameterization condition `n ≤ p`. The test routes through the factorization
`ntkGramMatrix Φ = Φ Φᵀ` and the kernel of `Φᵀ`: `PosDef` is equivalent to that kernel being
trivial, which is exactly row-independence, and `PosDef` then yields `0 < eigenvalues i`.
The key insight is that `ntkGram_eigenvalues_nonneg` already gives the `≥ 0` half, so the
entire remaining gap is upgrading non-strict to strict via an injectivity/rank statement
about `Φ`. Why now? Because every `optimalRate_*` theorem and the capstone currently take
`μ > 0` (equivalently `λ > 0`) as a *hypothesis*; this direction converts it into a
*checkable rank condition on the network*, turning assumptions into theorems about real
models. If false, a PSD-but-singular Gram with independent rows would reveal a subtlety in
the Gram/rank correspondence over `ℝ`.

### Direction 3 — Whole-vector convergence rate from the spectral gap

The conjecture is the textbook global NTK rate: if `K` is symmetric with all eigenvalues in
`[μ, L]`, `0 < μ ≤ L`, and `η = 2/(μ+L)`, then for *every* initial residual `u₀`,
`‖gdResidual K η u₀ t‖ ≤ ((L-μ)/(L+μ))ᵗ · ‖u₀‖`. The test composes Direction 1 (operator-norm
bound) with `optimalRate_contraction` and `optimalRate_lt_one`, then iterates `t` times.
The key insight is that the two ingredients — the optimal scalar rate (proved this cycle)
and the operator-norm reduction (Direction 1) — compose purely mechanically, with no new
mathematics in their conjunction. Why now? Because exactly one of the two pieces is already
formal and the other is a known Mathlib expansion; their product is the first *fully
explicit, condition-number-driven* NTK convergence theorem formalized end to end. If false,
it would mean the worst-case per-mode rate is not attained simultaneously across all initial
conditions, signalling a real gap between per-mode and global behavior.

### Direction 4 — Multi-output / block NTK via general index types

The conjecture is that re-deriving the entire file with the scalar index `Fin n` replaced by
an arbitrary `Fintype ι` (e.g. `ι = Fin n × Fin k` for `k`-class outputs) leaves every
theorem true verbatim. The test is to generalize `ntkGramMatrix`, `gdUpdateOp`, `gdResidual`
and the spectral lemmas to `[Fintype ι] [DecidableEq ι]` and re-run the proofs; the block
Gram structure is still `Φ Φᵀ`, so PSD-ness and nonnegative eigenvalues should transfer
unchanged. The key insight is that none of this cycle's proofs ever touch the linear order
or cardinality of `Fin n` — they manipulate only `mulVec`, `smul`, and scalars — so the
development is already secretly index-agnostic. Why now? Because the proofs exist and are
short, this is a cheap robustness stress-test rather than new theory. If false, the point of
failure pinpoints exactly which lemma secretly depended on `Fin n`, which is precisely the
information needed before any larger generalization.

### Direction 5 — Loss decay rate and the PL / strong-convexity bridge

The conjecture is that with `K = ntkGramMatrix Φ` positive definite (gap `μ > 0`) and
squared loss `𝓛(u) = ½‖u‖²` on the residual, gradient descent satisfies
`𝓛(uₜ) ≤ (1 - ημ)^{2t} 𝓛(u₀)`, i.e. linear convergence of the *loss*, not just the
residual. The test squares the residual bound (from Direction 3, or directly the per-mode
law `gdResidual_eigenvector_norm`) and identifies `1 - ημ` as the slowest-decaying mode,
relating `𝓛(uₜ)` to `‖uₜ‖²`. The key insight is that `gdResidual_eigenvector_norm` already
gives the *exact squared norm per mode*, so the loss — a sum of these squares — inherits the
rate as a one-line corollary once the spectral gap (Direction 2) is in hand. Why now?
Because the exact per-mode squared-norm is already a theorem, the loss-rate statement needs
no new dynamics, only summation. If true, it connects the NTK picture to the
Polyak–Łojasiewicz / strong-convexity view of optimization, opening a bridge to the
convex-optimization corner of the catalog. If false, the discrepancy between residual-rate
and loss-rate would reveal a cross-term the naive squaring argument misses.

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
