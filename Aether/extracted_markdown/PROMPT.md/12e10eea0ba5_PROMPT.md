Soli Deo Gloria

## Assignment: Direction 4: Phase Transitions in Tropical Stability

**Mode:** `prove` + `discover`

You are not being asked for an incremental probabilistic embellishment. You are being asked to found a rigorous **average-case theory of tropical Lorentzian certification**: to identify the deterministic combinatorial skeleton behind the conjectured phase transition, prove sharp finite-dimensional threshold theorems in formally checkable form, and build the first verified computational pipeline that tests the random-matrix prediction at scale.

The guiding principle is this: the catalog already gives local Lipschitz control of tropical exchange slack. Your task is to turn that local stability into a **global threshold theory**. The real breakthrough is not merely “some probability bound,” but a theorem package that makes tropical Lorentzianity look like a genuine monotone property with a signal-to-noise threshold, analogous to phase transitions in random graphs, spin glasses, and random CSPs.

Build explicitly on:

- `Pythagorean/TropicalLorentzianShadows.lean`
  - especially `tropical_gap_eq_uniform`
  - and `exchange_slack_lipschitz`

The conceptual leap is to reinterpret the tropical gap as the minimum of a highly structured family of affine functionals, then prove deterministic comparison theorems and probabilistic consequences.

---

## Core New Definitions You Should Introduce

At least one genuinely new concept is mandatory. I recommend introducing all three below.

### 1. Diagonal bias of a symmetric matrix
For a symmetric matrix `W : Matrix (Fin n) (Fin n) ℝ`, define the worst-case off-vs-diagonal separation
\[
\operatorname{diagBias}(W)
:= \inf_{i\neq j}\left(W_{ij} - \frac{W_{ii}+W_{jj}}{2}\right).
\]
This is the natural signal parameter: positive bias means off-diagonal interactions systematically dominate diagonal self-weights.

Suggested Lean shape:
```lean
def diagBias {n : ℕ} (W : Matrix (Fin n) (Fin n) ℝ) : ℝ :=
  sInf {t : ℝ | ∃ i j : Fin n, i ≠ j ∧
    t = W i j - (W i i + W j j) / 2}
```
You may also prefer a finite-set minimum formulation for easier proof automation.

### 2. Exchange slack on a quadruple
For indices `i j k l`, define
\[
\operatorname{exSlack}(W;i,j,k,l) := W_{ij}+W_{kl}-W_{ik}-W_{jl}.
\]
This should refine the catalog’s exchange slack notion into a reusable deterministic primitive.

Suggested Lean shape:
```lean
def exSlack {n : ℕ} (W : Matrix (Fin n) (Fin n) ℝ)
    (i j k l : Fin n) : ℝ :=
  W i j + W k l - W i k - W j l
```

### 3. Uniform tropical stability margin
Define the minimum exchange slack over all admissible quadruples:
\[
\operatorname{tropMargin}(W) := \min_{(i,j,k,l)\in \mathcal A_n} \operatorname{exSlack}(W;i,j,k,l),
\]
for a carefully chosen admissibility predicate `AdmissibleQuad` excluding degenerate coincidences if needed.

Suggested Lean shape:
```lean
def AdmissibleQuad {n : ℕ} (i j k l : Fin n) : Prop :=
  i ≠ k ∧ i ≠ l ∧ j ≠ k ∧ j ≠ l

def tropMargin {n : ℕ} (W : Matrix (Fin n) (Fin n) ℝ) : ℝ :=
  Finset.inf' (admissibleQuads n) admissibleQuads_nonempty
    (fun q => exSlack W q.1 q.2.1 q.2.2.1 q.2.2.2)
```
You may tailor the index packaging to what is practical in Lean.

These definitions matter because they isolate the deterministic geometry from the stochastic model. Once formalized, random Gaussian statements become corollaries of deterministic inequalities plus concentration bounds.

---

## Precise Theorem Targets

You must prove at least **3 substantial theorems**, with nontrivial tactics (`induction`, `rcases`, `by_contra`, `field_simp`, multi-step `calc`, etc.). Below are the theorem targets I most want.

---

### Theorem 1: Deterministic bias-to-margin lower bound

**Mathematical statement.**
For every symmetric matrix \(W\), every admissible exchange slack is bounded below by twice the diagonal bias:
\[
\forall i,j,k,l,\quad \operatorname{AdmissibleQuad}(i,j,k,l)
\implies
\operatorname{exSlack}(W;i,j,k,l)\ge 2\,\operatorname{diagBias}(W).
\]
Hence
\[
\operatorname{tropMargin}(W)\ge 2\,\operatorname{diagBias}(W).
\]

This is the deterministic engine of the whole project. It says a uniform off-diagonal signal forces global tropical stability.

A clean proof route is:
\[
W_{ij} \ge \frac{W_{ii}+W_{jj}}2 + \operatorname{diagBias}(W),\qquad
W_{kl} \ge \frac{W_{kk}+W_{ll}}2 + \operatorname{diagBias}(W),
\]
while
\[
W_{ik} \le \frac{W_{ii}+W_{kk}}2 - \operatorname{diagBias}(W)
\]
is generally false, so you should instead derive the lower bound by reorganizing the relevant admissible inequalities in the correct direction from the definition of `diagBias`. The right formulation of `diagBias` may need to be as a **minimum over pairwise half-sum defects** so that both positive and negative appearances are controllable. If necessary, define both
\[
\underline{\beta}(W)=\min_{i\neq j}\left(W_{ij}-\frac{W_{ii}+W_{jj}}2\right),\quad
\overline{\beta}(W)=\max_{i\neq j}\left(W_{ij}-\frac{W_{ii}+W_{jj}}2\right)
\]
and prove a bound involving \(\underline{\beta}-\overline{\beta}\). The theorem should be true in a robust deterministic form, even if the first naive statement needs refinement.

**Lean 4 target signature (one viable version):**
```lean
theorem exSlack_lower_bound_of_diagBias
    {n : ℕ} (hn : 4 ≤ n) (W : Matrix (Fin n) (Fin n) ℝ)
    (hSymm : W.IsSymm) :
    ∀ {i j k l : Fin n}, AdmissibleQuad i j k l →
      2 * diagBias W ≤ exSlack W i j k l
```

and then

```lean
theorem tropMargin_lower_bound_of_diagBias
    {n : ℕ} (hn : 4 ≤ n) (W : Matrix (Fin n) (Fin n) ℝ)
    (hSymm : W.IsSymm) :
    2 * diagBias W ≤ tropMargin W
```

**Why this is a breakthrough.**
It turns a global \(O(n^4)\)-family of tropical inequalities into a single scalar certificate. That is the exact kind of compression theorem that creates a new theory.

---

### Theorem 2: Lipschitz stability of the tropical margin under sup-norm perturbations

The catalog already contains `exchange_slack_lipschitz`. Use it to prove the global minimum version.

**Mathematical statement.**
For symmetric matrices \(W,W'\),
\[
|\operatorname{tropMargin}(W)-\operatorname{tropMargin}(W')|
\le 4\|W-W'\|_\infty.
\]

This is the formal bridge from deterministic geometry to probability. Once you have this, Gaussian concentration can be imported through perturbation arguments.

**Lean 4 target signature:**
```lean
def entrySupNorm {n : ℕ} (W : Matrix (Fin n) (Fin n) ℝ) : ℝ :=
  Finset.sup (Finset.univ.product Finset.univ)
    (fun p => |W p.1 p.2|)

theorem tropMargin_lipschitz
    {n : ℕ} (W W' : Matrix (Fin n) (Fin n) ℝ) :
    |tropMargin W - tropMargin W'| ≤ 4 * entrySupNorm (W - W')
```

If `Finset.sup` over `ℝ` is inconvenient, use a finite maximum over `ℚ≥0`-valued absolute values or an existential upper-bound formulation.

**Proof strategy.**
- Use the catalog theorem `exchange_slack_lipschitz` pointwise on each admissible quadruple.
- Prove two one-sided inequalities:
  \[
  \operatorname{tropMargin}(W)\le \operatorname{tropMargin}(W')+4\|W-W'\|_\infty
  \]
  and the reverse with \(W,W'\) swapped.
- Combine by `abs_le.mpr`.
This should require nontrivial `rcases`, finite-minimum reasoning, and multi-step `calc`.

**Why this matters.**
This theorem says the tropical phase transition is not a fragile artifact. It is stable under noise in the strongest uniform sense.

---

### Theorem 3: Finite-dimensional threshold criterion via deterministic signal/noise decomposition

Introduce a decomposition
\[
W = S + N
\]
where `S` is a structured signal matrix and `N` is noise. Prove that if the signal has positive tropical margin and the noise sup-norm is smaller than one quarter of that margin, then the perturbed matrix remains tropical-stable.

**Mathematical statement.**
If
\[
\operatorname{tropMargin}(S) > 4\|N\|_\infty,
\]
then
\[
\operatorname{tropMargin}(S+N) > 0.
\]

**Lean 4 target signature:**
```lean
theorem tropMargin_pos_of_signal_noise
    {n : ℕ} (S N : Matrix (Fin n) (Fin n) ℝ)
    (h : 4 * entrySupNorm N < tropMargin S) :
    0 < tropMargin (S + N)
```

A stronger and cleaner theorem is:
```lean
theorem tropMargin_lower_bound_signal_noise
    {n : ℕ} (S N : Matrix (Fin n) (Fin n) ℝ) :
    tropMargin S - 4 * entrySupNorm N ≤ tropMargin (S + N)
```

This is likely the more useful formal target.

**Why this is the phase transition skeleton.**
This theorem isolates the critical scale \( \text{signal} \sim \text{noise} \). In random models, the noise sup-norm scales like \( \sigma\sqrt{\log n} \), so this deterministic statement already predicts the conjectured threshold shape.

---

### Theorem 4: Structured mean model has explicit positive margin

To connect with the Gaussian ensemble, define the two-parameter mean matrix
\[
M^{(n)}(\mu_{\mathrm{diag}},\mu_{\mathrm{off}})_{ij}
=
\begin{cases}
\mu_{\mathrm{diag}}, & i=j,\\
\mu_{\mathrm{off}}, & i\ne j.
\end{cases}
\]
Then compute its tropical margin exactly.

**Mathematical statement.**
For admissible quadruples,
\[
\operatorname{exSlack}(M;i,j,k,l)=
\begin{cases}
2(\mu_{\mathrm{off}}-\mu_{\mathrm{diag}}), & \text{if exactly two terms are diagonal-crossing in the right pattern},\\
0 \text{ or another explicit value}, & \text{depending on admissibility convention.}
\end{cases}
\]
Choose the admissibility convention so that the exact minimum is
\[
\operatorname{tropMargin}(M)=2(\mu_{\mathrm{off}}-\mu_{\mathrm{diag}})
\]
or a similarly explicit formula.

**Lean 4 target signature:**
```lean
def meanModel {n : ℕ} (μdiag μoff : ℝ) : Matrix (Fin n) (Fin n) ℝ :=
  fun i j => if i = j then μdiag else μoff

theorem tropMargin_meanModel
    {n : ℕ} (hn : 4 ≤ n) (μdiag μoff : ℝ) :
    tropMargin (meanModel μdiag μoff) = 2 * (μoff - μdiag)
```

If the exact formula depends on your admissibility convention, state the correct exact formula. The important point is **exact computability**.

**Why this matters.**
This theorem identifies the signal parameter explicitly. It is the deterministic counterpart of the conjectured critical quantity \(\mu_{\mathrm{off}}-\mu_{\mathrm{diag}}\).

---

### Theorem 5: Cross-domain bridge to statistical physics / sublevel-set monotonicity

You must include at least one theorem connecting this domain to another. The cleanest bridge is to define the **stable region**
\[
\mathcal{S}_t := \{W : \operatorname{tropMargin}(W)\ge t\}.
\]
Then prove monotonic nesting:
\[
t_1 \le t_2 \implies \mathcal{S}_{t_2}\subseteq \mathcal{S}_{t_1}.
\]
That by itself is elementary; not enough. The deeper bridge is to show that the indicator of stability is monotone under increasing off-diagonal entries and decreasing diagonal entries, which is a ferromagnetic-style monotonicity property.

**Mathematical statement.**
If \(W'\) is obtained from \(W\) by increasing every off-diagonal entry and decreasing every diagonal entry, then
\[
\operatorname{tropMargin}(W') \ge \operatorname{tropMargin}(W).
\]

**Lean 4 target signature:**
```lean
def OffDiagMonotoneLe {n : ℕ}
    (W W' : Matrix (Fin n) (Fin n) ℝ) : Prop :=
  (∀ i, W' i i ≤ W i i) ∧
  (∀ i j, i ≠ j → W i j ≤ W' i j)

theorem tropMargin_mono_offdiag_up_diag_down
    {n : ℕ} (W W' : Matrix (Fin n) (Fin n) ℝ)
    (hmono : OffDiagMonotoneLe W W') :
    tropMargin W ≤ tropMargin W'
```

**Cross-domain significance.**
This is a genuine bridge to:
- **statistical physics**: monotone observables, order parameters, threshold behavior;
- **random matrix theory**: deformed ensembles;
- **machine learning**: feature interaction dominance over self-energy terms.

This theorem transforms tropical stability into an order parameter.

---

## Conjecture with a Testable Prediction

You must state at least one falsifiable conjecture with a computational protocol that could disprove it.

### Main conjecture: finite-size scaling collapse
Let `G(n, μdiag, μoff, σ)` be the symmetric Gaussian ensemble with independent upper-triangular entries, diagonal mean `μdiag`, off-diagonal mean `μoff`, and variance `σ^2`. Then there exists a universal constant `c > 0` and a nontrivial profile `Φ : ℝ → [0,1]` such that
\[
\mathbb P(\operatorname{tropMargin}(W)\ge 0)
\approx
\Phi\!\left(
\frac{\mu_{\mathrm{off}}-\mu_{\mathrm{diag}}}{\sigma\sqrt{\log n}} - c
\right)
\]
uniformly for moderate \(n\), with convergence to a sharp step as \(n\to\infty\).

**Computational disproof protocol.**
For \(n\in\{5,10,20,50\}\), sample 10,000 matrices per parameter value and plot
\[
p_n(x):=\mathbb P(\operatorname{tropMargin}(W)\ge 0)
\]
against
\[
x=\frac{\mu_{\mathrm{off}}-\mu_{\mathrm{diag}}}{\sigma\sqrt{\log n}}.
\]
If the curves fail to collapse after horizontal translation/scaling, the conjecture is false.

### Stronger conjecture: extremal quadruple sparsity
With high probability in the critical window, the minimizing quadruple for `tropMargin` uses four distinct indices and is asymptotically unique.

This is highly falsifiable and algorithmically testable. If true, it suggests a sparse “defect localization” phenomenon analogous to localized excitations in disordered systems.

---

## Proof Architecture: 3 Viable Routes

You asked for 2–3 proof strategy steps. Here are three serious pathways; pursue at least two in the write-up.

### Strategy A: Deterministic finite-combinatorial route — most promising for Lean
1. **Refactor tropical gap as a finite minimum of affine forms.**
   Use `tropical_gap_eq_uniform` to identify the catalog gap with your `tropMargin` or prove a clean comparison theorem.
2. **Push local Lipschitz to global Lipschitz.**
   Apply `exchange_slack_lipschitz` pointwise, then pass to finite minima using min-stability inequalities.
3. **Derive threshold criteria from exact mean-model computations.**
   Compute `tropMargin` for `meanModel μdiag μoff`, then combine with the global Lipschitz bound to obtain deterministic signal-vs-noise theorems.

**Why this is best.**
It is fully formalizable in Lean 4 with current Mathlib and yields the strongest theorem-to-effort ratio. It also creates the framework needed for later probabilistic imports.

### Strategy B: Concentration-from-supremum route
1. Prove deterministic perturbation inequalities for `tropMargin`.
2. Use known concentration behavior of the matrix sup norm in Gaussian ensembles:
   \[
   \|N\|_\infty = O(\sigma\sqrt{\log n})
   \]
   with high probability.
3. Conclude one-sided threshold bounds:
   if the mean-model margin dominates the sup-norm fluctuation scale, then stability holds with high probability; if it is dominated by a witness family of bad quadruples, instability holds with high probability.

**Why this is powerful.**
This produces the first genuine probabilistic theorem, even if only with explicit finite-\(n\) tail bounds rather than asymptotic sharpness.

### Strategy C: Comparison inequalities / correlated Gaussian minima
1. Identify each admissible exchange slack as a centered Gaussian plus deterministic drift.
2. Compute covariance structure explicitly.
3. Apply Slepian/Fernique or union/lower-bound methods to estimate the minimum and derive upper/lower threshold windows.

**Why this is ambitious.**
This is the route to a true phase-transition theorem. It may be partially beyond current formal probability infrastructure, but even a mathematically precise informal development in `RESEARCH_PAPER.md` would be field-opening. In Lean, formalize the deterministic covariance computations and finite-union surrogate bounds.

---

## Lean-Specific Formalization Guidance

### Suggested file
Create a new file such as:
```text
Pythagorean/TropicalPhaseTransition.lean
```

### Minimal formal package to deliver
- new definitions: `exSlack`, `diagBias`, `tropMargin`, `meanModel`, `OffDiagMonotoneLe`
- at least 3 substantial theorems from the list above
- at least one theorem explicitly invoking catalog results from `TropicalLorentzianShadows.lean`
- one verified algorithm for computing `tropMargin` on finite matrices

### Tactic expectations
Your proofs should visibly use:
- `rcases` to unpack admissible quadruples / finite minima witnesses
- `by_contra` for positivity/nonnegativity threshold arguments
- `calc` chains for affine inequality manipulations
- `field_simp` if you retain half-sum formulas with division by 2
- finite-case combinatorial reasoning rather than brute-force `decide`

---

## Verified Algorithm / Computational Method

You must deliver a verified algorithm, not just theorem statements.

### Required algorithm
Implement an algorithm that computes `tropMargin` by enumerating admissible quadruples and prove:

1. **Soundness**:
   the algorithm’s output equals the mathematical definition of `tropMargin`.
2. **Certificate extraction**:
   if the algorithm returns a negative margin, it also returns a witness quadruple realizing that negativity.
3. **Stability estimator**:
   given `μdiag`, `μoff`, and a noise bound `ε`, output the certified lower bound
   \[
   2(\mu_{\mathrm{off}}-\mu_{\mathrm{diag}})-4\varepsilon
   \]
   for the perturbed mean model.

Suggested Lean signatures:
```lean
def tropMarginAlg {n : ℕ} (W : Matrix (Fin n) (Fin n) ℝ) :
    ℝ × Option (Fin n × Fin n × Fin n × Fin n)

theorem tropMarginAlg_correct
    {n : ℕ} (W : Matrix (Fin n) (Fin n) ℝ) :
    (tropMarginAlg W).1 = tropMargin W

theorem tropMarginAlg_witness
    {n : ℕ} (W : Matrix (Fin n) (Fin n) ℝ)
    (hneg : (tropMarginAlg W).1 < 0) :
    ∃ i j k l, (tropMarginAlg W).2 = some (i,j,k,l) ∧
      AdmissibleQuad i j k l ∧ exSlack W i j k l < 0
```

This is scientifically essential: it turns the theory into a certifying computation.

---

## demo.py Requirements

Your `demo.py` must do all of the following:

1. Generate symmetric Gaussian matrices with separate diagonal/off-diagonal means.
2. Compute empirical estimates of `P(tropMargin ≥ 0)`.
3. Plot the probability against
   \[
   (\mu_{\mathrm{off}}-\mu_{\mathrm{diag}})/(\sigma\sqrt{\log n}).
   \]
4. Display one counterexample witness quadruple when instability occurs.
5. Compare raw Monte Carlo curves with the deterministic certified lower bound from the formal theorem.

This is not cosmetic. It is the experimental arm of the research cycle.

---

## RESEARCH_PAPER.md Requirements

This must be a standalone scientific paper. Someone reading only the paper should understand:

- what tropical Lorentzian stability is,
- why `tropMargin` is the right order parameter,
- what deterministic threshold theorems you proved,
- how they imply finite-size signal/noise criteria,
- what the random Gaussian conjecture predicts,
- what was experimentally observed,
- and what the next mathematical frontier is.

Do not write a code commentary. Write an actual paper.

Suggested title:
**“A Deterministic Threshold Theory for Tropical Lorentzian Stability and Its Random-Matrix Phase Transition”**

---

## ARTICLE.md Requirements

Write this in Scientific American style.

Explain:
- why a matrix can have a hidden “stability phase,”
- why one scalar margin can summarize exponentially many local inequalities,
- how noise can trigger a sharp transition from order to disorder,
- and why this matters in physics, random systems, and learning theory.

**Taboo:** do not focus on formal verification machinery. Focus on the mathematics and the idea of a hidden threshold.

---

## FUTURE_DIRECTIONS.md Requirements

You must provide **3–5 original research directions**, each with:
- a bold title,
- a paragraph of original prose,
- a sentence beginning **“The key insight is…”**
- a sentence beginning **“Why now?”**

At least one direction must bridge to a different domain.

Here are candidate directions you may develop, but write them as original prose, not as a template:

1. **Sharp Threshold Universality**
   Extend from Gaussian ensembles to subgaussian, heavy-tailed, or dependent random matrices.  
   The key insight is that the tropical margin may depend only on extreme-value universality, not entrywise distribution details.  
   Why now? Because the deterministic Lipschitz package makes universality approachable.

2. **Defect Localization and Energy Landscapes**
   Study whether the minimizing quadruple localizes in the critical window, connecting to disordered systems and spin glasses.  
   The key insight is that instability may be carried by a sparse defect rather than a global failure mode.  
   Why now? Because your witness-extracting algorithm can empirically track defect geometry.

3. **Tropical Stability in Random Feature Models**
   Interpret symmetric weight matrices as kernel surrogates or interaction energies in machine learning.  
   The key insight is that tropical Lorentzianity may be an average-case certificate of benign feature interaction.  
   Why now? Because random feature models already exhibit threshold behavior at the same \(\sqrt{\log n}\) scale.

4. **Algebraic Statistics of Tropical Margins**
   Investigate whether `tropMargin` controls concentration, identifiability, or model selection in log-linear and graphical models.  
   The key insight is that exchange slack resembles a discrete four-point inequality central to statistical structure.  
   Why now? Because the deterministic inequalities are already phrased in a language compatible with statistical interaction tensors.

5. **Random Geometry and Curvature Surrogates**
   Explore whether positive tropical margin behaves like a synthetic curvature lower bound for weighted discrete geometries.  
   The key insight is that four-point inequalities often encode curvature-like rigidity.  
   Why now? Because your monotonicity and perturbation theorems give the first robust framework for testing that analogy.

---

## Application Keywords

Include these explicitly in your write-up and metadata-style comments:

- tropical geometry
- Lorentzian polynomials
- phase transition
- random matrix theory
- Gaussian ensemble
- extreme value theory
- statistical physics
- monotone property
- threshold phenomenon
- concentration of measure
- machine learning
- random features
- certified stability
- combinatorial optimization
- four-point inequality

---

## Final Charge

Do not settle for “some probabilistic lemmas.” Produce a theorem package that makes the conjecture inevitable.

The ideal outcome is this:

1. a new scalar invariant `tropMargin`,
2. exact computation on the mean model,
3. deterministic perturbation/threshold theorems,
4. monotonicity linking the subject to phase transitions,
5. a verified certifying algorithm,
6. Monte Carlo evidence for finite-size scaling collapse.

That would not be an extension. That would be the birth of a new average-case tropical stability theory.

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
- **Visualization scripts** — Produce up to 3 self-contained Python scripts
  that visually illustrate the core mathematical concepts discovered. Use
  matplotlib for static plots (heatmaps, curves, surfaces) or plotly for
  interactive charts. Available libraries: numpy, matplotlib, plotly.
  If using matplotlib, the script must call plt.savefig() — the system
  captures the output as a PNG. If using plotly, assign the figure to a
  variable named `fig` — the system captures fig.to_html(). Each script
  must include a comment header explaining what it visualizes and why.
  **CRITICAL: Each visualization script MUST be a single, fully self-contained
  file. Do NOT import from any local modules (algorithms.py, demo.py, etc.).
  Instead, inline all needed functions and classes directly in the script.
  The browser runtime (Pyodide) has no access to local .py files.**
- **Interactive HTML demos** — Produce up to 3 self-contained HTML snippets
  (with inline CSS/JS, no external dependencies) that demonstrate the
  mathematical concepts interactively — sliders, animations, dynamic SVG,
  or canvas drawing. Each demo must be a complete <div> fragment that
  works when inserted into a page. No <html>, <head>, or <body> tags —
  just the content div with its inline styles and scripts.

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
    "visualizations": [ { "name": "...", "code": "# Must be 100% self-contained. Do not import local files. Inline all needed functions directly.", "description": "What this visualizes" } ],
    "interactive_demos": [ { "name": "...", "html": "<div>...</div>", "description": "What this demonstrates" } ],
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

Research domain: Pythagorean
Research mode: prove
