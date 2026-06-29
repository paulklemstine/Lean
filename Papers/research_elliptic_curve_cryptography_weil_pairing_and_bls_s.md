# An Abstract Bilinear Pairing and the Algebraic Core of BLS Signatures, Aggregation, and the MOV Reduction

**Author:** Aristotle
**Date:** 2026-06-23
**Domain:** Cryptography (with a Cryptography ↔ Algebra domain bridge)

## Abstract

Pairing-based cryptography rests on a single algebraic object: a bilinear map
$e : G \times G \to T$ from an additively written abelian group $G$ (the points
of an elliptic curve) to a multiplicatively written abelian group $T$ (a group
of roots of unity). We isolate the *minimal* interface this object must satisfy —
biadditivity in each argument — and show that the entire protocol layer of the
Boneh–Lynn–Shacham (BLS) signature scheme follows from it by elementary algebra,
with no recourse to the analytic construction of the Weil or Tate pairing. We
prove: (i) the family of bilinearity laws, including the scalar-sliding identity
$e(n\cdot p, q) = e(p,q)^n$ over $\mathbb{N}$ and $\mathbb{Z}$, the joint law
$e(a\cdot p, b\cdot q) = e(p,q)^{ab}$, and the sum-to-product law
$e(\sum_i f_i, q) = \prod_i e(f_i, q)$; (ii) BLS completeness
$e(x\cdot H, g) = e(H, x\cdot g)$ and aggregate completeness
$e(\sum_i x_i\cdot H_i, g) = \prod_i e(H_i, x_i\cdot g)$, the algebraic content
of *short aggregate signatures*; (iii) the binding property as point separation
under nondegeneracy, equivalent to injectivity of the induced character map;
(iv) the *alternating* refinement characterizing the genuine Weil pairing, from
which antisymmetry $e(p,q)\cdot e(q,p) = 1$ follows; and (v) the
Menezes–Okamoto–Vanstone (MOV) reduction as a faithful congruence, transporting
the elliptic-curve discrete logarithm problem (ECDLP) into a discrete logarithm
in $T$ and recovering the secret exactly modulo $\operatorname{ord}(e(g,g))$,
with full recovery precisely when this order dominates $\operatorname{ord}(g)$.
Every statement is backed by a formally verified proof.

## 1. Introduction

Cryptographic pairings are the enabling technology behind a wide class of
protocols that are not achievable with classical discrete-log groups alone:
short signatures, signature aggregation, identity-based encryption, and
succinct non-interactive arguments. The canonical instance is the Weil pairing
on the $r$-torsion subgroup $E[r]$ of an elliptic curve $E$, a deep
construction drawing on divisors and function fields. Yet the protocols that
*consume* a pairing never use anything beyond a small set of algebraic
identities. This paper makes that observation precise: we axiomatize the pairing
by its characteristic property — biadditivity into a multiplicative target — and
derive the full BLS protocol layer, its aggregate variant, the binding property,
the alternating Weil refinement, and the MOV reduction, from this interface
alone.

The methodological payoff is twofold. First, the proofs become elementary and
modular: each cryptographic guarantee is a one- or two-line consequence of a
named algebraic lemma. Second, the boundary between "what the construction
gives" and "what the protocol needs" becomes explicit. BLS completeness and
aggregation need only biadditivity; binding needs nondegeneracy; the
Weil-specific antisymmetry needs the alternating axiom; and the MOV reduction
needs only biadditivity plus the order of a single target element.

### 1.1 Notation and conventions

Throughout, $G$ is an additively written abelian group (an `AddCommMonoid`,
strengthened to an `AddCommGroup` where inverses are required), and $T$ is a
multiplicatively written abelian group (`CommGroup`). We write $n\cdot p$ for
the $n$-fold sum of $p\in G$ ($n\in\mathbb{N}$ or $\mathbb{Z}$), $t^n$ for the
$n$-th power in $T$, $1$ for the identity of $T$, $\operatorname{ord}(t)$ for the
order of $t\in T$, and $a\equiv b \pmod m$ for congruence of naturals. The
symbol $e$ always denotes the pairing map.

## 2. The pairing interface

**Definition 1 (Pairing).** A *pairing* from $G$ to $T$ is a map
$e : G \times G \to T$ that is additive-to-multiplicative in each argument:
$$ e(a + b,\ q) = e(a, q)\cdot e(b, q) \quad\text{(add\_left)}, \qquad
   e(p,\ a + b) = e(p, a)\cdot e(p, b) \quad\text{(add\_right)}. $$
These two axioms are the complete definition; no further structure is assumed.

This is exactly the interface satisfied by the Weil and Tate pairings restricted
to the algebraic data that protocols use. The source group models the elliptic
curve point group (secret keys act by scalar multiplication); the target group
models the multiplicative group $\mu_r \subset K^\times$ of $r$-th roots of
unity.

## 3. Bilinearity: the derived laws

**Lemma 2 (Unit on the boundary; `map_one_left`, `map_one_right`).**
$e(0, q) = 1$ and $e(p, 0) = 1$.

*Proof sketch.* Put $a = b = 0$ in add\_left: $e(0,q) = e(0,q)\cdot e(0,q)$.
In a group, $x = x\cdot x$ forces $x = 1$ (cancel one factor). The right
identity is the mirror argument with add\_right. $\square$

**Lemma 3 (Scalar sliding; `pairing_nsmul_left`, `pairing_nsmul_right`).**
For all $n\in\mathbb{N}$, $e(n\cdot p, q) = e(p,q)^n$ and
$e(p, n\cdot q) = e(p,q)^n$.

*Proof sketch.* Induction on $n$. Base case $n=0$ is Lemma 2 together with
$t^0 = 1$. Inductive step: $(n+1)\cdot p = n\cdot p + p$, so by add\_left and the
hypothesis, $e((n+1)\cdot p, q) = e(n\cdot p, q)\cdot e(p,q) = e(p,q)^n\cdot e(p,q)
= e(p,q)^{n+1}$. The right version is identical with add\_right. $\square$

**Lemma 4 (Joint scalar law; `pairing_bilinear_nsmul`).**
For all $a, b\in\mathbb{N}$, $e(a\cdot p, b\cdot q) = e(p,q)^{ab}$.

*Proof sketch.* Apply Lemma 3 in each slot in turn:
$e(a\cdot p, b\cdot q) = e(p, b\cdot q)^a = (e(p,q)^b)^a = e(p,q)^{ab}$, using
$(t^b)^a = t^{ab}$ and commutativity of $\mathbb{N}$-multiplication. $\square$

**Lemma 5 (Sum to product; `pairing_sum_left`).**
For a finite index set $s$ and $f : s \to G$,
$$ e\!\Big(\sum_{i\in s} f_i,\ q\Big) = \prod_{i\in s} e(f_i, q). $$

*Proof sketch.* Finite-set induction. Empty set: the empty sum is $0$, the empty
product is $1$, and $e(0,q)=1$ by Lemma 2. Insertion step: peeling off a new
index $a$ gives $e(f_a + \sum_{i} f_i, q) = e(f_a, q)\cdot e(\sum_i f_i, q)$ by
add\_left, then the hypothesis. $\square$

**Lemma 8 (Inverses and $\mathbb{Z}$-grading; `map_neg_left`,
`pairing_zsmul_left`).** When $G$ is a group, $e(-p, q) = e(p,q)^{-1}$, and for
all $n\in\mathbb{Z}$, $e(n\cdot p, q) = e(p,q)^n$.

*Proof sketch.* From $e(p,q)\cdot e(-p,q) = e(p + (-p), q) = e(0,q) = 1$ we read
off $e(-p,q) = e(p,q)^{-1}$. For the $\mathbb{Z}$ law, split $n = m$ or
$n = -m$ with $m\in\mathbb{N}$; the nonnegative case is Lemma 3, and the negative
case combines $e(-p,q) = e(p,q)^{-1}$ with the natural law and $t^{-m} =
(t^m)^{-1}$. $\square$

## 4. BLS signatures and aggregation

We model BLS over the pairing interface. Public parameters fix a generator
$g\in G$. A signer holds secret key $x\in\mathbb{N}$ and publishes public key
$X = x\cdot g$. To sign a message whose hash-to-curve value is $H\in G$, the
signer outputs the single group element $\sigma = x\cdot H$. A verifier holding
$(g, X, H, \sigma)$ accepts iff $e(\sigma, g) = e(H, X)$.

**Theorem 6 (BLS completeness; `bls_verify_correct`).**
For all $g, H\in G$ and $x\in\mathbb{N}$,
$$ e(x\cdot H,\ g) = e(H,\ x\cdot g). $$
Consequently the verification equation $e(\sigma, g) = e(H, X)$ holds for every
honestly generated signature $\sigma = x\cdot H$ with $X = x\cdot g$.

*Proof sketch.* By Lemma 3 in the first slot, $e(x\cdot H, g) = e(H,g)^x$; by
Lemma 3 in the second slot, $e(H, x\cdot g) = e(H,g)^x$. The two right-hand
sides coincide. $\square$

**Theorem 7 (Aggregate completeness; `bls_aggregate_correct`).**
For a finite index set $s$, generator $g$, hash points $H : s \to G$, and secret
keys $x : s \to \mathbb{N}$,
$$ e\!\Big(\sum_{i\in s} x_i\cdot H_i,\ g\Big) = \prod_{i\in s} e\big(H_i,\ x_i\cdot g\big). $$
The aggregate signature $\sigma_{\mathrm{agg}} = \sum_i x_i\cdot H_i$ is a single
group element that verifies against the product of per-signer pairings.

*Proof sketch.* Apply the sum-to-product law (Lemma 5) to the left side, turning
the pairing of the aggregated sum into a product of per-index pairings
$e(x_i\cdot H_i, g)$; then rewrite each factor by Theorem 6 to obtain
$e(H_i, x_i\cdot g)$. $\square$

This is the algebraic content of *short aggregate signatures*: $n$ signatures
compress to one group element while verification fans out into $n$
publicly-checkable factors $\prod_i e(H_i, X_i)$.

## 5. Binding via nondegeneracy

A pairing is *left-nondegenerate* if the only point pairing trivially with
everything is $0$: $\forall a,\ (\forall q,\ e(a,q)=1) \Rightarrow a = 0$.

**Theorem 9 (Point separation; `pairing_left_injective`).**
If $e$ is left-nondegenerate and $e(p_1, q) = e(p_2, q)$ for all $q\in G$, then
$p_1 = p_2$.

*Proof sketch.* For every $q$,
$e(p_1 - p_2, q) = e(p_1, q)\cdot e(-p_2, q) = e(p_1,q)\cdot e(p_2,q)^{-1} = 1$
using add\_left, Lemma 8, and the hypothesis. Nondegeneracy applied to
$p_1 - p_2$ gives $p_1 - p_2 = 0$, hence $p_1 = p_2$. $\square$

**Definition 13 (Character homomorphisms; `homLeft`, `homRight`).**
For fixed $q$ (resp. $p$), the maps $p\mapsto e(p,q)$ and $q\mapsto e(p,q)$ are
additive-to-multiplicative homomorphisms $G \to \mathrm{Additive}\,T$, i.e.
genuine additive group homomorphisms once $T$ is viewed additively. They
package the two biadditivity axioms in the standard homomorphism API
($e(0,q)=1$ becomes $\mathrm{map\_zero}$; add\_left becomes $\mathrm{map\_add}$).

**Theorem 14 (Nondegeneracy is injectivity; `nondegenerate_iff_char_injective`).**
Left-nondegeneracy is equivalent to injectivity of the character map
$\chi : G \to (G \to T)$, $\chi(p) = \big(q \mapsto e(p,q)\big)$:
$$ \big(\forall a,\ (\forall q,\ e(a,q)=1) \Rightarrow a = 0\big) \iff \text{$\chi$ is injective}. $$

*Proof sketch.* ($\Rightarrow$) If $\chi(p_1) = \chi(p_2)$, then $e(p_1,q) =
e(p_2,q)$ for all $q$; apply Theorem 9. ($\Leftarrow$) Given $a$ with $e(a,q)=1$
for all $q$, note $e(0,q)=1=e(a,q)$ for all $q$, so $\chi(a) = \chi(0)$, hence
$a = 0$ by injectivity. $\square$

Theorem 14 gives the clean algebraic boundary for the binding property: a pairing
"separates points" precisely when its character map is one-to-one, so distinct
keys produce distinct verification fingerprints. A forgery that passed
verification without the secret would violate this injectivity.

## 6. The alternating refinement: the genuine Weil pairing

The Weil pairing on $E[r]$ is *alternating*. We capture this as a refinement of
the interface.

**Definition 15 (Alternating pairing; `AlternatingPairing`).**
An *alternating pairing* is a pairing $e$ on a group $G$ additionally satisfying
the self-pairing axiom $e(p, p) = 1$ for all $p$.

**Theorem 16 (Antisymmetry; `mul_swap_eq_one`, `swap_eq_inv`).**
For an alternating pairing,
$$ e(p, q)\cdot e(q, p) = 1, \qquad\text{equivalently}\qquad e(q, p) = e(p, q)^{-1}. $$

*Proof sketch.* Expand the self-pairing of a sum by biadditivity:
$$ 1 = e(p+q,\ p+q) = e(p,p)\cdot e(p,q)\cdot e(q,p)\cdot e(q,q). $$
By the alternating axiom $e(p,p) = e(q,q) = 1$, leaving $e(p,q)\cdot e(q,p) = 1$.
The inverse form is immediate: $e(q,p)$ is the inverse of $e(p,q)$. $\square$

Antisymmetry is the algebraic fingerprint distinguishing the Weil pairing from a
generic biadditive map, and it explains why self-pairing leaks nothing about a
secret: $e(X, X) = 1$ for every public key $X = x\cdot g$.

## 7. The MOV reduction: a Cryptography ↔ Algebra bridge

The Menezes–Okamoto–Vanstone reduction transports the ECDLP in $G$ to a discrete
logarithm in the target group $T$. Its fidelity is governed entirely by a single
order.

**Theorem 10 (The MOV map; `mov_map`).**
For all $g\in G$ and $x\in\mathbb{N}$,
$$ e(x\cdot g,\ g) = e(g, g)^{x}. $$

*Proof sketch.* Lemma 3 in the first slot with $p = q = g$. $\square$

Thus the ECDLP instance "$x$ such that $X = x\cdot g$" becomes the DLP instance
"$x$ such that $e(X, g) = e(g,g)^x$" in $T$ — a discrete log to the base
$e(g,g)$ in the multiplicative group of a finite field.

**Theorem 11 (Faithfulness of the reduction; `mov_reduction`).**
For all $g\in G$ and $a, b\in\mathbb{N}$,
$$ e(a\cdot g,\ g) = e(b\cdot g,\ g) \iff a \equiv b \pmod{\operatorname{ord}\!\big(e(g,g)\big)}. $$

*Proof sketch.* By Theorem 10 the equality becomes $e(g,g)^a = e(g,g)^b$. In a
group, two equal powers of an element $t$ are characterized by congruence of
exponents modulo $\operatorname{ord}(t)$ (the standard power-equality criterion).
$\square$

Hence solving the DLP base $e(g,g)$ in $T$ recovers the ECDLP value *exactly
modulo* $\operatorname{ord}(e(g,g))$. The reduction loses no more and no less
than this residue.

**Theorem 12 (Full recovery; `mov_recovers_dlog`).**
Let $n\in\mathbb{N}$ with $n \le \operatorname{ord}(e(g,g))$. If $a, b < n$ and
$e(a\cdot g, g) = e(b\cdot g, g)$, then $a = b$.

*Proof sketch.* Theorem 11 gives $a \equiv b \pmod{\operatorname{ord}(e(g,g))}$.
Since $a, b < n \le \operatorname{ord}(e(g,g))$, both are their own residues
modulo $\operatorname{ord}(e(g,g))$, so the congruence forces $a = b$. $\square$

Taking $n = \operatorname{ord}(g)$, Theorem 12 says: whenever the order of
$e(g,g)$ in $T$ is at least the order of $g$ — the regime of *small embedding
degree* — the finite-field DLP solver returns the unique secret in the canonical
range $0 \le x < \operatorname{ord}(g)$. This is the precise reason curves with
small embedding degree are cryptographically broken: the pairing dissolves the
ECDLP into a finite-field DLP that can be solved by subexponential index-calculus
methods.

## 8. Algorithms

We summarize the constructive content of the results as algorithms over the
abstract interface; concrete implementations appear in the companion demo.

- **BLS aggregate verification (from Theorem 7).** Given $(g, \{(H_i,
  X_i)\}_i, \sigma_{\mathrm{agg}})$, accept iff $e(\sigma_{\mathrm{agg}}, g) =
  \prod_i e(H_i, X_i)$. Cost: one left pairing plus $n$ right pairings and $n-1$
  target multiplications.
- **MOV attack (from Theorems 10–12).** Given $(g, X = x\cdot g)$ on a curve of
  small embedding degree, compute $u = e(X, g)$ and $h = e(g, g)$ in $T$, then
  solve the finite-field discrete logarithm $u = h^x$ for $x$ in the range
  $0 \le x < \operatorname{ord}(g)$. By Theorem 12 the recovered $x$ is unique.

## 9. Discussion and applications

The abstraction clarifies *exactly* what each cryptographic property costs in
axioms. Completeness (Theorem 6) and aggregation (Theorem 7) are theorems of the
bare biadditive interface; they require neither nondegeneracy nor the alternating
law. Binding (Theorems 9, 14) requires nondegeneracy and nothing else. The
Weil-specific antisymmetry (Theorem 16) requires the alternating axiom. And the
MOV reduction (Theorems 10–12) is again a theorem of bare biadditivity, with the
single quantitative input $\operatorname{ord}(e(g,g))$ controlling its fidelity.

This separation has practical consequences. Aggregate BLS underpins the
finality gadgets of modern proof-of-stake blockchains, where thousands of
validator signatures per block must be stored and checked; Theorem 7 is the
reason a single group element suffices. The MOV reduction, conversely, is a
design *constraint*: curve selection must ensure a large embedding degree so that
$\operatorname{ord}(e(g,g))$ does not place the ECDLP within reach of
finite-field index calculus.

## 10. Future work

Four directions extend the present development. (1) *Antisymmetry vs.
alternation:* on targets without 2-torsion, antisymmetry $e(p,q)\cdot e(q,p)=1$
for all $p,q$ should be equivalent to the alternating law $e(p,p)=1$, the gap
being exactly the 2-torsion subgroup of $T$ (since $e(p,p)^2 = 1$ is the only
obstruction). (2) *Embedding degree characterization:* promote Theorem 12 to an
*iff*, characterizing the embedding degree $k$ as the least $k$ with
$\operatorname{ord}(g) \mid \operatorname{ord}(e(g,g))$ in $\mu_{q^k - 1}$.
(3) *Aggregate soundness:* upgrade completeness (Theorem 7) to a binding/soundness
statement equivalent to left-nondegeneracy (Theorem 14), by reducing aggregate
collisions to a single equation $e(\Delta, g) = 1$ for the difference $\Delta$ of
aggregated signatures. (4) *Cyclic targets:* when $T$ is cyclic, reduce the full
ECDLP to a single `Nat.ModEq` solve. These are the natural next theorems given
the lemmas already in hand.

## 11. Conclusion

From two equations — biadditivity in each slot — we obtain the complete BLS
protocol layer, its short aggregate variant, the binding property as point
separation, the alternating refinement defining the genuine Weil pairing, and
the MOV reduction as a faithful congruence governed by a single order. The
analytic construction of the Weil pairing is unnecessary for any of this: the
algebra of the interface is the whole story, and it is enough to explain why
pairing-based signatures are simultaneously powerful (aggregation) and delicate
(the MOV pitfall).
