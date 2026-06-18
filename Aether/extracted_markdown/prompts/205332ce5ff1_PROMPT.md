
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

**Title**: Polynomial closure of simulation preorders via sum systems
**Domain**: Logic
**Mathematical framing**: Work in the proof-complexity lattice around `SimulationPreorder` and `DegreeLattice`. Treat `PolyBounded` as the certificate that a simulation overhead is eventually bounded by a polynomial and `PolyMono` as the monotonicity side condition needed to compose such certificates. First close the foundational algebra of witnesses: identity maps are polynomially bounded/monotone, and composition of polynomially bounded witnesses is polynomially bounded. Next establish that the pointwise maximum of polynomially monotone witnesses is polynomially monotone (`polyMono_max`). Then use these witness-building lemmas to discharge the sum-system simulation statements already specified in `DegreeLattice`: left and right inclusions into `sumSystem`, followed by the universal property that simulations from both summands into a target induce a simulation from the sum. The conceptual bridge is from Logic to Computation: the resulting theorems should be framed as a reusable complexity-composition pipeline, where simulation certificates can be mechanically combined, not just existentially asserted. A strong final theorem would state that the simulation preorder on systems is reflexive and transitive with polynomial witnesses, and that `sumSystem` is an upper-bound constructor for this preorder, yielding join-like behavior in the associated degree structure.
**Concept description**: The key insight is that the recently successful order-theoretic Cook–Reckhow program can be advanced concretely by proving that the simulation preorder is closed under the catalog’s `sumSystem` constructor with explicit polynomial witnesses, turning a qualitative preorder into a compositional complexity calculus. Why now: `Logic/ProofComplexity/SimulationPreorder.lean` and `Logic/ProofComplexity/DegreeLattice.lean` already expose exactly the missing ingredients—`PolyBounded`, `PolyMono`, and the theorems `simulates_sumSystem_left`, `simulates_sumSystem_right`, `simulates_sumSystem_of_simulates_both`—but these files still contain sorries, and the recent substantial breakthrough on the order-theoretic core of Cook–Reckhow indicates that closing these lemmas would unlock a genuinely new bridge from abstract degree lattices to algorithmic proof-complexity composition. The proposed research is to formalize and prove that polynomially bounded simulations are stable under identity, composition, and binary sum, then derive monotonicity and join-style upper bounds in the degree lattice. Concretely, one should prove the missing closure lemmas `polyBounded_id`, `polyBounded_comp`, `polyMono_id`, and the max-bound compatibility `polyMono_max`, and use them to show that if systems `A` and `B` both simulate `C` with polynomial overhead, then the sum system built from `A` and `B` also simulates `C` with an explicit overhead controlled by the max of the witness polynomials. This is falsifiable because the formal target is a specific chain of theorems already named in the catalog, and it matters because it would make the preorder computationally compositional rather than merely definitional, providing an algorithmic pipeline for assembling larger simulated systems from smaller ones.
**Novelty estimate**: 0.82
**Breakthrough potential**: 0.88
Research domain: Logic
Research mode: sorry_fill


### Lean 4 Sketch
Close the sorries in `Logic/ProofComplexity/SimulationPreorder.lean` and `Logic/ProofComplexity/DegreeLattice.lean` by proving witness lemmas about polynomial bounds and then feeding them into the existing `simulates_sumSystem_*` statements. Likely needs elementary lemmas about monotonicity of `max`, polynomial closure under composition, and simple arithmetic normalization. After that, package a theorem showing compositionality of simulations under `sumSystem`.


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


## v12 Depth Requirements -- Speculative Specifier Research Engine

You are leading a mathematical research team. Your goal is to produce groundbreaking,
master-class, useful, novel, and marvelous new Mathematics that pushes the frontier of human knowledge.

This engine is configured for **Speculative Specifying (Bold Conjectures)**. Target high-risk, high-reward, grand-challenge level research.

### RESEARCH CORE METHODOLOGY:
1. **Grand Challenges**: Formulate bold, surprising, and non-trivial conjectures that challenge existing intuition. Even if a complete proof cannot be achieved in this cycle, outline precise strategies, obstacles, and partial results.
2. **Deep Speculation**: Explore radical connections that seem distant or impossible at first glance. Frame your theorems as seeds for entirely new fields of study.
3. **Long-Term Roadmap**: Dedicate significant intellectual effort to detailing the proof strategies and testable predictions in your future directions, laying out a clear path for future researchers.

### DELIVERABLES:
- **Lean 4 proofs** of deep, non-trivial theorems with complete proofs (no sorry on main results).
- **Lab Notebook** comment blocks in each .lean file detailing Hypothesis, Result, Insight, and Failure analysis.
- **FUTURE_DIRECTIONS.md** outlining the Synthesis of your findings, a Results Summary, and 3-5 bold, falsifiable research directions to steer the next cycle.


## Output format reminder

Your output must include `.lean` files AND a `FUTURE_DIRECTIONS.md` file.
The .lean files contain the proofs. The FUTURE_DIRECTIONS.md contains 3-5
research conjectures that extend the work. Both are required.
Be precise, be deep, be world-class.
