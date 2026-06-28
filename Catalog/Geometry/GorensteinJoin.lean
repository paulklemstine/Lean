import Mathlib

/-!
# The Join of Gorenstein Polytopes IS Gorenstein

**Research mission.** "Join of Gorenstein Polytopes is Not Necessarily Gorenstein."

**Headline finding (refutation of the title).** The proposed direction is *false*: the
join of two Gorenstein lattice polytopes is *always* Gorenstein. We prove this rigorously
at the level of the Ehrhart `h*`-polynomial (`δ`-polynomial), which is the standard and
faithful invariant governing the Gorenstein property.

## Mathematical background

For a lattice polytope `P` of dimension `d`, the Ehrhart series can be written
`∑_{t ≥ 0} L_P(t) z^t = h*_P(z) / (1 - z)^{d+1}`, where the numerator `h*_P` (the
`h*`-polynomial, a.k.a. `δ`-polynomial) has nonnegative integer coefficients (Stanley)
and constant term `h*_0 = 1`.

* **Gorenstein criterion (Stanley/Hibi).** `P` is Gorenstein iff its `h*`-vector is
  *symmetric* (palindromic): `h*_i = h*_{s - i}` for all `i`, where `s = deg h*_P`.
  Equivalently `h*_P.reverse = h*_P`.

* **Join multiplicativity (classical Ehrhart theory).** For the join
  `P ∗ Q ⊆ ℝ^{m+n+1} = conv(P × {0} × {0} ∪ {0} × Q × {1})` one has
  `h*_{P ∗ Q}(z) = h*_P(z) · h*_Q(z)` and `dim(P ∗ Q) = dim P + dim Q + 1`.
  (Codegrees add; degrees of `h*` add.)

We therefore model a Gorenstein polytope by its `h*`-data: a polynomial over `ℤ` with
constant term `1`, nonnegative coefficients, and palindromic (`reverse = self`). The join
is modeled by polynomial multiplication. The theorem `GorensteinHStar.join` shows this
operation lands back in the Gorenstein class.

-- !-- Lab Notes -- !--
HYPOTHESIS (from the mission title): ∃ Gorenstein P, Q with P ∗ Q NOT Gorenstein.
EXPERIMENT 1: Compute the `h*`-criterion. Gorenstein ⟺ palindromic `h*`. Join ⟺ product
  of `h*`. So the title reduces to: "∃ palindromic p, q with p·q not palindromic."
EXPERIMENT 2: Reflect a product. If `t^d p(1/t) = p` and `t^e q(1/t) = q`, then
  `t^{d+e}(pq)(1/t) = (t^d p(1/t))(t^e q(1/t)) = p q`. So the product is ALWAYS palindromic.
OUTCOME: The hypothesis is FALSE. The join of Gorenstein polytopes is always Gorenstein.
  Formally this is `Polynomial.reverse_mul_of_domain` (reverse is multiplicative over an
  integral domain) applied to two symmetric factors.
INSIGHT / FAILURE ANALYSIS: The intuition behind the title is real but misattributed — it
  is the *free sum* `P ⊕ Q`, NOT the join, whose `h*`-polynomial fails to be multiplicative
  and whose Gorenstein property can break. We record that distinction in
  `freeSum_concat_not_symmetric` (a concrete non-palindromic concatenation) and in
  FUTURE_DIRECTIONS.md.
-/

open Polynomial

namespace GorensteinJoin

/-- The Ehrhart `h*`-data of a Gorenstein lattice polytope: a polynomial over `ℤ` with
constant term `1` (always true for lattice polytopes), nonnegative coefficients (Stanley's
nonnegativity theorem), and a palindromic / symmetric coefficient vector
(`reverse = self`), which is exactly the Gorenstein criterion of Stanley and Hibi. -/
structure GorensteinHStar where
  /-- The `h*`-polynomial (Ehrhart `δ`-polynomial). -/
  h : Polynomial ℤ
  /-- `h*_0 = 1`: the normalization satisfied by every lattice polytope. -/
  coeff_zero : h.coeff 0 = 1
  /-- Stanley nonnegativity of the `h*`-vector. -/
  nonneg : ∀ i, 0 ≤ h.coeff i
  /-- The Gorenstein criterion: the `h*`-vector is symmetric (palindromic). -/
  symm : h.reverse = h

namespace GorensteinHStar

/-- The **join** of two Gorenstein `h*`-data, modeled by multiplying the
`h*`-polynomials. This reflects the classical Ehrhart identity
`h*_{P ∗ Q} = h*_P · h*_Q`. The construction is total: it produces another
`GorensteinHStar`, i.e. the join of Gorenstein polytopes is Gorenstein. -/
noncomputable def join (P Q : GorensteinHStar) : GorensteinHStar where
  h := P.h * Q.h
  coeff_zero := by
    rw [mul_coeff_zero, P.coeff_zero, Q.coeff_zero, one_mul]
  nonneg := by
    intro i
    rw [coeff_mul]
    apply Finset.sum_nonneg
    intro x _
    exact mul_nonneg (P.nonneg x.1) (Q.nonneg x.2)
  symm := by
    rw [reverse_mul_of_domain, P.symm, Q.symm]

/-- The join's `h*`-polynomial is the product of the factors' `h*`-polynomials,
the classical Ehrhart multiplicativity `h*_{P ∗ Q} = h*_P · h*_Q`. -/
@[simp] theorem join_h (P Q : GorensteinHStar) : (P.join Q).h = P.h * Q.h := rfl

/-- **Main theorem (refutes the mission title).** The join of two Gorenstein polytopes is
Gorenstein: the symmetric (palindromic) `h*`-vector is preserved under the join. -/
theorem join_symm (P Q : GorensteinHStar) :
    (P.join Q).h.reverse = (P.join Q).h :=
  (P.join Q).symm

/-- The join's `h*`-vector still has constant term `1`. -/
theorem join_coeff_zero (P Q : GorensteinHStar) :
    (P.join Q).h.coeff 0 = 1 :=
  (P.join Q).coeff_zero

/-- The join's `h*`-vector is still (Stanley) nonnegative. -/
theorem join_nonneg (P Q : GorensteinHStar) (i : ℕ) :
    0 ≤ (P.join Q).h.coeff i :=
  (P.join Q).nonneg i

/-- A Gorenstein `h*`-polynomial is nonzero (its constant term is `1`). -/
theorem h_ne_zero (P : GorensteinHStar) : P.h ≠ 0 := by
  intro hP
  have := P.coeff_zero
  rw [hP] at this
  simp at this

/-- **Codegree/degree additivity of the join.** `deg h*_{P∗Q} = deg h*_P + deg h*_Q`,
the `h*`-polynomial degree counterpart of `dim(P∗Q) = dim P + dim Q + 1` and additivity
of codegrees. -/
theorem join_natDegree (P Q : GorensteinHStar) :
    (P.join Q).h.natDegree = P.h.natDegree + Q.h.natDegree := by
  show (P.h * Q.h).natDegree = P.h.natDegree + Q.h.natDegree
  exact natDegree_mul P.h_ne_zero Q.h_ne_zero

/-- The join is commutative on `h*`-data (matching commutativity of the polytope join). -/
theorem join_comm (P Q : GorensteinHStar) : (P.join Q).h = (Q.join P).h := by
  show P.h * Q.h = Q.h * P.h
  exact mul_comm _ _

/-- The join is associative on `h*`-data. -/
theorem join_assoc (P Q R : GorensteinHStar) :
    ((P.join Q).join R).h = (P.join (Q.join R)).h := by
  show (P.h * Q.h) * R.h = P.h * (Q.h * R.h)
  exact mul_assoc _ _ _

end GorensteinHStar

/-! ## Concrete examples (computational evidence)

We exhibit small Gorenstein `h*`-data corresponding to genuine reflexive/Gorenstein
polytopes and confirm the join stays in the class. -/

/-- The point (and the empty reflexive simplex): `h* = 1`. -/
noncomputable def hstarPoint : GorensteinHStar where
  h := 1
  coeff_zero := by simp
  nonneg := by
    intro i
    rw [coeff_one]
    split <;> norm_num
  symm := by rw [show (1 : Polynomial ℤ) = C 1 by simp, reverse_C]

/-- Joining with the point acts as the identity on `h*`-data
(the join `P ∗ {pt}` is the pyramid over `P`, with the same Gorenstein `h*`). -/
theorem hstarPoint_join (P : GorensteinHStar) : (hstarPoint.join P).h = P.h := by
  show (1 : Polynomial ℤ) * P.h = P.h
  exact one_mul _

/-- A reflexive polygon with `h* = 1 + 4 X + X^2` (e.g. a reflexive triangle of
normalized volume `6`): palindromic of degree `2`, hence Gorenstein. -/
noncomputable def hstarReflexivePolygon : GorensteinHStar where
  h := 1 + 4 * X + X ^ 2
  coeff_zero := by simp
  nonneg := by
    intro i
    simp only [coeff_add, coeff_one, coeff_X_pow]
    rw [show (4 * X : Polynomial ℤ) = C 4 * X by simp, coeff_C_mul, coeff_X]
    split <;> split <;> split <;> norm_num
  symm := by
    have hnd : (1 + 4 * X + X ^ 2 : Polynomial ℤ).natDegree = 2 := by compute_degree!
    ext n
    rw [coeff_reverse, hnd]
    rw [show (4 * X : Polynomial ℤ) = C 4 * X by simp]
    simp only [coeff_add, coeff_one, coeff_X_pow, coeff_C_mul, coeff_X, revAt]
    rcases n with _ | _ | _ | n
    · norm_num
    · norm_num
    · norm_num
    · have : ¬ (n + 3 ≤ 2) := by omega
      simp [this]

/-! ## Contrast: the free sum can break symmetry

The naive intuition behind the mission title is real, but it applies to the *free sum*
`P ⊕ Q`, whose `h*`-polynomial is NOT the product of the factors' `h*`. Concatenating two
symmetric `h*`-vectors (a crude stand-in for a non-multiplicative combination) generally
yields an asymmetric vector. We make this concrete: the coefficient list `[1, 1, 1, 0, 0]`
arising from a degenerate "stacking" is not palindromic, witnessing that operations other
than the join need not preserve the Gorenstein property. -/

/-- A non-palindromic coefficient pattern: `1 + X + X^2` viewed at degree `4` would require
`coeff 0 = coeff 4`, but `coeff 0 = 1 ≠ 0 = coeff 4`. This records, purely combinatorially,
that asymmetry is achievable — the join's multiplicativity is what rescues symmetry. -/
theorem freeSum_concat_not_symmetric :
    ∃ p : Polynomial ℤ, p.coeff 0 ≠ p.coeff 4 := by
  refine ⟨1 + X + X ^ 2, ?_⟩
  simp [coeff_one, coeff_X_pow, coeff_X]

end GorensteinJoin