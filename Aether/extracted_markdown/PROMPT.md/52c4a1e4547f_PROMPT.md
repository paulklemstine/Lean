
            ## PHASE A: LEAN 4 ONLY — DOING THE MATH

            You are leading a research team: Hypothesizer, Experimenter, Analyst,
Critic, and Synthesist. Run the loop:
Hypothesize -> Experiment -> Analyze -> Critique -> Generalize -> Iterate.
Your ONLY job is to produce **new Lean 4 code** and **take good notes**
for the next team.

            ### DELIVERABLES (strict — only this):
            1. **lean files (count chosen by theorem declarations)**
            2. **2-4 theorems with correct proofs (sorry = 0 on main results)**
            3. **Brief proof sketches** as `-- !-- comment -- !--` blocks (1-2 sentences each)
            4. **A FUTURE_DIRECTIONS.md file** listing 3-5 testable, falsifiable
               conjectures as a freeform narrative (NOT a form). Each direction MUST
               include a "The key insight is..." sentence and a "Why now?" justification.
               This file drives the next research cycle — make it count.
5. **Lab Notebook** as `-- !-- Lab Notebook -- !--` comment blocks
   in each .lean file: Hypothesis, Result, Insight, Failure analysis.

            ### DO NOT OUTPUT (Phase B handles these — if your work passes quality bar):
            - NO `ARTICLE.md`
            - NO `RESEARCH_PAPER.md`
            - NO `demo.py` / `algorithms.py`
            - NO HTML widgets
            - NO `PACKAGE.json`
            - NO prose for human readers (except FUTURE_DIRECTIONS.md)

            ### WHY THIS NARROW:
            The Lean 4 file IS the deliverable. A self-contained Lean file with
            3-5 world-class theorems is worth more than 30K characters of prose
            about trivial results. Focus 100% of your compute on the math.
            If your work is genuinely world-class, the packaging step is dispatched
            automatically and cheaply.

            ### CATALOG SYNTHESIS (required — read the catalog context below):
            The Catalog Context and Recent Discoveries sections list existing theorems
            already proven in this project. You MUST analyze these and combine concepts
            from the catalog with the research direction above. Specifically:

            1. **Identify relevant catalog theorems** — Which existing results connect
               to your research direction? Cite them by name in your proof sketches.
            2. **Build on catalog foundations** — Your theorems should EXTEND or
               GENERALIZE catalog results, not reprove them from scratch. Use `import`
               and reference existing definitions and lemmas where possible.
            3. **Combine concepts across domains** — The most valuable theorems connect
               ideas from different catalog domains (e.g., applying algebraic structures
               to topological problems, or using combinatorial arguments in number theory).
               Look for cross-domain connections in the catalog context.
            4. **Avoid duplication** — Check the catalog context before proving. If a
               similar result already exists, extend it rather than reproving it.


## Concept

**Title**: Tropical Cryptocurrency: Mining on the Min-Plus Semiring
**Domain**: Bridges
**Mathematical framing**: Bitcoin mining requires finding a nonce n such that SHA256(block_header || n) < target. What if we replaced SHA256 with a tropical hash? Define tropical SHA as: TSHA(m) = min over all i of (m_i + h_i) where m = (m_1,...,m_k) is the message, h = (h_1,...,h_k) is the tropical hash key, and all operations are in the min-plus semiring (a tropical plus b = min(a,b), a tropical times b = a + b). Conjecture: TSHA is a one-way function in the tropical sense: computing TSHA(m) given m and h is O(k) (trivial), but finding m given TSHA(m) and h is NP-hard (it reduces to a tropical shortest path problem). More precisely, the tropical preimage problem — given y and h, find m such that min_i(m_i + h_i) = y — requires checking O(e^{k}) tropical paths in the worst case. But there's a twist: tropical hash collisions are COMMON because min(a,b) = min(b,a). To fix this, define TSHA2(m) = (min_i(m_i + h_i), min_i(m_i + h'_i)) where h and h' are two independent tropical keys. Conjecture: TSHA2 is collision-resistant with probability 1 - O(1/k). Test: implement TSHA and TSHA2, measure collision resistance, and compare mining difficulty to SHA256 for block sizes k = 32, 64, 128. Impact: a cryptocurrency where mining is solving tropical optimization problems instead of brute-force hash searches — mining IS mathematics.
**Concept description**: Bitcoin mining requires finding a nonce n such that SHA256(block_header || n) < target. What if we replaced SHA256 with a tropical hash? Define tropical SHA as: TSHA(m) = min over all i of (m_i + h_i) where m = (m_1,...,m_k) is the message, h = (h_1,...,h_k) is the tropical hash key, and all operations are in the min-plus semiring (a tropical plus b = min(a,b), a tropical times b = a + b). Conjecture: TSHA is a one-way function in the tropical sense: computing TSHA(m) given m and h is O(k) (trivial), but finding m given TSHA(m) and h is NP-hard (it reduces to a tropical shortest path problem). More precisely, the tropical preimage problem — given y and h, find m such that min_i(m_i + h_i) = y — requires checking O(e^{k}) tropical paths in the worst case. But there's a twist: tropical hash collisions are COMMON because min(a,b) = min(b,a). To fix this, define TSHA2(m) = (min_i(m_i + h_i), min_i(m_i + h'_i)) where h and h' are two independent tropical keys. Conjecture: TSHA2 is collision-resistant with probability 1 - O(1/k). Test: implement TSHA and TSHA2, measure collision resistance, and compare mining difficulty to SHA256 for block sizes k = 32, 64, 128. Impact: a cryptocurrency where mining is solving tropical optimization problems instead of brute-force hash searches — mining IS mathematics.
**Novelty estimate**: 0.7921999999999999
**Breakthrough potential**: 0.79
Research domain: Bridges
Research mode: team


### Lean 4 Sketch
Define TSHA(m, h) = min_{i=1..k} (m_i + h_i) in the min-plus semiring. Prove: TSHA is O(k) to compute (single pass). Prove: finding m given TSHA(m,h) = y and h is NP-hard by reduction from the tropical shortest path problem. Reduction: given a weighted graph G, let h encode the edge weights and let m encode the path. Then TSHA(m,h) = length of shortest path. Finding m that achieves a given TSHA value equals finding the shortest path. Prove TSHA2 collision resistance: P(TSHA2(m) = TSHA2(m')) = O(



### Recent Discoveries in Catalog
No previous research cycles completed yet. This is a cold start — prioritize sorry_fill on the priority targets (CarmichaelComposite, Fib_gcd_identity) to close known open problems, or target cross-domain bridge theorems for novelty.


## v14 Depth Requirements -- Conceptual Unifier: Local-to-Global Sheaves Research Engine

You are leading a mathematical research team. Your goal is to produce groundbreaking,
master-class, useful, novel, and marvelous new Mathematics that pushes the frontier of human knowledge.

This engine is configured for **Conceptual Unification (Local-to-Global Sheaves)**. Explore sheaf theory, local-to-global translations, and cohomological obstructions.

### RESEARCH CORE METHODOLOGY:
1. **Local-to-Global Translation**: Construct sheaves or presheaves to describe local properties that glue together to form global structures. Check if local solutions can be extended globally.
2. **Obstruction Theory & Cohomology**: Use cohomology groups or obstruction classes to mathematically measure the failure or boundaries of local-to-global extensions.
3. **Stalk-Level Reduction**: Reduce complex global proofs to stalk-level computations or local neighborhood verifications, using algebraic localization or geometric limits.

### DELIVERABLES:
- **Lean 4 proofs** of deep, non-trivial theorems with complete proofs (no sorry on main results).
- **Lab Notebook** comment blocks in each .lean file detailing Hypothesis, Result, Insight, and Failure analysis.
- **FUTURE_DIRECTIONS.md** outlining the Synthesis of your findings, a Results Summary, and 3-5 bold, falsifiable research directions to steer the next cycle.


## Output format reminder

Your output must include `.lean` files AND a `FUTURE_DIRECTIONS.md` file.
The .lean files contain the proofs. The FUTURE_DIRECTIONS.md contains 3-5
research conjectures that extend the work. Both are required.
Be precise, be deep, be world-class.
