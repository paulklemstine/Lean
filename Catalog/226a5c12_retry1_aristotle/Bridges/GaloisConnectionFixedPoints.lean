import Mathlib

/-!
# The order-theoretic half of the Galois-connection bridge

This file develops, **independently of Knaster–Tarski**, the fixed-point theory
attached to a Galois connection between two complete lattices.

Given complete lattices `α`, `β` and maps `l : α → β`, `u : β → α` forming a
Galois connection (`l a ≤ b ↔ a ≤ u b`), we:

* define the closure operator `cl a = u (l a)` on `α` and the kernel/interior
  operator `ker b = l (u b)` on `β`;
* prove the standard consequences of the adjunction *directly* from the
  defining bi-implication (`l`, `u` monotone; `a ≤ u (l a)`; `l (u b) ≤ b`;
  `u (l (u b)) = u b`; `l (u (l a)) = l a`);
* introduce the closed elements `{a // u (l a) = a}` and coclosed elements
  `{b // l (u b) = b}`;
* establish the fundamental fixed-point correspondence as an `OrderIso`
  (`fixedPointOrderIso`);
* prove that the closed elements form a complete lattice and the coclosed
  elements form a complete lattice, *without invoking Knaster–Tarski*,
  using only the closure-system structure (arbitrary infima of closed elements
  are closed; arbitrary suprema are obtained by closing the ambient supremum,
  and dually for coclosed elements);
* record the equivalent explicit least-upper-bound / greatest-lower-bound
  theorems with their closed-form witnesses.

**Anti-circularity.**  Nothing here references `Bridges.KnasterTarskiBridge`.
The bridge to Knaster–Tarski (least fixed point of `cl` is `u (l ⊥)`, greatest
fixed point of `ker` is `l (u ⊤)`) lives in the separate file
`Bridges.GaloisConnectionKnasterTarskiBridge`.
-/

namespace GaloisConnectionFixedPoints

universe u v

variable {α : Type u} {β : Type v}

/-! ## Section 1: the closure and kernel operators -/

section Operators

/-- The closure operator on `α` attached to a candidate adjunction `(l, u)`. -/
def cl (l : α → β) (u : β → α) (a : α) : α := u (l a)

/-- The kernel (interior) operator on `β` attached to a candidate adjunction
`(l, u)`. -/
def ker (l : α → β) (u : β → α) (b : β) : β := l (u b)

@[simp] theorem cl_apply (l : α → β) (u : β → α) (a : α) : cl l u a = u (l a) := rfl
@[simp] theorem ker_apply (l : α → β) (u : β → α) (b : β) : ker l u b = l (u b) := rfl

end Operators

/-! ## Section 2: consequences of the adjunction, proved directly -/

section GaloisConnection

variable [CompleteLattice α] [CompleteLattice β] {l : α → β} {u : β → α}

/-- The unit of the adjunction: `a ≤ u (l a)`.  Proved directly from
`l a ≤ l a ↔ a ≤ u (l a)`. -/
theorem le_u_l (gc : GaloisConnection l u) (a : α) : a ≤ u (l a) :=
  (gc a (l a)).1 le_rfl

/-- The counit of the adjunction: `l (u b) ≤ b`.  Proved directly from
`l (u b) ≤ b ↔ u b ≤ u b`. -/
theorem l_u_le (gc : GaloisConnection l u) (b : β) : l (u b) ≤ b :=
  (gc (u b) b).2 le_rfl

/-- The left adjoint is monotone (direct proof). -/
theorem monotone_l (gc : GaloisConnection l u) : Monotone l :=
  fun _ a' h => (gc _ (l a')).2 (h.trans (le_u_l gc a'))

/-- The right adjoint is monotone (direct proof). -/
theorem monotone_u (gc : GaloisConnection l u) : Monotone u :=
  fun b _ h => (gc (u b) _).1 ((l_u_le gc b).trans h)

/-- Triangle identity on the right: `u (l (u b)) = u b`. -/
theorem u_l_u (gc : GaloisConnection l u) (b : β) : u (l (u b)) = u b :=
  le_antisymm (monotone_u gc (l_u_le gc b)) (le_u_l gc (u b))

/-- Triangle identity on the left: `l (u (l a)) = l a`. -/
theorem l_u_l (gc : GaloisConnection l u) (a : α) : l (u (l a)) = l a :=
  le_antisymm (l_u_le gc (l a)) (monotone_l gc (le_u_l gc a))

/-! ### The closure / kernel operators are genuine closure / interior operators -/

theorem cl_extensive (gc : GaloisConnection l u) (a : α) : a ≤ cl l u a := le_u_l gc a

theorem cl_monotone (gc : GaloisConnection l u) : Monotone (cl l u) :=
  fun _ _ h => monotone_u gc (monotone_l gc h)

theorem cl_idem (gc : GaloisConnection l u) (a : α) : cl l u (cl l u a) = cl l u a :=
  u_l_u gc (l a)

theorem ker_contracting (gc : GaloisConnection l u) (b : β) : ker l u b ≤ b := l_u_le gc b

theorem ker_monotone (gc : GaloisConnection l u) : Monotone (ker l u) :=
  fun _ _ h => monotone_l gc (monotone_u gc h)

theorem ker_idem (gc : GaloisConnection l u) (b : β) : ker l u (ker l u b) = ker l u b :=
  l_u_l gc (u b)

/-! ## Section 3 & 4: closed / coclosed elements and the fixed-point `OrderIso` -/

/-- The closed elements of `α`: those fixed by the closure operator `u ∘ l`. -/
abbrev Closed (l : α → β) (u : β → α) : Type u := {a : α // u (l a) = a}

/-- The coclosed elements of `β`: those fixed by the kernel operator `l ∘ u`. -/
abbrev Coclosed (l : α → β) (u : β → α) : Type v := {b : β // l (u b) = b}

/-- **Fundamental fixed-point correspondence.**  The left and right adjoints
restrict to mutually inverse, order-preserving bijections between the closed
elements of `α` and the coclosed elements of `β`. -/
def fixedPointOrderIso (gc : GaloisConnection l u) : Closed l u ≃o Coclosed l u where
  toFun a := ⟨l a.1, l_u_l gc a.1⟩
  invFun b := ⟨u b.1, u_l_u gc b.1⟩
  left_inv a := Subtype.ext a.2
  right_inv b := Subtype.ext b.2
  map_rel_iff' := by
    intro a a'
    constructor
    · intro h
      have h2 : u (l a.1) ≤ u (l a'.1) := monotone_u gc h
      rwa [a.2, a'.2] at h2
    · intro h
      exact monotone_l gc h

@[simp] theorem fixedPointOrderIso_apply (gc : GaloisConnection l u) (a : Closed l u) :
    (fixedPointOrderIso gc a : β) = l a.1 := rfl

@[simp] theorem fixedPointOrderIso_symm_apply (gc : GaloisConnection l u) (b : Coclosed l u) :
    ((fixedPointOrderIso gc).symm b : α) = u b.1 := rfl

/-! ## Section 5: the closed elements form a complete lattice

We use the closure-system structure rather than Knaster–Tarski:

* arbitrary infima of closed elements are closed (`closed_sInf_closed`);
* a least closed upper bound of a family is the closure of its ambient
  supremum (`closed_isLeastUB`).

The complete-lattice instance is then obtained from `completeLatticeOfInf`,
which only requires that every set of closed elements has an infimum that is a
greatest lower bound. -/

/-- Arbitrary infima of closed elements are closed. -/
theorem closed_sInf_closed (gc : GaloisConnection l u) {S : Set α}
    (hS : ∀ a ∈ S, u (l a) = a) : u (l (sInf S)) = sInf S := by
  refine le_antisymm (le_sInf ?_) (le_u_l gc _)
  intro x hx
  calc u (l (sInf S)) ≤ u (l x) := monotone_u gc (monotone_l gc (sInf_le hx))
    _ = x := hS x hx

/-- **Greatest closed lower bound.**  For a family `S` of closed elements, the
ambient infimum `sInf S` is itself closed, is a lower bound, and is the greatest
closed lower bound. -/
theorem closed_isGreatestLB (gc : GaloisConnection l u) {S : Set α}
    (hS : ∀ a ∈ S, u (l a) = a) :
    u (l (sInf S)) = sInf S ∧ (∀ a ∈ S, sInf S ≤ a) ∧
      ∀ c, u (l c) = c → (∀ a ∈ S, c ≤ a) → c ≤ sInf S :=
  ⟨closed_sInf_closed gc hS, fun _ ha => sInf_le ha, fun _ _ hc => le_sInf hc⟩

/-- **Least closed upper bound.**  For a family `S` of closed elements, the
closure `u (l (sSup S))` of the ambient supremum is closed, is an upper bound,
and is the least closed upper bound. -/
theorem closed_isLeastUB (gc : GaloisConnection l u) {S : Set α}
    (_hS : ∀ a ∈ S, u (l a) = a) :
    u (l (u (l (sSup S)))) = u (l (sSup S)) ∧ (∀ a ∈ S, a ≤ u (l (sSup S))) ∧
      ∀ c, u (l c) = c → (∀ a ∈ S, a ≤ c) → u (l (sSup S)) ≤ c := by
  refine ⟨u_l_u gc _, fun a ha => (le_sSup ha).trans (le_u_l gc _), ?_⟩
  intro c hc hub
  calc u (l (sSup S)) ≤ u (l c) := monotone_u gc (monotone_l gc (sSup_le hub))
    _ = c := hc

/-- The closed elements of `α` form a complete lattice.  Infima are inherited
from `α`; suprema are computed by closing the ambient supremum.  This uses
`completeLatticeOfInf`, not Knaster–Tarski. -/
noncomputable def Closed.completeLattice (gc : GaloisConnection l u) :
    CompleteLattice (Closed l u) :=
  letI : InfSet (Closed l u) :=
    ⟨fun T => ⟨sInf (Subtype.val '' T),
      closed_sInf_closed gc (by rintro a ⟨b, -, rfl⟩; exact b.2)⟩⟩
  completeLatticeOfInf _ (by
    intro T
    constructor
    · rintro t ht; exact sInf_le ⟨t, ht, rfl⟩
    · rintro c hc; apply le_sInf; rintro x ⟨t, ht, rfl⟩; exact hc ht)

/-! ## Section 6: the coclosed elements form a complete lattice (dual) -/

/-- Arbitrary suprema of coclosed elements are coclosed. -/
theorem coclosed_sSup_coclosed (gc : GaloisConnection l u) {T : Set β}
    (hT : ∀ b ∈ T, l (u b) = b) : l (u (sSup T)) = sSup T := by
  refine le_antisymm (l_u_le gc _) (sSup_le ?_)
  intro x hx
  calc x = l (u x) := (hT x hx).symm
    _ ≤ l (u (sSup T)) := monotone_l gc (monotone_u gc (le_sSup hx))

/-- **Least coclosed upper bound.**  For a family `T` of coclosed elements, the
ambient supremum `sSup T` is itself coclosed, is an upper bound, and is the
least coclosed upper bound. -/
theorem coclosed_isLeastUB (gc : GaloisConnection l u) {T : Set β}
    (hT : ∀ b ∈ T, l (u b) = b) :
    l (u (sSup T)) = sSup T ∧ (∀ b ∈ T, b ≤ sSup T) ∧
      ∀ c, l (u c) = c → (∀ b ∈ T, b ≤ c) → sSup T ≤ c :=
  ⟨coclosed_sSup_coclosed gc hT, fun _ hb => le_sSup hb, fun _ _ hub => sSup_le hub⟩

/-- **Greatest coclosed lower bound.**  For a family `T` of coclosed elements,
the kernel `l (u (sInf T))` of the ambient infimum is coclosed, is a lower
bound, and is the greatest coclosed lower bound. -/
theorem coclosed_isGreatestLB (gc : GaloisConnection l u) {T : Set β}
    (_hT : ∀ b ∈ T, l (u b) = b) :
    l (u (l (u (sInf T)))) = l (u (sInf T)) ∧ (∀ b ∈ T, l (u (sInf T)) ≤ b) ∧
      ∀ c, l (u c) = c → (∀ b ∈ T, c ≤ b) → c ≤ l (u (sInf T)) := by
  refine ⟨l_u_l gc _, fun b hb => (l_u_le gc _).trans (sInf_le hb), ?_⟩
  intro c hc hlb
  calc c = l (u c) := hc.symm
    _ ≤ l (u (sInf T)) := monotone_l gc (monotone_u gc (le_sInf hlb))

/-- The coclosed elements of `β` form a complete lattice.  Suprema are inherited
from `β`; infima are computed by applying the kernel to the ambient infimum.
This uses `completeLatticeOfSup`, not Knaster–Tarski. -/
noncomputable def Coclosed.completeLattice (gc : GaloisConnection l u) :
    CompleteLattice (Coclosed l u) :=
  letI : SupSet (Coclosed l u) :=
    ⟨fun T => ⟨sSup (Subtype.val '' T),
      coclosed_sSup_coclosed gc (by rintro a ⟨b, -, rfl⟩; exact b.2)⟩⟩
  completeLatticeOfSup _ (by
    intro T
    constructor
    · rintro t ht; exact le_sSup ⟨t, ht, rfl⟩
    · rintro c hc; apply sSup_le; rintro x ⟨t, ht, rfl⟩; exact hc ht)

end GaloisConnection

end GaloisConnectionFixedPoints