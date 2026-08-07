/-
Copyright (c) 2026. Released under Apache 2.0 license.
-/
import Geometry.RischGaussianObstruction

/-!
# A Liouville dichotomy for one exponential extension, for every exponent

`Catalog/Geometry/RischGaussianObstruction.lean` settles the single exponent `g = x²`:
the Risch differential equation `R' + 2xR = 1` has no rational solution, so `exp(x²)` has
no antiderivative of the form `R(x)·exp(x²)`.  `Catalog/Geometry/RischResidueLiouville.lean`
settles the opposite side for `g = a·x`.

This file proves the general statement conjectured in `FUTURE_DIRECTIONS.md`
(Conjecture B), and in a sharper form: the whole analysis is carried out for an arbitrary
exponent polynomial `g` and an arbitrary right-hand side `p`.

The structural core is

* `rational_solution_gives_polynomial_solution` — **the exponential Risch differential
  equation `y' + G·y = p` has a rational solution iff it has a polynomial one.**  Any
  root of the denominator of a rational solution is impossible, by an `(X-a)`-adic
  valuation count on the Wronskian identity: the term `P·Q'` has valuation exactly
  `k - 1` while every other term has valuation `≥ k`.  Note that no hypothesis whatsoever
  is placed on `G`; this is the general "denominators are constant" step of the Risch
  algorithm for a primitive-free exponential tower of height one.

* `no_polynomial_solution_of_natDegree_lt` — a degree count: for `q ≠ 0`,
  `deg (q' + G q) = deg q + deg G ≥ deg G`, so the equation is unsolvable in polynomials
  as soon as `0 < deg p < deg G` fails downward, i.e. as soon as `deg p < deg G`.

Combining them gives `no_rational_solution_of_natDegree_lt` and, specialising
`G = g'` and `p = 1`:

* `expPoly_no_rational_primitive` — for **every** `g : ℂ[X]` with `deg g ≥ 2` the equation
  `R' + g'·R = 1` has no rational solution, and
* `exp_no_rational_exponential_primitive` — analytically over `ℝ`: for every real
  polynomial `g` of degree `≥ 2`, the function `exp (g x)` has no antiderivative of the
  shape `R(x)·exp (g x)` with `R` rational.

* `exp_linear_has_rational_exponential_primitive` — the positive half of the dichotomy:
  for `deg g = 1` such a primitive always exists, explicitly `(1/a)·exp (g x)`.

Finally `gaussian_obstruction_of_dichotomy` re-derives the previous cycle's Gaussian
theorem as a one-line corollary, confirming that this file strictly generalises it.
-/

noncomputable section

open Polynomial

namespace RischDichotomy

/-! ## Step 1: denominators of rational solutions are constant -/

/-- **No denominator root.**  If `P/Q` (in lowest terms) solves the exponential Risch
differential equation `y' + G y = p` — i.e. satisfies the Wronskian identity
`P'Q - PQ' + G P Q = p Q²` — then `Q` has no root.

The proof is a valuation count at a root `a` of multiplicity `k`: writing
`Q = (X-a)^k R` with `R(a) ≠ 0`, all of `P'Q`, `G P Q` and `p Q²` are divisible by
`(X-a)^k`, whereas `P Q'` contributes the nonzero value `k·P(a)·R(a)` in degree `k-1`.
Hence `P(a) = 0`, contradicting coprimality.  No hypothesis on `G` or `p` is used. -/
theorem denominator_has_no_root (G p P Q : ℂ[X]) (hQ : Q ≠ 0) (hco : IsCoprime P Q) (a : ℂ)
    (ha : Q.IsRoot a)
    (hid : derivative P * Q - P * derivative Q + G * P * Q = p * Q ^ 2) : False := by
  set k := Q.rootMultiplicity a with hk
  have hkpos : 0 < k := (Polynomial.rootMultiplicity_pos hQ).mpr ha
  obtain ⟨j, hj⟩ : ∃ j, k = j + 1 := ⟨k - 1, by omega⟩
  set R := Q /ₘ (X - C a) ^ k with hR
  have hQeq : Q = (X - C a) ^ (j + 1) * R := by
    have := Polynomial.pow_mul_divByMonic_rootMultiplicity_eq Q a
    rw [← hk, ← hR] at this
    simpa [hj] using this.symm
  have hR0 : R.eval a ≠ 0 := Polynomial.eval_divByMonic_pow_rootMultiplicity_ne_zero a hQ
  set U : ℂ[X] := derivative P * (X - C a) * R - C ((j : ℂ) + 1) * P * R
      - P * (X - C a) * derivative R + G * P * (X - C a) * R with hU
  have hkey : ((X - C a : ℂ[X])) ^ j * U
      = (X - C a) ^ j * ((X - C a) ^ (j + 2) * (p * R ^ 2)) := by
    have h1 : derivative P * Q - P * derivative Q + G * P * Q = (X - C a) ^ j * U := by
      rw [hQeq, hU]
      simp only [derivative_mul, derivative_pow, derivative_sub, derivative_X, derivative_C,
        sub_zero, mul_one, Nat.add_sub_cancel]
      push_cast
      ring
    have h2 : p * Q ^ 2 = (X - C a) ^ j * ((X - C a) ^ (j + 2) * (p * R ^ 2)) := by
      rw [hQeq]; ring
    rw [← h1, ← h2, hid]
  have hXne : ((X - C a : ℂ[X])) ^ j ≠ 0 := pow_ne_zero _ (Polynomial.X_sub_C_ne_zero a)
  have hU' : U = (X - C a) ^ (j + 2) * (p * R ^ 2) := mul_left_cancel₀ hXne hkey
  have h := congrArg (Polynomial.eval a) hU'
  rw [hU] at h
  simp only [eval_add, eval_sub, eval_mul, eval_X, eval_C, eval_pow, sub_self, mul_zero,
    zero_mul, zero_sub, zero_pow (Nat.succ_ne_zero (j + 1))] at h
  have hj1 : ((j : ℂ) + 1) ≠ 0 := by
    intro hcon
    have hcast : ((j : ℝ) + 1 : ℂ) = 0 := by exact_mod_cast hcon
    have hre : ((j : ℝ) + 1) = 0 := by exact_mod_cast hcast
    nlinarith [Nat.cast_nonneg (α := ℝ) j]
  have hP0 : P.eval a = 0 := by
    have hprod : ((j : ℂ) + 1) * (P.eval a * R.eval a) = 0 := by linear_combination -h
    rcases mul_eq_zero.mp hprod with h' | h'
    · exact absurd h' hj1
    · exact (mul_eq_zero.mp h').resolve_right hR0
  have hXP : (X - C a : ℂ[X]) ∣ P := (Polynomial.dvd_iff_isRoot).mpr hP0
  have hXQ : (X - C a : ℂ[X]) ∣ Q := (Polynomial.dvd_iff_isRoot).mpr ha
  exact (Polynomial.prime_X_sub_C a).not_unit (hco.isUnit_of_dvd' hXP hXQ)

/-- **Rational solutions are polynomial solutions.**  If `P/Q` in lowest terms solves
`y' + G y = p` then the equation already has a *polynomial* solution.  This is the
denominator-elimination step of the Risch algorithm for a height-one exponential tower,
here proved with no hypothesis at all on `G` and `p`. -/
theorem rational_solution_gives_polynomial_solution (G p P Q : ℂ[X]) (hQ : Q ≠ 0)
    (hco : IsCoprime P Q)
    (hid : derivative P * Q - P * derivative Q + G * P * Q = p * Q ^ 2) :
    ∃ q : ℂ[X], derivative q + G * q = p := by
  have hdeg : Q.natDegree = 0 := by
    by_contra hdeg
    obtain ⟨a, ha⟩ := IsAlgClosed.exists_root Q (fun hdz =>
      hdeg (Polynomial.natDegree_eq_zero_iff_degree_le_zero.mpr (le_of_eq hdz)))
    exact denominator_has_no_root G p P Q hQ hco a ha hid
  obtain ⟨c, rfl⟩ : ∃ c, Q = C c := ⟨Q.coeff 0, Polynomial.eq_C_of_natDegree_eq_zero hdeg⟩
  have hc : c ≠ 0 := fun h => hQ (by simp [h])
  have hCc : (C c : ℂ[X]) ≠ 0 := by simpa using hc
  refine ⟨C c⁻¹ * P, ?_⟩
  have hid' : derivative P * C c + G * P * C c = p * C c ^ 2 := by simpa using hid
  have key : derivative P + G * P = p * C c :=
    mul_left_cancel₀ hCc (by linear_combination hid')
  have expand : derivative (C c⁻¹ * P) + G * (C c⁻¹ * P)
      = C c⁻¹ * (derivative P + G * P) := by
    simp only [derivative_C_mul]
    ring
  rw [expand, key, ← mul_assoc, mul_comm (C c⁻¹) p, mul_assoc, ← C_mul,
    inv_mul_cancel₀ hc, C_1, mul_one]

/-! ## Step 2: the degree count -/

/-- The exact degree of the left-hand side of the Risch differential equation: for
`q ≠ 0` and `deg G ≥ 1`, the term `G q` dominates `q'`. -/
theorem natDegree_risch_lhs (G q : ℂ[X]) (hq : q ≠ 0) (hG : 0 < G.natDegree) :
    (derivative q + G * q).natDegree = G.natDegree + q.natDegree := by
  have hG0 : G ≠ 0 := fun h => by simp [h] at hG
  have hmul : (G * q).natDegree = G.natDegree + q.natDegree := natDegree_mul hG0 hq
  have hlt : (derivative q).natDegree < (G * q).natDegree := by
    have := Polynomial.natDegree_derivative_le q
    omega
  rw [natDegree_add_eq_right_of_natDegree_lt hlt, hmul]

/-- **No polynomial solution below the degree threshold.**  If `p ≠ 0` has degree strictly
smaller than `G`, the equation `y' + G y = p` has no polynomial solution. -/
theorem no_polynomial_solution_of_natDegree_lt (G p : ℂ[X]) (hp : p ≠ 0)
    (hlt : p.natDegree < G.natDegree) (q : ℂ[X]) : derivative q + G * q ≠ p := by
  intro h
  have hG : 0 < G.natDegree := lt_of_le_of_lt (Nat.zero_le _) hlt
  rcases eq_or_ne q 0 with rfl | hq
  · exact hp (by simpa using h.symm)
  · have := natDegree_risch_lhs G q hq hG
    rw [h] at this
    omega

/-- **No rational solution below the degree threshold.**  Combining the two steps: for
`p ≠ 0` of degree `< deg G`, the Risch differential equation `y' + G y = p` has no
rational solution at all. -/
theorem no_rational_solution_of_natDegree_lt (G p P Q : ℂ[X]) (hp : p ≠ 0)
    (hlt : p.natDegree < G.natDegree) (hQ : Q ≠ 0) (hco : IsCoprime P Q)
    (hid : derivative P * Q - P * derivative Q + G * P * Q = p * Q ^ 2) : False := by
  obtain ⟨q, hq⟩ := rational_solution_gives_polynomial_solution G p P Q hQ hco hid
  exact no_polynomial_solution_of_natDegree_lt G p hp hlt q hq

/-! ## Step 3: specialisation to `G = g'`, `p = 1` -/

/-- The derivative of a polynomial of degree `≥ 1` has degree exactly one less. -/
theorem natDegree_derivative_of_pos {R : Type*} [CommRing R] [IsAddTorsionFree R]
    (g : R[X]) (hg : 0 < g.natDegree) :
    (derivative g).natDegree = g.natDegree - 1 :=
  natDegree_eq_of_degree_eq_some (Polynomial.degree_derivative_eq g hg)

/-- **Every exponent of degree `≥ 2` obstructs.**  For `g : ℂ[X]` with `deg g ≥ 2`, the
Risch differential equation `R' + g'·R = 1` attached to `exp (g x)` has no rational
solution.  Taking `g = X²` recovers the Gaussian case of the previous cycle. -/
theorem expPoly_no_rational_primitive (g P Q : ℂ[X]) (hg : 2 ≤ g.natDegree) (hQ : Q ≠ 0)
    (hco : IsCoprime P Q)
    (hid : derivative P * Q - P * derivative Q + derivative g * P * Q = Q ^ 2) : False := by
  refine no_rational_solution_of_natDegree_lt (derivative g) 1 P Q one_ne_zero ?_ hQ hco
    (by simpa using hid)
  rw [natDegree_derivative_of_pos g (by omega), natDegree_one]
  omega

/-! ## Step 4: the analytic statement over `ℝ` -/

/-- A rational primitive `R(x)·exp (g x)` of `p(x)·exp (g x)` forces the Wronskian
identity `P'Q - PQ' + g'PQ = p Q²`. -/
theorem exp_wronskian_identity (g p P Q : ℝ[X]) (hQ : Q ≠ 0)
    (h : ∀ x : ℝ, Q.eval x ≠ 0 →
      HasDerivAt (fun y : ℝ => (P.eval y / Q.eval y) * Real.exp (g.eval y))
        (p.eval x * Real.exp (g.eval x)) x) :
    derivative P * Q - P * derivative Q + derivative g * P * Q = p * Q ^ 2 := by
  have hzero : derivative P * Q - P * derivative Q + derivative g * P * Q - p * Q ^ 2 = 0 := by
    refine Polynomial.eq_zero_of_infinite_isRoot _ (Set.Infinite.mono ?_
      ((Set.infinite_univ (α := ℝ)).diff (Polynomial.finite_setOf_isRoot hQ)))
    rintro x ⟨-, hQx⟩
    have hQx' : Q.eval x ≠ 0 := hQx
    have hexp : HasDerivAt (fun y : ℝ => Real.exp (g.eval y))
        (Real.exp (g.eval x) * (derivative g).eval x) x := by
      simpa [mul_comm] using (g.hasDerivAt x).exp
    have hd := ((P.hasDerivAt x).div (Q.hasDerivAt x) hQx').mul hexp
    have heq := (h x hQx').unique hd
    have hE : Real.exp (g.eval x) ≠ 0 := Real.exp_ne_zero _
    simp only [Pi.div_apply] at heq
    simp only [Set.mem_setOf_eq, IsRoot.def, eval_sub, eval_add, eval_mul, eval_pow]
    have hmul : ((((derivative P).eval x * Q.eval x - P.eval x * (derivative Q).eval x)
          / Q.eval x ^ 2) + (P.eval x / Q.eval x) * (derivative g).eval x)
        * Real.exp (g.eval x) = p.eval x * Real.exp (g.eval x) := by
      linear_combination -heq
    have hcancel := mul_right_cancel₀ hE hmul
    field_simp at hcancel
    linarith [hcancel]
  exact sub_eq_zero.mp hzero

/-- **The negative half of the Liouville dichotomy, analytically.**  If `p ≠ 0` has degree
strictly below `deg g - 1`, then `x ↦ p(x)·exp (g x)` has **no** antiderivative of the
form `R(x)·exp (g x)` with `R` a rational function. -/
theorem expPoly_no_rational_exponential_primitive (g p P Q : ℝ[X]) (hp : p ≠ 0)
    (hg : p.natDegree + 1 < g.natDegree) (hQ : Q ≠ 0) (hco : IsCoprime P Q)
    (h : ∀ x : ℝ, Q.eval x ≠ 0 →
      HasDerivAt (fun y : ℝ => (P.eval y / Q.eval y) * Real.exp (g.eval y))
        (p.eval x * Real.exp (g.eval x)) x) :
    False := by
  have hid := exp_wronskian_identity g p P Q hQ h
  have hdegmap : ∀ r : ℝ[X], (r.map (algebraMap ℝ ℂ)).natDegree = r.natDegree :=
    fun r => Polynomial.natDegree_map_eq_of_injective (algebraMap ℝ ℂ).injective r
  refine no_rational_solution_of_natDegree_lt (derivative (g.map (algebraMap ℝ ℂ)))
    (p.map (algebraMap ℝ ℂ)) (P.map (algebraMap ℝ ℂ)) (Q.map (algebraMap ℝ ℂ)) ?_ ?_ ?_
    (hco.map (Polynomial.mapRingHom (algebraMap ℝ ℂ))) ?_
  · simpa [Polynomial.map_eq_zero_iff (algebraMap ℝ ℂ).injective] using hp
  · rw [natDegree_derivative_of_pos _ (by rw [hdegmap]; omega), hdegmap, hdegmap]
    omega
  · simpa [Polynomial.map_eq_zero_iff (algebraMap ℝ ℂ).injective] using hQ
  · have hmap := congrArg (Polynomial.map (algebraMap ℝ ℂ)) hid
    simpa [Polynomial.derivative_map, Polynomial.map_add, Polynomial.map_sub,
      Polynomial.map_mul, Polynomial.map_pow] using hmap

/-- The special case `p = 1`: for every real polynomial `g` of degree at least `2`, the
function `x ↦ exp (g x)` has no antiderivative of the shape `R(x)·exp (g x)`. -/
theorem exp_no_rational_exponential_primitive (g P Q : ℝ[X]) (hg : 2 ≤ g.natDegree)
    (hQ : Q ≠ 0) (hco : IsCoprime P Q)
    (h : ∀ x : ℝ, Q.eval x ≠ 0 →
      HasDerivAt (fun y : ℝ => (P.eval y / Q.eval y) * Real.exp (g.eval y))
        (Real.exp (g.eval x)) x) :
    False :=
  expPoly_no_rational_exponential_primitive g 1 P Q one_ne_zero
    (by simpa using hg) hQ hco (by simpa using h)

/-- **The positive half of the dichotomy.**  For a degree-one exponent `g = a·x + b` with
`a ≠ 0`, the primitive `(1/a)·exp (g x)` exists and is of the required rational-times-
exponential shape. -/
theorem exp_linear_has_rational_exponential_primitive (a b : ℝ) (ha : a ≠ 0) (x : ℝ) :
    HasDerivAt (fun y : ℝ => ((C a⁻¹ : ℝ[X]).eval y / (1 : ℝ[X]).eval y) *
        Real.exp ((C a * X + C b : ℝ[X]).eval y))
      (Real.exp ((C a * X + C b : ℝ[X]).eval x)) x := by
  have hlin : HasDerivAt (fun y : ℝ => a * y + b) a x := by
    simpa using ((hasDerivAt_id x).const_mul a).add_const b
  have hexp : HasDerivAt (fun y : ℝ => Real.exp (a * y + b)) (Real.exp (a * x + b) * a) x :=
    hlin.exp
  have := hexp.const_mul a⁻¹
  simp only [eval_add, eval_mul, eval_C, eval_X, eval_one, div_one]
  convert this using 1
  field_simp

/-- The previous cycle's Gaussian obstruction is the special case `g = X²`, showing that
this file strictly generalises `RischGaussian.no_rational_solution_gaussian`. -/
theorem gaussian_obstruction_of_dichotomy (P Q : ℂ[X]) (hQ : Q ≠ 0) (hco : IsCoprime P Q)
    (hid : derivative P * Q - P * derivative Q + C 2 * X * P * Q = Q ^ 2) : False := by
  have hd : derivative (X ^ 2 : ℂ[X]) = C 2 * X := by
    rw [derivative_X_pow]
    norm_num
  refine expPoly_no_rational_primitive (X ^ 2) P Q (by simp) hQ hco ?_
  rw [hd]
  exact hid

/-! ## Sharpness of the degree hypothesis -/

/-- **The degree gap cannot be closed.**  For `p = g'` — the extremal case
`deg p + 1 = deg g` excluded by `expPoly_no_rational_exponential_primitive` — the function
`p(x)·exp (g x)` *does* have a rational-times-exponential primitive, namely `exp (g x)`
itself (the rational factor being `1`).  So the hypothesis `deg p + 1 < deg g` is sharp. -/
theorem degree_hypothesis_sharp (g : ℝ[X]) (hg : 0 < g.natDegree) :
    derivative g ≠ 0 ∧ (derivative g).natDegree + 1 = g.natDegree ∧
      ∀ x : ℝ, HasDerivAt
        (fun y : ℝ => ((1 : ℝ[X]).eval y / (1 : ℝ[X]).eval y) * Real.exp (g.eval y))
        ((derivative g).eval x * Real.exp (g.eval x)) x := by
  refine ⟨?_, ?_, fun x => ?_⟩
  · intro h0
    have hd := Polynomial.degree_derivative_eq g hg
    rw [h0, degree_zero] at hd
    simp at hd
  · rw [natDegree_derivative_of_pos g hg]
    omega
  · have hexp : HasDerivAt (fun y : ℝ => Real.exp (g.eval y))
        (Real.exp (g.eval x) * (derivative g).eval x) x := by
      simpa [mul_comm] using (g.hasDerivAt x).exp
    simpa [mul_comm] using hexp

/-! ## A concrete instance -/

/-- **Worked instance.**  `exp(x³)` has no antiderivative of the form `R(x)·exp(x³)`
with `R` a rational function.  (Degree `3` is outside the reach of the previous cycle,
which only covered `x²`.) -/
theorem exp_cube_no_rational_exponential_primitive :
    ¬ ∃ P Q : ℝ[X], Q ≠ 0 ∧ IsCoprime P Q ∧
      ∀ x : ℝ, Q.eval x ≠ 0 →
        HasDerivAt (fun y : ℝ => (P.eval y / Q.eval y) * Real.exp (y ^ 3))
          (Real.exp (x ^ 3)) x := by
  rintro ⟨P, Q, hQ, hco, h⟩
  refine exp_no_rational_exponential_primitive (X ^ 3) P Q ?_ hQ hco ?_
  · simp
  · simpa using h

end RischDichotomy