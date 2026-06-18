
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

**Title**: Berggren-tree lattice reduction as a terminating factorization descent
**Domain**: Bridges
**Mathematical framing**: Define a subtype of primitive Pythagorean triples using `IsPythag` plus coprimality/parity conditions. Use `evalWord` and generator actions from the cryptography file to define the reachable-state map from words to triples. Introduce a measure `μ` on primitive triples, preferably natural-valued, and prove: (1) root minimality: `μ rootTriple` is minimal; (2) predecessor existence: every non-root primitive triple has some inverse generator step to a primitive triple with strictly smaller `μ`; (3) noetherianity/termination of repeated reduction; (4) uniqueness of reduced word or at least uniqueness of normal form triple-to-word decomposition; (5) quantitative bound `path_length ≤ f(c)` for hypotenuse `c`. Then package the descent as an algorithmic reduction object and prove soundness/completeness of the pipeline. The bridge to cryptography is that the reduction path acts like a certified lattice-reduction transcript; the bridge to geometry/algebra is via Lorentz-form preservation. A secondary theorem could show that generator actions preserve `lorentzQ = 0` and primitive status, making the entire search space an invariant cone with canonical coordinates.
**Concept description**: The key insight is that the Berggren tree on primitive Pythagorean triples can be turned into a concrete descent invariant for lattice reduction, yielding a provable search pipeline from geometric words to arithmetic divisibility certificates. Why now: the catalog already contains the exact ingredients on both sides — `Algebra/BerggrenLorentz/Core.lean` gives the Lorentz/Pythagorean algebraic core (`lorentzForm`, `lorentzQ`, `IsPythag`), while `Cryptography/BerggrenLatticeReduction.lean` provides executable word actions (`actGen`, `rootTriple`, `evalWord`). This makes it tractable to prove new bridge theorems rather than invent new infrastructure. Concretely, study the monoid action of Berggren generators on triples and define an arithmetic complexity measure (for example hypotenuse size, Lorentz norm monotonicity, or a lexicographic pair built from coordinates) under which every non-root primitive triple admits a predecessor with strictly smaller measure. Then prove a reconstruction theorem: every primitive triple has a unique reduction path to `rootTriple`, and every such path induces an algorithmic certificate recovering a factorization-relevant decomposition of associated quadratic expressions such as `c^2 - a^2 = b^2` and `c^2 - b^2 = a^2`. The bridge claim is that geometric reduction in the Berggren tree can be formalized as a cryptographic-style reduction system whose termination and uniqueness give canonical normal forms for search states. A strong target theorem is a normal-form equivalence between words modulo action equality and primitive triples modulo equality, together with explicit descent bounds on path length in terms of the hypotenuse. This is falsifiable: uniqueness, strict descent, or the bound may fail and must be proved carefully. If successful, it would open the gravitational/cryptographic arc by replacing heuristic Berggren search with a certified reduction algorithm.
**Novelty estimate**: 0.87
**Breakthrough potential**: 0.9
Research domain: Bridges
Research mode: prove


### Lean 4 Sketch
Create `Bridges/BerggrenReductionDescent.lean` importing `Algebra/BerggrenLorentz/Core` and `Cryptography/BerggrenLatticeReduction`. Define primitive triple structure, word action lemmas, inverse-step candidates, measure, and normalization theorem. Likely prove preservation lemmas first, then strict-descent theorem, then `WellFounded` recursion for normalization.


### Catalog Context
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

@Cryptography/BerggrenLatticeReduction.lean
```lean
import Mathlib

/-!
# Berggren-Tree Lattice Reduction and Shortest-Word Rigidity

## Overview

We formalize prefix-rigidity theorems for the positive Berggren semigroup
acting on primitive Pythagorean triples. The Berggren tree is viewed as a
**noncommutative geometric code**: words whose images are close must share structure.

## Word convention

A word `[g₁, g₂, ..., gₙ]` evaluates as `g₁(g₂(...(gₙ(root))...))`.
The **suffix** of a word (tail end) represents generators applied first (near root).
The **prefix** (head) represents the outermost generators.
Extending a tree path deeper means **prepending** to the word.

## Main Results

* `evalWord_append` — prefix factorization of evaluation
* `height_lower_bound_length` — height grows linearly with word length
* `evalAtRoot_injective` — evaluation is injective (freeness)
* `first_letter_divergence` — distinct first letters ⟹ positive distance
* `prefix_rigidity_exact` — geoDist = 0 ⟺ same word
* `candidateWordSet_finite` — candidate sets are finite
* `prune_prepend_sound` — sound branch-and-bound pruning
* `finite_nearby_words` — finite ambiguity at bounded distance
-/

set_option linter.unusedVariables false
set_option linter.unusedTactic false

/-! ## Section 1: Core Definitions -/

/-- The three Berggren generators. -/
inductive BerggrenGen : Type
  | A  -- Left branch (B₁)
  | B  -- Middle branch (B₂)
  | C  -- Right branch (B₃)
  deriving DecidableEq, Repr

instance : Fintype BerggrenGen where
  elems := {.A, .B, .C}
  complete x := by cases x <;> simp

/-- A Berggren word is a list of generators. -/
abbrev BerggrenWord := List BerggrenGen

/-- A triple of integers. -/
abbrev Triple := ℤ × ℤ × ℤ

/-- Action of a single Berggren generator on a triple. -/
def actGen (g : BerggrenGen) (t : Triple) : Triple :=
  match g, t with
  | .A, (a, b, c) => (a - 2*b + 2*c, 2*a - b + 2*c, 2*a - 2*b + 3*c)
  | .B, (a, b, c) => (a + 2*b + 2*c, 2*a + b + 2*c, 2*a + 2*b + 3*c)
  | .C, (a, b, c) => (-a + 2*b + 2*c, -2*a + b + 2*c, -2*a + 2*b + 3*c)

/-- The root triple (3, 4, 5). -/
-- ... (truncated, full file has 511 lines)
```

@EML/LatticeTreeCorrespondence.lean
```lean
import Mathlib

/-! # CatalogBuild.Pythagorean.TreeFactoring.LatticeTreeCorrespondence

Auto-generated from theorem catalog database.
Domain: Pythagorean/TreeFactoring
Declarations: 48
-/

/-- Berggren 2×2 matrix M₁ ∈ SL(2,ℤ) -/
def berggren_M₁' : Matrix (Fin 2) (Fin 2) ℤ := !![2, -1; 1, 0]

/-- Berggren 2×2 matrix M₃ ∈ SL(2,ℤ) -/
def berggren_M₃' : Matrix (Fin 2) (Fin 2) ℤ := !![1, 2; 0, 1]

/-- M₁ inverse -/
def berggren_M₁_inv' : Matrix (Fin 2) (Fin 2) ℤ := !![0, 1; -1, 2]

/-- M₃ inverse -/
def berggren_M₃_inv' : Matrix (Fin 2) (Fin 2) ℤ := !![1, -2; 0, 1]

/-- [Section: # CatalogBuild.Pythagorean.TreeFactoring.LatticeTreeCorrespondence
Auto-generated from theorem catalog database.
Domain: Pythagorean/TreeFactoring
Declarations: 48] -/
theorem berggren_M₁'_det : Matrix.det berggren_M₁' = 1 := by
  simp [berggren_M₁', Matrix.det_fin_two]

/-- [Section: # CatalogBuild.Pythagorean.TreeFactoring.LatticeTreeCorrespondence
Auto-generated from theorem catalog database.
Domain: Pythagorean/TreeFactoring
Declarations: 48] -/
theorem berggren_M₃'_det : Matrix.det berggren_M₃' = 1 := by
  simp [berggren_M₃', Matrix.det_fin_two]

theorem berggren_M₁'_mul_inv :
    berggren_M₁' * berggren_M₁_inv' = (1 : Matrix (Fin 2) (Fin 2) ℤ) := by
  ext i j; fin_cases i <;> fin_cases j <;>
    simp [berggren_M₁', berggren_M₁_inv', Matrix.mul_apply, Fin.sum_univ_two]

theorem berggren_M₃'_mul_inv :
    berggren_M₃' * berggren_M₃_inv' = (1 : Matrix (Fin 2) (Fin 2) ℤ) := by
  ext i j; fin_cases i <;> fin_cases j <;>
    simp [berggren_M₃', berggren_M₃_inv', Matrix.mul_apply, Fin.sum_univ_two]

/-- **Lattice-Tree Correspondence, Part 1**: M₃⁻¹ is the subtraction step.
M₃⁻¹ · (m, n) = (m - 2n, n), corresponding to the continued fraction
quotient step in Gauss's algorithm. -/
theorem lattice_tree_correspondence_M₃ (m n : ℤ) :
    berggren_M₃_inv'.mulVec ![m, n] = ![m - 2 * n, n] := by
  ext i; fin_cases i <;>
    simp [berggren_M₃_inv', Matrix.mulVec, dotProduct, Fin.sum_univ_two] <;> ring

/-- **Lattice-Tree Correspondence, Part 2**: M₁⁻¹ is the swap step.
M₁⁻¹ · (m, n) = (n, 2n - m), corresponding to the basis exchange
step in Gauss's algorithm. -/
theorem lattice_tree_correspondence_M₁ (m n : ℤ) :
    berggren_M₁_inv'.mulVec ![m, n] = ![n, 2 * n - m] := by
  ext i; fin_cases i <;>
    simp [berggren_M₁_inv', Matrix.mulVec, dotProduct, Fin.sum_univ_two] <;> ring
-- ... (truncated, full file has 289 lines)
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
