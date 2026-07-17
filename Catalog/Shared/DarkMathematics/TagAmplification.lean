import Mathlib

/-!
# Dark existence and finite tag amplification

This file isolates a precise structural obstruction to treating “darkness level” as an
intrinsic hierarchy.  Provability is intentionally a parameter: no soundness or consistency
assumption is hidden in the definitions.

A predicate is dark when the proof system proves that it has a witness, while proving none
of the instances selected by a naming map.  `AtLeast k P` says that `P` has at least `k`
distinct witnesses.

The main result, `dark_all_finite_levels`, shows that one dark existential can be amplified
to every positive finite level merely by adjoining a finite, mathematically irrelevant tag.
The only assumptions on provability are the two elementary syntactic transformations needed
for this coding: existential tag introduction and tag erasure for instances.  Consequently,
raw witness cardinality cannot support a strict “hardness” hierarchy without an additional
invariance requirement forbidding such definitional/tag extensions.
-/

namespace DarkMathematics

/-- There are at least `k` distinct values satisfying `P`. -/
def AtLeast {α : Type*} (k : ℕ) (P : α → Prop) : Prop :=
  ∃ s : Finset α, s.card = k ∧ ∀ x ∈ s, P x

/-- Darkness relative to a proof predicate and a chosen sequence of named objects. -/
def Dark {α : Type*} (Prov : Prop → Prop) (name : ℕ → α) (P : α → Prop) : Prop :=
  Prov (∃ x, P x) ∧ ∀ n, ¬ Prov (P (name n))

/-- Level-`k` darkness: provable existence of `k` distinct witnesses, but no named instance
is provable. -/
def DarkLevel {α : Type*} (Prov : Prop → Prop) (name : ℕ → α)
    (k : ℕ) (P : α → Prop) : Prop :=
  Prov (AtLeast k P) ∧ ∀ n, ¬ Prov (P (name n))

/-- Add one of `k+1` finite tags to every named object. -/
def taggedName {α : Type*} (k : ℕ) (name : ℕ → α) (n : ℕ) : Fin (k + 1) × α :=
  (⟨n % (k + 1), Nat.mod_lt n (Nat.succ_pos k)⟩, name (n / (k + 1)))

/-
The tagged naming map reaches every finite tag over every named payload.
-/
theorem taggedName_surjective_over_names {α : Type*} (k : ℕ) (name : ℕ → α)
    (i : Fin (k + 1)) (n : ℕ) :
    ∃ code, taggedName k name code = (i, name n) := by
  refine' ⟨ n * ( k + 1 ) + i, _ ⟩;
  unfold taggedName; simp +decide [Nat.add_mod, Nat.mod_eq_of_lt i.isLt];
  rw [ Nat.add_div ] <;> norm_num [ Nat.div_eq_of_lt i.2 ];
  rw [ if_neg ( by rw [ Nat.mod_eq_of_lt ] <;> linarith [ Fin.is_lt i ] ) ] ; simp +decide

/-- Repeating one witness under every finite tag creates exactly `k+1` distinct witnesses. -/
theorem exists_implies_atLeast_tagged {α : Type*} (k : ℕ) (P : α → Prop) :
    (∃ x, P x) → AtLeast (k + 1) (fun z : Fin (k + 1) × α => P z.2) := by
  intro h;
  fconstructor;
  convert Finset.univ.image ( fun i : Fin ( k + 1 ) => ( i, Classical.choose h ) ) using 1;
  all_goals try exact Classical.decEq _;
  simp +decide [ Finset.card_image_of_injective, Function.Injective ];
  exact Classical.choose_spec h

/-
The tagged predicate has a witness exactly when the original predicate does.
-/
theorem exists_tagged_iff {α : Type*} (k : ℕ) (P : α → Prop) :
    (∃ z : Fin (k + 1) × α, P z.2) ↔ ∃ x, P x := by
  exact ⟨ fun ⟨ z, hz ⟩ => ⟨ z.2, hz ⟩, fun ⟨ x, hx ⟩ => ⟨ ( 0, x ), hx ⟩ ⟩

/-- The elementary proof transformations required for tag amplification.

For an ordinary recursively presented deductive calculus these are uniform primitive
syntactic operation on derivations: `liftExistence` duplicates a witness existentially
under all finite tags. It is stated explicitly rather than smuggling a particular
arithmetization of PA into the development. -/
structure SupportsFiniteTagging (Prov : Prop → Prop) (α : Type*) : Prop where
  liftExistence : ∀ (k : ℕ) (P : α → Prop),
    Prov (∃ x, P x) → Prov (AtLeast (k + 1) (fun z : Fin (k + 1) × α => P z.2))

/-
**Finite tag amplification.** A level-1 dark existential produces a level-`k+1`
dark predicate by adding `k+1` irrelevant tags.
-/
theorem dark_tag_amplification {α : Type*} {Prov : Prop → Prop}
    (rules : SupportsFiniteTagging Prov α) (name : ℕ → α) (P : α → Prop)
    (h : Dark Prov name P) (k : ℕ) :
    DarkLevel Prov (taggedName k name) (k + 1)
      (fun z : Fin (k + 1) × α => P z.2) := by
  refine ⟨rules.liftExistence k P h.1, ?_⟩
  intro n hn
  exact h.2 (n / (k + 1)) hn

/-
One and the same dark existential yields tagged dark predicates at every positive
finite level.  This is the promised collapse of the naive cardinality hierarchy.
-/
theorem dark_all_finite_levels {α : Type*} {Prov : Prop → Prop}
    (rules : SupportsFiniteTagging Prov α) (name : ℕ → α) (P : α → Prop)
    (h : Dark Prov name P) :
    ∀ k : ℕ, DarkLevel Prov (taggedName k name) (k + 1)
      (fun z : Fin (k + 1) × α => P z.2) := by
  exact fun k => dark_tag_amplification rules name P h k

/-
Explicit versions of levels one, two, and three. All arise uniformly from one dark
existential rather than requiring three unrelated combinatorial principles.
-/
theorem dark_levels_one_two_three {α : Type*} {Prov : Prop → Prop}
    (rules : SupportsFiniteTagging Prov α) (name : ℕ → α) (P : α → Prop)
    (h : Dark Prov name P) :
    DarkLevel Prov (taggedName 0 name) 1 (fun z : Fin 1 × α => P z.2) ∧
    DarkLevel Prov (taggedName 1 name) 2 (fun z : Fin 2 × α => P z.2) ∧
    DarkLevel Prov (taggedName 2 name) 3 (fun z : Fin 3 × α => P z.2) := by
  exact ⟨ dark_tag_amplification rules name P h 0, dark_tag_amplification rules name P h 1, dark_tag_amplification rules name P h 2 ⟩

/-
A proof system with named witness extraction cannot have a dark predicate.
-/
theorem no_dark_of_named_witness_extraction {α : Type*} {Prov : Prop → Prop}
    (name : ℕ → α) (P : α → Prop)
    (extract : Prov (∃ x, P x) → ∃ n, Prov (P (name n))) :
    ¬ Dark Prov name P := by
  exact fun h => h.2 _ ( extract h.1 |> Classical.choose_spec )

/-- Monotonicity of the underlying mathematical witness-count notion. -/
theorem atLeast_mono {α : Type*} {P : α → Prop} {m n : ℕ}
    (hmn : m ≤ n) (h : AtLeast n P) : AtLeast m P := by
  obtain ⟨ s, rfl, hs ⟩ := h;
  exact Exists.imp ( by aesop ) ( Finset.exists_subset_card_eq hmn )

/-
If the proof predicate admits the corresponding downward transformation, darkness at
level `n` descends to every smaller level `m`.
-/
theorem darkLevel_mono {α : Type*} {Prov : Prop → Prop} {name : ℕ → α}
    {P : α → Prop} {m n : ℕ} (hmn : m ≤ n)
    (lower : m ≤ n → Prov (AtLeast n P) → Prov (AtLeast m P))
    (h : DarkLevel Prov name n P) : DarkLevel Prov name m P := by
  exact ⟨lower hmn h.1, h.2⟩

end DarkMathematics