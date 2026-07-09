# Computational Evidence: Variance ↔ Squarefree Count

## The connector claim

For a **Rademacher random multiplicative function** `f` (independent signs `ε_p = ±1`
attached to the primes, `f(n) = ∏_{p ∣ n} ε_p` for squarefree `n` and `f(n) = 0`
otherwise), the variance of the partial sum over any finite set `A` of integers equals
the number of squarefree integers in `A`:

```
Var( ∑_{n ∈ A} f(n) )  =  #{ n ∈ A : n squarefree }.
```

This is the exact number-theoretic identity underlying the normalization
`σ(x,y)² = Var(∑_{x ≤ n ≤ x+y} f(n))` in the Rademacher short-interval CLT: since the
count of squarefree integers in `[x, x+y]` is `(6/π²)y + o(y)`, one gets
`σ(x,y)² ∼ (6/π²) y`.

## Small-case brute-force verification

We enumerate **all** `2^{π(b)}` sign patterns of the primes up to `b`, compute the sum
`S = ∑_{a ≤ n ≤ b} f(n)` for each pattern, and form the exact rational variance
`E[S²] − (E[S])²`. We compare with a direct count of squarefree integers in `[a,b]`.

| interval `[a,b]` | brute-force variance | squarefree count | match |
|------------------|----------------------|------------------|-------|
| `[10,20]`        | 7                    | 7                | ✓     |
| `[2,12]`         | 7                    | 7                | ✓     |

(Reproduced with an exact `ℚ`-valued computation in Lean; no floating point.)

In every case the **mean `E[S]` is `0`** (as long as `1 ∉ [a,b]`, i.e. `a ≥ 2`), because
`E[f(n)] = 0` for every `n ≥ 2`: any such squarefree `n` has a prime factor `p`, and
averaging over the independent sign `ε_p` gives `0`.

## Why the identity holds (covariance computation)

Independence of the `ε_p` and `ε_p² = 1` give, for `m, n` squarefree,
```
E[f(m) f(n)] = ∏_p E[ ε_p^{[p∣m] + [p∣n]} ] = 1  ⟺  ∀ p, [p∣m] = [p∣n]  ⟺  m = n,
```
the last step using that a squarefree number equals the product of its prime divisors.
Hence `Cov(f(m), f(n)) = δ_{m,n}·[m squarefree]`, and summing over `m,n ∈ A` yields the
squarefree count. This is precisely the argument formalized in
`Pythagorean/RademacherVariance.lean`.

## OEIS

The squarefree counting function is classical; the count of squarefree numbers `≤ n`
is OEIS [A013928](https://oeis.org/A013928) and the squarefree numbers themselves are
[A005117](https://oeis.org/A005117). No new sequence arises.

## Counterexample hunt

No counterexample exists: the identity is proved in full generality (any finite set `A`,
any finite set `P` of primes containing the prime factors of the elements of `A`).
The brute-force search over all sign patterns for several intervals found perfect
agreement, consistent with the theorem.
