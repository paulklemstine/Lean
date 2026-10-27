import Mathlib

/-!
# Multi-window crossing law, part I: the layer-cake displacement law

An oracle names `k` nested prefix windows `{0,…,w_i - 1}` of `M` cells.  A *layered*
posterior puts weight `b + Σ_i c_i · [j < w_i]` on cell `j`: a base level `b` plus a jump
`c_i` for every window containing `j`.  A search order is a permutation `σ` of `Fin M`
(probe slot `i` inspects cell `σ i`); its cost is the expected number of probes.

## Main results
* `layer_cake_cost` — the cost of **every** order is
  `b · M(M+1)/2 + Σ_i c_i · (index sum of the slots probing window i)`.
* `multi_displacement_law` — relative to the committed order, an order pays exactly
  `Σ_i c_i · (slot-index excess of window i)`.
* `slotSum_ge` — any `w` slots have index sum at least `w(w+1)/2`, plus one per slot beyond
  the first `w` (proved by induction on the maximum element).
* `multi_misplacement_cost`, `multi_bayes_eq_committed` — for nonnegative jumps the committed
  order is Bayes-optimal; every misplaced cell of window `i` costs at least `c_i`.
* `multi_bayes_order_iff` — for strictly positive jumps the Bayes orders are exactly the
  orders that probe each window inside its own first `w_i` slots.
* `antitone_layer_decomposition`, `committed_optimal_of_antitone` — every nonincreasing
  posterior is layered (with the `M` single-cell thresholds), so committed search is
  Bayes-optimal for every nonincreasing posterior.
-/

namespace MultiWindowCrossingLaw

open Finset

/-- Expected number of probes of order `σ` under the weight vector `q`. -/
noncomputable def probeCost {M : ℕ} (q : Fin M → ℝ) (σ : Equiv.Perm (Fin M)) : ℝ :=
  ∑ i : Fin M, (((i : ℕ) : ℝ) + 1) * q (σ i)

/-- The probe slots in which `σ` inspects a cell of the window `{0,…,w-1}`. -/
def windowSlots (M w : ℕ) (σ : Equiv.Perm (Fin M)) : Finset (Fin M) :=
  univ.filter fun i => (σ i : ℕ) < w

/-- Index sum (1-based) of a set of slots. -/
noncomputable def slotSum {M : ℕ} (U : Finset (Fin M)) : ℝ := ∑ i ∈ U, (((i : ℕ) : ℝ) + 1)

/-- The first `w` cells of `Fin M`. -/
def firstCells (M w : ℕ) : Finset (Fin M) := univ.filter fun i => (i : ℕ) < w

/-- Layered posterior: base level `b`, plus jump `c i` on the window `{0,…,w i - 1}`. -/
noncomputable def layered {M : ℕ} (b : ℝ) (k : ℕ) (w : ℕ → ℕ) (c : ℕ → ℝ) (j : Fin M) : ℝ :=
  b + ∑ i ∈ range k, if (j : ℕ) < w i then c i else 0

lemma firstCells_map (M w : ℕ) (hw : w ≤ M) :
    (firstCells M w).map Fin.valEmbedding = range w := by
  ext x
  simp only [firstCells, Finset.mem_map, mem_filter, mem_univ, true_and,
    Fin.valEmbedding_apply, mem_range]
  constructor
  · rintro ⟨i, hi, rfl⟩; exact hi
  · intro hx; exact ⟨⟨x, by omega⟩, hx, rfl⟩

lemma card_firstCells (M w : ℕ) (hw : w ≤ M) : (firstCells M w).card = w := by
  rw [← card_map Fin.valEmbedding, firstCells_map M w hw, card_range]

lemma sum_range_succ_real (w : ℕ) : ∑ x ∈ range w, ((x : ℝ) + 1) = (w : ℝ) * (w + 1) / 2 := by
  induction w with
  | zero => simp
  | succ n ih => rw [sum_range_succ, ih]; push_cast; ring

lemma slotSum_firstCells (M w : ℕ) (hw : w ≤ M) :
    slotSum (firstCells M w) = (w : ℝ) * (w + 1) / 2 := by
  rw [← sum_range_succ_real, ← firstCells_map M w hw, sum_map]
  rfl

lemma slotSum_univ (M : ℕ) : slotSum (univ : Finset (Fin M)) = (M : ℝ) * (M + 1) / 2 := by
  unfold slotSum
  rw [Fin.sum_univ_eq_sum_range (fun i => (i : ℝ) + 1), sum_range_succ_real]

lemma windowSlots_refl (M w : ℕ) : windowSlots M w (Equiv.refl (Fin M)) = firstCells M w := rfl

lemma windowSlots_eq_map (M w : ℕ) (σ : Equiv.Perm (Fin M)) :
    windowSlots M w σ = (firstCells M w).map σ.symm.toEmbedding := by
  ext i
  simp only [windowSlots, firstCells, mem_filter, mem_univ, true_and, Finset.mem_map,
    Equiv.coe_toEmbedding]
  constructor
  · intro h; exact ⟨σ i, h, by simp⟩
  · rintro ⟨j, hj, rfl⟩; simpa using hj

lemma card_windowSlots (M w : ℕ) (hw : w ≤ M) (σ : Equiv.Perm (Fin M)) :
    (windowSlots M w σ).card = w := by
  rw [windowSlots_eq_map, card_map, card_firstCells M w hw]

/-! ## 1. The layer-cake cost formula -/

/-- **Layer-cake cost formula.**  For every order `σ`, the cost under a layered posterior is the
base cost plus, for each window, its jump times the index sum of the slots probing it. -/
theorem layer_cake_cost (M : ℕ) (b : ℝ) (k : ℕ) (w : ℕ → ℕ) (c : ℕ → ℝ)
    (σ : Equiv.Perm (Fin M)) :
    probeCost (layered b k w c) σ =
      b * ((M : ℝ) * (M + 1) / 2) + ∑ i ∈ range k, c i * slotSum (windowSlots M (w i) σ) := by
  unfold probeCost layered slotSum windowSlots
  have h1 : ∀ s : Fin M, (((s : ℕ) : ℝ) + 1) * (b + ∑ l ∈ range k,
      if ((σ s : Fin M) : ℕ) < w l then c l else 0) =
      b * (((s : ℕ) : ℝ) + 1) + ∑ l ∈ range k,
        (if ((σ s : Fin M) : ℕ) < w l then c l * (((s : ℕ) : ℝ) + 1) else 0) := by
    intro s
    rw [mul_add, mul_sum]
    congr 1
    · ring
    · refine sum_congr rfl fun l _ => ?_
      split_ifs <;> ring
  rw [sum_congr rfl (fun s _ => h1 s), sum_add_distrib, ← mul_sum, sum_comm]
  congr 1
  · rw [Fin.sum_univ_eq_sum_range (fun i => (i : ℝ) + 1), sum_range_succ_real]
  · refine sum_congr rfl fun l _ => ?_
    rw [sum_filter, mul_sum]
    exact sum_congr rfl fun i _ => by split_ifs <;> simp

/-- **Multi-window displacement law.**  Relative to the committed order, any order pays exactly
`Σ_i c_i · (Σ window-`i` slots − w_i(w_i+1)/2)`. -/
theorem multi_displacement_law (M : ℕ) (b : ℝ) (k : ℕ) (w : ℕ → ℕ) (c : ℕ → ℝ)
    (hw : ∀ i ∈ range k, w i ≤ M) (σ : Equiv.Perm (Fin M)) :
    probeCost (layered b k w c) σ - probeCost (layered b k w c) (Equiv.refl (Fin M)) =
      ∑ i ∈ range k, c i * (slotSum (windowSlots M (w i) σ) - (w i : ℝ) * (w i + 1) / 2) := by
  rw [layer_cake_cost, layer_cake_cost, add_sub_add_left_eq_sub, ← sum_sub_distrib]
  refine sum_congr rfl fun i hi => ?_
  rw [windowSlots_refl, slotSum_firstCells M (w i) (hw i hi)]
  ring

/-! ## 2. The exchange bound on slot sums -/

/-- Natural-number core: a finite set `S ⊆ ℕ` of size `n` satisfies
`n(n+1) + 2·#{x ∈ S | n ≤ x} ≤ 2 Σ_{x∈S} (x+1)`. -/
lemma nat_slot_bound (S : Finset ℕ) :
    S.card * (S.card + 1) + 2 * (S.filter fun x => S.card ≤ x).card ≤
      2 * ∑ x ∈ S, (x + 1) := by
  induction S using Finset.induction_on_max with
  | h0 => simp
  | step a s hlt ih =>
    have ha : a ∉ s := fun h => lt_irrefl a (hlt a h)
    have hsub : s ⊆ range a := fun x hx => mem_range.2 (hlt x hx)
    have hca : s.card ≤ a := by simpa using card_le_card hsub
    rw [card_insert_of_notMem ha, sum_insert ha]
    set m := s.card
    have hfilt : ((insert a s).filter fun x => m + 1 ≤ x).card ≤
        (s.filter fun x => m ≤ x).card + (if m + 1 ≤ a then 1 else 0) := by
      rw [filter_insert]
      split_ifs with h
      · refine (card_insert_le _ _).trans ?_
        exact Nat.add_le_add_right (card_le_card (monotone_filter_right _
          (fun x _ hx => by omega))) 1
      · simpa using card_le_card (monotone_filter_right s (fun x _ (hx : m + 1 ≤ x) => by omega))
    split_ifs at hfilt with h <;> nlinarith

/-- **Slot-sum exchange bound.**  Any `w` slots have index sum at least `w(w+1)/2`, plus one
for every slot beyond the first `w`. -/
theorem slotSum_ge {M : ℕ} (U : Finset (Fin M)) :
    (U.card : ℝ) * (U.card + 1) / 2 + ((U.filter fun i : Fin M => U.card ≤ (i : ℕ)).card : ℝ)
      ≤ slotSum U := by
  have h := nat_slot_bound (U.map Fin.valEmbedding)
  rw [card_map, sum_map, filter_map, card_map] at h
  have h' : ((U.card : ℝ) * (U.card + 1) + 2 * ((U.filter fun i : Fin M => U.card ≤ (i : ℕ)).card
      : ℝ)) ≤ 2 * ∑ i ∈ U, (((i : ℕ) : ℝ) + 1) := by
    exact_mod_cast h
  unfold slotSum
  linarith

/-- Number of cells of window `w` that `σ` probes after slot `w` (misplaced cells). -/
def misplaced (M w : ℕ) (σ : Equiv.Perm (Fin M)) : ℕ :=
  ((windowSlots M w σ).filter fun i : Fin M => w ≤ (i : ℕ)).card

lemma slot_excess_ge (M w : ℕ) (hw : w ≤ M) (σ : Equiv.Perm (Fin M)) :
    (misplaced M w σ : ℝ) ≤ slotSum (windowSlots M w σ) - (w : ℝ) * (w + 1) / 2 := by
  have h := slotSum_ge (windowSlots M w σ)
  rw [card_windowSlots M w hw] at h
  unfold misplaced
  linarith

/-! ## 3. Bayes optimality of the committed order -/

/-- **Multi-window misplacement cost.**  With nonnegative jumps, every misplaced cell of window
`i` costs at least `c_i` on top of the committed cost. -/
theorem multi_misplacement_cost (M : ℕ) (b : ℝ) (k : ℕ) (w : ℕ → ℕ) (c : ℕ → ℝ)
    (hw : ∀ i ∈ range k, w i ≤ M) (hc : ∀ i ∈ range k, 0 ≤ c i) (σ : Equiv.Perm (Fin M)) :
    probeCost (layered b k w c) (Equiv.refl (Fin M)) +
        ∑ i ∈ range k, c i * (misplaced M (w i) σ : ℝ) ≤
      probeCost (layered b k w c) σ := by
  have hd := multi_displacement_law M b k w c hw σ
  have : ∑ i ∈ range k, c i * (misplaced M (w i) σ : ℝ) ≤
      ∑ i ∈ range k, c i * (slotSum (windowSlots M (w i) σ) - (w i : ℝ) * (w i + 1) / 2) :=
    sum_le_sum fun i hi => mul_le_mul_of_nonneg_left (slot_excess_ge M _ (hw i hi) σ) (hc i hi)
  linarith

/-- **Bayes ≡ Committed (multi-window).**  With nonnegative jumps the committed order is
optimal among all `M!` orders. -/
theorem multi_bayes_eq_committed (M : ℕ) (b : ℝ) (k : ℕ) (w : ℕ → ℕ) (c : ℕ → ℝ)
    (hw : ∀ i ∈ range k, w i ≤ M) (hc : ∀ i ∈ range k, 0 ≤ c i) (σ : Equiv.Perm (Fin M)) :
    probeCost (layered b k w c) (Equiv.refl (Fin M)) ≤ probeCost (layered b k w c) σ := by
  have h := multi_misplacement_cost M b k w c hw hc σ
  have : 0 ≤ ∑ i ∈ range k, c i * (misplaced M (w i) σ : ℝ) :=
    sum_nonneg fun i hi => mul_nonneg (hc i hi) (by positivity)
  linarith

/-- **Uniqueness of the Bayes orders.**  If every jump is strictly positive, an order is
Bayes-optimal iff, for every window `i`, every cell of window `i` is probed within the first
`w_i` slots. -/
theorem multi_bayes_order_iff (M : ℕ) (b : ℝ) (k : ℕ) (w : ℕ → ℕ) (c : ℕ → ℝ)
    (hw : ∀ i ∈ range k, w i ≤ M) (hc : ∀ i ∈ range k, 0 < c i) (σ : Equiv.Perm (Fin M)) :
    probeCost (layered b k w c) σ = probeCost (layered b k w c) (Equiv.refl (Fin M)) ↔
      ∀ l ∈ range k, ∀ i : Fin M, (σ i : ℕ) < w l → (i : ℕ) < w l := by
  constructor
  · intro h l hl i hi
    by_contra hiw
    have hpos : 1 ≤ misplaced M (w l) σ := by
      unfold misplaced
      exact card_pos.mpr ⟨i, by simp [windowSlots, hi]; omega⟩
    have hm := multi_misplacement_cost M b k w c hw (fun i hi => (hc i hi).le) σ
    have hle : c l * 1 ≤ ∑ i ∈ range k, c i * (misplaced M (w i) σ : ℝ) := by
      refine le_trans ?_ (single_le_sum (f := fun i => c i * (misplaced M (w i) σ : ℝ))
        (fun i hi => mul_nonneg (hc i hi).le (by positivity)) hl)
      exact mul_le_mul_of_nonneg_left (by exact_mod_cast hpos) (hc l hl).le
    have := hc l hl
    linarith
  · intro h
    rw [layer_cake_cost, layer_cake_cost]
    congr 1
    refine sum_congr rfl fun l hl => ?_
    have hsub : windowSlots M (w l) σ ⊆ firstCells M (w l) := by
      intro i hi
      simp only [windowSlots, firstCells, mem_filter, mem_univ, true_and] at hi ⊢
      exact h l hl i hi
    rw [eq_of_subset_of_card_le hsub (by rw [card_windowSlots M _ (hw l hl),
      card_firstCells M _ (hw l hl)]), windowSlots_refl]

/-! ## 4. Every nonincreasing posterior is layered -/

/-- Telescoping core: `f j = f N + Σ_{l < N, j ≤ l} (f l - f (l+1))` for `j ≤ N`. -/
lemma telescope_layers (f : ℕ → ℝ) (N j : ℕ) (hj : j ≤ N) :
    f j = f N + ∑ l ∈ range N, if j < l + 1 then f l - f (l + 1) else 0 := by
  induction N with
  | zero => simp at hj; subst hj; simp
  | succ n ih =>
    rw [sum_range_succ]
    rcases Nat.lt_or_ge j (n + 1) with h | h
    · rw [ih (by omega), if_pos h]; ring
    · have hjn : j = n + 1 := by omega
      subst hjn
      have : ∀ l ∈ range n, (if n + 1 < l + 1 then f l - f (l + 1) else 0) = 0 :=
        fun l hl => if_neg (by simp at hl; omega)
      rw [sum_congr rfl this, if_neg (by omega)]
      simp

/-- **Layer decomposition of a nonincreasing posterior.**  Any `q : Fin (N+1) → ℝ` equals the
layered posterior with base `q N` and jump `q l - q (l+1)` at threshold `l+1`. -/
theorem antitone_layer_decomposition (N : ℕ) (q : Fin (N + 1) → ℝ) :
    q = layered (q (Fin.last N)) N (fun l => l + 1)
      (fun l => if h : l + 1 < N + 1 then q ⟨l, by omega⟩ - q ⟨l + 1, h⟩ else 0) := by
  funext j
  let f : ℕ → ℝ := fun n => if h : n < N + 1 then q ⟨n, h⟩ else 0
  have hj := telescope_layers f N j (by omega)
  have hfj : f j = q j := by simp only [f, dif_pos j.isLt]
  have hfN : f N = q (Fin.last N) := by simp [f, Fin.last]
  rw [hfj, hfN] at hj
  rw [hj]
  unfold layered
  congr 1
  refine sum_congr rfl fun l hl => ?_
  simp only [mem_range] at hl
  have h1 : l + 1 < N + 1 := by omega
  simp only [f, dif_pos h1, dif_pos (show l < N + 1 by omega)]

/-- **Committed search is Bayes-optimal for every nonincreasing posterior** (proved through the
layer-cake decomposition rather than a rearrangement inequality). -/
theorem committed_optimal_of_antitone (N : ℕ) (q : Fin (N + 1) → ℝ) (hq : Antitone q)
    (σ : Equiv.Perm (Fin (N + 1))) :
    probeCost q (Equiv.refl _) ≤ probeCost q σ := by
  rw [antitone_layer_decomposition N q]
  refine multi_bayes_eq_committed (N + 1) _ N _ _ (fun i hi => by simp at hi; omega)
    (fun i hi => ?_) σ
  simp only [mem_range] at hi
  simp only [show i + 1 < N + 1 by omega, dite_true, sub_nonneg]
  exact hq (Fin.mk_le_mk.2 (by omega))

end MultiWindowCrossingLaw