/-! # CatalogBuild.Algebra.IntegerEnergy.Main

Auto-generated from theorem catalog database.
Domain: Algebra/IntegerEnergy
Declarations: 21
-/

import Mathlib

noncomputable section

/-- An operator is n-potent if P^n = P. -/
def IsNPotent {α : Type*} (P : α → α) (n : ℕ) : Prop := P^[n] = P





/-- Standard idempotency (2-potent) is a special case. -/
theorem isNPotent_two_iff_idempotent {α : Type*} (P : α → α) :
    IsNPotent P 2 ↔ ∀ x, P (P x) = P x := by
  constructor
  · intro h x
    have := congr_fun h x
    simp [Function.iterate_succ, Function.iterate_one, Function.comp] at this
    exact this
  · intro h
    ext x
    simp [Function.iterate_succ, Function.iterate_one, Function.comp]
    exact h x





/-- [Section: # CatalogBuild.Computation.Oracles.Main
Auto-generated from theorem catalog database.
Domain: Computation/Oracles
Declarations: 21] -/
theorem npotent_spectrum {R : Type*} [CommRing R] [NoZeroDivisors R]
    {M : Type*} [AddCommGroup M] [Module R M] [NoZeroSMulDivisors R M]
    (P : M →ₗ[R] M) (n : ℕ) (hn : 1 ≤ n)
    (hP : ∀ x, (P ^ n) x = P x)
    (v : M) (hv : v ≠ 0) (ev : R) (hev : P v = ev • v) :
    ev ^ n = ev := by
      -- By the induction hypothesis, we have $(P^n) v = ev^n • v$.
      have h_ind : (P ^ n) v = ev ^ n • v := by
        refine' Nat.le_induction _ _ n hn <;> simp_all +decide [ pow_succ', smul_smul ];
        exact fun _ _ _ => by rw [ mul_comm ] ;
      -- Since $v \neq 0$ and $R$ is a field, we can cancel $v$ from both sides of the equation $ev^n • v = ev • v$.
      have h_cancel : (ev^n - ev) • v = 0 := by
        rw [ sub_smul, eq_comm ] ; aesop;
      exact sub_eq_zero.mp ( by simpa [ hv ] using NoZeroSMulDivisors.eq_zero_or_eq_zero_of_smul_eq_zero h_cancel )





/-- [Section: # CatalogBuild.Computation.Oracles.Main
Auto-generated from theorem catalog database.
Domain: Computation/Oracles
Declarations: 21] -/
theorem oracle_spectrum_binary {R : Type*} [CommRing R] [NoZeroDivisors R]
    {M : Type*} [AddCommGroup M] [Module R M] [NoZeroSMulDivisors R M]
    (P : M →ₗ[R] M) (hP : ∀ x, P (P x) = P x)
    (v : M) (hv : v ≠ 0) (ev : R) (hev : P v = ev • v) :
    ev = 0 ∨ ev = 1 := by
      have h_eq : (ev - 1) • P v = 0 := by
        have := hP v; simp_all +decide [ sub_smul ] ;
      grind +suggestions





/-- [Section: # CatalogBuild.Computation.Oracles.Main
Auto-generated from theorem catalog database.
Domain: Computation/Oracles
Declarations: 21] -/
theorem tripotent_spectrum {R : Type*} [CommRing R] [NoZeroDivisors R]
    {M : Type*} [AddCommGroup M] [Module R M] [NoZeroSMulDivisors R M]
    (P : M →ₗ[R] M) (hP : ∀ x, (P ^ 3) x = P x)
    (v : M) (hv : v ≠ 0) (ev : R) (hev : P v = ev • v) :
    ev = 0 ∨ ev = 1 ∨ ev = -1 := by
      have h := npotent_spectrum P 3 ( by decide ) hP v hv ev hev; simp_all +decide [ pow_succ' ] ;
      exact Classical.or_iff_not_imp_left.2 fun h₀ => Classical.or_iff_not_imp_left.2 fun h₁ => mul_left_cancel₀ ( sub_ne_zero_of_ne h₁ ) <| mul_left_cancel₀ ( sub_ne_zero_of_ne h₀ ) <| by linear_combination' h;





theorem npotent_hierarchy {α : Type*} (P : α → α) (m n : ℕ)
    (hm : 2 ≤ m) (hn : 2 ≤ n)
    (hP : P^[m] = P) (hdvd : (m - 1) ∣ (n - 1)) :
    P^[n] = P := by
      obtain ⟨ k, hk ⟩ := hdvd;
      rcases n with ( _ | _ | n ) <;> simp_all +decide [ Function.iterate_mul, Function.iterate_fixed ];
      rcases m with ( _ | _ | m ) <;> simp_all +decide [ Function.iterate_mul, Function.iterate_fixed ];
      refine' Nat.recOn k _ _ <;> simp_all +decide [ Function.iterate_succ_apply', Function.comp ];
      simp_all +decide [ funext_iff, Function.iterate_succ_apply' ]





theorem idempotent_is_npotent {α : Type*} (P : α → α) (n : ℕ) (hn : 2 ≤ n)
    (hP : P^[2] = P) : P^[n] = P := by
      refine' Nat.le_induction _ _ n hn <;> aesop





/-- The bootstrap map f(x) = 3x² - 2x³. -/
def bootstrapMap (x : ℝ) : ℝ := 3 * x ^ 2 - 2 * x ^ 3





theorem bootstrap_fixed_points (x : ℝ) :
    bootstrapMap x = x ↔ x = 0 ∨ x = 1/2 ∨ x = 1 := by
      unfold bootstrapMap; exact ⟨ fun hx => Classical.or_iff_not_imp_left.2 fun hx0 => Classical.or_iff_not_imp_left.2 fun hx1 => mul_left_cancel₀ ( sub_ne_zero_of_ne hx0 ) <| mul_left_cancel₀ ( sub_ne_zero_of_ne hx1 ) <| by nlinarith, fun hx => by rcases hx with ( rfl | rfl | rfl ) <;> norm_num ⟩ ;





/-- The derivative at x = 1/2 is 3/2 > 1, so 1/2 is repelling. -/
theorem bootstrap_deriv_at_half :
    6 * (1/2 : ℝ) * (1 - 1/2) = 3/2 := by ring





/-- The generalized bootstrap family: f_α(x) = (1+α)x² - αx³. -/
def bootstrapFamily (α x : ℝ) : ℝ := (1 + α) * x ^ 2 - α * x ^ 3





/-- f_α(0) = 0 for all α. -/
theorem family_fixed_zero (α : ℝ) : bootstrapFamily α 0 = 0 := by
  unfold bootstrapFamily; ring





/-- f_α(1) = 1 for all α. -/
theorem family_fixed_one (α : ℝ) : bootstrapFamily α 1 = 1 := by
  unfold bootstrapFamily; ring





/-- The standard bootstrap is f_2. -/
theorem family_at_two (x : ℝ) : bootstrapFamily 2 x = bootstrapMap x := by
  unfold bootstrapFamily bootstrapMap; ring





theorem family_symmetry_iff_alpha_two (α : ℝ) :
    (∀ x, bootstrapFamily α (1 - x) = 1 - bootstrapFamily α x) ↔ α = 2 := by
      constructor <;> intro h <;> unfold bootstrapFamily at *;
      · linarith [ h 0, h 1, h 2 ];
      · exact fun x => by subst h; ring;





/-- For a commutative ring element satisfying a³ = a, we can define
the "positive part" e₊ = (a + a²) * (2⁻¹). -/
def tripotentPlus {R : Type*} [Field R] (a : R) : R :=
  (a + a ^ 2) / 2





/-- The "negative part" e₋ = (a² - a) * (2⁻¹). -/
def tripotentMinus {R : Type*} [Field R] (a : R) : R :=
  (a ^ 2 - a) / 2





theorem tripotentPlus_idem {R : Type*} [Field R] [CharZero R]
    (a : R) (ha : a ^ 3 = a) :
    (tripotentPlus a) ^ 2 = tripotentPlus a := by
      unfold tripotentPlus; simp +decide [ ha, pow_succ, mul_assoc ] ; ring;
      rw [ show a ^ 4 = a ^ 3 * a by ring, ha ] ; ring;





theorem tripotentMinus_idem {R : Type*} [Field R] [CharZero R]
    (a : R) (ha : a ^ 3 = a) :
    (tripotentMinus a) ^ 2 = tripotentMinus a := by
      unfold tripotentMinus; rw [ div_pow, eq_div_iff ] <;> ring;
      · rw [ show a ^ 4 = a ^ 3 * a by ring, ha ] ; ring;
      · norm_num





/-- a = e₊ - e₋ (the tripotent decomposition). -/
theorem tripotent_decomposition {R : Type*} [Field R] [CharZero R]
    (a : R) :
    tripotentPlus a - tripotentMinus a = a := by
  unfold tripotentPlus tripotentMinus
  field_simp
  ring





theorem tripotent_orthogonal {R : Type*} [Field R] [CharZero R]
    (a : R) (ha : a ^ 3 = a) :
    tripotentPlus a * tripotentMinus a = 0 := by
      by_cases ha' : a = 0 <;> simp_all +decide [ tripotentPlus, tripotentMinus, pow_succ' ];
      grind





end
