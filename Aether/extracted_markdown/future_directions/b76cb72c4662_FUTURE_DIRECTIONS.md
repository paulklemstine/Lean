# Future Directions — Integrated Information via Tensor Networks

This research cycle established the dictionary

> **IIT min-cut Φ  ≡  tensor-network min-cut entanglement capacity**
> (under `weight = log(bond dimension)`),

and proved two structural laws of the cut functional: **submodularity**
(`crossInfo_submodular`) and **superadditivity under superposition**
(`phi_superadditive`). The conjectures below are the falsifiable targets for the
next cycles, ordered roughly by ambition.

## C1. Holographic Strong Subadditivity (min lifts submodularity)

Cycle 1 proved the *cut function* `S ↦ crossInfo S` is submodular. Define the
**holographic entropy** of a region `A ⊆ Fin n` as the minimum cut separating
`A` from `Aᶜ`, `Sₕₒₗ(A) = min { crossInfo S : A ⊆ S, S nontrivial }`.

> **Conjecture C1.** `A ↦ Sₕₒₗ(A)` is itself submodular; equivalently, for
> disjoint regions `A,B,C`:
> `Sₕₒₗ(A∪B) + Sₕₒₗ(B∪C) ≥ Sₕₒₗ(A∪B∪C) + Sₕₒₗ(B)`.

This is the discrete Ryu–Takayanagi strong-subadditivity statement. Test: prove
the cut-and-paste inequality `crossInfo(S∩T) + crossInfo(S∪T) ≤ crossInfo S +
crossInfo T` (already have it) and combine with optimality of the minimizing
cuts. Falsifiable by a small explicit weighted graph if it fails.

## C2. Max-flow / min-cut tightness (area-law saturation)

We proved the one-sided bound `entanglementCapacity ≤ logCut S` for every cut.

> **Conjecture C2.** For every symmetric tensor network there is an explicit
> "flow" certificate whose value equals `entanglementCapacity`, so the min-cut
> bound is *tight*: `entanglementCapacity = max over admissible flows`.

This is a weighted directed max-flow=min-cut theorem specialized to the IIT cut
functional. Test: formalize an admissible-flow structure and prove weak duality
(`flow ≤ phi`) then strong duality on `Fin n`.

## C3. Coarse-graining monotonicity (RG step)

> **Conjecture C3.** Contracting an internal edge (merging two nodes `i,j` and
> summing their weights) does not increase Φ: `Φ(C / {i∼j}) ≤ Φ(C)`.

If true, Φ is an RG-monotone — a "c-theorem" for integrated information. Test:
define node-merge on `CausalSystem`, relate its bipartitions to the original's,
and bound the cut functional. Falsifiable: search small systems for a merge that
raises Φ.

## C4. Spectral lower bound (Fiedler/Cheeger for Φ)

> **Conjecture C4.** For the symmetrized system `symmetrize C` there is a
> Cheeger-type bound `Φ ≥ c · λ₂(L_C) · (min part size)` where `λ₂` is the
> algebraic connectivity of the weighted graph Laplacian `L_C`.

This would connect IIT directly to spectral graph theory and give a *computable*
certificate of high integration from an eigenvalue. Test: prove the easy
direction (Φ controls a conductance) first, then the spectral inequality.

## C5. Exact superadditivity gap

Cycle 2 proved `Φ(C₁ ⊕ C₂) ≥ Φ(C₁) + Φ(C₂)` and showed equality fails in
general.

> **Conjecture C5.** Equality `Φ(C₁ ⊕ C₂) = Φ(C₁) + Φ(C₂)` holds **iff** `C₁`
> and `C₂` admit a common minimizing bipartition.

Test: the `←` direction is immediate from `crossInfo_add`; the `→` direction
needs that the superposed minimizer simultaneously minimizes both summands.
Falsifiable by exhibiting a common-minimizer pair with strict inequality.
