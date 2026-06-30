# Computational Evidence — Combinatorial Nerve Euler Characteristic

We model a finite simplicial complex as a finite set of faces `X ⊆ 𝒫(V)` (each face is
the finite set of its vertices), with Euler characteristic the signed face count

    χ(X) = ∑_{σ ∈ X} (-1)^{|σ|}.

(Using `(-1)^{|σ|}` rather than `(-1)^{dim σ} = (-1)^{|σ|-1}` flips the overall sign of the
reduced Euler characteristic; it keeps every exponent a genuine natural number and remains an
additive set invariant, which is all the nerve bookkeeping requires.)

## 1. Small-case calculations

### 1a. A combinatorial circle ∂Δ²
Vertices `{0},{1},{2}`; edges `{0,1},{1,2},{0,2}`.

    χ = 3·(-1)^1 + 3·(-1)^2 = -3 + 3 = 0.

This matches the (sign-shifted) Euler characteristic of `S¹`. Verified in Lean as
`example : eulerChar circle = 0 := by decide`.

### 1b. Inclusion–exclusion over a 2-set cover (Mayer–Vietoris check)
Cover the circle by two arcs:

    A₀ = {0},{1},{2},{0,1},{0,2}     (everything except edge {1,2})
    A₁ = {0},{1},{2},{1,2}           (the remaining edge and its vertices)

Then `A₀ ∪ A₁ = circle`, and the intersection is `Y_{0,1} = {0},{1},{2}` (three vertices).

    χ(A₀) = 3·(-1) + 2·(+1) = -1
    χ(A₁) = 3·(-1) + 1·(+1) = -2
    χ(Y_{0,1}) = 3·(-1) = -3

Nerve / inclusion–exclusion alternating sum (signs `(-1)^{|t|+1}`):

    χ(A₀) + χ(A₁) - χ(Y_{0,1}) = (-1) + (-2) - (-3) = 0 = χ(circle).  ✓

This is exactly `eulerChar_biUnion`.

### 1c. Bigraded sign factorisation (E¹ page)
A bigraded generator `(t, m)` (nerve index `t`, internal Morse dimension `m`) sits in total
degree `n = m + |t| - 1` and carries sign `(-1)^{m + |t| - 1}`. Checking the factorisation
`(-1)^{m+|t|-1} = (-1)^{|t|+1}·(-1)^m`:

    |t|=1: (-1)^{m}      = (-1)^2·(-1)^m = (-1)^m            ✓
    |t|=2: (-1)^{m+1}    = (-1)^3·(-1)^m = -(-1)^m           ✓
    |t|=3: (-1)^{m+2}    = (-1)^4·(-1)^m = (-1)^m            ✓

So the nerve sign and the internal Morse sign separate cleanly. This is
`nerveTotalEuler_eq_signed`.

### 1d. Degree grading collapses to χ(X)
Take the trivial all-critical gradient field on each `Y_t` (every face critical), so
`c t m = #{m-dimensional faces of Y_t}` and the per-piece discrete Morse equality
`χ(Y_t) = ∑_m (-1)^m c t m` holds by definition (this is `eulerChar_eq_sum_by_dim`).
With the 2-arc cover of 1b and `D = 2`, `B = 3`:

    nerveRank n = (#bigraded generators in total degree n)
    ∑_n (-1)^n · nerveRank n = 0 = χ(circle).  ✓

This is the capstone `eulerChar_eq_degreeGraded_nerve`.

## 2. OEIS / sequence note

The alternating binomial structure of the nerve signs over a `k`-element cover is governed by
`∑_{j=1}^{k} (-1)^{j+1} C(k,j) = 1` (the nonempty-subset alternating sum), i.e. the first
difference of the all-ones sequence; the row sums of signed Pascal data
(OEIS A000007 / A130595-type alternating identities). No new sequence is introduced; the
content is the *bigraded* coupling of these nerve signs with the internal Morse signs.

## 3. Counterexample hunt

- **Drop the nerve signs** `(-1)^{|t|+1}` in `eulerChar_biUnion`: fails already on 1b
  (`(-1)+(-2)+(-3) = -6 ≠ 0`). Confirms the alternation is load-bearing.
- **Drop the degree bound** `hB` in `nerve_degree_grading`: generators of degree `≥ B` are
  silently dropped, so the ranks no longer sum to the total Euler characteristic. Confirms
  `hB` is necessary (mirrors the bounded-strip requirement of the spectral sequence).
- **Remove the `|t| ≥ 1` correction** in the sign factorisation: `|t|-1` would mis-truncate
  at `|t|=0`, but empty index sets are excluded from the nerve, so the guarded statement is
  exactly the true one.

No counterexample to the stated (guarded) theorems was found; each guard corresponds to a
genuine boundary of validity.

## 4. Conclusion

All four computational checks agree with the formal theorems in
`EulerCharacteristic.lean` and `NerveComplex.lean`. The evidence supports the claim that the
ranks of the combinatorial nerve chain groups reproduce `χ(X)` — the Euler-characteristic
shadow of the chain homotopy equivalence — and pins down precisely which sign data and bounds
are required.
