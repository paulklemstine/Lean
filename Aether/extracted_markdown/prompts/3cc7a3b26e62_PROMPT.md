## Assignment: Lattice Cryptography: LWE Hardness — From Worst-Case Geometry to Average-Case Encryption

You are not being asked to merely encode textbook cryptography. You are being asked to formalize the geometric engine that made modern post-quantum cryptography possible: the passage from worst-case lattice hardness to average-case noisy linear equations, and then from that hardness to a concrete encryption primitive. The breakthrough target is a Lean 4 development that makes the *hardness pipeline itself* mathematically explicit and reusable.

This direction is revolutionary because it sits at the junction of:
- geometry of numbers,
- probability on finite abelian groups,
- average-case complexity,
- algebraic number theory via ring-LWE,
- and information-theoretic security extraction.

A successful formalization here would not just certify one cryptosystem. It would open a verified theory of **noise-stability hardness reductions**, enabling future formal work on FHE, signatures, module-LWE, and structured post-quantum assumptions.

## Mode
**formalize + prove**

## Core Breakthrough Objective

Formalize a mathematically clean, Lean-verifiable version of the LWE hardness pipeline with three layers:

1. **Abstract LWE decisional/search framework** over `ZMod q`.
2. **Dual-Regev encryption scheme** with a proof of CPA security from decisional LWE advantage.
3. **Ring-LWE abstraction** showing how algebraic structure induces an LWE-style distribution and preserves a hardness-to-security implication.

You should be ambitious but mathematically strategic: do **not** attempt a full analytic quantum reduction if Mathlib’s current measure/Fourier infrastructure makes that infeasible. Instead, isolate the reduction into formalizable lemmas and prove a *rigorous theorem schema* that captures the reduction’s mathematical heart. The point is to create the first reusable Lean framework in which Regev-style hardness arguments can live.

---

## Precise Theorem Targets

You must prove at least **3 substantial theorems** with nontrivial proof structure. At least one should use contradiction or hybrid reasoning, at least one should use multi-step `calc`, and at least one should use structural decomposition (`rcases`, induction on samples, or recursive hybrids).

### New Definitions Required

Define at least one genuinely new concept not already in the catalog, for example:

- `LWESample`
- `LWEProblem`
- `DualRegevPublicKey`
- `AdvantageBound`
- `RingLWEDistribution`
- `NoiseSmudging` or `ErrorDomination`

Suggested Lean structures:

```lean
structure LWESample (n q : ℕ) where
  a : Fin n → ZMod q
  b : ZMod q

structure LWEInstance (n m q : ℕ) where
  secret : Fin n → ZMod q
  samples : Fin m → LWESample n q

def innerMod {n q : ℕ} (a s : Fin n → ZMod q) : ZMod q :=
  ∑ i, a i * s i

def IsLWESample {n q : ℕ} (χ : Type _) [Fintype χ] [DecidableEq χ]
    (embed : χ → ZMod q) (s : Fin n → ZMod q) (x : LWESample n q) : Prop :=
  ∃ e : χ, x.b = innerMod x.a s + embed e
```

For ring-LWE:

```lean
structure RingLWESample (R : Type _) [CommRing R] (q : ℕ) where
  a : R
  b : R
```

If quotient rings are easier:

```lean
def QuotRing := Polynomial (ZMod q) ⧸ Ideal.span ({f} : Set (Polynomial (ZMod q)))
```

---

## Theorem 1: Hybrid indistinguishability implies CPA security of Dual-Regev

This is the most important theorem to fully prove.

### Informal statement
If the underlying matrix/sample distribution is decisional-LWE secure, then the Dual-Regev public-key encryption scheme is CPA secure, with adversarial advantage bounded by the LWE distinguishing advantage plus negligible correctness failure.

### Suggested Lean theorem signature
You may need to adapt types, but aim for something close to:

```lean
theorem dualRegev_cpa_security_bound
    {n m q : ℕ}
    (χ : Type _) [Fintype χ] [DecidableEq χ]
    (embed : χ → ZMod q)
    (pk : DualRegevPublicKey n m q)
    (AdvLWE AdvCPA εcorr : ℚ)
    (hred : AdvCPA ≤ AdvLWE + εcorr) :
    AdvCPA ≤ AdvLWE + εcorr := by
```

That bare signature is tautological, so the real target should encode the reduction:

```lean
theorem dualRegev_cpa_security_of_lwe
    {n m q : ℕ}
    (χ : Type _) [Fintype χ] [DecidableEq χ]
    (embed : χ → ZMod q)
    (A : Type _) -- adversary type
    (B : Type _) -- reduction type
    (hB : LWEAdvantage B n m q χ embed ≥ CPAAdvantage A n m q χ embed - CorrectnessError n m q χ embed) :
    CPAAdvantage A n m q χ embed ≤
      LWEAdvantage B n m q χ embed + CorrectnessError n m q χ embed := by
```

### Why this matters
This theorem transforms abstract hardness into a certified cryptographic guarantee. It is the bridge from average-case lattice hardness to actual security of an implemented primitive.

### Proof strategy options

**Strategy A: Explicit game-hopping hybrids**
1. Define Game 0 = real Dual-Regev CPA experiment.
2. Define Game 1 = replace LWE public key component with uniform.
3. Define Game 2 = replace challenge ciphertext component with uniform independent mask.
4. Prove:
   - `|Pr[G0]-Pr[G1]| ≤ AdvLWE`
   - `Pr[G1]=Pr[G2]` or differs only by correctness failure
   - `AdvCPA ≤ AdvLWE + εcorr`
   
This is the most promising strategy because Lean handles finite probability spaces and equality of experiments better than analytic reduction arguments.

**Strategy B: Coupling-style argument on sample distributions**
1. Define a relation coupling real and ideal ciphertext distributions.
2. Show any distinguisher transfers to an LWE distinguisher.
3. Bound message advantage by statistical distance/coupling defect.

This is elegant and reusable, especially if probability tools are available.

**Strategy C: Direct reduction by contradiction**
1. Assume a CPA adversary with large advantage.
2. Build a distinguisher against LWE.
3. Derive contradiction with assumed LWE hardness bound.

This is ideal if your security notions are encoded as supremum/upper bounds rather than explicit experiments.

---

## Theorem 2: Search-to-decision style transfer in a finite abstract LWE model

A full classical/quantum Regev reduction may be too large, but you can prove a rigorous finite-model theorem showing that solving search-LWE reduces to distinguishing LWE from uniform under a hybrid oracle decomposition.

### Informal statement
If there exists an oracle distinguishing LWE samples from uniform with nonzero advantage, then there exists a procedure recovering at least one secret coordinate with nontrivial advantage; iterating yields a search-to-decision reduction in the finite setting.

### Suggested Lean theorem signature

```lean
theorem search_from_decision_LWE_coordinate
    {n m q : ℕ}
    (χ : Type _) [Fintype χ] [DecidableEq χ]
    (embed : χ → ZMod q)
    (D : OracleDistinguisher n m q χ embed)
    (ε : ℚ)
    (hε : 0 < ε)
    (hadv : ε ≤ DecisionLWEAdvantage D n m q χ embed) :
    ∃ i : Fin n, ∃ R : CoordinateRecoveryAlg n m q χ embed,
      (ε / n) ≤ CoordinateRecoveryAdvantage R i := by
```

A stronger recursive version:

```lean
theorem search_from_decision_LWE
    {n m q : ℕ}
    (χ : Type _) [Fintype χ] [DecidableEq χ]
    (embed : χ → ZMod q)
    (hqdim : 0 < n)
    (D : OracleDistinguisher n m q χ embed)
    (ε : ℚ)
    (hadv : ε ≤ DecisionLWEAdvantage D n m q χ embed) :
    ∃ R : SearchRecoveryAlg n m q χ embed,
      ε / n ≤ SearchRecoveryAdvantage R := by
```

### Why this matters
This theorem is the finite combinatorial skeleton of Regev’s reduction philosophy: *distinguishing noisy structure from randomness leaks hidden linear information*. Even if you cannot formalize the full quantum reduction, this result would be new and foundational in Lean.

### Proof strategy options

**Strategy A: Hybrid over coordinates**
1. Define hybrids where the first `k` coordinates of the secret are randomized.
2. Telescope the distinguishing gap across adjacent hybrids.
3. By averaging, one coordinate must contribute at least `ε / n`.
4. Recover that coordinate using oracle bias.

This is likely the best path: it uses finite combinatorics, pigeonhole/averaging, and avoids heavy analysis.

**Strategy B: Fourier character decomposition over `(ZMod q)^n`**
1. Express distinguishing bias as correlation with additive characters.
2. Show nontrivial bias implies a nonzero Fourier coefficient.
3. Extract a linear form correlated with the secret.
4. Deduce coordinate recovery under basis projections.

This is deeper and opens a cross-domain bridge to harmonic analysis on finite groups.

**Strategy C: Contrapositive information-theoretic route**
1. Assume all coordinates are unrecoverable.
2. Show all adjacent hybrids are indistinguishable.
3. Sum the bounds to show full decision advantage is small.

This may be easiest if your framework defines “advantage” abstractly via bounded distinguishers.

---

## Theorem 3: Ring-LWE induces module-LWE / coefficient-LWE security transfer

This is your cross-domain theorem connecting algebraic number theory and cryptography.

### Informal statement
For a finite quotient ring presented with a chosen basis, every ring-LWE sample induces an ordinary LWE sample on coefficient vectors; therefore any distinguisher against coefficient-embedded ring-LWE yields a distinguisher against the associated module-LWE problem.

### Suggested Lean theorem signature

```lean
theorem ringLWE_to_coefficientLWE
    {q n : ℕ}
    (R : Type _) [CommRing R] [Fintype R] [DecidableEq R]
    (basis : Basis (Fin n) (ZMod q) R)
    (x : RingLWESample R q) :
    ∃ y : LWESample n q,
      CoeffRep basis x = y := by
```

More meaningful reduction form:

```lean
theorem ringLWE_advantage_le_coefficientLWE_advantage
    {q n : ℕ}
    (R : Type _) [CommRing R] [Fintype R] [DecidableEq R]
    [Module (ZMod q) R]
    (basis : Basis (Fin n) (ZMod q) R)
    (D : CoeffLWEDistinguisher n q) :
    RingLWEAdvantage R q basis D ≤ CoefficientLWEAdvantage n q (transportDistinguisher basis D) := by
```

### Why this matters
This theorem turns ring-LWE from a black-box structured assumption into an explicit algebraic reduction principle. It creates a verified pathway from ideal lattices and quotient rings to standard LWE semantics.

### Proof strategy options

**Strategy A: Basis transport**
1. Define coefficient representation using `basis.repr`.
2. Show ring multiplication by public `a` induces a linear map on coefficients.
3. Translate `b = a*s + e` in the ring into vector-form LWE.
4. Conclude distinguisher transport.

This is probably the strongest and most reusable route.

**Strategy B: Matrix representation of ring multiplication**
1. Associate to each `a : R` a multiplication matrix `M_a`.
2. Rewrite ring-LWE sample as `b_vec = M_a s_vec + e_vec`.
3. Treat as module-LWE.
4. Bound advantages by exact experiment equivalence.

This is more computational and algorithmic, excellent for `demo.py`.

**Strategy C: Quotient polynomial ring specialization**
1. Take `R = (ZMod q)[X]/(f)`.
2. Use coefficient representatives modulo `f`.
3. Prove the sample transport concretely for cyclotomic-like rings.

This gives a more explicit path if generic basis formalization is too abstract.

---

## Stretch Theorem 4: Smudging / entropy preservation under noise addition

This is a strong cross-connection to entropy extraction and the existing catalog.

### Informal statement
Adding independent error from a sufficiently spread distribution to a linear form over `ZMod q` does not decrease min-entropy below a computable bound; hence LWE-style masking supports post-quantum key extraction.

### Suggested Lean theorem signature

```lean
theorem lwe_minEntropy_lower_bound
    {n q : ℕ}
    (χ : Type _) [Fintype χ] [DecidableEq χ]
    (embed : χ → ZMod q)
    (s : Fin n → ZMod q)
    (ha : True) :
    MinEntropy (fun x : LWESample n q => x.b) ≥
      MinEntropy (fun e : χ => embed e) := by
```

Or more reduction-oriented:

```lean
theorem lwe_key_security_from_entropy
    {n q : ℕ}
    (hsec : LWEHard n q)
    (hent : SufficientMinEntropy n q) :
    ExtractedKeySecure n q := by
```

### Build explicitly on catalog theorems
Use:
- `post_quantum_key_security_from_minEntropy`
- `trop_post_quantum_key_security`
- `lattice_exponential_security`
- `berggren_post_quantum_security`

The point is not to name-drop them, but to compose them:
1. prove an LWE min-entropy or unpredictability lemma,
2. feed it into `post_quantum_key_security_from_minEntropy`,
3. conclude a derived security statement for keys obtained from noisy lattice samples.

This is a major cross-domain bridge: **lattice hardness + entropy extraction + certified post-quantum security**.

---

## Lean 4 Type-Theoretic Guidance

Use finite types aggressively. A mathematically powerful but Lean-friendly setup is:
- vectors as `Fin n → ZMod q`,
- distributions either as finite support mass functions or abstract experiment probabilities over finite sample spaces,
- advantages as rational numbers or reals bounded by finite sums,
- hybrids indexed by `Fin (n+1)` or `Nat`.

Suggested core aliases:

```lean
abbrev Vec (n q : ℕ) := Fin n → ZMod q

def dot {n q : ℕ} (x y : Vec n q) : ZMod q :=
  ∑ i, x i * y i

def uniformSampleSpace (α : Type _) [Fintype α] := α

def lweEquation {n q : ℕ} (a s : Vec n q) (e : ZMod q) : ZMod q :=
  dot a s + e
```

For security games:

```lean
def CPAAdvantage (...) : ℚ := ...
def DecisionLWEAdvantage (...) : ℚ := ...
def CorrectnessError (...) : ℚ := ...
```

You do **not** need full cryptographic monads if they obstruct progress; finite experiment semantics are enough.

---

## Proof Architecture

You must include at least 2–3 proof strategy steps per major theorem in the file comments or surrounding documentation.

### Recommended proof flow
1. Define algebraic LWE sample semantics.
2. Define decision advantage and search recovery notions.
3. Prove hybrid lemmas for replacing true LWE by uniform.
4. Derive CPA security of Dual-Regev.
5. Define ring-LWE coefficient transport.
6. Prove reduction from ring-LWE distinguishing to coefficient/module-LWE distinguishing.
7. If possible, connect to entropy extraction using existing catalog results.

---

## Catalog Building Blocks to Use Explicitly

You already have:
1. `berggren_post_quantum_security`
   - file: `Cryptography/BerggrenPostQuantumLattices.lean`
   - file: `FINAL/Cryptography/BerggrenPostQuantumLattices.lean`

2. `post_quantum_key_security_from_minEntropy`
   - file: `Cryptography/EntropyExtraction/LeftoverHash.lean`

3. `classical_ge_quantum_security`
   - file: `Cryptography/QuantumGroupCrypto/Foundation.lean`

4. `trop_post_quantum_key_security`
   - file: `Cryptography/TropicalEntropy.lean`

5. `lattice_exponential_security`
   - file: `Cryptography/TropicalOneWayFoundations.lean`

6. `security_dimension_128_quantum`
   - file: `Cryptography/TropicalPostQuantumPrimitives.lean`

### How to build on them
- Use `post_quantum_key_security_from_minEntropy` as the final extraction step after proving an LWE unpredictability/min-entropy lemma.
- Use `lattice_exponential_security` as a comparative asymptotic benchmark: derive a theorem showing your LWE-style construction inherits or interfaces with lattice-based security scaling.
- Use `classical_ge_quantum_security` to phrase a theorem that any classical advantage bound you derive is automatically meaningful in a quantum-threat setting.
- Use `berggren_post_quantum_security` as a lattice-hardness anchor: even if not directly equivalent to LWE, position your new theorems as a bridge from abstract lattice security theorems to concrete noisy linear cryptosystems.

---

## Cross-Domain Connections You Must Include

At least one theorem and the surrounding writeup must explicitly connect LWE to a different domain.

### Strong options
1. **Harmonic analysis on finite abelian groups**
   - decision-LWE bias as Fourier correlation.
   - This is mathematically deep and unexpected.

2. **Information theory / entropy extraction**
   - noisy linear equations preserve extractable secrecy.
   - Build with `LeftoverHash.lean`.

3. **Algebraic number theory**
   - ring-LWE as coefficient transport from quotient rings / ideal lattices.

4. **Complexity-theoretic hybrid arguments**
   - formal game hopping as a discrete analogue of statistical mechanics phase interpolation.

If possible, state and prove a theorem of the form:
“Nonzero decision advantage implies nontrivial Fourier coefficient of the induced sample distribution.”
That would be a field-opening connection between lattice cryptography and finite harmonic analysis.

---

## Conjecture With Testable Prediction

You must state at least one falsifiable conjecture with a concrete computational test.

### Recommended conjecture
**Conjecture (`RingLWE_basis_conditioning_gap`)**:  
For quotient rings `R = (ZMod q)[X]/(f)` with two different natural bases `B₁, B₂`, the empirical distinguishing advantage of coefficient-embedded ring-LWE under bounded noise is minimized by the basis with smallest multiplication-matrix spectral spread.

This is falsifiable:
- choose small `q, n`,
- compute multiplication matrices under several bases,
- simulate ring-LWE samples,
- train/test a distinguisher,
- compare empirical advantage against spectral spread.

Alternative conjecture:
**Conjecture (`hybrid_loss_sublinear`)**:  
In finite-dimensional search-from-decision LWE reductions, the empirical hybrid loss scales sublinearly in dimension for discretized Gaussian-like error distributions.

This is also testable by simulation.

---

## Verified Algorithm / Computational Deliverable

You must produce a verified algorithm, not just theorems.

### Minimum algorithmic target
A certified reduction or simulator such as:
- `decisionToCoordinateRecovery`
- `dualRegevEncrypt` / `dualRegevDecrypt`
- `ringToCoeffSample`
- `hybridGameAdvantageEstimator`

The algorithm should have at least one correctness/security theorem formally proved.

Example target:

```lean
def dualRegevEncrypt
    {n m q : ℕ} :
    DualRegevPublicKey n m q → ZMod q → Ciphertext n m q := ...

theorem dualRegev_decrypt_correct
    {n m q : ℕ}
    (sk : DualRegevSecretKey n q)
    (pk : DualRegevPublicKey n m q)
    (μ : ZMod q) :
    WellFormedNoiseBound sk pk μ →
    dualRegevDecrypt sk (dualRegevEncrypt pk μ) = μ := by
```

---

## Demo Requirements

Provide `demo.py` that:
1. samples small LWE and ring-LWE instances,
2. demonstrates Dual-Regev encryption/decryption,
3. visualizes hybrid games or distinguishing advantage,
4. tests the conjecture on small parameters,
5. reports empirical advantage vs. basis/noise parameters.

The demo should be interactive or parameterized from the command line.

---

## Mandatory Deliverables

You must produce **all** of the following:

1. **Lean file(s)** with at least 3 substantial theorems and minimized sorrys.
2. **FUTURE_DIRECTIONS.md** with 3–5 falsifiable scientific hypotheses, each with:
   - precise conjecture,
   - why it matters,
   - concrete computational or formal test that could refute it.
3. **RESEARCH_PAPER.md** as a standalone scientific paper:
   - problem statement,
   - theorem statements,
   - proof ideas,
   - significance,
   - relation to worst-case/average-case hardness,
   - next open problems.
4. **ARTICLE.md** in Scientific American style:
   - explain LWE, noisy equations, lattices, and why this matters for post-quantum cryptography.
5. **A verified algorithm or computational method**
   - encryption, reduction, or sample transport.
6. **demo.py**
   - must demonstrate the result interactively or via reproducible experiments.

---

## Application Keywords

post-quantum cryptography, learning with errors, worst-case to average-case reduction, GapSVP, dual-Regev encryption, CPA security, ring-LWE, module-LWE, ideal lattices, finite harmonic analysis, entropy extraction, leftover hash lemma, hybrid arguments, algebraic number theory, verified cryptography, Lean 4, Mathlib, quantum-resistant encryption

---

## Final Charge

Do not settle for a shallow encoding of “LWE exists.” Build the first reusable formal scaffold in Lean where noisy linear algebra, lattice hardness, hybrid security proofs, and algebraic ring structure coexist. If you do this right, you will not merely formalize a cryptosystem—you will formalize a new *language* for post-quantum hardness reductions.

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

Research domain: Cryptography
Research mode: prove
