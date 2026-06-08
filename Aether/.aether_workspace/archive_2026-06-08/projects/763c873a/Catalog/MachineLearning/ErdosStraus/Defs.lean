/-
# Erdős–Straus Conjecture: Core Definitions and Equivalences

The Erdős–Straus conjecture (1948) asserts that for every integer n ≥ 2,
the fraction 4/n can be written as a sum of three unit fractions:
  4/n = 1/x + 1/y + 1/z
for positive integers x, y, z.

## Diophantine Surface Viewpoint

Clearing denominators, the equation 4/n = 1/x + 1/y + 1/z becomes
  4·x·y·z = n·(x·y + x·z + y·z),
which defines an affine surface in (x,y,z)-space parameterized by n.
Parametric solution families correspond to rational curves on this surface.

This file provides the integer-cleared formulation and proves its equivalence
with the rational statement.
-/
import Mathlib

/-- `ErdosStrausRep n x y z` asserts that `(x, y, z)` is a valid Erdős–Straus
decomposition for `n`: all three denominators are positive and the cleared
Diophantine equation `4·x·y·z = n·(x·y + x·z + y·z)` holds over ℤ. -/
def ErdosStrausRep (n x y z : ℕ) : Prop :=
  0 < x ∧ 0 < y ∧ 0 < z ∧
    (4 : ℤ) * x * y * z = (n : ℤ) * (x * y + x * z + y * z)

/-- `ErdosStrausSolvable n` asserts that `n` admits an Erdős–Straus decomposition. -/
def ErdosStrausSolvable (n : ℕ) : Prop :=
  ∃ x y z : ℕ, ErdosStrausRep n x y z

/-
The integer-cleared equation is equivalent to the rational unit-fraction identity,
provided all parameters are positive. This is the foundational bridge between the
algebraic (Diophantine) and analytic (rational arithmetic) formulations.
-/
theorem erdos_straus_rep_iff_rat
    {n x y z : ℕ} (hn : 0 < n) (hx : 0 < x) (hy : 0 < y) (hz : 0 < z) :
    ErdosStrausRep n x y z ↔
      ((4 : ℚ) / n = (1 : ℚ) / x + (1 : ℚ) / y + (1 : ℚ) / z) := by
  unfold ErdosStrausRep; simp +decide [ *, div_eq_mul_inv ] ;
  field_simp;
  norm_cast; ring;

/-
Rearrangement lemma: the Erdős–Straus equation is equivalent to the factored form
`(4x - n)·y·z = n·x·(y + z)`. This form is useful for algorithmic search since it
reveals that we need `4x > n` (i.e., `x > n/4`) for any solution.
-/
theorem erdos_straus_rearrange
    {n x y z : ℕ} (hx : 0 < x) (hy : 0 < y) (hz : 0 < z) :
    ErdosStrausRep n x y z ↔
      ((4 : ℤ) * x - n) * y * z = (n : ℤ) * x * (y + z) := by
  unfold ErdosStrausRep; ring;
  grind