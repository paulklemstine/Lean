# The Moment Spectrum and the Dimension of the Leading-Term Cancellation Space

## Abstract

We study the leading correction to a heat-kernel–type spectral trace,
$$
L(t) = \sum_{i=1}^{n} d_i \, e^{-t E_i},
$$
where $E = (E_1, \dots, E_n)$ is a real spectrum and $d = (d_1, \dots, d_n)$ is a
vector of diagonal shifts (perturbations). We prove three sharp structural
characterizations of the condition "$L(t) = 0$ for all $t \in \mathbb{R}$." First,
a **moment-spectrum equivalence**: the leading term cancels for all $t$ if and
only if every spectral power sum $m_k = \sum_i d_i E_i^k$ vanishes, converting a
transcendental identity into a countable family of algebraic ones. Second, a
realization of the cancellation condition as the **kernel of a single linear
level-aggregation map** $S$, which sends a shift vector to the tuple of its
aggregate shifts over the distinct energy levels. Third, an exact **dimension
formula**: the cancellation space has dimension $n - m$, where $m$ is the number
of distinct energy levels. As a corollary, nontrivial cancellation exists if and
only if the spectrum is degenerate. All three facts trace back to the
nonsingularity of a Vandermonde system on the distinct energy values, yielding a
clean bridge between spectral analysis, the combinatorics of degeneracy, and
finite-dimensional linear algebra.

**Keywords:** heat kernel, spectral moments, power sums, Vandermonde
determinant, cancellation space, kernel dimension, rank–nullity, degeneracy.

---

## 1. Introduction

### 1.1 Motivation

Spectral traces of the form $\sum_i w_i\, e^{-t E_i}$ pervade heat-kernel
expansions, partition functions in statistical mechanics, and semiclassical
approximations. In many settings one is interested not in the leading trace
itself but in its *first correction* under an expansion in a large parameter
$N$ — the term that survives at order $1/N$. Abstractly this correction has the
shape
$$
L(t) = \sum_{i=1}^{n} d_i \, e^{-t E_i},
$$
where the $E_i$ are the (real) energy levels and the $d_i$ encode the
first-order diagonal shifts induced by the perturbation. A recurring and
practically important phenomenon is that this correction sometimes vanishes
identically in $t$: the leading-order contribution *cancels*, robustly, at every
temperature. Empirically this is associated with **degeneracy** — the presence
of energy levels shared by several states.

An earlier development established the level-by-level criterion for this
cancellation: $L \equiv 0$ if and only if the aggregate diagonal shift over each
degenerate energy level is zero. The present paper deepens that result in two
independent directions and unifies them. We show the cancellation is equivalent
to the vanishing of an entire *moment spectrum*, we realize the space of all
cancellations as the kernel of a single explicit linear map, and we compute the
exact dimension of that space in terms of the spectral degeneracy.

### 1.2 Summary of results

Throughout, $n \ge 0$ is the number of states, $E, d : \{1,\dots,n\} \to
\mathbb{R}$, and $m = |\{E_i : i\}|$ denotes the number of distinct energy
values.

- **Theorem A (Moment spectrum).** $L(t) = 0$ for all $t$ if and only if
  $m_k := \sum_i d_i E_i^k = 0$ for all $k \in \mathbb{N}$.
- **Theorem B (Kernel realization).** There is a linear map $S$ (the
  level-aggregation map) whose kernel is exactly the set of shift vectors $d$
  with $L \equiv 0$.
- **Theorem C (Dimension formula).** The cancellation space has dimension
  $n - m$.
- **Corollary D (Degeneracy criterion).** A nonzero $d$ with $L \equiv 0$ exists
  if and only if $m < n$, i.e. the spectrum is degenerate.

The technical engine common to all four is the nonsingularity of the Vandermonde
matrix on the distinct energy values.

---

## 2. Definitions and setup

### 2.1 The leading term and its level sums

**Definition 2.1 (Leading term).** Given a spectrum $E : \{1,\dots,n\} \to
\mathbb{R}$ and shift vector $d : \{1,\dots,n\} \to \mathbb{R}$, the *leading
term* is the function
$$
L(t) \;=\; \operatorname{heatKernelLeading}(E, d)(t) \;=\; \sum_{i=1}^{n} d_i\, e^{-t E_i}, \qquad t \in \mathbb{R}.
$$

**Definition 2.2 (Distinct levels and level sums).** Let $V = \{E_i : 1 \le i \le
n\}$ be the (finite) set of *distinct energy values*, and set $m = |V|$. For each
$v \in V$, the *aggregate shift* (or *level sum*) at $v$ is
$$
s_v \;=\; \sum_{j \,:\, E_j = v} d_j.
$$

We take as our starting point the following level-by-level characterization from
the preceding development.

**Proposition 2.3 (Level-sum criterion, prior result).**
$L(t) = 0$ for all $t \in \mathbb{R}$ if and only if $s_v = 0$ for every distinct
energy value $v \in V$.

The idea behind Proposition 2.3 is that, grouping the sum defining $L$ by energy
value, $L(t) = \sum_{v \in V} s_v\, e^{-t v}$; since the exponential functions
$t \mapsto e^{-tv}$ for distinct $v$ are linearly independent, the whole sum
vanishes identically if and only if each coefficient $s_v$ vanishes. The present
paper reuses Proposition 2.3 as a black box and builds the moment and dimension
theory on top of it.

### 2.2 Spectral moments

**Definition 2.4 (Spectral moments / power sums).** For $k \in \mathbb{N}$, the
$k$-th *spectral moment* of $(E, d)$ is
$$
m_k \;=\; \sum_{i=1}^{n} d_i\, E_i^{\,k}.
$$
Here $m_0 = \sum_i d_i$ (total shift), $m_1 = \sum_i d_i E_i$ (first moment), and
so on, with the convention $E_i^0 = 1$ (including $0^0 = 1$).

---

## 3. The Vandermonde moment lemma

The algebraic heart of the paper is the classical fact that distinct sample
points make power sums a faithful test.

**Lemma 3.1 (Coefficients vanish from vanishing moments).**
Let $\iota$ be a finite index set and $x, c : \iota \to \mathbb{R}$ with $x$
*injective*. If
$$
\sum_{i \in \iota} c_i\, x_i^{\,k} = 0 \qquad \text{for every } k \in \mathbb{N},
$$
then $c_i = 0$ for every $i \in \iota$.

*Proof sketch.* Let $N = |\iota|$ and enumerate $\iota$ as $i_1, \dots, i_N$.
Consider the $N \times N$ Vandermonde matrix $\mathrm{Vand}$ with
$\mathrm{Vand}_{k,\ell} = x_{i_\ell}^{\,k}$ for $k, \ell \in \{0, \dots, N-1\}$.
Its determinant is
$$
\det \mathrm{Vand} = \prod_{\ell < \ell'} \big(x_{i_{\ell'}} - x_{i_\ell}\big),
$$
which is nonzero precisely because $x$ is injective (all differences are
nonzero). The hypotheses for $k = 0, 1, \dots, N-1$ say exactly that the vector
$c = (c_{i_1}, \dots, c_{i_N})^\top$ satisfies $\mathrm{Vand}\, c = 0$. A matrix
with nonzero determinant is invertible, so its only null vector is $c = 0$; hence
every $c_i = 0$. (Only the first $N$ moments are needed; the full family is more
than sufficient.) $\qquad\blacksquare$

**Remark 3.2.** Lemma 3.1 is genuinely load-bearing: the reverse implication in
Theorem A below cannot hold without the Vandermonde nonsingularity. It is exactly
the statement that distinct energies are linearly independent witnesses under the
power-sum pairing.

---

## 4. Fibrewise decomposition of moments

Before proving the moment equivalence we record the reorganization of a moment by
energy value — the algebraic analogue of grouping the trace by level.

**Lemma 4.1 (Level decomposition of a moment).** For every $k \in \mathbb{N}$,
$$
\sum_{i=1}^{n} d_i\, E_i^{\,k} \;=\; \sum_{v \in V} v^{\,k}\, \Big(\sum_{j \,:\, E_j = v} d_j\Big) \;=\; \sum_{v \in V} v^{\,k}\, s_v.
$$

*Proof sketch.* Partition the index set $\{1, \dots, n\}$ into the fibers
$\{j : E_j = v\}$ over the distinct values $v \in V$; these fibers are disjoint
and cover all indices. On the fiber over $v$ we have $E_j = v$, so
$d_j E_j^k = v^k d_j$. Summing over each fiber and then over $v$ regroups the
total sum as claimed; formally this is an exchange of summation order together
with the substitution $E_j = v$ inside each fiber. $\qquad\blacksquare$

Lemma 4.1 exhibits the moment $m_k$ as a Vandermonde-type pairing
$\sum_{v} v^k s_v$ between the powers of the distinct values and the level sums.
This is precisely the shape to which Lemma 3.1 applies.

---

## 5. Theorem A: the moment-spectrum equivalence

**Theorem A (Leading-term cancellation, moment form).**
For any spectrum $E$ and shift vector $d$,
$$
\big(\forall t \in \mathbb{R},\ L(t) = 0\big) \quad\Longleftrightarrow\quad \big(\forall k \in \mathbb{N},\ \textstyle\sum_i d_i E_i^k = 0\big).
$$

*Proof sketch.*

**($\Rightarrow$)** Assume $L \equiv 0$. By Proposition 2.3, every level sum
$s_v = 0$. Fix $k$. By Lemma 4.1, $m_k = \sum_{v \in V} v^k s_v = \sum_{v}
v^k \cdot 0 = 0$. Thus all moments vanish.

**($\Leftarrow$)** Assume $m_k = 0$ for all $k$. Introduce the finite index set
$\iota = V$ of distinct energy values, with the *injective* map $x : \iota \to
\mathbb{R}$, $x(v) = v$ (injective because the elements of $V$ are distinct by
construction), and coefficients $c(v) = s_v = \sum_{j : E_j = v} d_j$. Lemma 4.1
gives
$$
\sum_{v \in \iota} c(v)\, x(v)^k = \sum_{v \in V} v^k s_v = m_k = 0 \qquad \text{for all } k.
$$
By Lemma 3.1, every coefficient vanishes: $s_v = c(v) = 0$ for all $v \in V$.
Proposition 2.3 then yields $L(t) = 0$ for all $t$. $\qquad\blacksquare$

**Interpretation.** Theorem A trades the transcendental test family
$\{t \mapsto e^{-tE_i}\}$ for the algebraic family of power sums $\{E_i^k\}$. Both
families separate the distinct levels — the former by linear independence of
exponentials, the latter by the Vandermonde determinant — so testing against
either is equivalent. The cancellation is thereby exposed as an identity of
formal moments.

---

## 6. Theorems B and C: the cancellation space and its dimension

### 6.1 The level-aggregation map

**Definition 6.1 (Level-aggregation map).** Let $V = \{E_i : i\}$ with $m =
|V|$. The *level-aggregation map* is the linear map
$$
S = \operatorname{cancellationMap}(E) : \mathbb{R}^n \longrightarrow \mathbb{R}^{V}, \qquad S(d)(v) = \sum_{j \,:\, E_j = v} d_j = s_v.
$$
Linearity ($S(d_1 + d_2) = S(d_1) + S(d_2)$ and $S(a\,d) = a\,S(d)$) is immediate
from the additivity and homogeneity of finite sums.

**Definition 6.2 (Cancellation space).** The *cancellation space* is
$$
\mathcal{C}(E) = \{\, d \in \mathbb{R}^n : L(t) = 0 \text{ for all } t \,\}.
$$

**Theorem B (Kernel realization).** $\mathcal{C}(E) = \ker S$. In particular
$\mathcal{C}(E)$ is a linear subspace of $\mathbb{R}^n$.

*Proof sketch.* By Proposition 2.3, $d \in \mathcal{C}(E)$ iff $s_v = 0$ for all
$v \in V$, which says exactly $S(d) = 0$, i.e. $d \in \ker S$. A kernel of a
linear map is a subspace. $\qquad\blacksquare$

### 6.2 Surjectivity and the dimension formula

**Lemma 6.3 (Surjectivity of $S$).** The level-aggregation map $S : \mathbb{R}^n
\to \mathbb{R}^V$ is surjective.

*Proof sketch.* Each fiber $\{j : E_j = v\}$ is nonempty (every $v \in V$ is
$E_i$ for some $i$). Given a target $b \in \mathbb{R}^V$, choose for each $v$ a
representative index $j(v)$ in its fiber and set $d_{j(v)} = b(v)$, with all other
coordinates zero. Then $S(d)(v) = \sum_{j : E_j = v} d_j = b(v)$, so $S(d) = b$.
More conceptually, $S$ is the composite of surjective fiberwise sums; one can
spread any prescribed mass across a nonempty fiber. $\qquad\blacksquare$

**Theorem C (Dimension formula).**
$$
\dim \mathcal{C}(E) \;=\; n - m,
$$
where $m = |\{E_i : i\}|$ is the number of distinct energy levels.

*Proof sketch.* By the rank–nullity theorem applied to $S : \mathbb{R}^n \to
\mathbb{R}^V$,
$$
\dim \ker S + \operatorname{rank} S = \dim \mathbb{R}^n = n.
$$
By Lemma 6.3, $S$ is surjective, so $\operatorname{rank} S = \dim \mathbb{R}^V =
|V| = m$. Hence $\dim \ker S = n - m$, and by Theorem B this is
$\dim \mathcal{C}(E)$. $\qquad\blacksquare$

**Remark 6.4.** Since $V \subseteq \{E_i\}$ arises as the image of an $n$-element
index set, we always have $m \le n$, so the subtraction $n - m$ is well-defined
and nonnegative. The quantity $n - m$ is exactly the *total spectral
degeneracy*: the number of "extra" states beyond one per distinct level. Each
merged pair of states contributes one independent direction of cancellation.

### 6.3 The degeneracy criterion

**Corollary D (Nontrivial cancellation iff degenerate).** There exists a nonzero
$d \in \mathbb{R}^n$ with $L(t) = 0$ for all $t$ **if and only if** $m < n$
(the spectrum is degenerate).

*Proof sketch.* A nonzero element of $\mathcal{C}(E)$ exists iff
$\dim \mathcal{C}(E) > 0$, i.e. by Theorem C iff $n - m > 0$, i.e. $m < n$.
Since $m \le n$ always, $m < n$ is precisely the statement that some energy value
is shared by at least two indices, i.e. the spectrum is degenerate. When $m = n$
(all energies distinct), $\mathcal{C}(E) = \{0\}$: only the trivial perturbation
cancels. $\qquad\blacksquare$

---

## 7. Worked examples

**Example 7.1 (Doubly degenerate pair, $n=2$, $m=1$).** Let $E = (a, a)$ with a
single distinct level. The cancellation condition is the single equation
$s_a = d_1 + d_2 = 0$, a line in $\mathbb{R}^2$. Dimension: $2 - 1 = 1$, matching
Theorem C. A representative nonzero cancellation is $d = (c, -c)$; its moments are
$m_k = c\,a^k - c\,a^k = 0$ for every $k$, consistent with Theorem A and with
$L(t) = c\,e^{-ta} - c\,e^{-ta} = 0$.

**Example 7.2 (Non-degenerate pair, $n=2$, $m=2$).** Let $E = (0, 1)$ with two
distinct levels. The conditions $s_0 = d_1 = 0$ and $s_1 = d_2 = 0$ force
$d = 0$. Dimension: $2 - 2 = 0$. No nontrivial cancellation exists — the spectrum
is non-degenerate, as Corollary D predicts.

**Example 7.3 (Triple with one coincidence, $n=3$, $m=2$).** Let
$E = (a, a, b)$ with $a \ne b$. The conditions are $s_a = d_1 + d_2 = 0$ and
$s_b = d_3 = 0$; the solution space is $\{(c, -c, 0) : c \in \mathbb{R}\}$, of
dimension $3 - 2 = 1$.

---

## 8. Algorithms

The theory is directly computational. We record the two core algorithms; full
implementations appear in the accompanying software.

**Algorithm 8.1 (Cancellation-space dimension).** Given $E \in \mathbb{R}^n$,
compute $m = |\{E_i\}|$ (deduplicating up to a numerical tolerance) and return
$n - m$. Complexity $O(n \log n)$ (sorting) or $O(n)$ expected (hashing).

**Algorithm 8.2 (Cancellation-space basis).** Group indices by energy value into
fibers $F_1, \dots, F_m$. For each fiber $F$ with a chosen anchor index $a \in F$,
and for each other index $j \in F \setminus \{a\}$, emit the basis vector
$e_j - e_a$ (put $+1$ on $j$, $-1$ on $a$, zero elsewhere). These $\sum_r
(|F_r| - 1) = n - m$ vectors are linearly independent and each has zero aggregate
shift on every level, hence they form a basis of $\mathcal{C}(E)$. Complexity
$O(n)$ after grouping.

**Algorithm 8.3 (Moment-based cancellation test).** To test whether a given
$(E, d)$ cancels, it suffices by Theorem A and Lemma 3.1 to check the first $m$
moments $m_0, \dots, m_{m-1}$ (equivalently, all level sums are zero). Compute
each level sum $s_v$ and report cancellation iff all are (numerically) zero.
Complexity $O(n + m^2)$.

---

## 9. Discussion

The results assemble into a single conceptual statement: **leading-term
cancellation is controlled by one linear level-aggregation map.** Its kernel is
the cancellation space (dimension $n - m$), its triviality is equivalent to the
vanishing of every spectral power sum, and both facts trace back to the
invertibility of a Vandermonde system on the distinct energy values.

Three perspectives meet here:

1. **Spectral analysis** — the transcendental identity $\sum_i d_i e^{-tE_i}
   \equiv 0$.
2. **Combinatorics of degeneracy** — the partition of states into equal-energy
   blocks, whose block count $m$ is the only spectral datum that matters.
3. **Finite-dimensional linear algebra** — the kernel and rank of $S$, governed
   by rank–nullity.

A notable feature is *dimensional universality*: $\dim \mathcal{C}(E) = n - m$
depends on the spectrum only through the *number* of distinct levels, not on
their values. Two spectra with the same degeneracy pattern have cancellation
spaces of the same dimension, even if their energies are entirely different. This
suggests that the cancellation dimension is an observable proxy for coarse
spectral degeneracy.

**On the natural-number subtraction.** Theorem C is stated with $n - m$ in
$\mathbb{N}$, which is safe because $m \le n$ always holds ($V$ is the image of an
$n$-element set). Corollary D makes the boundary case $m < n$ explicit, so no
degenerate arithmetic is hidden.

---

## 10. Future directions

Several conjectures push the structure further.

**10.1 Sub-leading cancellation within a fixed degeneracy pattern.** Fix the
partition of levels into equal-energy blocks. Whenever the leading correction
cancels, the next-order correction $\sum_i d_i^2\, e^{-tE_i}$ (a second-order
Feynman–Hellmann term) should cancel for all $t$ if and only if the second-order
shifts also balance block-by-block, with a cancellation space of the *same*
dimension $n - m$. The insight: each order of perturbation theory sees the
spectrum only through the same level-aggregation map, so its cancellation freedom
is a fixed invariant of the degeneracy pattern, independent of order.

**10.2 Minimal sampling.** For a spectrum with exactly $m$ distinct levels, the
leading term should cancel for *all* $t$ as soon as it cancels at any $m$
distinct sample points $t_1, \dots, t_m$. The level-projected function lives in an
$m$-dimensional space of exponentials, so $m$ independent evaluations determine
it — the transcendental identity is finite-dimensional in disguise.

**10.3 Degeneracy detection from dimension alone.** The dimension of the
cancellation space should be a complete invariant of the *coarse* spectral
degeneracy: two spectra share the same cancellation dimension across every
perturbation class if and only if they have the same number of distinct levels,
regardless of the level values. This follows from $\dim = n - m$ depending only
on $m$.

**10.4 Weighted / density-of-states generalization.** Replace the counting of
levels by a positive weight $w_i$ (a density of states), and study the
corresponding weighted level-aggregation map and its kernel.

---

## 11. Conclusion

We have given three equivalent, sharp characterizations of leading-term
cancellation for a heat-kernel–type trace: a moment-spectrum criterion, a
kernel realization via a single linear level-aggregation map, and an exact
dimension formula $n - m$ for the cancellation space, with the immediate
corollary that nontrivial cancellation is possible exactly when the spectrum is
degenerate. The unifying mechanism throughout is the Vandermonde nonsingularity
on distinct energy values, which knits spectral analysis, the combinatorics of
degeneracy, and finite-dimensional linear algebra into one structure.
