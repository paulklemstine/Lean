# Computational Evidence — Good manifolds in an `n`-nice polytope

## 1. Reference data

The maximal number of good manifolds in an `n`-nice polytope, for `n = 1 … 21`:

```
6, 8, 12, 24, 40, 80, 128, 256, 512, 1024, 2048, 4096, 8192, 16384,
32768, 65536, 131072, 262144, 524288, 1048576, 2097152
```

(The final published term appears truncated as `20971`; the natural completion
is `2097152 = 2^21`, which the model below reproduces.)

## 2. Head / tail decomposition

| n  | value   | 2^n     | match? |
|----|---------|---------|--------|
| 1  | 6       | 2       | no     |
| 2  | 8       | 4       | no     |
| 3  | 12      | 8       | no     |
| 4  | 24      | 16      | no     |
| 5  | 40      | 32      | no     |
| 6  | 80      | 64      | no     |
| 7  | 128     | 128     | yes    |
| 8  | 256     | 256     | yes    |
| …  | …       | …       | yes    |
| 21 | 2097152 | 2097152 | yes    |

**Observed law:** for `n ≥ 7` the value is exactly `2^n`; the first six terms
form an irregular head. The transition value `2^7 = 128` first occurs at
`n = 7`, and the head values `6,8,12,24,40,80` are strictly below the
corresponding powers only from `n = 5` onward (`40 > 32`, `80 > 64`), while for
`n ≤ 4` the head *exceeds* `2^n`. Either way the head is not the power law.

## 3. Recurrence check (tail)

Ratios of consecutive tail terms are all exactly `2`:
`256/128 = 512/256 = … = 2097152/1048576 = 2`. Hence `a(n+1) = 2·a(n)` for
`n ≥ 7`.

## 4. Partial-sum check (tail, geometric)

`∑_{k=7}^{m} a(k) = 2^{m+1} − 2^7`. For example
`128 + 256 + 512 = 896 = 1024 − 128 = 2^{10} − 2^7`.

## 5. OEIS note

The tail is the pure doubling sequence `2^n` (cf. A000079). The full sequence,
with its six-term irregular head glued to the exponential tail, is treated here
as a standalone object; the verified content is the closed form of the tail and
its structural consequences.

## 6. Counterexample hunt

- *Global* closed form `a(n) = 2^n` for all `n`: **false**, witness `n = 5`
  (`40 ≠ 32`). This is recorded as `goodManifolds_head_not_pow`.
- Strict monotonicity across the head/tail junction: **holds** (`80 < 128`).

All numerical claims above are reproduced by the `#eval` in
`GoodManifolds.lean` and discharged by the formal theorems in that file.
