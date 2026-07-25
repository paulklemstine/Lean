import Mathlib

/-!
# Closure-Compression Optimality and Incompressibility

This file establishes the core theorems of **closure-compression duality**:
the mathematical framework that recasts data compression as projection to
fixed points of an idempotent operator, and characterizes incompressible
objects as exactly the fixed points of the closure.

## Main Results

### Theorem 1: `canonical_representative_shortest_in_closure_class`
The closure image `cl x` is the shortest representative in its closure
equivalence class: for any `y` with `cl y = cl x`, we have
`len (cl x) ≤ len y`.

### Theorem 2: `closure_code_realizes_mdl`
The closure canonical representative achieves the exact minimum description
length (MDL) within its closure class.

### Theorem 3: `fixed_points_iff_closure_incompressible`
Fixed points of the closure are exactly the closure-incompressible objects:
`cl x = x ↔ len (cl x) = len x`, under a faithfulness hypothesis.

### Theorem 4: `compression_factors_through_fixed_points`
Any function constant on closure classes factors through `cl`.

## Mathematical Significance

These results formalize the **closure/Kolmogorov duality**: any idempotent
closure operator induces a canonical compression scheme whose fixed points
are exactly the incompressible objects.
-/

open Function Set

namespace ClosureCompression

/-! ## Definitions -/

/-- An object is **strictly closure-compressible** if the closure strictly
reduces its length. -/
def StrictlyClosureCompressible (cl : α → α) (len : α → ℕ) (x : α) : Prop :=
  len (cl x) < len x

/-- An object is **closure-incompressible** if the closure does not reduce
its length. This is the closure-theoretic analogue of Kolmogorov randomness. -/
def ClosureIncompressible (cl : α → α) (len : α → ℕ) (x : α) : Prop :=
  len (cl x) = len x

/-! ## Theorem 1: Canonical representative is shortest in closure class -/

/-
**Closure canonical representative minimizes length in its fiber.**
If `cl` is idempotent (`cl ∘ cl = cl`) and `len (cl x) ≤ len x` for all `x`,
then for any `y` with `cl y = cl x`, we have `len (cl x) ≤ len y`.

This is the core compression theorem: the closure image is the shortest
certified representative in the closure equivalence class.
-/
theorem canonical_representative_shortest_in_closure_class
    {α : Type*}
    (cl : α → α)
    (len : α → ℕ)
    (_hidem : ∀ x, cl (cl x) = cl x)
    (hmin : ∀ x, len (cl x) ≤ len x)
    (x y : α)
    (hy : cl y = cl x) :
    len (cl x) ≤ len y := by
  calc len (cl x) = len (cl y) := by rw [hy]
    _ ≤ len y := hmin y

/-- Variant: the closure image minimizes length among all elements
with the same closure. -/
theorem closure_minimizes_in_fiber
    {α : Type*}
    (cl : α → α)
    (len : α → ℕ)
    (hidem : ∀ x, cl (cl x) = cl x)
    (hmin : ∀ x, len (cl x) ≤ len x)
    (x : α) :
    ∀ y, cl y = cl x → len (cl x) ≤ len y := fun y hy =>
  canonical_representative_shortest_in_closure_class cl len hidem hmin x y hy

/-! ## Theorem 2: Closure realizes exact MDL -/

/-- The **minimum description length** within a closure class: the infimum
of `len y` over all `y` in the same closure class as `x`. -/
noncomputable def mdlWithinClass (cl : α → α) (len : α → ℕ) (x : α) : ℕ :=
  iInf (fun (y : {y // cl y = cl x}) => len y.1)

/-
**Closure code realizes MDL.** The canonical representative achieves
the exact minimum description length within its closure class.
Under idempotence and the contractive-length hypothesis, the infimum
of lengths in the closure class equals `len (cl x)`.
-/
theorem closure_code_realizes_mdl
    {α : Type*}
    (cl : α → α)
    (len : α → ℕ)
    (hidem : ∀ x, cl (cl x) = cl x)
    (hmin : ∀ x, len (cl x) ≤ len x)
    (x : α) :
    mdlWithinClass cl len x = len (cl x) := by
  refine' le_antisymm _ _;
  · exact Nat.sInf_le ⟨ ⟨ cl x, by simp +decide [ hidem ] ⟩, rfl ⟩;
  · exact le_csInf ⟨ len ( cl x ), ⟨ ⟨ cl x, hidem x ⟩, rfl ⟩ ⟩ fun y hy => by obtain ⟨ ⟨ y, hy ⟩, rfl ⟩ := hy; exact canonical_representative_shortest_in_closure_class cl len hidem hmin x y hy;

/-! ## Theorem 3: Fixed points ↔ incompressibility -/

/-
Forward: fixed implies incompressible (no faithfulness needed).
-/
theorem fixed_implies_incompressible
    {α : Type*}
    (cl : α → α)
    (len : α → ℕ)
    (x : α)
    (hfix : cl x = x) :
    ClosureIncompressible cl len x := by
  grind +locals

/-
Backward: incompressible implies fixed (needs faithfulness).
-/
theorem incompressible_implies_fixed
    {α : Type*}
    (cl : α → α)
    (len : α → ℕ)
    (hfaithful : ∀ x, len (cl x) = len x → cl x = x)
    (x : α)
    (hinc : ClosureIncompressible cl len x) :
    cl x = x := by
  exact hfaithful x hinc

/-
**Fixed points are exactly closure-incompressible objects.**
Under a faithfulness hypothesis (length equality implies fixedness),
`cl x = x` if and only if `len (cl x) = len x`.

This is the rigorous duality theorem: fixed points are exactly the
incompressible states relative to the closure semantics.
-/
theorem fixed_points_iff_closure_incompressible
    {α : Type*}
    (cl : α → α)
    (len : α → ℕ)
    (_hidem : ∀ x, cl (cl x) = cl x)
    (_hle : ∀ x, len (cl x) ≤ len x)
    (hfaithful : ∀ x, len (cl x) = len x → cl x = x) :
    ∀ x, cl x = x ↔ ClosureIncompressible cl len x :=
  fun x => ⟨fun hx => by simp [ClosureIncompressible, hx], fun hx => hfaithful x hx⟩

/-! ## Theorem 4: Compression factorizes through fixed points -/

/-- The set of fixed points of `cl`. -/
def FixedPoints (cl : α → α) : Set α := {x | cl x = x}

/-- **One-step convergence.** For idempotent maps, iteration stabilizes
after one step. -/
theorem one_step_convergence
    {α : Type*}
    (cl : α → α)
    (hidem : ∀ x, cl (cl x) = cl x) :
    ∀ x, cl (cl x) = cl x := hidem

/-- The closure image always lands in the fixed-point set. -/
theorem closure_image_is_fixed
    {α : Type*}
    (cl : α → α)
    (hidem : ∀ x, cl (cl x) = cl x) :
    ∀ x, cl x ∈ FixedPoints cl :=
  fun x => hidem x

/-
Fixed points are exactly the range of cl when cl is idempotent.
-/
theorem fixed_eq_range_of_idempotent
    {α : Type*}
    (cl : α → α)
    (hidem : ∀ x, cl (cl x) = cl x) :
    FixedPoints cl = Set.range cl := by
  exact Set.ext fun x => ⟨ fun hx => ⟨ x, hx ⟩, fun hx => by obtain ⟨ y, rfl ⟩ := hx; exact hidem y ⟩

/-
**Compression factorization.** Any function that is constant on closure
classes factors through `cl`.
-/
theorem compression_factors_through_fixed_points
    {α β : Type*}
    (cl : α → α)
    (hidem : ∀ x, cl (cl x) = cl x)
    (f : α → β)
    (hf : ∀ x y, cl x = cl y → f x = f y) :
    ∀ x, f x = f (cl x) := by
  exact fun x => hf _ _ ( Eq.symm ( hidem x ) )

/-! ## Closure equivalence relation -/

/-- The equivalence relation induced by a closure operator:
`x ~ y ↔ cl x = cl y`. -/
def closureSetoid (cl : α → α) : Setoid α where
  r x y := cl x = cl y
  iseqv := ⟨fun _ => rfl, fun h => h.symm, fun h1 h2 => h1.trans h2⟩

/-
Equal closure implies equal MDL.
-/
theorem mdl_constant_on_classes
    {α : Type*}
    (cl : α → α)
    (len : α → ℕ)
    (x y : α)
    (h : cl x = cl y) :
    mdlWithinClass cl len x = mdlWithinClass cl len y := by
  unfold mdlWithinClass;
  rw [ h ]

end ClosureCompression