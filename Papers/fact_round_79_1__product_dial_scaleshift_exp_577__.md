# Computational Evidence — Paper 227 (exp 577 formalisation)

All numbers below were produced with Lean `#eval` in the same toolchain used for
the proofs (`Float`/`Nat`/`jacobiSym` evaluation).  They are *exploratory*: the
statements that are claimed as results are the Lean theorems in
`Catalog/Algebra/`, each proved without `sorry`.

## 1. Count-dial score `H_n² / n` (the dilution curve)

Model score of the equal-weight window `[0,n)` in the harmonic amplitude model
(`WindowOptimumFinite.countScore`):

| n | score | n | score |
|---|-------|---|-------|
| 1 | 1.000000 | 7 | 0.960415 |
| 2 | **1.125000** | 8 | 0.923343 |
| 3 | 1.120370 | 9 | 0.889229 |
| 4 | 1.085069 | 10 | 0.857886 |
| 5 | 1.042722 | 11 | 0.829060 |
| 6 | 1.000417 | 12 | 0.802493 |

The score rises to a **finite maximum** and then decays monotonically — the
qualitative shape of the measured sweep `.3207 → .0241 → .0150 → .0000`.  The
existence of that finite maximiser is the theorem
`WindowOptimumFinite.exists_window_optimum`; the decay to `0` is
`WindowOptimumFinite.countScore_tendsto_zero`.

## 2. Weighted-dial saturation

`W₂(n) = ∑_{i<n} 1/(i+1)²`:

| n | W₂(n) |
|---|-------|
| 400 | 1.642437 |
| 4000 | 1.644684 |
| 10⁶ | 1.644933 |

Ratio `W₂(400) / W₂(10⁶) = 0.998483`.  So the weighted dial is already `99.85%`
saturated at the published window `B* = 400`, matching the reported
`corr(W(10⁶), W(400)) = .999`.  The proved floor is
`WindowOptimumFinite.weighted_saturated_at_400` (`≥ 0.9975`, from the telescoping
tail bound `∑_{i≥n} 1/(i+1)² ≤ 1/n`).

## 3. Reciprocity-flip check (counterexample hunt)

For all ordered pairs of *distinct* odd primes `p, q < 100` (552 pairs) we tested

  `jacobiSym p q = − jacobiSym q p`  ⟺  `p ≡ 3 (mod 4) ∧ q ≡ 3 (mod 4)`.

Result: **552 pairs tested, 0 violations.**  This is the empirical form of
`ReciprocityFlipDial.legendre_flip_iff` / `jacobi_flip_iff_of_coprime`, which are
proved in general.

## 4. Unconditional flip density

Among all ordered pairs of odd primes below 200 (45 primes, 2025 pairs), the flip
condition `p ≡ q ≡ 3 (mod 4)` fires on 576 pairs, i.e. **28.44%** — close to the
reported unconditional rate `27.19%` on the experiment's population, and to the
`25%` idealised residue density proved in `ReciprocityFlipDial.twist_density`
(the excess is the usual Chebyshev bias of `3 mod 4` primes in short ranges).

## 5. Dispersion reading consistency

Reported pairs (fraction of raw dispersion, fraction of excess above Poisson):
`(0.3343, 0.4206)` for the count dial at `B = 400`, and `(0.4851, 0.6100)` for
the weighted dial at `B = 10⁶`.  Implied baseline dispersions
`D = 1/(1 − r/e)` are `4.8737` and `4.8839`; they agree to `0.011`.  The exact
algebra is `WindowOptimumFinite.reading_ratio`, and the numeric agreement (to
within `0.03`) is proved in `WindowOptimumFinite.readings_consistent`.

## 6. What was *not* found

No counterexample to any statement that was subsequently formalised; no evidence
of a window beyond `B*` at which the equal-weight count dial recovers (the model
score is strictly decreasing from `n = 3` onwards in the sampled range, and
proved to tend to `0`).
