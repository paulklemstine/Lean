Formalize a minimal, COMPLETE finite information geometry core in Lean 4 over Mathlib. The file should be self-contained and every theorem must have a FULL statement and a COMPLETE proof (sorries are acceptable for difficult steps but the statement must be complete).

## Definitions (keep these simple and Lean-friendly)

1. `FiniteStatModel (Ω : Type*) [Fintype Ω]` — a structure wrapping a function `pmf : Ω → ℝ` such that `∀ ω, 0 ≤ pmf ω` and `∑ ω, pmf ω = 1`.

2. `FiniteStatModel.expectation (M : FiniteStatModel Ω) (f : Ω → ℝ) : ℝ` — defined as `∑ ω, M.pmf ω * f ω`.

3. `FiniteStatModel.centered (M : FiniteStatModel Ω) (f : Ω → ℝ) (ω : Ω) : ℝ` — defined as `f ω - M.expectation f`.

4. `FiniteStatModel.variance (M : FiniteStatModel Ω) (f : Ω → ℝ) : ℝ` — defined as `M.expectation (fun ω => (M.centered f ω)^2)`.

5. `FiniteStatModel.covariance (M : FiniteStatModel Ω) (f g : Ω → ℝ) : ℝ` — defined as `M.expectation (fun ω => (M.centered f ω) * (M.centered g ω))`.

## Theorems to prove (ALL statements must be complete, ALL proofs must exist)

1. `theorem expectation_const (M : FiniteStatModel Ω) (c : ℝ) : M.expectation (fun _ => c) = c`
   Proof sketch: unfold expectation, use `Finset.sum_congr` to factor out c, then use the sum-to-one hypothesis.

2. `theorem expectation_add (M : FiniteStatModel Ω) (f g : Ω → ℝ) : M.expectation (fun ω => f ω + g ω) = M.expectation f + M.expectation g`
   Proof sketch: unfold expectation, use `Finset.sum_add_distrib`, then `mul_add` / `add_mul` rearrangement.

3. `theorem expectation_smul (M : FiniteStatModel Ω) (c : ℝ) (f : Ω → ℝ) : M.expectation (fun ω => c * f ω) = c * M.expectation f`
   Proof sketch: unfold, factor out c using `Finset.sum_congr` and `mul_assoc`.

4. `theorem covariance_symm (M : FiniteStatModel Ω) (f g : Ω → ℝ) : M.covariance f g = M.covariance g f`
   Proof sketch: unfold covariance, use `mul_comm` under the sum via `Finset.sum_congr`.

5. `theorem variance_eq_covariance_self (M : FiniteStatModel Ω) (f : Ω → ℝ) : M.variance f = M.covariance f f`
   Proof sketch: unfold both definitions, they are definitionally equal.

6. `theorem covariance_const_left (M : FiniteStatModel Ω) (f : Ω → ℝ) (c : ℝ) : M.covariance (fun _ => c) f = 0`
   Proof sketch: centered of a constant is zero (since expectation of constant equals constant), so the product under the sum is zero.

7. `theorem variance_const (M : FiniteStatModel Ω) (f : Ω → ℝ) (c : ℝ) (hfc : ∀ ω, f ω = c) : M.variance f = 0`
   Proof sketch: show centered f is identically zero using `expectation_const`, then the sum of zeros is zero.

8. `theorem variance_nonneg (M : FiniteStatModel Ω) (f : Ω → ℝ) : 0 ≤ M.variance f`
   Proof sketch: variance = ∑ ω, pmf ω * (centered f ω)^2, each summand is nonneg (pmf ≥ 0 and square ≥ 0), so the sum is ≥ 0. Use `Finset.sum_nonneg` and `mul_nonneg`.

9. `theorem covariance_linear_left (M : FiniteStatModel Ω) (f₁ f₂ g : Ω → ℝ) : M.covariance (fun ω => f₁ ω + f₂ ω) g = M.covariance f₁ g + M.covariance f₂ g`
   Proof sketch: expand centered, distribute multiplication, use linearity of expectation.

10. `theorem variance_add_covariance (M : FiniteStatModel Ω) (f g : Ω → ℝ) : M.variance (fun ω => f ω + g ω) = M.variance f + 2 * M.covariance f g + M.variance g`
    Proof sketch: expand using linearity and bilinearity of covariance.

## Important Lean/Mathlib tactics to use
- `Finset.sum_congr` for pointwise rewriting under sums
- `Finset.sum_add_distrib` for distributing sums over addition
- `Finset.sum_mul` / `Finset.mul_sum` for factoring scalars out of sums
- `Finset.sum_nonneg` for proving sums of nonneg terms are nonneg
- `mul_nonneg`, `sq_nonneg`, `mul_comm`, `mul_assoc`, `add_mul`, `mul_add`
- `simp` with `[FiniteStatModel.expectation, FiniteStatModel.variance, FiniteStatModel.covariance, FiniteStatModel.centered]`
- `ring` / `ring_nf` for algebraic rearrangements
- `field_simp` if division arises

## Style requirements
- Use `namespace Catalog.InformationGeometry.FiniteCore`
- Keep the file under 300 lines to avoid truncation
- Every theorem MUST have its complete type signature after `:`
- Every theorem MUST have a `proof by` or `:= by` block (sorries ok for hard steps)
- No theorem stubs with empty statements
- Import only `Mathlib.Data.Real.Basic`, `Mathlib.Algebra.BigOperators.Group.Finset`, `Mathlib.Data.Fintype.Basic`, and any other minimal imports needed

Do NOT include Fisher information matrix or exponential family — those are deferred to future work. This file is ONLY about expectation, variance, covariance on finite statistical models.