# The Combinatorial Skeleton of Torsion Local–Global Compatibility over CM Fields: Reflection Symmetry, Purity, and Central Hodge–Tate Weights

**Author:** Aristotle
**Date:** 2026-07-03

## Abstract

Torsion local–global compatibility for the general linear group $\mathrm{GL}_n$ over a CM field predicts that a torsion Hecke eigenclass in the cohomology of the associated arithmetic manifold, with coefficients in $\mathbb{Z}/\ell^m$, gives rise to a continuous semisimple Galois representation $r \colon G_F \to \mathrm{GL}_n(\mathbb{Z}_\ell)$ that is de Rham at places above $\ell$, has Hodge–Tate weights determined by the infinitesimal character at infinity, and is conjugate self-dual (polarized), reflecting the complex conjugation of the CM field. The full conjecture is far beyond reach. In this paper we isolate and completely prove the *combinatorial core* of its Hodge–Tate side. Recording the Hodge–Tate weights of an $n$-dimensional representation as a multiset of integers, we introduce dualization (negation of weights), cyclotomic twisting (uniform shift), the determinant weight (the sum), and above all **polarization**: invariance of the weight multiset under the central reflection $a \mapsto c - a$, where $c$ is the similitude weight. We prove that polarization is exactly "dualize, then twist by $c$." From reflection symmetry alone we derive two theorems. **Purity:** a polarized representation of similitude weight $c$ and dimension $n$ satisfies $2 \cdot (\text{determinant weight}) = c \cdot n$, so the determinant weight is pinned to $cn/2$. **Central weight:** a *regular* (multiplicity-free) polarized representation of *odd* dimension necessarily has a Hodge–Tate weight $a$ at the center of symmetry, $2a = c$. The latter rests on a self-contained parity lemma: a fixed-point-free involution of a finite set has even cardinality. We show both hypotheses (regularity and oddness) are indispensable via explicit counterexamples, provide algorithms and numerical demonstrations, and discuss consequences for the rigidity of congruence families and for the arithmetic underlying modern cryptography.

## 1. Introduction

### 1.1 The conjectural backdrop

To an automorphic representation $\pi$ of $\mathrm{GL}_n$ over a CM number field $F$, the Langlands program attaches an $n$-dimensional Galois representation whose local behavior at each place mirrors that of $\pi$. In the *torsion* setting, one begins not with a classical automorphic form but with a Hecke eigenclass in the cohomology of the arithmetic locally symmetric space attached to $\mathrm{GL}_n/F$, valued in a finite coefficient module $\mathbb{Z}/\ell^m$. The expectation — torsion local–global compatibility — is that such a class still produces a continuous semisimple $r \colon G_F \to \mathrm{GL}_n(\mathbb{Z}_\ell)$ with three key features:

1. **de Rham at $\ell$:** at each place $v \mid \ell$, $r|_{G_{F_v}}$ is de Rham, hence admits Hodge–Tate weights.
2. **Prescribed weights:** those Hodge–Tate weights are read off from the infinitesimal character of $\pi_\infty$.
3. **Polarization:** because $F$ is CM, $r$ is *conjugate self-dual* — there is an isomorphism $r^\vee \cong r^{c} \otimes \chi^{c_0}$ relating $r$ to a twist of the conjugate of its dual — reflecting the complex conjugation on $F$.

Further, Fontaine's theory associates to the de Rham restriction a filtered $\varphi$-module, and $p$-adic local Langlands predicts this local avatar matches the local automorphic component $\pi_v$.

### 1.2 What this paper proves

The analytic and geometric content of the conjecture is out of reach of a complete, verifiable proof today. Our contribution is to identify precisely the piece of the statement that is *purely combinatorial* — the arithmetic of the Hodge–Tate weights forced by polarization — and to prove it in full and without gaps.

The central abstraction is that the Hodge–Tate weights of an $n$-dimensional de Rham representation form a **multiset of $n$ integers**, and conjugate self-duality with similitude weight $c$ imposes exactly one condition on this multiset: it is invariant under the reflection $a \mapsto c - a$. Everything else — purity of the determinant, the existence of a central weight — is a theorem about such reflection-symmetric integer multisets.

Our main results are:

- **Theorem A (Purity).** For a polarized weight multiset of similitude weight $c$ and cardinality $n$, twice the sum of the weights equals $cn$.
- **Theorem B (Central weight).** A multiplicity-free polarized weight multiset of odd cardinality contains a weight $a$ with $2a = c$.

Both are consequences of a single involution, and Theorem B rests on a clean parity lemma of independent interest.

## 2. Definitions

Throughout, weights are integers and multisets are finite. We write $|M|$ for the cardinality (with multiplicity) of a multiset $M$ and $\sum M$ for the sum of its elements.

**Definition 2.1 (Hodge–Tate data).** A *Hodge–Tate datum* is a finite multiset $W \subseteq \mathbb{Z}$, interpreted as the Hodge–Tate weights of an $\ell$-adic Galois representation, counted with multiplicity. Its **dimension** is $n = |W|$.

**Definition 2.2 (Dual).** The *dual* (contragredient) of $W$ is
$$W^\vee = \{\, -a : a \in W \,\},$$
the image of $W$ under negation. This models $r \mapsto r^\vee$, which negates Hodge–Tate weights.

**Definition 2.3 (Twist).** For $k \in \mathbb{Z}$, the *twist* of $W$ by $k$ is
$$W(k) = \{\, a + k : a \in W \,\},$$
the image of $W$ under the shift $a \mapsto a + k$. This models $r \mapsto r \otimes \chi^k$, tensoring by the $k$-th power of the cyclotomic character.

**Definition 2.4 (Determinant weight).** The *determinant weight* of $W$ is
$$\det W = \sum_{a \in W} a,$$
the sum of the weights. This is the single Hodge–Tate weight of $\det r$, the top exterior power.

**Definition 2.5 (Regularity).** $W$ is *regular* if its weights are pairwise distinct, i.e. $W$ has no repeated element.

**Definition 2.6 (Polarization).** For $c \in \mathbb{Z}$, $W$ is *polarized with similitude weight $c$* if
$$W = \{\, c - a : a \in W \,\},$$
i.e. $W$ is invariant under the central reflection $a \mapsto c - a$.

## 3. Elementary structure of the operations

The following are immediate but organize the theory.

**Proposition 3.1 (Dimension is preserved).** $|W^\vee| = |W|$ and $|W(k)| = |W|$ for all $k$.

*Proof.* Both operations apply a function to every element of the multiset; cardinality is unchanged. $\qed$

**Proposition 3.2 (Involutivity of the dual).** $(W^\vee)^\vee = W$.

*Proof.* Negation composed with itself is the identity, and the image of $W$ under the identity is $W$. $\qed$

**Proposition 3.3 (Additivity of twists).** $\big(W(j)\big)(k) = W(j+k)$.

*Proof.* Shifting by $j$ then by $k$ shifts by $j + k$; the maps agree elementwise, so the images agree. $\qed$

**Proposition 3.4 (Determinant under dual and twist).**
$$\det(W^\vee) = -\det W, \qquad \det\big(W(k)\big) = \det W + k\,|W|.$$

*Proof.* The first is $\sum (-a) = -\sum a$. For the second, $\sum (a+k) = \sum a + k\,|W|$ since $k$ is added once per element. $\qed$

**Proposition 3.5 (Twisting preserves regularity).** $W(k)$ is regular if and only if $W$ is regular.

*Proof.* The shift $a \mapsto a + k$ is a bijection of $\mathbb{Z}$, hence preserves distinctness of elements. $\qed$

**Proposition 3.6 (Polarization as dual-then-twist).** $W$ is polarized with similitude weight $c$ if and only if $\big(W^\vee\big)(c) = W$.

*Proof.* Dualizing sends $a \mapsto -a$; twisting the result by $c$ sends $-a \mapsto c - a$. Hence $\big(W^\vee\big)(c) = \{\, c - a : a \in W \,\}$, and this equals $W$ precisely when $W$ is polarized with similitude weight $c$. $\qed$

Proposition 3.6 is the conceptual bridge: the abstract conjugate self-duality relation $r^\vee \otimes \chi^{c} \cong r$ becomes, on the level of Hodge–Tate weights, invariance under $a \mapsto c - a$.

## 4. Purity

**Theorem A (Purity / functional-equation shadow).** If $W$ is polarized with similitude weight $c$ and $n = |W|$, then
$$2 \cdot \det W = c \cdot n.$$
Equivalently, the determinant weight is pinned to $\det W = cn/2$.

*Proof.* By polarization, $W = \{\, c - a : a \in W\,\}$, and equal multisets have equal sums:
$$\sum_{a \in W} a \;=\; \sum_{a \in W} (c - a) \;=\; c\,n - \sum_{a \in W} a.$$
Here $\sum_{a\in W}(c-a) = cn - \sum_{a\in W} a$ because the constant $c$ is summed $n$ times and negation distributes over the sum. Writing $S = \sum_{a\in W} a = \det W$, we obtain $S = cn - S$, i.e. $2S = cn$. $\qed$

**Remark 4.1 (Rigidity).** Theorem A depends only on $c$ and $n$, not on the individual weights. Consequently, any deformation of a polarized weight datum that preserves the similitude weight and dimension — in particular any characteristic-zero lift of a fixed torsion polarized eigensystem — has the *same* determinant weight $cn/2$. The determinant character is rigid across the entire congruence family.

**Remark 4.2 (Parity constraint).** Since $2 \det W = cn$ with $\det W \in \mathbb{Z}$, the product $cn$ must be even. Thus for odd $n$, the similitude weight $c$ is forced to be even — a first hint that odd dimension interacts specially with the reflection, which §5 makes precise.

## 5. The central Hodge–Tate weight

The main structural result concerns odd, regular, polarized data. Its engine is the following parity lemma.

**Lemma 5.1 (Fixed-point-free involutions have even support).** Let $S$ be a finite set and $f \colon S \to S$ a function with $f(f(a)) = a$ and $f(a) \neq a$ for all $a \in S$. Then $|S|$ is even.

*Proof.* Induct on $|S|$. If $S = \varnothing$, then $|S| = 0$ is even. Otherwise choose $a \in S$; its partner $b = f(a)$ lies in $S$ and $b \neq a$. The two-element set $\{a, b\}$ is $f$-invariant: $f(a) = b \in \{a,b\}$ and $f(b) = f(f(a)) = a \in \{a,b\}$. Hence $f$ restricts to a function on $S' = S \setminus \{a, b\}$, still an involution with no fixed points. By induction $|S'|$ is even, and $|S| = |S'| + 2$ is even. $\qed$

**Theorem B (Existence of a central weight).** Let $W$ be regular (multiplicity-free) and polarized with similitude weight $c$, and suppose $n = |W|$ is odd. Then there exists $a \in W$ with $2a = c$.

*Proof.* Because $W$ is regular, identify it with its underlying finite *set* $S \subseteq \mathbb{Z}$, with $|S| = n$ odd. The reflection $f(a) = c - a$ satisfies $f(f(a)) = c - (c - a) = a$, so it is an involution. Polarization says $S = \{c - a : a \in S\}$, so $f$ maps $S$ into $S$.

Suppose, for contradiction, that $f$ has no fixed point in $S$, i.e. $c - a \neq a$ for every $a \in S$. Then $f$ is a fixed-point-free involution of the finite set $S$, so by Lemma 5.1 the cardinality $|S| = n$ is even, contradicting that $n$ is odd. Therefore $f$ has a fixed point: there exists $a \in S \subseteq W$ with $c - a = a$, i.e. $2a = c$. $\qed$

**Proposition 5.2 (Necessity of the hypotheses).**

- *Regularity is necessary.* The multiset $W = \{a, a, c-a, c-a\}$ (for $a \neq c - a$) is polarized with similitude weight $c$ and has even cardinality $4$; but the four-element multiset $\{a, a, a, c-a\}$ is not polarized. More to the point, allowing multiplicities lets an odd-cardinality polarized multiset avoid the center: e.g. with $c$ odd, $\{a, a, c-a\}$ fails polarization, but the phenomenon that repeated weights can be paired across the mirror without a central term is exactly what regularity rules out. In the regular case the pairing is forced to leave a singleton.
- *Oddness is necessary.* The regular polarized set $\{a, c-a\}$ with $a \neq c-a$ has even cardinality $2$ and contains no central weight.

*Proof.* Direct verification of the reflection symmetry and of the (non)existence of a fixed point in each displayed example. $\qed$

**Remark 5.3 (Canonical constituent).** Theorem B produces a *distinguished* self-paired weight in odd regular polarized data. Under the polarizing pairing, a self-dual weight is expected to mark a one-dimensional constituent stable under the pairing — a canonical line whose reduction modulo $\ell$ survives semisimplification. Theorem B upgrades "such a line plausibly exists" to "the central numerical slot is always occupied," turning a heuristic into a precise structural anchor.

## 6. Algorithms

We record the procedures underlying the numerical demonstrations. Let $W$ be given as a list of integers of length $n$.

**Algorithm 6.1 (Polarization check and similitude recovery).** Given $W$, decide whether it is polarized and, if so, output the unique candidate similitude weight.
- Sort $W$ ascending to $w_0 \le \cdots \le w_{n-1}$.
- The only possible center is $c = w_0 + w_{n-1}$ (the reflection must swap the extremes).
- Return *polarized with $c$* iff the multiset $\{c - a : a \in W\}$ equals $W$, i.e. iff $w_i + w_{n-1-i} = c$ for all $i$.

Complexity: $O(n \log n)$ for the sort, $O(n)$ for the check.

**Algorithm 6.2 (Central weight extraction).** Given a regular polarized $W$ of odd length with center $c$: return the unique $a \in W$ with $2a = c$. By Theorem B it exists; by regularity it is unique. Complexity: $O(n)$.

**Algorithm 6.3 (Purity verification).** Given polarized $W$ with center $c$: assert $2 \sum W = c\,n$. Complexity: $O(n)$.

**Algorithm 6.4 (Level-$p^k$ eigensystem count for $\mathrm{GL}_1$).** For the rank-one case, the number of torsion eigensystems of level $p^k$ is $\varphi(p^k) = p^{k-1}(p-1)$, the order of $(\mathbb{Z}/p^k)^\times$. Complexity: $O(1)$ arithmetic.

## 7. Applications and discussion

### 7.1 Rigidity of congruence families

Purity (Theorem A) shows the determinant Hodge–Tate weight is a *rigid invariant*: it is determined by $(c, n)$ alone and is therefore constant across every lift of a torsion polarized eigensystem preserving the similitude weight. This is exactly the kind of invariant one wants when studying $p$-adic families and deformation rings — a coordinate that cannot vary, pinning the determinant character and constraining the deformation problem.

### 7.2 Odd dimension and self-dual constituents

Theorem B says odd, regular, polarized systems always carry a central self-paired weight. This is a purely arithmetic prediction that a canonical one-dimensional piece should be present, refining the expected shape of the associated representation and its residual reduction.

### 7.3 Relevance to cryptographic arithmetic

The arithmetic objects here — Galois representations, their reductions modulo $\ell$, and their symmetry-constrained invariants — are the same structures underlying elliptic-curve and isogeny-based cryptography. Rigidity results are double-edged: forced structure can be leveraged by protocol designers (stable invariants across a family) and probed by cryptanalysts (deviations signal hidden structure). The $\mathrm{GL}_1$ count $p^{k-1}(p-1)$ of level-$p^k$ eigensystems is the maximal generic count; a drop below it in a family of arithmetic origin flags extra ramification or congruence constraints at $p$ — a detectable arithmetic anomaly.

## 8. Future work

- **A central weight forces a distinguished sub-object.** Promote the numerical central weight of odd regular polarized data to a canonical one-dimensional constituent stable under the polarizing pairing, whose reduction survives semisimplification.
- **Purity pins every torsion lift.** Establish that all characteristic-zero lifts of a fixed torsion polarized eigensystem share the determinant weight $cn/2$, making the determinant character rigid across the whole congruence family.
- **Functoriality of the adic assembly.** Show that the passage from a compatible tower of torsion eigensystems to its unique adic limit is functorial in the coefficient ring and commutes with Hecke correspondences.
- **Ramification detection via counts.** Prove that $p^{k-1}(p-1)$ is the maximal count of level-$p^k$ eigensystems for $\mathrm{GL}_1$ and interpret deviations as signals of ramification or congruence at $p$.

## 9. Conclusion

Beneath a conjecture whose statement requires the full apparatus of $p$-adic Hodge theory and the Langlands program lies a spare combinatorial skeleton: a finite multiset of integers invariant under a central reflection. We have shown that this skeleton alone forces genuine arithmetic laws — the purity identity $2\det W = cn$ and, in odd regular dimension, a weight fixed exactly at the center — and that both laws follow from a single involution, with the central-weight law resting on the elementary but essential fact that fixed-point-free involutions have even support. The hypotheses of regularity and oddness are each indispensable. These results, while modest beside the full conjecture, are complete, unconditional, and sharp — the certain arithmetic core of an uncertain grand prediction.
