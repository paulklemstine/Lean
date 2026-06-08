Soli Deo Gloria

## Assignment: Direction 2: Density Heuristics via the Circle Method

**Mode:** prove

Prove genuinely new, non-trivial theorems that turn the existing local-admissibility infrastructure for the three-cubes problem into a formal analytic framework for density heuristics. Do not stop at restating heuristic folklore: build a mathematically meaningful bridge from local congruence obstructions to asymptotic counting models, with explicit constants, monotonic approximation schemes, and a verified computational pipeline.

This direction is promising because the catalog already contains the arithmetic skeleton:
- `ThreeCubeLocalAdmissible` in `Algebra/SumThreeCubes/Defs.lean`
- `sumThreeCubesRep_implies_everywhereLocallyAdmissible` in `Algebra/SumThreeCubes/LocalGlobal.lean`

Your task is to supply the analytic flesh: define singular-series-style local factors from these admissibility counts, prove structural theorems about them, and extract a rigorous density model that can be tested computationally. Even if the full Hardy–Littlewood asymptotic is too ambitious in one cycle, a formalized approximation theory for the singular series and its positivity would already be a breakthrough: it would be the first certified framework connecting formal local-global arithmetic to circle-method style prediction for a genuinely difficult Diophantine problem.

---

## Central theorem target

Let
\[
R_k(N) := \#\{(x,y,z)\in \mathbb Z^3 : |x|,|y|,|z|\le N,\ x^3+y^3+z^3=k\}.
\]
For admissible \(k\) (that is, \(k \not\equiv 4,5 \pmod 9\)), the Hardy–Littlewood philosophy predicts
\[
R_k(N) \sim c_k\,N^{1/3},
\]
where \(c_k = \mathfrak S(k)\mathfrak J(k)\) is the product of a singular series and singular integral.

You should **not** merely encode this as a conjecture. Instead, formalize and prove the parts that are already within reach from the catalog:

1. a precise local-density definition of the singular series factors using admissible residue counts;
2. compatibility of these factors with actual global representations;
3. positivity and stabilization results for truncated Euler products under admissibility hypotheses;
4. a rigorously verified computational method for approximating the predicted constant.

The ideal end-state is a Lean development that makes the conjectural asymptotic mathematically legible and algorithmically testable.

---

## New definitions you should introduce

Define at least one genuinely new concept absent from the catalog. The following are strong candidates.

### 1. Local cubic representation density
For \(k : \mathbb Z\) and \(n : \mathbb N\), define the normalized count
\[
\delta_k(n) := \frac{1}{n^2}\#\{(a,b,c)\in (\mathbb Z/n\mathbb Z)^3 : a^3+b^3+c^3 \equiv k \pmod n\}.
\]
This is the natural local density for a codimension-one cubic congruence in three variables.

Suggested Lean-facing structure:
```lean
def threeCubeResidueCount (k : ℤ) (n : ℕ) : ℕ := ...
def threeCubeLocalDensity (k : ℤ) (n : ℕ) : ℚ := ...
```

### 2. Admissibility Euler factor
Define the local admissibility ratio
\[
\alpha_k(n) := \frac{\#A_k(n)}{n},
\]
where \(A_k(n)\) is the set of residues \(r \in \mathbb Z/n\mathbb Z\) such that \(r \equiv k - x^3 - y^3 \pmod n\) for some \(x,y\), or equivalently the catalog’s admissibility set specialized to three cubes.

Suggested Lean-facing structure:
```lean
def threeCubeAdmissibleResidues (k : ℤ) (n : ℕ) : Finset (ZMod n) := ...
def threeCubeAdmissibilityRatio (k : ℤ) (n : ℕ) : ℚ := ...
```

### 3. Truncated singular series
For a finite set of primes \(S\), define
\[
\mathfrak S_S(k) := \prod_{p\in S} \sigma_p(k),
\]
where \(\sigma_p(k)\) is built from \(p^m\)-level densities or admissibility ratios.

Suggested Lean-facing structure:
```lean
def localSigma (k : ℤ) (p m : ℕ) : ℚ := ...
def truncatedSingularSeries (k : ℤ) (P : Finset ℕ) : ℚ := ...
```

If a full prime-power formalization is too heavy, begin with a squarefree proxy
\[
\mathfrak S^{\mathrm{sf}}_P(k) := \prod_{p \le P} \alpha_k(p),
\]
and prove that global representations force every factor to be positive. This is still mathematically meaningful and computationally powerful.

---

## Precise theorem statements to formalize

You must prove at least 3 substantial theorems. Here are the highest-value targets.

### Theorem 1: Global representation implies positivity of every local density factor
If \(k\) has an integer representation as a sum of three cubes, then every local congruence density is positive.

Mathematical statement:
\[
(\exists x\,y\,z\in \mathbb Z,\ x^3+y^3+z^3=k)
\;\Longrightarrow\;
\forall n\ge 1,\ \delta_k(n) > 0.
\]

Suggested Lean 4 signature:
```lean
theorem threeCubeRep_implies_localDensity_pos
    (k : ℤ)
    (hrep : ∃ x y z : ℤ, x^3 + y^3 + z^3 = k) :
    ∀ n : ℕ, 0 < n → 0 < threeCubeLocalDensity k n
```

Why this matters: it upgrades `sumThreeCubesRep_implies_everywhereLocallyAdmissible` from a yes/no local obstruction statement to a quantitative positivity theorem. This is exactly the first step toward a singular series.

---

### Theorem 2: Multiplicativity of local counts for coprime moduli
The local density should factor over coprime moduli by CRT.

Mathematical statement:
\[
\gcd(m,n)=1 \Longrightarrow
\delta_k(mn)=\delta_k(m)\delta_k(n).
\]

Depending on normalization, you may first prove the count-level version
\[
\#\mathrm{Sol}(mn)=\#\mathrm{Sol}(m)\#\mathrm{Sol}(n),
\]
then divide by \((mn)^2\).

Suggested Lean 4 signature:
```lean
theorem threeCubeResidueCount_mul_of_coprime
    (k : ℤ) {m n : ℕ}
    (hm : 0 < m) (hn : 0 < n) (hcop : Nat.Coprime m n) :
    threeCubeResidueCount k (m * n)
      = threeCubeResidueCount k m * threeCubeResidueCount k n
```

and then
```lean
theorem threeCubeLocalDensity_mul_of_coprime
    (k : ℤ) {m n : ℕ}
    (hm : 0 < m) (hn : 0 < n) (hcop : Nat.Coprime m n) :
    threeCubeLocalDensity k (m * n)
      = threeCubeLocalDensity k m * threeCubeLocalDensity k n
```

Why this matters: multiplicativity is the algebraic engine behind Euler products. Without it, there is no singular series worth the name.

---

### Theorem 3: Admissibility modulo 9 forces nonvanishing of the squarefree truncated singular series
For \(k \not\equiv 4,5 \pmod 9\), all local admissibility factors at the catalog-supported level are nonzero, hence every finite truncation is positive.

Mathematical statement:
\[
k \not\equiv 4,5 \pmod 9
\Longrightarrow
\forall P,\ \mathfrak S^{\mathrm{sf}}_P(k) > 0.
\]

Suggested Lean 4 signature:
```lean
theorem truncatedSingularSeries_pos_of_mod9_admissible
    (k : ℤ)
    (hk : ¬ (k % 9 = 4 ∨ k % 9 = 5)) :
    ∀ P : ℕ, 0 < truncatedSingularSeries k ((Finset.range (P+1)).filter Nat.Prime)
```

A more precise and likely more tractable variant is:
```lean
theorem localSigma_pos_of_everywhereLocallyAdmissible
    (k : ℤ)
    (hloc : ∀ n : ℕ, 0 < n → ThreeCubeLocalAdmissible k n) :
    ∀ p : ℕ, Nat.Prime p → 0 < localSigma k p 1
```

Why this matters: this is the first rigorous statement that the formal local theory supplies positive Euler factors for the predicted asymptotic constant.

---

### Theorem 4: Monotone lower bounds for the singular-series proxy
Construct a computable lower-bound sequence from finite local data and prove monotonicity.

Mathematical statement:
If each local factor lies in \([0,1]\), then
\[
L_P(k) := \prod_{p\le P} \ell_p(k)
\]
is monotone nonincreasing and nonnegative, where \(\ell_p(k)\) is a verified lower bound for \(\sigma_p(k)\).

Suggested Lean 4 signature:
```lean
theorem truncatedSingularSeries_mono
    (k : ℤ) :
    Monotone fun P : ℕ =>
      truncatedSingularSeriesLower k ((Finset.range (P+1)).filter Nat.Prime)
```

Why this matters: even absent full convergence, monotone computable bounds turn heuristic constants into certified numerical objects.

---

### Theorem 5: Cross-domain theorem linking local density to probability
Interpret the local density as the exact probability that three independent uniform residues solve the cubic congruence modulo \(n\).

Mathematical statement:
\[
\delta_k(n)
=
\Pr_{a,b,c\sim \mathrm{Unif}(\mathbb Z/n\mathbb Z)}
[a^3+b^3+c^3\equiv k \pmod n].
\]

Suggested Lean 4 signature:
```lean
theorem threeCubeLocalDensity_eq_uniformProb
    (k : ℤ) (n : ℕ) (hn : 0 < n) :
    threeCubeLocalDensity k n
      = uniformThreeCubeProb k n
```

Why this matters: this creates a direct bridge between analytic number theory and probability/statistical mechanics. The singular series becomes a product of local probabilities, making “independence of local constraints” a precise testable philosophy rather than a slogan.

---

## Most promising proof architecture

### Strategy A: CRT-first algebraic route to an Euler product proxy
This is the most promising path.

1. **Define residue solution sets cleanly over `ZMod n`.**
   Represent solutions as a finite set of triples `(a,b,c) : ZMod n × ZMod n × ZMod n` satisfying the cubic congruence. This lets you count with `Fintype.card` or `Finset.card`, and use extensional reasoning rather than ad hoc modular arithmetic.

2. **Prove multiplicativity using Chinese remainder theory.**
   Use the ring equivalence
   \[
   \mathbb Z/(mn)\mathbb Z \cong \mathbb Z/m\mathbb Z \times \mathbb Z/n\mathbb Z
   \]
   for coprime \(m,n\), transport the cubic equation across the equivalence, and deduce a bijection of solution sets. This is where the deep proof tactics should appear: `rcases` on CRT representatives, multi-step `calc`, and nontrivial rewriting in product rings.

3. **Define truncated singular series and prove positivity from local admissibility.**
   Once multiplicativity is established, local-global catalog theorems imply positivity of each factor whenever a global representation exists. Then finite products are positive. This yields a rigorously certified Euler-product proxy.

Why this is best: it leverages existing catalog arithmetic directly and avoids the hardest analytic estimates while still producing genuinely new mathematics.

---

### Strategy B: Prime-power lifting and Hensel-style stabilization
This is more ambitious and potentially revolutionary.

1. **Study the counts modulo \(p^m\) and prove monotonicity/stabilization.**
   For primes \(p \neq 3\), investigate whether every nonsingular solution modulo \(p\) lifts to solutions modulo \(p^m\), giving a recursion for local counts.

2. **Define a prime-adic local factor as a limit.**
   Show that the normalized counts form a Cauchy or eventually constant sequence in \(\mathbb Q\) or \(\mathbb R\), and define
   \[
   \sigma_p(k)=\lim_{m\to\infty}\delta_k(p^m).
   \]

3. **Build the singular series from these prime-adic factors.**
   Even proving existence for a restricted set of \(k\) or primes would be a major advance.

Why it is powerful: this moves from a squarefree heuristic to a true \(p\)-adic density theory, much closer to the classical circle method.

Risk: prime-power lifting in Lean may be technically heavy if the current catalog has not yet built enough p-adic or Henselian infrastructure for this specific cubic.

---

### Strategy C: Harmonic-analysis formulation via finite Fourier expansion
This is conceptually beautiful and opens the strongest cross-domain bridge.

1. **Express the local count as a finite Fourier coefficient.**
   Over `ZMod n`, use additive characters to write
   \[
   \#\mathrm{Sol}(n)
   =
   \frac{1}{n}\sum_{t \in \mathbb Z/n\mathbb Z}
   e_n(-tk)\Big(\sum_x e_n(tx^3)\Big)^3.
   \]

2. **Interpret major/minor arcs in the finite setting.**
   Even without full circle-method estimates, the decomposition of the count into Fourier modes is already a rigorous finite harmonic-analysis theorem.

3. **Relate Fourier mass concentration to admissibility and density fluctuations.**
   This yields a bridge to signal processing and probability.

Why it matters: this is the conceptual embryo of the circle method inside finite algebra. It could become the formal foundation for future major/minor arc work.

Risk: additive characters over `ZMod n` and complex exponentials may require more setup than the CRT route.

---

## Recommended execution plan

1. **First prove Theorem 2** (multiplicativity).  
   This is the structural backbone.

2. **Then prove Theorem 1** (global representation ⇒ local density positivity).  
   This upgrades the catalog theorem quantitatively.

3. **Then define and analyze truncated singular series proxies** and prove positivity/monotonicity theorems (Theorem 3 or 4).

4. **If time permits, add the probability theorem** (Theorem 5) or a finite Fourier decomposition lemma.  
   That gives the strongest cross-domain impact.

---

## Lean-specific formalization targets

You should aim for theorem statements close to the following.

```lean
def threeCubeResidueSet (k : ℤ) (n : ℕ) :
    Finset ((ZMod n) × (ZMod n) × (ZMod n)) := ...

def threeCubeResidueCount (k : ℤ) (n : ℕ) : ℕ :=
  (threeCubeResidueSet k n).card

def threeCubeLocalDensity (k : ℤ) (n : ℕ) : ℚ :=
  (threeCubeResidueCount k n : ℚ) / (n : ℚ)^2

theorem threeCubeRep_implies_localDensity_pos
    (k : ℤ)
    (hrep : ∃ x y z : ℤ, x^3 + y^3 + z^3 = k) :
    ∀ n : ℕ, 0 < n → 0 < threeCubeLocalDensity k n := ...

theorem threeCubeResidueCount_mul_of_coprime
    (k : ℤ) {m n : ℕ}
    (hm : 0 < m) (hn : 0 < n) (hcop : Nat.Coprime m n) :
    threeCubeResidueCount k (m * n)
      = threeCubeResidueCount k m * threeCubeResidueCount k n := ...

theorem threeCubeLocalDensity_mul_of_coprime
    (k : ℤ) {m n : ℕ}
    (hm : 0 < m) (hn : 0 < n) (hcop : Nat.Coprime m n) :
    threeCubeLocalDensity k (m * n)
      = threeCubeLocalDensity k m * threeCubeLocalDensity k n := ...

def localSigmaSqFree (k : ℤ) (p : ℕ) : ℚ := threeCubeLocalDensity k p

def truncatedSingularSeries (k : ℤ) (P : Finset ℕ) : ℚ :=
  ∏ p in P, localSigmaSqFree k p

theorem truncatedSingularSeries_pos_of_rep
    (k : ℤ)
    (hrep : ∃ x y z : ℤ, x^3 + y^3 + z^3 = k) :
    ∀ P : Finset ℕ, (∀ p ∈ P, Nat.Prime p) → 0 < truncatedSingularSeries k P := ...
```

If you build a probability interface:
```lean
def uniformThreeCubeProb (k : ℤ) (n : ℕ) : ℚ := ...

theorem threeCubeLocalDensity_eq_uniformProb
    (k : ℤ) (n : ℕ) (hn : 0 < n) :
    threeCubeLocalDensity k n = uniformThreeCubeProb k n := ...
```

---

## Cross-domain connections you must make explicit

1. **Analytic number theory ↔ algebraic local-global arithmetic**  
   The singular series is a quantitative refinement of local admissibility. This turns congruence obstructions into density predictions.

2. **Number theory ↔ probability theory**  
   Local density is literally a probability that a random residue triple solves a cubic congruence. This reframes the circle method as a probabilistic independence principle across primes.

3. **Number theory ↔ harmonic analysis**  
   If you formalize finite Fourier expansions, the local count becomes a cubic exponential-sum moment. This is the finite-modulus shadow of major/minor arc decomposition.

4. **Number theory ↔ statistical physics**  
   The Euler product can be interpreted as a partition function of local compatibility constraints. Positivity and decay of factors echo correlation and renormalization phenomena.

At least one theorem should explicitly instantiate one of these bridges, not just mention it in prose.

---

## Conjecture with testable prediction

State and test a falsifiable conjecture, not just a vague heuristic.

### Conjecture
For each admissible \(k\in\{0,1,2,3,6,7,8,9\}\), there exists \(c_k>0\) such that
\[
R_k(N) = c_k N^{1/3} + O_k(N^{1/3-\eta})
\]
for some \(\eta>0\), and the squarefree truncated singular series
\[
\mathfrak S^{\mathrm{sf}}_{\le P}(k) := \prod_{p\le P} \delta_k(p)
\]
stabilizes numerically toward a nonzero constant proportional to \(c_k\).

### Computational falsification test
For each \(k\in\{0,1,2,3,6,7,8,9\}\):
1. compute \(R_k(N)\) for increasing \(N\);
2. compute \(\mathfrak S^{\mathrm{sf}}_{\le P}(k)\) for increasing prime cutoffs \(P\);
3. fit \(R_k(N)/N^{1/3}\) against the truncated series;
4. record whether relative error decreases.

A failure of stabilization, persistent oscillation, or systematic divergence between \(R_k(N)/N^{1/3}\) and the local-density proxy would be evidence against the conjectural model.

---

## Verified algorithm requirement

You must provide a verified computational method, not only theorems.

### Required algorithm
Implement a certified routine that computes:
- `threeCubeResidueCount k n`
- `threeCubeLocalDensity k n`
- `truncatedSingularSeries k P`

and proves basic correctness properties:
- nonnegativity,
- exact agreement with the counted solution set,
- multiplicativity over coprime moduli where applicable.

This algorithm is scientifically central: it transforms the singular series from a formal abstraction into an executable prediction engine.

Suggested theorem:
```lean
theorem truncatedSingularSeries_spec
    (k : ℤ) (P : Finset ℕ) :
    truncatedSingularSeries k P
      = ∏ p in P, ((threeCubeResidueCount k p : ℚ) / (p : ℚ)^2) := ...
```

---

## Demo requirement

Provide `demo.py` that:
1. computes empirical counts \(R_k(N)\) for selected \(k\),
2. computes local factors \(\delta_k(p)\) for primes \(p \le P\),
3. plots \(R_k(N)/N^{1/3}\) against the truncated singular-series proxy,
4. highlights admissible vs inadmissible residue classes mod \(9\).

The demo should make the theory visually persuasive.

---

## Why this would be a breakthrough

If you succeed, you will have created the first formal framework in this project where:
- local admissibility data becomes a quantitative density object;
- CRT multiplicativity yields an Euler-product architecture;
- the three-cubes problem is connected rigorously to probability and harmonic analysis;
- a certified algorithm computes the local factors that analytic number theorists normally manipulate heuristically.

This opens an entirely new research program: formal singular series for Diophantine equations. From there, one can attack sums of powers, Waring-type problems, local-to-global density laws, and eventually finite Fourier/circle-method formalizations. That is not an incremental extension. That is a new interface between formal arithmetic geometry and analytic number theory.

---

## Application keywords

circle method, singular series, singular integral, local density, Euler product, Chinese remainder theorem, cubic congruences, three cubes problem, Hardy–Littlewood heuristics, additive number theory, finite Fourier analysis, exponential sums, probability on finite rings, local-global principle, p-adic lifting, statistical mechanics analogy, asymptotic counting, certified computation

---

## Mandatory deliverables

You must produce **all** of the following:

1. **A Lean file** containing at least 3 substantial theorems with deep proof tactics (`induction`, `rcases`, `by_contra`, `field_simp`, multi-step `calc`, etc.), and at least one genuinely novel definition.
2. **A verified algorithm or computational method** for computing local densities and truncated singular series.
3. **`demo.py`** demonstrating the result interactively on the prescribed values of \(k\) and ranges of \(N,P\).
4. **`RESEARCH_PAPER.md`** as a standalone scientific paper explaining the definitions, theorems, computational evidence, significance, and next questions. A reader with no access to the code must still understand the discovery.
5. **`ARTICLE.md`** in Scientific American style, explaining the ideas and significance accessibly. Do **not** focus on formal verification machinery; focus on the mathematics.
6. **`FUTURE_DIRECTIONS.md`** with 3–5 original research directions. Each direction must explicitly include the sentences:
   - **“The key insight is...”**
   - **“Why now?”**
   At least one direction must bridge to a different domain, such as harmonic analysis, probability, or statistical physics.

Minimize `sorry`. If a theorem is too ambitious in full generality, prove the strongest nontrivial restricted version you can and make the restriction mathematically meaningful. The goal is not to imitate the circle method superficially; it is to create the first rigorous local-density architecture from which a true formal circle method can eventually emerge.

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
    "visualizations": [ { "name": "...", "code": "# matplotlib or plotly script, self-contained", "description": "What this visualizes" } ],
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
