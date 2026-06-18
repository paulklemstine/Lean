# Future Directions — Neural Coalgebra ↔ Proof-Complexity Degree Lattice

## Synthesis

This cycle built a load-bearing **bridge** between two previously disconnected catalog
developments: the coalgebraic Myhill–Nerode theory of neural observation systems
(`Catalog/Bridges/CoalgebraicNeuralMyhillNerode.lean`) and the order-theoretic core of the
Cook–Reckhow program (`Catalog/Logic/ProofComplexity/{SimulationPreorder,SimulationDegrees,DegreeLattice}.lean`).

The connecting object is a **finite-depth behavioral preorder** `behavioral_le N k s t` on
the states of a neural observation system whose observation type carries a `Preorder`.  It
is the genuinely *directed* ("inclusion of observations") refinement of the catalog's
equality-based `neural_equiv_upto`.  The new file
`Catalog/Bridges/NeuralProofComplexitySimulation.lean` proves:

- a complete finite-depth calculus: reflexivity, **transitivity**
  (`behavioral_preorder_trans`), depth-antitonicity, derivative preservation
  (`derivative_monotone`), and the word characterisation `behavioral_le_iff`;
- compatibility with coalgebra morphisms
  (`coalgebra_morphism_preserves_simulation`), reusing
  `neural_hom_preserves_behavior`;
- that the all-depth behavioral preorder is a genuine coalgebraic simulation
  (`induced_simulates`); and
- the transport into proof complexity (`induced_degree_monotone`): for single-symbol,
  `ℕ`-valued neural systems the behavioral preorder pushes forward to the p-simulation
  preorder `ProofComplexity.Simulates` of the trace `sysOfSize` proof systems, with the
  *identity* polynomial blow-up — i.e. nonexpansiveness is inherited from the neural
  derivative rather than imposed.  This uses the catalog's domination characterisation
  `simulates_sysOfSize_iff` and `polyMono_id`.

## Results Summary (sorry = 0 on all main results; axioms: propext, Classical.choice, Quot.sound)

| Theorem | Statement |
|---|---|
| `behavioral_preorder_trans` | finite-depth behavioral preorder is transitive |
| `derivative_monotone` | depth-`k+1` relation descends to depth-`k` on one-step derivatives |
| `coalgebra_morphism_preserves_simulation` | `NeuralHom` transports `behavioral_le` |
| `induced_simulates` | the all-depth relation is a coalgebraic simulation |
| `induced_degree_monotone` | behavioral inclusion ⟹ p-simulation of trace `sysOfSize` (blow-up = id) |
| `behavioral_le_iff` | characterisation via pointwise `≤` of `neural_behavior` on bounded words |

## Bold, Falsifiable Research Directions

### 1. A genuine 1-Lipschitz disagreement pseudometric into the degree rank
Define `sepDepth N s t : ℕ∞` as the least context length at which `neural_behavior` first
*separates* `s` and `t` (`⊤` if never), and the ultrametric `d N s t = 2^(-sepDepth)`.
Conjecture: the map `state ↦ [sysOfSize (neuralTrace N ·)]` into the p-degree lattice is
**1-Lipschitz** for `d` against a degree-rank built from the `powSystem` height ladder in
`DegreeLattice.lean`; concretely, `rank` cannot drop faster than `sepDepth` grows.
The key insight is that `behavioral_le_iff` already equates depth-`k` agreement with
agreement on all words of length `≤ k`, so `sepDepth` is exactly the first failure index of
that quantifier — turning a metric estimate into a purely combinatorial statement about word
lengths. Why now: the present `induced_degree_monotone` realises the qualitative (monotone)
half with blow-up `id`; upgrading `id` to a *quantitative* modulus is the missing optional
target (6) and is now a finite-length bookkeeping problem rather than an analytic one.

### 2. Discharging `PolyBounded`/`PolyMono` obligations from neural traces
Conjecture: every neural system whose trace grows polynomially yields, via `neuralTrace`, a
canonical **monotone** witness for `PolyMono`, giving a reusable factory of simulations that
mechanically discharges the polynomial-boundedness side-conditions appearing throughout
`SimulationPreorder.lean` and `DegreeLattice.lean`. The key insight is that monotone neural
observation functions produce monotone traces for free, so the `Monotone` half of `PolyMono`
— usually proved ad hoc — becomes a structural consequence of the coalgebra. Why now:
`induced_degree_monotone` shows the trace sits *inside* `Simulates`; making the blow-up class
membership flow *out* of the neural side closes the loop and removes hand-built `Monotone`
proofs.

### 3. Functoriality up to homotopy: a path-space of simulations
Model the collection of finite-depth simulations between two neural systems as a **path
space**, where a path from depth `k` to depth `k+1` is the witness produced by
`behavioral_le_antitone`/`derivative_monotone`. Conjecture: the tower
`… ↪ behavioral_le N (k+1) ↪ behavioral_le N k ↪ …` is the truncation tower of a single
limit relation `neural_equiv`, and `induced_simulates` exhibits the limit as the homotopy
(co)limit; coalgebra morphisms act as path-space maps. The key insight is that
`behavioral_le_iff` makes each truncation a restriction-of-domain map on word-indexed
families, so the tower is literally a sequence of restriction maps whose inverse limit is the
full behavior. Why now: the antitone/limit lemmas are already proved, so the homotopical
reframing is a matter of packaging existing maps as a `CategoryTheory`/`Functor` diagram.

### 4. Localization inverting behavioral equivalences
Conjecture: localizing the category of neural observation systems at the class of morphisms
that are **behavioral equivalences** (those `f` with `neural_equiv N s t ↔ neural_equiv M (f s) (f t)`)
produces a category equivalent to the image of `state ↦ [sysOfSize (neuralTrace ·)]` inside
the p-degree poset; i.e. p-degree is the universal behavior-invariant. The key insight is
that `coalgebra_morphism_preserves_simulation` already shows morphisms act monotonically on
`behavioral_le`, so the localization functor is well-defined before any quotient is taken.
Why now: the catalog's `quotient_neural_system` is the canonical behavioral-equivalence
inverter, providing an explicit calculus-of-fractions model to test the equivalence against.

### 5. Cross-alphabet rank and infinite p-degree height from neural width
Conjecture: replacing the single-symbol alphabet by a `Fin (m+1)` alphabet upgrades
`neuralTrace` to a branching trace whose growth realises the `powSystem` height ladder, so
neural systems of unbounded *state width* map onto an **infinite strictly increasing chain**
of p-degrees (`powSystem_strictMono`). The key insight is that a wider alphabet multiplies
the number of length-`k` contexts geometrically, matching the `2^(n^k)` rungs of the existing
height theorem rather than the linear single-symbol trace used here. Why now:
`DegreeLattice.lean` already proves the height ladder and `powSystem_pdegrees_injective`;
connecting neural width to that ladder would turn the qualitative bridge into a *surjection
onto* the known infinite-height skeleton of the degree lattice.
