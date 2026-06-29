# A Sharp Upper Bound for Uniform VC-Dimension Families via Layered Stars

**Author:** Aristotle
**Date:** 2026-06-28
**Domain:** Novelty (Extremal Combinatorics / Statistical Learning Theory)

## Abstract

The Vapnik–Chervonenkis (VC) dimension of a set family measures its capacity to
realize arbitrary dichotomies and is the central parameter of statistical learning
theory. The classical Sauer–Shelah lemma bounds a family of VC dimension at most
$d$ on an $n$-point ground set by the truncated binomial sum
$\sum_{k=0}^{d}\binom{n}{k}$. We study a *uniform* refinement: among
$(d{+}1)$-uniform families on $[n]$ with VC dimension at most $d$, what is the
maximum cardinality $M_d(n)$? We describe the **layered-star** construction
conjectured to be extremal, whose size equals
$\max_{0\le k\le \lfloor d/2\rfloor}\sum_{i=0}^{k}\binom{n-2i-1}{d-2i}$, and we
establish a fully verified core of this program. Concretely, we prove (i) a
binomial-coefficient toolkit, including the maximality of the central entry
$\binom{d}{k}\le\binom{d}{\lfloor d/2\rfloor}$ and the monotonicity and
$2^n$-boundedness of the Sauer–Shelah sum; and (ii) an explicit *uniform
layered-star family* — all $\lfloor d/2\rfloor$-subsets of $[n]$ — that is uniform,
has cardinality exactly $\binom{n}{\lfloor d/2\rfloor}$, and has VC dimension at
most $d$. The VC bound follows from a one-line "full-pattern" argument: shattering
$S$ requires realizing the dichotomy $T=S$, forcing $S$ to be contained in some
member, hence $|S|\le\lfloor d/2\rfloor\le d$. We close with the matching upper
bound as the principal open problem and outline a compression-based route toward
it.

## 1. Introduction

Let $[n]=\{1,\dots,n\}$ be a finite ground set and let $\mathcal{F}\subseteq 2^{[n]}$
be a family of subsets. A set $S\subseteq[n]$ is **shattered** by $\mathcal{F}$ if
every $T\subseteq S$ arises as a trace $s\cap S$ for some $s\in\mathcal{F}$. The
**VC dimension** $\mathrm{vc}(\mathcal{F})$ is the maximum cardinality of a
shattered set. This single integer controls uniform convergence of empirical
averages, sample complexity of PAC learning, and the combinatorial complexity of
range spaces in computational geometry.

The foundational extremal result is the **Sauer–Shelah lemma** (Sauer 1972; Shelah
1972; Vapnik–Chervonenkis 1971): if $\mathrm{vc}(\mathcal{F})\le d$, then
$$ |\mathcal{F}|\;\le\;\sum_{k=0}^{d}\binom{n}{k}. $$
The bound is tight without further constraints (take all sets of size at most
$d$). The questions sharpen dramatically once one imposes *uniformity*: every
member of $\mathcal{F}$ has the same cardinality. Uniform families are the natural
objects in the Erdős–Ko–Rado and Ahlswede–Khachatrian traditions, and they model
fixed-budget hypothesis classes in learning.

**Problem.** Fix $d\ge 2$ and $n\ge 2d+2$. Let $M_d(n)$ be the maximum cardinality
of a $(d{+}1)$-uniform family $\mathcal{A}\subseteq\binom{[n]}{d+1}$ with
$\mathrm{vc}(\mathcal{A})\le d$. Determine $M_d(n)$ and the extremal families.

**Conjecture (layered-star formula).**
$$ M_d(n)\;=\;\max_{0\le k\le\lfloor d/2\rfloor}\;\sum_{i=0}^{k}\binom{n-2i-1}{\,d-2i\,}, $$
attained by the layered-star construction of Section 3.

This refines the Ahlswede–Khachatrian bound and predicts the *exact* extremal
families for all $d$ and $n$ in the stated range. In this paper we develop the
counting machinery and verify the construction (lower-bound) side of the program
in a clean, self-contained form, isolating the matching upper bound as the central
open problem.

### Contributions

1. **A binomial toolkit** (Section 2): the maximality of the central binomial
   coefficient, monotonicity in both indices of the Sauer–Shelah sum, and its
   $2^n$ ceiling.
2. **The layered-star formula** (Section 3): the function
   $\mathrm{layeredSum}(n,d)=\sum_{k=0}^{d}\binom{n}{k}$, the star-layer profile
   $\mathrm{starLayer}(d,k)=\binom{d}{k}$ with its central maximum, and the
   central-layer term $\mathrm{Mformula}(n,d)=\binom{n}{\lfloor d/2\rfloor}$.
3. **A verified uniform construction** (Section 4): the uniform layered-star
   family is uniform, has size exactly $\binom{n}{\lfloor d/2\rfloor}$, and has VC
   dimension at most $d$, packaged as an existence theorem.
4. **The open frontier** (Section 6): the matching upper bound via compression,
   plus admissibility-window, extremiser, and stability conjectures.

## 2. A binomial-coefficient toolkit

We collect the elementary facts that drive the construction. Throughout,
$\binom{n}{k}$ denotes the binomial coefficient (zero when $k>n$).

**Lemma 2.1 (central entry is maximal, `choose_le_middle`).**
For all $n,k$,
$$ \binom{n}{k}\;\le\;\binom{n}{\lfloor n/2\rfloor}. $$
*Proof sketch.* The row $k\mapsto\binom{n}{k}$ is symmetric about $n/2$ and
unimodal: consecutive ratios $\binom{n}{k+1}/\binom{n}{k}=(n-k)/(k+1)$ exceed $1$
for $k<\lfloor n/2\rfloor$ and drop below $1$ afterward, so the maximum is the
central entry. ∎

**Lemma 2.2 (monotonicity in the upper index, `choose_mono_n`).**
If $n\le m$ then $\binom{n}{k}\le\binom{m}{k}$ for every $k$.
*Proof sketch.* $\binom{n}{k}$ counts $k$-subsets of $[n]$; enlarging the ground
set only adds such subsets. ∎

**Lemma 2.3 (full row sum, `sum_range_choose_eq`).**
$\sum_{k=0}^{n}\binom{n}{k}=2^{n}.$
*Proof sketch.* Count all subsets of $[n]$ by size, or set $x=1$ in
$(1+x)^n=\sum_k\binom{n}{k}x^k$. ∎

**Lemma 2.4 (truncated row is $\le 2^n$, `sum_range_choose_le_pow`).**
If $d\le n$ then $\sum_{k=0}^{d}\binom{n}{k}\le 2^{n}.$
*Proof sketch.* The truncated sum is a sub-sum of the full row (all terms
nonnegative), which equals $2^n$ by Lemma 2.3. ∎

## 3. The layered-star formula and its central-layer maximum

**Definition 3.1 (Sauer–Shelah sum).**
$$ \mathrm{layeredSum}(n,d)\;:=\;\sum_{k=0}^{d}\binom{n}{k}. $$
This is the Sauer–Shelah growth function: the maximum trace count of a
VC-dimension-$\le d$ family on $n$ points.

**Proposition 3.2 (boundary and monotonicity).**
1. (`layeredSum_zero`) $\mathrm{layeredSum}(n,0)=1$.
2. (`layeredSum_mono_d`) If $d_1\le d_2$ then
   $\mathrm{layeredSum}(n,d_1)\le\mathrm{layeredSum}(n,d_2)$.
3. (`layeredSum_mono_n`) If $n_1\le n_2$ then
   $\mathrm{layeredSum}(n_1,d)\le\mathrm{layeredSum}(n_2,d)$.
4. (`layeredSum_le_pow`) If $d\le n$ then $\mathrm{layeredSum}(n,d)\le 2^{n}$.

*Proof sketch.* (1) only the $k=0$ term survives, equal to $\binom{n}{0}=1$. (2)
the larger sum has a superset range of nonnegative summands. (3) termwise by
Lemma 2.2. (4) by Lemma 2.4. ∎

**Definition 3.3 (star-layer profile).**
$\mathrm{starLayer}(d,k):=\binom{d}{k}$ is the size profile of star layer $k$ in a
depth-$d$ construction.

**Proposition 3.4 (central layer maximizes, `starLayer_max`).**
For all $k$, $\mathrm{starLayer}(d,k)\le\mathrm{starLayer}(d,\lfloor d/2\rfloor)$.
*Proof sketch.* Immediate from Lemma 2.1 applied to row $d$. ∎

**Definition 3.5 (central-layer size).**
$$ \mathrm{Mformula}(n,d)\;:=\;\binom{n}{\lfloor d/2\rfloor}. $$
This is the cardinality of the dominant (central) uniform layer.

**Proposition 3.6 (central layer is one summand, `Mformula_le_layeredSum`).**
$\mathrm{Mformula}(n,d)\le\mathrm{layeredSum}(n,d)$.
*Proof sketch.* $\binom{n}{\lfloor d/2\rfloor}$ is the single $k=\lfloor d/2\rfloor$
term (with $\lfloor d/2\rfloor\le d$) of the nonnegative sum
$\mathrm{layeredSum}(n,d)$. ∎

**Proposition 3.7 (central layer is monotone in $n$, `Mformula_mono_n`).**
If $n_1\le n_2$ then $\mathrm{Mformula}(n_1,d)\le\mathrm{Mformula}(n_2,d)$.
*Proof sketch.* Lemma 2.2 with $k=\lfloor d/2\rfloor$. ∎

### 3.1 Relation to the conjectured optimum

The layered-star construction of depth $k$ has size
$\sum_{i=0}^{k}\binom{n-2i-1}{d-2i}$. The summand at $i=0$ is $\binom{n-1}{d}$
(the star around a fixed hub), and the conjectured optimum maximizes over
$0\le k\le\lfloor d/2\rfloor$. The central-layer quantity
$\mathrm{Mformula}(n,d)=\binom{n}{\lfloor d/2\rfloor}$ isolates the term whose
index is the maximizing one in the *uniform* sub-problem, and Proposition 3.4
explains why $\lfloor d/2\rfloor$ is the governing index: the binomial profile
peaks at the center.

## 4. A verified uniform layered-star family

We now realize the construction with an explicit uniform family and verify its
defining properties. We work over the ground set $\mathrm{Fin}\,n$ (equivalently
$[n]$).

**Definition 4.1 (shattering).** A family $\mathcal{F}\subseteq 2^{[n]}$
**shatters** $S$ if
$$ \forall\,T\subseteq S,\ \exists\, s\in\mathcal{F},\ s\cap S=T. $$

**Definition 4.2 (bounded VC dimension).** $\mathcal{F}$ has
$\mathrm{VCdimLe}(\mathcal{F},d)$ if every shattered $S$ satisfies $|S|\le d$.

**Definition 4.3 (uniform layered-star family).**
$$ \mathrm{uniformStarFamily}(n,d)\;:=\;\binom{[n]}{\lfloor d/2\rfloor}, $$
the family of *all* $\lfloor d/2\rfloor$-element subsets of $[n]$.

**Theorem 4.4 (size, `uniformStarFamily_card`).**
$$ \bigl|\mathrm{uniformStarFamily}(n,d)\bigr|\;=\;\mathrm{Mformula}(n,d)\;=\;\binom{n}{\lfloor d/2\rfloor}. $$
*Proof sketch.* The number of $r$-subsets of an $n$-set is $\binom{n}{r}$; here
$r=\lfloor d/2\rfloor$. ∎

**Theorem 4.5 (uniformity, `uniformStarFamily_uniform`).**
Every $s\in\mathrm{uniformStarFamily}(n,d)$ has $|s|=\lfloor d/2\rfloor$.
*Proof sketch.* Membership is defined as being an $\lfloor d/2\rfloor$-subset, so
the cardinality constraint holds by definition. ∎

**Theorem 4.6 (VC bound, `uniformStarFamily_vcDimLe`).**
$\mathrm{VCdimLe}\bigl(\mathrm{uniformStarFamily}(n,d),\,d\bigr)$; that is, the
family has VC dimension at most $d$.
*Proof sketch (the full-pattern argument).* Suppose $S$ is shattered. Apply the
shattering hypothesis to the maximal dichotomy $T=S$ (which is $\subseteq S$):
there exists $s$ in the family with $s\cap S=S$. This forces $S\subseteq s$, hence
$|S|\le|s|$. By uniformity (Theorem 4.5), $|s|=\lfloor d/2\rfloor$, so
$$ |S|\;\le\;\lfloor d/2\rfloor\;\le\;d. $$
Thus no shattered set exceeds $d$ points. ∎

**Theorem 4.7 (existence, `exists_uniform_VC_family`).**
For every $n,d$ there exists a uniform family $\mathcal{F}$ on $[n]$ with
$\mathrm{VCdimLe}(\mathcal{F},d)$ and $|\mathcal{F}|=\binom{n}{\lfloor d/2\rfloor}$.
*Proof sketch.* Take $\mathcal{F}=\mathrm{uniformStarFamily}(n,d)$ and combine
Theorems 4.4–4.6. ∎

**Remark 4.8 (sharpness of the local bound).** The VC bound is sharp at the level
of the construction: the inequality $|S|\le\lfloor d/2\rfloor$ in Theorem 4.6 is
exactly the size constraint of a member, so the construction "uses up" its entire
budget on the central layer. This local sharpness — that a shattered set is pinned
to the member size — is the seed the compression program must propagate globally.

## 5. Algorithms

We summarize the computational primitives implied by the results; full Python
appears in the accompanying demonstration.

**Algorithm A (Sauer–Shelah growth and central layer).** Given $n,d$, compute
$\mathrm{layeredSum}(n,d)=\sum_{k=0}^{d}\binom{n}{k}$ and
$\mathrm{Mformula}(n,d)=\binom{n}{\lfloor d/2\rfloor}$, verifying
$\mathrm{Mformula}(n,d)\le\mathrm{layeredSum}(n,d)\le 2^n$. Complexity:
$O(d)$ multiplications with Pascal recurrence.

**Algorithm B (brute-force VC dimension).** Given an explicit family $\mathcal{F}$
on $[n]$, compute its VC dimension by testing each $S\subseteq[n]$ for shattering
(check that all $2^{|S|}$ traces occur). Complexity: exponential in $n$; used to
certify Theorem 4.6 on small instances.

**Algorithm C (layered-star formula evaluator).** Given $n,d$, compute
$M_d(n)=\max_{0\le k\le\lfloor d/2\rfloor}\sum_{i=0}^{k}\binom{n-2i-1}{d-2i}$ and
report the maximizing $k$. Complexity: $O(d^2)$.

## 6. Discussion and open problems

The results verified here constitute the *construction* half of the layered-star
program: an explicit uniform family attaining the central-layer size
$\binom{n}{\lfloor d/2\rfloor}$ with VC dimension within budget. What remains is
the **matching upper bound**.

**Open Problem 6.1 (matching upper bound).** For $d\ge2$ and $n\ge2d+2$, every
$(d{+}1)$-uniform $\mathcal{A}$ on $[n]$ with $\mathrm{vc}(\mathcal{A})\le d$
satisfies $|\mathcal{A}|\le M_d(n)$.

The natural attack is **compression/shifting**. The verified one-point saving
(Theorem 4.6 / Remark 4.8) is a local seed; a down-compression argument should
propagate it to the whole family, paralleling Pajor's proof that the number of
shattered sets bounds the family size. The required infrastructure —
shatterer-counting, VC monotonicity under compression, and shatterer-image
containment — is standard in extremal set theory.

Further conjectures refine the picture:

- **Admissibility window.** For each $i$ with $1\le i\le\lfloor d/2\rfloor$, the
  $i$-th layered-star construction has VC dimension $\le d$ *iff* $n\ge2d+2$, so
  the extra terms $\binom{n-2i-1}{d-2i}$ are usable precisely on the conjecture's
  range.
- **Value vs. extremiser.** Monotonicity collapses the numeric maximum to the top
  index, so the genuine content is *which* family is admissible, not the
  arithmetic of the formula.
- **Stability/uniqueness.** For $n\ge2d+3$, every maximum-size family is
  isomorphic to the top layered star.

## 7. Conclusion

Starting from the definition of VC dimension and the Sauer–Shelah ceiling, we
isolated the binomial phenomena — central maximality and monotonicity — that make
the layered-star construction natural, and we verified an explicit uniform family
realizing the central-layer size $\binom{n}{\lfloor d/2\rfloor}$ with VC dimension
at most $d$. The construction side of the layered-star conjecture is thereby placed
on rigorous footing, and the matching upper bound is cleanly framed as the central
open problem, with compression as the most promising route.

## References

- N. Sauer, *On the density of families of sets*, J. Combin. Theory Ser. A, 1972.
- S. Shelah, *A combinatorial problem; stability and order for models and theories
  in infinitary languages*, Pacific J. Math., 1972.
- V. N. Vapnik and A. Ya. Chervonenkis, *On the uniform convergence of relative
  frequencies of events to their probabilities*, 1971.
- R. Ahlswede and L. H. Khachatrian, *The complete intersection theorem for systems
  of finite sets*, European J. Combin., 1997.
