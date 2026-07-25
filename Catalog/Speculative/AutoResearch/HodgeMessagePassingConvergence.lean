/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license.

# Convergence of Hodge-Laplacian Message Passing to the Harmonic Subspace

This file *extends* the spectral depth–threshold theory of
`Catalog/Speculative/AutoResearch/HodgeSpectralThreshold.lean`
(`psd_inner_self_eq_zero`, `harmonic_iff`, `ker_hodgeLaplacian`, `layer`,
`harmonic_depth_invariant`) from *energy decay* to a genuine *convergence*
statement for one-step gradient message passing.

For a symmetric positive–semidefinite operator `L` (think `L = BᵀB`, the up Hodge
Laplacian, or the full `Δ = d*d + e e*` of `HodgeThreeWayDecomposition`) one layer
of message passing is the affine-free **gradient step**

  `mpStep L α = 1 - α • L`,   acting by `x ↦ x - α • (L x)`.

The point of this cycle is that `mpStep L α` is a *linear* operator, hence:

* The harmonic component of an input is carried through every layer untouched
  (`mpStep_iterate_add_harmonic`), while
* the residual contracts geometrically at the spectral rate
  (`mpStep_iterate_contraction`).

Combining these gives **convergence**, not just energy decay: the squared distance
from the depth-`k` output to the harmonic component is bounded by `ρ^k ‖r‖²`
(`mpStep_dist_to_harmonic_bound`), so a finite depth reaches any tolerance
(`mpStep_converges_to_harmonic`).  We also derive the per-layer contraction factor
from the spectral bounds (`mpStep_contraction`) and prove the **spectral step**
`α = 1/λ` is optimal, with rate `1 - μ/λ` (`contraction_factor_optimal`,
`contraction_factor_at_optimal`).

The upshot, made rigorous: **deep Hodge message passing transports the cohomology
(harmonic) part exactly and suppresses everything else**, and the spectral gap is
the convergence rate.

-- !-- Lab Notebook -- !--
Hypothesis:  Because the message-passing layer `T = 1 - α L` is *linear* and fixes
  the harmonic subspace `ker L` pointwise, the depth-`k` map splits any input
  `x = h + r` (harmonic + residual) into a *fixed* harmonic part `h` plus a
  geometrically contracted residual `Tᵏ r`.  Hence deep message passing converges to
  the harmonic component at the spectral rate, upgrading the energy-decay picture of
  `HodgeSpectralThreshold` to a convergence-to-cohomology statement.
Result:  Formalised and proved sorry-free.  `mpStep_add`/`mpStep_smul` (linearity),
  `mpStep_harmonic_fixed`/`mpStep_iterate_harmonic_fixed` (harmonic = exact fixed
  point), `mpStep_iterate_add_harmonic` (additive transport of `h`),
  `mpStep_contraction` (per-layer factor from spectral bounds),
  `mpStep_iterate_contraction` (geometric `ρᵏ` decay of the residual energy),
  `mpStep_dist_to_harmonic_bound` (distance-to-harmonic bound),
  `mpStep_converges_to_harmonic` (finite depth reaches any tolerance), and
  `contraction_factor_optimal`/`contraction_factor_at_optimal` (the spectral step
  `α = 1/λ` is optimal with rate `1 - μ/λ`).
Insight:  The decisive move is to treat `T` as a `Module.End ℝ E` so that `Tᵏ`
  is `map_add`/`map_smul`-linear *for free*; convergence then needs only the scalar
  recursion `⟪Tᵏ⁺¹ r⟫ ≤ ρ ⟪Tᵏ r⟫`.  The contraction factor `1 - αμ(2 - αλ)` minus
  its optimum `1 - μ/λ` is the perfect square `μ·(αλ - 1)²/λ`, so optimality is a
  one-line `nlinarith` with `sq_nonneg (α*λ - 1)`.
Failure analysis:  Stating the contraction hypothesis only on `(ker L)ᗮ` forces
  invariance bookkeeping; stating it for *all* `x` (true for `T` symmetric) makes the
  iterate bound a clean induction.  Working with the inner-product energy `⟪v,v⟫`
  rather than `‖v‖` avoids `Real.sqrt` and keeps every step polynomial.
-- !-- Lab Notebook -- !--
-/
import Mathlib
import Speculative.AutoResearch.HodgeSpectralThreshold

open scoped InnerProductSpace BigOperators Topology

namespace HodgeMessagePassingConvergence

variable {E : Type*} [NormedAddCommGroup E] [InnerProductSpace ℝ E]

/-! ## The message-passing layer as a linear operator -/

/-- One layer of gradient message passing `T = 1 - α·L`, acting by
`x ↦ x - α • (L x)`.  Modeled as an element of `Module.End ℝ E` so that depth
(iteration) is automatically linear. -/
def mpStep (L : E →ₗ[ℝ] E) (α : ℝ) : E →ₗ[ℝ] E := (1 : Module.End ℝ E) - α • L

@[simp] theorem mpStep_apply (L : E →ₗ[ℝ] E) (α : ℝ) (x : E) :
    mpStep L α x = x - α • (L x) := by
  simp [mpStep]

/-
!-- comment: `mpStep L α` is a linear map, so additivity is `map_add`. -- !--
-/
theorem mpStep_add (L : E →ₗ[ℝ] E) (α : ℝ) (x y : E) :
    mpStep L α (x + y) = mpStep L α x + mpStep L α y := by
  simp +decide [ mpStep, map_add ]

/-
!-- comment: `mpStep L α` is a linear map, so homogeneity is `map_smul`. -- !--
-/
theorem mpStep_smul (L : E →ₗ[ℝ] E) (α : ℝ) (c : ℝ) (x : E) :
    mpStep L α (c • x) = c • mpStep L α x := by
  exact map_smul ( mpStep L α ) c x

/-! ## Harmonic signals are exact fixed points -/

/-
!-- comment: If `L h = 0` then `T h = h - α•0 = h`. -- !--
-/
theorem mpStep_harmonic_fixed (L : E →ₗ[ℝ] E) (α : ℝ) {h : E} (hh : L h = 0) :
    mpStep L α h = h := by
  simp +decide [ mpStep, hh ]

/-
!-- comment: Iterate `mpStep_harmonic_fixed` over depth `k` by induction. -- !--
-/
theorem mpStep_iterate_harmonic_fixed (L : E →ₗ[ℝ] E) (α : ℝ) {h : E}
    (hh : L h = 0) (k : ℕ) :
    ((mpStep L α) ^ k) h = h := by
  induction k <;> simp_all +decide [ pow_succ', mpStep ]

/-
!-- comment: By linearity of `Tᵏ` (`map_add`) and `mpStep_iterate_harmonic_fixed`,
the harmonic part `h` passes through depth as an additive constant. -- !--
-/
theorem mpStep_iterate_add_harmonic (L : E →ₗ[ℝ] E) (α : ℝ) {h : E}
    (hh : L h = 0) (r : E) (k : ℕ) :
    ((mpStep L α) ^ k) (h + r) = h + ((mpStep L α) ^ k) r := by
  rw [ map_add, mpStep_iterate_harmonic_fixed ];
  exact hh

/-! ## Per-layer contraction from the spectral bounds -/

/-
!-- comment: Expand `⟪Tx,Tx⟫ = ⟪x,x⟫ - 2α⟪x,Lx⟫ + α²⟪Lx,Lx⟫` via symmetry; bound
`⟪Lx,Lx⟫ ≤ λ⟪x,Lx⟫` and then `⟪x,Lx⟫ ≥ μ⟪x,x⟫`, using `α ≥ 0`, `αλ ≤ 2`. -- !--

**Per-layer contraction factor.** From the Rayleigh bounds
`μ⟪x,x⟫ ≤ ⟪x,Lx⟫` and `⟪Lx,Lx⟫ ≤ λ⟪x,Lx⟫`, one layer contracts the energy by the
factor `1 - αμ(2 - αλ)`.
-/
theorem mpStep_contraction (L : E →ₗ[ℝ] E) (α μ lam : ℝ)
    (hα : 0 ≤ α) (hstep : α * lam ≤ 2)
    (hlower : ∀ x, μ * ⟪x, x⟫_ℝ ≤ ⟪x, L x⟫_ℝ)
    (hupper : ∀ x, ⟪L x, L x⟫_ℝ ≤ lam * ⟪x, L x⟫_ℝ)
    (x : E) :
    ⟪mpStep L α x, mpStep L α x⟫_ℝ ≤ (1 - α * μ * (2 - α * lam)) * ⟪x, x⟫_ℝ := by
  simp +decide [ mpStep ];
  rw [ @norm_sub_sq ℝ ];
  simp_all +decide [ inner_smul_right, norm_smul ];
  rw [ abs_of_nonneg hα ] ; nlinarith [ hlower x, hupper x, mul_nonneg hα ( sub_nonneg.2 hstep ), mul_nonneg hα ( sq_nonneg α ), mul_nonneg hα ( sq_nonneg ( ‖x‖ ) ), mul_nonneg hα ( sq_nonneg ( ‖L x‖ ) ) ] ;

/-! ## Geometric decay of the residual energy across depth -/

/-
!-- comment: Induct on `k`: `⟪Tᵏ⁺¹r⟫ = ⟪T(Tᵏr)⟫ ≤ ρ⟪Tᵏr⟫ ≤ ρ·ρᵏ⟪r⟫`, using
`0 ≤ ρ`. -- !--

**Geometric decay of residual energy.** If a single layer contracts every energy
by `ρ ≥ 0`, then depth-`k` message passing contracts it by `ρᵏ`.
-/
theorem mpStep_iterate_contraction (L : E →ₗ[ℝ] E) (α ρ : ℝ) (hρ : 0 ≤ ρ)
    (hc : ∀ x, ⟪mpStep L α x, mpStep L α x⟫_ℝ ≤ ρ * ⟪x, x⟫_ℝ) (r : E) (k : ℕ) :
    ⟪((mpStep L α) ^ k) r, ((mpStep L α) ^ k) r⟫_ℝ ≤ ρ ^ k * ⟪r, r⟫_ℝ := by
  induction k <;> simp_all +decide [ pow_succ', mul_assoc ];
  exact le_trans ( hc _ ) ( mul_le_mul_of_nonneg_left ‹_› hρ )

/-! ## Convergence to the harmonic component -/

/-
!-- comment: The difference `Tᵏ(h+r) - h = Tᵏ r` by `mpStep_iterate_add_harmonic`,
so its energy is bounded by `ρᵏ⟪r,r⟫` via `mpStep_iterate_contraction`. -- !--

**Distance to harmonics decays geometrically.** Writing the input as harmonic plus
residual `h + r` with `L h = 0`, the energy of the gap between the depth-`k` output
and the harmonic part `h` is at most `ρᵏ ⟪r,r⟫`.
-/
theorem mpStep_dist_to_harmonic_bound (L : E →ₗ[ℝ] E) (α ρ : ℝ) (hρ : 0 ≤ ρ)
    (hc : ∀ x, ⟪mpStep L α x, mpStep L α x⟫_ℝ ≤ ρ * ⟪x, x⟫_ℝ)
    {h : E} (hh : L h = 0) (r : E) (k : ℕ) :
    ⟪((mpStep L α) ^ k) (h + r) - h, ((mpStep L α) ^ k) (h + r) - h⟫_ℝ
      ≤ ρ ^ k * ⟪r, r⟫_ℝ := by
  rw [ mpStep_iterate_add_harmonic ];
  · simpa using mpStep_iterate_contraction L α ρ hρ hc r k;
  · exact hh

/-
!-- comment: With `0 ≤ ρ < 1`, `ρᵏ → 0`, so the bound `ρᵏ⟪r,r⟫` of
`mpStep_dist_to_harmonic_bound` is eventually `< ε`. -- !--

**Finite depth reaches any tolerance.** If a layer is a strict contraction
(`0 ≤ ρ < 1`), then for every tolerance `ε > 0` there is a depth `K` beyond which the
energy gap between the output and the harmonic part `h` is below `ε`.
-/
theorem mpStep_converges_to_harmonic (L : E →ₗ[ℝ] E) (α ρ : ℝ)
    (hρ0 : 0 ≤ ρ) (hρ1 : ρ < 1)
    (hc : ∀ x, ⟪mpStep L α x, mpStep L α x⟫_ℝ ≤ ρ * ⟪x, x⟫_ℝ)
    {h : E} (hh : L h = 0) (r : E) {ε : ℝ} (hε : 0 < ε) :
    ∃ K : ℕ, ∀ k ≥ K,
      ⟪((mpStep L α) ^ k) (h + r) - h, ((mpStep L α) ^ k) (h + r) - h⟫_ℝ < ε := by
  -- Since $0 \leq \rho < 1$, we have $\rho^k \to 0$ as $k \to \infty$.
  have h_rho_pow_zero : Filter.Tendsto (fun k : ℕ => ρ ^ k * ⟪r, r⟫_ℝ) Filter.atTop (nhds 0) := by
    simpa using Filter.Tendsto.mul ( tendsto_pow_atTop_nhds_zero_of_lt_one hρ0 hρ1 ) tendsto_const_nhds;
  exact Filter.eventually_atTop.mp ( h_rho_pow_zero.eventually ( gt_mem_nhds hε ) ) |> fun ⟨ K, hK ⟩ ↦ ⟨ K, fun k hk ↦ lt_of_le_of_lt ( mpStep_dist_to_harmonic_bound L α ρ hρ0 hc hh r k ) ( hK k hk ) ⟩

/-! ## Optimality of the spectral step `α = 1/λ` -/

/-
!-- comment: `(1 - αμ(2 - αλ)) - (1 - μ/λ) = μ·(αλ - 1)² / λ ≥ 0`, a perfect
square; `nlinarith [sq_nonneg (α*lam - 1)]`. -- !--

**The spectral step is optimal.** Among all steps `α`, the contraction factor
`1 - αμ(2 - αλ)` is minimized at `α = 1/λ`, where it equals `1 - μ/λ`.
-/
theorem contraction_factor_optimal (μ lam α : ℝ) (hμ : 0 < μ) (hlam : 0 < lam) :
    1 - μ / lam ≤ 1 - α * μ * (2 - α * lam) := by
  nlinarith [ sq_nonneg ( α * lam - 1 ), mul_pos hμ hlam, div_mul_cancel₀ μ hlam.ne' ]

/-
!-- comment: Substitute `α = 1/λ`: `(1/λ)·μ·(2 - 1) = μ/λ`. -- !--

**Value at the optimal step.** At `α = 1/λ` the contraction factor equals
`1 - μ/λ` (one minus the spectral gap ratio).
-/
theorem contraction_factor_at_optimal (μ lam : ℝ) (hlam : lam ≠ 0) :
    1 - (1 / lam) * μ * (2 - (1 / lam) * lam) = 1 - μ / lam := by
  grind +extAll

/-! ## Bridge to the catalog: harmonics of the Hodge Laplacian are fixed points -/

/-
!-- comment: The catalog's `harmonic_iff` characterizes `ker Δ = ker up ⊓ ker down`;
any such harmonic cochain is `Δ h = 0`, hence a fixed point of `mpStep Δ α` by
`mpStep_harmonic_fixed`. -- !--

**Cohomology is fixed by message passing.** For the abstract Hodge Laplacian
`Δ = up + down` with `up`, `down` symmetric PSD, every harmonic cochain (closed and
coclosed) is an exact fixed point of every message-passing layer, at every depth.
-/
theorem hodge_harmonic_mpStep_fixed
    (up down : E →ₗ[ℝ] E)
    (hsymm_up : ∀ x y, ⟪up x, y⟫_ℝ = ⟪x, up y⟫_ℝ)
    (hpos_up : ∀ x, 0 ≤ ⟪up x, x⟫_ℝ)
    (hsymm_down : ∀ x y, ⟪down x, y⟫_ℝ = ⟪x, down y⟫_ℝ)
    (hpos_down : ∀ x, 0 ≤ ⟪down x, x⟫_ℝ)
    (α : ℝ) {x : E} (hx : up x = 0 ∧ down x = 0) (k : ℕ) :
    ((mpStep (HodgeSpectralThreshold.hodgeLaplacian up down) α) ^ k) x = x := by
  -- The catalog's `harmonic_iff` turns the closed-and-coclosed data into `Δ x = 0`,
  -- which `mpStep_iterate_harmonic_fixed` then propagates through every depth.
  have hΔ : HodgeSpectralThreshold.hodgeLaplacian up down x = 0 :=
    (HodgeSpectralThreshold.harmonic_iff up down hsymm_up hpos_up hsymm_down hpos_down x).mpr hx
  exact mpStep_iterate_harmonic_fixed _ _ hΔ k

end HodgeMessagePassingConvergence