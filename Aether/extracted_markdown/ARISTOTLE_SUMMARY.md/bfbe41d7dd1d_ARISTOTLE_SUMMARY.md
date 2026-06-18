# Summary of changes for run 1bf930a0-95c7-41d2-b973-b570693968b7
## Completed: Polynomial Obstruction Theory for ODE Solvability

### Lean File: `EML/EMLDiffObstruction.lean`

Created a self-contained, fully verified Lean 4 file establishing formal obstruction theory for polynomial solvability of linear ODEs. All 6 theorems compile with zero `sorry` and only standard axioms (`propext`, `Classical.choice`, `Quot.sound`).

### Theorems Proved

1. **`degree_second_deriv_lt_degree_X_mul`** — Core degree mismatch: for any nonzero p ∈ ℝ[X], deg(p″) < deg(X·p). This is the atomic building block.

2. **`no_poly_solves_airy`** — No nonzero polynomial satisfies the Airy equation y″ = X·y. Direct corollary of the degree mismatch.

3. **`no_poly_solves_second_order_pos_deg`** — **General obstruction**: For *any* polynomial coefficient q with deg(q) ≥ 1, the equation y″ = q·y has no nonzero polynomial solution. Strictly generalizes the Airy case.

4. **`poly_wronskian_derivative_zero`** — **Wronskian constancy (Abel's identity)**: If f″ = q·f and g″ = q·g in ℝ[X], then the derivative of the Wronskian W(f,g) = f·g' - g·f' is zero. This is the polynomial-ring version of Abel's identity.

5. **`no_poly_solves_riccati_airy`** — No polynomial satisfies the Riccati equation v' + v² = X. Uses a degree parity argument: deg(v²) = 2·deg(v) is even but deg(X) = 1 is odd.

6. **`no_poly_solves_gen_airy`** — For all n ≥ 1, no nonzero polynomial satisfies y″ = Xⁿ·y. Corollary of the general obstruction.

### Key Mathematical Insight

The degree mismatch argument: for y″ = q(x)·y with deg(q) ≥ 1, the right side has degree deg(q) + deg(y) > deg(y), while the left side y″ has degree < deg(y). This gap makes polynomial solutions impossible, providing the simplest and most fundamental obstruction to solving such ODEs.

### Future Directions: `FUTURE_DIRECTIONS.md`

Contains 5 falsifiable research directions:
1. Rational function solutions and full Kovacic Case 1
2. Polynomial obstruction for Painlevé I (nonlinear extension)
3. Exponential-polynomial solutions and growth hierarchies
4. Wronskian as a differential Galois/SL₂ invariant
5. Automated decision procedure for polynomial solvability