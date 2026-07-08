# Computational Evidence: Tropical Hash on the Min-Plus Semiring

We study the tropical hash `TSHA(h, m) = min_i (m_i + h_i)` and its two-key
refinement `TSHA2((h,h'), m) = (min_i (m_i + h_i), min_i (m_i + h'_i))` over the
min-plus semiring.

## 1. Small-case calculations (k = 3)

Let `h = (0,0,0)`.

| message m      | TSHA(h,m) = min(m_i) |
|----------------|----------------------|
| (0,0,0)        | 0                    |
| (0,1,1)        | 0                    |
| (0,5,9)        | 0                    |
| (2,0,7)        | 0                    |

All four distinct messages hash to `0`: single-key collisions are abundant
because the minimum ignores every non-minimal coordinate.

## 2. Collision abundance (one-wayness motivation)

Fix any message `m` with minimizing index `j`. Raising any *other* coordinate
`i ≠ j` (e.g. `m_i ↦ m_i + 1`) leaves `min_i(m_i + h_i)` unchanged, since the
minimizer `j` still attains the value `m_j + h_j`. Hence every message has a
one-parameter family of preimage-siblings — collisions are generic, not rare.

## 3. Two-key separation (the "twist")

Take `k = 2`, `h = (0,0)`, `h' = (1,0)`.

- `m  = (0,0)`  →  `TSHA(h,m)  = 0`,  `TSHA(h',m)  = min(1,0) = 0`.
- `m' = (0,1)`  →  `TSHA(h,m') = 0`,  `TSHA(h',m') = min(1,1) = 1`.

So `m` and `m'` collide under the single key `h` (both give `0`) but are
separated under the second key `h'` (`0 ≠ 1`). The construction generalizes to
every index set with at least two elements:

```
m  = 0                      (constant zero)
m' = [0 at a, 1 elsewhere]
h  = 0
h' = [1 at a, 0 elsewhere]
```

giving `TSHA(h,m) = TSHA(h,m') = 0` but `TSHA(h',m) = 0 ≠ 1 = TSHA(h',m')`.

## 4. Stability (1-Lipschitz in sup norm)

For all `m, m'`: `|TSHA(h,m) - TSHA(h,m')| ≤ max_i |m_i - m'_i|`. Numerically,
perturbing one coordinate by `ε` moves the hash by at most `ε`. This is the
tropical analogue of the avalanche-*absence* property: the tropical hash is
maximally smooth, which is exactly why the single-key version is easy to invert
approximately and why a second key is needed for discrimination.

## Conclusion

The evidence supports three provable claims, formalized in
`TropicalCryptocurrency.lean`:
1. `TSHA` is 1-Lipschitz in the sup norm (stability).
2. `TSHA` has non-unique preimages for every message (collisions generic).
3. `TSHA2` strictly separates single-key collisions (the two-key twist works).
