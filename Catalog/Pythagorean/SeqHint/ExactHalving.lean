import Pythagorean.SeqHint.Adaptive

/-!
# Sequential hint pricing VII: the halving law is exact, and the pin is `⌈log₂ W⌉`

The experiment reports two things about the adaptive width recursion
`w ↦ ⌈w / 2⌉` that are worth separating.  The *empirical* log-slope of the
speedup curve came out at `-0.6589` (unbalanced, passing the `-ln 2` test) and
`-0.5836` (balanced, failing it) — a band-entry phase effect of the sampled
factor positions.  The *law itself* is exact, and this file proves it.

* `halfIter_eq_ceilDiv` — closed form: `k` halvings of a width `w` window leave
  exactly `⌈w / 2 ^ k⌉ = (w + 2 ^ k - 1) / 2 ^ k` candidates.  No approximation,
  no drift, for every `w` and `k`.

* `halfIter_le_one_iff` — the window is pinned after `k` queries **iff**
  `w ≤ 2 ^ k`.

* `min_queries_eq_clog` — therefore the exact isolation budget is
  `⌈log₂ w⌉ = Nat.clog 2 w`, and it is a *least* element: the pin observed at
  `k = 20` for a `2 ^ 20` window, and at `k = 12` for the `3600`-candidate
  balanced support, is forced.

* `halving_log_slope` — on the exact model the log-residual is affine in `k`
  with slope exactly `-ln 2`, which is the `A10` prediction.
-/

namespace Pythagorean.SeqHint

/-- Ceiling-division characterisation used to iterate the halving law. -/
lemma ceil_div_le_iff {x c a : ℕ} (ha : 0 < a) : (x + a - 1) / a ≤ c ↔ x ≤ a * c := by
  rw [Nat.div_le_iff_le_mul_add_pred ha]
  omega

/-- **The halving law is exact.**  After `k` adaptive queries the worst-case
residual window is exactly `⌈w / 2 ^ k⌉`. -/
theorem halfIter_eq_ceilDiv : ∀ (k w : ℕ), halfIter k w = (w + 2 ^ k - 1) / 2 ^ k := by
  intro k
  induction k with
  | zero => intro w; simp [halfIter]
  | succ k ih =>
      intro w
      have ha : 0 < 2 ^ k := pow_pos (by norm_num) k
      have hkey : ∀ c : ℕ,
          (((w + 1) / 2 + 2 ^ k - 1) / 2 ^ k ≤ c ↔ (w + 2 ^ (k + 1) - 1) / 2 ^ (k + 1) ≤ c) := by
        intro c
        have h2 : (0 : ℕ) < 2 ^ (k + 1) := pow_pos (by norm_num) (k + 1)
        have hpow : (2 : ℕ) ^ (k + 1) = 2 * 2 ^ k := by ring
        rw [ceil_div_le_iff ha, ceil_div_le_iff h2, hpow]
        have hassoc : 2 * 2 ^ k * c = 2 * (2 ^ k * c) := by ring
        rw [hassoc]
        omega
      rw [halfIter, ih ((w + 1) / 2)]
      exact Nat.le_antisymm ((hkey _).2 le_rfl) ((hkey _).1 le_rfl)

/-- The window is pinned after `k` adaptive queries exactly when it started with
at most `2 ^ k` candidates. -/
theorem halfIter_le_one_iff (k w : ℕ) : halfIter k w ≤ 1 ↔ w ≤ 2 ^ k := by
  constructor
  · induction k generalizing w with
    | zero => intro h; simpa [halfIter] using h
    | succ k ih =>
        intro h
        have hk : (w + 1) / 2 ≤ 2 ^ k := ih _ h
        have hpow : (2 : ℕ) ^ (k + 1) = 2 * 2 ^ k := by ring
        omega
  · exact halfIter_le_one k w

/-- **The exact isolation budget is `⌈log₂ w⌉`.**  It is the least number of
adaptive queries that pins the window — the `k = 20` pin of the experiment for
a `2 ^ 20` window, and `k = 12` for the `3600`-wide balanced support, are both
forced by this. -/
theorem min_queries_eq_clog (w : ℕ) :
    IsLeast {k : ℕ | halfIter k w ≤ 1} (Nat.clog 2 w) := by
  constructor
  · exact (halfIter_le_one_iff _ w).2 (Nat.le_pow_clog (by norm_num) w)
  · intro k hk
    exact (Nat.clog_le_iff_le_pow (by norm_num)).2 ((halfIter_le_one_iff k w).1 hk)

/-- The `2 ^ 20` window of the bit-length-40 experiment pins at exactly `20`. -/
theorem clog_window_twenty : Nat.clog 2 (2 ^ 20) = 20 := by
  have h1 : Nat.clog 2 (2 ^ 20) ≤ 20 := (Nat.clog_le_iff_le_pow (by norm_num)).2 le_rfl
  have h2 : ¬ (Nat.clog 2 (2 ^ 20) ≤ 19) := by
    intro h
    have := (Nat.clog_le_iff_le_pow (b := 2) (x := 2 ^ 20) (y := 19) (by norm_num)).1 h
    norm_num at this
  omega

/-- The `3600`-candidate balanced support pins at exactly `12`. -/
theorem clog_balanced_twelve : Nat.clog 2 3600 = 12 := by
  have h1 : Nat.clog 2 3600 ≤ 12 := (Nat.clog_le_iff_le_pow (by norm_num)).2 (by norm_num)
  have h2 : ¬ (Nat.clog 2 3600 ≤ 11) := by
    intro h
    have := (Nat.clog_le_iff_le_pow (b := 2) (x := 3600) (y := 11) (by norm_num)).1 h
    norm_num at this
  omega

/-- **The `-ln 2` slope law, exactly.**  On the model the log of the residual
window is affine in the number of adaptive queries, with slope `-ln 2`. -/
theorem halving_log_slope (m k : ℕ) (hk : k ≤ m) :
    Real.log (halfIter k (2 ^ m)) = Real.log (2 ^ m) - k * Real.log 2 := by
  rw [halfIter_pow k m hk]
  push_cast
  rw [Real.log_pow, Real.log_pow, Nat.cast_sub hk]
  ring

end Pythagorean.SeqHint