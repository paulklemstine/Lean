import Mathlib
import Combinatorics.EnergyAscentBerggrenLetters

/-!
# Energy-Ascent III: the Fermat window is a positional ratio sensor

This file formalises the *mechanism* half of the ENERGY-ASCENT round.  The
empirical claim was that the magnitude spectrum of the Fermat energy
`E(a) = a² − N` read in a fixed window `W` anchored at `⌊√N⌋` behaves as a
**positional sensor of the parabola zero crossing**, with a hit rate that
depends strongly on the ratio band (measured rates `{0.000, 0.019, 0.673}` by
letter) — and *not* on any residue datum.

We prove the exact deterministic skeleton behind those numbers.

## Main results

* `EnergyAscent.fermatOffset_lower` / `fermatOffset_upper`: two-sided bounds
  `(q−p)²/(4(p+q)) ≤ (p+q)/2 − √(pq) ≤ (q−p)²/(8√(pq))`, i.e. the zero crossing
  of the Fermat parabola sits at distance `≍ (q−p)²/√N` from `√N`.
* `EnergyAscent.fermatOffset_scale`: the offset is homogeneous of degree one,
  so the *relative* offset is a function of the ratio alone — the sensor is
  positional.
* `EnergyAscent.window_hit_ratio_bound`: a window hit forces `(q−p)² ≤ 4W(p+q)`.
* `EnergyAscent.hit_implies_middle_band`: above scale `112·W` a window hit
  **forces the middle ratio band**.  This is the deterministic core of the
  measured hit-rate table: the outer letters have hit rate exactly `0` there.
* `EnergyAscent.window_hit_determines_berggren_letter`: consequently, for a
  primitive Pythagorean triple above that scale, a window hit on its leg pair
  pins the Berggren branch letter to `1` and names `invB2` as its parent — a
  magnitude channel reading a tree letter.
* `EnergyAscent.hits_exist_unbounded`: the channel is not vacuous; hits occur at
  every scale.
-/

namespace EnergyAscent

open Real

/-- The Fermat offset of a factorisation `N = p·q`: the distance from `√N` to
the abscissa `(p+q)/2` where the parabola `x ↦ x² − N` becomes a square. -/
noncomputable def fermatOffset (p q : ℝ) : ℝ := (p + q) / 2 - Real.sqrt (p * q)

/-- AM–GM: the Fermat crossing lies to the right of `√N`. -/
theorem sqrt_le_mid {p q : ℝ} (hp : 0 ≤ p) (hq : 0 ≤ q) :
    Real.sqrt (p * q) ≤ (p + q) / 2 := by
  have h1 : p * q ≤ ((p + q) / 2) ^ 2 := by nlinarith [sq_nonneg (p - q)]
  calc Real.sqrt (p * q) ≤ Real.sqrt (((p + q) / 2) ^ 2) := Real.sqrt_le_sqrt h1
    _ = (p + q) / 2 := Real.sqrt_sq (by linarith)

theorem fermatOffset_nonneg {p q : ℝ} (hp : 0 ≤ p) (hq : 0 ≤ q) :
    0 ≤ fermatOffset p q := by
  have := sqrt_le_mid hp hq
  unfold fermatOffset; linarith

/-- The defining identity `(s − √N)(s + √N) = ((q−p)/2)²`. -/
theorem fermatOffset_mul {p q : ℝ} (hp : 0 ≤ p) (hq : 0 ≤ q) :
    fermatOffset p q * ((p + q) / 2 + Real.sqrt (p * q)) = ((q - p) / 2) ^ 2 := by
  have hr : Real.sqrt (p * q) ^ 2 = p * q := Real.sq_sqrt (by positivity)
  unfold fermatOffset
  nlinarith [hr]

/-- Lower bound: the crossing is at least `(q−p)²/(4(p+q))` to the right of `√N`. -/
theorem fermatOffset_lower {p q : ℝ} (hp : 0 < p) (hq : 0 < q) :
    (q - p) ^ 2 / (4 * (p + q)) ≤ fermatOffset p q := by
  have hle := sqrt_le_mid hp.le hq.le
  have hnn := fermatOffset_nonneg hp.le hq.le
  have hid := fermatOffset_mul hp.le hq.le
  have hsum : (0 : ℝ) < 4 * (p + q) := by linarith
  rw [div_le_iff₀ hsum]
  nlinarith [hnn, hle, hid]

/-- Upper bound: the crossing is at most `(q−p)²/(8√N)` to the right of `√N`. -/
theorem fermatOffset_upper {p q : ℝ} (hp : 0 < p) (hq : 0 < q) :
    fermatOffset p q ≤ (q - p) ^ 2 / (8 * Real.sqrt (p * q)) := by
  have hrpos : 0 < Real.sqrt (p * q) := Real.sqrt_pos.mpr (by positivity)
  have hnn := fermatOffset_nonneg hp.le hq.le
  have hle := sqrt_le_mid hp.le hq.le
  have hid := fermatOffset_mul hp.le hq.le
  rw [le_div_iff₀ (by linarith)]
  nlinarith [hnn, hle, hid]

/-- **Positionality.**  The offset is homogeneous of degree one in the scale, so
the relative offset `fermatOffset p q / √(pq)` depends only on the ratio `q/p`.
The sensor reads position, never arithmetic. -/
theorem fermatOffset_scale {p q l : ℝ} (hl : 0 ≤ l) :
    fermatOffset (l * p) (l * q) = l * fermatOffset p q := by
  unfold fermatOffset
  have : l * p * (l * q) = l ^ 2 * (p * q) := by ring
  rw [this, Real.sqrt_mul (by positivity), Real.sqrt_sq hl]
  ring

/-- A window hit of half-width `W` forces a quadratic bound on the imbalance. -/
theorem window_hit_ratio_bound {p q W : ℝ} (hp : 0 < p) (hq : 0 < q)
    (hhit : fermatOffset p q ≤ W) : (q - p) ^ 2 ≤ 4 * W * (p + q) := by
  have h := fermatOffset_lower hp hq
  have hsum : (0 : ℝ) < 4 * (p + q) := by linarith
  rw [div_le_iff₀ hsum] at h
  nlinarith [h, hhit]

/-- **Mechanism theorem.**  Above scale `112·W` a window hit forces the *middle*
ratio band: the outer Berggren letters have hit rate exactly zero there.  This
is the deterministic skeleton of the measured table `{0.000, 0.019, 0.673}`. -/
theorem hit_implies_middle_band {p q W : ℤ} (hp : 0 < p) (hpq : p ≤ q)
    (hscale : 112 * W ≤ q) (hhit : fermatOffset (p : ℝ) (q : ℝ) ≤ (W : ℝ)) :
    3 * q ≤ 4 * p ∧ 3 * p ≤ 4 * q := by
  have hq : 0 < q := lt_of_lt_of_le hp hpq
  have hR : ((q : ℝ) - p) ^ 2 ≤ 4 * (W : ℝ) * ((p : ℝ) + q) :=
    window_hit_ratio_bound (by exact_mod_cast hp) (by exact_mod_cast hq) hhit
  have hZ : (q - p) ^ 2 ≤ 4 * W * (p + q) := by exact_mod_cast hR
  refine ⟨?_, by omega⟩
  by_contra hcon
  push_neg at hcon
  -- `4p < 3q` gives `4(q−p) > q` and `4(p+q) ≤ 7q`, whence `q < 112 W`.
  have h1 : q < 4 * (q - p) := by omega
  have h2 : 4 * (p + q) ≤ 7 * q := by omega
  have hqp : 0 < q - p := by omega
  nlinarith [hZ, h1, h2, hqp, hscale]

/-- **Cross-domain bridge.**  For a primitive Pythagorean triple whose leg pair
lies above scale `112·W`, a Fermat-window hit on the legs determines the
Berggren branch letter: it must be the middle letter, and the tree parent is the
`invB2` descent.  A magnitude/position channel reads a tree letter. -/
theorem window_hit_determines_berggren_letter {a b c W : ℤ}
    (ha : 0 < a) (hab : a ≤ b) (hc : 0 < c) (hpt : IsPT a b c)
    (hprim : Int.gcd a b = 1) (hW : 0 < W) (hscale : 112 * W ≤ b)
    (hhit : fermatOffset (a : ℝ) (b : ℝ) ≤ (W : ℝ)) :
    branchLetter a b = 1 ∧
      (0 < (invB2 a b c).1 ∧ 0 < (invB2 a b c).2.1 ∧ 0 < (invB2 a b c).2.2) := by
  have hb : 0 < b := lt_of_lt_of_le ha hab
  have hbc : b < c := by unfold IsPT at hpt; nlinarith
  have hc5 : 5 < c := by omega
  obtain ⟨hne1, hne2⟩ := no_boundary ha hb hc hpt hc5 hprim
  obtain ⟨h1, h2⟩ := hit_implies_middle_band ha hab hscale hhit
  exact ⟨(branchLetter_eq_one_iff a b).mpr ⟨h1, h2⟩,
    (branch_two_iff ha hb hc hpt).mpr ⟨by omega, by omega⟩⟩

/-- A sufficient condition for a window hit. -/
theorem balanced_implies_hit {p q W : ℝ} (hp : 0 < p) (hq : 0 < q)
    (h : (q - p) ^ 2 ≤ 8 * W * Real.sqrt (p * q)) : fermatOffset p q ≤ W := by
  have hrpos : 0 < Real.sqrt (p * q) := Real.sqrt_pos.mpr (by positivity)
  have hup := fermatOffset_upper hp hq
  have : (q - p) ^ 2 / (8 * Real.sqrt (p * q)) ≤ W := by
    rw [div_le_iff₀ (by linarith)]
    linarith [h]
  linarith

/-- **Non-vacuity.**  At every scale there are hits: consecutive factor pairs
sit inside any window `W ≥ 1`.  Hence the channel of
`hit_implies_middle_band` really carries information rather than being
vacuously true. -/
theorem hits_exist_unbounded (W : ℤ) (hW : 0 < W) (S : ℤ) :
    ∃ p q : ℤ, S < p ∧ p < q ∧ 112 * W ≤ q ∧
      fermatOffset (p : ℝ) (q : ℝ) ≤ (W : ℝ) := by
  set p : ℤ := max (S + 1) (112 * W) with hpdef
  have hpS : S < p := lt_of_lt_of_le (lt_add_one S) (le_max_left _ _)
  have hpW : 112 * W ≤ p := le_max_right _ _
  have hp1 : (1 : ℤ) ≤ p := by omega
  refine ⟨p, p + 1, hpS, by omega, by omega, ?_⟩
  have hpR : (1 : ℝ) ≤ (p : ℝ) := by exact_mod_cast hp1
  have hWR : (1 : ℝ) ≤ (W : ℝ) := by exact_mod_cast hW
  have hsq : (1 : ℝ) ≤ Real.sqrt ((p : ℝ) * ((p : ℝ) + 1)) := by
    have h := Real.sqrt_le_sqrt (show (1 : ℝ) ≤ (p : ℝ) * ((p : ℝ) + 1) by nlinarith)
    rwa [Real.sqrt_one] at h
  have hcast : ((p + 1 : ℤ) : ℝ) = (p : ℝ) + 1 := by push_cast; ring
  rw [hcast]
  refine balanced_implies_hit (by linarith) (by linarith) ?_
  have hone : ((p : ℝ) + 1 - p) ^ 2 = 1 := by ring
  rw [hone]
  nlinarith [hsq, hWR]

/-! ## Sharpness of the scale constant `112` -/

/-- A purely integral sufficient criterion for a window hit, obtained by
squaring away the square root. -/
theorem hit_of_quartic_criterion {p q W : ℤ} (hp : 0 < p) (hq : 0 < q) (hW : 0 < W)
    (h : (q - p) ^ 4 ≤ 64 * W ^ 2 * (p * q)) :
    fermatOffset (p : ℝ) (q : ℝ) ≤ (W : ℝ) := by
  have hpR : (0 : ℝ) < (p : ℝ) := by exact_mod_cast hp
  have hqR : (0 : ℝ) < (q : ℝ) := by exact_mod_cast hq
  have hWR : (0 : ℝ) < (W : ℝ) := by exact_mod_cast hW
  have hR : ((q : ℝ) - p) ^ 4 ≤ 64 * (W : ℝ) ^ 2 * ((p : ℝ) * q) := by exact_mod_cast h
  have hs : (0 : ℝ) ≤ Real.sqrt ((p : ℝ) * q) := Real.sqrt_nonneg _
  have hsq : Real.sqrt ((p : ℝ) * q) ^ 2 = (p : ℝ) * q := Real.sq_sqrt (by positivity)
  refine balanced_implies_hit hpR hqR ?_
  by_contra hcon
  push_neg at hcon
  have hA : (0 : ℝ) ≤ 8 * (W : ℝ) * Real.sqrt ((p : ℝ) * q) := by positivity
  have h2 := mul_self_lt_mul_self hA hcon
  nlinarith [h2, hsq, hR]

/-- **The scale constant is essentially optimal.**  `hit_implies_middle_band`
uses the threshold `112·W`; the explicit primitive triple
`(752604, 1004653, 1255285)` with `W = 9133` is a genuine window hit sitting at
scale `110·W` whose letter is *not* the middle one.  Hence no threshold `≤ 110·W`
can work, and the constant `112` is sharp up to two units. -/
theorem threshold_sharp :
    ∃ p q c W : ℤ, 0 < p ∧ p ≤ q ∧ 0 < c ∧ IsPT p q c ∧ Int.gcd p q = 1 ∧
      0 < W ∧ 110 * W ≤ q ∧ fermatOffset (p : ℝ) (q : ℝ) ≤ (W : ℝ) ∧
      branchLetter p q ≠ 1 := by
  refine ⟨752604, 1004653, 1255285, 9133, by norm_num, by norm_num, by norm_num, ?_,
    by norm_num, by norm_num, by norm_num, ?_, ?_⟩
  · unfold IsPT; norm_num
  · exact hit_of_quartic_criterion (by norm_num) (by norm_num) (by norm_num) (by norm_num)
  · have h0 : branchLetter (752604 : ℤ) (1004653 : ℤ) = 0 :=
      (branchLetter_eq_zero_iff _ _).mpr (by norm_num)
    rw [h0]
    decide

end EnergyAscent