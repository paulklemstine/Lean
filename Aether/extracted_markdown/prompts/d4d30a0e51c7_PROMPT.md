Soli Deo Gloria

## Assignment: Direction 3: Negative Dependence and Rapid Mixing via Directional Log-Concavity

**Mode:** `prove`

Prove genuinely new theorems at the interface of multivariate log-concavity, negative dependence, and Markov-chain mixing. Build explicitly on the catalog results in:

- `Catalog/Pythagorean/HigherOrderLogConcavity.lean`
  - `KFoldLogConcave.mul`
  - `partitionFunctionCoeff_kFoldLogConcave_of_factorization`
- `Pythagorean/MultivariateLogConcavity.lean`
  - `mixedLogConcave_mul`
  - any coefficientwise or derivative-based lemmas available there

Your goal is not to repackage known rapid-mixing statements, but to create a **coefficient-level theory of directional log-concavity as a spectral certificate** for Glauber dynamics on `{0,1}^n`.

The revolutionary target is this: replace the high-level “strongly log-concave polynomial machinery” of Anari–Liu–Oveis Gharan–Vinzant with a direct, formal, coefficient-driven framework in which **higher directional log-concavity quantitatively controls pairwise repulsion, one-site influence, contraction of disagreement, and hence mixing time**. If this works, it opens a new field: **algorithmic negative dependence by local polynomial inequalities**.

---

## Core Mathematical Vision

Let `μ : Fin n → Bool → ℝ≥0∞` be encoded more concretely by a nonnegative weight function on subsets
`w : Finset (Fin n) → ℝ≥0`,
with partition function
\[
Z = \sum_{S \subseteq [n]} w(S),
\]
and generating polynomial
\[
P_w(z_1,\dots,z_n) = \sum_{S \subseteq [n]} w(S)\prod_{i\in S} z_i.
\]

You should define a new formal notion of **discrete directional log-concavity at the coefficient level** for set systems, designed so that for distinct coordinates `i,j`, the mixed discrete Hessian inequality becomes
\[
\Big(\sum_{S \ni i,j} w(S)\Big)\Big(\sum_{S \not\ni i,j} w(S)\Big)
\le
\Big(\sum_{S \ni i,\, j\notin S} w(S)\Big)
\Big(\sum_{S \ni j,\, i\notin S} w(S)\Big),
\]
or an equivalent normalized covariance inequality
\[
\mu(i,j)\le \mu(i)\mu(j).
\]
This is the reversed-FKG phenomenon you want to extract from directional log-concavity.

The breakthrough theorem should not merely state negative correlation. It should show that this local repulsion propagates to **uniform influence bounds**, then to **path coupling contraction** for single-site Glauber dynamics.

---

## Precise Formalization Targets

You must introduce at least one genuinely new definition. A recommended definition is a coefficient-level class capturing pairwise or k-fold directional log-concavity on set weights.

### New definition candidate
```lean
def IsPairwiseDLC {n : ℕ} (w : Finset (Fin n) → ℝ) : Prop :=
  ∀ ⦃i j : Fin n⦄, i ≠ j →
    let a11 := ∑ S in Finset.powers (Finset.univ : Finset (Fin n)),
      if i ∈ S ∧ j ∈ S then w S else 0
    let a10 := ∑ S in Finset.powers (Finset.univ : Finset (Fin n)),
      if i ∈ S ∧ j ∉ S then w S else 0
    let a01 := ∑ S in Finset.powers (Finset.univ : Finset (Fin n)),
      if i ∉ S ∧ j ∈ S then w S else 0
    let a00 := ∑ S in Finset.powers (Finset.univ : Finset (Fin n)),
      if i ∉ S ∧ j ∉ S then w S else 0
    a11 * a00 ≤ a10 * a01
```

A more flexible and likely better formalization is to define the four two-coordinate marginals directly:

```lean
def twoSiteMarginal {n : ℕ} (w : Finset (Fin n) → ℝ)
    (i j : Fin n) (bi bj : Bool) : ℝ := ...

def IsPairwiseDLC {n : ℕ} (w : Finset (Fin n) → ℝ) : Prop :=
  ∀ ⦃i j : Fin n⦄, i ≠ j →
    twoSiteMarginal w i j true true * twoSiteMarginal w i j false false ≤
    twoSiteMarginal w i j true false * twoSiteMarginal w i j false true
```

Then define a one-step Glauber update kernel on subsets or bit-vectors, and a Hamming distance on states.

---

## Theorem Program: at least 3 deep theorems

You must prove at least **three nontrivial theorems** with multi-step proofs using induction, `rcases`, `by_contra`, `field_simp`, and/or substantial `calc` chains. Avoid theorem statements whose only proof is computation.

### Theorem 1: Pairwise DLC implies negative correlation
This is the foundational bridge from polynomial inequalities to probabilistic dependence.

**Mathematical statement**
For any nonnegative weight system `w` with positive partition function, if `w` is pairwise directionally log-concave, then for distinct `i,j`,
\[
\Pr[i,j \in X] \le \Pr[i \in X]\Pr[j \in X].
\]

**Lean 4 target signature**
```lean
theorem IsPairwiseDLC.negatively_correlated
    {n : ℕ} {w : Finset (Fin n) → ℝ}
    (h_nonneg : ∀ S, 0 ≤ w S)
    (hZ : 0 < ∑ S in Finset.powers (Finset.univ : Finset (Fin n)), w S)
    (hDLC : IsPairwiseDLC w) :
    ∀ ⦃i j : Fin n⦄, i ≠ j →
      pairInclusionProb w i j ≤ inclusionProb w i * inclusionProb w j
```

**Why this matters**
This theorem is the first coefficient-level extraction of negative dependence from directional inequalities. It converts an algebraic property of the generating polynomial into a statistical property of the induced measure. That bridge is the load-bearing beam for everything after it.

**Proof strategy**
1. Expand `inclusionProb` and `pairInclusionProb` using the four two-site marginals `a00,a01,a10,a11`.
2. Rewrite
   \[
   \Pr[i]\Pr[j]-\Pr[i,j]
   \]
   over the common denominator `Z^2`.
3. Use `field_simp` and a `calc` chain to show the numerator is exactly
   \[
   a10 a01 - a11 a00 \ge 0.
   \]
Most promising because it isolates the entire theorem into a single 2×2 determinant inequality.

Alternative route:
- Derive the inequality from a coefficient form of
  \[
  \partial_i \partial_j P(1)\, P(1) \le \partial_i P(1)\partial_j P(1),
  \]
  if your catalog lemmas already connect mixed log-concavity to derivative inequalities.

---

### Theorem 2: Pairwise DLC implies bounded one-site influence
This is the first algorithmic theorem: local repulsion controls sensitivity of conditional marginals.

Define the conditional inclusion probability
\[
p_i(\sigma_{-i}) := \Pr[X_i = 1 \mid X_{-i} = \sigma_{-i}],
\]
whenever the conditioning event has positive mass. Then define a discrete influence/Lipschitz constant measuring how much flipping coordinate `j` changes the update probability at `i`.

A tractable formal version is to work with **pair-conditioned ratios** rather than full arbitrary conditioning.

**Mathematical statement**
If `w` is pairwise DLC and all relevant conditional probabilities are defined, then for distinct `i,j`,
\[
\Pr[X_i=1\mid X_j=1] \le \Pr[X_i=1\mid X_j=0].
\]
Equivalently, the influence of `j` on `i` is nonpositive.

**Lean 4 target signature**
```lean
theorem IsPairwiseDLC.conditional_antitone
    {n : ℕ} {w : Finset (Fin n) → ℝ}
    (h_nonneg : ∀ S, 0 ≤ w S)
    (hDLC : IsPairwiseDLC w) :
    ∀ ⦃i j : Fin n⦄, i ≠ j →
      condInclusionProb w i j true ≤ condInclusionProb w i j false
```

A stronger quantitative version is even better:

```lean
theorem IsPairwiseDLC.influence_nonpos
    {n : ℕ} {w : Finset (Fin n) → ℝ}
    (h_nonneg : ∀ S, 0 ≤ w S)
    (hDLC : IsPairwiseDLC w) :
    ∀ ⦃i j : Fin n⦄, i ≠ j →
      siteInfluence w i j ≤ 0
```

**Why this matters**
Negative correlation is static. Influence bounds are dynamic. This theorem is the exact point where probability begins to control Markov-chain motion.

**Proof strategy**
1. Express the two conditional probabilities as
   \[
   \Pr[X_i=1\mid X_j=1]=\frac{a11}{a11+a01},\qquad
   \Pr[X_i=1\mid X_j=0]=\frac{a10}{a10+a00}.
   \]
2. Cross-multiply using positivity from `h_nonneg`; `field_simp` or denominator positivity lemmas will be essential.
3. Reduce to the same determinant inequality `a11 a00 ≤ a10 a01`.

Alternative route:
- Prove Theorem 1 first, then derive this by algebraic manipulation of the covariance identity
  \[
  \Pr[i,j]-\Pr[i]\Pr[j]
  = \Pr[j]\big(\Pr[i\mid j]-\Pr[i]\big).
  \]

---

### Theorem 3: Dobrushin-style contraction from summed directional influences
This is the decisive algorithmic bridge. You may need to define a new coefficient-level quantity:

```lean
def totalInfluenceAt {n : ℕ} (w : Finset (Fin n) → ℝ) (i : Fin n) : ℝ :=
  ∑ j in (Finset.univ.erase i), |siteInfluence w i j|

def hasDobrushinBound {n : ℕ} (w : Finset (Fin n) → ℝ) (c : ℝ) : Prop :=
  ∀ i, totalInfluenceAt w i ≤ c
```

Then prove a coupling contraction theorem for the single-site Glauber dynamics, assuming `c < 1`.

**Mathematical statement**
If the total influence at every site is at most `c < 1`, then under the standard synchronous/path coupling of single-site Glauber dynamics,
\[
\mathbb E[d_H(X_{t+1},Y_{t+1}) \mid X_t,Y_t] \le \left(1-\frac{1-c}{n}\right)d_H(X_t,Y_t).
\]
Hence the chain mixes in \(O\!\left(\frac{n}{1-c}\log n\right)\).

**Lean 4 target signature**
```lean
theorem glauber_pathCoupling_contraction
    {n : ℕ} {w : Finset (Fin n) → ℝ} {c : ℝ}
    (hn : 0 < n)
    (h_nonneg : ∀ S, 0 ≤ w S)
    (hc0 : 0 ≤ c) (hc1 : c < 1)
    (hDob : hasDobrushinBound w c) :
    ∀ x y : Fin n → Bool,
      expectedHammingAfterOneStep w x y ≤
        (1 - (1 - c) / n) * hammingDist x y
```

If a full expectation-valued Markov kernel is too heavy for one cycle, prove the one-step **disagreement propagation inequality** in a deterministic coupling skeleton, then state and computationally validate the full mixing theorem in `RESEARCH_PAPER.md` and `demo.py`.

A weaker but still meaningful formal target:
```lean
theorem glauber_disagreement_contracts_on_adjacent
    {n : ℕ} {w : Finset (Fin n) → ℝ} {c : ℝ}
    ...
    (hxy : hammingDist x y = 1) :
    disagreementBoundAfterOneStep w x y ≤ 1 - (1 - c) / n
```

**Why this matters**
This is the theorem that turns directional log-concavity into an algorithm. It opens approximate sampling and approximate counting from a new angle: verify local polynomial inequalities, get global mixing.

**Proof strategy**
1. Define the maximal coupling for one-site updates and show that when the chosen update site is outside the disagreement set, disagreement can only spread according to the influence matrix.
2. For adjacent states (`hammingDist = 1`), bound expected new disagreements by
   \[
   1 - \frac1n + \frac1n \sum_{j\neq i} |I_{ij}|.
   \]
3. Invoke path coupling to extend from distance 1 to general Hamming distance.

Most promising because it mirrors the classical Dobrushin path but now every coefficient in the argument is extracted from your new DLC/influence framework.

Alternative route:
- Work first on the adjacent-state case only, then use induction on Hamming paths.
- If expectation formalization is cumbersome, formalize a deterministic upper bound function and prove the contraction inequality symbolically.

---

## Stretch Breakthrough Theorem: k-fold DLC gives improved contraction constants

This is the genuinely field-opening target. Do not settle for pairwise DLC alone if the catalog gives you access to higher-order mixed log-concavity.

**Conjectural theorem target**
There exists an explicit monotone function `κ : ℕ → ℝ` with `κ k > 0` for `k ≥ 2` such that if `w` is `k`-fold directionally log-concave, then the Glauber dynamics spectral gap satisfies
\[
\lambda_{\mathrm{gap}} \ge \frac{\kappa(k)}{n}.
\]

**Lean-friendly theorem skeleton**
```lean
theorem kFoldDLC_implies_influence_bound
    {n k : ℕ} {w : Finset (Fin n) → ℝ}
    (hk : 2 ≤ k)
    (h_nonneg : ∀ S, 0 ≤ w S)
    (hDLC : IsKFoldDLC k w) :
    ∃ c : ℝ, c < 1 ∧ hasDobrushinBound w c
```

Even if you cannot complete the full spectral-gap theorem in Lean this cycle, you should formalize and prove a nontrivial finite-step precursor:
- `k`-fold DLC implies pairwise DLC;
- `k`-fold DLC implies stronger upper bounds on `totalInfluenceAt`;
- or `k`-fold DLC is preserved under product/factorization using `KFoldLogConcave.mul`.

This is where the catalog references matter: use them as the engine for closure properties and examples.

---

## Concrete Build on Catalog Theorems

Do not mention the catalog abstractly; use it structurally.

1. **From `KFoldLogConcave.mul`**  
   Build product measures or factorized partition functions whose generating polynomials inherit k-fold log-concavity. Then prove your new coefficient-level property for these examples. This gives a family of explicit test instances for `demo.py`.

2. **From `partitionFunctionCoeff_kFoldLogConcave_of_factorization`**  
   Use this to construct nontrivial distributions arising from partition functions of fermionic or exclusion-type systems. Then extract pairwise DLC or influence bounds on the coefficients. This is your bridge to statistical mechanics.

3. **From `mixedLogConcave_mul`**  
   Show that mixed log-concavity behaves well under multiplication, then transport that closure to your new `IsPairwiseDLC` / `IsKFoldDLC` definitions. A theorem of the form
   ```lean
   theorem IsPairwiseDLC.mul ...
   ```
   would be mathematically useful and computationally valuable for assembling complex models from simple components.

---

## Cross-Domain Connections You Must Make Explicit

At least one theorem and the surrounding exposition must connect this work to another domain.

### Statistical mechanics
Interpret `w(S)` as a canonical partition function for a fermionic/exclusion system. Then pairwise DLC becomes a formal version of **repulsive occupancy**. Rapid Glauber mixing becomes a statement about equilibration of exclusion-type systems.

### Spectral graph theory / Markov semigroups
Your influence matrix is a discrete analogue of a Bakry–Émery curvature or Dobrushin interdependence matrix. Make the connection precise in the paper: directional log-concavity is acting like a **local curvature certificate**.

### Information theory
Negative dependence suppresses mutual information between coordinates. If feasible, define a simple two-site covariance or Bernoulli mutual-information upper bound and prove that pairwise DLC forces it below the independent benchmark. Even a weak theorem here would be novel:
```lean
theorem pairwiseDLC_controls_binary_mutual_proxy ...
```
This would be a striking bridge: polynomial concavity → dependence geometry → information contraction.

### Application keywords
Include these explicitly in your writeup and metadata:
**negative dependence, Glauber dynamics, rapid mixing, spectral gap, Dobrushin uniqueness, directional log-concavity, strongly Rayleigh heuristics, partition functions, fermionic systems, approximate counting, sampling, statistical inference, information contraction, Markov semigroups**

---

## Proof Architecture: 2–3 strategy paths

### Strategy A: 2×2 marginal determinant calculus
Most promising for Lean.
1. Define the four two-site marginals `a00,a01,a10,a11`.
2. Show all target inequalities reduce to `a11 * a00 ≤ a10 * a01`.
3. Use algebraic rewriting and positivity to derive covariance, conditional monotonicity, and influence bounds.

Why best: it localizes the mathematics into finitely many sums and inequalities, ideal for Lean’s `calc`, `ring_nf`, `nlinarith`/ordered-ring lemmas, and `field_simp`.

### Strategy B: Derivative evaluation of generating polynomials
1. Encode probabilities using `P(1)`, `∂ᵢP(1)`, and `∂ᵢ∂ⱼP(1)`.
2. Use catalog mixed-log-concavity lemmas to prove
   \[
   \partial_i\partial_j P(1)\,P(1)\le \partial_i P(1)\partial_j P(1).
   \]
3. Translate derivative inequalities into probabilistic statements.

Why powerful: this ties your work directly to the catalog and scales naturally to k-fold conditions. Use this especially if the multivariate polynomial API is already developed enough.

### Strategy C: Coupling-first / influence-matrix approach
1. Define site influence from conditional update probabilities.
2. Prove pairwise DLC gives sign or magnitude bounds on these influences.
3. Build a path-coupling contraction theorem.

Why important: even if the full polynomial machinery is incomplete, this route produces a verified algorithmic theorem and a practical sampler bound.

---

## Verified Algorithm / Computational Deliverable

You must produce a verified computational method, not just theorem statements.

### Required algorithm
Implement a certified procedure that, given a finite weight system `w` on `{0,1}^n`:
1. computes all two-site marginals,
2. checks the pairwise DLC determinant inequalities,
3. computes empirical or exact pairwise influence bounds,
4. returns a certified upper bound on the Dobrushin constant `c`,
5. if `c < 1`, outputs the proven mixing-rate certificate
   \[
   T_{\mathrm{mix}}(\varepsilon) \le \left\lceil \frac{n}{1-c}\log\frac{n}{\varepsilon}\right\rceil
   \]
   or the exact variant you formalize.

This can be split into:
- a Lean function computing/checking determinant inequalities for finite systems,
- a Python demo that visualizes influences and simulates Glauber trajectories.

### `demo.py` requirements
`demo.py` must:
- generate example weight systems from factorized partition functions and fermionic/exclusion-inspired models,
- compute pairwise DLC scores,
- estimate empirical mixing time of Glauber dynamics,
- compare estimated mixing time against certified `c`,
- plot or print the correlation “higher k-fold depth / stronger DLC ⇒ faster mixing”.

This is essential because your conjecture is falsifiable and algorithmic.

---

## Falsifiable Conjecture with Testable Prediction

You must state at least one explicit conjecture in the Lean-adjacent documentation and test it computationally.

### Recommended conjecture
For every nonnegative weight system `w` on `{0,1}^n`, if the generating polynomial is `k`-fold directionally log-concave for some `k ≥ 2`, then there exists a monotone function `c_k < 1` such that
\[
\sup_i \sum_{j\ne i} |I_{ij}| \le c_k,
\qquad c_k \downarrow \text{ as } k \uparrow.
\]
Hence Glauber mixing is
\[
O\!\left(\frac{n}{1-c_k}\log n\right).
\]

**Clear computational disproof criterion:** find a family of examples with verified `k`-fold DLC but empirically or exactly computed Dobrushin constant not bounded away from 1, or with observed mixing much slower than the predicted scale.

This is an excellent conjecture because it can fail in a measurable way.

---

## Deliverables (MANDATORY)

You must produce **all** of the following:

### 1. Lean development
A Lean file with:
- at least one novel definition,
- at least 3 nontrivial theorems,
- deep proofs using induction / `rcases` / `by_contra` / `field_simp` / multi-step `calc`,
- minimal `sorry`.

### 2. `FUTURE_DIRECTIONS.md`
Include **3–5 original research directions**, each with the exact phrases:
- **“The key insight is...”**
- **“Why now?”**
At least one direction must bridge to a different domain, such as information theory, quantum/statistical mechanics, or spectral geometry.

Suggested future directions:
- k-fold DLC and modified log-Sobolev inequalities
- deterministic approximation algorithms from DLC certificates
- entropy decay and information contraction under repulsive Glauber dynamics
- tropical or nonarchimedean analogues of negative dependence
- continuous-spin analogues via Hessian comparison

### 3. `RESEARCH_PAPER.md`
A standalone scientific paper explaining:
- the definitions,
- the main theorems,
- why coefficient-level DLC is a new route to rapid mixing,
- how it relates to Anari–Liu–Oveis Gharan–Vinzant,
- what the conjectural hierarchy suggests next.

The paper must be readable with no access to code.

### 4. `ARTICLE.md`
Write this in **Scientific American style**:
- engaging,
- broad audience,
- focused on the ideas and significance,
- **taboo:** do not focus on formal verification machinery.

### 5. Verified algorithm / computational method
As specified above.

### 6. `demo.py`
Interactive or script-based demonstration of the theory on explicit examples.

---

## Final Standard for Success

A successful outcome is not “we formalized a known negative-correlation lemma.” A successful outcome is:

- a new coefficient-level notion of directional log-concavity for finite measures on `{0,1}^n`,
- a formal bridge from that notion to negative dependence,
- a formal bridge from negative dependence to influence contraction,
- a verified computational certificate for rapid mixing,
- and a clear conjectural hierarchy connecting higher-order directional log-concavity to spectral gaps.

If you achieve this, you will have created a new research lane: **local polynomial concavity as an algorithmic certificate for sampling and counting**. That is not an incremental extension. That is a blueprint for a field.

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
