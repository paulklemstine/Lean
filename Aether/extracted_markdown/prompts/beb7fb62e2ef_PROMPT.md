
## PHASE A: LEAN 4 ONLY — DOING THE MATH

You are a world-class mathematician. Your ONLY job in this cycle is
to produce **new Lean 4 code that extends the frontier of mathematics**.

### DELIVERABLES (strict — only this):
1. **lean files (count chosen by the Plan)**
2. **2-4 theorems with correct proofs (sorry = 0 on main results)**
3. **Brief proof sketches** as `-- !-- comment -- !--` blocks (1-2 sentences each)
4. **A FUTURE_DIRECTIONS.md file** listing 3-5 testable, falsifiable
   conjectures as a freeform narrative (NOT a form). Each direction MUST
   include a "The key insight is..." sentence and a "Why now?" justification.
   This file drives the next research cycle — make it count.

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


## Concept

**Title**: Stereographic Sheaf Theory: Gluing Data on Spheres
**Domain**: Geometry
**Mathematical framing**: Sheaf theory studies how local data glues to form global objects. The stereographic projection gives S^n a two-chart atlas with Mobius transition maps. Define a new class of sheaves called stereographic sheaves where the gluing data is constrained by the conformal structure of the stereographic atlas. A stereographic sheaf on S^n is a sheaf F such that for each chart U_i of the stereographic cover, the restriction F|U_i is a sheaf on R^n, and the transition function F(U_0 cap U_1) is a sheaf morphism that commutes with the Mobius transition. Conjecture: The category of stereographic sheaves on S^n is a proper subcategory of all sheaves on S^n, characterized by the condition that Cech cohomology with respect to the stereographic cover satisfies a Mobius compatibility. This subcategory has better computational properties: H^k(S^n, F) can be computed from the transition function alone for stereographic sheaves, reducing the computation of sheaf cohomology on S^n to a single gluing datum. Test: prove the equivalence with locally constant sheaves on RP^n for n=2,3. Compute H^1(S^2, Z) = Z/2Z for the constant sheaf Z. Impact: a new computational tool for sheaf cohomology that exploits conformal structure, with applications to topological data analysis and differential equations on spheres.
**Concept description**: Sheaf theory studies how local data glues to form global objects. The stereographic projection gives S^n a two-chart atlas with Mobius transition maps. Define a new class of sheaves called stereographic sheaves where the gluing data is constrained by the conformal structure of the stereographic atlas. A stereographic sheaf on S^n is a sheaf F such that for each chart U_i of the stereographic cover, the restriction F|U_i is a sheaf on R^n, and the transition function F(U_0 cap U_1) is a sheaf morphism that commutes with the Mobius transition. Conjecture: The category of stereographic sheaves on S^n is a proper subcategory of all sheaves on S^n, characterized by the condition that Cech cohomology with respect to the stereographic cover satisfies a Mobius compatibility. This subcategory has better computational properties: H^k(S^n, F) can be computed from the transition function alone for stereographic sheaves, reducing the computation of sheaf cohomology on S^n to a single gluing datum. Test: prove the equivalence with locally constant sheaves on RP^n for n=2,3. Compute H^1(S^2, Z) = Z/2Z for the constant sheaf Z. Impact: a new computational tool for sheaf cohomology that exploits conformal structure, with applications to topological data analysis and differential equations on spheres.
**Novelty estimate**: 0.88
**Breakthrough potential**: 0.88
Research domain: Geometry
Research mode: team


### Lean 4 Sketch
Define a stereographic sheaf as a sheaf on S^n whose restriction to each chart of the stereographic atlas satisfies a compatibility condition: the transition functions are Mobius transformations. Prove that the category of stereographic sheaves on S^n is equivalent to the category of locally constant sheaves on RP^n (real projective n-space). The key step: the stereographic cover has two charts, so Cech cohomology reduces to computing the gluing datum. Test: compute H^1(S^2, Z) for the constant 



### Recent Discoveries in Catalog
No previous research cycles completed yet. This is a cold start — prioritize sorry_fill on the priority targets (CarmichaelComposite, Fib_gcd_identity) to close known open problems, or target cross-domain bridge theorems for novelty.


## v5 Depth Requirements (MANDATORY — WORLD-CLASS STANDARD)

You are working on the frontier of mathematics. The Catalog has 100+ research
packages already. Each new cycle must contribute something genuinely new —
not a rephrasing, not a textbook exercise, not a "mathematics of X" parlor trick.

### STEP 1: PLAN (REQUIRED — before any Lean code)

Before writing any `.lean` file, you MUST output a `## Plan` section that
states, in plain prose:

- **Strategy**: Grothendieck path (define a new structure, prove its properties)
  OR Cauchy path (extend an existing catalog result). Choose the one that fits
  the concept. Do BOTH only if the concept genuinely demands it.
- **Files**: What `.lean` files you will create and what each contains.
  Use sensible names. No fixed count.
- **Theorems**: A list of the theorems you will prove, with one-sentence statements.
- **Why this is non-trivial**: A paragraph explaining the structural insight
  that makes this work world-class. If you cannot write this paragraph, the
  work is not world-class. Pick a different concept.

The Plan is not optional. Cycles that skip the Plan are rejected.

### STEP 2: PEGB for EVERY theorem (strict)

For EACH theorem you prove, you MUST provide all four of:

- **P**roof: A complete, non-trivial Lean 4 proof.
- **E**xample: A concrete worked example (an `example` block or a specific instance).
- **G**eneralization: A one-level-up generalization (a stronger statement, a
  broader class, a higher categorical level). State it as a `theorem` or `lemma`
  with `sorry` if proving it would take the cycle too far — but STATE it.
- **B**oundary: A counterexample or limit-case analysis. When does the result
  fail? What assumptions are essential?

"Top 3-5 theorems" is no longer accepted. EVERY theorem you produce must have
full PEGB. If you produce 2 theorems with full PEGB, that's better than 5 theorems
with PEGB on only 2.

### STEP 3: Anti-patterns (REJECTED outright)

The following tactics are BLACKLISTED for the primary proof of any non-trivial theorem:

- `native_decide`, `decide`, `norm_num`, `rfl` — unless the statement is genuinely
  a numeric/equality fact and the tactic is doing real work (not papering over
  a structural insight).
- `Aesop` — unless the goal is provably trivial (≤ 3 hypotheses, no arithmetic).
- `omega`, `linarith` on quantified goals — these are not "proofs" of structural
  statements.
- `simp only []` with no explicit simp set — this is "let the lemma solver figure it out."

If your only proof of a non-trivial theorem uses one of these, the theorem is not
worth proving. Find a structural proof, or drop the theorem.

### STEP 4: Novelty check

A theorem is "novel" only if a working mathematician in the area would say
"I haven't seen that before." Test yourself:

- Is the statement in a textbook? If yes, find a non-trivial generalization.
- Is the statement a rephrasing of a known result? If yes, the cycle is not novel.
- Is the proof essentially the same as a known proof? If yes, the contribution
  is the statement, not the proof — make sure the statement is genuinely new.

"Mathematics of X" where X is a real-world phenomenon (memes, dreams, consciousness,
art, music, social networks) is NOT a mathematical contribution unless you formalize
X as a precise mathematical object first. If you cannot formalize X rigorously, pick
a different topic.

### STEP 5: Either path (Aristotle's choice)

You are NOT required to follow a specific path. Choose the one that fits the concept:

**Grothendieck path** (define a new structure):
- Invent a new operator, category, algebraic variety, or combinatorial object.
- State its defining properties as axioms or definitions.
- Prove 2-4 non-obvious theorems about it.
- Best for: novel concepts, unexplored territory, "what if we defined X this way?".

**Cauchy path** (extend an existing result):
- Pick a specific catalog theorem (cite it by name).
- Generalize, strengthen, or bridge it.
- Prove the new version is strictly stronger or more general.
- Best for: deepening the catalog, building on existing strength.

You may do BOTH if the concept requires it. But the Plan must justify why both paths
are needed in a single cycle.

### STEP 6: Theorem count

No fixed count. Some concepts deserve 2 deep theorems. Some deserve 6. The Plan
must justify the count. The quality bar is "every theorem has full PEGB" — not
"produce a specific number".

### STEP 7: Cite your sources

Your `## Plan` and any prose must reference specific catalog results by name or path
when you build on them. The catalog is the substrate; you are growing new math on it.


## Output format reminder

Your output must include `.lean` files AND a `FUTURE_DIRECTIONS.md` file.
The .lean files contain the proofs. The FUTURE_DIRECTIONS.md contains 3-5
research conjectures that extend the work. Both are required.
Be precise, be deep, be world-class.
