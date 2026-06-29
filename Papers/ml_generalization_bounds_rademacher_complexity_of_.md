# Computational Evidence — Rademacher Complexity of Neural Networks

All claims below are *also* machine-checked in `Basic.lean` / `NeuralNet.lean`;
this note records the small-case numerics that motivated the formal statements.

## Setup

Empirical Rademacher complexity of a finite class `A ⊆ (Fin n → ℝ)`:

```
empRad n A = (1 / 2^n) * Σ_{σ ∈ {±1}^n}  max_{a ∈ A} (1/n) Σ_i σ_i a_i.
```

## 1. Singleton class ⇒ zero complexity  (`empRad_singleton`)

`n = 1`, `A = {a}` with `a = (2)`.

| σ₀ | (1/1)·σ₀·a₀ |
|----|-------------|
| +1 | +2          |
| −1 | −2          |

`empRad = (1/2)(2 + (−2)) = 0`.  Matches the formal `empRad_singleton = 0`.
The cancellation is exactly `E_σ[σ] = 0` (`sum_sgn_coord_eq_zero`).

## 2. Symmetric two-point class ⇒ positive complexity, equals the magnitude

`n = 1`, `A = {(2), (−2)}`.

| σ₀ | max over A of σ₀·a₀ |
|----|---------------------|
| +1 | max(+2, −2) = 2     |
| −1 | max(−2, +2) = 2     |

`empRad = (1/2)(2 + 2) = 2`.  Positive — consistent with `empRad_nonneg`, and the
larger class has strictly larger complexity than the singleton (`empRad_mono`).

## 3. Positive homogeneity  (`empRad_smul`)

Scaling `A = {(2),(−2)}` by `c = 3` gives `{(6),(−6)}` with `empRad = 6 = 3·2`.
Confirms `empRad (c • A) = c · empRad A` for `c ≥ 0`.

## 4. Depth law  (`empRad_deepNet`, `empRad_deepNet_le_of_normalized`)

A layer with spectral factor `c` is pointwise scaling; an `L`-layer net scales by
`c^L` (`deepNet_eq`).  With base complexity `R = empRad A`:

| c   | L=1   | L=2   | L=4    | L=8     | trend          |
|-----|-------|-------|--------|---------|----------------|
| 0.5 | 0.5R  | 0.25R | 0.0625R| 0.0039R | shrinks (good) |
| 1.0 | R     | R     | R      | R       | flat           |
| 2.0 | 2R    | 4R    | 16R    | 256R    | explodes (bad) |

For `c ≤ 1` the complexity is non-increasing in depth (`empRad_deepNet_le_of_normalized`)
and strictly decreasing when `c < 1` (`empRad_deepNet_antitone_depth`); for `c > 1`
it grows geometrically — the classic motivation for spectral/weight normalization.

## 5. Weight normalization ⇒ smaller complexity & bound  (`empRad_weightNorm_mono`, `weightNorm_improves_genGap`)

Restricting the realizable class to a norm ball of radius `C` is monotone in `C`:
shrinking `C` shrinks the class (`normBall_subset`), hence the complexity, hence the
generalization bound `genGap = 2R + √(log(1/δ)/(2n))` (monotone in `R`).

## Counterexample hunt

* Nonnegativity *without* symmetry: tested asymmetric classes such as
  `A = {(2),(0)}` (`n=1`): values give `empRad = (1/2)(2 + 0) = 1 ≥ 0`. No
  counterexample found — and indeed `empRad_nonneg` needs no symmetry hypothesis.
* Homogeneity at `c = 0`: image collapses to `{0}`, `empRad = 0 = 0·R`. No
  counterexample.

No counterexamples to the four structural laws were found in any small case.
