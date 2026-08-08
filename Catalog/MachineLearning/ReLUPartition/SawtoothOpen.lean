import Mathlib
import MachineLearning.ReLUPartition.SawtoothExact

/-!
# Generic (open) cells of the sawtooth network

`MachineLearning.ReLUPartition.SawtoothExact` determines the *pointwise* cell
count of the depth-`L` width-two sawtooth network exactly,
`#(sawNet.netRegions L) = 5 · 2 ^ (L - 2) + 1`.  That count is taken over all of
`ℝ`, so it includes cells that are single points — configurations in which some
pre-activation vanishes exactly.  Such cells are invisible to any sampling or
gridding scheme.

This file settles the *generic* count.  Call a pattern word an **open cell** when
some nonempty open interval of inputs realizes it (`IsOpenCell`).  We prove:

* `abs_sub_sawOrbit_eq` — an expansion law: as long as two inputs share a common
  *nonsilent* pattern prefix of length `n`, their orbits separate by exactly
  `2 ^ n`;
* `sigma_degenerate_singleton` — consequently every degenerate cell other than
  the two extreme ones is a **single point** (the orbit is pinned to `1/2` at
  the moment of death, and the expansion law forbids two preimages);
* `exists_open_interval_loud` — conversely each of the `2 ^ L` loud itineraries
  is realized on a whole open interval, obtained by pulling an interval back
  through the inverse tent branches;
* `card_openRegions_sawNet` — hence the exact generic count
  ```
      #(openRegions L) = 2 ^ L + 2 ,
  ```
  the `2 ^ L` itineraries together with the two unbounded cells `t < 0` and
  `t > 1`;
* `card_openRegions_lt_card_netRegions` — pointwise strictly exceeds generic from
  depth `3` on (they agree at depth `2`, so the naive form of the conjecture
  needed this correction), and
* `tendsto_pointwise_div_open` — the ratio of the two counts tends to `5/4`.

Together these quantify exactly how much of the pointwise partition is invisible
to sampling.
-/

namespace ReLUPartition

open Finset

/-! ### Trichotomy of layer patterns -/

lemma cellOf_cases (u : ℝ) : cellOf u = ∅ ∨ cellOf u = {0} ∨ cellOf u = {0, 1} := by
  rcases le_or_gt u 0 with h | h
  · exact Or.inl (cellOf_of_nonpos h)
  · rcases le_or_gt u (1 / 2) with h1 | h1
    · exact Or.inr (Or.inl (cellOf_of_low h h1))
    · exact Or.inr (Or.inr (cellOf_of_high h1))

lemma cellOf_eq_singleton_iff {u : ℝ} : cellOf u = {0} ↔ 0 < u ∧ u ≤ 1 / 2 := by
  constructor
  · intro h
    rcases le_or_gt u 0 with h0 | h0
    · exact absurd ((cellOf_of_nonpos h0).symm.trans h) (Ne.symm singleton_ne_empty)
    · rcases le_or_gt u (1 / 2) with h1 | h1
      · exact ⟨h0, h1⟩
      · exact absurd ((cellOf_of_high h1).symm.trans h) singleton_ne_pair.symm
  · exact fun h => cellOf_of_low h.1 h.2

lemma cellOf_eq_pair_iff {u : ℝ} : cellOf u = {0, 1} ↔ 1 / 2 < u := by
  constructor
  · intro h
    by_contra hcon
    push_neg at hcon
    rcases le_or_gt u 0 with h0 | h0
    · exact pair_ne_empty ((cellOf_of_nonpos h0) ▸ h).symm
    · exact singleton_ne_pair ((cellOf_of_low h0 hcon).symm.trans h)
  · exact cellOf_of_high

/-! ### The expansion law -/

/-- **Expansion law.**  If two inputs produce the same pattern for the first `n`
layers and none of those patterns is silent, then after `n` steps their scalar
orbits are separated by exactly `2 ^ n` times their initial distance.  Each
nonsilent branch of the sawtooth step is affine with slope `± 2`; a silent
pattern would collapse the distance to `0`, which is why the hypothesis is
needed. -/
lemma abs_sub_sawOrbit_eq {t t' : ℝ} :
    ∀ n : ℕ, (∀ l, l < n → cellOf (sawOrbit l t) = cellOf (sawOrbit l t') ∧
        cellOf (sawOrbit l t) ≠ ∅) →
      |sawOrbit n t - sawOrbit n t'| = 2 ^ n * |t - t'| := by
  intro n
  induction n with
  | zero => intro _; simp
  | succ n ih =>
      intro h
      have hn := ih (fun l hl => h l (by omega))
      obtain ⟨heq, hne⟩ := h n (by omega)
      have hstep : |sawOrbit (n + 1) t - sawOrbit (n + 1) t'|
          = 2 * |sawOrbit n t - sawOrbit n t'| := by
        rcases cellOf_cases (sawOrbit n t) with h1 | h1 | h1
        · exact absurd h1 hne
        · have hu := cellOf_eq_singleton_iff.mp h1
          have hu' := cellOf_eq_singleton_iff.mp (heq.symm.trans h1)
          rw [sawOrbit_succ, sawOrbit_succ, sawStep_of_pos_le_half hu.1 hu.2,
            sawStep_of_pos_le_half hu'.1 hu'.2,
            show 2 * sawOrbit n t - 2 * sawOrbit n t'
              = 2 * (sawOrbit n t - sawOrbit n t') by ring, abs_mul]
          norm_num
        · have hu := cellOf_eq_pair_iff.mp h1
          have hu' := cellOf_eq_pair_iff.mp (heq.symm.trans h1)
          rw [sawOrbit_succ, sawOrbit_succ, sawStep_of_half_lt hu, sawStep_of_half_lt hu',
            show 2 - 2 * sawOrbit n t - (2 - 2 * sawOrbit n t')
              = (-2) * (sawOrbit n t - sawOrbit n t') by ring, abs_mul]
          norm_num
      rw [hstep, hn, pow_succ]
      ring

/-! ### Open cells -/

/-- A pattern word is a **generic** (open) cell when a nonempty open interval of
inputs realizes it.  These are exactly the cells that a sampling scheme can
see. -/
def IsOpenCell (L : ℕ) (q : Fin L → Finset (Fin 2)) : Prop :=
  ∃ a b : ℝ, a < b ∧ ∀ t ∈ Set.Ioo a b, sawWord L t = q

lemma IsOpenCell.mem_netRegions {L : ℕ} {q : Fin L → Finset (Fin 2)} (h : IsOpenCell L q) :
    q ∈ sawNet.netRegions L := by
  obtain ⟨a, b, hab, hq⟩ := h
  exact mem_netRegions_iff_sawWord.mpr
    ⟨(a + b) / 2, hq _ ⟨by linarith, by linarith⟩⟩

open Classical in
/-- The generic cells of the depth-`L` sawtooth network. -/
noncomputable def openRegions (L : ℕ) : Finset (Fin L → Finset (Fin 2)) :=
  (sawNet.netRegions L).filter (fun q => IsOpenCell L q)

lemma mem_openRegions {L : ℕ} {q : Fin L → Finset (Fin 2)} :
    q ∈ openRegions L ↔ IsOpenCell L q := by
  classical
  simp only [openRegions, Finset.mem_filter]
  exact ⟨fun h => h.2, fun h => ⟨h.mem_netRegions, h⟩⟩

/-! ### The loud words -/

/-- The pattern word attached to a binary itinerary. -/
def loudWord (L : ℕ) (b : Fin L → Bool) : Fin L → Finset (Fin 2) :=
  fun l => if b l then {0, 1} else {0}

lemma loudWord_ne_empty {L : ℕ} (b : Fin L → Bool) (l : Fin L) : loudWord L b l ≠ ∅ := by
  unfold loudWord
  by_cases h : b l <;> simp [h]

/-- **Every itinerary is realized on an open interval.**  The interval is
obtained by pulling the interval for the tail itinerary back through the
appropriate inverse branch of the tent map. -/
lemma exists_open_interval_loud (L : ℕ) (b : Fin L → Bool) :
    ∃ p q : ℝ, 0 < p ∧ p < q ∧ q < 1 ∧
      ∀ t ∈ Set.Ioo p q, sawWord L t = loudWord L b := by
  induction L with
  | zero =>
      refine ⟨1 / 4, 1 / 2, by norm_num, by norm_num, by norm_num, ?_⟩
      intro t _
      funext l
      exact absurd l.isLt (by omega)
  | succ L ih =>
      obtain ⟨p, q, hp0, hpq, hq1, hword⟩ := ih (fun j : Fin L => b j.succ)
      have key : ∀ (p' q' : ℝ), 0 < p' → p' < q' → q' < 1 →
          (∀ t ∈ Set.Ioo p' q', cellOf t = loudWord (L + 1) b 0 ∧
            sawStep t ∈ Set.Ioo p q) →
          ∀ t ∈ Set.Ioo p' q', sawWord (L + 1) t = loudWord (L + 1) b := by
        intro p' q' _ _ _ hmain t ht
        obtain ⟨h0, hstep⟩ := hmain t ht
        funext l
        refine Fin.cases ?_ ?_ l
        · exact h0
        · intro j
          have hval : ((j.succ : Fin (L + 1)) : ℕ) = (j : ℕ) + 1 := rfl
          show cellOf (sawOrbit ((j.succ : Fin (L + 1)) : ℕ) t) = loudWord (L + 1) b j.succ
          rw [hval]
          have : sawOrbit ((j : ℕ) + 1) t = sawOrbit (j : ℕ) (sawStep t) :=
            Function.iterate_succ_apply sawStep (j : ℕ) t
          rw [this]
          have := congrFun (hword (sawStep t) hstep) j
          simpa [loudWord] using this
      by_cases hb : b 0 = true
      · refine ⟨1 - q / 2, 1 - p / 2, by linarith, by linarith, by linarith, ?_⟩
        refine key _ _ (by linarith) (by linarith) (by linarith) ?_
        intro t ht
        obtain ⟨ht1, ht2⟩ := ht
        have hhalf : 1 / 2 < t := by linarith
        refine ⟨?_, ?_⟩
        · show cellOf (sawOrbit 0 t) = loudWord (L + 1) b 0
          rw [sawOrbit_zero, cellOf_of_high hhalf]
          simp [loudWord, hb]
        · rw [sawStep_of_half_lt hhalf]
          exact ⟨by linarith, by linarith⟩
      · have hb' : b 0 = false := by simpa using hb
        refine ⟨p / 2, q / 2, by linarith, by linarith, by linarith, ?_⟩
        refine key _ _ (by linarith) (by linarith) (by linarith) ?_
        intro t ht
        obtain ⟨ht1, ht2⟩ := ht
        have hpos : 0 < t := by linarith
        have hhalf : t ≤ 1 / 2 := by linarith
        refine ⟨?_, ?_⟩
        · show cellOf (sawOrbit 0 t) = loudWord (L + 1) b 0
          rw [sawOrbit_zero, cellOf_of_low hpos hhalf]
          simp [loudWord, hb']
        · rw [sawStep_of_pos_le_half hpos hhalf]
          exact ⟨by linarith, by linarith⟩

lemma loudWord_isOpenCell (L : ℕ) (b : Fin L → Bool) : IsOpenCell L (loudWord L b) := by
  obtain ⟨p, q, _, hpq, _, hword⟩ := exists_open_interval_loud L b
  exact ⟨p, q, hpq, hword⟩

lemma loudWord_mem_loudRegions (L : ℕ) (b : Fin L → Bool) :
    loudWord L b ∈ loudRegions L := by
  classical
  refine Finset.mem_filter.mpr ⟨(loudWord_isOpenCell L b).mem_netRegions, ?_⟩
  exact loudWord_ne_empty b

/-- Every loud word is the word of its own itinerary. -/
lemma eq_loudWord_of_mem_loudRegions {L : ℕ} {q : Fin L → Finset (Fin 2)}
    (hq : q ∈ loudRegions L) : q = loudWord L (fun l => decide ((1 : Fin 2) ∈ q l)) := by
  classical
  rw [loudRegions, Finset.mem_filter, mem_netRegions_iff_sawWord] at hq
  obtain ⟨⟨t, rfl⟩, hloud⟩ := hq
  funext l
  have hne := hloud l
  rcases cellOf_cases (sawOrbit (l : ℕ) t) with h | h | h
  · exact absurd h hne
  · have h1 : (1 : Fin 2) ∉ sawWord L t l := by
      show (1 : Fin 2) ∉ cellOf (sawOrbit (l : ℕ) t)
      rw [h]; decide
    simp only [loudWord, decide_eq_true_eq, if_neg h1]
    exact h
  · have h1 : (1 : Fin 2) ∈ sawWord L t l := by
      show (1 : Fin 2) ∈ cellOf (sawOrbit (l : ℕ) t)
      rw [h]; decide
    simp only [loudWord, decide_eq_true_eq, if_pos h1]
    exact h

lemma loudRegions_subset_openRegions (L : ℕ) : loudRegions L ⊆ openRegions L := by
  intro q hq
  rw [mem_openRegions]
  rw [eq_loudWord_of_mem_loudRegions hq]
  exact loudWord_isOpenCell _ _

/-! ### The two extreme degenerate cells are open -/

lemma sawWord_of_neg {L : ℕ} {t : ℝ} (ht : t ≤ 0) : sawWord L t = fun _ => ∅ := by
  funext l
  exact cellOf_of_nonpos (sawOrbit_nonpos_mono (Nat.zero_le (l : ℕ)) (by simpa using ht))

lemma emptyWord_isOpenCell (M : ℕ) :
    IsOpenCell (M + 2) (degWord (M := M) (Sum.inl ())) := by
  refine ⟨-1, 0, by norm_num, ?_⟩
  intro t ht
  rw [sawWord_of_neg ht.2.le]
  rfl

lemma shutoffWord_isOpenCell (M : ℕ) :
    IsOpenCell (M + 2) (degWord (M := M) (Sum.inr (Sum.inl ()))) := by
  refine ⟨1, 2, by norm_num, ?_⟩
  intro t ht
  obtain ⟨ht1, _⟩ := ht
  have hhalf : 1 / 2 < t := by linarith
  have hstep : sawStep t ≤ 0 := by rw [sawStep_of_half_lt hhalf]; linarith
  funext l
  show cellOf (sawOrbit (l : ℕ) t) = _
  rcases Nat.eq_zero_or_pos (l : ℕ) with h | h
  · rw [h, sawOrbit_zero, cellOf_of_high hhalf]
    simp [degWord, h]
  · obtain ⟨k, hk⟩ : ∃ k, (l : ℕ) = k + 1 := ⟨(l : ℕ) - 1, by omega⟩
    have h1 : sawOrbit 1 t ≤ 0 := by rw [sawOrbit_succ, sawOrbit_zero]; exact hstep
    have : sawOrbit (l : ℕ) t ≤ 0 := sawOrbit_nonpos_mono (by omega) h1
    rw [cellOf_of_nonpos this]
    simp [degWord, hk]

/-! ### The remaining degenerate cells are single points -/

/-- On a degenerate cell of `Σ`-type the orbit is pinned: it equals `1/2` exactly
`j` steps in.  A layer can go silent only if the previous value was exactly `1`,
hence the one before that exactly `1/2`. -/
lemma sawOrbit_eq_half_of_sigma {M : ℕ} {j : Fin M} {b : Fin (j : ℕ) → Bool} {t : ℝ}
    (ht : sawWord (M + 2) t = degWord (M := M) (Sum.inr (Sum.inr ⟨j, b⟩))) :
    sawOrbit (j : ℕ) t = 1 / 2 := by
  have hj : (j : ℕ) < M := j.isLt
  have e0 : cellOf (sawOrbit (j : ℕ) t) = {0} :=
    (congrFun ht ⟨(j : ℕ), by omega⟩).trans (degWord_sigma_eq rfl)
  have e1 : cellOf (sawOrbit ((j : ℕ) + 1) t) = {0, 1} :=
    (congrFun ht ⟨(j : ℕ) + 1, by omega⟩).trans (degWord_sigma_succ rfl)
  have e2 : cellOf (sawOrbit ((j : ℕ) + 2) t) = ∅ :=
    (congrFun ht ⟨(j : ℕ) + 2, by omega⟩).trans (degWord_sigma_gt (by show (j : ℕ) + 1 < (j : ℕ) + 2; omega))
  obtain ⟨hu0, hu1⟩ := cellOf_eq_singleton_iff.mp e0
  have hstep1 : sawOrbit ((j : ℕ) + 1) t = 2 * sawOrbit (j : ℕ) t := by
    rw [sawOrbit_succ, sawStep_of_pos_le_half hu0 hu1]
  have hgt : 1 / 2 < 2 * sawOrbit (j : ℕ) t := by
    rw [← hstep1]; exact cellOf_eq_pair_iff.mp e1
  have hstep2 : sawOrbit ((j : ℕ) + 2) t = 2 - 4 * sawOrbit (j : ℕ) t := by
    rw [show (j : ℕ) + 2 = ((j : ℕ) + 1) + 1 from rfl, sawOrbit_succ, hstep1,
      sawStep_of_half_lt hgt]
    ring
  have hle : sawOrbit ((j : ℕ) + 2) t ≤ 0 := cellOf_eq_empty_iff.mp e2
  rw [hstep2] at hle
  linarith

/-- **The `Σ`-type degenerate cells are single points.**  Hence they are exactly
the cells that no sampling scheme can see. -/
theorem sigma_degenerate_singleton {M : ℕ} {j : Fin M} {b : Fin (j : ℕ) → Bool} {t t' : ℝ}
    (ht : sawWord (M + 2) t = degWord (M := M) (Sum.inr (Sum.inr ⟨j, b⟩)))
    (ht' : sawWord (M + 2) t' = degWord (M := M) (Sum.inr (Sum.inr ⟨j, b⟩))) :
    t = t' := by
  have hj : (j : ℕ) < M := j.isLt
  have hpref : ∀ l, l < (j : ℕ) → cellOf (sawOrbit l t) = cellOf (sawOrbit l t') ∧
      cellOf (sawOrbit l t) ≠ ∅ := by
    intro l hl
    have hlt : l < M + 2 := by omega
    have h1 : cellOf (sawOrbit l t)
        = degWord (M := M) (Sum.inr (Sum.inr ⟨j, b⟩)) ⟨l, hlt⟩ := congrFun ht ⟨l, hlt⟩
    have h2 : cellOf (sawOrbit l t')
        = degWord (M := M) (Sum.inr (Sum.inr ⟨j, b⟩)) ⟨l, hlt⟩ := congrFun ht' ⟨l, hlt⟩
    refine ⟨h1.trans h2.symm, ?_⟩
    rw [h1, degWord_sigma_lt (l := ⟨l, hlt⟩) hl]
    by_cases hb : b ⟨l, hl⟩ <;> simp [hb]
  have hexp := abs_sub_sawOrbit_eq (t := t) (t' := t') (j : ℕ) hpref
  rw [sawOrbit_eq_half_of_sigma ht, sawOrbit_eq_half_of_sigma ht'] at hexp
  simp only [sub_self, abs_zero] at hexp
  have hpow : (0 : ℝ) < 2 ^ (j : ℕ) := by positivity
  have : |t - t'| = 0 := by
    rcases mul_eq_zero.mp hexp.symm with h | h
    · exact absurd h (ne_of_gt hpow)
    · exact h
  have := abs_eq_zero.mp this
  linarith

lemma sigma_not_isOpenCell {M : ℕ} (j : Fin M) (b : Fin (j : ℕ) → Bool) :
    ¬ IsOpenCell (M + 2) (degWord (M := M) (Sum.inr (Sum.inr ⟨j, b⟩))) := by
  rintro ⟨p, q, hpq, hw⟩
  have h1 := hw ((2 * p + q) / 3) ⟨by linarith, by linarith⟩
  have h2 := hw ((p + 2 * q) / 3) ⟨by linarith, by linarith⟩
  have := sigma_degenerate_singleton h1 h2
  linarith

/-! ### The exact generic count -/

lemma openRegions_eq (M : ℕ) :
    openRegions (M + 2)
      = loudRegions (M + 2) ∪
          {degWord (M := M) (Sum.inl ()), degWord (M := M) (Sum.inr (Sum.inl ()))} := by
  classical
  ext q
  constructor
  · intro hq
    have hopen : IsOpenCell (M + 2) q := mem_openRegions.mp hq
    by_cases hloud : ∀ l, q l ≠ ∅
    · exact Finset.mem_union_left _ (Finset.mem_filter.mpr ⟨hopen.mem_netRegions, hloud⟩)
    · have hdeg : q ∈ degenRegions (M + 2) :=
        Finset.mem_filter.mpr ⟨hopen.mem_netRegions, hloud⟩
      obtain ⟨c, hc⟩ := exists_code_of_mem_degenRegions hdeg
      match c with
      | Sum.inl () => exact Finset.mem_union_right _ (by simp [← hc])
      | Sum.inr (Sum.inl ()) => exact Finset.mem_union_right _ (by simp [← hc])
      | Sum.inr (Sum.inr ⟨j, b⟩) =>
          exact absurd (hc ▸ hopen) (sigma_not_isOpenCell j b)
  · intro hq
    rcases Finset.mem_union.mp hq with h | h
    · exact loudRegions_subset_openRegions _ h
    · rcases Finset.mem_insert.mp h with h | h
      · rw [mem_openRegions, h]; exact emptyWord_isOpenCell M
      · rw [Finset.mem_singleton] at h
        rw [mem_openRegions, h]; exact shutoffWord_isOpenCell M

lemma emptyWord_ne_shutoffWord (M : ℕ) :
    degWord (M := M) (Sum.inl ()) ≠ degWord (M := M) (Sum.inr (Sum.inl ())) := by
  intro h
  have := congrFun h ⟨0, by omega⟩
  simp [degWord] at this
  exact pair_ne_empty this.symm

lemma emptyWord_not_loud (M : ℕ) :
    degWord (M := M) (Sum.inl ()) ∉ loudRegions (M + 2) := by
  classical
  intro h
  have := (Finset.mem_filter.mp h).2 ⟨0, by omega⟩
  simp [degWord] at this

lemma shutoffWord_not_loud (M : ℕ) :
    degWord (M := M) (Sum.inr (Sum.inl ())) ∉ loudRegions (M + 2) := by
  classical
  intro h
  have := (Finset.mem_filter.mp h).2 ⟨1, by omega⟩
  simp [degWord] at this

/-- **Exact generic cell count.**  The depth-`(M+2)` sawtooth network has exactly
`2 ^ (M+2) + 2` cells with nonempty interior: the `2 ^ (M+2)` tent itineraries,
plus the two unbounded cells `t < 0` and `t > 1`.  All remaining cells of the
pointwise partition are single points. -/
theorem card_openRegions_sawNet (M : ℕ) :
    (openRegions (M + 2)).card = 2 ^ (M + 2) + 2 := by
  classical
  rw [openRegions_eq M]
  rw [Finset.card_union_of_disjoint]
  · rw [card_loudRegions_sawNet, Finset.card_insert_of_notMem (by
      simpa using emptyWord_ne_shutoffWord M), Finset.card_singleton]
  · rw [Finset.disjoint_right]
    intro a ha
    rcases Finset.mem_insert.mp ha with h | h
    · rw [h]; exact emptyWord_not_loud M
    · rw [Finset.mem_singleton.mp h]; exact shutoffWord_not_loud M

/-- The generic count in the original variable. -/
theorem card_openRegions_sawNet' {L : ℕ} (hL : 2 ≤ L) :
    (openRegions L).card = 2 ^ L + 2 := by
  obtain ⟨M, rfl⟩ : ∃ M, L = M + 2 := ⟨L - 2, by omega⟩
  exact card_openRegions_sawNet M

/-- At depth `2` the pointwise and the generic partitions coincide: every cell of
the depth-`2` sawtooth is generic. -/
theorem card_openRegions_eq_card_netRegions_two :
    (openRegions 2).card = (sawNet.netRegions 2).card := by
  rw [card_openRegions_sawNet 0, card_netRegions_sawNet_exact 0]
  norm_num

/-- **The sampling gap.**  From depth `3` on, the pointwise cell count strictly
exceeds the generic one: invisible single-point cells really do appear. -/
theorem card_openRegions_lt_card_netRegions {M : ℕ} (hM : 1 ≤ M) :
    (openRegions (M + 2)).card < (sawNet.netRegions (M + 2)).card := by
  rw [card_openRegions_sawNet M, card_netRegions_sawNet_exact M]
  have h1 : (2 : ℕ) ^ (M + 2) = 4 * 2 ^ M := by ring
  have h2 : (2 : ℕ) ^ 1 ≤ 2 ^ M := Nat.pow_le_pow_right (by norm_num) hM
  rw [h1]
  omega

/-- **Asymptotic discrepancy.**  The ratio between the pointwise and the generic
cell counts tends to `5/4`: a quarter of the pointwise cells, in the limit, is
invisible to sampling. -/
theorem tendsto_pointwise_div_open :
    Filter.Tendsto
      (fun M : ℕ =>
        ((sawNet.netRegions (M + 2)).card : ℝ) / ((openRegions (M + 2)).card : ℝ))
      Filter.atTop (nhds (5 / 4)) := by
  have hrew : ∀ M : ℕ,
      ((sawNet.netRegions (M + 2)).card : ℝ) / ((openRegions (M + 2)).card : ℝ)
        = (5 + (1 / 2 : ℝ) ^ M) / (4 + 2 * (1 / 2 : ℝ) ^ M) := by
    intro M
    rw [card_netRegions_sawNet_exact M, card_openRegions_sawNet M]
    have hpow : (0 : ℝ) < 2 ^ M := by positivity
    have hhalf : ((1 : ℝ) / 2) ^ M = 1 / 2 ^ M := by
      rw [div_pow, one_pow]
    push_cast
    rw [hhalf, show (2 : ℝ) ^ (M + 2) = 4 * 2 ^ M by ring]
    field_simp
  simp only [hrew]
  have hzero : Filter.Tendsto (fun M : ℕ => (1 / 2 : ℝ) ^ M) Filter.atTop (nhds 0) :=
    tendsto_pow_atTop_nhds_zero_of_lt_one (by norm_num) (by norm_num)
  have hnum : Filter.Tendsto (fun M : ℕ => 5 + (1 / 2 : ℝ) ^ M) Filter.atTop (nhds 5) := by
    simpa using tendsto_const_nhds.add hzero
  have hden : Filter.Tendsto (fun M : ℕ => 4 + 2 * (1 / 2 : ℝ) ^ M) Filter.atTop (nhds 4) := by
    simpa using tendsto_const_nhds.add (hzero.const_mul (2 : ℝ))
  exact hnum.div hden (by norm_num)

/-! ### Axiom audit -/

#print axioms card_openRegions_sawNet
#print axioms sigma_degenerate_singleton
#print axioms card_openRegions_lt_card_netRegions
#print axioms tendsto_pointwise_div_open

end ReLUPartition