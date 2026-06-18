# Future Directions — Concrete d-Separation and the Graphoid Hierarchy

## Synthesis

The catalog already carried two attitudes toward causal independence. The
Čech-cohomological file (`Catalog/MachineLearning/CechComplex.lean`) treats
identifiability *algebraically*: discrepancies are cochains, `d² = 0` makes
cohomology well-defined, and `H¹ = 0` on the total space encodes "all effects
identifiable". The do-calculus roadmap, by contrast, imagined an *abstract*
`DSepOracle` whose graphoid axioms (symmetry, decomposition, weak union,
contraction) are simply *postulated*.

This cycle closes the gap from below. In
`Catalog/MachineLearning/ConcreteDSeparation.lean` we give a fully concrete,
combinatorial model of conditional independence — **undirected vertex
separation**, defined as non-reachability of `A` from `B` in the graph with the
conditioning set `Z` deleted — and *prove* that it satisfies all four
semi-graphoid axioms, plus the **composition** axiom that fails for generic
probabilistic independence. The four axioms are bundled into the structure
`graphSeparation_semigraphoid`, so the abstract oracle now has a witnessed
instance. The bridge `CausalDAG.skeleton` connects this to the catalog's
directed `CausalDAG`, since moralized d-separation is undirected separation in a
super-graph of the skeleton.

The unifying discovery is that the entire graphoid axiom system is a *shadow* of
three elementary facts about reflexive-transitive closure: **reversibility**
(symmetry), **anti-monotonicity in the deleted set** (weak union), and a
**first-hitting decomposition** of a walk relative to a predicate
(`reflTransGen_firstHit`, which powers contraction). The probabilistic axioms
are not deep about probability — they are deep about *reachability*.

## Results Summary

* `separation_symmetry`, `separation_decomposition`, `separation_weak_union`,
  `separation_contraction` — the four semi-graphoid axioms, proved for vertex
  separation.
* `separation_composition` — graph separation is *compositional*, separating it
  strictly from the probabilistic semi-graphoid.
* `graphSeparation_semigraphoid` — the bundled `SemiGraphoid` instance.
* `reflTransGen_firstHit` — a reusable, domain-agnostic first-hitting lemma for
  `Relation.ReflTransGen`.
* Sharper than folklore: contraction needed only `Disjoint A B`, not the usual
  `Disjoint A Z`.

## Falsifiable Research Directions

### 1. The Intersection Axiom and the Compositional-Graphoid Closure

Conjecture: undirected vertex separation also satisfies the **intersection**
axiom — `A ⊥ B | (Z ∪ W)` and `A ⊥ W | (Z ∪ B)` imply `A ⊥ (B ∪ W) | Z` — under
pairwise disjointness, making it a full *compositional graphoid* rather than
merely a semi-graphoid. This is falsifiable: a single finite graph with an
explicit triple `(A, B, W)` violating the implication would refute it. The key
insight is that intersection is again a first-hitting argument, but now the walk
must be split simultaneously against *two* predicates (`∈ B` and `∈ W`), so the
proof should follow from a *two-predicate* generalization of
`reflTransGen_firstHit` that tracks the first vertex meeting either set. Why now?
The single-predicate `reflTransGen_firstHit` already exists and was the only hard
ingredient of contraction; the two-predicate version is a direct structural
analogue, so the marginal cost is low and the payoff (placing graph separation
at the top of the graphoid hierarchy) is high.

### 2. Soundness of Moralized d-Separation in a `CausalDAG`

Conjecture: define the **moral graph** of `CechCausalComplex.CausalDAG`
(connect parents that share a child, then drop orientation) and the ancestral
restriction; then directed d-separation in the DAG is *equivalent* to undirected
`Separated` in the moralized ancestral graph. The soundness half (moral
separation ⟹ d-separation) is the falsifiable target. The key insight is that
the `CausalDAG.skeleton` bridge already lands d-separation inside the
`UndirectedGraph` world, so the only missing construction is the moralization
edge set, after which every graphoid theorem transfers *for free* by
specialization. Why now? `CausalDAG` ships with a topological `rank`,
`parents`/`children`, and acyclicity lemmas (`no_self_edge`, `edge_asymmetric`)
— exactly the scaffolding a moralization proof consumes — and the undirected
graphoid layer is now in place to receive the result.

### 3. Cohomological Obstruction = Reachability Obstruction

Conjecture: there is a functor from the reachability world of
`ConcreteDSeparation` to the Čech world of `CechCausalComplex` under which
"`A` is separated from `B` by `Z`" corresponds to the *vanishing* of a relative
`H¹` class supported on the `A`–`B` cut, so that `cocycle_path_decomposition`
(the frontdoor identity) is the cohomological image of `connAvoid_mono`. This is
testable on small graphs by computing both invariants and checking the
correspondence. The key insight is that both objects are quotients by a
"path-independence" relation — coboundaries on one side, reachability classes on
the other — so a comparison map should identify connected components with the
kernel of `coboundaryZero`. Why now? Both files now live in the same namespace
neighborhood and share the `CausalDAG` datatype, so a single bridge file can
import both and state the comparison without re-developing either theory.

### 4. A Verified Decision Procedure for `Separated`

Conjecture: `Separated G A B Z` is *decidable* and computable in polynomial time
via a breadth-first reachability search on the deleted graph, and the Boolean
procedure is provably equivalent to the `Prop`-level `Separated`. Falsifiable
by exhibiting an input on which the procedure and the relation disagree. The key
insight is that `ConnAvoid` is exactly `Relation.ReflTransGen` of a *decidable*
finite relation on `Fin n`, so its reflexive-transitive closure is decidable by
finite saturation, and `Separated` is a bounded conjunction of negations. Why
now? Everything is already phrased over `Fin n` and `Finset`, the decidable
substrate Lean's `Decidable` machinery and `decide` are built for, so extraction
to certified executable code is within immediate reach.

### 5. Faithfulness: Separation as the *Exact* Independence Relation

Conjecture: for the class of independence relations realizable by some
undirected graph, the semi-graphoid axioms together with composition are not
only *sound* but *complete* — i.e. an independence relation is graph-realizable
iff it is a compositional graphoid closed under the relevant union rules. The
falsifiable form: produce a compositional-graphoid relation on a small index set
that is provably *not* the separation relation of any graph. The key insight is
that `graphSeparation_semigraphoid` gives the soundness direction as a witnessed
instance, so completeness reduces to a *reconstruction* lemma — read edges off
the relation via `¬ (i ⊥ j | rest)` — and faithfulness becomes a fixed-point
statement about this reconstruction. Why now? The abstract `SemiGraphoid`
structure introduced here is the precise object a completeness theorem must
quantify over, making it the natural bridge between the graph-theoretic and
statistical (PC-algorithm) worlds named in the original roadmap.
