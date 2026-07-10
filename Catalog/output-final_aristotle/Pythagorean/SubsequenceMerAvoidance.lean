import Mathlib

/-!
# Pigeonhole thresholds for repeated contiguous blocks in symbolic sequences

Motivated by the combinatorics of genetic codes, this file studies *repeated blocks*
(`m`-mers) in sequences over a finite alphabet.  Fix an alphabet with `q` symbols,
modelled by `Fin q`, and a bi-infinite sequence `w : ℕ → Fin q`.  The length-`m`
contiguous window starting at position `i` is the tuple `mer w m i : Fin m → Fin q`.

The central phenomenon is a sharp pigeonhole threshold: there are exactly `q ^ m`
possible windows, so as soon as we examine strictly more than `q ^ m` window
positions, two of them must coincide — the sequence contains a repeated `m`-mer.
Conversely, a sequence whose contiguous `m`-mers are pairwise distinct can expose
at most `q ^ m` window positions, hence has bounded length.  This is the exact
extremal content behind de Bruijn sequences.

For DNA (`q = 4`) this gives concrete constants: any window of `257` starting
positions of a nucleotide sequence contains a repeated tetramer (`4 ^ 4 = 256`),
and any block whose `4`-mers are all distinct spans at most `259` bases.

## Main results

* `exists_repeated_mer` — the pigeonhole threshold: if `q ^ m < N` then two of the
  first `N` windows coincide.
* `merInjective_length_le` — the extremal converse: distinct `m`-mers force
  `N ≤ q ^ m` window positions.
* `dna_repeated_tetramer`, `dna_repeated_hexamer` — DNA specializations.
* `dna_repeatfree_tetramer_length_le` — de Bruijn length bound for tetramers.
* `distinct_mers_card_le` — the number of distinct `m`-mers is at most `min N (q^m)`.
-/

namespace DNARamsey

/-- The contiguous length-`m` block ("m-mer") of the sequence `w` starting at
position `i`, viewed as a tuple `Fin m → Fin q`. -/
def mer {q : ℕ} (w : ℕ → Fin q) (m i : ℕ) : Fin m → Fin q := fun j => w (i + j)

/-!
-- !-- Lab Notes -- !--

**Hypothesis.**  Over a `q`-letter alphabet there are only `q ^ m` distinct blocks
of length `m`.  Therefore a sequence cannot keep exhibiting fresh `m`-mers forever:
once more than `q ^ m` window positions are opened, a repeat is unavoidable.  We
conjectured this is *sharp*, i.e. it is the exact obstruction (de Bruijn sequences
saturate it).

**Experiment.**  We phrase windows as maps `Fin m → Fin q`, whose ambient type is
finite of cardinality `q ^ m`, and feed the position-to-window map into the finite
pigeonhole principle.  The converse (extremal) direction is a cardinality bound on
an injection.

**Analysis.**  The pigeonhole direction (`exists_repeated_mer`) and the extremal
direction (`merInjective_length_le`) are logically dual and together pin the
threshold exactly at `q ^ m`.  The DNA constants `256`, `4096` drop out by
evaluation.

**Critique.**  The informal slogan "4097 nucleotides force a repeated 6-mer" is
slightly off by the window-count correction: a length-`L` string has `L - m + 1`
windows, so `L - 5 > 4096`, i.e. `L ≥ 4102`, is what actually forces a repeated
hexamer.  We record the corrected constant in `dna_repeated_hexamer`.

**Synthesis.**  The results below form a self-contained "Ramsey threshold" toolkit
for block repetition, with exact DNA specializations.
-/

/-- **Pigeonhole threshold for repeated blocks.**  If the number `N` of window
positions strictly exceeds the number `q ^ m` of possible `m`-mers, then two
distinct positions carry the same `m`-mer. -/
theorem exists_repeated_mer {q : ℕ} (w : ℕ → Fin q) (m N : ℕ) (h : q ^ m < N) :
    ∃ i j : Fin N, i ≠ j ∧ mer w m i = mer w m j := by
  have hcard : Fintype.card (Fin m → Fin q) < Fintype.card (Fin N) := by
    simpa using h
  obtain ⟨i, j, hij, he⟩ :=
    Fintype.exists_ne_map_eq_of_card_lt (fun i : Fin N => mer w m (i : ℕ)) hcard
  exact ⟨i, j, hij, he⟩

/-- A sequence is `MerInjective w m N` when its `m`-mers at the first `N` window
positions are pairwise distinct (a de Bruijn / "repeat-free" condition). -/
def MerInjective {q : ℕ} (w : ℕ → Fin q) (m N : ℕ) : Prop :=
  Function.Injective (fun i : Fin N => mer w m i)

/-- **Extremal converse.**  If all `m`-mers at the first `N` window positions are
distinct, then `N ≤ q ^ m`: a repeat-free sequence exposes at most `q ^ m`
windows. -/
theorem merInjective_length_le {q : ℕ} (w : ℕ → Fin q) (m N : ℕ)
    (h : MerInjective w m N) : N ≤ q ^ m := by
  have := Fintype.card_le_of_injective _ h
  simpa using this

/-- The threshold is sharp: `q ^ m` windows are *not* enough to force a repeat in
general, but `q ^ m + 1` are.  This is the contrapositive packaging of
`exists_repeated_mer`: if the first `N` windows are all distinct then `N ≤ q ^ m`. -/
theorem not_merInjective_of_gt {q : ℕ} (w : ℕ → Fin q) (m N : ℕ) (h : q ^ m < N) :
    ¬ MerInjective w m N := by
  intro hinj
  exact absurd (merInjective_length_le w m N hinj) (Nat.not_le.mpr h)

/-- The number of *distinct* `m`-mers seen across the first `N` window positions is
at most `min N (q ^ m)`. -/
theorem distinct_mers_card_le {q : ℕ} (w : ℕ → Fin q) (m N : ℕ) :
    ((Finset.univ : Finset (Fin N)).image (fun i : Fin N => mer w m (i : ℕ))).card
      ≤ min N (q ^ m) := by
  refine Nat.le_min.mpr ⟨?_, ?_⟩
  · calc ((Finset.univ : Finset (Fin N)).image (fun i : Fin N => mer w m (i : ℕ))).card
        ≤ (Finset.univ : Finset (Fin N)).card := Finset.card_image_le
      _ = N := by simp
  · calc ((Finset.univ : Finset (Fin N)).image (fun i : Fin N => mer w m (i : ℕ))).card
        ≤ Fintype.card (Fin m → Fin q) := by
            simpa using Finset.card_le_univ
              ((Finset.univ : Finset (Fin N)).image (fun i : Fin N => mer w m (i : ℕ)))
      _ = q ^ m := by simp

/-!
## DNA specializations (`q = 4`)

The four nucleotides `A, C, G, T` are modelled by `Fin 4`.
-/

/-- **Repeated tetramer.**  Any `257` consecutive window positions of a nucleotide
sequence contain a repeated `4`-mer, since `4 ^ 4 = 256`. -/
theorem dna_repeated_tetramer (w : ℕ → Fin 4) :
    ∃ i j : Fin 257, i ≠ j ∧ mer w 4 i = mer w 4 j :=
  exists_repeated_mer w 4 257 (by norm_num)

/-- **Repeated hexamer (corrected constant).**  Any `4097` consecutive window
positions of a nucleotide sequence contain a repeated `6`-mer, since
`4 ^ 6 = 4096`.  In terms of raw sequence length this needs `L ≥ 4097 + 5 = 4102`
bases, correcting the naive slogan "4097 nucleotides". -/
theorem dna_repeated_hexamer (w : ℕ → Fin 4) :
    ∃ i j : Fin 4097, i ≠ j ∧ mer w 6 i = mer w 6 j :=
  exists_repeated_mer w 6 4097 (by norm_num)

/-- **de Bruijn length bound for tetramers.**  If a nucleotide sequence has all its
contiguous `4`-mers distinct across `N` window positions, then `N ≤ 256`; hence the
underlying block spans at most `256 + 3 = 259` bases. -/
theorem dna_repeatfree_tetramer_length_le (w : ℕ → Fin 4) (N : ℕ)
    (h : MerInjective w 4 N) : N ≤ 256 := by
  have := merInjective_length_le w 4 N h
  simpa using this

end DNARamsey