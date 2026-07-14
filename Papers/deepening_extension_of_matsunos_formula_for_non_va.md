# Computational Evidence

Theme: the μ-corrected extension of Matsuno's formula for the sharp/flat
λ-invariant difference under a quadratic twist, and its realization as a genuine
polynomial Iwasawa invariant (file
`Catalog/Bridges/MatsunoArithmeticPolynomialBridge.lean`).

All numbers below are produced by `#eval` on the actual Lean definitions, so they
double as machine checks of the definitions used in the proofs.

## 1. The 2-adic depth `n_ℓ = v₂((ℓ² − 1)/8)`

`#eval (List.range 12).map (fun k => (k, nEll k))`:

| k    | 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9 | 10 | 11 |
|------|---|---|---|---|---|---|---|---|---|---|----|----|
| n_k  | 0 | 0 | 0 | 0 | 0 | 0 | 2 | 1 | 0 | 1 | 2  | 0  |

For odd `ℓ ≥ 3` this matches the classical depth: `ℓ = 3,5 ⇒ n = 0`; `ℓ = 7,9 ⇒
n = 1`; and one checks `8·2^{n_ℓ} = 2^{v₂(ℓ−1)+v₂(ℓ+1)}` (e.g. `ℓ = 7`:
`8·2 = 16 = 2^{v₂6+v₂8} = 2^{1+3}`).

## 2. Total local μ-weight `weightSum D = Σ_{ℓ ∣ D} 2^{n_ℓ}`

`#eval [3,5,7,11,13,15,21,105].map (fun D => (D, weightSum D))`:

| D          | 3 | 5 | 7 | 11 | 13 | 15 | 21 | 105 |
|------------|---|---|---|----|----|----|----|-----|
| weightSum  | 1 | 1 | 2 | 1  | 1  | 2  | 3  | 4   |

Additivity over coprime factors is visible: `weightSum 15 = weightSum 3 +
weightSum 5 = 1 + 1 = 2`; `weightSum 105 = 1 + 1 + 2 = 4`. This is
`lambdaDiffMu_mul_coprime` / `lambdaInv_charElt_coprime`.

## 3. The μ-corrected invariant `lambdaDiffMu D NE μ ord`

Taking `NE = 1`, `ord ≡ 1` (so every classical local term vanishes and the whole
value is the μ-correction):

`#eval [(3,1),(3,2),(15,1),(105,2)].map (fun (D,m) => (D, m, lambdaDiffMu D 1 m (fun _ => 1)))`:

| (D, μ)   | (3,1) | (3,2) | (15,1) | (105,2) |
|----------|-------|-------|--------|---------|
| value    | 1     | 2     | 2      | 8       |

The split into classical term + μ-term
`[(D, μ, lambdaDiff, muTerm)] = [(3,1,0,1),(15,1,0,2),(105,2,0,8)]`
confirms `lambdaDiffMu = lambdaDiff + μ·weightSum`, so with a prime divisor the
value is strictly increasing in μ and the μ-term can dominate the classical term.

## 4. The polynomial realization (the bridge)

The characteristic element `charElt p D NE μ ord ∈ ℤ[X]` has genuine polynomial
Iwasawa invariants
`muInv 2 (charElt 2 D NE μ ord) = μ` (`muInv_charElt`) and
`lambdaInv 2 (charElt 2 D NE μ ord) = lambdaDiffMu D NE μ ord`
(`lambdaInv_charElt`). For `D = 3, NE = 1, μ = 1, ord ≡ 1` this gives a concrete
polynomial `X^0 · (2·X^1)^1 = 2X` with `μ_2 = 1` and `λ_2 = 1`, and the
μ-recovery `(λ − lambdaDiff)/weightSum = (1 − 0)/1 = 1 = μ`
(`mu_recovery_polynomial`). All three are machine-checked `example`s in the file.

## 5. Counterexample hunt

- **Is the realization exact for all inputs?** The two bridge theorems
  `muInv_charElt` and `lambdaInv_charElt` are universally quantified over
  `D, NE, μ, ord` and proved with no side conditions, so no counterexample exists.
- **Does μ-recovery need a prime divisor?** Yes. For `D = 1`,
  `D.primeFactors = ∅`, so `weightSum 1 = 0` and division by zero makes recovery
  meaningless; the hypothesis `D.primeFactors.Nonempty` in
  `mu_recovery_polynomial` / `lambdaInv_charElt_gt` is therefore necessary
  (matching the companion result `mu_not_injective_of_no_prime`).

No sequence lookup (OEIS) was pursued: the invariants depend on the auxiliary
data `NE, ord`, so they do not form a single canonical integer sequence.
