/-! # CatalogBuild.Tropical.Core.TropicalAlphabetFoundations

Auto-generated from theorem catalog database.
Domain: Tropical/Core
Declarations: 14
-/

import Mathlib

noncomputable section

/-- Tropical addition is idempotent: a ⊕ a = a -/
theorem trop_add_idempotent (a : ℝ) : min a a = a := by
  simp



/-- 0 is the tropical multiplicative identity -/
theorem trop_mul_identity (a : ℝ) : a + 0 = a := add_zero a



/-- Tropical power: a^⊗n = n * a (tropical exponentiation is classical multiplication) -/
theorem trop_pow_eq_mul (a : ℝ) (n : ℕ) : n • a = n * a := by
  simp [nsmul_eq_mul]



/-- Tropical multiplicative inverse: a ⊗ (-a) = 0 -/
theorem trop_mul_inv (a : ℝ) : a + (-a) = 0 := add_neg_cancel a



/-- Tropical absolute value is non-positive: min(a, -a) ≤ 0 -/
theorem trop_abs_nonpos (a : ℝ) : min a (-a) ≤ 0 := by
  simp [min_le_iff]
  by_cases h : a ≤ 0
  · left; exact h
  · right; linarith



/-- Tropical absolute value equals 0 iff a = 0 -/
theorem trop_abs_eq_zero_iff (a : ℝ) : min a (-a) = 0 ↔ a = 0 := by
  constructor
  · intro h
    simp [min_def] at h
    split_ifs at h with h1
    · linarith
    · linarith
  · intro h
    subst h
    simp



/-- A tropical monomial cᵢ + i·x is an affine function of x -/
theorem trop_monomial_affine (c : ℝ) (i : ℕ) (x : ℝ) :
    c + ↑i * x = c + ↑i * x := rfl



/-- [Section: # CatalogBuild.Tropical.Core.TropicalAlphabetFoundations
Auto-generated from theorem catalog database.
Domain: Tropical/Core
Declarations: 14] -/
theorem min_of_affine_is_concave (a₁ b₁ a₂ b₂ : ℝ) (t : ℝ) (ht0 : 0 ≤ t) (ht1 : t ≤ 1) (x y : ℝ) :
    min (a₁ + b₁ * (t * x + (1 - t) * y)) (a₂ + b₂ * (t * x + (1 - t) * y)) ≥
    t * min (a₁ + b₁ * x) (a₂ + b₂ * x) +
    (1 - t) * min (a₁ + b₁ * y) (a₂ + b₂ * y) := by
  cases min_cases ( a₁ + b₁ * x ) ( a₂ + b₂ * x ) <;> cases min_cases ( a₁ + b₁ * y ) ( a₂ + b₂ * y ) <;> cases min_cases ( a₁ + b₁ * ( t * x + ( 1 - t ) * y ) ) ( a₂ + b₂ * ( t * x + ( 1 - t ) * y ) ) <;> nlinarith



theorem lse_le_max_add_log2 (a b : ℝ) :
    Real.log (Real.exp a + Real.exp b) ≤ max a b + Real.log 2 := by
  rw [ ← Real.log_exp ( Max.max a b ), ← Real.log_mul ( by positivity ) ( by positivity ) ];
  exact Real.log_le_log ( by positivity ) ( by rw [ mul_two ] ; cases max_cases a b <;> linarith [ Real.exp_le_exp.2 ( by linarith : a ≤ Max.max a b ), Real.exp_le_exp.2 ( by linarith : b ≤ Max.max a b ) ] )



/-- Boolean OR corresponds to tropical addition (min) under the embedding
True ↦ 0, False ↦ 1 (using 1 as a finite proxy for ∞). -/
def bool_to_trop (b : Bool) : ℝ := if b then 0 else 1



/-- OR = tropical min for the Boolean embedding -/
theorem bool_or_is_trop_min (a b : Bool) :
    bool_to_trop (a || b) = min (bool_to_trop a) (bool_to_trop b) := by
  cases a <;> cases b <;> simp [bool_to_trop, min_def]



/-- AND = tropical addition (clamped) for the {0,1} encoding -/
theorem bool_and_is_trop_add_clamp (a b : Bool) :
    bool_to_trop (a && b) = min 1 (bool_to_trop a + bool_to_trop b) := by
  cases a <;> cases b <;> simp [bool_to_trop, min_def]



/-- The fundamental identity connecting all tiers:
a + min(b, c) = min(a + b, a + c)
This is what makes shortest paths, scheduling, and SAT all work tropically. -/
theorem fundamental_tropical_identity (a b c : ℝ) :
    a + min b c = min (a + b) (a + c) := by
  simp [min_def]; split_ifs <;> linarith



theorem trop_distrib_finset {ι : Type*} [DecidableEq ι] (s : Finset ι)
    (hs : s.Nonempty) (a : ℝ) (f : ι → ℝ) :
    a + s.inf' hs f = s.inf' hs (fun i => a + f i) := by
  refine' le_antisymm _ _ <;> simp_all +decide [ add_comm, add_left_comm, add_assoc ];
  · exact fun b hb => ⟨ b, hb, le_rfl ⟩;
  · exact Finset.exists_min_image _ _ hs



end
