import Shared.AttentionBudgetEntropyCertificates

/-!
# Cycle 7: the reported budget is sharp to within one key

Cycles 4–6 proved that a fitted tail law `1 - M(k) ≤ C rᵏ` *certifies* the budget
`budgetOfFit C r τ`, and that the certificate is monotone in the fit box and unbiased on a
geometric tail.  What was still open — it is direction 5 of the cycle-6 synthesis — is
*sharpness*: is the reported number close to the true knee, or merely an upper bound?

**Main theorem** (`budgetOfFit_le_kstar_add_one`).  If the measured tail is exactly
`1 - M(k) = C rᵏ` below the context length, and the reported budget fits inside the context,
then

  `budgetOfFit C r τ ≤ k*(n, τ) + 1`.

Combined with `kstar_le_budgetOfFit` this pins the report:
`k* ≤ budgetOfFit ≤ k* + 1` (`budget_report_sharp`).  The single-key slack is exactly the
ceiling rounding and cannot be removed: the report is the best integer certificate derivable
from the fit.

A second consequence (`kstar_exact_of_tail_exact`) is that on an exact geometric tail the
knee is *computed*, not merely bracketed: it equals `⌈log((1-τ)/C)/log r⌉₊` whenever that
number is at least one and at most `n`.  This is the strongest possible answer to the
cycle-1 razor-bracket question `12 < k* ≤ 16`: with a fit in hand the bracket collapses to
a single value.

-- !-- Lab Notes -- !--
Hypothesizer (cycle 7):
 (H26) The certified budget overshoots the true knee by at most one key whenever it fits
       inside the context.                                                   [BOLD]
 (H27) Consequently an exact tail measurement *determines* the knee, so the razor bracket
       of cycle 1 collapses to a point.                                      [BOLD]

Experimenter: H26 = `budgetOfFit_le_kstar_add_one`, H27 = `kstar_exact_of_tail_exact`;
both proved with zero sorries.  The mechanism is the minimality property of `Nat.ceil`:
if the budget one step below the reported one already cleared the gate, the ceiling would
have been smaller.

Analyst: the hypothesis `budgetOfFit C r τ ≤ n` is not decoration.  When the reported
budget exceeds the context length the knee saturates at `n` (a truncation effect, not a
decay effect) and the gap `budgetOfFit - k*` can be arbitrarily large; this is the same
finite-context boundary that appears as `rⁿ ≤ 1/2` in cycle 5.

Critic: `kstar_exact_of_tail_exact` is an equality between a `sInf` and a closed form, so
it is not definitional; it is proved by two-sided bracketing (a failure just below and a
pass at the reported value).  The exactness hypothesis is strictly stronger than `TailFit`
and is stated only for `k < n`, where the measured tail is genuinely informative.
-/

namespace AttentionBudget

open Finset

section Sharp

variable {w : ℕ → ℝ} {C r τ : ℝ} {n : ℕ}

/-- The reported budget is the least exponent whose fitted tail clears the residual: if
`C rᵐ ≤ 1 - τ` then `budgetOfFit C r τ ≤ max m 1`. -/
lemma budgetOfFit_le_of_pow_le {m : ℕ} (hC : 0 < C) (hr0 : 0 < r) (hr1 : r < 1) (hτ : τ < 1)
    (hm : C * r ^ m ≤ 1 - τ) : budgetOfFit C r τ ≤ max m 1 := by
  have hlogr : Real.log r < 0 := Real.log_neg hr0 hr1
  have hpos : 0 < (1 - τ) / C := div_pos (by linarith) hC
  have hpow : r ^ m ≤ (1 - τ) / C := by
    rw [le_div_iff₀ hC]
    linarith
  have hlog : (m : ℝ) * Real.log r ≤ Real.log ((1 - τ) / C) := by
    have hlp : Real.log (r ^ m) = (m : ℝ) * Real.log r := by rw [Real.log_pow]
    rw [← hlp]
    exact Real.log_le_log (pow_pos hr0 m) hpow
  have hdiv : Real.log ((1 - τ) / C) / Real.log r ≤ (m : ℝ) := by
    rw [div_le_iff_of_neg hlogr]
    linarith
  exact max_le_max (Nat.ceil_le.mpr hdiv) le_rfl

/-- **H26 — sharpness of the report.**  On an exactly measured geometric tail the reported
budget exceeds the true knee by at most one key. -/
theorem budgetOfFit_le_kstar_add_one (hw : ∀ i, 0 < w i) (hC : 0 < C) (hr0 : 0 < r)
    (hr1 : r < 1) (hτ : τ < 1) (hn : 0 < n)
    (hexact : ∀ k, k < n → tailMass w n k = C * r ^ k)
    (hfit : budgetOfFit C r τ ≤ n) :
    budgetOfFit C r τ ≤ kstar w n τ + 1 := by
  set K := budgetOfFit C r τ with hK
  have hK1 : 1 ≤ K := le_max_right _ _
  rcases Nat.eq_or_lt_of_le hK1 with hKeq | hKgt
  · -- the reported budget is the floor value `1`
    omega
  · -- `K - 1` is a genuine failure, so the knee is at least `K - 1 + 1 = K`
    have hKm : K - 1 < n := by omega
    have hfail : 1 - τ < C * r ^ (K - 1) := by
      by_contra hcon
      push_neg at hcon
      have hle : K ≤ max (K - 1) 1 := budgetOfFit_le_of_pow_le hC hr0 hr1 hτ hcon
      have : max (K - 1) 1 = K - 1 := max_eq_left (by omega)
      omega
    have hret : retained w n (K - 1) < τ := by
      have h := hexact (K - 1) hKm
      simp only [tailMass] at h
      linarith
    have hlt : K - 1 < kstar w n τ := lt_kstar_of_fail hw hn hτ.le hret
    omega

/-- The upper half of the report under an exact tail measurement. -/
lemma kstar_le_budgetOfFit_of_tail_exact (hw : ∀ i, 0 < w i) (hC : 0 < C) (hr0 : 0 < r)
    (hr1 : r < 1) (hτ : τ < 1) (hn : 0 < n)
    (hexact : ∀ k, k < n → tailMass w n k = C * r ^ k) :
    kstar w n τ ≤ budgetOfFit C r τ := by
  set K := budgetOfFit C r τ with hK
  have hb : tailMass w n K ≤ C * r ^ K := by
    rcases lt_or_ge K n with h | h
    · exact le_of_eq (hexact K h)
    · have hz : tailMass w n K = 0 := tailMass_eq_zero_of_context_le hw hn (by omega)
      rw [hz]
      positivity
  have h2 : C * r ^ K ≤ 1 - τ := fit_tail_le_of_budgetOfFit hC hr0 hr1 hτ
  simp only [tailMass] at hb
  exact kstar_le_of_pass (by linarith)

/-- **H27 — an exact tail measurement determines the knee.**  The razor bracket of cycle 1
collapses to a point: the knee *equals* the reported budget. -/
theorem kstar_exact_of_tail_exact (hw : ∀ i, 0 < w i) (hC : 0 < C) (hr0 : 0 < r)
    (hr1 : r < 1) (hτ0 : 0 < τ) (hτ : τ < 1) (hn : 0 < n)
    (hexact : ∀ k, k < n → tailMass w n k = C * r ^ k)
    (hfit : budgetOfFit C r τ ≤ n) :
    kstar w n τ = budgetOfFit C r τ := by
  set K := budgetOfFit C r τ with hK
  have hup : kstar w n τ ≤ K :=
    kstar_le_budgetOfFit_of_tail_exact hw hC hr0 hr1 hτ hn hexact
  have hK1 : 1 ≤ K := le_max_right _ _
  have hlow : K ≤ kstar w n τ := by
    rcases Nat.eq_or_lt_of_le hK1 with hKeq | hKgt
    · -- `K = 1`: the empty budget retains no mass, so the knee is at least one
      have hzero : retained w n 0 < τ := by
        simp only [retained, Nat.zero_min, headMass, Finset.range_zero, Finset.sum_empty,
          zero_div]
        exact hτ0
      have := lt_kstar_of_fail hw hn hτ.le hzero
      omega
    · have hKm : K - 1 < n := by omega
      have hfail : 1 - τ < C * r ^ (K - 1) := by
        by_contra hcon
        push_neg at hcon
        have hle : K ≤ max (K - 1) 1 := budgetOfFit_le_of_pow_le hC hr0 hr1 hτ hcon
        have hmax : max (K - 1) 1 = K - 1 := max_eq_left (by omega)
        omega
      have hret : retained w n (K - 1) < τ := by
        have h := hexact (K - 1) hKm
        simp only [tailMass] at h
        linarith
      have := lt_kstar_of_fail hw hn hτ.le hret
      omega
  omega

/-- **The report is pinned.**  Under an exact tail measurement the true knee and the
reported budget differ by at most one key (in fact they coincide). -/
theorem budget_report_sharp (hw : ∀ i, 0 < w i) (hC : 0 < C) (hr0 : 0 < r) (hr1 : r < 1)
    (hτ0 : 0 < τ) (hτ : τ < 1) (hn : 0 < n)
    (hexact : ∀ k, k < n → tailMass w n k = C * r ^ k)
    (hfit : budgetOfFit C r τ ≤ n) :
    kstar w n τ ≤ budgetOfFit C r τ ∧ budgetOfFit C r τ ≤ kstar w n τ + 1 := by
  have h := kstar_exact_of_tail_exact hw hC hr0 hr1 hτ0 hτ hn hexact hfit
  omega

end Sharp

end AttentionBudget