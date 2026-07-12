# Computational Evidence — The Aleph-One Surface

The central claims are cardinal-arithmetic and topological identities about the
Hilbert cube `Q = ℕ → [0,1]`; finite computation cannot literally evaluate a
cardinal such as `𝔠` or `ℵ₁`. We instead record the finite shadows of each claim,
which is where a false conjecture would first break.

## 1. The finite-cube tower (padding / truncation)

The embedding of the `n`-cube into `Q` pads with zeros; truncation reads the
first `n` coordinates. Small cases (coordinates shown as a finite prefix):

| `n` | point of `[0,1]ⁿ`      | padded point of `Q` (prefix) | truncate back |
|-----|------------------------|------------------------------|---------------|
| 1   | `(0.7)`                | `0.7, 0, 0, 0, …`            | `(0.7)`       |
| 2   | `(0.7, 0.2)`           | `0.7, 0.2, 0, 0, …`          | `(0.7, 0.2)`  |
| 3   | `(0.7, 0.2, 0.9)`      | `0.7, 0.2, 0.9, 0, …`        | `(0.7,0.2,0.9)` |

Truncation ∘ padding is the identity for every `n` — the finite witness that the
padding map is injective and inducing. No counterexample exists because the
identity holds coordinate-by-coordinate.

## 2. Cardinal arithmetic, finite check of the exponent law

The Euclidean cardinality proof rests on `𝔠 ^ n = 𝔠` for `n ≥ 1`, whose finite
analogue for a base of size `b ≥ 2` is `bⁿ`, strictly increasing — so the
collapse `𝔠 ^ n = 𝔠` is a purely infinite phenomenon driven by `𝔠 ^ ℵ₀ = 𝔠`.
The exponent monotonicity `1 ≤ n ≤ ℵ₀` used in the squeeze is checked directly:
`𝔠 = 𝔠¹ ≤ 𝔠ⁿ ≤ 𝔠^{ℵ₀} = 𝔠`.

## 3. Coordinate bijections behind self-similarity

The self-similarity homeomorphisms need explicit bijections of the index set:

* `ℕ ≃ ℕ ⊕ ℕ` — e.g. `0↦inl 0, 1↦inr 0, 2↦inl 1, 3↦inr 1, …` (even/odd split).
* `ℕ ≃ ℕ ⊕ Unit` — e.g. `0↦inr (), n+1↦inl n` (peel the head).

Both are genuine bijections on every finite prefix, the finite evidence that the
countable coordinate set can be re-partitioned without loss — the combinatorial
core of `Q ≃ Q × Q` and `Q ≃ Q × [0,1]`.

## 4. Counterexample hunt

The one claim that *fails* — deliberately excluded from the results — is a
literal "Hausdorff dimension equal to `ℵ₁`". Hausdorff dimension is real-valued
(at most `∞`), so no space has dimension a cardinal `> ∞`; the small-case check
is immediate (any metric space returns a value in `[0,∞]`). The corrected,
provable formulation ("contains cubes of every finite dimension") passes all
finite checks above.

## Summary

Every finite shadow of the four surviving claim-families is consistent; the sole
naive formulation that fails a finite sanity check (dimension = a cardinal) was
identified and replaced by its correct transfinite-dimension statement.
