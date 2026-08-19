/-
# Counting equivalence relations: the Bell numbers

Mathlib defines `Nat.bell` by the binomial recurrence
`bell (n+1) = ∑ i : Fin (n+1), (n.choose i) * bell (n - i)` and records as a TODO
that it counts the partitions of an `n`-element set.  This file proves exactly
that statement in the form

`KernelPattern.numSetoid n = Nat.bell n`,  where  `numSetoid n = Nat.card (Setoid (Fin n))`

is the number of equivalence relations on `Fin n`.

The proof is the classical "block of the distinguished point" decomposition, carried
out over `Option β`: an equivalence relation on `Option β` is the same data as a
subset `S ⊆ β` (the partners of the extra point `none`) together with an arbitrary
equivalence relation on the complement of `S`.  This is formalised as a fibration
`blockOfNone : Setoid (Option β) → Finset β` whose fibre over `S` is canonically
equivalent to `Setoid {b // b ∉ S}`.
-/
import Mathlib

namespace KernelPattern

open Finset

variable {α β : Type*}

/-! ## Finiteness and transport -/

instance instFiniteSetoid (α : Type*) [Finite α] : Finite (Setoid α) := by
  have hinj : Function.Injective (fun s : Setoid α => (fun a b => s a b : α → α → Prop)) := by
    intro s t h
    exact Setoid.ext fun a b => Iff.of_eq (congrFun (congrFun h a) b)
  exact Finite.of_injective _ hinj

/-- Transport of equivalence relations along a bijection of the underlying types. -/
def setoidCongr (e : α ≃ β) : Setoid α ≃ Setoid β where
  toFun s := s.comap e.symm
  invFun t := t.comap e
  left_inv s := by
    refine Setoid.ext fun a b => ?_
    simp [Setoid.comap, Function.onFun]
  right_inv t := by
    refine Setoid.ext fun a b => ?_
    simp [Setoid.comap, Function.onFun]

theorem natCard_setoid_congr (e : α ≃ β) : Nat.card (Setoid α) = Nat.card (Setoid β) :=
  Nat.card_congr (setoidCongr e)

/-- The number of equivalence relations on an `n`-element set. -/
noncomputable def numSetoid (n : ℕ) : ℕ := Nat.card (Setoid (Fin n))

theorem natCard_setoid_eq_numSetoid (α : Type*) [Fintype α] :
    Nat.card (Setoid α) = numSetoid (Fintype.card α) :=
  natCard_setoid_congr (Fintype.equivFin α)

/-! ## The block of the distinguished point -/

variable [Fintype β]

open scoped Classical in
/-- The set of points of `β` equivalent to the extra point `none`. -/
noncomputable def blockOfNone (s : Setoid (Option β)) : Finset β :=
  univ.filter fun b => s (some b) none

theorem mem_blockOfNone {s : Setoid (Option β)} {b : β} :
    b ∈ blockOfNone s ↔ s (some b) none := by
  classical
  simp [blockOfNone]

variable [DecidableEq β]

/-- The relation on `Option β` glued from a subset `S` (the block of `none`) and an
equivalence relation on the complement of `S`. -/
def optRel (S : Finset β) (t : Setoid {b : β // b ∉ S}) : Option β → Option β → Prop
  | none, none => True
  | none, some b => b ∈ S
  | some a, none => a ∈ S
  | some a, some b =>
      if ha : a ∈ S then b ∈ S
      else if hb : b ∈ S then False else t ⟨a, ha⟩ ⟨b, hb⟩

variable {S : Finset β} {t : Setoid {b : β // b ∉ S}} {a b c : β}

omit [Fintype β] in
theorem optRel_none_none : optRel S t none none := trivial

omit [Fintype β] in
theorem optRel_none_some : optRel S t none (some b) ↔ b ∈ S := Iff.rfl

omit [Fintype β] in
theorem optRel_some_none : optRel S t (some a) none ↔ a ∈ S := Iff.rfl

omit [Fintype β] in
theorem optRel_some_some :
    optRel S t (some a) (some b) =
      if ha : a ∈ S then b ∈ S else if hb : b ∈ S then False else t ⟨a, ha⟩ ⟨b, hb⟩ := rfl

omit [Fintype β] in
theorem optRel_some_some_of_mem (ha : a ∈ S) :
    optRel S t (some a) (some b) ↔ b ∈ S := by
  rw [optRel_some_some, dif_pos ha]

omit [Fintype β] in
theorem optRel_some_some_of_notMem (ha : a ∉ S) (hb : b ∉ S) :
    optRel S t (some a) (some b) ↔ t ⟨a, ha⟩ ⟨b, hb⟩ := by
  rw [optRel_some_some, dif_neg ha, dif_neg hb]

omit [Fintype β] in
theorem optRel_some_some_notMem_mem (ha : a ∉ S) (hb : b ∈ S) :
    ¬ optRel S t (some a) (some b) := by
  rw [optRel_some_some, dif_neg ha, dif_pos hb]
  exact id

omit [Fintype β] in
theorem optRel_equivalence (S : Finset β) (t : Setoid {b : β // b ∉ S}) :
    Equivalence (optRel S t) := by
  refine ⟨?_, ?_, ?_⟩
  · rintro (_ | a)
    · exact optRel_none_none
    · by_cases ha : a ∈ S
      · exact (optRel_some_some_of_mem ha).2 ha
      · exact (optRel_some_some_of_notMem ha ha).2 (t.refl _)
  · rintro (_ | a) (_ | b) h
    · exact optRel_none_none
    · exact optRel_some_none.2 (optRel_none_some.1 h)
    · exact optRel_none_some.2 (optRel_some_none.1 h)
    · by_cases ha : a ∈ S
      · by_cases hb : b ∈ S
        · exact (optRel_some_some_of_mem hb).2 ha
        · exact absurd ((optRel_some_some_of_mem ha).1 h) hb
      · by_cases hb : b ∈ S
        · exact absurd h (optRel_some_some_notMem_mem ha hb)
        · exact (optRel_some_some_of_notMem hb ha).2
            (t.symm ((optRel_some_some_of_notMem ha hb).1 h))
  · rintro (_ | a) (_ | b) (_ | c) h h'
    · exact optRel_none_none
    · exact h'
    · exact optRel_none_none
    · -- none, some b, some c
      have hb : b ∈ S := optRel_none_some.1 h
      exact optRel_none_some.2 ((optRel_some_some_of_mem hb).1 h')
    · exact h
    · -- some a, none, some c
      exact (optRel_some_some_of_mem (optRel_some_none.1 h)).2 (optRel_none_some.1 h')
    · -- some a, some b, none
      have hb : b ∈ S := optRel_some_none.1 h'
      by_cases ha : a ∈ S
      · exact optRel_some_none.2 ha
      · exact absurd h (optRel_some_some_notMem_mem ha hb)
    · -- some a, some b, some c
      by_cases ha : a ∈ S
      · have hb : b ∈ S := (optRel_some_some_of_mem ha).1 h
        exact (optRel_some_some_of_mem ha).2 ((optRel_some_some_of_mem hb).1 h')
      · by_cases hb : b ∈ S
        · exact absurd h (optRel_some_some_notMem_mem ha hb)
        · by_cases hc : c ∈ S
          · exact absurd h' (optRel_some_some_notMem_mem hb hc)
          · exact (optRel_some_some_of_notMem ha hc).2
              (t.trans ((optRel_some_some_of_notMem ha hb).1 h)
                ((optRel_some_some_of_notMem hb hc).1 h'))

/-- The equivalence relation on `Option β` glued from `S` and `t`. -/
def optSetoid (S : Finset β) (t : Setoid {b : β // b ∉ S}) : Setoid (Option β) :=
  ⟨optRel S t, optRel_equivalence S t⟩

omit [Fintype β] in
theorem optSetoid_apply (S : Finset β) (t : Setoid {b : β // b ∉ S}) (x y : Option β) :
    optSetoid S t x y ↔ optRel S t x y := Iff.rfl

theorem blockOfNone_optSetoid (S : Finset β) (t : Setoid {b : β // b ∉ S}) :
    blockOfNone (optSetoid S t) = S := by
  ext b
  rw [mem_blockOfNone, optSetoid_apply]
  exact optRel_some_none

/-- The restriction of an equivalence relation on `Option β` to the complement of the
block of `none`. -/
def restrictSetoid (S : Finset β) (s : Setoid (Option β)) : Setoid {b : β // b ∉ S} :=
  s.comap fun b => some b.1

omit [Fintype β] [DecidableEq β] in
theorem restrictSetoid_apply (S : Finset β) (s : Setoid (Option β)) (p q : {b : β // b ∉ S}) :
    restrictSetoid S s p q ↔ s (some p.1) (some q.1) := Iff.rfl

/-- **Fibre description**: an equivalence relation on `Option β` whose `none`-block is
`S` is the same data as an equivalence relation on the complement of `S`. -/
def fiberEquiv (S : Finset β) :
    {s : Setoid (Option β) // blockOfNone s = S} ≃ Setoid {b : β // b ∉ S} where
  toFun s := restrictSetoid S s.1
  invFun t := ⟨optSetoid S t, blockOfNone_optSetoid S t⟩
  left_inv := by
    rintro ⟨s, hs⟩
    have hmem : ∀ b : β, b ∈ S ↔ s (some b) none := by
      intro b
      rw [← hs]
      exact mem_blockOfNone
    apply Subtype.ext
    refine Setoid.ext ?_
    rintro (_ | x) (_ | y)
    · exact ⟨fun _ => s.refl _, fun _ => optRel_none_none⟩
    · rw [optSetoid_apply, optRel_none_some, hmem y]
      exact ⟨fun h => s.symm h, fun h => s.symm h⟩
    · rw [optSetoid_apply, optRel_some_none, hmem x]
    · rw [optSetoid_apply]
      by_cases hx : x ∈ S
      · rw [optRel_some_some_of_mem hx]
        constructor
        · intro hy
          exact s.trans ((hmem x).1 hx) (s.symm ((hmem y).1 hy))
        · intro h
          exact (hmem y).2 (s.trans (s.symm h) ((hmem x).1 hx))
      · by_cases hy : y ∈ S
        · constructor
          · exact fun h => absurd h (optRel_some_some_notMem_mem hx hy)
          · intro h
            exact absurd ((hmem x).2 (s.trans h ((hmem y).1 hy))) hx
        · rw [optRel_some_some_of_notMem hx hy]
          exact restrictSetoid_apply S s ⟨x, hx⟩ ⟨y, hy⟩
  right_inv := by
    intro t
    refine Setoid.ext fun p q => ?_
    rw [restrictSetoid_apply, optSetoid_apply, optRel_some_some_of_notMem p.2 q.2]

/-! ## The recurrence -/

theorem natCard_setoid_option :
    Nat.card (Setoid (Option β)) = ∑ S : Finset β, Nat.card (Setoid {b : β // b ∉ S}) := by
  classical
  have h1 : Nat.card (Setoid (Option β))
      = Nat.card (Σ S : Finset β, {s : Setoid (Option β) // blockOfNone s = S}) :=
    (Nat.card_congr (Equiv.sigmaFiberEquiv blockOfNone)).symm
  rw [h1, Nat.card_sigma]
  exact Finset.sum_congr rfl fun S _ => Nat.card_congr (fiberEquiv S)

theorem natCard_setoid_compl (S : Finset β) :
    Nat.card (Setoid {b : β // b ∉ S}) = numSetoid (Fintype.card β - S.card) := by
  classical
  rw [natCard_setoid_eq_numSetoid]
  congr 1
  have h1 : Fintype.card {b : β // b ∈ S} = S.card := Fintype.card_coe S
  rw [Fintype.card_subtype_compl, h1]

theorem numSetoid_succ (n : ℕ) :
    numSetoid (n + 1) = ∑ k ∈ range (n + 1), n.choose k * numSetoid (n - k) := by
  classical
  have h0 : numSetoid (n + 1) = Nat.card (Setoid (Option (Fin n))) :=
    natCard_setoid_congr (finSuccEquiv n)
  rw [h0, natCard_setoid_option]
  have hterm : ∀ S : Finset (Fin n), Nat.card (Setoid {b : Fin n // b ∉ S})
      = numSetoid (n - S.card) := by
    intro S
    rw [natCard_setoid_compl]
    simp
  rw [Finset.sum_congr rfl fun S (_ : S ∈ (univ : Finset (Finset (Fin n)))) => hterm S]
  have hpow : ∑ S ∈ (univ : Finset (Fin n)).powerset, numSetoid (n - S.card)
      = ∑ j ∈ range ((univ : Finset (Fin n)).card + 1),
          ∑ S ∈ Finset.powersetCard j (univ : Finset (Fin n)), numSetoid (n - S.card) :=
    Finset.sum_powerset _ _
  rw [Finset.powerset_univ] at hpow
  rw [hpow, Finset.card_univ, Fintype.card_fin]
  refine Finset.sum_congr rfl fun j _ => ?_
  have hconst : ∀ S ∈ Finset.powersetCard j (univ : Finset (Fin n)),
      numSetoid (n - S.card) = numSetoid (n - j) := by
    intro S hS
    rw [(Finset.mem_powersetCard.mp hS).2]
  rw [Finset.sum_congr rfl hconst, Finset.sum_const, Finset.card_powersetCard,
    Finset.card_univ, Fintype.card_fin, smul_eq_mul]

theorem numSetoid_zero : numSetoid 0 = 1 := by
  have hsub : Subsingleton (Setoid (Fin 0)) := ⟨fun s t => Setoid.ext fun a => a.elim0⟩
  have hne : Nonempty (Setoid (Fin 0)) := ⟨⊥⟩
  rw [numSetoid, Nat.card_eq_one_iff_unique]
  exact ⟨hsub, hne⟩

/-- **Main counting theorem**: the number of equivalence relations on an `n`-element
set is the `n`-th Bell number. (This is the statement recorded as a TODO in
Mathlib's `Nat.bell`.) -/
theorem numSetoid_eq_bell (n : ℕ) : numSetoid n = Nat.bell n := by
  induction n using Nat.strong_induction_on with
  | _ n ih =>
    match n, ih with
    | 0, _ => simpa using numSetoid_zero
    | (m + 1), ih =>
      rw [numSetoid_succ, Nat.bell_succ,
        Fin.sum_univ_eq_sum_range (fun k => m.choose k * Nat.bell (m - k)) (m + 1)]
      refine Finset.sum_congr rfl fun k hk => ?_
      have hlt : m - k < m + 1 := by omega
      rw [ih _ hlt]

end KernelPattern