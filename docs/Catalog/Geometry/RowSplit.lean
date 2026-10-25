import Catalog.Geometry.TurnNormalForm

/-!
# Turn-minimal normal form for every row dimension

Let `ι` be a finite set of coordinates and `R ⊆ ι` a set of *row coordinates*.  The hypercube on
`ι` splits as `Q_R □ Q_{ι \ R}`; a snake in `Q_ι` becomes a product snake whose row sequence is
the restriction to `R`.  Its *turn count* `turnsIn R p L` is the number of steps flipping a
coordinate of `R`.

Main results:

* `TurnMinimal.turnsIn_eq_sum_flips`: `turnsIn R p L = ∑ i ∈ R, (flips of coordinate i)`;
* `TurnMinimal.succ_le_turnsIn_succ_mul_pow`: **lower bound** (direction changes are essential):
  `L + 1 ≤ (turnsIn R p L + 1) * 2 ^ (|ι| - |R|)`;
* `TurnMinimal.exists_turnsIn_le`: **normal form** — for every `a ≤ |ι|` there is a row set `R`
  with `|R| = a` and `|ι| * turnsIn R p L ≤ a * L`.

Thus every snake of length `L` in `Q_n` is, after relabelling coordinates (no loss of length),
a product snake in `Q_a □ Q_{n-a}` with at most `a L / n` direction changes, and no
decomposition has fewer than `(L + 1) / 2 ^ (n - a) - 1`.
-/

namespace TurnMinimal

variable {ι : Type*} [Fintype ι] [DecidableEq ι]

/-- The hypercube on an arbitrary finite coordinate type. -/
def HQ (ι : Type*) [Fintype ι] : SimpleGraph (ι → Bool) where
  Adj x y := hammingDist x y = 1
  symm x y h := by simpa [hammingDist_comm] using h
  loopless := ⟨fun x h => by simp at h⟩

lemma Q_eq_HQ (n : ℕ) : Q n = HQ (Fin n) := rfl

/-- Restriction to the row coordinates `R`. -/
def rowPart (R : Finset ι) (x : ι → Bool) : {i // i ∈ R} → Bool := fun i => x i

/-- Restriction to the column coordinates `ι \ R`. -/
def colPart (R : Finset ι) (x : ι → Bool) : {i // i ∉ R} → Bool := fun i => x i

/-- Split a vertex into row and column parts. -/
def splitR (R : Finset ι) (x : ι → Bool) : ({i // i ∈ R} → Bool) × ({i // i ∉ R} → Bool) :=
  (rowPart R x, colPart R x)

omit [Fintype ι] in
lemma splitR_injective (R : Finset ι) : Function.Injective (splitR R) := by
  intro x y h
  simp only [splitR, Prod.mk.injEq] at h
  funext k
  by_cases hk : k ∈ R
  · exact congrFun h.1 ⟨k, hk⟩
  · exact congrFun h.2 ⟨k, hk⟩

lemma hammingDist_splitR (R : Finset ι) (x y : ι → Bool) :
    hammingDist x y = hammingDist (rowPart R x) (rowPart R y) +
      hammingDist (colPart R x) (colPart R y) := by
  simp only [hammingDist, rowPart, colPart, Finset.card_filter]
  convert (Fintype.sum_subtype_add_sum_subtype (fun i => i ∈ R)
    (fun k => if x k ≠ y k then 1 else 0)).symm

/-- `Q_ι ≅ Q_R □ Q_{ι \ R}` on adjacency. -/
theorem HQ_adj_iff_splitR (R : Finset ι) (x y : ι → Bool) :
    (HQ ι).Adj x y ↔ (HQ {i // i ∈ R} □ HQ {i // i ∉ R}).Adj (splitR R x) (splitR R y) := by
  change hammingDist x y = 1 ↔ _
  rw [SimpleGraph.boxProd_adj, hammingDist_splitR R]
  change _ ↔ (hammingDist _ _ = 1 ∧ _) ∨ (hammingDist _ _ = 1 ∧ _)
  simp only [splitR]
  constructor
  · intro h
    rcases Nat.eq_zero_or_pos (hammingDist (rowPart R x) (rowPart R y)) with h0 | h0
    · exact Or.inr ⟨by omega, hammingDist_eq_zero.1 h0⟩
    · exact Or.inl ⟨by omega, hammingDist_eq_zero.1 (by omega)⟩
  · rintro (⟨h1, h2⟩ | ⟨h1, h2⟩)
    · rw [h1, h2, hammingDist_self]
    · rw [h1, h2, hammingDist_self]

/-- Number of direction changes of `p` in the product decomposition with row set `R`. -/
def turnsIn (R : Finset ι) (p : ℕ → ι → Bool) (L : ℕ) : ℕ :=
  turnCount (fun s => rowPart R (p s)) L

/-- **Direction changes are essential.** For any row set `R`, a snake of length `L` in `Q_ι`
satisfies `L + 1 ≤ (turnsIn R p L + 1) * 2 ^ (|ι| - |R|)`. -/
theorem succ_le_turnsIn_succ_mul_pow (R : Finset ι) {p : ℕ → ι → Bool} {L : ℕ}
    (hp : IsSnake (HQ ι) p L) :
    L + 1 ≤ (turnsIn R p L + 1) * 2 ^ (Fintype.card ι - R.card) := by
  have h' : IsSnake (HQ {i // i ∈ R} □ HQ {i // i ∉ R}) (fun s => splitR R (p s)) L :=
    IsSnakeOn.map (splitR_injective R) (HQ_adj_iff_splitR R) hp
  have h := succ_le_turnCount_succ_mul h' (snakeBound_card (HQ {i // i ∉ R}))
  have hc : Fintype.card ({i // i ∉ R} → Bool) = 2 ^ (Fintype.card ι - R.card) := by
    rw [Fintype.card_fun, Fintype.card_bool, Fintype.card_subtype_compl, Fintype.card_coe]
  rw [hc, Nat.sub_add_cancel Nat.one_le_two_pow] at h
  exact h

/-- In a hypercube walk, the row set `R` changes at a step iff the flipped coordinate
lies in `R`; hence `turnsIn R` is the sum of the flip counts of the coordinates of `R`. -/
theorem turnsIn_eq_sum_flips (R : Finset ι) {p : ℕ → ι → Bool} {L : ℕ}
    (hw : IsWalk (HQ ι) p L) :
    turnsIn R p L = ∑ i ∈ R, turnCount (fun s => p s i) L := by
  have hstep : ∀ s ∈ Finset.range L,
      (if rowPart R (p s) ≠ rowPart R (p (s + 1)) then 1 else 0) =
        ∑ i ∈ R, (if p s i ≠ p (s + 1) i then 1 else 0) := by
    intro s hs
    have h := hw s (Finset.mem_range.1 hs)
    change hammingDist (p s) (p (s + 1)) = 1 at h
    rw [hammingDist_splitR R] at h
    have hrow : hammingDist (rowPart R (p s)) (rowPart R (p (s + 1))) =
        ∑ i ∈ R, (if p s i ≠ p (s + 1) i then 1 else 0) := by
      simp only [hammingDist, rowPart, Finset.card_filter]
      exact Finset.sum_coe_sort R (fun k => if p s k ≠ p (s + 1) k then 1 else 0)
    rw [← hrow]
    by_cases he : rowPart R (p s) = rowPart R (p (s + 1))
    · simp [he]
    · have hpos : 0 < hammingDist (rowPart R (p s)) (rowPart R (p (s + 1))) :=
        hammingDist_pos.2 he
      simp only [ne_eq, he, not_false_eq_true, if_true]
      omega
  unfold turnsIn turnCount
  simp only [Finset.card_filter]
  rw [Finset.sum_congr rfl hstep, Finset.sum_comm]

/-- Averaging: for `a ≤ |s|` some `a`-subset `R ⊆ s` has `|s| * ∑_R f ≤ a * ∑_s f`. -/
theorem exists_subset_sum_le {α : Type*} [DecidableEq α] (f : α → ℕ) (s : Finset α) :
    ∀ a ≤ s.card, ∃ R ⊆ s, R.card = a ∧ s.card * ∑ i ∈ R, f i ≤ a * ∑ i ∈ s, f i := by
  intro a ha
  obtain ⟨k, rfl⟩ : ∃ k, a = s.card - k := ⟨s.card - a, by omega⟩
  induction k with
  | zero => exact ⟨s, subset_rfl, by simp, by simp⟩
  | succ k ih =>
    rcases Nat.lt_or_ge k s.card with hk | hk
    · have hcard : s.card - (k + 1) + 1 = s.card - k := by omega
      obtain ⟨R, hRs, hRc, hR⟩ := ih (by omega)
      have hne : R.Nonempty := by
        rw [← Finset.card_pos]; omega
      obtain ⟨m, hm, hmax⟩ := Finset.exists_max_image R f hne
      refine ⟨R.erase m, (Finset.erase_subset _ _).trans hRs, ?_, ?_⟩
      · rw [Finset.card_erase_of_mem hm, hRc]; omega
      · have hsum := Finset.sum_erase_add R f hm
        have hle : ∑ i ∈ R, f i ≤ R.card * f m := by
          have := Finset.sum_le_sum (fun i hi => hmax i hi)
          simpa using this
        rw [hRc] at hle
        set A := ∑ i ∈ R.erase m, f i
        set T := ∑ i ∈ s, f i
        have key : (s.card - k) * A ≤ (s.card - (k + 1)) * (A + f m) := by
          rw [← hcard] at hle ⊢
          nlinarith
        have h1 : (s.card - k) * (s.card * A) ≤ (s.card - k) * ((s.card - (k + 1)) * T) := by
          calc (s.card - k) * (s.card * A) = s.card * ((s.card - k) * A) := by ring
            _ ≤ s.card * ((s.card - (k + 1)) * (A + f m)) := Nat.mul_le_mul_left _ key
            _ = (s.card - (k + 1)) * (s.card * (A + f m)) := by ring
            _ ≤ (s.card - (k + 1)) * ((s.card - k) * T) := by
                rw [hsum]; exact Nat.mul_le_mul_left _ hR
            _ = (s.card - k) * ((s.card - (k + 1)) * T) := by ring
        exact Nat.le_of_mul_le_mul_left h1 (by omega)
    · have h0 : s.card - (k + 1) = 0 := by omega
      exact ⟨∅, Finset.empty_subset _, by simp [h0], by simp⟩

/-- **Turn-minimal normal form.** For every snake (indeed every walk) of length `L` in the
hypercube `Q_ι` and every row dimension `a ≤ |ι|`, there is a set `R` of `a` row coordinates
whose product decomposition `Q_R □ Q_{ι \ R}` has at most `a L / |ι|` direction changes. -/
theorem exists_turnsIn_le {p : ℕ → ι → Bool} {L : ℕ} (hw : IsWalk (HQ ι) p L)
    (a : ℕ) (ha : a ≤ Fintype.card ι) :
    ∃ R : Finset ι, R.card = a ∧ Fintype.card ι * turnsIn R p L ≤ a * L := by
  obtain ⟨R, -, hRc, hR⟩ :=
    exists_subset_sum_le (fun i => turnCount (fun s => p s i) L) Finset.univ a (by simpa)
  refine ⟨R, hRc, ?_⟩
  have hnt : turnsIn Finset.univ p L = L := by
    unfold turnsIn turnCount
    rw [Finset.filter_true_of_mem, Finset.card_range]
    intro s hs he
    have h := hw s (Finset.mem_range.1 hs)
    apply (HQ ι).loopless.irrefl (p s)
    have : p s = p (s + 1) := by
      funext k; exact congrFun he ⟨k, Finset.mem_univ k⟩
    rw [this] at h ⊢; exact h
  have htot : ∑ i, turnCount (fun s => p s i) L = L := by
    rw [← turnsIn_eq_sum_flips Finset.univ hw, hnt]
  rw [turnsIn_eq_sum_flips R hw]
  simpa [htot] using hR

/-- Two-sided summary for snakes in `Q n`: there is an `a`-dimensional row split with at most
`a L / n` direction changes, and every `a`-dimensional row split has at least
`(L + 1) / 2 ^ (n - a) - 1` of them. -/
theorem turn_normal_form_two_sided {n L : ℕ} {p : ℕ → Fin n → Bool} (hp : IsSnake (Q n) p L)
    (a : ℕ) (ha : a ≤ n) :
    ∃ R : Finset (Fin n), R.card = a ∧ n * turnsIn R p L ≤ a * L ∧
      L + 1 ≤ (turnsIn R p L + 1) * 2 ^ (n - a) := by
  have hp' : IsSnake (HQ (Fin n)) p L := hp
  obtain ⟨R, hRc, hR⟩ := exists_turnsIn_le hp'.isWalk a (by simpa using ha)
  refine ⟨R, hRc, by simpa using hR, ?_⟩
  have := succ_le_turnsIn_succ_mul_pow R hp'
  simpa [hRc] using this

end TurnMinimal