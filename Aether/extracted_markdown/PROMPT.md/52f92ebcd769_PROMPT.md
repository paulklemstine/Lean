## Assignment: Elliptic Curve Arithmetic: Group Law Formalization

**Mode:** prove

Build a formally verified Lean 4 theory of elliptic curve arithmetic over finite fields that goes substantially beyond a definitional encoding of the chord–tangent law. The target is not “points on a curve form a group” as a textbook exercise, but a machine-checked arithmetic-and-geometry bridge: explicit algebraic group law, verified scalar multiplication algorithm, and a formally meaningful route to Hasse-type counting bounds. Minimize `sorry`, and if a full classical Hasse proof is too large for one cycle, isolate and prove a nontrivial certified reduction theorem that turns Hasse’s bound into a finite, computable verification problem for concrete primes.

This project becomes genuinely field-opening if you do **all three layers**:

1. **Geometric layer:** formalize the chord–tangent group law in affine/projective coordinates with singularity exclusions made explicit.
2. **Algorithmic layer:** implement verified point addition / doubling / scalar multiplication and prove correctness against the abstract additive structure.
3. **Arithmetic layer:** connect the trace-of-Frobenius viewpoint to point counting, using the existing theorem  
   `hasse_bound_implies_group_order` from `FINAL/Computation/ResearchQuestions.lean` as a certified bridge from an abstract Hasse inequality to exact group-order bounds.

The breakthrough is not merely another elliptic-curve file. It is a reusable Lean infrastructure for **formal arithmetic geometry over finite fields**, with immediate implications for cryptography, computational number theory, and eventually formalized modularity/Frobenius theories.

---

## Core Theorem Targets

You must prove at least **3 deep theorems** with multi-step reasoning. At least one should use `field_simp`, one should use substantial `rcases`/case splitting, and one should use a nontrivial `calc` or contradiction argument.

### 1. Algebraic correctness of the explicit group law

Work over a finite field `K := ZMod p` with `Fact p.Prime`, and coefficients `a b : K` satisfying nonsingularity.

Define a new structure capturing a **nonsingular short Weierstrass model over a field**, if not already present in the catalog:

```lean
structure ShortWeierstrassModel (K : Type _) [Field K] where
  a : K
  b : K
  nonsingular : 4 * a^3 + 27 * b^2 ≠ 0
```

Define the point type with point at infinity:

```lean
inductive ECPoint (E : ShortWeierstrassModel K)
| infinity : ECPoint E
| affine (x y : K) (h : y^2 = x^3 + E.a * x + E.b) : ECPoint E
```

Then prove a theorem of the following shape:

```lean
theorem add_commutes_with_reflection
  {K : Type _} [Field K]
  (E : ShortWeierstrassModel K) :
  ∀ P Q : ECPoint E, ecAdd E P Q = ecAdd E Q P
```

and more importantly:

```lean
theorem add_assoc_generic
  {K : Type _} [Field K]
  (E : ShortWeierstrassModel K) :
  ∀ P Q R : ECPoint E,
    genericPosition E P Q R →
    ecAdd E (ecAdd E P Q) R = ecAdd E P (ecAdd E Q R)
```

where `genericPosition` is a **new definition** excluding the denominator-zero collision cases in the explicit slope formulas. This is a mathematically valuable innovation: instead of trying to brute-force total associativity immediately, first isolate the Zariski-open generic locus where the rational formulas are transparent.

Suggested Lean signature for the generic predicate:

```lean
def genericPosition
  {K : Type _} [Field K] (E : ShortWeierstrassModel K) :
  ECPoint E → ECPoint E → ECPoint E → Prop
```

Then, if feasible, extend to total associativity:

```lean
theorem add_assoc
  {K : Type _} [Field K]
  (E : ShortWeierstrassModel K) :
  ∀ P Q R : ECPoint E,
    ecAdd E (ecAdd E P Q) R = ecAdd E P (ecAdd E Q R)
```

This would be a genuine formalization milestone.

### 2. Verified scalar multiplication algorithm

Define a recursive double-and-add algorithm and prove correctness:

```lean
def smulPoint
  {K : Type _} [Field K]
  (E : ShortWeierstrassModel K) :
  ℕ → ECPoint E → ECPoint E
```

Target theorem:

```lean
theorem smulPoint_correct
  {K : Type _} [Field K]
  (E : ShortWeierstrassModel K) :
  ∀ n P, smulPoint E n P = n • P
```

where the right-hand side uses the additive commutative group structure once established, or an inductively defined repeated addition if full group structure is not yet available.

A stronger algorithmic theorem, highly desirable for cryptographic relevance:

```lean
theorem smulPoint_bit0
  {K : Type _} [Field K]
  (E : ShortWeierstrassModel K) (n : ℕ) (P : ECPoint E) :
  smulPoint E (2*n) P = ecDouble E (smulPoint E n P)
```

and similarly for odd scalars.

### 3. Frobenius / point-count bridge and Hasse reduction

You likely will not formalize the full Weil machinery in one cycle, so do something mathematically sharp and certifiable instead.

Define the point count:

```lean
def pointCount (p : ℕ) [Fact p.Prime]
  (E : ShortWeierstrassModel (ZMod p)) : ℕ
```

Define the Frobenius trace candidate:

```lean
def frobeniusTrace (p : ℕ) [Fact p.Prime]
  (E : ShortWeierstrassModel (ZMod p)) : ℤ :=
  (p : ℤ) + 1 - pointCount p E
```

Then prove the exact identity:

```lean
theorem pointCount_eq_p_add_one_sub_trace
  (p : ℕ) [Fact p.Prime]
  (E : ShortWeierstrassModel (ZMod p)) :
  (pointCount p E : ℤ) = p + 1 - frobeniusTrace p E
```

This alone is trivial if unfolded, so do **not** count it as one of the deep theorems. The deep theorem should be the certified reduction:

```lean
theorem hasse_reduction_via_trace
  (p : ℕ) [Fact p.Prime] (hp : 2 ≤ p)
  (E : ShortWeierstrassModel (ZMod p))
  (htrace : |frobeniusTrace p E| ≤ 2 * Int.sqrt p) :
  |(pointCount p E : ℤ) - p - 1| ≤ 2 * Int.sqrt p
```

Then use the catalog theorem:

```lean
hasse_bound_implies_group_order
```

from `FINAL/Computation/ResearchQuestions.lean` to derive a formally packaged corollary for elliptic curves:

```lean
theorem elliptic_group_order_from_hasse
  (p : ℕ) [Fact p.Prime] (hp : 2 ≤ p)
  (E : ShortWeierstrassModel (ZMod p))
  (htrace : |frobeniusTrace p E| ≤ 2 * Int.sqrt p) :
  ∃ a_p : ℤ, |a_p| ≤ 2 * Int.sqrt p ∧
    pointCount p E = p + 1 - a_p.natAbs
```

If the exact codomain mismatch with the existing theorem requires adjustment, produce the strongest correct reformulation. The key point is to **explicitly build on** `hasse_bound_implies_group_order`: use it as a certified arithmetic wrapper around your newly defined `frobeniusTrace`.

---

## Lean 4 Type Signature Targets

You should aim to realize statements close to the following signatures:

```lean
structure ShortWeierstrassModel (K : Type _) [Field K] where
  a : K
  b : K
  nonsingular : 4 * a^3 + 27 * b^2 ≠ 0
```

```lean
inductive ECPoint (E : ShortWeierstrassModel K)
| infinity : ECPoint E
| affine (x y : K) (h : y^2 = x^3 + E.a * x + E.b) : ECPoint E
```

```lean
def ecNeg {K : Type _} [Field K] (E : ShortWeierstrassModel K) :
  ECPoint E → ECPoint E
```

```lean
def ecAdd {K : Type _} [Field K] (E : ShortWeierstrassModel K) :
  ECPoint E → ECPoint E → ECPoint E
```

```lean
def genericPosition
  {K : Type _} [Field K] (E : ShortWeierstrassModel K) :
  ECPoint E → ECPoint E → ECPoint E → Prop
```

```lean
theorem ecAdd_left_identity
  {K : Type _} [Field K] (E : ShortWeierstrassModel K) :
  ∀ P, ecAdd E (ECPoint.infinity) P = P
```

```lean
theorem ecAdd_left_inv
  {K : Type _} [Field K] (E : ShortWeierstrassModel K) :
  ∀ P, ecAdd E (ecNeg E P) P = ECPoint.infinity
```

```lean
theorem add_assoc_generic
  {K : Type _} [Field K]
  (E : ShortWeierstrassModel K) :
  ∀ P Q R, genericPosition E P Q R →
    ecAdd E (ecAdd E P Q) R = ecAdd E P (ecAdd E Q R)
```

```lean
def smulPoint
  {K : Type _} [Field K]
  (E : ShortWeierstrassModel K) :
  ℕ → ECPoint E → ECPoint E
```

```lean
theorem smulPoint_correct
  {K : Type _} [Field K]
  (E : ShortWeierstrassModel K) :
  ∀ n P, smulPoint E n P = n • P
```

```lean
def pointCount (p : ℕ) [Fact p.Prime]
  (E : ShortWeierstrassModel (ZMod p)) : ℕ
```

```lean
def frobeniusTrace (p : ℕ) [Fact p.Prime]
  (E : ShortWeierstrassModel (ZMod p)) : ℤ
```

```lean
theorem hasse_reduction_via_trace
  (p : ℕ) [Fact p.Prime] (hp : 2 ≤ p)
  (E : ShortWeierstrassModel (ZMod p))
  (htrace : |frobeniusTrace p E| ≤ 2 * Int.sqrt p) :
  |(pointCount p E : ℤ) - p - 1| ≤ 2 * Int.sqrt p
```

---

## Proof Strategy Architecture

### Strategy A: Rational-function geometry on the generic locus
**Most promising for associativity.**

1. Define `genericPosition` so all slope denominators in the affine formulas are nonzero and all intermediate sums stay affine.
2. Expand both sides of  
   `ecAdd E (ecAdd E P Q) R = ecAdd E P (ecAdd E Q R)`  
   into rational expressions in coordinates.
3. Use `field_simp`, polynomial normalization, and the curve equations `y^2 = x^3 + ax + b` to reduce both sides to the same numerator identity.

Why this is promising: it localizes the hardest algebra to the open dense case where explicit formulas are valid, avoiding immediate projective-geometry overhead. In Lean, this also gives clear entry points for `rcases` on points and `field_simp` on denominator hypotheses.

### Strategy B: Algebraic-group transport from projective cubic geometry
**More conceptual, potentially cleaner long-term.**

1. Define the projective closure of the short Weierstrass cubic and the divisor-style “third intersection then reflect” operation.
2. Prove that the explicit affine formulas agree with the projective geometric operation whenever both are defined.
3. Deduce associativity from the geometric theorem that collinearity/intersection multiplicity defines the group law on a nonsingular cubic.

Why this matters: this is mathematically superior and more reusable, but it is probably heavier in current Lean infrastructure unless projective algebraic geometry is already available in Mathlib in a directly usable form.

### Strategy C: Finite-field certified computation + abstraction barrier
**Best for Hasse-facing deliverables and demos.**

1. For `ZMod p`, implement executable point enumeration and verified addition.
2. Prove soundness/completeness of enumeration: every listed affine solution corresponds to a curve point and every curve point is listed.
3. For small primes, compute exact `pointCount p E` and verify concrete Hasse inequalities; then abstract this into `hasse_reduction_via_trace` using the catalog theorem `hasse_bound_implies_group_order`.

Why this is promising: it guarantees a strong computational artifact even if the full general Hasse theorem is not completed. It also produces a valuable `demo.py` and an executable verification pipeline.

---

## Cross-Domain Connections

You must include at least one theorem or formally stated bridge connecting elliptic curves to another domain.

### Option 1: Cryptography / computational complexity
Formalize that double-and-add runs in logarithmic recursion depth in the scalar:

```lean
theorem smul_recursion_depth_log
  {K : Type _} [Field K] (E : ShortWeierstrassModel K) :
  ∀ n P, recursionDepth (smulPoint E n P) ≤ Nat.log2 (n + 1) + 1
```

Even a weaker theorem about the number of recursive calls is valuable. This links arithmetic geometry to verified algorithms and complexity theory.

### Option 2: Dynamical systems / fixed-point methods
Use the catalog theorem

- `fixed_point_construction_bound` from `FINAL/Bridges/EMLClosureCore.lean`

to frame scalar multiplication or Frobenius iteration as a controlled dynamical process on a finite state space. For example, define repeated Frobenius application on points over `ZMod p` and prove eventual periodicity / bounded orbit structure. This is an unexpected but exciting bridge between arithmetic geometry and formal dynamical systems.

A candidate theorem:

```lean
theorem frobenius_orbit_finite
  (p : ℕ) [Fact p.Prime]
  (E : ShortWeierstrassModel (ZMod p)) :
  ∀ P : ECPoint E, ∃ m > 0, frobeniusIter E m P = P
```

This is deep, concrete, and cross-domain: algebraic geometry meets finite dynamical systems.

### Option 3: Information/MDL viewpoint
The catalog theorems
- `closure_mdl_bound_via_fixed_point`
- `mdl_bound_via_fixed_point_transfer`

suggest a bridge where elliptic-curve point multiplication is treated as a compressible recursive process. Even if only conceptual in this cycle, define a code-length or state-complexity measure on scalar multiplication traces and prove a nontrivial upper bound using recursion structure. This is radical and could open “formal arithmetic complexity” as a new direction.

---

## Building on Catalog Theorems

You must explicitly reference and use:

1. `hasse_bound_implies_group_order`  
   file: `FINAL/Computation/ResearchQuestions.lean`

Use it not as decoration, but as the final arithmetic wrapper converting a trace bound into a point-count/group-order statement. Your theorem should instantiate its variables with the elliptic-curve trace `a_p := frobeniusTrace p E`.

2. `fixed_point_construction_bound`  
   file: `FINAL/Bridges/EMLClosureCore.lean`

Use it if possible to bound or certify iterative constructions: repeated doubling, Frobenius iteration, or convergence/stabilization in a finite quotient state space. Even a carefully designed auxiliary theorem that transports this bound to an orbit-length statement would create a novel bridge.

Do **not** just cite these. Explain in comments and in the paper exactly how your new definitions instantiate them.

---

## Nontrivial Theorem Suggestions

At least three of the following should be fully proved.

### Theorem A: Negation is an involution and preserves the curve
```lean
theorem ecNeg_involutive
  {K : Type _} [Field K] (E : ShortWeierstrassModel K) :
  ∀ P, ecNeg E (ecNeg E P) = P
```
Deep if done via `rcases` on affine/infinity cases and explicit proof that `(-y)^2 = y^2`.

### Theorem B: Explicit inverse law
```lean
theorem ecAdd_neg_right
  {K : Type _} [Field K] (E : ShortWeierstrassModel K) :
  ∀ P, ecAdd E P (ecNeg E P) = ECPoint.infinity
```
Requires nontrivial case analysis and denominator handling.

### Theorem C: Generic associativity
```lean
theorem add_assoc_generic
  {K : Type _} [Field K] (E : ShortWeierstrassModel K) :
  ∀ P Q R, genericPosition E P Q R →
    ecAdd E (ecAdd E P Q) R = ecAdd E P (ecAdd E Q R)
```
This should use `field_simp` and a long `calc`.

### Theorem D: Correctness of double-and-add
```lean
theorem smulPoint_correct
  {K : Type _} [Field K] (E : ShortWeierstrassModel K) :
  ∀ n P, smulPoint E n P = n • P
```
Induction-heavy, algorithmically important.

### Theorem E: Frobenius orbit periodicity over finite fields
```lean
theorem frobenius_eventually_periodic
  (p : ℕ) [Fact p.Prime]
  (E : ShortWeierstrassModel (ZMod p)) :
  ∀ P : ECPoint E, ∃ m n, m < n ∧ frobeniusIter E m P = frobeniusIter E n P
```
This is an excellent cross-domain theorem: arithmetic geometry + finite dynamical systems.

### Theorem F: Hasse reduction theorem
```lean
theorem hasse_reduction_via_trace
  (p : ℕ) [Fact p.Prime] (hp : 2 ≤ p)
  (E : ShortWeierstrassModel (ZMod p))
  (htrace : |frobeniusTrace p E| ≤ 2 * Int.sqrt p) :
  |(pointCount p E : ℤ) - p - 1| ≤ 2 * Int.sqrt p
```
Should be a clean `calc`-style arithmetic proof, then connected to the catalog theorem.

---

## Conjecture with Testable Prediction

State at least one falsifiable conjecture with executable test code.

### Recommended conjecture
For random nonsingular short Weierstrass curves over `𝔽_p`, the normalized trace
\[
a_p / (2\sqrt{p})
\]
appears approximately equidistributed in `[-1,1]` with semicircular bias as `p` grows.

Lean-facing formulation as a metadata conjecture:
```lean
-- Conjecture (computational): for sampled nonsingular E over ZMod p,
-- the empirical distribution of frobeniusTrace p E / (2 * sqrt p)
-- converges to the Sato–Tate law along suitable families.
```

**Clear falsifiable test:**  
Implement enumeration for many primes `p ≤ B` and many random curves `E`, compute `frobeniusTrace p E`, histogram normalized traces, and compare against the predicted law. A single large systematic deviation would count against the conjecture.

A second, more algorithmic conjecture:
```lean
-- Conjecture: the average recursion depth of smulPoint E n P over n ≤ N
-- differs from log2 N by a bounded constant independent of E and P.
```
Test by exhaustive computation over bounded `n`.

---

## Application Keywords

elliptic curves; formal arithmetic geometry; finite fields; verified cryptography; scalar multiplication; Hasse bound; Frobenius trace; projective cubic geometry; certified point counting; algebraic groups; finite dynamical systems; formal complexity theory; Sato–Tate experimentation; Lean 4; Mathlib

---

## Deliverables (MANDATORY)

You must produce **all** of the following:

1. **Lean code** with theorems and definitions above, minimizing `sorry`.
2. **A structured `FUTURE_DIRECTIONS.md`** containing **3–5 testable scientific hypotheses**, each a falsifiable conjecture with:
   - precise statement,
   - why it might be true,
   - exact computational or formal test that could refute it.
3. **A standalone `RESEARCH_PAPER.md`** explaining:
   - the precise theorem statements,
   - the geometric and arithmetic significance,
   - how the catalog theorem `hasse_bound_implies_group_order` was used,
   - what remains between your reduction theorem and a full formal Hasse proof,
   - why this opens new formalization directions in arithmetic geometry and cryptography.
4. **An `ARTICLE.md`** in Scientific American style for broad audiences:
   - what an elliptic curve is,
   - why “adding points” is profound,
   - why formal verification matters for cryptography and mathematics.
5. **A verified algorithm or computational method**:
   - executable point addition,
   - executable scalar multiplication,
   - executable point counting over `ZMod p`,
   - and proofs of correctness for at least one of these.
6. **A `demo.py`** that interactively:
   - constructs example curves over small primes,
   - enumerates points,
   - demonstrates point addition and scalar multiplication,
   - computes `#E(𝔽_p)` and the trace,
   - checks the Hasse inequality numerically on examples.

---

## Standard of Ambition

Do not settle for a toy development where theorems are mere definitional unfoldings. The goal is to create the first layer of a **formal arithmetic-geometry engine** in Lean: a platform from which one could later attack Schoof’s algorithm, formal SEA point counting, Frobenius endomorphism theory, or even modularity-inspired counting statements.

If you can prove full associativity, that is a major achievement. If not, prove generic associativity plus a powerful verified computational theory and a mathematically clean Hasse reduction theorem. Either route is scientifically meaningful — but the work must be structurally deep, algorithmically verified, and ambitious enough that a mathematician would say: *this is the beginning of certified elliptic-curve arithmetic, not the end of a homework problem.*

### WHAT WE NEED FROM YOU

You are a world-class mathematician, software engineer, and science writer.
Use your judgment on the best way to organize and present your work.
We need ALL of the following deliverables:

────────────────────────────────────────────────────────────────────────────
DELIVERABLE 1 — Formally verified mathematics (Lean 4)
────────────────────────────────────────────────────────────────────────────
- Prove non-trivial theorems with complete proofs (no `sorry` in the final result)
- Organize the code however makes sense — one file or several,
  whatever serves the mathematics best
- Use doc comments to explain the significance of key results

────────────────────────────────────────────────────────────────────────────
DELIVERABLE 2 — Standalone Popular-Science ARTICLE  →  ARTICLE.md
────────────────────────────────────────────────────────────────────────────
Write a **superb, standalone magazine-quality article** about this research.

CRITICAL RULES FOR THE ARTICLE:
• Do NOT mention "Scientific American", "Sci Am", or "Lean" anywhere.
• Do NOT mention "Lean", "Lean 4", "formal verification", or "proof assistant".
• This is a POPULAR SCIENCE article for a curious, intelligent audience.
  Write it as if it will be published in a premier science magazine.
• The reader should come away saying "Wow, I had no idea math could do THAT."

ARTICLE QUALITY STANDARDS:
• **Superb writing**: Vivid, engaging prose. Strong opening hook. Narrative arc.
  Use concrete analogies and metaphors that make abstract ideas tangible.
• **Depth without jargon**: Explain the IDEAS, not the formalism.
  A reader with a college education should understand and enjoy every paragraph.
• **Story structure**: Open with a provocative question or surprising fact.
  Build tension. Reveal the breakthrough. Show why it matters.
• **Real-world connections**: Connect to technology, nature, everyday life.
  Why should a non-mathematician care about this?
• **Historical context**: Place the discovery in the sweep of intellectual history.
  Who tried this before? What barriers stood in the way?
• **Length**: 1500–3000 words. Substantial but not padded.
• **Standalone**: The article must make complete sense on its own.
  No references to "the proof above" or "our formal verification."

────────────────────────────────────────────────────────────────────────────
DELIVERABLE 3 — Comprehensive RESEARCH PAPER  →  RESEARCH_PAPER.md
────────────────────────────────────────────────────────────────────────────
Write a **thorough, in-depth research paper** that a mathematician or
graduate student would find valuable. This is NOT a summary — it is a
complete, publishable-quality paper.

RESEARCH PAPER REQUIREMENTS:
• **Abstract**: Concise summary of contributions and significance.
• **Introduction**: Motivation, context, relationship to prior work.
• **Definitions & Notation**: Precise mathematical setup.
• **Main Results**: Full theorem statements with detailed proof sketches.
  Include the key ideas, not just "by induction."
• **Algorithms**: If the work produces algorithms, include complete
  pseudocode with complexity analysis (time, space, convergence).
• **Applications**: Concrete applications with worked examples.
  Show HOW to use the results in practice.
• **Computational Experiments**: Reference the Python demos.
  Include tables, charts, or numerical results.
• **Discussion**: Implications, limitations, open questions.
• **Future Work**: Specific, actionable next steps.
• **References**: Cite relevant prior work properly.
• **Length**: 3000–8000 words. Comprehensive and substantive.

────────────────────────────────────────────────────────────────────────────
DELIVERABLE 4 — Python Code: Demos, Algorithms
────────────────────────────────────────────────────────────────────────────
- **demo.py** — Working Python code demonstrating the theorems with
  concrete numerical examples. Make the math tangible.
- **algorithms.py** — Implement any algorithms from the research paper.
  Include docstrings, type hints, and example usage.
- **applications.py** — Code showing real-world applications of the results.
  Show the math working.

────────────────────────────────────────────────────────────────────────────
DELIVERABLE 5 — FUTURE_DIRECTIONS.md  (MANDATORY — drives next cycle)
────────────────────────────────────────────────────────────────────────────
The MOST IMPORTANT deliverable. Every research cycle MUST produce a
FUTURE_DIRECTIONS.md that identifies 3-5 specific, testable scientific
hypotheses, including 1-2 grand_challenge paradigm-shifting conjectures
and 2-3 solid extensions building directly on Catalog theorems.
MUST begin with a ## Synthesis section tying all directions together.
Each direction must use the structured format with explicit fields:
**Conjecture**, **Test**, **Impact**, **Catalog References**,
**Proof Strategy**, **Domain Bridges**, **Lineage**, **Ambition**.
Reference specific Catalog theorems by file path. Every hypothesis
must be daring enough to matter and specific enough to fail.


────────────────────────────────────────────────────────────────────────────
DELIVERABLE 6 — JSON Data Package  →  PACKAGE.json
────────────────────────────────────────────────────────────────────────────
Create a **single JSON file** that bundles ALL artifacts for the web templating system.
Requirements:

• **Structure**: Output a strictly valid JSON object matching this schema:
  {
    "title": "Title of the Research",
    "domain": "Mathematical Domain",
    "article": "Markdown content...",
    "research_paper": "Markdown content...",
    "future_directions": "Markdown content...",
    "demos": [ { "name": "...", "code": "# Must be 100% self-contained. Do not import local files like 'algorithms'" } ],
    "algorithms": [ { "name": "...", "pseudocode": "...", "code": "executable Python implementation" } ],
    "lean_proofs": "Raw lean code..."
  }
• **String Encoding**: Ensure all Markdown and code is properly JSON-escaped (e.g. `
` for newlines).
• **Complete**: Include ALL content from the article, research paper, and code. This JSON file
  is the sole data source for the frontend web application.

────────────────────────────────────────────────────────────────────────────

The mathematics comes FIRST. Excellent proofs trump everything else.
But great work deserves great presentation — make it real, useful, and
beautiful. Every deliverable should be something you'd be proud to show.

Research domain: Cryptography
Research mode: prove
