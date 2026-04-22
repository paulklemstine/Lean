import Mathlib

/-! # CatalogBuild.Pythagorean.Berggren.BerggrenPellSemigroup

Auto-generated from theorem catalog database.
Domain: Pythagorean/Berggren
Declarations: 33
-/

/-- [Section: ## Section 1: Pell Sequences (self-contained definitions)] -/
def pellX' : ℕ → ℤ
  | 0 => 1
  | 1 => 3
  | n + 2 => 6 * pellX' (n + 1) - pellX' n

def pellY' : ℕ → ℤ
  | 0 => 0
  | 1 => 1
  | n + 2 => 6 * pellY' (n + 1) - pellY' n

/-- The Pell product: multiplication of elements in ℤ[√8].
(x₁ + y₁√8)(x₂ + y₂√8) = (x₁x₂ + 8y₁y₂) + (x₁y₂ + y₁x₂)√8 -/
def pellProd (p q : ℤ × ℤ) : ℤ × ℤ :=
  (p.1 * q.1 + 8 * p.2 * q.2, p.1 * q.2 + p.2 * q.1)

/-- The Pell unit: 1 + 0·√8 -/
def pellUnit : ℤ × ℤ := (1, 0)

/-- The fundamental solution: 3 + 1·√8 -/
def pellFund : ℤ × ℤ := (3, 1)

/-- [Section: ## Section 3: Pell Product is Associative and has Identity] -/
theorem pellProd_assoc (p q r : ℤ × ℤ) :
    pellProd (pellProd p q) r = pellProd p (pellProd q r) := by
  ext <;> simp [pellProd] <;> ring

theorem pellProd_unit_left (p : ℤ × ℤ) : pellProd pellUnit p = p := by
  ext <;> simp [pellProd, pellUnit]

theorem pellProd_unit_right (p : ℤ × ℤ) : pellProd p pellUnit = p := by
  ext <;> simp [pellProd, pellUnit]

theorem pellProd_comm (p q : ℤ × ℤ) : pellProd p q = pellProd q p := by
  ext <;> simp [pellProd] <;> ring

/-- The norm in ℤ[√8]: N(x + y√8) = x² - 8y² -/
def pellNorm (p : ℤ × ℤ) : ℤ := p.1 ^ 2 - 8 * p.2 ^ 2

/-- [Section: ## Section 4: Norm Preservation] -/
theorem pellNorm_unit : pellNorm pellUnit = 1 := by simp [pellNorm, pellUnit]

theorem pellNorm_fund : pellNorm pellFund = 1 := by norm_num [pellNorm, pellFund]

/-- The norm is multiplicative: N(p·q) = N(p)·N(q) -/
theorem pellNorm_mul (p q : ℤ × ℤ) :
    pellNorm (pellProd p q) = pellNorm p * pellNorm q := by
  simp [pellNorm, pellProd]; ring

/-- The n-th power of a pair under pellProd -/
def pellPow (p : ℤ × ℤ) : ℕ → ℤ × ℤ
  | 0 => pellUnit
  | n + 1 => pellProd p (pellPow p n)

/-- [Section: ## Section 5: Pell Power] -/
theorem pellPow_zero (p : ℤ × ℤ) : pellPow p 0 = pellUnit := rfl

theorem pellPow_succ (p : ℤ × ℤ) (n : ℕ) :
    pellPow p (n + 1) = pellProd p (pellPow p n) := rfl

theorem pellPow_one (p : ℤ × ℤ) : pellPow p 1 = p := by
  simp [pellPow, pellProd_unit_right]

/-- [Section: ## Section 6: Norm of Powers] -/
theorem pellNorm_pow (p : ℤ × ℤ) (n : ℕ) :
    pellNorm (pellPow p n) = pellNorm p ^ n := by
  induction n with
  | zero => simp [pellPow_zero, pellNorm_unit]
  | succ n ih => rw [pellPow_succ, pellNorm_mul, ih, pow_succ, mul_comm]

theorem pellNorm_fund_pow (n : ℕ) : pellNorm (pellPow pellFund n) = 1 := by
  rw [pellNorm_pow, pellNorm_fund, one_pow]

/-- [Section: ## Section 7: Connection to pellX', pellY'] -/
theorem pellPow_fund_eq (n : ℕ) :
    pellPow pellFund n = (pellX' n, pellY' n) := by
      induction' n using Nat.strong_induction_on with n ih;
      rcases n with ( _ | _ | n ) <;> simp +arith +decide [ * ];
      grind +locals

/-- [Section: ## Section 8: Pell Product Addition Law] -/
theorem pellProd_add (m n : ℕ) :
    pellProd (pellX' m, pellY' m) (pellX' n, pellY' n) =
    (pellX' (m + n), pellY' (m + n)) := by
      -- By definition of pellProd, we can expand both sides.
      rw [← pellPow_fund_eq, ← pellPow_fund_eq, ← pellPow_fund_eq];
      induction' n with n ih;
      · exact pellProd_unit_right _;
      · grind +locals

/-- [Section: ## Section 9: Doubling Formulas (for fast computation)] -/
theorem pellX'_double (n : ℕ) :
    pellX' (2 * n) = 2 * pellX' n ^ 2 - 1 := by
      induction' n using Nat.strong_induction_on with n ih;
      rcases n with ( _ | _ | _ | n ) <;> simp +arith +decide [ *, ih ];
      have := ih n ( by linarith ) ; have := ih ( n + 1 ) ( by linarith ) ; have := ih ( n + 2 ) ( by linarith ) ; simp_all +decide [ Nat.mul_succ, pellX' ] ; ring;
      grind

theorem pellY'_double (n : ℕ) :
    pellY' (2 * n) = 2 * pellX' n * pellY' n := by
      by_contra h;
      -- By definition of $pellY'$, we know that $pellY'(2n)$ is the second component of $pellProd (pellFund^n) (pellFund^n)$.
      have h_pellY'_def : pellY' (2 * n) = (pellProd (pellX' n, pellY' n) (pellX' n, pellY' n)).2 := by
        rw [ show 2 * n = n + n by ring, pellProd_add ];
      exact h ( h_pellY'_def.trans ( by unfold pellProd; ring ) )

/-- The conjugate: x - y√8. Conjugation is an involution preserving norm. -/
def pellConj (p : ℤ × ℤ) : ℤ × ℤ := (p.1, -p.2)

/-- [Section: ## Section 10: Pell Conjugate] -/
theorem pellConj_involution (p : ℤ × ℤ) : pellConj (pellConj p) = p := by
  simp [pellConj]

theorem pellNorm_conj (p : ℤ × ℤ) : pellNorm (pellConj p) = pellNorm p := by
  simp [pellNorm, pellConj]

theorem pellProd_conj (p q : ℤ × ℤ) :
    pellConj (pellProd p q) = pellProd (pellConj p) (pellConj q) := by
  ext <;> simp [pellConj, pellProd] <;> ring

/-- Product with conjugate gives the norm: p · conj(p) = (N(p), 0) -/
theorem pellProd_self_conj (p : ℤ × ℤ) :
    pellProd p (pellConj p) = (pellNorm p, 0) := by
  ext <;> simp [pellProd, pellConj, pellNorm] <;> ring

/-- For norm-1 elements, the conjugate is the inverse -/
theorem pellConj_inverse (p : ℤ × ℤ) (hp : pellNorm p = 1) :
    pellProd p (pellConj p) = pellUnit := by
  rw [pellProd_self_conj, hp]; rfl

/-- [Section: ## Section 12: Specific Computations] -/
theorem pellFund_sq : pellProd pellFund pellFund = (17, 6) := by
  ext <;> simp [pellProd, pellFund]

theorem pellFund_cube : pellProd pellFund (pellProd pellFund pellFund) = (99, 35) := by
  ext <;> simp [pellProd, pellFund]

theorem pellX'_values :
    pellX' 0 = 1 ∧ pellX' 1 = 3 ∧ pellX' 2 = 17 ∧ pellX' 3 = 99 := by
  refine ⟨rfl, rfl, ?_, ?_⟩ <;> native_decide

theorem pellY'_values :
    pellY' 0 = 0 ∧ pellY' 1 = 1 ∧ pellY' 2 = 6 ∧ pellY' 3 = 35 := by
  refine ⟨rfl, rfl, ?_, ?_⟩ <;> native_decide
