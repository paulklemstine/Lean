# Future Directions: A Tropical Growth-Rank Valuation on the Simulation Preorder

## Synthesis

This cycle built a genuine cross-domain bridge between two previously separate strands of
the catalog:

* the **order-theoretic core of the Cook–Reckhow program** —
  `Catalog/Logic/ProofComplexity/SimulationPreorder.lean` (the p-simulation preorder
  `Simulates`, the blow-up class `PolyBounded`/`PolyMono`, `polyBounded_comp`,
  `polyMono_comp`), `Catalog/Logic/ProofComplexity/SimulationDegrees.lean`
  (`polyBounded_of_le`, the degrees), and
  `Catalog/Logic/ProofComplexity/DegreeLattice.lean` (the meet `sumSystem`, `polyMono_max`,
  `isGLB_sumSystem`, `simulates_sumSystem_of_simulates_both`); and
* the **target category of tropical valuation objects** —
  `Catalog/Bridges/CategoricalTropicalUltrametric.lean`
  (`TropicalValuationObject`).

The new file `Catalog/Bridges/ProofComplexityTropicalDegree.lean` introduces a numerical
invariant `growthRank` on polynomial blow-ups (and its lift `simRank` to whole simulations)
and proves it is a **tropical valuation**:

* `growthRank_id` / `simRank_self`: identity has rank `0` (the tropical multiplicative unit);
* `growthRank_comp` / `simRank_comp`: composition is subadditive
  (`rank (g ∘ f) ≤ rank f + rank g`) — tropical multiplication;
* `growthRank_max` / `simRank_sumSystem`: the pointwise maximum, and the lattice meet
  `sumSystem`, realise tropical addition (`max`);
* `growthRank_mono`: monotonicity under pointwise domination.

These laws are assembled into a concrete `degreeTropObject : TropicalValuationObject
(WithBot ℕ)` — the standard tropical semiring `(WithBot ℕ, max, +)` — together with the
homomorphism statements `simDegree_self`, `simDegree_comp_le`, `simDegree_sumSystem`.

The decisive technical idea was **logarithmic re-encoding of the polynomial degree**.
Polynomial degree is multiplicative under composition (`deg (g∘f) = deg g · deg f`), so the
catalog's raw exponent `k` cannot be a tropical (additive) valuation. Bounding instead by
`(n+2)^(2^k)` makes the degree `2^k`, so its logarithm `k` adds under composition:
`2^a · 2^b = 2^(a+b)`. Shifting the additive fudge from `+1` to `+2` removed the
off-by-one in the composition estimate, yielding an *exact* subadditive law.

## Results Summary

| Theorem | Statement | Tropical reading |
|---|---|---|
| `growthRank_id` | `growthRank id = 0` | unit `↦` `1` |
| `growthRank_comp` | `growthRank (f∘g) ≤ growthRank f + growthRank g` | composition `↦` `⊗` |
| `growthRank_max` | `growthRank (max f g) = max (..) (..)` | choice `↦` `⊕` |
| `growthRank_mono` | domination `⇒` `≤` | functoriality of order |
| `simRank_self` | `simRank P P = 0` | identity simulation |
| `simRank_comp` | subadditive over `Simulates`-triangles | functor on morphisms |
| `simRank_sumSystem` | `simRank R (sumSystem P Q) = max (..) (..)` | meet `↦` `⊕` |
| `simDegree_*` | homomorphism into `degreeTropObject` | the valuation functor |

All main results compile with `sorry = 0` and depend only on
`propext, Classical.choice, Quot.sound`.

## Research Directions

### 1. Descend `simRank` to a hemimetric / pseudo-ultrametric on p-degrees.

`simRank P Q` is currently defined on raw proof systems. The pair
`d(P, Q) := max (simRank P Q) (simRank Q P)` should be a genuine **pseudo-ultrametric** on
the poset of p-degrees `Antisymmetrization (ProofSystem Thm) (·≤·)`: symmetric by
construction, zero on p-equivalent systems (`simRank_self` plus the two rank-`0`
projections), and satisfying the strong (ultrametric) triangle inequality
`d(P,R) ≤ max (d(P,Q)) (d(Q,R))` — *not just* the additive one — because the meet realises
`max`. The key insight is that the tropical-`max` law for `sumSystem` is exactly the
ultrametric inequality in disguise, so the valuation already secretes a metric. Why now:
the catalog has both the antisymmetrization poset (`pEquiv_iff_antisymmRel`,
`exists_two_distinct_pdegrees`) and the ultrametric reconstruction machinery in
`CategoricalTropicalUltrametric`, so the descent and the ultrametric axioms can be proven by
reusing existing lemmas rather than rebuilding either side.

### 2. Compute the growth-rank of the explicit `powSystem` ladder and prove unboundedness.

`DegreeLattice.powSystem k` (size `2^(n^k)`) is an infinite strictly increasing chain.
Conjecture: `simRank (powSystem k) (powSystem (k+1))` is finite for every `k` but the family
`k ↦ simRank (powSystem 1) (powSystem (k+1))` is **unbounded**, exhibiting a sequence of
p-degrees of strictly increasing tropical distance from a fixed base. The key insight is
that `pow_pow_succ_gap` already isolates the precise super-polynomial gap between consecutive
rungs, so it should pin down the growth rank rung-by-rung. Why now: the ladder and its gap
lemma are fully formalized in `DegreeLattice.lean`, so this is a direct quantitative
refinement of an existing qualitative separation (`powSystem_strictMono`) — turning "infinite
height" into "infinite tropical diameter".

### 3. A `simRank`-Lipschitz transfer theorem into certified robustness bounds.

`CategoricalTropicalUltrametric` proves quantitative bounds transfer functorially from the
tropical world to ultrametric/certified-robustness settings
(`lipschitz_certified_robustness_transfer_quantum`,
`post_quantum_security_gap_transfer`). Conjecture: the valuation `simDegree` is a
`1`-Lipschitz functor from the simulation preorder into `degreeTropObject`, so every
proof-complexity separation yields a *certified lower bound* in the ultrametric image. The
key insight is that `simDegree_comp_le` is precisely the Lipschitz/contraction estimate the
transfer theorems consume as a hypothesis. Why now: with the homomorphism `simDegree_*` in
hand, the only missing step is to feed it into the already-proven transfer lemmas, making a
proof-complexity → robustness pipeline realistic in one short cycle.

### 4. Tightness: is the composition law `growthRank_comp` ever an equality?

We proved `growthRank (f∘g) ≤ growthRank f + growthRank g`. Conjecture: for the canonical
"degree-`2^k`" witnesses `f(n) = (n+2)^(2^a) - 2`, the inequality is an **equality**, so the
valuation is not merely sub- but genuinely *additive* on a spanning set of morphisms (a
tropical *homomorphism*, not just a lax one). The key insight is that the slack in the bound
comes only from non-extremal blow-ups, and the extremal family saturates the
`pow_mul`/`pow_add` step in `GrowthBound.comp` exactly. Why now: the extremal witnesses are
elementary polynomials already expressible with the current `GrowthBound` predicate, so the
lower bound `growthRank f + growthRank g ≤ growthRank (f∘g)` reduces to a single
`Nat.pow`-injectivity argument.

### 5. A dual (Stone-type) representation of the p-degree semilattice via the valuation.

The p-degrees form a meet-semilattice (`isGLB_sumSystem`, `simulation_directed`) and now
carry a tropical valuation. Conjecture: the assignment `P ↦ (Q ↦ simDegree P Q)` is an
order-reversing embedding of p-degrees into a space of `WithBot ℕ`-valued functions with the
pointwise tropical structure — a **dual representation** in the spirit of Stone/Gelfand
duality, recovering the order from the valuation. The key insight is that `simRank P Q = 0`
together with `simRank Q P = 0` characterises p-equivalence, so the valuation separates
points of the poset, which is exactly the injectivity needed for a representation theorem.
Why now: the duality-and-representation toolkit of `CategoricalTropicalUltrametric`
(valuation reconstruction as a functor) is designed for precisely this move, and the
point-separating property follows from the rank-`0` projection lemmas proven this cycle.
