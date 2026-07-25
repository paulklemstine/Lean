/-
# Tropical Dreams, Reforged: A Formal Bridge Between 𝔽₁-Combinatorics and Tropical Convexity

This file establishes that finite tropical convex objects carry a canonical 𝔽₁-combinatorial
shadow, and that base change from this shadow recovers toric/combinatorial invariants.

The key insight is that in a finite distributive lattice (the right model for finite tropical
convexity), the join-irreducible elements play the role of "𝔽₁-points" — they are the
indecomposable tropical generators from which every element is reconstructed.

## Main results

* `TropF1.IsIndecomposable` — an element that cannot be decomposed as a nontrivial tropical
  combination
* `TropF1.isIndecomposable_sup_iff` — indecomposable points under sup are exactly the
  sup-irreducibles plus ⊥
* `TropF1.sup_supIrred_eq` — every element of a finite distributive lattice is the sup of
  join-irreducibles below it (generation by 𝔽₁-points)
* `TropF1.finset_supIrred_iff_singleton` — in a Boolean lattice of finite sets, the
  sup-irreducibles are exactly the singletons
* `TropF1.F1Card_finset_eq_card` — the 𝔽₁-cardinality of a Boolean lattice equals the ground
  set size
* `TropF1.supBotHom_eq_of_eq_on_supIrred` — sup-preserving maps are determined by their
  values on join-irreducibles (base change theorem)

## References

* Birkhoff's representation theorem for finite distributive lattices
* Connes–Consani–Marcolli theory of 𝔽₁-geometry
* Tropical convexity (Develin–Sturmfels)
-/

import Mathlib

namespace TropF1

open Finset
attribute [local instance] Classical.propDecidable

/-! ## Definition: Tropically indecomposable elements -/

/-- An element `v` is **tropically indecomposable** with respect to a binary operation `op`
if whenever `op a b = v`, at least one of `a, b` equals `v`. In the tropical setting with
`op = sup`, this captures elements that cannot be decomposed as a nontrivial tropical
combination. This is the 𝔽₁-analog of "vertex" or "indecomposable generator." -/
def IsIndecomposable {α : Type*} (op : α → α → α) (v : α) : Prop :=
  ∀ a b, op a b = v → a = v ∨ b = v

/-! ## Theorem 1: Indecomposable elements under sup characterization -/

/-
In a semilattice with bot, `IsIndecomposable sup v` holds iff `v` is sup-irreducible
or `v = ⊥`. The bottom element is trivially indecomposable (the only way `a ⊔ b = ⊥` is
`a = b = ⊥`), while for non-minimal elements, indecomposability is exactly
sup-irreducibility.
-/
theorem isIndecomposable_sup_iff {α : Type*} [SemilatticeSup α] [OrderBot α] (v : α) :
    IsIndecomposable (· ⊔ ·) v ↔ SupIrred v ∨ v = ⊥ := by
  by_cases hv : v = ⊥ <;> simp_all +decide [ IsIndecomposable, SupIrred ]

/-
For non-bot elements, `IsIndecomposable sup` is exactly `SupIrred`. This is the core
identification: 𝔽₁-points of a tropical skeleton are join-irreducible elements.
-/
theorem isIndecomposable_sup_iff_supIrred {α : Type*} [SemilatticeSup α] [OrderBot α]
    {v : α} (hv : v ≠ ⊥) :
    IsIndecomposable (· ⊔ ·) v ↔ SupIrred v := by
  convert isIndecomposable_sup_iff v using 1;
  aesop

/-! ## Definition: 𝔽₁-Cardinality -/

/-- The **𝔽₁-cardinality** of a finite type equipped with a sup-semilattice structure
is the number of sup-irreducible elements. These are the "𝔽₁-points" — the
indecomposable tropical generators. -/
noncomputable def F1Card (α : Type*) [SemilatticeSup α] [Fintype α] : ℕ :=
  Fintype.card {x : α // SupIrred x}

/-! ## Verified algorithm: extract extreme generators -/

/-- Computable extraction of sup-irreducible elements from a finite type.
This is the algorithmic heart of 𝔽₁-point detection in tropical skeletons. -/
def supIrredFinset (α : Type*) [SemilatticeSup α] [OrderBot α]
    [Fintype α] [DecidableEq α] [DecidablePred (SupIrred : α → Prop)] : Finset α :=
  Finset.univ.filter (fun x => SupIrred x)

/-- Correctness of the extraction algorithm. -/
theorem mem_supIrredFinset_iff (α : Type*) [SemilatticeSup α] [OrderBot α]
    [Fintype α] [DecidableEq α] [DecidablePred (SupIrred : α → Prop)] (x : α) :
    x ∈ supIrredFinset α ↔ SupIrred x := by
  simp [supIrredFinset]

/-! ## Theorem 2: Generation by 𝔽₁-points

Every element of a finite distributive lattice is the supremum of the
sup-irreducible elements below it. -/

/-
Every element of a finite distributive lattice is the sup of the sup-irreducible elements
below it. This is the tropical/𝔽₁ generation theorem: the entire tropical skeleton is
reconstructed from its 𝔽₁-points.
-/
theorem sup_supIrred_eq {α : Type*} [DistribLattice α] [OrderBot α]
    [Fintype α] [DecidableEq α]
    (x : α) :
    (Finset.univ.filter (fun e => SupIrred e ∧ e ≤ x)).sup id = x := by
  by_contra h;
  -- By induction on $x$, we can � show� that if $x$ is not the supremum � of� the sup-irreducible elements below it, then there exists a sup-irreducible element $e$ such that $e \leq x$ and $e$ is not in the set of sup-irreducible elements below $x$.
  induction' x using WellFoundedLT.induction with x ih;
  -- If $x$ is not the supremum of the sup-irreducible elements below it, then there exist $a, b < x$ such that $a \lor b = x$.
  obtain ⟨a, b, ha, hb, hab⟩ : ∃ a b : α, a < x ∧ b < x ∧ a ⊔ b = x := by
    by_cases hx : SupIrred x;
    · refine' False.elim ( h _ );
      refine' le_antisymm _ _;
      · exact Finset.sup_le fun e he => by aesop;
      · exact Finset.le_sup ( f := id ) ( by aesop );
    · rw [ SupIrred ] at hx;
      by_cases hx : IsMin x <;> simp_all +decide [ IsMin ];
      · simp_all +decide [ le_antisymm_iff ];
      · obtain ⟨ y, hy, hy' ⟩ := hx; obtain ⟨ a, b, hab, ha, hb ⟩ := ‹∀ x_1 ≤ x, ¬x ≤ x_1 → ∃ x_2 x_3, x_2 ⊔ x_3 = x ∧ ¬x_2 = x ∧ ¬x_3 = x› y hy hy'; exact ⟨ a, lt_of_le_of_ne ( hab ▸ le_sup_left ) ha, b, lt_of_le_of_ne ( hab ▸ le_sup_right ) hb, hab ⟩ ;
  refine' h _;
  refine' le_antisymm _ _;
  · aesop;
  · grind

/-! ## Theorem 3: Boolean lattice model — singletons are the 𝔽₁-points -/

/-
In the Boolean lattice `Finset α`, the sup-irreducible elements under union
are exactly the singletons. This gives a concrete model: the 𝔽₁-points of
the powerset tropical skeleton are the individual elements of the ground set.
-/
theorem finset_supIrred_iff_singleton {α : Type*} [DecidableEq α]
    (s : Finset α) :
    SupIrred s ↔ ∃ a : α, s = {a} := by
  by_cases h : s.Nonempty <;> simp_all +decide [ Finset.nonempty_iff_ne_empty ];
  constructor <;> intro h' <;> simp_all +decide [ SupIrred ];
  · obtain ⟨ a, ha ⟩ := Finset.nonempty_iff_ne_empty.2 h; use a; specialize h' ( show { a } ∪ ( s \ { a } ) = s from by aesop ) ; aesop;
  · grind +splitImp

/-! ## Theorem 4: 𝔽₁-cardinality of Boolean lattice = ground set size -/

/-
The 𝔽₁-cardinality of the Boolean lattice `Finset α` equals the cardinality
of the ground set `α`. This is the precise version of "𝔽₁-points are vertices"
in the simplex/Boolean model.
-/
theorem F1Card_finset_eq_card (α : Type*) [Fintype α] [DecidableEq α] :
    F1Card (Finset α) = Fintype.card α := by
  convert Fintype.card_of_subtype _ _;
  rotate_left;
  exact Finset.image ( fun a => { a } ) Finset.univ;
  · simp +decide [ finset_supIrred_iff_singleton ];
    exact fun x => exists_congr fun a => eq_comm;
  · rw [ Finset.card_image_of_injective _ fun a b h => by simpa using h, Finset.card_univ ]

/-! ## Theorem 5: Base change — sup-preserving maps are determined by 𝔽₁-points -/

/-
A map from a finite distributive lattice that preserves finite sups and bot
is uniquely determined by its values on sup-irreducible elements. This is the
finite affine content of "base change from 𝔽₁": classical additive geometry
is reconstructed from the tropical/𝔽₁-skeleton by freely extending the
extremal generators.
-/
theorem supBotHom_eq_of_eq_on_supIrred
    {α : Type*} [DistribLattice α] [OrderBot α] [Fintype α] [DecidableEq α]
    {β : Type*} [SemilatticeSup β] [OrderBot β]
    (f g : SupBotHom α β)
    (h : ∀ x : α, SupIrred x → f x = g x) :
    f = g := by
  ext x;
  rw [ ← sup_supIrred_eq x, ← sup_supIrred_eq x ];
  -- Since $g$ and $f$ are both sup-preserving homomorphisms, they commute with the supremum operation.
  have h_comm : ∀ (s : Finset α), g (s.sup id) = s.sup (fun e => g e) ∧ f (s.sup id) = s.sup (fun e => f e) := by
    intro s; induction s using Finset.induction <;> aesop;
  rw [ h_comm _ |>.1, h_comm _ |>.2 ];
  exact Finset.sup_congr rfl fun e he => by aesop;

end TropF1