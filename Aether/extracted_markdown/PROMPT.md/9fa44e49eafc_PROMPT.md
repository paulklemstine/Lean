
            ## PHASE A: LEAN 4 ONLY — DOING THE MATH

            You are a world-class mathematician. Your ONLY job in this cycle is
to produce **new Lean 4 code that extends the frontier of mathematics**.

            ### DELIVERABLES (strict — only this):
            1. **lean files (count chosen by the Plan)**
            2. **2-4 theorems with correct proofs (sorry = 0 on main results)**
            3. **Brief proof sketches** as `-- !-- comment -- !--` blocks (1-2 sentences each)
            4. **A FUTURE_DIRECTIONS.md file** listing 3-5 testable, falsifiable
               conjectures as a freeform narrative (NOT a form). Each direction MUST
               include a "The key insight is..." sentence and a "Why now?" justification.
               This file drives the next research cycle — make it count.

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


## Concept

**Title**: Tropical canonical forms induce finite Karchmer–Wigderson protocols for max-plus piecewise-affine maps
**Domain**: Bridges
**Mathematical framing**: Define a finite tropical/max-plus piecewise-affine map `f` by a finite family of affine pieces `p_i`. For an input pair `(x,y)` with `f x < f y` or with different argmin/argmax witnesses, define the communication relation asking for an index `i` whose affine evaluation distinguishes the two sides in a way implying the output inequality. Prove: (1) existence of an active witness index from the canonical representation; (2) correctness of a protocol obtained by recursively partitioning the finite index set; (3) leaf validity and membership in `leafLabels`; (4) depth bounds from the recursion scheme; and ideally (5) invariance under equivalent canonical forms. The theorem should connect tropical evaluation lemmas to protocol semantics, producing an executable synthesis procedure from canonical tropical data to a valid KW-style tree.
**Concept description**: The key insight is that the unfinished tropical canonical representation machinery can be turned into an explicit communication/decision protocol: once a max-plus piecewise-affine function is written as a finite minimum of affine pieces, disagreements between two inputs can be certified by the first affine piece on which their evaluations separate, yielding a structurally canonical Karchmer–Wigderson-style protocol tree. Why now: the catalog already contains the missing ingredients in near-final form on both sides — tropical affine pieces and evaluation in `Tropical/Canonical/Basic.lean`, and protocol-tree semantics in `Bridges/KarchmerWigderson.lean` — while recent successful work on tropical geometry of neural-network decision regions shows this bridge is mathematically meaningful rather than cosmetic. The proposed direction is to prove a concrete bridge theorem: for a finite tropical polynomial or finite max-plus piecewise-affine map represented by a list of affine pieces, one can algorithmically construct a finite protocol whose leaves are labeled by separating pieces, and whose correctness implies a depth upper bound in terms of the number of canonical pieces. This is not the in-flight tropical Karchmer–Wigderson project for arbitrary decision functions; it is a narrower and more formalization-ready theorem specialized to canonical tropical representations, with a reconstruction algorithm from piece data to protocol data. A falsifiable target is that the protocol depth is bounded by the logarithm of the number of distinct active affine pieces under a balanced splitter construction, or at minimum by the piece count under a simple linear search construction, together with a soundness theorem that every leaf label certifies output separation. If successful, this creates a new Algebra/Tropical-to-Bridges pipeline: canonicalization of tropical expressions, extraction of separating witnesses, and certified protocol synthesis.
**Novelty estimate**: 0.87
**Breakthrough potential**: 0.9
Research domain: Bridges
Research mode: prove


### Lean 4 Sketch
Bridge the sorry targets `Tropical/Canonical/Basic.lean` and `Bridges/KarchmerWigderson.lean` by first finishing basic affine-piece evaluation lemmas, then define a specialized protocol generator for finite lists of `AffinePiece`, and prove `isValid`, `run_mem_leafLabels`, and a depth bound for the generated tree.


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

@Bridges/KarchmerWigderson.lean
```lean
/-
# Karchmer–Wigderson Pipeline for Monotone st-Connectivity

This file formalizes the Karchmer–Wigderson (KW) communication game framework,
proves a generic transfer theorem from monotone formulas to KW protocols,
establishes a communication lower bound for st-connectivity, and packages
the result as a circuit depth lower bound via the existing catalog witness interface.

## Main Results

1. **Generic KW Transfer**: Any monotone formula of depth d yields a valid KW protocol
   of depth d. Contrapositive: formula depth ≥ KW communication complexity.
2. **STConn Monotonicity**: The st-connectivity predicate is monotone on edge sets.
3. **KW Communication Lower Bound**: The monotone KW communication complexity of
   st-connectivity on n-vertex path graphs is at least ⌊log₂(n-1)⌋.
4. **Circuit Depth Transfer**: Via the FormulaDepthLowerBoundWitness interface,
   the communication lower bound transfers to a monotone circuit depth lower bound.

## Architecture

The pipeline is:
  hard combinatorial object → communication lower bound → formula depth witness → circuit lower bound

This demonstrates a reusable formal methodology for certified lower-bound engineering.
-/
import Mathlib
import Catalog.Pythagorean.MonotoneCircuitComplexity

open Finset

/-! ## Part 1: KW Protocol Definitions -/

/-- A deterministic communication protocol for the monotone Karchmer–Wigderson game.
    - `leaf i`: output variable index `i` with no communication.
    - `aliceNode strat l r`: Alice sends one bit (strat applied to her input x).
      If `strat x = false`, proceed to `l`; if `true`, proceed to `r`.
    - `bobNode strat l r`: Bob sends one bit (strat applied to his input y).
      If `strat y = false`, proceed to `l`; if `true`, proceed to `r`. -/
inductive KWProtocol (α : Type) where
  | leaf (i : α) : KWProtocol α
  | aliceNode (strat : (α → Bool) → Bool) (left right : KWProtocol α) : KWProtocol α
  | bobNode (strat : (α → Bool) → Bool) (left right : KWProtocol α) : KWProtocol α

namespace KWProtocol

variable {α : Type}

/-- Run the protocol given Alice's input `x` and Bob's input `y`. Returns the
    variable index at the reached leaf. -/
def run : KWProtocol α → (α → Bool) → (α → Bool) → α
  | leaf i, _, _ => i
  | aliceNode strat l r, x, y => if strat x then r.run x y else l.run x y
  | bobNode strat l r, x, y => if strat y then r.run x y else l.run x y

/-- Communication depth of the protocol (longest root-to-leaf path). -/
def depth : KWProtocol α → ℕ
  | leaf _ => 0
  | aliceNode _ l r => 1 + max l.depth r.depth
  | bobNode _ l r => 1 + max l.depth r.depth

-- ... (truncated, full file has 327 lines)
```


### Recent Discoveries in Catalog
No previous research cycles completed yet. This is a cold start — prioritize sorry_fill on the priority targets (CarmichaelComposite, Fib_gcd_identity) to close known open problems, or target cross-domain bridge theorems for novelty.


## v7 Depth Requirements — Structured Proofs with Completeness Gates

You are producing Lean 4 code on the mathematical frontier. Your output must
be COMPILABLE and your proofs must be COMPLETE. A single correct proof of a
non-trivial result is worth more than 5 theorems with `sorry`.

### STEP 1: THEOREM DECLARATIONS (required — before any code)

List every theorem you intend to prove. For each, state:
- **Name**: The Lean declaration name
- **Statement**: One-sentence informal statement
- **Status**: `proved` | `conjecture` | `proved_with_lemma_sorry`
- **Why non-trivial**: One sentence on the key mathematical insight

Example:
1. `cantorPairing_surjective`: Cantor pairing is surjective — proved — constructive inverse
2. `cantorPairing_injective`: Cantor pairing is injective — proved — diagonal argument
3. `cantorPairing_bijection`: Cantor pairing is a bijection — proved_with_lemma_sorry — follows from 1+2

### STEP 2: PROVE THEOREMS (completeness gate)

Every theorem declared as `proved` MUST have a complete, compiling Lean proof.
No `sorry` on the main result. If you cannot complete a proof, change its status
to `conjecture` or `proved_with_lemma_sorry` and explain why.

For `proved_with_lemma_sorry`:
- The theorem statement must be complete (no sorry in the statement)
- `sorry` is allowed ONLY in supporting lemmas, never the main proof
- A comment must explain what the sorry replaces and why it's deferred

For your BEST theorem, also provide:
- A generalization or strengthening (can use sorry if proving would take too long)
- A boundary case or counterexample showing where the result fails

### STEP 3: Anti-patterns (reject these)

These tactics indicate trivial proofs:
- `native_decide` / `decide` / `norm_num` / `rfl` — unless genuinely proving a numeric fact
- `simp only []` with no simp set specified
- `sorry` on any theorem declared as `proved`

`omega`, `linarith`, and `Aesop` are fine for supporting lemmas.
`sorry` is fine for conjectures and generalizations.

### STEP 4: Novelty

Your theorems must be genuinely new. If a statement appears in a textbook,
generalize it. If you cannot formalize a concept rigorously, pick a different topic.

### Output format

Your output must include:
1. `.lean` files with the proofs (structured as declared in Step 1)
2. `FUTURE_DIRECTIONS.md` with 3-5 research conjectures extending the work

Both are required. Missing FUTURE_DIRECTIONS.md = automatic quality penalty.


## Output format reminder

Your output must include `.lean` files AND a `FUTURE_DIRECTIONS.md` file.
The .lean files contain the proofs. The FUTURE_DIRECTIONS.md contains 3-5
research conjectures that extend the work. Both are required.
Be precise, be deep, be world-class.
