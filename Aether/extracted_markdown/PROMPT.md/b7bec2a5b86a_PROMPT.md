## Assignment: Type Theory: Cubical Type Theory Foundations  
**Mode: prove + formalize + discover**

Aristotle, do not merely encode a toy syntax of cubical ideas. Force Lean 4 to host a mathematically meaningful fragment of cubical type theory whose consequences interact with topology, logic, and spacetime symmetry. The breakthrough target is to formalize a **computationally tractable cubical core** in ordinary Lean, then prove nontrivial structural theorems that make higher paths usable as mathematics rather than decorative syntax.

Your task is to construct a new Lean 4 development around an **internal cubical interval/path framework** and use it to prove genuine theorems about extensionality, transport, and higher inductive approximations. The goal is not “axiomatically assume HoTT.” The goal is to engineer a formal bridge: enough cubical structure to derive consequences, enough computation to test conjectures, and enough cross-domain content that this becomes a new platform for mechanized higher geometry.

---

## Core Vision

Build a Lean-native structure encoding a **cubical interval with endpoint maps and composition-compatible paths**, then prove that:

1. **Path equality induces function extensionality** in your cubical framework.
2. **Equivalences act functorially on paths**, giving a computational shadow of univalence.
3. **A higher inductive approximation to the circle/suspension carries nontrivial elimination principles** and interacts with external mathematical structures.
4. **Cross-domain invariance theorems** show that cubical paths can encode symmetry principles already verified elsewhere in the catalog.

This is revolutionary because it opens a route to:
- mechanized synthetic homotopy inside Lean without requiring a full kernel extension,
- computational experiments on higher structures,
- a bridge between type-theoretic identity, topological homotopy, and physical invariance,
- a reusable formal substrate for future work on univalence, semantics, and higher categories.

Application keywords: **cubical type theory, homotopy type theory, path spaces, univalence, higher inductive types, formal topology, semantic invariance, Lorentz symmetry, constructive computation, mechanized foundations**

---

## Novel Definitions You Must Introduce

You must define at least one genuinely new structure not already present in the catalog. The following is the recommended centerpiece.

### 1. Cubical interval structure
Define a structure expressing an interval object with endpoints and path families:

```lean
structure CubicalInterval where
  I : Type
  i0 : I
  i1 : I
  conn : ∀ i : I, Plift (i = i0) ⊕ Plift (i = i1) ⊕ Unit
```

This is only a starting point; strengthen it if needed. The key is to make it useful for defining paths and endpoint evaluation.

### 2. Internal path type
Define paths as interval-indexed families with endpoint constraints:

```lean
def PathOver (CI : CubicalInterval) (A : Type u) (a₀ a₁ : A) : Type u :=
  { p : CI.I → A // p CI.i0 = a₀ ∧ p CI.i1 = a₁ }
```

Also define dependent paths if feasible:

```lean
def DPathOver (CI : CubicalInterval) {A : Type u} (B : A → Type v)
    {a₀ a₁ : A} (p : PathOver CI A a₀ a₁) (b₀ : B a₀) (b₁ : B a₁) : Type (max u v) := ...
```

### 3. Cubical equivalence action on paths
Define a structure of equivalence that acts on paths:

```lean
structure CubicalEquiv (A : Type u) (B : Type v) where
  toFun    : A → B
  invFun   : B → A
  leftInv  : Function.LeftInverse invFun toFun
  rightInv : Function.RightInverse invFun toFun
```

Then define path transport along equivalences.

### 4. Higher inductive approximation
Since genuine HITs are difficult in core Lean, define a **higher inductive approximation** for the circle or suspension using a quotient, relation closure, or presented algebra. For example, a suspension-like type:

```lean
inductive Susp (A : Type u)
| north : Susp A
| south : Susp A
| merid : A → PathProxy north south
```

If direct path constructors are impossible, introduce a proxy structure encoding the intended eliminator data and prove the corresponding universal property externally.

---

## Exact Theorem Targets

You must prove at least 3 deep theorems. Here are the primary targets, with precise statements and Lean signatures to aim for.

### Theorem 1: Cubical function extensionality
If two functions are pointwise connected by cubical paths, then they are connected by a path in the function space.

**Mathematical statement**  
For any cubical interval `CI`, types `A B`, and functions `f g : A → B`, if  
`∀ x : A, PathOver CI B (f x) (g x)`,  
then there exists  
`PathOver CI (A → B) f g`.

**Lean target**
```lean
theorem cubical_funext
    (CI : CubicalInterval) {A : Type u} {B : Type v}
    {f g : A → B}
    (h : ∀ x : A, PathOver CI B (f x) (g x)) :
    PathOver CI (A → B) f g := ...
```

**Why this matters**  
This is the first nontrivial structural theorem showing your path object is not merely pointwise decoration. It establishes that function spaces inherit cubical geometry.

---

### Theorem 2: Equivalences preserve and reflect path structure
A cubical equivalence induces an equivalence on path spaces.

**Mathematical statement**  
For any cubical equivalence `e : CubicalEquiv A B` and any `a₀ a₁ : A`, there is a bijective correspondence between `PathOver CI A a₀ a₁` and `PathOver CI B (e.toFun a₀) (e.toFun a₁)`.

**Lean target**
```lean
def mapPath {CI : CubicalInterval} {A : Type u} {B : Type v}
    (e : CubicalEquiv A B) {a₀ a₁ : A} :
    PathOver CI A a₀ a₁ → PathOver CI B (e.toFun a₀) (e.toFun a₁) := ...

theorem cubical_equiv_path_equiv
    (CI : CubicalInterval) {A : Type u} {B : Type v}
    (e : CubicalEquiv A B) (a₀ a₁ : A) :
    Nonempty (PathOver CI A a₀ a₁) ↔
    Nonempty (PathOver CI B (e.toFun a₀) (e.toFun a₁)) := ...
```

Stronger version if you can:
```lean
theorem cubical_equiv_path_bijective
    (CI : CubicalInterval) {A : Type u} {B : Type v}
    (e : CubicalEquiv A B) (a₀ a₁ : A) :
    Function.Bijective (mapPath e : PathOver CI A a₀ a₁ →
      PathOver CI B (e.toFun a₀) (e.toFun a₁)) := ...
```

**Why this matters**  
This is a computational shadow of univalence: equivalence is not just cardinality preservation, but geometry preservation at the level of identity witnesses.

---

### Theorem 3: Path transport yields extensional invariance of verified semantics
Connect cubical foundations to an existing verified theorem from the catalog.

Use `lorentz_boost_preserves_interval` from `FINAL/Logic/FormalTime.lean`. Construct a path-level statement saying that Lorentz boosts preserve a cubically encoded spacetime interval observable.

**Mathematical statement**  
For `|v|<1`, the interval observable on events is invariant along the path induced by Lorentz boost action.

**Lean target sketch**
```lean
theorem lorentz_interval_cubical_invariant
    (CI : CubicalInterval) {v : ℝ} (hv : v^2 < 1) :
    ∀ e₁ e₂ : Event1,
    PathOver CI ℝ
      (spacetimeInterval e₁ e₂)
      (spacetimeInterval (lorentzBoost v e₁) (lorentzBoost v e₂)) := ...
```

If the exact names differ, adapt to the file. The key is that the proof must explicitly build on:

- `FINAL/Logic/FormalTime.lean`
- theorem `lorentz_boost_preserves_interval`

**Why this matters**  
This is the cross-domain theorem. It says path equality can encode physical symmetry. That is the kind of unexpected connection that opens a field: cubical identity as a language for invariance principles.

---

### Theorem 4: Constructive interval induces nontrivial cubical paths
Use `constructive_ivt_interval` from `FINAL/Logic/Bisection.lean` to turn constructive continuity data into path existence.

**Mathematical statement**  
A constructive interpolation theorem on an interval yields a path between endpoint values of a function. This links cubical paths with constructive analysis.

**Lean target sketch**
```lean
theorem constructive_path_from_ivt
    (CI : CubicalInterval)
    (f : ℝ → ℝ)
    (hcont : ConstructiveContinuous f)
    {a b : ℝ} (hab : a ≤ b) :
    PathOver CI ℝ (f a) (f b) := ...
```

If `ConstructiveContinuous` is unavailable, formulate the theorem directly in terms of the hypotheses required by `constructive_ivt_interval`.

**Why this matters**  
This turns cubical paths into a computational object arising from constructive analysis, rather than a purely syntactic identity gadget.

---

### Theorem 5: Suspension or circle approximation satisfies a universal property
You do not need kernel-level HITs to prove something deep. Instead, define an approximation and prove its eliminator/universal property.

**Lean target sketch**
```lean
structure SuspAlg (A : Type u) (X : Type v) where
  north : X
  south : X
  merid : A → PathProxy north south

theorem susp_rec_unique
    (A : Type u) (X : Type v) :
    ∀ (s : SuspAlg A X), ∃! f : SuspApprox A → X, RespectsSuspAlg s f := ...
```

Or for a circle approximation:
```lean
theorem circleApprox_rec_loop_determines_map
    (X : Type u) :
    ∀ (x : X) (ℓ : PathProxy x x), ∃! f : CircleApprox → X, ... := ...
```

**Why this matters**  
This provides a mathematically serious surrogate for higher inductive types and gives a rigorous platform for experimentation.

---

## Recommended Proof Architecture

You asked for deeper mathematical insight and 2–3 proof strategy steps. Here are the strongest approaches.

### Strategy A: Direct sigma-subtype path engineering
Best for `cubical_funext` and equivalence action.

1. **Define paths concretely** as endpoint-constrained functions `CI.I → A`.
2. For function extensionality, define the candidate path by
   `p i x := (h x).1 i`,
   then prove endpoint conditions by `funext` plus the endpoint equalities from each `h x`.
3. For equivalence preservation, map the underlying path pointwise by `e.toFun`; for reflection, map by `e.invFun` and use `leftInv/rightInv` to discharge endpoint equalities.

Why promising: it is computational, elementary, and avoids unsupported kernel-level cubical primitives while still giving real structure.

---

### Strategy B: Transport via presented identity algebras
Best for suspension/circle approximation and univalence shadows.

1. Introduce a `PathProxy` or quotient-presented relation that records intended generating paths.
2. Prove a recursor/universal property using quotient induction or generated congruence.
3. Show that equivalences preserve the presented path algebra, yielding a synthetic univalence-style action.

Why promising: this gives higher-inductive behavior without needing true HIT support. It is mathematically subtle and highly reusable.

---

### Strategy C: Semantic bridge through verified invariance theorems
Best for cross-domain breakthroughs.

1. Extract from catalog theorems an equality/invariance principle, e.g. `lorentz_boost_preserves_interval`.
2. Convert that equality into a constant cubical path or a transported path under your `PathOver` encoding.
3. Generalize: any theorem of the form `φ x = φ (T x)` induces a cubical path witness, suggesting a broad theorem schema for semantic invariance.

Why promising: it transforms existing verified mathematics into a higher-identity calculus. This is the clearest route to “I never thought of that connection.”

---

## Build Explicitly on Catalog Theorems

You must use these as actual building blocks, not decorative citations.

### 1. `lorentz_boost_preserves_interval`
- File: `FINAL/Logic/FormalTime.lean`
- Use it to instantiate a path witness in `ℝ`.
- If your `PathOver` admits constant paths generated from equality, define:
  ```lean
  def eqToPath {CI : CubicalInterval} {A : Type u} {a b : A} (h : a = b) :
      PathOver CI A a b := ...
  ```
  Then apply it to the catalog equality.

### 2. `constructive_ivt_interval`
- File: `FINAL/Logic/Bisection.lean`
- Use it to derive existence of a constructive midpoint or interpolant, then package the interpolation into a path-like object.
- If full continuity machinery is too heavy, prove a theorem saying constructive interval data determines a path in a suitable quotient/path proxy space.

### 3. `temporal_stone_duality_exact_theory`
- File: `FINAL/Logic/TemporalFixpointSemantics.lean`
- This is a powerful semantic/logical bridge. Use it to formulate a theorem that theory equivalence induces path equivalence in a semantic space of behaviors or theories.
- Example target:
  ```lean
  theorem theory_equiv_gives_cubical_path
      (CI : CubicalInterval) (T : FTS σ) :
      PathOver CI _ (syntacticTheory T) (semanticTheory T) := ...
  ```
  Adapt exact names as needed.

### 4. `TFormula.behavEquiv_iff_theory_eq`
- Use it to convert semantic equivalence into equality, then equality into a cubical path.
- This gives a second cross-domain theorem: cubical identity as logical equivalence witness.

---

## Deeper Mathematical Insight: What “Univalence” Should Mean Here

Do not overclaim by asserting Voevodsky’s full univalence axiom in plain Lean unless you are truly formalizing an axiomatic universe with that principle. Instead, aim for a **shadow univalence theorem**:

> For a class of explicitly presented types and cubical equivalences between them, equivalence induces path equivalence at the level of observable structure.

This is more honest and often more mathematically useful in Lean. A good target is:

```lean
theorem weak_univalence_observable
    (CI : CubicalInterval)
    {A : Type u} {B : Type v}
    (Obs : Type u → Type w)
    (mapObs : ∀ {X Y}, CubicalEquiv X Y → Obs X ≃ Obs Y)
    (e : CubicalEquiv A B) :
    Nonempty (PathOver CI (ObsSort Obs) (encodeObs A) (encodeObs B)) := ...
```

Even a specialized version for finite presented types, semantics, or path spaces would be a real advance.

---

## Cross-Domain Connections You Must Include

At least one theorem must connect cubical type theory to another domain. Strong options:

1. **Physics**: via `lorentz_boost_preserves_interval`, show cubical paths encode symmetry/invariance.
2. **Constructive analysis**: via `constructive_ivt_interval`, show paths arise from constructive interpolation.
3. **Logic/semantics**: via `temporal_stone_duality_exact_theory` or `TFormula.behavEquiv_iff_theory_eq`, show path equality can encode equivalence of theories or behaviors.
4. **Dependency/rank theory**: use `exists_rank_function` to define a filtration or dimension-like observable on path-presented structures, then prove monotonicity under cubical equivalence.

A particularly bold theorem would be:

```lean
theorem behavioral_equiv_induces_cubical_path
    (CI : CubicalInterval)
    {α : Type*} [DecidableEq α]
    (...) :
    behavEquiv f g →
    PathOver CI _ (theoryOf f) (theoryOf g) := ...
```

This would connect model equivalence, semantics, and higher identity.

---

## Conjecture with Testable Prediction

You must state at least one falsifiable conjecture with a computational disproof mechanism.

### Conjecture A: Path-equivalence reflection for finite presented types
For finite types with explicitly given `CubicalEquiv`, every path-space cardinality is preserved.

```lean
conjecture finite_path_count_invariant
    (CI : CubicalInterval) {A : Type u} {B : Type v}
    [Fintype A] [Fintype B]
    (e : CubicalEquiv A B) :
    ∀ a₀ a₁ : A,
      Fintype.card (PathOver CI A a₀ a₁) =
      Fintype.card (PathOver CI B (e.toFun a₀) (e.toFun a₁))
```

**Computational test:** enumerate small finite intervals `CI.I`, finite types `A, B`, and explicit equivalences; compute path counts. A counterexample disproves it.

### Conjecture B: Circle approximation detects nontrivial loops
For your `CircleApprox`, there exists a target algebra where the canonical loop is not equal to the constant loop.

**Computational test:** instantiate into finite automata/graph models and search whether loop images collapse.

### Conjecture C: Semantic equivalence always lifts to cubical path equivalence
Using `TFormula.behavEquiv_iff_theory_eq`, conjecture that all behaviorally equivalent systems are connected by a path in a suitable semantic presentation type.

**Computational test:** generate finite transition systems and compare behavior equivalence vs. existence of induced path witness in your encoding.

---

## Minimal Theorem Portfolio Required

Your Lean file must contain at least these 3 nontrivial theorems, with real proofs:

1. `cubical_funext`
2. `cubical_equiv_path_equiv` or stronger `cubical_equiv_path_bijective`
3. One cross-domain theorem built from a catalog theorem, preferably  
   `lorentz_interval_cubical_invariant` or a logic/semantics analogue

And ideally a fourth:
4. A universal property theorem for `SuspApprox` or `CircleApprox`

Use induction, `rcases`, `by_contra`, subtype unpacking, extensionality, and multi-step `calc`. Avoid proofs that collapse to trivial definitional reduction.

---

## Lean 4 Type Signature Bundle

Here is a coherent bundle of signatures to aim for:

```lean
universe u v w

structure CubicalInterval where
  I : Type u
  i0 : I
  i1 : I

def PathOver (CI : CubicalInterval) (A : Type v) (a₀ a₁ : A) : Type (max u v) :=
  { p : CI.I → A // p CI.i0 = a₀ ∧ p CI.i1 = a₁ }

def reflPath (CI : CubicalInterval) {A : Type v} (a : A) : PathOver CI A a a := ...

def eqToPath (CI : CubicalInterval) {A : Type v} {a b : A} (h : a = b) :
    PathOver CI A a b := ...

theorem cubical_funext
    (CI : CubicalInterval) {A : Type u} {B : Type v}
    {f g : A → B}
    (h : ∀ x : A, PathOver CI B (f x) (g x)) :
    PathOver CI (A → B) f g := ...

structure CubicalEquiv (A : Type u) (B : Type v) where
  toFun    : A → B
  invFun   : B → A
  leftInv  : Function.LeftInverse invFun toFun
  rightInv : Function.RightInverse invFun toFun

def mapPath {CI : CubicalInterval} {A : Type u} {B : Type v}
    (e : CubicalEquiv A B) {a₀ a₁ : A} :
    PathOver CI A a₀ a₁ → PathOver CI B (e.toFun a₀) (e.toFun a₁) := ...

theorem cubical_equiv_path_equiv
    (CI : CubicalInterval) {A : Type u} {B : Type v}
    (e : CubicalEquiv A B) (a₀ a₁ : A) :
    Nonempty (PathOver CI A a₀ a₁) ↔
    Nonempty (PathOver CI B (e.toFun a₀) (e.toFun a₁)) := ...

theorem cubical_equiv_path_bijective
    (CI : CubicalInterval) {A : Type u} {B : Type v}
    (e : CubicalEquiv A B) (a₀ a₁ : A) :
    Function.Bijective (mapPath e : PathOver CI A a₀ a₁ →
      PathOver CI B (e.toFun a₀) (e.toFun a₁)) := ...
```

If you introduce `PathProxy`, add signatures for recursors and universal properties.

---

## Deliverables You Must Produce

You must produce **all** of the following:

1. **Lean source file(s)** with the new definitions and at least 3 deep theorems proved with nontrivial tactics.
2. **FUTURE_DIRECTIONS.md** containing **3–5 testable scientific hypotheses**, each falsifiable and paired with a concrete computational test.
3. **RESEARCH_PAPER.md** as a standalone scientific paper: definitions, theorem statements, proof ideas, significance, limitations, and next questions.
4. **ARTICLE.md** in Scientific American style, explaining why cubical paths, extensionality, and higher structures matter to a broad audience.
5. **A verified algorithm or computational method**: e.g. an algorithm that constructs path witnesses from equalities/equivalences, or computes finite path-space invariants for presented cubical structures.
6. **demo.py** demonstrating the result interactively, such as:
   - constructing finite cubical intervals,
   - visualizing path spaces,
   - checking the conjectured path-count invariance on small examples,
   - illustrating Lorentz-invariance-as-path.

---

## Final Tactical Guidance

- Be honest about full univalence/HITs: if kernel-level support is unavailable, formalize **weak/universal-property versions** that are mathematically sharp.
- Prefer **reusable abstractions** over one-off encodings.
- Every theorem should feel like a piece of a future library of synthetic higher mathematics in Lean.
- Use the catalog aggressively: convert verified equalities and equivalences into path witnesses.
- Minimize `sorry`, but if one remains, isolate it behind the most conceptually meaningful interface.

The right outcome is not “a cubical toy.” The right outcome is a **new verified architecture for higher identity in Lean 4**, with enough semantic and computational traction that future work on univalence, HITs, and mechanized homotopy can build directly on it.

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

Research domain: Logic
Research mode: prove
