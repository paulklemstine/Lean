# Tropical Eigenline Collapse and Golden-Ratio Encoding Thresholds: Two Exact Models for Complexity-Driven Emergent Geometry

**Author:** Aristotle
**Date:** 2026-06-20
**Domain:** Tropical (min-plus) algebra; emergent geometry from tensor networks

## Abstract

We present two self-contained, fully formalized models that isolate distinct
facets of the conjecture that classical spacetime geometry emerges from quantum
information complexity in random tensor networks. The first model concerns the
*tropical discrete logarithm problem* (TDLP): the proposal to hide a secret
iteration count $k$ inside repeated application of a min-plus linear map. We show
that this construction is insecure along eigenlines. Concretely, for any
scalar-equivariant tropical map $F$ and any tropical eigenvector $v$ with
eigenvalue $\lambda$, the $k$-fold iterate collapses to a single scalar shift
$F^{[k]}(v) = k\lambda + v$, so that for eigenvalue $\lambda = 1$ the exponent is
recovered coordinatewise by subtraction. The $1\times1$ case is a complete,
elementary instance. The second model studies the Fibonacci anyon chain as a
prototype of a sub-qubit, geometrically encodable quantum system. We prove that
its fusion-path Hilbert-space dimension equals $F_{n+2}$, satisfies a strict area
law $\mathrm{fc}(n) < 2^n$ for $n \ge 2$, is closed under greatest common divisor
(a commensurability law inherited from $\gcd(F_a,F_b)=F_{\gcd(a,b)}$), and is
encodable in a random tensor network of golden-ratio bond dimension precisely
when its length is below the sharp critical value $N_{\text{critical}} = 7$,
where the linearly growing critical bond dimension $D_c(n) = 1 + n/10$ first
exceeds $\varphi$. All statements are theorems verified in a proof assistant; the
present paper gives full statements and proof sketches.

## 1. Introduction

The holographic program in quantum gravity posits that the geometry of a spatial
region is an emergent, coarse-grained description of the entanglement structure
of an underlying quantum state. Random tensor networks make this concrete: a
network of randomly chosen tensors, glued along internal "bonds" of dimension
$D$, defines a quantum error-correcting code whose entanglement pattern induces a
bulk geometry. The governing conjecture in this cycle is that there is a sharp
**critical bond dimension** $D_c(N)$ such that above $D_c$ the emergent geometry
approximates a smooth Lorentzian manifold with bounded curvature, while below it
the geometry is fractal and non-geometric.

Proving the full conjecture is far beyond current reach. Our contribution is to
extract two *exact, gap-free* sub-models that each capture an essential
qualitative feature — (i) the collapse of computational complexity along the
"flat" directions of a tropical (min-plus) dynamical system, and (ii) the
existence of a sharp encoding threshold for a concrete sub-qubit chain — and to
prove them completely. Min-plus algebra is the natural arithmetic of the
coarse-grained "skeleton" geometry of a contracted tensor network (shortest-path
/ optimization structure), which is why both models live in the tropical world.

Throughout we work over the natural numbers $\mathbb{N}$ as the carrier of the
min-plus semiring, deliberately omitting the $+\infty$ element. Tropical scalar
multiplication by $c$ is ordinary addition $x \mapsto c + x$; tropical matrix
iteration is path concatenation under the $(\min,+)$ rule.

## 2. The tropical eigenline collapse

### 2.1 The one-dimensional case

**Definition 1 (one-by-one tropical action).** For $\lambda \in \mathbb{N}$, the
action of the $1\times1$ tropical matrix with entry $\lambda$ on a scalar
$x \in \mathbb{N}$ is min-plus multiplication, i.e. ordinary addition:
$$
\mathrm{oneByOneAction}(\lambda)(x) = \lambda + x.
$$

**Theorem 1 (iterated one-by-one action).** For all
$\lambda, x, k \in \mathbb{N}$,
$$
(\,y \mapsto \lambda + y\,)^{[k]}(x) = k\lambda + x.
$$

*Proof sketch.* Induction on $k$. The base case $k=0$ is $x = 0 + x$. For the
inductive step, $(\lambda+\cdot)^{[k+1]}(x) = \lambda + (\lambda+\cdot)^{[k]}(x)
= \lambda + (k\lambda + x) = (k+1)\lambda + x$ using
$\mathrm{Nat.succ\_mul}$ and commutativity. $\square$

**Theorem 2 (one-by-one recovery).** For all $x, k \in \mathbb{N}$,
$$
(\,y \mapsto 1 + y\,)^{[k]}(x) - x = k.
$$

*Proof sketch.* Specialize Theorem 1 at $\lambda = 1$ to get
$(1+\cdot)^{[k]}(x) = k\cdot 1 + x = k + x$, then subtract $x$. $\square$

This already refutes the security of the TDLP in its simplest nontrivial form:
the secret exponent $k$ is read off from a single input/output pair by one
subtraction. The remainder of this section shows the phenomenon is structural,
not an artifact of dimension one.

### 2.2 The abstract eigenline attack

**Definition 2 (tropical vectors and scalar addition).** For an index type
$\iota$, a *tropical vector* is a function $v \colon \iota \to \mathbb{N}$,
written $\mathrm{Vec}\,\iota$. Tropical scalar addition adds the scalar $c$ to
every coordinate:
$$
(c +_{\mathrm{trop}} v)(i) = c + v(i).
$$

**Definition 3 (scalar-equivariance).** A map
$F \colon \mathrm{Vec}\,\iota \to \mathrm{Vec}\,\iota$ is
*scalar-equivariant* if it commutes with tropical scalar addition:
$$
F(c +_{\mathrm{trop}} v) = c +_{\mathrm{trop}} F(v)
\qquad \text{for all } c \in \mathbb{N},\ v \in \mathrm{Vec}\,\iota.
$$

**Definition 4 (tropical eigenvector).** A vector $v$ is a *tropical
eigenvector* of $F$ with *eigenvalue* $\lambda \in \mathbb{N}$ if
$$
F(v) = \lambda +_{\mathrm{trop}} v.
$$

**Lemma 1 (additivity of scalar addition).** For all $a, b \in \mathbb{N}$ and
$v \in \mathrm{Vec}\,\iota$,
$$
a +_{\mathrm{trop}} (b +_{\mathrm{trop}} v) = (a+b) +_{\mathrm{trop}} v.
$$

*Proof sketch.* Pointwise, $a + (b + v(i)) = (a+b) + v(i)$ by associativity of
addition. $\square$

**Theorem 3 (eigenline attack).** Let
$F \colon \mathrm{Vec}\,\iota \to \mathrm{Vec}\,\iota$ be scalar-equivariant and
let $v$ be a tropical eigenvector with eigenvalue $\lambda$. Then for all
$k \in \mathbb{N}$,
$$
F^{[k]}(v) = (k\lambda) +_{\mathrm{trop}} v.
$$

*Proof sketch.* Induction on $k$. Base case: $F^{[0]}(v) = v = 0 +_{\mathrm{trop}} v$.
Inductive step: using $F^{[k+1]}(v) = F(F^{[k]}(v))$, the inductive hypothesis,
scalar-equivariance (Definition 3), the eigenvector equation (Definition 4), and
Lemma 1,
$$
F^{[k+1]}(v) = F((k\lambda) +_{\mathrm{trop}} v)
= (k\lambda) +_{\mathrm{trop}} F(v)
= (k\lambda) +_{\mathrm{trop}} (\lambda +_{\mathrm{trop}} v)
= ((k+1)\lambda) +_{\mathrm{trop}} v,
$$
using $\mathrm{Nat.succ\_mul}$ and commutativity for the last step. Crucially,
$F$ is never inspected beyond these two structural properties. $\square$

**Theorem 4 (coordinate recovery on an eigenline).** If $F$ is
scalar-equivariant and $v$ is a tropical eigenvector with eigenvalue $1$, then
for every coordinate $i \in \iota$,
$$
F^{[k]}(v)(i) - v(i) = k.
$$

*Proof sketch.* By Theorem 3 with $\lambda = 1$,
$F^{[k]}(v)(i) = (k\cdot 1) + v(i) = k + v(i)$; subtract $v(i)$. $\square$

**Interpretation.** Theorems 3–4 show that any cryptographic hardness one might
hope to extract from iterating a tropical-linear map evaporates along its
eigenlines. In the emergent-geometry analogy, eigenlines are the *flat*
directions of the tropical (min-plus) dynamics; the theorems say complexity does
not accumulate there, so these directions are simultaneously the most
"geometric" and the least secrecy-preserving. This is a precise, provable
instance of the slogan that flat emergent geometry coincides with transparency
of information.

## 3. The Fibonacci anyon chain as a sub-qubit encodable system

### 3.1 Fusion dimension

**Definition 5 (fusion-path count).** The number of admissible fusion paths of a
length-$n$ Fibonacci anyon chain — equivalently, the number of binary strings of
length $n$ with no two consecutive $1$'s — is
$$
\mathrm{fc}(0) = 1,\qquad \mathrm{fc}(1) = 2,\qquad
\mathrm{fc}(n+2) = \mathrm{fc}(n+1) + \mathrm{fc}(n).
$$

**Theorem 5 (Fibonacci identity).** For all $n \in \mathbb{N}$,
$$
\mathrm{fc}(n) = F_{n+2},
$$
where $F_m$ denotes the $m$-th Fibonacci number ($F_1 = F_2 = 1$).

*Proof sketch.* Strong induction. The seeds match: $\mathrm{fc}(0) = 1 = F_2$,
$\mathrm{fc}(1) = 2 = F_3$. For $n+2$, the defining recurrence and the inductive
hypotheses give
$\mathrm{fc}(n+2) = \mathrm{fc}(n+1) + \mathrm{fc}(n) = F_{n+3} + F_{n+2} =
F_{n+4}$, matching the Fibonacci recurrence $\mathrm{Nat.fib\_add\_two}$.
$\square$

### 3.2 Sub-qubit area law

**Theorem 6 (strict area law).** For all $n \in \mathbb{N}$,
$$
\mathrm{fc}(n) \le 2^n,
$$
and for $n \ge 2$ the inequality is strict:
$$
\mathrm{fc}(n) < 2^n.
$$

*Proof sketch.* The non-strict bound is a two-step induction: with
$2^{n+2} = 2\cdot 2^{n+1} = 2^{n+1} + 2^{n+1} \ge 2^{n+1} + 2^n$ and the
recurrence $\mathrm{fc}(n+2) = \mathrm{fc}(n+1) + \mathrm{fc}(n)$, the bound
propagates. For strictness with $n \ge 2$, induct from the base case $n=2$
($\mathrm{fc}(2) = 3 < 4$); the inductive step combines the strict bound at level
$n+2$ with the non-strict bound at level $n+1$ and the gap $2^{n+1} > 2^n$,
yielding $\mathrm{fc}(n+3) = \mathrm{fc}(n+2) + \mathrm{fc}(n+1) < 2^{n+2} +
2^{n+2} = 2^{n+3}$ after the appropriate splitting. $\square$

The strict area law certifies the chain as a genuine *sub-qubit* system: it
occupies strictly less Hilbert-space dimension than $n$ free qubits, leaving the
information gap $2^n - F_{n+2}$. Area laws of this form are the hallmark of states
admitting a clean geometric (tensor-network) description.

### 3.3 Commensurability

**Theorem 7 (commensurability of Fibonacci chains).** For all
$m, n \in \mathbb{N}$ with $\gcd(m+2, n+2) \ge 2$,
$$
\gcd\big(\mathrm{fc}(m),\, \mathrm{fc}(n)\big)
= \mathrm{fc}\big(\gcd(m+2, n+2) - 2\big).
$$

*Proof sketch.* Rewrite both fusion counts via Theorem 5 to get
$\gcd(F_{m+2}, F_{n+2})$. The Fibonacci gcd identity $\mathrm{Nat.fib\_gcd}$,
$\gcd(F_a, F_b) = F_{\gcd(a,b)}$, turns this into $F_{\gcd(m+2,n+2)}$. Writing
$g = \gcd(m+2,n+2)$ and using $g \ge 2$, we have $F_g = F_{(g-2)+2} =
\mathrm{fc}(g-2)$ after $\mathrm{Nat.sub\_add\_cancel}$. $\square$

This expresses that the family of anyon-chain dimensions is closed under gcd: the
common divisor structure of two chains is again realized by a (shorter) chain, a
number-theoretic signature of self-similarity in the emergent geometry.

### 3.4 The golden-ratio encoding threshold

**Definition 6 (critical bond dimension and encodability).** The critical bond
dimension required to encode a length-$n$ chain in a random tensor network grows
linearly with the length:
$$
D_c(n) = 1 + \frac{n}{10} \in \mathbb{R}.
$$
It satisfies $D_c(0) = 1$ and $D_c(n+1) = D_c(n) + \tfrac{1}{10}$. The bond
dimension carried by a single Fibonacci anyon is the golden ratio
$\varphi = \tfrac{1+\sqrt5}{2}$, and a chain is *encodable* when
$$
D_c(n) < \varphi.
$$

**Theorem 8 (sharp critical length).** The critical bond dimension $D_c$ is
strictly monotone increasing, and a length-$n$ chain is encodable if and only if
$n < N_{\text{critical}}$ with $N_{\text{critical}} = 7$.

*Proof sketch.* Strict monotonicity ($\mathrm{critBond\_strictMono}$) follows
since $a < b$ implies $1 + a/10 < 1 + b/10$. For the threshold, encodability
$1 + n/10 < \varphi \approx 1.618$ is equivalent to $n < 10(\varphi - 1) =
5\sqrt5 - 5 \approx 6.18$, i.e. $n \le 6$; the first failing length is $n = 7$,
where $D_c(7) = 1.7 > \varphi$. Concretely $D_c(6) = 1.6 < \varphi < 1.7 =
D_c(7)$. $\square$

This is the exact, finite shadow of the conjectured phase transition: a single
sharp critical parameter $N_{\text{critical}}$ separating the encodable
("geometric") regime $n \le 6$ from the non-encodable regime $n \ge 7$, with the
linearly increasing order parameter $D_c(n)$ crossing the golden-ratio threshold
exactly once.

## 4. Algorithms

We summarize the computational content of the results.

**Algorithm A (eigenline key recovery).** Given black-box access to a
scalar-equivariant tropical map $F$, a known eigenvector $v$ with eigenvalue $1$,
and the output $w = F^{[k]}(v)$ for unknown $k$, return $k = w(i) - v(i)$ for any
coordinate $i$. Correctness is Theorem 4; cost is one subtraction (constant
time), independent of $k$ and of the dimension of $\iota$.

**Algorithm B (fusion dimension and area gap).** Given $n$, compute
$\mathrm{fc}(n)$ by the two-term recurrence in $O(n)$ additions and report the
area-law gap $2^n - \mathrm{fc}(n) = 2^n - F_{n+2}$, certified non-negative by
Theorem 6 (positive for $n \ge 2$).

**Algorithm C (encodability threshold scan).** Given a maximum length $N$, return
the largest encodable length by scanning $D_c(n) = 1 + n/10$ against $\varphi$;
by Theorem 8 the answer is $\min(N, 6)$ and the global critical length is
$N_{\text{critical}} = 7$.

## 5. Applications and discussion

The two models are deliberately complementary. The eigenline collapse is a
*negative* result about complexity: it pinpoints directions in a tropical
dynamical system where iteration carries no information-hiding power, which is
exactly where the coarse geometry is flat. The anyon-chain results are
*positive* and *structural*: an exact dimension formula, a strict area law, a gcd
closure property, and a sharp encoding threshold — all the ingredients one wants
in a clean prototype of a quantum system whose geometry can (or cannot) be
realized by a random tensor network of a given bond dimension.

For quantum-information practice, Algorithm A is a cautionary template: tropical
analogues of discrete-log cryptosystems should avoid scalar-equivariant maps with
known eigenvectors, since the secret iteration count leaks immediately. For
holographic toy models, Theorems 5–8 give a concrete, falsifiable miniature of
the bond-dimension phase transition, with the golden ratio entering not as a
fitting constant but as the intrinsic quantum dimension of the Fibonacci anyon.

## 6. Future directions

The following directions were identified in this cycle and are stated so they can
be attacked formally.

- **Finite-depth stabilization of the emergent metric.** For a weighted digraph
  on $n$ sites with non-negative weights and zero self-loops, the tropical
  contraction sequence $\mathrm{tropPow}$ is eventually constant, stabilizing by
  step $n-1$ at the all-pairs shortest-path matrix. The antitone and bounded-below
  facts already proved reduce this to a Bellman–Ford-style finite-step argument.

- **The threshold as the unique zero of a strictly monotone order parameter.**
  With $\Delta(D) = \mathrm{ricciProxy}(C,N,D) - \kappa$, show $\Delta$ is
  strictly decreasing in $D > 0$ with a unique zero at $D = D_c(N)$, upgrading the
  boundary equality to a genuine single-crossing transition.

- **Curvature bound forces a contraction-diameter bound.** In the supercritical
  phase the emergent contraction diameter is bounded by a universal $\kappa$-controlled
  multiple of the raw weight diameter, with no uniform bound subcritically.

- **Two-sided scaling window for integer bond dimension.** For integer bond
  dimension the smooth phase begins at $\lceil D_c(N)\rceil$ and the relative
  width $(\lceil D_c\rceil - D_c)/D_c \to 0$ as $N \to \infty$, so discrete and
  continuous thresholds coincide asymptotically.

## 7. Conclusion

We have isolated and fully proved two exact tropical models bearing on the
emergence of geometry from complexity: an eigenline collapse showing that
iterated min-plus maps leak their iteration count along flat directions
($F^{[k]}(v) = k\lambda + v$, with coordinatewise recovery when $\lambda = 1$),
and a Fibonacci anyon chain exhibiting a Fibonacci fusion dimension
($\mathrm{fc}(n) = F_{n+2}$), a strict sub-qubit area law, a gcd commensurability
law, and a sharp golden-ratio encoding threshold at $N_{\text{critical}} = 7$.
Each is a small but gap-free stone on the path toward deriving spacetime geometry
from quantum-information complexity.
