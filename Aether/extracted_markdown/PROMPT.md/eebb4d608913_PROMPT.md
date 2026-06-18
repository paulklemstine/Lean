
## PHASE A: LEAN 4 ONLY — DOING THE MATH

You are a world-class mathematician. Your ONLY job in this cycle is
to produce **new Lean 4 code that extends the frontier of mathematics**.

### DELIVERABLES (strict — only this):
1. **1-3 .lean files in `Catalog/{concept.domain}/<package_name>/`**
2. **3-5 non-trivial theorems with `sorry = 0` (PROVED, not admitted)**
3. **Brief proof sketches** as `-- !-- comment -- !--` blocks (1-2 sentences each)
4. **A trailing comment block** titled `FUTURE DIRECTIONS` listing
   3-5 testable, falsifiable conjectures

### DO NOT OUTPUT (Phase B handles these — if your work passes quality bar):
- NO `ARTICLE.md`
- NO `RESEARCH_PAPER.md`
- NO `demo.py` / `algorithms.py`
- NO HTML widgets
- NO `PACKAGE.json`
- NO prose for human readers

### WHY THIS NARROW:
The Lean 4 file IS the deliverable. A self-contained Lean file with
3-5 world-class theorems is worth more than 30K characters of prose
about trivial results. Focus 100% of your compute on the math.
If your work is genuinely world-class, the packaging step is dispatched
automatically and cheaply.


## Concept

**Title**: Hypergraph Ramsey Theory: Beyond Graphs
**Domain**: Computation
**Mathematical framing**: Ramsey's theorem for graphs states that R(k,l) = the minimum n such that any 2-coloring of the edges of K_n contains a red K_k or a blue K_l. For hypergraphs: R_r(k,l) = the minimum n such that any 2-coloring of the r-tuples of an n-set contains a red K_k^{(r)} or a blue K_l^{(r)}. The growth rate is an open problem: R_3(4,4) = 13 (known), R_3(5,5) is between 34 and 55, and R_3(k,k) is believed to grow like a double exponential 2^{c*k^2}. Conjecture: R_3(k,k) ~ 2^{2^{ck}} for some constant c > 0. This is a tower function (height 2 exponential). More precisely: the lower bound R_3(k,k) >= 2^{ck^2} (from the probabilistic method) and the upper bound R_3(k,k) <= 2^{2^{ck}} (from the stepping-up lemma). The gap is between a single exponential and a double exponential. Conjecture: the true growth rate is double exponential, and the upper bound is tight. This would mean that 3-uniform Ramsey numbers grow much faster than graph Ramsey numbers. Test: compute R_3(k,k) for k = 3, 4, 5, 6 by exhaustive search and verify the growth rate. Impact: 3-uniform Ramsey numbers are double exponential. Combinatorics at the hypergraph level is fundamentally harder than at the graph level.
**Concept description**: Ramsey's theorem for graphs states that R(k,l) = the minimum n such that any 2-coloring of the edges of K_n contains a red K_k or a blue K_l. For hypergraphs: R_r(k,l) = the minimum n such that any 2-coloring of the r-tuples of an n-set contains a red K_k^{(r)} or a blue K_l^{(r)}. The growth rate is an open problem: R_3(4,4) = 13 (known), R_3(5,5) is between 34 and 55, and R_3(k,k) is believed to grow like a double exponential 2^{c*k^2}. Conjecture: R_3(k,k) ~ 2^{2^{ck}} for some constant c > 0. This is a tower function (height 2 exponential). More precisely: the lower bound R_3(k,k) >= 2^{ck^2} (from the probabilistic method) and the upper bound R_3(k,k) <= 2^{2^{ck}} (from the stepping-up lemma). The gap is between a single exponential and a double exponential. Conjecture: the true growth rate is double exponential, and the upper bound is tight. This would mean that 3-uniform Ramsey numbers grow much faster than graph Ramsey numbers. Test: compute R_3(k,k) for k = 3, 4, 5, 6 by exhaustive search and verify the growth rate. Impact: 3-uniform Ramsey numbers are double exponential. Combinatorics at the hypergraph level is fundamentally harder than at the graph level.
**Novelty estimate**: 0.05
**Breakthrough potential**: 0.04488
Research domain: Computation
Research mode: team


### Lean 4 Sketch
3-uniform Ramsey number R_3(k,k): minimum n such that any red/blue coloring of the 3-element subsets of [n] contains a monochromatic set of size k. Known values: R_3(3,3) = 13 (proved), R_3(4,4) is between 34 and 55 (current bounds). Lower bound (probabilistic method): R_3(k,k) >= 2^{ck^2} for some constant c. Proof: color each 3-set randomly. P(monochromatic K_k^{(3)}) < 2 * C(n,k) * 2^{-C(k,3)}. This is < 1 when n < 2^{k^2/6}. So R_3(k,k) > 2^{k^2/6}. Upper bound (stepping-up lemma): if R_3(k,



### Recent Discoveries in Catalog
No previous research cycles completed yet. This is a cold start — prioritize sorry_fill on the priority targets (CarmichaelComposite, Fib_gcd_identity) to close known open problems, or target cross-domain bridge theorems for novelty.


## Depth Requirements (MANDATORY — WORLD-CLASS STANDARD)

Your output must satisfy ALL of these. This is not incremental work.
This is the frontier. Act accordingly.

1. **NO trivial proofs**: Do NOT prove statements by `native_decide`, `decide`,
   `norm_num`, or `rfl` unless the statement itself is genuinely important.
   If the only proof tactic is enumeration, the theorem is not worth formalizing.

2. **DEFINE a novel mathematical structure** (CORE REQUIREMENT): Your cycle
   must introduce at least one NEW mathematical object — a structure, a
   construction, a notion, a category, an operator — that does not already
   exist in the Catalog or in standard references. This is the seed of new
   mathematics. The definition must be substantial (not a one-liner renaming
   of a known concept) and must come with at least 3 theorems that PROVE
   non-obvious properties of the new structure.

   Think like Grothendieck defining schemes, or Rota defining matroids, or
   Voiculescu defining free probability. The structure is the contribution.
   The theorems are the evidence that the structure is useful.

   **Critical constraint**: A "novel mathematical structure" must be a
   genuine mathematical object — a formal construction with a precise
   definition, ideally with operations or axioms. **Mathematics of X** where
   X is a real-world phenomenon (memes, dreams, consciousness, art, music,
   jokes, social networks) is NOT a mathematical structure unless you
   formalize X as a precise mathematical object first and then prove
   theorems about THAT object. If you can't formalize X rigorously, pick a
   different X — choose a topic where the math comes naturally.

3. **PEGB for every major theorem** (Proof + Example + Generalization + Boundary):
   For each of your top 3-5 theorems, you MUST produce all four:
   - **P**roof: A complete, non-trivial Lean 4 proof
   - **E**xample: A concrete worked example
   - **G**eneralization: A one-level-up generalization
   - **B**oundary: A counterexample or limit-case analysis

   A theorem without PEGB is a one-off. A theorem WITH PEGB is a research
   program. We are building research programs, not collecting isolated facts.

4. **Conjecture with testable prediction**: State at least one falsifiable
   conjecture with a clear computational test that could disprove it.

5. **Cross-connection**: At least one theorem should genuinely connect to
   or build upon an existing catalog result.


## Output format reminder

The ONLY files in your output should be 1-3 `.lean` files. The Lean code itself
is the deliverable. Be precise, be deep, be world-class.
