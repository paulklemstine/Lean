import Speculative.DepthSeparation.Basic
import Mathlib

/-!
# Derivative Formula for Iterated Exponentials

The central result of this file is the **closed-form derivative product formula**:

$$\frac{d}{dx}\operatorname{iterExp}(k+1, x) = \prod_{j=0}^{k} \operatorname{iterExp}(j+1, x)$$

This formula reveals that the derivative of a depth-`k` exponential tower is a product
of all intermediate tower levels — a multiplicative cascade that grows super-exponentially.
This is the key structural invariant underlying depth separation.

## Main results

* `hasDerivAt_iterExp` — `HasDerivAt` form of the derivative formula
* `deriv_iterExp_eq_prod` — equality form using `deriv`
* `deriv_iterExp_ge_self` — derivative lower bound: `(iterExp (k+1))' x ≥ iterExp (k+1) x`
* `deriv_iterExp_ge_one` — `1 ≤ deriv (iterExp (k+1)) x` for `x ≥ 0`
-/

noncomputable section

open Real Set

/-
The derivative of `iterExp (k+1)` at `x` equals the product
`∏ j ∈ Finset.range (k+1), iterExp (j+1) x`. This is the compositional cascade formula.
-/
theorem hasDerivAt_iterExp (k : ℕ) (x : ℝ) :
    HasDerivAt (iterExp (k + 1))
      (∏ j ∈ Finset.range (k + 1), iterExp (j + 1) x) x := by
  induction' k with k ih generalizing x;
  · simpa using Real.hasDerivAt_exp x;
  · convert HasDerivAt.exp ( ih x ) using 1;
    rw [ Finset.prod_range_succ, mul_comm ];
    rfl

/-
Derivative equality form of the tower cascade formula.
-/
theorem deriv_iterExp_eq_prod (k : ℕ) (x : ℝ) :
    deriv (iterExp (k + 1)) x =
      ∏ j ∈ Finset.range (k + 1), iterExp (j + 1) x := by
  convert ( hasDerivAt_iterExp k x |> HasDerivAt.deriv ) using 1

/-
On `x ≥ 0`, each factor in the derivative product is `≥ 1`, so the
derivative of `iterExp (k+1)` is at least `iterExp (k+1) x`.
-/
theorem deriv_iterExp_ge_self (k : ℕ) {x : ℝ} (hx : 0 ≤ x) :
    iterExp (k + 1) x ≤ deriv (iterExp (k + 1)) x := by
  rw [ deriv_iterExp_eq_prod ];
  rw [ Finset.prod_range_succ ];
  exact le_mul_of_one_le_left ( by exact le_trans ( by positivity ) ( one_le_iterExp_succ_of_nonneg k hx ) ) ( by exact le_trans ( by norm_num ) ( Finset.prod_le_prod ( fun _ _ => by positivity ) fun _ _ => one_le_iterExp_succ_of_nonneg _ hx ) )

/-
The derivative of `iterExp (k+1)` is at least 1 for `x ≥ 0`.
-/
theorem deriv_iterExp_ge_one (k : ℕ) {x : ℝ} (hx : 0 ≤ x) :
    1 ≤ deriv (iterExp (k + 1)) x := by
  exact le_trans ( one_le_iterExp_succ_of_nonneg k hx ) ( deriv_iterExp_ge_self k hx )

end