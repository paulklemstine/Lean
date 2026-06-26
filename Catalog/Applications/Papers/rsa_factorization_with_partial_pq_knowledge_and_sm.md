# Computational Evidence — Modified Wiener Attack with Partial p+q Knowledge

## Setup

RSA modulus `n = p·q`, primes `p > q`, Euler totient `φ(n) = (p-1)(q-1)`.
Public/private exponents satisfy the key equation `e·d = k·φ(n) + 1` for some
integer `k ≥ 1`.

Wiener's attack observes that `k/d` is an extremely good rational approximation of
`e/n`, so good that it must be a continued-fraction convergent of `e/n` when `d` is
small. The *modified* attack replaces `n` by a corrected modulus
`ñ = n + 1 - s`, where `s` is an estimate of `p+q` obtained from the known most
significant bits. The better `s` approximates `p+q`, the better `k/d` approximates
`e/ñ`, which tolerates a larger private exponent `d`.

## Key algebraic identities (verified by `#eval`)

Take `p = 17, q = 11`, so `n = 187`, `φ = 160`, `p+q = 28`.
Pick `d = 23`, `e = 7`, `k = 1` (since `7·23 = 161 = 1·160 + 1`).

1. **Classical key identity** `e·d - k·n = 1 - k·(p+q-1)`:
   - LHS `= 7·23 - 1·187 = -26`
   - RHS `= 1 - 1·(28-1) = -26`  ✓

2. **Modified key identity** `e·d - k·ñ = 1 - k·(p+q-s)` with `ñ = n+1-s`.
   With a deliberately wrong estimate `s = 30`:
   - LHS `= 7·23 - 1·(187+1-30) = 3`
   - RHS `= 1 - 1·(28-30) = 3`  ✓

3. **Exact approximation error** `e/ñ - k/d = (1 - k·(p+q-s))/(ñ·d)`.
   With the exact estimate `s = 28` (so `ñ = φ = 160`):
   - LHS `= 7/160 - 1/23 = 1/3680`
   - RHS `= (1 - 0)/(160·23) = 1/3680`  ✓

   Note `1/3680 < 1/(2·23²) = 1/1058`, so the Legendre convergent criterion holds and
   `k/d = 1/23` is recovered as a convergent of `e/ñ`.

## Counterexample hunt

The *uniqueness* claim "`b ≤ d` and both `|x-k/d|, |x-a/b| < 1/(2d²)` ⟹ `k/d = a/b`"
was stress-tested on random integer fractions; no counterexample exists because the
Farey separation `|a/b - c/e| ≥ 1/(be)` for distinct fractions is an identity-level
bound. This is the engine guaranteeing that the recovered denominator is the true `d`.

## Asymptotic reading

If a `δ`-fraction of the most significant bits of `p+q` is known, the residual error
satisfies `|p+q - s| ≤ Δ` with `Δ ≈ (p+q)^{1-δ}`. The convergent criterion
`2·d·(k·Δ + 1) < ñ` then admits private exponents up to roughly `d < n^{(1+δ)/2}`,
recovering the classical Wiener bound `d < n^{1/4}` at `δ = 0` (where only the leading
behaviour `Δ ≈ p+q ≈ n^{1/2}` is available).

All identities and inequalities used in the formal development are exact rational
arithmetic facts and require no floating point; the evidence above is reproduced
inside the Lean files as `decide`/`norm_num`-checked example lemmas.
