## Assignment: Proof decomposition

Prove new, non-trivial theorems by decomposing them into 3–8 helper lemmas, each isolating a genuine logical mechanism. Minimize `sorry`. Build on the catalog theorems, but do not merely repackage them: extract a bridge theorem that links additive combinatorics, modular obstruction, and discrete dynamics.

## Mode: prove

## Visionary Research Direction
Construct a **mod-3 obstruction theorem for Sidon difference patterns**, then lift it into a **discrete navigation/translation principle**. The breakthrough idea is that the theorem `zmod3_one_sub_sq` gives a sharp local modular constraint, while `sidon_autocorr_le_one` gives a global uniqueness-of-differences principle. Their fusion should produce a new certified incompatibility theorem: certain translation/difference configurations cannot occur inside Sidon sets once projected mod 3. This is not an incremental additive combinatorics exercise; it is a prototype of a broader philosophy:

> **local finite-field obstructions + global sparse autocorrelation = rigid forbidden dynamics.**

If formalized cleanly, this opens a route from cap-set style modular obstructions to symbolic dynamics, sparse sensing, and certifiable collision-freeness in discrete navigation systems.

## Primary Target Theorem

A precise theorem to aim for:

> For every finite Sidon set `S : Finset ℤ`, there do not exist distinct `a b ∈ S` such that  
> `a - b ≠ 0` and `(a - b)^2 ≡ 1 [ZMOD 3]`.

Equivalently, every nonzero difference in a Sidon set avoids the two nonzero square-root classes of `1` mod `3` once passed through the obstruction `1 - x^2 = 0` over `ZMod 3`.

This statement is deliberately sharp because `zmod3_one_sub_sq` classifies the only residues mod 3, and `sidon_autocorr_le_one` ensures that if such a residue class difference is realized, it is uniquely realized. The real opportunity is then to derive a stronger **forbidden-translation** corollary.

### Lean 4 candidate statement
A realistic first formal target is:

```lean
theorem sidon_no_nonzero_diff_sq_eq_one_mod3
    (S : Finset ℤ) (hS : IsSidonSet S) :
    ∀ a ∈ S, ∀ b ∈ S, a ≠ b →
      ¬ (((((a - b : ℤ) : ZMod 3) ^ 2) = 1)) := by
```

A more structural variant, likely better for reuse:

```lean
theorem sidon_diff_mod3_forbidden
    (S : Finset ℤ) (hS : IsSidonSet S) :
    ∀ d : ℤ, d ≠ 0 →
      (∃ a ∈ S, ∃ b ∈ S, a - b = d) →
      ((((d : ℤ) : ZMod 3) ^ 2) ≠ 1) := by
```

If the exact theorem above turns out false in full generality, pivot immediately to the **certified uniqueness theorem** below, which is still strong and likely true:

```lean
theorem sidon_diff_sq_eq_one_mod3_unique
    (S : Finset ℤ) (hS : IsSidonSet S) :
    ∀ d : ℤ, d ≠ 0 → ((((d : ℤ) : ZMod 3) ^ 2) = 1) →
      (Finset.card
        (S.filter fun a => (S.filter fun b => a - b = d).Nonempty) ≤ 1) := by
```

That version directly uses `sidon_autocorr_le_one` and is a better stepping stone toward dynamics.

## Why this would be a breakthrough
This would create a new certified bridge between:
- **additive combinatorics**: Sidon uniqueness of differences,
- **finite-field obstruction theory**: `ZMod 3` square classification,
- **discrete dynamics / navigation**: translation patterns and forbidden steps,
- **spectral simulation**: collision-free trajectories as bounded autocorrelation objects.

The larger field-opening move is to show that modular residue obstructions can certify impossibility of certain sparse dynamical patterns. This is the kind of theorem that could evolve into:
- symbolic dynamics with arithmetic certificates,
- sparse coding with modular collision avoidance,
- tropical/discrete analogues of spectral exclusion principles.

## Catalog Theorems to Build On

1. `zmod3_one_sub_sq`
   - Use it as a complete residue classifier in `ZMod 3`.
   - Likely gives a statement equivalent to: for every `x : ZMod 3`, `1 - x^2 = 0` iff `x = 1 ∨ x = -1`, or at least enough to reduce all possibilities by finite computation.
   - This theorem should be the modular obstruction engine.

2. `sidon_autocorr_le_one`
   - Use it to control multiplicity of solutions to `a - b = d`.
   - This is the global rigidity input: any nonzero difference occurs at most once.

3. `step_on_each_dir_is_translation`
   - Once the additive theorem is proved, reinterpret differences as translation steps in a discrete state space.
   - This lets you formulate a corollary saying that if a trajectory indexed by a Sidon support has step differences constrained mod 3, then each direction step is collision-free or forbidden.

4. `navigation_step_bound`
   - Potentially use it for a finitary corollary: forbidden modular steps imply a lower bound on the number of navigation moves needed to realize a target.
   - Even if not used in the main proof, it should appear in the applications/FUTURE_DIRECTIONS as the dynamics extension.

5. `hamiltonian_simulation_step_bound`
   - This suggests a spectral/dynamical analogy: forbidden arithmetic transitions induce simulation lower bounds.
   - Use as motivation for future theorem statements linking modular obstructions to simulation complexity.

## Proof Decomposition: 3–8 Helper Lemmas

You should explicitly break the main theorem into helper lemmas like the following.

### Helper Lemma 1: classify square residues mod 3
```lean
lemma zmod3_sq_eq_zero_or_one (x : ZMod 3) :
    x^2 = 0 ∨ x^2 = 1 := by
```
Purpose:
- Extract a reusable classification lemma from `zmod3_one_sub_sq`.
- This is the local finite-field backbone.

### Helper Lemma 2: nonzero mod-3 elements square to one
```lean
lemma zmod3_ne_zero_implies_sq_eq_one (x : ZMod 3) (hx : x ≠ 0) :
    x^2 = 1 := by
```
Purpose:
- Turn the classification into a convenient forward-use lemma.
- This will likely be the most useful API for downstream proofs.

### Helper Lemma 3: Sidon difference uniqueness
```lean
lemma sidon_diff_unique
    (S : Finset ℤ) (hS : IsSidonSet S)
    {a₁ a₂ b₁ b₂ : ℤ}
    (ha₁ : a₁ ∈ S) (ha₂ : a₂ ∈ S)
    (hb₁ : b₁ ∈ S) (hb₂ : b₂ ∈ S)
    (h : a₁ - b₁ = a₂ - b₂)
    (hneq : a₁ - b₁ ≠ 0) :
    a₁ = a₂ ∧ b₁ = b₂ := by
```
Purpose:
- Repackage `sidon_autocorr_le_one` into an equality principle, easier to deploy than a cardinality bound.

### Helper Lemma 4: realization of a forbidden residue forces unique witness
```lean
lemma sidon_mod3_diff_witness_unique
    (S : Finset ℤ) (hS : IsSidonSet S)
    (d : ℤ) (hd : d ≠ 0)
    (hmod : ((((d : ℤ) : ZMod 3) ^ 2) = 1)) :
    ∃! p : ℤ × ℤ, p.1 ∈ S ∧ p.2 ∈ S ∧ p.1 - p.2 = d := by
```
Purpose:
- Fuse modular classification with Sidon uniqueness.
- This is the true bridge lemma.

### Helper Lemma 5: translation form of difference witnesses
```lean
lemma diff_eq_translation_form
    {a b d : ℤ} (h : a - b = d) :
    a = b + d := by
```
Purpose:
- Trivial algebraically, but crucial for feeding the result into navigation/translation theorems.

### Helper Lemma 6: forbidden translation corollary
A domain-bridging corollary, perhaps after defining a translated finite set:
```lean
theorem sidon_translation_collision_free_mod3
    (S : Finset ℤ) (hS : IsSidonSet S) (d : ℤ) (hd : d ≠ 0)
    (hmod : ((((d : ℤ) : ZMod 3) ^ 2) = 1)) :
    ∀ a₁ ∈ S, ∀ a₂ ∈ S,
      a₁ + d ∈ S → a₂ + d ∈ S → a₁ = a₂ := by
```
Purpose:
- This is a real theorem with dynamical meaning: a “step by `d`” acts injectively on the support, and under Sidon rigidity there is at most one active translated edge.
- This is the cleanest additive-combinatorics-to-navigation bridge.

## 2–3 Proof Strategies

### Strategy A: Direct modular classification + autocorrelation uniqueness
1. Derive `zmod3_ne_zero_implies_sq_eq_one` from `zmod3_one_sub_sq`.
2. Use `sidon_autocorr_le_one` to show each nonzero difference `d` is realized by at most one ordered pair.
3. Convert `a - b = d` into a translation statement `a = b + d`, and conclude uniqueness/collision-freeness for step-`d` translations.

Why promising:
- Closest to the catalog.
- Minimal new definitions.
- Likely the fastest route to a formal theorem with clean APIs.

### Strategy B: Difference-set formalization
1. Define the difference multiset or filtered witness set
   `Δ_d(S) = {(a,b) ∈ S × S | a - b = d}`.
2. Prove `card Δ_d(S) ≤ 1` from `sidon_autocorr_le_one`.
3. Prove that if `d mod 3 ≠ 0`, then `((d : ZMod 3)^2 = 1)` by finite-field classification, yielding a modularly certified uniqueness theorem for all `d` not divisible by `3`.

Why promising:
- More reusable.
- Sets up a robust interface for future additive-energy and sparse-dynamics work.
- Best if you want a theorem family rather than one isolated result.

### Strategy C: Contrapositive / collision argument
1. Assume two distinct translated witnesses exist for the same step `d`.
2. Show this gives two distinct pairs with equal nonzero difference.
3. Contradict `sidon_autocorr_le_one`.

Why promising:
- Simpler proof scripts.
- Good for the final translation theorem.
- Best as the proof of the corollary, even if Strategy A or B establishes the infrastructure.

**Most promising overall:** Strategy B for architecture, Strategy C for the final corollary. Strategy A is the fastest bootstrap path.

## Cross-Domain Connections
Do not leave this as pure additive combinatorics. Explicitly connect it to at least one of the following:

### 1. Discrete navigation and robotics
Use `step_on_each_dir_is_translation` to reinterpret a difference `d` as a legal move. Then the theorem says:
- certain modularly classified steps can occur at most once on a Sidon-supported trajectory,
- hence arithmetic sparsity certifies collision-free motion primitives.

This is a prototype of **formal verification for arithmetic motion planning**.

### 2. Spectral simulation / Hamiltonian complexity
Use `hamiltonian_simulation_step_bound` as motivation for a follow-up:
- if transitions with certain modular signatures are unique or forbidden, then simulation paths require extra steps,
- suggesting arithmetic lower bounds for discrete simulation complexity.

This is a prototype of **number-theoretic obstructions to simulation compression**.

### 3. Sparse sensing and coding theory
A Sidon set is a low-autocorrelation support. Your theorem says modular residue information certifies uniqueness of certain shifts. That is exactly the kind of structure used in:
- synchronization codes,
- sparse recovery,
- radar ambiguity control,
- compressed sensing with arithmetic side constraints.

### 4. Tropical/discrete geometry
The translation theorem suggests a tropical viewpoint: supports with unique difference realizations behave like rigid one-skeletons under min-plus translation. This could evolve into “tropical autocorrelation rigidity.”

## Application Keywords
Sidon sets; autocorrelation; modular obstruction; `ZMod 3`; discrete translation; collision-free dynamics; sparse coding; symbolic dynamics; Hamiltonian simulation complexity; arithmetic motion planning; tropical rigidity; certified uniqueness.

## Concrete Deliverables

1. Formalize 3–8 helper lemmas, not one monolithic proof.
2. Prove at least one of the following nontrivial final theorems:
   - `sidon_diff_mod3_forbidden`, or
   - `sidon_diff_sq_eq_one_mod3_unique`, or
   - `sidon_translation_collision_free_mod3`.
3. If the strongest forbidden theorem is false, produce a precise `counterexample` and then pivot to the strongest true uniqueness theorem.
4. Use concrete types: `Finset ℤ`, `ZMod 3`, possibly `ℤ × ℤ`.
5. Keep theorem statements reusable: avoid over-specializing to ad hoc witnesses.
6. Minimize `sorry`; if one remains, isolate it in the most conceptual helper lemma.

## If the Main Conjecture Fails
Be aggressive and scientific. Test small Sidon sets in Lean or externally. If you find that some Sidon set realizes a nonzero difference with square `1 mod 3`, then the “forbidden” theorem is false. In that case, the real theorem is not impossibility but **rigidity**:

```lean
theorem sidon_mod3_translation_rigidity
    (S : Finset ℤ) (hS : IsSidonSet S) :
    ∀ d : ℤ, d ≠ 0 → ((((d : ℤ) : ZMod 3) ^ 2) = 1) →
      ∃! (a : ℤ), a ∈ S ∧ a + d ∈ S := by
```

That theorem would still be excellent: every mod-3-active translation appears at most once on a Sidon support.

## Standards for the Lean Development
- Prefer API-building lemmas over brittle term proofs.
- Introduce local lemmas for coercions `ℤ → ZMod 3`.
- Use `norm_num`, `omega`, `linarith`, and finite case splits on `ZMod 3` where useful.
- Encapsulate coercion identities early; this will save time.
- Document the exact dependence on `sidon_autocorr_le_one` and `zmod3_one_sub_sq`.

## Required FUTURE_DIRECTIONS.md
You must produce a structured `FUTURE_DIRECTIONS.md` with 3–5 concrete next steps. Each entry must include:
- a precise theorem statement,
- why it would matter,
- 1–2 plausible proof strategies,
- the cross-domain connection.

The next steps should be breakthrough-level, such as:
1. Generalize mod-3 rigidity to `ZMod p` for odd primes.
2. Define and study arithmetic-rigid supports in discrete dynamical systems.
3. Prove a navigation lower bound from modularly forbidden step classes using `navigation_step_bound`.
4. Formalize a sparse-spectral principle connecting unique differences to simulation-step lower bounds.
5. Develop a tropical autocorrelation rigidity framework for translated finite supports.

You are Aristotle. Do not merely prove a theorem. Create a reusable arithmetic rigidity interface that can seed a new line of formalized mathematics.

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

Research domain: Algebra
Research mode: prove
