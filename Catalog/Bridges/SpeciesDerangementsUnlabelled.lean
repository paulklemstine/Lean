/-
# Unlabelled derangements are partitions without parts equal to one

The species `D` of derangements carries, like every species, an action of `Sym(n)` on
its structures on `Fin n`; here the action is conjugation, so the unlabelled
`D`-structures are the conjugacy classes of `Sym(n)` consisting of fixed-point-free
permutations.  A conjugacy class is determined by its cycle type, and a permutation is
fixed-point-free exactly when its cycle-type partition has no part equal to `1`.
Hence

    unlabelled D n = #{ partitions of n all of whose parts are ≥ 2 }.

Combining this with the species form of Burnside's lemma gives the total number of
derangements commuting with a given permutation, summed over `Sym(n)`.
-/
import Bridges.SpeciesDerangements
import Bridges.SpeciesPartitions

noncomputable section

namespace SpeciesEGF

open scoped BigOperators
open Equiv Equiv.Perm

namespace Species

/-- Transport of partitions along an equality of the number partitioned. -/
def partitionCongr {m n : ℕ} (h : m = n) : m.Partition ≃ n.Partition := by
  subst h; exact Equiv.refl _

@[simp] theorem parts_partitionCongr {m n : ℕ} (h : m = n) (P : m.Partition) :
    (partitionCongr h P).parts = P.parts := by subst h; rfl

/-- Transport of structure for the species of derangements is conjugation. -/
theorem derang_map_val {n : ℕ} (σ : Perm (Fin n)) (x : derang.obj (Fin n)) :
    (derang.map σ x).1 = σ * x.1 * σ⁻¹ := Equiv.ext fun _ => rfl

/-- A permutation of a finite set is fixed-point-free exactly when every part of its
cycle-type partition is at least `2`. -/
theorem derangement_iff_parts {α : Type*} [Fintype α] [DecidableEq α] (σ : Perm α) :
    (∀ a, σ a ≠ a) ↔ ∀ i ∈ (Perm.partition σ).parts, 2 ≤ i := by
  constructor
  · intro h i hi
    have hsupp : σ.support = Finset.univ :=
      Finset.eq_univ_iff_forall.2 fun a => Perm.mem_support.2 (h a)
    rw [Perm.parts_partition, hsupp] at hi
    have hcard : Fintype.card α - (Finset.univ : Finset α).card = 0 := by
      simp
    rw [hcard, Multiset.replicate_zero, add_zero] at hi
    exact Perm.two_le_of_mem_cycleType hi
  · intro h a
    have hone : (1 : ℕ) ∉ (Perm.partition σ).parts := by
      intro h1
      have := h 1 h1
      omega
    have hzero : Fintype.card α - σ.support.card = 0 := by
      by_contra hne
      refine hone ?_
      rw [Perm.parts_partition]
      refine Multiset.mem_add.2 (Or.inr ?_)
      exact Multiset.mem_replicate.2 ⟨hne, rfl⟩
    have hle : Fintype.card α ≤ σ.support.card := by omega
    have hsupp : σ.support = Finset.univ :=
      Finset.eq_univ_of_card _ (le_antisymm (Finset.card_le_univ _) (by simpa using hle))
    have : a ∈ σ.support := by rw [hsupp]; exact Finset.mem_univ a
    exact Perm.mem_support.1 this

/-- **The unlabelled derangements on `n` points are the partitions of `n` with all parts
at least `2`.** -/
theorem unlabelled_derang (n : ℕ) :
    derang.unlabelled n = Nat.card {P : Nat.Partition n // ∀ i ∈ P.parts, 2 ≤ i} := by
  classical
  have hn : Fintype.card (Fin n) = n := Fintype.card_fin n
  set toPart : derang.obj (Fin n) → {P : Nat.Partition n // ∀ i ∈ P.parts, 2 ≤ i} :=
    fun x => ⟨partitionCongr hn (Perm.partition x.1), by
      intro i hi
      rw [parts_partitionCongr] at hi
      exact (derangement_iff_parts x.1).1 x.2 i hi⟩ with htoPart
  have hconj : ∀ x y : derang.obj (Fin n), (∃ σ : Perm (Fin n), derang.map σ y = x) →
      toPart x = toPart y := by
    rintro x y ⟨σ, hσ⟩
    have hval : x.1 = σ * y.1 * σ⁻¹ := by
      rw [← hσ, derang_map_val]
    have : IsConj y.1 x.1 := isConj_iff.2 ⟨σ, hval.symm⟩
    apply Subtype.ext
    apply (partitionCongr hn).symm.injective
    simp only [Equiv.symm_apply_apply, htoPart]
    exact (Perm.partition_eq_of_isConj.1 this).symm
  set f : Quotient (MulAction.orbitRel (Perm (Fin n)) (derang.obj (Fin n))) →
      {P : Nat.Partition n // ∀ i ∈ P.parts, 2 ≤ i} :=
    Quotient.lift toPart (fun x y h => hconj x y h) with hf
  have hbij : Function.Bijective f := by
    constructor
    · refine fun q q' => Quotient.inductionOn₂ q q' ?_
      intro x y h
      have h' : partitionCongr hn (Perm.partition x.1) = partitionCongr hn (Perm.partition y.1) :=
        congrArg Subtype.val h
      have hp : Perm.partition x.1 = Perm.partition y.1 := (partitionCongr hn).injective h'
      obtain ⟨σ, hσ⟩ := isConj_iff.1 (Perm.partition_eq_of_isConj.2 hp.symm)
      refine Quotient.sound ⟨σ, Subtype.ext ?_⟩
      show (derang.map σ y).1 = x.1
      rw [derang_map_val]
      exact hσ
    · rintro ⟨P, hP⟩
      have hsum : P.parts.sum ≤ Fintype.card (Fin n) := by
        rw [hn, P.parts_sum]
      obtain ⟨σ, hσ⟩ := (Perm.exists_with_cycleType_iff (Fin n) (m := P.parts)).2 ⟨hsum, hP⟩
      have hsupp : σ.support.card = n := by
        rw [← Perm.sum_cycleType, hσ, P.parts_sum]
      have hparts : (Perm.partition σ).parts = P.parts := by
        rw [Perm.parts_partition, hσ, hsupp, hn]
        simp
      have hderang : ∀ a, σ a ≠ a :=
        (derangement_iff_parts σ).2 (by rw [hparts]; exact hP)
      refine ⟨Quotient.mk _ ⟨σ, hderang⟩, Subtype.ext (Nat.Partition.ext_iff.2 ?_)⟩
      show (partitionCongr hn (Perm.partition σ)).parts = P.parts
      rw [parts_partitionCongr]
      exact hparts
  rw [unlabelled, Nat.card_eq_of_bijective f hbij]

/-- **Burnside for derangements**: the number of derangements commuting with `σ`, summed
over all `σ ∈ Sym(n)`, is `n!` times the number of partitions of `n` with all parts at
least `2`. -/
theorem sum_card_commuting_derangements (n : ℕ) :
    ∑ σ : Perm (Fin n), Nat.card {x : derang.obj (Fin n) // σ * x.1 = x.1 * σ}
      = Nat.card {P : Nat.Partition n // ∀ i ∈ P.parts, 2 ≤ i} * n.factorial := by
  rw [← unlabelled_derang, ← burnside]
  refine Finset.sum_congr rfl fun σ _ => ?_
  refine Nat.card_congr (Equiv.subtypeEquivRight fun x => ?_)
  constructor
  · intro h
    refine Subtype.ext ?_
    show (derang.map σ x).1 = x.1
    rw [derang_map_val, h]
    simp [mul_assoc]
  · intro h
    have h' : σ * x.1 * σ⁻¹ = x.1 := by rw [← derang_map_val]; exact congrArg Subtype.val h
    have := congrArg (fun y => y * σ) h'
    simpa [mul_assoc] using this

end Species

end SpeciesEGF