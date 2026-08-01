# Sharpness of Finite-Group Cocycle Averaging in Prime Characteristic

## Abstract

Let a finite group $G$ act linearly on a vector space $V$ over a field $k$. If the order $|G|$ is invertible in $k$, the standard averaging argument shows that every degree-one cocycle $c:G\to V$ is a coboundary. We establish the sharpness of this hypothesis by giving a uniform counterexample in every prime characteristic. For each prime $p$, take the additive cyclic group $\mathbb{Z}/p\mathbb{Z}$, written multiplicatively, acting trivially on $V=\mathbb{F}_p$. The coordinate map $c(g)=g$ satisfies the cocycle identity, but every coboundary for the trivial action is zero, while $c(1)=1$. Moreover, $|G|=p=0$ in $\mathbb{F}_p$. Thus unconditional degree-one averaging is false whenever the characteristic is allowed to divide the group order. We present the construction, prove its properties, give an exhaustive finite algorithm for illustrating it, and discuss its implications for continuous cohomology, profinite groups, arithmetic geometry, Selmer structures, and deformation theory.

## 1. Introduction

Averaging over a finite group is a fundamental method for producing invariant objects. Given a finite group $G$ and data indexed by $G$, one sums over the orbit and divides by $|G|$. Since left or right multiplication permutes $G$, the average is invariant. This principle underlies invariant inner products, equivariant projections, semisimplicity phenomena, and cohomological vanishing theorems.

The qualification “divide by $|G|$” is decisive. If the coefficient field $k$ has characteristic dividing $|G|$, then $|G|$ is zero in $k$ and has no multiplicative inverse. One might nevertheless wonder whether the conclusion of a particular averaging theorem survives by another method. For degree-one group cohomology, it does not.

This paper isolates an explicit and uniform obstruction. For every prime $p$, the cyclic group of order $p$ acting trivially on the one-dimensional vector space $\mathbb{F}_p$ has a nonzero degree-one cocycle. Since all coboundaries for a trivial action vanish, this cocycle represents a nonzero cohomology class. At the same time, the group order maps to zero in the coefficient field. The example proves that invertibility of $|G|$ is not merely an assumption used by the standard proof; without it, the asserted vanishing is false.

The construction is elementary, but it has broader significance. It distinguishes prime-to-characteristic finite quotients, where averaging remains available, from quotients whose orders contain the coefficient characteristic. That distinction is inherited by profinite groups and is central when studying continuous cohomology with finite discrete coefficients. Such cohomological inputs, in turn, occur in arithmetic geometry, Iwasawa theory, Selmer theory, and deformation theory.

We proceed self-containedly. Section 2 defines linear actions, cocycles, coboundaries, and first cohomology. Section 3 recalls the averaging argument under the invertibility hypothesis. Section 4 gives the prime-characteristic construction. Section 5 proves the main sharpness theorem and derives its cohomological interpretation. Section 6 describes computational demonstrations. Sections 7 and 8 discuss conceptual consequences and future directions.

## 2. Definitions and elementary structure

### 2.1. Group actions on vector spaces

Let $G$ be a group, let $k$ be a field, and let $V$ be a vector space over $k$. A **linear action** of $G$ on $V$ assigns to each $g\in G$ an invertible $k$-linear transformation $v\mapsto g\cdot v$ such that

$$
e\cdot v=v,\qquad (gh)\cdot v=g\cdot(h\cdot v)
$$

for all $g,h\in G$ and $v\in V$. A vector space equipped with such an action is called a $G$-module over $k$.

The action is **trivial** if $g\cdot v=v$ for every $g\in G$ and $v\in V$. Trivial actions are important here because they make the distinction between cocycles and coboundaries especially transparent.

### 2.2. Degree-one cocycles

A **degree-one cocycle**, also called a crossed homomorphism, is a function $c:G\to V$ satisfying

$$
c(gh)=c(g)+g\cdot c(h)
$$

for every $g,h\in G$. Denote the set of these functions by $Z^1(G,V)$.

The terminology is motivated by affine actions. Given a function $c:G\to V$, define

$$
g\star v=g\cdot v+c(g).
$$

Then $\star$ is a group action precisely when $c$ satisfies the cocycle identity. Indeed,

$$
g\star(h\star v)=g\cdot(h\cdot v+c(h))+c(g)
=(gh)\cdot v+g\cdot c(h)+c(g),
$$

which equals $(gh)\star v$ exactly when $c(gh)=c(g)+g\cdot c(h)$.

For a trivial action, the cocycle identity simplifies to

$$
c(gh)=c(g)+c(h).
$$

Thus degree-one cocycles for the trivial action are precisely group homomorphisms from $G$ to the additive group of $V$.

### 2.3. Coboundaries and changes of origin

For each $v\in V$, define a function $\delta v:G\to V$ by

$$
(\delta v)(g)=v-g\cdot v.
$$

Such a function is called a **degree-one coboundary**. It satisfies the cocycle equation:

$$
\begin{aligned}
(\delta v)(gh)
&=v-(gh)\cdot v\\
&=v-g\cdot v+g\cdot v-g\cdot(h\cdot v)\\
&=(\delta v)(g)+g\cdot(\delta v)(h).
\end{aligned}
$$

Write $B^1(G,V)$ for the set of coboundaries. The quotient

$$
H^1(G,V)=Z^1(G,V)/B^1(G,V)
$$

is the **first group cohomology** of $G$ with coefficients in $V$.

Coboundaries correspond to affine actions that become linear after translating the origin. Indeed, if $c(g)=v-g\cdot v$, then the point $v$ is fixed by the affine action $g\star x=g\cdot x+c(g)$:

$$
g\star v=g\cdot v+v-g\cdot v=v.
$$

Therefore $H^1(G,V)$ measures the obstruction to finding a fixed point, or equivalently to eliminating the translational part of an affine action by a change of origin.

For a trivial action, every coboundary is zero because

$$
(\delta v)(g)=v-v=0.
$$

Consequently,

$$
H^1(G,V)=\operatorname{Hom}(G,V^+)
$$

when the action is trivial, where $V^+$ denotes the additive group of $V$.

## 3. The finite averaging theorem

We first recall the positive result whose sharpness is at issue.

> **Theorem 3.1 (Finite-group averaging in degree one).** Let $G$ be a finite group acting linearly on a vector space $V$ over a field $k$. Suppose $|G|$ is nonzero in $k$, equivalently that $|G|$ is invertible in $k$. Then every degree-one cocycle $c:G\to V$ is a coboundary. Hence $H^1(G,V)=0$.

**Proof sketch.** Let $c\in Z^1(G,V)$ and set

$$
w=\frac{1}{|G|}\sum_{h\in G}c(h).
$$

For fixed $g\in G$, the cocycle identity gives $c(gh)=c(g)+g\cdot c(h)$, so

$$
g\cdot c(h)=c(gh)-c(g).
$$

Summing over $h$ and using the fact that $h\mapsto gh$ permutes $G$, we obtain

$$
\sum_{h\in G}g\cdot c(h)
=\sum_{h\in G}c(gh)-|G|c(g)
=\sum_{h\in G}c(h)-|G|c(g).
$$

Dividing by $|G|$ yields $g\cdot w=w-c(g)$, or

$$
c(g)=w-g\cdot w.
$$

Thus $c=\delta w$. $\square$

The proof uses invertibility only in the final division, which raises a precise question.

> **Unconditional averaging conjecture.** For every finite group $G$, every field $k$, every linear $G$-module $V$ over $k$, and every degree-one cocycle $c:G\to V$, the cocycle $c$ is a coboundary, even when the characteristic of $k$ divides $|G|$.

The conjecture is false. The following sections give a counterexample for every prime characteristic.

## 4. The cyclic coordinate construction

Fix a prime number $p$. Let

$$
\mathbb{F}_p=\mathbb{Z}/p\mathbb{Z}
$$

be the field with $p$ elements. Define $G_p$ to be its additive group, but write the group operation multiplicatively. Concretely, if $[a]$ denotes the residue class of an integer $a$, then the element corresponding to $[a]$ times the element corresponding to $[b]$ is the element corresponding to $[a+b]$. The identity corresponds to $[0]$, and the inverse of $[a]$ corresponds to $[-a]$. Thus $G_p$ is cyclic of order $p$.

Let $V_p=\mathbb{F}_p$, viewed as a one-dimensional vector space over itself. Give $V_p$ the trivial $G_p$-action:

$$
g\cdot x=x
$$

for all $g\in G_p$ and $x\in V_p$.

Finally, define the **coordinate cocycle** $c_p:G_p\to V_p$ by forgetting that the group law was written multiplicatively. If $g$ corresponds to $[a]$, set

$$
c_p(g)=[a].
$$

This map is simply the identity on the underlying set of residues, interpreted as a map from the multiplicatively written group to the additive coefficient space.

> **Lemma 4.1 (Coordinate cocycle law).** For every prime $p$ and all $g,h\in G_p$, the coordinate map satisfies

$$
c_p(gh)=c_p(g)+g\cdot c_p(h).
$$

**Proof.** Write $g=[a]$ and $h=[b]$ in additive coordinates. By definition of the multiplicatively written group, $gh$ has coordinate $[a+b]$. Therefore

$$
c_p(gh)=[a+b]=[a]+[b]=c_p(g)+c_p(h).
$$

The action is trivial, so $g\cdot c_p(h)=c_p(h)$. Substitution gives the desired identity. $\square$

The primality of $p$ is needed to make $\mathbb{Z}/p\mathbb{Z}$ a field, but the cocycle calculation itself is simply modular addition.

## 5. Nontriviality and sharpness

We now prove that the coordinate cocycle cannot be removed by a change of origin.

> **Lemma 5.1 (Vanishing of coboundaries for the trivial action).** Let a group $G$ act trivially on a vector space $V$. Then every degree-one coboundary is identically zero.

**Proof.** A coboundary has the form $g\mapsto v-g\cdot v$ for some $v\in V$. Triviality gives $g\cdot v=v$, so its value at every $g$ is $v-v=0$. $\square$

> **Lemma 5.2 (Nonvanishing of the coordinate cocycle).** For every prime $p$, the coordinate cocycle $c_p$ is not the zero function.

**Proof.** Let $u\in G_p$ be the element whose additive coordinate is $[1]$. Then

$$
c_p(u)=[1].
$$

Because $p$ is prime, $p\ge2$, and $[1]\ne[0]$ in $\mathbb{F}_p$. Hence $c_p$ is nonzero. $\square$

Combining these lemmas gives the first principal conclusion.

> **Theorem 5.3 (Non-coboundary theorem).** For every prime $p$, the coordinate cocycle $c_p:G_p\to\mathbb{F}_p$ for the trivial action is not a coboundary.

**Proof.** If $c_p$ were a coboundary, Lemma 5.1 would make it identically zero. Lemma 5.2 shows that its value on the element with coordinate $[1]$ is nonzero. This is a contradiction. $\square$

The group order also behaves exactly as required to obstruct averaging.

> **Lemma 5.4 (The group order vanishes in the coefficient field).** For every prime $p$, the group $G_p$ has cardinality $p$, and the image of $|G_p|$ in $\mathbb{F}_p$ is zero.

**Proof.** The elements of $G_p$ are the $p$ residue classes modulo $p$, so $|G_p|=p$. By the definition of characteristic $p$, the sum of $p$ copies of $1$ is zero in $\mathbb{F}_p$. Therefore the natural image of $p$ in $\mathbb{F}_p$ is zero. $\square$

We may now state the sharpness result in its complete form.

> **Theorem 5.5 (Uniform counterexample to unconditional averaging).** For every prime $p$, there exist a finite group $G_p$, a one-dimensional vector space $V_p$ over $\mathbb{F}_p$, a linear action of $G_p$ on $V_p$, and a function $c_p:G_p\to V_p$ such that:
>
> 1. $|G_p|=p$, whose image in $\mathbb{F}_p$ is zero;
> 2. $c_p$ satisfies the degree-one cocycle identity $c_p(gh)=c_p(g)+g\cdot c_p(h)$ for every $g,h\in G_p$;
> 3. there is no $v\in V_p$ such that $c_p(g)=v-g\cdot v$ for every $g\in G_p$.
>
> One may take $G_p$ to be the cyclic group of order $p$, $V_p=\mathbb{F}_p$, the action to be trivial, and $c_p$ to be the additive coordinate map.

**Proof.** The cardinality assertion is Lemma 5.4, the cocycle assertion is Lemma 4.1, and the non-coboundary assertion is Theorem 5.3. $\square$

> **Corollary 5.6 (Nonvanishing of first cohomology).** For every prime $p$,

$$
H^1(G_p,\mathbb{F}_p)\ne0
$$

for the trivial action. In fact,

$$
H^1(G_p,\mathbb{F}_p)\cong\operatorname{Hom}(\mathbb{Z}/p\mathbb{Z},\mathbb{F}_p^+)\cong\mathbb{F}_p.
$$

**Proof sketch.** Under the trivial action, cocycles are additive homomorphisms and all coboundaries vanish. A homomorphism from the cyclic group of order $p$ is determined by the image of a generator, which can be any element of $\mathbb{F}_p$. The coordinate cocycle corresponds to the value $1$ and hence generates this one-dimensional cohomology group. $\square$

> **Corollary 5.7 (Sharp boundary for the averaging hypothesis).** The condition that $|G|$ be invertible in the coefficient field cannot be removed from Theorem 3.1. For every possible positive prime characteristic, there is a finite group whose order is zero in the field and for which the conclusion $H^1(G,V)=0$ fails.

This is a logical sharpness statement. The absence of $1/|G|$ is accompanied by an explicit failure of the desired conclusion, not merely by a failure of the standard proof.

## 6. Finite algorithms and numerical demonstrations

Although the theorem is symbolic and uniform in $p$, finite computation offers a useful pedagogical view. Represent $G_p$ and $V_p$ by integers $0,1,\ldots,p-1$, with arithmetic modulo $p$. The coordinate cocycle is

$$
c_p(a)=a\bmod p,
$$

and the trivial action is $a\cdot x=x$.

### 6.1. Exhaustive cocycle verification

For each ordered pair $(a,b)$, compute

$$
L=c_p(a+b\bmod p)
$$

and

$$
R=c_p(a)+c_p(b)\bmod p.
$$

The cocycle law holds exactly when $L=R$ for all $p^2$ pairs. This takes $O(p^2)$ modular arithmetic operations and $O(1)$ auxiliary space if pairs are streamed.

### 6.2. Exhaustive coboundary comparison

For each possible $v\in\mathbb{F}_p$, compute the trivial-action coboundary

$$
b_v(a)=v-v=0.
$$

Comparison with $c_p(1)=1$ immediately rejects every $v$. A literal exhaustive implementation takes $O(p)$ operations, while the mathematical simplification gives a constant-time witness after confirming $p\ge2$.

### 6.3. Example at $p=5$

The coordinate values are

$$
(c_5(0),c_5(1),c_5(2),c_5(3),c_5(4))=(0,1,2,3,4).
$$

For $a=3$ and $b=4$,

$$
c_5(3+4)=c_5(2)=2
$$

and

$$
c_5(3)+c_5(4)=3+4=2\pmod5.
$$

Every coboundary table is $(0,0,0,0,0)$, independently of $v$. The order of the group is represented by

$$
5\bmod5=0.
$$

The same demonstration works unchanged for every prime.

## 7. Conceptual and geometric interpretation

The first cohomology group classifies translational defects in affine actions, modulo translations of the origin. In the present example, $G_p$ acts on the affine line over $\mathbb{F}_p$ by

$$
g\star x=x+c_p(g).
$$

The element with coordinate $a$ translates the line by $a$. This affine action has no global fixed point: if $x$ were fixed by every element, the element with coordinate $1$ would imply $x+1=x$, impossible in a field. The absence of a fixed point is the geometric content of the cocycle’s nontriviality.

In contrast, Theorem 3.1 says that when $|G|$ is invertible, every affine action with prescribed linear part has a fixed point obtained by averaging an orbit. The counterexample therefore marks a fixed-point boundary: modular translation actions can be fixed-point-free precisely in a regime where orbit averaging cannot be normalized.

The example is also the smallest manifestation of modular representation theory. When the characteristic does not divide $|G|$, averaging often splits equivariant constructions. When the characteristic divides $|G|$, extensions need not split and cohomology can survive. Here the nonzero class in $H^1$ is the elementary shadow of that broader failure of semisimplicity.

## 8. Profinite and arithmetic directions

A **profinite group** is an inverse limit of finite groups. If it acts continuously on a finite discrete module, continuous maps often factor through finite quotients. This suggests transferring finite averaging to the continuous setting.

Suppose a profinite group $\Gamma$ is pro-prime-to-$\ell$, meaning that every finite quotient relevant to its topology has order prime to a fixed prime $\ell$. For a finite discrete $\mathbb{F}_\ell$-module, quotient orders are then invertible in $\mathbb{F}_\ell$. A continuous cocycle that factors through such a quotient can be averaged there. One expects, subject to the precise continuity and action hypotheses, a vanishing result for first continuous cohomology.

The cyclic construction shows why the prime-to-$\ell$ condition is structurally appropriate. If a quotient of order divisible by $\ell$ is admitted, the quotient may contain the same phenomenon as $G_\ell$. In particular, pro-$\ell$ groups naturally map onto cyclic groups of order $\ell$, and pulling back the coordinate cocycle can produce nontrivial continuous classes.

These facts feed into several longer programs.

First, étale cohomology of affine curves requires cohomological-dimension and finiteness statements that connect geometric fundamental groups with finite coefficient modules. Prime-to-characteristic vanishing controls which local systems contribute nontrivially.

Second, completed group algebras such as $\mathbb{Z}_\ell[[\Gamma]]$ encode continuous actions over infinite towers. Compact versions of Nakayama’s lemma relate a module to its reduction modulo $\ell$. Establishing when finite reduction corresponds to torsion and vanishing of the Iwasawa $\mu$-invariant requires careful module theory, but finite cohomology supplies foundational inputs.

Third, Selmer structures impose compatible local conditions on global cohomology classes. Cartesian local conditions and Pontryagin duality can turn finite-level control into statements about Iwasawa modules. The sharp boundary identified here warns that local averaging arguments must track the residue characteristic explicitly.

Fourth, deformation theory interprets $H^1$ as a tangent space and $H^2$ as an obstruction space. For framed and unframed deformation functors, degree-two vanishing can imply formal smoothness and power-series presentations of deformation rings. The present degree-one example does not itself settle those questions, but it identifies a basic source of nonvanishing that any obstruction-theoretic development must accommodate.

## 9. Discussion

The counterexample has four notable features.

**Uniformity.** It works for every prime $p$ without modification. Thus no positive characteristic escapes the obstruction.

**Minimality.** The group has the smallest order divisible by the characteristic, and the coefficient space is one-dimensional. The action is trivial, eliminating representation-theoretic complications.

**Transparency.** The cocycle law reduces to modular addition, while non-coboundary status follows because trivial-action coboundaries vanish.

**Exact alignment with averaging failure.** The group order is zero in the coefficient field, exactly preventing the normalization $1/|G|$. The algebraic obstruction and the failure of division coincide.

The result should not be overextended. It does not say that every action in modular characteristic has nonzero $H^1$, nor that averaging has no replacements in special categories. Additional hypotheses may force vanishing. Rather, it refutes a universal theorem lacking any prime-to-characteristic condition and supplies the canonical test case against which proposed generalizations should be checked.

There is also a useful methodological principle. Whenever a proposed vanishing theorem uses an average, one should first test the smallest cyclic subgroup whose order is killed by the coefficients. For degree one with trivial coefficients, this test reduces to asking whether the additive coefficient group receives a nonzero homomorphism from that cyclic group. In characteristic $p$, the answer is immediate: the generator may be sent to $1$. Thus the coordinate construction is not an accidental counterexample but a systematic diagnostic for the precise torsion that normalization by $|G|$ would otherwise remove.

## 10. Future work

The first natural step is to define continuous crossed homomorphisms from profinite groups into finite discrete modules and prove precise finite-quotient factorization results. Once factorization is available, finite averaging should transfer to quotients whose orders are prime to the coefficient characteristic.

A complementary step is to analyze pro-$p$ groups. The cyclic coordinate classes provide finite nonvanishing examples, and inflation along quotient maps should clarify when they survive in continuous cohomology.

Further work can connect these group-cohomological statements to étale cohomology of affine curves, including finiteness and cohomological-dimension bounds. On the algebraic side, completed group algebras and compact Nakayama theory are needed to relate finite reduction modulo $\ell$ to torsion and the vanishing of the Iwasawa $\mu$-invariant.

Finally, defining cartesian Selmer structures, Pontryagin duals, and deformation functors would allow finite cohomology, Iwasawa modules, and obstruction theory to be assembled into arithmetic applications. In that setting, the sharpness theorem remains a useful diagnostic: any vanishing argument based on averaging must ensure that all finite quotients being averaged have order invertible in the coefficient ring.

## 11. Conclusion

For every prime $p$, the cyclic group of order $p$ acting trivially on $\mathbb{F}_p$ admits the coordinate cocycle $c_p(g)=g$. It satisfies the degree-one cocycle identity, is nonzero, and cannot be a coboundary because every coboundary for a trivial action vanishes. Simultaneously, the group order $p$ is zero in the coefficient field.

This uniform family disproves unconditional finite-group cocycle averaging and proves the necessity of a prime-to-characteristic hypothesis in the general degree-one vanishing theorem. The example is elementary enough to compute exhaustively, yet broad enough to identify the obstruction that must be excluded in continuous cohomology and related arithmetic theories.
