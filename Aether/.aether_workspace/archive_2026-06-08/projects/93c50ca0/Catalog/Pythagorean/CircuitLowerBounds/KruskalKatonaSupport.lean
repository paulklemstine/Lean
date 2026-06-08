/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license.
-/
import Mathlib

/-!
# Kruskal–Katona Optimal Shadow Bounds for Circuit Supports

This file develops a new framework connecting **extremal combinatorics** (Kruskal–Katona
shadow theory) to **algebraic circuit complexity** via the combinatorial geometry of
polynomial supports.

## Main Definitions

* `oneShadow` — The one-step downward shadow of a finset of exponent vectors.
* `supportMul` — Minkowski sum of two finite exponent-vector families.
* `kkMinShadow` — The Kruskal–Katona minimum one-shadow cardinality.
* `shadowGap` — The excess of actual shadow size over the KK minimum.
* `SupportCircuit` — An inductive type modeling monotone algebraic circuits.
* `SquarefreeFamily` — Predicate for squarefree homogeneous support families.

## Main Results

* `oneShadow_union_subset` — Shadow of union ⊆ union of shadows.
* `card_oneShadow_union_le` — Subadditivity: `|Sh(A ∪ B)| ≤ |Sh(A)| + |Sh(B)|`.
* `map_add_mem_oneShadow_supportMul` — Shifted shadow inclusion under Minkowski sum.
* `card_oneShadow_le_card_oneShadow_supportMul` — Monotonicity under Minkowski product.
* `card_oneShadow_singleton_le` — Shadow of singleton has ≤ n elements.
* `shadow_bound_of_supportCircuit` — Recursive shadow bound for circuits.
-/

open Finset BigOperators Function

namespace KruskalKatonaSupport

variable {n : ℕ}

/-! ## Total Degree -/

/-- Total degree of a multi-index `m : Fin n → ℕ`. -/
def totalDeg (m : Fin n → ℕ) : ℕ := ∑ i, m i

/-! ## One-Step Shadow -/

/-- The **one-step shadow** of a finite set `S` of exponent vectors.
An exponent vector `β` lies in `oneShadow S` iff it can be obtained from some
`α ∈ S` by decrementing exactly one positive coordinate by 1.

This is the support-level analogue of taking all first partial derivatives. -/
def oneShadow (S : Finset (Fin n → ℕ)) : Finset (Fin n → ℕ) :=
  S.biUnion (fun α =>
    Finset.univ.biUnion (fun i : Fin n =>
      if 0 < α i then {Function.update α i (α i - 1)} else ∅))

/-- Membership characterization for `oneShadow`. -/
theorem mem_oneShadow_iff {S : Finset (Fin n → ℕ)} {β : Fin n → ℕ} :
    β ∈ oneShadow S ↔
      ∃ α ∈ S, ∃ i : Fin n, 0 < α i ∧ β = Function.update α i (α i - 1) := by
  simp only [oneShadow, Finset.mem_biUnion, Finset.mem_univ, true_and]
  constructor
  · rintro ⟨α, hα, i, hi⟩
    refine ⟨α, hα, i, ?_⟩
    split_ifs at hi with h
    · simp at hi; exact ⟨h, hi⟩
    · simp at hi
  · rintro ⟨α, hα, i, hpos, rfl⟩
    refine ⟨α, hα, i, ?_⟩
    simp [hpos]

/-- Shadow is monotone in the support set. -/
theorem oneShadow_mono {S₁ S₂ : Finset (Fin n → ℕ)} (h : S₁ ⊆ S₂) :
    oneShadow S₁ ⊆ oneShadow S₂ := by
  intro β hβ
  rw [mem_oneShadow_iff] at hβ ⊢
  obtain ⟨α, hα, i, hpos, rfl⟩ := hβ
  exact ⟨α, h hα, i, hpos, rfl⟩

/-- The shadow of the empty set is empty. -/
@[simp]
theorem oneShadow_empty : oneShadow (∅ : Finset (Fin n → ℕ)) = ∅ := by
  simp [oneShadow]

/-! ## Shadow Subadditivity Under Union (Theorem 2) -/

/-- The shadow of a union is contained in the union of shadows. -/
theorem oneShadow_union_subset (A B : Finset (Fin n → ℕ)) :
    oneShadow (A ∪ B) ⊆ oneShadow A ∪ oneShadow B := by
  intro β hβ
  rw [mem_oneShadow_iff] at hβ
  obtain ⟨α, hα, i, hpos, rfl⟩ := hβ
  rw [Finset.mem_union] at hα ⊢
  cases hα with
  | inl h => left; rw [mem_oneShadow_iff]; exact ⟨α, h, i, hpos, rfl⟩
  | inr h => right; rw [mem_oneShadow_iff]; exact ⟨α, h, i, hpos, rfl⟩

/-- **Shadow subadditivity under support union.**
`|Sh₁(A ∪ B)| ≤ |Sh₁(A)| + |Sh₁(B)|`. -/
theorem card_oneShadow_union_le (A B : Finset (Fin n → ℕ)) :
    (oneShadow (A ∪ B)).card ≤ (oneShadow A).card + (oneShadow B).card :=
  le_trans
    (Finset.card_le_card (oneShadow_union_subset A B))
    (Finset.card_union_le _ _)

/-! ## Minkowski Product of Supports -/

/-- **Support multiplication** (Minkowski sum of exponent vectors).
Models the support of `f * g` in the absence of cancellation. -/
def supportMul (A B : Finset (Fin n → ℕ)) : Finset (Fin n → ℕ) :=
  (A ×ˢ B).image (fun p => p.1 + p.2)

theorem mem_supportMul_iff {A B : Finset (Fin n → ℕ)} {γ : Fin n → ℕ} :
    γ ∈ supportMul A B ↔ ∃ a ∈ A, ∃ b ∈ B, γ = a + b := by
  simp only [supportMul, Finset.mem_image, Finset.mem_product, Prod.exists]
  constructor
  · rintro ⟨a, b, ⟨ha, hb⟩, rfl⟩; exact ⟨a, ha, b, hb, rfl⟩
  · rintro ⟨a, ha, b, hb, rfl⟩; exact ⟨a, b, ⟨ha, hb⟩, rfl⟩

/-! ## Shadow of Minkowski Product (Theorem 3) -/

/-- Key identity: decrementing coordinate `i` commutes with adding `b`. -/
theorem update_add_eq_add_update (a b : Fin n → ℕ) (i : Fin n) (h : 0 < a i) :
    Function.update a i (a i - 1) + b =
    Function.update (a + b) i ((a + b) i - 1) := by
  ext j
  simp only [Pi.add_apply]
  by_cases hj : j = i
  · subst hj; simp [Function.update_self]; omega
  · simp [Function.update_of_ne hj]

/-- **Shadow of Minkowski product contains shifted factors (strong form).**
If `α ∈ oneShadow A` and `b ∈ B`, then `α + b ∈ oneShadow (supportMul A B)`. -/
theorem map_add_mem_oneShadow_supportMul
    (A B : Finset (Fin n → ℕ))
    ⦃α : Fin n → ℕ⦄ ⦃b : Fin n → ℕ⦄
    (hα : α ∈ oneShadow A) (hb : b ∈ B) :
    α + b ∈ oneShadow (supportMul A B) := by
  rw [mem_oneShadow_iff] at hα ⊢
  obtain ⟨a, ha, i, hpos, rfl⟩ := hα
  refine ⟨a + b, ?_, i, ?_, ?_⟩
  · rw [mem_supportMul_iff]; exact ⟨a, ha, b, hb, rfl⟩
  · simp [Pi.add_apply]; omega
  · exact update_add_eq_add_update a b i hpos

/-- When `0 ∈ B`, the shadow of `A` embeds into the shadow of `supportMul A B`. -/
theorem add_mem_oneShadow_supportMul
    (A B : Finset (Fin n → ℕ))
    (h0 : (0 : Fin n → ℕ) ∈ B) :
    ∀ ⦃α⦄, α ∈ oneShadow A → α ∈ oneShadow (supportMul A B) := by
  intro α hα
  have : α + 0 = α := by ext; simp
  rw [← this]
  exact map_add_mem_oneShadow_supportMul A B hα h0

/-- **Shadow monotonicity under Minkowski product.**
If `0 ∈ B`, then `|Sh₁(A)| ≤ |Sh₁(A ⊞ B)|`. -/
theorem card_oneShadow_le_card_oneShadow_supportMul
    (A B : Finset (Fin n → ℕ))
    (h0 : (0 : Fin n → ℕ) ∈ B) :
    (oneShadow A).card ≤ (oneShadow (supportMul A B)).card := by
  exact Finset.card_le_card (fun α hα => add_mem_oneShadow_supportMul A B h0 hα)

/-! ## Kruskal–Katona Minimum Shadow -/

/-- The **Kruskal–Katona minimum one-shadow cardinality** among all degree-`d`
multi-index families of cardinality `m` in `n` variables. -/
noncomputable def kkMinShadow (nn d m : ℕ) : ℕ :=
  iInf (fun (S : { S : Finset (Fin nn → ℕ) //
    S.card = m ∧ ∀ α ∈ S, totalDeg α = d }) =>
    (oneShadow S.val).card)

/-
Any qualifying family achieves at least `kkMinShadow`.
-/
theorem kkMinShadow_le_oneShadow_card
    (S : Finset (Fin n → ℕ)) {d m : ℕ}
    (hcard : S.card = m)
    (hdeg : ∀ α ∈ S, totalDeg α = d) :
    kkMinShadow n d m ≤ (oneShadow S).card := by
  convert Nat.sInf_le ?_;
  exact ⟨ ⟨ S, hcard, hdeg ⟩, rfl ⟩

/-! ## Shadow Gap -/

/-- The **shadow gap**: excess of actual shadow size over KK minimum. -/
noncomputable def shadowGap (nn d : ℕ) (S : Finset (Fin nn → ℕ)) : ℤ :=
  (oneShadow S).card - kkMinShadow nn d S.card

/-! ## Squarefree Families -/

/-- A **squarefree family** of degree `d`: every exponent vector has entries
in {0,1} and total degree exactly `d`. -/
def SquarefreeFamily (d : ℕ) (S : Finset (Fin n → ℕ)) : Prop :=
  ∀ α ∈ S, (∀ i : Fin n, α i ≤ 1) ∧ totalDeg α = d

/-! ## Support Circuits -/

/-- A **monotone support circuit**. -/
inductive SupportCircuit (n : ℕ) where
  | atom : (Fin n → ℕ) → SupportCircuit n
  | add  : SupportCircuit n → SupportCircuit n → SupportCircuit n
  | mul  : SupportCircuit n → SupportCircuit n → SupportCircuit n

/-- Evaluation of a support circuit to its support family. -/
def SupportCircuit.eval : SupportCircuit n → Finset (Fin n → ℕ)
  | .atom α  => {α}
  | .add C D => C.eval ∪ D.eval
  | .mul C D => supportMul C.eval D.eval

/-- Size of a support circuit (number of gates). -/
def SupportCircuit.size : SupportCircuit n → ℕ
  | .atom _  => 1
  | .add C D => 1 + C.size + D.size
  | .mul C D => 1 + C.size + D.size

/-- A recursively defined upper bound on shadow size for support circuits. -/
def SupportCircuit.shadowBound : SupportCircuit n → ℕ
  | .atom _  => n
  | .add C D => C.shadowBound + D.shadowBound
  | .mul C D => n * C.eval.card * D.eval.card

/-! ## General Shadow Cardinality Bound -/

/-
**General bound**: the shadow of any family has at most `n * |S|` elements,
since each element contributes at most `n` shadow elements (one per coordinate).
-/
theorem card_oneShadow_le_mul_card (S : Finset (Fin n → ℕ)) :
    (oneShadow S).card ≤ n * S.card := by
  -- Let's rewrite the shadow using the definition.
  have hshadow : oneShadow S = S.biUnion (fun α => Finset.univ.biUnion (fun i => if 0 < α i then {Function.update α i (α i - 1)} else ∅)) := by
    rfl
  refine' hshadow ▸ le_trans ( Finset.card_biUnion_le ) _;
  refine' le_trans ( Finset.sum_le_sum fun x hx => Finset.card_biUnion_le ) _;
  exact le_trans ( Finset.sum_le_sum fun _ _ => Finset.sum_le_sum fun _ _ => show _ ≤ 1 by split_ifs <;> norm_num ) ( by simp +decide [ mul_comm ] )

/-
The cardinality of `supportMul A B` is at most `|A| * |B|`.
-/
theorem card_supportMul_le (A B : Finset (Fin n → ℕ)) :
    (supportMul A B).card ≤ A.card * B.card := by
  exact Finset.card_image_le.trans_eq ( Finset.card_product _ _ )

/-! ## Shadow of Singleton -/

/-
Shadow of a singleton has at most `n` elements.
-/
theorem card_oneShadow_singleton_le (α : Fin n → ℕ) :
    (oneShadow {α}).card ≤ n := by
  simp +decide [ oneShadow ];
  exact le_trans ( Finset.card_biUnion_le ) ( by simpa using Finset.sum_le_sum fun i ( hi : i ∈ Finset.univ ) => show # ( if 0 < α i then { update α i ( α i - 1 ) } else ∅ ) ≤ 1 by split_ifs <;> simp +decide )

/-! ## Circuit Shadow Bound (Theorem 5) -/

/-
**Circuit-level shadow bound.**
The shadow of any support circuit's evaluation is bounded by a recursive
function of the circuit structure.
-/
theorem shadow_bound_of_supportCircuit :
    ∀ C : SupportCircuit n,
      (oneShadow C.eval).card ≤ C.shadowBound := by
  -- We proceed by induction on the structure of the support circuit C.
  intro C
  induction' C with C D hC hD C D hC hD;
  · convert card_oneShadow_singleton_le C;
  · exact le_trans ( card_oneShadow_union_le _ _ ) ( add_le_add hD C );
  · -- By card_oneShadow_le_mul_card, shadow ≤ n * |supportMul C.eval D.eval|.
    have h_mul : (oneShadow (supportMul D.eval hC.eval)).card ≤ n * (supportMul D.eval hC.eval).card := by
      convert card_oneShadow_le_mul_card ( supportMul D.eval hC.eval ) using 1;
    convert h_mul.trans ( Nat.mul_le_mul_left _ ( card_supportMul_le _ _ ) ) using 1;
    exact Nat.mul_assoc _ _ _

/-! ## Squarefree Shadow Bridge -/

/-
For any squarefree family of degree `d`, the KK minimum is a lower bound.
-/
theorem squarefree_shadow_ge_kk
    {d : ℕ} (S : Finset (Fin n → ℕ))
    (hsq : SquarefreeFamily d S) :
    kkMinShadow n d S.card ≤ (oneShadow S).card := by
  convert kkMinShadow_le_oneShadow_card S rfl _;
  exact fun α hα => hsq α hα |>.2

/-! ## Permanent Support -/

/-- Permanent exponent vector for permutation `σ` on `m × m` matrix. -/
def permExponentVec (m : ℕ) (σ : Equiv.Perm (Fin m)) : Fin (m * m) → ℕ :=
  fun idx =>
    if hm : m = 0 then 0
    else
      let row := idx.val / m
      let col := idx.val % m
      if h : row < m then
        if σ ⟨row, h⟩ = ⟨col, Nat.mod_lt idx.val (Nat.pos_of_ne_zero hm)⟩ then 1 else 0
      else 0

/-- The permanent support family for `m × m` matrices. -/
noncomputable def permSupport (m : ℕ) : Finset (Fin (m * m) → ℕ) :=
  Finset.univ.image (permExponentVec m)

end KruskalKatonaSupport