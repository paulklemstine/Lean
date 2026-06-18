# Future Directions: The Oracle Counting Barrier

## Synthesis

This cycle isolated the *cardinal mechanism* behind the bridge between
finite-description complexity and three-valued oracle non-computability, and reduced it
to a single, domain-agnostic counting fact. Two Lean files carry the work.

`Catalog/Computation/OracleCountingBarrier.lean` proves eight foundational results: the
space of three-valued oracles on `N` statements has size `3 ^ N` (`oracle_card`); any
program space strictly smaller than the oracle space fails to cover it for *any* answer
alphabet (`oracle_not_covered_generic`) and in particular for three verdicts
(`oracle_not_covered`); a fixed program budget `b ^ k` is eventually outrun by `3 ^ N`
(`budget_gap_exists`); binary descriptions of length `N` are strictly too poor,
`2 ^ N < 3 ^ N` (`binary_insufficient`); the computable fraction `C / 3 ^ N → 0` for any
constant budget (`computable_fraction_tendsto_zero`); and the binary-reachable fraction is
the *exact* geometric law `2 ^ N / 3 ^ N = (2/3) ^ N` (`binary_fraction_eq`), which itself
vanishes (`binary_fraction_tendsto_zero`).

`Catalog/Computation/OracleBarrierExtensions.lean` pushes three directions further: a
*constructive* Cantor diagonal that exhibits the escaping oracle explicitly when the
program space is the index set (`oracle_diagonal_escape`); a finite Turing jump
(`oracle_comp_card`, `oracle_comp_jump`, `oracle_comp_budget_gap`) showing the
oracle-to-oracle space has the exact size `3 ^ (N · 3 ^ N)`, strictly above the
evaluation space `3 ^ N` for every `N ≥ 1` and beyond every fixed budget; and a
robustness theorem (`consistent_oracles_escape`) proving that any consistency constraint
leaving an independent `3`-valued block of size `k` keeps the barrier biting against any
sub-`3 ^ k` program space.

The structural insight that organizes all of this: the **coverage** obstruction and the
**information** obstruction are logically independent. Coverage needs nothing about the
number "3" — `oracle_not_covered_generic` is stated and proved for an arbitrary alphabet
size `a` and follows purely from `Fintype.card_le_of_surjective` together with the
function-space count `Fintype.card_fun`. The number "3" enters only the information story,
where it produces the binary deficit `2 ^ N < 3 ^ N` and, sharpened, the exact rate
`(2/3) ^ N`. Factoring the argument this way is what makes each proof one or two lines and
makes the core lemma reusable across domains by merely changing the codomain. The catalog
connections are to `Computation/OracleBurden.lean` (oracle jump hierarchy via provability
sets) and `Computation/Oracles/Foundation.lean` (geodesic idempotent oracles): this work
supplies the single counting lemma those chains can specialize, replacing an ascending
sequence of separations by one cardinal inequality, and now a finite, fully constructive
jump.

## Results Summary

- `oracle_card`: proved — exactly `3 ^ N` three-valued oracles on `N` statements.
- `oracle_not_covered_generic`: proved — the reusable, alphabet-agnostic barrier.
- `oracle_not_covered`: proved — the `a = 3` one-line specialization.
- `budget_gap_exists`: proved — every fixed budget `b ^ k` is eventually outrun by `3 ^ N`.
- `binary_insufficient`: proved — `2 ^ N < 3 ^ N` for `N ≥ 1` (boundary `N = 0` is exactly where it fails).
- `computable_fraction_tendsto_zero`: proved — for any constant budget `C`, `C / 3 ^ N → 0`.
- `binary_fraction_eq`: proved — the exact geometric law `2 ^ N / 3 ^ N = (2/3) ^ N`.
- `binary_fraction_tendsto_zero`: proved — that fraction vanishes geometrically.
- `oracle_diagonal_escape`: proved — explicit constructive diagonal escape, any alphabet `a ≥ 2`.
- `oracle_comp_card`: proved — composition space has cardinality `3 ^ (N · 3 ^ N)`.
- `oracle_comp_jump`: proved — evaluation strictly cheaper than composition for `N ≥ 1` (finite Turing jump).
- `oracle_comp_budget_gap`: proved — composition outruns every fixed budget.
- `consistent_oracles_escape`: proved — the barrier survives consistency constraints with an independent `3 ^ k` block.

## Research Directions

### Direction 1: The Exact Reachability Spectrum and its Phase Transition

The constant-budget limit and the `a = 3`, `m = N` point of the reachable fraction are now
pinned exactly by `binary_fraction_eq` and `binary_fraction_tendsto_zero`. The natural
generalization is the full spectrum: for alphabet size `a` and binary description length
`m = c·N`, the reachable fraction should be exactly `min(2^(c·N), a^N) / a^N`, tending to
`0` geometrically when `c < log₂ a` and being eventually `1` when `c > log₂ a`. **The key
insight is** that the description-rate threshold sits exactly at `c = log₂ a`, the finite
shadow of Shannon source coding, and the transition is sharp rather than smeared. **Why
now?** Because `binary_fraction_eq` already gives the exact closed form at one point of the
spectrum, so only the two-sided dichotomy via `Real.logb` and
`tendsto_pow_atTop_nhds_zero_of_lt_one` (with its `> 1` counterpart) remains. A test that
disproves sharpness — sub-geometric behaviour near `c = log₂ a` — would reveal structure
beyond pure counting; a confirmation turns the barrier into a phase-transition theorem.

### Direction 2: Iterated Jumps and a Finite Jump Hierarchy

`oracle_comp_jump` exhibits one finite Turing jump: composition is strictly costlier than
evaluation. Iterating the construction — `Oracle N → Oracle N → ⋯ → Oracle N` with `j`
arrows — should yield a strictly increasing tower of cardinalities `3 ^ N < 3 ^ (N·3^N) <
3 ^ (N · 3 ^ (N·3^N)) < ⋯`, a finite analogue of the arithmetical hierarchy with each
level a bare cardinal inequality. **The key insight is** that each jump is just one more
application of `Fintype.card_fun`, so the hierarchy is generated by a single recursive
counting step with no recourse to relativized halting problems. **Why now?** Because
`oracle_comp_card` already computes the first jump exactly and `budget_gap_exists` supplies
the growth control; the `j`-fold tower is an induction on these two lemmas. Falsification
would require some structural collapse of higher-order oracle maps — a finite degree
collapse, itself a striking result.

### Direction 3: Logically Consistent Oracles at Scale

`consistent_oracles_escape` shows that *any* consistency predicate retaining an injective
`3 ^ k` block keeps the barrier alive. The open quantitative question is how large that
block must be for natural implication relations `R` on the `N` statements: if `R` is a DAG
of implications, does it always leave a linear-in-`N` independent antichain, forcing the
consistent-oracle count above `2 ^ N`? **The key insight is** that only the *width* of the
implication poset (its largest antichain), not its size, controls the surviving entropy —
Dilworth's theorem should convert chain-cover bounds directly into block sizes. **Why now?**
Because `consistent_oracles_escape` reduces the entire problem to producing one injection
`Fin k → Fin 3` into the consistent set, so the remaining work is purely the combinatorial
antichain lower bound. A relation `R` collapsing the consistent count to a polynomial in
`N` would falsify the hypothesis and identify exactly which logical constraints buy
computability.

### Direction 4: Confidence Oracles via the Discretization Limit

`oracle_not_covered_generic` is already alphabet-parametric, so real-valued confidence
oracles `Fin N → [0,1]` discretized to `a` levels should inherit the barrier uniformly in
`a`, and the barrier should survive the resolution limit `a → ∞`. **The key insight is**
that increasing resolution only *enlarges* the oracle space `a ^ N`, so finer confidence
never helps a fixed program budget — the limit strengthens, rather than dissolves, the
obstruction. **Why now?** Because the only missing piece is the discretization map
`[0,1] → Fin a` together with the observation that realizable verdict vectors still number
`a ^ N` on an independent probe set; the counting lemma is already in hand. If continuity
constraints were found to cap the realizable count below `a ^ N`, that would isolate
precisely where analysis beats counting — a genuinely informative failure.

### Direction 5: Tropical Solution Oracles Inherit the Barrier

Discretizing each tropical polynomial system on `n` equations into a three-valued verdict
vector (feasible / infeasible / degenerate per probe point) makes it an honest element of
`Oracle N`, so `oracle_not_covered` should apply verbatim once one lower-bounds the number
of realizable verdict vectors by `2 ^ n` via tropical hyperplane-arrangement counts. **The
key insight is** that the verdict map turns a geometric feasibility question into a pure
counting question, letting the *same* barrier lemma cross from computation into tropical
geometry with no new combinatorics. **Why now?** Because the catalog already contains
`Tropical/ComplexityTransfer.lean` and related arrangement-counting machinery, and
`oracle_not_covered` is ready to consume any lower bound on realizable vectors. A small
certificate family reproducing all verdict vectors for `n ≤ 5` would falsify the transfer
and prove tropical solution sets are polynomially certifiable — itself a strong structural
theorem.
