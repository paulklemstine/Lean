import Mathlib

/-!
# Sequential hint pricing III: the downstream Fermat scan and the two strata

The hint-pricing experiment prices the *downstream* work of a hinted factoring
attempt in Fermat (difference-of-squares) steps: after the hints have narrowed
the position of the smaller factor, the scan walks `a = ⌈√N⌉, ⌈√N⌉ + 1, …` until
`a ^ 2 - N` is a square.  The baseline cost `T₀` of that scan is what the
speedup `s(k)` is measured against, and it is the sole reason the experiment has
two strata at all: `T₀` depends only on the imbalance `ρ = q / p`.

This file proves the arithmetic and the analysis behind that.

* `fermat_pair` — for odd `p ≤ q` the Fermat scan really does terminate at
  `a = (p + q) / 2` with `b = (q - p) / 2`, i.e. `a ^ 2 = N + b ^ 2`.

* `fermat_factor_iff_pythagorean` — the **cross-domain bridge**: on a perfect
  square `N = k ^ 2`, the pairs `(a, b)` the Fermat scan looks for are *exactly*
  the Pythagorean triples with leg `k`.  Factoring `k ^ 2` by difference of
  squares is literally enumerating Pythagorean triples on that leg, which is why
  this experiment lives in the Pythagorean catalog.

* `fermat_offset_sqrt` — the closed form for the scan length,
  `(p + q) / 2 - √N = (√q - √p) ^ 2 / 2`, i.e. the scan is short exactly when
  the semiprime is balanced.

* `scanUnits`, `scanUnits_strict_mono`, `stratum_contrast` — the scan length in
  units of `√N` as a function of `u = √ρ`, its strict monotonicity, and the
  quantitative separation of the experiment's two strata: with
  `ρ_bal ∈ [1, 1.01]` and `ρ_unb ≥ 7.5`, the unbalanced scan is at least
  `10 ^ 4` times longer.  (The experiment's measured `T₀` ratio is smaller
  because the priced divisibility-test count carries a per-test constant and an
  additive floor; the model bound below is on the pure scan length.)
-/

namespace Pythagorean.SeqHint

/-! ## The Fermat scan, arithmetically -/

/-- **Fermat's difference of squares.**  For odd `p ≤ q` the scan terminates at
`a = (p + q) / 2`, where `a ^ 2 - N` is the square of `b = (q - p) / 2`. -/
theorem fermat_pair (p q : ℕ) (hp : Odd p) (hq : Odd q) (hpq : p ≤ q) :
    ∃ a b : ℕ, b ≤ a ∧ 2 * a = p + q ∧ 2 * b = q - p ∧ a ^ 2 = p * q + b ^ 2 := by
  obtain ⟨i, rfl⟩ := hp
  obtain ⟨j, rfl⟩ := hq
  have hij : i ≤ j := by omega
  refine ⟨i + j + 1, j - i, by omega, by omega, by omega, ?_⟩
  obtain ⟨c, rfl⟩ : ∃ c, j = i + c := ⟨j - i, by omega⟩
  have : i + c - i = c := by omega
  rw [this]
  ring

/-- **Cross-domain bridge to Pythagorean triples.**  For `b ≤ a`, the pair
`(a, b)` is a Fermat witness for the perfect square `N = k ^ 2` exactly when
`(k, b, a)` is a Pythagorean triple.  Difference-of-squares factoring of `k ^ 2`
*is* the enumeration of Pythagorean triples with leg `k`. -/
theorem fermat_factor_iff_pythagorean (k a b : ℕ) (hb : b ≤ a) :
    (a - b) * (a + b) = k ^ 2 ↔ k ^ 2 + b ^ 2 = a ^ 2 := by
  have hsq : (a - b) * (a + b) = a ^ 2 - b ^ 2 := by
    obtain ⟨c, rfl⟩ : ∃ c, a = b + c := ⟨a - b, by omega⟩
    have h1 : b + c - b = c := by omega
    rw [h1]
    exact Nat.eq_sub_of_add_eq (by ring)
  rw [hsq]
  have hb2 : b ^ 2 ≤ a ^ 2 := Nat.pow_le_pow_left hb 2
  omega

/-! ## The scan length: closed form and stratum dependence -/

/-- **Closed form for the Fermat scan length.**  The scan starts at `√N` and
ends at `(p + q) / 2`, so its length is `(√q - √p) ^ 2 / 2`: quadratic in the
gap between the square roots of the two factors. -/
theorem fermat_offset_sqrt (p q : ℝ) (hp : 0 ≤ p) (hq : 0 ≤ q) :
    (p + q) / 2 - Real.sqrt (p * q) = (Real.sqrt q - Real.sqrt p) ^ 2 / 2 := by
  have hsp : Real.sqrt p ^ 2 = p := Real.sq_sqrt hp
  have hsq : Real.sqrt q ^ 2 = q := Real.sq_sqrt hq
  have hmul : Real.sqrt (p * q) = Real.sqrt p * Real.sqrt q := Real.sqrt_mul hp q
  rw [hmul]
  linear_combination (-(1 : ℝ) / 2) * hsp - ((1 : ℝ) / 2) * hsq

/-- The Fermat scan length in units of `√N`, as a function of `u = √ρ` where
`ρ = q / p ≥ 1` is the imbalance. -/
noncomputable def scanUnits (u : ℝ) : ℝ := (u - 1) ^ 2 / (2 * u)

/-- `scanUnits` really is the scan length divided by `√N`: writing `p = s ^ 2`,
`q = t ^ 2`, the scan length is `s t · scanUnits (t / s)`. -/
theorem scan_offset_eq (s t : ℝ) (hs : 0 < s) (ht : 0 < t) :
    (s ^ 2 + t ^ 2) / 2 - s * t = (s * t) * scanUnits (t / s) := by
  unfold scanUnits
  field_simp
  ring

/-- A perfectly balanced semiprime needs no scan at all. -/
@[simp] theorem scanUnits_one : scanUnits 1 = 0 := by norm_num [scanUnits]

/-- **The scan length is strictly increasing in the imbalance.**  This is the
sole source of the experiment's stratification. -/
theorem scanUnits_strict_mono {u₁ u₂ : ℝ} (h₁ : 1 ≤ u₁) (h : u₁ < u₂) :
    scanUnits u₁ < scanUnits u₂ := by
  have hu₁ : 0 < u₁ := lt_of_lt_of_le one_pos h₁
  have hu₂ : 0 < u₂ := hu₁.trans h
  unfold scanUnits
  rw [div_lt_div_iff₀ (by positivity) (by positivity)]
  nlinarith [sq_nonneg (u₂ - u₁), sq_nonneg (u₁ - 1), mul_pos hu₁ hu₂]

/-- Balanced stratum: for `ρ ≤ 1.01` the scan is shorter than `√N / 60000`. -/
theorem scanUnits_balanced {ρ : ℝ} (h₁ : 1 ≤ ρ) (h₂ : ρ ≤ 1.01) :
    scanUnits (Real.sqrt ρ) ≤ 1 / 60000 := by
  set u := Real.sqrt ρ with hu
  have hu0 : 0 < u := Real.sqrt_pos.2 (by linarith)
  have husq : u ^ 2 = ρ := Real.sq_sqrt (by linarith)
  have hu1 : 1 ≤ u := by nlinarith
  have hu2 : u ≤ 1.005 := by nlinarith
  unfold scanUnits
  rw [div_le_div_iff₀ (by positivity) (by norm_num)]
  nlinarith

/-- Unbalanced stratum: for `ρ ≥ 7.5` the scan is longer than `√N / 2`. -/
theorem scanUnits_unbalanced {ρ : ℝ} (h : 7.5 ≤ ρ) :
    1 / 2 ≤ scanUnits (Real.sqrt ρ) := by
  set u := Real.sqrt ρ with hu
  have hρ : (0:ℝ) < ρ := by linarith
  have hu0 : 0 < u := Real.sqrt_pos.2 hρ
  have husq : u ^ 2 = ρ := Real.sq_sqrt (le_of_lt hρ)
  have hu27 : 2.7 ≤ u := by nlinarith
  have hmono : scanUnits (Real.sqrt 7.5) ≤ scanUnits u := by
    rcases eq_or_lt_of_le (Real.sqrt_le_sqrt h) with heq | hlt
    · rw [heq]
    · exact le_of_lt (scanUnits_strict_mono (by
        have : (1:ℝ) = Real.sqrt 1 := by simp
        rw [this]
        exact Real.sqrt_le_sqrt (by norm_num)) hlt)
  have hs75 : Real.sqrt 7.5 ^ 2 = 7.5 := Real.sq_sqrt (by norm_num)
  have hs0 : 0 < Real.sqrt 7.5 := Real.sqrt_pos.2 (by norm_num)
  have hlow : 2.7 ≤ Real.sqrt 7.5 := by nlinarith
  have hhigh : Real.sqrt 7.5 ≤ 2.8 := by nlinarith
  have : 1 / 2 ≤ scanUnits (Real.sqrt 7.5) := by
    unfold scanUnits
    rw [le_div_iff₀ (by positivity)]
    nlinarith
  linarith

/-- **Stratum contrast.**  In the idealized model the unbalanced stratum's
Fermat scan is at least `10 ^ 4` times longer than the balanced one — a single
parameter `ρ` produces the two regimes the hint experiment measures. -/
theorem stratum_contrast {ρb ρu : ℝ} (hb₁ : 1 ≤ ρb) (hb₂ : ρb ≤ 1.01) (hu : 7.5 ≤ ρu) :
    10000 * scanUnits (Real.sqrt ρb) ≤ scanUnits (Real.sqrt ρu) := by
  have h1 := scanUnits_balanced hb₁ hb₂
  have h2 := scanUnits_unbalanced hu
  linarith

end Pythagorean.SeqHint