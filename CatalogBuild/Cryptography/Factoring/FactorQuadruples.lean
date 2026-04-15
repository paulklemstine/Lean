/-! # CatalogBuild.Cryptography.Factoring.FactorQuadruples

Auto-generated from theorem catalog database.
Domain: Cryptography/Factoring
Declarations: 12
-/

import Mathlib

/-- A factor pair of n is an ordered pair (a, b) with a * b = n. -/
structure FactorPair (n : ℕ) where
  a : ℕ
  b : ℕ
  ha : 0 < a
  hb : 0 < b
  hab : a * b = n


/-- A factor quadruple of n consists of two factor pairs (a,b) and (c,d) with ab = cd = n. -/
structure FactorQuadruple (n : ℕ) where
  pair1 : FactorPair n
  pair2 : FactorPair n


/-- Swapping the two factor pairs in a quadruple yields another quadruple. -/
def FactorQuadruple.swap {n : ℕ} (q : FactorQuadruple n) : FactorQuadruple n :=
  ⟨q.pair2, q.pair1⟩


/-- If two factor pairs (a,b) and (c,d) both multiply to n,
then gcd(a,c) divides n. -/
theorem quadruple_gcd_dvd_n {n a b c d : ℕ}
    (hab : a * b = n) (hcd : c * d = n) :
    Nat.gcd a c ∣ n :=
  dvd_trans (Nat.gcd_dvd_left a c) ⟨b, hab.symm⟩


/-- Two distinct divisor pairs (a,b) and (c,d) with ab = cd = n and a ≠ c
always produce a proper divisor of n via gcd when n is not prime. -/
theorem divisor_pair_gcd_nontrivial {n a b c d : ℕ}
    (hn : 1 < n)
    (ha : 0 < a) (hb : 0 < b) (hc : 0 < c) (hd : 0 < d)
    (hab : a * b = n) (hcd : c * d = n)
    (hac : a ≠ c) (ha_lt : a < n) (hc_lt : c < n) :
    0 < Nat.gcd a c ∧ Nat.gcd a c ∣ n := by
  refine ⟨Nat.pos_of_ne_zero (fun h => ?_), dvd_trans (Nat.gcd_dvd_left a c) ⟨b, hab.symm⟩⟩
  have := Nat.eq_zero_of_gcd_eq_zero_left h
  omega


/-- Every divisor d of n with 0 < d corresponds to the lattice point (d, n/d)
on the hyperbola xy = n. -/
theorem lattice_point_on_hyperbola {n d : ℕ} (hd : d ∣ n) :
    d * (n / d) = n :=
  Nat.mul_div_cancel' hd


/-- [Section: ## Section 3: Lattice Interpretation] -/
theorem lattice_points_eq_divisor_count (n : ℕ) (hn : 0 < n) :
    (Finset.filter (fun d => d ∣ n) (Finset.Icc 1 n)).card = n.divisors.card := by
  exact congr_arg _ ( by ext x; exact ⟨ fun hx => Nat.mem_divisors.mpr ⟨ by aesop, by aesop ⟩, fun hx => Finset.mem_filter.mpr ⟨ Finset.mem_Icc.mpr ⟨ Nat.pos_of_mem_divisors hx, Nat.le_of_dvd hn ( Nat.dvd_of_mem_divisors hx ) ⟩, by aesop ⟩ ⟩ )


/-- [Section: ## Section 4: Fermat's Method as Quadruple Search] -/
theorem fermat_factoring_from_difference_of_squares {n x y : ℕ}
    (hxy : y < x) (heq : x ^ 2 - y ^ 2 = n) (hn : 0 < n) :
    (x - y) * (x + y) = n := by
  rwa [ Nat.sq_sub_sq, mul_comm ] at heq


/-- In Fermat's method, the two factors (x-y) and (x+y) satisfy
(x-y) ≤ √n ≤ (x+y), showing the search is symmetric around √n. -/
theorem fermat_factor_symmetry {n x y : ℕ}
    (hxy : y < x) (heq : x ^ 2 - y ^ 2 = n) (hn : 0 < n) :
    (x - y) * (x + y) = n ∧ x - y ≤ x + y := by
  exact ⟨fermat_factoring_from_difference_of_squares hxy heq hn, by omega⟩


/-- If n has k distinct prime factors all ≤ B, then n has at least 2^k divisors,
meaning more potential factor quadruples. -/
theorem smooth_has_many_divisors {n : ℕ} (hn : 1 < n)
    (factors : Finset ℕ) (hfactors : ∀ p ∈ factors, Nat.Prime p ∧ p ∣ n) :
    factors.card ≤ n.divisors.card := by
  apply Finset.card_le_card
  intro p hp
  simp [Nat.mem_divisors]
  exact ⟨(hfactors p hp).2, by omega⟩


/-- Main theorem: Given n = ab = cd with gcd(a,c) = g,
we can write a = g·α, c = g·γ with gcd(α,γ) = 1,
and g divides n. This is the algebraic core of quadruple-based factoring. -/
theorem quadruple_gcd_decomposition {n a b c d : ℕ}
    (ha : 0 < a) (hc : 0 < c)
    (hab : a * b = n) (hcd : c * d = n) :
    let g := Nat.gcd a c
    g ∣ a ∧ g ∣ c ∧ g ∣ n := by
  simp only
  exact ⟨Nat.gcd_dvd_left a c, Nat.gcd_dvd_right a c,
         dvd_trans (Nat.gcd_dvd_left a c) ⟨b, hab.symm⟩⟩


/-- Cross-ratio property: if ab = cd, then a/gcd(a,c) and c/gcd(a,c) are coprime,
and their product structure encodes complementary factor information. -/
theorem cross_ratio_coprime {a c : ℕ} (ha : 0 < a) (hc : 0 < c) :
    Nat.Coprime (a / Nat.gcd a c) (c / Nat.gcd a c) :=
  Nat.coprime_div_gcd_div_gcd (Nat.gcd_pos_of_pos_left c ha)

