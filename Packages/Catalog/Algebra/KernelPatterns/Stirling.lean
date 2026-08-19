/-
# The block-refined count: Stirling numbers of the second kind

Refining `KernelPattern.card_pattern` (there are `Nat.bell n` equality patterns on `n`
letters) by the number of blocks produces the Stirling numbers of the second kind.

This file defines `KernelPattern.stirling2` by the classical recurrence
`S(n+1, k+1) = (k+1) * S(n, k+1) + S(n, k)` and proves

* `KernelPattern.card_patternWithBlocks` — the patterns on `n` letters with exactly `k`
  blocks number `stirling2 n k`;
* `KernelPattern.sum_stirling2_eq_bell` — summing over the block count recovers
  `Nat.bell n`, i.e. `∑_{k ≤ n} S(n,k) = B(n)`.

The proof is the "last letter" fibration: deleting the last coordinate of a pattern on
`n+1` letters gives a pattern on `n` letters, and the fibre over `q` is parametrised by
the value of the pattern at the last coordinate, which is either a block representative
of `q` (leaving the block count unchanged) or the last coordinate itself (creating a new
block).
-/
import Algebra.KernelPatterns.Core
import Algebra.KernelPatterns.Blocks

namespace KernelPattern

open Finset

variable {n k : ℕ}

/-- Stirling numbers of the second kind, by the classical recurrence. -/
def stirling2 : ℕ → ℕ → ℕ
  | 0, 0 => 1
  | 0, _ + 1 => 0
  | _ + 1, 0 => 0
  | n + 1, k + 1 => (k + 1) * stirling2 n (k + 1) + stirling2 n k

@[simp] theorem stirling2_zero_zero : stirling2 0 0 = 1 := rfl
@[simp] theorem stirling2_zero_succ (k : ℕ) : stirling2 0 (k + 1) = 0 := rfl
@[simp] theorem stirling2_succ_zero (n : ℕ) : stirling2 (n + 1) 0 = 0 := rfl
theorem stirling2_succ_succ (n k : ℕ) :
    stirling2 (n + 1) (k + 1) = (k + 1) * stirling2 n (k + 1) + stirling2 n k := rfl

/-! ## Deleting the last letter -/

/-- The restriction of a pattern on `n+1` letters to its first `n` letters. -/
def restr (p : Pattern (n + 1)) : Pattern n := by
  refine ⟨fun i => ⟨(p.1 i.castSucc).val, ?_⟩, ?_⟩
  · have h : p.1 i.castSucc ≤ i.castSucc := (p.2 i.castSucc).1
    have : (p.1 i.castSucc).val ≤ i.val := h
    exact lt_of_le_of_lt this i.isLt
  · intro i
    constructor
    · have h : p.1 i.castSucc ≤ i.castSucc := (p.2 i.castSucc).1
      exact (show (p.1 i.castSucc).val ≤ i.val from h)
    · apply Fin.ext
      have hcast : (⟨(p.1 i.castSucc).val, by
          have h : p.1 i.castSucc ≤ i.castSucc := (p.2 i.castSucc).1
          exact lt_of_le_of_lt (show (p.1 i.castSucc).val ≤ i.val from h) i.isLt⟩ :
            Fin n).castSucc = p.1 i.castSucc := by
        apply Fin.ext; rfl
      show (p.1 _).val = (p.1 i.castSucc).val
      rw [hcast, (p.2 i.castSucc).2]

theorem castSucc_restr (p : Pattern (n + 1)) (i : Fin n) :
    ((restr p).1 i).castSucc = p.1 i.castSucc := by
  apply Fin.ext; rfl

/-- The value of an extension at the last letter is either a block representative of the
restricted pattern, or the last letter itself (opening a new block). -/
def IsExtValue (q : Pattern n) (v : Fin (n + 1)) : Prop :=
  v = Fin.last n ∨ ∃ j : Fin n, v = j.castSucc ∧ q.1 j = j

instance (q : Pattern n) (v : Fin (n + 1)) : Decidable (IsExtValue q v) := by
  unfold IsExtValue; infer_instance

/-- Extension of a pattern on `n` letters by a prescribed value at the last letter. -/
def ext (q : Pattern n) (v : Fin (n + 1)) (hv : IsExtValue q v) : Pattern (n + 1) := by
  refine ⟨fun i => if h : i = Fin.last n then v else ((q.1 (i.castPred h)).castSucc), ?_⟩
  have hvle : v ≤ Fin.last n := Fin.le_last v
  intro i
  constructor
  · by_cases h : i = Fin.last n
    · simp only [h, dif_pos]
      exact hvle
    · simp only [h, dif_neg, not_false_iff]
      calc (q.1 (i.castPred h)).castSucc ≤ (i.castPred h).castSucc :=
              Fin.castSucc_le_castSucc_iff.2 (q.2 (i.castPred h)).1
      _ = i := Fin.castSucc_castPred i h
  · by_cases h : i = Fin.last n
    · simp only [h, dif_pos]
      rcases hv with hv | ⟨j, hj, hqj⟩
      · simp [hv]
      · subst hj
        have hne : (j.castSucc : Fin (n + 1)) ≠ Fin.last n := Fin.castSucc_ne_last j
        simp only [hne, dif_neg, not_false_iff]
        rw [Fin.castPred_castSucc, hqj]
    · simp only [h, dif_neg, not_false_iff]
      have hne : (q.1 (i.castPred h)).castSucc ≠ Fin.last n :=
        Fin.castSucc_ne_last _
      simp only [hne, dif_neg, not_false_iff]
      rw [Fin.castPred_castSucc, (q.2 (i.castPred h)).2]

theorem ext_last (q : Pattern n) (v : Fin (n + 1)) (hv : IsExtValue q v) :
    (ext q v hv).1 (Fin.last n) = v := by
  simp [ext]

theorem ext_castSucc (q : Pattern n) (v : Fin (n + 1)) (hv : IsExtValue q v) (i : Fin n) :
    (ext q v hv).1 i.castSucc = (q.1 i).castSucc := by
  have h : i.castSucc ≠ Fin.last n := Fin.castSucc_ne_last i
  simp only [ext, h, dif_neg, not_false_iff]
  rw [Fin.castPred_castSucc]

theorem restr_ext (q : Pattern n) (v : Fin (n + 1)) (hv : IsExtValue q v) :
    restr (ext q v hv) = q := by
  apply Subtype.ext
  funext i
  apply Fin.castSucc_injective
  rw [castSucc_restr, ext_castSucc]

theorem isExtValue_last_value (p : Pattern (n + 1)) : IsExtValue (restr p) (p.1 (Fin.last n)) := by
  by_cases h : p.1 (Fin.last n) = Fin.last n
  · exact Or.inl h
  · refine Or.inr ⟨(p.1 (Fin.last n)).castPred h, (Fin.castSucc_castPred _ h).symm, ?_⟩
    apply Fin.castSucc_injective
    rw [castSucc_restr, Fin.castSucc_castPred _ h, (p.2 (Fin.last n)).2]

theorem ext_restr (p : Pattern (n + 1)) :
    ext (restr p) (p.1 (Fin.last n)) (isExtValue_last_value p) = p := by
  apply Subtype.ext
  funext i
  by_cases h : i = Fin.last n
  · rw [h, ext_last]
  · rw [← Fin.castSucc_castPred i h, ext_castSucc, castSucc_restr]

/-! ## Block counts of extensions -/

/-- The blocks of a pattern are exactly its fixed points. -/
theorem image_eq_filter_fixed (q : Pattern n) :
    Finset.image q.1 Finset.univ = Finset.univ.filter fun j => q.1 j = j := by
  ext w
  simp only [Finset.mem_image, Finset.mem_filter, Finset.mem_univ, true_and]
  constructor
  · rintro ⟨i, rfl⟩
    exact (q.2 i).2
  · intro hw
    exact ⟨w, hw⟩

theorem numBlocks_eq_card_fixed (q : Pattern n) :
    numBlocks q = (Finset.univ.filter fun j => q.1 j = j).card := by
  rw [numBlocks, image_eq_filter_fixed]

theorem card_image_castSucc_comp (q : Pattern n) :
    (Finset.image (fun i => (q.1 i).castSucc) Finset.univ).card = numBlocks q := by
  have h : Finset.image (fun i => (q.1 i).castSucc) (Finset.univ : Finset (Fin n))
      = Finset.image Fin.castSucc (Finset.image q.1 Finset.univ) := by
    rw [Finset.image_image]
    rfl
  rw [h, Finset.card_image_of_injective _ (Fin.castSucc_injective n)]
  rfl

theorem image_ext (q : Pattern n) (v : Fin (n + 1)) (hv : IsExtValue q v) :
    Finset.image (ext q v hv).1 Finset.univ
      = insert v (Finset.image (fun i => (q.1 i).castSucc) Finset.univ) := by
  ext w
  simp only [Finset.mem_image, Finset.mem_insert, Finset.mem_univ, true_and]
  constructor
  · rintro ⟨i, rfl⟩
    by_cases h : i = Fin.last n
    · exact Or.inl (by rw [h, ext_last])
    · exact Or.inr ⟨i.castPred h, by
        rw [← ext_castSucc q v hv (i.castPred h), Fin.castSucc_castPred i h]⟩
  · rintro (rfl | ⟨i, rfl⟩)
    · exact ⟨Fin.last n, ext_last _ _ hv⟩
    · exact ⟨i.castSucc, ext_castSucc _ _ hv i⟩

/-- Extending by the last letter creates a new block; extending by a block
representative does not. -/
theorem numBlocks_ext (q : Pattern n) (v : Fin (n + 1)) (hv : IsExtValue q v) :
    numBlocks (ext q v hv) = numBlocks q + (if v = Fin.last n then 1 else 0) := by
  rw [numBlocks, image_ext q v hv]
  rcases hv with hlast | ⟨j, rfl, hqj⟩
  · subst hlast
    have hnot : Fin.last n ∉ Finset.image (fun i => (q.1 i).castSucc) (Finset.univ : Finset (Fin n)) := by
      intro hmem
      obtain ⟨i, -, hi⟩ := Finset.mem_image.mp hmem
      exact absurd hi (Fin.castSucc_ne_last _)
    rw [Finset.card_insert_of_notMem hnot, card_image_castSucc_comp]
    simp
  · have hmem : (j.castSucc : Fin (n + 1))
        ∈ Finset.image (fun i => (q.1 i).castSucc) (Finset.univ : Finset (Fin n)) :=
      Finset.mem_image.2 ⟨j, Finset.mem_univ _, by rw [hqj]⟩
    rw [Finset.insert_eq_self.2 hmem, card_image_castSucc_comp]
    have hne : (j.castSucc : Fin (n + 1)) ≠ Fin.last n := Fin.castSucc_ne_last j
    simp [hne]

/-! ## The fibration by the restricted pattern -/

/-- The patterns on `n` letters with exactly `k` blocks. -/
def patternsWith (n k : ℕ) : Finset (Pattern n) :=
  Finset.univ.filter fun p => numBlocks p = k

/-- The number of patterns on `n` letters with exactly `k` blocks. -/
def numPat (n k : ℕ) : ℕ := (patternsWith n k).card

theorem mem_patternsWith {p : Pattern n} : p ∈ patternsWith n k ↔ numBlocks p = k := by
  simp [patternsWith]

/-- Total version of `ext`, defaulting to the new-block extension. -/
def extTotal (q : Pattern n) (v : Fin (n + 1)) : Pattern (n + 1) :=
  if hv : IsExtValue q v then ext q v hv else ext q (Fin.last n) (Or.inl rfl)

theorem extTotal_eq (q : Pattern n) (v : Fin (n + 1)) (hv : IsExtValue q v) :
    extTotal q v = ext q v hv := dif_pos hv

theorem numBlocks_extTotal (q : Pattern n) (v : Fin (n + 1)) (hv : IsExtValue q v) :
    numBlocks (extTotal q v) = numBlocks q + (if v = Fin.last n then 1 else 0) := by
  rw [extTotal_eq q v hv, numBlocks_ext]

/-- The admissible last values, i.e. the fibre of the restriction map, described inside
`Fin (n+1)`. -/
def extValues (q : Pattern n) (k : ℕ) : Finset (Fin (n + 1)) :=
  Finset.univ.filter fun v => IsExtValue q v ∧ numBlocks (extTotal q v) = k

theorem card_fiber_eq_card_extValues (q : Pattern n) (k : ℕ) :
    ((patternsWith (n + 1) k).filter fun p => restr p = q).card = (extValues q k).card := by
  refine Finset.card_bij (fun p _ => p.1 (Fin.last n)) ?_ ?_ ?_
  · intro p hp
    rw [Finset.mem_filter, mem_patternsWith] at hp
    obtain ⟨hblocks, hres⟩ := hp
    have hval : IsExtValue q (p.1 (Fin.last n)) := by
      rw [← hres]; exact isExtValue_last_value p
    refine Finset.mem_filter.2 ⟨Finset.mem_univ _, hval, ?_⟩
    rw [extTotal_eq q _ hval]
    have : ext q (p.1 (Fin.last n)) hval = p := by
      subst hres
      exact ext_restr p
    rw [this, hblocks]
  · intro p hp p' hp' hval
    rw [Finset.mem_filter] at hp hp'
    have h1 : ext (restr p) (p.1 (Fin.last n)) (isExtValue_last_value p) = p := ext_restr p
    have h2 : ext (restr p') (p'.1 (Fin.last n)) (isExtValue_last_value p') = p' := ext_restr p'
    rw [← h1, ← h2]
    simp only [hp.2, hp'.2, hval]
  · intro v hv
    simp only [extValues, Finset.mem_filter] at hv
    obtain ⟨-, hval, hblocks⟩ := hv
    refine ⟨extTotal q v, ?_, ?_⟩
    · refine Finset.mem_filter.2 ⟨mem_patternsWith.2 hblocks, ?_⟩
      rw [extTotal_eq q v hval, restr_ext]
    · show (extTotal q v).1 (Fin.last n) = v
      rw [extTotal_eq q v hval, ext_last]

theorem extValues_eq_of_eq_succ (q : Pattern n) (k : ℕ) (hq : numBlocks q = k + 1) :
    extValues q (k + 1) = Finset.image Fin.castSucc (Finset.univ.filter fun j => q.1 j = j) := by
  ext v
  simp only [extValues, Finset.mem_filter, Finset.mem_univ, true_and, Finset.mem_image]
  constructor
  · rintro ⟨hval, hblocks⟩
    rw [numBlocks_extTotal q v hval, hq] at hblocks
    have hne : v ≠ Fin.last n := by
      intro hlast
      rw [hlast] at hblocks
      simp at hblocks
    rcases hval with h | ⟨j, rfl, hqj⟩
    · exact absurd h hne
    · exact ⟨j, hqj, rfl⟩
  · rintro ⟨j, hj, rfl⟩
    have hval : IsExtValue q j.castSucc := Or.inr ⟨j, rfl, hj⟩
    refine ⟨hval, ?_⟩
    rw [numBlocks_extTotal q _ hval, hq]
    simp [Fin.castSucc_ne_last j]

theorem extValues_eq_of_eq (q : Pattern n) (k : ℕ) (hq : numBlocks q = k) :
    extValues q (k + 1) = {Fin.last n} := by
  ext v
  simp only [extValues, Finset.mem_filter, Finset.mem_univ, true_and, Finset.mem_singleton]
  constructor
  · rintro ⟨hval, hblocks⟩
    rw [numBlocks_extTotal q v hval, hq] at hblocks
    by_contra hne
    simp [hne] at hblocks
  · rintro rfl
    have hval : IsExtValue q (Fin.last n) := Or.inl rfl
    refine ⟨hval, ?_⟩
    rw [numBlocks_extTotal q _ hval, hq]
    simp

theorem extValues_eq_empty (q : Pattern n) (k : ℕ) (h1 : numBlocks q ≠ k + 1)
    (h2 : numBlocks q ≠ k) : extValues q (k + 1) = ∅ := by
  ext v
  simp only [extValues, Finset.mem_filter, Finset.mem_univ, true_and, Finset.notMem_empty,
    iff_false, not_and]
  intro hval hblocks
  rw [numBlocks_extTotal q v hval] at hblocks
  by_cases hlast : v = Fin.last n
  · rw [hlast] at hblocks
    simp at hblocks
    exact h2 (by omega)
  · simp [hlast] at hblocks
    exact h1 hblocks

theorem card_extValues (q : Pattern n) (k : ℕ) :
    (extValues q (k + 1)).card
      = (if numBlocks q = k + 1 then k + 1 else 0) + (if numBlocks q = k then 1 else 0) := by
  by_cases h1 : numBlocks q = k + 1
  · have h2 : numBlocks q ≠ k := by omega
    rw [extValues_eq_of_eq_succ q k h1,
      Finset.card_image_of_injective _ (Fin.castSucc_injective n),
      ← numBlocks_eq_card_fixed, h1]
    simp
  · by_cases h2 : numBlocks q = k
    · rw [extValues_eq_of_eq q k h2]
      simp [h2]
    · rw [extValues_eq_empty q k h1 h2]
      simp [h1, h2]

/-- **The Stirling recurrence**, proved by fibring the patterns on `n+1` letters over
their restriction to the first `n` letters. -/
theorem numPat_succ_succ (n k : ℕ) :
    numPat (n + 1) (k + 1) = (k + 1) * numPat n (k + 1) + numPat n k := by
  have hfib : (patternsWith (n + 1) (k + 1)).card
      = ∑ q ∈ (Finset.univ : Finset (Pattern n)),
          ((patternsWith (n + 1) (k + 1)).filter fun p => restr p = q).card :=
    Finset.card_eq_sum_card_fiberwise fun p _ => Finset.mem_univ _
  have hterm : ∀ q ∈ (Finset.univ : Finset (Pattern n)),
      ((patternsWith (n + 1) (k + 1)).filter fun p => restr p = q).card
        = (if numBlocks q = k + 1 then k + 1 else 0) + (if numBlocks q = k then 1 else 0) := by
    intro q _
    rw [card_fiber_eq_card_extValues q (k + 1), card_extValues]
  rw [numPat, hfib, Finset.sum_congr rfl hterm, Finset.sum_add_distrib,
    ← Finset.sum_filter, ← Finset.sum_filter, Finset.sum_const, Finset.sum_const,
    smul_eq_mul, smul_eq_mul, numPat, numPat, patternsWith, patternsWith]
  ring

theorem numPat_zero_zero : numPat 0 0 = 1 := by decide

theorem numBlocks_zero (p : Pattern 0) : numBlocks p = 0 := by
  simp [numBlocks]

theorem numPat_zero_succ (k : ℕ) : numPat 0 (k + 1) = 0 := by
  rw [numPat, Finset.card_eq_zero, patternsWith, Finset.filter_eq_empty_iff]
  intro p _
  rw [numBlocks_zero p]
  omega

theorem numBlocks_pos (p : Pattern (n + 1)) : 0 < numBlocks p := by
  rw [numBlocks, Finset.card_pos]
  exact ⟨p.1 0, Finset.mem_image.2 ⟨0, Finset.mem_univ _, rfl⟩⟩

theorem numPat_succ_zero (n : ℕ) : numPat (n + 1) 0 = 0 := by
  rw [numPat, Finset.card_eq_zero, patternsWith, Finset.filter_eq_empty_iff]
  intro p _
  exact (numBlocks_pos p).ne'

/-- **Patterns with a prescribed number of blocks are counted by the Stirling numbers of
the second kind.** -/
theorem numPat_eq_stirling2 (n k : ℕ) : numPat n k = stirling2 n k := by
  induction n generalizing k with
  | zero =>
    cases k with
    | zero => rw [numPat_zero_zero, stirling2_zero_zero]
    | succ k => rw [numPat_zero_succ, stirling2_zero_succ]
  | succ n ih =>
    cases k with
    | zero => rw [numPat_succ_zero, stirling2_succ_zero]
    | succ k => rw [numPat_succ_succ, stirling2_succ_succ, ih, ih]

/-- The block-refined count, spelled out. -/
theorem card_patternWithBlocks (n k : ℕ) :
    (Finset.univ.filter fun p : Pattern n => numBlocks p = k).card = stirling2 n k :=
  numPat_eq_stirling2 n k

theorem numBlocks_le (p : Pattern n) : numBlocks p ≤ n := by
  have := Finset.card_le_univ (Finset.image p.1 Finset.univ)
  simpa [numBlocks] using this

/-- **Summing the Stirling numbers over the block count gives the Bell number.** -/
theorem sum_stirling2_eq_bell (n : ℕ) :
    ∑ k ∈ Finset.range (n + 1), stirling2 n k = Nat.bell n := by
  have hfib : (Finset.univ : Finset (Pattern n)).card
      = ∑ k ∈ Finset.range (n + 1),
          ((Finset.univ : Finset (Pattern n)).filter fun p => numBlocks p = k).card :=
    Finset.card_eq_sum_card_fiberwise fun p _ =>
      Finset.mem_range.2 (Nat.lt_succ_of_le (numBlocks_le p))
  have hsum : ∑ k ∈ Finset.range (n + 1), stirling2 n k
      = ∑ k ∈ Finset.range (n + 1),
          ((Finset.univ : Finset (Pattern n)).filter fun p => numBlocks p = k).card :=
    Finset.sum_congr rfl fun k _ => (card_patternWithBlocks n k).symm
  rw [hsum, ← hfib, Finset.card_univ, card_pattern]

/-! ## Small cases

The Stirling triangle for `n ≤ 5`, each row summing to the corresponding Bell number. -/

theorem stirling2_row_four : (stirling2 4 0, stirling2 4 1, stirling2 4 2, stirling2 4 3,
    stirling2 4 4) = (0, 1, 7, 6, 1) := by decide

theorem stirling2_row_five : (stirling2 5 0, stirling2 5 1, stirling2 5 2, stirling2 5 3,
    stirling2 5 4, stirling2 5 5) = (0, 1, 15, 25, 10, 1) := by decide

/-- The fifth Bell number as the sum of a Stirling row: `1 + 15 + 25 + 10 + 1 = 52`. -/
theorem bell_five_eq_sum_stirling_row : Nat.bell 5 = 52 := by
  rw [← sum_stirling2_eq_bell 5]
  decide

end KernelPattern