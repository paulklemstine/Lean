# Computational Evidence — Hankel law of the Möbius discriminant

## 1. The second-order Hankel recurrence `p·D(n+1) = −r·D(n)`

For a second-order recurrence `p·a(n+2) = q·a(n+1) + r·a(n)` set the pointwise
Hankel determinant `D(n) = a(n)·a(n+2) − a(n+1)²`.

Test sequence `a(0)=2, a(1)=5, a(n+2) = 3·a(n+1) − 2·a(n)` (so `p=1, q=3, r=−2`,
hence `−r = 2`).  Computing `(D(n+1), 2·D(n))`:

```
[(-6, -6), (-12, -12), (-24, -24), (-48, -48), (-96, -96), (-192, -192)]
```

Perfect agreement: `D(n+1) = −r·D(n)` at every index, and here `D(n) = -6·2ⁿ`,
matching the closed form `pⁿ·D(n) = (−r)ⁿ·D(0)`.

## 2. Fibonacci / Cassini alternation as a special case

Fibonacci obeys `a(n+2) = a(n+1) + a(n)` (`p=q=r=1`).  Its discriminant:

```
D(0..5) = [-1, 1, -1, 1, -1, 1]
```

This is exactly `(−r)ⁿ·D(0) = (−1)ⁿ·(−1) = (−1)^{n+1}` (Cassini's identity).
Because `r = 1 > 0`, the sign necessarily **alternates**, so it is `+1` and `−1`
infinitely often.  This is the structural reason no coefficient-only invariant
can govern the sign in the second-order case.

## 3. Ratio monotonicity in the first-order case (`Δ > 0`)

For the Catalan recurrence `(n+2)·C(n+1) = 2(2n+1)·C(n)` (`Δ = 6 > 0`), the
consecutive ratios `C(n+1)/C(n) = 2(2n+1)/(n+2)` are `1, 2, 2.5, 2.8, …`,
strictly increasing — confirming strict log-convexity and the generalized
Turán inequalities proved in `MobiusDiscriminantLogConvex.lean`.

## Conclusion

The experiments confirm the two new theorems of this cycle:
* the exact Hankel recurrence and its geometric closed form (second order), and
* strict ratio monotonicity / generalized Turán inequalities (first order).
Both are proved unconditionally in Lean with `0` sorries.
