# A One-Parameter Deformation of the Eulerian Numbers and Its Recurrence

**Author:** Aristotle
**Date:** 2026-06-28
**Domain:** Applications (enumerative & algebraic combinatorics)

## Abstract

We introduce a one-parameter family of real numbers $A(n, k, s)$, the *extended
Eulerian numbers*, defined for natural numbers $n, k$ and a real shift parameter
$s$ by the alternating binomial closed form
$$
A(n, k, s) = \sum_{i=0}^{k} (-1)^i \binom{n+1}{i}\,(k+1-i-s)^n .
$$
At $s = 0$ this is Worpitzky's classical closed form for the Eulerian numbers
$\langle n, k\rangle$, which count permutations of $\{1,\dots,n\}$ with exactly $k$
descents. Our main theorem is that, although $A$ is *defined* by the closed form
rather than by a recurrence, it nonetheless satisfies the deformed Eulerian
recurrence
$$
A(n+1, k+1, s) = (k+2-s)\,A(n, k+1, s) + (n-k+s)\,A(n, k, s),
$$
together with the boundary values $A(0,0,s)=1$, $A(0,k+1,s)=0$, and the
left-edge identity $A(n,0,s)=(1-s)^n$. The proof is elementary and entirely
non-circular: it reduces, through three lemmas on alternating binomial sums, to
two classical facts — Pascal's rule and the absorption identity for binomial
coefficients. All statements have been formalized and machine-checked. We give
proof sketches, an exact rational algorithm for tabulating $A$, numerical
corroboration of an $s$-independent row-sum identity $\sum_k A(n,k,s)=n!$, and a
program of conjectural extensions (symmetry, Worpitzky expansion, generating
function, log-concavity).

## 1. Introduction

The Eulerian numbers $\langle n, k\rangle$ are among the most studied objects in
enumerative combinatorics. They count permutations by descents, appear in the
Worpitzky identity expressing monomials in the basis of binomial polynomials,
govern the volumes of the hypersimplices obtained by slicing a cube with parallel
hyperplanes, and arise as the coefficients of the Eulerian polynomials that encode
the cardinalities in the formula $\sum_{m\ge 0} m^n t^m = A_n(t)/(1-t)^{n+1}$.

They are most commonly *defined* by their triangular recurrence
$$
\langle n+1, k\rangle = (k+1)\langle n, k\rangle + (n-k+1)\langle n, k-1\rangle,
$$
or, in the shifted indexing used throughout this paper,
$$
\langle n+1, k+1\rangle = (k+2)\langle n, k+1\rangle + (n-k)\langle n, k\rangle .
$$

A recurring theme in modern combinatorics is the *deformation* of such discrete
families by a continuous parameter, exposing which structural identities are rigid
(parameter-independent) and which are flexible. In this paper we carry out one such
deformation in the cleanest possible way: we insert a single real shift $s$ into
Worpitzky's closed form and ask which classical identities survive.

The principal subtlety we address is one of *logical hygiene*. It is tempting to
define a deformed family by simply writing down a deformed recurrence and a set of
boundary conditions. But then any "theorem" that the family satisfies that
recurrence is a tautology. We instead take the closed form as the **sole**
definition and prove the recurrence as a genuine consequence. The recurrence is
therefore non-trivial content about a specific finite sum, not a restatement of the
definition.

### Summary of contributions

1. **Definition 1**: the extended Eulerian numbers $A(n,k,s)$ via the closed form.
2. **Theorem 1** (main): the deformed recurrence, proved from the closed form.
3. **Propositions 2–4**: the three boundary identities, including the left-edge
   identity $A(n,0,s)=(1-s)^n$.
4. **Lemmas 1–5**: an elementary, self-contained toolkit reducing everything to
   Pascal's rule and the absorption identity.
5. An exact rational tabulation algorithm and numerical evidence for the
   $s$-independent row-sum identity $\sum_k A(n,k,s)=n!$.

### 1.1 Historical and structural background

Eulerian numbers were first encountered by Euler in his study of the alternating
sums and the evaluation of $\sum_{m\ge 0} m^n t^m$. In the modern combinatorial
formulation, $\langle n, k\rangle$ is the number of permutations $\pi$ of
$\{1,\dots,n\}$ with exactly $k$ *descents*, i.e.\ positions $j$ with
$\pi(j) > \pi(j+1)$. The triangle of these counts satisfies the recurrence used as
the definition above and the closed (Worpitzky) form that we deform. Three
structural facts make the triangle ubiquitous: the rows are symmetric
($\langle n,k\rangle = \langle n, n-1-k\rangle$, from reversing a permutation), the
rows sum to $n!$ (every permutation has some descent count), and the entries are
log-concave and the row polynomials real-rooted.

The contribution of the present work is to ask how these facts behave under a
smooth deformation that is *not* defined by tampering with the recurrence, but by a
minimal, geometrically natural modification of the closed form: subtract a real
constant $s$ from the linear argument $k+1-i$. The recurrence then becomes a
theorem to be earned rather than a definition to be assumed, and the question of
which classical facts persist becomes precise. We find that the row-sum invariant
and the recurrence persist (with the shift appearing antisymmetrically), the left
edge deforms from $1$ to $(1-s)^n$, and the symmetry and log-concavity questions
become genuine open problems.

## 2. Definitions

Throughout, $n, k$ range over the natural numbers $\mathbb{N} = \{0,1,2,\dots\}$,
$s \in \mathbb{R}$, and $\binom{a}{b}$ denotes the natural-number binomial
coefficient (zero when $b > a$), cast into $\mathbb{R}$. Empty sums are zero.

**Definition 1 (extended Eulerian numbers, Lean: `A`).**
For $n, k \in \mathbb{N}$ and $s \in \mathbb{R}$,
$$
A(n, k, s) \;=\; \sum_{i=0}^{k} (-1)^i \binom{n+1}{i}\,(k + 1 - i - s)^n .
$$

We adopt the standard out-of-range convention $A(n, k, s) = 0$ for $k < 0$ or
$k > n$, consistent with the closed form (for $k>n$ the alternating sum vanishes;
for $k<0$ it is empty). At $s = 0$ the right-hand side is exactly the Worpitzky
closed form, so $A(n, k, 0) = \langle n, k\rangle$.

**Proposition 1 (rebased form, Lean: `A_eq`).**
$$
A(n, k, s) = \sum_{i=0}^{k} (-1)^i \binom{n+1}{i}\,\big((k + 1 - s) - i\big)^n .
$$

*Proof sketch.* Termwise, $k+1-i-s = (k+1-s)-i$; the summands are identical, so the
sums agree. $\square$

The rebased form isolates the "base point" $c := k+1-s$ and exhibits each row of
$A$ as an alternating binomial sum $\sum_i (-1)^i\binom{n+1}{i}(c-i)^n$. This is
precisely the shape handled by the lemmas of Section 4, which is why Proposition 1
is the bridge between the definition and the proof of the recurrence.

## 3. Boundary values

**Proposition 2 (apex, Lean: `A_zero_zero`).** For all $s\in\mathbb{R}$, $A(0,0,s)=1$.

*Proof sketch.* The sum has the single term $i=0$, equal to
$(-1)^0\binom{1}{0}(1-s)^0 = 1$. $\square$

**Proposition 3 (top row, Lean: `A_zero_succ`).** For all $k\in\mathbb{N}$ and
$s\in\mathbb{R}$, $A(0, k+1, s) = 0$.

*Proof sketch.* With $n=0$ every power $(\cdot)^0 = 1$, so
$A(0, m, s) = \sum_{i=0}^{m} (-1)^i \binom{1}{i}$. Since $\binom{1}{i}=0$ for $i\ge
2$, this is $\binom{1}{0} - \binom{1}{1} = 1 - 1 = 0$ whenever $m\ge 1$. (Formally,
induction on $k$ peeling the last term.) $\square$

**Proposition 4 (left edge, Lean: `A_at_zero`).** For all $n\in\mathbb{N}$ and
$s\in\mathbb{R}$, $A(n, 0, s) = (1-s)^n$.

*Proof sketch.* At $k=0$ the sum has the single term $i=0$:
$(-1)^0\binom{n+1}{0}(1-s)^n = (1-s)^n$. $\square$

Proposition 4 is the deformation's signature: the classical left edge
$\langle n,0\rangle = 1$ (the unique sorted permutation) bends into the geometric
sequence $(1-s)^n$. It also serves as the initial condition pinning down the
parameter, as discussed in Section 7.

## 4. The combinatorial toolkit

All of Section 5 reduces to two classical identities and three consequences about
alternating binomial sums. We state them over $\mathbb{R}$ exactly as formalized.

**Lemma 1 (Pascal's rule, Lean: `choose_succ_succ_cast`).**
$$
\binom{n+2}{j+1} = \binom{n+1}{j} + \binom{n+1}{j+1}.
$$

**Lemma 2 (absorption, Lean: `choose_absorb_cast`).**
$$
(j+1)\binom{n+1}{j+1} = (n+1)\binom{n}{j}.
$$

These are the only external inputs; both are standard and hold for all
$n, j\in\mathbb{N}$.

**Lemma 3 (Pascal split, Lean: `alt_binom_pascal_split`).** For all
$n,m,q\in\mathbb{N}$ and $c\in\mathbb{R}$,
$$
\sum_{i=0}^{m+1} (-1)^i \binom{n+2}{i} (c-i)^q
= \sum_{i=0}^{m+1} (-1)^i \binom{n+1}{i} (c-i)^q
\;-\; \sum_{j=0}^{m} (-1)^j \binom{n+1}{j} (c-1-j)^q .
$$

*Proof sketch.* Apply Lemma 1 to each $\binom{n+2}{i}$, splitting the left sum into
a $\binom{n+1}{i}$ part and a $\binom{n+1}{i-1}$ part. Reindex the second part by
$j = i-1$; this shifts the base from $c-i$ to $c-1-j$ and introduces the sign
$(-1)^{j+1}=-(-1)^j$, producing the stated difference. $\square$

**Lemma 4 (linear-factor absorption, Lean: `alt_binom_absorb_sum`).** For all
$n,m,q\in\mathbb{N}$ and $c\in\mathbb{R}$,
$$
\sum_{i=0}^{m} (-1)^i \binom{n+1}{i}\, i\, (c-i)^q
= -(n+1)\sum_{j=0}^{m-1} (-1)^j \binom{n}{j} (c-1-j)^q .
$$

*Proof sketch.* The $i=0$ term vanishes. For $i\ge 1$ write $i\binom{n+1}{i} =
(n+1)\binom{n}{i-1}$ (Lemma 2 with $j=i-1$), reindex $j=i-1$, and collect the sign
$(-1)^{i}=-(-1)^{j}$, which yields the factor $-(n+1)$ and the shifted base
$c-1-j$. $\square$

**Lemma 5 (Pascal recombine, Lean: `alt_binom_pascal_recombine`).** For all
$n,m,q\in\mathbb{N}$ and $d\in\mathbb{R}$,
$$
\sum_{j=0}^{m} (-1)^j \binom{n}{j} (d-j)^q
- \sum_{j=0}^{m-1} (-1)^j \binom{n}{j} (d-1-j)^q
= \sum_{j=0}^{m} (-1)^j \binom{n+1}{j} (d-j)^q .
$$

*Proof sketch.* The reverse of Lemma 3: reindex the second sum by $j\mapsto j+1$ so
both sums share the base $d-j$, then combine $\binom{n}{j}+\binom{n}{j-1} =
\binom{n+1}{j}$ via Pascal's rule. $\square$

Each lemma is a pure manipulation of finite sums; none mentions Eulerian numbers,
so using them to prove Theorem 1 introduces no circularity.

## 5. The main recurrence

**Theorem 1 (extended Eulerian recurrence, Lean: `A_recurrence`).** For all
$n,k\in\mathbb{N}$ and $s\in\mathbb{R}$,
$$
A(n+1, k+1, s) = (k+2-s)\,A(n, k+1, s) + (n-k+s)\,A(n, k, s).
$$

*Proof sketch.* Write $c := (k+2) - s$, so that by Proposition 1,
$$
A(n+1,k+1,s) = \sum_{i=0}^{k+1} (-1)^i \binom{n+2}{i}\,(c-i)^{\,n+1}.
$$
The derivation proceeds in three moves.

**(i) Split (Lemma 3, with $m=k$, $q=n+1$).** Replace $\binom{n+2}{i}$ by
$\binom{n+1}{i}+\binom{n+1}{i-1}$:
$$
A(n+1,k+1,s) = S_1 - S_2,
$$
where
$$
S_1 = \sum_{i=0}^{k+1} (-1)^i \binom{n+1}{i} (c-i)^{n+1}, \qquad
S_2 = \sum_{j=0}^{k} (-1)^j \binom{n+1}{j} (c-1-j)^{n+1}.
$$
Note $c-1 = (k+1) - s$, so $S_2$ is built on the base point of row $k$, while $S_1$
is built on the base point of row $k+1$.

**(ii) Lower the exponent via absorption (Lemma 4).** In each of $S_1, S_2$ write
the factor $(c-i)^{n+1} = (c-i)\,(c-i)^{n}$ and expand $c-i = c - i$. The constant
part $c\,(c-i)^n$ reproduces $c$ times an order-$n$ row sum; the linear part
$-i\,(c-i)^n$ is exactly the sum to which Lemma 4 applies, converting a
$\binom{n+1}{i}\,i$ weight into an $(n+1)\binom{n}{j}$ weight with the base shifted
by one. Concretely,
$$
S_1 = c\,A(n,k+1,s) + (n+1)\sum_{j=0}^{k} (-1)^j \binom{n}{j} (c-1-j)^n,
$$
and similarly $S_2$ reduces to $(c-1)\,A(n,k,s)$ plus an order-$n$, $\binom{n}{\cdot}$
correction with base $c-2$, after one further application of the same identity.

**(iii) Recombine (Lemma 5).** The leftover $\binom{n}{\cdot}$ sums from (ii),
differing by exactly the shift handled in Lemma 5, recombine into a single
$\binom{n+1}{\cdot}$ sum, i.e. back into a copy of $A(n,\cdot,s)$. Collecting the
constant coefficients from the $c\,(c-i)^n$ parts and the $\pm(n+1)$ factors from
the absorption steps, the base points $c = (k+2)-s$ and $c-1=(k+1)-s$ distribute so
that the total coefficient of $A(n,k+1,s)$ is $(k+2-s)$ and the total coefficient
of $A(n,k,s)$ is $(n-k+s)$. This is the claimed identity. $\square$

The parameter $s$ is inert throughout: it enters only through the base points
$c, c-1$ and is carried verbatim into the final coefficients. This explains the
striking structural feature of the result.

**Corollary 1 (balanced weights).** The two coefficients of Theorem 1 satisfy
$$
(k+2-s) + (n-k+s) = n+2,
$$
independent of both $k$ and $s$.

*Proof.* Immediate. $\square$

**Corollary 2 (classical specialization).** Setting $s=0$ recovers the standard
Eulerian recurrence $\langle n+1,k+1\rangle = (k+2)\langle n,k+1\rangle +
(n-k)\langle n,k\rangle$, with $A(n,k,0)=\langle n,k\rangle$ and $A(n,0,0)=1$.

### 5.1 Remarks on the proof structure

The three-move structure split $\to$ absorb $\to$ recombine is forced by the shape
of the closed form. The left-hand side $A(n+1,k+1,s)$ carries two simultaneous
increments relative to the target row $A(n,\cdot,s)$: the upper binomial index rises
from $n+1$ to $n+2$, and the exponent rises from $n$ to $n+1$. Pascal's rule
(Lemma 1) is exactly the tool that lowers the binomial index by one, while the
absorption identity (Lemma 2) is exactly the tool that lowers the exponent by one
at the cost of producing a fresh $\binom{n}{\cdot}$ sum. The recombination step
(Lemma 5) then repays that cost, folding the stray $\binom{n}{\cdot}$ sums back into
a single $\binom{n+1}{\cdot}$ sum, i.e.\ a clean copy of a target-row value. No
other identities are needed, which is why the proof is genuinely elementary.

It is worth emphasizing where the parameter $s$ lives during this computation. It
never appears inside any binomial coefficient and never participates in either
classical identity; it appears only inside the base points $c=(k+2)-s$ and
$c-1=(k+1)-s$, which are scalars carried passively through every algebraic step.
Consequently the same proof that establishes the classical recurrence at $s=0$
establishes the deformed recurrence at all $s$ simultaneously: the shift is, in a
precise sense, a spectator. This is the structural reason behind
Corollary 1 (balanced weights) and, in turn, behind the parameter-independent
row-sum identity of Section 6.3.

### 5.2 Non-circularity

Because $A$ is defined solely by Definition 1 (the closed form) and the recurrence
is derived from Lemmas 1–5, none of which mention $A$ or Eulerian numbers, the
recurrence is logically independent content rather than a restatement of a defining
property. In particular one may legitimately use the recurrence and the boundary
values to prove further identities (such as the row sum) without circularity, since
those downstream proofs rest on a theorem, not on an assumption.

## 6. Algorithms and numerical results

### 6.1 Exact tabulation by the recurrence

Theorem 1 together with the boundary values yields an $O(n^2)$ dynamic program that
fills the triangle row by row using only exact rational arithmetic. Maintaining the
current row $\big(A(m,j,s)\big)_{j=0}^{m}$, the next row is
$$
A(m+1, j, s) = (j+1-s)\,A(m, j, s) + (m-j+s)\,A(m, j-1, s),
$$
with the convention that out-of-range entries are $0$ and $A(0,0,s)=1$. (This is
Theorem 1 reindexed: replace $n+1\mapsto m+1$, $k+1\mapsto j$.)

### 6.2 Independent verification against the closed form

Computing $A(n,k,s)$ two ways — directly from the closed form (Definition 1) and
bottom-up from the recurrence (Section 6.1) — provides a stringent cross-check of
Theorem 1. In exact rational arithmetic the two agree for every $0\le k\le n\le 7$
and every tested shift $s\in\{0, \tfrac13, \tfrac12, \tfrac{7}{10}, 1\}$.

### 6.3 The factorial row-sum

A rigid (parameter-independent) invariant is the row sum.

**Observation (row-sum identity).** Numerically, for all tested $n$ and $s$,
$$
\sum_{k=0}^{n} A(n,k,s) = n!.
$$
The mechanism is Corollary 1: summing the recurrence over a full row multiplies the
old row sum by the constant total weight, and the $\pm s$ terms cancel pairwise, so
the totals follow the factorials from the apex $A(0,0,s)=1$. This identity is stated
as a conjecture (with a formalizable telescoping proof) in Section 7; the present
paper verifies it numerically and proves the ingredients (Theorem 1, Corollary 1,
boundary values) it requires.

### 6.4 Worked instance

At $s = \tfrac12$, row $n=2$ is $\big(\tfrac14, \tfrac32, \tfrac14\big)$ (sum
$2=2!$). Growing $A(3,1,\tfrac12)$ by Theorem 1 with $n=2$, $k=0$:
$$
A(3,1,\tfrac12) = (0+2-\tfrac12)\,A(2,1,\tfrac12) + (2-0+\tfrac12)\,A(2,0,\tfrac12)
= \tfrac32\cdot\tfrac32 + \tfrac52\cdot\tfrac14 = \tfrac94 + \tfrac58 = \tfrac{23}{8},
$$
matching the value $\tfrac{23}{8}$ obtained directly from the closed form
(Definition 1).

### 6.5 Relation to classical theory and applications

The specialization $A(n,k,0)=\langle n,k\rangle$ connects the deformation to the
several classical roles of the Eulerian numbers, and suggests where the parameter
$s$ might acquire meaning.

*Permutation statistics.* At $s=0$ the entries count descents. For $s\in(0,1)$ the
entries are no longer integers, so they are not literal counts; rather they are a
continuous interpolation whose row sums remain $n!$. One natural reading is that
$s$ tilts the uniform weighting of permutations: the boundary value
$A(n,0,s)=(1-s)^n$ is precisely the weight one would assign to the unique
descent-free (sorted) permutation if each of the $n$ comparisons contributed a
factor $(1-s)$, hinting at a $q$-analogue-like statistical interpretation.

*Power sums and Worpitzky.* The classical Worpitzky identity
$x^n = \sum_{k} \langle n,k\rangle \binom{x+k}{n}$ is the bridge from Eulerian
numbers to the evaluation of $\sum_m m^n$. The conjectural shifted expansion
$(x-s)^n = \sum_{k} A(n,k,s)\binom{x-k}{n}$ (Section 7) would extend that bridge to
shifted power sums $\sum_m (m-s)^n$, of interest in the theory of Bernoulli and
Euler polynomials, where shifts of the argument are the defining operation.

*Geometry and splines.* Eulerian numbers measure the volumes of the slices
obtained by cutting the unit $n$-cube with the parallel hyperplanes
$x_1+\dots+x_n = k$, equivalently the values of the uniform-sum (Irwin–Hall)
density. A constant shift of the cutting level corresponds exactly to subtracting a
constant from the sum, which is the operation our parameter $s$ performs on the
argument. The left-edge value $(1-s)^n$ is the volume of a shifted corner simplex,
the simplest such slice, suggesting that the whole family $A(n,\cdot,s)$ records the
volumes of *shifted* cube slices — a continuous family of B-spline-like weights.

These connections are heuristic pointers rather than theorems; the rigorously
established content of this paper is Definition 1, Propositions 1–4, Lemmas 1–5,
Theorem 1, and Corollaries 1–2.

## 7. Discussion and future directions

The construction isolates a clean dichotomy. The **left edge** is flexible,
$A(n,0,s)=(1-s)^n$, bending from the classical column of $1$'s into powers of
$1-s$; whereas the **row sum** is rigid, $\sum_k A(n,k,s)=n!$, because the shift
enters the recurrence antisymmetrically (Corollary 1). The boundary value of
Proposition 4 also acts as the unique initial datum selecting a given $s$, which is
the natural starting point for a generating-function treatment.

We record the open directions produced alongside the formalization.

**(1) Row-sum / normalization.** $\sum_{k=0}^{n} A(n,k,s) = n!$ for every $s$. A
telescoping induction on $n$ using Theorem 1 and Corollary 1 should close this; the
recurrence and boundary lemmas are exactly the needed ingredients.

**(2) Symmetry under $s\mapsto 1-s$ and $k\mapsto n-1-k$.** Whether a shifted
reflection $A(n,k,s) = A(n,n-1-k,1-s)$ holds (recovering the classical symmetry
$\langle n,k\rangle = \langle n,n-1-k\rangle$ at $s=0$ in a reflected form) is open;
numerical exploration suggests the precise shifted statement needs adjustment, so
this remains a genuine question about whether $s$ is a true new degree of freedom.

**(3) Worpitzky-type expansion.** Conjecturally $(x-s)^n = \sum_{k=0}^{n-1}
A(n,k,s)\binom{x-k}{n}$, a shifted Worpitzky identity equivalent to Theorem 1 via
the Pascal recurrence for $\binom{x-k}{n}$.

**(4) Exponential generating function.** A one-parameter deformation of the
classical Eulerian EGF $(t-1)/(t-e^{(t-1)x})$, with $s$ entering only through the
initial condition $A(n,0,s)=(1-s)^n$ (Proposition 4), which fixes the deformation
uniquely.

**(5) Log-concavity / real-rootedness in $k$.** For fixed $n$ and $s\in[0,1]$, is
$k\mapsto A(n,k,s)$ log-concave (and the row polynomial real-rooted)? The recurrence
has the interlacing-preserving shape of the classical case while coefficients stay
nonnegative for $s\in[0,1]$.

## 8. Conclusion

We have defined the extended Eulerian numbers by an explicit alternating binomial
closed form and proved, with full formal rigor and no circularity, that they obey
the deformed recurrence $A(n+1,k+1,s) = (k+2-s)A(n,k+1,s) + (n-k+s)A(n,k,s)$ with
boundary values $A(0,0,s)=1$, $A(0,k+1,s)=0$, $A(n,0,s)=(1-s)^n$. The proof reduces
to Pascal's rule and the absorption identity through three lemmas on alternating
binomial sums. The shift $s$ is structurally inert in the recurrence — entering the
two coefficients antisymmetrically — which both explains the parameter-independent
factorial row sum and identifies the boundary value $(1-s)^n$ as the datum that
selects the deformation. The result places the classical Eulerian triangle inside a
smooth one-parameter family and opens a concrete program of symmetry, expansion,
generating-function, and log-concavity questions.
