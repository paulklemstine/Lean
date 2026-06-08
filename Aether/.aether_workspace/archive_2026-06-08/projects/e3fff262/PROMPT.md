            ## Assignment: **Conjecture.** For any admissible tuple H and any squarefree integer M = p₁ · p

            Prove new, non-trivial theorems. Build on catalog theorems. Minimize sorry.

            ### Research Direction
            # Future Directions: Falsifiable Hypotheses for Formal Prime Gap Infrastructure

## Hypothesis 1: Multiplicativity of Survivor Counts for Arbitrary Squarefree Moduli

**Conjecture.** For any admissible tuple H and any squarefree integer M = p₁ · p₂ · … · pₙ (distinct primes), the number of survivor residues modulo M factors as a product of local survivor counts:

$$|\{a \in [0, M) : \forall h \in H,\ \gcd(a + h, M) = 1\}| = \prod_{i=1}^{n} (p_i - \nu_{p_i}(H))$$

where ν_p(H) = |H mod p|.

**Test.** Formalize the theorem `card_survivors_mul_of_coprime` asserting that for coprime moduli m, n, the survivor count modulo m·n equals the product of survivor counts modulo m and n. Then specialize to primorials. A computational sweep over all squarefree moduli up to 10⁵ with tuples of size ≤ 10 confirms or refutes the formula.

**Infrastructure needed.** A formal CRT bijection theorem at the level of finite sets (not just existence), proving that the map ℤ/mnℤ → ℤ/mℤ × ℤ/nℤ restricts to a bijection on survivor sets. This requires `ZMod.chineseRemainder` from Mathlib composed with set-level bijection lemmas.

**Impact if true.** This would complete the combinatorial foundation of sieve theory: the exact survivor count is a multiplicative function of the modulus, yielding a formal Euler product for the sieve density. It would also give the first machine-verified derivation of the Hardy–Littlewood singular series.

---

## Hypothesis 2: Tight Diameter Bounds for Optimal Admissible k-Tuples

**Conjecture.** For every k ≥ 2, the minimal diameter D(k) of an admissible k-tuple satisfies

$$D(k) \leq k \cdot (\ln k + \ln \ln k + 6)$$

This is sharper than the Hensley–Richards bound D(k) ~ k log k and matches computational data for k ≤ 342.

**Test.** Implement a certified exhaustive search for D(k) up to k = 20, verify the bound computationally for k ≤ 1000 using greedy algorithms, and formalize the inequality D(k) < k · (ln k + ln ln k + 6) for all k ≤ N where N is the search frontier. Any counterexample immediately refutes the conjecture.

**Infrastructure needed.** A formalized greedy admissible tuple construction algorithm with a verified upper bound on its output diameter. This requires decidable admissibility (already achieved) plus an inductive bound on the next admissible offset.

**Impact if true.** This would give the tightest known formal upper bound on prime gap sizes achievable by the Maynard–Tao method. Combined with the threshold existence theorem, it would yield an explicit computable function k ↦ D(k) bounding the gap between consecutive primes infinitely often.

---

## Hypothesis 3: Exact Comparison Between Survivor Density and Inclusion-Exclusion Truncations

**Conjecture.** For any admissible k-tuple H and bound B, the exact survivor density equals the full inclusion-exclusion sum, and the Bonferroni truncations provide rigorous alternating bounds:

$$\sum_{S \subseteq \text{Primes}_{\leq B},\ |S| \leq 2m} (-1)^{|S|} \frac{|\bigcap_{p \in S} F_p|}{M} \leq \frac{|\text{Survivors}|}{M} \leq \sum_{S \subseteq \text{Primes}_{\leq B},\ |S| \leq 2m+1} (-1)^{|S|} \frac{|\bigcap_{p \in S} F_p|}{M}$$

where F_p is the set of residues forbidden by prime p and M = primorial(B).

**Test.** For H = {0, 2, 6} and B = 11, compute all Bonferroni truncation levels (there are only π(11) = 5 primes, so 32 subsets) and verify the alternating bounds hold with equality at the final level. Formalize the identity for the full inclusion-exclusion case (all subsets).

**Infrastructure needed.** A formal Bonferroni inequality over finite sets with the independence structure provided by CRT. This connects to `Finset.sum_indicator_subset` and Möbius inversion infrastructure in Mathlib.

**Impact if true.** This would formalize the exact relationship between the sieve of Eratosthenes (inclusion-exclusion), the Selberg sieve (optimized quadratic forms), and the CRT product formula (exact count). It is the missing link between elementary and analytic sieve theory.

---

## Hypothesis 4: Formal Selberg Sieve Quadratic Forms in Finite Dimension

**Conjecture.** The Selberg sieve upper bound in finite dimension can be expressed as a positive-definite quadratic form optimization. Specifically, for a finite set of primes P and admissible tuple H of size k, there exists a positive-definite matrix Q of size |P| × |P| such that the Selberg sieve upper bound for prime k-tuples up to N equals

$$\frac{N}{\mathbf{1}^T Q^{-1} \mathbf{1}} + O(N^{1/2+\epsilon})$$

and the optimal Selberg weights are λ_d = (Q^{-1} · 1)_d / (1^T Q^{-1} 1).

**Test.** For H = {0, 2} and P = {2, 3, 5, 7, 11}, construct Q explicitly as the matrix Q_{d,e} = ∑_{[d,e]|n ≤ N} 1 (where [d,e] is the lcm), verify it is positive definite, compute the Selberg bound, and compare with the exact prime pair count up to N = 10⁶.

**Infrastructure needed.** Formalization of the Selberg sieve requires:
- Positive-definite matrices over ℝ (available in Mathlib)
- Möbius function and multiplicative function infrastructure
- The Selberg symmetry condition λ_d = λ_d' when d, d' have the same prime factors
- Connection between the quadratic form minimum and the CRT survivor count

**Impact if true.** This would be the first formal connection between the finite combinatorial infrastructure (admissibility, CRT survivors) and the analytic sieve machinery. It would open the door to formalizing Zhang's theorem on bounded gaps.

---

## Hypothesis 5: Entropy-Optimal Admissible Tuples Minimize the Singular Series

**Conjecture.** Among all admissible k-tuples of a given diameter D, the tuple minimizing the "local obstruction entropy"

$$E(H) = -\sum_{p \leq k} \frac{\nu_p(H)}{p} \log \frac{\nu_p(H)}{p}$$

also minimizes the singular series constant 𝔖(H). In other words, the most "uniformly spread" tuples in residue-class space are the ones with the smallest Hardy–Littlewood constant.

**Test.** For k = 5 and D ≤ 20, enumerate all admissible 5-tuples, compute both E(H) and 𝔖(H, B=100), and test whether the Spearman rank correlation between E and 𝔖 is negative. A single tuple pair where the entropy ordering disagrees with the singular series ordering would refute the conjecture.

**Infrastructure needed.** Formalized real-valued entropy function over finite distributions, singular series partial products (already computable), and a comparison theorem relating the two. The entropy function requires `Real.log` and `Finset.sum` over prime residue distributions.

**Impact if true.** This would provide a computationally cheap proxy for the singular series (which requires computing many local factors). Tuple optimization for prime gap searches could use entropy minimization instead of full singular series computation, dramatically speeding up the search for optimal tuples in large databases.


            ### Mathematical Framing
            # Future Directions: Falsifiable Hypotheses for Formal Prime Gap Infrastructure

## Hypothesis 1: Multiplicativity of Survivor Counts for Arbitrary Squarefree Moduli

**Conjecture.** For any admissible tuple H and any squarefree integer M = p₁ · p₂ · … · pₙ (distinct primes), the number of survivor residues modulo M factors as a product of local survivor counts:

$$|\{a \in [0, M) : \forall h \in H,\ \gcd(a + h, M) = 1\}| = \prod_{i=1}^{n} (p_i - \nu_{p_i}(H))$$

where ν_p(H) = |H mod p|.

**Test.** Formalize the theorem `card_survivors_mul_of_coprime` asserting that for coprime moduli m, n, the survivor count modulo m·n equals the product of survivor counts modulo m and n. Then specialize to primorials. A computational sweep over all squarefree moduli up to 10⁵ with tuples of size ≤ 10 confirms or refutes the formula.

**Infrastructure needed.** A formal CRT bijection theorem at the level of finite sets (not just existence), proving that the map ℤ/mnℤ → ℤ/mℤ × ℤ/nℤ restricts to a bijection on survivor sets. This requires `ZMod.chineseRemainder` from Mathlib composed with set-level bijection lemmas.

**Impact if true.** This would complete the combinatorial foundation of sieve theory: the exact survivor count is a multiplicative function of the modulus, yielding a formal Euler product for the sieve density. It would also give the first machine-verified derivation of the Hardy–Littlewood singular series.

---

## Hypothesis 2: Tight Diameter Bounds for Optimal Admissible k-Tuples

**Conjecture.** For every k ≥ 2, the minimal diameter D(k) of an admissible k-tuple satisfies

$$D(k) \leq k \cdot (\ln k + \ln \ln k + 6)$$

This is sharper than the Hensley–Richards bound D(k) ~ k log k and matches computational data for k ≤ 342.

**Test.** Implement a certified exhaustive search for D(k) up to k = 20, verify the bound computationally for k ≤ 1000 using greedy algorithms, and formalize the inequality D(k) < k · (ln k + ln ln k + 6) for all k ≤ N where N is the search frontier. Any counterexample immediately refutes the conjecture.

**Infrastructure needed.** A formalized greedy admissible tuple construction algorithm with a verified upper bound on its output diameter. This requires decidable admissibility (already achieved) plus an inductive bound on the next admissible offset.

**Impact if true.** This would give the tightest known formal upper bound on prime gap sizes achievable by the Maynard–Tao method. Combined with the threshold existence theorem, it would yield an explicit computable function k ↦ D(k) bounding the gap between consecutive primes infinitely often.

---

## Hypothesis 3: Exact Comparison Between Survivor Density and Inclusion-Exclusion Truncations

**Conjecture.** For any admissible k-tuple H and bound B, the exact survivor density equals the full inclusion-exclusion sum, and the Bonferroni truncations provide rigorous alternating bounds:

$$\sum_{S \subseteq \text{Primes}_{\leq B},\ |S| \leq 2m} (-1)^{|S|} \frac{|\bigcap_{p \in S} F_p|}{M} \leq \frac{|\text{Survivors}|}{M} \leq \sum_{S \subseteq \text{Primes}_{\leq B},\ |S| \leq 2m+1} (-1)^{|S|} \frac{|\bigcap_{p \in S} F_p|}{M}$$

where F_p is the set of residues forbidden by prime p and M = primorial(B).

**Test.** For H = {0, 2, 6} and B = 11, compute all Bonferroni truncation levels (there are only π(11) = 5 primes, so 32 subsets) and verify the alternating bounds hold with equality at the final level. Formalize the identity for the full inclusion-exclusion case (all subsets).

**Infrastructure needed.** A formal Bonferroni inequality over finite sets with the independence structure provided by CRT. This connects to `Finset.sum_indicator_subset` and Möbius inversion infrastructure in Mathlib.

**Impact if true.** This would formalize the exact relationship between the sieve of Eratosthenes (inclusion-exclusion), the Selberg sieve (optimized quadratic forms), and the CRT product formula (exact count). It is the missing link between elementary and analytic sieve theory.

---

## Hypothesis 4: Formal Selberg Sieve Quadratic Forms in Finite Dimension

**Conjecture.** The Selberg sieve upper bound in finite dimension can be expressed as a positive-definite quadratic form optimization. Specifically, for a finite set of primes P and admissible tuple H of size k, there exists a positive-definite matrix Q of size |P| × |P| such that the Selberg sieve upper bound for prime k-tuples up to N equals

$$\frac{N}{\mathbf{1}^T Q^{-1} \mathbf{1}} + O(N^{1/2+\epsilon})$$

and the optimal Selberg weights are λ_d = (Q^{-1} · 1)_d / (1^T Q^{-1} 1).

**Test.** For H = {0, 2} and P = {2, 3, 5, 7, 11}, construct Q explicitly as the matrix Q_{d,e} = ∑_{[d,e]|n ≤ N} 1 (where [d,e] is the lcm), verify it is positive definite, compute the Selberg bound, and compare with the exact prime pair count up to N = 10⁶.

**Infrastructure needed.** Formalization of the Selberg sieve requires:
- Positive-definite matrices over ℝ (available in Mathlib)
- Möbius function and multiplicative function infrastructure
- The Selberg symmetry condition λ_d = λ_d' when d, d' have the same prime factors
- Connection between the quadratic form minimum and the CRT survivor count

**Impact if true.** This would be the first formal connection between the finite combinatorial infrastructure (admissibility, CRT survivors) and the analytic sieve machinery. It would open the door to formalizing Zhang's theorem on bounded gaps.

---

## Hypothesis 5: Entropy-Optimal Admissible Tuples Minimize the Singular Series

**Conjecture.** Among all admissible k-tuples of a given diameter D, the tuple minimizing the "local obstruction entropy"

$$E(H) = -\sum_{p \leq k} \frac{\nu_p(H)}{p} \log \frac{\nu_p(H)}{p}$$

also minimizes the singular series constant 𝔖(H). In other words, the most "uniformly spread" tuples in residue-class space are the ones with the smallest Hardy–Littlewood constant.

**Test.** For k = 5 and D ≤ 20, enumerate all admissible 5-tuples, compute both E(H) and 𝔖(H, B=100), and test whether the Spearman rank correlation between E and 𝔖 is negative. A single tuple pair where the entropy ordering disagrees with the singular series ordering would refute the conjecture.

**Infrastructure needed.** Formalized real-valued entropy function over finite distributions, singular series partial products (already computable), and a comparison theorem relating the two. The entropy function requires `Real.log` and `Finset.sum` over prime residue distributions.

**Impact if true.** This would provide a computationally cheap proxy for the singular series (which requires computing many local factors). Tuple optimization for prime gap searches could use entropy minimization instead of full singular series computation, dramatically speeding up the search for optimal tuples in large databases.



            ### Existing Verified Theorems
            Existing theorems you can build on:
  1. `exists_minimal_graph_from_rank_data` : theorem exists_minimal_graph_from_rank_data (R : TropRankData)
     (file: Bridges/AlgebraTropicalGeometry/TropicalPersistenceRealizationDuality.lean)
  2. `exists_modulus_injective_on_finite_int_matrix_set` : theorem exists_modulus_injective_on_finite_int_matrix_set
     (file: Cryptography/BerggrenBallRigidity.lean)
  3. `exists_minimal_graph_from_rank_data` : theorem exists_minimal_graph_from_rank_data (R : TropRankData)
     (file: FINAL/Bridges/TropicalPersistenceRealizationDuality.lean)
  4. `exists_modulus_injective_on_finite_int_matrix_set` : theorem exists_modulus_injective_on_finite_int_matrix_set
     (file: FINAL/Cryptography/BerggrenBallRigidity.lean)
  5. `sum_two_sq_primes_mod4_count` : theorem sum_two_sq_primes_mod4_count :
     (file: FINAL/Geometry/InverseStereoResearch.lean)

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
