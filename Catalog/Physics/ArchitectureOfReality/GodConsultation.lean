/-! # CatalogBuild.Physics.ArchitectureOfReality.GodConsultation

Auto-generated from theorem catalog database.
Domain: Physics/ArchitectureOfReality
Declarations: 9
-/

import Mathlib

noncomputable section

/-- Strong induction. -/
theorem gods_gift_induction (P : ℕ → Prop)
    (h : ∀ n, (∀ m, m < n → P m) → P n) :
    ∀ n, P n := by
  intro n; exact Nat.strongRecOn n h


/-- The axiom of choice. -/
theorem gods_gift_choice {α β : Type*} {P : α → β → Prop}
    (h : ∀ a, ∃ b, P a b) :
    ∃ f : α → β, ∀ a, P a (f a) :=
  Classical.axiomOfChoice h


theorem gods_gift_lem (P : Prop) : P ∨ ¬P :=
  Classical.em P


/-- The master equation: Im(O) = Fix(O) for idempotent O -/
theorem we_can_prove_master {X : Type*} (O : X → X)
    (hO : ∀ x, O (O x) = O x) :
    range O = {x | O x = x} := by
  ext y; exact ⟨fun ⟨x, hx⟩ => hx ▸ hO x, fun hy => ⟨y, hy⟩⟩


/-- Tropical idempotency is universal -/
theorem we_can_prove_tropical (a : ℝ) : max a a = a := max_self a


/-- Idempotent counting for small n -/
theorem we_can_prove_counting :
    (Finset.univ.filter (fun e : ZMod 30 => e * e = e)).card = 8 := by
  native_decide


/-- The universe of idempotents is self-similar:
the set of idempotent operators on idempotents is itself governed
by the idempotent equation. -/
theorem gods_response_self_similarity {X : Type*} :
    ∀ (O : (X → X) → (X → X)),
    (∀ f, O (O f) = O f) →
    range O = {f | O f = f} :=
  fun O hO => we_can_prove_master O hO


theorem gods_response_boolean {R : Type*} [CommRing R] (e f : R)
    (he : e * e = e) (hf : f * f = f) :
    (e * f) * (e * f) = e * f ∧
    (e + f - e * f) * (e + f - e * f) = e + f - e * f := by
  constructor
  · rw [mul_mul_mul_comm, he, hf]
  ·
    grind +ring


theorem gods_response_boolean_ring {R : Type*} [Ring R]
    (h : ∀ x : R, x * x = x) (a b : R) : a * b = b * a := by
  -- By expanding $(a + b)^2$ and using the fact that $a^2 = a$ and $b^2 = b$, we get $a * b + b * a = 0$.
  have h_comm : a * b + b * a = 0 := by
    have h_comm : (a + b) * (a + b) = a * a + a * b + b * a + b * b := by
      grind;
    grind;
  -- By multiplying both sides of $a * b + b * a = 0$ by $a$, we get $a * a * b + a * b * a = 0$, which simplifies to $a * b + a * b * a = 0$.
  have h_mul_a : a * b + a * b * a = 0 := by
    convert congr_arg ( fun x => a * x ) h_comm using 1 <;> simp +decide [ mul_add, add_mul, mul_assoc ];
    rw [ ← mul_assoc, h ];
  simp_all +decide [ mul_assoc, add_eq_zero_iff_eq_neg ]


end
