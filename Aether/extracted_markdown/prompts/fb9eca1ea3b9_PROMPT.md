## Assignment: Direction 2: Chain Rule for Compression Defect

Prove a genuinely new information-theoretic theorem in the categorical/sheaf-compression setting, not a formal rearrangement. The goal is to turn the existing compression defect into a **structured calculus of conditional information** on finite sites, with a bona fide chain rule analogous to Shannon’s identity
\[
I(X;Y,Z)=I(X;Y)+I(X;Z\mid Y).
\]

This is not an incremental extension. If successful, it would create one of the first rigorously formalized examples of a **categorical information measure with compositional laws**, opening a path toward sheaf-theoretic data processing, interaction information, and categorical channel theory.

### Core vision

The existing catalog already contains the raw material: a compression defect and subadditivity for coproducts. The breakthrough is to identify the **correct conditionalized defect** and prove a chain rule that is not tautological but emerges from the geometry of witness profiles over finite sites.

The central scientific question is:

> Can compression defect on presheaves over a finite site be organized into a conditional-information formalism obeying chain decomposition, monotonicity bounds, and computable witness identities?

If yes, then categorical compression becomes an information theory, not merely a complexity invariant.

---

## Precise theorem target

Work over a finite site \((C,J)\), with presheaves valued in a category where the catalog’s coproduct-based compression defect is already defined. Use the catalog definitions from:

- `Catalog/Pythagorean/ProbeComplexity/CoproductSubadditivity.lean`
  - especially `compressionDefect`
  - especially `sheafCompressionNumber_coprod_le`
- `Catalog/Pythagorean/ProbeComplexity/Theorems.lean`
  - especially `card_hom_le_profile_capacity`

You should introduce a new conditional notion, then prove at least three substantial theorems around it.

### New definitions to introduce

Define a **conditional compression increment** and a **conditional mutual compression**.

Mathematically, the intended definitions are:

\[
\kappa_{\mathrm{cond}}(G,H)
:= \kappa_{\mathrm{sh}}(J, G \oplus H)-\kappa_{\mathrm{sh}}(J,G),
\]

and

\[
I_{\mathrm{sh}}(F;G)
:= \kappa_{\mathrm{sh}}(F)+\kappa_{\mathrm{sh}}(G)-\kappa_{\mathrm{sh}}(J,F\oplus G).
\]

Then define the conditional mutual quantity by the **difference form**
\[
I_{\mathrm{sh}}(F;H\mid G)
:= I_{\mathrm{sh}}(F;G\oplus H)-I_{\mathrm{sh}}(F;G).
\]

This difference-form definition is strategically preferable as the primary formal object, because it makes the chain rule theorem meaningful but still leaves room to prove equivalence with a defect-style expression under associativity/transport lemmas.

After that, define the more structural form
\[
I^{\mathrm{def}}_{\mathrm{sh}}(F;H\mid G)
:= \kappa_{\mathrm{sh}}(F)+\kappa_{\mathrm{cond}}(G,H)-\kappa^{G}_{\mathrm{sh}}(F\oplus H),
\]
where the last term should be implemented in whatever Lean-accessible way correctly captures “compression of \(F\oplus H\) relative to a fixed \(G\)-context”. If a fully relative compression object is too ambitious initially, prove the difference-form chain rule first and then derive the defect-style formula as a theorem.

### Suggested Lean 4 signatures

You will need to adapt names/types to the exact catalog namespace, but the formal targets should look approximately like:

```lean
def conditionalCompressionDefect
  (J : GrothendieckTopology C)
  (G H : Presheaf C X) : ℕ :=
  sheafCompressionNumber J (G ⨿ H) - sheafCompressionNumber J G

def mutualCompression
  (J : GrothendieckTopology C)
  (F G : Presheaf C X) : ℕ :=
  sheafCompressionNumber J F
    + sheafCompressionNumber J G
    - sheafCompressionNumber J (F ⨿ G)

def conditionalMutualCompression
  (J : GrothendieckTopology C)
  (F G H : Presheaf C X) : ℤ :=
  (mutualCompression J F (G ⨿ H) : ℤ) - mutualCompression J F G
```

If subtraction in `ℕ` creates truncation artifacts, move to `ℤ` or `ℚ≥0` for the conditional quantities. This is not a technical nuisance; it is mathematically important. A true chain rule often lives naturally in an additive ambient group even when primitive quantities are nonnegative naturals.

The flagship theorem should be formalized in a form like:

```lean
theorem mutualCompression_chain_rule
  (J : GrothendieckTopology C)
  (F G H : Presheaf C X) :
  conditionalMutualCompression J F G H
    = (mutualCompression J F (G ⨿ H) : ℤ) - mutualCompression J F G
```

That identity is definitional if you define conditional mutual compression by difference, so it is not enough. The real theorem should instead identify this difference with a **defect-style closed formula**. For example:

```lean
theorem conditionalMutualCompression_eq
  (J : GrothendieckTopology C)
  (F G H : Presheaf C X) :
  conditionalMutualCompression J F G H
    =
    (sheafCompressionNumber J F : ℤ)
      + conditionalCompressionDefect J G H
      - sheafCompressionNumberRel J G (F ⨿ H)
```

or, if relative compression is encoded differently, an equivalent transported formula.

A second major theorem should be a true chain rule on triple coproducts, using associativity:

```lean
theorem mutualCompression_coprod_assoc_chain
  (J : GrothendieckTopology C)
  (F G H : Presheaf C X) :
  (mutualCompression J F ((G ⨿ H)) : ℤ)
    = mutualCompression J F G + conditionalMutualCompression J F G H
```

A third substantial theorem should prove a nonnegativity or monotonicity statement under a clear hypothesis:

```lean
theorem conditionalCompressionDefect_nonneg
  (J : GrothendieckTopology C)
  (G H : Presheaf C X) :
  0 ≤ (conditionalCompressionDefect J G H : ℤ)
```

or a boundedness theorem such as:

```lean
theorem mutualCompression_le_left
  (J : GrothendieckTopology C)
  (F G : Presheaf C X) :
  mutualCompression J F G ≤ sheafCompressionNumber J F
```

provided this follows from catalog subadditivity and arithmetic.

---

## What would count as a breakthrough

A proof here would not merely mimic entropy notation. It would show that **compression witnesses on a site compose like information-bearing contexts**. That is conceptually new.

Why this matters:

1. **Categorical information theory:** You would have a chain rule for an invariant defined from presheaf/sheaf compression rather than probability measures.
2. **Sheaf semantics of context:** Conditioning on \(G\) becomes a structural context operation, not a probabilistic sigma-algebra.
3. **Algorithmic applications:** Once chain rules exist, one can compute interaction scores, redundancy/synergy diagnostics, and candidate “data processing” inequalities for structured datasets on small categories.
4. **Cross-pollination:** This links category theory, information theory, combinatorics of finite sites, and complexity-style witness minimization.

This opens a field: **categorical probe information theory**.

---

## Required theorem package

You must prove at least **3 nontrivial theorems** with actual proof architecture, not definitional simplifications.

### Theorem A: Conditional defect nonnegativity
Use `sheafCompressionNumber_coprod_le` or its consequences to show the coproduct cannot compress “better than context alone” in the wrong direction, after choosing the correct codomain (`ℤ` if necessary). If the naive nonnegativity fails in `ℕ` due to truncation, formulate the theorem in an additive ordered codomain where the statement is mathematically faithful.

Target shape:
\[
0 \le \kappa_{\mathrm{cond}}(G,H).
\]

### Theorem B: Chain rule for mutual compression
Prove the genuine additive decomposition:
\[
I_{\mathrm{sh}}(F;G\oplus H)=I_{\mathrm{sh}}(F;G)+I_{\mathrm{sh}}(F;H\mid G),
\]
where \(I_{\mathrm{sh}}(F;H\mid G)\) is not merely introduced to make the theorem tautological, but is also shown equal to a defect-style formula derived from witness arithmetic and coproduct associativity.

This theorem should involve multi-step `calc`, transport across coproduct reassociation isomorphisms, and arithmetic manipulation of compression numbers.

### Theorem C: A cross-domain theorem
You must include one theorem connecting this framework to another domain.

Two strong options:

#### Option C1: Capacity bound from probe complexity
Use `card_hom_le_profile_capacity` to derive an information bound of the form:
\[
I_{\mathrm{sh}}(F;G)\le \kappa_{\mathrm{sh}}(F),
\qquad
I_{\mathrm{sh}}(F;G)\le \kappa_{\mathrm{sh}}(G),
\]
or a counting-theoretic upper bound on mutual compression via profile capacity. This links **categorical information** to **combinatorial counting/complexity**.

#### Option C2: Submodularity-style inequality
Attempt a theorem analogous to Shannon submodularity:
\[
I_{\mathrm{sh}}(F;G\oplus H)\ge I_{\mathrm{sh}}(F;G),
\]
under a hypothesis ensuring conditioning cannot destroy witness-sharing. This links to **polymatroid theory**, **matroid rank**, and **submodular optimization**.

If the theorem fails, produce a small counterexample and formalize the failure mechanism. A good counterexample is scientifically valuable.

---

## Proof strategy architecture

You must not rely on trivial automation. Build the argument in stages.

### Strategy 1: Algebraic-defect expansion via coproduct subadditivity
Most promising.

1. Expand all mutual-compression quantities into expressions involving `sheafCompressionNumber`.
2. Use `sheafCompressionNumber_coprod_le` as the engine for monotonicity/nonnegativity inequalities.
3. Introduce explicit lemmas for reassociation of coproducts:
   \[
   (F\oplus G)\oplus H \cong F\oplus (G\oplus H),
   \]
   and prove invariance of compression under the relevant isomorphism transport.
4. Finish with `calc` chains and arithmetic normalization in `ℤ`.

Why this is strongest: it is closest to the certified catalog infrastructure and minimizes dependence on speculative new semantic machinery.

### Strategy 2: Witness decomposition / profile projection
Conceptually deeper.

1. Unpack the witness or profile definition underlying `compressionDefect`.
2. Show that a witness for \(F\oplus G\oplus H\) canonically projects to witnesses for \(F\oplus G\) and \(G\oplus H\).
3. Identify the residual witness cost as conditional information.
4. Reassemble the costs to obtain the chain rule.

Why this matters: if successful, it gives not only the theorem but also an algorithm for computing conditional information from witness data.

### Strategy 3: Capacity-counting bridge
Best for the cross-domain theorem.

1. Use `card_hom_le_profile_capacity` to reinterpret compression numbers as upper bounds on morphism-profile growth.
2. Translate coproduct compression identities into inequalities about counts/log-count surrogates.
3. Derive upper bounds for mutual compression and test whether monotonicity/submodularity holds empirically on small sites.

Why useful: even partial success yields computationally testable predictions and links to information-theoretic counting principles.

---

## Mathematical subtleties you must confront directly

### 1. Naturals vs additive groups
The expression
\[
a+b-c
\]
is often unnatural in `ℕ` if \(c\) can exceed \(a+b\) before subadditivity is invoked. You should seriously consider defining conditional/mutual quantities in `ℤ`. This is mathematically cleaner and avoids hidden truncation.

### 2. Associativity transport is not cosmetic
The chain rule compares \(G\oplus H\) and triple coproducts. You must prove or reuse invariance of compression under canonical coproduct isomorphisms. This is where a real categorical theorem lives.

### 3. “Conditional compression” may need a relative notion
If the naive definition
\[
\kappa_{\mathrm{sh}}(J,G\oplus H)-\kappa_{\mathrm{sh}}(J,G)
\]
is too weak to support the desired formula, define a new structure, e.g. a **contextual compression profile** or **relative witness cost**. This satisfies the novelty requirement and could be the real conceptual contribution.

For example, introduce a structure like:

```lean
structure ContextualCompressionProfile where
  baseCost : ℕ
  extensionCost : ℕ
  witnessCount : ℕ
  admissible : Prop
```

or a more mathematically elegant variant that packages the compression of an extension \(G \to G \oplus H\).

This is not bureaucracy; it may be the right abstraction that makes the chain rule true for structural reasons.

---

## Cross-domain connections to emphasize

You must explicitly frame the work as connecting:

- **Information theory:** chain rule, conditional mutual information, interaction information
- **Category theory:** finite sites, presheaves, coproduct associativity, contextual extension
- **Combinatorics / complexity:** profile capacity, counting bounds, witness minimization
- **Physics/stat mech analogy:** contextual compression behaves like free-energy increment under extension of state space; conditional mutual compression measures “coupling energy” revealed after fixing a background context
- **Polymatroid theory:** if monotonicity/submodularity emerges, compression numbers may define a rank-like function

Use these connections in the paper and article, not as decoration but as scientific positioning.

---

## Computational agenda

You are required to produce a verified computational method, not just theorems.

### Verified algorithm
Implement an algorithm that, for small finite categories/sites and finitely enumerable presheaves \(F,G,H\),

1. computes `sheafCompressionNumber`,
2. computes `mutualCompression`,
3. computes `conditionalCompressionDefect`,
4. tests the chain rule identity,
5. searches for counterexamples to monotonicity/nonnegativity variants.

This algorithm should be formalized enough that the correctness of the computed quantity is theorem-backed, not merely script-level experimentation.

### `demo.py`
Create an interactive script that:
- enumerates small triples \((F,G,H)\),
- prints the compression values,
- verifies the chain rule numerically,
- highlights any counterexample,
- visualizes the “information decomposition” for a chosen triple.

A simple table or graph is enough.

---

## Falsifiable conjectures for FUTURE_DIRECTIONS.md

You must include 3–5 testable hypotheses. At least one should be a serious strengthening and at least one should be a plausible failure mode.

Examples:

1. **Conditional nonnegativity conjecture.**
   For every finite site and presheaves \(F,G,H\),
   \[
   I_{\mathrm{sh}}(F;H\mid G)\ge 0.
   \]
   **Test:** exhaustive search on all presheaf triples over categories with at most 3 objects and bounded section sizes.

2. **Submodularity conjecture.**
   The function \(K(F):=\kappa_{\mathrm{sh}}(J,F)\) is submodular with respect to coproduct decomposition.
   **Test:** verify
   \[
   K(F\oplus G)+K(G\oplus H)\ge K(G)+K(F\oplus G\oplus H)
   \]
   on exhaustive small examples.

3. **Capacity upper-bound conjecture.**
   Mutual compression is bounded by a logarithmic profile-capacity surrogate derived from `card_hom_le_profile_capacity`.
   **Test:** compute both sides on enumerated finite examples.

4. **Interaction-sign conjecture.**
   The ternary interaction
   \[
   I_{\mathrm{sh}}(F;G;H):=I_{\mathrm{sh}}(F;G)+I_{\mathrm{sh}}(F;H)-I_{\mathrm{sh}}(F;G\oplus H)
   \]
   can be negative, indicating categorical synergy.
   **Test:** brute-force search for first negative instance.

5. **Data-processing-style conjecture.**
   If \(G\to H\) is a morphism preserving witness profiles in a suitable sense, then
   \[
   I_{\mathrm{sh}}(F;H)\le I_{\mathrm{sh}}(F;G).
   \]
   **Test:** enumerate profile-preserving maps on small finite examples.

A single counterexample is scientifically meaningful. If the strongest conjecture fails, pivot and characterize the obstruction.

---

## Lean execution guidance

You should aim for a file containing:
- one new definition block for conditional/relative compression,
- auxiliary lemmas for coproduct reassociation transport,
- at least three substantial theorems,
- one theorem explicitly using catalog results as imported lemmas,
- one theorem or construction bridging to counting/capacity.

Use deep proof tactics:
- `induction` where presheaves or finite object enumerations are recursively analyzed,
- `rcases` to unpack witness/profile structures,
- `by_contra` for monotonicity/nonnegativity contradictions,
- `field_simp` if you pass to rationalized/counting forms,
- multi-step `calc` blocks for chain-rule algebra.

Do not settle for a theorem that is true by unfolding a definition and using `rfl`. If a quantity is defined by difference, the theorem must identify it with a nontrivial defect/witness formula or derive a substantial inequality from it.

---

## Deliverables (ALL mandatory)

You must produce all of the following:

1. **Lean development** with at least 3 nontrivial theorems and minimal `sorry`.
2. **A structured `FUTURE_DIRECTIONS.md`** containing 3–5 falsifiable scientific hypotheses with explicit computational tests.
3. **A standalone `RESEARCH_PAPER.md`** explaining the definitions, theorem statements, proof ideas, significance, computational experiments, and next questions. It must be readable without code access.
4. **An `ARTICLE.md` in Scientific American style** explaining the ideas and why they matter to a broad audience. Do not focus on formal verification machinery.
5. **A verified algorithm or computational method** for computing/testing the compression-information quantities.
6. **A `demo.py`** that interactively demonstrates the theorem and/or searches for counterexamples.

---

## Application keywords

categorical information theory; chain rule; conditional mutual information; sheaf compression; presheaf complexity; finite sites; coproduct subadditivity; profile capacity; submodularity; polymatroids; contextual compression; interaction information; witness decomposition; combinatorial category theory; statistical mechanics analogy; data processing inequality; algorithmic discovery; exhaustive finite search

---

## Final call

Do not merely prove a lemma. Build the first credible **calculus of conditional information for sheaf compression**. Either prove the chain rule in a robust defect-relative form, or discover the precise obstruction and formalize the corrected law. In either case, the result should teach us something new about how information lives in categories.

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
