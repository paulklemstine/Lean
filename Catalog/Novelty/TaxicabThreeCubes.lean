import MachineLearning.NumberTheory.LocalGlobalGeometry
import Pythagorean.NumberTheory.CircleMethodDensity

/-!
# 1729 as a Sum of Three Nonzero Cubes

The taxicab number has the familiar positive two-cube representations
`1729 = 12³ + 1³ = 10³ + 9³`.  It also has the signed, genuinely three-term
representation

`1729 = 13³ + (-7)³ + (-5)³`.

Thus the proposed nonexistence of a representation with three nonzero terms is
false.  The results below record the counterexample, its arithmetic structure,
a sharp lower bound for the height of any such representation, its scaling
family, and its local consequences.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): The initial nonexistence conjecture suggested that
1729 might inherit rigidity from its two positive taxicab decompositions.  More
ambitious variants predicted that every signed three-cube decomposition would
have height greater than 13, that the first decomposition might fail a local
condition, or that no primitive decomposition could exist.

Experiment (Experimenter): A symmetric search over signed triples immediately
found `(-7,-5,13)`.  Direct expansion gives `-343-125+2197=1729`.  A complete
search of the smaller height box found no nonzero solution, while the displayed
triple has greatest common divisor one.  Reduction modulo small moduli found no
local obstruction, as expected from the integral point.

Analysis (Analyst): Cancellation is decisive.  Restricting attention to positive
cubes hides the nearby cube `13³=2197`; subtracting `7³+5³=468` lands exactly on
1729.  The primitive identity persists under scaling and supplies integral
points on an infinite sequence of diagonal cubic surfaces.  Every such integral
point automatically supplies points over every residue ring.

Critique (Critic): The counterexample uses three genuinely nonzero, pairwise
distinct integers, so it is not a padded two-cube representation.  The height
claim is explicitly bounded and exhaustive rather than an unsupported global
classification.  Local solvability is asserted only in the necessary direction
from a displayed integral point; no converse local-global principle is claimed.

Synthesis (Principal Investigator): The nonexistence conjecture is replaced by
a sharp minimum-height theorem: among nonzero signed decompositions of 1729,
height 13 is optimal and is attained by the primitive triple `(13,-7,-5)`.
The identity also connects the concrete taxicab calculation to cubic surfaces,
local representability, and positive finite local densities.
-- !-- Lab Notes -- !--
-/

namespace TaxicabThreeCubes

/-- The height of an ordered integer triple. -/
def tripleHeight (x y z : ℤ) : ℤ := max |x| (max |y| |z|)

/-- The two classical positive taxicab decompositions of 1729. -/
theorem two_taxicab_decompositions :
    (12 : ℤ) ^ 3 + 1 ^ 3 = 1729 ∧ (10 : ℤ) ^ 3 + 9 ^ 3 = 1729 := by
  norm_num

/-- A genuinely three-term signed-cube decomposition of 1729. -/
theorem nontrivial_three_cube_decomposition :
    (13 : ℤ) ^ 3 + (-7) ^ 3 + (-5) ^ 3 = 1729 := by
  norm_num

/-- The displayed decomposition uses three nonzero, pairwise distinct terms. -/
theorem decomposition_is_genuine :
    (13 : ℤ) ≠ 0 ∧ (-7 : ℤ) ≠ 0 ∧ (-5 : ℤ) ≠ 0 ∧
      (13 : ℤ) ≠ -7 ∧ (13 : ℤ) ≠ -5 ∧ (-7 : ℤ) ≠ -5 := by
  norm_num

/-- The displayed triple is primitive. -/
theorem decomposition_is_primitive :
    Int.gcd 13 (Int.gcd (-7) (-5)) = 1 := by
  norm_num

/-- Exhaustive bounded arithmetic underlying the sharp height theorem. -/
private lemma no_small_nonzero_solution :
    ∀ x ∈ Finset.Icc (-12 : ℤ) 12,
      ∀ y ∈ Finset.Icc (-12 : ℤ) 12,
        ∀ z ∈ Finset.Icc (-12 : ℤ) 12,
          x ≠ 0 → y ≠ 0 → z ≠ 0 → x ^ 3 + y ^ 3 + z ^ 3 ≠ 1729 := by
  native_decide

/-
No nonzero representation of 1729 has height below 13.
-/
theorem nonzero_solution_height_ge_thirteen
    (x y z : ℤ) (hx : x ≠ 0) (hy : y ≠ 0) (hz : z ≠ 0)
    (hsum : x ^ 3 + y ^ 3 + z ^ 3 = 1729) :
    13 ≤ tripleHeight x y z := by
  by_contra h_contra;
  unfold tripleHeight at h_contra;
  have hx_mem : x ∈ Finset.Icc (-12 : ℤ) 12 := by simp; grind
  have hy_mem : y ∈ Finset.Icc (-12 : ℤ) 12 := by simp; grind
  have hz_mem : z ∈ Finset.Icc (-12 : ℤ) 12 := by simp; grind
  exact no_small_nonzero_solution x hx_mem y hy_mem z hz_mem hx hy hz hsum

/-
Exhaustive classification in the sharp height box.
-/
private lemma classify_bounded_nonzero_solution :
    ∀ x ∈ Finset.Icc (-13 : ℤ) 13,
      ∀ y ∈ Finset.Icc (-13 : ℤ) 13,
        ∀ z ∈ Finset.Icc (-13 : ℤ) 13,
          x ≠ 0 → y ≠ 0 → z ≠ 0 →
          x ^ 3 + y ^ 3 + z ^ 3 = 1729 →
          (x = 13 ∧ y = -7 ∧ z = -5) ∨
          (x = 13 ∧ y = -5 ∧ z = -7) ∨
          (x = -7 ∧ y = 13 ∧ z = -5) ∨
          (x = -7 ∧ y = -5 ∧ z = 13) ∨
          (x = -5 ∧ y = 13 ∧ z = -7) ∨
          (x = -5 ∧ y = -7 ∧ z = 13) := by
  have h_cases : ∀ x y z : ℤ, x ∈ Finset.Icc (-13) 13 → y ∈ Finset.Icc (-13) 13 → z ∈ Finset.Icc (-13) 13 → x ≠ 0 → y ≠ 0 → z ≠ 0 → x ^ 3 + y ^ 3 + z ^ 3 = 1729 → (x = 13 ∧ y = -7 ∧ z = -5) ∨ (x = 13 ∧ y = -5 ∧ z = -7) ∨ (x = -7 ∧ y = 13 ∧ z = -5) ∨ (x = -7 ∧ y = -5 ∧ z = 13) ∨ (x = -5 ∧ y = 13 ∧ z = -7) ∨ (x = -5 ∧ y = -7 ∧ z = 13) := by
    intros x y z hx hy hz hx0 hy0 hz0 hsum
    revert x y z;
    intros x y z hx hy hz hx0 hy0 hz0 hsum
    have h_cases : x ∈ Finset.Icc (-13) 13 ∧ y ∈ Finset.Icc (-13) 13 ∧ z ∈ Finset.Icc (-13) 13 := by
      exact ⟨ hx, hy, hz ⟩;
    revert x y z;
    intros x y z hx hy hz hx0 hy0 hz0 hsum h_cases
    have h_cases : x ∈ Finset.Icc (-13) 13 ∧ y ∈ Finset.Icc (-13) 13 ∧ z ∈ Finset.Icc (-13) 13 := by
      exact h_cases;
    revert x y z;
    intros x y z hx hy hz hx0 hy0 hz0 hsum h_cases h_cases'
    have h_cases : x ∈ Finset.Icc (-13) 13 ∧ y ∈ Finset.Icc (-13) 13 ∧ z ∈ Finset.Icc (-13) 13 := by
      exact h_cases';
    fin_cases hx <;> simp +decide at hx0 ⊢;
    all_goals revert y; revert z; native_decide;
  exact fun x hx y hy z hz hx0 hy0 hz0 hsum => h_cases x y z hx hy hz hx0 hy0 hz0 hsum

/-- Every nonzero solution of height at most 13 is a permutation of `(13,-7,-5)`. -/
theorem classify_minimum_height_solution
    (x y z : ℤ) (hx : x ≠ 0) (hy : y ≠ 0) (hz : z ≠ 0)
    (hsum : x ^ 3 + y ^ 3 + z ^ 3 = 1729)
    (hheight : tripleHeight x y z ≤ 13) :
    (x = 13 ∧ y = -7 ∧ z = -5) ∨
    (x = 13 ∧ y = -5 ∧ z = -7) ∨
    (x = -7 ∧ y = 13 ∧ z = -5) ∨
    (x = -7 ∧ y = -5 ∧ z = 13) ∨
    (x = -5 ∧ y = 13 ∧ z = -7) ∨
    (x = -5 ∧ y = -7 ∧ z = 13) := by
  unfold tripleHeight at hheight
  have hx_mem : x ∈ Finset.Icc (-13 : ℤ) 13 := by simp; grind
  have hy_mem : y ∈ Finset.Icc (-13 : ℤ) 13 := by simp; grind
  have hz_mem : z ∈ Finset.Icc (-13 : ℤ) 13 := by simp; grind
  exact classify_bounded_nonzero_solution x hx_mem y hy_mem z hz_mem hx hy hz hsum

/-- Height 13 is the sharp minimum among nonzero representations of 1729. -/
theorem minimum_height_thirteen :
    (∃ x y z : ℤ, x ≠ 0 ∧ y ≠ 0 ∧ z ≠ 0 ∧
      x ^ 3 + y ^ 3 + z ^ 3 = 1729 ∧ tripleHeight x y z = 13) ∧
    (∀ x y z : ℤ, x ≠ 0 → y ≠ 0 → z ≠ 0 →
      x ^ 3 + y ^ 3 + z ^ 3 = 1729 → 13 ≤ tripleHeight x y z) := by
  constructor
  · refine ⟨13, -7, -5, by norm_num, by norm_num, by norm_num, ?_, ?_⟩
    · exact nontrivial_three_cube_decomposition
    · norm_num [tripleHeight]
  · exact nonzero_solution_height_ge_thirteen

/-- Scaling the primitive identity gives a homogeneous family of cubic points. -/
theorem scaled_three_cube_family (t : ℤ) :
    (13 * t) ^ 3 + (-7 * t) ^ 3 + (-5 * t) ^ 3 = 1729 * t ^ 3 := by
  ring

/-- Every nonzero scale still has three nonzero summands. -/
theorem scaled_family_is_genuine {t : ℤ} (ht : t ≠ 0) :
    13 * t ≠ 0 ∧ -7 * t ≠ 0 ∧ -5 * t ≠ 0 := by
  refine ⟨mul_ne_zero (by norm_num) ht, ?_, ?_⟩
  · exact mul_ne_zero (by norm_num) ht
  · exact mul_ne_zero (by norm_num) ht

/-- The counterexample is an integral point on the diagonal cubic surface. -/
theorem taxicab_surface_point :
    (SumThreeCubesSurface 1729).Nonempty := by
  refine ⟨(13, -7, -5), ?_⟩
  exact nontrivial_three_cube_decomposition

/-- The integral point reduces to a point modulo every positive modulus. -/
theorem taxicab_locally_representable (n : ℕ) (hn : 0 < n) :
    LocallyAtMod 1729 n := by
  apply global_implies_local hn
  exact ⟨13, -7, -5, nontrivial_three_cube_decomposition⟩

/-- In the circle-method normalization, every finite local density is positive. -/
theorem taxicab_local_density_positive (n : ℕ) [NeZero n] :
    0 < threeCubeLocalDensity 1729 n := by
  apply threeCubeRep_implies_localDensity_pos
  exact ⟨13, -7, -5, nontrivial_three_cube_decomposition⟩

/-- The conjecture that every three-cube representation of 1729 has a zero term is false. -/
theorem refutes_zero_term_conjecture :
    ¬ (∀ x y z : ℤ, x ^ 3 + y ^ 3 + z ^ 3 = 1729 →
      x = 0 ∨ y = 0 ∨ z = 0) := by
  intro h
  have := h 13 (-7) (-5) nontrivial_three_cube_decomposition
  omega

end TaxicabThreeCubes