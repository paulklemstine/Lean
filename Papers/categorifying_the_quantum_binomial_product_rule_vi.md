# Computational Evidence — quantum binomial characters of plethystic modules

We treat the formal character (principal specialisation) of `Sym^a Sym^b E`, for
`E` the two-dimensional standard representation, as the Gaussian binomial
coefficient `[a+b, a]_q ∈ ℤ[q]`, defined by the `q`-Pascal recurrence
`[n+1,k+1]_q = [n,k]_q + q^{k+1}[n,k+1]_q`.

## 1. Small-case table of `[n,k]_q`

```
[0,0] = 1
[1,0] = 1        [1,1] = 1
[2,0] = 1        [2,1] = 1 + q            [2,2] = 1
[3,0] = 1        [3,1] = 1 + q + q^2      [3,2] = 1 + q + q^2       [3,3] = 1
[4,0] = 1        [4,1] = 1 + q + q^2 + q^3
[4,2] = 1 + q + 2q^2 + q^3 + q^4          [4,3] = 1 + q + q^2 + q^3  [4,4] = 1
```

Checks performed (all confirmed against the recurrence):

* **Row-symmetry (Hermite reciprocity):** `[3,1] = [3,2]`, `[4,1] = [4,3]`,
  and `[4,2]` is palindromic. In general `[n,k]_q = [n,n-k]_q`.
* **Specialisation `q = 1`:** each polynomial's coefficient sum equals the
  ordinary binomial coefficient, e.g. `[4,2]_{q=1} = 1+1+2+1+1 = 6 = C(4,2)`.
* **Constant term:** every `[n,k]_q` with `k ≤ n` has constant term `1`
  (the unique lowest graded piece); above the diagonal `[n,k]_q = 0`.
* **`q`-integer:** `[n,1]_q = 1 + q + ⋯ + q^{n-1}`, verified for `n ≤ 5`.

## 2. Graded dimensions and Hermite reciprocity

Setting `gradedDim(a,b) = [a+b, a]_q`:

```
gradedDim(2,1) = [3,2] = 1 + q + q^2
gradedDim(1,2) = [3,1] = 1 + q + q^2      →  gradedDim(2,1) = gradedDim(1,2)
gradedDim(2,2) = [4,2] = 1 + q + 2q^2 + q^3 + q^4  (palindrome, self-dual)
```

The reciprocity `gradedDim(a,b) = gradedDim(b,a)` was checked for all
`a,b ≤ 4`; no counterexample exists (it is now proved in general).

## 3. Filtration step (categorified product rule)

The first graded piece of the field-independent filtration is the identity

```
gradedDim(a+1,b+1) = gradedDim(a,b+1) + q^{a+1} · gradedDim(a+1,b).
```

Numerical check at `(a,b) = (1,1)`:
`gradedDim(2,2) = 1 + q + 2q^2 + q^3 + q^4`, while
`gradedDim(1,2) + q^2·gradedDim(2,1) = (1+q+q^2) + q^2(1+q+q^2)
 = 1 + q + 2q^2 + q^3 + q^4`. ✓

## 4. Sequence identification

The triangle of coefficients of `[n,k]_q` read by antidiagonals is the classical
Gaussian-binomial (`q`-binomial) triangle, OEIS **A022166**. Its `q = 1`
projection is Pascal's triangle, OEIS **A007318**. The central column
`[2n,n]_q` (graded dimension of `Sym^n Sym^n E`) begins
`1, 1+q, 1+q+2q^2+q^3+q^4, …`, matching OEIS **A008967**-style central
Gaussian binomials.

## 5. Counterexample hunt

The two candidate failure modes were tested:

* **Reciprocity failing off the palindromic center** — none found; every row is
  symmetric.
* **Form-A alone determining reciprocity** — this *does* fail: matching the two
  expansions of `[a+b,a]` and `[a+b,b]` by the single Pascal rule leaves a
  residual `(1-q^{b+1})v = (1-q^{a+1})u`. This residual is exactly the
  absorption identity, which is why the proof genuinely needs a second
  (dual) recurrence. This observed obstruction drove the final proof design.

All computational evidence is consistent with — and now subsumed by — the fully
proved statements in `Filtration.lean`.
