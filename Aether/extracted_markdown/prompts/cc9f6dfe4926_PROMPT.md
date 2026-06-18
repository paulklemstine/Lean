## Assignment: Direction 5: Non-Commutative Module-LWE and NTRU

**Mode:** prove

Prove genuinely new, non-trivial theorems that push the current verified cryptographic framework beyond commutative algebra. Build directly on:

- `Cryptography/ModuleLWE/TVDContraction.lean`
- `Cryptography/ModuleLWE/SearchDecision.lean`
- `Cryptography/ModuleLWE/KernelQuotient.lean`

The target is not a cosmetic generalization. The target is a **structural unification theorem**: the abstract information-theoretic and reduction-theoretic core of Module-LWE should survive intact over **non-commutative base rings**, thereby placing NTRU-style systems and Module-LWE-style systems inside one verified module-theoretic security architecture.

This would be a breakthrough because it would show that the real engine behind these reductions is not commutative algebra, but **additive harmonic structure on finite modules together with left-linearity**. If formalized cleanly, this opens a new field of *verified non-commutative post-quantum cryptography*, where ring-LWE, module-LWE, NTRU, group-ring schemes, and skew-polynomial constructions can be studied under one abstract theorem stack.

---

## Core Theorem Targets

You should aim to prove at least the following three substantial theorems, with deep proofs and minimal `sorry`.

### Theorem 1: TVD contraction is ring-agnostic

The existing contraction theorem should be generalized so that the base ring is only assumed to be a ring, not a commutative ring, and the ambient objects are left modules.

### Precise mathematical statement

Let `R` be a finite ring, not assumed commutative. Let `M` and `N` be finite additive groups equipped with left `R`-module structures. Let `φ : M →ₗ[R] N` be an `R`-linear map. Then pushforward along `φ` does not increase total variation distance between finitely supported distributions on `M`.

A representative Lean target should look close to:

```lean
theorem tvd_map_le_of_leftLinear
    {R M N : Type*}
    [Ring R]
    [AddCommGroup M] [Module R M] [Fintype M] [DecidableEq M]
    [AddCommGroup N] [Module R N] [Fintype N] [DecidableEq N]
    (φ : M →ₗ[R] N)
    (μ ν : PMF M) :
    tvd (μ.map φ) (ν.map φ) ≤ tvd μ ν
```

If the catalog uses a different distribution type than `PMF`, adapt the statement to the native notion already present in `TVDContraction.lean`. The essential point is that **commutativity of `R` should disappear from the type signature**.

### Why this is nontrivial
This theorem isolates the true invariant behind the reduction: total variation contraction depends only on finite summation over fibers and nonnegativity/triangle inequalities, not on multiplicative commutativity. Making this explicit is conceptually important because it identifies the correct level of abstraction for cryptographic indistinguishability arguments.

---

### Theorem 2: Hybrid telescope survives over non-commutative modules

The search-to-decision and hybrid arguments should be refactored so the telescope lemma is formulated over arbitrary finite families of distributions indexed by left-module transformations, again with no commutativity assumption on `R`.

### Precise mathematical statement

For a finite sequence of hybrid distributions `H : Fin (n+1) → PMF Ω`, one has the standard telescoping bound

```lean
theorem hybrid_telescope_noncomm
    {Ω : Type*} [Fintype Ω] [DecidableEq Ω]
    (n : ℕ) (H : Fin (n+1) → PMF Ω) :
    tvd (H 0) (H ⟨n, Nat.lt_succ_self n⟩)
      ≤ ∑ i : Fin n, tvd (H (Fin.castSucc i)) (H i.succ)
```

and then instantiate this theorem in the non-commutative module-LWE setting, where the hybrids arise from replacing one sample coordinate at a time by uniform or noise-twisted module samples over a left `R`-module.

A stronger cryptographic corollary should be targeted:

```lean
theorem searchDecision_advantage_bound_noncomm
    {R M N : Type*}
    [Ring R]
    [AddCommGroup M] [Module R M] [Fintype M] [DecidableEq M]
    [AddCommGroup N] [Module R N] [Fintype N] [DecidableEq N]
    (params : NoncommModuleLWEParams R M N) :
    decisionAdvantage params ≤ sampleCount params * oneStepAdvantage params
```

with whatever naming best matches the catalog API.

### Why this is nontrivial
The hybrid telescope is the reduction-theoretic heart of modern cryptography. Showing it formalizes cleanly in the non-commutative module setting means that a large class of reductions is secretly **measure-theoretic and additive**, not commutative-algebraic. This is exactly the kind of abstraction shift that changes a library from “one family of proofs” to “a theorem-generating machine.”

---

### Theorem 3: Abstract NTRU instance as a non-commutative module system

Define a new mathematical structure capturing an NTRU-style public-key sample space over a non-commutative ring or ring quotient, and derive a reduction statement from the abstract module theorems.

### Novel definition requirement

You must define at least one genuinely new structure, for example:

```lean
structure NoncommModuleLWEParams (R M N : Type*) [Ring R]
    [AddCommGroup M] [Module R M]
    [AddCommGroup N] [Module R N] where
  sampleCount : ℕ
  secretDist  : PMF M
  errorDist   : PMF N
  actionMap   : M →ₗ[R] N
  baseDist    : PMF N
```

and/or a more NTRU-specific object:

```lean
structure NTRUInstance (R I M : Type*) [Ring R]
    [AddCommGroup M] [Module R M] where
  quotientMap : R →+* I
  messageSpace : Type*
  -- plus distributions / key equations / public sample map
```

Even better would be a structure capturing **left-ideal quotient cryptosystems** or **group-ring NTRU samples**.

### Precise theorem target

Show that an NTRU-style public distribution is an instance of the abstract non-commutative module framework:

```lean
theorem ntru_instantiates_noncomm_module_framework
    {R M N : Type*}
    [Ring R]
    [AddCommGroup M] [Module R M]
    [AddCommGroup N] [Module R N]
    (P : NTRUInstance R M N) :
    ∃ params : NoncommModuleLWEParams R M N, P.Realize params
```

Then derive a security reduction theorem:

```lean
theorem ntru_decision_reduction
    {R M N : Type*}
    [Ring R]
    [AddCommGroup M] [Module R M] [Fintype M] [DecidableEq M]
    [AddCommGroup N] [Module R N] [Fintype N] [DecidableEq N]
    (P : NTRUInstance R M N) :
    decisionAdvantage (P.toParams) ≤
      sampleCount (P.toParams) * oneStepAdvantage (P.toParams)
```

### Why this is a breakthrough
This would be the first step toward a verified theorem saying: **NTRU is not an alien species relative to LWE; it is another manifestation of the same module-level information contraction principles.** That reframes post-quantum cryptography conceptually and formally.

---

## Stronger Optional Theorem: Kernel/quotient transport without commutativity

If `KernelQuotient.lean` currently assumes commutativity, remove it wherever unnecessary and prove a transport theorem for left modules over arbitrary rings.

A good target would be:

```lean
theorem quotient_map_tvd_bound_noncomm
    {R M N : Type*}
    [Ring R]
    [AddCommGroup M] [Module R M] [Fintype M] [DecidableEq M]
    [AddCommGroup N] [Module R N] [Fintype N] [DecidableEq N]
    (φ : M →ₗ[R] N) (μ ν : PMF M) :
    tvd (μ.map φ) (ν.map φ) ≤ tvd μ ν
```

and then a theorem identifying when equality or near-equality holds in terms of fiberwise concentration. That would connect the cryptographic reduction to quotient geometry of modules.

---

## Proof Strategy Architecture

You must provide proofs with real mathematical substance: induction, `rcases`, `by_contra`, `field_simp`, multi-step `calc`, explicit finite-sum manipulations. Avoid trivialization.

### Strategy A: Proof audit and commutativity excision
Most promising for the first pass.

1. **Audit the existing theorem dependencies** in the three catalog files and identify exactly where `[CommRing R]` or `[CommSemiring R]` enters the signatures.
2. **Refactor statements to the weakest assumptions**:
   - likely `[Ring R]`,
   - `[AddCommGroup M] [Module R M]`,
   - finite support / finite type assumptions for distributions.
3. Re-run the existing proofs, replacing any commutative lemmas with additive-group lemmas on finite sums, absolute values, and pushforwards.
4. Where a proof breaks, isolate whether the break is real mathematics or just a typeclass artifact.

Why promising: the conjecture itself predicts the proofs already do not use commutativity. This path has the highest ratio of conceptual payoff to proof complexity.

---

### Strategy B: Abstract away from modules to additive maps, then re-specialize
Potentially cleaner and more revolutionary.

1. Prove the contraction and telescope theorems first for **arbitrary functions between finite types** or for **additive homomorphisms**.
2. Show that linear maps over left modules are a special case.
3. Recover the module-LWE and NTRU corollaries by specialization.

Why this may be even better: if successful, it reveals that the real theorem lives at the level of **finite probability theory and additive combinatorics**, not module theory at all. Then the cryptographic applications become corollaries of a stronger theorem schema.

---

### Strategy C: Quotient/fiber decomposition via kernels
Best for the NTRU bridge.

1. Express the pushforward distribution along a linear map as a **sum over kernel cosets/fibers**.
2. Prove TVD contraction by grouping mass fiberwise and applying triangle inequality.
3. Use this decomposition to model NTRU samples as quotient-projected noisy module samples.

Why useful: this strategy gives the strongest geometric insight. It connects the reduction to lattice-style quotient structure and may yield stronger follow-up theorems about when reductions are tight.

---

## Cross-Domain Connections You Should Make Explicit

This project must include at least one theorem that genuinely bridges domains.

### 1. Non-commutative algebra ↔ Cryptography
The obvious bridge: left modules over non-commutative rings as a common language for NTRU and Module-LWE.

### 2. Quotient geometry / lattice theory ↔ Information theory
TVD contraction under linear pushforward is really an information-loss theorem under quotienting by kernel fibers. This is a finite analogue of coarse-graining in statistical mechanics and data processing in information theory.

A cross-domain theorem worth stating formally:

```lean
theorem coarse_graining_contracts_tvd
    {α β : Type*} [Fintype α] [DecidableEq α] [Fintype β] [DecidableEq β]
    (f : α → β) (μ ν : PMF α) :
    tvd (μ.map f) (ν.map f) ≤ tvd μ ν
```

Then interpret your module theorem as a corollary. This is a genuine bridge:
**cryptographic hybrids are finite statistical mechanics under coarse-graining**.

### 3. Non-commutative algebra ↔ Harmonic analysis on finite groups
If you model candidate NTRU instances over group algebras or skew group rings, emphasize that these are natural habitats for Fourier-analytic techniques on non-abelian groups. Even if full harmonic-analysis formalization is too large, state this as the conceptual horizon.

### 4. Lattice theory ↔ Representation theory
A group-ring or matrix-ring NTRU formalization suggests that cryptographic hardness may be organized by module decomposition into irreducibles. Even a small theorem identifying module decomposition behavior in finite settings would be a field-opening hint.

---

## Concrete Lean 4 Formalization Targets

Use the native objects in the catalog wherever possible, but the following signatures capture the intended level of abstraction.

```lean
structure NoncommModuleLWEParams
    (R M N : Type*)
    [Ring R]
    [AddCommGroup M] [Module R M]
    [AddCommGroup N] [Module R N] where
  sampleCount : ℕ
  secretDist : PMF M
  errorDist : PMF N
  linMap : M →ₗ[R] N
  targetDist : PMF N
```

```lean
theorem tvd_contraction_noncomm
    {R M N : Type*}
    [Ring R]
    [AddCommGroup M] [Module R M] [Fintype M] [DecidableEq M]
    [AddCommGroup N] [Module R N] [Fintype N] [DecidableEq N]
    (f : M →ₗ[R] N) (μ ν : PMF M) :
    tvd (μ.map f) (ν.map f) ≤ tvd μ ν
```

```lean
theorem hybrid_telescope_noncomm
    {Ω : Type*} [Fintype Ω] [DecidableEq Ω]
    (n : ℕ) (H : Fin (n+1) → PMF Ω) :
    tvd (H 0) (H ⟨n, Nat.lt_succ_self n⟩)
      ≤ ∑ i : Fin n, tvd (H (Fin.castSucc i)) (H i.succ)
```

```lean
structure NTRUInstance
    (R M N : Type*)
    [Ring R]
    [AddCommGroup M] [Module R M]
    [AddCommGroup N] [Module R N] where
  publicMap : M →ₗ[R] N
  secretDist : PMF M
  noiseDist : PMF N
  publicDist : PMF N
  witness : publicDist = (secretDist.bind fun s => (noiseDist.map ((publicMap s) + ·)))
```

If this exact `bind/map` API does not match Mathlib/catalog code, adapt while preserving the mathematical content.

---

## Key Technical Questions to Resolve

1. **Do the current proofs use multiplication in `R` at all, or only linearity and finite sums?**
   If only the latter, the generalization is real and immediate.

2. **What is the weakest algebraic structure on the codomain needed for TVD contraction?**
   Possibly no module structure at all for the contraction theorem.

3. **Can the search-to-decision theorem be reformulated entirely in terms of additive group actions and sample replacement?**
   If yes, then “module-LWE” is actually a special case of a broader finite-action theorem.

4. **What is the correct formal object for NTRU in Lean?**
   Candidate models:
   - left modules over matrix rings,
   - modules over finite group algebras,
   - quotient modules by left ideals,
   - skew-polynomial quotients if feasible.

---

## Testable Conjectures

You must include at least one falsifiable conjecture with a clear computational test. Here are strong candidates.

### Conjecture A: Pure ring-agnosticity of the reduction stack
For every theorem in the current Module-LWE catalog whose proof only manipulates distributions, finite sums, and linear pushforwards, the assumption `[CommRing R]` can be weakened to `[Ring R]` without changing the theorem statement’s conclusion.

**Computational test:** systematically clone the theorem statements with weakened typeclasses and attempt recompilation. Any theorem whose proof fails for a mathematically essential reason disproves the conjecture.

### Conjecture B: NTRU instances over finite group rings satisfy the same hybrid bound as module-LWE
For finite group ring candidates `R = k[G]` with non-abelian `G`, the abstract decision advantage bound derived from the non-commutative framework numerically matches the hybrid telescope prediction.

**Computational test:** implement explicit small examples, e.g. `G = S₃` over a small finite field/ring, sample empirical distributions, and compare measured TVD with the formal upper bound. A violation disproves the conjecture or exposes a modeling bug.

### Conjecture C: Fiber structure controls tightness of contraction
If `f : M → N` is a linear map whose fibers have nearly uniform conditional mass under both `μ` and `ν`, then the contraction inequality is close to equality only when discrepancy aligns across fibers.

**Computational test:** enumerate small finite modules and maps, compute exact TVD before/after pushforward, and correlate slack with fiberwise entropy statistics.

---

## Deliverables You Must Produce

You must produce **all** of the following:

1. **Lean file(s)** with at least 3 nontrivial theorem proofs using deep tactics (`induction`, `rcases`, `by_contra`, `field_simp`, substantial `calc` chains).
2. **A new definition** not already present in the catalog, such as `NoncommModuleLWEParams` or `NTRUInstance`.
3. **A cross-domain theorem** connecting this cryptographic framework to another domain, ideally coarse-graining / information theory.
4. **`FUTURE_DIRECTIONS.md`** containing 3–5 falsifiable scientific hypotheses, each with a concrete test.
5. **`RESEARCH_PAPER.md`** as a standalone paper explaining the theorem, proof architecture, significance, and next directions.
6. **`ARTICLE.md`** in Scientific American style, accessible but accurate.
7. **A verified algorithm or computational method**, not just theorem statements:
   - e.g. an algorithm that computes exact TVD contraction slack for finite maps,
   - or a procedure that instantiates and checks a small non-commutative NTRU model.
8. **`demo.py`** demonstrating the result interactively:
   - sample finite non-commutative instances,
   - compute empirical vs certified TVD bounds,
   - visualize hybrid telescoping and contraction under quotient maps.

---

## Application Keywords

non-commutative cryptography; post-quantum cryptography; NTRU; Module-LWE; group rings; left modules; quotient geometry; total variation distance; data processing inequality; coarse-graining; finite harmonic analysis; lattice reductions; verified cryptography; Lean 4; Mathlib; hybrid arguments; kernel quotient methods; representation-theoretic cryptography

---

## Final Charge

Do not merely “generalize assumptions.” Expose the hidden theorem: **cryptographic indistinguishability reductions are fundamentally coarse-graining principles on finite additive structures, and commutativity is often accidental.** If you can make that precise in Lean, you do not just extend the catalog — you redefine the abstraction barrier for verified post-quantum cryptography.

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

Research domain: Pythagorean
Research mode: prove
