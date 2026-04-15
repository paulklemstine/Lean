/-! # CatalogBuild.FutureResearch.BrahmaguptaFibonacciFactoring

Auto-generated from theorem catalog database.
Domain: FutureResearch
Declarations: 9
-/

import Mathlib

theorem bf_identity_1 (a b c d : ℤ) :
    (a ^ 2 + b ^ 2) * (c ^ 2 + d ^ 2) =
    (a * c - b * d) ^ 2 + (a * d + b * c) ^ 2 := by ring


theorem bf_identity_2 (a b c d : ℤ) :
    (a ^ 2 + b ^ 2) * (c ^ 2 + d ^ 2) =
    (a * c + b * d) ^ 2 + (a * d - b * c) ^ 2 := by ring


theorem bf_cross_term_product (a b c d : ℤ) :
    (a * d - b * c) * (a * d + b * c) = a ^ 2 * d ^ 2 - b ^ 2 * c ^ 2 := by ring


theorem bf_N_divides_cross_product (a b c d : ℤ)
    (h : a ^ 2 + b ^ 2 = c ^ 2 + d ^ 2) :
    (a ^ 2 + b ^ 2) ∣ (a * d - b * c) * (a * d + b * c) := by
  exact ⟨ a ^ 2 - c ^ 2, by nlinarith ⟩


theorem bf_two_representations (a b c d : ℤ) :
    (a ^ 2 + b ^ 2) * (c ^ 2 + d ^ 2) =
    (a * c - b * d) ^ 2 + (a * d + b * c) ^ 2 ∧
    (a ^ 2 + b ^ 2) * (c ^ 2 + d ^ 2) =
    (a * c + b * d) ^ 2 + (a * d - b * c) ^ 2 :=
  ⟨by ring, by ring⟩


theorem bf_representations_distinct (a b c d : ℤ) (hbc : b * c ≠ 0) :
    a * d + b * c ≠ a * d - b * c := by
  grind


theorem bf_nontrivial_factor_criterion (N g : ℕ) (hg_dvd : g ∣ N)
    (hg_gt : 1 < g) (hg_lt : g < N) :
    ∃ k : ℕ, N = g * k ∧ 1 < k := by
  obtain ⟨k, hk⟩ := hg_dvd
  refine ⟨k, hk, ?_⟩
  by_contra h; push_neg at h
  interval_cases k <;> omega


theorem fermat_two_squares (p : ℕ) (hp : Nat.Prime p) (hmod : p % 4 = 1) :
    ∃ a b : ℕ, a ^ 2 + b ^ 2 = p := by
  have := Fact.mk hp;
  have := @Nat.Prime.sq_add_sq p;
  aesop


theorem bf_gcd_divides_N (N t : ℕ) : Nat.gcd N t ∣ N :=
  Nat.gcd_dvd_left N t
