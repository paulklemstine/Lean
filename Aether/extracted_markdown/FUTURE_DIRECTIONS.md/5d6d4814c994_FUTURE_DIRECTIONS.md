# Future Directions: Multi-Cut Integrated Information of Tensor Networks

The file `Computation/IIT/TensorNetworkMultiCut.lean` synthesizes the catalog's
combinatorial IIT skeleton (`Applications/Consciousness/IntegratedInformation.lean`,
the Minimum-Information-Partition `Φ = min over bipartitions`) with the quantum/Schmidt
development (`Computation/IIT/TensorNetworkSchmidt.lean`, single-cut `phiBip = rank − 1`).
The result is a multi-cut integrated information `phiMC` taking the minimum of the
per-cut Schmidt-rank deficit over all nontrivial bipartitions, together with a
reducibility characterization (`Φ = 0` iff the state is a product across some cut), a
bond-dimension bound (`Φ ≤ D − 1`), and a tightness theorem realizing the bound by the
maximally entangled network. These leave several sharp, falsifiable continuations.

## 1. Schmidt rank from genuine coefficient matrices, not abstract `CutData`

The current `CutData` records the Schmidt rank across each cut as an abstract function.
The next step is to *derive* `rank A` from a single underlying amplitude tensor by
reshaping it across the cut `A` into a coefficient matrix `M_A`, with `rank A := M_A.rank`,
reusing `phiBip M_A` from the Schmidt file as the per-cut value. **The key insight is**
that the consistency constraint "all `M_A` arise from one global tensor" is exactly what
makes IIT's MIP nontrivial — the cuts are not independent, so the minimum is constrained by
the shared tensor. **Why now?** Mathlib already has `Matrix.rank`, `vecMulVec`, and
`rank_mul_le_left`, and the Schmidt file proves the single-cut anchors, so the reshaping
layer is the only missing piece and it is purely bookkeeping over `Fin` products.

## 2. Strict monotonicity and the entanglement order

`phiMC_mono` shows `Φ` is monotone in the Schmidt-rank data. Conjecture: if `S.rank ≤
T.rank` pointwise and the inequality is strict *at the MIP cut of `T`*, then `Φ S < Φ T`.
**The key insight is** that only the minimizing cut controls `Φ`, so strictness must be
located there rather than globally — a falsifiable refinement, since a counterexample is
any `S` that lowers a non-MIP cut while leaving the MIP cut fixed. **Why now?** The
`exists_MIP` realizer is already proved, giving direct access to the controlling cut, so
the strict version is a short `omega`/case argument away.

## 3. Subadditivity of `Φ` under tensoring of networks

Given two networks `S₁, S₂`, their independent composite has, across each cut, Schmidt
rank equal to the product of the per-component ranks. Conjecture:
`Φ(S₁ ⊗ S₂) + 1 ≤ (Φ S₁ + 1)(Φ S₂ + 1)`, i.e. integrated information is *submultiplicative*
in `rank` and the `+1` shift linearizes it. **The key insight is** that composing systems
multiplies Schmidt ranks per cut but the MIP of the composite may pick a *different* cut
than either factor's MIP, forcing an inequality rather than equality. **Why now?** With
`phiMC` defined over `Finset (Fin n)` cuts, the product network's cut lattice is the
product of the factor lattices, and `Finset.min'` interacts cleanly with products via
existing `Finset.min'_le` / `le_min'` lemmas.

## 4. From Schmidt rank to entanglement entropy and quantum mutual information

The original concept conjectures that `Φ` equals the *minimal quantum mutual information*
across any bipartition. For a bipartite pure state this mutual information is `2·S(ρ_A)`
(twice the entanglement entropy), and `S(ρ_A) ≤ log(Schmidt rank)`. Conjecture: the
real-valued `Φ_S := min over cuts of S(ρ_A)` satisfies `Φ_S ≤ log(phiMC + 1)`, with
equality for flat (maximally mixed) Schmidt spectra. **The key insight is** that the
discrete `phiMC` upper-bounds the continuous entropic `Φ` through the log-rank inequality,
making the rank version a certified, decidable surrogate for the entropic one. **Why now?**
Mathlib's `Real.log`, `Finset.sum`, and convexity API (`inner_le_nnorm`, Jensen) are
mature enough to state and bound the flat-spectrum case without building measure-theoretic
von Neumann entropy from scratch.

## 5. MPS bond profiles and the area law for `Φ`

For an open-boundary matrix product state on a chain, the bond dimension may *vary* by
position, giving a bond profile `D : position → ℕ`. Conjecture: `Φ` of the chain equals
`(min over cut positions of D) − 1`, i.e. integrated information is governed by the
*thinnest* bond — a discrete "area law" where the MIP is the narrowest waist of the
network. **The key insight is** that contiguous cuts of a 1D MPS factor through exactly one
bond, so the multi-cut minimum collapses to a minimum over bond positions, turning the
combinatorial MIP into a one-dimensional search. **Why now?** `phiMC_le_bond` already
proves the `≤` direction for a uniform bond; generalizing to a profile and proving the
matching lower bound via an explicit maximally entangled bond only needs the reshaping
layer of Direction 1.
