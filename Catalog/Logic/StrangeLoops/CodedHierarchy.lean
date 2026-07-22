import Mathlib

/-!
# Coded strange loops, Tarski's barrier, and infinitely many Gödel sentences

A diagonal lemma ranges over *representable object-language predicates*, not over every
metatheoretic predicate.  This file makes that distinction explicit by introducing a
type of predicate codes and a semantics for those codes.  This avoids the inconsistent
assumption that semantic negation of truth itself is available to diagonalization.

The main results are:

* a coded Gödel sentence is true and independent in every sound coded system;
* the predicate “is not true” cannot be represented (a Tarski-style barrier);
* if a system has rank-separated codes for its own unprovability, it contains an
  injectively indexed infinite family of independent strange loops;
* truth-preserving, proof-reflecting interpretations transport incompleteness, so a
  two-way interpretability cycle gives an explicit tangled hierarchy.
-/

noncomputable section

namespace CodedStrangeLoops

/-- A formal system whose diagonalization applies only to predicates represented by
object-language codes. -/
structure CodedDiagonalSystem where
  Sentence : Type
  Code : Type
  denotes : Code → Sentence → Prop
  codeNeg : Code → Code
  denotes_codeNeg : ∀ c s, denotes (codeNeg c) s ↔ ¬ denotes c s
  Provable : Sentence → Prop
  True_ : Sentence → Prop
  sound : ∀ s, Provable s → True_ s
  neg : Sentence → Sentence
  true_neg : ∀ s, True_ (neg s) ↔ ¬ True_ s
  diag : Code → Sentence
  diag_spec : ∀ c, True_ (diag c) ↔ denotes c (diag c)
  unprovabilityCode : Code
  unprovability_spec : ∀ s, denotes unprovabilityCode s ↔ ¬ Provable s

namespace CodedDiagonalSystem

/-- The diagonalization of the represented unprovability predicate. -/
def goedelSentence (S : CodedDiagonalSystem) : S.Sentence :=
  S.diag S.unprovabilityCode

/-- The coded Gödel sentence says precisely that it is not provable. -/
theorem goedel_fixed_point (S : CodedDiagonalSystem) :
    S.True_ S.goedelSentence ↔ ¬ S.Provable S.goedelSentence := by
  rw [goedelSentence, S.diag_spec, S.unprovability_spec]

/-- Soundness makes the coded Gödel sentence unprovable. -/
theorem goedel_unprovable (S : CodedDiagonalSystem) :
    ¬ S.Provable S.goedelSentence := by
  intro hp
  exact (S.goedel_fixed_point.mp (S.sound _ hp)) hp

/-- The coded Gödel sentence is semantically true. -/
theorem goedel_true (S : CodedDiagonalSystem) :
    S.True_ S.goedelSentence := by
  exact S.goedel_fixed_point.mpr S.goedel_unprovable

/-- Neither the coded Gödel sentence nor its object-language negation is provable. -/
theorem goedel_independent (S : CodedDiagonalSystem) :
    ¬ S.Provable S.goedelSentence ∧ ¬ S.Provable (S.neg S.goedelSentence) := by
  refine ⟨S.goedel_unprovable, ?_⟩
  intro hn
  have hnt : S.True_ (S.neg S.goedelSentence) := S.sound _ hn
  exact (S.true_neg S.goedelSentence).mp hnt S.goedel_true

/-- **Tarski barrier.** No available predicate code can denote semantic untruth.
Otherwise its diagonal sentence would be true exactly when it was not true. -/
theorem no_code_for_semantic_untruth (S : CodedDiagonalSystem) :
    ¬ ∃ c : S.Code, ∀ s : S.Sentence, S.denotes c s ↔ ¬ S.True_ s := by
  rintro ⟨c, hc⟩
  have hliar : S.True_ (S.diag c) ↔ ¬ S.True_ (S.diag c) :=
    (S.diag_spec c).trans (hc (S.diag c))
  by_cases ht : S.True_ (S.diag c)
  · exact (hliar.mp ht) ht
  · exact ht (hliar.mpr ht)

/-- **Tarski undefinability of truth.** No code can define the full semantic truth
predicate.  Closure of represented predicates under negation would turn such a code
into a forbidden code for semantic untruth.  This does not prohibit harmless
individual truth-tellers; it prohibits a uniform truth predicate. -/
theorem no_code_for_semantic_truth (S : CodedDiagonalSystem) :
    ¬ ∃ c : S.Code, ∀ s : S.Sentence, S.denotes c s ↔ S.True_ s := by
  rintro ⟨c, hc⟩
  apply S.no_code_for_semantic_untruth
  refine ⟨S.codeNeg c, ?_⟩
  intro s
  rw [S.denotes_codeNeg, hc]

/-- Consequently, the semantics map from codes to predicates is not surjective. -/
theorem semantics_not_surjective (S : CodedDiagonalSystem) :
    ¬ Function.Surjective S.denotes := by
  intro hsurj
  obtain ⟨c, hc⟩ := hsurj (fun s => ¬ S.True_ s)
  apply S.no_code_for_semantic_untruth
  exact ⟨c, fun s => by rw [hc]⟩

end CodedDiagonalSystem

/-- A sufficiently expressive ranked system: for every natural rank it has a code
for unprovability, and diagonalization at that code produces a sentence of exactly
that rank.  Rank separation is the explicit syntactic resource that turns one Gödel
loop into infinitely many distinct loops. -/
structure RankedDiagonalSystem extends CodedDiagonalSystem where
  rank : Sentence → ℕ
  rankedUnprovabilityCode : ℕ → Code
  ranked_unprovability_spec :
    ∀ n s, denotes (rankedUnprovabilityCode n) s ↔ ¬ Provable s
  diag_rank : ∀ n, rank (diag (rankedUnprovabilityCode n)) = n

namespace RankedDiagonalSystem

/-- The rank-`n` Gödel sentence. -/
def rankedGoedel (S : RankedDiagonalSystem) (n : ℕ) : S.Sentence :=
  S.diag (S.rankedUnprovabilityCode n)

/-- Every ranked Gödel sentence has its prescribed syntactic rank. -/
theorem rank_rankedGoedel (S : RankedDiagonalSystem) (n : ℕ) :
    S.rank (S.rankedGoedel n) = n := by
  exact S.diag_rank n

/-- Every ranked Gödel sentence is a strange loop for unprovability. -/
theorem rankedGoedel_fixed_point (S : RankedDiagonalSystem) (n : ℕ) :
    S.True_ (S.rankedGoedel n) ↔ ¬ S.Provable (S.rankedGoedel n) := by
  rw [rankedGoedel, S.diag_spec, S.ranked_unprovability_spec]

/-- Every ranked Gödel sentence is true. -/
theorem rankedGoedel_true (S : RankedDiagonalSystem) (n : ℕ) :
    S.True_ (S.rankedGoedel n) := by
  have hnot : ¬ S.Provable (S.rankedGoedel n) := by
    intro hp
    exact (S.rankedGoedel_fixed_point n).mp (S.sound _ hp) hp
  exact (S.rankedGoedel_fixed_point n).mpr hnot

/-- Every ranked Gödel sentence is independent. -/
theorem rankedGoedel_independent (S : RankedDiagonalSystem) (n : ℕ) :
    ¬ S.Provable (S.rankedGoedel n) ∧
      ¬ S.Provable (S.neg (S.rankedGoedel n)) := by
  constructor
  · intro hp
    exact (S.rankedGoedel_fixed_point n).mp (S.sound _ hp) hp
  · intro hn
    have hnt := S.sound _ hn
    exact (S.true_neg (S.rankedGoedel n)).mp hnt (S.rankedGoedel_true n)

/-- Rank separation makes the family of Gödel sentences injective. -/
theorem rankedGoedel_injective (S : RankedDiagonalSystem) :
    Function.Injective S.rankedGoedel := by
  intro m n h
  calc
    m = S.rank (S.rankedGoedel m) := (S.rank_rankedGoedel m).symm
    _ = S.rank (S.rankedGoedel n) := congrArg S.rank h
    _ = n := S.rank_rankedGoedel n

/-- **Infinitely many strange loops.** The set of ranked Gödel sentences is infinite,
and every member is a true independent fixed point of unprovability. -/
theorem infinitely_many_independent_strange_loops (S : RankedDiagonalSystem) :
    Set.Infinite (Set.range S.rankedGoedel) ∧
    ∀ n, S.True_ (S.rankedGoedel n) ∧
      ¬ S.Provable (S.rankedGoedel n) ∧
      ¬ S.Provable (S.neg (S.rankedGoedel n)) := by
  constructor
  · exact Set.infinite_range_of_injective S.rankedGoedel_injective
  · intro n
    exact ⟨S.rankedGoedel_true n, S.rankedGoedel_independent n⟩

end RankedDiagonalSystem

/-- An interpretation preserves truth and reflects proofs.  Proof reflection is the
condition needed to transport an unprovability result backwards across translation. -/
structure Interpretation (S T : CodedDiagonalSystem) where
  translate : S.Sentence → T.Sentence
  truth_iff : ∀ s, T.True_ (translate s) ↔ S.True_ s
  reflects_proof : ∀ s, T.Provable (translate s) → S.Provable s

namespace Interpretation

/-- A true-but-unprovable sentence remains true-but-unprovable under a
truth-preserving, proof-reflecting interpretation. -/
theorem transports_incompleteness {S T : CodedDiagonalSystem}
    (I : Interpretation S T) {s : S.Sentence}
    (hs : S.True_ s ∧ ¬ S.Provable s) :
    T.True_ (I.translate s) ∧ ¬ T.Provable (I.translate s) := by
  constructor
  · exact (I.truth_iff s).mpr hs.1
  · intro hp
    exact hs.2 (I.reflects_proof s hp)

end Interpretation

/-- A two-level tangled hierarchy: each formal level interprets the other. -/
structure TwoLevelTangle where
  lower : CodedDiagonalSystem
  upper : CodedDiagonalSystem
  up : Interpretation lower upper
  down : Interpretation upper lower

namespace TwoLevelTangle

/-- In a two-way hierarchy, each level contains both its own Gödel witness and the
translated witness arriving around the interpretability cycle. -/
theorem incompleteness_on_both_sides (H : TwoLevelTangle) :
    (H.lower.True_ H.lower.goedelSentence ∧
      ¬ H.lower.Provable H.lower.goedelSentence) ∧
    (H.upper.True_ (H.up.translate H.lower.goedelSentence) ∧
      ¬ H.upper.Provable (H.up.translate H.lower.goedelSentence)) ∧
    (H.upper.True_ H.upper.goedelSentence ∧
      ¬ H.upper.Provable H.upper.goedelSentence) ∧
    (H.lower.True_ (H.down.translate H.upper.goedelSentence) ∧
      ¬ H.lower.Provable (H.down.translate H.upper.goedelSentence)) := by
  have hl : H.lower.True_ H.lower.goedelSentence ∧
      ¬ H.lower.Provable H.lower.goedelSentence :=
    ⟨H.lower.goedel_true, H.lower.goedel_unprovable⟩
  have hu : H.upper.True_ H.upper.goedelSentence ∧
      ¬ H.upper.Provable H.upper.goedelSentence :=
    ⟨H.upper.goedel_true, H.upper.goedel_unprovable⟩
  exact ⟨hl, H.up.transports_incompleteness hl, hu,
    H.down.transports_incompleteness hu⟩

end TwoLevelTangle

#print axioms CodedDiagonalSystem.goedel_independent
#print axioms CodedDiagonalSystem.no_code_for_semantic_untruth
#print axioms CodedDiagonalSystem.no_code_for_semantic_truth
#print axioms CodedDiagonalSystem.semantics_not_surjective
#print axioms RankedDiagonalSystem.infinitely_many_independent_strange_loops
#print axioms TwoLevelTangle.incompleteness_on_both_sides

end CodedStrangeLoops