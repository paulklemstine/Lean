import Tropical.DependentFibers.Core

/-!
# The fibre family is the support of a genuine min-plus semiring evaluation

`Core` defines `tropVal` by an explicit `Finset.inf'`.  This file identifies it with the
evaluation of a polynomial in Mathlib's tropical semiring `Tropical (WithTop ℚ)`,

`⨁_{i ≤ n} trop (c i) ⊙ trop x ^ i`,

where `⊕` is tropical addition (the minimum) and `⊙` tropical multiplication (ordinary
addition).  Consequently the fibre `fiber n c x` is exactly the set of monomials whose
tropical value equals the tropical sum (`mem_fiber_iff_trop_eq`), i.e. the *support of
the tropical evaluation* in the strict semiring sense, and the results of the other
files are statements about honest tropical polynomials, not about an ad-hoc minimum.
-/

namespace TropicalDependentFibers

open Finset

/-- A single tropical monomial: `trop (c i) ⊙ (trop x)^i = trop (c i + i·x)`. -/
theorem trop_monomial (a x : ℚ) (i : ℕ) :
    Tropical.trop (((a + (i : ℚ) * x : ℚ) : WithTop ℚ))
      = Tropical.trop ((a : WithTop ℚ)) * (Tropical.trop ((x : WithTop ℚ))) ^ i := by
  induction i with
  | zero => simp
  | succ i ih =>
      have hstep : ((a + ((i + 1 : ℕ) : ℚ) * x : ℚ) : WithTop ℚ)
          = ((a + (i : ℚ) * x : ℚ) : WithTop ℚ) + ((x : ℚ) : WithTop ℚ) := by
        have hq : a + ((i + 1 : ℕ) : ℚ) * x = (a + (i : ℚ) * x) + x := by
          push_cast; ring
        rw [hq]
        norm_cast
      rw [hstep, Tropical.trop_add, ih, pow_succ, mul_assoc]

/-- The **tropical evaluation** of the degree-`n` polynomial with coefficients `c` in
Mathlib's tropical semiring. -/
def tropicalEval (n : ℕ) (c : ℕ → ℚ) (x : ℚ) : Tropical (WithTop ℚ) :=
  ∑ i ∈ range (n + 1), Tropical.trop (((c i : ℚ) : WithTop ℚ)) *
    (Tropical.trop (((x : ℚ) : WithTop ℚ))) ^ i

/-- **Semiring compatibility.**  The explicit minimum `tropVal` is the tropical sum of
the monomials: our fibre theory is the fibre theory of the min-plus polynomial. -/
theorem trop_tropVal (n : ℕ) (c : ℕ → ℚ) (x : ℚ) :
    Tropical.trop ((tropVal n c x : ℚ) : WithTop ℚ) = tropicalEval n c x := by
  have hcoe : ((tropVal n c x : ℚ) : WithTop ℚ)
      = (range (n + 1)).inf fun i => (((c i + (i : ℚ) * x : ℚ)) : WithTop ℚ) := by
    rw [tropVal, Finset.coe_inf' (range_succ_nonempty n)]
    rfl
  rw [hcoe, Finset.trop_inf, tropicalEval]
  exact Finset.sum_congr rfl fun i _ => trop_monomial (c i) x i

/-- The fibre is the support of the tropical evaluation: the monomials whose tropical
value equals the tropical sum. -/
theorem mem_fiber_iff_trop_eq {n i : ℕ} {c : ℕ → ℚ} {x : ℚ} :
    i ∈ fiber n c x ↔ i ≤ n ∧
      Tropical.trop ((c i : WithTop ℚ)) * (Tropical.trop ((x : WithTop ℚ))) ^ i
        = tropicalEval n c x := by
  rw [fiber, mem_filter, mem_range]
  constructor
  · rintro ⟨hi, hval⟩
    refine ⟨by omega, ?_⟩
    rw [← trop_monomial (c i) x i, ← trop_tropVal]
    exact congrArg _ (congrArg _ hval)
  · rintro ⟨hi, heq⟩
    refine ⟨by omega, ?_⟩
    rw [← trop_monomial (c i) x i, ← trop_tropVal] at heq
    have := Tropical.trop_injective heq
    exact_mod_cast this

/-- Restatement of the main non-constancy phenomenon in semiring language: at a corner
at least two distinct monomials of the tropical polynomial attain the evaluation. -/
theorem two_monomials_attain_of_corner {n : ℕ} {c : ℕ → ℚ} {x : ℚ}
    (hx : 2 ≤ (fiber n c x).card) :
    ∃ i j : ℕ, i ≠ j ∧ i ≤ n ∧ j ≤ n ∧
      Tropical.trop ((c i : WithTop ℚ)) * (Tropical.trop ((x : WithTop ℚ))) ^ i
        = tropicalEval n c x ∧
      Tropical.trop ((c j : WithTop ℚ)) * (Tropical.trop ((x : WithTop ℚ))) ^ j
        = tropicalEval n c x := by
  obtain ⟨i, hi, j, hj, hij⟩ := Finset.one_lt_card.mp hx
  obtain ⟨hin, hieq⟩ := mem_fiber_iff_trop_eq.mp hi
  obtain ⟨hjn, hjeq⟩ := mem_fiber_iff_trop_eq.mp hj
  exact ⟨i, j, hij, hin, hjn, hieq, hjeq⟩

end TropicalDependentFibers