# Computational Evidence — Elliptic Curve Arithmetic

All computations below were run in Lean (`#eval`) over `ZMod p` using
`affineCount p a b = #{(x,y) : y² = x³ + a x + b}` and
`pointCount = affineCount + 1` (the extra point is `∞`).

## 1. Point counts and Hasse check

For each curve we record `#E = pointCount`, the Frobenius trace
`t = (p+1) - #E`, and the integer Hasse witness `t² ≤ 4p`.

| field | curve `y²=x³+ax+b` | #E | p+1 | t = p+1−#E | t² | 4p | t²≤4p |
|------:|--------------------|---:|----:|-----------:|---:|---:|:-----:|
| F₅    | a=1, b=1           |  9 |   6 |   −3       |  9 | 20 |  ✓    |
| F₇    | a=1, b=1           |  5 |   8 |    3       |  9 | 28 |  ✓    |
| F₁₁   | a=1, b=1           | 14 |  12 |   −2       |  4 | 44 |  ✓    |
| F₁₃   | a=2, b=3           | 18 |  14 |   −4       | 16 | 52 |  ✓    |
| F₁₇   | a=1, b=1           | 18 |  18 |    0       |  0 | 68 |  ✓    |
| F₁₉   | a=1, b=2           | 12 |  20 |    8       | 64 | 76 |  ✓    |
| F₂₃   | a=1, b=1           | 28 |  24 |   −4       | 16 | 92 |  ✓    |

Every row satisfies `t² ≤ 4p`, i.e. `|#E − (p+1)| ≤ 2√p`. These are exactly the
instances `hasse_F5 … hasse_F23` proved in `HasseBound.lean`.

## 2. Nonsingularity (genuine elliptic curves)

The short Weierstrass discriminant indicator is `4a³ + 27b²` (mod p). A curve is
nonsingular iff this is nonzero.

| field | 4a³+27b² (mod p) | nonzero |
|------:|------------------|:-------:|
| F₅    | 1                | ✓       |
| F₇    | 3                | ✓       |
| F₁₁   | 9                | ✓       |
| F₁₃   | 2                | ✓       |
| F₁₇   | 14               | ✓       |
| F₁₉   | 17               | ✓       |
| F₂₃   | 8                | ✓       |

All curves chosen are nonsingular, so Hasse's theorem genuinely applies (the
bound can fail for singular cubics). Proved as `F*_nonsingular`.

## 3. Counterexample hunt

* **Hasse bridge `t² ≤ 4p ↔ |t| ≤ 2√p`.** Searched for an integer `t` and
  prime power that satisfies one side but not the other: none exists (the two
  are logically equivalent for `p ≥ 0`, which the Lean proof confirms). Dropping
  `0 ≤ p` breaks the `√(4p) = 2√p` rewrite, so the hypothesis is load-bearing.
* **F₁₇ edge case (`t = 0`).** A trace-zero ("balanced") curve gives `#E = p+1`
  exactly; the Hasse inequality becomes `0 ≤ 2√17`, true but non-vacuous as an
  instance of the general bound.
* **Finiteness keystone.** Removing the `Finite` hypothesis collapses
  `Nat.card E = 0`, after which the Lagrange statements become true-but-trivial;
  this confirms finiteness is the load-bearing input, not decoration.

## Notes

The point counts here are not in OEIS as a single sequence (they depend on the
chosen `(a,b)`), but per-curve traces match the standard small-curve tables.
Computation is finite and exact over `ZMod p`, so no approximation is involved.
