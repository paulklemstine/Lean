## Assignment: Finite-temperature pruning law for redundant heads

Prove a genuinely new theorem formalizing a sharp finite-temperature stability principle for log-sum-exp aggregation under head pruning. The target is not an implementation detail of transformers; it is a structural theorem about soft tropicalization: when one coordinate is redundant in the tropical sense, finite-temperature smoothing cannot amplify its removal by more than an entropic term `τ * log n`. This is the beginning of a formal pruning calculus.

### Mode
prove

### Core Breakthrough Target

Let
- `τ > 0` be temperature,
- `x : Fin (n+1) → ℝ` be head scores,
- `j : Fin (n+1)` be a candidate redundant head,
- `s = max_{i ≠ j} x i`.

Define the finite-temperature aggregate
\[
\operatorname{LSE}_\tau(x) := \tau \log \left(\sum_i e^{x_i/\tau}\right).
\]
Define the pruned vector by removing or zeroing out head `j` in the sum:
\[
\operatorname{LSE}_\tau^{(-j)}(x) := \tau \log \left(\sum_{i \ne j} e^{x_i/\tau}\right).
\]

The theorem you should aim to prove in strongest useful form is:

> **Finite-temperature pruning bound.**  
> For every `n : ℕ`, every `τ > 0`, every `x : Fin (n+1) → ℝ`, and every `j : Fin (n+1)`, if `x j ≤ sup_{i ≠ j} x i`, then
> \[
> 0 \le \operatorname{LSE}_\tau(x) - \operatorname{LSE}_\tau^{(-j)}(x)
> \le \tau \log 2.
> \]
> More generally, if a set `S` of heads is removed and each removed head is pointwise dominated by the maximum of the retained heads, then
> \[
> 0 \le \operatorname{LSE}_\tau(x) - \operatorname{LSE}_{\tau}^{(\mathrm{keep})}(x)
> \le \tau \log (|S|+1),
> \]
> and in particular, if at most `n` redundant heads are removed relative to one surviving maximizer, the change is bounded by
> \[
> \tau \log n.
> \]

This is the right theorem because the single-head statement gives the exact local pruning law, while the multi-head statement produces the advertised `τ · log n` scaling and turns redundancy into a certified compression principle.

### Lean 4 formalization target

Use concrete finite index sets and reals. A suitable main theorem shape is:

```lean
theorem lse_prune_redundant_head_bound
  {n : ℕ} (τ : ℝ) (hτ : 0 < τ) (x : Fin (n+1) → ℝ) (j : Fin (n+1))
  (hred : x j ≤ Finset.sup' ((Finset.univ).erase j) (by
    simpa using Finset.card_erase_ne_zero.2 (Fin.is_lt j)) (fun i => x i)) :
  let lse_all : ℝ := τ * Real.log (∑ i : Fin (n+1), Real.exp (x i / τ))
  let lse_pruned : ℝ := τ * Real.log (∑ i in (Finset.univ.erase j), Real.exp (x i / τ))
  0 ≤ lse_all - lse_pruned ∧ lse_all - lse_pruned ≤ τ * Real.log 2
```

Then generalize to subsets:

```lean
theorem lse_prune_redundant_set_bound
  {n : ℕ} (τ : ℝ) (hτ : 0 < τ) (x : Fin n → ℝ)
  (K : Finset (Fin n)) (hK : K.Nonempty)
  (R : Finset (Fin n)) (hdisj : Disjoint K R)
  (hdom : ∀ j ∈ R, x j ≤ Finset.sup' K hK (fun i => x i)) :
  let lse_all : ℝ := τ * Real.log (∑ i : Fin n, Real.exp (x i / τ))
  let lse_keep : ℝ := τ * Real.log (∑ i in K, Real.exp (x i / τ))
  0 ≤ lse_all - lse_keep ∧
  lse_all - lse_keep ≤ τ * Real.log (R.card + 1)
```

A sharper and more elegant version replaces `R.card + 1` by
\[
\tau \log\!\left(1 + \sum_{j \in R} e^{(x_j - s)/\tau}\right),
\quad s = \sup_{i \in K} x_i,
\]
from which the cardinality bound follows immediately. This refined theorem is probably the true breakthrough statement.

A refined Lean signature:

```lean
theorem lse_prune_refined_gap_bound
  {n : ℕ} (τ : ℝ) (hτ : 0 < τ) (x : Fin n → ℝ)
  (K : Finset (Fin n)) (hK : K.Nonempty)
  (R : Finset (Fin n)) (hdisj : Disjoint K R)
  (hall : K ∪ R = Finset.univ) :
  let s : ℝ := Finset.sup' K hK (fun i => x i)
  let lse_all : ℝ := τ * Real.log (∑ i : Fin n, Real.exp (x i / τ))
  let lse_keep : ℝ := τ * Real.log (∑ i in K, Real.exp (x i / τ))
  lse_all - lse_keep ≤
    τ * Real.log (1 + ∑ j in R, Real.exp ((x j - s) / τ))
```

### Why this is a breakthrough

This is not merely “pruning changes the output a little.” It identifies the exact thermodynamic penalty of deleting tropical-redundant components under entropic smoothing. In max-plus language, redundancy is free; in finite temperature, redundancy costs only entropy. This creates a rigorous bridge between:
- tropical geometry (`max` as zero-temperature limit),
- information theory (log-partition / free energy),
- neural compression (head pruning),
- statistical mechanics (partition functions under state deletion).

A theorem of this form opens a formal theory of **certified soft pruning**, where model compression guarantees are derived from energy landscapes rather than ad hoc Lipschitz estimates.

### Existing verified theorems to exploit

Build on the catalog aggressively, even if only conceptually at first:

1. `tropical_spectral_bound`  
   Use this as a precedent for converting tropical dominance information into quantitative finite bounds. If it packages a max-plus spectral estimate, imitate its “dominated by extremal coordinate” style when structuring lemmas.

2. `tropical_fourier_coeff_bound`  
   This likely encodes a finite-index summation bound with a tropical flavor. Reuse any summation / supremum proof patterns for finite families over `Fin n` and `Finset`.

3. `tropical_kl_antisymmetric_bound`  
   This is especially relevant conceptually: LSE is a log-partition function, and pruning is deleting states. There is a hidden information-theoretic interpretation: the pruning gap is a free-energy or log-normalizer difference, hence a KL-type control may emerge. If the theorem gives antisymmetric KL control, try to reinterpret your bound as a one-sided partition perturbation inequality.

4. `tropical_security_from_norm_bound`  
   Potentially useful for a later corollary: if head-score perturbations are norm-controlled, combine norm robustness with pruning robustness to get hybrid compression-security certificates.

5. `birthday_bound_tropical_hash`  
   Not directly on topic, but if it contains entropy/cardinality logarithm estimates, its proof may offer reusable finite combinatorial `log(card)` machinery.

### Proof architecture: three viable strategies

#### Strategy A: Direct log-partition comparison via factorization
Most promising.

1. Let `s = sup' K ... (fun i => x i)` where `K` is the kept set.
   Then for every removed `j ∈ R`, use `x j ≤ s` to derive
   \[
   e^{x_j/\tau} \le e^{s/\tau}.
   \]

2. Lower-bound the retained partition:
   since `K` contains an index attaining `s`,
   \[
   \sum_{i \in K} e^{x_i/\tau} \ge e^{s/\tau}.
   \]

3. Therefore
   \[
   \sum_{i \in R} e^{x_i/\tau}
   \le |R|\, e^{s/\tau}
   \le |R| \sum_{i \in K} e^{x_i/\tau}.
   \]
   Hence
   \[
   \sum_{i \in K \cup R} e^{x_i/\tau}
   \le (|R|+1)\sum_{i \in K} e^{x_i/\tau}.
   \]

4. Apply monotonicity of `Real.log`, then multiply by `τ > 0`:
   \[
   \tau \log Z_{\mathrm{all}} - \tau \log Z_{\mathrm{keep}}
   \le \tau \log(|R|+1).
   \]

This route is clean, finite, and highly Lean-friendly.

#### Strategy B: Refined free-energy defect formula
More conceptual; likely yields the strongest theorem.

1. Write
   \[
   Z_{\mathrm{all}} = Z_{\mathrm{keep}}\left(1 + \frac{Z_R}{Z_{\mathrm{keep}}}\right),
   \quad
   \Delta = \tau \log\left(1 + \frac{Z_R}{Z_{\mathrm{keep}}}\right).
   \]

2. Bound
   \[
   \frac{Z_R}{Z_{\mathrm{keep}}}
   \le \sum_{j \in R} e^{(x_j-s)/\tau}
   \]
   using `Z_keep ≥ e^{s/τ}`.

3. Conclude the refined theorem
   \[
   \Delta \le \tau \log\left(1+\sum_{j \in R} e^{(x_j-s)/\tau}\right).
   \]
   Then deduce the cardinality bound because each exponential term is `≤ 1`.

This is the theorem the field actually wants: it quantifies not just redundancy count, but redundancy depth.

#### Strategy C: Convex duality / entropy route
Harder to formalize, but conceptually revolutionary.

1. Use the variational formula
   \[
   \operatorname{LSE}_\tau(x)
   = \sup_{p \in \Delta_n} \left(\sum_i p_i x_i + \tau H(p)\right).
   \]

2. Compare optimization over all distributions with optimization restricted to the kept set. The difference comes only from entropy carried by deleted states.

3. If removed heads are score-dominated by the kept maximum, their linear-energy contribution gives no gain over the kept maximizer; only entropy remains, producing exactly the `τ log(|R|+1)` term.

This route builds a profound bridge to information theory and statistical mechanics. Even if the full variational theorem is too heavy for this cycle, include it in `FUTURE_DIRECTIONS.md`.

### Recommended proof decomposition in Lean

Prove these lemmas first.

1. **Partition positivity**
```lean
lemma sum_exp_pos {n : ℕ} (τ : ℝ) (hτ : 0 < τ) (x : Fin n → ℝ) :
  0 < ∑ i : Fin n, Real.exp (x i / τ)
```

2. **Kept partition dominates top exponent**
```lean
lemma sum_exp_ge_exp_sup
  {n : ℕ} (τ : ℝ) (hτ : 0 < τ) (x : Fin n → ℝ)
  (K : Finset (Fin n)) (hK : K.Nonempty) :
  let s := Finset.sup' K hK (fun i => x i)
  Real.exp (s / τ) ≤ ∑ i in K, Real.exp (x i / τ)
```

3. **Removed partition bounded by cardinality times top exponent**
```lean
lemma sum_exp_removed_le_card_mul_exp_sup
  {n : ℕ} (τ : ℝ) (hτ : 0 < τ) (x : Fin n → ℝ)
  (K R : Finset (Fin n)) (hK : K.Nonempty)
  (hdom : ∀ j ∈ R, x j ≤ Finset.sup' K hK (fun i => x i)) :
  ∑ j in R, Real.exp (x j / τ)
    ≤ R.card * Real.exp ((Finset.sup' K hK (fun i => x i)) / τ)
```

4. **Ratio bound**
```lean
lemma sum_exp_all_le_mul_sum_exp_keep
  ...
  :
  ∑ i : Fin n, Real.exp (x i / τ)
    ≤ (R.card + 1 : ℝ) * ∑ i in K, Real.exp (x i / τ)
```

5. **Log-transfer lemma**
```lean
lemma tau_log_le_of_le_mul
  {a b c τ : ℝ} (hτ : 0 < τ) (ha : 0 < a) (hb : 0 < b) (hc : 1 ≤ c)
  (h : a ≤ c * b) :
  τ * Real.log a - τ * Real.log b ≤ τ * Real.log c
```

Once these are in place, the main theorem should be short.

### Cross-domain connections you must make explicit

1. **Statistical mechanics**  
   `LSE_τ` is free energy / log-partition. Pruning deletes microstates. Your theorem says deleting energetically dominated states costs at most entropy. This is a finite-state free-energy stability law.

2. **Information theory**  
   The difference of log-partitions is a coding redundancy penalty. Connect the refined bound to KL-style control and Gibbs distributions. This is where `tropical_kl_antisymmetric_bound` may become structurally relevant.

3. **Tropical geometry / idempotent analysis**  
   As `τ → 0`, `LSE_τ → max`. Your theorem quantifies the defect of replacing smooth aggregation by tropical aggregation under state deletion. This is a certified dequantization estimate.

4. **Neural network pruning**  
   In attention, each head contributes a score/logit. If a head is always dominated by others at the score level, then softmax aggregation changes by at most an entropic penalty. This provides a theorem-schema for certified head removal.

5. **Spectral and Fourier viewpoints**  
   If head scores arise from spectral modes or Fourier coefficients, combine this theorem with `tropical_spectral_bound` or `tropical_fourier_coeff_bound` to derive pruning certificates from harmonic/spectral decay.

### Strong corollaries worth proving if time permits

#### Corollary 1: Uniform domination gap gives exponential improvement
If each removed head satisfies `x j ≤ s - δ` for some `δ ≥ 0`, then
\[
\Delta \le \tau \log\left(1 + |R| e^{-\delta/\tau}\right).
\]
This is much stronger than `τ log(|R|+1)` and captures low-temperature suppression.

Lean target:
```lean
theorem lse_prune_gap_with_margin
  {n : ℕ} (τ δ : ℝ) (hτ : 0 < τ) (hδ : 0 ≤ δ)
  (x : Fin n → ℝ) (K R : Finset (Fin n)) (hK : K.Nonempty)
  (hdom : ∀ j ∈ R, x j ≤ Finset.sup' K hK (fun i => x i) - δ) :
  let lse_all : ℝ := τ * Real.log (∑ i in K ∪ R, Real.exp (x i / τ))
  let lse_keep : ℝ := τ * Real.log (∑ i in K, Real.exp (x i / τ))
  lse_all - lse_keep ≤ τ * Real.log (1 + R.card * Real.exp (-δ / τ))
```

#### Corollary 2: Single-head exact defect formula
For one removed head `j`,
\[
\Delta = \tau \log\left(1 + \frac{e^{x_j/\tau}}{\sum_{i \ne j} e^{x_i/\tau}}\right),
\]
hence if `x_j ≤ max_{i ≠ j} x_i`, then `Δ ≤ τ log 2`.

This gives the cleanest theorem and should probably be formalized first.

#### Corollary 3: Zero-temperature convergence under pruning
If removed heads are tropical-redundant, then
\[
\lim_{\tau \to 0^+} \left(\operatorname{LSE}_\tau(x) - \operatorname{LSE}^{(\mathrm{keep})}_\tau(x)\right) = 0.
\]
This is the conceptual bridge theorem to tropicalization.

### Lean engineering advice

- Prefer `Finset.sup'` over `sup` to avoid bottom-element complications.
- Keep sums over `Finset` rather than coercing immediately to full `Fintype` sums unless needed.
- Use `have hpos : 0 < ... := by exact Finset.sum_pos ...` with `Real.exp_pos`.
- For logarithms, isolate positivity side conditions early.
- The identity `log a - log b = log (a / b)` is useful, but in Lean it may be simpler to use monotonicity:
  from `a ≤ c*b`, get `log a ≤ log (c*b) = log c + log b`, then rearrange.
- For singleton or erase cases, start with `n+1` so `erase j` is nonempty when needed.

### What to write if the strongest theorem is hard

If the full subset theorem becomes technically heavy, prove in this order:

1. single redundant head with `≤ τ * log 2`,
2. repeated-pruning induction giving `≤ τ * k * log 2`,
3. improved cardinality theorem `≤ τ * log (k+1)` once the ratio argument is in place.

But do not stop at a trivial one-head inequality if the multi-head logarithmic theorem is within reach.

### Deliverables

1. Lean theorem(s) implementing the finite-temperature pruning bound.
2. Supporting lemmas about sums of exponentials, `Finset.sup'`, and logarithm monotonicity.
3. At least one cross-domain corollary, preferably the margin-refined bound.
4. `FUTURE_DIRECTIONS.md` with 3–5 concrete next steps.

### Required application keywords

- certified pruning
- attention head redundancy
- log-sum-exp stability
- tropicalization error
- free energy perturbation
- entropy-compression tradeoff
- softmax robustness
- idempotent analysis
- KL / Gibbs distributions
- low-temperature asymptotics

### Required FUTURE_DIRECTIONS.md contents

You must include 3–5 specific next theorems, each with:
- exact statement,
- why it is breakthrough-level,
- likely Lean proof route,
- cross-domain payoff.

Strong suggestions:

1. **Variational LSE theorem in Lean**  
   Formalize
   \[
   \tau \log \sum_i e^{x_i/\tau} = \sup_{p \in \Delta_n} \left(\sum_i p_i x_i + \tau H(p)\right).
   \]
   This would unlock entropy-based proofs everywhere.

2. **Pruning under linear output maps**  
   If each head outputs a vector and aggregation is weighted by softmax scores, prove an operator-norm bound on output perturbation after pruning.

3. **Tropical mutual information via log-sum-exp smoothing**  
   Connect finite-temperature tropicalization to data-processing inequalities.

4. **Spectral pruning theorem**  
   Combine `tropical_spectral_bound` with the pruning bound to certify removal of spectrally subdominant modes.

5. **Low-temperature asymptotic expansion**  
   Show the pruning defect is asymptotic to `τ log m`, where `m` is the multiplicity of near-maximal removed states, under precise gap hypotheses.

Be bold: the real target is to found a formal theory of thermodynamic model compression, not just prove one inequality.

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
