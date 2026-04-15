/-! # CatalogBuild.NumberTheory.Factoring.HyperbolicFactoring

Auto-generated from theorem catalog database.
Domain: NumberTheory/Factoring
Declarations: 16
-/

import Mathlib

noncomputable section

/-- A lattice point on the hyperbola xy = n is a pair (a, b) of positive naturals
with a * b = n. -/
def OnHyperbola (n a b : ℕ) : Prop := a * b = n ∧ 0 < a ∧ 0 < b


/-- Every divisor of n gives a lattice point on xy = n. -/
theorem divisor_gives_lattice_point {n d : ℕ} (hn : 0 < n) (hd : d ∣ n) (hd_pos : 0 < d) :
    OnHyperbola n d (n / d) := by
  refine ⟨Nat.mul_div_cancel' hd, hd_pos, Nat.div_pos (Nat.le_of_dvd hn hd) hd_pos⟩


/-- Every lattice point on xy = n gives a divisor of n. -/
theorem lattice_point_gives_divisor {n a b : ℕ} (h : OnHyperbola n a b) :
    a ∣ n := by
  obtain ⟨hab, _, _⟩ := h
  exact ⟨b, hab.symm⟩


/-- The fundamental correspondence: d divides n if and only if
(d, n/d) is a lattice point on xy = n. -/
theorem divisor_iff_lattice_point {n d : ℕ} (hn : 0 < n) (hd : 0 < d) :
    d ∣ n ↔ OnHyperbola n d (n / d) := by
  constructor
  · exact fun h => divisor_gives_lattice_point hn h hd
  · exact fun h => lattice_point_gives_divisor h


/-- The hyperbola xy = n is symmetric under (a,b) ↦ (b,a). -/
theorem hyperbola_symm {n a b : ℕ} :
    OnHyperbola n a b ↔ OnHyperbola n b a := by
  constructor <;> (intro ⟨h, ha, hb⟩; exact ⟨by linarith [mul_comm a b], hb, ha⟩)


/-- The set of lattice points on xy = n, represented as divisors. -/
noncomputable def hyperbolaPoints (n : ℕ) : Finset (ℕ × ℕ) :=
  (Nat.divisors n).map ⟨fun d => (d, n / d), by
    intro d₁ d₂ h
    simp only [Prod.mk.injEq] at h
    exact h.1⟩


/-- The number of lattice points on xy = n equals the number of divisors of n. -/
theorem lattice_point_count_eq_num_divisors (n : ℕ) :
    (hyperbolaPoints n).card = (Nat.divisors n).card := by
  simp [hyperbolaPoints, Finset.card_map]


/-- 210 = 2 × 3 × 5 × 7 -/
theorem n210_factorization : 210 = 2 * 3 * 5 * 7 := by norm_num


/-- 210 has exactly 16 divisors. -/
theorem n210_divisor_count : (Nat.divisors 210).card = 16 := by native_decide


/-- The divisors of 210 are {1,2,3,5,6,7,10,14,15,21,30,35,42,70,105,210}. -/
theorem n210_divisors :
    Nat.divisors 210 = {1, 2, 3, 5, 6, 7, 10, 14, 15, 21, 30, 35, 42, 70, 105, 210} := by
  native_decide


/-- Each divisor pair of 210 satisfies d * (210/d) = 210. -/
theorem n210_divisor_pair_product (d : ℕ) (hd : d ∈ Nat.divisors 210) :
    d * (210 / d) = 210 := by
  rw [Nat.mem_divisors] at hd
  exact Nat.mul_div_cancel' hd.1


/-- [Section: ## Section 5: Dirichlet's Hyperbola Method] -/
theorem divisor_pair_sqrt_bound {n d : ℕ} (hn : 0 < n) (hd : d ∣ n) :
    d ≤ Nat.sqrt n ∨ n / d ≤ Nat.sqrt n := by
  exact Classical.or_iff_not_imp_left.2 fun h => by nlinarith [ Nat.lt_succ_sqrt n, Nat.div_mul_cancel hd ] ;


/-- For prime p, the only lattice points on xy = p are (1, p) and (p, 1). -/
theorem prime_hyperbola_two_points {p : ℕ} (hp : Nat.Prime p) :
    (Nat.divisors p).card = 2 := by
  rw [Nat.Prime.divisors hp]
  exact Finset.card_pair (Nat.Prime.one_lt hp).ne


/-- If gcd(m, n) = 1, then the lattice points on xy = mn are in bijection
with pairs of lattice points on xy = m and xy = n.
This is the geometric content of σ₀ being multiplicative. -/
theorem coprime_hyperbola_product {m n : ℕ} (hcop : Nat.Coprime m n) :
    (Nat.divisors (m * n)).card = (Nat.divisors m).card * (Nat.divisors n).card :=
  Nat.Coprime.card_divisors_mul hcop


/-- The area of the rectangle formed by a divisor pair (d, n/d) is always n.
This is the geometric invariant that AI-based factoring can exploit. -/
theorem rectangle_area_invariant {n d : ℕ} (hd : d ∣ n) :
    d * (n / d) = n :=
  Nat.mul_div_cancel' hd


/-- [Section: ## Section 7: Geometric Structure for Algorithmic Exploitation] -/
theorem hyperbola_strictly_decreasing {n d₁ d₂ : ℕ}
    (hn : 0 < n) (hd₁ : d₁ ∣ n) (hd₂ : d₂ ∣ n)
    (hlt : d₁ < d₂) (hd₁_pos : 0 < d₁) :
    n / d₂ < n / d₁ := by
  exact Nat.div_lt_of_lt_mul <| by nlinarith [ Nat.div_mul_cancel hd₁, Nat.div_mul_cancel hd₂ ] ;


end
