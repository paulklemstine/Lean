/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license.
-/
import Mathlib

/-!
# Non-Archimedean Finite Probability Spaces

This file establishes a rigorous foundation for finite probability theory over arbitrary
linearly ordered fields, extending classical probability beyond the reals to non-Archimedean
settings (e.g., the Levi-Civita field, hyperreals, surreals).

## Novel Mathematical Structure

We introduce `FinProbSpace F n` — a finite probability space with sample space `Fin n` and
weights in an arbitrary linearly ordered field `F`. The key novelty is the companion
`RegularFinProbSpace`, where every point has *strictly positive* weight. Over non-Archimedean
fields, regularity is "free" (use infinitesimal weights), making conditional probability
on singletons universally well-defined.

## Main Results

1. **Inclusion-exclusion** (`inclusion_exclusion_two`):
   P(A ∪ B) = P(A) + P(B) - P(A ∩ B).

2. **Bayes' theorem** (`bayes_theorem`):
   P(A|B) · P(B) = P(B|A) · P(A).

3. **Markov inequality** (`markov_ineq`):
   P(X ≥ t) ≤ E[X] / t.

4. **No Dutch Book theorem** (`no_dutch_book`):
   Probability axioms preclude guaranteed-profit betting.

5. **Dutch Book existence** (`dutch_book_of_sum_ne_one`):
   Mispriced totals admit a Dutch book.

6. **Tropical bridge** (`prob_weight_power_bound`):
   Powers-of-ε weights connect to tropical (min-plus) probability.

## PEGB Coverage

Each major theorem includes Proof, Example, Generalization note, and Boundary analysis.
-/

open Finset

namespace NonArchProb

-- ============================================================================
-- Definitions
-- ============================================================================

/-- A finite probability space over a linearly ordered field `F` with sample space `Fin n`.
Requires nonneg weights summing to 1 — Kolmogorov axioms over an arbitrary ordered field. -/
structure FinProbSpace (F : Type*) [Field F] [LinearOrder F] [IsStrictOrderedRing F]
    (n : ℕ) where
  weight : Fin n → F
  weight_nonneg : ∀ i, 0 ≤ weight i
  weight_sum : ∑ i, weight i = 1

/-- A regular finite probability space: every outcome has strictly positive weight.
Over non-Archimedean fields, regularity is "free" — assign infinitesimal weight ε > 0
to each point. Over ℝ, regularity forces weights bounded away from zero. -/
structure RegularFinProbSpace (F : Type*) [Field F] [LinearOrder F] [IsStrictOrderedRing F]
    (n : ℕ) extends FinProbSpace F n where
  weight_pos : ∀ i, 0 < weight i

variable {F : Type*} [Field F] [LinearOrder F] [IsStrictOrderedRing F] {n : ℕ}

/-- Probability of an event A ⊆ Fin n: the sum of weights over outcomes in A. -/
noncomputable def FinProbSpace.prob (P : FinProbSpace F n) (A : Finset (Fin n)) : F :=
  ∑ i ∈ A, P.weight i

/-- Conditional probability P(A | B) = P(A ∩ B) / P(B). -/
noncomputable def FinProbSpace.condProb (P : FinProbSpace F n) (A B : Finset (Fin n)) : F :=
  P.prob (A ∩ B) / P.prob B

/-- Expectation of a random variable X : Fin n → F. -/
noncomputable def FinProbSpace.expectation (P : FinProbSpace F n) (X : Fin n → F) : F :=
  ∑ i, P.weight i * X i

/-- The event {X ≥ t} as a Finset. -/
noncomputable def eventGe (X : Fin n → F) (t : F) : Finset (Fin n) :=
  Finset.univ.filter (fun i => t ≤ X i)

/-- A Dutch book against prices `p` is stakes guaranteeing positive profit everywhere.
At outcome ω, profit = s(ω) - ∑ s(i)·p(i). -/
structure DutchBook (F : Type*) [Field F] [LinearOrder F] [IsStrictOrderedRing F]
    (n : ℕ) (p : Fin n → F) where
  stake : Fin n → F
  profit_pos : ∀ ω : Fin n, ∑ i : Fin n, stake i * p i < stake ω

/-- The uniform probability space on Fin n (when n > 0). -/
noncomputable def uniformSpace (hn : 0 < n) : FinProbSpace F n where
  weight := fun _ => (1 : F) / n
  weight_nonneg := fun _ => div_nonneg (le_of_lt one_pos) (Nat.cast_nonneg' n)
  weight_sum := by
    simp only [Finset.sum_const, Finset.card_fin, nsmul_eq_mul]
    rw [mul_div_cancel₀]
    exact Nat.cast_ne_zero.mpr (Nat.pos_iff_ne_zero.mp hn)

/-- The uniform space is regular. -/
noncomputable def uniformRegularSpace (hn : 0 < n) : RegularFinProbSpace F n where
  toFinProbSpace := uniformSpace hn
  weight_pos := fun _ => by
    simp only [uniformSpace]
    exact div_pos one_pos (Nat.cast_pos'.mpr hn)

-- ============================================================================
-- Basic properties (proved inline)
-- ============================================================================

theorem prob_univ (P : FinProbSpace F n) : P.prob Finset.univ = 1 := by
  unfold FinProbSpace.prob; exact P.weight_sum

theorem prob_nonneg (P : FinProbSpace F n) (A : Finset (Fin n)) : 0 ≤ P.prob A :=
  Finset.sum_nonneg fun i _ => P.weight_nonneg i

theorem prob_le_one (P : FinProbSpace F n) (A : Finset (Fin n)) : P.prob A ≤ 1 := by
  rw [← prob_univ P]
  exact Finset.sum_le_sum_of_subset_of_nonneg (Finset.subset_univ A)
    (fun i _ _ => P.weight_nonneg i)

theorem prob_empty (P : FinProbSpace F n) : P.prob ∅ = 0 := by
  simp [FinProbSpace.prob]

theorem prob_mono (P : FinProbSpace F n) {A B : Finset (Fin n)} (h : A ⊆ B) :
    P.prob A ≤ P.prob B :=
  Finset.sum_le_sum_of_subset_of_nonneg h (fun i _ _ => P.weight_nonneg i)

/-
============================================================================
Theorem 1: Complement and Inclusion-Exclusion
============================================================================
-/
theorem prob_compl (P : FinProbSpace F n) (A : Finset (Fin n)) :
    P.prob Aᶜ = 1 - P.prob A := by
  convert eq_sub_of_add_eq' ( P.weight_sum ▸ Finset.sum_add_sum_compl A ( fun i => P.weight i ) )

theorem prob_union_disjoint (P : FinProbSpace F n) {A B : Finset (Fin n)}
    (h : Disjoint A B) : P.prob (A ∪ B) = P.prob A + P.prob B := by
  exact Finset.sum_union h

/-
!-- Proof sketch for inclusion_exclusion_two: Use Finset.sum_union_inter to get
∑_{A∪B} w + ∑_{A∩B} w = ∑_A w + ∑_B w. Rearrange. -- !--

**Inclusion-exclusion for two events** (Theorem 1).
P(A ∪ B) = P(A) + P(B) - P(A ∩ B).

*Example*: Over ℚ with uniform weights on Fin 4, A = {0,1}, B = {1,2}:
P(A ∪ B) = 3/4 = 1/2 + 1/2 - 1/4.

*Generalization*: Extends to k-set inclusion-exclusion over arbitrary ordered fields.

*Boundary*: When A ∩ B = ∅, reduces to disjoint additivity.
-/
theorem inclusion_exclusion_two (P : FinProbSpace F n) (A B : Finset (Fin n)) :
    P.prob (A ∪ B) = P.prob A + P.prob B - P.prob (A ∩ B) := by
  unfold FinProbSpace.prob; rw [ ← Finset.sum_union_inter ] ; ring;

/-
============================================================================
Theorem 2: Bayes' Theorem
============================================================================

!-- Proof sketch: Both sides equal P(A ∩ B). Use div_mul_cancel₀ and inter_comm. -- !--

**Bayes' theorem** (Theorem 2).
P(A|B) · P(B) = P(B|A) · P(A) when both P(A) and P(B) are nonzero.
Both sides equal P(A ∩ B).

*Example*: Over ℚ, weights (1/3, 1/3, 1/3) on Fin 3, A = {0,1}, B = {1,2}:
P(A|B)·P(B) = 1/3 = P(B|A)·P(A). ✓

*Generalization*: Extends to Bayes' rule with partition of the sample space.

*Boundary*: When P(A) = 0 or P(B) = 0, both sides are 0 (Lean's div-by-zero = 0).
-/
theorem bayes_theorem (P : FinProbSpace F n) (A B : Finset (Fin n))
    (hA : P.prob A ≠ 0) (hB : P.prob B ≠ 0) :
    P.condProb A B * P.prob B = P.condProb B A * P.prob A := by
  unfold FinProbSpace.condProb; rw [ div_mul_cancel₀ _ hB, div_mul_cancel₀ _ hA ] ;
  rw [ Finset.inter_comm ]

/-
============================================================================
Theorem 3: Markov Inequality
============================================================================

!-- Proof sketch: E[X] = ∑ w(i)X(i) ≥ ∑_{X(i)≥t} w(i)X(i) ≥ ∑_{X(i)≥t} w(i)·t
= t · P(X≥t). Divide by t > 0. -- !--

**Markov inequality** (Theorem 3).
For a nonneg random variable X and threshold t > 0: P(X ≥ t) ≤ E[X] / t.

*Example*: Over ℚ, uniform on Fin 4, X = (0,1,2,3). E[X] = 3/2.
P(X ≥ 2) = 1/2 ≤ 3/4. ✓

*Generalization*: Chebyshev follows by applying Markov to (X-μ)².

*Boundary*: At t = E[X], gives P(X ≥ E[X]) ≤ 1.
-/
theorem markov_ineq (P : FinProbSpace F n) (X : Fin n → F) (hX : ∀ i, 0 ≤ X i)
    (t : F) (ht : 0 < t) :
    P.prob (eventGe X t) ≤ P.expectation X / t := by
  rw [ le_div_iff₀' ht ];
  -- Apply the pointwise bound $w(i) * X(i) \geq w(i) * t$ to each term in the sum.
  have h_pointwise : ∀ i ∈ eventGe X t, P.weight i * X i ≥ P.weight i * t := by
    exact fun i hi => mul_le_mul_of_nonneg_left ( Finset.mem_filter.mp hi |>.2 ) ( P.weight_nonneg i );
  simpa only [ mul_comm, Finset.mul_sum _ _ _, FinProbSpace.expectation, FinProbSpace.prob ] using Finset.sum_le_sum h_pointwise |> le_trans <| Finset.sum_le_sum_of_subset_of_nonneg ( Finset.subset_univ _ ) fun _ _ _ => mul_nonneg ( P.weight_nonneg _ ) ( hX _ )

/-
============================================================================
Theorem 4: No Dutch Book
============================================================================

!-- Proof sketch: If stakes s give profit s(ω) > c = ∑ s(i)p(i) for all ω,
multiply by p(ω) ≥ 0 and sum: ∑ p(ω)s(ω) > c·∑p(ω) = c.
But ∑ p(ω)s(ω) = c. Since ∑ p = 1 > 0 (n > 0), some p(ω₀) > 0 gives strict ineq. -- !--

**No Dutch Book** (Theorem 4).
Probability axioms preclude guaranteed-profit betting.

*Example*: Weights (1/3,1/3,1/3): no stakes s have s(ω) > (s₀+s₁+s₂)/3 for all ω.

*Generalization*: Extends to convex combinations.

*Boundary*: Requires n ≥ 1.
-/
theorem no_dutch_book (P : FinProbSpace F n) :
    IsEmpty (DutchBook F n P.weight) := by
  by_contra! h_nonempty;
  obtain ⟨db⟩ := h_nonempty
  obtain ⟨s, hs⟩ := db
  set c := ∑ i, s i * P.weight i
  have h_pos : ∃ ω₀, P.weight ω₀ > 0 := by
    by_cases h_zero : ∀ ω, P.weight ω = 0;
    · have := P.weight_sum; simp_all +decide ;
    · exact not_forall_not.mp fun h => h_zero fun ω => le_antisymm ( le_of_not_gt ( h ω ) ) ( P.weight_nonneg ω );
  obtain ⟨ ω₀, hω₀ ⟩ := h_pos
  have hsum : ∑ ω, P.weight ω * s ω > ∑ ω, P.weight ω * c := by
    refine' Finset.sum_lt_sum _ _;
    · exact fun i _ => mul_le_mul_of_nonneg_left ( le_of_lt ( hs i ) ) ( P.weight_nonneg i );
    · exact ⟨ ω₀, Finset.mem_univ _, mul_lt_mul_of_pos_left ( hs ω₀ ) hω₀ ⟩;
  simp_all +decide [ ← Finset.sum_mul _ _ _, mul_comm ];
  rw [ P.weight_sum ] at hsum ; aesop

/-
============================================================================
Theorem 5: Dutch Book Existence
============================================================================

!-- Proof sketch: If ∑ p < 1, stakes = 1 everywhere. Profit at ω = 1 - ∑ p > 0.
If ∑ p > 1, stakes = -1 everywhere. Profit at ω = ∑ p - 1 > 0. -- !--

**Dutch book from mispriced totals** (Theorem 5).
If prices don't sum to 1, a Dutch book exists.

*Example*: Prices (0.4,0.4,0.4) sum to 1.2. Stakes (-1,-1,-1):
profit at any ω = 1.2 - 1 = 0.2 > 0.

*Generalization*: Full Dutch book iff: no Dutch book ↔ probability axioms.

*Boundary*: ∑ p = 1 with some p(i) < 0 needs separate argument.
-/
theorem dutch_book_of_sum_ne_one (p : Fin n → F)
    (h : ∑ i, p i ≠ 1) : Nonempty (DutchBook F n p) := by
  by_cases h_sum : ∑ i, p i < 1;
  · exact ⟨ ⟨ fun _ => 1, fun _ => by simpa using h_sum ⟩ ⟩;
  · refine' ⟨ fun _ => -1, fun _ => _ ⟩ ; simp_all +decide [ Finset.sum_neg_distrib ];
    exact lt_of_le_of_ne h_sum ( Ne.symm h )

-- ============================================================================
-- Regular probability: conditional probability on singletons
-- ============================================================================

theorem regular_singleton_pos (P : RegularFinProbSpace F n) (i : Fin n) :
    0 < P.prob {i} := by
  simp [FinProbSpace.prob, P.weight_pos i]

/-
In a regular probability space, conditional probability on a singleton
is always well-defined. This is a key advantage of non-Archimedean probability.
-/
theorem regular_condProb_singleton_welldefined (P : RegularFinProbSpace F n) (i : Fin n)
    (A : Finset (Fin n)) :
    P.condProb A {i} = if i ∈ A then 1 else 0 := by
  by_cases hi : i ∈ A <;> simp +decide [ hi, FinProbSpace.condProb ];
  · exact ne_of_gt ( regular_singleton_pos P i );
  · exact Or.inl ( prob_empty _ )

/-
============================================================================
Tropical bridge: weight power bound
============================================================================

**Valuation compatibility** (tropical bridge).
When weights = ε^{k(i)} with ε ∈ (0,1), probability is squeezed between
ε^{min k} and |A|·ε^{min k}. In the tropical limit, log P(A) → min k(A).
-/
theorem prob_weight_power_bound (P : FinProbSpace F n) (ε : F) (k : Fin n → ℕ)
    (hε_pos : 0 < ε) (hε_lt : ε < 1)
    (hweq : ∀ i, P.weight i = ε ^ k i)
    (A : Finset (Fin n))
    (j : Fin n) (hj : j ∈ A) (hj_min : ∀ i ∈ A, k j ≤ k i) :
    ε ^ k j ≤ P.prob A ∧ P.prob A ≤ A.card • (ε ^ k j) := by
  constructor;
  · exact Finset.single_le_sum ( fun i _ => show 0 ≤ P.weight i from hweq i ▸ pow_nonneg hε_pos.le _ ) hj |> le_trans ( by simp +decide [ hweq ] );
  · refine' le_trans ( Finset.sum_le_sum fun i hi => _ ) _;
    exacts [ fun _ => ε ^ k j, by rw [ hweq ] ; exact pow_le_pow_of_le_one hε_pos.le hε_lt.le ( hj_min _ hi ), by simp +decide ]

-- ============================================================================
-- Concrete examples
-- ============================================================================

noncomputable example : FinProbSpace ℚ 3 := uniformSpace (by omega)

example : FinProbSpace ℚ 3 where
  weight := ![1/2, 1/3, 1/6]
  weight_nonneg := by intro i; fin_cases i <;> simp [Matrix.cons_val_zero, Matrix.cons_val_one]
  weight_sum := by simp [Fin.sum_univ_three, Matrix.cons_val_zero, Matrix.cons_val_one]; ring

end NonArchProb