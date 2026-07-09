# Computational Evidence: Symmetric colorings vs. one-weight colorings of `[t]^n`

## Setup

A word is `x ∈ [t]^n` (a length-`n` string over the alphabet `{0,…,t-1}`).
A coloring `c : [t]^n → C` is:

- **symmetric** if `c(x∘σ) = c(x)` for every coordinate permutation `σ`;
- **one-weight** if there are integer weights `w₀,…,w_{t-1}` and a function `f`
  with `c(x) = f(∑ᵢ w_{x ᵢ})`.

The *content* of a word is the vector `(m₀,…,m_{t-1})` where `m_j` is the number
of coordinates equal to `j`; note `∑ m_j = n` and each `m_j ∈ {0,…,n}`.

## Small-case reasoning

A symmetric coloring depends only on the content vector, since two words are
related by a coordinate permutation exactly when they have the same content.
So the number of symmetric colorings with palette of size `r` equals
`r^{#contents}`, where `#contents = C(n+t-1, t-1)` (compositions of `n` into `t`
nonnegative parts).

| `t` | `n` | `#contents = C(n+t-1,t-1)` |
|-----|-----|-----------------------------|
| 2   | 3   | 4                           |
| 2   | 5   | 6                           |
| 3   | 2   | 6                           |
| 3   | 3   | 10                          |
| 4   | 3   | 20                          |

## Why a single weight suffices — the base-`(n+1)` encoding

The key numerical observation: because every content coordinate lies in
`{0,…,n}`, the map

    content (m₀,…,m_{t-1})  ↦  ∑_j m_j (n+1)^j

is exactly reading `(m₀,…,m_{t-1})` as the digits of a base-`(n+1)` number.
Distinct contents therefore produce distinct sums. Concretely, the weighted
letter sum of a word equals this positional value, so it recovers the content.

Worked example (`t = 3`, `n = 3`, weights `w = (1, 4, 16)` since `n+1 = 4`):

| word (content `(m₀,m₁,m₂)`) | weighted sum `m₀·1 + m₁·4 + m₂·16` |
|-----------------------------|-------------------------------------|
| `(3,0,0)`                   | 3                                   |
| `(2,1,0)`                   | 6                                   |
| `(2,0,1)`                   | 18                                  |
| `(1,2,0)`                   | 9                                   |
| `(0,3,0)`                   | 12                                  |
| `(0,0,3)`                   | 48                                  |

All ten contents give ten distinct sums, confirming injectivity for this case.

## Counterexample hunt for a *fixed* (n-independent) weight vector

The equivalence is an existence statement: the separating weights are allowed to
depend on `n`. This dependence is necessary. Contents span a
`(t-1)`-dimensional simplex, whereas any fixed weight vector collapses them onto
a one-dimensional axis, so for `t ≥ 3` and `n` large enough every fixed integer
weight vector `w` sends two distinct contents to the same sum (pigeonhole on the
growing simplex against the bounded set of achievable sums per direction). For
example with `w = (0,1,2)` the contents `(1,0,1)` and `(0,2,0)` both have
weighted sum `2`. Hence no universal weight vector works, matching the theorem's
form.

## Conclusion

The computations support both directions:

1. Permuting coordinates never changes any weighted letter sum (forward
   direction, trivially verified on all small cases).
2. The base-`(n+1)` weights separate all contents (checked exhaustively for the
   cases above), so a symmetric coloring is one-weight.

These findings guided the formal development in
`HalesJewettSymmetricColorings.lean`, in particular the choice of base-`(n+1)`
weights and the positional-encoding injectivity argument.
