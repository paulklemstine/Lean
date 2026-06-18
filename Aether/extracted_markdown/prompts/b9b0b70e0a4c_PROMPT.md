## Assignment: Tropical Chosen-Plaintext Security from Extractor Robustness

**Mode:** prove

Prove a genuinely new theorem that lifts extractor security for tropical orbit sources into **game-based CPA security** for symmetric encryption keyed by the extracted output. This should not be a cosmetic restatement of the leftover hash lemma. The breakthrough is to formalize, inside Lean, the exact bridge from **statistical closeness of extracted keys** to **adaptive chosen-plaintext indistinguishability**, with tropical structure supplying the entropy source.

This is the right next theorem because the catalog already contains the entropy-side ingredients:
- `key_derivation_security_bound`
- `hybrid_argument_advantage_bound`
- `tropical_kl_security_bound`
- `tropical_security_from_norm_bound`

What is missing is the cryptographic synthesis: a theorem saying that **tropical randomness extraction is already enough to support operational encryption security**, not just passive key indistinguishability. That closes the loop from tropical dynamics → extractor theory → modern game-based cryptography.

---

## Precise Theorem Target

You should define a minimal abstract model of a symmetric encryption oracle family `Enc : K → M → C`, an adversary with at most `q` oracle queries, and a CPA advantage functional comparing the real game (key sampled from extracted tropical source) with the ideal game (uniform key).

Then prove a theorem of the following shape:

> If the extracted key distribution is `ε`-close in statistical distance to uniform, then every `q`-query CPA adversary has distinguishing advantage at most `q * ε` (or, in the strongest formalization, at most `ε`, with `q * ε` appearing only for a multi-hybrid transcript bound depending on your exact oracle model).

The mathematically sharp target is:

\[
\forall q \in \mathbb{N},\ \forall \varepsilon \ge 0,\ 
\operatorname{SD}(K_{\mathrm{real}}, U_K) \le \varepsilon
\;\Longrightarrow\;
\operatorname{Adv}^{\mathrm{CPA}}_{\mathcal A}(q;K_{\mathrm{real}}) \le q\varepsilon,
\]
and combining with the existing leftover-hash theorem for tropical orbit sources:
\[
\operatorname{Adv}^{\mathrm{CPA}}_{\mathcal A}(q;\operatorname{Extract}(X))
\le q \cdot \operatorname{tropExtractorAdv}(X).
\]

If your formal model yields the sharper bound
\[
\operatorname{Adv}^{\mathrm{CPA}}_{\mathcal A} \le \varepsilon,
\]
that is even better; in that case also derive the weaker but convenient corollary `≤ q * ε` for downstream use.

---

## Lean 4 Type Signature Target

You should aim for a theorem close to the following abstraction level. Adjust names to match available probability/game infrastructure, but preserve the quantifier structure.

```lean
theorem tropical_cpa_security_from_extractor_robustness
  {K M C : Type} [Fintype K] [DecidableEq K]
  (Enc : K → M → C)
  (RealKey : ProbDist K)
  (UnifKey : ProbDist K)
  (A : CpaAdversary K M C)
  (q : ℕ)
  (ε : ℝ)
  (hε : 0 ≤ ε)
  (hq : A.queryBound ≤ q)
  (hclose : statDist RealKey UnifKey ≤ ε) :
  cpaAdvantage Enc RealKey A ≤ q * ε
```

and then the tropical instantiation:

```lean
theorem tropical_cpa_security_of_leftover_hash
  {S K M C : Type} [Fintype K] [DecidableEq K]
  (Enc : K → M → C)
  (src : ProbDist S)
  (ext : S → K)
  (A : CpaAdversary K M C)
  (q : ℕ)
  (ε : ℝ)
  (hε : 0 ≤ ε)
  (hq : A.queryBound ≤ q)
  (hExt : statDist (ProbDist.map ext src) (ProbDist.uniform K) ≤ ε) :
  cpaAdvantage Enc (ProbDist.map ext src) A ≤ q * ε
```

The final theorem should then be specialized using the catalog theorem `key_derivation_security_bound`:

```lean
theorem tropical_cpa_security_from_leftover_hash_bound
  {S K M C : Type} [Fintype K] [DecidableEq K]
  (Enc : K → M → C)
  (src : ProbDist S)
  (ext : S → K)
  (A : CpaAdversary K M C)
  (q : ℕ)
  (δ : ℝ)
  (hδ : 0 ≤ δ)
  (hq : A.queryBound ≤ q)
  (hKD : statDist (ProbDist.map ext src) (ProbDist.uniform K) ≤ δ) :
  cpaAdvantage Enc (ProbDist.map ext src) A ≤ q * δ
```

If the existing theorem `key_derivation_security_bound` directly outputs a bound on extractor advantage rather than a `statDist` statement, prove an intermediate lemma translating that bound into the exact hypothesis above.

---

## Exact Mathematical Statement You Should Establish

A strong target formulation:

> **Theorem.** Let `K` be a finite key space, `M` a message space, `C` a ciphertext space, and `Enc : K → M → C` a deterministic or randomized symmetric encryption scheme whose randomness is internal to the oracle game. Let `D_real` be a key distribution and `U_K` the uniform distribution on `K`. Suppose
> \[
> \Delta(D_{\mathrm{real}}, U_K) \le \varepsilon.
> \]
> Then for every adversary `A` making at most `q` encryption-oracle queries,
> \[
> \operatorname{Adv}^{\mathrm{CPA}}_A(Enc; D_{\mathrm{real}}) \le q\varepsilon.
> \]
> Consequently, if `D_real` is the output of a leftover-hash extractor applied to a tropical orbit source and the catalog theorem bounds its statistical distance by `ε_trop`, then
> \[
> \operatorname{Adv}^{\mathrm{CPA}}_A \le q\,\varepsilon_{\mathrm{trop}}.
> \]

A conceptually cleaner sharpened theorem:

> If the CPA game samples one secret key once at the beginning and all oracle responses are deterministic functions of that key and fresh public randomness, then
> \[
> \operatorname{Adv}^{\mathrm{CPA}}_A \le \Delta(D_{\mathrm{real}}, U_K),
> \]
> because the entire adversarial transcript distribution is a pushforward of the key distribution.  
> Then derive the `qε` bound as a hybrid corollary for oracle-by-oracle transcript exposure.

This sharpened theorem is especially attractive because it reveals a deep principle: **CPA security is functorial under pushforward of key distributions**.

---

## Why This Is a Breakthrough

This theorem opens a new lane: **tropical cryptography with operational security guarantees**. Existing extractor results usually stop at entropy or indistinguishability of keys. By proving the CPA lift formally, you show that tropical orbit sources are not merely mathematically exotic randomness objects—they support bona fide encryption security in the standard modern sense.

This creates a bridge between:
- tropical semigroup dynamics,
- extractor theory,
- statistical distance / KL control,
- and game-based cryptographic security.

The field-opening insight is that **nonclassical algebraic randomness models can be certified at the level cryptographers actually use**.

---

## Proof Strategy Architecture

### Strategy A: Transcript Pushforward + Data Processing (most promising)
This is the cleanest and most conceptually powerful route.

1. **Define the CPA transcript distribution as a pushforward of the key distribution.**  
   For a fixed adversary `A` and oracle interaction semantics, define a measurable/finite map
   \[
   T_A : K \to \mathrm{Transcript}
   \]
   or, if internal randomness is present, a kernel combined with public randomness. Show the real and ideal transcript distributions are induced from `RealKey` and `UnifKey`.

2. **Apply statistical distance monotonicity under post-processing.**  
   Use total variation contraction / data processing:
   \[
   \Delta(T_{A\#} D_{\mathrm{real}}, T_{A\#} U_K) \le \Delta(D_{\mathrm{real}}, U_K).
   \]
   Then identify CPA advantage as bounded by transcript distinguishing advantage.

3. **Conclude the sharper bound `Adv ≤ ε`, then derive `Adv ≤ q * ε`.**  
   The `q * ε` version can be obtained by a trivial inequality if `q ≥ 1`, or by a separate hybrid lemma if your game formalization naturally exposes one query at a time.

**Why most promising:** it aligns naturally with `tropical_kl_security_bound` and the broader information-theoretic catalog. It also gives the strongest theorem, and its abstraction is reusable for CCA, key-dependent message security, and leakage resilience.

---

### Strategy B: Standard Hybrid Argument Using Existing Catalog Theorem
This is likely the easiest route if game infrastructure is already query-indexed.

1. **Construct a sequence of `q+1` games.**  
   In game `i`, the first `i` oracle interactions are answered using a uniform key world and the remaining ones using the real extracted key world, or vice versa depending on your formalization.

2. **Bound adjacent game differences by `ε`.**  
   Use `hybrid_argument_advantage_bound` together with the hypothesis
   \[
   \Delta(D_{\mathrm{real}}, U_K) \le \varepsilon.
   \]
   Show each hybrid swap changes the adversary’s success probability by at most `ε`.

3. **Sum over `q` hybrids.**  
   Conclude
   \[
   \operatorname{Adv}^{\mathrm{CPA}} \le q\varepsilon.
   \]

**Why useful:** it directly leverages `hybrid_argument_advantage_bound`, making this theorem a visible synthesis of existing catalog results. It is perhaps less elegant than Strategy A, but more likely to fit available lemmas with minimal new infrastructure.

---

### Strategy C: KL / Norm Bounds → Statistical Distance → CPA
This is the cross-domain route and may generate stronger corollaries.

1. **Use `tropical_kl_security_bound` or `tropical_security_from_norm_bound`**  
   to obtain an explicit bound on total variation/statistical distance between extracted key and uniform.

2. **Transfer that bound to transcript distributions**  
   via either Strategy A’s pushforward argument or Strategy B’s hybrid argument.

3. **Derive explicit CPA bounds in terms of KL divergence or norm control.**  
   For example:
   \[
   \operatorname{Adv}^{\mathrm{CPA}} \le q \sqrt{\tfrac12 D_{\mathrm{KL}}(D_{\mathrm{real}}\|U_K)}
   \]
   if your existing theorems support a Pinsker-style translation.

**Why exciting:** this turns tropical information-theoretic inequalities into cryptographic security guarantees. That is a genuinely interdisciplinary theorem family, not just a one-off result.

---

## How to Build on the Catalog Theorems

### 1. `key_derivation_security_bound`
Use this as the extractor-side engine. Identify whether it states:
- a direct statistical distance bound,
- a semantic-security style bound,
- or a min-entropy leftover-hash inequality.

If it is not already in the exact `statDist ≤ ε` form you need, prove a wrapper lemma:
```lean
theorem key_derivation_security_bound_to_statDist ...
```
that converts its conclusion into a uniform-key closeness statement for the extracted key.

### 2. `hybrid_argument_advantage_bound`
This should control the telescoping sum across `q` game hops.  
Your job is not merely to invoke its name; instantiate it with the exact game family indexed by query count, and prove the adjacent-game bound using key closeness.

### 3. `tropical_kl_security_bound`
This can provide a stronger analytic corollary. If it bounds KL divergence from a tropical source to an ideal distribution, compose it with a TV/KL inequality to obtain CPA security. This is the route that most strongly links tropical information theory to cryptography.

### 4. `tropical_security_from_norm_bound`
If this theorem controls security from an `L¹`, `L²`, or operator norm estimate, use it to generate an explicit tropical CPA theorem where the final bound is expressed in geometric/analytic parameters of the orbit source. That would make the result far more explanatory than a black-box `ε`.

### 5. `birthday_bound_tropical_hash`
This is not central to the main theorem, but it is an excellent corollary source: combine CPA security from extractor robustness with collision bounds to obtain a broader “tropical symmetric primitive security package.” Even a short corollary would be valuable.

---

## Lean Design Guidance

You will likely need a lightweight abstraction layer for CPA games. Keep it finite and simple.

Possible structures:
```lean
structure CpaAdversary (K M C : Type) where
  queryBound : ℕ
  -- internal strategy representation
```

and
```lean
def cpaAdvantage
  (Enc : K → M → C)
  (D : ProbDist K)
  (A : CpaAdversary K M C) : ℝ := ...
```

If a full adaptive adversary is too heavy for the first theorem, start with a **non-adaptive q-query adversary** formalization, prove the theorem there, and then generalize. But be explicit that the target is adaptive CPA. The mathematically deepest version is transcript-based and can encode adaptivity abstractly.

Critical intermediate lemmas you should try to prove:

```lean
theorem statDist_map_le
  (f : α → β) (p q : ProbDist α) :
  statDist (ProbDist.map f p) (ProbDist.map f q) ≤ statDist p q
```

```lean
theorem cpa_advantage_le_statDist
  (Enc : K → M → C) (A : CpaAdversary K M C)
  (D : ProbDist K) :
  cpaAdvantage Enc D A ≤ statDist D (ProbDist.uniform K)
```

```lean
theorem cpa_advantage_hybrid_le
  (Enc : K → M → C) (A : CpaAdversary K M C)
  (q : ℕ) (ε : ℝ) :
  statDist D U ≤ ε →
  A.queryBound ≤ q →
  cpaAdvantage Enc D A ≤ q * ε
```

If the library’s `ProbDist` API is restrictive, use finite distributions as functions with normalization proofs and build exactly the lemmas you need.

---

## Cross-Domain Connections You Should Exploit

1. **Information theory ↔ cryptography**  
   CPA security should emerge as a post-processing corollary of statistical indistinguishability. This is the same philosophy as data processing inequalities. If you can phrase the transcript map as a channel, you effectively prove a cryptographic instance of information contraction.

2. **Tropical dynamics ↔ randomness extraction**  
   Tropical orbit sources are highly structured, not IID randomness. Showing they nevertheless support CPA-secure encryption after extraction suggests a new theory of **structured-source cryptography**.

3. **Semigroup actions ↔ key agreement / public-key heuristics**  
   Tropical semigroup actions have long been candidates for hard computational problems. This theorem says that even before computational hardness enters, the entropy they generate has direct cryptographic utility.

4. **Riesz / norm control ↔ operational security**  
   The existence of `tropical_security_from_norm_bound` hints at a geometric control principle: analytic bounds on tropical objects can become encryption-security bounds. That is a profound bridge and should be highlighted in theorem statements and comments.

5. **KL divergence ↔ game advantage**  
   If you can derive a CPA theorem from KL via Pinsker or a catalog theorem, you create a reusable pipeline:
   tropical geometry → divergence bound → total variation bound → cryptographic advantage bound.

---

## Deliverables

1. A Lean theorem proving CPA security from key statistical closeness.
2. A tropical instantiation using leftover-hash / extractor robustness.
3. At least one corollary using either:
   - `tropical_kl_security_bound`, or
   - `tropical_security_from_norm_bound`.
4. Minimal `sorry`s, with all major cryptographic and probabilistic steps fully formalized.

If a full adaptive CPA model is too large for one pass, prioritize:
- a complete non-adaptive theorem,
- then an abstract transcript lemma that clearly generalizes to adaptivity.

---

## Revolutionary Significance

If you complete this, you will have formalized one of the first genuinely nontrivial pipelines from **tropical algebraic structure to modern cryptographic game security** in Lean. This is not an incremental extension. It opens a field:

- tropical extractor-based cryptography,
- structured-source symmetric security,
- information-theoretic certification of algebraically generated keys,
- and eventually CCA, leakage resilience, and composable security for tropical systems.

This is the kind of theorem that changes how one thinks about formalized cryptography: not merely verifying standard reductions, but discovering new security mechanisms sourced from exotic mathematics.

---

## Application Keywords

`tropical cryptography`, `chosen-plaintext security`, `leftover hash lemma`, `statistical distance`, `total variation`, `hybrid argument`, `data processing inequality`, `structured-source extraction`, `tropical semigroup actions`, `information-theoretic security`, `KL-to-TV transfer`, `formal cryptography in Lean`

---

## Required Final Artifact

Produce a structured `FUTURE_DIRECTIONS.md` with **3–5 concrete breakthrough-level next steps**, for example:
- CCA security from tropical extractor robustness with decryption-oracle hybrids
- Leakage-resilient encryption under tropical source perturbations
- Tropical mutual information and a data processing theorem for cryptographic channels
- Composable security of key exchange derived from tropical semigroup actions
- KL- and norm-controlled explicit CPA bounds for concrete tropical orbit families

Make those next steps specific enough that they can seed the next research cycle immediately.

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
