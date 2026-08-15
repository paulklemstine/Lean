import Mathlib
import Combinatorics.MordellDenominatorPointCount

/-!
# The third layer: tripling, the division polynomial `ψ₃`, and its residue classes

The previous file (`Combinatorics.MordellDenominatorPointCount`) analysed the *doubling* layer
of the Mordell curve `E_N : y² = x³ + N`: a good prime `ℓ ≥ 5` divides the denominator of
`x(2P)` exactly when the reduction of `x` is a root of `T³ + N`, the division polynomial
`ψ₂`-condition in disguise (`ℓ ∣ y ↔ y² = x³ + N ≡ 0`).

Here we prove the analogous statement one layer up, for `3P`.  The relevant polynomial is the
third division polynomial of `y² = x³ + N`,
`ψ₃(x) = 3x⁴ + 12Nx = 3x(x³ + 4N)`,
and the numerator is
`φ₃(x) = x⁹ - 96Nx⁶ + 48N²x³ + 64N³`.

## Main results

* `mordell_triple_xCoord` : **derived from Mathlib's group law** (two applications of the affine
  addition formulas), `x(3P) = φ₃(x)/ψ₃(x)²` for every rational point of `E_N` with `y ≠ 0`
  and `ψ₃(x) ≠ 0`.  This is the general form of the numeric computation `xCoord_triple_55` of
  `Applications.MordellDenominatorOrbits`.
* `not_dvd_phi3_of_dvd_psi3` : the non-cancellation lemma.  If `ℓ ≥ 5` is a good prime dividing
  `ψ₃(x)` then `ℓ ∤ φ₃(x)`; the two exceptional evaluations are `φ₃ ≡ 64N³` (when `ℓ ∣ x`) and
  `φ₃ ≡ -1728N³` (when `x³ ≡ -4N`), and `1728 = 12³` is composed of the primes `2, 3` only.
* `dvd_den_triple_iff` : hence `ℓ ∣ den x(3P) ↔ ℓ ∣ ψ₃(x)`, the layer-3 analogue of
  `MordellDenominators.dvd_den_double_iff`.
* `card_vanishingClasses3_of_two_mod_three` : at a supersingular prime the layer-3 locus has
  exactly **two** classes (`x ≡ 0` and the unique cube root of `-4N`), against one class at
  layer 2; `card_layer2_union_layer3` shows the two layers together contribute exactly `3`
  classes, all distinct.
* `card_vanishingClasses3_of_one_mod_three` : at an ordinary prime the count is `1` or `4`.
* `good_prime_realised_layer3` : every prime `ℓ ≥ 5` is a good-reduction denominator prime at
  layer 3 for the explicit curve `N = 1 - ℓ³` and point `P = (ℓ, 1)`.
* `triple_55_recovers_13_and_73` : specialising the general theory to `N = 55`, `P = (9,28)`
  reproves the catalog's numeric fact that `13` and `73` divide `den x(3P)`, from
  `ψ₃(9) = 25623 = 3³ · 13 · 73`.

-- !-- Lab Notes -- !--
Hypothesizer: the doubling analysis should be layer 2 of a tower indexed by the division
  polynomials `ψ_n`; the prediction is `ℓ ∣ den x(nP) ↔ ℓ ∣ ψ_n(x)` for good `ℓ`, with the
  residue-class count equal to `#{roots of ψ_n mod ℓ}` — growing like `n²/2`.
Experimenter: layer 3 is proved in full here.  The formula `x(3P) = φ₃/ψ₃²` is *derived* from
  `WeierstrassCurve.Affine.Point.add_self_of_Y_ne` and `add_of_X_ne`, not postulated, and the
  arithmetic core is the pair of evaluations `φ₃ ≡ 64N³` and `φ₃ ≡ -1728N³`.
Analyst: the two exceptional constants `64 = 2⁶` and `1728 = 2⁶·3³` are exactly the "small bad
  primes" `2, 3` of the Mordell family — the reason the criterion needs `ℓ ≥ 5` and no more.
  The class count jumps `1 → 2` from layer 2 to layer 3 at supersingular primes, and the union
  of the two loci has exactly `3` classes: reduction to a `2`- or `3`-torsion point.
Critic: `ψ₃(x) ≠ 0` is a genuine hypothesis (it says `2P ≠ ±P`, i.e. `P` is not `3`-torsion);
  over `ℚ` it fails only for the finitely many `3`-torsion points.  The layer-3 counting needs
  `ℓ ∤ N` (as does layer 2) and `ℓ ≥ 5` (`3` divides `ψ₃` identically).  No `sorry` below.
-/

namespace MordellPointCount

open Finset EllipticModCount MordellDenominators WeierstrassCurve WeierstrassCurve.Affine

variable {ℓ : ℕ}

/-- `2` is invertible mod a prime `ℓ ≥ 5`. -/
lemma two_ne_zero_zmod [Fact ℓ.Prime] (hl5 : 5 ≤ ℓ) : (2 : ZMod ℓ) ≠ 0 := by
  have h : ((2 : ℕ) : ZMod ℓ) ≠ 0 := by
    rw [Ne, ZMod.natCast_eq_zero_iff]
    intro hc
    have := Nat.le_of_dvd (by norm_num) hc
    omega
  simpa using h

/-! ## The tripling formula, derived from Mathlib's group law -/

private lemma triple_slope_aux (P y x : ℚ) (hy : y ≠ 0) (hP : P ≠ 0) :
    ((y - (16 * y ^ 4 - 3 * x ^ 2 * P) / (8 * y ^ 3)) - y) / ((x - P / (4 * y ^ 2)) - x)
      = (16 * y ^ 4 - 3 * x ^ 2 * P) / (2 * y * P) := by
  have h1 : (x - P / (4 * y ^ 2)) - x = (-P) / (4 * y ^ 2) := by ring
  have h2 : (y - (16 * y ^ 4 - 3 * x ^ 2 * P) / (8 * y ^ 3)) - y
      = (-(16 * y ^ 4 - 3 * x ^ 2 * P)) / (8 * y ^ 3) := by ring
  rw [h1, h2, div_div_div_eq]
  rw [div_eq_div_iff (mul_ne_zero (by positivity) (neg_ne_zero.mpr hP))
    (mul_ne_zero (mul_ne_zero two_ne_zero hy) hP)]
  ring

private lemma triple_final_aux (N x y : ℚ) (hy : y ≠ 0) (heq : y ^ 2 = x ^ 3 + N)
    (hpsi : 3 * x ^ 4 + 12 * N * x ≠ 0) :
    ((16 * y ^ 4 - 3 * x ^ 2 * (3 * x ^ 4 + 12 * N * x)) / (2 * y * (3 * x ^ 4 + 12 * N * x))) ^ 2
      - (x - (3 * x ^ 4 + 12 * N * x) / (4 * y ^ 2)) - x
      = (x ^ 9 - 96 * N * x ^ 6 + 48 * N ^ 2 * x ^ 3 + 64 * N ^ 3)
          / (3 * x ^ 4 + 12 * N * x) ^ 2 := by
  have hy2 : (y : ℚ) ^ 2 ≠ 0 := pow_ne_zero _ hy
  have hxN : (x ^ 3 + N) ≠ 0 := by rw [← heq]; exact hy2
  obtain ⟨P, hP⟩ : ∃ P : ℚ, P = 3 * x ^ 4 + 12 * N * x := ⟨_, rfl⟩
  rw [← hP] at hpsi ⊢
  rw [div_pow, show (2 * y * P) ^ 2 = 4 * y ^ 2 * P ^ 2 by ring,
    show (16 * y ^ 4 - 3 * x ^ 2 * P) ^ 2
      = 256 * (y ^ 2) ^ 4 - 96 * x ^ 2 * P * (y ^ 2) ^ 2 + 9 * x ^ 4 * P ^ 2 by ring, heq]
  field_simp
  subst hP
  ring

/-- **Tripling formula.**  For a nonsingular rational point `P = (x, y)` of `E_N : y² = x³ + N`
with `y ≠ 0` (so `P` is not `2`-torsion) and `ψ₃(x) = 3x⁴ + 12Nx ≠ 0` (so `P` is not
`3`-torsion), Mathlib's affine group law gives
`x(3P) = (x⁹ - 96Nx⁶ + 48N²x³ + 64N³) / (3x⁴ + 12Nx)²`. -/
theorem mordell_triple_xCoord (N x y : ℚ) (h : (mordell N).toAffine.Nonsingular x y) (hy : y ≠ 0)
    (hpsi : 3 * x ^ 4 + 12 * N * x ≠ 0) :
    xCoord (Point.some h + Point.some h + Point.some h)
      = some ((x ^ 9 - 96 * N * x ^ 6 + 48 * N ^ 2 * x ^ 3 + 64 * N ^ 3)
          / (3 * x ^ 4 + 12 * N * x) ^ 2) := by
  have heq : y ^ 2 = x ^ 3 + N := (mordell_equation_iff N x y).1 h.1
  have hy2 : (y : ℚ) ^ 2 ≠ 0 := pow_ne_zero _ hy
  have hne : y ≠ (mordell N).toAffine.negY x y := by
    simp only [WeierstrassCurve.Affine.negY, mordell_a₁, mordell_a₃, ne_eq]
    intro hc; exact hy (by linarith)
  have hs : (mordell N).toAffine.slope x x y y = 3 * x ^ 2 / (2 * y) := by
    rw [slope_of_Y_ne rfl hne]
    simp only [WeierstrassCurve.Affine.negY, mordell_a₁, mordell_a₂, mordell_a₃, mordell_a₄]
    ring_nf
  have hx2 : (mordell N).toAffine.addX x x ((mordell N).toAffine.slope x x y y)
      = x - (3 * x ^ 4 + 12 * N * x) / (4 * y ^ 2) := by
    rw [hs]
    simp only [WeierstrassCurve.Affine.addX, mordell_a₁, mordell_a₂]
    field_simp
    linear_combination (-48 * x) * heq
  have hyy : (mordell N).toAffine.addY x x y ((mordell N).toAffine.slope x x y y)
      = y - (16 * y ^ 4 - 3 * x ^ 2 * (3 * x ^ 4 + 12 * N * x)) / (8 * y ^ 3) := by
    simp only [WeierstrassCurve.Affine.addY, WeierstrassCurve.Affine.negY,
      WeierstrassCurve.Affine.negAddY, mordell_a₁, mordell_a₃]
    rw [hx2, hs]
    field_simp
    ring
  have hXne : (mordell N).toAffine.addX x x ((mordell N).toAffine.slope x x y y) ≠ x := by
    rw [hx2]
    intro hc
    apply hpsi
    have hz : (3 * x ^ 4 + 12 * N * x) / (4 * y ^ 2) = 0 := by linarith [hc]
    field_simp at hz
    linear_combination hz
  rw [Point.add_self_of_Y_ne hne, Point.add_of_X_ne hXne]
  simp only [xCoord, Option.some.injEq]
  rw [slope_of_X_ne hXne, hx2, hyy]
  simp only [WeierstrassCurve.Affine.addX, mordell_a₁, mordell_a₂]
  rw [triple_slope_aux _ _ _ hy hpsi]
  linear_combination triple_final_aux N x y hy heq hpsi

/-! ## The arithmetic core at layer 3 -/

/-- The third division polynomial of `y² = x³ + N`. -/
def psi3 (N x : ℤ) : ℤ := 3 * x ^ 4 + 12 * N * x

/-- The numerator of `x(3P)`. -/
def phi3 (N x : ℤ) : ℤ := x ^ 9 - 96 * N * x ^ 6 + 48 * N ^ 2 * x ^ 3 + 64 * N ^ 3

/-- **Non-cancellation at layer 3.**  If `ℓ ≥ 5` is a prime with `ℓ ∤ N` dividing `ψ₃(x)`, then
`ℓ ∤ φ₃(x)`: on the locus `ℓ ∣ x` one has `φ₃ ≡ 64N³`, and on the locus `x³ ≡ -4N` one has
`φ₃ ≡ -1728N³`, and `ℓ` divides neither `64 = 2⁶`, nor `1728 = 2⁶·3³`, nor `N`. -/
theorem not_dvd_phi3_of_dvd_psi3 {N x : ℤ} {ℓ : ℕ} (hl : ℓ.Prime) (hl5 : 5 ≤ ℓ)
    (hlN : ¬(ℓ : ℤ) ∣ N) (hdvd : (ℓ : ℤ) ∣ psi3 N x) : ¬(ℓ : ℤ) ∣ phi3 N x := by
  haveI : Fact ℓ.Prime := ⟨hl⟩
  have hN : ((N : ZMod ℓ)) ≠ 0 := by rw [Ne, ZMod.intCast_zmod_eq_zero_iff_dvd]; exact hlN
  have h3 : ((3 : ZMod ℓ)) ≠ 0 := EllipticModCount.three_ne_zero_zmod (by omega)
  have h2 : ((2 : ZMod ℓ)) ≠ 0 := two_ne_zero_zmod hl5
  have hpsi0 : (3 : ZMod ℓ) * (x : ZMod ℓ) ^ 4 + 12 * (N : ZMod ℓ) * (x : ZMod ℓ) = 0 := by
    have := (ZMod.intCast_zmod_eq_zero_iff_dvd (psi3 N x) ℓ).mpr hdvd
    rw [psi3] at this
    push_cast at this
    linear_combination this
  have hfac : (3 : ZMod ℓ) * (x : ZMod ℓ) * ((x : ZMod ℓ) ^ 3 + 4 * (N : ZMod ℓ)) = 0 := by
    linear_combination hpsi0
  rw [Ne, ZMod.intCast_zmod_eq_zero_iff_dvd] at hN
  intro hphi
  have hphi0 : (x : ZMod ℓ) ^ 9 - 96 * (N : ZMod ℓ) * (x : ZMod ℓ) ^ 6
      + 48 * (N : ZMod ℓ) ^ 2 * (x : ZMod ℓ) ^ 3 + 64 * (N : ZMod ℓ) ^ 3 = 0 := by
    have := (ZMod.intCast_zmod_eq_zero_iff_dvd (phi3 N x) ℓ).mpr hphi
    rw [phi3] at this
    push_cast at this
    linear_combination this
  have hNz : ((N : ZMod ℓ)) ≠ 0 := by rw [Ne, ZMod.intCast_zmod_eq_zero_iff_dvd]; exact hN
  rcases mul_eq_zero.mp hfac with h | hcube
  · rcases mul_eq_zero.mp h with h3' | hx0
    · exact h3 h3'
    · -- `ℓ ∣ x`, so `φ₃ ≡ 64 N³`
      have h64 : (64 : ZMod ℓ) * (N : ZMod ℓ) ^ 3 = 0 := by
        rw [hx0] at hphi0
        linear_combination hphi0
      have h64ne : ((64 : ZMod ℓ)) ≠ 0 := by
        have : (64 : ZMod ℓ) = 2 ^ 6 := by norm_num
        rw [this]; exact pow_ne_zero _ h2
      rcases mul_eq_zero.mp h64 with h | h
      · exact h64ne h
      · exact hNz (pow_eq_zero_iff (by norm_num) |>.mp h)
  · -- `x³ ≡ -4N`, so `φ₃ ≡ -1728 N³`
    have hx3 : (x : ZMod ℓ) ^ 3 = -4 * (N : ZMod ℓ) := by linear_combination hcube
    have h1728 : (1728 : ZMod ℓ) * (N : ZMod ℓ) ^ 3 = 0 := by
      have h9 : (x : ZMod ℓ) ^ 9 = -64 * (N : ZMod ℓ) ^ 3 := by
        calc (x : ZMod ℓ) ^ 9 = ((x : ZMod ℓ) ^ 3) ^ 3 := by ring
          _ = (-4 * (N : ZMod ℓ)) ^ 3 := by rw [hx3]
          _ = -64 * (N : ZMod ℓ) ^ 3 := by ring
      have h6 : (x : ZMod ℓ) ^ 6 = 16 * (N : ZMod ℓ) ^ 2 := by
        calc (x : ZMod ℓ) ^ 6 = ((x : ZMod ℓ) ^ 3) ^ 2 := by ring
          _ = (-4 * (N : ZMod ℓ)) ^ 2 := by rw [hx3]
          _ = 16 * (N : ZMod ℓ) ^ 2 := by ring
      rw [h9, h6, hx3] at hphi0
      linear_combination -hphi0
    have h1728ne : ((1728 : ZMod ℓ)) ≠ 0 := by
      have h : (1728 : ZMod ℓ) = 2 ^ 6 * 3 ^ 3 := by norm_num
      rw [h]
      exact mul_ne_zero (pow_ne_zero _ h2) (pow_ne_zero _ h3)
    rcases mul_eq_zero.mp h1728 with h | h
    · exact h1728ne h
    · exact hNz (pow_eq_zero_iff (by norm_num) |>.mp h)

/-- **Denominator criterion at layer 3.**  For an integral point `(x, y)` of `E_N` and a good
prime `ℓ ≥ 5` (`ℓ ∤ N`) with `ψ₃(x) ≠ 0`, the prime `ℓ` divides the denominator of
`x(3P) = φ₃(x)/ψ₃(x)²` **iff** `ℓ ∣ ψ₃(x) = 3x(x³ + 4N)`. -/
theorem dvd_den_triple_iff {N x : ℤ} (hpsi : psi3 N x ≠ 0) {ℓ : ℕ} (hl : ℓ.Prime) (hl5 : 5 ≤ ℓ)
    (hlN : ¬(ℓ : ℤ) ∣ N) :
    ℓ ∣ (((phi3 N x : ℤ) : ℚ) / (((psi3 N x) ^ 2 : ℤ) : ℚ)).den ↔ (ℓ : ℤ) ∣ psi3 N x := by
  have hp : Prime (ℓ : ℤ) := Nat.prime_iff_prime_int.mp hl
  have hB : ((psi3 N x) ^ 2 : ℤ) ≠ 0 := pow_ne_zero _ hpsi
  constructor
  · intro h
    have h1 : (ℓ : ℤ) ∣ ((psi3 N x) ^ 2 : ℤ) :=
      dvd_trans (by exact_mod_cast h) (MordellDenominators.den_dvd_denom _ _)
    exact hp.dvd_of_dvd_pow h1
  · intro h
    exact MordellDenominators.prime_dvd_den hB hl (Dvd.dvd.pow h (by norm_num))
      (not_dvd_phi3_of_dvd_psi3 hl hl5 hlN h)

/-- **Layer-3 criterion for the actual group-law point `3P`.**  Combining the tripling formula
with the divisibility criterion: for an integral point `(x, y)` of `E_N` which is neither `2`-
nor `3`-torsion, and a good prime `ℓ ≥ 5`, the prime `ℓ` divides the denominator of the
`x`-coordinate of `3P` (computed in Mathlib's group law) iff `ℓ ∣ ψ₃(x)`. -/
theorem dvd_den_triple_point_iff {N x y : ℤ}
    (h : (mordell ((N : ℤ) : ℚ)).toAffine.Nonsingular ((x : ℚ)) ((y : ℚ))) (hy : y ≠ 0)
    (hpsi : psi3 N x ≠ 0) {ℓ : ℕ} (hl : ℓ.Prime) (hl5 : 5 ≤ ℓ) (hlN : ¬(ℓ : ℤ) ∣ N) :
    ∀ X : ℚ, xCoord (Point.some h + Point.some h + Point.some h) = some X →
      (ℓ ∣ X.den ↔ (ℓ : ℤ) ∣ psi3 N x) := by
  have hyQ : ((y : ℚ)) ≠ 0 := Int.cast_ne_zero.mpr hy
  have hpsiQ : 3 * ((x : ℚ)) ^ 4 + 12 * ((N : ℚ)) * ((x : ℚ)) ≠ 0 := by
    have : ((psi3 N x : ℤ) : ℚ) ≠ 0 := Int.cast_ne_zero.mpr hpsi
    rw [psi3] at this
    push_cast at this
    exact this
  intro X hX
  rw [mordell_triple_xCoord _ _ _ h hyQ hpsiQ] at hX
  have hXeq : X = ((phi3 N x : ℤ) : ℚ) / (((psi3 N x) ^ 2 : ℤ) : ℚ) := by
    have := (Option.some.injEq _ _).mp hX
    rw [← this, phi3, psi3]
    push_cast
    ring
  rw [hXeq]
  exact dvd_den_triple_iff hpsi hl hl5 hlN

/-! ## The layer-3 residue classes and their count -/

/-- The residue classes mod `ℓ` which force `ℓ` into the denominator of `x(3P)`: the roots of
the division polynomial `ψ₃`. -/
def vanishingClasses3 (N : ℤ) (ℓ : ℕ) [Fact ℓ.Prime] : Finset (ZMod ℓ) :=
  univ.filter fun t => 3 * t ^ 4 + 12 * (N : ZMod ℓ) * t = 0

lemma mem_vanishingClasses3_iff [Fact ℓ.Prime] {N : ℤ} {t : ZMod ℓ} :
    t ∈ vanishingClasses3 N ℓ ↔ 3 * t ^ 4 + 12 * (N : ZMod ℓ) * t = 0 := by
  simp [vanishingClasses3]

/-- The layer-3 locus is `{0} ∪ {roots of T³ + 4N}`. -/
lemma mem_vanishingClasses3_iff' [Fact ℓ.Prime] (hl5 : 5 ≤ ℓ) {N : ℤ} {t : ZMod ℓ} :
    t ∈ vanishingClasses3 N ℓ ↔ (t = 0 ∨ t ^ 3 + 4 * (N : ZMod ℓ) = 0) := by
  have h3 : ((3 : ZMod ℓ)) ≠ 0 := EllipticModCount.three_ne_zero_zmod (by omega)
  rw [mem_vanishingClasses3_iff]
  constructor
  · intro h
    have hfac : (3 : ZMod ℓ) * (t * (t ^ 3 + 4 * (N : ZMod ℓ))) = 0 := by linear_combination h
    rcases mul_eq_zero.mp hfac with h' | h'
    · exact absurd h' h3
    · exact mul_eq_zero.mp h'
  · rintro (rfl | h)
    · ring
    · linear_combination 3 * t * h

/-- **Layer 3 at a supersingular prime.**  For `ℓ ≥ 5`, `ℓ ≡ 2 (mod 3)` and `ℓ ∤ N` there are
exactly **two** denominator-producing classes at layer 3: `x ≡ 0` and the unique cube root of
`-4N`. -/
theorem card_vanishingClasses3_of_two_mod_three [Fact ℓ.Prime] (hl5 : 5 ≤ ℓ) (h3 : ℓ % 3 = 2)
    {N : ℤ} (hlN : ¬(ℓ : ℤ) ∣ N) : (vanishingClasses3 N ℓ).card = 2 := by
  have hN : ((N : ZMod ℓ)) ≠ 0 := by rw [Ne, ZMod.intCast_zmod_eq_zero_iff_dvd]; exact hlN
  have h4 : ((4 : ZMod ℓ) * (N : ZMod ℓ)) ≠ 0 := by
    have h2 : ((2 : ZMod ℓ)) ≠ 0 := two_ne_zero_zmod hl5
    refine mul_ne_zero ?_ hN
    have h : (4 : ZMod ℓ) = 2 ^ 2 := by norm_num
    rw [h]; exact pow_ne_zero _ h2
  obtain ⟨hinj, hsurj⟩ := EllipticModCount.cube_bijective_zmod (p := ℓ) h3
  obtain ⟨r, hr⟩ := hsurj (-(4 * (N : ZMod ℓ)))
  simp only at hr
  have hr0 : r ≠ 0 := by
    intro hc
    apply h4
    have hz : (0 : ZMod ℓ) ^ 3 = -(4 * (N : ZMod ℓ)) := by rw [← hc]; exact hr
    linear_combination hz
  have hset : vanishingClasses3 N ℓ = {0, r} := by
    ext u
    rw [mem_vanishingClasses3_iff' hl5]
    simp only [Finset.mem_insert, Finset.mem_singleton]
    constructor
    · rintro (rfl | h)
      · exact Or.inl rfl
      · refine Or.inr (hinj ?_)
        simp only
        rw [hr]
        linear_combination h
    · rintro (rfl | rfl)
      · exact Or.inl rfl
      · exact Or.inr (by rw [hr]; ring)
  rw [hset, Finset.card_insert_of_notMem (by simp [Ne.symm hr0]), Finset.card_singleton]

/-- **Layer 3 at an ordinary prime.**  For `ℓ ≥ 5`, `ℓ ≡ 1 (mod 3)` and `ℓ ∤ N` the layer-3
count is `1` or `4`: the class `x ≡ 0` together with the `0` or `3` cube roots of `-4N`. -/
theorem card_vanishingClasses3_of_one_mod_three [Fact ℓ.Prime] (hl5 : 5 ≤ ℓ) (h3 : ℓ % 3 = 1)
    {N : ℤ} (hlN : ¬(ℓ : ℤ) ∣ N) :
    (vanishingClasses3 N ℓ).card = 1 ∨ (vanishingClasses3 N ℓ).card = 4 := by
  have hl4N : ¬(ℓ : ℤ) ∣ (4 * N) := by
    intro h
    have hp : Prime (ℓ : ℤ) := Nat.prime_iff_prime_int.mp Fact.out
    rcases hp.dvd_mul.mp h with h' | h'
    · have := Int.le_of_dvd (by norm_num) h'
      omega
    · exact hlN h'
  have hsplit : vanishingClasses3 N ℓ
      = insert (0 : ZMod ℓ) (vanishingClasses (4 * N) ℓ) := by
    ext u
    rw [mem_vanishingClasses3_iff' hl5, Finset.mem_insert, mem_vanishingClasses_iff]
    push_cast
    constructor
    · rintro (rfl | h)
      · exact Or.inl rfl
      · exact Or.inr (by linear_combination h)
    · rintro (rfl | h)
      · exact Or.inl rfl
      · exact Or.inr (by linear_combination h)
  have h0 : (0 : ZMod ℓ) ∉ vanishingClasses (4 * N) ℓ := by
    rw [mem_vanishingClasses_iff]
    push_cast
    intro hc
    have hN : ((N : ZMod ℓ)) ≠ 0 := by rw [Ne, ZMod.intCast_zmod_eq_zero_iff_dvd]; exact hlN
    have h2 : ((2 : ZMod ℓ)) ≠ 0 := two_ne_zero_zmod hl5
    have h4 : ((4 : ZMod ℓ)) ≠ 0 := by
      have h : (4 : ZMod ℓ) = 2 ^ 2 := by norm_num
      rw [h]; exact pow_ne_zero _ h2
    rcases mul_eq_zero.mp (by linear_combination hc : (4 : ZMod ℓ) * (N : ZMod ℓ) = 0) with h | h
    · exact h4 h
    · exact hN h
  rw [hsplit, Finset.card_insert_of_notMem h0]
  rcases card_vanishingClasses_of_one_mod_three hl5 h3 hl4N with h | h <;> rw [h]
  · exact Or.inl rfl
  · exact Or.inr rfl

/-- **The two layers are disjoint and together contribute exactly three classes.**  At a
supersingular prime `ℓ ≥ 5` with `ℓ ∤ N`, layer 2 contributes the cube root of `-N`, layer 3
contributes `0` and the cube root of `-4N`, and these three classes are pairwise distinct. -/
theorem card_layer2_union_layer3 [Fact ℓ.Prime] (hl5 : 5 ≤ ℓ) (h3 : ℓ % 3 = 2) {N : ℤ}
    (hlN : ¬(ℓ : ℤ) ∣ N) :
    (vanishingClasses N ℓ ∪ vanishingClasses3 N ℓ).card = 3 := by
  have hN : ((N : ZMod ℓ)) ≠ 0 := by rw [Ne, ZMod.intCast_zmod_eq_zero_iff_dvd]; exact hlN
  have h3ne : ((3 : ZMod ℓ)) ≠ 0 := EllipticModCount.three_ne_zero_zmod (by omega)
  have hdisj : Disjoint (vanishingClasses N ℓ) (vanishingClasses3 N ℓ) := by
    rw [Finset.disjoint_left]
    intro u hu hu3
    rw [mem_vanishingClasses_iff] at hu
    rw [mem_vanishingClasses3_iff' hl5] at hu3
    rcases hu3 with rfl | h
    · simp at hu
      exact hN hu
    · -- `u³ = -N` and `u³ = -4N` force `3N = 0`
      have : (3 : ZMod ℓ) * (N : ZMod ℓ) = 0 := by linear_combination h - hu
      rcases mul_eq_zero.mp this with h' | h'
      · exact h3ne h'
      · exact hN h'
  rw [Finset.card_union_of_disjoint hdisj, card_vanishingClasses_of_two_mod_three h3 N,
    card_vanishingClasses3_of_two_mod_three hl5 h3 hlN]

/-! ## Realisation of every prime at layer 3 -/

/-- **Every prime `ℓ ≥ 5` occurs at layer 3 as a good-reduction denominator prime.**  Witness:
`N = 1 - ℓ³`, `P = (ℓ, 1)`, which lies on `E_N` and has `ψ₃(ℓ) = 3ℓ(ℓ³ + 4N) ≡ 0 (mod ℓ)`
while `ℓ ∤ N` (indeed `N ≡ 1 mod ℓ`), so `ℓ ∤ Δ = -432N²`. -/
theorem good_prime_realised_layer3 {ℓ : ℕ} (hl : ℓ.Prime) (hl5 : 5 ≤ ℓ) :
    ∃ N x y : ℤ, y ^ 2 = x ^ 3 + N ∧ y ≠ 0 ∧ psi3 N x ≠ 0 ∧
      ¬(ℓ : ℤ) ∣ (mordell N).Δ ∧
      ℓ ∣ (((phi3 N x : ℤ) : ℚ) / (((psi3 N x) ^ 2 : ℤ) : ℚ)).den := by
  have hl0 : (5 : ℤ) ≤ (ℓ : ℤ) := by exact_mod_cast hl5
  refine ⟨1 - (ℓ : ℤ) ^ 3, (ℓ : ℤ), 1, by ring, one_ne_zero, ?_, ?_, ?_⟩
  · rw [psi3]
    have hneg : 3 * (ℓ : ℤ) ^ 4 + 12 * (1 - (ℓ : ℤ) ^ 3) * (ℓ : ℤ) < 0 := by
      nlinarith [hl0, sq_nonneg ((ℓ : ℤ) - 5), sq_nonneg ((ℓ : ℤ)),
        sq_nonneg ((ℓ : ℤ) * (ℓ : ℤ) - 25)]
    exact ne_of_lt hneg
  · refine MordellDenominators.not_dvd_Δ hl hl5 ?_
    intro h
    have h1 : (ℓ : ℤ) ∣ 1 := by
      have h3 : (ℓ : ℤ) ∣ (ℓ : ℤ) ^ 3 := dvd_pow_self _ (by norm_num)
      simpa using dvd_add h h3
    have := Int.le_of_dvd (by norm_num) h1
    omega
  · refine (dvd_den_triple_iff ?_ hl hl5 ?_).mpr ?_
    · rw [psi3]
      have hneg : 3 * (ℓ : ℤ) ^ 4 + 12 * (1 - (ℓ : ℤ) ^ 3) * (ℓ : ℤ) < 0 := by
        nlinarith [hl0, sq_nonneg ((ℓ : ℤ) - 5), sq_nonneg ((ℓ : ℤ)),
          sq_nonneg ((ℓ : ℤ) * (ℓ : ℤ) - 25)]
      exact ne_of_lt hneg
    · intro h
      have h1 : (ℓ : ℤ) ∣ 1 := by
        have h3 : (ℓ : ℤ) ∣ (ℓ : ℤ) ^ 3 := dvd_pow_self _ (by norm_num)
        simpa using dvd_add h h3
      have := Int.le_of_dvd (by norm_num) h1
      omega
    · rw [psi3]
      exact ⟨3 * (ℓ : ℤ) ^ 3 + 12 * (1 - (ℓ : ℤ) ^ 3), by ring⟩

/-! ## Synthesis: the good denominator primes of the first two nontrivial layers -/

/-- **Complete description of the good denominator primes at layers 2 and 3.**  For an integral
point `(x, y)` of `E_N` which is neither `2`- nor `3`-torsion, a prime `ℓ ≥ 5` with `ℓ ∤ N`
divides the denominator of `x(2P)` or of `x(3P)` if and only if `ℓ ∣ y · ψ₃(x)`.  So the good
violating primes of the first two layers are exactly the prime divisors `≥ 5` of the single
integer `y · (3x⁴ + 12Nx)` that do not divide `N`. -/
theorem dvd_den_layers_two_three_iff {N x y : ℤ} (heq : y ^ 2 = x ^ 3 + N) (hy : y ≠ 0)
    (hpsi : psi3 N x ≠ 0) {ℓ : ℕ} (hl : ℓ.Prime) (hl5 : 5 ≤ ℓ) (hlN : ¬(ℓ : ℤ) ∣ N) :
    (ℓ ∣ (((x : ℚ) ^ 4 - 8 * (N : ℚ) * (x : ℚ)) / (4 * (y : ℚ) ^ 2)).den ∨
        ℓ ∣ (((phi3 N x : ℤ) : ℚ) / (((psi3 N x) ^ 2 : ℤ) : ℚ)).den) ↔
      (ℓ : ℤ) ∣ y * psi3 N x := by
  have hp : Prime (ℓ : ℤ) := Nat.prime_iff_prime_int.mp hl
  rw [MordellDenominators.dvd_den_double_iff heq hy hl hl5 hlN,
    dvd_den_triple_iff hpsi hl hl5 hlN]
  exact (hp.dvd_mul).symm

/-! ## Recovering the numeric `N = 55` data from the general theory -/

/-- `ψ₃(9) = 25623 = 3³ · 13 · 73` for `N = 55`. -/
theorem psi3_55_9 : psi3 55 9 = 3 ^ 3 * 13 * 73 := by rw [psi3]; norm_num

/-- **The general layer-3 criterion recovers the catalog's numeric orbit data.**  For `N = 55`
and `P = (9, 28)`, the primes `13` and `73` divide `ψ₃(9) = 25623`, hence divide the
denominator of `x(3P)`, while `5` and `11` — the prime factors of `N` — do not divide it.
Both `13` and `73` are primes of good reduction. -/
theorem triple_55_recovers_13_and_73 :
    13 ∣ (((phi3 55 9 : ℤ) : ℚ) / (((psi3 55 9) ^ 2 : ℤ) : ℚ)).den ∧
      73 ∣ (((phi3 55 9 : ℤ) : ℚ) / (((psi3 55 9) ^ 2 : ℤ) : ℚ)).den ∧
      ¬ 5 ∣ (((phi3 55 9 : ℤ) : ℚ) / (((psi3 55 9) ^ 2 : ℤ) : ℚ)).den ∧
      ¬ 11 ∣ (((phi3 55 9 : ℤ) : ℚ) / (((psi3 55 9) ^ 2 : ℤ) : ℚ)).den ∧
      ¬(13 : ℤ) ∣ (mordell (55 : ℤ)).Δ ∧ ¬(73 : ℤ) ∣ (mordell (55 : ℤ)).Δ := by
  have hpsi : psi3 55 9 ≠ 0 := by rw [psi3]; norm_num
  have den_triple_55_eq : (((phi3 55 9 : ℤ) : ℚ) / (((psi3 55 9) ^ 2 : ℤ) : ℚ)).den
      = 3 ^ 6 * 13 ^ 2 * 73 ^ 2 := by rw [phi3, psi3]; norm_num
  refine ⟨?_, ?_, ?_, ?_, ?_, ?_⟩
  · exact (dvd_den_triple_iff hpsi (by norm_num) (by norm_num) (by norm_num)).mpr
      (by rw [psi3]; norm_num)
  · exact (dvd_den_triple_iff hpsi (by norm_num) (by norm_num) (by norm_num)).mpr
      (by rw [psi3]; norm_num)
  · rw [den_triple_55_eq]; norm_num
  · rw [den_triple_55_eq]; norm_num
  · exact MordellDenominators.not_dvd_Δ (ℓ := 13) (by norm_num) (by norm_num) (by norm_num)
  · exact MordellDenominators.not_dvd_Δ (ℓ := 73) (by norm_num) (by norm_num) (by norm_num)

end MordellPointCount