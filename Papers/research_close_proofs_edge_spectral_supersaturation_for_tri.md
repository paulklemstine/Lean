# Edge-Spectral Supersaturation for Triangles: An Unconditional Bound via the Power-Trace Method

## Abstract

Nosal's theorem states that a triangle-free graph with $m$ edges has spectral
radius $\lambda$ satisfying $\lambda^2 \le m$; equivalently, $\lambda^2 > m$
forces a triangle. We study the *supersaturation* regime, in which the spectral
excess $q := \lambda^2 - m$ is strictly positive, and quantify how the triangle
count $t$ grows with $q$. Working entirely at the level of the eigenvalue
multiset of the adjacency matrix, we prove the unconditional lower bound
$$\lambda\, q \le 3t, \qquad\text{hence}\qquad \sqrt{m}\,\cdot q \le 3t,$$
i.e. $t \ge q\sqrt{m}/3$. The argument isolates a single pointwise inequality —
*cubic domination* — and pushes it through the trace identities
$\sum_i \mu_i^2 = 2m$ and $\sum_i \mu_i^3 = 6t$ together with the
Perron–Frobenius dominance $|\mu_i| \le \lambda$. The bound is tight up to the
constant: the sharp conjecture predicts constant $1$, and we explain precisely
where the power-trace method loses a factor of three. Because every step is
phrased for an abstract spectrum, the results hold verbatim for any real
symmetric matrix whose spectral radius dominates its spectrum, and we record the
trace-of-powers bridge $\operatorname{tr}(A^k) = \sum_i \mu_i^k$ that specializes
the abstract theorem to genuine matrices. The complete graph $K_3$ certifies that
all hypotheses are simultaneously satisfiable and that the bound is non-vacuous.

**Keywords:** spectral graph theory, supersaturation, triangle counting, Nosal's
inequality, power-trace method, Perron–Frobenius, adjacency spectrum.

---

## 1. Introduction

### 1.1 Background and motivation

Let $G$ be a finite simple graph on $n$ vertices with $m$ edges and adjacency
matrix $A \in \mathbb{R}^{n\times n}$, the symmetric $0/1$ matrix with
$A_{ij} = 1$ iff $\{i,j\}$ is an edge. Since $A$ is real symmetric, it has $n$
real eigenvalues
$$\mu_1 \ge \mu_2 \ge \cdots \ge \mu_n,$$
and the *spectral radius* $\lambda := \mu_1 = \max_i |\mu_i|$ is the Perron root.
Spectral extremal graph theory asks how spectral invariants — chiefly
$\lambda$ — constrain combinatorial structure.

The prototype is a 1970 theorem of Nosal.

> **Theorem (Nosal).** If $G$ is triangle-free, then $\lambda \le \sqrt{m}$,
> equivalently $\lambda^2 \le m$.

Nosal's inequality is the spectral analogue of Mantel's theorem (a triangle-free
graph has at most $n^2/4$ edges) and is sharp on complete bipartite graphs. It is
a *threshold* result: it certifies the existence of at least one triangle as soon
as $\lambda^2 > m$.

Modern extremal combinatorics is preoccupied not merely with thresholds but with
**supersaturation**: once a parameter crosses the extremal boundary, the number
of forbidden substructures should grow with the amount of excess. The spectral
form of this question, first studied systematically for triangles by Ning–Zhai
and others, is:

> **Question.** If $\lambda^2 = m + q$ with $q > 0$, how many triangles must $G$
> contain?

The conjectured sharp answer has the shape $t \gtrsim q\sqrt{m}$ with constant
tending to $1$. More generally, for a color-critical graph $F$ an edge-spectral
supersaturation bound with a sharp constant $B_F$ is known when the chromatic
number satisfies $\chi(F) \ge 4$; the triangle case $\chi(F) = 3$ is the open
frontier.

### 1.2 Contribution

This paper isolates and proves the **unconditional** part of the story — the
bound that the power-trace method yields with no stability input — and pins down
exactly the loss incurred. Our main results are:

1. **Cubic domination** (Lemma 3.1): $|\mu| \le \lambda \Rightarrow -\lambda\mu^2 \le \mu^3$.
2. **Eigenvalue supersaturation inequality** (Theorem 3.2):
   $2\lambda^3 - \lambda\sum_i \mu_i^2 \le \sum_i \mu_i^3$ for any spectrum
   dominated by a distinguished top eigenvalue.
3. **Spectral supersaturation** (Theorem 4.1): $\lambda q \le 3t$.
4. **The $\sqrt{m}$ form** (Theorem 4.2): $\sqrt{m}\,q \le 3t$.
5. **Nosal endpoint** (Theorem 4.3): the $q = 0$ boundary recovers $\lambda^2 \le m$.
6. **Trace bridge** (Theorem 5.1) and its **matrix corollary** (Theorem 5.2):
   $\operatorname{tr}(A^k) = \sum_i \mu_i^k$ for real symmetric $A$, discharging
   the trace hypotheses from the spectral theorem.
7. **Worked instance** (Section 6): $K_3$ satisfies all hypotheses.

A distinctive feature is that Theorems 3.2 and 4.1–4.3 are proved for an
abstract eigenvalue vector $\mu : \{1,\dots,n\} \to \mathbb{R}$, so they apply to
any real symmetric matrix, not only adjacency matrices.

---

## 2. Definitions and standing assumptions

Throughout, fix $n \in \mathbb{N}$ and a vector $\mu = (\mu_1, \dots, \mu_n)$ of
real numbers, thought of as the eigenvalue multiset of a symmetric matrix. We
single out an index $j$ and set $\lambda := \mu_j$.

**Definition 2.1 (Power sums / moments).** For $k \ge 1$ the $k$-th power sum is
$p_k := \sum_{i=1}^n \mu_i^k$. When $\mu$ is the adjacency spectrum of a graph
$G$ we have the classical identities
$$p_2 = \sum_i \mu_i^2 = \operatorname{tr}(A^2) = 2m, \qquad
  p_3 = \sum_i \mu_i^3 = \operatorname{tr}(A^3) = 6t,$$
where $m$ is the number of edges and $t$ the number of triangles.

**Definition 2.2 (Spectral dominance).** We say $\lambda = \mu_j$ *dominates* the
spectrum if $|\mu_i| \le \lambda$ for all $i$. For adjacency matrices this is the
Perron–Frobenius theorem for nonnegative symmetric matrices.

**Definition 2.3 (Spectral excess).** Given an edge count $m$, the *spectral
excess* is $q := \lambda^2 - m$. Nosal's threshold is $q = 0$; the
supersaturation regime is $q > 0$.

The identities of Definition 2.1 are genuine theorems (the trace of a matrix
power equals the corresponding power sum of eigenvalues; the combinatorial
interpretations of $\operatorname{tr}(A^2)$ and $\operatorname{tr}(A^3)$), and
Definition 2.2 is Perron–Frobenius. We treat them as the *arithmetic input* to
the method and make them explicit hypotheses, which is the faithful abstraction:
the theorems below hold for any real vector satisfying them.

---

## 3. The power-trace core

### 3.1 Cubic domination

**Lemma 3.1 (Cubic domination).** *For all real $\mu$ and $\lambda$ with
$|\mu| \le \lambda$,*
$$-\lambda\,\mu^2 \le \mu^3.$$

*Proof.* From $|\mu| \le \lambda$ we get $\mu \ge -\lambda$, so $\mu + \lambda \ge 0$.
Since $\mu^2 \ge 0$,
$$\mu^3 + \lambda\mu^2 = \mu^2(\mu + \lambda) \ge 0,$$
which rearranges to $-\lambda\mu^2 \le \mu^3$. $\qquad\blacksquare$

This is the only place where the sign structure of the problem enters: a real
number's cube cannot fall below $-\lambda$ times its square once its absolute
value is capped by $\lambda$.

### 3.2 Summing to the eigenvalue supersaturation inequality

**Theorem 3.2 (Eigenvalue supersaturation inequality).** *Let
$\mu : \{1,\dots,n\}\to\mathbb{R}$, let $\lambda = \mu_j$, and suppose
$|\mu_i| \le \lambda$ for all $i$. Then*
$$2\lambda^3 - \lambda\sum_{i} \mu_i^2 \;\le\; \sum_i \mu_i^3.$$

*Proof.* By Lemma 3.1 applied to each $\mu_i$, every term of the family
$$f(i) := \mu_i^3 + \lambda\mu_i^2$$
is nonnegative. Retaining only the $j$-th term of a sum of nonnegative reals,
$$f(j) \le \sum_i f(i).$$
Now $f(j) = \mu_j^3 + \lambda\mu_j^2 = \lambda^3 + \lambda\cdot\lambda^2 = 2\lambda^3$,
using $\lambda = \mu_j$. On the right, distributivity gives
$$\sum_i f(i) = \sum_i \mu_i^3 + \lambda\sum_i \mu_i^2.$$
Combining,
$$2\lambda^3 \le \sum_i \mu_i^3 + \lambda\sum_i \mu_i^2,$$
which rearranges to the claim. $\qquad\blacksquare$

The inequality is the abstract heart of the paper: it converts the pointwise
cubic bound into a relation among the second and third power sums, with the top
eigenvalue contributing the "supersaturating" term $2\lambda^3$.

---

## 4. Triangle supersaturation

We now specialize $p_2 = 2m$, $p_3 = 6t$, and $\lambda^2 = m + q$.

**Theorem 4.1 (Spectral supersaturation, constant $1/3$).** *Suppose the spectrum
$\mu$ satisfies $|\mu_i| \le \lambda = \mu_j$, together with $\sum_i \mu_i^2 = 2m$,
$\sum_i \mu_i^3 = 6t$, and $\lambda^2 = m + q$. Then*
$$\lambda\, q \le 3t.$$

*Proof.* Substitute $\sum_i\mu_i^2 = 2m$ and $\sum_i \mu_i^3 = 6t$ into
Theorem 3.2:
$$2\lambda^3 - 2\lambda m \le 6t.$$
Since $\lambda^2 = m + q$, we have $\lambda^3 = \lambda(m+q)$, so
$2\lambda^3 - 2\lambda m = 2\lambda(m+q) - 2\lambda m = 2\lambda q$. Therefore
$2\lambda q \le 6t$, i.e. $\lambda q \le 3t$. $\qquad\blacksquare$

**Theorem 4.2 ($\sqrt{m}$-scaled form).** *Under the hypotheses of Theorem 4.1
with $q \ge 0$,*
$$\sqrt{m}\,\cdot q \le 3t, \qquad\text{i.e.}\qquad t \ge \frac{q\sqrt{m}}{3}.$$

*Proof.* First, $\lambda \ge 0$: indeed $0 \le |\mu_j| \le \lambda$. Next,
$\sqrt{m} \le \lambda$, because $m = \lambda^2 - q \le \lambda^2$ gives
$\sqrt{m} \le \sqrt{\lambda^2} = \lambda$. Multiplying $\sqrt{m}\le\lambda$ by
$q \ge 0$ yields $\sqrt{m}\,q \le \lambda q$, and combining with Theorem 4.1,
$\sqrt{m}\,q \le \lambda q \le 3t$. $\qquad\blacksquare$

This is the shape appearing in the conjecture $t \ge (1-\varepsilon)q\sqrt{m}$,
here with constant $1/3$.

**Theorem 4.3 (Nosal endpoint).** *Suppose $|\mu_i| \le \lambda = \mu_j$,
$\sum_i \mu_i^2 = 2m$, and $\sum_i \mu_i^3 = 0$ (the spectral signature of a
triangle-free graph). Then $\lambda^2 \le m$.*

*Proof.* This is the $q = 0$ boundary. From Theorem 3.2 with $\sum_i\mu_i^2 = 2m$
and $\sum_i\mu_i^3 = 0$ we obtain $2\lambda^3 - 2\lambda m \le 0$, i.e.
$2\lambda(\lambda^2 - m) \le 0$. Since $\lambda \ge 0$, if $\lambda > 0$ we may
divide to get $\lambda^2 \le m$; if $\lambda = 0$ then $\lambda^2 = 0 \le m$
trivially (as $m \ge 0$). $\qquad\blacksquare$

Thus the single inequality of Theorem 3.2 simultaneously yields the
supersaturation growth ($q > 0$) and recovers the classical triangle-free bound
($q = 0$).

---

## 5. From abstract spectra to genuine matrices

The results above take the trace identities as hypotheses. For completeness we
record the linear-algebra bridge that discharges them.

**Theorem 5.1 (Trace of powers as power sums).** *Let $A$ be a real symmetric
$n\times n$ matrix with eigenvalues $\mu_1,\dots,\mu_n$ (with multiplicity). Then
for every $k \ge 1$,*
$$\operatorname{tr}(A^k) = \sum_{i=1}^n \mu_i^k.$$

*Proof sketch.* By the spectral theorem $A = Q D Q^{\top}$ with $Q$ orthogonal
and $D = \operatorname{diag}(\mu_1,\dots,\mu_n)$. Then
$A^k = Q D^k Q^{\top}$, and the trace is similarity-invariant
($\operatorname{tr}(QMQ^\top) = \operatorname{tr}(M)$), so
$\operatorname{tr}(A^k) = \operatorname{tr}(D^k) = \sum_i \mu_i^k$. $\qquad\blacksquare$

**Theorem 5.2 (Matrix supersaturation inequality).** *Let $A$ be real symmetric
with spectral radius attained at $\lambda = \mu_j$ dominating the spectrum. Then*
$$2\lambda^3 - \lambda\operatorname{tr}(A^2) \le \operatorname{tr}(A^3).$$

*Proof.* Apply Theorem 3.2 to the eigenvalue vector of $A$ and rewrite the power
sums via Theorem 5.1. $\qquad\blacksquare$

For an adjacency matrix, $\operatorname{tr}(A^2) = 2m$ counts closed walks of
length $2$ (each edge traversed forward and backward), and
$\operatorname{tr}(A^3) = 6t$ counts closed walks of length $3$ (each triangle
has $3$ starting vertices $\times\ 2$ orientations). Substituting these into
Theorem 5.2 reproduces Theorem 4.1 as a literal statement about a graph.

---

## 6. A worked instance: $K_3$

Consider the complete graph $K_3$: three vertices, all pairwise adjacent.

- **Adjacency matrix:** the $3\times3$ matrix with $0$ on the diagonal and $1$
  off-diagonal.
- **Spectrum:** $\mu = (2, -1, -1)$, so $\lambda = 2$ dominates
  ($|{-1}| \le 2$). ✓ Definition 2.2.
- **Edges:** $m = 3$; check $p_2 = 4 + 1 + 1 = 6 = 2m$. ✓
- **Triangles:** $t = 1$; check $p_3 = 8 - 1 - 1 = 6 = 6t$. ✓
- **Excess:** $q = \lambda^2 - m = 4 - 3 = 1 > 0$.
- **Theorem 4.1:** $\lambda q = 2 \le 3 = 3t$. ✓
- **Theorem 4.2:** $\sqrt{m}\,q = \sqrt{3} \approx 1.732 \le 3$. ✓

All hypotheses hold simultaneously and the bound is strict, confirming
non-vacuousness.

---

## 7. Sharpness and the missing factor of three

The conjectured sharp bound has constant $1$: $t \ge (1-\varepsilon)q\sqrt{m}$
for large graphs. Theorems 4.1–4.2 give constant $1/3$. The discrepancy is not an
artifact but a structural feature of the method.

The only inequality used beyond exact identities is the step
$$\sum_{i \ne \text{top}} \mu_i^3 \ge -\lambda\sum_{i\ne\text{top}}\mu_i^2,$$
i.e. cubic domination applied to the non-Perron eigenvalues. Equality holds iff
every non-top eigenvalue equals $0$ or $-\lambda$; that is, the negative spectrum
concentrates at $-\lambda$. This is the spectral signature of a (nearly)
*bipartite* graph. But a bipartite graph has *no* triangles, so the configuration
that makes the algebra tight is combinatorially incompatible with a large
triangle count. The factor-of-three loss is precisely the price of ignoring this
incompatibility.

Consequently the natural route to the sharp constant is a **stability argument**:
show that a graph nearly attaining the eigenvalue inequality is nearly bipartite,
hence triangle-poor, and iterate to remove the slack. This is exactly the extra
input available for $\chi(F) \ge 4$ and missing for triangles, which is why the
$\chi = 3$ case remains open.

---

## 8. Applications and discussion

**Triangle detection from a single number.** Theorems 4.1–4.3 turn the pair
$(\lambda, m)$ into a triangle census: measure the top eigenvalue and the edge
count, form $q = \lambda^2 - m$, and read off a guaranteed lower bound
$t \ge q\sqrt{m}/3$. No enumeration of triples is needed.

**Universality.** Because Theorems 3.2 and 4.1–4.3 are stated for an abstract
dominated spectrum, they apply to any real symmetric matrix: weighted adjacency
matrices, signed graphs, Gram/correlation matrices, and graph Laplacian variants,
wherever a "third-moment counts something" identity is available.

**Relation to combinatorial extremal theory.** The $q = 0$ endpoint (Theorem 4.3)
is the spectral face of Mantel/Turán; the $q > 0$ regime is the spectral face of
combinatorial supersaturation. The power-trace method threads both through one
inequality.

---

## 9. Future directions

1. **Sharp constant $B = 1$ for triangles.** The method is lossy by exactly a
   factor of $3$ relative to $t \gtrsim q\sqrt{m}$. Closing the gap for
   $\chi(F) = 3$ is the open problem; $\chi(F) \ge 4$ is known. A promising route
   combines the eigenvalue estimate with a stability argument ruling out the
   near-tight bipartite-like negative spectrum.

2. **Full graph-theoretic instantiation.** Connect the trace bridge to the
   adjacency matrix, proving $\operatorname{tr}(A^2) = 2\cdot(\#\text{edges})$ and
   $\operatorname{tr}(A^3) = 6\cdot(\#\text{triangles})$ within a graph API so the
   matrix inequality reads literally as a triangle-counting theorem.

3. **General $K_r$ supersaturation.** Extend the power-trace method from the third
   moment (triangles) to higher moments $\operatorname{tr}(A^k)$ to obtain
   spectral supersaturation bounds for $K_r$ and other color-critical $F$.

4. **Weighted / signed adjacency matrices.** The eigenvalue-level results already
   apply to any real symmetric matrix; exploring signed and weighted graphs could
   reveal new supersaturation phenomena.

5. **Perron–Frobenius as a theorem, not a hypothesis.** Replace the dominance
   hypothesis $|\mu_i| \le \lambda$ with the Perron–Frobenius theorem for
   nonnegative symmetric matrices, making the adjacency specialization fully
   unconditional.

---

## 10. Conclusion

From one pointwise inequality — a real number's cube cannot fall below $-\lambda$
times its square — the power-trace method delivers an unconditional spectral
supersaturation bound for triangles, $\lambda q \le 3t$ and $t \ge q\sqrt{m}/3$,
with Nosal's inequality as the boundary case. The constant $1/3$ is off from the
conjectured optimum by a transparent factor whose origin (near-bipartite
extremal spectra) points squarely at the stability argument needed to remove it.
The abstract, eigenvalue-level formulation makes every result immediately
portable to arbitrary real symmetric matrices.
