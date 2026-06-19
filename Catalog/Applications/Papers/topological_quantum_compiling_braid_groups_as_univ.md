# Computational Evidence — Topological Quantum Compiling (Fibonacci anyons, k = 5)

This note records the small-case computations that informed the formal results
in `FibonacciAnyonBraid.lean` and `FibonacciMatrixInfiniteOrder.lean`.

## 1. The Fibonacci loop value

For the Jones / Temperley–Lieb representation at the root of unity
`A = e^{2πi/5}`, the loop value is `δ = -(A² + A⁻²) = 2·cos(π/5)`.

Numerically `2·cos(π/5) = 1.6180339887… = (1 + √5)/2 = φ` (the golden ratio).

Verified symbolically in Lean via `Real.cos_pi_div_five : cos(π/5) = (1+√5)/4`,
and `δ² = δ + 1` (`Real.goldenRatio_sq`). This is the defining quadratic of the
Fibonacci fusion category.

## 2. Powers of the Burau / Fibonacci `Q`-matrix

`Q = !![1,1;1,0]`. Computed in Lean with `#eval`:

| n | Qⁿ                | Fibonacci reading |
|---|-------------------|-------------------|
| 1 | `!![1,1;1,0]`     | `!![F2,F1;F1,F0]` |
| 2 | `!![2,1;1,1]`     | `!![F3,F2;F2,F1]` |
| 3 | `!![3,2;2,1]`     | `!![F4,F3;F3,F2]` |
| 5 | `!![8,5;5,3]`     | `!![F6,F5;F5,F4]` |

Pattern: `Qⁿ⁺¹ = !![F(n+2),F(n+1);F(n+1),F(n)]` (proved as `Q_pow`).
The off-diagonal entry `F(n+1) ≥ 1` is never `0`, so `Qᵐ ≠ I` for every `m ≥ 1`
— hence `Q` has **infinite order**. The eigenvalues of `Q` are `φ` and `-1/φ`;
`|φ| > 1` is the hyperbolicity that forces infinite order. This is the discrete
shadow of an irrational rotation angle in `SU(3)`.

OEIS: the entry sequence is the Fibonacci numbers, **A000045**
(0,1,1,2,3,5,8,13,…).

## 3. The Burau braid `σ₁σ₂⁻¹`

With the explicit `B₃` Jones-specialization Burau matrices
`σ₁ ↦ !![1,1;0,1]`, `σ₂ ↦ !![1,0;-1,1]`:

* `σ₁σ₂σ₁ = σ₂σ₁σ₂ = !![0,1;-1,1]` — the braid relation holds (`burau_braid_relation`).
* `σ₂ · σ₂⁻¹ = I` with `σ₂⁻¹ ↦ !![1,0;1,1]` (`s2_mul_s2inv`).
* `σ₁σ₂⁻¹ = !![2,1;1,1] = Q²` (`burau_word_eq_Q_sq`), exhibiting an explicit
  braid of infinite order.

By contrast `σ₁σ₂ ↦ !![0,1;-1,1]` is *elliptic* (order 6), so the
infinite-order phenomenon is genuinely word-dependent — a non-trivial check that
ruled out the naive conjecture "every length-2 braid word is infinite order".

## 4. Counterexample hunt for the commutator identity

Tested `[jonesOp A X, jonesOp A Y] = A⁻² [X,Y]` symbolically: the scalar cross
terms `(A·A⁻¹)` cancel only because the base field is commutative. Over a
non-commutative scalar ring the identity would fail — recorded as the boundary
of `jonesOp_commutator`.

## Conclusion

The computational landscape is fully consistent with the two formalized pillars
(non-abelian braiding + an infinite-order braid). No counterexamples were found.
The full analytic density-in-`SU(3)` claim was *not* tested numerically here and
remains a future direction.
