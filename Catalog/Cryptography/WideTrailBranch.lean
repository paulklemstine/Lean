/-
# Symmetric-Key Cryptanalysis II: The Wide-Trail Strategy — Branch Number & Two-Round Bound

This file formalizes the *column-weight* machinery behind the **wide-trail
strategy** of Daemen and Rijmen (the AES design rationale). A cipher state is an
`R × C` grid of bytes (`Fin R → Fin C → α`); in differential cryptanalysis a
byte is **active** when its difference is nonzero.

The two pillars formalized here are:

* `two_round` — the **two-round propagation theorem**: if every active column of
  a MixColumns step obeys the branch-number bound `B ≤ (input col weight) +
  (output col weight)`, then the total active bytes over the step is at least
  `B · (number of active columns)`. This is the engine that turns the *branch
  number of MixColumns* into a guaranteed count of active S-boxes.
* `colActive_shiftRows_ge_colWeight` — the **diffusion-optimality of ShiftRows**:
  the bytes of one column are spread by ShiftRows into pairwise-distinct columns,
  so `colActive (ShiftRows s) ≥ colWeight s j` for every column `j`. This is the
  structural reason a heavy column forces many active columns one round later.

`round_bound` packages these into the per-round inequality used by the
four-round 25-active-S-box theorem (file `AESFourRound.lean`). The concrete AES
ShiftRows (`aesShiftRows i = +i`) is proved diffusion-optimal in
`aesShiftRows_diffusionOptimal`.

## Application Keywords

wide-trail strategy, AES, branch number, MixColumns, MDS code, ShiftRows,
diffusion, active S-boxes, differential cryptanalysis, linear cryptanalysis,
two-round propagation theorem, Daemen-Rijmen
-/

import Mathlib

open Finset

namespace WideTrail

/-- A cipher state: an `R × C` grid of "bytes" in `α`. A byte is *active* when it
is nonzero (we track only the activity pattern of a differential trail). -/
abbrev St (α : Type*) (R C : ℕ) := Fin R → Fin C → α

variable {α : Type*} [DecidableEq α] [Zero α] {R C : ℕ}

/-- The weight of column `j`: number of active bytes in that column. -/
def colWeight (s : St α R C) (j : Fin C) : ℕ :=
  (Finset.univ.filter (fun i : Fin R => s i j ≠ 0)).card

/-- The total weight of a state: number of active bytes (active S-boxes). -/
def wt (s : St α R C) : ℕ := ∑ j : Fin C, colWeight s j

/-- The weight of row `i`: number of active bytes in that row. -/
def rowCount (s : St α R C) (i : Fin R) : ℕ :=
  (Finset.univ.filter (fun j : Fin C => s i j ≠ 0)).card

/-- The set of active columns (columns containing at least one active byte). -/
def colActiveSet (s : St α R C) : Finset (Fin C) :=
  Finset.univ.filter (fun j => ∃ i, s i j ≠ 0)

/-- The number of active columns (the *bundle weight* in wide-trail terminology). -/
def colActive (s : St α R C) : ℕ := (colActiveSet s).card

/-- ShiftRows applies a column permutation `ρ i` to each row `i`. -/
def shiftRows (ρ : Fin R → Equiv.Perm (Fin C)) (s : St α R C) : St α R C :=
  fun i j => s i (ρ i j)

/-- A column has weight zero iff it has no active byte. -/
theorem colWeight_eq_zero_iff (s : St α R C) (j : Fin C) :
    colWeight s j = 0 ↔ ∀ i, s i j = 0 := by
  unfold colWeight
  rw [Finset.card_eq_zero, Finset.filter_eq_empty_iff]
  simp

@[simp] theorem mem_colActiveSet {s : St α R C} {j : Fin C} :
    j ∈ colActiveSet s ↔ ∃ i, s i j ≠ 0 := by simp [colActiveSet]

/-- **Two-round propagation theorem.** Given a MixColumns-style step from `p`
(the post-ShiftRows state) to `y`, where every active column obeys the branch
number bound, the total active bytes is at least `B` times the number of active
output columns. This converts the branch number of MixColumns into a guaranteed
active-byte count. -/
theorem two_round (p y : St α R C) (B : ℕ)
    (hactive : ∀ j, (∃ i, p i j ≠ 0) ↔ (∃ i, y i j ≠ 0))
    (hbranch : ∀ j, (∃ i, p i j ≠ 0) → B ≤ colWeight p j + colWeight y j) :
    B * colActive y ≤ wt p + wt y := by
  have hsum_y : ∑ j ∈ colActiveSet y, colWeight y j = wt y := by
    unfold wt
    apply Finset.sum_subset (Finset.subset_univ _)
    intro j _ hj
    rw [colWeight_eq_zero_iff]; intro i; by_contra hc
    exact hj (mem_colActiveSet.mpr ⟨i, hc⟩)
  have hsum_p : ∑ j ∈ colActiveSet y, colWeight p j = wt p := by
    unfold wt
    apply Finset.sum_subset (Finset.subset_univ _)
    intro j _ hj
    rw [colWeight_eq_zero_iff]; intro i; by_contra hc
    exact hj (mem_colActiveSet.mpr ((hactive j).mp ⟨i, hc⟩))
  have hb : B * colActive y = ∑ _j ∈ colActiveSet y, B := by
    rw [Finset.sum_const, smul_eq_mul, mul_comm]; rfl
  rw [hb, ← hsum_p, ← hsum_y, ← Finset.sum_add_distrib]
  apply Finset.sum_le_sum
  intro j hj
  exact hbranch j ((hactive j).mpr (mem_colActiveSet.mp hj))

/-- Total weight as the sum of row weights (used to show ShiftRows preserves weight). -/
theorem wt_eq_sum_rowCount (s : St α R C) : wt s = ∑ i : Fin R, rowCount s i := by
  unfold wt colWeight rowCount
  simp only [Finset.card_filter]
  rw [Finset.sum_comm]

/-- ShiftRows preserves each row's weight (it permutes within the row). -/
theorem rowCount_shiftRows (ρ : Fin R → Equiv.Perm (Fin C)) (s : St α R C) (i : Fin R) :
    rowCount (shiftRows ρ s) i = rowCount s i := by
  unfold rowCount shiftRows
  apply Finset.card_bij (fun j _ => ρ i j)
  · intro j hj; simpa using hj
  · intro j1 _ j2 _ h; exact (ρ i).injective h
  · intro j hj
    exact ⟨(ρ i).symm j, by simpa using hj, by simp⟩

/-- **ShiftRows preserves total weight**: the number of active S-boxes is unchanged
by ShiftRows (it is a positional permutation). -/
theorem wt_shiftRows (ρ : Fin R → Equiv.Perm (Fin C)) (s : St α R C) :
    wt (shiftRows ρ s) = wt s := by
  rw [wt_eq_sum_rowCount, wt_eq_sum_rowCount]
  exact Finset.sum_congr rfl (fun i _ => rowCount_shiftRows ρ s i)

/-- ShiftRows is *diffusion-optimal* when bytes coming from a single column are
mapped into pairwise distinct columns. -/
def DiffusionOptimal (ρ : Fin R → Equiv.Perm (Fin C)) : Prop :=
  ∀ j0 : Fin C, Function.Injective (fun i : Fin R => (ρ i).symm j0)

/-- **Diffusion of ShiftRows.** With diffusion-optimal ShiftRows, a column of
weight `m` spreads to `m` distinct active columns: `colActive (ShiftRows s) ≥
colWeight s j0`. This is why a single heavy column guarantees many active columns
in the next round — the combinatorial core of the wide-trail strategy. -/
theorem colActive_shiftRows_ge_colWeight (ρ : Fin R → Equiv.Perm (Fin C))
    (hρ : DiffusionOptimal ρ) (s : St α R C) (j0 : Fin C) :
    colWeight s j0 ≤ colActive (shiftRows ρ s) := by
  show colWeight s j0 ≤ (colActiveSet (shiftRows ρ s)).card
  unfold colWeight
  apply Finset.card_le_card_of_injOn (fun i => (ρ i).symm j0)
  · intro i hi
    simp only [Finset.coe_filter, Finset.mem_univ, true_and, Set.mem_setOf_eq] at hi
    rw [Finset.mem_coe, mem_colActiveSet]
    exact ⟨i, by simp only [shiftRows, Equiv.apply_symm_apply]; exact hi⟩
  · intro i1 _ i2 _ h; exact hρ j0 h

/-- **Per-round active-byte bound.** A single AES round = ShiftRows followed by a
branch-`B` MixColumns. Combining `two_round` with weight-invariance of ShiftRows:
the active bytes in the round's input and output total at least `B · colActive`
of the output. -/
theorem round_bound (ρ : Fin R → Equiv.Perm (Fin C)) (x y : St α R C) (B : ℕ)
    (hactive : ∀ j, (∃ i, shiftRows ρ x i j ≠ 0) ↔ (∃ i, y i j ≠ 0))
    (hbranch : ∀ j, (∃ i, shiftRows ρ x i j ≠ 0) →
      B ≤ colWeight (shiftRows ρ x) j + colWeight y j) :
    B * colActive y ≤ wt x + wt y := by
  have h := two_round (shiftRows ρ x) y B hactive hbranch
  rwa [wt_shiftRows] at h

/-- The concrete AES ShiftRows on a `4 × 4` state: row `i` is rotated by `i`. -/
def aesShiftRows : Fin 4 → Equiv.Perm (Fin 4) := fun i => Equiv.addLeft i

/-- **AES ShiftRows is diffusion-optimal.** Within a fixed column, the four rows
are sent to four distinct columns (the shifts `0,1,2,3` are pairwise distinct). -/
theorem aesShiftRows_diffusionOptimal : DiffusionOptimal aesShiftRows := by
  intro j0 i1 i2 h
  simp only [aesShiftRows, Equiv.addLeft_symm, Equiv.coe_addLeft] at h
  have : -i1 = -i2 := add_right_cancel h
  simpa using this

/-
-- !-- Lab Notes -- !--

HYPOTHESIS (Hypothesizer):
  H1 (bold): The branch number `B` of MixColumns linearly converts active columns
     into active S-boxes: any MixColumns step has `#active S-boxes ≥ B·#active cols`.
  H2 (bold): ShiftRows is *diffusion optimal*: a single active column of weight m
     becomes m active columns. Conjecture this is exactly the property that makes
     the super-box MDS.
  H3: ShiftRows never changes the active-S-box count (it only moves bytes).

EXPERIMENT (Experimenter):
  - `two_round` (H1): summed the per-column branch inequality over active columns;
    the subtle step is that column weights of inactive columns vanish, so the
    partial sums over `colActiveSet` equal the full weights `wt`.
  - `colActive_shiftRows_ge_colWeight` (H2): exhibited an INJECTION from the active
    rows of a column into the active columns of the shifted state, via
    `i ↦ (ρ i).symm j0`; injectivity is precisely DiffusionOptimal.
  - `wt_shiftRows` (H3): row-wise re-summation + a `Finset.card_bij` permutation.
  - Verified the concrete AES ShiftRows (`+i` per row) is diffusion optimal.

ANALYSIS (Analyst):
  - ALL hypotheses SURVIVED with 0 sorries.
  - Structural pattern: every wide-trail fact is a statement about WHERE the
    weight lives (columns vs rows), provable by a bijection or a column-partition
    of the total weight. No field arithmetic of GF(2^8) is needed at this level —
    only the *branch number* abstraction and the *permutation* structure.
  - "needs a different definition": defining `wt` as `∑ colWeight` (rather than a
    raw `card` of active positions) was the key choice making `two_round` clean.

CRITIQUE (Critic):
  - `two_round` and the diffusion lemma use genuine combinatorics (partition,
    injection), not `decide`. The branch number `B` is kept as a hypothesis: this
    is faithful, since "MixColumns is MDS with branch 5" is the standard cited AES
    fact; we expose it as the hypothesis `hbranch` rather than hiding it.
  - Corner case checked: inactive columns contribute 0 (via `colWeight_eq_zero_iff`),
    so the `two_round` sum manipulation is valid even when many columns are zero.

SYNTHESIS (PI):
  `round_bound` is the reusable per-round engine. Feeding it the branch number of
  MixColumns and chaining two rounds around a super-box yields the 25-active-S-box
  theorem (file `AESFourRound.lean`).
-/

end WideTrail