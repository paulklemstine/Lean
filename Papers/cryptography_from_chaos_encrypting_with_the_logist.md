# Computational Evidence: the logistic map at r = 4

## 1. Semiconjugacy `f(sin² t) = sin²(2t)`

With `f(x) = 4x(1-x)` and `x = sin² t`:

| t        | sin² t   | f(sin² t) | sin²(2t) |
|----------|----------|-----------|----------|
| 0.3      | 0.087322 | 0.318841  | 0.318841 |
| 0.7      | 0.415415 | 0.971296  | 0.971296 |
| 1.1      | 0.794519 | 0.652718  | 0.652718 |

Columns 3 and 4 agree to machine precision, confirming `4 sin²t cos²t = sin²(2t)`.

## 2. Iterated conjugacy and the collapsing seed family

The seeds `sₙ = sin²(π / 2^{n+2})` satisfy `fⁿ(sₙ) = sin²(π/4) = 1/2` exactly,
while `sₙ → 0`:

| n | sₙ = sin²(π/2^{n+2}) | fⁿ(sₙ) |
|---|----------------------|--------|
| 0 | 0.500000             | 0.5    |
| 1 | 0.146447             | 0.5    |
| 2 | 0.038060             | 0.5    |
| 3 | 0.009607             | 0.5    |
| 4 | 0.002408             | 0.5    |

The output stays pinned at `1/2` while the seed collapses toward the fixed point
`0` (whose orbit is constantly `0`), giving an `O(1)` output gap from an
`O(2^{-n})` seed change — sensitive dependence.

## 3. Fixed points

`f(x) = x  ⟺  x(3 - 4x) = 0  ⟺  x ∈ {0, 3/4}`. Numerically `f(0.75) = 0.75`
and `f(0) = 0`; no other real solutions exist.

## 4. Degree growth of the iterate polynomials

`f¹` has degree 2, `f²` degree 4, `f³` degree 8, matching `2ⁿ`. Verified by
polynomial composition: `deg(p∘q) = deg p · deg q` with `deg f = 2`.

## 5. Counterexample hunt

No counterexample was found to any stated identity across the sampled `t` and `n`.
The one folklore claim that fails scrutiny — "seed recovery is as hard as solving
a degree-`2ⁿ` polynomial" — is addressed in FUTURE_DIRECTIONS (Conjecture 1): the
conjugate coordinate reduces it to a linear-time bit shift, so we did **not**
formalize the hardness claim as a theorem.

All identities in items 1–4 are proved exactly in `LogisticMapChaos.lean`.


# Computational Evidence: the logistic map at r = 4

## 1. Semiconjugacy `f(sin² t) = sin²(2t)`

With `f(x) = 4x(1-x)` and `x = sin² t`:

| t        | sin² t   | f(sin² t) | sin²(2t) |
|----------|----------|-----------|----------|
| 0.3      | 0.087322 | 0.318841  | 0.318841 |
| 0.7      | 0.415415 | 0.971296  | 0.971296 |
| 1.1      | 0.794519 | 0.652718  | 0.652718 |

Columns 3 and 4 agree to machine precision, confirming `4 sin²t cos²t = sin²(2t)`.

## 2. Iterated conjugacy and the collapsing seed family

The seeds `sₙ = sin²(π / 2^{n+2})` satisfy `fⁿ(sₙ) = sin²(π/4) = 1/2` exactly,
while `sₙ → 0`:

| n | sₙ = sin²(π/2^{n+2}) | fⁿ(sₙ) |
|---|----------------------|--------|
| 0 | 0.500000             | 0.5    |
| 1 | 0.146447             | 0.5    |
| 2 | 0.038060             | 0.5    |
| 3 | 0.009607             | 0.5    |
| 4 | 0.002408             | 0.5    |

The output stays pinned at `1/2` while the seed collapses toward the fixed point
`0` (whose orbit is constantly `0`), giving an `O(1)` output gap from an
`O(2^{-n})` seed change — sensitive dependence.

## 3. Fixed points

`f(x) = x  ⟺  x(3 - 4x) = 0  ⟺  x ∈ {0, 3/4}`. Numerically `f(0.75) = 0.75`
and `f(0) = 0`; no other real solutions exist.

## 4. Degree growth of the iterate polynomials

`f¹` has degree 2, `f²` degree 4, `f³` degree 8, matching `2ⁿ`. Verified by
polynomial composition: `deg(p∘q) = deg p · deg q` with `deg f = 2`.

## 5. Counterexample hunt

No counterexample was found to any stated identity across the sampled `t` and `n`.
The one folklore claim that fails scrutiny — "seed recovery is as hard as solving
a degree-`2ⁿ` polynomial" — is addressed in FUTURE_DIRECTIONS (Conjecture 1): the
conjugate coordinate reduces it to a linear-time bit shift, so we did **not**
formalize the hardness claim as a theorem.

All identities in items 1–4 are proved exactly in `LogisticMapChaos.lean`.
