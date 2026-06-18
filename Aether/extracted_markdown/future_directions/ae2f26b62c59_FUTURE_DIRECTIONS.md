# Future Research Directions: EML Differential Equations

## Synthesis

This research cycle established the first formal connection between the Kovacic algorithm for second-order linear ODEs and the EML function hierarchy. The key insight is that the polynomial degree obstruction — a simple parity argument — provides a computationally checkable criterion for ruling out polynomial Riccati solutions, which constitutes Case 1 of Kovacic's algorithm. Combined with the Riccati reduction theorem (transforming y'' = r·y into ω' + ω² = r) and Abel's identity for Wronskians, we have formalized the algebraic backbone of differential Galois theory for second-order ODEs.

The most promising cross-domain connection emerging from this cycle is the bridge between **polynomial algebra** (degree obstructions, leading coefficient analysis) and **differential analysis** (HasDerivAt, Wronskians, ODE solutions). The degree obstruction theorem `no_poly_riccati_odd_degree` works over any characteristic-zero integral domain, suggesting that the Kovacic criterion has a purely algebraic core that can be separated from the analytic aspects. This algebraic core connects naturally to the existing Galois obstruction theory in the Catalog (`prime_degree_divides_galois_order`), and to the EML function hierarchy (`eml_beats_poly_for_towers`).

The highest breakthrough potential lies in Direction 1 (Complete Kovacic Formalization), as it would constitute the first machine-verified decision procedure for Liouvillian solvability — a problem of fundamental importance to both symbolic computation and mathematical physics.

---

### Direction 1: Complete Formalization of the Kovacic Algorithm

**Conjecture**: The full Kovacic algorithm (all three cases) can be formalized in Lean 4 using Mathlib's polynomial and algebraic number theory infrastructure, yielding a verified decision procedure for Liouvillian solvability of y'' = r(x)y with r ∈ ℚ(x).

**Test**: Formalize Case 2 (checking if ω = a + b√r with a,b rational satisfies the Riccati equation) and verify it against known examples: y'' = x²y (has Liouvillian solutions) vs y'' = xy (no Liouvillian solutions). The key test is whether the algebraic machinery for working with ℚ(x)[√r] is available in Mathlib.

**Impact**: If successful, this would be the first verified implementation of a non-trivial computer algebra algorithm, bridging formal verification with symbolic computation. The result would immediately apply to classifying hundreds of physics ODEs.

**Catalog References**: `Bridges/GaloisNeuralCorrespondence.lean` (Galois group structure), `Algebra/FreivaldsSchwartzZippel.lean` (polynomial identity testing), `EML/EMLv17Advanced.lean` (EML function properties)

**Proof Strategy**: 
1. Formalize rational function fields ℚ(x) with their derivative (already partially in Mathlib as `RatFunc`)
2. Implement Case 2: compute the "necessary conditions" on poles and leading terms of a and b
3. Implement Case 3: classify finite subgroups of SL(2,ℂ) (tetrahedral, octahedral, icosahedral) and check compatibility with monodromy
4. Combine all cases with Case 1 (already formalized) to produce the decision procedure
5. Verify on Airy (y''=xy), Bessel (y''+y'/x+(1-n²/x²)y=0), and harmonic oscillator (y''+x²y=0)

**Domain Bridges**: Algebra (Galois groups, polynomial rings) <-> Analysis (ODE solutions, asymptotic behavior) <-> Computation (decision procedures, symbolic algorithms)

**Lineage**: Builds on `no_poly_riccati_odd_degree`, `riccati_reduction`, and `abel_identity_pointwise` from this cycle.

**Ambition**: grand_challenge

---

### Direction 2: Picard-Lindelöf Theorem and ODE Uniqueness in Lean 4

**Conjecture**: The Picard-Lindelöf existence and uniqueness theorem for ODEs can be formalized in Lean 4 using Mathlib's metric space and Banach fixed-point theorem infrastructure, enabling the completion of the Wronskian linear dependence theory.

**Test**: Formalize the statement: if f : ℝ × ℝ → ℝ is Lipschitz in the second variable, then y' = f(x,y) with y(x₀) = y₀ has a unique local solution. The key test is whether Mathlib's `ContractingMap` and `BanachFixedPoint` infrastructure is sufficient for the Picard iteration argument.

**Impact**: Would unlock the formalization of `linear_dependent_of_wronskian_zero` and `three_solutions_dependent` from this cycle, completing the Wronskian theory. More broadly, ODE uniqueness is a prerequisite for formalizing most of mathematical physics.

**Catalog References**: `Applications/WronskianTheory.lean` (statements requiring uniqueness), `Applications/RiccatiAiry.lean` (ODE solution structure)

**Proof Strategy**:
1. Define the Picard iteration operator T[y](x) = y₀ + ∫_{x₀}^{x} f(t, y(t)) dt
2. Show T is a contraction on C([x₀-δ, x₀+δ]) with the sup norm, for small enough δ
3. Apply the Banach fixed-point theorem (available as `ContractingMap.fixedPoint` in Mathlib)
4. Derive uniqueness from the contraction property
5. Specialize to linear ODEs y'' + py' + qy = 0 to get the solution space structure

**Domain Bridges**: Analysis (fixed-point theorems, metric spaces) <-> ODE theory (existence, uniqueness) <-> Algebra (solution space dimension)

**Lineage**: Directly extends the Wronskian theory from this cycle, filling the gap identified in `WronskianTheory.lean`.

**Ambition**: grand_challenge

---

### Direction 3: Rational Riccati Solutions and Partial Fraction Decomposition

**Conjecture**: For a polynomial r(x) of odd degree, the Riccati equation ω' + ω² = r has no *rational* (not just polynomial) solution. Specifically, any rational function ω satisfying ω' + ω² = r with deg(r) odd must be a polynomial, reducing to our existing theorem.

**Test**: Formalize the pole analysis: if ω has a pole of order m at x = α, then near α, ω² has a pole of order 2m while ω' has a pole of order m+1. For ω' + ω² to be a polynomial (no poles), we need 2m = m+1, hence m = 1. Then the residue must be ±1. Show that this leads to a contradiction for odd-degree r by counting constraints.

**Impact**: Completes Case 1 of the Kovacic algorithm for polynomial coefficient equations, moving from our current polynomial-only result to the full rational function case.

**Catalog References**: `Applications/KovacicCriterion.lean` (polynomial case), `Applications/RiccatiAiry.lean` (degree obstruction)

**Proof Strategy**:
1. Formalize Laurent series or formal power series around a pole (Mathlib has `PowerSeries`)
2. Analyze the leading terms of ω' + ω² near a pole of ω
3. Show the residue condition forces m = 1, residue = ±1
4. Count the degrees of freedom: n poles remove n degrees from the leading coefficient system
5. Show the system is inconsistent for odd-degree r

**Domain Bridges**: Algebra (partial fractions, rational functions) <-> Complex Analysis (poles, residues) <-> Differential algebra (Riccati equations)

**Lineage**: Direct extension of `no_poly_riccati_odd_degree` from this cycle.

**Ambition**: extension

---

### Direction 4: EML Growth Rate Classification and Hardy Fields

**Conjecture**: EML functions form a **Hardy field**: any EML function is eventually (for large x) either positive, negative, or zero, and any two EML functions are eventually comparable. Furthermore, the growth rate of an EML function is determined by its depth (exp/log nesting level), with each additional exp-level giving super-polynomial growth.

**Test**: Formalize the statement that for any two EML expressions e₁, e₂, there exists X such that for all x > X, either e₁.eval(x) ≤ e₂.eval(x) or e₂.eval(x) ≤ e₁.eval(x). Test with specific examples: exp(x) vs x^n for any n, exp(exp(x)) vs exp(x^n), log(x) vs x^ε for any ε > 0.

**Impact**: Would provide a formal foundation for asymptotic analysis of ODE solutions, enabling growth-rate arguments like "Airy solutions grow like exp(x^{3/2}) which is not achievable by any EML function of depth 1." This connects the syntactic EML hierarchy to analytic function behavior.

**Catalog References**: `EML/EMLv17Core.lean` (EML definitions), `EML/EMLv17Advanced.lean` (EML properties), `Applications/EMLExpr.lean` (depth, symbDeriv)

**Proof Strategy**:
1. Define eventual ordering on EML expressions via their evaluations
2. Prove the comparison principle by structural induction, using L'Hôpital's rule (available in Mathlib as various `Filter.Tendsto` lemmas)
3. Prove the growth rate theorem: depth-k EML functions grow faster than any depth-(k-1) function
4. Apply to Airy: solutions have "depth 1.5" growth (exp(x^{3/2})), which falls between depth-1 and depth-2 EML growth

**Domain Bridges**: Analysis (asymptotic analysis, Hardy fields) <-> Algebra (ordered fields, valuation theory) <-> EML theory (depth hierarchy)

**Lineage**: Extends `depth_symbDeriv_le` from this cycle and connects to `eml_beats_poly_for_towers` from the Catalog.

**Ambition**: extension

---

### Direction 5: Differential Galois Groups as Algebraic Groups

**Conjecture**: The differential Galois group of a second-order linear ODE y'' = r(x)y with polynomial r(x) can be formally characterized as a Zariski-closed subgroup of SL(2, ℂ), and the Kovacic case classification corresponds exactly to the classification of algebraic subgroups of SL(2): Borel, dihedral, finite, or all of SL(2).

**Test**: Formalize the definition of the differential Galois group as Aut(K/F) where K is the Picard-Vessiot extension and F = ℂ(x). Verify that for the constant coefficient equation y'' = cy (c ∈ ℂ), the Galois group is: {I} when c = 0; the multiplicative group ℂ* when c ≠ 0 is not a perfect square; or ℤ/2ℤ when the roots of t² = c are in ℚ.

**Impact**: Would provide the algebraic foundation for understanding WHY the Kovacic algorithm works — it's not just a trick, but a reflection of the classification of algebraic subgroups of SL(2). This would be the first formalization of differential Galois theory as a coherent algebraic framework.

**Catalog References**: `Bridges/GaloisNeuralCorrespondence.lean` (classical Galois theory), `Algebra/ProofSpectra/Core.lean` (Galois connections), `Algebra/QDF_HE_Frontiers.lean` (group structure)

**Proof Strategy**:
1. Define Picard-Vessiot extensions as differential field extensions with specified solution properties
2. Define the differential Galois group as the group of differential automorphisms
3. Prove it is a linear algebraic group (Zariski-closed in GL(n))
4. For n=2, classify using the known classification of algebraic subgroups of SL(2)
5. Connect each subgroup type to the corresponding Kovacic case

**Domain Bridges**: Algebraic geometry (algebraic groups, Zariski topology) <-> Differential algebra (Picard-Vessiot theory) <-> Representation theory (SL(2) representations)

**Lineage**: Extends the Galois group connections from `prime_degree_divides_galois_order` and the Riccati theory from this cycle.

**Ambition**: grand_challenge
