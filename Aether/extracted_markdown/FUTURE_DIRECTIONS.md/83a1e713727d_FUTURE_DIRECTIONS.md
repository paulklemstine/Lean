# Future Directions — Arithmetic → Tropical Height Transfer

Cycle artifact: `Catalog/Bridges/ArithmeticTropicalHeight.lean`
(domain: **Bridges**; mode: **prove**).

## Synthesis

This cycle built the missing **Bridges ↔ Tropical** connection flagged by the catalog.
We fused two existing infrastructures — the arithmetic (Weil) height side from
`Bridges/ArithmeticOperadicStability` (`ratHeight`, `logRatHeight`) and the
valuation-depth philosophy from `Computation/PadicValuationDepth`
(`ValuationDepthMeasure`, `vdepth_add`, `vdepth_mul`) — into a concrete map
`tropHeight : Finset ℕ → ℚ → ℕ`. The local building block is
`vdepth p q = (-(padicValRat p q)).toNat`, the exponent of `p` in the denominator of
`q`; the global height aggregates these local depths over a finite set of primes with
the tropical addition `max`.

The decisive structural discovery is that **the `max` aggregation, applied to the
denominator-side depth, makes `tropHeight` a genuine map into the tropical (max,+)
semiring**: `tropHeight (x+y) ≤ max (tropHeight x) (tropHeight y)` (tropical `⊕`, with
**zero additive constant**) and `tropHeight (x·y) ≤ tropHeight x + tropHeight y`
(tropical `⊗`). Two design choices were load-bearing and validated by failure
analysis: (i) using the *non-negative denominator part* `(-v_p).toNat` rather than the
full magnitude `|v_p|` — the latter destroys the constant-free addition law; and
(ii) `max`-aggregation rather than `sum`-aggregation — a sum would forfeit the tropical
addition (max) law. We further proved the arithmetic-control bound
`tropHeight q ≤ logRatHeight q` (the arithmetic height dominates tropical complexity)
and a certified syntax→bound **pipeline** `tropHeight (eval e) ≤ cost e` for rational
expressions, where `cost` is the tropical-semiring evaluation of the syntax tree.

The Critic's sharpness question turned into a theorem: the addition inequality is an
equality exactly on the **separated locus** (depths differ at every prime), via the
strict ultrametric law `padicValRat.add_eq_min` and the lattice identity
`sup_max_distrib`. What remains open is *quantitative* sharpness of the arithmetic
comparison, the behaviour under division/inversion (where depths can become negative,
i.e. numerator depth appears), and lifting `tropHeight` to an actual semiring
*homomorphism* into `Tropical (WithTop ℕ)` so the catalog's tropical machinery applies
verbatim.

## Results Summary

- `vdepth_intCast` / `vdepth_natCast`: proved — integer/natural constants are depth-free (normalization at the local level).
- `vdepth_mul_le`: proved — local depth is subadditive under products (tropical `⊗` locally).
- `vdepth_add_le`: proved — local depth obeys the constant-free ultrametric `max` law (tropical `⊕` locally).
- `vdepth_eq_padicValNat_den`: proved — local depth equals the `p`-adic valuation of the denominator (computable characterization).
- `vdepth_le_log_den`: proved — local depth is bounded by `log₂` of the denominator.
- `tropHeight_intCast`: proved — **normalization**: integer constants have tropical height `0`.
- `tropHeight_mul_le`: proved — **tropical multiplication**: `tropHeight (x·y) ≤ tropHeight x + tropHeight y`.
- `tropHeight_add_le`: proved — **tropical addition (exact)**: `tropHeight (x+y) ≤ max (tropHeight x) (tropHeight y)`, zero additive constant.
- `tropHeight_le_logRatHeight`: proved — **arithmetic comparison**: `tropHeight q ≤ logRatHeight q`.
- `tropHeight_mono`: proved — monotone in the prime set.
- `tropHeight_eval_le_cost`: proved — **compositional pipeline**: tropical height of an evaluated rational expression is bounded by its structural tropical cost.
- `sup_max_distrib`: proved — finite `sup` distributes over binary `max` (lattice support lemma).
- `vdepth_add_eq_of_ne`: proved — local strict ultrametric equality under separated depths.
- `tropHeight_add_eq_of_separated`: proved — **sharpness**: the tropical addition law is an equality on the separated locus.

## Research Directions

### Direction 1: Promote `tropHeight` to a bona fide tropical semiring homomorphism
**Hypothesis**: There is a map `Φ : ℚ → Tropical (WithTop ℕ)` (using Mathlib's
`Tropical`) such that, relative to a fixed prime set `S`, `Φ` sends `+` to tropical
addition (`min`/`max`) and `·` to tropical multiplication (`+`) as inequalities, and to
equalities on the separated locus, with `Φ q = tropHeight S q` after the obvious
identification.
**Test**: Define `Φ` and prove `Φ (x*y) ≤ Φ x * Φ y` and `Φ (x+y) ≤ Φ x + Φ y` in
`Tropical`, then `exact`-match against `tropHeight_mul_le`/`tropHeight_add_le`.
**Why now**: This cycle already proved both semiring inequalities and the separated
equality; only the packaging into Mathlib's `Tropical` type is missing. The key insight
is that the constant-free `max` law is precisely the axiom of tropical addition, so the
homomorphism is *already* proved up to a type wrapper.
**If true**: The entire catalog `Tropical/*` machinery (`Tropical/IdempotentSemiring`,
`Tropical/Bernstein`, Bellman–Ford, etc.) becomes applicable to arithmetic-height data
for free.
**If false**: It would reveal a genuine obstruction (e.g. the finite-`S` truncation is
not functorial), pinpointing exactly which tropical axiom the denominator-depth violates.

### Direction 2: Inversion and the full (numerator+denominator) depth
**Hypothesis**: Define `fullDepth p q = (padicValRat p q).natAbs` (numerator *and*
denominator). Then `tropHeightFull` satisfies multiplicativity exactly,
`tropHeightFull (x*y) = `-style equalities under separation, but the addition law
degrades to `≤ max (..) (..) + C` with an explicit, computable `C` tied to numerator
collisions.
**Test**: Prove `vdepthFull_mul` as an *equality* via `padicValRat.mul`, and
disprove the constant-free addition law by exhibiting `x, y` with
`fullDepth p (x+y) > max (fullDepth p x) (fullDepth p y)` (a concrete counterexample
witness).
**Why now**: We isolated *why* the denominator-only depth gives a constant-free law; the
key insight is that the additive constant in the literature's "height of a sum" bound is
exactly the numerator contribution this cycle deliberately discarded. Re-introducing it
makes the constant explicit and falsifiable.
**If true**: Connects to the classical Weil-height inequality `h(x+y) ≤ h(x)+h(y)+log 2`
with a tropical, prime-local refinement.
**If false**: The discarded numerator term is inert, strengthening the claim that
denominator depth alone carries all tropical content.

### Direction 3: Quantitative tightness of `tropHeight ≤ logRatHeight`
**Hypothesis**: For every `k`, there exist rationals with `tropHeight S q = k` and
`logRatHeight q = k` (the comparison is attained), but the *gap*
`logRatHeight q - tropHeight S q` is unbounded over `q` with fixed `tropHeight`.
**Test**: Construct `q = 1/2^k` (gap `0`, witnessing tightness) and `q = (2^m+1)/2^k`
(large `logRatHeight`, depth still `k`) and compute both sides with `decide`/`#eval`.
**Why now**: `vdepth_eq_padicValNat_den` makes `tropHeight` of `1/p^k` exactly
computable, so witnesses are explicit. The key insight is that tropical height sees only
denominator prime *powers*, while arithmetic height also sees numerator magnitude — so
the two agree on prime-power denominators and diverge otherwise.
**If true**: Establishes that `tropHeight` is the "denominator-shadow" of `logRatHeight`,
a clean Galois-style left adjoint candidate.
**If false** (gap bounded): Then `tropHeight` and `logRatHeight` are equivalent up to an
additive constant, an unexpectedly strong rigidity.

### Direction 4: Northcott finiteness for tropical height
**Hypothesis**: For a fixed finite prime set `S` and bound `B`, the set
`{q : ℚ | q.den square-free supported on S ∧ tropHeight S q ≤ B}` is finite, and more
generally bounded tropical height + bounded numerator height gives a finite class.
**Test**: Reduce to `boundedHeightRationals_finite` (already in
`ArithmeticOperadicStability`) by bounding the denominator via
`vdepth_eq_padicValNat_den` and finiteness of exponent tuples over `S`.
**Why now**: The catalog already proves Northcott-style finiteness for `ratHeight`; the
key insight is that `tropHeight S q ≤ B` bounds each prime exponent of the denominator by
`B`, so the denominator ranges over a finite set once `S` is fixed.
**If true**: Yields a tropical analogue of Northcott's theorem and a finite-hypothesis
bound usable in the catalog's certified-robustness / post-quantum counting results.
**If false**: Indicates the numerator must be controlled too — i.e. tropical height alone
is not a Northcott height, sharpening the role of the prime-set parameter.

### Direction 5: Tropical complexity of iterated/operadic rational expressions
**Hypothesis**: For the operadic trees `ArchNet` of `ArithmeticOperadicStability`, there
is a translation `toRatExpr : ArchNet → RatExpr` whose tropical cost is bounded by the
network's `networkDepth`-weighted parameter heights, giving
`tropHeight S (eval ∘ toRatExpr) ≤ Σ-over-multiplications depth-bounded contributions`.
**Test**: Define `toRatExpr`, then chain `tropHeight_eval_le_cost` with the existing
`networkHeight_le_size_mul_maxParam` bound to get a depth×height tropical complexity
bound; verify on small trees with `#eval`.
**Why now**: `tropHeight_eval_le_cost` already certifies the syntax→tropical pipeline for
`RatExpr`; the key insight is that operadic composition trees are exactly nested
`add`/`mul` expressions, so the pipeline transports verbatim once a translation is fixed.
**If true**: Directly links operadic/neural architectural complexity to tropical height,
realizing the "tropical automorphic-style complexity" application named in the concept.
**If false** (cost blows up super-linearly): Reveals that tropical height is *not* an
operadic-additive invariant, motivating a refined cost functional with explicit
composition penalties.
