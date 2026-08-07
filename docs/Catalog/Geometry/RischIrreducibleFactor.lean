/-
Copyright (c) 2026. Released under Apache 2.0 license.
-/
import Geometry.RischArctanBoundary

/-!
# Irreducible-factor poles: the general valuation lemma and the arctangent base case

`Catalog/Geometry/RischLogIndependence.lean` proves that the derivative of a rational
function never has a *simple pole at a point*: the obstruction is phrased in terms of the
linear factor `X - a`.  `Catalog/Geometry/RischArctanBoundary.lean` then handles the single
function `1/(x²+1)` by passing to `ℂ` and localising at the point `i`.

The first next-cycle sub-conjecture recorded in `FUTURE_DIRECTIONS.md` asked whether the
valuation lemma holds verbatim with `X - a` replaced by an arbitrary irreducible factor.
This file proves that it does, over **any** field of characteristic zero, and then uses it
together with an explicit primitive to settle the base case of Conjecture A — one
irreducible quadratic denominator — in both directions:

* `irreducible_pole_not_derivative` — if `A/B` is in lowest terms and
  `(A'B - AB')·(F·R) = P·B²` with `F` irreducible, `F ∤ R` and `F ∤ P`, then `False`.
  In words: *a rational function with a simple pole along an irreducible factor `F` is
  never a derivative of a rational function.*  The proof is an `F`-adic valuation count:
  writing `B = Fᵏ·S` with `F ∤ S`, the Wronskian `A'B - AB'` is exactly `F^(k-1)` times a
  polynomial that is not divisible by `F`, because modulo `F` it equals `-k·A·F'·S` and
  `F` divides none of the four factors (`F' ≠ 0` has smaller degree, `A` is coprime to `B`,
  and `k ≠ 0` in characteristic zero).

* `real_irreducible_pole_has_no_rational_primitive` — the real analytic form, obtained
  through the Wronskian transfer lemma of the previous file.

* `irreducible_quadratic` and `quadratic_pole_no_rational_primitive` — for a negative
  discriminant, `X² + bX + c` is irreducible over `ℝ`, hence `(αx+β)/(x²+bx+c)` has no
  rational antiderivative unless `α = β = 0`.  Note that no passage to `ℂ` is needed any
  more: the obstruction is now visible over the real ground field itself.

* `quadratic_log_arctan_primitive` — the matching positive statement: for every
  `α, β` and every negative discriminant,
  `(α/2)·log(x²+bx+c) + ((2β-αb)/√Δ)·arctan((2x+b)/√Δ)` is an antiderivative of
  `(αx+β)/(x²+bx+c)` at **every** real point (the denominator never vanishes).

* `irreducible_quadratic_boundary` — the two halves combined: exactly one new generator,
  `arctan`, is needed, and it cannot be dispensed with.  Specialised to `1/(x²+1)` in
  `arctan_primitive` and `inv_x_sq_add_one_no_rational_primitive`.

* `quadratic_pole_not_rational_plus_logs` — the full generalisation of
  `RischArctan.arctan_not_rational_plus_real_logs`: for *every* irreducible real quadratic
  and *every* nonzero numerator, no combination `A(x)/B(x) + ∑ c_a·log(x-a)` is an
  antiderivative.  Unlike the previous cycle's proof, this one never leaves `ℝ`.

* `hermite_coefficients`, `hermite_step` and `quadratic_pow_has_log_arctan_primitive` —
  Hermite reduction at a *repeated* irreducible quadratic: for every `j`, the function
  `(αx+β)/Q^(j+1)` has a primitive `Pₙ(x)/Q(x)ʲ + λ·log Q(x) + μ·arctan((2x+b)/√Δ)`,
  by an induction that strips one power of `Q` at a time.

Altogether this strictly generalises the previous cycle's arctangent boundary (arbitrary
irreducible `F`, arbitrary numerator, arbitrary cofactor `R`, no algebraic closure) while
adding the constructive half that the previous cycles lacked.
-/

noncomputable section

open Polynomial

namespace RischIrred

/-! ## The `F`-adic valuation lemma -/

/-- In characteristic zero an irreducible polynomial does not divide its own derivative:
the derivative is nonzero (else `F` would be constant) and has strictly smaller degree. -/
theorem not_dvd_derivative_of_irreducible {K : Type*} [Field K] [CharZero K] {F : K[X]}
    (hF : Irreducible F) : ¬ F ∣ derivative F := by
  have hdeg : 0 < F.natDegree := hF.natDegree_pos
  have hd0 : derivative F ≠ 0 := fun h => by
    have := Polynomial.natDegree_eq_zero_of_derivative_eq_zero h
    omega
  intro hdvd
  have h1 := Polynomial.natDegree_le_of_dvd hdvd hd0
  have h2 := Polynomial.natDegree_derivative_lt (p := F) (by omega)
  omega

/-- **A derivative of a rational function has no simple pole along an irreducible factor.**

The hypothesis `(A'B - AB')·(F·R) = P·B²` is the cleared-denominator form of
`(A/B)' = P/(F·R)`, with `A/B` in lowest terms.  If `F` is irreducible and divides neither
the cofactor `R` nor the numerator `P` — i.e. the right-hand side really has an `F`-pole of
order exactly one — the identity is impossible.

This is `RischLogIndep.simple_pole_not_derivative` with the linear factor `X - a` replaced
by an arbitrary irreducible `F`, and with the point evaluations replaced by divisibility;
it holds over any field of characteristic zero, with no algebraic closedness assumption. -/
theorem irreducible_pole_not_derivative {K : Type*} [Field K] [CharZero K]
    (A B P R F : K[X]) (hF : Irreducible F) (hB : B ≠ 0) (hAB : IsCoprime A B)
    (hR : ¬ F ∣ R) (hP : ¬ F ∣ P)
    (hid : (derivative A * B - A * derivative B) * (F * R) = P * B ^ 2) : False := by
  have hFprime : Prime F := hF.prime
  by_cases hFB : F ∣ B
  · -- `F` divides the denominator: the pole has order `k + 1 ≥ 2`, not `1`.
    have hfin : FiniteMultiplicity F B := FiniteMultiplicity.of_not_isUnit hF.not_isUnit hB
    obtain ⟨S, hBeq, hS⟩ := hfin.exists_eq_pow_mul_and_not_dvd
    have hkpos : 0 < multiplicity F B := dvd_iff_multiplicity_pos.mpr hFB
    obtain ⟨j, hj⟩ : ∃ j, multiplicity F B = j + 1 := ⟨multiplicity F B - 1, by omega⟩
    rw [hj] at hBeq
    have hFA : ¬ F ∣ A := fun hFA => hFprime.not_unit (hAB.isUnit_of_dvd' hFA hFB)
    set T : K[X] := derivative A * F * S - C ((j : K) + 1) * A * derivative F * S
        - A * F * derivative S with hT
    -- The Wronskian factors as `F^j · T`.
    have h1 : derivative A * B - A * derivative B = F ^ j * T := by
      rw [hBeq, hT]
      simp only [derivative_mul, derivative_pow, Nat.add_sub_cancel]
      push_cast
      ring
    have hFne : (F : K[X]) ^ (j + 1) ≠ 0 := pow_ne_zero _ hFprime.ne_zero
    have hcancel : F ^ (j + 1) * (T * R) = F ^ (j + 1) * (F ^ (j + 1) * (P * S ^ 2)) := by
      have hid' := hid
      rw [h1, hBeq] at hid'
      ring_nf
      ring_nf at hid'
      linear_combination hid'
    have hTR : T * R = F ^ (j + 1) * (P * S ^ 2) := mul_left_cancel₀ hFne hcancel
    have hFTR : F ∣ T * R := ⟨F ^ j * (P * S ^ 2), by rw [hTR]; ring⟩
    rcases hFprime.dvd_or_dvd hFTR with hFT | hFR
    · -- `F ∣ T` forces `F` to divide one of `(j+1)`, `A`, `F'`, `S`; all are excluded.
      have h2 : F ∣ C ((j : K) + 1) * A * derivative F * S := by
        have hrw : C ((j : K) + 1) * A * derivative F * S
            = derivative A * F * S - A * F * derivative S - T := by rw [hT]; ring
        rw [hrw]
        exact dvd_sub (dvd_sub ⟨derivative A * S, by ring⟩ ⟨A * derivative S, by ring⟩) hFT
      have hjne : ((j : K) + 1) ≠ 0 := by
        have hcast : ((j : K) + 1) = ((j + 1 : ℕ) : K) := by push_cast; ring
        rw [hcast]
        exact Nat.cast_ne_zero.mpr (Nat.succ_ne_zero j)
      have hCu : IsUnit (C ((j : K) + 1)) := isUnit_C.mpr (Ne.isUnit hjne)
      rcases hFprime.dvd_or_dvd h2 with h3 | h3
      · rcases hFprime.dvd_or_dvd h3 with h4 | h4
        · rcases hFprime.dvd_or_dvd h4 with h5 | h5
          · exact hFprime.not_unit (isUnit_of_dvd_unit h5 hCu)
          · exact hFA h5
        · exact not_dvd_derivative_of_irreducible hF h4
      · exact hS h3
    · exact hR hFR
  · -- `F` does not divide the denominator: then the left side has no `F`-pole at all.
    have hFPB : F ∣ P * B ^ 2 :=
      ⟨(derivative A * B - A * derivative B) * R, by rw [← hid]; ring⟩
    rcases hFprime.dvd_or_dvd hFPB with h | h
    · exact hP h
    · exact hFB (hFprime.dvd_of_dvd_pow h)

/-- Existential restatement: a rational function `P/(F·R)` with an order-one `F`-pole has
no rational antiderivative. -/
theorem no_rational_primitive_of_irreducible_pole {K : Type*} [Field K] [CharZero K]
    (P R F : K[X]) (hF : Irreducible F) (hR : ¬ F ∣ R) (hP : ¬ F ∣ P) :
    ¬ ∃ A B : K[X], B ≠ 0 ∧ IsCoprime A B ∧
      (derivative A * B - A * derivative B) * (F * R) = P * B ^ 2 := by
  rintro ⟨A, B, hB, hAB, hid⟩
  exact irreducible_pole_not_derivative A B P R F hF hB hAB hR hP hid

/-! ## The real analytic form -/

/-- **Real form of the irreducible-pole obstruction.**  If `A/B` is in lowest terms and its
derivative equals `P/(F·R)` wherever both sides are defined, with `F` irreducible over `ℝ`
dividing neither `R` nor `P`, then a contradiction follows. -/
theorem real_irreducible_pole_has_no_rational_primitive (A B P R F : ℝ[X])
    (hF : Irreducible F) (hB : B ≠ 0) (hAB : IsCoprime A B) (hR : ¬ F ∣ R) (hP : ¬ F ∣ P)
    (h : ∀ x : ℝ, B.eval x ≠ 0 → (F * R).eval x ≠ 0 →
      HasDerivAt (fun y : ℝ => A.eval y / B.eval y) (P.eval x / (F * R).eval x) x) :
    False := by
  have hRne : R ≠ 0 := fun h0 => hR (by simp [h0])
  have hQ : (F * R : ℝ[X]) ≠ 0 := mul_ne_zero hF.ne_zero hRne
  have hid := RischLogIndep.wronskian_identity_of_hasDerivAt A B P (F * R) hB hQ h
  exact irreducible_pole_not_derivative A B P R F hF hB hAB hR hP hid

/-! ## Irreducible quadratics over `ℝ` -/

/-- A real quadratic with negative discriminant is irreducible: it has no real root
because `4·(x² + bx + c) = (2x + b)² + (4c - b²) > 0`. -/
theorem irreducible_quadratic (b c : ℝ) (hdisc : 0 < 4 * c - b ^ 2) :
    Irreducible (X ^ 2 + C b * X + C c : ℝ[X]) := by
  have hdeg : (X ^ 2 + C b * X + C c : ℝ[X]).natDegree = 2 := by compute_degree!
  refine Polynomial.irreducible_of_degree_le_three_of_not_isRoot (by simp [hdeg]) ?_
  intro x hx
  have hx' : x ^ 2 + b * x + c = 0 := by simpa using hx
  nlinarith [sq_nonneg (2 * x + b)]

/-- The quadratic `x² + bx + c` with negative discriminant is strictly positive
everywhere, so `(αx+β)/(x²+bx+c)` is defined at every real point. -/
theorem quadratic_pos (b c : ℝ) (hdisc : 0 < 4 * c - b ^ 2) (x : ℝ) :
    0 < x ^ 2 + b * x + c := by
  nlinarith [sq_nonneg (2 * x + b)]

/-- **No rational antiderivative past an irreducible quadratic pole.**  For a negative
discriminant and `(α, β) ≠ (0,0)`, the function `(αx+β)/(x²+bx+c)` has no antiderivative
that is a rational function.

Unlike `RischArctan.arctan_not_rational_plus_real_logs`, which needed the complex point
`i`, this is proved entirely over `ℝ` by the `F`-adic valuation count above, and it covers
every numerator and every irreducible quadratic. -/
theorem quadratic_pole_no_rational_primitive (al be b c : ℝ) (hdisc : 0 < 4 * c - b ^ 2)
    (hne : ¬ (al = 0 ∧ be = 0)) :
    ¬ ∃ A B : ℝ[X], B ≠ 0 ∧ IsCoprime A B ∧
      ∀ x : ℝ, B.eval x ≠ 0 →
        HasDerivAt (fun y : ℝ => A.eval y / B.eval y)
          ((al * x + be) / (x ^ 2 + b * x + c)) x := by
  rintro ⟨A, B, hB, hAB, h⟩
  set F : ℝ[X] := X ^ 2 + C b * X + C c with hFdef
  set P : ℝ[X] := C al * X + C be with hPdef
  have hF : Irreducible F := irreducible_quadratic b c hdisc
  have hPne : P ≠ 0 := by
    intro h0
    apply hne
    have h1 : P.eval 0 = be := by simp [hPdef]
    have h2 : P.eval 1 = al + be := by simp [hPdef]
    rw [h0] at h1 h2
    simp at h1 h2
    constructor <;> linarith
  have hPdeg : P.natDegree ≤ 1 := by
    rw [hPdef]; compute_degree
  have hFP : ¬ F ∣ P := by
    intro hdvd
    have hle := Polynomial.natDegree_le_of_dvd hdvd hPne
    have hFdeg : F.natDegree = 2 := by rw [hFdef]; compute_degree!
    omega
  have hFR : ¬ F ∣ (1 : ℝ[X]) := fun hdvd => hF.not_isUnit (isUnit_of_dvd_one hdvd)
  refine real_irreducible_pole_has_no_rational_primitive A B P 1 F hF hB hAB hFR hFP ?_
  intro x hBx _
  have hval : (F * 1).eval x = x ^ 2 + b * x + c := by simp [hFdef]
  have hPval : P.eval x = al * x + be := by simp [hPdef]
  rw [hval, hPval]
  exact h x hBx

/-! ## The positive half: one arctangent generator suffices -/

/-- **The arctangent base case of Conjecture A.**  For every negative discriminant and
every numerator `αx + β`, the function
`(α/2)·log(x² + bx + c) + ((2β - αb)/√Δ)·arctan((2x + b)/√Δ)`, with `Δ = 4c - b²`,
is an antiderivative of `(αx + β)/(x² + bx + c)` at *every* real point.

The computation behind it: `d/dx arctan((2x+b)/√Δ) = 2√Δ/(Δ + (2x+b)²)` and
`Δ + (2x+b)² = 4(x² + bx + c)`, so the arctangent contributes `√Δ/(2(x²+bx+c))`, which is
exactly what is needed to cancel the `b`-part of the logarithmic term. -/
theorem quadratic_log_arctan_primitive (al be b c : ℝ) (hdisc : 0 < 4 * c - b ^ 2) (x : ℝ) :
    HasDerivAt (fun y : ℝ => (al / 2) * Real.log (y ^ 2 + b * y + c)
        + ((2 * be - al * b) / Real.sqrt (4 * c - b ^ 2))
            * Real.arctan ((2 * y + b) / Real.sqrt (4 * c - b ^ 2)))
      ((al * x + be) / (x ^ 2 + b * x + c)) x := by
  set d := Real.sqrt (4 * c - b ^ 2) with hdd
  have hdpos : 0 < d := Real.sqrt_pos.mpr hdisc
  have hd2 : d ^ 2 = 4 * c - b ^ 2 := Real.sq_sqrt hdisc.le
  have hQ : ∀ y : ℝ, 0 < y ^ 2 + b * y + c := quadratic_pos b c hdisc
  have h1 : HasDerivAt (fun y : ℝ => y ^ 2 + b * y + c) (2 * x + b) x := by
    have h := ((hasDerivAt_pow 2 x).add ((hasDerivAt_id x).const_mul b)).add_const c
    simpa using h
  have h2 : HasDerivAt (fun y : ℝ => Real.log (y ^ 2 + b * y + c))
      ((2 * x + b) / (x ^ 2 + b * x + c)) x := h1.log (hQ x).ne'
  have h3 : HasDerivAt (fun y : ℝ => (2 * y + b) / d) (2 / d) x := by
    have h : HasDerivAt (fun y : ℝ => 2 * y + b) 2 x := by
      simpa using ((hasDerivAt_id x).const_mul 2).add_const b
    simpa using h.div_const d
  have h4 : HasDerivAt (fun y : ℝ => Real.arctan ((2 * y + b) / d))
      ((2 / d) / (1 + ((2 * x + b) / d) ^ 2)) x := by
    simpa [div_eq_mul_inv, mul_comm] using h3.arctan
  have key : (2 / d) / (1 + ((2 * x + b) / d) ^ 2) = d / (2 * (x ^ 2 + b * x + c)) := by
    have hQx := hQ x
    rw [div_eq_div_iff (by positivity) (by positivity)]
    field_simp
    nlinarith [hd2]
  rw [key] at h4
  have h := (h2.const_mul (al / 2)).add (h4.const_mul ((2 * be - al * b) / d))
  convert h using 1
  have hQx := hQ x
  field_simp
  ring

/-- **The boundary, both halves at once.**  For a negative discriminant and a nonzero
numerator, `(αx+β)/(x²+bx+c)`
* *has* an antiderivative built from a logarithm and an arctangent of affine data, valid at
  every real point, and
* has *no* antiderivative that is a rational function.

So exactly one new generator beyond the rational functions and logarithms of the previous
cycles — the arctangent — is both sufficient and necessary at an irreducible quadratic. -/
theorem irreducible_quadratic_boundary (al be b c : ℝ) (hdisc : 0 < 4 * c - b ^ 2)
    (hne : ¬ (al = 0 ∧ be = 0)) :
    (∀ x : ℝ, HasDerivAt (fun y : ℝ => (al / 2) * Real.log (y ^ 2 + b * y + c)
        + ((2 * be - al * b) / Real.sqrt (4 * c - b ^ 2))
            * Real.arctan ((2 * y + b) / Real.sqrt (4 * c - b ^ 2)))
      ((al * x + be) / (x ^ 2 + b * x + c)) x)
    ∧ ¬ ∃ A B : ℝ[X], B ≠ 0 ∧ IsCoprime A B ∧
      ∀ x : ℝ, B.eval x ≠ 0 →
        HasDerivAt (fun y : ℝ => A.eval y / B.eval y)
          ((al * x + be) / (x ^ 2 + b * x + c)) x :=
  ⟨fun x => quadratic_log_arctan_primitive al be b c hdisc x,
    quadratic_pole_no_rational_primitive al be b c hdisc hne⟩

/-! ## The classical instance `1/(x²+1)` -/

/-- Specialisation of the positive half: `arctan` is a primitive of `1/(x²+1)`.
Obtained from `quadratic_log_arctan_primitive` with `α = 0`, `β = 1`, `b = 0`, `c = 1`,
where `√Δ = 2` and the formula collapses to `arctan(2x/2) = arctan x`. -/
theorem arctan_primitive (x : ℝ) :
    HasDerivAt Real.arctan (1 / (x ^ 2 + 1)) x := by
  have h := quadratic_log_arctan_primitive 0 1 0 1 (by norm_num) x
  have hs : Real.sqrt (4 * 1 - (0 : ℝ) ^ 2) = 2 := by
    rw [show (4 * 1 - (0 : ℝ) ^ 2) = 2 ^ 2 by norm_num]
    exact Real.sqrt_sq (by norm_num)
  rw [hs] at h
  simpa using h

/-- Specialisation of the negative half: `1/(x²+1)` has no rational antiderivative.  This
is the algebraic content of "`arctan` is not a rational function", proved without leaving
`ℝ`. -/
theorem inv_x_sq_add_one_no_rational_primitive :
    ¬ ∃ A B : ℝ[X], B ≠ 0 ∧ IsCoprime A B ∧
      ∀ x : ℝ, B.eval x ≠ 0 →
        HasDerivAt (fun y : ℝ => A.eval y / B.eval y) (1 / (x ^ 2 + 1)) x := by
  have h := quadratic_pole_no_rational_primitive 0 1 0 1 (by norm_num) (by simp)
  intro hcon
  refine h ?_
  obtain ⟨A, B, hB, hAB, hd⟩ := hcon
  exact ⟨A, B, hB, hAB, fun x hx => by simpa using hd x hx⟩

/-! ## Rational functions plus real logarithms are not enough, for any irreducible quadratic -/

/-- **Generalised arctangent boundary.**  For every real quadratic with negative
discriminant and every nonzero numerator `αx + β`, the function `(αx+β)/(x²+bx+c)` has no
antiderivative of the form `A(x)/B(x) + ∑_{a ∈ s} c_a·log(x - a)`.

`RischArctan.arctan_not_rational_plus_real_logs` is the special case
`α = 0, β = 1, b = 0, c = 1`; that proof had to pass to `ℂ` and localise at the point `i`,
whereas here the whole argument stays over `ℝ`: the logarithmic denominator `∏(x-a)` is a
product of linear factors, hence coprime to the irreducible `F`, so `F` survives as an
order-one pole of the combined right-hand side and
`irreducible_pole_not_derivative` applies directly. -/
theorem quadratic_pole_not_rational_plus_logs (al be b c : ℝ) (hdisc : 0 < 4 * c - b ^ 2)
    (hne : ¬ (al = 0 ∧ be = 0)) (A B : ℝ[X]) (s : Finset ℝ) (cc : ℝ → ℝ)
    (hB : B ≠ 0) (hAB : IsCoprime A B)
    (h : ∀ x : ℝ, B.eval x ≠ 0 → (∀ a ∈ s, x ≠ a) →
      HasDerivAt (fun y : ℝ => A.eval y / B.eval y + ∑ a ∈ s, cc a * Real.log (y - a))
        ((al * x + be) / (x ^ 2 + b * x + c)) x) :
    False := by
  set F : ℝ[X] := X ^ 2 + C b * X + C c with hFdef
  set P : ℝ[X] := C al * X + C be with hPdef
  set D : ℝ[X] := ∏ a ∈ s, (X - C a) with hD
  set N : ℝ[X] := ∑ a ∈ s, C (cc a) * ∏ b ∈ s.erase a, (X - C b) with hN
  have hF : Irreducible F := irreducible_quadratic b c hdisc
  have hFdeg : F.natDegree = 2 := by rw [hFdef]; compute_degree!
  have hDne : D ≠ 0 :=
    Finset.prod_ne_zero_iff.mpr fun a _ => Polynomial.X_sub_C_ne_zero a
  have hFeval : ∀ x : ℝ, F.eval x = x ^ 2 + b * x + c := by
    intro x; simp [hFdef]
  have hPeval : ∀ x : ℝ, P.eval x = al * x + be := by
    intro x; simp [hPdef]
  -- `F` is coprime to the linear logarithmic denominator
  have hFD : ¬ F ∣ D := by
    intro hdvd
    rw [hD] at hdvd
    obtain ⟨a, -, hda⟩ := (Prime.dvd_finset_prod_iff hF.prime _).mp hdvd
    have := Polynomial.natDegree_le_of_dvd hda (Polynomial.X_sub_C_ne_zero a)
    simp [hFdeg] at this
  have hPne : P ≠ 0 := by
    intro h0
    apply hne
    have h1 : P.eval 0 = be := by simp [hPdef]
    have h2 : P.eval 1 = al + be := by simp [hPdef]
    rw [h0] at h1 h2
    simp at h1 h2
    constructor <;> linarith
  have hFP : ¬ F ∣ P := by
    intro hdvd
    have hle := Polynomial.natDegree_le_of_dvd hdvd hPne
    have hPdeg : P.natDegree ≤ 1 := by rw [hPdef]; compute_degree
    omega
  have hFnum : ¬ F ∣ (P * D - F * N) := by
    intro hdvd
    have : F ∣ P * D := by
      have hrw : P * D = (P * D - F * N) + F * N := by ring
      rw [hrw]
      exact dvd_add hdvd ⟨N, rfl⟩
    rcases hF.prime.dvd_or_dvd this with h' | h'
    · exact hFP h'
    · exact hFD h'
  -- the cleared-denominator identity, obtained by differentiating the candidate primitive
  have hid : (derivative A * B - A * derivative B) * (F * D) = (P * D - F * N) * B ^ 2 := by
    have hzero : (derivative A * B - A * derivative B) * (F * D)
        - (P * D - F * N) * B ^ 2 = 0 := by
      refine Polynomial.eq_zero_of_infinite_isRoot _ (Set.Infinite.mono ?_
        ((Set.infinite_univ (α := ℝ)).diff
          (Polynomial.finite_setOf_isRoot (mul_ne_zero hB hDne))))
      rintro x ⟨-, hx⟩
      have hx' : (B * D).eval x ≠ 0 := hx
      rw [eval_mul, mul_ne_zero_iff] at hx'
      obtain ⟨hBx, hDx⟩ := hx'
      have hDx' : (∏ a ∈ s, (x - a)) ≠ 0 := by
        rw [hD, eval_prod] at hDx
        simpa using hDx
      have hnea : ∀ a ∈ s, x ≠ a := by
        intro a ha hcon
        exact hDx' (Finset.prod_eq_zero ha (by simp [hcon]))
      have hQx : 0 < x ^ 2 + b * x + c := quadratic_pos b c hdisc x
      have hlogs : HasDerivAt (fun y : ℝ => ∑ a ∈ s, cc a * Real.log (y - a))
          (∑ a ∈ s, cc a / (x - a)) x := by
        refine HasDerivAt.fun_sum (A := fun (a : ℝ) (y : ℝ) => cc a * Real.log (y - a))
          (A' := fun a : ℝ => cc a / (x - a)) fun a ha => ?_
        have hxa : x - a ≠ 0 := sub_ne_zero.mpr (hnea a ha)
        have hl : HasDerivAt (fun y : ℝ => Real.log (y - a)) (1 / (x - a)) x := by
          simpa using (((hasDerivAt_id x).sub_const a).log hxa)
        simpa [mul_one_div] using HasDerivAt.const_mul (cc a) hl
      have hd := ((A.hasDerivAt x).div (B.hasDerivAt x) hBx).add hlogs
      have heq := (h x hBx hnea).unique hd
      rw [RischArctan.sum_simple_fractions_eq s cc hnea] at heq
      have hNx : (∑ a ∈ s, cc a * ∏ b ∈ s.erase a, (x - b)) = N.eval x := by
        rw [hN, eval_finset_sum]
        exact Finset.sum_congr rfl fun a _ => by rw [eval_mul, eval_C, eval_prod]; simp
      have hDxv : (∏ a ∈ s, (x - a)) = D.eval x := by
        rw [hD, eval_prod]; simp
      rw [hNx, hDxv] at heq
      simp only [Set.mem_setOf_eq, IsRoot.def, eval_sub, eval_mul, eval_pow]
      rw [hFeval, hPeval]
      have hDxne : D.eval x ≠ 0 := hDx
      have hQ' : x * (x + b) + c ≠ 0 := by nlinarith
      field_simp at heq
      linear_combination -heq
    exact sub_eq_zero.mp hzero
  exact irreducible_pole_not_derivative A B (P * D - F * N) D F hF hB hAB hFD hFnum hid

/-! ## Hermite reduction at a repeated irreducible quadratic, and the full base case -/

/-- **The Hermite coefficients exist.**  For a nonzero discriminant and a nonzero
multiplier `k`, one can choose `u, v, d` with
`u·Q + d·Q - k·(u x + v)·Q' = αx + β` identically in `x`, where `Q = x² + bx + c` and
`Q' = 2x + b`.  These are exactly the coefficients produced by Hermite reduction:
`u = (2β - αb)/(kΔ)`, `v = (ub - α/k)/2`, `d = u(2k-1)`. -/
theorem hermite_coefficients (al be b c : ℝ) (hdisc : 0 < 4 * c - b ^ 2) (k : ℝ) (hk : k ≠ 0) :
    ∃ u v d : ℝ, ∀ x : ℝ,
      u * (x ^ 2 + b * x + c) + d * (x ^ 2 + b * x + c)
        - k * (u * x + v) * (2 * x + b) = al * x + be := by
  have hD : (4 * c - b ^ 2) ≠ 0 := ne_of_gt hdisc
  refine ⟨(2 * be - al * b) / (k * (4 * c - b ^ 2)),
    ((2 * be - al * b) / (k * (4 * c - b ^ 2)) * b - al / k) / 2,
    (2 * be - al * b) / (k * (4 * c - b ^ 2)) * (2 * k - 1), fun x => ?_⟩
  field_simp
  ring

/-- **One Hermite reduction step at an irreducible quadratic.**  With the coefficients of
`hermite_coefficients`, the rational function `(ux+v)/Qᵏ` has derivative
`(αx+β)/Q^(k+1) - d/Qᵏ`: differentiating it removes the order-`(k+1)` pole and leaves a
*constant* numerator over `Qᵏ`.  This is the inductive step that drives the pole order
down. -/
theorem hermite_step (al be b c u v d : ℝ) (hdisc : 0 < 4 * c - b ^ 2) (k : ℕ) (hk : 1 ≤ k)
    (hstep : ∀ x : ℝ, u * (x ^ 2 + b * x + c) + d * (x ^ 2 + b * x + c)
      - (k : ℝ) * (u * x + v) * (2 * x + b) = al * x + be) (x : ℝ) :
    HasDerivAt (fun y : ℝ => (u * y + v) / (y ^ 2 + b * y + c) ^ k)
      ((al * x + be) / (x ^ 2 + b * x + c) ^ (k + 1) - d / (x ^ 2 + b * x + c) ^ k) x := by
  have hQ : ∀ y : ℝ, 0 < y ^ 2 + b * y + c := quadratic_pos b c hdisc
  have hQx := hQ x
  have h1 : HasDerivAt (fun y : ℝ => y ^ 2 + b * y + c) (2 * x + b) x := by
    have h := ((hasDerivAt_pow 2 x).add ((hasDerivAt_id x).const_mul b)).add_const c
    simpa using h
  have h2 : HasDerivAt (fun y : ℝ => (y ^ 2 + b * y + c) ^ k)
      ((k : ℝ) * (x ^ 2 + b * x + c) ^ (k - 1) * (2 * x + b)) x := h1.pow k
  have h3 : HasDerivAt (fun y : ℝ => u * y + v) u x := by
    simpa using ((hasDerivAt_id x).const_mul u).add_const v
  have hden : ((x ^ 2 + b * x + c) ^ k) ≠ 0 := by positivity
  have h4 := h3.div h2 hden
  convert h4 using 1
  obtain ⟨j, rfl⟩ : ∃ j, k = j + 1 := ⟨k - 1, by omega⟩
  have hs := hstep x
  push_cast at hs
  simp only [Nat.add_sub_cancel]
  rw [div_sub_div _ _ (by positivity) (by positivity),
    div_eq_div_iff (by positivity) (by positivity)]
  push_cast
  linear_combination (-(((x ^ 2 + b * x + c) ^ j) ^ 3 * (x ^ 2 + b * x + c) ^ 3)) * hs

/-- **The base case of Conjecture A, at full multiplicity.**  For every irreducible real
quadratic `Q = x² + bx + c` and every `j`, every function `(αx+β)/Q^(j+1)` has an
antiderivative of the form

`Pₙ(x)/Q(x)ʲ + λ·log Q(x) + μ·arctan((2x+b)/√Δ)`,

valid at *every* real point.  The proof is an induction on `j` whose step is
`hermite_step`: it strips one power of `Q`, at the cost of a constant numerator, until the
order-one case `quadratic_log_arctan_primitive` applies.

Together with `RischSplit.split_rational_has_EML_primitive` (all split denominators) and
`quadratic_pole_not_rational_plus_logs` (arctangent is unavoidable), this settles the
one-irreducible-quadratic case of the completeness conjecture in both directions. -/
theorem quadratic_pow_has_log_arctan_primitive (b c : ℝ) (hdisc : 0 < 4 * c - b ^ 2) :
    ∀ (j : ℕ) (al be : ℝ), ∃ (Pn : ℝ[X]) (lam mu : ℝ), ∀ x : ℝ,
      HasDerivAt (fun y : ℝ => Pn.eval y / (y ^ 2 + b * y + c) ^ j
          + lam * Real.log (y ^ 2 + b * y + c)
          + mu * Real.arctan ((2 * y + b) / Real.sqrt (4 * c - b ^ 2)))
        ((al * x + be) / (x ^ 2 + b * x + c) ^ (j + 1)) x := by
  have hQ : ∀ y : ℝ, 0 < y ^ 2 + b * y + c := quadratic_pos b c hdisc
  intro j
  induction j with
  | zero =>
      intro al be
      refine ⟨0, al / 2, (2 * be - al * b) / Real.sqrt (4 * c - b ^ 2), fun x => ?_⟩
      have h := quadratic_log_arctan_primitive al be b c hdisc x
      simpa using h
  | succ j ih =>
      intro al be
      have hkne : ((j : ℝ) + 1) ≠ 0 := by positivity
      obtain ⟨u, v, d, hcoef⟩ := hermite_coefficients al be b c hdisc ((j : ℝ) + 1) hkne
      have hcoef' : ∀ x : ℝ, u * (x ^ 2 + b * x + c) + d * (x ^ 2 + b * x + c)
          - ((j + 1 : ℕ) : ℝ) * (u * x + v) * (2 * x + b) = al * x + be := by
        intro x; push_cast; exact hcoef x
      obtain ⟨Pn, lam, mu, hih⟩ := ih 0 d
      refine ⟨C u * X + C v + Pn * (X ^ 2 + C b * X + C c), lam, mu, fun x => ?_⟩
      have hstep := hermite_step al be b c u v d hdisc (j + 1) (by omega) hcoef' x
      have hsum := hstep.add (hih x)
      have hfun : (fun y : ℝ => (C u * X + C v + Pn * (X ^ 2 + C b * X + C c)).eval y
            / (y ^ 2 + b * y + c) ^ (j + 1)
            + lam * Real.log (y ^ 2 + b * y + c)
            + mu * Real.arctan ((2 * y + b) / Real.sqrt (4 * c - b ^ 2)))
          = fun y : ℝ => (u * y + v) / (y ^ 2 + b * y + c) ^ (j + 1)
            + (Pn.eval y / (y ^ 2 + b * y + c) ^ j
              + lam * Real.log (y ^ 2 + b * y + c)
              + mu * Real.arctan ((2 * y + b) / Real.sqrt (4 * c - b ^ 2))) := by
        funext y
        have hQy : (0 : ℝ) < y ^ 2 + b * y + c := hQ y
        have hne : ((y ^ 2 + b * y + c) ^ j) ≠ 0 := by positivity
        have key : ∀ A : ℝ, (u * y + v + A * (y ^ 2 + b * y + c)) / (y ^ 2 + b * y + c) ^ (j + 1)
            = (u * y + v) / (y ^ 2 + b * y + c) ^ (j + 1) + A / (y ^ 2 + b * y + c) ^ j := by
          intro A
          rw [add_div]
          congr 1
          rw [pow_succ (y ^ 2 + b * y + c) j, mul_comm ((y ^ 2 + b * y + c) ^ j) (y ^ 2 + b * y + c),
            mul_comm A (y ^ 2 + b * y + c), mul_div_mul_left _ _ hQy.ne']
        simp only [eval_add, eval_mul, eval_pow, eval_C, eval_X]
        rw [key]
        ring
      rw [hfun]
      convert hsum using 1
      simp only [zero_mul, zero_add]
      ring

end RischIrred