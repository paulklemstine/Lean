/-! # CatalogBuild.Computation.Oracles.Main

Auto-generated from theorem catalog database.
Domain: Computation/Oracles
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

/-
PROBLEM
**n-Potent Spectrum Theorem**: If P is a linear map with Pⁿ = P, and
    P v = λ v for v ≠ 0, then λⁿ = λ (i.e., λⁿ - λ = 0,
    so λ = 0 or λ is an (n-1)-th root of unity).

PROVIDED SOLUTION
By induction on n, show that (P^n) v = ev^n • v. Base case n=1: P v = ev • v by hypothesis, and ev^1 = ev. Inductive step: (P^(k+1)) v = P ((P^k) v) = P (ev^k • v) = ev^k • (P v) = ev^k • (ev • v) = ev^(k+1) • v, using linearity of P. Then from the hypothesis (P^n) v = P v, we get ev^n • v = ev • v, so (ev^n - ev) • v = 0, and since v ≠ 0 and NoZeroSMulDivisors, ev^n = ev.
-/

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

/-
PROBLEM
For the standard oracle (n=2), the spectrum is {0, 1}.

PROVIDED SOLUTION
From hP we get P(Pv) = Pv, so P(ev • v) = ev • v, so ev • Pv = ev • v (by linearity), so ev • (ev • v) = ev • v, so ev² • v = ev • v, so (ev² - ev) • v = 0. Since v ≠ 0, ev² - ev = 0, so ev(ev-1) = 0, so ev = 0 or ev = 1.
-/

theorem oracle_spectrum_binary {R : Type*} [CommRing R] [NoZeroDivisors R]
    {M : Type*} [AddCommGroup M] [Module R M] [NoZeroSMulDivisors R M]
    (P : M →ₗ[R] M) (hP : ∀ x, P (P x) = P x)
    (v : M) (hv : v ≠ 0) (ev : R) (hev : P v = ev • v) :
    ev = 0 ∨ ev = 1 := by
      have h_eq : (ev - 1) • P v = 0 := by
        have := hP v; simp_all +decide [ sub_smul ] ;
      grind +suggestions

/-
PROBLEM
For tripotent (n=3), the eigenvalue equation gives λ³ = λ,
    i.e., λ(λ²-1) = 0, so λ ∈ {0, 1, -1}.

PROVIDED SOLUTION
By the same argument as npotent_spectrum with n=3, we get ev³ = ev. Then ev³ - ev = 0, ev(ev² - 1) = 0, ev(ev-1)(ev+1) = 0 in a no-zero-divisors ring. So ev = 0 or ev - 1 = 0 or ev + 1 = 0.
-/

theorem tripotent_spectrum {R : Type*} [CommRing R] [NoZeroDivisors R]
    {M : Type*} [AddCommGroup M] [Module R M] [NoZeroSMulDivisors R M]
    (P : M →ₗ[R] M) (hP : ∀ x, (P ^ 3) x = P x)
    (v : M) (hv : v ≠ 0) (ev : R) (hev : P v = ev • v) :
    ev = 0 ∨ ev = 1 ∨ ev = -1 := by
      have h := npotent_spectrum P 3 ( by decide ) hP v hv ev hev; simp_all +decide [ pow_succ' ] ;
      exact Classical.or_iff_not_imp_left.2 fun h₀ => Classical.or_iff_not_imp_left.2 fun h₁ => mul_left_cancel₀ ( sub_ne_zero_of_ne h₁ ) <| mul_left_cancel₀ ( sub_ne_zero_of_ne h₀ ) <| by linear_combination' h;

/-! ## §2: n-Potent Hierarchy -/

/-
PROBLEM
**Hierarchy Theorem**: If P^m = P and (m-1) | (n-1), then P^n = P.
    This shows n-potency classes form a lattice under divisibility.

PROVIDED SOLUTION
Key idea: P^[m] = P means P^[m-1] ∘ P = P, so P^[m-1] acts as identity on the range of P. Since (m-1) | (n-1), write n-1 = k(m-1). Then P^[n] = P^[n-1] ∘ P = (P^[m-1])^k ∘ P. Since P^[m-1] acts as identity on range of P (because P^[m] = P^[m-1] ∘ P = P), and each application of P^[m-1] keeps us in range of P, we get P^[n] = P.

More concretely: from P^[m] = P, we get P^[m-1+1] = P, so P^[m-1] ∘ P = P. By induction, (P^[m-1])^k ∘ P = P for all k. Now n - 1 = k(m-1) means n = k(m-1) + 1, so P^[n] = P^[k(m-1)+1] = (P^[m-1])^[k] ∘ P = P.

Use Function.iterate_mul and the fact that P^[m] = P implies P^[m-1] is identity on range P.
-/

theorem npotent_hierarchy {α : Type*} (P : α → α) (m n : ℕ)
    (hm : 2 ≤ m) (hn : 2 ≤ n)
    (hP : P^[m] = P) (hdvd : (m - 1) ∣ (n - 1)) :
    P^[n] = P := by
      obtain ⟨ k, hk ⟩ := hdvd;
      rcases n with ( _ | _ | n ) <;> simp_all +decide [ Function.iterate_mul, Function.iterate_fixed ];
      rcases m with ( _ | _ | m ) <;> simp_all +decide [ Function.iterate_mul, Function.iterate_fixed ];
      refine' Nat.recOn k _ _ <;> simp_all +decide [ Function.iterate_succ_apply', Function.comp ];
      simp_all +decide [ funext_iff, Function.iterate_succ_apply' ]

/-
PROBLEM
Every idempotent is n-potent for all n ≥ 2.

PROVIDED SOLUTION
Use npotent_hierarchy with m=2. We need (2-1) | (n-1), i.e. 1 | (n-1), which is always true. Apply npotent_hierarchy P 2 n (le_refl 2) hn hP (one_dvd (n-1)).
-/

theorem idempotent_is_npotent {α : Type*} (P : α → α) (n : ℕ) (hn : 2 ≤ n)
    (hP : P^[2] = P) : P^[n] = P := by
      refine' Nat.le_induction _ _ n hn <;> aesop

/-! ## §3: Oracle Bootstrap Symmetry (H9) -/

/-- The bootstrap map f(x) = 3x² - 2x³. -/

def bootstrapMap (x : ℝ) : ℝ := 3 * x ^ 2 - 2 * x ^ 3

/-- **Bootstrap Symmetry**: f(1-x) = 1 - f(x).
    This implies the Julia set is symmetric about Re(z) = 1/2. -/

theorem bootstrap_fixed_points (x : ℝ) :
    bootstrapMap x = x ↔ x = 0 ∨ x = 1/2 ∨ x = 1 := by
      unfold bootstrapMap; exact ⟨ fun hx => Classical.or_iff_not_imp_left.2 fun hx0 => Classical.or_iff_not_imp_left.2 fun hx1 => mul_left_cancel₀ ( sub_ne_zero_of_ne hx0 ) <| mul_left_cancel₀ ( sub_ne_zero_of_ne hx1 ) <| by nlinarith, fun hx => by rcases hx with ( rfl | rfl | rfl ) <;> norm_num ⟩ ;

/-- The derivative at x = 1/2 is 3/2 > 1, so 1/2 is repelling. -/

theorem bootstrap_deriv_at_half :
    6 * (1/2 : ℝ) * (1 - 1/2) = 3/2 := by ring

/-! ## §4: Generalized Bootstrap Family (H10) -/

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

/-
PROBLEM
The symmetry f_α(1-x) = 1 - f_α(x) holds ONLY for α = 2.

PROVIDED SOLUTION
Forward: expand bootstrapFamily α (1-x) = (1+α)(1-x)² - α(1-x)³ and 1 - bootstrapFamily α x = 1 - (1+α)x² + αx³. Comparing coefficients, the constant terms give: (1+α) - α = 1, check. The x coefficient gives: -2(1+α) + 3α = 0, i.e. α - 2 = 0, so α = 2. Equivalently, specialize x to some convenient value (like x = 0 isn't useful since both sides are 1, but x = 1/3 should work) to extract α = 2.

More precisely: set x = 0: both sides equal 1, no info. Set x = 1/3: LHS = bootstrapFamily α (2/3), RHS = 1 - bootstrapFamily α (1/3). Computing, bootstrapFamily α (1/3) = (1+α)/9 - α/27. bootstrapFamily α (2/3) = 4(1+α)/9 - 8α/27. The equation LHS = RHS gives 4(1+α)/9 - 8α/27 = 1 - (1+α)/9 + α/27. Simplify: 4(1+α)/9 - 8α/27 + (1+α)/9 - α/27 = 1. This is 5(1+α)/9 - 9α/27 = 1, i.e. 5(1+α)/9 - α/3 = 1, i.e. (5+5α - 3α)/9 = 1, i.e. 5+2α = 9, so α = 2.

Backward: when α = 2, bootstrapFamily 2 = bootstrapMap, and we have bootstrap_symmetry.
-/

theorem family_symmetry_iff_alpha_two (α : ℝ) :
    (∀ x, bootstrapFamily α (1 - x) = 1 - bootstrapFamily α x) ↔ α = 2 := by
      constructor <;> intro h <;> unfold bootstrapFamily at *;
      · linarith [ h 0, h 1, h 2 ];
      · exact fun x => by subst h; ring;

/-! ## §5: Tripotent Decomposition -/

/-- For a commutative ring element satisfying a³ = a, we can define
    the "positive part" e₊ = (a + a²) * (2⁻¹). -/

def tripotentPlus {R : Type*} [Field R] (a : R) : R :=
  (a + a ^ 2) / 2

/-- The "negative part" e₋ = (a² - a) * (2⁻¹). -/

def tripotentMinus {R : Type*} [Field R] (a : R) : R :=
  (a ^ 2 - a) / 2

/-
PROBLEM
e₊ is idempotent when a³ = a.

PROVIDED SOLUTION
Expand (tripotentPlus a)² = ((a + a²)/2)² = (a + a²)²/4 = (a² + 2a³ + a⁴)/4. Since a³ = a, we have a⁴ = a·a³ = a·a = a². So numerator = a² + 2a + a² = 2a + 2a² = 2(a + a²). Dividing by 4: (a + a²)/2 = tripotentPlus a. Use field_simp and nlinarith/ring with the substitution a^3 = a.
-/

theorem tripotentPlus_idem {R : Type*} [Field R] [CharZero R]
    (a : R) (ha : a ^ 3 = a) :
    (tripotentPlus a) ^ 2 = tripotentPlus a := by
      unfold tripotentPlus; simp +decide [ ha, pow_succ, mul_assoc ] ; ring;
      rw [ show a ^ 4 = a ^ 3 * a by ring, ha ] ; ring;

/-
PROBLEM
e₋ is idempotent when a³ = a.

PROVIDED SOLUTION
Expand (tripotentMinus a)² = ((a² - a)/2)² = (a² - a)²/4 = (a⁴ - 2a³ + a²)/4. Since a³ = a, a⁴ = a². So = (a² - 2a + a²)/4 = (2a² - 2a)/4 = (a² - a)/2 = tripotentMinus a. Use field_simp and nlinarith/ring with a^3 = a.
-/

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

/-
PROBLEM
e₊ · e₋ = 0 when a³ = a (orthogonality).

PROVIDED SOLUTION
tripotentPlus a * tripotentMinus a = ((a+a²)/2) * ((a²-a)/2) = (a+a²)(a²-a)/4 = (a²(1+a)(a-1)... wait). (a + a²)(a² - a) = a(1+a)·a(a-1) = a²(a+1)(a-1) = a²(a²-1). Since a³ = a, a⁴ = a², so a²(a²-1) = a⁴ - a² = a² - a² = 0. Use field_simp and nlinarith with a^3 = a.
-/

theorem tripotent_orthogonal {R : Type*} [Field R] [CharZero R]
    (a : R) (ha : a ^ 3 = a) :
    tripotentPlus a * tripotentMinus a = 0 := by
      by_cases ha' : a = 0 <;> simp_all +decide [ tripotentPlus, tripotentMinus, pow_succ' ];
      grind


end
