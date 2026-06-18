
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

**Title**: The Topology of Knotted Light: How Laser Beams Get Tangled
**Domain**: Applications
**Mathematical framing**: Laser beams can carry orbital angular momentum (OAM), creating 'knotted light' — beams whose wavefronts are linked or knotted. A knotted light beam has a phase singularity (where the amplitude vanishes) that traces out a knot in 3D space. The simplest example is the trefoil beam, whose singularity traces a trefoil knot. Conjecture: The OAM spectrum of a knotted light beam encodes the Alexander polynomial of the knot. Specifically, if the singularity of the beam traces a knot K, then the OAM spectrum (the set of allowed angular momentum values) is {l : Delta_K(e^{2*pi*i*l/N}) = 0} where Delta_K is the Alexander polynomial of K and N is the crossing number. For the trefoil (Delta = t^2 - t + 1), the OAM spectrum includes l = 1/6, 5/6 (mod 1), giving OAM values l = 1, 5 (mod 6). For the unknot (Delta = 1), the OAM spectrum is trivial (l = 0 only). For the figure-eight knot (Delta = t^2 - 3t + 1), the OAM values include l = (3 ± sqrt(5))/2 mod 1. Test: compute the OAM spectrum of trefoil, figure-eight, and cinquefoil beams numerically and verify they match the Alexander polynomial predictions. Impact: knotted light carries knot invariants in its angular momentum — shining a laser through a knot-shaped hologram encodes the Alexander polynomial in the beam's quantum numbers.
**Concept description**: Laser beams can carry orbital angular momentum (OAM), creating 'knotted light' — beams whose wavefronts are linked or knotted. A knotted light beam has a phase singularity (where the amplitude vanishes) that traces out a knot in 3D space. The simplest example is the trefoil beam, whose singularity traces a trefoil knot. Conjecture: The OAM spectrum of a knotted light beam encodes the Alexander polynomial of the knot. Specifically, if the singularity of the beam traces a knot K, then the OAM spectrum (the set of allowed angular momentum values) is {l : Delta_K(e^{2*pi*i*l/N}) = 0} where Delta_K is the Alexander polynomial of K and N is the crossing number. For the trefoil (Delta = t^2 - t + 1), the OAM spectrum includes l = 1/6, 5/6 (mod 1), giving OAM values l = 1, 5 (mod 6). For the unknot (Delta = 1), the OAM spectrum is trivial (l = 0 only). For the figure-eight knot (Delta = t^2 - 3t + 1), the OAM values include l = (3 ± sqrt(5))/2 mod 1. Test: compute the OAM spectrum of trefoil, figure-eight, and cinquefoil beams numerically and verify they match the Alexander polynomial predictions. Impact: knotted light carries knot invariants in its angular momentum — shining a laser through a knot-shaped hologram encodes the Alexander polynomial in the beam's quantum numbers.
**Novelty estimate**: 0.7921999999999999
**Breakthrough potential**: 0.79
Research domain: Applications
Research mode: team


### Lean 4 Sketch
Define knotted light: a paraxial beam psi(x,y,z) = u(r,phi,z) * exp(i*l*phi) where l is the OAM quantum number and u vanishes on a knot K. The phase singularity traces K in 3D. Define the Alexander polynomial Delta_K(t) of the knot K. Conjecture: the OAM spectrum {l : the beam with OAM l exists as a stable mode} equals {l : Delta_K(e^{2*pi*i*l/N}) = 0} where N is the crossing number. Proof sketch: the wave equation on the complement S^3 - K has solutions with angular momentum l if and only if th



### Recent Discoveries in Catalog
No previous research cycles completed yet. This is a cold start — prioritize sorry_fill on the priority targets (CarmichaelComposite, Fib_gcd_identity) to close known open problems, or target cross-domain bridge theorems for novelty.


## v14 Depth Requirements -- Synthetic Catalog Integration Engine

You are leading a mathematical research team. Your goal is to produce groundbreaking,
master-class, useful, novel, and marvelous new Mathematics that pushes the frontier of human knowledge.

This engine is configured for **Synthetic Catalog Integration**. Focus on building a coherent body of work on top of our existing catalog.

### RESEARCH CORE METHODOLOGY:
1. **Lineage Synthesis**: Analyze the existing catalog context deeply. Do not reinvent definitions; import and build directly on top of the validated catalog results.
2. **Connect the Dots**: Search for "orphan" results or gaps in the catalog and construct bridges to connect them. Show how new theorems advance the overall mathematical architecture of the repository.
3. **Foundational Extension**: Take successful packages from the catalog and extend their results to broader algebraic settings, sharper bounds, or new domain applications.

### DELIVERABLES:
- **Lean 4 proofs** of deep, non-trivial theorems with complete proofs (no sorry on main results).
- **Lab Notebook** comment blocks in each .lean file detailing Hypothesis, Result, Insight, and Failure analysis.
- **FUTURE_DIRECTIONS.md** outlining the Synthesis of your findings, a Results Summary, and 3-5 bold, falsifiable research directions to steer the next cycle.


## Output format reminder

Your output must include `.lean` files AND a `FUTURE_DIRECTIONS.md` file.
The .lean files contain the proofs. The FUTURE_DIRECTIONS.md contains 3-5
research conjectures that extend the work. Both are required.
Be precise, be deep, be world-class.
