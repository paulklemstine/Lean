import Mathlib
import Bridges.PigeonholeInjectionBridge.PigeonholeInjectionBridge

/-! # Subsequence Ramsey Bounds for Finite Genetic Alphabets

A word of length `m` sampled at an aligned position is represented by a function
`Fin m → α`.  Thus an alphabet of size `q` has exactly `q^m` possible words.
The results below combine this coding observation with finite pigeonhole arguments:
more than `q^m` aligned samples force two equal words, and more than `r q^m`
samples force one word to occur at least `r+1` times.

The distinction between aligned blocks and arbitrary subsequences is essential.
The universal statements here provide rigorous upper bounds; genome-dependent
claims require an explicit sequence and cannot follow from alphabet size alone.
-/

namespace DNASubsequenceRamsey

/-- The length-`m` word beginning at aligned block `i` in an infinite sequence. -/
def alignedBlock (x : ℕ → α) (m : ℕ) (i : ℕ) : Fin m → α :=
  fun j => x (i * m + j)

/-
There are `|α|^m` words of length `m` over a finite alphabet `α`.
-/
theorem card_word_space (α : Type*) [Fintype α] (m : ℕ) :
    Fintype.card (Fin m → α) = Fintype.card α ^ m := by
  simp +decide [ Finset.card_univ ]

/-
If more aligned blocks are sampled than there are words, two sampled blocks agree.
This is the basic Ramsey-style collision theorem for finite alphabets.
-/
theorem aligned_block_collision {α : Type*} [Fintype α]
    (x : ℕ → α) (m n : ℕ) (h : Fintype.card α ^ m < n) :
    ∃ i j : Fin n, i < j ∧ alignedBlock x m i = alignedBlock x m j := by
  contrapose! h with h_contra
  convert PigeonholeInjectionBridge.card_le_of_injective _
    (show Function.Injective (fun i : Fin n => alignedBlock x m (i : ℕ)) from
      fun i j hij => le_antisymm
        (le_of_not_gt fun hi => h_contra j i hi hij.symm)
        (le_of_not_gt fun hj => h_contra i j hj hij)) using 1
  · simp +decide
  · rw [card_word_space]

/-
A block collision is an equality of two disjoint, order-preserving subsequences,
with the second copy beginning after the first whenever the block length is positive.
-/
theorem collision_gives_disjoint_subsequences {α : Type*}
    (x : ℕ → α) (m i j : ℕ) (hij : i < j)
    (hblock : alignedBlock x m i = alignedBlock x m j) :
    (∀ t : Fin m, x (i * m + t) = x (j * m + t)) ∧
      (0 < m → i * m + m ≤ j * m) := by
  exact ⟨ fun t => congr_fun hblock t, fun hm => by nlinarith ⟩

/-
Quantitative supersaturation: among more than `r |α|^m` aligned samples,
one length-`m` word occurs at least `r+1` times.
-/
theorem frequent_aligned_block {α : Type*} [Fintype α] [DecidableEq α]
    (x : ℕ → α) (m n r : ℕ) (h : Fintype.card α ^ m * r < n) :
    ∃ w : Fin m → α,
      r < Fintype.card {i : Fin n // alignedBlock x m i = w} := by
  convert Fintype.exists_lt_card_fiber_of_mul_lt_card _ _;
  rotate_left;
  exact Fin n;
  all_goals try infer_instance;
  exact fun i j => x ( i * m + j );
  · simpa [ card_word_space ] using h;
  · rw [ Fintype.subtype_card ];
    convert rfl

/-
Avoiding repeated aligned words imposes the sharp coding bound `n ≤ |α|^m`.
-/
theorem aligned_avoidance_bound {α : Type*} [Fintype α]
    (x : ℕ → α) (m n : ℕ)
    (havoid : ∀ i j : Fin n, alignedBlock x m i = alignedBlock x m j → i = j) :
    n ≤ Fintype.card α ^ m := by
  contrapose! havoid;
  obtain ⟨ i, j, hij, h ⟩ := aligned_block_collision x m n havoid;
  exact ⟨ i, j, h, ne_of_lt hij ⟩

/-
DNA specialization: among 257 aligned four-base words, two agree.  Their
starting positions lie below 1028 and the copies are disjoint.
-/
theorem dna_four_mer_collision (x : ℕ → Fin 4) :
    ∃ i j : ℕ, i < j ∧ j * 4 + 3 < 1028 ∧
      (∀ t : Fin 4, x (i * 4 + t) = x (j * 4 + t)) ∧ i * 4 + 4 ≤ j * 4 := by
  obtain ⟨i, j, hij, hblock⟩ : ∃ i j : Fin 257, i < j ∧ alignedBlock x 4 i = alignedBlock x 4 j := by
    convert aligned_block_collision x 4 257 (by norm_num) using 1
  exact ⟨ i, j, hij, by linarith [ Fin.is_lt i, Fin.is_lt j ], fun t => congr_fun hblock t, by linarith [ show ( i : ℕ ) < j from hij ] ⟩

-- !-- Lab Notes -- !--
/-
Hypothesis (Hypothesizer): Finite-word coding should turn subsequence repetition
into a hierarchy: collision, geometric separation, multiplicity, and an extremal
avoidance bound.  A genome-independent four-mer threshold should emerge without
probabilistic assumptions.

Experiment (Experimenter): The alphabet was kept arbitrary through the structural
results and specialized only at the end.  The experiments distinguished arbitrary
subsequences from aligned contiguous samples, since conflating them makes several
proposed thresholds ill-posed.  Multiplicity was tested through fibers of the block
coding map rather than by repeated pairwise collision arguments.

Analysis (Analyst): The governing invariant is the cardinality `|α|^m` of word
space.  Pairwise collision and high multiplicity are two levels of the same fiber
principle.  Equal aligned blocks also produce equal order-preserving subsequences;
positive block length upgrades this to disjointness.

Critique (Critic): The bounds are worst-case and say nothing by themselves about a
specific human genome or a random-genome distribution.  The often-quoted value
near 5000 is not `256 log 256` under the natural logarithm, and a factor-of-five
compression cannot be asserted without sequence data and a precise window statistic.
The DNA result concerns 257 aligned blocks (1028 bases), not every choice of an
arbitrary subsequence.

Synthesis (Principal Investigator): The resulting theorem chain gives a sharp,
generic coding bound, a stronger repeated-fiber theorem, and a concrete DNA
corollary.  It also isolates exactly which empirical and probabilistic claims remain
outside the finite pigeonhole argument.
-/

end DNASubsequenceRamsey