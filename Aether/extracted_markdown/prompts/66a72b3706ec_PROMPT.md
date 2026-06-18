
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

**Title**: This cycle pushed the *spectral depth threshold* program of
**Domain**: Novelty
**Mathematical framing**: # Future Directions — Hodge–Laplacian Message Passing, Second Cycle

## Synthesis

This cycle pushed the *spectral depth threshold* program of
`HodgeSpectralThreshold.lean` forward along two of its own conjectured axes, turning
two informal "future directions" into proven, sorry-free Lean 4 theory.

* **`HodgeFullDecomposition.lean` — the genuine Hodge Laplacian.**
  The original file modelled only the *up* Laplacian `L = Bᵀ B`. We upgraded to the full
  combinatorial Hodge Laplacian `L = ∂ₖᵀ ∂ₖ + ∂ₖ₊₁ ∂ₖ₊₁ᵀ` built from *two* boundary
  maps. The Dirichlet energy now splits into a **closed** channel `‖∂ₖ x‖²` and a
  **coclosed** channel `‖∂ₖ₊₁ᵀ x‖²` (`fullHodge_quadform`), and the discrete Hodge
  theorem (`fullHodge_kernel`) characterizes harmonic cochains as exactly the
  *closed-and-coclosed* signals — the genuine cohomological invariant
  `ker ∂ₖ ∩ ker ∂ₖ₊₁ᵀ`. The chain condition `∂ₖ ∂ₖ₊₁ = 0` is isolated to a single
  orthogonality lemma (`hodge_image_orthogonal`) from which a Pythagorean energy identity
  (`hodge_energy_pythagoras`) follows.

* **`HodgeDepthLogarithmic.lean` — the explicit logarithmic depth law.**
  The original `spectral_depth_threshold` only asserted that *some* finite depth reaches a
  tolerance `ε`. We replaced that non-constructive existence with the explicit, evaluable
  witness `N(ε) = ⌈log_ρ(ε/‖x‖²)⌉` (`hodgeDepth`) and proved it suffices
  (`hodgeDepth_residual_bound`, specialized to message passing in `hodge_mp_log_depth`).
  Depth grows like `log(1/ε)`: this is the quantitative depth–accuracy trade-off.

The unifying picture sharpens: message passing is a discrete deformation retraction onto
the harmonic core, the harmonic core is now correctly the *cohomology* (not just a single
boundary kernel), and the speed of the retraction is governed by an explicit logarithmic
clock.

## Results summary

| Theorem | File | Statement |
|---|---|---|
| `fullHodge_isSymm` | FullDecomposition | full Hodge Laplacian is symmetric |
| `fullHodge_quadform` | FullDecomposition | `⟨x,Lx⟩ = ‖∂ₖx‖² + ‖∂ₖ₊₁ᵀx‖²` |
| `fullHodge_psd` | FullDecomposition | `L` positive semidefinite |
| `fullHodge_kernel` | FullDecomposition | harmonic ⇔ closed ∧ coclosed (discrete Hodge) |
| `hodge_image_orthogonal` | FullDecomposition | `∂∂=0 ⇒ im ∂ₖ₊₁ ⊥ im ∂ₖᵀ` |
| `hodge_energy_pythagoras` | FullDecomposition | Pythagoras for the Hodge splitting |
| `quadform_iterate_bound` | DepthLogarithmic | geometric energy decay `ρᵏ` |
| `pow_le_of_logb_le` | DepthLogarithmic | `N ≥ log_ρ c ⇒ ρᴺ ≤ c` |
| `hodgeDepth_residual_bound` | DepthLogarithmic | explicit `⌈log⌉` depth suffices |
| `hodge_mp_log_depth` | DepthLogarithmic | the above, for `mpStep` |

All proofs depend only on `propext`, `Classical.choice`, `Quot.sound`.

## Research directions

### 1. Betti numbers from the harmonic kernel dimension
Conjecture: with `fullHodge_kernel` in hand, `dim ker(∂ₖᵀ∂ₖ + ∂ₖ₊₁∂ₖ₊₁ᵀ) = dim ker ∂ₖ −
rank ∂ₖ₊₁`, i.e. the dimension of the space of harmonic `k`-cochains equals the `k`-th
Betti number. This is falsifiable: any explicit small complex whose harmonic-space
dimension disagrees with its rank-nullity prediction refutes it. **The key insight is**
that `fullHodge_kernel` already identifies harmonic cochains as `ker ∂ₖ ∩ (im ∂ₖ₊₁)ᗮ`, so
the Betti formula is precisely the rank–nullity theorem applied to `∂ₖ` restricted to that
intersection — no new geometry, only `Matrix.rank` bookkeeping. **Why now?** Mathlib's
`Matrix.rank`, `LinearMap.finrank_range_add_finrank_ker`, and the orthogonality lemma
`hodge_image_orthogonal` proven here are exactly the three ingredients required.

### 2. Convergence to the harmonic projector
Conjecture: for the admissible step `0 < α < 2/λ_max`, the iterate `(mpStep L α)^[k]`
converges entrywise to the orthogonal projector `P` onto `ker L`, with
`‖(mpStep L α)^[k] x − P x‖² ≤ ρᵏ ‖x − P x‖²` where `ρ = 1 − αμ(2 − αλ)`. Falsifiable by a
complex with an eigenvalue outside `(0, 2/α)` exhibiting non-contraction. **The key insight
is** that `quadform_iterate_bound` already gives the geometric rate on the invariant
complement `(ker L)ᗮ`; the only missing step is invariance `mpStep L α '' (ker L)ᗮ ⊆
(ker L)ᗮ`, a one-line consequence of self-adjointness (`fullHodge_isSymm`). **Why now?**
With harmonic signals fixed (`mpStep_iterate_fixes_harmonic`) and the contraction on the
complement quantified, the splitting `id = P + (id − P)` assembles the limit directly from
Mathlib's `Submodule.orthogonalProjection`.

### 3. Tightness of the logarithmic depth
Conjecture: the depth `hodgeDepth ρ ‖x‖² ε = ⌈log_ρ(ε/‖x‖²)⌉` is not merely sufficient but
**tight**: for the bottom non-harmonic eigenvector `v` (energy contracted by *exactly* `ρ`
each layer) every layer below `hodgeDepth − 1` leaves residual `> ε`. Falsifiable by a
complex where strictly fewer layers already reach `ε` on every input. **The key insight is**
that the worst-case input saturates `quadform_iterate_bound` with equality
(`‖Tᵏv‖² = ρᵏ‖v‖²`), so the sufficient bound becomes exact and the ceiling becomes a
genuine minimum. **Why now?** `pow_le_of_logb_le` proven here has an immediate converse
`ρᴺ > c` for `N < log_ρ c` via the same `div_lt_iff_of_neg` lemma, so tightness is a
mechanical mirror of the existing proof.

### 4. Heat-flow continuum limit of the depth clock
Conjecture: the discrete flow `x_{k+1} = x_k − α L x_k` is the explicit Euler scheme of the
Hodge heat equation `ẋ = −L x`; as `α → 0` with `kα = t` fixed, `(mpStep L α)^[k] x →
e^{−tL} x`, and the continuum decay constant equals the spectral gap `μ`. Falsifiable by a
complex whose empirical decay rate differs from its second-smallest Hodge eigenvalue.
**The key insight is** that the contraction factor `1 − αμ(2 − αλ) ≈ 1 − 2αμ` is the
first-order expansion of `e^{−2αμ}`, identifying the discrete logarithmic depth clock
`hodgeDepth` with the continuous heat-kernel half-life `t = log(1/ε)/(2μ)`. **Why now?**
Mathlib's `Matrix.exp` and its derivative API make the Euler-to-exponential limit a
concrete analysis target, and `hodgeDepth` provides the discrete side of the comparison.

### 5. Multi-tolerance depth schedules and adaptive smoothing
Conjecture: for a decreasing tolerance schedule `ε_1 > ε_2 > …`, the *incremental* depths
`hodgeDepth ρ E ε_{j+1} − hodgeDepth ρ E ε_j = ⌈log_ρ(ε_{j+1}/ε_j)⌉` are governed only by
the *ratio* of consecutive tolerances, independent of the signal energy `E`. This predicts
that adaptive smoothing networks should add layers in batches sized by geometric tolerance
ratios. Falsifiable by a regime where required incremental depth depends on `E`. **The key
insight is** that `hodgeDepth` is `⌈log_ρ⌉` of a *quotient*, so energy cancels in
differences, making the depth schedule a pure function of the accuracy ratio. **Why now?**
`hodgeDepth` and `pow_le_of_logb_le` give the closed form; the increment law is a direct
`Real.logb` arithmetic corollary requiring no new analysis.

**Concept description**: # Future Directions — Hodge–Laplacian Message Passing, Second Cycle

## Synthesis

This cycle pushed the *spectral depth threshold* program of
`HodgeSpectralThreshold.lean` forward along two of its own conjectured axes, turning
two informal "future directions" into proven, sorry-free Lean 4 theory.

* **`HodgeFullDecomposition.lean` — the genuine Hodge Laplacian.**
  The original file modelled only the *up* Laplacian `L = Bᵀ B`. We upgraded to the full
  combinatorial Hodge Laplacian `L = ∂ₖᵀ ∂ₖ + ∂ₖ₊₁ ∂ₖ₊₁ᵀ` built from *two* boundary
  maps. The Dirichlet energy now splits into a **closed** channel `‖∂ₖ x‖²` and a
  **coclosed** channel `‖∂ₖ₊₁ᵀ x‖²` (`fullHodge_quadform`), and the discrete Hodge
  theorem (`fullHodge_kernel`) characterizes harmonic cochains as exactly the
  *closed-and-coclosed* signals — the genuine cohomological invariant
  `ker ∂ₖ ∩ ker ∂ₖ₊₁ᵀ`. The chain condition `∂ₖ ∂ₖ₊₁ = 0` is isolated to a single
  orthogonality lemma (`hodge_image_orthogonal`) from which a Pythagorean energy identity
  (`hodge_energy_pythagoras`) follows.

* **`HodgeDepthLogarithmic.lean` — the explicit logarithmic depth law.**
  The original `spectral_depth_threshold` only asserted that *some* finite depth reaches a
  tolerance `ε`. We replaced that non-constructive existence with the explicit, evaluable
  witness `N(ε) = ⌈log_ρ(ε/‖x‖²)⌉` (`hodgeDepth`) and proved it suffices
  (`hodgeDepth_residual_bound`, specialized to message passing in `hodge_mp_log_depth`).
  Depth grows like `log(1/ε)`: this is the quantitative depth–accuracy trade-off.

The unifying picture sharpens: message passing is a discrete deformation retraction onto
the harmonic core, the harmonic core is now correctly the *cohomology* (not just a single
boundary kernel), and the speed of the retraction is governed by an explicit logarithmic
clock.

## Results summary

| Theorem | File | Statement |
|---|---|---|
| `fullHodge_isSymm` | FullDecomposition | full Hodge Laplacian is symmetric |
| `fullHodge_quadform` | FullDecomposition | `⟨x,Lx⟩ = ‖∂ₖx‖² + ‖∂ₖ₊₁ᵀx‖²` |
| `fullHodge_psd` | FullDecomposition | `L` positive semidefinite |
| `fullHodge_kernel` | FullDecomposition | harmonic ⇔ closed ∧ coclosed (discrete Hodge) |
| `hodge_image_orthogonal` | FullDecomposition | `∂∂=0 ⇒ im ∂ₖ₊₁ ⊥ im ∂ₖᵀ` |
| `hodge_energy_pythagoras` | FullDecomposition | Pythagoras for the Hodge splitting |
| `quadform_iterate_bound` | DepthLogarithmic | geometric energy decay `ρᵏ` |
| `pow_le_of_logb_le` | DepthLogarithmic | `N ≥ log_ρ c ⇒ ρᴺ ≤ c` |
| `hodgeDepth_residual_bound` | DepthLogarithmic | explicit `⌈log⌉` depth suffices |
| `hodge_mp_log_depth` | DepthLogarithmic | the above, for `mpStep` |

All proofs depend only on `propext`, `Classical.choice`, `Quot.sound`.

## Research directions

### 1. Betti numbers from the harmonic kernel dimension
Conjecture: with `fullHodge_kernel` in hand, `dim ker(∂ₖᵀ∂ₖ + ∂ₖ₊₁∂ₖ₊₁ᵀ) = dim ker ∂ₖ −
rank ∂ₖ₊₁`, i.e. the dimension of the space of harmonic `k`-cochains equals the `k`-th
Betti number. This is falsifiable: any explicit small complex whose harmonic-space
dimension disagrees with its rank-nullity prediction refutes it. **The key insight is**
that `fullHodge_kernel` already identifies harmonic cochains as `ker ∂ₖ ∩ (im ∂ₖ₊₁)ᗮ`, so
the Betti formula is precisely the rank–nullity theorem applied to `∂ₖ` restricted to that
intersection — no new geometry, only `Matrix.rank` bookkeeping. **Why now?** Mathlib's
`Matrix.rank`, `LinearMap.finrank_range_add_finrank_ker`, and the orthogonality lemma
`hodge_image_orthogonal` proven here are exactly the three ingredients required.

### 2. Convergence to the harmonic projector
Conjecture: for the admissible step `0 < α < 2/λ_max`, the iterate `(mpStep L α)^[k]`
converges entrywise to the orthogonal projector `P` onto `ker L`, with
`‖(mpStep L α)^[k] x − P x‖² ≤ ρᵏ ‖x − P x‖²` where `ρ = 1 − αμ(2 − αλ)`. Falsifiable by a
complex with an eigenvalue outside `(0, 2/α)` exhibiting non-contraction. **The key insight
is** that `quadform_iterate_bound` already gives the geometric rate on the invariant
complement `(ker L)ᗮ`; the only missing step is invariance `mpStep L α '' (ker L)ᗮ ⊆
(ker L)ᗮ`, a one-line consequence of self-adjointness (`fullHodge_isSymm`). **Why now?**
With harmonic signals fixed (`mpStep_iterate_fixes_harmonic`) and the contraction on the
complement quantified, the splitting `id = P + (id − P)` assembles the limit directly from
Mathlib's `Submodule.orthogonalProjection`.

### 3. Tightness of the logarithmic depth
Conjecture: the depth `hodgeDepth ρ ‖x‖² ε = ⌈log_ρ(ε/‖x‖²)⌉` is not merely sufficient but
**tight**: for the bottom non-harmonic eigenvector `v` (energy contracted by *exactly* `ρ`
each layer) every layer below `hodgeDepth − 1` leaves residual `> ε`. Falsifiable by a
complex where strictly fewer layers already reach `ε` on every input. **The key insight is**
that the worst-case input saturates `quadform_iterate_bound` with equality
(`‖Tᵏv‖² = ρᵏ‖v‖²`), so the sufficient bound becomes exact and the ceiling becomes a
genuine minimum. **Why now?** `pow_le_of_logb_le` proven here has an immediate converse
`ρᴺ > c` for `N < log_ρ c` via the same `div_lt_iff_of_neg` lemma, so tightness is a
mechanical mirror of the existing proof.

### 4. Heat-flow continuum limit of the depth clock
Conjecture: the discrete flow `x_{k+1} = x_k − α L x_k` is the explicit Euler scheme of the
Hodge heat equation `ẋ = −L x`; as `α → 0` with `kα = t` fixed, `(mpStep L α)^[k] x →
e^{−tL} x`, and the continuum decay constant equals the spectral gap `μ`. Falsifiable by a
complex whose empirical decay rate differs from its second-smallest Hodge eigenvalue.
**The key insight is** that the contraction factor `1 − αμ(2 − αλ) ≈ 1 − 2αμ` is the
first-order expansion of `e^{−2αμ}`, identifying the discrete logarithmic depth clock
`hodgeDepth` with the continuous heat-kernel half-life `t = log(1/ε)/(2μ)`. **Why now?**
Mathlib's `Matrix.exp` and its derivative API make the Euler-to-exponential limit a
concrete analysis target, and `hodgeDepth` provides the discrete side of the comparison.

### 5. Multi-tolerance depth schedules and adaptive smoothing
Conjecture: for a decreasing tolerance schedule `ε_1 > ε_2 > …`, the *incremental* depths
`hodgeDepth ρ E ε_{j+1} − hodgeDepth ρ E ε_j = ⌈log_ρ(ε_{j+1}/ε_j)⌉` are governed only by
the *ratio* of consecutive tolerances, independent of the signal energy `E`. This predicts
that adaptive smoothing networks should add layers in batches sized by geometric tolerance
ratios. Falsifiable by a regime where required incremental depth depends on `E`. **The key
insight is** that `hodgeDepth` is `⌈log_ρ⌉` of a *quotient*, so energy cancels in
differences, making the depth schedule a pure function of the accuracy ratio. **Why now?**
`hodgeDepth` and `pow_le_of_logb_le` give the closed form; the increment law is a direct
`Real.logb` arithmetic corollary requiring no new analysis.

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
