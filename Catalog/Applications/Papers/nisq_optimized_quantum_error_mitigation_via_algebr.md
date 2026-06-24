# Computational Evidence — Agreement-Complex `β₀` and Majority Decoding

Concise sanity checks performed before formalisation. All claims below are now
backed by the proved theorems in this directory; this file records the
small-case exploration that guided the statements.

## 1. `betti0` of the agreement complex (small cases)

Model `betti0 (agree s)` = number of distinct values in the readout `s`.

| readout `s` (length `n`) | distinct values | `betti0 (agree s)` | consensus? |
|--------------------------|-----------------|--------------------|------------|
| `[T]`                    | {T}             | 1                  | yes        |
| `[T,T,T]`                | {T}             | 1                  | yes        |
| `[T,F]`                  | {T,F}           | 2                  | no         |
| `[T,T,F]`                | {T,F}           | 2                  | no         |
| `[F,F,F,F]`              | {F}             | 1                  | yes        |

Observed invariant: `1 ≤ betti0 (agree s) ≤ 2` for every nonempty readout, with
value `1` exactly on consensus. This is exactly
`betti0_agree_pos` / `betti0_agree_le_two` / `betti0_agree_eq_one`.

## 2. Error-count conservation (`errors_complement`)

For each readout above, `errors s true + errors s false`:

| readout      | `errors true` | `errors false` | sum | `n` |
|--------------|---------------|----------------|-----|-----|
| `[T,T,T]`    | 0             | 3              | 3   | 3   |
| `[T,T,F]`    | 1             | 2              | 3   | 3   |
| `[T,F]`      | 1             | 1              | 2   | 2   |
| `[F,F,F,F]`  | 4             | 0              | 4   | 4   |

Sum always equals `n` → `errors_complement`.

## 3. Nearest-codeword / majority optimality (`majority_eq_min_errors`)

| readout      | `ones` | `majority` | `errors (majority)` | `min(errors T, errors F)` |
|--------------|--------|------------|---------------------|---------------------------|
| `[T,T,F]`    | 2      | T          | 1                   | 1                         |
| `[T,F]`      | 1      | F (tie)    | 1                   | 1                         |
| `[F,F,F,F]`  | 0      | F          | 0                   | 0                         |

The decoded bit always attains the minimum Hamming distance, including the tie
case `n` even with `ones = n/2` (decoder favours `false`, both distances `n/2`).
This is `majority_nearest_codeword` / `majority_eq_min_errors`.

## 4. Counterexample hunt

- *Naive iff* `majority s = b ↔ 2*errors s b < n` FAILS for `b = false` at the
  tie `[T,F]` (`2*errors false = 2 = n` yet `majority = false`). Hence the
  one-sided / `true`-only statements in `MajorityDecoding.lean` and the `≤`/`min`
  (not strict) formulation here.
- *`betti0 ≤ 1` always* FAILS at `[T,F]` (`betti0 = 2`). Hence the `≤ 2` bound.
- No counterexample found to `errors_complement`, `majority_eq_min_errors`, or
  the `betti0 ∈ {1,2}` dictionary across all readouts of length `≤ 4`.

## 5. OEIS

No nontrivial integer sequence is generated; the invariants are bounded
(`betti0 ∈ {1,2}`) or linear (`errors` sums to `n`), so an OEIS lookup is not
informative here.
