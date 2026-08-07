/-
Copyright (c) 2026. Released under Apache 2.0 license.
-/
import Geometry.RischLiouvilleDichotomy

/-!
# Derivatives have no simple poles, and logarithms are independent

The previous cycle proved (`RischResidue.no_rational_primitive_of_simple_pole`) that the
single rational function `c/(x-a)` with `c ≠ 0` has no rational antiderivative.  This file
proves the general structural fact behind it, which is the missing ingredient identified
as Conjecture C in `FUTURE_DIRECTIONS.md`:

* `simple_pole_not_derivative` — **the derivative of a rational function never has a
  simple pole.**  Concretely: if `A/B` is in lowest terms and `(A/B)' = P/((x-a)·R)` with
  `R(a) ≠ 0` and `P(a) ≠ 0`, then a contradiction follows.  The proof is a valuation count
  at `a`: if `B` has an `a`-adic valuation `k ≥ 1` then the Wronskian `A'B - AB'` has
  valuation exactly `k - 1`, so the derivative has a pole of order exactly `k + 1 ≥ 2`;
  and if `B(a) ≠ 0` the derivative has no pole at `a` at all.

* `no_rational_primitive_of_simple_pole_general` — consequently *any* rational function in
  lowest terms whose denominator has a simple root has no rational antiderivative.  This
  strictly generalises the previous cycle's single-pole statement.

* `log_coefficients_vanish_of_rational` — **linear independence of logarithms of distinct
  affine factors modulo rational functions**: if `∑_{a ∈ s} c_a/(x-a)` is the derivative of
  a rational function then every `c_a` is zero.  Combined with
  `RischResidue.partialFraction_eval` (which realises the coefficients as the simple-pole
  residues) this says that the logarithmic part of the Risch output is *forced*: no
  nonzero residue can be absorbed into the rational part.

* Real analytic corollaries: `real_simple_pole_has_no_rational_primitive` and
  `real_log_coefficients_vanish`.
-/

noncomputable section

open Polynomial

namespace RischLogIndep

/-! ## The valuation lemma -/

/-- **A derivative of a rational function has no simple pole.**

Hypotheses: `A/B` is a rational function in lowest terms (`IsCoprime A B`, `B ≠ 0`), and
the Wronskian identity `(A'B - AB')·((X-a)·R) = P·B²` holds, which is the cleared-
denominator form of `(A/B)' = P/((X-a)·R)`.  If moreover `R(a) ≠ 0` and `P(a) ≠ 0` — that
is, the right-hand side really has a *simple* pole at `a` with nonzero residue — then this
is impossible. -/
theorem simple_pole_not_derivative (A B P R : ℂ[X]) (a : ℂ) (hB : B ≠ 0) (hAB : IsCoprime A B)
    (hR : R.eval a ≠ 0) (hP : P.eval a ≠ 0)
    (hid : (derivative A * B - A * derivative B) * ((X - C a) * R) = P * B ^ 2) : False := by
  by_cases hBa : B.eval a = 0
  · -- `B` vanishes at `a`; the pole of the derivative has order `k + 1 ≥ 2`.
    have hBroot : B.IsRoot a := hBa
    have hAa : A.eval a ≠ 0 := by
      intro hAa
      have hXA : (X - C a : ℂ[X]) ∣ A := (Polynomial.dvd_iff_isRoot).mpr hAa
      have hXB : (X - C a : ℂ[X]) ∣ B := (Polynomial.dvd_iff_isRoot).mpr hBroot
      exact (Polynomial.prime_X_sub_C a).not_unit (hAB.isUnit_of_dvd' hXA hXB)
    set k := B.rootMultiplicity a with hk
    have hkpos : 0 < k := (Polynomial.rootMultiplicity_pos hB).mpr hBroot
    obtain ⟨j, hj⟩ : ∃ j, k = j + 1 := ⟨k - 1, by omega⟩
    set S := B /ₘ (X - C a) ^ k with hS
    have hBeq : B = (X - C a) ^ (j + 1) * S := by
      have := Polynomial.pow_mul_divByMonic_rootMultiplicity_eq B a
      rw [← hk, ← hS] at this
      simpa [hj] using this.symm
    have hS0 : S.eval a ≠ 0 := Polynomial.eval_divByMonic_pow_rootMultiplicity_ne_zero a hB
    set T : ℂ[X] := derivative A * (X - C a) * S - C ((j : ℂ) + 1) * A * S
        - A * (X - C a) * derivative S with hT
    have h1 : derivative A * B - A * derivative B = (X - C a) ^ j * T := by
      rw [hBeq, hT]
      simp only [derivative_mul, derivative_pow, derivative_sub, derivative_X, derivative_C,
        sub_zero, mul_one, Nat.add_sub_cancel]
      push_cast
      ring
    have hcancel : ((X - C a : ℂ[X])) ^ (j + 1) * (T * R)
        = ((X - C a : ℂ[X])) ^ (j + 1) * ((X - C a) ^ (j + 1) * (P * S ^ 2)) := by
      have hid' := hid
      rw [h1, hBeq] at hid'
      linear_combination hid'
    have hXne : ((X - C a : ℂ[X])) ^ (j + 1) ≠ 0 :=
      pow_ne_zero _ (Polynomial.X_sub_C_ne_zero a)
    have hTR : T * R = (X - C a) ^ (j + 1) * (P * S ^ 2) := mul_left_cancel₀ hXne hcancel
    have h := congrArg (Polynomial.eval a) hTR
    rw [hT] at h
    simp only [eval_sub, eval_mul, eval_X, eval_C, eval_pow, sub_self, mul_zero,
      zero_mul, zero_sub, zero_pow (Nat.succ_ne_zero j)] at h
    have hj1 : ((j : ℂ) + 1) ≠ 0 := by
      intro hcon
      have hcast : ((j : ℝ) + 1 : ℂ) = 0 := by exact_mod_cast hcon
      have hre : ((j : ℝ) + 1) = 0 := by exact_mod_cast hcast
      nlinarith [Nat.cast_nonneg (α := ℝ) j]
    have hprod : ((j : ℂ) + 1) * (A.eval a * (S.eval a * R.eval a)) = 0 := by
      linear_combination -h
    rcases mul_eq_zero.mp hprod with h' | h'
    · exact hj1 h'
    · rcases mul_eq_zero.mp h' with h'' | h''
      · exact hAa h''
      · rcases mul_eq_zero.mp h'' with h₃ | h₃
        · exact hS0 h₃
        · exact hR h₃
  · -- `B(a) ≠ 0`: the derivative is regular at `a`, so the right-hand side must be too.
    have h := congrArg (Polynomial.eval a) hid
    simp only [eval_mul, eval_sub, eval_X, eval_C, eval_pow, sub_self,
      zero_mul, mul_zero] at h
    exact hP ((mul_eq_zero.mp h.symm).resolve_right (pow_ne_zero 2 hBa))

/-- **No rational antiderivative past a simple pole.**  A rational function `P/Q` whose
denominator has a simple root `a` at which the numerator does not vanish has no rational
antiderivative.  (Stated in cleared-denominator form; `Q = (X - a)·R` with `R(a) ≠ 0`
expresses that `a` is a simple root.)  This generalises
`RischResidue.no_rational_primitive_of_simple_pole` from `c/(x-a)` to arbitrary
numerators and denominators. -/
theorem no_rational_primitive_of_simple_pole_general (P R : ℂ[X]) (a : ℂ)
    (hR : R.eval a ≠ 0) (hP : P.eval a ≠ 0) :
    ¬ ∃ A B : ℂ[X], B ≠ 0 ∧ IsCoprime A B ∧
      (derivative A * B - A * derivative B) * ((X - C a) * R) = P * B ^ 2 := by
  rintro ⟨A, B, hB, hAB, hid⟩
  exact simple_pole_not_derivative A B P R a hB hAB hR hP hid

/-! ## Linear independence of logarithms -/

/-- The value at `a ∈ s` of the numerator `∑_{b ∈ s} c b ∏_{d ≠ b} (X - d)` of the
logarithmic derivative is `c a · ∏_{d ∈ s \ {a}} (a - d)`: every other summand contains
the factor `(a - a)`. -/
theorem eval_residue_numerator (s : Finset ℂ) (c : ℂ → ℂ) {a : ℂ} (ha : a ∈ s) :
    (∑ b ∈ s, C (c b) * ∏ d ∈ s.erase b, (X - C d)).eval a
      = c a * ∏ d ∈ s.erase a, (a - d) := by
  rw [eval_finset_sum]
  rw [Finset.sum_eq_single a]
  · simp [eval_prod]
  · intro b hb hba
    have haerase : a ∈ s.erase b := Finset.mem_erase.mpr ⟨Ne.symm hba, ha⟩
    have : (∏ d ∈ s.erase b, (X - C d)).eval a = 0 := by
      rw [eval_prod]
      exact Finset.prod_eq_zero haerase (by simp)
    simp [this]
  · intro hna
    exact absurd ha hna

/-- **Logarithms of distinct affine factors are linearly independent modulo rational
functions.**  If `∑_{a ∈ s} c_a/(x - a)` — the derivative of `∑_{a ∈ s} c_a log(x - a)` —
is the derivative of a rational function `A/B` in lowest terms, then all `c_a = 0`.

Equivalently: no nontrivial combination of logarithms of distinct affine factors is a
rational function.  This is what makes the residue criterion sharp: the logarithmic part
of a Risch primitive can never be traded for a rational one. -/
theorem log_coefficients_vanish_of_rational (s : Finset ℂ) (c : ℂ → ℂ) (A B : ℂ[X])
    (hB : B ≠ 0) (hAB : IsCoprime A B)
    (hid : (derivative A * B - A * derivative B) * (∏ a ∈ s, (X - C a))
      = (∑ a ∈ s, C (c a) * ∏ b ∈ s.erase a, (X - C b)) * B ^ 2) :
    ∀ a ∈ s, c a = 0 := by
  intro a ha
  by_contra hca
  set R : ℂ[X] := ∏ b ∈ s.erase a, (X - C b) with hRdef
  have hQ : (∏ b ∈ s, (X - C b)) = (X - C a) * R := (Finset.mul_prod_erase s _ ha).symm
  have hR : R.eval a ≠ 0 := by
    rw [hRdef, eval_prod]
    refine Finset.prod_ne_zero_iff.mpr ?_
    intro d hd
    have hda : d ≠ a := (Finset.mem_erase.mp hd).1
    simp only [eval_sub, eval_X, eval_C]
    exact sub_ne_zero.mpr fun h => hda h.symm
  have hP : (∑ b ∈ s, C (c b) * ∏ d ∈ s.erase b, (X - C d)).eval a ≠ 0 := by
    rw [eval_residue_numerator s c ha]
    refine mul_ne_zero hca ?_
    refine Finset.prod_ne_zero_iff.mpr ?_
    intro d hd
    exact sub_ne_zero.mpr fun h => (Finset.mem_erase.mp hd).1 h.symm
  exact simple_pole_not_derivative A B _ R a hB hAB hR hP (by rw [← hQ]; exact hid)

/-! ## Real analytic corollaries -/

/-- Transfer of the Wronskian identity from an analytic statement over `ℝ` to a polynomial
identity over `ℂ`: if `A/B` has derivative `P/Q` wherever both are defined, then
`(A'B - AB')·Q = P·B²` after mapping to `ℂ[X]`. -/
theorem wronskian_identity_of_hasDerivAt (A B P Q : ℝ[X]) (hB : B ≠ 0) (hQ : Q ≠ 0)
    (h : ∀ x : ℝ, B.eval x ≠ 0 → Q.eval x ≠ 0 →
      HasDerivAt (fun y : ℝ => A.eval y / B.eval y) (P.eval x / Q.eval x) x) :
    (derivative A * B - A * derivative B) * Q = P * B ^ 2 := by
  have hzero : (derivative A * B - A * derivative B) * Q - P * B ^ 2 = 0 := by
    refine Polynomial.eq_zero_of_infinite_isRoot _ (Set.Infinite.mono ?_
      ((Set.infinite_univ (α := ℝ)).diff
        (Polynomial.finite_setOf_isRoot (mul_ne_zero hB hQ))))
    rintro x ⟨-, hx⟩
    have hx' : (B * Q).eval x ≠ 0 := hx
    rw [eval_mul, mul_ne_zero_iff] at hx'
    obtain ⟨hBx, hQx⟩ := hx'
    have hd := (A.hasDerivAt x).div (B.hasDerivAt x) hBx
    have heq := (h x hBx hQx).unique hd
    simp only [Set.mem_setOf_eq, IsRoot.def, eval_sub, eval_mul, eval_pow]
    field_simp at heq
    linarith [heq]
  exact sub_eq_zero.mp hzero

/-- **Real form of the simple-pole obstruction.**  A rational function `P/Q` with a simple
real pole at `a` (numerator nonvanishing there) has no rational antiderivative. -/
theorem real_simple_pole_has_no_rational_primitive (A B P R : ℝ[X]) (a : ℝ) (hB : B ≠ 0)
    (hAB : IsCoprime A B) (hR : R.eval a ≠ 0)
    (hP : P.eval a ≠ 0)
    (h : ∀ x : ℝ, B.eval x ≠ 0 → ((X - C a) * R).eval x ≠ 0 →
      HasDerivAt (fun y : ℝ => A.eval y / B.eval y)
        (P.eval x / ((X - C a) * R).eval x) x) :
    False := by
  have hRne : R ≠ 0 := fun h0 => hR (by simp [h0])
  have hQ : ((X - C a) * R : ℝ[X]) ≠ 0 := mul_ne_zero (Polynomial.X_sub_C_ne_zero a) hRne
  have hid := wronskian_identity_of_hasDerivAt A B P ((X - C a) * R) hB hQ h
  have hmap := congrArg (Polynomial.map (algebraMap ℝ ℂ)) hid
  refine simple_pole_not_derivative (A.map (algebraMap ℝ ℂ)) (B.map (algebraMap ℝ ℂ))
    (P.map (algebraMap ℝ ℂ)) (R.map (algebraMap ℝ ℂ)) ((algebraMap ℝ ℂ) a) ?_
    (hAB.map (Polynomial.mapRingHom (algebraMap ℝ ℂ))) ?_ ?_ ?_
  · simpa [Polynomial.map_eq_zero_iff (algebraMap ℝ ℂ).injective] using hB
  · rw [Polynomial.eval_map, ← Polynomial.aeval_def, Polynomial.aeval_algebraMap_apply]
    simpa using fun hcon => hR (by exact_mod_cast hcon)
  · rw [Polynomial.eval_map, ← Polynomial.aeval_def, Polynomial.aeval_algebraMap_apply]
    simpa using fun hcon => hP (by exact_mod_cast hcon)
  · simpa [Polynomial.derivative_map, Polynomial.map_add, Polynomial.map_sub,
      Polynomial.map_mul, Polynomial.map_pow] using hmap

/-! ## A concrete instance -/

/-- **Worked instance.**  `1/(x(x-1))` has no rational antiderivative: its pole at `0` is
simple with residue `-1`.  (Its primitive is `log(x-1) - log x`, a genuine logarithm.) -/
theorem inv_x_mul_x_sub_one_no_rational_primitive :
    ¬ ∃ A B : ℝ[X], B ≠ 0 ∧ IsCoprime A B ∧
      ∀ x : ℝ, B.eval x ≠ 0 → x * (x - 1) ≠ 0 →
        HasDerivAt (fun y : ℝ => A.eval y / B.eval y) (1 / (x * (x - 1))) x := by
  rintro ⟨A, B, hB, hAB, h⟩
  refine real_simple_pole_has_no_rational_primitive A B 1 (X - C 1) 0 hB hAB
    (by norm_num) (by norm_num) ?_
  intro x hBx hQx
  simpa using h x hBx (by simpa using hQx)

end RischLogIndep