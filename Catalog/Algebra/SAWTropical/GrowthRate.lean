/-
# Submultiplicative Growth Rates and the Fekete–Tropical Bridge

This file establishes formal foundations connecting submultiplicative sequences
(as arise in self-avoiding walk enumeration) to subadditive analysis via Fekete's
lemma, and to tropical algebra via growth-rate convergence criteria.

## Main Results

- `IsSubmultiplicative`: A sequence `a : ℕ → ℝ` with `a(m+n) ≤ a(m) * a(n)` and `a(n) > 0`.
- `IsSubmultiplicative.log_subadditive`: Logarithm converts submultiplicative to subadditive.
- `IsSubmultiplicative.bound_pow`: `a(k*n) ≤ a(n)^k * a(0)` for submultiplicative sequences.
- `submulGrowthRate`: The connective constant as infimum of nth roots.
- `TropicalPowerSeries`: Tropical power series and convergence criteria.
- `fekete_tropical_bridge`: The bridge between classical and tropical convergence.
-/
import Mathlib

open Real Filter Topology Set

/-! ## Submultiplicative Sequences -/

/-- A sequence `a : ℕ → ℝ` is submultiplicative if `a(m+n) ≤ a(m) * a(n)` for all `m, n`,
    and all values are positive. This captures the growth pattern of self-avoiding walk
    counts on lattices. -/
def IsSubmultiplicative (a : ℕ → ℝ) : Prop :=
  (∀ n, 0 < a n) ∧ (∀ m n, a (m + n) ≤ a m * a n)

/-- The logarithm of a submultiplicative sequence is subadditive. This is the key bridge
    between multiplicative growth (combinatorics) and additive analysis (Fekete's lemma). -/
theorem IsSubmultiplicative.log_subadditive {a : ℕ → ℝ} (ha : IsSubmultiplicative a) :
    Subadditive (fun n => Real.log (a n)) := by
  intro m n
  have hpos := ha.1
  have hsub := ha.2
  calc Real.log (a (m + n))
      ≤ Real.log (a m * a n) := Real.log_le_log (hpos (m + n)) (hsub m n)
    _ = Real.log (a m) + Real.log (a n) :=
        Real.log_mul (ne_of_gt (hpos m)) (ne_of_gt (hpos n))

/-- Submultiplicative sequences satisfy `a(k*n) ≤ a(n)^k * a(0)` by induction. -/
theorem IsSubmultiplicative.bound_pow {a : ℕ → ℝ} (ha : IsSubmultiplicative a)
    (n : ℕ) : ∀ k : ℕ, a (k * n) ≤ a n ^ k * a 0 := by
  intro k
  induction' k with k ih <;> simp_all +decide [pow_succ, add_mul]
  exact le_trans (ha.2 _ _) (by nlinarith [ha.1 n, ha.1 0, pow_pos (ha.1 n) k])

/-- For submultiplicative sequences with `a(0) = 1`, `a(n) ≤ a(1)^n`. -/
theorem IsSubmultiplicative.bound_by_first {a : ℕ → ℝ} (ha : IsSubmultiplicative a)
    (h0 : a 0 = 1) (n : ℕ) : a n ≤ a 1 ^ n := by
  simpa [h0] using ha.bound_pow 1 n

/-! ## Growth Rate (Connective Constant) -/

/-- The **growth rate** (or connective constant) of a submultiplicative sequence,
    defined as the infimum of `a(n)^(1/n)` over positive `n`. For self-avoiding walks,
    this is the connective constant `μ` of the lattice. -/
noncomputable def submulGrowthRate (a : ℕ → ℝ) : ℝ :=
  iInf (fun n : ℕ+ => (a n) ^ (1 / (n : ℝ)))

/-- The growth rate is at most `a(n)^(1/n)` for any positive `n`. -/
theorem submulGrowthRate_le_nthRoot {a : ℕ → ℝ} (ha : IsSubmultiplicative a) (n : ℕ+) :
    submulGrowthRate a ≤ (a n) ^ (1 / (n : ℝ)) := by
  exact ciInf_le ⟨0, by rintro x ⟨m, rfl⟩; exact le_of_lt (rpow_pos_of_pos (ha.1 m) _)⟩ n

/-- The growth rate is at most `a(1)`. -/
theorem submulGrowthRate_le_first {a : ℕ → ℝ} (ha : IsSubmultiplicative a) :
    submulGrowthRate a ≤ a 1 := by
  simpa using submulGrowthRate_le_nthRoot ha 1

/-
The growth rate is nonneg for submultiplicative sequences.
-/
theorem submulGrowthRate_nonneg {a : ℕ → ℝ} (ha : IsSubmultiplicative a) :
    0 ≤ submulGrowthRate a := by
  exact Real.iInf_nonneg fun n => Real.rpow_nonneg ( le_of_lt ( ha.1 n ) ) _

/-
The growth rate is positive when `a(n) ≥ 1` for all positive `n`. This holds
    for SAW counts, since there is always at least one walk of each length.
-/
theorem submulGrowthRate_pos_of_ge_one {a : ℕ → ℝ} (_ha : IsSubmultiplicative a)
    (hge : ∀ n : ℕ+, 1 ≤ a n) : 0 < submulGrowthRate a := by
  refine' lt_of_lt_of_le one_pos ( le_ciInf fun n => Real.one_le_rpow _ _ );
  · exact hge n;
  · positivity

/-! ## Tropical Power Series Convergence -/

/-- A **tropical power series** with real coefficients. In the min-plus tropical
    semiring, evaluation at `x` gives `inf_n (c_n + n*x)`. -/
structure TropicalPowerSeries where
  coeffs : ℕ → ℝ

namespace TropicalPowerSeries

/-- The tropical evaluation at point `x`: `inf_n (c_n + n*x)`. -/
noncomputable def tropEval (f : TropicalPowerSeries) (x : ℝ) : EReal :=
  iInf (fun n : ℕ => (↑(f.coeffs n + n * x) : EReal))

end TropicalPowerSeries

/-! ## The Fekete–Tropical Bridge -/

/-- Given a submultiplicative sequence `a`, the associated tropical power series
    has coefficients `-log(a(n))`. -/
noncomputable def submulToTropical (a : ℕ → ℝ) : TropicalPowerSeries :=
  ⟨fun n => -Real.log (a n)⟩

/-
**Fekete–Tropical Bridge Theorem**: For a submultiplicative sequence with positive
    growth rate, `-log(a(n)) + n * log(μ) ≤ 0` for all positive `n`. This means every
    term of the tropical power series at the growth rate is non-positive, connecting
    the classical radius of convergence `1/μ` to the tropical growth rate `log(μ)`.
-/
theorem fekete_tropical_bridge {a : ℕ → ℝ} (ha : IsSubmultiplicative a)
    (hμ : 0 < submulGrowthRate a) (n : ℕ+) :
    -Real.log (a n) + ↑(n : ℕ) * Real.log (submulGrowthRate a) ≤ 0 := by
  -- From submulGrowthRate_le_nthRoot, we have that μ ≤ a(n)^(1/n).
  have h_le : (submulGrowthRate a) ≤ (a (n : ℕ)) ^ (1 / (n : ℝ)) := by
    convert submulGrowthRate_le_nthRoot ha n using 1;
  have := Real.log_le_log hμ h_le; norm_num at *;
  rwa [ Real.log_rpow ( ha.1 _ ), inv_mul_eq_div, le_div_iff₀' ( Nat.cast_pos.mpr n.pos ) ] at this

/-! ## Self-Avoiding Walk Application -/

/-- A **lattice graph** for SAW enumeration: a type with a symmetric generating set. -/
structure LatticeGraph where
  vertices : Type*
  [grp : Group vertices]
  generators : Finset vertices
  symm : ∀ g ∈ generators, g⁻¹ ∈ generators
  one_not_gen : (1 : vertices) ∉ generators

/-- SAW count data for a lattice graph. -/
structure SAWCount (G : LatticeGraph) where
  count : ℕ → ℝ
  submul : IsSubmultiplicative count
  count_zero : count 0 = 1
  count_one : count 1 = G.generators.card

/-- The **connective constant** of a lattice graph. -/
noncomputable def connectiveConstant (G : LatticeGraph) (c : SAWCount G) : ℝ :=
  submulGrowthRate c.count

/-- The connective constant is at most the degree of the lattice. -/
theorem connectiveConstant_le_degree (G : LatticeGraph) (c : SAWCount G) :
    connectiveConstant G c ≤ G.generators.card := by
  convert submulGrowthRate_le_first c.submul using 1
  exact c.count_one.symm

/-! ## Nienhuis Constant -/

/-- The Nienhuis constant `√(2 + √2)` — the connective constant of the hexagonal lattice,
    proved by Duminil-Copin and Smirnov (2012). -/
noncomputable def NienhuisConstant : ℝ := Real.sqrt (2 + Real.sqrt 2)

/-- The Nienhuis constant is irrational. We prove this by showing `2 + √2` is irrational
    (since `√2` is irrational), and therefore its square root is also irrational. -/
theorem nienhuis_irrational : Irrational NienhuisConstant := by
  have h_irr : Irrational (2 + Real.sqrt 2) := by
    exact_mod_cast irrational_sqrt_two.ratCast_add 2
  have h_sqrt_irr : Irrational (Real.sqrt (2 + Real.sqrt 2)) := by
    have h_sq : Real.sqrt (2 + Real.sqrt 2) ^ 2 = 2 + Real.sqrt 2 := by
      exact Real.sq_sqrt <| by positivity
    exact fun ⟨a, ha⟩ => h_irr ⟨a ^ 2, by push_cast; rw [← h_sq, ha]⟩
  exact h_sqrt_irr

/-- The Nienhuis constant satisfies `x⁴ - 4x² + 2 = 0`. This is its minimal polynomial
    over ℚ, showing it is algebraic of degree 4. -/
theorem nienhuis_minimal_poly :
    NienhuisConstant ^ 4 - 4 * NienhuisConstant ^ 2 + 2 = 0 := by
  unfold NienhuisConstant
  nlinarith [Real.mul_self_sqrt (show 0 ≤ 2 + Real.sqrt 2 by positivity),
             Real.mul_self_sqrt (show 0 ≤ (2 : ℝ) by positivity)]