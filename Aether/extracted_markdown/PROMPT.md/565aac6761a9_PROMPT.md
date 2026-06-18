Soli Deo Gloria

## Assignment: Direction 3 Reforged — Algorithmic Lattice-Reduced Diophantine Certification as a Geometry-of-Numbers Bridge to Tropical KAM

**Mode:** prove

Do not treat this as a mere algorithmic speedup. The real target is a new theorem schema converting a **finite tropical Diophantine nonresonance certificate** into a **lattice-separation theorem in the geometry of numbers**, and then extracting a verified algorithm whose complexity is polynomial in the input size for fixed dimension, with explicit correctness margins. If done cleanly, this becomes a new formal bridge between tropical dynamics, computational number theory, and lattice-based optimization.

The catalog already gives the foundational notions in `Pythagorean/TropicalKAMDefs.lean`, especially `l1Norm`, `latticeInner`, and `TropicalDiophantine`. Your task is to **recast finite-order tropical Diophantine certification as a shortest-vector / closest-vector separation problem** and prove mathematically nontrivial comparison theorems. The breakthrough is not “LLL is faster than brute force”; the breakthrough is:

> **Finite nonresonance up to cutoff K can be certified by a lower bound on a lattice minimum in a lifted lattice whose geometry encodes the frequency vector.**

That statement opens a new formal program: tropical KAM via geometry of numbers, with downstream implications for celestial mechanics, integer optimization, and even lattice-based cryptography, where “absence of short relations” is the central hardness motif.

---

## Core Objects to Introduce

You must define at least one genuinely new structure. A recommended definition is a **lifted resonance lattice certificate**.

### Suggested new definitions
Introduce a structure in Lean expressing a finite-order lattice certificate for a frequency vector:

```lean
structure LiftedFreqCertificate where
  n : ℕ
  K : ℕ
  C : ℝ
  ω : Fin n → ℝ
  carrier : Set (Fin n → ℤ)
  sep : ℝ
```

and, more importantly, define the actual separation quantity:

```lean
def liftedGap (K : ℕ) (ω : Fin n → ℝ) : ℝ :=
  sInf {r : ℝ | ∃ k : Fin n → ℤ,
    k ≠ 0 ∧ l1Norm k ≤ K ∧ |latticeInner k ω| = r}
```

If `sInf` becomes technically awkward, use a finite-set minimum over the boxed search domain
`{k | l1Norm k ≤ K}` after proving finiteness. A computationally robust alternative:

```lean
def boxedResonantSet (K : ℕ) (n : ℕ) : Finset (Fin n → ℤ) := ...
def boxedGap (K : ℕ) (ω : Fin n → ℝ) : ℝ :=
  (boxedResonantSet K n).fold min 0 (fun k => if k = 0 then 0 else |latticeInner k ω|)
```

Also define a lifted lattice surrogate that packages integer relations among coordinates and a target hyperplane. If full lattice formalization is too heavy, define an abstract predicate expressing the existence of a short near-relation and prove implications from it.

A highly usable new concept:

```lean
def NoShortDualRelation (K : ℕ) (C : ℝ) (ω : Fin n → ℝ) : Prop :=
  ∀ k : Fin n → ℤ, k ≠ 0 → l1Norm k ≤ K → C ≤ |latticeInner k ω|
```

and then prove this is equivalent to the catalog’s `TropicalDiophantine K C ω` if that is indeed the existing definition, or prove one direction if the catalog uses a slightly different normalization.

---

## Precise Theorem Targets

You must prove **at least 3 nontrivial theorems** with multi-step reasoning. Below are the right theorems to target.

### Theorem 1: Exact finite certification as a minimum principle
This is the foundational geometry-of-numbers reformulation.

**Mathematical statement.**  
For every dimension `n`, cutoff `K`, threshold `C`, and frequency vector `ω : Fin n → ℝ`, the tropical Diophantine condition up to order `K` holds iff the minimum nonzero resonance gap over the `ℓ¹` box of radius `K` is at least `C`.

**Lean-style target signature:**
```lean
theorem tropicalDiophantine_iff_boxedGap_ge
    {n K : ℕ} {C : ℝ} {ω : Fin n → ℝ} :
    TropicalDiophantine K C ω ↔
      ∀ k : Fin n → ℤ, k ≠ 0 → l1Norm k ≤ K → C ≤ |latticeInner k ω|
```

If `TropicalDiophantine` is already exactly this, do **not** stop there. Strengthen it to a minimum-attainment theorem over a finite search set:

```lean
theorem exists_minimizer_boxedGap
    {n K : ℕ} {ω : Fin n → ℝ} :
    ∃ k : Fin n → ℤ,
      (k = 0 ∨ l1Norm k ≤ K) ∧
      ∀ j : Fin n → ℤ, (j = 0 ∨ l1Norm j ≤ K) →
        |latticeInner k ω| ≤ |latticeInner j ω|
```

and then derive

```lean
theorem tropicalDiophantine_iff_min_gap_ge
    {n K : ℕ} {C : ℝ} {ω : Fin n → ℝ} :
    TropicalDiophantine K C ω ↔
      C ≤ boxedGap K ω
```

**Why this matters.**  
This upgrades a quantified condition into an optimization certificate. That is the gateway to algorithms, asymptotic complexity, and comparison with lattice reduction.

---

### Theorem 2: Monotonicity and transfer of certificates across scales
This theorem makes the certification usable in practice.

**Mathematical statement.**  
If a frequency vector is certified nonresonant up to order `K₂`, then it is certified up to any smaller order `K₁ ≤ K₂`. Moreover, if it is certified with threshold `C₂`, it is certified with any weaker threshold `C₁ ≤ C₂`.

**Lean-style target signature:**
```lean
theorem TropicalDiophantine.mono_order
    {n K₁ K₂ : ℕ} {C : ℝ} {ω : Fin n → ℝ}
    (hK : K₁ ≤ K₂)
    (h : TropicalDiophantine K₂ C ω) :
    TropicalDiophantine K₁ C ω
```

```lean
theorem TropicalDiophantine.mono_threshold
    {n K : ℕ} {C₁ C₂ : ℝ} {ω : Fin n → ℝ}
    (hC : C₁ ≤ C₂)
    (h : TropicalDiophantine K C₂ ω) :
    TropicalDiophantine K C₁ ω
```

Then prove a combined transport theorem:

```lean
theorem TropicalDiophantine.transport
    {n K₁ K₂ : ℕ} {C₁ C₂ : ℝ} {ω : Fin n → ℝ}
    (hK : K₁ ≤ K₂) (hC : C₁ ≤ C₂)
    (h : TropicalDiophantine K₂ C₂ ω) :
    TropicalDiophantine K₁ C₁ ω
```

**Why this matters.**  
This theorem creates a hierarchy of certificates and enables multiscale algorithms: certify at one scale, inherit many weaker certificates for free. This is the formal backbone of branch-and-bound and adaptive search.

---

### Theorem 3: Lattice-separation implies tropical Diophantine certification
This is the conceptual breakthrough theorem.

You may need to formulate this in a slightly abstract way depending on available linear algebra / lattice infrastructure. The essential content is:

**Mathematical statement.**  
Suppose a lifted lattice construction associated to `ω` has no nonzero vector in a prescribed convex body of radius controlled by `K` and `C`. Then `TropicalDiophantine K C ω` holds.

A formal version can be written using an abstract predicate `LiftedSeparationCert K C ω`. You define that predicate and prove it implies the Diophantine condition.

**Lean-style target signature:**
```lean
def LiftedSeparationCert (K : ℕ) (C : ℝ) (ω : Fin n → ℝ) : Prop := 
  ∀ k : Fin n → ℤ, k ≠ 0 → l1Norm k ≤ K → C ≤ |latticeInner k ω|
```

This may look identical to the target, but the real goal is to refine it by introducing a lifted witness object coming from a reduced basis or dual-lattice lower bound. For example:

```lean
structure ReducedBasisWitness (n : ℕ) (K : ℕ) (C : ℝ) (ω : Fin n → ℝ) : Prop where
  lower_bound :
    ∀ k : Fin n → ℤ, k ≠ 0 → l1Norm k ≤ K → C ≤ |latticeInner k ω|
```

and prove

```lean
theorem ReducedBasisWitness.sound
    {n K : ℕ} {C : ℝ} {ω : Fin n → ℝ} :
    ReducedBasisWitness n K C ω → TropicalDiophantine K C ω
```

That is the minimal theorem. But the stronger theorem you should actually aim for is a perturbative transfer result:

### Theorem 3′: Stability under frequency perturbation
If `ω` is certified at threshold `C + εK`, and `ω'` is within `ε` in sup norm coordinatewise, then `ω'` is certified at threshold `C`.

**Lean-style target signature:**
```lean
theorem tropicalDiophantine_stable_under_supPerturb
    {n K : ℕ} {C ε : ℝ} {ω ω' : Fin n → ℝ}
    (hε : 0 ≤ ε)
    (hclose : ∀ i, |ω i - ω' i| ≤ ε)
    (h : TropicalDiophantine K (C + K * ε) ω) :
    TropicalDiophantine K C ω'
```

This is a real theorem with substance: use triangle inequality plus the bound
`|⟪k, ω - ω'⟫| ≤ (l1Norm k) * ε ≤ Kε`.

**Why this matters.**  
This turns exact nonresonance into a **robust certificate**, which is what LLL/BKZ actually produce in practice: approximate arithmetic information with explicit error bars. This is the theorem that makes numerical lattice reduction mathematically meaningful for tropical KAM.

---

## Strongly Recommended Fourth Theorem: Explicit finite search cardinality bound
This theorem links to complexity.

**Mathematical statement.**  
The number of integer vectors `k : Fin n → ℤ` with `l1Norm k ≤ K` is finite and bounded by `(2K+1)^n`.

**Lean-style target signature:**
```lean
theorem card_l1_box_le
    (n K : ℕ) :
    Fintype.card {k : Fin n → ℤ // l1Norm k ≤ K} ≤ (2 * K + 1) ^ n
```

If exact counting is easier in your setup, even better. This gives a formal upper bound for brute-force certification and creates the contrast with reduced-basis search.

**Why this matters.**  
This theorem is the complexity baseline against which the lattice-reduced method is measured.

---

## Proof Architecture: 3 Viable Strategies

### Strategy A: Finite optimization + perturbative geometry
**Most promising for Lean.**
1. Prove the search domain `{k : Fin n → ℤ | l1Norm k ≤ K}` is finite.
2. Define the minimum resonance gap over that finite domain and prove equivalence with `TropicalDiophantine`.
3. Prove perturbation stability using
   \[
   |\langle k,\omega'\rangle| \ge |\langle k,\omega\rangle| - |\langle k,\omega'-\omega\rangle|
   \]
   and the estimate
   \[
   |\langle k,\omega'-\omega\rangle| \le \|k\|_1 \|\omega'-\omega\|_\infty.
   \]
4. Package any approximate lattice-reduction output as a witness satisfying the perturbative hypotheses.

**Why best:** avoids deep dependence on a preexisting formalization of LLL while still proving a theorem that justifies LLL-style certification.

---

### Strategy B: Abstract geometry-of-numbers certificate
1. Define an abstract predicate representing a lower bound on the first minimum of a lifted lattice or dual module.
2. Show that any nonzero resonance vector `k` in the `ℓ¹` box would induce a short vector in the lifted lattice.
3. Prove the contrapositive: if the lifted lattice has no such short vector, then no resonance occurs, hence `TropicalDiophantine`.

**Why powerful:** conceptually deepest; best if you can formalize enough lattice language. This is the theorem that would make mathematicians notice the work.

---

### Strategy C: Rational approximation / transference inequality
1. Express near-resonance `|⟪k,ω⟫| < C` as a Diophantine approximation statement.
2. Use a transference-style estimate: good integer relations correspond to short vectors in an associated lattice basis matrix.
3. Derive a certificate theorem from lower bounds on shortest vectors.

**Why interesting:** strongest bridge to cryptography and computational number theory. Use this if you can encode the matrix/lattice relation cleanly.

**Recommendation:** pursue Strategy A fully, then layer in Strategy B as the conceptual wrapper. That gives both a complete Lean success path and a research-level narrative.

---

## Cross-Domain Connection Theorems You Should Explicitly Include

You are required to connect to another domain. Do not make this superficial.

### Bridge 1: Geometry of numbers / cryptography
Formulate and prove that “absence of short integer relations” is a certificate of tropical nonresonance. This is exactly the same structural phenomenon that underlies lattice attacks and hardness assumptions in lattice cryptography.

**Application keywords:** shortest vector problem, closest vector problem, transference bounds, lattice hardness, dual lattice, BKZ.

### Bridge 2: Dynamical systems / celestial mechanics
Explain formally in `RESEARCH_PAPER.md` that Diophantine frequency conditions are the classical obstruction-removal mechanism in KAM theory; your theorem makes them computationally certifiable in high dimension, directly relevant to many-body Hamiltonian systems.

**Application keywords:** KAM theory, invariant tori, nonresonance, Hamiltonian perturbation, many-body celestial mechanics.

### Bridge 3: Integer optimization
Finite resonance search over `l1Norm k ≤ K` is an integer feasibility problem. Your certificate theorem reframes it as a convex/lattice separation problem, aligning tropical KAM with methods from integer programming.

**Application keywords:** integer programming, separation oracle, branch-and-bound, convex bodies, combinatorial optimization.

---

## Lean 4 Formal Targets

Work in a new file, for example:
`Pythagorean/AlgorithmicLatticeDiophantine.lean`

Import the catalog definitions from:
`Pythagorean/TropicalKAMDefs.lean`

At minimum, formalize and prove versions of the following:

```lean
theorem TropicalDiophantine.mono_order
    {n K₁ K₂ : ℕ} {C : ℝ} {ω : Fin n → ℝ}
    (hK : K₁ ≤ K₂)
    (h : TropicalDiophantine K₂ C ω) :
    TropicalDiophantine K₁ C ω
```

```lean
theorem TropicalDiophantine.mono_threshold
    {n K : ℕ} {C₁ C₂ : ℝ} {ω : Fin n → ℝ}
    (hC : C₁ ≤ C₂)
    (h : TropicalDiophantine K C₂ ω) :
    TropicalDiophantine K C₁ ω
```

```lean
theorem latticeInner_sub_bound
    {n : ℕ} (k : Fin n → ℤ) (x y : Fin n → ℝ) :
    |latticeInner k x - latticeInner k y| ≤ (l1Norm k : ℝ) * (Finset.univ.sup (fun i => |x i - y i|))
```

If `sup` over `Finset.univ` is awkward, replace by a hypothesis:
```lean
(hclose : ∀ i, |x i - y i| ≤ ε)
```
and prove
```lean
theorem latticeInner_sub_bound_of_coordwise
    {n : ℕ} (k : Fin n → ℤ) (x y : Fin n → ℝ) {ε : ℝ}
    (hε : 0 ≤ ε)
    (hclose : ∀ i, |x i - y i| ≤ ε) :
    |latticeInner k x - latticeInner k y| ≤ (l1Norm k : ℝ) * ε
```

```lean
theorem tropicalDiophantine_stable_under_supPerturb
    {n K : ℕ} {C ε : ℝ} {ω ω' : Fin n → ℝ}
    (hε : 0 ≤ ε)
    (hclose : ∀ i, |ω i - ω' i| ≤ ε)
    (h : TropicalDiophantine K (C + (K : ℝ) * ε) ω) :
    TropicalDiophantine K C ω'
```

```lean
theorem card_l1_box_le
    (n K : ℕ) :
    Fintype.card {k : Fin n → ℤ // l1Norm k ≤ K} ≤ (2 * K + 1) ^ n
```

You should also define a computable brute-force checker and a witness-based checker:
```lean
def bruteForceDiophantineCheck (K : ℕ) (C : ℝ) (ω : Fin n → ℝ) : Bool := ...
def witnessDiophantineCheck (K : ℕ) (C : ℝ) (ω : Fin n → ℝ) (w : ReducedBasisWitness n K C ω) : Bool := true
```

Then prove a soundness theorem:
```lean
theorem witnessDiophantineCheck_sound
    {n K : ℕ} {C : ℝ} {ω : Fin n → ℝ}
    (w : ReducedBasisWitness n K C ω) :
    witnessDiophantineCheck K C ω w = true ∧ TropicalDiophantine K C ω
```

---

## Deep Proof Tactics Requirement

Your three main theorems must genuinely use nontrivial proof structure. Aim for:
- `rcases` on bounded/nonzero integer vectors,
- `by_contra` for separation arguments,
- `field_simp` if rational frequency examples are used,
- induction on dimension or on finite sums where natural,
- multi-step `calc` chains for triangle-inequality and norm estimates.

Do **not** satisfy the assignment by definitional unfolding alone.

A particularly good nontrivial proof is the perturbation theorem, because it forces:
1. decomposition of `latticeInner k ω'` as `latticeInner k ω + latticeInner k (ω' - ω)`,
2. absolute-value inequalities,
3. conversion from coordinatewise error to global `ℓ¹–ℓ∞` bound,
4. transport of the Diophantine lower bound.

---

## Computational Deliverable: Verified Algorithmic Method

You must provide a verified computational method, not just theorem statements.

### Required algorithmic pipeline
1. **Brute-force checker** over all `k : Fin n → ℤ` with `l1Norm k ≤ K`.
2. **Lattice-reduced surrogate checker**:
   - in Lean, formalize the *soundness interface* rather than full LLL if necessary;
   - in `demo.py`, implement an actual practical LLL-based or relation-search-based heuristic using Python libraries (`sympy`, `fpylll`, or a fallback rational-relation search).
3. **Cross-validation harness**:
   - compare outputs on random and structured examples,
   - report agreement/disagreement,
   - measure wall-clock runtime.

The theorem-level soundness should justify:
- if the witness-based checker returns a certificate satisfying the proven inequalities, then `TropicalDiophantine K C ω` is true;
- if brute force finds a violating vector, the certificate is false.

This is scientifically valuable even if completeness of the reduced-basis method is not formally proved.

---

## Testable Conjectures for FUTURE_DIRECTIONS.md

You must include **3–5 falsifiable scientific hypotheses**. At least one should be a genuine sharpened conjecture beyond the assignment. Recommended candidates:

1. **Polynomial witness conjecture.**  
   For fixed dimension `n`, there exists a reduced-basis certificate algorithm whose runtime for deciding `TropicalDiophantine K C ω` is polynomial in `log K`, the bit-size of rational approximants to `ω`, and `n`.

   **Test:** generate rational/irrational frequency vectors with controlled precision; compare runtime scaling against brute force.

2. **Sharp perturbation conjecture.**  
   The stability margin in
   `TropicalDiophantine K (C + Kε) ω → TropicalDiophantine K C ω'`
   can be improved from `Kε` to `α_n Kε` with `α_n < 1` for generic frequency vectors.

   **Test:** Monte Carlo search over random `ω, ω'` to estimate the smallest universal constant.

3. **Random frequency gap conjecture.**  
   For random `ω ∈ [0,1]^n`, the minimum resonance gap over `l1Norm k ≤ K` is typically of order `K^{-n}` up to logarithmic factors.

   **Test:** sample random frequencies and fit empirical scaling of `boxedGap K ω`.

4. **Cryptographic hardness analogy conjecture.**  
   Families of frequency vectors engineered from hard lattice instances produce worst-case tropical certification problems for brute-force search but remain tractable via reduced-basis witnesses.

   **Test:** construct frequencies from near-kernel lattice bases and compare empirical hardness.

5. **Celestial mechanics transfer conjecture.**  
   Frequencies extracted from discretized many-body Hamiltonians satisfy robust finite-order tropical Diophantine certificates with probability approaching 1 under random perturbation.

   **Test:** generate model Hamiltonian frequency vectors and run the certification pipeline.

Each conjecture must include a clear refutation criterion.

---

## RESEARCH_PAPER.md Narrative Mandate

Your paper must be standalone and explain the mathematics as if the reader never sees the code.

It must include:
- a precise statement of `TropicalDiophantine`,
- the finite optimization reformulation,
- the perturbation-stability theorem,
- the lattice-certificate interpretation,
- algorithmic consequences,
- empirical comparison between brute force and reduced-basis heuristics,
- a discussion of why this matters for high-dimensional KAM-type problems.

Do not frame the story as “we formalized an existing algorithm.” Frame it as:

> We discovered that finite tropical nonresonance is naturally a geometry-of-numbers separation problem, and this yields robust algorithmic certificates.

---

## ARTICLE.md Mandate

Write in Scientific American style. Make the big idea vivid:

- Resonance is when many oscillations accidentally line up.
- The theorem says we can detect the impossibility of such alignments by looking for hidden integer relations using lattice geometry.
- This could matter for predicting long-term stability in complex dynamical systems and for understanding the geometry behind high-dimensional optimization.

**Taboo:** do not focus on formal verification machinery. Focus on the mathematics and scientific significance.

---

## demo.py Mandate

Your demo must:
1. generate sample frequency vectors `ω`,
2. run brute-force certification,
3. run LLL/relation-search heuristic,
4. compare results,
5. visualize runtime scaling in `n` and `K`,
6. exhibit at least one perturbation-stability experiment showing the theorem in action.

If external LLL libraries are unavailable, implement:
- a rational approximation matrix construction,
- a basic short-vector heuristic or integer relation search,
- and clearly mark it as a surrogate for BKZ/LLL.

---

## Application Keywords

tropical KAM, Diophantine nonresonance, geometry of numbers, shortest vector problem, closest vector problem, dual lattice, LLL, BKZ, lattice cryptography, integer relations, perturbation stability, many-body celestial mechanics, Hamiltonian dynamics, integer programming, separation oracle, high-dimensional certification

---

## Final Charge

Do not deliver a polite extension of brute-force search. Deliver a **new theorem interface** between tropical dynamics and lattice geometry.

The strongest possible outcome is:

1. a finite minimum-gap characterization of tropical Diophantine certification,
2. a robust perturbation theorem converting approximate lattice information into exact certification,
3. a witness-based algorithm with proven soundness,
4. empirical evidence that reduced-basis heuristics dramatically outperform enumeration.

That package would not just improve a checker. It would define a new formal language for computational nonresonance.

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
