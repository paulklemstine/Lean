            ## Assignment: This document identifies five falsifiable scientific hypotheses extending the fo

            Prove new, non-trivial theorems. Build on catalog theorems. Minimize sorry.

            ### Research Direction
            # Future Directions in Formal Meta-Complexity

## Summary

This document identifies five falsifiable scientific hypotheses extending the formal meta-complexity framework established in this cycle. Each hypothesis is concrete enough to be tested computationally and proved or disproved in a formal proof assistant.

---

## Hypothesis 1: Exact Symmetric Witness Formula

**Conjecture:** For any symmetric Boolean function `f : (Fin n → Bool) → Bool` with profile `p : Fin (n+1) → Bool`, the KW witness cardinality is exactly:

```
|KWWitness(f)| = Σ_{k=0}^{n} Σ_{l=0}^{n} [p(k)=true ∧ p(l)=false] · C(n,k) · C(n,l) · |k-l|
```

**Lean objects involved:** `MetaComplexity.KWWitness`, `MetaComplexity.hammingWeight`, `MetaComplexity.IsSymmetric`, `Nat.choose`, `Nat.dist`.

**Test:** Compute both sides for all symmetric functions on n ≤ 8 variables. The formula should match the brute-force count in every case. A formal proof would proceed by partitioning `KWWitness(f)` by Hamming weight pairs (k,l) and showing each pair (x,y) of weights (k,l) contributes exactly |k-l| witnesses.

**Refutation criterion:** A single symmetric function where the formula gives a different value from the brute-force count would refute this. Computational evidence (verified for n ≤ 8 in this cycle's Python demos) strongly supports the conjecture.

**Impact:** Would convert the qualitative lower bound `C(n,t)·C(n,t-1) ≤ |KWWitness|` into an exact enumerative invariant. All lower bounds for symmetric functions would become bookkeeping.

---

## Hypothesis 2: Entropy Gap is O(log n) for Monotone Functions

**Conjecture:** For every monotone Boolean function `f : (Fin n → Bool) → Bool`,

```
log₂ |KWWitness(f)| - KWComplexityExact(f) ≤ C · log₂(n+1)
```

for a universal constant `C` (conjectured: `C ≤ 2`).

Here `KWComplexityExact(f) = inf {d | ∃ P : KWProtocol f d}`.

**Lean objects involved:** `MetaComplexity.KWWitness`, `CircuitComplexity.KWProto.cost`, `Nat.log`.

**Test:** For threshold functions `Thresh_{n,t}` with n ≤ 15, compute `log₂|KWWitness|` and compare with the minimum protocol cost (exhaustive search over small protocol trees). The gap should be ≤ 2·log₂(n+1).

**Refutation criterion:** A monotone function family where the gap grows as ω(log n) would refute this. A candidate refutation family: monotone functions with many isolated true vectors.

**Impact:** Would establish that witness entropy is essentially equivalent to communication complexity for monotone functions, up to a logarithmic correction — making witness counting a complete complexity measure.

---

## Hypothesis 3: Boundary Dominance for Monotone Symmetric Functions

**Conjecture:** For every monotone symmetric function `f` with threshold `t`, the witness count satisfies:

```
|KWWitness(f)| ≤ poly(n) · C(n,t) · C(n,t-1)
```

where `poly(n) ≤ n²`.

That is, the adjacent boundary layers `(t, t-1)` dominate the total witness count up to polynomial factors.

**Lean objects involved:** `MetaComplexity.card_KWWitness_threshold_ge_choose`, `MetaComplexity.layer_card_eq_choose`.

**Test:** For threshold functions with n ≤ 30 and various thresholds t, compute the ratio `|KWWitness| / (C(n,t)·C(n,t-1))`. The conjecture predicts this ratio is ≤ n².

**Refutation criterion:** If the ratio grows faster than n² for some threshold family, the conjecture fails. Based on computational evidence, the ratio appears to grow as roughly Θ(n) for central thresholds.

**Impact:** Would show that the boundary-layer lower bound proved in this cycle captures the dominant term, justifying its use as a practical complexity estimator.

---

## Hypothesis 4: Majority Maximizes Witness Entropy Among Monotone Symmetric Functions

**Conjecture:** Among all monotone symmetric Boolean functions on n variables, the majority function `Maj_n` maximizes `|KWWitness(f)|`.

Formally:
```
∀ f : SymmetricBoolFn n, IsMonotone f →
  |KWWitness(f)| ≤ |KWWitness(Maj_n)|
```

**Lean objects involved:** `MetaComplexity.KWWitness`, `MetaComplexity.majorityFn`, `MetaComplexity.thresholdFn`.

**Test:** For n ≤ 12, enumerate all monotone symmetric profiles (there are n+1 of them, one per threshold) and verify that the central threshold maximizes the witness count.

**Refutation criterion:** A non-majority monotone symmetric function with larger witness count would refute this. Based on computational evidence for n ≤ 30, majority always wins.

**Impact:** Would establish majority as the canonical "hardest" function in the symmetric monotone world, connecting to noise stability (majority maximizes noise sensitivity) and providing a tight benchmark for the entropy lower bound method.

---

## Hypothesis 5: Rectangle Rigidity for Low-Cost Majority Protocols

**Conjecture:** Every KW protocol for `Maj_n` of cost d partitions the witness relation into at most `2^d` monochromatic rectangles, and the largest rectangle contains at most `|KWWitness(Maj_n)| / 2^{d/2}` witnesses.

More precisely: if a protocol has cost d, then no single transcript (leaf of the protocol tree) can be reached by more than `|KWWitness(Maj_n)| · 2^{-d/2}` true/false input pairs.

**Lean objects involved:** `CircuitComplexity.KWProto`, `MetaComplexity.KWWitness`, `MetaComplexity.majorityFn`.

**Test:** For n ≤ 7, exhaustively search over all KW protocols of minimal cost and verify the rectangle density bound. This requires enumerating protocols, which is computationally expensive but feasible for small n.

**Refutation criterion:** A low-cost protocol with a highly concentrated rectangle (density exceeding `2^{-d/2}`) would refute this. The conjecture predicts that efficient protocols must distribute witnesses relatively uniformly.

**Impact:** Would provide a structural explanation for why majority is hard: not only are there many witnesses, but they resist concentration into compact combinatorial rectangles. This connects to the Razborov–Wigderson paradigm of approximation methods and would open a path to superlogarithmic formula depth lower bounds via witness geometry.

---

## Experimental Validation Plan

All five hypotheses can be partially validated computationally using the Python code provided in this cycle:

1. **Hypothesis 1:** Run `symmetric_kw_witness_count` against `exact_kw_witness_count` for all 2^(n+1) symmetric profiles, n ≤ 8.
2. **Hypothesis 2:** Implement protocol search and compare with `compression_lower_bound`.
3. **Hypothesis 3:** Run `witness_entropy_analysis` for all thresholds, check ratio bound.
4. **Hypothesis 4:** Run `symmetric_kw_count` for all monotone symmetric profiles, compare.
5. **Hypothesis 5:** Requires protocol enumeration infrastructure (next cycle target).

Each hypothesis failing would redirect the research program: failures in Hypotheses 1 or 3 would suggest the symmetric case is more subtle than expected; failure in Hypothesis 4 would reveal a surprising extremal structure; failure in Hypothesis 5 would suggest efficient protocols can exploit geometric concentration.


            ### Mathematical Framing
            # Future Directions in Formal Meta-Complexity

## Summary

This document identifies five falsifiable scientific hypotheses extending the formal meta-complexity framework established in this cycle. Each hypothesis is concrete enough to be tested computationally and proved or disproved in a formal proof assistant.

---

## Hypothesis 1: Exact Symmetric Witness Formula

**Conjecture:** For any symmetric Boolean function `f : (Fin n → Bool) → Bool` with profile `p : Fin (n+1) → Bool`, the KW witness cardinality is exactly:

```
|KWWitness(f)| = Σ_{k=0}^{n} Σ_{l=0}^{n} [p(k)=true ∧ p(l)=false] · C(n,k) · C(n,l) · |k-l|
```

**Lean objects involved:** `MetaComplexity.KWWitness`, `MetaComplexity.hammingWeight`, `MetaComplexity.IsSymmetric`, `Nat.choose`, `Nat.dist`.

**Test:** Compute both sides for all symmetric functions on n ≤ 8 variables. The formula should match the brute-force count in every case. A formal proof would proceed by partitioning `KWWitness(f)` by Hamming weight pairs (k,l) and showing each pair (x,y) of weights (k,l) contributes exactly |k-l| witnesses.

**Refutation criterion:** A single symmetric function where the formula gives a different value from the brute-force count would refute this. Computational evidence (verified for n ≤ 8 in this cycle's Python demos) strongly supports the conjecture.

**Impact:** Would convert the qualitative lower bound `C(n,t)·C(n,t-1) ≤ |KWWitness|` into an exact enumerative invariant. All lower bounds for symmetric functions would become bookkeeping.

---

## Hypothesis 2: Entropy Gap is O(log n) for Monotone Functions

**Conjecture:** For every monotone Boolean function `f : (Fin n → Bool) → Bool`,

```
log₂ |KWWitness(f)| - KWComplexityExact(f) ≤ C · log₂(n+1)
```

for a universal constant `C` (conjectured: `C ≤ 2`).

Here `KWComplexityExact(f) = inf {d | ∃ P : KWProtocol f d}`.

**Lean objects involved:** `MetaComplexity.KWWitness`, `CircuitComplexity.KWProto.cost`, `Nat.log`.

**Test:** For threshold functions `Thresh_{n,t}` with n ≤ 15, compute `log₂|KWWitness|` and compare with the minimum protocol cost (exhaustive search over small protocol trees). The gap should be ≤ 2·log₂(n+1).

**Refutation criterion:** A monotone function family where the gap grows as ω(log n) would refute this. A candidate refutation family: monotone functions with many isolated true vectors.

**Impact:** Would establish that witness entropy is essentially equivalent to communication complexity for monotone functions, up to a logarithmic correction — making witness counting a complete complexity measure.

---

## Hypothesis 3: Boundary Dominance for Monotone Symmetric Functions

**Conjecture:** For every monotone symmetric function `f` with threshold `t`, the witness count satisfies:

```
|KWWitness(f)| ≤ poly(n) · C(n,t) · C(n,t-1)
```

where `poly(n) ≤ n²`.

That is, the adjacent boundary layers `(t, t-1)` dominate the total witness count up to polynomial factors.

**Lean objects involved:** `MetaComplexity.card_KWWitness_threshold_ge_choose`, `MetaComplexity.layer_card_eq_choose`.

**Test:** For threshold functions with n ≤ 30 and various thresholds t, compute the ratio `|KWWitness| / (C(n,t)·C(n,t-1))`. The conjecture predicts this ratio is ≤ n².

**Refutation criterion:** If the ratio grows faster than n² for some threshold family, the conjecture fails. Based on computational evidence, the ratio appears to grow as roughly Θ(n) for central thresholds.

**Impact:** Would show that the boundary-layer lower bound proved in this cycle captures the dominant term, justifying its use as a practical complexity estimator.

---

## Hypothesis 4: Majority Maximizes Witness Entropy Among Monotone Symmetric Functions

**Conjecture:** Among all monotone symmetric Boolean functions on n variables, the majority function `Maj_n` maximizes `|KWWitness(f)|`.

Formally:
```
∀ f : SymmetricBoolFn n, IsMonotone f →
  |KWWitness(f)| ≤ |KWWitness(Maj_n)|
```

**Lean objects involved:** `MetaComplexity.KWWitness`, `MetaComplexity.majorityFn`, `MetaComplexity.thresholdFn`.

**Test:** For n ≤ 12, enumerate all monotone symmetric profiles (there are n+1 of them, one per threshold) and verify that the central threshold maximizes the witness count.

**Refutation criterion:** A non-majority monotone symmetric function with larger witness count would refute this. Based on computational evidence for n ≤ 30, majority always wins.

**Impact:** Would establish majority as the canonical "hardest" function in the symmetric monotone world, connecting to noise stability (majority maximizes noise sensitivity) and providing a tight benchmark for the entropy lower bound method.

---

## Hypothesis 5: Rectangle Rigidity for Low-Cost Majority Protocols

**Conjecture:** Every KW protocol for `Maj_n` of cost d partitions the witness relation into at most `2^d` monochromatic rectangles, and the largest rectangle contains at most `|KWWitness(Maj_n)| / 2^{d/2}` witnesses.

More precisely: if a protocol has cost d, then no single transcript (leaf of the protocol tree) can be reached by more than `|KWWitness(Maj_n)| · 2^{-d/2}` true/false input pairs.

**Lean objects involved:** `CircuitComplexity.KWProto`, `MetaComplexity.KWWitness`, `MetaComplexity.majorityFn`.

**Test:** For n ≤ 7, exhaustively search over all KW protocols of minimal cost and verify the rectangle density bound. This requires enumerating protocols, which is computationally expensive but feasible for small n.

**Refutation criterion:** A low-cost protocol with a highly concentrated rectangle (density exceeding `2^{-d/2}`) would refute this. The conjecture predicts that efficient protocols must distribute witnesses relatively uniformly.

**Impact:** Would provide a structural explanation for why majority is hard: not only are there many witnesses, but they resist concentration into compact combinatorial rectangles. This connects to the Razborov–Wigderson paradigm of approximation methods and would open a path to superlogarithmic formula depth lower bounds via witness geometry.

---

## Experimental Validation Plan

All five hypotheses can be partially validated computationally using the Python code provided in this cycle:

1. **Hypothesis 1:** Run `symmetric_kw_witness_count` against `exact_kw_witness_count` for all 2^(n+1) symmetric profiles, n ≤ 8.
2. **Hypothesis 2:** Implement protocol search and compare with `compression_lower_bound`.
3. **Hypothesis 3:** Run `witness_entropy_analysis` for all thresholds, check ratio bound.
4. **Hypothesis 4:** Run `symmetric_kw_count` for all monotone symmetric profiles, compare.
5. **Hypothesis 5:** Requires protocol enumeration infrastructure (next cycle target).

Each hypothesis failing would redirect the research program: failures in Hypotheses 1 or 3 would suggest the symmetric case is more subtle than expected; failure in Hypothesis 4 would reveal a surprising extremal structure; failure in Hypothesis 5 would suggest efficient protocols can exploit geometric concentration.



            ### Existing Verified Theorems
            Existing theorems you can build on:
  1. `key_dimension_lower_bound_from_height` : theorem key_dimension_lower_bound_from_height
     (file: Speculative/AutoResearch/AlgebraicInvariantCryptography.lean)
  2. `hammingWeight_lower_bound_base` : theorem hammingWeight_lower_bound_base
     (file: Speculative/AutoResearch/Bridges/ReedMuller/MinDistance.lean)
  3. `iterate_pair_bound_geometric` : theorem iterate_pair_bound_geometric
     (file: Speculative/AutoResearch/Bridges/UltrametricProofLearning.lean)
  4. `depth_lower_bound_from_degree` : theorem depth_lower_bound_from_degree (C : AlgCircuit R n) (d : ℕ)
     (file: Algebra/CircuitComplexity/AlgebraicCircuitComplexity.lean)
  5. `depth_lower_bound_log` : theorem depth_lower_bound_log (C : AlgCircuit R n) (d : ℕ)
     (file: Algebra/CircuitComplexity/CoordinateRingDepth.lean)

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
