## Assignment: Eigenvalue attack

**Mode:** prove

Prove a genuinely new theorem connecting tropical spectral theory to exponent leakage in max-plus matrix powers. The central vision is this: if a tropical matrix \(G\) has a uniquely dominant cycle mean \(\lambda\), then the diagonal growth of \(G^n\) is eventually affine in \(n\), and in strongly connected / critical regimes it is exactly affine. This turns tropical eigenvalue computation into a cryptanalytic invariant: the exponent \(a\) in \(G^a\) leaves a linear spectral fingerprint on observable entries.

This is not merely “another tropical matrix fact.” It is a bridge between:
- tropical linear algebra,
- max-plus Perron–Frobenius theory,
- semigroup/exponent attacks,
- algorithmic cryptanalysis,
- and eventually tropical dynamical systems / automata.

If formalized cleanly in Lean, it opens a new program: **spectral cryptanalysis over idempotent semirings**.

---

## Research Direction

Let \(G\) be a tropical matrix (max-plus convention) over a finite index type. The classical Cuninghame-Green phenomenon says that under suitable irreducibility / criticality hypotheses, the tropical eigenvalue \(\lambda\) governs asymptotic power growth, and in favorable cases
\[
(G^n)_{ii} = n \lambda
\]
for all \(i\) (or at least for all critical \(i\), or eventually up to additive constants / periodic terms).

Your mission is to formalize a precise, nontrivial version of this principle in Lean 4 using concrete matrix types, and then extract a theorem showing that if \(G^a\) is known, then \(a\) is constrained by diagonal values and the tropical eigenvalue.

The theorem should not be stated vaguely. State exact hypotheses and exact conclusions.

---

## Primary Target Theorem

A realistic breakthrough target is an **exact affine diagonal law** for rank-one tropical shifts, then a **spectral divisibility / injectivity consequence** for exponents. Start with a formally robust theorem that can be proved now, but whose conceptual payload is large enough to seed future work.

### Theorem A: exact diagonal growth under scalar tropical shift

In max-plus notation, if
\[
G = \lambda \odot I \oplus H
\]
with \(H\) strictly subcritical on the diagonal and spectrally dominated by \(\lambda\), then
\[
(G^n)_{ii} = n\lambda
\]
for all \(n \ge 1\) and all \(i\).

This may need to be instantiated in a simplified concrete form first, e.g. \(G = \lambda + I\) in additive notation.

### Lean 4 type signature target
A first exact formal target, deliberately concrete, could be:

```lean
theorem tropical_diag_pow_scalar_identity
  {n : ℕ} (hn : 0 < n) (λ : ℝ) (i : Fin m) :
  ((Matrix.diagonal fun _ : Fin m => λ) ^ n) i i = (n : ℝ) * λ
```

If matrix multiplication is ordinary and not tropical in the current library, define a dedicated tropical power operation or a max-plus matrix structure first. If necessary, use `WithBot ℝ` instead of `ℝ` to model \(-\infty\).

A stronger and more cryptanalytic target is:

```lean
theorem tropical_pow_diag_recovers_exponent
  {m : ℕ} [NeZero m] (λ : ℝ) (hλ : 0 < λ)
  {a b : ℕ}
  (h :
    ((Matrix.diagonal fun _ : Fin m => λ) ^ a) 0 0 =
    ((Matrix.diagonal fun _ : Fin m => λ) ^ b) 0 0) :
  a = b
```

This theorem says: once \(\lambda>0\), equality of one diagonal entry of tropical powers forces equality of exponents. That is already an “eigenvalue attack” in distilled form.

---

## Ambitious Breakthrough Theorem

The truly field-opening target is the following.

### Theorem B: spectral constraint on exponent from a diagonal observation

Let \(G\) be an irreducible tropical matrix with tropical eigenvalue \(\lambda\). Suppose there exists \(c_i\) such that for some index \(i\),
\[
(G^n)_{ii} = n\lambda + c_i
\quad \text{for all sufficiently large } n.
\]
Then for any observed diagonal value \(d = (G^a)_{ii}\), the exponent \(a\) must satisfy
\[
a = \frac{d-c_i}{\lambda}
\]
whenever \(\lambda \neq 0\) and the right side is a natural number. In particular, if the eventual affine law is exact from time \(1\), then \(a\) is uniquely determined by \(d\).

### Lean 4 type signature target
This can be expressed abstractly as:

```lean
theorem eventual_affine_diag_determines_exponent
  {a : ℕ} {λ c d : ℝ}
  (hλ : λ ≠ 0)
  (hdiag : d = (a : ℝ) * λ + c) :
  a = Nat.floor ((d - c) / λ)
```

This is only the arithmetic shell; the real achievement is to connect it to matrix powers via a formalized tropical diagonal-growth theorem. You may need to split the project:

1. prove eventual/exact affine diagonal growth for a class of tropical matrices,
2. prove arithmetic uniqueness of the exponent from that affine formula.

---

## Stronger Structural Theorem to Aim For

If the library support permits graph-theoretic encoding of cycle means, aim for:

### Theorem C: cycle-mean lower bound on all diagonal powers
For every tropical matrix \(G\) and every index \(i\),
\[
(G^n)_{ii} \ge n\lambda
\]
where \(\lambda\) is the maximum cycle mean.

And under a critical accessibility hypothesis on \(i\),
\[
\exists N,\ \forall n \ge N,\ (G^n)_{ii} = n\lambda + p_i(n)
\]
with \(p_i\) eventually periodic and bounded.

This is a major formalization milestone because it imports max-plus spectral asymptotics into Lean. Even a weakened exact case would be excellent.

A possible signature skeleton:

```lean
theorem tropical_cycle_mean_lower_bound_diag
  (G : Matrix (Fin m) (Fin m) ℝ∞) (n : ℕ) (i : Fin m) :
  (n : ℝ∞) * tropical_eigenvalue G ≤ (tropical_pow G n) i i
```

where `ℝ∞` is whichever tropical coefficient type you define (`WithBot ℝ`, etc.), and `tropical_pow` uses max-plus multiplication.

---

## Why this is a breakthrough

A successful formalization here would establish the first Lean-native pipeline from:
1. tropical spectral invariants,
2. to exact growth laws for semigroup powers,
3. to exponent identifiability / leakage.

That opens:
- tropical cryptanalysis,
- max-plus control/inference,
- identification of hidden time parameters in discrete-event systems,
- and tropical analogues of spectral attacks known in linear algebra over fields.

This is especially potent because tropical eigenvalues are combinatorial (cycle means), so the “attack surface” is algorithmic and graph-theoretic, not merely algebraic.

---

## Existing Verified Theorems to Build On

Use the catalog aggressively, but not superficially.

1. `tropical_mirror_theorem`
   ```lean
   theorem tropical_mirror_theorem (a : ℝ) : max a a = a := max_self a
   ```
   **Use:** this is tiny, but operationally important in normalizing max-expressions in tropical multiplication and powers. It will help simplify self-loop contributions and idempotent joins.

2. `tropical_fundamental_theorem_of_arithmetic`
   **Use:** if this encodes additive/multiplicative decomposition principles, mine it for induction schemes or positivity lemmas on naturals needed in exponent recovery.

3. `tropical_fundamental_theorem`
   **Use:** if this theorem formalizes a surjectivity or structure theorem in a tropical representation setting, inspect whether it provides reusable tropical polynomial / semiring interfaces. Even if the mathematical content differs, the infrastructure may be reusable.

4. `tropical_rayleigh_eigenvalue`
   **Use:** this is the most important bridge. If it gives a variational characterization of tropical eigenvalues, leverage it to derive lower bounds on diagonal entries of powers or to certify that a scalar-diagonal matrix has eigenvalue exactly \(\lambda\).

5. `tropical_eigenvalue_determines_char`
   **Use:** conceptually crucial. It says a tropical eigenvalue can determine character data in a Langlands-flavored setting. Your job is to repurpose that philosophy: **the eigenvalue determines exponent data**. This is a cross-domain bridge theorem waiting to happen.

---

## Precise Lean 4 formalization targets

You should define, if absent:

```lean
def tropicalMul (A B : Matrix (Fin m) (Fin m) (WithBot ℝ)) :
    Matrix (Fin m) (Fin m) (WithBot ℝ) := ...

def tropicalPow (A : Matrix (Fin m) (Fin m) (WithBot ℝ)) (n : ℕ) :
    Matrix (Fin m) (Fin m) (WithBot ℝ) := ...

def tropicalTrace (A : Matrix (Fin m) (Fin m) (WithBot ℝ)) : WithBot ℝ := ...

def cycleMean (G : Matrix (Fin m) (Fin m) (WithBot ℝ)) : WithBot ℝ := ...
```

Then target at least one theorem of the form:

```lean
theorem tropical_pow_diag_scalar
  (λ : ℝ) (n : ℕ) (i : Fin m) :
  tropicalPow (Matrix.diagonal fun _ : Fin m => some λ) n i i = some ((n : ℝ) * λ)
```

and one theorem of the form:

```lean
theorem exponent_recovery_from_tropical_diag
  (λ : ℝ) (hλ : 0 < λ) (a b : ℕ)
  (hobs :
    tropicalPow (Matrix.diagonal fun _ : Fin m => some λ) a 0 0 =
    tropicalPow (Matrix.diagonal fun _ : Fin m => some λ) b 0 0) :
  a = b
```

If `WithBot ℝ` creates friction, first do a finite-valued version over `ℝ` for scalar-diagonal matrices, then generalize.

---

## Proof strategy paths

### Strategy A: exact computation on scalar diagonal tropical matrices
This is the most promising first attack.

1. Define tropical multiplication explicitly for diagonal matrices and prove closure:
   \[
   \operatorname{diag}(\lambda) \otimes \operatorname{diag}(\mu)
   = \operatorname{diag}(\lambda+\mu).
   \]
2. Induct on \(n\) to prove
   \[
   (\operatorname{diag}(\lambda))^n = \operatorname{diag}(n\lambda).
   \]
3. Read off the diagonal entry and prove injectivity in \(n\) when \(\lambda>0\).

**Why most promising:** minimal dependence on deep graph theory, yet already yields a genuine spectral-exponent identifiability theorem. It also creates reusable tropical matrix infrastructure.

### Strategy B: graph-theoretic path semantics
Use the interpretation of \((G^n)_{ij}\) as the maximum weight of a length-\(n\) path from \(i\) to \(j\).

1. Formalize path weights and prove the semantic theorem for tropical powers.
2. Show that diagonal entries correspond to closed walks at \(i\).
3. For scalar-diagonal or critical-cycle matrices, prove the unique optimal closed walk repeats a cycle of mean \(\lambda\), yielding \((G^n)_{ii}=n\lambda\).

**Why powerful:** this scales toward full Cuninghame-Green and Karp-style cycle-mean results, and naturally connects to automata and discrete-event systems.

### Strategy C: variational/eigenvalue route via tropical Rayleigh principle
Exploit `tropical_rayleigh_eigenvalue`.

1. Show scalar diagonal matrices have tropical eigenvalue \(\lambda\).
2. Derive lower and upper bounds on \((G^n)_{ii}\) using repeated application of eigenvalue inequalities.
3. Force equality in the diagonal/scalar case and then use arithmetic monotonicity to recover exponents.

**Why interesting:** this connects your theorem directly to existing catalog spectral results and may produce the cleanest conceptual theorem statement.

**Recommended order:** A first, then B, then C as a conceptual strengthening.

---

## Cross-domain connections you should explicitly exploit

### 1. Cryptanalysis
The theorem should be phrased as an attack primitive:
- observable diagonal entries of \(G^a\),
- computable tropical eigenvalue \(\lambda\),
- infer or constrain \(a\).

This is analogous to spectral leakage in classical linear cryptanalysis, but over idempotent semirings.

### 2. Graph algorithms
Tropical eigenvalues are maximum cycle means. This connects directly to:
- Karp’s algorithm,
- weighted digraphs,
- shortest/longest path dualities,
- and complexity-theoretic attack surfaces.

A future theorem could state that exponent recovery reduces to a cycle-mean computation plus integer arithmetic.

### 3. Discrete-event systems / control
In max-plus systems, powers \(G^n\) encode timing evolution. Your theorem says observed return times reveal hidden iteration count. That is a systems-identification theorem in disguise.

### 4. Langlands / representation analogy
The catalog theorem `tropical_eigenvalue_determines_char` suggests a philosophical bridge:
- in tropical Langlands, eigenvalue determines character;
- here, tropical eigenvalue determines temporal/exponent information.
This is the seed of a general “tropical spectral rigidity” program.

### 5. Automata and formal languages
Max-plus matrix powers encode weighted automata. Diagonal entries count optimal loop weights. Exponent recovery from loop weights suggests a new identification theory for weighted automata.

---

## Concrete theorem list to attempt in order

1. **Infrastructure theorem**
   ```lean
   theorem tropical_diag_mul_tropical_diag ...
   ```
   Diagonal tropical matrices multiply by adding diagonal weights.

2. **Power theorem**
   ```lean
   theorem tropical_diag_pow_scalar_identity ...
   ```
   \(n\)-th tropical power of scalar diagonal matrix has diagonal \(n\lambda\).

3. **Eigenvalue identification theorem**
   ```lean
   theorem tropical_eigenvalue_of_scalar_diag ...
   ```
   The tropical eigenvalue of scalar diagonal matrix is \(\lambda\).

4. **Exponent injectivity theorem**
   ```lean
   theorem tropical_pow_diag_recovers_exponent ...
   ```
   Equality of observed diagonal entries implies equality of exponents when \(\lambda>0\).

5. **Attack corollary**
   ```lean
   theorem exponent_bounded_by_observed_diag ...
   ```
   If \((G^a)_{ii}=d\) and exact affine law holds, then \(a \le \lfloor d/\lambda \rfloor\) or even \(a=d/\lambda\) in exact cases.

6. **Bridge theorem**
   ```lean
   theorem tropical_eigenvalue_determines_exponent_class ...
   ```
   For a class of matrices satisfying exact diagonal law, tropical eigenvalue plus one diagonal observation determines the exponent.

This final theorem would be genuinely new and conceptually strong.

---

## Experimental/formal guidance

Use concrete types:
- `Fin m` for indices,
- `Matrix` for matrices,
- `ℕ`, `ℝ`, or `WithBot ℝ` for weights.

If tropical matrix multiplication is absent from Mathlib, define a dedicated operation rather than fighting existing ring multiplication. Keep the first file self-contained and executable.

If exact Cuninghame-Green is too heavy immediately, prove a **clean exact subclass theorem**:
- scalar diagonal matrices,
- diagonal plus strictly dominated off-diagonal perturbations,
- or matrices with a unique optimal self-loop at every vertex.

That is still nontrivial and already cryptanalytically meaningful.

---

## Application keywords

tropical algebra, max-plus spectral theory, Cuninghame-Green theorem, exponent recovery, cryptanalysis, semigroup attack, weighted digraphs, cycle mean, Karp algorithm, discrete-event systems, weighted automata, tropical Perron–Frobenius, spectral rigidity, idempotent semirings, formal verification, Lean 4, Mathlib

---

## Deliverables

1. Lean 4 code proving at least one exact diagonal-growth theorem and one exponent-recovery corollary.
2. Definitions needed for tropical matrix multiplication/powers if absent.
3. Minimal `sorry` usage; if a deep theorem blocks progress, isolate it cleanly as a named conjectural lemma.
4. A structured `FUTURE_DIRECTIONS.md` containing **3–5 concrete next theorems**, each with:
   - precise statement,
   - proof strategy,
   - cross-domain connection,
   - why it would be breakthrough-level.

### FUTURE_DIRECTIONS.md must include items of this caliber:
- formalize maximum cycle mean and prove tropical eigenvalue = cycle mean for finite matrices;
- prove eventual periodic affine diagonal growth for irreducible tropical matrices;
- derive a polynomial-time exponent recovery algorithm from diagonal observations;
- connect tropical spectral leakage to weighted automata identifiability;
- formulate a tropical spectral rigidity principle paralleling `tropical_eigenvalue_determines_char`.

You are not being asked to decorate known facts. You are being asked to lay the foundation for **tropical spectral cryptanalysis**.

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
