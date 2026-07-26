import Mathlib

/-!
# Closure-Compression Core: Factorization, MDL Optimality, and Incompressibility

This file establishes the core theorems linking closure operators to canonical
compression schemes, minimum description length (MDL) optimality, and a
closure-relative notion of incompressibility.

## Main Results

### Theorem A: Closure-induced lossless compression
- `closure_compression_factorizes_through_fixed_points`: Compression via a closure
  operator factors through the subtype of closed (fixed) elements.
- `closure_compression_constant_on_classes`: Compression is constant on
  closure-equivalence classes.
- `closure_compression_idempotent`: Compressing an already-closed element is trivial.

### Theorem B: MDL optimality via canonical representatives
- `closure_respecting_length_factors_through_fixed_points`: Any closure-respecting
  description length factors through the fixed-point subtype.
- `closure_respecting_length_eq_of_same_closure`: Elements with the same closure
  image have the same description length under any closure-respecting code.

### Theorem C: Incompressibility = fixed point under strict descent
- `closure_deficiency_zero_iff_fixed`: Under a strict descent axiom, an element
  has zero deficiency (ℓ(x) - ℓ(cl x) = 0) if and only if it is a fixed point
  of the closure operator.

### Frontier Theorem: Fixed points are minimal-complexity representatives
- `fixed_points_equal_incompressibles_of_strict_minimality`: If a complexity
  functional satisfies closure minimality axioms, fixed points coincide with
  minimal-complexity representatives in their closure class.

## Mathematical Significance

These results establish that **compression can be recast as passage to fixed points
of an idempotent dynamical system**, and that **complexity upper bounds arise from
canonical representatives selected by closure**. This provides a computable,
verified framework for MDL-type reasoning without invoking noncomputable
Kolmogorov complexity.
-/

open Set Function Finset

noncomputable section

namespace ClosureCompressionCore

/-! ## Theorem A: Closure-induced lossless compression -/

/-
**Closure compression factorizes through fixed points.**
For any closure operator and any injective encoding of closed elements,
compression of any element `x` can be decoded back to the canonical
representative `cl x`, which is always a closed element.
-/
theorem closure_compression_factorizes_through_fixed_points
    {α : Type*} [PartialOrder α] [Fintype α] [DecidableEq α]
    (cl : ClosureOperator α)
    (code : {x // cl.IsClosed x} → List Bool)
    (decode : List Bool → Option {x // cl.IsClosed x})
    (hdecode : ∀ z, decode (code z) = some z) :
    ∀ x : α, ∃ z : {y // cl.IsClosed y}, z.1 = cl x ∧ decode (code z) = some z := by
  exact fun x => ⟨ ⟨ cl x, cl.isClosed_iff.mpr ( cl.idempotent x ) ⟩, rfl, hdecode _ ⟩

/-
**Compression is constant on closure-equivalence classes.**
Two elements with the same closure image produce identical compressed output.
-/
theorem closure_compression_constant_on_classes
    {α : Type*} [PartialOrder α]
    (cl : ClosureOperator α)
    (code : {x // cl.IsClosed x} → List Bool)
    (mk_closed : (α → {y // cl.IsClosed y}))
    (hmk : ∀ a, (mk_closed a).1 = cl a) :
    ∀ x y : α, cl x = cl y → code (mk_closed x) = code (mk_closed y) := by
  grind

/-
**Compression is idempotent on the encoding level.**
Compressing an already-closed element produces the same code.
-/
theorem closure_compression_idempotent
    {α : Type*} [PartialOrder α]
    (cl : ClosureOperator α)
    (code : {x // cl.IsClosed x} → List Bool)
    (mk_closed : (α → {y // cl.IsClosed y}))
    (hmk : ∀ a, (mk_closed a).1 = cl a) :
    ∀ x : α, code (mk_closed (cl x)) = code (mk_closed x) := by
  intro x; congr 1; ext; simp +decide [ hmk ] ;

/-! ## Theorem B: MDL optimality -/

/-
**Closure-respecting description lengths factor through fixed points.**
Any description length function `L` that assigns the same length to elements
with the same closure image can be expressed as a function on the closed
subtype composed with the closure map.
-/
theorem closure_respecting_length_factors_through_fixed_points
    {α : Type*} [PartialOrder α]
    (cl : ClosureOperator α)
    (L : α → ℕ)
    (hL : ∀ x y : α, cl x = cl y → L x = L y) :
    ∃ Lfix : {x // cl.IsClosed x} → ℕ,
      ∀ x, L x = Lfix ⟨cl x, cl.isClosed_iff.mpr (cl.idempotent x)⟩ := by
  exact ⟨ fun ⟨ x, hx ⟩ => L x, fun x => hL _ _ ( cl.idempotent _ ).symm ⟩

/-
Elements with the same closure have the same description length.
-/
theorem closure_respecting_length_eq_of_same_closure
    {α : Type*} [PartialOrder α]
    (cl : ClosureOperator α)
    (L : α → ℕ)
    (hL : ∀ x y : α, cl x = cl y → L x = L y)
    (x : α) : L x = L (cl x) := by
  grind +suggestions

/-! ## Theorem C: Incompressibility = fixed point -/

/-
**Closure deficiency zero iff fixed.**
Under a strict descent axiom (closure strictly reduces length on non-fixed
elements), an element has zero deficiency `ℓ(x) - ℓ(cl x) = 0` if and only
if it is a fixed point of the closure operator.

This is the closure-theoretic analogue of "Kolmogorov-random strings are
incompressible": fixed points are exactly the elements that cannot be
further compressed by the closure.
-/
theorem closure_deficiency_zero_iff_fixed
    {α : Type*} [PartialOrder α]
    (cl : ClosureOperator α)
    (ℓ : α → ℕ)
    (hstrict : ∀ x, ¬ cl.IsClosed x → ℓ (cl x) < ℓ x) :
    ∀ x, (ℓ x - ℓ (cl x) = 0) ↔ cl.IsClosed x := by
  grind +suggestions

/-
Fixed points have zero deficiency (forward direction).
-/
theorem fixed_implies_zero_deficiency
    {α : Type*} [PartialOrder α]
    (cl : ClosureOperator α)
    (ℓ : α → ℕ) :
    ∀ x, cl.IsClosed x → ℓ x - ℓ (cl x) = 0 := by
  -- By definition of closure, if cl.IsClosed x, then cl x = x.
  intro x hx
  simp [ClosureOperator.IsClosed.closure_eq hx]

/-
Non-fixed points are strictly compressible (contrapositive).
-/
theorem non_fixed_strictly_compressible
    {α : Type*} [PartialOrder α]
    (cl : ClosureOperator α)
    (ℓ : α → ℕ)
    (hstrict : ∀ x, ¬ cl.IsClosed x → ℓ (cl x) < ℓ x) :
    ∀ x, ¬ cl.IsClosed x → 0 < ℓ x - ℓ (cl x) := by
  exact fun x hx => Nat.sub_pos_of_lt ( hstrict x hx )

/-! ## Frontier Theorem: Fixed points = minimal-complexity representatives -/

/-
**Fixed points are exactly the minimal-complexity representatives in their
closure class.** If a complexity functional `Khat` satisfies:
1. Closure never increases complexity: `Khat (cl x) ≤ Khat x`
2. Closure strictly reduces complexity on non-fixed points

Then an element is a fixed point iff it has minimal complexity in its
closure-equivalence class. This is the correct formal replacement for
"fixed points = Kolmogorov-random strings."
-/
theorem fixed_points_equal_incompressibles_of_strict_minimality
    {α : Type*} [PartialOrder α]
    (cl : ClosureOperator α)
    (Khat : α → ℕ)
    (hclosed_min : ∀ x, Khat (cl x) ≤ Khat x)
    (hstrict : ∀ x, ¬ cl.IsClosed x → Khat (cl x) < Khat x) :
    ∀ x, cl.IsClosed x ↔ ∀ y, cl y = cl x → Khat x ≤ Khat y := by
  grind +suggestions

/-- **One-step convergence.** For closure operators, repeated application
converges in exactly one step. -/
theorem closure_one_step_convergence
    {α : Type*} [PartialOrder α]
    (cl : ClosureOperator α) :
    ∀ x, cl (cl x) = cl x :=
  cl.idempotent

/-- **Closure equivalence relation.** Two elements are closure-equivalent
iff they map to the same canonical representative. -/
def closureEquiv {α : Type*} [PartialOrder α] (cl : ClosureOperator α) : Setoid α where
  r x y := cl x = cl y
  iseqv := ⟨fun _ => rfl, fun h => h.symm, fun h1 h2 => h1.trans h2⟩

end ClosureCompressionCore

end