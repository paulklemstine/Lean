
            ## PHASE A: LEAN 4 ONLY — DOING THE MATH

            You are leading a research team: Hypothesizer, Experimenter, Analyst,
Critic, and Synthesist. Run the loop:
Hypothesize -> Experiment -> Analyze -> Critique -> Generalize -> Iterate.
Your ONLY job is to produce **new Lean 4 code** and **take good notes**
for the next team.

            ### DELIVERABLES (strict — only this):
            1. **lean files (count chosen by theorem declarations)**
            2. **2-4 theorems with correct proofs (sorry = 0 on main results)**
            3. **Brief proof sketches** as `-- !-- comment -- !--` blocks (1-2 sentences each)
            4. **A FUTURE_DIRECTIONS.md file** listing 3-5 testable, falsifiable
               conjectures as a freeform narrative (NOT a form). Each direction MUST
               include a "The key insight is..." sentence and a "Why now?" justification.
               This file drives the next research cycle — make it count.
5. **Lab Notebook** as `-- !-- Lab Notebook -- !--` comment blocks
   in each .lean file: Hypothesis, Result, Insight, Failure analysis.

            ### DO NOT OUTPUT (Phase B handles these — if your work passes quality bar):
            - NO `ARTICLE.md`
            - NO `RESEARCH_PAPER.md`
            - NO `demo.py` / `algorithms.py`
            - NO HTML widgets
            - NO `PACKAGE.json`
            - NO prose for human readers (except FUTURE_DIRECTIONS.md)

            ### WHY THIS NARROW:
            The Lean 4 file IS the deliverable. A self-contained Lean file with
            3-5 world-class theorems is worth more than 30K characters of prose
            about trivial results. Focus 100% of your compute on the math.
            If your work is genuinely world-class, the packaging step is dispatched
            automatically and cheaply.

            ### CATALOG SYNTHESIS (required — read the catalog context below):
            The Catalog Context and Recent Discoveries sections list existing theorems
            already proven in this project. You MUST analyze these and combine concepts
            from the catalog with the research direction above. Specifically:

            1. **Identify relevant catalog theorems** — Which existing results connect
               to your research direction? Cite them by name in your proof sketches.
            2. **Build on catalog foundations** — Your theorems should EXTEND or
               GENERALIZE catalog results, not reprove them from scratch. Use `import`
               and reference existing definitions and lemmas where possible.
            3. **Combine concepts across domains** — The most valuable theorems connect
               ideas from different catalog domains (e.g., applying algebraic structures
               to topological problems, or using combinatorial arguments in number theory).
               Look for cross-domain connections in the catalog context.
            4. **Avoid duplication** — Check the catalog context before proving. If a
               similar result already exists, extend it rather than reproving it.


## Concept

**Title**: Functorial tropicalization of proof spectra via semiring congruence quotients
**Domain**: Bridges
**Mathematical framing**: Define a tropicalized proof cost on a semiring with proof-spectrum congruence as a map into an idempotent ordered semiring satisfying normalization, congruence invariance, subadditivity for addition, and submultiplicativity for multiplication. Main conjectural theorem: such a cost factors through the proof-spectrum quotient and induces an order-preserving semiring morphism into a tropical target when strengthened by exactness axioms on distinguished generators. Intermediate lemmas should establish congruence-respect, well-definedness on quotient representatives, monotonicity on the zeroClass from `Algebra/ProofSpectra/Core.lean`, and compatibility with homomorphic transport. A concrete first milestone is a theorem that any natural-valued length/complexity function satisfying `c 0 = ⊥`, `c (a+b) ≤ max (c a) (c b)` and `c (a*b) ≤ c a + c b` descends to a max-plus or min-plus invariant on the proof-spectrum quotient. A second milestone is a bridge theorem packaging this descent as a functor from a category of semirings-with-congruence to tropical ordered semirings. This is not a notation variant: it would connect an existing algebraic quotient construction to tropical semantics in a way the catalog currently lacks.
**Concept description**: The key insight is that the algebraic proof-spectrum machinery already present in `Algebra/ProofSpectra/Core.lean` should admit a genuinely new bridge to Tropical by sending multiplicative proof-composition data to min-plus complexity profiles, and this bridge can be made concrete as order-preserving inequalities and quotient-compatible maps rather than vague analogy. Why now: Bridges↔Tropical is explicitly identified as a high-potential missing structural connection, Tropical already has substantial zero-sorry infrastructure, and recent work on tropical eigenvalues and valuation-style limits suggests the catalog is mature enough to support a rigorous semiring-level transfer theorem without repeating the avoided valuation-bridge project. Concretely, study whether a semiring congruence class in a proof spectrum determines a tropical cost functional on representatives, and prove that this functional descends to the quotient whenever it is subadditive under multiplication and monotone under the spectrum relation. The target theorem should be falsifiable: given a semiring `R`, a proof-spectrum congruence `SRCong R`, and a cost map `c : R → α` into a canonically ordered idempotent semiring or linear order, prove precise descent criteria of the form `a ≈ b → c a = c b`, plus induced inequalities `c (a * b) ≤ c a ⊗ c b` and `c (a + b) ≤ c a ⊕ c b` in tropical notation. A stronger bridge result is to construct, from any quotient-compatible submultiplicative cost, an induced map on zero classes/quotient objects that behaves functorially under semiring homomorphisms preserving the congruence. This would create a reusable pipeline from algebraic proof systems to tropical complexity bounds, giving an algorithmic way to extract tropical invariants from formal proof data rather than just asserting existence.
**Novelty estimate**: 0.88
**Breakthrough potential**: 0.82
Research domain: Bridges
Research mode: prove


### Lean 4 Sketch
Likely implement in a new file such as `Catalog/Bridges/ProofSpectraTropicalization.lean`. Reuse `SRCong`, `zeroClass`, and quotient lemmas from `Algebra/ProofSpectra/Core.lean`; define a structure `TropicalProofCost` with axioms; prove `descends_to_quotient`; then add transport lemmas along semiring homomorphisms. If quotient API is awkward, start with invariant-on-related-elements theorems before packaging the induced quotient map.


### Catalog Context
@Algebra/ProofSpectra/Core.lean
```lean
/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Proof-Theoretic Algebraic Geometry: Prime Congruence Spectra and Idempotent Cut-Elimination

This file founds **proof-theoretic algebraic geometry** by establishing that semiring
congruences carry a rich geometric structure analogous to the Zariski topology on
commutative rings. The central objects are:

- **Prime congruences** on semirings (the analogue of prime ideals)
- **Proof spectra** — the set of prime congruences, forming a spectral-like space
- **Idempotent semirings** — where x + x = x, connecting to tropical geometry
- **Zariski-closed proof varieties** via a Galois connection

## Main results

* `zariskiClosed_iInter` — V(⋃ 𝒮) = ⋂ V(S): closed under arbitrary intersections
* `zariskiClosed_union_eq_inter` — V(S ∪ T) = V(S) ∩ V(T)
* `galois_connection_theory_variety` — The Galois connection S ⊆ Th(X) ↔ X ⊆ V(S)
* `idempotent_add_natural_preorder` — Idempotent addition induces a natural preorder
* `idem_add_is_join` — Addition is the join operation in the natural order
* `prime_cong_zero_class_prime_theory` — Zero-class of prime congruence is a prime theory
* `radical_fixpoint_iff_inter_primes` — Radical = T ↔ T is intersection of primes
* `radicalTheory_idempotent` — The radical operator is idempotent
* `towerExp_ge_pow` — Tower function grows faster than simple exponentiation
* `nontrivial_prime_exists` — Integral domains have non-degenerate prime congruences
* `idem_nsmul_eq` — Summing n copies of x in an idempotent monoid gives x

## Bridge: algebraic_geometry ↔ proof_theory

Proof systems form semirings: disjunction = addition, conjunction = multiplication.
Prime congruences are "geometric points", Zariski-closed sets = provability loci.

## Bridge: tropical_geometry ↔ computational_complexity

Idempotent semirings (x + x = x) are tropical semirings. Every congruence admits
a prime refinement, yielding decidability with explicit complexity bounds.
-/

import Mathlib

set_option maxHeartbeats 400000

universe u

open Set

/-! ## Section 1: Semiring Congruences -/

/-- A semiring congruence: an equivalence relation compatible with `+` and `*`.
    Bridge: connects universal_algebra to proof_theory via derivation equivalence.
    Application: proof_search, certified_robustness -/
structure SRCong (R : Type u) [Semiring R] where
  /-- The underlying relation -/
  rel : R → R → Prop
  /-- Reflexivity -/
  refl : ∀ a, rel a a
  /-- Symmetry -/
  symm : ∀ {a b}, rel a b → rel b a
-- ... (truncated, full file has 721 lines)
```

@Bridges/BerggrenTransferDuality.lean
```lean
/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib

/-!
# Berggren Transfer Duality via Triple-Tree Scattering Semimodules

This file establishes a formal bridge between **Berggren arithmetic dynamics** of primitive
Pythagorean triples, **weighted automata / Hankel realization theory**, and
**idempotent transfer physics**.

## Main Results

The core insight is that a finite arithmetic tree (Berggren subtree) is recoverable from
transfer observables exactly as a finite scattering object is recoverable from its
response data.

### Key Theorems

1. `prefixClosed_nil_mem` — Every nonempty prefix-closed set contains the root word.
2. `prefixClosed_prefix_mem` — Prefix-closed sets are closed under taking prefixes.
3. `boundaryWords_finite` — The boundary of a finite set is finite.
4. `futureEquiv_equivalence` — Future-equivalence is an equivalence relation.
5. `finiteRankHankel_of_finite_prefix_closed_support` — Finite support implies finite
   Hankel rank (the core Hankel finiteness theorem).
6. `finiteRankHankel_iff_finiteResonanceType` — Finite Hankel rank is equivalent to finite
   resonance type for prefix-closed languages.
7. `berggren_transfer_duality` — Existence of transfer duality for finite Berggren subtrees.
8. `certified_reconstruction_from_observables` — Certified reconstruction of the minimal
   resonance automaton from observable data.
9. `spectral_shell_decomposition` — Depth-shell decomposition of finite Berggren subtrees.
10. `transfer_observables_determine_boundary_partition` — Transfer observables determine
    the boundary resonance partition.

## Mathematical Context

- **Arithmetic inverse scattering**: Finite Berggren subtrees behave like compact scatterers,
  with root-to-boundary paths as channels and transfer weights as propagation amplitudes.
- **Weighted automata**: Pythagorean triple generation is recast as a 3-letter deterministic
  production system with semiring-valued observables.
- **Tropical resonance**: In idempotent semirings, addition models competition of channels,
  multiplication models propagation, and finite decomposition corresponds to finitely many
  dominant resonant modes.

## References

- Berggren (1934): "Pytagoreiska trianglar"
- Fliess (1974): Hankel matrices and rational series
- Berstel–Reutenauer: Rational series and their languages

## Keywords

arithmetic inverse scattering, Berggren tree realization, weighted automata,
Hankel minimality, idempotent transfer semimodules, tropical resonance,
certified reconstruction, discrete scattering channels, Pythagorean spectral shells,
arithmetic interference invariants, formal inverse problems, semiring signal processing
-/

-- ... (truncated, full file has 666 lines)
```


### Recent Discoveries in Catalog
No previous research cycles completed yet. This is a cold start — prioritize sorry_fill on the priority targets (CarmichaelComposite, Fib_gcd_identity) to close known open problems, or target cross-domain bridge theorems for novelty.


## v10 Depth Requirements -- Conceptual Unifier Research Engine

You are leading a mathematical research team. Your goal is to produce groundbreaking,
master-class, useful, novel, and marvelous new Mathematics that pushes the frontier of human knowledge.

This engine is configured for **Conceptual Unification (Grothendieck style)**. Search for deep, hidden structures, universal patterns, and bridges across domains.

### RESEARCH CORE METHODOLOGY:
1. **Abstract Structural Patterns**: Frame your objects and mappings in terms of universal structures, symmetries, and invariant properties. Look for the underlying categorical, topological, or algebraic foundations that make the specific problem a special case of a deeper truth.
2. **Cross-Domain Bridges**: Connect apparently distinct mathematical worlds (e.g. applying algebraic structures to computational complexity, or geometry to logic).
3. **Generalization Over Specialization**: Prefer elegant, universal formulations that unify multiple separate facts into single, coherent conceptual frameworks.

### DELIVERABLES:
- **Lean 4 proofs** of deep, non-trivial theorems with complete proofs (no sorry on main results).
- **Lab Notebook** comment blocks in each .lean file detailing Hypothesis, Result, Insight, and Failure analysis.
- **FUTURE_DIRECTIONS.md** outlining the Synthesis of your findings, a Results Summary, and 3-5 bold, falsifiable research directions to steer the next cycle.


## Output format reminder

Your output must include `.lean` files AND a `FUTURE_DIRECTIONS.md` file.
The .lean files contain the proofs. The FUTURE_DIRECTIONS.md contains 3-5
research conjectures that extend the work. Both are required.
Be precise, be deep, be world-class.
