# Computational Evidence — FHE noise accumulation

All numbers below were produced with exact rational arithmetic (`ℚ`) inside Lean 4
(`#eval`), using the same recursion that the formal development uses:

```lean
def iter (g D : ℚ) : ℕ → ℚ → ℚ
  | 0,       x => x
  | (n + 1), x => g * (iter g D n x) ^ 2 + D     -- noiseStep γ D applied n+1 times
```

They are *exploratory* data that guided the formalization; the theorems in
`Catalog/Cryptography/FHE/` are what is actually verified.

## 1. Relinearization-free growth is doubly exponential

`γ = 1`, `D = 0`, `B = 2` (the catalog's `noiseAfterDepth 2 d`):

| depth `d` | 0 | 1 | 2 | 3 | 4 | 5 | 6 |
|---|---|---|---|---|---|---|---|
| noise | 2 | 4 | 16 | 256 | 65536 | 4294967296 | 1.8·10¹⁹ |

This is `2^(2^d)`, matching the closed form `γ·iterNoise γ d B = (γB)^(2^d)`
(`FHENoise.gamma_iterNoise`) and the catalog identity
`iterNoise 1 d B = RingLWEFHE.noiseAfterDepth B d`
(`FHENoise.iterNoise_one_eq_noiseAfterDepth`).

With a relinearization surcharge `D = 1` the same start gives
`2, 5, 26, 677, 458330, 210066388901` — the surcharge is negligible against the
squaring, which is why the *stability* question below is decided entirely by the
size of `D` relative to `1/(4γ)`.

## 2. The dichotomy at the threshold `4γD = 1`

`γ = 1`, start `x₀ = 0.1`.

* `D = 1/5` (so `4γD = 0.8 ≤ 1`) — orbit converges:
  `0.1, 0.21, 0.2441, 0.2596, 0.2674, 0.2715, 0.2737, 0.2749, 0.2756, 0.2759, 0.2761, 0.2763 …`
  The limit agrees with the predicted fixed point
  `(1 − √(1 − 4γD))/(2γ) = 0.2763932…` (`FHENoise.noiseFixedPoint_spec`).

* `D = 3/10` (so `4γD = 1.2 > 1`) — orbit escapes:
  `0.1, 0.31, 0.3961, 0.4569, 0.5088, 0.5588, 0.6123, 0.6749, 0.7555, 0.8708, 1.0582, 1.4199 …`
  and first exceeds `T = 10` at depth **14**.  The proved linear lower bound
  `iterD d x ≥ x + d·(D − 1/(4γ))` with slope `c = 0.05` guarantees escape by
  depth `198`; the bound is therefore correct but conservative — as expected,
  since it ignores the quadratic term.  This is exactly the shape of
  `FHENoise.exists_depth_exceeding`.

## 3. Counterexample hunt for the dichotomy

Grid search over `γ ∈ {0.2, 0.4, …, 2.0}`, `D ∈ {0, 0.05, …, 0.5}` (110 pairs);
for each pair a fine sweep of candidate budgets `Q ∈ {0, 0.001, …, 2}` tested
whether `γQ² + D ≤ Q` is satisfiable, and compared the answer with the predicate
`4γD ≤ 1`.

**Result: 0 disagreements.**  This is the statement later proved in full
generality as `FHENoise.noiseStep_dichotomy`
(`(∃ Q, InvariantBudget γ D Q) ↔ 4γD ≤ 1`).

## 4. Scheduling data

`γ = 1`, `D = 0`, refreshed noise level `B = 2`, decoding radius `T = 65535`:
depth 3 gives noise `256 ≤ T`, depth 4 gives `65536 > T`.  So exactly three
multiplication levels fit between two bootstraps, and multiplicative depth `10`
needs at least `⌈10/3⌉ = 4` bootstraps.  Both statements are formalized
(`FHENoise.three_levels_between_bootstraps`,
`FHENoise.depth_ten_needs_four_bootstraps`,
`FHENoise.uniform_schedule_attains`).

## 5. Sequences

The only integer sequences appearing are the classical doubly exponential
`2^(2^d) = 2, 4, 16, 256, 65536, …` and the quadratic-recurrence sequence
`x ↦ x² + 1` started at `2`, i.e. `2, 5, 26, 677, 458330, …`.  Both are standard;
no new sequence is claimed and no OEIS identifier is asserted here.
