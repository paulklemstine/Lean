import Mathlib

/-!
# Counting the irreducible characters of `Sₙ`: rows of the character table

The number of rows (= columns) of the character table of a finite group `G` equals the
number of conjugacy classes of `G` (this is the number of irreducible complex
characters).  For the symmetric group `Sₙ = Perm (Fin n)` the conjugacy classes are
parametrised by the **partitions of `n`** (cycle type), so the character table of `Sₙ`
is a `p(n) × p(n)` square, where `p(n)` is the partition number.

This file proves the combinatorial backbone of that statement:

* `SnConjClassCount.card_conjClasses_eq_card_partition` —
  `|ConjClasses (Perm (Fin n))| = |Nat.Partition n|`, i.e. the number of conjugacy
  classes of `Sₙ` equals the number of partitions of `n`.
* the concrete counts `card_conjClasses_S3 = 3`, `card_conjClasses_S4 = 5`,
  `card_conjClasses_S5 = 7` (`= p(3), p(4), p(5)`), giving the sizes of the character
  tables of `S₃, S₄, S₅`.

The bijection `partitionEquivConjClasses` between partitions of `n` and conjugacy
classes of `Perm (Fin n)` is reproduced here from the catalog file
`Catalog/9c488c94_retry3_aristotle/Algebra/PartitionConjClasses.lean` (it cannot be
imported directly because that file is not in a built library target); full credit for
the bijection construction belongs to that file.  The *new* results of this file are the
cardinality statement and the concrete `S₃/S₄/S₅` counts built on top of it.

-- !-- Lab Notes -- !--
* Hypothesis: the character table of `Sₙ` is a `p(n) × p(n)` square; in particular
  `S₃, S₄, S₅` have `3, 5, 7` irreducible characters.
* Experiment: the number of irreducible complex characters equals the number of
  conjugacy classes; for `Sₙ` these are indexed by cycle type, i.e. by partitions of
  `n`. Reuse the explicit partition ↔ conjugacy-class bijection and take cardinalities.
* Analysis: the cardinality transfer is `Fintype.card_congr`. The concrete numbers are
  the partition numbers `p(3)=3, p(4)=5, p(5)=7`, which match OEIS A000041.
* Critique: the deep representation-theoretic identity "#irreducibles = #conjugacy
  classes" is *not* re-proved here (it is not in Mathlib); we prove its `Sₙ`-specific
  combinatorial half, "#conjugacy classes = #partitions", which is the part that makes
  the table genuinely about `Sₙ` rather than an arbitrary group.
* Synthesis: combined with `LinearCharacters.lean` (two explicit rows) this pins down
  the shape `p(n)` of the `Sₙ` character table.
-/

open Equiv Equiv.Perm

/-! ### Partition ↔ conjugacy-class bijection (reproduced from the catalog) -/

namespace PartitionConjClasses

variable {n : ℕ}

/-- Transporting a partition along an equality of its index does not change its parts. -/
lemma parts_cast {a b : ℕ} (h : a = b) (q : a.Partition) : (h ▸ q).parts = q.parts := by
  subst h; rfl

/-- For a partition `p` of `n`, there is a permutation of `Fin n` whose cycle type is the
multiset of parts of `p` that are at least `2`. -/
lemma exists_perm_cycleType (p : Nat.Partition n) :
    ∃ g : Equiv.Perm (Fin n), g.cycleType = p.parts.filter (2 ≤ ·) := by
  convert ( Equiv.Perm.exists_with_cycleType_iff _ ).mpr ?_ using 1;
  simp +zetaDelta at *;
  have := p.parts_sum;
  grind +suggestions

/-- The permutation associated to a partition. -/
noncomputable def permOfPartition (p : Nat.Partition n) : Equiv.Perm (Fin n) :=
  (exists_perm_cycleType p).choose

/-- The cycle type of `permOfPartition p` is the multiset of parts of `p` that are at
least `2`. -/
lemma permOfPartition_cycleType (p : Nat.Partition n) :
    (permOfPartition p).cycleType = p.parts.filter (2 ≤ ·) :=
  (exists_perm_cycleType p).choose_spec

/-- The parts of the partition associated to `permOfPartition p` are exactly the parts
of `p`. -/
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

/-- The backward map: a conjugacy class is sent to the partition of any representative. -/
noncomputable def ofConjClass (c : ConjClasses (Equiv.Perm (Fin n))) : Nat.Partition n :=
  Quotient.liftOn c permPartition
    (fun _ _ h => by
      simp only [permPartition]
      rw [(Equiv.Perm.partition_eq_of_isConj).mp h])

lemma ofConjClass_mk (σ : Equiv.Perm (Fin n)) :
    ofConjClass (ConjClasses.mk σ) = permPartition σ := rfl

/-- `permOfPartition p` is conjugate to any permutation whose partition has the same
parts as `p`. -/
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

/-! ### New results: cardinalities and the `S₃/S₄/S₅` character-table sizes -/

namespace SnConjClassCount

/-- **The number of conjugacy classes of `Sₙ` equals the number of partitions of `n`.**
Equivalently, the character table of `Sₙ` has exactly `p(n)` rows. -/
theorem card_conjClasses_eq_card_partition (n : ℕ) :
    Fintype.card (ConjClasses (Equiv.Perm (Fin n))) = Fintype.card (Nat.Partition n) :=
  (Fintype.card_congr (PartitionConjClasses.partitionEquivConjClasses (n := n))).symm

/-- The character table of `S₃` is `3 × 3`: `S₃` has `p(3) = 3` conjugacy classes. -/
theorem card_conjClasses_S3 :
    Fintype.card (ConjClasses (Equiv.Perm (Fin 3))) = 3 := by
  rw [card_conjClasses_eq_card_partition]
  native_decide

/-- The character table of `S₄` is `5 × 5`: `S₄` has `p(4) = 5` conjugacy classes. -/
theorem card_conjClasses_S4 :
    Fintype.card (ConjClasses (Equiv.Perm (Fin 4))) = 5 := by
  rw [card_conjClasses_eq_card_partition]
  native_decide

/-- The character table of `S₅` is `7 × 7`: `S₅` has `p(5) = 7` conjugacy classes. -/
theorem card_conjClasses_S5 :
    Fintype.card (ConjClasses (Equiv.Perm (Fin 5))) = 7 := by
  rw [card_conjClasses_eq_card_partition]
  native_decide

end SnConjClassCount