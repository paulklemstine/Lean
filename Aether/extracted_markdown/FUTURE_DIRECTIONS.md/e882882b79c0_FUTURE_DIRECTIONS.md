# Future Directions — The Minimum-Spanning-Tree Law for `H₀` Persistence

## Synthesis

`ProteinFoldingMST.lean` models the degree-`0` total persistence of a Vietoris–Rips filtration on a
finite metric configuration (a "protein") as the **minimum-spanning-tree functional**

```
MSTWeight Trees hne w = Trees.inf' hne (treeWeight w),   treeWeight w T = ∑ e ∈ T, w e.
```

The conceptual payload is a local-to-global unification: the **elder rule** of persistent homology
is, at degree `0`, nothing more than the order theory of `Finset.inf'`. Every "folding law" we want
turns out to be a structural property of an infimum of an additive, monotone, Lipschitz family, and a
*single* proof skeleton — extract the optimizer with `Finset.exists_mem_eq_inf'`, then bound it with
`Finset.inf'_le` / `Finset.le_inf'` — glues the local edge-level bounds into the global folding
statement. This is precisely a sheaf-theoretic *gluing*: local sections (per-tree energies) are
reconciled into a global section (the native energy) by the meet operation, and the obstruction to
naive gluing (the `Fin 2` counterexample) measures exactly where pointwise domination fails.

## Results Summary (all with `sorry = 0`, axioms `propext` / `Classical.choice` / `Quot.sound`)

- `MSTWeight_exists_argmin` — attainment of the optimal merge tree (the native fold exists).
- `treeWeight_mono`, `MSTWeight_mono`, `MSTWeight_strict_mono` — the hydrophobic-collapse
  monotonicity law and its strict refinement under "every admissible tree is nonempty".
- `contraction_lowers_energy_metric` — a metric contraction by `c ≤ 1` lowers the topological energy;
  the proof exposes that `0 ≤ c` is *not* needed, generalizing the physical statement.
- `MSTWeight_stable` — Lipschitz / bottleneck stability with constant `k = #edges`.
- `chain_MSTWeight_eq_extent` — the 1-D bridge: a chain's consecutive gaps telescope to its extent
  `x n − x 0`, recovering the elder-rule extent identity.
- `energy_gap_unique_min`, `energy_gap_robust` — a positive energy gap forces a unique native fold and
  places every decoy above the energy by the full gap.
- `MSTWeight_mono_needs_pointwise` — a boundary theorem (explicit `Fin 2` counterexample) showing the
  pointwise contraction hypothesis of `MSTWeight_mono` is genuinely load-bearing.

## Direction 1 — `MSTWeight` equals the Kruskal cut/cycle construction

Replace the abstract admissible family `Trees` by the genuine graph-theoretic spanning trees of the
complete graph on `n` atoms with edge weights `w`, and prove `MSTWeight (spanningTrees n) hne w`
equals the total weight selected by Kruskal's greedy algorithm — equivalently the sum of
single-linkage merge distances. **The key insight is** that the elder rule and Kruskal's cut property
are the same exchange argument: the cheapest edge crossing any component cut is always safe to add, so
the greedy deaths are exactly the barcode deaths, and `MSTWeight_exists_argmin` already produces the
optimizer that the cut property must characterize. **Why now?** Mathlib's `SimpleGraph.IsTree`,
`SimpleGraph.IsAcyclic`, and the `Finset` exchange-lemma API are mature enough for a clean
matroid-style proof, and the claim is finite and checkable numerically against MST weights on PDB
structures.

## Direction 2 — Bottleneck (not sup) stability

`MSTWeight_stable` pays a factor `k = #edges`. Sharpen it: `|MSTWeight w − MSTWeight w'|` is at most
the `1`-Wasserstein (hence bottleneck) distance of the two `H₀` death multisets, with *no* dependence
on `k`. **The key insight is** that the MST realizes a matching between the two barcodes' deaths, so
the energy gap is a transport cost, not a sum of per-edge worst cases — the `k` is an artifact of the
edge-by-edge bound used in the current proof. **Why now?** `MSTWeight_exists_argmin` supplies explicit
optimizers on both sides, so the matching the transport bound needs is already in hand; the predicted
`k`-independent constant is falsifiable by perturbing a single structure and checking the energy
change saturates the bottleneck, not the `kε`, bound.

## Direction 3 — Gap stability: foldability is an open condition

`energy_gap_unique_min` gives uniqueness from a positive gap at *fixed* weights. Conjecture: the gap
itself is stable — a perturbation of `ε` per edge moves the gap by at most `2·k·ε` (apply
`MSTWeight_stable` to both the minimizer and the runner-up). Consequently foldability is an *open*
condition: a strictly foldable configuration stays foldable under small structural noise, while a
gapless one stays gapless. **The key insight is** that foldability is the perturbation-stable version
of injectivity-at-the-minimizer, so it must inherit the Lipschitz stability already proved for the
energy. **Why now?** `MSTWeight_stable` is exactly the per-decoy Lipschitz estimate this argument
needs, and intrinsically disordered proteins furnish a ready negative control (ordered ⇒ robust gap,
disordered ⇒ no gap).

## Direction 4 — A signature-vector theorem for higher barcodes `(TP₀, TP₁, TP₂)`

`MSTWeight` is degree `0` only. Conjecture: native folds minimize `TP₀` **subject to** a fixed nonzero
target for `TP₁` (the main-chain loop) and `TP₂` (the hydrophobic-core cavity), rather than minimizing
total persistence in every degree. Define `TPᵢ` via filtered Čech/Rips chain complexes and prove a
constrained-optimization characterization of the native state. **The key insight is** that a fold is
topologically nontrivial — collapse with zero `H₂` persistence is a molten globule, not a fold — so
the native state lives on a *level set* of `TP₂`, not at its minimum. **Why now?** Mathlib's
simplicial-homology API makes a degree-`1` toy case a realistic first milestone, and fast
Vietoris–Rips engines make multi-degree barcodes computable on native/decoy ensembles for testing.

## Direction 5 — A sheaf of merge trees and the cohomological obstruction to global gluing

Promote `Trees` to a presheaf assigning to each sub-configuration its admissible merge trees, with
restriction maps given by edge deletion, and let `MSTWeight` be the section functional. Conjecture:
the local minima glue to the global native fold **iff** a degree-`1` Čech obstruction class vanishes,
and `MSTWeight_mono_needs_pointwise` is the smallest nonvanishing representative of that class.
**The key insight is** that the failure of "one cheaper edge lowers the global energy" is not noise
but an obstruction cocycle — gluing local descent into global descent is exactly a `H¹` vanishing
statement. **Why now?** The `Fin 2` counterexample already pins the minimal obstruction, and Mathlib's
`Presheaf`/`Cech` infrastructure makes a two-cover toy computation tractable; the conjecture is
falsifiable by exhibiting a configuration with vanishing obstruction yet no global minimizer.
