/-
# From separated principal filtrations to non-archimedean geometry

A separated principal filtration is precisely what is needed to turn the `a`-adic order
`x ↦ multiplicity a x` into an honest `ℕ`-valued valuation.  This file makes that
passage explicit and pushes it into two neighbouring domains:

* **Algebra → analysis.**  For a *prime* element `a` of a domain whose principal
  filtration is separated, `‖x‖ₐ = 2^(-ord_a x)` is a genuine non-archimedean
  `AbsoluteValue R ℝ` (`adicAbsoluteValue`), satisfying the strong triangle inequality
  `‖x + y‖ₐ ≤ max ‖x‖ₐ ‖y‖ₐ`.
* **Algebra → topology.**  Separation is exactly the Hausdorff axiom for the
  `a`-adic topology: `IsHausdorff (span {a}) R`, hence `T2Space R` for the adic
  topology (`t2Space_adicTopology`).

Everything is stated for the general setting of `SeparatedPrincipalFiltration.lean`,
so it applies verbatim to `ℤ` at `2`, to `k[X]` at `X`, and to any Noetherian domain or
UFD at any prime — while failing, as it must, in `ℤ + X·ℚ[X]` at `2`.
-/
import Mathlib
import Shared.SeparatedPrincipalFiltration

namespace SeparatedPrincipalFiltration

variable {R : Type*} [CommRing R]

/-! ## The `a`-adic order of a nonzero element -/

/-- The `a`-adic order of `x`, i.e. the exponent of the largest power of `a` dividing
`x`.  It is meaningful exactly when the principal filtration at `a` is separated. -/
noncomputable def ord (a x : R) : ℕ := multiplicity a x

lemma finite_of_isSeparated {a : R} (h : IsSeparated a) {x : R} (hx : x ≠ 0) :
    FiniteMultiplicity a x := isSeparated_iff_finiteMultiplicity.mp h x hx

lemma pow_ord_dvd {a : R} (h : IsSeparated a) {x : R} (hx : x ≠ 0) : a ^ ord a x ∣ x :=
  (finite_of_isSeparated h hx).pow_dvd_iff_le_multiplicity.mpr le_rfl

lemma not_pow_succ_ord_dvd {a : R} (h : IsSeparated a) {x : R} (hx : x ≠ 0) :
    ¬ a ^ (ord a x + 1) ∣ x := by
  intro hdvd
  have := (finite_of_isSeparated h hx).le_multiplicity_of_pow_dvd hdvd
  simp only [ord] at this
  omega

lemma le_ord_iff {a : R} (h : IsSeparated a) {x : R} (hx : x ≠ 0) {k : ℕ} :
    k ≤ ord a x ↔ a ^ k ∣ x :=
  (finite_of_isSeparated h hx).pow_dvd_iff_le_multiplicity.symm

/-- Additivity of the order on products: the `a`-adic order is a valuation whenever `a`
is prime. -/
theorem ord_mul [IsDomain R] {a : R} (h : IsSeparated a) (hp : Prime a) {x y : R} (hx : x ≠ 0)
    (hy : y ≠ 0) : ord a (x * y) = ord a x + ord a y :=
  multiplicity_mul hp (finite_of_isSeparated h (mul_ne_zero hx hy))

/-- The strong (ultrametric) inequality for the order. -/
theorem min_le_ord_add {a : R} (h : IsSeparated a) {x y : R} (hx : x ≠ 0) (hy : y ≠ 0)
    (hxy : x + y ≠ 0) : min (ord a x) (ord a y) ≤ ord a (x + y) := by
  rw [le_ord_iff h hxy]
  exact dvd_add ((le_ord_iff h hx).mp (min_le_left _ _))
    ((le_ord_iff h hy).mp (min_le_right _ _))

/-- The order of `a` itself is `1`. -/
theorem ord_self [IsDomain R] (a : R) : ord a a = 1 := multiplicity_self

/-! ## The `a`-adic absolute value -/

open Classical in
/-- The `a`-adic absolute value `‖x‖ₐ = 2^(-ord_a x)`, with `‖0‖ₐ = 0`. -/
noncomputable def adicAbs (a x : R) : ℝ := if x = 0 then 0 else (2 : ℝ) ^ (-(ord a x : ℤ))

@[simp] lemma adicAbs_zero (a : R) : adicAbs a 0 = 0 := by simp [adicAbs]

lemma adicAbs_of_ne_zero {a x : R} (hx : x ≠ 0) :
    adicAbs a x = (2 : ℝ) ^ (-(ord a x : ℤ)) := by simp [adicAbs, hx]

lemma adicAbs_pos {a x : R} (hx : x ≠ 0) : 0 < adicAbs a x := by
  rw [adicAbs_of_ne_zero hx]
  positivity

lemma adicAbs_nonneg (a x : R) : 0 ≤ adicAbs a x := by
  rcases eq_or_ne x 0 with rfl | hx
  · simp
  · exact (adicAbs_pos hx).le

lemma adicAbs_eq_zero_iff {a x : R} : adicAbs a x = 0 ↔ x = 0 := by
  refine ⟨fun h => ?_, fun h => by simp [h]⟩
  by_contra hx
  exact absurd h (adicAbs_pos hx).ne'

/-- Multiplicativity: the `a`-adic absolute value is a monoid homomorphism. -/
theorem adicAbs_mul [IsDomain R] {a : R} (h : IsSeparated a) (hp : Prime a) (x y : R) :
    adicAbs a (x * y) = adicAbs a x * adicAbs a y := by
  rcases eq_or_ne x 0 with rfl | hx
  · simp
  rcases eq_or_ne y 0 with rfl | hy
  · simp
  rw [adicAbs_of_ne_zero (mul_ne_zero hx hy), adicAbs_of_ne_zero hx, adicAbs_of_ne_zero hy,
    ord_mul h hp hx hy]
  push_cast
  rw [← zpow_add₀ (by norm_num : (2:ℝ) ≠ 0)]
  ring_nf

/-- **Strong triangle inequality.**  Separation makes the `a`-adic absolute value
non-archimedean. -/
theorem adicAbs_add_le_max {a : R} (h : IsSeparated a) (x y : R) :
    adicAbs a (x + y) ≤ max (adicAbs a x) (adicAbs a y) := by
  rcases eq_or_ne x 0 with rfl | hx
  · simp [adicAbs_nonneg]
  rcases eq_or_ne y 0 with rfl | hy
  · simp [adicAbs_nonneg]
  rcases eq_or_ne (x + y) 0 with hxy | hxy
  · simp [hxy, adicAbs_nonneg]
  have hmin := min_le_ord_add h hx hy hxy
  rw [adicAbs_of_ne_zero hxy, adicAbs_of_ne_zero hx, adicAbs_of_ne_zero hy]
  rcases le_total (ord a x) (ord a y) with hle | hle
  · refine le_trans ?_ (le_max_left _ _)
    apply zpow_le_zpow_right₀ (by norm_num : (1:ℝ) ≤ 2)
    simp only [min_eq_left hle] at hmin
    omega
  · refine le_trans ?_ (le_max_right _ _)
    apply zpow_le_zpow_right₀ (by norm_num : (1:ℝ) ≤ 2)
    simp only [min_eq_right hle] at hmin
    omega

theorem adicAbs_add_le {a : R} (h : IsSeparated a) (x y : R) :
    adicAbs a (x + y) ≤ adicAbs a x + adicAbs a y := by
  refine (adicAbs_add_le_max h x y).trans ?_
  rcases le_total (adicAbs a x) (adicAbs a y) with hle | hle
  · rw [max_eq_right hle]
    linarith [adicAbs_nonneg a x]
  · rw [max_eq_left hle]
    linarith [adicAbs_nonneg a y]

/-- **The `a`-adic absolute value.**  For a prime element with separated principal
filtration, `x ↦ 2^(-ord_a x)` is an absolute value on the domain `R`; this is the
bridge from the purely ideal-theoretic separation statement to non-archimedean
analysis. -/
noncomputable def adicAbsoluteValue [IsDomain R] {a : R} (h : IsSeparated a) (hp : Prime a) :
    AbsoluteValue R ℝ where
  toFun := adicAbs a
  map_mul' := adicAbs_mul h hp
  nonneg' := adicAbs_nonneg a
  eq_zero' _ := adicAbs_eq_zero_iff
  add_le' := adicAbs_add_le h

@[simp] lemma adicAbsoluteValue_apply [IsDomain R] {a : R} (h : IsSeparated a) (hp : Prime a) (x : R) :
    adicAbsoluteValue h hp x = adicAbs a x := rfl

/-- The absolute value is non-archimedean, i.e. it is bounded on the image of `ℕ` by `1`
in the strong sense of the ultrametric inequality. -/
theorem adicAbsoluteValue_nonarchimedean [IsDomain R] {a : R} (h : IsSeparated a) (hp : Prime a)
    (x y : R) : adicAbsoluteValue h hp (x + y) ≤
      max (adicAbsoluteValue h hp x) (adicAbsoluteValue h hp y) :=
  adicAbs_add_le_max h x y

/-- The value `‖a‖ₐ = 1/2` is strictly between `0` and `1`: the filtration really does
shrink. -/
theorem adicAbs_self [IsDomain R] {a : R} (ha : a ≠ 0) : adicAbs a a = 1 / 2 := by
  rw [adicAbs_of_ne_zero ha, ord_self]
  norm_num

/-! ## The topological face of separation -/

/-- Separation of the principal filtration is exactly the Hausdorff property for the
`a`-adic filtration in the sense of `IsHausdorff`. -/
theorem isHausdorff_span_of_isSeparated {a : R} (h : IsSeparated a) :
    IsHausdorff (Ideal.span {a}) R := by
  rw [isHausdorff_iff]
  intro x hx
  refine h.eq_zero fun n => ?_
  have hxn := hx n
  rw [SModEq.zero] at hxn
  simpa [smul_eq_mul, Ideal.mul_top, Ideal.span_singleton_pow, Ideal.mem_span_singleton]
    using hxn

/-- Conversely, `IsHausdorff` for the principal ideal gives back separation. -/
theorem isSeparated_of_isHausdorff {a : R} (h : IsHausdorff (Ideal.span {a}) R) :
    IsSeparated a := by
  refine isSeparated_iff.mpr fun x hx => ?_
  refine h.haus x fun n => ?_
  rw [SModEq.zero]
  simpa [smul_eq_mul, Ideal.mul_top, Ideal.span_singleton_pow, Ideal.mem_span_singleton]
    using hx n

theorem isSeparated_iff_isHausdorff {a : R} :
    IsSeparated a ↔ IsHausdorff (Ideal.span {a}) R :=
  ⟨isHausdorff_span_of_isSeparated, isSeparated_of_isHausdorff⟩

/-- **Algebra → topology.**  In a domain with well-founded divisibility, the `a`-adic
topology attached to any non-unit `a` is Hausdorff. -/
theorem t2Space_adicTopology [IsDomain R] [WfDvdMonoid R] {a : R} (ha : ¬ IsUnit a) :
    @T2Space R ((Ideal.span {a}).adicTopology) := by
  letI := (Ideal.span {a}).adicTopology
  have hadic : IsAdic (Ideal.span {a}) := rfl
  exact hadic.isHausdorff_iff.mp (isHausdorff_span_of_isSeparated
    (isSeparated_of_not_isUnit ha))

/-! ## The classical instances -/

/-- The `2`-adic absolute value on `ℤ`, obtained from the general machine. -/
noncomputable def intTwoAdicAbs : AbsoluteValue ℤ ℝ :=
  adicAbsoluteValue int_two_isSeparated Int.prime_two

@[simp] theorem intTwoAdicAbs_two : intTwoAdicAbs 2 = 1 / 2 :=
  adicAbs_self (by norm_num : (2:ℤ) ≠ 0)

theorem intTwoAdicAbs_ultrametric (x y : ℤ) :
    intTwoAdicAbs (x + y) ≤ max (intTwoAdicAbs x) (intTwoAdicAbs y) :=
  adicAbs_add_le_max int_two_isSeparated x y

/-- The `X`-adic absolute value on `k[X]` for a field `k`. -/
noncomputable def polyXAdicAbs (k : Type*) [Field k] : AbsoluteValue (Polynomial k) ℝ :=
  adicAbsoluteValue polynomial_X_isSeparated (Polynomial.prime_X)

theorem polyXAdicAbs_X (k : Type*) [Field k] :
    polyXAdicAbs k Polynomial.X = 1 / 2 :=
  adicAbs_self Polynomial.X_ne_zero

end SeparatedPrincipalFiltration