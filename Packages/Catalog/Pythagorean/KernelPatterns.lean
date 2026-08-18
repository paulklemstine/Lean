import Mathlib

/-!
# Kernel patterns: complete invariants for the permutation action on tuples

For a tuple `f : Fin n → α`, its *kernel* (equality pattern) is the relation
`Ker f i j ↔ f i = f j`, equivalently the set partition of the index set `Fin n`
into the fibres of `f`.

This file develops:

* `KernelPattern.Ker`, the equality pattern, and `KernelPattern.canon`, a *computable*
  canonical form (the "restricted growth" normal form `canon f i = min {j // f j = f i}`);
* the invariance theorem: the kernel is invariant under post-composition by an injective
  map, in particular under the action of the symmetric group `Equiv.Perm β`;
* the completeness theorem `KernelPattern.exists_perm_iff_ker_eq`: over a *finite*
  codomain, two tuples lie in the same `Equiv.Perm β`-orbit **iff** they have the same
  kernel.  Thus the kernel is a complete invariant of the orbit, and `canon` is a
  complete computable invariant;
* the enumeration `KernelPattern.Patterns n` of all kernel patterns of length `n`, whose
  cardinalities are the Bell numbers `1, 1, 2, 5, 15, 52` (OEIS A000110), matched against
  Mathlib's `Nat.bell` and verified by `decide`;
* the orbit-counting corollary: the number of `Equiv.Perm (Fin n)`-orbits on `(Fin n)^n`
  is `Nat.bell n` for `n ≤ 5`.
-/

namespace KernelPattern

variable {n : ℕ} {α β γ : Type*}

/-! ## The equality pattern -/

/-- The **kernel** (equality pattern) of a tuple `f : Fin n → α`: the relation recording
which coordinates carry equal entries. -/
def Ker (f : Fin n → α) : Fin n → Fin n → Prop := fun i j => f i = f j

theorem ker_apply (f : Fin n → α) (i j : Fin n) : Ker f i j ↔ f i = f j := Iff.rfl

theorem ker_eq_iff {f : Fin n → α} {g : Fin n → β} :
    Ker f = Ker g ↔ ∀ i j, f i = f j ↔ g i = g j := by
  constructor
  · intro h i j
    exact iff_of_eq (congrFun (congrFun h i) j)
  · intro h
    funext i j
    exact propext (h i j)

theorem ker_refl (f : Fin n → α) (i : Fin n) : Ker f i i := rfl

theorem ker_symm {f : Fin n → α} {i j : Fin n} (h : Ker f i j) : Ker f j i := h.symm

theorem ker_trans {f : Fin n → α} {i j k : Fin n} (h₁ : Ker f i j) (h₂ : Ker f j k) :
    Ker f i k := h₁.trans h₂

/-- The kernel is an equivalence relation on the index set. -/
theorem ker_equivalence (f : Fin n → α) : Equivalence (Ker f) :=
  ⟨ker_refl f, ker_symm, ker_trans⟩

/-! ## Invariance -/

/-- Post-composing with an **injective** map does not change the equality pattern.
This is the invariance half of the "complete invariant" statement. -/
theorem ker_comp_of_injective {σ : α → β} (hσ : Function.Injective σ) (f : Fin n → α) :
    Ker (σ ∘ f) = Ker f := by
  funext i j
  exact propext ⟨fun h => hσ h, fun h => congrArg σ h⟩

/-- The kernel is a `G`-invariant for `G = Equiv.Perm α` acting on tuples by
post-composition. -/
theorem ker_perm_smul (σ : Equiv.Perm α) (f : Fin n → α) : Ker (σ • f) = Ker f :=
  ker_comp_of_injective σ.injective f

/-! ## The computable canonical form -/

section Canon

variable [DecidableEq α]

/-- The canonical form of a tuple: `canon f i` is the *least* index `j` with `f j = f i`.
It is a computable, `Fin n`-valued encoding of the kernel of `f` (a restricted growth
function). -/
def canon (f : Fin n → α) (i : Fin n) : Fin n :=
  ((List.finRange n).find? (fun j => decide (f j = f i))).getD i

@[simp] theorem apply_canon (f : Fin n → α) (i : Fin n) : f (canon f i) = f i := by
  unfold canon
  cases h : (List.finRange n).find? (fun j => decide (f j = f i)) with
  | none => simp
  | some a => simpa using List.find?_some h

/-- `canon f i` is a lower bound for all indices in the fibre of `i`. -/
theorem canon_le {f : Fin n → α} {i j : Fin n} (h : f j = f i) : canon f i ≤ j := by
  unfold canon
  cases hf : (List.finRange n).find? (fun k => decide (f k = f i)) with
  | none =>
      exact absurd (by simpa using h) (by simpa using (List.find?_eq_none.1 hf j (by simp)))
  | some a =>
      rw [List.find?_eq_some_iff_getElem] at hf
      obtain ⟨-, k, hk, hget, hlt⟩ := hf
      simp only [Option.getD_some]
      by_contra hcon
      push_neg at hcon
      have hak : a.val = k := by
        rw [← hget, List.getElem_finRange]; rfl
      have hja : j.val < a.val := hcon
      have hjk : j.val < k := by omega
      have := hlt j.val hjk
      rw [List.getElem_finRange] at this
      simp [h] at this

theorem canon_le_self (f : Fin n → α) (i : Fin n) : canon f i ≤ i := canon_le rfl

/-- The defining characterisation: `canon f i` is the least element of the fibre of `i`. -/
theorem canon_eq_iff_least {f : Fin n → α} {i c : Fin n} :
    canon f i = c ↔ f c = f i ∧ ∀ j, f j = f i → c ≤ j := by
  constructor
  · rintro rfl
    exact ⟨apply_canon f i, fun j hj => canon_le hj⟩
  · rintro ⟨hc, hmin⟩
    exact le_antisymm (canon_le hc) (hmin _ (apply_canon f i))

/-- Tuples with the same kernel have the same canonical form. -/
theorem canon_congr [DecidableEq β] {f : Fin n → α} {g : Fin n → β} (h : Ker f = Ker g) :
    canon f = canon g := by
  rw [ker_eq_iff] at h
  funext i
  refine canon_eq_iff_least.2 ⟨?_, ?_⟩
  · exact (h (canon g i) i).2 (apply_canon g i)
  · intro j hj
    exact canon_le ((h j i).1 hj)

/-- Two coordinates are equal iff they receive the same canonical label. -/
theorem eq_iff_canon_eq (f : Fin n → α) (i j : Fin n) : f i = f j ↔ canon f i = canon f j := by
  constructor
  · intro h
    refine canon_eq_iff_least.2 ⟨?_, ?_⟩
    · exact (apply_canon f j).trans h.symm
    · intro k hk
      exact canon_le (hk.trans h)
  · intro h
    calc f i = f (canon f i) := (apply_canon f i).symm
      _ = f (canon f j) := by rw [h]
      _ = f j := apply_canon f j

/-- The kernel of the canonical form is the kernel of the tuple: `canon` loses no
information. -/
theorem ker_canon (f : Fin n → α) : Ker (canon f) = Ker f := by
  funext i j
  exact propext (eq_iff_canon_eq f i j).symm

/-- **`canon` is a complete invariant of the kernel.** -/
theorem canon_eq_canon_iff [DecidableEq β] {f : Fin n → α} {g : Fin n → β} :
    canon f = canon g ↔ Ker f = Ker g := by
  refine ⟨fun h => ?_, canon_congr⟩
  rw [ker_eq_iff]
  intro i j
  rw [eq_iff_canon_eq f i j, eq_iff_canon_eq g i j, h]

/-- Applying the canonical form to a canonical index changes nothing. -/
@[simp] theorem canon_canon_apply (f : Fin n → α) (i : Fin n) :
    canon f (canon f i) = canon f i :=
  (eq_iff_canon_eq f _ _).1 (apply_canon f i)

/-- A tuple with pairwise distinct entries is its own canonical form: injective tuples
carry the discrete pattern. -/
theorem canon_eq_id_of_injective {f : Fin n → α} (hf : Function.Injective f) :
    canon f = id := by
  funext i
  exact hf (apply_canon f i)

/-- `canon` is idempotent: canonical forms are fixed points. -/
@[simp] theorem canon_idem (f : Fin n → α) : canon (canon f) = canon f :=
  canon_eq_canon_iff.2 (ker_canon f)

/-- `canon` is invariant under post-composition with an injective map. -/
theorem canon_comp_of_injective [DecidableEq β] {σ : α → β} (hσ : Function.Injective σ)
    (f : Fin n → α) : canon (σ ∘ f) = canon f :=
  canon_eq_canon_iff.2 (ker_comp_of_injective hσ f)

/-- `canon` is a `G`-invariant for the symmetric group action. -/
theorem canon_perm_smul (σ : Equiv.Perm α) (f : Fin n → α) : canon (σ • f) = canon f :=
  canon_comp_of_injective σ.injective f

end Canon

/-! ## Completeness of the kernel invariant -/

/-- If two tuples into a finite type have the same kernel, they differ by a permutation of
the codomain.  Together with `ker_perm_smul` this says the kernel is a **complete
`Equiv.Perm β`-invariant**. -/
theorem exists_perm_of_ker_eq [Fintype β] [DecidableEq β] {f g : Fin n → β}
    (h : Ker f = Ker g) : ∃ σ : Equiv.Perm β, σ ∘ f = g := by
  classical
  rw [ker_eq_iff] at h
  -- the induced bijection between the two ranges
  have fwd : ∀ x : {x : β // x ∈ Set.range f}, g x.2.choose ∈ Set.range g := fun x => ⟨_, rfl⟩
  have bwd : ∀ y : {y : β // y ∈ Set.range g}, f y.2.choose ∈ Set.range f := fun y => ⟨_, rfl⟩
  let e : {x : β // x ∈ Set.range f} ≃ {y : β // y ∈ Set.range g} :=
    { toFun := fun x => ⟨g x.2.choose, fwd x⟩
      invFun := fun y => ⟨f y.2.choose, bwd y⟩
      left_inv := by
        rintro ⟨x, hx⟩
        have hx' : f hx.choose = x := hx.choose_spec
        set i := hx.choose with hi
        apply Subtype.ext
        show f (fwd ⟨x, hx⟩).choose = x
        have hj : g (fwd ⟨x, hx⟩).choose = g i := (fwd ⟨x, hx⟩).choose_spec
        have := (h (fwd ⟨x, hx⟩).choose i).2 hj
        rw [this, hx']
      right_inv := by
        rintro ⟨y, hy⟩
        have hy' : g hy.choose = y := hy.choose_spec
        set i := hy.choose with hi
        apply Subtype.ext
        show g (bwd ⟨y, hy⟩).choose = y
        have hj : f (bwd ⟨y, hy⟩).choose = f i := (bwd ⟨y, hy⟩).choose_spec
        have := (h (bwd ⟨y, hy⟩).choose i).1 hj
        rw [this, hy'] }
  refine ⟨e.extendSubtype, ?_⟩
  funext i
  show e.extendSubtype (f i) = g i
  have hmem : f i ∈ Set.range f := ⟨i, rfl⟩
  rw [Equiv.extendSubtype_apply_of_mem e _ hmem]
  show g (hmem.choose) = g i
  exact (h _ _).1 hmem.choose_spec

/-- **Completeness theorem.**  Over a finite codomain, two tuples lie in the same orbit of
the symmetric group acting by post-composition iff they have the same equality pattern. -/
theorem exists_perm_iff_ker_eq [Fintype β] [DecidableEq β] (f g : Fin n → β) :
    (∃ σ : Equiv.Perm β, σ ∘ f = g) ↔ Ker f = Ker g := by
  refine ⟨?_, exists_perm_of_ker_eq⟩
  rintro ⟨σ, rfl⟩
  exact (ker_comp_of_injective σ.injective f).symm

/-- The canonical form is a complete computable invariant of the orbit. -/
theorem exists_perm_iff_canon_eq [Fintype β] [DecidableEq β] (f g : Fin n → β) :
    (∃ σ : Equiv.Perm β, σ ∘ f = g) ↔ canon f = canon g := by
  rw [exists_perm_iff_ker_eq, canon_eq_canon_iff]

/-- Orbit formulation, with the `MulAction` of `Equiv.Perm β` on tuples. -/
theorem smul_orbit_iff_canon_eq [Fintype β] [DecidableEq β] (f g : Fin n → β) :
    (∃ σ : Equiv.Perm β, σ • f = g) ↔ canon f = canon g := by
  rw [← exists_perm_iff_canon_eq]
  constructor <;> rintro ⟨σ, hσ⟩ <;> exact ⟨σ, hσ⟩

/-! ## Enumeration: the Bell numbers -/

/-- The finite set of all kernel patterns of tuples of length `n`, realised as the set of
canonical forms. -/
def Patterns (n : ℕ) : Finset (Fin n → Fin n) :=
  Finset.univ.image (fun f : Fin n → Fin n => canon f)

theorem mem_patterns_iff {p : Fin n → Fin n} : p ∈ Patterns n ↔ canon p = p := by
  constructor
  · rintro hp
    obtain ⟨f, -, rfl⟩ := Finset.mem_image.1 hp
    exact canon_idem f
  · intro hp
    exact Finset.mem_image.2 ⟨p, Finset.mem_univ _, hp⟩

theorem patterns_eq_filter (n : ℕ) :
    Patterns n = Finset.univ.filter (fun f : Fin n → Fin n => canon f = f) := by
  ext p
  simp [mem_patterns_iff]

/-- Every tuple, with values in any type with decidable equality, has its pattern in
`Patterns n`. -/
theorem canon_mem_patterns [DecidableEq α] (f : Fin n → α) : canon f ∈ Patterns n :=
  mem_patterns_iff.2 (canon_idem f)

/-- Patterns classify tuples up to the symmetric group action. -/
theorem patterns_complete (f g : Fin n → Fin n) :
    (∃ σ : Equiv.Perm (Fin n), σ • f = g) ↔ canon f = canon g :=
  smul_orbit_iff_canon_eq f g

section BellCounts

/-! The first six Bell numbers, evaluated from Mathlib's recursive definition. -/

theorem bell_zero' : Nat.bell 0 = 1 := by norm_num [Nat.bell, Fin.sum_univ_succ, Nat.choose]
theorem bell_one' : Nat.bell 1 = 1 := by norm_num [Nat.bell, Fin.sum_univ_succ, Nat.choose]
theorem bell_two' : Nat.bell 2 = 2 := by norm_num [Nat.bell, Fin.sum_univ_succ, Nat.choose]
theorem bell_three' : Nat.bell 3 = 5 := by norm_num [Nat.bell, Fin.sum_univ_succ, Nat.choose]
theorem bell_four' : Nat.bell 4 = 15 := by norm_num [Nat.bell, Fin.sum_univ_succ, Nat.choose]
theorem bell_five' : Nat.bell 5 = 52 := by norm_num [Nat.bell, Fin.sum_univ_succ, Nat.choose]

theorem card_patterns_zero : (Patterns 0).card = 1 := by
  rw [patterns_eq_filter]; decide

theorem card_patterns_one : (Patterns 1).card = 1 := by
  rw [patterns_eq_filter]; decide

theorem card_patterns_two : (Patterns 2).card = 2 := by
  rw [patterns_eq_filter]; decide

set_option maxRecDepth 40000 in
theorem card_patterns_three : (Patterns 3).card = 5 := by
  rw [patterns_eq_filter]; decide

set_option maxRecDepth 400000 in
theorem card_patterns_four : (Patterns 4).card = 15 := by
  rw [patterns_eq_filter]; decide

set_option maxRecDepth 4000000 in
set_option maxHeartbeats 2000000 in
theorem card_patterns_five : (Patterns 5).card = 52 := by
  rw [patterns_eq_filter]; decide

/-- The kernel-pattern counts agree with Mathlib's Bell numbers `Nat.bell`
(OEIS A000110: `1, 1, 2, 5, 15, 52`) for all `n ≤ 5`. -/
theorem card_patterns_eq_bell_of_le_five {n : ℕ} (hn : n ≤ 5) :
    (Patterns n).card = Nat.bell n := by
  interval_cases n
  · rw [card_patterns_zero, bell_zero']
  · rw [card_patterns_one, bell_one']
  · rw [card_patterns_two, bell_two']
  · rw [card_patterns_three, bell_three']
  · rw [card_patterns_four, bell_four']
  · rw [card_patterns_five, bell_five']

/-- The list of pattern counts is the initial segment `1, 1, 2, 5, 15, 52` of A000110. -/
theorem patterns_card_list :
    (List.range 6).map (fun n => (Patterns n).card) = [1, 1, 2, 5, 15, 52] := by
  simp only [List.range_succ, List.range_zero]
  simp only [List.map_cons, List.map_nil, List.nil_append, List.cons_append]
  rw [card_patterns_zero, card_patterns_one, card_patterns_two, card_patterns_three,
    card_patterns_four, card_patterns_five]

end BellCounts

end KernelPattern