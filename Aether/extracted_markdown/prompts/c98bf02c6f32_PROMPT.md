## Assignment: Direction 1: Complete Verified Regev Reduction

**Mode:** prove

Prove genuinely new, non-trivial theorems that push the existing catalog from “formalized fragments of LWE security” to a **complete verified hardness pipeline**. Build explicitly on the catalog theorems below, minimize `sorry`, and aim for a result that would constitute the first machine-checked worst-case-to-average-case hardness proof for a post-quantum primitive.

## Core Vision

The target is not another local lemma in LWE formalization. The target is a **modular theorem architecture for the Regev reduction itself**:

> worst-case lattice hardness  
> `→` bounded distance decoding / structured coset decoding  
> `→` discrete Gaussian / Fourier sampling interface  
> `→` search-LWE  
> `→` decision-LWE  
> `→` modulus and dimension management via linear/quotient pushforwards.

The breakthrough is to show that the reduction is not an opaque cryptographic monolith, but a composition of **module-theoretic, measure-theoretic, and quotient-functorial invariants** that can each be formally verified and recombined.

If this works, it opens a new field: **certified cryptographic hardness transfer**. Not just verified implementations, but verified *security origins*.

---

## Exact Research Goal

Formalize a decomposition of the Regev reduction into four machine-verifiable components and prove at least three deep new theorems that certify the compositional correctness of the reduction under explicit hypotheses.

### Master theorem target

A precise target theorem should have the following shape:

> If a family of lattice instances admits a worst-case reduction to a bounded-distance decoding problem over a finitely generated free `ℤ`-module, and if the induced sampling map produces an average-case error distribution whose pushforward under the quotient/dimension reduction map contracts total variation distance, then any distinguisher for the resulting decision-LWE distribution yields a solver for the original worst-case instance.

This should be broken into Lean-checkable intermediate statements, not attempted in one jump.

---

## Precise Theorem Statements to Target

You should aim to prove versions of the following theorems with exact hypotheses made Lean-friendly.

### Theorem 1: TVD contraction under quotient/module morphisms
This is the formal bridge from modulus/dimension reduction to preserved indistinguishability.

**Mathematical statement.**  
Let `f : M →ₗ[R] N` be a linear map between finite modules, and let `μ ν` be probability distributions on `M`. Then pushing forward along `f` cannot increase total variation distance:
\[
\operatorname{TVD}(μ.map\,f,\; ν.map\,f) \le \operatorname{TVD}(μ,\;ν).
\]
Moreover, if `f` is a quotient map compatible with the LWE secret/noise decomposition, then every hybrid gap in the quotient system is bounded by the corresponding hybrid gap upstairs.

**Lean 4 type signature sketch.**
```lean
theorem tvd_contracts_under_module_quotient
  {R M N : Type*}
  [CommRing R]
  [AddCommGroup M] [Module R M]
  [AddCommGroup N] [Module R N]
  [Fintype M] [Fintype N] [DecidableEq M] [DecidableEq N]
  (f : M →ₗ[R] N)
  (μ ν : PMF M) :
  tvd (μ.map f) (ν.map f) ≤ tvd μ ν
```

A strengthened version specialized to affine-LWE pushforwards is even better:
```lean
theorem lwe_hybrid_gap_contracts_under_quotient
  {R M N : Type*}
  [CommRing R]
  [AddCommGroup M] [Module R M]
  [AddCommGroup N] [Module R N]
  [Fintype M] [Fintype N] [DecidableEq M] [DecidableEq N]
  (q : M →ₗ[R] N)
  (D₀ D₁ : PMF M)
  (hq : IsQuotientCompatible q D₀ D₁) :
  tvd (D₀.map q) (D₁.map q) ≤ tvd D₀ D₁
```

### Theorem 2: Hybrid telescope for composed reductions
This upgrades the existing hybrid telescope into a reusable theorem for chained reductions.

**Mathematical statement.**  
Given distributions `H₀, H₁, ..., Hₙ` on a finite module, if each adjacent pair differs by a bounded advantage after a compatible linear/affine map, then the total distinguishing advantage is bounded by the sum of the local advantages:
\[
\operatorname{TVD}(H_0,H_n)\le \sum_{i=0}^{n-1}\operatorname{TVD}(H_i,H_{i+1}).
\]
The point is not the inequality alone, but its **instantiation to the exact hybrids used in search→decision and modulus/dimension reduction**.

**Lean 4 type signature sketch.**
```lean
theorem composed_hybrid_telescope_bound
  {α : Type*} [Fintype α] [DecidableEq α]
  (H : Fin (n + 1) → PMF α) :
  tvd (H 0) (H ⟨n, Nat.lt_succ_self n⟩)
    ≤ ∑ i : Fin n, tvd (H (Fin.castSucc i)) (H i.succ)
```

A more cryptographic version:
```lean
theorem affine_hybrid_telescope_bound
  {R M : Type*}
  [CommRing R] [AddCommGroup M] [Module R M]
  [Fintype M] [DecidableEq M]
  (H : Fin (n + 1) → PMF M)
  (hstep : ∀ i : Fin n, tvd (H (Fin.castSucc i)) (H i.succ) ≤ ε i) :
  tvd (H 0) (H ⟨n, Nat.lt_succ_self n⟩) ≤ ∑ i : Fin n, ε i
```

### Theorem 3: Search-to-decision transport through quotient-compatible structure
This theorem should package existing search→decision ingredients into a form that survives dimension/modulus reduction.

**Mathematical statement.**  
Suppose search-LWE reduces to a family of decision distinguishers coordinatewise, and suppose a quotient map preserves the affine error structure and contracts TVD. Then the search→decision reduction descends through the quotient.

This is the theorem that makes the existing catalog result part of the full Regev pipeline rather than a standalone fact.

**Lean 4 type signature sketch.**
```lean
theorem search_to_decision_descends_via_quotient
  {R M N : Type*}
  [CommRing R]
  [AddCommGroup M] [Module R M]
  [AddCommGroup N] [Module R N]
  [Fintype M] [Fintype N] [DecidableEq M] [DecidableEq N]
  (q : M →ₗ[R] N)
  (A : SearchToDecisionStructure R M)
  (hq : A.CompatibleWithQuotient q) :
  DecisionAdvantage N (A.pushforward q) ≤ SearchAdvantage M A
```

### Theorem 4: New structure theorem for module-theoretic Regev components
You are required to introduce at least one genuinely new definition. The right one here is a compositional object encoding the reduction interfaces.

**New definition proposal.**
```lean
structure RegevComponent (R X Y : Type*) [CommRing R] :=
  (stateMap    : X → Y)
  (distMap     : PMF X → PMF Y)
  (advBound    : ℝ≥0∞)
  (sound       : ∀ μ ν, tvd (distMap μ) (distMap ν) ≤ advBound + tvd μ ν)
```

Or, better adapted to modules:
```lean
structure ModuleReductionStep (R M N : Type*)
  [CommRing R] [AddCommGroup M] [Module R M]
  [AddCommGroup N] [Module R N] :=
  (map        : M →ₗ[R] N)
  (noisePush  : PMF M → PMF N)
  (preservesAffineLWE : Prop)
  (tvd_bound  : ∀ μ ν, tvd (noisePush μ) (noisePush ν) ≤ tvd μ ν)
```

Then prove compositionality:

```lean
theorem ModuleReductionStep.comp_sound
  {R M N P : Type*}
  [CommRing R]
  [AddCommGroup M] [Module R M]
  [AddCommGroup N] [Module R N]
  [AddCommGroup P] [Module R P]
  [Fintype M] [Fintype N] [Fintype P]
  [DecidableEq M] [DecidableEq N] [DecidableEq P]
  (S₁ : ModuleReductionStep R M N)
  (S₂ : ModuleReductionStep R N P) :
  ∀ μ ν, tvd ((S₂.noisePush) ((S₁.noisePush) μ))
              ((S₂.noisePush) ((S₁.noisePush) ν))
        ≤ tvd μ ν
```

This is not just software architecture. It is the mathematical claim that the Regev reduction can be decomposed into certified morphisms in a category of hardness-preserving distributional systems.

---

## Required Components to Formalize

### 1. GapSVP → BDD reduction interface
You do **not** need the full analytic geometry of every lattice theorem immediately. But you should formalize a module-theoretic shell that isolates exactly what the later stages need.

Target: define a `BDDInstance` / `LatticeDecodingInstance` structure with:
- ambient free `ℤ`-module,
- lattice basis / submodule,
- target point,
- decoding radius,
- uniqueness or bounded-distance hypothesis.

Then prove at least one nontrivial theorem showing uniqueness or stability of decoding under a radius hypothesis. This gives the formal output type for the worst-case reduction.

Possible Lean sketch:
```lean
structure BDDInstance where
  (n : ℕ)
  (Λ : Submodule ℤ (Fin n → ℤ))
  (target : Fin n → ℤ)
  (radius : ℝ)
  (wellSeparated : Prop)
```

A meaningful theorem:
```lean
theorem bdd_solution_unique
  (I : BDDInstance)
  (hsep : I.wellSeparated)
  : ∀ x y ∈ I.Λ, withinRadius I.target x I.radius →
                 withinRadius I.target y I.radius →
                 x = y
```

### 2. Quantum/discrete Gaussian sampling interface
This is the mathematically dangerous part and therefore the most important.

Do not promise full quantum semantics unless you can support it. Instead define a **formal interface theorem** that captures exactly what the reduction needs: a sampler whose output law approximates a target discrete Gaussian with certified moments or TVD bound.

New definition idea:
```lean
structure ApproxDiscreteGaussian (α : Type*) :=
  (sample : PMF α)
  (target : PMF α)
  (momentBound : ℕ → ℝ → Prop)
  (tvdError : ℝ≥0∞)
  (certified : tvd sample target ≤ tvdError)
```

Then prove compositional statements such as:
- pushforward preserves certified approximation,
- hybrid replacement cost is additive,
- quotienting the ambient module does not worsen approximation error.

These theorems are mathematically substantial and fit the reduction.

### 3. Search-LWE → Decision-LWE
Build directly on:
- `Cryptography/LWE/Security.lean`
- `Cryptography/ModuleLWE/SearchDecision.lean`
- especially `search_from_decision_as_special_case`,
  `search_from_decision_coordinate`,
  `hybrid_telescope_bound`,
  `abstract_hybrid_telescope`.

Do not merely restate the existing theorem. Repackage it so it composes with quotient maps and module morphisms.

### 4. Dimension/modulus reduction as quotient map
This is likely the cleanest deep theorem zone. Formalize modulus reduction as a linear or affine quotient-compatible pushforward and show:
- induced distribution is still an LWE-type affine-noise distribution,
- TVD contracts,
- search→decision compatibility descends.

This is where the catalog theorem
`tvd_contracts_under_linear_pushforward`
should become a cornerstone.

---

## Proof Strategy Architecture

You must provide and pursue 2–3 viable proof paths. Do not lock into one too early.

### Strategy A: Category-of-reductions approach
1. Define a new compositional structure (`ModuleReductionStep`, `RegevComponent`, or similar) whose morphisms are distribution transformers equipped with TVD monotonicity/soundness.
2. Show catalog theorems instantiate these morphisms:
   - hybrid telescope gives compositional advantage accounting,
   - TVD contraction gives functoriality under pushforward,
   - search→decision gives a terminal morphism from search hardness to decision hardness.
3. Prove the Regev pipeline by composition of certified morphisms.

**Why promising:** this turns a long cryptographic proof into a small number of algebraic invariants. It is the cleanest path to a reusable hardness-transfer framework.

### Strategy B: Concrete finite-module hybridization
1. Work over finite modules first (`ZMod q`, finite free modules, finitely supported PMFs).
2. Define the exact hybrids for modulus reduction and decision-LWE.
3. Prove every local hybrid step with explicit `calc`, `rcases`, TVD inequalities, and telescoping sums.
4. Only then abstract to generic module-theoretic statements.

**Why promising:** Lean is often easier on concrete finite objects than on highly abstract interfaces. This is likely the best route for getting the first complete proof artifact.

### Strategy C: Approximation-interface for the quantum step
1. Avoid full quantum circuit semantics initially.
2. Introduce an abstract certified sampler object with explicit TVD/moment guarantees.
3. Prove the rest of the Regev reduction parametrically in such a sampler.
4. Later, separately instantiate the sampler with a verified discrete Gaussian procedure.

**Why promising:** it isolates the hardest analytic/quantum part without blocking the entire reduction. This gives a theorem of the form “if the sampler exists with these certified properties, the reduction is complete.”

**Most promising overall:** combine **B + C** first, then refactor into **A**. Concrete finite-module proofs will land fastest; the abstract compositional structure can then be extracted from the successful proof.

---

## Deep Proof Tactics Requirement

Your file must contain at least 3 substantial theorems proved using multi-step reasoning. Suitable proof patterns include:
- induction on hybrid length,
- `rcases` decomposition of quotient-compatible structures,
- `by_contra` to prove uniqueness/separation in BDD-style lemmas,
- `field_simp` in probability mass normalization identities,
- long `calc` chains for TVD inequalities and pushforward monotonicity.

In particular, the following theorem types are ideal for the “deep proof tactics” requirement:
1. induction-based hybrid telescope,
2. `by_contra` uniqueness theorem for bounded decoding,
3. `calc`-driven contraction/composition theorem for TVD under chained pushforwards.

---

## Cross-Domain Connections You Must Exploit

This project is powerful precisely because it is not “just cryptography.”

### Lattice geometry ↔ module theory
A lattice basis becomes a finitely generated free `ℤ`-module with submodule structure; decoding becomes a uniqueness statement in a metric neighborhood of a coset.

### probability theory ↔ algebra
LWE hardness is fundamentally a statement about **affine pushforwards of distributions** over finite modules. TVD contraction is a probabilistic shadow of algebraic functoriality.

### quantum computation ↔ certified approximation theory
The quantum sampling step can be reframed as a certified approximation interface: the reduction only needs output-law guarantees, not necessarily full circuit semantics at first pass.

### category theory / compositional semantics ↔ cryptographic reductions
The whole Regev reduction can be viewed as composition in a category whose morphisms preserve bounded distinguishing advantage. This is a new conceptual language for formal cryptography.

### formal methods ↔ post-quantum standardization
A verified Regev reduction would connect proof assistant technology directly to NIST-grade security foundations.

---

## Catalog Theorems to Build On

Use these concretely, not decoratively:

- `Cryptography/LWE/Security.lean`
  - `search_from_decision_coordinate`
  - `hybrid_telescope_bound`
- `Cryptography/ModuleLWE/SearchDecision.lean`
  - `abstract_hybrid_telescope`
  - `search_from_decision_as_special_case`
- `Cryptography/ModuleLWE/TVDContraction.lean`
  - `tvd_contracts_under_linear_pushforward`

You should explicitly state in comments or theorem docs how each new theorem depends on one or more of these.

Example of intended dependency pattern:
- use `tvd_contracts_under_linear_pushforward` to prove quotient reduction cannot amplify distinguishing advantage;
- use `abstract_hybrid_telescope` to aggregate local errors from coordinate replacement / modulus reduction;
- use `search_from_decision_as_special_case` as the terminal step after transporting the instance through quotient-compatible maps.

---

## Concrete Lemma Decomposition Target

Break the work into 8–12 independent lemmas. A suggested decomposition:

1. Define `ModuleReductionStep` or `RegevComponent`.
2. Prove identity step soundness.
3. Prove composition soundness.
4. Define quotient-compatible affine LWE instance.
5. Prove pushforward of affine LWE under quotient remains affine LWE.
6. Prove TVD contraction for that pushforward.
7. Prove hybrid telescope for a chain of quotient-compatible hybrids.
8. Define `ApproxDiscreteGaussian`.
9. Prove approximation error composes additively through hybrids.
10. Prove search→decision descends through quotient.
11. Define BDD interface object.
12. Prove a uniqueness/stability theorem for BDD instances.

If you complete these, the master theorem becomes realistic.

---

## Falsifiable Conjecture With Clear Computational Test

You must include at least one explicit conjecture in the code/comments and in `FUTURE_DIRECTIONS.md`.

### Conjecture A: Quotient-stable Gaussian hardness transport
For every finite free `ℤ/qℤ`-module `M`, every quotient-compatible linear map `q : M →ₗ[R] N`, and every certified approximate discrete Gaussian error law `χ` on `M`, the induced decision-LWE advantage after pushforward is never greater than the original advantage, up to the certified Gaussian approximation error.

**Test:**  
For small parameters `q ≤ 11`, dimensions `n ≤ 4`, and explicit finitely supported noise laws approximating discrete Gaussians, enumerate:
- original LWE distribution,
- quotient-pushforward LWE distribution,
- uniform baseline,
and compute exact TVD values. A single counterexample where quotient advantage exceeds the predicted bound falsifies the conjecture.

### Conjecture B: Module-theoretic completeness of the Regev reduction
Every non-quantum step of the classical Regev reduction can be expressed as a composition of `ModuleReductionStep`s with no appeal to analytic machinery beyond finitely supported PMFs and linear pushforwards.

**Test:**  
Attempt formalization of each step. The conjecture is falsified if some essential step cannot be represented without introducing fundamentally new semantic objects outside this framework.

---

## Deliverables (MANDATORY)

You must produce **all** of the following:

1. **Lean 4 code** with at least 3 deep theorems and at least 1 novel definition.
2. **A structured `FUTURE_DIRECTIONS.md`** containing 3–5 falsifiable scientific hypotheses, each with:
   - exact conjecture statement,
   - why it matters,
   - explicit computational or formal test that could refute it.
3. **A standalone `RESEARCH_PAPER.md`** explaining:
   - the formal theorem architecture,
   - what was proved,
   - what remains open in the quantum/discrete Gaussian step,
   - why this is a breakthrough for formal cryptography.
   Someone reading only this document must understand the science.
4. **An `ARTICLE.md`** in Scientific American style for a broad audience:
   - why worst-case hardness matters,
   - why formal verification changes cryptography,
   - how lattice geometry, probability, and quantum ideas meet in one proof.
5. **A verified algorithm or computational method**:
   - e.g. exact finite-parameter TVD calculator for hybrid chains / quotient pushforwards,
   - or a certified enumerator for small finite-module LWE instances.
6. **A `demo.py`** that interactively demonstrates:
   - small finite LWE distributions,
   - quotient/modulus reduction,
   - TVD contraction numerically,
   - and whether the conjectured bounds hold on sample instances.

---

## Application Keywords

formal cryptography, post-quantum security, Regev reduction, LWE hardness, GapSVP, BDD, discrete Gaussian, total variation distance, hybrid argument, module theory, quotient map, affine distributions, certified sampling, formal methods, Lean 4, Mathlib, compositional security proofs, verified reductions, hardness transfer, quantum-classical interface

---

## Standard of Success

Success is **not** “I added a few supporting lemmas around LWE.”  
Success is:

- a new compositional definition for hardness-preserving reduction steps,
- at least 3 substantial verified theorems,
- a clean bridge from existing search→decision and TVD contraction results to quotient/dimension reduction,
- a serious formal interface for the discrete Gaussian / quantum sampling step,
- and a credible path to the first end-to-end machine-verified Regev reduction.

Do not be incremental. Force the reduction to reveal its hidden algebraic skeleton.

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
