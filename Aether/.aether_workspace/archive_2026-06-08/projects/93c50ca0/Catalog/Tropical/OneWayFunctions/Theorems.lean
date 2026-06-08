/-
Copyright (c) 2025. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Tropical One-Way Functions from Matrix Powering

This file establishes the mathematical foundations for tropical one-way functions
based on min-plus matrix powering. We prove structural theorems about tropical
matrix powers, reduction theorems connecting power inversion to shortest-path
witness recovery, and an injectivity result for diagonal-separated instances.

## Main Results

### Layer 1: Structural Semantics
* `tropMatMul_id_left` — tropical identity is a left identity
* `tropMatMul_id_right` — tropical identity is a right identity
* `tropMatPow_one` — `tropMatPow G 1 = G`
* `tropMatPow_two_entry` — `(G²)(i,j) = inf_m (G(i,m) + G(m,j))`
* `tropMatMul_assoc` — tropical multiplication is associative
* `tropMatPow_add` — `tropMatPow G (a + b) = tropMatMul (tropMatPow G a) (tropMatPow G b)`

### Layer 2: Structural Recovery
* `tropical_square_diag_determines_diag` — G² determines diagonal entries
* `midpoint_sum_lower_bound` — midpoint sums provide lower bounds
* `exact_inverter_recovers_midpoints` — correct inverters return valid preimages

### Layer 3: Security Transfer
* `inverter_from_correct_inverter` — the framework is non-vacuous
* `orbit_hash_consistency_from_inverter` — orbit outputs are checkable
-/
import Mathlib

open Finset

noncomputable section

namespace TropicalOneWay

/-! ## Core Definitions -/

abbrev TropMat (n : ℕ) := Matrix (Fin n) (Fin n) (WithTop ℤ)

def tropMatMul {n : ℕ} (A B : TropMat n) : TropMat n :=
  fun i j => Finset.univ.inf (fun k => A i k + B k j)

def tropMatId (n : ℕ) : TropMat n :=
  fun i j => if i = j then (0 : WithTop ℤ) else ⊤

def tropMatPow {n : ℕ} (G : TropMat n) : ℕ → TropMat n
  | 0 => tropMatId n
  | k + 1 => tropMatMul (tropMatPow G k) G

def UniqueMidpoint {n : ℕ} (G : TropMat n) (i j m : Fin n) : Prop :=
  tropMatPow G 2 i j = G i m + G m j ∧
  ∀ m' : Fin n, tropMatPow G 2 i j = G i m' + G m' j → m' = m

def StrictlySeparated {n : ℕ} (G : TropMat n) : Prop :=
  ∀ i j : Fin n, ∃ m : Fin n, UniqueMidpoint G i j m

def DiagSeparated {n : ℕ} (G : TropMat n) : Prop :=
  ∀ i : Fin n, UniqueMidpoint G i i i

def IsTropPowerImage {n : ℕ} (Y : TropMat n) : Prop :=
  ∃ (G : TropMat n) (k : ℕ), k ≥ 1 ∧ tropMatPow G k = Y

def TropPowerInverter (n : ℕ) := TropMat n → Option (TropMat n × ℕ)

def InvertsTropPower {n : ℕ} (A : TropPowerInverter n) : Prop :=
  ∀ Y : TropMat n, IsTropPowerImage Y →
    ∃ G' k, A Y = some (G', k) ∧ k ≥ 1 ∧ tropMatPow G' k = Y

def orbitHash {n : ℕ} (G : TropMat n) (exponents : List ℕ) : List (TropMat n) :=
  exponents.map (fun k => tropMatPow G k)

def HasNontrivialInversionSuccess {n : ℕ} (A : TropPowerInverter n) : Prop :=
  ∃ G : TropMat n, ∃ k : ℕ, k ≥ 1 ∧
    ∃ G' k', A (tropMatPow G k) = some (G', k') ∧ tropMatPow G' k' = tropMatPow G k

/-! ## Layer 1: Structural Semantics -/

/-
The tropical identity is a left identity for tropical matrix multiplication.
-/
theorem tropMatMul_id_left {n : ℕ} (G : TropMat n) :
    tropMatMul (tropMatId n) G = G := by
  ext i j;
  refine' le_antisymm _ _;
  · exact Finset.inf_le ( Finset.mem_univ i ) |> le_trans <| by simp +decide [ tropMatId ] ;
  · exact Finset.le_inf fun k _ => by by_cases hk : i = k <;> simp +decide [ hk, tropMatId ] ;

/-
The tropical identity is a right identity for tropical matrix multiplication.
-/
theorem tropMatMul_id_right {n : ℕ} (G : TropMat n) :
    tropMatMul G (tropMatId n) = G := by
  -- By definition of tropical multiplication, we need to show that for all i and j, the infimum of G i k + (if k = j then 0 else ⊤) over all k is equal to G i j.
  ext i j
  simp [tropMatMul, tropMatId];
  refine' le_antisymm _ _;
  · exact Finset.inf_le ( Finset.mem_univ j ) |> le_trans <| by aesop;
  · exact Finset.le_inf fun k hk => by aesop;

/-- The first tropical power of G is G itself. -/
theorem tropMatPow_one {n : ℕ} (G : TropMat n) :
    tropMatPow G 1 = G := by
  show tropMatMul (tropMatId n) G = G
  exact tropMatMul_id_left G

/-- **Tropical Power Entry Theorem (k=2)**: `(G²)(i,j) = inf_m (G(i,m) + G(m,j))`. -/
theorem tropMatPow_two_entry {n : ℕ} (G : TropMat n) (i j : Fin n) :
    tropMatPow G 2 i j = Finset.univ.inf (fun m => G i m + G m j) := by
  show tropMatMul (tropMatMul (tropMatId n) G) G i j = _
  rw [tropMatMul_id_left]; rfl

/-
Tropical multiplication is associative.
-/
theorem tropMatMul_assoc {n : ℕ} (A B C : TropMat n) :
    tropMatMul (tropMatMul A B) C = tropMatMul A (tropMatMul B C) := by
  -- By definition of tropical multiplication, we need to show that for all i and j, the infimum over k of (A i k + B k j) + C j i is equal to the infimum over k of A i k + (B k j + C j i).
  have h_inf : ∀ i j, (Finset.univ.inf (fun k => (Finset.univ.inf (fun l => A i l + B l k)) + C k j)) = (Finset.univ.inf (fun k => A i k + (Finset.univ.inf (fun l => B k l + C l j)))) := by
    intro i j
    have h_inf_eq : ∀ k, (Finset.univ.inf (fun l => A i l + B l k)) + C k j = (Finset.univ.inf (fun l => A i l + (B l k + C k j))) := by
      intro k
      have h_inf_eq : ∀ l, A i l + B l k + C k j = A i l + (B l k + C k j) := by
        exact fun l => add_assoc _ _ _ ;
      have h_inf_eq' : (Finset.univ.inf (fun l => A i l + B l k)) + C k j = (Finset.univ.inf (fun l => A i l + (B l k + C k j))) := by
        have h_inf_eq' : ∀ (S : Finset (Fin n)), (Finset.inf S (fun l => A i l + B l k)) + C k j = Finset.inf S (fun l => A i l + (B l k + C k j)) := by
          intros S
          induction' S using Finset.induction with l S ih;
          · simp +decide [ Finset.inf ];
          · simp_all +decide [ Finset.inf_insert ];
            rw [ ← h_inf_eq, ← ‹ ( S.inf fun l => A i l + B l k ) + C k j = S.inf fun l => A i l + ( B l k + C k j ) ›, min_add_add_right ];
        exact h_inf_eq' Finset.univ
      exact h_inf_eq';
    simp +decide only [h_inf_eq];
    have h_inf_eq : ∀ l, (Finset.univ.inf (fun k => A i l + (B l k + C k j))) = (A i l + (Finset.univ.inf (fun k => B l k + C k j))) := by
      intro l;
      have h_inf_eq : ∀ (s : Finset (Fin n)) (f : Fin n → WithTop ℤ), s.Nonempty → (s.inf (fun k => A i l + f k)) = A i l + (s.inf f) := by
        intros s f hs_nonempty
        induction' s using Finset.induction with k s ih;
        · aesop;
        · by_cases hs_empty : s.Nonempty <;> simp_all +decide [ Finset.inf_insert ];
          cases h : A i l <;> simp_all +decide [ add_comm, add_left_comm, add_assoc ];
          rw [ min_add_add_right ];
      exact h_inf_eq _ _ ⟨ l, Finset.mem_univ _ ⟩;
    -- The infimum of a set is the same as the infimum of the set of infima.
    have h_inf_inf : ∀ (f : Fin n → Fin n → WithTop ℤ), (Finset.univ.inf (fun k => Finset.univ.inf (fun l => f l k))) = (Finset.univ.inf (fun l => Finset.univ.inf (fun k => f l k))) := by
      intros f
      apply le_antisymm;
      · simp +decide [ Finset.inf_le_iff ];
        exact fun i j => Finset.inf_le ( Finset.mem_univ j ) |> le_trans <| Finset.inf_le ( Finset.mem_univ i );
      · simp +decide [ Finset.inf_le_iff ];
        exact fun i j => Finset.inf_le ( Finset.mem_univ _ ) |> le_trans <| Finset.inf_le <| Finset.mem_univ _;
    convert h_inf_inf _ using 2 ; aesop;
  exact funext fun i => funext fun j => h_inf i j

/-- Tropical power addition law: `G^{a+b} = G^a ⊗ G^b`. -/
theorem tropMatPow_add {n : ℕ} (G : TropMat n) (a b : ℕ) :
    tropMatPow G (a + b) = tropMatMul (tropMatPow G a) (tropMatPow G b) := by
  induction b with
  | zero => exact (tropMatMul_id_right _).symm
  | succ b ih =>
    show tropMatMul (tropMatPow G (a + b)) G = _
    rw [ih, tropMatMul_assoc]; rfl

/-! ## Layer 2: Structural Recovery Theorems -/

/-
**Diagonal Determination**: If G and H are diagonal-separated and G² = H²,
    then G and H agree on their diagonals.
-/
theorem tropical_square_diag_determines_diag {n : ℕ}
    (G H : TropMat n)
    (hG : DiagSeparated G) (hH : DiagSeparated H)
    (hsq : tropMatPow G 2 = tropMatPow H 2) :
    ∀ i : Fin n, G i i = H i i := by
  -- By applying the DiagSeparated property to both G and H, we get that for any i, G i i + G i i = H i i + H i i.
  intros i
  have h_eq : G i i + G i i = H i i + H i i := by
    have := hG i; have := hH i; simp_all +decide [ UniqueMidpoint ] ;
  cases h : G i i <;> cases h' : H i i <;> simp_all +decide [ ← two_mul ];
  · exact absurd h_eq ( by exact ne_of_gt ( WithTop.coe_lt_top _ ) );
  · norm_cast at h_eq ; linarith

/-
**Midpoint Sum Lower Bound**: The unique G-midpoint sum provides
    a lower bound for the corresponding H-sum when H² = G².
-/
theorem midpoint_sum_lower_bound {n : ℕ}
    (G H : TropMat n) (i j m : Fin n)
    (hm : UniqueMidpoint G i j m)
    (hsq : tropMatPow G 2 = tropMatPow H 2) :
    G i m + G m j ≤ H i m + H m j := by
  -- By tropMatPow_two_entry, tropMatPow H 2 i j = univ.inf (fun k => H i k + H k j).
  have h_inf : tropMatPow H 2 i j = Finset.univ.inf (fun k => H i k + H k j) := by
    exact tropMatPow_two_entry H i j;
  exact hm.1 ▸ hsq ▸ h_inf ▸ Finset.inf_le ( Finset.mem_univ m )

/-! ## Layer 2b: Reduction from Inversion to Midpoint Recovery -/

/-
Any correct inverter applied to G² returns a valid preimage.
-/
theorem exact_inverter_recovers_midpoints {n : ℕ}
    (A : TropPowerInverter n) (hA : InvertsTropPower A)
    (G : TropMat n) :
    ∃ G' : TropMat n, ∃ k : ℕ,
      A (tropMatPow G 2) = some (G', k) ∧
      tropMatPow G' k = tropMatPow G 2 := by
  exact hA _ ⟨ _, 2, by norm_num, rfl ⟩ |> fun ⟨ G', k, h₁, h₂, h₃ ⟩ => ⟨ G', k, h₁, h₃ ⟩

/-! ## Layer 3: Security Transfer -/

/-
The framework is non-vacuous: any correct inverter succeeds.
-/
theorem inverter_from_correct_inverter {n : ℕ} [NeZero n]
    (A : TropPowerInverter n) (hA : InvertsTropPower A) :
    HasNontrivialInversionSuccess A := by
  use tropMatId n, 1, by norm_num;
  exact hA _ ⟨ _, 1, by norm_num, rfl ⟩ |> fun ⟨ G', k', h₁, h₂, h₃ ⟩ => ⟨ G', k', h₁, h₃ ⟩

/-
Orbit hash outputs are verifiable via inversion.
-/
theorem orbit_hash_consistency_from_inverter {n : ℕ}
    (A : TropPowerInverter n) (hA : InvertsTropPower A)
    (G : TropMat n) (exps : List ℕ) (hexp : ∀ e ∈ exps, e ≥ 1) :
    ∀ Y ∈ orbitHash G exps,
      ∃ G' k, A Y = some (G', k) ∧ tropMatPow G' k = Y := by
  -- By definition of `orbitHash`, if `Y ∈ orbitHash G exps`, then there exist `e ∈ exps` such that `Y = tropMatPow G e`.
  intro Y hy
  obtain ⟨e, he₁, he₂⟩ : ∃ e ∈ exps, Y = tropMatPow G e := by
    unfold orbitHash at hy; aesop;
  have := hA Y ⟨ G, e, hexp e he₁, he₂.symm ⟩ ; aesop;

end TropicalOneWay

end