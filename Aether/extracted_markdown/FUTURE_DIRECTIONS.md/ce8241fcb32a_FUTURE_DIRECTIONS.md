# Future Directions: Degree-lattice simulation laws for additive proof systems

## Synthesis

The new file `Catalog/Logic/ProofComplexity/SimulationSemilattice.lean` closes the
gap between the *qualitative* Cook–Reckhow lattice already in the catalog
(`ProofSystemCollapse.union`/`union_least`, `DegreeLattice.sumSystem`/`isGLB_sumSystem`)
and the *quantitative* polynomial-degree layer that proof complexity actually
cares about. The organizing idea is to promote the polynomial *degree* — the
exponent `k` in the monomial size-blow-up bound `c·(n+1)^k` — to a first-class
index, `PSimAt S T k`. With the degree exposed, the join becomes a calculable
lattice operation: the direct sum `sumSystem` is the least upper bound in the
p-simulation preorder, and the *degree of the combined simulation is exactly the
`max` of the component degrees* (`psimAt_sumSystem_of_psimAt_both`). Packaged
through a `Preorder` instance, this yields `isLUB_sumSystem`, up-directedness,
and an honest `SemilatticeSup` on simulation-equivalence classes
(`Antisymmetrization` of the p-degree order). This is the explicit-monomial
avatar of `DegreeLattice.polyMono_max`, and it turns proof-complexity composition
into order theory.

## Results Summary

- `PSimAt` / `PSimulates`: polynomial simulation with the degree exposed, and its
  monotonicity (`psimAt_mono`), reflexivity, and transitivity (degrees multiply).
- `psimAt_sumSystem_of_psimAt_both`: the **degree-`max` join universal property**
  (the central new theorem).
- `isLUB_sumSystem`, `psim_directed`: `sumSystem` is the order-theoretic join; the
  preorder is up-directed.
- `instSemilatticeSupAntisymmetrization`: the induced **join-semilattice** on
  p-degrees.

The four conjectures below are concrete, falsifiable, and each builds directly on
a catalog foundation.

## Direction 1 — The dual meet with degree control: a genuine *lattice* of p-degrees

The catalog already has the qualitative meet (`ProofSystemCollapse.inter`, the
conclusion-matched product of proofs, with `inter_greatest`). The open question is
the *degree* of the meet. Conjecture: if `S` p-simulates `R` at degree `a` and `T`
p-simulates `R` at degree `b`, then the product system p-simulates `R` at degree
`a + b` (not `max`), so the antisymmetrization is a full `Lattice` whose meet adds
degrees while the join takes their max. The key insight is that joins *pad* the
weaker component up to a common degree for free, whereas meets must *pair* two
independent translations and therefore pay the sum of the exponents — the two
lattice operations carry genuinely different degree arithmetic. Why now: the
join half is finished here and the qualitative meet is finished in
`ProofSystemCollapse`; only the single degree bound `a + b` is missing to upgrade
`SemilatticeSup` to `Lattice`, and it reduces to a monomial inequality of exactly
the kind the subagent already discharged for `psimAt_trans`.

## Direction 2 — (Non-)distributivity of the p-degree lattice

Once both operations have degree control (Direction 1), ask whether the p-degree
lattice is distributive. Conjecture: it is **not** distributive — there is an
`N₅` (pentagon) sublattice witnessed by three systems built from the catalog
growth ladder `DegreeLattice.powSystem` (the `2^(n^k)` rungs) together with their
sums and products. The key insight is that degree-`max` joins and degree-`sum`
meets interact asymmetrically, so the modular law must fail somewhere along a
super-polynomially separated chain. Why now: `DegreeLattice.powSystem_strictMono`
already provides an infinite family of provably incomparable degrees, giving ready
made distinct points to assemble the pentagon; the falsification test is a finite
check of five explicit `PSimAt` (non-)bounds.

## Direction 3 — Compact elements and algebraicity (the singleton atoms)

Conjecture: the p-degree join-semilattice is *algebraic*, and its compact
elements are exactly the polynomially bounded systems (`ProofSystemCollapse.PBounded`),
with the single-formula systems (`ProofSystemCollapse.singletonSys`) as the atoms
under the `simulates_singleton_iff` duality. The key insight is that
`PBounded`-ness is precisely a finiteness-of-generation condition: a p-bounded
system is dominated by a finite "degree budget", so it cannot be the join of a
directed family without already appearing in it. Why now: the singleton duality and
`pbounded_union` (closure of `PBounded` under the join) are already proved in the
catalog, so the compactness proof reduces to combining them with the new
`isLUB_sumSystem`; this directly connects the lattice shape to classical
domain-theoretic structure.

## Direction 4 — A max-law bridge from Logic to Computation

The file `Computation/PadicValuationDepth.lean` proves an ultrametric composition
law `vdepth_add f g ≤ max (vdepth f) (vdepth g) + 1`: classical depth composed via
`max`, not `sum`. Conjecture: the assignment `system ↦ p-degree` is a lax monoidal
functor from `(ProofSystem, sumSystem)` to the join-semilattice that lands inside
the valuation-depth hierarchy, i.e. there is a Galois connection between p-degrees
and the depth classes `VAL_k` under which `sumSystem` corresponds to the
ultrametric `max`-composition. The key insight is that *both* sides are governed by
the same `max`-controlled composition law — `psimAt_sumSystem_of_psimAt_both`'s
degree-`max` is the proof-theoretic shadow of `vdepth_add`'s ultrametric `max` —
so the two hierarchies should be order-isomorphic on their additive fragments. Why
now: the degree-`max` law proved here is the first quantitative invariant on the
proof-system side that matches the non-Archimedean `max`-law already formalized on
the computation side, making the bridge stateable for the first time.

## Direction 5 — The degree functional as a multiplicative ultrametric valuation

Define the minimal simulation degree `d(S,T) := min { k | PSimAt S T k }` (when it
exists). Conjecture two laws: a *multiplicative triangle inequality*
`d(S,U) ≤ d(S,T) · d(T,U)` (degrees compose by multiplication, from `psimAt_trans`)
and a *join max-law* `d(U, sumSystem S T) = max (d(U,S), d(U,T))` (from the new
universal property, once minimality is established). The key insight is that the
degree is simultaneously multiplicative under composition and `max`-additive under
sums, exactly the signature of a non-Archimedean valuation — making the p-degree
poset a metric object, not merely an order. Why now: `psimAt_trans` and
`psimAt_sumSystem_of_psimAt_both` already supply the two inequalities in one
direction; the remaining work is the well-definedness of the `min` (a
well-ordering argument on `ℕ`) and the matching lower bounds, both finite and
self-contained.
