import Mathlib

/-!
# The topology of argumentation, III: the simplicial complex `K(AF)` and its Euler characteristic

This file is **self-contained**.  It makes precise the central geometric claim
about argumentation frameworks and settles the associated Euler-characteristic
conjecture.

## The complex `K(AF)`

For an argumentation framework `(A, R)` the *conflict-free* subsets of `A` are
**downward closed**: any subset of a conflict-free set is conflict-free.  This is
exactly the defining axiom of an *abstract simplicial complex*.  We record this
as `conflictFreeComplex R : ASC A`.  (Note: it is the **conflict-free sets**, not
the preferred extensions, that form the complex — preferred extensions are the
*maximal* admissible sets and are not downward closed, so the naive reading of
the informal conjecture does not typecheck; `conflictFreeComplex` is the correct
carrier of the topology.)

## Euler characteristic

`eulerChar F` is the (unreduced) Euler characteristic of a finite family of
faces, `∑_{∅ ≠ s ∈ F} (-1)^(dim s)` with `dim s = |s| - 1`.  We prove
`eulerChar_powerset`: the full simplex on a nonempty vertex set is contractible
(`χ = 1`), and empty otherwise.

## The Euler = semantics conjecture is false

The informal conjecture asserts

  `χ(K(AF)) = |preferred extensions| − |grounded extension|`.

We refute it with an explicit witness: the attack-free framework on a single
argument (`R0` on `Fin 1`).  There `χ(K) = 1` (a point), there is exactly one
preferred extension, and the grounded extension has size `1`, so the right-hand
side is `1 − 1 = 0 ≠ 1`.  See `euler_semantics_conjecture_false`.
-/

namespace ArgTop

open Finset

variable {A : Type*}

/-- `S` is conflict-free: no argument in `S` attacks another in `S`. -/
def ConflictFree (R : A → A → Prop) (S : Set A) : Prop := ∀ a ∈ S, ∀ b ∈ S, ¬ R a b

/-- Conflict-free sets are downward closed. -/
theorem conflictFree_subset (R : A → A → Prop) {S T : Set A} (h : S ⊆ T)
    (hT : ConflictFree R T) : ConflictFree R S :=
  fun a ha b hb => hT a (h ha) b (h hb)

/-- An **abstract simplicial complex** on a vertex type `V`: a downward-closed
family of finite *faces*. -/
structure ASC (V : Type*) where
  /-- The set of faces (simplices) of the complex. -/
  faces : Set (Finset V)
  /-- The faces are downward closed: any subset of a face is a face. -/
  downClosed : ∀ ⦃s⦄, s ∈ faces → ∀ ⦃t⦄, t ⊆ s → t ∈ faces

/-- **`K(AF)`: the conflict-free subsets of an argumentation framework form an
abstract simplicial complex** on the vertex set of arguments. -/
def conflictFreeComplex (R : A → A → Prop) : ASC A where
  faces := {s : Finset A | ConflictFree R (↑s : Set A)}
  downClosed := by
    intro s hs t hts
    exact conflictFree_subset R (Finset.coe_subset.mpr hts) hs

/-- The empty set is always a face of `K(AF)`. -/
theorem empty_mem_conflictFreeComplex (R : A → A → Prop) :
    (∅ : Finset A) ∈ (conflictFreeComplex R).faces := by
  simp only [conflictFreeComplex, Set.mem_setOf_eq, Finset.coe_empty]
  intro a ha; exact absurd ha (Set.notMem_empty a)

/-- An argument `a` is a *vertex* of `K(AF)` (i.e. `{a}` is a face) iff it does
not attack itself.  Thus self-attacking arguments are exactly the "phantom"
vertices excluded from the topology. -/
theorem singleton_mem_conflictFreeComplex (R : A → A → Prop) (a : A) :
    ({a} : Finset A) ∈ (conflictFreeComplex R).faces ↔ ¬ R a a := by
  simp only [conflictFreeComplex, Set.mem_setOf_eq, Finset.coe_singleton]
  constructor
  · intro h haa; exact h a rfl a rfl haa
  · intro h x hx y hy
    rw [Set.mem_singleton_iff] at hx hy; subst hx; subst hy; exact h

/-- (Unreduced) **Euler characteristic** of a finite family of faces:
`∑_{∅ ≠ s ∈ F} (-1)^(dim s)` where the dimension of `s` is `|s| - 1`. -/
def eulerChar [DecidableEq A] (F : Finset (Finset A)) : ℤ :=
  ∑ s ∈ F, if s = ∅ then 0 else (-1) ^ (s.card - 1)

/-- **The full simplex is contractible.**  The Euler characteristic of the
complex of *all* subsets of a vertex set `X` is `1` when `X` is nonempty (a
contractible simplex) and `0` when `X` is empty (the void complex). -/
theorem eulerChar_powerset [DecidableEq A] (X : Finset A) :
    eulerChar (X.powerset) = if X = ∅ then 0 else 1 := by
  unfold eulerChar
  have key : ∀ s : Finset A, (if s = ∅ then (0 : ℤ) else (-1) ^ (s.card - 1))
      = -((-1) ^ s.card) + (if s = ∅ then 1 else 0) := by
    intro s
    by_cases hs : s = ∅
    · simp [hs]
    · have hc : 1 ≤ s.card := Finset.one_le_card.mpr (Finset.nonempty_of_ne_empty hs)
      rw [if_neg hs, if_neg hs]
      have h2 : s.card - 1 + 1 = s.card := Nat.sub_add_cancel hc
      calc (-1 : ℤ) ^ (s.card - 1) = -((-1) ^ (s.card - 1) * (-1)) := by ring
        _ = -((-1) ^ (s.card - 1 + 1)) := by rw [pow_succ]
        _ = -((-1) ^ s.card) + 0 := by rw [h2]; ring
  rw [Finset.sum_congr rfl (fun s _ => key s), Finset.sum_add_distrib,
      Finset.sum_neg_distrib, Finset.sum_powerset_neg_one_pow_card]
  have hemp : ∑ s ∈ X.powerset, (if s = ∅ then (1 : ℤ) else 0) = 1 := by
    rw [Finset.sum_ite_eq' X.powerset ∅ (fun _ => (1 : ℤ))]; simp
  rw [hemp]; by_cases hX : X = ∅ <;> simp [hX]

open Classical in
/-- The finite face set of `K(AF)` for a finite framework. -/
noncomputable def facesFinset [Fintype A] (R : A → A → Prop) : Finset (Finset A) :=
  Finset.univ.filter (fun s => ConflictFree R (↑s : Set A))

/-!
## Refuting the Euler = semantics conjecture

We now set up the machinery needed to state the conjecture (`Defends`,
`Admissible`, `Preferred`, `groundedExt`) and produce the explicit
counterexample.
-/

/-- `S` defends `a`: every attacker of `a` is counter-attacked from `S`. -/
def Defends (R : A → A → Prop) (S : Set A) (a : A) : Prop :=
  ∀ b, R b a → ∃ c ∈ S, R c b

/-- `S` is admissible: conflict-free and defends all its members. -/
def Admissible (R : A → A → Prop) (S : Set A) : Prop :=
  ConflictFree R S ∧ ∀ a ∈ S, Defends R S a

/-- The characteristic (defense) operator. -/
def charF (R : A → A → Prop) (S : Set A) : Set A := {a | Defends R S a}

/-- `S` is a preferred extension: a maximal admissible set. -/
def Preferred (R : A → A → Prop) (S : Set A) : Prop :=
  Admissible R S ∧ ∀ T, Admissible R T → S ⊆ T → T = S

theorem charF_mono (R : A → A → Prop) {S T : Set A} (h : S ⊆ T) :
    charF R S ⊆ charF R T := by
  intro a ha b hb; obtain ⟨c, hc, hcb⟩ := ha b hb; exact ⟨c, h hc, hcb⟩

/-- The defense operator as a monotone self-map of `Set A`. -/
def charFHom (R : A → A → Prop) : Set A →o Set A := ⟨charF R, fun _ _ h => charF_mono R h⟩

/-- The grounded extension: least fixed point of the defense operator. -/
noncomputable def groundedExt (R : A → A → Prop) : Set A := OrderHom.lfp (charFHom R)

theorem charF_groundedExt (R : A → A → Prop) : charF R (groundedExt R) = groundedExt R :=
  OrderHom.map_lfp (charFHom R)

/-- The attack-free framework on a single argument. -/
def R0 : Fin 1 → Fin 1 → Prop := fun _ _ => False

theorem charF_R0 (S : Set (Fin 1)) : charF R0 S = Set.univ := by
  ext a
  simp only [charF, Defends, R0, Set.mem_setOf_eq, Set.mem_univ, iff_true]
  intro b hb; exact hb.elim

theorem grounded_R0 : groundedExt R0 = Set.univ := by
  have h := charF_groundedExt R0
  rw [charF_R0] at h; exact h.symm

theorem admissible_R0 (S : Set (Fin 1)) : Admissible R0 S :=
  ⟨fun _ _ _ _ h => h.elim, fun _ _ _ hb => hb.elim⟩

theorem preferred_R0_iff (S : Set (Fin 1)) : Preferred R0 S ↔ S = Set.univ := by
  constructor
  · rintro ⟨_, hmax⟩
    exact (hmax Set.univ (admissible_R0 _) (Set.subset_univ S)).symm
  · rintro rfl
    exact ⟨admissible_R0 _, fun T _ h => Set.univ_subset_iff.mp h⟩

theorem preferred_ncard_R0 : Set.ncard {S : Set (Fin 1) | Preferred R0 S} = 1 := by
  have : {S : Set (Fin 1) | Preferred R0 S} = {Set.univ} := by
    ext S; simp [preferred_R0_iff]
  rw [this]; exact Set.ncard_singleton _

theorem grounded_ncard_R0 : Set.ncard (groundedExt R0) = 1 := by
  rw [grounded_R0, Set.ncard_univ]; simp

theorem euler_R0 : eulerChar (facesFinset R0) = 1 := by
  have hfaces : facesFinset R0 = Finset.univ := by
    classical
    apply Finset.filter_true_of_mem
    intro _ _ _ _ _ _ h; exact h.elim
  rw [hfaces, ← Finset.powerset_univ, eulerChar_powerset, if_neg]
  exact Finset.univ_nonempty.ne_empty

/-- **The Euler = semantics conjecture is false.**  For the attack-free
framework `R0` on a single argument, the topological Euler characteristic of
`K(AF)` is `1` (the complex is a point), yet `|preferred extensions| − |grounded
extension| = 1 − 1 = 0`.  Hence the proposed identity
`χ(K(AF)) = |preferred extensions| − |grounded extension|` does not hold in
general. -/
theorem euler_semantics_conjecture_false :
    (eulerChar (facesFinset R0) : ℤ) ≠
      (Set.ncard {S : Set (Fin 1) | Preferred R0 S} : ℤ)
        - (Set.ncard (groundedExt R0) : ℤ) := by
  rw [euler_R0, preferred_ncard_R0, grounded_ncard_R0]
  norm_num

end ArgTop