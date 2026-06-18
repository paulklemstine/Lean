## Assignment: Low-rank attack

**Mode:** `prove`

Prove a genuinely new theorem that turns tropical low-rank structure into a formal attack surface on tropical matrix powers. The goal is not merely to restate factorization folklore, but to extract a mathematically precise mechanism by which a hidden exponent `a` in `G^a` becomes recoverable, or at least sharply constrained, when `G` has tropical rank strictly smaller than ambient dimension.

You should aim to formalize a theorem that says: **low tropical rank forces all tropical powers of `G` to evolve inside an `r`-dimensional factor space, so the sequence `G, G^2, G^3, ...` is controlled by a smaller tropical endomorphism, reducing exponent recovery to a lower-dimensional problem.** This is the beginning of a tropical analogue of low-rank cryptanalysis.

---

## Research Direction

If `G` has tropical rank `r < n`, then `G` admits a tropical factorization through `r` dimensions:
\[
G = U \otimes V,
\]
with `U : n × r`, `V : r × n`, where `⊗` is tropical matrix multiplication. Then
\[
G^2 = U \otimes (V \otimes U) \otimes V,\qquad
G^a = U \otimes (V \otimes U)^{a-1} \otimes V \quad (a \ge 1).
\]
Thus the full `n × n` power sequence is governed by the smaller `r × r` matrix
\[
H := V \otimes U.
\]
This is the core theorem to formalize and exploit.

The breakthrough is not the factorization alone. The breakthrough is to prove that **every power of `G` is funneled through a compressed tropical core `H`**, and therefore any hidden exponent problem on `G^a` descends to a smaller hidden exponent problem on `H^{a-1}`. This creates a rigorous low-rank attack principle.

---

## Precise Theorem Targets

You should define tropical matrix multiplication concretely over a usable carrier such as `WithTop ℤ` or `ℝ ∪ {∞}` depending on what is most feasible with Mathlib. Use `Matrix (Fin n) (Fin m) α`.

### Theorem 1: Power compression through a tropical factorization
For `a ≥ 1`, if `G = U ⊗ V`, then
\[
G^a = U \otimes (V \otimes U)^{a-1} \otimes V.
\]

### Suggested Lean 4 type signature
```lean
theorem tropical_pow_factorization
  {n r : ℕ}
  (U : Matrix (Fin n) (Fin r) (WithTop ℤ))
  (V : Matrix (Fin r) (Fin n) (WithTop ℤ))
  (a : ℕ) (ha : 1 ≤ a) :
  tropical_mat_pow (tropical_mat_mul U V) a =
    tropical_mat_mul U
      (tropical_mat_mul (tropical_mat_pow (tropical_mat_mul V U) (a - 1)) V)
```
If associativity is encoded differently, an equivalent parenthesization is acceptable:
```lean
theorem tropical_pow_factorization'
  {n r : ℕ}
  (U : Matrix (Fin n) (Fin r) (WithTop ℤ))
  (V : Matrix (Fin r) (Fin n) (WithTop ℤ))
  (a : ℕ) (ha : 1 ≤ a) :
  tropical_mat_pow (tropical_mat_mul U V) a =
    tropical_mat_mul
      (tropical_mat_mul U (tropical_mat_pow (tropical_mat_mul V U) (a - 1)))
      V
```

### Theorem 2: Low-rank reduction principle
If `G` has tropical rank at most `r`, and if your catalog theorem gives a decomposition witness, then there exist `U, V` such that all powers factor through `r`:
\[
\exists U,V,\ \forall a \ge 1,\ G^a = U \otimes H^{a-1} \otimes V,\quad H = V \otimes U.
\]

### Suggested Lean 4 type signature
```lean
theorem low_rank_power_reduction
  {n r : ℕ}
  (G : Matrix (Fin n) (Fin n) (WithTop ℤ))
  (hr : tropical_rank G ≤ r) :
  ∃ (U : Matrix (Fin n) (Fin r) (WithTop ℤ))
    (V : Matrix (Fin r) (Fin n) (WithTop ℤ)),
    tropical_mat_mul U V = G ∧
    ∀ a : ℕ, 1 ≤ a →
      tropical_mat_pow G a =
        tropical_mat_mul
          (tropical_mat_mul U (tropical_mat_pow (tropical_mat_mul V U) (a - 1)))
          V
```
If your existing theorem `tropical_factoring_decomposition` gives hypotheses in a different shape, adapt the statement to the exact output of that theorem rather than forcing an artificial interface.

### Theorem 3: Equality of powers reduces to equality in the core
Under a mild nondegeneracy hypothesis on `U,V` ensuring left/right multiplication preserves distinguishability, prove:
\[
H^{a-1} = H^{b-1} \implies G^a = G^b.
\]
More ambitiously, prove a partial converse under a separation hypothesis:
\[
G^a = G^b \implies H^{a-1} = H^{b-1}.
\]
This is the real cryptanalytic content: periodicity or collisions in `G^a` are inherited from the smaller core.

### Suggested Lean target
```lean
theorem core_power_collision_implies_full_collision
  {n r : ℕ}
  (U : Matrix (Fin n) (Fin r) (WithTop ℤ))
  (V : Matrix (Fin r) (Fin n) (WithTop ℤ))
  {a b : ℕ} (ha : 1 ≤ a) (hb : 1 ≤ b)
  (hcore :
    tropical_mat_pow (tropical_mat_mul V U) (a - 1) =
    tropical_mat_pow (tropical_mat_mul V U) (b - 1)) :
  tropical_mat_pow (tropical_mat_mul U V) a =
  tropical_mat_pow (tropical_mat_mul U V) b
```

A very strong follow-up theorem, if feasible, is eventual periodicity transfer:
```lean
theorem eventual_periodicity_of_low_rank_powers
  {n r : ℕ}
  (U : Matrix (Fin n) (Fin r) (WithTop ℤ))
  (V : Matrix (Fin r) (Fin n) (WithTop ℤ)) :
  ∃ N p : ℕ, 0 < p ∧
    ∀ a ≥ N,
      tropical_mat_pow (tropical_mat_mul U V) (a + p) =
      tropical_mat_pow (tropical_mat_mul U V) a
```
This would be a major bridge between tropical algebra, automata-style semigroup finiteness, and cryptanalysis.

---

## Why this is a breakthrough

This would formalize a **dimension-collapse law for tropical dynamics**. In ordinary linear algebra, low rank constrains image dimension. In tropical algebra, low rank is subtler and tied to combinatorial geometry, min-plus convexity, and shortest-path structure. A theorem showing that all powers of a low-rank tropical matrix are governed by a smaller internal core would open:

- **tropical cryptanalysis**: hidden exponent attacks in tropical semigroup protocols,
- **min-plus control theory**: reduced-order models for event systems,
- **graph algorithms**: compressed repeated shortest-path propagation,
- **idempotent dynamics**: finite-state structure of tropical matrix semigroups,
- **complexity theory**: parameterized algorithms in tropical rank `r`.

This is not an incremental rank lemma. It is a structural reduction principle with direct algorithmic meaning.

---

## Existing Verified Theorems to Build On

Use the catalog aggressively, but do not merely cite it—extract the right formal witness and transport it into a theorem about powers.

1. `tropical_rank_bound`
   - file: `Tropical/Core/TropicalDeepResearch.lean`
   - Likely useful for obtaining ambient inequalities and ensuring `r ≤ n`-style sanity conditions.

2. `tropical_and_bound`
   - file: `Tropical/Oracles/OracleApplicationsFrontier.lean`
   - Probably not central algebraically, but if it packages tropical inequalities or oracle-style bounds, it may help formulate distinguishability or attack bounds.

3. `tropical_rank_le_dim`
   - file: `Tropical/Core/HashInversion.lean`
   - Use this to control the permissible compressed dimension and avoid degenerate index issues.

4. `energy_has_tropical_limit`
   - file: `Tropical/Core/TropicalAdvancedTheory.lean`
   - This suggests a bridge to asymptotic growth of powers. If you can define an “energy” or cycle-mean observable on `G^a`, low-rank compression may imply that asymptotics are already visible in `H`.

5. `tropical_factoring_decomposition`
   - file: `Tropical/Core/TropicalFactoring.lean`
   - This is the key build block. Inspect its exact statement and use it to produce the witnesses `U,V`. Your theorem should be a nontrivial corollary that upgrades one-shot factorization into **all-power control**.

---

## Proof Strategy Architecture

### Strategy A: Direct inductive compression via associativity
This is the most promising path.

1. **Define/locate tropical matrix multiplication and power**  
   Ensure you have an associative multiplication:
   \[
   (U \otimes V)\otimes (U \otimes V)=U\otimes (V\otimes U)\otimes V.
   \]
   Prove a reassociation lemma specialized to rectangular matrices.

2. **Induct on `a`**  
   Base case `a = 1` is immediate from `G = U ⊗ V`.  
   Inductive step:
   \[
   G^{a+1} = G^a \otimes G
   = U \otimes H^{a-1} \otimes V \otimes U \otimes V
   = U \otimes H^a \otimes V.
   \]

3. **Package into an existential low-rank theorem**  
   Use `tropical_factoring_decomposition` to extract `U,V` from rank assumptions, then instantiate the inductive theorem.

Why this is best: it is structurally clean, requires no deep spectral theory, and directly exposes the compressed core `H = V ⊗ U`.

---

### Strategy B: Semigroup morphism / sandwich factorization viewpoint
This is conceptually elegant and may yield stronger corollaries.

1. Define maps
   \[
   \Phi(X)=U\otimes X\otimes V,\qquad H=V\otimes U.
   \]
2. Prove by induction that
   \[
   \Phi(H^{a-1})=(U\otimes V)^a.
   \]
3. Show that power collisions, periodicity, and eventual stabilization in the small semigroup generated by `H` transfer to the large semigroup generated by `G`.

Why this is valuable: it naturally produces collision-transfer and periodicity theorems, and suggests categorical interpretations.

---

### Strategy C: Weighted digraph / shortest-path interpretation
Use this if algebraic proof gets stuck or for ARTICLE-level exposition.

1. Interpret `G` as a weighted directed graph and `G^a` as optimal path weights of length `a`.
2. Interpret `G = U ⊗ V` as forcing every one-step transition to pass through `r` latent states.
3. Then every length-`a` path in `G` corresponds to a length-`a-1` path in the latent graph `H = V ⊗ U`, sandwiched by entry/exit costs from `U,V`.

Why it matters: this yields intuitive cryptanalytic and algorithmic meaning and may guide formal lemmas about path decomposition.

---

## Cross-domain connections you must exploit

### 1. Cryptography
This is a tropical analogue of a **low-rank hidden-structure attack**. If a public key reveals `G^a` and `G` has low tropical rank, then exponent recovery may be reduced to a smaller `r × r` hidden-power problem. Keywords:
- hidden exponent problem
- semigroup cryptanalysis
- low-rank attack
- key recovery via compression

### 2. Graph theory / shortest paths
Tropical matrix multiplication is min-plus path composition. Low rank means all transitions factor through `r` latent hubs. This is a structural theorem about **compressed path dynamics**.

### 3. Control theory / max-plus systems
In discrete event systems, powers of tropical matrices encode system evolution. Low-rank reduction gives a rigorous reduced-order model.

### 4. Complexity theory
If powers of `n × n` matrices reduce to powers of an `r × r` core, then repeated powering may be fixed-parameter tractable in tropical rank `r`. This opens a parameterized complexity program:
- FPT in tropical rank
- kernelization by factor core
- compressed semigroup dynamics

### 5. Asymptotic/spectral tropical analysis
Use `energy_has_tropical_limit` as inspiration: if growth rates of `G^a` admit tropical limits, low-rank compression suggests those limits are governed by `H`. This could lead to tropical Lyapunov exponents or cycle-mean reduction theorems.

---

## Concrete formalization guidance

You should introduce, if absent:

- `tropical_mat_mul`
- `tropical_mat_pow`
- rectangular associativity lemmas
- sandwich lemmas of the form
  ```lean
  tropical_mat_mul (tropical_mat_mul A B) C =
    tropical_mat_mul A (tropical_mat_mul B C)
  ```
  with dimension-safe indices.

If Mathlib’s ordinary `Matrix.mul` over a tropical semiring is easier than custom definitions, prefer that. The deepest theorem is independent of notation. If you can instantiate a min-plus semiring structure on `WithTop ℤ` or `ℝ≥∞`, then the theorem may collapse to a general semiring lemma:
```lean
theorem mul_pow_sandwich
  {α : Type*} [Semiring α]
  {n r : ℕ}
  (U : Matrix (Fin n) (Fin r) α)
  (V : Matrix (Fin r) (Fin n) α)
  (a : ℕ) (ha : 1 ≤ a) :
  (U ⬝ V)^a = U ⬝ (V ⬝ U)^(a - 1) ⬝ V
```
Then specialize to tropical semirings. If this general theorem is formalizable, it is even stronger and more elegant: the tropical attack becomes an instance of a universal sandwich-power identity.

This may be the most powerful abstraction available.

---

## High-value theorem variants

If the main theorem succeeds, push toward one of these:

1. **Rank-preservation under powers**
   \[
   \operatorname{trk}(G^a) \le r
   \]
   for all `a ≥ 1`.

   Lean target:
   ```lean
   theorem tropical_rank_pow_le
     {n r : ℕ}
     (G : Matrix (Fin n) (Fin n) (WithTop ℤ))
     (hr : tropical_rank G ≤ r) :
     ∀ a : ℕ, tropical_rank (tropical_mat_pow G a) ≤ r
   ```

2. **Core-periodicity implies full-periodicity**
   If `H^(k+p) = H^k`, then `G^(k+1+p) = G^(k+1)`.

3. **Exponent search reduction**
   Formalize a statement of the form: if `G^a = P`, then solving for `a` reduces to solving
   \[
   U \otimes H^{a-1} \otimes V = P.
   \]
   Even if algorithm extraction is premature, a theorem asserting equivalence of witness existence is valuable.

4. **Asymptotic growth reduction**
   Show that any tropical growth invariant of `G^a` defined through entries or energies is controlled by `H`.

---

## Suggested work plan

1. Inspect `tropical_factoring_decomposition` and determine its exact witness format.
2. Prove the pure algebraic sandwich-power identity in the most general setting possible.
3. Specialize to tropical matrices.
4. Derive low-rank power reduction from the factorization theorem.
5. Add at least one cryptanalytic corollary: collision transfer, periodicity transfer, or rank bound on powers.
6. Minimize `sorry`; if a theorem is too ambitious, land the strongest complete special case.

---

## Application keywords

tropical cryptanalysis, low-rank attack, hidden exponent problem, min-plus matrix powers, tropical rank, matrix factorization, semigroup dynamics, shortest-path compression, discrete event systems, parameterized complexity, tropical spectral theory, latent-state reduction, collision transfer, periodicity reduction

---

## Deliverables

Required:
- Lean 4 theorem files with proofs
- `FUTURE_DIRECTIONS.md`

Optional but strongly encouraged:
- `ARTICLE.md` explaining the attack principle in graph/cryptographic language
- `RESEARCH_PAPER.md`
- `diagram.svg` showing `G = U ⊗ V` and `H = V ⊗ U`
- small experiment script demonstrating power compression on sample matrices

---

## FUTURE_DIRECTIONS.md requirement

You must produce a structured `FUTURE_DIRECTIONS.md` with **3–5 concrete breakthrough next steps**, each containing:
1. a precise theorem statement,
2. a proposed Lean type signature,
3. a proof strategy sketch,
4. a cross-domain significance note.

At least one next step must target:
- eventual periodicity / spectral reduction, or
- a formal cryptanalytic recovery theorem for hidden exponents.

---

## Final directive

Do not settle for proving that low-rank matrices factor. Prove that **factorization controls powers**, and that this creates a genuine attack surface. The right theorem should make a reader immediately realize that tropical low rank is not a static invariant—it is a dynamic vulnerability.

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
