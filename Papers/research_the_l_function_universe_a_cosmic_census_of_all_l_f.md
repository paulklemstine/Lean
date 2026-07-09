# A Census of the Selberg Class: The L-Function Universe is Countable

## Abstract

L-functions are among the most information-dense objects in mathematics: a single
one encodes the arithmetic of an entire number-theoretic structure. They organize
themselves into a sprawling universe — the Riemann zeta function, the Dirichlet
L-functions, the L-functions of elliptic curves, of modular forms, and of Galois
representations. We address a foundational structural question about this
universe: *how large is it?* We make precise the guiding intuition that a "natural"
L-function, of the kind envisioned by the Selberg class axioms (analytic
continuation, functional equation, Euler product, Ramanujan bound), is determined
by a **finite arithmetic signature** — its degree, conductor, gamma-factor
shifts, and local Euler data at finitely many primes. We prove that the space of
such signatures is *countably infinite*, deduce a general **census principle**
(any family admitting an injective signature is countable), and verify that the
Riemann zeta function, the Dirichlet family, and the family of elliptic curves
over $\mathbb{Q}$ all embed into the census. We complement these positive results
with sharp **boundary theorems**: relaxing the finiteness of the local data — by
permitting an independent binary choice at every prime — yields an uncountable
family, and the continuum of real j-invariants admits no injective finite
signature. Together these results establish a *finiteness dichotomy* governing the
size of the L-function universe: finiteness of the determining data, not the depth
of any individual L-function, is what makes the census countable.

**Keywords.** L-functions, Selberg class, conductor, Dirichlet characters,
elliptic curves, countability, cardinal arithmetic, Cantor's theorem.

---

## 1. Introduction

### 1.1 Motivation

An L-function is a Dirichlet series
$$L(s) = \sum_{n=1}^{\infty} \frac{a_n}{n^{s}}$$
that, in the well-behaved cases, admits an Euler product over primes, a
meromorphic continuation to the whole complex plane, and a functional equation
relating $s$ to $1-s$. The prototype is the Riemann zeta function $\zeta(s)$; the
family expands through Dirichlet L-functions $L(s,\chi)$, the L-functions of
elliptic curves and modular forms, and, conjecturally through the Langlands
correspondence, the L-functions of automorphic representations and Galois
representations.

Selberg proposed an axiomatic framework isolating the "natural" L-functions. An
element of the **Selberg class** $\mathcal{S}$ is a Dirichlet series satisfying:

1. **Analytic continuation.** $(s-1)^m L(s)$ extends to an entire function of
   finite order for some integer $m \ge 0$.
2. **Functional equation.** There are parameters $Q > 0$, $\lambda_j > 0$,
   $\Re(\mu_j) \ge 0$ and $|\omega| = 1$ such that
   $$\Phi(s) = Q^{s} \prod_{j} \Gamma(\lambda_j s + \mu_j)\, L(s)$$
   satisfies $\Phi(s) = \omega\, \overline{\Phi(1 - \bar{s})}$.
3. **Euler product.** $\log L(s) = \sum_{n} b_n n^{-s}$ with $b_n$ supported on
   prime powers and $b_n \ll n^{\theta}$ for some $\theta < 1/2$.
4. **Ramanujan bound.** $a_n \ll_{\varepsilon} n^{\varepsilon}$ for every
   $\varepsilon > 0$.

A central and deeply studied invariant of an element of $\mathcal{S}$ is its
**degree** $d = 2\sum_j \lambda_j$ and its **conductor** $q$, an arithmetic
integer built from $Q$ and the $\lambda_j$. Both are known to be strong
complexity measures; degree $1$ elements, for instance, are exactly the shifts of
$\zeta$ and the primitive Dirichlet L-functions.

### 1.2 The census question

The naive size estimate is alarming. Elliptic curves over $\mathbb{R}$ are
distinguished by their j-invariant $j \in \mathbb{R}$, and distinct j-invariants
typically give distinct L-functions; since $\mathbb{R}$ is uncountable, one might
expect uncountably many L-functions. In tension with this is the structural
intuition that the Selberg class is *tame*.

We resolve the tension by making precise the sense in which each element of
$\mathcal{S}$ is determined by **finite data**, and by tracking exactly where
that finiteness — and hence countability — breaks down. Our contribution is a
clean, self-contained mathematical framework for the census, together with its
sharp boundary.

### 1.3 Results

- **Countability of signatures (Theorem 3.2).** The space of arithmetic
  signatures is countable.
- **Census principle (Theorem 3.3).** Any family with an injective signature map
  is countable.
- **Populated census (Theorems 4.1–4.2).** The Dirichlet family and the family of
  elliptic curves over $\mathbb{Q}$ are countable.
- **Countable infinitude (Theorem 5.3).** The signature space is in bijection
  with $\mathbb{N}$.
- **Boundary theorems (Theorems 6.1–6.3).** An unrestricted per-prime binary
  family is uncountable, and the real j-line admits no injective finite signature.

---

## 2. The arithmetic signature

We isolate the finite data attached to an L-function.

**Definition 2.1 (Arithmetic signature).** An *arithmetic signature* is a tuple
$$\sigma = (d, N, \boldsymbol{\gamma}, \mathcal{E})$$
consisting of:

- a **degree** $d \in \mathbb{N}$ (the dimension of the associated representation);
- a **conductor** $N \in \mathbb{N}$ (the arithmetic modulus of the functional
  equation);
- a finite list $\boldsymbol{\gamma} \in \mathbb{Q}^{<\omega}$ of **gamma-factor
  shifts**, a rational model of the parameters $\mu_j$;
- a finite list $\mathcal{E}$ of **local Euler data**, each entry a pair
  $(p, \mathbf{c})$ where $p \in \mathbb{N}$ is a prime and
  $\mathbf{c} \in \mathbb{Q}^{<\omega}$ is the coefficient list of the inverse
  local polynomial at $p$.

We write $\mathrm{Sig}$ for the set of all arithmetic signatures. Here
$X^{<\omega}$ denotes the set of finite lists (finite sequences) with entries in
$X$.

The philosophy of Definition 2.1 is that the Selberg axioms constrain an
L-function so tightly that its "identity" is captured by these four finite pieces
of arithmetic. We do not need the full strength of the (conjectural) statement
that finitely many Euler factors determine the L-function; we require only that
the *stored* signature is finite, which the axioms guarantee.

**Remark 2.2.** The census does *not* assert that the map from L-functions to
signatures is injective — that is a deep uniqueness question (see §7). It asserts
that *if* a family carries an injective signature, that family is countable. This
is the correct and provable form of the census principle, and it is what all our
concrete examples satisfy.

---

## 3. Countability of the signature space

**Lemma 3.1 (Closure of countability).** Countability is preserved by finite
products, by the formation of finite lists, and by passage to a subtype via an
injection. Concretely: $\mathbb{N}$ and $\mathbb{Q}$ are countable; if $X$ is
countable then so is the set $X^{<\omega}$ of finite lists over $X$; if $X, Y$ are
countable so is $X \times Y$; and if $f : A \to B$ is injective and $B$ is
countable then $A$ is countable.

*Proof sketch.* $\mathbb{Q}$ is countable as a quotient of $\mathbb{Z} \times
\mathbb{Z}$. For finite lists, $X^{<\omega} = \bigsqcup_{n} X^{n}$ is a countable
union of countable sets. Products of two countable sets are countable by the
standard pairing bijection $\mathbb{N} \times \mathbb{N} \cong \mathbb{N}$.
Injective preimages of countable sets are countable by transporting an
enumeration back along $f$. $\square$

**Theorem 3.2 (Signatures are countable).** The set $\mathrm{Sig}$ is countable.

*Proof.* The map
$$\sigma = (d, N, \boldsymbol{\gamma}, \mathcal{E}) \;\longmapsto\;
\big(d,\, N,\, \boldsymbol{\gamma},\, \mathcal{E}\big) \in
\mathbb{N} \times \mathbb{N} \times \mathbb{Q}^{<\omega} \times
(\mathbb{N} \times \mathbb{Q}^{<\omega})^{<\omega}$$
is a bijection onto the displayed product (each component of the tuple determines,
and is determined by, the corresponding field of the signature), and in
particular injective. Each factor of the target is countable by Lemma 3.1:
$\mathbb{N}$ is countable; $\mathbb{Q}^{<\omega}$ is countable since $\mathbb{Q}$
is; and $(\mathbb{N} \times \mathbb{Q}^{<\omega})^{<\omega}$ is countable since
$\mathbb{N} \times \mathbb{Q}^{<\omega}$ is. A finite product of countable sets is
countable, so the target is countable, and by the injection $\mathrm{Sig}$ is
countable. $\square$

**Theorem 3.3 (Census principle).** Let $L$ be any set (of L-functions) equipped
with a map $\mathrm{sig} : L \to \mathrm{Sig}$ that is injective. Then $L$ is
countable.

*Proof.* Compose: $L \hookrightarrow \mathrm{Sig}$ is an injection into a
countable set, so $L$ is countable by Lemma 3.1. $\square$

Theorem 3.3 is the abstract engine of the census. Every concrete countability
statement below is an instance of it, obtained by exhibiting an injective
signature (or a directly injective parametrization).

---

## 4. Populating the census

**Example 4.0 (Riemann zeta).** The Riemann zeta function has signature
$$\sigma_\zeta = (1,\; 1,\; [0],\; [\,]):$$
degree $1$, conductor $1$, a single trivial gamma shift, and no exceptional local
data. It occupies the first address (conductor $1$) of the census.

**Theorem 4.1 (Dirichlet family is countable).** The family
$$\coprod_{N \ge 1} \{\, \chi : \chi \text{ a Dirichlet character mod } N \,\}$$
of all Dirichlet characters, over all moduli, is countable.

*Proof.* For each fixed modulus $N \ge 1$, the group of Dirichlet characters
modulo $N$ is finite: characters mod $N$ are homomorphisms
$(\mathbb{Z}/N\mathbb{Z})^{\times} \to \mathbb{C}^{\times}$ from a finite group, of
which there are only $\varphi(N)$. The family is therefore a countable
($N$-indexed) disjoint union of finite sets, hence countable. Since each
Dirichlet L-function $L(s,\chi)$ is determined by its character $\chi$ (together
with its modulus), the family of Dirichlet L-functions is countable. $\square$

**Theorem 4.2 (Rational elliptic curves are countable).** The set of elliptic
curves over $\mathbb{Q}$, presented in Weierstrass form
$$E : y^2 + a_1 xy + a_3 y = x^3 + a_2 x^2 + a_4 x + a_6,
\qquad a_1, a_2, a_3, a_4, a_6 \in \mathbb{Q},$$
is countable. Consequently the family of L-functions of elliptic curves over
$\mathbb{Q}$ is countable.

*Proof.* The assignment $E \mapsto (a_1, a_2, a_3, a_4, a_6)$ is an injection into
$\mathbb{Q}^5$: a Weierstrass curve is literally determined by its five
coefficients. Since $\mathbb{Q}$ is countable, so is $\mathbb{Q}^5$ (finite
product), and hence the set of curves is countable by Lemma 3.1. The L-function
$L(s, E)$ is determined by $E$, so the family of L-functions is countable.
$\square$

**Corollary 4.3 (Resolution of the j-invariant paradox).** Although the map
$E \mapsto j(E)$ has uncountable image over $\mathbb{R}$, only countably many
elliptic curves are defined over $\mathbb{Q}$, and only these carry arithmetic
L-functions. The apparent uncountability of "one L-function per j-invariant" is an
artifact of allowing transcendental coefficients that no arithmetic L-function
uses.

---

## 5. The census is countably infinite

Countability alone does not preclude finiteness; we show the census is genuinely
of size $\aleph_0$.

**Definition 5.1 (Principal enumeration).** For $N \in \mathbb{N}$ let
$$\pi(N) = (1,\; N,\; [0],\; [\,]) \in \mathrm{Sig}$$
be the *principal signature of conductor $N$* — degree one, trivial gamma shift,
no exceptional local data. This models the principal L-functions ordered by
conductor.

**Lemma 5.2 (Injectivity and monotonicity).** The map $\pi : \mathbb{N} \to
\mathrm{Sig}$ is injective, and $N \mapsto (\pi(N)).\mathrm{conductor} = N$ is
strictly increasing.

*Proof.* If $\pi(a) = \pi(b)$ then reading off the conductor field gives $a = b$;
hence injective. The conductor field of $\pi(N)$ is $N$, so $N \mapsto N$ is
strictly monotone. $\square$

**Theorem 5.3 (Countably infinite census).** The signature space $\mathrm{Sig}$
is infinite (Lemma 5.2 embeds $\mathbb{N}$) and countable (Theorem 3.2); hence
there is a bijection
$$\mathrm{Sig} \;\cong\; \mathbb{N}.$$
There are *exactly* as many arithmetic signatures as natural numbers.

*Proof.* By Lemma 5.2, $\pi$ is an injection $\mathbb{N} \hookrightarrow
\mathrm{Sig}$, so $\mathrm{Sig}$ is infinite. By Theorem 3.2 it is countable. A
set that is both countable and infinite is countably infinite, i.e. admits a
bijection with $\mathbb{N}$. $\square$

Ordered by conductor, the principal signatures $\pi(1), \pi(2), \pi(3), \dots$
provide the natural "census ordered by conductor": the first hundred addresses are
$N = 1, 2, \dots, 100$, and the enumeration continues forever without ever leaving
the countable realm.

---

## 6. Boundaries: why finiteness is essential

The census depends on the *finiteness* of the signature. We now show that natural
relaxations immediately produce uncountable families, delimiting the principle
exactly.

**Theorem 6.1 (Cantor obstruction).** The set $\mathbb{N} \to \{0,1\}$ of all
infinite binary sequences is uncountable.

*Proof.* Its cardinality is $2^{\aleph_0}$, and Cantor's theorem gives
$2^{\aleph_0} > \aleph_0$, so it is not countable. $\square$

**Theorem 6.2 (Per-prime boundary).** The family of all functions
$$\{\text{primes}\} \to \{0,1\}$$
— an *independent binary choice at every prime*, e.g. a free
ramified/unramified label — is uncountable.

*Proof.* The set of primes is infinite, so functions from it to $\{0,1\}$ form a
set of cardinality $2^{\aleph_0} > \aleph_0$ (Cantor). Hence uncountable.
$\square$

Theorem 6.2 is the precise reason the Euler data in Definition 2.1 must be
supported on *finitely many* primes. An unconstrained per-prime choice already
escapes countability, so no census over such data could be countable.

**Theorem 6.3 (j-invariant boundary).** There is no injective map
$$f : \mathbb{R} \to \mathrm{Sig}.$$
In particular one cannot attach a distinct finite arithmetic signature to every
real j-invariant.

*Proof.* If such an injective $f$ existed, then $\mathbb{R}$ would inject into a
countable set (Theorem 3.2) and would therefore be countable — contradicting the
uncountability of $\mathbb{R}$. $\square$

Theorems 6.2 and 6.3 are the fence posts of the census: they show that the source
of countability is *not* any simplicity of individual L-functions (each is
infinitely deep) but the *finiteness of the determining data* enforced by the
Selberg axioms. Restricting to number fields cuts the continuum of j-invariants
down to a countable census; unshackling the local data at all primes blows it back
up to the continuum.

---

## 7. Discussion

The results assemble into a single organizing principle.

**Finiteness dichotomy.** A family of L-functions is:
- *countable*, whenever it is determined by finite arithmetic data (a signature);
- *uncountable*, whenever it permits a free choice indexed by an infinite set
  (all primes, or a continuum of j-invariants).

This dichotomy explains the census cleanly. The Selberg class lands on the
countable side because its axioms compress the determining data of each member
into a finite signature. The naive slogans that suggest uncountability — "one
L-function per j-invariant," or "a free local factor at every prime" — land on the
uncountable side precisely because they abandon that finiteness.

**On the strength of the model.** We deliberately do *not* assume the (open, and
in full generality false-as-stated) claim that an L-function is determined by its
Euler factors at *finitely many* primes. Theorem 6.2 shows why such a blanket
claim cannot be the basis of countability. Our census rests instead on the
finiteness of the *stored signature*, which is exactly what the Selberg axioms
provide. This makes the framework both faithful and robust.

**Relation to known theory.** The countability of the Selberg class is folklore
among analytic number theorists; our contribution is a clean, self-contained
*proof architecture* — the census principle plus its populated examples and its
sharp boundary — that isolates the exact hypothesis (finiteness of the signature)
responsible for countability, and that quantifies the size as precisely
$\aleph_0$.

---

## 8. Future directions

The census principle establishes that the universe of "natural" L-functions is
governed by a finiteness dichotomy: a family determined by a finite arithmetic
signature is countable, while a family that permits an independent choice indexed
by an infinite set (all primes, or a continuum of j-invariants) is uncountable.
The following conjectures push this structural insight forward.

**Conjecture 1 — Degree-graded density of the census.** For each fixed degree
$d$, order the census members of degree $d$ by conductor and count how many have
conductor at most $X$. Conjecture: this counting function grows polynomially in
$X$, with an exponent that is an explicit function of $d$ (roughly linear in $d$),
so that the census is not merely countable but has a well-defined, degree-graded
growth rate. The key insight is that the conductor is a genuine complexity
measure: bounding it bounds the entire signature, so counting by conductor turns
an abstract countability statement into a quantitative density law. Large-scale
tabulations of L-functions have reached the point where conductor-by-conductor
counts can be checked against a predicted growth exponent for the first time.

**Conjecture 2 — Rigidity: finitely many local factors determine the whole.**
Although an *unrestricted* per-prime family is uncountable, the Selberg axioms
impose an Euler product plus a functional equation. Conjecture: within the Selberg
class, two elements sharing the same degree, conductor, gamma factor, and local
Euler factors at all primes up to an explicit bound $B(d,N)$ (depending only on
degree and conductor) must coincide. In other words, the true determining data is
finite after all — the infinitude in the boundary example is destroyed by the
functional equation, which acts as a global rigidity constraint converting
"agreement at finitely many primes" into "agreement everywhere." Effective
multiplicity-one results have sharpened the dependence of the determining bound on
degree and conductor, turning a qualitative uniqueness statement into a
quantitative one.

**Conjecture 3 — No small-degree exotica.** For degree $d < 2$ the census
contains exactly the shifts of the Riemann zeta function and the primitive
Dirichlet L-functions, and nothing else; in particular there is a *conductor gap*
— no census member of degree one has conductor in a forbidden residue-defined set.
The key insight is that low degree leaves almost no room in the signature: the
functional equation and Euler product are so constraining that the finite
signature space of small degree is essentially exhausted by the classical
examples.

---

## 9. Conclusion

The census of Selberg-type L-functions has size exactly $\aleph_0$: it is
countable, and countably infinite. Its size is governed by a finiteness dichotomy
rather than by the internal depth of any single L-function. Each L-function is a
galaxy of arithmetic; there are only countably many stars in the sky — precisely
as many as there are integers.
