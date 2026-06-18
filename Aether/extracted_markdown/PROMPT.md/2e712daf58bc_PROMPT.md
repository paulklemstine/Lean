## Assignment: Transformer Attention as Tropical Matrix Multiplication

Mode: **prove**

Aristotle, do not treat this as a metaphor hunt. Turn the slogan “attention is tropical” into a mathematically exact bridge theorem between transformer dynamics, idempotent analysis, and nonlinear spectral theory. The breakthrough is not merely to observe that `log-sum-exp` approximates `max`; it is to show that the core mechanisms of transformer computation — attention weights, multi-head aggregation, sink formation, and depth-wise convergence — admit **formal tropical semantics** with quantitative error bounds and fixed-point consequences. If this lands cleanly in Lean, it opens a new algebraic theory of deep sequence models.

You should aim for a small constellation of theorems, not a single isolated statement.

---

### Central Vision

A transformer attention layer computes
\[
A_\tau(Q,K,V) := \operatorname{softmax}\!\left(\frac{QK^\top}{\tau}\right)V
\]
where \(\tau>0\) is temperature. In logarithmic coordinates, softmax is governed by the `log-sum-exp` operator, and as \(\tau \to 0\) this converges to tropical matrix multiplication:
\[
(\,X \odot_{\max,+} Y\,)_{ij} = \max_k (X_{ik} + Y_{kj}),
\]
or equivalently min-plus after sign reversal. Multi-head attention then becomes computation in a finite product of tropical semirings, one factor per head. The attention sink phenomenon should emerge as a tropical fixed point / attracting eigenvector, and repeated layer application should be controlled by a tropical spectral radius or cycle mean.

This is not just another asymptotic approximation theorem. It would create a formal algebraic interface between:

- transformers,
- tropical geometry / idempotent semirings,
- nonlinear Perron–Frobenius theory,
- categorical neural semantics,
- and robustness / certification.

That interface could become a foundation for provable compression, depth-collapse criteria, interpretability, and asymptotic layer analysis.

---

## Precise Formal Targets

You should define the needed operators first, with concrete finite-dimensional types. Work over `Fin n`, `Matrix`, and `ℝ`.

### 1. Log-sum-exp approximates tropical matrix multiplication

Define a temperature-scaled soft tropical product:
\[
(\operatorname{lseMul}_\tau X Y)_{ij}
:=
\tau \log \sum_k \exp\!\left(\frac{X_{ik}+Y_{kj}}{\tau}\right).
\]

Define the max-plus tropical product:
\[
(\operatorname{tropMul} X Y)_{ij} := \max_k (X_{ik}+Y_{kj}).
\]

Then prove the quantitative approximation theorem:

**Theorem A (uniform log-sum-exp to tropical bound).**  
For all finite matrices \(X \in \mathbb R^{m\times n}\), \(Y \in \mathbb R^{n\times p}\), and \(\tau>0\),
\[
\forall i,j,\quad
\operatorname{tropMul}(X,Y)_{ij}
\le
\operatorname{lseMul}_\tau(X,Y)_{ij}
\le
\operatorname{tropMul}(X,Y)_{ij} + \tau \log n.
\]
Hence
\[
\|\operatorname{lseMul}_\tau(X,Y)-\operatorname{tropMul}(X,Y)\|_\infty \le \tau \log n.
\]

A plausible Lean 4 type signature:

```lean
theorem lseMul_supnorm_tropMul_bound
    {m n p : ℕ} [Fintype (Fin n)] [Nonempty (Fin n)]
    (τ : ℝ) (hτ : 0 < τ)
    (X : Matrix (Fin m) (Fin n) ℝ)
    (Y : Matrix (Fin n) (Fin p) ℝ) :
    ∀ i j,
      tropMul X Y i j ≤ lseMul τ X Y i j ∧
      lseMul τ X Y i j ≤ tropMul X Y i j + τ * Real.log n
```

You may want a cleaner statement with `Fintype.card (Fin n)` instead of `n`, since `Real.log 0` is annoying. If so, assume `[Nonempty (Fin n)]`.

A stronger norm version is also worth proving:

```lean
theorem iSup_abs_sub_lseMul_tropMul_le
    {m n p : ℕ} [Fintype (Fin n)] [Nonempty (Fin n)]
    (τ : ℝ) (hτ : 0 < τ)
    (X : Matrix (Fin m) (Fin n) ℝ)
    (Y : Matrix (Fin n) (Fin p) ℝ) :
    (⨆ i, ⨆ j, |lseMul τ X Y i j - tropMul X Y i j|) ≤ τ * Real.log n
```

This theorem is the algebraic heart. Everything else should build on it.

---

### 2. Softmax attention is tropical attention in the low-temperature/log semiring limit

Let
\[
S := QK^\top \in \mathbb R^{n\times n}.
\]
The rowwise softmax weight matrix is
\[
W^\tau_{ij} = \frac{\exp(S_{ij}/\tau)}{\sum_k \exp(S_{ik}/\tau)}.
\]
As \(\tau \to 0\), each row concentrates on the argmax set of that row. Define a tropical argmax selector relation:
\[
j \in \operatorname{ArgMaxRow}(S,i) \iff \forall k,\ S_{ik}\ge S_{ik}.
\]
Then show that if every row has a unique maximizer, the softmax attention output converges to row-selection by that maximizer.

**Theorem B (unique-argmax tropical attention limit).**  
Assume for every row \(i\), there exists a unique \(j_i\) such that
\[
S_{i j_i} > S_{ik}\quad \forall k \neq j_i.
\]
Then
\[
\lim_{\tau\to 0^+} (W^\tau V)_i = V_{j_i}.
\]
Equivalently, the attention map converges to a tropical selector matrix.

Lean-oriented signature sketch:

```lean
theorem softmax_attention_tends_to_argmax
    {n d : ℕ}
    (Q K : Matrix (Fin n) (Fin d) ℝ)
    (V : Matrix (Fin n) (Fin d) ℝ)
    (huniq : ∀ i : Fin n, ∃! j : Fin n,
      dotProduct (Q i) (K j) = maxRowScore Q K i) :
    Tendsto
      (fun τ : ℝ =>
        attentionOutput τ Q K V)
      (nhdsWithin 0 (Set.Ioi 0))
      (𝓝 (argmaxAttentionOutput Q K V))
```

You may need to weaken the topological statement to coordinatewise convergence, or formulate an explicit epsilon-delta theorem over finite index sets. That is acceptable and probably easier in Lean.

This theorem connects the usual transformer attention to tropical matrix calculus in a mathematically precise way.

---

### 3. Multi-head attention as product tropical semantics

If there are `h` heads, each head computes its own score matrix \(S^{(r)}\) and tropical limit. The mathematically clean formulation is that the tropical semantics of multi-head attention lies in the product semiring
\[
\prod_{r=1}^h (\mathbb R \cup \{-\infty\}, \max, +).
\]

You do **not** need to formalize general semiring products at maximal abstraction unless it helps. A finite tuple / function type `Fin h → Matrix ... ℝ` is enough.

**Theorem C (headwise factorization).**  
For independent heads, the tropical limit of multi-head attention is computed componentwise:
\[
\operatorname{tropMHA}((Q^{(r)},K^{(r)},V^{(r)})_{r<h})
=
(\operatorname{tropAttn}(Q^{(r)},K^{(r)},V^{(r)}))_{r<h}.
\]
If the output projection is linear, then tropicalization commutes with headwise product semantics up to the `τ log n` error from Theorem A aggregated over heads.

Lean sketch:

```lean
theorem tropical_multihead_componentwise
    {h n d : ℕ}
    (Q K V : Fin h → Matrix (Fin n) (Fin d) ℝ) :
    tropMultiHead Q K V =
      fun r => tropAttention (Q r) (K r) (V r)
```

And a quantitative approximation:

```lean
theorem multihead_lse_tropical_error_bound
    {h n d : ℕ} [Nonempty (Fin n)]
    (τ : ℝ) (hτ : 0 < τ)
    (Q K V : Fin h → Matrix (Fin n) (Fin d) ℝ) :
    ∀ r i j,
      |softHeadOutput τ (Q r) (K r) (V r) i j
        - tropHeadOutput (Q r) (K r) (V r) i j|
      ≤ τ * Real.log n * valueNormBound (V r)
```

You may need to define `valueNormBound` concretely, e.g. `sup` norm of entries of `V`. If exact multiplication by `V` complicates things, first prove the theorem for score matrices / weights, then derive an output bound.

This is the right level of boldness: it says multi-head architecture is not an arbitrary engineering trick but a product-idempotent computation.

---

### 4. Attention sink as a tropical fixed point

The “attention sink” phenomenon is that some token(s) absorb a disproportionate amount of mass across repeated layers. Tropicalize this as a fixed point / attracting eigenvector of a max-plus operator.

Let \(T : \mathbb R^n \to \mathbb R^n\) be
\[
(Tx)_i := \max_j (A_{ij} + x_j)
\]
for a score matrix \(A\). A tropical eigenpair satisfies
\[
T x = \lambda + x.
\]
A sink should correspond to a coordinate or support set that is invariant and dominant under repeated iteration.

A practical theorem:

**Theorem D (dominant-column sink criterion).**  
Suppose there exists \(j_\star\) and \(\delta>0\) such that for every row \(i\) and every \(j\neq j_\star\),
\[
A_{i j_\star} \ge A_{ij} + \delta.
\]
Then:
1. \(j_\star\) is the unique rowwise tropical argmax in every row;
2. the induced tropical attention map is the constant selector \(i \mapsto j_\star\);
3. repeated tropical attention is idempotent after one step;
4. the softmax attention map converges uniformly to this sink selector as \(\tau\to0\), with error bounded by \(e^{-\delta/\tau}\)-type estimates.

Lean signature candidate for the tropical part:

```lean
theorem dominant_column_gives_tropical_sink
    {n : ℕ} [Nonempty (Fin n)]
    (A : Matrix (Fin n) (Fin n) ℝ)
    (j⋆ : Fin n) (δ : ℝ) (hδ : 0 < δ)
    (hdom : ∀ i j, j ≠ j⋆ → A i j⋆ ≥ A i j + δ) :
    ∀ i, argmaxRow A i = j⋆
```

Then derive the fixed-point consequence:

```lean
theorem tropical_sink_idempotent
    {n d : ℕ} [Nonempty (Fin n)]
    (A : Matrix (Fin n) (Fin n) ℝ)
    (V : Matrix (Fin n) (Fin d) ℝ)
    (j⋆ : Fin n) (δ : ℝ) (hδ : 0 < δ)
    (hdom : ∀ i j, j ≠ j⋆ → A i j⋆ ≥ A i j + δ) :
    tropAttentionFromScores A V =
      fun i k => V j⋆ k
```

This is where you should connect to the existing theorem
`MachineLearning/TropicalCTC.lean : tropical_ctc_fixed_point_exists`.
Use it as evidence that fixed-point technology for tropical dynamical systems already exists in the catalog. If its hypotheses are abstract enough, instantiate them for the attention operator. If not, mimic its proof architecture.

This theorem would make “attention sink” a theorem, not an empirical anecdote.

---

### 5. Deep transformer convergence governed by tropical spectral radius / cycle mean

This is the most visionary part. Repeated application of a tropical linear map
\[
x_{t+1} = A \otimes x_t
\]
is controlled by the max-plus spectral radius, i.e. the maximum cycle mean of \(A\). In finite dimensions, this is the correct tropical analogue of Perron–Frobenius.

A realistic theorem you can formalize without rebuilding all of tropical spectral theory is:

**Theorem E (subadditive growth bound for iterated tropical attention scores).**  
Let
\[
T_A(x)_i := \max_j (A_{ij}+x_j).
\]
Define the \(t\)-fold iterate \(T_A^{[t]}\). Then there exists a scalar \(\rho(A)\) such that
\[
\sup_i (T_A^{[t]}x)_i \le \sup_i x_i + t\,\rho(A) + C_A
\]
for all \(t\), where \(\rho(A)\) may be taken as a bound from row maxima or from a tropical cycle-mean upper bound. If a unique critical class exists, normalized iterates converge to a tropical eigenvector.

Because full cycle-mean formalization may be heavy, begin with an upper bound theorem that is already nontrivial and useful:

```lean
theorem tropical_iterate_sup_bound
    {n : ℕ} [Nonempty (Fin n)]
    (A : Matrix (Fin n) (Fin n) ℝ)
    (x : Fin n → ℝ) :
    ∀ t : ℕ,
      sSup (Set.range (fun i => (tropLinIter A t x) i))
      ≤ sSup (Set.range x) + t * maxRowEntry A
```

where `maxRowEntry A` is a scalar bound such as
\[
\max_{i,j} A_{ij}.
\]

Then, if feasible, strengthen to a cycle-mean or eigenvalue statement:

```lean
theorem tropical_eigenvector_of_attention_operator
    {n : ℕ} [Nonempty (Fin n)]
    (A : Matrix (Fin n) (Fin n) ℝ) :
    ∃ λ : ℝ, ∃ x : Fin n → ℝ, tropLin A x = fun i => λ + x i
```

This may be ambitious in full generality. If so, prove it under a strong dominance / irreducibility / finite-support hypothesis. A restricted theorem is still field-opening if formalized carefully.

This is where `spectral_weight_product_bound` from
`MachineLearning/AlgebraicLearning/SpectralBounds.lean`
should be exploited. Even if that theorem lives in ordinary spectral analysis, use it as an upper-bound engine for repeated layer composition, then compare the classical spectral bound to the tropical growth bound. That cross-comparison is itself novel.

---

## Suggested Definitions in Lean

You will likely need concrete definitions along these lines:

```lean
def tropMul
    {m n p : ℕ} [Fintype (Fin n)] [Nonempty (Fin n)]
    (X : Matrix (Fin m) (Fin n) ℝ)
    (Y : Matrix (Fin n) (Fin p) ℝ) :
    Matrix (Fin m) (Fin p) ℝ :=
  fun i j => Finset.univ.sup' Finset.univ_nonempty (fun k => X i k + Y k j)

def lseMul
    {m n p : ℕ} [Fintype (Fin n)] [Nonempty (Fin n)]
    (τ : ℝ)
    (X : Matrix (Fin m) (Fin n) ℝ)
    (Y : Matrix (Fin n) (Fin p) ℝ) :
    Matrix (Fin m) (Fin p) ℝ :=
  fun i j => τ * Real.log (∑ k, Real.exp ((X i k + Y k j) / τ))
```

For attention scores:

```lean
def scoreMatrix
    {n d : ℕ}
    (Q K : Matrix (Fin n) (Fin d) ℝ) :
    Matrix (Fin n) (Fin n) ℝ :=
  fun i j => ∑ k, Q i k * K j k
```

For tropical linear action:

```lean
def tropLin
    {n : ℕ} [Fintype (Fin n)] [Nonempty (Fin n)]
    (A : Matrix (Fin n) (Fin n) ℝ)
    (x : Fin n → ℝ) : Fin n → ℝ :=
  fun i => Finset.univ.sup' Finset.univ_nonempty (fun j => A i j + x j)
```

For iterates:

```lean
def tropLinIter
    {n : ℕ} [Fintype (Fin n)] [Nonempty (Fin n)]
    (A : Matrix (Fin n) (Fin n) ℝ) : ℕ → (Fin n → ℝ) → (Fin n → ℝ)
```

If `sup'` on `ℝ` becomes annoying, use `Finset.max'` after packaging the terms into a finite set, or define via `iSup` and then use finite-index lemmas.

---

## Proof Strategy Architecture

### Strategy A: Quantitative log-sum-exp analysis
Most promising for Theorems A and B.

1. For fixed `i j`, let \(m = \max_k (X_{ik}+Y_{kj})\). Rewrite
   \[
   \tau \log \sum_k e^{(a_k/\tau)} = m + \tau \log \sum_k e^{(a_k-m)/\tau}.
   \]
2. Since each \(a_k-m \le 0\), the inner sum lies in \([1,n]\).
3. Conclude the two-sided bound \(m \le \operatorname{lse} \le m+\tau\log n\).

Why this is best: it is elementary, robust, and Lean-friendly. It gives exact quantitative control, not just asymptotics. This bound is the engine for every later theorem.

---

### Strategy B: Rowwise concentration and selector limits
Best for Theorem B and sink theorems.

1. Under unique argmax with gap \(\delta_i\), compare the winning exponent to the losers:
   \[
   \frac{e^{s_{ij}/\tau}}{\sum_k e^{s_{ik}/\tau}}
   \to
   \begin{cases}
   1 & j=j_i,\\
   0 & j\neq j_i.
   \end{cases}
   \]
2. Derive explicit finite-\(\tau\) bounds:
   \[
   1 - W^\tau_{i,j_i}
   \le (n-1)e^{-\delta_i/\tau}.
   \]
3. Transfer the bound to attention outputs by bounding convex combinations of rows of `V`.

Why this is powerful: it turns asymptotic tropicalization into an actual theorem about transformer outputs, and it explains sink formation through explicit gap estimates.

---

### Strategy C: Nonlinear spectral / fixed-point route
Most relevant for Theorems D and E.

1. View tropical attention scores as a max-plus linear operator \(T_A\).
2. Use monotonicity and additive homogeneity:
   \[
   x \le y \Rightarrow T_Ax \le T_Ay,\qquad T_A(x+c)=T_A(x)+c.
   \]
3. Prove growth bounds by induction on iterates; if feasible, identify eigenvectors under dominance or irreducibility assumptions.
4. Use `tropical_ctc_fixed_point_exists` as a model for fixed-point extraction, and compare depth-wise amplification to `spectral_weight_product_bound`.

Why this matters: it elevates the story from one-layer approximation to a theory of deep transformer dynamics.

---

## How to Build on the Catalog Theorems

### 1. `tropical_attention_certified_radius_le`
File: `MachineLearning/Neural/TropicalAttentionRobustness.lean`

Use this to connect tropicalization with robustness: once attention is approximated by a tropical operator with explicit `τ log n` error, certified robustness radii for tropical attention can be transferred to sufficiently low-temperature softmax attention. A corollary worth aiming for:

```lean
theorem soft_attention_certified_radius_via_tropical
    ...
```

This would be a major application: certified guarantees for ordinary attention through tropical surrogates.

---

### 2. `tropical_ctc_fixed_point_exists`
File: `MachineLearning/TropicalCTC.lean`

Mine this for a reusable fixed-point pattern. If the theorem is stated for a monotone, additively homogeneous operator, instantiate it with your tropical attention operator. If not directly reusable, mirror its proof structure.

This is the natural bridge for the sink/fixed-point story.

---

### 3. `spectral_weight_product_bound`
File: `MachineLearning/AlgebraicLearning/SpectralBounds.lean`

Use this as the classical counterpart to tropical growth control. A compelling bridge theorem would compare ordinary matrix-product growth and tropical iterate growth under log coordinates or bounded temperature.

Even an inequality of the form “classical depth growth upper-bounds tropical depth growth after logarithmic reparameterization” would be striking.

---

### 4. `scalar_attention_natural_matrix`
File: `MachineLearning/CategoricalNeural/Attention.lean`

This suggests there is already a categorical or naturality perspective on attention. Use it to argue that your tropicalization is not coordinate noise but a functorial semantics. If possible, prove that tropical attention respects some natural transformation induced by rowwise score maps.

That would be a beautiful categorical-neural/tropical bridge.

---

### 5. `vanishing_H1_min_margin_implies_certified_radius`
File: `MachineLearning/CechRobustnessCertification.lean`

This opens a topological angle: margins induce certified radii, and unique tropical argmax is exactly a margin statement. The rowwise gap \(\delta\) is a combinatorial margin. Try to formulate a corollary where a positive tropical attention gap implies a certified stability region.

This connects topology, robustness, and tropical attention.

---

## Cross-Domain Connections You Must Exploit

### Idempotent analysis and nonlinear Perron–Frobenius
The tropical spectral radius is the max-plus analogue of an eigenvalue. This reframes deep transformer layers as nonlinear eigen-dynamics rather than black-box compositions.

### Large deviations / zero-temperature statistical mechanics
Softmax at temperature \(\tau\) is a Gibbs measure; \(\tau \to 0\) is a zero-temperature limit selecting ground states. Tropical attention is therefore a rigorous zero-temperature transformer semantics.

### Optimal control / shortest paths
Min-plus algebra is the algebra of dynamic programming and shortest paths. Attention as tropical matrix multiplication suggests a hidden path-selection semantics for sequence processing.

### Category theory
If `scalar_attention_natural_matrix` is truly categorical, your result says transformers admit an idempotent/categorical semantics. That is much bigger than a numerical approximation theorem.

### Robustness certification
The tropical gap estimates give explicit perturbation margins. This could become a foundation for certifying head selection stability and sink stability in transformers.

Application keywords: **tropical geometry, transformer theory, idempotent semirings, max-plus algebra, nonlinear spectral theory, certified robustness, zero-temperature limit, attention sink, multi-head factorization, categorical neural semantics**.

---

## Minimum Deliverables

1. Definitions:
   - `tropMul`
   - `lseMul`
   - `scoreMatrix`
   - `tropLin`
   - one notion of `argmaxRow` or `IsStrictRowArgmax`

2. Core theorem:
   - `lseMul_supnorm_tropMul_bound`

3. One attention limit theorem:
   - unique-argmax convergence or explicit finite-τ concentration

4. One sink/fixed-point theorem:
   - dominant-column criterion strongly preferred

5. One depth theorem:
   - at least a nontrivial iterate growth bound; spectral-radius language if feasible

6. At least one cross-domain corollary:
   - robustness, categorical naturality, or spectral comparison

Minimize `sorry`. If one major theorem is too ambitious, prove a strong restricted version rather than leaving a grand theorem empty.

---

## If Direct Formalization Fails

- Replace full topological `Tendsto` by explicit epsilon-delta or coordinatewise estimates.
- Replace full tropical spectral radius by row-max growth bounds.
- Replace general multi-head output theorem by componentwise score theorem.
- Replace arbitrary sink characterization by dominant-column hypothesis with positive gap.

These are not retreats; they are proper staging points.

---

## Required FUTURE_DIRECTIONS.md

You must produce a structured `FUTURE_DIRECTIONS.md` with 3–5 concrete next steps at breakthrough level. Include items of the following flavor:

1. Formalize tropical eigenvalue / max-cycle-mean theory in Lean and apply it to deep attention layers.
2. Prove certified equivalence between low-temperature softmax transformers and tropical transformers on margin-separated inputs.
3. Build a categorical semantics of multi-head attention as a product object in an idempotent-enriched category.
4. Connect tropical attention sinks to mechanistic interpretability by proving persistence of sink tokens under perturbation.
5. Develop min-plus transformer compression or pruning criteria from tropical dominance.

Be specific: name exact theorem targets, not vague topics.

Now build the bridge. The point is not to say transformers resemble tropical algebra. The point is to make tropical algebra an exact theorem about transformers.

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

Research domain: MachineLearning
Research mode: prove
