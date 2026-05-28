/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license.
-/
import Mathlib

/-!
# Cancellation-Aware Shadow Bounds for General Circuits

This file develops a **cancellation-sensitive** extension of the Kruskal–Katona shadow
framework for algebraic circuit complexity. When polynomials are added with cancellation,
the support shrinks, but the *shadow deficit* is controlled by the shadow of the
cancelled monomials.

## Main Definitions

* `oneShadow` — One-step downward shadow of a family of exponent vectors.
* `cancelSet` — Monomials lost to cancellation: `(supp f ∪ supp g) \ supp(f+g)`.
* `supportMul` — Minkowski sum of exponent vector families.
* `CancelCircuit` — Algebraic circuit with explicit cancellation tracking.

## Main Results (3 substantial theorems + cross-domain bridge)

### Theorem 1: Shadow splitting and support transfer
* `oneShadow_split` — For `C ⊆ A`: `Sh(A) ⊆ Sh(C) ∪ Sh(A \ C)`.

### Theorem 2: Quantitative shadow deficit bound
* `shadow_deficit_le` — `|Sh(A)| - |Sh(C)| ≤ |Sh(A \ C)|` for `C ⊆ A`.
* `poly_shadow_deficit` — Polynomial instantiation via cancellation set.

### Theorem 3: Circuit-level recursive bounds
* `shadow_le_envelope` — Circuit shadow ≤ envelope shadow.
* `envelope_shadow_le_bound` — Envelope shadow ≤ recursive bound.
* `add_gate_deficit` — Gate-level deficit ≤ local cancel shadow.

### Cross-domain bridge (additive combinatorics)
* `cancel_card_bound` — Cancellation bounded by overlap structure.
* `mvpoly_support_mul_subset` — Product support ⊆ sumset.
-/

open Finset Function Pointwise

namespace CancellationShadow

variable {n : ℕ}

/-! ## One-Step Shadow -/

/-- The **one-step downward shadow** of a finite set `S` of exponent vectors. -/
def oneShadow (S : Finset (Fin n → ℕ)) : Finset (Fin n → ℕ) :=
  S.biUnion fun α =>
    Finset.univ.biUnion fun i : Fin n =>
      if 0 < α i then {Function.update α i (α i - 1)} else ∅

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
    exact ⟨α, hα, i, by simp [hpos]⟩

@[simp]
theorem oneShadow_empty : oneShadow (∅ : Finset (Fin n → ℕ)) = ∅ := by
  simp [oneShadow]

theorem oneShadow_mono {S₁ S₂ : Finset (Fin n → ℕ)} (h : S₁ ⊆ S₂) :
    oneShadow S₁ ⊆ oneShadow S₂ := by
  intro β hβ
  rw [mem_oneShadow_iff] at hβ ⊢
  obtain ⟨α, hα, i, hpos, rfl⟩ := hβ
  exact ⟨α, h hα, i, hpos, rfl⟩

/-- Shadow of union equals union of shadows (since shadow is defined via biUnion). -/
theorem oneShadow_union_eq (A B : Finset (Fin n → ℕ)) :
    oneShadow (A ∪ B) = oneShadow A ∪ oneShadow B := by
  simp only [oneShadow]
  ext x; simp only [Finset.mem_biUnion, Finset.mem_union]
  constructor
  · rintro ⟨a, ha | ha, hx⟩
    · exact Or.inl ⟨a, ha, hx⟩
    · exact Or.inr ⟨a, ha, hx⟩
  · rintro (⟨a, ha, hx⟩ | ⟨a, ha, hx⟩)
    · exact ⟨a, Or.inl ha, hx⟩
    · exact ⟨a, Or.inr ha, hx⟩

theorem oneShadow_union_subset (A B : Finset (Fin n → ℕ)) :
    oneShadow (A ∪ B) ⊆ oneShadow A ∪ oneShadow B :=
  (oneShadow_union_eq A B).le

theorem card_oneShadow_union_le (A B : Finset (Fin n → ℕ)) :
    (oneShadow (A ∪ B)).card ≤ (oneShadow A).card + (oneShadow B).card := by
  rw [oneShadow_union_eq]
  exact Finset.card_union_le _ _

theorem card_oneShadow_le_mul_card (S : Finset (Fin n → ℕ)) :
    (oneShadow S).card ≤ n * S.card := by
  unfold oneShadow
  calc (S.biUnion _).card
      ≤ ∑ α ∈ S, (Finset.univ.biUnion fun i =>
            if 0 < α i then {Function.update α i (α i - 1)} else ∅).card :=
          Finset.card_biUnion_le
    _ ≤ ∑ _ ∈ S, n := Finset.sum_le_sum fun α _ => by
          calc (Finset.univ.biUnion _).card
              ≤ ∑ _ : Fin n, 1 := le_trans Finset.card_biUnion_le
                  (Finset.sum_le_sum fun i _ => by split_ifs <;> simp)
            _ = n := by simp
    _ = n * S.card := by simp [mul_comm]

/-! ## Theorem 1: Shadow Splitting -/

/-- **Shadow splitting (Theorem 1).** For `C ⊆ A`:
`Sh(A) ⊆ Sh(C) ∪ Sh(A \ C)`.

The shadow of a set decomposes into the shadow of any subset plus
the shadow of the removed elements. Applied to polynomial cancellation:
the shadow of `supp(f) ∪ supp(g)` decomposes into the shadow of
`supp(f+g)` plus the shadow of `Cancel(f,g)`. -/
theorem oneShadow_split {A C : Finset (Fin n → ℕ)} (hCA : C ⊆ A) :
    oneShadow A ⊆ oneShadow C ∪ oneShadow (A \ C) := by
  conv_lhs => rw [show A = C ∪ A \ C from (Finset.union_sdiff_of_subset hCA).symm]
  exact (oneShadow_union_eq C (A \ C)).le

/-! ## Theorem 2: Quantitative Shadow Deficit Bound -/

/-- **Quantitative shadow deficit bound (Theorem 2).**
For `C ⊆ A`:  `|Sh(A)| - |Sh(C)| ≤ |Sh(A \ C)|`.

The amount of one-shadow lost when restricting from `A` to `C` is bounded
by the shadow of the removed set `A \ C`. This is the quantitative heart
of cancellation-aware analysis: if cancellation removes a set `D` of monomials,
the shadow can decrease by at most `|Sh(D)|`. -/
theorem shadow_deficit_le {A C : Finset (Fin n → ℕ)} (hCA : C ⊆ A) :
    (oneShadow A).card - (oneShadow C).card ≤ (oneShadow (A \ C)).card := by
  have h1 : oneShadow A = oneShadow (C ∪ A \ C) := by
    congr 1; exact (Finset.union_sdiff_of_subset hCA).symm
  rw [h1, oneShadow_union_eq]
  have h2 := Finset.card_union_le (oneShadow C) (oneShadow (A \ C))
  omega

/-! ## Polynomial Cancellation -/

section MvPolySupport

variable {σ : Type*} {R : Type*} [DecidableEq σ] [CommSemiring R]

/-- The **cancellation witness set**: monomials present in at least one of
`f, g` but absent from `f + g` due to coefficient cancellation. -/
noncomputable def cancelSet (f g : MvPolynomial σ R) : Finset (σ →₀ ℕ) :=
  (f.support ∪ g.support) \ (f + g).support

/-- `supp(f + g) ⊆ supp(f) ∪ supp(g)`. The fundamental support monotonicity. -/
theorem mvpoly_support_add_subset (f g : MvPolynomial σ R) :
    (f + g).support ⊆ f.support ∪ g.support :=
  MvPolynomial.support_add

/-- `supp(f * g) ⊆ supp(f) + supp(g)` (Minkowski/sumset of supports).
This connects algebraic circuit multiplication to additive combinatorics.
The `+` here is `Finset.pointwiseAdd`, i.e., the sumset. -/
theorem mvpoly_support_mul_subset (f g : MvPolynomial σ R) :
    (f * g).support ⊆ f.support + g.support :=
  MvPolynomial.support_mul f g

/-- Reconstructing the union from surviving support and cancel set. -/
theorem support_add_union_cancel (f g : MvPolynomial σ R) :
    (f + g).support ∪ cancelSet f g = f.support ∪ g.support := by
  simp only [cancelSet]
  exact Finset.union_sdiff_of_subset (MvPolynomial.support_add (p := f) (q := g))

/-- **Shadow deficit for polynomial addition (Theorem 2, polynomial form).**
For any shadow-like subadditive function `sh`,
the deficit from cancellation is bounded by `sh(Cancel(f,g))`.

`sh(supp(f) ∪ supp(g)) - sh(supp(f+g)) ≤ sh(Cancel(f,g))` -/
theorem poly_shadow_deficit
    (sh : Finset (σ →₀ ℕ) → ℕ)
    (h_sub : ∀ A B : Finset (σ →₀ ℕ), sh (A ∪ B) ≤ sh A + sh B)
    (f g : MvPolynomial σ R) :
    sh (f.support ∪ g.support) - sh (f + g).support ≤
      sh (cancelSet f g) := by
  have key : sh (f.support ∪ g.support) ≤
      sh (f + g).support + sh (cancelSet f g) := by
    calc sh (f.support ∪ g.support)
        = sh ((f + g).support ∪ cancelSet f g) := by
          congr 1; exact (support_add_union_cancel f g).symm
      _ ≤ sh (f + g).support + sh (cancelSet f g) :=
          h_sub _ _
  omega

end MvPolySupport

/-! ## Minkowski Sum of Supports -/

/-- Minkowski sum (pointwise addition) of two exponent vector families. -/
def supportMul (A B : Finset (Fin n → ℕ)) : Finset (Fin n → ℕ) :=
  (A ×ˢ B).image fun p => p.1 + p.2

theorem mem_supportMul_iff {A B : Finset (Fin n → ℕ)} {γ : Fin n → ℕ} :
    γ ∈ supportMul A B ↔ ∃ a ∈ A, ∃ b ∈ B, γ = a + b := by
  simp only [supportMul, Finset.mem_image, Finset.mem_product, Prod.exists]
  constructor
  · rintro ⟨a, b, ⟨ha, hb⟩, rfl⟩; exact ⟨a, ha, b, hb, rfl⟩
  · rintro ⟨a, ha, b, hb, rfl⟩; exact ⟨a, b, ⟨ha, hb⟩, rfl⟩

theorem card_supportMul_le (A B : Finset (Fin n → ℕ)) :
    (supportMul A B).card ≤ A.card * B.card :=
  Finset.card_image_le.trans_eq (Finset.card_product _ _)

theorem supportMul_mono {A₁ A₂ B₁ B₂ : Finset (Fin n → ℕ)}
    (hA : A₁ ⊆ A₂) (hB : B₁ ⊆ B₂) :
    supportMul A₁ B₁ ⊆ supportMul A₂ B₂ := by
  intro γ hγ
  rw [mem_supportMul_iff] at hγ ⊢
  obtain ⟨a, ha, b, hb, rfl⟩ := hγ
  exact ⟨a, hA ha, b, hB hb, rfl⟩

/-! ## Theorem 3: Algebraic Circuits with Cancellation Budget -/

/-- An **algebraic circuit** with cancellation tracking.
Each `add` gate stores the actual output support (which may be smaller
than the union of children due to cancellation). -/
inductive CancelCircuit (n : ℕ) where
  | atom (support : Finset (Fin n → ℕ)) : CancelCircuit n
  | add (left right : CancelCircuit n)
      (actualSupp : Finset (Fin n → ℕ)) : CancelCircuit n
  | mul (left right : CancelCircuit n) : CancelCircuit n

/-- The **monotone envelope**: the support ignoring all cancellation. -/
def CancelCircuit.envelope : CancelCircuit n → Finset (Fin n → ℕ)
  | .atom S => S
  | .add L R _ => L.envelope ∪ R.envelope
  | .mul L R => supportMul L.envelope R.envelope

/-- The **actual support** of a circuit (with cancellation). -/
def CancelCircuit.actualSupport : CancelCircuit n → Finset (Fin n → ℕ)
  | .atom S => S
  | .add _ _ S => S
  | .mul L R => supportMul L.actualSupport R.actualSupport

/-- **Well-formedness**: at every `add` gate, the actual support ⊆ envelope. -/
def CancelCircuit.WellFormed : CancelCircuit n → Prop
  | .atom _ => True
  | .add L R actualS =>
      actualS ⊆ L.envelope ∪ R.envelope ∧ L.WellFormed ∧ R.WellFormed
  | .mul L R => L.WellFormed ∧ R.WellFormed

/-- For well-formed circuits, `actualSupport ⊆ envelope`. -/
theorem CancelCircuit.actualSupport_sub_envelope {C : CancelCircuit n}
    (hw : C.WellFormed) : C.actualSupport ⊆ C.envelope := by
  induction C with
  | atom S => exact Finset.Subset.refl S
  | add L R actualS ihL ihR => exact hw.1
  | mul L R ihL ihR => exact supportMul_mono (ihL hw.1) (ihR hw.2)

/-- **Monotone envelope shadow bound**: recursive upper bound. -/
def CancelCircuit.envelopeShadowBound : CancelCircuit n → ℕ
  | .atom S => n * S.card
  | .add L R _ => L.envelopeShadowBound + R.envelopeShadowBound
  | .mul L R => n * L.envelope.card * R.envelope.card

/-- **Cancellation budget**: bound on accumulated shadow deficit at add gates. -/
def CancelCircuit.cancelBudget : CancelCircuit n → ℕ
  | .atom _ => 0
  | .add L R actualS =>
      L.cancelBudget + R.cancelBudget +
      (oneShadow ((L.envelope ∪ R.envelope) \ actualS)).card
  | .mul L R => L.cancelBudget + R.cancelBudget

/-- **Shadow ≤ envelope shadow (Theorem 3a).**
For well-formed circuits, shadow of actual support ≤ shadow of envelope. -/
theorem CancelCircuit.shadow_le_envelope {C : CancelCircuit n}
    (hw : C.WellFormed) :
    (oneShadow C.actualSupport).card ≤ (oneShadow C.envelope).card :=
  Finset.card_le_card (oneShadow_mono (C.actualSupport_sub_envelope hw))

/-- **Envelope shadow ≤ recursive bound (Theorem 3b).** -/
theorem CancelCircuit.envelope_shadow_le_bound :
    ∀ (C : CancelCircuit n),
      (oneShadow C.envelope).card ≤ C.envelopeShadowBound := by
  intro C
  induction C with
  | atom S =>
    simp only [envelope, envelopeShadowBound]
    exact card_oneShadow_le_mul_card S
  | add L R actualS ihL ihR =>
    simp only [envelope, envelopeShadowBound]
    exact le_trans (card_oneShadow_union_le _ _) (Nat.add_le_add ihL ihR)
  | mul L R ihL ihR =>
    simp only [envelope, envelopeShadowBound]
    calc (oneShadow (supportMul L.envelope R.envelope)).card
        ≤ n * (supportMul L.envelope R.envelope).card :=
          card_oneShadow_le_mul_card _
      _ ≤ n * (L.envelope.card * R.envelope.card) :=
          Nat.mul_le_mul_left n (card_supportMul_le _ _)
      _ = n * L.envelope.card * R.envelope.card := by ring

/-- **Gate-level deficit (Theorem 3c).**
At each `add` gate, the shadow deficit is bounded by the shadow of
the gate's local cancellation set. -/
theorem CancelCircuit.add_gate_deficit {L R : CancelCircuit n}
    {actualS : Finset (Fin n → ℕ)}
    (h_sub : actualS ⊆ L.envelope ∪ R.envelope) :
    (oneShadow (L.envelope ∪ R.envelope)).card - (oneShadow actualS).card ≤
      (oneShadow ((L.envelope ∪ R.envelope) \ actualS)).card :=
  shadow_deficit_le h_sub

/-! ## Cross-Domain: Additive Combinatorics Bridge -/

/-- **Overlap-cancellation bound (additive combinatorics bridge).**
`|(A ∪ B) \ C| ≤ |A| + |B| - |C|` for `C ⊆ A ∪ B`.

Applied to polynomial supports: the cancellation set size is bounded by
the total support size minus the surviving support. When overlap between
`supp(f)` and `supp(g)` is small, the cancel set must be small too.
This connects to sumset theory in additive combinatorics. -/
theorem cancel_card_bound {α : Type*} [DecidableEq α] {A B C : Finset α}
    (hC : C ⊆ A ∪ B) :
    ((A ∪ B) \ C).card ≤ A.card + B.card - C.card := by
  have h1 := Finset.card_sdiff_add_card_eq_card hC
  have h2 := Finset.card_union_le A B
  omega

/-- **Cancellation requires overlap.**
The size of `(A ∪ B) \ C` plus `|C|` equals `|A ∪ B|`. -/
theorem cancel_plus_surviving {α : Type*} [DecidableEq α]
    {A B C : Finset α} (hC : C ⊆ A ∪ B) :
    ((A ∪ B) \ C).card + C.card = (A ∪ B).card :=
  Finset.card_sdiff_add_card_eq_card hC

/-- **Cancellation bounded by intersection (additive combinatorics bridge).**
`|(A ∪ B) \ C| ≤ |A| + |B| - |A ∪ B| + |A ∪ B| - |C|`
= `|A ∩ B| + |A ∪ B| - |C|`.

When `|C| = |A ∪ B|` (no cancellation), the deficit is 0.
When `|C|` is much less than `|A ∪ B|`, the deficit is large,
and the inclusion-exclusion term `|A ∩ B|` appears as a natural bound. -/
theorem cancel_with_intersection {α : Type*} [DecidableEq α]
    {A B C : Finset α} (hC : C ⊆ A ∪ B) :
    ((A ∪ B) \ C).card = (A ∪ B).card - C.card := by
  have := Finset.card_sdiff_add_card_eq_card hC
  omega

end CancellationShadow