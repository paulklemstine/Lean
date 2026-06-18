## Assignment: Tropical Energy Interpretation of Normalization

**Mode:** prove

Prove genuinely new, non-trivial theorems in Lean 4 about a tropical/energy semantics for typed normalization. Build a new bridge between proof theory, tropical geometry, and discrete physics. Minimize sorry.

The core vision is not merely to show termination again. It is to **re-express normalization as irreversible energy dissipation**: β-reduction becomes a certified downhill flow in a combinatorial potential landscape. If formalized correctly, this opens a new language for relating lambda calculus, optimization, tropical algebra, and Lyapunov-style stability theory.

## Central Breakthrough Target

You should not stop at a vague conjecture. Aim to prove a theorem of the following shape for a simply typed term language `STm Γ A` with a one-step reduction relation `Step : STm Γ A → STm Γ A → Prop`.

### Precise theorem statement
Construct an explicit potential
\[
\Phi_{\delta,w} : STm\,\Gamma\,A \to \mathbb N
\]
depending on:
- a **type-depth function** `δ : Ty → ℕ`,
- a **weight profile** `w : ℕ → ℕ`,
such that every β-step strictly decreases the potential:
\[
\forall t\,u,\; Step\,t\,u \to \Phi_{\delta,w}(u) < \Phi_{\delta,w}(t).
\]

The intended semantic reading is:
- type depth = tropical height,
- syntactic duplication cost = energy storage,
- β-reduction = dissipative release of stored energy.

### Lean 4 type signature target
Your formal target should look as close as possible to:

```lean
def typeDepth : Ty → ℕ
def tropicalPotential : {Γ : Ctx} → {A : Ty} → STm Γ A → ℕ

theorem tropicalPotential_strict_decrease
  {Γ : Ctx} {A : Ty} {t u : STm Γ A} :
  Step t u → tropicalPotential u < tropicalPotential t
```

If your reduction relation is polymorphic over contexts/types or indexed differently, adapt the signature but preserve the quantifier structure and strict inequality.

A stronger target, if feasible, is the transitive-closure version:

```lean
theorem tropicalPotential_decrease_reflTransGen
  {Γ : Ctx} {A : Ty} {t u : STm Γ A} :
  Relation.TransGen Step t u →
  t ≠ u →
  tropicalPotential u < tropicalPotential t
```

and then derive normalization/noetherianity as a corollary:

```lean
theorem no_infinite_descending_beta_chain
  {Γ : Ctx} {A : Ty} :
  WellFounded (@Step Γ A)
```

or an equivalent accessibility theorem.

## Novel definitions you must introduce

You are required to define at least one genuinely new concept. Do not merely rename size.

Recommended new structures:

```lean
def typeDepth : Ty → ℕ
```

```lean
def weightedSize : {Γ : Ctx} → {A : Ty} → STm Γ A → ℕ
```

```lean
def duplicationLoad : {Γ : Ctx} → {A : Ty} → STm Γ A → ℕ
```

```lean
def tropicalPotential : {Γ : Ctx} → {A : Ty} → STm Γ A → ℕ :=
  weightedSize t + duplicationLoad t
```

or, better, package the semantics:

```lean
structure TropicalEnergyModel where
  typeDepth : Ty → ℕ
  nodeWeight : ℕ → ℕ
  potential : {Γ : Ctx} → {A : Ty} → STm Γ A → ℕ
  beta_dissipative :
    ∀ {Γ A} {t u : STm Γ A}, Step t u → potential u < potential t
```

This would be mathematically important: it turns normalization proofs into the existence of a discrete dissipative system.

## Three theorem targets minimum

Your file must contain at least 3 substantial theorems with real proof structure. Suggested theorem stack:

### Theorem 1: Substitution energy bound
Prove a nontrivial upper bound showing how substitution changes weighted energy.

Mathematical form:
\[
\Phi(t[x:=s]) \le \Phi(t) + \operatorname{occ}_x(t)\cdot \Phi(s) + C(t,s),
\]
where the correction term depends on type depth / binder depth.

Possible Lean target:
```lean
theorem tropicalPotential_subst_bound
  {Γ : Ctx} {A B : Ty} (t : STm (A :: Γ) B) (s : STm Γ A) :
  tropicalPotential (subst t s) ≤
    tropicalPotentialLift t + freeOccurrencesTop t * tropicalPotential s
```

You may need an auxiliary lifted potential `tropicalPotentialLift` if substitution changes context structure. This theorem is the technical heart: β-reduction is difficult precisely because substitution can duplicate.

### Theorem 2: Strict decrease on β-redex contraction
For the canonical redex:
\[
(\lambda x.\, t)\, s \to_\beta t[x:=s],
\]
prove strict decrease.

Possible Lean target:
```lean
theorem tropicalPotential_beta
  {Γ : Ctx} {A B : Ty} (t : STm (A :: Γ) B) (s : STm Γ A) :
  tropicalPotential (subst t s) <
    tropicalPotential (app (lam t) s)
```

This is the flagship theorem. It should use your substitution bound plus a carefully designed penalty term for applications/lambdas.

### Theorem 3: Global strict decrease for arbitrary one-step reduction
Extend from head β-redexes to all contextual reduction rules.

Possible Lean target:
```lean
theorem tropicalPotential_strict_decrease
  {Γ : Ctx} {A : Ty} {t u : STm Γ A} :
  Step t u → tropicalPotential u < tropicalPotential t
```

This theorem should require `induction` on the derivation of `Step`, plus local monotonicity lemmas for each constructor/context rule.

### Strong optional theorem 4: Energy normalization principle
Show that every reduction sequence has length bounded by initial energy:
```lean
theorem reduction_length_le_potential
  {Γ : Ctx} {A : Ty} :
  ∀ {t u : STm Γ A},
  Relation.ReflTransGen Step t u →
  reductionLengthBound t u ≤ tropicalPotential t
```

Even if the exact sequence-length notion is awkward, prove an accessibility or well-foundedness result from strict descent on `ℕ`.

## Proof architecture: 3 possible strategies

### Strategy A: Direct syntactic Lyapunov function
1. Define `typeDepth` on types and a weighted node-count on terms.
2. Add a **duplication penalty** that overcharges applications and binder bodies enough to dominate substitution growth.
3. Prove substitution and β-step descent by induction on term structure.

Why this is promising:
- It is the most formalization-friendly path in Lean.
- It uses elementary combinatorics over syntax trees.
- It produces explicit constants and a directly executable algorithm.

Likely proof tactics:
- `induction t generalizing Γ`
- `rcases` on reduction derivations
- `calc` chains with arithmetic inequalities
- `omega`/`linarith` only as support, not as the substance
- `by_contra` to rule out non-strict cases when arithmetic saturation would imply impossible occurrence equalities

### Strategy B: Multiset/tropical interpretation of redexes
1. Interpret each term as a multiset of depth-weighted resources.
2. Map this multiset to a tropical scalar potential via min-plus or weighted sum.
3. Show β-contraction corresponds to strict multiset descent under a well-founded order.

Why this is deeper:
- It better reflects “tropical” semantics rather than just weighted size.
- It may connect to termination orders from rewriting theory.

Why it is harder:
- Formal multiset orders and contextual closure are more elaborate in Lean.
- Strict scalar extraction from multiset descent requires careful design.

This is a good second path if direct weighted-size proofs stall.

### Strategy C: Categorical/physics-inspired energy semantics
1. Define a compositional energy semantics: lambda stores potential, application releases it, substitution transports it.
2. Prove compositional inequalities for each constructor.
3. Derive β-dissipation as a discrete analog of a free-energy decrease law.

Why this matters:
- It opens a conceptual framework beyond a single theorem.
- It may lead to reusable abstractions for other calculi: linear λ-calculus, normalization by evaluation, proof nets.

Most promising route overall:
**Start with Strategy A**, but package the result in the language of Strategy C. That gives the best combination of proof tractability and conceptual novelty.

## Cross-domain connections you must explicitly include

At least one theorem must connect this topic to another mathematical domain. Strong options:

### 1. Proof theory + discrete dynamical systems
Interpret `tropicalPotential` as a **Lyapunov function** for the reduction system. Prove a theorem explicitly stating that one-step reduction defines a strictly dissipative discrete dynamical system on well-typed terms.

Possible formal theorem:
```lean
theorem beta_reduction_is_lyapunov_dissipative
  {Γ : Ctx} {A : Ty} :
  ∀ {t u : STm Γ A}, Step t u → tropicalPotential u < tropicalPotential t
```

The statement may coincide with the flagship theorem, but the paper should frame it as a dynamical-systems result.

### 2. Proof theory + tropical geometry
Define a “tropicalization” of a term as a depth profile vector or weighted support profile. Show that β-reduction strictly lowers a tropical scalarization of that profile.

Possible theorem pattern:
```lean
def tropicalProfile : STm Γ A → List ℕ
theorem beta_profile_lex_decrease ...
```

This would be exciting because it replaces bare size with a tropical-geometric invariant.

### 3. Proof theory + statistical physics / thermodynamics
Define energy and prove an entropy-like monotonicity surrogate, e.g. number of active redex opportunities decreases under a suitable weighted correction. Even a partial theorem here would be field-opening.

Application keywords:
**typed lambda calculus, tropical semantics, normalization, Lyapunov function, dissipative systems, proof theory, rewriting systems, min-plus algebra, thermodynamic interpretation, certified termination, symbolic optimization**

## How to build on existing verified theorems

The listed catalog theorems are from a different domain, but do not ignore them conceptually. Use them as a cue to be bold about **depth-indexed arithmetic invariants**. In particular, the theorem
`exists_depth_d_triple_with_hyp_le_iff`
signals that the library already supports precise reasoning with **depth-parameterized combinatorial quantities**. Your energy model should likewise be explicitly depth-sensitive, not just a crude size count.

Concretely:
- mimic the style of a depth-indexed invariant;
- define energy in terms of **type depth** or **binder depth**;
- isolate lemmas where a local rewrite causes a global decrease because a depth-sensitive weight collapses.

Do not force irrelevant Pythagorean content into the theorem statements, but do adopt the same research posture: depth-stratified arithmetic invariants can encode surprisingly strong global structure.

## Recommended theorem refinement: explicit candidate potential

A strong candidate is:
\[
\Phi(t)=\sum_{v \in \text{nodes}(t)} w(\mathrm{depthTy}(v))
\;+\;
\sum_{\text{applications }(f\,a)\subseteq t} \alpha
\;+\;
\sum_{\text{binders }\lambda x:A.\,u\subseteq t} \beta\cdot \mathrm{occ}_x(u)
\]
for suitably chosen weights `w`, `α`, `β`.

Interpretation:
- node weights capture structural mass,
- application surcharge captures pending computation,
- binder-occurrence surcharge anticipates substitution duplication.

A simpler executable variant:
```lean
def tropicalPotential : STm Γ A → ℕ
| var _   => 1
| lam t   => tropicalPotential t + 2
| app f a => tropicalPotential f + tropicalPotential a + 1 + redexHeadBonus f
```
where `redexHeadBonus` detects when `f` is a lambda or carries enough latent substitution cost.

If exact strict decrease fails, refine by adding:
- free occurrence counts,
- type-depth multipliers,
- context-sensitive redex penalties.

## Computational component you must verify

You must produce a verified algorithm, not just theorem statements.

### Required algorithm
Implement a computable candidate:
```lean
def tropicalPotential : STm Γ A → ℕ
```
and a checker/enumerator pipeline that tests the strict-decrease property on all well-typed terms up to bounded size.

If full enumeration of typed terms is difficult in Lean, you may:
- implement the certified potential in Lean,
- export/test candidate terms in `demo.py`,
- verify a large finite family computationally.

The key scientific loop is:
1. define candidate potential,
2. test on bounded terms,
3. inspect counterexamples,
4. refine the invariant,
5. formally prove the corrected theorem.

## Falsifiable conjectures for FUTURE_DIRECTIONS.md

You must include 3–5 testable hypotheses. At least one should be:

1. **Uniform dissipativity conjecture**  
   There exists a universal weight profile `w` depending only on type depth such that `tropicalPotential` strictly decreases for every simply typed β-step.  
   **Test:** Exhaustively enumerate well-typed terms up to size 20 and search for a counterexample.

Additional strong hypotheses:
2. **Linear bound conjecture**  
   Normalization length of `t : STm Γ A` is bounded above by `tropicalPotential t`.  
   **Test:** Compute maximal reduction lengths for all terms up to size `n ≤ 16` and compare.

3. **Tropical profile dominance conjecture**  
   A lexicographic tropical profile decreases even when scalar potential is not obviously strict.  
   **Test:** Search for terms where scalar decrease is small but profile decrease persists.

4. **Phase transition conjecture**  
   There is a critical weight parameter `β₀` such that strict descent fails below `β₀` and holds above it.  
   **Test:** Sweep weight parameters and detect first universal success on bounded enumeration.

5. **Transfer conjecture to linear logic terms**  
   The same energy semantics extends to a resource-sensitive calculus with sharper bounds.  
   **Test:** Implement a fragment and compare normalization-length/potential ratios.

## Deliverables (ALL mandatory)

You must produce all of the following:

1. **Lean file(s)** with at least 3 deep theorems, including induction / `rcases` / `by_contra` / `field_simp` / multi-step `calc` reasoning. No trivial theorem padding.

2. **FUTURE_DIRECTIONS.md**  
   Include 3–5 falsifiable scientific hypotheses with explicit computational tests.

3. **RESEARCH_PAPER.md**  
   A standalone scientific paper explaining:
   - the formal system,
   - the new tropical energy definitions,
   - the main theorems,
   - why this is a breakthrough,
   - limitations,
   - concrete next experiments.

4. **ARTICLE.md**  
   Scientific American style. Explain how a proof can “lose energy” as it simplifies, and why that matters for logic and computation.

5. **Verified algorithm / computational method**  
   The computable potential and a finite-search testing procedure for bounded terms.

6. **demo.py**  
   Interactive demonstration showing:
   - example terms,
   - their potentials,
   - one-step reductions,
   - observed energy drops,
   - optional search for counterexamples to naive candidate potentials.

## Standards and anti-goals

- Do **not** submit a glorified size-decreases-under-substitution lemma unless it yields genuine strict β-dissipation.
- Do **not** rely on `native_decide`, `decide`, `norm_num`, or `rfl` for the substantive theorems.
- Do **not** present a potential that only works for a tiny syntactic fragment unless you clearly label it as a stepping stone and still prove something conceptually strong.
- Do **not** avoid the hard part: the challenge is duplication under substitution.

## What would make this revolutionary

If you succeed, you will have formalized a new principle:

> **Normalization is tropical dissipation.**

That reframes proof simplification as an energy law, opening:
- a tropical semantics of computation,
- Lyapunov methods for rewriting systems,
- optimization-inspired proof complexity measures,
- potential transfer to proof nets, linear logic, and differentiable programming semantics.

This is not an incremental theorem. It is the beginning of a new dictionary between logic and energy. Build that dictionary precisely, prove the hard lemmas, and make the computational evidence impossible to ignore.

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
