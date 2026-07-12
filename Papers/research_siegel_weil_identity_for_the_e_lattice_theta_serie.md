# The Siegel–Weil Identity for the $E_8$ Theta Series and the Hecke Structure of $240\,\sigma_3$

## Abstract

The theta series of an even, positive-definite, unimodular lattice of rank $8$
coincides with the normalized weight-$4$ Eisenstein series $E_4$. Equivalently,
writing $r(n)$ for the number of lattice vectors of squared length $2n$, one has
$r(n) = 240\,\sigma_3(n)$ for every positive integer $n$, where
$\sigma_3(n) = \sum_{d \mid n} d^3$. This is the foundational rank-$8$ case of the
classical Siegel–Weil formula, which equates the average theta series of a genus
of quadratic forms with an Eisenstein series; the genus of even unimodular
rank-$8$ lattices has a single class, so the average degenerates to the single
lattice $E_8$. We give a self-contained account of the arithmetic backbone of
this identity: the coefficient system $n \mapsto 240\,\sigma_3(n)$ is not an
arbitrary arithmetic function but the coefficient system of a Hecke eigenform.
We establish a geometric closed form for $\sigma_3$ at prime powers, the
three-term Hecke recurrence on prime powers, multiplicativity across coprime
arguments and its consequence for representation numbers, and the global Hecke
eigenform convolution identity
$\sigma_3(m)\,\sigma_3(n) = \sum_{d \mid \gcd(m,n)} d^3\,\sigma_3(mn/d^2)$. We
close with numerical corroboration, applications, and a program of extensions.

**Keywords.** $E_8$ lattice, theta series, Eisenstein series $E_4$, Siegel–Weil
formula, Hecke eigenform, divisor-power sum $\sigma_3$, modular forms, sphere
packing.

**MSC.** 11F27, 11F30, 11H31, 11E45.

---

## 1. Introduction

### 1.1 Lattices, shells, and theta series

A *lattice* $L \subset \mathbb{R}^8$ is the set of integer linear combinations of a
basis; equipped with the standard inner product it carries an integer-valued
quadratic form $x \mapsto \langle x, x\rangle$. The lattice is *even* if
$\langle x, x\rangle \in 2\mathbb{Z}$ for all $x \in L$, *positive-definite* if
$\langle x, x\rangle > 0$ for $x \neq 0$, and *unimodular* if the Gram matrix of
any basis has determinant $\pm 1$ (equivalently $L = L^\ast$, the lattice equals
its dual). In rank $8$ there is, up to isometry, exactly one even positive-definite
unimodular lattice: the root lattice $E_8$.

Partitioning $L$ into shells by squared length yields the *representation
numbers*
$$N(k) = \#\{x \in L : \langle x, x\rangle = k\}.$$
For an even lattice $N(k) = 0$ unless $k$ is even, so it is convenient to index by
$n$ with $k = 2n$ and write $r(n) = N(2n)$. The generating function packaging
these counts is the *theta series*
$$\theta_L(\tau) = \sum_{x \in L} q^{\langle x, x\rangle / 2} = \sum_{n \ge 0} r(n)\, q^n, \qquad q = e^{2\pi i \tau},\ \ \mathrm{Im}\,\tau > 0,$$
with $r(0) = 1$ (the zero vector). A classical theorem states that for an even
unimodular lattice of rank $m$, $\theta_L$ is a modular form of weight $m/2$ for
the full modular group $\mathrm{SL}_2(\mathbb{Z})$.

### 1.2 The Eisenstein series $E_4$

For even weight $k \ge 4$, the normalized Eisenstein series is
$$E_k(\tau) = 1 - \frac{2k}{B_k} \sum_{n \ge 1} \sigma_{k-1}(n)\, q^n,$$
where $B_k$ is the $k$-th Bernoulli number and
$\sigma_{k-1}(n) = \sum_{d \mid n} d^{\,k-1}$. For $k = 4$, using $B_4 = -1/30$,
$$E_4(\tau) = 1 + 240 \sum_{n \ge 1} \sigma_3(n)\, q^n.$$
The space $M_4(\mathrm{SL}_2(\mathbb{Z}))$ of weight-$4$ modular forms is
one-dimensional and spanned by $E_4$; in particular there are no nonzero weight-$4$
cusp forms.

### 1.3 The Siegel–Weil identity in rank 8

Since $\theta_{E_8}$ is a weight-$4$ modular form with constant term $1$, and
$M_4$ is one-dimensional spanned by $E_4$ (also with constant term $1$), the two
functions coincide:
$$\boxed{\;\theta_{E_8} = E_4\;} \qquad\Longleftrightarrow\qquad r(n) = 240\,\sigma_3(n)\ \ \text{for all } n \ge 1.$$
This is the rank-$8$ case of the **Siegel–Weil formula**: the genus-average of
theta series equals an Eisenstein series, and here the genus is a single class,
so the average is $\theta_{E_8}$ itself. The problem of *proving* the identity
reduces to matching Fourier coefficients, and the arithmetic content lives
entirely in the coefficient function
$$\mathrm{rE8}(n) := 240\,\sigma_3(n).$$

### 1.4 Contributions

This paper develops the arithmetic backbone that makes $240\,\sigma_3$ the
coefficient system of a Hecke eigenform. Concretely we prove:

1. **(Prime-power closed form.)** $\sigma_3(p^r) = \sum_{i=0}^r p^{3i}$ for prime
   $p$, and the specialization $\sigma_3(p) = 1 + p^3$.
2. **(Hecke three-term recurrence.)**
   $\sigma_3(p^{r+2}) + p^3\,\sigma_3(p^r) = \sigma_3(p)\,\sigma_3(p^{r+1})$.
3. **(Multiplicativity.)** $\sigma_3(mn) = \sigma_3(m)\,\sigma_3(n)$ for coprime
   $m, n$, and the induced quasi-multiplicativity
   $240\,\mathrm{rE8}(mn) = \mathrm{rE8}(m)\,\mathrm{rE8}(n)$.
4. **(Global eigenform identity.)**
   $\sigma_3(m)\,\sigma_3(n) = \sum_{d \mid \gcd(m,n)} d^3\,\sigma_3(mn/d^2)$ for
   all $m, n \ge 1$.

Together these show that the vector counts of $E_8$ form a Hecke eigenvalue
system, exactly as the Siegel–Weil philosophy predicts.

---

## 2. Definitions and notation

Throughout, $p$ denotes a prime, $\mathbb{N} = \{0, 1, 2, \dots\}$, and for
$s \in \mathbb{N}$ the divisor-power sum is
$$\sigma_s(n) = \sum_{d \mid n} d^s, \qquad n \ge 1,$$
with the convention $\sigma_s(0) = 0$. An arithmetic function $f$ is
*multiplicative* if $f(1) = 1$ and $f(mn) = f(m)f(n)$ whenever $\gcd(m,n) = 1$.
The function $\sigma_s$ is multiplicative for every $s$.

**Definition 2.1 (Siegel–Weil prediction).** The predicted number of $E_8$
vectors of squared length $2n$ is
$$\mathrm{rE8}(n) = 240\,\sigma_3(n).$$

**Definition 2.2 (Hecke convolution).** For $m, n \ge 1$ define
$$\mathrm{heckeRHS}(m, n) = \sum_{d \mid \gcd(m,n)} d^3\,\sigma_3\!\left(\frac{mn}{d^2}\right).$$
(One sets $\mathrm{heckeRHS}(0, n) = \mathrm{heckeRHS}(m, 0) = 0$.)

---

## 3. The arithmetic of $\sigma_3$ at prime powers

### 3.1 Geometric closed form

**Theorem 3.1 (Prime-power closed form).** *For a prime $p$ and $r \ge 0$,*
$$\sigma_3(p^r) = \sum_{i=0}^{r} p^{3i} = 1 + p^3 + p^6 + \cdots + p^{3r}.$$

*Proof sketch.* The divisors of $p^r$ are exactly $1, p, p^2, \dots, p^r$, so
$$\sigma_3(p^r) = \sum_{j=0}^{r} (p^j)^3 = \sum_{j=0}^{r} p^{3j}.$$
Reindexing $i = j$ gives the stated sum. $\qquad\blacksquare$

**Corollary 3.2 (Value at a prime).** $\sigma_3(p) = 1 + p^3$.

*Proof.* Take $r = 1$ in Theorem 3.1: the sum has the two terms $p^0 = 1$ and
$p^3$. $\qquad\blacksquare$

Summing the geometric series yields the useful closed form
$$\sigma_3(p^r)\,(p^3 - 1) = p^{3(r+1)} - 1,$$
which reduces congruence questions about $\sigma_3(p^r)$ to elementary modular
arithmetic.

### 3.2 The Hecke three-term recurrence

**Theorem 3.3 (Hecke recurrence on prime powers).** *For a prime $p$ and
$r \ge 0$,*
$$\sigma_3(p^{r+2}) + p^3\,\sigma_3(p^r) = \sigma_3(p)\,\sigma_3(p^{r+1}).$$

*Proof sketch.* Write $S_a = \sum_{i=0}^{a} p^{3i}$, so by Theorem 3.1
$\sigma_3(p^a) = S_a$ and by Corollary 3.2 $\sigma_3(p) = 1 + p^3 = S_1$. The
right-hand side is
$$(1 + p^3)\,S_{r+1} = S_{r+1} + p^3 S_{r+1}.$$
Now $p^3 S_{r+1} = \sum_{i=0}^{r+1} p^{3(i+1)} = \sum_{j=1}^{r+2} p^{3j} = S_{r+2} - 1$,
and $S_{r+1} = S_r + p^{3(r+1)}$. Hence
$$(1+p^3)S_{r+1} = (S_r + p^{3(r+1)}) + (S_{r+2} - 1).$$
On the other hand the left-hand side is $S_{r+2} + p^3 S_r$. Subtracting,
the identity is equivalent to
$p^3 S_r = S_r + p^{3(r+1)} - 1 = S_r + (p^{3(r+1)} - 1)$, i.e.
$(p^3 - 1)S_r = p^{3(r+1)} - 1$, which is precisely the geometric-sum identity of
§3.1. Thus both sides agree. $\qquad\blacksquare$

The number $\sigma_3(p) = 1 + p^3$ is the eigenvalue of the Hecke operator $T_p$
acting on $E_4$; Theorem 3.3 is the coefficient-level shadow of the eigenform
equation $T_p E_4 = (1 + p^3) E_4$.

---

## 4. Multiplicativity and representation numbers

**Theorem 4.1 (Multiplicativity of $\sigma_3$).** *If $\gcd(m, n) = 1$ then*
$$\sigma_3(mn) = \sigma_3(m)\,\sigma_3(n).$$

*Proof sketch.* When $\gcd(m,n) = 1$, every divisor $d$ of $mn$ factors uniquely
as $d = d_1 d_2$ with $d_1 \mid m$, $d_2 \mid n$, and this correspondence is a
bijection between $\mathrm{Div}(mn)$ and $\mathrm{Div}(m) \times \mathrm{Div}(n)$.
Therefore
$$\sigma_3(mn) = \sum_{d \mid mn} d^3 = \sum_{d_1 \mid m}\sum_{d_2 \mid n} (d_1 d_2)^3
= \Big(\sum_{d_1 \mid m} d_1^3\Big)\Big(\sum_{d_2 \mid n} d_2^3\Big) = \sigma_3(m)\,\sigma_3(n).$$
$\qquad\blacksquare$

**Corollary 4.2 (Quasi-multiplicativity of representation numbers).** *For
coprime $m, n$,*
$$240\,\mathrm{rE8}(mn) = \mathrm{rE8}(m)\,\mathrm{rE8}(n).$$

*Proof.* Expand with Definition 2.1 and apply Theorem 4.1:
$240\,\mathrm{rE8}(mn) = 240 \cdot 240\,\sigma_3(mn)
= (240\,\sigma_3(m))(240\,\sigma_3(n)) = \mathrm{rE8}(m)\,\mathrm{rE8}(n).$
The stray factor $240$ reflects the normalization $\mathrm{rE8} = 240\,\sigma_3$;
it is $\sigma_3$, not $\mathrm{rE8}$, that is genuinely multiplicative.
$\qquad\blacksquare$

---

## 5. The global Hecke eigenform identity

We now package all of the local structure into a single global convolution law.

**Theorem 5.1 (Hecke eigenform identity).** *For all $m, n \ge 1$,*
$$\sigma_3(m)\,\sigma_3(n) = \sum_{d \,\mid\, \gcd(m,n)} d^3\,\sigma_3\!\left(\frac{mn}{d^2}\right) = \mathrm{heckeRHS}(m,n).$$

*Proof sketch.* Both sides are multiplicative as functions of the pair $(m, n)$:
if $(m,n) = (m_1 m_2, n_1 n_2)$ with $\gcd(m_1 n_1, m_2 n_2) = 1$, the left side
factors by Theorem 4.1, and the right side factors because the divisors of
$\gcd(m,n) = \gcd(m_1,n_1)\gcd(m_2,n_2)$ split accordingly and $\sigma_3$ is
multiplicative. Hence it suffices to verify the identity when $m = p^a$ and
$n = p^b$ are powers of a single prime $p$.

For prime powers, $\gcd(p^a, p^b) = p^{\min(a,b)}$, so its divisors are
$1, p, \dots, p^{\min(a,b)}$ and
$$\mathrm{heckeRHS}(p^a, p^b) = \sum_{i=0}^{\min(a,b)} p^{3i}\,\sigma_3\!\left(p^{\,a+b-2i}\right)
= \sum_{i=0}^{\min(a,b)} p^{3i}\sum_{l=0}^{a+b-2i} p^{3l}.$$
Writing $q = p^3$ and using the prime-power closed form (Theorem 3.1) this is the
purely combinatorial *geometric double-sum identity*
$$\Big(\sum_{i=0}^{a} q^{i}\Big)\Big(\sum_{j=0}^{b} q^{j}\Big)
= \sum_{i=0}^{\min(a,b)} q^{i}\sum_{l=0}^{\,a+b-2i} q^{l},$$
whose left side is exactly $\sigma_3(p^a)\,\sigma_3(p^b)$. The double-sum
identity is proved by induction on $\min(a,b)$: peeling off the diagonal term
$i = 0$ leaves a product of two geometric sums whose ranges have shrunk, and the
telescoping of geometric series matches the two sides term by term. This
establishes the prime-power case, and multiplicativity lifts it to all $m, n$.
$\qquad\blacksquare$

**Remark 5.2 (Specializations).** Theorem 5.1 unifies the earlier results:
- Taking $\gcd(m,n) = 1$, the sum has only the term $d = 1$, recovering
  multiplicativity (Theorem 4.1).
- Taking $m = p$, $n = p^{r+1}$, the sum over $d \mid \gcd(p, p^{r+1}) = p$ has
  terms $d = 1$ and $d = p$, giving
  $\sigma_3(p)\,\sigma_3(p^{r+1}) = \sigma_3(p^{r+2}) + p^3\,\sigma_3(p^r)$, the
  Hecke recurrence (Theorem 3.3).

**Remark 5.3 (Interpretation).** Theorem 5.1 is the arithmetic statement that
$E_4$ is a simultaneous eigenform of all Hecke operators. In the Hecke algebra,
$T_m T_n = \sum_{d \mid \gcd(m,n)} d^{k-1} T_{mn/d^2}$ in weight $k$; applied to
$E_4$ (weight $k = 4$) with eigenvalues $\sigma_3$, this operator identity becomes
exactly the convolution law above with $k - 1 = 3$.

---

## 6. Numerical corroboration

The first shell counts $r(n) = 240\,\sigma_3(n)$ are:

| $n$ | $\sigma_3(n)$ | $r(n) = 240\,\sigma_3(n)$ |
|----:|--------------:|--------------------------:|
| 1   | 1             | 240                       |
| 2   | 9             | 2160                      |
| 3   | 28            | 6720                      |
| 4   | 73            | 17520                     |
| 5   | 126           | 30240                     |
| 6   | 252           | 60480                     |
| 7   | 344           | 82560                     |
| 8   | 585           | 140400                    |

These match the classical theta-series coefficients of $E_8$: the innermost
shell has the famous $240$ roots, and the sequence
$240, 2160, 6720, 17520, 30240, \dots$ is exactly $240 \cdot E_4$'s coefficient
list. Multiplicativity is visible directly, e.g.
$\sigma_3(6) = \sigma_3(2)\sigma_3(3) = 9 \cdot 28 = 252$, and the Hecke
recurrence at $p = 2$, $r = 0$ reads
$\sigma_3(4) + 8\,\sigma_3(1) = 73 + 8 = 81 = 9^2 = \sigma_3(2)^2$.

---

## 7. Applications

**7.1 Sphere packing and root systems.** The $240$ minimal vectors of $E_8$ form
the root system of the exceptional Lie algebra $\mathfrak{e}_8$; the count
$r(1) = 240$ is the arithmetic reflection of this. $E_8$ is the densest sphere
packing in dimension $8$, and its exact shell counts feed directly into density
and kissing-number computations.

**7.2 Coding theory.** Even unimodular lattices underlie some of the best known
error-correcting codes; the theta series records the weight distribution of the
associated code. The exact formula $240\,\sigma_3$ gives closed-form access to
these distributions in rank $8$.

**7.3 Modular forms and the Langlands program.** The identity
$\theta_{E_8} = E_4$ is a first, fully explicit instance of the correspondence
between automorphic objects (Eisenstein series, Hecke eigenforms) and geometric
data (lattices, quadratic forms) that the Langlands program organizes at grand
scale.

---

## 8. Discussion

The proof strategy is a template for Siegel–Weil identities: reduce the
analytic statement $\theta_L = E_k$ to a coefficient identity, then verify the
coefficient identity via the local–global structure of the Hecke algebra. What
makes rank $8$ singularly clean is the confluence of three facts: (i) the genus
of even unimodular rank-$8$ lattices has a single class, so no averaging is
needed; (ii) $M_4(\mathrm{SL}_2(\mathbb{Z}))$ is one-dimensional; and (iii) there
are no weight-$4$ cusp forms, so the Eisenstein part is the *whole* story. The
divisor-cube function $\sigma_3$ therefore carries the complete Hecke-eigenform
structure, and every eigenform law appears as an elementary identity among
sums of cubes of divisors.

A subtle normalization point deserves emphasis: it is $\sigma_3$, and not the
scaled count $\mathrm{rE8} = 240\,\sigma_3$, that is multiplicative. The scaling
constant $240$ produces the corrective factor in Corollary 4.2, a reminder that
the "clean" multiplicative object is the Hecke eigenvalue system underneath the
geometric counts.

---

## 9. Future directions

**9.1 The weight-8 convolution identity $\sigma_7 = \sigma_3 \star \sigma_3$.**
Squaring $\theta_{E_8}$ gives $\theta_{E_8 \oplus E_8}$, a weight-$8$ form; since
$M_8$ is again one-dimensional, one obtains
$$\sigma_7(n) = \sigma_3(n) + 120 \sum_{m=1}^{n-1} \sigma_3(m)\,\sigma_3(n-m).$$
The multiplicative machinery for $\sigma_3$ is in hand; the remaining work is the
additive convolution bookkeeping.

**9.2 Uniqueness of the genus.** Any two even positive-definite unimodular
rank-$8$ lattices have identical representation numbers and are hence isometric,
because the genus-average equals $E_4$ while weight-$4$ cusp forms vanish, so
every lattice in the genus shares the theta series $E_4$.

**9.3 Ramanujan-type congruences.** From $\sigma_3(p) = 1 + p^3 \equiv 1 + p
\pmod{12}$ one expects $\sigma_3(n) \equiv \sigma_1(n) \pmod{12}$, giving
$r(n) \equiv 0 \pmod{2880}$ for prime $n$; the exact form
$\sigma_3(p^r)(p^3 - 1) = p^{3(r+1)} - 1$ converts these into elementary modular
arithmetic.

**9.4 Hecke-eigenform rigidity.** For each odd $k$, $\sigma_k$ should be the
unique (up to scalar) multiplicative function satisfying
$f(m)f(n) = \sum_{d \mid \gcd(m,n)} d^k f(mn/d^2)$ together with
$f(p) = 1 + p^k$, since the convolution law is equivalent to being a simultaneous
Hecke eigenfunction with prescribed eigenvalues.

---

## 10. Conclusion

The number of $E_8$ vectors of squared length $2n$ is exactly $240\,\sigma_3(n)$,
the Siegel–Weil identity $\theta_{E_8} = E_4$ in rank $8$. Beneath this equality
lies a complete Hecke-eigenform structure, visible purely at the level of divisor
sums: a geometric closed form and three-term recurrence on prime powers,
multiplicativity across coprime arguments, and a single global convolution law
that packages all Hecke relations. The vector counts of the most symmetric
lattice in dimension $8$ are the coefficient system of a weight-$4$ Hecke
eigenform — the arithmetic incarnation of one of the cleanest bridges between
geometry and number theory.
