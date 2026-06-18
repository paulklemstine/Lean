
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

**Title**: A functor from proof-complexity degree lattices to tropical valuation objects via polynomial growth rank
**Domain**: Bridges
**Mathematical framing**: Work in the proof-complexity framework of simulation preorders. Define a numerical invariant `growthRank` on morphisms/witnesses of `PolyBounded` or on equivalence classes in the degree lattice, intended to measure the least polynomial exponent certifying simulation. Main target theorems: (1) `growthRank(id) = 0`; (2) `growthRank(g ∘ f) ≤ growthRank(f) + growthRank(g)`; (3) for the sum-system operation from `DegreeLattice`, `growthRank(sumSystem f g) = max (growthRank f) (growthRank g)` or at least the two-sided inequalities needed for a tropical valuation; (4) monotonicity under simulation order; (5) these laws induce a `TropicalValuationObject` in the sense of `Bridges/CategoricalTropicalUltrametric.lean`. A stronger version would descend this invariant to simulation-equivalence classes and define a pseudo-ultrametric on degrees by `d(x,y) = growthRank(x↔y)` or a one-sided hemimetric. The proof strategy should follow the future-direction pattern that succeeded in the catalog: extract the order-theoretic core first, then show the tropical axioms by reusing `polyBounded_comp`, `polyMono_*`, and sum-system simulation lemmas, rather than introducing a new proof-complexity formalism.
**Concept description**: The key insight is that the polynomial simulation data already formalized in the Cook–Reckhow side of the catalog can be compressed into a tropical valuation by assigning to each proof system morphism its least polynomial growth exponent, turning composition into tropical addition and binary choice/sum systems into tropical maximum. Why now: the catalog has recently matured on the order-theoretic core of proof complexity, with `Logic/ProofComplexity/SimulationPreorder.lean` and `Logic/ProofComplexity/DegreeLattice.lean` identifying simulation and sum-system structure, while `Bridges/CategoricalTropicalUltrametric.lean` already provides a target category of tropical valuation objects. This makes it realistic to prove a genuine cross-domain bridge rather than inventing parallel notation. Concretely, define a growth-rank valuation on `PolyBounded` witnesses: if a simulation is bounded by `C * n^k`, its valuation is the minimal such exponent `k`. Prove that identity has valuation `0`, composition satisfies a subadditivity law giving tropical additivity of exponents, and the sum-system constructors satisfy a max-law reflecting the dominant exponent under coproduct-like combination. Package these into a `TropicalValuationObject` attached to the simulation preorder or its degree lattice, and show monotonicity under the lattice order. If the exact minimal exponent is technically awkward in Lean, a first robust theorem can use an infimum/abstract rank satisfying the same axioms. This would matter because it translates proof-complexity comparison data into a metric/valuation invariant, opening algorithmic lower-bound heuristics and giving a new semantics for degree growth beyond pure order theory.
**Novelty estimate**: 0.92
**Breakthrough potential**: 0.88
Research domain: Bridges
Research mode: prove


### Lean 4 Sketch
Bridges/ProofComplexityTropicalDegree.lean


### Catalog Context
@Logic/ProofComplexity/SimulationPreorder.lean
```lean
import Mathlib

/-! # The abstract simulation preorder of proof systems, and a Fibonacci separation bridge

This file formalizes the order-theoretic core of the **Cook–Reckhow program** in proof
complexity: the *p-simulation preorder* on abstract proof systems, together with a
cross-domain bridge to the catalog's Fibonacci / entry-point number theory
(`Shared.CarmichaelProof`, `Speculative.AutoResearch.CarmichaelComposite`).

A Cook–Reckhow propositional proof system is a surjective, polynomial-time computable map
from "proofs" to the tautologies they certify.  Abstracting away the computability layer,
we model a proof system as a completeness-witnessing map `proves : Proof → Thm` equipped
with a `size : Proof → ℕ`.  System `P` *p-simulates* `Q` when `Q`-proofs can be translated
into `P`-proofs of the same theorem with only a polynomial blow-up in size.

We prove:

* `Simulates` is a **preorder** (`Simulates_refl`, `Simulates_trans`, registered as a
  genuine `Preorder` instance) — the structural heart of the theory.
* p-equivalence `PEquiv` (mutual simulation) is reflexive, symmetric and transitive,
  registered as a `Setoid` (its quotient is the poset of "p-degrees").
* **Bridge to the catalog:** Fibonacci growth is *not* polynomially bounded
  (`not_polyBounded_fib`); hence no monotone polynomial blow-up can dominate it
  (`no_poly_bound_dominates_fib`).
* **Separation theorem:** if a system `Q` proves a family of theorems with linear-size
  proofs while every `P`-proof of the same theorem needs size `≥ F n`, then `P` does *not*
  p-simulate `Q` (`no_simulation_of_fib_hard`).  This is the proof-complexity reading of
  the catalog's Fibonacci lower bounds: super-polynomial (here, Fibonacci) size lower
  bounds are exactly what *separate* proof systems in the simulation preorder.

-- !-- Lab Notebook -- !--
Hypothesis : The Cook–Reckhow simulation relation, stripped of its computability layer
             and parameterized by an abstract polynomial blow-up class, should form a
             genuine preorder, and Fibonacci growth should provide an honest separating
             witness because it is super-polynomial.
Result     : Confirmed, `sorry = 0`.  `Simulates` is reflexive and transitive (a genuine
             `Preorder`), `PEquiv` is an equivalence (`Setoid`), and the separation
             `no_simulation_of_fib_hard` follows from `not_polyBounded_fib`.
Insight    : Transitivity is *exactly* closure of the polynomial blow-up class under
             composition; encoding "polynomially bounded" as `∃ k, f n + 1 ≤ (n+2)^k`
             makes composition closure elementary (the `+2` base dodges the `n = 0`
             corner where a constant bound would otherwise fail).  Monotonicity of the
             blow-up function is the one extra ingredient transitivity needs, so the
             blow-up class is `PolyMono := Monotone ∧ PolyBounded`.
Failure analysis : A first attempt used the bound `f n ≤ (n+1)^k`, which cannot dominate a
             constant `> 1` at `n = 0` and so is *not* closed under composition.  Shifting
             to `f n + 1 ≤ (n+2)^k` repairs this since `2 ≤ n+2` always.
-- !-- Lab Notebook -- !--
-/

namespace ProofComplexity

/-! ## The polynomial blow-up class -/

-- !-- comment: "Polynomially bounded" via a single exponent `k`; the `+2` base makes the
--             class closed under composition with no `n = 0` corner case. -- !--
/-- A function `ℕ → ℕ` is *polynomially bounded* if `f n + 1 ≤ (n+2)^k` for some `k`. -/
def PolyBounded (f : ℕ → ℕ) : Prop := ∃ k : ℕ, ∀ n, f n + 1 ≤ (n + 2) ^ k

/-- The blow-up functions used by simulations: monotone **and** polynomially bounded.
-- ... (truncated, full file has 238 lines)
```

@Logic/ProofComplexity/DegreeLattice.lean
```lean
import Mathlib
import Catalog.Logic.ProofComplexity.SimulationPreorder
import Catalog.Logic.ProofComplexity.SimulationDegrees

/-! # Lattice shape and parametric separation of the poset of p-degrees

This file extends the order-theoretic core of the Cook–Reckhow program developed in
`Catalog.Logic.ProofComplexity.SimulationPreorder` (the simulation preorder `Simulates`,
its `Preorder` instance `simulationPreorder`, `PolyBounded`/`PolyMono`, the Fibonacci
super-polynomiality `not_polyBounded_fib`) and
`Catalog.Logic.ProofComplexity.SimulationDegrees` (the generic separation template
`no_simulation_of_hard`, and the concrete `linSystem` / `fibSystem`).

We answer two structural questions about the **poset of p-degrees**
(`Antisymmetrization (ProofSystem Thm) (· ≤ ·)`):

* **Lattice shape.**  Binary *meets* always exist: the direct-sum proof system
  `sumSystem P Q` (proofs are `P.Proof ⊕ Q.Proof`) is the greatest lower bound of
  `{P, Q}` in the simulation preorder (`isGLB_sumSystem`).  Hence the simulation preorder
  is down-directed (`simulation_directed`) and the p-degrees form a meet-semilattice.

* **Parametric separation / infinite height.**  Beyond the single Fibonacci separation
  `lin_lt_fib`, the size functions `n ↦ 2 ^ (n ^ k)` give an **infinite strictly increasing
  chain** of p-degrees (`powSystem_strictMono`): each polynomial step in the exponent is a
  super-polynomial jump in size, so the poset of p-degrees has infinite height.

-- !-- Lab Notebook -- !--
Hypothesis : (1) The simulation preorder should have binary meets, realised concretely by
             a "run both systems" direct sum.  (2) Beyond one Fibonacci separation the
             degree poset should have infinite height, witnessed by a growth ladder whose
             consecutive rungs are separated by a super-polynomial gap.
Result     : Both confirmed, `sorry = 0`.  `isGLB_sumSystem` exhibits the meet; the
             characterisation `simulates_sysOfSize_iff` reduces simulation between
             `ℕ`-indexed size systems to pointwise polynomial domination, turning the
             chain into the elementary growth fact `pow_pow_succ_gap`.
Insight    : The right invariant is *polynomial domination of size functions*: `sys a`
             p-simulates `sys b` iff `a ≤ poly ∘ b`.  Lattice meets correspond to the
             pointwise `min`-in-strength (= `max` of blow-ups), and height corresponds to
             chains of growth rates that are not polynomially comparable.  The ladder
             `2 ^ (n ^ k)` works precisely because `n ^ (k+1) = n · n ^ k` outruns
             `c · n ^ k + c` for `n > c`, whereas a plain exponential `2 ^ (k·n)` would
             collapse (all such rungs are polynomially comparable).
Failure analysis : A first ladder attempt used `2 ^ (k * n)`; it collapses because
             `2 ^ ((k+1) n) ≤ (2 ^ (k n)) ^ 2`, i.e. consecutive rungs are p-equivalent.
             Moving the parameter into the *exponent of the exponent* (`n ^ k`) creates a
             genuinely non-polynomial gap.  The `k = 0` rung (constant size) needs a
             separate argument, so the published chain starts at `k = 1`.
-- !-- Lab Notebook -- !--
-/

set_option maxHeartbeats 1000000

namespace ProofComplexity

universe u v

variable {Thm : Type u}

/-! ## The direct-sum proof system and binary meets -/

-- ... (truncated, full file has 256 lines)
```

@Bridges/CategoricalTropicalUltrametric.lean
```lean
/-
  # Categorical Tropical–Ultrametric Equivalence
  ## via Valuation Reconstruction and Functorial Bound Transfer

  Bridge: connects tropical algebra ↔ ultrametric analysis ↔ certified robustness ↔
  post-quantum lattice-style metrics.

  **Core principle**: tropical valuation data on an ordered idempotent semiring can be
  reconstructed into an ultrametric seminorm, and quantitative bounds proven in the
  tropical world transfer functorially to ultrametric certified bounds relevant to
  quantum/cryptographic/ML settings.

  The most important mathematical message: **valuation reconstruction is not just a
  dictionary — it is a quantitative functor**.
-/

import Mathlib

open Function

noncomputable section

namespace CategoricalTropicalUltrametric

/-! ## §1. Tropical Valuation Objects

Bridge: connects tropical algebra to ultrametric geometry and certified robustness. -/

/-- A tropical valuation object: a linearly ordered additive-idempotent commutative monoid
    with a compatible multiplicative structure. The key axiom `add_eq_max'` encodes the
    tropical "addition = max" principle. -/
structure TropicalValuationObject (R : Type u) where
  le : R → R → Prop
  le_refl : ∀ a, le a a
  le_antisymm : ∀ {a b}, le a b → le b a → a = b
  le_trans : ∀ {a b c}, le a b → le b c → le a c
  le_total : ∀ a b, le a b ∨ le b a
  zero : R
  one : R
  add : R → R → R
  mul : R → R → R
  max_op : R → R → R
  add_eq_max' : ∀ a b, add a b = max_op a b
  max_comm : ∀ a b, max_op a b = max_op b a
  max_assoc : ∀ a b c, max_op (max_op a b) c = max_op a (max_op b c)
  max_idem : ∀ a, max_op a a = a
  max_le_left : ∀ a b, le a (max_op a b)
  max_le_right : ∀ a b, le b (max_op a b)
  max_least : ∀ {a b c}, le a c → le b c → le (max_op a b) c
  mul_comm : ∀ a b, mul a b = mul b a
  mul_assoc : ∀ a b c, mul (mul a b) c = mul a (mul b c)
  mul_one : ∀ a, mul a one = a
  mul_zero : ∀ a, mul a zero = zero
  add_zero : ∀ a, add a zero = a

/-- Bundled tropical valuation object. -/
structure TropObj where
  α : Type u
  trop : TropicalValuationObject α

-- ... (truncated, full file has 890 lines)
```

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


### Recent Discoveries in Catalog
No previous research cycles completed yet. This is a cold start — prioritize sorry_fill on the priority targets (CarmichaelComposite, Fib_gcd_identity) to close known open problems, or target cross-domain bridge theorems for novelty.


## v8 Depth Requirements -- Conceptual Unifier: Duality & Representation Research Engine

You are leading a mathematical research team. Your goal is to produce groundbreaking,
master-class, useful, novel, and marvelous new Mathematics that pushes the frontier of human knowledge.

This engine is configured for **Conceptual Unification (Duality & Representation)**. Search for deep dualities, representation theorems, and dual translations (such as Stone duality, Gelfand duality, or Fourier/Pontryagin dualities).

### RESEARCH CORE METHODOLOGY:
1. **Dual Translations**: Look for dual formulations of your mathematical objects. Translate geometric or topological spaces into algebraic representations (e.g. rings of functions), and algebraic structures back into geometric spaces.
2. **Representation Theorems**: Seek to represent abstract algebraic or topological structures as concrete operations on simpler, well-understood spaces (e.g. matrices, sets, or functions).
3. **Spectral Perspectives**: Leverage spectral properties, duality pairings, and transform methods to translate hard problems in the primary space into easier problems in the dual space.

### DELIVERABLES:
- **Lean 4 proofs** of deep, non-trivial theorems with complete proofs (no sorry on main results).
- **Lab Notebook** comment blocks in each .lean file detailing Hypothesis, Result, Insight, and Failure analysis.
- **FUTURE_DIRECTIONS.md** outlining the Synthesis of your findings, a Results Summary, and 3-5 bold, falsifiable research directions to steer the next cycle.


## Output format reminder

Your output must include `.lean` files AND a `FUTURE_DIRECTIONS.md` file.
The .lean files contain the proofs. The FUTURE_DIRECTIONS.md contains 3-5
research conjectures that extend the work. Both are required.
Be precise, be deep, be world-class.
