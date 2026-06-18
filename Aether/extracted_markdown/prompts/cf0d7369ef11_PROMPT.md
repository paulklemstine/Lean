
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

**Title**: This cycle rebuilt the discrete Hodge program on a **self-contained Mathlib foun
**Domain**: Applications
**Mathematical framing**: # Future Directions — Discrete Hodge Laplacian, Green's Operator & Diffusion Message Passing

## Synthesis

This cycle rebuilt the discrete Hodge program on a **self-contained Mathlib foundation**, after
discovering that the catalog's entire `Hodge*` stack was non-elaborating: the files
`HodgeGreenOperator`, `HodgeHarmonicProjector`, `HodgeIsomorphism`, `HodgeResolutionIdentity` and
`HodgeThreeWayDecomposition` all `import` foundation modules (`HodgeBettiRank`,
`HodgeSpectralPositivity`, `HodgeDiffusionContraction`) that **do not exist** in the repository, and
the package declared no `srcDir`, so even the present files could not be located by `lake`. A
one-line infrastructure repair (`srcDir = "Catalog"` in `lakefile.toml`) restored module
resolution, and the new file `Catalog/Speculative/AutoResearch/HodgeLaplacianGreen.lean` re-derives
the operator-algebra, spectral, analytic and dynamical layers of the program from Mathlib alone.

The central object is the discrete **Hodge Laplacian** of a two-step cochain complex
`U --e--> V --d--> W`,
```
Δ = d* ∘ d + e ∘ e*
```
on the middle space `V`, with `d*`, `e*` the Mathlib adjoints. The single organizing identity is
the sum-of-squares **Dirichlet energy**
```
⟪Δ x, x⟫ = ‖d x‖² + ‖e* x‖²,
```
from which everything else follows: the harmonic space `ker Δ` is exactly the closed-and-co-closed
cochains (`d x = 0 ∧ e* x = 0`); the Rayleigh form is strictly positive off `ker Δ`; self-adjointness
turns `(ker Δ)ᗮ` into `range Δ`; and `Δ` is therefore invertible on the complement, yielding the
unique **Green's operator** value. On the dynamical side, the explicit-Euler diffusion step
`S = id − a·Δ` fixes the harmonic space pointwise and conserves the harmonic projection along the
whole trajectory `P (Sᵏ x) = P x`: diffusion never creates or destroys the topological (harmonic)
component, it only relaxes the exact/co-exact part.

This is the **local-to-global** picture of the engine's theme made discrete: local data (the maps
`d`, `e` on individual cochains) glues, via the Hodge decomposition, into the global obstruction
object `ker Δ`, and the Green's operator is the cohomological measurement of how the non-harmonic
part is inverted.

## Results summary

| Theorem | Statement |
|---|---|
| `hodgeLap_isSymmetric` | `Δ` is self-adjoint |
| `hodgeLap_quadratic_form` | `⟪Δ x, x⟫ = ‖d x‖² + ‖e* x‖²` |
| `hodgeLap_apply_eq_zero_iff` | `Δ x = 0 ↔ d x = 0 ∧ e* x = 0` (harmonic ⇔ closed & co-closed) |
| `hodgeLap_quadratic_eq_zero_iff` | `⟪Δ x, x⟫ = 0 ↔ Δ x = 0` (strict positivity off the kernel) |
| `hodgeLap_apply_mem_orthogonal_ker` | `Δ x ∈ (ker Δ)ᗮ` |
| `hodgeLap_range_eq_orthogonal_ker` | `range Δ = (ker Δ)ᗮ` |
| `hodgeLap_injOn_orthogonal_ker` | `Δ` is injective on `(ker Δ)ᗮ` |
| `sub_harmonicProjection_mem_orthogonal_ker` | `x − P x ∈ (ker Δ)ᗮ` |
| `hodgeLap_green_existsUnique` | unique `z ∈ (ker Δ)ᗮ` with `Δ z = x − P x` (Green value) |
| `diffStep_harmonic_fixed` / `diffStep_pow_harmonic_fixed` | `Sᵏ h = h` for harmonic `h` |
| `harmonicProjection_diffStep` / `harmonicProjection_diffStep_pow` | `P (Sᵏ x) = P x` |

All main results depend only on `propext`, `Classical.choice`, `Quot.sound`.

## Research directions

### 1. Bundle the Green's operator into an honest self-adjoint linear map
`hodgeLap_green_existsUnique` currently delivers a *pointwise* `∃!`. Conjecture it bundles into a
genuine `G : V →ₗ[ℝ] V` with `G ∘ Δ = Δ ∘ G = id − P_harmonic`, `G ∘ P_harmonic = 0`, and `G`
self-adjoint (`⟪G x, y⟫ = ⟪x, G y⟫`). Falsifiable by any candidate `G` with `Δ (G x) ≠ x − P x` on
some `x`, or with `⟪G x, y⟫ ≠ ⟪x, G y⟫`. **The key insight is** that uniqueness is the *only*
obstruction to linearity of a solver: `z(x+y)` and `z(x)+z(y)` both solve the same `∃!` problem
(`hodgeLap_injOn_orthogonal_ker` forces them equal), so `G x := Classical.choose (hodgeLap_green_exists x)`
is automatically additive and homogeneous, and `LinearMap.mk` closes the construction.
**Why now?** Injectivity on the complement is a theorem this cycle, so each `LinearMap` axiom is a
one-line uniqueness argument, with self-adjointness following from `hodgeLap_isSymmetric` restricted
to the invariant complement.

### 2. The diffusion energy is a strict Lyapunov function with harmonic limit
Conjecture the Dirichlet energy `E(x) = ⟪Δ x, x⟫` is non-increasing along admissible diffusion,
`E(S x) ≤ E(x)` for `0 < a < 2/λ_max`, with equality iff `x` is harmonic, and that `Sᵏ x → P x` as
`k → ∞`. Falsifiable by an `x` and admissible `a` with `E(S x) > E(x)`, or a non-harmonic fixed
point of `S`. **The key insight is** that `hodgeLap_quadratic_form` already exhibits `E` as a sum of
squares whose zero set is exactly `ker Δ` (`hodgeLap_quadratic_eq_zero_iff`), and
`harmonicProjection_diffStep_pow` pins the limit's harmonic part to `P x`, so only the complementary
part must be shown to vanish. **Why now?** Both the Lyapunov candidate (the proven quadratic form)
and the conserved target (`P x`) are in hand; monotonicity reduces to a single algebraic estimate on
`E(x) − E(Sx) = 2a⟪Δx,Δx⟫ − a²⟪Δx,Δ(Δx)⟫` once `Δ` is bounded by `λ_max` on the complement.

### 3. Quantitative contraction at the spectral-gap rate
Conjecture that for an admissible step `0 < a < 2/λ_max`,
`‖Sᵏ x − P x‖ ≤ ρᵏ ‖x − P x‖` with `ρ = max_{λ>0} |1 − aλ| < 1` over the nonzero eigenvalues of `Δ`.
Falsifiable by a complex, an admissible `a`, and an iterate failing to contract by `ρ`. **The key
insight is** that `harmonicProjection_diffStep_pow` makes `x − P x` the only part that moves, and on
`(ker Δ)ᗮ` the Laplacian has strictly positive eigenvalues (`hodgeLap_quadratic_eq_zero_iff` plus
`hodgeLap_injOn_orthogonal_ker`), so `‖S y‖ ≤ ρ‖y‖` for `y ∈ (ker Δ)ᗮ` collapses to the
one-dimensional estimate `|1 − aλ| ≤ ρ` per eigenvector. **Why now?** The invariant splitting and
strict positivity are theorems, so contraction is a geometric per-eigenvalue bound rather than a
fresh dynamical-systems study — it needs only the spectral resolution of Direction 4.

### 4. Spectral resolution `Δ = Σ λᵢ Pᵢ` with `P₀ = P_harmonic` and `G = Σ_{λᵢ>0} λᵢ⁻¹ Pᵢ`
Conjecture the finite-dimensional spectral theorem for `Δ`: an orthonormal eigenbasis with
`0 = λ₀ ≤ λ₁ ≤ …`, the `0`-eigenprojection equal to `P_harmonic`, `Δ = Σ λᵢ Pᵢ`, and the Green's
operator of Direction 1 equal to `G = Σ_{λᵢ>0} λᵢ⁻¹ Pᵢ`. Falsifiable by a negative eigenvalue, a
non-harmonic `0`-eigenvector, or a mismatch `G ≠ Σ λᵢ⁻¹ Pᵢ`. **The key insight is** that
`hodgeLap_isSymmetric` feeds Mathlib's finite-dimensional spectral theorem directly, the quadratic
form pins the spectrum to `[0,∞)`, and `hodgeLap_quadratic_eq_zero_iff` identifies the `0`-eigenspace
with `ker Δ`, so the eigendecomposition is an *application* rather than a new theory. **Why now?** All
three hypotheses of the spectral theorem are theorems, and `hodgeLap_green_existsUnique` forces the
Green-operator formula once eigenprojections exist.

### 5. The discrete Hodge isomorphism `H = ker d / range e ≃ ker Δ` as a quotient isometry
Conjecture that the harmonic representative realizes the cohomology quotient: every class `[x]` with
`d x = 0` has a *unique* harmonic representative `P x ∈ ker Δ`, giving a linear isomorphism
`ker d / range e ≃ ker Δ`, and that it is an **isometry** for the quotient norm,
`‖[x]‖ = ‖P x‖`. Falsifiable by a closed `x` whose harmonic projection leaves the class, or a class
whose quotient norm differs from `‖P x‖`. **The key insight is** that `range Δ = (ker Δ)ᗮ` already
splits any closed cochain into a harmonic part `P x` and a part in `range Δ = range d* ⊕ range e`;
restricted to closed cochains the `d*`-component vanishes, so `x − P x ∈ range e` and `P x` is the
canonical class representative, with the energy minimization `‖P x‖ ≤ ‖x − e u‖` making the quotient
infimum attained exactly at `P x`. **Why now?** The orthogonal splitting and the harmonic-projection
identities are theorems this cycle; only the identification of Mathlib's `Submodule.Quotient.norm_mk`
infimum with this attained minimum remains, upgrading the linear iso to a `LinearIsometryEquiv`.

Research domain: Applications
Research mode: team


## Phase A Lean 4 Output (the math — read this carefully)

```
-- NEW_FILE: Catalog/Speculative/AutoResearch/HodgeLaplacianGreen.lean
/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license.

# The Discrete Hodge Laplacian, its Harmonic Space, and Diffusion Message Passing

This file gives a **self-contained Mathlib foundation** for the discrete Hodge program.
It works with a two-step cochain complex of finite-dimensional real inner-product spaces

    U --e--> V --d--> W

and studies the *Hodge Laplacian* on the middle space `V`,

    Δ = d* ∘ d + e ∘ e*,

where `d* = LinearMap.adjoint d` and `e* = LinearMap.adjoint e`.

The single organizing identity is the sum-of-squares **Dirichlet energy**

    ⟪Δ x, x⟫ = ‖d x‖² + ‖e* x‖²,

from which everything else follows:

* the harmonic space `ker Δ` is exactly the *closed-and-co-closed* cochains
  (`d x = 0 ∧ e* x = 0`);
* the Rayleigh quadratic form is strictly positive off `ker Δ`;
* `Δ` is self-adjoint, so its image lands in `(ker Δ)ᗮ`.

On the dynamical side, the explicit-Euler **diffusion step** `S = id − a·Δ`
fixes the harmonic space pointwise and *conserves the harmonic projection* along the
whole trajectory, `P (Sᵏ x) = P x`: diffusion never creates or destroys the
topological (harmonic) component, it only relaxes the exact / co-exact part.

This file is deliberately independent of the rest of the catalog (it imports only
Mathlib), repairing the previously non-elaborating `Hodge*` stack.

-- !-- Lab Notebook -- !--
Hypothesis:  For the two-step complex `U → V → W`, the Hodge Laplacian
  `Δ = d*d + e e*` should satisfy the Dirichlet identity `⟪Δx,x⟫ = ‖dx‖² + ‖e*x‖²`,
  which simultaneously makes `Δ` positive semidefinite, identifies its kernel with the
  closed-&-co-closed cochains, and (via self-adjointness) forces `range Δ ⊆ (ker Δ)ᗮ`.
  The diffusion step `S = id − aΔ` should then fix harmonics and conserve the harmonic
  projection at every depth.
Result:  Formalised and proved sorry-free.  `hodgeLap_isSymmetric` (self-adjoint),
  `hodgeLap_quadratic_form` (the Dirichlet identity), `hodgeLap_apply_eq_zero_iff`
  (harmonic ⇔ closed & co-closed), `hodgeLap_quadratic_eq_zero_iff` (strict positivity
  off the kernel), `hodgeLap_apply_mem_orthogonal_ker` (`Δx ⊥ ker Δ`),
  `diffStep_harmonic_fixed` / `diffStep_pow_harmonic_fixed` (harmonics are fixed at
  every depth), and `harmonicProjection_diffStep` / `harmonicProjection_diffStep_pow`
  (the harmonic projection is conserved along diffusion).
Insight:  Every analytic fact is a one-line consequence of the two adjunction lemmas
  `adjoint_inner_left/right` once the energy is written as a sum of squares; the
  dynamical facts then need only linearity of `Δ` and of the orthogonal projection,
  plus the symmetry-driven inclusion `Δx ∈ (ker Δ)ᗮ`.
Failure analysis:  Working with the inner-product energy `⟪v,v⟫` rather than `‖v‖`
  avoids `Real.sqrt`; phrasing the kernel characterisation through the quadratic form
  (`⟪Δx,x⟫ = 0 ↔ Δx = 0`) sidesteps any explicit eigenvalue bookkeeping.
-- !-- Lab Notebook -- !--
-/
import Mathlib

open scoped InnerProductSpace BigOperators

namespace HodgeLaplacianGreen

variable {U V W : Type*}
  [NormedAddCommGroup U] [InnerProductSpace ℝ U] [FiniteDimensional ℝ U]
  [NormedAddCommGroup V] [InnerProductSpace ℝ V] [FiniteDimensional ℝ V]
  [NormedAddCommGroup W] [InnerProductSpace ℝ W] [FiniteDimensional ℝ W]

/-- The discrete **Hodge Laplacian** of the two-step complex `U --e--> V --d--> W`,
acting on the middle space `V` by `Δ = d* ∘ d + e ∘ e*`. -/
noncomputable def hodgeLap (e : U →ₗ[ℝ] V) (d : V →ₗ[ℝ] W) : V →ₗ[ℝ] V :=
  LinearMap.adjoint d ∘ₗ d + e ∘ₗ LinearMap.adjoint e

variable (e : U →ₗ[ℝ] V) (d : V →ₗ[ℝ] W)

@[simp] theorem hodgeLap_apply (x : V) :
    hodgeLap e d x = LinearMap.adjoint d (d x) + e (LinearMap.adjoint e x) := by
  simp [hodgeLap]

/-
!-- comment: Expand `Δ` and move each summand across the relevant adjunction
(`adjoint_inner_left/right`) to land symmetrically on `x` and `y`. -- !--

The Hodge Laplacian is **self-adjoint**: `⟪Δ x, y⟫ = ⟪x, Δ y⟫`.
-/
theorem hodgeLap_isSymmetric : (hodgeLap e d).IsSymmetric := by
  intro x y;
  simp +decide only [hodgeLap, LinearMap.add_apply, LinearMap.comp_apply, inner_add_left,
      LinearMap.adjoint_inner_left];
  rw [ inner_add_right, LinearMap.adjoint_inner_right ];
  simp +decide [ ← LinearMap.adjoint_inner_left ]

/-
!-- comment: `⟪d*(dx),x⟫ = ⟪dx,dx⟫` and `⟪e(e*x),x⟫ = ⟪e*x,e*x⟫` by the two
adjunction lemmas; rewrite `⟪v,v⟫` as `‖v‖²`. -- !--

The **Dirichlet energy / Rayleigh quotient** is a sum of squares:
`⟪Δ x, x⟫ = ‖d x‖² + ‖e* x‖²`.
-/
theorem hodgeLap_quadratic_form (x : V) :
    (⟪hodgeLap e d x, x⟫_ℝ) = ‖d x‖ ^ 2 + ‖LinearMap.adjoint e x‖ ^ 2 := by
  have h1 : ⟪LinearMap.adjoint d (d x), x⟫_ℝ = ‖d x‖ ^ 2 := by
    rw [LinearMap.adjoint_inner_left, real_inner_self_eq_norm_sq]
  have h2 : ⟪e (LinearMap.adjoint e x), x⟫_ℝ = ‖LinearMap.adjoint e x‖ ^ 2 := by
    rw [← LinearMap.adjoint_inner_right, real_inner_self_eq_norm_sq]
  simp only [hodgeLap, LinearMap.add_apply, LinearMap.comp_apply, inner_add_left, h1, h2]

/-
!-- comment: From the sum-of-squares form, `⟪Δx,x⟫ = 0` forces both squares to vanish;
conversely if both vanish then `Δx = 0`.  Combine with the quadratic-eq-zero lemma. -- !--

**Harmonic ⇔ closed & co-closed**: `Δ x = 0 ↔ d x = 0 ∧ e* x = 0`.
-/
theorem hodgeLap_apply_eq_zero_iff (x : V) :
    hodgeLap e d x = 0 ↔ d x = 0 ∧ LinearMap.adjoint e x = 0 := by
  by_cases h₁ : d x = 0 <;> simp_all +decide [ hodgeLap ];
  · constructor <;> intro h <;> have := LinearMap.adjoint_inner_right e ( LinearMap.adjoint e x ) x <;> simp_all +decide [ inner_self_eq_norm_sq_to_K ];
  · contrapose! h₁; have := hodgeLap_quadratic_form e d x; simp_all +decide;
    exact norm_eq_zero.mp ( by nlinarith )

/-
!-- comment: `⟪Δx,x⟫ = ‖dx‖²+‖e*x‖² = 0 ↔ dx = 0 ∧ e*x = 0 ↔ Δx = 0`
(strict positivity of the Rayleigh form off the kernel). -- !--

**Strict positivity off the kernel**: the Rayleigh form vanishes only on harmonics,
`⟪Δ x, x⟫ = 0 ↔ Δ x = 0`.
-/
theorem hodgeLap_quadratic_eq_zero_iff (x : V) :
    (⟪hodgeLap e d x, x⟫_ℝ) = 0 ↔ hodgeLap e d x = 0 := by
  convert ( hodgeLap_apply_eq_zero_iff e d x ) |> Iff.symm using 1;
  rw [ hodgeLap_quadratic_form ];
  exact ⟨ fun h => ⟨ norm_eq_zero.mp ( by nlinarith ), norm_eq_zero.mp ( by nlinarith ) ⟩, fun h => by simp +decide [ h ] ⟩

/-
!-- comment: For `h ∈ ker Δ`, `⟪h, Δx⟫ = ⟪Δh, x⟫ = 0` by self-adjointness, so
`Δx ⊥ ker Δ`. -- !--

**Image lands in the orthogonal complement of the kernel**: `Δ x ∈ (ker Δ)ᗮ`.
-/
theorem hodgeLap_apply_mem_orthogonal_ker (x : V) :
    hodgeLap e d x ∈ (LinearMap.ker (hodgeLap e d))ᗮ := by
  intro y hy;
  convert congr_arg ( fun z => ⟪z, x⟫_ℝ ) hy using 1;
  · rw [ hodgeLap_isSymmetric ];
  · simp +decide

/-! ## Diffusion message passing -/

/-- One explicit-Euler **diffusion step** `S = id − a·Δ`, as a linear endomorphism of
`V`, so that iterating it (`S ^ k`) is automatically linear. -/
noncomputable def diffStep (a : ℝ) : V →ₗ[ℝ] V :=
  LinearMap.id - a • hodgeLap e d

@[simp] theorem diffStep_apply (a : ℝ) (x : V) :
    diffStep e d a x = x - a • hodgeLap e d x := by
  simp [diffStep]

/-- The **harmonic projection** `P`: orthogonal projection onto the harmonic space
`ker Δ`. -/
noncomputable def harmonicProjection : V →L[ℝ] (LinearMap.ker (hodgeLap e d)) :=
  (LinearMap.ker (hodgeLap e d)).orthogonalProjection

/-
!-- comment: If `Δh = 0` then `S h = h − a•0 = h`. -- !--

Harmonic cochains are **fixed points** of a diffusion step.
-/
theorem diffStep_harmonic_fixed (a : ℝ) {h : V} (hh : hodgeLap e d h = 0) :
    diffStep e d a h = h := by
  unfold diffStep; aesop;

/-
!-- comment: Iterate `diffStep_harmonic_fixed` over depth `k` by induction
(`pow_succ'`). -- !--

Harmonic cochains are fixed at **every depth** of diffusion.
-/
theorem diffStep_pow_harmonic_fixed (a : ℝ) {h : V} (hh : hodgeLap e d h = 0) (k : ℕ) :
    ((diffStep e d a) ^ k) h = h := by
  induction' k with k ih;
  · rfl;
  · rw [ pow_su
```

## Phase A Future Directions (include in PACKAGE.json)

Phase A produced these future research directions. Include them verbatim
(or lightly edited for clarity) in the `future_directions` field of
PACKAGE.json so they appear in the "Future Directions" tab on the website.

```
# Future Directions — Discrete Hodge Laplacian, Harmonic Space & Diffusion Message Passing

## Synthesis

This cycle rebuilds the discrete Hodge program on a **self-contained Mathlib foundation**.
The previous catalog `Hodge*` stack did not elaborate: `HodgeMessagePassingConvergence`
imports a module `Speculative.AutoResearch.HodgeSpectralThreshold` that does not exist in the
repository, and the package declared no `srcDir`, so `lake` could not even locate the catalog
sources. Two infrastructure repairs were made — adding `srcDir = "Catalog"` to `lakefile.toml`
so module resolution works at all — and a new, dependency-free file
`Catalog/Speculative/AutoResearch/HodgeLaplacianGreen.lean` re-derives the operator-algebra,
analytic, and dynamical layers of the program from Mathlib alone.

The central object is the discrete **Hodge Laplacian** of a two-step cochain complex of
finite-dimensional real inner-product spaces

```
U --e--> V --d--> W ,        Δ = d* ∘ d + e ∘ e*   on   V ,
```

with `d* = LinearMap.adjoint d` and `e* = LinearMap.adjoint e`. The single organizing identity
is the sum-of-squares **Dirichlet energy**

```
⟪Δ x, x⟫ = ‖d x‖² + ‖e* x‖² ,
```

from which everything else follows. The harmonic space `ker Δ` is exactly the
closed-and-co-closed cochains (`d x = 0 ∧ e* x = 0`); the Rayleigh form is strictly positive
off `ker Δ`; self-adjointness places the image of `Δ` inside `(ker Δ)ᗮ`. On the dynamical
side, the explicit-Euler diffusion step `S = id − a·Δ` fixes the harmonic space pointwise and
conserves the harmonic projection along the whole trajectory, `P (Sᵏ x) = P x`: diffusion
never creates or destroys the topological (harmonic) component, it only relaxes the
exact / co-exact part. This is the local-to-global picture made discrete: local data (the maps
`d`, `e` on individual cochains) glues, via the Hodge decomposition, into the global
obstruction object `ker Δ`.

## Results summary (proved sorry-free; axioms `propext, Classical.choice, Quot.sound`)

| Theorem | Statement |
|---|---|
| `hodgeLap_isSymmetric` | `Δ` is self-adjoint |
| `hodgeLap_quadratic_form` | `⟪Δ x, x⟫ = ‖d x‖² + ‖e* x‖²` |
| `hodgeLap_apply_eq_zero_iff` | `Δ x = 0 ↔ d x = 0 ∧ e* x = 0` (harmonic ⇔ closed & co-closed) |
| `hodgeLap_quadratic_eq_zero_iff` | `⟪Δ x, x⟫ = 0 ↔ Δ x = 0` (strict positivity off the kernel) |
| `hodgeLap_apply_mem_orthogonal_ker` | `Δ x ∈ (ker Δ)ᗮ` |
| `diffStep_harmonic_fixed` / `diffStep_pow_harmonic_fixed` | `Sᵏ h = h` for harmonic `h` |
| `harmonicProjection_diffStep` / `harmonicProjection_diffStep_pow` | `P (Sᵏ x) = P x` |

## Research directions

### 1. From "image in `(ker Δ)ᗮ`" to the orthogonal splitting `range Δ = (ker Δ)ᗮ`
This cycle proves the easy inclusion `Δ x ∈ (ker Δ)ᗮ` (`hodgeLap_apply_mem_orthogonal_ker`).
Conjecture the full identity `range Δ = (ker Δ)ᗮ`, and consequently that `Δ` is a linear
isomorphism of `(ker Δ)ᗮ` onto itself. Falsifiable by any `y ∈ (ker Δ)ᗮ` not of the form
`Δ x`, or any nonzero `z ∈ (ker Δ)ᗮ`
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
