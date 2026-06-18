# FUTURE_DIRECTIONS — Persistent-Homology Folding (Extended)

## Synthesis

This cycle extended the catalog's topological theory of protein folding
(`Speculative/AutoResearch/ProteinFolding.lean`, the `ProteinTopology` namespace) along four
axes, collected in `Speculative/AutoResearch/PersistentHomologyFoldingExt.lean` (namespace
`FoldingHomology`). The catalog had established the *elder rule on a chain*
(`H0_totalPersistence_eq_extent`: degree-0 total persistence = end-to-end extent) and the
existence/uniqueness of a "native fold" as the argmin of topological energy. The structural
question we pressed on was: **how rigid is the energy functional, and how much does it actually
determine the fold?**

The recurring discovery is that the degree-0 ("`H₀`") total persistence is an extraordinarily
*coarse* invariant. Because it telescopes to `xₙ − x₀`, it is (i) additive over disjoint
features and sub-chains (`totalPersistence_add`, `H0_totalPersistence_concat`), (ii) monotone
under feature inclusion (`totalPersistence_mono`), (iii) degree-1 homogeneous under rescaling
(`H0_totalPersistence_smul`), and — most importantly — (iv) a function of the *endpoints alone*
(`H0_energy_depends_only_on_endpoints`). Point (iv) is a genuine *negative* result: it lets us
construct two manifestly different monotone folds with identical `H₀` energy
(`native_fold_nonunique`), pinning the exact boundary of the catalog's `native_fold_unique`
theorem. The injectivity/energy-separation hypothesis there is not cosmetic — it is unavoidable,
because `H₀` cannot distinguish folds that share endpoints. The structural insight that ties the
cycle together: **to resolve Levinthal-type uniqueness you must look beyond `H₀`** to higher
persistent homology (loops `H₁`, voids `H₂`), which is exactly where the next cycle should go.

A secondary thread was a cross-domain bridge: evaluating the persistent-homology energy on the
Fibonacci sequence (atoms placed at `Fₖ`) returns exactly `Fₙ` (`H0_totalPersistence_fib`),
connecting the topology layer to the catalog's Fibonacci number theory
(`Shared/Fib_gcd_identity`, `Speculative/AutoResearch/FibPrimitive`). This is a template:
any monotone integer sequence becomes a "fold" whose topological energy is its terminal value.

## Results Summary

- `totalPersistence_mono`: proved — topological energy is monotone under multiset (feature) inclusion; the order-theoretic companion of additivity.
- `monotone_const_smul`: proved — nonnegative rescaling preserves monotonicity of a chain (supporting lemma for the scaling law).
- `H0_totalPersistence_smul`: proved — folding energy is degree-1 homogeneous: rescaling coordinates by `c ≥ 0` scales energy by `c`; the contact map has no intrinsic length scale.
- `H0_totalPersistence_concat`: proved — energy is additive across an interior split point (domain decomposition of the folding free energy).
- `H0_energy_depends_only_on_endpoints`: proved — degree-0 energy is a function of `(x 0, x n)` only; the structural root of Levinthal degeneracy.
- `chainA_monotone`, `chainB_monotone`: proved — two concrete monotone folds with shared endpoints (supporting the counterexample).
- `native_fold_nonunique`: proved (counterexample) — two distinct monotone folds with equal endpoints share `H₀` energy, so `native_fold_unique`'s injectivity hypothesis is not removable.
- `fibChain_monotone`: proved — the Fibonacci position sequence is monotone (supporting the bridge).
- `H0_totalPersistence_fib`: proved — the `H₀` energy of the Fibonacci fold equals `Fₙ`; a topology↔number-theory bridge.

## Research Directions

### Direction 1: Higher persistent homology breaks the endpoint degeneracy
**Hypothesis**: There is a `H₁`-flavored persistence functional `E₁` on planar (or 3D) Cα
configurations such that two folds with equal endpoints and equal `H₀` energy but different loop
structure satisfy `E₁(fold₁) ≠ E₁(fold₂)`; i.e. `(E₀, E₁)` jointly separate the `native_fold_nonunique`
counterexample.
**Test**: Formalize a minimal `H₁` barcode for a cyclic contact graph (e.g. the number/length of
independent cycles in the Vietoris–Rips complex at a fixed scale) and prove it distinguishes
`chainA` lifted to a loop vs. an unknotted variant.
**Why now**: `native_fold_nonunique` gives an explicit, fully-formal pair of indistinguishable
folds — a ready-made test fixture for any candidate higher invariant.
**If true**: Uniqueness of the native fold can be recovered from a *finite* tuple of persistence
energies, a quantitative refinement of `native_fold_unique`.
**If false**: It would suggest topological energy alone (any degree) cannot pin a fold, pushing
the theory toward geometric (metric, not just topological) functionals.

### Direction 2: General finite-metric elder rule = minimum spanning tree weight
**Hypothesis**: For any finite metric configuration, the degree-0 total persistence of its
Vietoris–Rips filtration equals the total edge weight of a minimum spanning tree of the complete
weighted graph; the chain result `H0_totalPersistence_eq_extent` is the special case where the MST
is the path through consecutive atoms.
**Test**: Define an MST-weight functional in Lean and prove equality with `totalPersistence` of the
`H₀` barcode for `Fintype` point sets; verify on a 3- and 4-point example by `decide`/explicit computation.
**Why now**: The chain case is fully proved and the additivity/monotonicity algebra
(`totalPersistence_add`, `totalPersistence_mono`) is exactly the toolkit needed to induct on edges.
**If true**: Promotes the entire folding-energy theory from linear chains to arbitrary 3D
configurations — the realistic setting.
**If false**: The discrepancy would localize precisely which non-tree cycles contribute, informing
the `H₁` theory of Direction 1.

### Direction 3: Stability as a Lipschitz bound in the sup-metric
**Hypothesis**: `|E(x) − E(y)| ≤ 2 · sup_k |x k − y k|` for all monotone chains (a global,
all-coordinates strengthening of the catalog's two-endpoint `H0_totalPersistence_stable`).
**Test**: Prove it from `H0_energy_depends_only_on_endpoints` + the triangle inequality, then probe
whether the constant `2` is tight and whether it survives the MST generalization of Direction 2.
**Why now**: `H0_energy_depends_only_on_endpoints` reduces the whole functional to two coordinates,
making the sup-bound a short corollary while exposing the tightness question.
**If true**: Gives bottleneck stability of the folding energy landscape under thermal noise in a
clean operator-norm form.
**If false**: The failing configuration is a counterexample worth cataloguing — it would mean MST
rewiring under perturbation amplifies error beyond the endpoint bound.

### Direction 4: Integer-sequence folds as a topology↔number-theory dictionary
**Hypothesis**: For every monotone `a : ℕ → ℕ`, the fold at positions `aₖ` has `H₀` energy `aₙ − a₀`;
specializing to multiplicative/recursive sequences yields identities (e.g. for `aₖ = ∑_{j≤k} φ(j)`,
the energy is the totient summatory function), turning persistence identities into number-theoretic ones.
**Test**: Generalize `H0_totalPersistence_fib` to an arbitrary monotone `ℕ→ℕ` sequence, then derive
the totient-summatory and partial-sum-of-divisors instances as corollaries.
**Why now**: `H0_totalPersistence_fib` is the first worked instance; the proof is sequence-agnostic
(`H0_totalPersistence_eq_extent` + `a₀` value), so generalization is immediate.
**If true**: Provides a uniform bridge letting catalog number-theory results
(`Fib_gcd_identity`, `FibPrimitive`) be re-read as statements about persistent-homology energies.
**If false (i.e. some sequence breaks monotonicity casting)**: It pinpoints exactly which arithmetic
functions fail to embed as folds, a constraint on the dictionary.

### Direction 5: Two-sided functoriality and the persistence module structure
**Hypothesis**: The map `t ↦ Rips d t` together with the inclusion maps assembles into a genuine
persistence module over `ℝ`, and `totalPersistence` factors through its barcode decomposition
functorially (interleaving distance ≤ ε ⇒ energies differ by ≤ C·ε).
**Test**: Define the inclusion morphisms `Rips d s → Rips d t` (already supported by the catalog's
`Rips_mono`) and prove a categorical interleaving-stability statement for the chain model.
**Why now**: `Rips_mono` (catalog) plus this cycle's `totalPersistence_mono` give both halves of the
functoriality square; only the morphism bookkeeping remains.
**If true**: Connects the folding model to the standard persistence-module machinery, opening the
door to importing bottleneck/interleaving stability in full generality.
**If false**: The obstruction would reveal where the finite-chain model departs from the continuous
persistence-module theory — itself a publishable boundary.
