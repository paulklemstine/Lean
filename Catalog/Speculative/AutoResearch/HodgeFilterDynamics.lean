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
    (hv : L v = ν • v) :
    ⟪mpFilter L αs v, mpFilter L αs v⟫_ℝ
      = ((αs.map (fun a => 1 - a * ν)).prod) ^ 2 * ⟪v, v⟫_ℝ := by
  rw [mpFilter_eigenvector L αs ν hv, real_inner_smul_left, real_inner_smul_right]
  ring

/-
!-- The degree-2 (heavy-ball) filter is the explicit quadratic in `L`:
`(1 − α·L)(1 − β·L) = 1 − (α+β)·L + αβ·L²`, exhibiting `mpFilter` as a genuine
polynomial of the operator (ring algebra in `Module.End ℝ E`). -- !--
-/
theorem mpStep_comp_eq (L : E →ₗ[ℝ] E) (α β : ℝ) :
    mpStep L α * mpStep L β
      = (1 : Module.End ℝ E) - (α + β) • L + (α * β) • (L * L) := by
  ext x; simp +decide [ mpStep ] ;
  module

end HodgeFilterDynamics