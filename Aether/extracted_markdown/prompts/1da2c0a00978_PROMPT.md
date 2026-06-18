## Assignment: Conjecture 3: Coefficient Growth Rate Under Iterated Transfer

**Mode: prove**

Aristotle, do not treat this as an isolated coefficient estimate. Treat it as the formal seed of a verified asymptotic theory for local functorial transfer. The real objective is to turn the vague phrase “coefficient growth under symmetric-power transfer” into a Lean-certified mechanism that links:
- representation-theoretic transfer at unramified places,
- combinatorics of elementary symmetric polynomials,
- tropical/convex control of logarithmic coefficient growth,
- and algorithmic bounds relevant to automorphic \(L\)-function computation.

The target is not a toy upper bound. The target is a reusable formal framework in which iterated transfer creates a discrete Newton polytope whose support function controls coefficient size.

---

## Core Mathematical Objective

Let
\[
P_n(T;\alpha,\beta) := \prod_{j=0}^{n}\left(1-\alpha^{\,n-j}\beta^{\,j}T\right)
= \sum_{k=0}^{n+1} c_{n,k}(\alpha,\beta)\, T^k.
\]
This is the local Euler factor of the symmetric \(n\)-th power transfer of an unramified \(\mathrm{GL}_2\) parameter \((\alpha,\beta)\).

Your central theorem should formalize a nontrivial coefficient-growth bound of the form:
\[
\max_{0\le k\le n+1} |c_{n,k}(\alpha,\beta)|
\le C(n)\, M^{n(n+1)/2},
\qquad M:=\max(|\alpha|,|\beta|)\ge 1,
\]
with an explicit combinatorial choice of \(C(n)\), ideally \(C(n)\le \binom{n+1}{\lfloor (n+1)/2\rfloor}\), and preferably sharpened to a \(k\)-dependent estimate
\[
|c_{n,k}(\alpha,\beta)| \le \binom{n+1}{k}\, M^{k n - k(k-1)/2}.
\]
This sharper exponent is the real structural theorem; the global maximum bound then follows immediately.

The reason this is a breakthrough direction is that it identifies the coefficient profile as a **weight polytope phenomenon**: the exponent \(k n-k(k-1)/2\) is the maximal weight sum obtained by choosing \(k\) roots among \(\alpha^n,\alpha^{n-1}\beta,\dots,\beta^n\). This is not merely a bound; it is a formal bridge from Satake parameters to convex-geometric growth laws.

---

## Precise Theorem Targets

You should prove at least **3 substantial theorems**, with multi-step proofs using induction / `rcases` / `by_contra` / `field_simp` / structured `calc`. Avoid any theorem whose substance collapses to `norm_num` or `rfl`.

### Theorem 1: Sharp coefficient-wise growth bound
For complex parameters \(\alpha,\beta\), define the coefficient \(c_{n,k}\) of the symmetric-power Euler factor. Prove:
\[
\forall n\ge 0,\ \forall k\le n+1,\ 
|c_{n,k}(\alpha,\beta)|
\le \binom{n+1}{k}\, M^{k n - k(k-1)/2},
\quad M:=\max(|\alpha|,|\beta|),\ M\ge 1.
\]

### Lean 4 type signature sketch
```lean
theorem symmEuler_coeff_bound
  (α β : ℂ) (n k : ℕ)
  (hk : k ≤ n + 1)
  (hM : 1 ≤ max ‖α‖ ‖β‖) :
  ‖symmEulerCoeff α β n k‖
    ≤ (Nat.choose (n + 1) k : ℝ) *
      (max ‖α‖ ‖β‖) ^ (k * n - k * (k - 1) / 2) := by
  ...
```

You may need to define `symmEulerCoeff` as the coefficient of the polynomial
\[
\prod_{j=0}^n (X - \alpha^{n-j}\beta^j)
\]
or equivalently of
\[
\prod_{j=0}^n (1 - \alpha^{n-j}\beta^j T).
\]
Choose the representation that best aligns with Mathlib’s polynomial API.

---

### Theorem 2: Maximum coefficient norm bound
Derive:
\[
\forall n\ge 0,\quad
\max_{0\le k\le n+1}|c_{n,k}(\alpha,\beta)|
\le \left(\max_{0\le k\le n+1}\binom{n+1}{k}\right) M^{n(n+1)/2}.
\]
Then identify
\[
\max_k \binom{n+1}{k} = \binom{n+1}{\lfloor (n+1)/2\rfloor}
\]
to obtain an explicit \(C(n)\).

### Lean 4 type signature sketch
```lean
theorem symmEuler_maxCoeff_bound
  (α β : ℂ) (n : ℕ)
  (hM : 1 ≤ max ‖α‖ ‖β‖) :
  maxCoeffNorm (symmEulerPoly α β n)
    ≤ (Nat.choose (n + 1) ((n + 1) / 2) : ℝ) *
      (max ‖α‖ ‖β‖) ^ (n * (n + 1) / 2) := by
  ...
```

If `maxCoeffNorm` does not already exist in the needed form, define it as a new concept:
```lean
def maxCoeffNorm (P : Polynomial ℂ) : ℝ := ...
```
This satisfies the “novel definitions” requirement and creates reusable infrastructure.

---

### Theorem 3: Log-convex / tropical upper envelope theorem
Define the exponent profile
\[
E(n,k) := k n - \frac{k(k-1)}{2}.
\]
Prove that \(k \mapsto E(n,k)\) is concave on \(\{0,\dots,n+1\}\), and that the logarithmic coefficient bound is controlled by the tropical polynomial
\[
\operatorname{Trop}_n(k) := \log \binom{n+1}{k} + E(n,k)\log M.
\]
Formally, show a discrete convexity or monotonicity statement implying the maximum exponent occurs at \(k=n+1\), giving \(E(n,n+1)=n(n+1)/2\), while the binomial factor is maximized centrally.

This is your cross-domain theorem: it links automorphic local factors to **tropical / discrete convex geometry**.

### Lean 4 type signature sketch
```lean
def transferExponent (n k : ℕ) : ℕ :=
  k * n - k * (k - 1) / 2

theorem transferExponent_concave
  (n : ℕ) {k : ℕ}
  (hk : k + 2 ≤ n + 1) :
  transferExponent n k + transferExponent n (k + 2)
    ≤ 2 * transferExponent n (k + 1) := by
  ...
```

and a coefficient envelope theorem such as
```lean
theorem logCoeff_bound_tropical
  (α β : ℂ) (n k : ℕ)
  (hk : k ≤ n + 1)
  (hM : 1 < max ‖α‖ ‖β‖) :
  Real.log ‖symmEulerCoeff α β n k‖
    ≤ Real.log (Nat.choose (n + 1) k) +
      (transferExponent n k : ℝ) * Real.log (max ‖α‖ ‖β‖) := by
  ...
```
where you handle zero-coefficient edge cases carefully, possibly with a positive-part or nonzero hypothesis.

---

## New Definitions You Should Introduce

At least one genuinely new concept should be defined and used in proofs. Recommended options:

1. **Transfer exponent profile**
```lean
def transferExponent (n k : ℕ) : ℕ := ...
```
This captures the maximal \(M\)-weight of a \(k\)-fold elementary symmetric monomial in the root multiset \(\{\alpha^n,\alpha^{n-1}\beta,\dots,\beta^n\}\).

2. **Maximum coefficient norm**
```lean
def maxCoeffNorm (P : Polynomial ℂ) : ℝ := ...
```

3. **Tropical transfer envelope**
```lean
def tropicalTransferEnvelope (M : ℝ) (n k : ℕ) : ℝ :=
  Real.log (Nat.choose (n + 1) k) + (transferExponent n k : ℝ) * Real.log M
```
This is conceptually powerful: it packages the coefficient-growth problem as a tropical support-function estimate.

These are not cosmetic. They create a reusable formal language for future work on exterior powers, Rankin–Selberg products, and plethysm.

---

## Proof Architecture: 3 Viable Strategies

### Strategy A: Elementary symmetric polynomial expansion via subset combinatorics
This is the most promising route.

**Step 1.** Express \(c_{n,k}\) as a signed sum over \(k\)-element subsets:
\[
c_{n,k} = (-1)^k \sum_{0\le j_1<\cdots<j_k\le n}
\alpha^{\sum (n-j_t)}\beta^{\sum j_t}.
\]

**Step 2.** Bound each summand by \(M^{\sum(n-j_t)+\sum j_t}=M^{kn}\) if crude, then sharpen by exploiting the actual maximal subset weight for the ordered roots. The sharper estimate comes from selecting the \(k\) largest exponents among \(n,n-1,\dots,0\), giving
\[
n+(n-1)+\cdots+(n-k+1)=kn-\frac{k(k-1)}2.
\]

**Step 3.** Apply the triangle inequality and count subsets with `Nat.choose (n+1) k`.

Why this is best: it matches Lean well, reduces the problem to finite-set combinatorics, and exposes the exact exponent profile.

---

### Strategy B: Induction on \(n\) using the recurrence for adjoining one new Satake root
Write
\[
P_{n+1}(T)= (1-\alpha^{n+1}T)\cdot \prod_{j=1}^{n+1}(1-\alpha^{n+1-j}\beta^jT),
\]
or more naturally derive a recursion between \(P_{n+1}\) and \(P_n\) after reindexing.

**Step 1.** Prove a coefficient recurrence:
\[
c_{n+1,k}=c'_{n,k} - \alpha^{n+1} c'_{n,k-1},
\]
where \(c'_{n,k}\) corresponds to the shifted parameter multiset.

**Step 2.** Bound recursively using induction and Pascal’s identity:
\[
\binom{n+2}{k}=\binom{n+1}{k}+\binom{n+1}{k-1}.
\]

**Step 3.** Verify the exponent profile satisfies the needed compatibility:
\[
E(n+1,k)\ge E(n,k),\qquad
E(n+1,k)\ge (n+1)+E(n,k-1).
\]

Why this is powerful: it yields a structurally elegant proof and may generalize to arbitrary transfer constructions where roots are adjoined iteratively.

---

### Strategy C: Newton polytope / tropical majorization
Interpret each coefficient as an elementary symmetric polynomial in the root multiset \(r_j=\alpha^{n-j}\beta^j\).

**Step 1.** Associate to the multiset the exponent points \((n-j,j)\) on a line segment in \(\mathbb{N}^2\).

**Step 2.** Show that the maximal \(M\)-weight of a \(k\)-fold monomial equals the support function of the \(k\)-th hypersimplex slice of that segment configuration, producing exactly \(E(n,k)\).

**Step 3.** Deduce coefficient bounds by combining support-function control with counting of lattice points.

Why this matters: it opens the door to a general theorem for \(\mathrm{GL}_m\) highest-weight transfers, where coefficient growth is governed by weight polytopes and tropicalization. Harder to formalize fully, but extremely visionary.

---

## Cross-Domain Connections You Must Make Explicit

This project must not remain trapped in local algebra. Build at least one theorem or section that explicitly connects to another field.

### 1. Tropical geometry / discrete convex analysis
The function \(E(n,k)\) is a tropical support function. The coefficient-growth problem becomes a statement about upper hulls of a discrete Newton polygon. This is the right language for future generalization to plethysm and tensor-product Euler factors.

### 2. Analytic number theory
Coefficient bounds for local Euler factors feed directly into:
- truncation error bounds in partial Euler products,
- growth control for logarithmic derivatives,
- explicit complexity estimates for numerical evaluation of symmetric-power \(L\)-functions.

### 3. Statistical mechanics / partition functions
The coefficient \(c_{n,k}\) is a weighted sum over \(k\)-particle configurations chosen from energy levels \(0,1,\dots,n\). The exponent profile \(E(n,k)\) is the maximal energy occupancy bound. This analogy may inspire future formal work on transfer operators as partition functions.

### 4. Representation theory
The roots \(\alpha^{n-j}\beta^j\) are weights of \(\mathrm{Sym}^n\) of the standard \(2\)-dimensional representation. Your coefficient bound is therefore a formal theorem about **weight multiplicity growth under functorial transfer**.

---

## Stronger Theorem You Should Attempt If Feasible

If Lean infrastructure permits, prove a symmetry-refined statement under \(|\alpha\beta|=1\):
\[
|c_{n,k}| = |c_{n,n+1-k}|
\]
up to a predictable normalization, or at least prove a palindromic relation
\[
c_{n,n+1-k} = (-1)^{n+1} (\alpha\beta)^{n(n+1)/2}\,\overline{?}\, c_{n,k}
\]
in an algebraic form without conjugation if working over a commutative ring. This would reveal a local functional-equation shadow.

Possible Lean sketch:
```lean
theorem symmEuler_coeff_reciprocal
  (α β : ℂ) (n k : ℕ)
  (hk : k ≤ n + 1) :
  symmEulerCoeff α β n (n + 1 - k)
    = (-1)^(n + 1) *
      (α * β)^(n * (n + 1) / 2) *
      symmEulerCoeff (α⁻¹) (β⁻¹) n k := by
  ...
```
Even a weaker polynomial reciprocity theorem would be scientifically valuable.

---

## Falsifiable Conjecture and Computational Test

You must include at least one explicit conjecture with a numerical disproof protocol.

### Conjecture A: Sharpness along diagonal Satake parameters
For \(\alpha=\beta=M>1\),
\[
\max_k |c_{n,k}| = \binom{n+1}{\lfloor (n+1)/2\rfloor} M^{\lfloor (n+1)/2\rfloor n}
\]
after the obvious simplification of the factor, and the proven upper bound is asymptotically sharp up to subexponential factors.

**Test:** compute exact coefficients for \(M=1.1,1.5,2.0\), \(2\le n\le 10\), compare the ratio
\[
\frac{\max_k |c_{n,k}|}{\binom{n+1}{\lfloor (n+1)/2\rfloor} M^{n(n+1)/2}}.
\]
If the ratio decays exponentially or oscillates wildly, the proposed sharpness picture is false.

### Conjecture B: Unimodality of coefficient norms
For real \( \alpha,\beta>0 \), the sequence \(k\mapsto |c_{n,k}|\) is unimodal.

**Test:** for sampled \((\alpha,\beta)\) and \(n\le 20\), detect violations of unimodality.

This conjecture is important because it predicts a hidden log-concavity phenomenon tied to real-rootedness and may connect to Pólya frequency sequences.

---

## Algorithmic Deliverable

You must provide a **verified algorithm** for computing and bounding coefficients.

Recommended formal/computational method:
1. Generate the root list \([\alpha^n,\alpha^{n-1}\beta,\dots,\beta^n]\).
2. Build the polynomial by folding \((1-rT)\).
3. Extract coefficients.
4. Compute the theoretical bound
   \[
   B(n,k,M)=\binom{n+1}{k} M^{E(n,k)}.
   \]
5. Verify coefficientwise inequalities numerically for sample inputs.

The Lean side should verify the formula and correctness of the bound; `demo.py` should visualize:
- coefficient profiles,
- the tropical envelope,
- growth in \(n\),
- and the ratio of actual coefficient norm to the upper bound.

---

## Lean 4 Formalization Guidance

You likely want definitions along these lines:

```lean
def symmEulerRoots (α β : ℂ) (n : ℕ) : List ℂ :=
  (List.range (n + 1)).map (fun j => α^(n - j) * β^j)

def symmEulerPoly (α β : ℂ) (n : ℕ) : Polynomial ℂ :=
  (symmEulerRoots α β n).foldr
    (fun r P => (1 - C r * X) * P) 1

def symmEulerCoeff (α β : ℂ) (n k : ℕ) : ℂ :=
  (symmEulerPoly α β n).coeff k

def transferExponent (n k : ℕ) : ℕ :=
  k * n - k * (k - 1) / 2

def maxCoeffNorm (P : Polynomial ℂ) : ℝ :=
  sSup {r | ∃ k, r = ‖P.coeff k‖}
```

You may prefer `Finset` over `List` for subset expansions. A `Finset`-indexed elementary symmetric sum may make the coefficient theorem cleaner.

Useful proof ingredients to search for in Mathlib:
- coefficients of products of linear factors,
- bounds on norms of sums/products,
- `Nat.choose`,
- finite set sums over subsets,
- polynomial coefficient APIs,
- real powers / norms,
- big operators over `Finset`.

If the exact catalog theorem names are not obvious, build your own local lemmas cleanly and make them reusable.

---

## Why This Would Be Revolutionary

If formalized correctly, this becomes more than a bound for \(\mathrm{Sym}^n(\mathrm{GL}_2)\). It becomes the prototype of a machine-verifiable theory of **local transfer complexity**:
- how coefficient heights evolve under representation-theoretic operations,
- how Newton polytopes encode automorphic local data,
- and how tropicalized weight geometry predicts analytic growth.

That opens a field:
- certified algorithms for automorphic \(L\)-function local factors,
- formal asymptotic bounds for higher-rank transfers,
- verified experiments on functoriality,
- and eventually a bridge from Lean formalization to computational Langlands.

This is exactly the kind of theorem that makes a representation theorist, an analytic number theorist, and a tropical geometer all stop and say: “I did not expect those structures to line up this cleanly.”

---

## Mandatory Deliverables

You must produce **all** of the following:

1. **Lean file** with at least 3 nontrivial theorems, using deep proof tactics.
2. **A structured `FUTURE_DIRECTIONS.md`** containing 3–5 falsifiable scientific hypotheses, each with a concrete computational test.
3. **A standalone `RESEARCH_PAPER.md`** explaining the theorem, proof architecture, significance, and next questions so that a reader without the code fully understands the discovery.
4. **An accessible `ARTICLE.md`** in Scientific American style for broad audiences.
5. **A verified algorithm or computational method** for computing the Euler-factor coefficients and their bounds.
6. **A `demo.py`** that interactively computes coefficients for sample \((\alpha,\beta,n)\), plots actual coefficient norms against the tropical/combinatorial upper envelope, and tests the conjectures above.

---

## Application Keywords

automorphic \(L\)-functions, Satake parameters, symmetric power transfer, Euler factors, coefficient height, Newton polytope, tropical geometry, discrete convexity, local Langlands, representation theory, combinatorial asymptotics, verified numerics, formalized analytic number theory, partition functions, log-concavity, functoriality, computational Langlands

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
hypotheses. Each direction must be a falsifiable claim or conjecture that
can be proved, disproved, or tested — not a vague "we could explore X."
Format: "Conjecture: [precise statement]. Test: [what would confirm or
refute it]. Impact: [what this would enable if true]." Every hypothesis
should be daring enough to matter and specific enough to fail.

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

Research domain: Speculative
Research mode: prove
