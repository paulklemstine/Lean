# A Shift-Invariant Row-Sum Law for the Extended Eulerian Numbers

## Abstract

The classical Eulerian numbers $\left\langle n \atop k \right\rangle$ count
permutations of $\{1,\dots,n\}$ by their number of descents and satisfy the
well-known row identity $\sum_{k} \left\langle n \atop k \right\rangle = n!$. We
study a one-parameter deformation, the **extended Eulerian numbers**
$A(n,k,s)$, obtained by inserting a continuous real shift $s$ into the classical
alternating-binomial closed form; at $s=0$ they reduce to the ordinary Eulerian
numbers. We prove two results with a single, self-contained technique — the
forward finite-difference calculus. First, a **boundary vanishing theorem**:
$A(n,k,s) = 0$ for all $k \ge n+1$ and all real $s$, so every deformed row is
supported on the $n+1$ entries $k = 0,\dots,n$. Second, a **shift-invariant
row-sum law**: for every $n$ and every real $s$,
$\sum_{k=0}^{n} A(n,k,s) = n!$, independent of the shift. The row sum is thus a
rigid invariant of the deformation, and the classical identity is recovered as the
special case $s=0$. The proofs never invoke the Eulerian recurrence; they rest
only on the closed form and three structural facts about iterated forward
differences: annihilation of low-degree polynomials, the factorial value of the
top-order difference of a monomial, and the explicit alternating-binomial
expansion of an iterated difference. We include algorithms, numerical
verification, and applications to finite calculus and the distribution of sums of
uniform random variables.

**Keywords:** Eulerian numbers, forward finite difference, alternating binomial
sums, descents, factorial, Worpitzky-type identities, deformation invariant.

**MSC (informal):** enumerative combinatorics; finite difference calculus;
special sequences.

---

## 1. Introduction

### 1.1 The Eulerian numbers

Let $n \in \mathbb{N}$ and let $\sigma$ be a permutation of $\{1,\dots,n\}$. A
**descent** of $\sigma$ is an index $j$ with $\sigma(j) > \sigma(j+1)$. The
**Eulerian number** $\left\langle n \atop k \right\rangle$ is the number of
permutations of $\{1,\dots,n\}$ with exactly $k$ descents. These numbers form a
symmetric triangular array whose first rows are

$$
\begin{array}{c|ccccc}
n \backslash k & 0 & 1 & 2 & 3 & 4 \\\hline
0 & 1 & & & & \\
1 & 1 & & & & \\
2 & 1 & 1 & & & \\
3 & 1 & 4 & 1 & & \\
4 & 1 & 11 & 11 & 1 & \\
5 & 1 & 26 & 66 & 26 & 1
\end{array}
$$

Two elementary facts organize the array. The **symmetry**
$\left\langle n \atop k \right\rangle = \left\langle n \atop n-1-k \right\rangle$
comes from reversing a permutation (which exchanges ascents and descents), and the
**row sum**

$$
\sum_{k=0}^{n-1} \left\langle n \atop k \right\rangle = n!
$$

holds because grouping the $n!$ permutations by descent count partitions them.

A classical closed form expresses the Eulerian numbers as an alternating binomial
sum of powers:

$$
\left\langle n \atop k \right\rangle
   = \sum_{i=0}^{k} (-1)^i \binom{n+1}{i}\,(k+1-i)^{\,n}. \tag{1.1}
$$

### 1.2 A continuous deformation

We introduce a real shift parameter $s$ into (1.1).

> **Definition 1.1 (Extended Eulerian numbers).** For $n, k \in \mathbb{N}$ and
> $s \in \mathbb{R}$, define
> $$
> A(n,k,s) \;=\; \sum_{i=0}^{k} (-1)^i \binom{n+1}{i}\,\bigl((k+1-i) - s\bigr)^{\,n}
> \;\in\; \mathbb{R}.
> $$

At $s = 0$ we have $A(n,k,0) = \left\langle n \atop k \right\rangle$ by (1.1). For
generic $s$, $A(n,k,s)$ is a real number that need not be an integer, need not be
nonnegative, and does not inherit the symmetry of the classical row. The shift $s$
is a continuous dial deforming the entire triangle.

### 1.3 Results

We prove two theorems, both uniformly in $s$.

- **Theorem A (Boundary vanishing).** For all $n,k$ with $k \ge n+1$ and all
  $s \in \mathbb{R}$, $A(n,k,s) = 0$. Hence the $n$-th deformed row is supported on
  $k \in \{0,1,\dots,n\}$.

- **Theorem B (Shift-invariant row sum).** For all $n \in \mathbb{N}$ and all
  $s \in \mathbb{R}$,
  $$
  \sum_{k=0}^{n} A(n,k,s) = n!.
  $$
  In particular the row sum is independent of $s$, and $s=0$ recovers
  $\sum_k \left\langle n \atop k \right\rangle = n!$.

The novelty is not the classical identity but its **rigidity**: the individual
entries vary continuously and nontrivially with $s$, yet the row total is frozen.
Both proofs are conducted entirely within the forward finite-difference calculus
and never use the Eulerian recurrence
$\left\langle n \atop k \right\rangle = (k+1)\left\langle n-1 \atop k \right\rangle
+ (n-k)\left\langle n-1 \atop k-1 \right\rangle$. This is deliberate: it gives a
non-circular account, since the numbers are *defined* by the closed form of
Definition 1.1 rather than by the recurrence.

---

## 2. The finite-difference toolkit

### 2.1 The forward difference operator

> **Definition 2.1.** For a function $f$ defined on $\mathbb{R}$ (or on
> $\mathbb{N}$) the **forward difference with step $1$** is
> $$
> (\Delta f)(x) = f(x+1) - f(x).
> $$
> Its $n$-fold iterate is written $\Delta^n$, with $\Delta^0 = \mathrm{id}$.

The operator $\Delta$ is the discrete analogue of differentiation. We record three
structural facts; all are standard and self-contained.

> **Lemma 2.2 (Explicit expansion).** For every $f$, every $n \in \mathbb{N}$, and
> every $x$,
> $$
> (\Delta^n f)(x) = \sum_{k=0}^{n} (-1)^{\,n-k}\binom{n}{k}\, f(x+k).
> $$

*Proof.* Induction on $n$ using the binomial recurrence
$\binom{n+1}{k} = \binom{n}{k} + \binom{n}{k-1}$; the base case $n=0$ is trivial
and the inductive step regroups the telescoped shifts. $\square$

> **Lemma 2.3 (Degree annihilation).** If $p$ is a real polynomial of degree at
> most $n$, then $\Delta^{n+1} p \equiv 0$.

*Proof.* Each application of $\Delta$ lowers the degree by exactly one (the
leading term $a\,x^m$ maps to $a\,m\,x^{m-1} + \text{lower}$), so after $n+1$
applications a polynomial of degree $\le n$ becomes the zero polynomial. $\square$

> **Lemma 2.4 (Factorial value, with translation invariance).** For every
> $n \in \mathbb{N}$ and every constant $c \in \mathbb{R}$,
> $$
> \Delta^n\!\bigl[x \mapsto (x+c)^n\bigr] \equiv n!.
> $$
> In particular $\Delta^n[x \mapsto x^n] \equiv n!$.

*Proof.* Write $g(x) = x^n$. The composition $g(x+c) = (x+c)^n$ satisfies
$\Delta^n[g(\,\cdot\,+c)] = (\Delta^n g)(\,\cdot\,+c)$ because $\Delta$ commutes
with translation of the argument. It therefore suffices to prove
$\Delta^n[x^n] = n!$. This follows by induction: $\Delta[x^n]$ is a monic
polynomial of degree $n-1$ with leading coefficient $n$, and iterating multiplies
the leading coefficients $n, n-1, \dots, 1$, leaving the constant $n!$ after $n$
steps; equivalently, apply Lemma 2.3 to see the result is constant and Lemma 2.2
to evaluate it. $\square$

### 2.2 Matching the closed form to a difference

The closed form of Definition 1.1 is an alternating binomial sum, and Lemma 2.2
says that iterated differences are *exactly* alternating binomial sums. The two
are the same object once the summation index is reflected. This identification is
the engine behind both theorems: the extended Eulerian numbers, and their row
sums, are iterated forward differences in disguise.

---

## 3. Boundary vanishing (Theorem A)

> **Theorem A.** For all $n, k \in \mathbb{N}$ with $k \ge n+1$ and all
> $s \in \mathbb{R}$, $A(n,k,s) = 0$.

**Proof.** Fix $k \ge n+1$. In the defining sum
$A(n,k,s) = \sum_{i=0}^{k} (-1)^i \binom{n+1}{i}(k+1-i-s)^n$, the binomial
coefficient $\binom{n+1}{i}$ vanishes for $i > n+1$. Hence only the terms
$i = 0,\dots,n+1$ contribute, and

$$
A(n,k,s) = \sum_{i=0}^{n+1} (-1)^i \binom{n+1}{i}\,(k+1-i-s)^n. \tag{3.1}
$$

Reflect the index by $i \mapsto n+1-i$. Using $\binom{n+1}{n+1-i} = \binom{n+1}{i}$
and $(-1)^{n+1-i} = (-1)^{n+1}(-1)^{-i}$, the right-hand side of (3.1) becomes
(up to the global sign that we track below) the alternating binomial sum

$$
\sum_{i=0}^{n+1} (-1)^{\,(n+1)-i}\binom{n+1}{i}\, p\bigl((k-n) + i\bigr),
\qquad p(x) := (x - s)^n,
$$

which by Lemma 2.2 is exactly $\bigl(\Delta^{n+1} p\bigr)(k-n)$. Now
$p(x) = (x-s)^n$ is a polynomial of degree $n$, so by Lemma 2.3,
$\Delta^{n+1} p \equiv 0$. Therefore $A(n,k,s) = 0$. $\square$

**Remark.** The proof uses nothing about $k$ beyond $k \ge n+1$ (which guarantees
the full range $i=0,\dots,n+1$ lies inside the summation) and nothing about $s$
beyond the fact that $x \mapsto (x-s)^n$ has degree $n$. The vanishing is a
degree phenomenon, uniform in the shift.

---

## 4. The shift-invariant row sum (Theorem B)

The proof has three movements: (i) interchange the order of summation and package
the inner sum as a discrete antiderivative; (ii) recognize the result as a single
iterated forward difference; (iii) evaluate that difference via Lemma 2.4.

### 4.1 A discrete antiderivative

> **Definition 4.1.** For $n \in \mathbb{N}$ and $s \in \mathbb{R}$ set
> $$
> Q(t) \;=\; \sum_{m=0}^{t-1} \bigl(m + 1 - s\bigr)^{\,n}, \qquad t \in \mathbb{N},
> $$
> with $Q(0) = 0$ (the empty sum).

> **Lemma 4.2.** $\displaystyle (\Delta Q)(t) = (t + 1 - s)^n$ for all
> $t \in \mathbb{N}$.

*Proof.* $(\Delta Q)(t) = Q(t+1) - Q(t) = \sum_{m=0}^{t}(m+1-s)^n -
\sum_{m=0}^{t-1}(m+1-s)^n = (t+1-s)^n$. $\square$

Thus $Q$ is a discrete antiderivative of the shifted power $t \mapsto (t+1-s)^n$.

### 4.2 Reassembling the row sum as an iterated difference

> **Lemma 4.3 (Fubini reindexing).** For every $n$ and $s$,
> $$
> \sum_{k=0}^{n} A(n,k,s)
> = \sum_{i=0}^{n} (-1)^i \binom{n+1}{i}\, Q(n+1-i).
> $$

*Proof.* Expand and interchange the order of summation:
$$
\sum_{k=0}^{n} A(n,k,s)
= \sum_{k=0}^{n}\sum_{i=0}^{k} (-1)^i\binom{n+1}{i}(k+1-i-s)^n
= \sum_{i=0}^{n} (-1)^i\binom{n+1}{i}\sum_{k=i}^{n} (k+1-i-s)^n .
$$
The interchange is valid because the index set is the triangle
$\{(k,i): 0 \le i \le k \le n\}$. In the inner sum substitute $m = k-i$, so $m$
ranges over $0,\dots,n-i$ and $k+1-i-s = m+1-s$:
$$
\sum_{k=i}^{n}(k+1-i-s)^n = \sum_{m=0}^{n-i}(m+1-s)^n = Q(n+1-i). \qquad \square
$$

> **Lemma 4.4.** $\displaystyle \sum_{k=0}^{n} A(n,k,s) = \bigl(\Delta^{n+1} Q\bigr)(0).$

*Proof.* Start from Lemma 4.3. Reindex by $j = n+1-i$; as $i$ runs $0,\dots,n$,
$j$ runs $n+1,\dots,1$, and $(-1)^i = (-1)^{n+1-j}$,
$\binom{n+1}{i} = \binom{n+1}{n+1-j} = \binom{n+1}{j}$. Hence
$$
\sum_{i=0}^{n}(-1)^i\binom{n+1}{i}Q(n+1-i)
= \sum_{j=1}^{n+1}(-1)^{\,(n+1)-j}\binom{n+1}{j}\,Q(j).
$$
The missing $j=0$ term contributes $(-1)^{n+1}\binom{n+1}{0}Q(0) = 0$ because
$Q(0)=0$, so we may extend the sum to $j=0,\dots,n+1$ without changing its value.
By Lemma 2.2 (with $f = Q$, evaluated at $x=0$),
$$
\sum_{j=0}^{n+1}(-1)^{\,(n+1)-j}\binom{n+1}{j}Q(j) = \bigl(\Delta^{n+1}Q\bigr)(0).
\qquad \square
$$

### 4.3 Evaluation

> **Theorem B.** For all $n \in \mathbb{N}$ and $s \in \mathbb{R}$,
> $$
> \sum_{k=0}^{n} A(n,k,s) = n!.
> $$

**Proof.** By Lemma 4.4 the row sum equals $(\Delta^{n+1}Q)(0)$. Peel off one
difference and apply Lemma 4.2:
$$
\Delta^{n+1} Q = \Delta^{n}\bigl(\Delta Q\bigr)
= \Delta^{n}\bigl[t \mapsto (t+1-s)^n\bigr].
$$
The inner function is $t \mapsto (t + (1-s))^n$, a shifted monomial of degree $n$.
By Lemma 2.4 (translation-invariant factorial value with $c = 1-s$),
$\Delta^{n}[t \mapsto (t+1-s)^n] \equiv n!$, a constant independent of $s$.
Evaluating at $0$ gives $(\Delta^{n+1}Q)(0) = n!$. Therefore
$\sum_{k=0}^{n} A(n,k,s) = n!$. $\square$

**Why the shift disappears.** The parameter $s$ enters the argument only as the
translation constant $c = 1-s$ inside the monomial. The top-order difference
$\Delta^n$ of a degree-$n$ polynomial returns its (constant) leading data scaled
by $n!$, and translation does not change the leading coefficient. The row sum is
therefore blind to $s$ by the same mechanism that makes it blind to *where* one
starts differencing.

---

## 5. Algorithms

We describe three procedures used to compute and verify the results.

### 5.1 Direct evaluation of $A(n,k,s)$

Compute $A(n,k,s)$ from Definition 1.1 with an explicit alternating binomial sum.
Precompute the binomial coefficients $\binom{n+1}{i}$ by the multiplicative
recurrence to avoid factorial overflow. Complexity: $O(k)$ arithmetic operations
per entry (using $O(\log n)$-cost exponentiation), or $O(k)$ with repeated
squaring amortized.

```
function A(n, k, s):
    total <- 0
    binom <- 1                      # binom = C(n+1, 0)
    for i in 0 .. k:
        term <- (-1)^i * binom * (k + 1 - i - s)^n
        total <- total + term
        binom <- binom * (n + 1 - i) / (i + 1)   # update to C(n+1, i+1)
    return total
```

### 5.2 Row-sum verification by iterated differencing

Rather than summing a row entrywise, verify Theorem B by computing
$(\Delta^{n+1}Q)(0)$ directly, exposing the mechanism of the proof. Build the
finite table $Q(0),\dots,Q(n+1)$, then apply $\Delta$ repeatedly $n+1$ times and
read off the surviving value. This must equal $n!$ for every $s$.

```
function rowsum_via_differences(n, s):
    Q <- array of length n+2
    Q[0] <- 0
    for t in 1 .. n+1:
        Q[t] <- Q[t-1] + (t - s)^n        # since Q(t)-Q(t-1) = (t-s)^n = ((t-1)+1-s)^n
    D <- copy(Q)
    repeat (n+1) times:
        D <- [ D[j+1] - D[j] for j in 0 .. len(D)-2 ]
    return D[0]                             # equals n!
```

### 5.3 Deformation sweep

To exhibit shift invariance empirically, sweep $s$ over a grid, compute the full
row $A(n,0,s),\dots,A(n,n,s)$ and its sum, and confirm the sum is constant at $n!$
while the entries vary. This is the numerical fingerprint of Theorem B.

---

## 6. Numerical illustration

For $n = 4$ the classical row ($s = 0$) is $1, 11, 11, 1, 0$ on $k=0,\dots,4$
(the last entry $A(4,4,0)=0$ sits just at the boundary $k=n$ and happens to
vanish because $\left\langle 4 \atop 4\right\rangle=0$; the genuine support of the
integer triangle is $k=0,\dots,n-1$). Summing gives $24 = 4!$.

Turning the dial to $s = \tfrac13$ produces a row of non-integer,
non-symmetric values, yet their sum is again exactly $24$. Sweeping
$s \in \{-2, -1, -\tfrac12, 0, \tfrac13, 1, \pi\}$ leaves the row sum pinned at
$4! = 24$ throughout, while columns $k \ge 5$ remain identically zero, confirming
Theorem A. The accompanying software reproduces these checks in exact rational
arithmetic (for rational $s$) and to machine precision otherwise.

---

## 7. Applications and context

### 7.1 Finite calculus and Worpitzky-type identities

The Eulerian numbers are the change-of-basis coefficients between ordinary powers
and binomial (falling-factorial) bases — the content of Worpitzky's identity
$x^n = \sum_k \left\langle n \atop k \right\rangle \binom{x+k}{n}$. The extended
numbers $A(n,k,s)$ are the corresponding coefficients for the *shifted* power
$(x-s)^n$. Theorem B, read in this basis, says that the total mass of the
decomposition is conserved under the shift — a discrete analogue of translation
invariance of an integral.

### 7.2 Sums of uniform random variables

Let $U_1,\dots,U_n$ be independent random variables uniform on $[0,1]$ and let
$S_n = U_1+\cdots+U_n$. The density of $S_n$ (the Irwin–Hall distribution) is a
piecewise polynomial whose pieces are governed by the Eulerian numbers. Sliding
the sum, $S_n - s$, corresponds exactly to the shift parameter, and the
conservation of total probability $\int f_{S_n - s} = 1$ is, after the appropriate
normalization by $n!$, the row-sum invariant of Theorem B. The abstract identity
thus has a probabilistic reading: shifting a distribution moves mass around but
never creates or destroys it.

### 7.3 Non-circular foundations

Standard treatments define the Eulerian numbers by their recurrence, prove the
closed form (1.1) from it, and then recover the recurrence from the closed form —
a loop that is logically fine but pedagogically circular. By taking the closed
form as the *definition* (Definition 1.1) and proving the row sum purely from the
difference calculus, we obtain a development in which the row-sum law rests on
independent foundations. This is precisely the appeal of the finite-difference
route: it needs only Lemmas 2.2–2.4, none of which mention descents or the
recurrence.

---

## 8. Discussion

The two theorems illustrate a general principle: an identity that appears
special often survives a continuous deformation, revealing that the "real"
content is a structural invariant rather than an accident of integer values. Here
the invariant is the top-order forward difference of a monomial, whose value $n!$
is manifestly independent of any translation of the argument. The deformation
parameter $s$ is exactly a translation, and so it cannot be felt by the invariant.

The technique is robust. Any closed form built as an alternating binomial sum of a
degree-$n$ polynomial in the summation index will exhibit an analogous boundary
vanishing (by degree annihilation) and an analogous conserved row sum (by the
factorial value of the top difference). The Eulerian case is the archetype.

---

## 9. Future directions

Several avenues extend the present work.

1. **Higher-step and multivariate shifts.** Replace the single real shift $s$ by
   a vector of shifts or by a difference step $h \ne 1$; the factorial value
   becomes $h^n\,n!$ and one expects a correspondingly scaled invariant.

2. **$q$-deformations.** Investigate a $q$-analogue $A_q(n,k,s)$ built from
   $q$-binomial coefficients and study whether a $q$-factorial row-sum invariant
   persists under the shift.

3. **Signed and colored descents.** Extend the descent statistic to signed
   permutations (type $B$) and to $r$-colored permutations, and identify the
   corresponding deformation and its conserved row sum.

4. **Moments and higher symmetric functions of a row.** Beyond the row sum
   (first moment), determine which symmetric functions of a deformed row are
   invariant under $s$ and which vary, quantifying the rigidity precisely.

---

## 10. Conclusion

We introduced the extended Eulerian numbers $A(n,k,s)$, a continuous deformation
of the classical Eulerian numbers, and established two uniform-in-$s$ results by a
single finite-difference argument: the deformed triangle stays triangular
(boundary vanishing), and every deformed row sums to $n!$ (shift-invariant row
sum). The classical identity $\sum_k \left\langle n \atop k \right\rangle = n!$
emerges as the snapshot at $s=0$ of a rigid law. The proofs are self-contained,
free of the Eulerian recurrence, and rest only on the annihilation, factorial, and
expansion properties of the forward difference operator — a compact demonstration
that the humblest tool of finite calculus can pin down an invariant that survives
an entire one-parameter family of deformations.
