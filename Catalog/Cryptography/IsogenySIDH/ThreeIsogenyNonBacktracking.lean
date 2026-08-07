/-
# Non-backtracking and the radical obstruction for Montgomery 3-isogenies

`ThreeIsogenyMontgomery` uniformised the Montgomery 3-isogeny by the kernel
abscissa `r`: the source is `mont3Source r`, the target is `mont3Target r`, and
the two `j`-invariants are a zero of `Φ₃`.  To *iterate* the construction one
must choose a point of order three on the target, i.e. a root of
`threeDivPoly (mont3Target r) X`.  This file analyses that quartic completely.

* `threeDual_kernel` — `X = -1/(3r)` is always a root: it is the kernel of the
  dual isogeny, so this is the backtracking choice.  (This is the `ℓ = 3`
  analogue of `radTwoIso_two_torsion_image` in `RadicalWalkStructure`.)
* `threeDivPoly_target_factor` — the quartic factors *over the base field* as
  `r · threeDivPoly (mont3Target r) X = (3rX + 1) · threeNextKernelPoly r X`
  with the explicit residual cubic
  `threeNextKernelPoly r X = X³ + 3r(2 - 3r²)X² + 3r²X - r`.
  So a non-backtracking 3-step means choosing a root of that cubic.
* `threeNextKernelPoly_depressed` — the Tschirnhaus shift `X = Y - r(2 - 3r²)`
  depresses the cubic to `Y³ + 9r²(3r² - 1)(1 - r²) Y + threeDepressedConst r`.
* `three_radical_obstruction` — **a negative result.**  Away from the loci
  `r = 0`, `r² = 1` and `3r² = 1` the depressed cubic has *nonzero* linear
  coefficient, hence it is never of the form `Y³ - c`: the abscissa of the next
  kernel is *not* obtainable by extracting a single cube root in the Montgomery
  coordinate.  This is why radical 3-isogeny formulas are written in Tate normal
  form rather than in Montgomery form, and it delimits precisely how far the
  `ℓ = 2` picture (where `α² = A + 2` *is* a single square root) generalises.
  The hypothesis `3 ≠ 0` is necessary: in characteristic three the cubic
  degenerates to `X³ - r`, which is a pure cube.
* `three_radical_locus` — **and the exception.**  Exactly on the locus
  `3r² = 1` the cubic collapses to the pure cube `(X + r)³ - 4r/3`, so there the
  next kernel *is* given by one cube root.
-/
import Cryptography.IsogenySIDH.ThreeIsogenyMontgomery

set_option maxHeartbeats 1000000

namespace Cryptography.IsogenySIDH

variable {K : Type*} [Field K]

/-! ## The dual kernel -/

/-- **The backtracking choice.**  On the target curve of the 3-isogeny with
kernel abscissa `r`, the abscissa `-1/(3r)` is always a point of order three: it
generates the kernel of the dual isogeny. -/
theorem threeDual_kernel {r : K} (htwo : (2 : K) ≠ 0) (hthree : (3 : K) ≠ 0)
    (hr : r ≠ 0) : threeDivPoly (mont3Target r) (-(1 / (3 * r))) = 0 := by
  have h3r : (3 : K) * r ≠ 0 := mul_ne_zero hthree hr
  have hfour : (4 : K) ≠ 0 := two_pow_ne_zero_aux htwo
  simp only [threeDivPoly, mont3Target]
  field_simp
  ring

/-! ## The residual cubic -/

/-- The cubic whose roots are the abscissae of the three *non-backtracking*
order-three kernels on the target curve. -/
def threeNextKernelPoly (r X : K) : K :=
  X ^ 3 + 3 * r * (2 - 3 * r ^ 2) * X ^ 2 + 3 * r ^ 2 * X - r

/-- **Factorisation of the target's three-division polynomial.**  The dual
kernel splits off over the base field, leaving the explicit residual cubic. -/
theorem threeDivPoly_target_factor {r : K} (htwo : (2 : K) ≠ 0) (hr : r ≠ 0) (X : K) :
    r * threeDivPoly (mont3Target r) X = (3 * r * X + 1) * threeNextKernelPoly r X := by
  have hfour : (4 : K) ≠ 0 := two_pow_ne_zero_aux htwo
  simp only [threeDivPoly, mont3Target, threeNextKernelPoly]
  field_simp
  ring

/-- Every non-backtracking 3-step is a root of the residual cubic. -/
theorem threeNextKernel_of_root {r X : K} (htwo : (2 : K) ≠ 0) (hr : r ≠ 0)
    (hX : threeDivPoly (mont3Target r) X = 0) (hdual : 3 * r * X + 1 ≠ 0) :
    threeNextKernelPoly r X = 0 := by
  have h := threeDivPoly_target_factor htwo hr X
  rw [hX, mul_zero] at h
  rcases mul_eq_zero.mp h.symm with h1 | h1
  · exact absurd h1 hdual
  · exact h1

/-! ## Depressing the cubic -/

/-- The constant term of the depressed residual cubic. -/
def threeDepressedConst (r : K) : K :=
  2 * r ^ 3 * (2 - 3 * r ^ 2) ^ 3 - 3 * r ^ 3 * (2 - 3 * r ^ 2) - r

/-- The Tschirnhaus shift removes the quadratic term of the residual cubic; the
resulting linear coefficient is `9r²(3r² - 1)(1 - r²)`. -/
theorem threeNextKernelPoly_depressed (r Y : K) :
    threeNextKernelPoly r (Y - r * (2 - 3 * r ^ 2))
      = Y ^ 3 + 9 * r ^ 2 * (3 * r ^ 2 - 1) * (1 - r ^ 2) * Y + threeDepressedConst r := by
  simp only [threeNextKernelPoly, threeDepressedConst]
  ring

/-- **The radical obstruction.**  Off the three degenerate loci the depressed
residual cubic is not a pure cube, so the abscissa of the next 3-isogeny kernel
cannot be produced by extracting a single cube root in the Montgomery
coordinate. -/
theorem three_radical_obstruction {r : K} (htwo : (2 : K) ≠ 0) (hthree : (3 : K) ≠ 0)
    (hr : r ≠ 0) (h1 : r ^ 2 - 1 ≠ 0) (h3 : 3 * r ^ 2 - 1 ≠ 0) :
    ¬ ∃ c : K, ∀ Y : K, threeNextKernelPoly r (Y - r * (2 - 3 * r ^ 2)) = Y ^ 3 - c := by
  rintro ⟨c, hc⟩
  have h9 : (9 : K) ≠ 0 := by
    have h : (9 : K) = 3 * 3 := by norm_num
    rw [h]; exact mul_ne_zero hthree hthree
  have hL : 9 * r ^ 2 * (3 * r ^ 2 - 1) * (1 - r ^ 2) ≠ 0 := by
    refine mul_ne_zero (mul_ne_zero (mul_ne_zero h9 (pow_ne_zero 2 hr)) h3) ?_
    intro h
    exact h1 (by linear_combination -h)
  have e1 := hc 1
  have e2 := hc (-1)
  rw [threeNextKernelPoly_depressed] at e1 e2
  have hsum : 2 * (9 * r ^ 2 * (3 * r ^ 2 - 1) * (1 - r ^ 2)) = 0 := by
    linear_combination e1 - e2
  rcases mul_eq_zero.mp hsum with h | h
  · exact htwo h
  · exact hL h

/-- **The exceptional locus.**  When `3r² = 1` the residual cubic *is* a pure
cube: `threeNextKernelPoly r X = (X + r)³ - 4r/3`.  There the next kernel is
obtained by a single cube root. -/
theorem three_radical_locus {r : K} (hthree : (3 : K) ≠ 0) (hloc : 3 * r ^ 2 - 1 = 0)
    (X : K) : threeNextKernelPoly r X = (X + r) ^ 3 - 4 * r / 3 := by
  simp only [threeNextKernelPoly]
  field_simp
  linear_combination (-(9 * r * X ^ 2 + r)) * hloc

end Cryptography.IsogenySIDH