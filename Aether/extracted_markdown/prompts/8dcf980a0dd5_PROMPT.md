## Assignment: Direction 1: Universal Affine Σ-Protocol Extraction

**Mode:** prove

Build a genuinely new formal theory of **universal witness extraction for affine Σ-protocols** over finite fields, with explicit Lean 4 abstractions that subsume Schnorr-style special soundness as one instance of a broader linear-algebraic phenomenon. The goal is not to re-prove a known protocol lemma in a different notation; the goal is to isolate the exact algebraic mechanism by which *rewinding + two accepting transcripts* becomes *solving a linear system*, and then make that mechanism reusable across protocol families.

This direction is compelling because it reframes special soundness as a theorem of **finite-dimensional linear algebra over `ZMod q`**, rather than a protocol-by-protocol trick. If successful, it opens a path toward a **library of extraction principles** parameterized by acceptance matrices, with immediate applications to formal cryptography, zero-knowledge compilers, Fiat–Shamir analyses, and mechanized reductions.

---

## Core Mathematical Vision

A Σ-protocol transcript typically has the form
- commitment `a`
- challenge `c : ZMod q`
- response `z : (ZMod q)^n`

and verification checks that certain algebraic equalities hold. In Schnorr, the acceptance equation is
`g^z = a * y^c`,
which after taking exponents becomes affine in the witness exponent. In Chaum–Pedersen and Okamoto, the same phenomenon persists, but with multiple response coordinates and multiple equations.

The breakthrough theorem to formalize is:

> **Universal affine extraction principle.**  
> Whenever the verifier’s acceptance condition can be encoded as an affine linear relation in the witness variables and transcript responses over `ZMod q`, then any two accepting transcripts with the same commitment and distinct challenges determine the witness by solving a linear system whose coefficient matrix is built from challenge differences and protocol template data.

This should not remain a slogan. State and prove it with exact quantifiers.

---

## Precise Formal Target

Introduce a new abstraction for affine Σ-protocols. One possible minimal design is:

```lean
structure AffineSigmaProtocol (q : ℕ) [Fact q.Prime] where
  Witness : Type
  Statement : Type
  Commitment : Type
  Response : Type
  Eqn : Type
  witnessToVec : Witness → Fin n → ZMod q
  responseToVec : Response → Fin m → ZMod q
  acceptCoeffW : Statement → Commitment → Eqn → Matrix (Fin r) (Fin n) (ZMod q)
  acceptCoeffZ : Statement → Commitment → Eqn → Matrix (Fin r) (Fin m) (ZMod q)
  acceptCoeffC : Statement → Commitment → Eqn → Matrix (Fin r) (Fin 1) (ZMod q)
  acceptConst  : Statement → Commitment → Eqn → Fin r → ZMod q
  accepts :
    Statement → Commitment → ZMod q → Response → Prop
```

Then define a theorem-level predicate saying the acceptance relation is represented by an affine system:
```lean
def AffineAccepts
  (P : AffineSigmaProtocol q) : Prop := ...
```

You may simplify the API if needed, but the abstraction must be strong enough to instantiate:
1. Schnorr
2. Chaum–Pedersen equality of discrete logs
3. Okamoto two-generator protocol

The most important theorem should look morally like this:

```lean
theorem affine_special_soundness_extract
  {q : ℕ} [Fact q.Prime]
  (P : AffineSigmaProtocol q)
  (hAff : P.AffineAccepts)
  (x : P.Statement) (a : P.Commitment)
  (c₁ c₂ : ZMod q) (z₁ z₂ : P.Response)
  (hacc₁ : P.accepts x a c₁ z₁)
  (hacc₂ : P.accepts x a c₂ z₂)
  (hneq : c₁ ≠ c₂)
  (huniq : suitable_uniqueness_condition P x a c₁ c₂) :
  ∃ w : P.Witness, extractor P x a c₁ z₁ c₂ z₂ = some w ∧ WitnessRel P x w
```

If your abstraction makes existence of a witness too weak, strengthen the statement to identify the extracted witness vector uniquely:

```lean
theorem affine_extractor_correct
  ...
  : ∃! wv : Fin n → ZMod q,
      linearWitnessRelation P x wv ∧
      wv = solve_from_two_transcripts ... 
```

A more concrete and likely more Lean-friendly theorem is the following 1-dimensional master lemma:

```lean
theorem one_dim_affine_extract
  {q : ℕ} [Fact q.Prime]
  {α : Type}
  (A B : α → ZMod q)
  (w z₁ z₂ c₁ c₂ : ZMod q)
  (h₁ : z₁ = A () + c₁ * w)
  (h₂ : z₂ = A () + c₂ * w)
  (hneq : c₁ ≠ c₂) :
  w = (z₁ - z₂) * (c₁ - c₂)⁻¹ := ...
```

and then the multidimensional generalization:

```lean
theorem matrix_affine_extract
  {q : ℕ} [Fact q.Prime]
  {n m : ℕ}
  (M : Matrix (Fin m) (Fin n) (ZMod q))
  (w : Fin n → ZMod q)
  (c₁ c₂ : ZMod q)
  (z₁ z₂ t : Fin m → ZMod q)
  (h₁ : z₁ = t + c₁ • (M.mulVec w))
  (h₂ : z₂ = t + c₂ • (M.mulVec w))
  (hneq : c₁ ≠ c₂)
  (hinj : Function.Injective fun v => M.mulVec v) :
  w = extractor_matrix M c₁ z₁ c₂ z₂ := ...
```

For Okamoto, the decisive theorem should specialize to a `2 × 2` system:

```lean
theorem okamoto_extract_correct
  {q : ℕ} [Fact q.Prime]
  (c₁ c₂ : ZMod q) (z₁₁ z₁₂ z₂₁ z₂₂ : ZMod q)
  (hneq : c₁ ≠ c₂)
  (hacc₁ : okamoto_accepts ... c₁ (z₁₁, z₁₂))
  (hacc₂ : okamoto_accepts ... c₂ (z₂₁, z₂₂)) :
  let (w₁, w₂) := okamotoExtractor c₁ z₁₁ z₁₂ c₂ z₂₁ z₂₂
  in okamoto_witness_relation ... w₁ w₂ := ...
```

---

## Minimum Theorem Portfolio

Your file must contain **at least 3 nontrivial theorems**, all with real proof structure. Recommended portfolio:

1. **Master difference lemma over `ZMod q`**  
   Two affine accepting transcripts imply a linear equation in the witness, using subtraction and inversion of `c₁ - c₂`.
   - Uses `by_contra`, field-style reasoning over `ZMod q`, and `calc`.

2. **Universal matrix extractor theorem**  
   If the protocol’s response equations are of the form  
   `z = t + c • M w`, then two accepting transcripts determine `w` uniquely when `M` is injective on witnesses.
   - Uses `rcases`, matrix algebra, and multi-step rewriting.

3. **Protocol instantiation theorem** for Chaum–Pedersen or Okamoto  
   Show the protocol satisfies the affine template and the universal extractor yields the expected witness.
   - Uses structured decomposition of transcripts, `rcases`, and specialized algebra.

A fourth theorem is strongly encouraged:

4. **Obstruction theorem / classification lemma**  
   Characterize when the affine template fails:
   - either challenge-independent rank deficiency,
   - or non-injective witness embedding,
   - or non-affine acceptance dependence.
   
   Example target:
   ```lean
   theorem no_unique_extractor_of_kernel_nontrivial
     ...
     : ¬ ∀ tr₁ tr₂, distinct_challenges tr₁ tr₂ → ∃! w, compatible P tr₁ tr₂ w
   ```
   This is scientifically valuable because it identifies the exact obstruction rather than merely failing to instantiate.

---

## New Definitions You Must Introduce

You must define at least one genuinely new concept absent from the current catalog. Recommended definitions:

1. **Affine transcript compatibility**
   ```lean
   def AffineCompatible ... : Prop := ...
   ```

2. **Universal affine extractor**
   ```lean
   def affineExtractor ... : Option Witness := ...
   ```

3. **Extraction rank condition**
   ```lean
   def HasExtractionRank ... : Prop := ...
   ```
   This should express the invertibility or injectivity needed for unique extraction.

4. **Affine special soundness class**
   ```lean
   class HasAffineSpecialSoundness (P : AffineSigmaProtocol q) : Prop := ...
   ```

These definitions are not cosmetic. They should become the vocabulary through which future protocols are verified.

---

## Proof Strategy Architecture

### Strategy A: Difference-of-transcripts linearization
Most promising.

1. Formalize each accepting equation so that the commitment-dependent term cancels when subtracting two transcripts with the same commitment.
2. Derive
   `z₁ - z₂ = (c₁ - c₂) • M w`.
3. Since `q` is prime and `c₁ ≠ c₂`, prove `c₁ - c₂ ≠ 0`, hence invertible in `ZMod q`.
4. Recover `M w`, then recover `w` using injectivity / left inverse / determinant non-vanishing in the `2 × 2` case.

**Why this is best:** it exposes the universal algebraic core and minimizes protocol-specific group reasoning.

### Strategy B: Build a left-inverse extractor from matrix rank
1. Define an explicit left inverse `L` with `L ⬝ M = 1`.
2. Set
   `w := L.mulVec (((c₁ - c₂)⁻¹) • (z₁ - z₂))`.
3. Prove correctness by direct matrix calculation.
4. Instantiate `L` concretely for Okamoto’s `2 × 2` template.

**Why this matters:** it converts existence of extraction into a reusable certified algorithm, closer to computational cryptography.

### Strategy C: Protocol-first instantiation then abstract upward
1. First prove extraction for Chaum–Pedersen and Okamoto directly.
2. Identify the common matrix skeleton.
3. Refactor into the general affine theorem.
4. Show Schnorr is the rank-1 special case.

**Why this may help:** Lean development may go faster if the abstraction is discovered from successful concrete proofs rather than imposed up front.

Recommended order: **C → A → B** for engineering, but the final library should present **A/B as the conceptual centerpiece**.

---

## Concrete Instantiations to Formalize

### 1. Chaum–Pedersen equality of discrete logarithms
Verification equations:
- `g^z = a₁ * h^c`
- `u^z = a₂ * y^c`

After exponent-linearization, both encode the same witness `w`:
- `z = r + c*w`

This is the easiest nontrivial instance because there are two group equations but only one witness coordinate. The deep insight is that the **same scalar affine law** simultaneously explains consistency across two bases.

Target theorem:
```lean
theorem chaum_pedersen_affine_extractor_correct : ...
```

### 2. Okamoto protocol
Witness `(w₁, w₂)` with response equations
- `z₁ = r₁ + c*w₁`
- `z₂ = r₂ + c*w₂`

Two transcripts give:
- `z₁₁ - z₂₁ = (c₁ - c₂) * w₁`
- `z₁₂ - z₂₂ = (c₁ - c₂) * w₂`

This is the cleanest first multidimensional affine extractor. It should yield an explicit algorithm:
```lean
def okamotoExtractor ... : ZMod q × ZMod q := ...
```

### 3. Range proofs with affine decomposition
Do not overpromise full Bulletproofs. Instead formalize a toy but real affine fragment:
- witness is a bit-decomposition vector or bounded integer decomposition,
- response coordinates are affine in the challenge,
- extraction recovers the decomposition vector.

If the full protocol is too nonlinear, isolate the affine subprotocol and prove an **obstruction theorem** for the nonlinear remainder. That is scientifically stronger than a forced weak formalization.

---

## Cross-Domain Connections You Must Exploit

1. **Cryptography × Linear Algebra**  
   The central message: special soundness is rank/invertibility. This reframes extraction as a finite-field decoding problem.

2. **Cryptography × Coding Theory**  
   Two accepting transcripts with the same commitment act like two noisy-free evaluations of an affine codeword. Extraction is syndrome-free decoding of a rank-1 affine code family.  
   Consider introducing language relating transcript families to affine codes; even one theorem connecting extractor uniqueness to minimum distance / injectivity would be excellent.

3. **Cryptography × Category / Algebraic semantics**  
   If feasible, treat the verifier equation as a natural transformation from witness space to transcript space. Even a lightweight formulation would be visionary: extraction becomes inversion of a morphism in a subcategory of affine maps.

4. **Cryptography × Program verification**  
   The universal extractor is an *algorithm schema*. This makes mechanized cryptographic proof engineering more compositional: protocol verification reduces to proving an affine representation theorem plus rank condition.

At least one theorem should explicitly bridge to another domain, e.g. coding theory:

```lean
theorem affine_extraction_unique_of_code_injective
  ...
  : UniqueDecodingRadiusLikeProperty ...
```

Even if the formal statement is modest, the conceptual bridge matters.

---

## Application Keywords

formal cryptography, zero-knowledge, Σ-protocols, special soundness, witness extraction, finite fields, `ZMod q`, matrix inversion, coding theory, affine geometry, mechanized verification, Fiat–Shamir, proof compilers, rank conditions, protocol semantics

---

## Suggested Lean 4 Engineering Notes

- Use `ZMod q` with `[Fact q.Prime]` so nonzero challenge differences are invertible.
- Expect to need lemmas of the form:
  - `sub_ne_zero.mpr hneq`
  - inversion properties in `ZMod`
  - matrix/vector extensionality
  - scalar distribution over subtraction
- If matrix APIs become heavy, encode vectors as `Fin n → ZMod q` first and postpone matrix packaging.
- For the `2 × 2` extractor, an explicit coordinatewise formula may be easier than general matrix inversion.
- Minimize `sorry`, but if one becomes necessary, isolate it in a low-level linear algebra helper and document exactly what remains.

---

## Falsifiable Conjecture and Computational Test

State at least one explicit conjecture with a clear disproof procedure.

### Conjecture A: affine completeness of textbook Σ-protocols
> Every standard special-sound Σ-protocol with response equations linear in the challenge can be represented in the `AffineSigmaProtocol` class after an appropriate witness embedding.

**Test:** Implement a search over a small suite of protocols/transcript templates in `demo.py`; for each, attempt to fit verifier equations to the affine schema and either synthesize extraction matrices or produce a symbolic obstruction certificate.

### Conjecture B: rank obstruction is the only obstruction
> For affine Σ-protocols over `ZMod q`, failure of unique extraction from two accepting transcripts occurs iff the induced witness-response linear map has nontrivial kernel or the challenge difference vanishes.

**Test:** Randomly generate small matrices over `ZMod q`; compare:
- success/failure of the implemented extractor,
- injectivity / determinant / kernel computation,
- existence of distinct witnesses producing identical transcript differences.

A counterexample would immediately refute the conjecture.

---

## Deliverables (MANDATORY)

You must produce **all** of the following:

1. **Lean file(s)** containing:
   - the new abstraction(s),
   - at least 3 deep theorems,
   - at least one cross-domain theorem,
   - at least one explicit extractor algorithm.

2. **`FUTURE_DIRECTIONS.md`** with **3–5 falsifiable scientific hypotheses**, each with:
   - precise conjecture,
   - why it matters,
   - explicit computational or formal test that could refute it.

3. **`RESEARCH_PAPER.md`** as a standalone scientific paper:
   - problem statement,
   - theorem statements,
   - proof ideas,
   - algorithmic content,
   - why universal affine extraction changes formal cryptography,
   - limitations and next questions.

4. **`ARTICLE.md`** in Scientific American style:
   - explain to a broad audience how “rewinding a proof” becomes “solving an equation,”
   - why this matters for trustworthy cryptography,
   - what new scientific territory it opens.

5. **A verified algorithm / computational method**
   - not just theorem statements,
   - implement the extractor as a function,
   - prove correctness for at least one nontrivial protocol family.

6. **`demo.py`**
   - generate small examples over `ZMod q`-like finite fields,
   - construct pairs of accepting transcripts,
   - run the extractor,
   - display recovered witnesses or obstruction certificates interactively.

---

## Standard of Ambition

Do not settle for “Schnorr generalized to one more protocol.” The real target is a **formal meta-theorem**: extraction is a theorem of affine algebra. If you succeed, you will have created a reusable bridge from cryptographic proof systems to finite-field linear algebra, and that is the kind of result that changes how whole families of protocols get formalized.

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

Research domain: Algebra
Research mode: prove
