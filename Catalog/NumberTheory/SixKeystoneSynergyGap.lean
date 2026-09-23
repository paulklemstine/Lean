import Catalog.NumberTheory.SixKeystoneZeroDrift

/-!
# Cycle III: the synergy of two channels is quantised

Cycle I (`Catalog/NumberTheory/SixKeystoneZeroDrift.lean`) proved that the synergy
`S(p,q) = I(lcm p q) − max (I p) (I q)` of two periodic channels is nonnegative and
vanishes exactly in the nested case `p ∣ q ∨ q ∣ p`.  The audited synergy table reports
*small positive* numbers (e.g. `+0.0049`) alongside larger ones (`+0.1290`), which raises
the question of how small a nonzero synergy can be for genuinely periodic channels.

The answer here is sharp and perhaps counterintuitive: for integer periods there is a
**one-bit gap**.

## Main results

* `capN_max_add_capN_min` — the elementary companion of `gcd · lcm = p · q`.
* `synergy_eq_capN_min_sub_capN_gcd` — the exact closed form
  `S(p,q) = I(min p q) − I(gcd p q) = log₂ (min p q / gcd p q)`.
* `synergy_gap` — **quantisation**: a non-nested pair has `S(p,q) ≥ 1`; there is no
  synergy strictly between `0` and `1` bit.
* `synergy_eq_one_iff_double` — the gap is attained exactly when the smaller period is
  twice the shared period.
* `overlap_eq_ratio`, `overlap_add_synergy_share` — the overlap coefficient is
  `I(gcd)/I(min)` and the two audited statistics partition unity:
  `overlap + S / I(min) = 1`.
-/

namespace SixKeystoneZeroDrift

section

lemma capN_pos {n : ℕ} (hn : 2 ≤ n) : 0 < capN n := by
  have : (1 : ℝ) < (n : ℝ) := by exact_mod_cast (by omega : 1 < n)
  simpa [capN] using Real.logb_pos (by norm_num) this

lemma capN_nonneg {n : ℕ} (hn : 0 < n) : 0 ≤ capN n := by
  have : (1 : ℝ) ≤ (n : ℝ) := by exact_mod_cast hn
  simpa [capN] using Real.logb_nonneg (by norm_num) this

/-- The order-theoretic companion of `gcd · lcm = p · q`. -/
theorem capN_max_add_capN_min (p q : ℕ) (hp : 0 < p) (hq : 0 < q) :
    capN (max p q) + capN (min p q) = capN p + capN q := by
  have hmin : 0 < min p q := lt_min hp hq
  have hmax : 0 < max p q := lt_of_lt_of_le hp (le_max_left _ _)
  have key : ((min p q : ℕ) : ℝ) * ((max p q : ℕ) : ℝ) = (p : ℝ) * (q : ℝ) := by
    exact_mod_cast congrArg (fun n : ℕ => (n : ℝ)) (min_mul_max p q)
  have h1 : capN (min p q) + capN (max p q)
      = Real.logb 2 (((min p q : ℕ) : ℝ) * ((max p q : ℕ) : ℝ)) := by
    rw [Real.logb_mul (by exact_mod_cast hmin.ne') (by exact_mod_cast hmax.ne')]
    rfl
  have h2 : capN p + capN q = Real.logb 2 ((p : ℝ) * (q : ℝ)) := by
    rw [Real.logb_mul (by exact_mod_cast hp.ne') (by exact_mod_cast hq.ne')]
    rfl
  rw [h2, ← key, ← h1]; ring

/-- **Closed form for synergy**: the joint channel adds exactly the bits by which the
weaker period exceeds the shared period. -/
theorem synergy_eq_capN_min_sub_capN_gcd (p q : ℕ) (hp : 0 < p) (hq : 0 < q) :
    synergy p q = capN (min p q) - capN (Nat.gcd p q) := by
  have hmax : max (capN p) (capN q) = capN (max p q) := by
    rcases le_total p q with h | h
    · rw [max_eq_right (capN_le_capN hp h), max_eq_right h]
    · rw [max_eq_left (capN_le_capN hq h), max_eq_left h]
  have h1 := capN_lcm_add_capN_gcd p q hp hq
  have h2 := capN_max_add_capN_min p q hp hq
  rw [synergy, hmax]
  linarith

lemma capN_min_eq_min_capN (p q : ℕ) (hp : 0 < p) (hq : 0 < q) :
    capN (min p q) = min (capN p) (capN q) := by
  rcases le_total p q with h | h
  · rw [min_eq_left h, min_eq_left (capN_le_capN hp h)]
  · rw [min_eq_right h, min_eq_right (capN_le_capN hq h)]

/-- **Synergy quantisation.** For integer periods the synergy is either `0` or at least a
full bit: no value lies strictly between. -/
theorem synergy_gap (p q : ℕ) (hp : 0 < p) (hq : 0 < q) (h : ¬(p ∣ q ∨ q ∣ p)) :
    1 ≤ synergy p q := by
  have hg : 0 < Nat.gcd p q := Nat.gcd_pos_of_pos_left _ hp
  have hmin : 0 < min p q := lt_min hp hq
  have hdvd : Nat.gcd p q ∣ min p q := by
    rcases le_total p q with hpq | hpq
    · rw [min_eq_left hpq]; exact Nat.gcd_dvd_left p q
    · rw [min_eq_right hpq]; exact Nat.gcd_dvd_right p q
  have hne : Nat.gcd p q ≠ min p q := by
    intro heq
    apply h
    rcases le_total p q with hpq | hpq
    · left
      rw [min_eq_left hpq] at heq
      exact heq ▸ Nat.gcd_dvd_right p q
    · right
      rw [min_eq_right hpq] at heq
      exact heq ▸ Nat.gcd_dvd_left p q
  -- a proper divisor is at most half
  have hdouble : 2 * Nat.gcd p q ≤ min p q := by
    obtain ⟨t, ht⟩ := hdvd
    have ht1 : t ≠ 1 := by
      intro h1; exact hne (by simp [ht, h1])
    have ht0 : t ≠ 0 := by
      intro h0
      rw [h0, Nat.mul_zero] at ht
      omega
    have : 2 ≤ t := by omega
    calc 2 * Nat.gcd p q ≤ t * Nat.gcd p q := Nat.mul_le_mul_right _ this
      _ = min p q := by rw [ht]; ring
  rw [synergy_eq_capN_min_sub_capN_gcd p q hp hq]
  have hlog : capN (2 * Nat.gcd p q) ≤ capN (min p q) := capN_le_capN (by omega) hdouble
  have hsplit : capN (2 * Nat.gcd p q) = 1 + capN (Nat.gcd p q) := by
    have hgr : ((Nat.gcd p q : ℕ) : ℝ) ≠ 0 := by
      exact_mod_cast hg.ne'
    have : ((2 * Nat.gcd p q : ℕ) : ℝ) = 2 * ((Nat.gcd p q : ℕ) : ℝ) := by push_cast; ring
    rw [capN, this, Real.logb_mul (by norm_num) hgr,
      Real.logb_self_eq_one (b := 2) (by norm_num)]
    rfl
  linarith [hsplit ▸ hlog]

/-- The one-bit gap is attained exactly when the weaker period doubles the shared one. -/
theorem synergy_eq_one_iff_double (p q : ℕ) (hp : 0 < p) (hq : 0 < q) :
    synergy p q = 1 ↔ min p q = 2 * Nat.gcd p q := by
  have hg : 0 < Nat.gcd p q := Nat.gcd_pos_of_pos_left _ hp
  have hmin : 0 < min p q := lt_min hp hq
  have hsplit : capN (2 * Nat.gcd p q) = 1 + capN (Nat.gcd p q) := by
    have hgr : ((Nat.gcd p q : ℕ) : ℝ) ≠ 0 := by exact_mod_cast hg.ne'
    have hcast : ((2 * Nat.gcd p q : ℕ) : ℝ) = 2 * ((Nat.gcd p q : ℕ) : ℝ) := by
      push_cast; ring
    rw [capN, hcast, Real.logb_mul (by norm_num) hgr,
      Real.logb_self_eq_one (b := 2) (by norm_num)]
    rfl
  rw [synergy_eq_capN_min_sub_capN_gcd p q hp hq]
  constructor
  · intro h1
    have heq : capN (min p q) = capN (2 * Nat.gcd p q) := by rw [hsplit]; linarith
    by_contra hne
    rcases Nat.lt_or_ge (min p q) (2 * Nat.gcd p q) with hlt | hge
    · have : capN (min p q) < capN (2 * Nat.gcd p q) := by
        refine Real.logb_lt_logb (by norm_num) (by exact_mod_cast hmin) ?_
        exact_mod_cast hlt
      exact absurd heq (ne_of_lt this)
    · have hgt : 2 * Nat.gcd p q < min p q := lt_of_le_of_ne hge (fun hh => hne hh.symm)
      have : capN (2 * Nat.gcd p q) < capN (min p q) := by
        refine Real.logb_lt_logb (by norm_num) (by exact_mod_cast (by omega : 0 < 2 * Nat.gcd p q)) ?_
        exact_mod_cast hgt
      exact absurd heq.symm (ne_of_lt this)
  · intro h1
    rw [h1, hsplit]; ring

/-- The overlap coefficient in closed form. -/
theorem overlap_eq_ratio (p q : ℕ) (hp : 0 < p) (hq : 0 < q) :
    overlap p q = capN (Nat.gcd p q) / capN (min p q) := by
  rw [overlap, capN_min_eq_min_capN p q hp hq]

/-- **The audit's two statistics partition unity**: the overlap fraction plus the synergy
share of the weaker channel is exactly `1`. -/
theorem overlap_add_synergy_share (p q : ℕ) (hp : 2 ≤ p) (hq : 2 ≤ q) :
    overlap p q + synergy p q / capN (min p q) = 1 := by
  have hminpos : 2 ≤ min p q := le_min hp hq
  have hcap : 0 < capN (min p q) := capN_pos hminpos
  rw [overlap_eq_ratio p q (by omega) (by omega),
    synergy_eq_capN_min_sub_capN_gcd p q (by omega) (by omega), ← add_div]
  have hsum : capN (Nat.gcd p q) + (capN (min p q) - capN (Nat.gcd p q)) = capN (min p q) := by
    ring
  rw [hsum, div_self hcap.ne']

end

end SixKeystoneZeroDrift