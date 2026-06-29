import Mathlib

/-!
# Bijection between partitions of `n` and conjugacy classes of `Perm (Fin n)`

For a natural number `n`, this file constructs an explicit bijection

`partitionEquivConjClasses : Nat.Partition n ≃ ConjClasses (Equiv.Perm (Fin n))`

between the partitions of `n` and the conjugacy classes of the symmetric group on
`Fin n`.

The forward map sends a partition `p` to the conjugacy class of an explicit
permutation `permOfPartition p`, obtained by arranging the elements of `Fin n` into
disjoint blocks whose sizes are the parts of `p` and turning each block into a cycle
(parts equal to `1` becoming fixed points).  The key facts are:

* `permOfPartition_cycleType` : the cycle type of `permOfPartition p` is the multiset of
  parts of `p` that are at least `2` (the parts of size `1` are fixed points and do not
  contribute to the cycle type);
* `permOfPartition_partition_parts` : the parts of the partition associated to
  `permOfPartition p` are exactly the parts of `p`.

Injectivity is deduced from `Equiv.Perm.partition_eq_of_isConj` and surjectivity from the
fact that every conjugacy class has a representative, whose partition is matched by
`permOfPartition`.
-/

open Equiv Equiv.Perm

namespace PartitionConjClasses

variable {n : ℕ}

/-- Transporting a partition along an equality of its index does not change its parts. -/
lemma parts_cast {a b : ℕ} (h : a = b) (q : a.Partition) : (h ▸ q).parts = q.parts := by
  subst h; rfl

/-
For a partition `p` of `n`, there is a permutation of `Fin n` whose cycle type is the
multiset of parts of `p` that are at least `2`.
-/
lemma exists_perm_cycleType (p : Nat.Partition n) :
    ∃ g : Equiv.Perm (Fin n), g.cycleType = p.parts.filter (2 ≤ ·) := by
  convert ( Equiv.Perm.exists_with_cycleType_iff _ ).mpr ?_ using 1;
  simp +zetaDelta at *;
  have := p.parts_sum;
  grind +suggestions

/-- The permutation associated to a partition: the elements of `Fin n` are arranged into
disjoint blocks whose sizes are the parts of `p`, and each block is turned into a cycle
(parts equal to `1` being fixed points). -/
noncomputable def permOfPartition (p : Nat.Partition n) : Equiv.Perm (Fin n) :=
  (exists_perm_cycleType p).choose

/-- The cycle type of `permOfPartition p` is the multiset of parts of `p` that are at
least `2`. -/
lemma permOfPartition_cycleType (p : Nat.Partition n) :
    (permOfPartition p).cycleType = p.parts.filter (2 ≤ ·) :=
  (exists_perm_cycleType p).choose_spec

/-
The parts of the partition associated to `permOfPartition p` are exactly the parts of
`p`.
-/
lemma permOfPartition_partition_parts (p : Nat.Partition n) :
    (permOfPartition p).partition.parts = p.parts := by
  rw [ Equiv.Perm.parts_partition, permOfPartition_cycleType ];
  convert Multiset.filter_add_not ( fun x => 2 ≤ x ) p.parts using 2;
  rw [ ← Equiv.Perm.sum_cycleType, permOfPartition_cycleType ];
  rw [ show ( Multiset.filter ( fun a => ¬2 ≤ a ) p.parts ) = Multiset.replicate ( Multiset.card ( Multiset.filter ( fun a => ¬2 ≤ a ) p.parts ) ) 1 from ?_ ];
  · rw [ show ( Multiset.filter ( fun a => ¬2 ≤ a ) p.parts ).card = ( Multiset.filter ( fun a => ¬2 ≤ a ) p.parts ).sum from ?_ ];
    · have h_card : (Multiset.filter (fun a => 2 ≤ a) p.parts).sum + (Multiset.filter (fun a => ¬2 ≤ a) p.parts).sum = n := by
        rw [ ← Multiset.sum_add, Multiset.filter_add_not, p.parts_sum ];
      simp +arith +decide [ ← h_card ];
    · have h_card : ∀ x ∈ Multiset.filter (fun a => ¬2 ≤ a) p.parts, x = 1 := by
        intro x hx; have := Multiset.mem_filter.mp hx; rcases this with ⟨ hx₁, hx₂ ⟩ ; have := p.parts_pos hx₁; interval_cases x ; trivial;
      rw [ Multiset.eq_replicate_of_mem h_card ] ; norm_num;
  · rw [ Multiset.eq_replicate ];
    exact ⟨ rfl, fun x hx => le_antisymm ( not_lt.mp <| Multiset.mem_filter.mp hx |>.2 ) <| p.parts_pos <| Multiset.mem_filter.mp hx |>.1 ⟩

/-- The partition (over `Fin n`) of a permutation, reindexed as a partition of `n`. -/
noncomputable def permPartition (σ : Equiv.Perm (Fin n)) : Nat.Partition n :=
  Fintype.card_fin n ▸ σ.partition

lemma permPartition_parts (σ : Equiv.Perm (Fin n)) :
    (permPartition σ).parts = σ.partition.parts := by
  rw [permPartition, parts_cast]

/-- The forward map: a partition is sent to the conjugacy class of its permutation. -/
noncomputable def toConjClass (p : Nat.Partition n) : ConjClasses (Equiv.Perm (Fin n)) :=
  ConjClasses.mk (permOfPartition p)

/-- The backward map: a conjugacy class is sent to the partition of any representative;
this is well defined by `Equiv.Perm.partition_eq_of_isConj`. -/
noncomputable def ofConjClass (c : ConjClasses (Equiv.Perm (Fin n))) : Nat.Partition n :=
  Quotient.liftOn c permPartition
    (fun _ _ h => by
      simp only [permPartition]
      rw [(Equiv.Perm.partition_eq_of_isConj).mp h])

lemma ofConjClass_mk (σ : Equiv.Perm (Fin n)) :
    ofConjClass (ConjClasses.mk σ) = permPartition σ := rfl

/-
`permOfPartition p` is conjugate to any permutation whose partition has the same parts
as `p`.
-/
lemma isConj_permOfPartition (p : Nat.Partition n) (σ : Equiv.Perm (Fin n))
    (h : σ.partition.parts = p.parts) : IsConj (permOfPartition p) σ := by
  rw [ Equiv.Perm.partition_eq_of_isConj ];
  convert Nat.Partition.ext _;
  convert permOfPartition_partition_parts p

lemma toConjClass_injective : Function.Injective (toConjClass (n := n)) := by
  intro p q h_eq
  have h_conj : IsConj (permOfPartition p) (permOfPartition q) :=
    ConjClasses.mk_eq_mk_iff_isConj.mp h_eq
  have h_parts : (permOfPartition p).partition.parts = (permOfPartition q).partition.parts :=
    congrArg Nat.Partition.parts (Equiv.Perm.partition_eq_of_isConj.mp h_conj)
  refine Nat.Partition.ext ?_
  rw [← permOfPartition_partition_parts p, ← permOfPartition_partition_parts q, h_parts]

lemma toConjClass_surjective : Function.Surjective (toConjClass (n := n)) := by
  intro c
  obtain ⟨σ, hσ⟩ := ConjClasses.exists_rep c
  refine ⟨permPartition σ, ?_⟩
  rw [← hσ, toConjClass,
    ConjClasses.mk_eq_mk_iff_isConj.mpr
      (isConj_permOfPartition (permPartition σ) σ (permPartition_parts σ).symm)]

/-- The explicit bijection between partitions of `n` and conjugacy classes of
`Perm (Fin n)`. -/
noncomputable def partitionEquivConjClasses :
    Nat.Partition n ≃ ConjClasses (Equiv.Perm (Fin n)) where
  toFun := toConjClass
  invFun := ofConjClass
  left_inv := by
    intro p
    rw [toConjClass, ofConjClass_mk]
    refine Nat.Partition.ext ?_
    rw [permPartition_parts, permOfPartition_partition_parts]
  right_inv := by
    intro c
    obtain ⟨σ, hσ⟩ := ConjClasses.exists_rep c
    rw [← hσ, ofConjClass_mk, toConjClass,
      ConjClasses.mk_eq_mk_iff_isConj.mpr
        (isConj_permOfPartition (permPartition σ) σ (permPartition_parts σ).symm)]

end PartitionConjClasses