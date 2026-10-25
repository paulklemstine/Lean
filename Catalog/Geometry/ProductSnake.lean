import Catalog.Geometry.TurnCount

/-!
# Snakes in product graphs and the turn lower bound

A *snake* (induced path) in a graph `G` on the index window `[a, b]` is a map
`p : ℕ → V` that is injective on `[a, b]` and such that `p i, p j` are adjacent
exactly when `|i - j| = 1`.  The hypercube splits as a box product
`Q_{m+k} ≅ Q_m □ Q_k`, so a snake in `Q_n` is a snake in a product `G □ H`; its
*row sequence* is the `G`-coordinate.

Main results:

* `TurnMinimal.turnCount_row_add_turnCount_col`: for any walk in `G □ H`,
  `#row changes + #column changes = length` (every step moves in exactly one factor);
* `TurnMinimal.IsSnakeOn.column_of_row_const`: a row block of a product snake is a snake
  in the column factor `H`;
* `TurnMinimal.succ_le_turnCount_succ_mul`: **direction changes are essential** —
  if every snake in `H` has length at most `S`, a snake of length `L` in `G □ H` satisfies
  `L + 1 ≤ (turnCount + 1) * (S + 1)`.
-/

namespace TurnMinimal

variable {V W : Type*}

/-- `p` is a snake (induced path) in `G` on the index window `[a, b]`. -/
def IsSnakeOn (G : SimpleGraph V) (p : ℕ → V) (a b : ℕ) : Prop :=
  (∀ i j, a ≤ i → i ≤ b → a ≤ j → j ≤ b → p i = p j → i = j) ∧
  (∀ i j, a ≤ i → i ≤ b → a ≤ j → j ≤ b → (G.Adj (p i) (p j) ↔ (i + 1 = j ∨ j + 1 = i)))

/-- A snake of length `L` (starting at index `0`). -/
def IsSnake (G : SimpleGraph V) (p : ℕ → V) (L : ℕ) : Prop := IsSnakeOn G p 0 L

/-- Every snake in `G` has length (number of edges) at most `S`. -/
def SnakeBound (G : SimpleGraph V) (S : ℕ) : Prop :=
  ∀ (p : ℕ → V) (a b : ℕ), a ≤ b → IsSnakeOn G p a b → b - a ≤ S

/-- `p` is a walk of length `L`: consecutive vertices are adjacent. -/
def IsWalk (G : SimpleGraph V) (p : ℕ → V) (L : ℕ) : Prop :=
  ∀ s, s < L → G.Adj (p s) (p (s + 1))

lemma IsSnake.isWalk {G : SimpleGraph V} {p : ℕ → V} {L : ℕ} (h : IsSnake G p L) :
    IsWalk G p L := fun s hs =>
  (h.2 s (s + 1) (Nat.zero_le _) hs.le (Nat.zero_le _) hs).2 (Or.inl rfl)

/-- **Step accounting.** Every step of a walk in `G □ H` changes exactly one coordinate,
so the row changes and the column changes add up to the length. -/
theorem turnCount_row_add_turnCount_col [DecidableEq V] [DecidableEq W]
    {G : SimpleGraph V} {H : SimpleGraph W} {p : ℕ → V × W} {L : ℕ}
    (hw : IsWalk (G □ H) p L) :
    turnCount (fun s => (p s).1) L + turnCount (fun s => (p s).2) L = L := by
  induction L with
  | zero => simp [turnCount_zero]
  | succ L ih =>
    have ih := ih (fun s hs => hw s (by omega))
    rw [turnCount_succ, turnCount_succ]
    have hadj := hw L (by omega)
    rw [SimpleGraph.boxProd_adj] at hadj
    rcases hadj with ⟨hG, hc⟩ | ⟨hH, hr⟩
    · have : (p L).1 ≠ (p (L + 1)).1 := hG.ne
      simp only [ne_eq, this, not_false_eq_true, if_true, hc, not_true_eq_false, if_false]
      omega
    · have : (p L).2 ≠ (p (L + 1)).2 := hH.ne
      simp only [ne_eq, this, not_false_eq_true, if_true, hr, not_true_eq_false, if_false]
      omega

/-- A row block of a product snake is a snake in the column factor. -/
theorem IsSnakeOn.column_of_row_const {G : SimpleGraph V} {H : SimpleGraph W}
    {p : ℕ → V × W} {a b : ℕ} (h : IsSnakeOn (G □ H) p a b)
    (hrow : ∀ i, a ≤ i → i ≤ b → (p i).1 = (p a).1) :
    IsSnakeOn H (fun i => (p i).2) a b := by
  refine ⟨fun i j hai hib haj hjb hij => ?_, fun i j hai hib haj hjb => ?_⟩
  · refine h.1 i j hai hib haj hjb (Prod.ext ?_ hij)
    rw [hrow i hai hib, hrow j haj hjb]
  · have hr : (p i).1 = (p j).1 := by rw [hrow i hai hib, hrow j haj hjb]
    rw [← h.2 i j hai hib haj hjb, SimpleGraph.boxProd_adj]
    constructor
    · intro hH; exact Or.inr ⟨hH, hr⟩
    · rintro (⟨hG, _⟩ | ⟨hH, _⟩)
      · exact absurd hr hG.ne
      · exact hH

lemma turnCount_mono {α : Type*} [DecidableEq α] (row : ℕ → α) {s t : ℕ} (hst : s ≤ t) :
    turnCount row s ≤ turnCount row t := by
  unfold turnCount
  exact Finset.card_le_card (Finset.filter_subset_filter _ (Finset.range_subset_range.2 hst))

/-- If the turn counter does not increase between `a` and `b`, the row is constant
on `[a, b]`. -/
lemma row_const_of_turnCount_eq {α : Type*} [DecidableEq α] (row : ℕ → α) {a b : ℕ}
    (heq : turnCount row a = turnCount row b) :
    ∀ i, a ≤ i → i ≤ b → row i = row a := by
  intro i hai hib
  induction i, hai using Nat.le_induction with
  | base => rfl
  | succ i hai ih =>
    have h1 := turnCount_mono row hai
    have h2 := turnCount_mono row (show i + 1 ≤ b from hib)
    have hs := turnCount_succ row i
    have hno : ¬ row i ≠ row (i + 1) := by
      intro hne
      simp only [ne_eq, hne, not_false_eq_true, if_true] at hs
      omega
    rw [← ih (by omega)]
    exact (not_not.1 hno).symm

/-- **Direction changes are essential.** If every snake in the column factor `H` has length
at most `S`, then a snake of length `L` in `G □ H` changes rows at least
`(L + 1) / (S + 1) - 1` times: `L + 1 ≤ (turnCount + 1) * (S + 1)`. -/
theorem succ_le_turnCount_succ_mul [DecidableEq V]
    {G : SimpleGraph V} {H : SimpleGraph W} {p : ℕ → V × W} {L S : ℕ}
    (hp : IsSnake (G □ H) p L) (hH : SnakeBound H S) :
    L + 1 ≤ (turnCount (fun s => (p s).1) L + 1) * (S + 1) := by
  set row : ℕ → V := fun s => (p s).1 with hrowdef
  set f : ℕ → ℕ := fun s => turnCount row s with hf
  have hcard := Finset.card_le_mul_card_image (f := f) (Finset.range (L + 1)) (S + 1) ?_
  · have himg : (Finset.range (L + 1)).image f ⊆ Finset.range (turnCount row L + 1) := by
      intro m hm
      obtain ⟨s, hs, rfl⟩ := Finset.mem_image.1 hm
      simp only [Finset.mem_range] at hs ⊢
      have : f s ≤ f L := turnCount_mono row (show s ≤ L by omega)
      have hfL : f L = turnCount row L := rfl
      omega
    have := Finset.card_le_card himg
    simp only [Finset.card_range] at hcard this
    calc L + 1 ≤ (S + 1) * ((Finset.range (L + 1)).image f).card := hcard
      _ ≤ (S + 1) * (turnCount row L + 1) := Nat.mul_le_mul_left _ this
      _ = _ := Nat.mul_comm _ _
  · intro m hm
    set F := (Finset.range (L + 1)).filter (fun x => f x = m) with hF
    have hne : F.Nonempty := by
      obtain ⟨s, hs, hsm⟩ := Finset.mem_image.1 hm
      exact ⟨s, Finset.mem_filter.2 ⟨hs, hsm⟩⟩
    set a := F.min' hne
    set b := F.max' hne
    have haF : a ∈ F := F.min'_mem hne
    have hbF : b ∈ F := F.max'_mem hne
    simp only [hF, Finset.mem_filter, Finset.mem_range] at haF hbF
    have hab : a ≤ b := F.min'_le_max' hne
    have hsub : F ⊆ Finset.Icc a b := fun x hx =>
      Finset.mem_Icc.2 ⟨F.min'_le x hx, F.le_max' x hx⟩
    have hconst := row_const_of_turnCount_eq row (haF.2.trans hbF.2.symm)
    have hsnake : IsSnakeOn (G □ H) p a b :=
      ⟨fun i j _ hib _ hjb hij => hp.1 i j (Nat.zero_le _) (by omega) (Nat.zero_le _)
          (by omega) hij,
       fun i j _ hib _ hjb => hp.2 i j (Nat.zero_le _) (by omega) (Nat.zero_le _) (by omega)⟩
    have hcol := hsnake.column_of_row_const hconst
    have hlen := hH _ a b hab hcol
    calc F.card ≤ (Finset.Icc a b).card := Finset.card_le_card hsub
      _ = b + 1 - a := Nat.card_Icc a b
      _ ≤ S + 1 := by omega

end TurnMinimal