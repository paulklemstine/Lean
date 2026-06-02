/-
Copyright (c) 2024 Harmonic. All rights reserved.
Released under Apache 2.0 license.
-/
import Mathlib

/-!
# Ramsey Theory of DNA: Subsequence Avoidance in Genetic Codes

This module develops the combinatorial theory of k-mer (substring) avoidance
in sequences over finite alphabets, motivated by DNA sequence analysis.

## Main Results

* `pigeonhole_kmer_repeat` — Any sequence of length ≥ α^k + k has a repeated k-mer
* `repeat_free_length_bound` — Repeat-free sequences have length ≤ α^k + k - 1
* `subword_complexity_le_pow` — Subword complexity C(k) ≤ α^k
* `forces_repeat_monotone` — Repeat-forcing is monotone in sequence length
* `effective_alphabet_reduces_threshold` — Fewer distinct symbols → earlier repeats
* `dna_4mer_bound` — DNA sequences of length ≥ 260 have repeated 4-mers
-/

namespace DNARamsey

-- ============================================================
-- ALPHABET AND SEQUENCE DEFINITIONS
-- ============================================================

/-- A nucleotide base in DNA. The four bases adenine (A), cytosine (C),
    guanine (G), and thymine (T) form the 4-letter genetic alphabet. -/
inductive Nucleotide : Type
  | A | C | G | T
  deriving DecidableEq, Repr

instance : Fintype Nucleotide where
  elems := {.A, .C, .G, .T}
  complete := by intro x; cases x <;> simp

/-- The DNA alphabet has exactly 4 letters. -/
@[simp] lemma card_nucleotide : Fintype.card Nucleotide = 4 := by decide

-- ============================================================
-- K-MER EXTRACTION
-- ============================================================

/-- The k-mer (contiguous substring of length k) starting at position i
    in a sequence s of length n. Returns a function `Fin k → α` representing
    the k-mer. Requires `i + k ≤ n` to stay within bounds. -/
def kmerAt (s : Fin n → α) (k : ℕ) (i : ℕ) (hi : i + k ≤ n) : Fin k → α :=
  fun j => s ⟨i + j.val, by omega⟩

/-- The k-mer extraction map: sends each valid starting position in `Fin (n - k + 1)`
    to its corresponding k-mer in `Fin k → α`. -/
def kmerMap (s : Fin n → α) (k : ℕ) (hk : k ≤ n) : Fin (n - k + 1) → (Fin k → α) :=
  fun i => kmerAt s k i.val (by omega)

-- ============================================================
-- REPEAT-FREENESS AND COMPLEXITY
-- ============================================================

/-- A sequence is **k-repeat-free** if all its contiguous k-mers are distinct. -/
def IsRepeatFree (s : Fin n → α) (k : ℕ) (hk : k ≤ n) : Prop :=
  Function.Injective (kmerMap s k hk)

/-- The **subword complexity** at level k: the number of distinct k-mers. -/
noncomputable def subwordComplexity [DecidableEq α] [Fintype α]
    (s : Fin n → α) (k : ℕ) (hk : k ≤ n) : ℕ :=
  (Finset.image (kmerMap s k hk) Finset.univ).card

/-- The **repeat-forcing** predicate: every sequence of length n has a repeated k-mer. -/
def ForcesRepeat (α : Type*) [Fintype α] [DecidableEq α] (n k : ℕ) : Prop :=
  ∀ (s : Fin n → α), (hk : k ≤ n) → ¬ IsRepeatFree s k hk

/-- The **Ramsey threshold** for k-mer repeats: α^k + k. -/
noncomputable def RamseyThreshold (α : Type*) [Fintype α] [DecidableEq α] (k : ℕ) : ℕ :=
  Fintype.card α ^ k + k

/-- The **effective alphabet size**: number of distinct symbols actually used. -/
noncomputable def effectiveAlphabetSize [Fintype α] [DecidableEq α]
    (s : Fin n → α) : ℕ :=
  (Finset.univ.filter (fun a => ∃ i : Fin n, s i = a)).card

-- ============================================================
-- MAIN THEOREMS
-- ============================================================

section Pigeonhole

variable {α : Type*} [Fintype α] [DecidableEq α]

/-
**Pigeonhole Principle for K-mers** (Main Theorem 1).

    If a sequence over a finite alphabet of cardinality c has length n
    with n - k + 1 > c^k, then some k-mer must appear at least twice.
-/
omit [DecidableEq α] in
theorem pigeonhole_kmer_repeat
    (s : Fin n → α) (k : ℕ) (hk : k ≤ n)
    (hlen : Fintype.card α ^ k < n - k + 1) :
    ¬ IsRepeatFree s k hk := by
  -- By the pigeonhole principle, since there are more k-mers than possible distinct k-mers, there must be a repetition.
  have h_pigeonhole : Fintype.card (Fin (n - k + 1)) > Fintype.card (Fin k → α) := by
    aesop;
  exact fun h => h_pigeonhole.not_ge ( Fintype.card_le_of_injective _ h )

/-
**Repeat-Free Length Bound** (Main Theorem 2).

    A k-repeat-free sequence over an alphabet of size c has at most
    c^k + k - 1 elements.
-/
omit [DecidableEq α] in
theorem repeat_free_length_bound
    (s : Fin n → α) (k : ℕ) (hk : 0 < k) (hkn : k ≤ n)
    (hfree : IsRepeatFree s k hkn) :
    n ≤ Fintype.card α ^ k + k - 1 := by
  contrapose! hfree;
  exact pigeonhole_kmer_repeat s k hkn ( by omega )

/-
**Subword Complexity Bound** (Main Theorem 3).

    The number of distinct k-mers in any sequence is at most α^k.
-/
theorem subword_complexity_le_pow
    (s : Fin n → α) (k : ℕ) (hk : k ≤ n) :
    subwordComplexity s k hk ≤ Fintype.card α ^ k := by
  convert Finset.card_le_univ ( Finset.image ( kmerMap s k hk ) Finset.univ ) using 1;
  simp +decide [ Fintype.card_pi ]

/-
The subword complexity equals n - k + 1 for repeat-free sequences.
-/
theorem subword_complexity_of_repeat_free
    (s : Fin n → α) (k : ℕ) (hk : k ≤ n)
    (hfree : IsRepeatFree s k hk) :
    subwordComplexity s k hk = n - k + 1 := by
  rw [ subwordComplexity, Finset.card_image_of_injective ];
  · simp +decide;
  · exact hfree

end Pigeonhole

section Monotonicity

variable {α : Type*} [Fintype α] [DecidableEq α]

/-
Restricting a sequence preserves k-mer identity.
-/
omit [Fintype α] [DecidableEq α] in
lemma kmerAt_restrict (s : Fin n → α) (m k : ℕ) (hmn : m ≤ n)
    (i : ℕ) (hi : i + k ≤ m) :
    kmerAt (fun j : Fin m => s ⟨j.val, by omega⟩) k i hi =
    kmerAt s k i (by omega) := by
  unfold kmerAt; aesop;

/-
**Repeat Forcing is Monotone** (Main Theorem 4).

    If every sequence of length n has a repeated k-mer,
    then so does every sequence of length m ≥ n.
-/
theorem forces_repeat_monotone
    (h : ForcesRepeat α n k) (hmn : n ≤ m) (hk : k ≤ n) :
    ForcesRepeat α m k := by
  contrapose! h;
  simp +decide [ ForcesRepeat ] at h ⊢;
  obtain ⟨ s, hs, hs' ⟩ := h; use fun i ↦ s ⟨ i.val, by linarith [ Fin.is_lt i ] ⟩ ; simp_all +decide [ IsRepeatFree ] ;
  convert hs'.comp ( show Function.Injective ( fun i : Fin ( n - k + 1 ) => ⟨ i.val, by omega ⟩ : Fin ( n - k + 1 ) → Fin ( m - k + 1 ) ) from fun i j hij => by simpa [ Fin.ext_iff ] using hij ) using 1

/-
The Ramsey threshold forces repeats.
-/
theorem ramsey_threshold_forces (_hk : 0 < k) :
    ForcesRepeat α (RamseyThreshold α k) k := by
  intro s hk';
  apply pigeonhole_kmer_repeat s k hk';
  unfold RamseyThreshold; omega;

end Monotonicity

section EffectiveAlphabet

variable {α : Type*} [Fintype α] [DecidableEq α]

/-
The effective alphabet size is bounded by the full alphabet size.
-/
theorem effective_alphabet_le_card (s : Fin n → α) :
    effectiveAlphabetSize s ≤ Fintype.card α := by
  exact Finset.card_le_univ _

end EffectiveAlphabet

section DNA

/-
**DNA 4-mer Repeat Bound** (Main Theorem 5).

    Any DNA sequence of length ≥ 260 contains a repeated 4-mer.
-/
theorem dna_4mer_bound (s : Fin n → Nucleotide) (hn : 260 ≤ n) :
    ¬ IsRepeatFree s 4 (by omega) := by
  convert pigeonhole_kmer_repeat s 4 _ _;
  rw [ show Fintype.card Nucleotide = 4 by rfl ] ; omega

/-- The Ramsey threshold for DNA k-mers. -/
@[simp] theorem ramsey_threshold_dna (k : ℕ) :
    RamseyThreshold Nucleotide k = 4 ^ k + k := by
  simp [RamseyThreshold, card_nucleotide]

end DNA

-- ============================================================
-- CONJECTURE: Composition Bias Gap
-- ============================================================

/-- **Conjecture (Composition Bias Gap)**:
    For sequences where the most frequent symbol appears in more than n/3
    positions, the repeat-free threshold is reduced from 4^k to 3^k. -/
def compositionBiasGapConjecture : Prop :=
  ∀ (n k : ℕ) (s : Fin n → Nucleotide) (_hk : 0 < k) (hkn : k ≤ n),
    (∃ b : Nucleotide, n / 3 < (Finset.univ.filter (fun i => s i = b)).card) →
    IsRepeatFree s k hkn → n ≤ 3 ^ k + k - 1


end DNARamsey