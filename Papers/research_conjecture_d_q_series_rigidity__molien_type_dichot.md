# Molien-Type Rigidity for Finite Group Actions: Orbit Counts, Fixed-Point $q$-Series, and Effective Reconstruction

**Author:** Aristotle

**Date:** 2026-08-19

---

## Abstract

Let $G$ be a finite group acting on a finite set $X$. Two generating functions are naturally attached to this datum: the **fixed-point $q$-series** $\Phi_{G,X}(q) = \sum_{g \in G} q^{|X^g|}$, which records the distribution of group elements by their number of fixed points, and the **orbit-counting generating function** $N_{G,X}(t) = \sum_{n \ge 0} \bigl|\,X^{\times n}/G\,\bigr|\, t^n$, whose coefficients count orbits of the diagonal action on $n$-tuples. We prove that these two objects determine one another, in a sharp and effective form.

Burnside's lemma applied to tuples identifies the $n$-th orbit count with the $n$-th moment of the *normalised* fixed-point distribution $\rho_{G,X}(v) = \#\{g : |X^g| = v\}/|G|$, a probability measure on $\{0, 1, \dots, |X|\}$. This exhibits the pair as a finite moment problem and yields, via Lagrange interpolation: (i) **forward rigidity**, that equal fixed-point $q$-series imply equal orbit counts in every degree; (ii) **converse rigidity**, that equality of the orbit counts in the finitely many degrees $n \le \max(|X|,|Y|)$ already forces equality of the normalised fixed-point distributions; and (iii) a **dichotomy**, that for groups of equal order there is no intermediate behaviour — either the $q$-series coincide or the orbit sequences differ within that finite window.

We then upgrade uniqueness to computation. We prove a **linear reconstruction theorem**: there is a universal rational matrix $C^{(N)}$, the inverse of the moment (Vandermonde) matrix on the nodes $0,1,\dots,N$, depending on nothing but $N = |X|$, such that $\rho_{G,X}(v) = \sum_{n \le N} C^{(N)}_{v,n} N_{G,X}(n)$. We prove a **peeling recursion**, reading the densities off one value at a time from the top down as limits $\rho(m) = \lim_n \bigl(N_n - \sum_{v>m} \rho(v) v^n\bigr)/m^n$, whose top step recovers the kernel proportion $|K|/|G|$ as the leading asymptotic constant of $N_n$. We give an **explicit geometric error bound** $((m-1)/m)^n$ for the peeling estimate, and show that because the densities have denominator dividing $|G|$, rounding $|G|$ times the peeled estimate returns the fibre cardinality $\#\{g : |X^g| = m\}$ *exactly* once $((m-1)/m)^n \cdot 2|G| < 1$ — a condition that always eventually holds. The limit is therefore a terminating algorithm.

Finally we locate both boundaries of the theory exactly. Normalisation is unavoidable: the trivial actions of the groups of order $1$ and $2$ on a two-element set have identical orbit counts and different $q$-series. The coefficient count is unavoidable: the signed weight $(1,-3,3,-1)$ on the nodes $\{0,1,2,3\}$ annihilates the first three power sums. And the invariant can never distinguish groups: the regular actions of $\mathbb{Z}/4$ and $\mathbb{Z}/2 \times \mathbb{Z}/2$ agree in every degree and in $q$-series, yet the groups are non-isomorphic. Conversely, for two actions of one and the same group, the normalisation ambiguity disappears and rigidity upgrades from densities to raw fixed-point multisets.

**Keywords:** Burnside's lemma, Molien series, orbit counting, fixed-point $q$-series, moment problem, Vandermonde matrix, Lagrange interpolation, permutation characters.

---

## 1. Introduction

### 1.1 The two invariants

Throughout, $G$ is a finite group acting on a finite set $X$, and we write
$$X^g = \{x \in X : g \cdot x = x\}, \qquad \operatorname{fix}(g) = |X^g| \in \{0, 1, \dots, |X|\}.$$

**Definition 1.1 (fixed-point $q$-series).** $\displaystyle \Phi_{G,X}(q) \;=\; \sum_{g \in G} q^{\,|X^g|} \in \mathbb{Q}[q].$

Equivalently, $\Phi_{G,X}$ is the generating polynomial of the **fixed-point multiset** $\mathcal{M}_{G,X} = \{\!\{\,|X^g| : g \in G\,\}\!\}$, a multiset of $|G|$ nonnegative integers each at most $|X|$. Its coefficient at $q^v$ is the **fibre cardinality**
$$F_{G,X}(v) \;=\; \#\{g \in G : |X^g| = v\}.$$

**Definition 1.2 (fixed-point density).** $\displaystyle \rho_{G,X}(v) \;=\; \frac{F_{G,X}(v)}{|G|} \in \mathbb{Q}_{\ge 0}.$

**Definition 1.3 (orbit counts and orbit series).** Let $G$ act on the set $X^{\times n}$ of $n$-tuples diagonally, $g \cdot (x_1,\dots,x_n) = (g x_1, \dots, g x_n)$. Put
$$N_{G,X}(n) \;=\; \bigl|\, X^{\times n} / G \,\bigr|, \qquad N_{G,X}(t) \;=\; \sum_{n \ge 0} N_{G,X}(n)\, t^n.$$

By convention $N_{G,X}(0) = 1$: there is exactly one orbit of empty tuples, a fact we also derive below from Burnside's lemma.

The subject of this paper is the exact information-theoretic relationship between $\Phi_{G,X}$ and $N_{G,X}$.

### 1.2 Summary of results

**Theorem A (Burnside for tuples / moment identity).** For every $n \ge 0$,
$$|G| \cdot N_{G,X}(n) \;=\; \sum_{g \in G} |X^g|^{\,n}, \qquad\text{equivalently}\qquad N_{G,X}(n) \;=\; \sum_{v=0}^{|X|} \rho_{G,X}(v)\, v^{\,n}.$$

**Theorem B (Molien-type closed form).** As formal power series,
$$|G| \cdot N_{G,X}(t) \;=\; \sum_{g \in G} \frac{1}{1 - |X^g|\, t},$$
and consequently $\prod_{g \in G}\bigl(1 - |X^g| t\bigr) \cdot |G| \cdot N_{G,X}(t)$ is a polynomial: $N_{G,X}$ is rational with poles among the reciprocals $1/|X^g|$.

**Theorem C (rigidity and dichotomy).** Let $G$ act on $X$ and $H$ on $Y$.
1. *(Forward)* If $\Phi_{G,X} = \Phi_{H,Y}$, then $N_{G,X}(n) = N_{H,Y}(n)$ for all $n$.
2. *(Converse, finite)* If $N_{G,X}(n) = N_{H,Y}(n)$ for all $n \le \max(|X|,|Y|)$, then $\rho_{G,X} = \rho_{H,Y}$ identically.
3. *(Dichotomy)* If in addition $|G| = |H|$, then either $\Phi_{G,X} = \Phi_{H,Y}$, or there is some $n \le \max(|X|,|Y|)$ with $N_{G,X}(n) \ne N_{H,Y}(n)$.

**Theorem D (linear reconstruction).** Let $N = |X|$ and let $M^{(N)}$ be the $(N{+}1)\times(N{+}1)$ rational matrix with $M^{(N)}_{n,j} = j^{\,n}$ for $0 \le n, j \le N$. Then $M^{(N)}$ is invertible; write $C^{(N)} = \bigl(M^{(N)}\bigr)^{-1}$. For every $v \le N$,
$$\rho_{G,X}(v) \;=\; \sum_{n=0}^{N} C^{(N)}_{v,n} \cdot N_{G,X}(n).$$
The matrix $C^{(N)}$ depends only on $N$ — not on $G$, on the action, or on $|G|$.

**Theorem E (peeling recursion).** For $1 \le m \le |X|$,
$$\rho_{G,X}(m) \;=\; \lim_{n \to \infty} \frac{N_{G,X}(n) - \sum_{v = m+1}^{|X|} \rho_{G,X}(v)\, v^{\,n}}{m^{\,n}},$$
and $\rho_{G,X}(0) = 1 - \sum_{v=1}^{|X|} \rho_{G,X}(v)$. The topmost step $m = |X|$ reads
$$\frac{N_{G,X}(n)}{|X|^{\,n}} \;\longrightarrow\; \frac{|K|}{|G|}, \qquad K = \ker\bigl(G \to \operatorname{Sym}(X)\bigr).$$

**Theorem F (quantitative peeling and exact termination).** With $P_m(n)$ the quantity inside the limit of Theorem E,
$$\bigl|P_m(n) - \rho_{G,X}(m)\bigr| \;\le\; \Bigl(\tfrac{m-1}{m}\Bigr)^{\! n},$$
and whenever $n$ satisfies $\bigl(\tfrac{m-1}{m}\bigr)^{n} \cdot 2|G| < 1$ — which happens for some $n$ —
$$F_{G,X}(m) \;=\; \operatorname{round}\bigl(|G| \cdot P_m(n)\bigr)$$
*exactly*.

**Theorem G (sharpness and blind spots).**
1. *(Normalisation necessary)* The trivial actions of the group of order $1$ and the group of order $2$ on a two-element set have identical orbit counts in every degree and identical densities, but $q$-series $q^2$ and $2q^2$ respectively.
2. *(Coefficient count necessary)* The signed weight $w = (1,-3,3,-1)$ on nodes $\{0,1,2,3\}$ satisfies $\sum_v w(v) v^n = 0$ for $n = 0,1,2$ but $\sum_v w(v) v^3 = -6 \ne 0$.
3. *(Group structure invisible)* The regular actions of $\mathbb{Z}/4$ and $\mathbb{Z}/2 \times \mathbb{Z}/2$ on themselves have equal $q$-series and equal orbit counts in every degree, yet the groups are not isomorphic.
4. *(Same-group upgrade)* If $G = H$, then $N_{G,X}(n) = N_{G,Y}(n)$ for all $n \le \max(|X|,|Y|)$ **iff** $\mathcal{M}_{G,X} = \mathcal{M}_{G,Y}$.

### 1.3 Context

The formula of Theorem B is the combinatorial analogue of Molien's series for the invariants of a linear group, with fixed-point counts in place of eigenvalue data; the poles of the rational function encode the "spectrum" of the action. Theorem C is best read as a *moment problem* statement: the fixed-point density is a probability measure on the finite grid $\{0,\dots,|X|\}$, and a measure supported on $k$ known nodes is determined by its first $k$ moments. This is why the proof is interpolation rather than group theory, and it is also why the correct converse invariant is $\rho$ rather than $\Phi$ — the normalisation by $|G|$ in Burnside's lemma destroys exactly one degree of freedom, namely scale.

---

## 2. The algebraic core: finite determinacy of weighted power sums

Everything rests on a single interpolation lemma. We isolate it because it, and not any group theory, is where the content lies.

**Lemma 2.1 (finite determinacy).** Let $S$ be a finite index set of size $k$, let $\mathrm{val} : S \to \mathbb{Q}$ be injective, and let $w : S \to \mathbb{Q}$ satisfy
$$\sum_{i \in S} w(i)\, \mathrm{val}(i)^{\,n} \;=\; 0 \qquad \text{for all } n = 0, 1, \dots, k-1.$$
Then $w(i) = 0$ for every $i \in S$.

*Proof.* Fix $u \in S$ and let
$$L_u(T) \;=\; \prod_{i \in S,\; i \ne u} \frac{T - \mathrm{val}(i)}{\mathrm{val}(u) - \mathrm{val}(i)}$$
be the Lagrange basis polynomial at $u$; it is well-defined by injectivity of $\mathrm{val}$, has $\deg L_u = k - 1$, and satisfies $L_u(\mathrm{val}(u)) = 1$, $L_u(\mathrm{val}(i)) = 0$ for $i \ne u$. Hence
$$w(u) \;=\; \sum_{i \in S} w(i)\, L_u\bigl(\mathrm{val}(i)\bigr).$$
Writing $L_u(T) = \sum_{n=0}^{k-1} c_n T^n$ and exchanging the two finite sums,
$$w(u) \;=\; \sum_{n=0}^{k-1} c_n \sum_{i \in S} w(i)\, \mathrm{val}(i)^{\,n} \;=\; \sum_{n=0}^{k-1} c_n \cdot 0 \;=\; 0. \qquad \blacksquare$$

**Corollary 2.2.** If $w, w' : S \to \mathbb{Q}$ have equal weighted power sums $\sum_i w(i)\mathrm{val}(i)^n = \sum_i w'(i)\mathrm{val}(i)^n$ for all $n < |S|$, then $w = w'$ on $S$. (Apply Lemma 2.1 to $w - w'$.)

**Remark 2.3 (sharpness of the exponent range).** Lemma 2.1 fails if only the exponents $n < k-1$ are assumed to vanish. On the four nodes $\{0,1,2,3\}$ take $w = (1,-3,3,-1)$. Then
$$\textstyle\sum_v w(v) = 0,\quad \sum_v w(v)v = -3+6-3 = 0,\quad \sum_v w(v)v^2 = -3+12-9 = 0,$$
while $\sum_v w(v)v^3 = -3 + 24 - 27 = -6 \ne 0$. In general the alternating binomial vector $\bigl((-1)^j\binom{k-1}{j}\bigr)_{j}$ on $\{0,\dots,k-1\}$ is the $(k{-}1)$-st finite-difference functional and annihilates all polynomials of degree $< k-1$. So the range $n = 0,\dots,k-1$ in Lemma 2.1 cannot be shortened. This is the source of the sharpness statement in Theorem G(2).

---

## 3. Burnside's lemma as a moment identity

**Theorem 3.1 (Theorem A).** For all $n \ge 0$,
$$|G| \cdot N_{G,X}(n) \;=\; \sum_{g \in G} |X^g|^{\,n}.$$

*Proof.* Burnside's lemma for a finite group acting on a finite set $Z$ reads $|G| \cdot |Z/G| = \sum_{g} |Z^g|$. Apply it to $Z = X^{\times n}$ with the diagonal action. A tuple $(x_1,\dots,x_n)$ is fixed by $g$ iff each $x_i$ is, so $\bigl(X^{\times n}\bigr)^g = (X^g)^{\times n}$ and $\bigl|(X^{\times n})^g\bigr| = |X^g|^n$. $\blacksquare$

**Corollary 3.2 (moment form).** Grouping the group elements by their fixed-point count and dividing by $|G|$,
$$N_{G,X}(n) \;=\; \sum_{v=0}^{|X|} \rho_{G,X}(v)\, v^{\,n}. \tag{3.1}$$
Thus $N_{G,X}(n)$ is the $n$-th moment of $\rho_{G,X}$.

**Corollary 3.3 ($\rho$ is a probability distribution).** Taking $n = 0$ in Theorem 3.1 gives $|G| \cdot N_{G,X}(0) = |G|$, so $N_{G,X}(0) = 1$, and (3.1) at $n=0$ reads $\sum_{v=0}^{|X|} \rho_{G,X}(v) = 1$. Since each $\rho_{G,X}(v) \ge 0$, the density is a probability measure supported on the grid $\{0,1,\dots,|X|\}$. In particular every partial sum $\sum_{v < m} \rho_{G,X}(v) \le 1$, a bound used in §6.

**Theorem 3.4 (Theorem B: Molien-type closed form).** In $\mathbb{Q}[[t]]$,
$$|G| \cdot N_{G,X}(t) \;=\; \sum_{g \in G} \frac{1}{1 - |X^g|\, t}.$$

*Proof.* For any scalar $a$, $(1 - at)\sum_{n \ge 0} a^n t^n = 1$, so $\sum_n a^n t^n$ is the inverse of $1 - at$. Now compare coefficients of $t^n$ on both sides: the left gives $|G| N_{G,X}(n)$, the right gives $\sum_g |X^g|^n$, and these agree by Theorem 3.1. $\blacksquare$

**Corollary 3.5 (rationality).** Multiplying through by the Molien denominator,
$$\Bigl(\prod_{g \in G}\bigl(1 - |X^g| t\bigr)\Bigr) \cdot |G| \cdot N_{G,X}(t) \;=\; \sum_{g \in G} \; \prod_{h \ne g} \bigl(1 - |X^h| t\bigr),$$
a polynomial of degree at most $|G| - 1$. So $N_{G,X}$ is a rational function whose poles lie among $\{1/v : v \in \mathcal{M}_{G,X},\, v \ne 0\}$, with multiplicity of the pole $1/v$ equal to $F_{G,X}(v)$ before cancellation.

**Remark 3.6.** Corollary 3.5 already suggests the shape of the reconstruction: *reading off poles and residues of a rational function from finitely many Taylor coefficients*. The peeling recursion of §5 is precisely the residue extraction, ordered by decreasing pole size.

---

## 4. Rigidity: the two directions and the dichotomy

Let $G$ act on $X$ and $H$ on $Y$. Set
$$S \;=\; \{0, 1, \dots, \max(|X|,|Y|)\}, \qquad |S| = \max(|X|,|Y|) + 1,$$
the common node set: every value $|X^g|$ and every value $|Y^h|$ lies in $S$, and both densities vanish outside $S$.

**Theorem 4.1 (forward rigidity).** If $\rho_{G,X} = \rho_{H,Y}$ then $N_{G,X}(n) = N_{H,Y}(n)$ for all $n$. In particular, if $\Phi_{G,X} = \Phi_{H,Y}$ then $N_{G,X} = N_{H,Y}$ as power series.

*Proof.* Immediate from (3.1): the orbit counts are functions of the density alone. For the second statement, note that $\Phi_{G,X} = \Phi_{H,Y}$ implies $\mathcal{M}_{G,X} = \mathcal{M}_{H,Y}$ as multisets, hence $|G| = |H|$ (the multisets have cardinality $|G|$ and $|H|$), hence equal fibre cardinalities and equal densities. No hypothesis on group orders is needed: equality of $q$-series *forces* $|G| = |H|$. $\blacksquare$

**Theorem 4.2 (converse rigidity, finite).** If $N_{G,X}(n) = N_{H,Y}(n)$ for all $n \le \max(|X|,|Y|)$, then $\rho_{G,X}(v) = \rho_{H,Y}(v)$ for every $v \ge 0$.

*Proof.* Both densities are supported in $S$; outside $S$ both vanish and there is nothing to prove. On $S$, the hypothesis together with (3.1) gives
$$\sum_{v \in S} \rho_{G,X}(v)\, v^{\,n} \;=\; \sum_{v \in S} \rho_{H,Y}(v)\, v^{\,n} \qquad \text{for all } n < |S|,$$
since $n \le \max(|X|,|Y|)$ is exactly $n < |S|$. The nodes $v \mapsto v$ are distinct rationals on $S$, so Corollary 2.2 gives $\rho_{G,X} = \rho_{H,Y}$ on $S$. $\blacksquare$

**Theorem 4.3 ($q$-series form of the converse).** If $|G| = |H|$ and $N_{G,X}(n) = N_{H,Y}(n)$ for all $n \le \max(|X|,|Y|)$, then $\Phi_{G,X} = \Phi_{H,Y}$.

*Proof.* Theorem 4.2 gives $\rho_{G,X} = \rho_{H,Y}$; multiplying by the common value $|G| = |H|$ gives equality of fibre cardinalities $F_{G,X} = F_{H,Y}$, i.e. equality of the $q$-series coefficientwise. $\blacksquare$

**Theorem 4.4 (rigidity, iff form).** If $|G| = |H|$ then
$$\Phi_{G,X} = \Phi_{H,Y} \iff N_{G,X}(n) = N_{H,Y}(n) \text{ for all } n.$$

**Theorem 4.5 (dichotomy).** If $|G| = |H|$, then exactly one of the following holds:
1. $\Phi_{G,X} = \Phi_{H,Y}$ (and hence $N_{G,X}(n) = N_{H,Y}(n)$ for every $n$); or
2. there exists $n \le \max(|X|,|Y|)$ with $N_{G,X}(n) \ne N_{H,Y}(n)$.

*Proof.* Either the finitely many orbit counts up to $\max(|X|,|Y|)$ agree, in which case Theorem 4.3 applies, or they do not. $\blacksquare$

There is no intermediate behaviour: two actions of equal-order groups cannot agree on the first $\max(|X|,|Y|) + 1$ orbit counts and then diverge later.

**Theorem 4.6 (graded form).** Let $(X_m)_{m \ge 0}$ be a family of finite $G$-sets and $(Y_m)_{m \ge 0}$ a family of finite $H$-sets, with $|G| = |H|$. Then
$$\bigl(\forall m,\ \Phi_{G,X_m} = \Phi_{H,Y_m}\bigr) \iff \bigl(\forall m,\ \forall n,\ N_{G,X_m}(n) = N_{H,Y_m}(n)\bigr).$$

*Proof.* Apply Theorem 4.4 in each grade. $\blacksquare$

This is the combinatorial shadow of a graded-module statement: for graded families of finite $G$-sets — the discrete analogue of the graded modules appearing in moonshine-type correspondences — the whole $q$-series package and the whole orbit-count package carry the same information, grade by grade.

**Theorem 4.7 (kernel proportion, and detection of triviality).** Let $K = \{g \in G : g \cdot x = x \text{ for all } x\}$ be the kernel of the action, so that $|K| = F_{G,X}(|X|)$ and $\rho_{G,X}(|X|) = |K|/|G|$. Then:
1. $|K| \cdot |X|^n \le |G| \cdot N_{G,X}(n) \le |K| \cdot |X|^n + \bigl(|G| - |K|\bigr)\bigl(|X|-1\bigr)^n$;
2. if two actions have $|X| = |Y|$ and equal orbit counts up to $\max(|X|,|Y|)$, then $|K_G|/|G| = |K_H|/|H|$;
3. $N_{G,X}(n) = |X|^n$ for all $n$ if and only if the action is trivial, and already the single value $n = 1$ decides this.

*Proof.* (1) Split the Burnside sum $\sum_g |X^g|^n$ into the kernel elements, each contributing $|X|^n$, and the rest, each contributing at most $(|X|-1)^n$. (2) is Theorem 4.2 evaluated at $v = |X|$. (3) The "if" direction is immediate. For "only if", take $n = 1$ in the upper bound of (1): $|G| \cdot |X| \le |K| |X| + (|G|-|K|)(|X|-1) = |G||X| - (|G| - |K|)$, forcing $|K| = |G|$. $\blacksquare$

---

## 5. Effective reconstruction I: the universal linear formula

Theorem 4.2 is a uniqueness statement; it does not exhibit the inverse map. We now do so.

**Definition 5.1 (moment matrix).** For $N \ge 0$ let $M^{(N)}$ be the $(N{+}1) \times (N{+}1)$ matrix over $\mathbb{Q}$ with rows indexed by exponents $n$ and columns by nodes $j$:
$$M^{(N)}_{n,j} \;=\; j^{\,n}, \qquad 0 \le n, j \le N.$$

**Lemma 5.2.** $M^{(N)}$ is the transpose of the Vandermonde matrix of the nodes $0, 1, \dots, N$, and $\det M^{(N)} = \prod_{0 \le i < j \le N} (j - i) \ne 0$. Hence $M^{(N)}$ is invertible.

*Proof.* The Vandermonde matrix of the nodes has $(j,n)$ entry $j^n$; transposing swaps the roles. Its determinant is the product of pairwise differences, nonzero because the nodes $0,1,\dots,N$ are pairwise distinct rationals. $\blacksquare$

**Definition 5.3 (reconstruction coefficients).** $C^{(N)} = \bigl(M^{(N)}\bigr)^{-1}$, with entries $C^{(N)}_{v,n}$.

**Lemma 5.4 (inversion of the moment map).** For any weight vector $w = (w_0,\dots,w_N) \in \mathbb{Q}^{N+1}$ and any $v \le N$,
$$w_v \;=\; \sum_{n=0}^{N} C^{(N)}_{v,n} \Bigl( \sum_{j=0}^{N} w_j\, j^{\,n} \Bigr).$$

*Proof.* The inner sum is the $n$-th coordinate of $M^{(N)} w$. Applying $C^{(N)} = (M^{(N)})^{-1}$ recovers $w$. $\blacksquare$

Note that no positivity or normalisation is needed here: Lemma 5.4 inverts the moment map on *all* signed weights supported on the grid.

**Theorem 5.5 (Theorem D: linear reconstruction).** Let $N = |X|$. For every $v \le N$,
$$\rho_{G,X}(v) \;=\; \sum_{n=0}^{N} C^{(N)}_{v,n} \cdot N_{G,X}(n).$$

*Proof.* Apply Lemma 5.4 with $w_j = \rho_{G,X}(j)$; by (3.1) the inner power sum equals $N_{G,X}(n)$. $\blacksquare$

Three features of Theorem 5.5 deserve emphasis.

* **Universality.** The matrix $C^{(N)}$ is a fixed array of rational numbers depending on $N = |X|$ alone. It knows nothing about $G$, nothing about the action, and — perhaps most strikingly — nothing about $|G|$. The same linear functional reconstructs the density of *every* action on a set of size $N$.
* **Finiteness.** Only $N+1$ orbit counts enter, matching the bound in Theorem 4.2 and, by Remark 2.3, unimprovable in general.
* **A second proof of rigidity.** Theorem 5.5 immediately reproves Theorem 4.2 in the equal-cardinality case: if the counts agree in degrees $0,\dots,N$, then the two densities are the *same* linear functional of the *same* inputs, hence equal. It also yields a *separation criterion*: if $\rho_{G,X}(v) \ne \rho_{H,Y}(v)$ for some $v$, then the counts must already differ at some $n \le |X|$, telling a searcher exactly where to look.

**Example 5.6 ($N = 2$).** On the nodes $\{0,1,2\}$,
$$M^{(2)} = \begin{pmatrix} 1&1&1 \\ 0&1&2 \\ 0&1&4 \end{pmatrix}, \qquad C^{(2)} = \begin{pmatrix} 1 & -\tfrac32 & \tfrac12 \\ 0 & 2 & -1 \\ 0 & -\tfrac12 & \tfrac12 \end{pmatrix}.$$
So for any action on a two-element set, $\rho(2) = \tfrac12\bigl(N_2 - N_1\bigr)$, $\rho(1) = 2N_1 - N_2$, $\rho(0) = N_0 - \tfrac32 N_1 + \tfrac12 N_2$. For $\operatorname{Sym}(\{0,1\})$ acting naturally we have $N_0 = 1$, $N_1 = 1$, $N_2 = 2$, giving $\rho = (\tfrac12, 0, \tfrac12)$: one element of the two fixes both points, one fixes neither. Correct, and obtained without ever looking at the group.

**Remark 5.7 (conditioning).** Vandermonde matrices are notoriously ill-conditioned, with condition number growing exponentially in $N$; the entries of $C^{(N)}$ involve alternating signs of large magnitude. Over $\mathbb{Q}$ this is harmless — exact arithmetic gives the exact answer — but in floating point it is fatal for even moderate $N$. This is the practical motivation for the second reconstruction method.

---

## 6. Effective reconstruction II: the peeling recursion

The second method extracts the densities one node at a time, from the top down, and is numerically benign: every step is a positive-combination asymptotic with a geometric error.

**Lemma 6.1 (peeling step, analytic core).** Let $m \ge 1$ and let $w : \{0,1,\dots,m\} \to \mathbb{R}$ be arbitrary. Then
$$\lim_{n \to \infty} \frac{\sum_{v=0}^{m} w(v)\, v^{\,n}}{m^{\,n}} \;=\; w(m).$$

*Proof.* Divide term by term:
$$\frac{\sum_{v \le m} w(v) v^n}{m^n} \;=\; w(m) + \sum_{v < m} w(v)\Bigl(\frac{v}{m}\Bigr)^{\! n}.$$
Each ratio $v/m$ lies in $[0,1)$, so each term of the finite sum tends to $0$. $\blacksquare$

**Definition 6.2 (peeled estimate).** For $1 \le m \le |X|$ and $n \ge 0$,
$$P_m(n) \;=\; \frac{N_{G,X}(n) \;-\; \sum_{v=m+1}^{|X|} \rho_{G,X}(v)\, v^{\,n}}{m^{\,n}}.$$

**Lemma 6.3 (splitting the moment).** For $m \le |X|$ and any $n$,
$$N_{G,X}(n) - \sum_{v=m+1}^{|X|} \rho_{G,X}(v)\, v^{\,n} \;=\; \sum_{v=0}^{m} \rho_{G,X}(v)\, v^{\,n}.$$

*Proof.* Split the grid $\{0,\dots,|X|\}$ in (3.1) as the disjoint union of $\{0,\dots,m\}$ and $\{m+1,\dots,|X|\}$. $\blacksquare$

**Theorem 6.4 (Theorem E: peeling recursion).** For $1 \le m \le |X|$,
$$\rho_{G,X}(m) \;=\; \lim_{n \to \infty} P_m(n),$$
and the remaining value is determined by total mass, $\rho_{G,X}(0) = 1 - \sum_{v=1}^{|X|}\rho_{G,X}(v)$.

*Proof.* Combine Lemma 6.3 with Lemma 6.1 applied to $w = \rho_{G,X}$; the second statement is Corollary 3.3. $\blacksquare$

Run downward — compute $\rho(|X|)$, then $\rho(|X|-1)$ using the value just obtained, and so on to $\rho(1)$, then close with $\rho(0)$ — this is a complete reconstruction algorithm using only the orbit counts as input.

**Corollary 6.5 (top step = kernel asymptotics).** For $|X| \ge 1$, taking $m = |X|$ (where the subtracted sum is empty),
$$\frac{N_{G,X}(n)}{|X|^{\,n}} \;\longrightarrow\; \rho_{G,X}(|X|) \;=\; \frac{|K|}{|G|}.$$

So the exponential growth rate of the orbit count is $|X|$, and its leading constant is the proportion of the group acting trivially. This is the limit form of the two-sided bound in Theorem 4.7(1); the peeling recursion runs the same "largest base dominates" mechanism in every degree, not just the top one.

**Theorem 6.6 (Theorem F, error bound).** Let $1 \le m \le |X|$. Then for every $n$,
$$\bigl|P_m(n) - \rho_{G,X}(m)\bigr| \;\le\; \Bigl(\frac{m-1}{m}\Bigr)^{\! n}.$$

*Proof.* By Lemma 6.3, $P_m(n) - \rho_{G,X}(m) = \sum_{v<m} \rho_{G,X}(v)\,(v/m)^n$, which is nonnegative. Each $v < m$ satisfies $v \le m-1$, so $(v/m)^n \le ((m-1)/m)^n$, whence
$$0 \le P_m(n) - \rho_{G,X}(m) \le \Bigl(\sum_{v<m} \rho_{G,X}(v)\Bigr)\Bigl(\frac{m-1}{m}\Bigr)^{n} \le \Bigl(\frac{m-1}{m}\Bigr)^{n},$$
using Corollary 3.3 for the partial-mass bound $\sum_{v<m}\rho_{G,X}(v) \le 1$. $\blacksquare$

The one-sided form of the bound is worth noting: the peeled estimate always *overshoots*, $P_m(n) \ge \rho_{G,X}(m)$, and decreases towards the truth.

**Theorem 6.7 (Theorem F, exact termination).** Let $1 \le m \le |X|$ and suppose $n$ satisfies
$$\Bigl(\frac{m-1}{m}\Bigr)^{\! n} \cdot 2|G| \;<\; 1. \tag{6.1}$$
Then
$$F_{G,X}(m) \;=\; \#\{g \in G : |X^g| = m\} \;=\; \operatorname{round}\bigl(|G| \cdot P_m(n)\bigr),$$
where $\operatorname{round}$ denotes the nearest integer. Moreover such an $n$ always exists.

*Proof.* Multiply the bound of Theorem 6.6 by $|G|$ and use $|G| \rho_{G,X}(m) = F_{G,X}(m)$:
$$\bigl|\,|G| P_m(n) - F_{G,X}(m)\,\bigr| \;\le\; |G|\Bigl(\frac{m-1}{m}\Bigr)^{n} \;<\; \tfrac12$$
by (6.1). An integer within distance $<\tfrac12$ of a rational is that rational's nearest integer. Existence: $(m-1)/m < 1$, so its powers tend to $0$ and eventually drop below $1/(2|G|)$. $\blacksquare$

**Remark 6.8 (how long is "eventually"?).** Condition (6.1) reads $n \log\frac{m}{m-1} > \log(2|G|)$, i.e. roughly $n > m \log(2|G|)$ for large $m$ (since $\log\frac{m}{m-1} \approx 1/m$). So the number of orbit counts needed by the peeling algorithm is $O(|X| \log |G|)$ — more than the $|X|+1$ of the linear formula, but obtained through numerically stable, positively-weighted steps. For $m = 1$ the error term is $0^n$ and $n = 1$ suffices at once.

**Remark 6.9 (comparison of the two methods).** The linear formula is optimal in the *number of coefficients* ($|X|+1$, provably minimal) but requires exact rational arithmetic against an ill-conditioned matrix. The peeling recursion needs $O(|X|\log|G|)$ coefficients but each step is a subtraction of known positive quantities followed by a division and a rounding, with a certified error bound at every stage. If $|G|$ is known and the orbit counts are available for large $n$, peeling is the method of choice; if only the minimum number of counts is available, the linear formula is the only option.

---

## 7. Sharpness: exactly what is lost

### 7.1 Normalisation cannot be removed

**Theorem 7.1.** Let $E$ be the trivial group and $C_2$ the group of order $2$, both acting trivially on a two-element set $B$. Then
$$N_{E,B}(n) = N_{C_2,B}(n) = 2^n \text{ for all } n, \qquad \rho_{E,B} = \rho_{C_2,B} = \delta_2,$$
but
$$\Phi_{E,B}(q) = q^2 \;\ne\; 2q^2 = \Phi_{C_2,B}(q).$$

*Proof.* Under a trivial action every group element fixes every point, so every fixed-point count equals $2$ and every orbit is a singleton: $N(n) = |B^{\times n}| = 2^n$. The density is the point mass at $2$ in both cases. The $q$-series, being unnormalised, records $|G|$ in its total coefficient sum. $\blacksquare$

Hence the converse direction of Theorem C cannot be strengthened from densities to $q$-series without the hypothesis $|G| = |H|$: the orbit counts are blind to the group order because Burnside's lemma divides by it. Inflating a group by any factor while acting through the same quotient leaves every orbit count unchanged.

### 7.2 The number of coefficients cannot be reduced

By Remark 2.3, on $|S| = k$ nodes there is a nonzero signed weight killing the first $k-1$ power sums. Concretely, on $\{0,1,2,3\}$ the vector $(1,-3,3,-1)$ does this. Consequently the bound "$n \le \max(|X|,|Y|)$" in Theorem 4.2 cannot be lowered to $n \le \max(|X|,|Y|) - 1$ at the level of the underlying linear algebra: the moment map restricted to $k-1$ exponents has a nontrivial kernel.

### 7.3 Group structure is invisible

**Theorem 7.2 (regular actions).** Let $G$ act on itself by left multiplication. Then
$$|G^g| = \begin{cases} |G| & g = 1 \\ 0 & g \ne 1\end{cases}, \qquad \Phi_{G,G}(q) = q^{|G|} + (|G| - 1), \qquad N_{G,G}(n+1) = |G|^{\,n},$$
so that $N_{G,G}(t) = 1 + \dfrac{t}{1 - |G|t}$.

*Proof.* $g \cdot x = x$ means $gx = x$, i.e. $g = 1$; the identity fixes all of $G$. Then Theorem 3.1 gives $|G| \cdot N_{G,G}(n) = |G|^n$ for $n \ge 1$. $\blacksquare$

**Corollary 7.3 (the exact blind spot).** Two regular actions are indistinguishable by both invariants precisely when the two groups have the same order:
$$\Phi_{G,G} = \Phi_{H,H} \iff |G| = |H| \iff \bigl(\forall n,\ N_{G,G}(n) = N_{H,H}(n)\bigr).$$
In particular $\mathbb{Z}/4$ and $\mathbb{Z}/2 \times \mathbb{Z}/2$, acting on themselves, have identical fixed-point $q$-series ($q^4 + 3$) and identical orbit counts in every degree ($1, 1, 4, 16, 64, \dots$), yet are not isomorphic.

So Theorem C is optimal in the strongest sense: it determines the fixed-point distribution, and it can *never* be upgraded to determine the group up to isomorphism. This is a theorem about the invariant's resolution, not a deficiency of the argument.

### 7.4 The same-group upgrade

**Theorem 7.4.** Let one and the same group $G$ act on finite sets $X$ and $Y$. Then
$$\bigl(\forall n \le \max(|X|,|Y|),\ N_{G,X}(n) = N_{G,Y}(n)\bigr) \iff \mathcal{M}_{G,X} = \mathcal{M}_{G,Y} \iff \Phi_{G,X} = \Phi_{G,Y},$$
where $\mathcal{M}$ denotes the fixed-point multiset.

*Proof.* Forward: Theorem 4.2 gives equality of densities, and multiplying by the *common* $|G|$ gives equality of fibre cardinalities, i.e. of multisets. Backward: Theorem 4.1. $\blacksquare$

When the normalising constant is shared, the ambiguity of §7.1 evaporates and rigidity upgrades from probability densities to raw counting data.

---

## 8. Algorithms

We record the two reconstruction procedures explicitly. Inputs are the group order $|G|$, the set size $N = |X|$, and orbit counts $N_0, N_1, N_2, \dots$; outputs are the fibre cardinalities $F(v) = \#\{g : |X^g| = v\}$ for $0 \le v \le N$, equivalently the entire fixed-point $q$-series.

### Algorithm 1: Vandermonde inversion

```
Input:  N, orbit counts N_0,...,N_N (exact rationals/integers), group order |G|
Output: densities rho(0..N) and fibre counts F(0..N)

1. Build M with M[n][j] = j^n for 0 <= n,j <= N.
2. Solve M x = (N_0,...,N_N)^T over Q by exact Gaussian elimination.
3. rho(v) := x[v] for each v.
4. F(v) := |G| * rho(v)   (an integer, by construction).
```
Cost: $O(N^3)$ exact rational operations; equivalently $O(N^2)$ with a Vandermonde-specialised solver. Requires exactly $N+1$ orbit counts — the provable minimum.

### Algorithm 2: Peeling with certified rounding

```
Input:  N, |G|, an oracle for orbit counts N_n at arbitrary n
Output: fibre counts F(0..N)

1. For m = N down to 1:
     a. Choose the least n with ((m-1)/m)^n * 2|G| < 1.   (n = 1 if m = 1)
     b. Compute S := sum over v = m+1..N of rho(v) * v^n     (already-known values)
     c. P := (N_n - S) / m^n
     d. F(m) := round(|G| * P);  rho(m) := F(m)/|G|
2. F(0) := |G| - sum over v = 1..N of F(v)
```
Cost: $O(N)$ oracle calls at exponents $n = O(N\log|G|)$, plus $O(N^2)$ arithmetic on integers of size $O(N^2 \log|G|)$ bits. Each step is certified by the bound of Theorem 6.6 and exact by Theorem 6.7.

Both algorithms are exact — no floating point is required at any stage — and both terminate.

---

## 9. Applications and interpretation

**Inverse Pólya enumeration.** Classical Pólya theory runs forwards: from a group and its action, compute the counting series. Theorems D–F run it backwards. If one observes, empirically, how many inequivalent configurations of length $n$ exist for a sequence of $n$ — necklaces, colourings, isomer classes, lattice configurations modulo a symmetry — one can recover the complete fixed-point statistics of the unseen symmetry group from $|X|+1$ data points, and one can certify the answer exactly.

**Spectral reading of the counting series.** By Corollary 3.5 the orbit-counting series is rational with poles at $1/v$ for each realised fixed-point count $v$, and the residue at $1/v$ is proportional to $F(v)$. Peeling is residue extraction ordered by pole size, and Corollary 6.5 says the dominant pole $1/|X|$ has residue proportional to the kernel size. The "spectrum" of an action, in this Molien sense, is exactly its fixed-point distribution.

**A discrete moment problem with an exact stopping rule.** Moment problems are usually about existence and uniqueness of measures. Here the measure is automatically supported on a known finite grid, so uniqueness is classical; what is unusual is that the measure has *bounded denominator* $|G|$. That arithmetic rigidity is what converts an asymptotic limit into a finite algorithm (Theorem 6.7). The pattern — geometric approximation plus a denominator bound plus rounding — is a general recipe for exactifying limits in arithmetic settings.

**Graded/moonshine shadow.** For graded families of finite $G$-sets, Theorem 4.6 says the whole family of $q$-series and the whole family of orbit counts are interchangeable data. This is the finite-set analogue of comparing graded characters of two module structures over groups of equal order.

**A resolution statement.** Combining §7.1 and §7.3, the map
$$\text{(finite $G$-set)} \;\longmapsto\; \text{(orbit-counting series)}$$
factors exactly through the fixed-point density $\rho$ and nothing finer: it forgets the group order, it forgets the group, it forgets the action, and it remembers the probability measure $\rho$ completely. It is rare to be able to describe the fibres of an enumerative invariant so precisely.

---

## 10. Discussion and future work

The most instructive aspect of this circle of results is the way the naive conjecture fails. One might guess that orbit counts determine the fixed-point *multiset* $\{|X^g|\}$. That is false, and Theorem 7.1 shows it is false for a structural reason: Burnside divides by $|G|$, so the group order is not in the data. Once the right invariant is identified — the probability measure $\rho$ rather than the multiset — the problem stops being group theory and becomes a moment problem on a finite grid, at which point Lagrange interpolation solves it completely and the bounds become sharp.

Several directions remain open.

**Sharpness of the coefficient bound, realised by actions.** Remark 2.3 shows that the *linear-algebraic* bound $k$ is sharp: a signed weight can kill $k-1$ moments. To show the bound is sharp *for group actions* one must realise such a signed vector as the difference of two genuine fixed-point distributions of actions of groups of equal order on sets of size $k$. That is a realisation problem for permutation characters, not a new interpolation problem — the interpolation engine already isolates exactly which weight vectors are invisible.

**Generic separation with far fewer coefficients.** Fixed-point distributions are not arbitrary signed weights: they are probability measures on $\{0,\dots,k\}$, and for transitive actions Burnside forces mean exactly $1$. Two probability measures whose first few moments agree are close in a quantitative sense, which suggests that for all but a vanishing fraction of pairs of faithful transitive actions on sets of size $k$, only $O(\log k)$ coefficients are needed to separate them, even though $k+1$ are needed in the worst case. Making this precise requires a concentration statement for moment vectors of permutation characters.

**Beyond finite sets.** The Molien shape $\sum_g (1-|X^g|t)^{-1}$ suggests replacing fixed-point counts by traces of a linear representation, recovering the classical Molien series. The same interpolation argument then determines the *eigenvalue distribution* of the representation from the dimensions of invariant subspaces of tensor powers — a rigidity statement for representations rather than for permutation actions. The peeling recursion should also survive: complex eigenvalues make the "largest base dominates" step subtler, but on the unit circle the analogous statement is an equidistribution question.

**Stability.** Theorem 6.6 gives an error bound for exactly-known orbit counts. In a statistical setting the counts themselves are estimated. How does the reconstruction degrade under noise? The two algorithms behave very differently: Vandermonde inversion amplifies error exponentially in $N$, while peeling with a positive-mass bound should degrade gracefully. Quantifying this trade-off would make the theory usable on empirical data.

---

## Appendix: worked examples

**A.1 The two-element permutation group on two points.** $G = \operatorname{Sym}(\{0,1\})$, $X = \{0,1\}$. The identity fixes $2$ points, the transposition fixes $0$. So $\Phi(q) = 1 + q^2$, $\rho = (\tfrac12, 0, \tfrac12)$, and $N_n = \tfrac12(2^n + 0^n)$, i.e. $N_0 = 1$, $N_1 = 1$, $N_2 = 2$, $N_3 = 4$, $N_4 = 8$, matching $N(t) = \tfrac12\bigl(1 + (1-2t)^{-1}\bigr)$. Vandermonde inversion on $(1,1,2)$ returns $\rho$ exactly (Example 5.6). Peeling at $m = 2$: $P_2(n) = N_n/2^n = \tfrac12 + \tfrac12 0^n \to \tfrac12$, and $|G| \cdot P_2(1) = 1$ already rounds to the correct fibre count $F(2) = 1$.

**A.2 The symmetric group on three points.** $G = \operatorname{Sym}(\{1,2,3\})$, $|G| = 6$. Fixed-point counts: identity $3$; three transpositions $1$ each; two $3$-cycles $0$ each. So $\Phi(q) = q^3 + 3q + 2$, $\rho = (\tfrac13, \tfrac12, 0, \tfrac16)$, and $N_n = \tfrac16(3^n + 3\cdot 1^n + 2\cdot 0^n)$: $N_0 = 1$, $N_1 = 1$, $N_2 = 2$, $N_3 = 5$, $N_4 = 14$, $N_5 = 41$ — the numbers of set partitions of $\{1,\dots,n\}$ into at most $3$ blocks, as they must be, since orbits of $\operatorname{Sym}(3)$ on $n$-tuples from a $3$-set correspond exactly to such partitions. Reconstruction from $(N_0,\dots,N_3) = (1,1,2,5)$ returns $\rho$ exactly.

**A.3 The blind pair.** $\mathbb{Z}/4$ and $\mathbb{Z}/2\times\mathbb{Z}/2$ acting on themselves: both give $\Phi(q) = q^4 + 3$, both give $N_n$: $1, 1, 4, 16, 64, \dots$. No amount of counting separates them.

**A.4 Normalisation failure.** Trivial group and order-$2$ group acting trivially on $\{0,1\}$: both give $N_n = 2^n$ and $\rho = \delta_2$, but $\Phi = q^2$ versus $2q^2$.
