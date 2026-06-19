# Research Direction: Local Proof Complexity via the Depth Spectrum of Dependency Graphs

**Status of this document.** The central theorem proposed below is *not a conjecture*: it is
formalized and machine-checked in
[`Catalog/Speculative/ProofDepthSpectrum.lean`](Catalog/Speculative/ProofDepthSpectrum.lean)
(axioms: `propext`, `Classical.choice`, `Quot.sound`; no `sorry`). The document states the
direction, gives the precise mathematical statements that are now verified, situates them in
the catalog, and lays out a forward-looking research program building on them.

---

## 1. Motivation: three catalog strands, one object

The catalog already contains three independently developed threads:

| Strand | Representative catalog file | Object of study |
|---|---|---|
| **Dependency graphs** | `Logic/IncrementalRecompute.lean` | finite DAGs with a predecessor function `pred : V → Finset V` and a *level* (longest-path depth) assignment; an incremental kernel that recomputes only inside an edited *cone* |
| **Proof complexity** | `Algebra/ProofSpectra/Core.lean` | graded invariants of derivation objects ("proof spectra"), tower-type growth functions |
| **Computational abstraction** | `Logic/IncrementalRecompute.lean`, `Computation/*` | *local rewrites*: a computation/proof is edited in one place and the effect must be re-derived |

The research direction is to **unify these into a single invariant — the *proof-depth
spectrum* of a dependency graph — and to prove that this invariant is *local*: its response
to an edit is controlled by the size of the edited cone, not the size of the whole graph.**

Intuitively: in a large body of formalized mathematics (such as this catalog itself, viewed
as a DAG of declarations), the *profile of proof depths* is a stable, conserved measure of
proof complexity, and editing one lemma perturbs that profile only by a bounded amount.

---

## 2. The objects (all formalized)

Fix a finite type `V` of vertices (declarations / proof nodes).

* **Dependency graph.** A predecessor function `pred : V → Finset V`. `u ∈ pred v` means
  "`v` depends on `u`".
* **Depth assignment.** `levels : V → ℕ` is *correct* for `pred` when
  ```
  LevelsCorrect pred levels  :≡  ∀ v, levels v = 1 + (pred v).sup levels.
  ```
  Sources get depth `1`; in general `levels v` is one more than the longest dependency
  chain into `v`. (Existence of such a `levels` is exactly acyclicity.)
* **Proof-depth spectrum.** The proof-complexity profile
  ```
  depthSpectrum levels d  :≡  #{ v | levels v = d },
  ```
  i.e. how many derivations have depth `d`. This is the combinatorial shadow of the
  "proof spectra" of `Algebra/ProofSpectra/Core.lean`.
* **Edit / abstraction.** Two assignments `old, new : V → ℕ` and the *changed set*
  `changed old new = { v | old v ≠ new v }`. In the incremental model `new` is the depth
  assignment after an edit and `changed old new` is contained in the edited cone.

---

## 3. Verified theorems

All statements below are theorems in `ProofDepthSpectrum.lean`.

**T1 — Depth is a well-defined invariant (`levelsCorrect_unique`).**
For a fixed dependency graph, the depth assignment is unique:
```
LevelsCorrect pred l₁ → LevelsCorrect pred l₂ → l₁ = l₂.
```
*Consequence:* the depth spectrum depends only on the graph, not on how depth was computed —
it is a genuine invariant.

**T2 — Conservation of mass (`sum_depthSpectrum_eq_card`).**
If every depth lies in a finite index set `T`, then
```
∑ d ∈ T, depthSpectrum levels d = Fintype.card V.
```
The spectrum is a probability-like profile: it redistributes `|V|` units of mass over depths.

**T3 — Pointwise stability (`depthSpectrum_dist_le`).**
For every depth `d`,
```
Nat.dist (depthSpectrum new d) (depthSpectrum old d) ≤ #(changed old new).
```

**T4 — Total-variation (ℓ¹) stability (`depthSpectrum_total_variation_le`).**
For any finite set of depths `T`,
```
∑ d ∈ T, Nat.dist (depthSpectrum new d) (depthSpectrum old d) ≤ 2 · #(changed old new).
```
The whole profile moves by total variation at most twice the number of changed vertices.

**T5 — Flagship: proof complexity is local (`spectrum_stable_under_local_edit`).**
If the edit changes depth only inside a cone `C` (`∀ v, old v ≠ new v → v ∈ C`), then
```
∑ d ∈ T, Nat.dist (depthSpectrum new d) (depthSpectrum old d) ≤ 2 · #C.
```
The right-hand side has **no dependence on `|V|`**: the proof-complexity profile is
`2`-Lipschitz in the cone size, uniformly in the ambient graph.

### Logical structure

```
        (Mathlib fiberwise counting)            (Finset sdiff / biUnion)
                    │                                      │
                    ▼                                      ▼
   T2 sum_depthSpectrum_eq_card        T3 depthSpectrum_dist_le ─┐
                                       (helper) sum_card_filter_sdiff_le
                                                                 │
   T1 levelsCorrect_unique  ──(invariance)──►   T4 total_variation_le ◄┘
   (strong induction on depth)                          │
                                                        ▼
                                       T5 spectrum_stable_under_local_edit
                                       (changed ⊆ cone  ⇒  #changed ≤ #C)
```

The bridge to the catalog's incremental kernel is the hypothesis of T5: the catalog's
`incrementalRecompute_eq_old_outside_cone` (in `Logic/IncrementalRecompute.lean`) is exactly
a proof that `old` and `new` agree outside the cone, i.e. it *discharges* the hypothesis
`hloc` of T5. Composing the two gives an end-to-end statement: *recomputing depths after a
local edit changes the proof-complexity profile by total variation ≤ 2·|cone|.*

---

## 4. Why this is the right abstraction

* **It is an invariant, not an artifact** (T1): unlike "proof size as written", depth is
  forced by the dependency structure.
* **It is conserved** (T2): the spectrum is a genuine distribution over a finite budget `|V|`.
* **It is local** (T5): the response to abstraction/edits is controlled by the cone, matching
  the incremental-computation philosophy of the catalog.
* It interpolates the three strands literally: dependency graph (`pred`, `levels`),
  proof complexity (`depthSpectrum`), computational abstraction (`changed`/cone edits).

---

## 5. Forward-looking research plan

**Phase A — Sharpen and enrich the invariant (near term).**
1. *Sharp constant.* Prove `2·#C` is tight (exhibit an edit moving exactly `2·#C` mass) and
   characterize equality. Conjecture: equality iff the cone's vertices all change depth and no
   two of them land in the same source/target depth class.
2. *Higher moments.* Replace counting by weighted spectra `∑_v w(levels v)` for monotone `w`
   (e.g. `towerExp` from `ProofSpectra/Core.lean`) and prove a weighted Lipschitz bound; this
   connects the depth spectrum to the catalog's tower-growth proof-complexity measures.
3. *Spectral entropy.* Define `H = −∑_d p_d log p_d` with `p_d = depthSpectrum/|V|` (T2 makes
   this a distribution) and bound `|H(new) − H(old)|` by a modulus of T4 — a continuity
   statement for "proof-complexity entropy" under edits.

**Phase B — Compose with the catalog's verified kernels (near/medium term).**
4. Formally chain T5 with `incrementalRecompute_eq_old_outside_cone` and
   `incrementalWork_le` to obtain a single theorem: *work and spectrum-perturbation are both
   bounded by cone size*, giving a verified cost/effect bound for incremental re-derivation.
5. Instantiate `V` as the catalog's own declaration DAG and compute the depth spectrum as a
   concrete, checkable profile of this corpus; track its total-variation drift as files are
   added (an empirically meaningful "complexity stability" metric for a proof library).

**Phase C — Toward complexity-theoretic statements (longer term).**
6. *Lower bounds.* Combine the locality of the spectrum with the barrier material in
   `Logic/CircuitComplexityBarriers.lean` / `Logic/PvsNPFoundations.lean`: a family of edits
   forced to move `Ω(|V|)` spectral mass must touch cones of size `Ω(|V|)`, yielding
   unconditional lower bounds on incremental re-derivation for explicit graph families.
7. *Algorithm.* Package T1–T5 as a verified streaming algorithm that maintains the depth
   spectrum of a growing dependency DAG in amortized `O(#cone)` updates with a certified
   error/conservation guarantee, generalizing `IncrementalRecompute` from a single vertex
   level to the whole spectrum.
8. *Categorical abstraction.* Recast `depthSpectrum` as a functor from the poset of dependency
   graphs (under cone-local edits) to distributions, with T4/T5 as a Lipschitz/`enriched`
   functoriality statement, linking to the bridge files (`Bridges/*`) that already treat
   computation categorically.

---

## 6. Deliverable in this repository

* `Catalog/Speculative/ProofDepthSpectrum.lean` — self-contained, `import Mathlib`,
  no `sorry`, six theorems (T1–T5 plus the disjointness helper), kernel-only axioms.
  It is the verified nucleus from which the program above proceeds.
