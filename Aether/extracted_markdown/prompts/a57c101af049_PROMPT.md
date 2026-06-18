
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

**Title**: This cycle closed two of the standing conjectures of the *spectral depth thresho
**Domain**: Applications
**Mathematical framing**: # Future Directions — Hodge–Laplacian Message Passing, Third Cycle

## Synthesis

This cycle closed two of the standing conjectures of the *spectral depth threshold* /
*full Hodge decomposition* program and, in doing so, sharpened its local-to-global core.
The two new sorry-free files turn previously informal "future directions" into proven Lean 4
theory, and they do so by promoting the earlier **entrywise matrix** lemmas to **basis-free
operator** statements, which is exactly the move that makes the cohomological content visible.

* **`Catalog/Speculative/AutoResearch/HodgeBettiRank.lean` — Betti numbers from the harmonic
  kernel (Research Direction 1).** The matrix discrete-Hodge theorem `fullHodge_kernel` and
  the orthogonality lemma `hodge_image_orthogonal` of `HodgeFullDecomposition.lean` are lifted
  to arbitrary finite-dimensional real inner product spaces, working with the genuine
  finite-dimensional adjoint `d*` rather than a matrix transpose. The operator Hodge Laplacian
  `Δ = d* d + e e*` (`hodgeLap`) has its harmonic space characterized as the closed-and-coclosed
  cochains `ker d ⊓ ker e*` (`hodgeLap_ker`), with `ker e* = (range e)ᗮ`
  (`ker_adjoint_eq_orthogonal_range`). The chain condition `d ∘ e = 0` places the gradient image
  inside the closed space (`range_e_le_ker_d`), and a single application of orthogonal
  rank–nullity (`Submodule.finrank_add_inf_finrank_orthogonal`) yields the **Hodge–Betti
  identity** `dim(ker Δ) + rank e = dim(ker d)` (`hodge_betti`), i.e.
  `bₖ = dim ker ∂ₖ − rank ∂ₖ₊₁` (`hodge_betti_eq`). A *global* topological invariant is now
  computed from purely *local* boundary data.

* **`Catalog/Speculative/AutoResearch/HodgeDepthSchedule.lean` — tightness and energy-free
  schedules (Research Directions 3 & 5).** The sufficient logarithmic depth
  `hodgeDepth = ⌈log_ρ(ε/E)⌉₊` of `HodgeDepthLogarithmic.lean` is shown to be *necessary*:
  the analytic converse `pow_gt_of_logb_lt` (the exact mirror of `pow_le_of_logb_le`) combined
  with `Nat.lt_ceil` proves that on a saturating worst-case input every layer strictly below
  `hodgeDepth` leaves residual energy `> ε` (`hodgeDepth_tight`). Hence the ceiling is a genuine
  minimum, not merely an upper bound. The schedule law isolates that `hodgeDepth` is a `⌈log⌉` of
  a *quotient*, so the signal energy `E` is a pure additive offset and cancels in differences:
  exactly at the continuous level (`logb_depth_energy_cancel`) and up to ceiling sub-additivity
  at the integer level (`hodgeDepth_increment_le`). Monotonicity in the tolerance
  (`hodgeDepth_mono`) confirms the clock is well behaved.

The unifying picture is now: message passing is a deformation retraction onto the harmonic core;
the harmonic core *is* the cohomology and its dimension *is* the Betti number; and the speed of
the retraction is governed by an explicit, tight, energy-free logarithmic clock.

## Results summary

| Theorem | File | Statement |
|---|---|---|
| `ker_adjoint_eq_orthogonal_range` | BettiRank | `ker e* = (range e)ᗮ` |
| `hodgeLap_quadform` | BettiRank | `⟪Δx,x⟫ = ‖dx‖² + ‖e*x‖²` |
| `hodgeLap_ker` | BettiRank | discrete Hodge theorem: `ker Δ = ker d ⊓ ker e*` |
| `range_e_le_ker_d` | BettiRank | chain condition `d∘e=0 ⇒ range e ≤ ker d` |
| `hodge_betti` | BettiRank | `dim(ker Δ) + rank e = dim(ker d)` |
| `hodge_betti_eq` | BettiRank | `bₖ = dim ker ∂ₖ − rank ∂ₖ₊₁` |
| `pow_gt_of_logb_lt` | DepthSchedule | `N < log_ρ c ⇒ c < ρᴺ` (analytic converse) |
| `hodgeDepth_tight` | DepthSchedule | every depth `< hodgeDepth` overshoots `ε` |
| `logb_depth_energy_cancel` | DepthSchedule | continuous depth law is energy-free |
| `hodgeDepth_increment_le` | DepthSchedule | incremental depth `≤ ⌈log_ρ(ε₂/ε₁)⌉₊` |
| `hodgeDepth_mono` | DepthSchedule | depth clock monotone in tolerance |

All proofs depend only on `propext`, `Classical.choice`, `Quot.sound`.

## Research directions

### 1. The Hodge isomorphism: harmonic space ≅ cohomology, not just equidimensional
`hodge_betti` proves the harmonic dimension equals `dim ker d − rank e`, the dimension of the
cohomology `Hᵏ = ker d / range e`. The natural next step is to build the explicit **linear
isomorphism** `ker Δ ≃ₗ[ℝ] (ker d ⧸ range e.range)` sending a harmonic cochain to its
cohomology class, and to prove it is an isometry for the quotient inner product. Falsifiable: any
two-step complex where the class map is not injective (a nonzero harmonic cochain that is exact)
would refute it. **The key insight is** that `hodgeLap_ker` already realizes harmonic cochains as
`(range e)ᗮ ⊓ ker d`, which is a *canonical set-theoretic section* of the quotient map
`ker d ↠ ker d / range e`; the orthogonality `range_e_le_ker_d` makes that section linear and
norm-preserving, so the isomorphism is `Submodule.quotientEquivOfIsCompl` specialized to the
orthogonal complement. **Why now?** With `hodge_betti` giving equal dimensions and
`ker_adjoint_eq_orthogonal_range` giving the explicit complement, an injective linear map between
equidimensional spaces is automatically an isomorphism (`LinearMap.injective_iff_surjective`), so
only injectivity — a one-line consequence of `range e ⊆ ker d` and orthogonality — remains.

### 2. Strong (three-way) Hodge decomposition of the cochain space
Conjecture: under the chain condition the middle space splits as a *triple* orthogonal direct sum
`V = range d* ⊕ range e ⊕ ker Δ` (coexact ⊕ exact ⊕ harmonic), with each summand `Δ`-invariant.
Falsifiable by exhibiting a vector with no such decomposition, or a nonzero overlap between two
summands. **The key insight is** that `ker Δ = ker d ⊓ ker e*` (from `hodgeLap_ker`) is precisely
the orthogonal complement of `range d* + range e`, and `range d* ⊥ range e` is the operator-level
restatement of `hodge_image_orthogonal`; so the triple sum is two nested applications of
`Submodule.finrank_add_finrank_orthogonal`. **Why now?** All three pieces — the kernel
description, the image orthogonality, and `range_e_le_ker_d` — are now theorems, so the
decomposition is pure `Submodule` bookkeeping with no new analysis.

### 3. Euler characteristic as a telescoping alternating sum of harmonic dimensions
Conjecture: for a length-`n` cochain complex the alternating sum of harmonic dimensions equals the
alternating sum of the space dimensions, `Σ (−1)ᵏ dim(ker Δₖ) = Σ (−1)ᵏ dim Vₖ` — the discrete
**Hodge–Euler theorem**, identifying the analytic Euler characteristic with the combinatorial one.
Falsifiable by a finite complex whose harmonic Euler sum differs from its space Euler sum. **The
key insight is** that `hodge_betti` gives `dim(ker Δₖ) = dim ker dₖ − rank eₖ` at each degree, and
the rank–nullity theorem `rank dₖ + dim ker dₖ = dim Vₖ` makes consecutive `rank` terms telescope
when summed with alternating signs. **Why now?** `hodge_betti` supplies every per-degree identity;
the global statement is a finite alternating-sum induction over `Finset.range n` using only
`Module.finrank` arithmetic already available in Mathlib.

### 4. Convergence of message passing to the orthogonal harmonic projector
Conjecture: for an admissible step `0 < α < 2/λ_max`, the iterate `(id − αΔ)^[k]` converges in
operator norm to the orthogonal projector `P` onto `ker Δ`, with rate
`‖(id − αΔ)^[k] x − P x‖ ≤ ρᵏ ‖x − P x‖` for `ρ = max|1 − αλ|` over nonzero eigenvalues `λ`.
Falsifiable by a complex with an eigenvalue outside `(0, 2/α)` exhibiting non-contraction.
**The key insight is** that the three-way decomposition of Direction 2 makes `ker Δ` and its
complement `(range d* ⊕ range e)` simultaneously `Δ`-invariant; the harmonic block is fixed
exactly (`Δ` acts as `0`), and on the complement the spectral mapping theorem gives geometric
contraction with the stated `ρ`. **Why now?** Mathlib's `Submodule.orthogonalProjection` and the
finite-dimensional spectral theorem for the self-adjoint `Δ` (it is symmetric by construction)
provide both the projector and the eigenbasis, so the limit assembles from `id = P + (id − P)`.

### 5. Continuum heat-flow limit of the depth clock
Conjecture: the discrete flow `x_{k+1} = x_k − αΔ x_k` is the explicit Euler scheme of the Hodge
heat equation `ẋ = −Δx`; as `α → 0` with `kα = t` fixed, `(id − αΔ)^[k] x → e^{−tΔ} x`, and the
continuum decay constant equals the spectral gap `μ` (smallest nonzero Hodge eigenvalue). Hence the
discrete tight depth `hodgeDepth` matches the continuous half-life `t = log(1/ε)/(2μ)`. Falsifiable
by a complex whose empirical decay rate differs from its second-smallest Hodge eigenvalue.
**The key insight is** that the per-layer contraction factor `1 − αμ(2 − αμ) ≈ 1 − 2αμ` is the
first-order expansion of `e^{−2αμ}`, so the *tight* logarithmic clock `hodgeDepth` proven here is
the discrete shadow of the heat-kernel half-life. **Why now?** `pow_gt_of_logb_lt` and
`hodgeDepth_tight` pin the discrete rate exactly, and Mathlib's `Matrix.exp` / `NormedSpace.exp`
derivative API makes the Euler-to-exponential comparison a concrete, bounded analysis target.

Research domain: Applications
Research mode: team


## Phase A Lean 4 Output (the math — read this carefully)

```
-- NEW_FILE: Catalog/Speculative/AutoResearch/HodgeIsomorphism.lean
/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license.

# The Hodge Isomorphism: the harmonic space *is* the cohomology

This file *extends* the Hodge–Betti dimension count of
`Catalog/Speculative/AutoResearch/HodgeBettiRank.lean` (`hodge_betti`, `hodgeLap_ker`) and
the three-way splitting of
`Catalog/Speculative/AutoResearch/HodgeThreeWayDecomposition.lean`
(`closed_eq_exact_sup_harmonic`, `harmonic_le_orthogonal_range_e`) from an *equidimensional*
statement (`dim (ker Δ) = dim ker d − rank e`) to a genuine **linear isomorphism**

  `ker Δ  ≅  Hᵏ = ker d / range e`            (`hodgeCohomologyEquiv`),

the classical **Hodge isomorphism**: every cohomology class of the cochain complex
`U --e--> V --d--> W` (with `d ∘ e = 0`) contains exactly one harmonic representative.

The content is split into the two halves of "exactly one":

* **Existence.** Every closed cochain is harmonic plus exact (`harmonic_representative_exists`).
* **Uniqueness.** Two harmonic cochains in the same cohomology class are equal
  (`harmonic_representative_unique`), because harmonic ∩ exact `= 0`
  (`harmonic_inf_exact_eq_bot`).

These combine into the explicit `LinearEquiv` `hodgeCohomologyEquiv`, built by
`Submodule.quotientEquivOfIsCompl` from the fact that, *inside the closed space* `ker d`, the
exact part `range e` and the harmonic part `ker Δ` are complementary (`hodge_isCompl`).

## Main results

* `harmonic_le_ker_d`            — harmonic cochains are closed: `ker Δ ≤ ker d`.
* `harmonic_inf_exact_eq_bot`    — harmonic ∩ exact `= ⊥` (orthogonality of the summands).
* `harmonic_representative_unique` — at most one harmonic representative per class.
* `harmonic_representative_exists` — at least one: every closed cochain `= exact + harmonic`.
* `hodge_isCompl`                — `range e` and `ker Δ` are complementary inside `ker d`.
* `hodgeCohomologyEquiv`         — **Hodge isomorphism** `(ker d / range e) ≃ₗ ker Δ`.

## Catalog synthesis

This realizes **Research Direction 1** ("the Hodge isomorphism, not just equidimensionality")
of `HodgeBettiRank`'s FUTURE_DIRECTIONS.  `closed_eq_exact_sup_harmonic` (from the three-way
file) supplies *existence/codisjointness*, while `harmonic_le_orthogonal_range_e` plus
`Submodule.inf_orthogonal_eq_bot` supplies *uniqueness/disjointness*; together they give
`IsCompl` inside `ker d`, and `Submodule.quotientEquivOfIsCompl` upgrades the dimension count
`hodge_betti` to a canonical isomorphism.
-/
import Mathlib
import Speculative.AutoResearch.HodgeBettiRank
import Speculative.AutoResearch.HodgeThreeWayDecomposition

namespace HodgeIsomorphism

open LinearMap RealInnerProductSpace
open scoped InnerProductSpace
open HodgeBettiRank HodgeThreeWayDecomposition

variable {U V W : Type*}
  [NormedAddCommGroup U] [InnerProductSpace ℝ U] [FiniteDimensional ℝ U]
  [NormedAddCommGroup V] [InnerProductSpace ℝ V] [FiniteDimensional ℝ V]
  [NormedAddCommGroup W] [InnerProductSpace ℝ W] [FiniteDimensional ℝ W]

-- !-- Lab Notebook -- !--
-- Hypothesis: The Hodge–Betti equality `dim ker Δ = dim ker d − rank e` should refine to a
--   canonical *linear isomorphism* `ker Δ ≅ ker d / range e`: the harmonic representative of
--   each cohomology class, existing and unique.  Inside the closed space `ker d`, the exact
--   part `range e` and the harmonic part `ker Δ` should be complementary submodules.
-- Result: All six statements are proven sorry-free.  `hodge_isCompl` is the structural core,
--   and `hodgeCohomologyEquiv` is the explicit Hodge isomorphism built from it.
-- Insight: Disjointness `range e ⊓ ker Δ = ⊥` is orthogonality (`ker Δ ≤ (range e)ᗮ` and
--   `K ⊓ Kᗮ = ⊥`); codisjointness `range e ⊔ ker Δ = ker d` is the Hodge split
--   `closed_eq_exact_sup_harmonic`.  Pulling both back along `(ker d).subtype` (which is
--   injective, so `Submodule.map` reflects equalities) turns these into `IsCompl` *inside*
--   `↥(ker d)`, exactly the hypothesis of `Submodule.quotientEquivOfIsCompl`.
-- Failure analysis: the isomorphism must be assembled in the ambient module `↥(ker d)`, not
--   `V` — `range e` and `ker Δ` are NOT complementary in `V` (their sup is `ker d ≠ ⊤`
--   whenever `d ≠ 0`).  `Submodule.comapSubtypeEquivOfLe` re-identifies the pulled-back
--   harmonic submodule with `ker Δ` itself, closing the type mismatch.
-- !-- end Lab Notebook -- !--

-- !-- Harmonic cochains are closed.  `ker Δ = ker d ⊓ ker e* ≤ ker d` (`hodgeLap_ker`). -- !--
theorem harmonic_le_ker_d (d : V →ₗ[ℝ] W) (e : U →ₗ[ℝ] V) :
    LinearMap.ker (hodgeLap d e) ≤ LinearMap.ker d := by
  rw [hodgeLap_ker]; exact inf_le_left

-- !-- Harmonic ∩ exact = 0.  `ker Δ ≤ (range e)ᗮ` (`harmonic_le_orthogonal_range_e`), so the
--    intersection sits inside `(range e)ᗮ ⊓ range e = ⊥` (`Submodule.inf_orthogonal_eq_bot`). -- !--
theorem harmonic_inf_exact_eq_bot (d : V →ₗ[ℝ] W) (e : U →ₗ[ℝ] V) :
    LinearMap.ker (hodgeLap d e) ⊓ LinearMap.range e = ⊥ := by
  have h : LinearMap.ker (hodgeLap d e) ⊓ LinearMap.range e
      ≤ (LinearMap.range e)ᗮ ⊓ LinearMap.range e :=
    inf_le_inf_right _ (harmonic_le_orthogonal_range_e d e)
  have hbot : (LinearMap.range e)ᗮ ⊓ LinearMap.range e = ⊥ := by
    rw [inf_comm]; exact Submodule.inf_orthogonal_eq_bot _
  rw [hbot] at h
  exact le_bot_iff.mp h

-- !-- Uniqueness of harmonic representatives.  If `h₁, h₂ ∈ ker Δ` and `h₁ - h₂ ∈ range e`,
--    then `h₁ - h₂ ∈ ker Δ ⊓ range e = ⊥`, so `h₁ = h₂`. -- !--
theorem harmonic_representative_unique (d : V →ₗ[ℝ] W) (e : U →ₗ[ℝ] V)
    (h₁ h₂ : V) (hh₁ : h₁ ∈ LinearMap.ker (hodgeLap d e))
    (hh₂ : h₂ ∈ LinearMap.ker (hodgeLap d e))
    (hdiff : h₁ - h₂ ∈ LinearMap.range e) : h₁ = h₂ := by
  have hmem : h₁ - h₂ ∈ LinearMap.ker (hodgeLap d e) ⊓ LinearMap.range e :=
    Submodule.mem_inf.mpr ⟨Submodule.sub_mem _ hh₁ hh₂, hdiff⟩
  rw [harmonic_inf_exact_eq_bot, Submodule.mem_bot] at hmem
  exact sub_eq_zero.mp hmem

-- !-- Existence of harmonic representatives.  A closed cochain `x ∈ ker d = range e ⊔ ker Δ`
--    (`closed_eq_exact_sup_harmonic`) lies in the sup, so `Submodule.mem_sup` gives an exact
--    part `e u` and a harmonic part `h` with `x = e u + h`. -- !--
theorem harmonic_representative_exists (d : V →ₗ[ℝ] W) (e : U →ₗ[ℝ] V) (hde : d ∘ₗ e = 0)
    (x : V) (hx : x ∈ LinearMap.ker d) :
    ∃ u : U, ∃ h ∈ LinearMap.ker (hodgeLap d e), x = e u + h := by
  rw [← closed_eq_exact_sup_harmonic d e hde, Submodule.mem_sup] at hx
  obtain ⟨a, ha, h, hh, hsum⟩ := hx
  obtain ⟨u, rfl⟩ := ha
  exact ⟨u, h, hh, hsum.symm⟩

-- !-- Complementarity inside the closed space.  Pull `range e` and `ker Δ` back along
--    `(ker d).subtype`.  Disjoint: `comap` preserves `⊓`, and `range e ⊓ ker Δ = ⊥`.
--    Codisjoint: `Submodule.map (ker d).subtype` is injective and sends the sup to
--    `range e ⊔ ker Δ = ker d = map subtype ⊤`. -- !--
theorem hodge_isCompl (d : V →ₗ[ℝ] W) (e : U →ₗ[ℝ] V) (hde : d ∘ₗ e = 0) :
    IsCompl (Submodule.comap (LinearMap.ker d).subtype (LinearMap.range e))
      (Submodule.comap (LinearMap.ker d).subtype (LinearMap.ker (hodgeLap d e))) := by
  constructor
  · rw [disjoint_iff, ← Submodule.comap_inf]
    have hbot : LinearMap.range e ⊓ LinearMap.ker (hodgeLap d e) = ⊥ := by
      rw [inf_comm]; exact harmonic_inf_exact_eq_bot d e
    rw [hbot, Submodule.comap_bot, Submodule.ker_subtype]
  · rw [codisjoint_iff]
    apply Submodule.map_injective_of_injective
      (Submodule.injective_subtype (LinearMap.ker d))
    rw [Submodule.map_sup, Submodule.map_comap_subtype, Submodule.map_comap_subtype,
      Submodule.map_subtype_top, inf_of_le_right (range_e_le_ker_d d e hde),
      inf_of_le_right (harmonic_le_ker_d d e)]
    exact closed_eq_exact_sup_harmonic d e hde

/-- The **Hodge isomorphism**: the cohomology `Hᵏ = ker d / range e` is canonically
isomorphic to the harmonic space `ker Δ`.  Each cohomology class has a unique harmonic
representative. -/
noncomputable def hodgeCohomologyEquiv
```

## Phase A Future Directions (include in PACKAGE.json)

Phase A produced these future research directions. Include them verbatim
(or lightly edited for clarity) in the `future_directions` field of
PACKAGE.json so they appear in the "Future Directions" tab on the website.

```
# Future Directions — Hodge–Laplacian Message Passing, Fourth Cycle

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
| `hodge_isCompl` | Isomorphism | `range e`, `ker Δ` complementary insid
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
