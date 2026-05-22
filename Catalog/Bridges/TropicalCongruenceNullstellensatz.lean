/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib

/-!
# Congruence-Level Tropical Nullstellensatz for EML Function Semirings

This file upgrades the ideal-level tropical Nullstellensatz to the *congruence level*,
which is the correct algebraic-geometric language for idempotent semirings. In classical
algebraic geometry, ideals capture kernels of ring homomorphisms. In semiring geometry —
where subtraction is unavailable — the correct analogues are *congruences*: equivalence
relations compatible with the semiring operations.

## Main definitions

* `TropCongr.zeroSet` — the common solution locus of a finite family of equations
* `TropCongr.vanishing` — the vanishing congruence of a point set
* `TropCongr.radical` — the radical congruence of a finite relation
* `TropCongr.vanishingSetoid` — `vanishing V` as a `Setoid`
* `TropCongr.radicalSetoid` — `radical R` as a `Setoid`

## Main results

* `TropCongr.radical_eq_vanishing_zeroSet` — **the congruence-level tropical
  Nullstellensatz**: the radical congruence of `R` equals the vanishing congruence
  of the zero set of `R`
* `TropCongr.radicalSetoid_eq_vanishingSetoid` — the setoid-level formulation
* `TropCongr.vanishing_anti` — antitonicity of the vanishing congruence
* `TropCongr.zeroSet_anti` — antitonicity of the zero set
* `TropCongr.galoisConnection` — Galois connection between point sets and congruences
* `TropCongr.vanishing_compatible_add` — compatibility with pointwise addition
* `TropCongr.vanishing_compatible_mul` — compatibility with pointwise multiplication
* Bridge theorems connecting congruence-level and ideal-level objects

## Mathematical significance

Given finitely many equations f₁ = g₁, …, fₙ = gₙ in an idempotent function semiring,
the radical congruence — all pairs that must agree on the common solution locus — coincides
with the vanishing congruence of that solution locus. This is the fundamental
algebra-geometry correspondence at the congruence level for tropical/semiring geometry.
-/

open Set Finset

universe u v

variable {X : Type u} {S : Type v}

namespace TropCongr

/-! ### Core definitions -/

/-- The common zero set (solution locus) of a finite family of equations:
the set of points where all pairs in `R` agree pointwise. -/
def zeroSet (R : Finset ((X → S) × (X → S))) : Set X :=
  {x | ∀ p ∈ R, p.1 x = p.2 x}

/-- The vanishing congruence of a point set `V`: the set of all pairs `(f, g)`
that agree on every point of `V`. This is the congruence-geometric analogue
of the vanishing ideal. -/
def vanishing (V : Set X) : Set ((X → S) × (X → S)) :=
  {p | ∀ x ∈ V, p.1 x = p.2 x}

/-- The radical congruence of a finite family of equations: the set of all pairs
`(f, g)` that agree wherever all pairs in `R` agree. This is the congruence-geometric
analogue of the tropical radical. -/
def radical (R : Finset ((X → S) × (X → S))) : Set ((X → S) × (X → S)) :=
  {p | ∀ x, (∀ q ∈ R, q.1 x = q.2 x) → p.1 x = p.2 x}

/-! ### Membership lemmas -/

@[simp]
theorem mem_zeroSet_iff (R : Finset ((X → S) × (X → S))) (x : X) :
    x ∈ zeroSet R ↔ ∀ p ∈ R, p.1 x = p.2 x :=
  Iff.rfl

@[simp]
theorem mem_vanishing_iff (V : Set X) (p : (X → S) × (X → S)) :
    p ∈ vanishing V ↔ ∀ x ∈ V, p.1 x = p.2 x :=
  Iff.rfl

@[simp]
theorem mem_radical_iff (R : Finset ((X → S) × (X → S)))
    (p : (X → S) × (X → S)) :
    p ∈ radical R ↔ ∀ x, (∀ q ∈ R, q.1 x = q.2 x) → p.1 x = p.2 x :=
  Iff.rfl

/-! ### The Congruence-Level Tropical Nullstellensatz -/

/-
**The Congruence-Level Tropical Nullstellensatz.**
The radical congruence of a finite family of equations `R` equals the vanishing
congruence of the zero set (common solution locus) of `R`.

A pair `(f, g)` belongs to the radical congruence of `R`
(i.e., `f` and `g` must agree wherever all equations in `R` are satisfied)
if and only if `f` and `g` agree on every point of the common solution locus of `R`.
-/
theorem radical_eq_vanishing_zeroSet (R : Finset ((X → S) × (X → S))) :
    radical R = vanishing (zeroSet R) := by
  ext ⟨ f, g ⟩ ; simp +decide [ radical, vanishing, zeroSet ] ;

/-! ### Antitonicity and monotonicity -/

/-
The vanishing congruence is antitone: enlarging the point set shrinks the
congruence, because more points impose more equality constraints.
-/
theorem vanishing_anti {V W : Set X} (h : V ⊆ W) :
    (vanishing W : Set ((X → S) × (X → S))) ⊆ vanishing V := by
  exact fun p hp x hx => hp x ( h hx )

/-
The zero set is antitone in the relation set: adding more equations
shrinks the solution locus.
-/
theorem zeroSet_anti {R₁ R₂ : Finset ((X → S) × (X → S))} (h : R₁ ⊆ R₂) :
    zeroSet R₂ ⊆ zeroSet R₁ := by
  exact fun x hx => fun p hp => hx p ( h hp )

/-
Every pair in `R` belongs to the radical congruence of `R`.
-/
theorem subset_radical (R : Finset ((X → S) × (X → S))) :
    (R : Set ((X → S) × (X → S))) ⊆ radical R := by
  exact fun p hp => fun x hx => hx p hp

/-! ### Galois connection -/

/-
The Galois connection between point sets and congruences: a set of pairs
is contained in the vanishing congruence of `V` if and only if `V` is contained
in the zero set of those pairs.
-/
theorem galoisConnection (R : Finset ((X → S) × (X → S))) (V : Set X) :
    (R : Set ((X → S) × (X → S))) ⊆ vanishing V ↔ V ⊆ zeroSet R := by
  constructor <;> intro h <;> intro x hx <;> specialize h <;> simp_all +decide;
  · exact fun a b hab => h hab x hx;
  · exact fun y hy => h hy x hx

/-! ### Equivalence relation structure -/

/-- The vanishing congruence on a set `V` forms a setoid (equivalence relation)
on functions `X → S`. -/
def vanishingSetoid (V : Set X) : Setoid (X → S) where
  r f g := ∀ x ∈ V, f x = g x
  iseqv := {
    refl := fun _ _ _ => rfl
    symm := fun h x hx => (h x hx).symm
    trans := fun h₁ h₂ x hx => (h₁ x hx).trans (h₂ x hx)
  }

/-- The radical congruence forms a setoid (equivalence relation). -/
def radicalSetoid (R : Finset ((X → S) × (X → S))) : Setoid (X → S) where
  r f g := ∀ x, (∀ q ∈ R, q.1 x = q.2 x) → f x = g x
  iseqv := {
    refl := fun _ _ _ => rfl
    symm := fun h x hR => (h x hR).symm
    trans := fun h₁ h₂ x hR => (h₁ x hR).trans (h₂ x hR)
  }

/-- The vanishing setoid agrees with the vanishing congruence set. -/
theorem vanishingSetoid_eq (V : Set X) (f g : X → S) :
    (vanishingSetoid V).r f g ↔ (f, g) ∈ vanishing V :=
  Iff.rfl

/-- The radical setoid agrees with the radical congruence set. -/
theorem radicalSetoid_eq (R : Finset ((X → S) × (X → S))) (f g : X → S) :
    (radicalSetoid R).r f g ↔ (f, g) ∈ radical R :=
  Iff.rfl

/-
**Setoid-level Congruence Nullstellensatz.**
The radical setoid equals the vanishing setoid on the zero set.
-/
theorem radicalSetoid_eq_vanishingSetoid (R : Finset ((X → S) × (X → S))) :
    radicalSetoid R = vanishingSetoid (zeroSet R) := by
  ext; simp [radicalSetoid, vanishingSetoid, zeroSet]

/-! ### Compatibility with semiring operations -/

section SemiringCompat

variable [Add S] [Mul S]

/-
The vanishing congruence is compatible with pointwise addition:
if `(f₁, g₁)` and `(f₂, g₂)` agree on `V`, then so do `(f₁ + f₂, g₁ + g₂)`.
-/
omit [Mul S] in
theorem vanishing_compatible_add (V : Set X)
    {f₁ g₁ f₂ g₂ : X → S}
    (h₁ : (f₁, g₁) ∈ (vanishing V : Set ((X → S) × (X → S))))
    (h₂ : (f₂, g₂) ∈ (vanishing V : Set ((X → S) × (X → S)))) :
    (f₁ + f₂, g₁ + g₂) ∈ (vanishing V : Set ((X → S) × (X → S))) := by
  exact fun x hx => congr_arg₂ ( · + · ) ( h₁ x hx ) ( h₂ x hx )

/-
The vanishing congruence is compatible with pointwise multiplication:
if `(f₁, g₁)` and `(f₂, g₂)` agree on `V`, then so do `(f₁ * f₂, g₁ * g₂)`.
-/
omit [Add S] in
theorem vanishing_compatible_mul (V : Set X)
    {f₁ g₁ f₂ g₂ : X → S}
    (h₁ : (f₁, g₁) ∈ (vanishing V : Set ((X → S) × (X → S))))
    (h₂ : (f₂, g₂) ∈ (vanishing V : Set ((X → S) × (X → S)))) :
    (f₁ * f₂, g₁ * g₂) ∈ (vanishing V : Set ((X → S) × (X → S))) := by
  intro x hx
  exact congr_arg₂ (· * ·) (h₁ x hx) (h₂ x hx)

/-
The diagonal pair `(f, f)` always belongs to the vanishing congruence.
-/
omit [Add S] [Mul S] in
theorem vanishing_diagonal (V : Set X) (f : X → S) :
    (f, f) ∈ (vanishing V : Set ((X → S) × (X → S))) := by
  exact fun x hx => rfl

/-
The vanishing congruence is symmetric.
-/
omit [Add S] [Mul S] in
/-- The vanishing congruence is symmetric. -/
theorem vanishing_symm (V : Set X) {f g : X → S}
    (h : (f, g) ∈ (vanishing V : Set ((X → S) × (X → S)))) :
    (g, f) ∈ (vanishing V : Set ((X → S) × (X → S))) := by
  exact fun x hx => Eq.symm ( h x hx )

/-
The vanishing congruence is transitive.
-/
omit [Add S] [Mul S] in
/-- The vanishing congruence is transitive. -/
theorem vanishing_trans (V : Set X) {f g h : X → S}
    (h₁ : (f, g) ∈ (vanishing V : Set ((X → S) × (X → S))))
    (h₂ : (g, h) ∈ (vanishing V : Set ((X → S) × (X → S)))) :
    (f, h) ∈ (vanishing V : Set ((X → S) × (X → S))) := by
  exact fun x hx => h₁ x hx ▸ h₂ x hx ▸ rfl

end SemiringCompat

/-! ### Bridge to ideal-level Nullstellensatz -/

section IdealBridge

variable [Bot S]

/-
Bridge: the congruence zero set of singleton `{(f, ⊥)}` agrees with the
ideal-level zero set `{x | f x = ⊥}`. Here `⊥` denotes the constant-bot function.
-/
theorem zeroSet_singleton_eq_idealZeroSet (f : X → S) :
    zeroSet ({(f, fun _ => ⊥)} : Finset ((X → S) × (X → S))) =
      {x | f x = ⊥} := by
  exact Set.ext fun x => by simp +decide [ zeroSet ] ;

/-- Bridge: the vanishing congruence of `V` restricted to pairs `(f, ⊥)` recovers
the ideal-level vanishing ideal. -/
theorem vanishing_bot_eq_idealOfSet (V : Set X) (f : X → S) :
    (f, fun _ => ⊥) ∈ (vanishing V : Set ((X → S) × (X → S))) ↔
      ∀ x ∈ V, f x = ⊥ :=
  Iff.rfl

end IdealBridge

/-! ### Empty and universal cases -/

/-
The zero set of the empty relation is the entire space.
-/
@[simp]
theorem zeroSet_empty : zeroSet (∅ : Finset ((X → S) × (X → S))) = Set.univ := by
  exact Set.eq_univ_of_forall fun x => by simp +decide [ zeroSet ] ;

/-
The vanishing congruence of the empty set is the total relation.
-/
@[simp]
theorem vanishing_empty : (vanishing ∅ : Set ((X → S) × (X → S))) = Set.univ := by
  exact Set.eq_univ_of_forall fun p => fun x hx => False.elim <| hx

/-
The vanishing congruence of the universe is the diagonal (equality).
-/
theorem vanishing_univ :
    (vanishing Set.univ : Set ((X → S) × (X → S))) = {p | p.1 = p.2} := by
  -- To prove equality of sets, we show each set is a subset of the other.
  apply Set.ext
  intro p
  simp [vanishing];
  exact ⟨ fun h => funext h, fun h x => congr_fun h x ⟩

/-
The radical of the empty finset is the diagonal (equality). Since the empty
set of equations is vacuously satisfied everywhere, the radical congruence requires
agreement at every point, i.e., function equality.
-/
theorem radical_empty_eq_diagonal :
    radical (∅ : Finset ((X → S) × (X → S))) = {p | p.1 = p.2} := by
  simp +decide [ radical, funext_iff ]

/-! ### Zero set of unions -/

/-
The zero set of a union is the intersection of zero sets.
-/
theorem zeroSet_union [DecidableEq ((X → S) × (X → S))]
    (R₁ R₂ : Finset ((X → S) × (X → S))) :
    zeroSet (R₁ ∪ R₂) = zeroSet R₁ ∩ zeroSet R₂ := by
  ext x; simp [zeroSet];
  grind

/-
The vanishing congruence of an intersection contains the union of
vanishing congruences.
-/
theorem vanishing_inter_superset (V W : Set X) :
    (vanishing V : Set ((X → S) × (X → S))) ∪ vanishing W ⊆
      vanishing (V ∩ W) := by
  unfold vanishing at *; aesop;

/-! ### Closure operator properties -/

/-
Applying vanishing then zeroSet produces a larger set:
`V ⊆ zeroSet(vanishing V)` when restricted to finset-representable congruences.
-/
theorem subset_zeroSet_vanishing (R : Finset ((X → S) × (X → S))) :
    (R : Set ((X → S) × (X → S))) ⊆ vanishing (zeroSet R) := by
  grind +locals

/-
The radical congruence contains the generating set.
-/
theorem generating_subset_radical (R : Finset ((X → S) × (X → S))) :
    (R : Set ((X → S) × (X → S))) ⊆ radical R := by
  exact subset_radical R

end TropCongr