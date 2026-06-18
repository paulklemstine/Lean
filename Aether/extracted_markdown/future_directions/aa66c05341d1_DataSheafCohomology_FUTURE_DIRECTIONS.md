# Future Directions — Sheaf Cohomology of Data: The Topology of Missing Information

## Synthesis

We formalized the claim that *a dataset with missing values is a cellular sheaf* and made
its two lowest cohomology invariants computable and provable in Lean 4. The carrier is the
**co-observation graph** `coobsGraph present` on the records of a dataset: two records are
linked exactly when they share at least one *observed* feature, so an edge is a place where
the records' imputed values are genuinely coupled. Over a field `k` the constant data sheaf
attaches `k` to each record and the equality constraint to each edge, and:

- `H⁰` is the space of **globally consistent imputations** and equals `CellularSheaf.H0`
  of the catalog (`ker_dataDelta_eq_H0`); its dimension is the number of **data clusters**
  — connected components — that no chain of shared features can bridge
  (`finrank_dataH0_eq_clusters`, inherited from
  `CellularSheaf.finrank_H0_eq_card_connectedComponent`).
- `H¹` is the **obstruction to patching**, defined as the cokernel of the oriented
  coboundary `dataDelta`. Its dimension is the **first Betti number / circuit rank**

      dim H¹ = (#shared-feature couplings) − (#records) + (#data clusters)

  (`finrank_dataH1_eq_firstBetti`), and it vanishes exactly on acyclic (forest) data
  (`dataH1_trivial_of_tree`).

The load-bearing engine is a single basis-free **Euler / rank–nullity identity**
`finrank_ker_sub_finrank_coker`: `dim ker T − dim coker T = dim dom − dim cod` for any
linear map between finite-dimensional spaces. This mirrors the Hodge–Betti philosophy of
`Catalog/Speculative/AutoResearch/HodgeBettiRank.lean` (`hodge_betti`) but for the
combinatorial coboundary of a data sheaf instead of the Hodge Laplacian.

## Results summary

| Theorem | Statement | Status |
|---|---|---|
| `finrank_ker_sub_finrank_coker` | `dim ker T − dim coker T = dim dom − dim cod` | proved, sorry-free |
| `ker_dataDelta_eq_H0` | global sections = consistent imputations (`ker δ = H⁰`) | proved, sorry-free |
| `finrank_dataH0_eq_clusters` | `dim H⁰ = #data clusters` | proved, sorry-free |
| `finrank_dataH1_eq_firstBetti` | `dim H¹ = #couplings − #records + #clusters` | proved, sorry-free |
| `dataH1_trivial_of_tree` | forest ⟹ `dim H¹ = 0` (fully patchable) | proved, sorry-free |

All depend only on `propext`, `Classical.choice`, `Quot.sound`.

## Research directions

**1. The original `r·n·r·log(1/r)` conjecture is almost certainly the wrong law — replace it
with the exact circuit-rank law and an Erdős–Rényi prediction.** Our `finrank_dataH1_eq_firstBetti`
proves that `dim H¹` is *exactly* the circuit rank `E − V + c` of the co-observation graph,
a quantity with no `log` in it. Under a Missing-Completely-At-Random model with retention
probability `p = 1 − r`, two records co-observe a feature with probability
`1 − (1 − p²)ⁿ`, so the co-observation graph is an Erdős–Rényi graph `G(m, q)` with
`q = 1 − (1 − (1−r)²)ⁿ`; its expected circuit rank is `E[E] − m + E[c]`, which for
`q` above the connectivity threshold is `≈ binom(m,2)·q − m + 1`, growing *quadratically*
in the number of records and not matching `r·n·r·log(1/r)` at all. *The key insight is* that
`dim H¹` is a hard combinatorial invariant (circuit rank), so the missing-information law is
dictated by random-graph connectivity thresholds, not by an entropy-style `r log(1/r)` term.
*Why now?* We finally have the exact formula in Lean, so the falsifiable claim
"`E[dim H¹] = binom(m,2)q − m + E[c]` with `q = 1 − (1−(1−r)²)ⁿ`" can be checked against
synthetic datasets and, if it fails, located precisely to either the `E[E]` or the `E[c]` term.

**2. A homological imputation-recoverability criterion: missing data on feature `j` is
uniquely recoverable iff a relative `H¹` vanishes.** Extend the constant sheaf to the
*feature-valued* sheaf whose stalk at record `i` is `k^{present i}` with restriction maps the
coordinate projections, and define recoverability of a missing entry `(i, j)` as the
existence and uniqueness of a global section extending the observed data. Conjecture: entry
`(i,j)` is uniquely recoverable iff the relative obstruction `H¹` of the pair (full sheaf,
sheaf with `(i,j)` deleted) is zero. *The key insight is* that imputation is a section-extension
problem, so its solvability is governed by a connecting map in a long exact sequence rather
than by any statistical smoothness assumption. *Why now?* `ker_dataDelta_eq_H0` already
identifies sections with kernels of an explicit linear map, so the long-exact-sequence
machinery can be bootstrapped from the coboundary `dataDelta` we have built, with the Euler
identity supplying every dimension count.

**3. Spectral surrogate: `dim H¹` equals the multiplicity-corrected nullity of the graph
Laplacian, making it computable without forming the quotient.** The coboundary `dataDelta`
has `dataDeltaᵀ ∘ dataDelta` equal to the unnormalized graph Laplacian `L` of the
co-observation graph; hence `dim H⁰ = dim ker L` and, by rank–nullity,
`dim H¹ = E − rank L = E − (V − dim ker L)`. Conjecture: this Laplacian identity holds verbatim
and gives an `O(V³)` (or iterative `O(E·k)`) algorithm for the missing-information dimension
that never builds the cokernel. *The key insight is* that the discrete Hodge Laplacian collapses
both Betti numbers into one symmetric PSD spectrum, so `dim H¹` is a pure nullity computation.
*Why now?* `Catalog/Speculative/AutoResearch/HodgeBettiRank.lean` already formalizes
`hodge_betti` for abstract two-step complexes; specializing it to `dataDelta` would connect
our combinatorial `finrank_dataH1_eq_firstBetti` to that operator-theoretic result and yield a
genuinely cross-file, cross-domain bridge.

**4. Monotonicity of missing information under feature acquisition is non-monotone — and the
sign of the jump is a testable cohomological law.** Adding an observed feature to a record can
only *add* couplings (edges), which by `finrank_dataH1_eq_firstBetti` changes
`dim H¹` by `+1` if the new edge closes a cycle (joins two already-connected records) and by
`0` if it merges two clusters (`#clusters` drops by 1 to compensate). Conjecture: observing one
more entry never decreases `dim H¹`, and decreases `dim H⁰` by exactly the number of clusters it
merges. *The key insight is* that more data can *increase* the obstruction `H¹`, contradicting
the naive intuition that information always reduces uncertainty. *Why now?* The exact Euler
formula lets us state the jump as a clean `±1`/`0` dichotomy that is directly falsifiable by
incrementally revealing entries of a synthetic dataset and recomputing the Betti numbers.

**5. Higher cohomology from the full nerve: `H²` detects "triple-incompatibility" of imputations
and predicts where MICE-style iterative imputers fail to converge.** Replace the 1-dimensional
co-observation graph by the full nerve of the cover `{records observing feature j}_j` and build
its simplicial cochain complex; `H²` then measures obstructions that no pairwise patching can see.
Conjecture: `H² ≠ 0` exactly on datasets where round-robin conditional imputers (MICE) cycle without
a fixed point, and `dim H²` lower-bounds the number of independent inconsistency cycles among
feature-conditional models. *The key insight is* that iterative imputation is a search for a global
section of a higher sheaf, so its non-convergence is a genuine degree-2 topological obstruction,
not a numerical artifact. *Why now?* Our degree-0/1 layer (`dataDelta`, `dataH1`) is the truncation
of exactly this complex, so the nerve and its `δ¹` can be appended with the same oriented-simplex
bookkeeping, and the existing Euler identity generalizes to the alternating-sum Euler characteristic.
