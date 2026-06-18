## Assignment: Homomorphic Encryption over Tropical Semirings

**Mode:** prove

You should **not** try to force a classical Ring-LWE-style FHE theorem into a semiring where subtraction is absent and standard IND-CPA reductions are not yet formalized in the catalog. That would likely produce a weak or vacuous formalization. Instead, carve out a mathematically sharp, foundational breakthrough:

> **Formalize and prove that tropical idempotence yields exact, noise-stable homomorphic evaluation for a broad class of min-plus circuits, and isolate the precise obstruction to classical-style semantic security.**

This is the right first theorem family. If done well, it opens a new field: **idempotent cryptography**, where correctness/bootstrapping is governed by semiring order theory rather than norm growth.

---

## Core Breakthrough Objective

Construct a concrete encryption abstraction over the tropical semiring `(α, ⊕, ⊗) = (ℕ∞ or ℝ≥0∞, min, +)` and prove:

1. **Homomorphic correctness** for tropical addition and multiplication.
2. **Noise stabilization / exact bootstrapping** driven by idempotence of `min`.
3. A precise **order-theoretic security barrier**: deterministic exact min-plus homomorphism leaks order information, so any CPA-style security must randomize through fibers or quotient observables.

This is more revolutionary than “yet another FHE variant”: it identifies a genuinely new cryptographic geometry where **noise is replaced by residuation/order collapse**.

---

## Precise Theorem Targets

Work with a concrete message space first, ideally `WithTop ℕ` or `ℕ` if top complicates the first pass. Define ciphertexts as randomized lifts equipped with a decryption map preserving tropical structure.

### Theorem 1: Exact tropical homomorphic correctness

Define a structure like:

```lean
structure TropicalEncScheme where
  Cipher : Type
  key : Type
  encode : key → ℕ → Cipher
  decode : key → Cipher → ℕ
  cmin : Cipher → Cipher → Cipher
  cplus : Cipher → Cipher → Cipher
  correct_min : ∀ k m₁ m₂,
    decode k (cmin (encode k m₁) (encode k m₂)) = min m₁ m₂
  correct_plus : ∀ k m₁ m₂,
    decode k (cplus (encode k m₁) (encode k m₂)) = m₁ + m₂
```

Then prove compositional correctness for all tropical circuits.

### Lean 4 theorem signature
```lean
inductive TropCircuit
| input : ℕ → TropCircuit
| tmin : TropCircuit → TropCircuit → TropCircuit
| tplus : TropCircuit → TropCircuit → TropCircuit

def TropCircuit.eval (σ : ℕ → ℕ) : TropCircuit → ℕ
| .input i => σ i
| .tmin φ ψ => min (eval σ φ) (eval σ ψ)
| .tplus φ ψ => eval σ φ + eval σ ψ

def TropCircuit.ceval
  (S : TropicalEncScheme) (k : S.key) (τ : ℕ → S.Cipher) :
  TropCircuit → S.Cipher
| .input i => τ i
| .tmin φ ψ => S.cmin (ceval S k τ φ) (ceval S k τ ψ)
| .tplus φ ψ => S.cplus (ceval S k τ φ) (ceval S k τ ψ)

theorem tropical_homomorphic_correctness
  (S : TropicalEncScheme) (k : S.key) (σ : ℕ → ℕ) :
  ∀ φ : TropCircuit,
    S.decode k (φ.ceval S k (fun i => S.encode k (σ i))) = φ.eval σ
```

This is the foundational theorem. It is nontrivial because it upgrades local homomorphism laws to arbitrary circuit evaluation.

---

### Theorem 2: Idempotent bootstrapping / no-noise-growth theorem

You need a mathematically meaningful notion of “noise.” In tropical settings, the right notion is not additive error norm but a **decrypt-invariant fiber radius** or **stability under repeated min-gates**.

A good formal target:

Define a predicate `StableUnderDecode k c : Prop := decode k (refresh k c) = decode k c`.  
Then define refresh via a canonical re-encryption of the decrypted value.

```lean
def refresh (S : TropicalEncScheme) (k : S.key) (c : S.Cipher) : S.Cipher :=
  S.encode k (S.decode k c)

theorem refresh_correct
  (S : TropicalEncScheme) (k : S.key) (c : S.Cipher) :
  S.decode k (refresh S k c) = S.decode k c
```

Now the breakthrough theorem should state that tropical `min` is automatically stable under iterated refresh, and repeated min-composition does not accumulate decryption error.

```lean
theorem tropical_min_idempotent_bootstrap
  (S : TropicalEncScheme) (k : S.key) (c : S.Cipher) :
  S.decode k (S.cmin c c) = S.decode k c
```

and more generally

```lean
theorem tropical_min_circuit_refresh_invariant
  (S : TropicalEncScheme) (k : S.key) :
  ∀ φ : TropCircuit, (∀ i, True) →
    S.decode k
      (refresh S k (φ.ceval S k (fun i => S.encode k i))) =
    S.decode k (φ.ceval S k (fun i => S.encode k i))
```

If your concrete scheme includes a noise parameter `ν : Cipher → ℕ`, prove:

```lean
theorem min_noise_nonexpanding
  (ν : S.Cipher → ℕ) :
  ∀ c₁ c₂, ν (S.cmin c₁ c₂) ≤ max (ν c₁) (ν c₂)
```

and ideally, for an exact scheme:

```lean
theorem refresh_resets_noise
  (ν : S.Cipher → ℕ) :
  ∀ k c, ν (refresh S k c) = 0
```

This theorem family gives the precise mathematical content behind the phrase “bootstrapping without classical noise growth.”

---

### Theorem 3: Security obstruction / order leakage theorem

Do not overclaim “CPA security” unless you define an actual probability distribution and indistinguishability game in Lean. A more profound theorem is:

> Any deterministic exact tropical-homomorphic encryption into an ordered ciphertext semiring leaks plaintext order through ciphertext evaluation.

A clean theorem target:

```lean
class OrderedTropicalEncScheme extends TropicalEncScheme where
  cle : Cipher → Cipher → Prop
  decode_monotone :
    ∀ {k} {c₁ c₂}, cle c₁ c₂ → decode k c₁ ≤ decode k c₂
  encode_reflects_order :
    ∀ k m₁ m₂, cle (encode k m₁) (encode k m₂) ↔ m₁ ≤ m₂
```

Then prove:

```lean
theorem deterministic_tropical_order_leak
  (S : OrderedTropicalEncScheme) (k : S.key) (m₁ m₂ : ℕ) :
  S.cle (S.encode k m₁) (S.encode k m₂) ↔ m₁ ≤ m₂
```

Interpretation: exact deterministic homomorphism reveals at least the plaintext order type. Hence true semantic security requires randomized encryption where many ciphertexts decrypt to the same tropical value.

A stronger version:

```lean
theorem no_perfect_secrecy_of_injective_deterministic_tropical_enc
  (S : TropicalEncScheme)
  (hinj : Function.Injective (S.encode ·?·)) :
  ¬ True  -- replace by your formal perfect-secrecy predicate
```

If a full Shannon-style perfect secrecy predicate is too heavy, define a simpler finite-support distinguishability notion and prove failure for deterministic injective schemes.

This is not a negative result for its own sake; it identifies the exact design space for tropical cryptography.

---

## Most Promising Concrete Construction

Start with a **masked-offset scheme** over `ℕ × ℕ`:

- plaintext `m : ℕ`
- ciphertext `c = (r, m + r)`
- decrypt by `decode (r, s) := s - r` — but subtraction is awkward in `ℕ`

So instead use a representation where subtraction is built into a proof-relevant invariant, or move to `ℤ` for ciphertexts while plaintext stays in `ℕ`.

A better semiring-friendly option is to define ciphertexts as **fibers over plaintexts**:

```lean
structure Cipher where
  val : ℕ
  noise : ℕ
```

with
- `decode c := val`
- `cmin c₁ c₂ := if val₁ ≤ val₂ then c₁ else c₂`
- `cplus c₁ c₂ := ⟨val₁ + val₂, noise₁ + noise₂⟩`

Then correctness is immediate, and you can define `refresh ⟨v,n⟩ := ⟨v,0⟩`.

This is not yet semantically secure, but it is the right object for proving the algebraic theorems. After that, add randomness by replacing `noise : ℕ` with a finite set/fiber witness and prove decryption invariance.

---

## Proof Strategy Architecture

### Strategy A: Structural recursion on circuits
Most promising for Theorem 1.

1. Define `TropCircuit.eval` and `TropCircuit.ceval`.
2. Prove local correctness lemmas for `tmin` and `tplus` using `correct_min` and `correct_plus`.
3. Induct on `φ : TropCircuit`.

Why this is best: it is Lean-native, compositional, and converts algebraic homomorphism into a reusable certified evaluator theorem.

---

### Strategy B: Semiring morphism / initial algebra viewpoint
Best for elegance and later generalization.

1. Package plaintext tropical operations as a semiring-like structure (likely custom, since min-plus is not a ring and may need an idempotent semiring class).
2. Show `decode` is a homomorphism from ciphertext operations to plaintext operations.
3. Derive circuit correctness as the universal property of term evaluation.

Why it matters: this opens the path to **generic homomorphic evaluation over idempotent semirings**, not just one ad hoc scheme.

---

### Strategy C: Order-theoretic / residuation proof of security obstruction
Best for Theorem 3.

1. Formalize ciphertext order `cle` and monotonicity/reflection assumptions.
2. Show that order on plaintexts is decidable by comparing encryptions.
3. Conclude any deterministic exact scheme leaks a nontrivial invariant.

Why this is revolutionary: it reframes cryptographic impossibility as a theorem in **idempotent order geometry**.

---

## How to Build on Catalog Theorems

Use the existing theorem

- `tropical_plus_distributes_over_min`

from the cited files as the algebraic engine for normalization and evaluation reassociation. Explicitly:

- in circuit proofs, when handling mixed nodes `tplus (tmin φ ψ) χ`, rewrite using distributivity to compare different evaluation orders;
- in future bootstrapping lemmas, use distributivity to show refresh can be pushed through normalized circuit forms;
- connect with `tropical_security_dimension_growth` as a model for asymptotic parameter theorems: after correctness is established, define ciphertext fiber size or ambiguity dimension and prove it grows with a security parameter.

A concrete theorem to aim for using the catalog result:

```lean
theorem tropical_circuit_normal_form_sound
  (σ : ℕ → ℕ) :
  ∀ φ : TropCircuit, ∃ ψ : TropCircuit,
    TropCircuit.eval σ ψ = TropCircuit.eval σ φ ∧
    -- ψ in a chosen distributive normal form
    True
```

This would let you reason about homomorphic evaluation through normal forms, not just syntax trees.

---

## Cross-Domain Connections

This project becomes field-opening if you explicitly connect it to at least one of:

1. **Idempotent analysis / control theory**  
   Min-plus algebra is the language of shortest paths, dynamic programming, Hamilton–Jacobi limits, and discrete optimal control.  
   Interpretation: encrypted tropical evaluation = privacy-preserving dynamic programming.

2. **Mathematical morphology / image processing**  
   `min` and `+` are erosion/dilation primitives in tropical disguise.  
   Interpretation: homomorphic tropical circuits enable encrypted morphological filtering.

3. **Neural networks / tropical geometry**  
   Piecewise-linear networks admit tropicalizations.  
   Interpretation: tropical homomorphic evaluation may support encrypted inference for tropicalized models without classical FHE noise explosion.

4. **Semantics of computation / program algebra**  
   Idempotent semirings govern weighted automata and shortest-path semantics.  
   Interpretation: this is cryptography for automata-valued computation.

You should explicitly state at least one bridge theorem or application corollary, e.g.:

```lean
theorem encrypted_shortest_path_step_correct
  ...
```

showing a Bellman update is homomorphically evaluable.

---

## Application Keywords

tropical cryptography, idempotent semiring, homomorphic evaluation, bootstrapping, min-plus algebra, order-theoretic security, encrypted dynamic programming, shortest paths, weighted automata, tropical geometry, mathematical morphology, privacy-preserving optimization

---

## Concrete Deliverables

1. Define `TropCircuit`, `TropicalEncScheme`, `refresh`, and a concrete example scheme.
2. Prove `tropical_homomorphic_correctness`.
3. Prove one or more no-noise-growth theorems:
   - `tropical_min_idempotent_bootstrap`
   - `min_noise_nonexpanding`
   - `refresh_correct`
4. Prove a security obstruction theorem:
   - `deterministic_tropical_order_leak`
5. If time permits, formalize an application corollary for shortest-path or dynamic programming updates.

---

## Ambition Filter

Do **not** settle for a toy statement like “min is associative” or “encryption preserves addition” for one gate. The breakthrough is the synthesis:

> **exact circuit-level homomorphism + idempotent bootstrapping theorem + impossibility/obstruction theorem for deterministic secrecy**

That combination defines the subject.

---

## FUTURE_DIRECTIONS.md Requirement

You must produce a structured `FUTURE_DIRECTIONS.md` with **3–5 concrete breakthrough next steps**, for example:

1. randomized fiber-based tropical encryption with a formal finite-support IND-style game;
2. homomorphic Bellman–Ford / Viterbi evaluation over encrypted weighted graphs;
3. categorical formulation via idempotent semiring objects and homomorphic semantics;
4. tropical information theory: define and prove a data-processing inequality in min-plus entropy;
5. bridge theorem between tropical neural inference and encrypted shortest-path computation.

Be specific, theorem-driven, and bold.

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
