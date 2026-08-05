/-
# Unlabelled permutation-structures are partitions

The species `S` of permutations has `n!` labelled structures on `n` points.  Its
unlabelled structures — the orbits of the transport action of `Sym(n)`, i.e. the
conjugacy classes of `Sym(n)` — are classified by their cycle type, hence counted by
the partition numbers `p(n)`.

Combining this with the species form of Burnside's lemma
(`SpeciesEGF.Species.burnside`) yields the classical identity

    ∑_{σ ∈ Sym(n)} |centraliser of σ| = n! · p(n).
-/
import Bridges.SpeciesUnlabelled

noncomputable section

namespace SpeciesEGF

open scoped BigOperators
open Equiv Equiv.Perm

namespace Species

variable (α : Type*) [Fintype α] [DecidableEq α]

/-- Every partition of `|α|` is the cycle-type partition of some permutation of `α`. -/
theorem partition_surjective : Function.Surjective (Perm.partition (α := α)) := by
  classical
  intro P
  set m := P.parts.filter (fun i => 2 ≤ i) with hm
  set r := P.parts.filter (fun i => ¬ 2 ≤ i) with hr
  have hsplit : m + r = P.parts := Multiset.filter_add_not _ _
  have hr1 : r = Multiset.replicate r.card 1 := by
    refine Multiset.eq_replicate_card.2 ?_
    intro b hb
    have hb1 : b ∈ P.parts := Multiset.mem_of_mem_filter hb
    have h2 : ¬ 2 ≤ b := (Multiset.mem_filter.1 hb).2
    have hpos := P.parts_pos hb1
    omega
  have hsum : m.sum + r.sum = Fintype.card α := by
    rw [← Multiset.sum_add, hsplit, P.parts_sum]
  have hrsum : r.sum = r.card := by
    conv_lhs => rw [hr1]
    simp
  obtain ⟨σ, hσ⟩ := (Perm.exists_with_cycleType_iff α (m := m)).2
    ⟨by omega, fun a ha => (Multiset.mem_filter.1 ha).2⟩
  have hsupp : σ.support.card = m.sum := by rw [← sum_cycleType, hσ]
  refine ⟨σ, ?_⟩
  rw [Nat.Partition.ext_iff, parts_partition, hσ, hsupp, ← hsplit]
  congr 1
  rw [hr1]
  congr 1
  omega

/-- The cycle-type map from conjugacy classes of `Perm α` to partitions of `|α|`. -/
def conjClassesPartition : ConjClasses (Perm α) → (Fintype.card α).Partition :=
  Quotient.lift (fun σ => Perm.partition σ) fun _ _ h => Perm.partition_eq_of_isConj.1 h

theorem conjClassesPartition_bijective : Function.Bijective (conjClassesPartition α) := by
  constructor
  · refine fun x y => Quotient.inductionOn₂ x y ?_
    intro a b h
    exact Quotient.sound (Perm.partition_eq_of_isConj.2 h)
  · intro P
    obtain ⟨σ, hσ⟩ := partition_surjective α P
    exact ⟨Quotient.mk _ σ, hσ⟩

/-- **Conjugacy classes of the symmetric group are classified by cycle type.** -/
theorem card_conjClasses_perm :
    Nat.card (ConjClasses (Perm α)) = Nat.card ((Fintype.card α).Partition) :=
  Nat.card_eq_of_bijective _ (conjClassesPartition_bijective α)

/-- The number of unlabelled structures of the species of permutations on `n` points is
the number of partitions of `n`. -/
theorem unlabelled_perm_eq_partitions (n : ℕ) :
    perm.unlabelled n = Nat.card (Nat.Partition n) := by
  rw [unlabelled_perm, card_conjClasses_perm]
  simp

/-- **Burnside applied to the species of permutations**: the total size of all
centralisers in `Sym(n)` is `n!` times the number of partitions of `n`. -/
theorem sum_card_centralizer_eq (n : ℕ) :
    ∑ σ : Perm (Fin n), Nat.card {x : Perm (Fin n) // σ * x = x * σ}
      = Nat.card (Nat.Partition n) * n.factorial := by
  rw [← unlabelled_perm_eq_partitions, ← burnside]
  refine Finset.sum_congr rfl fun σ _ => ?_
  refine (Nat.card_congr (Equiv.subtypeEquivRight fun x => ?_)).symm
  show perm.map σ x = x ↔ _
  rw [perm_map_eq_conj]
  constructor
  · intro h
    have := congrArg (fun y => y * σ) h
    simpa [mul_assoc] using this
  · intro h
    rw [h]
    simp [mul_assoc]

end Species

end SpeciesEGF