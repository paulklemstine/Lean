/-! # CatalogBuild.Speculative.Other.GapMatterResearch

Auto-generated from theorem catalog database.
Domain: Speculative/Other
Declarations: 34
-/

import Mathlib

noncomputable section

/-- [Section: # CatalogBuild.Speculative.Other.GapMatterResearch
Auto-generated from theorem catalog database.
Domain: Speculative/Other
Declarations: 34] -/
theorem photon_addresses_measure_zero :
    MeasureTheory.volume (Set.range (Nat.cast : ℕ → ℝ)) = 0 := by
      rw [ Set.countable_range _ |> Set.Countable.measure_zero ]




/-- [Section: # CatalogBuild.Speculative.Other.GapMatterResearch
Auto-generated from theorem catalog database.
Domain: Speculative/Other
Declarations: 34] -/
theorem gaps_have_full_measure :
    MeasureTheory.volume (Set.range (Nat.cast : ℕ → ℝ))ᶜ = ⊤ := by
      rw [ MeasureTheory.measure_compl ] <;> norm_num [ photon_addresses_measure_zero ];
      exact Set.countable_range _ |> Set.Countable.measurableSet




/-- No natural number lies strictly between n and n+1 (the gap is truly empty of photons). -/
theorem gap_contains_no_photon (n : ℕ) :
    ¬ ∃ m : ℕ, (n : ℝ) < (m : ℝ) ∧ (m : ℝ) < (n : ℝ) + 1 := by
  push_neg
  intro m hm
  have : (n : ℝ) < (m : ℝ) := hm
  have h1 : n < m := by exact_mod_cast this
  linarith [show (m : ℝ) ≥ (n : ℝ) + 1 from by exact_mod_cast h1]




theorem gap_is_uncountable (n : ℕ) :
    ¬ Set.Countable (Set.Ioo (n : ℝ) ((n : ℝ) + 1)) := by
      aesop




/-- The Stokes-Minkowski form. -/
def stokesMinkowskiForm (S₀ S₁ S₂ S₃ : ℝ) : ℝ :=
  S₀^2 - S₁^2 - S₂^2 - S₃^2




theorem mixing_creates_mass
    (S₁ S₂ S₃ T₁ T₂ T₃ I : ℝ)
    (hI : I > 0)
    (hS : I^2 = S₁^2 + S₂^2 + S₃^2)
    (hT : I^2 = T₁^2 + T₂^2 + T₃^2)
    (hne : (S₁, S₂, S₃) ≠ (T₁, T₂, T₃)) :
    stokesMinkowskiForm I ((S₁ + T₁)/2) ((S₂ + T₂)/2) ((S₃ + T₃)/2) > 0 := by
      unfold stokesMinkowskiForm;
      linarith [ sq_nonneg ( S₁ - T₁ ), sq_nonneg ( S₂ - T₂ ), sq_nonneg ( S₃ - T₃ ), show 0 < ( S₁ - T₁ ) ^ 2 + ( S₂ - T₂ ) ^ 2 + ( S₃ - T₃ ) ^ 2 from not_le.mp fun h => hne <| by congr <;> nlinarith only [ h ] ]




theorem null_sphere_has_measure_zero :
    MeasureTheory.volume {p : EuclideanSpace ℝ (Fin 3) |
      p 0 ^ 2 + p 1 ^ 2 + p 2 ^ 2 = 1} = 0 := by
        -- The sphere is a smooth codimension-1 submanifold of ℝ³ and hence has Lebesgue measure zero.
        have h_sphere_measure_zero : MeasureTheory.volume (Metric.sphere (0 : EuclideanSpace ℝ (Fin 3)) 1) = 0 := by
          norm_num [ MeasureTheory.Measure.addHaar_sphere ];
        convert h_sphere_measure_zero using 1;
        congr ; ext ; simp +decide [ EuclideanSpace.norm_eq, Fin.sum_univ_three ]




theorem timelike_ball_positive_measure :
    MeasureTheory.volume {p : EuclideanSpace ℝ (Fin 3) |
      p 0 ^ 2 + p 1 ^ 2 + p 2 ^ 2 < 1} > 0 := by
        refine' ( lt_of_lt_of_le _ ( MeasureTheory.measure_mono _ ) );
        case refine'_2 => exact Metric.ball 0 ( 1 / 2 );
        · norm_num [ EuclideanSpace.volume_ball ];
          exact ⟨ by positivity, by positivity ⟩;
        · intro p hp; have := hp.out; norm_num [ EuclideanSpace.norm_eq ] at *;
          rw [ Real.sqrt_lt' ] at this <;> norm_num [ Fin.sum_univ_three ] at * ; nlinarith




theorem gap_interpolation_massive
    (S₁ S₂ S₃ T₁ T₂ T₃ I : ℝ)
    (hI : I > 0)
    (hS : I^2 = S₁^2 + S₂^2 + S₃^2)
    (hT : I^2 = T₁^2 + T₂^2 + T₃^2)
    (hne : (S₁, S₂, S₃) ≠ (T₁, T₂, T₃))
    (t : ℝ) (ht0 : 0 < t) (ht1 : t < 1) :
    isTimelike I
      ((1-t) * S₁ + t * T₁)
      ((1-t) * S₂ + t * T₂)
      ((1-t) * S₃ + t * T₃) := by
        -- By the properties of the dot product and the fact that $S$ and $T$ are distinct, we have $S₁T₁ + S₂T₂ + S₃T₃ < I²$.
        have h_dot_product : S₁ * T₁ + S₂ * T₂ + S₃ * T₃ < I^2 := by
          contrapose! hne;
          exact Prod.ext ( by nlinarith [ sq_nonneg ( S₁ - T₁ ), sq_nonneg ( S₁ + T₁ ), sq_nonneg ( S₂ - T₂ ), sq_nonneg ( S₂ + T₂ ), sq_nonneg ( S₃ - T₃ ), sq_nonneg ( S₃ + T₃ ) ] ) ( Prod.ext ( by nlinarith [ sq_nonneg ( S₁ - T₁ ), sq_nonneg ( S₁ + T₁ ), sq_nonneg ( S₂ - T₂ ), sq_nonneg ( S₂ + T₂ ), sq_nonneg ( S₃ - T₃ ), sq_nonneg ( S₃ + T₃ ) ] ) ( by nlinarith [ sq_nonneg ( S₁ - T₁ ), sq_nonneg ( S₁ + T₁ ), sq_nonneg ( S₂ - T₂ ), sq_nonneg ( S₂ + T₂ ), sq_nonneg ( S₃ - T₃ ), sq_nonneg ( S₃ + T₃ ) ] ) );
        exact show 0 < I ^ 2 - ( ( 1 - t ) * S₁ + t * T₁ ) ^ 2 - ( ( 1 - t ) * S₂ + t * T₂ ) ^ 2 - ( ( 1 - t ) * S₃ + t * T₃ ) ^ 2 from by nlinarith [ mul_pos ht0 ( sub_pos.2 ht1 ) ] ;




theorem midpoint_maximum_mass
    (S₁ S₂ S₃ T₁ T₂ T₃ I : ℝ)
    (hS : I^2 = S₁^2 + S₂^2 + S₃^2)
    (hT : I^2 = T₁^2 + T₂^2 + T₃^2)
    (t : ℝ) (ht0 : 0 ≤ t) (ht1 : t ≤ 1) :
    stokesMinkowskiForm I
      ((1-t) * S₁ + t * T₁)
      ((1-t) * S₂ + t * T₂)
      ((1-t) * S₃ + t * T₃)
    ≤ stokesMinkowskiForm I
      ((S₁ + T₁)/2)
      ((S₂ + T₂)/2)
      ((S₃ + T₃)/2) := by
        unfold stokesMinkowskiForm; ring_nf; norm_num; nlinarith [ sq_nonneg ( t - 1 / 2 ), mul_self_nonneg ( S₁ - T₁ ), mul_self_nonneg ( S₂ - T₂ ), mul_self_nonneg ( S₃ - T₃ ) ] ;




/-- **Theorem 6 (Parabolic Mass Profile)**:
The Minkowski norm of the interpolated state is a quadratic function of t,
vanishing at t=0 and t=1, with maximum at t=1/2.
Explicitly: η(S(t)) = t(1-t) · [2I² - 2(S⃗·T⃗)]
where S⃗·T⃗ = S₁T₁ + S₂T₂ + S₃T₃. -/
theorem parabolic_mass_profile
    (S₁ S₂ S₃ T₁ T₂ T₃ I : ℝ)
    (hS : I^2 = S₁^2 + S₂^2 + S₃^2)
    (hT : I^2 = T₁^2 + T₂^2 + T₃^2)
    (t : ℝ) :
    stokesMinkowskiForm I
      ((1-t) * S₁ + t * T₁)
      ((1-t) * S₂ + t * T₂)
      ((1-t) * S₃ + t * T₃)
    = t * (1 - t) * (2 * I^2 - 2 * (S₁*T₁ + S₂*T₂ + S₃*T₃)) := by
  unfold stokesMinkowskiForm
  nlinarith [sq_nonneg (S₁ - T₁), sq_nonneg (S₂ - T₂), sq_nonneg (S₃ - T₃),
             sq_nonneg ((1-t)*S₁ + t*T₁), sq_nonneg ((1-t)*S₂ + t*T₂),
             sq_nonneg ((1-t)*S₃ + t*T₃), sq_nonneg t, sq_nonneg (1-t)]




/-- **Experiment 1**: H-polarized photon (1,1,0,0) is null. -/
theorem experiment_H_null : isNull 1 1 0 0 := by
  unfold isNull stokesMinkowskiForm; ring




/-- **Experiment 2**: V-polarized photon (1,-1,0,0) is null. -/
theorem experiment_V_null : isNull 1 (-1) 0 0 := by
  unfold isNull stokesMinkowskiForm; ring




/-- **Experiment 3**: 50-50 mixture of H and V is unpolarized (1,0,0,0), which is timelike. -/
theorem experiment_HV_mix_timelike : isTimelike 1 0 0 0 := by
  unfold isTimelike stokesMinkowskiForm; norm_num




/-- **Experiment 4**: The mass of the H+V mixture. -/
theorem experiment_HV_mass : stokesMinkowskiForm 1 0 0 0 = 1 := by
  unfold stokesMinkowskiForm; ring




/-- **Experiment 5**: At t = 1/4, the interpolation between H and V. -/
theorem experiment_interpolation_quarter :
    stokesMinkowskiForm 1 ((3/4)*1 + (1/4)*(-1)) 0 0 = 1 - (1/2)^2 := by
  unfold stokesMinkowskiForm; ring




/-- **Experiment 6**: Verify parabolic formula for H-V interpolation.
S⃗·T⃗ = 1·(-1) + 0 + 0 = -1, so η(t) = t(1-t)·(2-2·(-1)) = 4t(1-t). -/
theorem experiment_HV_parabola (t : ℝ) :
    stokesMinkowskiForm 1 ((1-t)*1 + t*(-1)) 0 0 = 4 * t * (1 - t) := by
  unfold stokesMinkowskiForm; ring




/-- **Experiment 7**: The H+V parabola achieves maximum value 1 at t = 1/2. -/
theorem experiment_HV_max : 4 * (1/2 : ℝ) * (1 - 1/2) = 1 := by ring




/-- The degree of polarization. -/
def degreeOfPolarization (S₀ S₁ S₂ S₃ : ℝ) (hS₀ : S₀ > 0) : ℝ :=
  Real.sqrt (S₁^2 + S₂^2 + S₃^2) / S₀




/-- **Theorem 8 (Mass from Depolarization)**:
The Stokes-Minkowski "mass" equals S₀²(1 - p²) where p is the degree of polarization. -/
theorem mass_from_depolarization (S₀ S₁ S₂ S₃ : ℝ) (hS₀ : S₀ > 0)
    (hp : S₁^2 + S₂^2 + S₃^2 ≤ S₀^2) :
    stokesMinkowskiForm S₀ S₁ S₂ S₃ =
    S₀^2 * (1 - (degreeOfPolarization S₀ S₁ S₂ S₃ hS₀)^2) := by
  unfold degreeOfPolarization stokesMinkowskiForm
  rw [div_pow, Real.sq_sqrt (by nlinarith [sq_nonneg S₁, sq_nonneg S₂, sq_nonneg S₃])]
  field_simp
  ring




/-- Fully polarized light has zero mass. -/
theorem fully_polarized_zero_mass (S₀ S₁ S₂ S₃ : ℝ)
    (h : S₀^2 = S₁^2 + S₂^2 + S₃^2) :
    stokesMinkowskiForm S₀ S₁ S₂ S₃ = 0 := by
  unfold stokesMinkowskiForm; linarith




/-- Unpolarized light has maximum mass S₀². -/
theorem unpolarized_max_mass (S₀ : ℝ) :
    stokesMinkowskiForm S₀ 0 0 0 = S₀^2 := by
  unfold stokesMinkowskiForm; ring




/-- **Theorem 9 (Two-Photon Mass Formula)**:
Two photons with Stokes vectors S and T (both null, same intensity I)
produce a combined state with mass 2I²(1 - cos θ) where θ is the
angle between their polarization directions on the Poincaré sphere.
cos θ = (S⃗·T⃗)/I² for unit-intensity photons. -/
theorem two_photon_mass_formula
    (S₁ S₂ S₃ T₁ T₂ T₃ I : ℝ)
    (hI : I > 0)
    (hS : I^2 = S₁^2 + S₂^2 + S₃^2)
    (hT : I^2 = T₁^2 + T₂^2 + T₃^2) :
    stokesMinkowskiForm (2*I) (S₁ + T₁) (S₂ + T₂) (S₃ + T₃)
    = 2 * (I^2 - (S₁*T₁ + S₂*T₂ + S₃*T₃)) := by
  unfold stokesMinkowskiForm; nlinarith [sq_nonneg (S₁ - T₁), sq_nonneg (S₂ - T₂),
    sq_nonneg (S₃ - T₃), sq_nonneg (S₁ + T₁), sq_nonneg (S₂ + T₂), sq_nonneg (S₃ + T₃)]




/-- Orthogonal photons (cos θ = 0 on Poincaré sphere) produce maximum mass 2I². -/
theorem orthogonal_photons_max_mass (S₁ S₂ S₃ T₁ T₂ T₃ I : ℝ)
    (hS : I^2 = S₁^2 + S₂^2 + S₃^2)
    (hT : I^2 = T₁^2 + T₂^2 + T₃^2)
    (horth : S₁*T₁ + S₂*T₂ + S₃*T₃ = 0) :
    stokesMinkowskiForm (2*I) (S₁ + T₁) (S₂ + T₂) (S₃ + T₃) = 2 * I^2 := by
  unfold stokesMinkowskiForm; nlinarith [sq_nonneg (S₁ + T₁), sq_nonneg (S₂ + T₂),
    sq_nonneg (S₃ + T₃), sq_nonneg (S₁ - T₁), sq_nonneg (S₂ - T₂), sq_nonneg (S₃ - T₃)]




/-- Parallel photons (cos θ = 1, same polarization) produce zero mass. -/
theorem parallel_photons_zero_mass (S₁ S₂ S₃ I : ℝ)
    (hS : I^2 = S₁^2 + S₂^2 + S₃^2) :
    stokesMinkowskiForm (2*I) (2*S₁) (2*S₂) (2*S₃) = 0 := by
  unfold stokesMinkowskiForm; nlinarith [sq_nonneg S₁, sq_nonneg S₂, sq_nonneg S₃]




/-- **Theorem 10 (Massive Dispersion Relation)**:
A Stokes vector with degree of polarization p satisfies
S₀² = |S⃗|² + m² where m² = S₀²(1-p²). This is exactly
the relativistic dispersion relation E² = p² + m².
In other words: **partially polarized light IS a massive particle
in Stokes-Minkowski space.** -/
theorem massive_dispersion_relation (S₀ S₁ S₂ S₃ : ℝ)
    (hS₀ : S₀ > 0) (hp : S₁^2 + S₂^2 + S₃^2 ≤ S₀^2) :
    S₀^2 = (S₁^2 + S₂^2 + S₃^2) + stokesMinkowskiForm S₀ S₁ S₂ S₃ := by
  unfold stokesMinkowskiForm; ring




/-- The "mass" is non-negative for physical Stokes vectors. -/
theorem stokes_mass_nonneg (S₀ S₁ S₂ S₃ : ℝ)
    (hp : S₁^2 + S₂^2 + S₃^2 ≤ S₀^2) :
    stokesMinkowskiForm S₀ S₁ S₂ S₃ ≥ 0 := by
  unfold stokesMinkowskiForm; nlinarith




/-- The "mass" is zero iff the light is fully polarized. -/
theorem mass_zero_iff_fully_polarized (S₀ S₁ S₂ S₃ : ℝ)
    (hS₀ : S₀ > 0) (hp : S₁^2 + S₂^2 + S₃^2 ≤ S₀^2) :
    stokesMinkowskiForm S₀ S₁ S₂ S₃ = 0 ↔ S₁^2 + S₂^2 + S₃^2 = S₀^2 := by
  unfold stokesMinkowskiForm; constructor <;> intro h <;> nlinarith




theorem gaps_uncountable : ¬ Set.Countable (Set.range (Nat.cast : ℕ → ℝ))ᶜ := by
  intro h;
  have := h.union ( Set.countable_range ( Nat.cast : ℕ → ℝ ) );
  exact absurd this ( by rw [ Set.compl_union_self ] ; exact Cardinal.not_countable_real )




/-- ℕ is countable (the photon addresses are a "thin" set). -/
theorem addresses_countable : Set.Countable (Set.range (Nat.cast : ℕ → ℝ)) := by
  exact Set.countable_range Nat.cast




/-- **Hypothesis A formalized**: Entropy formula for partially polarized light.
For a state with degree of polarization p, the effective number of
"mass modes" is 1/(1-p²), and the entropy is related to this. -/
theorem entropy_mass_connection (p : ℝ) (hp0 : 0 ≤ p) (hp1 : p < 1)
    (S₀ : ℝ) (hS₀ : S₀ > 0) :
    stokesMinkowskiForm S₀ (p * S₀) 0 0 = S₀^2 * (1 - p^2) := by
  unfold stokesMinkowskiForm; ring




/-- **Hypothesis D formalized**: The decoherence trajectory for H→V interpolation. -/
theorem decoherence_trajectory (t : ℝ) :
    stokesMinkowskiForm 1 (1 - 2*t) 0 0 = 4 * t * (1 - t) := by
  unfold stokesMinkowskiForm; ring




/-- The maximum decoherence (maximum mass) occurs at the midpoint. -/
theorem max_decoherence_at_midpoint :
    ∀ t : ℝ, 0 ≤ t → t ≤ 1 → 4 * t * (1 - t) ≤ 1 := by
  intro t ht0 ht1
  nlinarith [sq_nonneg (2*t - 1)]




/-- The decoherence mass vanishes at the endpoints. -/
theorem decoherence_zero_at_endpoints :
    4 * (0:ℝ) * (1 - 0) = 0 ∧ 4 * (1:ℝ) * (1 - 1) = 0 := by
  constructor <;> ring




end
