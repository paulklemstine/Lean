# Future Directions — Integrated Information via Tensor Networks

## Synthesis

This cold-start cycle established a rigorous, sorry-free algebraic skeleton connecting
Tononi's Integrated Information Theory (IIT) to quantum tensor networks. The key structural
move was to identify the IIT integrated-information functional `Φ` of a pure quantum state
with the **Schmidt rank** of its coefficient tensor across a cut, discretized as
`Φ = rank − 1`. Under this identification, the two poles of IIT become exact linear-algebra
facts: a *reducible* (product/separable) state has `Φ = 0` (`phi_productState_eq_zero`,
`phiMIP_eq_zero_of_product_cut`), and the *maximally entangled* state attains the maximal
`Φ = d − 1` (`phi_maximallyEntangled_eq`). In between, the matrix-product-state (MPS) bond
dimension `D` provides a sharp algebraic ceiling on integration, `Φ ≤ D − 1`
(`phi_mps_le_bond`), with the bond-dimension-2 case (`phi_mps_bondTwo_le_one`) realizing the
concept's explicit test: a bond-2 MPS can integrate at most one bit's worth of Schmidt
structure.

The cycle deliberately built on the catalog's existing graph-theoretic IIT in
`Shared.CausalIntegration.Core`, where `CausalSystem.phi` is the min-cut of a weighted
digraph over `nontrivialBipartitions`. We mirrored that minimum-over-bipartitions
architecture exactly in `phiMIP`, replacing the graph cross-cut weight with the quantum
Schmidt rank across the cut. This makes the two formalizations *structurally aligned*: both
take a minimum over the same indexing set, and both have a "decoupled cut ⟹ Φ = 0" theorem
(`phi_zero_of_disconnected` ↔ `phiMIP_eq_zero_of_product_cut`). The cross-domain bridge —
graph min-cut IIT ≅ tensor-network Schmidt-rank IIT — is the novel contribution.

What we could *not* close this cycle: the converse direction (`Φ = 0 ⟹ the state is a
product across some cut`), which requires the rank-one ⟹ outer-product structure theorem;
and the genuine quantum *mutual information* (von Neumann entropy) version, which Mathlib
does not yet support for density matrices. These define the natural next cycle. The deepest
open structural question is whether the discrete `Φ = rank − 1` is *monotone* under local
operations (LOCC), which would make it a bona fide entanglement measure rather than a mere
cut statistic.

## Results Summary

- `phi_productState_eq_zero`: proved — a separable bipartite state `|u⟩⊗|v⟩` has `Φ = 0`,
  the IIT reducibility axiom as an exact rank fact.
- `phi_mps_le_bond`: proved — an MPS through a bond of dimension `D` satisfies `Φ ≤ D − 1`;
  bond dimension is the algebraic throttle on integration.
- `phi_mps_bondTwo_le_one`: proved — the concept's explicit bond-2 test case, `Φ ≤ 1`.
- `phi_maximallyEntangled_eq`: proved — the maximally entangled `d⊗d` state attains the
  extremal `Φ = d − 1`, showing the bond bound is tight (needs `D = d`).
- `cutMatrix_rank_le_one_of_product`: proved — a tensor factorizing across a cut has Schmidt
  rank ≤ 1 across that cut (multipartite reshape ⟹ outer product).
- `phiMIP_eq_zero_of_product_cut`: proved — the multipartite minimum-information-partition
  `Φ = 0` whenever *any* nontrivial cut decouples the state (reducibility ⟹ zero `Φ`).
- `schmidtRankAt_le_block`: proved — Schmidt rank across a cut is bounded by the complement
  block dimension `d^|Sᶜ|`, a discrete entanglement area-law bound.

## Research Directions

### Direction 1: The converse — `Φ = 0` characterizes product states
**Hypothesis**: For a bipartite coefficient matrix `M`, `phiBip M = 0` (i.e. `rank M ≤ 1`)
if and only if `M = vecMulVec u v` for some `u, v`; equivalently, every cut with zero
integrated information exhibits an explicit product decomposition.
**Test**: Prove `rank M ≤ 1 ↔ ∃ u v, M = vecMulVec u v` in Lean, then upgrade
`phiMIP_eq_zero_of_product_cut` to an iff `phiMIP ψ = 0 ↔ ∃ cut, ψ factors`. The forward
direction needs a rank-one structure lemma (pick a nonzero row as `v`, read off `u` from
column ratios).
**Why now**: We already have the easy direction (`cutMatrix_rank_le_one_of_product`) and the
reshape machinery (`cutMatrix`, `Equiv.piEquivPiSubtypeProd`); only the structure theorem is
missing.
**If true**: `Φ` becomes a *complete* reducibility invariant — the central IIT dichotomy
fully formalized.
**If false** (in the multipartite case): would reveal genuinely multipartite entanglement
(GHZ/W-type) where no single cut decouples yet pairwise structure is degenerate — exactly
the regime where IIT's "irreducibility" is nontrivial.

### Direction 2: Mutual-information (von Neumann) version of `Φ`
**Hypothesis**: Define `Φ_S(ψ)` as the von Neumann entropy of the reduced density matrix
across cut `S`. Then for the bond-`D` MPS, `Φ_S ≤ log D`, and `Φ_S = 0 ↔ Schmidt rank = 1`,
matching the rank-based `phiBip` exactly at its zero set.
**Test**: Build the reduced density matrix `M Mᴴ` and its eigenvalue entropy in Mathlib;
prove the `log D` ceiling from the rank bound `schmidtRankAt_le_block` plus concavity.
**Why now**: The Schmidt rank we already compute is exactly the *number of nonzero* Schmidt
coefficients, so the entropy is supported on `≤ rank` values — the rank bounds we proved
become entropy bounds for free via `log(rank)`.
**If true**: Connects the discrete combinatorial `Φ` to the standard continuous information
measure, validating the rank discretization.
**If false**: Pinpoints where rank and entropy diverge (degenerate vs. flat spectra),
clarifying which IIT statements are spectral and which are merely rank-theoretic.

### Direction 3: Sub/super-additivity of `Φ` across nested cuts
**Hypothesis**: For nested site sets `S ⊆ T`, the Schmidt ranks satisfy a submultiplicative
law `schmidtRankAt T ψ ≤ schmidtRankAt S ψ · (local factor)`, yielding monotonicity of the
MIP value under coarsening of partitions.
**Test**: Express the reshape across `T` as a product of the reshape across `S` with a block
map, then apply `rank_mul_le`. Prove `phiMIP` is monotone under refinement of the
bipartition lattice.
**Why now**: `rank_mul_le_left/right` is the workhorse that already gave us
`phi_mps_le_bond`; the same submultiplicativity should govern cut composition, and the
`biparts` lattice is already defined.
**If true**: Establishes that the minimum-information partition is achieved on a *coarsest*
nontrivial cut — a structural shortcut for computing `Φ`.
**If false**: Demonstrates genuine multipartite frustration where the MIP is an interior
partition, the most interesting IIT phenomenon.

### Direction 4: LOCC-monotonicity — is `Φ` an entanglement measure?
**Hypothesis**: `phiBip` is non-increasing under local operations, i.e. for any matrices
`L, R` (local channels on each party), `phiBip (L * M * R) ≤ phiBip M`.
**Test**: This is exactly `rank (L*M*R) ≤ rank M`, provable from `rank_mul_le_left` and
`rank_mul_le_right` chained; then interpret as the IIT axiom that integration cannot be
created by acting on parts in isolation.
**Why now**: The proof reduces to two applications of rank submultiplicativity we have
already used; it is essentially immediate and would be a high-value, low-cost result.
**If true**: Elevates `Φ` from a cut statistic to a certified entanglement monotone — the
single most important property linking IIT to quantum information.
**If false**: Would be a fundamental inconsistency (rank only ever drops under
multiplication), so a *failure here would indicate a modeling error*, making this a crucial
sanity check on the whole framework.

### Direction 5: Tightness of the bond bound and an MPS realization theorem
**Hypothesis**: The bound `phi_mps_le_bond` is tight at every value: for each `D` there is a
bond-`D` MPS whose Schmidt rank across the central cut is exactly `D`, so `Φ = D − 1` is
realized (not just bounded).
**Test**: Take `A = B = (1 : Matrix (Fin D) (Fin D))` so `A * B = 1` and apply
`phi_maximallyEntangled_eq`; then generalize to non-square MPS tensors and prove a "generic
MPS saturates its bond" statement.
**Why now**: We already proved both halves separately (`phi_mps_le_bond` for the upper bound,
`phi_maximallyEntangled_eq` for saturation at `M = 1`); fusing them is a short step.
**If true**: Confirms bond dimension is the *exact* resource for integrated information in
MPS, the quantitative core of the original concept.
**If false**: Would expose hidden rank collapse in MPS contraction, revealing that bond
dimension overcounts integration — a surprising and publishable negative result.
