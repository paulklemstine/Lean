import Mathlib

/-!
# Turn counts of row sequences and minimality of the comb

A path in a product `G □ H` determines a *row sequence* `row : ℕ → α`
(its first coordinate).  The *turn count* of the path on `[0, L]` is the number of
steps `s < L` at which the row changes.  We prove:

* `TurnMinimal.card_rows_le_turnCount_succ`: a path visiting `r` distinct rows makes at
  least `r - 1` turns;
* `TurnMinimal.IsComb.turnCount_succ_eq`: the comb (each row visited in one contiguous
  block) attains this minimum exactly;
* `TurnMinimal.isComb_iff_turnCount_succ_eq`: conversely the comb is the *only* minimiser.
-/

namespace TurnMinimal

variable {α : Type*} [DecidableEq α]

/-- Number of steps `s < L` at which the row sequence changes. -/
def turnCount (row : ℕ → α) (L : ℕ) : ℕ :=
  ((Finset.range L).filter (fun s => row s ≠ row (s + 1))).card

/-- Set of rows visited on `[0, L]`. -/
def rowSet (row : ℕ → α) (L : ℕ) : Finset α :=
  (Finset.range (L + 1)).image row

/-- Comb property: every row is visited in a single contiguous block of times. -/
def IsComb (row : ℕ → α) (L : ℕ) : Prop :=
  ∀ i j k, i ≤ j → j ≤ k → k ≤ L → row i = row k → row j = row i

lemma turnCount_zero (row : ℕ → α) : turnCount row 0 = 0 := by
  simp [turnCount]

lemma turnCount_succ (row : ℕ → α) (L : ℕ) :
    turnCount row (L + 1) = turnCount row L + if row L ≠ row (L + 1) then 1 else 0 := by
  unfold turnCount
  rw [Finset.range_add_one, Finset.filter_insert]
  split_ifs with h
  · rw [Finset.card_insert_of_notMem (by simp)]
  · rfl

lemma rowSet_succ (row : ℕ → α) (L : ℕ) :
    rowSet row (L + 1) = insert (row (L + 1)) (rowSet row L) := by
  unfold rowSet
  rw [Finset.range_add_one (n := L + 1), Finset.image_insert]

lemma mem_rowSet {row : ℕ → α} {L : ℕ} {a : α} :
    a ∈ rowSet row L ↔ ∃ i ≤ L, row i = a := by
  simp [rowSet]

lemma turnCount_le (row : ℕ → α) (L : ℕ) : turnCount row L ≤ L := by
  unfold turnCount
  exact (Finset.card_filter_le _ _).trans (by simp)

/-- **Turn lower bound.** A path visiting `r` rows turns at least `r - 1` times. -/
theorem card_rows_le_turnCount_succ (row : ℕ → α) (L : ℕ) :
    (rowSet row L).card ≤ turnCount row L + 1 := by
  induction L with
  | zero => simp [rowSet, turnCount_zero]
  | succ L ih =>
    rw [rowSet_succ, turnCount_succ]
    by_cases h : row L = row (L + 1)
    · have : row (L + 1) ∈ rowSet row L := mem_rowSet.2 ⟨L, le_rfl, h⟩
      rw [Finset.insert_eq_of_mem this]
      simp [h, ih]
    · have := Finset.card_insert_le (row (L + 1)) (rowSet row L)
      simp only [ne_eq, h, not_false_eq_true, if_true]
      omega

omit [DecidableEq α] in
lemma IsComb.mono {row : ℕ → α} {L M : ℕ} (h : IsComb row L) (hM : M ≤ L) :
    IsComb row M := fun i j k hij hjk hk hik => h i j k hij hjk (hk.trans hM) hik

/-- **The comb attains the minimum.** -/
theorem IsComb.turnCount_succ_eq {row : ℕ → α} {L : ℕ} (h : IsComb row L) :
    turnCount row L + 1 = (rowSet row L).card := by
  induction L with
  | zero => simp [rowSet, turnCount_zero]
  | succ L ih =>
    have ih := ih (h.mono (Nat.le_succ L))
    rw [rowSet_succ, turnCount_succ]
    by_cases hL : row L = row (L + 1)
    · have : row (L + 1) ∈ rowSet row L := mem_rowSet.2 ⟨L, le_rfl, hL⟩
      rw [Finset.insert_eq_of_mem this]
      simp [hL, ih]
    · have hnot : row (L + 1) ∉ rowSet row L := by
        intro hm
        obtain ⟨i, hi, hri⟩ := mem_rowSet.1 hm
        exact hL ((h i L (L + 1) hi (Nat.le_succ L) le_rfl hri).trans hri)
      rw [Finset.card_insert_of_notMem hnot]
      simp only [ne_eq, hL, not_false_eq_true, if_true]
      omega

/-- **Uniqueness of the minimiser.** A row sequence attains the turn lower bound
`turnCount = #rows - 1` if and only if it is a comb. -/
theorem isComb_iff_turnCount_succ_eq (row : ℕ → α) (L : ℕ) :
    IsComb row L ↔ turnCount row L + 1 = (rowSet row L).card := by
  refine ⟨IsComb.turnCount_succ_eq, fun heq => ?_⟩
  induction L with
  | zero =>
    intro i j k hij hjk hk _
    have : i = 0 := by omega
    have : j = 0 := by omega
    subst_vars; rfl
  | succ L ih =>
    have hle := card_rows_le_turnCount_succ row L
    rw [rowSet_succ, turnCount_succ] at heq
    have hins := Finset.card_insert_le (row (L + 1)) (rowSet row L)
    -- equality propagates to the prefix, and a turn at `L` must open a new row
    have key : turnCount row L + 1 = (rowSet row L).card ∧
        (row L ≠ row (L + 1) → row (L + 1) ∉ rowSet row L) := by
      by_cases hL : row L = row (L + 1)
      · have : row (L + 1) ∈ rowSet row L := mem_rowSet.2 ⟨L, le_rfl, hL⟩
        rw [Finset.insert_eq_of_mem this] at heq
        simp only [hL, ne_eq, not_true_eq_false, if_false] at heq
        exact ⟨by omega, fun h => absurd hL h⟩
      · simp only [ne_eq, hL, not_false_eq_true, if_true] at heq
        refine ⟨by omega, fun _ hm => ?_⟩
        rw [Finset.insert_eq_of_mem hm] at heq
        omega
    have ihc := ih key.1
    intro i j k hij hjk hk hik
    rcases Nat.lt_or_ge k (L + 1) with hkL | hkL
    · exact ihc i j k hij hjk (by omega) hik
    · have hk' : k = L + 1 := by omega
      subst hk'
      rcases Nat.lt_or_ge i (L + 1) with hiL | hiL
      · -- row (L+1) is an old row, so no turn at L
        have hold : row (L + 1) ∈ rowSet row L := mem_rowSet.2 ⟨i, by omega, hik⟩
        have hnt : row L = row (L + 1) := by
          by_contra hc; exact key.2 hc hold
        rcases Nat.lt_or_ge j (L + 1) with hjL | hjL
        · exact ihc i j L hij (by omega) le_rfl (hik.trans hnt.symm)
        · have : j = L + 1 := by omega
          subst this; exact hik.symm
      · have : i = L + 1 := by omega
        have : j = L + 1 := by omega
        subst_vars; rfl

/-- The comb is turn-minimal among all row sequences visiting the same set of rows. -/
theorem IsComb.turnCount_le_of_rowSet_eq {row row' : ℕ → α} {L L' : ℕ}
    (h : IsComb row L) (hrows : rowSet row L = rowSet row' L') :
    turnCount row L ≤ turnCount row' L' := by
  have h1 := h.turnCount_succ_eq
  have h2 := card_rows_le_turnCount_succ row' L'
  rw [hrows] at h1
  omega

end TurnMinimal