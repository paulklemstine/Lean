/-! # CatalogBuild.Speculative.IdempotentCollapse.NewHypotheses

Auto-generated from theorem catalog database.
Domain: Speculative/IdempotentCollapse
Declarations: 12
-/

import Mathlib

noncomputable section

/-- [Section: # CatalogBuild.Speculative.IdempotentCollapse.NewHypotheses
Auto-generated from theorem catalog database.
Domain: Speculative/IdempotentCollapse
Declarations: 12] -/
theorem maslov_lower (a b : ℝ) : max a b ≤ Real.log (Real.exp a + Real.exp b) := by
  rw [ Real.le_log_iff_exp_le ( by positivity ) ];
  cases max_cases a b <;> simp +decide [ * ] <;> linarith [ Real.exp_pos a, Real.exp_pos b ]



theorem maslov_upper (a b : ℝ) :
    Real.log (Real.exp a + Real.exp b) ≤ max a b + Real.log 2 := by
  rw [ Real.log_le_iff_le_exp, Real.exp_add, Real.exp_log ] <;> norm_num;
  · linarith [ Real.exp_le_exp.2 ( le_max_left a b ), Real.exp_le_exp.2 ( le_max_right a b ) ];
  · positivity



/-- In the tropical semiring (ℝ, max, +), every element is idempotent under ⊕ = max. -/
theorem tropical_all_idempotent (a : ℝ) : max a a = a := max_self a



/-- Tropical addition is idempotent on integers too. -/
theorem tropical_all_idempotent_int (a : ℤ) : max a a = a := max_self a



/-- Tropical addition is idempotent on rationals. -/
theorem tropical_all_idempotent_rat (a : ℚ) : max a a = a := max_self a



/-- An endomorphism is idempotent if f ∘ f = f. -/
def IsIdempotent' (f : α → α) : Prop := ∀ x, f (f x) = f x



/-- Composition of commuting idempotents is idempotent. -/
theorem idempotent_comp_of_comm (f g : α → α) (hf : IsIdempotent' f) (hg : IsIdempotent' g)
    (hcomm : ∀ x, f (g x) = g (f x)) :
    IsIdempotent' (f ∘ g) := by
  intro x
  simp only [comp_apply]
  -- f(g(f(g(x)))) = f(g(g(f(x)))) by commutativity applied to g(x)
  -- Wait: f(g(f(g(x)))) -- apply hcomm to get g(f(g(x))), then...
  -- Actually: (f ∘ g)(f(g(x))) = f(g(f(g(x))))
  -- = f(f(g(g(x))))  [using hcomm on the inner g(f(g(x))) = f(g(g(x)))]
  -- Hmm, let's just use calc
  calc f (g (f (g x)))
      = f (f (g (g x))) := by rw [← hcomm]
    _ = f (g (g x)) := by rw [hf]
    _ = f (g x) := by rw [hg]



/-- **The Core Identity**: ReLU(x) = x ⊕_T 0. Proof: reflexivity. -/
theorem relu_is_tropical (x : ℝ) : relu' x = tropAdd x 0 := rfl



/-- ReLU is idempotent on nonneg reals. -/
theorem relu_idempotent_nonneg (x : ℝ) (hx : 0 ≤ x) : relu' (relu' x) = relu' x := by
  simp [relu', max_eq_left hx]



theorem quadruple_parity (a b c d : ℤ) (h : a^2 + b^2 + c^2 = d^2) :
    Even (a + b + c + d) := by
  apply_fun Even at h; simp_all +decide [ parity_simps ] ;



/-- At q=1, Gaussian binomial = ordinary binomial. -/
theorem gaussBinom_q1 (n k : ℕ) : gaussBinom n k 1 = Nat.choose n k := by
  induction n generalizing k with
  | zero => cases k <;> simp [gaussBinom, Nat.choose]
  | succ n ih =>
    cases k with
    | zero => simp [gaussBinom, Nat.choose]
    | succ k =>
      simp only [gaussBinom, Nat.choose, one_pow, one_mul]
      rw [ih k, ih (k + 1)]



/-- Total "projections" at q=1 equals 2^n (Boolean lattice). -/
theorem totalProj_q1 (n : ℕ) :
    ∑ r ∈ Finset.range (n + 1), gaussBinom n r 1 = 2^n := by
  simp only [gaussBinom_q1]
  exact Nat.sum_range_choose n



end
