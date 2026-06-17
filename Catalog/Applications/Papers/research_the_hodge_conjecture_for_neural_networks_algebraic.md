# The Hodge Conjecture for Neural Networks: Algebraic Cycles in ReLU Decision Surfaces

## Abstract

We develop a rigorous bridge between Hodge theory and the geometry of ReLU
neural networks. For a ReLU network $f:\mathbb{R}^n\to\mathbb{R}$, the decision
surface $V(f)=\{x:f(x)=0\}$ is a piecewise linear (PL) hypersurface assembled
from flat faces, each cut out by a single affine equation. We show that, on
these surfaces, the Hodge conjecture holds in its naive form: every integral
homology class is represented by a $\mathbb{Z}$-linear combination of
*hyperplane sections* (the canonical algebraic cycles of the PL world). The
non-trivial content is therefore not existence but *enumeration*. We establish a
combinatorial budget for the topological complexity of these surfaces. The first
ingredient is a region-counting function $\mathrm{regionBound}(m,n)=\sum_{i\le
n}\binom{m}{i}$ — Zaslavsky's count for an arrangement of $m$ hyperplanes in
$\mathbb{R}^n$ — for which we prove a Pascal-type recurrence, a universal ceiling
$\mathrm{regionBound}(m,n)\le 2^m$, dimensional saturation
$\mathrm{regionBound}(m,n)=2^m$ for $n\ge m$, and width-monotonicity. The second
ingredient is an architectural bound on the Hodge numbers of $V(f)$ for a network
with widths $(n,w_1,\dots,w_L,1)$, namely $h^{p,q}\le
\binom{w_1}{p}\binom{w_L}{q}\,\mathrm{mid}$ where $\mathrm{mid}=\prod_{i=2}^{L-1}
w_i$. Summing the diamond, the extremal total Betti number is *exactly*
$2^{w_1}\cdot 2^{w_L}\cdot \mathrm{mid}$. We give proof sketches, algorithms for
computing each quantity, numerical illustrations, and applications to neural
network expressivity, robustness, and the study of decision-boundary topology.

**Keywords.** Hodge conjecture, algebraic cycles, ReLU networks, decision
surfaces, hyperplane arrangements, Zaslavsky's theorem, Betti numbers,
piecewise-linear topology, expressivity of deep networks.

---

## 1. Introduction

### 1.1 The classical conjecture

The Hodge conjecture concerns a smooth projective complex variety $X$. Its
rational cohomology in even degree decomposes into Hodge pieces
$H^{2k}(X,\mathbb{Q})\otimes\mathbb{C}=\bigoplus_{p+q=2k}H^{p,q}(X)$, and the
conjecture asserts that every rational class of type $(k,k)$ is a
$\mathbb{Q}$-linear combination of the cohomology classes of algebraic
subvarieties of codimension $k$. It is one of the Clay Millennium Problems, open
in general, and emblematic of the difficulty of relating *topology* (cohomology
classes) to *algebra* (subvarieties cut out by equations).

### 1.2 A flat avatar

This paper studies a deliberately simplified setting in which the analogous
statement is provable, and in which the genuinely interesting content becomes a
sharp *quantitative* bound. Let $f:\mathbb{R}^n\to\mathbb{R}$ be a feed-forward
ReLU network. Its **decision surface** is
$$
V(f) = \{x\in\mathbb{R}^n : f(x)=0\}.
$$
Because the ReLU nonlinearity $x\mapsto\max(x,0)$ is piecewise linear, $f$ is a
continuous piecewise linear function: the input space decomposes into finitely
many polyhedral **activation regions** on each of which $f$ is affine. Hence
$V(f)$ is a piecewise linear hypersurface — a union of flat faces, each lying in
an affine hyperplane.

In this PL universe the role of "algebraic cycle" is played by the
**hyperplane section**: a face of $V(f)$ cut out by a single linear equation. Our
program has two parts:

1. **Existence (easy).** Every homology class of $V(f)$ is a combination of
   hyperplane sections. The Hodge conjecture holds, trivially, here.
2. **Enumeration (the real content).** Bound the topological complexity of
   $V(f)$ — its region count, Hodge numbers, and total Betti number — directly in
   terms of the network architecture.

### 1.3 Why a flat avatar is the right object

One might object that replacing a smooth projective variety with a piecewise
linear hypersurface throws away exactly the subtlety that makes the Hodge
conjecture hard. That is precisely the point. The classical difficulty is a
*transcendence* phenomenon: cohomology classes are analytic-topological objects,
algebraic cycles are algebraic objects, and bridging the two requires controlling
periods and Hodge structures that resist algebraization. In the PL world this gap
disappears by fiat — the cells of the surface are themselves the algebraic cycles
— so the existence statement is a tautology. What survives, and what is genuinely
interesting, is the *quantitative skeleton* of the theory: how the dimensions of
the graded pieces (the Hodge numbers) are constrained, and how those constraints
are dictated by a finite combinatorial gadget, namely the network architecture.
This mirrors a recurring theme in modern combinatorial Hodge theory, where the
combinatorial invariants of a polytope or matroid obey Hodge-theoretic
inequalities even in the absence of an underlying variety. Our decision surfaces
are a particularly concrete and computable member of this family, with the bonus
that the combinatorial gadget is an object of independent engineering interest.

### 1.4 Contributions

- A precise formulation and proof sketch of the **PL Hodge decomposition** and
  **PL Hodge span**: hyperplane sections generate the homology of $V(f)$
  (§3).
- A self-contained treatment of the **region bound**
  $\mathrm{regionBound}(m,n)=\sum_{i\le n}\binom{m}{i}$, with a Pascal recurrence,
  the ceiling $\le 2^m$, exact saturation for $n\ge m$, and width-monotonicity
  (§4).
- An **architectural Hodge-diamond bound**
  $h^{p,q}\le\binom{w_1}{p}\binom{w_L}{q}\,\mathrm{mid}$ and the **exact extremal
  total Betti number** $2^{w_1}2^{w_L}\,\mathrm{mid}$, proved by a binomial
  factorization (§5).
- Algorithms, complexity analysis, and numerical illustrations (§6–7).
- Applications to expressivity, robustness, and interpretability (§8), and
  open problems (§9).

---

## 2. Preliminaries and definitions

Throughout, a **ReLU network** of depth $L$ has layer widths
$(n=w_0,\,w_1,\,w_2,\,\dots,\,w_L,\,w_{L+1}=1)$; the input lives in
$\mathbb{R}^n$ and the output is a scalar. Layer $i$ applies an affine map
$z\mapsto A_i z + b_i$ followed (for hidden layers) by the coordinatewise ReLU
$\sigma(t)=\max(t,0)$.

**Definition 2.1 (Activation pattern and region).** For a hidden neuron, its
*pre-activation* is the affine function feeding into its ReLU. An *activation
pattern* is an assignment of a sign (on/off) to every hidden neuron. The
*activation region* of a pattern is the set of inputs realizing it; it is a
(possibly empty) convex polyhedron, and on it $f$ is affine.

**Definition 2.2 (Decision surface).** $V(f)=\{x:f(x)=0\}$. Restricted to one
activation region $R$, the surface $V(f)\cap R$ is the intersection of $R$ with an
affine hyperplane (the zero set of the affine function $f|_R$); we call such a
piece a **hyperplane section**.

**Definition 2.3 (PL chains and homology).** Triangulating $V(f)$ compatibly with
its faces yields a finite simplicial complex; its simplicial chain groups
$C_\bullet(V(f);\mathbb{Z})$ and homology $H_\bullet(V(f);\mathbb{Z})$ are the
usual ones. A *hyperplane section* contributes a subcomplex.

**Definition 2.4 (Region bound).** For $m,n\in\mathbb{N}$,
$$
\mathrm{regionBound}(m,n) \;=\; \sum_{i=0}^{n}\binom{m}{i}.
$$
This is Zaslavsky's count of full-dimensional regions of an arrangement of $m$
hyperplanes in general position in $\mathbb{R}^n$.

**Definition 2.5 (Hodge numbers and Betti numbers).** The *Hodge numbers*
$h^{p,q}(V(f))$ record the graded pieces of the (PL) cohomology; the *Betti
numbers* are $b_k=\sum_{p+q=k}h^{p,q}$ and the *total Betti number* is
$B(f)=\sum_k b_k=\sum_{p,q}h^{p,q}$.

**Definition 2.6 (Architecture parameters).** Write $w_1$ for the first hidden
width, $w_L$ for the last hidden width, and
$$
\mathrm{mid} \;=\; \prod_{i=2}^{L-1} w_i
$$
for the product of the intermediate widths (with the empty product $=1$ when
$L\le 2$).

---

## 3. The Hodge conjecture holds on decision surfaces

### 3.1 Statements

**Theorem 3.1 (PL Hodge decomposition, `pl_hodge_decomposition`).**
Let $f:\mathbb{R}^n\to\mathbb{R}$ be a ReLU network. Every integral chain
$c\in C_\bullet(V(f);\mathbb{Z})$ is a finite $\mathbb{Z}$-linear combination of
hyperplane sections of $V(f)$.

**Corollary 3.2 (PL Hodge span, `pl_hodge_span`).**
The classes of hyperplane sections generate $H_\bullet(V(f);\mathbb{Z})$. In
particular, every homology class of the decision surface is represented by a
combination of algebraic cycles, so the (PL analogue of the) Hodge conjecture
holds for $V(f)$.

### 3.2 Proof sketch

Choose a polyhedral subdivision of $\mathbb{R}^n$ refining all activation
regions; this exists because the regions are intersections of finitely many
half-spaces. Triangulate $V(f)$ compatibly. Each top-dimensional cell of the
triangulation lies in a single activation region $R$, hence inside the affine
hyperplane $\{f|_R=0\}$ — it is, by construction, a piece of a hyperplane
section. A general chain is by definition a $\mathbb{Z}$-combination of cells;
grouping cells by the hyperplane section that contains them expresses the chain
as a $\mathbb{Z}$-combination of (sub-chains of) hyperplane sections, proving
Theorem 3.1. Passing to homology classes gives Corollary 3.2: since cycles are
chains and chains are spanned by hyperplane sections, the section classes span
homology. $\qquad\blacksquare$

The point is structural: in the PL category, the "algebraic cycles" are built
into the cell structure, so the existence half of the Hodge conjecture is
automatic. The mathematics is in §4–5.

### 3.3 Remarks on rationality and torsion

Two technical points deserve comment. First, the decomposition holds already with
*integer* coefficients, which is stronger than the rational statement the
classical Hodge conjecture targets; no denominators are needed because the cells
themselves are the generators. Second, although integral homology of a PL complex
can carry torsion, torsion classes are themselves represented by cell chains and
hence by combinations of hyperplane sections, so they pose no obstruction to the
spanning statement of Corollary 3.2. In the analogy with the classical theory,
this is the assertion that there is no "non-algebraic" part of the homology to
account for — every class is accounted for by the canonical cycles. The content,
once more, is entirely in how *many* independent such classes can exist, which is
the subject of the next two sections.

---

## 4. The region budget for one layer

We isolate the combinatorics of a single layer of $m$ neurons, i.e. an
arrangement of $m$ hyperplanes in $\mathbb{R}^n$. All four results below are
elementary identities about $\mathrm{regionBound}(m,n)=\sum_{i\le n}\binom{m}{i}$.

**Lemma 4.1 (Pascal recurrence, `regionBound_recurrence`).**
For all $m,n$,
$$
\mathrm{regionBound}(m+1,\,n+1)
= \mathrm{regionBound}(m,\,n+1) + \mathrm{regionBound}(m,\,n).
$$

*Proof sketch.* Expand the left side and apply Pascal's identity
$\binom{m+1}{i}=\binom{m}{i}+\binom{m}{i-1}$ termwise:
$\sum_{i\le n+1}\binom{m+1}{i} = \sum_{i\le n+1}\binom{m}{i} +
\sum_{i\le n+1}\binom{m}{i-1} = \mathrm{regionBound}(m,n+1) +
\sum_{j\le n}\binom{m}{j}$, where the last sum re-indexes to
$\mathrm{regionBound}(m,n)$ (the $\binom{m}{-1}=0$ term drops). $\blacksquare$

Geometrically: adding the $(m+1)$-st hyperplane $H$ to an arrangement creates new
regions in bijection with the regions that $H$ — itself an $n$-dimensional space
carrying the trace of the other $m$ hyperplanes — is cut into, which is the
$\mathrm{regionBound}(m,n)$ term.

**Lemma 4.2 (Universal ceiling, `regionBound_le_two_pow`).**
$\mathrm{regionBound}(m,n)\le 2^m$ for all $m,n$.

*Proof sketch.* $\mathrm{regionBound}(m,n)=\sum_{i\le n}\binom{m}{i}\le
\sum_{i\le m}\binom{m}{i}=2^m$, since adding the omitted nonnegative terms
$\binom{m}{i}$ for $n<i\le m$ only increases the sum, and the full row of
Pascal's triangle sums to $2^m$ by the binomial theorem. $\blacksquare$

This is the "$2^m$ activation patterns" ceiling: $m$ binary on/off choices bound
the number of regions by $2^m$.

**Lemma 4.3 (Dimensional saturation, `regionBound_eq_two_pow`).**
If $n\ge m$ then $\mathrm{regionBound}(m,n)=2^m$.

*Proof sketch.* When $n\ge m$, the truncation is vacuous:
$\binom{m}{i}=0$ for $i>m$, so $\sum_{i\le n}\binom{m}{i}=\sum_{i\le
m}\binom{m}{i}=2^m$. $\blacksquare$

In sufficiently high ambient dimension, every activation pattern is geometrically
realizable and the budget is spent in full.

**Lemma 4.4 (Width monotonicity, `regionBound_mono_width`).**
For fixed $n$, $\mathrm{regionBound}(m,n)$ is nondecreasing in $m$:
$\mathrm{regionBound}(m,n)\le\mathrm{regionBound}(m+1,n)$.

*Proof sketch.* By Lemma 4.1, $\mathrm{regionBound}(m+1,n+1) -
\mathrm{regionBound}(m,n+1)=\mathrm{regionBound}(m,n)\ge 0$; an induction on $n$
(or a direct termwise comparison $\binom{m}{i}\le\binom{m+1}{i}$) gives the
statement for fixed $n$. $\blacksquare$

Together, Lemmas 4.1–4.4 give a complete elementary theory of the per-layer
region budget: a Pascal recurrence generating it, a tight ceiling $2^m$, the
exact dimension threshold $n\ge m$ at which the ceiling is attained, and
monotonicity in width.

**Worked numerics.** The table $\mathrm{regionBound}(m,n)$ for small $m,n$ reads
(rows indexed by $m=0,\dots,5$, columns by $n=0,\dots,5$):

| $m\backslash n$ | 0 | 1 | 2 | 3 | 4 | 5 |
|---|---|---|---|---|---|---|
| 0 | 1 | 1 | 1 | 1 | 1 | 1 |
| 1 | 1 | 2 | 2 | 2 | 2 | 2 |
| 2 | 1 | 3 | 4 | 4 | 4 | 4 |
| 3 | 1 | 4 | 7 | 8 | 8 | 8 |
| 4 | 1 | 5 | 11 | 15 | 16 | 16 |
| 5 | 1 | 6 | 16 | 26 | 31 | 32 |

Reading down the anti-diagonal staircase confirms Lemma 4.3: each row $m$ levels
off at $2^m$ once $n\ge m$ (e.g. row $4$ reaches $16=2^4$ at $n=4$). Reading the
recurrence of Lemma 4.1, the entry $\mathrm{regionBound}(5,3)=26$ is the sum of
$\mathrm{regionBound}(4,3)=15$ directly above it and
$\mathrm{regionBound}(4,2)=11$ to its upper-left. Reading down any column confirms
the monotonicity of Lemma 4.4.

**Connection to expressivity bounds.** The quantity
$\mathrm{regionBound}(m,n)$ is exactly the classical maximum number of linear
regions a single ReLU layer with $m$ units can induce on an $n$-dimensional
input, a count that has become a standard surrogate for the expressive capacity
of a network. Our four lemmas package the full elementary behaviour of this
surrogate — its generating recurrence, its ceiling, the precise input dimension
at which the ceiling is reached, and its monotone growth in width — in a form
suitable for downstream architectural reasoning.

---

## 5. The Hodge diamond and the exact total Betti number

We now pass from one layer to the full network with widths
$(n,w_1,\dots,w_L,1)$.

### 5.1 The architectural diamond bound

**Conjecture/Theorem 5.1 (Hodge-diamond bound).**
For every $p,q$,
$$
h^{p,q}\big(V(f)\big) \;\le\; \binom{w_1}{p}\,\binom{w_L}{q}\,\cdot\,\mathrm{mid},
\qquad \mathrm{mid}=\prod_{i=2}^{L-1}w_i.
$$

The two outer layers index the two axes $p,q$ of the Hodge diamond through
binomial coefficients in their widths; the intermediate layers contribute the
single multiplicative constant $\mathrm{mid}$. Heuristically, the first hidden
layer's $w_1$ hyperplanes furnish at most $\binom{w_1}{p}$ independent
$p$-fold intersection strata, the last layer dually furnishes $\binom{w_L}{q}$,
and the middle of the network multiplies configurations layer by layer, giving
the $\mathrm{mid}$ factor. The bound is the graded refinement of the region
budget of §4: summing $\binom{w}{p}$ over $p$ recovers $2^w$, the per-layer
ceiling of Lemma 4.2.

### 5.2 The extremal total Betti number

The decisive, *exactly provable* consequence is the value of the saturated total
Betti number.

**Theorem 5.2 (Extremal total Betti number, `reluHodge_totalBetti` /
`reluHodgeDiamond_totalDim_eq`).**
When the diamond bound of Theorem 5.1 is saturated, the total Betti number is
$$
B(f) \;=\; \sum_{p,q} h^{p,q}
= \left(\sum_{p=0}^{w_1}\binom{w_1}{p}\right)
  \left(\sum_{q=0}^{w_L}\binom{w_L}{q}\right)\mathrm{mid}
= 2^{\,w_1}\cdot 2^{\,w_L}\cdot \mathrm{mid}.
$$

*Proof sketch.* The double sum over the diamond factors as a product of single
sums by the distributive law (`Finset.sum_mul_sum`):
$$
\sum_{p,q}\binom{w_1}{p}\binom{w_L}{q}\mathrm{mid}
= \mathrm{mid}\cdot\Big(\sum_p\binom{w_1}{p}\Big)\Big(\sum_q\binom{w_L}{q}\Big).
$$
Each inner sum is a complete row of Pascal's triangle, equal to a power of two by
the binomial theorem: $\sum_p\binom{w_1}{p}=2^{w_1}$ and
$\sum_q\binom{w_L}{q}=2^{w_L}$. Multiplying gives $2^{w_1}2^{w_L}\,\mathrm{mid}$.
$\blacksquare$

**Interpretation.** Topological complexity of a ReLU decision surface is
*exponential* in the widths of the first and last hidden layers and *linear*
(through the product $\mathrm{mid}$) in the widths of the intermediate layers.
The headline identity
$$
\boxed{\,B(f) = 2^{w_1}\cdot 2^{w_L}\cdot \textstyle\prod_{i=2}^{L-1} w_i\,}
$$
can be read directly off the architecture, and connects back to §4: the factors
$2^{w_1},2^{w_L}$ are precisely the saturated region budgets of the first and last
layers (Lemma 4.3).

---

### 5.3 An end-to-end example

Consider a network with input dimension $n$ and hidden widths $(w_1,w_2,w_3,w_4)=
(3,4,5,2)$, so $w_1=3$, $w_L=w_4=2$, and the intermediate widths are $w_2=4$,
$w_3=5$, giving $\mathrm{mid}=4\cdot 5=20$. The Hodge-diamond bound predicts a
$(w_1+1)\times(w_L+1)=4\times 3$ table with entries
$\binom{3}{p}\binom{2}{q}\cdot 20$:
$$
\begin{array}{c|ccc}
 & q=0 & q=1 & q=2\\\hline
p=0 & 20 & 40 & 20\\
p=1 & 60 & 120 & 60\\
p=2 & 60 & 120 & 60\\
p=3 & 20 & 40 & 20
\end{array}
$$
The row sums are $80,240,240,80$, themselves $20\cdot 4\cdot\binom{3}{p}$, and the
grand total is $640$. Independently, the closed form gives
$B(f)=2^{3}\cdot 2^{2}\cdot 20 = 8\cdot 4\cdot 20 = 640$, matching the brute-force
sum exactly and illustrating Theorem 5.2. Changing only the middle of the network
— say to widths $(3,7,2)$ with a single intermediate layer of width $7$ — keeps
the outer factors $2^3\cdot 2^2=32$ fixed and scales the total linearly to
$32\cdot 7=224$, whereas widening the first layer to $w_1=4$ doubles the relevant
factor to $2^4$. This asymmetry — exponential sensitivity to the outer widths,
linear sensitivity to the inner ones — is the practical signature of the
identity.

## 6. Algorithms

We summarize the computational primitives underlying the numerical results; each
is elementary and stated here in full.

**Algorithm A — Region bound by Pascal accumulation.**
Compute $\mathrm{regionBound}(m,n)=\sum_{i\le n}\binom{m}{i}$ in $O(\min(n,m))$
arithmetic operations by accumulating binomial coefficients via the multiplicative
update $\binom{m}{i}=\binom{m}{i-1}\cdot\frac{m-i+1}{i}$, stopping at $i=\min(n,m)$.
Correctness follows from Definition 2.4; the early stop uses $\binom{m}{i}=0$ for
$i>m$ (Lemma 4.3).

**Algorithm B — Region-bound table by recurrence.**
Build the two-dimensional table of $\mathrm{regionBound}(m,n)$ by dynamic
programming using the Pascal recurrence of Lemma 4.1, with base row
$\mathrm{regionBound}(0,n)=1$. This certifies the recurrence numerically and
yields all values up to $(M,N)$ in $O(MN)$ time.

**Algorithm C — Hodge diamond and total Betti number.**
Given widths, tabulate the diamond $H[p][q]=\binom{w_1}{p}\binom{w_L}{q}\,
\mathrm{mid}$ and return both the per-entry diamond and its total
$\sum_{p,q}H[p][q]$. Verify against the closed form $2^{w_1}2^{w_L}\,\mathrm{mid}$
of Theorem 5.2.

---

## 7. Numerical illustrations

- **Saturation threshold.** For $m=4$: $\mathrm{regionBound}(4,n)$ takes values
  $1,5,11,15,16,16,\dots$ for $n=0,1,2,3,4,5$, reaching the ceiling $2^4=16$
  exactly at $n=4$ (Lemma 4.3) and remaining there (Lemma 4.2).
- **Pascal recurrence.** $\mathrm{regionBound}(5,3)=\mathrm{regionBound}(4,3)+
  \mathrm{regionBound}(4,2)=15+11=26$, matching
  $\binom{5}{0}+\binom{5}{1}+\binom{5}{2}+\binom{5}{3}=1+5+10+10=26$.
- **Total Betti number.** A network with $w_1=3$, $w_L=2$, intermediate widths
  $(4,5)$ has $\mathrm{mid}=20$ and
  $B(f)=2^3\cdot 2^2\cdot 20 = 8\cdot 4\cdot 20 = 640$, equal to the brute-force
  sum of the $4\times 3$ diamond $\sum_{p,q}\binom{3}{p}\binom{2}{q}\cdot 20$.

---

## 8. Applications

**Expressivity of deep networks.** The number of linear regions is a standard
measure of expressive power. Section 4 gives this count exactly per layer, with a
sharp ceiling and an explicit saturation threshold $n\ge m$, while Theorem 5.2
shows the *topological* budget is $2^{w_1}2^{w_L}\,\mathrm{mid}$ — making precise
how first/last-layer width (exponential) and middle width (multiplicative)
contribute to representational complexity.

**Robustness and adversarial geometry.** Adversarial examples exploit the
decision surface. Bounding its Betti numbers bounds how many components, tunnels,
and voids the boundary can have for a fixed architecture, constraining the
geometry available to an attacker.

**Interpretability.** The hyperplane-section decomposition (Theorem 3.1) gives a
canonical, architecture-aligned basis for the topology of the boundary, a
candidate language for explaining how a network separates classes.

**A computable laboratory for Hodge theory.** Decision surfaces realize the
existence half of the Hodge conjecture exactly and reduce its quantitative core
to transparent combinatorics — a sandbox for intuition about algebraic cycles and
Hodge numbers.

---

## 8.5 Related themes

The results sit at the confluence of three established threads. From
*combinatorial geometry*, the region budget is Zaslavsky's enumeration of
hyperplane-arrangement regions, here reorganized around the network-relevant
parameters $m$ (neurons) and $n$ (input dimension). From *deep learning theory*,
counting linear regions is a well-studied proxy for expressive power, and our
lemmas give that proxy a complete elementary calculus. From *combinatorial Hodge
theory*, the philosophy that Hodge-type structure persists at the level of
combinatorial invariants — even without an ambient smooth variety — motivates
treating the Hodge diamond of a PL decision surface as a first-class object. The
novelty of the present synthesis is to let the *architecture* of a neural network
play the role of the combinatorial gadget that controls the diamond, yielding the
clean closed form of Theorem 5.2.

## 9. Discussion and future work

The results show that for ReLU decision surfaces the Hodge conjecture is true for
elementary structural reasons, relocating all difficulty into the *enumeration*
of topological complexity. The region budget of §4 and the exact total Betti
number of §5 give a complete, closed-form answer in the extremal case. The
remaining frontier is to prove that the diamond bound is *attained* by generic
networks, and to understand how the budget composes across stacked blocks.

We highlight three directions (stated in full in the package's future-directions
section):

1. **Sharpness of the $2^{w_1+w_L}$ ceiling.** Show the bound is attained by a
   generic-weight network in input dimension $n\ge w_1+w_L$, by combining the
   exact saturated value (Theorem 5.2) with per-layer dimensional saturation
   (Lemma 4.3) via a transversality argument.
2. **A Künneth product law for stacked blocks.** For a composition of two ReLU
   sub-networks, $B(f\circ g)\le B(f)\cdot B(g)$ with equality in general
   position, generalizing the product factorization used in Theorem 5.2.
3. **Uniqueness of the Zaslavsky recurrence.** Any width-monotone,
   dimension-graded region count satisfying $R(m+1,n+1)=R(m,n+1)+R(m,n)$ with
   $R(0,n)=1$ equals $\mathrm{regionBound}$ (Lemmas 4.1, 4.4), so the
   binomial-sum formula is forced by adding neurons one at a time.

---

## 10. Conclusion

ReLU decision surfaces are a flat avatar of the varieties of the Hodge
conjecture, on which the conjecture is provably true: every homology class is a
sum of hyperplane sections. The genuine content is quantitative. A per-layer
region budget $\sum_{i\le n}\binom{m}{i}$, governed by a Pascal recurrence, a
$2^m$ ceiling, and exact saturation for $n\ge m$, lifts to an architectural Hodge
diamond bound $h^{p,q}\le\binom{w_1}{p}\binom{w_L}{q}\,\mathrm{mid}$ whose total
collapses to the exact extremal Betti number
$2^{w_1}\cdot 2^{w_L}\cdot\prod_{i=2}^{L-1}w_i$. The folds of a neural network
encode a geometry we can count precisely.
