# Summary of changes for run 312ba8c4-2636-4e36-ba9e-5ff107eb0bfc
# EML Differential Equations: Galois Obstruction Theory

## Summary

I formalized the differential Galois-theoretic obstruction to EML (exponential-multiplicative-logarithmic) solvability of second-order linear ODEs, with a focus on Airy's equation y'' = xy.

## Lean 4 Proofs (4 files, ~600 lines, 39/40 theorems proved)

### `EML/DiffEqCore.lean` — Core EML Definitions (13 theorems, all proved)
- **EMLExpr**: Inductive type for EML expressions (const, var, add, mul, neg, inv, exp, log)
- **diff_elHeight_le**: The EL-height (exp/log nesting depth) does not increase under differentiation — a key structural result
- **Evaluation semantics**: eval_const_zero, eval_var, eval_add, eval_mul
- **EML closure**: isEML_const, isEML_id, isEML_add, isEML_mul, isEML_exp, isEML_log

### `EML/AbelWronskian.lean` — Abel's Identity (5 theorems, all proved)
- **abel_identity**: W'(x) = -p(x)·W(x) for the Wronskian of solutions of y'' + py' + qy = 0
- **abel_identity_integral**: W(x) = W(x₀)·exp(-∫p(t)dt) — the integral form
- **wronskian_nonzero_everywhere**: If W(x₀) ≠ 0, then W(x) ≠ 0 for all x
- **wronskian_antisymm**, **wronskian_zero_of_dep**

### `EML/GaloisObstruction.lean` — Galois Theory (12 theorems, all proved)
- **perfect_not_solvable**: Non-trivial perfect groups are not solvable
- **derivedSeries_perfect**: The derived series of a perfect group is constant at ⊤
- **Differential ring**: D_zero, D_one, D_neg, D_pow_succ (Leibniz rule consequences)
- **Kovacic framework**: Case 4 (SL(2) Galois group) excludes Liouvillian solutions
- **galois_obstruction_no_eml**: Non-solvable Galois group → no EML solutions

### `EML/AiryNoEML.lean` — Airy Equation (10 theorems, 9 proved, 1 sorry)
- **airy_no_const_solution**: No nontrivial constant satisfies Airy's equation
- **airy_no_monomial_solution**: No monomial x^n (n ≥ 1) satisfies Airy's equation
- **airy_no_exp_linear_solution**: No exp(ax) satisfies Airy's equation
- **three_halves_not_nat**: 3/2 is not a natural number (growth rate obstruction)
- **polynomial_growth_is_iter_exp_zero**: Growth hierarchy inclusion
- **airy_no_nontrivial_eml_solution**: The full theorem (stated, 1 sorry — requires semantic correctness bridge and SL(2,ℂ) perfectness)

## Key Mathematical Contributions

1. **Abel's Identity (both forms)**: Complete formal proofs using HasDerivAt, the product rule, and the fundamental theorem of calculus. The integral form proof constructs h(x) = W(x)·exp(∫p) and shows h' = 0, hence h is constant.

2. **Perfect ⟹ Not Solvable**: Clean abstract proof by induction on the derived series, applicable to any perfect group (not just SL(2)).

3. **Differential Ring Axiomatics**: Formal derivation of D(0)=0, D(1)=0, D(-a)=-Da, D(a^{n+1})=(n+1)a^n·Da from the Leibniz rule alone.

4. **Specific Airy Obstructions**: Degree-counting and algebraic arguments showing no constant, monomial, or exponential can satisfy y'' = xy.

## Other Deliverables

- **ARTICLE.md**: Popular-science article on why Airy's equation resists elementary solution
- **RESEARCH_PAPER.md**: In-depth paper with proofs, PEGB analysis, and references
- **FUTURE_DIRECTIONS.md**: 5 research directions including verified Kovacic algorithm, SL(2) perfectness, semantic correctness bridge, Painlevé transcendents, and Risch algorithm
- **demo.py**: Numerical demonstrations (Airy functions, Wronskian verification, Kovacic cases, growth hierarchy, EML differentiation)
- **algorithms.py**: Type-hinted implementations of Kovacic classification, EML expression manipulation, Wronskian computation
- **visualize_airy.py**: Matplotlib visualization script
- **PACKAGE.json**: Complete package with 3 interactive HTML widgets (EML Expression Explorer, Airy Phase Portrait, Kovacic Case Classifier)

## Catalog Integration

Builds on: `Bridges/GaloisNeuralCorrespondence.lean` (prime_degree_divides_galois_order), `Algebra/ProofSpectra/Core.lean` (galois_connection_theory_variety), `EML/EMLv17Core.lean` (eml function definitions). The perfect_not_solvable theorem provides the abstract group-theoretic foundation that connects to these existing results.