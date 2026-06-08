            ## Assignment: **Conjecture**: For every prime p ≡ 3 (mod 4), the Paley Type I construction pro

            Prove new, non-trivial theorems. Build on catalog theorems. Minimize sorry.

            ### Research Direction
            # Future Directions

## Hypothesis 1: Parametric Paley Certification

**Conjecture**: For every prime p ≡ 3 (mod 4), the Paley Type I construction produces a certified Hadamard matrix of order p + 1, provable in Lean 4 using Mathlib's finite field and quadratic character infrastructure.

**Test**: Formalize the Jacobsthal matrix Q over 𝔽_p using `ZMod p` and the Legendre symbol `legendreSym`. Prove Q · Q^T = pI − J (where J is all-ones) using character sum identities (specifically, the evaluation of ∑_{t ∈ 𝔽_p} χ(t)χ(t+a) for the quadratic character χ). Then lift to ℤ and verify the Paley matrix [[1, j^T], [−j, Q+I]] satisfies HH^T = (p+1)I.

**Refutation**: The conjecture would be refuted if Mathlib's character sum infrastructure is insufficient to prove the key orthogonality ∑_{t} χ(t)χ(t+a) = −1 for a ≠ 0, which requires the explicit evaluation of Jacobi sums. Verify by attempting the formalization for p = 3 and p = 7 as test cases.

**Impact**: Would provide a formally certified infinite family of Hadamard orders of the form p + 1 (primes p ≡ 3 mod 4), immediately generating thousands of new certified orders via Kronecker closure. This is the single highest-impact extension of the current work.

---

## Hypothesis 2: Formal Hadamard-BIBD Bridge

**Conjecture**: From a normalized Hadamard matrix H of order 4n (formalized in Lean), the (4n−1) × (4n−1) core incidence matrix A (defined by A_{ij} = (1 − H_{i+1,j+1})/2) satisfies the symmetric BIBD equations:
- Each row sum equals 2n − 1
- A · A^T = (n−1)I + (2n−1−n+1)·(J − I) ... more precisely, A · A^T = nI + (n−1)J_reduced

**Test**: Define the extraction map from normalized Hadamard matrices to binary incidence matrices in Lean 4. Prove the row-sum and Gram matrix identities using the dot-product lemmas already formalized. Start with the n = 1 case (trivial 3×3 design from H₄) and generalize.

**Refutation**: The conjecture could fail if the formalization of "deleting a row and column" introduces intractable type-theoretic complications with `Fin (4n)` vs `Fin (4n − 1)`. Test by attempting the extraction for the explicit H₄ first.

**Impact**: Would formally bridge Hadamard matrix theory to combinatorial design theory, enabling certified BIBD constructions for all certified Hadamard orders. This opens the door to formal finite geometry.

---

## Hypothesis 3: Kronecker Saturation Density

**Conjecture**: The density of certified Hadamard orders (as a fraction of all multiples of 4) within [4, N] converges to a positive limit as N → ∞, and this limit is at least 0.8 when using Sylvester + Paley Type I + Paley Type II + Kronecker closure.

**Test**: Implement the certified existence engine for N up to 10,000 and 100,000. Compute the coverage fraction and fit an asymptotic model. Compare with theoretical predictions from the density of Paley primes (which has density 1/2 among primes by Dirichlet's theorem, giving positive Kronecker density).

**Refutation**: If the coverage fraction drops below 0.7 for N = 100,000, or if the growth rate is sub-logarithmic rather than polynomial, the conjecture is likely false. Specific counterexamples: orders like 4 · p where p is a prime ≡ 1 (mod 4) and neither p−1 nor 2p−1 is a prime power may create persistent gaps.

**Impact**: A positive density result would quantify exactly how much of the Hadamard conjecture is resolved by classical constructions, sharpening the frontier of the remaining open problem.

---

## Hypothesis 4: Equivalence Class Distinguishability

**Conjecture**: Inequivalent Hadamard matrices of the same order n ≥ 16 can be distinguished by a formally computable invariant based on the spectrum of the "row intersection graph" — where vertices are rows and edge weights are |⟨r_i, r_j⟩| (which is 0 for Hadamard matrices, but becomes non-trivial after normalization and core extraction).

**Test**: For the 5 known inequivalent Hadamard matrices of order 16:
1. Normalize each matrix
2. Compute the core (delete first row/column)
3. Build the intersection matrix: I_{ij} = #{k : core_{ik} = core_{jk} = 1}
4. Compute the spectrum (eigenvalues) of I
5. Check if spectra distinguish all 5 inequivalent classes

**Refutation**: Find two inequivalent Hadamard matrices of the same order with identical intersection spectra. This would demonstrate that the invariant is too coarse.

**Impact**: A successful distinguishing invariant would provide a certified equivalence test for Hadamard matrices, enabling formal enumeration of equivalence classes for small orders.

---

## Hypothesis 5: Code Optimality Certificate

**Conjecture**: The equidistant binary code extracted from an n × n Hadamard matrix (2n codewords, length n, distance n/2) meets the Plotkin bound with equality, and this can be formally proved in Lean 4.

**Test**: 
1. Formalize the Plotkin bound: for a binary code with M codewords of length n and minimum distance d, if d is even and 2d > n, then M ≤ 2d/(2d − n). For 2d = n (our case), the bound becomes M ≤ 2n.
2. Verify that the Hadamard code achieves M = 2n with d = n/2.
3. Prove equality in the Plotkin bound.

**Refutation**: The conjecture could fail if the Plotkin bound in its standard form doesn't exactly match the Hadamard code parameters (e.g., if the bound gives M ≤ 2n but equality requires additional conditions). Check the exact bound statement.

**Impact**: Would provide the first formally certified optimality result in coding theory, connecting Hadamard matrices to extremal combinatorics. This would demonstrate that Hadamard codes are not merely good but provably best possible among equidistant codes.


            ### Mathematical Framing
            # Future Directions

## Hypothesis 1: Parametric Paley Certification

**Conjecture**: For every prime p ≡ 3 (mod 4), the Paley Type I construction produces a certified Hadamard matrix of order p + 1, provable in Lean 4 using Mathlib's finite field and quadratic character infrastructure.

**Test**: Formalize the Jacobsthal matrix Q over 𝔽_p using `ZMod p` and the Legendre symbol `legendreSym`. Prove Q · Q^T = pI − J (where J is all-ones) using character sum identities (specifically, the evaluation of ∑_{t ∈ 𝔽_p} χ(t)χ(t+a) for the quadratic character χ). Then lift to ℤ and verify the Paley matrix [[1, j^T], [−j, Q+I]] satisfies HH^T = (p+1)I.

**Refutation**: The conjecture would be refuted if Mathlib's character sum infrastructure is insufficient to prove the key orthogonality ∑_{t} χ(t)χ(t+a) = −1 for a ≠ 0, which requires the explicit evaluation of Jacobi sums. Verify by attempting the formalization for p = 3 and p = 7 as test cases.

**Impact**: Would provide a formally certified infinite family of Hadamard orders of the form p + 1 (primes p ≡ 3 mod 4), immediately generating thousands of new certified orders via Kronecker closure. This is the single highest-impact extension of the current work.

---

## Hypothesis 2: Formal Hadamard-BIBD Bridge

**Conjecture**: From a normalized Hadamard matrix H of order 4n (formalized in Lean), the (4n−1) × (4n−1) core incidence matrix A (defined by A_{ij} = (1 − H_{i+1,j+1})/2) satisfies the symmetric BIBD equations:
- Each row sum equals 2n − 1
- A · A^T = (n−1)I + (2n−1−n+1)·(J − I) ... more precisely, A · A^T = nI + (n−1)J_reduced

**Test**: Define the extraction map from normalized Hadamard matrices to binary incidence matrices in Lean 4. Prove the row-sum and Gram matrix identities using the dot-product lemmas already formalized. Start with the n = 1 case (trivial 3×3 design from H₄) and generalize.

**Refutation**: The conjecture could fail if the formalization of "deleting a row and column" introduces intractable type-theoretic complications with `Fin (4n)` vs `Fin (4n − 1)`. Test by attempting the extraction for the explicit H₄ first.

**Impact**: Would formally bridge Hadamard matrix theory to combinatorial design theory, enabling certified BIBD constructions for all certified Hadamard orders. This opens the door to formal finite geometry.

---

## Hypothesis 3: Kronecker Saturation Density

**Conjecture**: The density of certified Hadamard orders (as a fraction of all multiples of 4) within [4, N] converges to a positive limit as N → ∞, and this limit is at least 0.8 when using Sylvester + Paley Type I + Paley Type II + Kronecker closure.

**Test**: Implement the certified existence engine for N up to 10,000 and 100,000. Compute the coverage fraction and fit an asymptotic model. Compare with theoretical predictions from the density of Paley primes (which has density 1/2 among primes by Dirichlet's theorem, giving positive Kronecker density).

**Refutation**: If the coverage fraction drops below 0.7 for N = 100,000, or if the growth rate is sub-logarithmic rather than polynomial, the conjecture is likely false. Specific counterexamples: orders like 4 · p where p is a prime ≡ 1 (mod 4) and neither p−1 nor 2p−1 is a prime power may create persistent gaps.

**Impact**: A positive density result would quantify exactly how much of the Hadamard conjecture is resolved by classical constructions, sharpening the frontier of the remaining open problem.

---

## Hypothesis 4: Equivalence Class Distinguishability

**Conjecture**: Inequivalent Hadamard matrices of the same order n ≥ 16 can be distinguished by a formally computable invariant based on the spectrum of the "row intersection graph" — where vertices are rows and edge weights are |⟨r_i, r_j⟩| (which is 0 for Hadamard matrices, but becomes non-trivial after normalization and core extraction).

**Test**: For the 5 known inequivalent Hadamard matrices of order 16:
1. Normalize each matrix
2. Compute the core (delete first row/column)
3. Build the intersection matrix: I_{ij} = #{k : core_{ik} = core_{jk} = 1}
4. Compute the spectrum (eigenvalues) of I
5. Check if spectra distinguish all 5 inequivalent classes

**Refutation**: Find two inequivalent Hadamard matrices of the same order with identical intersection spectra. This would demonstrate that the invariant is too coarse.

**Impact**: A successful distinguishing invariant would provide a certified equivalence test for Hadamard matrices, enabling formal enumeration of equivalence classes for small orders.

---

## Hypothesis 5: Code Optimality Certificate

**Conjecture**: The equidistant binary code extracted from an n × n Hadamard matrix (2n codewords, length n, distance n/2) meets the Plotkin bound with equality, and this can be formally proved in Lean 4.

**Test**: 
1. Formalize the Plotkin bound: for a binary code with M codewords of length n and minimum distance d, if d is even and 2d > n, then M ≤ 2d/(2d − n). For 2d = n (our case), the bound becomes M ≤ 2n.
2. Verify that the Hadamard code achieves M = 2n with d = n/2.
3. Prove equality in the Plotkin bound.

**Refutation**: The conjecture could fail if the Plotkin bound in its standard form doesn't exactly match the Hadamard code parameters (e.g., if the bound gives M ≤ 2n but equality requires additional conditions). Check the exact bound statement.

**Impact**: Would provide the first formally certified optimality result in coding theory, connecting Hadamard matrices to extremal combinatorics. This would demonstrate that Hadamard codes are not merely good but provably best possible among equidistant codes.



            ### Existing Verified Theorems
            Existing theorems you can build on:
  1. `finite_key_certificate_existence` : theorem finite_key_certificate_existence
     (file: Speculative/AutoResearch/AlgebraicInvariantCryptography.lean)
  2. `prime_one_mod_four_has_sum_two_squares` : theorem prime_one_mod_four_has_sum_two_squares
     (file: FINAL/Pythagorean/TropicalBerggrenZeta.lean)
  3. `prime_one_mod_four_has_sum_two_squares` : theorem prime_one_mod_four_has_sum_two_squares
     (file: Pythagorean/TropicalBerggrenZeta.lean)
  4. `prime_power_liars_bound` : theorem prime_power_liars_bound (p k : ℕ) (hp : Nat.Prime p) (hk : 2 ≤ k)
     (file: Speculative/PrimalityTesting/MillerRabinBound.lean)
  5. `prime_power_fiber_decorrelation_row_bound` : theorem prime_power_fiber_decorrelation_row_bound
     (file: FINAL/Tropical/PrimePowerAmplification.lean)

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
