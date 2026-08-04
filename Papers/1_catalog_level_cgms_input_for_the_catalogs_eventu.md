# Computational evidence

All theorems of this cycle live in `Catalog/Combinatorics/RamseyExponentialBounds.lean`
(Part II).  The numerical exploration below is *scratch* exploration used to pick
the statements; it is **not** a verification.  Every claim that is asserted is
proved in Lean.

## 1. The central binomial coefficient has no sub-four exponential bound

`C(2k,k)^{1/k} → 4` from below.  The catalog obstruction theorem
`not_hasSubFourUpperBound_centralBinom` says exactly that no fixed `ε > 0`
can dominate this sequence eventually.

| k | C(2k,k)/4^k | C(2k,k)^{1/k} |
|---|-------------|---------------|
| 1 | 0.500000 | 2.0000 |
| 2 | 0.375000 | 2.4495 |
| 3 | 0.312500 | 2.7144 |
| 5 | 0.246094 | 3.0219 |
| 10 | 0.176197 | 3.3625 |
| 20 | 0.125371 | 3.6055 |
| 50 | 0.079589 | 3.8026 |
| 100 | 0.056348 | 3.8866 |
| 500 | 0.025225 | 3.9707 |

The last column crosses every level `4 - ε`, which is the content of the Lean
proof: it uses `Nat.four_pow_lt_mul_centralBinom` (`4^k < k · C(2k,k)` for
`k ≥ 4`) together with `k = o(c^k)` for `c = 4/(4-ε) > 1`.  The loss in the
classical bound is only *polynomial* (`≈ 1/√(πk)`), and by the polynomial-loss
theorem of Part I a polynomial loss can never create an exponential saving.

## 2. Threshold elimination: small-case data

Known diagonal Ramsey numbers, compared with `4^k`:

| k | R(k,k) | 4^k | R(k,k)^{1/k} |
|---|--------|-----|--------------|
| 2 | 2 | 16 | 1.414 |
| 3 | 6 | 64 | 1.817 |
| 4 | 18 | 256 | 2.060 |

Every known value satisfies `R(k,k) < 4^k` strictly, and with a wide margin.
This is exactly the hypothesis `hsmall` of `subFour_threshold_elimination`: an
eventual sub-four estimate plus strict small-case inequalities gives one uniform
`ε > 0` valid from `k = 2` on.  A single computed value with `R(k,k) ≥ 4^k`
would falsify the hypothesis (and, by the theorem, is the *only* way threshold
elimination can fail).

## 3. The entropy base on a ratio window

`entropyBase x = x^{-x}(1-x)^{-(1-x)} = 2^{H₂(x)}`:

| x | entropyBase x |
|---|---------------|
| 0.10 | 1.3841 |
| 0.25 | 1.7548 |
| 0.30 | 1.8420 |
| 0.50 | 2.0000 |
| 0.70 | 1.8420 |
| 0.90 | 1.3841 |

Three features drive the equivalence proof `asymmetric_normalization`:
`entropyBase x > 1` for all `x ∈ (0,1)` (`one_lt_entropyBase`), the explicit
window bound `exp(b·(-log a) + (1-a)·(-log(1-b)))` (`entropyBase_le_of_mem_Icc`),
and the sharp global bound `entropyBase x ≤ 2` (`entropyBase_le_two`, from the
binary-entropy inequality `H₂ ≤ log 2`), which lets the equivalence be proved
even without compactness (`asymmetric_normalization_global`).
At the diagonal ratio `x = 1/2` the base is exactly `2`, and `2^(2k) = 4^k`,
which is why the two-parameter normalization specializes to the one-parameter
one (`hasSubFourUpperBound_diagonal_of_proportionalSaving₂`).

## 4. Counterexample hunt: how far does loss absorption go?

Losses `L(k)` multiplying `(4q)^k`:

* `L(k) = k^d` (polynomial), `L(k) = C` (constant), `L(k) = exp(√k)` — all
  satisfy `∀ δ>0, L(k) ≤ exp(δk)` eventually, and are absorbed (Part II,
  `hasSubFourUpperBound_of_subexponentialLoss`).
* `L(k) = 2^k` with `q = 1/2` gives `L(k)·(4q)^k = 4^k` exactly: the saving is
  destroyed.  This is formalized as `exponentialLoss_not_absorbable`, and
  `not_subexponentialLoss_two_pow` confirms `2^k` fails the hypothesis.

So the subexponential condition is not merely sufficient but sharp at the level
of pure exponentials.
