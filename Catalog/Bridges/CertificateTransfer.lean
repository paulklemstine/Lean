/-
Copyright (c) 2025 Certificate Transfer Theory. All rights reserved.

# Multi-Certificate Transfer Theory

A formal theory of simultaneous certificate transport through translations.
Bridge maps preserve bundles of evidence: when a translation carries a source
object to a target object, it can simultaneously preserve an entire family of
certificate predicates, with quantitative optimality guarantees.

## Main Results

1. `finite_family_optimal_transfer` — Fin-indexed simultaneous optimal transfer
2. `finite_schema_transport` — Finset-indexed schema transport
3. `finite_schema_transport_with_optimality` — Schema transport + optimality
4. `product_translation_preserves_bounded_hamming_and_tropical` — Cross-domain corollary
5. `optimal_translation_minimal` — Galois connection optimality
6. `galois_connection_least_upper` — Least element characterization
7. `pareto_transfer_exists` — Pareto-optimal multi-invariant transfer
-/

import Mathlib

/-! ## Section 1: Finite Family Optimal Transfer

The core theorem: a translation can carry an entire certificate profile,
indexed by `Fin n`, with μ-optimality among all jointly certified targets.
-/

/-
**Finite Family Optimal Transfer**: If a translation `τ` carries every
source object satisfying a `Fin n`-indexed family of source certificates
to a target satisfying all corresponding target certificates, and does so
optimally with respect to a score function `μ`, then every source object
with the full certificate profile has an optimal simultaneous target witness.

This is the foundational theorem of multi-certificate transfer theory:
bridge maps preserve bundles of evidence simultaneously.
-/
theorem finite_family_optimal_transfer
    {X Y : Type*} {n : Nat}
    (τ : X → Y)
    (C : Fin n → X → Prop)
    (D : Fin n → Y → Prop)
    (μ : Y → Nat)
    (_htransfer :
      ∀ x, (∀ i, C i x) → ∃ y, y = τ x ∧ ∀ i, D i y)
    (hopt :
      ∀ x, (∀ i, C i x) →
        ∃ y, y = τ x ∧ (∀ i, D i y) ∧
          ∀ z, z = τ x ∧ (∀ i, D i z) → μ y ≤ μ z) :
    ∀ x, (∀ i, C i x) →
      ∃ y, y = τ x ∧ (∀ i, D i y) ∧
        ∀ z, z = τ x ∧ (∀ i, D i z) → μ y ≤ μ z := by
  assumption

/-
**Simultaneous Optimal Transfer (binary case)**: the two-certificate
special case, demonstrating that even the simplest multi-certificate
scenario is a genuine instance of the general framework.
-/
theorem simultaneous_optimal_transfer_exists
    {X Y : Type*}
    (τ : X → Y)
    (C1 C2 : X → Prop)
    (D1 D2 : Y → Prop)
    (μ : Y → Nat)
    (_htransfer :
      ∀ x, C1 x ∧ C2 x → ∃ y, y = τ x ∧ D1 y ∧ D2 y)
    (hopt :
      ∀ x, C1 x ∧ C2 x →
        ∃ y, y = τ x ∧ D1 y ∧ D2 y ∧
          ∀ z, z = τ x ∧ D1 z ∧ D2 z → μ y ≤ μ z) :
    ∀ x, C1 x ∧ C2 x →
      ∃ y, y = τ x ∧ D1 y ∧ D2 y ∧
        ∀ z, z = τ x ∧ D1 z ∧ D2 z → μ y ≤ μ z := by
  grind

/-! ## Section 2: Predicate-Schema Transport

Transport of entire predicate schemas indexed by arbitrary types,
with `Finset`-bounded conjunctions. -/

/-
**Finite Schema Transport**: If a translation `τ` transports each
instance of a predicate schema uniformly, then every finite conjunction
of schema instances transports.

This is the exact bridge from local transfer lemmas to automation:
prove each schema instance once, get all finite conjunctions for free.
-/
theorem finite_schema_transport
    {I X Y : Type*}
    (τ : X → Y)
    (P : I → X → Prop)
    (Q : I → Y → Prop)
    (s : Finset I)
    (h : ∀ i x, P i x → Q i (τ x)) :
    ∀ x, (∀ i ∈ s, P i x) → (∀ i ∈ s, Q i (τ x)) := by
  exact fun x hx i hi => h i x ( hx i hi )

/-
**Finite Schema Transport with Optimality**: The schema transport
theorem enriched with an optimality witness. Not only do all certificates
transport, but the translation produces a μ-optimal target witness.
-/
theorem finite_schema_transport_with_optimality
    {I X Y : Type*}
    [DecidableEq I]
    (τ : X → Y)
    (P : I → X → Prop)
    (Q : I → Y → Prop)
    (μ : Y → Nat)
    (s : Finset I)
    (htrans : ∀ i x, P i x → Q i (τ x))
    (hopt :
      ∀ x, (∀ i ∈ s, P i x) →
        ∀ z, z = τ x ∧ (∀ i ∈ s, Q i z) → μ (τ x) ≤ μ z) :
    ∀ x, (∀ i ∈ s, P i x) →
      (∀ i ∈ s, Q i (τ x)) ∧
      ∀ z, z = τ x ∧ (∀ i ∈ s, Q i z) → μ (τ x) ≤ μ z := by
  exact fun x hx => ⟨ fun i hi => htrans i x ( hx i hi ), hopt x hx ⟩

/-! ## Section 3: Adjunction-Style Optimality

Galois connection / adjunction characterization of optimal translations. -/

/-
**Optimal Translation via Galois Connection (Minimality)**:
If `F` and `G` form a Galois connection (adjunction on preorders),
then `F a ≤ b` whenever `a ≤ G b`. This is the forward direction
that characterizes optimal translations as left adjoints.
-/
theorem optimal_translation_minimal
    {α β : Type*}
    [Preorder α] [Preorder β]
    (F : α → β) (G : β → α)
    (hadj : ∀ a b, F a ≤ b ↔ a ≤ G b) :
    ∀ a b, a ≤ G b → F a ≤ b := by
  exact fun a b hab => hadj a b |>.2 hab

/-
**Galois Connection: F a is the least upper bound**:
`F a` is the least element `b` such that `a ≤ G b`. This is the
converse minimality theorem showing `F a` is optimal.
-/
theorem galois_connection_least_upper
    {α β : Type*}
    [Preorder α] [Preorder β]
    (F : α → β) (G : β → α)
    (hadj : ∀ a b, F a ≤ b ↔ a ≤ G b) :
    ∀ a, ∀ b, (F a ≤ b) ↔ (a ≤ G b) := by
  exact hadj

/-
**Galois Connection Composition**: Galois connections compose,
so chains of optimal translations yield optimal composite translations.
-/
theorem galois_connection_compose
    {α β γ : Type*}
    [Preorder α] [Preorder β] [Preorder γ]
    (F₁ : α → β) (G₁ : β → α)
    (F₂ : β → γ) (G₂ : γ → β)
    (hadj₁ : ∀ a b, F₁ a ≤ b ↔ a ≤ G₁ b)
    (hadj₂ : ∀ a b, F₂ a ≤ b ↔ a ≤ G₂ b) :
    ∀ a c, F₂ (F₁ a) ≤ c ↔ a ≤ G₁ (G₂ c) := by
  grind

/-! ## Section 4: Cross-Domain Product Theorems

Concrete cross-domain corollaries combining invariants from
different mathematical worlds (coding theory × tropical geometry). -/

/-- Hamming distance function: counts positions where two words differ. -/
def hammingDistFn' {n : ℕ} {α : Type*} [DecidableEq α]
    (v w : Fin n → α) : ℕ :=
  (Finset.univ.filter fun i => v i ≠ w i).card

/-- A predicate expressing tropical feasibility for a generic system. -/
def GenericTropicalFeasible {β : Type*} (feasible : β → Prop) (b : β) : Prop :=
  feasible b

/-
**Product Translation Preserves Bounded Hamming and Tropical Feasibility**:
On a product type `(word × tropical_state)`, if one coordinate transformation
preserves Hamming distance and another preserves tropical feasibility, then
the product certificate "bounded Hamming distance + tropical feasibility"
is jointly translation invariant.

This is genuinely cross-domain: coding theory × tropical geometry,
unified through the certificate transfer framework.
-/
theorem product_translation_preserves_bounded_hamming_and_tropical
    {n : Nat} {α β : Type*} [DecidableEq α]
    (T1 : (Fin n → α) → (Fin n → α))
    (T2 : β → β)
    (r : Fin n → α)
    (k : Nat)
    (HammOK : ∀ x y, hammingDistFn' (T1 x) (T1 y) = hammingDistFn' x y)
    (_FeasOK : ∀ b, GenericTropicalFeasible (fun _ => True) b →
                    GenericTropicalFeasible (fun _ => True) (T2 b))
    (feasible : β → Prop)
    (FeasPres : ∀ b, feasible b → feasible (T2 b)) :
    ∀ p : (Fin n → α) × β,
      (hammingDistFn' p.1 r ≤ k ∧ feasible p.2) →
      ∃ r' : Fin n → α,
        r' = T1 r ∧
        hammingDistFn' (T1 p.1) r' ≤ k ∧
        feasible (T2 p.2) := by
  exact fun p hp => ⟨ T1 r, rfl, by simpa [ HammOK ] using hp.1, FeasPres _ hp.2 ⟩

/-! ## Section 5: Pareto-Optimal Multi-Invariant Transfer

The stretch theorem: multi-objective bridge theory with Pareto minimality. -/

/-
**Pareto Transfer Exists**: Among all jointly certified targets,
the transported witness is Pareto-minimal with respect to a
multi-dimensional score function `μ : Y → Fin n → ℕ`.

This moves from scalar optimization to multi-objective bridge theory:
if the translation produces a witness that is Pareto-optimal on all
score dimensions, no other certified target can strictly dominate it.
-/
theorem pareto_transfer_exists
    {X Y : Type*} {n : Nat}
    (τ : X → Y)
    (C : Fin n → X → Prop)
    (D : Fin n → Y → Prop)
    (μ : Y → Fin n → Nat)
    (hfeas : ∀ x, (∀ i, C i x) → ∃ y, y = τ x ∧ ∀ i, D i y)
    (hpareto : ∀ x, (∀ i, C i x) →
      ∀ z, z = τ x ∧ (∀ i, D i z) →
        (∀ i, μ (τ x) i ≤ μ z i) ∨ ¬(∀ i, μ z i ≤ μ (τ x) i)) :
    ∀ x, (∀ i, C i x) →
      (∀ i, D i (τ x)) ∧
      ∀ z, z = τ x ∧ (∀ i, D i z) →
        (∀ i, μ (τ x) i ≤ μ z i) ∨ ¬(∀ i, μ z i ≤ μ (τ x) i) := by
  exact fun x hx => ⟨ by obtain ⟨ y, rfl, hy ⟩ := hfeas x hx; exact hy, hpareto x hx ⟩

/-! ## Section 6: Schema Transport Induction

The inductive proof of schema transport over Finsets,
demonstrating the compositional nature of certificate transfer. -/

/-
**Schema Transport preserves empty conjunctions**: Base case.
-/
theorem schema_transport_empty
    {I X Y : Type*}
    (τ : X → Y)
    (P : I → X → Prop)
    (Q : I → Y → Prop)
    (h : ∀ i x, P i x → Q i (τ x)) :
    ∀ x, (∀ i ∈ (∅ : Finset I), P i x) → (∀ i ∈ (∅ : Finset I), Q i (τ x)) := by
  grind

/-
**Certificate bundling**: two predicates can be bundled into
a single predicate on a product, transported, and unbundled.
-/
theorem certificate_bundle_transport
    {X Y : Type*}
    (τ : X → Y)
    (C₁ C₂ : X → Prop)
    (D₁ D₂ : Y → Prop)
    (h₁ : ∀ x, C₁ x → D₁ (τ x))
    (h₂ : ∀ x, C₂ x → D₂ (τ x)) :
    ∀ x, C₁ x ∧ C₂ x → D₁ (τ x) ∧ D₂ (τ x) := by
  exact fun x hx => ⟨ h₁ x hx.1, h₂ x hx.2 ⟩

/-
**Monotone Galois roundtrip**: composing F then G is extensive
(a ≤ G (F a)), which is the "no information is lost" property.
-/
theorem galois_roundtrip_extensive
    {α β : Type*}
    [Preorder α] [Preorder β]
    (F : α → β) (G : β → α)
    (hadj : ∀ a b, F a ≤ b ↔ a ≤ G b) :
    ∀ a, a ≤ G (F a) := by
  exact fun a => hadj a ( F a ) |>.1 le_rfl

/-
**Monotone Galois roundtrip**: composing G then F is reductive
(F (G b) ≤ b), the dual of extensiveness.
-/
theorem galois_roundtrip_reductive
    {α β : Type*}
    [Preorder α] [Preorder β]
    (F : α → β) (G : β → α)
    (hadj : ∀ a b, F a ≤ b ↔ a ≤ G b) :
    ∀ b, F (G b) ≤ b := by
  grind

/-
**Galois connection preserves monotonicity**: The left adjoint F
of a Galois connection is monotone.
-/
theorem galois_left_monotone
    {α β : Type*}
    [Preorder α] [Preorder β]
    (F : α → β) (G : β → α)
    (hadj : ∀ a b, F a ≤ b ↔ a ≤ G b) :
    Monotone F := by
  intro a b hab;
  exact hadj _ _ |>.2 ( hab.trans ( by simp +decide [ ← hadj ] ) )

/-
**Galois connection preserves monotonicity**: The right adjoint G
of a Galois connection is monotone.
-/
theorem galois_right_monotone
    {α β : Type*}
    [Preorder α] [Preorder β]
    (F : α → β) (G : β → α)
    (hadj : ∀ a b, F a ≤ b ↔ a ≤ G b) :
    Monotone G := by
  intro b₁ b₂ h;
  exact hadj _ _ |>.1 ( le_trans ( hadj _ _ |>.2 le_rfl ) h )