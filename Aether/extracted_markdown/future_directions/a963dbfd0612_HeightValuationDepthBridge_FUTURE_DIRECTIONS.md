# Future Directions — The Height ⇄ Valuation-Depth Bridge

## Synthesis

`Bridges/HeightValuationDepthBridge.lean` closes a gap the catalog had left open:
arithmetic **height** (`ArithmeticVCDim.ratArithHeight`, a Diophantine complexity
measure on `ℚ`) and **p-adic valuation depth** (`|padicValRat|`, the ultrametric
complexity modelled by `Computation/PadicValuationDepth.lean`'s `ValuationDepthMeasure`)
were each developed in isolation. We built the missing comparison map and proved it is
filtration-preserving.

The load-bearing result is `prime_pow_depth_le_height`:
`p ^ depthAt p q ≤ ratArithHeight q` for every prime `p`. From it follow the uniform
logarithmic bound `depthAt p q ≤ log₂(ratArithHeight q)`, the finite aggregate bound
`∑_{p∈S} depthAt p q ≤ |S| · log₂(ratArithHeight q)`, the multiplicative subadditivity
`depthAt_mul_le`, the ultrametric additive law `vdepthSigned_add_min_le`, the functorial
support inclusion `depthSupport_mul_subset`, and the descending filtration
`depthFiltration_antitone`.

The unexpected structural lesson (see the Lab Notebook in the `.lean` file): the bound
needs **no coprimality hypothesis**. Splitting `v_p(q) = v_p(num) − v_p(den)` by sign
always isolates a single side whose `p`-power divides `|num|` or `den`, each already
dominated by the height. The dual failure is equally instructive: support is *not*
preserved by addition (`1 + 1 = 2` manufactures the prime `2`), so the additive control
must live on the signed depth, exactly where the ultrametric inequality applies.

## Results summary

| Theorem | Statement | Status |
|---|---|---|
| `prime_pow_depth_le_height` | `p ^ depthAt p q ≤ ratArithHeight q` | proved |
| `prime_depth_le_log_height` | `depthAt p q ≤ log₂(ratArithHeight q)` | proved |
| `sum_prime_depth_le_card_mul_log` | `∑_{p∈S} depthAt p q ≤ |S| · log₂ H` | proved |
| `depthAt_mul_le` | multiplicative subadditivity | proved |
| `vdepthSigned_mul` | exact multiplicativity of signed depth | proved |
| `vdepthSigned_add_min_le` | ultrametric additive non-expansiveness | proved |
| `depthSupport_mul_subset` | functorial support control | proved |
| `depthFiltration_antitone` | descending threshold filtration | proved |

All main results are `sorry`-free and depend only on the standard axioms
(`propext`, `Classical.choice`, `Quot.sound`).

## Bold, falsifiable directions

### 1. A tight aggregate bound without the `|S|` factor

The aggregate bound `∑_{p∈S} depthAt p q ≤ |S| · log₂ H` is provably loose: every summand
re-pays the full logarithmic height. The conjecture is the carry-free version
`∑_{p prime} depthAt p q ≤ 2 · log₂(ratArithHeight q)`, i.e. the *total* depth across
**all** primes is bounded by a height logarithm with an absolute constant, independent of
how many primes are involved.

The key insight is that the numerator-side depths assemble into a divisor of `|num|` and
the denominator-side depths into a divisor of `den`, so `2^{∑ depth} ≤ |num| · den ≤ H²`;
the `|S|` factor is an artifact of bounding each prime separately rather than using that
the prime powers multiply into a single integer. Falsifier: any rational with
`∑_p depthAt p q > 2·log₂ H`.

Why now? `prime_pow_depth_le_height` already supplies the per-prime divisibility facts;
the only missing ingredient is `∏_{p∈S} p^{depthAt p q} ∣ |num|·den`, a finite product of
coprime prime powers that Mathlib's `Nat.factorization`/`Finsupp.prod` API handles
directly. This converts the bridge from "shallow per prime" to "globally shallow", which
is the version a pruning algorithm actually wants.

### 2. A Northcott-style finiteness certificate for shallow profiles

Conjecture: for every height bound `H` and threshold `t ≥ 1`, the set
`{ q : ℚ | ratArithHeight q ≤ H ∧ ∃ p, t ≤ depthAt p q }` is finite, and moreover its
cardinality is bounded by an explicit polynomial in `H` independent of `t`.

The key insight is that `depthFiltration` sublevel sets are *automatically* truncated by
height: `prime_depth_le_log_height` forces every nonempty level `t ≤ log₂ H`, so the
filtration has bounded length and the whole profile lives in a finite box once `H` is
fixed — Northcott finiteness re-expressed through the depth filtration rather than through
heights directly. Falsifier: an infinite height-bounded family sharing a fixed deep prime.

Why now? Mathlib already proves height-bounded sets of rationals are finite; pairing that
with the proved filtration-length bound turns an abstract finiteness statement into a
*counted* certificate, the exact object the concept description calls a "computable pruning
criterion."

### 3. Filtration functoriality upgraded to a genuine valued category

We proved set-level laws (`depthSupport_mul_subset`, `depthFiltration_antitone`). The bold
upgrade is to package `(ℚˣ, ·)` together with `depthProfile` as an object of the
nonexpansive-functor category of `Bridges/CategoricalTropicalUltrametric.lean`, and prove
that multiplication is a `1`-Lipschitz endofunctor of the resulting filtered system while
addition is `1`-Lipschitz on the denominator subfiltration.

The key insight is that `depthAt_mul_le` is precisely a `TropicalValuationObject`-style
`add_eq_max'`/subadditivity axiom in disguise, so the bridge's inequalities *are* the
structure maps of an ultrametric object — the comparison map is a functor, not merely a
family of bounds. Falsifier: a pair `q, r` for which no Lipschitz constant `1` works, i.e.
`depthAt p (q·r) > max(depthAt p q, depthAt p r) + 1` for some prime.

Why now? `CategoricalTropicalUltrametric.lean` provides the categorical scaffolding and
`HeightValuationDepthBridge.lean` provides the quantitative laws; the remaining work is
purely the bookkeeping of fitting proved inequalities into the existing structure fields.

### 4. Height-depth duality as a learning-theoretic capacity bound

`Bridges/ArithmeticVCDimension.lean` turns height control into pseudo-dimension bounds.
Conjecture: the valuation-depth profile is itself a VC-style capacity functional — the
number of distinct depth profiles realizable by height-`≤ H` rationals over a fixed prime
set `S` is at most `(1 + log₂ H)^{|S|}`, giving a Sauer–Shelah-type trace count directly in
ultrametric coordinates.

The key insight is that each coordinate `depthAt p q` ranges over `{0, 1, …, log₂ H}` by
`prime_depth_le_log_height`, so the profile lives in a product of finite chains and the
trace count is a pure counting consequence of the proved per-prime bound. Falsifier: a
height-`H` family realizing more than `(1+log₂H)^{|S|}` profiles on some `S`.

Why now? This is the literal composition `height ⇒ depth ⇒ finite trace count` promised by
the catalog's VC pipeline, but routed through valuation depth instead of raw parameter
traces; the proved logarithmic bound is exactly the per-coordinate alphabet size the count
needs.

### 5. Sharpness: the bound is attained, and its log form is order-optimal

Conjecture: for every prime `p` and every `k`, the rational `q = p^k` satisfies
`depthAt p q = k` and `ratArithHeight q = p^k + 1`, so `prime_pow_depth_le_height` is
attained up to the `+1`, and `prime_depth_le_log_height` is tight to within
`log₂ p`. Hence no bound of the form `depthAt p q ≤ c · log_b H` with `b > p` can hold for
all `q`.

The key insight is that pure prime powers saturate the sign-split argument — all the height
is concentrated on one side and one prime — so the inequalities cannot be globally improved
except by changing the logarithm's base, pinning down the bridge's exact constant. Falsifier:
a uniform improvement `depthAt p q ≤ log₂ H − 1` valid for all `q`, contradicted by `q = 2^k`.

Why now? The witnesses are explicit and computable; verifying `depthAt p (p^k) = k` is a
direct `padicValRat` computation, turning the qualitative bridge into a *sharp* one and
certifying that the pruning criterion loses at most a constant factor.
