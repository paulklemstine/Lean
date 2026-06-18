# Future Directions: Clique Complexes, the One-Skeleton Adjunction, and Vietoris–Rips Filtrations

## Synthesis

This cycle extended the from-scratch clique-complex theory in
`Catalog/Geometry/CliqueComplexFlag.lean` along two complementary axes and tied them
together through a single order-theoretic backbone.

The first axis is **order theory**. The existing file proved `oneSkeleton (cliqueComplex G) = G`
(`oneSkeleton_cliqueComplex`) and the conditional reconstruction `flag_eq_cliqueComplex`. We
recognized these as the two halves of a *Galois connection* between the poset of simple graphs
(ordered by `≤`) and the poset of abstract simplicial complexes (ordered by face inclusion).
`Catalog/Geometry/CliqueComplexGalois.lean` makes this precise: both functors are monotone
(`cliqueComplex_mono`, `oneSkeleton_mono`); there is an unconditional unit `K ⊆ Δ(sk K)`
(`le_cliqueComplex_oneSkeleton`) that needs *only* downward closure; the composite `Δ ∘ sk` is a
closure operator (`cliqueComplex_oneSkeleton_idem`); and on flag complexes with all singletons the
adjunction `Δ G ⊆ K ↔ G ≤ sk K` (`cliqueComplex_galois`) holds in full.

The second axis is **filtrations and duality**. `Catalog/Geometry/CliqueComplexVietorisRips.lean`
pins down the two extremes of the Vietoris–Rips filtration `ε ↦ vietorisRips d ε`: above the
diameter it is the full simplex (`vietorisRips_full_of_bounded`), and below the minimum separation
it is discrete (`vietorisRips_discrete_of_separated`). Combined with the catalog's `vietorisRips_mono`,
the filtration's qualitative shape is now completely understood. The same file observes that the
clique construction is self-dual under graph complementation: the independence complex is
`cliqueComplex Gᶜ` (`mem_independenceComplex`, `independenceComplex_eq_cliqueComplex`), and flagness
transfers for free (`independenceComplex_isFlag`).

## Results Summary

- `cliqueComplex_mono`, `oneSkeleton_mono` — both functors are monotone.
- `le_cliqueComplex_oneSkeleton` — the unit `K ⊆ Δ(sk K)`, with no hypotheses beyond downward closure.
- `cliqueComplex_oneSkeleton_idem` — `Δ(sk(Δ G)) = Δ G`, the closure law.
- `cliqueComplex_galois` — the Galois adjunction `Δ G ⊆ K ↔ G ≤ sk K` for flag complexes with all singletons.
- `vietorisRips_full_of_bounded` — bounded dissimilarity ⇒ full simplex.
- `vietorisRips_discrete_of_separated` — strict separation ⇒ faces are exactly the `≤ 1`-element sets.
- `mem_independenceComplex`, `independenceComplex_eq_cliqueComplex`, `independenceComplex_isFlag`
  — the complement duality and inherited flagness.

All theorems are `sorry`-free and depend only on the standard axioms `propext`,
`Classical.choice`, and `Quot.sound`.

## Research Directions

### 1. The closure operator on graphs is a flag-closure, and its fixed points are exactly the flag complexes.

We proved `Δ ∘ sk` is idempotent on complexes of the form `Δ G`. The natural completion is to
show that, restricted to complexes containing all singletons, the fixed points of the closure
operator `c = Δ ∘ sk` are *precisely* the flag complexes, i.e. `c K = K ↔ IsFlag K` (under the
singleton hypothesis). The key insight is that `flag_eq_cliqueComplex` already gives the `⇐`
direction, while `le_cliqueComplex_oneSkeleton` gives one containment of `⇒` for free, so only the
reverse containment of the fixed-point equation remains and it is governed entirely by the flag axiom.
Why now? The Galois connection is in place and the closure operator is proven idempotent, so the
fixed-point characterization is the immediate, falsifiable next theorem — and it would upgrade the
adjunction to a genuine *Galois insertion* onto the flag complexes.

### 2. The Vietoris–Rips filtration changes only at finitely many critical scales.

For a finite vertex type with a dissimilarity `d`, the filtration `ε ↦ vietorisRips d ε` is monotone,
full above `diam = max d`, and discrete below `sep = min_{u≠v} d`. The conjecture is that the
filtration changes value only at finitely many *critical scales*, all of which lie in the finite set
`{ d u v : u v }`, and is constant on each open interval between consecutive critical values. The key
insight is that face membership is decided by a finite conjunction of inequalities `d u v ≤ ε`, so the
complex can only change when `ε` crosses one of the finitely many values `d u v`. Why now? We already
have the two endpoints (`vietorisRips_full_of_bounded`, `vietorisRips_discrete_of_separated`) and
monotonicity; bounding the critical set is the natural quantitative refinement and is fully computable
(`decide`/`#eval` on concrete finite `d`).

### 3. Complementation is an order-reversing involution intertwining clique and independence complexes.

`independenceComplex_eq_cliqueComplex` identifies `independenceComplex G = cliqueComplex Gᶜ`. The next
step is to make complementation a first-class duality: `independenceComplex (Gᶜ) = cliqueComplex G`,
`oneSkeleton (independenceComplex G) = Gᶜ`, and an order-*reversing* analogue of the Galois connection
(`G ≤ H ↔ independenceComplex H ⊆ independenceComplex G`). The key insight is that `Gᶜᶜ = G`
(`compl_compl`) turns every clique-complex theorem into a dual independence-complex theorem by a single
substitution, so an entire dual library can be generated mechanically rather than re-proved. Why now?
The duality bridge is established and flagness already transfers; formalizing the involution converts
that one bridge into a free functorial dictionary.

### 4. A sharp Turán-type equality criterion for the f-vector of a clique complex.

The catalog proves `f_k(Δ(G)) ≤ C(n, k+1)` (`cliqueComplex_fVector_le_choose`). The conjecture is the
equality case: `f_k(Δ(G)) = C(n,k+1)` for some `k ≥ 1` iff `G` is complete (equivalently, iff equality
holds for all `k`). The key insight is that a size-`(k+1)` clique forces all its `C(k+1,2)` edges, so
saturating the binomial bound at any single positive dimension already forces every edge to be present.
Why now? The `f`-vector and the upper bound are already in the catalog, and the monotonicity lemma
`cliqueComplex_mono` proved this cycle gives exactly the tool needed to compare `Δ(G)` with the
complete-graph complex, making the equality criterion a tractable and decisive sharpening.

### 5. The clique complex preserves graph joins as simplicial joins.

For graphs `G` on `V` and `H` on `W`, the join `G ⋆ H` (disjoint union plus all cross edges) should
satisfy `cliqueComplex (G ⋆ H) = (cliqueComplex G) ⋆ (cliqueComplex H)` as abstract simplicial
complexes, where the simplicial join takes unions of a face from each side. The key insight is that a
set is a clique in the graph join iff its two projections are cliques *and* every cross-pair is an edge
— which is automatic in `G ⋆ H` — so cliqueness factors exactly through the two factors. Why now? The
structural pivot `isClique_pair` and the monotonicity machinery from this cycle are precisely what a
join-decomposition proof needs, and a join theorem is the standard gateway to inductive computations of
homotopy type and connectivity of clique complexes.
