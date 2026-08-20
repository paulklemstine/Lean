/-
# Short-interval (additive window) gaps for Chebotarev geodesic counting functions

Motivated by *"Chebotarev geodesic theorem: non-split case"* and continuing the development in
`Shared.ChebotarevGeodesic`, `Shared.ChebotarevGeodesicEffective` and
`Shared.ChebotarevGeodesicTorus`.

`eventually_lt_of_window` (in `ChebotarevGeodesicEffective.lean`) proves the *multiplicative*
window statement: if `π x = c x^β + O(x^{θ+ε})` with `θ < β`, then every dilated window
`[x, λ x]`, `λ > 1`, eventually contains a new geodesic.  This file proves the much stronger
**additive** (short-interval) statement predicted by conjecture C4 of `FUTURE_DIRECTIONS.md`:

* `rpow_bernoulli_add_le` : the scaled Bernoulli inequality
  `x^β + β x^{β-1} h ≤ (x+h)^β` for `β ≥ 1`, `x > 0`, `h ≥ 0`;
* `eventually_lt_of_additive_window` : for every exponent `γ` with
  `1 - (β - θ) < γ ≤ 1` the interval `[x, x + x^{γ}]` eventually contains a point counted
  by `π`;
* `exists_additive_window_threshold` : the same statement in explicit `∃ X₀, ∀ x ≥ X₀` form;
* `chebotarev_gap_25_36` : the numerical instance of the paper — with main term `c·x` and
  exponent `25/36`, consecutive geodesics of a fixed conjugacy class are at distance
  `≪ x^{25/36 + ε}`;
* `torusCount_eq_of_mem_Ico`, `torusCount_no_short_gaps` : the *sharpness boundary*.  For the
  single non-split torus, whose main term is logarithmic rather than a positive power, the
  conclusion fails for **every** `γ < 1`: there are arbitrarily large `x` with no geodesic at
  all in `[x, x + x^{γ}]`.  So a power-size main term is not a technical convenience in
  `eventually_lt_of_additive_window`, it is exactly what makes short-interval gaps possible.
-/

import Mathlib
import Catalog.Shared.ChebotarevGeodesic
import Catalog.Shared.ChebotarevGeodesicEffective
import Catalog.Shared.ChebotarevGeodesicTorus

open Finset Filter
open scoped Topology

namespace ChebotarevGeodesic

/-! ## A scaled Bernoulli inequality -/

/-- **Scaled Bernoulli inequality.**  For `β ≥ 1`, `x > 0` and `h ≥ 0`,
`(x + h)^β ≥ x^β + β x^{β-1} h`: the tangent line at `x` stays below the graph.  This is the
quantitative input that converts a main term `c x^β` into a *lower bound for the increment*
over a short interval. -/
theorem rpow_bernoulli_add_le {x h β : ℝ} (hx : 0 < x) (hh : 0 ≤ h) (hβ : 1 ≤ β) :
    x ^ β + β * x ^ (β - 1) * h ≤ (x + h) ^ β := by
  have hs0 : (0 : ℝ) ≤ h / x := by positivity
  have hs : (-1 : ℝ) ≤ h / x := by linarith
  have key := one_add_mul_self_le_rpow_one_add hs hβ
  have hxb : (0 : ℝ) < x ^ β := Real.rpow_pos_of_pos hx β
  have h1 : (x + h) ^ β = x ^ β * (1 + h / x) ^ β := by
    rw [← Real.mul_rpow hx.le (by positivity)]
    congr 1
    field_simp
  have h2 : x ^ (β - 1) = x ^ β / x := by rw [Real.rpow_sub hx, Real.rpow_one]
  rw [h1, h2]
  have h3 := mul_le_mul_of_nonneg_left key hxb.le
  calc x ^ β + β * (x ^ β / x) * h = x ^ β * (1 + β * (h / x)) := by field_simp
    _ ≤ x ^ β * (1 + h / x) ^ β := h3

/-! ## Geodesics in short intervals -/

/-- **Short-interval (additive window) theorem.**  Let `π` be a counting function with main term
`c x^β` (`c > 0`, `β ≥ 1`) and error exponent `θ ≥ 0` with `θ < β`.  Then for every window
exponent `γ` with

  `1 - (β - θ) < γ ≤ 1`

the interval `[x, x + x^{γ}]` eventually contains a point counted by `π`, i.e.
`π x < π (x + x^{γ})` for all large `x`.

The proof balances the increment of the main term, which is `≥ c β x^{β-1+γ}` by the scaled
Bernoulli inequality, against the two error terms, of total size `≪ x^{θ+ε}`; the hypothesis on
`γ` is exactly the statement that the first exponent beats the second. -/
theorem eventually_lt_of_additive_window {pi : ℝ → ℝ} {θ β c γ : ℝ}
    (h : HasErrorExponent pi (fun x => c * x ^ β) θ) (hc : 0 < c) (hβ : 1 ≤ β) (hθ : 0 ≤ θ)
    (hγ1 : γ ≤ 1) (hγ : 1 - (β - θ) < γ) :
    ∀ᶠ x in atTop, pi x < pi (x + x ^ γ) := by
  set gap : ℝ := γ - 1 + β - θ with hgapdef
  have hgap : 0 < gap := by simp only [hgapdef]; linarith
  set ε : ℝ := gap / 2 with hεdef
  have hε : 0 < ε := by positivity
  set θ' : ℝ := θ + ε with hθ'def
  have hθ'0 : 0 ≤ θ' := by simp only [hθ'def]; linarith
  have hlt : θ' < β - 1 + γ := by simp only [hθ'def, hεdef, hgapdef]; linarith
  obtain ⟨C, hC, X, hX, hb⟩ := h ε hε
  set t : ℝ := (2 : ℝ) ^ θ' with htdef
  have ht : 0 < t := Real.rpow_pos_of_pos (by norm_num) _
  have hdom := eventually_rpow_lt_rpow (a := θ') (b := β - 1 + γ)
    (K := C * t + C) (L := c * β) hlt (by positivity) (by nlinarith)
  filter_upwards [hdom, eventually_ge_atTop X, eventually_ge_atTop (1 : ℝ)] with x hx hxX hx1
  have hx0 : (0 : ℝ) < x := lt_of_lt_of_le zero_lt_one hx1
  have hxγ : (0 : ℝ) < x ^ γ := Real.rpow_pos_of_pos hx0 _
  have hxγx : x ^ γ ≤ x := by
    calc x ^ γ ≤ x ^ (1 : ℝ) := Real.rpow_le_rpow_of_exponent_le hx1 hγ1
      _ = x := Real.rpow_one x
  have hxX' : X ≤ x + x ^ γ := by linarith
  have h1 := hb x hxX
  have h2 := hb (x + x ^ γ) hxX'
  simp only [← hθ'def] at h1 h2
  have hA : x ^ (β - 1) * x ^ γ = x ^ (β - 1 + γ) := (Real.rpow_add hx0 _ _).symm
  have hbern := rpow_bernoulli_add_le hx0 hxγ.le hβ
  rw [mul_assoc, hA] at hbern
  have hQ : (x + x ^ γ) ^ θ' ≤ t * x ^ θ' := by
    have h2x : x + x ^ γ ≤ 2 * x := by linarith
    calc (x + x ^ γ) ^ θ' ≤ (2 * x) ^ θ' := Real.rpow_le_rpow (by positivity) h2x hθ'0
      _ = t * x ^ θ' := by rw [Real.mul_rpow (by norm_num) hx0.le]
  have hup : pi x ≤ c * x ^ β + C * x ^ θ' := by
    have := abs_le.mp h1; linarith [this.2]
  have hlow : c * (x + x ^ γ) ^ β - C * (x + x ^ γ) ^ θ' ≤ pi (x + x ^ γ) := by
    have := abs_le.mp h2; linarith [this.1]
  have step1 : c * (x ^ β + β * x ^ (β - 1 + γ)) ≤ c * (x + x ^ γ) ^ β :=
    mul_le_mul_of_nonneg_left hbern hc.le
  have step2 : C * (x + x ^ γ) ^ θ' ≤ C * (t * x ^ θ') :=
    mul_le_mul_of_nonneg_left hQ hC.le
  linarith

/-- The short-interval theorem in explicit threshold form. -/
theorem exists_additive_window_threshold {pi : ℝ → ℝ} {θ β c γ : ℝ}
    (h : HasErrorExponent pi (fun x => c * x ^ β) θ) (hc : 0 < c) (hβ : 1 ≤ β) (hθ : 0 ≤ θ)
    (hγ1 : γ ≤ 1) (hγ : 1 - (β - θ) < γ) :
    ∃ X₀ ≥ (1 : ℝ), ∀ x ≥ X₀, pi x < pi (x + x ^ γ) := by
  obtain ⟨X, hX⟩ := eventually_atTop.mp (eventually_lt_of_additive_window h hc hβ hθ hγ1 hγ)
  exact ⟨max X 1, le_max_right _ _, fun x hx => hX x (le_trans (le_max_left _ _) hx)⟩

/-- **The numerical instance of the paper.**  A conjugacy class counting function with density
`d > 0`, main term `d·c·x` and error exponent `25/36` has geodesics in every short interval
`[x, x + x^{γ}]` with `25/36 < γ ≤ 1`: the gaps between consecutive geodesics in a fixed
conjugacy class are `O(x^{25/36 + ε})`. -/
theorem chebotarev_gap_25_36 {piC : ℝ → ℝ} {d c γ : ℝ} (hd : 0 < d) (hc : 0 < c)
    (hγ1 : γ ≤ 1) (hγ : 25 / 36 < γ)
    (h : HasErrorExponent piC (fun x => (d * c) * x ^ (1 : ℝ)) (25 / 36)) :
    ∀ᶠ x in atTop, piC x < piC (x + x ^ γ) :=
  eventually_lt_of_additive_window h (by positivity) le_rfl (by norm_num) hγ1 (by linarith)

/-! ## Sharpness: a logarithmic main term admits arbitrarily long gaps -/

/-- The counting function of a single non-split torus is constant on each interval
`[ε^{2k}, ε^{2k+2})`. -/
theorem torusCount_eq_of_mem_Ico {e : ℝ} (he : 1 < e) {k : ℕ} {y : ℝ}
    (h1 : e ^ (2 * k) ≤ y) (h2 : y < e ^ (2 * (k + 1))) :
    torusCount e y = k := by
  have he0 : (0 : ℝ) < e := lt_trans zero_lt_one he
  have hy1 : (1 : ℝ) ≤ y :=
    le_trans (one_le_pow₀ he.le) h1
  have hle : k ≤ torusCount e y := (le_torusCount_iff he hy1 k).mp h1
  have hnot : ¬ (k + 1 ≤ torusCount e y) := by
    intro hcon
    exact absurd ((le_torusCount_iff he hy1 (k + 1)).mpr hcon) (not_le.mpr h2)
  omega

/-- **Sharpness of the short-interval theorem.**  For the single non-split torus the geodesics
sit at the points `ε^{2k}`, so their gaps are *multiplicative*: for every window exponent
`γ < 1` there are arbitrarily large `x` for which the interval `[x, x + x^{γ}]` contains no
geodesic at all.

Together with `eventually_lt_of_additive_window` this delimits the phenomenon exactly: short
intervals are populated precisely because the Chebotarev main term is a positive *power* of
`x`; the logarithmic main term of one torus is far too small. -/
theorem torusCount_no_short_gaps {e : ℝ} (he : 1 < e) {γ : ℝ} (hγ : γ < 1) (B : ℝ) :
    ∃ x, B ≤ x ∧ 1 ≤ x ∧ torusCount e (x + x ^ γ) = torusCount e x := by
  have he0 : (0 : ℝ) < e := lt_trans zero_lt_one he
  have hsq : (1 : ℝ) < e ^ 2 := by nlinarith
  -- eventually `x^γ < (e² - 1) x`, so `x + x^γ` stays below `e² x`
  have hdom : ∀ᶠ x : ℝ in atTop, 1 * x ^ γ < (e ^ 2 - 1) * x ^ (1 : ℝ) :=
    eventually_rpow_lt_rpow hγ one_pos (by linarith)
  obtain ⟨N, hN⟩ := eventually_atTop.mp hdom
  obtain ⟨k, hk⟩ := pow_unbounded_of_one_lt (max (max N B) 1) hsq
  refine ⟨e ^ (2 * k), ?_, ?_, ?_⟩
  · exact le_trans (le_trans (le_max_right N B) (le_max_left _ _)) (by rw [pow_mul]; exact hk.le)
  · exact le_trans (le_max_right _ _) (by rw [pow_mul]; exact hk.le)
  · set x : ℝ := e ^ (2 * k) with hxdef
    have hxk : (e ^ 2) ^ k = x := by rw [hxdef, pow_mul]
    have hx1 : (1 : ℝ) ≤ x := le_trans (le_max_right _ _) (by rw [← hxk]; exact hk.le)
    have hxN : N ≤ x :=
      le_trans (le_trans (le_max_left N B) (le_max_left _ _)) (by rw [← hxk]; exact hk.le)
    have hx0 : (0 : ℝ) < x := lt_of_lt_of_le zero_lt_one hx1
    have hgap := hN x hxN
    rw [one_mul, Real.rpow_one] at hgap
    have hupper : x + x ^ γ < e ^ (2 * (k + 1)) := by
      have : e ^ (2 * (k + 1)) = e ^ 2 * x := by rw [hxdef, ← pow_add]; ring_nf
      rw [this]
      nlinarith
    have hlower : e ^ (2 * k) ≤ x + x ^ γ := by
      have : (0 : ℝ) < x ^ γ := Real.rpow_pos_of_pos hx0 _
      simp only [← hxdef]; linarith
    rw [torusCount_eq_of_mem_Ico he hlower hupper,
      torusCount_eq_of_mem_Ico he (le_refl (e ^ (2 * k))) (by
        have : e ^ (2 * (k + 1)) = e ^ 2 * x := by rw [hxdef, ← pow_add]; ring_nf
        rw [this]; nlinarith)]

/-! ## The critical window exponent is exactly `1 - (β - θ)`

The torus model above shows that *some* hypothesis on the size of the main term is needed.  We
now show that the numerical threshold `1 - (β - θ)` of `eventually_lt_of_additive_window` is
itself optimal, by exhibiting for every `θ ∈ [0,1)` a counting function with main term exactly
`x` and error exponent `θ` whose jumps are spaced `≍ x^{θ}` apart.  Writing `δ = 1 - θ`, the
example is the *`δ`-sparse counter*

  `sparseCount δ x = ⌊x^δ⌋^{1/δ}`,

which is constant on each interval `[n^{1/δ}, (n+1)^{1/δ})`. -/

/-- **Reverse (decrement) Bernoulli inequality**: for `p ≥ 1`, `0 < v` and `h ≤ v`,
`(v - h)^p ≥ v^p - p v^{p-1} h`.  It bounds the jump `(n+1)^p - n^p` *from above*, which is
what controls the error term of `sparseCount`. -/
theorem rpow_sub_bernoulli_le {v h p : ℝ} (hv : 0 < v) (hhv : h ≤ v) (hp : 1 ≤ p) :
    v ^ p - p * v ^ (p - 1) * h ≤ (v - h) ^ p := by
  have hs : (-1 : ℝ) ≤ -(h / v) := by
    have : h / v ≤ 1 := (div_le_one hv).mpr hhv
    linarith
  have key := one_add_mul_self_le_rpow_one_add hs hp
  have hvp : (0 : ℝ) < v ^ p := Real.rpow_pos_of_pos hv p
  have h1 : (v - h) ^ p = v ^ p * (1 + -(h / v)) ^ p := by
    rw [← Real.mul_rpow hv.le (by
      have : h / v ≤ 1 := (div_le_one hv).mpr hhv
      linarith)]
    congr 1
    field_simp
    ring
  have h2 : v ^ (p - 1) = v ^ p / v := by rw [Real.rpow_sub hv, Real.rpow_one]
  rw [h1, h2]
  have h3 := mul_le_mul_of_nonneg_left key hvp.le
  calc v ^ p - p * (v ^ p / v) * h = v ^ p * (1 + p * -(h / v)) := by field_simp; ring
    _ ≤ v ^ p * (1 + -(h / v)) ^ p := h3

/-- The `δ`-sparse counting function `x ↦ ⌊x^δ⌋^{1/δ}`: it counts the points
`1^{1/δ}, 2^{1/δ}, 3^{1/δ}, …`, weighted so that its main term is exactly `x`. -/
noncomputable def sparseCount (δ x : ℝ) : ℝ := ((⌊x ^ δ⌋₊ : ℝ)) ^ (1 / δ)

/-- Localisation of `x` between two consecutive jumps of `sparseCount δ`. -/
theorem sparseCount_bracket {δ x : ℝ} (hδ0 : 0 < δ) (hx : 1 ≤ x) :
    1 ≤ ⌊x ^ δ⌋₊ ∧ ((⌊x ^ δ⌋₊ : ℝ)) ^ (1 / δ) ≤ x ∧ x < ((⌊x ^ δ⌋₊ : ℝ) + 1) ^ (1 / δ) := by
  have hx0 : (0 : ℝ) < x := lt_of_lt_of_le zero_lt_one hx
  set p : ℝ := 1 / δ with hpdef
  have hp0 : 0 < p := by positivity
  have hxδ : (1 : ℝ) ≤ x ^ δ := Real.one_le_rpow hx hδ0.le
  have hn1 : 1 ≤ ⌊x ^ δ⌋₊ := Nat.le_floor (by exact_mod_cast hxδ)
  have hnonneg : (0 : ℝ) ≤ x ^ δ := Real.rpow_nonneg hx0.le _
  have hle : ((⌊x ^ δ⌋₊ : ℝ)) ≤ x ^ δ := Nat.floor_le hnonneg
  have hlt : x ^ δ < (⌊x ^ δ⌋₊ : ℝ) + 1 := Nat.lt_floor_add_one _
  have hxx : (x ^ δ) ^ p = x := by
    have h : δ * p = 1 := by rw [hpdef]; field_simp
    rw [← Real.rpow_mul hx0.le, h, Real.rpow_one]
  refine ⟨hn1, ?_, ?_⟩
  · calc ((⌊x ^ δ⌋₊ : ℝ)) ^ p ≤ (x ^ δ) ^ p := Real.rpow_le_rpow (by positivity) hle hp0.le
      _ = x := hxx
  · calc x = (x ^ δ) ^ p := hxx.symm
      _ < ((⌊x ^ δ⌋₊ : ℝ) + 1) ^ p := Real.rpow_lt_rpow hnonneg hlt hp0

/-- `sparseCount δ` is constant, equal to `n^{1/δ}`, on the interval
`[n^{1/δ}, (n+1)^{1/δ})`. -/
theorem sparseCount_eq_of_mem_Ico {δ y : ℝ} (hδ0 : 0 < δ) {n : ℕ} (hn : 1 ≤ n)
    (h1 : ((n : ℝ)) ^ (1 / δ) ≤ y) (h2 : y < ((n : ℝ) + 1) ^ (1 / δ)) :
    sparseCount δ y = ((n : ℝ)) ^ (1 / δ) := by
  set p : ℝ := 1 / δ with hpdef
  have hp0 : 0 < p := by positivity
  have hn0 : (0 : ℝ) < (n : ℝ) := by exact_mod_cast hn
  have hy0 : (0 : ℝ) < y := lt_of_lt_of_le (Real.rpow_pos_of_pos hn0 p) h1
  have hpow : ∀ z : ℝ, 0 < z → (z ^ p) ^ δ = z := by
    intro z hz
    have h : p * δ = 1 := by rw [hpdef]; field_simp
    rw [← Real.rpow_mul hz.le, h, Real.rpow_one]
  have hlow : (n : ℝ) ≤ y ^ δ := by
    calc (n : ℝ) = ((n : ℝ) ^ p) ^ δ := (hpow _ hn0).symm
      _ ≤ y ^ δ := Real.rpow_le_rpow (Real.rpow_nonneg hn0.le _) h1 hδ0.le
  have hhigh : y ^ δ < (n : ℝ) + 1 := by
    calc y ^ δ < (((n : ℝ) + 1) ^ p) ^ δ := Real.rpow_lt_rpow hy0.le h2 hδ0
      _ = (n : ℝ) + 1 := hpow _ (by linarith)
  have hfloor : ⌊y ^ δ⌋₊ = n := by
    rw [Nat.floor_eq_iff (Real.rpow_nonneg hy0.le _)]
    exact ⟨by exact_mod_cast hlow, by exact_mod_cast hhigh⟩
  rw [sparseCount, hfloor]

/-- The `δ`-sparse counter approximates `x` with error `≤ (1/δ)·2^{1/δ-1}·x^{1-δ}`. -/
theorem sparseCount_abs_sub_le {δ x : ℝ} (hδ0 : 0 < δ) (hδ1 : δ ≤ 1) (hx : 1 ≤ x) :
    |sparseCount δ x - x| ≤ (1 / δ) * 2 ^ (1 / δ - 1) * x ^ (1 - δ) := by
  obtain ⟨hn1, hle, hlt⟩ := sparseCount_bracket hδ0 hx
  set p : ℝ := 1 / δ with hpdef
  have hp0 : 0 < p := by positivity
  have hp : 1 ≤ p := by rw [hpdef, le_div_iff₀ hδ0]; linarith
  set n : ℝ := ((⌊x ^ δ⌋₊ : ℕ) : ℝ) with hndef
  have hn1' : (1 : ℝ) ≤ n := by rw [hndef]; exact_mod_cast hn1
  have hn0 : (0 : ℝ) < n := lt_of_lt_of_le zero_lt_one hn1'
  have hb := rpow_sub_bernoulli_le (v := n + 1) (h := 1) (p := p) (by linarith) (by linarith) hp
  have hsimp : (n + 1 - 1 : ℝ) = n := by ring
  rw [hsimp, mul_one] at hb
  have hpe : p * (1 - δ) = p - 1 := by rw [hpdef]; field_simp
  have h21 : (n + 1) ^ (p - 1) ≤ 2 ^ (p - 1) * n ^ (p - 1) := by
    calc (n + 1) ^ (p - 1) ≤ (2 * n) ^ (p - 1) :=
          Real.rpow_le_rpow (by linarith) (by linarith) (by linarith)
      _ = 2 ^ (p - 1) * n ^ (p - 1) := Real.mul_rpow (by norm_num) hn0.le
  have hnx : n ^ (p - 1) ≤ x ^ (1 - δ) := by
    have h1 : (n ^ p) ^ (1 - δ) = n ^ (p - 1) := by rw [← Real.rpow_mul hn0.le, hpe]
    calc n ^ (p - 1) = (n ^ p) ^ (1 - δ) := h1.symm
      _ ≤ x ^ (1 - δ) := Real.rpow_le_rpow (Real.rpow_nonneg hn0.le _) hle (by linarith)
  have h2pos : (0 : ℝ) < 2 ^ (p - 1) := Real.rpow_pos_of_pos (by norm_num) _
  have hfinal : x - n ^ p ≤ p * (2 ^ (p - 1) * x ^ (1 - δ)) := by
    have hstep : x - n ^ p ≤ p * (n + 1) ^ (p - 1) := by linarith [hlt.le]
    have hmid : (n + 1) ^ (p - 1) ≤ 2 ^ (p - 1) * x ^ (1 - δ) :=
      le_trans h21 (mul_le_mul_of_nonneg_left hnx h2pos.le)
    calc x - n ^ p ≤ p * (n + 1) ^ (p - 1) := hstep
      _ ≤ p * (2 ^ (p - 1) * x ^ (1 - δ)) := mul_le_mul_of_nonneg_left hmid hp0.le
  have hsc : sparseCount δ x = n ^ p := rfl
  rw [hsc, abs_le]
  constructor <;> nlinarith [hle]

/-- **The `δ`-sparse counter has main term `x` and error exponent `1 - δ`.** -/
theorem hasErrorExponent_sparseCount {δ : ℝ} (hδ0 : 0 < δ) (hδ1 : δ ≤ 1) :
    HasErrorExponent (sparseCount δ) (fun x => 1 * x ^ (1 : ℝ)) (1 - δ) := by
  intro ε hε
  refine ⟨(1 / δ) * 2 ^ (1 / δ - 1), by positivity, 1, le_rfl, fun x hx => ?_⟩
  have hx0 : (0 : ℝ) < x := lt_of_lt_of_le zero_lt_one hx
  have hmain : (fun x : ℝ => 1 * x ^ (1 : ℝ)) x = x := by
    show (1 : ℝ) * x ^ (1 : ℝ) = x
    rw [Real.rpow_one, one_mul]
  rw [hmain]
  have hmono : x ^ (1 - δ) ≤ x ^ (1 - δ + ε) :=
    Real.rpow_le_rpow_of_exponent_le hx (by linarith)
  have hK : (0 : ℝ) < (1 / δ) * 2 ^ (1 / δ - 1) := by positivity
  exact le_trans (sparseCount_abs_sub_le hδ0 hδ1 hx) (mul_le_mul_of_nonneg_left hmono hK.le)

/-- Below the critical exponent the `δ`-sparse counter has arbitrarily large empty windows. -/
theorem sparseCount_no_short_window {δ γ : ℝ} (hδ0 : 0 < δ) (hδ1 : δ ≤ 1) (hγ : γ < 1 - δ)
    (B : ℝ) :
    ∃ x, B ≤ x ∧ 1 ≤ x ∧ sparseCount δ (x + x ^ γ) = sparseCount δ x := by
  set p : ℝ := 1 / δ with hpdef
  have hp0 : 0 < p := by positivity
  have hp : 1 ≤ p := by rw [hpdef, le_div_iff₀ hδ0]; linarith
  have hpe : p * (1 - δ) = p - 1 := by rw [hpdef]; field_simp
  have hdom : ∀ᶠ z : ℝ in atTop, 1 * z ^ γ < p * z ^ (1 - δ) :=
    eventually_rpow_lt_rpow hγ one_pos hp0
  obtain ⟨N, hN⟩ := eventually_atTop.mp hdom
  set m : ℕ := max (max ⌈N⌉₊ ⌈B⌉₊) 1 with hmdef
  have hm1 : 1 ≤ m := le_max_right _ _
  have hm0 : (0 : ℝ) < (m : ℝ) := by exact_mod_cast hm1
  have hm1' : (1 : ℝ) ≤ (m : ℝ) := by exact_mod_cast hm1
  have hmN : N ≤ (m : ℝ) :=
    le_trans (Nat.le_ceil N) (by exact_mod_cast le_trans (le_max_left _ _) (le_max_left _ _))
  have hmB : B ≤ (m : ℝ) :=
    le_trans (Nat.le_ceil B) (by exact_mod_cast le_trans (le_max_right _ _) (le_max_left _ _))
  set x : ℝ := (m : ℝ) ^ p with hxdef
  have hxm : (m : ℝ) ≤ x := by
    calc (m : ℝ) = (m : ℝ) ^ (1 : ℝ) := (Real.rpow_one _).symm
      _ ≤ (m : ℝ) ^ p := Real.rpow_le_rpow_of_exponent_le hm1' hp
  have hx1 : (1 : ℝ) ≤ x := le_trans hm1' hxm
  have hx0 : (0 : ℝ) < x := lt_of_lt_of_le zero_lt_one hx1
  have hxγ : (0 : ℝ) < x ^ γ := Real.rpow_pos_of_pos hx0 _
  have hbern := rpow_bernoulli_add_le hm0 zero_le_one hp
  rw [mul_one] at hbern
  have hmx : (m : ℝ) ^ (p - 1) = x ^ (1 - δ) := by rw [hxdef, ← Real.rpow_mul hm0.le, hpe]
  rw [hmx] at hbern
  have hgap := hN x (le_trans hmN hxm)
  rw [one_mul] at hgap
  have hnext : x + p * x ^ (1 - δ) ≤ ((m : ℝ) + 1) ^ p := by rw [hxdef]; linarith [hbern]
  have hupper : x + x ^ γ < ((m : ℝ) + 1) ^ p := by linarith
  refine ⟨x, le_trans hmB hxm, hx1, ?_⟩
  rw [sparseCount_eq_of_mem_Ico hδ0 hm1 (by rw [hxdef]; linarith) hupper,
    sparseCount_eq_of_mem_Ico hδ0 hm1 (le_of_eq hxdef.symm) (by
      have hppos : (0 : ℝ) < p * x ^ (1 - δ) := by positivity
      linarith)]

/-- **The critical window exponent is exactly `1 - (β - θ)`.**  For every `δ ∈ (0,1]` the
`δ`-sparse counter has main term `x` (so `β = 1`, `c = 1`) and error exponent `θ = 1 - δ`, and:

* for every `γ < 1 - δ` the short-interval conclusion **fails** — arbitrarily large windows
  `[x, x + x^{γ}]` are empty;
* for every `γ` with `1 - δ < γ ≤ 1` it **holds**.

So the threshold `1 - (β - θ)` in `eventually_lt_of_additive_window` cannot be lowered; this
completes conjecture C4 of `FUTURE_DIRECTIONS.md` in both directions. -/
theorem sparseCount_critical_window_exponent {δ : ℝ} (hδ0 : 0 < δ) (hδ1 : δ ≤ 1) :
    HasErrorExponent (sparseCount δ) (fun x => 1 * x ^ (1 : ℝ)) (1 - δ) ∧
      (∀ γ < 1 - δ, ¬ ∀ᶠ x in atTop, sparseCount δ x < sparseCount δ (x + x ^ γ)) ∧
      (∀ γ, 1 - δ < γ → γ ≤ 1 →
        ∀ᶠ x in atTop, sparseCount δ x < sparseCount δ (x + x ^ γ)) := by
  refine ⟨hasErrorExponent_sparseCount hδ0 hδ1, ?_, ?_⟩
  · intro γ hγ hcon
    obtain ⟨N, hN⟩ := eventually_atTop.mp hcon
    obtain ⟨x, hxN, _, heq⟩ := sparseCount_no_short_window hδ0 hδ1 hγ N
    exact absurd (hN x hxN) (by rw [heq]; exact lt_irrefl _)
  · intro γ hγ hγ1
    refine eventually_lt_of_additive_window (hasErrorExponent_sparseCount hδ0 hδ1)
      one_pos le_rfl (by linarith) hγ1 (by linarith)

end ChebotarevGeodesic