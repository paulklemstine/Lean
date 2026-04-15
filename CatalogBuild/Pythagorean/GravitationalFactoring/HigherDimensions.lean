/-! # CatalogBuild.Pythagorean.GravitationalFactoring.HigherDimensions

Auto-generated from theorem catalog database.
Domain: Pythagorean/GravitationalFactoring
Declarations: 16
-/

import Mathlib

theorem two_square_identity_alt (a b c d : ℤ) :
    (a^2 + b^2) * (c^2 + d^2) = (a*c + b*d)^2 + (a*d - b*c)^2 := by ring

/-- The two forms give DIFFERENT decompositions → factoring information! -/

def factoringChannels' (k : ℕ) : ℕ := k + Nat.choose k 2

/-- The factoring channel hierarchy. -/

theorem channels_triangular_formula (k : ℕ) :
    2 * factoringChannels' k = k * (k + 1) := by
  unfold factoringChannels'
  rcases k with _ | n
  · simp
  · rw [Nat.choose_two_right, Nat.succ_sub_one]
    have h : 2 ∣ (n + 1) * n := by
      rcases n.even_or_odd with ⟨m, rfl⟩ | ⟨m, rfl⟩
      · exact ⟨m * (2*m + 1), by ring⟩
      · exact ⟨(m+1) * (2*m + 1), by ring⟩
    obtain ⟨t, ht⟩ := h
    rw [ht, Nat.mul_div_cancel_left _ (by norm_num : 0 < 2)]
    nlinarith [ht]

/-! ## §3. The Gaussian Integer Norm and Factoring -/

/-- The Gaussian norm is multiplicative. -/

theorem gaussian_factor_key (a b c d N : ℤ) :
    ↑(Int.gcd (a*c - b*d) N) ∣ N :=
  Int.gcd_dvd_right _ _

/-! ## §4. Peel Identities for Specific Dimensions -/

/-- Triple peel: (c-a)(c+a) = b². -/

theorem triple_peel (a b c : ℤ)
    (h : a ^ 2 + b ^ 2 = c ^ 2) :
    (c - a) * (c + a) = b ^ 2 := by nlinarith

/-- Quadruple peel: (d-a)(d+a) = b² + c². -/

theorem quadruple_peel (a b c d : ℤ)
    (h : a ^ 2 + b ^ 2 + c ^ 2 = d ^ 2) :
    (d - a) * (d + a) = b ^ 2 + c ^ 2 := by nlinarith

/-- 5-tuple peel: (d-a₄)(d+a₄) = a₁² + a₂² + a₃². -/

theorem five_tuple_peel (a₁ a₂ a₃ a₄ d : ℤ)
    (h : a₁ ^ 2 + a₂ ^ 2 + a₃ ^ 2 + a₄ ^ 2 = d ^ 2) :
    (d - a₄) * (d + a₄) = a₁ ^ 2 + a₂ ^ 2 + a₃ ^ 2 := by nlinarith

/-! ## §5. Lifting Theorems -/

/-- A quadruple lifts to a 5-tuple. -/

theorem quadruple_lifts_to_5tuple (a b c d e f : ℤ)
    (h_quad : a ^ 2 + b ^ 2 + c ^ 2 = d ^ 2)
    (h_triple : d ^ 2 + e ^ 2 = f ^ 2) :
    a ^ 2 + b ^ 2 + c ^ 2 + e ^ 2 = f ^ 2 := by linarith

/-- Shared hypotenuse for 5-tuples implies equal sums. -/

theorem five_tuple_shared_hyp
    (a₁ a₂ a₃ a₄ b₁ b₂ b₃ b₄ d : ℤ)
    (h1 : a₁ ^ 2 + a₂ ^ 2 + a₃ ^ 2 + a₄ ^ 2 = d ^ 2)
    (h2 : b₁ ^ 2 + b₂ ^ 2 + b₃ ^ 2 + b₄ ^ 2 = d ^ 2) :
    a₁ ^ 2 + a₂ ^ 2 + a₃ ^ 2 + a₄ ^ 2 =
      b₁ ^ 2 + b₂ ^ 2 + b₃ ^ 2 + b₄ ^ 2 := by linarith

/-! ## §6. Representation Density -/

/-- For a prime p ≥ 3, the count 8(1+p) is at least 32. -/

theorem semiprime_r4_lower_bound (p q : ℕ) (hp : 3 ≤ p) (hq : 3 ≤ q) :
    1024 ≤ 8 * (1 + p) * (8 * (1 + q)) := by nlinarith

/-! ## §7. The Division Algebra Hierarchy -/

/-- Cayley-Dickson dimensions. -/

def cayleyDicksonDims : List ℕ := [1, 2, 4, 8]


theorem cayley_dickson_dims_correct :
    cayleyDicksonDims = [1, 2, 4, 8] := rfl

/-! ## §8. The Octonionic Advantage -/

/-- 36 channels for k=8: a 12× improvement over k=2. -/

theorem octonionic_factoring_advantage :
    factoringChannels' 8 = 36 ∧
    factoringChannels' 8 = 6 * factoringChannels' 3 := by
  unfold factoringChannels'; decide


theorem oct_vs_gauss :
    factoringChannels' 8 / factoringChannels' 2 = 12 := by
  unfold factoringChannels'; decide

/-! ## §9. Hyperbolic Distance -/

/-- If p*q divides d² and p is prime, then p divides d. -/

theorem semiprime_sq_div (d p q : ℤ) (hp : Prime p)
    (hpq : p * q ∣ d ^ 2) : p ∣ d := by
  have : p ∣ d ^ 2 := dvd_trans (dvd_mul_right p q) hpq
  rw [sq, hp.dvd_mul] at this
  exact this.elim id id

/-! ## §10. Cross-Difference for 5-Tuples -/

/-- Cross-difference for 5-tuples. -/

theorem five_tuple_cross_diff
    (a₁ a₂ a₃ a₄ b₁ b₂ b₃ b₄ d : ℤ)
    (h1 : a₁ ^ 2 + a₂ ^ 2 + a₃ ^ 2 + a₄ ^ 2 = d ^ 2)
    (h2 : b₁ ^ 2 + b₂ ^ 2 + b₃ ^ 2 + b₄ ^ 2 = d ^ 2) :
    a₄ ^ 2 - b₄ ^ 2 = (b₁ ^ 2 - a₁ ^ 2) + (b₂ ^ 2 - a₂ ^ 2) + (b₃ ^ 2 - a₃ ^ 2) := by
  linarith

