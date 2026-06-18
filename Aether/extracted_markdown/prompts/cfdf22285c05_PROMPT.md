## Assignment: Tropical Quadratic Sieve: Min-Plus Factoring Algorithm

Mode: **discover → prove → counterexample-if-needed**

This direction is audacious, but the literal headline claim as stated — “tropical min-plus matrix multiplication yields a subexponential factoring algorithm matching classical quadratic sieve complexity” — is almost certainly too strong if interpreted as a fully formalized end-to-end integer factoring theorem inside current Lean/Mathlib infrastructure. You should therefore attack the idea at the level where genuine mathematics can be extracted and certified:

1. **formalize the tropicalization of the sieve scoring step**,  
2. **prove exact equivalence theorems between classical additive valuation accumulation and min-plus / idempotent aggregation**, and  
3. **derive complexity transfer theorems for the tropicalized sieve kernel**,  
4. while being intellectually honest about what remains unproved for full factoring.

The breakthrough is not “we rephrase QS in strange notation.” The breakthrough is to isolate a **tropical semiring skeleton of relation collection**, prove that smoothness detection and candidate ranking are expressible as min-plus linear algebra, and thereby open a new field: **idempotent algorithmic number theory**. If successful, this creates a rigorous bridge between tropical geometry, semiring algorithms, cryptanalytic sieving, shortest-path style dynamic programming, and hardware-accelerated min-plus computation.

### Core theorem targets

You should define a mathematically honest tropical quadratic-sieve kernel and prove theorems about it. Here is the right target.

Let `N : ℕ` be odd composite, let `B : ℕ` be a factor base bound, let `FB` be the finite set of primes `p ≤ B` with `(N | p) = 1` in the usual quadratic-sieve sense, and let
`Q_N(x) = x^2 - N`.
For each `x` in a finite sieve interval `I`, define the **valuation score vector**
`v_x : FB → ℕ∞` by
- `v_x(p) = padicValNat p (Q_N x)` if `p ∣ Q_N(x)`,
- and `∞` or a large penalty if not.

Then define the **tropical deficiency score**
\[
\delta_B(x) := \bigoplus_{p \in FB} w_p \odot v_x(p),
\]
where in min-plus notation `⊕ = min`, `⊗ = (+)`, and `w_p` is a prime-dependent weight, ideally `log p` or an integer surrogate such as `Nat.log p` / a discrete weight.

The real theorem is not that this alone factors `N`; the theorem is that this tropical score exactly reproduces the ranking criterion used by sieve heuristics.

### Precise theorem statement candidates

#### Theorem A: Tropical valuation aggregation equals additive sieve scoring
For a suitable discrete weight function `w : FB → ℕ`, prove that the tropical matrix product of the valuation incidence matrix with the weight vector computes the same candidate score as classical additive accumulation over the factor base.

A possible Lean-facing statement:

```lean
theorem tropical_sieve_score_eq_classical
  {ι : Type} [Fintype ι] [DecidableEq ι]
  (A : ι → ℕ) (w : ι → ℕ) :
  (Finset.univ.inf fun i => (A i + w i)) =
  sInf ((Finset.univ.image fun i => A i + w i) : Set ℕ)
```

This is too primitive alone, but it is the algebraic kernel you can build from.

A more relevant matrix version:

```lean
theorem minPlus_mul_vec_entry
  {m n : Type} [Fintype m] [Fintype n] [DecidableEq m] [DecidableEq n]
  (M : Matrix m n ℕ) (w : n → ℕ) (i : m) :
  ((fun i => Finset.univ.inf fun j => M i j + w j) i)
    = Finset.univ.inf (fun j => M i j + w j)
```

Then specialize `M i j` to a deficiency or valuation penalty matrix attached to `Q_N(x_i)` and factor-base prime `p_j`.

#### Theorem B: Tropical smoothness certificate is exact for fully supported relations
Define a relation to be **B-supported** if every prime divisor of `Q_N(x)` lies in the factor base. Prove that for such `x`, the tropical score recovers the exact weighted logarithmic size of `Q_N(x)` from the valuation vector.

Mathematically:
\[
Q_N(x)\ \text{is } B\text{-supported} \implies
\sum_{p \in FB} v_p(Q_N(x)) \log p = \log |Q_N(x)|.
\]

Since Lean will prefer exact arithmetic, replace logs by weighted sums over prime powers or use `Nat.factorization`. A robust exact theorem is:

```lean
theorem factorization_weight_sum_eq
  (n : ℕ) (hn : n ≠ 0)
  (S : Finset ℕ)
  (hS : ∀ p, p ∈ n.factorization.support → p ∈ S) :
  ∑ p in S, n.factorization p * w p
    = ∑ p in n.factorization.support, n.factorization p * w p
```

Then instantiate `w p := Nat.log p` or another monotone weight. This gives a certified “smoothness scoring exactness” theorem.

#### Theorem C: Tropical convolution realizes the sieve update
The sieve step in QS adds `log p` to positions `x` satisfying `Q_N(x) ≡ 0 [ZMOD p^k]`. Tropicalizing, one can interpret candidate extraction as a min-plus convolution over residue classes.

A Lean-amenable finite statement:

```lean
def tropicalConv (f g : ℕ → ℕ) (n : ℕ) : ℕ :=
  Finset.inf' (Finset.Icc 0 n) (by simp) (fun k => f k + g (n - k))

theorem tropicalConv_assoc
  (f g h : ℕ → ℕ) (n : ℕ) :
  tropicalConv (fun m => tropicalConv f g m) h n
    = tropicalConv f (fun m => tropicalConv g h m) n
```

This is a real theorem: associativity of min-plus convolution on finite intervals. It opens the path to viewing sieve accumulation as tropical signal processing.

#### Theorem D: Complexity transfer theorem for tropical sieve kernel
Prove not “factoring is subexponential in Lean” but a conditional complexity preservation result:

If a sieve scoring routine performs `O(R * |FB|)` additive updates classically, then its tropicalized matrix/vector or convolutional form performs `O(R * |FB|)` semiring operations over `ℕ`/`WithTop ℕ`.

A formal statement will be definitional, but useful:

```lean
theorem tropical_sieve_kernel_work_bound
  (R B : ℕ) :
  ∃ C : ℕ, kernelWork R B ≤ C * R * B
```

This needs you to define `kernelWork`. The theorem is modest but foundational: it certifies that tropicalization does not asymptotically destroy the sieve kernel.

### Most promising exact theorem

The best theorem to aim for first is:

```lean
theorem qs_tropical_score_exact_on_smooth
  (N x B : ℕ)
  (hx : x^2 ≥ N)
  (hQ : Q N x ≠ 0)
  (hSmooth : ∀ p ∈ (Q N x).factorization.support, Nat.Prime p ∧ p ≤ B) :
  tropicalScore N B x = classicalWeightScore (Q N x)
```

where
- `Q N x := x^2 - N`,
- `tropicalScore` is defined from the factor-base valuation vector,
- `classicalWeightScore` is the exact factorization-weight sum.

This is a real theorem, nontrivial, and genuinely bridges the sieve heuristic to tropical algebra. It is the theorem that makes the research direction mathematically defensible.

---

## Why this would be a breakthrough

If you prove that the relation-collection core of the quadratic sieve is an instance of min-plus linear algebra, then you have done something much more important than rebranding a known algorithm:

- You identify a **semiring-invariant computational essence** of integer factoring.
- You make cryptanalytic sieving accessible to tools from tropical geometry and shortest-path algorithms.
- You invite new hardware implementations using min-plus accelerators, systolic arrays, and graph semiring engines.
- You create a common formal language for **number theory, optimization, and idempotent analysis**.

This could open:
- tropical cryptanalysis,
- semiring complexity theory for arithmetic algorithms,
- tropical analogues of lattice sieves and NFS relation collection,
- certified cost-preserving program transformations from ring arithmetic to semiring kernels.

Application keywords: **tropical cryptanalysis, idempotent semirings, quadratic sieve, smooth numbers, min-plus convolution, semiring complexity, tropical linear algebra, certified algorithmics, factorization heuristics, cryptographic hardness, hardware acceleration**

---

## Building on the catalog theorems

Use the existing theorems not as decoration but as algebraic primitives.

1. `tropical_add_idempotent`  
   This certifies the idempotent collapse principle. Use it to show repeated evidence accumulation in a tropical score does not overcount once encoded as a min-selection process.

2. `tropical_plus_distributes_over_min`  
   This is central. It is exactly the law needed for pushing weights through minima:
   \[
   a + \min(b,c) = \min(a+b, a+c).
   \]
   Use it to prove:
   - distributivity of weighted deficiency accumulation,
   - correctness of min-plus matrix-vector evaluation,
   - associativity lemmas for tropical convolution.

3. `idempotent_semiring_with_inverses_trivial`  
   This theorem is philosophically crucial: it explains why tropicalization cannot preserve all multiplicative group structure. Use it to justify why the right target is the **sieve scoring / relation collection stage**, not the full ring-theoretic linear algebra stage over `Z/2Z`. In other words, this theorem tells you where tropicalization is mathematically legitimate and where it necessarily collapses information.

That observation itself is profound: **the sieve stage tropicalizes naturally; the parity-solving stage does not.** This is exactly the kind of structural theorem that separates genuine insight from hype.

---

## Proof strategy architecture

### Strategy A: Exact factorization-weight theorem via `Nat.factorization`
This is the most promising route.

1. Define `Q : ℕ → ℕ → ℕ` carefully, probably as a truncated natural version on the domain `x^2 ≥ N`, or switch to `ℤ` for algebraic cleanliness and use `natAbs`.
2. Define the factor-base support and a classical exact weight score using `Nat.factorization`.
3. Define the tropical score as a min-plus / inf-based aggregation over prime-indexed penalties.
4. Prove equality on `B`-smooth inputs by support restriction and factorization support lemmas.

Why this is best:
- Mathlib already knows about prime factorization.
- Exact equalities are more formalizable than asymptotic heuristic smoothness probabilities.
- This yields a certifiable theorem that really captures the QS scoring idea.

### Strategy B: Matrix formulation over `WithTop ℕ` or `ℕ`
Recast the sieve interval as row indices and factor-base primes as column indices.

1. Define a valuation/penalty matrix `M : Matrix X P ℕ`.
2. Define min-plus matrix-vector multiplication entrywise as inf of sums.
3. Show that each row computes the candidate deficiency score for one sieve point.
4. Prove algebraic laws: distributivity, monotonicity, and finite complexity bounds.

Why this matters:
- It turns relation collection into tropical linear algebra.
- It sets up future GPU / accelerator / APSP-style reductions.
- It is a natural bridge to existing Mathlib `Matrix` infrastructure.

This is likely the second theorem after Strategy A.

### Strategy C: Counterexample and structural boundary theorem
If the grand claim starts to overreach, prove a sharp no-go theorem.

Example target:
> There is no faithful tropicalization of the full quadratic sieve preserving both relation collection and parity-linear-algebra solution in an idempotent semiring with multiplicative inverses, except in the trivial semiring.

This would use `idempotent_semiring_with_inverses_trivial`.

Lean-style skeleton:
```lean
theorem no_nontrivial_full_tropical_QS_model
  {S : Type*} [IdempotentSemiring S] [GroupWithZero S] :
  Subsingleton S
```

or a variant matching available typeclasses. If exact typeclasses do not align, formulate an application theorem deriving triviality from the catalog result.

Why this is valuable:
- It tells the field exactly what can and cannot be tropicalized.
- Negative structural theorems are often more revolutionary than forced positive ones.

---

## Cross-domain connections you should explicitly exploit

### 1. Shortest paths / dynamic programming
Min-plus matrix multiplication is the algebra of shortest paths. Your tropical sieve score is a path cost through a prime-support graph. This suggests:
- candidate smoothness as shortest explanation length,
- relation collection as path aggregation,
- tropical convolution as dynamic programming over valuation decompositions.

### 2. Information theory / coding
The tropical score behaves like a minimum description length functional for factorization support. Smooth numbers are those with compressible prime descriptions relative to the factor base. This suggests a future tropical entropy of integer factorization.

### 3. Statistical mechanics
The deficiency score resembles an energy landscape:
- primes are interaction modes,
- valuations are occupancies,
- smooth candidates are low-energy states.
This could eventually connect smoothness heuristics to partition functions.

### 4. Hardware / algorithm engineering
Min-plus kernels map to specialized accelerators. If relation scoring is truly tropical linear algebra, one can imagine:
- systolic tropical sieve engines,
- FPGA min-plus relation collectors,
- graph-semiring cryptanalytic hardware.

### 5. Tropical geometry
The factor-base score defines a piecewise-linear landscape over the sieve interval. Relation collection becomes the search for low tropical height points on a combinatorial hypersurface induced by `x^2 - N`.

These are not decorative metaphors. They indicate actual next theorem families.

---

## Lean 4 formalization targets

Use concrete types aggressively.

### Definitions to introduce
- `Q : ℕ → ℕ → ℕ` or `Qz : ℕ → ℤ → ℤ`
- `factorBase : ℕ → Finset ℕ`
- `valuationVec : ℕ → Finset ℕ → ℕ → ℕ`
- `weightScore : Finset ℕ → (ℕ → ℕ) → ℕ → ℕ`
- `tropicalScore : Finset ℕ → (ℕ → ℕ) → (ℕ → ℕ) → ℕ`
- `tropicalMatVec` for min-plus matrix-vector multiplication
- `tropicalConv`

### Suggested theorem signatures

```lean
def tropicalMatVec
  {m n : Type} [Fintype m] [Fintype n] [DecidableEq n]
  (M : Matrix m n ℕ) (v : n → ℕ) : m → ℕ :=
  fun i => Finset.univ.inf fun j => M i j + v j
```

```lean
theorem tropicalMatVec_mono
  {m n : Type} [Fintype m] [Fintype n] [DecidableEq n]
  {M : Matrix m n ℕ} {v w : n → ℕ}
  (hvw : ∀ j, v j ≤ w j) :
  ∀ i, tropicalMatVec M v i ≤ tropicalMatVec M w i
```

```lean
def classicalWeightScore (n : ℕ) (w : ℕ → ℕ) : ℕ :=
  ∑ p in n.factorization.support, n.factorization p * w p
```

```lean
theorem classicalWeightScore_support_restrict
  (n : ℕ) (hn : n ≠ 0) (S : Finset ℕ) (w : ℕ → ℕ)
  (hS : ∀ p, p ∈ n.factorization.support → p ∈ S) :
  classicalWeightScore n w
    = ∑ p in S, n.factorization p * w p
```

```lean
theorem qs_tropical_score_exact_on_B_smooth
  (n : ℕ) (hn : n ≠ 0) (S : Finset ℕ) (w : ℕ → ℕ)
  (hSmooth : ∀ p, p ∈ n.factorization.support → p ∈ S) :
  tropicalScoreFromFactorization n S w = classicalWeightScore n w
```

```lean
theorem tropicalConv_assoc
  (f g h : ℕ → ℕ) :
  ∀ n, tropicalConv (fun m => tropicalConv f g m) h n
      = tropicalConv f (fun m => tropicalConv g h m) n
```

If `Finset.inf` causes friction on `ℕ`, use `WithTop ℕ` or nonempty interval lemmas with `Finset.inf'`.

---

## What to avoid

Do **not** waste the cycle trying to formalize the full heuristic theorem
\[
\text{QS runs in } \exp((1+o(1))\sqrt{\log N \log\log N})
\]
inside Lean. That is not the right first breakthrough here.

Do **not** pretend that tropical semiring operations literally preserve the full algebraic content of quadratic-sieve linear dependency finding. The catalog already hints this is impossible in nontrivial idempotent settings.

Do **not** settle for a tautology like “min-plus matrix multiplication is associative.” It must be tied to the number-theoretic model.

---

## Strongest possible deliverable for this cycle

A field-opening cycle would produce:

1. A Lean file defining a tropical sieve kernel.
2. A theorem that on `B`-smooth inputs, tropical scoring exactly matches classical factorization-weight scoring.
3. A matrix or convolution theorem showing the sieve update is a min-plus linear operator.
4. A complexity-preservation theorem for the tropical kernel.
5. Optionally, a no-go theorem showing why the parity-solving stage cannot be fully tropicalized in a nontrivial idempotent semiring.

That package is already publishable in spirit: it isolates the tropicalizable core of factoring.

---

## Required team plan

Create a team with explicit roles:

- **Algebra Lead**: formalize idempotent/min-plus algebra lemmas from the catalog.
- **Number Theory Lead**: build `Q_N`, factor-base support, and `Nat.factorization` lemmas.
- **Algorithms Lead**: define tropical convolution/matrix kernels and work bounds.
- **Skeptic / Counterexample Lead**: test whether the full-factoring claim collapses and extract no-go theorems when needed.
- **Integration Lead**: produce coherent Lean APIs and reusable abstractions.

Run experiments on small composite `N` to validate the scoring definitions before proving theorems.

---

## Deliverables

- Lean 4 code with minimized `sorry`
- at least one theorem from the core list fully proved
- one cross-domain bridge theorem or definition
- a candid note on which part of the original headline claim survives formal scrutiny
- `FUTURE_DIRECTIONS.md` with **3–5 concrete breakthrough next steps**, not generic wishes

### FUTURE_DIRECTIONS.md must include items of the following caliber
- Tropical number field sieve relation collection via valuation polyhedra
- Tropical entropy / information content of smooth numbers
- Certified reduction from smoothness scoring to min-plus shortest path
- No-go theorems for semiring-linear dependency extraction in idempotent settings
- Hardware-realizable tropical cryptanalytic kernels with formally verified cost bounds

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
