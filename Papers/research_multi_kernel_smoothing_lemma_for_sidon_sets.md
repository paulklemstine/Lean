# The $L^2$ Energy Characterisation of Sidon Sets: A Two-Kernel Decomposition

## Abstract

A finite set of integers is a *Sidon set* (equivalently a $B_2$ set) if all
of its pairwise sums are distinct up to the trivial symmetry. We give a
complete and self-contained treatment of Sidon sets from the point of view
of *additive energy* — the number of quadruples $(a,b,c,d)$ from the set
with $a+b=c+d$ — which equals the squared $L^2$ norm of the set's
self-convolution kernel. We prove two results. First, a **universal lower
bound**: every finite set $s$ of integers satisfies
$E[s] \ge 2|s|^2 - |s|$, so the additive energy can never fall below a floor
that depends only on the cardinality. Second, an **exact characterisation**:
$s$ is a Sidon set if and only if it attains this floor, $E[s] = 2|s|^2 -
|s|$. Both results are derived from a single structural fact: the set of
energy quadruples always contains, and for Sidon sets exactly equals, the
almost-disjoint union of two elementary convolution kernels — a *diagonal
kernel* and a *coordinate-swap kernel*, each a shifted copy of $s \times s$,
overlapping in exactly $|s|$ elements. This shows Sidon sets to be the exact
$L^2$-energy minimisers, and it exhibits the "multi-kernel" structure behind
that minimisation as a rigid two-element skeleton, universal across all sets.
We include worked numerical examples, algorithms for testing the Sidon
property and computing additive energy, and a discussion of quantitative
and higher-order extensions.

**Keywords:** Sidon set, $B_2$ set, additive energy, convolution kernel,
$L^2$ minimisation, Golomb ruler, additive combinatorics.

---

## 1. Introduction

Let $s$ be a finite set of integers. Its *sumset* is the set of all values
$a+b$ with $a,b \in s$. A classical question, going back to Simon Sidon's
work in the 1930s on lacunary Fourier series, asks how additively "spread
out" $s$ can be — how few coincidences its sums can exhibit. The extremal
objects are the **Sidon sets**: those in which the equation $a+b=c+d$ has
only the trivial solutions.

Sidon sets recur throughout mathematics and its applications under a variety
of names. As **Golomb rulers**, they describe tick placements in which every
pair of marks is a distinct distance apart, prized in radar and sonar array
design and in the layout of interferometers. In coding theory and in
frequency-hopping communication they minimise interference. In number theory
they are the sets for which the representation function $r_s(x) = \#\{(a,b)
\in s^2 : a+b=x\}$ is as flat as possible, and they saturate the classical
density bound $|s| \lesssim \sqrt{N}$ for subsets of $\{1,\dots,N\}$.

This paper isolates the **$L^2$ (convolution-energy) face** of the theory.
Rather than the size or the difference-set behaviour of $s$, we study the
*additive energy* $E[s]$, and we prove that the Sidon property is equivalent
to $E[s]$ attaining a universal floor. The argument is elementary,
constructive, and structural: it exhibits the energy as governed by exactly
two convolution kernels.

### Historical context

Sidon introduced these sets to control the $L^4$ norm of trigonometric sums
with frequencies restricted to $s$; the additive-combinatorial reformulation
via distinct pairwise sums came shortly after. Erdős and Turán established the
foundational density results in the 1940s, and Singer's construction from
finite projective planes produces Sidon sets of size roughly $\sqrt{N}$ inside
$\{1, \dots, N\}$, matching the upper bound up to lower-order terms. The
additive energy $E[s]$ that we take as our central object became a standard
tool decades later, in the development of modern additive combinatorics, where
it measures the failure of a set to behave additively like a random set. The
contribution of the present work is to make the relationship between the Sidon
property and this energy functional completely explicit and exact, and to
expose the elementary two-kernel mechanism that governs it.

### Contributions

1. **Universal energy floor** (Theorem 4.1): $E[s] \ge 2|s|^2 - |s|$ for
   every finite $s \subset \mathbb{Z}$.
2. **Sidon $\Leftrightarrow$ minimal energy** (Theorem 4.2): $s$ is Sidon
   iff $E[s] = 2|s|^2 - |s|$.
3. **Two-kernel decomposition** (Section 3): the structural engine behind
   both results, showing that the certifying kernel family has cardinality
   exactly two, independent of $|s|$.

---

## 2. Definitions

Throughout, $s$ denotes a finite subset of $\mathbb{Z}$ and $|s|$ its
cardinality. All products of sets are Cartesian products, and quadruples are
*ordered*.

**Definition 2.1 (Sidon set).** A finite set $s \subset \mathbb{Z}$ is a
*Sidon set* (a $B_2$ set) if for all $a,b,c,d \in s$,
$$a + b = c + d \implies (a = c \ \text{or}\ a = d).$$
Equivalently, the only representations of any integer as an ordered sum of
two elements of $s$ are the one representation and its swap.

**Definition 2.2 (Representation function / self-convolution).** For $x \in
\mathbb{Z}$ let
$$r_s(x) = \#\{(a,b) \in s \times s : a + b = x\}.$$
The function $r_s = \mathbf{1}_s * \mathbf{1}_s$ is the *self-convolution
kernel* of $s$. It records, for each total $x$, how many ordered pairs of
elements of $s$ produce it.

**Definition 2.3 (Additive energy).** The *additive energy* of $s$ is
$$E[s] = \#\{(a,b,c,d) \in s^4 : a+b = c+d\}.$$

**Proposition 2.4 (Parseval / $L^2$ identity).**
$$E[s] = \sum_{x \in \mathbb{Z}} r_s(x)^2.$$

*Proof.* Group the quadruples $(a,b,c,d)$ with $a+b=c+d$ by their common
value $x = a+b = c+d$. For a fixed $x$ there are $r_s(x)$ choices of the
pair $(a,b)$ and, independently, $r_s(x)$ choices of $(c,d)$, giving
$r_s(x)^2$ quadruples. Summing over $x$ yields the claim. $\qquad\blacksquare$

Thus additive energy is literally the squared $L^2$ norm of the convolution
kernel, and minimising energy is minimising that $L^2$ mass. This is the
sense in which the results below are an "$L^2$ minimisation" statement.

**Remark 2.4a (Fourier / analytic viewpoint).** The convolution language has an
equivalent frequency-side form that explains why additive energy is such a
robust measure of structure. If one associates to $s$ the exponential sum
$\widehat{\mathbf{1}_s}(\theta) = \sum_{a \in s} e^{2\pi i a\theta}$, then
$r_s = \mathbf{1}_s * \mathbf{1}_s$ has Fourier transform
$\widehat{\mathbf{1}_s}(\theta)^2$, and Parseval's theorem turns the identity of
Proposition 2.4 into
$$E[s] = \int_0^1 \bigl|\widehat{\mathbf{1}_s}(\theta)\bigr|^4 \, d\theta.$$
Additive energy is therefore the fourth moment of the exponential sum. A set
whose exponential sum is small away from $\theta = 0$ (an additively
"pseudorandom" set) has energy close to the floor; a set with large mass at
some nonzero frequency (additive structure, such as an arithmetic progression)
has energy far above it. The results of this paper pin down the exact extreme
of this fourth-moment functional: it is minimised precisely by Sidon sets, and
the minimum value is $2|s|^2 - |s|$. While we do not use the analytic form in
our proofs — the combinatorial two-kernel argument is cleaner and exact — it
locates the theorem within the standard toolkit of additive combinatorics.

**Definition 2.5 (Energy quadruple set).** Encode a quadruple $(a,b,c,d)$ as
the pair-of-pairs $((a,c),(b,d))$. The *energy set* of $s$ is
$$\mathcal{E}(s) = \{((a,c),(b,d)) \in (s\times s)\times(s\times s) : a+b = c+d\}.$$
By construction $|\mathcal{E}(s)| = E[s]$.

---

## 3. The two-kernel decomposition

The heart of the paper is a description of $\mathcal{E}(s)$ in terms of two
elementary pieces. Both are images of $s \times s$ under simple coordinate
maps, and both consist entirely of genuine energy quadruples.

**Definition 3.1 (Diagonal kernel).**
$$\mathcal{A}(s) = \{((a,a),(b,b)) : (a,b) \in s \times s\},$$
the image of $s\times s$ under $(a,b) \mapsto ((a,a),(b,b))$. In quadruple
terms these are the identities $a + b = a + b$.

**Definition 3.2 (Swap kernel).**
$$\mathcal{B}(s) = \{((a,b),(b,a)) : (a,b) \in s \times s\},$$
the image of $s\times s$ under $(a,b) \mapsto ((a,b),(b,a))$. In quadruple
terms these are the symmetric identities $a + b = b + a$.

**Lemma 3.3 (Kernel cardinalities).** Each coordinate map above is injective
on $s \times s$, hence
$$|\mathcal{A}(s)| = |\mathcal{B}(s)| = |s|^2.$$

*Proof.* For $\mathcal{A}$: from $((a,a),(b,b))$ one recovers $(a,b)$
uniquely, so the map is injective. For $\mathcal{B}$: from $((a,b),(b,a))$
one recovers $(a,b)$ from the first coordinate pair directly. Injective
images preserve cardinality, and $|s\times s| = |s|^2$. $\qquad\blacksquare$

**Lemma 3.4 (Overlap).** The two kernels intersect exactly in the
fully-diagonal quadruples:
$$\mathcal{A}(s) \cap \mathcal{B}(s) = \{((a,a),(a,a)) : a \in s\},
\qquad |\mathcal{A}(s) \cap \mathcal{B}(s)| = |s|.$$

*Proof.* An element $((a,a),(b,b))$ of $\mathcal{A}(s)$ lies in
$\mathcal{B}(s)$ iff it has the swap form $((p,q),(q,p))$. Matching
coordinates forces $p = q = a = b$; conversely each such element is the image
of $a$ under $a \mapsto ((a,a),(a,a))$, an injection of $s$. $\qquad\blacksquare$

**Lemma 3.5 (Union count).** By inclusion–exclusion,
$$|\mathcal{A}(s) \cup \mathcal{B}(s)| + |s| = 2|s|^2,
\qquad\text{i.e.}\qquad |\mathcal{A}(s) \cup \mathcal{B}(s)| = 2|s|^2 - |s|.$$

*Proof.* $|\mathcal{A} \cup \mathcal{B}| = |\mathcal{A}| + |\mathcal{B}| -
|\mathcal{A}\cap\mathcal{B}| = |s|^2 + |s|^2 - |s|$ by Lemmas 3.3 and 3.4.
$\qquad\blacksquare$

**Lemma 3.6 (Kernels are genuine energy quadruples).**
$$\mathcal{A}(s) \cup \mathcal{B}(s) \subseteq \mathcal{E}(s).$$

*Proof.* A diagonal element $((a,a),(b,b))$ decodes to the quadruple
$(a,b,a,b)$, which satisfies $a+b = a+b$; a swap element $((a,b),(b,a))$
decodes to $(a,b,b,a)$, which satisfies $a+b=b+a$. Both are in
$\mathcal{E}(s)$, and all coordinates lie in $s$. $\qquad\blacksquare$

The final structural lemma is the one place the Sidon hypothesis enters: it
says that for Sidon sets there are *no* energy quadruples beyond the two
kernels.

**Lemma 3.7 (Rigidity for Sidon sets).** If $s$ is a Sidon set, then
$$\mathcal{E}(s) \subseteq \mathcal{A}(s) \cup \mathcal{B}(s),$$
and hence $\mathcal{E}(s) = \mathcal{A}(s)\cup\mathcal{B}(s)$.

*Proof.* Let $((a,c),(b,d)) \in \mathcal{E}(s)$, so $a,b,c,d \in s$ and
$a+b=c+d$. By the Sidon property (Definition 2.1), either $a=c$ or $a=d$.

- If $a = c$, then $a+b = c+d = a+d$ forces $b = d$, so the quadruple is
  $((a,a),(b,b)) \in \mathcal{A}(s)$.
- If $a = d$, then $a+b = c+d = c+a$ forces $b = c$, so the quadruple is
  $((a,b),(b,a)) \in \mathcal{B}(s)$.

Thus $\mathcal{E}(s) \subseteq \mathcal{A}(s)\cup\mathcal{B}(s)$; combined
with Lemma 3.6 this is an equality. $\qquad\blacksquare$

**Lemma 3.8 (Converse rigidity).** If $\mathcal{E}(s) \subseteq
\mathcal{A}(s) \cup \mathcal{B}(s)$, then $s$ is a Sidon set.

*Proof.* Suppose $a,b,c,d \in s$ with $a+b=c+d$. Then $((a,c),(b,d)) \in
\mathcal{E}(s)$, hence lies in $\mathcal{A}(s)$ or $\mathcal{B}(s)$. If it
lies in $\mathcal{A}(s)$ its first coordinate pair is diagonal, so $a=c$; if
it lies in $\mathcal{B}(s)$ its form is $((a,c),(c,a))$, so $a=d$. Either
way the Sidon condition holds. $\qquad\blacksquare$

---

## 4. Main results

**Theorem 4.1 (Universal energy floor).** For every finite set $s \subset
\mathbb{Z}$,
$$2|s|^2 \le E[s] + |s|, \qquad\text{equivalently}\qquad E[s] \ge 2|s|^2 - |s|.$$

*Proof.* Since $|\mathcal{E}(s)| = E[s]$ and $\mathcal{A}(s)\cup\mathcal{B}(s)
\subseteq \mathcal{E}(s)$ (Lemma 3.6), monotonicity of cardinality gives
$|\mathcal{A}(s)\cup\mathcal{B}(s)| \le E[s]$. By Lemma 3.5 the left side is
$2|s|^2 - |s|$, so $E[s] \ge 2|s|^2 - |s|$. $\qquad\blacksquare$

In the convolution language of Proposition 2.4 this reads $\sum_x r_s(x)^2
\ge 2|s|^2 - |s|$: the self-convolution kernel always carries $L^2$ energy at
least $2|s|^2 - |s|$, and equality is the extremal case.

**Theorem 4.2 (Sidon $\Leftrightarrow$ minimal energy).** A finite set $s
\subset \mathbb{Z}$ is a Sidon set if and only if
$$E[s] + |s| = 2|s|^2, \qquad\text{equivalently}\qquad E[s] = 2|s|^2 - |s|.$$

*Proof.* ($\Rightarrow$) If $s$ is Sidon, Lemma 3.7 gives $\mathcal{E}(s) =
\mathcal{A}(s)\cup\mathcal{B}(s)$, so $E[s] = |\mathcal{E}(s)| =
|\mathcal{A}(s)\cup\mathcal{B}(s)| = 2|s|^2 - |s|$ by Lemma 3.5.

($\Leftarrow$) Suppose $E[s] = 2|s|^2 - |s|$. Then $|\mathcal{E}(s)| =
2|s|^2 - |s| = |\mathcal{A}(s)\cup\mathcal{B}(s)|$ by Lemma 3.5. Since
$\mathcal{A}(s)\cup\mathcal{B}(s) \subseteq \mathcal{E}(s)$ (Lemma 3.6) and
the two finite sets have equal cardinality, they are equal; in particular
$\mathcal{E}(s) \subseteq \mathcal{A}(s)\cup\mathcal{B}(s)$, and Lemma 3.8
concludes that $s$ is Sidon. $\qquad\blacksquare$

**Corollary 4.3 (Exact minimisers).** Among all subsets of $\mathbb{Z}$ of a
fixed cardinality $n$, the minimum possible additive energy is $2n^2 - n$,
and it is attained by exactly the Sidon sets of that size.

**Corollary 4.4 (Energy is a Sidon witness).** For any finite $s$, the
non-negative quantity $D(s) := E[s] - (2|s|^2 - |s|)$ vanishes iff $s$ is
Sidon; $D(s)$ is an exact count of the energy quadruples of $s$ lying outside
$\mathcal{A}(s)\cup\mathcal{B}(s)$, i.e. of its non-trivial additive
coincidences.

*Proof of the count in 4.4.* Because $\mathcal{A}(s)\cup\mathcal{B}(s)
\subseteq \mathcal{E}(s)$ with the union of size $2|s|^2 - |s|$, the set
difference $\mathcal{E}(s)\setminus(\mathcal{A}(s)\cup\mathcal{B}(s))$ has
size $E[s] - (2|s|^2 - |s|) = D(s)$. $\qquad\blacksquare$

---

## 5. Worked examples

We verify the theory on small sets by direct enumeration. Write
$\text{floor}(n) = 2n^2 - n$.

**Example 5.1 ($\{0,1,3,7\}$, Sidon).** Here $n=4$ and $\text{floor}(4)=28$.
Direct enumeration of quadruples $(a,b,c,d)$ with $a+b=c+d$ gives $E = 28$.
Consistent with Theorem 4.2, $D = 0$: the set is Sidon.

**Example 5.2 ($\{0,1,2,3\}$, non-Sidon).** Again $n=4$, $\text{floor}=28$,
but $E = 44$, so $D = 16$. The surplus counts the non-trivial coincidences,
e.g. $0+2=1+1$, $0+3=1+2$, $1+3=2+2$ and their orderings.

**Example 5.3 ($\{0,1,2\}$, arithmetic progression).** Here $n=3$,
$\text{floor}=15$, and $E=19$, so $D=4$. The extra coincidence $0+2 = 1+1$
(with its orderings) accounts for the surplus.

**Example 5.4 (perfect difference set $\{0,1,3\}$, Sidon).** $n=3$,
$\text{floor}=15$, and $E=15$: a minimal-energy, hence Sidon, triple.

These confirm both the sharpness of the floor and the strictness of the gap
for non-Sidon sets.

---

## 6. Algorithms

We describe three routines. Complexities are stated in terms of $n = |s|$.

**Algorithm 6.1 (Additive energy by convolution).** Compute $r_s(x)$ for all
$x$ by tallying the $n^2$ pairwise sums into a dictionary, then return
$\sum_x r_s(x)^2$. This uses $O(n^2)$ time and $O(n^2)$ space and is exact.
It directly realises Proposition 2.4.

**Algorithm 6.2 (Sidon test).** Two equivalent strategies:
(a) *Direct*: insert every pairwise sum $a+b$ with $a \le b$ into a set; the
input is Sidon iff no collision occurs, in $O(n^2)$ time.
(b) *Energy*: compute $E[s]$ via Algorithm 6.1 and test $E[s] = 2n^2 - n$;
by Theorem 4.2 this is equivalent, also $O(n^2)$.

**Algorithm 6.3 (Energy defect).** Return $D(s) = E[s] - (2n^2 - n)$. By
Corollary 4.4 this is a non-negative integer measuring how far $s$ is from
Sidon, and it equals the number of non-trivial energy quadruples.

---

## 6b. Relation to the classical size bound

The $L^2$ story dovetails with the classical *size* theory of Sidon sets. If $s
\subseteq \{1, \dots, N\}$ is Sidon, then all $\binom{|s|}{2}$ positive pairwise
differences are distinct and lie in $\{1, \dots, N-1\}$, forcing
$\binom{|s|}{2} \le N-1$ and hence $|s| \le \sqrt{N} + O(1)$. The energy
viewpoint recovers the same extremal flavour from the other side: among all
subsets of a fixed size, Sidon sets are those that spread their sums as thinly
as possible, so they are simultaneously the *largest* sets one can fit under a
distinctness constraint and the *lowest-energy* sets of a given cardinality.
The two extremal principles — maximal size for fixed ambient range, minimal
energy for fixed cardinality — are dual faces of the same distinctness
condition, and the exact floor $2|s|^2 - |s|$ is the energy-side analogue of the
square-root density bound. The representation function $r_s$ mediates both: the
size bound controls its *support*, while the energy bound controls its
*$L^2$ mass*.

## 7. Applications

**Radar and sonar arrays (Golomb rulers).** A Sidon set placed as sensor
positions guarantees that every pairwise spacing is distinct, so a measured
delay identifies its generating pair unambiguously. The energy floor gives a
clean numerical certificate — a single integer comparison — for array
optimality, replacing pairwise-collision bookkeeping.

**Communications.** In frequency-hopping and in the design of low-correlation
sequences, the additive energy directly bounds worst-case interference; the
floor $2n^2 - n$ is the best achievable and is met exactly by Sidon
configurations.

**Additive combinatorics.** Additive energy is a standard proxy for
arithmetic structure; the exact identity $D(s) = E[s] - (2n^2-n)$ turns the
qualitative slogan "low energy implies structure" into an exact census of
coincidences, a form well-suited to robust ("$99\%$-structured") arguments.

---

## 8. Discussion: the rigidity of the two-kernel skeleton

It is worth emphasising what is and is not claimed to be new here. The
numerical value $2n^2 - n$ for the minimal energy, and the equivalence between
the Sidon property and minimal energy, are classical folklore in additive
combinatorics; they follow immediately once one writes $E[s] = \sum_x r_s(x)^2$
and observes that $\sum_x r_s(x) = |s|^2$ with each $r_s(x) \ge 1$ on the
support. The technical emphasis of this paper is instead the *mechanism*. The entire minimum is witnessed by exactly
two elementary convolution kernels, $\mathcal{A}(s)$ and $\mathcal{B}(s)$,
each an injective copy of $s \times s$, overlapping in $|s|$ points. This has
three consequences worth emphasising.

1. **Universality.** The two kernels and their overlap are defined by the
   same coordinate maps for every $s$; nothing about them adapts to the set.
   The skeleton is rigid.

2. **Minimality of the family.** A single kernel supplies only $|s|^2$
   quadruples, strictly below the floor whenever $|s| > 1$; two suffice to
   reach it exactly; a third can add nothing without leaving
   $\mathcal{E}(s)$ for a non-Sidon set. So the *exact* certifying family has
   cardinality exactly two.

3. **Reframing multi-kernel smoothing.** Weighted multi-kernel methods treat
   the number of kernels as a free parameter to optimise. The present result
   says the exact energy minimiser has a fixed two-kernel core, so such
   optimisations are perturbations of a known rigid center rather than open
   searches.

---

## 9. Future directions

**9.1 Two kernels are optimal, three are never needed.** We conjecture that
for a Sidon set the family of trivial additive coincidences decomposes into
*precisely* two elementary convolution kernels — a diagonal kernel and a
coordinate-swap kernel — and that no family of fewer than two can reproduce
the exact energy minimum while no family of more than two ever lowers it. In
particular, the minimal cardinality of an exact kernel family that certifies
the energy minimum is exactly two, independent of the size of the set. The
key insight is that the additive energy of a Sidon set is not merely bounded
but realised as an almost-disjoint union of two shifted copies of the set's
own product, so the "many kernels" heuristic collapses to a rigid two-element
basis.

**9.2 A quantitative energy defect controls near-Sidon sets.** We conjecture
that if a finite set misses the Sidon condition by exactly $k$ non-trivial
additive quadruples, then its additive energy exceeds the Sidon minimum by
precisely a linear function of $k$; and conversely any set whose energy is
within $k$ of the minimum can be made Sidon by deleting at most a bounded
multiple of $\sqrt{k}$ elements. Corollary 4.4 already establishes the exact
defect identity $D(s) = E[s] - (2n^2 - n)$; the removal statement, with
explicit constants, would upgrade "low energy $\Rightarrow$ structured" into
a quantitative repair theorem.

**9.3 Higher-order Sidon sets and the two-to-$h!$ kernel jump.** For $B_h$
sets — those in which all $h$-fold sums are distinct — we conjecture that the
$h$-fold self-convolution kernel is bounded pointwise by exactly $h!$, that
the associated energy is minimised precisely by such sets, and that the
minimal exact kernel family jumps from two (the ordinary case $h=2$) to $h!$
in general, indexed by the permutations of the $h$ summands.

---

## 10. Conclusion

Sidon sets — the additively most spread-out finite sets of integers — admit
an exact $L^2$-energy characterisation: they are precisely the sets whose
additive energy attains the universal floor $2|s|^2 - |s|$. The floor and the
characterisation both flow from a single elementary structure, a rigid
two-kernel decomposition of the energy quadruple set into a diagonal copy and
a swap copy of $s\times s$. This makes precise, and delimits, the sense in
which "multi-kernel" smoothing has a fixed skeleton, and it opens
quantitative and higher-order refinements.
