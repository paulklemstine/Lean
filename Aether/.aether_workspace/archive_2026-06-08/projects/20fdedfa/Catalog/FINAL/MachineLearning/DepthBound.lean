/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Depth Lower Bounds from Entropy Contraction

This file establishes that layered monotone computation with bounded per-layer
entropy drop leads to depth lower bounds via telescoping.

## Main results

- `card_biUnion_le_mul_sup`: `|⋃ᵢ Aᵢ| ≤ k · maxᵢ |Aᵢ|` (combinatorial core of fan-in bound).
- `logb_biUnion_le_sup_add_logb`: the logarithmic version for fan-in `k` OR gates.
- `depth_lower_bound_layered`: if each layer drops entropy by at most `B`,
  then total entropy drop is at most `d * B`.
- `entropyDrop_le_hammingDist_mul_maxStep`: entropy drop bounded by Hamming distance
  times maximum single-step drop (order-theoretic bridge theorem).
-/

import Mathlib
import Speculative.MonotoneEntropy.Defs

open Finset Real

noncomputable section

/-! ## Theorem 2: Fan-in bound on cardinality (combinatorial core) -/

/-
The cardinality of a union of `k` finite sets is at most `k` times the
maximum cardinality among them. This is the combinatorial engine behind
the fan-in entropy bound.
-/
theorem card_biUnion_le_mul_sup {α : Type*} [DecidableEq α] {k : ℕ} (hk : 0 < k)
    (s : Fin k → Finset α) :
    (Finset.univ.biUnion s).card ≤
      k * (Finset.univ.sup' (by exact univ_nonempty_iff.mpr ⟨⟨0, hk⟩⟩) (fun i => (s i).card)) := by
  -- Apply the fact that the cardinality of a union of sets is at most the sum of the cardinalities of the sets.
  have h_card_biUnion_le : (Finset.card (Finset.biUnion Finset.univ s)) ≤ Finset.sum Finset.univ (fun i => Finset.card (s i)) := by
    exact Finset.card_biUnion_le;
  exact h_card_biUnion_le.trans ( le_trans ( Finset.sum_le_card_nsmul _ _ _ fun i _ => show # ( s i ) ≤ Finset.univ.sup' ( Finset.univ_nonempty_iff.mpr ⟨ ⟨ 0, hk ⟩ ⟩ ) fun i => # ( s i ) from Finset.le_sup' ( fun i => # ( s i ) ) ( Finset.mem_univ i ) ) ( by simp +decide [ mul_comm ] ) )

/-
**Logarithmic fan-in bound** (Theorem 2, set-theoretic version):
`log₂ |⋃ᵢ Aᵢ| ≤ maxᵢ log₂ |Aᵢ| + log₂ k`.

This captures the key insight: a `k`-ary OR gate can increase the logarithmic
mass of a set system by at most `log₂ k`.
-/
theorem logb_biUnion_le_sup_add_logb {α : Type*} [DecidableEq α] {k : ℕ}
    (hk : 0 < k) (s : Fin k → Finset α) :
    Real.logb 2 ((Finset.univ.biUnion s).card : ℝ) ≤
      (Finset.univ.sup' (by exact univ_nonempty_iff.mpr ⟨⟨0, hk⟩⟩) (fun i => Real.logb 2 ((s i).card : ℝ))) +
      Real.logb 2 (k : ℝ) := by
  by_cases h : ( Finset.univ.biUnion s ).card = 0;
  · simp_all +decide [ Finset.ext_iff ];
    simp_all +decide [ Finset.eq_empty_of_forall_notMem fun a ha => h a _ <| Finset.mem_biUnion.mp ha |> Classical.choose_spec |> And.right ];
    exact add_nonneg ( Finset.le_sup'_of_le _ ( Finset.mem_univ ⟨ 0, hk ⟩ ) ( by simp +decide [ show s ⟨ 0, hk ⟩ = ∅ from Finset.eq_empty_of_forall_notMem fun a ha => h a ⟨ 0, hk ⟩ ha ] ) ) ( Real.logb_nonneg ( by norm_num ) ( by norm_cast ) );
  · have h_card_biUnion_le_mul_sup : (Finset.univ.biUnion s).card ≤ k * (Finset.univ.sup' (by exact univ_nonempty_iff.mpr ⟨⟨0, hk⟩⟩) (fun i => (s i).card)) := by
      exact?;
    have h_log_card_biUnion_le_log_mul_sup : Real.logb 2 (Finset.univ.biUnion s).card ≤ Real.logb 2 k + Real.logb 2 (Finset.univ.sup' (by exact univ_nonempty_iff.mpr ⟨⟨0, hk⟩⟩) (fun i => (s i).card)) := by
      rw [ ← Real.logb_mul ] <;> norm_cast;
      · gcongr ; norm_cast;
      · grind +qlia;
      · grind;
    refine' le_trans h_log_card_biUnion_le_log_mul_sup _;
    rw [ add_comm ];
    rcases ( Finset.exists_max_image Finset.univ ( fun i => ( s i |> Finset.card : ℝ ) ) ⟨ ⟨ 0, hk ⟩, Finset.mem_univ _ ⟩ ) with ⟨ i, hi, hi' ⟩ ; simp_all +decide [ Finset.sup'_eq_sup ];
    exact ⟨ i, by rw [ show ( Finset.univ.sup' ( by exact ⟨ i, Finset.mem_univ i ⟩ ) fun i => ( # ( s i ) : ℝ ) ) = ( # ( s i ) : ℝ ) from le_antisymm ( Finset.sup'_le _ _ fun x _ => Nat.cast_le.mpr ( hi' x ) ) ( Finset.le_sup' ( fun i => ( # ( s i ) : ℝ ) ) ( Finset.mem_univ i ) ) ] ⟩

/-! ## Layered Monotone System -/

/-- A `LayeredMonotoneSystem` models a depth-`d` layered monotone computation.
At each layer, the system transforms a monotone Boolean function, and we
track the semantic entropy at each layer. The key constraint is that each
layer drops entropy by at most `B`.

This is an abstract model: we don't specify gates explicitly but rather
track the sequence of monotone functions computed at each layer. -/
structure LayeredMonotoneSystem (n : ℕ) (d : ℕ) where
  /-- The monotone function computed at each layer (layer 0 is input, layer d is output). -/
  layer : Fin (d + 1) → ((Fin n → Bool) → Bool)
  /-- Each layer function is monotone. -/
  layer_mono : ∀ i, Monotone (layer i)

/-- The output function of a layered system is the function at the final layer. -/
def LayeredMonotoneSystem.output {n d : ℕ} (C : LayeredMonotoneSystem n d) :
    (Fin n → Bool) → Bool :=
  C.layer (Fin.last d)

/-! ## Theorem 3: Depth lower bound from telescoping -/

/-
**Depth lower bound from layerwise entropy contraction** (Theorem 3):
If each layer of a monotone computation drops entropy by at most `B`,
then the total entropy drop from the first to the last layer is at most `d * B`.

This is proved by telescoping: the total drop is a sum of per-layer drops,
each bounded by `B`.
-/
theorem depth_lower_bound_layered {n d : ℕ} {B : ℝ}
    (C : LayeredMonotoneSystem n d)
    (hB : 0 ≤ B)
    (hstep : ∀ (i : Fin d) (x y : Fin n → Bool), x ≤ y →
      entropyDrop (C.layer i.succ) x y ≤ entropyDrop (C.layer i.castSucc) x y + B)
    {x y : Fin n → Bool} (hxy : x ≤ y) :
    entropyDrop (C.layer (Fin.last d)) x y ≤ entropyDrop (C.layer 0) x y + d * B := by
  induction' d with d ih;
  · norm_num;
  · convert le_trans _ ( add_le_add_right ( ih _ _ ) B ) using 1;
    rotate_left;
    rotate_left;
    exact ⟨ fun i => C.layer i.castSucc, fun i => C.layer_mono i.castSucc ⟩;
    · grind +splitImp;
    · push_cast; ring!;
    · convert hstep ( Fin.last d ) x y hxy using 1 ; ring!

/-
**Corollary**: If the initial layer has zero entropy drop (e.g., the identity),
then the output entropy drop is at most `d * B`.
-/
theorem depth_lower_bound_simple {n d : ℕ} {B : ℝ}
    (C : LayeredMonotoneSystem n d)
    (hB : 0 ≤ B)
    (hinput : ∀ x y, entropyDrop (C.layer 0) x y = 0)
    (hstep : ∀ (i : Fin d) (x y : Fin n → Bool), x ≤ y →
      entropyDrop (C.layer i.succ) x y ≤ entropyDrop (C.layer i.castSucc) x y + B)
    {x y : Fin n → Bool} (hxy : x ≤ y) :
    entropyDrop (C.output) x y ≤ d * B := by
  convert depth_lower_bound_layered C hB hstep hxy using 1 ; aesop

/-! ## Theorem 4: Order-theoretic bridge -/

/-- The maximum single-step (cover) entropy drop for a monotone function `f`.
This is the supremum of `entropyDrop f u v` over all pairs `u ≤ v` that
differ in exactly one coordinate (covers in the Boolean lattice). -/
def maxCoverEntropyDrop {n : ℕ} (f : (Fin n → Bool) → Bool) : ℝ :=
  Finset.univ.sup'
    ⟨(fun _ => false, fun _ => false), Finset.mem_univ _⟩
    (fun p : (Fin n → Bool) × (Fin n → Bool) =>
      if (hammingDist p.1 p.2 = 1 ∧ p.1 ≤ p.2) then entropyDrop f p.1 p.2 else 0)

/-
**Entropy drop bounded by Hamming distance** (Theorem 4, Order-theoretic bridge):
For monotone `f` and `x ≤ y`, the entropy drop from `x` to `y` is bounded by
the Hamming distance times the maximum single-step entropy drop.

This turns semantic entropy into a path metric / potential function on the
Boolean lattice, connecting to discrete geometry and communication complexity.
-/
theorem entropyDrop_le_hammingDist_mul_maxStep {n : ℕ}
    {f : (Fin n → Bool) → Bool} (hf : Monotone f)
    {x y : Fin n → Bool} (hxy : x ≤ y) :
    entropyDrop f x y ≤ hammingDist x y * maxCoverEntropyDrop f := by
  have h_telescope : ∀ (x y : Fin n → Bool), x ≤ y → entropyDrop f x y ≤ (hammingDist x y : ℝ) * maxCoverEntropyDrop f := by
    intros x y hxy
    have h_path : ∀ (z : Fin n → Bool), z ∈ Finset.univ → ∀ (i : Fin n), z i = false → entropyDrop f z (Function.update z i true) ≤ maxCoverEntropyDrop f := by
      intros z hz i hi
      have h_cover : hammingDist z (Function.update z i true) = 1 ∧ z ≤ Function.update z i true := by
        simp +decide [ hammingDist, hi, Function.update_apply ];
        exact Finset.card_eq_one.mpr ⟨ i, by aesop ⟩;
      exact Finset.le_sup' ( fun p : ( Fin n → Bool ) × ( Fin n → Bool ) => if hammingDist p.1 p.2 = 1 ∧ p.1 ≤ p.2 then entropyDrop f p.1 p.2 else 0 ) ( Finset.mem_univ ( z, Function.update z i true ) ) |> le_trans ( by aesop );
    -- By induction on the Hamming distance, we can show that the entropy drop along any path from x to y is at most the Hamming distance times the maximum cover entropy drop.
    have h_induction : ∀ (x y : Fin n → Bool), x ≤ y → ∀ (S : Finset (Fin n)), (∀ i ∈ S, x i = false ∧ y i = true) → entropyDrop f x (fun i => if i ∈ S then y i else x i) ≤ S.card * maxCoverEntropyDrop f := by
      intros x y hxy S hS;
      induction' S using Finset.induction with i S hiS ih;
      · unfold entropyDrop; aesop;
      · have h_step : entropyDrop f (fun j => if j ∈ S then y j else x j) (fun j => if j ∈ insert i S then y j else x j) ≤ maxCoverEntropyDrop f := by
          convert h_path ( fun j => if j ∈ S then y j else x j ) ( Finset.mem_univ _ ) i _ using 1;
          · congr! 2;
            grind;
          · grind;
        have h_step : entropyDrop f x (fun j => if j ∈ insert i S then y j else x j) ≤ entropyDrop f x (fun j => if j ∈ S then y j else x j) + entropyDrop f (fun j => if j ∈ S then y j else x j) (fun j => if j ∈ insert i S then y j else x j) := by
          unfold entropyDrop; ring_nf; norm_num;
        rw [ Finset.card_insert_of_notMem hiS ] ; push_cast ; linarith [ ih fun j hj => hS j ( Finset.mem_insert_of_mem hj ) ];
    convert h_induction x y hxy ( Finset.univ.filter fun i => x i ≠ y i ) _ using 1 <;> simp +decide [ hammingDist ];
    · congr ; ext i ; by_cases hi : x i = y i <;> simp +decide [ hi ];
    · intro i hi; specialize hxy i; cases h : x i <;> cases h' : y i <;> simp_all +decide ;
  exact h_telescope x y hxy

end