module

public import Mathlib

/-!
# Knee stability is equivalent to tail-exchangeability

A *demand multiset* is a finite multiset `D : Multiset ℕ`.

* `tail D t` is the **upper-tail counting function**: the number of demands strictly
  exceeding the threshold `t`.
* `knee D g` is the **knee at gate `g`**: the least threshold `t` such that at most `g`
  demands exceed `t`.

Main results:

* `knee_le_iff` : Galois connection `knee D g ≤ t ↔ tail D t ≤ g`.
* `knee_eq_sortDesc_getD` : the knee is an order statistic (the `g`-th entry, 0-indexed,
  of the demands sorted in decreasing order, `0` past the end).
* `knee_eq_iff_tail_eq` / `tail_eq_iff_filter_pos_eq` : equal knees at all gates
  ↔ equal tail functions ↔ equal multisets of *positive* demands.
* `knee_window_iff_clamp` / `knee_window_iff_band` : equal knees on a gate window `[a, b]`
  ↔ equal tail functions after clamping to the count band `[a, b+1]`.
* `naive_closed_band_false` : the naive "agree whenever the count lies in `[a, b]`"
  formulation is false.
* conjugate-partition duality (`tail_eq_card_knee_gt`, `knee_eq_card_tail_gt`) and the
  area identity `sum_knee_eq_sum`.
* stability: `knee_shift_of_tail_le` (Lipschitz-type sandwich) and merge bounds.
-/

@[expose] public section

namespace Catalog.NumberTheory.KneeTail

/-- Upper-tail counting function: number of demands strictly above the threshold `t`. -/
def tail (D : Multiset ℕ) (t : ℕ) : ℕ := (D.filter (fun d => t < d)).card

theorem tail_eq_zero_of_forall_le {D : Multiset ℕ} {t : ℕ} (h : ∀ d ∈ D, d ≤ t) :
    tail D t = 0 := by
  unfold tail
  rw [Multiset.card_eq_zero, Multiset.filter_eq_nil]
  intro d hd
  exact not_lt.2 (h d hd)

theorem tail_sup_eq_zero (D : Multiset ℕ) : tail D D.sup = 0 :=
  tail_eq_zero_of_forall_le (fun _ hd => Multiset.le_sup hd)

theorem exists_tail_le (D : Multiset ℕ) (g : ℕ) : ∃ t, tail D t ≤ g :=
  ⟨D.sup, by rw [tail_sup_eq_zero]; exact Nat.zero_le g⟩

/-- Knee at gate `g`: least threshold exceeded by at most `g` demands. -/
def knee (D : Multiset ℕ) (g : ℕ) : ℕ := Nat.find (exists_tail_le D g)

theorem tail_antitone (D : Multiset ℕ) : Antitone (tail D) := by
  intro s t hst
  unfold tail
  apply Multiset.card_le_card
  apply Multiset.monotone_filter_right
  intro d hd
  exact lt_of_le_of_lt hst hd

theorem tail_le_card (D : Multiset ℕ) (t : ℕ) : tail D t ≤ D.card :=
  Multiset.card_le_card (Multiset.filter_le _ _)

/-- **Galois connection** between knees and tails. -/
theorem knee_le_iff (D : Multiset ℕ) (g t : ℕ) : knee D g ≤ t ↔ tail D t ≤ g := by
  unfold knee
  rw [Nat.find_le_iff]
  constructor
  · rintro ⟨m, hm, h⟩
    exact le_trans (tail_antitone D hm) h
  · intro h
    exact ⟨t, le_rfl, h⟩

theorem lt_knee_iff (D : Multiset ℕ) (g t : ℕ) : t < knee D g ↔ g < tail D t := by
  rw [← not_le, knee_le_iff, not_le]

theorem tail_knee_le (D : Multiset ℕ) (g : ℕ) : tail D (knee D g) ≤ g :=
  (knee_le_iff D g _).1 le_rfl

theorem knee_antitone (D : Multiset ℕ) : Antitone (knee D) := by
  intro g h hgh
  rw [knee_le_iff]
  exact le_trans (tail_knee_le D g) hgh

theorem knee_le_sup (D : Multiset ℕ) (g : ℕ) : knee D g ≤ D.sup := by
  rw [knee_le_iff, tail_sup_eq_zero]; exact Nat.zero_le g

theorem knee_eq_zero_iff (D : Multiset ℕ) (g : ℕ) : knee D g = 0 ↔ tail D 0 ≤ g := by
  rw [← Nat.le_zero, knee_le_iff]

/-- Pointwise criterion: knees at gate `g` agree iff the sublevel tests `tail · t ≤ g`
agree at every threshold. -/
theorem knee_eq_knee_iff (D D' : Multiset ℕ) (g : ℕ) :
    knee D g = knee D' g ↔ ∀ t, (tail D t ≤ g ↔ tail D' t ≤ g) := by
  constructor
  · intro h t
    rw [← knee_le_iff, ← knee_le_iff, h]
  · intro h
    apply le_antisymm
    · rw [knee_le_iff, h, ← knee_le_iff]
    · rw [knee_le_iff, ← h, ← knee_le_iff]

/-- **Knee stability ↔ tail-exchangeability** (all gates). -/
theorem knee_eq_iff_tail_eq (D D' : Multiset ℕ) : knee D = knee D' ↔ tail D = tail D' := by
  constructor
  · intro h
    funext t
    apply le_antisymm
    · rw [← knee_le_iff, h, knee_le_iff]
    · rw [← knee_le_iff, ← h, knee_le_iff]
  · intro h
    funext g
    rw [knee_eq_knee_iff]
    intro t
    rw [h]


/-! ### Tails determine the positive part of the multiset -/

theorem tail_cons (a : ℕ) (D : Multiset ℕ) (t : ℕ) :
    tail (a ::ₘ D) t = tail D t + if t < a then 1 else 0 := by
  unfold tail
  rw [Multiset.filter_cons]
  split_ifs <;> simp

theorem tail_add (D E : Multiset ℕ) (t : ℕ) : tail (D + E) t = tail D t + tail E t := by
  unfold tail; rw [Multiset.filter_add, Multiset.card_add]

/-- The histogram is the discrete derivative of the tail. -/
theorem tail_eq_tail_succ_add_count (D : Multiset ℕ) (k : ℕ) :
    tail D k = tail D (k+1) + D.count (k+1) := by
  induction D using Multiset.induction_on with
  | empty => simp [tail]
  | cons a D ih =>
    rw [tail_cons, tail_cons, Multiset.count_cons, ih]
    split_ifs <;> omega

theorem tail_filter_pos (D : Multiset ℕ) (t : ℕ) : tail (D.filter (0 < ·)) t = tail D t := by
  unfold tail
  rw [Multiset.filter_filter]
  congr 1
  apply Multiset.filter_congr
  intro d _
  constructor
  · exact fun h => h.1
  · intro h; exact ⟨h, by omega⟩

/-- Tail functions agree iff the multisets of positive demands agree
(zero demands are invisible to every tail and every knee). -/
theorem tail_eq_iff_filter_pos_eq (D D' : Multiset ℕ) :
    tail D = tail D' ↔ D.filter (0 < ·) = D'.filter (0 < ·) := by
  constructor
  · intro h
    ext v
    rw [Multiset.count_filter, Multiset.count_filter]
    rcases v with _ | k
    · simp
    · simp only [Nat.succ_pos, if_true]
      have h1 := tail_eq_tail_succ_add_count D k
      have h2 := tail_eq_tail_succ_add_count D' k
      rw [h] at h1
      omega
  · intro h
    funext t
    rw [← tail_filter_pos D, h, tail_filter_pos]

/-- **Main theorem (all gates).** Equal knees at every gate ⟺ equal upper-tail counting
functions ⟺ equal multisets of positive demands. -/
theorem knee_eq_iff_filter_pos_eq (D D' : Multiset ℕ) :
    knee D = knee D' ↔ D.filter (0 < ·) = D'.filter (0 < ·) := by
  rw [knee_eq_iff_tail_eq, tail_eq_iff_filter_pos_eq]

/-- For multisets of strictly positive demands, knee stability is plain equality. -/
theorem knee_eq_iff_eq_of_pos {D D' : Multiset ℕ} (hD : ∀ d ∈ D, 0 < d)
    (hD' : ∀ d ∈ D', 0 < d) : knee D = knee D' ↔ D = D' := by
  rw [knee_eq_iff_filter_pos_eq, Multiset.filter_eq_self.2 hD, Multiset.filter_eq_self.2 hD']

/-! ### Gate windows and count bands -/

/-- Clamp a count to the band `[a, a + w]`. -/
def clampBand (a w x : ℕ) : ℕ := min (max x a) (a + w)

/-- **Main theorem (gate window).** Knees agree on the gate window `a ≤ g < a + w` iff the
tail counting functions agree after clamping to the count band `[a, a + w]`. -/
theorem knee_window_iff_clamp (D D' : Multiset ℕ) (a w : ℕ) :
    (∀ g, a ≤ g → g < a + w → knee D g = knee D' g) ↔
      ∀ t, clampBand a w (tail D t) = clampBand a w (tail D' t) := by
  constructor
  · intro h t
    have key : ∀ g, a ≤ g → g < a + w → (tail D t ≤ g ↔ tail D' t ≤ g) :=
      fun g ha hb => (knee_eq_knee_iff D D' g).1 (h g ha hb) t
    unfold clampBand
    rcases lt_trichotomy (min (max (tail D t) a) (a + w)) (min (max (tail D' t) a) (a + w))
      with hlt | heq | hgt
    · have := key (min (max (tail D t) a) (a + w)) (by omega) (by omega)
      omega
    · exact heq
    · have := key (min (max (tail D' t) a) (a + w)) (by omega) (by omega)
      omega
  · intro h g ha hb
    rw [knee_eq_knee_iff]
    intro t
    have := h t
    unfold clampBand at this
    omega

/-- Band formulation of the window theorem (for a nonempty window): the tails induce the
same "below band" / "above band" classification and coincide inside the open band. -/
theorem knee_window_iff_band (D D' : Multiset ℕ) (a w : ℕ) (hw : 0 < w) :
    (∀ g, a ≤ g → g < a + w → knee D g = knee D' g) ↔
      ∀ t, (tail D t ≤ a ↔ tail D' t ≤ a) ∧ (a + w ≤ tail D t ↔ a + w ≤ tail D' t) ∧
        (a < tail D t → tail D t < a + w → tail D t = tail D' t) := by
  rw [knee_window_iff_clamp]
  apply forall_congr'
  intro t
  unfold clampBand
  constructor
  · intro h
    refine ⟨?_, ?_, ?_⟩ <;> omega
  · rintro ⟨h1, h2, h3⟩
    omega

/-- **Critic's boundary.** The naive formulation "if knees agree on gates `[a, b]` then the
tail functions agree wherever the count lies in the *closed* band `[a, b]`" is false:
take `D = {5}`, `D' = ∅`, `a = b = 1`, `t = 0`. -/
theorem naive_closed_band_false :
    ¬ ∀ (D D' : Multiset ℕ) (a b : ℕ), (∀ g, a ≤ g → g ≤ b → knee D g = knee D' g) →
      ∀ t, a ≤ tail D t → tail D t ≤ b → tail D t = tail D' t := by
  intro h
  have hD : tail ({5} : Multiset ℕ) 0 = 1 := by simp [tail, Multiset.filter_singleton]
  have hD' : tail (0 : Multiset ℕ) 0 = 0 := by simp [tail]
  have hk : ∀ g, 1 ≤ g → g ≤ 1 → knee ({5} : Multiset ℕ) g = knee 0 g := by
    intro g h1 _
    rw [(knee_eq_zero_iff _ _).2 (by rw [hD]; exact h1), (knee_eq_zero_iff _ _).2 (by
      rw [hD']; exact Nat.zero_le g)]
  have := h {5} 0 1 1 hk 0 (by rw [hD]) (by rw [hD])
  rw [hD, hD'] at this
  exact absurd this (by norm_num)

/-- **Finite sweep suffices.** Equality of knees at all gates is decided by the gates
`g < max |D| |D'|`. -/
theorem knee_eq_iff_finite_sweep (D D' : Multiset ℕ) :
    knee D = knee D' ↔ ∀ g < max D.card D'.card, knee D g = knee D' g := by
  constructor
  · intro h g _; rw [h]
  · intro h
    rw [knee_eq_iff_tail_eq]
    have hw := (knee_window_iff_clamp D D' 0 (max D.card D'.card)).1
      (fun g _ hg => h g (by omega))
    funext t
    have := hw t
    have h1 := tail_le_card D t
    have h2 := tail_le_card D' t
    unfold clampBand at this
    omega

/-! ### The knee is an order statistic -/

theorem list_filter_length_le_iff (L : List ℕ) (hL : L.Pairwise (fun a b => b ≤ a))
    (g t : ℕ) : (L.filter (fun d => decide (t < d))).length ≤ g ↔ L.getD g 0 ≤ t := by
  induction L generalizing g with
  | nil => simp
  | cons x l ih =>
    rw [List.pairwise_cons] at hL
    obtain ⟨hx, hl⟩ := hL
    rcases g with _ | k
    · simp only [List.getD_cons_zero, Nat.le_zero, List.length_eq_zero_iff,
        List.filter_eq_nil_iff, decide_eq_true_eq, not_lt]
      constructor
      · intro h; exact h x (by simp)
      · intro h d hd
        rcases List.mem_cons.1 hd with rfl | hd
        · exact h
        · exact le_trans (hx d hd) h
    · simp only [List.getD_cons_succ]
      by_cases hxt : t < x
      · rw [List.filter_cons_of_pos (by simpa using hxt), List.length_cons, ← ih hl k]
        omega
      · push_neg at hxt
        have hnil : l.filter (fun d => decide (t < d)) = [] := by
          rw [List.filter_eq_nil_iff]
          intro d hd; simpa using le_trans (hx d hd) hxt
        rw [List.filter_cons_of_neg (by simpa using hxt), hnil]
        simp only [List.length_nil, zero_le, true_iff]
        rw [List.getD_eq_getElem?_getD]
        rcases h : l[k]? with _ | y
        · simp
        · simp only [Option.getD_some]
          exact le_trans (hx y (List.mem_of_getElem? h)) hxt

/-- Demands sorted in decreasing order. -/
def sortDesc (D : Multiset ℕ) : List ℕ := D.sort (fun a b => b ≤ a)

theorem tail_eq_length_filter_sortDesc (D : Multiset ℕ) (t : ℕ) :
    tail D t = ((sortDesc D).filter (fun d => decide (t < d))).length := by
  unfold tail sortDesc
  conv_lhs => rw [← Multiset.sort_eq D (fun a b => b ≤ a)]
  rw [Multiset.filter_coe, Multiset.coe_card]

/-- **The knee is an order statistic**: the knee at gate `g` is the `(g+1)`-st largest
demand (and `0` if there are at most `g` demands). -/
theorem knee_eq_sortDesc_getD (D : Multiset ℕ) (g : ℕ) :
    knee D g = (sortDesc D).getD g 0 := by
  have hs : (sortDesc D).Pairwise (fun a b => b ≤ a) := Multiset.pairwise_sort _ _
  have key : ∀ t, knee D g ≤ t ↔ (sortDesc D).getD g 0 ≤ t := by
    intro t
    rw [knee_le_iff, tail_eq_length_filter_sortDesc, list_filter_length_le_iff _ hs]
  exact le_antisymm ((key _).2 le_rfl) ((key _).1 le_rfl)

/-! ### Conjugate-partition duality and the area identity -/

/-- The tail is the conjugate of the knee sequence. -/
theorem tail_eq_card_knee_gt (D : Multiset ℕ) (t : ℕ) :
    tail D t = ((Finset.range D.card).filter (fun g => t < knee D g)).card := by
  have : (Finset.range D.card).filter (fun g => t < knee D g) = Finset.range (tail D t) := by
    ext g
    simp only [Finset.mem_filter, Finset.mem_range, lt_knee_iff]
    have := tail_le_card D t
    omega
  rw [this, Finset.card_range]

/-- The knee is the conjugate of the tail function: one histogram yields every knee. -/
theorem knee_eq_card_tail_gt (D : Multiset ℕ) (g : ℕ) :
    knee D g = ((Finset.range (D.sup + 1)).filter (fun t => g < tail D t)).card := by
  have : (Finset.range (D.sup + 1)).filter (fun t => g < tail D t) =
      Finset.range (knee D g) := by
    ext t
    simp only [Finset.mem_filter, Finset.mem_range, ← lt_knee_iff]
    have := knee_le_sup D g
    omega
  rw [this, Finset.card_range]

theorem card_filter_range_lt {M a : ℕ} (h : a ≤ M) :
    ((Finset.range M).filter (fun t => t < a)).card = a := by
  have : (Finset.range M).filter (fun t => t < a) = Finset.range a := by
    ext t; simp only [Finset.mem_filter, Finset.mem_range]; omega
  rw [this, Finset.card_range]

theorem sum_tail_eq_sum (D : Multiset ℕ) (M : ℕ) (hM : ∀ d ∈ D, d ≤ M) :
    ∑ t ∈ Finset.range M, tail D t = D.sum := by
  induction D using Multiset.induction_on with
  | empty => simp [tail]
  | cons a D ih =>
    simp only [tail_cons, Finset.sum_add_distrib, Multiset.sum_cons]
    rw [ih (fun d hd => hM d (Multiset.mem_cons_of_mem hd)), Finset.sum_boole,
      card_filter_range_lt (hM a (Multiset.mem_cons_self a D))]
    simp [add_comm]

/-- **Area identity**: the knees over all gates sum to the total demand
(the Young diagram has the same area read by rows or by columns). -/
theorem sum_knee_eq_sum (D : Multiset ℕ) :
    ∑ g ∈ Finset.range D.card, knee D g = D.sum := by
  calc ∑ g ∈ Finset.range D.card, knee D g
      = ∑ g ∈ Finset.range D.card, ∑ t ∈ Finset.range (D.sup + 1),
          (if g < tail D t then 1 else 0) := by
        apply Finset.sum_congr rfl
        intro g _
        rw [knee_eq_card_tail_gt, Finset.sum_boole]
        simp
    _ = ∑ t ∈ Finset.range (D.sup + 1), ∑ g ∈ Finset.range D.card,
          (if g < tail D t then 1 else 0) := Finset.sum_comm
    _ = ∑ t ∈ Finset.range (D.sup + 1), tail D t := by
        apply Finset.sum_congr rfl
        intro t _
        rw [Finset.sum_boole, card_filter_range_lt (tail_le_card D t)]
        simp
    _ = D.sum := sum_tail_eq_sum D _ (fun d hd => le_trans (Multiset.le_sup hd)
          (Nat.le_succ _))

/-! ### Stability -/

/-- **Gate-shift sandwich**: if the tails of `D'` exceed those of `D` by at most `k`,
then the knees of `D'` at gate `g + k` are bounded by the knees of `D` at gate `g`. -/
theorem knee_shift_of_tail_le {D D' : Multiset ℕ} {k : ℕ}
    (h : ∀ t, tail D' t ≤ tail D t + k) (g : ℕ) : knee D' (g + k) ≤ knee D g := by
  rw [knee_le_iff]
  have := tail_knee_le D g
  have := h (knee D g)
  omega

/-- Contamination robustness: adding `k` arbitrary demands shifts knees by at most `k`
gates: `knee (D + F) (g + k) ≤ knee D g ≤ knee (D + F) g`. -/
theorem knee_contamination (D F : Multiset ℕ) (g : ℕ) :
    knee (D + F) (g + F.card) ≤ knee D g ∧ knee D g ≤ knee (D + F) g := by
  constructor
  · apply knee_shift_of_tail_le
    intro t
    rw [tail_add]
    have := tail_le_card F t
    omega
  · rw [knee_le_iff]
    have := tail_knee_le (D + F) g
    rw [tail_add] at this
    omega

/-- Merge bound for pooled corpora. -/
theorem knee_add_le_max (D E : Multiset ℕ) (g h : ℕ) :
    knee (D + E) (g + h) ≤ max (knee D g) (knee E h) := by
  rw [knee_le_iff, tail_add]
  have h1 := le_trans (tail_antitone D (le_max_left (knee D g) (knee E h))) (tail_knee_le D g)
  have h2 := le_trans (tail_antitone E (le_max_right (knee D g) (knee E h))) (tail_knee_le E h)
  omega

theorem max_knee_le_knee_add (D E : Multiset ℕ) (g : ℕ) :
    max (knee D g) (knee E g) ≤ knee (D + E) g := by
  have := tail_knee_le (D + E) g
  rw [tail_add] at this
  apply max_le
  · rw [knee_le_iff]; omega
  · rw [knee_le_iff]; omega

/-- **Gate-shift ⟺ tail-shift.** Knees of `D'` at gate `g + k` are bounded by knees of `D`
at gate `g` for every `g` iff the tails of `D'` exceed those of `D` by at most `k`
everywhere. The gate-shift (Lévy-type) distance between knee profiles equals the
sup-distance between tail histograms. -/
theorem knee_shift_iff_tail_le (D D' : Multiset ℕ) (k : ℕ) :
    (∀ g, knee D' (g + k) ≤ knee D g) ↔ ∀ t, tail D' t ≤ tail D t + k := by
  constructor
  · intro h t
    have h1 : knee D (tail D t) ≤ t := (knee_le_iff D _ t).2 le_rfl
    exact (knee_le_iff D' _ t).1 (le_trans (h (tail D t)) h1)
  · exact fun h g => knee_shift_of_tail_le h g

/-- Symmetric version: tails within sup-distance `k` iff knee profiles are mutually
`k`-gate-shift bounded. -/
theorem tail_dist_le_iff_knee_sandwich (D D' : Multiset ℕ) (k : ℕ) :
    (∀ t, tail D' t ≤ tail D t + k ∧ tail D t ≤ tail D' t + k) ↔
      ∀ g, knee D' (g + k) ≤ knee D g ∧ knee D (g + k) ≤ knee D' g := by
  rw [forall_and, forall_and, knee_shift_iff_tail_le, knee_shift_iff_tail_le]

end Catalog.NumberTheory.KneeTail