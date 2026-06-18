
## PHASE B: PACKAGING ONLY — COMMUNICATING THE MATH

Phase A of this cycle has already done the math. Lean 4 files have
been produced with 3-5 world-class theorems. Your ONLY job in
Phase B is to **package this work for human readers**.

### DELIVERABLES (strict — only this):
1. **ARTICLE.md** — Standalone popular-science article (1500-3000 words).
   Write about IDEAS, not formal verification. No mentions of Lean or
   proof assistants. Vivid prose, narrative arc, real-world connections.
   **Must be fully self-contained and publishable without any external
   references.** State every theorem, result, and definition inline —
   do NOT use @file references or point to other files. A reader with
   only this article must understand every result without looking elsewhere.
2. **RESEARCH_PAPER.md** — In-depth research paper (3000-8000 words).
   Abstract, definitions, main results (with proof sketches — NOT
   full Lean), algorithms, applications, discussion, future work.
   **Must be fully self-contained and publishable quality without any
   external references.** State every theorem, lemma, and definition
   inline with its full mathematical statement and proof sketch. Do NOT
   use @file references or reference other files. A reader with only this
   paper must be able to follow every result from start to finish.
3. **demo.py** — Numerical examples demonstrating the key results.
   Self-contained Python, type hints, all functions inlined.
4. **PACKAGE.json** — Single JSON bundling all of the above, with this schema:

```json
{
  "title": "Human-Readable Package Title",
  "domain": "Algebra|Applications|Bridges|Computation|Cryptography|EML|Geometry|Logic|MachineLearning|Novelty|Physics|Pythagorean|Shared|Tropical",
  "description": "1-2 sentence description of the package",
  "authors": ["Author Name"],
  "date": "YYYY-MM-DD",
  "key_results": ["Key result 1", "Key result 2"],
  "keywords": ["keyword1", "keyword2"],
  "article": "ARTICLE.md",
  "research_paper": "RESEARCH_PAPER.md",
  "demo": "demo.py",
  "demos": [
    {"name": "Descriptive and Professional Title of the Python Demo", "description": "A comprehensive, high-quality description of what this Python demo calculates and shows mathematically.", "code": "# full Python source..."}
  ],
  "algorithms": [
    {
      "name": "Formal Mathematical Title of the Algorithm",
      "description": "Detailed in-depth explanation of the algorithm, its mathematical foundation, computational complexity, and role in the pipeline.",
      "pseudocode": "Formal, structured step-by-step pseudocode detailing the logic.",
      "code": "# full Python source with type hints..."
    }
  ],
  "visualizations": [
    {"name": "Descriptive Visualization Title", "description": "What this visualizes", "code": "# standalone Python script that generates a visualization..."}
  ],
  "interactive_demos": [
    {"title": "Beautiful Math-Rich Interactive Widget Title", "description": "Detailed description of the interactive widget and what users can explore.", "html": "<!DOCTYPE html><html>...</html>"}
  ],
  "lean_proofs": "LEAN_FILE_CONTENT_OR_PLACEHOLDER",
  "future_directions": "FUTURE_DIRECTIONS_CONTENT",
  "modules": {"demo": "# full demo.py source..."},
  "lean_files": ["Catalog/Domain/Package/File.lean"]
}
```

**CRITICAL**: The `demos`, `algorithms`, `visualizations`, and
`interactive_demos` fields MUST be arrays of objects with the
exact structure shown above. Do NOT use placeholder strings like
"MISSING" — either include real content or omit the field entirely.

### DO NOT OUTPUT:
- NO new `.lean` files
- NO new theorem proofs
- NO changes to the existing Lean 4 source
- NO `FUTURE_DIRECTIONS.md` as a separate file (Phase A already produced
  future directions — they are provided below for inclusion in PACKAGE.json)

The math is already proved. Treat the Lean files below as the
ground truth — your prose should explain and contextualize them.
State theorems inline in your article and paper — they must be
self-contained and publishable without external references.


## Concept

**Title**: This cycle (`Catalog/Speculative/AutoResearch/HodgeFilterDynamics.lean`) sharpen
**Domain**: Novelty
**Mathematical framing**: # Future Directions — Hodge–Laplacian Message Passing: Exact Mode Dynamics & Polynomial Filters

## Synthesis

This cycle (`Catalog/Speculative/AutoResearch/HodgeFilterDynamics.lean`) sharpens the
convergence theory of `HodgeMessagePassingConvergence.lean` along two of that file's
declared research directions, turning a one-sided picture into a two-sided one and
generalizing a single gradient step into an entire family of spectral filters.

The previous strand established that one layer of gradient message passing
`mpStep L α = 1 - α·L` is a linear operator that fixes the harmonic subspace `ker L`
and contracts the residual energy by a factor `ρ`, giving the *upper* bound
`ρᵏ⟪r,r⟫` on the distance from the depth-`k` output to the cohomology (harmonic)
part. Two questions were left open: is that bound *attained* (is the spectral rate
necessary, not merely sufficient?), and does the whole scaffolding survive when the
single step is replaced by the higher-order/Chebyshev filters used in spectral GNNs?

We answer both affirmatively and constructively.

**Exactness on a mode.** On a genuine eigenvector `L v = ν·v`, message passing *is*
scalar multiplication: `mpStep L α v = (1 − αν)·v` (`mpStep_eigenvector`), so depth
`k` produces the closed-form orbit `(1 − αν)ᵏ·v` (`mpStep_iterate_eigenvector`) and
the energy is *exactly* `(1 − αν)^{2k}⟪v,v⟫` (`mpStep_iterate_eigenvector_energy`).
Specializing to the slowest nonzero mode `ν = μ`, whose harmonic component is `0`,
the distance-to-harmonic energy equals `σᵏ⟪v,v⟫` with `σ = (1 − αμ)²`
(`oversmoothing_exact`) — an equality matching the convergence cycle's inequality
shape, so the geometric rate is tight. The inequality `< ε` then *forces*
`σᵏ < ε/⟪v,v⟫` (`oversmoothing_depth_necessary`): reaching tolerance on the slowest
mode requires logarithmic depth. This is the quantitative oversmoothing lower bound
of the parent file's Direction 5.

**Polynomial filters.** A degree-`m` filter is a product of gradient steps
`∏ᵢ (1 − αᵢ·L)`, i.e. a polynomial `p(L)` with `p(0) = 1`. We model it as
`mpFilter L αs` — the `List.prod` (composition) of `mpStep`s in `Module.End ℝ E` —
and show the structural lemmas transfer verbatim: harmonics remain exact fixed points
(`mpFilter_harmonic_fixed`), and on an eigenvector the filter acts as the scalar
`∏ᵢ (1 − αᵢν) = p(ν)` (`mpFilter_eigenvector`), with energy scaled by `p(ν)²`
(`mpFilter_eigenvector_energy`). The degree-2 (heavy-ball) case is the explicit
quadratic in `L`, `1 − (α+β)L + αβ L²` (`mpStep_comp_eq`), exhibiting `mpFilter` as a
genuine polynomial of the operator. This realizes the parent file's Direction 3.

The upshot: **the spectral gap is not just an upper bound on the convergence rate but
the exact rate on the extremal mode, and the entire linear-operator/harmonic-fixing
calculus is invariant under passing from a single gradient step to any
`p(0) = 1` polynomial filter — so Chebyshev acceleration is a scalar optimization on
`[μ, λ]`, with the operator-level bookkeeping already discharged.**

## Results Summary (all sorry-free; axioms: `propext`, `Classical.choice`, `Quot.sound`)

- `mpStep_eigenvector` — one layer acts as `(1 − αν)·` on an eigenvector.
- `mpStep_iterate_eigenvector` — depth-`k` orbit is `(1 − αν)ᵏ·v` in closed form.
- `mpStep_iterate_eigenvector_energy` — exact energy `(1 − αν)^{2k}⟪v,v⟫`.
- `oversmoothing_exact` — distance-to-harmonic energy equals `σᵏ⟪v,v⟫`, `σ = (1−αμ)²`
  (matching lower bound: the convergence-cycle upper bound is attained).
- `oversmoothing_depth_necessary` — sub-tolerance on the slowest mode forces
  `σᵏ < ε/⟪v,v⟫` (logarithmic depth is necessary).
- `mpFilter` — degree-`|αs|` polynomial filter `∏(1 − αᵢL)` as a `List.prod` of steps.
- `mpFilter_harmonic_fixed` — every `p(0)=1` filter fixes harmonics exactly.
- `mpFilter_eigenvector` — a filter acts on an eigenvector as the scalar `p(ν)`.
- `mpFilter_eigenvector_energy` — eigenvector energy scaled by `p(ν)²`.
- `mpStep_comp_eq` — heavy-ball filter is the explicit quadratic `1 − (α+β)L + αβL²`.

## Research Directions

### 1. Two-sided convergence: an exact `Θ(log(1/ε)/log(1/ρ))` depth law.

We proved both an upper bound (parent file) and a lower bound (`oversmoothing_exact`,
`oversmoothing_depth_necessary`) on the slowest-mode energy. The next step is to fuse
them into a single closed-form depth law: the smallest depth `k` with residual energy
below `ε` is exactly `⌈log(⟪v,v⟫/ε) / log(1/σ)⌉` on the extremal mode, and lies
between the harmonic-and-extremal-mode bounds for a general input. **The key insight
is** that on the slowest mode the iterate is a *geometric sequence*, so the depth
threshold is not an estimate but an exact ceiling of a logarithm, with no
inequality slack. **Why now?** `oversmoothing_exact` already gives the exact energy
`σᵏ⟪v,v⟫`; the only remaining ingredient is Mathlib's `Real.logb`/`Nat.ceil`
monotonicity to invert the geometric law, turning the one-line division of
`oversmoothing_depth_necessary` into a sharp two-sided count.

### 2. Chebyshev optimality of the degree-`m` polynomial filter.

`mpFilter_eigenvector` shows a filter acts on `[μ, λ]` as the scalar polynomial
`p(ν) = ∏(1 − αᵢν)` with `p(0) = 1`. The falsifiable conjecture: the worst-case
contraction `maxₙ∈[μ,λ] |p(ν)|` is minimized by the shifted Chebyshev polynomial, with
optimal value `ρ_m = ((√λ − √μ)/(√λ + √μ))^m / Tₘ((λ+μ)/(λ−μ))`, a quadratic depth
speedup over the plain rate `(1 − μ/λ)`. **The key insight is** that the operator-level
work is finished — every filter is `mpFilter L αs` and acts modewise as `p(ν)` — so the
problem collapses to the classical real-analysis extremal problem for monic-normalized
polynomials on an interval. **Why now?** With `mpStep_comp_eq` exhibiting the `m = 2`
filter as `1 − (α+β)L + αβL²`, the heavy-ball case `min_{α,β} max_{[μ,λ]} |1 − (α+β)ν +
αβν²|` is a two-variable optimization that `nlinarith`/`polyrith` can attack directly,
validating the pattern before the general Chebyshev bound.

### 3. The limit is the orthogonal projection onto `ker L`.

`oversmoothing_exact` identifies the harmonic limit on a single mode, but the global
limit of `(mpStep L α)ᵏ x` for arbitrary `x` should be `orthogonalProjection (ker L) x`,
a basis-free topological invariant. The conjecture: under the contraction hypothesis,
`(mpStep L α)ᵏ x → orthogonalProjection (ker L) x` in norm. **The key insight is** that
`mpStep_iterate_add_harmonic` already splits `x = h + r` with `h` fixed and `r`
contracted, and for symmetric PSD `L` the residual `r` lives in `(ker L)ᗮ = range L`, so
the split is *the* orthogonal decomposition and uniqueness forces `h = proj x`. **Why
now?** `HodgeThreeWayDecomposition` supplies `(ker d)ᗮ = range d*` and the orthogonal
projection API; combined with `oversmoothing_exact`'s exact modewise control, the only
new content is `Submodule.orthogonalProjection` bookkeeping over the existing
inner-product layer.

### 4. Unconditional contraction for `L = BᵀB` via the spectral theorem.

The convergence pipeline assumes the per-layer contraction `⟪Tx,Tx⟫ ≤ ρ⟪x,x⟫`. For a
concrete coboundary `L = BᵀB`, this should be a theorem, not a hypothesis: with `μ` the
smallest nonzero eigenvalue and `λ` the largest, every step `α ∈ (0, 2/λ)` yields
`ρ = 1 − αμ(2 − αλ) < 1` on `(ker L)ᗮ`. **The key insight is** that
`mpFilter_eigenvector`/`mpStep_eigenvector` already give the *exact* action on each
eigenvector, so on an eigenbasis the contraction is the scalar fact
`(1 − αν)² ≤ ρ` for `ν ∈ [μ, λ]` — no operator inequalities remain. **Why now?**
Mathlib's `LinearMap.IsSymmetric.spectral_theorem`/eigenbasis decomposition expands any
`x ∈ (ker L)ᗮ` in eigenvectors, and our modewise energy lemma
`mpStep_iterate_eigenvector_energy` sums termwise to the global bound, making the whole
pipeline unconditional for concrete `B`.

### 5. Full Hodge Laplacian `Δ = d*d + e e*` and simultaneous exact/coexact decay.

We worked with a single symmetric PSD operator `L`. The conjecture: every result of
`HodgeFilterDynamics` holds verbatim for the full Hodge Laplacian `Δ` of
`HodgeThreeWayDecomposition`, with the limit being the projection onto `ker Δ` (the
Betti space) and the rate set by the smallest nonzero eigenvalue of `Δ`, while the
residual's exact and coexact parts are contracted *simultaneously*. **The key insight
is** that `Δ` is again symmetric PSD with `ker Δ = ker d ⊓ ker e*` fixed by `1 − αΔ`,
so `mpStep_eigenvector` and `mpFilter_harmonic_fixed` apply unchanged once `Δ` replaces
`L`. **Why now?** `hodgeLaplacian`, `harmonic_iff`, and the cross-file bridge
`hodge_harmonic_mpStep_fixed` are already proven, so the harmonic-fixing step is
immediate and only the spectral bounds for `Δ` — supplied by Direction 4's eigenbasis —
remain to make convergence-to-cohomology fully unconditional.

Research domain: Novelty
Research mode: team


## Phase A Lean 4 Output (the math — read this carefully)

```
-- NEW_FILE: Catalog/Speculative/AutoResearch/HodgeFilterDynamics.lean
/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license.

# Hodge–Laplacian Message Passing: Exact Mode Dynamics & Polynomial Filters

This file *sharpens* the convergence theory of
`Catalog/Speculative/AutoResearch/HodgeMessagePassingConvergence.lean`
(`mpStep`, `mpStep_apply`, `mpStep_smul`, `mpStep_harmonic_fixed`,
`mpStep_iterate_harmonic_fixed`, `mpStep_iterate_contraction`,
`contraction_factor_optimal`) along two of its declared research directions:

1.  **Exactness on a spectral mode.**  The parent file proved a one-sided *upper*
    bound `ρᵏ⟪r,r⟫` on the distance-to-harmonic energy.  Here we show that on a
    genuine eigenvector `L v = ν•v`, message passing *is* scalar multiplication
    `mpStep L α v = (1 − αν)•v` (`mpStep_eigenvector`), so the depth-`k` orbit is the
    closed form `(1 − αν)ᵏ•v` (`mpStep_iterate_eigenvector`) with *exact* energy
    `(1 − αν)^{2k}⟪v,v⟫` (`mpStep_iterate_eigenvector_energy`).  On the slowest
    nonzero mode `ν = μ` this is `σᵏ⟪v,v⟫` with `σ = (1 − αμ)²`
    (`oversmoothing_exact`): the parent's inequality is *attained*, and reaching a
    tolerance `ε` *forces* `σᵏ < ε/⟪v,v⟫` (`oversmoothing_depth_necessary`) — a
    quantitative oversmoothing lower bound (logarithmic depth is necessary).

2.  **Polynomial (Chebyshev-type) filters.**  A degree-`m` filter is a product of
    gradient steps `∏ᵢ (1 − αᵢ·L)`, i.e. a polynomial `p(L)` with `p(0) = 1`.  We
    model it as `mpFilter L αs`, the `List.prod` (composition) of `mpStep`s in
    `Module.End ℝ E`, and show the whole structural calculus transfers verbatim:
    harmonics stay exact fixed points (`mpFilter_harmonic_fixed`), a filter acts on
    an eigenvector as the scalar `∏ᵢ (1 − αᵢν) = p(ν)` (`mpFilter_eigenvector`) and
    scales energy by `p(ν)²` (`mpFilter_eigenvector_energy`).  The degree-2
    (heavy-ball) filter is the explicit quadratic `1 − (α+β)L + αβ·L²`
    (`mpStep_comp_eq`), exhibiting `mpFilter` as a genuine polynomial of `L`.

The upshot: **the spectral gap is the exact rate on the extremal mode, and the
linear-operator / harmonic-fixing calculus is invariant under passing from a single
gradient step to any `p(0) = 1` polynomial filter.**

-- !-- Lab Notebook -- !--
Hypothesis:  Because `mpStep L α = 1 − α•L` is linear and `L v = ν•v` makes `L` act
  as the scalar `ν` on the line `ℝ•v`, the layer must act as the scalar `(1 − αν)` on
  that line; iterating gives a geometric orbit and *equality* (not just an upper
  bound) for the energy.  Composing steps (a polynomial filter) then acts as the
  product `∏(1 − αᵢν) = p(ν)`, and harmonics (`ν = 0` direction, `L h = 0`) are fixed
  by every factor.
Result:  Formalised and proved sorry-free.  `mpStep_eigenvector`,
  `mpStep_iterate_eigenvector`, `mpStep_iterate_eigenvector_energy`,
  `oversmoothing_exact`, `oversmoothing_depth_necessary`, `mpFilter`,
  `mpFilter_harmonic_fixed`, `mpFilter_eigenvector`, `mpFilter_eigenvector_energy`,
  `mpStep_comp_eq`.
Insight:  Modeling a filter as `(αs.map (mpStep L)).prod` in the *monoid* `Module.End
  ℝ E` makes the cons-step of every induction `LinearMap.mul_apply` + linearity of a
  single `mpStep`, so the eigenvector and harmonic lemmas are one clean induction
  each.  Energy equalities reduce to `inner_smul_left`/`inner_smul_right` and the
  identity `c^k·c^k = c^{2k}`.
Failure analysis:  Stating the orbit with `L v = ν•v` (an honest eigenvector) rather
  than the abstract contraction hypothesis is what turns the parent file's `≤` into
  `=`; the slowest-mode specialization `ν = μ` is then a one-line `pow_mul` rewrite
  `(1 − αμ)^{2k} = ((1 − αμ)²)^k`.
-- !-- Lab Notebook -- !--
-/
import Mathlib
import Speculative.AutoResearch.HodgeMessagePassingConvergence

open scoped InnerProductSpace BigOperators Topology

namespace HodgeFilterDynamics

open HodgeMessagePassingConvergence

variable {E : Type*} [NormedAddCommGroup E] [InnerProductSpace ℝ E]

/-! ## Exact action on a spectral mode -/

/-
!-- One layer of message passing acts on an eigenvector `L v = ν•v` as the
scalar `(1 − αν)`: `mpStep L α v = (1 − αν)•v`. -- !--
-/
theorem mpStep_eigenvector (L : E →ₗ[ℝ] E) (α ν : ℝ) {v : E} (hv : L v = ν • v) :
    mpStep L α v = (1 - α * ν) • v := by
  simp [mpStep, hv, smul_smul];
  rw [ sub_smul, one_smul ]

/-
!-- Depth-`k` message passing on an eigenvector is the closed-form geometric
orbit `(1 − αν)ᵏ•v` (induction via `mpStep_eigenvector` and linearity). -- !--
-/
theorem mpStep_iterate_eigenvector (L : E →ₗ[ℝ] E) (α ν : ℝ) {v : E}
    (hv : L v = ν • v) (k : ℕ) :
    ((mpStep L α) ^ k) v = (1 - α * ν) ^ k • v := by
  induction k <;> simp_all +decide [ pow_succ, mul_assoc, smul_smul ];
  rw [ ← sub_smul ] ; ring

/-
!-- The energy of the depth-`k` eigenmode orbit is *exactly* `(1 − αν)^{2k}⟪v,v⟫`
(from the closed form and `inner_smul_left`/`inner_smul_right`). -- !--
-/
theorem mpStep_iterate_eigenvector_energy (L : E →ₗ[ℝ] E) (α ν : ℝ) {v : E}
    (hv : L v = ν • v) (k : ℕ) :
    ⟪((mpStep L α) ^ k) v, ((mpStep L α) ^ k) v⟫_ℝ
      = (1 - α * ν) ^ (2 * k) * ⟪v, v⟫_ℝ := by
  rw [ mpStep_iterate_eigenvector L α ν hv k ];
  rw [ real_inner_smul_left, real_inner_smul_right ] ; ring

/-! ## Tight oversmoothing on the slowest nonzero mode -/

/-
!-- On the slowest nonzero mode `L v = μ•v` (harmonic component `0`), the
distance-to-harmonic energy equals `σᵏ⟪v,v⟫` with `σ = (1 − αμ)²`: the parent file's
upper bound is *attained* (`pow_mul` rewrite of `mpStep_iterate_eigenvector_energy`). -- !--
-/
theorem oversmoothing_exact (L : E →ₗ[ℝ] E) (α μ : ℝ) {v : E} (hv : L v = μ • v)
    (k : ℕ) :
    ⟪((mpStep L α) ^ k) v, ((mpStep L α) ^ k) v⟫_ℝ
      = ((1 - α * μ) ^ 2) ^ k * ⟪v, v⟫_ℝ := by
  rw [ mpStep_iterate_eigenvector_energy L α μ hv k, pow_mul ]

/-
!-- Reaching tolerance `ε` on the slowest mode forces `σᵏ < ε/⟪v,v⟫`
(`σ = (1 − αμ)²`): logarithmic depth is necessary.  Divide the exact equality
`oversmoothing_exact` by `⟪v,v⟫ > 0`. -- !--
-/
theorem oversmoothing_depth_necessary (L : E →ₗ[ℝ] E) (α μ : ℝ) {v : E}
    (hv : L v = μ • v) (hv0 : 0 < ⟪v, v⟫_ℝ) {ε : ℝ} (k : ℕ)
    (hk : ⟪((mpStep L α) ^ k) v, ((mpStep L α) ^ k) v⟫_ℝ < ε) :
    ((1 - α * μ) ^ 2) ^ k < ε / ⟪v, v⟫_ℝ := by
  exact lt_div_iff₀ hv0 |>.2 ( by linarith [ oversmoothing_exact L α μ hv k ] )

/-! ## Polynomial (Chebyshev-type) filters -/

/-- A degree-`|αs|` polynomial filter `∏ᵢ (1 − αᵢ·L)`, modeled as the `List.prod`
(composition) of single gradient steps in the monoid `Module.End ℝ E`. -/
def mpFilter (L : E →ₗ[ℝ] E) (αs : List ℝ) : Module.End ℝ E :=
  (αs.map (mpStep L)).prod

@[simp] theorem mpFilter_nil (L : E →ₗ[ℝ] E) : mpFilter L [] = 1 := by
  simp [mpFilter]

@[simp] theorem mpFilter_cons (L : E →ₗ[ℝ] E) (a : ℝ) (αs : List ℝ) :
    mpFilter L (a :: αs) = mpStep L a * mpFilter L αs := by
  simp [mpFilter]

/-
!-- Every `p(0)=1` polynomial filter fixes harmonics exactly: if `L h = 0`,
each factor `mpStep L aᵢ` fixes `h` (`mpStep_harmonic_fixed`), so their composition
does too (induction on `αs`). -- !--
-/
theorem mpFilter_harmonic_fixed (L : E →ₗ[ℝ] E) (αs : List ℝ) {h : E}
    (hh : L h = 0) :
    mpFilter L αs h = h := by
  induction' αs with a αs ih <;> simp_all +decide [ mpFilter ]

/-
!-- A filter acts on an eigenvector `L v = ν•v` as the scalar polynomial
`p(ν) = ∏ᵢ (1 − αᵢν)`: induction on `αs` using `mpStep_eigenvector` and linearity. -- !--
-/
theorem mpFilter_eigenvector (L : E →ₗ[ℝ] E) (αs : List ℝ) (ν : ℝ) {v : E}
    (hv : L v = ν • v) :
    mpFilter L αs v = (αs.map (fun a => 1 - a * ν)).prod • v := by
  induction' αs with a αs ih generalizing v <;> simp_all +decide [ mpFilter, List.prod_cons, List.map_cons ];
  module

/-
!-- A filter scales eigenvector energy by `p(ν)²` with `p(ν) = ∏ᵢ (1 − αᵢν)`
(`mpFilter_eigenvector` then `inner_smul_left`/`inner_smul_right`). -- !--
-/
theorem mpFilter_eigenvector_energy (L : E →ₗ[ℝ] E) (αs : List ℝ) (ν : ℝ) {v : E}
    (hv : L v 
```

## Phase A Future Directions (include in PACKAGE.json)

Phase A produced these future research directions. Include them verbatim
(or lightly edited for clarity) in the `future_directions` field of
PACKAGE.json so they appear in the "Future Directions" tab on the website.

```
# Future Directions — Hodge–Laplacian Message Passing: Exact Mode Dynamics & Polynomial Filters

## Synthesis

This cycle (`Catalog/Speculative/AutoResearch/HodgeFilterDynamics.lean`) sharpens the
convergence theory of `HodgeMessagePassingConvergence.lean` along two of that file's
declared research directions, turning a one-sided picture into a two-sided one and
generalizing a single gradient step into an entire family of spectral filters.

The previous strand established that one layer of gradient message passing
`mpStep L α = 1 − α·L` is a linear operator that fixes the harmonic subspace `ker L`
and contracts the residual energy by a factor `ρ`, giving the *upper* bound `ρᵏ⟪r,r⟫`
on the distance from the depth-`k` output to the cohomology (harmonic) part. Two
questions were left open: is that bound *attained* (is the spectral rate necessary, not
merely sufficient?), and does the whole scaffolding survive when the single step is
replaced by the higher-order/Chebyshev filters used in spectral GNNs?

We answer both affirmatively and constructively.

**Exactness on a mode.** On a genuine eigenvector `L v = ν·v`, message passing *is*
scalar multiplication: `mpStep L α v = (1 − αν)·v` (`mpStep_eigenvector`), so depth `k`
produces the closed-form orbit `(1 − αν)ᵏ·v` (`mpStep_iterate_eigenvector`) and the
energy is *exactly* `(1 − αν)^{2k}⟪v,v⟫` (`mpStep_iterate_eigenvector_energy`).
Specializing to the slowest nonzero mode `ν = μ`, the distance-to-harmonic energy
equals `σᵏ⟪v,v⟫` with `σ = (1 − αμ)²` (`oversmoothing_exact`) — an equality matching the
convergence cycle's inequality shape, so the geometric rate is tight. The inequality
`< ε` then *forces* `σᵏ < ε/⟪v,v⟫` (`oversmoothing_depth_necessary`): reaching tolerance
on the slowest mode requires logarithmic depth.

**Polynomial filters.** A degree-`m` filter is a product of gradient steps
`∏ᵢ (1 − αᵢ·L)`, i.e. a polynomial `p(L)` with `p(0) = 1`. We model it as
`mpFilter L αs` — the `List.prod` (composition) of `mpStep`s in `Module.End ℝ E` — and
show the structural lemmas transfer verbatim: harmonics remain exact fixed points
(`mpFilter_harmonic_fixed`), and on an eigenvector the filter acts as the scalar
`∏ᵢ (1 − αᵢν) = p(ν)` (`mpFilter_eigenvector`), with energy scaled by `p(ν)²`
(`mpFilter_eigenvector_energy`). The degree-2 (heavy-ball) case is the explicit
quadratic in `L`, `1 − (α+β)L + αβ·L²` (`mpStep_comp_eq`), exhibiting `mpFilter` as a
genuine polynomial of the operator.

The upshot: **the spectral gap is not just an upper bound on the convergence rate but
the exact rate on the extremal mode, and the entire linear-operator/harmonic-fixing
calculus is invariant under passing from a single gradient step to any `p(0) = 1`
polynomial filter — so Chebyshev acceleration is a scalar optimization on `[μ, λ]`, with
the operator-level bookkeeping already discharged.**

## Results Summary (all sorry-free; axioms: `propext`, `Classical.choice`, `Quot.sound`)

- `mpStep_eigenvector` — one layer acts 
```

## Your task

Produce the deliverables listed above. The Lean file is the source of truth —
your prose must accurately explain it. Both ARTICLE.md and RESEARCH_PAPER.md
MUST be self-contained and publishable without referencing any external files.
State every theorem, definition, and result inline so a reader can follow the
entire argument from the document alone.

ARTICLE.md: write a popular-science narrative that makes the key idea accessible.
RESEARCH_PAPER.md: write the formal paper with abstract, definitions, results.
demo.py: write numerical examples that demonstrate the results.
PACKAGE.json: bundle everything into a single JSON with ALL fields populated.
Make sure demos, algorithms, visualizations, and interactive_demos are arrays
of objects (not placeholder strings). For each algorithm in the algorithms array, provide a clear, professional mathematical title in 'name' (do not use generic placeholders; this will be displayed as the header on the interactive site), a detailed explanation of its logic and complexity in 'description', formal step-by-step pseudocode in 'pseudocode', and clean type-hinted Python code in 'code'. For each Python demo in the demos array, provide a highly descriptive title in 'name', a comprehensive functional description in 'description', and the implementation code in 'code'. For each interactive HTML demo in interactive_demos, provide a beautiful title in 'title' and a detailed description in 'description'. Include future directions from Phase A in the future_directions field.

Be vivid, be precise, be world-class. The math has already been done — now
make it beautiful to read.
