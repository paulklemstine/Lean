/-
# The affine-readout barrier for the EML product gate

This file closes the negative half of the "Correction Rank of the EML Product
Gate" conjecture recorded in `FUTURE_DIRECTIONS.md`.

`Bridges/EMLPolarisationSharpConstant.lean` proves that the width-`4`
polarisation gate satisfies, uniformly on the unit square,

`prodGate h x y = x*y + h² · x y (x²+y²)/6 + O(h⁴)`,

and that no *scalar* gain `lam` can remove the `Θ(h²)` term
(`no_scalar_debiasing`).  The obvious next question is whether the two squaring
units that the gate already contains can be reused as a *correction*: is there
an affine read-out

`N(x,y) = lam · prodGate h x y + mu · S_h(x) + nu · S_h(y) + kappa`,
`S_h(u) = (sqLayer h).eval u = (exp(h u) + exp(−h u) − 2)/h²`,

whose error is `o(h²)` uniformly on `[0,1]²`?

**Theorem (`no_affine_debiasing`).**  No.  For every `0 < h ≤ 1/2` and *all*
real `lam, mu, nu, kappa` — including `h`-dependent ones — the error of `N`
is at least `h²/210` somewhere on `[0,1]²`.

## The mechanism

The proof is a *mixed second difference*.  On the four corners of an
axis-parallel rectangle the functional

`D[F] = F(a,b) − F(a,c) − F(d,b) + F(d,c)`

annihilates every function of `x` alone, every function of `y` alone, and every
constant; so `mu`, `nu` and `kappa` disappear **exactly**, with no estimates
involved.  Applying `D` on the two rectangles with corners `(1,1)` and
`(1/2,1/2)` (whose remaining three corners lie on the axes, where the gate is
*exactly* correct) leaves the two clean scalar equations

`D₁ = lam · prodGate h 1 1 − 1`,  `D₂ = lam · prodGate h (1/2) (1/2) − 1/4`.

Because `prodGate h 1 1 ≈ 1 + h²/3` while `4 · prodGate h (1/2) (1/2) ≈
1 + h²/12`, the combination `D₁ − 4·D₂ = lam·(A − 4B)` sees a gap of size
`h²/4`, forcing `|lam| < 1/2`; but then `D₁` itself is bounded away from `0`.
The two probes with *different* ratios of quartic error to bilinear value are
exactly what an affine read-out cannot reconcile.

## Main results

* `sqLayer_eval_zero`, `prodGate_zero_left` — the exact vanishing facts that
  make the second difference collapse.
* `prodGate_corner_sharp`, `prodGate_half_sharp` — the two probe expansions.
* `affine_mixed_difference_corner`, `affine_mixed_difference_half` — the two
  scalar equations, proved by `ring` after the vanishing facts.
* `no_affine_debiasing` — the barrier.
* `affine_readout_not_fourth_order` — its asymptotic form: an affine read-out
  can never be `O(h⁴)`.

Everything is proved from `import Mathlib` plus the catalog files; no `sorry`.
-/
import Mathlib
import Applications.EMLDepthWidthTradeoff
import Bridges.EMLPolarisationSharpConstant

namespace EML.CorrectionRank

open Real Set EML.DepthWidth EML.Polarisation

noncomputable section

/-! ## 1. Exact vanishing facts -/

/-- The squaring layer vanishes at `0`. -/
theorem sqLayer_eval_zero (h : ℝ) (hh : h ≠ 0) : (sqLayer h).eval 0 = 0 := by
  rw [sqLayer_eval h hh]
  norm_num

/-- The gate is identically `0` on the axis `x = 0`: the two polarisation
branches coincide because the squaring layer is even. -/
theorem prodGate_zero_left (h y : ℝ) (hh : h ≠ 0) : prodGate h 0 y = 0 := by
  have h1 : h * (0 + y) = h * y := by ring
  have h2 : h * (0 - y) = -(h * y) := by ring
  simp only [prodGate, sqLayer_eval h hh, h1, h2, neg_neg]
  ring

/-- The gate is identically `0` on the axis `y = 0`. -/
theorem prodGate_zero_right (h x : ℝ) : prodGate h x 0 = 0 := by
  simpa using prodGate_axis_exact h x

/-! ## 2. The two probe expansions -/

/-- At the corner `(1,1)` the gate is `1 + h²/3 + O(h⁴)`. -/
theorem prodGate_corner_sharp (h : ℝ) (hh0 : 0 < h) (hh : h ≤ 1 / 2) :
    |prodGate h 1 1 - 1 - h ^ 2 / 3| ≤ h ^ 4 / 21 := by
  have := prodGate_error_sharp h 1 1 hh0 hh ⟨zero_le_one, le_refl 1⟩ ⟨zero_le_one, le_refl 1⟩
  have hrw : (1:ℝ) * 1 + h ^ 2 * (1 * 1 * (1 ^ 2 + 1 ^ 2)) / 6 = 1 + h ^ 2 / 3 := by ring
  calc |prodGate h 1 1 - 1 - h ^ 2 / 3|
      = |prodGate h 1 1 - 1 * 1 - h ^ 2 * (1 * 1 * ((1:ℝ) ^ 2 + 1 ^ 2)) / 6| := by
        rw [show prodGate h 1 1 - 1 - h ^ 2 / 3
          = prodGate h 1 1 - ((1:ℝ) * 1 + h ^ 2 * (1 * 1 * (1 ^ 2 + 1 ^ 2)) / 6) by
            rw [hrw]; ring]
        ring_nf
    _ ≤ h ^ 4 / 21 := this

/-- At the interior probe `(1/2,1/2)` the gate is `1/4 + h²/48 + O(h⁴)`.  The
ratio of quartic error to bilinear value, `h²/12` after rescaling, differs from
the corner's `h²/3`: that discrepancy is the whole obstruction. -/
theorem prodGate_half_sharp (h : ℝ) (hh0 : 0 < h) (hh : h ≤ 1 / 2) :
    |prodGate h (1/2) (1/2) - 1/4 - h ^ 2 / 48| ≤ h ^ 4 / 21 := by
  have hmem : (1/2 : ℝ) ∈ Icc (0:ℝ) 1 := ⟨by norm_num, by norm_num⟩
  have := prodGate_error_sharp h (1/2) (1/2) hh0 hh hmem hmem
  have hrw : prodGate h (1/2) (1/2) - (1/2 : ℝ) * (1/2)
        - h ^ 2 * ((1/2 : ℝ) * (1/2) * ((1/2 : ℝ) ^ 2 + (1/2 : ℝ) ^ 2)) / 6
      = prodGate h (1/2) (1/2) - 1/4 - h ^ 2 / 48 := by ring
  rwa [hrw] at this

/-! ## 3. The mixed second difference kills `mu`, `nu` and `kappa` -/

section Affine

variable (h lam mu nu kappa : ℝ)

/-- The affine read-out built from the gate and the two squaring units. -/
def affineReadout (x y : ℝ) : ℝ :=
  lam * prodGate h x y + mu * (sqLayer h).eval x + nu * (sqLayer h).eval y + kappa

/-- The error of the affine read-out against the true product. -/
def affineErr (x y : ℝ) : ℝ := affineReadout h lam mu nu kappa x y - x * y

/-- **Mixed difference at the corner.**  On the rectangle with corners
`(1,1), (1,0), (0,1), (0,0)` the second difference of the error is
`lam · prodGate h 1 1 − 1`: the two squaring units and the bias cancel exactly. -/
theorem affine_mixed_difference_corner (hh : h ≠ 0) :
    affineErr h lam mu nu kappa 1 1 - affineErr h lam mu nu kappa 1 0
        - affineErr h lam mu nu kappa 0 1 + affineErr h lam mu nu kappa 0 0
      = lam * prodGate h 1 1 - 1 := by
  simp only [affineErr, affineReadout, prodGate_zero_right, prodGate_zero_left h 1 hh,
    prodGate_zero_left h 0 hh, sqLayer_eval_zero h hh]
  ring

/-- **Mixed difference at the half-probe.**  Same cancellation on the rectangle
with corners `(1/2,1/2), (1/2,0), (0,1/2), (0,0)`. -/
theorem affine_mixed_difference_half (hh : h ≠ 0) :
    affineErr h lam mu nu kappa (1/2) (1/2) - affineErr h lam mu nu kappa (1/2) 0
        - affineErr h lam mu nu kappa 0 (1/2) + affineErr h lam mu nu kappa 0 0
      = lam * prodGate h (1/2) (1/2) - 1/4 := by
  simp only [affineErr, affineReadout, prodGate_zero_right, prodGate_zero_left h (1/2) hh,
    prodGate_zero_left h 0 hh, sqLayer_eval_zero h hh]
  ring

end Affine

/-! ## 4. The barrier -/

set_option maxHeartbeats 1000000 in
/-- **No affine read-out removes the quadratic error.**  For every `0 < h ≤ 1/2`
and every choice of gain `lam`, correction weights `mu, nu` and bias `kappa`
— all of which may depend on `h` — the network

`lam · prodGate h x y + mu · S_h(x) + nu · S_h(y) + kappa`

misses `x·y` by at least `h²/210` at one of the seven probe points of the unit
square.  So the `Θ(h²)` rate of the width-`4` gate survives every affine
read-out that reuses the gate's own squaring units: the correction rank of the
EML product gate is at least `1`. -/
theorem no_affine_debiasing (h : ℝ) (hh0 : 0 < h) (hh : h ≤ 1 / 2)
    (lam mu nu kappa : ℝ) :
    ∃ x ∈ Icc (0:ℝ) 1, ∃ y ∈ Icc (0:ℝ) 1,
      h ^ 2 / 210 ≤ |affineErr h lam mu nu kappa x y| := by
  by_contra hcon
  push_neg at hcon
  have hne : h ≠ 0 := ne_of_gt hh0
  have h0 : (0:ℝ) ∈ Icc (0:ℝ) 1 := ⟨le_refl 0, zero_le_one⟩
  have h1 : (1:ℝ) ∈ Icc (0:ℝ) 1 := ⟨zero_le_one, le_refl 1⟩
  have hhalf : (1/2 : ℝ) ∈ Icc (0:ℝ) 1 := ⟨by norm_num, by norm_num⟩
  -- the seven probe bounds
  have b11 := abs_lt.mp (hcon 1 h1 1 h1)
  have b10 := abs_lt.mp (hcon 1 h1 0 h0)
  have b01 := abs_lt.mp (hcon 0 h0 1 h1)
  have b00 := abs_lt.mp (hcon 0 h0 0 h0)
  have bhh := abs_lt.mp (hcon (1/2) hhalf (1/2) hhalf)
  have bh0 := abs_lt.mp (hcon (1/2) hhalf 0 h0)
  have b0h := abs_lt.mp (hcon 0 h0 (1/2) hhalf)
  -- the two clean scalar equations: `mu`, `nu`, `kappa` cancel exactly
  have e1 := affine_mixed_difference_corner h lam mu nu kappa hne
  have e2 := affine_mixed_difference_half h lam mu nu kappa hne
  set A := prodGate h 1 1 with hA
  set B := prodGate h (1/2) (1/2) with hB
  have key1 : |lam * A - 1| < 4 * (h ^ 2 / 210) := by
    rw [← e1, abs_lt]
    exact ⟨by linarith [b11.1, b10.2, b01.2, b00.1],
      by linarith [b11.2, b10.1, b01.1, b00.2]⟩
  have key2 : |lam * B - 1/4| < 4 * (h ^ 2 / 210) := by
    rw [← e2, abs_lt]
    exact ⟨by linarith [bhh.1, bh0.2, b0h.2, b00.1],
      by linarith [bhh.2, bh0.1, b0h.1, b00.2]⟩
  -- the two probe expansions
  have hA' := abs_le.mp (prodGate_corner_sharp h hh0 hh)
  have hB' := abs_le.mp (prodGate_half_sharp h hh0 hh)
  rw [← hA] at hA'
  rw [← hB] at hB'
  have hsq0 : (0:ℝ) < h ^ 2 := by positivity
  have hsq : h ^ 2 ≤ 1 / 4 := by nlinarith
  have hq : h ^ 4 ≤ h ^ 2 / 4 := by nlinarith [sq_nonneg h]
  -- step 1: the two probes disagree on the quartic-to-bilinear ratio,
  -- which forces the gain to be small
  have hgap : 4 * h ^ 2 / 21 ≤ A - 4 * B := by
    have hstep : h ^ 2 / 4 - 5 * h ^ 4 / 21 ≤ A - 4 * B := by
      linarith [hA'.1, hA'.2, hB'.1, hB'.2]
    linarith
  have hcomb : |lam * (A - 4 * B)| < 20 * (h ^ 2 / 210) := by
    have hid : lam * (A - 4 * B) = (lam * A - 1) - 4 * (lam * B - 1/4) := by ring
    rw [hid]
    have habs4 : |4 * (lam * B - 1/4)| = 4 * |lam * B - 1/4| := by
      rw [abs_mul]; norm_num
    have htri : |(lam * A - 1) - 4 * (lam * B - 1/4)|
        ≤ |lam * A - 1| + |4 * (lam * B - 1/4)| := abs_sub _ _
    rw [habs4] at htri
    linarith
  have habs : |lam| * (A - 4 * B) < 20 * (h ^ 2 / 210) := by
    have heq : |lam| * (A - 4 * B) = |lam * (A - 4 * B)| := by
      rw [abs_mul, abs_of_nonneg (by linarith : (0:ℝ) ≤ A - 4 * B)]
    rw [heq]; exact hcomb
  have hlam : |lam| < 1 / 2 := by
    have h1' : |lam| * (4 * h ^ 2 / 21) ≤ |lam| * (A - 4 * B) :=
      mul_le_mul_of_nonneg_left hgap (abs_nonneg lam)
    nlinarith [abs_nonneg lam, hsq0]
  -- step 2: a small gain cannot reproduce the bilinear value at the corner
  have h4 : h ^ 4 ≤ 1 / 16 := by nlinarith
  have hAbound : |A| ≤ 11 / 10 := by
    rw [abs_le]
    exact ⟨by linarith [hA'.1, hA'.2], by linarith [hA'.1, hA'.2]⟩
  have hlamA : |lam * A| < 11 / 20 := by
    rw [abs_mul]
    have hstep : |lam| * |A| ≤ |lam| * (11 / 10) :=
      mul_le_mul_of_nonneg_left hAbound (abs_nonneg lam)
    linarith
  have hAbs := abs_lt.mp hlamA
  -- a gain below `1/2` leaves `lam * A` below `11/20`, while the corner equation
  -- forces it within `1/210` of `1`
  have hk := abs_lt.mp key1
  linarith [hk.1, hAbs.2, hsq]

/-- **Asymptotic form.**  Since the lower bound `h²/210` is proportional to `h²`,
no affine read-out of the width-`4` gate can be uniformly `O(h⁴)`: for every
constant `C` there is an `h` at which the error exceeds `C·h⁴`. -/
theorem affine_readout_not_fourth_order (C : ℝ) :
    ∃ h : ℝ, 0 < h ∧ h ≤ 1 / 2 ∧ ∀ lam mu nu kappa : ℝ,
      ∃ x ∈ Icc (0:ℝ) 1, ∃ y ∈ Icc (0:ℝ) 1,
        C * h ^ 4 < |affineErr h lam mu nu kappa x y| := by
  obtain ⟨n, hn⟩ := exists_nat_gt (210 * C)
  have hn0 : (0:ℝ) ≤ (n : ℝ) := Nat.cast_nonneg n
  have hle : (1:ℝ) / ((n : ℝ) + 2) ≤ 1 / 2 :=
    one_div_le_one_div_of_le (by norm_num) (by linarith)
  refine ⟨1 / ((n : ℝ) + 2), by positivity, hle, ?_⟩
  intro lam mu nu kappa
  set h : ℝ := 1 / ((n : ℝ) + 2) with hh_def
  have hh0 : 0 < h := by rw [hh_def]; positivity
  obtain ⟨x, hx, y, hy, hxy⟩ := no_affine_debiasing h hh0 hle lam mu nu kappa
  refine ⟨x, hx, y, hy, lt_of_lt_of_le ?_ hxy⟩
  have hh2 : (0:ℝ) < h ^ 2 := by positivity
  have hh1 : h ≤ 1 := le_trans hle (by norm_num)
  have hhn : h * ((n : ℝ) + 2) = 1 := by
    rw [hh_def]; field_simp
  have hkey : 210 * C * h ^ 2 < 1 := by
    rcases le_or_gt C 0 with hC | hC
    · nlinarith
    · have hn' : 210 * C < (n : ℝ) + 2 := by linarith
      have hstep : 210 * C * h < 1 := by nlinarith
      nlinarith
  nlinarith [hh2, hkey]

end

end EML.CorrectionRank

/-! ## 5. Axiom audit -/

section Audit

#print axioms EML.CorrectionRank.no_affine_debiasing
#print axioms EML.CorrectionRank.affine_readout_not_fourth_order
#print axioms EML.CorrectionRank.affine_mixed_difference_corner
#print axioms EML.CorrectionRank.affine_mixed_difference_half
#print axioms EML.CorrectionRank.prodGate_corner_sharp
#print axioms EML.CorrectionRank.prodGate_half_sharp
#print axioms EML.CorrectionRank.prodGate_zero_left

end Audit