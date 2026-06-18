## Assignment: **prove**

### Title
**Berggren Tree Arithmetic Dynamics: certified exponential growth, residue mixing, and hypotenuse multiplicity**

Prove genuinely new theorems at the interface of arithmetic dynamics, semigroup growth, and formal algorithmic number theory. The aim is not merely to enumerate primitive Pythagorean triples, but to turn the Berggren tree into a rigorously analyzed dynamical system with certified complexity bounds, congruence-level mixing, and exact multiplicity formulas. This opens a formal bridge between discrete semigroup actions, thin-orbit heuristics, and verified enumeration complexity.

You should target at least one theorem in each of the three directions below, with Hypothesis 1 the highest-priority breakthrough because it converts the Berggren tree from a classical parametrization device into a provably efficient arithmetic dynamical algorithm.

---

## Core objects to formalize

Let the Berggren generators be the classical matrices
\[
A=\begin{pmatrix}
1 & -2 & 2\\
2 & -1 & 2\\
2 & -2 & 3
\end{pmatrix},\quad
B=\begin{pmatrix}
1 & 2 & 2\\
2 & 1 & 2\\
2 & 2 & 3
\end{pmatrix},\quad
C=\begin{pmatrix}
-1 & 2 & 2\\
-2 & 1 & 2\\
-2 & 2 & 3
\end{pmatrix},
\]
acting on primitive Pythagorean triples, rooted at \((3,4,5)\).

For a word \(w\) in the free monoid on \(\{A,B,C\}\), let \(T(w)=(a(w),b(w),c(w))\) be the resulting triple, and let \(|w|=d\) be the depth.

Define
\[
c_{\min}(d):=\min\{c(w): |w|=d\}.
\]

The theorem-level goal is to make the asymptotic arithmetic of \(c(w)\) formal and algorithmically exploitable.

---

## Theorem Target 1: Exponential hypotenuse growth rate

### Precise theorem statement
Prove that there exist constants \(K_1,K_2>0\) and \(\lambda>1\) such that for every depth \(d\),
\[
K_1 \lambda^d \le c_{\min}(d)\le K_2 \lambda^d.
\]
Stronger target:
\[
\lim_{d\to\infty} c_{\min}(d)^{1/d}=\lambda,
\]
and the minimizing branch is eventually periodic, ideally exactly periodic.

The boldest version is:

> **Periodic minimal-growth theorem.** There exists a finite nonempty word \(p\) and constants \(C_-,C_+>0\) such that if \(w_d\) is the lexicographically chosen depth-\(d\) minimizer of \(c(w)\), then for all sufficiently large \(d\), \(w_d\) is the prefix of the infinite periodic word \(ppp\cdots\), and hence
> \[
> c_{\min}(d)=\Theta(\lambda^d)
> \]
> where \(\lambda\) is the Perron eigenvalue of the matrix product corresponding to \(p\), normalized by period length.

This is the theorem that would be a breakthrough: it identifies an extremal geodesic in the Berggren semigroup and extracts a certified growth constant governing optimal enumeration depth.

### Lean 4 type signature target
You may need to define words, matrix action, and hypotenuse projection. A plausible formal target is:

```lean
def BerggrenGen := Fin 3
def berggrenMatrix : BerggrenGen → Matrix (Fin 3) (Fin 3) ℤ
def rootTriple : Fin 3 → ℤ
def evalWord : List BerggrenGen → (Fin 3 → ℤ)
def hypotenuse (v : Fin 3 → ℤ) : ℤ := v 2
def cMin (d : ℕ) : ℤ := sInf {z | ∃ w : List BerggrenGen, w.length = d ∧ hypotenuse (evalWord w) = z}

theorem exists_exp_growth_bounds_cMin :
  ∃ λ : ℝ, ∃ K₁ K₂ : ℝ,
    1 < λ ∧ 0 < K₁ ∧ 0 < K₂ ∧
    ∀ d : ℕ,
      K₁ * λ^d ≤ (cMin d : ℝ) ∧ (cMin d : ℝ) ≤ K₂ * λ^d := by
  sorry
```

A sharper asymptotic target:

```lean
theorem tendsto_log_cMin_div_depth :
  ∃ λ : ℝ, 1 < λ ∧
    Filter.Tendsto
      (fun d : ℕ => Real.log (cMin (d+1)) / (d+1 : ℝ))
      Filter.atTop
      (nhds (Real.log λ)) := by
  sorry
```

If the eventual periodic minimizer is reachable:

```lean
theorem exists_eventually_periodic_minimizer :
  ∃ p : List BerggrenGen, p ≠ [] ∧
  ∃ N : ℕ, ∀ d ≥ N,
    ∃ w : List BerggrenGen,
      w.length = d ∧
      hypotenuse (evalWord w) = cMin d ∧
      IsPrefix w (List.join (List.replicate (d+1) p)) := by
  sorry
```

### Why this is revolutionary
This theorem would convert the Berggren tree into a complexity-certified enumeration mechanism:
to enumerate all primitive triples with \(c\le N\), it suffices to explore depth
\[
d \le \frac{\log N + O(1)}{\log \lambda}.
\]
That is a formally verified logarithmic-depth search bound. This is not just number theory; it is a rare exact complexity theorem for a classical arithmetic generation process.

### Proof strategy options

#### Strategy A: Projective dynamics on slope space
1. Pass from triples \((a,b,c)\) to Euclid parameters or to a projective slope variable \(x\) on a positive cone.
2. Show each Berggren generator acts by a Möbius transformation on slope space, while the hypotenuse transforms by a positive linear cocycle.
3. Prove that the minimal asymptotic growth reduces to minimizing a subadditive cocycle over a finite-state or contracting projective dynamical system. Then apply a joint spectral radius / ergodic optimization argument to extract \(\lambda\) and periodicity of the minimizer.

This is the most promising route if you can identify a one-dimensional contracting model. It turns the problem into certified arithmetic dynamics.

#### Strategy B: Semigroup extremal norm / joint spectral radius
1. Restrict the Berggren matrices to the positive cone of primitive triples.
2. Study
   \[
   \inf_{|w|=d} \|M_w v_0\|
   \]
   where \(M_w\) is the product along the word and \(v_0=(3,4,5)\).
3. Use extremal norm ideas or cone-preserving matrix products to prove existence of an asymptotic exponential rate. Then identify the minimizer via a finite candidate search among periodic words.

This route is algebraically clean and may formalize better in Lean if spectral radius lemmas for finite-dimensional real matrices are accessible.

#### Strategy C: Recurrence for the minimal branch
1. Compute exact child formulas for \(c\) in terms of \((a,b,c)\).
2. Prove a comparison principle showing one generator is always suboptimal outside a narrow region, and that the minimizer must remain in an invariant cone/interval.
3. Derive a scalar recurrence for the minimal-growth branch and solve it explicitly or asymptotically.

This is the most elementary and most likely to yield a full formal proof if the projective reduction becomes too heavy.

---

## Theorem Target 2: Congruence equidistribution at large depth

### Precise theorem statement
For fixed modulus \(m\), let
\[
\mu_{d,m}(r)=\frac{1}{3^d}\#\{w: |w|=d,\ c(w)\equiv r \pmod m\}.
\]
Let \(S_m\subseteq \mathbb Z/m\mathbb Z\) be the set of admissible residues represented by primitive hypotenuses modulo \(m\), equivalently residues represented as a sum of two squares modulo \(m\) subject to primitivity constraints.

Target theorem:

> For every odd modulus \(m\), if the Berggren semigroup action on the reachable residue-state graph modulo \(m\) is strongly connected and aperiodic, then
> \[
> \mu_{d,m}(r)\to \frac{1}{|S_m|}
> \]
> for all \(r\in S_m\), and \(\mu_{d,m}(r)\to 0\) for \(r\notin S_m\).

Even stronger:
obtain an explicit exponential mixing estimate
\[
\left|\mu_{d,m}(r)-\frac{1}{|S_m|}\right| \le C(m)\rho(m)^d,\qquad 0<\rho(m)<1.
\]

### Lean 4 type signature target
A finite-state Markov operator on residue classes is likely the right formalization.

```lean
def residueTriple (m : ℕ) := Fin m × Fin m × Fin m
def reachableResidues (m : ℕ) : Finset (residueTriple m) := sorry
def stepResidues (m : ℕ) : residueTriple m → Finset (residueTriple m) := sorry
def depthDistC (m d : ℕ) : Fin m → ℚ := sorry
def admissibleCResidues (m : ℕ) : Finset (Fin m) := sorry

theorem residue_equidistribution_uniform
  (m : ℕ) (hm : Odd m) :
  stronglyConnectedAperiodic (berggrenResidueGraph m) →
  ∀ r : Fin m,
    r ∈ admissibleCResidues m →
    Filter.Tendsto (fun d : ℕ => (depthDistC m d r : ℝ))
      Filter.atTop
      (nhds (1 / (admissibleCResidues m).card : ℝ)) := by
  sorry
```

A weaker but very realistic theorem is to prove exact stationarity/uniformity on connected components for each fixed \(m\) after constructing the finite graph.

### Why this is revolutionary
This would be the first formally verified statement that Berggren dynamics exhibits residue-class mixing. It links a classical tree of primitive triples to:
- finite dynamical systems,
- spectral graph theory,
- thin semigroup orbit heuristics,
- the beginnings of a certified spectral-gap program.

This is where elementary number theory starts touching homogeneous dynamics.

### Proof strategy options

#### Strategy A: Finite-state automaton + Perron–Frobenius
1. Construct the finite directed graph of primitive residue triples modulo \(m\).
2. Show Berggren generators preserve primitiveness and admissibility modulo \(m\).
3. Prove the adjacency/transition matrix is irreducible and aperiodic on the reachable component; conclude convergence to the unique stationary distribution. Then identify that stationary distribution is uniform on admissible hypotenuse residues by symmetry.

This is the strongest formalization candidate because it reduces the theorem to finite combinatorics for each modulus.

#### Strategy B: Semigroup action on \((u,v)\)-parameters modulo \(m\)
1. Pass from triples to Euclid parameters \(a=u^2-v^2\), \(b=2uv\), \(c=u^2+v^2\).
2. Translate Berggren moves into transformations on coprime parity-constrained pairs \((u,v)\).
3. Analyze orbit structure modulo \(m\) there; uniformity of \(c=u^2+v^2\) may become more transparent.

This may expose the “admissible residues” naturally and clarify the sum-of-two-squares structure.

#### Strategy C: Representation-theoretic Fourier analysis mod \(m\)
1. Consider the averaging operator over the three generators on functions mod \(m\).
2. Study its action on additive characters or on the finite reachable state space.
3. Prove all nontrivial Fourier modes contract.

This is the most conceptually ambitious route and creates a bridge to expander/spectral-gap ideas.

---

## Theorem Target 3: Fixed-hypotenuse multiplicity formula

### Precise theorem statement
Let \(r_{\mathrm{prim}}(c)\) be the number of primitive Pythagorean triples \((a,b,c)\) with \(a<b\). Then the target theorem is:

> If
> \[
> c=\prod_{p_i\equiv 1\!\!\!\pmod 4} p_i^{e_i}\cdot \prod_{q_j\equiv 3\!\!\!\pmod 4} q_j^{f_j},
> \]
> then \(r_{\mathrm{prim}}(c)=0\) unless every \(f_j\) is even. In the valid case,
> \[
> r_{\mathrm{prim}}(c)=2^{k-1},
> \]
> where \(k\) is the number of distinct primes \(p_i\equiv 1\pmod 4\).

This should be stated in a way compatible with known sum-of-two-squares structure, and carefully normalized by ordering \(a<b\) to avoid double-counting.

### Lean 4 type signature target
Assuming definitions for primitive triples and prime factor support:

```lean
def IsPrimitivePythTriple (a b c : ℕ) : Prop :=
  a^2 + b^2 = c^2 ∧ Nat.Coprime a b ∧ a < b

def primTripleCountWithHypotenuse (c : ℕ) : ℕ := sorry
def oneModFourPrimeFactors (c : ℕ) : Finset ℕ := sorry
def validHypotenuse (c : ℕ) : Prop := sorry

theorem primitive_hypotenuse_multiplicity_formula (c : ℕ) :
  primTripleCountWithHypotenuse c =
    if validHypotenuse c then
      2 ^ ((oneModFourPrimeFactors c).card - 1)
    else 0 := by
  sorry
```

A more realistic split theorem:
1. characterize valid hypotenuses;
2. prove the count is \(2^{k-1}\).

### Why this matters
Unlike Hypotheses 1 and 2, this theorem is likely classical in substance, but formalizing it cleanly is still high value because it supplies exact counting data for Berggren dynamics. It becomes the arithmetic input for:
- counting nodes by hypotenuse,
- validating enumeration completeness,
- comparing tree-depth complexity with arithmetic multiplicity,
- building a certified database of primitive triples up to \(10^6\) and beyond.

This theorem is the algebraic backbone against which the dynamical theorems can be tested.

### Proof strategy options

#### Strategy A: Gaussian integers
1. Use factorization \(c=a^2+b^2=(a+bi)(a-bi)\) in \(\mathbb Z[i]\).
2. Primitive triples correspond to coprime Gaussian factorizations up to units and conjugation.
3. Count choices of splitting among distinct \(p\equiv 1\pmod 4\), divide by the symmetry from swapping/conjugation, and obtain \(2^{k-1}\).

This is the conceptual gold standard.

#### Strategy B: Sum-of-two-squares counting formula
1. Use the classical formula for the number of representations of \(c\) as a sum of two squares.
2. Extract the primitive representations by Möbius inversion or gcd filtering.
3. Quotient by sign and order symmetries to isolate \(a<b\).

This may integrate more directly with existing Mathlib number-theory lemmas if Gaussian integers are incomplete.

#### Strategy C: Euclid parameter classification
1. Show primitive triples correspond to coprime \(u>v\), opposite parity, with \(c=u^2+v^2\).
2. Count the number of primitive representations of \(c\) as \(u^2+v^2\).
3. Reduce to the prime decomposition criterion.

This is the most elementary and may be easiest to verify computationally alongside the theorem.

---

## Cross-domain connections to exploit

### 1. Arithmetic dynamics
The Berggren tree is a semigroup action on an arithmetic variety. Hypothesis 1 is an extremal Lyapunov exponent problem. Hypothesis 2 is a finite-quotient mixing problem. Phrase the work this way: you are not studying triples, you are studying a thin arithmetic dynamical system.

### 2. Automata and certified algorithms
The residue dynamics modulo \(m\) is a finite automaton. Formalizing this in Lean yields verified state-transition systems, enabling exact proofs of connectivity, periodicity, and stationary distribution. This is a bridge from theorem proving to algorithm certification.

### 3. Spectral theory and joint spectral radius
The exponential growth constant \(\lambda\) is naturally linked to extremal matrix products. This imports tools from control theory and matrix cocycles into a classical Diophantine setting.

### 4. Thin orbits and homogeneous dynamics
Congruence equidistribution is the finite-shadow version of deep thin-orbit phenomena. Even a theorem for fixed \(m\) and the Berggren semigroup is a concrete formal foothold into the spectral-gap worldview.

### 5. Analytic number theory via Gaussian integers
The multiplicity formula connects the Berggren tree to unique factorization in \(\mathbb Z[i]\), representation by quadratic forms, and the sum-of-two-squares theorem. This gives an exact arithmetic control layer over the dynamical layer.

### 6. Complexity theory
Hypothesis 1 transforms the tree into a complexity object: logarithmic-depth completeness bounds, asymptotic node counts, and certified output-sensitive enumeration.

---

## Suggested sequence of attack

1. **Formalize the Berggren generators and prove they preserve primitive Pythagorean triples.**
   This is foundational and should have zero ambiguity.

2. **Prove exact child formulas for the hypotenuse and simple monotonicity inequalities.**
   These inequalities will be the raw material for the minimal-growth theorem.

3. **Construct the finite residue graph modulo \(m\) for small moduli and prove reachability/connectivity lemmas.**
   Even partial equidistribution theorems for explicitly verified moduli \(m\in\{3,5,7,13\}\) would already be a substantial formal milestone.

4. **Formalize the multiplicity formula.**
   This theorem is likely the easiest major win and provides arithmetic validation infrastructure.

5. **Return to the asymptotic minimal-growth theorem with computational evidence guiding the periodic branch conjecture.**
   Once the likely periodic word is identified, prove it is globally optimal.

---

## Concrete nontrivial theorem variants if the strongest form stalls

If the full asymptotic in Hypothesis 1 is too hard immediately, prove one of these intermediate theorems:

### Variant 1A: Uniform exponential lower bound
\[
\exists \lambda_0>1,\ \forall w,\ c(w)\ge c(\varnothing)\lambda_0^{|w|}.
\]
This already gives logarithmic depth bounds.

```lean
theorem uniform_exp_lower_bound_hypotenuse :
  ∃ λ₀ : ℝ, 1 < λ₀ ∧
    ∀ w : List BerggrenGen,
      (hypotenuse (evalWord w) : ℝ) ≥ (hypotenuse rootTriple : ℝ) * λ₀^(w.length) := by
  sorry
```

### Variant 1B: Existence of asymptotic growth rate for a fixed periodic branch
For some explicit nonempty word \(p\),
\[
\lim_{n\to\infty} c(p^n)^{1/n}=\rho(M_p).
\]

### Variant 2A: Exact uniformity on a finite quotient component
For a specific modulus \(m\), prove the stationary distribution on reachable residues is uniform.

### Variant 2B: Reachability characterization
Classify exactly which residue triples mod \(m\) are reachable from \((3,4,5)\).

### Variant 3A: Valid hypotenuse criterion
Prove \(c\) occurs as a primitive hypotenuse iff every prime \(q\equiv 3\pmod 4\) divides \(c\) to an even power and at least one prime \(p\equiv 1\pmod 4\) divides \(c\).

---

## Build on catalog theorems
Search the catalog for:
- matrix and finite graph infrastructure,
- Perron–Frobenius or spectral radius lemmas,
- Gaussian integer / sum-of-two-squares formalizations,
- modular arithmetic and finite-state reachability results,
- asymptotic growth lemmas for linear recurrences or submultiplicative sequences.

Use existing theorems as certified scaffolding, not decoration. In particular:
- if there are graph connectivity or Markov-chain convergence lemmas, use them to turn the residue-action theorem into a finite combinatorics proof;
- if there are spectral radius results for nonnegative matrices, use them to isolate \(\lambda\);
- if there are Gaussian integer factorization theorems, use them to make the multiplicity formula elegant and exact.

Minimize sorry by choosing theorem statements that decompose into reusable algebraic and combinatorial lemmas.

---

## Deliverables

1. Lean files proving at least one major theorem and several supporting lemmas.
2. Computation-backed conjecture refinement for the exact value of \(\lambda\) and the identity of the minimal-growth periodic branch.
3. A short note inside the code comments explaining which proof route succeeded and which failed.
4. **A structured `FUTURE_DIRECTIONS.md` with 3–5 falsifiable scientific hypotheses**, each with:
   - a precise conjectural statement,
   - a concrete computational or formal test,
   - a criterion for falsification.

These hypotheses must be genuine next-step science, not vague suggestions.

---

## Required FUTURE_DIRECTIONS hypotheses
At least include candidates of the following form:

1. **Periodic minimizer hypothesis:** the depth-\(d\) minimizer is eventually periodic with explicit period \(p\).
2. **Spectral-gap hypothesis mod \(m\):** the second eigenvalue of the averaging operator on reachable residues mod \(m\) is uniformly bounded away from 1 for all odd \(m\) in a tested family.
3. **Large deviations hypothesis:** among depth-\(d\) words, \(\log c(w)/d\) satisfies a concentration principle around a typical Lyapunov exponent.
4. **Berggren geodesic hypothesis:** minimal-growth words are exactly geodesics in an induced projective metric on the positive cone.
5. **Multiplicity–depth interaction hypothesis:** for hypotenuse \(c\), the number of primitive triples with that hypotenuse correlates with the number of near-minimal-depth representations in the Berggren tree.

Each must be testable by explicit enumeration or formal finite-state analysis.

---

## Application keywords
primitive Pythagorean triples; Berggren tree; arithmetic dynamics; thin semigroups; congruence mixing; spectral gap; joint spectral radius; projective dynamics; Gaussian integers; sum of two squares; formalized number theory; verified enumeration complexity; finite automata; Perron–Frobenius; modular equidistribution; Lean 4; Mathlib.

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
