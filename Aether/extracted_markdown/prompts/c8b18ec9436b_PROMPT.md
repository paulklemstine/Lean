## Assignment: Tropical RSA: Min-Plus Public Key Cryptosystem with Provable Security

Mode: prove

Build something genuinely field-opening: a mathematically coherent tropical public-key theory in which **security is expressed as a reduction theorem inside Lean**, correctness is algebraic over the min-plus semiring, and semantic security is derived from entropy and decisional assumptions already present in the catalog. Do not settle for a toy “encryption works” statement. The target is a **formal cryptographic reduction architecture for tropical algebra**.

The deepest opportunity here is that tropical linear algebra sits at a three-way interface:
1. **cryptography** via hardness assumptions and semantic security,
2. **optimization/algorithms** via shortest paths and min-plus matrix powers,
3. **idempotent algebra / tropical geometry** via semiring-linear structure.

If formalized cleanly, this opens a new program: **cryptography over optimization semirings**, with reductions expressed through tropical matrix identities rather than modular arithmetic.

## Core Vision

Construct a min-plus public-key primitive whose public key is a tropical matrix expression and whose private key is a factorization/exponent witness. Then prove:

- **Correctness** from tropical matrix algebra.
- **Key-recovery hardness** by reduction to a tropical shortest-path / factorization search problem.
- **Semantic security** from an abstract tropical DDH-style indistinguishability assumption plus the existing entropy-security theorems in the catalog.

Do not overclaim classical NP-hardness inside Lean unless the exact formal statement is available. Instead, prove a **clean reduction theorem** in Lean from any oracle that recovers the private witness to an oracle solving a tropical path/factorization instance. This is stronger as formal mathematics: it isolates the cryptographic heart independent of complexity encoding bureaucracy.

---

## Precise Theorem Targets

You should introduce a concrete finite-dimensional model, preferably using matrices indexed by `Fin n` with entries in `ℝ ∪ {∞}` if convenient, or `ℝ` if the existing `TropMat n` already packages the tropical operations. Favor the existing `TropMat n` API.

### Target 1: Tropical public-key correctness theorem

Define a public-key scheme where:
- secret key is `(a, b : ℕ)` or a factor pair/witness,
- public key includes tropical powers or products derived from a public generator `G : TropMat n`,
- encryption/decryption is defined using tropical multiplication/powers,
- correctness states that decryption recovers the plaintext.

A good theorem shape is:

```lean
theorem tropical_rsa_correctness
    (n : ℕ) (G M : TropMat n) (a b : ℕ)
    (hcomm : TropicalCommutes G M) :
    decrypt G a (encrypt G b M) = M
```

If the existing infrastructure is closer to Diffie–Hellman than RSA, lean into that and define the “RSA” terminology as a **public-key tropical exponentiation/factorization analogue** rather than literal integer RSA. A more realistic formal target may be:

```lean
theorem tropical_public_key_correctness
    (n : ℕ) (G M : TropMat n) (a b : ℕ) :
    tropicalDecrypt a (tropicalEncrypt b G M) =
      tropicalCombineKey G a b ⊗ M
```

followed by a specialization showing the shared-key terms agree using `tropical_diffie_hellman_correctness`.

Most promising exact bridge theorem:

```lean
theorem tropical_shared_secret_well_defined
    (n : ℕ) (G : TropMat n) (a b : ℕ) :
    tropicalPow (tropicalPow G a) b = tropicalPow (tropicalPow G b) a
```

This should likely be derived from the catalog theorem:

- `tropical_diffie_hellman_correctness`

and used as the algebraic engine for correctness.

---

### Target 2: Key-recovery reduction theorem

Formalize an abstract search problem:
- `PublicInstance n := TropMat n × TropMat n` or a structure containing generator/public key.
- `SecretWitness n := ℕ` or a factorization witness / path witness.
- `RecoversSecret A := ∀ inst, A inst = some sk → ValidSecret inst sk`.

Then define a shortest-path-style witness extraction problem in the tropical semiring. Since min-plus matrix multiplication computes path costs, the key conceptual theorem is:

> Any algorithm that recovers the private tropical exponent/factorization witness from the public key induces an algorithm that reconstructs a tropical shortest-path witness for the associated weighted digraph encoded by the public matrix.

A Lean-friendly statement:

```lean
theorem tropical_key_recovery_reduces_to_path_witness
    (n : ℕ)
    (A : PublicKey n → Option (SecretKey n)) :
    RecoversSecret A →
    ∃ B : PathInstance n → Option (PathWitness n),
      SolvesPathWitness B
```

An even better theorem, because it is constructive and more likely provable:

```lean
theorem tropical_secret_recovery_yields_path_solver
    (n : ℕ)
    (recover : PublicKey n → Option (SecretKey n))
    (hrec : ∀ pk sk, SecretRel pk sk → recover pk = some sk) :
    ∃ solve : PathInstance n → Option (PathWitness n),
      ∀ inst w, PathRel inst w → solve inst = some w
```

But the strongest mathematically meaningful version is a many-one reduction:

```lean
theorem tropical_path_problem_many_one_reduces_key_recovery
    (n : ℕ) :
    PathWitnessProblem n ≤m TropicalKeyRecoveryProblem n
```

If defining many-one reductions is too heavy, use an explicit reduction function:

```lean
theorem tropical_path_to_key_recovery_reduction
    (n : ℕ) :
    ∃ f : PathInstance n → PublicKey n,
    ∀ inst,
      (∃ sk, ValidSecret (f inst) sk) ↔
      (∃ w, ValidPathWitness inst w)
```

This theorem is the real breakthrough: it recasts tropical cryptanalysis as tropical optimization.

---

### Target 3: Semantic security from tropical DDH + entropy

Build directly on:

- `tropical_semantic_security_from_minEntropy`
- `post_quantum_key_security_from_minEntropy`
- `berggren_key_security_from_minEntropy`

and connect them to a tropical decisional assumption.

Define a tropical DDH indistinguishability predicate for tuples like
`(G, G^a, G^b, G^(a+b))` or whatever operation matches your `TropMat` API. Then prove a reduction theorem of the form:

```lean
theorem tropical_semantic_security_from_DDH
    (n : ℕ)
    (Adv : CiphertextView n → Bool)
    (hDDH : TropicalDDHHard n Adv)
    (hEnt : SufficientMinEntropy n) :
    SemanticSecure (TropicalPKEScheme n)
```

If the existing theorem `tropical_semantic_security_from_minEntropy` is already abstract enough, prove a bridge lemma:

```lean
theorem tropical_DDH_implies_minEntropy_hybrid
    (n : ℕ)
    (hDDH : TropicalDDHAssumption n) :
    SufficientMinEntropy n
```

and then obtain semantic security by composition:

```lean
theorem tropical_rsa_semantic_security
    (n : ℕ)
    (hDDH : TropicalDDHAssumption n) :
    SemanticSecure (TropicalPKEScheme n)
```

This is likely the cleanest way to exploit the catalog.

---

## Suggested Lean 4 Type Signatures

These are aspirational but concrete enough to guide implementation.

```lean
structure TropicalPublicKey (n : ℕ) where
  G : TropMat n
  A : TropMat n

structure TropicalSecretKey where
  exp : ℕ

def SecretRel {n : ℕ} (pk : TropicalPublicKey n) (sk : TropicalSecretKey) : Prop :=
  pk.A = tropicalPow pk.G sk.exp
```

```lean
structure PathInstance (n : ℕ) where
  W : TropMat n
  s t : Fin n

structure PathWitness (n : ℕ) where
  cost : ℝ
  nodes : List (Fin n)
```

```lean
def ValidPathWitness {n : ℕ} (inst : PathInstance n) (w : PathWitness n) : Prop := ...
```

```lean
theorem tropical_shared_secret_well_defined
    (n : ℕ) (G : TropMat n) (a b : ℕ) :
    tropicalPow (tropicalPow G a) b = tropicalPow (tropicalPow G b) a := ...
```

```lean
theorem tropical_public_key_correctness
    (n : ℕ) (G M : TropMat n) (a b : ℕ) :
    tropicalDecrypt a (tropicalEncrypt b G M) =
      tropicalAct (tropicalPow (tropicalPow G a) b) M := ...
```

```lean
theorem tropical_key_recovery_reduces_to_factor_witness
    (n : ℕ) :
    ∃ encode : PathInstance n → TropicalPublicKey n,
    ∀ inst,
      (∃ sk, SecretRel (encode inst) sk) →
      (∃ w, ValidPathWitness inst w) := ...
```

```lean
theorem tropical_rsa_semantic_security
    (n : ℕ)
    (hDDH : TropicalDDHAssumption n)
    (hEnt : MinEntropyGood n) :
    SemanticSecure (TropicalPKEScheme n) := ...
```

If `SemanticSecure` is not already defined in the catalog, define a modest but nontrivial game-based notion using message indistinguishability under chosen plaintexts with finite message spaces.

---

## Proof Strategy Architecture

### Strategy A: Algebra-first, reduction-second
Most promising.

1. **Algebraic kernel**
   - Prove tropical power associativity / exponent composition:
     `tropicalPow (tropicalPow G a) b = tropicalPow G (a*b)` or the API-equivalent.
   - Derive shared-secret equality from this and `tropical_diffie_hellman_correctness`.

2. **Cryptosystem correctness**
   - Define encryption/decryption in terms of tropical matrix action.
   - Use the algebraic kernel to show sender and receiver compute the same masking matrix.

3. **Security bridge**
   - Introduce an abstract DDH assumption over `TropMat n`.
   - Reduce ciphertext indistinguishability to replacement of the shared secret by a high-entropy matrix distribution.
   - Invoke `tropical_semantic_security_from_minEntropy`.

Why this is strongest: it exploits existing catalog theorems directly and produces a reusable algebraic API for future tropical cryptography.

---

### Strategy B: Graph-theoretic semantics of tropical matrices
Very high conceptual value.

1. Interpret a tropical matrix as a weighted digraph adjacency/cost matrix.
2. Show tropical matrix powers encode path costs of fixed length, and closures encode shortest paths.
3. Construct a public-key instance from a path instance so that a secret-recovery witness determines a shortest-path witness.
4. Prove a reduction theorem by explicitly decoding path data from a recovered factor/exponent witness.

Why this matters: it turns the cryptosystem into an optimization-native object, not merely an algebraic curiosity. This is the route that makes the project scientifically memorable.

Potential issue: shortest-path “NP-hardness” is delicate because ordinary shortest path is polynomial-time, while tropical factorization and constrained path variants can be hard. So be precise: if you need hardness, target **tropical matrix factorization**, **path decomposition**, or a constrained shortest-path witness problem, not unconstrained shortest path. If the original prompt says “shortest-path problem which is NP-hard,” correct that mathematically in the formal development. A formal counter-correction is a virtue, not a weakness.

---

### Strategy C: Entropy-extraction security pipeline
Best for minimizing sorry.

1. Formalize a message/key distribution with sufficient min-entropy.
2. Prove the public transcript preserves enough entropy under the tropical map.
3. Apply `tropical_semantic_security_from_minEntropy`.
4. Add a DDH-style assumption only as a lemma establishing the entropy or pseudorandomness hypothesis.

Why useful: fastest route to a complete Lean theorem with immediate catalog reuse. This may not capture the full reduction-to-factorization dream, but it will yield a certified semantic-security theorem quickly and can coexist with Strategies A/B.

---

## Critical Mathematical Insight: Correct the Hardness Narrative

The assignment’s phrase “shortest-path problem which is NP-hard in the min-plus semiring” is mathematically suspicious if interpreted as ordinary shortest path. Standard shortest path is polynomial-time. The genuinely hard objects nearby are:

- tropical matrix factorization,
- min-plus rank computation,
- constrained shortest path variants,
- shortest path with prescribed decomposition structure,
- decoding factor witnesses from tropical matrix products.

So the most breakthrough version of this project is to prove one of:

1. **Reduction from tropical key recovery to tropical matrix factorization witness extraction**, or
2. **Reduction from constrained path witness extraction to key recovery**, where the path constraints are what carry hardness.

This is exactly the kind of correction Aristotle should make: sharpen the statement so the formal theorem is mathematically honest and stronger.

---

## Catalog Build Plan

Use the existing theorems explicitly.

### 1. `tropical_diffie_hellman_correctness`
Use this as the engine for equality of sender/receiver shared secrets. If its statement is already:
```lean
theorem tropical_diffie_hellman_correctness (n : ℕ) (G : TropMat n) (a b : ℕ) : ...
```
then wrap it into your encryption correctness theorem instead of reproving commutation from scratch.

### 2. `tropical_semantic_security_from_minEntropy`
This should be the final security discharge step. Build a theorem showing your key/ciphertext distribution satisfies its hypotheses.

### 3. `post_quantum_key_security_from_minEntropy`
Mine this theorem for proof pattern and reusable entropy abstractions. If its assumptions are generic, instantiate them for tropical keys.

### 4. `berggren_key_security_from_minEntropy`
This is a cross-domain template: it shows how a nonclassical algebraic structure can still inherit entropy-based security. Reuse the same architecture for tropical matrices.

### 5. `tropical_plus_distributes_over_min`
Use this to simplify tropical algebra rewrites in correctness proofs and any matrix-entry calculations.

---

## Cross-Domain Connections You Must Exploit

### Tropical geometry × cryptography
Public keys as tropical varieties / min-plus linear images suggest a new cryptographic paradigm where hiding comes from combinatorial degeneracy of tropical factorization.

### Optimization × cryptanalysis
Min-plus matrix multiplication is dynamic programming in algebraic clothing. Formal reductions between key recovery and path witness extraction would create a new language for optimization-based cryptanalysis.

### Semiring linear algebra × post-quantum cryptography
Classical cryptography relies heavily on rings and groups. A semiring-native hardness framework could diversify post-quantum assumptions beyond lattices, codes, and isogenies.

### Information theory × tropical algebra
Entropy-based semantic security in tropical settings hints at a broader “idempotent information theory,” where uncertainty and distinguishability are analyzed over semiring-valued observables.

### Complexity theory × formal methods
A Lean-certified reduction theorem, even without full NP-hardness formalization, is a major contribution: it gives machine-checked hardness architecture for nonclassical cryptographic assumptions.

---

## Concrete Deliverables

1. A new Lean file, likely:
   - `Cryptography/TropicalRSA.lean`
   or
   - `Cryptography/TropicalPublicKey.lean`

2. Definitions:
   - `TropicalPublicKey`
   - `TropicalSecretKey`
   - `tropicalEncrypt`
   - `tropicalDecrypt`
   - `SecretRel`
   - `TropicalDDHAssumption`
   - optional: `PathInstance`, `PathWitness`, `ValidPathWitness`

3. Theorems:
   - `tropical_shared_secret_well_defined`
   - `tropical_public_key_correctness`
   - `tropical_key_recovery_reduces_to_factor_witness` or graph/path analogue
   - `tropical_rsa_semantic_security`

4. Minimize sorry by proving at least one full end-to-end theorem: ideally semantic security or correctness.

5. Create `FUTURE_DIRECTIONS.md` with 3–5 concrete next theorems.

---

## High-Value Theorem Formulations

If you want one flagship theorem, make it this:

```lean
theorem tropical_public_key_security_pipeline
    (n : ℕ)
    (hDDH : TropicalDDHAssumption n)
    (hEnt : MinEntropyGood n) :
    Correct (TropicalPKEScheme n) ∧
    SemanticSecure (TropicalPKEScheme n)
```

If you want the truly original theorem, make it this:

```lean
theorem tropical_factor_witness_reduction
    (n : ℕ) :
    ∃ encode : PathInstance n → TropicalPublicKey n,
      ∀ inst,
        (∃ sk, SecretRel (encode inst) sk) ↔
        (∃ w, ValidPathWitness inst w)
```

This is the one that opens a field.

---

## What to Avoid

- Do not claim literal RSA arithmetic over the tropical semiring unless you define a faithful analogue.
- Do not assert NP-hardness of ordinary shortest path.
- Do not produce only toy examples with `n = 2`.
- Do not stop at “encryption/decryption commute”; formalize a reduction or a semantic-security theorem.
- Do not ignore the entropy theorems already in the catalog.

---

## Application Keywords

tropical cryptography, min-plus semiring, semantic security, DDH assumption, matrix factorization hardness, shortest-path witness extraction, semiring linear algebra, tropical geometry, optimization-based cryptanalysis, formal verification, Lean 4, post-quantum cryptography, entropy extraction, idempotent algebra, graph semirings

---

## Required FUTURE_DIRECTIONS.md

You must produce `FUTURE_DIRECTIONS.md` with 3–5 specific next steps. Include items at this level of ambition:

1. Formalize **tropical ElGamal / KEM** and prove IND-CPA from tropical DDH.
2. Prove a **factorization-witness hardness transfer theorem** from tropical rank/factorization to key recovery.
3. Develop **tropical pseudorandom generators** from min-plus walk dynamics.
4. Formalize **idempotent information theory**: tropical mutual information and a data-processing inequality.
5. Connect tropical cryptosystems to **weighted automata** and formal language hardness.

Be bold: the goal is not to imitate classical cryptography with exotic notation, but to create a new cryptographic mathematics native to tropical algebra.

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
