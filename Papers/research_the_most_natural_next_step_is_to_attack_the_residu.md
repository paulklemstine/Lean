# One Known Solution Linearizes the Riccati Equation: A Differential-Galois Account

**Author:** Aristotle
**Date:** 2026-06-28
**Domain:** Novelty — Differential Algebra and Differential Galois Theory

## Abstract

The Riccati equation $v' + v^2 + p\,v + q = 0$ is the simplest genuinely nonlinear ordinary differential equation and a hinge between linear and nonlinear theory. It is classical that a single known solution $v_0$ reduces it to a first-order linear equation via the substitution $v = v_0 + 1/u$. We give a fully rigorous, purely algebraic treatment of this reduction in an *arbitrary differential field* $(K, {}')$ — no analytic, topological, characteristic, or algebraic-closure hypotheses are used. Our central result is a single *cleared* algebraic identity,
$$\big[(v_0 + u^{-1})' + (v_0 + u^{-1})^2 + p(v_0 + u^{-1}) + q\big]\,u^2 = (2v_0 + p)\,u + 1 - u',$$
from which we derive, as an exact equivalence, that $v = v_0 + 1/u$ solves the Riccati equation **iff** $u$ solves the affine linear equation $u' = (2v_0 + p)\,u + 1$. We prove the converse extraction map $u = 1/(v - v_0)$, establishing a bijection between Riccati solutions distinct from $v_0$ and solutions of the linear equation, and we record the Bernoulli companion identity $(v - v_0)'/(v - v_0) = -(v + v_0 + p)$. We then place these facts inside differential Galois theory: the general Riccati equation carries a projective $\mathrm{PGL}_2(\text{constants})$ symmetry (witnessed by the constancy of the cross-ratio of four solutions), and fixing one solution restricts this symmetry to the *solvable affine stabilizer* $\mathbb{G}_a \rtimes \mathbb{G}_m$. This is the structural reason a Riccati equation with one known solution is integrable by quadratures. All results are machine-verified in Lean 4 / Mathlib.

---

## 1. Introduction

The Riccati equation
$$v' + v^2 + p\,v + q = 0 \tag{R}$$
occupies a privileged place in the theory of differential equations. It is first order and quadratic — the minimal departure from linearity — yet it controls a remarkable range of phenomena: the logarithmic derivative $v = y'/y$ of a second-order linear equation $y'' + p\,y' + (\dots)\,y = 0$ satisfies a Riccati equation, so (R) is the nonlinear avatar of all second-order linear theory. In applications it governs linear-quadratic optimal control (the matrix Riccati equation), the WKB/eikonal expansion in semiclassical analysis, supersymmetric quantum mechanics, and eigenvalue flows.

The equation (R) has two faces. **Negatively**, its solutions can be transcendental: the Airy Riccati equation $v' + v^2 = x$ admits no rational solution, so it cannot be solved in elementary terms. **Positively**, there is a classical reduction principle: *one known solution linearizes the equation*. If $v_0$ solves (R), the substitution $v = v_0 + 1/u$ removes the nonlinearity and produces a first-order linear equation for $u$, which is solvable by an integrating factor — "integrable by quadratures."

This paper gives a complete, elementary, and fully general proof of the positive reduction, and frames it within differential Galois theory. Our contributions are:

1. A **division-free cleared identity** (Theorem 3.1) that is the algebraic engine of the linearization, valid for any $u \ne 0$.
2. The **linearization equivalence** (Theorem 3.2): an exact "iff" between solvability of (R) by $v_0 + 1/u$ and the affine linear equation for $u$.
3. The **converse extraction** (Theorem 3.3): any second solution $v$ yields $u = 1/(v - v_0)$ solving the linear equation — a bijection.
4. The **Bernoulli companion** (Theorem 3.4): the logarithmic derivative of the gap $v - v_0$.
5. A **differential-Galois synthesis** (Section 4): the projective $\mathrm{PGL}_2$ symmetry of the general equation (constancy of the cross-ratio), and its restriction to the solvable affine stabilizer when $v_0$ is fixed.

Everything is proved over an arbitrary differential field, and all proofs are formally verified.

## 2. Setting and definitions

### 2.1 Differential fields

**Definition 2.1 (Differential field).** A *differential field* is a field $K$ equipped with a *derivation* ${}' : K \to K$ — an additive map satisfying the Leibniz rule
$$(xy)' = x'\,y + x\,y' \qquad (x, y \in K).$$
We write $x'$ for the derivative of $x$. An element $c \in K$ with $c' = 0$ is a *constant*; the constants form a subfield $C \subseteq K$.

From the axioms one derives the standard calculus of derivations, all of which we use:
- **Quotient rule:** $(x/y)' = (x'y - xy')/y^2$ for $y \ne 0$.
- **Reciprocal rule:** $(y^{-1})' = -y^{-2}\,y'$ for $y \ne 0$.
- **Integer powers:** $(y^n)' = n\,y^{n-1}\,y'$ for $n \in \mathbb{Z}$, $y \ne 0$.

No assumption is made on the characteristic of $K$, on algebraic closure, or on the size of the constant field. The canonical analytic models are $K = \mathbb{C}(x)$ (rational functions, $' = d/dx$, constants $\mathbb{C}$) and $K = $ a field of meromorphic functions, but the theory is purely algebraic.

### 2.2 The logarithmic derivative

**Definition 2.2 (Logarithmic derivative).** For $y \in K^\times$, the *logarithmic derivative* is $L(y) := y'/y$.

The Leibniz rule makes $L$ a group homomorphism from the multiplicative group $(K^\times, \cdot)$ to the additive group $(K, +)$:
$$L(yz) = L(y) + L(z), \qquad L(y/z) = L(y) - L(z), \qquad L(y^n) = n\,L(y).$$
Its kernel is exactly the nonzero constants. This homomorphism is the structural reason first-order linear equations "exponentiate": the solutions of $y' = a\,y$ form a single coset of $\ker L = C^\times$, i.e. a one-dimensional $\mathbb{G}_m(C)$-torsor.

### 2.3 First-order linear equations and their symmetry

**Definition 2.3 (First-order linear / affine equations).** Given $a, b \in K$:
- the *homogeneous* first-order linear equation is $w' = a\,w$;
- the *affine* (inhomogeneous) equation is $u' = a\,u + b$.

**Proposition 2.4 (Multiplicative structure; `solution_ratio_isConstant`, `galois_torsor`).** If $y_1' = a\,y_1$ and $y_2' = a\,y_2$ with $y_1 \ne 0$, then $(y_2/y_1)' = 0$; consequently any two nonzero solutions of $w' = a\,w$ differ by a nonzero constant factor, and the nonzero solutions form a $\mathbb{G}_m(C)$-torsor. *Sketch.* By the quotient rule, $(y_2/y_1)' = (y_2'y_1 - y_2 y_1')/y_1^2 = (a y_2 y_1 - a y_2 y_1)/y_1^2 = 0$. $\square$

This is the rank-1 Picard–Vessiot statement: the differential Galois group of $w' = a\,w$ is a subgroup of $\mathbb{G}_m(C)$, the multiplicative group of nonzero constants.

### 2.4 The Riccati equation and the cross-ratio

We say $v \in K$ is a *Riccati solution* (for fixed $p, q \in K$) if it satisfies (R).

**Definition 2.5 (Cross-ratio).** For $v_1, v_2, v_3, v_4 \in K$ with $v_1 \ne v_4$, $v_2 \ne v_3$,
$$[\,v_1, v_2; v_3, v_4\,] := \frac{(v_1 - v_3)(v_2 - v_4)}{(v_1 - v_4)(v_2 - v_3)}.$$
The cross-ratio is the basis-free invariant of the Möbius ($\mathrm{PGL}_2$) action on $K \cup \{\infty\}$.

## 3. The linearization theorems

Fix $p, q \in K$ and a Riccati solution $v_0$, i.e. $v_0' + v_0^2 + p\,v_0 + q = 0$.

### 3.1 The cleared identity

**Theorem 3.1 (`riccati_oneSolution_identity`).** For every $u \in K$ with $u \ne 0$,
$$\Big[(v_0 + u^{-1})' + (v_0 + u^{-1})^2 + p\,(v_0 + u^{-1}) + q\Big]\cdot u^2 \;=\; (2v_0 + p)\,u + 1 - u'. \tag{3.1}$$

*Proof sketch.* Expand the left-hand bracket. Using additivity of $'$ and the reciprocal rule $(u^{-1})' = -u^{-2}u'$,
$$(v_0 + u^{-1})' = v_0' - u^{-2}u'.$$
Expanding the square, $(v_0 + u^{-1})^2 = v_0^2 + 2v_0 u^{-1} + u^{-2}$, and $p(v_0 + u^{-1}) = p v_0 + p u^{-1}$. Grouping,
$$\text{bracket} = \underbrace{(v_0' + v_0^2 + p v_0 + q)}_{= 0 \text{ by (R)}} + (2v_0 + p)u^{-1} + u^{-2} - u^{-2}u'.$$
The first group vanishes by the hypothesis that $v_0$ solves (R). Multiplying the surviving terms $(2v_0 + p)u^{-1} + u^{-2} - u^{-2}u'$ by $u^2$ yields $(2v_0 + p)u + 1 - u'$. Formally, after clearing denominators with `field_simp`, the identity is the linear combination $u^2 \cdot (\text{R at } v_0)$, discharged by `linear_combination`. $\square$

The point of multiplying by $u^2$ is to obtain a *polynomial* identity with no denominators beyond the single hypothesis $u \ne 0$, making the equivalence below immediate and division-free.

### 3.2 The linearization equivalence

**Theorem 3.2 (`riccati_solvable_iff_linear`).** Let $u \ne 0$. Then
$$(v_0 + u^{-1})' + (v_0 + u^{-1})^2 + p\,(v_0 + u^{-1}) + q = 0 \quad\Longleftrightarrow\quad u' = (2v_0 + p)\,u + 1. \tag{3.2}$$

*Proof sketch.* Let $R(u) := \big[(v_0 + u^{-1})' + \cdots + q\big]$ be the Riccati expression at $v = v_0 + u^{-1}$, and let $S(u) := (2v_0 + p)u + 1 - u'$. Theorem 3.1 states $R(u)\,u^2 = S(u)$.
($\Rightarrow$) If $R(u) = 0$ then $S(u) = 0\cdot u^2 = 0$, i.e. $u' = (2v_0+p)u + 1$.
($\Leftarrow$) If $u' = (2v_0+p)u+1$ then $S(u) = 0$, so $R(u)\,u^2 = 0$; since $u^2 \ne 0$ (as $u \ne 0$), the factor $R(u) = 0$. $\square$

This is the linearization: the nonlinear equation (R) for $v = v_0 + 1/u$ is *equivalent* to the affine linear equation $u' = (2v_0 + p)u + 1$, which is solvable by quadratures.

**Remark 3.2.1 (Geometric meaning of the coefficient).** The right-hand side of (R), as a map $v \mapsto -v^2 - p v - q$, has derivative $-2v - p$. At $v = v_0$ this is $-(2v_0 + p)$. Thus the coefficient $2v_0 + p$ in the linearized equation is (up to the catalog sign convention) the *Jacobian of the Riccati vector field at the known solution*. The "$+1$" is the inhomogeneous (translation) term created by the reciprocal substitution.

### 3.3 Converse extraction and the bijection

**Theorem 3.3 (`riccati_solution_gives_linear`).** If $v$ is a Riccati solution with $v \ne v_0$, then $u := (v - v_0)^{-1}$ satisfies
$$u' = (2v_0 + p)\,u + 1. \tag{3.3}$$

*Proof sketch.* Since $v \ne v_0$, $d := v - v_0 \ne 0$, hence $u = d^{-1} \ne 0$. Observe $v_0 + u^{-1} = v_0 + (d^{-1})^{-1} = v_0 + d = v$. Therefore the Riccati expression at $v_0 + u^{-1}$ equals the Riccati expression at $v$, which is $0$ since $v$ solves (R). Apply the forward direction of Theorem 3.2 to conclude (3.3). $\square$

**Corollary 3.3.1 (Bijection of solution sets).** The maps
$$u \;\longmapsto\; v_0 + u^{-1} \qquad\text{and}\qquad v \;\longmapsto\; (v - v_0)^{-1}$$
are mutually inverse bijections between $\{\,u \ne 0 : u' = (2v_0 + p)u + 1\,\}$ and $\{\,v \ne v_0 : v \text{ solves (R)}\,\}$. *Sketch.* Theorem 3.2 sends each nonzero solution $u$ of the affine equation to a Riccati solution $v = v_0 + 1/u$; since $1/u \ne 0$, $v \ne v_0$. Theorem 3.3 is the inverse, and $u \mapsto (v_0 + u^{-1} - v_0)^{-1} = u$ checks compatibility. $\square$

Thus solving (R) completely reduces — *exactly*, not approximately — to solving one affine linear equation. Since the homogeneous part $w' = (2v_0 + p)w$ has a $\mathbb{G}_m(C)$-torsor of solutions (Proposition 2.4) and a particular solution of the affine equation is obtained by one integration (variation of constants), the full Riccati solution set is determined by a single quadrature plus one constant of integration.

### 3.4 The Bernoulli companion

**Theorem 3.4 (`riccati_secondSolution_diff_logDeriv`).** If $v$ and $v_0$ both solve (R) and $v \ne v_0$, then
$$\frac{(v - v_0)'}{v - v_0} = -(v + v_0 + p). \tag{3.4}$$

*Proof sketch.* Subtracting the Riccati equations for $v$ and $v_0$,
$$(v - v_0)' = -(v^2 - v_0^2) - p(v - v_0) = -(v + v_0 + p)(v - v_0),$$
using $v^2 - v_0^2 = (v+v_0)(v-v_0)$. Dividing by $v - v_0 \ne 0$ gives (3.4). $\square$

Equation (3.4) exhibits the gap $v - v_0$ as a solution of the *homogeneous* first-order linear equation $w' = -(v + v_0 + p)\,w$ — the multiplicative skeleton ($\mathbb{G}_m$) underneath the affine ($\mathbb{G}_a \rtimes \mathbb{G}_m$) linearization of Theorem 3.2. It is the special case, at $v_2 = v_0$, of the general difference law for Riccati solutions used in the projective theory below.

## 4. Differential-Galois synthesis: from projective to affine

The four theorems above acquire their meaning inside differential Galois theory, which assigns to (R) a symmetry group measuring its solvability.

### 4.1 The general equation is projective

**Theorem 4.1 (Difference law; `riccati_diff`).** If $v_1, v_2$ both solve (R), then
$$(v_1 - v_2)' = -(v_1 + v_2 + p)(v_1 - v_2).$$
*Sketch.* Subtract the two Riccati equations as in Theorem 3.4. $\square$

So *every* difference of solutions is a homogeneous first-order solution. Feeding these into the multiplicative calculus of the logarithmic derivative yields the projective invariant.

**Theorem 4.2 (Cross-ratio is constant; `riccati_crossRatio_isConstant`).** If $v_1, v_2, v_3, v_4$ all solve (R), with $v_1 \ne v_4$ and $v_2 \ne v_3$, then
$$\big[\,v_1, v_2; v_3, v_4\,\big]' = 0.$$
*Proof sketch.* Write the cross-ratio as $\dfrac{(v_1 - v_3)(v_2 - v_4)}{(v_1 - v_4)(v_2 - v_3)}$. By Theorem 4.1 each factor $v_i - v_j$ solves a homogeneous first-order equation with coefficient $-(v_i + v_j + p)$. By the homomorphism property of $L$ (Definition 2.2), the numerator solves the equation with coefficient $-(v_1+v_3+p) - (v_2+v_4+p)$ and the denominator with coefficient $-(v_1+v_4+p) - (v_2+v_3+p)$. Their quotient therefore solves $w' = \kappa\,w$ with
$$\kappa = \big[-(v_1+v_3+p) - (v_2+v_4+p)\big] - \big[-(v_1+v_4+p) - (v_2+v_3+p)\big] = 0,$$
the $p$ and linear terms telescoping exactly. Hence the cross-ratio has zero derivative. $\square$

Constancy of the cross-ratio is precisely the statement that the differential Galois group of (R) acts on the solution set by Möbius transformations: it is a subgroup of $\mathrm{PGL}_2(C)$. Three distinct solutions fix the projective coordinate, so the solution set is a single $\mathrm{PGL}_2(C)$-orbit.

### 4.2 One solution restricts to the solvable affine group

In $\mathrm{PGL}_2$, the stabilizer of a point is the affine group $\mathrm{Aff}_1 = \mathbb{G}_a \rtimes \mathbb{G}_m$ of maps $w \mapsto \alpha w + \beta$. Fixing a Riccati solution $v_0$ amounts to passing to this stabilizer, and Theorems 3.1–3.3 realize it concretely:

- The reciprocal coordinate $u = 1/(v - v_0)$ converts the projective action fixing $v_0$ into the affine action on $u$.
- The linearized equation $u' = (2v_0 + p)u + 1$ has homogeneous part $u' = (2v_0+p)u$, whose solutions form a $\mathbb{G}_m(C)$-line (Proposition 2.4): this is the *scaling* part.
- The inhomogeneous "$+1$" is the *translation* ($\mathbb{G}_a$) part, resolved by a single particular solution.

Concretely, if $v_1, v_2$ are two solutions distinct from $v_0$, then $u_i = 1/(v_i - v_0)$ each solve the affine equation, and their **difference** $u_1 - u_2$ solves the *homogeneous* equation $w' = (2v_0 + p)w$ — the inhomogeneous terms cancel. Two such homogeneous differences have constant ratio (Proposition 2.4). This is the affine torsor structure made explicit: solutions live on an affine line over the one-dimensional homogeneous solution space.

**The structural conclusion.** Because $\mathrm{Aff}_1 = \mathbb{G}_a \rtimes \mathbb{G}_m$ is a *solvable* algebraic group, the equation it governs is integrable by quadratures. Thus:

> A single known solution of a Riccati equation restricts its differential Galois group from the projective $\mathrm{PGL}_2(C)$ to the solvable affine stabilizer $\mathbb{G}_a \rtimes \mathbb{G}_m(C)$, which is exactly why the equation becomes integrable.

### 4.3 The negative boundary

The reduction is vacuous if no solution exists in $K$. The Airy Riccati equation $v' + v^2 = x$ over $K = \mathbb{C}(x)$ has *no rational solution*: there is no $v_0$ to fix, the Galois group never descends below the projective level, and the solutions are genuinely transcendental (Airy functions). The positive results of this paper are the exact mirror of that obstruction: existence of one solution is the precise hinge between "EML-unsolvable" and "integrable by quadratures."

## 5. Algorithmic content

The theorems are constructive and yield an explicit solution procedure.

**Algorithm (Riccati reduction by a known solution).**
*Input:* $p, q \in K$ and a solution $v_0$ of (R).
1. Form the affine equation $u' = (2v_0 + p)\,u + 1$.
2. Solve its homogeneous part $w' = (2v_0 + p)\,w$ by one quadrature: $w = \exp\!\int (2v_0 + p)$.
3. Find a particular solution $u_p$ by variation of constants: $u_p = w\!\int w^{-1}$.
4. The general solution is $u = u_p + C\,w$ for a constant $C$.
5. Output $v = v_0 + 1/u$.

By Corollary 3.3.1 this captures *every* solution $v \ne v_0$; the value $v = v_0$ corresponds to the limit $C \to \infty$ (i.e. $u \to \infty$). The cost is two quadratures, matching the classical complexity of "solvable by quadratures."

In purely algebraic settings (e.g. $K = \mathbb{C}(x)$), the same steps become *rational* operations whenever the quadratures stay rational, and Theorem 3.2 then serves as a *certificate*: to verify a claimed solution $v = v_0 + 1/u$ one need only check the single linear identity $u' = (2v_0 + p)u + 1$, a polynomial identity after clearing denominators — far cheaper than re-substituting into the quadratic equation.

## 6. Applications

- **Control theory.** The scalar linear-quadratic regulator reduces to a Riccati equation; a known equilibrium solution linearizes the transient analysis exactly as in Theorem 3.2.
- **Quantum mechanics / SUSY QM.** With $v = \psi'/\psi$, a known ground state $\psi_0$ supplies $v_0$, and the linearization is the algebraic core of factorization (Darboux) methods and shape-invariant potentials.
- **Special-function identities.** Connection formulas between solutions of second-order linear ODEs descend, via $v = y'/y$, to Möbius relations among Riccati solutions — exactly the constant cross-ratio of Theorem 4.2.
- **Certified symbolic solving.** Theorem 3.2 gives a cheap, division-free correctness certificate for computer-algebra Riccati solvers.

## 7. Discussion and future work

The results crystallize a clean trichotomy for the Riccati equation: **projective** $\mathrm{PGL}_2(C)$ symmetry in general (cross-ratio constant), **affine/solvable** collapse once one solution is known (this paper), and a **negative boundary** when no solution exists (Airy). The proofs are elementary — they use only the Leibniz rule and field arithmetic — yet they expose the full Galois-theoretic skeleton.

Several directions extend this work:

1. **Second-order linearization.** Via $v = y'/y$, the Riccati reduction corresponds to *reduction of order* for second-order linear equations: one known solution $y_0$ reduces $y'' + P y' + Q y = 0$ to a first-order equation for the ratio. Formalizing this correspondence in the same differential-field generality would unify the Riccati and Wronskian pictures.

2. **Matrix and projective Riccati equations.** The scalar reduction generalizes to the matrix Riccati equation of optimal control, where $\mathrm{PGL}_2$ is replaced by a larger projective group acting on a Grassmannian. A formal account of the matrix linearization (one known solution reduces to a Lyapunov/Sylvester linear equation) is the natural next target.

3. **Kovacic-style classification.** Constancy of the cross-ratio classifies Riccati solvability by the $\mathrm{PGL}_2(C)$-orbit type of the solution set; pairing this with the affine reduction would yield a formal, certificate-driven version of the decision procedure for closed-form solvability of second-order linear ODEs.

4. **Picard–Vessiot rank-2 theory.** Promoting the rank-1 $\mathbb{G}_m(C)$-torsor statement to the full Picard–Vessiot correspondence for second-order equations would let the affine and projective layers be read off directly from the Galois group, completing the dictionary between the differential-algebraic identities here and the structure theory of linear algebraic groups.

## 8. Conclusion

We have given a complete, fully general, machine-verified proof that one known solution linearizes the Riccati equation, organized around a single cleared algebraic identity. The linearization is an exact equivalence, the second-solution map is a bijection, and the whole phenomenon is the restriction of a projective $\mathrm{PGL}_2(C)$ symmetry to its solvable affine stabilizer $\mathbb{G}_a \rtimes \mathbb{G}_m(C)$ — the differential-Galois reason a Riccati equation with a known solution is integrable by quadratures. The arguments require nothing beyond the algebra of a derivation, and they sit cleanly alongside the projective (cross-ratio) and negative (Airy) layers of the theory.
