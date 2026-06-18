
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

**Title**: The sphere-packing bound gives an upper bound on code size, but the
**Domain**: Novelty
**Mathematical framing**: # Future Directions: The Library of Babel

## 1. Gilbert-Varshamov Bound and Asymptotic Rates

The sphere-packing bound gives an upper bound on code size, but the
Gilbert-Varshamov bound gives a *lower* bound: there exists a code of size
at least k^n / V(n, d-1) where V is the Hamming ball volume. Together with
our `hamming_ball_card` and `sphere_packing_bound`, formalizing the GV bound
would complete the classical coding theory trifecta.

The key insight is that the GV bound follows from a greedy argument: keep
adding codewords until no more can be added without violating the distance
constraint. The ball volumes we've computed are exactly what's needed.

Why now? We have sorry-free `hamming_ball_card` and `sphere_packing_bound`.
The GV bound is the natural next step and would be the first formalization
of this result in Lean 4 / Mathlib.

## 2. Plotkin Bound via Hamming Weight Double-Counting

When the minimum distance d exceeds n/2, the sphere-packing bound becomes
trivial. The Plotkin bound fills this gap: if d > n/2, then |C| ≤ 2d/(2d-n)
for binary codes. The proof uses a beautiful double-counting argument on the
total Hamming weight of all pairwise distances.

The key insight is that ∑_{c,c' ∈ C} d(c,c') can be computed both as a sum
over pairs and as a sum over coordinates, yielding the bound. This bridges
our Hamming metric formalization with linear algebra over F_2.

Why now? The `hammingDist_book` infrastructure and triangle inequality are
in place. The Plotkin bound requires only elementary double-counting, not
the algebraic machinery of polynomial codes.

## 3. Kolmogorov Complexity via Turing Machines

Our `incompressibility_counting` theorem is the counting core of Kolmogorov
complexity, but without Turing machines. Formalizing a minimal Turing machine
model and defining K(x) = min{|p| : U(p) = x} would connect our combinatorial
results to algorithmic information theory proper.

The key insight is that once K(x) is defined, our `fraction_compressible_bound`
immediately gives |{x : K(x) < |x| - d}| ≤ 2^(|x|-d), the "most strings are
random" theorem of Kolmogorov complexity.

Why now? Lean 4 has good support for recursive function definitions. A minimal
UTM formalization (even a string rewriting system) would suffice to state K(x).

## 4. Perfect Codes Classification

Our sphere-packing bound achieves equality for "perfect codes." The classification
theorem states that the only nontrivial perfect binary codes are the Hamming codes
(parameters [2^r - 1, 2^r - r - 1, 3]) and the binary Golay code [23, 12, 7].
Formalizing that Hamming codes achieve equality in `sphere_packing_bound` would
be a clean application of our ball cardinality formula.

The key insight is that for Hamming codes, k^n / V(n,t) is exactly an integer
(= 2^{n-r}), which is equivalent to the ball volumes partitioning the space.
This connects combinatorial coding theory to finite geometry (projective spaces
over F_2).

Why now? We have the exact ball cardinality formula. Verifying that 2^n = 2^{n-r} * V(n,1)
for n = 2^r - 1 is a concrete numerical identity that our framework can check.

## 5. Metric Entropy and Covering Numbers

The Hamming ball cardinality determines the ε-covering number N(ε) of the Library:
the minimum number of balls of radius ε needed to cover the space. This connects
to metric entropy H(ε) = log N(ε), a fundamental concept in approximation theory.

The key insight is that N(ε) = ⌈k^n / V(n, ε)⌉ for the Hamming metric (by a
simple volume argument), giving an exact formula rather than just bounds. This
bridges discrete combinatorics with continuous approximation theory.

Why now? The `hamming_ball_card_full` result (ball of radius n covers everything)
and the exact ball cardinality formula provide the two ingredients needed. This
would be a novel formalized bridge between coding theory and functional analysis.

**Concept description**: # Future Directions: The Library of Babel

## 1. Gilbert-Varshamov Bound and Asymptotic Rates

The sphere-packing bound gives an upper bound on code size, but the
Gilbert-Varshamov bound gives a *lower* bound: there exists a code of size
at least k^n / V(n, d-1) where V is the Hamming ball volume. Together with
our `hamming_ball_card` and `sphere_packing_bound`, formalizing the GV bound
would complete the classical coding theory trifecta.

The key insight is that the GV bound follows from a greedy argument: keep
adding codewords until no more can be added without violating the distance
constraint. The ball volumes we've computed are exactly what's needed.

Why now? We have sorry-free `hamming_ball_card` and `sphere_packing_bound`.
The GV bound is the natural next step and would be the first formalization
of this result in Lean 4 / Mathlib.

## 2. Plotkin Bound via Hamming Weight Double-Counting

When the minimum distance d exceeds n/2, the sphere-packing bound becomes
trivial. The Plotkin bound fills this gap: if d > n/2, then |C| ≤ 2d/(2d-n)
for binary codes. The proof uses a beautiful double-counting argument on the
total Hamming weight of all pairwise distances.

The key insight is that ∑_{c,c' ∈ C} d(c,c') can be computed both as a sum
over pairs and as a sum over coordinates, yielding the bound. This bridges
our Hamming metric formalization with linear algebra over F_2.

Why now? The `hammingDist_book` infrastructure and triangle inequality are
in place. The Plotkin bound requires only elementary double-counting, not
the algebraic machinery of polynomial codes.

## 3. Kolmogorov Complexity via Turing Machines

Our `incompressibility_counting` theorem is the counting core of Kolmogorov
complexity, but without Turing machines. Formalizing a minimal Turing machine
model and defining K(x) = min{|p| : U(p) = x} would connect our combinatorial
results to algorithmic information theory proper.

The key insight is that once K(x) is defined, our `fraction_compressible_bound`
immediately gives |{x : K(x) < |x| - d}| ≤ 2^(|x|-d), the "most strings are
random" theorem of Kolmogorov complexity.

Why now? Lean 4 has good support for recursive function definitions. A minimal
UTM formalization (even a string rewriting system) would suffice to state K(x).

## 4. Perfect Codes Classification

Our sphere-packing bound achieves equality for "perfect codes." The classification
theorem states that the only nontrivial perfect binary codes are the Hamming codes
(parameters [2^r - 1, 2^r - r - 1, 3]) and the binary Golay code [23, 12, 7].
Formalizing that Hamming codes achieve equality in `sphere_packing_bound` would
be a clean application of our ball cardinality formula.

The key insight is that for Hamming codes, k^n / V(n,t) is exactly an integer
(= 2^{n-r}), which is equivalent to the ball volumes partitioning the space.
This connects combinatorial coding theory to finite geometry (projective spaces
over F_2).

Why now? We have the exact ball cardinality formula. Verifying that 2^n = 2^{n-r} * V(n,1)
for n = 2^r - 1 is a concrete numerical identity that our framework can check.

## 5. Metric Entropy and Covering Numbers

The Hamming ball cardinality determines the ε-covering number N(ε) of the Library:
the minimum number of balls of radius ε needed to cover the space. This connects
to metric entropy H(ε) = log N(ε), a fundamental concept in approximation theory.

The key insight is that N(ε) = ⌈k^n / V(n, ε)⌉ for the Hamming metric (by a
simple volume argument), giving an exact formula rather than just bounds. This
bridges discrete combinatorics with continuous approximation theory.

Why now? The `hamming_ball_card_full` result (ball of radius n covers everything)
and the exact ball cardinality formula provide the two ingredients needed. This
would be a novel formalized bridge between coding theory and functional analysis.

**Novelty estimate**: 0.75
**Breakthrough potential**: 0.75
Research domain: Novelty
Research mode: team




### Recent Discoveries in Catalog
No previous research cycles completed yet. This is a cold start — prioritize sorry_fill on the priority targets (CarmichaelComposite, Fib_gcd_identity) to close known open problems, or target cross-domain bridge theorems for novelty.


## v6 Depth Requirements — Correct Proofs First

You are working on the frontier of mathematics. Your goal is to produce
Lean 4 code that COMPILES and PROVES non-trivial results. A correct proof
of one good theorem is worth more than 5 theorems with `sorry`.

### STEP 1: BRIEF PLAN (2-3 lines)

Before writing Lean code, state:
- **Strategy**: New structure (Grothendieck) OR extend existing result (Cauchy)
- **Theorems**: List the 2-4 theorems you will prove (one sentence each)
- **Why non-trivial**: One sentence explaining the key insight

### STEP 2: PROVE THEOREMS (correctness > completeness)

Write Lean 4 proofs that COMPILE. Every theorem should have:
- A complete proof (no `sorry` for the main result)
- A brief proof sketch as a comment (1-2 sentences)
- An `example` block showing the theorem in action (if practical)

For your BEST theorem, also provide:
- A generalization or strengthening (can use `sorry` if proving it would take too long)
- A boundary case or counterexample showing where the result fails

You do NOT need full PEGB on every theorem. Deep PEGB on your best theorem
and solid proofs on the rest is the target.

### STEP 3: Anti-patterns (avoid these)

These tactics indicate trivial proofs that add no value:
- `native_decide` / `decide` / `norm_num` / `rfl` — unless genuinely proving a numeric fact
- `simp only []` with no simp set specified
- `sorry` on the main theorem statement

`omega`, `linarith`, and `Aesop` are fine for supporting lemmas.
`sorry` is fine for generalizations and boundary cases.

### STEP 4: Novelty

Your theorems should be genuinely new. If a statement appears in a textbook,
generalize it. If you cannot formalize a concept rigorously, pick a different topic.

### Output format

Your output must include `.lean` files AND a `FUTURE_DIRECTIONS.md` file.
The .lean files contain the proofs. The FUTURE_DIRECTIONS.md contains 3-5
research conjectures that extend the work. Both are required.


## Output format reminder

Your output must include `.lean` files AND a `FUTURE_DIRECTIONS.md` file.
The .lean files contain the proofs. The FUTURE_DIRECTIONS.md contains 3-5
research conjectures that extend the work. Both are required.
Be precise, be deep, be world-class.
