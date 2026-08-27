/-
# The lag spectrum of the sieve polynomial

`Logic.JFeatureConsecutiveDependency` computed the dependency between positions
`v` and `v+1`.  The pre-registered consecutive-`v` study is really a statement
about *one* lag; this file computes the whole spectrum at once, for every lag
`k ≠ 0`, and shows it is completely rigid.

For an odd prime `q`, a nonzero square target `N = r²`, and any lag `k ≠ 0`:

* `four_mul_eq_sq_of_lag` : if `q` divides both `y_v` and `y_{v+k}` then
  necessarily `4N = k²`.  (No hypothesis on `q` beyond primality is needed: the
  argument is `k · (2(s+v) + k) = 0` in a field.)
* `pairSetLag_eq_empty`, `pairSetLag_eq_singleton`, `card_pairSetLag_dichotomy` :
  the number of lag-`k` double hits is exactly `0`, or exactly `1` on the
  exceptional locus `4N = k²`.
* `cov_lag_eq` : the exact covariance `(#pairSetLag)/q - (2/q)²`.
* `lag_spectrum_flat` : **the spectrum is flat.**  For every non-exceptional lag
  the covariance is exactly `-4/q²`, independent of `k`.
* `exceptional_lag_iff`, `card_exceptionalLags` : the exceptional lags are
  exactly `k = ±2r`, so **exactly two** of the `q-1` nonzero lags carry a
  positive covariance and all the others carry the same negative one.

So the adjacent (`k = 1`) result of paper 248's follow-up is not special to
adjacency: the dependency is a global, lag-independent property of the sieve
polynomial, with a two-point exceptional set determined by the target.  A
statistic that averages over lags therefore loses no signal, which is the
design-relevant consequence.
-/
import Logic.JFeatureConsecutiveDependency

namespace Logic.JFeature

open Finset Logic.PhaseRoute

section LagSpectrum

variable {q : ℕ} [Fact (Nat.Prime q)]

/-- The residues `v` at which `q` divides both `y_v` and `y_{v+k}`. -/
def pairSetLag (k s N : ZMod q) : Finset (ZMod q) :=
  univ.filter (fun v => yv s N v = 0 ∧ yv s N (v + k) = 0)

lemma mem_pairSetLag {k s N v : ZMod q} :
    v ∈ pairSetLag k s N ↔ (s + v) ^ 2 = N ∧ (s + (v + k)) ^ 2 = N := by
  simp [pairSetLag, yv, sub_eq_zero]

/-- **The lag obstruction.**  A double hit at lag `k ≠ 0` forces `4N = k²`. -/
theorem four_mul_eq_sq_of_lag {k s N v : ZMod q} (hk : k ≠ 0)
    (hv : v ∈ pairSetLag k s N) : 4 * N = k ^ 2 := by
  rw [mem_pairSetLag] at hv
  obtain ⟨h1, h2⟩ := hv
  have hfac : k * (2 * (s + v) + k) = 0 := by
    have : (s + (v + k)) ^ 2 - (s + v) ^ 2 = k * (2 * (s + v) + k) := by ring
    rw [← this, h1, h2, sub_self]
  have hlin : 2 * (s + v) + k = 0 := by
    rcases mul_eq_zero.1 hfac with h | h
    · exact absurd h hk
    · exact h
  have hk2 : k = -(2 * (s + v)) := by linear_combination hlin
  rw [hk2, ← h1]
  ring

/-- Off the exceptional locus there are no lag-`k` double hits. -/
theorem pairSetLag_eq_empty {k s N : ZMod q} (hk : k ≠ 0) (h : 4 * N ≠ k ^ 2) :
    pairSetLag k s N = ∅ := by
  rw [Finset.eq_empty_iff_forall_notMem]
  exact fun v hv => h (four_mul_eq_sq_of_lag hk hv)

/-- On the exceptional locus `4N = k²` there is exactly one lag-`k` double hit,
at the midpoint `v = -(k/2) - s`. -/
theorem pairSetLag_eq_singleton {k s N : ZMod q} (hq : q ≠ 2) (hk : k ≠ 0)
    (h : 4 * N = k ^ 2) : pairSetLag k s N = {-(2⁻¹ * k) - s} := by
  have h2 : (2 : ZMod q) ≠ 0 := two_ne_zero_of_ne_two hq
  have hN : N = (2⁻¹ * k) ^ 2 := by
    have h4 : (4 : ZMod q) = 2 * 2 := by norm_num
    field_simp at h ⊢
    linear_combination h
  ext v
  rw [mem_pairSetLag, Finset.mem_singleton]
  constructor
  · rintro ⟨h1, hh2⟩
    have hfac : k * (2 * (s + v) + k) = 0 := by
      have : (s + (v + k)) ^ 2 - (s + v) ^ 2 = k * (2 * (s + v) + k) := by ring
      rw [← this, h1, hh2, sub_self]
    have hlin : 2 * (s + v) + k = 0 := by
      rcases mul_eq_zero.1 hfac with hx | hx
      · exact absurd hx hk
      · exact hx
    have : (2 : ZMod q) * v = 2 * (-(2⁻¹ * k) - s) := by
      field_simp
      linear_combination hlin
    exact mul_left_cancel₀ h2 this
  · rintro rfl
    have hx : s + (-(2⁻¹ * k) - s) = -(2⁻¹ * k) := by ring
    have hy : s + ((-(2⁻¹ * k) - s) + k) = 2⁻¹ * k := by
      field_simp
      ring
    rw [hx, hy, hN]
    exact ⟨by ring, rfl⟩

theorem card_pairSetLag_dichotomy {k s N : ZMod q} (hq : q ≠ 2) (hk : k ≠ 0) :
    (pairSetLag k s N).card = 0 ∨ (pairSetLag k s N).card = 1 := by
  by_cases h : 4 * N = k ^ 2
  · exact Or.inr (by rw [pairSetLag_eq_singleton hq hk h, Finset.card_singleton])
  · exact Or.inl (by rw [pairSetLag_eq_empty hk h, Finset.card_empty])

/-! ### The covariance at an arbitrary lag -/

/-- The divisibility indicator read `k` positions later. -/
noncomputable def hitIndLag (s N k : ZMod q) : ZMod q → ℝ := fun v => hitInd s N (v + k)

lemma avg_hitIndLag (s N k : ZMod q) :
    avg (hitIndLag s N k) = ((divSet s N).card : ℝ) / (q : ℝ) := by
  have hshift : ∑ v : ZMod q, hitInd s N (v + k) = ∑ v : ZMod q, hitInd s N v :=
    Fintype.sum_equiv (Equiv.addRight k) _ _ (fun v => rfl)
  simp only [avg, hitIndLag, hshift]
  rw [← avg, avg_hitInd]

lemma avg_hitInd_mul_lag (s N k : ZMod q) :
    avg (fun v => hitInd s N v * hitIndLag s N k v)
      = ((pairSetLag k s N).card : ℝ) / (q : ℝ) := by
  have hcard : Fintype.card (ZMod q) = q := ZMod.card q
  have hprod : ∀ v : ZMod q, hitInd s N v * hitIndLag s N k v
      = if (yv s N v = 0 ∧ yv s N (v + k) = 0) then (1 : ℝ) else 0 := by
    intro v
    by_cases h1 : yv s N v = 0 <;> by_cases h2 : yv s N (v + k) = 0 <;>
      simp [hitInd, hitIndLag, h1, h2]
  simp only [avg, hprod, hcard]
  congr 1
  simp [pairSetLag]

/-- **The exact lag-`k` covariance.** -/
theorem cov_lag_eq (s N k : ZMod q) :
    cov (hitInd s N) (hitIndLag s N k)
      = ((pairSetLag k s N).card : ℝ) / (q : ℝ)
        - (((divSet s N).card : ℝ) / (q : ℝ)) ^ 2 := by
  rw [cov, avg_hitInd_mul_lag, avg_hitInd, avg_hitIndLag]
  ring

/-- **The lag spectrum is flat.**  For every nonzero lag off the exceptional
locus the covariance is exactly `-4/q²`, with no dependence on the lag. -/
theorem lag_spectrum_flat (hq : q ≠ 2) (s : ZMod q) {k r : ZMod q} (hk : k ≠ 0)
    (hr : r ≠ 0) (h : k ^ 2 ≠ 4 * r ^ 2) :
    cov (hitInd s (r ^ 2)) (hitIndLag s (r ^ 2) k) = -(4 / (q : ℝ) ^ 2) := by
  rw [cov_lag_eq, pairSetLag_eq_empty hk (fun hc => h hc.symm), card_divSet hq s r hr]
  norm_num
  ring

/-- On an exceptional lag the covariance jumps to `1/q - 4/q²`. -/
theorem cov_lag_exceptional (hq : q ≠ 2) (s : ZMod q) {k r : ZMod q} (hk : k ≠ 0)
    (hr : r ≠ 0) (h : k ^ 2 = 4 * r ^ 2) :
    cov (hitInd s (r ^ 2)) (hitIndLag s (r ^ 2) k) = 1 / (q : ℝ) - 4 / (q : ℝ) ^ 2 := by
  rw [cov_lag_eq, pairSetLag_eq_singleton hq hk h.symm, card_divSet hq s r hr]
  norm_num
  ring

/-- **The exceptional lags are exactly `±2r`.** -/
theorem exceptional_lag_iff (k r : ZMod q) : 4 * r ^ 2 = k ^ 2 ↔ k = 2 * r ∨ k = -(2 * r) := by
  constructor
  · intro h
    have hfac : (k - 2 * r) * (k + 2 * r) = 0 := by linear_combination -h
    rcases mul_eq_zero.1 hfac with hx | hx
    · exact Or.inl (by linear_combination hx)
    · exact Or.inr (by linear_combination hx)
  · rintro (rfl | rfl) <;> ring

/-- The exceptional lags form a two-element set: out of the `q-1` nonzero lags,
exactly two carry a positive covariance and every other one carries the same
negative covariance `-4/q²`. -/
theorem card_exceptionalLags (hq : q ≠ 2) {r : ZMod q} (hr : r ≠ 0) :
    (univ.filter (fun k : ZMod q => 4 * r ^ 2 = k ^ 2)).card = 2 := by
  have hset : (univ.filter (fun k : ZMod q => 4 * r ^ 2 = k ^ 2))
      = ({2 * r, -(2 * r)} : Finset (ZMod q)) := by
    ext k
    simp only [Finset.mem_filter, Finset.mem_univ, true_and, Finset.mem_insert,
      Finset.mem_singleton]
    exact exceptional_lag_iff k r
  have h2 : (2 : ZMod q) ≠ 0 := two_ne_zero_of_ne_two hq
  have hne : (2 * r : ZMod q) ≠ -(2 * r) := by
    intro h
    have : (2 : ZMod q) * (2 * r) = 0 := by linear_combination h
    rcases mul_eq_zero.1 this with hx | hx
    · exact h2 hx
    · rcases mul_eq_zero.1 hx with hy | hy
      · exact h2 hy
      · exact hr hy
  rw [hset, Finset.card_insert_of_notMem (by simpa using hne), Finset.card_singleton]

/-- **No lag is independent.**  For `q ≥ 5` and any nonzero square target, every
nonzero lag has nonzero covariance — negative at all but two lags, positive at
those two. -/
theorem lag_dependency (hq5 : 5 ≤ q) (s : ZMod q) {k r : ZMod q} (hk : k ≠ 0) (hr : r ≠ 0) :
    cov (hitInd s (r ^ 2)) (hitIndLag s (r ^ 2) k) ≠ 0 := by
  have hq : q ≠ 2 := by omega
  have hqR : (5 : ℝ) ≤ (q : ℝ) := by exact_mod_cast hq5
  have hqpos : (0 : ℝ) < (q : ℝ) := by linarith
  by_cases h : k ^ 2 = 4 * r ^ 2
  · rw [cov_lag_exceptional hq s hk hr h]
    have : 0 < 1 / (q : ℝ) - 4 / (q : ℝ) ^ 2 := by
      rw [sub_pos, div_lt_div_iff₀ (by positivity) hqpos]
      nlinarith
    linarith
  · rw [lag_spectrum_flat hq s hk hr h]
    have : 0 < 4 / (q : ℝ) ^ 2 := by positivity
    linarith

end LagSpectrum

end Logic.JFeature