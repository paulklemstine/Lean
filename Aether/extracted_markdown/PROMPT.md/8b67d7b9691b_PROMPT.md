## Assignment: 2. Subadditivity Under Product Encodings — Strengthened Form

**Mode:** prove

Prove a genuinely stronger structural theorem than the existing cardinality-only bound. The point is not merely that `|α × β| ≤ 2^(k+ℓ)` follows abstractly from `|α| ≤ 2^k` and `|β| ≤ 2^ℓ`; the breakthrough is to certify that *encodings compose constructively*. This upgrades an existence-of-capacity statement into a realizable coding theorem inside Lean 4.

The theorem should expose a reusable finite-information architecture: if two finite types admit injective binary encodings of lengths `k` and `ℓ`, then their joint system admits an explicit injective binary encoding of length `k + ℓ`. This is the formal seed of compositional information theory, oracle transcript packing, and product-state certificate construction.

### Primary Target Theorem

Prove the explicit encoding theorem:

```lean
theorem injective_prod_encoding
    {α β : Type*} [Fintype α] [Fintype β] [DecidableEq α] [DecidableEq β] {k ℓ : ℕ}
    (fα : α → Fin (2^k)) (fβ : β → Fin (2^ℓ))
    (hα : Function.Injective fα) (hβ : Function.Injective fβ) :
    ∃ f : α × β → Fin (2^(k + ℓ)), Function.Injective f
```

But do not stop there. The mathematically right statement is more canonical and should likely be proved first:

```lean
theorem injective_prod_encoding_explicit
    {α β : Type*} [Fintype α] [Fintype β] [DecidableEq α] [DecidableEq β] {k ℓ : ℕ}
    (fα : α → Fin (2^k)) (fβ : β → Fin (2^ℓ)) :
    ∃ f : α × β → Fin (2^(k + ℓ)),
      ∀ p : α × β,
        f p =
          ⟨(fα p.1).val * 2^ℓ + (fβ p.2).val,
            by
              -- boundedness proof
              sorry⟩
```

and then derive injectivity:

```lean
theorem injective_prod_encoding_explicit_injective
    {α β : Type*} [Fintype α] [Fintype β] [DecidableEq α] [DecidableEq β] {k ℓ : ℕ}
    (fα : α → Fin (2^k)) (fβ : β → Fin (2^ℓ))
    (hα : Function.Injective fα) (hβ : Function.Injective fβ) :
    Function.Injective
      (fun p : α × β =>
        ⟨(fα p.1).val * 2^ℓ + (fβ p.2).val,
          by
            -- boundedness proof
            sorry⟩ : Fin (2^(k + ℓ)))
```

From these, recover the existential theorem exactly as requested.

### Stronger Canonical Generalization

If the arithmetic cooperates cleanly, the truly reusable theorem is not base-2-specific. Prove the radix-generic version:

```lean
theorem injective_prod_encoding_base
    {α β : Type*} [Fintype α] [Fintype β] [DecidableEq α] [DecidableEq β]
    {B k ℓ : ℕ} (hB : 1 ≤ B)
    (fα : α → Fin (B^k)) (fβ : β → Fin (B^ℓ))
    (hα : Function.Injective fα) (hβ : Function.Injective fβ) :
    ∃ f : α × β → Fin (B^(k + ℓ)), Function.Injective f
```

This is a field-opening abstraction: it turns a binary theorem into a theorem about positional numeral systems, finite state compression, and mixed-radix coding. The binary theorem becomes the corollary `B = 2`.

### Why This Is a Breakthrough

`entropyBound_prod_of_entropyBound` only says the box is large enough. You should now prove how to *pack* the product into the box. That distinction is the difference between:
- counting arguments and executable encodings,
- nonconstructive entropy bounds and actual code synthesis,
- abstract subadditivity and compositional finite-information protocols.

This theorem becomes infrastructure for:
- oracle complexity transcript composition,
- product certificates in proof complexity,
- joint state encodings in adversarial prediction,
- finite probabilistic couplings and channel products,
- eventual formal Shannon-style coding arguments.

### Precise Lean Architecture

A clean implementation path is to define the encoding function directly:

```lean
def prodEncoding
    {α β : Type*} {k ℓ : ℕ}
    (fα : α → Fin (2^k)) (fβ : β → Fin (2^ℓ)) :
    α × β → Fin (2^(k + ℓ)) :=
  fun p =>
    ⟨(fα p.1).val * 2^ℓ + (fβ p.2).val,
      by
        -- use (fα p.1).is_lt and (fβ p.2).is_lt
        -- prove:
        --   (fα p.1).val * 2^ℓ + (fβ p.2).val < 2^k * 2^ℓ
        -- then rewrite with Nat.pow_add
        sorry⟩
```

Then prove:

```lean
theorem prodEncoding_injective
    {α β : Type*} [DecidableEq α] [DecidableEq β] {k ℓ : ℕ}
    (fα : α → Fin (2^k)) (fβ : β → Fin (2^ℓ))
    (hα : Function.Injective fα) (hβ : Function.Injective fβ) :
    Function.Injective (prodEncoding fα fβ)
```

This should be the engine theorem from which the existential target is trivial.

### Building Blocks From the Catalog

Use the existing theorems as conceptual scaffolding, not decoration:

1. `entropyBound_prod_of_entropyBound`  
   This gives the cardinality-level subadditivity and confirms you are proving the constructive strengthening of an already verified information bound. Your theorem should be presented as the *realizer* of that existential size argument.

2. `product_encoding_injective`  
   This is likely your closest structural analogue. Mine it for the exact style of proof of injectivity for paired encodings into a single code space. Even if its codomain is not `Fin (2^(k+ℓ))`, the decomposition argument may transfer directly.

3. `query_strategy_output_bound`  
   This suggests an oracle-complexity interpretation: finite output alphabets from independent query blocks can be packed into one transcript alphabet of additive bitlength. Use this as motivation for follow-on lemmas.

4. `info_lower_bound`  
   This can contextualize the theorem as a coding upper bound paired with a logarithmic lower bound. After the constructive theorem, one can prove tightness statements of the form “joint code length is at most additive and cannot in general be made smaller than logarithmic cardinality.”

### Proof Strategy A: Direct radix decomposition via division and modulus
This is the most promising and should likely be the main proof.

Step 1:
Define
```lean
f (a,b) = (fα a).val * 2^ℓ + (fβ b).val
```
and prove boundedness:
```lean
(fα a).val < 2^k, (fβ b).val < 2^ℓ
⊢ (fα a).val * 2^ℓ + (fβ b).val < 2^k * 2^ℓ = 2^(k+ℓ)
```
Use `Nat.mul_lt_mul_of_pos_right`, `Nat.add_lt_add_left`, and `Nat.pow_add`.

Step 2:
For injectivity, assume
```lean
(fα a₁).val * 2^ℓ + (fβ b₁).val =
(fα a₂).val * 2^ℓ + (fβ b₂).val
```
with both remainders `< 2^ℓ`. Extract equality of remainders by taking `% 2^ℓ`, and equality of quotients by taking `/ 2^ℓ`.

Step 3:
Convert equality of `Fin` values back to equality in `α` and `β` using `hα`, `hβ`.

Why this is strongest:
It proves the theorem in the mathematically canonical way and yields the generic base-`B` version almost for free.

### Proof Strategy B: Factor through `Fin (2^k) × Fin (2^ℓ)` and then pack
This is elegant if the library already has suitable finite product encodings.

Step 1:
Define the injective map
```lean
α × β → Fin (2^k) × Fin (2^ℓ)
```
by `(a,b) ↦ (fα a, fβ b)`.

Step 2:
Construct an injective packing map
```lean
Fin (2^k) × Fin (2^ℓ) → Fin (2^(k+ℓ))
```
using either an existing theorem analogous to `product_encoding_injective` or a dedicated lemma:
```lean
theorem fin_pair_pack_injective {m n : ℕ} :
  Function.Injective (fun p : Fin m × Fin n => ...)
```

Step 3:
Compose injective maps.

Why this is valuable:
It modularizes the theorem into a generic “packing finite rectangles into a single interval” lemma, reusable far beyond this one statement.

### Proof Strategy C: Use equivalences/cardinality and then refine to explicit code
This is least direct but may help if arithmetic on `Fin` becomes painful.

Step 1:
Use finite cardinality machinery to show
```lean
Fintype.card (α × β) ≤ 2^(k+ℓ)
```
from the injective hypotheses and existing entropy/cardinality lemmas.

Step 2:
Invoke a generic theorem that any finite type of cardinality at most `n` injects into `Fin n`.

Step 3:
After obtaining the existential theorem, separately prove that the explicit mixed-radix encoding coincides with one such injection or is injective on its own.

Why this is weaker:
It gets the theorem, but not the intended computational content. Use only as fallback.

### Key Arithmetic Lemmas You May Need to Isolate

It may be worth proving the following helper lemmas first:

```lean
lemma fin_mul_add_lt_pow_add
    {k ℓ a b : ℕ}
    (ha : a < 2^k) (hb : b < 2^ℓ) :
    a * 2^ℓ + b < 2^(k + ℓ)
```

```lean
lemma mixed_radix_eq_iff
    {m a₁ a₂ b₁ b₂ : ℕ}
    (hb₁ : b₁ < m) (hb₂ : b₂ < m)
    (h : a₁ * m + b₁ = a₂ * m + b₂) :
    a₁ = a₂ ∧ b₁ = b₂
```

and in the binary-specialized form:

```lean
lemma binary_block_concat_injective
    {k ℓ : ℕ} :
    Function.Injective
      (fun p : Fin (2^k) × Fin (2^ℓ) =>
        ⟨p.1.val * 2^ℓ + p.2.val, by sorry⟩ : Fin (2^(k+ℓ)))
```

These helper lemmas would become a miniature library of finite mixed-radix arithmetic.

### Cross-Domain Connections You Should Make Explicit

This theorem is not “just finite arithmetic.” It is a bridge result.

- **Information theory:** additive code length for joint encodings; precursor to subadditivity of description complexity.
- **Oracle complexity:** independent query transcripts can be concatenated into a single bounded transcript alphabet.
- **Proof complexity / certificates:** product witnesses can be serialized without superadditive blowup.
- **Tropical/combinatorial geometry:** mixed-radix packing mirrors coordinate chart flattening and combinatorial encoding of product cells.
- **Probability / channels:** finite product output alphabets of independent channels admit canonical joint encodings.
- **Learning theory:** paired hypotheses / state-label products can be encoded with additive bit budget.

The surprising scientific-fiction angle is this: formalizing explicit product encodings is the tiny finite combinatorial core behind composition laws across information-processing systems. Once certified in Lean, it can propagate into entropy, complexity, coding, and protocol semantics.

### Suggested Follow-On Theorems

If the main theorem lands cleanly, immediately push one or more of these:

1. **n-ary iterated product encoding**
```lean
theorem injective_list_prod_encoding
    {ι : Type*} [Fintype ι] [DecidableEq ι]
    (κ : ι → Type*) [∀ i, Fintype (κ i)] [∀ i, DecidableEq (κ i)]
    (bits : ι → ℕ)
    (enc : ∀ i, κ i → Fin (2^(bits i)))
    (henc : ∀ i, Function.Injective (enc i)) :
    ∃ f : ((i : ι) → κ i) → Fin (2^(∑ i, bits i)), Function.Injective f
```

2. **Generic finite rectangle packing**
```lean
theorem fin_prod_injective_to_fin_mul
    {m n : ℕ} :
    ∃ f : Fin m × Fin n → Fin (m * n), Function.Injective f
```

3. **Cardinality-to-explicit-encoding upgrade**
A theorem saying any finite type with cardinality bound `≤ 2^k` admits an explicit injection into `Fin (2^k)`.

4. **Transcript composition theorem**
Use `query_strategy_output_bound` to derive an additive bound on the bitlength of composed query strategies.

### Application Keywords

`information-theory`, `finite-coding`, `mixed-radix`, `subadditivity`, `oracle-complexity`, `proof-certificates`, `transcript-compression`, `product-types`, `constructive-entropy`, `formal-Shannon-theory`

### Deliverables

1. The exact theorem `injective_prod_encoding`.
2. Preferably also the stronger explicit definition theorem `prodEncoding` and its injectivity lemma.
3. If feasible, the radix-generic version `injective_prod_encoding_base`.
4. Minimize `sorry`, especially in the arithmetic lemmas.
5. Produce a `FUTURE_DIRECTIONS.md` with 3–5 concrete next steps at breakthrough level, such as n-ary encodings, explicit channel products, or formal prefix-free coding infrastructure.

This is the moment to turn entropy bounds into executable structure. Prove not just that the box is big enough, but that we know exactly how to place every pair inside it.

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

Research domain: Logic
Research mode: prove
