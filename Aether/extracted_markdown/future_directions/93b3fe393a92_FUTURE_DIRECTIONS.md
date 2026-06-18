# Future Directions — The compositional algebra of simulation meets

## Synthesis

The order-theoretic Cook–Reckhow program in `Catalog/Logic/ProofComplexity/` had already
established that the direct-sum constructor `sumSystem` is the *greatest lower bound* of a
pair of proof systems in the p-simulation preorder (`isGLB_sumSystem`), together with the
witness algebra (`PolyBounded`, `PolyMono`, `polyMono_max`, `polyMono_comp`) that powers
its universal property. What was missing was the step from a *single* meet to a *calculus*:
the equational laws and the n-ary generalisation that make simulation certificates
combinable by machine rather than merely assertable.

This cycle closes that gap in `Catalog/Logic/ProofComplexity/SumSystemAlgebra.lean`. From
the three projection/universal lemmas alone we derived the full meet-semilattice equational
theory — commutativity (`sumSystem_comm`), associativity (`sumSystem_assoc`), idempotency
(`sumSystem_idem`) — together with monotonicity/functoriality of the meet
(`sumSystem_mono`, `sumSystem_pEquiv_congr`). We then bootstrapped *finite* meets via a
list fold (`sumSystemList`, `isGLB_sumSystemList`): a large simulated system can be
assembled from many small ones, and the assembly is provably the GLB of the whole family.
The capstone descends the meet to the antisymmetrized poset of p-degrees, upgrading its
bare `PartialOrder` to a genuine `SemilatticeInf` (`instSemilatticeInfPDegree`).

## Results summary

* `sumSystem_comm`, `sumSystem_assoc`, `sumSystem_idem` — meet-semilattice laws up to
  p-equivalence, proved purely from the universal property.
* `sumSystem_mono`, `sumSystem_pEquiv_congr` — functoriality / congruence of the meet:
  simulation certificates compose under binary sum, with blow-up the `max` of the witnesses.
* `sumSystemList`, `sumSystemList_simulates`, `simulates_sumSystemList_of_forall`,
  `isGLB_sumSystemList` — the n-ary assembly pipeline; finite meets exist and are a fold.
* `instSemilatticeInfPDegree` — the p-degrees over `ℕ` form a `SemilatticeInf`.

All results are `sorry`-free and depend only on the standard axioms
(`propext`, `Classical.choice`, `Quot.sound`).

## Bold, falsifiable research directions

### 1. The p-degrees are *not* a lattice: meets exist but joins generically fail.

The natural dual of `sumSystem` would be a "product" proof system serving as the *least
upper bound* (join) of two p-degrees — a system that is p-simulated by both `P` and `Q`.
We conjecture that **binary joins do not exist in general**: there are p-degrees `P`, `Q`
with no least common upper bound, so `Antisymmetrization (ProofSystem ℕ) (· ≤ ·)` is a
meet-semilattice that is provably *not* a lattice. The key insight is that an upper bound
of `{P, Q}` must be *simultaneously* p-simulated by two systems whose hard instances are
super-polynomially incomparable (as in `powSystem_strictMono` / `LadderDensity`), and any
candidate join would have to dominate both growth rates while staying minimal — a tension
that the Fibonacci/ladder separations already show is unsatisfiable in the worst case. Why
now: the meet side is now fully algebraic (`isGLB_sumSystemList`, `instSemilatticeInfPDegree`),
so the join side is the precise remaining structural unknown, and the existing separators
(`not_simulates_powSystem_succ`, `pow_pow_succ_gap`) are exactly the obstructions one needs
to engineer an explicit join-less pair.

### 2. The fold blow-up is logarithmic in the family size: a quantitative assembly law.

`isGLB_sumSystemList` is qualitative. We conjecture a **quantitative** companion: when
assembling `n` systems each simulated by a target with witness polynomial of degree `≤ d`,
the folded system `sumSystemList` is simulated with witness degree `≤ d` *independent of
`n`* (only the constant, not the degree, grows, and it grows like `log n` in the exponent
via repeated `polyMono_max`). The key insight is that `polyMono_max` adds exponents
additively (`k₁ + k₂ + 1`), so a balanced fold of `n` certificates costs `O(log n)` in the
exponent rather than `O(n)` — a genuine efficiency statement about the calculus itself. Why
now: `polyMono_max` and `sumSystem_mono` already expose the exact exponent arithmetic, and
`sumSystemList` gives the recursion to induct on; the conjecture is a clean induction whose
falsification would be a concrete family forcing linear exponent blow-up.

### 3. `sumSystem` is the categorical product of an enriched simulation category.

Promote the preorder to a **category** whose objects are proof systems and whose morphisms
`P ⟶ Q` are the polynomial-blow-up translations witnessing `Simulates P Q`, enriched over
the monoid `(PolyMono, ∘, id)` of witness polynomials. We conjecture `sumSystem` is the
honest categorical **product** in this category (not just a poset GLB), with `Sum.inl` /
`Sum.inr` the projections and `simulates_sumSystem_of_simulates_both` the pairing, and that
the product is *functorial* exactly as `sumSystem_mono` records. The key insight is that
`PolyMono`'s closure under composition (`polyMono_comp`) and `max` (`polyMono_max`) makes
the hom-objects a genuine enrichment base, turning order-theoretic GLB into a universal
property with explicit data. Why now: the witness-composition algebra is fully formalised,
so the only new ingredient is naming the morphisms and checking the product axioms — a
finite, mechanical obligation directly on top of this file.

### 4. A meet-continuity / Scott-topology bridge to the infinite ladder.

`DegreeLattice` exhibits an infinite strictly increasing chain `powSystem (k+1)`; combined
with the new `SemilatticeInf` we can ask whether the p-degrees are **meet-continuous**:
does the meet distribute over the directed suprema realised by such ladders? We conjecture
the p-degree poset is a *conditionally complete* meet-semilattice in which the `powSystem`
ladder has *no* least upper bound (echoing Direction 1) but every *bounded-below* family
has a meet computed by an `sumSystem`-style limit. The key insight is that meets are
"local" (controlled pointwise by `polyMono_max`) while joins are "global" (forced to
dominate an entire growth rate), so meet-continuity should hold while join-continuity
fails — a structural asymmetry mirroring `bot_exists_no_top`. Why now: both the chain
(`powSystem_strictMono`) and the meet (`instSemilatticeInfPDegree`) are now formal objects
in the same namespace, so their interaction is stateable and testable directly.

### 5. Compositional separation: meets preserve and reflect hardness.

Combine the meet algebra with the generic separation template `no_simulation_of_hard`. We
conjecture a **compositional separation principle**: `sumSystem P Q` fails to p-simulate a
target `R` *iff at least one of* `P`, `Q` fails to — i.e. hardness lower bounds are
detected componentwise through the meet. The key insight is that `sumSystem P Q` simulates
`R` exactly when *both* components do (by the universal property), so the contrapositive
turns a monolithic separation into a disjunction of component separations, making lower
bounds modular. Why now: `no_simulation_of_hard`, `not_polyBounded_fib`, and the new
`sumSystem_mono` are all in place, so the principle is a short logical consequence whose
failure would expose a non-componentwise hardness phenomenon worth isolating.
