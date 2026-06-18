
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

**Title**: A valuation-depth ultrametric on proof-complexity simulation degrees
**Domain**: Bridges
**Mathematical framing**: Work in the proof-complexity framework of `Logic/ProofComplexity/SimulationPreorder.lean` and `Logic/ProofComplexity/SimulationDegrees.lean`. Let a simulation witness from P to Q consist of a polynomially bounded map together with its growth certificate. Associate to such a witness a finite-support numeric profile (for example coefficients of a bounding polynomial, or a support-count sequence by degree) and feed this profile into `ValuationDepthMeasure` from `Computation/PadicValuationDepth.lean`. Define `simDepth P Q` as the infimum/minimum depth over witnesses P <=p Q when such a minimum is representable, or as a chosen witness depth for a canonical normal form. Then define a symmetric separation on mutual simulation classes by `d([P],[Q]) = max(simDepth P Q, simDepth Q P)` or by a tropicalized variant compatible with the bridge API. Main target theorems: reflexivity gives `d([P],[P]) = 0`; composition plus `vdepth_sum_le`-style estimates yield the strong triangle inequality; preorder equivalence descends the distance to degree classes; monotonicity lemmas connect order and distance. A stronger version would package simulation degrees as an object of `TropicalValuationObject`/`UltraNormObj`. If direct coefficient valuation is too representation-dependent, replace it by a canonical degree-support multiset or minimal majorant polynomial. The project should avoid mere definitional transport and instead prove new structural theorems linking composition of simulations to ultrametric geometry.
**Concept description**: The key insight is that the order-theoretic Cook–Reckhow simulation framework can be enriched by a nonarchimedean size-of-separation invariant, built from p-adic-style valuation depth on witness functions, yielding an ultrametric geometry on simulation degrees rather than only a preorder. Why now: recent work already isolated the lattice structure of the p-simulation preorder and separately formalized valuation-depth subadditivity in `Computation/PadicValuationDepth.lean`, while `Bridges/CategoricalTropicalUltrametric.lean` provides an abstract pipeline from valuation-like data to ultrametric objects; this makes a first rigorous bridge between Logic/ProofComplexity and Tropical/Bridges tractable without repeating the in-flight arithmetic-height projects. Concretely, define a proof-system comparison invariant on reductions or simulation witnesses by measuring the valuation depth of the coefficient/support profile of the polynomial bound witnessing simulation, then prove: (1) identity witnesses have zero depth; (2) composition of witnesses satisfies a max- or additive-type inequality strong enough to induce a pseudoultrametric on mutual simulation classes; (3) equivalent proof systems have distance zero; (4) incomparable or strictly separated systems can have positive distance under explicit hypotheses; and ideally (5) the quotient by zero-distance inherits a tropical/ultrametric object in the sense of the existing bridge file. This matters because it upgrades the Cook–Reckhow program from order theory to quantitative geometry: not only whether one system simulates another, but how nonarchimedeanly close simulation mechanisms are. The proposal is falsifiable, because the central composition inequality may fail for naive witness encodings; if so, the research should isolate the correct witness semiring or restricted class of polynomial bounds for which the ultrametric structure genuinely exists.
**Novelty estimate**: 0.93
**Breakthrough potential**: 0.86
Research domain: Bridges
Research mode: prove


### Lean 4 Sketch
Create a new bridge file, likely `Bridges/ProofComplexityUltrametric.lean`, importing `Logic/ProofComplexity/SimulationPreorder`, `Logic/ProofComplexity/SimulationDegrees`, `Computation/PadicValuationDepth`, and `Bridges/CategoricalTropicalUltrametric`. Start with a restricted witness datatype whose composition is explicit and whose size profile lands in finitely supported sequences. Prove depth lemmas mirroring `polyBounded_comp` and `vdepth_sum_le`, then define a pseudometric-like structure on


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

@Logic/ProofComplexity/SimulationDegrees.lean
```lean
import Mathlib
import Catalog.Logic.ProofComplexity.SimulationPreorder

/-! # The poset of p-degrees and a generic separation template

This file is the **second cycle** of the order-theoretic Cook–Reckhow development begun in
`Catalog/Logic/ProofComplexity/SimulationPreorder.lean`.  That file proved that the
p-simulation relation `Simulates` on abstract proof systems is a `Preorder` and that
`PEquiv` (mutual simulation) is a `Setoid`.  Here we push the structure theory further and
make the separation phenomenon *concrete*:

* **Generic separation template** (`no_simulation_of_hard`).  The Fibonacci separation
  `ProofComplexity.no_simulation_of_fib_hard` used only one property of `Nat.fib`: that it
  is *not* polynomially bounded.  We abstract the hardness function to an arbitrary
  `s : ℕ → ℕ` with `¬ PolyBounded s`, recovering the Fibonacci statement as the special
  case `s = Nat.fib` (`not_polyBounded_fib`).  The engine is the monotonicity lemma
  `polyBounded_of_le`: domination by a polynomially bounded function is itself polynomially
  bounded.

* **Concrete witnesses** (`linSystem`, `fibSystem`, `exists_separated_pair`).  We exhibit
  two honest proof systems over `Thm = ℕ` — one with linear proof size, one with Fibonacci
  proof size — and prove the linear system is *not* p-simulated by the Fibonacci one.  This
  shows the simulation preorder is genuinely non-trivial: not all systems collapse to one
  p-degree.

* **Antisymmetrization** (`pEquiv_iff_antisymmRel`, `exists_two_distinct_pdegrees`).  We
  identify `PEquiv` with Mathlib's `AntisymmRel (· ≤ ·)`, so the canonical poset of
  *p-degrees* is exactly `Antisymmetrization (ProofSystem Thm) (· ≤ ·)` with its library
  `PartialOrder`.  The concrete separation upgrades to two genuinely distinct p-degrees,
  proving the poset has at least two points.

-- !-- Lab Notebook -- !--
Hypothesis : (1) The Fibonacci separation should be an instance of a purely growth-theoretic
             template parameterized by any non-polynomial hardness function.  (2) The
             abstract preorder should antisymmetrize to Mathlib's `Antisymmetrization`
             poset with no extra work, and the Fibonacci bound should furnish an explicit
             pair of distinct p-degrees, witnessing non-triviality.
Result     : Both confirmed with `sorry = 0`.  `no_simulation_of_hard` generalizes the
             Fibonacci separation; `exists_separated_pair` and `exists_two_distinct_pdegrees`
             give concrete witnesses; `pEquiv_iff_antisymmRel` is definitional.
Insight    : The *only* arithmetic input to any simulation separation is the closure
             fact `polyBounded_of_le` (a function below a polynomially-bounded one is
             polynomially bounded).  Everything else is order theory.  Hence "P fails to
             p-simulate Q" is equivalent to "the simulation blow-up would have to escape
             the polynomial class", which is a statement purely about growth classes — this
             is what makes the template parametric in the hardness function.
Failure analysis : A first instinct was to construct the concrete witnesses with `Fin`
             indexed proofs; using `Thm = ℕ` with `proves = id` (so completeness is just
             `Function.surjective_id`) removes all index bookkeeping and makes the hardness
             hypothesis `s n ≤ size pf` reduce to `rfl` after substitution.
-- !-- Lab Notebook -- !--
-/

namespace ProofComplexity

/-! ## Growth-class engine: domination is polynomially bounded -/

-- !-- comment: A function pointwise below a polynomially-bounded one is itself
--             polynomially bounded — the single arithmetic fact behind every separation. -- !--
/-- If `s n ≤ f n` for all `n` and `f` is polynomially bounded, so is `s`. -/
-- ... (truncated, full file has 161 lines)
```

@Computation/PadicValuationDepth.lean
```lean
/-
Copyright (c) 2025 Harmonic. All rights reserved.

# p-adic Valuation Depth: Algebraic Foundations for Non-Archimedean Computation

Bridge: Algebra/valuation_theory ↔ Computation/complexity_measures

The ultrametric inequality |a+b| ≤ max(|a|,|b|) eliminates carry propagation,
making p-adic arithmetic fundamentally cheaper than classical arithmetic.

## Main definitions
* `ValuationDepthMeasure` — typeclass for valuation depth of functions
* `ValDepthBounded` — predicate for bounded valuation depth
* `ValDepthClassSet` — complexity classes VAL_k
* `UltrametricCompositionLaw` — composition uses max not sum
* `HenselConvergenceData` — certified exponential convergence
* `HenselIterationComplexity` — O(log n) certified complexity
* `UltrametricLipschitzData` — Lipschitz data with ultrametric composition
* `StratifiedComputation` — abstract strict hierarchy model
* `DepthWitness` — hierarchy separation witnesses
* `ClassicalArithDepth` / `UltrametricArithDepth` — depth comparison
-/

import Mathlib

/-! ## Section 1: Valuation Depth Measure — Core Typeclass -/

/-- `ValuationDepthMeasure α β`: the minimum number of valuation queries to compute
a function `f : α → β` over a semiring. Non-Archimedean analogue of circuit depth.
Bridge: connects Algebra/valuation_theory to Computation/complexity_classes. -/
class ValuationDepthMeasure (α : Type*) (β : Type*) [Semiring α] [Semiring β] where
  vdepth : (α → β) → ℕ
  vdepth_zero : vdepth (fun _ => 0) = 0
  vdepth_add : ∀ f g : α → β, vdepth (fun x => f x + g x) ≤ max (vdepth f) (vdepth g) + 1
  vdepth_mul : ∀ f g : α → β, vdepth (fun x => f x * g x) ≤ max (vdepth f) (vdepth g) + 1

namespace ValuationDepthMeasure
variable {α β : Type*} [Semiring α] [Semiring β] [ValuationDepthMeasure α β]

theorem vdepth_const_eq_zero : vdepth (fun (_ : α) => (0 : β)) = 0 := vdepth_zero

theorem vdepth_sum_le (f g : α → β) :
    vdepth (fun x => f x + g x) ≤ max (vdepth f) (vdepth g) + 1 := vdepth_add f g

theorem vdepth_prod_le (f g : α → β) :
    vdepth (fun x => f x * g x) ≤ max (vdepth f) (vdepth g) + 1 := vdepth_mul f g

/-- Squaring: depth ≤ vdepth(f) + 1. Bridge: Computation/squaring ↔ Algebra/quadratics. -/
theorem vdepth_square_bound (f : α → β) :
    vdepth (fun x => f x * f x) ≤ vdepth f + 1 := by
  have := vdepth_mul f f; simp [max_self] at this; exact this

/-- Doubling: depth ≤ vdepth(f) + 1. -/
theorem vdepth_double_bound (f : α → β) :
    vdepth (fun x => f x + f x) ≤ vdepth f + 1 := by
  have := vdepth_add f f; simp [max_self] at this; exact this

/-- Triple sum: depth ≤ max₃ + 2. -/
theorem vdepth_triple_sum_bound (f g h : α → β) :
    vdepth (fun x => f x + g x + h x) ≤
-- ... (truncated, full file has 459 lines)
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


### Recent Discoveries in Catalog
No previous research cycles completed yet. This is a cold start — prioritize sorry_fill on the priority targets (CarmichaelComposite, Fib_gcd_identity) to close known open problems, or target cross-domain bridge theorems for novelty.


## v13 Depth Requirements -- First-Principles Grounding Engine

You are leading a mathematical research team. Your goal is to produce groundbreaking,
master-class, useful, novel, and marvelous new Mathematics that pushes the frontier of human knowledge.

This engine is configured for **First-Principles Grounding**. Focus on elegance, structural simplicity, and building blocks of deep theories.

### RESEARCH CORE METHODOLOGY:
1. **Foundational Clarity**: Build theories starting from clean, minimal, first-principles assumptions. Keep definitions mathematically pure, elegant, and simple.
2. **Lemma Factorization**: Decompose large, complex theorems into a hierarchy of beautiful, standalone, reusable lemmas. Each lemma should be a complete mathematical statement of independent interest.
3. **Explanatory Elegance**: Design proofs that are not only correct but structurally beautiful and easy to understand. Let the proofs explain the mathematical mechanism.

### DELIVERABLES:
- **Lean 4 proofs** of deep, non-trivial theorems with complete proofs (no sorry on main results).
- **Lab Notebook** comment blocks in each .lean file detailing Hypothesis, Result, Insight, and Failure analysis.
- **FUTURE_DIRECTIONS.md** outlining the Synthesis of your findings, a Results Summary, and 3-5 bold, falsifiable research directions to steer the next cycle.


## Output format reminder

Your output must include `.lean` files AND a `FUTURE_DIRECTIONS.md` file.
The .lean files contain the proofs. The FUTURE_DIRECTIONS.md contains 3-5
research conjectures that extend the work. Both are required.
Be precise, be deep, be world-class.
