# Computational Evidence — Cantor ultrametric on the golden-mean truth space

This cycle formalizes **natural next step #1** from `FUTURE_DIRECTIONS.md`:
the Cantor first-disagreement ultrametric on the space of truth streams
`ℕ → Bool`, its metric axioms, and the exact identification of
radius-`2⁻ⁿ` closed balls with the prefix-agreement relation `AgreeTo n`.

## 1. The distance function

For `x, y : ℕ → Bool` let `firstDiff x y` be the least index at which the two
streams disagree (`0` by convention when they are equal), and set

```
cantorDist x y = if x = y then 0 else 2 ^ (- firstDiff x y)
```

Small cases (writing streams as bit lists on their differing prefix):

| x prefix | y prefix | first diff | dist   |
|----------|----------|------------|--------|
| 000…     | 000…     | —          | 0      |
| 1…       | 0…       | 0          | 1      |
| 01…      | 00…      | 1          | 1/2    |
| 011…     | 010…     | 2          | 1/4    |
| 0110…    | 0111…    | 3          | 1/8    |

So the distance takes exactly the values `{0} ∪ {2⁻ᵏ : k ∈ ℕ}`, the standard
Cantor-space scale.

## 2. Ultrametric inequality — spot check

Strong triangle inequality `d(x,z) ≤ max (d(x,y)) (d(y,z))`.
Reason: if `x,y` agree on the first `a` bits and `y,z` agree on the first `b`
bits, then `x,z` agree on the first `min a b` bits, hence
`firstDiff x z ≥ min (firstDiff x y) (firstDiff y z)`, giving
`d(x,z) = 2^(-firstDiff x z) ≤ 2^(-min) = max (d(x,y)) (d(y,z))`.

Numeric check: `x=011…`, `y=010…`, `z=000…`.
`d(x,y)=1/4` (first diff at index 2), `d(y,z)=1/2` (index 1),
`d(x,z)=1/2` (index 1). Indeed `1/2 ≤ max(1/4,1/2)=1/2`. ✓ (equality, as
required whenever the two summands differ — a hallmark of ultrametrics).

## 3. Balls versus prefix agreement

Claim: `cantorDist x y ≤ 2^(-n) ↔ AgreeTo n x y` where
`AgreeTo n x y := ∀ k < n, x k = y k`.

- `x=y`: LHS `0 ≤ 2⁻ⁿ` true; RHS vacuously/always true. ✓
- `x≠y`: LHS `2^(-firstDiff) ≤ 2^(-n) ↔ n ≤ firstDiff`, and `n ≤ firstDiff`
  exactly says the first `n` bits agree, i.e. `AgreeTo n x y`. ✓

So the closed ball of radius `2⁻ⁿ` about `x` is *precisely* the
prefix-agreement class `{y | AgreeTo n x y}`. This is the exact bridge
between the metric scale and the combinatorial cylinder structure of the
previous cycle (whose depth-`n` cylinders number `fib (n+2)`).

## 4. Why no counterexample hunt is needed

Every statement proved is a universally quantified metric identity/inequality
with a short constructive witness (`firstDiff` via `Nat.sInf`), so the content
is a theorem rather than an empirical conjecture. The spot checks above are
consistent with all claims; the Lean file `FractalTruthMetric.lean` contains
the kernel-checked proofs.
