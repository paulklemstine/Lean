# An Euler Product for the Autocorrelation of Simultaneously Visible Lattice Points

## Abstract

A lattice point $v \in \mathbb{Z}^k$ is *visible* from a point $x$ when the segment joining them contains no other lattice point, equivalently when the coordinate vector $v - x$ is primitive: $\gcd(v-x) = 1$. Given a finite set $S \subset \mathbb{Z}^k$ of observers, let $V_S$ be the set of lattice points simultaneously visible from every point of $S$. We study the autocorrelation
$$\gamma_S(z) = \lim_{N \to \infty} \frac{\bigl| V_S \cap (V_S + z) \cap [-N,N]^k \bigr|}{(2N+1)^k},$$
and establish the arithmetic backbone from which its Euler-product evaluation follows. The central structural fact is a **Local–Global Bridge**: primitivity of an integer vector is equivalent to nonvanishing of its reduction modulo every prime. Combined with a complement-count identity for the local factor and the multiplicativity of the primitive-residue density across coprime moduli (Chinese Remainder Theorem), this yields the conjectural evaluation
$$\gamma_S(z) = \prod_{p} \left(1 - \frac{|S_p \cup (S-z)_p|}{p^k}\right),$$
where $S_p$ denotes the image of $S$ in $(\mathbb{Z}/p\mathbb{Z})^k$. Specializing to $S = \{0\}$, $z = 0$ recovers the classical density $1/\zeta(k)$ of visible lattice points. We also isolate a natural but **false** multiplicativity claim about the local factor of a fixed finite set, exhibiting an explicit one-dimensional counterexample, and we identify the correct multiplicative quantity (a Jordan-totient-style primitive-residue density). The Euler-product structure implies that $\gamma_S$ is almost periodic, from which the pure-point nature of the associated diffraction spectrum is expected to follow.

**Keywords:** visible lattice points, primitive vectors, coprimality, Euler product, Chinese Remainder Theorem, Möbius function, Riemann zeta, autocorrelation, pure-point diffraction, Jordan totient.

---

## 1. Introduction

The classical set of *visible lattice points* consists of those $v \in \mathbb{Z}^k$ that can be seen from the origin without obstruction by an intervening lattice point. This happens exactly when $\gcd(v_1, \dots, v_k) = 1$. The density of such points is a textbook consequence of Möbius inversion:
$$\lim_{N \to \infty} \frac{|\{v \in [-N,N]^k : \gcd(v) = 1\}|}{(2N+1)^k} = \frac{1}{\zeta(k)} = \prod_p \left(1 - p^{-k}\right).$$
Visible lattice points have become a model system in the theory of aperiodic order: their autocorrelation and diffraction have been computed, and they furnish a natural example of a structure with pure-point diffraction spectrum despite the appearance of pseudo-randomness induced by the primes.

In this paper we replace the single observer at the origin by an arbitrary finite observer set $S \subset \mathbb{Z}^k$ and study the set $V_S$ of points *simultaneously visible* from all of $S$. This generalization introduces new phenomena — most notably the way distinct observers interact prime by prime — while preserving the multiplicative structure that makes an Euler-product evaluation possible. Our contribution is to lay the local (per-prime) foundations rigorously: we prove that primitivity is a local condition, translate the visibility constraints into complement counts modulo each prime, and clarify precisely which quantity is multiplicative across coprime moduli (correcting a plausible but false claim about the local factor).

Throughout we fix an integer $k \ge 1$; the analytic conclusions (convergence of the Euler product, existence of the density) require $k \ge 2$, where $\sum_p p^{-k} < \infty$.

---

## 2. Definitions

We work with integer vectors $w : \{1, \dots, k\} \to \mathbb{Z}$, written $w \in \mathbb{Z}^k$.

**Definition 2.1 (Vector gcd).** For $w \in \mathbb{Z}^k$, let $\gcd(w)$ denote the (non-negative, normalized) greatest common divisor of the coordinates $w_1, \dots, w_k$. By convention $\gcd(0) = 0$, and $\gcd(w) \ge 0$ for all $w$.

**Definition 2.2 (Primitivity).** A vector $w \in \mathbb{Z}^k$ is *primitive* if $\gcd(w) = 1$. More generally, over any commutative ring $R$, a vector $x \in R^k$ is *primitive* if its coordinates generate the unit ideal, i.e. there exist $a_1, \dots, a_k \in R$ with $\sum_{i} a_i x_i = 1$. Over a field this is equivalent to $x \neq 0$; over $\mathbb{Z}$ it is equivalent to $\gcd(w) = 1$.

**Definition 2.3 (Reduction modulo $p$).** For a positive integer $p$ and $w \in \mathbb{Z}^k$, the reduction $\rho_p(w) \in (\mathbb{Z}/p\mathbb{Z})^k$ is the coordinatewise image $\rho_p(w)_i = w_i \bmod p$. For a finite set $S \subset \mathbb{Z}^k$ we write $S_p = \rho_p(S) \subset (\mathbb{Z}/p\mathbb{Z})^k$ for its image.

**Definition 2.4 (Visibility from a point).** A point $v \in \mathbb{Z}^k$ is *visible* from $x \in \mathbb{Z}^k$ if $v - x$ is primitive, i.e. $\gcd(v - x) = 1$.

**Definition 2.5 (Simultaneously visible set).** For finite $S \subset \mathbb{Z}^k$,
$$V_S = \{ v \in \mathbb{Z}^k : \gcd(v - x) = 1 \text{ for all } x \in S \}.$$

**Definition 2.6 (Autocorrelation).** For $z \in \mathbb{Z}^k$,
$$\gamma_S(z) = \lim_{N \to \infty} \frac{|V_S \cap (V_S + z) \cap [-N,N]^k|}{(2N+1)^k},$$
whenever the limit exists.

**Definition 2.7 (Primitive-residue density).** For a positive integer $n$, let
$$\delta_k(n) = \frac{|\{ x \in (\mathbb{Z}/n\mathbb{Z})^k : x \text{ primitive} \}|}{n^k},$$
the density of primitive residue vectors modulo $n$. (Over $\mathbb{Z}/n\mathbb{Z}$, "primitive" means the coordinates generate the unit ideal; equivalently no prime factor of $n$ divides all coordinates.)

---

## 3. The Local–Global Bridge

The technical heart of the theory is that coprimality of an integer vector is decided independently by each prime.

**Theorem 3.1 (Divisibility of the vector gcd).** For any $d \in \mathbb{Z}$ and $w \in \mathbb{Z}^k$,
$$d \mid \gcd(w) \iff d \mid w_i \text{ for every } i.$$

*Proof sketch.* This is the universal property of the gcd of a finite family: $\gcd(w)$ is, up to units, the generator of the ideal $(w_1, \dots, w_k)$, so an integer divides it iff it divides every generator. $\qquad\blacksquare$

**Theorem 3.2 (Congruence criterion).** For a positive integer $p$ and $v, x \in \mathbb{Z}^k$,
$$\rho_p(v) = \rho_p(x) \iff p \mid \gcd(v - x).$$

*Proof sketch.* Coordinatewise, $\rho_p(v)_i = \rho_p(x)_i$ iff $v_i \equiv x_i \pmod p$ iff $p \mid (v_i - x_i)$. Taking the conjunction over all $i$ and applying Theorem 3.1 with $d = p$ and $w = v - x$ gives the claim. In particular, taking $x = 0$: $\rho_p(w) = 0 \iff p \mid \gcd(w)$. $\qquad\blacksquare$

**Theorem 3.3 (Local–Global Bridge).** For $w \in \mathbb{Z}^k$,
$$\gcd(w) = 1 \iff \rho_p(w) \neq 0 \text{ for every prime } p.$$
Equivalently: $w$ is primitive iff for every prime $p$ at least one coordinate of $w$ is a unit modulo $p$.

*Proof sketch.* ($\Rightarrow$) If $\gcd(w) = 1$ and some prime $p$ had $\rho_p(w) = 0$, then by Theorem 3.2 (with $x = 0$) we would have $p \mid \gcd(w) = 1$, impossible since $p \ge 2$. ($\Leftarrow$) Suppose $\gcd(w) \neq 1$. Since $\gcd(w) \ge 0$, either $\gcd(w) = 0$ (only when $w = 0$, in which case $\rho_p(w) = 0$ for all $p$) or $\gcd(w) \ge 2$. In the latter case pick a prime $p$ dividing $\gcd(w)$; then $p \mid w_i$ for all $i$ by Theorem 3.1, so $\rho_p(w) = 0$. Either way some prime witnesses failure. $\qquad\blacksquare$

Theorem 3.3 is the statement that visibility is a *local* condition: a lattice point is obstructed from a given observer iff some single prime simultaneously divides all coordinate differences. It reduces the infinitary condition "$\gcd = 1$" to a family of independent finite conditions in the residue rings $(\mathbb{Z}/p\mathbb{Z})^k$.

---

## 4. The local factor and the Euler product

We now express membership in $V_S \cap (V_S + z)$ as a family of per-prime constraints.

**Membership as a residue avoidance condition.** By Definition 2.5 and Theorem 3.3, $v \in V_S$ iff for every observer $x \in S$ and every prime $p$ we have $\rho_p(v - x) \neq 0$, i.e. $\rho_p(v) \neq \rho_p(x)$ (Theorem 3.2). Thus
$$v \in V_S \iff \forall p,\ \rho_p(v) \notin S_p.$$
Similarly, $v \in V_S + z$ iff $v - z \in V_S$ iff for all $p$, $\rho_p(v) \notin (S-z)_p$. Combining:
$$v \in V_S \cap (V_S + z) \iff \forall p,\ \rho_p(v) \notin S_p \cup (S - z)_p. \tag{4.1}$$

**The local factor.** For each prime $p$ the *allowed* residues modulo $p$ are those in $(\mathbb{Z}/p\mathbb{Z})^k \setminus (S_p \cup (S-z)_p)$, a fraction
$$f_p(z) = 1 - \frac{|S_p \cup (S-z)_p|}{p^k} \tag{4.2}$$
of all $p^k$ residues. Only finitely many primes are "active": for $p$ larger than the maximal coordinate spread of $S \cup (S - z)$, the reductions of distinct elements are distinct and no cancellation from wrap-around occurs; but crucially, for *all* $p$, formula (4.2) is a well-defined complement count in $[0, 1]$.

**Conjecture 4.1 (Euler product evaluation).** For $k \ge 2$, every finite $S \subset \mathbb{Z}^k$, and every $z \in \mathbb{Z}^k$, the limit $\gamma_S(z)$ exists and
$$\gamma_S(z) = \prod_p f_p(z) = \prod_p \left( 1 - \frac{|S_p \cup (S-z)_p|}{p^k} \right). \tag{4.3}$$

*Rationale.* Condition (4.1) is a conjunction of independent residue constraints, one per prime. By the Chinese Remainder Theorem, constraints at distinct primes combine into product constraints modulo the corresponding coprime moduli, so the density of vectors satisfying all constraints up to a bound $P$ is the finite product $\prod_{p \le P} f_p(z)$. Passing to the limit requires a sieve tail estimate: the error incurred by truncating at $P$ is controlled by $\sum_{p > P} |S_p \cup (S-z)_p| / p^k$, which is summable precisely because $k \ge 2$ makes $\sum_p p^{-k} < \infty$ (the number of active residues $|S_p \cup (S-z)_p|$ is at most $2|S|$). The finite complement-count identity (4.2) is exactly the numerator of the $p$-th Euler factor; only the uniform tail estimate remains to make the derivation complete. $\qquad\blacksquare$ (conditional)

**Corollary 4.2 (Classical specialization).** For $S = \{0\}$ and $z = 0$, we have $S_p \cup (S - z)_p = \{0\}$, so $f_p = 1 - p^{-k}$ and
$$\gamma_{\{0\}}(0) = \prod_p (1 - p^{-k}) = \frac{1}{\zeta(k)}.$$
In particular the density of visible lattice points in the plane ($k = 2$) is $6/\pi^2 \approx 0.6079$. Möbius inversion gives the equivalent form $\gamma_{\{0\}}(0) = \sum_{n \ge 1} \mu(n)/n^k$.

---

## 5. What is (and is not) multiplicative

The Euler product (4.3) is multiplicative across primes. It is tempting to attribute this to multiplicativity of the *local factor of a fixed finite set*. We show this attribution is incorrect and identify the quantity that genuinely multiplies.

**Definition 5.1 (Naive local density).** For a finite $S \subset \mathbb{Z}^k$ and modulus $n$, put
$$L_n(S) = 1 - \frac{|\rho_n(S)|}{n^k},$$
the complement fraction of the image of $S$ modulo $n$.

**Proposition 5.2 (Failure of naive multiplicativity).** The identity $L_{pq}(S) = L_p(S)\, L_q(S)$ for coprime $p, q$ is **false in general**. Explicitly, take $k = 1$, $p = 2$, $q = 3$, and $S = \{0, 1\} \subset \mathbb{Z}$. Then
$$|\rho_2(S)| = |\{0,1\}| = 2, \quad |\rho_3(S)| = |\{0,1\}| = 2, \quad |\rho_6(S)| = |\{0,1\}| = 2,$$
so
$$L_6(S) = 1 - \tfrac{2}{6} = \tfrac{2}{3}, \qquad L_2(S)\, L_3(S) = \bigl(1 - \tfrac{2}{2}\bigr)\bigl(1 - \tfrac{2}{3}\bigr) = 0 \cdot \tfrac{1}{3} = 0,$$
and $\tfrac{2}{3} \neq 0$.

*Proof sketch.* Direct computation as displayed. The underlying reason: the image $\rho_n(S)$ of a *fixed* finite set is not a CRT cylinder set. For a set of the form $A \times B$ under the CRT isomorphism $(\mathbb{Z}/pq\mathbb{Z})^k \cong (\mathbb{Z}/p\mathbb{Z})^k \times (\mathbb{Z}/q\mathbb{Z})^k$, cardinalities multiply; but $\rho_{pq}(S)$ is the *diagonal image* $\{(\rho_p(s), \rho_q(s)) : s \in S\}$, whose size is bounded by $|S|$ rather than by $|\rho_p(S)|\cdot|\rho_q(S)|$. $\qquad\blacksquare$

The correct multiplicative object is the density of *primitive residue vectors* (Definition 2.7), which controls the visible-point density in the shift-free single-observer case and is a higher-dimensional Jordan totient.

**Theorem 5.3 (Multiplicativity of the primitive-residue density).** For coprime positive integers $m, n$,
$$\delta_k(mn) = \delta_k(m)\, \delta_k(n).$$

*Proof sketch.* The Chinese Remainder Theorem gives a ring isomorphism $\mathbb{Z}/mn\mathbb{Z} \cong \mathbb{Z}/m\mathbb{Z} \times \mathbb{Z}/n\mathbb{Z}$, hence a coordinatewise bijection $(\mathbb{Z}/mn\mathbb{Z})^k \cong (\mathbb{Z}/m\mathbb{Z})^k \times (\mathbb{Z}/n\mathbb{Z})^k$. Two facts make primitivity respect this product:

1. *Primitivity transports along ring isomorphisms.* If $e : R \xrightarrow{\sim} S$ is a ring isomorphism and $x \in R^k$, then $x$ is primitive iff $(e(x_i))_i$ is primitive, because $e\bigl(\sum a_i x_i\bigr) = \sum e(a_i) e(x_i)$ carries a unit-ideal certificate $\sum a_i x_i = 1$ to $\sum e(a_i) e(x_i) = 1$ and back via $e^{-1}$.

2. *Primitivity is coordinate-projectionwise over a product ring.* A vector $x \in (R \times T)^k$ is primitive iff both projections are primitive: a certificate $\sum a_i x_i = 1$ in $R \times T$ is equivalent to certificates in each factor, and conversely certificates in each factor assemble into one for the product.

Combining, primitivity modulo $mn$ is equivalent to simultaneous primitivity modulo $m$ and modulo $n$, so the count of primitive vectors factors: $\#\{\text{primitive mod } mn\} = \#\{\text{primitive mod } m\} \cdot \#\{\text{primitive mod } n\}$. Dividing by $(mn)^k = m^k n^k$ yields $\delta_k(mn) = \delta_k(m)\delta_k(n)$. $\qquad\blacksquare$

**Remark 5.4.** At a prime power, $\delta_k(p^e) = 1 - p^{-k}$ independently of $e \ge 1$ (a vector is imprimitive modulo $p^e$ iff $p$ divides all coordinates). Combining with Theorem 5.3 recovers $\delta_k(n) = \prod_{p \mid n} (1 - p^{-k})$ and, in the limit over squarefree $n$, the density $1/\zeta(k)$. Thus the genuine arithmetic engine behind the Euler product is $\delta_k$, not $L_n$.

---

## 6. Algorithms

We describe how to compute the local factors and truncated Euler products numerically.

**Algorithm 6.1 (Local factor at a prime).** Given a finite $S \subset \mathbb{Z}^k$, a shift $z$, and a prime $p$, compute $f_p(z) = 1 - |S_p \cup (S-z)_p| / p^k$ by reducing every element of $S$ and of $S - z$ modulo $p$ coordinatewise, forming the union of the resulting residue tuples, and counting. Complexity $O(|S| \cdot k)$ per prime.

**Algorithm 6.2 (Truncated autocorrelation).** Approximate $\gamma_S(z)$ by $\prod_{p \le P} f_p(z)$. The truncation error is bounded by $1 - \prod_{p \le P}(1 - c\, p^{-k}) \lesssim c \sum_{p > P} p^{-k}$ with $c \le 2|S|$, giving rapid convergence for $k \ge 2$.

**Algorithm 6.3 (Empirical density).** Directly enumerate $V_S \cap (V_S + z)$ inside a box $[-N,N]^k$ by testing $\gcd(v - x) = 1$ for all $x \in S$ and $\gcd(v - z - x) = 1$ for all $x \in S$, and divide the count by $(2N+1)^k$. This provides an independent check of the Euler product.

---

## 7. Applications

**Aperiodic order and diffraction.** The autocorrelation $\gamma_S$ is the central object in the theory of mathematical diffraction: the diffraction measure of $V_S$ is the Fourier transform of $\gamma_S$ (viewed as a measure on $\mathbb{Z}^k$). The Euler-product form (4.3) exhibits $\gamma_S$ as a product of prime-indexed periodic functions of $z$, hence an almost-periodic function. Almost-periodic autocorrelations have pure-point diffraction. Thus $V_S$, despite pseudo-random gaps, models a structure with sharp Bragg peaks — a mathematical crystal.

**Number theory.** The formula unifies and generalizes classical visible-point densities. The single-observer, zero-shift case reproduces $1/\zeta(k)$; nonzero shifts and multiple observers produce a rich family of rational-times-$\zeta$ expressions determined entirely by the finite residue images $S_p$.

**Sampling and coverage.** In dimension $k \ge 2$, $\gamma_S(0)$ measures the density of points visible to an entire sensor array $S$ at once — a coverage statistic for line-of-sight networks on a lattice, monotone decreasing as the array grows.

---

## 8. Discussion

Two conceptual points deserve emphasis. First, the Local–Global Bridge (Theorem 3.3) is what makes the entire program possible: it converts a global divisibility statement into independent local ones, enabling both the CRT-based multiplicativity and a sieve. Second, the distinction between the false naive multiplicativity (Proposition 5.2) and the true primitive-residue multiplicativity (Theorem 5.3) is a genuine subtlety. The image of a fixed finite set is a *diagonal* under CRT, not a *product*, and diagonals do not respect cardinality factorization. Correctly locating multiplicativity in $\delta_k$ rather than in $L_n$ is essential to a sound derivation of (4.3).

The results here are the local, algebraic layer of the theory; the analytic layer — turning finite products into densities — is stated as Conjecture 4.1 and is expected to follow from a standard sieve once the tail estimate is made uniform in $S$.

---

## 9. Future Directions

**Existence and Euler-product value of the autocorrelation.** For every $k \ge 2$, finite $S \subset \mathbb{Z}^k$, and shift $z$, the limit $\gamma_S(z)$ should exist and equal $\prod_p (1 - |S_p \cup (S-z)_p|/p^k)$. The finite complement-count identity is exactly the numerator of the $p$-th Euler factor, and CRT-multiplicativity upgrades a truncated product over primes below a bound into a genuine density via a sieve with an error term that is summable when $k \ge 2$.

**Pure-point diffraction from the Euler product.** The diffraction measure of $V_S$ (the Fourier transform of $z \mapsto \gamma_S(z)$) should be pure point for every finite $S$, with atoms supported on the rational points determined by the moduli appearing in $S$. A convergent Euler product is a multiplicative, hence almost-periodic, function of $z$, and almost-periodic autocorrelations transform to pure-point spectra.

**Observation-set monotonicity and a visibility "capacity".** Enlarging the observation set can only thin the visible set: if $S \subseteq S'$ then $\gamma_{S'}(0) \le \gamma_S(0)$, and the ratio $\gamma_{S'}(0)/\gamma_S(0) = \prod_p (p^k - |S'_p|)/(p^k - |S_p|)$ depends only on the residue images $S_p$. Consequently there is a well-defined "visibility capacity" of $S$, invariant under translation and under any bijection of $\mathbb{Z}^k$ preserving all residue images. The density depends on $S$ only through its finite reductions $S_p$, so two observation sets with identical residue images in every modulus are density-indistinguishable, however different geometrically.

---

## References (classical background)

- The density of visible lattice points and its value $1/\zeta(k)$ is classical (Möbius inversion / Mertens-type sieves).
- The autocorrelation and pure-point diffraction of the visible lattice points appear in the mathematical theory of aperiodic order and diffraction.
