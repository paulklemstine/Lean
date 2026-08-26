import Geometry.KernelPatterns.Synthesis

/-!
# Cycle 2: chambers of the braid arrangement

The kernel pattern of a tuple records *which* coordinates coincide; on the
complement of the braid arrangement — the injective tuples — nothing coincides
and the relevant invariant becomes the *ordering* of the coordinates.  This
file is the chamber-level companion of the flat-level results in
`Geometry.KernelPatterns.BraidFlats`.

* `chamber n σ` — the open cone `v (σ 0) < v (σ 1) < ⋯ < v (σ (n-1))`.
* `chamber_convex`, `chamber_nonempty` — chambers are nonempty convex (hence
  connected) sets.
* `chamber_eq_chamber_iff`, `chamber_injective` — a chamber determines its
  permutation, i.e. the ordering is a complete invariant of the chamber.
* `iUnion_chamber` — the chambers cover exactly the complement of the
  arrangement.
* `card_chambers` — there are `n !` chambers, whereas
  (`card_braidFlats_eq_bell`) there are `Nat.bell n` flats.
-/

namespace Geometry.KernelPatterns

open Finset

variable {n : ℕ}

/-- The open chamber of the braid arrangement in `ℝ^n` indexed by a permutation:
the coordinates are strictly increasing along `σ`. -/
def chamber (n : ℕ) (σ : Equiv.Perm (Fin n)) : Set (Fin n → ℝ) :=
  {v | ∀ i j : Fin n, i < j → v (σ i) < v (σ j)}

@[simp] lemma mem_chamber {σ : Equiv.Perm (Fin n)} {v : Fin n → ℝ} :
    v ∈ chamber n σ ↔ ∀ i j : Fin n, i < j → v (σ i) < v (σ j) := Iff.rfl

/-- Chambers are convex, hence connected. -/
theorem chamber_convex (σ : Equiv.Perm (Fin n)) : Convex ℝ (chamber n σ) := by
  intro v hv w hw a b ha hb hab i j hij
  have h1 : v (σ i) < v (σ j) := hv i j hij
  have h2 : w (σ i) < w (σ j) := hw i j hij
  have key : a * v (σ i) + b * w (σ i) < a * v (σ j) + b * w (σ j) := by
    rcases eq_or_lt_of_le ha with ha0 | hapos
    · have hb1 : b = 1 := by linarith
      have ha1 : a = 0 := ha0.symm
      rw [ha1, hb1]; linarith
    · nlinarith [mul_lt_mul_of_pos_left h1 hapos, mul_le_mul_of_nonneg_left h2.le hb]
  simpa using key

/-- Every chamber is nonempty. -/
theorem chamber_nonempty (σ : Equiv.Perm (Fin n)) : (chamber n σ).Nonempty := by
  refine ⟨fun x => ((σ.symm x : Fin n) : ℕ), fun i j hij => ?_⟩
  simp only [Equiv.symm_apply_apply]
  exact_mod_cast Fin.lt_def.1 hij

/-- Points of a chamber avoid the braid arrangement. -/
theorem injective_of_mem_chamber {σ : Equiv.Perm (Fin n)} {v : Fin n → ℝ}
    (hv : v ∈ chamber n σ) : Function.Injective v := by
  intro x y hxy
  by_contra hne
  have hne' : σ.symm x ≠ σ.symm y := fun h => hne (by
    have := congrArg σ h
    simpa using this)
  rcases lt_or_gt_of_ne hne' with h | h
  · have := hv _ _ h
    simp only [Equiv.apply_symm_apply] at this
    exact absurd hxy (ne_of_lt this)
  · have := hv _ _ h
    simp only [Equiv.apply_symm_apply] at this
    exact absurd hxy.symm (ne_of_lt this)

/-- Conversely every point off the arrangement lies in a chamber, obtained by
sorting its coordinates. -/
theorem exists_mem_chamber {v : Fin n → ℝ} (hv : Function.Injective v) :
    v ∈ chamber n (Tuple.sort v) := by
  have hmono : Monotone (v ∘ (Tuple.sort v)) := Tuple.monotone_sort v
  have hinj : Function.Injective (v ∘ (Tuple.sort v)) :=
    hv.comp (Tuple.sort v).injective
  exact fun i j hij => hmono.strictMono_of_injective hinj hij

/-- The chambers cover exactly the complement of the braid arrangement. -/
theorem iUnion_chamber (n : ℕ) :
    (⋃ σ : Equiv.Perm (Fin n), chamber n σ) = {v : Fin n → ℝ | Function.Injective v} := by
  ext v
  constructor
  · intro hv
    obtain ⟨σ, hσ⟩ := Set.mem_iUnion.1 hv
    exact injective_of_mem_chamber hσ
  · intro hv
    exact Set.mem_iUnion.2 ⟨Tuple.sort v, exists_mem_chamber hv⟩

/-- Distinct permutations give disjoint chambers: an injective tuple is sorted
by exactly one permutation. -/
theorem chamber_disjoint {σ τ : Equiv.Perm (Fin n)} (hne : σ ≠ τ) :
    Disjoint (chamber n σ) (chamber n τ) := by
  rw [Set.disjoint_left]
  intro v hσ hτ
  apply hne
  have hmono : StrictMono fun i => v (σ i) := fun i j hij => hσ i j hij
  have hmono' : StrictMono fun i => v (τ i) := fun i j hij => hτ i j hij
  set ρ : Equiv.Perm (Fin n) := τ.trans σ.symm with hρdef
  have hρapp : ∀ i, ρ i = σ.symm (τ i) := fun i => rfl
  have hρ : StrictMono (ρ : Fin n → Fin n) := by
    intro i j hij
    have h1 : v (σ (ρ i)) < v (σ (ρ j)) := by
      simpa [hρapp] using hmono' hij
    exact hmono.lt_iff_lt.1 h1
  have hρsymm : StrictMono (ρ.symm : Fin n → Fin n) := by
    intro i j hij
    by_contra hle
    push_neg at hle
    have hmon := hρ.monotone hle
    simp only [Equiv.apply_symm_apply] at hmon
    exact absurd hij (not_lt.2 hmon)
  have hid : ∀ i, ρ i = i := by
    intro i
    have h2 : i ≤ ρ.symm i := hρsymm.le_apply
    have h3 : ρ i ≤ i := by
      have := hρ.monotone h2
      simpa using this
    exact le_antisymm h3 hρ.le_apply
  refine Equiv.ext fun i => ?_
  have := hid i
  rw [hρapp] at this
  have := congrArg σ this
  simpa using this.symm

/-- The chamber determines the permutation. -/
theorem chamber_injective (n : ℕ) : Function.Injective (chamber n) := by
  intro σ τ h
  by_contra hne
  have hdisj := chamber_disjoint hne
  obtain ⟨v, hv⟩ := chamber_nonempty σ
  have hv' : v ∈ chamber n τ := h ▸ hv
  exact (Set.disjoint_left.1 hdisj hv) hv'

/-- The set of chambers of the braid arrangement. -/
def chambers (n : ℕ) : Set (Set (Fin n → ℝ)) := Set.range (chamber n)

/-- **The braid arrangement in `ℝ^n` has `n !` chambers** (compare
`card_braidFlats_eq_bell`: it has `Nat.bell n` flats). -/
theorem card_chambers (n : ℕ) : Nat.card (chambers n) = Nat.factorial n := by
  have h : Nat.card ↥(chambers n) = Nat.card (Equiv.Perm (Fin n)) :=
    Nat.card_range_of_injective (chamber_injective n)
  rw [h, Nat.card_eq_fintype_card, Fintype.card_perm, Fintype.card_fin]

end Geometry.KernelPatterns