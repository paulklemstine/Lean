
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

**Title**: The Baker-Norine theorem states that for a divisor D on a graph G of genus g,
**Domain**: Novelty
**Mathematical framing**: # Future Directions: Tropical Brill-Noether Theory

## 1. Baker-Norine Riemann-Roch for Graphs

The Baker-Norine theorem states that for a divisor D on a graph G of genus g,
rank(D) - rank(K_G - D) = deg(D) - g + 1, where K_G is the canonical divisor.
Our chip-firing infrastructure (Laplacian sum-zero, degree invariance, linear
equivalence as equivalence relation) provides exactly the foundation needed.

The key insight is that the Laplacian kernel characterizes chip-firing equivalence
classes, and the degree invariance theorem we proved ensures the rank function
is well-defined on equivalence classes. Why now? We have all the algebraic
infrastructure for graph divisors formalized — what remains is the combinatorial
argument using q-reduced divisors (Dhar's burning algorithm) to establish the
existence and uniqueness of reduced representatives.

## 2. Full CDPR Theorem with Metric Structure

The Cools-Draisma-Payne-Robeva theorem in Core.lean currently proves the
combinatorial equivalence between CDPR allocations and ρ ≥ 0. The full
theorem requires showing that on a *generic* metric chain of loops, the
rank of the constructed divisor equals exactly r.

The key insight is that the genericity condition (distinct edge-length ratios,
formalized in Defs.lean as `MetricChainOfLoops.IsGeneric`) prevents accidental
rank jumps, ensuring the allocation-based construction achieves rank exactly r
and no more. Why now? The metric chain of loops structure and genericity
condition are already formalized in Defs.lean; what's needed is the tropical
linear series computation on metric graphs using the break divisor theory.

## 3. Specialization Inequality and Lifting

Baker's specialization lemma (abstracted in Defs.lean as `SpecializationDatum`)
states that rank does not decrease under tropicalization. The converse — the
lifting problem — asks when tropical divisors lift to algebraic ones with the
same rank. This would close the loop between tropical and classical
Brill-Noether theory.

The key insight is that the Serre duality we proved (ρ(g,r,d) = ρ(g,g-1-d+r,2g-2-d))
constrains which tropical divisors can possibly lift, since the duality must be
preserved by any faithful specialization. Why now? The abstract specialization
interface provides a clean framework for stating lifting conditions, and the
duality theorem gives computable necessary conditions for liftability.

## 4. Tropical Moduli Space Dimension

The Brill-Noether number ρ should equal the dimension of the tropical moduli
space W^r_d(Γ) for a general tropical curve Γ. Our strict monotonicity result
and boundary behavior (ρ < 0 for large genus) constrain when this space is
empty.

The key insight is that the monotonicity theorem (ρ is strictly increasing in d)
means the transition from empty to nonempty W^r_d happens at a single critical
degree, making the dimension theory particularly clean in the tropical setting.
Why now? The algebraic properties proven in Duality.lean give complete control
over the sign of ρ, which is the key input for tropical intersection theory
computations on the moduli space.

## 5. Chip-Firing Groups and Jacobians

The graph Laplacian we formalized defines a group homomorphism from
(V → ℤ) to GraphDivisor V. The cokernel of this map restricted to
degree-zero divisors is the Jacobian (or sandpile group) of the graph,
whose order equals the number of spanning trees by the matrix-tree theorem.

The key insight is that our Laplacian additivity theorem (graphLaplacian_add)
and the linear equivalence transitivity directly give the group structure
on divisor classes, and the Laplacian sum-zero property ensures the degree-zero
condition is well-defined on classes. Why now? The equivalence relation
(reflexivity, symmetry, transitivity all proved) means we can immediately
quotient to get the Jacobian as a type, and the matrix-tree theorem connection
would give a concrete computation of its cardinality.

**Concept description**: # Future Directions: Tropical Brill-Noether Theory

## 1. Baker-Norine Riemann-Roch for Graphs

The Baker-Norine theorem states that for a divisor D on a graph G of genus g,
rank(D) - rank(K_G - D) = deg(D) - g + 1, where K_G is the canonical divisor.
Our chip-firing infrastructure (Laplacian sum-zero, degree invariance, linear
equivalence as equivalence relation) provides exactly the foundation needed.

The key insight is that the Laplacian kernel characterizes chip-firing equivalence
classes, and the degree invariance theorem we proved ensures the rank function
is well-defined on equivalence classes. Why now? We have all the algebraic
infrastructure for graph divisors formalized — what remains is the combinatorial
argument using q-reduced divisors (Dhar's burning algorithm) to establish the
existence and uniqueness of reduced representatives.

## 2. Full CDPR Theorem with Metric Structure

The Cools-Draisma-Payne-Robeva theorem in Core.lean currently proves the
combinatorial equivalence between CDPR allocations and ρ ≥ 0. The full
theorem requires showing that on a *generic* metric chain of loops, the
rank of the constructed divisor equals exactly r.

The key insight is that the genericity condition (distinct edge-length ratios,
formalized in Defs.lean as `MetricChainOfLoops.IsGeneric`) prevents accidental
rank jumps, ensuring the allocation-based construction achieves rank exactly r
and no more. Why now? The metric chain of loops structure and genericity
condition are already formalized in Defs.lean; what's needed is the tropical
linear series computation on metric graphs using the break divisor theory.

## 3. Specialization Inequality and Lifting

Baker's specialization lemma (abstracted in Defs.lean as `SpecializationDatum`)
states that rank does not decrease under tropicalization. The converse — the
lifting problem — asks when tropical divisors lift to algebraic ones with the
same rank. This would close the loop between tropical and classical
Brill-Noether theory.

The key insight is that the Serre duality we proved (ρ(g,r,d) = ρ(g,g-1-d+r,2g-2-d))
constrains which tropical divisors can possibly lift, since the duality must be
preserved by any faithful specialization. Why now? The abstract specialization
interface provides a clean framework for stating lifting conditions, and the
duality theorem gives computable necessary conditions for liftability.

## 4. Tropical Moduli Space Dimension

The Brill-Noether number ρ should equal the dimension of the tropical moduli
space W^r_d(Γ) for a general tropical curve Γ. Our strict monotonicity result
and boundary behavior (ρ < 0 for large genus) constrain when this space is
empty.

The key insight is that the monotonicity theorem (ρ is strictly increasing in d)
means the transition from empty to nonempty W^r_d happens at a single critical
degree, making the dimension theory particularly clean in the tropical setting.
Why now? The algebraic properties proven in Duality.lean give complete control
over the sign of ρ, which is the key input for tropical intersection theory
computations on the moduli space.

## 5. Chip-Firing Groups and Jacobians

The graph Laplacian we formalized defines a group homomorphism from
(V → ℤ) to GraphDivisor V. The cokernel of this map restricted to
degree-zero divisors is the Jacobian (or sandpile group) of the graph,
whose order equals the number of spanning trees by the matrix-tree theorem.

The key insight is that our Laplacian additivity theorem (graphLaplacian_add)
and the linear equivalence transitivity directly give the group structure
on divisor classes, and the Laplacian sum-zero property ensures the degree-zero
condition is well-defined on classes. Why now? The equivalence relation
(reflexivity, symmetry, transitivity all proved) means we can immediately
quotient to get the Jacobian as a type, and the matrix-tree theorem connection
would give a concrete computation of its cardinality.

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
