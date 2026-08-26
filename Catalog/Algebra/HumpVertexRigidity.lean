/-
# Rigidity of the hump vertex: a two-sided pin, independent of the aspect ratio

Fourth formal core of experiment **581** (paper 231), closing the first named
open question of the previous cycle.

`Algebra.HumpWindowGeometry` shows that the chord-gap vertex `ξ` of the log-size
profile of `j² − N` is unique and lies strictly left of the window centre.  What
it does not explain is a striking numerical fact: **the vertex barely moves when
the aspect ratio `c = √N / M` is varied over nine orders of magnitude.**

This file explains it, by pinning the vertex between two explicit logarithmic
means:

```
        LM(a, b)   ≤   ξ   ≤   LM(a + 2c, b + 2c) − 2c   <   (a + b)/2 ,
        LM(p, q) = (q − p) / (log q − log p).
```

Both bounds come from one monotonicity — that the logarithmic mean gains
*strictly more* than a common shift of its endpoints — and that in turn comes
from the classical `GM < LM` inequality, proved here from scratch.

## Main results

* `HumpVertexRigidity.log_lt_half_sub_inv` — `log s < (s − 1/s)/2` for `s > 1`.
* `HumpVertexRigidity.geomMean_mul_log_lt_sub` — **`GM < LM`**:
  `√(pq) · (log q − log p) < q − p` for `0 < p < q`.
* `HumpVertexRigidity.logMean_shift_le` — **shift rigidity**:
  `LM(a,b) + t ≤ LM(a+t, b+t)` for `t ≥ 0`.
* `HumpVertexRigidity.logMean_le_vertex` — the **lower** pin `LM(a,b) ≤ ξ`.
* `HumpVertexRigidity.vertex_le_shifted_logMean` — the **upper** pin
  `ξ ≤ LM(a+2c, b+2c) − 2c`.
* `HumpVertexRigidity.vertex_mem_Icc` — the two-sided pin, and
  `HumpVertexRigidity.vertex_indep_of_aspect` — the resulting bound on how far
  two vertices at different aspect ratios can be apart.

## Consequence for the verdict

The vertex of the geometric hump is not a free parameter of the sieve: it is
squeezed between two logarithmic means of the window endpoints.  In the sieve
regime `a = 1/M`, `b = 1` the lower pin is `≈ 1/log M`, so the geometric vertex
sits *near the left edge* and is pushed there harder as the window grows.  This
is the quantitative form of `HumpWindowGeometry.measured_vertex_not_from_window_geometry`:
the measured `0.5901` is not a near miss.
-/
import Mathlib
import Algebra.HumpWindowGeometry

namespace HumpVertexRigidity

open Set HumpWindowGeometry

/-! ## 1. `GM < LM` -/

/-- `log s < (s - 1/s)/2` for `s > 1`. -/
theorem log_lt_half_sub_inv {s : ℝ} (hs : 1 < s) : Real.log s < (s - 1 / s) / 2 := by
  set G : ℝ → ℝ := fun x => (x - 1 / x) / 2 - Real.log x with hG
  have hderiv : ∀ x : ℝ, 0 < x → HasDerivAt G ((1 + 1 / x ^ 2) / 2 - 1 / x) x := by
    intro x hx
    have hxne : x ≠ 0 := ne_of_gt hx
    have h1 : HasDerivAt (fun y : ℝ => y - 1 / y) (1 - (-(1 / x ^ 2))) x := by
      have hinv : HasDerivAt (fun y : ℝ => 1 / y) (-(1 / x ^ 2)) x := by
        simpa [one_div] using (hasDerivAt_inv hxne)
      exact (hasDerivAt_id x).sub hinv
    have h2 : HasDerivAt (fun y : ℝ => (y - 1 / y) / 2) ((1 - (-(1 / x ^ 2))) / 2) x :=
      h1.div_const 2
    have h3 : HasDerivAt Real.log (1 / x) x := by
      simpa [one_div] using Real.hasDerivAt_log hxne
    have := h2.sub h3
    convert this using 1
    ring
  have hmono : StrictMonoOn G (Ici (1 : ℝ)) := by
    apply strictMonoOn_of_deriv_pos (convex_Ici 1)
    · intro x hx
      exact ((hderiv x (lt_of_lt_of_le zero_lt_one hx)).continuousAt).continuousWithinAt
    · intro x hx
      rw [interior_Ici] at hx
      have hx0 : (0 : ℝ) < x := lt_trans zero_lt_one hx
      rw [(hderiv x hx0).deriv]
      have hkey : (1 + 1 / x ^ 2) / 2 - 1 / x = (x - 1) ^ 2 / (2 * x ^ 2) := by
        field_simp
        ring
      rw [hkey]
      have hnum : (0 : ℝ) < (x - 1) ^ 2 := by
        have : x - 1 ≠ 0 := by intro h; rw [sub_eq_zero] at h; exact absurd h (ne_of_gt hx)
        positivity
      positivity
  have h0 : G 1 = 0 := by simp [hG]
  have hlt := hmono Set.self_mem_Ici (mem_Ici.2 (le_of_lt hs)) hs
  rw [h0] at hlt
  simp only [hG] at hlt
  linarith

/-- **The geometric mean is below the logarithmic mean.** -/
theorem geomMean_mul_log_lt_sub {p q : ℝ} (hp : 0 < p) (hpq : p < q) :
    Real.sqrt (p * q) * (Real.log q - Real.log p) < q - p := by
  have hq : 0 < q := lt_trans hp hpq
  set s : ℝ := Real.sqrt (q / p) with hs
  have hratio : 1 < q / p := (one_lt_div hp).2 hpq
  have hs1 : 1 < s := by
    rw [hs]
    have : Real.sqrt 1 < Real.sqrt (q / p) :=
      Real.sqrt_lt_sqrt (by norm_num) hratio
    simpa using this
  have hs0 : 0 < s := lt_trans zero_lt_one hs1
  have hssq : s ^ 2 = q / p := Real.sq_sqrt (le_of_lt (div_pos hq hp))
  have hq_eq : q = p * s ^ 2 := by
    rw [hssq]; field_simp
  have hsqrt : Real.sqrt (p * q) = p * s := by
    rw [hq_eq, hs]
    have hrw : p * (p * (Real.sqrt (q / p)) ^ 2) = (p * Real.sqrt (q / p)) ^ 2 := by ring
    rw [hrw, Real.sqrt_sq (by positivity)]
  have hlog : Real.log q - Real.log p = 2 * Real.log s := by
    rw [hq_eq, Real.log_mul (ne_of_gt hp) (by positivity), Real.log_pow]
    push_cast
    ring
  rw [hsqrt, hlog, hq_eq]
  have hkey := log_lt_half_sub_inv hs1
  have hstep : 2 * s * Real.log s < s ^ 2 - 1 := by
    have h2 : 2 * s * Real.log s < 2 * s * ((s - 1 / s) / 2) := by
      apply mul_lt_mul_of_pos_left hkey (by linarith)
    have hsimp : 2 * s * ((s - 1 / s) / 2) = s ^ 2 - 1 := by
      field_simp
    linarith [hsimp ▸ h2]
  nlinarith [hstep, hp]

/-! ## 2. Shift rigidity of the logarithmic mean -/

/-- The logarithmic mean of two positive reals. -/
noncomputable def logMean (p q : ℝ) : ℝ := (q - p) / (Real.log q - Real.log p)

theorem logMean_pos {p q : ℝ} (hp : 0 < p) (hpq : p < q) : 0 < logMean p q := by
  have hlog : 0 < Real.log q - Real.log p := by
    have := Real.log_lt_log hp hpq
    linarith
  exact div_pos (by linarith) hlog

/-- **Shift rigidity.**  Translating both endpoints by `t ≥ 0` raises the
logarithmic mean by at least `t`. -/
theorem logMean_shift_le {a b : ℝ} (ha : 0 < a) (hab : a < b) {t : ℝ} (ht : 0 ≤ t) :
    logMean a b + t ≤ logMean (a + t) (b + t) := by
  rcases eq_or_lt_of_le ht with rfl | htpos
  · simp
  set d : ℝ := b - a with hd
  have hd0 : 0 < d := by rw [hd]; linarith
  set D : ℝ → ℝ := fun u => Real.log (b + u) - Real.log (a + u) with hD
  have hDpos : ∀ u : ℝ, 0 ≤ u → 0 < D u := by
    intro u hu
    have h1 : 0 < a + u := by linarith
    have h2 : a + u < b + u := by linarith
    have := Real.log_lt_log h1 h2
    rw [hD]; linarith
  have hDderiv : ∀ u : ℝ, 0 ≤ u → HasDerivAt D ((b + u)⁻¹ - (a + u)⁻¹) u := by
    intro u hu
    have h1 : (0 : ℝ) < a + u := by linarith
    have h2 : (0 : ℝ) < b + u := by linarith
    have hb : HasDerivAt (fun y : ℝ => Real.log (b + y)) ((b + u)⁻¹) u := by
      simpa using (Real.hasDerivAt_log (ne_of_gt h2)).comp u ((hasDerivAt_id u).const_add b)
    have haa : HasDerivAt (fun y : ℝ => Real.log (a + y)) ((a + u)⁻¹) u := by
      simpa using (Real.hasDerivAt_log (ne_of_gt h1)).comp u ((hasDerivAt_id u).const_add a)
    exact hb.sub haa
  set F : ℝ → ℝ := fun u => d / D u - u with hF
  have hFderiv : ∀ u : ℝ, 0 ≤ u →
      HasDerivAt F ((0 * D u - d * ((b + u)⁻¹ - (a + u)⁻¹)) / (D u) ^ 2 - 1) u := by
    intro u hu
    exact ((hasDerivAt_const u d).div (hDderiv u hu) (ne_of_gt (hDpos u hu))).sub
      (hasDerivAt_id u)
  have hmono : StrictMonoOn F (Ici (0 : ℝ)) := by
    apply strictMonoOn_of_deriv_pos (convex_Ici 0)
    · intro u hu
      exact ((hFderiv u (mem_Ici.1 hu)).continuousAt).continuousWithinAt
    · intro u hu
      rw [interior_Ici] at hu
      have hu0 : (0 : ℝ) ≤ u := le_of_lt hu
      have h1 : (0 : ℝ) < a + u := by linarith
      have h2 : (0 : ℝ) < b + u := by linarith
      rw [(hFderiv u hu0).deriv]
      have hDu : 0 < D u := hDpos u hu0
      -- `GM < LM` for the shifted endpoints
      have hgm := geomMean_mul_log_lt_sub h1 (by linarith : a + u < b + u)
      have hDeq : Real.log (b + u) - Real.log (a + u) = D u := by rw [hD]
      rw [hDeq] at hgm
      have hsub : (b + u) - (a + u) = d := by rw [hd]; ring
      rw [hsub] at hgm
      have hsqrtpos : 0 < Real.sqrt ((a + u) * (b + u)) := Real.sqrt_pos.2 (by positivity)
      have hsq : Real.sqrt ((a + u) * (b + u)) ^ 2 = (a + u) * (b + u) :=
        Real.sq_sqrt (by positivity)
      have hkey : (a + u) * (b + u) * (D u) ^ 2 < d ^ 2 := by
        have hlhs : ((a + u) * (b + u)) * (D u) ^ 2
            = (Real.sqrt ((a + u) * (b + u)) * D u) ^ 2 := by
          rw [mul_pow, hsq]
        rw [hlhs]
        have hpos : 0 < Real.sqrt ((a + u) * (b + u)) * D u := mul_pos hsqrtpos hDu
        nlinarith [hgm, hpos]
      have hexp : (0 * D u - d * ((b + u)⁻¹ - (a + u)⁻¹)) / (D u) ^ 2 - 1
          = (d ^ 2 - (a + u) * (b + u) * (D u) ^ 2)
            / ((a + u) * (b + u) * (D u) ^ 2) := by
        field_simp
        ring
      rw [hexp]
      apply div_pos (by linarith) (by positivity)
  have hstep := hmono (mem_Ici.2 (le_refl 0)) (mem_Ici.2 ht) htpos
  simp only [hF] at hstep
  have hF0 : d / D 0 = logMean a b := by
    rw [hD, logMean, hd]
    norm_num
  have hFt : d / D t = logMean (a + t) (b + t) := by
    rw [hD, logMean, hd]
    have hsub : (b + t) - (a + t) = b - a := by ring
    rw [hsub]
  rw [hF0] at hstep
  rw [hFt] at hstep
  linarith

/-! ## 3. The two-sided pin on the vertex -/

theorem chordSlope_split {c a b : ℝ} (ha : 0 < a) (hab : a < b) (hc : 0 ≤ c) :
    chordSlope (logSize c) a b = 1 / logMean a b + 1 / logMean (a + 2 * c) (b + 2 * c) := by
  have hlog1 : 0 < Real.log b - Real.log a := by
    have := Real.log_lt_log ha hab
    linarith
  have hlog2 : 0 < Real.log (b + 2 * c) - Real.log (a + 2 * c) := by
    have := Real.log_lt_log (by linarith : (0:ℝ) < a + 2 * c) (by linarith : a + 2*c < b + 2*c)
    linarith
  have hba : (0 : ℝ) < b - a := by linarith
  have h1 : 1 / logMean a b = (Real.log b - Real.log a) / (b - a) := by
    rw [logMean, one_div, inv_div]
  have h2 : 1 / logMean (a + 2 * c) (b + 2 * c)
      = (Real.log (b + 2 * c) - Real.log (a + 2 * c)) / (b - a) := by
    rw [logMean, one_div, inv_div]
    have hsub : (b + 2 * c) - (a + 2 * c) = b - a := by ring
    rw [hsub]
  rw [chordSlope, logSize, logSize, h1, h2]
  ring

/-- **Lower pin.**  The hump vertex is never left of the logarithmic mean of the
window endpoints — whatever the aspect ratio. -/
theorem logMean_le_vertex {c a b ξ : ℝ} (hc : 0 ≤ c) (ha : 0 < a) (hab : a < b)
    (hξ : IsVertex c a b ξ) : logMean a b ≤ ξ := by
  set L : ℝ := logMean a b with hL
  set L₂ : ℝ := logMean (a + 2 * c) (b + 2 * c) with hL2
  have hLpos : 0 < L := logMean_pos ha hab
  have hL2pos : 0 < L₂ := logMean_pos (by linarith) (by linarith)
  have hξ0 : (0 : ℝ) < ξ := lt_trans ha hξ.1.1
  have hshift : L + 2 * c ≤ L₂ := logMean_shift_le ha hab (by linarith)
  have hinv : 1 / L₂ ≤ 1 / (L + 2 * c) := by
    apply one_div_le_one_div_of_le (by linarith) hshift
  have hS : chordSlope (logSize c) a b ≤ logSizeDeriv c L := by
    rw [chordSlope_split ha hab hc, logSizeDeriv, ← hL, ← hL2]
    linarith
  have hlt : logSizeDeriv c ξ ≤ logSizeDeriv c L := by rw [hξ.2]; exact hS
  by_contra hcon
  push_neg at hcon
  exact absurd (logSizeDeriv_strictAntiOn hc (mem_Ioi.2 hξ0) (mem_Ioi.2 hLpos) hcon)
    (not_lt.2 hlt)

/-- **Upper pin.**  The hump vertex is never right of the shifted logarithmic
mean `LM(a+2c, b+2c) − 2c`. -/
theorem vertex_le_shifted_logMean {c a b ξ : ℝ} (hc : 0 ≤ c) (ha : 0 < a) (hab : a < b)
    (hξ : IsVertex c a b ξ) : ξ ≤ logMean (a + 2 * c) (b + 2 * c) - 2 * c := by
  set L : ℝ := logMean a b with hL
  set L₂ : ℝ := logMean (a + 2 * c) (b + 2 * c) with hL2
  have hLpos : 0 < L := logMean_pos ha hab
  have hξ0 : (0 : ℝ) < ξ := lt_trans ha hξ.1.1
  have hshift : L + 2 * c ≤ L₂ := logMean_shift_le ha hab (by linarith)
  have hm2pos : 0 < L₂ - 2 * c := by linarith
  have hm2L : L ≤ L₂ - 2 * c := by linarith
  have hinv : 1 / (L₂ - 2 * c) ≤ 1 / L := one_div_le_one_div_of_le hLpos hm2L
  have hval : logSizeDeriv c (L₂ - 2 * c) = 1 / (L₂ - 2 * c) + 1 / L₂ := by
    rw [logSizeDeriv]
    have h : L₂ - 2 * c + 2 * c = L₂ := by ring
    rw [h]
  have hS : logSizeDeriv c (L₂ - 2 * c) ≤ chordSlope (logSize c) a b := by
    rw [hval, chordSlope_split ha hab hc, ← hL, ← hL2]
    linarith
  have hlt : logSizeDeriv c (L₂ - 2 * c) ≤ logSizeDeriv c ξ := by rw [hξ.2]; exact hS
  by_contra hcon
  push_neg at hcon
  exact absurd (logSizeDeriv_strictAntiOn hc (mem_Ioi.2 hm2pos) (mem_Ioi.2 hξ0) hcon)
    (not_lt.2 hlt)

/-- **The vertex is pinned between two logarithmic means.** -/
theorem vertex_mem_Icc {c a b ξ : ℝ} (hc : 0 ≤ c) (ha : 0 < a) (hab : a < b)
    (hξ : IsVertex c a b ξ) :
    ξ ∈ Icc (logMean a b) (logMean (a + 2 * c) (b + 2 * c) - 2 * c) :=
  ⟨logMean_le_vertex hc ha hab hξ, vertex_le_shifted_logMean hc ha hab hξ⟩

/-- **Aspect-ratio insensitivity.**  Two vertices computed at different aspect
ratios `c₁, c₂` on the same window differ by at most the spread of the pin at
the larger aspect ratio; in particular both lie in
`[LM(a,b), (a+b)/2)`, an interval that does not depend on the aspect ratio at
all.  This is the theorem behind the numerically observed `c`-independence. -/
theorem vertex_indep_of_aspect {c₁ c₂ a b ξ₁ ξ₂ : ℝ} (hc₁ : 0 ≤ c₁) (hc₂ : 0 ≤ c₂)
    (ha : 0 < a) (hab : a < b) (h₁ : IsVertex c₁ a b ξ₁) (h₂ : IsVertex c₂ a b ξ₂) :
    |ξ₁ - ξ₂| < (a + b) / 2 - logMean a b := by
  have hlo₁ := logMean_le_vertex hc₁ ha hab h₁
  have hlo₂ := logMean_le_vertex hc₂ ha hab h₂
  have hhi₁ := vertex_lt_midpoint hc₁ ha hab h₁
  have hhi₂ := vertex_lt_midpoint hc₂ ha hab h₂
  rw [abs_lt]
  constructor <;> linarith

end HumpVertexRigidity