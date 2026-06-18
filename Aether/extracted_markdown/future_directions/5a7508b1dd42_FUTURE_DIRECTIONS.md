# FUTURE_DIRECTIONS — Persistent-Homology Folding (Extended)

## Synthesis

This cycle extended the catalog's topological theory of protein folding
(`Speculative/AutoResearch/ProteinFolding.lean`, namespace `ProteinTopology`) into a new file
`Speculative/AutoResearch/PersistentHomologyFoldingExt.lean` (namespace `FoldingHomology`). The
catalog had established the *elder rule on a chain* (`ProteinTopology.H0_totalPersistence_eq_extent`:
degree-`0` total persistence of a linear fold equals its end-to-end extent `xₙ − x₀`) together
with the existence/uniqueness of a "native fold" as the argmin of topological energy
(`exists_native_fold`, `native_fold_unique`). The structural question we pressed on was: **how
rigid is the degree-`0` energy functional, and how much does it actually determine the fold?**

The recurring discovery is that degree-`0` ("`H₀`") total persistence is an extraordinarily
*coarse* invariant. Because it telescopes to `xₙ − x₀`, it is (i) monotone under feature
inclusion (`totalPersistence_mono`, the order-theoretic companion of the catalog's additivity
`totalPersistence_add`), (ii) degree-`1` homogeneous under rescaling (`H0_totalPersistence_smul`,
so the contact map has no intrinsic length scale), (iii) additive across an interior split point
(`H0_totalPersistence_concat`, a domain decomposition of the folding free energy), and — most
importantly — (iv) a function of the *endpoints alone* (`H0_energy_depends_only_on_endpoints`).
Point (iv) is a genuine *negative* result: it lets us construct two manifestly different monotone
folds with identical `H₀` energy (`native_fold_nonunique`), pinning the exact boundary of the
catalog's `native_fold_unique`. The injectivity/energy-separation hypothesis there is not
cosmetic — it is unavoidable, because `H₀` cannot distinguish folds that share endpoints. The
insight that ties the cycle together: **to resolve Levinthal-type uniqueness you must look
beyond `H₀`** (loops `H₁`, voids `H₂`), which is where the next cycle should go.

A secondary thread was a cross-domain bridge: any monotone integer sequence `a : ℕ → ℕ` becomes a
"fold" whose `H₀` energy is `aₙ − a₀` (`H0_totalPersistence_natSeq`), and specializing to the
Fibonacci positions `Fₖ` returns exactly `Fₙ` (`H0_totalPersistence_fib`), connecting the
topology layer to the catalog's Fibonacci number theory. Because the proof is sequence-agnostic
(extent rule plus the `a 0` value), every recursive/multiplicative integer sequence becomes a
persistence identity in waiting.

## Results Summary

- `totalPersistence_mono`: proved — `H₀` energy is monotone under multiset (feature) inclusion.
- `monotone_const_smul`: proved — nonnegative rescaling preserves chain monotonicity (scaling-law support).
- `H0_totalPersistence_smul`: proved — energy is degree-`1` homogeneous: `E(c·x) = c·E(x)` for `c ≥ 0`.
- `monotone_shift`: proved — a sub-chain `i ↦ x(i+m)` of a monotone chain is monotone (concat support).
- `H0_totalPersistence_concat`: proved — energy is additive across an interior split point.
- `H0_energy_depends_only_on_endpoints`: proved — `H₀` energy is a function of `(x 0, x n)` only.
- `chainA_monotone`, `chainB_monotone`: proved — two concrete monotone folds with shared endpoints.
- `native_fold_nonunique`: proved (counterexample) — distinct monotone folds with equal endpoints share `H₀` energy, so the injectivity hypothesis of `native_fold_unique` is not removable.
- `monotone_natSeq`: proved — a monotone `ℕ→ℕ` sequence casts to a monotone real chain.
- `H0_totalPersistence_natSeq`: proved — the fold at integer positions `aₖ` has `H₀` energy `aₙ − a₀`.
- `fibChain_monotone`: proved — the Fibonacci position sequence is monotone.
- `H0_totalPersistence_fib`: proved — the `H₀` energy of the Fibonacci fold equals `Fₙ` (topology ↔ number theory).

## Research Directions

### Direction 1: Higher persistent homology breaks the endpoint degeneracy
**Hypothesis**: There is an `H₁`-flavored persistence functional `E₁` on planar (or 3D) Cα
configurations such that two folds with equal endpoints and equal `H₀` energy but different loop
structure satisfy `E₁(fold₁) ≠ E₁(fold₂)`; i.e. `(E₀, E₁)` jointly separate the
`native_fold_nonunique` counterexample.
**Test**: Formalize a minimal `H₁` barcode for a cyclic contact graph (number/length of
independent cycles in the Vietoris–Rips complex at a fixed scale) and prove it distinguishes
`chainA` lifted to a loop versus an unknotted variant.
**The key insight is** that `native_fold_nonunique` already produces a fully formal pair of
`H₀`-indistinguishable folds, so any candidate higher invariant has a concrete, ready-made
fixture to be tested against rather than an abstract existence claim.
**Why now**: This cycle made the degeneracy *explicit and reusable*; a single Lean term now
witnesses exactly what `H₀` cannot see.
**If true**: Uniqueness of the native fold is recoverable from a *finite* tuple of persistence
energies — a quantitative refinement of `native_fold_unique`.
**If false**: Topological energy alone (any degree) cannot pin a fold, pushing the theory toward
genuinely geometric (metric, not just topological) functionals.

### Direction 2: General finite-metric elder rule = minimum spanning tree weight
**Hypothesis**: For any finite metric configuration, degree-`0` total persistence of its
Vietoris–Rips filtration equals the total edge weight of a minimum spanning tree of the complete
weighted graph; the chain result `H0_totalPersistence_eq_extent` is the special case where the
MST is the path through consecutive atoms.
**Test**: Define an MST-weight functional in Lean and prove equality with `totalPersistence` of
the `H₀` barcode for `Fintype` point sets; verify on 3- and 4-point examples by explicit
computation.
**The key insight is** that the additivity/monotonicity algebra proved this cycle
(`totalPersistence_add`, `totalPersistence_mono`, `H0_totalPersistence_concat`) is precisely the
induction-on-edges toolkit needed to grow the MST one edge at a time.
**Why now**: The chain case is fully proved and the monotonicity companion to additivity was just
established, closing the algebraic gap.
**If true**: Promotes the entire folding-energy theory from linear chains to arbitrary 3D
configurations — the realistic setting.
**If false**: The discrepancy localizes which non-tree cycles contribute, feeding the `H₁` theory
of Direction 1.

### Direction 3: Stability as a Lipschitz bound in the sup-metric
**Hypothesis**: `|E(x) − E(y)| ≤ 2 · sup_k |x k − y k|` for all monotone chains, a global,
all-coordinates strengthening of the catalog's two-endpoint `H0_totalPersistence_stable`.
**Test**: Derive it from `H0_energy_depends_only_on_endpoints` plus the triangle inequality, then
probe whether the constant `2` is tight and whether it survives the MST generalization of
Direction 2.
**The key insight is** that `H0_energy_depends_only_on_endpoints` collapses the whole functional
to two coordinates, so the sup-bound is a short corollary and the only open question is tightness.
**Why now**: The endpoint-only reduction was proved this cycle, turning a global stability claim
into a two-coordinate triangle-inequality exercise.
**If true**: Gives bottleneck stability of the folding energy landscape under thermal noise in a
clean operator-norm form.
**If false**: The failing configuration is a catalogable counterexample showing MST rewiring
under perturbation amplifies error beyond the endpoint bound.

### Direction 4: Integer-sequence folds as a topology↔number-theory dictionary
**Hypothesis**: Specializing `H0_totalPersistence_natSeq` to multiplicative/recursive sequences
yields number-theoretic identities — e.g. for `aₖ = ∑_{j≤k} φ(j)` the energy is the totient
summatory function, and for partial sums of the divisor function the energy is the divisor
summatory function.
**Test**: Instantiate `H0_totalPersistence_natSeq` with `Nat.totient`-partial-sums and
`Nat.sigma`-partial-sums (both monotone), deriving each summatory identity as a one-line corollary.
**The key insight is** that the energy proof is entirely sequence-agnostic (extent rule plus the
`a 0` value), so the bridge is already general — only the choice of arithmetic sequence remains.
**Why now**: `H0_totalPersistence_fib` is the first worked instance and `H0_totalPersistence_natSeq`
is its proven generalization, so the corollaries require no new topology.
**If true**: Catalog number-theory results can be re-read uniformly as statements about
persistent-homology energies.
**If false (some sequence breaks the monotone cast)**: It pinpoints exactly which arithmetic
functions fail to embed as folds — a precise constraint on the dictionary.

### Direction 5: Two-sided functoriality and the persistence-module structure
**Hypothesis**: The map `t ↦ Rips d t` with its inclusion maps assembles into a genuine
persistence module over `ℝ`, and `totalPersistence` factors through its barcode decomposition
functorially (interleaving distance ≤ ε ⇒ energies differ by ≤ C·ε).
**Test**: Define the inclusion morphisms `Rips d s → Rips d t` (supported by the catalog's
`Rips_mono`) and prove a categorical interleaving-stability statement for the chain model.
**The key insight is** that `Rips_mono` (catalog) and `totalPersistence_mono` (this cycle) supply
both halves of the functoriality square, leaving only the morphism bookkeeping.
**Why now**: The monotonicity half of the square was the missing piece and was proved this cycle.
**If true**: Connects the folding model to standard persistence-module machinery, importing
bottleneck/interleaving stability in full generality.
**If false**: The obstruction reveals where the finite-chain model departs from continuous
persistence-module theory — itself a publishable boundary.
