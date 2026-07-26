/-
# Triangular Lattice Bond Percolation: Exact Critical Threshold

The critical polynomial for homogeneous bond percolation on the triangular lattice
is `p³ - 3p + 1 = 0`. We prove:
1. This polynomial has exactly one root in (0,1).
2. That root equals `2 sin(π/18)`.
3. The dual honeycomb threshold is `1 - 2 sin(π/18)`.

These are classical results from exact percolation theory, following from
self-duality and star-triangle transformations on the triangular lattice.
-/

import Mathlib

open Real Set

noncomputable section

/-- The critical polynomial for triangular lattice bond percolation.
    The critical probability is the unique root of this polynomial in (0,1). -/
def triangularCriticalPolynomial (p : ℝ) : ℝ := p ^ 3 - 3 * p + 1

/-
The polynomial evaluates to 1 at p = 0.
-/
theorem triangularCriticalPolynomial_at_zero :
    triangularCriticalPolynomial 0 = 1 := by
      unfold triangularCriticalPolynomial; norm_num

/-
The polynomial evaluates to -1 at p = 1.
-/
theorem triangularCriticalPolynomial_at_one :
    triangularCriticalPolynomial 1 = -1 := by
      exact show ( 1 : ℝ ) ^ 3 - 3 * 1 + 1 = -1 by norm_num;

/-
The derivative of the critical polynomial is 3(p² - 1), which is negative on (0,1).
-/
theorem triangularCriticalPolynomial_deriv (p : ℝ) :
    HasDerivAt triangularCriticalPolynomial (3 * p ^ 2 - 3) p := by
      convert HasDerivAt.add ( HasDerivAt.sub ( hasDerivAt_pow 3 p ) ( HasDerivAt.const_mul 3 ( hasDerivAt_id p ) ) ) ( hasDerivAt_const p 1 ) using 1 ; ring

/-
The critical polynomial is strictly decreasing on [0, 1].
-/
theorem triangularCriticalPolynomial_strictAntiOn :
    StrictAntiOn triangularCriticalPolynomial (Icc 0 1) := by
      -- By definition of strict monotonicity, we need to show that if $0 \leq a < b \leq 1$, then $triangularCriticalPolynomial a > triangularCriticalPolynomial b$.
      simp [StrictAntiOn];
      exact fun a ha₁ ha₂ b hb₁ hb₂ hab => by unfold triangularCriticalPolynomial; nlinarith [ sq_nonneg ( a - b ), mul_le_mul_of_nonneg_left hab.le ( sub_nonneg.mpr ha₁ ) ] ;

/-
The critical polynomial is continuous.
-/
theorem triangularCriticalPolynomial_continuous :
    Continuous triangularCriticalPolynomial := by
      exact Continuous.add ( Continuous.sub ( continuous_pow 3 ) ( continuous_const.mul continuous_id' ) ) continuous_const

/-
There exists a root of the critical polynomial in the open interval (0, 1).
-/
theorem triangularCriticalPolynomial_has_root :
    ∃ p ∈ Ioo (0 : ℝ) 1, triangularCriticalPolynomial p = 0 := by
      apply_rules [ intermediate_value_Ioo' ] <;> norm_num [ triangularCriticalPolynomial ];
      exact Continuous.continuousOn <| by exact Continuous.add ( Continuous.sub ( continuous_pow 3 ) <| continuous_const.mul continuous_id' ) continuous_const;

/-
The root in (0, 1) is unique: the polynomial is strictly decreasing on [0,1],
    positive at 0, and negative at 1, so there is exactly one zero crossing.
-/
theorem exists_unique_triangular_bond_threshold :
    ∃! p : ℝ, p ∈ Ioo (0 : ℝ) 1 ∧ triangularCriticalPolynomial p = 0 := by
      -- We start by showing that there is a unique root of the critical polynomial in the interval (0, 1).
      have h_unique_root : ∀ p q : ℝ, p ∈ Ioo 0 1 → q ∈ Ioo 0 1 → triangularCriticalPolynomial p = 0 → triangularCriticalPolynomial q = 0 → p = q := by
        -- Assume that $p$ and $q$ are both roots of the critical polynomial in the interval $(0, 1)$.
        intros p q hp hq hp_root hq_root;
        exact StrictAntiOn.injOn ( triangularCriticalPolynomial_strictAntiOn ) ( Set.Ioo_subset_Icc_self hp ) ( Set.Ioo_subset_Icc_self hq ) ( hp_root.trans hq_root.symm );
      exact ⟨ _, triangularCriticalPolynomial_has_root.choose_spec, fun p hp => h_unique_root _ _ hp.1 triangularCriticalPolynomial_has_root.choose_spec.1 hp.2 triangularCriticalPolynomial_has_root.choose_spec.2 ⟩

/-
Key trigonometric identity: `sin(3θ) = 3 sin(θ) - 4 sin³(θ)`.
    This is used to show that `2 sin(π/18)` is a root of the critical polynomial.
-/
theorem sin_three_mul (θ : ℝ) :
    Real.sin (3 * θ) = 3 * Real.sin θ - 4 * Real.sin θ ^ 3 := by
      exact Real.sin_three_mul θ

/-
`2 sin(π/18)` satisfies the critical polynomial equation.
    Proof: Let s = sin(π/18). Then (2s)³ - 3(2s) + 1 = 8s³ - 6s + 1
    = -2(3s - 4s³) + 1 = -2 sin(3·π/18) + 1 = -2 sin(π/6) + 1 = -2·(1/2) + 1 = 0.
-/
theorem triangular_threshold_satisfies_poly :
    triangularCriticalPolynomial (2 * Real.sin (Real.pi / 18)) = 0 := by
      unfold triangularCriticalPolynomial;
      have := Real.sin_three_mul ( Real.pi / 18 ) ; rw [ ( by ring : 3 * ( Real.pi / 18 ) = Real.pi / 6 ) ] at this; norm_num at this; linarith;

/-
`2 sin(π/18)` lies in the interval (0, 1).
-/
theorem triangular_threshold_in_unit_interval :
    2 * Real.sin (Real.pi / 18) ∈ Ioo (0 : ℝ) 1 := by
      exact ⟨ mul_pos zero_lt_two ( Real.sin_pos_of_pos_of_lt_pi ( by positivity ) ( by linarith [ Real.pi_pos ] ) ), by nlinarith [ Real.sin_sq_add_cos_sq ( Real.pi / 18 ), show 0 < Real.cos ( Real.pi / 18 ) from Real.cos_pos_of_mem_Ioo ⟨ by linarith [ Real.pi_pos ], by linarith [ Real.pi_pos ] ⟩, show Real.sin ( Real.pi / 18 ) < 1 / 2 by rw [ ← Real.cos_pi_div_two_sub ] ; rw [ ← Real.cos_pi_div_three ] ; exact Real.cos_lt_cos_of_nonneg_of_le_pi ( by positivity ) ( by linarith [ Real.pi_pos ] ) ( by linarith [ Real.pi_pos ] ) ] ⟩

/-- **Main theorem**: The critical probability for bond percolation on the triangular
    lattice is `2 sin(π/18)`, and it is the unique root of `p³ - 3p + 1 = 0` in (0,1). -/
theorem triangular_bond_threshold_closed_form :
    let p := 2 * Real.sin (Real.pi / 18)
    p ∈ Ioo (0 : ℝ) 1 ∧ triangularCriticalPolynomial p = 0 := by
  exact ⟨triangular_threshold_in_unit_interval, triangular_threshold_satisfies_poly⟩

/-- **Honeycomb dual**: By duality, the honeycomb lattice bond percolation threshold
    is `1 - 2 sin(π/18)`, which satisfies the dual equation. -/
theorem honeycomb_bond_threshold_closed_form :
    let p := 1 - 2 * Real.sin (Real.pi / 18)
    p ∈ Ioo (0 : ℝ) 1 ∧ triangularCriticalPolynomial (1 - p) = 0 := by
  constructor
  · constructor
    · linarith [triangular_threshold_in_unit_interval.2]
    · linarith [triangular_threshold_in_unit_interval.1]
  · show triangularCriticalPolynomial (1 - (1 - 2 * Real.sin (Real.pi / 18))) = 0
    have : 1 - (1 - 2 * Real.sin (Real.pi / 18)) = 2 * Real.sin (Real.pi / 18) := by ring
    rw [this]
    exact triangular_threshold_satisfies_poly

/-
The square bond percolation duality map sends p to 1 - p.
    The unique fixed point is p = 1/2.
-/
theorem square_bond_duality_fixed_point :
    ∀ p : ℝ, (1 - p = p) ↔ p = 1 / 2 := by
      exact fun p => ⟨ fun h => by linarith, fun h => by linarith ⟩

end