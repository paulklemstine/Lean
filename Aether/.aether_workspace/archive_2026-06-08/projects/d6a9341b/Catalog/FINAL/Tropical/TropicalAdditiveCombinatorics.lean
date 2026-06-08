/-
# Tropical Additive Combinatorics

This file develops a formal framework for tropical (min-plus) additive combinatorics
over ℕ. The key insight is that additive representation theory of subsets of ℕ can be
recast as tropical linear algebra: sumset membership becomes tropical convolution vanishing.

## Main definitions
- `tropInd`: Tropical indicator function of a set (0 on the set, ⊤ off it)
- `tropConvNat`: Min-plus convolution of two cost functions on ℕ
- `primeCost`: Tropical indicator of the primes
- `goldbachTrop`: Tropical self-convolution of `primeCost`

## Main results
- `tropInd_tropConv_eq_zero_iff`: Tropical convolution of indicators vanishes iff sumset membership
- `tropInd_tropConv_eq_top_iff`: Tropical convolution is ⊤ iff no sumset representation
- `goldbach_tropical_equiv_pointwise`: goldbachTrop n = 0 ↔ n is a sum of two primes
- `goldbach_conjecture_iff_tropical`: Goldbach's conjecture ↔ tropical vanishing on even n > 2
- `not_bounded_of_goldbach_counterexample`: A Goldbach counterexample forces goldbachTrop = ⊤
- `tropConv_self_eventually_zero_of_bounded_compl`: Cofinite sets have eventually zero self-convolution
-/

import Mathlib

open scoped Classical
open Finset WithTop

/-! ## Core Definitions -/

/-- Tropical indicator of a set: cost 0 on the set, ⊤ off it. -/
noncomputable def tropInd (A : Set ℕ) (n : ℕ) : WithTop ℕ :=
  if n ∈ A then 0 else ⊤

/-- Min-plus convolution of two cost functions on ℕ.
    `(f ⋆ₜ g)(n) = inf_{a+b=n} (f(a) + g(b))` computed as a finite infimum.
    We use `Finset.inf` which requires `OrderTop`, satisfied by `WithTop ℕ`. -/
noncomputable def tropConvNat (f g : ℕ → WithTop ℕ) (n : ℕ) : WithTop ℕ :=
  Finset.inf (Finset.range (n + 1)) (fun a => f a + g (n - a))

/-- Tropical indicator of the prime numbers. -/
def primeCost (n : ℕ) : WithTop ℕ :=
  if Nat.Prime n then 0 else ⊤

/-- The tropical Goldbach function: min-plus self-convolution of the prime indicator. -/
noncomputable def goldbachTrop (n : ℕ) : WithTop ℕ :=
  tropConvNat primeCost primeCost n

/-! ## Auxiliary lemmas -/

/-
The summand is 0 iff both arguments are in their respective sets.
-/
lemma tropInd_add_eq_zero_iff (A B : Set ℕ) (a b : ℕ) :
    tropInd A a + tropInd B b = 0 ↔ a ∈ A ∧ b ∈ B := by
  unfold tropInd; aesop;

/-
The summand is ⊤ iff at least one argument is outside its set.
-/
lemma tropInd_add_eq_top_iff (A B : Set ℕ) (a b : ℕ) :
    tropInd A a + tropInd B b = ⊤ ↔ a ∉ A ∨ b ∉ B := by
  by_cases ha : a ∈ A <;> by_cases hb : b ∈ B <;> simp +decide [ *, tropInd ]

/-! ## Theorem 1: Exact tropical-additive equivalence -/

/-
**Foundational equivalence**: The tropical convolution of set indicators vanishes at `n`
    if and only if `n` is in the sumset `A + B`.
-/
theorem tropInd_tropConv_eq_zero_iff
    (A B : Set ℕ) (n : ℕ) :
    tropConvNat (tropInd A) (tropInd B) n = 0 ↔
      ∃ a b : ℕ, a ∈ A ∧ b ∈ B ∧ a + b = n := by
  constructor;
  · contrapose!;
    intro h;
    refine' ne_of_gt ( lt_of_lt_of_le _ ( Finset.le_inf _ ) );
    exact WithTop.coe_lt_coe.mpr ( Nat.succ_pos 0 );
    intro a ha; by_cases ha' : a ∈ A <;> by_cases hb' : n - a ∈ B <;> simp_all +decide [ tropInd ] ;
    exact h a ( n - a ) ha' hb' ( Nat.add_sub_of_le ha );
  · rintro ⟨ a, b, ha, hb, rfl ⟩;
    refine' le_antisymm _ _;
    · exact Finset.inf_le ( Finset.mem_range.mpr ( Nat.lt_succ_of_le ( Nat.le_add_right _ _ ) ) ) |> le_trans <| by simp +decide [ *, tropInd ] ;
    · exact le_trans ( by norm_num ) ( Finset.le_inf fun x hx => zero_le _ )

/-
The tropical convolution of set indicators is `⊤` at `n` if and only if `n` is
    *not* in the sumset `A + B`.
-/
theorem tropInd_tropConv_eq_top_iff
    (A B : Set ℕ) (n : ℕ) :
    tropConvNat (tropInd A) (tropInd B) n = ⊤ ↔
      ¬ ∃ a b : ℕ, a ∈ A ∧ b ∈ B ∧ a + b = n := by
  constructor <;> intro h;
  · contrapose! h;
    exact ne_of_eq_of_ne ( tropInd_tropConv_eq_zero_iff A B n |>.2 h ) ( by simp +decide );
  · convert tropInd_tropConv_eq_zero_iff A B n |>.not.mp _;
    · constructor <;> intro <;> simp_all +decide [ tropConvNat ];
      intro s hs; contrapose! h; unfold tropInd at *; aesop;
    · exact fun hn => h <| tropInd_tropConv_eq_zero_iff A B n |>.1 hn

/-! ## Theorem 2: Goldbach ↔ tropical vanishing -/

/-
The tropical Goldbach function vanishes at `n` if and only if `n` is expressible
    as the sum of two primes.
-/
theorem goldbach_tropical_equiv_pointwise (n : ℕ) :
    goldbachTrop n = 0 ↔
      ∃ p q : ℕ, Nat.Prime p ∧ Nat.Prime q ∧ p + q = n := by
  convert tropInd_tropConv_eq_zero_iff ( setOf Nat.Prime ) ( setOf Nat.Prime ) n using 1;
  unfold goldbachTrop tropInd;
  congr! 2;
  · exact funext fun n => by unfold primeCost; aesop;
  · exact funext fun n => by unfold primeCost; aesop;

/-
**Goldbach's conjecture is exactly the universal tropical vanishing statement.**
    This theorem is an unconditional equivalence — it does not prove Goldbach.
-/
theorem goldbach_conjecture_iff_tropical :
    (∀ n : ℕ, 2 < n → Even n → goldbachTrop n = 0) ↔
    (∀ n : ℕ, 2 < n → Even n →
      ∃ p q : ℕ, Nat.Prime p ∧ Nat.Prime q ∧ p + q = n) := by
  constructor <;> intro h <;> intro n hn hn' <;> specialize h n hn hn' <;> ( have := goldbach_tropical_equiv_pointwise n ; aesop; )

/-! ## Theorem 3: Counterexample — naive boundedness fails -/

/-
If `n` is not a sum of two primes, then `goldbachTrop n = ⊤`.
-/
theorem not_bounded_of_goldbach_counterexample
    (n : ℕ) (_hgt : 2 < n) (_he : Even n)
    (h : ¬ ∃ p q : ℕ, Nat.Prime p ∧ Nat.Prime q ∧ p + q = n) :
    goldbachTrop n = ⊤ := by
  rw [show goldbachTrop n = tropConvNat (tropInd (setOf Nat.Prime)) (tropInd (setOf Nat.Prime)) n
    from by unfold goldbachTrop; congr 1 <;> exact funext fun k => by simp [tropInd, primeCost]]
  rw [tropInd_tropConv_eq_top_iff]
  push_neg at h ⊢
  exact h

/-
If a Goldbach counterexample exists, then `goldbachTrop` cannot be bounded above
    by any finite constant on even numbers greater than 2.
-/
theorem no_finite_bound_if_counterexample_exists
    (h : ∃ n : ℕ, 2 < n ∧ Even n ∧
      ¬ ∃ p q : ℕ, Nat.Prime p ∧ Nat.Prime q ∧ p + q = n) :
    ¬ ∃ C : ℕ, ∀ n : ℕ, 2 < n → Even n → goldbachTrop n ≤ ↑C := by
  -- From h, get a counterexample n₀ with 2 < n₀, Even n₀, and no prime pair summing to n₀.
  obtain ⟨n₀, hn₀_gt, hn₀_even, hn₀_no_pair⟩ : ∃ n₀, 2 < n₀ ∧ Even n₀ ∧ ¬∃ p q, Nat.Prime p ∧ Nat.Prime q ∧ p + q = n₀ := h;
  exact fun ⟨ C, hC ⟩ => by have := hC n₀ hn₀_gt hn₀_even; exact absurd this ( by erw [ not_bounded_of_goldbach_counterexample n₀ hn₀_gt hn₀_even hn₀_no_pair ] ; exact not_le_of_gt ( WithTop.coe_lt_top _ ) ) ;

/-! ## Theorem 4: Cofinite sets — unconditional tropical vanishing -/

/-
**Unconditional tropical theorem**: If every `n ≥ M` belongs to `A`, then the tropical
    self-convolution of `A`'s indicator vanishes for all `n ≥ 2M`.
-/
theorem tropConv_self_eventually_zero_of_bounded_compl
    (A : Set ℕ) (M : ℕ)
    (hA : ∀ n : ℕ, M ≤ n → n ∈ A) :
    ∀ n : ℕ, 2 * M ≤ n → tropConvNat (tropInd A) (tropInd A) n = 0 := by
  intro n hn
  have h_inf : ∃ a ∈ Finset.range (n + 1), tropInd A a + tropInd A (n - a) = 0 := by
    use M, Finset.mem_range.mpr ( by linarith ), ?_;
    grind +suggestions;
  exact le_antisymm ( Finset.inf_le h_inf.choose_spec.1 |> le_trans <| h_inf.choose_spec.2.le ) ( by exact le_trans ( by norm_num ) ( Finset.le_inf fun x hx => zero_le _ ) )

/-
Cofinite sets have eventually zero tropical self-convolution.
-/
theorem tropConv_self_eventually_zero_of_finite_compl
    (A : Set ℕ)
    (hA : (Aᶜ).Finite) :
    ∃ N : ℕ, ∀ n : ℕ, N ≤ n → tropConvNat (tropInd A) (tropInd A) n = 0 := by
  obtain ⟨ M, hM ⟩ := hA.bddAbove; exact ⟨ 2 * ( M + 1 ), fun n hn => by exact tropConv_self_eventually_zero_of_bounded_compl A ( M + 1 ) ( fun n hn => by contrapose! hn; linarith [ hM hn ] ) n hn ⟩ ;

/-! ## Theorem 5: Zero locus equals sumset -/

/-
The zero locus of the tropical convolution of finset indicators within a range
    equals the image sumset.
-/
theorem zero_locus_tropConv_eq_sumset (A B : Finset ℕ) (N : ℕ)
    (hN : ∀ x ∈ A, ∀ y ∈ B, x + y < N) :
    ((Finset.range N).filter
      (fun n => tropConvNat (tropInd (↑A : Set ℕ)) (tropInd (↑B : Set ℕ)) n = 0)) =
    Finset.image₂ (· + ·) A B := by
  -- By definition of $tropConvNat$, we know that $tropConvNat (tropInd A) (tropInd B) n = 0$ if and only if there exist $a \in A$ and $b \in B$ such that $a + b = n$.
  ext n
  simp [tropInd_tropConv_eq_zero_iff];
  exact fun x hx y hy hxy => hxy ▸ hN x hx y hy

/-! ## Commutativity of tropical convolution -/

/-
Tropical convolution is commutative.
-/
theorem tropConvNat_comm (f g : ℕ → WithTop ℕ) (n : ℕ) :
    tropConvNat f g n = tropConvNat g f n := by
  refine' le_antisymm _ _;
  · simp +decide [ tropConvNat ];
    intro b hb; convert Finset.inf_le ( Finset.mem_range.mpr ( show n - b < n + 1 from Nat.lt_succ_of_le ( Nat.sub_le _ _ ) ) ) using 1 ; simp +decide [ add_comm, Nat.sub_sub_self hb ] ;
  · unfold tropConvNat; simp +decide [ Finset.inf_eq_iInf ] ;
    intro i hi; refine' le_trans ( ciInf_le _ ( n - i ) ) _ ; aesop;
    rw [ Nat.sub_sub_self hi, add_comm ];
    exact ciInf_le_of_le ⟨ ⊥, Set.forall_mem_range.mpr fun _ => bot_le ⟩ ( Nat.sub_le _ _ ) le_rfl

/-! ## Tropical indicator only takes values 0 or ⊤ -/

/-
The tropical convolution of indicators only takes values in `{0, ⊤}`.
-/
theorem tropConvNat_tropInd_eq_zero_or_top (A B : Set ℕ) (n : ℕ) :
    tropConvNat (tropInd A) (tropInd B) n = 0 ∨
    tropConvNat (tropInd A) (tropInd B) n = ⊤ := by
  grind +suggestions