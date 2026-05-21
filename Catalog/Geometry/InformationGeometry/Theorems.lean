/-
  Information Geometry: Core Theorems
  ====================================

  This file proves the main theorems of finite-dimensional information geometry:

  1. Fisher matrix is symmetric (Theorem 1a)
  2. Fisher matrix is positive semidefinite (Theorem 1b)
  3. Score has mean zero (Theorem 2)
  4. Cramér–Rao inequality — directional form (Theorem 3)
  5. Fisher = covariance of sufficient statistic for exponential families (Theorem 4)
  6. Convexity of log-partition function (cross-domain: convex analysis)
  7. Alpha-connection flatness for exponential families (Theorem 5)
-/

import Geometry.InformationGeometry.Defs

open Finset BigOperators Matrix

noncomputable section

variable {n : ℕ} {Ω : Type*} [Fintype Ω] [DecidableEq Ω]

/-! ## Theorem 1a: Fisher matrix is symmetric -/

/-- The Fisher information matrix is symmetric: I(θ) = I(θ)ᵀ.
    Follows from commutativity of multiplication: sᵢ·sⱼ = sⱼ·sᵢ. -/
theorem fisherMatrix_symmetric
    (M : FiniteStatModel (Fin n → ℝ) Ω)
    (dlogp : (Fin n → ℝ) → Ω → Fin n → ℝ) (θ : Fin n → ℝ) :
    (fisherMatrix M dlogp θ).IsSymm := by
  exact Matrix.ext fun i j => by
    simp +decide [fisherMatrix, mul_assoc, mul_comm, mul_left_comm]

/-! ## Auxiliary: Quadratic form equals sum of squares -/

/-
Key algebraic identity: v ᵀ I(θ) v = ∑_ω p(ω;θ) (∑ᵢ vᵢ sᵢ(θ,ω))².
-/
theorem fisher_quadratic_eq_weighted_square
    (M : FiniteStatModel (Fin n → ℝ) Ω)
    (dlogp : (Fin n → ℝ) → Ω → Fin n → ℝ) (θ : Fin n → ℝ) (v : Fin n → ℝ) :
    ∑ i, ∑ j, v i * fisherMatrix M dlogp θ i j * v j =
    ∑ ω : Ω, M.pmf θ ω * (∑ i, v i * dlogp θ ω i) ^ 2 := by
  simp +decide only [fisherMatrix, mul_comm];
  simp +decide [ Matrix.of_apply, sq, mul_assoc, mul_comm, mul_left_comm, Finset.mul_sum _ _ _, Finset.sum_mul ];
  exact Eq.symm ( Finset.sum_comm.trans ( Finset.sum_congr rfl fun _ _ => Finset.sum_comm.trans ( Finset.sum_congr rfl fun _ _ => Finset.sum_congr rfl fun _ _ => by ring ) ) )

/-! ## Theorem 1b: Fisher matrix is positive semidefinite -/

/-
The Fisher information matrix is positive semidefinite:
    v ᵀ I(θ) v ≥ 0 for all v.
-/
theorem fisherMatrix_posSemidef
    (M : FiniteStatModel (Fin n → ℝ) Ω)
    (dlogp : (Fin n → ℝ) → Ω → Fin n → ℝ) (θ : Fin n → ℝ) :
    ∀ v : Fin n → ℝ, 0 ≤ ∑ i, ∑ j, v i * fisherMatrix M dlogp θ i j * v j := by
  intro v
  rw [fisher_quadratic_eq_weighted_square];
  exact Finset.sum_nonneg fun ω _ => mul_nonneg ( M.pmf_nonneg θ ω ) ( sq_nonneg _ )

/-! ## Theorem 2: Score has mean zero -/

/-- The score has mean zero under regularity hypotheses. -/
theorem score_mean_zero
    (M : FiniteStatModel (Fin n → ℝ) Ω)
    (dlogp : (Fin n → ℝ) → Ω → Fin n → ℝ)
    (hreg : RegularityHypotheses M dlogp)
    (θ : Fin n → ℝ) :
    ∀ i : Fin n, ∑ ω : Ω, M.pmf θ ω * dlogp θ ω i = 0 :=
  hreg.score_mean_zero θ

/-! ## Weighted Cauchy–Schwarz -/

/-
Cauchy–Schwarz in weighted L²(p): (∑ p·f·g)² ≤ (∑ p·f²)(∑ p·g²) when p ≥ 0.
-/
theorem weighted_cauchy_schwarz
    (p f g : Ω → ℝ) (hp : ∀ ω, 0 ≤ p ω) :
    (∑ ω : Ω, p ω * f ω * g ω) ^ 2 ≤
    (∑ ω : Ω, p ω * f ω ^ 2) * (∑ ω : Ω, p ω * g ω ^ 2) := by
  -- By the Cauchy-Schwarz inequality, we have that for any vectors $v$ and $w$ of equal length, $(∑ i, v i * w i)^2 ≤ (∑ i, v i^2) * (∑ i, w i^2)$.
  have h_cauchy_schwarz : ∀ (v w : Ω → ℝ), (∑ i, v i * w i)^2 ≤ (∑ i, (v i)^2) * (∑ i, (w i)^2) := by
    exact?;
  convert h_cauchy_schwarz ( fun ω => Real.sqrt ( p ω ) * f ω ) ( fun ω => Real.sqrt ( p ω ) * g ω ) using 3 <;> ring_nf;
  · grind;
  · rw [ mul_comm, Real.sq_sqrt ( hp _ ) ];
  · rw [ mul_comm, Real.sq_sqrt ( hp _ ) ]

/-! ## Theorem 3: Cramér–Rao inequality (directional form) -/

/-
The directional Cramér–Rao inequality:
    (Dg(θ)[v])² ≤ Var_θ(T) · v ᵀ I(θ) v.

    The hypothesis `hcov` encodes the key identity that differentiating unbiasedness
    yields: ∑_ω p(ω) (T(ω) - E[T]) · (∑ᵢ vᵢ sᵢ(ω)) = Dg(θ)[v].
    Combined with Cauchy–Schwarz, this gives the bound.
-/
theorem cramerRao_directional
    (M : FiniteStatModel (Fin n → ℝ) Ω)
    (dlogp : (Fin n → ℝ) → Ω → Fin n → ℝ)
    (hreg : RegularityHypotheses M dlogp)
    (T : Ω → ℝ) (g : (Fin n → ℝ) → ℝ)
    (θ : Fin n → ℝ)
    (hcov : ∀ v : Fin n → ℝ,
      ∑ ω : Ω, M.pmf θ ω * (T ω - expectationAt M θ T) * (∑ i, v i * dlogp θ ω i) =
      directionalDeriv g θ v) :
    ∀ v : Fin n → ℝ,
      (directionalDeriv g θ v) ^ 2 ≤
      varianceAt M θ T * (∑ i, ∑ j, v i * fisherMatrix M dlogp θ i j * v j) := by
  -- Apply the weighted Cauchy-Schwarz inequality with the given p, f, and g.
  intros v
  have h_cauchy_schwarz : (∑ ω, M.pmf θ ω * (T ω - expectationAt M θ T) * (∑ i, v i * dlogp θ ω i)) ^ 2 ≤ (∑ ω, M.pmf θ ω * (T ω - expectationAt M θ T) ^ 2) * (∑ ω, M.pmf θ ω * (∑ i, v i * dlogp θ ω i) ^ 2) := by
    convert weighted_cauchy_schwarz ( fun ω => M.pmf θ ω ) ( fun ω => ( T ω - expectationAt M θ T ) ) ( fun ω => ∑ i, v i * dlogp θ ω i ) ( fun ω => M.pmf_nonneg θ ω ) using 1;
  convert h_cauchy_schwarz using 1 <;> push_cast [ ← hcov, fisher_quadratic_eq_weighted_square ] <;> ring!;

/-! ## Theorem 4: Fisher = sufficient statistic covariance for exponential families -/

/-
For an exponential family with natural score sᵢ(θ,ω) = Tᵢ(ω) − ηᵢ(θ),
    the Fisher matrix equals the covariance matrix of the sufficient statistic.
-/
theorem fisher_eq_sufficientStatCov
    (E : ExponentialFamily n Ω) (θ : Fin n → ℝ) :
    let dlogp := fun (θ' : Fin n → ℝ) (ω : Ω) (i : Fin n) =>
      E.suffStat ω i - expectationParameter E θ' i
    fisherMatrix E.toStatModel dlogp θ = sufficientStatCov E θ := by
  unfold fisherMatrix sufficientStatCov expectationParameter;
  simp +decide [ mul_sub, sub_mul, mul_assoc, Finset.sum_mul _ _ _, Finset.mul_sum ];
  simp +decide only [← Finset.mul_sum _ _ _, ← sum_mul, E.toStatModel.pmf_sum_one];
  simp +decide [ mul_assoc, mul_comm, mul_left_comm, Finset.mul_sum _ _ _, Finset.sum_mul ]

/-! ## Cross-domain: Convexity of log-partition -/

/-
The log-partition function of an exponential family is convex.
    ψ(θ) = log ∑_ω exp(⟨θ,T(ω)⟩ + k(ω)) is log-sum-exp of affine functions,
    hence convex. This connects information geometry to convex analysis and
    statistical physics (free energy convexity).
-/
set_option maxHeartbeats 800000 in
theorem logPartition_convex
    (E : ExponentialFamily n Ω) :
    ConvexOn ℝ Set.univ (logPartition E) := by
  refine' ⟨ convex_univ, _ ⟩;
  intro θ₁ _ θ₂ _ a b ha hb hab
  have h_log_sum_exp : Real.log (∑ ω : Ω, Real.exp (a * (∑ i, θ₁ i * E.suffStat ω i + E.baseMeasure ω) + b * (∑ i, θ₂ i * E.suffStat ω i + E.baseMeasure ω))) ≤ a * Real.log (∑ ω : Ω, Real.exp (∑ i, θ₁ i * E.suffStat ω i + E.baseMeasure ω)) + b * Real.log (∑ ω : Ω, Real.exp (∑ i, θ₂ i * E.suffStat ω i + E.baseMeasure ω)) := by
    have h_log_sum_exp : ∀ (x y : Ω → ℝ), (∀ ω, 0 ≤ x ω) → (∀ ω, 0 ≤ y ω) → (∑ ω, x ω ^ a * y ω ^ b) ≤ (∑ ω, x ω) ^ a * (∑ ω, y ω) ^ b := by
      intro x y hx hy
      have h_weighted_am_gm : ∀ (ω : Ω), x ω ^ a * y ω ^ b ≤ (x ω / (∑ ω, x ω)) ^ a * (y ω / (∑ ω, y ω)) ^ b * (∑ ω, x ω) ^ a * (∑ ω, y ω) ^ b := by
        intro ω; by_cases hω : ∑ ω, x ω = 0 <;> by_cases hω' : ∑ ω, y ω = 0 <;> simp_all +decide [ mul_assoc, mul_comm, mul_left_comm, div_eq_mul_inv ] ;
        · simp_all +decide [ Finset.sum_eq_zero_iff_of_nonneg ];
          by_cases ha' : a = 0 <;> by_cases hb' : b = 0 <;> simp +decide [ ha', hb' ];
        · by_cases ha : a = 0 <;> by_cases hb : b = 0 <;> simp_all +decide [ Finset.sum_eq_zero_iff_of_nonneg ];
          rw [ mul_left_comm, mul_inv_cancel₀ ( ne_of_gt ( lt_of_lt_of_le ( lt_of_le_of_ne ( hy _ ) ( Ne.symm hω'.choose_spec ) ) ( Finset.single_le_sum ( fun i _ => hy i ) ( Finset.mem_univ _ ) ) ) ), mul_one ];
        · simp_all +decide [ Finset.sum_eq_zero_iff_of_nonneg ];
          by_cases hb : b = 0 <;> simp_all +decide [ ne_of_gt ];
          rw [ mul_left_comm, mul_inv_cancel₀ ( ne_of_gt ( lt_of_lt_of_le ( lt_of_le_of_ne ( hx _ ) ( Ne.symm hω.choose_spec ) ) ( Finset.single_le_sum ( fun ω _ => hx ω ) ( Finset.mem_univ _ ) ) ) ), mul_one ];
        · rw [ Real.mul_rpow ( hx ω ) ( inv_nonneg.2 ( Finset.sum_nonneg fun _ _ => hx _ ) ), Real.mul_rpow ( hy ω ) ( inv_nonneg.2 ( Finset.sum_nonneg fun _ _ => hy _ ) ) ] ; ring_nf;
          simp +decide [ mul_assoc, mul_comm, mul_left_comm, Real.inv_rpow ( Finset.sum_nonneg fun _ _ => hx _ ), Real.inv_rpow ( Finset.sum_nonneg fun _ _ => hy _ ), hω, hω' ];
          simp +decide [ mul_left_comm ( ( ∑ ω, x ω ) ^ a ), mul_assoc, ne_of_gt ( Real.rpow_pos_of_pos ( show 0 < ∑ ω, x ω from lt_of_le_of_ne ( Finset.sum_nonneg fun _ _ => hx _ ) ( Ne.symm hω ) ) _ ), ne_of_gt ( Real.rpow_pos_of_pos ( show 0 < ∑ ω, y ω from lt_of_le_of_ne ( Finset.sum_nonneg fun _ _ => hy _ ) ( Ne.symm hω' ) ) _ ) ];
      refine' le_trans ( Finset.sum_le_sum fun ω _ => h_weighted_am_gm ω ) _;
      have h_weighted_am_gm_sum : ∑ ω, (x ω / (∑ ω, x ω)) ^ a * (y ω / (∑ ω, y ω)) ^ b ≤ 1 := by
        have h_weighted_am_gm_sum : ∀ (ω : Ω), (x ω / (∑ ω, x ω)) ^ a * (y ω / (∑ ω, y ω)) ^ b ≤ a * (x ω / (∑ ω, x ω)) + b * (y ω / (∑ ω, y ω)) := by
          intro ω;
          have := @Real.geom_mean_le_arith_mean;
          specialize this { 0, 1 } ( fun i => if i = 0 then a else b ) ( fun i => if i = 0 then x ω / ∑ ω, x ω else y ω / ∑ ω, y ω ) ; simp_all +decide;
          exact this ( div_nonneg ( hx ω ) ( Finset.sum_nonneg fun _ _ => hx _ ) ) ( div_nonneg ( hy ω ) ( Finset.sum_nonneg fun _ _ => hy _ ) );
        refine' le_trans ( Finset.sum_le_sum fun ω _ => h_weighted_am_gm_sum ω ) _;
        simp +decide [ Finset.sum_add_distrib, ← Finset.mul_sum _ _ _, ← Finset.sum_div, hab ];
        by_cases h : ∑ ω, x ω = 0 <;> by_cases h' : ∑ ω, y ω = 0 <;> simp +decide [ h, h' ];
        · linarith;
        · linarith;
        · linarith;
      simpa only [ ← mul_assoc, ← Finset.sum_mul _ _ _ ] using mul_le_of_le_one_left ( mul_nonneg ( Real.rpow_nonneg ( Finset.sum_nonneg fun _ _ => hx _ ) _ ) ( Real.rpow_nonneg ( Finset.sum_nonneg fun _ _ => hy _ ) _ ) ) h_weighted_am_gm_sum;
    convert Real.log_le_log ( Finset.sum_pos ( fun _ _ => ?_ ) ( Finset.univ_nonempty_iff.mpr ⟨ Classical.choose ( show ∃ ω, True from by
                                                                                                                    by_cases h : Nonempty Ω <;> simp_all +decide [ ExponentialFamily.partition_pos ];
                                                                                                                    exact absurd ( E.partition_pos 0 ) ( by simp +decide [ Finset.sum_empty ] ) ) ⟩ ) ) ( h_log_sum_exp ( fun ω => Real.exp ( ∑ i, θ₁ i * E.suffStat ω i + E.baseMeasure ω ) ) ( fun ω => Real.exp ( ∑ i, θ₂ i * E.suffStat ω i + E.baseMeasure ω ) ) ( fun ω => Real.exp_nonneg _ ) ( fun ω => Real.exp_nonneg _ ) ) using 1
    generalize_proofs at *;
    · simp +decide [ ← Real.exp_mul, ← Real.exp_add, mul_comm a, mul_comm b, hab ];
    · rw [ Real.log_mul ( ne_of_gt ( Real.rpow_pos_of_pos ( Finset.sum_pos ( fun _ _ => Real.exp_pos _ ) ( Finset.univ_nonempty_iff.mpr ⟨ Classical.choose ( show ∃ ω, True from by
                                                                                                                                                              by_cases h : Nonempty Ω <;> simp_all +decide [ ExponentialFamily.partition_pos ];
                                                                                                                                                              exact absurd ( E.partition_pos 0 ) ( by simp +decide [ Finset.sum_empty ] ) ) ⟩ ) ) _ ) ) ( ne_of_gt ( Real.rpow_pos_of_pos ( Finset.sum_pos ( fun _ _ => Real.exp_pos _ ) ( Finset.univ_nonempty_iff.mpr ⟨ Classical.choose ( show ∃ ω, True from by
                                                                                                                                                                                                                                                                                                                                              by_cases h : Nonempty Ω <;> simp_all +decide [ ExponentialFamily.partition_pos ];
                                                                                                                                                                                                                                                                                                                                              exact absurd ( E.partition_pos 0 ) ( by simp +decide [ Finset.sum_empty ] ) ) ⟩ ) ) _ ) ), Real.log_rpow ( Finset.sum_pos ( fun _ _ => Real.exp_pos _ ) ( Finset.univ_nonempty_iff.mpr ⟨ Classical.choose ( show ∃ ω, True from by
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            by_cases h : Nonempty Ω <;> simp_all +decide [ ExponentialFamily.partition_pos ];
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            exact absurd ( E.partition_pos 0 ) ( by simp +decide [ Finset.sum_empty ] ) ) ⟩ ) ), Real.log_rpow ( Finset.sum_pos ( fun _ _ => Real.exp_pos _ ) ( Finset.univ_nonempty_iff.mpr ⟨ Classical.choose ( show ∃ ω, True from by
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  by_cases h : Nonempty Ω <;> simp_all +decide [ ExponentialFamily.partition_pos ];
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  exact absurd ( E.partition_pos 0 ) ( by simp +decide [ Finset.sum_empty ] ) ) ⟩ ) ) ];
    · positivity;
  convert h_log_sum_exp using 2 ; simp +decide [ logPartition, Finset.sum_add_distrib, Finset.mul_sum _ _ _, Finset.sum_mul, mul_add, add_mul, mul_assoc, mul_comm, mul_left_comm, ← Finset.sum_smul, ← Finset.smul_sum, hab ];
  exact congr_arg _ ( Finset.sum_congr rfl fun _ _ => by rw [ ← eq_sub_iff_add_eq' ] at hab; subst hab; ring )

/-! ## Theorem 5: Alpha-connection flatness -/

/-
In natural coordinates, the (+1)-connection Christoffel symbols vanish
    when the Levi-Civita symbols equal −(1/2)C_{ijk}.
-/
theorem alpha_plus_one_flat_natural_coords
    (E : ExponentialFamily n Ω)
    (dlogp : (Fin n → ℝ) → Ω → Fin n → ℝ)
    (leviCivita : (Fin n → ℝ) → Fin n → Fin n → Fin n → ℝ)
    (θ : Fin n → ℝ)
    (hLC : ∀ i j k, leviCivita θ i j k =
      -(1/2) * amariChentsovTensor E.toStatModel dlogp θ i j k) :
    PlusOneFlat (alphaChristoffel E.toStatModel dlogp leviCivita 1 θ) := by
  intro i j k; simp [alphaChristoffel, hLC]

/-
Alpha-duality: the lowered Christoffel symbols of the (+α) and (−α) connections
    sum to twice the Levi-Civita symbol when the Amari–Chentsov tensor is symmetric.
-/
theorem alpha_connections_sum
    (M : FiniteStatModel (Fin n → ℝ) Ω)
    (dlogp : (Fin n → ℝ) → Ω → Fin n → ℝ)
    (leviCivita : (Fin n → ℝ) → Fin n → Fin n → Fin n → ℝ)
    (α : ℝ) (θ : Fin n → ℝ)
    (hACsymm : ∀ i j k, amariChentsovTensor M dlogp θ i j k =
      amariChentsovTensor M dlogp θ k j i)
    (hLCsymm : ∀ i j k, leviCivita θ k j i = leviCivita θ i j k) :
    ∀ i j k,
      alphaChristoffel M dlogp leviCivita α θ i j k +
      alphaChristoffel M dlogp leviCivita (-α) θ k j i =
      2 * leviCivita θ i j k := by
  unfold alphaChristoffel; intros; rw [ hLCsymm ] ; ring;
  rw [ hACsymm ] ; ring

end