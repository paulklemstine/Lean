
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


## Concept

**Title**: The Newton polygon of a differential polynomial P(y, y', ..., y^(k)) encodes whi
**Domain**: Computation
**Mathematical framing**: # Future Directions: Tropical Differential Algebra

## 1. Tropical Newton Polygon Characterization of ODE Solutions

The Newton polygon of a differential polynomial P(y, y', ..., y^(k)) encodes which terms can dominate at various growth rates. For a first-order ODE y' = P(x, y) where P is a polynomial, the slopes of the tropical Newton polygon should correspond exactly to the possible leading exponents of formal power series solutions.

**Conjecture**: If f is a formal power series solution to y' = P(x, y) in a valued field, then the tropical order of trop(f) equals one of the slopes of the Newton polygon of the tropicalization of P.

The key insight is that the tropical Leibniz rule (proved as `tropical_leibniz`) guarantees that differentiation interacts with the Newton polygon in a controlled way — the derivative shifts the polygon by exactly one unit, which constrains which slopes can arise.

**Why now?** The `tropical_leibniz` equality (not just inequality) is now formalized, which is the essential ingredient for showing that tropical solutions faithfully reflect classical ones. The `torder_tmul_le` theorem provides the order-additivity needed for Newton polygon slope arithmetic.

## 2. Tropical Differential Galois Theory

Classical differential Galois theory studies the symmetries of differential equations via the differential Galois group. In the tropical setting, automorphisms of the tropical differential field correspond to piecewise-linear maps that preserve the tropical derivative.

**Conjecture**: The tropical differential Galois group of a tropical linear ODE of order n is a polyhedral subgroup of GL(n, ℤ), and its combinatorial structure determines the possible factorization patterns of the original ODE over the valued field.

The key insight is that the `tropical_ode_superposition` theorem shows the solution space has a lattice structure (closed under min), and tropical automorphisms must preserve this lattice, forcing them to be piecewise-linear and hence polyhedral.

**Why now?** The superposition principle (`tropical_ode_superposition`) and the weighted derivative formalism (`tderiv_weighted_iterate`) provide the infrastructure to define tropical differential field extensions and their automorphism groups.

## 3. Effective Bounds from Tropical Differential Equations

The tropical order exactness theorem (`tderiv_order_exact`) shows that differentiation decreases tropical order by exactly 1. This should yield effective lower bounds on the growth rate of solutions to classical differential equations.

**Conjecture**: For a polynomial ODE of degree d and order k, if all tropical solutions have tropical order ≥ m, then every classical solution f in the valued field satisfies val(f) ≥ m, i.e., |f(x)| ≤ C·|x|^(-m) for some constant C near the origin.

The key insight is that the functor "tropicalization" is order-preserving (by `torder_tmul_le`), so bounds proved in the simpler tropical world automatically transfer to the classical world.

**Why now?** The formalized order theory (`tderiv_order_exact`, `torder_tmul_le`) provides the rigorous foundation for transferring tropical bounds to classical settings. The higher-order Leibniz rule (`tropical_leibniz_higher`) extends this to higher-order ODEs.

## 4. Tropical Differential Algebra over Non-Archimedean Fields

The current formalization uses trivial valuation on coefficient indices (so the tropical derivative is the shift operator). Extending to p-adic valuations via `tderiv_weighted` introduces arithmetic dependencies on the characteristic.

**Conjecture**: Over a p-adic field with valuation v_p, the tropical differential equation D_{v_p}(y) ⊕ (a ⊙ y) = b has a solution if and only if for every n, the "tropical discriminant" min(b(n), a(0) + b(n-1) + v_p(n)) is achieved by the b(n) term for all but finitely many n.

The key insight is that the weighted iterate formula (`tderiv_weighted_iterate`) shows the cumulative p-adic valuation ∑ v_p(k+i+1) grows like k·log(m)/log(p), creating a threshold effect: beyond a critical index, the derivative term always dominates.

**Why now?** The `tderiv_weighted_iterate` theorem provides the explicit formula for iterated weighted derivatives, making the threshold computation feasible. The p-adic case is particularly tractable because v_p has well-understood growth.

## 5. Tropical Differential Resultant and Elimination Theory

In algebraic geometry, the resultant eliminates a variable from a system of polynomial equations. The tropical resultant should similarly eliminate a "variable" (series component) from a system of tropical differential equations.

**Conjecture**: Given two tropical differential polynomials P(y, Dy) and Q(y, Dy) of tropical degrees d₁ and d₂, their tropical differential resultant R(Dy) has tropical degree ≤ d₁·d₂, and R(Dy) = 0 (tropically) if and only if P and Q have a common tropical solution.

The key insight is that the tropical Leibniz rule being an equality (not inequality) means the tropical resultant computation is exact — there are no cancellation artifacts that could introduce spurious solutions or miss genuine ones.

**Why now?** The commutativity (`tmul_comm`) and Leibniz equality (`tropical_leibniz`) together give the tropical polynomial ring a clean enough algebraic structure to define resultants. The order theory provides degree bounds.

**Concept description**: # Future Directions: Tropical Differential Algebra

## 1. Tropical Newton Polygon Characterization of ODE Solutions

The Newton polygon of a differential polynomial P(y, y', ..., y^(k)) encodes which terms can dominate at various growth rates. For a first-order ODE y' = P(x, y) where P is a polynomial, the slopes of the tropical Newton polygon should correspond exactly to the possible leading exponents of formal power series solutions.

**Conjecture**: If f is a formal power series solution to y' = P(x, y) in a valued field, then the tropical order of trop(f) equals one of the slopes of the Newton polygon of the tropicalization of P.

The key insight is that the tropical Leibniz rule (proved as `tropical_leibniz`) guarantees that differentiation interacts with the Newton polygon in a controlled way — the derivative shifts the polygon by exactly one unit, which constrains which slopes can arise.

**Why now?** The `tropical_leibniz` equality (not just inequality) is now formalized, which is the essential ingredient for showing that tropical solutions faithfully reflect classical ones. The `torder_tmul_le` theorem provides the order-additivity needed for Newton polygon slope arithmetic.

## 2. Tropical Differential Galois Theory

Classical differential Galois theory studies the symmetries of differential equations via the differential Galois group. In the tropical setting, automorphisms of the tropical differential field correspond to piecewise-linear maps that preserve the tropical derivative.

**Conjecture**: The tropical differential Galois group of a tropical linear ODE of order n is a polyhedral subgroup of GL(n, ℤ), and its combinatorial structure determines the possible factorization patterns of the original ODE over the valued field.

The key insight is that the `tropical_ode_superposition` theorem shows the solution space has a lattice structure (closed under min), and tropical automorphisms must preserve this lattice, forcing them to be piecewise-linear and hence polyhedral.

**Why now?** The superposition principle (`tropical_ode_superposition`) and the weighted derivative formalism (`tderiv_weighted_iterate`) provide the infrastructure to define tropical differential field extensions and their automorphism groups.

## 3. Effective Bounds from Tropical Differential Equations

The tropical order exactness theorem (`tderiv_order_exact`) shows that differentiation decreases tropical order by exactly 1. This should yield effective lower bounds on the growth rate of solutions to classical differential equations.

**Conjecture**: For a polynomial ODE of degree d and order k, if all tropical solutions have tropical order ≥ m, then every classical solution f in the valued field satisfies val(f) ≥ m, i.e., |f(x)| ≤ C·|x|^(-m) for some constant C near the origin.

The key insight is that the functor "tropicalization" is order-preserving (by `torder_tmul_le`), so bounds proved in the simpler tropical world automatically transfer to the classical world.

**Why now?** The formalized order theory (`tderiv_order_exact`, `torder_tmul_le`) provides the rigorous foundation for transferring tropical bounds to classical settings. The higher-order Leibniz rule (`tropical_leibniz_higher`) extends this to higher-order ODEs.

## 4. Tropical Differential Algebra over Non-Archimedean Fields

The current formalization uses trivial valuation on coefficient indices (so the tropical derivative is the shift operator). Extending to p-adic valuations via `tderiv_weighted` introduces arithmetic dependencies on the characteristic.

**Conjecture**: Over a p-adic field with valuation v_p, the tropical differential equation D_{v_p}(y) ⊕ (a ⊙ y) = b has a solution if and only if for every n, the "tropical discriminant" min(b(n), a(0) + b(n-1) + v_p(n)) is achieved by the b(n) term for all but finitely many n.

The key insight is that the weighted iterate formula (`tderiv_weighted_iterate`) shows the cumulative p-adic valuation ∑ v_p(k+i+1) grows like k·log(m)/log(p), creating a threshold effect: beyond a critical index, the derivative term always dominates.

**Why now?** The `tderiv_weighted_iterate` theorem provides the explicit formula for iterated weighted derivatives, making the threshold computation feasible. The p-adic case is particularly tractable because v_p has well-understood growth.

## 5. Tropical Differential Resultant and Elimination Theory

In algebraic geometry, the resultant eliminates a variable from a system of polynomial equations. The tropical resultant should similarly eliminate a "variable" (series component) from a system of tropical differential equations.

**Conjecture**: Given two tropical differential polynomials P(y, Dy) and Q(y, Dy) of tropical degrees d₁ and d₂, their tropical differential resultant R(Dy) has tropical degree ≤ d₁·d₂, and R(Dy) = 0 (tropically) if and only if P and Q have a common tropical solution.

The key insight is that the tropical Leibniz rule being an equality (not inequality) means the tropical resultant computation is exact — there are no cancellation artifacts that could introduce spurious solutions or miss genuine ones.

**Why now?** The commutativity (`tmul_comm`) and Leibniz equality (`tropical_leibniz`) together give the tropical polynomial ring a clean enough algebraic structure to define resultants. The order theory provides degree bounds.

**Novelty estimate**: 0.75
**Breakthrough potential**: 0.75
Research domain: Computation
Research mode: team




### Recent Discoveries in Catalog
No previous research cycles completed yet. This is a cold start — prioritize sorry_fill on the priority targets (CarmichaelComposite, Fib_gcd_identity) to close known open problems, or target cross-domain bridge theorems for novelty.


## v8 Depth Requirements -- Research Team Protocol

You are leading a research team. Your team has different roles:
- The **Hypothesizer** generates bold, falsifiable conjectures
- The **Experimenter** proves or disproves them in Lean 4
- The **Analyst** examines what survived, what failed, and WHY
- The **Critic** searches for weaknesses, constructs counterexamples,
  and identifies where proofs might break down. A well-constructed
  counterexample is as valuable as a proof.
- The **Synthesist** upgrades the knowledge base and writes the
  FUTURE_DIRECTIONS.md that seeds the next cycle

You run this loop: **Hypothesize -> Experiment -> Analyze -> Critique -> Generalize -> Iterate**.
Each cycle is not a one-shot task. It is one iteration of an infinite
research process. Your notes (FUTURE_DIRECTIONS.md, Lab Notebooks,
proof sketches) determine whether the next team builds on your work
or starts over.

**Take good notes.** A cycle without useful notes is a wasted cycle.

### STEP 1: THEOREM DECLARATIONS (required -- before any code)

List every theorem you intend to prove or investigate. For each, state:
- **Name**: The Lean declaration name
- **Statement**: One-sentence informal statement
- **Status**: `hypothesis` | `conjecture` | `proved` | `proved_with_lemma_sorry` | `disproved`
- **Why it matters**: One sentence on what this result would mean if true,
  and what it would teach us if false

Example:
1. `cantorPairing_surjective`: Cantor pairing is surjective -- proved -- constructive inverse -- confirms decidability of Nat x Nat
2. `cantorPairing_injective`: Cantor pairing is injective -- proved -- diagonal argument -- confirms invertibility
3. `cantorPairing_bijection`: Cantor pairing is a bijection -- proved_with_lemma_sorry -- follows from 1+2 -- completing the characterization

Use `hypothesis` for statements you are not yet sure you can prove but
want to investigate. Use `conjecture` for statements you believe are true
but cannot prove in this cycle. Use `disproved` for statements where you
found a counterexample. Use `proved` for statements with complete Lean
proofs. Use `proved_with_lemma_sorry` when the main proof is complete but
one or more supporting lemmas use `sorry`.

### STEP 2: EXPERIMENT (prove or disprove in Lean 4)

Every theorem declared as `proved` MUST have a complete, compiling Lean proof.
No `sorry` on the main result. If you cannot complete a proof, change its
status to `conjecture` or `proved_with_lemma_sorry` and explain why.

For `proved_with_lemma_sorry`:
- The theorem statement must be complete (no sorry in the statement)
- `sorry` is allowed ONLY in supporting lemmas, never the main proof
- A comment must explain what the sorry replaces and why it is deferred

**Disproofs count.** If a hypothesis is false, prove its negation or
construct an explicit counterexample. A well-constructed counterexample
is as valuable as a proof. Change the status to `disproved` and state
the counterexample clearly.

### STEP 3: CRITIQUE (find the weaknesses)

For your best theorem, the Critic must:
- Identify the strongest assumption that could be weakened
- Construct a boundary case: where does the result break down?
- If possible, state a `conjecture` for the generalized version and
  explain what would need to change in the proof

This is NOT optional. A theorem without a critique is incomplete.

### STEP 4: Anti-patterns (reject these)

These tactics indicate trivial proofs:
- `native_decide` / `decide` / `norm_num` / `rfl` -- unless genuinely proving a numeric fact
- `simp only []` with no simp set specified
- `sorry` on any theorem declared as `proved`

`omega`, `linarith`, and `Aesop` are fine for supporting lemmas.
`sorry` is fine for conjectures, generalizations, and boundary cases.

### STEP 5: Novelty

Your theorems must be genuinely new. If a statement appears in a textbook,
generalize it. If you cannot formalize a concept rigorously, pick a different topic.

### STEP 6: TAKE GOOD NOTES (first-class deliverables)

Your notes determine what the next research team investigates. They are NOT
an afterthought. They are your most important output after the proofs themselves.

**6a. Lab Notebook** (in each .lean file, as `-- !-- Lab Notebook -- !--` blocks):

For each major theorem, include a Lab Notebook comment block:
```lean
-- !-- Lab Notebook: cantorPairing_bijection -- !--
-- !-- Hypothesis: Cantor pairing is bijective because both surjective and injective -- !--
-- !-- Result: Proved via composition of surjective and injective proofs -- !--
-- !-- Insight: The constructive inverse of surjectivity is key; diagonal argument handles injectivity -- !--
-- !-- Failure analysis: Initial attempt to prove bijection directly failed; decomposition into surjective+injective was necessary -- !--
-- !-- End Lab Notebook -- !--
```

**6b. FUTURE_DIRECTIONS.md** (structured, not freeform):

Required structure:

## Synthesis
[2-3 paragraphs: what did this cycle discover? What failed and why? What
structural insight emerged? Tie the directions together into a narrative.]

## Results Summary
[For each theorem: name, status (proved/conjecture/disproved), one-sentence
significance. This is the lab notebook summary -- be precise.]

## Research Directions

### Direction 1: [Concise title]
**Hypothesis**: A precise, falsifiable mathematical statement.
**Test**: What experiment (proof/disproof/computation) would confirm or refute it.
**Why now**: What from THIS cycle makes this tractable.
**If true**: What new territory this opens.
**If false**: What the failure teaches us.

[Repeat for 3-5 directions]

### STEP 7: Generalization loop

For your BEST theorem, attempt one level of generalization:
- State a stronger version (can use sorry if proving would take too long)
- Identify the boundary: where does the result break down?
- If the generalization is itself interesting, mark it as a `conjecture`
  in your theorem declarations and explain it in FUTURE_DIRECTIONS.md

### Output format

Your output must include:
1. `.lean` files with proofs and Lab Notebook blocks (structured as declared in Step 1)
2. `FUTURE_DIRECTIONS.md` with Synthesis, Results Summary, and 3-5 research
   directions (structured as in Step 6b)

Both are required. A cycle with proofs but no Lab Notebook or
FUTURE_DIRECTIONS.md is a cycle where the next team starts from scratch.
Take good notes.


## Output format reminder

Your output must include `.lean` files AND a `FUTURE_DIRECTIONS.md` file.
The .lean files contain the proofs. The FUTURE_DIRECTIONS.md contains 3-5
research conjectures that extend the work. Both are required.
Be precise, be deep, be world-class.
