# Polynomial Secret Sharing and Verifiable Variants: Reconstruction, Information-Theoretic Privacy, and the Binding–Hiding Duality

**Author:** Aristotle
**Date:** 2026-06-26
**Domain:** Cryptography (with bridges to Algebra and Linear Algebra)

## Abstract

We present a unified, fully formal treatment of polynomial secret sharing and
its two canonical verifiable variants. Working over an arbitrary field $F$, we
prove that Shamir's $(t,n)$ secret sharing scheme satisfies two dual guarantees
that are, at bottom, the same statement about the evaluation map on polynomials
of bounded degree. First, **reconstruction**: any $t$ distinct shares determine
the degree-$(<t)$ sharing polynomial uniquely, so the reconstruction threshold
equals the polynomial degree plus one. Second, **information-theoretic
privacy**: any $t-1$ shares are consistent with every secret in exactly one way,
so a sub-threshold coalition learns nothing. We make reconstruction
*constructive* via the explicit Lagrange formula with node-only weights summing
to one, and we derive the additive and multiplicative homomorphisms that make
Shamir sharing the linear backbone of secure multiparty computation. We then
formalize two verifiable secret sharing schemes. **Feldman's VSS** is shown to be
complete, sound (cheating dealers are caught: a share verifies iff it equals the
committed evaluation), and perfectly **binding**. **Pedersen's VSS** is shown to
be complete, homomorphic, and perfectly **hiding** — its commitments leak zero
information about the sharing polynomial — together with the dual property of
**equivocation**. The binding of Feldman and the hiding of Pedersen are exhibited
as the injectivity and surjectivity, respectively, of a single commitment map,
making precise the binding–hiding duality of commitment-based VSS. All results
are machine-checked.

## 1. Introduction

Secret sharing, introduced independently by Shamir and Blakley in 1979, is the
problem of splitting a secret $c$ among $n$ participants so that any authorized
subset can reconstruct $c$ while any unauthorized subset learns nothing. In the
$(t,n)$-threshold case, authorized subsets are exactly those of size at least
$t$. Shamir's construction is disarmingly simple: encode the secret as the
constant term of a random polynomial of degree less than $t$ and distribute
evaluations of that polynomial as shares.

The scheme's two pillars — perfect reconstruction at the threshold and perfect
secrecy below it — are two readings of one classical algebraic fact: the
evaluation map sending a polynomial of degree $<t$ to its values at $t$ fixed
distinct nodes is a bijection. This paper develops that observation into a
rigorous, self-contained account, and then layers on **verifiability**, the
property that protects against a malicious *dealer* who distributes inconsistent
shares.

Two commitment-based verifiable secret sharing (VSS) schemes occupy opposite
ends of a fundamental trade-off. Feldman's scheme commits to each polynomial
coefficient as $C_j = a_j \cdot g$ in a group where discrete logarithms are hard;
it binds the dealer perfectly to a single polynomial but hides the secret only
computationally. Pedersen's scheme uses two generators and a random blinding
polynomial, $C_j = a_j\cdot g + a'_j\cdot h$; it hides the secret perfectly but
binds only computationally. We prove the formal cores of both, and we present the
binding of Feldman and the hiding of Pedersen as the two complementary halves of
a single algebraic dichotomy.

Throughout, we follow the additive-group convention common in formalized
cryptography: a prime-order cyclic group is modeled as (the additive group of) a
field $F$ with fixed generators, and group exponentiation $g^a$ is rendered as
the scalar multiple $a \cdot g$.

## 2. Preliminaries and definitions

Let $F$ be a field and let $F[X]$ denote the ring of univariate polynomials over
$F$. For $f \in F[X]$ we write $f.\mathrm{coeff}\,j$ for the coefficient of
$X^j$, $\deg f$ for the degree, $\mathrm{natDegree}\,f$ for the natural-number
degree, and $f(x)$ (or `f.eval x`) for evaluation at $x \in F$.

**Definition 1 (Sharing polynomial and secret).** A *sharing polynomial* for
threshold $t$ is a polynomial $f \in F[X]$ with $\deg f < t$. Its *secret* is the
constant term $f(0) = f.\mathrm{coeff}\,0$.

**Definition 2 (Shares).** Given distinct nonzero evaluation nodes
$x_1, \dots, x_n \in F$, the *share* of participant $i$ is $f(x_i)$.

For the constructive reconstruction theory we use the Lagrange interpolation
framework over an index set. Let $s$ be a finite set of participant indices and
$v : \iota \to F$ an evaluation-node map that is injective on $s$, with $v\,i \ne 0$.

**Definition 3 (Lagrange basis and reconstruction coefficient).** The *Lagrange
basis polynomial* $\mathrm{basis}_s^v(i)$ is the unique polynomial of degree
$< \#s$ satisfying $\mathrm{basis}_s^v(i)(v\,j) = \delta_{ij}$ for $j \in s$. The
*reconstruction coefficient* of participant $i$ is

$$\mathrm{lagrangeCoeff}(s, v, i) \;=\; \mathrm{basis}_s^v(i)(0),$$

a quantity depending only on the nodes, not on the sharing polynomial.

For the verifiable schemes we fix generators in $F$.

**Definition 4 (Feldman commitment).** For a generator $g \in F$ and sharing
polynomial $f$, the $j$-th *Feldman commitment* is
$\mathrm{feldmanCommit}(g, f, j) = (f.\mathrm{coeff}\,j)\cdot g$.

**Definition 5 (Feldman verification).** A claimed share value $s$ at point $x$
*verifies* against published commitments $C : \mathbb{N} \to F$ with threshold
$t$ iff $\mathrm{FeldmanVerifies}(g, t, C, x, s)$ holds, where

$$\mathrm{FeldmanVerifies}(g, t, C, x, s) \;:\Longleftrightarrow\; s \cdot g = \sum_{j=0}^{t-1} x^j \, C_j.$$

**Definition 6 (Pedersen commitment).** For generators $g, h \in F$, sharing
polynomial $f$, and blinding polynomial $f'$, the $j$-th *Pedersen commitment* is

$$\mathrm{pedersenCommit}(g, h, f, f', j) \;=\; (f.\mathrm{coeff}\,j)\cdot g + (f'.\mathrm{coeff}\,j)\cdot h.$$

**Definition 7 (Pedersen verification).** A claimed share pair $(s, s')$ at point
$x$ *verifies* iff

$$\mathrm{PedersenVerifies}(g, h, t, C, x, s, s') \;:\Longleftrightarrow\; s\cdot g + s'\cdot h = \sum_{j=0}^{t-1} x^j\, C_j.$$

## 3. Reconstruction: threshold equals degree plus one

The reconstruction guarantee is a uniqueness statement about low-degree
polynomials.

**Theorem 1 (`shamir_reconstruction`).** Let $t \in \mathbb{N}$, let $s \subseteq F$
be a finite set with $\#s = t$, and let $f, g \in F[X]$ with $\deg f < t$ and
$\deg g < t$. If $f(x) = g(x)$ for all $x \in s$, then $f = g$.

*Proof sketch.* Consider $f - g$. By the triangle inequality for polynomial
degree, $\deg(f - g) \le \max(\deg f, \deg g) < t = \#s$. But $f - g$ vanishes on
all $\#s = t$ points of $s$. A nonzero polynomial of degree $< t$ can have at
most $t-1$ roots, so $f - g$ must be the zero polynomial; hence $f = g$. (In the
formalization this is `Polynomial.eq_of_degree_sub_lt_of_eval_finset_eq` after
rewriting the degree bounds through $\#s = t$.) $\qquad\blacksquare$

**Corollary 1 (`shamir_secret_recovered`).** Under the hypotheses of Theorem 1,
$f(0) = g(0)$.

*Proof.* Immediate from $f = g$ by evaluating at $0$. $\qquad\blacksquare$

Theorem 1 is the precise sense in which *the reconstruction threshold equals the
degree plus one*: a degree-$(t-1)$ polynomial is determined by exactly
$t = (t-1)+1$ values, and Corollary 1 says the secret is among the determined
data. Equivalently, two parties holding $t$ consistent shares must agree on the
secret.

Uniqueness is non-constructive. The constructive companion is Lagrange
interpolation.

**Theorem 9 (`shamir_reconstruct_at`).** Let $v$ be injective on the finite index
set $s$ and let $f \in F[X]$ with $\deg f < \#s$. Then for every $z \in F$,

$$f(z) = \sum_{i \in s} f(v\,i)\, \mathrm{basis}_s^v(i)(z).$$

*Proof sketch.* Both sides are polynomials in $z$ of degree $< \#s$ that agree at
the $\#s$ nodes $\{v\,i : i \in s\}$ (the right-hand side evaluates to $f(v\,j)$
at $z = v\,j$ because $\mathrm{basis}_s^v(i)(v\,j) = \delta_{ij}$). By the
uniqueness principle (Theorem 1 in spirit), the two polynomials coincide.
$\qquad\blacksquare$

Specializing to $z = 0$ gives the operational reconstruction algorithm.

**Theorem 10 (`shamir_explicit_reconstruction`).** Under the hypotheses of
Theorem 9,

$$f(0) = \sum_{i \in s} f(v\,i)\, \mathrm{lagrangeCoeff}(s, v, i).$$

*Proof.* Set $z = 0$ in Theorem 9 and use Definition 3. $\qquad\blacksquare$

Theorem 10 exhibits the secret as a *fixed linear functional* of the shares: the
weights $\mathrm{lagrangeCoeff}(s,v,i)$ depend only on the nodes, so the same
recipe recovers the secret of every polynomial shared on those nodes. The weights
satisfy a normalization identity.

**Lemma 1 (`sum_lagrangeCoeff_eq_one`).** For a nonempty index set $s$ on which
$v$ is injective, $\sum_{i \in s} \mathrm{lagrangeCoeff}(s, v, i) = 1$.

*Proof sketch.* Apply Theorem 9 to the constant polynomial $f \equiv 1$ (degree
$0 < \#s$): the left side is $1$ and each share value $f(v\,i)$ equals $1$, so the
right side at $z = 0$ is $\sum_i \mathrm{lagrangeCoeff}(s,v,i)$. $\qquad\blacksquare$

Lemma 1 says reconstruction is an *affine* (indeed, when weights are
nonnegative, convex-like) combination of the shares — the algebraic analogue of a
weighted average.

## 4. Information-theoretic privacy below threshold

We now prove that a coalition holding $t-1$ shares learns nothing about the
secret. The statement is an existence-and-uniqueness claim, per candidate secret.

**Theorem 2 (`shamir_privacy`).** Let $t \ge 1$, let $s \subseteq F$ with
$0 \notin s$ and $\#s = t-1$, let $y : F \to F$ record the observed shares, and
let $c \in F$ be any candidate secret. Then there exists a *unique* $f \in F[X]$
with

$$\deg f < t, \qquad f(0) = c, \qquad \text{and} \qquad f(x) = y(x)\ \text{for all } x \in s.$$

*Proof sketch.* Consider the augmented node set $s^+ = \{0\} \cup s$, which has
$\#s^+ = t$ because $0 \notin s$. Define target values on $s^+$ by assigning $c$
to the node $0$ and $y(x)$ to each $x \in s$. By Lagrange interpolation there is a
polynomial $f$ of degree $< t$ hitting all $t$ targets; this $f$ witnesses
existence. For uniqueness, any two solutions agree on the $t$ points of $s^+$
(they share the value $c$ at $0$ and the values $y(x)$ on $s$) and both have
degree $< t$, so Theorem 1 forces them equal. (The formalization constructs the
interpolant explicitly by induction on $s$, then adjusts the constant term to
hit $c$ at $0$, and closes uniqueness with `shamir_reconstruction`.) $\qquad\blacksquare$

The interpretation is the crux of information-theoretic security. For *every*
secret $c$ there is *exactly one* sharing polynomial consistent with the
coalition's view. The map (candidate secret) $\mapsto$ (consistent polynomial) is
therefore a bijection, so the coalition's $t-1$ shares are equally compatible
with every secret, each in exactly one way. No statistical test on the observed
shares can favor one secret over another: the shares carry zero information about
$c$. The contrapositive packages this as explicit ambiguity.

**Corollary 2 (`shamir_insufficient`).** Under the hypotheses of Theorem 2, for
any two distinct secrets $c_1 \ne c_2$ there exist $f, g \in F[X]$ with
$\deg f < t$, $\deg g < t$, $f(x) = g(x) = y(x)$ for all $x \in s$,
$f(0) = c_1$, $g(0) = c_2$, and $f \ne g$.

*Proof.* Instantiate Theorem 2 at $c_1$ and at $c_2$ to obtain witnesses $f$ and
$g$; they differ because their constant terms $c_1 \ne c_2$ differ. $\qquad\blacksquare$

Theorems 1 and 2 together expose the threshold as a sharp phase transition.
Abstractly, the evaluation map $E_k : \{f : \deg f < t\} \to F^k$ sending a
polynomial to its values on $k$ fixed distinct nodes is *injective* for $k \ge t$
(Theorem 1) and, once the secret node is included, *bijective at $k = t$* and
*surjective with uniform fibers at $k = t-1$* (Theorem 2). Security and
reconstruction are the same bijection read at adjacent cardinalities.

## 5. Linear homomorphism and secure computation

Because reconstruction is a fixed linear functional of the shares (Theorem 10),
secrets inherit the linear algebra of their shares.

**Theorem 11 (`shamir_reconstruct_additive`).** Let $f, g \in F[X]$ both have
degree $< \#s$, shared on the same nodes $v$. Then the participant-wise sum of
shares $i \mapsto f(v\,i) + g(v\,i)$ reconstructs the sum of secrets:

$$\sum_{i \in s} \big(f(v\,i) + g(v\,i)\big)\,\mathrm{lagrangeCoeff}(s,v,i) = f(0) + g(0).$$

*Proof sketch.* The participant-wise sums are exactly the shares of $f + g$,
which has degree $< \#s$; apply Theorem 10 to $f + g$ and split the sum by
linearity, using $(f+g)(0) = f(0) + g(0)$. $\qquad\blacksquare$

Thus participants can add two shared secrets by adding shares *locally* and then
running the ordinary reconstruction, never revealing either summand. The same
linearity yields multiplication by public scalars and hence arbitrary linear
combinations.

Multiplication of secrets is governed by degree growth.

**Theorem 12 (`shamir_reconstruct_mul`).** Let $f, g \in F[X]$ with
$\deg(f \cdot g) < \#s$ (e.g. $\#s \ge 2t-1$ when $\deg f, \deg g < t$). Then the
participant-wise products of shares reconstruct the product of secrets:

$$\sum_{i \in s} \big(f(v\,i)\,g(v\,i)\big)\,\mathrm{lagrangeCoeff}(s,v,i) = f(0)\,g(0).$$

*Proof sketch.* The products $f(v\,i)\,g(v\,i)$ are the shares of the polynomial
$f\cdot g$. Since $\deg(f\cdot g) < \#s$, Theorem 10 applies to $f\cdot g$ and
recovers its constant term $(f\cdot g)(0) = f(0)\,g(0)$. $\qquad\blacksquare$

Theorem 12 is the algebraic core of the BGW protocol for general secure
multiparty computation: products can be reconstructed, but at the cost of doubled
degree, which a full protocol then reduces via re-sharing. Together with Theorem
11, Shamir sharing is an $F$-linear secret-sharing scheme supporting addition and
(degree-permitting) multiplication of secrets held only in shared form.

## 6. Feldman's verifiable secret sharing

We now defend against a malicious dealer. The algebraic heart of Feldman
verification is that the homomorphic combination of commitments reproduces the
commitment to the share.

**Theorem 3 (`feldman_commitment_eval`).** Let $g \in F$, $t \in \mathbb{N}$, and
$f \in F[X]$ with $\mathrm{natDegree}\,f < t$. Then for all $x \in F$,

$$\sum_{j=0}^{t-1} x^j\, \mathrm{feldmanCommit}(g, f, j) = f(x)\cdot g.$$

*Proof sketch.* Substitute $\mathrm{feldmanCommit}(g,f,j) = (f.\mathrm{coeff}\,j)\cdot g$,
factor $g$ out of the sum, and recognize the remaining sum as $f(x)$ via the
finite evaluation identity $f(x) = \sum_{j<t}(f.\mathrm{coeff}\,j)\,x^j$, valid
because $\mathrm{natDegree}\,f < t$. $\qquad\blacksquare$

**Corollary 3 (`feldman_complete`, completeness).** Under the hypotheses of
Theorem 3, $\mathrm{FeldmanVerifies}(g, t, \mathrm{feldmanCommit}(g,f), x, f(x))$.

*Proof.* The verification equation is exactly the (symmetric) statement of
Theorem 3. $\qquad\blacksquare$

**Theorem 4 (`feldman_verify_iff`).** If $g \ne 0$ and $\mathrm{natDegree}\,f < t$,
then a claimed share $s$ verifies iff $s = f(x)$:

$$\mathrm{FeldmanVerifies}(g, t, \mathrm{feldmanCommit}(g,f), x, s) \iff s = f(x).$$

*Proof sketch.* By Theorem 3 the verification equation reads $s\cdot g = f(x)\cdot g$.
Since $g \ne 0$ and $F$ is a field, multiplication by $g$ is injective, so this is
equivalent to $s = f(x)$. $\qquad\blacksquare$

**Corollary 4 (`feldman_catches_cheater`, soundness).** If $g \ne 0$,
$\mathrm{natDegree}\,f < t$, and $s \ne f(x)$, then verification fails:
$\lnot\,\mathrm{FeldmanVerifies}(g, t, \mathrm{feldmanCommit}(g,f), x, s)$.

*Proof.* The contrapositive of the right-to-left direction of Theorem 4.
$\qquad\blacksquare$

Corollary 4 is exactly the guarantee that *cheating dealers are caught*: any
share value inconsistent with the published commitments is rejected by the
verifier. Finally, the commitments bind the dealer.

**Theorem 5 (`feldman_binding`).** If $g \ne 0$ and $f, f'$ both have
$\mathrm{natDegree} < t$, and $\mathrm{feldmanCommit}(g,f,j) = \mathrm{feldmanCommit}(g,f',j)$
for all $j \in \{0,\dots,t-1\}$, then $f = f'$.

*Proof sketch.* On the index range, $(f.\mathrm{coeff}\,j)\cdot g = (f'.\mathrm{coeff}\,j)\cdot g$
and cancelling the nonzero $g$ gives equal coefficients; off the range both
coefficients vanish by the degree bound. Equality of all coefficients gives
$f = f'$ by polynomial extensionality. $\qquad\blacksquare$

Thus Feldman commitments are *perfectly binding*: the commitment vector
determines the polynomial, hence the secret. The cost is that hiding is only
computational, because $C_0 = c \cdot g$ is a deterministic public function of the
secret.

## 7. Pedersen's perfectly hiding VSS

Pedersen's scheme trades the binding/hiding roles by introducing a second
generator and a blinding polynomial. The verification identity is structurally
identical to Feldman's.

**Theorem 6 (`pedersen_commitment_eval`).** Let $g, h \in F$, $t \in \mathbb{N}$,
and $f, f' \in F[X]$ with $\mathrm{natDegree}\,f < t$ and
$\mathrm{natDegree}\,f' < t$. Then for all $x \in F$,

$$\sum_{j=0}^{t-1} x^j\, \mathrm{pedersenCommit}(g, h, f, f', j) = f(x)\cdot g + f'(x)\cdot h.$$

*Proof sketch.* Expand the commitment, split the sum into a $g$-part and an
$h$-part, and apply the finite evaluation identity to each of $f$ and $f'$. $\qquad\blacksquare$

**Corollary 5 (`pedersen_complete`, completeness).** Under the hypotheses of
Theorem 6, the honest share pair $(f(x), f'(x))$ verifies:
$\mathrm{PedersenVerifies}(g, h, t, \mathrm{pedersenCommit}(g,h,f,f'), x, f(x), f'(x))$.

*Proof.* This is the symmetric form of Theorem 6. $\qquad\blacksquare$

**Theorem 7 (`pedersen_commit_add`, homomorphism).** For all $g, h, f_1, f_1',
f_2, f_2', j$,

$$\mathrm{pedersenCommit}(g,h,f_1+f_2, f_1'+f_2', j) = \mathrm{pedersenCommit}(g,h,f_1,f_1',j) + \mathrm{pedersenCommit}(g,h,f_2,f_2',j).$$

*Proof.* Coefficient-wise additivity: $(f_1+f_2).\mathrm{coeff}\,j = f_1.\mathrm{coeff}\,j + f_2.\mathrm{coeff}\,j$,
and likewise for the blinding; expand and regroup by the ring axioms.
$\qquad\blacksquare$

The headline result is perfect hiding.

**Theorem 8 (`pedersen_perfect_hiding`).** Suppose $h \ne 0$. For every threshold
$t$, every commitment vector $C : \mathbb{N} \to F$, and every sharing polynomial
$f \in F[X]$, there exists a blinding polynomial $f' \in F[X]$ such that

$$\mathrm{pedersenCommit}(g, h, f, f', j) = C_j \qquad \text{for all } j \in \{0,\dots,t-1\}.$$

*Proof sketch.* Define $f'$ explicitly as the polynomial with $j$-th coefficient
$(C_j - (f.\mathrm{coeff}\,j)\cdot g)/h$ for $j < t$ (a finite sum of monomials).
Then $\mathrm{pedersenCommit}(g,h,f,f',j) = (f.\mathrm{coeff}\,j)\cdot g + \big((C_j - (f.\mathrm{coeff}\,j)\cdot g)/h\big)\cdot h = C_j$,
using $h \ne 0$ to cancel. $\qquad\blacksquare$

Interpretation: because *every* sharing polynomial $f$ (hence every secret) can
be made to produce *any* published commitment vector by a suitable choice of
blinding, the commitments are equally consistent with every secret. They carry no
information about the sharing polynomial — *perfect hiding*, an
information-theoretic property matching Shamir's privacy (Theorem 2). The dual
statement is equivocation.

**Corollary 6 (`pedersen_equivocation`).** If $h \ne 0$, then for any two sharing
polynomials $f_1, f_2$ there exist blinding polynomials $f_1', f_2'$ with

$$\mathrm{pedersenCommit}(g,h,f_1,f_1',j) = \mathrm{pedersenCommit}(g,h,f_2,f_2',j) \qquad \text{for all } j < t.$$

*Proof sketch.* Take $f_1' = 0$ and choose $f_2'$ with $j$-th coefficient
$((f_1.\mathrm{coeff}\,j - f_2.\mathrm{coeff}\,j)\cdot g)/h$ for $j < t$; the two
commitments then coincide on the range. (Equivalently, apply Theorem 8 with
$C_j = \mathrm{pedersenCommit}(g,h,f_1,0,j)$.) $\qquad\blacksquare$

## 8. The binding–hiding duality

Theorems 5 and 8 are two halves of one algebraic phenomenon. Fix the
participant-visible range $\{0, \dots, t-1\}$ and consider, for a fixed sharing
polynomial $f$, the *commitment map* induced by the blinding:

$$\Phi_f : f' \longmapsto \big(j \mapsto (f.\mathrm{coeff}\,j)\cdot g + (f'.\mathrm{coeff}\,j)\cdot h\big).$$

Pedersen's perfect hiding (Theorem 8) is precisely the **surjectivity** of $\Phi_f$
onto commitment vectors (when $h \ne 0$): every target $C$ is hit, for every $f$.
Feldman's binding (Theorem 5) is precisely the **injectivity** of the analogous
*unblinded* map $f \mapsto (j \mapsto (f.\mathrm{coeff}\,j)\cdot g)$ on degree-$(<t)$
polynomials (when $g \ne 0$): distinct polynomials give distinct commitments.
Injectivity binds; surjectivity hides. The presence of the blinding generator $h$
is exactly what converts the rigid, injective Feldman map into the flexible,
surjective Pedersen map. No single commitment scheme of this linear form can be
both perfectly binding and perfectly hiding, and Feldman and Pedersen are the
canonical witnesses of the two extremes. This is the bridge from **Cryptography**
to **Algebra**: the security properties are statements about the injectivity and
surjectivity of explicit linear maps between polynomial spaces.

## 9. Algorithms

**Algorithm A — Threshold dealing.** Given a secret $c$, threshold $t$, and nodes
$x_1, \dots, x_n$, sample random coefficients $a_1, \dots, a_{t-1} \in F$, set
$f = c + a_1 X + \dots + a_{t-1}X^{t-1}$, and output shares $f(x_i)$. Cost:
$O(nt)$ field operations.

**Algorithm B — Lagrange reconstruction.** Given any $t$ shares at distinct nodes,
precompute the node-only weights $w_i = \mathrm{lagrangeCoeff}(s, v, i)$ and return
$\sum_i \text{share}_i \cdot w_i$ (Theorem 10). Cost: $O(t^2)$ to form the weights,
$O(t)$ per reconstruction thereafter; weights are reusable across secrets.

**Algorithm C — Feldman verify.** Given commitments $C_0, \dots, C_{t-1}$, a node
$x$, and a claimed share $s$, accept iff $s\cdot g = \sum_{j<t} x^j C_j$ (Theorem
4). Cost: $O(t)$.

**Algorithm D — Pedersen equivocation / hiding witness.** Given $f$ and a target
commitment vector $C$, output the blinding coefficients
$a'_j = (C_j - a_j \cdot g)/h$ for $j < t$ (Theorem 8). Cost: $O(t)$.

## 10. Applications

- **Key management and threshold cryptography.** Distribute a master key so that
  any $t$ of $n$ custodians can recover or use it, while fewer than $t$ learn
  nothing (Theorems 1, 2).
- **Secure multiparty computation.** Additive and multiplicative homomorphisms
  (Theorems 11, 12) let mutually distrustful parties compute arithmetic functions
  of private inputs held only in shared form (BGW).
- **Verifiable distribution against malicious dealers.** Feldman verification
  (Theorem 4, Corollary 4) lets each participant detect inconsistent shares;
  binding (Theorem 5) prevents later equivocation.
- **Privacy-preserving commitments.** Pedersen commitments (Theorem 8) underlie
  zero-knowledge protocols and confidential transactions, where the commitment
  must reveal nothing about the committed value.

## 11. Discussion and limitations

The formalization works over an arbitrary field $F$ and models the cryptographic
group additively as $(F, +)$ with scalar generators; the discrete-logarithm
hardness that underwrites Feldman hiding and Pedersen binding is a *computational*
assumption outside the algebraic core and is not (and cannot be) an unconditional
theorem. What is proved unconditionally are the *information-theoretic* facts —
Shamir reconstruction and privacy, Feldman completeness/soundness/binding, and
Pedersen completeness/homomorphism/perfect-hiding/equivocation — together with
the linear-algebraic homomorphisms enabling MPC. Privacy (Theorem 2) requires
$0 \notin s$ (the secret node must be distinct from observed nodes) and $t \ge 1$;
both hypotheses are load-bearing. Soundness and binding for Feldman require a
nonzero generator; completeness does not.

## 12. Future work

See the future directions appended to the package. In brief: formalizing a full
BGW multiplication round with degree reduction; proving that a Pedersen double
opening computes the discrete logarithm of $h$ base $g$ (computational binding);
establishing Feldman verification as a homomorphism over share addition for
verifiable MPC addition; and sharpening sub-threshold privacy to the quantitative
bijection statement that the evaluation map is surjective iff $k \le t-1$ and
injective iff $k \ge t$.

## 13. Conclusion

A single elementary fact — a degree-$(<t)$ polynomial is determined by $t$ of its
values — yields both perfect reconstruction at the threshold and perfect secrecy
below it. Layering homomorphic commitments turns the scheme verifiable, and the
choice between Feldman and Pedersen commitments is precisely the choice between
perfect binding and perfect hiding, captured as the injectivity versus
surjectivity of an explicit linear map. The linearity that secures the scheme is
the same linearity that lets parties compute on secrets they never see.
