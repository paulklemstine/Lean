/-! # CatalogBuild.Computation.Oracles.MillenniumCrossExam

Auto-generated from theorem catalog database.
Domain: Computation/Oracles
Declarations: 11
-/

import Mathlib

/-- [Section: # CatalogBuild.Computation.Oracles.MillenniumCrossExam
Auto-generated from theorem catalog database.
Domain: Computation/Oracles
Declarations: 11] -/
theorem oracle_p_subset_np (P : ℕ → Prop) [DecidablePred P] :
    ∀ n, P n ∨ ¬ P n := by
  exact fun n => em _





/-- [Section: # CatalogBuild.Computation.Oracles.MillenniumCrossExam
Auto-generated from theorem catalog database.
Domain: Computation/Oracles
Declarations: 11] -/
theorem oracle_pigeonhole {α β : Type*} [DecidableEq β]
    (s : Finset α) (t : Finset β) (f : α → β)
    (hf : ∀ a ∈ s, f a ∈ t) (hst : t.card < s.card) :
    ∃ a₁ ∈ s, ∃ a₂ ∈ s, a₁ ≠ a₂ ∧ f a₁ = f a₂ := by
  contrapose! hst;
  exact Finset.card_le_card ( show Finset.image f s ⊆ t from Finset.image_subset_iff.2 hf ) |> fun h => h.trans' ( by rw [ Finset.card_image_of_injOn fun a ha b hb hab => not_imp_not.1 ( hst a ha b hb ) hab ] )





/-- [Section: # CatalogBuild.Computation.Oracles.MillenniumCrossExam
Auto-generated from theorem catalog database.
Domain: Computation/Oracles
Declarations: 11] -/
theorem oracle_mobius_squared_bound (n : ℕ) (hn : n > 0) :
    Int.natAbs (ArithmeticFunction.moebius n) ≤ 1 := by
  unfold ArithmeticFunction.moebius;
  aesop





theorem oracle_totient_le (n : ℕ) : Nat.totient n ≤ n := by
  exact Nat.totient_le n





theorem oracle_totient_prime (p : ℕ) (hp : Nat.Prime p) :
    Nat.totient p = p - 1 := by
  exact Nat.totient_prime hp





theorem oracle_totient_prime_pow (p : ℕ) (hp : Nat.Prime p) (k : ℕ) (hk : k ≥ 1) :
    Nat.totient (p ^ k) = p ^ k - p ^ (k - 1) := by
  rcases k with ( _ | k ) <;> simp_all +decide [ Nat.totient_prime_pow ];
  rw [ pow_succ, mul_tsub, mul_one ]





theorem oracle_bezout (a b : ℤ) :
    ∃ x y : ℤ, a * x + b * y = Int.gcd a b := by
  exact Int.gcd_eq_gcd_ab a b ▸ ⟨ _, _, rfl ⟩





theorem oracle_zmod_card (n : ℕ) [NeZero n] :
    Fintype.card (ZMod n) = n := by
  cases n <;> aesop





theorem oracle_frobenius (p : ℕ) (hp : Nat.Prime p) (a b : ZMod p) :
    (a + b) ^ p = a ^ p + b ^ p := by
  haveI := Fact.mk hp; simp +decide [ add_pow_char ] ;





theorem oracle_powerset_card (α : Type*) [Fintype α] [DecidableEq α] :
    Fintype.card (Finset α) = 2 ^ Fintype.card α := by
  convert Set.toFinset_card;
  swap;
  exact α;
  aesop





theorem oracle_binomial_sum (n : ℕ) :
    ∑ k ∈ range (n + 1), Nat.choose n k = 2 ^ n := by
  rw [ Nat.sum_range_choose ]



