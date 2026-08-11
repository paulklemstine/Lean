/-
# Submultiplicativity of grid crossings across a horizontal cut

This file proves the structural form of the decay conjecture that survived the
adversarial stage of this cycle: the naive doubling bound `θ_{2n}(p) ≤ θ_n(p)²`
is false (`crossing_sq_one_lt_two` in
`Catalog/Logic/CrossingRowBKBound.lean`), because a top-to-bottom crossing of a
grid splits not into two crossings of smaller *grids* but into two crossings of
the two *bands* separated by a horizontal cut.  Here that splitting is
formalized and combined with the van den Berg–Kesten inequality:

`P(band [a,b] crossed) ≤ P(band [a,k] crossed) · P(band [k+1,b] crossed)`

for every interior cut level `k`, and in particular
`θ_n(p) ≤ P_p(low band crossed) · P_p(high band crossed)`.

The geometric input is that a grid walk changes its row index by at most one at
each step, so a walk from row `0` to row `n-1` has an initial segment that stays
in the rows `≤ k` and ends on row `k` (`gridWalk_prefix_below`), and a final
segment that stays in the rows `> k` and starts on row `k+1`
(`gridWalk_prefix_above`, applied to the reversed walk).  These two segments use
*disjoint* sets of open sites, which is exactly the hypothesis of the BK
inequality; Harris would give the inequality in the wrong direction.

## Main results

* `gridWalk_prefix_below`, `gridWalk_prefix_above`: extraction of the two
  segments of a crossing walk at a horizontal cut.
* `bandEvent`, `bandEvent_isIncreasing`: the band-crossing events.
* `crossingEvent_eq_bandEvent`: the crossing event is the full band.
* `bandEvent_subset_disjointOccur`: a band-crossing configuration realizes the
  two sub-band crossings *disjointly*.
* `bernProb_bandEvent_le_prod`, `crossing_bernProb_le_band_prod`: the resulting
  submultiplicativity, in the recursive form and for the grid crossing.
* `bandEvent_single_eq`, `bernProb_bandEvent_single`: a band of height one is a
  single row, crossed with probability `1 - (1-p)^n`.
* `bernProb_bandEvent_le_pow`, `crossing_bernProb_le_pow_via_bands`: iterating
  the cut one row at a time recovers the row bound `θ_n(p) ≤ (1 - (1-p)^n)^n`
  of `Catalog/Logic/CrossingRowBKBound.lean` from the band recursion.
* `crossing_two_le_band_prod_explicit`: the instance `n = 2`, `k = 0`, where the
  bound is the explicit polynomial inequality `2p² - p⁴ ≤ (2p - p²)²`.
-/

import Logic.CrossingRowBKBound

open Finset

namespace BernoulliThresholdCoupling

/-! ## Splitting a grid walk at a horizontal cut -/

/-- The initial segment of a grid walk that stays below the cut.  A walk that
starts at or below row `k` and ends strictly above it has an initial segment
ending exactly on row `k` and staying in the rows `≤ k`. -/
theorem gridWalk_prefix_below {n k : ℕ} :
    ∀ {a b : Fin n × Fin n} (w : (gridGraph n).Walk a b), a.1.val ≤ k → k < b.1.val →
      ∃ (y : Fin n × Fin n) (w' : (gridGraph n).Walk a y), y.1.val = k ∧
        ∀ x ∈ w'.support, x ∈ w.support ∧ x.1.val ≤ k := by
  intro a b w
  induction w with
  | nil => intro ha hb; exact absurd hb (by omega)
  | @cons a y b hadj q ih =>
    intro ha hb
    by_cases hy : y.1.val ≤ k
    · obtain ⟨z, w', hz, hsup⟩ := ih hy hb
      refine ⟨z, SimpleGraph.Walk.cons hadj w', hz, ?_⟩
      intro x hx
      rw [SimpleGraph.Walk.support_cons] at hx
      rcases List.mem_cons.mp hx with rfl | hx'
      · exact ⟨by simp, ha⟩
      · obtain ⟨h1, h2⟩ := hsup x hx'
        refine ⟨?_, h2⟩
        rw [SimpleGraph.Walk.support_cons]
        exact List.mem_cons_of_mem _ h1
    · push_neg at hy
      have hak : a.1.val = k := by
        rcases hadj with ⟨h1, -⟩ | ⟨-, h2⟩
        · have := congrArg Fin.val h1; omega
        · omega
      refine ⟨a, SimpleGraph.Walk.nil, hak, ?_⟩
      intro x hx
      simp only [SimpleGraph.Walk.support_nil, List.mem_singleton] at hx
      subst hx
      exact ⟨by simp, ha⟩

/-- The initial segment of a grid walk that stays above the cut.  A walk that
starts strictly above row `k` and ends at or below it has an initial segment
ending exactly on row `k+1` and staying in the rows `> k`. -/
theorem gridWalk_prefix_above {n k : ℕ} :
    ∀ {a b : Fin n × Fin n} (w : (gridGraph n).Walk a b), k < a.1.val → b.1.val ≤ k →
      ∃ (y : Fin n × Fin n) (w' : (gridGraph n).Walk a y), y.1.val = k + 1 ∧
        ∀ x ∈ w'.support, x ∈ w.support ∧ k < x.1.val := by
  intro a b w
  induction w with
  | nil => intro ha hb; exact absurd hb (by omega)
  | @cons a y b hadj q ih =>
    intro ha hb
    by_cases hy : k < y.1.val
    · obtain ⟨z, w', hz, hsup⟩ := ih hy hb
      refine ⟨z, SimpleGraph.Walk.cons hadj w', hz, ?_⟩
      intro x hx
      rw [SimpleGraph.Walk.support_cons] at hx
      rcases List.mem_cons.mp hx with rfl | hx'
      · exact ⟨by simp, ha⟩
      · obtain ⟨h1, h2⟩ := hsup x hx'
        refine ⟨?_, h2⟩
        rw [SimpleGraph.Walk.support_cons]
        exact List.mem_cons_of_mem _ h1
    · push_neg at hy
      have hak : a.1.val = k + 1 := by
        rcases hadj with ⟨h1, -⟩ | ⟨-, h2⟩
        · have := congrArg Fin.val h1; omega
        · omega
      refine ⟨a, SimpleGraph.Walk.nil, hak, ?_⟩
      intro x hx
      simp only [SimpleGraph.Walk.support_nil, List.mem_singleton] at hx
      subst hx
      exact ⟨by simp, ha⟩

/-! ## Band-crossing events -/

/-- The event that the band of rows `a ≤ r ≤ b` is crossed from row `a` to row
`b` using only open sites of that band. -/
def bandEvent (n a b : ℕ) : Set (Fin n × Fin n → Bool) :=
  {η | ∃ (x y : Fin n × Fin n) (w : (gridGraph n).Walk x y), x.1.val = a ∧ y.1.val = b ∧
    ∀ z ∈ w.support, η z = true ∧ a ≤ z.1.val ∧ z.1.val ≤ b}

theorem bandEvent_isIncreasing (n a b : ℕ) : IsIncreasing (bandEvent n a b) := by
  rintro η ξ hdom ⟨x, y, w, hx, hy, hw⟩
  exact ⟨x, y, w, hx, hy, fun z hz => ⟨hdom z (hw z hz).1, (hw z hz).2⟩⟩

/-- The sites of the band of rows `a ≤ r ≤ b`. -/
def bandSites (n a b : ℕ) : Finset (Fin n × Fin n) :=
  univ.filter (fun x => a ≤ x.1.val ∧ x.1.val ≤ b)

theorem bandSites_disjoint (n a k b : ℕ) :
    Disjoint (bandSites n a k) (bandSites n (k + 1) b) := by
  refine Finset.disjoint_left.mpr fun x hx hx' => ?_
  simp only [bandSites, mem_filter] at hx hx'
  omega

/-- The full band is the crossing event: a walk of the grid automatically stays
in the rows `0 ≤ r ≤ n - 1`. -/
theorem crossingEvent_eq_bandEvent (n : ℕ) (hn : 0 < n) :
    crossingEvent n hn = bandEvent n 0 (n - 1) := by
  ext η
  constructor
  · rintro ⟨α, β, w, hw⟩
    refine ⟨_, _, w, by simp, by simp, fun z hz => ⟨hw z hz, Nat.zero_le _, ?_⟩⟩
    have := z.1.isLt
    omega
  · rintro ⟨x, y, w, hx, hy, hw⟩
    have hx' : x = (⟨0, hn⟩, x.2) := Prod.ext (Fin.ext hx) rfl
    have hy' : y = (⟨n - 1, by omega⟩, y.2) := Prod.ext (Fin.ext hy) rfl
    refine ⟨x.2, y.2, ?_⟩
    rw [← hx', ← hy']
    exact ⟨w, fun z hz => (hw z hz).1⟩

/-! ## Splitting a band crossing at an interior cut -/

/-- **The geometric splitting.**  A configuration crossing the band `[a, b]`
realizes the crossings of the two sub-bands `[a, k]` and `[k+1, b]` on disjoint
sets of open sites. -/
theorem bandEvent_subset_disjointOccur (n a k b : ℕ) (hak : a ≤ k) (hkb : k < b) :
    bandEvent n a b ⊆ disjointOccur (bandEvent n a k) (bandEvent n (k + 1) b) := by
  rintro η ⟨x, y, w, hx, hy, hw⟩
  refine ⟨bandSites n a k, bandSites n (k + 1) b, bandSites_disjoint n a k b, ?_, ?_⟩
  · obtain ⟨z, w', hz, hsup⟩ :=
      gridWalk_prefix_below (k := k) w (by omega) (by omega)
    refine ⟨x, z, w', hx, hz, fun u hu => ⟨?_, (hw u (hsup u hu).1).2.1, (hsup u hu).2⟩⟩
    have hulow : u ∈ bandSites n a k := by
      simp only [bandSites, mem_filter, mem_univ, true_and]
      exact ⟨(hw u (hsup u hu).1).2.1, (hsup u hu).2⟩
    simp only [maskOn, if_pos hulow]
    exact (hw u (hsup u hu).1).1
  · obtain ⟨z, w', hz, hsup⟩ :=
      gridWalk_prefix_above (k := k) w.reverse (by omega) (by omega)
    have hsup' : ∀ u ∈ w'.support, u ∈ w.support ∧ k < u.1.val := by
      intro u hu
      obtain ⟨h1, h2⟩ := hsup u hu
      rw [SimpleGraph.Walk.support_reverse, List.mem_reverse] at h1
      exact ⟨h1, h2⟩
    refine ⟨z, y, w'.reverse, hz, hy, fun u hu => ?_⟩
    rw [SimpleGraph.Walk.support_reverse, List.mem_reverse] at hu
    obtain ⟨hmem, hrow⟩ := hsup' u hu
    have huhigh : u ∈ bandSites n (k + 1) b := by
      simp only [bandSites, mem_filter, mem_univ, true_and]
      exact ⟨by omega, (hw u hmem).2.2⟩
    refine ⟨?_, by omega, (hw u hmem).2.2⟩
    simp only [maskOn, if_pos huhigh]
    exact (hw u hmem).1

/-- **Submultiplicativity of band crossings.**  Cutting a band at any interior
level multiplies the bound: `P(band [a,b]) ≤ P(band [a,k]) · P(band [k+1,b])`.
This is the van den Berg–Kesten inequality applied to the geometric splitting;
the Harris inequality gives the opposite bound and is useless here. -/
theorem bernProb_bandEvent_le_prod (n a k b : ℕ) (hak : a ≤ k) (hkb : k < b)
    {p : ℝ} (hp0 : 0 ≤ p) (hp1 : p ≤ 1) :
    bernProb p (bandEvent n a b) ≤
      bernProb p (bandEvent n a k) * bernProb p (bandEvent n (k + 1) b) := by
  refine le_trans (bernProb_mono_subset hp0 hp1
    (bandEvent_subset_disjointOccur n a k b hak hkb)) ?_
  exact bernProb_bk hp0 hp1 (bandEvent_isIncreasing n a k) (bandEvent_isIncreasing n (k + 1) b)

/-- **Submultiplicativity of the crossing probability across a horizontal
cut.**  For every cut level `k < n - 1` the crossing probability of the `n × n`
grid is at most the product of the two band-crossing probabilities. -/
theorem crossing_bernProb_le_band_prod (n k : ℕ) (hn : 0 < n) (hk : k < n - 1)
    {p : ℝ} (hp0 : 0 ≤ p) (hp1 : p ≤ 1) :
    bernProb p (crossingEvent n hn) ≤
      bernProb p (bandEvent n 0 k) * bernProb p (bandEvent n (k + 1) (n - 1)) := by
  rw [crossingEvent_eq_bandEvent n hn]
  exact bernProb_bandEvent_le_prod n 0 k (n - 1) (Nat.zero_le _) hk hp0 hp1

/-! ## Degenerate bands are single rows -/

/-- A band of height one is a single row: crossing it just means having an open
site in that row. -/
theorem bandEvent_single_eq (n a : ℕ) (ha : a < n) :
    bandEvent n a a = someOpenEvent (gridRow n ⟨a, ha⟩) := by
  ext η
  constructor
  · rintro ⟨x, y, w, hx, -, hw⟩
    exact ⟨x, mem_gridRow.mpr (Fin.ext hx), (hw x w.start_mem_support).1⟩
  · rintro ⟨v, hv, hvo⟩
    have hva : v.1.val = a := by rw [mem_gridRow] at hv; rw [hv]
    refine ⟨v, v, SimpleGraph.Walk.nil, hva, hva, fun z hz => ?_⟩
    simp only [SimpleGraph.Walk.support_nil, List.mem_singleton] at hz
    subst hz
    exact ⟨hvo, by omega, by omega⟩

/-- A single-row band is crossed with probability `1 - (1-p)^n`. -/
theorem bernProb_bandEvent_single (n a : ℕ) (ha : a < n) (p : ℝ) :
    bernProb p (bandEvent n a a) = 1 - (1 - p) ^ n := by
  rw [bandEvent_single_eq n a ha, bernProb_someOpenEvent, card_gridRow]

/-! ## Iterating the cut -/

/-- **The iterated band bound.**  Cutting a band into its single rows and
applying the submultiplicativity at each cut gives
`P(band [a,b]) ≤ (1 - (1-p)^n)^{b-a+1}`. -/
theorem bernProb_bandEvent_le_pow (n a : ℕ) {p : ℝ} (hp0 : 0 ≤ p) (hp1 : p ≤ 1) :
    ∀ b, a ≤ b → b < n → bernProb p (bandEvent n a b) ≤ (1 - (1 - p) ^ n) ^ (b - a + 1) := by
  have hnn : (0 : ℝ) ≤ 1 - (1 - p) ^ n := by
    have : (1 - p) ^ n ≤ 1 := pow_le_one₀ (by linarith) (by linarith)
    linarith
  intro b hab
  induction b, hab using Nat.le_induction with
  | base =>
    intro ha
    rw [bernProb_bandEvent_single n a ha]
    simp
  | succ b hab ih =>
    intro hb1
    have hih := ih (by omega)
    calc bernProb p (bandEvent n a (b + 1))
        ≤ bernProb p (bandEvent n a b) * bernProb p (bandEvent n (b + 1) (b + 1)) :=
          bernProb_bandEvent_le_prod n a b (b + 1) hab (by omega) hp0 hp1
      _ = bernProb p (bandEvent n a b) * (1 - (1 - p) ^ n) := by
          rw [bernProb_bandEvent_single n (b + 1) hb1]
      _ ≤ (1 - (1 - p) ^ n) ^ (b - a + 1) * (1 - (1 - p) ^ n) :=
          mul_le_mul_of_nonneg_right hih hnn
      _ = (1 - (1 - p) ^ n) ^ (b + 1 - a + 1) := by
          rw [← pow_succ]
          congr 1
          omega

/-- The row bound `θ_n(p) ≤ (1 - (1-p)^n)^n` of
`Catalog/Logic/CrossingRowBKBound.lean`, re-derived from the band recursion by
cutting the grid one row at a time. -/
theorem crossing_bernProb_le_pow_via_bands (n : ℕ) (hn : 0 < n) {p : ℝ} (hp0 : 0 ≤ p)
    (hp1 : p ≤ 1) :
    bernProb p (crossingEvent n hn) ≤ (1 - (1 - p) ^ n) ^ n := by
  rw [crossingEvent_eq_bandEvent n hn]
  have h := bernProb_bandEvent_le_pow n 0 hp0 hp1 (n - 1) (Nat.zero_le _) (by omega)
  rwa [show n - 1 - 0 + 1 = n by omega] at h

/-! ## The smallest instance -/

/-- On the `2 × 2` grid the cut at level `0` splits the crossing into the two
row events. -/
theorem crossing_bernProb_le_band_prod_two {p : ℝ} (hp0 : 0 ≤ p) (hp1 : p ≤ 1) :
    bernProb p (crossingEvent 2 two_pos) ≤
      bernProb p (bandEvent 2 0 0) * bernProb p (bandEvent 2 1 1) :=
  crossing_bernProb_le_band_prod 2 0 two_pos (by omega) hp0 hp1

/-- The explicit form of the `2 × 2` band bound: `2p² - p⁴ ≤ (2p - p²)²`. -/
theorem crossing_two_le_band_prod_explicit {p : ℝ} (hp0 : 0 ≤ p) (hp1 : p ≤ 1) :
    2 * p ^ 2 - p ^ 4 ≤ (2 * p - p ^ 2) ^ 2 := by
  have h := crossing_bernProb_le_band_prod_two hp0 hp1
  rw [crossing_bernProb_two, bernProb_bandEvent_single 2 0 (by omega),
    bernProb_bandEvent_single 2 1 (by omega)] at h
  calc 2 * p ^ 2 - p ^ 4 ≤ (1 - (1 - p) ^ 2) * (1 - (1 - p) ^ 2) := h
    _ = (2 * p - p ^ 2) ^ 2 := by ring

end BernoulliThresholdCoupling