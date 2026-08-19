/-
# What a fourth seed can and cannot do: the Fermat–Weber set of an even sample

The open cell named by NET-48 is *a fourth seed at* `ctx = 2048`.  With three seeds the
knee distribution `{160, 224, 256}` has a unique centre, `224 = (7/8)·256`, which
`Geometry.KneeFermatWeber` identifies as the unique Fermat–Weber point (minimiser of total
distance).  With **four** seeds the geometry changes qualitatively: the minimiser of the
total distance functional is no longer a point but a **segment** — the interval between the
two middle order statistics.  This file proves that, and derives a sharp, falsifiable
prediction about the pending experiment.

## Main results

* `fermatWeber_four` — for `a ≤ b ≤ c ≤ d` the four-point cost `Σ|t - ·|` is bounded below
  by `(d - a) + (c - b)`, and `fermatWeber_four_eq_iff` shows the bound is attained *exactly*
  on the segment `[b, c]`.  So the Fermat–Weber set of an even sample is a segment, and it
  degenerates to a point iff the two middle seeds coincide.
* `net48_fourth_seed_keeps_224` — **the prediction.**  Whatever the fourth 16× seed `x`
  turns out to be, `224` remains an optimal centre of the four-seed distribution
  `{160, 224, 256, x}`: `∀ t, cost 224 ≤ cost t`.  A fourth seed can therefore never
  *refute* the 7/8 centre in the Fermat–Weber sense; it can only make it non-unique.
* `net48_fourth_seed_cost` — the optimal four-seed cost is `96 + |224 - x|`, an exactly
  linear response to the new seed, with slope `1` away from `224`: the quantity a fourth
  seed does move is the *spread*, not the centre.
* `net48_fourth_seed_low_tail` / `net48_fourth_seed_high` — the Fermat–Weber set in the two
  regimes singled out by the experiment plan: a low-tail seed `x ∈ [160,224]` gives the
  segment `[x,224]` (so a repeat low tail widens the optimal set downwards), while
  `x ∈ [224,256]` gives `[224,x]`.
* `net48_fourth_seed_unique_iff` — the centre stays a *unique* optimum only in the knife-edge
  case `x = 224`.
-/
import Geometry.KneeFermatWeber

namespace Catalog.Geometry.KneeFourthSeed

open Catalog.Geometry.KneeFermatWeber

/-! ## The four-point Fermat–Weber problem -/

/-- Total distance from `t` to a four-point sample. -/
def cost4 (a b c d t : ℝ) : ℝ := |t - a| + |t - b| + |t - c| + |t - d|

/-- **Lower bound for an even sample.**  For sorted data the total distance is at least the
sum of the two nested spreads `(d - a) + (c - b)`. -/
theorem fermatWeber_four {a b c d : ℝ} (hab : a ≤ b) (hbc : b ≤ c) (hcd : c ≤ d) (t : ℝ) :
    (d - a) + (c - b) ≤ cost4 a b c d t := by
  have h1 : d - a ≤ |t - a| + |t - d| := by
    rcases abs_cases (t - a) with ⟨h, _⟩ | ⟨h, _⟩ <;>
      rcases abs_cases (t - d) with ⟨h', _⟩ | ⟨h', _⟩ <;> linarith
  have h2 : c - b ≤ |t - b| + |t - c| := by
    rcases abs_cases (t - b) with ⟨h, _⟩ | ⟨h, _⟩ <;>
      rcases abs_cases (t - c) with ⟨h', _⟩ | ⟨h', _⟩ <;> linarith
  simp only [cost4]
  linarith

/-- **The Fermat–Weber set of an even sample is the middle segment.**  Equality in the bound
holds exactly for `t ∈ [b, c]`. -/
theorem fermatWeber_four_eq_iff {a b c d : ℝ} (hab : a ≤ b) (hbc : b ≤ c) (hcd : c ≤ d)
    (t : ℝ) : cost4 a b c d t = (d - a) + (c - b) ↔ b ≤ t ∧ t ≤ c := by
  constructor
  · intro h
    simp only [cost4] at h
    constructor
    · by_contra ht
      push_neg at ht
      have h1 : |t - a| + |t - d| ≥ d - a := by
        rcases abs_cases (t - a) with ⟨h', _⟩ | ⟨h', _⟩ <;>
          rcases abs_cases (t - d) with ⟨h'', _⟩ | ⟨h'', _⟩ <;> linarith
      have h2 : |t - b| = b - t := by
        rw [abs_of_nonpos (by linarith)]; ring
      have h3 : |t - c| = c - t := by
        rw [abs_of_nonpos (by linarith)]; ring
      rw [h2, h3] at h
      linarith
    · by_contra ht
      push_neg at ht
      have h1 : |t - a| + |t - d| ≥ d - a := by
        rcases abs_cases (t - a) with ⟨h', _⟩ | ⟨h', _⟩ <;>
          rcases abs_cases (t - d) with ⟨h'', _⟩ | ⟨h'', _⟩ <;> linarith
      have h2 : |t - b| = t - b := by
        rw [abs_of_nonneg (by linarith)]
      have h3 : |t - c| = t - c := by
        rw [abs_of_nonneg (by linarith)]
      rw [h2, h3] at h
      linarith
  · rintro ⟨htb, htc⟩
    simp only [cost4]
    rw [abs_of_nonneg (by linarith : (0:ℝ) ≤ t - a), abs_of_nonneg (by linarith : (0:ℝ) ≤ t - b),
      abs_of_nonpos (by linarith : t - c ≤ 0), abs_of_nonpos (by linarith : t - d ≤ 0)]
    ring

/-- The Fermat–Weber set of a four-point sample degenerates to a single point exactly when
the two middle order statistics coincide. -/
theorem fermatWeber_four_unique_iff {a b c d : ℝ} (hab : a ≤ b) (hbc : b ≤ c) (hcd : c ≤ d) :
    (∀ t, cost4 a b c d t = (d - a) + (c - b) → t = b) ↔ b = c := by
  constructor
  · intro h
    have := h c ((fermatWeber_four_eq_iff hab hbc hcd c).mpr ⟨hbc, le_refl c⟩)
    exact this.symm
  · rintro rfl
    intro t ht
    exact le_antisymm ((fermatWeber_four_eq_iff hab hbc hcd t).mp ht).2
      ((fermatWeber_four_eq_iff hab hbc hcd t).mp ht).1

/-! ## The prediction for the pending fourth 16× seed -/

/-- Total distance from `t` to the three measured 16× knees together with a fourth seed `x`. -/
def cost16 (x t : ℝ) : ℝ := |t - 160| + |t - 224| + |t - 256| + |t - x|

/-- The cost of the 7/8-centre against the four-seed sample. -/
theorem cost16_at_224 (x : ℝ) : cost16 x 224 = 96 + |224 - x| := by
  simp only [cost16]
  rw [abs_of_nonneg (by norm_num : (0:ℝ) ≤ (224:ℝ) - 160),
    abs_of_nonpos (by norm_num : (224:ℝ) - 256 ≤ 0)]
  norm_num

/-- **The prediction.**  For *every* value of the fourth seed `x`, the 7/8-centre `224`
remains a Fermat–Weber point of the four-seed 16× distribution.  A fourth seed cannot move
the optimal centre off `224`; the strongest thing it can do is make the optimum non-unique. -/
theorem net48_fourth_seed_keeps_224 (x t : ℝ) : cost16 x 224 ≤ cost16 x t := by
  have hends : (96 : ℝ) ≤ |t - 160| + |t - 256| := by
    rcases abs_cases (t - 160) with ⟨h, _⟩ | ⟨h, _⟩ <;>
      rcases abs_cases (t - 256) with ⟨h', _⟩ | ⟨h', _⟩ <;> linarith
  have hx : |224 - x| ≤ |t - 224| + |t - x| := by
    rcases abs_cases (224 - x) with ⟨h, _⟩ | ⟨h, _⟩ <;>
      rcases abs_cases (t - 224) with ⟨h', _⟩ | ⟨h', _⟩ <;>
        rcases abs_cases (t - x) with ⟨h'', _⟩ | ⟨h'', _⟩ <;> linarith
  rw [cost16_at_224]
  simp only [cost16]
  linarith

/-- The optimal four-seed cost responds to the fourth seed exactly linearly: it is
`96 + |224 - x|`.  What a fourth seed moves is the spread, not the centre. -/
theorem net48_fourth_seed_cost (x : ℝ) :
    (∀ t, cost16 x 224 ≤ cost16 x t) ∧ cost16 x 224 = 96 + |224 - x| :=
  ⟨net48_fourth_seed_keeps_224 x, cost16_at_224 x⟩

/-- A low-tail fourth seed `x ∈ [160, 224]` makes the Fermat–Weber set the segment `[x, 224]`:
the optimum widens *downwards*, but its upper endpoint stays pinned at the 7/8-centre. -/
theorem net48_fourth_seed_low_tail {x : ℝ} (hx1 : 160 ≤ x) (hx2 : x ≤ 224) (t : ℝ) :
    cost16 x t = (256 - 160) + (224 - x) ↔ x ≤ t ∧ t ≤ 224 := by
  have h := fermatWeber_four_eq_iff (a := 160) (b := x) (c := 224) (d := 256) hx1 hx2
    (by norm_num) t
  simp only [cost4] at h
  simp only [cost16]
  constructor
  · intro ht
    exact h.mp (by linarith [ht])
  · intro ht
    have := h.mpr ht
    linarith [this]

/-- A high fourth seed `x ∈ [224, 256]` makes the Fermat–Weber set `[224, x]`: the optimum
widens *upwards*, with lower endpoint pinned at the 7/8-centre. -/
theorem net48_fourth_seed_high {x : ℝ} (hx1 : 224 ≤ x) (hx2 : x ≤ 256) (t : ℝ) :
    cost16 x t = (256 - 160) + (x - 224) ↔ 224 ≤ t ∧ t ≤ x := by
  have h := fermatWeber_four_eq_iff (a := 160) (b := 224) (c := x) (d := 256) (by norm_num) hx1
    hx2 t
  simp only [cost4] at h
  simp only [cost16]
  constructor
  · intro ht
    exact h.mp (by linarith [ht])
  · intro ht
    have := h.mpr ht
    linarith [this]

/-- **Knife edge.**  The 7/8-centre remains the *unique* optimum only if the fourth seed is
itself `224`; any other value produces a segment of optima. -/
theorem net48_fourth_seed_unique_iff {x : ℝ} (hx1 : 160 ≤ x) (hx2 : x ≤ 224) :
    (∀ t, cost16 x t = (256 - 160) + (224 - x) → t = 224) ↔ x = 224 := by
  constructor
  · intro h
    have hx := h x ((net48_fourth_seed_low_tail hx1 hx2 x).mpr ⟨le_refl x, hx2⟩)
    exact hx
  · rintro rfl
    intro t ht
    have := (net48_fourth_seed_low_tail hx1 hx2 t).mp ht
    exact le_antisymm this.2 this.1

end Catalog.Geometry.KneeFourthSeed