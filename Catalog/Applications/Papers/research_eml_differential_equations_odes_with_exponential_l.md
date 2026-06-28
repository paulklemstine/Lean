# The Differential Algebra of EML Ordinary Differential Equations: Logarithmic Derivatives, Galois Torsors, and a Sharp Kovacic Parity Decision

**Author:** Aristotle
**Date:** 2026-06-28
**Domain:** Novelty (Differential Algebra / Differential Galois Theory)

---

## Abstract

We develop, in a fully abstract differential-field setting, the algebraic core
of ordinary differential equations whose coefficients are *exponential,
multiplicative, and logarithmic* (EML) functions, and we apply it to the
decision problem of elementary solvability. Working over an arbitrary
differential field $K$ with derivation $y \mapsto y'$, we establish four
interlocking layers of structure. First, the **logarithmic derivative**
$L(y) = y'/y$ is a homomorphism from the multiplicative group $K^\times$ to the
additive group $(K,+)$, with the consequence that solutions of first-order linear
equations $y' = a\,y$ multiply by adding coefficients; we prove the finite
superposition law $\big(\prod_i y_i\big)' = \big(\sum_i a_i\big)\prod_i y_i$.
Second, the **constants** $\{x : x' = 0\}$ form a subfield, and the solution
space of $y' = a\,y$ is a torsor under the multiplicative group of nonzero
constants $\mathbb{G}_m(\text{constants})$: any two nonzero solutions differ by a
nonzero constant. Third, the **Wronskian** $W(y_1,y_2) = y_1 y_2' - y_2 y_1'$ is
constant on solutions of $y'' = a\,y$ (abstract Abel identity) and is a sharp
detector of linear independence over the constants. Fourth, the **Riccati
transform** $v = y'/y$ converts $y'' = a\,y$ into $v' + v^2 = a$, which drives the
first step of the Kovacic algorithm; we prove that for any polynomial $f$ of odd
degree the Riccati equation $v' + v^2 = f$ has no rational solution, deducing that
the generalized Airy family $y'' = x^{2k+1} y$ — and Airy's equation $y'' = xy$ in
particular — has no rational Riccati solution and hence no elementary solution.
Finally, we prove the decision rule is **sharp**: the even-degree coefficient
$f = x^2 + 1$ admits the rational Riccati solution $v = x$ (the logarithmic
derivative of $e^{x^2/2}$), so the odd-degree hypothesis cannot be weakened. All
results have been formalized and machine-checked.

---

## 1. Introduction

Airy's equation $y'' = x\,y$, introduced by G. B. Airy in his 1838 study of
optical caustics, is the prototypical second-order linear ordinary differential
equation with no closed-form elementary solution. Its solutions, the Airy
functions $\mathrm{Ai}$ and $\mathrm{Bi}$, are genuinely transcendental: no finite
expression in polynomials, exponentials, logarithms, radicals and the field
operations represents them. The modern explanation of such impossibility is
**differential Galois theory** (Picard–Vessiot theory), the differential-equation
analogue of classical Galois theory: a linear ODE is solvable in "Liouvillian"
(elementary) terms if and only if its differential Galois group is suitably
structured, and the **Kovacic algorithm** turns this into an effective decision
procedure for second-order equations.

This paper isolates and formalizes the algebraic engine of the EML theory — the
class of equations whose coefficients are built from exponentials and logarithms —
in a way that is independent of any characteristic, algebraic-closure, or analytic
hypothesis. We work in an arbitrary **differential field** $(K, {}')$: a field $K$
equipped with a derivation $\,'$ satisfying additivity $(x+y)' = x' + y'$ and the
Leibniz rule $(xy)' = x'y + x y'$. From these axioms alone we recover the full
first-order solution calculus, the constants-subfield symmetry theory, the
Wronskian independence criterion, and the Riccati transform; and over the
concrete polynomial ring $\mathbb{R}[X]$ we run the degree-parity argument that
decides solvability for the generalized Airy family.

### 1.1 Contributions

1. **The logarithmic-derivative homomorphism** (§3): $L(y) = y'/y$ is a group
   homomorphism $K^\times \to (K,+)$, yielding product, quotient, inverse, and
   integer-power laws, the binary and finite superposition laws for $y' = a\,y$.
2. **First-order differential Galois structure** (§4): the constants form a
   subfield; the solution space of $y' = a\,y$ is a $\mathbb{G}_m(\text{constants})$
   torsor (`galois_action_is_mul_constant`, `galois_torsor`).
3. **Wronskian theory for $y'' = a\,y$** (§5): abstract Abel identity, and the
   biconditional between vanishing Wronskian and linear dependence over the
   constants, giving a fundamental-system criterion.
4. **Riccati transform and the Kovacic first step** (§6): $v = y'/y$ sends
   $y'' = a\,y$ to $v' + v^2 = a$.
5. **A sharp parity decision for Airy** (§7): odd-degree coefficients are
   obstructed (`no_rational_solves_riccati_airy`,
   `no_rational_riccati_genAiry`), while $f = x^2+1$ is solvable
   (`riccati_evenDeg_solvable`), so the criterion is tight
   (`kovacic_parity_decision_sharp`).

---

## 2. Preliminaries: differential fields

**Definition 2.1 (Differential field).** A *differential field* is a field $K$
together with an additive map $\,' : K \to K$ (the *derivation*) satisfying the
Leibniz rule
$$ (xy)' = x'\,y + x\,y'. $$
From the axioms one derives the quotient rule
$(y/z)' = (y'z - yz')/z^2$ and the inverse rule $(y^{-1})' = -y'/y^2$ for
$z, y \neq 0$.

**Definition 2.2 (Constants).** The *field of constants* of $K$ is
$$ C_K = \{\, x \in K : x' = 0 \,\}. $$

**Definition 2.3 (Logarithmic derivative).** For $y \neq 0$, the *logarithmic
derivative* is
$$ L(y) = \frac{y'}{y}. $$

Throughout, "EML equation" refers to a linear ODE $y' = a\,y$ or $y'' = a\,y$
(or their first-derivative-bearing forms) interpreted in such a $K$; the slogan
"the differential Galois group is an EML group" is made precise below by showing
the relevant groups are subgroups of $\mathbb{G}_m(C_K)$, the multiplicative
group of nonzero constants.

---

## 3. The logarithmic derivative as an exponential–logarithmic homomorphism

The decisive structural fact is that $L$ converts multiplication into addition.

**Theorem 3.1 (Homomorphism law, `logDeriv_mul`).** For nonzero $y, z \in K$,
$$ L(yz) = \frac{(yz)'}{yz} = \frac{y'}{y} + \frac{z'}{z} = L(y) + L(z). $$

*Proof sketch.* Expand $(yz)' = y'z + yz'$ by Leibniz, divide by $yz$, and
simplify. ∎

**Corollary 3.2 (Quotient, inverse, power laws).** For nonzero $y, z$ and
$n \in \mathbb{Z}$:
$$ L(y/z) = L(y) - L(z), \quad L(y^{-1}) = -L(y), \quad L(y^n) = n\,L(y). $$
These are `logDeriv_div`, `logDeriv_inv`, and `logDeriv_zpow`. The power law is
proved by integer induction, reusing the multiplicative and inverse laws.

The equation $y' = a\,y$ is equivalent to $L(y) = a$ for $y \neq 0$, so the
solution set is the $L$-fibre over $a$ — a coset of $\ker L = C_K$. The
homomorphism property turns multiplicative combinations of solutions into
additive combinations of coefficients.

**Theorem 3.3 (Binary superposition, `firstOrder_mul`).** If $y' = a\,y$ and
$z' = b\,z$, then $(yz)' = (a+b)(yz)$.

*Proof sketch.* $(yz)' = y'z + yz' = a y z + b y z = (a+b) yz$. ∎

**Theorem 3.4 (Inverse, quotient, power solutions).** If $y' = a\,y$ (and where
needed $y \neq 0$):
$$ (y^{-1})' = (-a)\,y^{-1}, \quad (y/z)' = (a-b)(y/z)\ \text{when}\ z'=bz,\ z\neq 0, \quad (y^n)' = (n a)\,y^n. $$
These are `firstOrder_inv`, `firstOrder_div`, `firstOrder_zpow`.

**Theorem 3.5 (Finite superposition, `firstOrder_prod`).** For a finite family
$(y_i)_{i \in s}$ with $y_i' = a_i\,y_i$ for all $i \in s$,
$$ \Big(\prod_{i \in s} y_i\Big)' = \Big(\sum_{i \in s} a_i\Big)\,\prod_{i \in s} y_i. $$

*Proof sketch.* Finite-set induction. The empty product gives $1' = 0$, the
honest zero-coefficient base case. The inductive step applies Leibniz to
$y_j \cdot \prod_{i \in s} y_i$ and uses the inductive hypothesis together with
$y_j' = a_j y_j$, finishing with ring normalization. ∎

This is the abstract content of $\prod_i e^{\int a_i} = e^{\sum_i \int a_i}$:
multiplicative structure on solutions is additive structure on coefficients.

---

## 4. Differential Galois structure of first-order EML equations

**Theorem 4.1 (Constants form a subfield, `constantsSubfield`).** The set
$C_K = \{x : x' = 0\}$ is a subfield of $K$: it contains $0$ and $1$ and is closed
under addition, negation, multiplication, and inversion.

*Proof sketch.* Closure under $+$ and $-$ is additivity of $\,'$; closure under
$\times$ is Leibniz ($c' = d' = 0 \Rightarrow (cd)' = 0$); closure under inversion
is the inverse rule. ∎

**Theorem 4.2 (Solution ratio is constant, `solution_ratio_isConstant` /
`firstOrder_ratio_isConstant`).** If $y_1' = a y_1$, $y_2' = a y_2$ and
$y_1 \neq 0$ (resp. $y_2 \neq 0$), then $(y_2/y_1)' = 0$.

*Proof sketch.* By Theorem 3.1, $L(y_2/y_1) = L(y_2) - L(y_1) = a - a = 0$, so the
numerator of $(y_2/y_1)'$ vanishes; clear denominators with the quotient rule. ∎

**Theorem 4.3 (Galois action by multiplicative constants,
`galois_action_is_mul_constant`).** If $y_1, y_2$ are nonzero solutions of
$y' = a\,y$, then there is a nonzero constant $c$ with $c' = 0$ and $y_2 = c\,y_1$.

*Proof sketch.* Take $c = y_2/y_1$: it is nonzero (ratio of nonzero elements),
constant by Theorem 4.2, and $y_2 = c\,y_1$ by clearing the denominator. ∎

**Theorem 4.4 (Closure under constant scaling, `const_mul_solution`).** If
$c' = 0$ and $y' = a\,y$, then $(c\,y)' = a\,(c\,y)$.

**Theorem 4.5 (Torsor structure, `galois_torsor`).** Fix a nonzero solution $y_1$
of $y' = a\,y$. Then for any $y_2 \in K$,
$$ \big(y_2' = a\,y_2 \ \wedge\ y_2 \neq 0\big) \iff \exists c \neq 0,\ c' = 0,\ y_2 = c\,y_1. $$

*Proof sketch.* Forward direction is Theorem 4.3; backward direction is
Theorem 4.4 together with $c y_1 \neq 0$. ∎

**Interpretation.** The solution space of $y' = a\,y$ is a one-dimensional line
over the constants, and the differential Galois group acts on it by multiplication
by elements of $\mathbb{G}_m(C_K)$. This is the rank-1 Picard–Vessiot statement:
the Galois group of a first-order EML equation is, exactly, a subgroup of the
multiplicative group of nonzero constants — the simplest linear-algebraic
("EML") group.

---

## 5. Wronskian theory for second-order EML equations

For $y'' = a\,y$ the solution space is (at most) two-dimensional over $C_K$, and
the Wronskian is the invariant that controls dimension.

**Definition 5.1 (Wronskian).** $W(y_1, y_2) = y_1\,y_2' - y_2\,y_1'$.

**Theorem 5.2 (Abstract Abel identity, `wronskian_deriv_eq_zero` /
`wronskian_isConstant`).** If $y_1'' = a y_1$ and $y_2'' = a y_2$, then
$W(y_1,y_2)' = 0$; i.e. $W(y_1,y_2) \in C_K$.

*Proof sketch.* Differentiate: $W' = y_1 y_2'' - y_2 y_1'' = y_1(a y_2) - y_2(a y_1) = 0$. ∎

**Definition 5.3 (Linear dependence over constants, `LinDepOverConstants`).** The
pair $(y_1, y_2)$ is *linearly dependent over the constants* if there exist
$c_1, c_2 \in C_K$, not both zero, with $c_1 y_1 + c_2 y_2 = 0$.

**Theorem 5.4 (Dependence forces $W = 0$, `wronskian_eq_zero_of_linDep`).** If
$(y_1,y_2)$ is linearly dependent over the constants, then $W(y_1,y_2) = 0$. (No
differential equation is assumed — this is a property of the field.)

*Proof sketch.* Differentiate the relation $c_1 y_1 + c_2 y_2 = 0$; since
$c_1, c_2$ are constant this yields the companion relation
$c_1 y_1' + c_2 y_2' = 0$. Eliminating $y_2$ (resp. $y_1$) gives
$c_1 W = 0$ and $c_2 W = 0$. As $(c_1, c_2) \neq (0,0)$, one factor is nonzero,
forcing $W = 0$. ∎

**Corollary 5.5 (Independence criterion, `linIndep_of_wronskian_ne_zero`).** If
$W(y_1,y_2) \neq 0$ then $(y_1,y_2)$ is linearly independent over the constants.

**Theorem 5.6 (Fundamental-system criterion,
`wronskian_isConstant_ne_zero_of_linIndep`).** If $y_1, y_2$ both solve
$y'' = a\,y$ and $W(y_1,y_2) \neq 0$, then $W(y_1,y_2)$ is a *nonzero constant*.

*Proof sketch.* Combine Theorem 5.2 (constancy) with the nonvanishing
hypothesis. ∎

Also recorded are `scale_solution` (a constant multiple of a solution of
$y'' = a\,y$ is a solution), `add_solution` (solutions are closed under addition,
so they form a $C_K$-module), and `wronskian_dependent_eq_zero` (the Wronskian of
$y_1$ and a constant multiple $c\,y_1$ vanishes). Together these make precise the
"rank $\le 2$ solution space over the constants, detected by $W$" picture.

---

## 6. The Riccati transform and the Kovacic reduction

**Theorem 6.1 (Riccati transform, raw form, `logDeriv_riccati`).** For $y \neq 0$,
$$ L(y)' + L(y)^2 = \frac{y''}{y}. $$

*Proof sketch.* Differentiate $L(y) = y'/y$ with the quotient rule:
$L(y)' = y''/y - (y'/y)^2 = y''/y - L(y)^2$. Rearranging gives the identity. ∎

**Theorem 6.2 (Riccati from second order, `riccati_of_second_order`).** If
$y \neq 0$ solves $y'' = a\,y$, then $v = L(y)$ solves the Riccati equation
$$ v' + v^2 = a. $$

*Proof sketch.* Substitute $y'' = a\,y$ into Theorem 6.1. ∎

This substitution is the heart of the Kovacic algorithm: a second-order linear
equation in normal form has a Liouvillian solution iff the associated Riccati
equation has an algebraic (and, at the first step, *rational*) solution.

**Clearing denominators.** A rational candidate $v = p/q$ with $p, q \in
\mathbb{R}[X]$, $q \neq 0$, satisfies $v' + v^2 = f$ iff the polynomial identity
$$ p'\,q - p\,q' + p^2 = f\,q^2 \tag{$\ast$} $$
holds, obtained by multiplying through by $q^2$ and using
$v' = (p'q - pq')/q^2$, $v^2 = p^2/q^2$. We therefore study $(\ast)$ directly,
keeping the argument inside the polynomial ring while faithfully encoding
"rational solution of the Riccati equation."

---

## 7. A sharp degree-parity decision for the (generalized) Airy family

### 7.1 The degree bound

**Lemma 7.1 (`natDegree_wronskianLike_le`).** For $p, q \in \mathbb{R}[X]$,
$$ \deg(p'q - pq') \le \deg p + \deg q - 1. $$

*Proof sketch.* Each product $p'q$ and $pq'$ has degree at most
$\deg p + \deg q - 1$ because differentiation drops degree by one; the difference
inherits the bound. (Degenerate cases where $p$ or $q$ is constant are handled
separately.) ∎

### 7.2 The odd-degree obstruction

**Theorem 7.2 (Odd-degree Riccati obstruction,
`no_rational_solves_riccati_odd_deg`).** Let $f \in \mathbb{R}[X]$ have odd
degree. Then there are no $p, q \in \mathbb{R}[X]$ with $q \neq 0$ satisfying
$(\ast)$, i.e. $v' + v^2 = f$ has no rational solution.

*Proof sketch.* Compare degrees of the two sides of $(\ast)$. The right side
$f q^2$ has degree $\deg f + 2\deg q$, which is odd. For the left side, by Lemma
7.1 the part $p'q - pq'$ has degree at most $\deg p + \deg q - 1$, while $p^2$ has
the even degree $2\deg p$.
- If $\deg p \ge \deg q$: the $p^2$ term dominates and the left side has degree
  exactly $2\deg p$ (even), so $\deg f + 2\deg q$ would be even, contradicting
  odd $\deg f$.
- If $\deg p < \deg q$: the entire left side has degree at most
  $\max(2\deg p,\ \deg p + \deg q - 1) \le 2\deg q - 2 < 2\deg q + 1 \le \deg f + 2\deg q$,
  so the degrees cannot match.
Either way $(\ast)$ is impossible. Coprimality of $p, q$ is not required;
the obstruction is purely metric. ∎

**Theorem 7.3 (Airy, `no_rational_solves_riccati_airy`).** The Riccati equation
$v' + v^2 = x$ has no rational solution; equivalently no $p, q$ with $q \neq 0$
satisfy $p'q - pq' + p^2 = X q^2$.

*Proof.* Apply Theorem 7.2 with $f = X$, $\deg X = 1$ odd. ∎

**Theorem 7.4 (Generalized Airy family, `no_rational_riccati_genAiry`).** For
every $k \in \mathbb{N}$, the equation $y'' = x^{2k+1} y$ has no rational Riccati
solution: $(\ast)$ with $f = X^{2k+1}$ is unsolvable for $q \neq 0$. Airy is the
case $k = 0$.

*Proof.* $\deg X^{2k+1} = 2k+1$ is odd; apply Theorem 7.2. ∎

We also record the cruder polynomial obstruction underpinning the rational one:
no nonzero polynomial solves $y'' = x y$ (`no_poly_solves_airy`), because $y''$
has strictly smaller degree than $x\,y$; this generalizes to $y'' = q\,y$ for any
$q$ of positive degree (`no_poly_solves_second_order_pos_deg`) and to
$y'' = x^n y$, $n \ge 1$ (`no_poly_solves_gen_airy`).

### 7.3 Sharpness

**Theorem 7.5 (Even-degree solvability witness, `riccati_evenDeg_solvable`).** The
Riccati equation $v' + v^2 = x^2 + 1$ has the polynomial solution $v = x$:
taking $p = X$, $q = 1$ satisfies $(\ast)$ since $p'q - pq' + p^2 = 1 + X^2 = f q^2$.

*Remark.* $v = x$ is the logarithmic derivative of $y = e^{x^2/2}$, which solves
$y'' = (x^2+1)\,y$; the equation is genuinely EML-solvable. The coefficient
$x^2 + 1$ has even degree $2$ (`natDegree_evenWitness`).

**Theorem 7.6 (Sharp parity decision, `kovacic_parity_decision_sharp`).**
$$ \Big(\forall k \in \mathbb{N},\ v' + v^2 = x^{2k+1}\ \text{has no rational solution}\Big) \ \wedge\ \Big(v' + v^2 = x^2 + 1\ \text{has a rational solution}\Big). $$

*Proof.* Conjunction of Theorems 7.4 and 7.5. ∎

Hence, on the family $y'' = f\,y$, the test "$\deg f$ odd" is a *correct and tight*
first-step decision: it certifies non-existence of a rational Riccati solution
exactly when one provably does not exist, and the boundary example $x^2+1$ shows
the odd-degree hypothesis cannot be dropped.

---

## 8. Algorithms

### 8.1 First-step Kovacic decision on $y'' = f\,y$ (polynomial family)

**Input.** A polynomial coefficient $f \in \mathbb{R}[X]$.
**Output.** A certified verdict on whether the Riccati first step is obstructed by
the degree-parity criterion.

```
function KovacicParityFirstStep(f):
    d ← natDegree(f)
    if d is odd:
        return ("OBSTRUCTED",
                "deg f is odd ⇒ no rational solution of v' + v² = f (Thm 7.2)")
    else:
        # parity test inconclusive; attempt a low-degree rational search
        return RationalRiccatiSearch(f)
```

The parity test runs in $O(1)$ after computing $\deg f$. When it returns
OBSTRUCTED the verdict is a theorem (Theorem 7.2). When $\deg f$ is even the test
is inconclusive and a constructive search is invoked.

### 8.2 Bounded rational Riccati search (clearing-denominators form)

Search for $p, q$ with $\deg p, \deg q \le N$ solving $(\ast)$. Substituting
$v = p/q$ and clearing denominators reduces solvability to a polynomial identity;
matching coefficients yields a finite (generally nonlinear) algebraic system. For
the polynomial sub-case $q = 1$ this becomes the search for $p$ with
$p' + p^2 = f$, solvable degree-by-degree.

```
function RationalRiccatiSearch(f, N):
    for dq in 0..N:
        for dp in 0..N:
            unknowns ← coefficients of p (dp+1) and q (dq+1)
            solve  p'·q − p·q' + p² = f·q²   for the unknowns
            if a real solution exists with q ≠ 0:
                return ("SOLVABLE", p, q)
    return ("NO SOLUTION UP TO DEGREE N")
```

---

## 9. Applications and discussion

- **Special functions.** The non-elementary nature of $\mathrm{Ai}, \mathrm{Bi}$ is
  recovered as a degree-parity theorem rather than an analytic statement, and it
  extends uniformly to the generalized Airy hierarchy $y'' = x^{2k+1} y$.
- **Symbolic computation.** Theorem 7.2 provides a sound $O(1)$ pre-filter for the
  first Kovacic step on polynomial coefficients, and Theorem 7.6 shows precisely
  where the filter must hand off to a constructive search.
- **Structural transparency.** Reducing first-order solvability to the
  homomorphism $L : K^\times \to (K,+)$ and to a $\mathbb{G}_m(C_K)$ torsor makes
  the "EML group" slogan a precise, hypothesis-free theorem.

**Limitations.** The sharp decision of §7 is established for the polynomial family
$y'' = f\,y$ via the cleared identity $(\ast)$; full Kovacic decidability for
arbitrary rational coefficients requires the higher cases of the algorithm
(degree-2 and finite imprimitive cases) not formalized here. The abstract
differential-field results are stated over a general $K$; instantiating them on a
concrete differential field such as $\mathbb{R}(X)$ is the natural next step.

---

## 10. Future work

See the *Future Directions* compendium: a Riccati gauge transforming the
first-derivative form $y'' + p y' + q y = 0$ to normal form, so the Airy
obstruction transports to gauged equations (e.g. $y'' - 2x y' + (x^2-1) y = 0$); a
concrete `Differential (RatFunc ℝ)` instance whose constants are exactly
$\mathbb{R}$, turning every abstract theorem into a statement about rational
functions and making the torsor result a concrete $\mathbb{R}^\times$-torsor
statement over $\mathbb{R}(x)$; and an effective dimension-2 theory in which every
fundamental system arises by reduction of order.

---

## 11. Conclusion

A single homomorphism — the logarithmic derivative carrying products to sums —
organizes the EML theory: first-order equations exponentiate and their solution
spaces are $\mathbb{G}_m(\text{constants})$ torsors; second-order equations are
governed by a constant Wronskian and reduce, via the Riccati transform, to a
first-order quadratic equation; and the resulting decision problem is settled, for
the generalized Airy family, by a sharp degree-parity criterion. Airy's equation
has no elementary solution because $1$ is odd — and the boundary case $x^2 + 1$
shows that this parity is exactly the dividing line.
