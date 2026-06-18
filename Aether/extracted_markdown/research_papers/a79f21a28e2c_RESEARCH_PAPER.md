# Tropical Differential Equations: Power Series Solutions

## A valuation tropicalization of the differential ring of formal power series

### Abstract

We develop the **valuation (order) tropicalization** of the ring of formal
power series $R\llbracket X\rrbracket$ and use it to study *tropical
differential constraints*: lower bounds on the order (valuation) of solutions of
differential equations. The tropicalization map $\mathsf{T}(f) =
\operatorname{trop}(\operatorname{ord} f)$ sends a power series to the tropical
class of its order, landing in the min-plus tropical semiring
$\mathsf{Trop}(\mathbb{N} \cup \{\infty\})$. We prove that this map is a *lax
semiring homomorphism*: it is exactly multiplicative on products
($\mathsf{T}(fg) = \mathsf{T}(f) \odot \mathsf{T}(g)$, the Product Law) and
super-additive on sums ($\mathsf{T}(f) \oplus \mathsf{T}(g) \le \mathsf{T}(f+g)$,
the Sum Law). The novel contribution is the **differential** half of the theory.
We show that the formal derivative acts on valuations as "subtract at most one,"
$\operatorname{ord} f \le \operatorname{ord} f' + 1$, over an *arbitrary*
commutative ring, and that this iterates to
$\operatorname{ord} f \le \operatorname{ord} f^{(k)} + k$. The inequality becomes
an equality precisely in characteristic zero: if $\operatorname{ord} f > 0$ then
$\operatorname{ord} f' + 1 = \operatorname{ord} f$. As a headline application of
this exactness, we prove a **valuation-pinning theorem**: over a
characteristic-zero field, any nonzero solution of the linear differential
equation $f' = c \cdot f$ with $c \ne 0$ must have order $0$. This is the
simplest nontrivial concrete realization of the *fundamental-theorem-of-tropical-
differential-algebra* phenomenon — the tropicalization of an equation
constraining the tropicalization of its solution set. Every result has been
formally verified.

**Keywords.** tropical geometry, formal power series, valuation, formal
derivative, differential algebra, min-plus semiring, order of vanishing,
characteristic zero, lower bounds on growth.

**MSC 2020.** 14T10 (tropical geometry), 13F25 (formal power series rings),
12H05 (differential algebra), 16Y60 (semirings).

---

## 1. Introduction

### 1.1 Motivation

Tropical geometry replaces algebraic objects by piecewise-linear "shadows" that
retain combinatorial information while being far easier to compute with. The
classical bridge is the *valuation map*: a non-archimedean valuation
$v\colon K \to \mathbb{R} \cup \{\infty\}$ on a field turns multiplication into
addition and addition into a minimum, exactly the operations of the **min-plus
(tropical) semiring**. Tropicalizing a variety yields a polyhedral complex; the
*fundamental theorem of tropical geometry* asserts that this complex is the
combinatorial closure of the valuations of the variety's points.

In the *differential* setting, the analogous program was initiated by Aroca,
Garay, and Toghani, who proved a fundamental theorem of tropical differential
algebraic geometry: the tropicalization of a differential ideal equals the
tropical differential ideal of the tropicalization. The natural valued object is
the ring of formal power series $K\llbracket X\rrbracket$ equipped with its
order valuation and the formal derivative $\frac{d}{dX}$.

This paper builds, from first principles and in fully verified form, the
foundational layer of that theory for the single-variable power series ring: the
order tropicalization map, its homomorphism properties, the tropical action of
the derivation, and a concrete pinning theorem that exhibits the
fundamental-theorem phenomenon in its smallest nontrivial case.

### 1.2 Contributions

We establish six results, organized into a static (algebraic) half and a
differential half.

**Static half (the order is a lax tropical homomorphism).**

1. *Product Law* (Theorem 3.1): $\mathsf{T}(fg) = \mathsf{T}(f) \odot
   \mathsf{T}(g)$ over an integral domain.
2. *Sum Law* (Theorem 3.2): $\mathsf{T}(f) \oplus \mathsf{T}(g) \le
   \mathsf{T}(f+g)$ over any semiring.

**Differential half (the derivative tropicalizes to "subtract one").**

3. *Derivative Bound* (Theorem 4.1): $\operatorname{ord} f \le
   \operatorname{ord} f' + 1$ over any commutative ring.
4. *Iterated Bound* (Theorem 4.2): $\operatorname{ord} f \le
   \operatorname{ord} f^{(k)} + k$.
5. *Exact Drop* (Theorem 4.3): over a characteristic-zero field,
   $\operatorname{ord} f > 0 \implies \operatorname{ord} f' + 1 =
   \operatorname{ord} f$.
6. *Pinning Theorem* (Theorem 5.1): over a characteristic-zero field, a nonzero
   solution of $f' = c f$ with $c \ne 0$ has $\operatorname{ord} f = 0$.

### 1.3 Relation to prior tropical work

This extends a line of work tropicalizing static linear objects — convexity of
difference-constraint polyhedra, tropical convexity of polytopes — by adding the
differential dimension. Where those results tropicalize a *polytope*, here we
tropicalize a *ring equipped with a derivation*. The min-plus semiring
$\mathsf{Trop}$ is the same throughout; what is new is that the derivation
operator acquires a tropical action.

---

## 2. Preliminaries and definitions

### 2.1 Formal power series and order

Let $R$ be a commutative ring. The ring of **formal power series** in one
variable is

$$
R\llbracket X\rrbracket = \Bigl\{\, f = \sum_{i \ge 0} a_i X^i : a_i \in R \,\Bigr\},
$$

with the usual addition and the Cauchy product
$(fg)_n = \sum_{i+j=n} a_i b_j$. We write $\operatorname{coeff}_i(f) = a_i$ for
the coefficient of $X^i$.

**Definition 2.1 (Order / valuation).** The **order** of $f \in
R\llbracket X\rrbracket$ is

$$
\operatorname{ord}(f) =
\begin{cases}
\min\{\, i : a_i \ne 0 \,\} & \text{if } f \ne 0,\\[2pt]
+\infty & \text{if } f = 0,
\end{cases}
$$

taking values in $\mathbb{N} \cup \{\infty\} = \overline{\mathbb{N}}$. The order
is the $X$-adic valuation; it is finite if and only if $f \ne 0$.

We record the two facts about order that ground everything below.

**Fact 2.2 (Coefficients below the order vanish).** If $i < \operatorname{ord}(f)$
then $\operatorname{coeff}_i(f) = 0$. Conversely, if $\operatorname{coeff}_i(f)
= 0$ for all $i < n$, then $n \le \operatorname{ord}(f)$.

**Fact 2.3 (Order is additive on a domain).** If $R$ is an integral domain (no
zero divisors), then $\operatorname{ord}(fg) = \operatorname{ord}(f) +
\operatorname{ord}(g)$, with the convention $n + \infty = \infty$.

### 2.2 The min-plus tropical semiring

**Definition 2.4 (Tropical semiring).** The **min-plus tropical semiring**
$\mathsf{Trop}(\overline{\mathbb{N}})$ has underlying set $\overline{\mathbb{N}}
= \mathbb{N} \cup \{\infty\}$, with

$$
a \oplus b := \min(a, b), \qquad a \odot b := a + b.
$$

The additive identity is $\infty$ (since $\min(a, \infty) = a$) and the
multiplicative identity is $0$. We write $\operatorname{trop}\colon
\overline{\mathbb{N}} \to \mathsf{Trop}(\overline{\mathbb{N}})$ for the
order-reversing identification of the carrier with the semiring, and we use the
two structural identities

$$
\operatorname{trop}(a + b) = \operatorname{trop}(a) \odot \operatorname{trop}(b),
\qquad
\operatorname{trop}(\min(a,b)) = \operatorname{trop}(a) \oplus \operatorname{trop}(b).
$$

The map $\operatorname{trop}$ is monotone: $a \le b \iff \operatorname{trop}(a)
\le \operatorname{trop}(b)$ in the tropical order.

### 2.3 The tropicalization of a power series

**Definition 2.5 (Valuation tropicalization).** For $f \in
R\llbracket X\rrbracket$ define

$$
\mathsf{T}(f) := \operatorname{trop}\bigl(\operatorname{ord}(f)\bigr) \in
\mathsf{Trop}(\overline{\mathbb{N}}).
$$

This is the *order tropicalization* of $f$. It records exactly the valuation of
$f$ and nothing else; the entire higher-order structure of the series is
discarded.

### 2.4 The formal derivative

**Definition 2.6 (Formal derivative).** The **formal derivative**
$\frac{d}{dX}\colon R\llbracket X\rrbracket \to R\llbracket X\rrbracket$ is the
$R$-linear map determined by

$$
\operatorname{coeff}_i\!\left(\tfrac{d}{dX} f\right) = (i+1)\cdot a_{i+1},
$$

i.e. $f' = \sum_{i\ge 0}(i+1)a_{i+1}X^i$. We write $f' = \frac{d}{dX}f$ and
$f^{(k)} = \bigl(\frac{d}{dX}\bigr)^k f$ for the $k$-fold iterate. The integer
factor $(i+1)$ is interpreted via the canonical ring map $\mathbb{Z} \to R$, so
it may vanish in positive characteristic.

---

## 3. The static half: a lax tropical homomorphism

The order tropicalization respects the ring operations in the tropical sense:
exactly on products, laxly (as a lower bound) on sums.

### 3.1 The Product Law

**Theorem 3.1 (`tropOrder_mul`).** Let $R$ be an integral domain and $f, g \in
R\llbracket X\rrbracket$. Then

$$
\mathsf{T}(fg) = \mathsf{T}(f) \odot \mathsf{T}(g).
$$

*Proof sketch.* By Fact 2.3, $\operatorname{ord}(fg) = \operatorname{ord}(f) +
\operatorname{ord}(g)$ over a domain. Apply $\operatorname{trop}$ to both sides
and use $\operatorname{trop}(a+b) = \operatorname{trop}(a) \odot
\operatorname{trop}(b)$. $\quad\square$

The hypothesis that $R$ is a domain is essential: it is exactly what prevents the
product of the two leading coefficients from vanishing. Over a ring with zero
divisors only the inequality $\operatorname{ord}(fg) \ge \operatorname{ord}(f) +
\operatorname{ord}(g)$ survives.

### 3.2 The Sum Law

**Theorem 3.2 (`tropOrder_add_le`).** Let $R$ be any semiring and $f, g \in
R\llbracket X\rrbracket$. Then

$$
\mathsf{T}(f) \oplus \mathsf{T}(g) \le \mathsf{T}(f+g).
$$

*Proof sketch.* The classical valuation inequality
$\min(\operatorname{ord} f, \operatorname{ord} g) \le \operatorname{ord}(f+g)$
holds because every coefficient of $f+g$ below index
$\min(\operatorname{ord} f, \operatorname{ord} g)$ is a sum of two zeros. Now
rewrite tropical addition as $\mathsf{T}(f) \oplus \mathsf{T}(g) =
\operatorname{trop}(\min(\operatorname{ord} f, \operatorname{ord} g))$ and push
the inequality through the monotone map $\operatorname{trop}$. $\quad\square$

The inequality is generally strict: leading-term cancellation can raise the order
of the sum above the minimum, e.g. $(5 + \cdots) + (-5 + \cdots)$ jumps from
order $0$ to order $\ge 1$. Thus $\mathsf{T}$ is a genuine *lax* homomorphism on
the additive side — it provides only a lower bound, mirroring the one-sided
"balancing" ubiquitous in tropical geometry.

**Summary.** Theorems 3.1–3.2 say $\mathsf{T}$ is a lax semiring homomorphism
$R\llbracket X\rrbracket \to \mathsf{Trop}(\overline{\mathbb{N}})$: a faithful
tropical shadow of the power-series ring, exact on products and lower-bounding on
sums.

---

## 4. The differential half: the tropical action of the derivative

We now tropicalize the *derivation*. The central phenomenon is that on
valuations the formal derivative acts as "subtract at most one," and that this is
exact precisely in characteristic zero.

### 4.1 The Derivative Bound

**Theorem 4.1 (`order_deriv_succ_le`).** Let $R$ be any commutative ring and
$f \in R\llbracket X\rrbracket$. Then

$$
\operatorname{ord}(f) \le \operatorname{ord}(f') + 1.
$$

Equivalently $\operatorname{ord}(f') \ge \operatorname{ord}(f) - 1$:
differentiation lowers the order by at most one.

*Proof sketch.* If $f = 0$ both sides are $\infty$ and the inequality holds.
Otherwise $\operatorname{ord}(f)$ is finite; write $n = \operatorname{ord}(f)$.
For every index $i < n - 1$ we have $i + 1 < n = \operatorname{ord}(f)$, so by
Fact 2.2 the coefficient $a_{i+1} = 0$, whence
$\operatorname{coeff}_i(f') = (i+1)a_{i+1} = 0$. By the converse direction of
Fact 2.2 applied to $f'$, this forces $\operatorname{ord}(f') \ge n - 1$.
Therefore $\operatorname{ord}(f) = n \le (n-1) + 1 \le \operatorname{ord}(f') +
1$. $\quad\square$

The proof uses *no* arithmetic on the factor $(i+1)$ beyond the trivial fact
that $0 \cdot a = 0$; this is why the result holds over an arbitrary commutative
ring, including positive characteristic. It is the universal tropical bound for
the derivation: on shadows, $\frac{d}{dX}$ subtracts at most one.

### 4.2 The Iterated Bound

**Theorem 4.2 (`order_iterate_deriv_le`).** Let $R$ be any commutative ring,
$f \in R\llbracket X\rrbracket$, and $k \in \mathbb{N}$. Then

$$
\operatorname{ord}(f) \le \operatorname{ord}\bigl(f^{(k)}\bigr) + k.
$$

*Proof sketch.* Induct on $k$. The base case $k = 0$ is
$\operatorname{ord}(f) \le \operatorname{ord}(f)$. For the inductive step, write
$f^{(k+1)} = \bigl(f^{(k)}\bigr)'$ (composition on the outside). Apply the
inductive hypothesis to obtain $\operatorname{ord}(f) \le
\operatorname{ord}(f^{(k)}) + k$, then Theorem 4.1 to the inner $k$-fold
derivative to obtain $\operatorname{ord}(f^{(k)}) \le \operatorname{ord}(f^{(k+1)})
+ 1$; chain the two inequalities. $\quad\square$

This is the differential-monomial form of the fundamental-theorem inequality:
the tropicalization of a degree-$k$ differential operator subtracts at most $k$
from the valuation, hence **lower-bounds the order — and so the flatness and
growth — of any classical solution** of a differential expression built from
$f, f', \dots, f^{(k)}$.

### 4.3 The Exact Drop in characteristic zero

The one-step bound is generally not an equality: in characteristic $p$, the
series $f = X^p$ has $f' = pX^{p-1} = 0$, so $\operatorname{ord}(f) = p$ but
$\operatorname{ord}(f') = \infty$. The defect is caused entirely by the vanishing
of the integer factor $(i+1)$. In characteristic zero this cannot happen.

**Theorem 4.3 (`order_deriv_eq_of_pos`).** Let $R$ be a field of characteristic
zero and $f \in R\llbracket X\rrbracket$ with $\operatorname{ord}(f) > 0$. Then

$$
\operatorname{ord}(f') + 1 = \operatorname{ord}(f).
$$

*Proof sketch.* Let $n = \operatorname{ord}(f) \ge 1$ (finite, since $f \ne 0$).
By Theorem 4.1, $\operatorname{ord}(f') \ge n - 1$. For the reverse inequality,
inspect the coefficient of $X^{n-1}$ in $f'$:
$\operatorname{coeff}_{n-1}(f') = n \cdot a_n$. Here $a_n =
\operatorname{coeff}_n(f) \ne 0$ because $n = \operatorname{ord}(f)$, and the
integer $n$ is nonzero in $R$ because the characteristic is zero. As $R$ is a
field (hence a domain), $n \cdot a_n \ne 0$, so $\operatorname{coeff}_{n-1}(f')
\ne 0$ and therefore $\operatorname{ord}(f') \le n - 1$. Combining,
$\operatorname{ord}(f') = n - 1$, i.e. $\operatorname{ord}(f') + 1 = n$. $\quad\square$

This isolates the **characteristic as the boundary between the lax and exact
tropical derivative.** In characteristic zero the derivative tropicalizes to an
*exact* "subtract one" (on series of positive order); in positive characteristic
it only subtracts *at most* one, and can collapse to $\infty$.

---

## 5. The Pinning Theorem: tropicalizing a differential equation

We now combine exactness with the Product Law to pin the valuation of solutions
of a linear ODE — the simplest nontrivial realization of the principle that *the
tropicalization of an equation constrains the tropicalization of its solutions*.

**Theorem 5.1 (`linODE_order_zero`).** Let $R$ be a field of characteristic
zero, let $c \in R$ with $c \ne 0$, and let $f \in R\llbracket X\rrbracket$ be a
nonzero solution of

$$
f' = c \cdot f.
$$

Then $\operatorname{ord}(f) = 0$.

*Proof sketch.* Suppose for contradiction that $n := \operatorname{ord}(f) > 0$
(it is finite since $f \ne 0$). Compute the orders of the two sides of the
equation:

- *Left side.* By the Exact Drop (Theorem 4.3, applicable since $n > 0$),
  $\operatorname{ord}(f') = n - 1$.
- *Right side.* Since $c \ne 0$ is a nonzero constant, the series $c$ (regarded
  as $c X^0 + 0 + \cdots$) has order $0$. By the Product Law (Theorem 3.1, using
  that a field is a domain), $\operatorname{ord}(c f) = \operatorname{ord}(c) +
  \operatorname{ord}(f) = 0 + n = n$.

The equation $f' = c f$ forces $\operatorname{ord}(f') = \operatorname{ord}(cf)$,
i.e. $n - 1 = n$, a contradiction. Hence $n = 0$, that is
$\operatorname{ord}(f) = 0$. $\quad\square$

**Tropical reading.** Tropicalize the equation. The left side has tropical class
$\mathsf{T}(f') = \operatorname{trop}(n - 1)$; the right side has
$\mathsf{T}(cf) = \mathsf{T}(c) \odot \mathsf{T}(f) = 0 \odot \operatorname{trop}(n)
= \operatorname{trop}(n)$. The tropical equation $\operatorname{trop}(n-1) =
\operatorname{trop}(n)$ is *unbalanced* unless the valuation collapses to the
bottom element $0$. The pinning is precisely the statement that the tropicalized
equation determines the tropicalized solution.

**Sharpness of the hypotheses.**

- *$c \ne 0$ is needed.* If $c = 0$ the equation is $f' = 0$, solved by every
  nonzero constant — and indeed by anything whose derivative vanishes — so the
  order is not pinned (and in positive characteristic $f = X^p$ also solves
  $f' = 0$).
- *Characteristic zero is needed.* The proof invokes the Exact Drop, which fails
  in characteristic $p$: there $f = X^p$ has $f' = 0$, and order behavior is no
  longer rigid.

---

## 6. Algorithms

The theory is fully effective on truncated power series. We summarize the core
routines; full implementations appear in the accompanying demonstration code.

### 6.1 Order computation

```
INPUT : coefficients a_0, ..., a_{N-1}
OUTPUT: ord(f) up to precision N
for i = 0 .. N-1:
    if a_i != 0: return i
return +infinity   (within the truncation)
```

### 6.2 Tropical product / sum of orders

```
trop_mul(a, b) = (a + b)         with INF absorbing
trop_add(a, b) = min(a, b)
```

By the Product Law, $\operatorname{ord}(fg)$ is computed *without* multiplying
the series, simply as $\operatorname{ord}(f) \odot \operatorname{ord}(g)$. By the
Sum Law, $\operatorname{trop\_add}(\operatorname{ord} f, \operatorname{ord} g)$ is
a certified lower bound for $\operatorname{ord}(f+g)$.

### 6.3 Certified lower bound on a differential expression

```
INPUT : a differential monomial m = f^(k_1) * ... * f^(k_r)
OUTPUT: a certified lower bound L <= ord(m)
L := sum over j of (ord(f) - k_j)   (clipped at 0 if ord(f) < k_j)
return L
```

This uses the Iterated Bound (Theorem 4.2) inside each factor and the Product
Law across factors, yielding a guaranteed lower bound on the order — and hence on
the flatness — of any classical solution, *without solving* the equation.

---

## 7. Applications and discussion

**Lower bounds on solution growth.** The headline practical consequence of the
differential half is that tropical data *certify* lower bounds on the valuation
of solutions. Given a differential equation and a candidate order $n$ for $f$,
the Iterated Bound and Product Law let one read off the order of every
differential monomial and check tropical balancing — a purely combinatorial test
that can rule out impossible valuations, exactly as in the Pinning Theorem.

**Initial-value rigidity.** Theorem 5.1 says exponential-type equations admit no
"delayed" solutions: a nonzero solution of $f' = cf$ cannot vanish at the origin.
This is the formal-power-series shadow of the analytic fact that $e^{cX}$ is
nonzero at $X = 0$, proved without any analysis.

**The lax/exact dichotomy as a characteristic detector.** Theorems 4.1 and 4.3
together turn the question "does the derivative drop the order exactly?" into a
test for characteristic zero. The failure witness $f = X^p$ (with $f' = 0$) is a
clean diagnostic: exactness of the tropical derivative is equivalent to the
integer factors $(i+1)$ never vanishing, i.e. to characteristic zero.

**Position within tropical geometry.** This is the single-variable, order-valued
instance of the fundamental theorem of tropical differential algebra. The Product
and Sum Laws are the differential-ring analogues of the valuation axioms; the
Derivative Bound is the new structural ingredient that the differential setting
demands; the Pinning Theorem exhibits the fundamental-theorem phenomenon
concretely rather than axiomatically.

---

## 8. Future directions

The following directions, identified during the development, extend the theory
along three axes — coarser-to-finer invariants, single- to multivariable, and
linear to nonlinear equations.

- **From order to initial form.** Replace the order-only tropicalization
  $\mathsf{T}(f) = \operatorname{trop}(\operatorname{ord} f)$ by the *initial
  form* (the leading coefficient together with the order), recovering a finer
  shadow that detects cancellation in the Sum Law and upgrades the lax additive
  inequality to a tracked equality-with-defect.
- **Several variables and several derivations.** Generalize from
  $R\llbracket X\rrbracket$ with one derivation to
  $R\llbracket X_1, \dots, X_m\rrbracket$ with partial derivatives, where orders
  become Newton-polytope data and the Derivative Bound becomes a statement about
  supporting hyperplanes.
- **Nonlinear and higher-order ODEs.** Extend the Pinning Theorem from
  $f' = cf$ to general polynomial differential equations $P(f, f', \dots,
  f^{(k)}) = 0$, characterizing which equations pin the valuation and which leave
  it free, via tropical balancing of the Newton polytope of $P$.
- **Systems and matrices.** Tropicalize linear systems $f' = A f$ with $A$ a
  matrix over $R$, connecting the valuation spectrum of $A$ to the achievable
  orders of solution vectors.
- **Positive characteristic refinements.** In characteristic $p$, replace the
  failed Exact Drop by a $p$-adically corrected statement tracking how many times
  the order can "jump" under repeated differentiation, linking to the theory of
  $p$-derivations and Hasse derivatives.

---

## 9. Conclusion

We have built the foundational layer of tropical differential algebra for
single-variable formal power series: a valuation tropicalization that is a lax
semiring homomorphism (exact on products, super-additive on sums), a derivation
that tropicalizes to "subtract at most one" over any commutative ring and
"subtract exactly one" in characteristic zero, and a pinning theorem showing that
the equation $f' = cf$ ($c \ne 0$) forces every nonzero solution to have order
zero. The recurring lesson is that a single number — the order — already obeys a
rich tropical arithmetic, and that arithmetic is sharp enough to constrain, and
sometimes determine, features of the solutions of differential equations without
ever solving them.

---

## References

1. F. Aroca, C. Garay, Z. Toghani. *The fundamental theorem of tropical
   differential algebraic geometry.* Pacific J. Math. **283** (2016), no. 2,
   257–270.
2. D. Maclagan, B. Sturmfels. *Introduction to Tropical Geometry.* Graduate
   Studies in Mathematics **161**, American Mathematical Society, 2015.
