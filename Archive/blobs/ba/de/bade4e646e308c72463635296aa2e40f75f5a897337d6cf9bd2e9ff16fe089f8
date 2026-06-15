import Mathlib

/-!
# Polynomial Obstruction Theory for ODE Solvability

This file establishes formal obstruction theory for polynomial solvability of
linear ordinary differential equations, centered on Airy's equation y″ = xy
as the prototypical barrier.

## Main Results

* `no_poly_solves_airy` — No nonzero polynomial satisfies y″ = X·y
* `no_poly_solves_second_order_pos_deg` — General degree obstruction: for any
  polynomial coefficient q of positive degree, y″ = q·y has no nonzero polynomial solution
* `poly_wronskian_derivative_zero` — The polynomial Wronskian W(f,g) = f·g' - g·f'
  has zero derivative when f and g both satisfy y″ = q·y
* `no_poly_solves_riccati_airy` — No polynomial satisfies the associated Riccati
  equation v' + v² = X

## Mathematical Context

The impossibility of solving Airy's equation y″ = xy in terms of elementary
functions begins with the most basic obstruction: no polynomial can satisfy it.
The key insight is a degree mismatch: for y″ = q(x)·y with deg(q) ≥ 1,
the right side q·y has degree deg(q) + deg(y), strictly greater than deg(y),
while the left side y″ has degree strictly less than deg(y). This makes
equality impossible for any nonzero polynomial y.

The Wronskian result is the polynomial-ring analogue of Abel's identity from
ODE theory. The Riccati obstruction connects to differential Galois theory:
if Airy's equation had a Liouvillian solution, the associated Riccati equation
would have an algebraic (in particular, polynomial) solution.
-/

open Polynomial

namespace EMLDiffObstruction

/-! ### Degree comparison lemma -/

/-
!-- The core degree argument: for p ≠ 0, degree(p'') < degree(X · p).
This follows because degree(p'') < degree(p) ≤ degree(p) + 1 = degree(X · p),
using that derivative strictly decreases degree of nonzero polynomials. -- !--

The degree of the second derivative of a nonzero polynomial is strictly less
than the degree of X times that polynomial. This is the core degree mismatch
underlying all polynomial obstruction arguments for second-order ODEs.
-/
theorem degree_second_deriv_lt_degree_X_mul (p : Polynomial ℝ) (hp : p ≠ 0) :
    (derivative (derivative p)).degree < (X * p).degree := by
  -- The degree of $X * p$ is $1 + \deg(p)$.
  have h_deg_Xp : (Polynomial.X * p).degree = 1 + p.degree := by
    rw [ Polynomial.degree_mul, Polynomial.degree_X ];
  exact lt_of_le_of_lt ( Polynomial.degree_derivative_le ) ( lt_of_le_of_lt ( Polynomial.degree_derivative_le ) ( by erw [ h_deg_Xp ] ; erw [ Polynomial.degree_eq_natDegree hp ] ; norm_cast; linarith ) )

/-! ### Airy equation obstruction -/

/-
!-- No nonzero polynomial satisfies y'' = xy. Proof: by the degree comparison
lemma, degree(p'') < degree(X·p), so they cannot be equal. -- !--

**Airy polynomial obstruction**: No nonzero polynomial satisfies the Airy
equation y″ = xy in the polynomial ring ℝ[X].
-/
theorem no_poly_solves_airy (p : Polynomial ℝ) (hp : p ≠ 0)
    (heq : derivative (derivative p) = X * p) : False := by
  -- By degree comparison, since the degrees of the left-hand side and right-hand side are different, they cannot be equal.
  have := degree_second_deriv_lt_degree_X_mul p hp
  aesop

/-! ### General degree obstruction -/

/-
!-- For any polynomial q with natDegree ≥ 1 and nonzero p, we have
degree(p'') < degree(p) ≤ degree(q·p), so p'' ≠ q·p. -- !--

**General polynomial ODE obstruction**: For any polynomial coefficient q of
positive degree, the equation y″ = q·y has no nonzero polynomial solution.
This generalizes the Airy case (q = X) to arbitrary polynomial coefficients
like q = X², X³, X² + X, etc.
-/
theorem no_poly_solves_second_order_pos_deg (q p : Polynomial ℝ)
    (hq : 1 ≤ q.natDegree) (hp : p ≠ 0)
    (heq : derivative (derivative p) = q * p) : False := by
  apply_fun Polynomial.natDegree at heq
  rw [ Polynomial.natDegree_mul' ] at heq;
  · have h_deg_p'' : Polynomial.natDegree (derivative (derivative p)) ≤ p.natDegree - 2 := by
      have h_deg_p'' : Polynomial.natDegree (derivative p) ≤ p.natDegree - 1 := by
        exact Polynomial.natDegree_derivative_le _;
      exact le_trans ( Polynomial.natDegree_derivative_le .. ) ( by omega );
    omega;
  · aesop

/-! ### Polynomial Wronskian theory -/

/-- The polynomial Wronskian of two polynomials f and g, defined as
W(f,g) = f · g' - g · f'. This is the polynomial-ring analogue of the
classical Wronskian from ODE theory. -/
noncomputable def polyWronskian (f g : Polynomial ℝ) : Polynomial ℝ :=
  f * derivative g - g * derivative f

/-
!-- If f'' = q·f and g'' = q·g, then W'(f,g) = f·g'' - g·f'' = f·(q·g) - g·(q·f) = 0.
This is the polynomial-ring version of Abel's identity. -- !--

**Wronskian constancy (Abel's identity)**: If f and g both satisfy y″ = q·y
in the polynomial ring, then their Wronskian has zero derivative. This is the
polynomial analogue of the classical result that the Wronskian of solutions to
a second-order linear ODE without first-derivative term is constant.
-/
theorem poly_wronskian_derivative_zero (q f g : Polynomial ℝ)
    (hf : derivative (derivative f) = q * f)
    (hg : derivative (derivative g) = q * g) :
    derivative (polyWronskian f g) = 0 := by
  unfold polyWronskian; simp +decide [hf, hg, Polynomial.derivative_sub, Polynomial.derivative_mul]; ring

/-! ### Riccati equation obstruction -/

/-
!-- No polynomial solves v' + v² = X. If deg(p) = 0, then p is constant c,
so 0 + c² = X, but c² is constant. If deg(p) ≥ 1, then deg(p²) = 2·deg(p) ≥ 2
but deg(p') < deg(p) ≤ deg(p²), so deg(p' + p²) = deg(p²) = 2·deg(p),
which must equal deg(X) = 1, giving 2·deg(p) = 1, impossible in ℕ. -- !--

**Riccati polynomial obstruction**: No polynomial satisfies the Riccati equation
v' + v² = X associated with Airy's equation. The proof combines a degree parity
argument (deg(v²) = 2·deg(v) is even but deg(X) = 1 is odd) with a constant-case
analysis. This obstruction connects to differential Galois theory: if Airy's
equation had a Liouvillian solution, this Riccati equation would have a rational
(and in particular, potentially polynomial) solution.
-/
theorem no_poly_solves_riccati_airy (p : Polynomial ℝ)
    (heq : derivative p + p * p = (X : Polynomial ℝ)) : False := by
  -- If $p$ is a polynomial of degree $n$, then $p^2$ is a polynomial of degree $2n$.
  have h_deg_p2 : Polynomial.degree (p * p) = 2 * Polynomial.degree p := by
    rw [ two_mul, Polynomial.degree_mul ];
  by_cases h : p = 0 <;> simp_all +decide;
  · exact Polynomial.X_ne_zero heq.symm;
  · replace heq := congr_arg Polynomial.degree heq ; simp_all +decide;
    rw [ Polynomial.degree_add_eq_right_of_degree_lt ] at heq <;> simp_all +decide [ Polynomial.degree_eq_natDegree h ];
    · norm_cast at heq; linarith [ show p.natDegree = 0 by linarith ] ;
    · exact lt_of_le_of_lt ( Polynomial.degree_derivative_le ) ( by erw [ Polynomial.degree_eq_natDegree h ] ; norm_cast; linarith [ Nat.pos_of_ne_zero ( show p.natDegree ≠ 0 from fun h' => by rw [ Polynomial.eq_C_of_natDegree_eq_zero h' ] at h heq; aesop ) ] )

/-! ### Degree mismatch for higher-order terms -/

/-
!-- X^n · p has natDegree = n + natDegree(p), but p'' has natDegree ≤ natDegree(p) - 2.
For n ≥ 1, this gives n + natDegree(p) > natDegree(p) - 2. -- !--

No nonzero polynomial satisfies y″ = Xⁿ·y for any n ≥ 1.
This is a corollary of the general degree obstruction, but stated
in a form that directly applies to the family of generalized Airy equations.
-/
theorem no_poly_solves_gen_airy (n : ℕ) (hn : 1 ≤ n) (p : Polynomial ℝ) (hp : p ≠ 0)
    (heq : derivative (derivative p) = X ^ n * p) : False := by
  convert no_poly_solves_second_order_pos_deg ( X ^ n ) p _ hp heq;
  rw [ Polynomial.natDegree_X_pow ] ; linarith

end EMLDiffObstruction