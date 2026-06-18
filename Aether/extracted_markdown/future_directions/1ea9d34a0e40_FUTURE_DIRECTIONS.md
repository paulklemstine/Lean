# FUTURE_DIRECTIONS — Thermodynamic Proof Erasure

## Synthesis

This cycle formalized **Landauer's principle for proof compression** in
`Physics/ProofErasureLandauer.lean`, building directly on the existing tropical
Landauer file `Physics/Landauer.lean` (its `entropyDefect f = log|domain| -
log|range f|`). The central modeling choice that made everything tractable was
representing a length-`n` proof as a sequence of `n` binary search-tree
decisions, `Proof n := Fin n → Bool`, so that a proof carries exactly `n` bits
(`|Proof n| = 2^n`) and a *compressor* is **any** map `Proof n → Proof m`.

The cycle's structural discovery is a clean **lower-bound / achievability pair**.
On one side, `compression_entropyDefect_lower_bound` shows that *every*
compressor — regardless of algorithm — erases at least `(n-m)·log 2` of
information; the proof only needs `card (range f) ≤ 2^m` and monotonicity of
`log`, so the bound is genuinely method-independent (a physical, not algorithmic,
limit). On the other side, `truncation_entropyDefect` shows the canonical
truncation compressor achieves exactly `(n-m)·log 2`, so the bound is **tight**.
Multiplying by temperature gives the heat-dissipation statements
(`compression_landauer_thermodynamic`, `compression_factor_bound`,
`fta_compression_cost`), and `compression_forces_erasure` pins down the
combinatorial root cause: when `m < n` no compressor can be injective, so
irreversibility — and hence positive cost — is forced.

What was unexpectedly clean: the universal lower bound needs **no** `m ≤ n`
hypothesis (it degrades to a vacuous statement when `m ≥ n`), so the deleted
hypothesis was dropped to give a stronger theorem. What was friction: rewriting
under `Fintype.card` triggers "motive is not type correct" because the cardinality
carries a `Fintype` instance on the range — transporting along an explicit
`Equiv` (`Equiv.setCongr ∘ Equiv.Set.univ`) is the robust fix and is worth
reusing in any range-cardinality argument. The honest limitation of the model is
that it counts *raw search-tree bits*, not *semantic* proof content: two distinct
binary strings may denote the same proof, so the `2^n` count is an upper model of
information, and the directions below probe exactly that gap.

## Results Summary

- `truncation_card_range`: proved — the truncation compressor is surjective, so its range has `2^m` elements (the achievability engine).
- `truncation_entropyDefect`: proved — truncation erases exactly `(n-m)·log 2`, establishing tightness of the lower bound.
- `compression_entropyDefect_lower_bound`: proved — every compressor erases at least `(n-m)·log 2`, a method-independent information floor.
- `compression_landauer_thermodynamic`: proved — at temperature `kT ≥ 0` the heat dissipated is at least `kT·(n-m)·log 2`.
- `compression_factor_bound`: proved — a `c`-fold compression (`c·m ≤ n`) costs at least `kT·n·(1-1/c)·log 2`, scaling with the *source* length.
- `fta_compression_cost`: proved — compressing a 1000-step proof to 100 steps dissipates at least `900·kT·log 2` (concrete falsifiable number).
- `compression_forces_erasure`: proved — for `m < n` no compressor is injective, so irreversibility is forced by cardinality.

## Research Directions

### Direction 1: Quotient-aware proof information (semantic vs. syntactic bits)
**Hypothesis**: If proofs are taken up to a definitional/normalization equivalence
`~` on `Proof n` with `q` equivalence classes, the true erasure floor for a
compressor respecting `~` is `log q_n - log q_m`, which can be **strictly smaller**
than `(n-m)·log 2`; concretely there exists an `~` and a compressor with
`entropyDefect` of the induced quotient map `= 0` while `n > m`.
**Test**: Define the quotient `Proof n / ~`, port `entropyDefect` to the quotient
(its cardinality replaces `2^n`), and either prove the quotient lower bound or
exhibit a counterexample where collapsing redundant syntactic steps costs nothing.
**Why now**: `compression_entropyDefect_lower_bound` is stated for arbitrary
finite types via `entropyDefect`, so it already applies verbatim to a finite
quotient — only the cardinality input changes.
**If true**: separates *syntactic* (Landauer) cost from *semantic* (irreducible)
cost, giving a two-tier theory of proof information.
**If false**: shows search-tree bits are already the right currency — every
syntactic bit is semantically load-bearing.

### Direction 2: Reversible (Bennett-style) compression has zero net erasure
**Hypothesis**: If a compressor is augmented with a *garbage register*
`g : Proof n → Proof k` so that `(f, g) : Proof n → Proof m × Proof k` is
injective, then `entropyDefect (f,g) = 0`, and the Landauer cost is paid **only**
when the garbage is finally erased — recovering Bennett's reversible-computation
refinement of Landauer.
**Test**: Prove `entropyDefect h = 0 ↔ Function.Injective h` for `h` between
finite proof spaces, then show that injectivity of `(f,g)` forces `k ≥ n - m`
(by cardinality), so the deferred erasure cost is again `≥ (n-m)·log 2`.
**Why now**: `compression_forces_erasure` already isolates injectivity as the
cardinality obstruction; the `iff` is the natural completion, and `entropyDefect`
is exactly the quantity that should vanish for injective maps.
**If true**: the bound is conserved, not avoided — cost is moved in time, not
eliminated, a sharp formal version of "no free lunch".
**If false**: there is a genuinely reversible compression channel, which would be
a striking and surprising loophole worth chasing.

### Direction 3: Subadditivity / composition of compression cost
**Hypothesis**: For composable compressors `f : Proof n → Proof m` and
`g : Proof m → Proof k`, `entropyDefect (g ∘ f) ≤ entropyDefect g + entropyDefect f`,
with equality iff `f` is surjective; thus staged compression never costs less than
the single-shot floor `(n-k)·log 2`.
**Test**: Prove the subadditivity inequality from `card (range (g∘f)) ≥
card (range g restricted to range f)` and `log` monotonicity; derive equality
characterization from surjectivity of `f` (mirroring `truncation_card_range`).
**Why now**: the truncation surjectivity lemma and the `card (range ·)`
machinery developed this cycle are exactly the tools a composition law needs.
**If true**: upgrades the per-step bound to a *pipeline* law, letting one bound
multi-pass proof minimizers.
**If false**: staged erasure can beat the floor, exposing a flaw in treating the
search tree as memoryless.

### Direction 4: Temperature/landscape — cost as a function of proof-system entropy
**Hypothesis**: If the source proof distribution is non-uniform with Shannon
entropy `H ≤ n·log 2` (not all `2^n` strings equiprobable), the expected erasure
cost of compressing to `m` steps is at least `kT·(H - m·log 2)⁺`, strictly below
the worst-case `kT·(n-m)·log 2` whenever `H < n·log 2`.
**Test**: Replace counting `entropyDefect` with a Shannon-entropy defect
`H(X) - H(f(X))` over `Finset`-supported distributions, and prove the
data-processing inequality `H(f(X)) ≤ H(X)` plus the erasure floor; reuse the
mutual-information API in `Shared/MutualInformation.lean`.
**Why now**: the catalog already has `Shared/MutualInformation.lean` with
data-processing infrastructure; bridging it to `entropyDefect` is the natural
cross-domain merge this concept calls for.
**If true**: yields an *average-case* Landauer bound — compressing "typical"
proofs is cheaper than compressing adversarial ones.
**If false**: the worst-case counting bound is also the average-case bound,
meaning proof information is incompressible on average.

### Direction 5: Cost of proof *verification* vs. proof *compression* (asymmetry)
**Hypothesis**: Verification is logically reversible (it reads a proof and
outputs accept/reject without destroying it), so its intrinsic Landauer cost is
`0`, whereas compression's is `(n-m)·log 2`; formally, the "verify" map
`Proof n → Proof n × Bool`, `p ↦ (p, valid p)`, has `entropyDefect = 0`.
**Test**: Prove `entropyDefect (fun p => (p, valid p)) = 0` (it is injective, so
this follows from the `iff` in Direction 2), contrasted with the strictly
positive `truncation_entropyDefect` for `m < n`.
**Why now**: `compression_forces_erasure` and `truncation_entropyDefect` already
give the positive side; the negative (verification) side is one injectivity
argument away.
**If true**: formal thermodynamic asymmetry between *checking* and *shortening*
proofs — checking is free, shortening is not.
**If false**: verification also dissipates, suggesting hidden state erasure in
the checking process worth modeling explicitly.
