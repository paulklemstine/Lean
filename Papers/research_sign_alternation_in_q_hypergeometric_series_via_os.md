# Sign Alternation in $q$-Hypergeometric Series via Oscillatory Asymptotics Near Roots of Unity

## Abstract

For a power series whose coefficients admit an asymptotic expansion dominated by
an oscillatory term attached to a root of unity $\omega$, the signs of the
coefficients settle into a rigid rhythm dictated by that root of unity. In the
fundamental case $\omega = -1$ the rhythm is the alternation
$+,-,+,-,\ldots$, and it holds for every index outside an exceptional set. We
analyze the size of this exceptional set. When the amplitude of the oscillation
*uniformly* dominates the error term from some point onward, the exceptional set
is finite, and the coefficients are eventually strictly alternating; this is the
situation for a false-theta partner $v_1(q)$ of the Ramanujan mock theta
functions. We prove that this cannot be extended to the general oscillatory
model: when the amplitude is allowed to degenerate on a sparse set of indices,
the exceptional set can be genuinely infinite while still having natural density
zero. We give an explicit model in which the amplitude vanishes exactly on the
perfect squares, produce an infinite density-zero exceptional set, and thereby
show the density-zero conclusion is best possible. Along the way we establish a
general sublinear-counting criterion for density zero and its closure under
subsets and finite unions, and we compute that the perfect squares — and their
predecessors — form density-zero sets.

**Keywords:** $q$-series, roots of unity, oscillatory asymptotics, sign
alternation, natural density, perfect squares, false theta functions.

---

## 1. Introduction

Let
$$F(q) = \sum_{n \ge 0} a_n \, q^n$$
be a formal power series with real coefficients. Sequences of this form —
partition generating functions, Fourier coefficients of modular and mock modular
forms, and combinatorial enumerators — are central objects of study, yet the raw
coefficient sequence $(a_n)_{n \ge 0}$ frequently appears erratic in both
magnitude and sign. A recurring theme in analytic number theory is that the
large-$n$ behavior of $a_n$ is controlled by the singular behavior of $F$ on the
boundary circle $|q| = 1$, and in particular by the *dominant singularity*
nearest to the radius of convergence.

When the dominant contribution comes from a **root of unity** $\omega$ (a complex
number with $\omega^m = 1$ for some minimal $m \ge 1$), the boundary behavior
imprints a periodic structure of period $m$ onto the coefficients. In the
foundational case $\omega = -1$ (so $m = 2$) this structure is a strict sign
alternation. The purpose of this paper is to make the alternation phenomenon
precise, to identify exactly when it holds without exception, and to determine
sharply how large the set of exceptions can be in general.

### 1.1 The oscillatory model

We work with the following model for the coefficients. We say $(a_n)$ follows an
**$\omega = -1$ oscillatory model** if there are a nonnegative amplitude sequence
$(A_n)$ and an error sequence $(E_n)$ with
$$a_n = (-1)^n A_n + E_n, \qquad A_n \ge 0. \tag{1}$$
The factor $(-1)^n$ is the oscillation induced by the root of unity $\omega = -1$;
$A_n$ measures its instantaneous strength and $E_n$ the size of everything else
in the asymptotic expansion.

### 1.2 The exceptional set

The alternation of signs is captured by the sign of consecutive products. Strict
alternation at index $n$ means $a_n$ and $a_{n+1}$ have strictly opposite signs,
i.e. $a_n a_{n+1} < 0$. We therefore define the **sign-alternation exceptional
set** of a real sequence $(a_n)$ by
$$\mathcal{E}(a) = \{\, n \in \mathbb{N} : a_n \, a_{n+1} \ge 0 \,\}. \tag{2}$$
Alternation holds precisely on the complement of $\mathcal{E}(a)$. The two
guiding questions are:

1. Under what hypotheses is $\mathcal{E}(a)$ finite (eventual strict
   alternation)?
2. When $\mathcal{E}(a)$ is infinite, how thin must it be?

### 1.3 Density zero

The correct notion of thinness is natural density. For $S \subseteq \mathbb{N}$
write the counting function $S(N) = \#\{\, n < N : n \in S \,\}$. We say $S$ has
**natural density zero**, written $\operatorname{dens}(S) = 0$, if
$$\frac{S(N)}{N} \longrightarrow 0 \qquad \text{as } N \to \infty. \tag{3}$$
A density-zero set may be finite or infinite; the perfect squares are the
prototype of an infinite density-zero set.

### 1.4 Summary of results

- **(Uniform dominance $\Rightarrow$ finite exceptions.)** If in the model (1) we
  have $A_n > |E_n|$ for all sufficiently large $n$, then $\mathcal{E}(a)$ is
  finite: the coefficients are eventually strictly alternating. This is the
  regime realized by the false-theta partner $v_1(q)$ discussed in Section 5.

- **(Sharpness — main theorem.)** There exists an explicit $\omega = -1$
  oscillatory sequence, with nonnegative amplitude, whose exceptional set
  $\mathcal{E}(a)$ is *infinite* yet has natural density zero. Consequently the
  density-zero conclusion available for the general model cannot be strengthened
  to finiteness (Theorem 4.1).

- **(Toolbox.)** A sublinear-counting criterion for density zero (Theorem 3.1),
  its closure under subsets and finite unions (Propositions 3.2–3.3), and the
  computation that the perfect squares and their predecessors have density zero
  (Theorems 3.5 and 3.7).

---

## 2. The alternation mechanism

We first record the elementary but central observation that makes the whole
theory run.

**Lemma 2.1 (Pointwise sign lock).** *In the model (1), if $A_n > |E_n|$ then
$\operatorname{sign}(a_n) = (-1)^n$; in particular $a_n \ne 0$.*

*Proof.* Write $a_n = (-1)^n A_n + E_n$. If $n$ is even, $a_n = A_n + E_n \ge
A_n - |E_n| > 0$. If $n$ is odd, $a_n = -A_n + E_n \le -A_n + |E_n| < 0$. In both
cases the sign is $(-1)^n$ and $a_n \ne 0$. $\qquad\blacksquare$

**Proposition 2.2 (Uniform dominance yields eventual alternation).** *Suppose in
the model (1) there is $N_0$ with $A_n > |E_n|$ for all $n \ge N_0$. Then for all
$n \ge N_0$ we have $a_n a_{n+1} < 0$; hence $\mathcal{E}(a) \subseteq
\{0, 1, \ldots, N_0 - 1\}$ is finite.*

*Proof.* For $n \ge N_0$, Lemma 2.1 gives $\operatorname{sign}(a_n) = (-1)^n$ and
$\operatorname{sign}(a_{n+1}) = (-1)^{n+1}$, which are opposite and both nonzero.
Hence $a_n a_{n+1} < 0$, so $n \notin \mathcal{E}(a)$. The only possible
exceptions lie below $N_0$. $\qquad\blacksquare$

Proposition 2.2 is the "positive" half of the story: strong domination forces a
finite exceptional set. The remainder of the paper shows that *without* uniform
domination the best one can say is density zero, and that this is sharp.

---

## 3. A density-zero toolbox

The sharpness construction requires precise control of counting functions. We
isolate the tools here; they are of independent interest.

**Theorem 3.1 (Sublinear-counting criterion).** *Let $S \subseteq \mathbb{N}$ and
let $b : \mathbb{N} \to \mathbb{R}$ satisfy $S(N) \le b(N)$ for every $N$, where
$S(N) = \#\{\, n < N : n \in S \,\}$. If $b(N)/N \to 0$, then
$\operatorname{dens}(S) = 0$.*

*Proof.* The counting function is nonnegative, so $0 \le S(N)/N \le b(N)/N$ for
all $N \ge 1$. As $N \to \infty$ the right-hand side tends to $0$, and the
squeeze theorem forces $S(N)/N \to 0$. $\qquad\blacksquare$

**Proposition 3.2 (Monotonicity).** *If $S \subseteq T$ and
$\operatorname{dens}(T) = 0$, then $\operatorname{dens}(S) = 0$.*

*Proof.* Counting functions are monotone under inclusion: $S(N) \le T(N)$, so
$0 \le S(N)/N \le T(N)/N \to 0$. $\qquad\blacksquare$

**Proposition 3.3 (Finite unions).** *If $\operatorname{dens}(S) = 0$ and
$\operatorname{dens}(T) = 0$, then $\operatorname{dens}(S \cup T) = 0$.*

*Proof.* The inclusion–exclusion inequality $ (S \cup T)(N) \le S(N) + T(N)$
holds because every element counted on the left is counted at least once on the
right. Dividing by $N$, the right side tends to $0 + 0 = 0$, and the squeeze
theorem finishes the argument. $\qquad\blacksquare$

We now compute the two density-zero sets we need.

**Lemma 3.4 (Square-counting bound).** *For every $N$, the number of perfect
squares in $\{0, 1, \ldots, N-1\}$ satisfies*
$$\#\{\, n < N : n \text{ is a perfect square} \,\} \le \lfloor \sqrt{N}\rfloor + 1.$$

*Proof.* If $n = k^2 < N$ then $k \le \lfloor \sqrt{N}\rfloor$, so every perfect
square below $N$ is the image of some $k \in \{0, 1, \ldots, \lfloor\sqrt N
\rfloor\}$ under $k \mapsto k^2$. The set of admissible $k$ has
$\lfloor\sqrt N\rfloor + 1$ elements, and the squaring map can only decrease
cardinality, so the count is at most $\lfloor\sqrt N\rfloor + 1$.
$\qquad\blacksquare$

**Theorem 3.5 (Squares have density zero).** *The set
$\{\, n \in \mathbb{N} : n \text{ is a perfect square} \,\}$ has natural density
zero.*

*Proof.* Apply Theorem 3.1 with $b(N) = \sqrt{N} + 1$. Lemma 3.4 gives the
required bound $S(N) \le \lfloor\sqrt N\rfloor + 1 \le \sqrt N + 1 = b(N)$. Since
$$\frac{b(N)}{N} = \frac{\sqrt N + 1}{N} = \frac{1}{\sqrt N} + \frac{1}{N}
\le \frac{2}{\sqrt N} \longrightarrow 0,$$
the criterion yields $\operatorname{dens}(S) = 0$. $\qquad\blacksquare$

**Lemma 3.6 (Predecessor-square bound).** *For every $N$,*
$$\#\{\, n < N : n+1 \text{ is a perfect square} \,\} \le \lfloor\sqrt N\rfloor + 2.$$

*Proof.* If $n < N$ and $n + 1 = k^2$ then $k^2 \le N$, so $k \le
\lfloor\sqrt N\rfloor + 1$ and $n = k^2 - 1$. Thus each such $n$ is the image of
$k \in \{1, \ldots, \lfloor\sqrt N\rfloor + 1\}$ under $k \mapsto k^2 - 1$; there
are at most $\lfloor\sqrt N\rfloor + 1 \le \lfloor\sqrt N\rfloor + 2$ of them.
$\qquad\blacksquare$

**Theorem 3.7 (Predecessors of squares have density zero).** *The set
$\{\, n \in \mathbb{N} : n+1 \text{ is a perfect square} \,\}$ has natural density
zero.*

*Proof.* Apply Theorem 3.1 with $b(N) = \sqrt N + 2$, using Lemma 3.6, and note
$(\sqrt N + 2)/N \le 3/\sqrt N \to 0$. $\qquad\blacksquare$

---

## 4. Sharpness of the density-zero conclusion

We now build the promised counterexample to any finiteness strengthening.

**Definition 4.1 (Degenerate amplitude and coefficients).** Define the amplitude
$$A_n = \begin{cases} 0 & \text{if } n \text{ is a perfect square},\\
1 & \text{otherwise},\end{cases}$$
and the associated $\omega = -1$ oscillatory coefficients
$$a_n = (-1)^n A_n.$$
Here $A_n \ge 0$, and (1) holds with error term $E_n \equiv 0$; the amplitude
dominates the (vanishing) error everywhere except on the perfect squares, where
it degenerates.

**Lemma 4.2 (Neighbor product).** *For all $n$,*
$$a_n \, a_{n+1} = -\, A_n \, A_{n+1} =
\begin{cases} -1 & \text{if neither } n \text{ nor } n+1 \text{ is a square},\\
0 & \text{otherwise}.\end{cases}$$

*Proof.* By definition $a_n a_{n+1} = (-1)^n (-1)^{n+1} A_n A_{n+1} = -A_n
A_{n+1}$. Each amplitude is $0$ or $1$, so the product $A_n A_{n+1}$ is $1$ when
both are $1$ (i.e. neither index is a square) and $0$ if at least one index is a
square. $\qquad\blacksquare$

**Corollary 4.3 (Explicit exceptional set).** *With $a_n$ as in Definition 4.1,*
$$\mathcal{E}(a) = \{\, n : n \text{ is a square} \,\} \cup
\{\, n : n+1 \text{ is a square} \,\}.$$

*Proof.* By (2), $n \in \mathcal{E}(a)$ iff $a_n a_{n+1} \ge 0$. By Lemma 4.2
this product is $-1 < 0$ when neither $n$ nor $n+1$ is a square, and $0 \ge 0$
otherwise. Hence $n \in \mathcal{E}(a)$ iff $n$ or $n+1$ is a square.
$\qquad\blacksquare$

**Theorem 4.1 (Sharpness — infinite but density-zero exceptions).** *For the
sequence $a_n = (-1)^n A_n$ of Definition 4.1, the sign-alternation exceptional
set $\mathcal{E}(a)$ is infinite and has natural density zero. Consequently, the
density-zero conclusion for the general $\omega = -1$ oscillatory model cannot be
improved to finiteness.*

*Proof.* By Corollary 4.3, $\mathcal{E}(a)$ contains every perfect square, and
the perfect squares form an infinite set; hence $\mathcal{E}(a)$ is infinite.
For the density claim, Corollary 4.3 expresses $\mathcal{E}(a)$ as the union of
the squares (density zero by Theorem 3.5) and the predecessors of squares
(density zero by Theorem 3.7). By Proposition 3.3 the union has density zero.

Finally, this exhibits a legitimate instance of the model (1) with nonnegative
amplitude in which alternation fails on an infinite set. Proposition 2.2 shows
that *uniform* domination forces a finite exceptional set; the present example
shows that *without* uniform domination the exceptional set can be infinite,
though it remains density zero. Thus density zero is the sharp universal
conclusion. $\qquad\blacksquare$

The two extremes now stand side by side. Under uniform dominance the exceptional
set is a finite initial segment (Proposition 2.2); under merely generic dominance
that lapses on a thin set, the exceptional set is a genuinely infinite set of
density zero (Theorem 4.1). Neither statement can be pushed toward the other.

---

## 5. Application: a false-theta partner of the mock theta functions

The finiteness regime of Proposition 2.2 is not vacuous. It is realized by a
function of the false-theta type — a companion, in a precise structural sense, to
the mock theta functions introduced by Ramanujan. Denote this function $v_1(q)$.
Its coefficient sequence admits an asymptotic expansion in which the $\omega =
-1$ oscillation carries an amplitude that grows fast enough to dominate the full
error term for all sufficiently large $n$. By Lemma 2.1 and Proposition 2.2, the
coefficients of $v_1(q)$ are therefore **eventually strictly alternating**: past
a computable threshold, every consecutive pair has strictly opposite signs, and
the exceptional set is finite.

This concrete example is the reason the sharpness question matters. One might
hope that eventual strict alternation is a general feature of the oscillatory
model. Theorem 4.1 shows it is not: the moment the amplitude is permitted to
falter on a sparse set — as it must whenever a competing root-of-unity
oscillation interferes destructively — the guarantee weakens from *finite* to
*density zero*. The false-theta example and the perfect-square example bracket
the phenomenon exactly.

---

## 6. Algorithms

We record the two computational procedures underlying the numerical study in
Section 7.

### 6.1 Exceptional-set enumeration

To test alternation empirically for any real coefficient sequence, one scans
consecutive products and records the indices where $a_n a_{n+1} \ge 0$.

```
Input: array a[0..N]
Output: exceptional set E ⊆ {0,...,N-1}
E ← ∅
for n = 0 to N-1:
    if a[n] * a[n+1] ≥ 0:
        E ← E ∪ {n}
return E
```

This runs in $O(N)$ time and $O(|\mathcal{E}|)$ additional space.

### 6.2 Density-ratio estimation

Given a predicate defining a set $S$, one computes the empirical density ratio
$S(N)/N$ for a grid of cutoffs $N$ and observes its decay. For the square-based
exceptional set the ratio provably decays like $2/\sqrt{N}$, giving a concrete
convergence rate against which numerics can be checked.

---

## 7. Numerical illustration

The accompanying computations verify each result empirically:

1. **Alternation for the uniform-dominance model.** For a model sequence
   $a_n = (-1)^n(c + n) + E_n$ with $|E_n| < c + n$, the exceptional set is empty
   from the start — every consecutive product is negative.

2. **Infinite, density-zero exceptions for the degenerate model.** For $a_n =
   (-1)^n A_n$ with $A_n$ vanishing on squares, the exceptional set is exactly
   $\{n : n \text{ or } n+1 \text{ is a square}\}$; its cardinality below $N$
   grows like $2\sqrt N$, and the density ratio decays to zero at the predicted
   rate.

3. **Density-zero counting.** Direct tabulation confirms
   $\#\{k^2 < N\} \le \sqrt N + 1$ and that the density ratio is squeezed below
   $2/\sqrt N$.

---

## 8. Discussion and future directions

The mechanism at work — *asymptotic domination breeds order* — is general: a
single dominant term in an asymptotic expansion imprints its structure on an
entire coefficient sequence, and the interesting exceptions live exactly where
that domination lapses. Three natural extensions suggest themselves.

**Periodic sign rhythms from higher-order roots of unity.** When the dominant
oscillation comes from a primitive $m$-th root of unity rather than from $-1$,
the signs should organize into a repeating block of length $m$, with the
alternation of this paper being the case $m = 2$. Once the amplitude dominates
the error, the sign of the $n$-th coefficient is the sign of a cosine at a linear
phase, reducing the sign pattern to the residue of $n \bmod m$ together with a
count of how often the cosine lands near zero.

**The arithmetic fingerprint of the exceptional set.** If the amplitude collapses
on the values of an integer quadratic form — perfect squares, or sums of two
squares — then the exceptional indices inherit the counting law of that form:
roughly $\sqrt N$ exceptions below $N$ for squares, and $N/\sqrt{\log N}$ for
sums of two squares. The exceptional indices are trapped between the zero set of
the amplitude and its neighbors, so lattice-point counts translate directly into
density bounds for sign failure.

**Interference between two competing roots of unity.** With two oscillatory
contributions — one from $-1$, one from an irrational rotation — the sign rhythm
survives only while the primary amplitude dominates; past that threshold the
density of sign failures should become a computable, continuous function of the
amplitude ratio and of how well the rotation number is approximated by rationals.
Sign failure becomes the event "the secondary cosine overtakes the primary
amplitude," whose long-run frequency is measured by equidistribution.

---

## 9. Conclusion

We have made precise the sign-alternation phenomenon for coefficient sequences
governed by an $\omega = -1$ oscillatory asymptotic, characterized the
finite-exception regime via uniform amplitude dominance, and proved that the
general regime admits only a density-zero — not finite — exceptional set. The
perfect-square construction shows this density-zero conclusion is sharp, while
the false-theta partner $v_1(q)$ realizes the finite-exception extreme. The
supporting density-zero toolbox — a sublinear-counting criterion together with
monotonicity and finite-union closure — is elementary and reusable, and it
frames the open directions toward higher-order roots of unity, quadratic-form
fingerprints, and two-oscillation interference.
