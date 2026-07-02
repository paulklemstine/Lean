# Explicit Reciprocity from Roots of Unity to Class Numbers: Steps Toward Hilbert's Twelfth Problem

## Abstract

Hilbert's twelfth problem asks for an explicit construction of the abelian extensions of an arbitrary number field, generalizing the Kronecker–Weber theorem, which realizes every abelian extension of the rationals inside a cyclotomic field. We develop the arithmetic consequences of the abelian ($\mathrm{GL}_1$) reciprocity law in two settings. Over the rationals, we harvest the group-theoretic invariants of cyclotomic Galois groups from the Artin reciprocity isomorphism $(\mathbb{Z}/n\mathbb{Z})^\times \cong \mathrm{Gal}(\mathbb{Q}(\zeta_n)/\mathbb{Q})$: the order of the group equals Euler's totient $\varphi(n)$, and for prime modulus $p$ the group is cyclic of order $p-1$. We show by explicit example ($n=8$) that cyclicity genuinely requires the prime hypothesis. We then take the first structural step beyond $\mathbb{Q}$ by studying the Hilbert class field $H$ of a number field $K$, characterized by the higher reciprocity isomorphism $\mathrm{Gal}(H/K)\cong \mathrm{Cl}(\mathcal{O}_K)$. From this isomorphism we derive the fundamental degree law $[H:K] = h_K$, where $h_K$ is the class number, and the corollary that class number one forces $H = K$. We verify non-vacuity by instantiating the reciprocity datum for $K = H = \mathbb{Q}$. Throughout, the emphasis is on turning abstract reciprocity isomorphisms into exact, computable numerical invariants — the numerical fingerprints of explicit class field theory.

**Keywords:** Kronecker–Weber theorem, cyclotomic fields, Artin reciprocity, Euler totient, cyclic Galois groups, Hilbert class field, ideal class group, class number, Hilbert's twelfth problem, Langlands program.

## 1. Introduction

Class field theory describes the abelian extensions of a number field $K$ — its finite Galois extensions with commutative Galois group — in terms of the arithmetic of $K$ itself. Its foundational special case is the **Kronecker–Weber theorem**: every abelian extension of $\mathbb{Q}$ is contained in a cyclotomic field $\mathbb{Q}(\zeta_n)$, the field obtained by adjoining a primitive $n$-th root of unity. Hilbert's twelfth problem asks for the analogous *explicit* generators for an arbitrary base field $K$ — the "roots of unity of $K$."

This paper is organized around a single organizing principle: an abelian reciprocity isomorphism does more than match two objects set-theoretically; it forces their numerical and structural invariants to coincide. We exploit this principle twice.

1. Over $\mathbb{Q}$, the Artin reciprocity isomorphism
   $$\rho_n : (\mathbb{Z}/n\mathbb{Z})^\times \xrightarrow{\ \sim\ } \mathrm{Gal}(\mathbb{Q}(\zeta_n)/\mathbb{Q})$$
   determines the order and cyclic type of the cyclotomic Galois group (Section 3).

2. Over an arbitrary number field $K$, the higher reciprocity isomorphism
   $$\mathrm{Gal}(H/K)\xrightarrow{\ \sim\ }\mathrm{Cl}(\mathcal{O}_K)$$
   characterizing the Hilbert class field $H$ determines the degree $[H:K]$ (Section 4).

The results are elementary given the reciprocity isomorphisms, but their point is methodological: they are the reusable numerical lemmas — degree $=\varphi(n)$, prime-case cyclicity, degree $=$ class number — on which downstream conductor, ramification, and tower computations rest.

## 2. Definitions and background

Throughout, $n$ denotes a positive integer and $\zeta_n$ a primitive $n$-th root of unity.

**Definition 2.1 (Cyclotomic field).** The $n$-th *cyclotomic field* is $\mathbb{Q}(\zeta_n)$, the smallest subfield of $\mathbb{C}$ containing $\mathbb{Q}$ and $\zeta_n$. It is a Galois extension of $\mathbb{Q}$.

**Definition 2.2 (Galois group).** For a finite Galois extension $L/K$, the *Galois group* $\mathrm{Gal}(L/K)$ is the group of field automorphisms of $L$ fixing $K$ pointwise, under composition. Its cardinality equals the degree $[L:K] = \dim_K L$.

**Definition 2.3 (Euler totient).** For $n\ge 1$, $\varphi(n) = \#\{\,k : 1\le k\le n,\ \gcd(k,n)=1\,\} = \#(\mathbb{Z}/n\mathbb{Z})^\times$.

**Definition 2.4 (Cyclic group).** A finite group $G$ is *cyclic* if there exists $g\in G$ with $G = \{g^0,g^1,\dots\}$; equivalently $G\cong \mathbb{Z}/|G|\mathbb{Z}$.

**Definition 2.5 (Ring of integers, ideal class group, class number).** For a number field $K$, let $\mathcal{O}_K$ be its ring of integers (the integral closure of $\mathbb{Z}$ in $K$). The *ideal class group* $\mathrm{Cl}(\mathcal{O}_K)$ is the quotient of the group of nonzero fractional ideals by the subgroup of principal fractional ideals; it is a finite abelian group. The *class number* is $h_K = \#\,\mathrm{Cl}(\mathcal{O}_K)$. One has $h_K = 1$ if and only if $\mathcal{O}_K$ is a principal ideal domain, i.e. factorization into primes is unique.

**Definition 2.6 (Hilbert class field).** The *Hilbert class field* $H$ of $K$ is the maximal unramified abelian extension of $K$. It is the canonical first target of explicit class field theory; its defining property is the Artin reciprocity isomorphism
$$\mathrm{Gal}(H/K)\cong \mathrm{Cl}(\mathcal{O}_K).$$

## 3. The cyclotomic case over $\mathbb{Q}$

The foundation for this section is the abelian reciprocity isomorphism over the rationals.

**Reciprocity datum 3.1 (Artin reciprocity over $\mathbb{Q}$).** For every modulus $n$ there is a canonical group isomorphism
$$\rho_n : (\mathbb{Z}/n\mathbb{Z})^\times \xrightarrow{\ \sim\ } \mathrm{Gal}(\mathbb{Q}(\zeta_n)/\mathbb{Q}),$$
sending the class of $k$ to the automorphism $\sigma_k : \zeta_n \mapsto \zeta_n^{\,k}$.

This isomorphism is the concrete $\mathrm{GL}_1$ instance of Artin reciprocity, and it is constructed unconditionally for every $n$. Everything in this section is a transported consequence of $\rho_n$.

### 3.1 The degree equals Euler's totient

**Theorem 3.2 (Degree of the cyclotomic extension).** For every $n\ge 1$,
$$\#\,\mathrm{Gal}(\mathbb{Q}(\zeta_n)/\mathbb{Q}) = \varphi(n),$$
and hence $[\mathbb{Q}(\zeta_n):\mathbb{Q}] = \varphi(n)$.

*Proof sketch.* The isomorphism $\rho_n$ is in particular a bijection of underlying sets, so
$$\#\,\mathrm{Gal}(\mathbb{Q}(\zeta_n)/\mathbb{Q}) = \#(\mathbb{Z}/n\mathbb{Z})^\times.$$
By Definition 2.3, $\#(\mathbb{Z}/n\mathbb{Z})^\times = \varphi(n)$. Since the cardinality of the Galois group of a finite Galois extension equals its degree, $[\mathbb{Q}(\zeta_n):\mathbb{Q}] = \varphi(n)$. $\qquad\blacksquare$

The proof requires only $n\neq 0$ (so that $\mathbb{Q}(\zeta_n)$ is well-defined); no primality is assumed. This recovers the classical statement that the minimal polynomial of $\zeta_n$ — the $n$-th cyclotomic polynomial — has degree $\varphi(n)$, now read off directly from the order of the reciprocity partner rather than from irreducibility arguments.

**Examples.** $[\mathbb{Q}(\zeta_5):\mathbb{Q}] = \varphi(5) = 4$; $[\mathbb{Q}(\zeta_{12}):\mathbb{Q}] = \varphi(12) = 4$; $[\mathbb{Q}(\zeta_{1}):\mathbb{Q}] = \varphi(1)=1$; $[\mathbb{Q}(\zeta_{2}):\mathbb{Q}] = \varphi(2)=1$ (since $\zeta_2 = -1$ already lies in $\mathbb{Q}$).

### 3.2 Prime moduli give cyclic Galois groups

**Theorem 3.3 (Cyclicity for prime modulus).** For a prime $p$, the group $\mathrm{Gal}(\mathbb{Q}(\zeta_p)/\mathbb{Q})$ is cyclic.

*Proof sketch.* The multiplicative group of a finite field is cyclic; in particular $(\mathbb{Z}/p\mathbb{Z})^\times = \mathbb{F}_p^\times$ is cyclic. Cyclicity is preserved under group isomorphism, so transporting along $\rho_p$ shows $\mathrm{Gal}(\mathbb{Q}(\zeta_p)/\mathbb{Q})$ is cyclic. $\qquad\blacksquare$

**Theorem 3.4 (Order for prime modulus).** For a prime $p$,
$$\#\,\mathrm{Gal}(\mathbb{Q}(\zeta_p)/\mathbb{Q}) = p - 1.$$

*Proof sketch.* By Theorem 3.2 the order is $\varphi(p)$, and for a prime $\varphi(p) = p-1$. $\qquad\blacksquare$

Combining Theorems 3.3 and 3.4: $\mathrm{Gal}(\mathbb{Q}(\zeta_p)/\mathbb{Q})\cong \mathbb{Z}/(p-1)\mathbb{Z}$. A generator corresponds under $\rho_p$ to a *primitive root* modulo $p$.

### 3.3 The prime hypothesis is necessary

**Proposition 3.5 (Cyclicity fails for $n=8$).** $\mathrm{Gal}(\mathbb{Q}(\zeta_8)/\mathbb{Q})$ is not cyclic; it is isomorphic to $\mathbb{Z}/2\mathbb{Z}\times\mathbb{Z}/2\mathbb{Z}$.

*Proof sketch.* Under $\rho_8$ the Galois group is isomorphic to $(\mathbb{Z}/8\mathbb{Z})^\times = \{1,3,5,7\}$. Each element squares to $1$ modulo $8$ ($3^2=9\equiv 1$, $5^2=25\equiv 1$, $7^2=49\equiv 1$), so every non-identity element has order $2$. A cyclic group of order $4$ has an element of order $4$; hence the group is not cyclic and must be the Klein four-group $\mathbb{Z}/2\mathbb{Z}\times\mathbb{Z}/2\mathbb{Z}$. $\qquad\blacksquare$

Thus the prime hypothesis in Theorems 3.3–3.4 is load-bearing, not decorative: the structural conclusion "cyclic" is a genuine feature of prime moduli.

## 4. The Hilbert class field of a general number field

We now take the first structural step beyond the cyclotomic ($\mathrm{GL}_1/\mathbb{Q}$) case. Let $K$ be a number field with ring of integers $\mathcal{O}_K$ and Hilbert class field $H$ (Definition 2.6).

Because the full existence theory of the Hilbert class field — its maximality and unramifiedness — lies deeper than the numerical consequences we seek, we isolate the single property that makes $H$ useful and treat it as an explicit hypothesis: the reciprocity isomorphism.

**Reciprocity datum 4.1 (Artin reciprocity for the Hilbert class field).** There is a group isomorphism
$$e : \mathrm{Gal}(H/K)\xrightarrow{\ \sim\ }\mathrm{Cl}(\mathcal{O}_K).$$

**Theorem 4.2 (Degree equals class number).** Let $K$ be a number field and $H/K$ a finite Galois extension equipped with a reciprocity isomorphism $e:\mathrm{Gal}(H/K)\cong \mathrm{Cl}(\mathcal{O}_K)$. Then
$$[H:K] = h_K.$$

*Proof sketch.* For a finite Galois extension the number of automorphisms equals the degree:
$$\#\,\mathrm{Gal}(H/K) = [H:K].$$
The isomorphism $e$ is a bijection, so
$$\#\,\mathrm{Gal}(H/K) = \#\,\mathrm{Cl}(\mathcal{O}_K) = h_K$$
by Definition 2.5. Chaining the two equalities gives $[H:K] = h_K$. $\qquad\blacksquare$

**Corollary 4.3 (Class number one).** Under the hypotheses of Theorem 4.2, if $h_K = 1$ then $[H:K] = 1$; equivalently, $H = K$.

*Proof sketch.* Immediate from $[H:K] = h_K = 1$. $\qquad\blacksquare$

Corollary 4.3 formalizes the maxim that a number field with unique factorization is its own Hilbert class field: it admits no nontrivial unramified abelian extension.

### 4.1 Non-vacuity: the rational witness

A conditional theorem is only as valuable as the certainty that its hypotheses can be met. We exhibit the reciprocity datum concretely in the simplest case.

**Proposition 4.4 (Rational witness).** For $K = H = \mathbb{Q}$, the reciprocity isomorphism $e$ exists: both $\mathrm{Gal}(\mathbb{Q}/\mathbb{Q})$ and $\mathrm{Cl}(\mathbb{Z})$ are trivial groups, so the unique map between them is an isomorphism. Consequently Theorem 4.2 instantiates to $[\mathbb{Q}:\mathbb{Q}] = h_{\mathbb{Q}} = 1$.

*Proof sketch.* The ring of integers of $\mathbb{Q}$ is $\mathbb{Z}$, a principal ideal domain, so $\mathrm{Cl}(\mathbb{Z})$ is trivial and $h_{\mathbb{Q}} = 1$; the class group of $\mathbb{Z}$ has at most one element, hence is a singleton. The Galois group $\mathrm{Gal}(\mathbb{Q}/\mathbb{Q})$ is trivial. Any map between two trivial groups is an isomorphism, providing $e$. Theorem 4.2 then yields $[\mathbb{Q}:\mathbb{Q}] = 1$, consistent with the trivial extension. $\qquad\blacksquare$

This witness rules out the failure mode in which the hypotheses of Theorem 4.2 can never be satisfied, and it exhibits Kronecker–Weber's base field $\mathbb{Q}$ as the degenerate corner of the general theory.

## 5. Algorithms

The reciprocity laws above are constructive and yield direct computational recipes.

**Algorithm A (Cyclotomic degree and cyclic type).** Given $n$, compute $\varphi(n)$ by factoring $n = \prod p_i^{a_i}$ and using $\varphi(n) = \prod p_i^{a_i - 1}(p_i - 1)$; this is $[\mathbb{Q}(\zeta_n):\mathbb{Q}]$. The Galois group is cyclic if and only if $n\in\{1,2,4,p^k,2p^k\}$ for an odd prime $p$ (equivalently, $(\mathbb{Z}/n\mathbb{Z})^\times$ is cyclic); in the prime case a generator is found by locating a primitive root modulo $p$.

**Algorithm B (Hilbert class field degree).** Given a number field $K$, compute $\mathrm{Cl}(\mathcal{O}_K)$ (for example, via Minkowski's bound: every ideal class contains an integral ideal of norm at most the Minkowski bound $M_K$, so enumerate prime ideals of norm $\le M_K$ and their relations). The degree of the Hilbert class field is $[H:K] = h_K$, the size of the resulting group; $H = K$ exactly when $h_K = 1$.

## 6. Applications

- **Degree computations.** Theorem 3.2 provides degrees of cyclotomic extensions purely arithmetically, and Theorem 4.2 provides degrees of Hilbert class fields from class-number data — no explicit generators of the extensions are needed.
- **Detecting unique factorization.** Corollary 4.3 links a field-theoretic invariant ($[H:K]$) to a purely arithmetic one ($h_K$); a nontrivial Hilbert class field is a certificate that unique factorization fails in $K$.
- **Primitive roots and generators.** Theorem 3.3 identifies generators of prime cyclotomic Galois groups with primitive roots modulo $p$, tying field automorphisms to elementary number theory.

## 7. Discussion

The results here are individually elementary once the reciprocity isomorphisms are granted, but collectively they illustrate the core mechanism of explicit class field theory: reciprocity transports arithmetic invariants ($\varphi(n)$, cyclicity, the class number) onto structural invariants of field extensions (degree, Galois type). This is the abelian, $\mathrm{GL}_1$ layer of the Langlands program, where the correspondence is fully understood and unconditional over $\mathbb{Q}$.

The Hilbert class field marks the genuine departure from Kronecker–Weber. Over $\mathbb{Q}$ the reciprocity partner is the concrete group $(\mathbb{Z}/n\mathbb{Z})^\times$; over a general $K$ it is the ideal class group, an invariant sensitive to the failure of unique factorization. The degree law $[H:K] = h_K$ is the precise analogue of $[\mathbb{Q}(\zeta_n):\mathbb{Q}] = \varphi(n)$ one level up in generality.

## 8. Future directions

*Conductor duality for cyclotomic subfields.* Every abelian extension of $\mathbb{Q}$ has a smallest cyclotomic field containing it, and the modulus of that field — the conductor — is a computable arithmetic invariant equal to the least common multiple of the ramified primes' contributions. The subfield lattice of a cyclotomic field is in order-reversing bijection with the subgroup lattice of a finite abelian group, so the conductor is forced by group-theoretic index rather than by any transcendental input.

*Class-number rigidity of the Hilbert tower.* For a number field of class number greater than one, the Hilbert class field again has its own class number; iterating produces a tower whose successive degrees are class numbers. The degree-equals-class-number law converts a qualitative tower into a sequence of exactly computable integers.

*Prime-cyclicity transfer to real subfields.* For each prime $p$, the maximal real subfield of $\mathbb{Q}(\zeta_p)$ is a cyclic extension of $\mathbb{Q}$ of degree $(p-1)/2$, being the unique index-two quotient of the full cyclotomic Galois group. Cyclicity descends to quotients, so the real subfield inherits an explicit cyclic generator.

*Complex-multiplication analogue of Kronecker–Weber.* For an imaginary quadratic field, the abelian extensions are generated not by roots of unity but by special values of modular and elliptic functions (the theory of complex multiplication) — the archetypal solved case of Hilbert's twelfth problem beyond $\mathbb{Q}$.

## 9. Conclusion

Starting from the abelian reciprocity isomorphisms, we extracted the exact numerical invariants of the objects they govern: the degree of a cyclotomic field is Euler's totient, prime moduli yield cyclic Galois groups of order $p-1$ (and the prime hypothesis is necessary, as $n=8$ shows), and the degree of a Hilbert class field equals the class number, collapsing to a trivial extension exactly when factorization is unique. Together these are the numerical fingerprints of explicit class field theory and concrete steps toward Hilbert's twelfth problem.
