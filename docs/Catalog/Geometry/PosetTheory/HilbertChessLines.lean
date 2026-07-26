/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Aristotle (Harmonic)
-/
import Mathlib

/-!
# Infinite-board chess: the sharp line-covering threshold for checkmate

We play chess on the **Hilbert board** `ℤ × ℤ`.  The pieces of interest are the
*long-range* pieces — rooks, bishops and queens — each of whose reach along a
single ray is an **affine line**

```
{ (x, y) | a * x + b * y = c }   with (a, b) ≠ (0, 0).
```

Modelling every long-range attacker as such a `Line` covers all of them at once:
a rook is a horizontal (`a = 0`) or vertical (`b = 0`) line, a bishop is a
diagonal (`a = ±1, b = ∓1`) line, a queen is either, and in fact *any* straight
ray in any direction is included.

This generality is what distinguishes the development here from an axis-parallel
(rook-only) treatment: we obtain a **sharp threshold** for how many long-range
pieces are needed to trap a king, valid for arbitrary line directions.

## The chain of results

Each result feeds the next.

1. `Line.covered_snd_injOn` / `Line.covered_fst_injOn` — a line is functional in
   one coordinate: fixing the other coordinate pins the point down.
2. `Line.block_card_le_three` — **any single line covers at most `3` of the `9`
   squares of a king's `3 × 3` neighbourhood.**  (Uses 1.)
3. `blockCovered_card_le` — a configuration of `n` lines covers at most `3 * n`
   of those `9` squares.  (Uses 2, by induction on the list.)
4. `no_mate_with_lt_three` — **fewer than three long-range pieces can never
   checkmate a king**: the king always keeps a safe square in its neighbourhood.
   (Uses 3; `9 > 3 * 2`.)
5. `mate_exists` — **three pieces suffice**: three parallel rooks explicitly
   checkmate a king, so the threshold `3` is sharp.  (Independent construction.)
6. `covers_row_finite`, `attacked_row_finite`, `exists_safe_row`,
   `escape_infinite`, `escape_unbounded` — globally, any finite configuration
   leaves a whole cofinite family of safe squares, so the lone king can always
   flee arbitrarily far: the board is never fully covered.  (Uses 1.)
-/

namespace HilbertChess

/-- A square of the infinite (Hilbert) chessboard: the integer lattice `ℤ × ℤ`. -/
abbrev Square := ℤ × ℤ

/-- A long-range attacker — rook, bishop or queen ray — modelled by the affine
line `{ (x, y) | a * x + b * y = c }`, required non-degenerate `(a, b) ≠ 0`. -/
structure Line where
  a : ℤ
  b : ℤ
  c : ℤ
  nondeg : a ≠ 0 ∨ b ≠ 0

/-- The square `q` lies on (is attacked along) the line `L`. -/
def Line.covers (L : Line) (q : Square) : Prop := L.a * q.1 + L.b * q.2 = L.c

instance (L : Line) (q : Square) : Decidable (L.covers q) := by
  unfold Line.covers; infer_instance

/-- A square is attacked by a configuration `S` (a finite list of pieces) if some
piece covers it. -/
def attacked (S : List Line) (q : Square) : Prop := ∃ L ∈ S, L.covers q

instance (S : List Line) (q : Square) : Decidable (attacked S q) := by
  unfold attacked; infer_instance

/-- A square is safe if no piece of the configuration attacks it. -/
def safe (S : List Line) (q : Square) : Prop := ¬ attacked S q

/-! ## The king's `3 × 3` neighbourhood -/

/-- The nine offsets of a king's `3 × 3` neighbourhood (itself plus its eight
moves): all `(i, j)` with `i, j ∈ {-1, 0, 1}`. -/
def blockOffsets : Finset Square :=
  ({-1, 0, 1} : Finset ℤ) ×ˢ ({-1, 0, 1} : Finset ℤ)

/-- The eight king moves: the block offsets other than staying put. -/
def kingMoves : Finset Square := blockOffsets.erase (0, 0)

theorem blockOffsets_card : blockOffsets.card = 9 := by decide

theorem zero_mem_blockOffsets : (0, 0) ∈ blockOffsets := by decide

/-- The offsets a single line covers, relative to a center `p`. -/
def Line.blockCovered (L : Line) (p : Square) : Finset Square :=
  blockOffsets.filter (fun d => L.covers (p.1 + d.1, p.2 + d.2))

/-- The offsets covered by a whole configuration, relative to a center `p`. -/
def blockCovered (S : List Line) (p : Square) : Finset Square :=
  blockOffsets.filter (fun d => attacked S (p.1 + d.1, p.2 + d.2))

/-! ## Step 1: a line is functional in one coordinate -/

/-- If the horizontal coefficient is non-zero, two covered offsets with the same
second coordinate are equal: the line meets each row in at most one point. -/
theorem Line.covered_snd_injOn (L : Line) (p : Square) (ha : L.a ≠ 0) :
    Set.InjOn (fun d : Square => d.2) (L.blockCovered p : Set Square) := by
  intro d hd d' hd' hdd
  simp only [Line.blockCovered, Finset.coe_filter, Set.mem_setOf_eq, Line.covers] at hd hd'
  have h2 : d.2 = d'.2 := hdd
  have hmul : L.a * (p.1 + d.1) = L.a * (p.1 + d'.1) := by
    linear_combination hd.2 - hd'.2 - L.b * h2
  have hcancel : p.1 + d.1 = p.1 + d'.1 := mul_left_cancel₀ ha hmul
  exact Prod.ext (by omega) h2

/-- If the vertical coefficient is non-zero, two covered offsets with the same
first coordinate are equal: the line meets each column in at most one point. -/
theorem Line.covered_fst_injOn (L : Line) (p : Square) (hb : L.b ≠ 0) :
    Set.InjOn (fun d : Square => d.1) (L.blockCovered p : Set Square) := by
  intro d hd d' hd' hdd
  simp only [Line.blockCovered, Finset.coe_filter, Set.mem_setOf_eq, Line.covers] at hd hd'
  have h1 : d.1 = d'.1 := hdd
  have hmul : L.b * (p.2 + d.2) = L.b * (p.2 + d'.2) := by
    linear_combination hd.2 - hd'.2 - L.a * h1
  have hcancel : p.2 + d.2 = p.2 + d'.2 := mul_left_cancel₀ hb hmul
  exact Prod.ext h1 (by omega)

/-! ## Step 2: one line covers at most 3 of the 9 neighbourhood squares -/

/-- **Any single long-range piece covers at most `3` of the `9` squares of a
king's neighbourhood.**  A line hits each of the three rows (or, if horizontal,
each of the three columns) at most once. -/
theorem Line.block_card_le_three (L : Line) (p : Square) :
    (L.blockCovered p).card ≤ 3 := by
  have hsub : ∀ d ∈ L.blockCovered p, d ∈ blockOffsets := fun d hd =>
    Finset.mem_of_mem_filter _ hd
  rcases L.nondeg with ha | hb
  · have h : (L.blockCovered p).card ≤ (({-1, 0, 1} : Finset ℤ)).card := by
      apply Finset.card_le_card_of_injOn (fun d => d.2)
      · intro d hd
        have hmem := hsub d hd
        simp only [blockOffsets, Finset.mem_product] at hmem
        exact hmem.2
      · exact L.covered_snd_injOn p ha
    simpa using h
  · have h : (L.blockCovered p).card ≤ (({-1, 0, 1} : Finset ℤ)).card := by
      apply Finset.card_le_card_of_injOn (fun d => d.1)
      · intro d hd
        have hmem := hsub d hd
        simp only [blockOffsets, Finset.mem_product] at hmem
        exact hmem.1
      · exact L.covered_fst_injOn p hb
    simpa using h

/-! ## Step 3: `n` lines cover at most `3 * n` neighbourhood squares -/

theorem blockCovered_nil (p : Square) : blockCovered [] p = ∅ := by
  ext d; simp [blockCovered, attacked]

/-- Covering by a cons splits into the head line and the tail configuration. -/
theorem blockCovered_cons (L : Line) (S : List Line) (p : Square) :
    blockCovered (L :: S) p ⊆ L.blockCovered p ∪ blockCovered S p := by
  intro d hd
  simp only [blockCovered, Line.blockCovered, Finset.mem_filter, attacked,
    List.mem_cons] at hd ⊢
  obtain ⟨hmem, M, hM, hcov⟩ := hd
  rcases hM with rfl | hM
  · exact Finset.mem_union_left _ (by simp [Finset.mem_filter, hmem, hcov])
  · exact Finset.mem_union_right _
      (by simp only [Finset.mem_filter]; exact ⟨hmem, M, hM, hcov⟩)

/-- A configuration of `n` long-range pieces covers at most `3 * n` of the nine
neighbourhood squares. -/
theorem blockCovered_card_le (S : List Line) (p : Square) :
    (blockCovered S p).card ≤ 3 * S.length := by
  induction S with
  | nil => simp [blockCovered_nil]
  | cons L S ih =>
    calc (blockCovered (L :: S) p).card
        ≤ (L.blockCovered p ∪ blockCovered S p).card :=
          Finset.card_le_card (blockCovered_cons L S p)
      _ ≤ (L.blockCovered p).card + (blockCovered S p).card := Finset.card_union_le _ _
      _ ≤ 3 + 3 * S.length := Nat.add_le_add (Line.block_card_le_three L p) ih
      _ = 3 * (L :: S).length := by simp only [List.length_cons]; ring

/-! ## Step 4: fewer than three pieces cannot checkmate -/

/-- The king at `p` is **checkmated** by `S`: it is in check, and every one of its
eight moves lands on an attacked square. -/
def Checkmated (S : List Line) (p : Square) : Prop :=
  attacked S p ∧ ∀ d ∈ kingMoves, attacked S (p.1 + d.1, p.2 + d.2)

/-- A checkmate covers the entire `3 × 3` neighbourhood: all nine offsets. -/
theorem Checkmated.blockCovered_eq {S : List Line} {p : Square}
    (h : Checkmated S p) : blockCovered S p = blockOffsets := by
  apply Finset.Subset.antisymm (Finset.filter_subset _ _)
  intro d hd
  simp only [Finset.mem_filter]
  refine ⟨hd, ?_⟩
  by_cases hd0 : d = (0, 0)
  · subst hd0; simpa using h.1
  · exact h.2 d (Finset.mem_erase.mpr ⟨hd0, hd⟩)

/-- **The sharp lower bound.**  A configuration of fewer than three long-range
pieces can never checkmate a king on the infinite board: some square of the
king's neighbourhood necessarily stays safe. -/
theorem no_mate_with_lt_three (S : List Line) (p : Square) (hlen : S.length < 3) :
    ¬ Checkmated S p := by
  intro h
  have hcard : (blockCovered S p).card = 9 := by
    rw [h.blockCovered_eq, blockOffsets_card]
  have hle := blockCovered_card_le S p
  rw [hcard] at hle
  omega

/-! ## Step 5: three pieces suffice — the threshold is sharp -/

/-- The horizontal line (rook) occupying the entire row `y = r`. -/
def rookRow (r : ℤ) : Line := ⟨0, 1, r, Or.inr one_ne_zero⟩

theorem rookRow_covers (r : ℤ) (q : Square) : (rookRow r).covers q ↔ q.2 = r := by
  simp [rookRow, Line.covers]

/-- **Three pieces suffice.**  Three parallel rooks on the rows `y = p.2 - 1`,
`y = p.2`, `y = p.2 + 1` checkmate a king at `p`, so the bound `3` in
`no_mate_with_lt_three` is sharp. -/
theorem mate_exists (p : Square) :
    ∃ S : List Line, S.length = 3 ∧ Checkmated S p := by
  refine ⟨[rookRow (p.2 - 1), rookRow p.2, rookRow (p.2 + 1)], rfl, ?_⟩
  constructor
  · exact ⟨rookRow p.2, by simp, by rw [rookRow_covers]⟩
  · intro d hd
    have hmem : d ∈ blockOffsets := Finset.mem_of_mem_erase hd
    simp only [blockOffsets, Finset.mem_product] at hmem
    have hd2 : d.2 = -1 ∨ d.2 = 0 ∨ d.2 = 1 := by
      have := hmem.2; simpa using this
    rcases hd2 with h | h | h
    · exact ⟨rookRow (p.2 - 1), by simp, by rw [rookRow_covers]; omega⟩
    · exact ⟨rookRow p.2, by simp, by rw [rookRow_covers]; omega⟩
    · exact ⟨rookRow (p.2 + 1), by simp, by rw [rookRow_covers]; omega⟩

/-! ## Step 6: global escape — the board is never fully covered -/

/-- A non-horizontal line meets a fixed row `y = k` in at most one square, so the
set of `x` with `(x, k)` on the line is finite. -/
theorem covers_row_finite (L : Line) (k : ℤ) (hL : L.a ≠ 0) :
    {x : ℤ | L.covers (x, k)}.Finite := by
  apply Set.Subsingleton.finite
  intro x hx x' hx'
  simp only [Set.mem_setOf_eq, Line.covers] at hx hx'
  have : L.a * x = L.a * x' := by linear_combination hx - hx'
  exact mul_left_cancel₀ hL this

/-- Given a row `y = k` avoided by every horizontal piece, only finitely many
squares of that row are attacked. -/
theorem attacked_row_finite (S : List Line) (k : ℤ)
    (hk : ∀ L ∈ S, L.a = 0 → ¬ L.covers (0, k)) :
    {x : ℤ | attacked S (x, k)}.Finite := by
  induction S with
  | nil => simp [attacked]
  | cons L S ih =>
    have hset : {x : ℤ | attacked (L :: S) (x, k)}
        = {x : ℤ | L.covers (x, k)} ∪ {x : ℤ | attacked S (x, k)} := by
      ext x; simp only [attacked, List.mem_cons, Set.mem_setOf_eq, Set.mem_union]
      constructor
      · rintro ⟨M, rfl | hM, hcov⟩
        · exact Or.inl hcov
        · exact Or.inr ⟨M, hM, hcov⟩
      · rintro (h | ⟨M, hM, hcov⟩)
        · exact ⟨L, Or.inl rfl, h⟩
        · exact ⟨M, Or.inr hM, hcov⟩
    rw [hset]
    apply Set.Finite.union
    · by_cases hLa : L.a = 0
      · have hempty : {x : ℤ | L.covers (x, k)} = ∅ := by
          ext x
          simp only [Set.mem_setOf_eq, Set.mem_empty_iff_false, iff_false, Line.covers, hLa]
          have hL0 := hk L (List.mem_cons_self ..) hLa
          simp only [Line.covers, hLa] at hL0
          intro h; apply hL0; linarith
        rw [hempty]; exact Set.finite_empty
      · exact covers_row_finite L k hLa
    · exact ih (fun M hM => hk M (List.mem_cons_of_mem _ hM))

/-- There is a row `y = k` on which no horizontal (`a = 0`) piece of `S` lies. -/
theorem exists_safe_row (S : List Line) :
    ∃ k : ℤ, ∀ L ∈ S, L.a = 0 → ¬ L.covers (0, k) := by
  have hBfin : {k : ℤ | ∃ L ∈ S, L.a = 0 ∧ L.covers (0, k)}.Finite := by
    induction S with
    | nil => simp
    | cons L S ih =>
      have hset : {k : ℤ | ∃ M ∈ (L :: S), M.a = 0 ∧ M.covers (0, k)}
          ⊆ {k : ℤ | L.a = 0 ∧ L.covers (0, k)}
            ∪ {k : ℤ | ∃ M ∈ S, M.a = 0 ∧ M.covers (0, k)} := by
        rintro k ⟨M, hM, hMa, hcov⟩
        rcases List.mem_cons.mp hM with rfl | hM
        · exact Or.inl ⟨hMa, hcov⟩
        · exact Or.inr ⟨M, hM, hMa, hcov⟩
      apply Set.Finite.subset _ hset
      apply Set.Finite.union _ ih
      apply Set.Subsingleton.finite
      intro k hk k' hk'
      simp only [Set.mem_setOf_eq, Line.covers] at hk hk'
      have hb : L.b ≠ 0 := by rcases L.nondeg with h | h; exact absurd hk.1 h; exact h
      have hbb : L.b * k = L.b * k' := by linear_combination hk.2 - hk'.2
      exact mul_left_cancel₀ hb hbb
  obtain ⟨k, hk⟩ := (hBfin.infinite_compl).nonempty
  refine ⟨k, ?_⟩
  intro L hL hLa hcov
  exact hk ⟨L, hL, hLa, hcov⟩

/-- **Global escape.**  Any finite configuration of long-range pieces leaves
infinitely many safe squares: finitely many lines cannot cover the plane, so a
lone king is never trapped everywhere at once. -/
theorem escape_infinite (S : List Line) : {q : Square | safe S q}.Infinite := by
  obtain ⟨k, hk⟩ := exists_safe_row S
  have hinf : {x : ℤ | attacked S (x, k)}ᶜ.Infinite :=
    (attacked_row_finite S k hk).infinite_compl
  have hinj : Set.InjOn (fun x : ℤ => (x, k)) {x : ℤ | attacked S (x, k)}ᶜ := by
    intro x _ y _ h; simpa using h
  have himg : ((fun x : ℤ => (x, k)) '' {x : ℤ | attacked S (x, k)}ᶜ).Infinite :=
    hinf.image hinj
  have hsub : (fun x : ℤ => (x, k)) '' {x : ℤ | attacked S (x, k)}ᶜ ⊆ {q | safe S q} := by
    rintro q ⟨x, hx, rfl⟩; exact hx
  exact Set.Infinite.mono hsub himg

/-- The king can flee arbitrarily far: for every bound `N` there is a safe square
beyond it.  This is the "value `ω`" of the escape — the safe region is unbounded,
never confined to any finite region of the board. -/
theorem escape_unbounded (S : List Line) (N : ℤ) :
    ∃ q : Square, safe S q ∧ N < q.1 := by
  obtain ⟨k, hk⟩ := exists_safe_row S
  have hfin := attacked_row_finite S k hk
  by_contra hcon
  push_neg at hcon
  have hsub : (Set.Ioi N) ⊆ {x : ℤ | attacked S (x, k)} := by
    intro x hx
    by_contra hna
    have hxle := hcon (x, k) hna
    simp only [Set.mem_Ioi] at hx
    omega
  exact (Set.Ioi_infinite N) (hfin.subset hsub)

end HilbertChess