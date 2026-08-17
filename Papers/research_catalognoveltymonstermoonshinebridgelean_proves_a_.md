# Moonshine Beyond the $j$-Function: Moments of Trace Series, Bell Numbers, $k$-Transitivity, and the Limits of Aggregation

**Author:** Aristotle

**Date:** 2026-08-17

---

## Abstract

Monstrous moonshine attaches to each element $g$ of a finite group $G$ acting on a graded space a generating function $T_g(q)=\sum_n \operatorname{tr}(g\mid V_n)q^n$, and asserts deep modularity properties of these series. This paper isolates the part of that architecture which is *unconditionally true for every finite group acting on every graded finite set*, and develops it into a complete quantitative theory.

Working with the permutation-character specialization $T_g(q)=\sum_n |X_n^g|\,q^n$, we prove: (i) a **moment hierarchy** identifying $\sum_{g\in G}|X^g|^k$ with $|G|$ times the number of orbits on $k$-tuples, of which Burnside's lemma is the case $k=1$; (ii) **superadditivity** $\#(X/G)^k\le \#(X^k/G)$ together with a **rigidity theorem** stating that equality at $k=2$ characterizes the trivial action; (iii) a universal **Bell floor** $B_k\,|G|\le\sum_{g}|X^g|^k$ for $k\le|X|$, where $B_k$ is the $k$-th Bell number, realized combinatorially as the number of restricted growth functions on $\{1,\dots,k\}$; (iv) a **Bell criterion**: the floor is attained if and only if the action is $k$-transitive, so a single integer moment of the trace family decides a classical permutation-group property; (v) a **fibre spectrum** refinement expressing the *Bell defect* $\sum_g|X^g|^k-B_k|G|$ exactly as $|G|\sum_P(m_P-1)$, where $m_P$ counts the orbits with kernel pattern $P$; (vi) a **moment inversion theorem**: for actions on sets of size at most $N$, the multiset $\{|X^g|:g\in G\}$ is determined by the moments $k\le N$ and by no shorter range, whence the trace distribution and the orbit counts on tuples carry exactly the same information, while an explicit Klein-four example shows the trace distribution is *not* a complete invariant of the action; and (vii) on the analytic side, a complete analysis of the "product over all classes'' slogan: a product of $m$ series normalized to order $-1$ at the cusp has order exactly $-m$ (so a $194$-fold Monster product has a pole of order $194$), the renormalized products $q^m\prod f_i$ realize *precisely* the order-$0$ series, factorizations are never unique, and **no** permutation-invariant aggregate of $m\ge2$ series is injective — while an explicit label-remembering (interleaving) aggregate is. Commutativity, not any accident of examples, is the obstruction to faithful unlabeled aggregation.

**Keywords:** moonshine, permutation character, Burnside's lemma, moment hierarchy, Bell numbers, restricted growth functions, $k$-transitivity, Laurent $q$-series, pole order, aggregation.

---

## 1. Introduction

### 1.1 The moonshine template

Monstrous moonshine begins with a graded module $V=\bigoplus_{n} V_n$ for the Monster simple group $M$ and, for each $g\in M$, the McKay–Thompson series
$$T_g(q)=\sum_{n\ge -1}\operatorname{tr}(g\mid V_n)\,q^{n} = q^{-1}+O(q),$$
whose class $T_1$ is the normalized modular $j$-invariant $J(q)=j(q)-744$. Three features of that construction are logically independent of the modularity miracle:

1. **Element-indexing.** One series per group element, depending only on the conjugacy class.
2. **Averaging.** $\frac{1}{|G|}\sum_{g\in G}T_g$ is a canonical "quotient'' object.
3. **Grading.** Everything happens coefficientwise in a formal $q$-expansion.

Our thesis is that these three features, and a surprising amount of quantitative structure built on them, hold for *every* finite group acting on *every* graded finite set — and that the resulting theory is sharp, with explicit equality cases, explicit defects, and explicit counterexamples marking its boundaries. Conversely, the features of moonshine that are genuinely analytic — modularity, genus-zero properties — do not survive, and we make precise exactly where and why the naive extrapolations break.

### 1.2 The combinatorial specialization

Let $G$ be a finite group acting on a finite set $X$. The most elementary trace available is the permutation character
$$\chi_X(g)=|X^g|=\#\{x\in X: g\cdot x=x\},$$
the character of the linear permutation representation $\mathbb{C}[X]$. If the action is graded — a family $(X_n)_{n\ge0}$ of finite $G$-sets — one obtains a formal *trace series*
$$T_g(q)=\sum_{n\ge0}|X_n^g|\,q^{n}\in\mathbb{Z}[[q]].$$
Since $|X^{hgh^{-1}}| = |X^g|$ (the map $x \mapsto h\cdot x$ is a bijection $X^{g}\to X^{hgh^{-1}}$), each coefficient, and hence each series, is a class function: the family $(T_g)_{g\in G}$ descends to conjugacy-class data exactly as the McKay–Thompson family does.

### 1.3 Results

Section 2 sets up the moment hierarchy and its rigidity. Section 3 develops kernel patterns, Bell numbers and the $k$-transitivity criterion. Section 4 refines this into the fibre spectrum and the exact Bell defect. Section 5 proves that finitely many moments determine the trace distribution and delimits the invariant. Section 6 treats Laurent normalization, the pole-order obstruction, the surjectivity of renormalized products, and the symmetry obstruction to injective aggregation. Section 7 gives algorithms; Section 8 discusses applications and limitations; Section 9 lists open directions.

---

## 2. The moment hierarchy

Throughout, $G$ is a finite group and $X$ a finite $G$-set. Write $X/G$ for the orbit set, $X^k$ for the set of functions $\{1,\dots,k\}\to X$ with the diagonal action $(g\cdot f)(i)=g\cdot f(i)$.

**Lemma 2.1 (Fixed points of the diagonal action).** *For every $g\in G$ and $k\ge 0$, restriction to coordinates gives a bijection $(X^k)^g \cong (X^g)^k$; in particular $|(X^k)^g| = |X^g|^k$.*

*Proof.* A tuple $f$ is fixed by $g$ iff $g\cdot f(i)=f(i)$ for all $i$, i.e. iff every coordinate lies in $X^g$. $\square$

**Theorem 2.2 (Moment hierarchy).** *For every $k\ge 0$,*
$$\sum_{g\in G}|X^g|^{k} \;=\; |G|\cdot \#\bigl(X^{k}/G\bigr).$$

*Proof.* Burnside's orbit-counting lemma applied to the $G$-set $X^k$ gives $\sum_g |(X^k)^g| = |G|\cdot \#(X^k/G)$; substitute Lemma 2.1. $\square$

Special cases: $k=0$ gives $|G|=|G|$; $k=1$ is Burnside's lemma, $\sum_g|X^g|=|G|\cdot|X/G|$; $k=2$ says $\frac{1}{|G|}\sum_g|X^g|^2$ is the **rank** of the permutation action, i.e. the number of orbitals (orbits on ordered pairs). In representation-theoretic language, $\frac1{|G|}\sum_g \chi_X(g)^2 = \langle \chi_X,\chi_X\rangle$ when $\chi_X$ is real-valued, so Theorem 2.2 at $k=2$ is the classical statement that the multiplicity-squared sum of $\mathbb{C}[X]$ equals the orbital count.

**Graded form.** For a graded $G$-set $(X_n)$, Theorem 2.2 holds in each grade, so the coefficientwise $k$-th moment of the trace family is again a generating function of orbit counts:
$$\sum_{g\in G}T_g(q)^{\odot k} := \sum_{n\ge0}\Bigl(\sum_{g\in G}|X_n^g|^k\Bigr)q^n = |G|\sum_{n\ge0}\#\bigl(X_n^k/G\bigr)q^n,$$
where $\odot$ denotes coefficientwise power. At $k=1$ this is the *moonshine average* in the combinatorial setting:
$$\sum_{g\in G}T_g(q)=|G|\cdot O(q),\qquad O(q)=\sum_{n\ge0}|X_n/G|\,q^n.$$

**Proposition 2.3 (Superadditivity).** *For every $k$, $\;\#(X/G)^k\le \#(X^k/G)$.*

*Proof.* Choose one representative per orbit of $X$; distinct $k$-tuples of representatives lie in distinct orbits of $X^k$ because the induced tuple of orbits is a $G$-invariant of a tuple. $\square$

**Theorem 2.4 (Rigidity at $k=2$).** *$\#(X/G)^2=\#(X^2/G)$ if and only if $G$ acts trivially on $X$ (every $g$ fixes every point).*

*Proof sketch.* By Theorem 2.2 the assertion is $\bigl(\frac1{|G|}\sum_g|X^g|\bigr)^2=\frac1{|G|}\sum_g|X^g|^2$, i.e. the Cauchy–Schwarz/variance defect $\sum_g\bigl(|X^g|-\overline{|X^\bullet|}\bigr)^2$ vanishes, i.e. $g\mapsto|X^g|$ is constant. Since $|X^1|=|X|$, constancy forces $|X^g|=|X|$ for all $g$, i.e. $X^g=X$: every element acts as the identity. Conversely a trivial action has $\#(X^k/G)=|X|^k=\#(X/G)^k$. $\square$

A quantitative refinement holds: the Cauchy–Schwarz defect $|G|\sum_g|X^g|^2-\bigl(\sum_g|X^g|\bigr)^2$ bounds, for any *single* element $g_0$, how far $|X^{g_0}|$ can deviate from the mean $|X/G|$; thus a small second-moment defect forces *every* element to be close to acting trivially.

**Proposition 2.5 (Extremes).** *For the left regular action of $G$ on itself, $\#(G^{k+1}/G)=|G|^{k}$. More generally, for any $k\ge1$, the action of $G$ on $X$ is free if and only if $\#(X^k/G)$ attains its maximal possible value, equivalently iff $\sum_g|X^g|^k=|X|^k$.*

Freeness means every non-identity element is fixed-point-free, so the $k$-th moment collapses to the single term $g=1$.

---

## 3. Kernel patterns, Bell numbers, and $k$-transitivity

### 3.1 Patterns

**Definition 3.1 (Pattern).** A *pattern* on $\{1,\dots,k\}$ is a map $p:\{1,\dots,k\}\to\{1,\dots,k\}$ satisfying
$$p(i)\le i \quad\text{and}\quad p(p(i))=p(i)\qquad\text{for all }i.$$
Such maps are precisely the *restricted growth functions*: $p$ selects, for each $i$, the least element of the block containing $i$ in a set partition. Let $\mathrm{Pat}(k)$ denote the (finite) set of patterns.

**Proposition 3.2.** *Patterns on $\{1,\dots,k\}$ are in canonical bijection with set partitions of $\{1,\dots,k\}$; hence $|\mathrm{Pat}(k)|=B_k$, the $k$-th Bell number. The first values are*
$$B_0=1,\;B_1=1,\;B_2=2,\;B_3=5,\;B_4=15,\;B_5=52 \quad (\text{OEIS A000110}).$$

*Proof.* From a partition, define $p(i)=\min(\text{block of }i)$; this satisfies $p(i)\le i$ and $p\circ p=p$. Conversely, the fibres of a pattern $p$ form a partition whose block minima are the fixed points of $p$; the two constructions are mutually inverse. $\square$

We take $|\mathrm{Pat}(k)| = B_k$ as the definition of $B_k$ in what follows; the numerical values above are finite verifications.

### 3.2 The kernel pattern of a tuple

**Definition 3.3 (Kernel pattern).** For $f:\{1,\dots,k\}\to X$ put
$$\ker\mathrm{Pat}(f)(i) = \min\{\,j : f(j)=f(i)\,\}.$$

**Lemma 3.4.** *(a) $f(\ker\mathrm{Pat}(f)(i))=f(i)$ and $\ker\mathrm{Pat}(f)(i)\le i$; (b) $\ker\mathrm{Pat}(f)$ is a pattern; (c) $\ker\mathrm{Pat}(f)(i)=\ker\mathrm{Pat}(f)(j)\iff f(i)=f(j)$, so the kernel pattern is a complete invariant of the coincidence structure of $f$; (d) $f$ injective $\iff \ker\mathrm{Pat}(f)=\mathrm{id}$; (e) $\ker\mathrm{Pat}(g\cdot f)=\ker\mathrm{Pat}(f)$ for every $g\in G$.*

*Proof.* (a) and (b) are immediate from the definition of minimum. (c) If $f(i)=f(j)$ the two defining sets coincide, so the minima agree; conversely if the minima agree then $f(i)=f(\ker\mathrm{Pat}(f)(i))=f(\ker\mathrm{Pat}(f)(j))=f(j)$ by (a). (d) follows from (c). (e) $g$ acts by a bijection of $X$, hence $g\cdot f(j)=g\cdot f(i)\iff f(j)=f(i)$; the defining sets are unchanged. $\square$

By (e), the kernel pattern factors through orbits, giving a well-defined map
$$\pi_k:\;X^k/G\;\longrightarrow\;\mathrm{Pat}(k),\qquad \pi_k([f])=\ker\mathrm{Pat}(f).$$

### 3.3 Surjectivity: extension of injective partial tuples

**Lemma 3.5 (Injective extension).** *Let $|X|\ge k$, let $L\subseteq\{1,\dots,k\}$ and let $f:\{1,\dots,k\}\to X$ be injective on $L$. Then there is a globally injective $u:\{1,\dots,k\}\to X$ with $u|_L=f|_L$.*

*Proof sketch.* Extend one index at a time. Having defined $u$ injectively on a subset $S\supseteq L$ of size $<k$, the image $u(S)$ has fewer than $k\le|X|$ elements, so some unused point of $X$ is available for the next index. $\square$

**Proposition 3.6 (Surjectivity of $\pi_k$).** *If $k\le|X|$, then $\pi_k$ is surjective; consequently $B_k\le \#(X^k/G)$.*

*Proof.* Given a pattern $p$, let $L$ be its set of fixed points (block leaders), $|L|\le k$. By Lemma 3.5 pick an injective $u$ and set $f=u\circ p$. Then $f(i)=f(j)$ iff $p(i)=p(j)$ (as $u$ is injective), so by Lemma 3.4(c) $\ker\mathrm{Pat}(f)=p$ — using $p(i) \le i$ and idempotence to see that block minima match. $\square$

**Corollary 3.7 (Bell floor for moments).** *If $k\le|X|$ then for every finite group $G$ acting on $X$,*
$$B_k\cdot|G|\;\le\;\sum_{g\in G}|X^g|^{k}.$$

*Proof.* Combine Proposition 3.6 with Theorem 2.2. $\square$

### 3.4 Injectivity: the $k$-transitivity criterion

**Definition 3.8.** The action is *$k$-transitive* if for all injective $f,f':\{1,\dots,k\}\to X$ there exists $g\in G$ with $g\cdot f=f'$.

**Theorem 3.9 (Same pattern $\Rightarrow$ same orbit, for $k$-transitive actions).** *Let $k\le|X|$ and suppose the action is $k$-transitive. If $\ker\mathrm{Pat}(f)=\ker\mathrm{Pat}(f')$ then $f$ and $f'$ lie in the same $G$-orbit.*

*Proof.* Let $L$ be the common set of block leaders, i.e. the fixed points of the shared pattern $p$. By Lemma 3.4(c), both $f$ and $f'$ are injective on $L$. By Lemma 3.5 extend to globally injective $u\supseteq f|_L$ and $u'\supseteq f'|_L$. By $k$-transitivity there is $g$ with $g\cdot u=u'$. For each $i$, $f(i)=f(p(i))=u(p(i))$ and $f'(i)=f'(p(i))=u'(p(i))$ since $p(i)\in L$; hence $g\cdot f(i)=g\cdot u(p(i))=u'(p(i))=f'(i)$. $\square$

**Theorem 3.10 (Bell criterion).** *Let $G$ act on a finite set $X$ with $k\le|X|$. The following are equivalent:*

1. *the action is $k$-transitive;*
2. *$\pi_k$ is injective (hence bijective);*
3. *$\#(X^k/G)=B_k$;*
4. *$\displaystyle\sum_{g\in G}|X^g|^{k}=B_k\cdot|G|$.*

*Proof.* (1)$\Rightarrow$(2) is Theorem 3.9. (2)$\Rightarrow$(1): injective tuples all have kernel pattern $\mathrm{id}$ (Lemma 3.4(d)); if $\pi_k$ is injective they form a single orbit, which is $k$-transitivity. (2)$\Leftrightarrow$(3): $\pi_k$ is a surjection between finite sets by Proposition 3.6, so it is injective iff the domain and codomain have equal cardinality, and $|\mathrm{Pat}(k)|=B_k$. (3)$\Leftrightarrow$(4) is Theorem 2.2. $\square$

**Corollary 3.11 (Low $k$).** With $|X|$ large enough: $\sum_g|X^g|=|G|$ iff the action is transitive; $\sum_g|X^g|^2=2|G|$ iff $2$-transitive; $\sum_g|X^g|^3=5|G|$ iff $3$-transitive; and in general the $k$-th moment equals $B_k|G|$ iff $k$-transitive.

**Corollary 3.12 (Symmetric groups).** *$S_n$ acting on $n$ points is $k$-transitive for every $k\le n$, hence*
$$\sum_{\sigma\in S_n}|\mathrm{fix}(\sigma)|^{k}=B_k\cdot n!\qquad(k\le n),$$
*the classical statement that the number of fixed points of a uniformly random permutation has all moments below $n$ equal to those of a Poisson$(1)$ variable (whose $k$-th moment is $B_k$, Dobiński's formula).*

**Proposition 3.13 (Monotone hierarchy).** *If $k+1\le|X|$ and the action is $(k+1)$-transitive then it is $k$-transitive. Hence if the $(k+1)$-st moment attains its Bell floor, so does every lower moment.*

*Proof.* Extend two injective $k$-tuples to injective $(k+1)$-tuples (possible since $k+1\le|X|$), apply $(k+1)$-transitivity, and restrict. $\square$

**Graded form.** If every grade $X_n$ of a graded $G$-set is $k$-transitive, then the coefficientwise $k$-th moment of the trace family is the *constant* series
$$\sum_{g\in G}T_g(q)^{\odot k}=B_k|G|\cdot\frac{1}{1-q} \quad\text{(coefficientwise: } B_k|G| \text{ in every grade).}$$
Conversely the identity in a single grade $n$ with $k\le|X_n|$ forces $k$-transitivity in that grade.

---

## 4. The fibre spectrum and the exact Bell defect

Theorem 3.10 is an equality/inequality dichotomy. The refinement below quantifies the failure.

**Definition 4.1 (Pattern multiplicity).** For a pattern $P\in\mathrm{Pat}(k)$ set
$$m_P \;=\; \#\pi_k^{-1}(P) \;=\; \#\{\text{orbits of }k\text{-tuples with kernel pattern }P\}.$$

**Proposition 4.2 (Fibre decomposition).** $\displaystyle\sum_{P\in\mathrm{Pat}(k)}m_P=\#(X^k/G)$, *and if $k\le|X|$ then $m_P\ge1$ for every $P$.*

*Proof.* The first statement is the fibrewise count of the map $\pi_k$; the second is Proposition 3.6. $\square$

**Theorem 4.3 (Fibrewise transitivity criterion).** *If $k\le |X|$, the action is $k$-transitive if and only if $m_P=1$ for every pattern $P$.*

*Proof.* By Theorem 3.10 $k$-transitivity is equivalent to injectivity of $\pi_k$; a surjection is injective iff all its fibres are singletons. $\square$

**Theorem 4.4 (Exact Bell defect).** *Let $k\le|X|$. Then*
$$D_k \;:=\; \sum_{g\in G}|X^g|^{k}-B_k\,|G| \;=\; |G|\sum_{P\in\mathrm{Pat}(k)}\bigl(m_P-1\bigr).$$
*In particular $D_k\ge0$, with $D_k=0$ exactly when the action is $k$-transitive.*

*Proof.* By Theorem 2.2 and Proposition 4.2, $\sum_g|X^g|^k=|G|\sum_P m_P$. Writing $m_P=1+(m_P-1)$, valid since $m_P\ge1$, and summing over the $B_k$ patterns gives $\sum_P m_P=B_k+\sum_P(m_P-1)$. $\square$

Thus the Bell defect is not an error term but a *census*: it records, pattern by pattern, how many extra orbits the action fails to merge. For example, for the cyclic group $C_n$ acting on $n$ points and $k=2$, the pattern with two equal coordinates contributes $m=1$ (a single orbit of diagonal pairs) while the pattern with distinct coordinates splits into $n-1$ orbits (indexed by the difference), so $D_2 = n\cdot(n-2)$ for $n\ge2$ — visibly the failure of $C_n$ to be $2$-transitive for $n>2$.

---

## 5. Moments determine the trace distribution — and what they do not determine

### 5.1 Power-sum inversion

**Definition 5.1.** The *value multiset* of $a:I\to\mathbb{N}$ on a finite index set $I$ is the multiset $\{\!\{a(i):i\in I\}\!\}$.

**Theorem 5.2 (Moment inversion).** *Let $a:I\to\mathbb{N}$ and $b:J\to\mathbb{N}$ be functions on finite sets with $a(i)\le N$ and $b(j)\le N$ for all $i,j$. If*
$$\sum_{i\in I}a(i)^k=\sum_{j\in J}b(j)^k \qquad \text{for all }0\le k\le N,$$
*then $a$ and $b$ have the same value multiset. Conversely equal value multisets give equal power sums for every $k$.*

*Proof.* Let $c_v=\#\{i: a(i)=v\}$ and $d_v=\#\{j: b(j)=v\}$ for $0\le v\le N$; all values lie in this range. Partitioning the index set by value gives, for each $k$,
$$\sum_i a(i)^k=\sum_{v=0}^{N}c_v\,v^{k},\qquad \sum_j b(j)^k=\sum_{v=0}^N d_v\,v^k .$$
Over $\mathbb{Q}$, this is the linear system $M c = M d$ with $M=(v^{k})_{0\le k,v\le N}$, the transpose of the Vandermonde matrix with the $N+1$ distinct nodes $0,1,\dots,N$. Its determinant $\prod_{u<v}(v-u)\ne0$, so $M$ is invertible and $c=d$. $\square$

**Theorem 5.3 (Sharpness).** *The range $k\le N$ cannot be shortened in general: the functions $a=(0,2)$ and $b=(1,1)$ on a two-element index set are bounded by $N=2$ and satisfy $\sum a(i)^k=\sum b(i)^k$ for $k\le1$, yet have different value multisets.*

Indeed $0+2=1+1$ and both have two entries, but $\{\!\{0,2\}\!\}\ne\{\!\{1,1\}\!\}$; the second moments $0+4=4$ and $1+1=2$ differ, exactly at the top of the range.

### 5.2 The moonshine statement

**Definition 5.4.** The *trace distribution* of a finite $G$-action on $X$ is the multiset $\mathcal{T}(G,X)=\{\!\{|X^g| : g\in G\}\!\}$. In the graded setting, $\mathcal{T}(G,X_n)$ is the distribution over $G$ of the $n$-th coefficient of the trace series family.

**Theorem 5.5 (Trace distribution $\leftrightarrow$ orbit counts).** *Let $G$ be finite and let $X,Y$ be finite $G$-sets with $|X|,|Y|\le N$. Then*
$$\mathcal{T}(G,X)=\mathcal{T}(G,Y)\iff \#(X^k/G)=\#(Y^k/G)\ \text{for all }k\le N \iff \#(X^k/G)=\#(Y^k/G)\ \text{for all }k .$$

*Proof.* Fixed-point counts are bounded by $|X|\le N$ resp. $|Y|\le N$. By Theorem 2.2, $\#(X^k/G)=\frac1{|G|}\sum_g|X^g|^k$, so equality of orbit counts for $k\le N$ is equality of the first $N+1$ power sums of the two fixed-point functions; apply Theorem 5.2 for the forward direction and its converse half for the backward. Since equal distributions give equal power sums for *all* $k$, the finite range propagates to the infinite one. $\square$

**Corollary 5.6 (Invariants of the trace distribution).** *If $\mathcal{T}(G,X)=\mathcal{T}(G,Y)$, then for every $v$ the number of group elements with exactly $v$ fixed points agrees for $X$ and $Y$; in particular the number of fixed-point-free elements agrees. Moreover $|X/G|=|Y/G|$, and (combining with Theorem 3.10) for every $k$ with $k\le|X|$ and $k\le|Y|$, $X$ is $k$-transitive iff $Y$ is: the entire $k$-transitivity spectrum is an invariant of the trace distribution.*

**Graded corollary.** If two graded finite $G$-sets have, at each grade $n$, the same orbit counts on $k$-tuples for $k\le N_n$ (a bound for both grades), then at each grade their trace coefficients have the same distribution over $G$; consequently all their moment series $n\mapsto\sum_g|X_n^g|^k$ coincide, for every $k$. The family of trace series is determined up to relabelling of the group elements.

### 5.3 The limits of the invariant

Completeness for *distributions* does not mean completeness for *actions*.

**Theorem 5.7 (Trace distribution is not a complete invariant).** *Let $V=S_2\times S_2$ be the Klein four-group, and let $X$ be a two-point set acted on through the first factor and $Y$ a two-point set acted on through the second. Then*
$$\mathcal{T}(V,X)=\mathcal{T}(V,Y),\qquad \#(X^k/V)=\#(Y^k/V)\ \text{for all }k,$$
*yet $X$ and $Y$ are not isomorphic as $V$-sets.*

*Proof.* The factor-swap $\sigma:(g_1,g_2)\mapsto(g_2,g_1)$ is a bijection of $V$ with $|X^{g}|=|Y^{\sigma(g)}|$, so the two fixed-point functions have the same value multiset; Theorem 5.5 gives the orbit-count equality. But an equivariant bijection $e:X\to Y$ would have to satisfy $e(g\cdot x)=g\cdot e(x)$, which fails for $g=(\text{swap},1)$: this element moves both points of $X$ and fixes both points of $Y$, so $e(g\cdot x)\ne e(x)=g\cdot e(x)$. $\square$

The two actions differ in their kernels, and the kernel is invisible to the whole moment tower. This is the structural counterweight to moonshine mysticism: trace data, however complete as distributional data, has a definite blind spot.

---

## 6. Laurent normalization, pole orders, and aggregation

### 6.1 Normalized series

Model $q$-expansions as Laurent-type series with integer coefficients and integer exponents, i.e. formal series $F=\sum_{n\in\mathbb{Z}}c_n q^n$ with well-ordered support. Let $\operatorname{ord}(F)$ denote the least exponent with $c_n\ne0$ (with $\operatorname{ord}(0)=+\infty$).

**Definition 6.1.** $F$ is *McKay–Thompson normalized* if $\operatorname{ord}(F)=-1$, i.e. $F=q^{-1}+O(1)$ up to a nonzero leading coefficient.

Normalized series are abundant: $q^{-1}+c$ is normalized for every constant $c$, and $a\,q^{-1}$ is normalized for every $a\ne0$. In the combinatorial setting one obtains genuinely normalized trace series by setting
$$\widehat T_g(q)=q^{-1}+\sum_{n\ge0}|X_n^g|\,q^n,\qquad \widehat O(q)=q^{-1}+\sum_{n\ge0}|X_n/G|\,q^n,$$
which reproduces the $q^{-1}+O(q)$ shape of the classical McKay–Thompson series and preserves the average identity in the modified form
$$\sum_{g\in G}\widehat T_g(q)=|G|\cdot \widehat O(q) \quad\text{after normalizing the polar term by } |G| .$$

### 6.2 The pole-order obstruction

**Lemma 6.2 (Additivity of order).** *For a finite family $(f_i)_{i\in S}$ of nonzero series, $\operatorname{ord}\bigl(\prod_{i\in S}f_i\bigr)=\sum_{i\in S}\operatorname{ord}(f_i)$.*

**Theorem 6.3 (Pole order of a product).** *If $f_1,\dots,f_m$ are all normalized, then $\operatorname{ord}\bigl(\prod_i f_i\bigr)=-m$. In particular, for $m\ge1$ the product is never holomorphic at the cusp, and for $m=194$ — the number of conjugacy classes of the Monster — the product has a pole of order exactly $194$.*

This is the precise reason why "the product of all McKay–Thompson series is a holomorphic modular form of weight $|M|/24$'' cannot be taken at face value: the normalization of the factors dictates the pole order of the product, independently of any modularity considerations. (Even setting the pole aside, McKay–Thompson series are modular *functions* of weight $0$ for various genus-zero groups with Atkin–Lehner extensions; products of weight-$0$ objects have weight $0$, and a product over distinct invariance groups is invariant only for their intersection.)

**Theorem 6.4 (Renormalization).** *$\operatorname{ord}\bigl(q^{m}\prod_{i=1}^m f_i\bigr)=0$ for normalized $f_1,\dots,f_m$.*

### 6.3 The pole is the only obstruction

**Theorem 6.5 (Surjectivity of renormalized products).** *Let $m\ge1$ and let $F$ be any Laurent series with $\operatorname{ord}(F)=0$. Then there exist normalized $f_1,\dots,f_m$ with*
$$q^{m}\prod_{i=1}^{m}f_i=F .$$
*Consequently, for each fixed $m\ge1$, the image of the renormalized-product map is exactly the set of series of order $0$.*

*Proof.* Put $f_1=q^{-1}F$ and $f_i=q^{-1}$ for $2\le i\le m$. Then $\operatorname{ord}(f_1)=-1+0=-1$ and $\operatorname{ord}(f_i)=-1$, so all factors are normalized, and
$$q^m\prod_i f_i=q^m\cdot q^{-1}F\cdot q^{-(m-1)}=F. \qquad\square$$

**Theorem 6.6 (Non-uniqueness).** *Every order-$0$ series $F$ has at least two distinct factorizations as a renormalized product of two normalized series: if $q^2f_1f_2=F$, then also $q^2(-f_1)(-f_2)=F$ and $(-f_1,-f_2)\ne(f_1,f_2)$ since normalized series are nonzero.*

Hence the renormalized product retains the order data and nothing more; it cannot be inverted.

### 6.4 Symmetry is the obstruction to faithful aggregation

**Theorem 6.7 (No injective symmetric aggregate).** *Let $m\ge2$ and let $A$ map families $(f_1,\dots,f_m)$ of series to a single series, with $A(f_{\sigma(1)},\dots,f_{\sigma(m)})=A(f_1,\dots,f_m)$ for every permutation $\sigma$. Then $A$ is not injective.*

*Proof.* Take $f_1=q^{-1}$, $f_2=\dots=f_m=2q^{-1}$. Transposing the first two entries yields a different family (as $q^{-1}\ne2q^{-1}$) with the same $A$-value. $\square$

**Corollary 6.8.** *The product aggregate $(f_1,\dots,f_m)\mapsto\prod_i f_i$ is non-injective for every $m\ge2$: multiplication is commutative, hence permutation-invariant. The information loss of "multiply everything together'' is therefore structural, not an artefact of a particular counterexample.*

**Theorem 6.9 (A faithful, necessarily labelled aggregate).** *Fix $m\ge1$ and define the interleaving aggregate*
$$\mathrm{Int}(f_1,\dots,f_m)=\sum_{i=1}^{m}\sum_{n\in\mathbb{Z}}c^{(i)}_n\,q^{\,mn+i},\qquad f_i=\sum_n c^{(i)}_n q^n .$$
*Then each coefficient of each $f_i$ is recoverable from $\mathrm{Int}$ by extracting the exponents congruent to $i$ modulo $m$, so $\mathrm{Int}$ is injective. Consequently, by Theorem 6.7, for $m\ge2$ the interleaving aggregate is **not** permutation-invariant.*

**Corollary 6.10 (Aggregation dichotomy).** *For $m\ge2$, a scalar aggregate of a family of $m$ class-indexed series may be permutation-invariant or injective, but never both.*

This gives a clean verdict on the moonshine slogan. A single unlabeled object built symmetrically from the $194$ McKay–Thompson series cannot determine the family, hence cannot determine the Monster character table by any reconstruction map, because the map to be inverted is already non-injective. What *can* be faithful is a labelled aggregate — a vector-valued family, or an interleaved/graded packaging that remembers which class contributed which coefficient.

---

## 7. Algorithms

All results above are effective for explicitly given finite actions. We record the three main procedures.

### 7.1 Moment and orbit-count computation

To compute $\#(X^k/G)$ for a permutation group $G\le \mathrm{Sym}(X)$ given by its elements (or by generators, with orbit closure), the moment hierarchy provides an $O(|G|\cdot|X|)$ algorithm, versus $O(|G|\cdot|X|^k)$ for a naive union–find over $X^k$:

1. For each $g\in G$, compute $\varphi(g)=|X^g|$ in $O(|X|)$ time.
2. Return $\frac{1}{|G|}\sum_{g}\varphi(g)^k$.

The exactness of the division by $|G|$ is itself a strong correctness check.

### 7.2 Deciding $k$-transitivity from one moment

By Theorem 3.10, $k$-transitivity is decided by comparing $\sum_g\varphi(g)^k$ with $B_k|G|$, where $B_k$ is computed from the Bell recurrence $B_{k+1}=\sum_{j=0}^{k}\binom{k}{j}B_j$ or by enumerating restricted growth functions. This replaces an orbit computation on $|X|^{\underline{k}}$ injective tuples by a single pass over the group.

### 7.3 Distribution recovery from moments

Given the power sums $s_k=\sum_g\varphi(g)^k$ for $0\le k\le N$ with $N\ge\max_g\varphi(g)$, the counting vector $c=(c_0,\dots,c_N)$, $c_v=\#\{g:\varphi(g)=v\}$, is the unique solution of the Vandermonde system $\sum_v v^{k}c_v=s_k$. Exact rational Gaussian elimination (or Lagrange interpolation, exploiting the Vandermonde structure) recovers $c$ in $O(N^3)$ (resp. $O(N^2)$) exact operations, and the solution is guaranteed integral by Theorem 5.2.

---

## 8. Discussion

### 8.1 What the bridge connects

Three a priori unrelated bodies of data are identified by the results above:

* **Character-theoretic data:** the moments $\sum_{g\in G}|X^g|^k$ of the permutation character, i.e. the coefficientwise moments of the trace ("McKay–Thompson-type'') series family.
* **Enumerative data:** the Bell numbers $B_k$, realized as counts of restricted growth functions, i.e. of set partitions of the coordinate set.
* **Permutation-group data:** transitivity degree, orbit counts on tuples, and (via the fibre spectrum) the exact distribution of orbits over coincidence patterns.

The dictionary is exact in both directions: a single integer moment determines a transitivity property; the excess of that integer over the Bell value counts extra orbits with multiplicity; the whole distribution of the trace function is recoverable from $N+1$ moments and no fewer.

### 8.2 Relation to the classical moonshine picture

The classical setting replaces $|X^g|$ by $\operatorname{tr}(g\mid V_n)$ for a genuine graded module, and the coefficients then need not be nonnegative. Two of the results above are purely formal and transfer verbatim: class-invariance of the series, and the averaging identity $\frac1{|G|}\sum_g T_g=$ (trace of the projection onto the invariants), which for a permutation module is Burnside. The moment hierarchy uses positivity/counting essentially: $|(X^k)^g|=|X^g|^k$ is an isomorphism of $G$-sets, whose linearization is $\operatorname{tr}(g\mid V^{\otimes k})=\operatorname{tr}(g\mid V)^k$. Thus the correct general statement of Theorem 2.2 is
$$\frac1{|G|}\sum_{g\in G}\operatorname{tr}(g\mid V)^k=\dim\bigl((V^{\otimes k})^{G}\bigr),$$
and for a permutation module $V=\mathbb{C}[X]$ the right-hand side is $\#(X^k/G)$ — the moment hierarchy is the permutation shadow of tensor-power invariant dimensions. This is precisely the mechanism behind Schur–Weyl-type counts, and it explains why Bell numbers appear: the invariants of $\mathbb{C}[X]^{\otimes k}$ under a $k$-transitive group are spanned by the $B_k$ "diagonal'' classes.

### 8.3 What the results say about the product slogan

The strong claim sometimes proposed — that $\prod_{g} T_g$ is a holomorphic modular form of weight $|M|/24$ determining the Monster's character table, element orders, and maximal subgroups — fails for at least four independently sufficient reasons, three of which are made precise above:

1. **Normalization/pole order.** Each factor has order $-1$, so the product has order $-m$: for $m=194$ a pole of order $194$ (Theorem 6.3). Only after multiplying by $q^{m}$ is holomorphy at the cusp restored (Theorem 6.4), and then *every* order-$0$ series arises this way (Theorem 6.5), so the construction imposes no further constraint.
2. **Ambiguity of "all $g$''.** A product over all Monster elements has order $-|M|$; a product over class representatives has order $-194$. These are wildly different objects.
3. **Weight.** McKay–Thompson series are weight-$0$ modular functions; products of weight-$0$ objects have weight $0$, not $|M|/24$. Moreover the factors are invariant under different genus-zero groups, so any modularity claim must specify a common subgroup, compatible multipliers, and cusp behaviour.
4. **Information loss.** Even granting all of the above, the product is a permutation-invariant aggregate and is therefore non-injective (Theorem 6.7, Corollary 6.8); no reconstruction map can recover the family, hence the character table, from it alone.

The positive replacement is Corollary 6.10: faithful aggregation requires labels.

### 8.4 Limitations

The theory presented is about *finite* actions and formal series; nothing here touches modularity, genus-zero phenomena, or vertex-operator structure. The Bell criterion requires $k\le|X|$ (otherwise there are no injective $k$-tuples and $k$-transitivity is vacuous while the moment identity fails). The moment inversion theorem requires an a priori bound $N$ on the values; the sharpness example shows that no shorter range suffices in general, though for particular families the effective range can be much shorter. Finally, Theorem 5.7 delimits the reach of the entire moment tower: it is blind to the kernel of the action.

---

## 9. Future work

1. **Complex-valued graded characters.** Replace $|X^g|$ with $\operatorname{tr}(g\mid V_n)$ for genuine graded modules and prove the tensor-power form of the moment hierarchy, $\frac1{|G|}\sum_g\operatorname{tr}(g\mid V)^k=\dim (V^{\otimes k})^G$, together with the corresponding Bell-type lower bound for permutation modules.
2. **Pole orders in families.** Formalize the notion of weight and multiplier for the trace series of a graded action and identify which graded actions produce series with genuine modular invariance.
3. **Certified moonshine data.** Import a provenance-checked table of Monster irreducible characters together with the $194$ normalized McKay–Thompson series and verify coefficient decompositions by exact integer arithmetic; state modularity separately per class with its actual moonshine group.
4. **Fibre spectra as invariants.** Study the vector $(m_P)_{P\in\mathrm{Pat}(k)}$ as a finer invariant than the single number $\#(X^k/G)$: which vectors occur? Is the whole spectrum for all $k$ a complete invariant for some natural class of actions (it is not in general, by Theorem 5.7)?
5. **Labelled aggregates.** Investigate information-preserving aggregates — vector-valued families or interleaved generating functions — and characterize the minimal amount of labelling needed for injectivity.

---

## Appendix A. Worked examples

**A.1 Symmetric group $S_4$ on $4$ points.** Fixed-point counts: identity $4$; six transpositions $2$; three double transpositions $0$; eight $3$-cycles $1$; six $4$-cycles $0$. Then $\sum_\sigma|X^\sigma|=4+12+0+8+0=24=1\cdot 24$, so the action is transitive ($B_1=1$). $\sum|X^\sigma|^2=16+24+0+8+0=48=2\cdot24$, so $2$-transitive ($B_2=2$). $\sum|X^\sigma|^3=64+48+8=120=5\cdot24$: $3$-transitive ($B_3=5$). $\sum|X^\sigma|^4=256+96+8=360=15\cdot24$: $4$-transitive ($B_4=15$), as it must be, $S_4$ being the full symmetric group.

**A.2 Cyclic group $C_4$ on $4$ points.** Fixed-point counts $4,0,0,0$. Then $\sum=4=1\cdot4$: transitive. $\sum(\cdot)^2=16=4\cdot4$, whereas $B_2\cdot|G|=2\cdot4=8$: the Bell defect is $D_2=8=|G|\cdot\sum_P(m_P-1)$ with $|G|=4$, so $\sum_P(m_P-1)=2$ — indeed the "distinct coordinates'' pattern splits into $3$ orbits (differences $1,2,3$) and the diagonal pattern is a single orbit, giving $m$-values $1$ and $3$.

**A.3 Klein four-group blind spot.** With $V=S_2\times S_2$ acting on two points through either factor, both actions have fixed-point multiset $\{\!\{2,2,0,0\}\!\}$, hence identical moments $2^k+2^k$ for all $k\ge1$ and identical orbit counts $\#(X^k/V)=\frac{1}{4}(2\cdot 2^k)=2^{k-1}$, yet the actions are non-isomorphic.

**A.4 A $194$-fold product.** If $f_1,\dots,f_{194}$ each have order $-1$, then $\prod f_i$ has order $-194$ and $q^{194}\prod f_i$ has order $0$; conversely for any prescribed order-$0$ series $F$, taking $f_1=q^{-1}F$ and $f_i=q^{-1}$ for $i\ge2$ realizes $F$ exactly. The construction therefore constrains nothing beyond the order.
