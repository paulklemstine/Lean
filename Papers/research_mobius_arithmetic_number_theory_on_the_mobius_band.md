# Möbius Arithmetic: Orientation Twists of the Integers, Their Spectra, and Their Zeta Functions

**Author:** Aristotle
**Date:** 2026-08-07

---

## Abstract

We study number systems obtained by imposing an orientation ($\mathbb{Z}/2$) symmetry on the integers, in two essentially different ways, and we determine completely what arithmetic invariants each construction produces.

The first construction is *set-theoretic*: the **Möbius integers** $\widetilde{\mathbb{Z}}$ are the oriented integers $\mathbb{Z} \times \{\pm 1\}$ modulo the Möbius identification $(n,+1) \sim (-n,-1)$, with arithmetic performed through the identification. We prove that the quotient map $\mathbb{Z}\times\{\pm1\} \to \widetilde{\mathbb{Z}}$ is a genuine free double cover — the deck involution $(n,\varepsilon)\mapsto(-n,-\varepsilon)$ is fixed-point free and every fibre has exactly two points — but that the resulting ring is isomorphic to $\mathbb{Z}$. Consequently: the class number is one; prime elements double-cover the rational primes as a $\mathbb{Z}/2$-torsor, while the prime *spectrum* does not double at all ($\operatorname{Spec}\widetilde{\mathbb{Z}} \cong \operatorname{Spec}\mathbb{Z}$ as ordered sets); the integer $6$ has exactly four ordered factorizations into Möbius primes, yet unique factorization holds up to orientation, with the multiset of radii a complete invariant; the ring satisfies the Ore condition; and the Dirichlet series is $\widetilde{\zeta}(s) = 2\zeta(s)$, so that the Möbius Riemann hypothesis is *equivalent* to the classical one. We prove a general theorem subsuming the last point: any norm whose nonzero fibres all have cardinality $k$ has Dirichlet series $k\zeta(s)$, and its Riemann hypothesis is equivalent to the classical one for every $k \ge 1$.

We then isolate the structural reason. Multiplication lifts to the cover *separably* — magnitudes multiply, orientations multiply — while addition admits no such lift, in a sharp sense: even allowing the orientation of a sum to be an arbitrary function of both complete oriented inputs, the magnitude of the sum is not a function of the two magnitudes. We give a necessary criterion for separable liftability (invariance of the absolute value under negating either argument), show it rules out addition, subtraction and many other operations, and exhibit an operation showing the criterion is not sufficient. We also classify the possible twists: the only additive symmetry of $\mathbb{Z}$ of finite order is $\pm\mathrm{id}$, negation occurring only in even order, so the Möbius half-twist is the unique nontrivial finite twist of the integers.

The second construction is *multiplicative*: the **oriented double** $\mathcal{O} = \mathbb{Z}[\tau]/(\tau^2-1)$, realised as the index-two subring $\{(u,v)\in\mathbb{Z}^2 : u\equiv v \bmod 2\}$ of $\mathbb{Z}\times\mathbb{Z}$. Here every prediction that failed for $\widetilde{\mathbb{Z}}$ succeeds: $\mathcal{O}$ is not a domain, hence not isomorphic to $\mathbb{Z}$ or $\widetilde{\mathbb{Z}}$; its unit group is the Klein four-group $\{\pm1,\pm\tau\}$; it has exactly two ring maps to $\mathbb{Z}$, exchanged by the deck involution; and $\operatorname{Spec}\mathcal{O} \to \operatorname{Spec}\mathbb{Z}$ is a double cover branched exactly at $2$, with conductor equal to the branch locus. Its spectral zeta function is $\zeta_{\mathcal{O}}(s) = \zeta(s)^2\,(1-2^{-s})$, with Dirichlet coefficients $d(n) - d(n/2)$ counting ideals of index $n$ at prime index, and value $\pi^4/48$ at $s=2$. The ramified factor produces a zero at $s_0 = 2\pi i/\log 2$ which is not a zero of $\zeta$; so the oriented Riemann hypothesis is *false*, while inside the critical strip it remains equivalent to the classical one.

The overall conclusion is a dichotomy: a $\mathbb{Z}/2$ symmetry carried by an identification of points is multiplicatively trivialisable and arithmetically invisible; a $\mathbb{Z}/2$ symmetry carried by the multiplication produces a branched cover of the spectrum, squares the Euler factors, and moves zeros — but only through its ramification.

**Keywords:** Möbius identification, oriented integers, free double cover, unique factorization up to associates, prime spectrum, group ring $\mathbb{Z}[\mathbb{Z}/2]$, Dirichlet series, Euler product, ramification, Riemann hypothesis.

---

## 1. Introduction

### 1.1 The question

The Möbius band is the quotient of the annulus $S^1\times[-1,1]$ by the free involution $(\theta,t)\mapsto(\theta+\pi,-t)$. It is the simplest nontrivial example of a free $\mathbb{Z}/2$-cover, and its half-twist is the prototype of orientation-reversal.

Arithmetic, too, is organised by quotients and covers: $\mathbb{Z}/n$, ideal class groups, extensions of number fields with their splitting and ramification behaviour, and the Euler products that encode all of this analytically. The natural question is therefore whether the Möbius twist can be transplanted into number theory. Concretely: take the integers, remember an orientation, glue with a half-turn, and see what arithmetic emerges.

This paper carries out that programme, tests all the conjectures it naturally suggests, and — crucially — explains the pattern of successes and failures by locating precisely where a $\mathbb{Z}/2$ symmetry must be stored in order to have arithmetic consequences.

### 1.2 Summary of results

We construct two objects.

1. **The Möbius integers** $\widetilde{\mathbb{Z}}$: the set-level construction. Section 2 builds it and proves it is a free double cover of an honest $\mathbb{Z}/2$-action; Section 3 proves the Structure Theorem $\widetilde{\mathbb{Z}}\cong\mathbb{Z}$ and the polar decomposition; Section 4 works out factorization theory and adjudicates the original conjectures; Section 5 computes the zeta function and proves a general "$k$-fold norm" theorem; Section 6 proves the sharp additive obstruction and the classification of finite twists.

2. **The oriented double** $\mathcal{O}=\mathbb{Z}[\tau]/(\tau^2-1)$: the multiplicative construction. Section 7 establishes its structure and its branched double-cover spectrum; Section 8 computes its spectral zeta function, its Dirichlet coefficients, and its zeros.

Section 9 discusses the resulting dichotomy, algorithms, applications and open problems.

### 1.3 Notation

$\zeta$ denotes the Riemann zeta function; $d = \sigma_0$ the number-of-divisors function; $\mathbb{F}_p = \mathbb{Z}/p$; $\operatorname{Spec} R$ the prime spectrum of a commutative ring $R$; $|S|$ the cardinality of $S$. "Radius" and "norm" are used interchangeably for the absolute value of the signed value of a Möbius integer.

---

## 2. The Möbius integers as a free double cover

### 2.1 Definition

**Definition 2.1 (Oriented integers).** An *oriented integer* is a pair $a = (n,\varepsilon)$ with $n \in \mathbb{Z}$ (the *magnitude*) and $\varepsilon \in \{+1,-1\}$ (the *orientation*). Write $\mathrm{Or} = \mathbb{Z}\times\{\pm1\}$.

**Definition 2.2 (Signed value).** The *signed value* of $a=(n,\varepsilon)$ is $v(a) = \varepsilon\, n \in \mathbb{Z}$. Thus $v(n,+1)=n$ and $v(n,-1)=-n$.

**Definition 2.3 (Möbius identification).** Declare $a \sim b$ iff $v(a) = v(b)$. Since this is the kernel relation of a function it is an equivalence relation, and its defining instance is precisely
$$(n,+1) \;\sim\; (-n,-1).$$
The set of classes is the set of **Möbius integers** $\widetilde{\mathbb{Z}} = \mathrm{Or}/\!\sim$. Write $[a]$ for the class of $a$, and let $V : \widetilde{\mathbb{Z}} \to \mathbb{Z}$, $V([a]) = v(a)$, be the induced signed-value map (well defined by construction).

Two useful abbreviations: for $n \ge 0$ write $n^{+} = [(n,+1)]$ and $n^{-} = [(n,-1)]$. Then $V(n^{+}) = n$ and $V(n^{-}) = -n$.

**Lemma 2.4.** $V$ is a bijection $\widetilde{\mathbb{Z}} \to \mathbb{Z}$; equivalently, $[a]=[b] \iff v(a)=v(b)$, and every integer is a signed value.

*Proof.* Injectivity is the definition of the relation, after passing to representatives; surjectivity holds since $V(n^{+}) = n$. $\square$

Lemma 2.4 already signals what is coming, but the interest of $\widetilde{\mathbb{Z}}$ is the *cover*, which does not collapse.

### 2.2 The deck involution

**Definition 2.5.** The *deck transformation* is $\tau : \mathrm{Or}\to\mathrm{Or}$, $\tau(n,\varepsilon) = (-n,-\varepsilon)$.

**Theorem 2.6 (Free double cover).** The following hold.
1. $\tau\circ\tau = \mathrm{id}$.
2. $\tau(a) \ne a$ for every $a$: the involution is fixed-point free.
3. $[a]=[b]$ if and only if $b = a$ or $b = \tau(a)$.
4. Every fibre of $\mathrm{Or}\to\widetilde{\mathbb{Z}}$ has exactly two elements.

*Proof.* (1) is immediate. (2): if $(-n,-\varepsilon)=(n,\varepsilon)$ then $\varepsilon = -\varepsilon$, impossible. (3): $v(\tau(a)) = (-\varepsilon)(-n)=\varepsilon n = v(a)$, so the "if" direction holds; conversely if $v(n,\varepsilon)=v(m,\delta)$ then either $\delta=\varepsilon$, forcing $m=n$, or $\delta=-\varepsilon$, forcing $m=-n$, i.e. $b=\tau(a)$. (4) follows from (2) and (3): the fibre through $a$ is $\{a,\tau(a)\}$, a two-element set. $\square$

**Corollary 2.7 ($\widetilde{\mathbb{Z}}$ is an orbit space).** Let $\mathbb{Z}/2$ act on $\mathrm{Or}$ with the nontrivial element acting as $\tau$. The action is *free* (only the identity fixes any point), and the orbit space is canonically $\widetilde{\mathbb{Z}}$: two oriented integers lie in the same orbit iff they have the same Möbius class.

This is the exact algebraic transcription of "the Möbius band is the annulus modulo a free involution": free, unramified, and with orbit space the band.

### 2.3 Twisted arithmetic

**Definition 2.8.** Define operations on $\widetilde{\mathbb{Z}}$ *through the identification*: for $x,y\in\widetilde{\mathbb{Z}}$,
$$x + y := (V(x)+V(y))^{+},\qquad x\cdot y := (V(x)\,V(y))^{+},\qquad -x := (-V(x))^{+},$$
with $0 = 0^{+}$ and $1 = 1^{+}$, where for $m\in\mathbb{Z}$ we write $m^{+} = [(m,+1)]$ (extending the earlier notation to all integers).

**Proposition 2.9.** These operations are well defined and satisfy $V(x+y)=V(x)+V(y)$, $V(xy)=V(x)V(y)$, $V(0)=0$, $V(1)=1$. They make $\widetilde{\mathbb{Z}}$ a commutative ring.

*Proof.* Well-definedness is automatic since the operations are defined via $V$, which is well defined; the displayed identities are then immediate from $v(m,+1)=m$. Every ring axiom is pulled back along the injective map $V$ from the corresponding axiom in $\mathbb{Z}$. $\square$

Two elementary compatibilities record how the twist interacts with the ring structure.

**Lemma 2.10 (Orientation reversal is negation).** For all $n,\varepsilon$: $[(n,-\varepsilon)] = -[(n,\varepsilon)]$. In particular $n^{-} = -\,n^{+}$.

---

## 3. Structure: the twist collapses

**Theorem 3.1 (Structure Theorem).** The signed-value map is a ring isomorphism
$$V:\ \widetilde{\mathbb{Z}} \;\xrightarrow{\ \sim\ }\; \mathbb{Z},$$
with inverse $n \mapsto n^{+}$.

*Proof.* $V$ is bijective (Lemma 2.4) and additive and multiplicative (Proposition 2.9). $\square$

**Corollary 3.2.** $\widetilde{\mathbb{Z}}$ is an integral domain and a principal ideal domain; every ideal is $(x)$ for some $x$.

**Proposition 3.3 (The unit group is the orientation group).** $x\in\widetilde{\mathbb{Z}}$ is a unit iff $x = 1$ or $x=-1$, and $-1 \ne 1$. Hence $\widetilde{\mathbb{Z}}^{\times}$ is cyclic of order two, canonically isomorphic to $\mathbb{Z}/2$.

*Proof.* Transport along $V$ and use that the units of $\mathbb{Z}$ are $\pm1$. $\square$

So the Möbius twist survives *only* as the unit group — the same $\mathbb{Z}/2$ that is $\pi_1$ of the Möbius band, and the same $\mathbb{Z}/2$ that acted freely upstairs.

### 3.1 Polar decomposition

**Definition 3.4.** The *norm* (or radius) of $x \in \widetilde{\mathbb{Z}}$ is $N(x) = |V(x)| \in \mathbb{N}$.

Clearly $N(xy)=N(x)N(y)$, $N(-x)=N(x)$, and $N(x)=0 \iff x=0$.

**Theorem 3.5 (Polar decomposition).** The map
$$\widetilde{\mathbb{Z}}^{\times}\times\mathbb{Z}_{>0} \longrightarrow \widetilde{\mathbb{Z}}\setminus\{0\},\qquad (u,n)\mapsto u\cdot n^{+},$$
is a bijection, and a monoid isomorphism for multiplication. Consequently the multiplicative monoid of nonzero Möbius integers is the direct product
$$\widetilde{\mathbb{Z}}\setminus\{0\} \;\cong\; \mathbb{Z}/2 \times \mathbb{Z}_{>0}.$$

*Proof sketch.* Multiplicativity is $N(u\,n^{+}) = n$ and $(u m^{+})(v n^{+}) = (uv)(mn)^{+}$. Injectivity: applying $N$ gives $m=n$, and cancelling $n^{+}$ (a nonzero element of a domain) gives $u=v$. Surjectivity: given $x\ne 0$, put $n = N(x)$; then either $V(x)=n$, whence $x = 1\cdot n^{+}$, or $V(x)=-n$, whence $x=(-1)\cdot n^{+}$. $\square$

**Corollary 3.6 (Multiplicative triviality of the cover).** The orientation character $\widetilde{\mathbb{Z}}\setminus\{0\}\to\mathbb{Z}/2$ obtained from Theorem 3.5 is a surjective monoid homomorphism admitting the section $n \mapsto n^{+}$. The Möbius double cover is therefore multiplicatively a *trivial* $\mathbb{Z}/2$-bundle over the monoid of radii.

Corollary 3.6 is the structural pattern behind every positive result below: class number one, unique factorization up to orientation, and $\widetilde{\zeta}=2\zeta$ are all consequences of a *split* orientation.

**Theorem 3.7 (Torsor structure of norm fibres).** If $x\ne 0$ and $N(x)=N(y)$, there is a *unique* unit $u$ with $y=ux$. Thus each nonzero fibre of $N$ is a torsor under $\widetilde{\mathbb{Z}}^{\times}\cong\mathbb{Z}/2$.

*Proof.* $|V(x)|=|V(y)|$ gives $V(y)=\pm V(x)$, i.e. $y=\pm x$; uniqueness of $u$ follows by cancelling $x$ in the domain $\widetilde{\mathbb{Z}}$. $\square$

**Proposition 3.8 (Lattice count).** For $N \in \mathbb{N}$, exactly $2N+1$ Möbius integers have norm $\le N$: two per positive radius, plus the centre.

**Theorem 3.9 (Doubled divisor function).** For $x \ne 0$, the set of divisors of $x$ in $\widetilde{\mathbb{Z}}$ has exactly $2\,d(N(x))$ elements, where $d$ is the classical divisor-counting function.

*Proof sketch.* Divisibility transports along $V$: $e \mid x$ iff $V(e)\mid V(x)$. The divisors of a nonzero integer $m$ in $\mathbb{Z}$ are the $\pm k$ with $k \mid |m|$, a disjoint union of two copies of the positive divisors, giving $2 d(|m|)$. $\square$

---

## 4. Factorization theory, and the fate of the conjectures

### 4.1 Primes and associates

**Theorem 4.1 (Primality is orientation-blind).** $x\in\widetilde{\mathbb{Z}}$ is prime iff $N(x)$ is a rational prime. In particular, for a rational prime $p$ both $p^{+}$ and $p^{-}$ are prime.

**Theorem 4.2 (Associates are orientation flips).** $x$ and $y$ are associates iff $y=x$ or $y=-x$.

**Theorem 4.3 (Fibres of the norm).** For $n \in \mathbb{N}$, $\{x : N(x) = n\} = \{n^{+}, n^{-}\}$, a two-element set for $n \ne 0$ and the singleton $\{0\}$ for $n = 0$. Consequently, for a rational prime $p$,
$$\bigl|\{x \in \widetilde{\mathbb{Z}} : x \text{ prime},\ N(x)=p\}\bigr| = 2 .$$

So **the prime elements do double-cover the rational primes**, and Theorem 3.7 says the two primes over $p$ form a $\mathbb{Z}/2$-torsor. This is the correct and provable form of the conjectured "oriented primes $p^{+}, p^{-}$".

### 4.2 The spectrum does *not* double

**Theorem 4.4 (No spectral doubling).** For every $n$, $(n^{+}) = (n^{-})$ as ideals. In particular $p^{+}$ and $p^{-}$, although distinct elements, define the *same* point of $\operatorname{Spec}\widetilde{\mathbb{Z}}$. Moreover the comparison map induced by the Structure Theorem is an order isomorphism
$$\operatorname{Spec}\widetilde{\mathbb{Z}} \;\cong\; \operatorname{Spec}\mathbb{Z}.$$

*Proof.* $n^{-}=-n^{+}$ and $-1$ is a unit, so the two principal ideals coincide; the second statement is functoriality of $\operatorname{Spec}$ applied to a ring isomorphism. $\square$

This refutes the conjecture that each rational prime "splits into two oriented primes" in the geometric sense. The doubling is a phenomenon of *elements*, and it is precisely a torsor under the unit group; on points of the spectrum the units act trivially, and the cover is a single cover.

### 4.3 Class number and unique factorization

**Theorem 4.5 (Class number one).** $\widetilde{\mathbb{Z}}$ is a principal ideal domain, so its ideal class group is trivial: the class number is $1$.

**Theorem 4.6 (Unique factorization up to orientation).** Let $f$ and $g$ be finite multisets of primes of $\widetilde{\mathbb{Z}}$ with equal products. Then there is a bijection between $f$ and $g$ matching each $x$ with a $y$ satisfying $y = x$ or $y = -x$.

*Proof sketch.* $\widetilde{\mathbb{Z}}$ is a unique factorization domain, so the two multisets are matched up to associates; by Theorem 4.2 associates in $\widetilde{\mathbb{Z}}$ are exactly orientation flips. $\square$

**Corollary 4.7 (Radii are a complete invariant).** Under the hypotheses of Theorem 4.6, the multisets of norms of $f$ and $g$ coincide. Hence the "unoriented" factorization of a Möbius integer is genuinely unique.

### 4.4 The test case: factoring $6$

**Theorem 4.8 (Complete enumeration).** The set of ordered pairs of Möbius primes with product $6$ is exactly
$$\{(2^{+},3^{+}),\ (3^{+},2^{+}),\ (2^{-},3^{-}),\ (3^{-},2^{-})\},$$
four elements. In particular $6 = 2^{+}3^{+} = 2^{-}3^{-}$ and $(2^{+},3^{+}) \ne (2^{-},3^{-})$.

*Proof sketch.* Transport to $\mathbb{Z}$ along $V$. If $a,b$ are prime integers with $ab=6$ then $|a||b|=6$ with both $\ge 2$, forcing $\{|a|,|b|\}=\{2,3\}$; the sign must be common to both since the product is positive. The four sign-and-order combinations are precisely the four listed pairs. $\square$

**Theorem 4.9 (…but unique factorization is not violated).** $2^{+}$ and $2^{-}$ are associates, as are $3^{+}$ and $3^{-}$.

So the prediction that "$6$ has two distinct factorizations" is **confirmed as a statement about oriented data** and **refuted as a failure of unique factorization**. The two factorizations differ by the unit $-1$ distributed across the two factors — a phenomenon already present in $\mathbb{Z}$, where $6 = 2\cdot 3 = (-2)\cdot(-3)$.

### 4.5 The Ore condition

**Theorem 4.10.** For nonzero $a,b \in\widetilde{\mathbb{Z}}$ there exist nonzero $x,y$ with $ax = by \ne 0$ — e.g. $x=b$, $y=a$. Hence $\widetilde{\mathbb{Z}}$ satisfies both Ore conditions.

The conjecture that $\widetilde{\mathbb{Z}}$ is a non-Ore ring — and that this explains exotic zeta behaviour — is therefore false at its root: $\widetilde{\mathbb{Z}}$ is a commutative domain.

---

## 5. The Möbius zeta function

### 5.1 The Dirichlet series

**Definition 5.1.** For $s\in\mathbb{C}$ set $\widetilde{\zeta}(s) := 2\,\zeta(s)$.

**Theorem 5.2 (The Dirichlet series of $\widetilde{\mathbb{Z}}$).** For $\operatorname{Re}s>1$,
$$\sum_{\substack{x\in\widetilde{\mathbb{Z}}\\ x\ne 0}} \frac{1}{N(x)^{s}} \;=\; 2\,\zeta(s) \;=\; \widetilde{\zeta}(s).$$

*Proof sketch.* Reindex the sum along the bijection $V$ to a sum over nonzero integers $\sum_{n\ne0}|n|^{-s}$; split it into the positive and negative halves, each equal to $\zeta(s)$ by absolute convergence for $\operatorname{Re}s>1$. The centre $x=0$ is excluded (it is the unique point of the norm fibre over $0$, the "ramification point" of the radius map, and its summand is undefined). $\square$

**Theorem 5.3 (Euler product).** For $\operatorname{Re}s>1$,
$$\widetilde{\zeta}(s) \;=\; 2\prod_{p} \bigl(1-p^{-s}\bigr)^{-1}.$$
Each rational prime contributes *one* Euler factor even though it carries two oriented primes, because the two are associate (Theorem 4.9) and generate the same ideal (Theorem 4.4).

### 5.2 Zeros

**Theorem 5.4.** $\widetilde{\zeta}(s)=0 \iff \zeta(s)=0$. In particular $\widetilde{\zeta}$ vanishes at $s=-2,-4,-6,\dots$

**Corollary 5.5 (Zeros off the critical line — with a caveat).** There exist $s$ with $\widetilde{\zeta}(s)=0$ and $\operatorname{Re}s \ne \tfrac12$; e.g. $s=-2$. The conjecture "the Möbius zeta function has zeros off the critical line" is thus literally true, but only via the *trivial* zeros inherited from $\zeta$, and not by any mechanism attributable to the twist.

**Definition 5.6.** The *Möbius Riemann hypothesis* asserts: every zero $s$ of $\widetilde{\zeta}$ that is neither $1$ nor of the form $-2(n+1)$, $n\in\mathbb{N}$, satisfies $\operatorname{Re}s=\tfrac12$.

**Theorem 5.7.** The Möbius Riemann hypothesis is equivalent to the classical Riemann hypothesis.

**Theorem 5.8 (Doubling is not squaring).** $\widetilde{\zeta}(2) = \pi^{2}/3 \ne \pi^{4}/36 = \zeta(2)^{2}$.

A genuine two-to-one cover of $\operatorname{Spec}\mathbb{Z}$ would square each Euler factor and hence (up to ramification) square the zeta function; the Möbius cover only multiplies by the order of the unit group. Theorem 5.8 is the analytic shadow of Theorem 4.4.

### 5.3 The general phenomenon

The doubling in Theorem 5.2 has nothing to do with the specific construction: it is a consequence of the *constancy of the fibre size*.

**Definition 5.9.** A map $N : A \to \mathbb{N}$ is a *$k$-fold norm* ($k \ge 1$) if every nonzero value of $N$ is attained exactly $k$ times: $|\{x : N(x) = n\}| = k$ for all $n\ne0$.

**Theorem 5.10 (Oriented zeta theorem).** If $N:A\to\mathbb{N}$ is a $k$-fold norm then, for $\operatorname{Re}s>1$,
$$\sum_{\substack{x\in A\\ N(x)\ne0}} \frac{1}{N(x)^{s}} \;=\; k\,\zeta(s).$$

*Proof sketch.* Choose, for each $n \ge 1$, a bijection of the fibre $N^{-1}(n)$ with $\{1,\dots,k\}$; assembling these gives a bijection $\{x : N(x)\ne0\} \cong \{1,\dots,k\}\times\mathbb{Z}_{>0}$ under which the summand depends only on the second coordinate. Reindexing an absolutely convergent sum over a finite product multiplies it by the size of the finite factor, giving $k\sum_{n\ge1}n^{-s} = k\zeta(s)$. $\square$

**Theorem 5.11 (No $k$-fold cover moves a zero).** For each $k\ge1$, define the $k$-fold Riemann hypothesis as the assertion that every non-trivial, non-pole zero of $k\zeta$ lies on $\operatorname{Re}s=\tfrac12$. Then for every $k\ge1$ this is equivalent to the classical Riemann hypothesis. Moreover every $k\ge1$ is realised by some $k$-fold norm (take $A = \mathbb{N}\times\{1,\dots,k\}$, $N(n,i)=n$), so the constant in Theorem 5.10 is sharp.

**Corollary 5.12.** The Möbius norm is a $2$-fold norm (Theorem 4.3), and $\widetilde{\zeta} = 2\zeta$ is the case $k=2$ of Theorem 5.10. The Möbius doubling is exactly the order of the orientation group, entering as a scalar and never as an Euler-factor multiplicity.

---

## 6. Where the twist lives: the additive obstruction

The Structure Theorem says the twist is invisible in the ring. This section explains *why*, and shows that the explanation is sharp.

### 6.1 Multiplication lifts, addition does not

**Theorem 6.1 (Multiplication is orientation-local).** For all oriented integers $a=(m,\varepsilon)$, $b=(n,\delta)$,
$$[a]\cdot[b] = [(mn,\ \varepsilon\delta)].$$
That is, the magnitude of a product is computed from the magnitudes and the orientation of a product from the orientations; the coordinates do not interact.

**Theorem 6.2 (Additive obstruction).** There is *no* pair of functions $g:\mathbb{Z}^2\to\mathbb{Z}$ and $h:\{\pm1\}^2\to\{\pm1\}$ with
$$[a] + [b] = [(g(m,n),\, h(\varepsilon,\delta))] \quad\text{for all } a=(m,\varepsilon),\ b=(n,\delta).$$

*Proof.* Take $a=(1,+1)$ and both $b=(1,+1)$ and $b=(1,-1)$. The two sums are $2$ and $0$, of absolute values $2$ and $0$; but in both cases the magnitude produced is $g(1,1)$, and the class $[(g(1,1),\eta)]$ has absolute signed value $|g(1,1)|$ regardless of $\eta$. Hence $|g(1,1)| = 2$ and $|g(1,1)| = 0$, a contradiction. $\square$

**Theorem 6.3 (Sharp form).** Even if the orientation of the sum is permitted to be an arbitrary function of the two *complete* oriented inputs, the magnitude of a Möbius sum cannot be computed from the two magnitudes alone: there is no $g:\mathbb{Z}^2\to\mathbb{Z}$ and $h:\mathrm{Or}^2\to\{\pm1\}$ with $[a]+[b] = [(g(m,n), h(a,b))]$ for all $a,b$.

*Proof.* Identical: the argument above never used separability of $h$, only that the absolute signed value of $[(k,\eta)]$ equals $|k|$. $\square$

This is the precise obstruction. Multiplication respects the stratification of the cover into a magnitude direction and an orientation direction; addition mixes them irreparably. Since the twist can only be recorded in structure that respects the stratification, and a *ring* structure requires addition, the twist cannot survive as ring structure — but it does survive multiplicatively, as Corollary 3.6 shows.

### 6.2 A criterion, and its limits

**Definition 6.4.** A binary operation $F:\mathbb{Z}^2\to\mathbb{Z}$ *lifts separably* if there are $g:\mathbb{Z}^2\to\mathbb{Z}$ and $h:\{\pm1\}^2\to\{\pm1\}$ with $v(g(m,n),h(\varepsilon,\delta)) = F(v(m,\varepsilon), v(n,\delta))$ for all oriented $(m,\varepsilon),(n,\delta)$.

**Theorem 6.5 (Necessary criterion).** If $F$ lifts separably then for all $m,n$:
$$|F(-m,n)| = |F(m,n)| \quad\text{and}\quad |F(m,-n)| = |F(m,n)|.$$

*Proof.* Both sides equal $|g(m,n)|$, since $|v(k,\eta)| = |k|$. $\square$

**Examples 6.6.**
- Multiplication lifts separably (Theorem 6.1).
- Addition does not: $|(-1)+1| = 0 \ne 2 = |1+1|$.
- Subtraction does not: $|1-(-1)| = 2 \ne 0 = |1-1|$.
- $(m,n)\mapsto m+n^{2}$ does not: $|-1+1| = 0 \ne 2$.
- Even the near-trivial $(m,n)\mapsto m+1$ does not: $|-1+1| = 0 \ne 2 = |1+1|$.

**Theorem 6.7 (The criterion is not sufficient).** Let
$$F(m,n) = \begin{cases} mn & \text{if } 2 \mid m,\\ |mn| & \text{otherwise.}\end{cases}$$
Then $|F(-m,n)| = |F(m,n)|$ and $|F(m,-n)| = |F(m,n)|$ for all $m,n$, yet $F$ admits no separable lift.

*Proof sketch.* The two invariance statements are immediate from $|F(m,n)| = |mn|$. For the failure of lifting: comparing $F$ at the inputs $(1,\pm1)$ with first argument of magnitude $1$ forces $h$ to give the same output sign in two cases where $F$ takes the value $1$ each time, while at magnitude $2$ the same pair of orientation inputs must produce the values $2$ and $-2$. No choice of $h(\cdot,\cdot) \in \{\pm1\}$ is consistent with both demands. $\square$

The moral: the real obstruction is a *sign cocycle*, not a size condition. Absolute values only detect part of it.

### 6.3 Classification of finite twists

One might hope for a "$\mathbb{Z}/k$-Möbius arithmetic" for other $k$. There is none.

**Theorem 6.8 (Classification of twists).** Let $\rho:\mathbb{Z}\to\mathbb{Z}$ be an additive homomorphism with $\rho^{\circ k} = \mathrm{id}$ for some $k > 0$. Then either $\rho = \mathrm{id}$, or $\rho(n) = -n$ for all $n$ and $k$ is even.

*Proof.* An additive endomorphism of $\mathbb{Z}$ is multiplication by $c = \rho(1)$, and $\rho^{\circ k}$ is multiplication by $c^{k}$; the hypothesis gives $c^{k}=1$, so $c$ is a unit, $c = \pm1$. If $c=-1$ then $(-1)^{k}=1$ forces $k$ even. $\square$

**Corollary 6.9.** There is no genuine $\mathbb{Z}/k$-twist of the integer line of odd order: any additive symmetry of odd finite order is the identity. The Möbius half-twist $n\mapsto -n$, of order two, is the unique nontrivial finite twist.

---

## 7. The oriented double: a twist that survives

The diagnosis of Section 6 suggests the remedy: **store the orientation in the multiplication**.

### 7.1 Definition and basic structure

**Definition 7.1.** The *oriented double* is the group ring of the orientation group,
$$\mathcal{O} \;=\; \mathbb{Z}[\tau]/(\tau^{2}-1),$$
realised concretely as the subring
$$\mathcal{O} \;\cong\; \{(u,v)\in\mathbb{Z}\times\mathbb{Z} \ :\ u\equiv v \ (\mathrm{mod}\ 2)\} \;\subseteq\; \mathbb{Z}\times\mathbb{Z},$$
via $a + b\tau \mapsto (a+b,\ a-b)$. The diagonal $\iota : \mathbb{Z}\to\mathcal{O}$, $n \mapsto (n,n)$, is an injective ring map, and $\tau = (1,-1)$.

**Theorem 7.2 (Basis).** Every element of $\mathcal{O}$ is uniquely $\iota(a) + \iota(b)\tau$ with $a,b\in\mathbb{Z}$; and $\tau^{2}=1$.

**Theorem 7.3 (Not a domain).** $(1+\tau)(1-\tau) = 1-\tau^{2} = 0$, while $1+\tau \ne 0 \ne 1-\tau$. Hence $\mathcal{O}$ is not an integral domain and therefore
$$\mathcal{O} \not\cong \mathbb{Z}, \qquad \mathcal{O}\not\cong\widetilde{\mathbb{Z}}.$$
Unlike the set-level construction, the multiplicative twist is a genuine ring-theoretic invariant.

**Theorem 7.4 (The orientation group grows).** $x \in \mathcal{O}$ is a unit iff $x \in \{1,-1,\tau,-\tau\}$, and these four are distinct. Thus $\mathcal{O}^{\times}$ is the Klein four-group $(\mathbb{Z}/2)^{2}$, an extension of the $\mathbb{Z}/2$ of $\widetilde{\mathbb{Z}}^{\times}$ by a new orientation direction.

**Definition 7.5.** The *deck involution* $\sigma:\mathcal{O}\to\mathcal{O}$ is the coordinate swap $(u,v)\mapsto(v,u)$, i.e. $\tau \mapsto -\tau$; it is a ring automorphism of order two.

**Theorem 7.6 (Fixed ring).** $\sigma(x) = x$ iff $x = \iota(n)$ for some $n\in\mathbb{Z}$: the fixed ring of the deck involution is exactly the diagonal copy of $\mathbb{Z}$.

**Theorem 7.7 (Exactly two orientations).** Define $\pi^{+}(a+b\tau) = a+b$ and $\pi^{-}(a+b\tau)=a-b$, the two coordinate projections. Then $\pi^{+} \ne \pi^{-}$, and *every* ring homomorphism $\mathcal{O}\to\mathbb{Z}$ equals $\pi^{+}$ or $\pi^{-}$. Moreover $\pi^{+}\circ\sigma = \pi^{-}$: the deck involution exchanges the two orientations.

*Proof sketch.* A ring map $f$ is determined by $f(\tau)$, which must satisfy $f(\tau)^2 = 1$, hence $f(\tau)=\pm1$; the two choices give $\pi^{\pm}$. $\square$

Each orientation exhibits $\widetilde{\mathbb{Z}}\cong\mathbb{Z}$ as an *orientation-quotient* of $\mathcal{O}$: the Möbius integers sit below the oriented double, one sheet at a time.

### 7.2 The spectrum is a branched double cover

Fix a rational prime $p$, and let $\pi^{\pm}_{p} : \mathcal{O} \to \mathbb{F}_p$ be the reduction of $\pi^{\pm}$ modulo $p$.

**Definition 7.8.** $P^{+}(p) = \ker \pi^{+}_{p}$ and $P^{-}(p) = \ker\pi^{-}_{p}$. Concretely $x \in P^{+}(p)$ iff $p$ divides the first coordinate of $x$, and similarly for $P^{-}$ and the second coordinate.

**Theorem 7.9.** For every prime $p$, both $\pi^{\pm}_p$ are surjective, so $P^{\pm}(p)$ are maximal ideals with residue field $\mathbb{F}_p$; and both contract to $p\mathbb{Z}$ along the diagonal $\iota$.

**Theorem 7.10 (Splitting at odd primes).** For $p$ an odd prime, $P^{+}(p) \ne P^{-}(p)$ and
$$P^{+}(p)\cap P^{-}(p) = (p),\qquad \mathcal{O}/p\mathcal{O} \cong \mathbb{F}_p\times\mathbb{F}_p.$$
Hence $p$ splits: there are exactly two points of $\operatorname{Spec}\mathcal{O}$ over $p$, and they are exchanged by $\sigma$.

**Theorem 7.11 (Ramification at $2$).** $P^{+}(2) = P^{-}(2) =: P(2)$, and
$$P(2)^{2} \subseteq (2) \subsetneq P(2).$$
The residue ring of $\mathcal{O}$ at $2$ is not reduced: the image of $\tau - 1$ is a nonzero nilpotent. Hence there is exactly one point of $\operatorname{Spec}\mathcal{O}$ over $2$, and it is fixed by $\sigma$.

**Corollary 7.12 (Sheet count).** Writing $\mathrm{sh}(p)$ for the number of points of $\operatorname{Spec}\mathcal{O}$ above $p$,
$$\mathrm{sh}(p) = \begin{cases} 1 & p = 2,\\ 2 & p \text{ odd}.\end{cases}$$
$\operatorname{Spec}\mathcal{O}\to\operatorname{Spec}\mathbb{Z}$ is a double cover branched exactly at the prime $2$ — the discrete shadow of the orientation double cover, with a single branch point.

**Theorem 7.13 (Conductor equals branch locus).** $\mathcal{O}$ has index two in $\mathbb{Z}\times\mathbb{Z}$, its normalisation; explicitly the parity map $(u,v)\mapsto u-v \bmod 2$ induces
$$(\mathbb{Z}\times\mathbb{Z})/\mathcal{O} \;\cong\; \mathbb{Z}/2 .$$
So the conductor of the order is supported exactly at the branch prime.

---

## 8. The spectral zeta function of the oriented double

### 8.1 Euler product

**Definition 8.1.** Give each point of $\operatorname{Spec}\mathcal{O}$ over $p$ the Euler factor $(1-p^{-s})^{-1}$ (legitimate, since each has residue field $\mathbb{F}_p$ by Theorems 7.9–7.11), and set
$$\zeta_{\mathcal{O}}(s) \;=\; \prod_{p \text{ prime}} \Bigl( \bigl(1-p^{-s}\bigr)^{-1}\Bigr)^{\mathrm{sh}(p)} .$$

**Theorem 8.2 (Closed form).** For $\operatorname{Re}s > 1$,
$$\boxed{\ \zeta_{\mathcal{O}}(s) \;=\; \zeta(s)^{2}\,\bigl(1 - 2^{-s}\bigr).\ }$$

*Proof sketch.* By Corollary 7.12 the product is $\prod_p (1-p^{-s})^{-2}$ *corrected* at $p=2$, where the exponent is $1$ rather than $2$; multiplying and dividing, $\zeta_{\mathcal{O}}(s) = \left(\prod_p (1-p^{-s})^{-2}\right)\cdot (1-2^{-s}) = \zeta(s)^2 (1-2^{-s})$, using the classical Euler product and the non-vanishing of the ramified factor on $\operatorname{Re}s>0$. $\square$

**Corollary 8.3.** $\zeta_{\mathcal{O}}(s) \ne 0$ for $\operatorname{Re}s>1$.

Note the contrast with Theorem 5.2: the multiplicative twist *squares* the Euler factors, whereas the set-level Möbius twist merely doubles the whole function.

### 8.2 Dirichlet coefficients count ideals

**Definition 8.4.** For $n \ge 1$ set
$$c(n) \;=\; d(n) - d(n/2),$$
where $d$ is the divisor function and $d(n/2)$ is read as $0$ when $n$ is odd. These are the Dirichlet coefficients of $\zeta(s)^2(1-2^{-s})$.

**Theorem 8.5 (Dirichlet expansion).** For $\operatorname{Re}s>1$, $\ \zeta_{\mathcal{O}}(s) = \sum_{n\ge1} c(n)\, n^{-s}$.

**Theorem 8.6 (Non-negativity and prime values).** $c(n)\ge0$ for all $n$; $c(p) = 2$ for odd primes $p$; and $c(2^{k}) = 1$ for all $k \ge 1$. The first twelve values are
$$c(1),\dots,c(12) \;=\; 1,\ 1,\ 2,\ 1,\ 2,\ 2,\ 2,\ 1,\ 3,\ 2,\ 2,\ 2 .$$

*Proof sketch.* Non-negativity follows from $d(n/2) \le d(n)$ since $n/2 \mid n$. For odd $p$, $d(p)=2$ and the correction vanishes; for $n=2^{k+1}$, $d(2^{k+1}) - d(2^{k}) = (k+2)-(k+1)=1$. $\square$

**Theorem 8.7 (The coefficients count ideals at prime index).** For every prime $p$, the number of ideals $I \subseteq \mathcal{O}$ with $|\mathcal{O}/I| = p$ equals $c(p)$. Concretely: for odd $p$ there are exactly two such ideals, $P^{+}(p)$ and $P^{-}(p)$; for $p=2$ there is exactly one, $P(2)$.

Note that $c(9)=3$, matching the three ideals of index $9$ over the prime $3$, namely $P^{+}(3)^2$, $P^{+}(3)P^{-}(3)=(3)$, and $P^{-}(3)^2$.

### 8.3 Special values and zeros

**Theorem 8.8 (Value at $s=2$).** $\ \zeta_{\mathcal{O}}(2) = \dfrac{\pi^{4}}{48} \approx 2.02937$.

*Proof.* $\zeta(2)^2 = \pi^4/36$ and $1-2^{-2}=3/4$; the product is $\pi^4/48$. $\square$

**Corollary 8.9 (The two twists are analytically distinct).** $\zeta_{\mathcal{O}}(2) = \pi^{4}/48 \ne \pi^{2}/3 = \widetilde{\zeta}(2)$.

**Definition 8.10.** Let $s_{0} = \dfrac{2\pi i}{\log 2}$, so $\operatorname{Im}s_{0} = 2\pi/\log 2 \approx 9.0647$ and $\operatorname{Re}s_{0} = 0$.

**Theorem 8.11 (A new zero).** $2^{-s_{0}} = e^{-s_0\log 2} = e^{-2\pi i} = 1$, so the ramified factor vanishes: $1 - 2^{-s_{0}} = 0$ and hence $\zeta_{\mathcal{O}}(s_{0}) = 0$ (where $\zeta_{\mathcal{O}}$ is understood via its closed form $\zeta(s)^2(1-2^{-s})$, the meromorphic continuation from Theorem 8.2). But $\zeta(s_{0}) \ne 0$: $s_0$ lies on the line $\operatorname{Re}s=0$, and the only zeros of $\zeta$ with $\operatorname{Re}s \le 0$ are the trivial zeros at the negative even integers, all of which are real. Hence $s_0$ is a zero of $\zeta_{\mathcal{O}}$ that is *not* a zero of $\zeta$.

**Corollary 8.12 (The oriented Riemann hypothesis is false).** There is a zero $s_0$ of $\zeta_{\mathcal{O}}$ with $s_0 \ne 1$, $s_0$ not a trivial zero of $\zeta$, and $\operatorname{Re}s_0 = 0 \ne \tfrac12$.

The original slogan of the programme — "the oriented zeta function has zeros off the critical line" — is therefore *literally and non-trivially true* for the oriented double. The mechanism, however, is not exotic non-commutativity (which does not exist here: $\mathcal{O}$ is commutative) but **ramification**: the new zeros are the zeros of the branch factor $1-2^{-s}$, an entire periodic function whose zeros are $2\pi i k/\log 2$, $k \in \mathbb{Z}$.

**Theorem 8.13 (…but the critical strip is untouched).** All the extra zeros lie on the line $\operatorname{Re}s = 0$, outside the open strip $0 < \operatorname{Re}s < 1$. Consequently, *inside the critical strip*, the oriented Riemann hypothesis is equivalent to the classical one: every zero of $\zeta_{\mathcal{O}}$ with $0 < \operatorname{Re}s<1$ has $\operatorname{Re}s=\tfrac12$ if and only if the classical Riemann hypothesis holds.

*Proof sketch.* On the strip, $1-2^{-s}$ does not vanish (its zeros are purely imaginary), so the zeros of $\zeta(s)^2(1-2^{-s})$ there are exactly the zeros of $\zeta$, with multiplicity doubled. $\square$

A double cover moves the zero set only through its branch locus, and only outside the strip.

---

## 9. Discussion

### 9.1 The dichotomy

The two constructions differ in exactly one respect — where the $\mathbb{Z}/2$ symmetry is stored — and the arithmetic consequences are opposite in every particular.

| | Set-level twist $\widetilde{\mathbb{Z}}$ | Multiplicative twist $\mathcal{O}$ |
|---|---|---|
| Underlying cover | free, unramified, 2 points per fibre | branched at $2$ |
| Ring | $\cong \mathbb{Z}$; a PID and a domain | not a domain; $\not\cong\mathbb{Z}$ |
| Unit group | $\mathbb{Z}/2$ | Klein four-group |
| Prime elements over $p$ | two, forming a $\mathbb{Z}/2$-torsor | — |
| Points of the spectrum over $p$ | one | two for odd $p$, one for $p=2$ |
| Effect on Euler factors | none (global factor $2$) | squared, corrected at $2$ |
| Zeta function | $2\zeta(s)$ | $\zeta(s)^2(1-2^{-s})$ |
| Value at $s=2$ | $\pi^{2}/3$ | $\pi^{4}/48$ |
| New zeros | none | $2\pi i k/\log 2$, $k\ne0$ |
| Riemann hypothesis | equivalent to classical | false; equivalent on the strip |

The conceptual statement is:

> **A $\mathbb{Z}/2$-symmetry realised as an identification of the underlying set is multiplicatively trivialisable (Corollary 3.6) and additively non-liftable (Theorems 6.2–6.3). Multiplicative triviality forces the ring to be untwisted and the zeta function to be a scalar multiple. A $\mathbb{Z}/2$-symmetry realised in the multiplication is not trivialisable, and produces a branched cover of the spectrum with the corresponding Euler-factor multiplicities.**

The boundary between the two regimes is precisely the failure of addition to lift to the cover.

### 9.2 Verdict on the original conjectures

- **Class number one.** True (Theorem 4.5) — but inherited from $\mathbb{Z}$.
- **Primes split into $p^{+}$ and $p^{-}$.** True as a statement about *elements* (Theorem 4.3), a $\mathbb{Z}/2$-torsor (Theorem 3.7); false as a statement about the *spectrum* (Theorem 4.4). The correct spectral splitting occurs in the oriented double (Theorem 7.10).
- **$6$ has two distinct factorizations.** True as oriented data — exactly four ordered factorizations (Theorem 4.8) — but not a failure of unique factorization (Theorem 4.9).
- **Unique factorization up to orientation.** True, in the sharp form that the multiset of radii is a complete invariant (Theorem 4.6, Corollary 4.7).
- **$\widetilde{\mathbb{Z}}$ is non-Ore.** False (Theorem 4.10).
- **The oriented zeta function has zeros off the critical line.** For $\widetilde{\mathbb{Z}}$: true only via inherited trivial zeros (Corollary 5.5), and the Riemann hypothesis is unchanged (Theorem 5.7). For $\mathcal{O}$: true non-trivially (Corollary 8.12), the extra zeros coming from ramification, but confined to $\operatorname{Re}s=0$ (Theorem 8.13).

### 9.3 Algorithms

Three computational procedures organise the material.

**Algorithm A (Möbius normal form and arithmetic).** Represent a Möbius integer by its signed value $V(x)$. Reduce a representative $(n,\varepsilon)$ to normal form by computing $\varepsilon n$; add and multiply signed values; the oriented representative with positive orientation is the canonical lift. Costs $O(1)$ bignum operations per arithmetic step, plus $O(\log|n|)$ bits for storage. Correctness is exactly Proposition 2.9 and Theorem 3.1.

**Algorithm B (Oriented prime factorization).** Given a nonzero Möbius integer $x$: compute $N = N(x)$; factor $N = \prod p_i^{e_i}$ classically; the factorizations of $x$ into Möbius primes are exactly the choices of orientation on each factor whose product of orientations equals the orientation of $x$. Hence $x$ has $2^{\Omega(N)-1}$ multisets of oriented prime factors, all associate in pairs, but a unique multiset of *radii* (Corollary 4.7). Complexity: dominated by integer factorization of $N$.

**Algorithm C (Sheet counting and Dirichlet coefficients for the oriented double).** For each $n$, compute $c(n) = d(n) - d(n/2)$ by sieving the divisor function up to a bound $X$ in time $O(X\log X)$; the partial sums approximate $\zeta_{\mathcal{O}}(s)$, and $c(p)$ reproduces the sheet count $\mathrm{sh}(p)$ at prime index (Theorems 8.6, 8.7).

### 9.4 Applications and connections

*Orders in étale algebras.* $\mathcal{O}$ is the simplest non-maximal order in the split étale algebra $\mathbb{Q}\times\mathbb{Q}$, and everything computed here — conductor $2$, split residue rings at odd primes, non-reduced residue ring at $2$, zeta function $\zeta^2\cdot(1-2^{-s})$ — is a completely explicit instance of the general theory of zeta functions of orders. The Möbius framing gives a topological reading of the conductor as a branch locus.

*Covering-space heuristics in arithmetic.* Theorems 5.10–5.11 formalise a useful negative principle: a covering whose fibre cardinality is a *constant independent of the point* contributes an additive constant to $\log\zeta$ and can never affect the zero set. To move zeros one needs the multiplicity to be *inside* the Euler factors, which means a genuine extension of rings, not a relabelling of elements.

*Orientation data in computation.* The dichotomy "multiplication lifts, addition does not" (Theorems 6.1–6.3) is a statement about representing signed quantities as (magnitude, sign) pairs — the sign-magnitude representation of computer arithmetic. It explains, at the level of impossibility rather than inefficiency, why sign-magnitude adders must inspect magnitudes to compute the output sign, while sign-magnitude multipliers need only XOR the sign bits.

*Group rings of small groups.* $\mathcal{O} = \mathbb{Z}[\mathbb{Z}/2]$ is the first nontrivial integral group ring, and the branch prime $2$ is the order of the group. The pattern — ramification exactly at primes dividing the group order — is the arithmetic content that the Möbius picture renders geometric.

### 9.5 Future work

Natural continuations include:

1. **$\mathbb{Z}[\mathbb{Z}/k]$ for general $k$.** Compute the sheet counts and spectral zeta function of $\mathbb{Z}[t]/(t^k-1)$, whose spectrum should be branched exactly at the primes dividing $k$, and whose zeta function should be a product of Dedekind zeta functions of cyclotomic fields corrected by conductor factors. Corollary 6.9 shows the corresponding *set-level* construction does not exist for odd $k$, sharpening the contrast.

2. **Non-abelian orientation groups.** Replacing $\mathbb{Z}/2$ by a non-abelian finite group gives non-commutative orders where the Ore condition becomes a genuine question — the setting in which the original "non-Ore" intuition might actually be realised.

3. **Quantitative ramification.** Determine, for a general order $R$ in an étale $\mathbb{Q}$-algebra, exactly which zeros of $\zeta_R$ fail to be zeros of the maximal-order zeta function, as a function of the conductor. Theorem 8.13 is the $\mathbb{Z}[\mathbb{Z}/2]$ case: all such zeros are purely imaginary.

4. **The full cocycle obstruction.** Theorem 6.7 shows the absolute-value criterion is not sufficient. Classify exactly which binary operations on $\mathbb{Z}$ lift separably to the oriented cover — the answer should be a cohomological condition on a sign cocycle over $\{\pm1\}^2$.

---

## 10. Conclusion

Doing arithmetic on the Möbius band is possible, and the answer is instructive precisely because it is negative in the first instance. The half-twist is real at the level of the cover — free, fixed-point-free, exactly two sheets — and it survives multiplicatively as a split $\mathbb{Z}/2$ of orientations, giving prime elements in pairs, a doubled divisor function, and a zeta function $2\zeta(s)$. But it does not survive as *ring* structure: the ring of Möbius integers is $\mathbb{Z}$, its spectrum is $\operatorname{Spec}\mathbb{Z}$, its class number is one for the least interesting reason, and its Riemann hypothesis is the ordinary one. The obstruction is exactly the failure of addition to lift to the cover, and this failure is sharp.

Replacing the identification by a multiplicative twist — adjoining an orientation symbol $\tau$ with $\tau^2=1$ — repairs every deficiency at once. The oriented double is not a domain, has a larger orientation group, and its spectrum is a bona fide double cover of $\operatorname{Spec}\mathbb{Z}$ branched exactly at $2$. Its zeta function squares the Euler factors, its Dirichlet coefficients $d(n)-d(n/2)$ count ideals, and its branch locus supplies genuinely new zeros at $2\pi i k/\log 2$, which nonetheless leave the critical strip undisturbed.

Topology suggested the question; the answer is that a topological twist becomes an arithmetic one exactly when it is written into the multiplication.
