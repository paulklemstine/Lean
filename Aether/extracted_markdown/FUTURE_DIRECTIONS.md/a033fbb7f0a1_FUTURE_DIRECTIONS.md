# Future Directions — The Minimum-Spanning-Tree Law for `H₀` Persistence and Beyond

## Synthesis

The file `Catalog/Speculative/AutoResearch/ProteinFoldingMST.lean` models the degree-`0` total
persistence of a Vietoris–Rips filtration on a finite metric configuration ("protein") as the
**minimum-spanning-tree functional** `MSTWeight Trees hne w = Trees.inf' hne (treeWeight w)`, a
minimum of an additive edge-weight functional over an admissible family of merge trees. The central
discovery is conceptual unification: the *elder rule* of persistent homology is, at degree `0`,
nothing but the order theory of `Finset.inf'`. Every "folding law" we want is therefore a structural
property of an infimum of an additive, monotone, Lipschitz family — and the *same* proof skeleton
(select the optimizer with `exists_mem_eq_inf'`, bound it with `inf'_le` / `le_inf'`) closes them all.

## Results Summary

Proven, with `sorry = 0` and only the standard axioms (`propext`, `Classical.choice`, `Quot.sound`):

- `MSTWeight_exists_argmin` — attainment of the optimal merge tree.
- `MSTWeight_mono`, `MSTWeight_strict_mono` — the hydrophobic-collapse monotonicity law and its
  strict form (the latter under "every tree is nonempty").
- `contraction_lowers_energy_metric` — a metric contraction by `c ≤ 1` lowers the topological energy;
  the proof reveals the lower bound `0 ≤ c` is *not* needed, generalizing the physical statement.
- `MSTWeight_stable` — Lipschitz / bottleneck stability with the constant `k = #edges`.
- `chain_MSTWeight_eq_extent` — the 1-D bridge: a chain's consecutive gaps telescope to its extent
  `x n − x 0` (= `max − min` when monotone), recovering the elder-rule extent identity.
- `energy_gap_unique_min`, `energy_gap_robust` — a positive energy gap forces a unique native fold
  and places every decoy strictly above the energy by the full gap.
- `MSTWeight_mono_needs_pointwise` — a boundary theorem (explicit `Fin 2` counterexample) showing the
  pointwise contraction hypothesis of `MSTWeight_mono` is genuinely necessary.

## Direction 1 — `MSTWeight` equals the Kruskal cut/cycle construction

Replace the abstract admissible family `Trees` by the genuine graph-theoretic spanning trees of the
complete graph on `n` atoms with edge weights `w`, and prove `MSTWeight (spanningTrees n) hne w`
equals the sum of weights selected by Kruskal's greedy algorithm — equivalently the sum of
single-linkage merge distances. **The key insight is** that the elder rule and Kruskal's cut property
are the same exchange argument: the cheapest edge crossing any component cut is always safe to add, so
the greedy deaths are exactly the bar deaths. **Why now?** Mathlib's `SimpleGraph.IsTree`,
`SimpleGraph.IsAcyclic`, and the `Finset` exchange-lemma API are mature enough for a clean
matroid-style proof, and `MSTWeight_exists_argmin` already supplies the optimizer the cut property
must characterize; the claim is finite and checkable against SciPy MST weights on PDB structures.

## Direction 2 — Bottleneck (not sup) stability

`MSTWeight_stable` pays a factor of `k = #edges`. Sharpen it: `|MSTWeight w − MSTWeight w'|` is at
most the `1`-Wasserstein (hence bottleneck) distance of the two `H₀` death multisets, with *no*
dependence on `k`. **The key insight is** that the MST realizes a matching between the two barcodes'
deaths, so the energy gap is a transport cost, not a sum of per-edge worst cases — the `k` in
`MSTWeight_stable` is an artifact of bounding each edge separately. **Why now?**
`MSTWeight_exists_argmin` gives explicit optimizers on both sides, so the matching needed for the
transport bound is already in hand; the predicted `k`-independent constant is falsifiable by
perturbing one structure and checking the energy change saturates the bottleneck, not the `kε`, bound.

## Direction 3 — A polynomial Levinthal bound

Combine the Lipschitz law (`MSTWeight_stable`, giving an `L`) with the gap criterion
(`energy_gap_unique_min`, giving a `γ > 0`) into a quantitative descent theorem: if the topological
energy is `L`-Lipschitz in the configuration and the native basin has spectral gap `γ`, then projected
gradient descent reaches the basin in `O(L²/γ²)` steps — polynomial, not exponential. **The key
insight is** that a globally Lipschitz energy with an isolated minimum cannot hide that minimum behind
exponentially many barriers, which is precisely the structural content Levinthal's paradox demands.
**Why now?** Both ingredients are now formal, so only a standard convergence estimate remains; it is
falsifiable by measuring the empirical step-count scaling of persistence-gradient descent across
protein lengths and checking the predicted `γ⁻²` dependence.

## Direction 4 — A signature-vector theorem for higher barcodes `(TP₀, TP₁, TP₂)`

`MSTWeight` is degree `0` only. Conjecture: native folds minimize `TP₀` **subject to** a fixed nonzero
target for `TP₁` (the main-chain loop) and `TP₂` (the hydrophobic-core cavity), rather than minimizing
total persistence in every degree. Define `TPᵢ` via filtered Čech/Rips chain complexes and prove a
constrained-optimization characterization of the native state. **The key insight is** that a protein
is topologically nontrivial — collapse with zero `H₂` persistence is a molten globule, not a fold — so
the native state lives on a level set of `TP₂`, not at its minimum. **Why now?** Fast Vietoris–Rips
engines make multi-degree barcodes computable for full proteins, making the hypothesis immediately
testable on native/decoy ensembles, while Mathlib's simplicial-homology API makes a degree-`1` toy
case a realistic first milestone.

## Direction 5 — Gap stability: foldability is an open condition

`energy_gap_unique_min` gives uniqueness from a positive gap at *fixed* energies; the robust
conjecture is that the gap itself is stable: a perturbation of `ε` in Gromov–Hausdorff distance moves
the gap by at most `2·(#edges)·ε` (apply `MSTWeight_stable` to both the minimizer and runner-up).
Consequently foldability is an *open* condition — a strictly foldable sequence stays foldable under
small structural noise, while an intrinsically disordered one stays gapless. **The key insight is**
that foldability is the perturbation-stable version of `Set.InjOn` at the minimizer, so it must
inherit the Lipschitz stability already proved for the energy. **Why now?** `MSTWeight_stable` is
exactly the per-decoy Lipschitz estimate this argument needs, and intrinsically disordered proteins
furnish a ready negative control: ordered proteins should show a noise-robust persistence-energy gap
while disordered ones should not.
