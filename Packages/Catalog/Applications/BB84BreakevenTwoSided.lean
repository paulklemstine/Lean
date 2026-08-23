import Mathlib
import Applications.BB84FiniteKeyThresholdGap

/-!
# The Break-Even Block Size Obeys a Two-Sided Inverse-Square Law

`Applications.BB84FiniteKeyThresholdGap` proves one half of the story: *every*
rational rate certificate valid at a QBER `Q` below the asymptotic threshold `Q*`
forces the break-even block size above `C²·ln(1/ε)/(44·(Q*−Q)²)`.  That is a
lower bound; on its own it leaves open the possibility that the break-even size
is *much* larger still — for instance exponentially large — in which case the
inverse-square shape would be an artifact of the proof rather than a law.

This file closes the gap.  The missing ingredient is a **lower** Lipschitz bound
for the binary entropy (`binEntropy_lipschitz_lower`), which says the asymptotic
rate vanishes *at least* linearly at the threshold.  Combining it with a rational
approximation step produces, for every `Q < Q*`, an *explicit rational
certificate* `rho` whose break-even block size is at most
`C²·ln(1/ε)/(9·(Q*−Q)²)`.  Together with the previous file:

`C²·ln(1/ε)/(44·(Q*−Q)²) ≤ n*(Q) ≤ C²·ln(1/ε)/(9·(Q*−Q)²)`,

i.e. `n*(Q) = Θ((Q*−Q)⁻²)` with a certified constant ratio `44/9 < 5`.

-- !-- Lab Notes -- !--
HYPOTHESIS (Hypothesizer): (H8) The one-sided divergence law of the previous
  cycle is tight: the break-even block size is *also* `O((Q*−Q)⁻²)`, so the
  inverse-square exponent is exact and the only uncertainty is a bounded constant.
  (H9) No irrational data are needed: a rational certificate capturing a fixed
  fraction (here `3/4`) of the true rate suffices, obtained by `exists_rat_btwn`.
EXPERIMENT (Experimenter): The derivative of the binary entropy is
  `log((1−p)/p)`, decreasing in `p`, so on `[Q, Q*]` its minimum sits at `Q*`.
  For `Q* ≤ 1/5` that minimum is at least `log 4 = 2 log 2`, giving
  `r(Q) ≥ 4 log 2 · (Q*−Q)`, i.e. at least `4·(Q*−Q)` *bits*.  Numerically at
  `Q* = 0.110028`, `4 log 2 = 2.7726` against the true slope `2 log((1−Q*)/Q*) =
  4.1657`, so the certified constant `4` bits is a factor `1.5` conservative and
  the true two-sided ratio is nearer `44/20`.
ANALYSIS (Analyst): Both halves of the law come from the *same* monotonicity
  template applied to `p ↦ K·p − binEntropy p` with `K` above (upper Lipschitz)
  and below (lower Lipschitz) the derivative range.  The exponent `2` is forced
  by the `√n` shape of the statistical correction alone; the entropy only fixes
  the constant.  This separation explains why the law is protocol-independent.
CRITIQUE (Critic): The upper bound is an *existence* statement about `rho`, so it
  could be vacuous if the interval `(3δ, 4δ]` contained no rational — it always
  does, and `exists_rat_btwn` produces one, with `rho > 0` recorded explicitly.
  The restriction `Q* ≤ 1/5` is what makes `log((1−Q*)/Q*) ≥ log 4` and is
  satisfied by the catalog's certified enclosure `Q* < 0.1101`.  Neither bound
  assumes `Q ≥ 1/10` except where the *upper* Lipschitz constant is used.
SYNTHESIS (PI): `binEntropy_lipschitz_lower` → `secureKeyRate_ge_gap` →
  `breakeven_le_of_gap` → `breakeven_two_sided_law`.
-/

open Real Set Finset

noncomputable section

namespace BB84
namespace FiniteKey

/-! ## 1. A lower Lipschitz bound for the binary entropy -/

/-- **Lower Lipschitz bound for the binary entropy.**  For `0 < x ≤ y ≤ 1/2`,

`log((1−y)/y) · (y − x) ≤ binEntropy y − binEntropy x`.

The derivative of `binEntropy` is `log((1−p)/p)`, which is decreasing, so its
minimum over `[x, y]` is attained at the right endpoint `y`.  Proved by
monotonicity of `p ↦ binEntropy p − log((1−y)/y) · p` on `[x, y]`. -/
theorem binEntropy_lipschitz_lower {x y : ℝ} (hx : 0 < x) (hxy : x ≤ y) (hy : y ≤ 1 / 2) :
    Real.log ((1 - y) / y) * (y - x) ≤ Real.binEntropy y - Real.binEntropy x := by
  set K : ℝ := Real.log ((1 - y) / y) with hK
  have hypos : (0:ℝ) < y := lt_of_lt_of_le hx hxy
  have hmono : MonotoneOn (fun p => Real.binEntropy p - K * p) (Set.Icc x y) := by
    apply monotoneOn_of_deriv_nonneg (convex_Icc _ _)
    · exact Real.binEntropy_continuous.continuousOn.sub
        (continuousOn_const.mul continuousOn_id)
    · intro t ht
      rw [interior_Icc] at ht
      have ht0 : t ≠ 0 := by intro h; rw [h] at ht; linarith [ht.1]
      have ht1 : t ≠ 1 := by intro h; rw [h] at ht; linarith [ht.2, hy]
      exact ((Real.hasDerivAt_binEntropy ht0 ht1).sub
        ((hasDerivAt_const t K).mul (hasDerivAt_id t))).differentiableAt.differentiableWithinAt
    · intro t ht
      rw [interior_Icc] at ht
      have htpos : (0:ℝ) < t := lt_trans hx ht.1
      have hty : t < y := ht.2
      have ht0 : t ≠ 0 := ne_of_gt htpos
      have ht1 : t ≠ 1 := by intro h; rw [h] at hty; linarith
      have hd : HasDerivAt (fun p => Real.binEntropy p - K * p)
          ((Real.log (1 - t) - Real.log t) - K) t := by
        simpa using (Real.hasDerivAt_binEntropy ht0 ht1).sub
          ((hasDerivAt_const t K).mul (hasDerivAt_id t))
      rw [hd.deriv]
      have h1t : (0:ℝ) < 1 - t := by linarith
      have hratio : K ≤ Real.log (1 - t) - Real.log t := by
        rw [← Real.log_div (ne_of_gt h1t) (ne_of_gt htpos), hK]
        apply Real.log_le_log (div_pos (by linarith) hypos)
        rw [div_le_div_iff₀ hypos htpos]
        nlinarith
      linarith
  have hxmem : x ∈ Set.Icc x y := ⟨le_refl x, hxy⟩
  have hymem : y ∈ Set.Icc x y := ⟨hxy, le_refl y⟩
  have h := hmono hxmem hymem hxy
  simp only at h
  linarith

/-! ## 2. The rate vanishes at least linearly at the threshold -/

/-- **At-least-linear vanishing at the threshold.**  If `Q*` is a zero of the
asymptotic key rate with `Q ≤ Q* ≤ 1/5`, then

`r(Q) ≥ 4 · log 2 · (Q* − Q)`  nats per sifted bit,

i.e. at least `4·(Q* − Q)` bits.  Together with `secureKeyRate_le_gap` this
sandwiches the rate linearly in the threshold gap. -/
theorem secureKeyRate_ge_gap {Q Qstar : ℝ} (hQ : 0 < Q) (hQQ : Q ≤ Qstar)
    (hQs : Qstar ≤ 1 / 5) (hzero : secureKeyRate Qstar = 0) :
    4 * Real.log 2 * (Qstar - Q) ≤ secureKeyRate Q := by
  have hlip := binEntropy_lipschitz_lower hQ hQQ (by linarith)
  have hQspos : (0:ℝ) < Qstar := lt_of_lt_of_le hQ hQQ
  have hratio : (4:ℝ) ≤ (1 - Qstar) / Qstar := by
    rw [le_div_iff₀ hQspos]; linarith
  have hlog4 : Real.log 4 ≤ Real.log ((1 - Qstar) / Qstar) :=
    Real.log_le_log (by norm_num) hratio
  have h4 : Real.log 4 = 2 * Real.log 2 := by
    rw [show (4:ℝ) = 2 ^ 2 by norm_num, Real.log_pow]; push_cast; ring
  have hgapnn : (0:ℝ) ≤ Qstar - Q := by linarith
  have hstep : 2 * Real.log 2 * (Qstar - Q) ≤ Real.log ((1 - Qstar) / Qstar) * (Qstar - Q) := by
    apply mul_le_mul_of_nonneg_right _ hgapnn
    rw [← h4]; exact hlog4
  have h0 : Real.log 2 - 2 * Real.binEntropy Qstar = 0 := hzero
  have hQdef : secureKeyRate Q = Real.log 2 - 2 * Real.binEntropy Q := rfl
  rw [hQdef]
  linarith

/-! ## 3. Break-even from above -/

/-- Helper: `C·√x < y` from the strict squared inequality. -/
theorem mul_sqrt_lt_of_sq {C x y : ℝ} (hC : 0 ≤ C) (hx : 0 ≤ x) (hy : 0 ≤ y)
    (h : C ^ 2 * x < y ^ 2) :
    C * Real.sqrt x < y := by
  have hrw : C * Real.sqrt x = Real.sqrt (C ^ 2 * x) := by
    rw [Real.sqrt_mul (sq_nonneg C), Real.sqrt_sq hC]
  rw [hrw]
  calc Real.sqrt (C ^ 2 * x) < Real.sqrt (y ^ 2) :=
        Real.sqrt_lt_sqrt (by positivity) h
    _ = y := Real.sqrt_sq hy

/-- **Positivity criterion for the finite-key length.**  Strictly above the
break-even sample size `(C/rho)²·ln(1/ε)`, the finite-key length is positive. -/
theorem finiteKeyBits_pos_of {rho C : ℚ} (hC : 0 ≤ C) (hrho : 0 < rho) {n : ℕ} {eps : ℝ}
    (hL : 0 ≤ Real.log (1 / eps))
    (h : (C : ℝ) ^ 2 * Real.log (1 / eps) < (n : ℝ) * (rho : ℝ) ^ 2) :
    0 < finiteKeyBits rho C n eps := by
  have hC' : (0:ℝ) ≤ (C : ℝ) := by exact_mod_cast hC
  have hrho' : (0:ℝ) < (rho : ℝ) := by exact_mod_cast hrho
  have hn : (0:ℝ) ≤ (n:ℝ) := Nat.cast_nonneg n
  have hnpos : (0:ℝ) < (n:ℝ) := by
    rcases eq_or_lt_of_le hn with h0 | h0
    · exfalso; rw [← h0] at h; nlinarith [sq_nonneg (C:ℝ)]
    · exact h0
  have hlt : (C:ℝ) * Real.sqrt ((n:ℝ) * Real.log (1 / eps)) < (n:ℝ) * (rho:ℝ) := by
    apply mul_sqrt_lt_of_sq hC' (by positivity) (by positivity)
    calc (C:ℝ) ^ 2 * ((n:ℝ) * Real.log (1/eps))
        = (n:ℝ) * ((C:ℝ) ^ 2 * Real.log (1/eps)) := by ring
      _ < (n:ℝ) * ((n:ℝ) * (rho:ℝ) ^ 2) := mul_lt_mul_of_pos_left h hnpos
      _ = ((n:ℝ) * (rho:ℝ)) ^ 2 := by ring
  unfold finiteKeyBits
  linarith

/-- **Break-even from above.**  Fix finite-key parameters `C > 0`, `ε` with
`ln(1/ε) ≥ 0`, and a QBER `Q` strictly below a threshold zero `Q* ≤ 1/5` of the
asymptotic rate.  Then there is an *explicit positive rational* rate certificate
`rho` — valid, i.e. `rho ≤ r(Q)/log 2` bits per sifted bit — whose break-even
block size is at most `C²·ln(1/ε)/(9·(Q*−Q)²)`: for every

`n ≥ C²·ln(1/ε)/(9·(Q*−Q)²)`,  `n ≥ 1`,

the finite-key length `finiteKeyBits rho C n ε` is strictly positive. -/
theorem breakeven_le_of_gap {C : ℚ} (hC : 0 < C) {eps : ℝ}
    (hL : 0 ≤ Real.log (1 / eps))
    {Q Qstar : ℝ} (hQ : 0 < Q) (hQQ : Q < Qstar) (hQs : Qstar ≤ 1 / 5)
    (hzero : secureKeyRate Qstar = 0) :
    ∃ rho : ℚ, 0 < rho ∧ (rho : ℝ) ≤ secureKeyRate Q / Real.log 2 ∧
      ∀ n : ℕ, 1 ≤ n →
        (C : ℝ) ^ 2 * Real.log (1 / eps) / (9 * (Qstar - Q) ^ 2) ≤ (n : ℝ) →
        0 < finiteKeyBits rho C n eps := by
  have hlog2 : (0:ℝ) < Real.log 2 := Real.log_pos (by norm_num)
  have hdelta : (0:ℝ) < Qstar - Q := by linarith
  have hrate : 4 * Real.log 2 * (Qstar - Q) ≤ secureKeyRate Q :=
    secureKeyRate_ge_gap hQ hQQ.le hQs hzero
  have hbits : 4 * (Qstar - Q) ≤ secureKeyRate Q / Real.log 2 := by
    rw [le_div_iff₀ hlog2]; linarith
  obtain ⟨rho, hrho1, hrho2⟩ := exists_rat_btwn (show 3 * (Qstar - Q) < 4 * (Qstar - Q) by linarith)
  have hrhopos : (0:ℝ) < (rho : ℝ) := by linarith
  have hrhoQ : (0:ℚ) < rho := by exact_mod_cast hrhopos
  refine ⟨rho, hrhoQ, le_trans hrho2.le hbits, ?_⟩
  intro n hn hnbig
  have hn1 : (1:ℝ) ≤ (n:ℝ) := by exact_mod_cast hn
  apply finiteKeyBits_pos_of hC.le hrhoQ hL
  -- from `n ≥ C²L/(9δ²)` and `rho > 3δ`
  have hkey : (C:ℝ) ^ 2 * Real.log (1 / eps) ≤ (n:ℝ) * (9 * (Qstar - Q) ^ 2) := by
    rw [div_le_iff₀ (by positivity)] at hnbig
    linarith
  have hsq : 9 * (Qstar - Q) ^ 2 < (rho:ℝ) ^ 2 := by nlinarith
  have hstep : (n:ℝ) * (9 * (Qstar - Q) ^ 2) < (n:ℝ) * (rho:ℝ) ^ 2 :=
    mul_lt_mul_of_pos_left hsq (by linarith)
  linarith

/-! ## 4. The two-sided law -/

/-- **Two-sided inverse-square law for the break-even block size.**
For every QBER `Q ∈ [1/10, Q*)` below a threshold zero `Q* ≤ 1/5` of the
asymptotic rate, and every finite-key parameter pair `(C, ε)` with `C > 0` and
`ln(1/ε) ≥ 0`:

* (**lower**) *every* valid rational certificate `rho` at `Q` has a break-even
  block size at least `C²·ln(1/ε)/(44·(Q*−Q)²)`;
* (**upper**) *some* valid rational certificate `rho` has a break-even block size
  at most `C²·ln(1/ε)/(9·(Q*−Q)²)`.

Hence `n*(Q) = Θ((Q* − Q)⁻²)`, with the two certified constants differing by the
factor `44/9 < 5`.  The inverse-square exponent is therefore a genuine law of the
finite-key accounting and not an artifact of a lossy estimate. -/
theorem breakeven_two_sided_law {C : ℚ} (hC : 0 < C) {eps : ℝ}
    (hL : 0 ≤ Real.log (1 / eps))
    {Q Qstar : ℝ} (hQ : 1 / 10 ≤ Q) (hQQ : Q < Qstar) (hQs : Qstar ≤ 1 / 5)
    (hzero : secureKeyRate Qstar = 0) :
    (∀ rho : ℚ, 0 < rho → (rho : ℝ) ≤ secureKeyRate Q / Real.log 2 →
        ∀ n : ℕ, 0 < finiteKeyBits rho C n eps →
          (C : ℝ) ^ 2 * Real.log (1 / eps) / (44 * (Qstar - Q) ^ 2) ≤ (n : ℝ)) ∧
      (∃ rho : ℚ, 0 < rho ∧ (rho : ℝ) ≤ secureKeyRate Q / Real.log 2 ∧
        ∀ n : ℕ, 1 ≤ n →
          (C : ℝ) ^ 2 * Real.log (1 / eps) / (9 * (Qstar - Q) ^ 2) ≤ (n : ℝ) →
          0 < finiteKeyBits rho C n eps) := by
  constructor
  · intro rho hrho hcert n hpos
    exact breakeven_ge_of_gap hC hrho hQ hQQ.le (by linarith) hzero hcert hpos
  · exact breakeven_le_of_gap hC hL (by linarith) hQQ hQs hzero

/-! ## 5. A fully explicit instance at `Q = 10 %` -/

/-- **Explicit two-sided instance at `Q = 10 %`.**  The catalog certifies the
threshold to lie in `(0.1100, 0.1101)`, so the gap at `Q = 10 %` exceeds `1/100`.
With `C = 10` and `ε = 2⁻⁵⁰` the upper half of the law then produces an explicit
positive rational certificate whose break-even block size is below `4·10⁶` sifted
bits — no irrational or floating-point data enter the construction. -/
theorem breakeven_ten_percent_upper {Qstar : ℝ} (hQs : Qstar ∈ Set.Icc (0:ℝ) 2⁻¹)
    (hzero : secureKeyRate Qstar = 0) :
    ∃ rho : ℚ, 0 < rho ∧ (rho : ℝ) ≤ secureKeyRate (1 / 10) / Real.log 2 ∧
      ∀ n : ℕ, 4 * 10 ^ 6 ≤ n → 0 < finiteKeyBits rho 10 n ((2:ℝ) ^ (-50 : ℤ)) := by
  obtain ⟨hlow, hhigh⟩ := threshold_mem_Ioo hQs hzero
  have hlog2 : (0:ℝ) < Real.log 2 := Real.log_pos (by norm_num)
  have hlog2lt : Real.log 2 < 0.6931471808 := Real.log_two_lt_d9
  have hL : Real.log (1 / ((2:ℝ) ^ (-50 : ℤ))) = 50 * Real.log 2 := log_one_div_eps50
  have hLnn : 0 ≤ Real.log (1 / ((2:ℝ) ^ (-50 : ℤ))) := by rw [hL]; linarith
  obtain ⟨rho, hrho, hcert, hpos⟩ := breakeven_le_of_gap (C := 10) (by norm_num) hLnn
    (Q := 1 / 10) (Qstar := Qstar) (by norm_num) (by linarith) (by linarith) hzero
  refine ⟨rho, hrho, hcert, ?_⟩
  intro n hn
  refine hpos n (by omega) ?_
  have hn' : (4 * 10 ^ 6 : ℝ) ≤ (n:ℝ) := by exact_mod_cast hn
  have hdelta : (1 / 100 : ℝ) < Qstar - 1 / 10 := by linarith
  rw [div_le_iff₀ (by positivity), hL]
  have h2 : (4 * 10 ^ 6 : ℝ) * (9 * (1 / 100 : ℝ) ^ 2) ≤ (n:ℝ) * (9 * (Qstar - 1 / 10) ^ 2) :=
    mul_le_mul hn' (by nlinarith) (by positivity) (by linarith)
  push_cast
  nlinarith [h2]

end FiniteKey
end BB84