/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license.

# The Deep Limit of Hodge-Laplacian Message Passing is the Cohomology Projector

This file *extends* two earlier cycles:

* `Catalog/Speculative/AutoResearch/HodgeSpectralThreshold.lean`
  (`hodgeLaplacian`, `harmonic_iff`, `harmonic_orthogonal_invariant`,
  `depth_threshold`) — the static harmonic/cohomology backbone and energy decay;
* `Catalog/Speculative/AutoResearch/HodgeMessagePassingConvergence.lean`
  (`mpStep`, `mpStep_iterate_add_harmonic`, `mpStep_iterate_harmonic_fixed`,
  `mpStep_iterate_contraction`, `contraction_factor_at_optimal`) — the move from
  energy decay to convergence-below-ε.

The previous convergence cycle assumed a contraction "for all `x`".  With a rate
`ρ < 1` that hypothesis is only satisfiable when `ker L = 0` — it secretly
trivialises the very harmonics it is meant to preserve (a harmonic `h` is fixed,
so `⟪Th,Th⟫ = ⟪h,h⟫ ≤ ρ⟪h,h⟫` forces `h = 0`).  This cycle replaces it with a
strict contraction **only on the residual subspace** `(ker L)ᗮ`, and closes the
loop from *"the residual energy gets small"* to *"the network computes a canonical
object"*:

1. `(ker L)ᗮ` is invariant under one layer `T = 1 - α·L` for symmetric `L`
   (`mpStep_mem_orthogonal`), at every depth (`mpStep_iterate_mem_orthogonal`),
   so the geometric `ρᵏ` residual-energy decay survives the weakening of the
   hypothesis (`mpStep_iterate_contraction_orthogonal`).
2. Depth-`k` message passing on any input converges **in norm** to the orthogonal
   projection onto the harmonic subspace (`mpStep_iterate_tendsto_harmonic`,
   `mpStep_deep_limit_eq_cohomology_projection`): deep Hodge message passing *is*
   the cohomology projector.  The bridge
   `hodge_deep_limit_is_harmonic_projection` instantiates this at the abstract
   combinatorial Hodge Laplacian `Δ = up + down`.
3. The non-constructive `∃ K` of the prior cycle is replaced by an explicit,
   logarithm-free stopping rule `criticalDepth ρ R ε`, proved correct via a
   Bernoulli bound (`criticalDepth_energy_bound`).

-- !-- Lab Notebook -- !--
Hypothesis:  The prior cycle's "contraction for all `x`" is mathematically
  dishonest at rate `ρ < 1` (it kills the harmonics).  The honest statement is a
  contraction on the residual subspace `(ker L)ᗮ` only; combined with invariance of
  that subspace under one layer, this should still yield geometric residual decay,
  and the geometric decay should upgrade from energy to *norm* convergence, so the
  deep limit literally equals the orthogonal projection onto cohomology.
Result:  Formalised and proved sorry-free.  `mpStep_mem_orthogonal` /
  `mpStep_iterate_mem_orthogonal` (subspace invariance), the corrected
  `mpStep_iterate_contraction_orthogonal` (`ρᵏ` residual decay under the honest
  hypothesis), `mpStep_iterate_tendsto_harmonic` (norm convergence of `Tᵏ(h+r)` to
  `h`), `mpStep_deep_limit_eq_cohomology_projection` (finite-dim: `Tᵏ x →
  starProjection x` for *every* input), `criticalDepth` + `criticalDepth_energy_bound`
  (explicit log-free depth), and `hodge_deep_limit_is_harmonic_projection` (the
  bridge to `Δ = up + down`).
Insight:  Energy `⟪v,v⟫ = ‖v‖²` is the bridge between the polynomial spectral
  estimates and the analytic limit: the `ρᵏ‖r‖²` energy bound squeezes `‖Tᵏr‖² → 0`,
  whence `Tᵏ(h+r) → h` by `tendsto_iff_dist_tendsto_zero`.  The deep limit then needs
  only the orthogonal decomposition `x = starProjection x + (x - starProjection x)`,
  available in finite dimension.  The log-free depth is pure Bernoulli:
  `(1/ρ)ᵏ ≥ 1 + k(1-ρ)/ρ` makes `ρᵏ R ≤ R/(k(1-ρ)) ≤ ε`.
Failure analysis:  Restricting the contraction to `(ker L)ᗮ` forces the invariance
  bookkeeping (`mpStep_iterate_mem_orthogonal`) that the all-`x` version dodged, but
  that bookkeeping is exactly what makes the hypothesis satisfiable at all.  Working
  with `⟪v,v⟫` rather than `‖v‖` keeps the spectral estimates polynomial; the single
  `Real.sqrt` is deferred to the very last analytic step.
-- !-- Lab Notebook -- !--
-/
import Mathlib
import Speculative.AutoResearch.HodgeSpectralThreshold
import Speculative.AutoResearch.HodgeMessagePassingConvergence

open scoped InnerProductSpace BigOperators Topology

namespace HodgeDeepLimit

open HodgeMessagePassingConvergence HodgeSpectralThreshold

variable {E : Type*} [NormedAddCommGroup E] [InnerProductSpace ℝ E]

/-! ## The residual subspace `(ker L)ᗮ` is invariant under a layer -/

/-
!-- comment: For `y ∈ ker L`, symmetry gives `⟪Lx,y⟫ = ⟪x,Ly⟫ = 0`, so
`⟪Tx,y⟫ = ⟪x,y⟫ - α⟪Lx,y⟫ = 0`; hence `Tx ⟂ ker L`.  (Generalises the catalog's
`harmonic_orthogonal_invariant`.) -- !--

**Residual invariance (one layer).** For symmetric `L`, the orthogonal complement
of the kernel is invariant under one message-passing layer `T = 1 - α·L`.
-/
theorem mpStep_mem_orthogonal (L : E →ₗ[ℝ] E) (α : ℝ)
    (hsymm : ∀ x y, ⟪L x, y⟫_ℝ = ⟪x, L y⟫_ℝ)
    {x : E} (hx : x ∈ (LinearMap.ker L)ᗮ) :
    mpStep L α x ∈ (LinearMap.ker L)ᗮ := by
  intro h hh; specialize hx h hh; simp_all +decide [ mpStep_apply, inner_sub_left, inner_smul_left, inner_smul_right ] ;
  simp_all +decide [ inner_sub_right, inner_smul_right ];
  exact Or.inr ( by rw [ ← hsymm, hh, inner_zero_left ] )

/-
!-- comment: Induct on `k` using `mpStep_mem_orthogonal` one layer at a time. -- !--

**Residual invariance (all depths).** Residual-subspace membership persists under
every iterate of the layer.
-/
theorem mpStep_iterate_mem_orthogonal (L : E →ₗ[ℝ] E) (α : ℝ)
    (hsymm : ∀ x y, ⟪L x, y⟫_ℝ = ⟪x, L y⟫_ℝ)
    {x : E} (hx : x ∈ (LinearMap.ker L)ᗮ) (k : ℕ) :
    ((mpStep L α) ^ k) x ∈ (LinearMap.ker L)ᗮ := by
  refine' Nat.recOn k _ _ <;> simp_all +decide [ pow_succ' ];
  intro n hn; exact mpStep_mem_orthogonal L α hsymm hn;

/-! ## Geometric decay of the residual energy under the *honest* hypothesis -/

/-
!-- comment: Induct on `k`.  `Tᵏ r` stays in `(ker L)ᗮ` by
`mpStep_iterate_mem_orthogonal`, so the subspace contraction `hcontract` applies at
each step: `⟪Tᵏ⁺¹r⟫ ≤ ρ⟪Tᵏr⟫ ≤ ρ·ρᵏ⟪r⟫`. -- !--

**Geometric residual decay (corrected).** If a single layer contracts the energy
of every residual vector by `ρ ≥ 0`, then depth-`k` message passing contracts the
energy of a residual input by `ρᵏ`.  Unlike the all-`x` hypothesis of the previous
cycle, this one is satisfiable without trivialising `ker L`.
-/
theorem mpStep_iterate_contraction_orthogonal (L : E →ₗ[ℝ] E) (α ρ : ℝ) (hρ : 0 ≤ ρ)
    (hsymm : ∀ x y, ⟪L x, y⟫_ℝ = ⟪x, L y⟫_ℝ)
    (hcontract : ∀ x ∈ (LinearMap.ker L)ᗮ,
      ⟪mpStep L α x, mpStep L α x⟫_ℝ ≤ ρ * ⟪x, x⟫_ℝ)
    {r : E} (hr : r ∈ (LinearMap.ker L)ᗮ) (k : ℕ) :
    ⟪((mpStep L α) ^ k) r, ((mpStep L α) ^ k) r⟫_ℝ ≤ ρ ^ k * ⟪r, r⟫_ℝ := by
  induction' k with k ih;
  · simp +decide;
  · convert le_trans ( hcontract _ ( mpStep_iterate_mem_orthogonal L α hsymm hr k ) ) ( mul_le_mul_of_nonneg_left ih hρ ) using 1 ; simp +decide [ pow_succ', mul_assoc ];
    ring

/-! ## Vector convergence to the harmonic component -/

/-
!-- comment: `Tᵏ(h+r) - h = Tᵏ r` (`mpStep_iterate_add_harmonic`), and
`‖Tᵏr‖² = ⟪Tᵏr,Tᵏr⟫ ≤ ρᵏ‖r‖² → 0`, so `‖Tᵏr‖ → 0`; conclude with
`tendsto_iff_dist_tendsto_zero`. -- !--

**Norm convergence to cohomology.** Depth-`k` message passing on a harmonic-plus-
residual input `h + r` (with `L h = 0`, `r ∈ (ker L)ᗮ`) converges *in norm* to the
harmonic part `h`.
-/
theorem mpStep_iterate_tendsto_harmonic (L : E →ₗ[ℝ] E) (α ρ : ℝ)
    (hρ0 : 0 ≤ ρ) (hρ1 : ρ < 1)
    (hsymm : ∀ x y, ⟪L x, y⟫_ℝ = ⟪x, L y⟫_ℝ)
    (hcontract : ∀ x ∈ (LinearMap.ker L)ᗮ,
      ⟪mpStep L α x, mpStep L α x⟫_ℝ ≤ ρ * ⟪x, x⟫_ℝ)
    {h r : E} (hh : L h = 0) (hr : r ∈ (LinearMap.ker L)ᗮ) :
    Filter.Tendsto (fun k => ((mpStep L α) ^ k) (h + r)) Filter.atTop (𝓝 h) := by
  rw [ tendsto_iff_norm_sub_tendsto_zero ];
  have h_norm_sq : Filter.Tendsto (fun k => ⟪((mpStep L α) ^ k) r, ((mpStep L α) ^ k) r⟫_ℝ) Filter.atTop (𝓝 0) := by
    refine' squeeze_zero ( fun k => by exact real_inner_self_nonneg ) ( fun k => mpStep_iterate_contraction_orthogonal L α ρ hρ0 hsymm hcontract hr k ) _;
    simpa using Filter.Tendsto.mul ( tendsto_pow_atTop_nhds_zero_of_lt_one hρ0 hρ1 ) tendsto_const_nhds;
  convert h_norm_sq.sqrt using 2 ; simp +decide [ real_inner_self_eq_norm_sq, mpStep_iterate_add_harmonic L α hh r ];
  norm_num

/-
!-- comment: Decompose `x = starProjection x + (x - starProjection x)` with the first
summand in `ker L` (so `L · = 0`) and the second in `(ker L)ᗮ`; apply
`mpStep_iterate_tendsto_harmonic`. -- !--

**Deep message passing is the cohomology projector.** In finite dimension, for every
input `x`, depth-`k` message passing converges in norm to the orthogonal projection
of `x` onto the harmonic subspace `ker L`.
-/
theorem mpStep_deep_limit_eq_cohomology_projection [FiniteDimensional ℝ E]
    (L : E →ₗ[ℝ] E) (α ρ : ℝ) (hρ0 : 0 ≤ ρ) (hρ1 : ρ < 1)
    (hsymm : ∀ x y, ⟪L x, y⟫_ℝ = ⟪x, L y⟫_ℝ)
    (hcontract : ∀ x ∈ (LinearMap.ker L)ᗮ,
      ⟪mpStep L α x, mpStep L α x⟫_ℝ ≤ ρ * ⟪x, x⟫_ℝ)
    (x : E) :
    Filter.Tendsto (fun k => ((mpStep L α) ^ k) x) Filter.atTop
      (𝓝 ((LinearMap.ker L).starProjection x)) := by
  convert mpStep_iterate_tendsto_harmonic L α ρ hρ0 hρ1 hsymm hcontract _ _;
  rw [ add_sub_cancel ];
  · exact LinearMap.mem_ker.mp ( Submodule.coe_mem _ );
  · exact Submodule.sub_starProjection_mem_orthogonal x

/-! ## A constructive, logarithm-free critical depth -/

/-- An explicit, logarithm-free stopping rule: the smallest depth our Bernoulli
bound certifies drives a residual of energy `≤ R` below tolerance `ε` at rate `ρ`. -/
noncomputable def criticalDepth (ρ R ε : ℝ) : ℕ := ⌈R / ((1 - ρ) * ε)⌉₊ + 1

/-
!-- comment: For `0 < ρ < 1`, Bernoulli `(1/ρ)ᵏ ≥ 1 + k(1-ρ)/ρ` gives
`ρᵏ ≤ ρ/(k(1-ρ) + ρ) ≤ 1/(k(1-ρ))`, so `ρᵏ R ≤ R/(k(1-ρ)) ≤ ε` once
`k ≥ R/((1-ρ)ε)`; the `+1` covers `ρ = 0` (then `ρᵏ = 0`). -- !--

**The explicit depth works.** At the explicit, log-free depth `criticalDepth ρ R ε`,
the geometric factor `ρᵏ` drives any residual energy `R` below the tolerance `ε`.
-/
theorem criticalDepth_energy_bound (ρ R ε : ℝ) (hρ0 : 0 ≤ ρ) (hρ1 : ρ < 1)
    (hR : 0 ≤ R) (hε : 0 < ε) :
    ρ ^ (criticalDepth ρ R ε) * R ≤ ε := by
  by_cases hρ : ρ = 0;
  · simp +decide [ hρ, criticalDepth ];
    linarith;
  · -- Use Bernoulli's inequality: $(1/ρ)^k ≥ 1 + k(1-ρ)/ρ$.
    have h_bernoulli : (1 / ρ) ^ (criticalDepth ρ R ε) ≥ 1 + (criticalDepth ρ R ε) * (1 - ρ) / ρ := by
      have h_bernoulli : ∀ k : ℕ, (1 + (1 - ρ) / ρ) ^ k ≥ 1 + k * (1 - ρ) / ρ := by
        exact fun k => by simpa [ mul_div_assoc ] using one_add_mul_le_pow ( by nlinarith [ div_mul_cancel₀ ( 1 - ρ ) hρ ] ) k;
      convert h_bernoulli ( criticalDepth ρ R ε ) using 1 ; ring;
      norm_num [ hρ ];
    -- Rearrange Bernoulli's inequality to get $\rho^k \leq \frac{1}{1 + k(1-\rho)/\rho}$.
    have h_rearrange : ρ ^ (criticalDepth ρ R ε) ≤ 1 / (1 + (criticalDepth ρ R ε) * (1 - ρ) / ρ) := by
      simpa using inv_anti₀ ( by exact add_pos_of_pos_of_nonneg zero_lt_one <| div_nonneg ( mul_nonneg ( Nat.cast_nonneg _ ) <| sub_nonneg.mpr hρ1.le ) hρ0 ) h_bernoulli;
    refine le_trans ( mul_le_mul_of_nonneg_right h_rearrange hR ) ?_;
    rw [ div_mul_eq_mul_div, div_le_iff₀ ];
    · rw [ add_div', mul_div, le_div_iff₀ ] <;> try positivity;
      unfold criticalDepth at *;
      have := Nat.le_ceil ( R / ( ( 1 - ρ ) * ε ) ) ; rw [ div_le_iff₀ ] at this <;> norm_num at * <;> nlinarith [ mul_pos hε ( sub_pos.mpr hρ1 ) ] ;
    · exact add_pos_of_pos_of_nonneg zero_lt_one ( div_nonneg ( mul_nonneg ( Nat.cast_nonneg _ ) ( sub_nonneg.mpr hρ1.le ) ) hρ0 )

/-! ## Bridge to the catalog: the abstract Hodge Laplacian `Δ = up + down` -/

/-
!-- comment: A direct instantiation of `mpStep_deep_limit_eq_cohomology_projection`
at `L = hodgeLaplacian up down` of `HodgeSpectralThreshold`. -- !--

**Deep simplicial message passing computes the harmonic projection.** For the
abstract combinatorial Hodge Laplacian `Δ = up + down`, in finite dimension, deep
message passing converges (in norm, on every input) to the orthogonal projection
onto the harmonic (cohomology) subspace `ker Δ`. -/
theorem hodge_deep_limit_is_harmonic_projection [FiniteDimensional ℝ E]
    (up down : E →ₗ[ℝ] E) (α ρ : ℝ) (hρ0 : 0 ≤ ρ) (hρ1 : ρ < 1)
    (hsymm : ∀ x y, ⟪hodgeLaplacian up down x, y⟫_ℝ
              = ⟪x, hodgeLaplacian up down y⟫_ℝ)
    (hcontract : ∀ x ∈ (LinearMap.ker (hodgeLaplacian up down))ᗮ,
      ⟪mpStep (hodgeLaplacian up down) α x, mpStep (hodgeLaplacian up down) α x⟫_ℝ
        ≤ ρ * ⟪x, x⟫_ℝ)
    (x : E) :
    Filter.Tendsto (fun k => ((mpStep (hodgeLaplacian up down) α) ^ k) x) Filter.atTop
      (𝓝 ((LinearMap.ker (hodgeLaplacian up down)).starProjection x)) :=
  mpStep_deep_limit_eq_cohomology_projection _ α ρ hρ0 hρ1 hsymm hcontract x

end HodgeDeepLimit