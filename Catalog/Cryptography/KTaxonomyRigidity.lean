import Cryptography.KTaxonomyGeneralWidth

/-!
# Rigidity of the k-taxonomy: price rescaling, tie sets, and the exact pin gap

Round three of the taxonomy.  The previous two files fixed the three budgets and proved the
exact identities relating them at unit query price and the argmin brackets at general width.
Here we close the three questions those results left open.

* **Price is a pure anchor rescaling** (`econ_eq_census_price`,
  `econ_argmin_iff_census_argmin_price`): for every price `c_q > 0`,
  `econ T₀ c_q k = c_q ⬝ (census (2 (T₀ - 1) / c_q) k + 1/2)`, so the economics optimum at
  price `c_q` is *exactly* the census optimum at the rescaled anchor `2 (T₀ - 1) / c_q`.
  The two-parameter taxonomy therefore collapses to the one-parameter census family.
* **Tie dichotomy** (`census_tie_iff`, `census_argmin_unique_of_not_two_pow`): the census
  argmin is a two-element set exactly at the dyadic widths `W = 2 ^ (k + 2)`, and is a
  singleton at every non-dyadic width.  So "the" census optimum is well defined off the
  dyadic locus, and ambiguous exactly on it.
* **Exact pin gap** (`pin_gap_one_iff_two_pow`): for an integer width `W ≥ 2` and a census
  optimum `k`, the gap `kPin W - k` equals `1` **iff** `W = 2 ^ (k + 1)`, and equals `2`
  otherwise.  Combined with `pin_gap_general` this determines the gap completely.

-- !-- Lab Notes -- !--
Hypothesizer (round 3):
 (H9)  Price enters only through the anchor: argmin of `econ T₀ c_q` = argmin of
       `census (2 (T₀ - 1) / c_q)`.                                              [BOLD]
 (H10) Ties happen exactly at dyadic widths.
 (H11) The pin gap is `2` at *non*-dyadic widths and `1` only when the width is exactly
       `2 ^ (k + 1)`.

Analyst: H11 is the informative correction of this round.  The natural guess from the
dyadic table (`argmin = {m-2, m-1}`, pin `m`, gaps `{2, 1}`) is that gap `1` is generic and
gap `2` is the dyadic exception.  The truth is the opposite: at `W = 3` the unique optimum
is `k = 0` while the pin is `2`, so the gap is `2`; a gap of `1` requires the width to sit
exactly on the power of two `2 ^ (k + 1)`.  This is a "needs a different statement" outcome
rather than a failure: the corrected statement is proved below, and it says the pin
overstates the work-optimal budget by *two* queries at almost every width.
-/

namespace KTaxonomy

/-! ## Price is a pure anchor rescaling -/

/-- The economics cost at price `c_q` is a positive multiple of the census cost at the
rescaled anchor `2 (T₀ - 1) / c_q`, up to the usual additive `1/2`. -/
theorem econ_eq_census_price (T₀ cq : ℝ) (hc : 0 < cq) (k : ℕ) :
    econ T₀ cq k = cq * (census (2 * (T₀ - 1) / cq) k + 1 / 2) := by
  have h : (2:ℝ) ^ k ≠ 0 := by positivity
  simp only [econ, census]
  field_simp
  ring

/-- **The economics optimum at any query price is a census optimum at a rescaled anchor.** -/
theorem econ_argmin_iff_census_argmin_price (T₀ cq : ℝ) (hc : 0 < cq) (k : ℕ) :
    (∀ j, econ T₀ cq k ≤ econ T₀ cq j) ↔
      (∀ j, census (2 * (T₀ - 1) / cq) k ≤ census (2 * (T₀ - 1) / cq) j) := by
  constructor <;> intro h j
  · have hj := h j
    rw [econ_eq_census_price T₀ cq hc, econ_eq_census_price T₀ cq hc] at hj
    have := le_of_mul_le_mul_left hj hc
    linarith
  · rw [econ_eq_census_price T₀ cq hc, econ_eq_census_price T₀ cq hc]
    have := h j
    exact mul_le_mul_of_nonneg_left (by linarith) hc.le

/-! ## The tie dichotomy -/

/-- **Ties occur exactly at dyadic widths.**  Two consecutive budgets are both census
optima iff the width is exactly `2 ^ (k + 2)`. -/
theorem census_tie_iff (W : ℝ) (hW : 0 < W) (k : ℕ) :
    ((∀ j, census W k ≤ census W j) ∧ (∀ j, census W (k + 1) ≤ census W j)) ↔
      W = 2 ^ (k + 2) := by
  constructor
  · rintro ⟨h1, h2⟩
    have hb1 := (census_argmin_iff W hW k).1 h1
    have hb2 := (census_argmin_iff W hW (k + 1)).1 h2
    rcases hb2.2 with hz | hlow
    · exact absurd hz (by omega)
    · have : (2:ℝ) ^ (k + 2) ≤ W := by simpa using hlow
      linarith [hb1.1]
  · intro hWval
    constructor
    · refine (census_argmin_iff W hW k).2 ⟨le_of_eq hWval, Or.inr ?_⟩
      rw [hWval]
      exact pow_le_pow_right₀ (by norm_num) (by omega)
    · refine (census_argmin_iff W hW (k + 1)).2 ⟨?_, Or.inr ?_⟩
      · rw [hWval]
        exact pow_le_pow_right₀ (by norm_num) (by omega)
      · rw [hWval]

/-- Two census optima are always within one step of each other. -/
theorem census_argmin_adjacent (W : ℝ) (hW : 0 < W) (k k' : ℕ)
    (hk : ∀ j, census W k ≤ census W j) (hk' : ∀ j, census W k' ≤ census W j) :
    k' ≤ k + 1 := by
  by_contra hcon
  push_neg at hcon
  have hb1 := (census_argmin_iff W hW k).1 hk
  have hb2 := (census_argmin_iff W hW k').1 hk'
  rcases hb2.2 with hz | hlow
  · omega
  · have hmono : (2:ℝ) ^ (k + 3) ≤ 2 ^ (k' + 1) :=
      pow_le_pow_right₀ (by norm_num) (by omega)
    have h3 : (2:ℝ) ^ (k + 3) ≤ W := le_trans hmono hlow
    have h4 : (2:ℝ) ^ (k + 2) < 2 ^ (k + 3) := by
      apply pow_lt_pow_right₀ (by norm_num) (by omega)
    linarith [hb1.1]

/-- **Off the dyadic locus the census optimum is unique.** -/
theorem census_argmin_unique_of_not_two_pow (W : ℝ) (hW : 0 < W)
    (hnd : ∀ m : ℕ, W ≠ 2 ^ m) (k k' : ℕ)
    (hk : ∀ j, census W k ≤ census W j) (hk' : ∀ j, census W k' ≤ census W j) :
    k = k' := by
  have h1 : k' ≤ k + 1 := census_argmin_adjacent W hW k k' hk hk'
  have h2 : k ≤ k' + 1 := census_argmin_adjacent W hW k' k hk' hk
  rcases lt_trichotomy k k' with h | h | h
  · obtain rfl : k' = k + 1 := by omega
    exact absurd ((census_tie_iff W hW k).1 ⟨hk, hk'⟩) (hnd (k + 2))
  · exact h
  · obtain rfl : k = k' + 1 := by omega
    exact absurd ((census_tie_iff W hW k').1 ⟨hk', hk⟩) (hnd (k' + 2))

/-! ## The exact pin gap -/

/-- **The pin gap is `1` exactly at the dyadic widths `W = 2 ^ (k + 1)`.**  Together with
`pin_gap_general` (gap `∈ {1, 2}`) this determines the gap at every integer width: it is
`2` unless the width sits exactly on the power of two just above the optimum. -/
theorem pin_gap_one_iff_two_pow (W k : ℕ) (hW : 2 ≤ W)
    (hk : ∀ j, census (W : ℝ) k ≤ census (W : ℝ) j) :
    kPin W - k = 1 ↔ W = 2 ^ (k + 1) := by
  have hWpos : (0:ℝ) < (W : ℝ) := by exact_mod_cast (show 0 < W by omega)
  have hgap := pin_gap_general W k hW hk
  have hbr := (census_argmin_iff (W : ℝ) hWpos k).1 hk
  constructor
  · intro h1
    have hpin : kPin W = k + 1 := by omega
    have hupper : W ≤ 2 ^ (k + 1) := by
      have := Nat.le_pow_clog (b := 2) (by norm_num) W
      rw [← hpin]
      simpa [kPin] using this
    rcases hbr.2 with hz | hlow
    · -- `k = 0`, so the pin is `1` and `2 ≤ W ≤ 2`
      subst hz
      omega
    · have : (2:ℕ) ^ (k + 1) ≤ W := by exact_mod_cast hlow
      omega
  · intro hWval
    have : kPin W = k + 1 := by
      rw [hWval, kPin]
      exact Nat.clog_pow 2 (k + 1) (by norm_num)
    omega

/-- Consequently the pin overshoots by exactly two queries at every non-dyadic width. -/
theorem pin_gap_two_of_not_two_pow (W k : ℕ) (hW : 2 ≤ W)
    (hnd : ∀ m : ℕ, W ≠ 2 ^ m)
    (hk : ∀ j, census (W : ℝ) k ≤ census (W : ℝ) j) :
    kPin W - k = 2 := by
  rcases pin_gap_general W k hW hk with h | h
  · exact absurd ((pin_gap_one_iff_two_pow W k hW hk).1 h) (hnd (k + 1))
  · exact h

/-! ## How much the pin overcharges -/

lemma census_two_step (W : ℝ) (k : ℕ) :
    census W (k + 2) - census W k = 2 - 3 * W / 2 ^ (k + 3) := by
  have h1 := census_incr W k
  have h2 := census_incr W (k + 1)
  have h5 : (k + 1) + 2 = k + 3 := by omega
  rw [h5] at h2
  have hsplit : census W (k + 2) - census W k
      = (census W (k + 1 + 1) - census W (k + 1)) + (census W (k + 1) - census W k) := by
    norm_num
  have h3 : (2:ℝ) ^ (k + 3) = 2 ^ (k + 2) * 2 := by ring
  have h4 : (0:ℝ) < 2 ^ (k + 2) := by positivity
  rw [hsplit, h1, h2, h3]
  field_simp
  ring

/-- **The pin overcharges by at least half a query and by less than `5/4` of a query**, at
every integer width `W ≥ 2`.  The lower bound `1/2` is attained exactly at the dyadic
widths `W = 2 ^ (k + 1)`; the upper bound `5/4` is approached (never attained) as
`W → 2 ^ m + 1`. -/
theorem pin_overcharge_bounds (W k : ℕ) (hW : 2 ≤ W)
    (hk : ∀ j, census (W : ℝ) k ≤ census (W : ℝ) j) :
    1 / 2 ≤ census (W : ℝ) (kPin W) - census (W : ℝ) k ∧
      census (W : ℝ) (kPin W) - census (W : ℝ) k < 5 / 4 := by
  have hWpos : (0:ℝ) < (W : ℝ) := by exact_mod_cast (show 0 < W by omega)
  have hbr := (census_argmin_iff (W : ℝ) hWpos k).1 hk
  have hk1 : 1 ≤ kPin W := one_le_kPin hW
  have hlow : (2:ℝ) ^ (k + 1) ≤ (W : ℝ) := by
    rcases hbr.2 with hz | h
    · subst hz
      have : (2:ℝ) ≤ (W : ℝ) := by exact_mod_cast hW
      simpa using this
    · exact h
  rcases pin_gap_general W k hW hk with hgap | hgap
  · have hWval : W = 2 ^ (k + 1) := (pin_gap_one_iff_two_pow W k hW hk).1 hgap
    have hpin : kPin W = k + 1 := by omega
    have hWr : (W : ℝ) = 2 ^ (k + 1) := by exact_mod_cast congrArg (Nat.cast (R := ℝ)) hWval
    have hinc := census_incr (W : ℝ) k
    have hp : (0:ℝ) < 2 ^ (k + 1) := by positivity
    have hval : census (W : ℝ) (kPin W) - census (W : ℝ) k = 1 / 2 := by
      rw [hpin, hinc, hWr]
      have : (2:ℝ) ^ (k + 2) = 2 ^ (k + 1) * 2 := by ring
      rw [this]
      field_simp
      norm_num
    rw [hval]
    norm_num
  · have hpin : kPin W = k + 2 := by omega
    have hstep := census_two_step (W : ℝ) k
    have hp3 : (0:ℝ) < 2 ^ (k + 3) := by positivity
    have hupper : (W : ℝ) ≤ 2 ^ (k + 2) := hbr.1
    have hstrict : (2:ℝ) ^ (k + 1) < (W : ℝ) := by
      rcases lt_or_eq_of_le hlow with h | h
      · exact h
      · exfalso
        have hWnat : W = 2 ^ (k + 1) := by exact_mod_cast h.symm
        have := (pin_gap_one_iff_two_pow W k hW hk).2 hWnat
        omega
    have e2 : (2:ℝ) ^ (k + 3) = 2 ^ (k + 1) * 4 := by ring
    have e1 : (2:ℝ) ^ (k + 2) = 2 ^ (k + 1) * 2 := by ring
    rw [e1] at hupper
    have hb1 : 3 * (W:ℝ) / 2 ^ (k + 3) ≤ 3 / 2 := by
      rw [div_le_iff₀ hp3, e2]
      nlinarith
    have hb2 : 3 / 4 < 3 * (W:ℝ) / 2 ^ (k + 3) := by
      rw [lt_div_iff₀ hp3, e2]
      nlinarith
    rw [hpin, hstep]
    constructor <;> linarith

end KTaxonomy