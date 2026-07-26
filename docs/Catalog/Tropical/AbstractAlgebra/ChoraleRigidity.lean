import Mathlib

/-!
# Four-Voice Chorale Cost and Zero-Cost Rigidity

This module formalizes:

1. **Chorale cost functional**: A four-voice cost assembled from pairwise
   voice-interaction terms and unary spacing/register penalties.

2. **Forward zero-cost theorem** (`choraleCost_eq_zero_of_pairwise_zero`):
   If every pair cost and every spacing penalty vanishes, the total cost is zero.

3. **Converse rigidity theorem** (`pairwise_zero_of_choraleCost_eq_zero`):
   If the total cost is zero and every summand is nonneg, then every pairwise
   interaction cost and every spacing penalty vanishes individually.

This is a formal **local-to-global optimality certificate** for polyphonic
writing: it turns a global optimum certificate into six local certificates
plus four unary certificates.
-/

open Finset BigOperators

noncomputable section

/-- A melody of length `n` is a sequence of integer pitches. -/
def Melody' (n : ℕ) := Fin n → ℤ

/-- A chorale is a 4-tuple of melodies, one for each voice (S, A, T, B). -/
def Chorale (n : ℕ) := Fin 4 → Melody' n

/-- The six unordered voice pairs `(i,j)` with `i < j`. -/
def voicePairs : Finset (Fin 4 × Fin 4) :=
  Finset.univ.filter (fun p => p.1 < p.2)

/-- The four-voice chorale cost: sum of pairwise costs over the six voice pairs,
    plus unary spacing penalties for each voice. -/
def choraleCost {n : ℕ} (pairCost : Melody' n → Melody' n → ℝ)
    (spacingPenalty : Fin 4 → Melody' n → ℝ) (C : Chorale n) : ℝ :=
  (∑ p ∈ voicePairs, pairCost (C p.1) (C p.2)) +
  ∑ i : Fin 4, spacingPenalty i (C i)

/-
There are exactly 6 voice pairs.
-/
theorem voicePairs_card : voicePairs.card = 6 := by
  native_decide +revert

/-- Every pair `(i,j)` with `i < j` is in `voicePairs`. -/
theorem mem_voicePairs {i j : Fin 4} (h : i < j) : (i, j) ∈ voicePairs := by
  simp [voicePairs, Finset.mem_filter]
  exact h

/-! ## Forward direction: local zeros imply global zero -/

/-
**Forward zero-cost theorem**: If every pairwise cost vanishes on each of the
    six voice pairs and every spacing penalty vanishes, the total chorale cost is zero.
-/
theorem choraleCost_eq_zero_of_pairwise_zero
    {n : ℕ} (pairCost : Melody' n → Melody' n → ℝ)
    (spacingPenalty : Fin 4 → Melody' n → ℝ) (C : Chorale n)
    (hpair_zero : ∀ p ∈ voicePairs, pairCost (C p.1) (C p.2) = 0)
    (hspace_zero : ∀ i : Fin 4, spacingPenalty i (C i) = 0) :
    choraleCost pairCost spacingPenalty C = 0 := by
  exact add_eq_zero_iff_eq_neg.mpr ( by rw [ Finset.sum_congr rfl hpair_zero, Finset.sum_const_zero, Finset.sum_congr rfl fun i hi => hspace_zero i, Finset.sum_const_zero, neg_zero ] )

/-! ## Converse rigidity: global zero implies every summand vanishes -/

/-
**Converse rigidity theorem**: If the total chorale cost is zero and every
    summand (pairwise cost and spacing penalty) is nonnegative, then each
    pairwise cost and each spacing penalty vanishes individually.

    This is the structural decomposition theorem: a global optimum certificate
    decomposes into six local pair certificates plus four unary certificates.
-/
theorem pairwise_zero_of_choraleCost_eq_zero
    {n : ℕ} (pairCost : Melody' n → Melody' n → ℝ)
    (spacingPenalty : Fin 4 → Melody' n → ℝ) (C : Chorale n)
    (hpair_nonneg : ∀ p ∈ voicePairs, 0 ≤ pairCost (C p.1) (C p.2))
    (hspace_nonneg : ∀ i : Fin 4, 0 ≤ spacingPenalty i (C i))
    (hzero : choraleCost pairCost spacingPenalty C = 0) :
    (∀ p ∈ voicePairs, pairCost (C p.1) (C p.2) = 0) ∧
    (∀ i : Fin 4, spacingPenalty i (C i) = 0) := by
  unfold choraleCost at hzero;
  exact ⟨ fun p hp => le_antisymm ( le_trans ( Finset.single_le_sum ( fun a _ => hpair_nonneg a ‹_› ) hp ) <| by linarith [ show 0 ≤ ∑ i : Fin 4, spacingPenalty i ( C i ) from Finset.sum_nonneg fun _ _ => hspace_nonneg _ ] ) ( hpair_nonneg p hp ), fun i => le_antisymm ( le_trans ( Finset.single_le_sum ( fun a _ => hspace_nonneg a ) <| Finset.mem_univ i ) <| by linarith [ show 0 ≤ ∑ p ∈ voicePairs, pairCost ( C p.1 ) ( C p.2 ) from Finset.sum_nonneg fun _ _ => hpair_nonneg _ ‹_› ] ) ( hspace_nonneg i ) ⟩

/-! ## Generalized nonnegative-sum rigidity -/

/-
**General nonneg-sum lemma**: If a finite sum of nonneg terms is zero,
    each term is zero. This is the key algebraic ingredient.
-/
theorem sum_eq_zero_of_nonneg_of_sum_eq_zero {ι : Type*} {s : Finset ι}
    {f : ι → ℝ} (hf : ∀ i ∈ s, 0 ≤ f i) (hsum : ∑ i ∈ s, f i = 0) :
    ∀ i ∈ s, f i = 0 := by
  exact fun i hi => le_antisymm ( hsum ▸ Finset.single_le_sum ( fun i _ => hf i ‹_› ) hi ) ( hf i hi )

/-
**Chorale cost is nonneg** when all summands are nonneg.
-/
theorem choraleCost_nonneg
    {n : ℕ} (pairCost : Melody' n → Melody' n → ℝ)
    (spacingPenalty : Fin 4 → Melody' n → ℝ) (C : Chorale n)
    (hpair_nonneg : ∀ p ∈ voicePairs, 0 ≤ pairCost (C p.1) (C p.2))
    (hspace_nonneg : ∀ i : Fin 4, 0 ≤ spacingPenalty i (C i)) :
    0 ≤ choraleCost pairCost spacingPenalty C := by
  exact add_nonneg ( Finset.sum_nonneg hpair_nonneg ) ( Finset.sum_nonneg fun _ _ => hspace_nonneg _ )

end