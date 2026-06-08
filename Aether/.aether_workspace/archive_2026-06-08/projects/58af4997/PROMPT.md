            ## Assignment: **Conjecture:** For all $n \geq 6$,

            Prove new, non-trivial theorems. Build on catalog theorems. Minimize sorry.

            ### Research Direction
            # Future Directions: Certified Generation Probability and Dixon's Theorem

## Hypothesis A: Tight Intransitive Obstruction Bound

**Conjecture:** For all $n \geq 6$,
$$\sum_{k=1}^{\lfloor n/2 \rfloor} \frac{1}{\binom{n}{k}} \leq \frac{1}{n} + \frac{3}{n^2}.$$

**Test:** Verify numerically for $6 \leq n \leq 200$ using exact rational arithmetic. Then formalize the analytic proof by bounding $\sum_{k=2}^{\lfloor n/2\rfloor} 1/\binom{n}{k}$ using the geometric-series domination of binomial coefficients: for $2 \leq k \leq n/2$, successive ratios satisfy $\binom{n}{k+1}/\binom{n}{k} = (n-k)/(k+1) \geq 2$ when $k \leq (n-1)/3$, giving exponential decay.

**Impact:** This would provide the tightest elementary upper bound on the intransitive obstruction and immediately imply that the failure probability for $S_n$-generation is $1/n + O(1/n^2)$, making the Dixon bound explicit with concrete constants. The proof infrastructure would also cover $A_n$ after a parity adjustment.

**Refutation criterion:** Find $n \geq 6$ where the sum exceeds $1/n + 3/n^2$, or prove a lower bound showing the constant 3 is insufficient.

---

## Hypothesis B: Transitive Non-Alternating Obstruction is $O(1/n^2)$

**Conjecture:** The probability that two random permutations in $S_n$ generate a transitive subgroup that is neither $A_n$ nor $S_n$ is $O(1/n^2)$ for $n \geq 5$.

More precisely, the non-generation probability decomposes as:
$$P(\text{fail}) = P(\text{intransitive}) + P(\text{transitive, imprimitive}) + P(\text{primitive, not } A_n \text{ or } S_n).$$

The transitive contributions should be:
- Imprimitive: $O(1/n^2)$ from wreath product subgroups
- Primitive, not $A_n/S_n$: exponentially small by the O'Nan-Scott theorem

**Test:** For $n = 5, 6, 7$ (where exhaustive computation is feasible), compute the exact contribution of each obstruction class. Verify that the transitive-but-not-$A_n/S_n$ contribution is at most $C/n^2$ for some explicit constant $C$.

**Impact:** This would isolate the three structural sources of non-generation and show that only point stabilizers and the alternating group matter asymptotically. Combined with Hypothesis A, it would yield a complete formal Dixon-style bound.

**Refutation criterion:** Find a family of transitive maximal subgroups contributing $\Omega(1/n)$ to the failure probability.

---

## Hypothesis C: Multi-Generator Point-Stabilizer Formula

**Conjecture:** For fixed $r \geq 2$, the probability that $r$ random permutations in $S_n$ all fix a common point is exactly
$$\frac{1}{n} \cdot \left(\frac{(n-1)!}{n!}\right)^{r-1} \cdot (\text{inclusion-exclusion correction}) = \sum_{j=1}^{n} (-1)^{j+1} \binom{n}{j} \left(\frac{(n-j)!}{n!}\right)^r.$$

For $r = 2$: this equals $\frac{1}{n} \cdot \left(1 - \frac{1}{(n-1)^2} + \cdots\right) \approx \frac{1}{n}$.

For $r = 3$: the failure probability from point stabilizers drops to $O(1/n^2)$.

**Test:** Formalize the exact inclusion-exclusion formula for $r$-tuples sharing a fixed point. Verify computationally for $n \leq 10$ and $r = 2, 3, 4$. Then prove the asymptotic $1/n^{r-1}$ scaling.

**Impact:** Establishes the multi-generator generalization of Dixon's theorem: $r$ random permutations generate $S_n$ with probability $1 - O(1/n^{r-1})$. For $r = 3$, this gives probability $\geq 1 - O(1/n^2)$, which is much stronger than the 2-generator case.

**Refutation criterion:** Find that the inclusion-exclusion does not simplify to $O(1/n^{r-1})$, or that imprimitive obstructions dominate for some $r$.

---

## Hypothesis D: Computational Reach to $S_7$

**Conjecture:** Exact generation probabilities for $S_n$ with $n \leq 7$ can be certified using optimized finite computation inside a proof assistant, using the `native_decide` approach demonstrated for $S_4$ and $S_5$.

Known values:
| $n$ | $\|S_n\|$ | $\|S_n \times S_n\|$ | Generating pairs | Probability |
|-----|-----------|---------------------|------------------|-------------|
| 2   | 2         | 4                   | 3                | 3/4         |
| 3   | 6         | 36                  | 18               | 1/2         |
| 4   | 24        | 576                 | 216              | 3/8         |
| 5   | 120       | 14,400              | 6,840            | 19/40       |
| 6   | 720       | 518,400             | ?                | ?           |
| 7   | 5,040     | 25,401,600          | ?                | ?           |

**Test:** Benchmark the current BFS-based `genFullBool` approach for $n = 6$ (518,400 pairs). If too slow, implement:
1. Orbit-based early rejection (if $\langle \sigma, \tau \rangle$ acts intransitively, reject immediately)
2. Schreier-Sims based subgroup order computation
3. Conjugacy-class pruning (count per conjugacy class pair, multiply by class sizes)

**Impact:** Extending the computational frontier validates the obstruction theory numerically and provides regression tests for abstract bounds. The $n = 6$ case involves the exceptional transitive subgroup $\text{PGL}(2,5) \cong S_5$ acting on cosets, making it a test of whether "exceptional" obstructions matter.

**Refutation criterion:** If $n = 6$ requires more than 1 hour of `native_decide` computation, the approach needs algorithmic improvement rather than raw computation.

---

## Hypothesis E: Alternating Group Generation with Parity Correction

**Conjecture:** The subgroup-obstruction formalism extends to $A_n$ with the following modification: for two random *even* permutations, the probability of generating $A_n$ satisfies
$$P(\langle \sigma, \tau \rangle = A_n) = 1 - \frac{1}{n} - O(1/n^2) \quad \text{as } n \to \infty.$$

The leading obstruction is again point stabilizers: the stabilizer of a point in $A_n$ is $A_{n-1}$, contributing $n \cdot ((n-1)!/2)/(n!/2))^2 = 1/n$ to the failure probability.

**Test:**
1. Define `countGenPairs_Alt n` analogous to our symmetric group version, counting pairs of even permutations generating $A_n$.
2. Compute for $n = 4, 5$ and verify:
   - $A_4$: $|A_4| = 12$, $|A_4 \times A_4| = 144$
   - $A_5$: $|A_5| = 60$, $|A_5 \times A_5| = 3600$
3. Prove the point-stabilizer contribution formula for $A_n$.

**Impact:** Extends the entire framework to alternating groups, which are the other main family in the classification of finite simple groups. Since every finite simple group is generated by 2 elements (by Steinberg's theorem), the generation probability question is universal for simple groups.

**Refutation criterion:** If the $O(1/n^2)$ error term is actually $O(1/n)$ due to additional obstructions specific to $A_n$ (e.g., from imprimitive subgroups of $A_n$ that are not restrictions of imprimitive subgroups of $S_n$).


            ### Mathematical Framing
            # Future Directions: Certified Generation Probability and Dixon's Theorem

## Hypothesis A: Tight Intransitive Obstruction Bound

**Conjecture:** For all $n \geq 6$,
$$\sum_{k=1}^{\lfloor n/2 \rfloor} \frac{1}{\binom{n}{k}} \leq \frac{1}{n} + \frac{3}{n^2}.$$

**Test:** Verify numerically for $6 \leq n \leq 200$ using exact rational arithmetic. Then formalize the analytic proof by bounding $\sum_{k=2}^{\lfloor n/2\rfloor} 1/\binom{n}{k}$ using the geometric-series domination of binomial coefficients: for $2 \leq k \leq n/2$, successive ratios satisfy $\binom{n}{k+1}/\binom{n}{k} = (n-k)/(k+1) \geq 2$ when $k \leq (n-1)/3$, giving exponential decay.

**Impact:** This would provide the tightest elementary upper bound on the intransitive obstruction and immediately imply that the failure probability for $S_n$-generation is $1/n + O(1/n^2)$, making the Dixon bound explicit with concrete constants. The proof infrastructure would also cover $A_n$ after a parity adjustment.

**Refutation criterion:** Find $n \geq 6$ where the sum exceeds $1/n + 3/n^2$, or prove a lower bound showing the constant 3 is insufficient.

---

## Hypothesis B: Transitive Non-Alternating Obstruction is $O(1/n^2)$

**Conjecture:** The probability that two random permutations in $S_n$ generate a transitive subgroup that is neither $A_n$ nor $S_n$ is $O(1/n^2)$ for $n \geq 5$.

More precisely, the non-generation probability decomposes as:
$$P(\text{fail}) = P(\text{intransitive}) + P(\text{transitive, imprimitive}) + P(\text{primitive, not } A_n \text{ or } S_n).$$

The transitive contributions should be:
- Imprimitive: $O(1/n^2)$ from wreath product subgroups
- Primitive, not $A_n/S_n$: exponentially small by the O'Nan-Scott theorem

**Test:** For $n = 5, 6, 7$ (where exhaustive computation is feasible), compute the exact contribution of each obstruction class. Verify that the transitive-but-not-$A_n/S_n$ contribution is at most $C/n^2$ for some explicit constant $C$.

**Impact:** This would isolate the three structural sources of non-generation and show that only point stabilizers and the alternating group matter asymptotically. Combined with Hypothesis A, it would yield a complete formal Dixon-style bound.

**Refutation criterion:** Find a family of transitive maximal subgroups contributing $\Omega(1/n)$ to the failure probability.

---

## Hypothesis C: Multi-Generator Point-Stabilizer Formula

**Conjecture:** For fixed $r \geq 2$, the probability that $r$ random permutations in $S_n$ all fix a common point is exactly
$$\frac{1}{n} \cdot \left(\frac{(n-1)!}{n!}\right)^{r-1} \cdot (\text{inclusion-exclusion correction}) = \sum_{j=1}^{n} (-1)^{j+1} \binom{n}{j} \left(\frac{(n-j)!}{n!}\right)^r.$$

For $r = 2$: this equals $\frac{1}{n} \cdot \left(1 - \frac{1}{(n-1)^2} + \cdots\right) \approx \frac{1}{n}$.

For $r = 3$: the failure probability from point stabilizers drops to $O(1/n^2)$.

**Test:** Formalize the exact inclusion-exclusion formula for $r$-tuples sharing a fixed point. Verify computationally for $n \leq 10$ and $r = 2, 3, 4$. Then prove the asymptotic $1/n^{r-1}$ scaling.

**Impact:** Establishes the multi-generator generalization of Dixon's theorem: $r$ random permutations generate $S_n$ with probability $1 - O(1/n^{r-1})$. For $r = 3$, this gives probability $\geq 1 - O(1/n^2)$, which is much stronger than the 2-generator case.

**Refutation criterion:** Find that the inclusion-exclusion does not simplify to $O(1/n^{r-1})$, or that imprimitive obstructions dominate for some $r$.

---

## Hypothesis D: Computational Reach to $S_7$

**Conjecture:** Exact generation probabilities for $S_n$ with $n \leq 7$ can be certified using optimized finite computation inside a proof assistant, using the `native_decide` approach demonstrated for $S_4$ and $S_5$.

Known values:
| $n$ | $\|S_n\|$ | $\|S_n \times S_n\|$ | Generating pairs | Probability |
|-----|-----------|---------------------|------------------|-------------|
| 2   | 2         | 4                   | 3                | 3/4         |
| 3   | 6         | 36                  | 18               | 1/2         |
| 4   | 24        | 576                 | 216              | 3/8         |
| 5   | 120       | 14,400              | 6,840            | 19/40       |
| 6   | 720       | 518,400             | ?                | ?           |
| 7   | 5,040     | 25,401,600          | ?                | ?           |

**Test:** Benchmark the current BFS-based `genFullBool` approach for $n = 6$ (518,400 pairs). If too slow, implement:
1. Orbit-based early rejection (if $\langle \sigma, \tau \rangle$ acts intransitively, reject immediately)
2. Schreier-Sims based subgroup order computation
3. Conjugacy-class pruning (count per conjugacy class pair, multiply by class sizes)

**Impact:** Extending the computational frontier validates the obstruction theory numerically and provides regression tests for abstract bounds. The $n = 6$ case involves the exceptional transitive subgroup $\text{PGL}(2,5) \cong S_5$ acting on cosets, making it a test of whether "exceptional" obstructions matter.

**Refutation criterion:** If $n = 6$ requires more than 1 hour of `native_decide` computation, the approach needs algorithmic improvement rather than raw computation.

---

## Hypothesis E: Alternating Group Generation with Parity Correction

**Conjecture:** The subgroup-obstruction formalism extends to $A_n$ with the following modification: for two random *even* permutations, the probability of generating $A_n$ satisfies
$$P(\langle \sigma, \tau \rangle = A_n) = 1 - \frac{1}{n} - O(1/n^2) \quad \text{as } n \to \infty.$$

The leading obstruction is again point stabilizers: the stabilizer of a point in $A_n$ is $A_{n-1}$, contributing $n \cdot ((n-1)!/2)/(n!/2))^2 = 1/n$ to the failure probability.

**Test:**
1. Define `countGenPairs_Alt n` analogous to our symmetric group version, counting pairs of even permutations generating $A_n$.
2. Compute for $n = 4, 5$ and verify:
   - $A_4$: $|A_4| = 12$, $|A_4 \times A_4| = 144$
   - $A_5$: $|A_5| = 60$, $|A_5 \times A_5| = 3600$
3. Prove the point-stabilizer contribution formula for $A_n$.

**Impact:** Extends the entire framework to alternating groups, which are the other main family in the classification of finite simple groups. Since every finite simple group is generated by 2 elements (by Steinberg's theorem), the generation probability question is universal for simple groups.

**Refutation criterion:** If the $O(1/n^2)$ error term is actually $O(1/n)$ due to additional obstructions specific to $A_n$ (e.g., from imprimitive subgroups of $A_n$ that are not restrictions of imprimitive subgroups of $S_n$).



            ### Existing Verified Theorems
            Existing theorems you can build on:
  1. `fixed_point_entropy_upper_bound` : theorem fixed_point_entropy_upper_bound
     (file: Speculative/AutoResearch/ThermodynamicClosureCore.lean)
  2. `exists_fixed_point_on_orbit_with_bound` : theorem exists_fixed_point_on_orbit_with_bound
     (file: Bridges/HolographicProofRenormalization.lean)
  3. `exists_fixed_point_on_orbit_with_bound` : theorem exists_fixed_point_on_orbit_with_bound
     (file: FINAL/Bridges/HolographicProofRenormalization.lean)
  4. `finite_generation_bound` : theorem finite_generation_bound
     (file: Speculative/AutoResearch/AlgebraicInvariantCryptography.lean)
  5. `valuation_pruning_error_bound` : theorem valuation_pruning_error_bound (w : ℚ_[p]) :
     (file: Speculative/AutoResearch/Bridges/UltrametricDeepLearning.lean)

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
