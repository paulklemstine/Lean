## Assignment: Homomorphic Encryption over Tropical Semirings

Mode: **prove**

You are not being asked for a cosmetic analogy to FHE. You are being asked to carve out a formally correct, mathematically sharp, Lean-native theory of **idempotent homomorphic encryption** over tropical semirings, and to identify exactly where “security” is genuinely provable and where the usual cryptographic rhetoric breaks. If full CPA security for a deterministic tropical homomorphism is impossible, prove the impossibility theorem and then pivot to the correct randomized construction. That pivot itself would be a breakthrough: a rigorous separation between **algebraic tropical homomorphism** and **cryptographic semantic security**.

Prove new, non-trivial theorems. Build on catalog theorems. Minimize sorry.

### Research Direction

Construct a mathematically precise encryption framework for min-plus arithmetic in which ciphertext operations implement tropical operations on plaintexts. Then prove one of the following two breakthrough outcomes:

1. **Positive direction:** a randomized tropical encryption scheme is homomorphic for min and plus, correct under evaluation, and secure against chosen-plaintext attack under a precise indistinguishability notion compatible with tropical masking; or

2. **Separation direction:** any deterministic exact tropical-semiring homomorphic encryption on an infinite plaintext domain fails CPA security, and therefore randomness or quotienting/noise abstraction is mathematically necessary.

The second theorem is not a fallback. It is potentially the more important theorem, because it formalizes a structural obstruction unique to idempotent algebra and could open a new field: **idempotent cryptography with impossibility frontiers**.

### Mathematical Framing

The central tension is this:

- tropical addition is `min`,
- tropical multiplication is `+`,
- `min` is idempotent,
- exact algebra homomorphisms preserve strong order-theoretic structure,
- and CPA security requires hiding precisely the structure that exact homomorphisms tend to expose.

This means the right theorem is not merely “define Enc and prove correctness.” The right theorem is to identify the exact interface between:

- semiring homomorphism,
- order preservation,
- randomness,
- quotient semantics,
- and noise-free bootstrapping.

The idempotence of tropical addition suggests a radically different noise theory from classical FHE: repeated aggregation by `min` does not amplify additive perturbations in the classical way. Formalize this as a **stability theorem for homomorphic evaluation depth**, and connect it to shortest-path / dynamic programming semantics.

### Existing Verified Theorems

Existing theorems you can build on:

1. `tropical_plus_distributes_over_min` : theorem `tropical_plus_distributes_over_min (a b c : ℝ) : ...`
   file: `Cryptography/TropicalPostQuantumPrimitives.lean`

2. `tropical_plus_distributes_over_min` : theorem `tropical_plus_distributes_over_min (a b c : ℝ) : ...`
   file: `Bridges/AlgebraTropicalCryptography/TropicalScatteringOneWayDuality.lean`

3. `tropical_plus_distributes_over_min` : theorem `tropical_plus_distributes_over_min (a b c : ℕ) : ...`
   file: `Bridges/AlgebraTropicalGeometry/TropicalRadonGraphDuality.lean`

4. `tropical_plus_distributes_over_min` : theorem `tropical_plus_distributes_over_min (a b c : ℝ) : ...`
   file: `Bridges/MinPlusVerificationCore.lean`

5. `tropical_security_dimension_bound` : theorem `tropical_security_dimension_bound (params : TropicalOWFSecurity) : ...`
   file: `Cryptography/TropicalOneWayFoundations.lean`

You should use these not as decorations but as load-bearing infrastructure:
- use distributivity to prove evaluation correctness for tropical circuits,
- use any available one-way/security dimension bounds to parameterize a randomized masking family,
- and use the min-plus algebra already certified in the catalog to avoid reproving semiring identities from scratch.

### Primary Theorem Targets

You should aim for a package of theorems, with at least one impossibility theorem and one positive construction theorem.

#### Target A: Deterministic exact tropical homomorphisms are not CPA-secure

This is the conceptual core. On a linearly ordered plaintext space such as `ℕ`, exact preservation of `min` and `+` forces severe rigidity.

**Precise theorem statement:**

Let `Enc : ℕ → C` and `Dec : C → ℕ` with ciphertext operations `cmin : C → C → C` and `cmul : C → C → C`. Assume:
- `Dec (Enc m) = m`,
- `Dec (cmin (Enc m₁) (Enc m₂)) = min m₁ m₂`,
- `Dec (cmul (Enc m₁) (Enc m₂)) = m₁ + m₂`.

Then `Enc` is injective. Consequently, if the adversary can test ciphertext equality or evaluate `Dec`-invariant predicates induced by the public operations, the scheme cannot satisfy any nontrivial indistinguishability notion on single-message CPA experiments. Formalize a clean version of this in Lean.

A good formal core is:

```lean
theorem tropical_det_hom_injective
  {C : Type} [DecidableEq C]
  (Enc : ℕ → C) (Dec : C → ℕ)
  (cmin cmul : C → C → C)
  (hdec : ∀ m, Dec (Enc m) = m)
  (hmin : ∀ m n, Dec (cmin (Enc m) (Enc n)) = Nat.min m n)
  (hadd : ∀ m n, Dec (cmul (Enc m) (Enc n)) = m + n) :
  Function.Injective Enc
```

Then push to a security obstruction theorem:

```lean
theorem no_det_cpa_secure_tropical_scheme
  {C : Type} [DecidableEq C]
  (Enc : ℕ → C) (Dec : C → ℕ)
  (cmin cmul : C → C → C)
  (hdec : ∀ m, Dec (Enc m) = m)
  (hmin : ∀ m n, Dec (cmin (Enc m) (Enc n)) = Nat.min m n)
  (hadd : ∀ m n, Dec (cmul (Enc m) (Enc n)) = m + n) :
  Function.Injective Enc
```

This second signature may initially look identical in conclusion, but the theorem statement should be strengthened in the file by introducing a simple game-based “deterministic indistinguishability failure” definition and proving the scheme violates it. If full probabilistic CPA machinery is too heavy for a first cycle, define a minimal formal notion:

```lean
def DetCPAInsecure {M C : Type} [DecidableEq C] (Enc : M → C) : Prop :=
  ∃ m0 m1, m0 ≠ m1 ∧ Enc m0 ≠ Enc m1
```

and prove exact homomorphic correctness implies `DetCPAInsecure Enc`. This is weaker than real CPA insecurity, but fully formal and points the way.

#### Target B: Randomized tropical masking yields correctness and perfect single-use secrecy

The right positive result is likely not “full FHE” in one leap, but a **one-time randomized tropical masking theorem** with exact decryption and homomorphic compatibility for a bounded class of evaluations.

A promising construction on `ℕ × ℕ` is:
- key `k : ℕ`,
- encryption `Enc_k(m; r) = (r, m + r + k)`,
- decryption `Dec_k(a,b) = b - a - k` under a suitable truncated subtraction side condition,
or on `ℤ`/`ℝ`:
- `Enc_k(m; r) = (r, m + r + k)`,
- `Dec_k(a,b) = b - a - k`.

Then define ciphertext operations so that decrypted results correspond to tropical operations on plaintexts:
- ciphertext multiplication for tropical multiplication (`+`) by pairwise addition,
- ciphertext addition for tropical addition (`min`) by a normalized minimum construction.

The challenge is that exact homomorphism and random masking interact nontrivially. You may need a quotient notion:
two ciphertexts are equivalent if they decrypt to the same plaintext. Then prove operations are homomorphic **modulo decryption**.

**Precise theorem statement candidate over integers:**

```lean
structure TropCipher where
  left : ℤ
  right : ℤ

def Enc (k m r : ℤ) : TropCipher := ⟨r, m + r + k⟩
def Dec (k : ℤ) (c : TropCipher) : ℤ := c.right - c.left - k

def cMul (c₁ c₂ : TropCipher) : TropCipher :=
  ⟨c₁.left + c₂.left, c₁.right + c₂.right⟩

theorem tropical_enc_correct
  (k m r : ℤ) :
  Dec k (Enc k m r) = m

theorem tropical_enc_hMul_correct
  (k m₁ m₂ r₁ r₂ : ℤ) :
  Dec (2*k) (cMul (Enc k m₁ r₁) (Enc k m₂ r₂)) = m₁ + m₂
```

This theorem already reveals a key-renormalization phenomenon: after multiplication the effective key becomes `2*k`. That is not a bug; it is a clue. Formalize **key evolution** under circuit evaluation and then search for a normalization operator/bootstrapping map exploiting idempotence.

#### Target C: Idempotent bootstrapping / depth-stability theorem

This is where the tropical story becomes original. Prove that for tropical polynomial evaluation, the “decryption offset complexity” grows only along multiplication gates and is stable under `min` gates.

Model a tropical expression language:

```lean
inductive TropExpr
| var : Fin n → TropExpr
| const : ℤ → TropExpr
| tmin : TropExpr → TropExpr → TropExpr
| tadd : TropExpr → TropExpr → TropExpr
```

Define:
- plaintext evaluation `evalPlain : (Fin n → ℤ) → TropExpr → ℤ`,
- ciphertext evaluation `evalCipher : ... → TropCipher`,
- offset complexity `keyWeight : TropExpr → ℕ` where
  - `keyWeight (var i) = 1`,
  - `keyWeight (const c) = 1`,
  - `keyWeight (tmin e₁ e₂) = max (keyWeight e₁) (keyWeight e₂)`,
  - `keyWeight (tadd e₁ e₂) = keyWeight e₁ + keyWeight e₂`.

Then prove:

```lean
theorem evalCipher_correct
  (k : ℤ) (ρ : Fin n → ℤ) (r : Fin n → ℤ) :
  Dec ((keyWeight e : ℕ) * k)
    (evalCipher (fun i => Enc k (ρ i) (r i)) e)
    = evalPlain ρ e
```

or an equivalent statement with coercions handled cleanly.

This is the first genuinely interesting theorem: **min gates do not increase key weight beyond a max**, unlike classical additive-noise accumulation. That is the tropical analogue of noise suppression. It is not yet “bootstrapping,” but it is the rigorous algebraic backbone of that claim.

#### Target D: Tropical normalization theorem

If you can define a normalization map `refresh` that resets key weight without changing decryption semantics, prove:

```lean
theorem refresh_preserves_plaintext
  (k K : ℤ) (c : TropCipher) :
  Dec K c = Dec k (refresh k K c)

theorem refresh_restores_base_key
  (k : ℤ) (e : TropExpr) ... :
  Dec k (refresh k ((keyWeight e : ℕ) * k) (evalCipher ... e)) = evalPlain ... e
```

Even a partial theorem here would be a major bridge between tropical algebra and FHE-style bootstrapping.

### Lean 4 Type Signature Guidance

Use concrete types first:
- `ℕ` for order/idempotence and finite combinatorics,
- `ℤ` for exact masking/decryption by subtraction,
- only move to `ℝ` if you need richer tropical geometry.

Likely useful initial signatures:

```lean
structure TropCipher where
  left : ℤ
  right : ℤ
deriving DecidableEq

def Enc (k m r : ℤ) : TropCipher := ⟨r, m + r + k⟩
def Dec (k : ℤ) (c : TropCipher) : ℤ := c.right - c.left - k
```

```lean
inductive TropExpr (n : ℕ)
| var : Fin n → TropExpr n
| const : ℤ → TropExpr n
| tmin : TropExpr n → TropExpr n → TropExpr n
| tadd : TropExpr n → TropExpr n → TropExpr n
```

```lean
def keyWeight : TropExpr n → ℕ
def evalPlain : (Fin n → ℤ) → TropExpr n → ℤ
def evalCipher : (Fin n → TropCipher) → TropExpr n → TropCipher
```

### Proof Strategy Paths

#### Strategy 1: Rigidity-first, then randomized repair
Most promising.

1. Prove exact deterministic correctness forces injectivity of `Enc` by composing with `Dec`.
2. Define a minimal indistinguishability failure notion and show injectivity of a deterministic public encryption map breaks it.
3. Introduce randomized masking and recover exact decryption plus homomorphic correctness modulo evolving key weight.

Why this is promising:
- the impossibility theorem is low-risk and mathematically clean;
- it prevents wasting time chasing impossible “deterministic tropical CPA security” claims;
- it naturally motivates the randomized construction.

#### Strategy 2: Expression semantics and idempotent depth theorem
Best for the “noise-free bootstrapping” claim.

1. Define tropical expressions and plaintext/ciphertext evaluators.
2. Prove by structural induction the correctness theorem with key-weight accounting.
3. Show `tmin` contributes `max`, not `+`, to key growth; derive corollaries for bounded-depth circuits and repeated min-aggregation.

Why this is promising:
- structural induction is Lean-friendly;
- it produces a theorem of independent value even if full cryptographic security is deferred;
- it gives a precise replacement for vague “no noise growth” language.

#### Strategy 3: Quotient-semantic homomorphism
Most conceptually ambitious.

1. Define an equivalence relation `c₁ ≈ₖ c₂ :↔ Dec k c₁ = Dec k c₂`.
2. Show ciphertext operators are homomorphic on equivalence classes rather than raw ciphertexts.
3. Interpret encryption as a semiring morphism into a quotient or setoid model.

Why this matters:
- tropical homomorphism may only be exact at the semantic level, not representation level;
- this is philosophically aligned with modern cryptography, where ciphertexts are distributions or equivalence classes, not canonical values.

### Cross-Domain Connections

You must connect this work to at least one other domain in a mathematically nontrivial way.

1. **Dynamic programming / shortest paths**  
   Tropical evaluation computes path costs, Bellman recurrences, Viterbi-style inference. A homomorphic tropical evaluator would amount to encrypted shortest-path style computation. This is not merely an application story: the `min`-stability theorem becomes an encrypted Bellman principle.

2. **Verification and robust AI**  
   Min-plus algebra already appears in verification, scheduling, and tropical neural abstractions. If ciphertext evaluation preserves tropical semantics with bounded key-weight growth, one gets a route to **privacy-preserving certified robustness computations** in idempotent models.

3. **Order theory / residuated algebra**  
   Exact preservation of `min` and `+` is deeply constrained by order enrichment. The impossibility theorem should be framed as an order-theoretic rigidity result, not just a cryptographic anecdote.

4. **Tropical geometry**  
   Tropical polynomials define piecewise-linear hypersurfaces. Homomorphic evaluation of tropical polynomials suggests encrypted computation of polyhedral decision boundaries. This is a bridge between algebraic geometry and private computation that almost nobody has formalized.

5. **Semiring complexity theory**  
   The distinction between additive noise growth in rings and max-stable/key-weight growth in idempotent semirings could found a new complexity theory of encrypted semiring computation.

### Application Keywords

tropical cryptography, idempotent semirings, homomorphic encryption, min-plus algebra, CPA security, impossibility theorem, randomized masking, bootstrapping, dynamic programming, shortest paths, tropical geometry, privacy-preserving optimization, semiring complexity, verification, encrypted Bellman recurrences

### Concrete Deliverables

1. A Lean file defining a minimal tropical ciphertext model and proving exact decryption.
2. A theorem showing deterministic exact tropical homomorphic encryption is injective and therefore fails a minimal indistinguishability notion.
3. A structural-induction theorem for tropical expression evaluation with key-weight accounting.
4. If possible, a randomized masking theorem with exact correctness and at least a single-use secrecy lemma.
5. Any theorem strengthening `tropical_security_dimension_bound` by linking algebraic dimension/security parameters to expression complexity.

### What Would Count as a Breakthrough

Any one of the following would be field-opening:

- a formal impossibility theorem showing deterministic exact tropical FHE is incompatible with CPA-style secrecy;
- a precise randomized tropical homomorphic scheme with proven evaluation correctness and semantic stability;
- a key-weight/noise theorem showing tropical idempotence fundamentally changes the bootstrapping landscape;
- a quotient-semantic semiring formalization of encrypted tropical computation.

### Required FUTURE_DIRECTIONS.md

You must produce a structured `FUTURE_DIRECTIONS.md` with 3–5 concrete breakthrough next steps. These must be specific theorem/program targets, not vague ideas. Include items of the following flavor:

- formal CPA game semantics with probabilistic ciphertext distributions in Lean,
- encrypted shortest-path / Bellman-Ford correctness over tropical ciphertexts,
- quotient-semantic tropical semiring instances for ciphertext classes,
- lower bounds showing which semiring-homomorphic security notions are impossible,
- tropical polynomial evaluation on encrypted inputs with polyhedral decision extraction.

### Final Directive

Do not simply assert “FHE over tropical semirings exists.” Either prove a precise construction or prove the obstruction. In this domain, the impossibility frontier is as valuable as the positive theorem. The goal is to found **tropical cryptography as a rigorous formal subject**, not to imitate classical ring-based FHE slogans in a semiring where the algebra behaves completely differently.

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

Research domain: Cryptography
Research mode: prove
