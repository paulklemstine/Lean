# Summary of changes for run deca319a-4491-469e-8514-7446c4002aeb
# EML Differential Equations: ODEs with Exponential-Logarithmic Coefficients

## Summary

Completed a research cycle formalizing the theory of second-order linear ODEs with EML coefficients, culminating in a proof that the Airy equation y'' = xy has no polynomial Riccati solution — the algebraic core of why Airy's equation has no elementary (EML) solutions.

## Lean 4 Proofs (26 theorems, 0 sorry, all axioms clean)

### `EML/DiffEqCore.lean` — Core ODE Framework (8 theorems)
- **`abel_wronskian_deriv`**: Abel's Wronskian Identity — if f₁, f₂ satisfy y'' + p·y' + q·y = 0, then the Wronskian W satisfies W' = -p·W. This is the foundational structural theorem connecting ODE solutions to the coefficient p.
- **`riccati_reduction`**: If f satisfies y'' = r·y with f(x) ≠ 0, then w = f'/f satisfies the Riccati equation w' + w² = r. This is the backbone of the Kovacic algorithm.
- **`wronskian_antisymm`**, **`wronskian_self`**: Structural properties of the Wronskian.
- **`wronskian_exp_xexp`**: Concrete Wronskian computation W(eˣ, x·eˣ) = e²ˣ.
- **`double_exp_deriv`**: exp(-exp(x)) satisfies f' = -exp(x)·f (EML-structured ODE from Abel's identity).
- **`exp_quotient`**: EML closure under division of exponentials.
- **`exp_growth_dominates_power`**: exp(c·x) dominates any polynomial for c > 0.

### `EML/AiryObstruction.lean` — Airy Non-Solvability (7 theorems)
- **`airy_riccati_no_poly_solution`** (Main theorem): No polynomial w ∈ ℝ[X] satisfies w' + w² = X. Proved by degree analysis: constants give degree 0, linears give degree 2, higher degrees give ≥ 4, all ≠ 1.
- **`airy_riccati_no_constant_solution`**, **`airy_riccati_no_linear_solution`**, **`airy_riccati_no_high_degree_solution`**: The three supporting cases.
- **`X_not_perfect_square`**: X is not a perfect square in ℝ[X] (Kovacic Case 1 obstruction).
- **`sqrt_not_polynomial_at_origin`**: √x cannot be represented by any polynomial on [0,∞).
- **`exp_growth_dominates_power`**: Growth rate obstruction for EML vs. Airy.

### `EML/DiffEqEML.lean` — EML Differential Algebra (11 theorems)
- **`log_deriv_mul`**: Logarithmic derivative additivity: (log(f·g))' = f'/f + g'/g.
- **`log_deriv_exp`**: (exp(f))'/exp(f) = f' — the exp-log Galois correspondence.
- **`exp_poly_product_deriv`**: (p·exp(a·x))' = (p' + a·p)·exp(a·x) — EML closure under differentiation.
- **`log_deriv_pow`**: Logarithmic derivative of xⁿ is n/x.
- EML partial derivatives, tower decomposition, Wronskian factor identity, and more.

## Deliverables

- **ARTICLE.md**: Popular-science article (~1800 words) on why the Airy equation can't be solved in elementary functions.
- **RESEARCH_PAPER.md**: Full research paper (~3500 words) with abstract, definitions, proofs, algorithms, and references.
- **FUTURE_DIRECTIONS.md**: Five research directions including constructive Kovacic algorithm, higher-order Wronskians, Painlevé transcendents, growth order bounds, and Stokes phenomena.
- **demo.py**: Seven numerical demonstrations verifying all formal theorems.
- **algorithms.py**: Type-hinted implementations of Wronskian computation, Abel identity verification, Riccati reduction, Kovacic Case 1, and EML tower height computation.
- **viz_airy_obstruction.py**: Four-panel matplotlib visualization.
- **PACKAGE.json**: Complete package with 3 interactive HTML widgets (Riccati degree explorer, EML tower calculator, Abel's identity visualizer).

## Key Mathematical Contributions

1. **Deepening of catalog results**: Extends `eml_beats_poly_for_towers` by showing the EML advantage has ODE-theoretic consequences — EML coefficients constrain solution structures via Abel's identity.
2. **Cross-domain bridge**: Connects polynomial algebra (degree theory in ℝ[X]) to differential equations via the Riccati reduction, and to differential Galois theory via the Wronskian.
3. **Novel formalization**: Abel's Wronskian Identity and the Riccati reduction appear to be new formalizations in Lean 4 / Mathlib.