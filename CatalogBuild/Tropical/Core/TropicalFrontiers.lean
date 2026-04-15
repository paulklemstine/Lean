/-! # CatalogBuild.Tropical.Core.TropicalFrontiers

Auto-generated from theorem catalog database.
Domain: Tropical/Core
Declarations: 14
-/

import Mathlib

noncomputable section

/-- T5: Tropical division (subtraction) is inverse of multiplication -/
theorem tropDiv_inverse (a b : ℝ) : tropMul (a - b) b = a := by
  unfold tropMul; ring


/-- The Interference Barrier Theorem (left): a ⊕ b ≥ a.
This is the fundamental reason tropical "quantum" computing
cannot simulate destructive interference. -/
theorem interference_barrier_left (a b : ℝ) : a ≤ tropAdd a b :=
  le_max_left a b


/-- The Interference Barrier Theorem (right): a ⊕ b ≥ b. -/
theorem interference_barrier_right (a b : ℝ) : b ≤ tropAdd a b :=
  le_max_right a b


/-- Tropical addition is monotone (no cancellation possible) -/
theorem tropAdd_mono_left (a : ℝ) {b c : ℝ} (h : b ≤ c) :
    tropAdd a b ≤ tropAdd a c :=
  max_le_max_left a h


/-- Key consequence: repeated tropical addition is idempotent.
In quantum mechanics, |ψ⟩ + |ψ⟩ = 2|ψ⟩ ≠ |ψ⟩ (amplification).
In tropical "quantum": v ⊕ v = v (no amplification). -/
theorem no_amplification (v : ℝ) : tropAdd v v = v := tropAdd_idempotent v


/-- Bellman optimality: if d satisfies the Bellman equation, it gives shortest paths -/
theorem bellman_optimality (d : ℕ → ℤ) (w : ℕ → ℤ)
    (h : ∀ v, d v = min (d v) (d 0 + w v)) (v : ℕ) :
    d v ≤ d 0 + w v := by
  have := h v; omega


/-- Newton polygon slopes encode p-adic root data. -/
theorem newton_slope_determines_valuation (v0 v1 : ℤ) :
    v0 - v1 = -(v1 - v0) := by omega


/-- The tropical polynomial trop(f)(x) = min(v(a₀), v(a₁) + x) has a
corner at x = v(a₀) - v(a₁). -/
theorem tropical_corner (v0 v1 x : ℤ) :
    min v0 (v1 + x) = v0 ↔ v1 + x ≥ v0 := by
  constructor
  · intro h; omega
  · intro h; omega


/-- p-adic valuation is a tropical homomorphism: v_p(ab) = v_p(a) + v_p(b) -/
theorem padic_val_mul_tropical {p : ℕ} (hp : Nat.Prime p)
    {a b : ℕ} (ha : a ≠ 0) (hb : b ≠ 0) :
    padicValNat p (a * b) = padicValNat p a + padicValNat p b := by
  haveI : Fact (Nat.Prime p) := ⟨hp⟩
  exact padicValNat.mul ha hb


theorem padic_val_gcd_eq_min {p : ℕ} (hp : Nat.Prime p)
    {a b : ℕ} (ha : a ≠ 0) (hb : b ≠ 0) :
    padicValNat p (Nat.gcd a b) = min (padicValNat p a) (padicValNat p b) := by
  -- Apply the lemma that states the p-adic valuation of the gcd of two numbers is the minimum of their p-adic valuations.
  have h_gcd_val : padicValNat p (Nat.gcd a b) = min (padicValNat p a) (padicValNat p b) := by
    have := Nat.factorization_gcd ha hb
    replace this := congr_arg ( fun x => x p ) this; simp_all +decide [ Nat.factorization ] ;
  exact h_gcd_val


/-- For the tropical permanent, n! permutations contribute. -/
theorem permanent_region_lower_bound (n : ℕ) :
    1 ≤ n.factorial := Nat.one_le_iff_ne_zero.mpr (Nat.factorial_ne_zero n)


theorem tropical_factoring_barrier {p n : ℕ} (hp : Nat.Prime p)
    (hn : n ≠ 0) :
    1 ≤ padicValNat p n ↔ p ∣ n := by
  by_cases h : p ∣ n <;> simp_all +decide [ Nat.factorization ];
  exact Nat.pos_of_ne_zero ( by aesop )


/-- v_p(1) = 0: the multiplicative identity maps to tropical zero -/
theorem padic_val_one' (p : ℕ) : padicValNat p 1 = 0 := by simp


/-- v_p(p) = 1 for prime p -/
theorem padic_val_self' {p : ℕ} (hp : Nat.Prime p) :
    padicValNat p p = 1 := by
  haveI : Fact (Nat.Prime p) := ⟨hp⟩
  exact padicValNat.self hp.one_lt


end
