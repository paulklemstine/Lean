# Future Directions — One-Way Functions: Existence and Hierarchy

## Synthesis

The cycle's central discovery is conceptual rather than computational: **one-wayness
is never an information-theoretic property**. Over any nonempty domain the canonical
inverse `Function.invFun f` is already a *weak inverse* (`invFun_weakInverse`), so an
adversary with unbounded resources always wins the inversion game
(`not_infoTheoreticOneWay`). What remains genuinely scarce is *exact* inversion: over a
finite domain no inverter can pin down more than `|Im f|` inputs
(`exact_inversions_le_image`), and that capacity is exactly met by `invFun f`
(`invFun_exact_inversions`). The image size `|Im f|` therefore emerges as the precise
information-theoretic capacity of inversion, the bridge between the collision/fiber
analysis of `Cryptography.HardnessHierarchy` (`fiber`, `large_fiber_exists`,
`LossyFunction`) and the one-wayness layer. Finally, the qualitative hierarchy
`OWF → PRG → PRF → ENC` was upgraded from the mere antisymmetry of `hierarchy_strict`
to a genuine total order with extremal elements (`level_total`, `owf_weakest`,
`enc_strongest`): the cryptographic hierarchy is order-isomorphic to `Fin 4`.

## Results Summary

| Theorem | Statement | Axioms |
|---|---|---|
| `exists_weakInverse` | every `f` over nonempty `α` has a weak inverse | standard |
| `not_infoTheoreticOneWay` | no `f` is information-theoretically one-way | standard |
| `weakInverse_inverts_all` | a weak inverter succeeds on all `\|α\|` inputs | standard |
| `exact_inversions_le_image` | any inverter exactly recovers `≤ \|Im f\|` inputs | standard |
| `invFun_exact_inversions` | `invFun f` attains the optimum `\|Im f\|` | standard |
| `rank_injective`, `level_total`, `owf_weakest`, `enc_strongest` | hierarchy is a total order with extrema | none / standard |

All main results compile with `sorry = 0` and depend only on `propext`,
`Classical.choice`, `Quot.sound` (the order results use no axioms at all).

## Research Directions

### 1. Exact-inversion capacity equals domain size minus collision deficit

Sharpen `exact_inversions_le_image` to an exact identity for *the* optimal inverter:
the maximal exact-inversion count over all `g` equals `|Im f| = |α| − (collision
deficit)`, where the deficit is `∑_{y} (|fiber y| − 1)` over the image. The key
insight is that `invFun_exact_inversions` already names the optimum `|Im f|`, so the
only missing piece is the algebraic identity `|α| = ∑_{y ∈ Im f} |fiber f y|`, which is
exactly `fiber_sum_eq_card` from `HardnessHierarchy`; combining them turns the
inversion optimum into a *collision invariant*. Why now? Both halves —
`invFun_exact_inversions` (this cycle) and `fiber_sum_eq_card` (catalog) — are already
formalized, so the bridge is a short, falsifiable composition rather than new theory.

### 2. Information-theoretic impossibility is monotone along the hierarchy

Conjecture: the impossibility of information-theoretic security propagates *upward*
through the order `OWF → PRG → PRF → ENC`. Concretely, model each level by a finite
function family and show that `not_infoTheoreticOneWay` at the OWF level forces an
unbounded-adversary break at every higher level, with the security loss bounded by the
`SecurityProfile.totalDegradation` of the connecting reductions. The key insight is
that `level_total` makes the hierarchy a chain, so a single base-level impossibility,
transported by the already-proven `reduction_compose_loss`, suffices to settle all
higher levels simultaneously. Why now? `level_total`/`enc_strongest` (this cycle) give
the chain structure and `SecurityProfile`/`reduction_compose_loss` (catalog) give the
loss bookkeeping — the components for a uniform impossibility transport now coexist.

### 3. A weak inverse exists with image a transversal of minimum size

Conjecture: among all weak inverses `g` of a finite `f`, the minimum of `|Im g|`
(the inverter's own table size) equals `|Im f|`, and `invFun f` realizes it. The key
insight is that a weak inverse only needs to name one preimage per fiber, so its
essential range is a transversal of the fiber partition, and `invFun_exact_inversions`
already exhibits `invFun f`'s fixed-point set as a size-`|Im f|` transversal. Why now?
The transversal bijection `Im f ≃ {x | invFun f (f x) = x}` was constructed this cycle;
re-reading it as a statement about `|Im g|` is a direct, testable refinement.

### 4. Quantitative one-wayness as a metric on the hierarchy chain

Define a real-valued hardness functional `H(f) = 1 − |Im f|/|α|` (the exact-inversion
*failure* fraction) and conjecture it is a monotone invariant: lossier functions
(smaller image) are strictly harder to invert exactly, and `H` is sub-additive under
the GGM-style composition `GGMTree`. The key insight is that `exact_inversions_le_image`
shows `|Im f|/|α|` is precisely the best achievable exact-inversion rate, so `H` is not
an ad-hoc metric but the operational success gap. Why now? With `invFun_exact_inversions`
pinning the optimum exactly, `H` becomes a *provable* quantity rather than a heuristic,
making monotonicity and sub-additivity sharply falsifiable.

### 5. Order-isomorphism `CryptoLevel ≃o Fin 4` and lattice completeness

Conjecture: the hardness hierarchy is not merely a total order but a *complete lattice*
order-isomorphic to `Fin 4`, with `OWF`/`ENC` as `⊥`/`⊤` in the "strength" order and
meets/joins given by `min`/`max` of ranks. The key insight is that `rank_injective`
plus `level_total` already certify a linear order on four elements, and every finite
linear order is automatically a complete lattice. Why now? `rank_injective` and
`level_total` (this cycle) furnish exactly the injectivity and totality needed to invoke
Mathlib's `LinearOrder`/`Fintype` lattice machinery, so the upgrade is mechanical and
immediately testable against a candidate `OrderIso`.
