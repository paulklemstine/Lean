/-
# Triplication: the "only bad primes" conjecture fails at `n = 3` as well

This file continues `Bridges.MordellDenominatorBadPrimes`, which refuted the
"only bad primes" conjecture for the Mordell curve `E_N : y² = x³ + N` at `n = 2`
(the denominator of `x(2P)` is governed by `2y`, not by the discriminant
`Δ = -432N²`).

Here the same programme is carried out for `n = 3`, where the relevant division
polynomial is `ψ₃ = 3x⁴ + 12Nx` instead of `ψ₂ = 2y`.  The main results are:

* `Bridges.MordellDenominator.triX_eq_chord_addX` and
  `Bridges.MordellDenominator.xCoord_add_add_self`: the classical triplication
  formula `x(3P) = x - ψ₂ψ₄/ψ₃²` agrees with mathlib's Weierstrass group law
  applied to `P + (P + P)`.
* `Bridges.MordellDenominator.prime_dvd_den_triX_iff`: the **mechanism theorem at
  `n = 3`**.  For an integral point `(x,y)` and a prime `ℓ ∤ 6N` of good reduction
  (with `ψ₃ ≠ 0`), `ℓ ∣ den x(3P) ↔ ℓ ∣ x⁴ + 4Nx`, i.e. iff `ψ₃(P) ≡ 0 (mod ℓ)`,
  i.e. iff `P` reduces to a point of order dividing `3`.
* `Bridges.MordellDenominator.tri_counterexample_55`: for the *same* curve and point
  as the `n = 2` counterexample, `N = 55 = 5·11`, `P = (9,28)`, the denominator of
  `x(3P)` is `656538129 = 3⁶·13²·73²`, so the good-reduction primes `13` and `73`
  both occur.  Hence the failure is not an artefact of doubling.
* `Bridges.MordellDenominator.onlyBadPrimesTri_false`: the `n = 3` form of the
  conjecture is false.
* `Bridges.MordellDenominator.every_prime_ge_five_is_extraneous_tri`: every prime
  `ℓ ≥ 5` occurs as a good-reduction denominator prime of some `x(3P)`, via the
  family `N = 1 - ℓ³`, `P = (ℓ, 1)`.

Together with the `n = 2` file this shows that at both levels the denominator is a
function of the *point* (through the division polynomial `ψ_n`), and not of the set
of bad primes of the curve.
-/
import Mathlib
import Bridges.MordellDenominatorBadPrimes

namespace Bridges.MordellDenominator

open WeierstrassCurve

/-! ## The third division polynomial and the triplication formula -/

/-- The third division polynomial `ψ₃ = 3x⁴ + 12Nx` of `y² = x³ + N`. -/
def psi3 (N x : ℚ) : ℚ := 3 * x ^ 4 + 12 * N * x

/-- The `y`-coordinate of `2P` for `P = (x,y)` on `y² = x³ + N`, in closed form. -/
def dblY (N x y : ℚ) : ℚ := (3 * x ^ 2 / (2 * y)) * (x - dblX N x) - y

/-- The `x`-coordinate of `3P`, in the classical division-polynomial form
`x(3P) = x - ψ₂ψ₄/ψ₃²` with `ψ₂ψ₄ = 8y²(x⁶ + 20Nx³ - 8N²)`. -/
def triX (N x y : ℚ) : ℚ :=
  (x * (psi3 N x) ^ 2 - 8 * y ^ 2 * (x ^ 6 + 20 * N * x ^ 3 - 8 * N ^ 2)) / (psi3 N x) ^ 2

/-- `x - x(2P) = ψ₃/ψ₂²`: the doubled point has a different `x`-coordinate exactly when
`ψ₃ ≠ 0`. -/
lemma sub_dblX_eq_psi3_div (N x y : ℚ) (h : y ^ 2 = x ^ 3 + N) (hy : y ≠ 0) :
    x - dblX N x = psi3 N x / (4 * y ^ 2) := by
  have hx3 : x ^ 3 + N = y ^ 2 := h.symm
  unfold dblX psi3
  rw [hx3]
  field_simp
  linear_combination 4 * x * h

/-- The chord through `P` and `2P` produces exactly the classical triplication value. -/
lemma triX_eq_chord (N x y : ℚ) (h : y ^ 2 = x ^ 3 + N) (hy : y ≠ 0) (hu : psi3 N x ≠ 0) :
    ((y - dblY N x y) / (x - dblX N x)) ^ 2 - x - dblX N x = triX N x y := by
  set u : ℚ := psi3 N x with hudef
  have hA : x - dblX N x = u / (4 * y ^ 2) := sub_dblX_eq_psi3_div N x y h hy
  have hdbl : dblX N x = x - u / (4 * y ^ 2) := by linarith [hA]
  have e1 : ((y - dblY N x y) / (x - dblX N x)) ^ 2 - x - dblX N x
      = ((16 * y ^ 4 - 3 * x ^ 2 * u) ^ 2 - 8 * x * y ^ 2 * u ^ 2 + u ^ 3) / (4 * y ^ 2 * u ^ 2) := by
    unfold dblY
    rw [hA, hdbl]
    field_simp
    ring
  have e2 : triX N x y
      = (4 * x * y ^ 2 * u ^ 2 - 32 * y ^ 4 * (x ^ 6 + 20 * N * x ^ 3 - 8 * N ^ 2))
          / (4 * y ^ 2 * u ^ 2) := by
    unfold triX
    rw [← hudef]
    field_simp
    ring
  have key : (16 * y ^ 4 - 3 * x ^ 2 * (3 * x ^ 4 + 12 * N * x)) ^ 2
        - 8 * x * y ^ 2 * (3 * x ^ 4 + 12 * N * x) ^ 2 + (3 * x ^ 4 + 12 * N * x) ^ 3
      = 4 * x * y ^ 2 * (3 * x ^ 4 + 12 * N * x) ^ 2
        - 32 * y ^ 4 * (x ^ 6 + 20 * N * x ^ 3 - 8 * N ^ 2) := by
    obtain rfl : N = y ^ 2 - x ^ 3 := by linarith
    ring
  rw [e1, e2, hudef]
  unfold psi3
  rw [key]

/-! ## Bridge with mathlib's group law -/

/-- `dblY` is mathlib's `addY` for the doubling of `(x,y)`. -/
lemma dblY_eq_addY (N x y : ℚ) (h : y ^ 2 = x ^ 3 + N) (hy : y ≠ 0) :
    (mordell N).addY x x y ((mordell N).slope x x y y) = dblY N x y := by
  rw [Affine.addY, Affine.negAddY, mordellC_negY, dblX_eq_addX N x y h hy,
    mordell_slope N x y hy]
  unfold dblY
  ring

/-- If `ψ₃(P) ≠ 0` then `P` and `2P` have distinct `x`-coordinates, so their sum is computed by
the secant line. -/
lemma x_ne_dblX (N x y : ℚ) (h : y ^ 2 = x ^ 3 + N) (hy : y ≠ 0) (hu : psi3 N x ≠ 0) :
    x ≠ dblX N x := by
  intro hc
  have h0 : psi3 N x / (4 * y ^ 2) = 0 := by
    rw [← sub_dblX_eq_psi3_div N x y h hy, sub_eq_zero]
    exact hc
  have h4 : (4 : ℚ) * y ^ 2 ≠ 0 := by positivity
  rcases div_eq_zero_iff.1 h0 with h1 | h1
  · exact hu h1
  · exact h4 h1

/-- Mathlib's secant slope through `P` and `2P`, with the `y`-coordinate of `2P` given by
`dblY`. -/
lemma mordell_slope_chord (N x y : ℚ) (hne : x ≠ dblX N x) :
    (mordell N).slope x (dblX N x) y (dblY N x y) = (y - dblY N x y) / (x - dblX N x) :=
  Affine.slope_of_X_ne hne

/-- **Bridge at `n = 3` (formula level).** Mathlib's `addX` applied to `P` and `2P` returns the
classical triplication value `triX`. -/
theorem triX_eq_chord_addX (N x y : ℚ) (h : y ^ 2 = x ^ 3 + N) (hy : y ≠ 0)
    (hu : psi3 N x ≠ 0) :
    (mordell N).addX x (dblX N x) ((mordell N).slope x (dblX N x) y (dblY N x y))
      = triX N x y := by
  have hne : x ≠ dblX N x := x_ne_dblX N x y h hy hu
  rw [mordell_slope_chord N x y hne, Affine.addX]
  simp only [mordellC]
  have := triX_eq_chord N x y h hy hu
  linarith [this]

/-- **Bridge at `n = 3` (group law level).** For a nonsingular point `P = (x,y)` with `y ≠ 0`
and `ψ₃(P) ≠ 0`, the `x`-coordinate of `P + (P + P)` computed by mathlib's group law is exactly
the classical triplication value `triX N x y`. -/
theorem xCoord_add_add_self (N x y : ℚ) (hns : (mordell N).Nonsingular x y)
    (h : y ^ 2 = x ^ 3 + N) (hy : y ≠ 0) (hu : psi3 N x ≠ 0) :
    ∃ hns2 : (mordell N).Nonsingular (dblX N x) (dblY N x y),
      xCoord (Affine.Point.some hns + Affine.Point.some hns) = some (dblX N x) ∧
      xCoord (Affine.Point.some hns + Affine.Point.some hns2) = some (triX N x y) := by
  classical
  have hyne : y ≠ (mordell N).negY x y := by
    rw [mordellC_negY]
    intro hc
    exact hy (by linarith)
  have hns2 : (mordell N).Nonsingular (dblX N x) (dblY N x y) := by
    have := Affine.nonsingular_add (W := mordell N) hns hns (fun hxy => hyne hxy.right)
    rwa [dblX_eq_addX N x y h hy, dblY_eq_addY N x y h hy] at this
  refine ⟨hns2, ?_, ?_⟩
  · exact xCoord_add_self N x y hns h hy
  · have hne : x ≠ dblX N x := x_ne_dblX N x y h hy hu
    rw [Affine.Point.add_of_X_ne (h₁ := hns) (h₂ := hns2) hne]
    show some ((mordell N).addX x (dblX N x)
      ((mordell N).slope x (dblX N x) y (dblY N x y))) = _
    rw [triX_eq_chord_addX N x y h hy hu]

/-! ## The mechanism theorem at `n = 3` -/

/-- The triplication value as an explicit fraction of integers. -/
lemma triX_intCast (N x y : ℤ) :
    triX (N : ℚ) (x : ℚ) (y : ℚ)
      = (((x * (3 * x ^ 4 + 12 * N * x) ^ 2
            - 8 * y ^ 2 * (x ^ 6 + 20 * N * x ^ 3 - 8 * N ^ 2) : ℤ)) : ℚ)
        / ((((3 * x ^ 4 + 12 * N * x) ^ 2 : ℤ)) : ℚ) := by
  unfold triX psi3; push_cast; ring

/-- Key nonvanishing step: if `ℓ ∤ 6N` is a prime dividing `ψ₃`, then `ℓ` does not divide
`8y²(x⁶ + 20Nx³ - 8N²)`, the numerator correction term of the triplication formula. -/
lemma not_dvd_psi2_psi4 (N x y : ℤ) (h : y ^ 2 = x ^ 3 + N) (l : ℕ) (hl : l.Prime)
    (hl6N : ¬(l : ℤ) ∣ 6 * N) (hpsi : (l : ℤ) ∣ 3 * x ^ 4 + 12 * N * x) :
    ¬(l : ℤ) ∣ 8 * y ^ 2 * (x ^ 6 + 20 * N * x ^ 3 - 8 * N ^ 2) := by
  haveI : Fact l.Prime := ⟨hl⟩
  have hl2 : ¬(l : ℤ) ∣ 2 := fun hc => hl6N (dvd_mul_of_dvd_left (hc.trans ⟨3, by ring⟩) N)
  have hl3 : ¬(l : ℤ) ∣ 3 := fun hc => hl6N (dvd_mul_of_dvd_left (hc.trans ⟨2, by ring⟩) N)
  have hlN : ¬(l : ℤ) ∣ N := fun hc => hl6N (Dvd.dvd.mul_left hc 6)
  -- move to the residue field
  set X : ZMod l := (x : ZMod l) with hX
  set Y : ZMod l := (y : ZMod l) with hY
  set M : ZMod l := (N : ZMod l) with hM
  have h2F : (2 : ZMod l) ≠ 0 := fun hc =>
    hl2 ((ZMod.intCast_zmod_eq_zero_iff_dvd 2 l).1 (by exact_mod_cast hc))
  have h3F : (3 : ZMod l) ≠ 0 := fun hc =>
    hl3 ((ZMod.intCast_zmod_eq_zero_iff_dvd 3 l).1 (by exact_mod_cast hc))
  have hMF : M ≠ 0 := fun hc => hlN ((ZMod.intCast_zmod_eq_zero_iff_dvd N l).1 hc)
  have hcurve : Y ^ 2 = X ^ 3 + M := by
    have : ((y ^ 2 : ℤ) : ZMod l) = ((x ^ 3 + N : ℤ) : ZMod l) := by rw [h]
    push_cast at this
    exact this
  have hpsiF : 3 * X ^ 4 + 12 * M * X = 0 := by
    have := (ZMod.intCast_zmod_eq_zero_iff_dvd (3 * x ^ 4 + 12 * N * x) l).2 hpsi
    push_cast at this
    exact this
  intro hdvd
  have hdvdF : 8 * Y ^ 2 * (X ^ 6 + 20 * M * X ^ 3 - 8 * M ^ 2) = 0 := by
    have := (ZMod.intCast_zmod_eq_zero_iff_dvd
      (8 * y ^ 2 * (x ^ 6 + 20 * N * x ^ 3 - 8 * N ^ 2)) l).2 hdvd
    push_cast at this
    exact this
  have hfac : (3 : ZMod l) * (X * (X ^ 3 + 4 * M)) = 0 := by linear_combination hpsiF
  have hsplit : X = 0 ∨ X ^ 3 + 4 * M = 0 := by
    rcases mul_eq_zero.1 hfac with hc | hc
    · exact absurd hc h3F
    · exact mul_eq_zero.1 hc
  rcases hsplit with hX0 | hX4
  · -- `X = 0`: the term equals `-64 M³`
    have hY2 : Y ^ 2 = M := by rw [hcurve, hX0]; ring
    have hval : 8 * Y ^ 2 * (X ^ 6 + 20 * M * X ^ 3 - 8 * M ^ 2) = -(64 * M ^ 3) := by
      rw [hX0, hY2]; ring
    rw [hval] at hdvdF
    have h64 : (64 : ZMod l) ≠ 0 := by
      have : (64 : ZMod l) = 2 ^ 6 := by norm_num
      rw [this]; exact pow_ne_zero 6 h2F
    have : (64 : ZMod l) * M ^ 3 = 0 := by linear_combination -hdvdF
    rcases mul_eq_zero.1 this with hc | hc
    · exact h64 hc
    · exact hMF (pow_eq_zero_iff (n := 3) (by norm_num) |>.1 hc)
  · -- `X³ = -4M`: the term equals `1728 M³`
    have hval : 8 * Y ^ 2 * (X ^ 6 + 20 * M * X ^ 3 - 8 * M ^ 2) = 1728 * M ^ 3 := by
      linear_combination (8 * (X ^ 6 + 20 * M * X ^ 3 - 8 * M ^ 2)) * hcurve
        + (8 * X ^ 6 + 136 * M * X ^ 3 - 448 * M ^ 2) * hX4
    rw [hval] at hdvdF
    have h1728 : (1728 : ZMod l) ≠ 0 := by
      have : (1728 : ZMod l) = 2 ^ 6 * 3 ^ 3 := by norm_num
      rw [this]; exact mul_ne_zero (pow_ne_zero 6 h2F) (pow_ne_zero 3 h3F)
    rcases mul_eq_zero.1 hdvdF with hc | hc
    · exact h1728 hc
    · exact hMF (pow_eq_zero_iff (n := 3) (by norm_num) |>.1 hc)

/-- **Mechanism theorem at `n = 3`.**  Let `(x,y)` be an integral point of `y² = x³ + N` with
`ψ₃(P) = 3x⁴ + 12Nx ≠ 0` (equivalently `x(3P)` is defined and `3P ≠ O` reduces properly), and let
`ℓ` be a prime of good reduction, `ℓ ∤ 6N`.  Then `ℓ` divides the denominator of `x(3P)` **iff**
`ℓ` divides `x⁴ + 4Nx`, i.e. iff `ψ₃(P) ≡ 0 (mod ℓ)`.  So, exactly as for doubling, the
denominator is controlled by the division polynomial at the point, and good-reduction primes are
not excluded. -/
theorem prime_dvd_den_triX_iff (N x y : ℤ) (h : y ^ 2 = x ^ 3 + N)
    (hpsi0 : 3 * x ^ 4 + 12 * N * x ≠ 0) (l : ℕ) (hl : l.Prime) (hl6N : ¬(l : ℤ) ∣ 6 * N) :
    (l : ℤ) ∣ ((triX (N : ℚ) (x : ℚ) (y : ℚ)).den : ℤ) ↔ (l : ℤ) ∣ x ^ 4 + 4 * N * x := by
  have hlp : Prime (l : ℤ) := Nat.prime_iff_prime_int.mp hl
  have hl3 : ¬(l : ℤ) ∣ 3 := fun hc => hl6N (dvd_mul_of_dvd_left (hc.trans ⟨2, by ring⟩) N)
  have hpsi_iff : (l : ℤ) ∣ 3 * x ^ 4 + 12 * N * x ↔ (l : ℤ) ∣ x ^ 4 + 4 * N * x := by
    constructor
    · intro hd
      rcases hlp.dvd_mul.1 (show (l : ℤ) ∣ 3 * (x ^ 4 + 4 * N * x) by
        rw [show (3 : ℤ) * (x ^ 4 + 4 * N * x) = 3 * x ^ 4 + 12 * N * x by ring]; exact hd) with
        h3 | hrest
      · exact absurd h3 hl3
      · exact hrest
    · intro hd
      rw [show (3 : ℤ) * x ^ 4 + 12 * N * x = 3 * (x ^ 4 + 4 * N * x) by ring]
      exact Dvd.dvd.mul_left hd 3
  rw [triX_intCast]
  rw [← hpsi_iff]
  constructor
  · intro hd
    have h1 : (l : ℤ) ∣ (3 * x ^ 4 + 12 * N * x) ^ 2 := hd.trans (den_dvd_den _ _)
    exact hlp.dvd_of_dvd_pow h1
  · intro hdpsi
    refine prime_dvd_den _ _ (pow_ne_zero 2 hpsi0) l hl (dvd_pow hdpsi two_ne_zero) ?_
    intro hc
    refine not_dvd_psi2_psi4 N x y h l hl hl6N hdpsi ?_
    have hx : (l : ℤ) ∣ x * (3 * x ^ 4 + 12 * N * x) ^ 2 :=
      Dvd.dvd.mul_left (dvd_pow hdpsi two_ne_zero) x
    have := dvd_sub hx hc
    simpa using this

/-! ## Good reduction and 3-torsion: the conceptual mechanism at `n = 3` -/

/-- The tangent slope at a point of the Mordell curve, over any field of characteristic `≠ 2`. -/
lemma mordellC_slope_self {F : Type*} [Field F] [DecidableEq F] (N x y : F) (h2 : (2 : F) ≠ 0)
    (hy : y ≠ 0) : (mordellC N).slope x x y y = 3 * x ^ 2 / (2 * y) := by
  rw [Affine.slope, if_pos rfl, if_neg (by
    simp [mordellC]
    intro hc
    exact absurd (by linear_combination hc : (2 : F) * y = 0) (mul_ne_zero h2 hy))]
  simp [mordellC]
  ring_nf

/-- `x(2P) - x(P) = -ψ₃/ψ₂²` over any field of characteristic `≠ 2`: the doubled point has the
same `x`-coordinate as `P` exactly when `ψ₃(P) = 0`. -/
lemma addX_self_sub {F : Type*} [Field F] [DecidableEq F] (N x y : F) (h2 : (2 : F) ≠ 0)
    (hy : y ≠ 0) (h : y ^ 2 = x ^ 3 + N) :
    (mordellC N).addX x x ((mordellC N).slope x x y y) - x
      = -((3 * x ^ 4 + 12 * N * x) / (4 * y ^ 2)) := by
  have h4 : (4 : F) ≠ 0 := by
    have h44 : (4 : F) = 2 * 2 := by norm_num
    rw [h44]; exact mul_ne_zero h2 h2
  rw [mordellC_slope_self N x y h2 hy, Affine.addX]
  simp only [mordellC]
  field_simp
  linear_combination (-48 * x) * h

/-- **The third division polynomial cuts out the 3-torsion.**  Over any field of characteristic
`≠ 2, 3` and for `N ≠ 0`, a point `P = (X,Y)` of `y² = x³ + N` satisfies `3P = 0` if and only if
`ψ₃(P) = 3X⁴ + 12NX = 0` (equivalently `X⁴ + 4NX = 0`). -/
theorem three_torsion_iff_psi3 {F : Type*} [Field F] [DecidableEq F] (N X Y : F)
    (h2 : (2 : F) ≠ 0) (h3 : (3 : F) ≠ 0) (hN : N ≠ 0) (hcurve : Y ^ 2 = X ^ 3 + N)
    (hns : (mordellC N).Nonsingular X Y) :
    (Affine.Point.some hns + Affine.Point.some hns + Affine.Point.some hns = 0)
      ↔ X ^ 4 + 4 * N * X = 0 := by
  have h4 : (4 : F) ≠ 0 := by
    have h44 : (4 : F) = 2 * 2 := by norm_num
    rw [h44]; exact mul_ne_zero h2 h2
  by_cases hY : Y = 0
  · -- `P` is 2-torsion, so `3P = P ≠ 0`, while `ψ₃(P) = 9NX ≠ 0`
    have hX3 : X ^ 3 = -N := by rw [hY] at hcurve; linear_combination -hcurve
    have hXne : X ≠ 0 := by
      intro hx0
      rw [hx0] at hX3
      exact hN (by linear_combination hX3)
    have hdbl : Affine.Point.some hns + Affine.Point.some hns = 0 :=
      Affine.Point.add_self_of_Y_eq (by rw [mordellC_negY, hY, neg_zero])
    constructor
    · intro hc
      rw [hdbl, zero_add] at hc
      exact absurd hc (Affine.Point.some_ne_zero hns)
    · intro hc
      exfalso
      have hz : X * (3 * N) = 0 := by linear_combination hc - X * hX3
      rcases mul_eq_zero.1 hz with h' | h'
      · exact hXne h'
      · rcases mul_eq_zero.1 h' with h'' | h''
        · exact h3 h''
        · exact hN h''
  · have hyne : Y ≠ (mordellC N).negY X Y := by
      rw [mordellC_negY]
      intro hc
      exact absurd (by linear_combination hc : (2 : F) * Y = 0) (mul_ne_zero h2 hY)
    rw [Affine.Point.add_self_of_Y_ne (h₁ := hns) hyne, add_eq_zero_iff_eq_neg,
      Affine.Point.neg_some, Affine.Point.some.injEq]
    have hsub := addX_self_sub N X Y h2 hY hcurve
    constructor
    · rintro ⟨hx, -⟩
      rw [hx, sub_self] at hsub
      have hzero : 3 * X ^ 4 + 12 * N * X = 0 := by
        have hs := hsub.symm
        rw [neg_eq_zero, div_eq_zero_iff] at hs
        rcases hs with h' | h'
        · exact h'
        · exact absurd h' (mul_ne_zero h4 (pow_ne_zero 2 hY))
      have h3' : (3 : F) * (X ^ 4 + 4 * N * X) = 0 := by linear_combination hzero
      rcases mul_eq_zero.1 h3' with h' | h'
      · exact absurd h' h3
      · exact h'
    · intro hpsi
      have hzero : (3 * X ^ 4 + 12 * N * X) / (4 * Y ^ 2) = 0 := by
        rw [div_eq_zero_iff]
        exact Or.inl (by linear_combination 3 * hpsi)
      have hx : (mordellC N).addX X X ((mordellC N).slope X X Y Y) = X := by
        rw [hzero, neg_zero, sub_eq_zero] at hsub
        exact hsub
      refine ⟨hx, ?_⟩
      rw [Affine.addY, Affine.negAddY, hx, mordellC_negY, mordellC_negY]
      ring

/-- **Reduction/torsion bridge at `n = 3`.**  For a good-reduction prime `ℓ ∤ 6N`, the prime `ℓ`
divides the denominator of `x(3P)` **iff** the reduction `P̄` of `P` satisfies `3P̄ = 0` in
`E_N(𝔽_ℓ)`.  This is the `n = 3` analogue of `den_dvd_iff_reduction_two_torsion`: the denominator
sees exactly those good primes at which `P` reduces into the `3`-torsion. -/
theorem den_triX_dvd_iff_reduction_three_torsion (N x y : ℤ) (h : y ^ 2 = x ^ 3 + N)
    (hpsi0 : 3 * x ^ 4 + 12 * N * x ≠ 0) (l : ℕ) [hFl : Fact l.Prime]
    (hl6N : ¬(l : ℤ) ∣ 6 * N)
    (hns : (mordellC ((N : ZMod l))).Nonsingular ((x : ZMod l)) ((y : ZMod l))) :
    (l : ℤ) ∣ ((triX (N : ℚ) (x : ℚ) (y : ℚ)).den : ℤ) ↔
      Affine.Point.some hns + Affine.Point.some hns + Affine.Point.some hns = 0 := by
  classical
  have hl2 : ¬(l : ℤ) ∣ 2 := fun hc => hl6N (dvd_mul_of_dvd_left (hc.trans ⟨3, by ring⟩) N)
  have hl3 : ¬(l : ℤ) ∣ 3 := fun hc => hl6N (dvd_mul_of_dvd_left (hc.trans ⟨2, by ring⟩) N)
  have hlN : ¬(l : ℤ) ∣ N := fun hc => hl6N (Dvd.dvd.mul_left hc 6)
  have h2F : (2 : ZMod l) ≠ 0 := fun hc =>
    hl2 ((ZMod.intCast_zmod_eq_zero_iff_dvd 2 l).1 (by exact_mod_cast hc))
  have h3F : (3 : ZMod l) ≠ 0 := fun hc =>
    hl3 ((ZMod.intCast_zmod_eq_zero_iff_dvd 3 l).1 (by exact_mod_cast hc))
  have hNF : ((N : ZMod l)) ≠ 0 := fun hc =>
    hlN ((ZMod.intCast_zmod_eq_zero_iff_dvd N l).1 hc)
  have hcurveF : ((y : ZMod l)) ^ 2 = ((x : ZMod l)) ^ 3 + ((N : ZMod l)) := by
    have hcast : ((y ^ 2 : ℤ) : ZMod l) = ((x ^ 3 + N : ℤ) : ZMod l) := by rw [h]
    push_cast at hcast
    exact hcast
  rw [prime_dvd_den_triX_iff N x y h hpsi0 l hFl.out hl6N,
    three_torsion_iff_psi3 ((N : ZMod l)) ((x : ZMod l)) ((y : ZMod l)) h2F h3F hNF hcurveF hns]
  rw [← ZMod.intCast_zmod_eq_zero_iff_dvd (x ^ 4 + 4 * N * x) l]
  push_cast
  rfl

/-! ## The counterexample at `n = 3`: same curve, new extraneous primes -/

lemma triX_55 : triX (55 : ℚ) (9 : ℚ) (28 : ℚ) = -2302089191 / 656538129 := by
  unfold triX psi3; norm_num

/-- The denominator of `x(3P)` for `N = 55`, `P = (9,28)` is `656538129 = 3⁶ · 13² · 73²`. -/
lemma den_triX_55 : (triX (55 : ℚ) (9 : ℚ) (28 : ℚ)).den = 656538129 := by
  rw [triX_55]; norm_num

/-- **Counterexample at `n = 3`.**  For the same curve `N = 55 = 5·11` and the same point
`P = (9,28)` as in the doubling counterexample, the denominator of `x(3P)` is
`656538129 = 3⁶·13²·73²`, so both `13` and `73` are primes of *good* reduction occurring in the
denominator, and neither lies in `{2,3,5,11}`.  The set of extraneous primes therefore grows
with `n`. -/
theorem tri_counterexample_55 :
    (triX (55 : ℚ) (9 : ℚ) (28 : ℚ)).den = 3 ^ 6 * 13 ^ 2 * 73 ^ 2 ∧
      (13 : ℤ) ∣ ((triX (55 : ℚ) (9 : ℚ) (28 : ℚ)).den : ℤ) ∧
      (73 : ℤ) ∣ ((triX (55 : ℚ) (9 : ℚ) (28 : ℚ)).den : ℤ) ∧
      (13 : ℕ) ∉ badPrimes 55 ∧ (73 : ℕ) ∉ badPrimes 55 ∧
      ¬(13 : ℤ) ∣ (-432 * 55 ^ 2 : ℤ) ∧ ¬(73 : ℤ) ∣ (-432 * 55 ^ 2 : ℤ) := by
  refine ⟨by rw [den_triX_55]; norm_num, by rw [den_triX_55]; norm_num,
    by rw [den_triX_55]; norm_num, ?_, ?_, by decide, by decide⟩
  · intro hm
    simp only [badPrimes, Finset.mem_insert, Nat.mem_primeFactors] at hm
    rcases hm with h | h | ⟨-, hd, -⟩ <;> omega
  · intro hm
    simp only [badPrimes, Finset.mem_insert, Nat.mem_primeFactors] at hm
    rcases hm with h | h | ⟨-, hd, -⟩ <;> omega

/-- **The extraneous primes move with `n`.**  For `N = 55`, `P = (9,28)`, the good-reduction prime
`7` divides `den x(2P)` but not `den x(3P)`, while `13` and `73` divide `den x(3P)` but not
`den x(2P)`.  So the extraneous primes at levels `2` and `3` are disjoint here: the denominators
read off the division polynomials `ψ₂, ψ₃` at `P`, not any fixed set attached to `N`. -/
theorem extraneous_primes_shift_55 :
    (7 : ℤ) ∣ ((dblX (55 : ℚ) (9 : ℚ)).den : ℤ) ∧
      ¬(7 : ℤ) ∣ ((triX (55 : ℚ) (9 : ℚ) (28 : ℚ)).den : ℤ) ∧
      (13 : ℤ) ∣ ((triX (55 : ℚ) (9 : ℚ) (28 : ℚ)).den : ℤ) ∧
      ¬(13 : ℤ) ∣ ((dblX (55 : ℚ) (9 : ℚ)).den : ℤ) ∧
      (73 : ℤ) ∣ ((triX (55 : ℚ) (9 : ℚ) (28 : ℚ)).den : ℤ) ∧
      ¬(73 : ℤ) ∣ ((dblX (55 : ℚ) (9 : ℚ)).den : ℤ) := by
  rw [den_dblX_55, den_triX_55]
  refine ⟨by norm_num, by decide, by norm_num, by decide, by norm_num, by decide⟩

/-- The `n = 3` form of the "only bad primes" conjecture: for `N = pq` and an integral point
`(x,y)`, every prime dividing the denominator of `x(3P)` lies in `{2,3,p,q}`. -/
def OnlyBadPrimesTriConj : Prop :=
  ∀ (p q : ℕ), p.Prime → q.Prime → ∀ (x y : ℤ), y ^ 2 = x ^ 3 + (p * q : ℕ) →
    ∀ l : ℕ, l.Prime → (l : ℤ) ∣ ((triX ((p * q : ℕ) : ℚ) (x : ℚ) (y : ℚ)).den : ℤ) →
      l ∈ badPrimes (p * q)

/-- **The conjecture is false at `n = 3` too**, witnessed by `N = 55 = 5·11`, `P = (9,28)`,
`ℓ = 13`. -/
theorem onlyBadPrimesTri_false : ¬ OnlyBadPrimesTriConj := by
  intro hconj
  have h55 : ((5 * 11 : ℕ) : ℚ) = (55 : ℚ) := by norm_num
  have hpt : (28 : ℤ) ^ 2 = (9 : ℤ) ^ 3 + ((5 * 11 : ℕ) : ℤ) := by norm_num
  have hmem := hconj 5 11 (by norm_num) (by norm_num) 9 28 hpt 13 (by norm_num) (by
    rw [show (((9 : ℤ)) : ℚ) = (9 : ℚ) by norm_num,
      show (((28 : ℤ)) : ℚ) = (28 : ℚ) by norm_num, h55, den_triX_55]
    norm_num)
  exact tri_counterexample_55.2.2.2.1 hmem

/-! ## Every prime `≥ 5` is extraneous at `n = 3` as well -/

/-- **No prime is excluded at `n = 3`.**  For every prime `ℓ ≥ 5` take `N = 1 - ℓ³` and the
integral point `P = (ℓ, 1)` of `E_N`.  Then `ℓ` is a prime of good reduction (`ℓ ∤ 6N`, hence
`ℓ ∤ Δ`) and `ℓ` divides the denominator of `x(3P)`. -/
theorem every_prime_ge_five_is_extraneous_tri (l : ℕ) (hl : l.Prime) (h5 : 5 ≤ l) :
    ¬((l : ℤ) ∣ 6 * (1 - (l : ℤ) ^ 3)) ∧
      (l : ℤ) ∣ ((triX (((1 - (l : ℤ) ^ 3 : ℤ)) : ℚ) (((l : ℤ)) : ℚ) ((1 : ℤ) : ℚ)).den : ℤ) := by
  have hlZ : (2 : ℤ) ≤ (l : ℤ) := by exact_mod_cast hl.two_le
  have hgood : ¬((l : ℤ) ∣ 6 * (1 - (l : ℤ) ^ 3)) := by
    intro hc
    refine prime_ge_five_not_dvd_six l hl h5 ?_
    have h6 : (6 : ℤ) = 6 * (1 - (l : ℤ) ^ 3) + 6 * (l : ℤ) ^ 3 := by ring
    rw [h6]
    exact dvd_add hc (Dvd.dvd.mul_left (dvd_pow_self (l : ℤ) three_ne_zero) 6)
  refine ⟨hgood, ?_⟩
  have hcurve : (1 : ℤ) ^ 2 = (l : ℤ) ^ 3 + (1 - (l : ℤ) ^ 3) := by ring
  have hpsi0 : 3 * (l : ℤ) ^ 4 + 12 * (1 - (l : ℤ) ^ 3) * (l : ℤ) ≠ 0 := by
    have hl5 : (5 : ℤ) ≤ (l : ℤ) := by exact_mod_cast h5
    have hexp : 3 * (l : ℤ) ^ 4 + 12 * (1 - (l : ℤ) ^ 3) * (l : ℤ)
        = (l : ℤ) * (12 - 9 * (l : ℤ) ^ 3) := by ring
    rw [hexp]
    refine mul_ne_zero (by linarith) ?_
    intro hc
    have hnn : (0 : ℤ) ≤ ((l : ℤ) - 5) * ((l : ℤ) ^ 2 + 5 * (l : ℤ) + 25) :=
      mul_nonneg (by linarith) (by nlinarith)
    nlinarith [hnn, hc]
  refine (prime_dvd_den_triX_iff (1 - (l : ℤ) ^ 3) (l : ℤ) 1 hcurve hpsi0 l hl hgood).2 ?_
  exact ⟨(l : ℤ) ^ 3 + 4 * (1 - (l : ℤ) ^ 3), by ring⟩

end Bridges.MordellDenominator