## Assignment: Tropical RSA: Min-Plus Public Key Cryptosystem with Provable Security

Mode: **prove**

Aristotle, do not treat this as “cryptography over a quirky semiring.” Treat it as the first serious attempt to formalize a **complexity-theoretic public-key paradigm native to tropical algebra**. The breakthrough is not merely a toy min-plus analogue of RSA. The breakthrough is to show that **algorithmic hardness in tropical linear algebra can support reduction-based public-key security statements in Lean 4**, thereby opening a verified bridge between tropical geometry, shortest-path complexity, and provable cryptography.

Your task is to formulate and prove **mathematically precise, formally checkable theorems** that isolate the correct algebraic core of a tropical public-key system, while remaining honest about what can actually be proved in Lean without smuggling in unformalized NP-hardness machinery. If full NP-hardness is too large for one cycle, prove the **reduction skeleton**, the **correctness theorem**, and a **semantic-security transfer theorem** under a precise tropical DDH-style assumption.

Build on the catalog theorems:
- `post_quantum_key_security_from_minEntropy`
  from `Cryptography/EntropyExtraction/LeftoverHash.lean`
- `tropical_diffie_hellman_correctness`
  from `Cryptography/TropicalPostQuantum.lean`
- `tropical_plus_distributes_over_min`
  from `Cryptography/TropicalPostQuantumPrimitives.lean`
- `tropical_security_dimension_bound`
  from `Cryptography/TropicalOneWayFoundations.lean`

The central vision: **replace multiplicative trapdoor arithmetic by tropical composition laws and factorization hardness**, then prove that the public transcript leaks no efficiently usable information beyond what a tropical DDH oracle would reveal.

---

## Core Mathematical Program

You should define a tropical public-key framework using concrete types such as `Matrix (Fin n) (Fin n) ℕ` or `Matrix (Fin n) (Fin n) ℝ≥0∞`, with min-plus multiplication:
- addition in the semiring = `min`
- multiplication in the semiring = ordinary `+`

The right level of abstraction is likely:
- weighted adjacency matrices,
- tropical matrix powers,
- path-length semantics,
- a factorization problem corresponding to decomposition of a public matrix into private tropical factors.

The first theorem should not overclaim “RSA” literally; instead, formalize a **tropical trapdoor action** and prove its correctness and security transfer properties. If the RSA metaphor survives the formalization, excellent. If not, rename the primitive honestly.

---

## Precise Theorem Targets

### Theorem 1: Tropical path semantics of public-key composition
Prove that tropical matrix multiplication computes shortest-path composition, so that public-key formation corresponds to path aggregation.

A clean formal target is:

```lean
theorem tropMul_entry_eq_iInf_pathWeight
  {n : ℕ}
  (A B : Matrix (Fin n) (Fin n) ℕ∞)
  (i j : Fin n) :
  (A ⬝ B) i j = ⨅ k : Fin n, (A i k + B k j)
```

If `ℕ∞` is awkward, use `WithTop ℕ` or `ℝ≥0∞`. If Mathlib’s matrix multiplication over the tropical semiring is not ready-made, define a custom min-plus product:

```lean
def tropMul {n : ℕ} (A B : Matrix (Fin n) (Fin n) ℕ∞) :
    Matrix (Fin n) (Fin n) ℕ∞ :=
  fun i j => ⨅ k, (A i k + B k j)
```

Then prove:

```lean
theorem tropMul_assoc {n : ℕ} :
  Associative (@tropMul n)
```

and

```lean
theorem tropPow_entry_eq_shortestPathLen
  {n : ℕ} (A : Matrix (Fin n) (Fin n) ℕ∞) (m : ℕ) (i j : Fin n) :
  (tropPow A m) i j = shortestPathLenExactEdges A m i j
```

This theorem is the algebraic engine: it turns tropical exponentiation/public composition into graph optimization.

### Theorem 2: Reduction of private-key recovery to tropical factor/path search
You should define a **private-key recovery problem** as a factorization or decomposition problem and prove a reduction theorem from key recovery to a shortest-path witness problem.

A realistic formal theorem is not “NP-hardness” in full Cook reduction language unless you build that framework. Instead, prove a **many-one reduction skeleton**:

```lean
def TropicalKeyRecoveryInstance (n : ℕ) := Matrix (Fin n) (Fin n) ℕ∞
def TropicalPathInstance (n : ℕ) :=
  Matrix (Fin n) (Fin n) ℕ∞ × Fin n × Fin n × ℕ∞

def recoversKey
    {n : ℕ}
    (Kpub : TropicalKeyRecoveryInstance n)
    (priv : Matrix (Fin n) (Fin n) ℕ∞ × Matrix (Fin n) (Fin n) ℕ∞) : Prop :=
  tropMul priv.1 priv.2 = Kpub

def pathWitness
    {n : ℕ}
    (I : TropicalPathInstance n) : Prop := ...
```

Then prove:

```lean
theorem tropical_key_recovery_reduces_to_path_witness
  {n : ℕ} :
  ∃ f : TropicalKeyRecoveryInstance n → TropicalPathInstance n,
    ∀ Kpub, (∃ priv, recoversKey Kpub priv) → pathWitness (f Kpub)
```

A stronger version, if definitions cooperate:

```lean
theorem tropical_factorization_witness_yields_path_witness
  {n : ℕ}
  (A B : Matrix (Fin n) (Fin n) ℕ∞) :
  let Kpub := tropMul A B
  ∃ I : TropicalPathInstance n, factorizationWitness A B Kpub → pathWitness I
```

This is the right formal breakthrough: a certified reduction **inside Lean** from a cryptanalytic inversion task to a tropical optimization witness problem.

### Theorem 3: Correctness of tropical encryption/decryption
Using a tropical DH-style shared-secret primitive already present in the catalog, prove a correctness theorem for encryption and decryption.

Target something like:

```lean
structure TropicalPublicKey (n : ℕ) where
  G   : TropMat n
  pub : TropMat n

structure TropicalPrivateKey (n : ℕ) where
  sec : ℕ

def tropicalEncrypt {n : ℕ} (pk : TropicalPublicKey n) (r : ℕ) (m : ℕ) : TropCiphertext n := ...
def tropicalDecrypt {n : ℕ} (sk : TropicalPrivateKey n) (c : TropCiphertext n) : ℕ := ...

theorem tropical_encrypt_decrypt_correct
  {n : ℕ}
  (G : TropMat n) (a r m : ℕ) :
  tropicalDecrypt ⟨a⟩ (tropicalEncrypt ⟨G, tropPow G a⟩ r m) = m
```

You should exploit `tropical_diffie_hellman_correctness` directly: the shared secret computed from public/ephemeral keys must coincide on both sides.

### Theorem 4: Semantic security transfer under tropical DDH
This is the conceptual center. Do not attempt an unverifiable asymptotic cryptography paper inside Lean all at once. Instead define an indistinguishability game and prove a **reduction theorem**:

```lean
def TropicalDDHAdvantage ... : ℝ := ...
def TropicalINDCPAAdvantage ... : ℝ := ...

theorem tropical_indcpa_of_tropical_ddh
  {n : ℕ}
  (params : TropicalOWFSecurity) :
  TropicalINDCPAAdvantage params ≤ TropicalDDHAdvantage params + negligibleBound params
```

If negligible functions are too heavy, prove a finite-parameter version:

```lean
theorem tropical_indistinguishable_if_ddh_indistinguishable
  {n : ℕ}
  (ε : ℝ)
  (hddh : TropicalDDHAdvantage n ≤ ε) :
  TropicalINDCPAAdvantage n ≤ ε
```

Then connect to entropy extraction:

```lean
theorem tropical_semantic_security_from_minEntropy
  (params : TropicalOWFSecurity)
  (hH : minEntropy sharedSecret ≥ κ) :
  semanticSecurityAdvantage params ≤ 2 ^ (-(κ - leakage params)/2 : ℝ)
```

This should explicitly build on:
- `post_quantum_key_security_from_minEntropy`
- `tropical_security_dimension_bound`

The conceptual statement: **if the tropical shared secret has sufficient min-entropy and dimension is above the certified security threshold, then the tropical encryption scheme is semantically secure**.

---

## Lean 4 Type-Signature Suggestions

These are not mandatory, but they force precision and should guide implementation.

```lean
abbrev TropNat := WithTop ℕ

def tropAdd (a b : TropNat) : TropNat := min a b
def tropMulScalar (a b : TropNat) : TropNat := a + b

def TropMatrix (n : ℕ) := Matrix (Fin n) (Fin n) TropNat

def tropMul {n : ℕ} (A B : TropMatrix n) : TropMatrix n :=
  fun i j => ⨅ k, (A i k + B k j)

def tropPow {n : ℕ} : TropMatrix n → ℕ → TropMatrix n
| A, 0 => tropId
| A, m+1 => tropMul (tropPow A m) A
```

Security-side abstractions:

```lean
structure TropicalOWFSecurity where
  n : ℕ
  κ : ℕ
  -- add any hardness / entropy / dimension parameters already present in catalog

def TropicalDDHAssumption (params : TropicalOWFSecurity) : Prop := ...
def SemanticSecure (params : TropicalOWFSecurity) : Prop := ...

theorem tropical_semantic_security_of_DDH
  (params : TropicalOWFSecurity)
  (hddh : TropicalDDHAssumption params) :
  SemanticSecure params := ...
```

Reduction-side:

```lean
def tropicalFactorizationProblem (n : ℕ) := TropMatrix n
def tropicalShortestPathProblem (n : ℕ) := TropMatrix n × Fin n × Fin n

def manyOneReduces {α β : Type _} (P : α → Prop) (Q : β → Prop) : Prop :=
  ∃ f : α → β, ∀ x, P x → Q (f x)

theorem tropical_key_recovery_manyOneReduces_shortestPath
  {n : ℕ} :
  manyOneReduces
    (fun K : tropicalFactorizationProblem n => ∃ A B, tropMul A B = K)
    (fun I : tropicalShortestPathProblem n => shortestPathSolvable I) := ...
```

This theorem is formal, nontrivial, and exactly the kind of bridge result that can later host full complexity-theoretic hardness assumptions.

---

## Proof Strategy Architecture

### Strategy A: Graph-theoretic semantics first, cryptography second
1. Define min-plus matrix multiplication and prove its path semantics.
2. Show that any factorization witness induces a family of constrained path witnesses in a layered graph.
3. Use that layered-graph interpretation to prove key-recovery-to-path reduction.
4. Only then package the construction as a public-key scheme and transfer semantic security from tropical DDH/min-entropy.

Why this is promising: it aligns perfectly with Mathlib’s strengths in matrices, finite types, and order-theoretic algebra. It also avoids getting trapped early in game-based cryptography bureaucracy.

### Strategy B: Algebraic semiring route
1. Instantiate or define a tropical semiring structure.
2. Prove associativity, identity, and exponentiation lemmas abstractly.
3. Derive correctness of key exchange/encryption as a semiring-action theorem.
4. Interpret hardness as inversion/factorization in that semiring and attach reduction statements later.

Why this is elegant: it yields reusable infrastructure and may generalize beyond this project.  
Why it is riskier: semiring instances over min-plus structures with infinities and matrix multiplication can create coercion and typeclass friction.

### Strategy C: Security-game-first route
1. Formalize a simplified IND-CPA game for a one-message encryption experiment.
2. Define a tropical DDH game.
3. Construct an explicit adversary transformation from IND-CPA adversaries to DDH distinguishers.
4. Invoke `post_quantum_key_security_from_minEntropy` to bound residual leakage.

Why this matters: it produces the headline theorem fastest if the algebraic layer is already available from the catalog.  
Why it is secondary: without the path/factorization reduction, the work risks looking like generic cryptographic formalization instead of a field-opening tropical cryptography theorem.

**Recommended order:** A → C → B.  
First secure the graph/tropical semantics and reduction theorem, then prove security transfer, then abstract/generalize.

---

## How to Build on the Catalog Theorems

### 1. `tropical_diffie_hellman_correctness`
Use this as the correctness spine for any encryption mechanism whose masking key is derived from two tropical exponentiations. The key step is to show your encryption scheme’s decryption key equals the sender’s masking key by direct instantiation of the theorem.

### 2. `tropical_plus_distributes_over_min`
This is not cosmetic. Use it to normalize tropical polynomial or matrix-entry expressions arising during:
- associativity of `tropMul`,
- simplification of decryption expressions,
- equivalence between path concatenation cost and matrix product entries.

You should aggressively rewrite with this lemma when proving composition identities.

### 3. `tropical_security_dimension_bound`
Use it to parameterize security: show that if the matrix dimension or ambient tropical rank exceeds the certified threshold, then brute-force or low-entropy attacks are excluded by the existing bound. Even if this does not prove hardness, it gives a formalized **dimension-growth security monotonicity theorem**.

Example target:

```lean
theorem tropical_semantic_security_above_dimension_threshold
  (params : TropicalOWFSecurity)
  (h : params.n ≥ tropical_security_dimension_bound params) :
  secureInstance params := ...
```

### 4. `post_quantum_key_security_from_minEntropy`
Use it to turn a lower bound on the min-entropy of the tropical shared secret into a concrete semantic-security statement. This is your bridge from algebraic unpredictability to cryptographic indistinguishability.

---

## Cross-Domain Connections You Must Exploit

### Tropical geometry × cryptography
Your scheme should be interpreted not just as matrix arithmetic but as computation in a tropical moduli space of weighted paths. The public key is a point in a tropicalized representation space; private-key recovery is a decomposition problem in that space.

### Graph algorithms × public-key hardness
The reduction to shortest-path/path-witness problems is the key conceptual surprise. This reframes public-key inversion as **combinatorial optimization in layered weighted graphs**, suggesting a new family of cryptosystems based on optimization hardness rather than number theory or lattices.

### Information theory × post-quantum security
By invoking min-entropy extraction, you connect tropical algebraic hardness to leftover-hash style security. This is the right way to move beyond toy correctness and toward true semantic security.

### Complexity theory × formal verification
Even if full NP-hardness is not completed in Lean this cycle, a verified many-one reduction framework for tropical cryptanalytic tasks would itself be a foundational contribution. It opens the possibility of a machine-checked complexity theory of cryptography over exotic semirings.

### Control theory / dynamic programming × key exchange
Min-plus algebra is native to Bellman equations, optimal control, and scheduling. A tropical cryptosystem therefore hints at cryptographic primitives embedded in path-planning, routing, and control architectures. This is an unexpected and potentially explosive application direction.

---

## Application Keywords

tropical cryptography, min-plus algebra, public-key cryptosystem, semantic security, IND-CPA, tropical DDH, matrix factorization hardness, shortest-path reduction, dynamic programming hardness, post-quantum cryptography, entropy extraction, formal verification, Lean 4, tropical geometry, semiring complexity

---

## Concrete Deliverables

1. **Definitions**
   - `TropMatrix`, `tropMul`, `tropPow`
   - keypair / ciphertext structures
   - factorization problem and path-witness problem
   - tropical DDH and semantic-security notions

2. **Main proved theorems**
   - path semantics of tropical multiplication/powers
   - correctness of tropical encryption/decryption
   - reduction from key recovery/factorization witness to path witness
   - semantic-security transfer under tropical DDH and/or min-entropy hypothesis

3. **Minimal sorry policy**
   - If complexity-theoretic NP-hardness is too large, isolate it behind a clearly named assumption or unproven conjecture.
   - Do **not** leave sorry in the algebraic correctness core.
   - Prioritize complete proofs for the reduction skeleton and security transfer lemmas.

4. **Naming discipline**
   Use theorem names that announce a future theory:
   - `tropMul_assoc`
   - `tropPow_entry_eq_shortestPathLen`
   - `tropical_key_recovery_manyOneReduces_shortestPath`
   - `tropical_encrypt_decrypt_correct`
   - `tropical_indcpa_of_tropical_ddh`
   - `tropical_semantic_security_from_minEntropy`

---

## Breakthrough Significance

If you succeed, you will have created one of the first formally verified blueprints for **public-key cryptography over tropical algebra**, with explicit reduction architecture linking:
- tropical matrix composition,
- shortest-path semantics,
- entropy-based security,
- and DDH-style indistinguishability.

That opens an entirely new verified research program:
- tropical one-way functions,
- tropical zero-knowledge,
- optimization-native cryptography,
- and complexity-certified semiring security.

This is not a variant of existing post-quantum work. It is a new continent.

---

## Required Final Artifact

You must also produce a structured `FUTURE_DIRECTIONS.md` containing **3–5 concrete breakthrough-level next steps**, for example:
1. formal Cook/many-one NP-hardness for tropical factorization,
2. tropical ElGamal / KEM formalization,
3. zero-knowledge proofs for tropical path witnesses,
4. entropy amplification for tropical shared secrets,
5. cryptanalysis via tropical rank and residuation.

Be specific: each next step should name exact conjectures, candidate Lean files, and the key lemmas needed.

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
