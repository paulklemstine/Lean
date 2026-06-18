
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

**Title**: Formal obstruction theory for EML-solvability of linear
**Domain**: Bridges
**Mathematical framing**: # Future Directions: EML Differential Equations

## Synthesis

This cycle established a formal obstruction theory for EML-solvability of linear ODEs, centered on Airy's equation y″ = xy as the prototypical barrier. We proved four independent obstruction arguments (polynomial degree, Riccati degree parity, Wronskian conservation/SL₂ invariance, and growth rate analysis) and developed foundational infrastructure including ODE uniqueness for second-order equations with continuous coefficients.

The most promising cross-domain connection is between the **differential Galois group** formalized here and the **algebraic Galois theory** already present in the Catalog (`Bridges/GaloisNeuralCorrespondence.lean`, `Algebra/ProofSpectra/Core.lean`). Both theories share the same core mechanism — group-theoretic obstructions to solvability — but operate in different categories (differential fields vs. number fields). Bridging these formally would unify a substantial portion of modern algebra.

The cycle's Wronskian theory and ODE uniqueness results are independently valuable and reusable. The growth rate classification (`EMLGrowthClass`) provides a framework for distinguishing solution types that could be applied to broad classes of ODEs beyond Airy.

---

### Direction 1: Formal Stokes Phenomenon for Airy's Equation

**Conjecture**: The asymptotic expansion of Ai(x) as x → +∞ (along the positive real axis) and as x → −∞ involve different linear combinations of formal WKB solutions, and the transition matrices between these asymptotic regimes are elements of the Stokes group, which is a unipotent subgroup of SL₂(ℂ). Formally: the monodromy representation of Airy's equation factors through the wild fundamental group, and the Stokes multipliers can be computed exactly as specific constants involving Γ(1/3) and Γ(2/3).

**Test**: Compute Stokes multipliers numerically by integrating Airy's equation along paths crossing Stokes lines (at angles 0, 2π/3, 4π/3) and verify they match the predicted values. Formally, prove that the connection matrix between the sectors arg(x) ∈ (−π/3, π/3) and arg(x) ∈ (π/3, π) has the form [[1, s], [0, 1]] for a specific constant s.

**Impact**: This would be the first formalization of the Stokes phenomenon in any proof assistant. The Stokes phenomenon is fundamental to asymptotic analysis, quantum mechanics (WKB approximation), and resurgence theory. A formal treatment would open the door to verified asymptotics.

**Catalog References**: `EML/EMLDiffEq.lean` (Wronskian theory, Abel's identity), `EML/EMLDiffGalois.lean` (SL₂ Galois invariance)

**Proof Strategy**: (1) Define formal WKB solutions as asymptotic series. (2) Prove existence of actual solutions with prescribed asymptotics in each sector using Borel summation. (3) Compute the connection matrices between sectors. (4) Show these matrices are unipotent elements of SL₂.

**Domain Bridges**: Differential Galois Theory ↔ Asymptotic Analysis ↔ Quantum Mechanics

**Lineage**: Builds on this cycle's Wronskian conservation and SL₂ invariance results.

**Ambition**: grand_challenge

---

### Direction 2: Kovacic Algorithm — Full Decidability Proof

**Conjecture**: Kovacic's algorithm, when formalized as a decision procedure on rational functions r(x) = P(x)/Q(x) with integer coefficients, terminates in time polynomial in the total degree of P and Q, and correctly decides Liouvillian solvability of y″ = r(x)y.

**Test**: Implement the full three-case algorithm in Lean 4 with a verified termination proof. Test on a battery of equations: (a) y″ = x²y (Liouvillian: y = exp(x³/3)), (b) y″ = xy (not Liouvillian: Airy), (c) y″ = (1/x²)y (Euler equation: Liouvillian), (d) y″ = (x²+1)y (Parabolic cylinder: Liouvillian via Hermite functions?). Verify each decision against known results.

**Impact**: A formally verified Kovacic algorithm would be the first certified decision procedure for Liouvillian solvability. This has applications in computer algebra systems (Maple, Mathematica) where Kovacic's algorithm is implemented but not verified.

**Catalog References**: `EML/EMLDiffGalois.lean` (Riccati obstruction, polynomial derivative algebra), `EML/EMLDiffEq.lean` (no_polynomial_solves_airy)

**Proof Strategy**: (1) Formalize rational functions as a computable type. (2) Implement pole order analysis. (3) Formalize the three cases as finite searches over candidate exponents. (4) Prove termination by bounding the search space. (5) Prove soundness by showing each case correctly identifies solutions.

**Domain Bridges**: Computer Algebra ↔ Differential Galois Theory ↔ Computation

**Lineage**: Builds on this cycle's no_polynomial_solves_riccati and kovacic_case1_airy_obstruction.

**Ambition**: grand_challenge

---

### Direction 3: EML Growth Hierarchy — Fractional Exponential Orders

**Conjecture**: Define the *exponential order* of a function f at infinity as ord(f) = inf{α > 0 : f(x) = O(exp(x^α))}. Then: (a) Every EML function has rational exponential order. (b) The Airy function Bi has exponential order exactly 3/2, which is rational but cannot be realized by any EML function. (c) More generally, the exponential orders realizable by solutions of y″ = r(x)y with polynomial r of degree d are exactly {(d+2)/2}, and (d+2)/2 is realizable by an EML function iff d is even.

**Test**: Verify conjecture (c) computationally for d = 0,1,2,...,10 by computing the WKB exponent ∫√r(x)dx and checking its degree. Formally, prove (a) by structural induction on EML expressions and (b) by the growth rate analysis from this cycle.

**Impact**: This would establish a precise numerical invariant distinguishing EML-solvable from EML-unsolvable equations, providing an effective criterion independent of the full Galois group computation.

**Catalog References**: `EML/EMLDiffGalois.lean` (EMLGrowthClass, exp_not_polynomial_growth), `EML/EMLDiffEq.lean` (exp_dominates_polynomial, airy_not_tendsto_zero)

**Proof Strategy**: (1) Define exponential order formally. (2) Prove the WKB approximation: solutions of y″ = r(x)y have exponential order equal to the degree of ∫√r(x)dx. (3) Classify which exponential orders arise from EML expressions. (4) Show the parity obstruction: odd-degree r gives half-integer exponential order, incompatible with EML.

**Domain Bridges**: Asymptotic Analysis ↔ EML Theory ↔ Complex Analysis

**Lineage**: Builds on this cycle's growth rate analysis and polynomial degree obstruction.

**Ambition**: extension

---

### Direction 4: Differential Galois–Algebraic Galois Bridge

**Conjecture**: There exists a formal functor from the category of Picard-Vessiot extensions of ℂ(x) to the category of algebraic groups over ℂ, such that: (a) the image of this functor restricted to constant coefficient equations y^(n) + aₙ₋₁y^(n-1) + ... + a₀y = 0 recovers the classical Galois group of the splitting field of the characteristic polynomial t^n + aₙ₋₁t^(n-1) + ... + a₀; (b) for Fuchsian equations (regular singular points only), the differential Galois group is the Zariski closure of the monodromy group.

**Test**: Verify (a) for specific examples: the equation y″ + y = 0 (Galois group {±1} ≅ ℤ/2, matching the algebraic Galois group of t² + 1 over ℝ). Verify (b) for the Gauss hypergeometric equation with specific parameters where the monodromy group is known.

**Impact**: This would be the first formal bridge between algebraic and differential Galois theory, connecting two of the most powerful obstruction theories in mathematics. It would enable transfer of results from the well-developed algebraic theory to the less-developed differential setting.

**Catalog References**: `Bridges/GaloisNeuralCorrespondence.lean` (prime_degree_divides_galois_order), `Algebra/ProofSpectra/Core.lean` (galois_connection_theory_variety), `EML/EMLDiffGalois.lean` (galois_preserves_wronskian)

**Proof Strategy**: (1) Formalize Picard-Vessiot extensions as differential field extensions with no new constants. (2) Define the differential Galois group as the automorphism group of the extension. (3) For constant-coefficient equations, show the exponential solutions generate a splitting field isomorphic to the algebraic splitting field. (4) For Fuchsian equations, relate analytic continuation to monodromy.

**Domain Bridges**: Algebraic Galois Theory ↔ Differential Galois Theory ↔ Topology (Monodromy)

**Lineage**: Builds on this cycle's SL₂ invariance and Wronskian theory, connecting to the algebraic Galois results in the Catalog.

**Ambition**: grand_challenge

---

### Direction 5: Nonlinear EML ODEs — Painlevé Transcendents

**Conjecture**: The first Painlevé equation y″ = 6y² + x has no EML solutions, and its "nonlinear differential Galois group" (in the sense of Malgrange) is the full symplectomorphism group of the phase space, which is infinite-dimensional.

**Test**: (a) Verify the polynomial obstruction: if y is a polynomial of degree d, then d − 2 = 2d + 1 (from y″ vs 6y² + x), giving d = −3, impossible. (b) Numerically integrate Painlevé I and verify that solutions develop arrays of double poles (the Painlevé property) with specific pole patterns. (c) Check that the pole locations are not expressible as EML functions of the initial conditions.

**Impact**: Painlevé transcendents are the next level of "new transcendental functions" beyond Airy. They arise in random matrix theory, quantum gravity, and integrable systems. A formal obstruction theory would extend our results from linear to nonlinear ODEs.

**Catalog References**: `EML/EMLDiffEq.lean` (no_polynomial_solves_airy — analogous degree argument), `EML/EMLDiffGalois.lean` (no_polynomial_solves_riccati — analogous nonlinear obstruction)

**Proof Strategy**: (1) Prove the polynomial obstruction (straightforward degree argument). (2) Formalize the Painlevé property (movable poles are at worst double). (3) Show the pole distribution contradicts EML structure. (4) Connect to Malgrange's nonlinear differential Galois theory.

**Domain Bridges**: Nonlinear ODEs ↔ Random Matrix Theory ↔ EML Theory

**Lineage**: Extends this cycle's linear obstruction theory to the nonlinear setting.

**Ambition**: extension

**Concept description**: # Future Directions: EML Differential Equations

## Synthesis

This cycle established a formal obstruction theory for EML-solvability of linear ODEs, centered on Airy's equation y″ = xy as the prototypical barrier. We proved four independent obstruction arguments (polynomial degree, Riccati degree parity, Wronskian conservation/SL₂ invariance, and growth rate analysis) and developed foundational infrastructure including ODE uniqueness for second-order equations with continuous coefficients.

The most promising cross-domain connection is between the **differential Galois group** formalized here and the **algebraic Galois theory** already present in the Catalog (`Bridges/GaloisNeuralCorrespondence.lean`, `Algebra/ProofSpectra/Core.lean`). Both theories share the same core mechanism — group-theoretic obstructions to solvability — but operate in different categories (differential fields vs. number fields). Bridging these formally would unify a substantial portion of modern algebra.

The cycle's Wronskian theory and ODE uniqueness results are independently valuable and reusable. The growth rate classification (`EMLGrowthClass`) provides a framework for distinguishing solution types that could be applied to broad classes of ODEs beyond Airy.

---

### Direction 1: Formal Stokes Phenomenon for Airy's Equation

**Conjecture**: The asymptotic expansion of Ai(x) as x → +∞ (along the positive real axis) and as x → −∞ involve different linear combinations of formal WKB solutions, and the transition matrices between these asymptotic regimes are elements of the Stokes group, which is a unipotent subgroup of SL₂(ℂ). Formally: the monodromy representation of Airy's equation factors through the wild fundamental group, and the Stokes multipliers can be computed exactly as specific constants involving Γ(1/3) and Γ(2/3).

**Test**: Compute Stokes multipliers numerically by integrating Airy's equation along paths crossing Stokes lines (at angles 0, 2π/3, 4π/3) and verify they match the predicted values. Formally, prove that the connection matrix between the sectors arg(x) ∈ (−π/3, π/3) and arg(x) ∈ (π/3, π) has the form [[1, s], [0, 1]] for a specific constant s.

**Impact**: This would be the first formalization of the Stokes phenomenon in any proof assistant. The Stokes phenomenon is fundamental to asymptotic analysis, quantum mechanics (WKB approximation), and resurgence theory. A formal treatment would open the door to verified asymptotics.

**Catalog References**: `EML/EMLDiffEq.lean` (Wronskian theory, Abel's identity), `EML/EMLDiffGalois.lean` (SL₂ Galois invariance)

**Proof Strategy**: (1) Define formal WKB solutions as asymptotic series. (2) Prove existence of actual solutions with prescribed asymptotics in each sector using Borel summation. (3) Compute the connection matrices between sectors. (4) Show these matrices are unipotent elements of SL₂.

**Domain Bridges**: Differential Galois Theory ↔ Asymptotic Analysis ↔ Quantum Mechanics

**Lineage**: Builds on this cycle's Wronskian conservation and SL₂ invariance results.

**Ambition**: grand_challenge

---

### Direction 2: Kovacic Algorithm — Full Decidability Proof

**Conjecture**: Kovacic's algorithm, when formalized as a decision procedure on rational functions r(x) = P(x)/Q(x) with integer coefficients, terminates in time polynomial in the total degree of P and Q, and correctly decides Liouvillian solvability of y″ = r(x)y.

**Test**: Implement the full three-case algorithm in Lean 4 with a verified termination proof. Test on a battery of equations: (a) y″ = x²y (Liouvillian: y = exp(x³/3)), (b) y″ = xy (not Liouvillian: Airy), (c) y″ = (1/x²)y (Euler equation: Liouvillian), (d) y″ = (x²+1)y (Parabolic cylinder: Liouvillian via Hermite functions?). Verify each decision against known results.

**Impact**: A formally verified Kovacic algorithm would be the first certified decision procedure for Liouvillian solvability. This has applications in computer algebra systems (Maple, Mathematica) where Kovacic's algorithm is implemented but not verified.

**Catalog References**: `EML/EMLDiffGalois.lean` (Riccati obstruction, polynomial derivative algebra), `EML/EMLDiffEq.lean` (no_polynomial_solves_airy)

**Proof Strategy**: (1) Formalize rational functions as a computable type. (2) Implement pole order analysis. (3) Formalize the three cases as finite searches over candidate exponents. (4) Prove termination by bounding the search space. (5) Prove soundness by showing each case correctly identifies solutions.

**Domain Bridges**: Computer Algebra ↔ Differential Galois Theory ↔ Computation

**Lineage**: Builds on this cycle's no_polynomial_solves_riccati and kovacic_case1_airy_obstruction.

**Ambition**: grand_challenge

---

### Direction 3: EML Growth Hierarchy — Fractional Exponential Orders

**Conjecture**: Define the *exponential order* of a function f at infinity as ord(f) = inf{α > 0 : f(x) = O(exp(x^α))}. Then: (a) Every EML function has rational exponential order. (b) The Airy function Bi has exponential order exactly 3/2, which is rational but cannot be realized by any EML function. (c) More generally, the exponential orders realizable by solutions of y″ = r(x)y with polynomial r of degree d are exactly {(d+2)/2}, and (d+2)/2 is realizable by an EML function iff d is even.

**Test**: Verify conjecture (c) computationally for d = 0,1,2,...,10 by computing the WKB exponent ∫√r(x)dx and checking its degree. Formally, prove (a) by structural induction on EML expressions and (b) by the growth rate analysis from this cycle.

**Impact**: This would establish a precise numerical invariant distinguishing EML-solvable from EML-unsolvable equations, providing an effective criterion independent of the full Galois group computation.

**Catalog References**: `EML/EMLDiffGalois.lean` (EMLGrowthClass, exp_not_polynomial_growth), `EML/EMLDiffEq.lean` (exp_dominates_polynomial, airy_not_tendsto_zero)

**Proof Strategy**: (1) Define exponential order formally. (2) Prove the WKB approximation: solutions of y″ = r(x)y have exponential order equal to the degree of ∫√r(x)dx. (3) Classify which exponential orders arise from EML expressions. (4) Show the parity obstruction: odd-degree r gives half-integer exponential order, incompatible with EML.

**Domain Bridges**: Asymptotic Analysis ↔ EML Theory ↔ Complex Analysis

**Lineage**: Builds on this cycle's growth rate analysis and polynomial degree obstruction.

**Ambition**: extension

---

### Direction 4: Differential Galois–Algebraic Galois Bridge

**Conjecture**: There exists a formal functor from the category of Picard-Vessiot extensions of ℂ(x) to the category of algebraic groups over ℂ, such that: (a) the image of this functor restricted to constant coefficient equations y^(n) + aₙ₋₁y^(n-1) + ... + a₀y = 0 recovers the classical Galois group of the splitting field of the characteristic polynomial t^n + aₙ₋₁t^(n-1) + ... + a₀; (b) for Fuchsian equations (regular singular points only), the differential Galois group is the Zariski closure of the monodromy group.

**Test**: Verify (a) for specific examples: the equation y″ + y = 0 (Galois group {±1} ≅ ℤ/2, matching the algebraic Galois group of t² + 1 over ℝ). Verify (b) for the Gauss hypergeometric equation with specific parameters where the monodromy group is known.

**Impact**: This would be the first formal bridge between algebraic and differential Galois theory, connecting two of the most powerful obstruction theories in mathematics. It would enable transfer of results from the well-developed algebraic theory to the less-developed differential setting.

**Catalog References**: `Bridges/GaloisNeuralCorrespondence.lean` (prime_degree_divides_galois_order), `Algebra/ProofSpectra/Core.lean` (galois_connection_theory_variety), `EML/EMLDiffGalois.lean` (galois_preserves_wronskian)

**Proof Strategy**: (1) Formalize Picard-Vessiot extensions as differential field extensions with no new constants. (2) Define the differential Galois group as the automorphism group of the extension. (3) For constant-coefficient equations, show the exponential solutions generate a splitting field isomorphic to the algebraic splitting field. (4) For Fuchsian equations, relate analytic continuation to monodromy.

**Domain Bridges**: Algebraic Galois Theory ↔ Differential Galois Theory ↔ Topology (Monodromy)

**Lineage**: Builds on this cycle's SL₂ invariance and Wronskian theory, connecting to the algebraic Galois results in the Catalog.

**Ambition**: grand_challenge

---

### Direction 5: Nonlinear EML ODEs — Painlevé Transcendents

**Conjecture**: The first Painlevé equation y″ = 6y² + x has no EML solutions, and its "nonlinear differential Galois group" (in the sense of Malgrange) is the full symplectomorphism group of the phase space, which is infinite-dimensional.

**Test**: (a) Verify the polynomial obstruction: if y is a polynomial of degree d, then d − 2 = 2d + 1 (from y″ vs 6y² + x), giving d = −3, impossible. (b) Numerically integrate Painlevé I and verify that solutions develop arrays of double poles (the Painlevé property) with specific pole patterns. (c) Check that the pole locations are not expressible as EML functions of the initial conditions.

**Impact**: Painlevé transcendents are the next level of "new transcendental functions" beyond Airy. They arise in random matrix theory, quantum gravity, and integrable systems. A formal obstruction theory would extend our results from linear to nonlinear ODEs.

**Catalog References**: `EML/EMLDiffEq.lean` (no_polynomial_solves_airy — analogous degree argument), `EML/EMLDiffGalois.lean` (no_polynomial_solves_riccati — analogous nonlinear obstruction)

**Proof Strategy**: (1) Prove the polynomial obstruction (straightforward degree argument). (2) Formalize the Painlevé property (movable poles are at worst double). (3) Show the pole distribution contradicts EML structure. (4) Connect to Malgrange's nonlinear differential Galois theory.

**Domain Bridges**: Nonlinear ODEs ↔ Random Matrix Theory ↔ EML Theory

**Lineage**: Extends this cycle's linear obstruction theory to the nonlinear setting.

**Ambition**: extension

**Novelty estimate**: 0.75
**Breakthrough potential**: 0.75
Research domain: Bridges
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
