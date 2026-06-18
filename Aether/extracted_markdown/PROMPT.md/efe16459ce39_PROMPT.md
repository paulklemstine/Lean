
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

**Title**: Tropical Jacobian via Reduced Laplacian Determinant and Néron Component Equivalence
**Domain**: Pythagorean
**Mathematical framing**: Let G be a finite connected graph with Laplacian L. One first proves structural lemmas: if L is symmetric and has row sums zero, then column sums are zero; constant vectors lie in ker L; deleting one row and column gives a reduced Laplacian L_red with det L_red >= 0. The central target is a precise equivalence between the finite abelian component group presented by coker(L_red) and the tropical Jacobian / critical group of G. A stronger theorem should show independence of the chosen deleted vertex up to canonical isomorphism. If existing divisor-group definitions are available, formulate the map explicitly and prove surjectivity/injectivity via principal divisors and Laplacian image. If not, define the minimal degree-zero divisor quotient needed for the equivalence. The computational corollary is Kirchhoff-style: the cardinality of the component group equals det L_red, yielding an executable invariant for small finite graphs and a bridge from linear algebra to tropical geometry.
**Concept description**: The key insight is that the unfinished Néron-component bridge in the Pythagorean/Tropical interface can be completed by turning the reduced graph Laplacian into a concrete computational invariant: its determinant controls the finite component group, while the row-sum-zero/symmetry package gives the canonical map from divisor classes to the tropical Jacobian. Why now: the catalog already contains the exact missing lemmas as priority sorries in `Pythagorean/TropicalBridge/NeronComponent/Theorems.lean`, and there is strong surrounding infrastructure in tropical divisor theory and graph/Laplacian formalization from the recent Baker-Norine line of work. The proposed project is to prove that for a finite connected graph, the reduced Laplacian is symmetric with nonnegative determinant, constants lie in the kernel of the full Laplacian, and the resulting cokernel/component-group object is equivalent to the tropical Jacobian defined from degree-zero divisors modulo principal divisors. This is not just sorry-filling: it upgrades an orphan bridge into an algorithmic pipeline computing the order of the tropical Jacobian from any chosen reduced Laplacian, giving a formal route from combinatorial graph data to a geometric Néron-component invariant.
**Novelty estimate**: 0.84
**Breakthrough potential**: 0.9
Research domain: Pythagorean
Research mode: sorry_fill


### Lean 4 Sketch
Complete `reducedLaplacian_symmetric`, `colSumZero_of_symmetric_rowSumZero`, `laplacian_ker_contains_constants`, `reducedLaplacian_det_nonneg`, and `componentGroup_equiv_tropicalJacobian` in `Pythagorean/TropicalBridge/NeronComponent/Theorems.lean`. Likely use `Matrix`, `LinearMap`, finitely supported functions or `Fin n -> ℤ`, quotient groups, and existing graph divisor infrastructure from tropical files.


### Catalog Context
@Pythagorean/TropicalBridge/NeronComponent/Theorems.lean
```lean
/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Néron Component Groups via Tropical Jacobians — Theorems

This file contains the main theorems connecting tropical Jacobians (reduced
Laplacian cokernels) to Néron component groups:

1. Symmetry, kernel, and basic properties of graph Laplacians
2. Positive semidefiniteness and nonneg determinant of reduced Laplacians
3. The arithmetic comparison principle (from axiomatized bridge)
4. Concrete computational examples (K₃, K₄, banana graphs)
5. Independence of the deleted vertex
6. Cardinality = |det| and SNF classification

## References

* Baker, M. "Specialization of linear systems from curves to graphs" (2008)
* Raynaud, M. "Spécialisation du foncteur de Picard" (1970)
-/

import Mathlib
import Pythagorean.TropicalBridge.NeronComponent.Defs

open Finset BigOperators Matrix

/-! ## Section 1: Basic Laplacian properties -/

/-- The reduced Laplacian of a symmetric matrix is symmetric. -/
theorem reducedLaplacian_symmetric {V : Type} [Fintype V] [DecidableEq V]
    (L : Matrix V V ℤ) (v0 : V) (hsym : Lᵀ = L) :
    (reducedLaplacian L v0)ᵀ = reducedLaplacian L v0 := by
  unfold reducedLaplacian; aesop

/-- Each column of a symmetric matrix with zero row sums also has zero column sums. -/
lemma colSumZero_of_symmetric_rowSumZero {V : Type} [Fintype V] [DecidableEq V]
    (L : Matrix V V ℤ) (hsym : Lᵀ = L) (hrow : ∀ v, ∑ w, L v w = 0)
    (w : V) : ∑ v, L v w = 0 := by
  rw [← hrow w]
  conv_rhs => rw [← hsym]
  rfl

/-- For a matrix with zero row sums, the constant vector is in the kernel. -/
lemma laplacian_ker_contains_constants {V : Type} [Fintype V] [DecidableEq V]
    (L : Matrix V V ℤ) (hrow : ∀ v, ∑ w, L v w = 0) (c : ℤ) :
    L.mulVec (Function.const V c) = 0 := by
  ext v; simp +decide [Matrix.mulVec, dotProduct, Finset.mul_sum _ _ _, hrow]
  rw [← Finset.sum_mul, hrow, MulZeroClass.zero_mul]

/-! ## Section 2: Positive semidefiniteness and nonneg determinant -/

/-
The determinant of the reduced Laplacian of a graph Laplacian is nonneg.
    This follows from PSD structure: x^T L x = ∑_{edges} w_{ij}(x_i - x_j)² ≥ 0.
    The proof lifts to ℝ, establishes PSD of the quadratic form,
    then uses that eigenvalues of PSD matrices are nonneg.
-/
lemma reducedLaplacian_det_nonneg
    (G : SemistableDualGraphData) (v0 : G.V) :
-- ... (truncated, full file has 265 lines)
```

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

@Geometry/BerggrenRamanujan.lean
```lean
import Mathlib

/-! # CatalogBuild.Pythagorean.Berggren.BerggrenRamanujan

Auto-generated from theorem catalog database.
Domain: Pythagorean/Berggren
Declarations: 59
-/

noncomputable section

/-- A direction in the ternary Berggren tree. -/
inductive BDir where
  | left  : BDir   -- B₁ branch
  | mid   : BDir   -- B₂ branch
  | right : BDir   -- B₃ branch
  deriving DecidableEq, Repr, Inhabited

/-- A position in the Berggren tree is a finite word over {left, mid, right}. -/
abbrev BPos := List BDir

/-- Apply a single Berggren step. -/
def berggrenStep (d : BDir) (t : ℤ × ℤ × ℤ) : ℤ × ℤ × ℤ :=
  let (a, b, c) := t
  match d with
  | .left  => (a - 2*b + 2*c, 2*a - b + 2*c, 2*a - 2*b + 3*c)
  | .mid   => (a + 2*b + 2*c, 2*a + b + 2*c, 2*a + 2*b + 3*c)
  | .right => (-a + 2*b + 2*c, -2*a + b + 2*c, -2*a + 2*b + 3*c)

/-- The Pythagorean triple at a given position (path applied left-to-right from root). -/
def berggrenAt (path : BPos) : ℤ × ℤ × ℤ :=
  path.foldl (fun t d => berggrenStep d t) (3, 4, 5)

/-- Each Berggren step preserves the Pythagorean equation. -/
theorem berggrenStep_preserves_pyth (d : BDir) (a b c : ℤ)
    (h : a ^ 2 + b ^ 2 = c ^ 2) :
    let (a', b', c') := berggrenStep d (a, b, c)
    a' ^ 2 + b' ^ 2 = c' ^ 2 := by
  cases d <;> simp [berggrenStep] <;> nlinarith [sq_nonneg (a - b), sq_nonneg (a + b)]

/-- Every position in the Berggren tree yields a Pythagorean triple. -/
theorem berggrenAt_pyth (path : BPos) :
    let (a, b, c) := berggrenAt path
    a ^ 2 + b ^ 2 = c ^ 2 := by
  simp only [berggrenAt]
  suffices h : ∀ (t : ℤ × ℤ × ℤ), t.1 ^ 2 + t.2.1 ^ 2 = t.2.2 ^ 2 →
    let r := path.foldl (fun t d => berggrenStep d t) t
    r.1 ^ 2 + r.2.1 ^ 2 = r.2.2 ^ 2 from
    h (3, 4, 5) (by norm_num)
  intro t ht
  induction path generalizing t with
  | nil => exact ht
  | cons d ds ih =>
    simp only [List.foldl]
    apply ih
    exact berggrenStep_preserves_pyth d t.1 t.2.1 t.2.2 ht

/-- Berggren matrix B₁. -/
def berggrenB₁ : Matrix (Fin 3) (Fin 3) ℤ :=
  !![1, -2, 2; 2, -1, 2; 2, -2, 3]
-- ... (truncated, full file has 316 lines)
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
