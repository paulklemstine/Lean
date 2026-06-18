
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

**Title**: Crystallographic Groups and Music: The 17 Wallpaper Groups of Rhythm
**Domain**: MachineLearning
**Mathematical framing**: A periodic rhythm in music is a function f: Z -> {0, 1} that is periodic: f(n + p) = f(n) for some period p. The symmetry group of a rhythm with period p is a subgroup of Z/pZ. But music also has 2D patterns: a drum pattern is a function g: Z x Z -> {0, 1} (onset grid in time x pitch). The symmetry group of a drum pattern is a subgroup of Z x Z, which is a wallpaper group in 1D. In 2D, the wallpaper groups classify all possible symmetries of periodic patterns. There are exactly 17 wallpaper groups in 2D. Conjecture: the 17 wallpaper groups correspond to 17 fundamentally different types of rhythmic structure in music. Specifically: (1) p1: no symmetry (free rhythm), (2) p2: 2-fold rotational symmetry (call-and-response), (3) pm: mirror symmetry (palindrome), (4) pg: glide reflection (canon), (5) cm: mirror + glide (round), (6) pmm: double mirror (bilateral palindrome), (7) pmg: mirror + glide (inverted canon), (8) pgg: double glide (double canon), (9) cmm: double mirror + glide (round + palindrome), (10) p4: 4-fold rotation (4-bar cycle), (11) p4m: 4-fold + mirrors (variations on a theme), (12) p4g: 4-fold + glides (inverted variations), (13) p3: 3-fold rotation (3-bar blues), (14) p3m1: 3-fold + mirrors, (15) p31m: 3-fold + glides, (16) p6: 6-fold rotation (whole-tone scale symmetry), (17) p6m: 6-fold + mirrors (maximal symmetry, the 'perfect' rhythm). Test: classify 1000 drum patterns by their wallpaper group and verify the distribution matches musical practice. Impact: there are exactly 17 types of rhythm in music, classified by the wallpaper groups.
**Concept description**: A periodic rhythm in music is a function f: Z -> {0, 1} that is periodic: f(n + p) = f(n) for some period p. The symmetry group of a rhythm with period p is a subgroup of Z/pZ. But music also has 2D patterns: a drum pattern is a function g: Z x Z -> {0, 1} (onset grid in time x pitch). The symmetry group of a drum pattern is a subgroup of Z x Z, which is a wallpaper group in 1D. In 2D, the wallpaper groups classify all possible symmetries of periodic patterns. There are exactly 17 wallpaper groups in 2D. Conjecture: the 17 wallpaper groups correspond to 17 fundamentally different types of rhythmic structure in music. Specifically: (1) p1: no symmetry (free rhythm), (2) p2: 2-fold rotational symmetry (call-and-response), (3) pm: mirror symmetry (palindrome), (4) pg: glide reflection (canon), (5) cm: mirror + glide (round), (6) pmm: double mirror (bilateral palindrome), (7) pmg: mirror + glide (inverted canon), (8) pgg: double glide (double canon), (9) cmm: double mirror + glide (round + palindrome), (10) p4: 4-fold rotation (4-bar cycle), (11) p4m: 4-fold + mirrors (variations on a theme), (12) p4g: 4-fold + glides (inverted variations), (13) p3: 3-fold rotation (3-bar blues), (14) p3m1: 3-fold + mirrors, (15) p31m: 3-fold + glides, (16) p6: 6-fold rotation (whole-tone scale symmetry), (17) p6m: 6-fold + mirrors (maximal symmetry, the 'perfect' rhythm). Test: classify 1000 drum patterns by their wallpaper group and verify the distribution matches musical practice. Impact: there are exactly 17 types of rhythm in music, classified by the wallpaper groups.
**Novelty estimate**: 0.6891865446593555
**Breakthrough potential**: 0.68
Research domain: MachineLearning
Research mode: team


### Lean 4 Sketch
Define a drum pattern as a function g: Z_m x Z_n -> {0, 1} (onset grid with m time steps and n pitch classes). The symmetry group of g is the set of (a, b, R) in Z_m x Z_n x D_n such that g(R*x + a, R*y + b) = g(x, y) for all (x, y). Here D_n is the dihedral group of order 2n. For 2D patterns with translation lattice L, the symmetry group is a wallpaper group. The 17 wallpaper groups are: p1, p2, pm, pg, cm, pmm, pmg, pgg, cmm, p4, p4m, p4g, p3, p3m1, p31m, p6, p6m. Each corresponds to a differe



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
