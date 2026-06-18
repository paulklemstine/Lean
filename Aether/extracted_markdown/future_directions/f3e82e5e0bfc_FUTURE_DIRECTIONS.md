# Future Directions: Polynomial Obstruction Theory for ODE Solvability

## What We Proved

This cycle established six formally verified results in `EML/EMLDiffObstruction.lean`:

1. **Degree mismatch lemma** (`degree_second_deriv_lt_degree_X_mul`): For any nonzero polynomial p ∈ ℝ[X], deg(p'') < deg(X·p). This is the atomic building block of all polynomial obstruction arguments.

2. **Airy polynomial obstruction** (`no_poly_solves_airy`): No nonzero polynomial satisfies y'' = X·y.

3. **General degree obstruction** (`no_poly_solves_second_order_pos_deg`): For *any* polynomial coefficient q with deg(q) ≥ 1, the equation y'' = q·y has no nonzero polynomial solution. This is a strictly stronger result than the Airy case.

4. **Wronskian constancy** (`poly_wronskian_derivative_zero`): If f'' = q·f and g'' = q·g in ℝ[X], then W(f,g)' = 0, the polynomial-ring version of Abel's identity.

5. **Riccati obstruction** (`no_poly_solves_riccati_airy`): No polynomial satisfies v' + v² = X, connecting to the Kovacic algorithm's Case 1 analysis.

6. **Generalized Airy family** (`no_poly_solves_gen_airy`): For all n ≥ 1, no nonzero polynomial satisfies y'' = Xⁿ·y.

---

## Direction 1: Rational Function Solutions and the Full Kovacic Case 1

The natural next step beyond polynomial obstruction is to show that no *rational function* r(x) = p(x)/q(x) satisfies the Riccati equation v' + v² = x either. The key insight is that poles of a rational solution of the Riccati equation must be simple (from the v² term dominating v' near a pole), and the residue at each pole must be exactly 1. But near x = ∞, the behavior of v ∼ ±√x is irrational, creating a global obstruction. This is precisely Kovacic's Case 1 obstruction applied to the Airy equation.

**Why now?** Our Riccati polynomial obstruction already handles the pole-free case. The pole analysis requires only rational function degree arithmetic and local Laurent expansion theory, both of which can be formalized using Mathlib's `RatFunc` and `LaurentSeries` types. The general degree obstruction theorem provides the structural template.

**Falsifiable test**: Formalize `RatFunc ℝ` solutions, prove no rational function satisfies v' + v² = X, and verify the result against Kovacic's algorithm output for the Airy equation.

---

## Direction 2: Polynomial Obstruction for Painlevé I

The first Painlevé transcendent y'' = 6y² + x has no polynomial solution by an analogous degree argument: if p has degree d, then deg(p'') = d - 2 but deg(6p² + X) = max(2d, 1). Setting d - 2 = 2d gives d = -2, impossible. The key insight is that the *same* degree-mismatch technique works for nonlinear ODEs, not just linear ones — the nonlinear term y² creates an even more severe degree gap than the linear term q·y.

**Why now?** Our formalization infrastructure (degree comparison, derivative bounds) transfers directly. The only new ingredient is handling the `max` in degree(f + g) for the nonlinear case. Mathlib's `Polynomial.degree_add_le` provides this. The result would be the first formally verified obstruction for Painlevé transcendents.

**Falsifiable test**: State and prove `no_poly_solves_painleve_I : ∀ p : ℝ[X], derivative (derivative p) = 6 * p * p + X → False` (note: no `p ≠ 0` hypothesis needed since p = 0 gives 0 = X).

---

## Direction 3: Exponential-Polynomial Solutions and Growth Hierarchies

Our results show polynomials cannot solve y'' = q·y for deg(q) ≥ 1. The next class to eliminate is *exponential-polynomial* functions f(x) = p(x)·exp(r(x)) where p, r ∈ ℝ[X]. The key insight is that substituting this ansatz into y'' = q·y and comparing leading terms creates a *nonlinear* polynomial identity (r')² + (terms of lower growth) = q, which forces r' = ±√q. For non-square q (like X), this means r' is irrational, blocking the exponential-polynomial ansatz.

**Why now?** We can formalize this in the polynomial ring by considering the equation p'' + 2p'r' + p(r'' + (r')²) = q·p and extracting the leading-order identity (r')² = q. For q = X, this means (r')² = X in ℝ[X], which is impossible since X is not a perfect square. Mathlib's `Polynomial.IsSquare` and irreducibility results can be leveraged.

**Falsifiable test**: Prove that X is not a perfect square in ℝ[X] (this is `Irreducible X` + degree argument), then show no exponential-polynomial satisfies the Airy equation by reducing to this algebraic fact.

---

## Direction 4: Wronskian as a Differential Galois Invariant

Our Wronskian constancy theorem shows W' = 0 for polynomial solutions. In the analytic setting, this generalizes to: the Wronskian of any two solutions of y'' = q(x)y satisfies W' = 0, making W a constant. The key insight is that this constant Wronskian defines an SL₂-invariant: if σ is any differential automorphism of the solution space, then W(σf, σg) = det(σ)·W(f,g), and det(σ) = 1 forces the differential Galois group into SL₂. Our polynomial-ring proof captures the algebraic core of this argument without analytic machinery.

**Why now?** The polynomial Wronskian theorem we proved is the exact algebraic skeleton of the differential Galois invariance proof. Lifting it to formal power series (`PowerSeries ℝ`) would give the analytic version. Mathlib has `PowerSeries` with multiplication and a derivative-like operation (`PowerSeries.mk` and coefficient manipulation). The SL₂ connection could be formalized using `Matrix.SpecialLinearGroup`.

**Falsifiable test**: Define the Wronskian for `PowerSeries ℝ`, prove W' = 0 for power series solutions of y'' = q·y (where q is a power series), and show the monodromy matrix lies in SL₂(ℝ).

---

## Direction 5: Automated Decision Procedure for Polynomial Solvability

Our general degree obstruction provides a *decision procedure*: for any polynomial ODE y'' = q·y, polynomial solvability is equivalent to natDegree(q) = 0 (constant coefficient case). When natDegree(q) = 0, polynomial solutions exist iff q = 0 (giving y = ax + b) or q = c² for some c (giving y = exp(cx), which is not polynomial). The key insight is that our theorem `no_poly_solves_second_order_pos_deg` reduces the decision problem to a single degree check, and the constant coefficient case can be completely classified.

**Why now?** We have the hard direction (natDegree(q) ≥ 1 → no polynomial solution). The easy direction (natDegree(q) = 0 case analysis) requires only checking finitely many polynomial forms. Combining both gives a complete `Decidable` instance. This would yield a verified polynomial-solvability oracle that could be extracted to executable code via Lean's code generation.

**Falsifiable test**: Prove `polynomial_solvable_iff_const_coeff : (∃ p : ℝ[X], p ≠ 0 ∧ derivative (derivative p) = q * p) ↔ (q = 0)` — the forward direction uses our obstruction theorem, and the backward direction constructs the explicit solution y = X.
