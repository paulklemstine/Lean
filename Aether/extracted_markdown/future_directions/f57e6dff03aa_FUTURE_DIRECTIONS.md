# FUTURE_DIRECTIONS — Integrated Information Theory (IIT)

Cycle artifact: `Catalog/Speculative/Consciousness/IntegratedInformation.lean`
(builds on the `Speculative/Consciousness` catalog domain, cf.
`CayleyDicksonLadder.observation_order_matters`).

## Synthesis

This cycle gives Tononi's Integrated Information Theory a rigorous, finite-lattice
backbone. The decisive structural move is to model a system as a finite element
set `Fin n` together with a nonnegative *effective information* function `ei` on
its cuts (bipartitions, encoded as nontrivial subsets `A ⊆ Fin n`), and to define
integrated information `Phi` as `Finset.inf'` of `ei` over the finite set of all
nontrivial cuts. Once `Phi` is a minimum over a finite nonempty set, the two
headline IIT claims become theorems rather than slogans: the Minimum Information
Partition *exists* and realizes `Phi` (`Phi_attained`), and `Phi` is the greatest
lower bound across cuts (`Phi_le_ei`). The qualitative IIT thesis — a system is
integrated/irreducible exactly when no cut destroys its information — is captured
exactly by `Phi_eq_zero_iff_reducible` (`Phi = 0` iff some cut has `ei = 0`).

The computational side is handled honestly. Genuine NP-hardness is not formalized;
instead its rigorous combinatorial surrogate is proved: the exact cut space has
`2^n - 2` elements (`card_allCuts`), so brute force is exponential, while a
polynomial (linear, `n`-element) family of *singleton cuts* yields a cheap
approximation `phiApprox` that is a *sound upper bound* on `Phi`
(`Phi_le_phiApprox`, `card_singletonCuts`). What failed/was deliberately deferred:
the approximation has no accuracy guarantee. The boundary is recorded as the
conjecture `phiApprox_gap_unbounded_conjecture` (the additive gap can exceed any
constant), which is the structural reason exact `Phi` resists cheap computation.

The emergent insight tying everything together: IIT's substance lives in the
*partition lattice*, and almost every qualitative claim about consciousness in
this framework is a statement about minima over that lattice. Attainment,
monotonicity, and irreducibility are lattice facts; hardness is a counting fact;
approximability is a question about which *sub-lattices* preserve the minimum.
This reframing is what makes the next directions tractable.

## Results Summary

- `allCuts_nonempty`: proved — for `n ≥ 2` a nontrivial cut exists (well-posedness of `Phi`).
- `singletonCuts_nonempty`: proved — the polynomial approximation search space is nonempty.
- `singletonCuts_subset`: proved — every singleton cut is a genuine cut (soundness scaffold).
- `card_allCuts`: proved — the exact cut space has size `2^n - 2` (exponential search; NP-hardness surrogate).
- `card_singletonCuts`: proved — the approximation evaluates exactly `n` cuts (polynomial cost).
- `Phi_attained`: proved — the Minimum Information Partition exists and realizes `Phi`.
- `Phi_le_ei`: proved — `Phi` is a lower bound on the effective information of every cut.
- `Phi_nonneg`: proved — integrated information is nonnegative.
- `Phi_eq_zero_iff_reducible`: proved — irreducibility characterization (`Phi = 0` iff a cut carries no information).
- `Phi_le_phiApprox`: proved — the polynomial-time singleton approximation is a sound upper bound on `Phi`.
- `phiApprox_gap_unbounded_conjecture`: conjecture — the approximation has no additive accuracy guarantee.

## Research Directions

### Direction 1: The approximation gap is genuinely unbounded
**Hypothesis**: For every `C : ℝ` there is an `IITSystem S` with `phiApprox S - Phi S > C`
(`phiApprox_gap_unbounded_conjecture`).
**Test**: Construct, for each `C`, a system on `n = 3` (or `n` growing) whose three
singleton cuts all carry `ei ≥ C + 1` while the balanced cut `{0,1} | {2}` carries
`ei = 0`; compute both sides and compare.
**Why now**: We already have `Phi_le_phiApprox` and `Phi_eq_zero_iff_reducible`; the
key insight is that the gap is realized by a single balanced cut that the singleton
family structurally cannot see, so an explicit `ei` makes the inequality arithmetic.
**If true**: It rules out any sound polynomial *additive* approximation of `Phi` from
sub-lattices that omit balanced cuts — a real limitation theorem.
**If false**: Singleton cuts would already pin the minimum, collapsing the apparent
hardness — forcing a re-examination of where IIT's complexity actually resides.

### Direction 2: Lattice monotonicity of approximation quality
**Hypothesis**: If `T ⊆ T'` are two cut families with `singletonCuts ⊆ T ⊆ T' ⊆ allCuts`,
then `Phi ≤ inf'_{T'} ei ≤ inf'_{T} ei`, i.e. enlarging the search sub-lattice can only
improve (lower) the upper bound, monotonically toward `Phi`.
**Test**: Generalize `Phi_le_phiApprox` to an arbitrary nonempty `T ⊆ allCuts` and prove
the chain via `Finset.inf'` monotonicity under subset inclusion.
**Why now**: The current proof of `Phi_le_phiApprox` already factors through
"a min over a subfamily attained at a genuine cut"; the key insight is that this argument
never used the specific singleton structure, only `T ⊆ allCuts`.
**If true**: Gives a principled anytime-approximation hierarchy (balanced-cut, bounded-size,
…) interpolating between polynomial cost and exact `Phi`.
**If false**: Would expose a non-monotonicity in the partition lattice — surprising, and a
sign the `inf'` model is missing normalization present in real IIT.

### Direction 3: k-block partitions and a partition-lattice `Phi`
**Hypothesis**: Replacing bipartitions by partitions into `k ≥ 2` blocks, integrated
information `Phi_k` is still attained at a concrete partition, and `Phi_k` is monotone in `k`.
**Test**: Define cuts as `Finset (Finset (Fin n))` ordered set-partitions, restate `Phi_attained`
and `Phi_le_ei` over this finite lattice, and probe monotonicity computationally on small `n`.
**Why now**: All current proofs use only that the cut space is a finite nonempty `Finset`; the
key insight is that nothing in `Phi_attained`/`Phi_le_ei`/`Phi_eq_zero_iff_reducible` is specific
to bipartitions, so they lift verbatim to any finite partition family.
**If true**: Unifies the bipartition `Phi` with the full IIT "minimum over all partitions",
recovering Tononi's definition rigorously.
**If false**: Some attainment step would break, pinpointing exactly which finiteness assumption
IIT silently relies on.

### Direction 4: From counting to genuine NP-hardness
**Hypothesis**: Deciding `Phi S ≤ t` for a succinctly presented `ei` is NP-hard (reduction from
MIN-BISECTION / graph partitioning).
**Test**: Encode MIN-BISECTION instances as `IITSystem`s with `ei A = cut-weight(A)` and show the
decision problems coincide; formalize the reduction skeleton even if the complexity class is left
abstract.
**Why now**: `card_allCuts` already shows the search space is exponential; the key insight is that
`ei` is an arbitrary nonnegative weight, so a graph-cut weighting turns `Phi` literally into a
minimum-bisection value.
**If true**: Upgrades the counting surrogate to a true hardness theorem, the first formal
NP-hardness result for an IIT quantity.
**If false**: Would mean `ei`'s structure (e.g. submodularity from real KL-divergences) makes `Phi`
tractable — itself a major positive result.

### Direction 5: Submodular `ei` and tractable exact `Phi`
**Hypothesis**: If `ei` is symmetric and submodular (as KL-based effective information plausibly is),
then the MIP can be found in polynomial time and `Phi` is exactly computable.
**Test**: Add a `submodular` field to `IITSystem`, then attempt to prove `Phi = phiApprox` or a
poly-time min-cut characterization (Queyranne's algorithm analog) on small cases.
**Why now**: Direction 4 shows arbitrary `ei` is hard; the key insight is that real IIT `ei` is not
arbitrary — divergence-based information measures carry submodular structure that may collapse the
hardness.
**If true**: Separates "IIT is hard in general" from "IIT is easy for physically realizable systems",
the most consequential possible outcome for the theory's usability.
**If false**: Confirms that even physically constrained `ei` keeps `Phi` hard, sharpening the case
that consciousness measures are intrinsically intractable.
