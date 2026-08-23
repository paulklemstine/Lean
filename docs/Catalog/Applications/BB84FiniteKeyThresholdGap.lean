import Mathlib
import Applications.BB84FiniteKeyBounds

/-!
# The Break-Even Block Size Diverges Quadratically in the Threshold Gap

`Applications.BB84FiniteKeyBounds` shows that at `Q = 11 %` the certified
finite-key length is non-positive below `n = 10¹¹`.  That looks like an artifact
of one particular QBER.  This file proves it is a *structural law*:

> For **every** QBER `Q` in `[10 %, Q*)`, every rational rate certificate `rho`
> valid at `Q`, and every `n` at which the finite-key length is positive,
> `n ≥ C²·ln(1/ε) / (44·(Q* − Q)²)`.

So the break-even sample size blows up at least like the inverse *square* of the
distance to the asymptotic threshold `Q*`.  Operating "just below threshold" is
therefore never a viable deployment strategy — the asymptotic threshold is the
wrong figure of merit, quantitatively and universally, not just at `11 %`.

The bridge is a Lipschitz bound for the binary entropy on `[1/10, 1/2]` proved by
the same one-dimensional monotonicity technique as the Padé bound of the previous
file: `p ↦ log 9 · p − binEntropy p` has derivative `log 9 − log((1−p)/p) ≥ 0`
there.  Combined with `r(Q*) = 0` it gives `r(Q) ≤ 2 log 9 · (Q* − Q)`.

-- !-- Lab Notes -- !--
HYPOTHESIS (Hypothesizer): (H4) The `O(√n)` statistical correction and the
  *linear* vanishing of the asymptotic rate at threshold interact to produce an
  inverse-square divergence of the break-even block size: `n*(Q) ≍ (Q*−Q)⁻²`.
  (H5) The constant can be certified from purely rational data: a Lipschitz
  constant for `binEntropy` on `[1/10, 1/2]` and the catalog's rational enclosure
  of `Q*`.
EXPERIMENT (Experimenter): Numerically `r'(Q) = -2 log((1-Q)/Q)`, so near
  `Q* ≈ 0.110028` the rate falls off at `4.16` nats per unit QBER (`6.01` bits).
  Predicted break-even at `C = 10`, `ε = 2⁻⁵⁰`: `n* ≈ C²·ln(1/ε)/(6.01·(Q*−Q))²`.
  At `Q = 0.11` (gap `2.8·10⁻⁵`) this predicts `n* ≈ 1.2·10¹¹`, matching the
  direct computation `1.25·10¹¹` of the previous file to within 5 %.  The proved
  constant `44` (from `log 3 ≤ 2 log 2 − 1/4` and `log 2 ≥ 0.693`) is a certified
  over-estimate of `(2 log 9 / log 2)² = 40.2`.
ANALYSIS (Analyst): The `(Q*−Q)⁻²` law needs only that the rate vanishes at most
  *linearly* at the threshold, i.e. an upper Lipschitz bound; no lower bound on
  the derivative and no second-order information is required.  This is why the
  argument is robust to the crude constant.
CRITIQUE (Critic): The bound is stated for `Q ≥ 1/10` because the Lipschitz
  constant `log((1-p)/p)` blows up as `p → 0`; that is exactly the regime where
  the rate is large and finite-key corrections are irrelevant, so nothing of
  interest is lost.  The hypothesis `secureKeyRate Q* = 0` is not vacuous: the
  catalog proves such a `Q*` exists and is unique in `[0, 1/2]`.
SYNTHESIS (PI): `binEntropy_lipschitz_upper` → `secureKeyRate_le_gap` →
  `breakeven_ge_of_gap` → the certified instance at `Q = 11 %`.
-/

open Real Set Finset

noncomputable section

namespace BB84
namespace FiniteKey

/-! ## 1. A certified Lipschitz constant for the binary entropy on `[1/10, 1/2]` -/

/-- `log 3 ≤ 2 log 2 − 1/4 < 1.1364`, from `log(4/3) ≥ 2/7` (Padé). -/
theorem log_three_le : Real.log 3 ≤ 2 * Real.log 2 - 1 / 4 := by
  have hp : 2 * ((4:ℝ)/3 - 1) / ((4:ℝ)/3 + 1) ≤ Real.log (4/3) :=
    log_pade_lower (4/3) (by norm_num)
  have hval : 2 * ((4:ℝ)/3 - 1) / ((4:ℝ)/3 + 1) = 2 / 7 := by norm_num
  rw [hval] at hp
  have hsplit : Real.log (4/3) = 2 * Real.log 2 - Real.log 3 := by
    rw [Real.log_div (by norm_num) (by norm_num),
      show (4:ℝ) = 2 ^ 2 by norm_num, Real.log_pow]
    push_cast
    ring
  rw [hsplit] at hp
  linarith

/-- `log 9 ≤ 2.2726`. -/
theorem log_nine_le : Real.log 9 ≤ 2.2726 := by
  have h9 : Real.log 9 = 2 * Real.log 3 := by
    rw [show (9:ℝ) = 3 ^ 2 by norm_num, Real.log_pow]
    push_cast; ring
  have h2 : Real.log 2 < 0.6931471808 := Real.log_two_lt_d9
  rw [h9]
  linarith [log_three_le]

/-- **Lipschitz bound for the binary entropy on `[1/10, 1/2]`.**
For `1/10 ≤ x ≤ y ≤ 1/2`, `binEntropy y − binEntropy x ≤ log 9 · (y − x)`.
Proved by monotonicity of `g p = log 9 · p − binEntropy p`, whose derivative
`log 9 − log((1−p)/p)` is nonnegative there. -/
theorem binEntropy_lipschitz_upper {x y : ℝ} (hx : 1 / 10 ≤ x) (hxy : x ≤ y)
    (hy : y ≤ 1 / 2) :
    Real.binEntropy y - Real.binEntropy x ≤ Real.log 9 * (y - x) := by
  have hmono : MonotoneOn (fun p => Real.log 9 * p - Real.binEntropy p)
      (Set.Icc (1/10 : ℝ) (1/2)) := by
    apply monotoneOn_of_deriv_nonneg (convex_Icc _ _)
    · exact (continuousOn_const.mul continuousOn_id).sub
        (Real.binEntropy_continuous.continuousOn)
    · intro t ht
      rw [interior_Icc] at ht
      have ht0 : t ≠ 0 := by intro h; rw [h] at ht; linarith [ht.1]
      have ht1 : t ≠ 1 := by intro h; rw [h] at ht; linarith [ht.2]
      exact (((hasDerivAt_const t (Real.log 9)).mul (hasDerivAt_id t)).sub
        (Real.hasDerivAt_binEntropy ht0 ht1)).differentiableAt.differentiableWithinAt
    · intro t ht
      rw [interior_Icc] at ht
      have ht0 : t ≠ 0 := by intro h; rw [h] at ht; linarith [ht.1]
      have ht1 : t ≠ 1 := by intro h; rw [h] at ht; linarith [ht.2]
      have hd : HasDerivAt (fun p => Real.log 9 * p - Real.binEntropy p)
          (Real.log 9 - (Real.log (1 - t) - Real.log t)) t := by
        simpa using ((hasDerivAt_const t (Real.log 9)).mul (hasDerivAt_id t)).sub
          (Real.hasDerivAt_binEntropy ht0 ht1)
      rw [hd.deriv]
      have htpos : (0:ℝ) < t := by linarith [ht.1]
      have h1t : (0:ℝ) < 1 - t := by linarith [ht.2]
      have hratio : Real.log (1 - t) - Real.log t ≤ Real.log 9 := by
        rw [← Real.log_div (ne_of_gt h1t) (ne_of_gt htpos)]
        apply Real.log_le_log (by positivity)
        rw [div_le_iff₀ htpos]
        linarith [ht.1]
      linarith
  have hxmem : x ∈ Set.Icc (1/10 : ℝ) (1/2) := ⟨hx, le_trans hxy hy⟩
  have hymem : y ∈ Set.Icc (1/10 : ℝ) (1/2) := ⟨le_trans hx hxy, hy⟩
  have := hmono hxmem hymem hxy
  simp only at this
  linarith

/-- **Linear vanishing at the threshold.**  If `Q*` is a zero of the asymptotic
key rate in `[Q, 1/2]` and `Q ≥ 1/10`, then `r(Q) ≤ 2 log 9 · (Q* − Q)` nats:
the rate cannot vanish faster than linearly as the threshold is approached. -/
theorem secureKeyRate_le_gap {Q Qstar : ℝ} (hQ : 1 / 10 ≤ Q) (hQQ : Q ≤ Qstar)
    (hQs : Qstar ≤ 1 / 2) (hzero : secureKeyRate Qstar = 0) :
    secureKeyRate Q ≤ 2 * Real.log 9 * (Qstar - Q) := by
  have hlip := binEntropy_lipschitz_upper hQ hQQ hQs
  have h0 : Real.log 2 - 2 * Real.binEntropy Qstar = 0 := hzero
  have hQdef : secureKeyRate Q = Real.log 2 - 2 * Real.binEntropy Q := rfl
  rw [hQdef]
  linarith

/-! ## 2. The break-even block size -/

/-- **Quadratic divergence of the break-even block size.**
Let `Q ∈ [10 %, Q*)` be any QBER below the asymptotic threshold `Q*`, let `rho`
be *any* rational rate certificate valid at `Q` (i.e. `rho ≤ r(Q)/log 2` bits per
sifted bit), and let `C > 0` and `ε` be the finite-key parameters.
Then any block size `n` at which the finite-key length is positive satisfies

`n ≥ C² · ln(1/ε) / (44 · (Q* − Q)²)`.

The break-even block size therefore diverges at least quadratically as `Q → Q*`. -/
theorem breakeven_ge_of_gap {C rho : ℚ} (hC : 0 < C) (hrho : 0 < rho) {eps : ℝ}
    {Q Qstar : ℝ} (hQ : 1 / 10 ≤ Q) (hQQ : Q ≤ Qstar) (hQs : Qstar ≤ 1 / 2)
    (hzero : secureKeyRate Qstar = 0)
    (hcert : (rho : ℝ) ≤ secureKeyRate Q / Real.log 2)
    {n : ℕ} (hpos : 0 < finiteKeyBits rho C n eps) :
    (C : ℝ) ^ 2 * Real.log (1 / eps) / (44 * (Qstar - Q) ^ 2) ≤ (n : ℝ) := by
  have hC' : (0:ℝ) < (C : ℝ) := by exact_mod_cast hC
  have hrho' : (0:ℝ) < (rho : ℝ) := by exact_mod_cast hrho
  have hlog2 : (0:ℝ) < Real.log 2 := Real.log_pos (by norm_num)
  have hlog2lt : Real.log 2 < 0.6931471808 := Real.log_two_lt_d9
  have hlog2gt : (0.693:ℝ) < Real.log 2 := lt_trans (by norm_num) Real.log_two_gt_d9
  -- `n ≥ 1`
  have hn1 : 1 ≤ n := by
    rcases Nat.eq_zero_or_pos n with h0 | h; · exfalso; rw [h0] at hpos; simp [finiteKeyBits] at hpos
    exact h
  -- positivity of the finite-key length forces `n·rho² ≥ C²·ln(1/ε)`
  have hnrho : (C:ℝ) ^ 2 * Real.log (1 / eps) ≤ (n : ℝ) * (rho : ℝ) ^ 2 := by
    by_contra hcon
    push_neg at hcon
    have := (finiteKeyBits_neg_iff hrho hC.le hn1 (eps := eps)).2 hcon
    linarith
  -- the rate certificate is bounded by the threshold gap
  have hgap : (rho : ℝ) ≤ 2 * Real.log 9 * (Qstar - Q) / Real.log 2 := by
    have h := secureKeyRate_le_gap hQ hQQ hQs hzero
    calc (rho:ℝ) ≤ secureKeyRate Q / Real.log 2 := hcert
      _ ≤ 2 * Real.log 9 * (Qstar - Q) / Real.log 2 := by gcongr
  have hgapnn : 0 ≤ Qstar - Q := by linarith
  have h9 : Real.log 9 ≤ 2.2726 := log_nine_le
  have hrhobound : (rho : ℝ) ≤ 6.6 * (Qstar - Q) := by
    have h1 : 2 * Real.log 9 * (Qstar - Q) ≤ 2 * 2.2726 * (Qstar - Q) := by nlinarith
    have h2 : 2 * Real.log 9 * (Qstar - Q) / Real.log 2 ≤ 2 * 2.2726 * (Qstar - Q) / 0.693 := by
      apply div_le_div₀ (by nlinarith) h1 (by norm_num) (by linarith)
    have h3 : 2 * (2.2726:ℝ) * (Qstar - Q) / 0.693 ≤ 6.6 * (Qstar - Q) := by
      rw [div_le_iff₀ (by norm_num)]
      nlinarith
    linarith
  have hrhosq : (rho : ℝ) ^ 2 ≤ 44 * (Qstar - Q) ^ 2 := by nlinarith [hrhobound, hrho']
  -- assemble
  have hgap2 : (0:ℝ) < (Qstar - Q) := by nlinarith [hrho', hrhobound]
  rw [div_le_iff₀ (by positivity)]
  nlinarith [hnrho, hrhosq, Nat.cast_nonneg (α := ℝ) n]

/-! ## 3. The certified instance at `Q = 11 %` -/

/-- **Protocol-independent lower bound on the block size at `Q = 11 %`.**
The catalog certifies the threshold `Q*` to lie in `(0.1100, 0.1101)`, so the gap
at `Q = 11 %` is below `10⁻⁴`.  Consequently, with `C = 10` and `ε = 2⁻⁵⁰`, *no*
rational rate certificate at `11 %` can produce a positive finite-key length
below `n = 7·10⁹` sifted bits.  (The sharper, certificate-specific bound for
`rho = 1/6000` is `10¹¹`, from `finiteKey_nonpos_below_1e11`.) -/
theorem breakeven_eleven_percent {rho : ℚ} (hrho : 0 < rho)
    {Qstar : ℝ} (hQs : Qstar ∈ Set.Icc (0:ℝ) 2⁻¹) (hzero : secureKeyRate Qstar = 0)
    (hcert : (rho : ℝ) ≤ secureKeyRate (11 / 100) / Real.log 2)
    {n : ℕ} (hpos : 0 < finiteKeyBits rho 10 n ((2:ℝ) ^ (-50 : ℤ))) :
    (7 : ℝ) * 10 ^ 9 ≤ (n : ℝ) := by
  obtain ⟨hlow, hhigh⟩ := threshold_mem_Ioo hQs hzero
  have hL : Real.log (1 / ((2:ℝ) ^ (-50 : ℤ))) = 50 * Real.log 2 := log_one_div_eps50
  have hlog2gt : (0.693:ℝ) < Real.log 2 := lt_trans (by norm_num) Real.log_two_gt_d9
  have hgapsmall : Qstar - 11 / 100 ≤ 1 / 10000 := by linarith
  have hgappos : 0 < Qstar - 11 / 100 := by linarith
  have hmain := breakeven_ge_of_gap (C := 10) (rho := rho) (by norm_num) hrho
    (Q := 11 / 100) (Qstar := Qstar) (by norm_num) (le_of_lt hlow)
    (le_trans hQs.2 (by norm_num)) hzero hcert hpos
  have hden : (44:ℝ) * (Qstar - 11 / 100) ^ 2 ≤ 44 * (1 / 10000) ^ 2 := by nlinarith
  have hnum : ((10:ℚ) : ℝ) ^ 2 * Real.log (1 / ((2:ℝ) ^ (-50 : ℤ))) ≥ 3465 := by
    push_cast
    rw [hL]
    linarith
  have hstep : (7:ℝ) * 10 ^ 9
      ≤ ((10:ℚ) : ℝ) ^ 2 * Real.log (1 / ((2:ℝ) ^ (-50 : ℤ))) / (44 * (Qstar - 11 / 100) ^ 2) := by
    rw [le_div_iff₀ (by positivity)]
    nlinarith [hnum, hden]
  linarith

/-- **Summary of the threshold-gap law.**  The rate vanishes at most linearly at
the threshold, and consequently the break-even block size diverges at least
quadratically in the threshold gap; at `Q = 11 %` this forces `n ≥ 7·10⁹` for any
rate certificate whatsoever. -/
theorem threshold_gap_summary :
    (∀ Q Qstar : ℝ, 1 / 10 ≤ Q → Q ≤ Qstar → Qstar ≤ 1 / 2 → secureKeyRate Qstar = 0 →
      secureKeyRate Q ≤ 2 * Real.log 9 * (Qstar - Q)) ∧
    (∀ (rho : ℚ) (Qstar : ℝ) (n : ℕ), 0 < rho → Qstar ∈ Set.Icc (0:ℝ) 2⁻¹ →
      secureKeyRate Qstar = 0 → (rho : ℝ) ≤ secureKeyRate (11 / 100) / Real.log 2 →
      0 < finiteKeyBits rho 10 n ((2:ℝ) ^ (-50 : ℤ)) → (7 : ℝ) * 10 ^ 9 ≤ (n : ℝ)) :=
  ⟨fun _ _ hQ hQQ hQs hz => secureKeyRate_le_gap hQ hQQ hQs hz,
   fun _ _ _ hrho hQs hz hcert hpos => breakeven_eleven_percent hrho hQs hz hcert hpos⟩

end FiniteKey
end BB84