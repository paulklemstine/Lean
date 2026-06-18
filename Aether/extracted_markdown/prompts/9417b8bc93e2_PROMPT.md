## Assignment: Conjecture 2: Derivative Growth as a Semantic Depth Invariant

**Mode:** prove

You should treat this as a chance to carve out a new invariant for expression complexity: **semantic depth detected through derivative growth**. The breakthrough is not merely an upper bound. The real target is to show that for a compositional class of EML expressions, **depth governs smooth sensitivity in a tower-like way**, while explicit iterated exponentials witness near-optimal separation. If formalized cleanly in Lean 4, this becomes a prototype for a new complexity theory of real-valued symbolic programs: not syntax-only, not asymptotic-only, but **semantic-analytic**.

The central scientific question is:

> Can compositional depth be certified from the growth rate of derivatives on compact intervals, and can iterated exponentials be shown to be extremal objects for that certification problem?

This would open a bridge between:
- **program semantics** and **real analysis**,
- **proof theory / circuit depth** and **differential inequalities**,
- **formal verification** and **complexity lower bounds**,
- potentially even **neural expressivity** and **continuous-time dynamical systems**.

---

## Core New Definitions to Introduce

You must define at least one genuinely new concept. I recommend introducing all of the following.

### 1. Semantic derivative envelope
For an EML expression `E`, define a certified bound on derivatives over an interval:
```lean
def derivEnvelope (E : EMLExpr) (I : Set ℝ) : ℝ :=
  sSup {r : ℝ | ∃ x ∈ I, ‖deriv (fun y => E.eval y) x‖ = r}
```
If direct `sSup` machinery is too heavy, define a simpler upper-bound notion:
```lean
def IsDerivEnvelopeBound (E : EMLExpr) (I : Set ℝ) (B : ℝ) : Prop :=
  ∀ x ∈ I, ‖deriv (fun y => E.eval y) x‖ ≤ B
```

### 2. Semantic depth majorant
Define the tower bound associated to expression depth:
```lean
def depthMajorant (d : ℕ) (M : ℝ) : ℝ := Nat.rec M (fun _ t => Real.exp t) d
```
or, if the catalog already has `iterExp`, reuse it:
```lean
def depthMajorant (d : ℕ) (M : ℝ) : ℝ := iterExp d M
```

### 3. Depth-bounded smooth semantics
A new predicate expressing that every subexpression stays bounded by `M` on `[0,1]`:
```lean
def SubexprBoundedOn (E : EMLExpr) (M : ℝ) : Prop := 
  ∀ E' ∈ E.subexprs, ∀ x ∈ Set.Icc (0 : ℝ) 1, ‖E'.eval x‖ ≤ M
```
This is conceptually important: derivative growth is only controllable if intermediate values are controlled. This makes the theorem mathematically honest and formally tractable.

### 4. Extremal depth witness
Define the canonical depth-`d` iterated exponential expression:
```lean
def towerExpr : ℕ → EMLExpr
| 0 => EMLExpr.var
| n+1 => EMLExpr.exp (towerExpr n)
```
Then prove it realizes the extremal growth phenomenon.

---

## Precise Theorem Targets

You need **at least 3 substantial theorems**, all with nontrivial proofs. The ideal package is:

---

### Theorem 1: Derivative growth upper bound from semantic depth

**Mathematical statement.**  
Let `E` be an EML expression of depth `d`. Assume every subexpression of `E` has absolute value at most `M` on `[0,1]`, with `0 ≤ M`. Then for every `x ∈ [0,1]`,
\[
|E'(x)| \le \operatorname{iterExp}(d,M).
\]
More realistically, if the expression language contains addition and multiplication, you may need a polynomial-in-size prefactor:
\[
|E'(x)| \le C(E)\,\operatorname{iterExp}(d,M),
\]
where `C(E)` depends structurally on the syntax tree. If you can eliminate `C(E)` for a natural restricted fragment, that is a stronger theorem.

**Lean 4 target signature** (adapt to actual catalog names):
```lean
theorem deriv_norm_le_depthMajorant
    (E : EMLExpr) (d : ℕ) (M : ℝ)
    (hdepth : E.depth ≤ d)
    (hM : 0 ≤ M)
    (hbounded : SubexprBoundedOn E M) :
    ∀ x ∈ Set.Icc (0 : ℝ) 1,
      ‖deriv (fun y : ℝ => E.eval y) x‖ ≤ depthMajorant d M := by
  ...
```

If this exact theorem is too strong for the full language, prove it for the **exp-composition fragment** first:
```lean
theorem deriv_norm_le_depthMajorant_expFragment
    (E : EMLExpr) (d : ℕ) (M : ℝ)
    (hfrag : E.InExpFragment)
    (hdepth : E.depth ≤ d)
    (hM : 0 ≤ M)
    (hbounded : SubexprBoundedOn E M) :
    ∀ x ∈ Set.Icc (0 : ℝ) 1,
      ‖deriv (fun y : ℝ => E.eval y) x‖ ≤ depthMajorant d M := by
  ...
```

**Why this matters.**  
This theorem would make depth a **certifiable analytic invariant**. It says semantic sensitivity cannot blow up faster than a tower controlled by composition depth. This is the seed of a new discipline: **analytic complexity of symbolic expressions**.

---

### Theorem 2: Iterated exponentials witness near-sharpness

**Mathematical statement.**  
For the canonical tower expression `towerExpr k`, its derivative on `[0,1]` is bounded below by a tower of height `k` and above by a tower of height `k+1`. In particular, the depth upper bound is qualitatively sharp.

At minimum, prove:
\[
\forall x \in [0,1],\quad 0 \le (\operatorname{iterExp}(k))'(x),
\]
and at `x = 1` or `x = 0`,
\[
(\operatorname{iterExp}(k))'(x) \ge \operatorname{iterExp}(k,1),
\]
or some comparable tower lower bound.

A strong version:
\[
(\operatorname{iterExp}(k))'(x)
= \prod_{i<k} \operatorname{iterExp}(i+1,x),
\]
hence in particular
\[
(\operatorname{iterExp}(k))'(1) \ge \operatorname{iterExp}(k,1).
\]

**Lean 4 target signature**:
```lean
theorem deriv_towerExpr_formula
    (k : ℕ) :
    ∀ x : ℝ,
      deriv (fun y => (towerExpr k).eval y) x
        = (towerDerivativeClosedForm k x) := by
  ...
```

and then:
```lean
theorem towerExpr_deriv_lower_bound_at_one
    (k : ℕ) :
    depthMajorant k 1 ≤
      deriv (fun y => (towerExpr (k+1)).eval y) 1 := by
  ...
```

If closed-form derivative is too difficult, prove a recursive inequality:
```lean
theorem towerExpr_deriv_ge_depthMajorant
    (k : ℕ) :
    depthMajorant k 1 ≤
      ‖deriv (fun y => (towerExpr (k+1)).eval y) 1‖ := by
  ...
```

**Why this matters.**  
Upper bounds are scientifically weak without extremizers. This theorem says the tower phenomenon is not an artifact of the proof: it is built into the semantics. That is the difference between a technical lemma and a field-opening invariant.

---

### Theorem 3: Depth separation via derivative obstruction

**Mathematical statement.**  
If an expression `E` has derivative exceeding the universal depth-`d` envelope somewhere on `[0,1]`, then `E` cannot be represented by any depth-`d` expression satisfying the same semantic boundedness assumptions.

This is the first step toward **lower bounds on representational depth** from analysis.

A formulation:
```lean
theorem not_representable_of_deriv_exceeds_depthMajorant
    (f : ℝ → ℝ) (d : ℕ) (M : ℝ)
    (hM : 0 ≤ M)
    (hexceed : ∃ x ∈ Set.Icc (0 : ℝ) 1,
      depthMajorant d M < ‖deriv f x‖) :
    ¬ ∃ E : EMLExpr,
        E.depth ≤ d ∧
        SubexprBoundedOn E M ∧
        (∀ x, E.eval x = f x) := by
  ...
```

A more internal version:
```lean
theorem depth_lower_bound_from_derivative
    (E : EMLExpr) (d : ℕ) (M : ℝ)
    (hM : 0 ≤ M)
    (hexceed : ∃ x ∈ Set.Icc (0 : ℝ) 1,
      depthMajorant d M < ‖deriv (fun y => E.eval y) x‖)
    (hbounded : SubexprBoundedOn E M) :
    d < E.depth := by
  ...
```

**Why this matters.**  
This is the actual semantic-depth invariant. It converts an analytic measurement into a lower bound on syntax. That is a new kind of formal complexity theorem.

---

## Recommended Proof Strategies

You asked for 2–3 proof strategy steps. Here are three viable routes; pursue at least two in parallel and choose the strongest fragment that formalizes robustly.

### Strategy A: Structural induction on expressions
**Most promising for Lean.**

1. **Prove local derivative bounds constructor-by-constructor.**
   - Variable, constants: easy base cases.
   - Addition/subtraction: triangle inequality.
   - Multiplication: product rule plus subexpression boundedness.
   - Exponential/composition: chain rule plus `‖(exp ∘ g)'‖ = exp(g) * ‖g'‖`, then use `g ≤ M`.
2. **Define a recursive structural bound** `syntacticDerivBound : EMLExpr → ℝ` and prove:
   ```lean
   ∀ x ∈ Icc 0 1, ‖deriv (fun y => E.eval y) x‖ ≤ syntacticDerivBound E
   ```
3. **Compare structural bound to the tower majorant** by a second induction:
   ```lean
   syntacticDerivBound E ≤ depthMajorant E.depth M
   ```
   possibly after restricting to an exp-dominant fragment or introducing a size factor.

**Why this is promising.**  
It aligns with Lean’s strengths: induction, recursive definitions, chain rule lemmas, norm inequalities, and `calc` blocks. It also naturally yields an algorithm for certified derivative bounds.

---

### Strategy B: Differential inequality / Grönwall-style domination
**Most conceptually powerful.**

1. Associate to each expression a scalar majorant function `B_d(M)` satisfying recursive inequalities under constructors.
2. Show by induction on depth that derivative envelopes satisfy:
   \[
   D_{d+1} \le \exp(M)\,D_d
   \quad\text{or more generally}\quad
   D_{d+1} \le \Phi(M,D_d),
   \]
   depending on the grammar.
3. Solve the recurrence to obtain a tower-type majorant.

**Why this matters.**  
This approach abstracts away from syntax details and points toward a future general theorem for broad classes of compositional analytic programs, neural networks, and ODE solution operators.

**Caution.**  
Harder in Lean if the recurrence is not perfectly tailored to existing calculus lemmas.

---

### Strategy C: Extremal witness and contradiction-based depth lower bounds
**Best for the separation theorem.**

1. Prove the universal upper bound for all depth-`d` expressions in the chosen fragment.
2. Compute or lower-bound the derivative of `towerExpr (d+1)` at `x = 1`.
3. Use `by_contra`:
   assume representability at depth `d`, apply Theorem 1, contradict the explicit lower bound from Theorem 2.

**Why this is promising.**  
This yields a clean “upper envelope vs witness” separation argument and creates a formal pattern for future lower bounds.

---

## Cross-Domain Connections You Must Explicitly Develop

Include at least one theorem or discussion connecting this work to another domain. Strong options:

### 1. Complexity theory / circuit depth
Interpret EML depth as analog circuit depth and derivative growth as a **continuous sensitivity complexity measure**. Theorems here become analogues of AC⁰/NC lower-bound heuristics, but for real analytic programs.

**Potential theorem statement**:
```lean
theorem semantic_sensitivity_obstructs_shallow_representation
    ...
```
This is your cross-domain theorem: **analysis ⇒ complexity lower bound**.

### 2. Dynamical systems / Lyapunov growth
Derivative magnitude on `[0,1]` behaves like a one-step local instability exponent. Tower growth corresponds to rapidly increasing local sensitivity under repeated nonlinear composition.

Application language:
- Lyapunov surrogate
- sensitivity propagation
- compositional instability

### 3. Machine learning / expressivity
Deep compositions of exponentials resemble highly expressive activation cascades. A derivative-based depth invariant suggests a formal route to proving that certain smooth functions require depth to represent stably.

Application language:
- expressivity separation
- certified sensitivity bounds
- architecture complexity
- symbolic regression depth detection

### 4. Proof theory / ordinal growth
Iterated exponentials are early members of fast-growing hierarchies. Showing depth controls derivative growth places EML semantics in contact with **subrecursive hierarchies** and proof-theoretic growth rates.

This is especially visionary: semantic depth may correspond to a level in a fast-growing hierarchy.

---

## Application Keywords

Use these explicitly in the paper and article:

**application keywords:** semantic complexity, derivative envelope, depth lower bounds, fast-growing hierarchy, certified sensitivity, symbolic regression, compositional expressivity, analog circuit complexity, formal verification, neural expressivity, Lyapunov growth, proof-theoretic rates

---

## Lean 4 Formalization Notes

You asked for precise type signatures. Here are additional likely useful theorem forms.

### Recursive tower majorant positivity
```lean
theorem depthMajorant_nonneg (d : ℕ) {M : ℝ} (hM : 0 ≤ M) :
    0 ≤ depthMajorant d M := by
  ...
```

### Structural derivative bound
```lean
theorem deriv_eval_norm_le_structuralBound
    (E : EMLExpr) (M : ℝ)
    (hbounded : SubexprBoundedOn E M) :
    ∀ x ∈ Set.Icc (0 : ℝ) 1,
      ‖deriv (fun y => E.eval y) x‖ ≤ E.structuralDerivBound M := by
  ...
```

### Structural bound controlled by depth
```lean
theorem structuralDerivBound_le_depthMajorant
    (E : EMLExpr) (M : ℝ)
    (hM : 0 ≤ M)
    (hbounded : SubexprBoundedOn E M) :
    E.structuralDerivBound M ≤ depthMajorant E.depth M := by
  ...
```

### Closed-form recursion for tower expression
```lean
theorem towerExpr_succ_eval
    (k : ℕ) (x : ℝ) :
    (towerExpr (k+1)).eval x = Real.exp ((towerExpr k).eval x) := by
  ...
```

```lean
theorem towerExpr_deriv_rec
    (k : ℕ) (x : ℝ) :
    deriv (fun y => (towerExpr (k+1)).eval y) x
      = Real.exp ((towerExpr k).eval x) *
        deriv (fun y => (towerExpr k).eval y) x := by
  ...
```

These should require real proof work: induction, `rcases` on expression constructors, `field_simp` if rational normalizations arise, `by_contra` in the separation theorem, and substantial `calc` chains.

---

## What to Build on from the Catalog

You mentioned existing verified theorems but did not include them fully. Therefore, you should explicitly search for and build on catalog lemmas in these categories:

1. **Derivative rules for `Real.exp`, addition, multiplication, composition**
   - chain rule
   - product rule
   - derivative of constants and identity
2. **Interval boundedness / extreme value theorems**
   - if available, use compactness of `Set.Icc (0:ℝ) 1`
3. **Monotonicity and positivity of `Real.exp`**
4. **Any existing `iterExp` or fast-growing recursion**
5. **Existing EML evaluation/depth infrastructure**
   - expression depth
   - subexpression recursion
   - evaluation semantics

When writing the formal development, cite exact imported theorem names from Mathlib or the catalog in comments. If there is already a theorem analogous to derivative recursion for iterated exponentials, use it as the backbone of Theorem 2.

---

## Falsifiable Conjecture with Computational Test

You must state at least one falsifiable conjecture with a clear disproof criterion.

### Conjecture A: Sharp depth envelope
For the exp-composition fragment, the tower majorant is asymptotically optimal up to a multiplicative constant depending polynomially on syntax size.

Formal research statement:
> There exists a polynomial `P` such that for every expression `E` in the exp-fragment,
> \[
> \sup_{x\in[0,1]} |E'(x)| \le P(|E|)\,\operatorname{iterExp}(\mathrm{depth}(E),M),
> \]
> and for infinitely many depths `d`, there exists `E_d` with
> \[
> \sup_{x\in[0,1]} |E_d'(x)| \ge c\,\operatorname{iterExp}(d,1).
> \]

**Computational test.**
Enumerate random depth-`d` expressions with bounded constants, numerically estimate derivative maxima on a fine mesh, and fit the ratio
\[
R(E)=\frac{\sup |E'|}{\operatorname{iterExp}(\mathrm{depth}(E),M)}.
\]
If `R(E)` systematically explodes superpolynomially in syntax size, the conjecture is false.

### Conjecture B: Depth identifiability from derivative profile
For bounded-coefficient exp-fragment expressions, minimal representation depth is recoverable up to ±1 from the growth class of the derivative envelope on `[0,1]`.

**Refutation criterion.**
Find two extensionally equal functions with drastically different minimal depths but indistinguishable derivative envelope growth.

This is scientifically excellent because it is **falsifiable** and immediately testable by brute-force expression generation.

---

## Algorithmic Deliverable

Do not stop at theorem statements. Produce a verified computational method:

### Certified derivative-bound algorithm
Define a recursive function computing a sound derivative upper bound:
```lean
def certifyDerivBound : EMLExpr → ℝ → ℝ
```
with theorem:
```lean
theorem certifyDerivBound_sound
    (E : EMLExpr) (M : ℝ)
    (hbounded : SubexprBoundedOn E M) :
    ∀ x ∈ Set.Icc (0 : ℝ) 1,
      ‖deriv (fun y => E.eval y) x‖ ≤ certifyDerivBound E M := by
  ...
```

Then compare it to `depthMajorant`:
```lean
theorem certifyDerivBound_le_depthMajorant
    (E : EMLExpr) (M : ℝ)
    (hM : 0 ≤ M)
    (hbounded : SubexprBoundedOn E M) :
    certifyDerivBound E M ≤ depthMajorant E.depth M := by
  ...
```

This is essential: it turns the theory into a usable certification procedure.

---

## demo.py Requirements

Your `demo.py` should:
1. Generate random bounded EML expressions by depth.
2. Numerically estimate derivative maxima on `[0,1]`.
3. Compute the certified symbolic bound from the recursive algorithm.
4. Compare against `iterExp(depth, M)`.
5. Plot:
   - observed max derivative,
   - certified recursive bound,
   - tower majorant,
   - derivative growth for canonical `towerExpr k`.
6. Search for possible counterexamples to the conjectured sharpness statement.

Interactive features:
- slider for depth,
- coefficient bound,
- grammar fragment selector,
- toggle for random vs canonical expressions.

---

## Mandatory Deliverables

You must produce **all** of the following:

1. **Lean file(s)** with at least 3 deep theorems, nontrivial proofs, and at least one novel definition.
2. **FUTURE_DIRECTIONS.md** with 3–5 falsifiable scientific hypotheses, each with a concrete computational or formal test.
3. **RESEARCH_PAPER.md** that is fully standalone: define the problem, state the theorems, explain the significance, relate to complexity/analysis/dynamics, and articulate next steps.
4. **ARTICLE.md** in Scientific American style, accessible but accurate, centered on the idea that “depth leaves an analytic fingerprint.”
5. **A verified algorithm** for certified derivative upper bounds.
6. **demo.py** demonstrating the theorem numerically and interactively.

---

## Final Scientific Vision

Do not frame this as “another bound on derivatives.” Frame it as the emergence of a new invariant:

> **Derivative growth is a semantic shadow of compositional depth.**

If you succeed, you will have created the beginnings of a formal theory where:
- syntax depth leaves a measurable analytic trace,
- iterated exponentials are extremal witnesses,
- representability lower bounds become provable by calculus,
- and Lean certifies the whole bridge from symbolic programs to complexity theory.

That is a genuinely new research direction.

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
hypotheses. Each direction must be a falsifiable claim or conjecture that
can be proved, disproved, or tested — not a vague "we could explore X."
Format: "Conjecture: [precise statement]. Test: [what would confirm or
refute it]. Impact: [what this would enable if true]." Every hypothesis
should be daring enough to matter and specific enough to fail.

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

Research domain: Speculative
Research mode: prove
