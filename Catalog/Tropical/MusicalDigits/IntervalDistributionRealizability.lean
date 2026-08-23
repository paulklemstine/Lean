import Mathlib
import Tropical.MusicalDigits.IntervalDistribution

/-!
# Every admissible interval distribution is realized by a decimal melody

The support theorem of `Tropical.MusicalDigits.IntervalDistribution` says that a decimal
melody can only realize interval values in `{0, …, 9}`.  This file proves the exact
converse — a complete inverse theorem for the pitch-interval statistic:

**`exists_melody_with_intervalDistribution`.**  For every prescribed multiplicity function
`N : ℕ → ℕ` on `{0, …, 9}` with total mass `n`, there is a decimal melody whose lag-1
interval distribution on the window of length `n` is exactly `N`.

Hence the support bound `v ≤ 9` is the *only* constraint: no other feature of an observed
interval histogram can be evidence for or against any property of the underlying number.
The construction is a two-step tropical/combinatorial device:

* a *layer-cake* sequence `layerSeq N` (`layerSeq_count`), the non-increasing rearrangement
  of the prescribed interval values, obtained by counting how many upper level sets of the
  tail mass a position pierces;
* an *alternating walk* `walk v` (`walk_dist`) that turns any non-increasing sequence of
  interval demands `v` with `v 0 ≤ 9` into an actual melody realizing them, using that the
  alternating partial sums of a non-increasing sequence stay inside `[0, v 0]`.

Combined with `interval_spectrum_iff` this closes the inverse problem for a single lag.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): the interval histogram carries no information beyond its
support; every histogram with the right total mass should be realizable.

Experiment (Experimenter): naive greedy realization fails — from note `4` the demand `9`
is unrealizable in either direction. Sorting the demands in non-increasing order repairs
this: the alternating walk then stays in `[0, v 0] ⊆ [0, 9]`, an invariant proved by a
two-case parity induction.

Analysis (Analyst): the layer-cake formula `v t = #{w ∈ [1,9] : t < tailMass N w}` turns
"sort the multiset" into a closed formula, so the counting argument becomes the identity
`#{t < n : v t ≥ w} = tailMass N w` plus a telescoping difference.

Critique (Critic): the theorem is stated for lag 1; longer lags follow by interleaving but
are not claimed here. The hypothesis `∑_{v<10} N v = n` is necessary, since the total mass
of the distribution is the window length.
-/

namespace TropicalMusicalDigits

open Finset

/-! ### The alternating walk realizing non-increasing interval demands -/

/-- The alternating walk: starting at pitch `0`, it goes up by `v t` at even times and
down by `v t` at odd times. -/
def walk (v : ℕ → ℕ) : ℕ → ℕ
  | 0 => 0
  | (t + 1) => if t % 2 = 0 then walk v t + v t else walk v t - v t

/-- Parity invariant: at even times the walk still has room to move up by `v t`, at odd
times it has room to move down by `v t`, and it never leaves `[0, v 0]`. -/
lemma walk_invariant (v : ℕ → ℕ) (hmono : ∀ s t, s ≤ t → v t ≤ v s) (t : ℕ) :
    (t % 2 = 0 → walk v t + v t ≤ v 0) ∧ (t % 2 = 1 → v t ≤ walk v t ∧ walk v t ≤ v 0) := by
  induction t with
  | zero => exact ⟨fun _ => by simp [walk], fun h => by simp at h⟩
  | succ n ih =>
    rcases Nat.even_or_odd n with he | ho
    · have hn : n % 2 = 0 := Nat.even_iff.1 he
      have h1 := ih.1 hn
      refine ⟨fun h => by omega, fun _ => ?_⟩
      have hw : walk v (n + 1) = walk v n + v n := by simp [walk, hn]
      have := hmono n (n + 1) (by omega)
      omega
    · have hn : n % 2 = 1 := Nat.odd_iff.1 ho
      obtain ⟨h1, h2⟩ := ih.2 hn
      have hw : walk v (n + 1) = walk v n - v n := by simp [walk, hn]
      have := hmono n (n + 1) (by omega)
      exact ⟨fun _ => by omega, fun h => by omega⟩

/-- The walk stays inside the pitch range `[0, v 0]`. -/
lemma walk_le (v : ℕ → ℕ) (hmono : ∀ s t, s ≤ t → v t ≤ v s) (t : ℕ) : walk v t ≤ v 0 := by
  have hinv := walk_invariant v hmono t
  rcases Nat.even_or_odd t with he | ho
  · have hn : t % 2 = 0 := Nat.even_iff.1 he
    have := hinv.1 hn; omega
  · exact (hinv.2 (Nat.odd_iff.1 ho)).2

/-- **The walk realizes the prescribed interval demands exactly.** -/
theorem walk_dist (v : ℕ → ℕ) (hmono : ∀ s t, s ≤ t → v t ≤ v s) (t : ℕ) :
    lagInterval (walk v) 1 t = v t := by
  have hinv := walk_invariant v hmono t
  simp only [lagInterval, interval]
  rcases Nat.even_or_odd t with he | ho
  · have hn : t % 2 = 0 := Nat.even_iff.1 he
    have hw : walk v (t + 1) = walk v t + v t := by simp [walk, hn]
    simp [Nat.dist, hw]
  · have hn : t % 2 = 1 := Nat.odd_iff.1 ho
    obtain ⟨h1, h2⟩ := hinv.2 hn
    have hw : walk v (t + 1) = walk v t - v t := by simp [walk, hn]
    simp only [Nat.dist, hw]
    omega

/-! ### The layer-cake rearrangement of a prescribed distribution -/

/-- The tail mass of the prescribed distribution above an interval value. -/
def tailMass (N : ℕ → ℕ) (w : ℕ) : ℕ := ∑ u ∈ Ico w 10, N u

/-- The non-increasing rearrangement of the prescribed interval values, written as a layer
cake: the value at time `t` is the number of levels whose tail mass exceeds `t`. -/
def layerSeq (N : ℕ → ℕ) (t : ℕ) : ℕ := ((Icc 1 9).filter fun w => t < tailMass N w).card

lemma tailMass_antitone (N : ℕ → ℕ) {w w' : ℕ} (h : w ≤ w') : tailMass N w' ≤ tailMass N w :=
  Finset.sum_le_sum_of_subset (Finset.Ico_subset_Ico h le_rfl)

lemma tailMass_succ (N : ℕ → ℕ) {w : ℕ} (hw : w < 10) :
    tailMass N w = N w + tailMass N (w + 1) :=
  Finset.sum_eq_sum_Ico_succ_bot hw N

lemma tailMass_ten (N : ℕ → ℕ) : tailMass N 10 = 0 := by simp [tailMass]

lemma tailMass_zero (N : ℕ → ℕ) : tailMass N 0 = ∑ u ∈ range 10, N u := by
  rw [tailMass, Finset.range_eq_Ico]

lemma layerSeq_le_nine (N : ℕ → ℕ) (t : ℕ) : layerSeq N t ≤ 9 := by
  have := Finset.card_filter_le (Icc 1 9) (fun w => t < tailMass N w)
  simpa using this

/-- The layer-cake sequence is non-increasing, as required by the alternating walk. -/
lemma layerSeq_antitone (N : ℕ → ℕ) {s t : ℕ} (h : s ≤ t) : layerSeq N t ≤ layerSeq N s := by
  apply Finset.card_le_card
  intro w hw
  simp only [mem_filter] at hw ⊢
  exact ⟨hw.1, by omega⟩

/-- Upper level sets of the layer-cake sequence are exactly the tail-mass intervals. -/
lemma layerSeq_ge_iff (N : ℕ → ℕ) (t : ℕ) {w : ℕ} (hw1 : 1 ≤ w) (hw9 : w ≤ 9) :
    w ≤ layerSeq N t ↔ t < tailMass N w := by
  constructor
  · intro h
    by_contra hcon
    push_neg at hcon
    have hsub : (Icc 1 9).filter (fun u => t < tailMass N u) ⊆ Icc 1 (w - 1) := by
      intro u hu
      simp only [mem_filter, mem_Icc] at hu ⊢
      refine ⟨hu.1.1, ?_⟩
      by_contra hge
      push_neg at hge
      have : tailMass N u ≤ tailMass N w := tailMass_antitone N (by omega)
      omega
    have hcard := Finset.card_le_card hsub
    rw [Nat.card_Icc] at hcard
    unfold layerSeq at h
    omega
  · intro h
    have hsub : Icc 1 w ⊆ (Icc 1 9).filter (fun u => t < tailMass N u) := by
      intro u hu
      simp only [mem_Icc] at hu
      simp only [mem_filter, mem_Icc]
      refine ⟨⟨hu.1, by omega⟩, ?_⟩
      have : tailMass N w ≤ tailMass N u := tailMass_antitone N hu.2
      omega
    have hcard := Finset.card_le_card hsub
    rw [Nat.card_Icc] at hcard
    unfold layerSeq
    omega

/-- Counting the positions above a level: exactly the tail mass. -/
lemma card_layerSeq_ge (N : ℕ → ℕ) (n : ℕ) {w : ℕ} (hw1 : 1 ≤ w) (hw9 : w ≤ 9)
    (hle : tailMass N w ≤ n) :
    ((range n).filter fun t => w ≤ layerSeq N t).card = tailMass N w := by
  have hset : (range n).filter (fun t => w ≤ layerSeq N t) = range (tailMass N w) := by
    ext t
    simp only [mem_filter, mem_range]
    rw [layerSeq_ge_iff N t hw1 hw9]
    omega
  rw [hset, card_range]

/-- Splitting an upper level set into the next one and the exact fibre. -/
lemma card_split (N : ℕ → ℕ) (n w : ℕ) :
    ((range n).filter fun t => w ≤ layerSeq N t).card
      = ((range n).filter fun t => w + 1 ≤ layerSeq N t).card
        + ((range n).filter fun t => layerSeq N t = w).card := by
  classical
  have hset : (range n).filter (fun t => w ≤ layerSeq N t)
      = ((range n).filter fun t => w + 1 ≤ layerSeq N t)
        ∪ ((range n).filter fun t => layerSeq N t = w) := by
    ext t
    simp only [mem_union, mem_filter, mem_range]
    omega
  have hdisj : Disjoint ((range n).filter fun t => w + 1 ≤ layerSeq N t)
      ((range n).filter fun t => layerSeq N t = w) := by
    rw [disjoint_left]
    intro t h1 h2
    simp only [mem_filter] at h1 h2
    omega
  rw [hset, card_union_of_disjoint hdisj]

/-- **The layer-cake sequence realizes the prescribed distribution.** -/
theorem layerSeq_count (N : ℕ → ℕ) (n : ℕ) (hmass : ∑ v ∈ range 10, N v = n) (w : ℕ)
    (hw : w < 10) :
    ((range n).filter fun t => layerSeq N t = w).card = N w := by
  have htail0 : tailMass N 0 = n := by rw [tailMass_zero, hmass]
  have hle : ∀ u, tailMass N u ≤ n := fun u => htail0 ▸ tailMass_antitone N (Nat.zero_le u)
  have hsucc : tailMass N w = N w + tailMass N (w + 1) := tailMass_succ N hw
  rcases Nat.eq_zero_or_pos w with rfl | hw1
  · -- level zero: complement of the first upper level set
    have h1 : ((range n).filter fun t => 1 ≤ layerSeq N t).card = tailMass N 1 :=
      card_layerSeq_ge N n (by norm_num) (by norm_num) (hle 1)
    have hsplit := card_split N n 0
    have h0 : ((range n).filter fun t => 0 ≤ layerSeq N t).card = n := by
      simp
    rw [h0, h1] at hsplit
    have : tailMass N 0 = N 0 + tailMass N 1 := tailMass_succ N (by norm_num)
    omega
  · by_cases hw9 : w ≤ 8
    · have hge := card_layerSeq_ge N n hw1 (by omega) (hle w)
      have hge1 := card_layerSeq_ge N n (by omega : 1 ≤ w + 1) (by omega) (hle (w + 1))
      have hsplit := card_split N n w
      rw [hge, hge1] at hsplit
      omega
    · -- the top level `w = 9`
      have hw9' : w = 9 := by omega
      subst hw9'
      have hge := card_layerSeq_ge N n (by norm_num) (by norm_num) (hle 9)
      have hempty : ((range n).filter fun t => 10 ≤ layerSeq N t).card = 0 := by
        simp only [card_eq_zero, filter_eq_empty_iff]
        intro t _
        have := layerSeq_le_nine N t
        omega
      have hsplit := card_split N n 9
      rw [hge, hempty] at hsplit
      have h10 : tailMass N 10 = 0 := tailMass_ten N
      norm_num at hsucc
      omega

/-! ### The inverse theorem -/

/-- **Inverse theorem for pitch-interval distributions.**  Every multiplicity function on
the admissible interval values `{0, …, 9}` with total mass `n` is the lag-1 interval
distribution of some decimal melody on the window of length `n`.  Together with the
support theorem this characterizes exactly which interval histograms can occur, and shows
that a histogram alone constrains nothing beyond its support. -/
theorem exists_melody_with_intervalDistribution (N : ℕ → ℕ) (n : ℕ)
    (hmass : ∑ v ∈ range 10, N v = n) :
    ∃ x : ℕ → ℕ, IsDigitMelody 10 x ∧ ∀ w ∈ range 10, intervalCount x n 1 w = N w := by
  refine ⟨walk (layerSeq N), ?_, ?_⟩
  · intro i
    have h := walk_le (layerSeq N) (fun s t hst => layerSeq_antitone N hst) i
    have := layerSeq_le_nine N 0
    omega
  · intro w hw
    have hmono : ∀ s t, s ≤ t → layerSeq N t ≤ layerSeq N s := fun s t hst =>
      layerSeq_antitone N hst
    have hfilter : ((range n).filter fun t => lagInterval (walk (layerSeq N)) 1 t = w)
        = ((range n).filter fun t => layerSeq N t = w) := by
      apply filter_congr
      intro t _
      rw [walk_dist (layerSeq N) hmono t]
    rw [intervalCount, hfilter]
    exact layerSeq_count N n hmass w (mem_range.1 hw)

/-- A concrete instance of the inverse theorem at the interval value that the octave claim
concerns: there is a decimal melody realizing, in a window of ten position pairs, one
unison and nine intervals of nine semitones each — yet still no octave. -/
theorem exists_melody_extreme_histogram :
    ∃ x : ℕ → ℕ, IsDigitMelody 10 x ∧
      intervalCount x 10 1 0 = 1 ∧ intervalCount x 10 1 9 = 9 ∧ intervalCount x 10 1 12 = 0 := by
  classical
  set N : ℕ → ℕ := fun w => if w = 0 then 1 else if w = 9 then 9 else 0 with hN
  have hmass : ∑ v ∈ range 10, N v = 10 := by decide
  obtain ⟨x, hx, hcount⟩ := exists_melody_with_intervalDistribution N 10 hmass
  refine ⟨x, hx, ?_, ?_, decimal_octave_count_eq_zero hx 10 1⟩
  · have := hcount 0 (by norm_num); simpa [hN] using this
  · have := hcount 9 (by norm_num); simpa [hN] using this

/-! ### Every lag realizes every distribution, up to the interleaving multiplicity -/

/-- The `ℓ`-fold interleaving of a melody: `ℓ` independent voices, each moving one step
per `ℓ` time units. -/
def interleave (z : ℕ → ℕ) (l : ℕ) : ℕ → ℕ := fun i => z (i / l)

/-- A window of length `ℓ m` decomposes into `m` consecutive blocks of length `ℓ`. -/
lemma card_filter_range_mul (l m : ℕ) (hl : 0 < l) (P : ℕ → Prop) [DecidablePred P] :
    ((range (l * m)).filter P).card
      = ∑ t ∈ range m, ((Ico (l * t) (l * t + l)).filter P).card := by
  classical
  have hcover : range (l * m) = (range m).biUnion (fun t => Ico (l * t) (l * t + l)) := by
    ext i
    simp only [mem_range, mem_biUnion, mem_Ico]
    constructor
    · intro hi
      have hdm := Nat.div_add_mod i l
      have hmod := Nat.mod_lt i hl
      exact ⟨i / l, Nat.div_lt_of_lt_mul (by omega), by omega, by omega⟩
    · rintro ⟨t, ht, h1, h2⟩
      calc i < l * t + l := h2
        _ = l * (t + 1) := by ring
        _ ≤ l * m := Nat.mul_le_mul_left l (by omega)
  have hdisj : ∀ s ∈ range m, ∀ t ∈ range m, s ≠ t →
      Disjoint (Ico (l * s) (l * s + l)) (Ico (l * t) (l * t + l)) := by
    intro s _ t _ hst
    rw [Finset.disjoint_left]
    intro i h1 h2
    simp only [mem_Ico] at h1 h2
    rcases lt_or_gt_of_ne hst with h | h
    · have : l * s + l ≤ l * t := by
        calc l * s + l = l * (s + 1) := by ring
          _ ≤ l * t := Nat.mul_le_mul_left l (by omega)
      omega
    · have : l * t + l ≤ l * s := by
        calc l * t + l = l * (t + 1) := by ring
          _ ≤ l * s := Nat.mul_le_mul_left l (by omega)
      omega
  rw [hcover, filter_biUnion, card_biUnion]
  intro s hs t ht hst
  exact Finset.disjoint_filter_filter (hdisj s hs t ht hst)

/-- Interleaving converts lag-1 intervals of the underlying voice into lag-`ℓ` intervals of
the interleaved melody. -/
lemma interleave_lagInterval (z : ℕ → ℕ) {l : ℕ} (hl : 0 < l) (i : ℕ) :
    lagInterval (interleave z l) l i = lagInterval z 1 (i / l) := by
  simp [lagInterval, interval, interleave, Nat.add_div_right i hl]

/-- **Distributional decoupling at every lag.**  For every lag `ℓ ≥ 1` and every prescribed
distribution `N` of total mass `m`, some decimal melody has lag-`ℓ` interval distribution
exactly `ℓ · N` on the window of length `ℓ m`.  Lag twelve is a special case: the temporal
parameter constrains nothing about the pitch histogram beyond its support. -/
theorem exists_melody_with_intervalDistribution_at_lag (N : ℕ → ℕ) (m l : ℕ) (hl : 0 < l)
    (hmass : ∑ v ∈ range 10, N v = m) :
    ∃ x : ℕ → ℕ, IsDigitMelody 10 x ∧ ∀ w ∈ range 10, intervalCount x (l * m) l w = l * N w := by
  classical
  have hmono : ∀ s t, s ≤ t → layerSeq N t ≤ layerSeq N s := fun s t hst =>
    layerSeq_antitone N hst
  refine ⟨interleave (walk (layerSeq N)) l, ?_, ?_⟩
  · intro i
    have h := walk_le (layerSeq N) hmono (i / l)
    have := layerSeq_le_nine N 0
    simp only [interleave]
    omega
  · intro w hw
    have hblock : ∀ t ∈ range m,
        ((Ico (l * t) (l * t + l)).filter
            fun i => lagInterval (interleave (walk (layerSeq N)) l) l i = w).card
          = if lagInterval (walk (layerSeq N)) 1 t = w then l else 0 := by
      intro t _
      have hdiv : ∀ i ∈ Ico (l * t) (l * t + l), i / l = t := by
        intro i hi
        simp only [mem_Ico] at hi
        have hdm := Nat.div_add_mod i l
        have hmod := Nat.mod_lt i hl
        have hqt : i / l = t := by
          rcases Nat.lt_trichotomy (i / l) t with hlt | heq | hgt
          · have : l * (i / l) + l ≤ l * t := by
              calc l * (i / l) + l = l * (i / l + 1) := by ring
                _ ≤ l * t := Nat.mul_le_mul_left l (by omega)
            omega
          · exact heq
          · have : l * t + l ≤ l * (i / l) := by
              calc l * t + l = l * (t + 1) := by ring
                _ ≤ l * (i / l) := Nat.mul_le_mul_left l (by omega)
            omega
        exact hqt
      have hfil : ((Ico (l * t) (l * t + l)).filter
          fun i => lagInterval (interleave (walk (layerSeq N)) l) l i = w)
          = (Ico (l * t) (l * t + l)).filter
            fun _ => lagInterval (walk (layerSeq N)) 1 t = w := by
        apply filter_congr
        intro i hi
        rw [interleave_lagInterval _ hl i, hdiv i hi]
      rw [hfil]
      by_cases hc : lagInterval (walk (layerSeq N)) 1 t = w
      · simp [hc, Nat.card_Ico]
      · simp [hc]
    rw [intervalCount, card_filter_range_mul l m hl, Finset.sum_congr rfl hblock,
      ← Finset.sum_filter]
    have hcount : ((range m).filter fun t => lagInterval (walk (layerSeq N)) 1 t = w).card
        = N w := by
      have hfil : ((range m).filter fun t => lagInterval (walk (layerSeq N)) 1 t = w)
          = ((range m).filter fun t => layerSeq N t = w) := by
        apply filter_congr
        intro t _
        rw [walk_dist (layerSeq N) hmono t]
      rw [hfil]
      exact layerSeq_count N m hmass w (mem_range.1 hw)
    rw [Finset.sum_const, hcount, smul_eq_mul, mul_comm]

end TropicalMusicalDigits