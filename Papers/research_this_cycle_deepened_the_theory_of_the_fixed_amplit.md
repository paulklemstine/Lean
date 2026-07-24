# Spectral Line-Locking in Fixed-Amplitude Complex-Weighted Undirected Graphs

**Author:** Aristotle

**Date:** 2026-07-24

## Abstract

We study the *fixed-amplitude model* of complex-weighted undirected graphs, in
which every present edge of an undirected graph on $n$ vertices carries one
common complex weight $z \in \mathbb{C}$. The weighted adjacency matrix factors
as $A = z\cdot B$, where $B$ is the Hermitian $0/1$ indicator matrix of the
symmetric edge relation. Our central result is **spectral line-locking**: for
nonzero $z$, every eigenvalue of $A$ is $z$ times a real number, so the entire
spectrum of $A$ collapses onto the one-dimensional line $\mathbb{R}\cdot z
\subseteq \mathbb{C}$. We prove this via a Rayleigh-quotient argument that
isolates the exact obstruction to two-dimensional (circular-law) behavior: all
randomness resides in the Hermitian core $B$, and a single complex scalar can
only rotate and dilate a real spectrum. We complement line-locking with the
global multiplicative invariants of the model — the trace scales as
$\operatorname{tr}(z\cdot B) = z\operatorname{tr}(B)$ and vanishes for loopless
graphs, while the determinant scales as $\det(z\cdot B) = z^n\det(B)$, whence
singularity of $A$ is a purely combinatorial (weight-independent) property of
$B$. Finally, for the complete graph $K_n$ we exhibit the mean-direction
eigenvalue $(n-1)z$ carried by the all-ones vector and prove that, for every
order $n \ge 3$, its modulus $(n-1)\lvert z\rvert$ strictly exceeds the naive
spectral radius $\sqrt{n}\cdot\lvert z\rvert$, so it is a genuine outlier. These
closed-form results delimit precisely where circular-law phenomena can and
cannot arise and motivate several sharp conjectures on phase-symmetry breaking,
outlier thresholds, and singularity in random graphs.

**Keywords:** complex-weighted graphs, weighted adjacency matrix, Hermitian
matrices, Rayleigh quotient, spectral radius, eigenvalue outliers, random
graphs, circular law, determinant, complete graph.

## 1. Introduction

The spectral theory of random matrices splits sharply along one axis: symmetry.
Symmetric (real) or Hermitian (complex) matrices have real spectra that, in the
large-$n$ limit, fill an interval according to Wigner's semicircle law.
Non-Hermitian matrices with independent entries instead have complex spectra
that fill a two-dimensional disk according to the circular law. A recurring
question in applications — spectral graph theory, synchronization, and network
dynamics among them — is how *weighting* the edges of a graph, especially with
complex weights, moves a model between these regimes.

This paper isolates and completely solves a boundary case: the **fixed-amplitude
model**, in which the graph is undirected and *every* present edge carries the
*same* complex weight $z$. This is the maximally phase-coherent weighting: no
edge-to-edge variation in strength or direction. We show that this coherence has
a dramatic and exact spectral consequence — the spectrum cannot be a
two-dimensional cloud; it is confined to a single line through the origin. We
call this **spectral line-locking**.

The value of an exact result here is that it pins down the *precise algebraic
obstruction* to circular-law behavior. The obstruction is the factorization $A
= z\cdot B$ with $B$ Hermitian: a scalar times a Hermitian matrix. Everything
random lives in $B$, whose spectrum is real; the scalar $z$ can only rotate and
scale. Recognizing this immediately tells us what to change if we want
two-dimensional spectra: break the shared phase so the matrix is no longer a
scalar multiple of a Hermitian matrix.

### Contributions

1. **Spectral line-locking** (Theorem 3.1): every eigenvalue of $z\cdot B$ is
   $z\cdot r$ with $r$ real, for Hermitian $B$ and nonzero $z$; equivalently the
   spectrum lies on $\mathbb{R}\cdot z$ (Theorem 3.2).
2. **Global multiplicative invariants** (Section 4): $\operatorname{tr}(z\cdot B)
   = z\operatorname{tr}(B)$, vanishing for loopless graphs; $\det(z\cdot B) =
   z^n\det(B)$; and consequently singularity of $z\cdot B$ is equivalent to
   singularity of $B$ for every nonzero $z$.
3. **Mean-direction outlier for the complete graph** (Section 5): the all-ones
   vector is an eigenvector of $z\cdot K_n$ with eigenvalue $(n-1)z$, and for
   $n\ge 3$ its modulus $(n-1)\lvert z\rvert$ exceeds the naive radius
   $\sqrt{n}\,\lvert z\rvert$.

## 2. Definitions and setup

Throughout, $n$ is a positive integer and matrices are indexed by an $n$-element
set. We work over the complex field $\mathbb{C}$.

**Definition 2.1 (Indicator matrix of an undirected graph).** Let $G$ be an
undirected graph on vertex set $V$ with $\lvert V\rvert = n$. Its *indicator
matrix* $B \in \mathbb{C}^{n\times n}$ is defined by $B_{ij} = 1$ if $\{i,j\}$
is an edge of $G$, and $B_{ij} = 0$ otherwise. Because $G$ is undirected,
$B_{ij} = B_{ji}$; because its entries are real, $B$ equals its conjugate
transpose, i.e. $B$ is **Hermitian** ($B^{*} = B$). If $G$ has no self-loops
then $B_{ii} = 0$ for all $i$; we call such $B$ *loopless*.

**Definition 2.2 (Fixed-amplitude weighted adjacency matrix).** Fix a complex
number $z \in \mathbb{C}$, the *weight* or *amplitude*. The *fixed-amplitude
weighted adjacency matrix* of $G$ is
$$A \;=\; z\cdot B,$$
the scalar multiple of the indicator matrix by $z$. Every present edge thus
carries the single common complex weight $z$; absent edges carry $0$.

**Definition 2.3 (Rayleigh quotient / quadratic form).** For a matrix $M \in
\mathbb{C}^{n\times n}$ and a vector $v \in \mathbb{C}^n$, the (unnormalized)
Rayleigh quotient is the sesquilinear form
$$\langle v, M v\rangle \;=\; \overline{v}^{\,\top} (M v) \;=\; \sum_{i} \overline{v_i}\,(Mv)_i.$$
We write $\langle v, v\rangle = \sum_i \lvert v_i\rvert^2 \ge 0$, which is real,
nonnegative, and strictly positive when $v \neq 0$.

**Definition 2.4 (Complex line through the origin).** For $z \in \mathbb{C}$ the
*line* $\mathbb{R}\cdot z = \{\, r z : r \in \mathbb{R}\,\}$ is the real
one-dimensional subspace of $\mathbb{C}$ spanned by $z$ (a genuine line through
the origin when $z \neq 0$, and $\{0\}$ when $z = 0$).

We use two standard facts, recorded as lemmas.

**Lemma 2.5 (Reality criterion).** A complex number $q$ with vanishing imaginary
part equals (the coercion of) its real part: if $\operatorname{Im}(q) = 0$ then
$q = \operatorname{Re}(q) \in \mathbb{R}$.

**Lemma 2.6 (Hermitian quadratic forms are real).** If $B$ is Hermitian then for
every $v$, $\langle v, B v\rangle$ is real, i.e. $\operatorname{Im}\langle v, B
v\rangle = 0$ and hence $\langle v, B v\rangle = \operatorname{Re}\langle v, B
v\rangle$.

*Proof.* The conjugate of $\langle v, B v\rangle$ is $\langle B v, v\rangle =
\langle v, B^{*} v\rangle = \langle v, B v\rangle$ using $B^{*} = B$. A complex
number equal to its own conjugate is real; apply Lemma 2.5. $\square$

## 3. Spectral line-locking

The core of the theory is a two-line computation with the Rayleigh quotient. We
first record how scaling the matrix scales the quotient.

**Lemma 3.0 (Scaling the Rayleigh quotient).** For any $B$, scalar $z$, and
vector $v$,
$$\langle v, (z\cdot B) v\rangle \;=\; z\,\langle v, B v\rangle.$$
In particular, if $B$ is Hermitian then $\langle v, (z\cdot B) v\rangle = z\cdot
r$ for some real $r$ (namely $r = \operatorname{Re}\langle v, B v\rangle$), by
Lemma 2.6.

*Proof.* $(z\cdot B)v = z\,(Bv)$, and the sesquilinear form is linear in its
second slot, so $\langle v, z\,(Bv)\rangle = z\,\langle v, Bv\rangle$. The second
claim is immediate from Lemma 2.6. $\square$

**Theorem 3.1 (Spectral line-locking).** Let $B \in \mathbb{C}^{n\times n}$ be
Hermitian, let $z \in \mathbb{C}$, and suppose $v \neq 0$ is an eigenvector of
$A = z\cdot B$ with eigenvalue $\mu$, i.e. $A v = \mu v$. Then there exists a
real number $r$ with
$$\mu \;=\; z\cdot r.$$
Consequently every eigenvalue of $z\cdot B$ lies on the line $\mathbb{R}\cdot z$.

*Proof.* Put $q = \langle v, B v\rangle$ and $s = \langle v, v\rangle$. By Lemma
2.6, $q$ is real; and $s = \sum_i \lvert v_i\rvert^2$ is real with $s > 0$ since
$v \neq 0$. Compute $\langle v, A v\rangle$ two ways. First, by Lemma 3.0,
$\langle v, A v\rangle = z\,q$. Second, using $A v = \mu v$ and linearity,
$\langle v, A v\rangle = \mu\,\langle v, v\rangle = \mu\,s$. Equating,
$$\mu\, s \;=\; z\, q.$$
Since $s$ is a nonzero real, divide to obtain $\mu = z\cdot (q/s)$. Both $q$ and
$s$ are real and $s \neq 0$, so $r := q/s \in \mathbb{R}$, giving $\mu = z\cdot
r$. As $\mu = zr \in \mathbb{R}\cdot z$, the spectrum is confined to the line.
$\square$

**Theorem 3.2 (Spectrum on the line).** Under the hypotheses of Theorem 3.1,
$$\mu \in \{\, (r) z : r \in \mathbb{R}\,\} = \mathbb{R}\cdot z.$$
That is, the point $\mu$ is a real scalar multiple of $z$; equivalently, if $z
\neq 0$, then $\mu / z \in \mathbb{R}$.

*Proof.* Immediate from Theorem 3.1 by taking the witness $r$ and observing
$(r) z = z r = \mu$. $\square$

**Remark 3.3 (Where the obstruction lives).** The proof reveals that
line-locking is caused *entirely* by the scalar–Hermitian factorization $A =
z\cdot B$. All the graph's structure sits inside the Hermitian $B$, whose
Rayleigh quotient is real; the scalar $z$ contributes exactly one rotation and
one dilation. No amount of randomness in the *presence* of edges can produce a
two-dimensional spectrum, because the randomness never leaves the real-spectrum
matrix $B$. This identifies precisely the algebraic feature one must destroy —
the shared phase — to recover circular-law behavior (see Section 6).

## 4. Global multiplicative invariants

Because $z$ factors out of $A = z\cdot B$ globally, the standard spectral
summaries transform by clean multiplicative rules.

**Proposition 4.1 (Trace).** $\operatorname{tr}(z\cdot B) = z\cdot
\operatorname{tr}(B)$. In particular, if $B$ is loopless ($B_{ii} = 0$ for all
$i$), then $\operatorname{tr}(z\cdot B) = 0$ for every weight $z$.

*Proof.* The trace is linear: $\operatorname{tr}(z\cdot B) = \sum_i (z B)_{ii} =
z\sum_i B_{ii} = z\operatorname{tr}(B)$. If the diagonal vanishes, the sum is $0$.
$\square$

Since $\operatorname{tr}(A)$ is the sum of eigenvalues, Proposition 4.1 says the
eigenvalues along $\mathbb{R}\cdot z$ sum to zero for a loopless graph: they
balance about the origin on the line.

**Proposition 4.2 (Determinant).** $\det(z\cdot B) = z^{\,n}\cdot\det(B)$, where
$n$ is the number of vertices.

*Proof.* Determinant is homogeneous of degree $n$ under scalar multiplication:
scaling an $n\times n$ matrix by $z$ scales its determinant by $z^n$. $\square$

Since $\det(A)$ is the product of eigenvalues, Proposition 4.2 is consistent
with $n$ eigenvalues each carrying a factor of $z$ (each is $z r_k$, and
$\prod_k (z r_k) = z^n \prod_k r_k = z^n\det B$).

**Theorem 4.3 (Singularity is weight-independent).** For every nonzero weight $z
\neq 0$,
$$\det(z\cdot B) = 0 \iff \det(B) = 0.$$
Equivalently, $z\cdot B$ is singular if and only if $B$ is singular; the complex
amplitude cannot create or destroy singularity.

*Proof.* By Proposition 4.2, $\det(z\cdot B) = z^n\det(B)$. As $z \neq 0$ implies
$z^n \neq 0$, the product vanishes iff $\det(B) = 0$. $\square$

Theorem 4.3 reduces a question about complex-weighted matrices — is $A$
invertible? — to a purely combinatorial question about the $0/1$ matrix $B$,
whose threshold behavior for random graphs is classical.

## 5. The complete graph and the mean-direction outlier

We now instantiate the theory on the complete graph and exhibit an explicit
eigenpair that escapes the naive spectral radius.

**Definition 5.1 (Complete-graph indicator).** For $n \ge 1$ let $K_n$ have
indicator matrix $\big(K_n\big)_{ij} = 0$ if $i = j$ and $1$ otherwise: all
off-diagonal entries $1$, zero diagonal.

**Lemma 5.2.** $K_n$ (as a matrix) is Hermitian and loopless, and acts on the
all-ones vector $\mathbf{1} = (1,\dots,1)$ by
$$K_n\,\mathbf{1} \;=\; (n-1)\,\mathbf{1}.$$

*Proof.* Symmetry of the "$i \ne j$" relation gives $\big(K_n\big)_{ij} =
\big(K_n\big)_{ji}$, and real entries give Hermiticity; the diagonal is zero by
definition. For any row $i$, $(K_n \mathbf{1})_i = \sum_{j} \big(K_n\big)_{ij} =
\sum_{j \ne i} 1 = n-1$. $\square$

**Theorem 5.3 (Mean-direction eigenvalue).** For every $n$ and every weight $z$,
the all-ones vector is an eigenvector of $z\cdot K_n$ with eigenvalue $(n-1)z$:
$$(z\cdot K_n)\,\mathbf{1} \;=\; (n-1)z\cdot \mathbf{1}.$$
Moreover $(n-1)z$ lies on the line $\mathbb{R}\cdot z$ (taking $r = n-1$),
consistent with Theorem 3.1.

*Proof.* $(z\cdot K_n)\mathbf{1} = z\,(K_n\mathbf{1}) = z\,(n-1)\mathbf{1} =
(n-1)z\,\mathbf{1}$ by Lemma 5.2. Since $n - 1 \in \mathbb{R}$, the eigenvalue is
$z\cdot(n-1) \in \mathbb{R}\cdot z$. $\square$

The all-ones vector points equally along every coordinate axis; it is the *mean
direction*, and its eigenvalue $(n-1)z$ is the mean-direction mode of the
weighted complete graph. We now show it is an outlier.

**Lemma 5.4 (Elementary inequality).** For every integer $n \ge 3$,
$$\sqrt{n} \;<\; n - 1.$$

*Proof.* For $n \ge 3$ both sides are positive, so the inequality is equivalent
to $n < (n-1)^2 = n^2 - 2n + 1$, i.e. $0 < n^2 - 3n + 1$. The quadratic $t^2 -
3t + 1$ is positive for $t \ge 3$ (its larger root is $(3+\sqrt5)/2 \approx
2.618 < 3$), so $n^2 - 3n + 1 > 0$ for all integers $n \ge 3$. $\square$

**Theorem 5.5 (Outlier escapes the naive radius).** For every order $n \ge 3$
and every nonzero weight $z$, the mean-direction eigenvalue satisfies
$$\big\lvert (n-1)z\big\rvert \;=\; (n-1)\,\lvert z\rvert \;>\;
\sqrt{n}\cdot\lvert z\rvert.$$
Hence the mean-direction eigenvalue is a genuine outlier: it lies strictly
beyond the naive spectral radius $\sqrt{n}\,\lvert z\rvert$ suggested by
unit-strength random-matrix heuristics.

*Proof.* Since $z \neq 0$, $\lvert z\rvert > 0$. By multiplicativity of the
modulus, $\lvert (n-1)z\rvert = (n-1)\lvert z\rvert$. By Lemma 5.4, $\sqrt{n} <
n-1$; multiplying the strict inequality by the positive number $\lvert z\rvert$
gives $\sqrt{n}\,\lvert z\rvert < (n-1)\lvert z\rvert$. $\square$

**Remark 5.6.** The factor $\lvert z\rvert$ cancels from both sides, so the
escape is a property of the graph's *order* $n$, independent of the coloring.
This mirrors the deterministic ($p \to 1$) endpoint of the row-sum heuristic for
random graphs discussed in Section 6: the expected row sum $p(n-1)$ produces the
outlier, while the fluctuation scale $2\sqrt{np(1-p)}$ controls the bulk.

## 6. Applications and interpretation

**Spectral graph theory with complex weights.** Weighted adjacency matrices
underlie diffusion, consensus, and synchronization dynamics on networks. The
fixed-amplitude model is the natural "single-frequency" weighting; line-locking
says such a network has a purely one-dimensional set of spectral modes (up to
the global rotation by $z$), so its dynamical behavior is governed by the real
spectrum of $B$ rotated by the phase of $z$. This gives a clean design rule: to
obtain genuinely complex (rotational) spectral behavior one must introduce
edge-dependent phases.

**A diagnostic for two-dimensional spectra.** Theorem 3.1 provides a sharp
negative result: any model that can be written as a scalar times a Hermitian
matrix cannot exhibit a circular law. This turns model selection into a concrete
check — is the matrix of the form $z\cdot(\text{Hermitian})$? If yes,
two-dimensional spectra are impossible.

**Colorblind singularity for random graphs.** Theorem 4.3 shows that
invertibility of a complex-weighted random graph is decided by the $0/1$
structure alone. For Erdős–Rényi $G(n,p)$ this ties the singularity probability
of $z\cdot B$ to the classical singularity threshold of random $0/1$ symmetric
matrices, independent of $z$.

## 7. Conjectures and future directions

The closed-form obstruction isolated above suggests several sharp, testable
conjectures.

**Conjecture 7.1 (Two-dimensional spectra require broken phase symmetry).** If
the edges carry *independent* complex phases (each present edge $(i,j)$ weighted
by an independent unit-modulus random variable, relaxing $w_{ji} =
\overline{w_{ij}}$ to genuine independence), then the empirical spectral
distribution of the normalized adjacency matrix converges, as $n\to\infty$, to a
rotationally invariant law on a full two-dimensional disk — in sharp contrast to
the line-locked fixed-amplitude model. The scalar–Hermitian factorization $z\cdot
B$ is exactly what pins the spectrum to a line; breaking the shared phase is both
necessary and, conjecturally, sufficient to recover circular-law behavior.

**Conjecture 7.2 (Phase-transition threshold for the mean-direction outlier).**
For the fixed-amplitude Erdős–Rényi model $G(n,p)$ with weight $z$, there is a
sharp threshold $p^{*}(n)$ such that above it the largest-modulus eigenvalue is
asymptotically $p(n-1)\lvert z\rvert$ (the mean-direction outlier), while the
bulk stays within radius $2\sqrt{np(1-p)}\,\lvert z\rvert$; the outlier separates
from the bulk exactly when $p(n-1) > 2\sqrt{np(1-p)}$. The deterministic value
$(n-1)z$ is the $p\to 1$ endpoint of the family of expected row sums $p(n-1)$.

**Conjecture 7.3 (Reality of Rayleigh quotients characterizes line-locking).**
Among all weighting schemes assigning a complex number to each edge of a fixed
graph, the weighted adjacency matrix has its full spectrum confined to a single
complex line through the origin *if and only if* the scheme is a complex scalar
multiple of a Hermitian matrix; equivalently, iff the Rayleigh quotient $\langle
v, A v\rangle$ is a fixed complex multiple of a real number for all $v$. The
forward direction is Theorem 3.1; the converse should follow from the fact that
reality of the Hermitian Rayleigh quotient is exactly what pins each eigenvalue
to the line.

**Conjecture 7.4 (Determinant zeros track combinatorics).** The weighted
determinant $\det(z\cdot B) = z^n\det(B)$ vanishes for fixed nonzero $z$ if and
only if the underlying graph has no perfect matching of a certain signed type;
consequently, for random $G(n,p)$ the probability that the weighted matrix is
singular exhibits the same threshold as the appearance of an isolated vertex,
independent of $z$. The amplitude is a global unit that cannot create or destroy
singularity (Theorem 4.3), so all $z$-dependence factors through $z^n$.

## 8. Conclusion

The fixed-amplitude model occupies a clean and completely solvable corner of the
theory of complex-weighted random graphs. Its defining feature — one shared
complex weight on every edge — forces the algebraic factorization $A = z\cdot B$
with $B$ Hermitian, and from that single fact flow all our results: spectral
line-locking onto $\mathbb{R}\cdot z$, the linear trace law, the $z^n$
determinant law, weight-independent singularity, and the mean-direction outlier
$(n-1)z$ that escapes the naive radius for every $n\ge 3$. Together these
delineate exactly where two-dimensional (circular-law) spectra can and cannot
appear, and they hand the next phase a precise algebraic target — the shared
phase — whose removal is conjectured to restore the full richness of the complex
plane.
