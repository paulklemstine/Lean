# Computational Evidence — Golden Ratio Diophantine Approximation

Topic: continued fractions and Diophantine approximation, with the golden ratio
`φ = (1+√5)/2` as the extremal (badly approximable) example.  Evidence supports
the two formalized theorems:

* `GoldenRatio.badly_approximable`: `|φ − p/q| ≥ (1/3)/q²` for all `q ≥ 1`.
* `GoldenRatioHurwitz.hurwitz_constant_sharp`: for `c > √5`, only finitely many
  `p/q` satisfy `|φ − p/q| < 1/(c q²)`.

## 1. Convergents of `φ` are ratios of consecutive Fibonacci numbers

`φ = [1;1,1,1,…]`, so its convergents are `F(n+1)/F(n)`.  The Binet identity
(`GoldenRatio.fib_binet`) gives `F(n+1) − φ·F(n) = ψⁿ` with `ψ = (1−√5)/2`,
`|ψ| ≈ 0.618034`.  Hence `|φ − F(n+1)/F(n)| = |ψ|ⁿ / F(n)` and

```
q² · |φ − F(n+1)/F(n)| = F(n) · |ψ|ⁿ  →  1/√5 ≈ 0.4472136 .
```

(The limit uses `φ·|ψ| = 1`.)

## 2. Table: `q² · |φ − p/q|` along the convergents

Computed in Lean (`Float`); see the `#eval` reproduced below.

| p   | q   | q²·|φ − p/q| |
|-----|-----|--------------|
| 1   | 1   | 0.618034 |
| 2   | 1   | 0.381966 |
| 3   | 2   | 0.472136 |
| 5   | 3   | 0.437694 |
| 8   | 5   | 0.450850 |
| 13  | 8   | 0.445825 |
| 21  | 13  | 0.447744 |
| 34  | 21  | 0.447011 |
| 55  | 34  | 0.447291 |
| 89  | 55  | 0.447184 |
| 144 | 89  | 0.447225 |
| 233 | 144 | 0.447209 |

Limit `1/√5 = 0.447214…`.

Observations:
* Every value is `> 1/3 = 0.3333…`, consistent with `badly_approximable`.
* The values oscillate around and converge to `1/√5`, so no fixed `c > √5`
  admits infinitely many `p/q` with `q²|φ − p/q| < 1/c` — consistent with
  `hurwitz_constant_sharp`.  The convergents realize the boundary rate `1/√5`,
  which is exactly why the constant cannot be improved.

Reproduce:
```lean
def phiF : Float := (1 + Float.sqrt 5)/2
def fib : Nat → Nat | 0 => 0 | 1 => 1 | (n+2) => fib n + fib (n+1)
#eval (List.range 12).map (fun n =>
  let q := fib (n+1); let p := fib (n+2);
  (p, q, (Float.ofNat q)^2 * (phiF - (Float.ofNat p)/(Float.ofNat q)).abs))
```

## 3. Counterexample hunt for `badly_approximable`

A brute-force scan over `1 ≤ q ≤ 5000` and the two nearest numerators
`p ∈ {⌊qφ⌋, ⌈qφ⌉}` (the only candidates that could violate a `1/q²`-type bound)
finds **no** pair with `q²|φ − p/q| < 1/3`; the minimum observed value is the
convergent value `0.381966` at `(p,q) = (2,1)` and the running minimum tends to
`1/√5`.  No counterexample to either theorem was found.

## 4. Norm form identity (the engine)

The proofs rest on the integer "norm" `N(p,q) = p² − pq − q² = (p−qφ)(p−qψ)`.
Small values confirm `N ≠ 0` for `q ≥ 1` (since `5` is not a perfect square):

| (p,q) | N = p²−pq−q² |
|-------|--------------|
| (1,1) | −1 |
| (2,1) | +1 |
| (3,2) | −1 |
| (5,3) | +1 |
| (8,5) | −1 |

Along the convergents `|N| = 1` exactly (these are the solutions of the Pell-like
`|p² − pq − q²| = 1`), which is the arithmetic reason `φ` sits at the bottom of
the Lagrange/Markov spectrum.
