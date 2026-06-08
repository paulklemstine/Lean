            ## Assignment: theorem symmCube_denominator_in_trace_det (α β X : ℂ) :

            Prove new, non-trivial theorems. Build on catalog theorems. Minimize sorry.

            ### Research Direction
            # Future Directions: Symmetric Square Transfer and Langlands Functoriality

## 1. Trace-Det Sufficiency for All Symmetric Powers

- **Hypothesis:** For every `n : ℕ`, the local Euler denominator of `Symⁿ` of a rank-2 parameter is a polynomial whose coefficients are universal polynomials in `trace = α + β` and `det = αβ`. Specifically, the denominator `∏ᵢ₌₀ⁿ (1 - αⁱβⁿ⁻ⁱ X)` can be written as a degree-(n+1) polynomial in X whose coefficients are elements of `ℤ[t, d]`.
- **Why it matters:** This would establish that functorial transfer for all symmetric powers depends only on conjugacy-invariant data, giving a complete algebraic foundation for the local Langlands correspondence for symmetric power lifts. It would also provide certified formulas for Hecke eigenvalues of all symmetric power L-functions.
- **Test:** Prove the `n = 3` case in Lean:
  ```lean
  theorem symmCube_denominator_in_trace_det (α β X : ℂ) :
      (1 - α^3 * X) * (1 - α^2 * β * X) * (1 - α * β^2 * X) * (1 - β^3 * X)
        = 1 - ((α+β)^3 - 2*(α+β)*(α*β)) * X + ... -- expand in t, d
  ```
  Alternatively, find a formal obstruction in the current API or produce counterexample for a specific n.
- **First step:** Define `symmPowerParameter (n : ℕ) (α β : ℂ) : Fin (n+1) → ℂ := fun i => α^(n-i) * β^i` and prove the n=3 denominator identity.

## 2. Semisimple Matrix Conjugacy Invariance

- **Hypothesis:** The symmetric-square local Euler factor depends only on the conjugacy class of a semisimple 2×2 matrix, not on its diagonalization. Concretely: if M, M' ∈ GL₂(ℂ) are conjugate (M' = P⁻¹MP for invertible P), then the symmetric square Euler denominators computed from their eigenvalues are equal.
- **Why it matters:** This would validate the representation-theoretic axiom that L-factors are conjugacy-class invariants, and would connect the eigenvalue-based formalization to the matrix-based formulation needed for non-split tori and ramified representations.
- **Test:** Prove equality for conjugate diagonalizable matrices in Lean:
  ```lean
  theorem symmSquare_euler_conjugacy_invariant (α β : ℂ) (P : Matrix (Fin 2) (Fin 2) ℂ)
      (hP : IsUnit P) (X : ℂ) :
      localEulerSymmSquare ⟨α, β⟩ X = localEulerSymmSquare ⟨α, β⟩ X
  ```
  More substantively, define `eigenvalues_of_matrix` and show `symmSquare_euler` factors through it. Identify which Mathlib lemmas about `Matrix.charpoly` and eigenvalue extraction are needed.
- **First step:** Formalize `charpolyCoeffs_conjugacy_invariant` showing that characteristic polynomial coefficients are conjugation-invariant, then derive the Euler factor invariance.

## 3. Finite Euler Product Coefficient Identities

- **Hypothesis:** The first nontrivial coefficient (coefficient of X) of a finite symmetric-square Euler product `∏_{v ∈ S} P_v(X)` equals the sum over local transformed traces: `- ∑_{v ∈ S} (α_v² + α_v β_v + β_v²)`. More generally, the k-th coefficient of the product is an elementary symmetric polynomial in the local symmetric-square traces.
- **Why it matters:** This connects local functoriality to global L-function coefficient formulas, the exact data needed for computational verification of the Langlands correspondence via modular form databases (LMFDB).
- **Test:** Expand the product over Finsets of sizes 1, 2, 3 and verify coefficient formulas:
  ```lean
  theorem finite_euler_linear_coeff (S : Finset ι) (α β : ι → ℂ) :
      -- coefficient of X in ∏_{v ∈ S} (1 - (α_v² + α_vβ_v + β_v²)X + ...)
      -- equals -∑_{v ∈ S} (α_v² + α_vβ_v + β_v²)
  ```
  Verify computationally for |S| = 1, 2, 3 using `#eval` over `ℚ`.
- **First step:** Define `symmSquareEulerPoly (α β : ι → ℂ) (v : ι) : Polynomial ℂ` as the formal cubic polynomial, then compute `(∏ v in S, symmSquareEulerPoly α β v).coeff 1`.

## 4. Palindromicity Under Determinant-One Normalization for Higher Symmetric Powers

- **Hypothesis:** For every `n : ℕ`, the local `Symⁿ` denominator polynomial with `det = αβ = 1` satisfies a self-reciprocity relation: `X^(n+1) · P(X⁻¹) = (-1)^(n+1) · P(X)` where P(X) = ∏ᵢ₌₀ⁿ (1 - αⁱβⁿ⁻ⁱ X).
- **Why it matters:** Palindromicity (functional equation symmetry) is the local manifestation of the global functional equation of L-functions. Proving it algebraically for all symmetric powers would give a certified local functional equation without analytic continuation.
- **Test:** Prove for n = 2 (already done as `symmSquare_palindromic_det_one` conceptually) and n = 3:
  ```lean
  theorem symmCube_palindromic_det_one (α β X : ℂ) (h : α * β = 1) :
      (1 - α^3*X) * (1 - α*X) * (1 - β*X) * (1 - β^3*X)
        = X^4 * ((1 - α^3*X⁻¹) * (1 - α*X⁻¹) * (1 - β*X⁻¹) * (1 - β^3*X⁻¹))
  ```
  Or produce a counterexample to the guessed sign/exponent normalization.
- **First step:** Prove `symmSquare_palindromic_det_one` rigorously (handling X⁻¹ for X ≠ 0 via a hypothesis or working with formal polynomials instead), then generalize.

## 5. Bridge to Certified Spectral Transfer Framework

- **Hypothesis:** There exists an abstract "spectral transfer" typeclass encompassing both iterative spectral bounds (as in spectral radius transfer for dynamical systems) and local Langlands symmetric-power transfer, unifying them through a common interface of: (1) source spectrum type, (2) transfer map, (3) invariant polynomial controlling the transferred spectrum.
- **Why it matters:** This would create a reusable formal framework connecting disparate areas of mathematics — dynamical systems, number theory, and representation theory — through their shared structure of spectral data transformation. It would enable code reuse and cross-pollination of proof techniques.
- **Test:** Define a typeclass and instantiate both examples:
  ```lean
  class SpectralTransfer (Source Target : Type*) where
    transferMap : Source → Target
    invariantPoly : Source → Polynomial ℂ
    transfer_respects_invariant : ∀ s, invariantPoly s = charPoly (transferMap s)

  instance : SpectralTransfer LocalGL2Parameter (ℂ × ℂ × ℂ) where ...
  ```
  Identify the obstruction if no clean common interface exists.
- **First step:** Define `SpectralTransfer` structure, instantiate for symmetric square, and attempt to instantiate for one other spectral transfer example in the codebase.


            ### Mathematical Framing
            # Future Directions: Symmetric Square Transfer and Langlands Functoriality

## 1. Trace-Det Sufficiency for All Symmetric Powers

- **Hypothesis:** For every `n : ℕ`, the local Euler denominator of `Symⁿ` of a rank-2 parameter is a polynomial whose coefficients are universal polynomials in `trace = α + β` and `det = αβ`. Specifically, the denominator `∏ᵢ₌₀ⁿ (1 - αⁱβⁿ⁻ⁱ X)` can be written as a degree-(n+1) polynomial in X whose coefficients are elements of `ℤ[t, d]`.
- **Why it matters:** This would establish that functorial transfer for all symmetric powers depends only on conjugacy-invariant data, giving a complete algebraic foundation for the local Langlands correspondence for symmetric power lifts. It would also provide certified formulas for Hecke eigenvalues of all symmetric power L-functions.
- **Test:** Prove the `n = 3` case in Lean:
  ```lean
  theorem symmCube_denominator_in_trace_det (α β X : ℂ) :
      (1 - α^3 * X) * (1 - α^2 * β * X) * (1 - α * β^2 * X) * (1 - β^3 * X)
        = 1 - ((α+β)^3 - 2*(α+β)*(α*β)) * X + ... -- expand in t, d
  ```
  Alternatively, find a formal obstruction in the current API or produce counterexample for a specific n.
- **First step:** Define `symmPowerParameter (n : ℕ) (α β : ℂ) : Fin (n+1) → ℂ := fun i => α^(n-i) * β^i` and prove the n=3 denominator identity.

## 2. Semisimple Matrix Conjugacy Invariance

- **Hypothesis:** The symmetric-square local Euler factor depends only on the conjugacy class of a semisimple 2×2 matrix, not on its diagonalization. Concretely: if M, M' ∈ GL₂(ℂ) are conjugate (M' = P⁻¹MP for invertible P), then the symmetric square Euler denominators computed from their eigenvalues are equal.
- **Why it matters:** This would validate the representation-theoretic axiom that L-factors are conjugacy-class invariants, and would connect the eigenvalue-based formalization to the matrix-based formulation needed for non-split tori and ramified representations.
- **Test:** Prove equality for conjugate diagonalizable matrices in Lean:
  ```lean
  theorem symmSquare_euler_conjugacy_invariant (α β : ℂ) (P : Matrix (Fin 2) (Fin 2) ℂ)
      (hP : IsUnit P) (X : ℂ) :
      localEulerSymmSquare ⟨α, β⟩ X = localEulerSymmSquare ⟨α, β⟩ X
  ```
  More substantively, define `eigenvalues_of_matrix` and show `symmSquare_euler` factors through it. Identify which Mathlib lemmas about `Matrix.charpoly` and eigenvalue extraction are needed.
- **First step:** Formalize `charpolyCoeffs_conjugacy_invariant` showing that characteristic polynomial coefficients are conjugation-invariant, then derive the Euler factor invariance.

## 3. Finite Euler Product Coefficient Identities

- **Hypothesis:** The first nontrivial coefficient (coefficient of X) of a finite symmetric-square Euler product `∏_{v ∈ S} P_v(X)` equals the sum over local transformed traces: `- ∑_{v ∈ S} (α_v² + α_v β_v + β_v²)`. More generally, the k-th coefficient of the product is an elementary symmetric polynomial in the local symmetric-square traces.
- **Why it matters:** This connects local functoriality to global L-function coefficient formulas, the exact data needed for computational verification of the Langlands correspondence via modular form databases (LMFDB).
- **Test:** Expand the product over Finsets of sizes 1, 2, 3 and verify coefficient formulas:
  ```lean
  theorem finite_euler_linear_coeff (S : Finset ι) (α β : ι → ℂ) :
      -- coefficient of X in ∏_{v ∈ S} (1 - (α_v² + α_vβ_v + β_v²)X + ...)
      -- equals -∑_{v ∈ S} (α_v² + α_vβ_v + β_v²)
  ```
  Verify computationally for |S| = 1, 2, 3 using `#eval` over `ℚ`.
- **First step:** Define `symmSquareEulerPoly (α β : ι → ℂ) (v : ι) : Polynomial ℂ` as the formal cubic polynomial, then compute `(∏ v in S, symmSquareEulerPoly α β v).coeff 1`.

## 4. Palindromicity Under Determinant-One Normalization for Higher Symmetric Powers

- **Hypothesis:** For every `n : ℕ`, the local `Symⁿ` denominator polynomial with `det = αβ = 1` satisfies a self-reciprocity relation: `X^(n+1) · P(X⁻¹) = (-1)^(n+1) · P(X)` where P(X) = ∏ᵢ₌₀ⁿ (1 - αⁱβⁿ⁻ⁱ X).
- **Why it matters:** Palindromicity (functional equation symmetry) is the local manifestation of the global functional equation of L-functions. Proving it algebraically for all symmetric powers would give a certified local functional equation without analytic continuation.
- **Test:** Prove for n = 2 (already done as `symmSquare_palindromic_det_one` conceptually) and n = 3:
  ```lean
  theorem symmCube_palindromic_det_one (α β X : ℂ) (h : α * β = 1) :
      (1 - α^3*X) * (1 - α*X) * (1 - β*X) * (1 - β^3*X)
        = X^4 * ((1 - α^3*X⁻¹) * (1 - α*X⁻¹) * (1 - β*X⁻¹) * (1 - β^3*X⁻¹))
  ```
  Or produce a counterexample to the guessed sign/exponent normalization.
- **First step:** Prove `symmSquare_palindromic_det_one` rigorously (handling X⁻¹ for X ≠ 0 via a hypothesis or working with formal polynomials instead), then generalize.

## 5. Bridge to Certified Spectral Transfer Framework

- **Hypothesis:** There exists an abstract "spectral transfer" typeclass encompassing both iterative spectral bounds (as in spectral radius transfer for dynamical systems) and local Langlands symmetric-power transfer, unifying them through a common interface of: (1) source spectrum type, (2) transfer map, (3) invariant polynomial controlling the transferred spectrum.
- **Why it matters:** This would create a reusable formal framework connecting disparate areas of mathematics — dynamical systems, number theory, and representation theory — through their shared structure of spectral data transformation. It would enable code reuse and cross-pollination of proof techniques.
- **Test:** Define a typeclass and instantiate both examples:
  ```lean
  class SpectralTransfer (Source Target : Type*) where
    transferMap : Source → Target
    invariantPoly : Source → Polynomial ℂ
    transfer_respects_invariant : ∀ s, invariantPoly s = charPoly (transferMap s)

  instance : SpectralTransfer LocalGL2Parameter (ℂ × ℂ × ℂ) where ...
  ```
  Identify the obstruction if no clean common interface exists.
- **First step:** Define `SpectralTransfer` structure, instantiate for symmetric square, and attempt to instantiate for one other spectral transfer example in the codebase.



            ### Existing Verified Theorems
            Existing theorems you can build on:
  1. `degree1_exact_from_cover_and_local_positivity` : theorem degree1_exact_from_cover_and_local_positivity
     (file: Bridges/ActivationNerve/MarginCosheaf.lean)
  2. `degree1_exact_from_cover_and_local_positivity` : theorem degree1_exact_from_cover_and_local_positivity
     (file: FINAL/Bridges/MarginCosheaf.lean)
  3. `exists_global_radius_of_finite_local_witnesses` : theorem exists_global_radius_of_finite_local_witnesses
     (file: FINAL/MachineLearning/NeuralSheafCohomology.lean)
  4. `exists_global_radius_of_finite_local_witnesses` : theorem exists_global_radius_of_finite_local_witnesses
     (file: MachineLearning/NeuralSheafCohomology.lean)
  5. `certified_radius_decreases_with_depth` : theorem certified_radius_decreases_with_depth (k : ℕ) (L : NNReal)
     (file: Speculative/AutoResearch/MachineLearning/OperadicDeepLearning/Foundations.lean)

### Previously Proved Theorems
No previous research cycles completed yet. This is a cold start — prioritize sorry_fill on the priority targets (CarmichaelComposite, Fib_gcd_identity) to close known open problems, or target cross-domain bridge theorems for novelty.


No specific files referenced. Use Mathlib and general knowledge.

            ---

            You are Aristotle. Pursue this research direction deeply and originally.
            Discover what matters. Prove what you can. Define what needs defining.
            Build on the catalog theorems referenced above.

            Use concrete types (Nat, Real, Finset, Matrix). Avoid trivial tautologies.
            If a direct proof fails, try the contrapositive, a constructive witness,
            or structural induction. Connect to at least one other domain for impact.

            ### Team Directive
            Create a team to conduct research, brainstorm testable hypotheses,
            run experiments to confirm or refute them, validate data,
            update knowledge base and iterate forever.

            Required: Lean 4 proofs, FUTURE_DIRECTIONS.md
            Optional: ARTICLE.md, RESEARCH_PAPER.md, demo.py

            FUTURE_DIRECTIONS.md is critical — it drives the next research cycle.
            Each direction must be a testable scientific hypothesis: a precise,
            falsifiable conjecture with a clear test that could confirm or refute it.
            Format each as:

            ### [Direction Title]
            **Conjecture**: A precise mathematical statement that can be proved or disproved.
            **Test**: What specific experiment, calculation, or proof attempt would
            confirm or refute this conjecture.
            **Impact**: If true, what new territory does this open? If false, what
            does the failure teach us?
            **Cross-domain**: Which other domains could this connect to?

            Do real science. Propose hypotheses that are bold enough to matter and
            specific enough to fail. Vague explorations like "study X further" or
            "extend Y" are not hypotheses — they are homework. Give us ideas that
            could change how we think about the problem.


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
