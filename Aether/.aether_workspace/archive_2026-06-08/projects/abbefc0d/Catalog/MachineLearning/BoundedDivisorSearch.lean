import Mathlib

/-! # Bounded Divisor Search: Certified Finite Search for Compositeness

This module establishes the arithmetic foundations for certified bounded search,
proving that any nontrivial divisor of a composite number yields a canonical
bounded complementary factor, and that trial division up to `√N` is complete
for compositeness detection.

## Main results

* `exists_factor_le_sqrt_of_dvd` — Any nontrivial divisor `p` of `N ≥ 2` determines a
  complementary factor `q = N/p`, and the smaller of the two is bounded by `√N`.
* `exists_small_factor_of_composite` — Every composite `N ≥ 2` has a nontrivial divisor
  at most `√N`.
* `composite_iff_exists_divisor_le_sqrt` — `N` is composite iff there exists a divisor
  in `[2, √N]`.
* `composite_detection_complete_on_Icc` — The same equivalence over `Finset.Icc`.
* `gcd_of_factor_pair` — `gcd(p, q) ∣ p * q`.

These theorems formalize the principle that computational search for compositeness
witnesses can be truncated to a bounded region, connecting to the catalog's
`smaller_factor_sqrt_bound` and the bounded-feasibility paradigm of
`feasibleChannelSet_bounded`.
-/

/-- Given a factorization `N = p * q` with `p ≤ q`, the smaller factor `p ≤ √N`.
This is the core arithmetic engine for bounded divisor search. -/
theorem smaller_factor_sqrt_bound' (N p q : ℕ) (hN : N = p * q) (hle : p ≤ q) :
    p ≤ Nat.sqrt N := by
  rw [hN, Nat.le_sqrt]
  nlinarith

/-
Any nontrivial divisor of `N ≥ 2` determines a complementary factor, and one of
the two factors is bounded by `√N`.
-/
theorem exists_factor_le_sqrt_of_dvd
    (N p : ℕ)
    (hN : 2 ≤ N)
    (_hp1 : 2 ≤ p)
    (hpdvd : p ∣ N) :
    ∃ q : ℕ, N = p * q ∧ 1 ≤ q ∧ (p ≤ q → p ≤ Nat.sqrt N) ∧ (q ≤ p → q ≤ Nat.sqrt N) := by
  -- Apply the smaller factor bound theorem to the factorization `N = p * q`.
  obtain ⟨q, hNq⟩ : ∃ q, N = p * q := hpdvd;
  exact ⟨ q, hNq, by nlinarith, fun h => smaller_factor_sqrt_bound' N p q hNq h, fun h => smaller_factor_sqrt_bound' N q p ( by linarith ) h ⟩

/-
A composite number `N ≥ 2` has a nontrivial divisor strictly less than `N`.
-/
theorem composite_has_nontrivial_divisor
    (N : ℕ) (hN : 2 ≤ N) (hcomp : ¬ Nat.Prime N) :
    ∃ d, 2 ≤ d ∧ d ∣ N ∧ d < N := by
  exact Exists.imp ( by aesop ) ( Nat.exists_dvd_of_not_prime2 hN hcomp )

/-
Every composite `N ≥ 2` has a nontrivial divisor at most `√N`.
-/
theorem exists_small_factor_of_composite
    (N : ℕ)
    (hN : 2 ≤ N)
    (hcomp : ¬ Nat.Prime N) :
    ∃ d : ℕ, 2 ≤ d ∧ d ∣ N ∧ d ≤ Nat.sqrt N := by
  obtain ⟨ d, hd₁, hd₂, hd₃ ⟩ := composite_has_nontrivial_divisor N hN hcomp;
  obtain ⟨ q, rfl ⟩ := hd₂;
  rcases le_total d q with h | h <;> [ exact ⟨ d, hd₁, dvd_mul_right _ _, by rw [ Nat.le_sqrt ] ; nlinarith ⟩ ; exact ⟨ q, by nlinarith, dvd_mul_left _ _, by rw [ Nat.le_sqrt ] ; nlinarith ⟩ ]

/-
Compositeness is equivalent to the existence of a divisor in `[2, √N]`.
-/
theorem composite_iff_exists_divisor_le_sqrt
    (N : ℕ) (hN : 2 ≤ N) :
    (¬ Nat.Prime N) ↔ ∃ d : ℕ, 2 ≤ d ∧ d ≤ Nat.sqrt N ∧ d ∣ N := by
  refine' ⟨ fun h => _, fun ⟨ d, hd₁, hd₂, hd₃ ⟩ h => _ ⟩;
  · obtain ⟨ k, hk₁, hk₂ ⟩ := exists_small_factor_of_composite N hN h; exact ⟨ k, hk₁, hk₂.2, hk₂.1 ⟩ ;
  · rw [ h.dvd_iff_eq ] at hd₃ <;> nlinarith [ Nat.sqrt_le N ]

/-
Compositeness detection is complete on `Finset.Icc 2 (Nat.sqrt N)` —
a computationally actionable finite set.
-/
theorem composite_detection_complete_on_Icc
    (N : ℕ) (hN : 2 ≤ N) :
    (¬ Nat.Prime N) ↔
      ∃ d ∈ Finset.Icc 2 (Nat.sqrt N), d ∣ N := by
  convert composite_iff_exists_divisor_le_sqrt N hN using 1;
  aesop

/-
`gcd(p, q)` divides `p * q`.
-/
theorem gcd_of_factor_pair
    (N p q : ℕ)
    (hN : N = p * q) :
    Nat.gcd p q ∣ N := by
  exact hN ▸ dvd_mul_of_dvd_left ( Nat.gcd_dvd_left _ _ ) _