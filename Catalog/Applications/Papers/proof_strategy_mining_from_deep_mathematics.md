# Computational Evidence — Tropical Polynomial Functions

Domain: Tropical (max-plus). A tropical polynomial of degree `d` with coefficients
`c : Fin (d+1) → ℝ` is the function
  p(x) = max_{0 ≤ i ≤ d} (c i + i·x).

## 1. Small-case calculations

Take d = 2, c = (c₀, c₁, c₂) = (0, 0, 0):
  p(x) = max(0, x, 2x).
- x = -1 : max(0, -1, -2) = 0      (constant term dominates)
- x =  0 : max(0,  0,  0) = 0
- x =  1 : max(0,  1,  2) = 2      (leading term dominates)
- x =  3 : max(0,  3,  6) = 6 = 2·3 (leading term dominates)
This is convex, piecewise-linear, monotone increasing, with corner ("tropical root")
at x = 0 where two monomials tie.

Take c = (0, 1, 0): p(x) = max(0, 1+x, 2x).
- x = -2 : max(0, -1, -4) = 0
- x = -1 : max(0,  0, -2) = 0  (tie of c₀ and c₁: corner at x = -1)
- x =  0 : max(0,  1,  0) = 1
- x =  1 : max(0,  2,  2) = 2  (tie of c₁ and c₂: corner at x = 1)
- x =  2 : max(0,  3,  4) = 4  (leading dominates)
Two tropical roots at x = -1 and x = 1, slope sequence 0 → 1 → 2 (integer slopes).

## 2. Asymptotic / leading-term dominance

For x ≥ (max_i c i − c_d)/1 (a finite threshold, since slopes are 0,1,...,d and the
top slope d is strictly largest among slopes that appear, when d ≥ 1 with strict
exponent gaps), the leading monomial c_d + d·x is ≥ every other monomial, so
p(x) = c_d + d·x exactly. Confirmed numerically above (x = 3 case gives 2x).

## 3. Convexity / monotonicity

p is a finite max of affine functions x ↦ c i + i·x, each convex (affine) and, since
the slopes i ≥ 0, monotone nondecreasing. A finite max of convex functions is convex;
a finite max of monotone functions is monotone. Hence p is convex and monotone. No
counterexample exists; verified on the tables above (differences of consecutive slopes
are nonnegative).

## 4. Freshman's dream (tropical power)

In max-plus, multiplication is `+` and the n-th tropical power is `n·`. The identity
  n · max(x, y) = max(n·x, n·y)   (n : ℕ)
holds because scaling by a nonnegative constant commutes with max. Checked:
  3·max(2, 5) = 3·5 = 15 = max(6, 15). ✓

## Conclusion

All universal claims (convexity, monotonicity, monomial lower bound, attainment of the
max, leading-term dominance for large x, tropical freshman's dream) survived the
counterexample hunt. We now formalize them in Lean 4.
