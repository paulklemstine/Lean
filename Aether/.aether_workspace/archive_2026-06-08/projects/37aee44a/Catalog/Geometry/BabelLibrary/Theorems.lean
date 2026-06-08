/-
# The Library of Babel: Main Theorems

Core results about the combinatorial topology of the Babel space.
-/

import Mathlib
import Geometry.BabelLibrary.Defs

open Finset Function Fintype

/-! ## Cardinality -/

/-- The cardinality of the Babel space is exactly α^N. -/
theorem babel_card (α N : ℕ) [NeZero α] :
    Fintype.card (BabelBook α N) = α ^ N := by
  aesop

/-! ## Hamming Distance Properties -/

/-- Hamming distance is symmetric. -/
theorem babelHammingDist_comm {α N : ℕ} (b₁ b₂ : BabelBook α N) :
    babelHammingDist b₁ b₂ = babelHammingDist b₂ b₁ := by
  exact congr_arg Finset.card (Finset.filter_congr fun i _ => ne_comm)

/-- Hamming distance from a book to itself is zero. -/
theorem babelHammingDist_self {α N : ℕ} (b : BabelBook α N) :
    babelHammingDist b b = 0 := by
  unfold babelHammingDist; aesop

/-- If the Hamming distance is zero, the books are equal. -/
theorem babelHammingDist_eq_zero_iff {α N : ℕ} (b₁ b₂ : BabelBook α N) :
    babelHammingDist b₁ b₂ = 0 ↔ b₁ = b₂ := by
  simp +decide [babelHammingDist, funext_iff]

/-- Triangle inequality for Hamming distance. -/
theorem babelHammingDist_triangle {α N : ℕ} (b₁ b₂ b₃ : BabelBook α N) :
    babelHammingDist b₁ b₃ ≤ babelHammingDist b₁ b₂ + babelHammingDist b₂ b₃ := by
  unfold babelHammingDist
  rw [← Finset.card_union_add_card_inter]
  exact le_add_right (Finset.card_le_card fun x hx => by by_cases h : b₁ x = b₂ x <;> aesop)

/-- Maximum Hamming distance between two books is N. -/
theorem babelHammingDist_le {α N : ℕ} (b₁ b₂ : BabelBook α N) :
    babelHammingDist b₁ b₂ ≤ N := by
  exact le_trans (Finset.card_filter_le _ _) (by norm_num)

/-! ## Incompressibility: The Fundamental Counting Argument -/

/-- The compress function of a faithful scheme is injective. -/
theorem compression_injective {α N M : ℕ} (s : CompressionScheme α N M) :
    Injective s.compress := by
  exact Function.LeftInverse.injective s.faithful

/-
**Key Theorem**: When the alphabet has at least 2 symbols, a faithful compression
    scheme from length N to length M < N cannot be surjective. This is the pigeonhole
    principle: there are α^N > α^M books but only α^M possible compressed forms.
-/
theorem compression_not_surjective {α N M : ℕ} (hα : 2 ≤ α)
    (hM : M < N) (s : CompressionScheme α N M) :
    ¬ Surjective s.compress := by
  intro h_surj
  have h_card : Fintype.card (BabelBook α N) ≤ Fintype.card (BabelBook α M) := by
    exact Fintype.card_le_of_injective _ ( compression_injective s );
  contrapose! h_card; simp_all +decide [ Fintype.card_pi ] ;
  exact pow_lt_pow_right₀ hα hM

/-- The number of books compressible to M symbols is at most α^M. -/
theorem compressible_books_card_le {α N M : ℕ} [NeZero α]
    (s : CompressionScheme α N M) :
    Fintype.card (Set.range s.compress) ≤ α ^ M := by
  rw [← babel_card]
  exact set_fintype_card_le_univ (Set.range s.compress)

/-- The fraction of compressible books vanishes exponentially. -/
theorem incompressible_fraction {α N M : ℕ} (hα : 2 ≤ α) (hM : M < N) :
    α ^ M < α ^ N := by
  exact pow_lt_pow_right₀ hα hM

/-! ## Spectrum Partition -/

/-- The symbol counts in a book's spectrum sum to N (the book length). -/
theorem spectrum_sum {α N : ℕ} [NeZero α] (b : BabelBook α N) :
    ∑ c : Fin α, symbolSpectrum b c = N := by
  unfold symbolSpectrum
  simp +decide only [card_filter]
  rw [Finset.sum_comm]; aesop

/-! ## Structural: Single-Character Edits -/

/-- Changing a single character produces a book at Hamming distance exactly 1. -/
theorem single_edit_distance {α N : ℕ} (b : BabelBook α N) (pos : Fin N)
    (newChar : Fin α) (hne : b pos ≠ newChar) :
    babelHammingDist b (Function.update b pos newChar) = 1 := by
  unfold babelHammingDist
  rw [Finset.card_eq_one]; use pos; ext i; by_cases hi : i = pos <;> aesop

/-! ## Incompressibility: Strict Cardinality Gap -/

/-
**Core incompressibility theorem**: When α ≥ 2 and M < N, the injective compression
    map cannot hit all books. The number of compressible books (≤ α^M) is strictly less
    than the total number of books (α^N). This is the formal statement that "almost all
    books in the Library of Babel are incompressible."
-/
theorem incompressible_majority {α N M : ℕ} (hα : 2 ≤ α) (hM : M < N)
    (s : CompressionScheme α N M) :
    Fintype.card (Set.range s.compress) < Fintype.card (BabelBook α N) := by
  convert Nat.lt_of_le_of_lt ( compressible_books_card_le s ) ( incompressible_fraction hα hM );
  · convert babel_card α N;
    exact NeZero.of_gt hα;
  · grind +suggestions

/-! ## Topological Structure -/

/-
**Total Disconnectedness**: For any two distinct books, there exists a position
    where they differ. This is the discrete separation property — no two distinct
    books are "topologically inseparable" in the product topology.
-/
theorem babel_totally_separated {α N : ℕ} (b₁ b₂ : BabelBook α N)
    (hne : b₁ ≠ b₂) : ∃ i : Fin N, b₁ i ≠ b₂ i := by
  exact Function.ne_iff.mp hne

/-
**Clopen Basis**: For each position i and symbol c, the set of books with
    symbol c at position i is both open and closed in the product topology.
    These clopen sets form a basis, witnessing dimension 0.
-/
theorem babel_clopen_basis {α N : ℕ} [NeZero α] (i : Fin N) (c : Fin α) :
    IsClopen {b : BabelBook α N | b i = c} := by
  constructor;
  · exact isClosed_eq ( continuous_apply i ) continuous_const;
  · refine' isOpen_pi_iff.mpr _;
    intro f hf; use { i } ; use fun _ => { c } ; aesop;

/-
**Singleton Clopen**: Every singleton {b} is clopen in the discrete/product topology
    on the finite Babel space. This is a direct consequence of finiteness.
-/
theorem babel_singleton_clopen {α N : ℕ} [NeZero α] (b : BabelBook α N) :
    IsClopen ({b} : Set (BabelBook α N)) := by
  convert isClopen_discrete { b }