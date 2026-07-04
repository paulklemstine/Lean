# Residue-Class Monotonicity of the Minimal Modulus of Sums of Fifth Roots of Unity

## Abstract

Let $\zeta = e^{2\pi i/5}$ be the standard primitive fifth root of unity. For a
natural number $n$, define $\sigma_5(n)$ to be the infimum of $\left|\sum_{j=1}^n
\zeta^{c_j}\right|$ taken over all choices of exponents $c_1, \dots, c_n \in
\mathbb{N}$; equivalently, $\sigma_5(n)$ is the least modulus of a nonnegative
integer combination $\sum_{r=0}^4 a_r \zeta^r$ with $\sum_r a_r = n$. We prove
that for every residue $r \in \{0,1,2,3,4\}$ the sequence $k \mapsto \sigma_5(5k +
r)$ is non-increasing:
$$\sigma_5\bigl(5(k+1)+r\bigr) \le \sigma_5(5k + r)\qquad\text{for all }k \in \mathbb{N}.$$
The proof rests on a single structural identity, $1 + \zeta + \zeta^2 + \zeta^3 +
\zeta^4 = 0$, which permits appending a complete, value-preserving block of five
roots to any configuration. This yields a nested chain of feasible sets and hence
monotonicity of infima. We situate the result within the arithmetic of the golden
field $\mathbb{Q}(\sqrt5) \subset \mathbb{Q}(\zeta)$, exhibit the exact values and
their eventual plateaus, give a lattice / closest-vector reformulation, and record
the general statement for $m$-th roots of unity. Numerical tables corroborate every
claim.

---

## 1. Introduction

Sums of roots of unity — the values $\sum_j \zeta^{c_j}$ for $\zeta$ a root of
unity — are among the most ubiquitous objects in mathematics. They are the
characters of finite cyclic groups, the kernels of the discrete Fourier transform,
and, through Gauss and Jacobi sums, central to analytic and algebraic number
theory. A recurring theme is *cancellation*: how small can such a sum be made, and
what algebraic constraints govern the smallest attainable modulus? This paper
studies the cleanest one-parameter version of that question for the fifth roots of
unity and establishes a monotonicity law along residue classes.

Fix $\zeta = e^{2\pi i/5}$, a primitive fifth root of unity, so that $\zeta^5 = 1$
and the powers $1, \zeta, \zeta^2, \zeta^3, \zeta^4$ are the five vertices of a
regular pentagon inscribed in the unit circle. Given a budget of $n$ summands, we
ask how close to $0$ a sum of $n$ such powers can be. The resulting quantity,
$\sigma_5(n)$, is a discrete optimization value; our main theorem shows that it
behaves monotonically once the domain is stratified by residue modulo $5$.

The engine of the argument is elementary but decisive: the five roots sum to zero.
This lets us pad any configuration with a full, balanced block of five roots
without changing its value, so the feasible set of moduli only grows as the budget
increases by five. The infimum of a growing family of sets can only decrease,
giving the monotonicity at once. The mechanism uses nothing about $5$ beyond the
vanishing of the complete root sum, so the entire development generalizes verbatim
to the $m$-th roots of unity.

### Contributions

1. A precise definition of the minimal-modulus function $\sigma_5$ as an infimum
   over all exponent sequences, together with its basic well-posedness
   (nonnegativity, bounded-below and nonempty feasible set).
2. A **one-step monotonicity** theorem: $\sigma_5(n + 5) \le \sigma_5(n)$ for all
   $n$.
3. The **residue-class monotonicity** theorem: for each $r$, $k \mapsto
   \sigma_5(5k + r)$ is non-increasing (antitone).
4. Exact evaluation of the small cases in the golden field
   $\mathbb{Q}(\sqrt5)$, identification of the residue-class plateaus, and a
   lattice / closest-vector reformulation.
5. The general statement for arbitrary modulus $m$.

---

## 2. Definitions and basic properties

Throughout, $\mathbb{N} = \{0, 1, 2, \dots\}$ and $\zeta = e^{2\pi i/5} \in
\mathbb{C}$.

### 2.1 The primitive fifth root of unity

**Definition 2.1.** Let $\zeta = e^{2\pi i/5} = \cos\tfrac{2\pi}{5} + i
\sin\tfrac{2\pi}{5}$.

**Proposition 2.2 (Order five).** $\zeta$ is a primitive fifth root of unity;
in particular $\zeta^5 = 1$ and $\zeta^j \neq 1$ for $1 \le j \le 4$.

*Proof.* Immediate from $\zeta^5 = e^{2\pi i} = 1$ and the fact that
$e^{2\pi i j/5} = 1$ forces $5 \mid j$. $\square$

**Proposition 2.3 (Complete root sum vanishes).**
$$\sum_{i=0}^{4} \zeta^i = 0.$$

*Proof.* Since $\zeta \ne 1$ and $\zeta^5 = 1$, the geometric sum gives
$\sum_{i=0}^4 \zeta^i = \frac{\zeta^5 - 1}{\zeta - 1} = \frac{0}{\zeta - 1} = 0$.
Equivalently, $\zeta$ is a root of the fifth cyclotomic polynomial $x^4 + x^3 +
x^2 + x + 1$. $\square$

**Proposition 2.4 (Order-five exponent reduction).** For every $n \in \mathbb{N}$,
$$\zeta^n = \zeta^{\,n \bmod 5}.$$

*Proof.* Write $n = 5q + (n \bmod 5)$. Then $\zeta^n = (\zeta^5)^q \cdot
\zeta^{\,n\bmod 5} = 1^q \cdot \zeta^{\,n\bmod 5} = \zeta^{\,n\bmod 5}$. $\square$

Proposition 2.4 is the multiplicative order-$5$ analogue, for powers of $\zeta$,
of the additive congruence $a^5 \equiv a \pmod 5$: exponents of $\zeta$ live in
$\mathbb{Z}/5\mathbb{Z}$. In particular, any sum $\sum_{j=1}^n \zeta^{c_j}$ depends
only on the residues $c_j \bmod 5$, and is therefore equal to a *canonical form*
$$\sum_{r=0}^{4} a_r\, \zeta^r,\qquad a_r \in \mathbb{N},\qquad \sum_{r=0}^4 a_r = n,$$
where $a_r$ counts how many summands have exponent congruent to $r$.

### 2.2 The feasible set and the minimal-modulus function

**Definition 2.5 (Feasible modulus set).** For $n \in \mathbb{N}$, let
$$\mathcal{A}_5(n) = \left\{\; \Bigl|\sum_{j=1}^{n} \zeta^{c_j}\Bigr| \;:\; c \colon \{1,\dots,n\} \to \mathbb{N} \;\right\} \subseteq \mathbb{R}_{\ge 0}.$$
This is the set of all moduli attainable by a sum of exactly $n$ powers of $\zeta$.

**Definition 2.6 (Minimal modulus).** The *minimal modulus of a sum of $n$ fifth
roots of unity* is
$$\sigma_5(n) = \inf \mathcal{A}_5(n).$$

**Lemma 2.7 (Well-posedness).** For every $n$:
1. every element of $\mathcal{A}_5(n)$ is $\ge 0$;
2. $\mathcal{A}_5(n)$ is bounded below (by $0$);
3. $\mathcal{A}_5(n)$ is nonempty;
4. consequently $\sigma_5(n)$ exists and $\sigma_5(n) \ge 0$.

*Proof.* (1) Moduli are nonnegative. (2) is immediate from (1). (3) Take all
exponents equal to $0$; then $\sum_j \zeta^0 = n \in \mathcal{A}_5(n)$. (4) The
infimum of a nonempty set bounded below exists in $\mathbb{R}$, and is $\ge 0$
because every element is. $\square$

Because $\mathcal{A}_5(n)$ is determined by the finitely many canonical forms
$\sum_r a_r \zeta^r$ with $\sum_r a_r = n$, the set is in fact finite and the
infimum is attained: $\sigma_5(n) = \min \mathcal{A}_5(n)$. We keep the infimum
formulation because it makes the monotonicity proof frictionless.

**Example 2.8.** $\sigma_5(0) = 0$ (empty sum). $\sigma_5(1) = 1$ (a single unit
vector). For $n = 2$, the choice $1 + \zeta^2$ has modulus $2\cos\tfrac{2\pi}{5} =
\tfrac{\sqrt5 - 1}{2} = \varphi^{-1}$, and no smaller value is possible, so
$\sigma_5(2) = \varphi^{-1} \approx 0.618034$, where $\varphi = \tfrac{1+\sqrt5}{2}$.

---

## 3. The one-step monotonicity theorem

The heart of the paper is the following.

**Theorem 3.1 (One-step monotonicity).** For every $n \in \mathbb{N}$,
$$\sigma_5(n + 5) \le \sigma_5(n).$$

*Proof.* It suffices to show $\mathcal{A}_5(n) \subseteq \mathcal{A}_5(n+5)$; the
inequality of infima then follows because the infimum of a larger set is no
larger.

Let $d \in \mathcal{A}_5(n)$. By definition there is an exponent function
$c \colon \{1, \dots, n\} \to \mathbb{N}$ with $d = \bigl|\sum_{j=1}^n
\zeta^{c_j}\bigr|$; write $S = \sum_{j=1}^n \zeta^{c_j}$. Extend $c$ to a function
$c' \colon \{1, \dots, n+5\} \to \mathbb{N}$ by appending the five exponents
$0, 1, 2, 3, 4$:
$$c'_j = \begin{cases} c_j, & 1 \le j \le n,\\ j - n - 1, & n+1 \le j \le n+5.\end{cases}$$
Then, using Proposition 2.3,
$$\sum_{j=1}^{n+5} \zeta^{c'_j} = S + \sum_{i=0}^{4} \zeta^{i} = S + 0 = S.$$
Hence $d = |S| \in \mathcal{A}_5(n+5)$. As $d$ was arbitrary,
$\mathcal{A}_5(n) \subseteq \mathcal{A}_5(n+5)$. $\square$

The move in the proof — appending the balanced block $\{0,1,2,3,4\}$ of exponents
— is *value-preserving* precisely because the complete set of roots sums to zero.
It costs five summands and changes nothing else, which is exactly the freedom we
exploit.

---

## 4. Residue-class monotonicity

We now stratify $\mathbb{N}$ by residue modulo $5$. Every $n$ is uniquely $n = 5k
+ r$ with $r \in \{0,1,2,3,4\}$ and $k \in \mathbb{N}$.

**Theorem 4.1 (Residue single step).** For all $r, k \in \mathbb{N}$,
$$\sigma_5\bigl(5(k+1) + r\bigr) \le \sigma_5(5k + r).$$

*Proof.* Since $5(k+1) + r = (5k + r) + 5$, this is Theorem 3.1 applied at
$n = 5k + r$. $\square$

**Theorem 4.2 (Residue-class monotonicity).** For each fixed $r \in
\{0,1,2,3,4\}$, the sequence
$$k \longmapsto \sigma_5(5k + r)$$
is non-increasing (antitone) on $\mathbb{N}$.

*Proof.* A sequence $f \colon \mathbb{N} \to \mathbb{R}$ is non-increasing iff
$f(k+1) \le f(k)$ for all $k$. This is exactly Theorem 4.1 with $f(k) =
\sigma_5(5k+r)$. $\square$

**Corollary 4.3 (Convergence of each class).** For each $r$, the sequence
$k \mapsto \sigma_5(5k + r)$ is non-increasing and bounded below by $0$, hence
converges to a limit $L_r \ge 0$.

*Proof.* A non-increasing sequence bounded below converges to its infimum by the
monotone convergence theorem for real sequences. $\square$

**Remark 4.4 (The residue-$0$ class is identically zero).** For $r = 0$ we have
$\sigma_5(5k) = 0$ for all $k$: laying down $k$ complete balanced blocks yields
$\sum_{t=1}^{k}\sum_{i=0}^4 \zeta^i = 0$, so $0 \in \mathcal{A}_5(5k)$ and, by
nonnegativity, $\sigma_5(5k) = 0$. Thus $L_0 = 0$.

---

## 5. Exact values, plateaus, and the golden field

The nonzero values of $\sigma_5$ are not arbitrary reals; they are algebraic
integers of the field $\mathbb{Q}(\zeta)$, and in fact lie in its real subfield
$\mathbb{Q}(\zeta) \cap \mathbb{R} = \mathbb{Q}(\sqrt5)$, the *golden field*
generated by $\varphi = \tfrac{1 + \sqrt5}{2}$. This is because
$|\sum_r a_r \zeta^r|^2 = \bigl(\sum_r a_r \zeta^r\bigr)\overline{\bigl(\sum_r a_r
\zeta^r\bigr)}$ is a symmetric integer combination of the real quantities
$\zeta^s + \zeta^{-s} = 2\cos\tfrac{2\pi s}{5}$, and $2\cos\tfrac{2\pi}{5} =
\varphi^{-1}$, $2\cos\tfrac{4\pi}{5} = -\varphi$.

### 5.1 Table of values

The following table lists $\sigma_5(n)$ for $0 \le n \le 15$, arranged so that
each row is one residue class read in steps of five (the residue $r$ is the row
index; column $k$ shows $\sigma_5(5k + r)$).

| $r \backslash k$ | $k=0$ | $k=1$ | $k=2$ | $k=3$ |
|---|---|---|---|---|
| $0$ | $0$ | $0$ | $0$ | $0$ |
| $1$ | $1$ | $\varphi^{-2}\approx 0.381966$ | $\varphi^{-4}\approx 0.145898$ | — |
| $2$ | $\varphi^{-1}\approx 0.618034$ | $\sqrt5-2\approx 0.236068$ | $\sqrt5-2\approx 0.236068$ | — |
| $3$ | $\varphi^{-1}\approx 0.618034$ | $\sqrt5-2\approx 0.236068$ | $\sqrt5-2\approx 0.236068$ | — |
| $4$ | $\varphi^{-2}\approx 0.381966$ | $\varphi^{-2}\approx 0.381966$ | $\varphi^{-4}\approx 0.145898$ | — |

Every row is non-increasing, in agreement with Theorem 4.2. The recurring
constants are
$$\varphi^{-1} = \tfrac{\sqrt5 - 1}{2},\quad \varphi^{-2} = \tfrac{3 - \sqrt5}{2},\quad
\sqrt5 - 2,\quad \varphi^{-4} = \tfrac{7 - 3\sqrt5}{2},$$
all elements of $\mathbb{Q}(\sqrt5)$.

### 5.2 Reduction and plateaus

Balanced blocks are free (Proposition 2.3 and Theorem 3.1), so any configuration
$(a_0, \dots, a_4)$ may be *reduced* by repeatedly subtracting $(1,1,1,1,1)$ until
some coordinate is zero, i.e. until $\min_r a_r = 0$, without changing the value
of the sum. Consequently the value of any configuration equals the value of a
reduced one with $\min_r a_r = 0$, and there are only finitely many reduced
canonical forms of any bounded total.

**Proposition 5.1 (Eventual plateau).** For each residue $r$, there exists an
index $k_r$ such that $\sigma_5(5k + r) = L_r$ for all $k \ge k_r$.

*Proof sketch.* The limit $L_r$ is the least modulus over all reduced canonical
forms whose total is $\equiv r \pmod 5$; call a minimizing reduced form
$(b_0,\dots,b_4)$ with total $T_r$. Once the budget $5k + r \ge T_r$ and
$5k + r \equiv T_r \pmod 5$ (which holds for all large $k$ since both are $\equiv r$),
we may realize $(b_0,\dots,b_4)$ and pad with $(5k + r - T_r)/5$ balanced blocks,
attaining modulus $L_r$. Hence $\sigma_5(5k+r) \le L_r$; combined with $\sigma_5
\ge L_r$ from monotone convergence to the infimum, equality holds. $\square$

In the table, the $r = 2$ and $r = 3$ classes plateau at $L_2 = L_3 = \sqrt5 - 2$
from $k = 1$ onward, while $r = 1$ and $r = 4$ are still descending in the
displayed range.

---

## 6. A lattice / closest-vector reformulation

The ring $\mathbb{Z}[\zeta]$ of integer combinations of powers of $\zeta$, viewed
through the embedding $\mathbb{Q}(\zeta) \hookrightarrow \mathbb{C}$, projects onto
a rank-$2$ lattice in the plane once one quotients by the relation $\sum_i \zeta^i
= 0$ (equivalently, works modulo the all-ones vector). Under this lens:

- A configuration $(a_0, \dots, a_4) \in \mathbb{N}^5$ with $\sum_r a_r = n$ maps
  to the point $\sum_r a_r \zeta^r$ of the lattice.
- The residue constraint $n \equiv r \pmod 5$ selects a coset of the sublattice
  fixed by the total-count-mod-5 condition.
- $\sigma_5(n)$ is the distance from the origin to the nearest attainable lattice
  point in that coset, subject to the coefficient box $0 \le a_r$, $\sum_r a_r =
  n$ — a *closest-vector* quantity.

As $n$ increases by $5$, the coefficient box enlarges (the constraint $\sum_r a_r
= n$ relaxes upward while the residue is preserved), so the set of attainable
points grows and the nearest distance cannot increase. This is the geometric
content of Theorem 3.1. The reformulation ties the problem to lattice reduction
and closest-vector algorithms (see Section 7), which compute $\sigma_5(n)$ far more
efficiently than the naive search over all $\binom{n+4}{4}$ canonical forms.

---

## 7. Algorithms

We record two ways to compute $\sigma_5$.

### 7.1 Exhaustive canonical-form search

Because only $(a_0, \dots, a_4)$ with $\sum a_r = n$ matter, one enumerates the
$\binom{n+4}{4} = O(n^4)$ compositions of $n$ into five nonnegative parts and
minimizes $|\sum_r a_r \zeta^r|$.

```
Input:  n
Output: sigma5(n)
best <- +infinity
for (a0, a1, a2, a3, a4) with a0+a1+a2+a3+a4 = n:
    S <- a0 + a1*z + a2*z^2 + a3*z^3 + a4*z^4       # z = exp(2*pi*i/5)
    best <- min(best, |S|)
return best
```

Complexity: $O(n^4)$ evaluations; polynomial but wasteful.

### 7.2 Reduced-form search (block reduction)

Since balanced blocks are free, one need only search reduced forms with $\min_r
a_r = 0$ and total $\le n$ congruent to $n \bmod 5$, dramatically shrinking the
search and directly exposing the plateau value $L_r$.

```
Input:  n
Output: sigma5(n)
r <- n mod 5
best <- +infinity
for every reduced (b0,...,b4) with min_r b_r = 0, sum b_r <= n, sum b_r == r (mod 5):
    S <- b0 + b1*z + b2*z^2 + b3*z^3 + b4*z^4
    best <- min(best, |S|)
return best
```

For fixed residue the reduced totals of interest are bounded independently of $k$
once $k \ge k_r$, so the plateau value $L_r$ is computed in constant work.

---

## 8. Applications and context

**Cyclic characters and Fourier analysis.** The powers of $\zeta$ are the values
of the nontrivial characters of $\mathbb{Z}/5\mathbb{Z}$; sums such as
$\sum_j \zeta^{c_j}$ are exactly the character sums that appear in the discrete
Fourier transform. The minimal modulus $\sigma_5(n)$ measures the maximal
cancellation achievable with a budget of $n$ character values, a quantity relevant
to the design of low-autocorrelation sequences and to bounds on exponential sums.

**Number theory.** Sums of roots of unity are the atoms of Gauss and Jacobi sums.
Understanding when such sums are small — and the algebraic field in which the
smallest values live (here $\mathbb{Q}(\sqrt5)$) — is a recurring subproblem in
the study of cyclotomic fields.

**Lattice computation.** The closest-vector reformulation of Section 6 places
$\sigma_5$ within the algorithmic geometry of numbers, where mature lattice-reduction
techniques apply.

---

## 9. Discussion and future work

The result is deliberately minimal in its hypotheses: the only property of $5$
used is Proposition 2.3, that the complete set of roots sums to zero. This suggests
several directions.

**General modulus $m$.** For any $m \ge 2$, define $\sigma_m(n)$ as the minimal
modulus of a sum of $n$ powers of $\omega = e^{2\pi i/m}$. Since $\sum_{i=0}^{m-1}
\omega^i = 0$, the identical padding argument gives $\sigma_m(n + m) \le
\sigma_m(n)$ and hence residue-class monotonicity modulo $m$. The five-root case
is a template, not a special case.

**Closed forms for the limits $L_r$.** By Corollary 4.3 and Proposition 5.1 each
class stabilizes at a value $L_r \in \mathbb{Q}(\sqrt5)$; determining $L_r$ in
closed form for all $r$ (and all $m$) is a concrete goal, with the observed values
$\varphi^{-1}, \varphi^{-2}, \sqrt5 - 2, \varphi^{-4}$ as data points.

**Stabilization index.** Characterizing the least $k_r$ at which each class reaches
its plateau upgrades the qualitative monotonicity to a quantitative rate.

**Lattice algorithms.** Exploiting the closest-vector formulation to compute
$\sigma_m(n)$ at scale, beyond brute force, is a natural algorithmic program.

---

## 10. Conclusion

We defined the minimal-modulus function $\sigma_5$ for sums of fifth roots of
unity and proved that it is non-increasing along every residue class modulo $5$.
The proof reduces to one identity — the vanishing of the complete root sum — which
makes any budget increase by five a free, value-preserving operation and thereby
nests the feasible sets. The exact values inhabit the golden field
$\mathbb{Q}(\sqrt5)$, the classes converge to explicit plateaus, and a
closest-vector reading connects the whole picture to lattice geometry. The
argument generalizes without change to the $m$-th roots of unity, turning a single
example into a structural principle about cyclic symmetry.
