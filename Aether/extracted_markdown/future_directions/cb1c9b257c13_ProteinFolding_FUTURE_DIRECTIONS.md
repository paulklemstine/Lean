# Future Directions — Biological Topology: Protein Folding as Persistent-Homology Optimization

The Lean development in `Catalog/Speculative/ProteinFolding.lean` establishes the rigorous
backbone of a topological theory of folding: barcodes, total persistence as a topological
*energy*, functoriality of the Vietoris–Rips contact filtration (`Rips_mono`), the elder-rule
identity on a chain (`H0_totalPersistence_eq_extent`), bottleneck stability
(`H0_totalPersistence_stable`), and existence/uniqueness of the native fold as the argmin of
the energy (`exists_native_fold`, `native_fold_unique`). The conjectures below are the natural
next theorems, each formalizable in Lean and each empirically testable.

## Direction 1 — The general minimum-spanning-tree law for `H₀` total persistence

The chain result `H0_totalPersistence_eq_extent` is the path-graph special case of a sweeping
identity: for *any* finite metric configuration of Cα atoms, the degree-`0` total persistence of
the Vietoris–Rips filtration equals the total edge weight of a minimum spanning tree of the
complete weighted graph on the atoms. **The key insight is** that single-linkage clustering and
`H₀` persistence are the same process viewed two ways — components merge exactly along MST edges,
so each bar's death is one MST edge weight and the births are all `0`. **Why now?** Mathlib now
has a mature `SimpleGraph` and weighted-graph API, and the elder-rule telescoping argument we
already proved is the `n = path` shadow of Kruskal's algorithm; lifting it to general trees is a
finite, falsifiable combinatorial statement (test: for 100 PDB structures, the GUDHI `H₀`
persistence sum must equal the SciPy MST weight to floating-point tolerance).

## Direction 2 — Compaction monotonicity beyond one dimension (the hydrophobic-collapse theorem)

`compaction_lowers_persistence` shows, on a line, that shrinking the extent lowers the energy.
The multidimensional conjecture: if a configuration `Y` is a `1`-Lipschitz contraction of `X`
(every pairwise distance weakly decreases), then `totalPersistence (H₀(Y)) ≤ totalPersistence (H₀(X))`.
**The key insight is** that a global contraction can only make components merge *earlier*, never
later, so every bar's death time can only decrease — monotonicity of the whole barcode under
distance contraction. **Why now?** This is the precise mathematical content of "the hydrophobic
core pulls the chain inward," and it is directly testable: artificially contracting decoy
coordinates toward their centroid must never raise the measured `H₀` persistence.

## Direction 3 — A Levinthal speed bound from the stability constant

`H0_totalPersistence_stable` gives a Lipschitz constant `2` between coordinate perturbations and
energy change on a chain. Conjecture: the energy landscape `E = totalPersistence ∘ H₀` is globally
Lipschitz in the configuration (in Gromov–Hausdorff distance) with an explicit constant depending
only on `N`, and this constant bounds the number of gradient-descent steps to the native basin by a
**polynomial** in `N`. **The key insight is** that a Lipschitz, single-well topological energy
cannot hide its minimum behind exponentially many barriers, which is exactly what Levinthal's
paradox needs explained. **Why now?** With stability proved in the chain case, the general
Lipschitz estimate is the missing quantitative ingredient; it is falsifiable by measuring the
empirical step-count-to-convergence scaling of persistence-gradient descent across protein lengths.

## Direction 4 — Higher barcodes detect the hydrophobic void (a degree-1/2 signature)

Total persistence in degree `0` measures connectivity; degrees `1` and `2` measure loops and
cavities. Conjecture: native folds are characterized not by minimal *total* persistence but by a
fixed **signature vector** `(TP₀, TP₁, TP₂)` in which `TP₀` is minimized while `TP₁, TP₂` carry a
sharp, reproducible nonzero peak corresponding to the hydrophobic core cavity and the main-chain
loop. **The key insight is** that a protein is not topologically trivial — collapse without a
persistent `H₂` void would be a molten globule, not a fold, so the native state *minimizes* `TP₀`
*subject to* a target `H₂` persistence rather than minimizing all degrees. **Why now?** Fast
Vietoris–Rips engines (Ripser) make multi-degree barcodes computable for full proteins, so the
signature-vector hypothesis can be checked against native/decoy ensembles immediately.

## Direction 5 — Energy-gap uniqueness as a foldability criterion

`native_fold_unique` gives uniqueness when the energy is injective on the decoy set. Conjecture:
a sequence is *foldable* (has a well-defined native state) iff its topological energy landscape has
a strictly positive **spectral gap** — the second-smallest energy over a dense decoy ensemble
exceeds the minimum by a margin bounded below independently of ensemble size. **The key insight is**
that foldability is not about the depth of the global minimum but about its *isolation*: a positive
energy gap is exactly the robust version of `Set.InjOn` at the minimizer. **Why now?** Intrinsically
disordered proteins (no unique fold) provide a natural negative control, so the gap criterion is
directly falsifiable — ordered proteins should show a measurable persistence-energy gap and
disordered ones should not.
