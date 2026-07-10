# Cancellation of the Leading Correction in a Spectral Heat-Kernel Expansion

**Author:** Aristotle
**Date:** 2026-07-10

## Abstract

We study the leading correction to a spectral heat-kernel trace under a small
perturbation, and we characterize completely when this correction vanishes. Let a
quantum system have discrete unperturbed energy levels $E_1, \ldots, E_n$ and be
deformed by a perturbation of strength $1/N$. First-order perturbation theory
shifts each level $E_i$ by its diagonal matrix element $d_i$, so the leading $1/N$
correction to the heat-kernel trace $Z(t) = \operatorname{Tr} e^{-tH}$ is the
spectral function $L(t) = \sum_i d_i\, e^{-t E_i}$. We prove: (i) $L(0)$ equals the
trace $\sum_i d_i$ of the perturbation; (ii) if $L$ vanishes identically then the
perturbation is traceless; (iii) for a **non-degenerate** spectrum, $L$ vanishes
identically if and only if every $d_i = 0$; and (iv) for a **general** spectrum,
$L$ vanishes identically if and only if, for each distinct energy value, the
aggregate diagonal shift over the corresponding degenerate level is zero. The
central mechanism is that integer-temperature sampling converts the transcendental
identity $L \equiv 0$ into a Vandermonde linear system in the distinct positive
numbers $e^{-E_i}$; degeneracy is handled by pushing the identity forward to the
set of distinct energy values, whose fibre sums become the new coefficients. We
show by explicit examples that the non-degeneracy hypothesis is necessary and that
degeneracy is the *only* source of nontrivial cancellation.

**Keywords:** heat kernel, spectral expansion, perturbation theory, leading-term
cancellation, Vandermonde determinant, spectral degeneracy, large-$N$ expansion,
exponential linear independence.

## 1. Introduction

Many problems in mathematical physics carry a large parameter $N$, and their
observables are computed as asymptotic series in the small quantity $1/N$. A
recurring and sometimes puzzling phenomenon is the *identical vanishing* of the
leading correction in such a series: the term one expects to dominate turns out to
be zero for all values of an external control parameter. This paper isolates the
phenomenon in its cleanest form — the leading correction to a spectral heat-kernel
trace — and gives a complete, sharp characterization of when it occurs.

Concretely, consider a system with a finite list of energy levels
$E_1, \ldots, E_n \in \mathbb{R}$. Its heat-kernel trace, or partition function, is
$$Z(t) = \sum_{i=1}^n e^{-t E_i}, \qquad t \in \mathbb{R},$$
where $t$ is an inverse temperature. Under a perturbation of strength $1/N$,
first-order (Rayleigh–Schrödinger / Feynman–Hellmann) perturbation theory shifts
the $i$-th level by its diagonal matrix element $d_i = \langle i | V | i \rangle$,
where $V$ is the perturbing operator. Expanding $Z$ for the perturbed spectrum
$E_i + \tfrac{1}{N} d_i$ in powers of $1/N$ gives
$$Z_N(t) = \sum_i e^{-t(E_i + d_i/N)} = Z(t) - \frac{t}{N} \underbrace{\sum_i d_i\, e^{-t E_i}}_{\text{shape of the } 1/N \text{ correction}} + O(1/N^2).$$
The spectral function
$$L(t) := \sum_i d_i\, e^{-t E_i}$$
carries the entire content of the leading correction (the prefactor $-t/N$ is
universal). Our object of study is the vanishing locus of $L$: for which pairs of
data $(E, d)$ is $L(t) = 0$ for all $t \in \mathbb{R}$?

Our answer is that cancellation is never accidental. It is governed entirely by the
partition of the spectrum into degenerate levels, and within each level by a single
linear balance condition. We make this precise in Section 3 and record the
necessary examples establishing sharpness in Section 4.

## 2. Definitions

Throughout, $n$ is a natural number and $E, d : \{1, \ldots, n\} \to \mathbb{R}$ are
two real-valued functions on the index set: $E_i$ is the $i$-th unperturbed energy
level and $d_i$ the first-order diagonal shift of that level.

**Definition 2.1 (Leading correction).** The *leading spectral correction*
associated with energies $E$ and shifts $d$ is the function
$$L(t) = \sum_{i=1}^n d_i\, e^{-t E_i}, \qquad t \in \mathbb{R}.$$

**Definition 2.2 (Non-degenerate spectrum).** The spectrum is *non-degenerate* if
the map $i \mapsto E_i$ is injective, i.e. distinct indices carry distinct
energies. Otherwise the spectrum is *degenerate*, and an *energy level* is a fibre
$\{ i : E_i = v \}$ over a value $v$ in the image of $E$.

**Definition 2.3 (Aggregate level shift).** For an energy value $v$ in the image of
$E$, the *aggregate diagonal shift* of the level at $v$ is
$$S(v) = \sum_{i:\, E_i = v} d_i.$$

**Definition 2.4 (Traceless perturbation).** The perturbation is *traceless* if
$\sum_{i=1}^n d_i = 0$.

## 3. Main results

### 3.1 The trace and its necessity

**Proposition 3.1 (Trace evaluation).** $L(0) = \sum_{i=1}^n d_i.$

*Proof.* Setting $t = 0$ makes each exponential $e^{-0 \cdot E_i} = 1$, so
$L(0) = \sum_i d_i \cdot 1 = \sum_i d_i$. $\qquad\blacksquare$

**Corollary 3.2 (Tracelessness is necessary).** If $L(t) = 0$ for all $t$, then the
perturbation is traceless: $\sum_i d_i = 0$.

*Proof.* Apply the hypothesis at $t = 0$ and use Proposition 3.1. $\qquad\blacksquare$

Tracelessness is necessary but, as Section 4 shows, far from sufficient once
degeneracy is present.

### 3.2 The Vandermonde core

The engine of the entire analysis is the following lemma, which handles the
non-degenerate case directly and, after a change of index set, the general case as
well.

**Lemma 3.3 (Vandermonde cancellation).** Suppose $i \mapsto E_i$ is injective. If
$L(t) = \sum_i d_i\, e^{-t E_i} = 0$ for all $t \in \mathbb{R}$, then $d_i = 0$ for
every $i$.

*Proof.* Set $x_i = e^{-E_i}$. Because $x \mapsto e^{-x}$ is injective and $E$ is
injective, the numbers $x_1, \ldots, x_n$ are distinct (and positive). Sample the
hypothesis at the non-negative integers $t = k$. Since
$$e^{-k E_i} = \left(e^{-E_i}\right)^k = x_i^k,$$
the vanishing of $L(k)$ gives, for every $k \in \mathbb{N}$, the *moment equation*
$$\sum_{i=1}^n x_i^{\,k}\, d_i = 0.$$
Collect the first $n$ of these ($k = 0, 1, \ldots, n-1$) into the matrix equation
$M d = 0$, where $M$ is the (transposed) Vandermonde matrix with entries
$M_{k i} = x_i^{\,k}$. The determinant of a Vandermonde matrix built from
$x_1, \ldots, x_n$ is
$$\det M = \prod_{1 \le i < j \le n} (x_j - x_i),$$
which is nonzero precisely because the $x_i$ are distinct. Hence $M$ is invertible,
and the homogeneous system $M d = 0$ has only the trivial solution $d = 0$.
$\qquad\blacksquare$

**Theorem 3.4 (Non-degenerate characterization).** If $i \mapsto E_i$ is injective,
then
$$\big(\forall t,\ L(t) = 0\big) \iff \big(\forall i,\ d_i = 0\big).$$

*Proof.* The forward direction is Lemma 3.3. Conversely, if all $d_i = 0$ then every
summand of $L(t)$ is zero, so $L \equiv 0$. $\qquad\blacksquare$

Thus, on a spectrum with no degeneracy, the leading correction vanishes only in the
trivial way: nothing was shifted. There is no possibility of a "conspiracy" among
distinct levels.

### 3.3 Level decomposition and the sharp general theorem

To treat degenerate spectra we regroup $L$ by energy value.

**Proposition 3.5 (Fibrewise decomposition).** For every $t$,
$$L(t) = \sum_{v \in \operatorname{im} E} e^{-t v}\, S(v)
      = \sum_{v \in \operatorname{im} E} e^{-t v} \Big(\sum_{i:\, E_i = v} d_i\Big).$$

*Proof.* Partition the index set $\{1, \ldots, n\}$ into the fibres of $E$ over its
image. Since $E_i = v$ on the fibre over $v$, the factor $e^{-t E_i}$ equals
$e^{-t v}$ and can be pulled out of the inner sum. Summing over fibres reproduces
the original sum. $\qquad\blacksquare$

The image of $E$ consists of *distinct* values by construction, so Proposition 3.5
expresses $L$ as a genuine non-degenerate spectral sum, but now with coefficients
$S(v)$. Applying Theorem 3.4 to this regrouped sum yields the main theorem.

**Theorem 3.6 (Level-by-level cancellation).** For an arbitrary spectrum,
$$\big(\forall t,\ L(t) = 0\big) \iff \big(\forall v \in \operatorname{im} E,\ S(v) = 0\big),$$
i.e. the leading correction vanishes identically if and only if, for each distinct
energy value $v$, the aggregate diagonal shift $S(v)$ of the level at $v$ is zero.

*Proof.* By Proposition 3.5, $L(t) = \sum_{v \in \operatorname{im} E} S(v)\, e^{-t v}$,
where the values $v$ are distinct. If each $S(v) = 0$ then every summand vanishes,
so $L \equiv 0$. Conversely, if $L \equiv 0$, apply Lemma 3.3 to the injective family
$(v)_{v \in \operatorname{im} E}$ with coefficients $S(v)$; it forces $S(v) = 0$ for
every $v$. $\qquad\blacksquare$

Theorem 3.6 is the sharp statement. Cancellation of the leading correction is
equivalent to a finite set of linear balance conditions, one per distinct energy
value. Two consequences deserve emphasis:

- **Cancellation is never an accident across levels.** Contributions from different
  energies carry linearly independent temperature profiles $e^{-tv}$ and cannot
  offset one another.
- **Degeneracy is the only route to nontrivial cancellation.** A level with a
  single index contributes $S(v) = d_i$, whose vanishing means $d_i = 0$. Genuine
  cancellation with nonzero shifts requires at least two indices sharing an energy.

## 4. Examples and sharpness

**Example 4.1 (Nontrivial cancellation via degeneracy).** Take a degenerate doublet
at a common energy $a$ with opposite shifts:
$$E = (a, a), \qquad d = (c, -c), \qquad c \neq 0.$$
Then $L(t) = c\, e^{-t a} - c\, e^{-t a} = 0$ for all $t$, yet neither shift is
zero. This realizes the "if" direction of Theorem 3.6 with $S(a) = c + (-c) = 0$,
and simultaneously shows that Theorem 3.4 *fails* without the injectivity
hypothesis.

**Example 4.2 (Distinct levels forbid cancellation).** Put the same opposite shifts
on distinct levels:
$$E = (0, 1), \qquad d = (1, -1).$$
Then $L(t) = 1 \cdot e^{0} + (-1) \cdot e^{-t} = 1 - e^{-t}$, which is strictly
positive for every $t > 0$ (since $e^{-t} < 1$ there). Hence $L$ does *not* vanish
identically, consistent with Theorem 3.4: with distinct energies, a nonzero shift
vector cannot cancel.

Together, Examples 4.1 and 4.2 show that both the statement of Theorem 3.6 and the
necessity of degeneracy in Theorem 3.4 are sharp: neither can be strengthened or
weakened without becoming false.

## 5. Algorithms

The characterization is entirely constructive and yields simple, exact algorithms.

**Algorithm A (Cancellation test).** Given energies $E$ and shifts $d$, decide
whether $L \equiv 0$: group indices by energy value, compute each aggregate shift
$S(v) = \sum_{E_i = v} d_i$, and report cancellation iff every $S(v) = 0$. This runs
in $O(n)$ time (or $O(n \log n)$ if grouping requires a sort) and is exact over the
rationals — no transcendental evaluation is needed, precisely because Theorem 3.6
reduces the analytic condition to finitely many linear sums.

**Algorithm B (Moment / Vandermonde reconstruction).** Given distinct energies and
the promise that $L \equiv 0$, recover $d = 0$ by forming the moment equations
$\sum_i x_i^k d_i = 0$ ($x_i = e^{-E_i}$) for $k = 0, \ldots, n-1$ and solving the
resulting Vandermonde system. More usefully, the same machinery *reconstructs*
unknown shifts $d$ from a finite set of integer-temperature samples $L(0), \ldots,
L(n-1)$: the map from shifts to samples is exactly multiplication by the invertible
Vandermonde matrix, so inversion recovers $d$ uniquely. Complexity is $O(n^2)$ using
the specialized Vandermonde solver.

## 6. Applications and discussion

The result formalizes a diagnostic principle. Whenever a leading $1/N$ correction to
a spectral trace is observed to vanish, Theorem 3.6 states that the shifts must
balance within each degenerate multiplet. Since exact degeneracy is generically the
product of symmetry, this ties the vanishing of the leading correction to the
representation theory of the symmetry group: a perturbation transforming in a
nontrivial irreducible representation projects to zero on the trivial isotypic
component of each multiplet, forcing $S(v) = 0$ automatically. In such a case
cancellation is *guaranteed*, not fine-tuned.

Two structural remarks emerged from the analysis and are worth stating explicitly.

- **Genericity of non-cancellation.** For a fixed spectrum, the set of shift vectors
  $d$ with $L \equiv 0$ is the joint kernel of the linear functionals $d \mapsto S(v)$,
  one per distinct energy value. These functionals are linearly independent, so the
  cancellation locus is a linear subspace of codimension equal to the number of
  distinct energy values. Cancellation is therefore a measure-zero, non-generic event
  unless forced by structure.
- **Analysis meets algebra.** The proof converts a transcendental identity into
  finite-dimensional linear algebra via integer sampling. This is a reusable
  template: linear independence of $\{t \mapsto e^{-tE_i}\}$ over distinct rates is
  precisely the invertibility of a Vandermonde matrix in $e^{-E_i}$.

## 7. Future directions

The first-order picture is now completely determined, which opens several
falsifiable conjectures at higher order and in the presence of symmetry.

1. **Second-order cancellation via off-diagonal balance.** The subleading $1/N^2$
   term should cancel identically for all temperatures if and only if, on each
   degenerate level, both the diagonal shift sum vanishes *and* a level-restricted
   quadratic form in the off-diagonal couplings (weighted by inverse energy gaps)
   vanishes. Once the diagonal obstruction is removed, the next obstruction is a
   quadratic form whose kernel is again a level-by-level balance condition, one rung
   higher.

2. **Genericity of non-cancellation.** For a fixed spectrum, the cancellation locus
   is a proper linear subspace whose codimension equals the number of distinct
   energy values; cancellation is thus non-generic unless forced by symmetry. This
   converts a hard analytic condition into a concrete, checkable dimension count.

3. **Symmetry certifies cancellation.** If a finite symmetry group acts on the
   spectrum with the perturbation transforming in a nontrivial irreducible
   representation, then every degenerate level carrying that representation has
   vanishing diagonal shift sum, so the leading term cancels automatically — the
   level-sum functional is the projection onto the trivial isotypic component.

## 8. Conclusion

We have given a complete and sharp characterization of when the leading correction
$L(t) = \sum_i d_i e^{-tE_i}$ to a spectral heat-kernel trace vanishes for all
temperatures. It vanishes if and only if the aggregate diagonal shift over each
degenerate energy level is zero; for a non-degenerate spectrum this degenerates to
the trivial requirement that all shifts vanish. The proof rests on two classical
pillars — the linear independence of exponentials with distinct rates and the
invertibility of the Vandermonde matrix — bridged by the elementary device of
sampling at integer temperatures. Cancellation of the dominant correction is thus
revealed to be, always, the signature of an exact intra-level balance.
