# Future Directions: Topological Theory of Protein Folding

These conjectures extend the formal results in
`Speculative/AutoResearch/ProteinFoldingGeneralized.lean`, which generalizes the chain model
of `ProteinFolding.lean` into three structural laws of the topological energy
`totalPersistence` and the Vietoris–Rips contact filtration `Rips`:

* `Rips_scale` — exact scaling symmetry of the contact filtration;
* `totalPersistence_scale` — degree-one homogeneity of the energy;
* `ForestBarcode_totalPersistence` — the elder rule for a *branched* fold (H₀ energy = total
  merge-forest weight), with `H0LineBarcode_eq_extent_via_forest` recovering the chain extent
  law as the path special case;
* `totalPersistence_W1_stable` — Wasserstein-1 (matching) stability of the energy;
* `min_spanning_tree_lower_bound` — a minimum-weight spanning tree lower-bounds every spanning
  tree's energy.

Each direction below is testable and falsifiable, names the Lean handle of the would-be
theorem, and states the empirical or formal experiment that could refute it.

---

## 1. Minimum-spanning-tree optimality of the H₀ barcode (`mst_optimality`)

The elder rule we proved (`ForestBarcode_totalPersistence`) says the degree-0 total persistence
of *a* merge forest equals its total edge weight. The missing strengthening is that the merge
forest actually realized by single-linkage clustering of the Cα point cloud is a **minimum**
spanning tree of the complete weighted graph, so its weight lower-bounds `spanningWeight d T`
over all spanning trees `T` — closing the loop with `min_spanning_tree_lower_bound`, whose
minimality hypothesis would then be discharged rather than assumed.

The key insight is that the degree-0 persistent homology functor *is* single-linkage
hierarchical clustering, and the cut property of MSTs gives a purely local certificate of global
optimality: for every cut of the vertex set, the cheapest crossing edge is in the MST.

Why now: Mathlib now has a substantial matroid and greedoid layer; MST optimality is the
greedy-matroid exchange lemma specialized to the graphic matroid, so the cut property is finally
within reach of a fully formal proof rather than an informal appeal.

Falsifiable test: for 100 PDB structures, compute the single-linkage dendrogram of the Cα cloud
and an independent MST (Prim/Kruskal); the conjecture predicts identical total weight. A single
protein where the two disagree refutes it.

---

## 2. Stability of the energy is tight, not just an upper bound (`W1_stability_sharp`)

We proved `totalPersistence_W1_stable`: the energy is 1-Lipschitz in the ℓ¹ matching metric.
The conjecture is that the bound is **achieved** — there exist barcodes (and underlying folds)
for which `|TotalPersistence B − TotalPersistence C|` equals the optimal matching cost, so the
Lipschitz constant 1 is sharp and `totalPersistence` is an isometry onto its image for the
optimal transport plan that moves every bar monotonically.

The key insight is that when all matched lifetime differences share a sign, the triangle
inequality `abs_add_le` used in the proof becomes an equality, so co-monotone perturbations (a
uniform thermal expansion of the whole molecule) saturate the bound exactly.

Why now: the proof of `totalPersistence_W1_stable` already exposes the exact equality condition
(same-sign differences), so the sharp converse is a short formal step rather than new theory.

Falsifiable test: perturb a native fold by a uniform radial expansion of factor `1+δ`; the
predicted energy change is exactly `δ · (end-to-end extent)`. Any sublinear deviation at small
`δ` refutes sharpness.

---

## 3. The native fold is the unique global minimizer modulo rigid motions (`native_isolated`)

Combining homogeneity (`totalPersistence_scale`) with the existence/uniqueness scaffolding of
`ProteinFolding.lean` (`exists_native_fold`, `native_fold_unique`), the conjecture is that for a
fixed primary sequence the topological energy has an **isolated** global minimum: the native fold
is separated from all decoys by a strictly positive energy gap that scales linearly with molecule
size.

The key insight is that scale-homogeneity forbids a flat energy valley — if two distinct compact
configurations had equal energy, rescaling would produce a one-parameter family of minimizers,
contradicting the discreteness of contact topology classes.

Why now: AlphaFold2's empirical success implies a well-separated minimum exists; persistent
homology gives the first candidate order parameter (the energy gap) whose size can be predicted
*a priori* from sequence length rather than measured post hoc.

Falsifiable test: across the 100-protein benchmark, regress the native-vs-best-decoy energy gap
against chain length `n`; the conjecture predicts a strictly positive slope. A vanishing or
negative trend refutes it.

---

## 4. Higher-degree persistence detects the hydrophobic core (`H1_core_signature`)

Our forest law is purely degree-0 (connectivity). The conjecture is that the **degree-1**
barcode — loops in the Vietoris–Rips filtration — carries a quantitative signature of the
hydrophobic core: native folds have exactly one long-lived H₁ bar per closed loop of the
backbone enclosing buried residues, and decoys either lack it or have spurious short bars.

The key insight is that `Rips_mono` already makes the filtration functorial in every degree, so
the same elder/younger bookkeeping that gives the MST law in degree 0 lifts to a *cycle* law in
degree 1, with deaths governed by minimal filling disks instead of minimal spanning edges.

Why now: the degree-0 machinery is now formal and reusable; promoting `ForestBarcode` to a
degree-1 "cycle barcode" needs only a Mathlib simplicial-homology interface, which the recent
`Mathlib.AlgebraicTopology` development is converging toward.

Falsifiable test: compute H₁ barcodes for native vs decoy ensembles; the conjecture predicts the
count of long H₁ bars equals the number of solvent-excluded loops in the native structure. A
protein where decoys reproduce the native H₁ count refutes the signature.

---

## 5. Compaction monotonicity generalizes from extent to diameter (`diameter_energy_monotone`)

`ProteinFolding.lean` proved `compaction_lowers_persistence` for the one-dimensional extent.
The conjecture is the genuinely multi-dimensional statement: if one configuration is
componentwise "more compact" than another in the sense that its Cα distance matrix is entrywise
≤ the other's, then its total persistence is ≤ the other's — so hydrophobic collapse is
energetically favored in full 3D, not just along a line.

The key insight is that `Rips_mono` plus the MST law makes total persistence a *monotone*
functional of the distance matrix: shrinking any pairwise distance can only lower MST edge
weights, hence the degree-0 energy, with no need for the chain hypothesis.

Why now: with the forest/MST elder rule formalized, monotonicity reduces to monotonicity of MST
weight under entrywise distance decrease — a clean lattice-theoretic lemma rather than a
geometric argument.

Falsifiable test: take any decoy, uniformly contract a random subset of its contacts, and
recompute total persistence; the conjecture predicts the energy never increases. A single
contraction that raises the energy refutes it.
