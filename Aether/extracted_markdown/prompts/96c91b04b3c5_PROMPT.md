## Assignment: Tropical Convexity, Tropical Linear Programming, and Mean-Payoff Duality

**Mode:** `prove`

Build a genuinely new formal theory of tropical convexity in Lean 4 that does **not** stop at definitions. The target is a field-opening bridge between tropical geometry, algorithmic optimization, and game theory: a verified tropical Minkowski–Weyl theorem, a certified reduction from tropical feasibility to mean-payoff games, and a polynomial-time solvability theorem **conditional on** the standard positional-solver primitive for mean-payoff games. If an unconditional P-time theorem is too ambitious to formalize honestly, state and prove the strongest correct conditional theorem instead, and isolate the exact game-solving oracle needed.

You must minimize sorrys, and every theorem should be mathematically substantive rather than a thin wrapper around simplification.

---

## Core Vision

Classical convexity rests on addition and scalar multiplication. Tropical convexity replaces these by `max` and `+`, turning polyhedra into combinatorial-geometric objects controlled by piecewise-linear structures. The revolutionary step is to **formalize not only the geometry but the algorithmic equivalence**:

- tropical polyhedra ↔ finitely generated tropical convex sets,
- tropical linear feasibility ↔ dynamic-programming inequalities,
- tropical optimization ↔ mean-payoff games.

This is not an incremental extension. It opens a verified pipeline from idempotent geometry to algorithmic game theory and discrete control. If completed cleanly, it creates a formal foundation for tropical optimization, static program analysis, network timing verification, and max-plus control.

**Application keywords:** tropical geometry, idempotent semiring, max-plus algebra, convexity, polyhedra, linear programming, mean-payoff games, dynamic programming, discrete event systems, formal verification, optimization complexity, algorithmic game theory.

---

## Existing Verified Theorems to Build On

Use the catalog tactically, not decoratively.

1. `tropical_mirror_theorem (a : ℝ) : max a a = a`
   - File: `FINAL/Tropical/Caratheodory.lean`
   - Use this as the canonical idempotence lemma when normalizing tropical convex-combination expressions.

2. `tropical_fundamental_theorem`
   - File: `FINAL/Tropical/Surjectivity_of_the_Tropical_Satake_Transform_for_GL₃.lean`
   - Even if not directly geometric, this certifies that the tropical ecosystem in the catalog already supports nontrivial structural theorems. Reuse any established tropical conventions and notation patterns from this file.

3. `tropical_fundamental_theorem_of_arithmetic {a b : ℕ} (ha : 0 < a) (hb : 0 < b)`
   - File: `FINAL/Tropical/TropicalFactoring.lean`
   - Mine this for style patterns in proving tropical algebraic statements with real combinatorial content.

4. `tropical_and_bound`
   - File: `FINAL/Tropical/OracleApplicationsFrontier.lean`
   - Potentially useful as an example of certified inequality reasoning in tropical-style max/min settings.

Do **not** merely restate these. Build a new theory layer above them.

---

## Mandatory New Definitions

You must define at least one genuinely new structure. Suggested nucleus:

```lean
/-- A set in `Fin n → ℝ` is tropically convex if it is closed under
tropical binary combinations `x ↦ max (a + x) (b + y)` coordinatewise. -/
def IsTropicallyConvex {n : ℕ} (S : Set (Fin n → ℝ)) : Prop :=
  ∀ ⦃x y : Fin n → ℝ⦄, x ∈ S → y ∈ S →
  ∀ a b : ℝ, (fun i => max (a + x i) (b + y i)) ∈ S
```

Then define a finitely generated tropical polytope, e.g.

```lean
/-- The tropical span of a set of generators. -/
def tropicalSpan {n : ℕ} (G : Set (Fin n → ℝ)) : Set (Fin n → ℝ) :=
  {x | ∀ S : Set (Fin n → ℝ), IsTropicallyConvex S → G ⊆ S → x ∈ S}
```

and/or a constructive finite-generator version:

```lean
/-- Membership in the tropical convex hull of a finite family `v : Fin m → (Fin n → ℝ)`. -/
def InTropicalConvHull {m n : ℕ} (v : Fin m → (Fin n → ℝ)) (x : Fin n → ℝ) : Prop :=
  ∃ c : Fin m → ℝ, x = fun i => Finset.univ.sup' Finset.univ_nonempty (fun j => c j + v j i)
```

Also define a tropical halfspace/polyhedron notion, for example:

```lean
/-- A tropical halfspace given by two finite coefficient families. -/
def InTropicalHalfspace {m n : ℕ}
    (A B : Fin m → Fin n → ℝ) (x : Fin n → ℝ) : Prop :=
  ∀ j : Fin m, (Finset.univ.sup' Finset.univ_nonempty (fun i => A j i + x i))
            ≤ (Finset.univ.sup' Finset.univ_nonempty (fun i => B j i + x i))
```

and a game graph / Shapley operator abstraction if needed for the optimization connection.

---

## Primary Theorem Targets

You must prove at least **3 deep theorems**. The following are the recommended flagship statements.

### Theorem 1: Tropical convex hull is tropically convex and minimal

This is foundational and should be fully proved.

**Precise statement:**
For every finite family `v : Fin m → (Fin n → ℝ)`, the set of points representable as tropical linear combinations of the `v j` is tropically convex and is the least tropically convex set containing all generators.

**Lean 4 type signature sketch:**
```lean
theorem tropicalConvHull_is_least
    {m n : ℕ} (v : Fin m → (Fin n → ℝ)) :
    IsTropicallyConvex {x | InTropicalConvHull v x} ∧
    (∀ j : Fin m, InTropicalConvHull v (v j)) ∧
    (∀ S : Set (Fin n → ℝ), IsTropicallyConvex S →
      (∀ j : Fin m, v j ∈ S) →
      ∀ x, InTropicalConvHull v x → x ∈ S)
```

**Why this matters:**  
This is the tropical analogue of the first universal property of convex hulls. Once formalized, it becomes the engine for all later tropical polytope theorems.

---

### Theorem 2: Tropical Minkowski–Weyl, finite-generator to finite-inequality direction

Do **not** overpromise the strongest imaginable version unless you can support it formally. A correct and substantial theorem is:

**Precise statement:**  
Every finitely generated tropical convex set in `Fin n → ℝ` is an intersection of finitely many tropical halfspaces.

If full equivalence is reachable, prove both directions. If not, prove one direction completely and formulate the converse as a conjecture with a computational test.

**Lean 4 type signature sketch:**
```lean
theorem tropical_finitely_generated_implies_polyhedral
    {m n : ℕ} (v : Fin m → (Fin n → ℝ)) :
    ∃ k : ℕ, ∃ A B : Fin k → Fin n → ℝ,
      ∀ x : Fin n → ℝ,
        InTropicalConvHull v x ↔ InTropicalHalfspace A B x
```

You may need a more expressive right-hand side as an intersection over `j : Fin k` of halfspaces; if so, encode that directly.

**Why this is a breakthrough:**  
This is the tropical Minkowski–Weyl bridge: geometry of generators equals geometry of inequalities. In formal mathematics, this is the exact point where tropical convexity becomes optimization-ready.

---

### Theorem 3: Reduction of tropical feasibility to mean-payoff game winning

This is the cross-domain theorem and should be mathematically serious.

**Precise statement:**  
Associate to each tropical linear inequality system a monotone additively homogeneous operator `T`. Then feasibility of the system is equivalent to existence of a sub-fixed point `x ≤ T x`, and this can be encoded as a mean-payoff game winning condition.

A formal theorem may look like:

```lean
def TropOp {m n : ℕ} (A B : Fin m → Fin n → ℝ) (x : Fin n → ℝ) : Fin n → ℝ := ...

theorem tropical_feasibility_iff_subfixed_point
    {m n : ℕ} (A B : Fin m → Fin n → ℝ) :
    (∃ x : Fin n → ℝ, InTropicalHalfspace A B x) ↔
    (∃ x : Fin n → ℝ, ∀ i : Fin n, x i ≤ TropOp A B x i)
```

Then prove a structural connection theorem such as:

```lean
theorem TropOp_monotone_additively_homogeneous
    {m n : ℕ} (A B : Fin m → Fin n → ℝ) :
    Monotone (TropOp A B) ∧
    (∀ (x : Fin n → ℝ) (c : ℝ), TropOp A B (fun i => x i + c) = fun i => TropOp A B x i + c)
```

If you formalize a finite mean-payoff game object:

```lean
theorem tropical_feasibility_reduces_to_mean_payoff
    {m n : ℕ} (A B : Fin m → Fin n → ℝ) :
    ∃ G : MeanPayoffGame, 
      ((∃ x, InTropicalHalfspace A B x) ↔ G.HasWinningState)
```

**Why this is revolutionary:**  
This connects tropical geometry to algorithmic game theory and nonlinear Perron–Frobenius theory. It says tropical linear programming is not “just another LP variant”; it is a geometric avatar of long-run optimal control.

---

### Theorem 4: Conditional polynomial-time solvability theorem

Be mathematically honest here. Since the complexity of mean-payoff games is subtle, the strongest safe theorem may be conditional.

**Precise statement:**  
If there exists a polynomial-time solver for finite mean-payoff games, then there exists a polynomial-time solver for tropical linear feasibility / optimization.

**Lean 4 type signature sketch:**
```lean
theorem tropical_LP_in_P_of_mean_payoff_in_P :
  (∃ algGame : MeanPayoffInstance → Bool,
      IsPolyTimeDecider MeanPayoffWinning algGame) →
  ∃ algTrop : TropicalLPInstance → Bool,
      IsPolyTimeDecider TropicalFeasible algTrop
```

If you have an actual verified combinational algorithm on a restricted class—difference constraints, Monge data, acyclic dependency graphs, or bounded-policy instances—then prove an unconditional polynomial-time theorem there as a special case.

**Why this matters:**  
This theorem turns an abstract equivalence into a complexity-theoretic transfer principle, making formal tropical optimization relevant to verified algorithms.

---

## Proof Strategy Architecture

You must include multi-step proofs. Here are the recommended routes.

### Strategy A: Universal-property route for tropical convex hull
Best for Theorem 1.

1. Define tropical combinations coordinatewise using `max` of shifted generators.
2. Prove closure under binary tropical combination by explicitly merging coefficient families:
   - given `x = max_j (c_j + v_j)` and `y = max_j (d_j + v_j)`,
   - show `max (a + x_i) (b + y_i) = max_j (max (a + c_j) (b + d_j) + v_j i)`.
3. Use `calc` chains, extensionality on functions `Fin n → ℝ`, and idempotence via `tropical_mirror_theorem`.

This is the most promising first theorem because it is structurally clean and creates reusable lemmas.

---

### Strategy B: Residuation / separation route for tropical Minkowski–Weyl
Most promising for Theorem 2.

1. For each candidate point outside the tropical hull, define a separating tropical inequality using coordinatewise residuation-type bounds.
2. Show every generator satisfies the inequality, but the target point violates it.
3. Compactify the finite-dimensional finite-generator setting to extract finitely many inequalities.

This is stronger than a brute-force finite enumeration and conceptually aligns with classical separation theorems. If full separation is difficult, prove a finite-support separation lemma first.

---

### Strategy C: Dynamic programming operator route for mean-payoff connection
Best for Theorems 3 and 4.

1. Rewrite each tropical inequality
   `max_i (A j i + x i) ≤ max_i (B j i + x i)`
   as a family of comparison constraints encoded by a Shapley-like operator.
2. Prove monotonicity and additive homogeneity of this operator.
3. Use standard fixed-point/subfixed-point reasoning to connect feasibility with game-theoretic winning conditions.

This strategy is the most visionary because it imports methods from control and games into tropical convexity. Even a partial formalization here would be scientifically valuable.

---

## Cross-Domain Connections You Must Exploit

At least one theorem must explicitly connect tropical convexity to another domain.

### Required connection: tropical geometry ↔ game theory
Use Theorem 3 above.

### Strongly encouraged secondary connection: tropical geometry ↔ discrete event systems / control
Formulate the Shapley or Bellman operator as a max-plus linear dynamical update. Prove a theorem such as:
- additive homogeneity corresponds to time-shift invariance,
- monotonicity yields order-preserving dynamics,
- feasible tropical potentials certify nonnegative cycle mean bounds.

Possible formal theorem sketch:
```lean
theorem TropOp_time_shift_invariant
    {m n : ℕ} (A B : Fin m → Fin n → ℝ) (x : Fin n → ℝ) (c : ℝ) :
    TropOp A B (fun i => x i + c) = fun i => TropOp A B x i + c
```

### Optional daring connection: tropical convexity ↔ nonarchimedean geometry
If you can define valuation-like maps or tropicalization shadows of classical convex combinations, add a conceptual theorem showing a degeneration principle. This can remain modest but should be mathematically real.

---

## Suggested Intermediate Lemmas

These should help you avoid fragile proofs.

```lean
theorem tropical_comb_assoc_coord
    {x y z : ℝ} {a b c : ℝ} :
    max (a + max (b + x) (c + y)) (a + z)
      = max (a + b + x) (max (a + c + y) (a + z))
```

```lean
theorem tropical_scalar_distrib_max
    (a x y : ℝ) :
    a + max x y = max (a + x) (a + y)
```

```lean
theorem tropical_combination_ext
    {n : ℕ} {f g : Fin n → ℝ}
    (h : ∀ i, f i = g i) : f = g
```

```lean
theorem InTropicalConvHull_generator
    {m n : ℕ} (v : Fin m → (Fin n → ℝ)) (j : Fin m) :
    InTropicalConvHull v (v j)
```

```lean
theorem InTropicalHalfspace_mono
    {m n : ℕ} {A B : Fin m → Fin n → ℝ} :
    Monotone (fun x => InTropicalHalfspace A B x)
```

Some of these may need corrected formulations during implementation; that is fine, but keep the mathematical intent.

---

## Complexity/Algorithm Deliverable

You must provide a **verified algorithm or computational method**, not just theorem statements.

### Minimum acceptable algorithm
A certified decision procedure for a nontrivial tropical feasibility fragment, for example:
- tropical difference constraints,
- acyclic tropical systems,
- bounded-policy mean-payoff reductions.

### Preferred algorithm
A verified reduction:
1. input tropical inequality system,
2. construct associated game/operator,
3. call a game solver oracle or restricted verified solver,
4. reconstruct feasibility certificate.

This algorithm must be documented and exercised in `demo.py`.

---

## Conjecture With Testable Prediction

You must include at least one falsifiable conjecture with a clear computational refutation criterion.

### Recommended conjecture
**Conjecture (Tropical Carathéodory for certified support size):**  
For every `x` in the tropical convex hull of `m` generators in `ℝ^n`, there exists a representation of `x` using at most `n + 1` active generators.

This may or may not hold in your exact formalization; investigate carefully.

**Computational test:**  
Enumerate random finite generator sets in low dimensions, compute tropical hull membership certificates, and search for points whose every certificate requires support size `> n + 1`. A single counterexample disproves the conjecture.

Alternative conjecture if you prefer algorithmic complexity:

**Conjecture (Policy-stabilization bound):**  
For tropical LP instances whose associated mean-payoff game graph has cyclicity `≤ C`, policy iteration stabilizes in `poly(n, m, C)` steps.

**Computational test:**  
Generate instances with controlled cyclicity, run policy iteration, fit growth rate, and search for superpolynomial families.

---

## Formal Deliverables

You must produce **all** of the following:

1. **Lean file(s)** containing:
   - at least 3 deep theorems,
   - at least 1 novel definition,
   - at least 1 cross-domain theorem,
   - proofs using induction, `rcases`, `by_contra`, `field_simp` where appropriate, and multi-step `calc`.

2. **`FUTURE_DIRECTIONS.md`**
   - include **3–5 testable scientific hypotheses**,
   - each must be falsifiable,
   - each must specify a concrete computational or formal test.

3. **`RESEARCH_PAPER.md`**
   - standalone scientific paper,
   - explain definitions, theorem statements, proof ideas, significance, and next questions,
   - understandable without reading the code.

4. **`ARTICLE.md`**
   - Scientific American style,
   - vivid explanation of tropical convexity, optimization, and games,
   - broad audience, but mathematically honest.

5. **Verified algorithm or computational method**
   - formalized and explained.

6. **`demo.py`**
   - interactive demonstration of:
     - constructing tropical convex hull examples,
     - checking tropical halfspace feasibility,
     - showing the game reduction on sample instances.

---

## Standards of Depth

These are mandatory:

- No trivial “theorems” discharged only by `native_decide`, `decide`, `norm_num`, or `rfl`, unless the theorem itself is conceptually deep.
- At least **3 nontrivial proofs** with real mathematical structure.
- At least one proof should use contradiction or separation logic.
- At least one proof should involve explicit coordinatewise algebraic manipulation.
- At least one proof should bridge two domains.

---

## Recommended Lean Design Choices

- Work in `Fin n → ℝ` first. This avoids premature abstraction and keeps finite suprema tractable.
- Use `Finset.univ.sup'` for coordinatewise tropical linear combinations.
- Package monotonicity and additive homogeneity early; they will pay off later.
- Prefer explicit finite-dimensional statements over broad typeclass-heavy generality.
- Once the theory works in `ℝ`, consider whether `ℤ` or `WithBot ℝ` variants are worth a follow-up.

---

## Final Objective

Produce a formal development that makes the following sentence true:

> “We now have a machine-checked bridge from tropical convex geometry to algorithmic game theory: finitely generated tropical convex sets admit inequality descriptions, tropical feasibility is equivalent to a subfixed-point problem for a Shapley-type operator, and tropical optimization inherits certified algorithmic solvability from mean-payoff game procedures.”

That is a real research milestone, not a toy exercise.

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

Research domain: Tropical
Research mode: prove
