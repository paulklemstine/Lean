import Mathlib

open Complex intervalIntegral

namespace KnottedLightDeepening

/-- Contour-integral winding over one azimuthal turn. -/
noncomputable def winding (γ : ℝ → ℂ) : ℂ :=
  (1 / (2 * Real.pi * Complex.I)) *
    ∫ θ in (0 : ℝ)..(2 * Real.pi), deriv γ θ / γ θ

/-- A globally smooth, nowhere-vanishing optical loop with a chosen continuous derivative. -/
structure IsSmoothLoop (γ γ' : ℝ → ℂ) : Prop where
  hasDeriv : ∀ θ, HasDerivAt γ (γ' θ) θ
  ne_zero : ∀ θ, γ θ ≠ 0
  contDeriv : Continuous γ'

namespace IsSmoothLoop

lemma deriv_eq {γ γ' : ℝ → ℂ} (hγ : IsSmoothLoop γ γ') (θ : ℝ) :
    deriv γ θ = γ' θ := by
  exact (hγ.hasDeriv θ).deriv

lemma logDeriv_continuous {γ γ' : ℝ → ℂ} (hγ : IsSmoothLoop γ γ') :
    Continuous (fun θ => deriv γ θ / γ θ) := by
  exact Continuous.div ( by rw [ show deriv γ = γ' from funext fun _ => hγ.deriv_eq _ ] ; exact hγ.contDeriv ) ( show Continuous γ from continuous_iff_continuousAt.mpr fun _ => DifferentiableAt.continuousAt ( by exact ( hγ.hasDeriv _ ) |> HasDerivAt.differentiableAt ) ) fun _ => hγ.ne_zero _

lemma logDeriv_intervalIntegrable {γ γ' : ℝ → ℂ} (hγ : IsSmoothLoop γ γ')
    (a b : ℝ) : IntervalIntegrable (fun θ => deriv γ θ / γ θ)
      (MeasureTheory.volume : MeasureTheory.Measure ℝ) a b := by
  exact hγ.logDeriv_continuous.intervalIntegrable a b

end IsSmoothLoop

/-
Multiplication closes smooth nonvanishing optical loops. This is the first
nontrivial structural step toward arbitrary composite beams.
-/
theorem smoothLoop_mul {γ γ' δ δ' : ℝ → ℂ}
    (hγ : IsSmoothLoop γ γ') (hδ : IsSmoothLoop δ δ') :
    IsSmoothLoop (fun θ => γ θ * δ θ)
      (fun θ => γ' θ * δ θ + γ θ * δ' θ) := by
  constructor;
  · exact fun θ => HasDerivAt.mul ( hγ.hasDeriv θ ) ( hδ.hasDeriv θ );
  · exact fun θ => mul_ne_zero ( hγ.ne_zero θ ) ( hδ.ne_zero θ );
  · exact Continuous.add ( Continuous.mul ( hγ.contDeriv ) ( show Continuous δ from continuous_iff_continuousAt.mpr fun _ => ( hδ.hasDeriv _ |> HasDerivAt.continuousAt ) ) ) ( Continuous.mul ( show Continuous γ from continuous_iff_continuousAt.mpr fun _ => ( hγ.hasDeriv _ |> HasDerivAt.continuousAt ) ) ( hδ.contDeriv ) )

/-
The logarithmic derivative of a product splits pointwise. Besides using
`smoothLoop_mul`, this records the exact analytic identity behind charge conservation.
-/
theorem logDeriv_mul {γ γ' δ δ' : ℝ → ℂ}
    (hγ : IsSmoothLoop γ γ') (hδ : IsSmoothLoop δ δ') (θ : ℝ) :
    deriv (fun t => γ t * δ t) θ / (γ θ * δ θ) =
      deriv γ θ / γ θ + deriv δ θ / δ θ := by
  -- By definition of the derivative, we know that
  have h_deriv : deriv (fun t => γ t * δ t) θ = γ' θ * δ θ + γ θ * δ' θ := by
    convert HasDerivAt.deriv ( HasDerivAt.mul ( hγ.hasDeriv θ ) ( hδ.hasDeriv θ ) ) using 1;
  rw [ h_deriv, IsSmoothLoop.deriv_eq hγ, IsSmoothLoop.deriv_eq hδ, div_add_div ] <;> ring <;> simp +decide [ hγ.ne_zero, hδ.ne_zero ]

/-
**General contour-integral product law.** Multiplication of arbitrary smooth,
nowhere-zero fields adds their winding charges.
-/
theorem winding_mul {γ γ' δ δ' : ℝ → ℂ}
    (hγ : IsSmoothLoop γ γ') (hδ : IsSmoothLoop δ δ') :
    winding (fun θ => γ θ * δ θ) = winding γ + winding δ := by
  unfold winding;
  rw [ ← mul_add, ← intervalIntegral.integral_add ];
  · exact congrArg _ ( intervalIntegral.integral_congr fun x _ => logDeriv_mul hγ hδ x );
  · exact hγ.logDeriv_intervalIntegrable _ _;
  · exact hδ.logDeriv_intervalIntegrable _ _

/-
Iterated coherent multiplication remains nonsingular and multiplies winding
by the number of factors. This simultaneously strengthens closure and conservation.
-/
theorem smoothLoop_pow_and_winding {γ γ' : ℝ → ℂ} (hγ : IsSmoothLoop γ γ') :
    ∀ n : ℕ,
      IsSmoothLoop (fun θ => (γ θ) ^ n)
        (fun θ => (n : ℂ) * (γ θ) ^ (n - 1) * γ' θ) ∧
      winding (fun θ => (γ θ) ^ n) = (n : ℂ) * winding γ := by
  intro n;
  induction' n with n ih;
  · constructor;
    · constructor <;> norm_num;
      · exact fun _ => hasDerivAt_const _ _;
      · exact continuous_const;
    · unfold winding; norm_num;
  · constructor;
    · convert smoothLoop_mul ih.1 hγ using 1;
      ext; cases n <;> norm_num [ pow_succ' ] ; ring;
    · have := winding_mul ( ih.1 ) hγ; simp_all +decide [ pow_succ, mul_assoc ] ; ring;

/-- The winding-power law, extracted as a reusable statement for optical fields. -/
theorem winding_pow {γ γ' : ℝ → ℂ} (hγ : IsSmoothLoop γ γ') (n : ℕ) :
    winding (fun θ => (γ θ) ^ n) = (n : ℂ) * winding γ := by
  exact (smoothLoop_pow_and_winding hγ n).2

/-
Pointwise inversion preserves smoothness and nonvanishing.
-/
theorem smoothLoop_inv {γ γ' : ℝ → ℂ} (hγ : IsSmoothLoop γ γ') :
    IsSmoothLoop (fun θ => (γ θ)⁻¹)
      (fun θ => -(γ' θ) / (γ θ) ^ 2) := by
  constructor;
  · intro θ;
    convert HasDerivAt.comp θ ( hasDerivAt_inv ( hγ.ne_zero θ ) ) ( hγ.hasDeriv θ ) using 1 ; ring;
  · exact fun θ => inv_ne_zero <| hγ.ne_zero θ;
  · exact Continuous.div ( by exact Continuous.neg hγ.contDeriv ) ( by exact Continuous.pow ( by exact continuous_iff_continuousAt.mpr fun _ => HasDerivAt.continuousAt ( hγ.hasDeriv _ ) ) _ ) fun x => pow_ne_zero _ ( hγ.ne_zero _ )

/-
Reversing the optical phase negates its contour-integral charge. The proof
uses the product law on `γ⁻¹ · γ = 1`, rather than recomputing the integral.
-/
theorem winding_inv {γ γ' : ℝ → ℂ} (hγ : IsSmoothLoop γ γ') :
    winding (fun θ => (γ θ)⁻¹) = -winding γ := by
  have := smoothLoop_inv hγ;
  have := winding_mul this hγ;
  rw [ eq_neg_iff_add_eq_zero, ← this ];
  unfold winding; norm_num [ hγ.ne_zero ] ;

/-
**Integer power law.** Arbitrary positive or negative coherent powers scale
the charge by the same integer. This extends `winding_pow` from `ℕ` to `ℤ`.
-/
theorem winding_zpow {γ γ' : ℝ → ℂ} (hγ : IsSmoothLoop γ γ') (k : ℤ) :
    winding (fun θ => (γ θ) ^ k) = (k : ℂ) * winding γ := by
  obtain ⟨ n, rfl | rfl ⟩ := Int.eq_nat_or_neg k;
  · simpa using winding_pow hγ n;
  · convert winding_pow ( smoothLoop_inv hγ ) n using 1 ; norm_num;
    rw [ winding_inv hγ ] ; push_cast ; ring

/-
Every integer power of a smooth nonvanishing loop again has some continuous
chosen derivative. The witness is existential because its closed form differs
between positive and negative powers.
-/
theorem smoothLoop_zpow {γ γ' : ℝ → ℂ} (hγ : IsSmoothLoop γ γ') (k : ℤ) :
    ∃ η' : ℝ → ℂ, IsSmoothLoop (fun θ => (γ θ) ^ k) η' := by
  obtain ⟨n, hn⟩ : ∃ n : ℕ, k = n ∨ k = -n := by
    exact ⟨ Int.natAbs k, by cases abs_cases k <;> simp +decide [ * ] ⟩;
  rcases hn with ( rfl | rfl );
  · exact ⟨ _, smoothLoop_pow_and_winding hγ n |>.1 ⟩;
  · have := smoothLoop_pow_and_winding ( smoothLoop_inv hγ ) n; aesop;

/-
**Two-mode integer superposition law.** For arbitrary smooth nonvanishing
modes, independently powering the modes and multiplying them gives the integral
linear combination of their charges.
-/
theorem winding_mul_zpow {γ γ' δ δ' : ℝ → ℂ}
    (hγ : IsSmoothLoop γ γ') (hδ : IsSmoothLoop δ δ') (k l : ℤ) :
    winding (fun θ => (γ θ) ^ k * (δ θ) ^ l) =
      (k : ℂ) * winding γ + (l : ℂ) * winding δ := by
  -- We will obtain the derivative witnesses for the power loops via smoothLoop_zpow.
  obtain ⟨ηγ, hηγ⟩ := smoothLoop_zpow hγ k
  obtain ⟨ηδ, hηδ⟩ := smoothLoop_zpow hδ l;
  rw [ winding_mul hηγ hηδ, winding_zpow hγ k, winding_zpow hδ l ]

end KnottedLightDeepening