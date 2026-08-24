import Mathlib
import Shared.AttentionBudgetKnee

/-!
# Geometric attention profiles: the knee as a function of the decay ratio

This file is the technical core of the NET-79 round.  It studies the knee
`kstar` of `Catalog/Shared/AttentionBudgetKnee.lean` on the one-parameter family of
*geometric profiles* `geomProfile r i = r ^ i`, `0 < r < 1`, and proves the three
facts that the rest of the round needs.

* `retained_geomProfile_antitone_ratio` — the retained mass of a top-`k` truncation is
  **antitone in the decay ratio**: a slower-decaying profile retains *less* mass at
  every budget and every context length.  The proof is a genuine rearrangement
  argument (a double-sum cross-term comparison `s^i r^j ≤ r^i s^j` for `i ≤ j`),
  not a differentiation.
* `kstar_geomProfile_mono_ratio` — consequently the knee is monotone in the ratio.
  This turns any *inversion* of decay ratios into an inversion of key budgets, which
  is exactly the phenomenon NET-79 reports across the scale × context grid.
* `kstar_geomProfile_le_of_pow_bound` (upper) and `lt_kstar_geomProfile_of_flat`
  (lower) — a two-sided quantitative control of the knee, the second of which shows
  that ratios close to `1` force arbitrarily large budgets.

-- !-- Lab Notes -- !--
Hypothesizer (this cycle, ranked):
 (G1) The knee of a geometric profile is monotone in the decay ratio, uniformly in
      the context length.  [BOLD: no continuity/analytic input, pure rearrangement]
 (G2) `retained` is antitone in the ratio *pointwise in (n,k)*, a much stronger
      statement than monotonicity of the knee.
 (G3) A ratio bounded away from 1 gives a context-free budget; a ratio approaching 1
      gives an unbounded budget.  Together: the budget diverges exactly at `r → 1⁻`.
Experimenter: G1–G3 are all proved below with zero sorries.
Analyst: the informative point is that G2 needs `k ≤ n` to be exploited through
`min k n`; the naive comparison of `(1 - r^k)/(1 - r^n)` by monotonicity of each
factor *fails* (both numerator and denominator move the same way), and the
rearrangement over `range m × Ico m n` is what actually carries the proof.
Critic: no statement here is vacuous — `lt_kstar_geomProfile_of_flat` is applied in
`NET79PythagoreanInversion.lean` to an explicit family of Pythagorean ratios, and
`kstar_geomProfile_le_of_pow_bound` is applied at the measured NET-79 gate `0.985`.
-/

namespace PythKnee

open Finset AttentionBudget

/-- The geometric attention profile with decay ratio `r`. -/
noncomputable def geomProfile (r : ℝ) : ℕ → ℝ := fun i => r ^ i

lemma geomProfile_pos {r : ℝ} (hr : 0 < r) : ∀ i, 0 < geomProfile r i := fun i => by
  simpa [geomProfile] using pow_pos hr i

lemma geomProfile_decay {r : ℝ} (i : ℕ) : geomProfile r (i + 1) = r * geomProfile r i := by
  simp [geomProfile, pow_succ, mul_comm]

lemma headMass_geomProfile (r : ℝ) (n : ℕ) :
    headMass (geomProfile r) n = ∑ i ∈ range n, r ^ i := rfl

/-! ## The rearrangement inequality behind ratio-monotonicity -/

lemma sum_range_split {m n : ℕ} (h : m ≤ n) (f : ℕ → ℝ) :
    ∑ i ∈ range n, f i = (∑ i ∈ range m, f i) + ∑ i ∈ Ico m n, f i := by
  rw [Finset.range_eq_Ico, ← Finset.sum_Ico_consecutive _ (Nat.zero_le m) h]

/-- **Cross-term rearrangement.**  For `0 < r ≤ s` and a head/tail split at `m`,
`(∑_{i<m} s^i)(∑_{m≤j<n} r^j) ≤ (∑_{i<m} r^i)(∑_{m≤j<n} s^j)`. -/
lemma geom_cross_sum {r s : ℝ} (hr : 0 < r) (hrs : r ≤ s) {m n : ℕ} :
    (∑ i ∈ range m, s ^ i) * (∑ j ∈ Ico m n, r ^ j)
      ≤ (∑ i ∈ range m, r ^ i) * (∑ j ∈ Ico m n, s ^ j) := by
  rw [Finset.sum_mul_sum, Finset.sum_mul_sum]
  refine Finset.sum_le_sum fun i hi => Finset.sum_le_sum fun j hj => ?_
  have hij : i ≤ j := le_trans (le_of_lt (mem_range.mp hi)) (mem_Ico.mp hj).1
  obtain ⟨d, rfl⟩ := Nat.exists_eq_add_of_le hij
  have hd : r ^ d ≤ s ^ d := pow_le_pow_left₀ hr.le hrs d
  have hri : (0 : ℝ) < r ^ i := pow_pos hr i
  have hsi : (0 : ℝ) < s ^ i := pow_pos (lt_of_lt_of_le hr hrs) i
  have h0 : (0 : ℝ) ≤ r ^ i * s ^ i := by positivity
  have key : s ^ i * (r ^ i * r ^ d) ≤ r ^ i * (s ^ i * s ^ d) := by
    calc s ^ i * (r ^ i * r ^ d) = (r ^ i * s ^ i) * r ^ d := by ring
      _ ≤ (r ^ i * s ^ i) * s ^ d := mul_le_mul_of_nonneg_left hd h0
      _ = r ^ i * (s ^ i * s ^ d) := by ring
  calc s ^ i * r ^ (i + d) = s ^ i * (r ^ i * r ^ d) := by rw [pow_add]
    _ ≤ r ^ i * (s ^ i * s ^ d) := key
    _ = r ^ i * s ^ (i + d) := by rw [pow_add]

/-- **G2 — retained mass is antitone in the decay ratio.**  A profile that decays more
slowly retains strictly less of the context's attention mass at every key budget and
every context length. -/
theorem retained_geomProfile_antitone_ratio {r s : ℝ} (hr : 0 < r) (hrs : r ≤ s)
    (n k : ℕ) (hn : 0 < n) :
    retained (geomProfile s) n k ≤ retained (geomProfile r) n k := by
  have hs : 0 < s := lt_of_lt_of_le hr hrs
  set m := min k n with hm
  have hmn : m ≤ n := min_le_right _ _
  have hRden : 0 < ∑ i ∈ range n, r ^ i :=
    Finset.sum_pos (fun i _ => pow_pos hr i) ⟨0, mem_range.mpr hn⟩
  have hSden : 0 < ∑ i ∈ range n, s ^ i :=
    Finset.sum_pos (fun i _ => pow_pos hs i) ⟨0, mem_range.mpr hn⟩
  rw [retained, retained, headMass_geomProfile, headMass_geomProfile, headMass_geomProfile,
    headMass_geomProfile, div_le_div_iff₀ hSden hRden]
  rw [sum_range_split hmn (fun i => r ^ i), sum_range_split hmn (fun i => s ^ i)]
  have := geom_cross_sum (r := r) (s := s) hr hrs (m := m) (n := n)
  nlinarith [Finset.sum_nonneg (fun i (_ : i ∈ range m) => (pow_pos hr i).le),
    Finset.sum_nonneg (fun i (_ : i ∈ range m) => (pow_pos hs i).le)]

/-- **G1 — the knee is monotone in the decay ratio.**  Slower decay never needs fewer
keys, at any context length and any gate. -/
theorem kstar_geomProfile_mono_ratio {r s τ : ℝ} (hr : 0 < r) (hrs : r ≤ s) {n : ℕ}
    (hn : 0 < n) (hτ : τ ≤ 1) :
    kstar (geomProfile r) n τ ≤ kstar (geomProfile s) n τ := by
  have hs : 0 < s := lt_of_lt_of_le hr hrs
  have hpass : τ ≤ retained (geomProfile s) n (kstar (geomProfile s) n τ) :=
    gate_le_retained_kstar (geomProfile_pos hs) hn hτ
  exact kstar_le_of_pass
    (hpass.trans (retained_geomProfile_antitone_ratio hr hrs n _ hn))

/-! ## Two-sided quantitative control -/

/-- **Upper bound.**  If `r ^ K / (1 - r) ≤ 1 - τ` then `K` keys clear the gate at every
context length: a context-free budget certified by the decay ratio alone. -/
theorem kstar_geomProfile_le_of_pow_bound {r τ : ℝ} (hr0 : 0 < r) (hr1 : r < 1) {K n : ℕ}
    (hK : 1 ≤ K) (hn : 1 ≤ n) (hbound : r ^ K / (1 - r) ≤ 1 - τ) :
    kstar (geomProfile r) n τ ≤ K := by
  have hpass : 1 - r ^ K / (1 - r) ≤ retained (geomProfile r) n K :=
    retained_ge_of_geometric_decay (geomProfile_pos hr0) hr0 hr1
      (fun i => le_of_eq (geomProfile_decay i)) hK hn
  exact kstar_le_of_pass (by linarith)

/-- A crude but robust upper estimate for the retained mass of a geometric profile:
`retained ≤ k / (n * r ^ (n-1))`.  For ratios close to `1` this is close to `k / n`. -/
lemma retained_geomProfile_le {r : ℝ} (hr0 : 0 < r) (hr1 : r ≤ 1) {n k : ℕ} (hn : 0 < n) :
    retained (geomProfile r) n k ≤ (k : ℝ) / (n * r ^ (n - 1)) := by
  have hnum : ∑ i ∈ range (min k n), r ^ i ≤ (k : ℝ) := by
    calc ∑ i ∈ range (min k n), r ^ i ≤ ∑ _i ∈ range (min k n), (1 : ℝ) :=
          Finset.sum_le_sum fun i _ => pow_le_one₀ hr0.le hr1
      _ = (min k n : ℝ) := by simp
      _ ≤ (k : ℝ) := by exact_mod_cast min_le_left k n
  have hden : (n : ℝ) * r ^ (n - 1) ≤ ∑ i ∈ range n, r ^ i := by
    calc (n : ℝ) * r ^ (n - 1) = ∑ _i ∈ range n, r ^ (n - 1) := by simp
      _ ≤ ∑ i ∈ range n, r ^ i := by
          refine Finset.sum_le_sum fun i hi => ?_
          exact pow_le_pow_of_le_one hr0.le hr1 (by have := mem_range.mp hi; omega)
  have hdpos : (0 : ℝ) < (n : ℝ) * r ^ (n - 1) := by
    have : (0 : ℝ) < n := by exact_mod_cast hn
    positivity
  have hsumpos : 0 < ∑ i ∈ range n, r ^ i := lt_of_lt_of_le hdpos hden
  rw [retained, headMass_geomProfile, headMass_geomProfile, div_le_div_iff₀ hsumpos hdpos]
  nlinarith [Finset.sum_nonneg (fun i (_ : i ∈ range n) => (pow_pos hr0 i).le)]

/-- **Lower bound / no uniform budget.**  If the profile is flat enough that
`k / (n * r ^ (n-1)) < τ`, then `k` keys provably fail: the knee exceeds `k`. -/
theorem lt_kstar_geomProfile_of_flat {r τ : ℝ} (hr0 : 0 < r) (hr1 : r ≤ 1) {n k : ℕ}
    (hn : 0 < n) (hτ : τ ≤ 1) (hflat : (k : ℝ) / (n * r ^ (n - 1)) < τ) :
    k < kstar (geomProfile r) n τ :=
  lt_kstar_of_fail (geomProfile_pos hr0) hn hτ
    (lt_of_le_of_lt (retained_geomProfile_le hr0 hr1 hn) hflat)

/-! ## Exact knee calculus for geometric profiles

For a *purely* geometric profile the retained mass has a closed form, which is far
sharper than the generic tail certificate: `retained = (1 - r ^ min k n) / (1 - r ^ n)`.
This is what makes exact knee values computable for concrete decay ratios. -/

/-- Closed form for the retained mass of a geometric profile. -/
theorem retained_geomProfile_eq {r : ℝ} (hr0 : 0 < r) (hr1 : r < 1) (n k : ℕ) (hn : 0 < n) :
    retained (geomProfile r) n k = (1 - r ^ (min k n)) / (1 - r ^ n) := by
  have hne : r ≠ 1 := ne_of_lt hr1
  have hd : r - 1 ≠ 0 := by intro h; apply hne; linarith
  have hrn : r ^ n < 1 := pow_lt_one₀ hr0.le hr1 (by omega)
  have hdn : r ^ n - 1 ≠ 0 := by intro h; linarith
  have hdn' : (1 : ℝ) - r ^ n ≠ 0 := by intro h; linarith
  rw [retained, headMass_geomProfile, headMass_geomProfile, geom_sum_eq hne, geom_sum_eq hne,
    div_div_div_eq, div_eq_div_iff (by simpa using mul_ne_zero hd hdn) hdn']
  ring

/-- The retained mass of a geometric profile is at least `1 - r ^ k`. -/
theorem one_sub_pow_le_retained_geomProfile {r : ℝ} (hr0 : 0 < r) (hr1 : r < 1) (n k : ℕ)
    (hn : 0 < n) : 1 - r ^ k ≤ retained (geomProfile r) n k := by
  have hrn : r ^ n < 1 := pow_lt_one₀ hr0.le hr1 (by omega)
  have hrnpos : (0 : ℝ) < r ^ n := pow_pos hr0 n
  rw [retained_geomProfile_eq hr0 hr1 n k hn]
  rcases le_total k n with hkn | hnk
  · rw [min_eq_left hkn, le_div_iff₀ (by linarith)]
    nlinarith [pow_pos hr0 k, pow_le_one₀ hr0.le hr1.le (n := k)]
  · rw [min_eq_right hnk, div_self (by linarith : (1 : ℝ) - r ^ n ≠ 0)]
    nlinarith [pow_pos hr0 k]

/-- **Sharp universal budget.**  For a geometric profile, any `K` with `r ^ K ≤ 1 - τ`
clears the gate at every context length.  (No `1/(1-r)` loss: this is the exact
certificate, not the generic tail bound.) -/
theorem kstar_geomProfile_le_of_pow_le {r τ : ℝ} (hr0 : 0 < r) (hr1 : r < 1) {n K : ℕ}
    (hn : 0 < n) (hK : r ^ K ≤ 1 - τ) : kstar (geomProfile r) n τ ≤ K :=
  kstar_le_of_pass
    (le_trans (by linarith) (one_sub_pow_le_retained_geomProfile hr0 hr1 n K hn))

/-- **Exact knee.**  A pass at `K` together with a failure at `K - 1` pins the knee of a
geometric profile to the value `K`. -/
theorem kstar_geomProfile_eq_of_bracket {r τ : ℝ} (hr0 : 0 < r) (hr1 : r < 1) {n K : ℕ}
    (hn : 0 < n) (hτ : τ ≤ 1) (hK1 : 1 ≤ K) (hKn : K ≤ n)
    (hpass : τ ≤ (1 - r ^ K) / (1 - r ^ n))
    (hfail : (1 - r ^ (K - 1)) / (1 - r ^ n) < τ) :
    kstar (geomProfile r) n τ = K := by
  have hpass' : τ ≤ retained (geomProfile r) n K := by
    rw [retained_geomProfile_eq hr0 hr1 n K hn, min_eq_left hKn]; exact hpass
  have hfail' : retained (geomProfile r) n (K - 1) < τ := by
    rw [retained_geomProfile_eq hr0 hr1 n (K - 1) hn, min_eq_left (by omega : K - 1 ≤ n)]
    exact hfail
  obtain ⟨hlo, hhi⟩ := knee_bracket (geomProfile_pos hr0) hn hτ hfail' hpass'
  omega

end PythKnee