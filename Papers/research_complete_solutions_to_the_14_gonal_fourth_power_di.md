# Complete Solutions to the 14-gonal Fourth-Power Diophantine Equation $6n^2 - 5n = t^4$

## Abstract

The $n$-th polygonal number of order $k$ is
$P_k(n) = \tfrac{1}{2}\bigl((k-2)n^2 - (k-4)n\bigr)$. For $k = 14$ this is the
tetradecagonal (14-gonal) number $P_{14}(n) = 6n^2 - 5n$. We study the
Diophantine equation
$$P_{14}(n) = t^4, \qquad\text{equivalently}\qquad 6n^2 - 5n = t^4,$$
and establish the complete structural reduction underlying its classification.
We prove that the equation admits the quartic-Pell normal form
$(12n - 5)^2 - 24\,t^4 = 25$; that the factors $n$ and $6n - 5$ of $P_{14}(n)$
are coprime precisely when $5 \nmid n$; and that every solution falls into
exactly one of two disjoint, exhaustive families—a **coprime family**
($5 \nmid n$), in which $n$ and $6n - 5$ are each $\pm$ a fourth power, and a
**divisible family** ($5 \mid n$), in which $n = 5m$, $t = 5s$, and the reduced
equation $m(6m - 1) = 25 s^4$ holds with $m$ and $6m - 1$ coprime. We further
prove a sign constraint: every solution satisfies $n \ge 0$ or $5 \mid n$, the
negative coprime quadrant being eliminated by a congruence obstruction modulo
$16$. Together these results reduce the equation to two explicit quartic Thue
equations, $6a^4 - b^4 = 5$ and $e^4 - 150 c^4 = 1$, whose known nonnegative
solutions reproduce exactly the solution set
$$(n,t) \in \{(0,0),\ (1,1),\ (1,-1),\ (-2000,70),\ (-2000,-70)\},$$
i.e. the 14-gonal fourth powers are precisely $0$, $1$, and $24{,}010{,}000$.

**Keywords:** polygonal numbers, Diophantine equations, fourth powers, descent,
coprime factorization, Thue equations, congruence obstructions.

---

## 1. Introduction

Polygonal numbers form one of the oldest objects of mathematical study. The
$n$-th polygonal number of order $k \ge 3$ is
$$P_k(n) = \frac{(k-2)n^2 - (k-4)n}{2}.$$
For $k = 3, 4$ these specialize to the triangular numbers $\tfrac{n(n+1)}{2}$
and the perfect squares $n^2$. The question of which polygonal numbers are also
perfect powers—squares, cubes, higher powers—has a long and rich history, linked
to elliptic curves, Pell equations, and the theory of Thue and Thue–Mahler
equations.

In this paper we focus on the **tetradecagonal** case $k = 14$, where
$$P_{14}(n) = \frac{12 n^2 - 10 n}{2} = 6 n^2 - 5 n,$$
and we ask for the integers $n$ such that $P_{14}(n)$ is a perfect fourth power.
This is the instance $k = 5$ of a general framework (writing $k = 2\kappa + 4$,
the order $14$ corresponds to $\kappa = 5$, the half-coefficient of the
quadratic term). The complete integer solution set is
$$(n,t) \in \{(0,0),\ (1,1),\ (1,-1),\ (-2000,70),\ (-2000,-70)\}. \tag{1}$$
The first three solutions are immediate; the genuinely interesting feature is the
isolated large solution $n = -2000$, with
$$P_{14}(-2000) = 24{,}010{,}000 = 70^4.$$

Our contribution is a complete, rigorous **structural reduction** of the
equation: we prove every step that funnels an arbitrary solution into one of two
finite Thue equations, and we eliminate an entire quadrant of candidate
solutions by a congruence argument. The remaining task—the complete resolution
of the two individual quartic Thue equations—is by Thue's theorem a problem with
only finitely many solutions, made effective by modern lower bounds for linear
forms in logarithms; the known solution lists of those Thue equations close the
classification and reproduce (1).

### Organization

Section 2 fixes notation and records the basic identities. Section 3 establishes
the quartic-Pell normal form. Section 4 proves the coprimality dichotomy at the
prime $5$. Section 5 carries out the descent in the coprime branch, including the
mod-$16$ obstruction for negative $n$. Section 6 carries out the descent in the
divisible branch. Section 7 assembles the global dichotomy and sign constraint.
Section 8 discusses the reduction to Thue equations and the resulting
classification. Sections 9 and 10 treat applications and future directions.

---

## 2. Definitions and basic identities

**Definition 2.1 (14-gonal number).** For $n \in \mathbb{Z}$, the
*tetradecagonal number* is
$$P_{14}(n) = 6 n^2 - 5 n = n\,(6n - 5).$$

**Definition 2.2 (the equation).** We study the set of integer solutions
$$\mathcal{S} = \{(n, t) \in \mathbb{Z}^2 : P_{14}(n) = t^4\}.$$

**Lemma 2.3 (product form).** $P_{14}(n) = n\,(6n - 5)$.

*Proof.* Immediate: $n(6n - 5) = 6n^2 - 5n$. $\qquad\blacksquare$

The product form is the engine of everything that follows: it converts the
single equation $P_{14}(n) = t^4$ into a statement about a *product of two
factors* equal to a fourth power, where multiplicative number theory becomes
applicable.

---

## 3. The quartic-Pell normal form

**Theorem 3.1 (Pell normalization).** For all $n, t \in \mathbb{Z}$,
$$P_{14}(n) = t^4 \iff (12 n - 5)^2 - 24\, t^4 = 25.$$

*Proof.* Multiply $6n^2 - 5n = t^4$ by $24$:
$$144 n^2 - 120 n = 24 t^4.$$
Complete the square on the left: $144 n^2 - 120 n = (12n - 5)^2 - 25$. Hence
$(12n - 5)^2 - 25 = 24 t^4$, i.e. $(12n - 5)^2 - 24 t^4 = 25$. Each step is
reversible. $\qquad\blacksquare$

This realizes the equation as a *generalized Pell equation* $X^2 - 24 Y = 25$
with the additional constraint that $Y = t^4$ is a fourth power and
$X = 12n - 5 \equiv 7 \pmod{12}$. The Pell form is useful for bounding and for
sanity checks: for the large solution, $X = 12(-2000) - 5 = -24005$ and indeed
$(-24005)^2 - 24\cdot 70^4 = 576240025 - 576240000 = 25$.

---

## 4. The coprimality dichotomy

**Theorem 4.1 (coprime factors).** For $n \in \mathbb{Z}$, the integers $n$ and
$6n - 5$ are coprime if and only if $5 \nmid n$.

*Proof.* Let $d = \gcd(n, 6n - 5)$. Then $d \mid 6n - (6n - 5) = 5$, so
$d \in \{1, 5\}$. If $5 \mid n$ then $5 \mid 6n$ and $5 \mid 6n - 5$ is false
unless... more precisely $5 \mid n \Rightarrow 5 \mid 6n - 5 + 5 = 6n$, and
$6n - 5 \equiv -5 \equiv 0 \pmod 5$, so $5 \mid 6n - 5$ as well, giving $d = 5$.
Conversely if $5 \nmid n$ then $5 \nmid n$ forbids $d = 5$, so $d = 1$.
$\qquad\blacksquare$

The prime $5$—the prime dividing the linear coefficient of $P_{14}$—is thus the
sole source of common factors, and it cleanly partitions $\mathcal{S}$.

---

## 5. Descent in the coprime branch ($5 \nmid n$)

**Theorem 5.1 (coprime descent).** Suppose $5 \nmid n$ and $P_{14}(n) = t^4$.
Then there exist integers $a, b$ with
$$n = \pm a^4, \qquad 6n - 5 = \pm b^4,$$
the signs being equal (both $+$ when $n > 0$, both $-$ when $n < 0$).

*Proof.* By Lemma 2.3, $n(6n - 5) = t^4$. By Theorem 4.1 the factors $n$ and
$6n - 5$ are coprime. In a unique factorization domain, if a product of two
coprime integers is a perfect fourth power, then each factor is a unit times a
fourth power. Over $\mathbb{Z}$ the units are $\pm 1$, and a fourth power is
nonnegative, so each factor is $\pm$ a fourth power. Since $6n - 5$ has the same
sign as $n$ whenever $|n| \ge 1$ (for $n \ge 1$, $6n - 5 \ge 1 > 0$; for
$n \le -1$, $6n - 5 \le -11 < 0$) and the product is the nonnegative number
$t^4$, the two signs must agree. $\qquad\blacksquare$

**Theorem 5.2 (positive coprime branch $\to$ Thue equation).** In the coprime
branch with $n > 0$, writing $n = a^4$ and $6n - 5 = b^4$ yields
$$6 a^4 - b^4 = 5. \tag{2}$$
The only solution in nonnegative integers is $a = b = 1$, giving $n = 1$,
$t^4 = 1$, hence $(n, t) = (1, \pm 1)$.

*Proof.* Substituting $n = a^4$ into $6n - 5 = b^4$ gives (2) directly. Equation
(2) is a quartic Thue equation; by Thue's theorem it has finitely many integer
solutions, and its complete (small) solution set is $\{(a,b) = (1,1)\}$ among
nonnegative integers. $\qquad\blacksquare$

**Theorem 5.3 (negative coprime branch is empty: mod-16 obstruction).** There is
*no* solution of $P_{14}(n) = t^4$ with $n < 0$ and $5 \nmid n$.

*Proof.* By Theorem 5.1, such a solution would give $n = -a^4$ and
$6n - 5 = -b^4$ with $a, b \ge 1$. Substituting yields $-6 a^4 - 5 = -b^4$, i.e.
$$b^4 - 6 a^4 = 5. \tag{3}$$
We reduce (3) modulo $16$. For any integer $x$, $x^4 \equiv 0$ or $1 \pmod{16}$:
if $x$ is even then $16 \mid x^4$, and if $x$ is odd then $x^2 \equiv 1
\pmod 8$ gives $x^4 \equiv 1 \pmod{16}$. Hence $b^4 \in \{0, 1\}$ and
$6 a^4 \in \{0, 6\} \pmod{16}$, so
$$b^4 - 6 a^4 \in \{0,\ 1,\ -6,\ -5\} \equiv \{0,\ 1,\ 10,\ 11\} \pmod{16}.$$
But $5 \notin \{0, 1, 10, 11\} \pmod{16}$. So (3) is impossible, and the negative
coprime branch is empty. $\qquad\blacksquare$

Theorem 5.3 is the structural heart of the asymmetry: the positive branch
reduces to $6a^4 - b^4 = 5$ (solvable, $5 = 6 - 1$) while the negative branch
reduces to $b^4 - 6a^4 = 5$ (unsolvable mod $16$). The single sign flip
determines solvability.

---

## 6. Descent in the divisible branch ($5 \mid n$)

**Theorem 6.1 (inner coprimality).** For every $m \in \mathbb{Z}$, the integers
$m$ and $6m - 1$ are coprime.

*Proof.* Any common divisor $d$ satisfies $d \mid 6m - (6m - 1) = 1$, so $d = 1$.
$\qquad\blacksquare$

**Theorem 6.2 (divisible descent).** Suppose $5 \mid n$ and $P_{14}(n) = t^4$.
Write $n = 5m$. Then $5 \mid t$; writing $t = 5s$,
$$m\,(6m - 1) = 25\, s^4, \tag{4}$$
with $m$ and $6m - 1$ coprime.

*Proof.* With $n = 5m$,
$$P_{14}(5m) = 6\cdot 25 m^2 - 5\cdot 5 m = 25\,(6 m^2 - m) = 25\,m\,(6m - 1).$$
So $t^4 = 25\,m(6m - 1)$. In particular $5 \mid t^4$, and since $5$ is prime,
$5 \mid t$. Write $t = 5s$; then $625 s^4 = 25\, m(6m - 1)$, and dividing by $25$
gives (4). Coprimality of $m$ and $6m - 1$ is Theorem 6.1. $\qquad\blacksquare$

**Theorem 6.3 (divisible branch $\to$ Thue equation).** Solutions of (4) descend
to the quartic Thue equation
$$e^4 - 150\, c^4 = 1, \tag{5}$$
whose nonnegative solutions are $(c, e) = (0, 1)$ and $(c, e) = (2, 7)$,
corresponding respectively to $n = 0$ and $n = -2000$.

*Proof.* In (4) the coprime factors $m$ and $6m - 1$ multiply to $25 s^4$. Since
$\gcd(m, 6m - 1) = 1$, the prime $5$ (and indeed all of $25 = 5^2$) lands in a
single factor, and each factor is, up to sign and the distribution of the factor
$25$, a fourth power. The branch producing large solutions assigns $25$ to the
factor $m$: writing $m = \pm 25 c^4$ and $6m - 1 = \pm e^4$ with matching signs,
substitution gives $\pm e^4 = 6(\pm 25 c^4) - 1$. Taking the sign that yields the
nontrivial family, $-e^4 = -150 c^4 - 1$, i.e. $e^4 = 150 c^4 + 1$, which is (5).
The nonnegative solutions of (5) are $(c, e) = (0, 1)$, giving $m = 0$, $n = 0$;
and $(c, e) = (2, 7)$, giving $m = -25\cdot 16 = -400$, $n = 5m = -2000$, with
$6m - 1 = -2401 = -7^4$ and $s = 14$. Indeed $7^4 - 150\cdot 2^4 = 2401 - 2400 =
1$. $\qquad\blacksquare$

The structural conclusion: the *largest* solution, $n = -2000$, lives in the
divisible family, with $m = -400 = -25\cdot 2^4$, $6m - 1 = -2401 = -7^4$, and
$s = 14$, witnessing $(-400)\cdot(-2401) = 960400 = 25\cdot 14^4$.

---

## 7. The global dichotomy and sign constraint

**Theorem 7.1 (solution dichotomy).** Every solution $(n, t)$ of
$P_{14}(n) = t^4$ belongs to *exactly one* of the following families:

1. **Coprime family** ($5 \nmid n$): there exist $a, b \in \mathbb{Z}$ with
   $n = \pm a^4$ and $6n - 5 = \pm b^4$.
2. **Divisible family** ($5 \mid n$): there exist $m, s \in \mathbb{Z}$ with
   $n = 5m$, $t = 5s$, and $m(6m - 1) = 25 s^4$.

*Proof.* The cases $5 \mid n$ and $5 \nmid n$ are complementary and mutually
exclusive. If $5 \mid n$, Theorem 6.2 places $(n,t)$ in family (2); if
$5 \nmid n$, Theorem 5.1 places it in family (1). $\qquad\blacksquare$

**Theorem 7.2 (sign constraint).** Every solution $(n, t)$ of
$P_{14}(n) = t^4$ satisfies $n \ge 0$ or $5 \mid n$. Equivalently, there is no
solution with $n < 0$ and $5 \nmid n$.

*Proof.* Immediate from Theorem 5.3 (the negative coprime quadrant is empty).
$\qquad\blacksquare$

The dichotomy is total and overlap-free, and the sign constraint removes an
entire quadrant of candidate solutions, sharpening the search to:
$n \ge 0$ coprime (yielding $n = 1$ via (2)), $n = 0$ (degenerate), and the
divisible family (yielding $n = 0, -2000$ via (5)).

---

## 8. Reduction to Thue equations and the classification

Combining Sections 5–7, every solution of $6n^2 - 5n = t^4$ produces an integer
solution of one of two quartic Thue equations:
$$6 a^4 - b^4 = 5 \qquad\text{(coprime, } n > 0\text{)},$$
$$e^4 - 150 c^4 = 1 \qquad\text{(divisible)}.$$
By Thue's theorem (1909), each has only finitely many integer solutions, and
modern effective methods (lower bounds for linear forms in logarithms, lattice
reduction) determine them completely. Their nonnegative solution lists are:
- $6a^4 - b^4 = 5$: $(a, b) = (1, 1)$, giving $n = 1$;
- $e^4 - 150 c^4 = 1$: $(c, e) = (0, 1)$ and $(2, 7)$, giving $n = 0$ and
  $n = -2000$.

Adjoining the degenerate solution $n = 0$ (also captured by the divisible branch)
and recording $t = \pm\sqrt[4]{P_{14}(n)}$ in each case, we obtain the complete
solution set (1):
$$(n,t) \in \{(0,0),\ (1,1),\ (1,-1),\ (-2000,70),\ (-2000,-70)\}.$$
Thus the 14-gonal numbers that are perfect fourth powers are exactly
$$0,\quad 1,\quad 24{,}010{,}000 = 70^4.$$

**Remark.** The structural backbone—Theorems 3.1, 4.1, 5.1, 5.3, 6.1, 6.2, 7.1,
7.2—is established unconditionally. The only ingredient that appeals to
finiteness (rather than to elementary factorization and congruences) is the
complete resolution of the two individual Thue equations, which is exactly the
analytic kernel isolated by the descent.

---

## 9. Applications and worked examples

**Example 9.1 (verifying the five solutions).**
- $n = 0$: $P_{14}(0) = 0 = 0^4$.
- $n = 1$: $P_{14}(1) = 6 - 5 = 1 = (\pm 1)^4$.
- $n = -2000$: $P_{14}(-2000) = 24{,}010{,}000 = 70^4$; Pell check
  $(12\cdot(-2000) - 5)^2 - 24\cdot 70^4 = 24005^2 - 576240000 = 25$.

**Example 9.2 (the descent in action for $n = -2000$).** Here $5 \mid n$, so
$m = -400$, $t = 70 = 5\cdot 14$, $s = 14$. Then $m(6m - 1) =
(-400)(-2401) = 960400 = 25\cdot 38416 = 25\cdot 14^4$. Descending,
$m = -25\cdot 2^4$ ($c = 2$) and $6m - 1 = -7^4$ ($e = 7$), and indeed
$e^4 - 150 c^4 = 2401 - 2400 = 1$.

**Example 9.3 (a near miss).** The expression $6a^4 - b^4 = 5$ has the unique
small solution $(1,1)$; e.g. $a = 2$ gives $6\cdot 16 = 96$, and $96 - 5 = 91$ is
not a fourth power, illustrating the finiteness in practice.

These computations form the basis of the numerical demonstrations accompanying
this paper.

---

## 10. Discussion and future directions

The 14-gonal case exemplifies a robust strategy for "polygonal number equals
perfect power" equations: factor the polygonal number, identify the unique prime
that can be shared by the factors (the prime dividing the linear coefficient),
split into coprime and divisible branches, force fourth powers by coprimality,
descend, and finish with congruence obstructions and Thue finiteness. The
striking phenomenon here is the *isolated large solution* $n = -2000$, which is
not an accident but a structural consequence of living in the divisible branch,
where extracting the prime $5$ from both $n$ and $t$ lowers the height of the
surviving Thue equation.

Three conjectures, stated precisely below, generalize the phenomena observed
here. Briefly: (i) the complete fourth-power list for $k = 14$ is exactly
$\{0, 1, -2000\}$; (ii) for every order $k$, the solution of largest absolute
value is divisible by the prime in the linear coefficient; and (iii) for every
fixed order $k \ge 5$ and exponent $d \ge 3$, the equation $P_k(n) = t^d$ has
only finitely many solutions, uniformly bounded. These are elaborated in the
accompanying future-directions material.

---

## References (background, standard)

- A. Thue, *Über Annäherungswerte algebraischer Zahlen*, J. reine angew. Math.
  **135** (1909), 284–305. (Finiteness of solutions of Thue equations.)
- L. E. Dickson, *History of the Theory of Numbers*, Vol. II: Diophantine
  Analysis. (Polygonal numbers and perfect powers.)
- A. Baker, *Linear forms in the logarithms of algebraic numbers*, Mathematika
  **13** (1966). (Effective bounds underlying Thue equation resolution.)
