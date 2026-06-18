# Future Directions — Neural Simulation Preorders ↔ Proof-Complexity Coverage

## Synthesis of this cycle

The new file `Catalog/Bridges/NeuralSimulationPreorder.lean` builds a load-bearing bridge
between two previously unconnected catalog domains:

* the **coalgebraic neural observation semantics** of
  `Catalog/Bridges/CoalgebraicNeuralMyhillNerode.lean`
  (`NeuralObservationSystem`, `neural_behavior`, `NeuralHom`,
  `neural_hom_preserves_behavior`), and
* the **Cook–Reckhow simulation preorder** of
  `Catalog/Logic/ProofComplexity/SimulationPreorder.lean`
  (`ProofComplexity.Simulates`, `ProofSystem`), whose lattice shape is studied in
  `Catalog/Logic/ProofComplexity/DegreeLattice.lean` (`isGLB_sumSystem`).

The unifying object is an abstract **coverage relation** `Covers vA vB := ∀ b, ∃ a, vA a = vB b`
on value maps, equivalently `Set.range vB ⊆ Set.range vA`. Bundled as `VCovers` on
`ValueSystem V`, it forms a genuine `Preorder` and (under mutual coverage `VPEquiv`) a `Setoid`.

The decisive observation is an **asymmetry** between the two domains:

* On the **neural** side every state realises a *trace function* `realized N s = fun w => neural_behavior N s w`,
  and trace-simulation `NSimulates` is *definitionally equal* to coverage of those trace
  functions (`nsimulates_iff_vcovers`). So `NSimulates` is a preorder, `NeuralHom`s induce
  simulations (`nhom_nsimulates`), mutual simulation is exactly equality of realised behaviour
  sets (`npequiv_iff_range_eq`), and the neural **coproduct** `nsum` is the greatest lower bound
  of `{S,T}` (`nsum_isGLB`) — the neural mirror of `isGLB_sumSystem`.
* On the **proof-complexity** side completeness forces `proves` to be surjective, so the coverage
  layer is *trivial* and all content lives in proof `size`. Forgetting size, a `p`-simulation is
  a coverage witness (`simulates_imp_covers`): Cook–Reckhow simulation **refines** coverage.

Thus both domains live in one abstract preorder, with neural simulation *equal to* coverage and
proof simulation *strictly stronger than* coverage (the strictness being precisely the polynomial
size bound). This is summarised in `coverage_bridge`.

## Results summary (all `sorry`-free; axioms ⊆ {propext, Classical.choice, Quot.sound})

- `coveragePreorder` / `vpEquivSetoid`: the abstract coverage preorder and its degree setoid.
- `nsimulates_iff_vcovers`, `nsimulates_iff`: neural simulation = coverage of trace maps.
- `neuralSimulationPreorder`: the neural trace-simulation preorder.
- `nhom_nsimulates`: behaviour-preserving morphisms induce simulations.
- `npequiv_iff_range_eq`: bisimulation/behaviour equality = mutual simulation.
- `nsum_isGLB`: the neural coproduct is the binary meet (mirrors `isGLB_sumSystem`).
- `simulates_imp_covers` / `coverage_bridge`: the size-forgetful bridge from Cook–Reckhow.

## Falsifiable research directions

### 1. A size-graded neural simulation that matches Cook–Reckhow *exactly*, not just up to coverage

The current bridge is intentionally one-directional: proof simulation refines coverage, but
coverage forgets size. Conjecture: equip neural systems with a *cost* `cost : State → ℕ`
(e.g. derivative depth, or the length of a shortest witnessing context) and define a graded
relation `NSimulates_poly` requiring, for every state `t` of `T`, a matching state `s` of `S`
with `cost s ≤ f (cost t)` for a `PolyMono f`. The key insight is that the catalog's
`PolyBounded`/`PolyMono` machinery is domain-agnostic, so the *same* polynomial blow-up class
should turn the neural coverage preorder into a genuine size-graded preorder whose forgetful
image is exactly `NSimulates`. Falsifiable failure mode: composition may break if neural cost is
not subadditive along `neural_derivative`, in which case `NSimulates_poly` is not transitive.
**Why now?** `PolyMono`, `polyMono_comp`, and the proof that transitivity *is* closure of the
blow-up class under composition are already isolated in `SimulationPreorder.lean`; the only
missing ingredient is a cost function on neural states, which `neural_derivative` supplies.

### 2. A Fibonacci-style separation of neural systems

The catalog proves `no_simulation_of_fib_hard`: Fibonacci-size lower bounds separate proof
systems. Conjecture: there exist two neural systems `S`, `T` over a fixed finite alphabet such
that `T`'s behaviours are realised by `S` only through states of super-polynomially growing cost
(in the sense of Direction 1), so `S` does not `NSimulates_poly`-simulate `T` even though it does
coverage-simulate it. The key insight is that `two_pow_le_fib` and `not_polyBounded_fib` are
purely arithmetic and transfer verbatim, so a neural system whose minimal witnessing contexts
have Fibonacci length yields an honest separation. Falsifiable failure mode: every finite-state
neural system may have polynomially bounded minimal witnesses (a Myhill–Nerode finiteness
phenomenon), collapsing the separation. **Why now?** The Fibonacci lower-bound infrastructure is
already proved in the Logic file, and `neural_equiv_upto` already formalises bounded-depth
distinguishers — the exact lengths that a separation must control.

### 3. Coproduct = join and a dual product = meet, giving a full lattice of behaviour degrees

This cycle showed `nsum` is the GLB. Conjecture: the trace-product `nprod` (states
`S.State × T.State`, observations paired into `β × β`, projected appropriately) realises the
*intersection* of behaviour ranges and is therefore the least upper bound, so the poset of
behaviour degrees `Antisymmetrization (NeuralSystem α β) (· ≤ ·)` is a genuine lattice. The key
insight is that coverage is reverse range inclusion, so set-theoretic union/intersection of
behaviour ranges are exactly the meet/join — and `nsum_isGLB` already nails the union half.
Falsifiable failure mode: the intersection of two realised behaviour ranges need not itself be a
realised behaviour range of any single finite system, so the LUB may fail to exist
constructively. **Why now?** `nsum_isGLB`, `vpequiv_iff_range_eq`, and Mathlib's
`Antisymmetrization` give the entire scaffolding; only the product construction and one range
computation remain.

### 4. The bridge is a monotone functor that is faithful but not full

Conjecture: the assignment `S ↦ S.toValueSystem` is a *faithful* monotone functor
`(NeuralSystem α β, NSimulates) → (ValueSystem (List α → β), VCovers)` (faithful because
`nsimulates_iff_vcovers` is an iff), while `P ↦ ProofSystem.toValueSystem P` is monotone but
**not full**: there are value systems coverage-below `P`'s that no proof system `p`-simulation
realises, precisely because coverage ignores size. The key insight is that fullness fails exactly
on the size gap quantified by `not_polyBounded_fib`, turning a categorical property (fullness)
into a complexity statement (polynomial vs super-polynomial). Falsifiable failure mode: if one
restricts to proof systems of bounded size the functor could become full, sharpening *where* the
size obstruction lives. **Why now?** Both forgetful maps are already defined and proved monotone
in this file; fullness/faithfulness are one quantifier away and reuse the existing Fibonacci
separation.

### 5. Weighted/semiring neural systems and a quantitative coverage preorder

The neural file advertises semiring-weighted observation systems. Conjecture: replacing the
observation type `β` by a semiring and `Set.range`-coverage by *weighted domination* yields a
quantitative coverage preorder that specialises (over the Boolean semiring) to the present
`Covers` and (over the tropical semiring) to a shortest-context metric, linking this bridge to
the catalog's tropical/min-plus modules. The key insight is that `Covers` is the Booleanisation
of "the value of every right-realisation is ≤ the value of some left-realisation," so swapping
`=` for a semiring `≤` is the natural quantitative lift. Falsifiable failure mode: weighted
domination may fail antisymmetry on degrees when the semiring has nontrivial units, breaking the
`Setoid` quotient. **Why now?** The coverage relation has just been isolated as the single point
of contact between the domains, making it the natural place to inject semiring weights and reach
the tropical catalog modules.
