# Summary of changes for run ab3f27dd-3fa8-4c3c-bed7-738dcca0ffc4
## EML Differential Equations: Riccati Obstructions and the Kovacic Criterion

### Overview
This research cycle formalized the connection between second-order linear ODEs with EML coefficients and their associated Riccati equations, culminating in a machine-verified proof that **Airy's equation y'' = xy has no polynomial Riccati solution** — the first step of the Kovacic algorithm proving Airy functions are not elementary/EML.

### Lean 4 Proofs (14 theorems, 0 sorries, all verified)

**`Applications/RiccatiAiry.lean`** — Core results:
- `riccati_reduction`: If f'' = r·f and f(x) ≠ 0, then (f'/f)' + (f'/f)² = r (the Riccati substitution)
- `no_poly_riccati_airy`: No polynomial satisfies ω' + ω² = X (Airy obstruction)
- `poly_sq_degree_dominates`: For deg(p) ≥ 1, deg(p' + p²) = 2·deg(p) — works over any CharZero integral domain
- `wronskian_derivative`: Abel's identity W' = -pW for second-order linear ODEs
- `const_riccati_ne_X`, `zero_ne_riccati_airy`, `derivative_C_eq_zero`: Supporting lemmas

**`Applications/KovacicCriterion.lean`** — General Kovacic theory:
- `no_poly_riccati_odd_degree`: For ANY nonzero polynomial r of odd degree, ω' + ω² = r has no polynomial solution (general degree parity obstruction)
- `no_poly_riccati_linear`: No polynomial satisfies ω' + ω² = ax + b when a ≠ 0 (covers all translated Airy equations)
- `riccati_poly_degree_even`: Any polynomial Riccati solution forces even degree on the RHS
- `airy_no_poly_riccati`: Direct corollary for Airy via the odd-degree theorem
- `leading_coeff_sq`, `natDegree_sq`: Polynomial algebra infrastructure

**`Applications/WronskianTheory.lean`** — Wronskian theory:
- `abel_identity_pointwise`: Abel's identity for the Wronskian (HasDerivAt proof using product rule + linear_combination)
- `wronskian_antisymm`: W(g,f) = -W(f,g)
- `wronskian_zero_of_scalar_multiple`: Proportional functions have zero Wronskian

**`Applications/EMLExpr.lean`** — EML differential algebra:
- `EMLExpr` inductive type with evaluation, symbolic differentiation, depth measure
- `depth_symbDeriv_le`: Differentiation increases EML depth by at most 1
- `symbDeriv_size_pos`: Symbolic derivatives are always nonempty expressions

### Key Mathematical Contributions

1. **Degree Parity Obstruction** (Theorem `no_poly_riccati_odd_degree`): A clean, general theorem showing that polynomial Riccati solutions are impossible whenever the coefficient polynomial has odd degree. This is Case 1 of the Kovacic algorithm, formalized for the first time.

2. **Riccati-ODE Bridge** (Theorem `riccati_reduction`): The fundamental transformation from second-order linear ODEs to first-order Riccati equations, proved as a HasDerivAt statement using Mathlib's quotient rule.

3. **Abel's Identity** (Theorem `abel_identity_pointwise`): The Wronskian evolution equation W' = -pW, connecting the Wronskian to ODE coefficients. Proved via product rule and linear_combination.

4. **EML Depth Bound** (Theorem `depth_symbDeriv_le`): Establishes that the EML function hierarchy is well-behaved under differentiation.

### Deliverables
- **`ARTICLE.md`**: Popular science article on why Airy functions transcend elementary mathematics
- **`RESEARCH_PAPER.md`**: Technical paper with PEGB analysis for each major theorem
- **`FUTURE_DIRECTIONS.md`**: 5 research directions including complete Kovacic formalization and Picard-Lindelöf theorem
- **`PACKAGE.json`**: Full package with 3 interactive HTML widgets (degree obstruction explorer, Wronskian simulator, Kovacic case analyzer)
- **`demo.py`**, **`algorithms.py`**, **`viz_riccati_landscape.py`**: Python implementations and visualizations