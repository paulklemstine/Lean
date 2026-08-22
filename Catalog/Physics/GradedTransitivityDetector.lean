import Physics.GradedTransitivityTrivial

/-!
# The singularity data detects eventual transitivity

The previous files computed, for a graded `G`-set whose transitivity counts are eventually
polynomial, two numbers attached to the unique singularity `q = 1` of the partition function:
its **order** `−(deg P + 1)` and its **residue** `−P(−1)`.  This file closes the loop by
showing that these two analytic numbers *recover* the group-theoretic property they came
from:

  the pole is simple **and** the residue is `−1`  ⟺  the action is eventually `r`-transitive.

Neither condition suffices alone.  A simple pole only says that the grade counts are
eventually *constant* (`deg P = 0`), which happens for any eventually fixed number of orbits;
the residue then reads off that constant, and the value `1` is exactly `r`-transitivity by
`transCount_eq_one_iff`.  So the pair (order, residue) is a complete analytic detector, and
the boundary of the statement is sharp: a graded `G`-set with eventually two orbits on
injective `r`-tuples has the same pole order but residue `−2`.

## Main results

* `Physics.GradedTransitivity.eventually_transitive_iff_poly_one` — eventual transitivity is
  equivalent to the grade-count polynomial being `1`.
* `Physics.GradedTransitivity.transitive_iff_simple_pole_residue_one` — the analytic
  detector: order `−1` together with residue `−1` characterises eventual transitivity.
* `Physics.GradedTransitivity.residue_eq_neg_const_of_eventually_const` — the sharpness
  boundary: eventually `c` orbits gives a simple pole with residue `−c`.
-/

namespace Physics.GradedTransitivity

open Finset Polynomial Complex Filter Topology MulAction

variable {G : Type*} [Group G] {Y : ℕ → Type*} [∀ n, MulAction G (Y n)] {r N : ℕ}
  {P : Polynomial ℂ}

/-- **Eventual transitivity in terms of the grade-count polynomial.**  If the transitivity
counts are eventually the values of `P`, then the action is eventually `r`-transitive exactly
when `P` is the constant polynomial `1`. -/
theorem eventually_transitive_iff_poly_one
    (hpoly : ∀ n, N ≤ n → ((transCount G r (Y n) : ℂ)) = P.eval (n : ℂ)) :
    (∀ n, N ≤ n → IsTransitiveDeg G r (Y n)) ↔ P = 1 := by
  constructor
  · intro htrans
    have hval : ∀ n, N ≤ n → P.eval (n : ℂ) = 1 := by
      intro n hn
      have h1 : transCount G r (Y n) = 1 := (transCount_eq_one_iff r (Y n)).mpr (htrans n hn)
      rw [← hpoly n hn, h1]
      norm_num
    -- `P` agrees with `1` on the infinite set `{(n : ℂ) | N ≤ n}`
    have hinj : Function.Injective (fun k : ℕ => ((k + N : ℕ) : ℂ)) := by
      intro i j h
      have hij : ((i + N : ℕ) : ℂ) = ((j + N : ℕ) : ℂ) := h
      have := Nat.cast_injective (R := ℂ) hij
      omega
    refine Polynomial.eq_of_infinite_eval_eq _ _
      (Set.Infinite.mono ?_ (Set.infinite_range_of_injective hinj))
    rintro _ ⟨k, rfl⟩
    simp only [Set.mem_setOf_eq, Polynomial.eval_one]
    exact hval (k + N) (Nat.le_add_left N k)
  · intro hP n hn
    have : ((transCount G r (Y n) : ℂ)) = 1 := by rw [hpoly n hn, hP, Polynomial.eval_one]
    have hnat : transCount G r (Y n) = 1 := by exact_mod_cast this
    exact (transCount_eq_one_iff r (Y n)).mp hnat

/-- **The analytic detector.**  For a graded `G`-set with eventually polynomial transitivity
counts, an analytic continuation of the partition function to `ℂ \ {1}` has a simple pole with
residue `−1` at `q = 1` if and only if the action is eventually `r`-transitive. -/
theorem transitive_iff_simple_pole_residue_one
    (hpoly : ∀ n, N ≤ n → ((transCount G r (Y n) : ℂ)) = P.eval (n : ℂ)) {F : ℂ → ℂ}
    (hF : AnalyticOnNhd ℂ F {(1 : ℂ)}ᶜ)
    (hF0 : ∀ᶠ q in 𝓝 (0 : ℂ), F q = ∑' n : ℕ, (transCount G r (Y n) : ℂ) * q ^ n)
    {ρ : ℝ} (hρ : 0 < ρ) :
    (meromorphicOrderAt F 1 = ((-1 : ℤ) : WithTop ℤ) ∧
        (∮ z in C((1 : ℂ), ρ), F z) = -(2 * (Real.pi : ℂ) * I))
      ↔ (∀ n, N ≤ n → IsTransitiveDeg G r (Y n)) := by
  rw [eventually_transitive_iff_poly_one hpoly]
  constructor
  · rintro ⟨horder, hres⟩
    -- a pole forces `P ≠ 0`
    have hP0 : P ≠ 0 := by
      intro hzero
      have hcoef0 : ∀ n, N ≤ n → ((transCount G r (Y n) : ℂ)) = 0 := by
        intro n hn; rw [hpoly n hn, hzero, Polynomial.eval_zero]
      have hnonneg := order_nonneg_of_eventually_zero hcoef0 hF hF0
      rw [horder] at hnonneg
      have : ((-1 : ℤ) : WithTop ℤ) < 0 := by exact_mod_cast (by omega : (-1 : ℤ) < 0)
      exact absurd hnonneg (not_le.mpr this)
    -- the order determines the degree
    have hdeg : P.natDegree = 0 := by
      have := order_of_eventually_polynomial hP0 hpoly hF hF0
      rw [horder] at this
      have hcast : (-1 : ℤ) = -(P.natDegree + 1 : ℤ) := by exact_mod_cast this
      omega
    obtain ⟨c, hc⟩ := Polynomial.natDegree_eq_zero.mp hdeg
    -- the residue determines the constant
    have hresidue := circleIntegral_of_eventually_polynomial hpoly hF hF0 hρ
    rw [hres, ← hc] at hresidue
    simp only [Polynomial.eval_C] at hresidue
    have hpi : (2 * (Real.pi : ℂ) * I) ≠ 0 := by
      simp [Real.pi_ne_zero, Complex.I_ne_zero, Complex.ofReal_eq_zero]
    have hneg : (-1 : ℂ) = -c := mul_right_cancel₀ hpi (by linear_combination hresidue)
    have hc1 : c = 1 := by linear_combination hneg
    rw [← hc, hc1]
    simp
  · intro hP
    refine ⟨?_, ?_⟩
    · have hP0 : P ≠ 0 := by rw [hP]; exact one_ne_zero
      have := order_of_eventually_polynomial hP0 hpoly hF hF0
      rw [hP] at this
      simpa using this
    · have := circleIntegral_of_eventually_polynomial hpoly hF hF0 hρ
      rw [hP] at this
      simpa using this

/-- **The sharpness boundary.**  If the number of orbits on injective `r`-tuples is eventually
the constant `c`, the pole stays simple but the residue is `−c`: the residue, not the pole
order, is what sees transitivity. -/
theorem residue_eq_neg_const_of_eventually_const {c : ℕ}
    (hconst : ∀ n, N ≤ n → transCount G r (Y n) = c) {F : ℂ → ℂ}
    (hF : AnalyticOnNhd ℂ F {(1 : ℂ)}ᶜ)
    (hF0 : ∀ᶠ q in 𝓝 (0 : ℂ), F q = ∑' n : ℕ, (transCount G r (Y n) : ℂ) * q ^ n)
    {ρ : ℝ} (hρ : 0 < ρ) :
    (∮ z in C((1 : ℂ), ρ), F z) = -(c : ℂ) * (2 * (Real.pi : ℂ) * I) := by
  have hcoef : ∀ n, N ≤ n → ((transCount G r (Y n) : ℂ)) = (Polynomial.C (c : ℂ)).eval (n : ℂ) := by
    intro n hn
    rw [hconst n hn, Polynomial.eval_C]
  rw [circleIntegral_of_eventually_polynomial hcoef hF hF0 hρ, Polynomial.eval_C]

end Physics.GradedTransitivity