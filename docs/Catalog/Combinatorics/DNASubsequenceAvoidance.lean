import Mathlib

open Function

namespace DNASubsequenceAvoidance

/-- The `k`-mer beginning at position `i` in a finite word. -/
def selectedKmer {α : Type*} {m k : ℕ} (hkm : k ≤ m) (word : Fin m → α)
    (i : Fin (m - k + 1)) : Fin k → α :=
  fun j => word ⟨i.val + j.val, by omega⟩

/-- Pigeonhole threshold for repeated contiguous `k`-mers.  A word over an
alphabet of size `q` has a repeated `k`-mer as soon as its length is at least
`q^k + k`.  Applied after selecting indices, this is also a theorem about
arbitrary subsequences. -/
theorem selectedKmer_repeat_threshold {α : Type*} [Fintype α] [DecidableEq α]
    {m k : ℕ} (hm : Fintype.card α ^ k + k ≤ m) (word : Fin m → α) :
    ∃ i j : Fin (m - k + 1), i ≠ j ∧
      selectedKmer (by omega : k ≤ m) word i =
        selectedKmer (by omega : k ≤ m) word j := by
  convert Fintype.exists_ne_map_eq_of_card_lt _ _
  exacts [inferInstance, inferInstance, by
    simp only [Fintype.card_fin, Fintype.card_fun]
    omega]

/-- A repeat-free word cannot reach the pigeonhole threshold.  Thus the
number of symbols, not the length of a surrounding genome, controls the
universal obstruction. -/
theorem length_lt_threshold_of_repeat_free {α : Type*} [Fintype α]
    [DecidableEq α] {m k : ℕ} (hkm : k ≤ m) (word : Fin m → α)
    (hfree : Function.Injective (selectedKmer hkm word)) :
    m < Fintype.card α ^ k + k := by
  by_contra h
  have hm : Fintype.card α ^ k + k ≤ m := by omega
  obtain ⟨i, j, hij, heq⟩ := selectedKmer_repeat_threshold hm word
  exact hij (hfree heq)

/-- Every selected DNA word of length at least `260 = 4^4 + 4`
contains two equal contiguous four-letter words.  In particular this applies
when `pick` is a strictly increasing map encoding a genome subsequence. -/
theorem every_long_DNA_selection_has_repeated_fourMer {n m : ℕ}
    (genome : Fin n → Fin 4) (pick : Fin m → Fin n) (hm : 260 ≤ m) :
    ∃ i j : Fin (m - 4 + 1), i ≠ j ∧
      selectedKmer (by omega : 4 ≤ m) (genome ∘ pick) i =
        selectedKmer (by omega : 4 ≤ m) (genome ∘ pick) j := by
  apply selectedKmer_repeat_threshold (α := Fin 4) (k := 4) (word := genome ∘ pick)
  norm_num at hm ⊢
  exact hm

/-- The same DNA bound applies to the genome itself: length `260` suffices
for a repeated contiguous four-mer. -/
theorem DNA_word_has_repeated_fourMer {m : ℕ} (hm : 260 ≤ m)
    (word : Fin m → Fin 4) :
    ∃ i j : Fin (m - 4 + 1), i ≠ j ∧
      selectedKmer (by omega : 4 ≤ m) word i =
        selectedKmer (by omega : 4 ≤ m) word j := by
  apply selectedKmer_repeat_threshold (α := Fin 4) (k := 4) (word := word)
  norm_num at hm ⊢
  exact hm

/-- If a selected DNA word factors through an alphabet of only `b` effective
symbols, then the repeated-four-mer threshold drops from `4^4 + 4` to
`b^4 + 4`.  This is a deterministic formulation of complexity compression. -/
theorem repeated_fourMer_of_effective_alphabet {m b : ℕ}
    (hm : b ^ 4 + 4 ≤ m) (encode : Fin m → Fin b) (decode : Fin b → Fin 4) :
    ∃ i j : Fin (m - 4 + 1), i ≠ j ∧
      selectedKmer (by omega : 4 ≤ m) (decode ∘ encode) i =
        selectedKmer (by omega : 4 ≤ m) (decode ∘ encode) j := by
  have hm' : Fintype.card (Fin b) ^ 4 + 4 ≤ m := by simpa using hm
  obtain ⟨i, j, hij, heq⟩ :=
    selectedKmer_repeat_threshold (α := Fin b) (k := 4) hm' encode
  refine ⟨i, j, hij, ?_⟩
  funext x
  exact congrArg decode (congrFun heq x)

/-- A binary low-complexity region of length `20 = 2^4 + 4` already forces
a repeated DNA four-mer after any decoding of its two effective symbols. -/
theorem binary_region_has_repeated_fourMer {m : ℕ} (hm : 20 ≤ m)
    (encode : Fin m → Fin 2) (decode : Fin 2 → Fin 4) :
    ∃ i j : Fin (m - 4 + 1), i ≠ j ∧
      selectedKmer (by omega : 4 ≤ m) (decode ∘ encode) i =
        selectedKmer (by omega : 4 ≤ m) (decode ∘ encode) j := by
  apply repeated_fourMer_of_effective_alphabet (b := 2) (encode := encode) (decode := decode)
  norm_num at hm ⊢
  exact hm

end DNASubsequenceAvoidance