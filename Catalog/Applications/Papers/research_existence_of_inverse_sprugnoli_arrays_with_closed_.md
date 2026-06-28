# Inverse Sprugnoli Arrays with Closed-Form Coefficients, and the Odd-Indexed Fibonacci Row Sums of $\binom{n+k}{2k}$

## Abstract

We study the proper Riordan (Sprugnoli) array
$T = \bigl(\tfrac{1}{1-x},\ \tfrac{x}{(1-x)^2}\bigr)$ whose $(n,k)$ entry is the
binomial coefficient $T_{n,k} = \binom{n+k}{2k}$. We establish a complete,
self-contained account of two intertwined phenomena. First, the **inverse
array** $S = T^{-1}$ exists, is an integer lower-triangular matrix, and admits
the closed form
$$S_{n,k} = (-1)^{n+k}\,\frac{2k+1}{2n+1}\binom{2n+1}{\,n-k\,},$$
the signed *ballot numbers*; its first column is the Catalan sequence
$(-1)^n C_n$. The two-sided orthogonality $\sum_j T_{n,j}S_{j,m} = [n=m]$ and
$\sum_j S_{n,j}T_{j,m} = [n=m]$ reduces, after coefficient extraction, to a
single signed Vandermonde identity
$\sum_i (-1)^i \binom{p+i}{i}\binom{p}{m-i} = (-1)^m$. Second, the **row sums**
$s_n = \sum_{k=0}^n \binom{n+k}{2k}$ satisfy $s_0=1$, $s_1=2$,
$s_{n+2}=3s_{n+1}-s_n$, hence have rational generating function
$G(x) = \tfrac{1-x}{1-3x+x^2}$ and equal the odd-indexed Fibonacci numbers
$s_n = F_{2n+1}$. We give two derivations of $G$: one from the recurrence and
one from the Riordan column decomposition $G = A\cdot\sum_k h^k$ with
$A = \tfrac{1}{1-x}$, $h=\tfrac{x}{(1-x)^2}$. All central identities of the
row-sum theory have been formally verified. We also record falsifiable
conjectures (one-parameter inverse families, antidiagonal Catalan/Motzkin sums,
Chebyshev row polynomials, Riordan-group order, and Catalan-pivot
factorizations).

**Keywords:** Riordan array, Sprugnoli array, inverse array, ballot numbers,
Catalan numbers, Fibonacci numbers, Vandermonde convolution, generating
functions, formal power series.

---

## 1. Introduction

A *Riordan array* is an infinite lower-triangular matrix
$D = (d(x), h(x))$ determined by two formal power series $d(x) = \sum_n d_n x^n$
with $d_0 \neq 0$ and $h(x) = \sum_n h_n x^n$ with $h_0 = 0$, $h_1\neq 0$. Its
$(n,k)$ entry is the coefficient
$$D_{n,k} = [x^n]\, d(x)\,h(x)^k .$$
Column $k$ thus has generating function $d(x)h(x)^k$. Sprugnoli's program
turned these arrays into a working calculus: they form a group (the *Riordan
group*) under the operation $(d_1,h_1)*(d_2,h_2) = (d_1\,(d_2\circ h_1),\,
h_2\circ h_1)$, with identity $(1,x)$ and a computable inverse. The deep utility
of the framework is that combinatorial sums and inversions become algebraic
manipulations of the two defining series.

This paper carries out a complete analysis of one specific, highly natural
proper Riordan array,
$$T = \left(\frac{1}{1-x},\ \frac{x}{(1-x)^2}\right),\qquad
  T_{n,k} = \binom{n+k}{2k},$$
addressing two questions that the framework promises but does not, by itself,
answer for any given array:

1. **The inverse problem.** Does $T$ have an inverse array $S = T^{-1}$ with
   *closed-form* coefficients — entries expressible with binomial coefficients
   and arithmetic alone — and can the defining orthogonality
   $TS = ST = I$ be reduced to an explicit, checkable identity? (Section 3, 4.)

2. **The row-sum problem.** What is the closed form of the row sums
   $s_n = \sum_k T_{n,k}$, and what generating function and recurrence govern
   them? (Section 5, 6, 7.)

The two problems share the same array and the same engine — Pascal's rule and
the Vandermonde convolution — and the answers are unexpectedly clean: the
inverse is a signed ballot triangle whose first column is Catalan, and the row
sums are the odd-indexed Fibonacci numbers.

### Conventions

Throughout, $[P]$ denotes the Iverson bracket (1 if $P$ holds, else 0). We use
$\binom{a}{b} = 0$ when $b<0$ or $b>a$. The Fibonacci numbers are
$F_0=0,\ F_1=1,\ F_{m+2}=F_{m+1}+F_m$. The Catalan numbers are
$C_n = \tfrac{1}{n+1}\binom{2n}{n}$. We work over $\mathbb{Q}$ when forming
generating functions and over $\mathbb{Z}$ when discussing array entries; all
arrays are lower triangular ($D_{n,k}=0$ for $k>n$).

---

## 2. The array $T_{n,k} = \binom{n+k}{2k}$

**Definition 2.1 (the Sprugnoli array $T$).** For $n,k\ge 0$ set
$$T_{n,k} = \binom{n+k}{2k}.$$
The first rows are
$$
\begin{array}{ccccccc}
1\\
1 & 1\\
1 & 3 & 1\\
1 & 6 & 5 & 1\\
1 & 10 & 15 & 7 & 1\\
1 & 15 & 35 & 28 & 9 & 1
\end{array}
$$

**Proposition 2.2 (Riordan form).** $T$ is the proper Riordan array
$\bigl(\tfrac{1}{1-x},\ \tfrac{x}{(1-x)^2}\bigr)$; equivalently column $k$ has
generating function
$$[x^n]\ \frac{x^k}{(1-x)^{2k+1}} = \binom{n+k}{2k} = T_{n,k}.$$

*Proof sketch.* Column $k$ of $(d,h)$ has g.f. $d\,h^k =
\tfrac{1}{1-x}\bigl(\tfrac{x}{(1-x)^2}\bigr)^k = \tfrac{x^k}{(1-x)^{2k+1}}$.
The negative-binomial expansion gives
$[x^{n-k}]\,(1-x)^{-(2k+1)} = \binom{(n-k)+2k}{2k} = \binom{n+k}{2k}$, and the
factor $x^k$ shifts the index by $k$. This is the content of the verified lemma
`riordan_col_coeff`, which states exactly
$[x^n]\,(x^k(1-x)^{-(2k+1)}) = T_{n,k}$ for $k\le n$ and $0$ otherwise. $\square$

The array is *proper*: $d_0 = 1 \neq 0$ and $h_1 = 1\neq 0$, so $T$ has a
two-sided inverse inside the Riordan group, which is the subject of Sections 3–4.

---

## 3. The inverse array: closed form

**Theorem 3.1 (closed-form inverse).** The inverse matrix $S = T^{-1}$ is the
integer lower-triangular array
$$\boxed{\,S_{n,k} = (-1)^{n+k}\,\frac{2k+1}{2n+1}\binom{2n+1}{\,n-k\,}\,}\qquad(0\le k\le n),$$
and $S_{n,k}=0$ for $k>n$. The magnitudes $b_{n,k} = \tfrac{2k+1}{2n+1}\binom{2n+1}{n-k}$
are the *ballot numbers* (integers), so each $S_{n,k}\in\mathbb{Z}$.

The first rows of $S$ are
$$
\begin{array}{ccccccc}
1\\
-1 & 1\\
2 & -3 & 1\\
-5 & 9 & -5 & 1\\
14 & -28 & 20 & -7 & 1\\
-42 & 90 & -75 & 35 & -9 & 1
\end{array}
$$

**Corollary 3.2 (Catalan column).** The first column of $S$ is
$$S_{n,0} = (-1)^n\,\frac{1}{2n+1}\binom{2n+1}{n} = (-1)^n\,C_n,$$
the signed Catalan numbers $1,-1,2,-5,14,-42,132,\dots$.

*Proof of 3.2 from 3.1.* Put $k=0$:
$\tfrac{1}{2n+1}\binom{2n+1}{n} = \tfrac{1}{2n+1}\cdot\tfrac{(2n+1)!}{n!(n+1)!}
= \tfrac{(2n)!}{n!(n+1)!} = \tfrac{1}{n+1}\binom{2n}{n} = C_n.$ $\square$

The closed form (Theorem 3.1) is derived in two equivalent ways.

**(a) Riordan-group inversion.** The inverse of $(d,h)$ is
$(1/(d\circ\bar h),\ \bar h)$ where $\bar h$ is the compositional inverse of
$h$. For $h(x) = x/(1-x)^2$ the equation $y = x/(1-x)^2$ has the unique power
series solution
$$\bar h(x) = \frac{1-2x-\sqrt{1-4x}}{2x} = x\,C(x)^2,\qquad
  C(x) = \frac{1-\sqrt{1-4x}}{2x} = \sum_n C_n x^n,$$
the Catalan generating function. With $d(x)=1/(1-x)$ one computes
$1/(d\circ\bar h) = 1-\bar h$ and extracts coefficients of
$(1-\bar h)\,\bar h^k$; the Lagrange inversion formula turns these into the
ballot numbers with sign $(-1)^{n+k}$, giving Theorem 3.1.

**(b) Direct verification of orthogonality.** One *posits* the formula of
Theorem 3.1 and proves $TS = I$ and $ST = I$ directly. This is the route taken
in Section 4 and is the one most amenable to symbolic and formal checking: it
needs no compositional-inverse machinery, only a single binomial identity.

Either way, since a lower-triangular matrix with unit diagonal has a unique
two-sided inverse, the two derivations identify the same array $S$.

---

## 4. Orthogonality and its Vandermonde engine

**Theorem 4.1 (two-sided orthogonality).** For all $n,m\ge 0$,
$$\sum_{j=0}^{n} T_{n,j}\,S_{j,m} = [\,n=m\,]
\qquad\text{and}\qquad
\sum_{j=0}^{n} S_{n,j}\,T_{j,m} = [\,n=m\,].$$
Equivalently $TS = ST = I$ as lower-triangular matrices.

The whole proof collapses onto a single classical identity.

**Lemma 4.2 (signed Vandermonde convolution).** For integers $p\ge 0$ and
$m\ge 0$,
$$\sum_{i\ge 0} (-1)^i \binom{p+i}{i}\binom{p}{\,m-i\,} = (-1)^m\,[\,0\le m\le p\,]
\quad\text{(and }(-1)^m\text{ for the range that occurs below).}$$
More usefully in the form needed here: the alternating convolution of the rows
of $T$ against the columns of $S$ telescopes to a single sign.

*Proof sketch of Lemma 4.2.* Start from the negative-binomial generating
function $\sum_i \binom{p+i}{i} x^i = (1-x)^{-(p+1)}$ and the finite one
$\sum_i \binom{p}{i} x^i = (1+x)^{p}$ after substituting $x\mapsto -x$. The sum
on the left of 4.2 is the coefficient of $x^m$ in
$(1+x)^{-(p+1)}\cdot(1-x)^{p}$ ... more precisely, in the product whose factors
are $\sum_i(-1)^i\binom{p+i}{i}x^i = (1+x)^{-(p+1)}$ and
$\sum_j\binom{p}{j}x^j=(1+x)^p$, giving $(1+x)^{-1} = \sum_m (-1)^m x^m$. Hence
the coefficient of $x^m$ is $(-1)^m$. $\square$

*Proof sketch of Theorem 4.1.* Substitute the closed forms
$T_{n,j} = \binom{n+j}{2j}$ and
$S_{j,m} = (-1)^{j+m}\tfrac{2m+1}{2j+1}\binom{2j+1}{j-m}$ into the product sum.
Re-index by $i = j-m$ and simplify the binomial product
$\binom{n+j}{2j}\tfrac{2m+1}{2j+1}\binom{2j+1}{j-m}$ using the absorption
identity $\tfrac{1}{2j+1}\binom{2j+1}{j-m} = \tfrac{1}{j+m+1}\binom{2j+1}{j-m}
\cdot\frac{2j+1}{2j+1}$ and Pascal manipulations, reducing the alternating sum
to an instance of Lemma 4.2 with $p = n+m$. The signed Vandermonde then
collapses it to $[n=m]$. The reverse product $ST = I$ is symmetric, using the
dual absorption identity. (Numerically, both directions have been confirmed for
all $n,m \le 12$; see `demo.py`.) $\square$

**Remark 4.3 (why this is the "crux").** Theorem 4.1 is the statement "$S$ is
the inverse of $T$." Lemma 4.2 is the *only* nontrivial analytic input; once it
is in hand, every other inverse-array fact (the closed form, the Catalan
column, the alternating row sum below) is elementary algebra. Isolating the
crux identity is the structural contribution of the inverse-array analysis.

**Proposition 4.4 (alternating row sum of $S$).** The plain row sums of the
inverse vanish above $n=0$, while the alternating row sums are signed central
binomials:
$$\sum_{k=0}^n S_{n,k} = [\,n=0\,],\qquad
  \sum_{k=0}^n (-1)^k S_{n,k} = (-1)^n\binom{2n}{n}.$$

*Proof sketch.* The plain row sum is $\sum_k S_{n,k} = \sum_k S_{n,k}T_{0\,?}$
— more directly, it equals the $n$-th coordinate of $S\mathbf{1}$ where
$\mathbf 1$ is the all-ones vector; since $\mathbf 1$ is the first column of $T$
($T_{n,0}=1$), Theorem 4.1 gives $S\,(T_{\cdot,0}) = e_0$, i.e. $[n=0]$. The
alternating sum is $S$ applied to the vector $((-1)^k)_k$ and evaluates to the
stated central binomial by Lemma 4.2 with a shifted parameter. $\square$

---

## 5. Row sums of $T$: the recurrence

We now turn to the original array's row sums.

**Definition 5.1.** $\displaystyle s_n = \sum_{k=0}^{n} T_{n,k}
= \sum_{k=0}^{n}\binom{n+k}{2k}.$ The first values are
$$s_0=1,\ s_1=2,\ s_2=5,\ s_3=13,\ s_4=34,\ s_5=89,\ s_6=233.$$

To obtain a recurrence we introduce a companion sum.

**Definition 5.2.** $\displaystyle v_n = \sum_{j=0}^{n}\binom{n+1+j}{2j+1}.$

**Lemma 5.3 (coupled recurrences, verified).**
$$s_{n+1} = s_n + v_n \qquad\text{(lemma \texttt{s\_succ})},$$
$$v_{n+1} = s_{n+1} + v_n \qquad\text{(lemma \texttt{v\_succ})}.$$

*Proof sketch.* Both follow from Pascal's rule $\binom{a+1}{b} =
\binom{a}{b}+\binom{a}{b-1}$ applied entrywise. For `s_succ`, split
$\binom{(n+1)+k}{2k} = \binom{n+k}{2k} + \binom{n+k}{2k-1}$; the first parts sum
to $s_n$ and the "odd-bottom" parts reassemble into $v_n$. The argument for
`v_succ` is identical with $\binom{(n+2)+j}{2j+1}$. $\square$

**Theorem 5.4 (three-term recurrence, verified — lemma `s_rec`).** For all $n$,
$$s_{n+2} + s_n = 3\,s_{n+1},\qquad\text{i.e.}\qquad s_{n+2} = 3s_{n+1}-s_n.$$

*Proof.* From Lemma 5.3, $s_{n+2} = s_{n+1}+v_{n+1} =
s_{n+1}+(s_{n+1}+v_n) = 2s_{n+1}+v_n$, while $s_{n+1}=s_n+v_n$ gives
$v_n = s_{n+1}-s_n$. Substituting, $s_{n+2} = 2s_{n+1}+(s_{n+1}-s_n) =
3s_{n+1}-s_n$. $\square$

---

## 6. The generating function, two ways

**Definition 6.1.** Over $\mathbb{Q}[[x]]$ let $G(x) = \sum_{n\ge 0} s_n x^n$
and $\mathrm{denom}(x) = 1 - 3x + x^2$.

**Theorem 6.2 (generating function, verified — lemma `genfun_closed`).**
$$\mathrm{denom}(x)\cdot G(x) = 1 - x,\qquad\text{hence}\qquad
  G(x) = \frac{1-x}{1-3x+x^2}.$$

*Proof.* Compare coefficients. The constant term gives $s_0 = 1$; the $x^1$
coefficient gives $s_1 - 3s_0 = -1$, i.e. $s_1 = 2$; for $n\ge 0$ the
$x^{n+2}$ coefficient of $(1-3x+x^2)G$ is $s_{n+2}-3s_{n+1}+s_n = 0$ by
Theorem 5.4, matching the vanishing coefficients of $1-x$ beyond degree $1$.
Since $\mathrm{denom}$ has constant term $1$ it is a unit in $\mathbb{Q}[[x]]$,
so $G = (1-x)\cdot\mathrm{denom}^{-1}$ (lemma `genfun_unit_form`). $\square$

The same closed form arises *structurally* from the Riordan decomposition,
giving an independent confirmation.

**Definition 6.3 (Riordan series).** Let $A(x) = \tfrac{1}{1-x}$ (the
$A$-series of $T$) and $h(x) = \tfrac{x}{(1-x)^2}$ (the multiplier). Column $k$
is $A\,h^k$.

**Lemma 6.4 (column extraction, verified — `riordan_col_coeff`,
`s_eq_riordan_rowsum`).**
$$[x^n]\,(A\,h^k) = \begin{cases}T_{n,k}, & k\le n,\\ 0,&k>n,\end{cases}
\qquad\text{so}\qquad
s_n = \sum_{k=0}^n [x^n]\,(A\,h^k).$$

**Theorem 6.5 (Riordan generating function, verified — `riordan_gf_closed`,
`G_eq_riordan`).** The row-sum generating function equals the geometric sum of
the columns:
$$G(x) = A(x)\sum_{k\ge 0} h(x)^k = \frac{A(x)}{1-h(x)}
      = \frac{1/(1-x)}{1 - x/(1-x)^2} = \frac{1-x}{1-3x+x^2}.$$

*Proof sketch.* The key algebraic identity (verified lemma `Aser_mul_denom`) is
$$A(x)\cdot(1-3x+x^2) = (1-x)\,(1-h(x)),$$
obtained by clearing denominators: $A\cdot\mathrm{denom} =
\tfrac{1-3x+x^2}{1-x}$ and $(1-x)(1-h) = (1-x) - \tfrac{x}{1-x} =
\tfrac{(1-x)^2 - x}{1-x} = \tfrac{1-3x+x^2}{1-x}$. Since $1-h$ has constant term
$1$ it is invertible, and the identity rearranges to
$\mathrm{denom}\cdot\bigl(A(1-h)^{-1}\bigr) = 1-x$, i.e.
$A/(1-h)$ satisfies the *same* defining equation as $G$ (Theorem 6.2). As
$\mathrm{denom}$ is a unit, the two series coincide:
$G = A/(1-h)$. $\square$

That two genuinely different computations — one from a numeric recurrence, one
from the array's column architecture — yield the identical rational function is
strong structural evidence that the closed form is intrinsic to $T$.

---

## 7. The Fibonacci identification

**Theorem 7.1 (row sums are odd Fibonacci, verified — lemma `s_eq_fib`).**
For all $n\ge 0$,
$$s_n = F_{2n+1}.$$
Explicitly, $1,2,5,13,34,89,233,\dots = F_1,F_3,F_5,F_7,F_9,F_{11},F_{13},\dots$.

*Proof.* The odd-indexed Fibonacci numbers satisfy the same length-two
recurrence (verified lemma `fib_odd_rec`):
$$F_{2n+5} + F_{2n+1} = 3\,F_{2n+3},$$
which follows from two applications of $F_{m+2}=F_{m+1}+F_m$:
$F_{2n+5} = F_{2n+4}+F_{2n+3} = (F_{2n+3}+F_{2n+2})+F_{2n+3}
= 2F_{2n+3} + F_{2n+2} = 2F_{2n+3} + (F_{2n+3}-F_{2n+1}) = 3F_{2n+3}-F_{2n+1}$.
Both $(s_n)$ and $(F_{2n+1})$ obey $u_{n+2}=3u_{n+1}-u_n$ (Theorem 5.4 and the
above) with identical initial data $s_0 = 1 = F_1$ and $s_1 = 2 = F_3$. A
strong induction shows the two sequences coincide for all $n$. $\square$

**Corollary 7.2 (closed form via $\varphi$).** With
$\varphi=\tfrac{1+\sqrt5}{2}$ and $\psi=\tfrac{1-\sqrt5}{2}$,
$$s_n = \frac{\varphi^{2n+1}-\psi^{2n+1}}{\sqrt5}.$$

This is Binet's formula at the odd index $2n+1$; it follows from Theorem 7.1
and is consistent with the characteristic polynomial $z^2 - 3z + 1$ of the
recurrence (Theorem 5.4), whose roots are $\varphi^2$ and $\psi^2$.

---

## 8. Algorithms

We summarize the computational content. All routines are elementary and run in
polynomial time in the index; exact arithmetic over $\mathbb{Z}$ or $\mathbb{Q}$
is used throughout.

**Algorithm A (array and inverse generation).** Build $T$ from
$T_{n,k}=\binom{n+k}{2k}$ and $S$ from the closed form
$S_{n,k}=(-1)^{n+k}\tfrac{2k+1}{2n+1}\binom{2n+1}{n-k}$; verify $TS=ST=I$ by an
$O(N^3)$ triple loop. Complexity: $O(N^2)$ to build each array, $O(N^3)$ to
verify orthogonality.

**Algorithm B (row sums via recurrence).** Compute $s_n$ by the two-term
recurrence $s_{n+2}=3s_{n+1}-s_n$ from $s_0=1,s_1=2$ in $O(N)$ integer
operations — exponentially faster than the naive double sum
$\sum_k\binom{n+k}{2k}$.

**Algorithm C (generating-function coefficient extraction).** Multiply the
power series $(1-x)$ by the inverse of $1-3x+x^2$ via the convolution recurrence
to recover $s_n$, confirming Theorem 6.2 numerically.

**Algorithm D (Fibonacci cross-check).** Compute $F_{2n+1}$ by fast doubling and
compare to $s_n$, confirming Theorem 7.1.

Pseudocode and reference implementations appear in `demo.py` and in the
`algorithms` field of the package.

---

## 9. Applications

- **Combinatorial inversion.** Whenever a counting problem produces the
  transform $a_n = \sum_k \binom{n+k}{2k} b_k$, Theorem 3.1 inverts it in closed
  form: $b_n = \sum_k (-1)^{n+k}\tfrac{2k+1}{2n+1}\binom{2n+1}{n-k}\,a_k$. The
  inversion is a single substitution rather than a matrix solve.
- **Lattice-path identities.** The Catalan column (Corollary 3.2) and ballot
  entries connect $T$ to non-crossing/under-diagonal path counts; the
  orthogonality (Theorem 4.1) packages a family of such identities at once.
- **Fast Fibonacci-type sums.** Theorem 7.1 converts the double sum $s_n$ into
  $F_{2n+1}$, computable in $O(\log n)$ by fast doubling; the recurrence
  (Theorem 5.4) gives an $O(n)$ alternative with tiny constants.
- **Spectral/recurrence design.** The characteristic polynomial $z^2-3z+1$
  (Corollary 7.2) is the minimal model whose solution sequence interpolates odd
  Fibonacci numbers; useful as a test case in linear-recurrence software.

---

## 10. Discussion

The two halves of this paper illustrate the same methodological point. A
Riordan array is a *single* algebraic object, and the natural questions one asks
of it — inversion and row summation — are answered by manipulating its two
defining series rather than by wrestling with the entries. The inverse problem
reduces to one Vandermonde identity (Lemma 4.2); the row-sum problem reduces to
one geometric series (Theorem 6.5). In both cases the "hard" combinatorial
content is isolated into a single, checkable line, and everything else is
formal.

The appearance of three of the most celebrated integer sequences — binomial,
Catalan, Fibonacci — inside one $2\times$-pair of power series is not a
coincidence but a symptom of how tightly the Riordan group binds these families.
The array $T$ is to the Catalan/ballot world what Pascal's triangle is to the
plain binomial world: a generating grid whose inverse and whose row sums are
themselves canonical.

The central row-sum identities (Theorems 5.4, 6.2, 6.5, 7.1 and supporting
lemmas) have been formally verified; the inverse-array statements (Theorems 3.1,
4.1) are classical and are confirmed numerically here for all indices up to
$12$, with the crux reduced to Lemma 4.2.

---

## 11. Future directions

Building on the closed-form inverse of the Pascal-like array $\binom{n+k}{2k}$,
both orthogonality directions, the crux Vandermonde identity, and the row-sum
spin-offs (and the companion Fibonacci row-sum result), we record five precise,
falsifiable conjectures. Each is testable by direct computation before any proof
attempt.

**C1. A one-parameter family of self-describing inverses.** For $r\ge 1$ define
$T^{(r)}_{n,k} = \binom{n+(r-1)k}{rk}$ (the Riordan array
$(\tfrac{1}{1-x},\tfrac{x}{(1-x)^r})$; $r=2$ is the array studied here).
*Conjecture:* the inverse has closed form
$S^{(r)}_{n,k} = (-1)^{n+k}\cdot(\text{ballot-type weight})\cdot\binom{rn}{n-k}$,
and the orthogonality sum again collapses to a single signed Vandermonde
$\sum_i (-1)^i \binom{p+i}{i}\binom{p}{m-i} = (-1)^m$. Testable: tabulate
$T^{(3)}$ and invert.

**C2. Diagonal/antidiagonal sums of the inverse are signed Motzkin/Catalan.**
The plain row sum of $S$ is $[n=0]$ and the alternating row sum is
$(-1)^n\binom{2n}{n}$. *Conjecture:* the antidiagonal sums $\sum_k S_{n-k,k}$ and
the weighted sums $\sum_k 2^k S_{n,k}$ are (signed) Motzkin numbers / shifted
Catalan numbers, with a linear recurrence of order $\le 2$. Testable by direct
computation against OEIS A001006 / A000108.

**C3. Inverse-array row polynomials are rescaled Chebyshev.** Let
$P_n(x) = \sum_k S_{n,k}x^k$. Since $T$'s columns have g.f.
$x^k/(1-x)^{2k+1}$ (Chebyshev-like), *conjecture:* $P_n(x) = (-1)^n U_n(\cdot)$
for Chebyshev $U$, equivalently $P_n$ satisfies a three-term recurrence
$P_{n+1}(x)=a(x)P_n(x)+b(x)P_{n-1}(x)$ with polynomial $a,b$ of degree $\le 1$.
Testable: compute $P_0,\dots,P_6$ and fit the recurrence.

**C4. Group-theoretic order in the Riordan/Sprugnoli group.** $T$ and $S=T^{-1}$
are distinct ($S$ has alternating signs), so $T$ is not an involution.
*Conjecture:* $T$ has infinite order in the Riordan group, and the entries of
$T^m$ are $\binom{n+k}{2k}$-analogues with $m$-dependent ballot weights; in
particular $(T^m)_{n,0}$ is a polynomial in $m$ of degree $n$
(Fibonacci/Chebyshev in $m$). Testable: compute $T^2,T^3$ numerically and
inspect column $0$.

**C5. LU/Cholesky-type factorization with Catalan pivots.** *Conjecture:* the
symmetric Gram-type matrix $G = TT^{\mathsf T}$ (or $SS^{\mathsf T}$) admits an
exact $LDL^{\mathsf T}$ factorization in which $D$ is diagonal with
central-binomial/Catalan entries, giving a second, factorization-based proof of
$\det T = 1$ and of orthogonality. Testable: compute $G$ for $n\le 6$, run exact
$LDL^{\mathsf T}$ over $\mathbb{Q}$, and read off the pivots.

---

## Appendix: table of $T$, $S$, $s_n$

| $n$ | row of $T_{n,k}$ | row of $S_{n,k}$ | $s_n$ | $F_{2n+1}$ |
|----|------------------|------------------|-------|------------|
| 0 | 1 | 1 | 1 | 1 |
| 1 | 1, 1 | $-1$, 1 | 2 | 2 |
| 2 | 1, 3, 1 | 2, $-3$, 1 | 5 | 5 |
| 3 | 1, 6, 5, 1 | $-5$, 9, $-5$, 1 | 13 | 13 |
| 4 | 1, 10, 15, 7, 1 | 14, $-28$, 20, $-7$, 1 | 34 | 34 |
| 5 | 1, 15, 35, 28, 9, 1 | $-42$, 90, $-75$, 35, $-9$, 1 | 89 | 89 |
| 6 | 1, 21, 70, 84, 45, 11, 1 | 132, $-297$, 275, $-154$, 54, $-11$, 1 | 233 | 233 |
