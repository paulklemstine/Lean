
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

**Title**: The file `Catalog/MachineLearning/HodgeSpectralThreshold.lean` extracts a rigoro
**Domain**: Novelty
**Mathematical framing**: # Future Directions — Spectral Depth Thresholds for Hodge–Laplacian Message Passing

## Synthesis

The file `Catalog/MachineLearning/HodgeSpectralThreshold.lean` extracts a rigorous,
sorry-free linear-algebraic skeleton for *spectral depth thresholds* in higher-order
message passing. The combinatorial Hodge Laplacian `L = Bᵀ B` is realized as a symmetric
positive-semidefinite operator whose Dirichlet energy `⟨x, L x⟩ = ⟨B x, B x⟩` is the
single identity from which everything else flows. Two regimes are made precise and
proven in full:

* **Homotopy-invariant core.** Harmonic cochains — the kernel of `L`, isomorphic by the
  discrete Hodge theorem to a cohomology group — are *exact fixed points* of message
  passing at every depth (`mpStep_iterate_fixes_harmonic`). Topology survives arbitrarily
  deep networks undistorted.
* **Contractive complement.** On energy-carrying signals, one layer contracts the energy
  by the quantitative factor `1 - αμ(2 - αλ)` (`mpStep_contraction`); iterating contracts
  geometrically (`quadform_iterate_bound`), so for any tolerance `ε` only finitely many
  layers are needed (`spectral_depth_threshold`).

The conceptual payload is a unification: message passing is a *discrete deformation
retraction* onto the harmonic (homotopy-invariant) subspace, and "depth" is the
continuous-time parameter of that retraction. This is the Homotopy & Path-Space lens
applied to learning on cell complexes.

## Results summary

| Theorem | Statement |
|---|---|
| `hodge_isSymm` | `Bᵀ B` is symmetric |
| `hodge_quadform` | `⟨x, L x⟩ = ⟨B x, B x⟩` (Dirichlet energy) |
| `hodge_psd` | `L` is positive semidefinite |
| `harmonic_iff_boundary` | discrete Hodge: `L x = 0 ↔ B x = 0` |
| `mpStep_fixes_harmonic` / `..._iterate_...` | harmonic signals fixed at every depth |
| `quadform_mpStep` | exact one-layer energy expansion |
| `mpStep_contraction` | one-layer contraction factor `1 - αμ(2 - αλ)` |
| `quadform_iterate_bound` | geometric energy decay `ρ^k` |
| `spectral_depth_threshold` | finite depth suffices for any tolerance |

All proofs use only `propext`, `Classical.choice`, `Quot.sound`.

## Research directions

### 1. The retraction is a deformation onto the harmonic subspace (orthogonal splitting)
Conjecture: with the admissible step `0 < α < 2/λ_max`, the message-passing flow `mpStep`
restricted to the `⟨·,·⟩`-orthogonal complement of `ker L` is a strict contraction, so
the iterate `(mpStep L α)^[k]` converges to the orthogonal projection `P_ker` onto the
harmonic subspace, and `‖(mpStep L α)^[k] x − P_ker x‖² ≤ (1 − αμ(2 − αλ))^k ‖x − P_ker x‖²`.
This is falsifiable: a single complex with an eigenvalue outside `(0, 2/α)` would exhibit
non-contraction or oscillation. **The key insight is** that `quadform_iterate_bound`
already gives the geometric rate on any invariant subspace, so the missing ingredient is
purely the invariance `mpStep L α '' (ker L)ᗮ ⊆ (ker L)ᗮ`, which follows from self-adjointness
of `L`. **Why now?** The orthogonal projection and `IsSymm`/self-adjoint spectral theorem
for finite real matrices are fully available in Mathlib, so the splitting can be assembled
from existing pieces rather than rebuilt.

### 2. Full Hodge decomposition: down + up Laplacian and the harmonic obstruction
Conjecture: for boundary maps `∂ₖ₊₁ : C_{k+1} → C_k` and `∂ₖ : C_k → C_{k-1}` with
`∂ₖ ∂ₖ₊₁ = 0`, the full Hodge Laplacian `L = ∂ₖ₊₁ ∂ₖ₊₁ᵀ + ∂ₖᵀ ∂ₖ` satisfies
`ker L = ker ∂ₖ ∩ ker ∂ₖ₊₁ᵀ`, and `dim ker L = dim ker ∂ₖ − rank ∂ₖ₊₁` (Betti number).
This refines `harmonic_iff_boundary` from the up-only case to the genuine cohomological
invariant. **The key insight is** that the cross term vanishes exactly when `∂ₖ ∂ₖ₊₁ = 0`,
turning the two energies into an orthogonal sum so harmonicity decouples into "closed" and
"coclosed". **Why now?** The up-Laplacian quadratic-form machinery in this file transfers
verbatim to each summand; the only new lemma is the orthogonality of the two images,
which is a one-line `∂∂ = 0` consequence.

### 3. Depth–accuracy trade-off is logarithmic and tight
Conjecture: the minimal depth `N(ε)` from `spectral_depth_threshold` satisfies
`N(ε) = ⌈ log(ε / ‖x‖²) / log ρ ⌉` with `ρ = 1 − αμ(2 − αλ)`, and this bound is tight:
there exists an input (the bottom non-harmonic eigenvector) achieving equality. Falsifiable
by exhibiting a complex where fewer layers already reach `ε`. **The key insight is** that
the worst-case input saturates every inequality in `quadform_iterate_bound` simultaneously,
so the geometric bound is not merely sufficient but exact on the spectral edge. **Why now?**
`Real.logb` and the monotonicity lemmas for `ρ^k` used in `spectral_depth_threshold` make
the explicit `⌈log⌉` formula a direct corollary.

### 4. Oversmoothing as collapse of the path space of signals
Conjecture: define the "signal path space" as the set of trajectories `k ↦ (mpStep L α)^[k] x`;
then as `k → ∞` every path is homotopic (through the linear deformation `t ↦ x − tα L x`,
`t ∈ [0,1]`) to the constant path at `P_ker x`, and the diameter of the reachable set
shrinks like `ρ^k`. Oversmoothing is precisely this collapse of the path space to its
homotopy-invariant core. **The key insight is** that the contraction factor `ρ` bounds the
diameter of the orbit, so the fundamental groupoid of the signal flow degenerates to a
point set indexed by harmonic classes. **Why now?** With the geometric decay already
formalized, the only remaining step is to phrase the orbit diameter bound, which reuses
`quadform_iterate_bound` directly.

### 5. Heat-flow continuum limit and the spectral-gap eigenvalue
Conjecture: the discrete flow `x_{k+1} = x_k − α L x_k` is the explicit Euler scheme of the
Hodge heat equation `ẋ = −L x`; as `α → 0` with `kα = t` fixed, `(mpStep L α)^[k] x → e^{−tL} x`,
and the asymptotic decay constant equals the spectral gap `μ = λ_min(L | (ker L)ᗮ)`. Falsifiable
by a complex whose empirical decay rate differs from its second-smallest Hodge eigenvalue.
**The key insight is** that `mpStep_contraction`'s factor `1 − αμ(2 − αλ) ≈ 1 − 2αμ` matches
the first-order expansion of `e^{−2αμ}`, identifying the discrete contraction rate with the
continuous heat-kernel rate. **Why now?** Mathlib's matrix exponential `Matrix.exp` and its
derivative API are in place, so the Euler-to-exponential limit is a concrete (if technical)
analysis target rather than new theory.

**Concept description**: # Future Directions — Spectral Depth Thresholds for Hodge–Laplacian Message Passing

## Synthesis

The file `Catalog/MachineLearning/HodgeSpectralThreshold.lean` extracts a rigorous,
sorry-free linear-algebraic skeleton for *spectral depth thresholds* in higher-order
message passing. The combinatorial Hodge Laplacian `L = Bᵀ B` is realized as a symmetric
positive-semidefinite operator whose Dirichlet energy `⟨x, L x⟩ = ⟨B x, B x⟩` is the
single identity from which everything else flows. Two regimes are made precise and
proven in full:

* **Homotopy-invariant core.** Harmonic cochains — the kernel of `L`, isomorphic by the
  discrete Hodge theorem to a cohomology group — are *exact fixed points* of message
  passing at every depth (`mpStep_iterate_fixes_harmonic`). Topology survives arbitrarily
  deep networks undistorted.
* **Contractive complement.** On energy-carrying signals, one layer contracts the energy
  by the quantitative factor `1 - αμ(2 - αλ)` (`mpStep_contraction`); iterating contracts
  geometrically (`quadform_iterate_bound`), so for any tolerance `ε` only finitely many
  layers are needed (`spectral_depth_threshold`).

The conceptual payload is a unification: message passing is a *discrete deformation
retraction* onto the harmonic (homotopy-invariant) subspace, and "depth" is the
continuous-time parameter of that retraction. This is the Homotopy & Path-Space lens
applied to learning on cell complexes.

## Results summary

| Theorem | Statement |
|---|---|
| `hodge_isSymm` | `Bᵀ B` is symmetric |
| `hodge_quadform` | `⟨x, L x⟩ = ⟨B x, B x⟩` (Dirichlet energy) |
| `hodge_psd` | `L` is positive semidefinite |
| `harmonic_iff_boundary` | discrete Hodge: `L x = 0 ↔ B x = 0` |
| `mpStep_fixes_harmonic` / `..._iterate_...` | harmonic signals fixed at every depth |
| `quadform_mpStep` | exact one-layer energy expansion |
| `mpStep_contraction` | one-layer contraction factor `1 - αμ(2 - αλ)` |
| `quadform_iterate_bound` | geometric energy decay `ρ^k` |
| `spectral_depth_threshold` | finite depth suffices for any tolerance |

All proofs use only `propext`, `Classical.choice`, `Quot.sound`.

## Research directions

### 1. The retraction is a deformation onto the harmonic subspace (orthogonal splitting)
Conjecture: with the admissible step `0 < α < 2/λ_max`, the message-passing flow `mpStep`
restricted to the `⟨·,·⟩`-orthogonal complement of `ker L` is a strict contraction, so
the iterate `(mpStep L α)^[k]` converges to the orthogonal projection `P_ker` onto the
harmonic subspace, and `‖(mpStep L α)^[k] x − P_ker x‖² ≤ (1 − αμ(2 − αλ))^k ‖x − P_ker x‖²`.
This is falsifiable: a single complex with an eigenvalue outside `(0, 2/α)` would exhibit
non-contraction or oscillation. **The key insight is** that `quadform_iterate_bound`
already gives the geometric rate on any invariant subspace, so the missing ingredient is
purely the invariance `mpStep L α '' (ker L)ᗮ ⊆ (ker L)ᗮ`, which follows from self-adjointness
of `L`. **Why now?** The orthogonal projection and `IsSymm`/self-adjoint spectral theorem
for finite real matrices are fully available in Mathlib, so the splitting can be assembled
from existing pieces rather than rebuilt.

### 2. Full Hodge decomposition: down + up Laplacian and the harmonic obstruction
Conjecture: for boundary maps `∂ₖ₊₁ : C_{k+1} → C_k` and `∂ₖ : C_k → C_{k-1}` with
`∂ₖ ∂ₖ₊₁ = 0`, the full Hodge Laplacian `L = ∂ₖ₊₁ ∂ₖ₊₁ᵀ + ∂ₖᵀ ∂ₖ` satisfies
`ker L = ker ∂ₖ ∩ ker ∂ₖ₊₁ᵀ`, and `dim ker L = dim ker ∂ₖ − rank ∂ₖ₊₁` (Betti number).
This refines `harmonic_iff_boundary` from the up-only case to the genuine cohomological
invariant. **The key insight is** that the cross term vanishes exactly when `∂ₖ ∂ₖ₊₁ = 0`,
turning the two energies into an orthogonal sum so harmonicity decouples into "closed" and
"coclosed". **Why now?** The up-Laplacian quadratic-form machinery in this file transfers
verbatim to each summand; the only new lemma is the orthogonality of the two images,
which is a one-line `∂∂ = 0` consequence.

### 3. Depth–accuracy trade-off is logarithmic and tight
Conjecture: the minimal depth `N(ε)` from `spectral_depth_threshold` satisfies
`N(ε) = ⌈ log(ε / ‖x‖²) / log ρ ⌉` with `ρ = 1 − αμ(2 − αλ)`, and this bound is tight:
there exists an input (the bottom non-harmonic eigenvector) achieving equality. Falsifiable
by exhibiting a complex where fewer layers already reach `ε`. **The key insight is** that
the worst-case input saturates every inequality in `quadform_iterate_bound` simultaneously,
so the geometric bound is not merely sufficient but exact on the spectral edge. **Why now?**
`Real.logb` and the monotonicity lemmas for `ρ^k` used in `spectral_depth_threshold` make
the explicit `⌈log⌉` formula a direct corollary.

### 4. Oversmoothing as collapse of the path space of signals
Conjecture: define the "signal path space" as the set of trajectories `k ↦ (mpStep L α)^[k] x`;
then as `k → ∞` every path is homotopic (through the linear deformation `t ↦ x − tα L x`,
`t ∈ [0,1]`) to the constant path at `P_ker x`, and the diameter of the reachable set
shrinks like `ρ^k`. Oversmoothing is precisely this collapse of the path space to its
homotopy-invariant core. **The key insight is** that the contraction factor `ρ` bounds the
diameter of the orbit, so the fundamental groupoid of the signal flow degenerates to a
point set indexed by harmonic classes. **Why now?** With the geometric decay already
formalized, the only remaining step is to phrase the orbit diameter bound, which reuses
`quadform_iterate_bound` directly.

### 5. Heat-flow continuum limit and the spectral-gap eigenvalue
Conjecture: the discrete flow `x_{k+1} = x_k − α L x_k` is the explicit Euler scheme of the
Hodge heat equation `ẋ = −L x`; as `α → 0` with `kα = t` fixed, `(mpStep L α)^[k] x → e^{−tL} x`,
and the asymptotic decay constant equals the spectral gap `μ = λ_min(L | (ker L)ᗮ)`. Falsifiable
by a complex whose empirical decay rate differs from its second-smallest Hodge eigenvalue.
**The key insight is** that `mpStep_contraction`'s factor `1 − αμ(2 − αλ) ≈ 1 − 2αμ` matches
the first-order expansion of `e^{−2αμ}`, identifying the discrete contraction rate with the
continuous heat-kernel rate. **Why now?** Mathlib's matrix exponential `Matrix.exp` and its
derivative API are in place, so the Euler-to-exponential limit is a concrete (if technical)
analysis target rather than new theory.

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
