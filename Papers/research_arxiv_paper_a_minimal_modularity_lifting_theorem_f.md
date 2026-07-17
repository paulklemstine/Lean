# The Algebraic Core of Minimal Ordinary Modularity Lifting for Genus-Two Siegel Systems

## Abstract

We isolate the commutative-algebra mechanism underlying a minimal ordinary modularity lifting theorem for genus-two Siegel modular forms in the stable-Yoshida setting. Let $\Lambda$ be a weight algebra, let $R$ be a universal minimal ordinary deformation ring, and let $\mathbb T$ be an ordinary Hecke algebra. Assuming the arithmetic comparison is an isomorphism of $\Lambda$-algebras $R\cong\mathbb T$, we prove four consequences. First, for every coefficient $\Lambda$-algebra $A$, $A$-valued deformation points and $A$-valued Hecke eigenpackets are naturally and mutually inversely identified. Consequently every deformation point has a unique modular realization. Second, uniqueness of eigenpackets already follows from any surjective deformation-to-Hecke presentation. Third, freeness over $\Lambda$ transfers in both directions across the comparison, with preservation of finite rank. Fourth, specialization of the weight algebra at a maximal ideal is an integral domain, in fact a field. We give proof sketches, explicit algorithms for transporting points and bases, and finite algebraic examples. The results separate the universal algebraic output of an $R=\mathbb T$ theorem from the deep arithmetic input required to establish that comparison for stable Yoshida residual representations.

## 1. Introduction

Modularity lifting theorems compare two deformation problems. The Galois-theoretic problem organizes lifts of a residual representation satisfying prescribed local and global conditions. The automorphic problem organizes eigensystems of Hecke operators occurring in a chosen space of automorphic forms. Their coordinate rings are traditionally denoted by $R$ and $\mathbb T$. An isomorphism

$$
R\cong\mathbb T
$$

asserts that these apparently different moduli problems have the same algebraic structure.

The motivating arithmetic situation concerns Siegel modular forms of genus two. Their associated Galois representations are four-dimensional and symplectic. The residual representation is assumed to arise from a stable Yoshida lift, namely from automorphic induction of a nearly ordinary Hilbert modular eigencuspform over a real quadratic field. Minimal ramification conditions restrict the permitted deformations, ordinarity controls behavior at the chosen residue characteristic $p$, and regularity hypotheses place classical points in a range where arithmetic comparison techniques operate effectively.

Those arithmetic hypotheses are indispensable for proving the comparison itself. They are not, however, needed to derive its formal consequences. This paper studies the latter in a general commutative-algebra setting. The separation is useful for two reasons. It prevents algebraic consequences from being repeatedly reproved inside arithmetic arguments, and it identifies exactly what remains to be supplied by a stable-Yoshida modularity lifting theorem.

The principal result is a natural bijection, functorial in the coefficient algebra $A$, between maps $R\to A$ and maps $\mathbb T\to A$. In arithmetic language, every minimal ordinary deformation point is modular and determines exactly one Hecke eigenpacket. The same comparison transports free module structures over the weight algebra. A separate cancellation theorem shows that uniqueness needs only a surjection $R\twoheadrightarrow\mathbb T$, while a maximal-ideal argument ensures that residual weight specialization has no zero divisors.

The conclusions are elementary once the comparison exists, but their combined interpretation is substantive. Point transport expresses modularity; inverse transport expresses uniqueness; linear transport expresses freeness; and quotient-field structure controls residual fibers. All are manifestations of one principle: properties and maps invariant under isomorphism belong to the common represented object, not to either presentation.

## 2. Arithmetic and algebraic setting

### 2.1. The weight algebra

Let $\Lambda$ be a commutative ring with identity. In ordinary genus-two applications, $\Lambda$ is an Iwasawa algebra describing a two-dimensional weight space. A typical model is a power-series ring $\mathcal O[[X_1,X_2]]$ over the valuation ring $\mathcal O$ of a finite extension of $\mathbb Q_p$. The two variables record independent weight directions.

A commutative $\Lambda$-algebra is a commutative ring $B$ equipped with a fixed homomorphism $\Lambda\to B$. A homomorphism of $\Lambda$-algebras must commute with these structure maps. Thus all constructions below preserve weight parameters.

### 2.2. The deformation ring

Fix, conceptually, a residual four-dimensional symplectic Galois representation $\bar\rho$ over a finite field of characteristic $p$. Impose a deformation condition: lifts are ordinary at places above $p$, minimally ramified away from $p$, and compatible with the required polarization and determinant data. When this deformation problem is representable, its universal ring is a commutative $\Lambda$-algebra $R$.

For the algebraic results, universality is encoded by maps out of $R$. Given a commutative $\Lambda$-algebra $A$, an **$A$-valued deformation point** is a $\Lambda$-algebra homomorphism

$$
\rho:R\longrightarrow A.
$$

The terminology reflects the intended moduli interpretation, but the proofs require only the displayed map.

### 2.3. The Hecke algebra

Let $\mathbb T$ be the commutative ordinary Hecke algebra attached to the relevant genus-two automorphic space, localized at the maximal ideal determined by $\bar\rho$. It is likewise a $\Lambda$-algebra. An **$A$-valued Hecke eigenpacket** is a $\Lambda$-algebra homomorphism

$$
\phi:\mathbb T\longrightarrow A.
$$

Such a homomorphism simultaneously assigns compatible values in $A$ to all Hecke operators represented in $\mathbb T$.

### 2.4. The comparison datum

The arithmetic input is the following.

**Definition 2.1 (Minimal ordinary comparison datum).** A minimal ordinary comparison datum over $\Lambda$ consists of commutative $\Lambda$-algebras $R$ and $\mathbb T$ together with a $\Lambda$-algebra isomorphism

$$
c:R\overset{\sim}{\longrightarrow}\mathbb T.
$$

In the stable-Yoshida application, producing $c$ is the content of the $R=\mathbb T$ theorem. Nothing in the arguments below proves its existence. Rather, the purpose is to derive its full algebraic output with no hidden arithmetic assumptions.

## 3. Transport of points

Fix a comparison datum and a commutative $\Lambda$-algebra $A$. Define

$$
\operatorname{Def}_A=\operatorname{Hom}_{\Lambda\text{-alg}}(R,A),
\qquad
\operatorname{Eig}_A=\operatorname{Hom}_{\Lambda\text{-alg}}(\mathbb T,A).
$$

There are two natural transport maps. For $\rho\in\operatorname{Def}_A$, set

$$
F_A(\rho)=\rho\circ c^{-1}.
$$

For $\phi\in\operatorname{Eig}_A$, set

$$
G_A(\phi)=\phi\circ c.
$$

Both composites are $\Lambda$-algebra homomorphisms because $c$, $c^{-1}$, $\rho$, and $\phi$ are.

**Lemma 3.1 (Inverse transport on deformation points).** For every $\rho\in\operatorname{Def}_A$,

$$
G_A(F_A(\rho))=\rho.
$$

**Proof sketch.** Associativity of composition and $c^{-1}\circ c=\operatorname{id}_R$ give

$$
G_A(F_A(\rho))=(\rho\circ c^{-1})\circ c
=\rho\circ(c^{-1}\circ c)=\rho.
$$

**Lemma 3.2 (Inverse transport on eigenpackets).** For every $\phi\in\operatorname{Eig}_A$,

$$
F_A(G_A(\phi))=\phi.
$$

**Proof sketch.** Similarly,

$$
F_A(G_A(\phi))=(\phi\circ c)\circ c^{-1}
=\phi\circ(c\circ c^{-1})=\phi.
$$

Together the lemmas yield the main pointwise statement.

**Theorem 3.3 (Abstract Minimal Modularity Lifting Theorem).** Let $R$ and $\mathbb T$ be commutative $\Lambda$-algebras equipped with a $\Lambda$-algebra isomorphism $c:R\to\mathbb T$. For every commutative $\Lambda$-algebra $A$ and every deformation point $\rho:R\to A$, there exists a unique Hecke eigenpacket $\phi:\mathbb T\to A$ such that

$$
\phi\circ c=\rho.
$$

Explicitly, $\phi=\rho\circ c^{-1}$. Equivalently, the sets $\operatorname{Def}_A$ and $\operatorname{Eig}_A$ are naturally bijective.

**Proof sketch.** Existence follows by defining $\phi=\rho\circ c^{-1}$ and applying Lemma 3.1. If $\psi\circ c=\rho$, then

$$
\psi=\psi\circ c\circ c^{-1}=\rho\circ c^{-1}=\phi,
$$

which proves uniqueness. Lemmas 3.1 and 3.2 show that the two transport operations define a bijection.

The theorem is stronger than a correspondence of field-valued classical points. Since $A$ is arbitrary, it also treats integral coefficients, Artinian coefficient rings carrying infinitesimal information, and larger families over auxiliary parameter rings.

**Proposition 3.4 (Naturality in coefficients).** If $f:A\to B$ is a homomorphism of commutative $\Lambda$-algebras, then transport commutes with extension of coefficients:

$$
f\circ F_A(\rho)=F_B(f\circ\rho),
$$

and similarly $f\circ G_A(\phi)=G_B(f\circ\phi)$.

**Proof sketch.** Both identities follow from associativity of function composition. For example,

$$
f\circ(\rho\circ c^{-1})=(f\circ\rho)\circ c^{-1}.
$$

Thus the point correspondence is not a collection of unrelated bijections. It is compatible with every change of coefficient algebra.

## 4. Uniqueness from a surjective presentation

An isomorphism is needed to transport points in both directions. Uniqueness alone requires less.

**Theorem 4.1 (Surjective Eigenpacket Uniqueness).** Let $q:R\to\mathbb T$ be a surjective homomorphism of commutative $\Lambda$-algebras. Let $A$ be a commutative $\Lambda$-algebra, and let $\phi,\psi:\mathbb T\to A$ be $\Lambda$-algebra homomorphisms. If

$$
\phi\circ q=\psi\circ q,
$$

then $\phi=\psi$.

**Proof sketch.** For any $t\in\mathbb T$, surjectivity supplies $r\in R$ with $q(r)=t$. Therefore

$$
\phi(t)=\phi(q(r))=(\phi\circ q)(r)
=(\psi\circ q)(r)=\psi(q(r))=\psi(t).
$$

The maps agree at every element of $\mathbb T$.

**Remark 4.2 (Necessity of surjectivity).** If $q$ is not surjective, the conclusion can fail. For example, let $R=k$, let $\mathbb T=k[x]$, and let $q$ include constants. Evaluation at $x=0$ and evaluation at $x=1$ are distinct maps $k[x]\to k$ that agree after composition with $q$. Thus agreement on deformation data determines an eigenpacket only when that data reaches all Hecke coordinates.

In arithmetic terms, Theorem 4.1 isolates the cancellation step behind uniqueness of an ordinary family. Very regular weight hypotheses may enter the proof that the relevant presentation is surjective or that a local component is suitably controlled; they do not enter the cancellation argument itself.

## 5. Freeness over weight space

The comparison map is also an isomorphism of $\Lambda$-modules. This transfers bases and all module-theoretic properties invariant under linear equivalence.

**Theorem 5.1 (Bidirectional Freeness Transfer).** Let $c:R\to\mathbb T$ be an isomorphism of commutative $\Lambda$-algebras. Then $R$ is a free $\Lambda$-module if and only if $\mathbb T$ is a free $\Lambda$-module.

**Proof sketch.** Suppose first that $\mathbb T$ has a $\Lambda$-basis $(e_i)_{i\in I}$. Then $(c^{-1}(e_i))_{i\in I}$ spans $R$: for $r\in R$, expand $c(r)=\sum_i\lambda_i e_i$ and apply $c^{-1}$ to obtain $r=\sum_i\lambda_i c^{-1}(e_i)$. Linear independence follows by applying $c$ to any relation among the $c^{-1}(e_i)$. Hence $R$ is free. The converse transports a basis of $R$ through $c$.

**Corollary 5.2 (Finite rank preservation).** Under the hypotheses of Theorem 5.1, if either ring is finite free of rank $n$ over $\Lambda$, then the other is finite free of rank $n$.

**Proof sketch.** Transporting a basis with exactly $n$ elements gives a basis with exactly $n$ elements. Equivalently, isomorphic finite free modules have equal rank.

In geometric language, finite freeness makes the corresponding affine morphism to weight space finite and flat with constant algebraic rank. The theorem does not prove that either side is free; it proves that freeness, once known on the Hecke side or deformation side, belongs equally to the other.

### 5.1. Basis-transport algorithm

If the comparison and a basis are explicit, the proof yields an algorithm.

1. Input a $\Lambda$-basis $e_1,\ldots,e_n$ of $\mathbb T$.
2. Compute $r_i=c^{-1}(e_i)$ for each $i$.
3. Output $r_1,\ldots,r_n$ as a basis of $R$.

The algorithm makes $n$ evaluations of $c^{-1}$. If each evaluation costs $C_c$, the transport costs $O(nC_c)$. In coordinate representations where $c$ is an invertible $n\times n$ matrix, precomputing its inverse by Gaussian elimination costs $O(n^3)$ field operations, after which transporting vectors costs $O(n^2)$ per full basis matrix.

## 6. Maximal specialization and residual integrality

A weight specialization is encoded by a quotient of $\Lambda$. Maximal ideals give residue fields.

**Theorem 6.1 (Residual Weight Ring Theorem).** Let $\Lambda$ be a commutative ring with identity and let $\mathfrak m$ be a maximal ideal. Then $\Lambda/\mathfrak m$ is a field. In particular, it is an integral domain.

**Proof sketch.** Let $[a]$ be a nonzero class in $\Lambda/\mathfrak m$. Then $a\notin\mathfrak m$. The ideal $\mathfrak m+(a)$ strictly contains $\mathfrak m$, so maximality implies $\mathfrak m+(a)=\Lambda$. Therefore $1=m+ab$ for some $m\in\mathfrak m$ and $b\in\Lambda$. Passing to the quotient gives $[a][b]=[1]$. Every nonzero class is invertible, so the quotient is a field. If $[a][b]=0$ and $[a]\ne0$, multiplying by $[a]^{-1}$ gives $[b]=0$; hence there are no zero divisors.

This result concerns the residual weight ring itself. It does not by itself assert that every specialized deformation or Hecke algebra is reduced, irreducible, or étale. Such conclusions require additional flatness, ramification, or fiberwise hypotheses.

## 7. Computational models and algorithms

The abstract results can be illustrated with finite presentations and finite residue rings.

### 7.1. A rank-two comparison

Let

$$
\Lambda=\mathbb Z,
\qquad
R=\mathbb Z[x]/(x^2-2),
\qquad
\mathbb T=\mathbb Z[y]/(y^2-2).
$$

Define $c:R\to\mathbb T$ by $c(x)=y$. Every element has unique coordinates $a+bx$ or $a+by$, so $c$ is an isomorphism with inverse $y\mapsto x$. Both rings are free of rank $2$ over $\mathbb Z$.

Let $A=\mathbb F_7$. Since $3^2\equiv2\pmod7$, the assignment $x\mapsto3$ defines a deformation point $R\to\mathbb F_7$. Transport gives the unique eigenpacket with $y\mapsto3$. The same point may also use $x\mapsto4$, since $4^2\equiv2\pmod7$; it transports to $y\mapsto4$. Distinct deformation points correspond to distinct eigenpackets, while each individual point has one image.

### 7.2. Surjective cancellation in finite rings

Let $R=\mathbb Z/12\mathbb Z$, $\mathbb T=\mathbb Z/6\mathbb Z$, and let $q$ be reduction modulo $6$. This map is surjective. Any two homomorphisms from $\mathbb T$ into a target ring that agree after precomposition with $q$ must agree on the six residue classes, because every class has a preimage among the twelve classes of $R$.

A computational uniqueness test for finite rings proceeds as follows:

1. Verify that every element of $\mathbb T$ occurs as $q(r)$ for some $r\in R$.
2. Verify $(\phi\circ q)(r)=(\psi\circ q)(r)$ for every $r\in R$.
3. For each $t\in\mathbb T$, choose a stored preimage $r_t$.
4. Conclude $\phi(t)=\psi(t)$ from equality at $r_t$.

For explicitly enumerated finite sets, constructing the preimage table costs $O(|R|)$ evaluations and checking the composites also costs $O(|R|)$. The final comparison costs $O(|\mathbb T|)$.

### 7.3. Two-variable residual specialization

Take

$$
\Lambda=\mathbb Z[u,v],
\qquad
\mathfrak m=(5,u-2,v-3).
$$

Evaluation followed by reduction modulo $5$ gives

$$
f(u,v)\longmapsto f(2,3)\bmod5.
$$

Its kernel is $\mathfrak m$, and its image is $\mathbb F_5$. Hence $\Lambda/\mathfrak m\cong\mathbb F_5$, a field. Numerically, the polynomial $u^2+uv+2v+1$ specializes to

$$
2^2+(2)(3)+2(3)+1=17\equiv2\pmod5.
$$

The nonzero residue $2$ has inverse $3$, since $2\cdot3\equiv1\pmod5$.

## 8. Applications to stable-Yoshida ordinary families

Assume now that the arithmetic work in the stable-Yoshida setting produces a $\Lambda$-algebra isomorphism between the universal minimal ordinary deformation ring and the localized genus-two ordinary Hecke algebra.

First, Theorem 3.3 says that every coefficient-valued minimal ordinary Galois deformation point arises from exactly one Hecke eigenpacket. This is the universal mapping form of minimal modularity lifting. It applies uniformly to residue fields, valuation rings, and infinitesimal coefficient algebras.

Second, Theorem 5.1 transfers freeness. If the localized ordinary Hecke algebra is known to be free over the two-variable Iwasawa algebra, then so is the universal deformation ring. Conversely, deformation-theoretic freeness implies Hecke-theoretic freeness. Corollary 5.2 preserves the rank, although identifying that rank with an automorphic multiplicity requires further arithmetic information.

Third, Theorem 4.1 explains uniqueness of ordinary families through a classical eigenform whenever the deformation-to-Hecke presentation is surjective in the relevant local setting. The theorem itself is global algebraic cancellation. Translating it into uniqueness of a geometric branch may additionally require reducedness or local control of the weight map.

Fourth, Theorem 6.1 guarantees that specialization at a maximal weight ideal has a residue field and hence no zero divisors at the level of the weight ring. This supplies a clean base for residual arguments but should not be confused with integrality of an arbitrary fiber algebra over that field.

## 9. Conceptual interpretation: represented arithmetic spaces

The preceding results admit a useful geometric reading. For each coefficient algebra $A$, the set $\operatorname{Hom}_{\Lambda\text{-alg}}(R,A)$ is the set of $A$-valued points of the affine space represented by $R$, while $\operatorname{Hom}_{\Lambda\text{-alg}}(\mathbb T,A)$ is the analogous set for the Hecke space. Theorem 3.3 identifies these point sets for every $A$ and does so compatibly with every map $A\to B$. Thus the comparison does not merely pair selected numerical solutions. It identifies the complete functors of points, including nilpotent directions visible only over nonreduced coefficient rings.

This distinction matters for families. A field-valued point records eigenvalues at one specialization, but a map to a dual-number ring such as $k[\varepsilon]/(\varepsilon^2)$ also records a first-order tangent direction. Since transport works for arbitrary $A$, tangent information crosses the comparison along with ordinary points. The theorem therefore supports deformation-theoretic statements about infinitesimal neighborhoods, provided the relevant arithmetic deformation condition is genuinely represented by $R$.

Freeness has a complementary geometric meaning. When $R$ is finite free of rank $n$ over $\Lambda$, its structure morphism to weight space is finite flat of constant degree $n$ in the module-theoretic sense. The comparison says that the Hecke presentation has exactly the same finite flat structure. However, constant degree does not prevent sheets from meeting or ramifying. Detecting such behavior requires the module of relative differentials, tangent maps, or Selmer-theoretic obstruction groups.

Finally, the surjective uniqueness principle is best viewed as a statement about coordinates. If every Hecke function is the image of a deformation function, then two Hecke points agreeing on all deformation coordinates agree on every function and hence are the same point. Without surjectivity, unobserved Hecke coordinates remain and may separate points. This geometric interpretation explains both the force and the exact boundary of the cancellation theorem.

## 10. Scope and limitations

The results deliberately do not claim an unconditional stable-Yoshida modularity lifting theorem. The comparison $R\cong\mathbb T$ remains an input. Its proof must address the construction of the Galois representation valued in the Hecke algebra, local-global compatibility, ordinary local conditions, minimal ramification, symplectic polarization, residual irreducibility, and an appropriate numerical or patching criterion.

Nor does freeness alone imply generic étaleness. A finite free algebra can be ramified. Étaleness is controlled by differentials or tangent spaces and is expected to relate to adjoint Selmer groups. Similarly, pointwise uniqueness under an isomorphism does not automatically classify all geometric components through a singular specialization unless the relevant local rings and coefficient categories are specified.

These boundaries sharpen rather than weaken the conclusions. They distinguish universal transport statements from arithmetic assertions about how the common space sits over weight space.

## 11. Future directions

An integral stable-Yoshida theorem should establish the comparison before inverting $p$. The stable Yoshida description may reduce the four-dimensional residual problem to controlled two-dimensional data while retaining the symplectic polarization required on the Siegel side.

A second goal is to prove that the common ring is finite flat and generically étale over the two-variable Iwasawa algebra, and to identify its rank with the multiplicity of the ordinary Hecke component. Freeness supplies constant rank; generic étaleness should reflect vanishing of adjoint Selmer obstructions at a dense set of classical points.

A third direction is rigidity beyond very regular weights. The natural boundary for uniqueness may be governed not by a numerical regularity inequality alone but by the reducedness and local degree of the weight map. This suggests locating an explicit congruence or endoscopic locus where uniqueness fails.

Finally, failure of uniqueness should carry information. At critical or congruence points, tangent directions of distinct companion families are expected to be detected by ordinary adjoint Selmer groups and partitioned by refinements of the local crystalline representation.

## 12. Conclusion

The algebraic consequences of a minimal ordinary $R=\mathbb T$ theorem form a single transport package. An isomorphism identifies deformation points with eigenpackets over every coefficient algebra and makes the identification natural under coefficient change. Surjectivity alone gives cancellation and uniqueness. Linear equivalence transfers freeness and finite rank. Maximal specialization of weight space produces an integral domain.

For genus-two Siegel systems arising from stable Yoshida residual representations, these statements clarify the architecture of modularity lifting. Deep arithmetic constructs the comparison; universal algebra then supplies modularity, uniqueness, and freeness without further case-by-case argument. This separation provides both a concise endpoint for an arithmetic proof and a precise map of the questions—integrality, rank, étaleness, and companion-family geometry—that lie beyond it.
