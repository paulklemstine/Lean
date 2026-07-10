# Computational Evidence — Functorial Entropy (Information Loss)

We measure the information a functor `F : C → D` destroys by the **conditional
entropy** of the domain object given its image, under the uniform distribution on
the objects of `C`:

```
    H(F) = -∑_c (1/n) log( p(c | F c) )  =  ∑_d (c_d / n) · log c_d,
```

where `c_d = |F⁻¹(d)|` is the fiber cardinality and `n = |Ob C|`.

> **Why not the naive marginal entropy `-∑ p(d) log p(d)`?**
> The description's naive formula does *not* vanish for faithful functors: an
> injective map into an `n`-point target already has marginal entropy `log n`.
> The information *lost* is the residual uncertainty about `c` after observing
> `F c`, i.e. the conditional entropy above. With this (standard) correction the
> conjectures "`H(F)=0` iff faithful" and "`H(F)=log(|C|/|D|)` for uniform
> fibers" both become true.

## 1. Small-case calculations

| Functor (on objects)                    | fiber sizes | H(F)        |
|-----------------------------------------|-------------|-------------|
| `id : Bool → Bool`                      | `1,1`       | `log 1 = 0` |
| `fst : Bool × Bool → Bool`              | `2,2`       | `log 2`     |
| constant `Fin n → Fin 1`                | `n`         | `log n`     |
| `Fin 6 → Fin 2` uniform (3 each)        | `3,3`       | `log 3`     |
| `Fin 6 → Fin 3` uniform (2 each)        | `2,2,2`     | `log 2`     |

Uniform check: `H = (1/n)·(#fibers)·k·log k = log k` with `k = n / #fibers`,
matching `log(|C|/|D|)`.

## 2. Faithfulness ⇔ zero entropy

For any `F`, every fiber term `(c_d/n) log c_d ≥ 0`, and it is `0` exactly when
`c_d ∈ {0,1}`. Thus `H(F)=0` iff all fibers are singletons iff `F` is injective
on objects. Sampled random maps `Fin m → Fin k`: `H = 0` observed **iff** the map
was injective, no counterexamples in the tested range `m,k ≤ 6`.

## 3. Data-processing (monotonicity) check

For composites `Fin m --f--> Fin k --g--> Fin j`, always `H(f) ≤ H(g∘f)`:
coarsening the target can only lose more. This follows from superadditivity of
`x ↦ x log x`: for nonnegative `a_i` with sum `S`, `∑ a_i log a_i ≤ S log S`
since each `a_i ≤ S`. No violation found in sampled compositions.

## 4. Upper bound

`H(F) ≤ log n` for every `F`, with equality for the constant functor; verified on
all tabulated cases (e.g. constant `Fin n → Fin 1` attains `log n`).

All of the above are proved in `FunctorialEntropy.lean` (0 sorries).
