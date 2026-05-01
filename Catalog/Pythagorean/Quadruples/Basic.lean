import Mathlib

/-! # CatalogBuild.Speculative.Other.Basic

Auto-generated from theorem catalog database.
Domain: Speculative/Other
Declarations: 15
-/

noncomputable section

/-- ε₀ (epsilon-zero): the least fixed point of `ω ^ ·` above 0.
This is the supremum of the omega tower and satisfies ω^(ε₀) = ε₀. -/
noncomputable def epsilon0 : Ordinal.{0} := Ordinal.nfp (omega0 ^ ·) 0

/-- [Section: # CatalogBuild.Speculative.Other.Basic
Auto-generated from theorem catalog database.
Domain: Speculative/Other
Declarations: 15] -/
theorem omegaTower_one : omegaTower 1 = omega0 := by simp [opow_one]

/-- [Section: # CatalogBuild.Speculative.Other.Basic
Auto-generated from theorem catalog database.
Domain: Speculative/Other
Declarations: 15] -/
theorem omegaTower_two : omegaTower 2 = omega0 ^ omega0 := by simp

/-- ω^· is a normal (strictly monotone and continuous) function on ordinals. -/
theorem omega0_opow_isNormal : Order.IsNormal (fun x : Ordinal.{0} => omega0 ^ x) :=
  Ordinal.isNormal_opow one_lt_omega0

/-- ω^· is strictly monotone. -/
theorem omega0_opow_strictMono : StrictMono (fun x : Ordinal.{0} => omega0 ^ x) :=
  omega0_opow_isNormal.strictMono

/-- Each level of the omega tower is positive. -/
theorem omegaTower_pos (n : ℕ) : 0 < omegaTower n := by
  induction n <;> simp +decide [*]
  exact Ordinal.opow_pos _ Ordinal.omega0_pos

/-- Each level of the omega tower is at least 1. -/
theorem one_le_omegaTower (n : ℕ) : 1 ≤ omegaTower n := by
  induction' n with n _ih
  · exact le_rfl
  · exact Ordinal.one_le_iff_ne_zero.mpr (ne_of_gt (Ordinal.opow_pos _ Ordinal.omega0_pos))

/-- The key step: each level is strictly less than the next. -/
theorem omegaTower_lt_succ (n : ℕ) : omegaTower n < omegaTower (n + 1) := by
  induction n <;> aesop

/-- The omega tower at level n equals the (n+1)-th iterate of ω^· applied to 0. -/
theorem omegaTower_eq_iterate_zero (n : ℕ) :
    omegaTower n = (omega0 ^ ·)^[n + 1] 0 := by
  induction n <;> simp_all +decide [Function.iterate_succ_apply']

/-- Every level of the omega tower is strictly below ε₀. -/
theorem omegaTower_lt_epsilon0 (n : ℕ) : omegaTower n < epsilon0 := by
  rw [omegaTower_eq_iterate_zero]
  apply Ordinal.iterate_lt_nfp omega0_opow_strictMono
  norm_num +zetaDelta

/-- **The defining property of ε₀**: ω^(ε₀) = ε₀. -/
theorem epsilon0_fixed_point : omega0 ^ epsilon0 = epsilon0 :=
  Ordinal.nfp_fp omega0_opow_isNormal 0

/-- ε₀ is the *least* ordinal ≥ 0 that is a fixed point of ω^·. -/
theorem epsilon0_le_of_fixed_point (a : Ordinal.{0}) (ha : omega0 ^ a = a) :
    epsilon0 ≤ a := by
  exact Ordinal.nfp_le_fp omega0_opow_isNormal.monotone bot_le (le_of_eq ha)

/-- ε₀ is positive. -/
theorem epsilon0_pos : 0 < epsilon0 :=
  lt_trans (by simp : (0 : Ordinal) < omegaTower 0) (omegaTower_lt_epsilon0 0)

/-- ε₀ is greater than ω. -/
theorem omega0_lt_epsilon0 : omega0 < epsilon0 :=
  omegaTower_one ▸ omegaTower_lt_epsilon0 1

/-- ε₀ is a limit ordinal (not zero, not a successor).
**Proof**: If `a ⋖ ε₀` (a is covered by ε₀, i.e., a is an immediate
predecessor), then `a < ε₀`. Since `ω^·` is a normal function,
`a ≤ ω^a`. If `a = ω^a`, then `a` is a fixed point of `ω^·`, so
`ε₀ ≤ a`, contradicting `a < ε₀`. Thus `a < ω^a`. But also
`ω^a < ω^(ε₀) = ε₀` by strict monotonicity. This gives
`a < ω^a < ε₀`, contradicting `a ⋖ ε₀`. -/
theorem epsilon0_isSuccLimit : Order.IsSuccLimit epsilon0 := by
  constructor
  · intro h
    exact absurd (h bot_le) (not_le.mpr epsilon0_pos)
  · intro a ⟨ha_lt, ha_cov⟩
    have h1 : a ≤ omega0 ^ a := omega0_opow_isNormal.strictMono.le_apply
    have h2 : a ≠ omega0 ^ a := by
      intro heq
      exact absurd ha_lt (not_lt.mpr (epsilon0_le_of_fixed_point a heq.symm))
    have h3 : a < omega0 ^ a := lt_of_le_of_ne h1 h2
    have h4 : omega0 ^ a < epsilon0 := epsilon0_fixed_point ▸ omega0_opow_strictMono ha_lt
    exact ha_cov h3 h4

end