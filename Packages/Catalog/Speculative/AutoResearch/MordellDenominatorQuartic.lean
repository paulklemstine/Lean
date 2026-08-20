import Mathlib
import Combinatorics.MordellDenominatorTripling

/-!
# Layer 4: quadrupling, the division polynomial `ψ₄`, and the constants `2⁶3²`, `3⁸`

This file is the layer-4 instalment of the tower begun in
`Combinatorics.MordellDenominatorPointCount` (doubling, `ψ₂ = 2y`, criterion `ℓ ∣ x³ + N`) and
`Combinatorics.MordellDenominatorTripling` (tripling, `ψ₃ = 3x⁴ + 12Nx`).

For `E_N : y² = x³ + N` the fourth division polynomial is
`ψ₄ = 4y (x⁶ + 20Nx³ - 8N²)`, so — using `y² = x³ + N` — its square is
`ψ₄² = 16 (x³ + N) S(x)²`,  `S(x) := x⁶ + 20Nx³ - 8N²`,
and its vanishing locus in `x` is cut out by the degree-`9` polynomial
`Ψ₄(x) := (x³ + N) · S(x)`.

## Main results

* `quartic_key_identity` : the algebraic heart of the layer,
  `(x⁴ - 8Nx)³ + 64N(x³ + N)³ = (x⁶ + 20Nx³ - 8N²)²`.
  It says that the *cubic* `X³ + N` evaluated at the doubling image `X = x(2P)` is a perfect
  square, and it is what makes the fourth division polynomial factor through `S`.
* `mordell_quadruple_xCoord` : **derived from Mathlib's affine group law** (the doubling formula
  applied twice), `x(4P) = φ₄(x)/ψ₄(x)²` with
  `φ₄(x) = (x⁴ - 8Nx)((x⁴ - 8Nx)³ - 512N(x³ + N)³)` and `ψ₄² = 16(x³+N)S(x)²`.
* `not_dvd_phi4_of_dvd_Psi4` : the non-cancellation lemma at layer 4.  On the locus `x³ + N ≡ 0`
  one has `φ₄ ≡ -3⁸ N⁵ x`, and on the locus `S ≡ 0` one has `φ₄ ≡ -2⁶3² N (x³+N)³`; the
  exceptional constants are `3⁸` and `576 = 2⁶3²`, composed of the primes `2` and `3` **only**.
  This *confirms at layer 4* the second half of conjecture C1 of the previous cycle.
* `dvd_den_quadruple_iff`, `dvd_den_quadruple_point_iff` : hence, for good `ℓ ≥ 5`,
  `ℓ ∣ den x(4P) ↔ ℓ ∣ (x³ + N)(x⁶ + 20Nx³ - 8N²)`, the layer-4 analogue of
  `dvd_den_double_iff` and `dvd_den_triple_iff`.
* `quartic_classes_55` : the general criterion, specialised to the catalog's running example
  `N = 55`, `P = (9, 28)`, recovers `7 · 827 · 1583 ∣ den x(4P)` — three good primes at once.

-- !-- Lab Notes -- !--
Hypothesizer: conjecture C1 of the previous cycle predicts that at every layer `n` the
  numerator `φ_n` evaluated on the locus `ψ_n = 0` is `c_n N^k` with `c_n` composed of `2` and
  `3` only.  Layer 4 is the first case where `ψ_n` has an irreducible factor which is *not* of
  the Kummer shape `T³ + cN`, so it is the first genuine test.
Experimenter: the prediction is confirmed: the two exceptional evaluations are `-3⁸N⁵x`
  (on `x³ ≡ -N`) and `-2⁶3²N(x³+N)³` (on `S ≡ 0`), and the criterion
  `ℓ ∣ den x(4P) ↔ ℓ ∣ (x³+N)S(x)` holds for every prime `ℓ ≥ 5` with `ℓ ∤ N`.
Analyst: the mechanism is the identity `A³ + 64N B̃³ = S²` (`quartic_key_identity`) with
  `A = x⁴ - 8Nx`, `B̃ = x³ + N`: the layer-4 locus is the union of the layer-2 locus `B̃ = 0`
  and of the *new* locus `S = 0`, and the two meet only where `27N² = 0`.  Note `27 = 3³`
  again — the discriminant constant of the Mordell family, exactly as at layer 3.
Critic: the hypothesis `S(x) ≠ 0` is genuine (it says `2P` is not `2`-torsion, i.e. `P` is not
  `4`-torsion), and `y ≠ 0` is needed for `2P` to be affine.  `ℓ ≥ 5` is needed because both
  exceptional constants are `{2,3}`-units, and `ℓ ∤ N` because `N` itself occurs in them.
  No `sorry` below.
-/

namespace MordellQuartic

open MordellDenominators MordellPointCount WeierstrassCurve WeierstrassCurve.Affine

/-! ## The layer-4 polynomials -/

/-- The sextic factor `S(x) = x⁶ + 20Nx³ - 8N²` of the fourth division polynomial
`ψ₄ = 4y·S(x)` of `y² = x³ + N`. -/
def sextic (N x : ℤ) : ℤ := x ^ 6 + 20 * N * x ^ 3 - 8 * N ^ 2

/-- The `x`-locus of the fourth division polynomial: `Ψ₄ = (x³ + N)·S(x)`, the radical of
`ψ₄² = 16(x³+N)S(x)²`. -/
def Psi4 (N x : ℤ) : ℤ := (x ^ 3 + N) * sextic N x

/-- The numerator of `x(4P)`. -/
def phi4 (N x : ℤ) : ℤ :=
  (x ^ 4 - 8 * N * x) * ((x ^ 4 - 8 * N * x) ^ 3 - 512 * N * (x ^ 3 + N) ^ 3)

/-- The denominator of `x(4P)`, i.e. `ψ₄²` after the substitution `y² = x³ + N`. -/
def den4 (N x : ℤ) : ℤ := 16 * (x ^ 3 + N) * (sextic N x) ^ 2

/-- **The key identity of layer 4.**  Over any commutative ring,
`(x⁴ - 8Nx)³ + 64N(x³ + N)³ = (x⁶ + 20Nx³ - 8N²)²`.

Equivalently: if `X = (x⁴ - 8Nx)/(4(x³+N))` is the `x`-coordinate of `2P`, then
`X³ + N = S(x)²/(64(x³+N)³)` is a square times the cube of the layer-2 denominator.  This is
why the fourth division polynomial of a Mordell curve factors as `ψ₄ = 4y·S(x)`. -/
theorem quartic_key_identity {R : Type*} [CommRing R] (N x : R) :
    (x ^ 4 - 8 * N * x) ^ 3 + 64 * N * (x ^ 3 + N) ^ 3
      = (x ^ 6 + 20 * N * x ^ 3 - 8 * N ^ 2) ^ 2 := by
  ring

/-! ## The quadrupling formula, derived from Mathlib's group law -/

/-- **Quadrupling formula.**  For a nonsingular rational point `P = (x, y)` of
`E_N : y² = x³ + N` with `y ≠ 0` (so `P` is not `2`-torsion) and `S(x) ≠ 0` (so `2P` is not
`2`-torsion, i.e. `P` is not `4`-torsion), Mathlib's affine group law gives
`x(4P) = (x⁴ - 8Nx)((x⁴ - 8Nx)³ - 512N(x³+N)³) / (16(x³+N)(x⁶ + 20Nx³ - 8N²)²)`. -/
theorem mordell_quadruple_xCoord (N x y : ℚ) (h : (mordell N).toAffine.Nonsingular x y)
    (hy : y ≠ 0) (hS : x ^ 6 + 20 * N * x ^ 3 - 8 * N ^ 2 ≠ 0) :
    xCoord ((Point.some h + Point.some h) + (Point.some h + Point.some h))
      = some (((x ^ 4 - 8 * N * x) * ((x ^ 4 - 8 * N * x) ^ 3 - 512 * N * (x ^ 3 + N) ^ 3))
          / (16 * (x ^ 3 + N) * (x ^ 6 + 20 * N * x ^ 3 - 8 * N ^ 2) ^ 2)) := by
  have heq : y ^ 2 = x ^ 3 + N := (mordell_equation_iff N x y).1 h.1
  have hne : y ≠ (mordell N).toAffine.negY x y := by
    simp only [WeierstrassCurve.Affine.negY, mordell_a₁, mordell_a₃, ne_eq]
    intro hc; exact hy (by linarith)
  have hxN : x ^ 3 + N ≠ 0 := by rw [← heq]; exact pow_ne_zero _ hy
  obtain ⟨X2, Y2, h₂, hEq⟩ : ∃ X2 : ℚ, ∃ Y2 : ℚ,
      ∃ h₂ : (mordell N).toAffine.Nonsingular X2 Y2,
      Point.some h + Point.some h = Point.some h₂ :=
    ⟨_, _, _, Point.add_self_of_Y_ne hne⟩
  have hX2 : X2 = (x ^ 4 - 8 * N * x) / (4 * (x ^ 3 + N)) := by
    have h3 := mordell_double_xCoord N x y h hy
    rw [hEq] at h3
    rw [heq] at h3
    simpa [xCoord] using h3
  have hY2sq : Y2 ^ 2 = X2 ^ 3 + N := (mordell_equation_iff N X2 Y2).1 h₂.1
  have hX2N : X2 ^ 3 + N
      = (x ^ 6 + 20 * N * x ^ 3 - 8 * N ^ 2) ^ 2 / (64 * (x ^ 3 + N) ^ 3) := by
    rw [hX2]
    field_simp
    ring
  have hX2Nne : X2 ^ 3 + N ≠ 0 := by
    rw [hX2N]
    exact div_ne_zero (pow_ne_zero _ hS) (by simp [hxN])
  have hY2 : Y2 ≠ 0 := fun hc => hX2Nne (by rw [← hY2sq, hc]; ring)
  rw [hEq, mordell_double_xCoord N X2 Y2 h₂ hY2, hY2sq]
  congr 1
  rw [hX2N, hX2]
  have h64 : (64 : ℚ) * (x ^ 3 + N) ^ 3 ≠ 0 := by simp [hxN]
  field_simp
  ring

/-! ## The arithmetic core at layer 4 -/

/-- A prime `ℓ ≥ 5` is invertible against the exceptional constant `3⁸ = 6561`. -/
lemma pow_three_eight_ne_zero_zmod {ℓ : ℕ} [Fact ℓ.Prime] (hl5 : 5 ≤ ℓ) :
    (6561 : ZMod ℓ) ≠ 0 := by
  have h3 : ((3 : ZMod ℓ)) ≠ 0 := EllipticModCount.three_ne_zero_zmod (by omega)
  have h : (6561 : ZMod ℓ) = 3 ^ 8 := by norm_num
  rw [h]; exact pow_ne_zero _ h3

/-- A prime `ℓ ≥ 5` is invertible against the exceptional constant `576 = 2⁶3²`. -/
lemma five_seventy_six_ne_zero_zmod {ℓ : ℕ} [Fact ℓ.Prime] (hl5 : 5 ≤ ℓ) :
    (576 : ZMod ℓ) ≠ 0 := by
  have h3 : ((3 : ZMod ℓ)) ≠ 0 := EllipticModCount.three_ne_zero_zmod (by omega)
  have h2 : ((2 : ZMod ℓ)) ≠ 0 := MordellPointCount.two_ne_zero_zmod hl5
  have h : (576 : ZMod ℓ) = 2 ^ 6 * 3 ^ 2 := by norm_num
  rw [h]; exact mul_ne_zero (pow_ne_zero _ h2) (pow_ne_zero _ h3)

/-- **Non-cancellation at layer 4** — the layer-4 instance of conjecture C1.

If `ℓ ≥ 5` is a prime with `ℓ ∤ N` dividing `Ψ₄(x) = (x³ + N)·S(x)`, then `ℓ ∤ φ₄(x)`.  The two
exceptional evaluations of the numerator on the vanishing locus of the division polynomial are
* `φ₄ ≡ 3⁸ N⁴ x⁴ = -3⁸ N⁵ x` on the branch `x³ ≡ -N`, and
* `φ₄ ≡ -2⁶3² N (x⁴ - 8Nx)(x³ + N)³` on the branch `S(x) ≡ 0`,

so the exceptional constants `3⁸` and `576 = 2⁶3²` are composed of the primes `2` and `3`
only — exactly as predicted for every layer of the tower. -/
theorem not_dvd_phi4_of_dvd_Psi4 {N x : ℤ} {ℓ : ℕ} (hl : ℓ.Prime) (hl5 : 5 ≤ ℓ)
    (hlN : ¬(ℓ : ℤ) ∣ N) (hdvd : (ℓ : ℤ) ∣ Psi4 N x) : ¬(ℓ : ℤ) ∣ phi4 N x := by
  haveI : Fact ℓ.Prime := ⟨hl⟩
  set X : ZMod ℓ := (x : ZMod ℓ) with hX
  set M : ZMod ℓ := (N : ZMod ℓ) with hM
  have hMne : M ≠ 0 := by rw [hM, Ne, ZMod.intCast_zmod_eq_zero_iff_dvd]; exact hlN
  have hPsi : (X ^ 3 + M) * (X ^ 6 + 20 * M * X ^ 3 - 8 * M ^ 2) = 0 := by
    have := (ZMod.intCast_zmod_eq_zero_iff_dvd (Psi4 N x) ℓ).mpr hdvd
    rw [Psi4, sextic] at this
    push_cast at this
    linear_combination this
  intro hphi
  have hphi0 :
      (X ^ 4 - 8 * M * X) * ((X ^ 4 - 8 * M * X) ^ 3 - 512 * M * (X ^ 3 + M) ^ 3) = 0 := by
    have := (ZMod.intCast_zmod_eq_zero_iff_dvd (phi4 N x) ℓ).mpr hphi
    rw [phi4] at this
    push_cast at this
    linear_combination this
  rcases mul_eq_zero.mp hPsi with hb | hs
  · -- branch `x³ ≡ -N`: `φ₄ ≡ 3⁸ N⁴ x⁴`
    have hx3 : X ^ 3 = -M := by linear_combination hb
    have hxne : X ≠ 0 := by
      intro hc
      apply hMne
      have h0 : (0 : ZMod ℓ) ^ 3 = -M := by rw [← hc]; exact hx3
      linear_combination h0
    have hA : X ^ 4 - 8 * M * X = -9 * M * X := by
      have hx4 : X ^ 4 = X * X ^ 3 := by ring
      rw [hx4, hx3]; ring
    have hval : (6561 : ZMod ℓ) * M ^ 4 * X ^ 4 = 0 := by
      rw [hA, hb] at hphi0
      linear_combination hphi0
    rcases mul_eq_zero.mp hval with h | h
    · rcases mul_eq_zero.mp h with h' | h'
      · exact pow_three_eight_ne_zero_zmod hl5 h'
      · exact hMne (pow_eq_zero_iff (by norm_num) |>.mp h')
    · exact hxne (pow_eq_zero_iff (by norm_num) |>.mp h)
  · -- branch `S ≡ 0`: `φ₄ ≡ -2⁶3² N (x⁴ - 8Nx)(x³ + N)³`
    have hcube : (X ^ 4 - 8 * M * X) ^ 3 = -64 * M * (X ^ 3 + M) ^ 3 := by
      have hid : (X ^ 4 - 8 * M * X) ^ 3 + 64 * M * (X ^ 3 + M) ^ 3
          = (X ^ 6 + 20 * M * X ^ 3 - 8 * M ^ 2) ^ 2 := by ring
      have hz : (X ^ 4 - 8 * M * X) ^ 3 + 64 * M * (X ^ 3 + M) ^ 3 = 0 := by
        rw [hid, hs]; ring
      linear_combination hz
    have hbne : X ^ 3 + M ≠ 0 := by
      intro hc
      apply hMne
      have h27 : (27 : ZMod ℓ) * M ^ 2 = 0 := by
        have hx3 : X ^ 3 = -M := by linear_combination hc
        have h6 : X ^ 6 = M ^ 2 := by
          calc X ^ 6 = (X ^ 3) ^ 2 := by ring
            _ = (-M) ^ 2 := by rw [hx3]
            _ = M ^ 2 := by ring
        rw [h6, hx3] at hs
        linear_combination -hs
      have h27ne : ((27 : ZMod ℓ)) ≠ 0 := by
        have h3 : ((3 : ZMod ℓ)) ≠ 0 := EllipticModCount.three_ne_zero_zmod (by omega)
        have h : (27 : ZMod ℓ) = 3 ^ 3 := by norm_num
        rw [h]; exact pow_ne_zero _ h3
      rcases mul_eq_zero.mp h27 with h | h
      · exact absurd h h27ne
      · exact pow_eq_zero_iff (by norm_num) |>.mp h
    have hAne : X ^ 4 - 8 * M * X ≠ 0 := by
      intro hc
      have hz : (64 : ZMod ℓ) * M * (X ^ 3 + M) ^ 3 = 0 := by
        rw [hc] at hcube
        linear_combination hcube
      have h64ne : ((64 : ZMod ℓ)) ≠ 0 := by
        have h2 : ((2 : ZMod ℓ)) ≠ 0 := MordellPointCount.two_ne_zero_zmod hl5
        have h : (64 : ZMod ℓ) = 2 ^ 6 := by norm_num
        rw [h]; exact pow_ne_zero _ h2
      rcases mul_eq_zero.mp hz with h | h
      · rcases mul_eq_zero.mp h with h' | h'
        · exact h64ne h'
        · exact hMne h'
      · exact hbne (pow_eq_zero_iff (by norm_num) |>.mp h)
    have hval : (576 : ZMod ℓ) * M * (X ^ 4 - 8 * M * X) * (X ^ 3 + M) ^ 3 = 0 := by
      rw [hcube] at hphi0
      linear_combination -hphi0
    rcases mul_eq_zero.mp hval with h | h
    · rcases mul_eq_zero.mp h with h' | h'
      · rcases mul_eq_zero.mp h' with h'' | h''
        · exact five_seventy_six_ne_zero_zmod hl5 h''
        · exact hMne h''
      · exact hAne h'
    · exact hbne (pow_eq_zero_iff (by norm_num) |>.mp h)

/-- **Denominator criterion at layer 4.**  For an integral point `(x, y)` of `E_N` with
`y ≠ 0` and `S(x) ≠ 0`, and a good prime `ℓ ≥ 5` (`ℓ ∤ N`), the prime `ℓ` divides the
denominator of `x(4P) = φ₄(x)/ψ₄(x)²` **iff** `ℓ ∣ Ψ₄(x) = (x³ + N)(x⁶ + 20Nx³ - 8N²)`. -/
theorem dvd_den_quadruple_iff {N x : ℤ} (hb : x ^ 3 + N ≠ 0) (hS : sextic N x ≠ 0) {ℓ : ℕ}
    (hl : ℓ.Prime) (hl5 : 5 ≤ ℓ) (hlN : ¬(ℓ : ℤ) ∣ N) :
    ℓ ∣ (((phi4 N x : ℤ) : ℚ) / ((den4 N x : ℤ) : ℚ)).den ↔ (ℓ : ℤ) ∣ Psi4 N x := by
  have hp : Prime (ℓ : ℤ) := Nat.prime_iff_prime_int.mp hl
  have hden : den4 N x ≠ 0 := by
    rw [den4]
    exact mul_ne_zero (mul_ne_zero (by norm_num) hb) (pow_ne_zero _ hS)
  have h16 : ¬(ℓ : ℤ) ∣ 16 := by
    intro hdvd
    have h2 : (ℓ : ℤ) ∣ (2 : ℤ) ^ 4 := by norm_num at hdvd ⊢; exact hdvd
    have := Int.le_of_dvd (by norm_num) (hp.dvd_of_dvd_pow h2)
    omega
  constructor
  · intro h
    have h1 : (ℓ : ℤ) ∣ den4 N x :=
      dvd_trans (by exact_mod_cast h) (MordellDenominators.den_dvd_denom _ _)
    rw [den4] at h1
    rw [Psi4]
    rcases hp.dvd_mul.mp h1 with h2 | h2
    · rcases hp.dvd_mul.mp h2 with h3 | h3
      · exact absurd h3 h16
      · exact Dvd.dvd.mul_right h3 _
    · exact Dvd.dvd.mul_left (hp.dvd_of_dvd_pow h2) _
  · intro h
    refine MordellDenominators.prime_dvd_den hden hl ?_
      (not_dvd_phi4_of_dvd_Psi4 hl hl5 hlN h)
    rw [Psi4] at h
    rw [den4]
    rcases hp.dvd_mul.mp h with h1 | h1
    · exact Dvd.dvd.mul_right (Dvd.dvd.mul_left h1 _) _
    · exact Dvd.dvd.mul_left (h1.pow (by norm_num)) _

/-- **Layer-4 criterion for the actual group-law point `4P`.**  For an integral point `(x, y)`
of `E_N` which is neither `2`- nor `4`-torsion, and a good prime `ℓ ≥ 5`, the prime `ℓ` divides
the denominator of the `x`-coordinate of `4P` (computed with Mathlib's group law) iff
`ℓ ∣ (x³ + N)(x⁶ + 20Nx³ - 8N²)`. -/
theorem dvd_den_quadruple_point_iff {N x y : ℤ}
    (h : (mordell ((N : ℤ) : ℚ)).toAffine.Nonsingular ((x : ℚ)) ((y : ℚ))) (hy : y ≠ 0)
    (hS : sextic N x ≠ 0) {ℓ : ℕ} (hl : ℓ.Prime) (hl5 : 5 ≤ ℓ) (hlN : ¬(ℓ : ℤ) ∣ N) :
    ∀ X : ℚ, xCoord ((Point.some h + Point.some h) + (Point.some h + Point.some h)) = some X →
      (ℓ ∣ X.den ↔ (ℓ : ℤ) ∣ Psi4 N x) := by
  have heq : (y : ℚ) ^ 2 = (x : ℚ) ^ 3 + (N : ℚ) := (mordell_equation_iff _ _ _).1 h.1
  have hyQ : ((y : ℚ)) ≠ 0 := Int.cast_ne_zero.mpr hy
  have hb : x ^ 3 + N ≠ 0 := by
    intro hc
    apply hyQ
    have hzero : ((x : ℚ)) ^ 3 + (N : ℚ) = 0 := by
      exact_mod_cast congrArg (fun t : ℤ => (t : ℚ)) hc
    rw [hzero] at heq
    exact pow_eq_zero_iff two_ne_zero |>.mp heq
  have hSQ : ((x : ℚ)) ^ 6 + 20 * (N : ℚ) * ((x : ℚ)) ^ 3 - 8 * (N : ℚ) ^ 2 ≠ 0 := by
    have hne : ((sextic N x : ℤ) : ℚ) ≠ 0 := Int.cast_ne_zero.mpr hS
    rw [sextic] at hne
    push_cast at hne
    exact hne
  intro X hX
  rw [mordell_quadruple_xCoord _ _ _ h hyQ hSQ] at hX
  have hXeq : X = ((phi4 N x : ℤ) : ℚ) / ((den4 N x : ℤ) : ℚ) := by
    have hval := (Option.some.injEq _ _).mp hX
    rw [← hval, phi4, den4, sextic]
    push_cast
    ring
  rw [hXeq]
  exact dvd_den_quadruple_iff hb hS hl hl5 hlN

/-! ## The running example `N = 55`, `P = (9, 28)` -/

/-- `Ψ₄(9) = 2⁴ · 7² · 827 · 1583` for `N = 55`. -/
lemma Psi4_55_9 : Psi4 55 9 = 2 ^ 4 * 7 ^ 2 * 827 * 1583 := by
  rw [Psi4, sextic]; norm_num

/-- **Three new good denominator primes at layer 4.**  For the catalog's running example
`N = 55 = 5 · 11`, `P = (9, 28)`, the primes `7`, `827` and `1583` — none of which divides the
discriminant `-432 · 55²` — all divide the denominator of `x(4P)`.  (At layer 2 only `7`
occurs, and at layer 3 only `13` and `73`.) -/
theorem quartic_denominator_primes_55 :
    ∀ ℓ : ℕ, ℓ = 7 ∨ ℓ = 827 ∨ ℓ = 1583 →
      ℓ ∣ (((phi4 55 9 : ℤ) : ℚ) / ((den4 55 9 : ℤ) : ℚ)).den := by
  have hb : (9 : ℤ) ^ 3 + 55 ≠ 0 := by norm_num
  have hS : sextic 55 9 ≠ 0 := by rw [sextic]; norm_num
  rintro ℓ (rfl | rfl | rfl)
  · exact (dvd_den_quadruple_iff hb hS (by norm_num) (by norm_num) (by decide)).2
      ⟨2 ^ 4 * 7 * 827 * 1583, by rw [Psi4_55_9]; ring⟩
  · exact (dvd_den_quadruple_iff hb hS (by norm_num) (by norm_num) (by decide)).2
      ⟨2 ^ 4 * 7 ^ 2 * 1583, by rw [Psi4_55_9]; ring⟩
  · exact (dvd_den_quadruple_iff hb hS (by norm_num) (by norm_num) (by decide)).2
      ⟨2 ^ 4 * 7 ^ 2 * 827, by rw [Psi4_55_9]; ring⟩

end MordellQuartic