import Mathlib

/-!
# Kernel patterns of tuples: a complete invariant for the symmetric-group action

For a tuple `x : Fin n → X` its *kernel* is the equivalence relation
`i ~ j ↔ x i = x j` on the index set `Fin n`.  We encode it by the canonical
*pattern* `pat x : Fin n → Fin n`, sending `i` to the least index `j` with
`x j = x i` (the "first occurrence" representative).

Main results of this file.

* `pat_eq_iff` — `pat` faithfully records the kernel.
* `pat_congr`, `pat_comp_injective` — `pat` is invariant under post-composition
  by injective maps, in particular under the diagonal action of `Equiv.Perm X`.
* `exists_perm_of_pat_eq`, `perm_orbit_iff_pat_eq` — for a *finite* value type
  `X`, equality of patterns is *exactly* equality of `Sym(X)`-orbits, i.e. the
  kernel is a complete invariant of the symmetric-group action on `X ^ n`.
* `pat_not_complete_of_trivial_group` — sharpness: for a proper subgroup the
  kernel need not be a complete invariant.
* `pat_idem`, `mem_patterns_iff` — patterns are exactly the idempotent tuples
  `p : Fin n → Fin n` with `pat p = p`; consequently the set of patterns
  *stabilises*: `patterns n m = patterns n n` as soon as `n ≤ m`
  (`patterns_stabilise`).
-/

namespace Geometry.KernelPatterns

open Finset

variable {n : ℕ} {X Y : Type*}

section Pat

variable [DecidableEq X]

/-- The *kernel pattern* of a tuple `x : Fin n → X`: the index `pat x i` is the
least `j` with `x j = x i`. -/
def pat (x : Fin n → X) (i : Fin n) : Fin n :=
  (univ.filter fun j => x j = x i).min' ⟨i, by simp⟩

lemma pat_mem (x : Fin n → X) (i : Fin n) :
    pat x i ∈ univ.filter fun j => x j = x i := Finset.min'_mem _ _

@[simp] lemma apply_pat (x : Fin n → X) (i : Fin n) : x (pat x i) = x i := by
  have := pat_mem x i; simpa using this

lemma pat_le (x : Fin n → X) (i : Fin n) : pat x i ≤ i :=
  Finset.min'_le _ _ (by simp)

/-- Two tuples with the same kernel have the same pattern. -/
lemma pat_congr [DecidableEq Y] {x : Fin n → X} {y : Fin n → Y}
    (h : ∀ k l, x k = x l ↔ y k = y l) : pat x = pat y := by
  funext i
  apply le_antisymm
  · exact Finset.min'_le _ _ (by simpa using (h _ _).2 (apply_pat y i))
  · exact Finset.min'_le _ _ (by simpa using (h _ _).1 (apply_pat x i))

/-- The pattern records the kernel faithfully. -/
@[simp] lemma pat_eq_iff {x : Fin n → X} {i j : Fin n} :
    pat x i = pat x j ↔ x i = x j := by
  constructor
  · intro h
    calc x i = x (pat x i) := (apply_pat x i).symm
      _ = x (pat x j) := by rw [h]
      _ = x j := apply_pat x j
  · intro h
    apply le_antisymm
    · exact Finset.min'_le _ _ (by simp [h])
    · exact Finset.min'_le _ _ (by simp [h])

/-- `pat` is invariant under post-composition with an injective map: it is a
`Sym(X)`-invariant (indeed an invariant for all of `X ↪ Y`). -/
lemma pat_comp_injective [DecidableEq Y] {f : X → Y} (hf : Function.Injective f)
    (x : Fin n → X) : pat (f ∘ x) = pat x :=
  (pat_congr (fun _ _ => by simp [hf.eq_iff])).symm

@[simp] lemma pat_perm (σ : Equiv.Perm X) (x : Fin n → X) : pat (σ ∘ x) = pat x :=
  pat_comp_injective σ.injective x

/-- The first-occurrence representative is a fixed point of the pattern map. -/
@[simp] lemma pat_apply_pat (x : Fin n → X) (i : Fin n) : pat x (pat x i) = pat x i :=
  pat_eq_iff.2 (apply_pat x i)

/-- Patterns are idempotent. -/
@[simp] lemma pat_idem (x : Fin n → X) : pat (pat x) = pat x :=
  pat_congr (fun _ _ => pat_eq_iff)

end Pat

/-! ### Completeness of the invariant for the symmetric group -/

section Complete

variable [Fintype X] [DecidableEq X]

/-- If two tuples over a finite type have equal patterns then some permutation
of the value type carries one to the other. -/
theorem exists_perm_of_pat_eq {x y : Fin n → X} (h : pat x = pat y) :
    ∃ σ : Equiv.Perm X, σ ∘ x = y := by
  classical
  have hxy : ∀ i j, x i = x j ↔ y i = y j := by
    intro i j
    rw [← pat_eq_iff (x := x), ← pat_eq_iff (x := y), h]
  set S : Set X := Set.range x with hS
  set T : Set X := Set.range y with hT
  let φ : S → T := fun a => ⟨y (Classical.choose a.2), Set.mem_range_self _⟩
  have hφ : ∀ a : S, x (Classical.choose a.2) = (a : X) := fun a => Classical.choose_spec a.2
  have hinj : Function.Injective φ := by
    intro a b hab
    have h1 : y (Classical.choose a.2) = y (Classical.choose b.2) := congrArg Subtype.val hab
    have h2 := (hxy _ _).2 h1
    exact Subtype.ext (by rw [← hφ a, ← hφ b]; exact h2)
  have hsurj : Function.Surjective φ := by
    intro b
    obtain ⟨j, hj⟩ := b.2
    refine ⟨⟨x j, Set.mem_range_self j⟩, Subtype.ext ?_⟩
    have hx : x (Classical.choose (⟨x j, Set.mem_range_self j⟩ : S).2) = x j := hφ _
    simpa [φ, hj] using (hxy _ _).1 hx
  let e : S ≃ T := Equiv.ofBijective φ ⟨hinj, hsurj⟩
  have hcard : Fintype.card (Sᶜ : Set X) = Fintype.card (Tᶜ : Set X) := by
    rw [Fintype.card_compl_set, Fintype.card_compl_set, Fintype.card_congr e]
  let e' : (Sᶜ : Set X) ≃ (Tᶜ : Set X) := Fintype.equivOfCardEq hcard
  refine ⟨(Equiv.Set.sumCompl S).symm.trans ((e.sumCongr e').trans (Equiv.Set.sumCompl T)), ?_⟩
  funext i
  have hmem : x i ∈ S := Set.mem_range_self i
  simp only [Function.comp_apply, Equiv.trans_apply,
    Equiv.Set.sumCompl_symm_apply_of_mem hmem, Equiv.sumCongr_apply, Sum.map_inl,
    Equiv.Set.sumCompl_apply_inl]
  have hval : (e ⟨x i, hmem⟩ : X) = y (Classical.choose (⟨x i, hmem⟩ : S).2) := rfl
  rw [hval]
  exact (hxy _ _).1 (hφ ⟨x i, hmem⟩)

/-- **Kernel patterns are a complete `Sym(X)`-invariant.** -/
theorem perm_orbit_iff_pat_eq (x y : Fin n → X) :
    (∃ σ : Equiv.Perm X, σ ∘ x = y) ↔ pat x = pat y := by
  constructor
  · rintro ⟨σ, rfl⟩; exact (pat_perm σ x).symm
  · exact exists_perm_of_pat_eq

end Complete

/-- Sharpness: for the trivial subgroup of `Sym(Fin 2)` the kernel is *not* a
complete invariant — the tuples `![0]` and `![1]` share a pattern but lie in
different orbits. -/
theorem pat_not_complete_of_trivial_group :
    pat (![0] : Fin 1 → Fin 2) = pat ![1] ∧
      ¬ ∃ σ : Equiv.Perm (Fin 2), σ ∈ (⊥ : Subgroup (Equiv.Perm (Fin 2))) ∧
        σ ∘ (![0] : Fin 1 → Fin 2) = ![1] := by
  constructor
  · decide
  · rintro ⟨σ, hσ, hcomp⟩
    rw [Subgroup.mem_bot] at hσ
    subst hσ
    have := congrFun hcomp 0
    simp at this

/-! ### The set of patterns, and stabilisation -/

/-- The finset of all kernel patterns of `n`-tuples with values in `Fin m`. -/
def patterns (n m : ℕ) : Finset (Fin n → Fin n) :=
  (univ : Finset (Fin n → Fin m)).image pat

/-- A tuple `p : Fin n → Fin n` is the pattern of some `Fin m`-valued tuple iff
it is idempotent and uses at most `m` distinct values. -/
lemma mem_patterns_iff {n m : ℕ} (p : Fin n → Fin n) :
    p ∈ patterns n m ↔ pat p = p ∧ (univ.image p).card ≤ m := by
  constructor
  · intro hp
    simp only [patterns, Finset.mem_image, Finset.mem_univ, true_and] at hp
    obtain ⟨x, rfl⟩ := hp
    refine ⟨pat_idem x, ?_⟩
    have hfix : ∀ j ∈ univ.image (pat x), pat x j = j := by
      intro j hj
      simp only [Finset.mem_image, Finset.mem_univ, true_and] at hj
      obtain ⟨i, rfl⟩ := hj
      exact pat_eq_iff.2 (apply_pat x i)
    have hle : (univ.image (pat x)).card ≤ (univ.image x).card := by
      refine Finset.card_le_card_of_injOn (fun j => x j) (fun j _ => by simp) ?_
      intro j hj j' hj' hxx
      rw [← hfix j hj, ← hfix j' hj']
      exact pat_eq_iff.2 hxx
    exact hle.trans (by simpa using Finset.card_le_univ (univ.image x))
  · rintro ⟨hidem, hcard⟩
    have hcard' : Fintype.card ↥(univ.image p) ≤ Fintype.card (Fin m) := by
      rw [Fintype.card_coe, Fintype.card_fin]; exact hcard
    obtain ⟨e⟩ := Function.Embedding.nonempty_of_card_le hcard'
    have hmem : ∀ i, p i ∈ univ.image p := fun i => Finset.mem_image_of_mem p (mem_univ i)
    refine Finset.mem_image.2 ⟨fun i => e ⟨p i, hmem i⟩, Finset.mem_univ _, ?_⟩
    have : pat (fun i => e ⟨p i, hmem i⟩) = pat p :=
      pat_congr (fun k l => by simp [e.injective.eq_iff, Subtype.ext_iff])
    rw [this, hidem]

lemma mem_patterns_self {n : ℕ} (p : Fin n → Fin n) :
    p ∈ patterns n n ↔ pat p = p := by
  rw [mem_patterns_iff]
  exact ⟨fun h => h.1, fun h => ⟨h, by simpa using Finset.card_le_univ (univ.image p)⟩⟩

/-- **Stabilisation**: once there are at least `n` available values, the set of
kernel patterns of `n`-tuples no longer depends on the value type. -/
theorem patterns_stabilise {n m : ℕ} (h : n ≤ m) : patterns n m = patterns n n := by
  ext p
  rw [mem_patterns_iff, mem_patterns_self]
  refine ⟨fun hp => hp.1, fun hp => ⟨hp, le_trans (by simpa using Finset.card_le_univ (univ.image p)) h⟩⟩

end Geometry.KernelPatterns