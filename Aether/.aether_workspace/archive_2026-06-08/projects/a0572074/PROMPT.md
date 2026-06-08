            ## Assignment: **Conjecture.** There exists a finite set of at most 20 explicit parametric iden

            Prove new, non-trivial theorems. Build on catalog theorems. Minimize sorry.

            ### Research Direction
            # Future Directions: Erdős–Straus Conjecture

## 1. Residue Covering Completeness via Modulus 840

**Conjecture.** There exists a finite set of at most 20 explicit parametric identities for 4/n = 1/x + 1/y + 1/z whose associated congruence classes form a complete covering system modulo 840 — that is, every residue class mod 840 is covered by at least one parametric family.

**Test.** For each residue r mod 840 with r ≡ 1 (mod 12) (the only residue class our current four families miss), search for an identity of the form x = ⌈αn⌉ for various rational α, derive closed-form (y,z) via the algebraic equation z = nxy/(4xy − n(x+y)), and check whether the resulting formula yields integer solutions for all n ≡ r (mod 840). Verify computationally for all r ∈ {1, 13, 25, 37, 49, 61, ...} mod 840 and check coverage.

**Impact.** A complete covering mod 840 would reduce the conjecture to finitely many prime residue classes, each requiring only bounded computational verification. Combined with the prime reduction theorem, this would essentially reduce the conjecture to a finite computation plus a density argument.

---

## 2. Quadratic Witness Bound for Exceptional Primes

**Conjecture.** For every prime p ≡ 1 (mod 12), there exists an Erdős–Straus decomposition 4/p = 1/x + 1/y + 1/z with x ≤ p, y ≤ p², z ≤ p². Moreover, one can always choose x = ⌈p/4⌉ or x = ⌈p/4⌉ + 1.

**Test.** For all primes p ≡ 1 (mod 12) up to 10⁶, compute the minimal ordered solution (x ≤ y ≤ z) and record max(z)/p². If the ratio stays bounded, the conjecture is supported. If x = ⌈p/4⌉ works for density > 99% of such primes, this would yield a near-proof strategy: prove x = ⌈p/4⌉ works generically, then handle exceptions by a secondary family.

**Impact.** An explicit polynomial bound on witness size would transform the search problem from unbounded to polynomial-time certifiable, connecting the conjecture to computational complexity theory and making large-scale formal verification feasible.

---

## 3. Two-Parameter Surface Parametrization for n ≡ 1 (mod 12)

**Conjecture.** For primes p ≡ 1 (mod 12), the affine surface S_p: 4xyz = p(xy + xz + yz) admits a two-parameter rational parametrization (a,b) ↦ (x(a,b), y(a,b), z(a,b)) with x,y,z polynomial in a,b of degree ≤ 3, such that for each p the parametrization covers all solutions with x ≤ p.

**Test.** Fix several primes p ≡ 1 (mod 12) (e.g., 13, 37, 61, 73, 97). Enumerate all solutions on S_p with coordinates ≤ 10⁴. Attempt to fit a rational parametrization using interpolation over the solution set. Verify the parametrization yields integer points for a random sample of (a,b) values.

**Impact.** Such a parametrization would provide a geometric proof of the conjecture for this residue class, connecting the number-theoretic problem to the algebraic geometry of rational surfaces. It would also yield an O(1) algorithm for finding decompositions.

---

## 4. Modular Arithmetic Obstruction Classification

**Conjecture.** The equation 4xyz ≡ 0 (mod p) with xy + xz + yz ≡ 0 (mod p) has solutions modulo every prime p. More precisely, for each prime p, the number of solutions (x,y,z) mod p to 4xyz ≡ p·(xy + xz + yz) (mod p²) is at least p² − 2p.

**Test.** For each prime p up to 1000, count solutions mod p² by exhaustive enumeration. If the count is always ≥ p² − 2p, this rules out local obstructions and suggests the Hasse principle applies to the Erdős–Straus surface. Formalize the mod-p solution count as a theorem.

**Impact.** Proving absence of local obstructions would be a major structural result. Combined with a suitable form of the circle method or sieve, it could potentially lead to an unconditional proof of the conjecture for all sufficiently large n.

---

## 5. Certified Verification to 10^14 via Parallel Search

**Conjecture.** The Erdős–Straus conjecture holds for all n ≤ 10^14, verifiable by a combination of: (a) the four algebraic families covering 11/12 of integers, (b) extended parametric families covering additional residue classes mod 840, and (c) a parallel smart search for the remaining ~0.5% of integers requiring computational verification.

**Test.** Implement the smart search algorithm in a compiled language (Rust/C++), parallelized across residue classes. For each exceptional n ≡ 1 (mod 12) up to 10^14, run the O(n) smart search (x ranges over [⌈n/4⌉, n], z is computed). Generate certified witnesses and verify them against the Diophantine equation. Import the witness certificates into the formal verification framework.

**Impact.** This would extend the verified bound by several orders of magnitude beyond current published results. The certified witness format would allow the formal proof system to verify each decomposition in O(1) time, creating a scalable bridge between computational number theory and formal mathematics.


            ### Mathematical Framing
            # Future Directions: Erdős–Straus Conjecture

## 1. Residue Covering Completeness via Modulus 840

**Conjecture.** There exists a finite set of at most 20 explicit parametric identities for 4/n = 1/x + 1/y + 1/z whose associated congruence classes form a complete covering system modulo 840 — that is, every residue class mod 840 is covered by at least one parametric family.

**Test.** For each residue r mod 840 with r ≡ 1 (mod 12) (the only residue class our current four families miss), search for an identity of the form x = ⌈αn⌉ for various rational α, derive closed-form (y,z) via the algebraic equation z = nxy/(4xy − n(x+y)), and check whether the resulting formula yields integer solutions for all n ≡ r (mod 840). Verify computationally for all r ∈ {1, 13, 25, 37, 49, 61, ...} mod 840 and check coverage.

**Impact.** A complete covering mod 840 would reduce the conjecture to finitely many prime residue classes, each requiring only bounded computational verification. Combined with the prime reduction theorem, this would essentially reduce the conjecture to a finite computation plus a density argument.

---

## 2. Quadratic Witness Bound for Exceptional Primes

**Conjecture.** For every prime p ≡ 1 (mod 12), there exists an Erdős–Straus decomposition 4/p = 1/x + 1/y + 1/z with x ≤ p, y ≤ p², z ≤ p². Moreover, one can always choose x = ⌈p/4⌉ or x = ⌈p/4⌉ + 1.

**Test.** For all primes p ≡ 1 (mod 12) up to 10⁶, compute the minimal ordered solution (x ≤ y ≤ z) and record max(z)/p². If the ratio stays bounded, the conjecture is supported. If x = ⌈p/4⌉ works for density > 99% of such primes, this would yield a near-proof strategy: prove x = ⌈p/4⌉ works generically, then handle exceptions by a secondary family.

**Impact.** An explicit polynomial bound on witness size would transform the search problem from unbounded to polynomial-time certifiable, connecting the conjecture to computational complexity theory and making large-scale formal verification feasible.

---

## 3. Two-Parameter Surface Parametrization for n ≡ 1 (mod 12)

**Conjecture.** For primes p ≡ 1 (mod 12), the affine surface S_p: 4xyz = p(xy + xz + yz) admits a two-parameter rational parametrization (a,b) ↦ (x(a,b), y(a,b), z(a,b)) with x,y,z polynomial in a,b of degree ≤ 3, such that for each p the parametrization covers all solutions with x ≤ p.

**Test.** Fix several primes p ≡ 1 (mod 12) (e.g., 13, 37, 61, 73, 97). Enumerate all solutions on S_p with coordinates ≤ 10⁴. Attempt to fit a rational parametrization using interpolation over the solution set. Verify the parametrization yields integer points for a random sample of (a,b) values.

**Impact.** Such a parametrization would provide a geometric proof of the conjecture for this residue class, connecting the number-theoretic problem to the algebraic geometry of rational surfaces. It would also yield an O(1) algorithm for finding decompositions.

---

## 4. Modular Arithmetic Obstruction Classification

**Conjecture.** The equation 4xyz ≡ 0 (mod p) with xy + xz + yz ≡ 0 (mod p) has solutions modulo every prime p. More precisely, for each prime p, the number of solutions (x,y,z) mod p to 4xyz ≡ p·(xy + xz + yz) (mod p²) is at least p² − 2p.

**Test.** For each prime p up to 1000, count solutions mod p² by exhaustive enumeration. If the count is always ≥ p² − 2p, this rules out local obstructions and suggests the Hasse principle applies to the Erdős–Straus surface. Formalize the mod-p solution count as a theorem.

**Impact.** Proving absence of local obstructions would be a major structural result. Combined with a suitable form of the circle method or sieve, it could potentially lead to an unconditional proof of the conjecture for all sufficiently large n.

---

## 5. Certified Verification to 10^14 via Parallel Search

**Conjecture.** The Erdős–Straus conjecture holds for all n ≤ 10^14, verifiable by a combination of: (a) the four algebraic families covering 11/12 of integers, (b) extended parametric families covering additional residue classes mod 840, and (c) a parallel smart search for the remaining ~0.5% of integers requiring computational verification.

**Test.** Implement the smart search algorithm in a compiled language (Rust/C++), parallelized across residue classes. For each exceptional n ≡ 1 (mod 12) up to 10^14, run the O(n) smart search (x ranges over [⌈n/4⌉, n], z is computed). Generate certified witnesses and verify them against the Diophantine equation. Import the witness certificates into the formal verification framework.

**Impact.** This would extend the verified bound by several orders of magnitude beyond current published results. The certified witness format would allow the formal proof system to verify each decomposition in O(1) time, creating a scalable bridge between computational number theory and formal mathematics.



            ### Existing Verified Theorems
            Existing theorems you can build on:
  1. `prime_one_mod_four_has_sum_two_squares` : theorem prime_one_mod_four_has_sum_two_squares
     (file: FINAL/Pythagorean/TropicalBerggrenZeta.lean)
  2. `prime_one_mod_four_has_sum_two_squares` : theorem prime_one_mod_four_has_sum_two_squares
     (file: Pythagorean/TropicalBerggrenZeta.lean)
  3. `aks_congruence_holds_for_prime` : theorem aks_congruence_holds_for_prime
     (file: Speculative/PrimalityTesting/AKS.lean)
  4. `exists_prime_between_sq_and_two_mul_sq` : theorem exists_prime_between_sq_and_two_mul_sq
     (file: FINAL/MachineLearning/LegendreGapReduction.lean)
  5. `exists_prime_between_sq_and_two_mul_sq` : theorem exists_prime_between_sq_and_two_mul_sq
     (file: MachineLearning/LegendreGapReduction.lean)

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
