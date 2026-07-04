# Residue-Anabelomorphic Equivalence: Rigidity and Non-Rigidity of the GL(1) Residue Torus

## Abstract

We develop a self-contained, rigorous model of the abelian (rank-one)
shadow of J. Joshi's notion of *anabelomorphy* — the phenomenon whereby
distinct local fields may be linked through isomorphisms of arithmetic
group data — restricted to the $\mathrm{GL}(1)$ / residue layer of the
local Langlands correspondence. To each non-archimedean local field we
attach a *residue datum* $(p, f)$ consisting of its residue
characteristic and residue degree, and the *residue torus*
$k^{\times}$, the multiplicative group of its residue field, a finite
cyclic group of order $p^f - 1$. We define two residue data to be
*residue-anabelomorphic* when their residue tori are isomorphic as
abstract groups, show this is an equivalence relation, and prove two
structural theorems. **Rigidity Theorem:** the residue tori are
isomorphic if and only if $p = p'$ and $f = f'$; the abstract group thus
recovers both invariants exactly. **Degree Non-Rigidity Theorem:**
fixing the residue characteristic and the total field degree $e \cdot f$
does *not* force residue-anabelomorphic equivalence, witnessed by the
unramified and totally ramified quadratic extensions of $\mathbb{Q}_2$.
Consequently residue degree is a strictly finer anabelomorphic invariant
than total field degree: ramification may be traded against residue
degree without preserving the $\mathrm{GL}(1)$ datum. We discuss the
sense in which these results localize the entire reconstruction
obstruction in the wild (pro-$p$) part of the field, and outline
extensions to L-factor invariance and higher-rank Langlands stacks.

**Keywords:** anabelomorphy, local field, residue field, residue torus,
finite field, cyclic group, local Langlands correspondence, GL(1),
ramification, prime-power rigidity.

**Mathematics Subject Classification:** 11S37 (local Langlands), 11S15
(ramification), 12E20 (finite fields), 11S31 (class field theory of
local fields).

---

## 1. Introduction

### 1.1 Anabelian geometry and anabelomorphy

A central theme of arithmetic geometry, originating with Grothendieck's
anabelian program and developed dramatically by Mochizuki, asks to what
extent an arithmetic object is determined by an abstract group naturally
attached to it — typically an absolute Galois group or an étale
fundamental group. When the object can be reconstructed from the group
alone, one speaks of *rigidity*.

Joshi's notion of **anabelomorphy** turns this lens around: rather than
asking when the group determines a *unique* field, it studies the
equivalence relation induced on fields by isomorphisms of their group
data, and the ways in which genuinely distinct fields can share the same
group-theoretic shadow. This paper isolates the simplest honest instance
of that relation and determines it completely.

### 1.2 The GL(1) / residue layer

The absolute Galois group of a non-archimedean local field $K$ is an
intricate profinite group. Its abelianization is, by local class field
theory, essentially the profinite completion of $K^{\times}$, and the
multiplicative group $K^{\times}$ decomposes canonically as
$$K^{\times} \;\cong\; \mathbb{Z} \;\times\; \mu_{q-1} \;\times\; U^{(1)},$$
where the $\mathbb{Z}$ records the valuation (the *unramified line*),
$\mu_{q-1}$ is the cyclic group of roots of unity of order $q - 1$ with
$q = p^f$ the residue-field size (the *tame torus*), and $U^{(1)}$ is a
pro-$p$ group carrying the *wild* ramification. The tame torus
$\mu_{q-1}$ is canonically isomorphic to the multiplicative group of the
residue field, and it is exactly the rank-one ($\mathrm{GL}(1)$)
Langlands datum: the object whose characters index unramified and tame
Hecke characters.

We take this residue torus as our fundamental invariant and study the
equivalence relation it induces. This is the abelian, tame shadow of full
anabelomorphy; it is the layer at which the theory is completely
tractable and admits sharp, unconditional theorems.

### 1.3 Summary of results

Let a *residue datum* be a pair $(p, f)$ with $p$ prime and $f \geq 1$,
modeling the residue characteristic and residue degree of a local field.
Its residue torus is $k^{\times}$ where $k$ is the finite field of order
$p^f$. Two residue data are *residue-anabelomorphic*, written
$D \sim D'$, when $k^{\times} \cong (k')^{\times}$ as abstract groups. We
prove:

1. **(Cardinality, §3.1)** $|k^{\times}| = p^f - 1$.
2. **(Equivalence, §3.2)** $\sim$ is an equivalence relation.
3. **(Rigidity, §4)** $D \sim D' \iff p = p'$ and $f = f'$.
4. **(Degree non-rigidity, §5)** There exist data of equal
   characteristic and equal total degree $e \cdot f$ that are *not*
   residue-anabelomorphic.

All four are established rigorously and constructively; §6 draws the
structural consequences and §7 lists concrete future directions.

---

## 2. Definitions

Throughout, $p$ denotes a prime and $f, f', e$ denote positive integers.
We write $k$ for a finite field and $k^{\times}$ for its multiplicative
group of nonzero elements.

**Definition 2.1 (Residue datum).** A *residue datum* is a pair
$D = (p, f)$ consisting of a prime number $p$ (the *residue
characteristic*) and a positive integer $f$ (the *residue degree*). We
write $p(D) = p$ and $f(D) = f$.

The datum $(p, f)$ models the local field $K$ whose residue field is the
finite field with $p^f$ elements. Recall the classical structure theorem
for finite fields: for every prime power $q = p^f$ there is, up to
isomorphism, a unique finite field $\mathbb{F}_q$ of order $q$, and every
finite field arises this way.

**Definition 2.2 (Residue field and residue torus).** The *residue field*
of $D = (p, f)$ is the finite field $k(D) = \mathbb{F}_{p^f}$ of order
$p^f$. The *residue torus* of $D$ is its multiplicative group
$$T(D) := k(D)^{\times} = \mathbb{F}_{p^f} \setminus \{0\},$$
a finite abelian group under multiplication.

**Definition 2.3 (Residue cardinality).** The *residue cardinality* of
$D = (p, f)$ is the order of its residue field,
$$q(D) := p^f.$$

**Definition 2.4 (Residue-anabelomorphic equivalence).** Two residue data
$D, D'$ are *residue-anabelomorphic*, written $D \sim D'$, when their
residue tori are isomorphic as abstract groups:
$$D \sim D' \quad:\Longleftrightarrow\quad T(D) \cong T(D').$$
Here $\cong$ denotes the existence of a group isomorphism (a bijection
respecting multiplication and inverses); the isomorphism is not part of
the data, only its existence.

**Remark 2.5.** Definition 2.4 is deliberately minimal: it asks for an
abstract group isomorphism, forgetting all field structure, all Galois
action, and all canonical identifications. It is precisely the
group-theoretic condition underlying any topological isomorphism of
absolute Galois groups restricted to the tame $\mathrm{GL}(1)$ layer, so
any necessary condition we derive for $\sim$ is a necessary condition for
full anabelomorphy at this layer.

---

## 3. Foundational structure

### 3.1 Cardinality of the residue torus

**Proposition 3.1 (Torus cardinality).** For every residue datum
$D = (p, f)$,
$$|T(D)| = p^f - 1.$$

*Proof.* The residue field $k(D)$ is finite of order $q = p^f$ by
Definition 2.3 and the classification of finite fields. A field element
is a unit (invertible under multiplication) if and only if it is nonzero;
hence $T(D) = k(D)^{\times}$ consists of all elements except $0$, and
$$|T(D)| = |k(D)| - 1 = p^f - 1. \qquad\blacksquare$$

**Proposition 3.2 (Cyclicity).** The residue torus $T(D)$ is a cyclic
group.

*Proof.* This is the classical theorem that the multiplicative group of
any finite field is cyclic: a finite subgroup of the multiplicative group
of a field is cyclic because for each $d$ the polynomial $x^d - 1$ has at
most $d$ roots, which forces the number of elements of each order to
match that of a cyclic group of the same size. $\qquad\blacksquare$

Propositions 3.1 and 3.2 together reduce the residue torus, up to
isomorphism, to the cyclic group $\mathbb{Z}/(p^f - 1)\mathbb{Z}$. This
is the single fact from which all subsequent rigidity flows: **the
isomorphism type of $T(D)$ is determined by, and determines, the single
integer $p^f - 1$.**

### 3.2 Equivalence relation

**Theorem 3.3 (Equivalence relation).** Residue-anabelomorphic
equivalence $\sim$ is an equivalence relation on residue data:

- *(Reflexivity)* $D \sim D$ for every $D$;
- *(Symmetry)* if $D \sim D'$ then $D' \sim D$;
- *(Transitivity)* if $D \sim D'$ and $D' \sim D''$ then $D \sim D''$.

*Proof.* Reflexivity: the identity map $T(D) \to T(D)$ is a group
isomorphism. Symmetry: if $\varphi : T(D) \to T(D')$ is a group
isomorphism, so is its inverse $\varphi^{-1} : T(D') \to T(D)$.
Transitivity: if $\varphi : T(D) \to T(D')$ and
$\psi : T(D') \to T(D'')$ are group isomorphisms, so is their
composite $\psi \circ \varphi : T(D) \to T(D'')$. Hence $\sim$ is
reflexive, symmetric, and transitive. $\qquad\blacksquare$

Theorem 3.3 legitimizes speaking of *residue-anabelomorphic classes* and
of $(p, f)$ as a class invariant; §4 shows the class invariant is exactly
$(p, f)$ itself.

---

## 4. The Rigidity Theorem

We now prove the main positive result: the abstract group $T(D)$ recovers
both arithmetic invariants of $D$.

### 4.1 An arithmetic lemma

The engine of rigidity is the uniqueness of prime-power factorization in
the following exponent-aware form.

**Lemma 4.1 (Prime-power rigidity).** Let $p, p'$ be primes and
$f, f' \geq 1$. If $p^f = p'^{f'}$ then $p = p'$ and $f = f'$.

*Proof.* The integer $N := p^f = p'^{f'}$ has, by unique factorization,
a single prime divisor on each side; since $p \mid N$ and $p' \mid N$ and
each of $p, p'$ is the only prime dividing $N$, we get $p = p'$. Cancelling
the common base, $p^f = p^{f'}$ with $p \geq 2$ forces $f = f'$ (the map
$n \mapsto p^n$ is strictly increasing). $\qquad\blacksquare$

We stress the *exponent-aware* nature of Lemma 4.1: it is genuinely
false to try to read the data off the torus size $p^f - 1$ directly. For
instance $2^2 - 1 = 3$ is itself prime and carries no visible trace of
its origin as $q - 1$; only after restoring $q = p^f$ can uniqueness be
applied. This "restore the prime power, then factor" step is the crux of
the proof below.

### 4.2 Isomorphism of finite cyclic groups

**Lemma 4.2 (Cyclic classification).** Two finite cyclic groups are
isomorphic if and only if they have the same order. More generally, for
the residue tori, $T(D) \cong T(D')$ if and only if
$|T(D)| = |T(D')|$.

*Proof.* Both tori are cyclic (Proposition 3.2). A cyclic group of order
$n$ is isomorphic to $\mathbb{Z}/n\mathbb{Z}$, and
$\mathbb{Z}/m\mathbb{Z} \cong \mathbb{Z}/n\mathbb{Z}$ if and only if
$m = n$ (an isomorphism is in particular a bijection, forcing equal
cardinalities; conversely equal cardinalities give the same standard
model). $\qquad\blacksquare$

### 4.3 Main theorem

**Theorem 4.3 (Rigidity Theorem).** For residue data
$D = (p, f)$ and $D' = (p', f')$,
$$D \sim D' \quad\Longleftrightarrow\quad p = p' \ \text{and}\ f = f'.$$

*Proof.*

($\Leftarrow$) If $p = p'$ and $f = f'$ then $D = D'$, whence $T(D) =
T(D')$ and the identity is an isomorphism; so $D \sim D'$.

($\Rightarrow$) Suppose $D \sim D'$, i.e. $T(D) \cong T(D')$. By Lemma
4.2 the tori have equal order, so by Proposition 3.1,
$$p^f - 1 = p'^{f'} - 1.$$
Adding $1$ to both sides (both $p^f$ and $p'^{f'}$ are at least $2$, so no
truncation issues arise) yields
$$p^f = p'^{f'}.$$
By Lemma 4.1, $p = p'$ and $f = f'$. $\qquad\blacksquare$

**Corollary 4.4 (Faithful invariant).** The assignment
$D \mapsto (p, f)$ is a *complete* invariant of residue-anabelomorphic
classes: two residue data are equivalent if and only if their invariants
coincide. Equivalently, each residue-anabelomorphic class is a
singleton $\{(p, f)\}$.

Corollary 4.4 is the precise sense in which the $\mathrm{GL}(1)$ residue
shadow is a *perfect fingerprint*: at this layer, anabelomorphy collapses
to literal equality of the residue characteristic and residue degree, and
no two distinct data are ever confused.

---

## 5. The Degree Non-Rigidity Theorem

Rigidity at the level of $(p, f)$ raises the question: is the *coarser*
data $(p, [K:\mathbb{Q}_p])$ — characteristic together with total field
degree — equally rigid? The answer is no, and the failure is exhibited by
the smallest possible witnesses.

### 5.1 Ramification and total degree

For a finite extension $K / \mathbb{Q}_p$ the total degree factors as
$$[K : \mathbb{Q}_p] = e \cdot f,$$
where $e$ is the *ramification index* (the stretching of the valuation)
and $f$ is the residue degree (the growth of the residue field). Two
extreme cases:

- $K$ is *unramified* when $e = 1$, so $[K:\mathbb{Q}_p] = f$; the residue
  field grows and the valuation is unchanged.
- $K$ is *totally ramified* when $f = 1$, so $[K:\mathbb{Q}_p] = e$; the
  valuation stretches and the residue field is unchanged.

Crucially, the residue torus depends *only* on $f$ (via $p^f - 1$), and
is completely insensitive to $e$.

### 5.2 The theorem

**Theorem 5.1 (Degree Non-Rigidity Theorem).** There exist local data of
equal residue characteristic and equal total degree that are *not*
residue-anabelomorphic. Explicitly, over $\mathbb{Q}_2$ consider:

- $K_1$, the *unramified* quadratic extension: $p = 2$, $(e, f) = (1, 2)$,
  total degree $e f = 2$, residue datum $D_1 = (2, 2)$;
- $K_2$, a *totally ramified* quadratic extension (e.g.
  $\mathbb{Q}_2(\sqrt 2)$): $p = 2$, $(e, f) = (2, 1)$, total degree
  $e f = 2$, residue datum $D_2 = (2, 1)$.

Then $[K_1 : \mathbb{Q}_2] = [K_2 : \mathbb{Q}_2] = 2$ and both have
residue characteristic $2$, yet
$$|T(D_1)| = 2^2 - 1 = 3, \qquad |T(D_2)| = 2^1 - 1 = 1,$$
so $T(D_1) \cong \mathbb{Z}/3\mathbb{Z}$ while $T(D_2)$ is trivial. These
groups are not isomorphic, hence $D_1 \not\sim D_2$.

*Proof.* Both fields have residue characteristic $2$ and total degree
$2$ by construction. By Proposition 3.1 the torus orders are $3$ and $1$
respectively. A group of order $3$ is not isomorphic to a group of order
$1$ (isomorphisms preserve cardinality); equivalently, by Theorem 4.3,
$D_1 \sim D_2$ would force $f_1 = f_2$, i.e. $2 = 1$, which is false.
Therefore $D_1 \not\sim D_2$. $\qquad\blacksquare$

**Remark 5.2 (Sharpness).** The witnesses are minimal: characteristic
$2$ is the smallest prime and total degree $2$ is the smallest degree
admitting two distinct factorizations $2 = 1 \cdot 2 = 2 \cdot 1$ with
differing $f$. The same construction runs for any prime $p$ and any
composite degree with two factorizations of differing residue part.

**Corollary 5.3 (Strict refinement).** Residue degree is a *strictly
finer* residue-anabelomorphic invariant than total field degree: knowing
$p$ and $e f$ is insufficient to determine the residue torus, whereas
knowing $p$ and $f$ determines it completely (Corollary 4.4).

---

## 6. Discussion

### 6.1 Localizing the reconstruction obstruction

Combining Theorems 4.3 and 5.1 gives a clean structural picture. Recall
the decomposition
$$K^{\times} \;\cong\; \mathbb{Z} \times \mu_{p^f - 1} \times U^{(1)}.$$
Theorem 4.3 says the tame factor $\mu_{p^f - 1}$ — the residue torus —
determines $(p, f)$ *exactly*. Theorem 5.1 says total degree is not
recovered from this factor, because the missing datum is the ramification
index $e$, which lives *entirely* in the wild pro-$p$ factor $U^{(1)}$.

Thus the tame layer is completely rigid, and any residual ambiguity in
reconstructing a local field from its multiplicative group data is
*confined to the wild part*. This is a concrete, quantitative version of
the folklore principle that "the tame part is easy, the wild part is
hard": here the tame part is not merely easy but *perfectly rigid*, so
the wild pro-$p$ filtration becomes the sole carrier of the remaining
ramification information.

### 6.2 The role of the "minus one"

A recurring technical point deserves emphasis. The invariant that the
group *literally is* has size $p^f - 1$, but the invariant that is
*rigid* is $p^f$. The passage from $p^f - 1$ back to $p^f$ — trivial
arithmetically, essential logically — is what converts an opaque integer
(which may be prime, or highly composite, with no visible prime-power
structure) into one to which unique factorization applies. This is a
small but instructive example of a general phenomenon: the "right"
invariant for a rigidity statement is often a mild transform of the one
handed to you by the group.

### 6.3 Relation to L-functions and Langlands data

The characters of the residue torus index the unramified and tame local
$L$-factors attached to $K$. Since Theorem 4.3 shows the torus is a
complete invariant of $(p, f)$, the multiset of these $L$-factors is a
residue-anabelomorphic invariant, and — by Corollary 4.4 — a *complete*
one at the $\mathrm{GL}(1)$ layer. This is the anchor for the L-factor
reconstruction program sketched in §7.

---

## 7. Future directions

The following program extends the rank-one, tame results above.

**7.1 Wild anabelomorphy.** The multiplicative group of a local field
splits into an unramified line, a tame cyclic torus, and a pro-$p$ factor
carrying wild ramification. This paper shows the tame factor is rigid, so
any remaining ambiguity in reconstructing the field from group data is
concentrated in the pro-$p$ part. The program is to classify precisely
which invariants — absolute ramification index, different, higher
ramification breaks — are forced by a topological isomorphism of the
pro-$p$ unit groups, and which can be traded. The key insight is that the
residue torus detects the residue degree but is blind to ramification, so
the entire reconstruction obstruction lives in the pro-$p$ filtration.

**7.2 Anabelomorphic invariance of unramified L-factors.** Each tame
character contributes a local $L$-factor governed by the residue-field
size, and the number of tame characters of order dividing a given integer
$n$ is $\gcd(n, p^f - 1)$. The conjecture is that the entire multiset of
local $L$-factors, and the zeta zeros they induce, is preserved by
residue-anabelomorphic equivalence and conversely reconstructs the
residue-field size. The function $n \mapsto \gcd(n, p^f - 1)$ is a
complete fingerprint of the residue-field size, so $L$-factor data and
anabelomorphic data are two encodings of the same information.

**7.3 Higher-rank Langlands stacks.** The rank-one story identifies the
residue torus and counts its characters. The escalation to $\mathrm{GL}(n)$
replaces the single cyclic count by a polynomial in the residue-field
size counting semisimple conjugacy classes, and more finely by the mass
of a moduli stack of bundles. The conjecture is that these polynomials
are residue-anabelomorphic invariants and, for suitable ranks, complete
ones.

**7.4 Global assembly.** Assemble the local invariants across all places
of a number field and ask which global arithmetic is recovered by the
collection of local residue tori — a tame, abelian analogue of global
anabelian reconstruction.

**7.5 Effective bounds.** Quantify non-rigidity: for fixed $p$ and total
degree $N$, count the number of residue-anabelomorphic classes realizable
by extensions of degree $N$, as a function of the divisor structure of
$N$.

---

## 8. Conclusion

We have given a complete, self-contained treatment of the abelian
$\mathrm{GL}(1)$ residue layer of anabelomorphy. The residue torus is a
finite cyclic group of order $p^f - 1$; residue-anabelomorphic
equivalence is an equivalence relation; and its class invariant is
*exactly* the pair $(p, f)$ — the group determines both the residue
characteristic and the residue degree and nothing is lost (Rigidity
Theorem). Yet the coarser data of characteristic-plus-total-degree is
*not* rigid, because ramification can be traded against residue degree
(Degree Non-Rigidity Theorem). Together these results pin down the tame
layer completely and localize all remaining reconstruction difficulty in
the wild pro-$p$ part, charting a precise path for the higher and wilder
extensions listed above.
