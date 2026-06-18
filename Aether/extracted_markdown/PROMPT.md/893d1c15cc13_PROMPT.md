## Mode: prove

## Title: Certified Canonical Equivalence for Univariate ReLU Networks via Tropical Rational Normal Forms

Prove a genuinely new theorem that upgrades the existing tropical-polynomial compilation story into a **decision procedure for exact functional equivalence** of univariate continuous piecewise-linear ReLU-expressible maps.

The breakthrough target is not “another representation theorem.” It is a **certified canonical semantics** for a nontrivial class of neural networks: every univariate ReLU network computes a continuous piecewise-linear function, and every such function should admit a unique minimal tropical-rational normal form whose equality is decidable by canonicalization. This would convert neural-network equivalence from an architecture-sensitive syntactic problem into an algebraic identity problem in tropical geometry.

If successful, this opens a new field line: **formal tropical semantics for neural computation**, with immediate consequences for verification, compression, architecture-agnostic reasoning, and eventually complexity-theoretic lower bounds via canonical invariants.

---

## Precise theorem targets

Work in the univariate setting first. Do not diffuse into multivariate generality until the canonical core is proved.

### Step 1: define the semantic class
Introduce a structure for continuous piecewise-linear functions on `ℝ` with finitely many breakpoints, and a structure for canonical tropical polynomials and tropical rational functions.

A promising semantic model is:
- tropical polynomial = finite max of affine forms `a_i + n_i * x`, with `n_i : ℕ`
- tropical rational function = difference of tropical polynomials
- canonicality = no redundant monomials, sorted slopes, no duplicate affine pieces modulo domination

You should aim to formalize a theorem of the following shape.

```lean
def IsUnivTPL (f : ℝ → ℝ) : Prop :=
  Continuous f ∧
  ∃ (S : Finset ℝ), ∀ x ∉ S,
    ∃ m b : ℝ, HasDerivAt f m x ∧ f x = m * x + b

structure TropicalPoly where
  terms : Finset (ℕ × ℝ)   -- slope/intercept encoding n*x + a

def TropicalPoly.eval (P : TropicalPoly) (x : ℝ) : ℝ :=
  supᵢ? -- replace by finite max over terms: a + n*x

structure TropicalRat where
  num : TropicalPoly
  den : TropicalPoly

def TropicalRat.eval (R : TropicalRat) (x : ℝ) : ℝ :=
  R.num.eval x - R.den.eval x

def Canonical (P : TropicalPoly) : Prop := ...
def MinimalRat (R : TropicalRat) : Prop := Canonical R.num ∧ Canonical R.den ∧ ...
def TropicallyEquivalent (R S : TropicalRat) : Prop := ∀ x : ℝ, R.eval x = S.eval x
```

### Main existence-and-uniqueness theorem
The central theorem should be stated as:

```lean
theorem exists_unique_minimal_tropical_rational
  (f : ℝ → ℝ)
  (hf : IsUnivTPL f) :
  ∃! R : TropicalRat,
    MinimalRat R ∧ ∀ x : ℝ, R.eval x = f x
```

This is the flagship statement. It says every univariate continuous PL function has a unique minimal tropical-rational representative.

### Main equivalence-checking theorem
Then derive the certified equivalence criterion:

```lean
theorem minimal_tropical_rational_ext
  {R S : TropicalRat}
  (hR : MinimalRat R)
  (hS : MinimalRat S) :
  (∀ x : ℝ, R.eval x = S.eval x) ↔ R = S
```

This is the theorem that turns semantics into exact canonical equality.

### Cross-multiplication theorem
If you define a denominator-clearing multiplication on tropical polynomials, prove the algebraic equivalence criterion at the semantic level:

```lean
def TropicalPoly.tmul (P Q : TropicalPoly) : TropicalPoly := ...
-- semantically: eval (P.tmul Q) x = P.eval x + Q.eval x

theorem tropical_rational_eq_iff_crossmul
  {R S : TropicalRat}
  (hcont : ∀ x : ℝ, True) :  -- replace with any needed well-formedness assumptions
  (∀ x : ℝ, R.eval x = S.eval x) ↔
  ∀ x : ℝ, (R.num.tmul S.den).eval x = (S.num.tmul R.den).eval x
```

This theorem is conceptually decisive: equality of rational tropical forms reduces to equality of tropical polynomials after clearing denominators.

### Compilation bridge theorem for ReLU networks
Use the catalog theorem `relu_tropical_polynomial` as the seed and prove that every univariate ReLU network computes a tropical rational function with canonical representative:

```lean
theorem relu_network_has_canonical_tropical_rational
  (N : UnivReluNet) :
  ∃! R : TropicalRat,
    MinimalRat R ∧ ∀ x : ℝ, R.eval x = N.eval x
```

Then conclude:

```lean
theorem relu_network_equiv_decidable_via_canonicalization
  (N₁ N₂ : UnivReluNet) :
  (∀ x : ℝ, N₁.eval x = N₂.eval x) ↔
  canonicalize N₁ = canonicalize N₂
```

where `canonicalize` returns the unique minimal tropical rational representative.

---

## Why this is a breakthrough

This would be one of the first formally verified theorems turning a nontrivial neural-network equivalence problem into a canonical algebraic normal-form problem. Not approximate equivalence. Not bounded-input testing. **Exact extensional equality**.

The significance is threefold:

1. **Neural verification**  
   Functional equivalence becomes a symbolic certificate, not a search problem.

2. **Tropical geometry meets program semantics**  
   ReLU networks become objects in a canonical tropical algebra, enabling algebraic reasoning about learned models.

3. **Foundations for compression and identifiability**  
   A unique minimal representative gives a semantics-level notion of redundancy independent of architecture.

This is the seed of a new subject: **canonical tropical semantics for machine learning models**.

---

## How to build on the catalog theorems

Use the existing results aggressively and explicitly.

### 1. `relu_tropical_polynomial`
File: `Tropical/Oracles/OracleApplicationsFrontier.lean`

This should be your entry point for showing that elementary ReLU fragments already admit tropical-polynomial semantics. Extend this from a single ReLU expression or affine-ReLU-affine gadget to network composition. The likely pattern is:
- affine maps are tropical rational in a degenerate sense
- `max(0, g(x))` corresponds to tropical addition with zero
- subtraction/differences of maxima produce tropical rational expressions

This theorem should serve as the local compilation lemma from network syntax to tropical algebra.

### 2. `trilemma_no_linear_relu`
File: `Tropical/NNCompilationExtended.lean`

This theorem likely encodes an obstruction showing when a ReLU representation cannot collapse to a globally linear map except in degenerate cases. Use it as a **non-collapse witness** in uniqueness/minimality proofs: if two distinct break profiles survived canonicalization but defined the same function, you should derive a forbidden linear-collapse phenomenon or redundant breakpoint contradiction.

### 3. `tropical_network_lipschitz_bound`
File: `Tropical/RieszRepresentation/Applications.lean`

This provides global regularity. Use it to control slopes and support finiteness arguments:
- bounded slope variation implies finite candidate breakpoint combinatorics in bounded architecture settings
- helps show canonicalization terminates
- useful when proving that the reconstructed tropical rational object is well-formed and semantically continuous

### 4. `tropical_profile_complete_for_bounded_architecture_congruence`
File: `Bridges/AlgebraMachineLearning/OperadicTropicalization.lean`

This is extremely important. It suggests a profile invariant already complete for a bounded notion of congruence. Your theorem should leap beyond bounded architecture congruence to **architecture-independent exact functional equivalence in the univariate case**. The profile theorem can likely provide:
- a finite invariant extracted from network semantics
- a guide for defining the canonical breakpoint/slope profile
- a bridge from network combinatorics to tropical canonicalization

### 5. `bool_and_as_tropical_max`
File: `Tropical/Core/HashInversion.lean`

This looks far afield, but it is a clue: tropical max already carries logical semantics. Use this as a conceptual bridge to argue that canonical tropical forms are not merely algebraic but also **decision objects**. In the longer term, equivalence checking becomes a logic normalization problem over max-plus expressions.

---

## Suggested Lean 4 definitions

Keep the first implementation brutally concrete. Do not begin with maximal abstraction.

Use finite lists or finsets of affine pieces:
```lean
structure AffinePiece where
  slope : ℝ
  intercept : ℝ

def AffinePiece.eval (p : AffinePiece) (x : ℝ) : ℝ := p.slope * x + p.intercept

structure TropicalPoly where
  pieces : List AffinePiece

def TropicalPoly.eval (P : TropicalPoly) (x : ℝ) : ℝ :=
  (P.pieces.map (fun p => p.eval x)).foldr max (-∞)
```

If `-∞` on `ℝ` is annoying, move temporarily to `WithBot ℝ` or require nonempty lists:
```lean
structure TropicalPoly where
  pieces : List AffinePiece
  nonempty : pieces ≠ []
```

Then define canonicality by sorted slopes plus nondomination:
```lean
def Nondominated (P : TropicalPoly) : Prop := ...
def SortedBySlope (P : TropicalPoly) : Prop := ...
def Canonical (P : TropicalPoly) : Prop := SortedBySlope P ∧ Nondominated P
```

For rational functions:
```lean
structure TropicalRat where
  num : TropicalPoly
  den : TropicalPoly

def TropicalRat.eval (R : TropicalRat) (x : ℝ) : ℝ :=
  R.num.eval x - R.den.eval x
```

You may discover that in the univariate continuous PL setting, every function is already representable as a difference of convex PL functions, i.e. difference of maxima of affine forms. That is the true mathematical engine here.

---

## Proof strategy A: DC decomposition of univariate PL maps
This is likely the most promising route.

### Step A1: prove every continuous univariate PL function is difference-of-convex
A continuous univariate piecewise-linear function has left/right slopes with finitely many jumps. Decompose slope variation into positive and negative jump measures. Integrate positive jumps to get a convex PL function `g`, negative jumps to get another convex PL function `h`, and show:
```math
f = g - h.
```
In tropical language, convex PL = tropical polynomial, so this gives existence.

### Step A2: characterize canonical convex representatives by breakpoint slopes
A convex PL function is uniquely determined up to additive normalization by:
- initial slope
- breakpoint multiset
- slope jumps
- one basepoint value

Use this to define a canonical tropical polynomial representation with redundant affine pieces removed.

### Step A3: derive uniqueness of the rational normal form
If `g₁ - h₁ = g₂ - h₂`, then
```math
g₁ + h₂ = g₂ + h₁.
```
Since all four are canonical convex PL functions, compare slope-jump data and prove equality of normalized pairs. This gives uniqueness.

Why this route is promising: it uses a deep but classical fact — univariate PL = DC — and converts the theorem into finite combinatorics on slopes and breakpoints, which is Lean-friendly.

---

## Proof strategy B: direct normal form from breakpoints and slope profile
This is more algorithmic and may be easier to execute formally.

### Step B1: extract a breakpoint profile
Given `f`, define the ordered finite breakpoint set and the affine formula on each interval. Encode:
- initial slope
- successive slope jumps
- value at one anchor point

### Step B2: synthesize canonical numerator and denominator
Positive slope jumps generate numerator terms; negative slope jumps generate denominator terms. This gives an explicit constructor:
```math
profile(f) ↦ (P_f, Q_f).
```

### Step B3: prove soundness and completeness
Show:
- `eval(P_f/Q_f) = f`
- any minimal tropical-rational representation must induce the same slope-jump profile
- therefore canonical forms coincide

Why this route is promising: it yields the actual `canonicalize` algorithm directly, rather than proving existence abstractly first.

---

## Proof strategy C: network-first induction on syntax
This route is riskier but could connect best to the existing catalog.

### Step C1: define a syntax-directed compilation from ReLU terms to tropical rational forms
Prove closure under:
- affine transformation
- addition/subtraction
- ReLU application

### Step C2: prove semantics preservation by induction on network depth
Use `relu_tropical_polynomial` as the local primitive.

### Step C3: prove canonicalization is complete on compiled forms
After compiling, reduce to polynomial/rational canonicalization and show network equivalence iff compiled canonical forms match.

Why this route is less promising initially: uniqueness proofs are usually easier on the semantic side than by induction on network syntax. But it is the best route for the final bridge theorem back to ML.

---

## Recommended execution order

1. Define univariate convex PL / tropical polynomial objects.
2. Prove canonicalization for tropical polynomials alone.
3. Define tropical rational functions as differences.
4. Prove existence and uniqueness for univariate continuous PL functions.
5. Only then bridge to ReLU network semantics.
6. Finally implement `canonicalize` and prove correctness/completeness.

Do not start with arbitrary multivariate rational tropical geometry. The univariate theorem is already deep and field-opening.

---

## Cross-domain connections to exploit

### Tropical geometry × neural semantics
ReLU networks compute max-affine composites; tropicalization makes this exact rather than metaphorical. Your theorem says network semantics live in a canonical tropical quotient.

### Convex analysis × formal verification
Difference-of-convex decomposition is usually an optimization concept. Here it becomes a proof-theoretic engine for exact program equivalence.

### Algebraic normal forms × compiler correctness
`canonicalize` is a verified optimizer for neural semantics. This is closer to certified compilation than to standard learning theory.

### Logic × tropical algebra
Via `bool_and_as_tropical_max`, max-plus operations carry logical content. Canonical tropical rational forms may become proof certificates for branch structure equivalence.

### Complexity theory × identifiability
A unique minimal representation suggests new lower-bound questions:
- how large must any ReLU network computing a given PL function be?
- can canonical tropical complexity separate function classes?

This is where the project becomes paradigm-shifting.

---

## Concrete intermediate lemmas worth proving

```lean
theorem convex_pl_iff_tropical_polynomial
  (f : ℝ → ℝ) :
  IsConvexPL f ↔ ∃ P : TropicalPoly, ∀ x, P.eval x = f x
```

```lean
theorem univ_continuous_pl_iff_tropical_rational
  (f : ℝ → ℝ) :
  IsUnivTPL f ↔ ∃ R : TropicalRat, ∀ x, R.eval x = f x
```

```lean
theorem canonical_tropical_poly_unique
  {P Q : TropicalPoly}
  (hP : Canonical P) (hQ : Canonical Q)
  (heq : ∀ x : ℝ, P.eval x = Q.eval x) :
  P = Q
```

```lean
theorem tropical_poly_eval_tmul
  (P Q : TropicalPoly) :
  ∀ x : ℝ, (P.tmul Q).eval x = P.eval x + Q.eval x
```

```lean
theorem tropical_rational_ext_via_crossmul
  {R S : TropicalRat} :
  (∀ x : ℝ, R.eval x = S.eval x) ↔
  (∀ x : ℝ, (R.num.tmul S.den).eval x = (S.num.tmul R.den).eval x)
```

```lean
theorem canonicalize_sound
  (R : TropicalRat) :
  MinimalRat (canonicalizeRat R) ∧
  ∀ x : ℝ, (canonicalizeRat R).eval x = R.eval x
```

```lean
theorem canonicalize_complete
  (R S : TropicalRat) :
  (∀ x : ℝ, R.eval x = S.eval x) ↔ canonicalizeRat R = canonicalizeRat S
```

---

## What to watch out for

- “Unique minimal representation” is false without normalization conventions. You must fix additive gauge freedoms carefully.
- Equality of differences `P - Q` is invariant under adding the same tropical polynomial to both sides semantically, so minimality must forbid this redundancy.
- If using affine pieces with real slopes, decide whether slopes should be all real numbers or only natural/integer slopes. For ReLU networks with arbitrary real weights, real slopes are the right semantic setting.
- The denominator language “quotient” is metaphorical in tropical algebra; in Lean, implement it as difference unless you have a robust semiring/group formalization ready.
- Continuity matters. Without continuity, jump discontinuities create different normal-form behavior.

---

## Deliverables

1. A Lean file defining:
   - `TropicalPoly`
   - `TropicalRat`
   - evaluation
   - canonicality/minimality
   - canonicalization algorithm

2. Lean proofs of:
   - polynomial canonical uniqueness
   - univariate continuous PL = tropical rational
   - unique minimal tropical-rational representation
   - equivalence iff canonical forms match

3. A bridge theorem for univariate ReLU networks using the cited catalog results.

4. A small suite of explicit examples:
   - identity
   - absolute value
   - hinge/ReLU
   - two different networks with same semantics but same canonical form
   - two networks with different semantics and distinct canonical forms

5. A `FUTURE_DIRECTIONS.md` containing 3–5 concrete next steps at breakthrough level.

---

## Required FUTURE_DIRECTIONS.md

You must produce `FUTURE_DIRECTIONS.md` with 3–5 specific next projects, for example:

1. **Multivariate tropical rational canonical forms**  
   Investigate whether generic continuous PL maps `ℝ^n → ℝ` admit canonical tropical-rational stratified normal forms, perhaps unique modulo regular subdivision data.

2. **Certified minimization and lower bounds for ReLU size**  
   Use canonical tropical complexity to prove architecture-independent lower bounds on number of hidden units needed to represent a function.

3. **Tropical semantics for quantized and integer-valued networks**  
   Connect canonical forms to Presburger arithmetic and exact decision procedures.

4. **Operadic composition laws for canonical tropical semantics**  
   Extend `tropical_profile_complete_for_bounded_architecture_congruence` into a compositional semantics of subnetworks.

5. **Proof-carrying neural equivalence certificates**  
   Export canonical forms as independently checkable certificates for external verifiers.

---

## Application keywords

tropical geometry, ReLU networks, exact equivalence checking, canonical forms, piecewise-linear semantics, difference-of-convex decomposition, formal verification, neural network compression, compiler correctness, symbolic AI, max-plus algebra, certified decision procedures, architecture-independent semantics, proof-carrying ML, operadic machine learning

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
DELIVERABLE 4 — Python Code: Demos, Visualizations, Algorithms
────────────────────────────────────────────────────────────────────────────
- **demo.py** — Working Python code demonstrating the theorems with
  concrete numerical examples. Make the math tangible.
- **visualizations** — matplotlib / plotly charts showing key mathematical
  structures, convergence behavior, phase diagrams, etc.
  Save figures as PNG/SVG files for inclusion in the HTML package.
- **algorithms.py** — Implement any algorithms from the research paper.
  Include docstrings, type hints, and example usage.
- **applications.py** — Code showing real-world applications of the results.
  If the math applies to ML, crypto, physics — show it working.

────────────────────────────────────────────────────────────────────────────
DELIVERABLE 5 — FUTURE_DIRECTIONS.md  (MANDATORY — drives next cycle)
────────────────────────────────────────────────────────────────────────────
The MOST IMPORTANT deliverable. Structured roadmap of breakthrough
research opportunities opened by this work. See detailed spec below.

**Team Directive**: Create a team to conduct research, brainstorm hypotheses,
run experiments, validate data, update knowledge base and iterate forever.
Each future direction should be specific enough for a team to pick up and
pursue with clear hypotheses, proof strategies, and cross-domain connections.

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
    "visualizations": [ { "name": "...", "data": "base64 encoded URI or inline SVG string" } ],
    "lean_proofs": "Raw lean code..."
  }
• **String Encoding**: Ensure all Markdown and code is properly JSON-escaped (e.g. `
` for newlines).
• **Embedded images**: ALL images (charts, diagrams, visualizations) MUST be
  embedded directly in the JSON. If you generate matplotlib/plotly figures, convert them to base64
  data URIs (e.g., `data:image/png;base64,...`). For SVG diagrams, put the raw `<svg>...</svg>`
  string into the `data` field. NEVER reference external image files.
• **Complete**: Include ALL content from the article, research paper, and code. This JSON file
  is the sole data source for the frontend web application.

────────────────────────────────────────────────────────────────────────────

The mathematics comes FIRST. Excellent proofs trump everything else.
But great work deserves great presentation — make it real, useful, and
beautiful. Every deliverable should be something you'd be proud to show.

Research domain: Tropical
Research mode: prove
