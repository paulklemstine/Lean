# Future Directions — Valuation ↔ Vietoris–Rips bridge

Foundational results established in `Catalog/Bridges/ValuationRipsBridge.lean`:
in an ultrametric (non-Archimedean valuation) space the Vietoris–Rips proximity
relation is, for every scale `r ≥ 0`, an equivalence relation; Rips paths
collapse to Rips edges (`rips_chain_closed`); connected components are full
simplices (`class_isRipsSimplex`, `ball_isRipsSimplex`); the filtration is
monotone (`ripsRel_mono`, `IsRipsSimplex.mono`); and triangles are isosceles
(`ultrametric_isosceles`). The following conjectures extend this line.

## C1. Vanishing of higher Rips homology (ultrametric ⇒ degree-0 persistence)
For a finite ultrametric space `X` and any `r ≥ 0`, the geometric realization of
`Rips_r(X)` is homotopy equivalent to the discrete set of clusters
`X / ripsSetoid r`. Consequently every reduced simplicial homology group
`H̃_k(Rips_r(X))` vanishes for `k ≥ 1`, and persistent homology is concentrated
in degree 0. *Testable handle:* prove each connected component is a simplex (done
combinatorially) and that a simplex is contractible; then assemble per-component.

## C2. Dendrogram functoriality of the cluster map
The assignment `r ↦ (X / ripsSetoid r)` is a functor from `(ℝ≥0, ≤)` to `Set`
with surjective merge maps `π_{r,r'} : X/∼_r → X/∼_{r'}` for `r ≤ r'`, satisfying
`π_{r',r''} ∘ π_{r,r'} = π_{r,r''}`. Conjecture: this functor is a complete
invariant of the ultrametric — two finite ultrametric spaces are isometric iff
their cluster functors are naturally isomorphic. This formalizes the
ultrametric ↔ dendrogram correspondence of Carlsson–Mémoli.

## C3. Single-linkage recovers the valuation
Given an arbitrary finite metric space `(X, d)`, the single-linkage (maximal
sub-dominant) ultrametric `u(x,y) = min over paths of max edge` satisfies
`u ≤ d`, is ultrametric, and equals `d` exactly when `d` is already ultrametric.
Conjecture (and target): `rips_chain_closed` characterizes ultrametricity —
`d` is ultrametric iff `ReflTransGen (ripsRel r) = ripsRel r` for all `r ≥ 0`.

## C4. Stability / Lipschitz robustness of ultrametric clustering
For ultrametric `X`, the cluster partition is locally constant in `r` away from
the finite set of realized distances, and an additive perturbation of the metric
by `ε` (still ultrametric) changes cluster boundaries by at most `ε` in the
bottleneck sense. This is the ML-relevant robustness statement: hierarchical
clustering on valuation data is stable, with an explicit modulus.

## C5. Nerve/Čech agreement and exact reconstruction
For ultrametric `X`, the Vietoris–Rips complex and the Čech complex of closed
`r`-balls coincide (both are the disjoint union of cluster simplices), so the
Nerve Lemma holds on the nose without a "good cover" hypothesis. Conjecture:
this self-agreement characterizes ultrametricity among metric spaces and yields
exact reconstruction of `X` from its Rips filtration up to isometry (cf. C2).
