import Mathlib
import Algebra.QubitTrade.Resolution
import Algebra.QubitTrade.SupportCollapse

/-!
# QUBIT-TRADE X: the Farey count, and the quadratic threshold in the exact grid model

`Resolution.lean` proves the two-sided threshold `t_min = 2 log₂ R + O(1)` in the
*tolerance* model (a `t`-bit register pins the phase to within `2^{-(t+1)}`), which
is the model in which Shor's post-processing is analysed.  The strictest possible
model is the *dyadic grid* model of `SupportCollapse.lean`: the register reports
only the cell index `⌊2^t · x⌋`, and two phases are confusable exactly when they
share a cell.

This file closes the gap between the two models by proving the missing counting
ingredient — an elementary lower bound on the number of Farey fractions —

* `QubitTrade.four_mul_card_coprimePairs` : `R² ≤ 4 · #{(a,b) ∈ [1,R]² : gcd a b = 1}`,
  proved from the exact gcd-fibration identity `R² = Σ_{d ≤ R} C(⌊R/d⌋)` together
  with the elementary tail bound `Σ_{d ≥ 2} d^{-2} ≤ 3/4`;
* `QubitTrade.card_fareyFractions_ge` : consequently at least `R²/4` *distinct*
  rationals in `(0,1)` have denominator `≤ 2R`;
* `QubitTrade.grid_ambiguous` : **pigeonhole** — if `4 · 2^t < R²` then two distinct
  reduced fractions of denominator `≤ 2R` fall in the *same* dyadic cell, so a
  `t`-bit truncated register cannot separate them;
* `QubitTrade.grid_threshold_quadratic` : restated in bit terms, a register that
  separates all fractions of denominator `≤ D` must have `2 log₂ D < t + 6`;
* `QubitTrade.gridCell_orderFrac` : the grid cell of an order fraction is *exactly*
  the truncated outcome `truncOutcome` of `SupportCollapse.lean`, so the two models
  are literally the same measurement;
* `QubitTrade.truncOutcome_ambiguous` : hence, below the quadratic threshold, two
  distinct order fractions `k/r ≠ k'/r'` with orders `≤ 2R` yield the same
  truncated register outcome.

* `QubitTrade.grid_separates_of_resolution` : the matching sufficiency — `R² ≤ 2^t`
  cells always separate distinct fractions of denominator `≤ R`;
* `QubitTrade.grid_threshold_two_sided` : the two halves packaged.  The critical
  number of cells lies between `R²/4` and `R²`, so `t_min = 2 log₂ R + O(1)`.

The quadratic threshold is therefore two-sided *in the grid model as well*: no
measurement model weakens the `2 log₂ r` requirement.
-/

namespace QubitTrade

open Finset

/-! ## Coprime pairs in a square -/

/-- The coprime pairs of a box: `{(a,b) : 1 ≤ a,b ≤ R, gcd a b = 1}`. -/
def coprimePairs (R : ℕ) : Finset (ℕ × ℕ) :=
  ((Finset.Icc 1 R) ×ˢ (Finset.Icc 1 R)).filter fun p => Nat.Coprime p.1 p.2

theorem card_box (R : ℕ) : ((Finset.Icc 1 R) ×ˢ (Finset.Icc 1 R)).card = R ^ 2 := by
  rw [Finset.card_product, Nat.card_Icc, Nat.add_sub_cancel, sq]

theorem card_coprimePairs_le (R : ℕ) : (coprimePairs R).card ≤ R ^ 2 := by
  calc (coprimePairs R).card ≤ ((Finset.Icc 1 R) ×ˢ (Finset.Icc 1 R)).card :=
        Finset.card_filter_le _ _
    _ = R ^ 2 := card_box R

/-- Rescaling by the gcd identifies the pairs of gcd `d` inside `[1,R]²` with the
coprime pairs inside `[1, ⌊R/d⌋]²`. -/
theorem card_gcd_fiber (R d : ℕ) (hd : 1 ≤ d) :
    (((Finset.Icc 1 R) ×ˢ (Finset.Icc 1 R)).filter
      (fun p => Nat.gcd p.1 p.2 = d)).card = (coprimePairs (R / d)).card := by
  apply Finset.card_bij (fun p _ => (p.1 / d, p.2 / d))
  · rintro ⟨a, b⟩ hp
    simp only [Finset.mem_filter, Finset.mem_product, Finset.mem_Icc] at hp
    obtain ⟨⟨⟨ha1, ha2⟩, hb1, hb2⟩, hg⟩ := hp
    have hda : d ∣ a := hg ▸ Nat.gcd_dvd_left a b
    have hdb : d ∣ b := hg ▸ Nat.gcd_dvd_right a b
    simp only [coprimePairs, Finset.mem_filter, Finset.mem_product, Finset.mem_Icc]
    refine ⟨⟨⟨?_, ?_⟩, ?_, ?_⟩, ?_⟩
    · exact Nat.one_le_div_iff (by omega) |>.mpr (Nat.le_of_dvd (by omega) hda)
    · exact Nat.div_le_div_right ha2
    · exact Nat.one_le_div_iff (by omega) |>.mpr (Nat.le_of_dvd (by omega) hdb)
    · exact Nat.div_le_div_right hb2
    · have := Nat.coprime_div_gcd_div_gcd (m := a) (n := b) (by rw [hg]; omega)
      rwa [hg] at this
  · rintro ⟨a, b⟩ hp ⟨a', b'⟩ hp' heq
    simp only [Finset.mem_filter, Finset.mem_product, Finset.mem_Icc] at hp hp'
    have hda : d ∣ a := hp.2 ▸ Nat.gcd_dvd_left a b
    have hdb : d ∣ b := hp.2 ▸ Nat.gcd_dvd_right a b
    have hda' : d ∣ a' := hp'.2 ▸ Nat.gcd_dvd_left a' b'
    have hdb' : d ∣ b' := hp'.2 ▸ Nat.gcd_dvd_right a' b'
    simp only [Prod.mk.injEq] at heq ⊢
    constructor
    · rw [← Nat.div_mul_cancel hda, ← Nat.div_mul_cancel hda', heq.1]
    · rw [← Nat.div_mul_cancel hdb, ← Nat.div_mul_cancel hdb', heq.2]
  · rintro ⟨a, b⟩ hp
    simp only [coprimePairs, Finset.mem_filter, Finset.mem_product, Finset.mem_Icc] at hp
    obtain ⟨⟨⟨ha1, ha2⟩, hb1, hb2⟩, hg⟩ := hp
    refine ⟨(d * a, d * b), ?_, ?_⟩
    · simp only [Finset.mem_filter, Finset.mem_product, Finset.mem_Icc]
      refine ⟨⟨⟨by nlinarith, ?_⟩, by nlinarith, ?_⟩, ?_⟩
      · calc d * a ≤ d * (R / d) := Nat.mul_le_mul_left _ ha2
          _ ≤ R := by rw [Nat.mul_comm]; exact Nat.div_mul_le_self R d
      · calc d * b ≤ d * (R / d) := Nat.mul_le_mul_left _ hb2
          _ ≤ R := by rw [Nat.mul_comm]; exact Nat.div_mul_le_self R d
      · rw [Nat.gcd_mul_left, hg, mul_one]
    · simp [Nat.mul_div_cancel_left _ (show 0 < d by omega)]

/-- **The gcd fibration identity.**  Every lattice point of the box has a gcd, and
dividing by it is a bijection onto a smaller box of coprime pairs. -/
theorem sq_eq_sum_card_coprimePairs (R : ℕ) :
    R ^ 2 = ∑ d ∈ Finset.Icc 1 R, (coprimePairs (R / d)).card := by
  rw [← card_box R]
  rw [Finset.card_eq_sum_card_fiberwise
    (f := fun p : ℕ × ℕ => Nat.gcd p.1 p.2) (t := Finset.Icc 1 R) ?_]
  · exact Finset.sum_congr rfl fun d hd => card_gcd_fiber R d (Finset.mem_Icc.mp hd).1
  · rintro ⟨a, b⟩ hp
    simp only [Finset.mem_coe, Finset.mem_product, Finset.mem_Icc] at hp
    obtain ⟨⟨ha1, ha2⟩, hb1, hb2⟩ := hp
    have hg : 0 < Nat.gcd a b := Nat.gcd_pos_of_pos_left _ (by omega)
    have hle : Nat.gcd a b ≤ a := Nat.le_of_dvd (by omega) (Nat.gcd_dvd_left a b)
    simpa only [Finset.mem_coe, Finset.mem_Icc] using
      (Finset.mem_Icc.mpr ⟨hg, by omega⟩ : Nat.gcd a b ∈ Finset.Icc 1 R)

/-! ## The elementary tail bound `Σ_{d ≥ 2} d⁻² ≤ 3/4` -/
private theorem inv_sq_succ_le (x : ℚ) (h : 0 < x) : ((x + 1) ^ 2)⁻¹ ≤ x⁻¹ - (x + 1)⁻¹ := by
  have h1 : (0:ℚ) < x + 1 := by linarith
  have e : x⁻¹ - (x + 1)⁻¹ = (x * (x + 1))⁻¹ := by field_simp; ring
  rw [e, inv_le_inv₀ (by positivity) (by positivity)]
  nlinarith

/-- `Σ_{d=2}^{R} d^{-2} ≤ 3/4 − 1/R`: the classical telescoping bound, by induction. -/
theorem sum_inv_sq_le {R : ℕ} (hR : 2 ≤ R) :
    ∑ d ∈ Finset.Icc 2 R, ((d : ℚ) ^ 2)⁻¹ ≤ 3 / 4 - (R : ℚ)⁻¹ := by
  induction R with
  | zero => omega
  | succ n ih =>
    rcases Nat.lt_or_ge n 2 with hn | hn
    · interval_cases n
      · omega
      · norm_num [Finset.Icc_self]
    · have hstep := ih hn
      rw [Finset.sum_Icc_succ_top (by omega)]
      have hn0 : (0 : ℚ) < (n : ℚ) := by exact_mod_cast Nat.lt_of_lt_of_le (by norm_num) hn
      have key := inv_sq_succ_le (n : ℚ) hn0
      push_cast
      calc ∑ d ∈ Finset.Icc 2 n, ((d:ℚ)^2)⁻¹ + (((n:ℚ)+1)^2)⁻¹
          ≤ (3/4 - (n:ℚ)⁻¹) + ((n:ℚ)⁻¹ - ((n:ℚ)+1)⁻¹) := by gcongr
        _ = 3/4 - ((n:ℚ)+1)⁻¹ := by ring

/-- The tail of the fibration identity occupies at most `3/4` of the box. -/
theorem tail_sum_le {R : ℕ} (hR : 2 ≤ R) :
    4 * ∑ d ∈ Finset.Icc 2 R, (R / d) ^ 2 ≤ 3 * R ^ 2 := by
  have hsum := sum_inv_sq_le hR
  have hQ : ((4 * ∑ d ∈ Finset.Icc 2 R, (R / d) ^ 2 : ℕ) : ℚ) ≤ ((3 * R ^ 2 : ℕ) : ℚ) := by
    push_cast
    have hterm : ∀ d ∈ Finset.Icc 2 R, ((R / d : ℕ) : ℚ) ^ 2 ≤ (R:ℚ)^2 * ((d:ℚ)^2)⁻¹ := by
      intro d hd
      have hd2 : 2 ≤ d := (Finset.mem_Icc.mp hd).1
      have hdpos : (0:ℚ) < (d:ℚ) := by exact_mod_cast Nat.lt_of_lt_of_le (by norm_num) hd2
      have h1 : ((R / d : ℕ) : ℚ) ≤ (R:ℚ)/(d:ℚ) := Nat.cast_div_le
      have h0 : (0:ℚ) ≤ ((R / d : ℕ) : ℚ) := by positivity
      calc ((R / d : ℕ) : ℚ) ^ 2 ≤ ((R:ℚ)/(d:ℚ))^2 := by nlinarith
        _ = (R:ℚ)^2 * ((d:ℚ)^2)⁻¹ := by field_simp
    calc (4:ℚ) * ∑ d ∈ Finset.Icc 2 R, ((R / d : ℕ):ℚ) ^ 2
        ≤ 4 * ∑ d ∈ Finset.Icc 2 R, (R:ℚ)^2 * ((d:ℚ)^2)⁻¹ := by
          gcongr with d hd; exact hterm d hd
      _ = 4 * ((R:ℚ)^2 * ∑ d ∈ Finset.Icc 2 R, ((d:ℚ)^2)⁻¹) := by rw [← Finset.mul_sum]
      _ ≤ 4 * ((R:ℚ)^2 * (3/4)) := by
          have hRpos : (0:ℚ) ≤ (R:ℚ)^2 := by positivity
          have hRinv : (0:ℚ) ≤ (R:ℚ)⁻¹ := by positivity
          gcongr
          linarith
      _ = 3 * (R:ℚ)^2 := by ring
  exact_mod_cast hQ

/-- **The Farey count, elementary form.**  At least a quarter of the lattice points of
`[1,R]²` are coprime pairs: `R² ≤ 4 · C(R)`.  (The truth is `C(R) ~ (6/π²)R²`; the
constant is irrelevant for the threshold, only the *quadratic* growth matters.) -/
theorem four_mul_card_coprimePairs (R : ℕ) : R ^ 2 ≤ 4 * (coprimePairs R).card := by
  rcases Nat.lt_or_ge R 2 with hR | hR
  · interval_cases R
    · simp
    · have : (1, 1) ∈ coprimePairs 1 := by decide
      have := Finset.card_pos.mpr ⟨(1,1), this⟩
      omega
  · have hsplit : ∑ d ∈ Finset.Icc 1 R, (coprimePairs (R / d)).card
        = (coprimePairs R).card + ∑ d ∈ Finset.Icc 2 R, (coprimePairs (R / d)).card := by
      rw [show Finset.Icc 1 R = insert 1 (Finset.Icc 2 R) by ext x; simp; omega,
        Finset.sum_insert (by simp), Nat.div_one]
    have hid := sq_eq_sum_card_coprimePairs R
    have htail : ∑ d ∈ Finset.Icc 2 R, (coprimePairs (R / d)).card
        ≤ ∑ d ∈ Finset.Icc 2 R, (R / d) ^ 2 :=
      Finset.sum_le_sum fun d _ => card_coprimePairs_le (R / d)
    have hbound := tail_sum_le hR
    omega

/-! ## From the Farey count to grid ambiguity -/

/-- The Stern–Brocot injection of a coprime pair into the fractions of `(0,1)`:
`(a,b) ↦ a/(a+b)`, which is already in lowest terms. -/
def fareyFrac (p : ℕ × ℕ) : ℚ := (p.1 : ℚ) / ((p.1 + p.2 : ℕ) : ℚ)

theorem fareyFrac_num_den {a b : ℕ} (ha : 1 ≤ a) (h : Nat.Coprime a b) :
    (fareyFrac (a, b)).num = a ∧ (fareyFrac (a, b)).den = a + b := by
  have hco : Nat.Coprime a (a + b) := by
    unfold Nat.Coprime at *; rw [Nat.gcd_self_add_right]; exact h
  have hb0 : (0:ℤ) < ((a + b : ℕ) : ℤ) := by exact_mod_cast (by omega : 0 < a + b)
  have h' : Nat.Coprime ((a:ℕ):ℤ).natAbs (((a + b : ℕ) : ℤ)).natAbs := by
    rw [Int.natAbs_natCast, Int.natAbs_natCast]; exact hco
  refine ⟨?_, ?_⟩
  · simpa [fareyFrac] using Rat.num_div_eq_of_coprime hb0 h'
  · have h2 : (((fareyFrac (a, b)).den : ℤ)) = ((a + b : ℕ) : ℤ) := by
      simpa [fareyFrac] using Rat.den_div_eq_of_coprime hb0 h'
    exact_mod_cast h2

/-- Distinct coprime pairs give distinct fractions. -/
theorem fareyFrac_inj {a b a' b' : ℕ} (ha : 1 ≤ a) (ha' : 1 ≤ a')
    (h : Nat.Coprime a b) (h' : Nat.Coprime a' b')
    (heq : fareyFrac (a, b) = fareyFrac (a', b')) : a = a' ∧ b = b' := by
  obtain ⟨hn, hd⟩ := fareyFrac_num_den ha h
  obtain ⟨hn', hd'⟩ := fareyFrac_num_den ha' h'
  rw [heq] at hn hd
  rw [hn'] at hn
  rw [hd'] at hd
  omega

theorem fareyFrac_pos {a b : ℕ} (ha : 1 ≤ a) : 0 < fareyFrac (a, b) := by
  have ha' : (0:ℚ) < (a:ℚ) := by exact_mod_cast ha
  have hs : (0:ℚ) < ((a + b : ℕ) : ℚ) := by
    have : 0 < a + b := by omega
    exact_mod_cast this
  unfold fareyFrac
  exact div_pos ha' hs

theorem fareyFrac_lt_one {a b : ℕ} (hb : 1 ≤ b) : fareyFrac (a, b) < 1 := by
  have hb' : (0:ℚ) < (b:ℚ) := by exact_mod_cast hb
  have hs : (0:ℚ) < ((a + b : ℕ) : ℚ) := by
    have : 0 < a + b := by omega
    exact_mod_cast this
  unfold fareyFrac
  rw [div_lt_one hs]
  push_cast
  linarith

/-- The reading of a `t`-bit *grid* register: the index of the dyadic cell containing
the phase `q`.  Two phases are confusable exactly when their cells agree. -/
def gridCell (t : ℕ) (q : ℚ) : ℤ := ⌊(2:ℚ) ^ t * q⌋

theorem gridCell_lt {t : ℕ} {q : ℚ} (h0 : 0 < q) (h1 : q < 1) :
    0 ≤ gridCell t q ∧ gridCell t q < 2 ^ t := by
  have hp : (0:ℚ) < (2:ℚ) ^ t := by positivity
  constructor
  · exact Int.floor_nonneg.mpr (by positivity)
  · rw [gridCell, Int.floor_lt]
    push_cast
    nlinarith

/-- **Grid ambiguity at the quadratic scale.**  If the register has fewer than
`R²/4` cells then two *distinct* reduced fractions of denominator `≤ 2R` share a
cell, so the truncated register cannot tell them apart. -/
theorem grid_ambiguous {R t : ℕ} (h : 4 * 2 ^ t < R ^ 2) :
    ∃ q₁ q₂ : ℚ, q₁ ≠ q₂ ∧ 0 < q₁ ∧ q₁ < 1 ∧ 0 < q₂ ∧ q₂ < 1 ∧
      q₁.den ≤ 2 * R ∧ q₂.den ≤ 2 * R ∧ gridCell t q₁ = gridCell t q₂ := by
  have hcard : (Finset.range (2 ^ t)).card < (coprimePairs R).card := by
    have := four_mul_card_coprimePairs R
    simp only [Finset.card_range]
    omega
  have hmaps : ∀ p ∈ coprimePairs R, (gridCell t (fareyFrac p)).toNat ∈ Finset.range (2 ^ t) := by
    rintro ⟨a, b⟩ hp
    simp only [coprimePairs, Finset.mem_filter, Finset.mem_product, Finset.mem_Icc] at hp
    obtain ⟨⟨⟨ha1, _⟩, hb1, _⟩, _⟩ := hp
    obtain ⟨hge, hlt⟩ := gridCell_lt (t := t) (fareyFrac_pos (b := b) ha1)
      (fareyFrac_lt_one (a := a) hb1)
    rw [show ((2:ℤ) ^ t) = ((2 ^ t : ℕ) : ℤ) by push_cast; ring] at hlt
    simp only [Finset.mem_range]
    omega
  obtain ⟨p, hp, p', hp', hne, hcell⟩ :=
    Finset.exists_ne_map_eq_of_card_lt_of_maps_to hcard hmaps
  obtain ⟨a, b⟩ := p
  obtain ⟨a', b'⟩ := p'
  simp only [coprimePairs, Finset.mem_filter, Finset.mem_product, Finset.mem_Icc] at hp hp'
  obtain ⟨⟨⟨ha1, ha2⟩, hb1, hb2⟩, hco⟩ := hp
  obtain ⟨⟨⟨ha1', ha2'⟩, hb1', hb2'⟩, hco'⟩ := hp'
  obtain ⟨hge, hlt⟩ := gridCell_lt (t := t) (fareyFrac_pos (b := b) ha1)
    (fareyFrac_lt_one (a := a) hb1)
  obtain ⟨hge', hlt'⟩ := gridCell_lt (t := t) (fareyFrac_pos (b := b') ha1')
    (fareyFrac_lt_one (a := a') hb1')
  refine ⟨fareyFrac (a, b), fareyFrac (a', b'), ?_, fareyFrac_pos ha1, fareyFrac_lt_one hb1,
    fareyFrac_pos ha1', fareyFrac_lt_one hb1', ?_, ?_, ?_⟩
  · intro heq
    obtain ⟨rfl, rfl⟩ := fareyFrac_inj ha1 ha1' hco hco' heq
    exact hne rfl
  · rw [(fareyFrac_num_den ha1 hco).2]; omega
  · rw [(fareyFrac_num_den ha1' hco').2]; omega
  · omega

/-- **The grid threshold is quadratic.**  If a `t`-bit grid register separates every
pair of distinct reduced fractions of denominator `≤ D` in `(0,1)`, then
`2 log₂ D < t + 6`: the register must carry `2 log₂ D − O(1)` bits.  This upgrades
`cf_target_ambiguous` from the tolerance model to the strictest grid model. -/
theorem grid_threshold_quadratic {D t : ℕ} (hD : 2 ≤ D)
    (hsep : ∀ q₁ q₂ : ℚ, 0 < q₁ → q₁ < 1 → 0 < q₂ → q₂ < 1 → q₁.den ≤ D → q₂.den ≤ D →
      gridCell t q₁ = gridCell t q₂ → q₁ = q₂) :
    2 * Nat.log 2 D < t + 6 := by
  set R := D / 2 with hR
  have hR1 : 1 ≤ R := by omega
  have hDR : D ≤ 2 * R + 1 := by omega
  have hno : ¬ (4 * 2 ^ t < R ^ 2) := by
    intro hlt
    obtain ⟨q₁, q₂, hne, h1, h2, h3, h4, hd1, hd2, hcell⟩ := grid_ambiguous hlt
    exact hne (hsep q₁ q₂ h1 h2 h3 h4 (by omega) (by omega) hcell)
  have hRsq : R ^ 2 ≤ 4 * 2 ^ t := by omega
  have hDsq : D ^ 2 < 2 ^ (t + 6) := by
    have h9 : D ^ 2 ≤ 9 * R ^ 2 := by nlinarith
    have h36 : (9 : ℕ) * R ^ 2 ≤ 36 * 2 ^ t := by
      calc 9 * R ^ 2 ≤ 9 * (4 * 2 ^ t) := Nat.mul_le_mul_left 9 hRsq
        _ = 36 * 2 ^ t := by ring
    have hpow : (2:ℕ) ^ (t + 6) = 64 * 2 ^ t := by ring
    have hpos : 0 < (2:ℕ) ^ t := Nat.two_pow_pos t
    omega
  have hD0 : D ≠ 0 := by omega
  have hlog : (2:ℕ) ^ (2 * Nat.log 2 D) ≤ D ^ 2 := by
    rw [mul_comm, pow_mul]
    exact Nat.pow_le_pow_left (Nat.pow_log_le_self 2 hD0) 2
  by_contra hcon
  push_neg at hcon
  have : (2:ℕ) ^ (t + 6) ≤ 2 ^ (2 * Nat.log 2 D) := Nat.pow_le_pow_right (by norm_num) hcon
  omega

/-! ## Back to order finding: the truncated outcome itself is ambiguous -/

private theorem floor_natCast_div (m n : ℕ) : ⌊((m : ℚ) / (n : ℚ))⌋ = ((m / n : ℕ) : ℤ) := by
  rw [Int.floor_div_natCast, Int.floor_natCast, Int.ofNat_ediv_ofNat]

/-- The grid cell of an order fraction *is* the truncated register outcome of
`SupportCollapse.lean`: the two models agree on the nose. -/
theorem gridCell_orderFrac (t r k : ℕ) :
    gridCell t (orderFrac k r) = (truncOutcome t r k : ℤ) := by
  have h : (2:ℚ) ^ t * orderFrac k r = ((2 ^ t * k : ℕ) : ℚ) / ((r : ℕ) : ℚ) := by
    unfold orderFrac
    push_cast
    ring
  rw [gridCell, h, floor_natCast_div, truncOutcome]

/-- **Order-level grid ambiguity.**  Below the quadratic threshold two genuinely
different order fractions `k/r ≠ k'/r'`, with orders bounded by `2R`, produce the
*same* truncated register outcome.  No post-processing whatsoever can separate
them, and this is in the exact dyadic-grid model — the strictest one. -/
theorem truncOutcome_ambiguous {R t : ℕ} (h : 4 * 2 ^ t < R ^ 2) :
    ∃ k r k' r' : ℕ, 0 < k ∧ k < r ∧ r ≤ 2 * R ∧ 0 < k' ∧ k' < r' ∧ r' ≤ 2 * R ∧
      orderFrac k r ≠ orderFrac k' r' ∧ truncOutcome t r k = truncOutcome t r' k' := by
  obtain ⟨q₁, q₂, hne, hp1, hl1, hp2, hl2, hd1, hd2, hcell⟩ := grid_ambiguous h
  have hrepr : ∀ q : ℚ, 0 < q → q < 1 →
      0 < q.num.toNat ∧ q.num.toNat < q.den ∧ orderFrac q.num.toNat q.den = q := by
    intro q h0 h1
    have hnum : 0 < q.num := Rat.num_pos.mpr h0
    have hden : 0 < q.den := q.pos
    have hlt : q.num < (q.den : ℤ) := Rat.lt_one_iff_num_lt_denom.mp h1
    refine ⟨by omega, by omega, ?_⟩
    unfold orderFrac
    rw [show ((q.num.toNat : ℕ) : ℚ) = (q.num : ℚ) by
      have : (q.num.toNat : ℤ) = q.num := Int.toNat_of_nonneg (le_of_lt hnum)
      exact_mod_cast congrArg (fun z : ℤ => (z : ℚ)) this]
    exact Rat.num_div_den q
  obtain ⟨hk1, hkr1, hq1⟩ := hrepr q₁ hp1 hl1
  obtain ⟨hk2, hkr2, hq2⟩ := hrepr q₂ hp2 hl2
  refine ⟨q₁.num.toNat, q₁.den, q₂.num.toNat, q₂.den, hk1, hkr1, hd1, hk2, hkr2, hd2, ?_, ?_⟩
  · rw [hq1, hq2]; exact hne
  · have e1 := gridCell_orderFrac t q₁.den q₁.num.toNat
    have e2 := gridCell_orderFrac t q₂.den q₂.num.toNat
    rw [hq1] at e1
    rw [hq2] at e2
    omega

/-! ## The matching sufficiency: the grid threshold is two-sided -/

/-- **Grid separation above the quadratic threshold.**  Once the register has at
least `R²` cells, *distinct* reduced fractions of denominator `≤ R` always land in
distinct cells: `2 log₂ R` bits suffice, in the grid model too. -/
theorem grid_separates_of_resolution {R t : ℕ} (hRt : R ^ 2 ≤ 2 ^ t) {q₁ q₂ : ℚ}
    (h1 : q₁.den ≤ R) (h2 : q₂.den ≤ R) (hcell : gridCell t q₁ = gridCell t q₂) :
    q₁ = q₂ := by
  by_contra hne
  -- the two phases are in the same cell, hence closer than one cell width
  have hclose : |(2:ℚ) ^ t * q₁ - (2:ℚ) ^ t * q₂| < 1 := by
    have f1 := Int.floor_le ((2:ℚ) ^ t * q₁)
    have f2 := Int.lt_floor_add_one ((2:ℚ) ^ t * q₁)
    have f3 := Int.floor_le ((2:ℚ) ^ t * q₂)
    have f4 := Int.lt_floor_add_one ((2:ℚ) ^ t * q₂)
    rw [gridCell, gridCell] at hcell
    rw [hcell] at f1 f2
    rw [abs_lt]
    constructor <;> linarith
  have hpow : (0:ℚ) < (2:ℚ) ^ t := by positivity
  have hdist : |q₁ - q₂| < ((2:ℚ) ^ t)⁻¹ := by
    rw [← mul_sub, abs_mul, abs_of_pos hpow] at hclose
    rw [inv_eq_one_div, lt_div_iff₀ hpow]
    linarith
  -- but Farey separation keeps them `1/R²` apart
  have hsep : (((q₁.den : ℝ) * q₂.den)⁻¹ : ℝ) ≤ |(q₁ : ℝ) - (q₂ : ℝ)| :=
    rat_den_separation q₁ q₂ hne
  have hd1 : (0:ℝ) < (q₁.den : ℝ) := by exact_mod_cast q₁.pos
  have hd2 : (0:ℝ) < (q₂.den : ℝ) := by exact_mod_cast q₂.pos
  have hR : (0:ℝ) < (R:ℝ) := by
    have : 0 < R := lt_of_lt_of_le q₁.pos h1
    exact_mod_cast this
  have hbig : ((R:ℝ) ^ 2)⁻¹ ≤ |(q₁ : ℝ) - (q₂ : ℝ)| := by
    refine le_trans ?_ hsep
    have c1 : (q₁.den : ℝ) ≤ R := by exact_mod_cast h1
    have c2 : (q₂.den : ℝ) ≤ R := by exact_mod_cast h2
    exact inv_anti₀ (by positivity) (by nlinarith)
  have hdistR : |(q₁ : ℝ) - (q₂ : ℝ)| < (((2:ℝ)) ^ t)⁻¹ := by
    have : ((|q₁ - q₂| : ℚ) : ℝ) < ((((2:ℚ) ^ t)⁻¹ : ℚ) : ℝ) := by exact_mod_cast hdist
    push_cast at this
    simpa using this
  have hRt' : ((R:ℝ)) ^ 2 ≤ (2:ℝ) ^ t := by exact_mod_cast hRt
  have hpowR : (0:ℝ) < (2:ℝ) ^ t := by positivity
  have : (((2:ℝ)) ^ t)⁻¹ ≤ ((R:ℝ) ^ 2)⁻¹ := inv_anti₀ (by positivity) hRt'
  linarith

/-- **The grid threshold, two-sided.**  For the exact dyadic-grid register the
critical width sits between `R²/4` and `R²` cells: `2 log₂ R + O(1)` bits are both
necessary and sufficient to resolve the order fractions of denominator `≤ R`.
This is the QUBIT-TRADE measurement `t_min ≈ 2 log₂ r`, in the strictest model. -/
theorem grid_threshold_two_sided (R t : ℕ) :
    (R ^ 2 ≤ 2 ^ t → ∀ q₁ q₂ : ℚ, q₁.den ≤ R → q₂.den ≤ R →
        gridCell t q₁ = gridCell t q₂ → q₁ = q₂) ∧
      (4 * 2 ^ t < R ^ 2 → ∃ q₁ q₂ : ℚ, q₁ ≠ q₂ ∧ q₁.den ≤ 2 * R ∧ q₂.den ≤ 2 * R ∧
        gridCell t q₁ = gridCell t q₂) := by
  refine ⟨fun h q₁ q₂ h1 h2 hc => grid_separates_of_resolution h h1 h2 hc, fun h => ?_⟩
  obtain ⟨q₁, q₂, hne, _, _, _, _, hd1, hd2, hcell⟩ := grid_ambiguous h
  exact ⟨q₁, q₂, hne, hd1, hd2, hcell⟩

end QubitTrade