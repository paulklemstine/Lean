/-
# Proof-Search One-Way Functions: Cryptographic Extraction from Branching Invariants

This module formalizes a **combinatorial hardness surrogate** derived from
proof-search branching complexity in finite directed graphs.

## Main Results

1. `IsValidWalk_decidable`: Walk verification is decidable (efficient verification).
2. `walkCount_le_pow`: Walks from a source ≤ B^n (ambient candidate bound).
3. `obstructedWalkCount_le_pow`: Obstructed walks ≤ B^(n-k) * ρ^k.
4. `obstruction_mul_mono`: Monotonicity of obstruction bounds.
5. `density_decay_nat` / `density_decay_rat`: Exponential density decay.
6. `validWalk_sparsity_from_obstructions`: Main sparsity theorem.

## Cryptographic Interpretation

The pair (decidable verification, exponential sparsity) is the combinatorial
skeleton of one-way function security: membership in the valid-walk set is
efficiently checkable, while finding an element by uniform sampling succeeds
with probability at most (ρ/B)^k.
-/

import Mathlib

open Finset Fintype BigOperators

namespace ProofSearch

variable {V : Type*} [Fintype V] [DecidableEq V]

/-! ## Walk Definitions -/

/-- A walk of length `n` is a function from `Fin (n+1)` to `V`. -/
abbrev Walk (V : Type*) (n : ℕ) := Fin (n + 1) → V

/-- A walk is **valid** from `s` to `t` if it starts at `s`, ends at `t`,
    and each consecutive pair follows an edge. -/
def IsValidWalk (E : V → Finset V) (s t : V) (n : ℕ) (w : Walk V n) : Prop :=
  w 0 = s ∧ w (Fin.last n) = t ∧ ∀ i : Fin n, w i.succ ∈ E (w i.castSucc)

/-- Walk validity is decidable (efficient verification). -/
instance IsValidWalk_decidable (E : V → Finset V) (s t : V) (n : ℕ) :
    DecidablePred (IsValidWalk E s t n) := by
  intro w; unfold IsValidWalk; infer_instance

/-- A **walk from source** `s` starts at `s` and follows edges. -/
def IsWalkFrom (E : V → Finset V) (s : V) (n : ℕ) (w : Walk V n) : Prop :=
  w 0 = s ∧ ∀ i : Fin n, w i.succ ∈ E (w i.castSucc)

instance IsWalkFrom_decidable (E : V → Finset V) (s : V) (n : ℕ) :
    DecidablePred (IsWalkFrom E s n) := by
  intro w; unfold IsWalkFrom; infer_instance

omit [Fintype V] [DecidableEq V] in
lemma isValidWalk_imp_isWalkFrom (E : V → Finset V) (s t : V) (n : ℕ) (w : Walk V n) :
    IsValidWalk E s t n w → IsWalkFrom E s n w := by
  intro ⟨h1, _, h3⟩; exact ⟨h1, h3⟩

/-! ## Recursive Walk Counting -/

/-- Number of walks of length `n` from vertex `s`, counted recursively. -/
noncomputable def walkCount (E : V → Finset V) (s : V) : ℕ → ℕ
  | 0 => 1
  | n + 1 => ∑ v ∈ E s, walkCount E v n

/-
**Walk count bound**: walks from any source ≤ `B^n`.
-/
theorem walkCount_le_pow (E : V → Finset V) (s : V) (n B : ℕ)
    (hdeg : ∀ v, (E v).card ≤ B) :
    walkCount E s n ≤ B ^ n := by
  induction' n with n ih generalizing s;
  · exact?;
  · exact le_trans ( Finset.sum_le_sum fun _ _ => ih _ ) ( by simpa [ pow_succ' ] using mul_le_mul_of_nonneg_right ( hdeg s ) ( Nat.zero_le _ ) )

/-! ## Obstructed Walk Counting -/

/-- Recursive upper bound on walks from `s` of length `n` encountering ≥ `k`
    obstructed vertices (those with degree ≤ `ρ`). -/
noncomputable def obstructedWalkCount (E : V → Finset V) (ρ : ℕ) (s : V) :
    ℕ → ℕ → ℕ
  | n, 0 => walkCount E s n
  | 0, _ + 1 => 0
  | n + 1, k + 1 =>
    if (E s).card ≤ ρ then
      ∑ v ∈ E s, obstructedWalkCount E ρ v n k
    else
      ∑ v ∈ E s, obstructedWalkCount E ρ v n (k + 1)

/-
**Obstructed walk count bound**: ≤ `B^(n-k) * ρ^k`.
    Each obstruction replaces one factor of `B` with `ρ`.
-/
theorem obstructedWalkCount_le_pow (E : V → Finset V) (s : V) (n B ρ k : ℕ)
    (hdeg : ∀ v, (E v).card ≤ B) (hρB : ρ ≤ B) :
    obstructedWalkCount E ρ s n k ≤ B ^ (n - k) * ρ ^ k := by
  induction' n with n ih generalizing s k <;> induction' k with k ih' <;> simp_all +decide [ pow_succ, mul_assoc, mul_comm, mul_left_comm ];
  · exact?;
  · exact Nat.zero_le _;
  · convert walkCount_le_pow E s ( n + 1 ) B hdeg using 1;
    grind +splitIndPred;
  · by_cases h : ( E s ).card ≤ ρ <;> simp_all +decide [ obstructedWalkCount ];
    · exact le_trans ( Finset.sum_le_sum fun _ _ => ih _ _ ) ( by simpa [ mul_assoc, mul_comm, mul_left_comm ] using Nat.mul_le_mul_right ( ρ ^ k * B ^ ( n - k ) ) h );
    · have h_sum : ∑ v ∈ E s, obstructedWalkCount E ρ v n (k + 1) ≤ B * (ρ ^ (k + 1) * B ^ (n - (k + 1))) := by
        exact le_trans ( Finset.sum_le_sum fun _ _ => ih _ _ ) ( by simpa [ mul_assoc, mul_comm, mul_left_comm ] using Nat.mul_le_mul_right ( ρ ^ ( k + 1 ) * B ^ ( n - ( k + 1 ) ) ) ( hdeg s ) );
      by_cases h : n < k + 1 <;> simp_all +decide [ Nat.succ_sub, pow_succ', mul_assoc, mul_comm, mul_left_comm ];
      · rw [ if_neg ( by linarith ) ];
        refine' Finset.sum_eq_zero _ |> fun h => h.le.trans ( Nat.zero_le _ );
        intro v hv; specialize ih v ( k + 1 ) ; simp_all +decide [ Nat.sub_eq_zero_of_le ( by linarith : n ≤ k + 1 ) ] ;
        -- By definition of obstructedWalkCount, if n < k + 1, then obstructedWalkCount E ρ v n (k + 1) = 0.
        have h_obstructedWalkCount_zero : ∀ {n k : ℕ} {v : V}, n < k + 1 → obstructedWalkCount E ρ v n (k + 1) = 0 := by
          intros n k v hn; induction' n with n ih generalizing v k <;> induction' k with k ih' <;> simp_all +decide [ obstructedWalkCount ] ;
          grind +splitIndPred;
        exact h_obstructedWalkCount_zero ( Nat.lt_succ_of_le h );
      · rw [ show n - k = n - ( k + 1 ) + 1 by omega, pow_succ' ] ; split_ifs <;> nlinarith [ pow_nonneg ( Nat.zero_le ρ ) k, pow_nonneg ( Nat.zero_le B ) ( n - ( k + 1 ) ), mul_le_mul_left' hρB ( ρ ^ k * B ^ ( n - ( k + 1 ) ) ) ] ;

/-! ## Obstruction Monotonicity -/

/-
If `ρ ≤ B` and `k ≤ j ≤ n`, then `B^(n-j) * ρ^j ≤ B^(n-k) * ρ^k`.
-/
theorem obstruction_mul_mono (B ρ n k j : ℕ) (hρB : ρ ≤ B) (hkj : k ≤ j)
    (hjn : j ≤ n) :
    B ^ (n - j) * ρ ^ j ≤ B ^ (n - k) * ρ ^ k := by
  -- We can rewrite $B^{n-j} \rho^j$ as $B^{n-j} \rho^k \rho^{j-k}$.
  have h_rewrite : B ^ (n - j) * ρ ^ j = B ^ (n - j) * ρ ^ k * ρ ^ (j - k) := by
    rw [ mul_assoc, ← pow_add, Nat.add_sub_of_le hkj ];
  rw [ h_rewrite, show n - k = n - j + ( j - k ) by omega, pow_add ];
  simpa only [ mul_right_comm ] using Nat.mul_le_mul_right _ ( Nat.mul_le_mul_left _ ( Nat.pow_le_pow_left hρB _ ) )

/-! ## Walk Sets and Cardinality -/

/-- The Finset of valid walks from `s` to `t` of length `n`. -/
noncomputable def validWalkSet (E : V → Finset V) (s t : V) (n : ℕ) :
    Finset (Walk V n) :=
  Finset.univ.filter (IsValidWalk E s t n)

/-- The Finset of walks from source `s` of length `n`. -/
noncomputable def walkFromSet (E : V → Finset V) (s : V) (n : ℕ) :
    Finset (Walk V n) :=
  Finset.univ.filter (IsWalkFrom E s n)

/-
Valid walks ⊆ walks from source.
-/
lemma validWalkSet_subset_walkFromSet (E : V → Finset V) (s t : V) (n : ℕ) :
    validWalkSet E s t n ⊆ walkFromSet E s n := by
  exact fun w hw => Finset.mem_filter.mpr ⟨ Finset.mem_filter.mp hw |>.1, ( Finset.mem_filter.mp hw |>.2 ).1, fun i => ( Finset.mem_filter.mp hw |>.2 ).2.2 i ⟩

lemma validWalkSet_card_le (E : V → Finset V) (s t : V) (n : ℕ) :
    (validWalkSet E s t n).card ≤ (walkFromSet E s n).card :=
  Finset.card_le_card (validWalkSet_subset_walkFromSet E s t n)

/-! ## Density Decay -/

/-
**Density decay (ℕ form)**: `cardValid * B^k ≤ B^n * ρ^k`.
-/
theorem density_decay_nat (cardValid B ρ n k : ℕ) (hkn : k ≤ n)
    (hbound : cardValid ≤ B ^ (n - k) * ρ ^ k) :
    cardValid * B ^ k ≤ B ^ n * ρ ^ k := by
  exact le_trans ( Nat.mul_le_mul_right _ hbound ) ( by rw [ mul_right_comm, ← pow_add, Nat.sub_add_cancel hkn ] )

/-
**Density decay (ℚ form)**: `cardValid / B^n ≤ (ρ/B)^k`.
-/
theorem density_decay_rat (cardValid B ρ n k : ℕ)
    (_hρB : ρ ≤ B) (hBpos : 0 < B) (hkn : k ≤ n)
    (hbound : cardValid ≤ B ^ (n - k) * ρ ^ k) :
    (cardValid : ℚ) / (B : ℚ) ^ n ≤ ((ρ : ℚ) / (B : ℚ)) ^ k := by
  -- Convert to rationals and use the fact that division is preserve inequalities.
  have bound_rat : (cardValid : ℚ) ≤ B ^ (n - k) * ρ ^ k := by
    norm_cast
  have hdiv : (cardValid : ℚ) / B ^ n ≤ ρ ^ k / B ^ k := by
    convert div_le_div_of_nonneg_right bound_rat ( pow_nonneg ( Nat.cast_nonneg B ) n ) using 1 ; rw [ show ( B : ℚ ) ^ n = ( B : ℚ ) ^ ( n - k ) * ( B : ℚ ) ^ k by rw [ ← pow_add, Nat.sub_add_cancel hkn ] ] ; ring_nf ; norm_num [ hBpos.ne' ] ;
    exact eq_div_of_mul_eq ( by positivity ) ( by ring )
  have hdiv_simp : (cardValid : ℚ) / B ^ n ≤ (ρ / B) ^ k := by
    rwa [ div_pow ]
  exact hdiv_simp

/-! ## Obstruction Count -/

/-- Number of obstructed steps: steps where out-degree ≤ `ρ`. -/
noncomputable def obstructionCount (E : V → Finset V) (ρ : ℕ) {n : ℕ}
    (w : Walk V n) : ℕ :=
  (Finset.univ.filter (fun i : Fin n => (E (w i.castSucc)).card ≤ ρ)).card

omit [Fintype V] [DecidableEq V] in
lemma obstructionCount_le_length (E : V → Finset V) (ρ : ℕ) {n : ℕ}
    (w : Walk V n) : obstructionCount E ρ w ≤ n :=
  le_trans (Finset.card_filter_le _ _) (by simp)

/-! ## Main Sparsity Theorem -/

/-
**Exponential sparsity from obstructions.**
    If every valid walk encounters ≥ `k` obstructed vertices, and the set
    of walks-from-source with ≥ `k` obstructions is bounded by `B^(n-k)*ρ^k`,
    then valid walks are at most `B^(n-k)*ρ^k`.
-/
theorem validWalk_sparsity_from_obstructions
    (E : V → Finset V) (s t : V) (n B ρ k : ℕ)
    (_hρB : ρ ≤ B) (_hkn : k ≤ n)
    (hobs : ∀ w, IsValidWalk E s t n w → k ≤ obstructionCount E ρ w)
    (hobsBound : (Finset.univ.filter (fun w : Walk V n =>
        IsWalkFrom E s n w ∧ k ≤ obstructionCount E ρ w)).card
      ≤ B ^ (n - k) * ρ ^ k) :
    (validWalkSet E s t n).card ≤ B ^ (n - k) * ρ ^ k := by
  refine le_trans ?_ hobsBound;
  refine Finset.card_le_card ?_;
  grind +locals

/-! ## Proof Architecture -/

/-- A proof architecture: directed graph with source and target. -/
structure ProofArchitecture (V : Type*) [DecidableEq V] where
  next : V → Finset V
  source : V
  target : V

noncomputable def ProofArchitecture.branchBound
    {V : Type*} [Fintype V] [DecidableEq V] (A : ProofArchitecture V) : ℕ :=
  Finset.univ.sup (fun v => (A.next v).card)

lemma ProofArchitecture.deg_le_branchBound
    {V : Type*} [Fintype V] [DecidableEq V] (A : ProofArchitecture V) (v : V) :
    (A.next v).card ≤ A.branchBound :=
  Finset.le_sup (f := fun v => (A.next v).card) (Finset.mem_univ v)

end ProofSearch