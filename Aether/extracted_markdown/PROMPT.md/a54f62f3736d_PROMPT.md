
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

**Title**: Tropical Polynomial Canonical Forms and Newton Polytope Classification
**Domain**: Tropical
**Mathematical framing**: Define a tropical polynomial p : ℝⁿ → ℝ_{trop} as p(x) = ⨁_{α ∈ A} c_α ⊗ x^α = max_{α ∈ A}(c_α + ⟨α, x⟩) where A ⊂ ℕⁿ is finite and c_α ∈ ℝ ∪ {-∞}. An affine piece (c_α, α) is irredundant if ∃ x₀ ∈ ℝⁿ such that c_α + ⟨α, x₀⟩ > c_β + ⟨β, x₀⟩ for all β ≠ α. The canonical form canon(p) is p restricted to its irredundant affine pieces. Theorem 1 (Canonical Uniqueness): If p and q are tropical polynomials with p(x) = q(x) for all x, then canon(p) = canon(q). Theorem 2 (Newton Polytope Classification): The Newton polytope Newt(p) = conv({(α, c_α) : α ∈ A, c_α > -∞}) determines canon(p) uniquely — specifically, canon(p) consists exactly of the upper-hull vertices of Newt(p). Theorem 3 (Domain Poset Isomorphism): The face lattice of Newt(p) is isomorphic to the poset of tropical domains of linearity of p, ordered by inclusion. Corollary: The number of distinct affine regions of p equals the number of vertices of Newt(p).
**Concept description**: The key insight is that every tropical polynomial has a unique canonical form as a maximum of irredundant affine pieces, and this canonical form is completely determined by the Newton polytope — the convex hull of exponent vectors weighted by their coefficients. Two tropical polynomials are tropically equivalent (agree everywhere) if and only if their canonical forms are identical, which holds if and only if their Newton polytopes coincide with matching vertex data. This 'Fundamental Theorem of Tropical Algebra' provides a combinatorial fingerprint that classifies tropical polynomials up to tropical equivalence, and the face lattice of the Newton polytope is isomorphic to the poset of tropical domains of linearity. Why now: The Tropical/Canonical/Basic.lean file has 6 open sorries defining AffinePiece, TropicalPoly, and their evaluation functions — closing these foundational gaps and proving the canonical form theorem unlocks the entire tropical polynomial infrastructure for subsequent research. The Newton polytope bridge connects Tropical algebraic geometry to polyhedral combinatorics in the Algebra and Bridges domains, creating a structural bridge that currently does not exist in the catalog.
**Novelty estimate**: 0.72
**Breakthrough potential**: 0.78
Research domain: Tropical
Research mode: formalize


### Lean 4 Sketch
-- Close the 6 sorries in Tropical/Canonical/Basic.lean first
-- Then prove canonical form uniqueness

def IsIrredundant {n : ℕ} (p : TropicalPoly n) (α : Fin n → ℕ) : Prop :=
  ∃ x : Fin n → ℝ, ∀ β ∈ p.support, β ≠ α → p.coeff α + ∑ i, α i * x i > p.coeff β + ∑ i, β i * x i

def canonicalForm {n : ℕ} (p : TropicalPoly n) : TropicalPoly n :=
  ⟨p.support.filter (IsIrredundant p), p.coeff, by ...⟩

theorem canonical_unique {n : ℕ} {p q : TropicalPoly n}
  (h : ∀ x, p.eval x = q.eval x) :
  canoni


### Catalog Context
@Tropical/Canonical/Basic.lean
```lean
import Mathlib

/-!
# Tropical Canonical Forms for Univariate Piecewise-Linear Functions

This file establishes a **canonical tropical-rational normal form** for univariate
continuous piecewise-linear (CPL) functions, and uses it to give a certified
decision procedure for exact functional equivalence.

## Main definitions

* `AffinePiece` — a pair (slope, intercept) defining `x ↦ slope * x + intercept`
* `TropicalPoly` — a nonempty list of affine pieces; evaluates as their pointwise maximum
* `TropicalRat` — a pair of tropical polynomials; evaluates as their difference
* `TropicalPoly.Canonical` — sorted by strictly increasing slope, every term strictly essential

## Main results

* `tropical_poly_eval_continuous` — evaluation of a tropical polynomial is continuous
* `tropical_rational_eq_iff_crossmul` — cross-multiplication criterion for rational equality
* `canonical_tropical_poly_unique` — canonical tropical polynomials with equal eval are equal
* `relu_network_has_canonical_tropical_rational` — every univariate ReLU network
  has a unique canonical tropical-rational form
-/

open scoped Topology

noncomputable section

/-! ## Affine Pieces -/

/-- An affine piece represents a function `x ↦ slope * x + intercept`. -/
@[ext]
structure AffinePiece where
  slope : ℝ
  intercept : ℝ

/-- Evaluation of an affine piece. -/
def AffinePiece.eval (p : AffinePiece) (x : ℝ) : ℝ :=
  p.slope * x + p.intercept

@[simp]
theorem AffinePiece.eval_def (p : AffinePiece) (x : ℝ) :
    p.eval x = p.slope * x + p.intercept := rfl

/-! ## Tropical Polynomials -/

/-- A tropical polynomial is a nonempty list of affine pieces.
    Its evaluation is the pointwise maximum of the affine pieces. -/
structure TropicalPoly where
  terms : List AffinePiece
  nonempty : terms ≠ []

/-- Evaluate a tropical polynomial at a point as the maximum of all affine pieces. -/
def TropicalPoly.eval (P : TropicalPoly) (x : ℝ) : ℝ :=
  match P.terms, P.nonempty with
  | t :: ts, _ => ts.foldl (fun acc p => max acc (p.eval x)) (t.eval x)

/-- A single-term tropical polynomial. -/
def TropicalPoly.single (a : AffinePiece) : TropicalPoly where
-- ... (truncated, full file has 591 lines)
```

@Bridges/AlgebraEMLReconstruction.lean
```lean
/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license.

# Algebraic–EML Tannaka Reconstruction via Closure Endomorphism Monoids

This file formalizes a reconstruction principle: a finitary closure operator on a
set is completely determined by its closed-set lattice, and hence by any
data (such as an endomorphism monoid) that determines that lattice. This bridges:
- **Algebraic lattice theory** / closure operators
- **Semiring and endomorphism algebra**
- **EML / Lawvere-style fixed-point semantics**
- **Post-quantum lattice cryptography** (separator hardness)

## Main results

* `closure_subset_closed_of_subset` — closed sets absorb closures of subsets
* `compactClosed_closed` — compact-closed sets are closed
* `algebraicLike_finite_witness` — finitary closures have finite witnesses
* `closure_eq_sInf_closed_eq` — closure = infimum of closed supersets
* `reconstructsClosure_empty` — reconstruction from closed sets (empty monoid)
* `closure_eq_of_sameClosedSets` — **Tannaka uniqueness**: closures with
  the same closed-set lattice must be equal
* `closure_eq_of_endMonoid_eq` — endomorphism monoid + separator → equal closures
* `closure_pointwise_quantum_reconstruction` — pointwise membership corollary
* `lipschitz_certified_robustness_identity` — identity is 1-Lipschitz on set distance
* `post_quantum_lattice_separator_bound` — finite separator orbit bound

## References

Inspired by Tannakian reconstruction in representation theory, adapted to
closure dynamics in the spirit of Lawvere's fixed-point semantics.
-/

import Mathlib

open Function Set Classical

noncomputable section

namespace Bridges.AlgebraEMLReconstruction

/-! ## Section 1: Basic Closure Operator -/
section BasicClosure

/-- A set-level closure operator: extensive, monotone, idempotent. -/
structure SetClosureOperator (α : Type*) where
  toFun : Set α → Set α
  extensive : ∀ s, s ⊆ toFun s
  monotone : Monotone toFun
  idempotent : ∀ s, toFun (toFun s) = toFun s

instance {α : Type*} : CoeFun (SetClosureOperator α) (fun _ => Set α → Set α) :=
  ⟨SetClosureOperator.toFun⟩

@[simp] theorem SetClosureOperator.coe_apply {α : Type*} (cl : SetClosureOperator α)
    (s : Set α) : cl.toFun s = cl s := rfl

/-- A set is closed under `cl` if applying `cl` leaves it unchanged. -/
def ClosedSet {α : Type*} (cl : SetClosureOperator α) (s : Set α) : Prop :=
-- ... (truncated, full file has 575 lines)
```

@Bridges/ArrowCurvature/Defs.lean
```lean
import Mathlib

/-!
# Arrow's Theorem as Curvature of Preference Space

We formalize the connection between Arrow's impossibility theorem and the
geometry of preference aggregation. The central insight: Condorcet cycles
in majority voting correspond to *holonomy* (curvature) in the space of
preference profiles.

## Main Definitions

* `Tournament` — A complete asymmetric binary relation (majority tournament)
* `PreferenceProfile` — A collection of voter strict-order preferences
* `MajorityTournament` — The tournament induced by majority rule
* `SinglePeaked` — The single-peaked domain restriction
* `CondorcetCurvature` — Numerical curvature measuring cycle strength

## Main Results

* `tournament_trans_iff_no_3cycle` — Tournament transitivity ↔ no 3-cycle
* `single_peaked_majority_transitive` — Black's theorem: single-peaked ⟹ transitive majority
* `curvature_zero_iff_no_majority_cycle` — Zero curvature ↔ transitive majority
* `positive_curvature_obstruction` — Positive curvature implies existence of cycles
-/

open Finset Function

/-! ## Part I: Tournament Theory -/

/-- A tournament on `Fin n`: a complete, irreflexive, asymmetric relation.
    This models the majority relation in voting theory. -/
structure Tournament (n : ℕ) where
  /-- `beats a b` means `a` defeats `b` in pairwise comparison -/
  beats : Fin n → Fin n → Prop
  [beatsDecidable : DecidableRel beats]
  beats_irrefl : ∀ a, ¬beats a a
  beats_complete : ∀ a b, a ≠ b → beats a b ∨ beats b a
  beats_asymm : ∀ a b, beats a b → ¬beats b a

attribute [instance] Tournament.beatsDecidable

namespace Tournament

variable {n : ℕ} (T : Tournament n)

/-- A tournament is transitive -/
def IsTransitive : Prop :=
  ∀ a b c : Fin n, T.beats a b → T.beats b c → T.beats a c

/-- A tournament has a 3-cycle (Condorcet cycle) -/
def Has3Cycle : Prop :=
  ∃ a b c : Fin n, T.beats a b ∧ T.beats b c ∧ T.beats c a

/-- The number of directed 3-cycles (curvature count) -/
noncomputable def cycleCount : ℕ :=
  ((Finset.univ (α := Fin n × Fin n × Fin n)).filter
    (fun ⟨a, b, c⟩ => T.beats a b ∧ T.beats b c ∧ T.beats c a)).card

end Tournament
-- ... (truncated, full file has 436 lines)
```

@Algebra/BerggrenLorentz/Core.lean
```lean
import Mathlib

/-!
# Berggren-Lorentz Monoid: Discrete Lorentz Symmetry of Pythagorean Triples

This file develops the theory of the **Berggren monoid** — the three-generator
submonoid of GL₃(ℤ) that acts on primitive Pythagorean triples via the
Berggren tree. We establish:

1. All three generators preserve the Lorentzian quadratic form Q(a,b,c) = a²+b²-c²,
   placing them in the integer orthogonal group O(2,1;ℤ).
2. Determinant computations showing orientation structure (two proper, one improper).
3. Pythagorean preservation: children of Pythagorean triples are Pythagorean.
4. Hypotenuse growth bounds giving O(log c) tree depth.
5. Trace structure, inverse matrices, and non-commutativity of generators.
6. Quadratic form identities and bilinear form theory.

## Bridge: Number Theory (Pythagorean triples) ↔ Physics (Lorentz group O(2,1;ℤ))
↔ Cryptography (monoid action hardness) ↔ ML (Lipschitz bounds via matrix norms)
-/

set_option maxHeartbeats 1600000

namespace BerggrenLorentz

/-! ## Section 1: Core Definitions -/

/-- The Lorentzian quadratic form Q(a,b,c) = a² + b² - c² on ℤ³.
    The light cone Q = 0 parametrizes Pythagorean triples.
    Bridge: connects number theory to physics (Minkowski metric). -/
def lorentzForm (v : Fin 3 → ℤ) : ℤ := v 0 ^ 2 + v 1 ^ 2 - v 2 ^ 2

/-- Scalar version of the Lorentz form for convenience. -/
def lorentzQ (a b c : ℤ) : ℤ := a ^ 2 + b ^ 2 - c ^ 2

/-- A triple (a,b,c) is Pythagorean iff it lies on the light cone Q = 0. -/
def IsPythag (a b c : ℤ) : Prop := a ^ 2 + b ^ 2 = c ^ 2

/-- The Berggren matrix A (first generator). -/
def matA : Matrix (Fin 3) (Fin 3) ℤ := !![1, -2, 2; 2, -1, 2; 2, -2, 3]

/-- The Berggren matrix B (second generator). -/
def matB : Matrix (Fin 3) (Fin 3) ℤ := !![1, 2, 2; 2, 1, 2; 2, 2, 3]

/-- The Berggren matrix C (third generator). -/
def matC : Matrix (Fin 3) (Fin 3) ℤ := !![-1, 2, 2; -2, 1, 2; -2, 2, 3]

/-- The Lorentz metric matrix Q_L = diag(1, 1, -1). -/
def metricQ : Matrix (Fin 3) (Fin 3) ℤ := !![1, 0, 0; 0, 1, 0; 0, 0, -1]

/-- Berggren child A: explicit coordinate formulas. -/
def childA (a b c : ℤ) : ℤ × ℤ × ℤ := (a - 2*b + 2*c, 2*a - b + 2*c, 2*a - 2*b + 3*c)

/-- Berggren child B: explicit coordinate formulas. -/
def childB (a b c : ℤ) : ℤ × ℤ × ℤ := (a + 2*b + 2*c, 2*a + b + 2*c, 2*a + 2*b + 3*c)

/-- Berggren child C: explicit coordinate formulas. -/
def childC (a b c : ℤ) : ℤ × ℤ × ℤ := (-a + 2*b + 2*c, -2*a + b + 2*c, -2*a + 2*b + 3*c)

/-- A word in the Berggren monoid: a finite sequence of generator indices. -/
-- ... (truncated, full file has 505 lines)
```

@Speculative/AutoResearch/TropicalHelly.lean
```lean
/-
Copyright (c) 2025. All rights reserved.
Released under Apache 2.0 license.
-/
import Mathlib

/-!
# Tropical Helly's Theorem — From Convexity to Optimization Duality

This file formalizes the foundations of tropical convexity in the max-plus semiring
and proves the tropical Helly theorem along with related results including
tropical Farkas-type lemmas and cross-domain connections.

## Main Definitions

* `IsTropConvex` — Tropical convexity in the max-plus semiring.
* `tropConvexHull` — The tropical convex hull: smallest tropically convex superset.
* `TropHalfspace` — A tropical halfspace: the max-plus analogue of a linear inequality.
* `TropicalNerve` — The nerve complex of a family of tropical convex sets.
* `TropicalFractionalHellyProp` — Falsifiable conjecture for tropical fractional Helly.

## Main Results

* `IsTropConvex.univ`, `.empty`, `.singleton` — Basic examples.
* `IsTropConvex.inter`, `.sInter`, `.iInter` — Closure under intersections.
* `tropConvexHull_isTropConvex`, `tropConvexHull_eq_self` — Hull properties.
* `tropHalfspace_isTropConvex` — Halfspaces are tropically convex.
* `tropConvex_dim1_interval` — Tropical convex sets in ℝ¹ are intervals.
* `tropLift_injective`, `tropLift_combination_bound` — Lifting to classical geometry.
* `tropical_farkas_weak` — Tropical Farkas lemma (weak form).
* `TropicalNerve.downward_closed` — Nerve is a simplicial complex.
* `tropical_helly` — The tropical Helly theorem (the main result).

## References

* Develin, M. and Sturmfels, B., "Tropical Convexity", 2004.
* Gaubert, S. and Katz, R.D., "The tropical analogue of polar cones", 2009.
-/

noncomputable section

open Set Finset BigOperators Classical

/-! ## Part 1: Tropical Convexity Foundations -/

/-- **Tropical convexity in the max-plus semiring.**
    A set S ⊆ ℝⁿ is tropically convex if for all x, y ∈ S and
    all coefficients s, t with max(s, t) = 0, the tropical combination
    i ↦ max(s + xᵢ, t + yᵢ) lies in S.

    The condition max(s, t) = 0 normalizes the tropical coefficients,
    analogous to requiring s + t = 1 in classical convex combinations. -/
def IsTropConvex {n : ℕ} (S : Set (Fin n → ℝ)) : Prop :=
  ∀ ⦃x y : Fin n → ℝ⦄, x ∈ S → y ∈ S →
    ∀ s t : ℝ, max s t = 0 → (fun i => max (s + x i) (t + y i)) ∈ S

/-- **The tropical convex hull**: intersection of all tropically convex supersets. -/
def tropConvexHull {n : ℕ} (T : Set (Fin n → ℝ)) : Set (Fin n → ℝ) :=
  ⋂₀ {S : Set (Fin n → ℝ) | IsTropConvex S ∧ T ⊆ S}

-- ... (truncated, full file has 431 lines)
```


### Recent Discoveries in Catalog
No previous research cycles completed yet. This is a cold start — prioritize sorry_fill on the priority targets (CarmichaelComposite, Fib_gcd_identity) to close known open problems, or target cross-domain bridge theorems for novelty.


## v8 Depth Requirements -- Research Team Protocol

You are leading a research team. Your team has different roles:
- The **Hypothesizer** generates bold, falsifiable conjectures
- The **Experimenter** proves or disproves them in Lean 4
- The **Analyst** examines what survived, what failed, and WHY
- The **Critic** searches for weaknesses, constructs counterexamples,
  and identifies where proofs might break down. A well-constructed
  counterexample is as valuable as a proof.
- The **Synthesist** upgrades the knowledge base and writes the
  FUTURE_DIRECTIONS.md that seeds the next cycle

You run this loop: **Hypothesize -> Experiment -> Analyze -> Critique -> Generalize -> Iterate**.
Each cycle is not a one-shot task. It is one iteration of an infinite
research process. Your notes (FUTURE_DIRECTIONS.md, Lab Notebooks,
proof sketches) determine whether the next team builds on your work
or starts over.

**Take good notes.** A cycle without useful notes is a wasted cycle.

### STEP 1: THEOREM DECLARATIONS (required -- before any code)

List every theorem you intend to prove or investigate. For each, state:
- **Name**: The Lean declaration name
- **Statement**: One-sentence informal statement
- **Status**: `hypothesis` | `conjecture` | `proved` | `proved_with_lemma_sorry` | `disproved`
- **Why it matters**: One sentence on what this result would mean if true,
  and what it would teach us if false

Example:
1. `cantorPairing_surjective`: Cantor pairing is surjective -- proved -- constructive inverse -- confirms decidability of Nat x Nat
2. `cantorPairing_injective`: Cantor pairing is injective -- proved -- diagonal argument -- confirms invertibility
3. `cantorPairing_bijection`: Cantor pairing is a bijection -- proved_with_lemma_sorry -- follows from 1+2 -- completing the characterization

Use `hypothesis` for statements you are not yet sure you can prove but
want to investigate. Use `conjecture` for statements you believe are true
but cannot prove in this cycle. Use `disproved` for statements where you
found a counterexample. Use `proved` for statements with complete Lean
proofs. Use `proved_with_lemma_sorry` when the main proof is complete but
one or more supporting lemmas use `sorry`.

### STEP 2: EXPERIMENT (prove or disprove in Lean 4)

Every theorem declared as `proved` MUST have a complete, compiling Lean proof.
No `sorry` on the main result. If you cannot complete a proof, change its
status to `conjecture` or `proved_with_lemma_sorry` and explain why.

For `proved_with_lemma_sorry`:
- The theorem statement must be complete (no sorry in the statement)
- `sorry` is allowed ONLY in supporting lemmas, never the main proof
- A comment must explain what the sorry replaces and why it is deferred

**Disproofs count.** If a hypothesis is false, prove its negation or
construct an explicit counterexample. A well-constructed counterexample
is as valuable as a proof. Change the status to `disproved` and state
the counterexample clearly.

### STEP 3: CRITIQUE (find the weaknesses)

For your best theorem, the Critic must:
- Identify the strongest assumption that could be weakened
- Construct a boundary case: where does the result break down?
- If possible, state a `conjecture` for the generalized version and
  explain what would need to change in the proof

This is NOT optional. A theorem without a critique is incomplete.

### STEP 4: Anti-patterns (reject these)

These tactics indicate trivial proofs:
- `native_decide` / `decide` / `norm_num` / `rfl` -- unless genuinely proving a numeric fact
- `simp only []` with no simp set specified
- `sorry` on any theorem declared as `proved`

`omega`, `linarith`, and `Aesop` are fine for supporting lemmas.
`sorry` is fine for conjectures, generalizations, and boundary cases.

### STEP 5: Novelty

Your theorems must be genuinely new. If a statement appears in a textbook,
generalize it. If you cannot formalize a concept rigorously, pick a different topic.

### STEP 6: TAKE GOOD NOTES (first-class deliverables)

Your notes determine what the next research team investigates. They are NOT
an afterthought. They are your most important output after the proofs themselves.

**6a. Lab Notebook** (in each .lean file, as `-- !-- Lab Notebook -- !--` blocks):

For each major theorem, include a Lab Notebook comment block:
```lean
-- !-- Lab Notebook: cantorPairing_bijection -- !--
-- !-- Hypothesis: Cantor pairing is bijective because both surjective and injective -- !--
-- !-- Result: Proved via composition of surjective and injective proofs -- !--
-- !-- Insight: The constructive inverse of surjectivity is key; diagonal argument handles injectivity -- !--
-- !-- Failure analysis: Initial attempt to prove bijection directly failed; decomposition into surjective+injective was necessary -- !--
-- !-- End Lab Notebook -- !--
```

**6b. FUTURE_DIRECTIONS.md** (MANDATORY — your output WILL BE REJECTED if missing):

You MUST produce a FUTURE_DIRECTIONS.md file with this EXACT structure.
Copy the section headers below verbatim. Do NOT use freeform prose.

## Synthesis

[2-3 paragraphs: what did this cycle discover? What failed and why? What
structural insight emerged? Tie the directions together into a narrative.]

## Results Summary

[For EACH theorem: name, status (proved/conjecture/disproved), one-sentence
significance. Format as a bullet list:]

- `theoremName`: status — one-sentence significance

## Research Directions

### Direction 1: [Concise title]
**Hypothesis**: A precise, falsifiable mathematical statement.
**Test**: What experiment (proof/disproof/computation) would confirm or refute it.
**Why now**: What from THIS cycle makes this tractable.
**If true**: What new territory this opens.
**If false**: What the failure teaches us.

[Repeat for 3-5 directions]

IMPORTANT: The ## Synthesis and ## Results Summary sections are NOT optional.
If your FUTURE_DIRECTIONS.md is missing either section, it will be treated as
incomplete and the next research team will have no context to build on your work.

### STEP 7: Generalization loop

For your BEST theorem, attempt one level of generalization:
- State a stronger version (can use sorry if proving would take too long)
- Identify the boundary: where does the result break down?
- If the generalization is itself interesting, mark it as a `conjecture`
  in your theorem declarations and explain it in FUTURE_DIRECTIONS.md

### Output format

Your output must include:
1. `.lean` files with proofs and Lab Notebook blocks (structured as declared in Step 1)
2. `FUTURE_DIRECTIONS.md` with Synthesis, Results Summary, and 3-5 research
   directions (structured as in Step 6b)

Both are required. A cycle with proofs but no Lab Notebook or
FUTURE_DIRECTIONS.md is a cycle where the next team starts from scratch.
Take good notes.


## Output format reminder

Your output must include `.lean` files AND a `FUTURE_DIRECTIONS.md` file.
The .lean files contain the proofs. The FUTURE_DIRECTIONS.md contains 3-5
research conjectures that extend the work. Both are required.
Be precise, be deep, be world-class.
