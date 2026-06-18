# Summary of changes for run ab4e98f0-6c7e-4c5d-8de8-bc71539edefc
## EML Differential Equations: Polynomial Obstructions and Wronskian Invariants

### Lean 4 Proofs (All sorry-free, verified with `lean build`)

**Applications/PolynomialODE.lean** — 8 fully proven theorems:
- `second_deriv_degree_gap`: The second derivative of a degree-≥-2 polynomial has degree exactly n−2
- `second_deriv_of_deg_le_one`: The second derivative of a degree-≤-1 polynomial is zero
- **`poly_ode_degree_obstruction`** (core result): For any nonzero polynomial q with deg(q) ≥ 1, the equation p'' = q·p has NO nonzero polynomial solution. This is a degree-theoretic impossibility: deg(p'') = n−2 while deg(q·p) = deg(q)+n, which are irreconcilable.
- `no_poly_solution_of_deg_ge_one`: Corollary formulated as an implication
- **`airy_no_poly_solution`**: No nonzero polynomial satisfies the Airy equation y'' = xy
- `no_poly_solution_const_coeff`: No nonzero polynomial satisfies y'' = cy for c ≠ 0
- `polyODESolutions`: The polynomial solution set forms a submodule of ℝ[X]
- `polyODESolutions_eq_bot`: This submodule is trivial when deg(q) ≥ 1

**Applications/WronskianTheory.lean** — 10 fully proven theorems:
- `wronskian_antisymm`, `wronskian_self`: Basic Wronskian properties
- `wronskian_add_left`, `wronskian_smul_left`: Bilinearity
- **`airy_wronskian_deriv_zero`** (Abel's Identity): For solutions of y'' = q(x)y, the Wronskian has derivative zero — connecting ODE theory to symplectic geometry
- **`airy_wronskian_const`**: The Wronskian is constant (using the fundamental theorem of calculus)
- `zero_mem_smoothSolutionSpace`, `add_mem_smoothSolutionSpace`, `smul_mem_smoothSolutionSpace`: The solution space is a vector space
- **`wronskian_ne_zero_imp_lin_indep`**: Nonzero Wronskian implies linear independence

**Applications/EMLDerivClosure.lean** — 7 proven results:
- `EMLExpr` inductive type: Formal grammar for EML expressions (const, var, add, mul, exp, log)
- `EMLExpr.deriv`: Structural differentiation preserving the EML type (closure by construction)
- `deriv_depth_le`: Derivative depth bounded by 2·depth+1
- Evaluation correctness lemmas for constants, variables, sums, products

### Key Mathematical Contributions

1. **General Polynomial ODE Obstruction**: Proved over arbitrary integral domains with torsion-free additive groups — not just ℝ. The degree gap argument (differentiation reduces degree, multiplication increases it) creates an absolute barrier.

2. **Wronskian Constancy via Abel's Identity**: Proved that for Airy-type ODEs (no first-derivative term), the Wronskian of any two solutions is constant. This is the statement that the differential Galois group preserves a symplectic form, forcing it into SL₂.

3. **EML Derivative Closure with Depth Control**: The derivative of any EML expression is EML, with depth growth bounded by 2·depth+1.

### Deliverables
- `ARTICLE.md`: Scientific American-style article on the Airy equation and the limits of mathematical expression
- `RESEARCH_PAPER.md`: Technical paper with PEGB analysis for all major theorems
- `FUTURE_DIRECTIONS.md`: 5 research directions including Kovacic algorithm formalization and tropical Airy equations
- `demo.py`, `algorithms.py`: Python implementations of degree gap test, EML differentiation, Wronskian computation
- `viz_degree_gap.py`, `viz_wronskian.py`: Visualization scripts
- `PACKAGE.json`: Full package with 3 interactive HTML widgets (Degree Gap Explorer, Wronskian Calculator, EML Differentiator)