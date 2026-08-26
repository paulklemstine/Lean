/-
# Synthesis: from the generator's ratio law to integer scan costs

`Novelty.GeneratorTiltWindow` decides the scan-order contest from the mean tilt of a pool;
`Novelty.GeneratorTiltRatio` computes the tilt from the generator's prime ratio.  This file
joins the two layers and pays the two debts that the idealised layers leave open:

1. **Rounding.**  A real scan runs over the *integer* window `[⌈√(N/2)⌉, ⌊√N⌋]`, not the real
   interval.  `descCost_lt_ascCost_of_real_margin` shows a half-step margin is enough to
   transfer the real comparison to the integer one.
2. **Per-key windows.**  Different keys have different windows, so the pool statement of
   `GeneratorTiltWindow` (one common window) is not directly applicable.
   `totalDescVar_lt_totalAscVar` proves the aggregation with a window per key.

The headline result is `deployed_descending_wins`: for a semiprime `N = p q` whose prime
ratio is *below* the critical ratio `24 - 16√2`, all sufficiently large `N` have
`⌈√(N/2)⌉ + ⌊√N⌋ < 2p`, i.e. the sqrt-descending scan strictly beats the window-ascending
scan on the true integer window — with an explicit threshold
`√N ≥ 1 / (2 · margin r)` where `margin r = r^{-1/2} - (1 + 2^{-1/2})/2` is positive exactly
in the top-heavy regime (`margin_pos_iff_top_heavy`).

Consequence for the Λ-channel question: a window-ascending advantage is *not* a consequence
of balance; it requires the generator's ratio mass to sit above `24 - 16√2 ≈ 1.3726`, and a
deployed-style concentration of the ratio near `1` is adversarial to it.
-/
import Novelty.GeneratorTiltWindow
import Novelty.GeneratorTiltRatio

namespace GeneratorTilt

open Finset

/-! ## Debt 1: rounding to the integer window -/

/-- Transfer from the real window to the integer window.  If the divisor `d` sits at least a
half step above the midpoint of the real window `[α, β]`, then it is above the midpoint of
the rounded integer window `[⌈α⌉, ⌊β⌋]`, so the descending scan is strictly cheaper. -/
theorem descCost_lt_ascCost_of_real_margin {α β : ℝ} {d : ℤ}
    (h : α + β + 1 ≤ 2 * (d : ℝ)) : descCost ⌊β⌋ d < ascCost ⌈α⌉ d := by
  rw [descCost_lt_ascCost_iff]
  have hc : (⌈α⌉ : ℝ) < α + 1 := Int.ceil_lt_add_one α
  have hf : (⌊β⌋ : ℝ) ≤ β := Int.floor_le β
  have : ((⌈α⌉ + ⌊β⌋ : ℤ) : ℝ) < ((2 * d : ℤ) : ℝ) := by push_cast; linarith
  exact_mod_cast this

/-! ## Debt 2: aggregating over per-key windows -/

variable {ι : Type*}

/-- Total ascending cost with a window `[a i, b i]` per key. -/
def totalAscVar (s : Finset ι) (a d : ι → ℤ) : ℤ := ∑ i ∈ s, ascCost (a i) (d i)

/-- Total descending cost with a window `[a i, b i]` per key. -/
def totalDescVar (s : Finset ι) (b d : ι → ℤ) : ℤ := ∑ i ∈ s, descCost (b i) (d i)

/-- **Pool aggregation with per-key windows.**  If every key of a nonempty pool is top-heavy
in its own window, the sqrt-descending scan strictly beats the window-ascending scan on the
whole pool. -/
theorem totalDescVar_lt_totalAscVar (s : Finset ι) (a b d : ι → ℤ) (hs : s.Nonempty)
    (h : ∀ i ∈ s, a i + b i < 2 * d i) : totalDescVar s b d < totalAscVar s a d := by
  unfold totalDescVar totalAscVar
  refine Finset.sum_lt_sum_of_nonempty hs ?_
  intro i hi
  exact (descCost_lt_ascCost_iff (a i) (b i) (d i)).mpr (h i hi)

/-- Mixed pools: a single strictly top-heavy key suffices to flip the total, provided no key
is bottom-heavy.  (Ties `a i + b i = 2 d i` are allowed.) -/
theorem totalDescVar_lt_totalAscVar_of_exists (s : Finset ι) (a b d : ι → ℤ)
    (h : ∀ i ∈ s, a i + b i ≤ 2 * d i) {j : ι} (hj : j ∈ s) (hjs : a j + b j < 2 * d j) :
    totalDescVar s b d < totalAscVar s a d := by
  unfold totalDescVar totalAscVar
  refine Finset.sum_lt_sum ?_ ⟨j, hj, ?_⟩
  · intro i hi
    unfold ascCost descCost
    have := h i hi
    omega
  · exact (descCost_lt_ascCost_iff (a j) (b j) (d j)).mpr hjs

/-! ## The margin of a ratio -/

/-- The margin by which a ratio is top-heavy: `r^{-1/2} - (1 + 2^{-1/2})/2`. -/
noncomputable def margin (r : ℝ) : ℝ := 1 / Real.sqrt r - (1 + 1 / Real.sqrt 2) / 2

/-- The margin is positive exactly in the top-heavy regime, i.e. exactly below the critical
ratio `24 - 16√2`. -/
theorem margin_pos_iff_top_heavy (r : ℝ) : 0 < margin r ↔ 1 / 2 < zOfRatio r := by
  have hd : 0 < 1 - 1 / Real.sqrt 2 := one_sub_inv_sqrt_two_pos
  unfold margin zOfRatio
  rw [lt_div_iff₀ hd]
  constructor <;> intro h <;> linarith

theorem margin_pos_of_lt_criticalRatio {r : ℝ} (hr : 0 < r) (h : r < criticalRatio) :
    0 < margin r := (margin_pos_iff_top_heavy r).mpr ((half_lt_zOfRatio_iff hr).mpr h)

/-! ## The deployed statement -/

/-- **Deployment theorem.**  Let `N = p q` with `0 < p ≤ q` and prime ratio `r = q/p`.  If
`N` is large enough that `1 ≤ 2 · margin r · √N` — possible for all large `N` exactly when
`r` is below the critical ratio, by `margin_pos_iff_top_heavy` — then on the *integer*
window `[⌈√(N/2)⌉, ⌊√N⌋]` the sqrt-descending scan strictly beats the window-ascending scan:
`⌈√(N/2)⌉ + ⌊√N⌋ < 2p`.

This is the refutation in deployable form: for a generator whose ratio concentrates below
`24 - 16√2 ≈ 1.3726` (in particular the observed deployed-style concentration near `1`),
window-ascending loses on every sufficiently large key. -/
theorem deployed_descending_wins {n : ℤ} {q : ℝ} (hp : 0 < (n : ℝ)) (hq : 0 < q)
    (hN : 1 ≤ 2 * margin (q / (n : ℝ)) * Real.sqrt ((n : ℝ) * q)) :
    descCost ⌊Real.sqrt ((n : ℝ) * q)⌋ n < ascCost ⌈Real.sqrt ((n : ℝ) * q / 2)⌉ n := by
  set p : ℝ := (n : ℝ) with hpdef
  have hw0 : (0:ℝ) < Real.sqrt 2 := sqrt_two_pos'
  have hw : Real.sqrt 2 ≠ 0 := ne_of_gt hw0
  have hsp : 0 < Real.sqrt p := Real.sqrt_pos.mpr hp
  have hsq : 0 < Real.sqrt q := Real.sqrt_pos.mpr hq
  have hSpos : 0 < Real.sqrt (p * q) := Real.sqrt_pos.mpr (by positivity)
  have hS : Real.sqrt (p * q) ≠ 0 := ne_of_gt hSpos
  have hN0 : Real.sqrt (p * q) = Real.sqrt p * Real.sqrt q := Real.sqrt_mul hp.le q
  have hr : Real.sqrt (q / p) = Real.sqrt q / Real.sqrt p := Real.sqrt_div hq.le p
  have hhalf : Real.sqrt (p * q / 2) = Real.sqrt (p * q) / Real.sqrt 2 := by
    rw [Real.sqrt_div (by positivity) 2]
  -- `p` in terms of `√N` and the ratio
  have hkey : 1 / Real.sqrt (q / p) * Real.sqrt (p * q) = p := by
    rw [hr, hN0]
    field_simp
    nlinarith [Real.mul_self_sqrt hp.le]
  have hinv : 1 / Real.sqrt (q / p) = p / Real.sqrt (p * q) := by
    rw [eq_div_iff hS]; exact hkey
  -- the margin hypothesis is exactly `α + β + 1 ≤ 2p`
  have hmain : Real.sqrt (p * q / 2) + Real.sqrt (p * q) + 1 ≤ 2 * p := by
    have hexp : 2 * margin (q / p) * Real.sqrt (p * q)
        = 2 * p - Real.sqrt (p * q) - Real.sqrt (p * q) / Real.sqrt 2 := by
      unfold margin
      rw [hinv]
      field_simp
      ring
    rw [hexp] at hN
    rw [hhalf]
    linarith
  exact descCost_lt_ascCost_of_real_margin (by linarith)

/-- Explicit threshold form: below the critical ratio, every key with
`√N ≥ 1 / (2 · margin r)` is won by the descending scan. -/
theorem deployed_descending_wins_of_lt_criticalRatio {n : ℤ} {q : ℝ} (hp : 0 < (n : ℝ))
    (hq : 0 < q) (hcrit : q / (n : ℝ) < criticalRatio)
    (hbig : 1 / (2 * margin (q / (n : ℝ))) ≤ Real.sqrt ((n : ℝ) * q)) :
    descCost ⌊Real.sqrt ((n : ℝ) * q)⌋ n < ascCost ⌈Real.sqrt ((n : ℝ) * q / 2)⌉ n := by
  have hm : 0 < margin (q / (n : ℝ)) := margin_pos_of_lt_criticalRatio (by positivity) hcrit
  refine deployed_descending_wins hp hq ?_
  rw [div_le_iff₀ (by positivity)] at hbig
  linarith [hbig]

/-! ## The scoped final statement -/

/-- **Scope of the Λ-channel (window-ascending) advantage.**  For a positive ratio `r`
exactly one of the following holds, and the dividing line `24 - 16√2 ≈ 1.3726` lies strictly
inside the balance band `(1, 2)`:

* `r < 24 - 16√2`: the population is top-heavy, the margin is positive and by
  `deployed_descending_wins` the sqrt-descending scan wins on all large keys;
* `24 - 16√2 < r`: the population is bottom-heavy and the window-ascending scan is the
  better order.

Hence enforcing balance (`q < 2p`, i.e. `r < 2`) does **not** secure a window-ascending
gain. -/
theorem lambda_channel_scope {r : ℝ} (hr : 0 < r) :
    (r < criticalRatio → 0 < margin r ∧ 1 / 2 < zOfRatio r) ∧
    (criticalRatio < r → margin r < 0 ∧ zOfRatio r < 1 / 2) ∧
    1 < criticalRatio ∧ criticalRatio < 2 := by
  refine ⟨fun h => ⟨margin_pos_of_lt_criticalRatio hr h, (half_lt_zOfRatio_iff hr).mpr h⟩,
    fun h => ⟨?_, (scan_order_scope_boundary hr).2 h⟩, criticalRatio_mem_balance_band.1,
    criticalRatio_mem_balance_band.2⟩
  have hz := (scan_order_scope_boundary hr).2 h
  have hd : 0 < 1 - 1 / Real.sqrt 2 := one_sub_inv_sqrt_two_pos
  unfold margin
  unfold zOfRatio at hz
  rw [div_lt_iff₀ hd] at hz
  linarith

end GeneratorTilt