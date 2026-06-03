/-
# Library of Babel: Combinatorics of Everything

We formalize the combinatorial and topological structure of Borges' Library of Babel:
the space of all possible books over a finite alphabet of fixed length.

## Main results:
- Hamming distance forms a metric on the book space
- Triangle inequality for Hamming distance (genuine proof, not trivial)
- Incompressibility theorem: most books cannot be compressed (pigeonhole)
- The book space is totally disconnected under the discrete topology
-/

import Mathlib

open Finset

namespace LibraryOfBabel

/-! ## Basic Definitions -/

/-- The alphabet size in the Library of Babel. Borges uses 25 symbols
    (22 letters + period + comma + space). -/
abbrev alphabetSize : ℕ := 25

/-- Characters per page (80 chars × 40 lines). -/
abbrev charsPerPage : ℕ := 3200

/-- Number of pages per book. -/
abbrev numPages : ℕ := 410

/-- Total characters per book. -/
abbrev bookLength : ℕ := numPages * charsPerPage

/-- A book in the Library of Babel is a function from positions to symbols.
    We define it as a type alias for clarity. -/
abbrev BabelBook := Fin bookLength → Fin alphabetSize

/-! ## Hamming Distance

We define the Hamming distance generically over `Fin n → Fin k` and prove
it satisfies the metric axioms. The key insight is the triangle inequality,
which requires careful counting of disagreement positions. -/

/-- The Hamming distance between two words: the number of positions where they differ. -/
def hammingDist {n k : ℕ} (x y : Fin n → Fin k) : ℕ :=
  (Finset.univ.filter fun i => x i ≠ y i).card

/-- Hamming distance is symmetric. -/
theorem hammingDist_symm {n k : ℕ} (x y : Fin n → Fin k) :
    hammingDist x y = hammingDist y x := by
  unfold hammingDist
  congr 1
  ext i
  simp [ne_comm]

/-
Hamming distance is zero iff words are equal.
-/
theorem hammingDist_eq_zero_iff {n k : ℕ} (x y : Fin n → Fin k) :
    hammingDist x y = 0 ↔ x = y := by
      simp +decide [ hammingDist, funext_iff ]

/-
**Triangle Inequality for Hamming Distance.**
If two words disagree at position i, then at least one of them disagrees with
any third word at position i. This is the key insight: the set of positions
where x and z differ is contained in the union of positions where x and y differ
and positions where y and z differ.
-/
theorem hammingDist_triangle {n k : ℕ} (x y z : Fin n → Fin k) :
    hammingDist x z ≤ hammingDist x y + hammingDist y z := by
      rw [ hammingDist, hammingDist, hammingDist ];
      rw [ ← Finset.card_union_add_card_inter ];
      exact le_add_right ( Finset.card_le_card fun i hi => by by_cases hi' : x i = y i <;> aesop )

/-
Hamming distance is bounded by word length.
-/
theorem hammingDist_le_length {n k : ℕ} (x y : Fin n → Fin k) :
    hammingDist x y ≤ n := by
      exact le_trans ( Finset.card_le_univ _ ) ( by simp )

/-! ## Incompressibility via Pigeonhole

The central information-theoretic result: for any injective mapping from words
to a smaller set, not all words can be mapped. Hence most words are "incompressible".

The argument is pure pigeonhole: if |domain| > |codomain|, no injection exists
from the full domain. We prove this for the set of "recoverable" words. -/

/-
**Incompressibility Theorem (Pigeonhole).**
Given any pair of functions compress : A → B and decompress : B → A,
the number of elements a ∈ A satisfying decompress(compress(a)) = a
is at most |B|. This is because compress restricted to such elements is injective,
and injective functions from a finite set to a finite set give |domain| ≤ |codomain|.
-/
theorem compressible_card_le {α β : Type*} [Fintype α] [Fintype β] [DecidableEq α]
    (compress : α → β) (decompress : β → α) :
    (Finset.univ.filter fun a => decompress (compress a) = a).card ≤ Fintype.card β := by
      by_contra h_contra;
      have h_inj : Function.Injective (fun a : {a : α | decompress (compress a) = a} => compress a) := by
        intro a b; aesop;
      exact h_contra ( by simpa [ Fintype.card_subtype ] using Fintype.card_le_of_injective _ h_inj )

/-
**Majority Incompressibility.**
When the total number of elements exceeds twice the compressed space size,
the majority of elements are incompressible under any compression scheme.
-/
theorem majority_incompressible {α β : Type*} [Fintype α] [Fintype β] [DecidableEq α]
    (hsize : 2 * Fintype.card β < Fintype.card α)
    (compress : α → β) (decompress : β → α) :
    (Finset.univ.filter fun a => decompress (compress a) ≠ a).card >
    (Finset.univ.filter fun a => decompress (compress a) = a).card := by
      -- By definition of compressible and incompressible sets, we have that the total number of elements in α is the sum of the sizes of these sets.
      have h_total : (Finset.univ.filter (fun a => decompress (compress a) = a)).card + (Finset.univ.filter (fun a => decompress (compress a) ≠ a)).card = Fintype.card α := by
        rw [ Finset.card_filter_add_card_filter_not, Finset.card_univ ];
      linarith [ compressible_card_le compress decompress ]

/-! ## Hamming Ball Combinatorics -/

/-- The Hamming ball of radius r around a center word. -/
def hammingBall {n k : ℕ} (center : Fin n → Fin k) (r : ℕ) : Finset (Fin n → Fin k) :=
  Finset.univ.filter fun w => hammingDist center w ≤ r

/-
Hamming balls of radius 0 are singletons.
-/
theorem hammingBall_zero_card {n k : ℕ} [NeZero k]
    (center : Fin n → Fin k) :
    (hammingBall center 0).card = 1 := by
      rw [ Finset.card_eq_one ] ; use center ; ext ; simp_all +decide [ hammingBall, hammingDist ] ; aesop;

/-
Hamming balls of maximum radius contain all words.
-/
theorem hammingBall_full {n k : ℕ} [NeZero k] (center : Fin n → Fin k) :
    hammingBall center n = Finset.univ := by
      exact Finset.filter_true_of_mem fun x _ => hammingDist_le_length center x

/-! ## Topological Structure: Total Disconnectedness

In the discrete topology on a finite type, every singleton is clopen,
every connected component is a singleton, and the space is totally disconnected.
This gives covering dimension 0. -/

/-
In a finite type with the discrete topology, every singleton is clopen.
-/
theorem singleton_clopen_of_discrete {α : Type*} [TopologicalSpace α] [DiscreteTopology α]
    (a : α) : IsClopen ({a} : Set α) := by
      constructor <;> aesop

/-
A finite discrete space is totally disconnected.
-/
theorem totallyDisconnected_of_discrete {α : Type*} [TopologicalSpace α] [DiscreteTopology α] :
    IsTotallyDisconnected (Set.univ : Set α) := by
      intro s hs;
      intro h;
      intro x hx y hy; have := h.subsingleton hx hy; aesop;

/-
The book space (with discrete topology) has the property that
    all connected components are singletons, hence covering dimension 0.
-/
theorem babelBook_connected_components_singletons :
    ∀ (b : BabelBook), connectedComponent b = {b} := by
      simp +zetaDelta at *

/-! ## Counting -/

/-
The cardinality of the book space equals alphabetSize ^ bookLength.
-/
theorem babelBook_card :
    Fintype.card BabelBook = alphabetSize ^ bookLength := by
      rw [ Fintype.card_pi ] ; aesop

/-- The maximum possible Hamming distance between any two Babel books. -/
theorem babelBook_maxDist :
    ∀ (x y : BabelBook), hammingDist x y ≤ bookLength :=
  fun x y => hammingDist_le_length x y

/-! ## Novel Definition: Lexicographic Entropy Profile

The **entropy profile** of a word captures the local complexity at each scale.
For a word w of length n over alphabet k, the entropy profile at scale s
counts the number of distinct s-grams (subwords of length s).

This is a novel structure that connects information theory to the combinatorics
of the Library. High-entropy books have many distinct subwords at every scale;
low-entropy books (like "aaa...a") have few. -/

/-- The set of s-grams (contiguous subwords of length s) in a word.
    Returns the set of starting positions that yield distinct s-grams. -/
noncomputable def distinctSgrams {n k : ℕ} (w : Fin n → Fin k) (s : ℕ) : ℕ :=
  if hs : s ≤ n then
    (Finset.univ.filter fun (i : Fin (n - s + 1)) =>
      ∀ j : Fin (n - s + 1), j < i →
        ∃ p : Fin s, w ⟨i.val + p.val, by omega⟩ ≠ w ⟨j.val + p.val, by omega⟩
    ).card
  else 0

/-- A book is **maximally complex** if it has the maximum number of distinct s-grams
    at every scale s ≤ some threshold. -/
def IsMaximallyComplex {n k : ℕ} (w : Fin n → Fin k) (threshold : ℕ) : Prop :=
  ∀ s, 1 ≤ s → s ≤ threshold → distinctSgrams w s = min (n - s + 1) (k ^ s)

/-! ## Conjecture: Hamming Distance Concentration

**Conjecture**: For the Library of Babel with alphabet size k and book length n,
for any fixed book x, the fraction of books y with
  |hammingDist x y - n * (k-1)/k| > n^(1/2) * t
is at most 2 * exp(-2t²).

This is a Hoeffding-type concentration inequality. Each position contributes
independently to the Hamming distance with probability (k-1)/k of disagreeing.

**Testable prediction**: For k=25, n=1312000, the standard deviation of the
Hamming distance distribution is approximately sqrt(n * (k-1)/k²) ≈ 224.
So 99.7% of all book pairs should have Hamming distance within 672 of the mean
1259520. This can be verified by sampling. -/

end LibraryOfBabel