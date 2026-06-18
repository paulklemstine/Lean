# Future Directions — Fermat Near-Misses in the Twilight Zone

## Synthesis

`Tropical/FermatNearMiss.lean` formalizes the dichotomy between *classical* and
*tropical* Fermat behaviour. Classically, `a^n + b^n = c^n` is empty of
nondegenerate solutions for `n ≥ 3`, so the best one can do is a **near-miss**:
make the discrepancy `disc n a b c = a^n + b^n - c^n` small. Tropically — passing
to the min-plus semiring where `x^n ↦ n·x` and `+ ↦ min` — the very same equation
becomes `min (n·a) (n·b) = n·c`, which is solved *exactly*, for every exponent, by
`c = min a b` (`tropical_fermat_exact`). The "twilight zone" is the residue left
behind when one transports the tropical exact balance back to the integers; its
size is controlled by the consecutive-power gap `(a+1)^n − a^n ≥ n·a^(n-1)`
(`pow_gap_lower_bound`), and each prescribed error is attained by at most one `a`
because the discrepancy is strictly monotone (`nearMiss_strictMono`).

## Results summary

- `nearMiss_one_exists`: error-`1` near-misses exist for every exponent and are
  unbounded in size (diagonal family `(1, N, N)`).
- `cube_nearMiss_pos`, `cube_nearMiss_neg`: the famous nondegenerate cubic
  near-misses `9³+10³−12³ = 1` and `6³+8³−9³ = −1`.
- `tropical_fermat_exact`, `tropical_fermat_nondegenerate`: tropical Fermat is
  exactly and nondegenerately solvable for all `n`.
- `nearMiss_strictMono`, `pow_gap_lower_bound`: quantitative sparsity / gap
  growth driving the thinning density of near-misses.

## Research directions

### 1. A super-exponential density bound for boxed near-misses
Count `N_n(X, ε) = #{(a,b,c) ∈ [1,X]³ : |a^n+b^n-c^n| ≤ ε}`. The strict
monotonicity of `disc` in `a` already shows that, after fixing `(b,c)`, the
number of admissible `a` is at most the number of `n`-th powers landing in an
interval of length `2ε+1`. Conjecture: `N_n(X, ε) ≤ C · X² · (ε+1)^{1/n}`, so the
*per-shell* density decays like `(ε+1)^{1/n}`, i.e. super-exponentially in `n`.
**The key insight is** that `pow_gap_lower_bound` turns "an `n`-th power in a short
interval" into a rare event whose rarity is governed by `n·a^(n-1)`, converting an
analytic density question into an elementary gap count. **Why now?** Both
ingredients (monotone injectivity and the gap bound) are already formalized, so
the counting bound is a direct, falsifiable next step rather than new theory.

### 2. Optimal one-sided near-miss `a = ⌊(c^n − b^n)^{1/n}⌋`
For fixed `b < c`, the best near-miss in `a` is `a₀ = ⌊(c^n − b^n)^{1/n}⌋`, and
its error satisfies `0 ≤ c^n − b^n − a₀^n < (a₀+1)^n − a₀^n ≤ n·(a₀+1)^{n-1}`.
Conjecture: this rounding construction yields, for every `n`, a family with
*relative* error `|disc| / c^n → 0` while all of `a,b,c → ∞` and `a,b < c`.
**The key insight is** that the inescapable absolute error is exactly one
power-gap wide, so dividing by `c^n` kills it. **Why now?** `pow_gap_lower_bound`
is the matching upper bound on a single gap; pairing it with a floor/`Nat.sqrt`-style
root gives a fully constructive, machine-checkable near-miss generator.

### 3. Tropical–classical residue inequality (the twilight bridge)
Make the bridge quantitative: for positive reals, relate the classical residue
`|a^n + b^n − c^n|` to the tropical defect `|min(n·a, n·b) − n·c|` through
logarithms, e.g. `log(a^n+b^n) = max(n log a, n log b) + O(1)` so that the tropical
equation is the leading-order shadow of the classical one. Conjecture: a triple is
an `ε`-relative near-miss classically **iff** it is an `O(ε)`-near-miss tropically
after taking logs. **The key insight is** that `tropical_fermat_exact` is precisely
the `T → 0` Maslov dequantization limit of `(x^n, +)`, so near-misses are first-order
deviations from that limit. **Why now?** Mathlib's `Real.log` / `Real.rpow` API is
mature enough to state and prove the `O(1)` log-sum-exp comparison directly.

### 4. Infinitely many nondegenerate cubic `±1` near-misses
The witnesses `9³+10³−12³ = 1` and `6³+8³−9³ = −1` are sporadic in this file.
Conjecture: there is an explicit polynomial parametrization `(a(t), b(t), c(t))`
with `a(t)^3 + b(t)^3 − c(t)^3 = 1` and `a(t), b(t) < c(t)` for all `t`, giving
infinitely many nondegenerate constant-error cubic near-misses. **The key insight
is** that constant-error cubic near-misses correspond to integral points on a
pencil of cubic surfaces, where a single rational curve forces an infinite family.
**Why now?** Once a candidate identity is found it is verifiable by `ring`,
turning an existence claim into a one-line Lean proof and a sharp test of the
ABC-conjecture heuristic that such families should be rare.

### 5. ABC-effective lower bound on the discrepancy
Connect to the effective ABC conjecture: for coprime nondegenerate triples with
`a^n + b^n` near `c^n`, conjecture `|a^n + b^n − c^n| ≥ c^{n − 1 − κ(n)}` for an
explicit `κ(n) → 0`, i.e. near-misses cannot be *too* good. **The key insight is**
that `pow_gap_lower_bound` already supplies an unconditional `≥ n·a^{n-1}` floor in
the one-variable slice; the ABC step upgrades this to a genuinely Diophantine,
radical-dependent floor in all three variables. **Why now?** The unconditional
slice bound is formalized, so the conditional ABC strengthening can be stated as a
clean hypothesis-bearing theorem (`abc_effective → near_miss_floor`) and tested
against the known cubic witnesses immediately.
