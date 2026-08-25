import Cryptography.KTaxonomyCensusEcon

/-!
# The k-taxonomy at general (non-dyadic) support width

`Cryptography.KTaxonomyCensusEcon` settles the taxonomy for dyadic widths `W = 2 ^ m`,
where the census optimum is the exact two-element tie set `{m - 2, m - 1}`.  This file
removes the dyadic restriction: for an arbitrary width `W > 0` it characterises the census
argmin by a pair of *dyadic bracketing inequalities*, and derives from that characterisation
the two structural verdicts of the taxonomy at full generality:

* `census_argmin_iff` : `k` is a census optimum for width `W` iff `W ≤ 2 ^ (k + 2)` and
  (`k = 0` or `2 ^ (k + 1) ≤ W`).  For `W = 2 ^ m` this returns the tie set `{m-2, m-1}`,
  and in general it says the optimum sits at offset `-2` or `-1` relative to `log₂ W`.
* `census_pin_strictly_suboptimal` : for **every** integer width `W ≥ 2` the pin
  `⌈log₂ W⌉` is strictly beaten by `⌈log₂ W⌉ - 1`.  So the pin is never a census optimum —
  not merely for the dyadic widths checked numerically.
* `pin_gap_general` : for **every** integer width `W ≥ 2`, every census optimum `k`
  satisfies `kPin W - k ∈ {1, 2}`.
* `econ_argmin_iff` : the corresponding characterisation for the economics objective,
  obtained for free from the exact anchor identity `econ_eq_census_anchor`.

-- !-- Lab Notes -- !--
Hypothesizer (round 2, after the dyadic results):
 (H6) The `{-2, -1}` offset pattern is not a dyadic accident: it is the general shape of
      the census argmin, expressible as `2 ^ (k+1) ≤ W ≤ 2 ^ (k+2)`.              [BOLD]
 (H7) "Pin is never optimal" holds for every integer width, with a one-line reason:
      `W ≤ 2 ^ ⌈log₂ W⌉` forces the last query to cost more than the residual it saves.
 (H8) The gap `pin - argmin ∈ {1,2}` is a corollary of H6 plus the two clog bracketing
      inequalities `2 ^ (⌈log₂ W⌉ - 1) < W ≤ 2 ^ ⌈log₂ W⌉`, so it needs no case check.

Experimenter: H6–H8 proved below with zero sorries.  The only analytic ingredient is the
increment formula `census W (k+1) - census W k = 1 - W / 2 ^ (k+2)`; everything else is
the discrete-convexity principle `min_of_local_min` from the previous file plus `Nat.clog`
bracketing.

Analyst: the numerically observed statement "gap ∈ {1,2} for every W ≤ 4096" is therefore
not a finite check at all — it is a theorem for every `W`, and the two possible gap values
are exactly the two ends of the census tie bracket.  Nothing in the argument uses dyadicity,
which is the structural reason the tie set has exactly two elements when `W` is dyadic (both
bracketing inequalities become equalities) and one element otherwise.
-/

namespace KTaxonomy

/-! ## The increment of the census cost -/

lemma census_incr (W : ℝ) (k : ℕ) :
    census W (k + 1) - census W k = 1 - W / 2 ^ (k + 2) := by
  have h : (2:ℝ) ^ k ≠ 0 := by positivity
  simp only [census]
  push_cast
  field_simp
  ring

/-! ## The census argmin at general width -/

/-- **General-width census optimum.**  For any positive width `W`, the budget `k` is a
census optimum exactly when the width is bracketed by `2 ^ (k+1) ≤ W ≤ 2 ^ (k+2)` (the
lower bracket being vacuous at `k = 0`). -/
theorem census_argmin_iff (W : ℝ) (hW : 0 < W) (k : ℕ) :
    (∀ j, census W k ≤ census W j) ↔ (W ≤ 2 ^ (k + 2) ∧ (k = 0 ∨ 2 ^ (k + 1) ≤ W)) := by
  constructor
  · intro h
    constructor
    · have h1 := h (k + 1)
      have h2 := census_incr W k
      have h3 : (0:ℝ) < 2 ^ (k + 2) := by positivity
      have : W / 2 ^ (k + 2) ≤ 1 := by linarith
      rwa [div_le_one h3] at this
    · rcases Nat.eq_zero_or_pos k with hk | hk
      · exact Or.inl hk
      · right
        obtain ⟨m, rfl⟩ : ∃ m, k = m + 1 := ⟨k - 1, by omega⟩
        have h1 := h m
        have h2 := census_incr W m
        have h3 : (0:ℝ) < 2 ^ (m + 2) := by positivity
        have : 1 ≤ W / 2 ^ (m + 2) := by linarith
        rwa [le_div_iff₀ h3, one_mul] at this
  · rintro ⟨hup, hdown⟩
    refine min_of_local_min (f := fun k => census W k) (census_conv W hW.le) ?_ ?_
    · have h2 := census_incr W k
      have h3 : (0:ℝ) < 2 ^ (k + 2) := by positivity
      have : W / 2 ^ (k + 2) ≤ 1 := by rwa [div_le_one h3]
      simp only
      linarith
    · rintro m rfl
      rcases hdown with hk | hk
      · exact absurd hk (by omega)
      · have h2 := census_incr W m
        have h3 : (0:ℝ) < 2 ^ (m + 2) := by positivity
        have : 1 ≤ W / 2 ^ (m + 2) := by rwa [le_div_iff₀ h3, one_mul]
        simp only
        linarith

/-- The economics argmin at general anchor, read off the exact anchor identity. -/
theorem econ_argmin_iff (T₀ : ℝ) (hT : 1 < T₀) (k : ℕ) :
    (∀ j, econ T₀ 1 k ≤ econ T₀ 1 j) ↔
      (2 * (T₀ - 1) ≤ 2 ^ (k + 2) ∧ (k = 0 ∨ 2 ^ (k + 1) ≤ 2 * (T₀ - 1))) := by
  rw [econ_argmin_iff_census_argmin T₀ k]
  exact census_argmin_iff (2 * (T₀ - 1)) (by linarith) k

/-! ## The pin is never optimal, at every integer width -/

lemma one_le_kPin {W : ℕ} (hW : 2 ≤ W) : 1 ≤ kPin W :=
  Nat.clog_pos (by norm_num) (by omega)

lemma width_le_two_pow_kPin (W : ℕ) : (W : ℝ) ≤ 2 ^ kPin W := by
  have := Nat.le_pow_clog (b := 2) (by norm_num) W
  exact_mod_cast this

lemma two_pow_pred_kPin_lt {W : ℕ} (hW : 2 ≤ W) : (2:ℝ) ^ (kPin W - 1) < W := by
  have := Nat.pow_pred_clog_lt_self (b := 2) (by norm_num) (x := W) (by omega)
  have h : (2:ℕ) ^ (kPin W - 1) < W := by
    simpa [kPin, Nat.pred_eq_sub_one] using this
  exact_mod_cast h

/-- **The pin is strictly suboptimal at every integer width `W ≥ 2`.**  Spending the last,
saturating query costs `1`, while it can only save `W / 2 ^ (kPin W + 1) ≤ 1/2`. -/
theorem census_pin_strictly_suboptimal (W : ℕ) (hW : 2 ≤ W) :
    census (W : ℝ) (kPin W - 1) < census (W : ℝ) (kPin W) := by
  have hk1 : 1 ≤ kPin W := one_le_kPin hW
  obtain ⟨p, hp⟩ : ∃ p, kPin W = p + 1 := ⟨kPin W - 1, by omega⟩
  have hpin : (W : ℝ) ≤ 2 ^ (p + 1) := by
    have := width_le_two_pow_kPin W
    rwa [hp] at this
  have hinc := census_incr (W : ℝ) p
  have hpow : (0:ℝ) < 2 ^ (p + 2) := by positivity
  have hhalf : (W : ℝ) / 2 ^ (p + 2) ≤ 1 / 2 := by
    rw [div_le_div_iff₀ hpow (by norm_num)]
    have : (2:ℝ) ^ (p + 2) = 2 ^ (p + 1) * 2 := by ring
    rw [this]
    linarith
  rw [hp]
  simp only [Nat.add_sub_cancel]
  linarith

/-- Hence the pin is never a census optimum. -/
theorem census_pin_not_argmin (W : ℕ) (hW : 2 ≤ W) :
    ¬ (∀ j, census (W : ℝ) (kPin W) ≤ census (W : ℝ) j) := by
  intro h
  have := h (kPin W - 1)
  have := census_pin_strictly_suboptimal W hW
  linarith

/-- **The pin overshoots every census optimum by exactly one or two queries**, at every
integer width `W ≥ 2`. -/
theorem pin_gap_general (W k : ℕ) (hW : 2 ≤ W)
    (hk : ∀ j, census (W : ℝ) k ≤ census (W : ℝ) j) :
    kPin W - k = 1 ∨ kPin W - k = 2 := by
  have hWpos : (0:ℝ) < (W : ℝ) := by exact_mod_cast (show 0 < W by omega)
  obtain ⟨hup, hdown⟩ := (census_argmin_iff (W : ℝ) hWpos k).1 hk
  -- upper bracket: `2 ^ (kPin W - 1) < W ≤ 2 ^ (k + 2)` forces `kPin W ≤ k + 2`
  have h1 : (2:ℝ) ^ (kPin W - 1) < 2 ^ (k + 2) :=
    lt_of_lt_of_le (two_pow_pred_kPin_lt hW) hup
  have h1' : kPin W - 1 < k + 2 := by
    have : (2:ℕ) ^ (kPin W - 1) < 2 ^ (k + 2) := by exact_mod_cast h1
    exact (Nat.pow_lt_pow_iff_right (by norm_num)).1 this
  -- lower bracket: `2 ^ (k + 1) ≤ W ≤ 2 ^ kPin W` forces `k + 1 ≤ kPin W`
  have hk1 : 1 ≤ kPin W := one_le_kPin hW
  rcases hdown with hk0 | hlow
  · subst hk0
    -- `k = 0`: then `W ≤ 4` and `W ≥ 2`, so `kPin W ∈ {1, 2}`
    have : kPin W ≤ 2 := by omega
    omega
  · have h2 : (2:ℝ) ^ (k + 1) ≤ 2 ^ kPin W :=
      le_trans hlow (width_le_two_pow_kPin W)
    have h2' : k + 1 ≤ kPin W := by
      have : (2:ℕ) ^ (k + 1) ≤ 2 ^ kPin W := by exact_mod_cast h2
      exact (Nat.pow_le_pow_iff_right (by norm_num)).1 this
    omega

end KTaxonomy