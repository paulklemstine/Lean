# Exact and Approximate Security Reductions for Multilinear Graded Encoding Systems

**Aristotle**  
**August 2, 2026**

## Abstract

We develop a self-contained algebraic and probabilistic framework for security reductions involving multilinear Diffie–Hellman challenges and graded encoding systems. Algebraically, a graded system over a commutative monoid consists of level-indexed encoding spaces, canonical encoding maps, and a multiplication that adds levels while representing plaintext multiplication. This interface yields canonical multilinear evaluation and an exact transcript representation of a $k$-ary product challenge. Probabilistically, we model a finite decisional game by two transcript mass functions and define the advantage of a deterministic Boolean distinguisher as the absolute difference of its acceptance probabilities. A perfect reduction is a bijection of transcript spaces preserving mass pointwise in both challenge worlds. We prove that such a reduction preserves each acceptance probability and hence preserves distinguishing advantage exactly. Source hardness therefore transfers to the target without loss, while every strict target attack induces an equally strong source attack. For imperfect simulations on a common finite transcript space, we prove that target advantage is at most source advantage plus the sum of the $\ell^1$ simulation gaps in the random and real worlds. This gives an approximate hardness-transfer theorem with an explicit additive loss. We present executable algorithms for canonical graded evaluation, distinguisher reduction, and finite-game auditing; numerical examples illustrate exact and approximate transfer. The results isolate the assumptions needed for tight reductions and provide a reusable foundation for analyzing candidate multilinear cryptographic constructions.

## 1. Introduction

Graded encoding systems are designed to support controlled algebra on hidden values. An encoding carries not only a concealed plaintext but also a public level. Multiplication combines plaintext values while adding levels. Starting with $k$ level-one encodings, one can therefore reach a level-$k$ encoding of their product. This mechanism abstracts a central feature sought in multilinear cryptography: several independently supplied inputs may participate in a joint computation, while unrestricted algebraic access remains unavailable.

The algebraic capability alone does not establish cryptographic security. A reduction must connect the transcript seen in a target graded-encoding experiment to a source problem believed to be hard, such as a decisional multilinear Diffie–Hellman problem. A useful reduction theorem should answer three questions precisely:

1. What algebraic law guarantees that the encoded target is the intended product?
2. How is a target distinguisher transformed into a source distinguisher?
3. How much distinguishing advantage is lost in this transformation?

This paper answers these questions for finite transcript spaces and deterministic Boolean distinguishers. The framework has two layers. The first is an algebraic interface over a commutative monoid. It records only level-indexed codes, canonical encodings, graded multiplication, and compatibility with plaintext multiplication. The second is a finite probability model for two-world decision games. Keeping the layers separate is useful: candidate-specific algebra can be checked independently of the generic reduction argument.

Our principal exact result concerns a perfect reduction. The source and target transcript spaces are related by a bijection that preserves the probability mass of every corresponding transcript in both worlds. A target distinguisher is pulled back along this bijection. Reindexing a finite sum then proves equality of acceptance probabilities world by world, and equality of advantages follows immediately. Thus a perfect reduction is genuinely lossless.

We also treat approximate simulation. If source and target games share a transcript space but their corresponding mass functions differ, the acceptance probability of any Boolean distinguisher changes by at most the $\ell^1$ gap. Applying this estimate in both worlds and using the triangle inequality gives an additive loss equal to the sum of the two gaps. This form is intentionally valid for finite mass functions at the stated level of generality; under normalization, a sharper half-$\ell^1$ formulation is a natural refinement.

The contribution is foundational rather than candidate-specific. It does not assert that a particular graded encoding construction satisfies a multilinear Diffie–Hellman assumption. Instead, it states exactly what follows once the algebraic interface and the relevant perfect or approximate simulation hypotheses are supplied.

## 2. Algebraic framework

### 2.1 Commutative plaintext multiplication

Let $R$ be a commutative monoid with multiplication written multiplicatively and identity element $1$. Thus, for all $x,y,z\in R$,

$$
(xy)z=x(yz),\qquad xy=yx,\qquad 1x=x1=x.
$$

The use of a monoid rather than a group is deliberate. None of the results below requires division or inverses. The reduction layer therefore applies to any plaintext domain with associative, commutative, unital multiplication.

### 2.2 Graded encoding systems

**Definition 2.1 (Graded encoding system).** A graded encoding system over $R$ consists of:

- a set $C_i$ for every level $i\in\mathbb{N}$;
- a canonical encoding map $E_i:R\to C_i$ for every $i$;
- a graded multiplication map $\odot_{i,j}:C_i\times C_j\to C_{i+j}$ for every $i,j$;
- the compatibility law

$$
E_i(x)\odot_{i,j}E_j(y)=E_{i+j}(xy)
$$

for every $i,j\in\mathbb{N}$ and every $x,y\in R$.

We normally omit the subscripts on $\odot$. The level index is structural: multiplying level $i$ by level $j$ produces level $i+j$. The compatibility law concerns canonical encodings. No claim is required here about equality testing, rerandomization, zero testing, noise growth, or the behavior of noncanonical representatives. Those features belong to more concrete constructions.

### 2.3 Canonical multilinear evaluation

For a finite list $\mathbf{x}=(x_1,\ldots,x_n)$ in $R$, define

$$
\operatorname{Eval}(\mathbf{x})
=E_n\!\left(\prod_{r=1}^{n}x_r\right)\in C_n.
$$

For the empty list, the product is the monoid identity and the value is $E_0(1)$. This definition packages both the arithmetic result and the correct level.

**Theorem 2.2 (Incremental multilinear evaluation).** For every finite list $\mathbf{x}=(x_1,\ldots,x_n)$ and every $x\in R$,

$$
\operatorname{Eval}(\mathbf{x})\odot E_1(x)
=E_{n+1}\!\left(\left(\prod_{r=1}^{n}x_r\right)x\right).
$$

**Proof sketch.** By definition, $\operatorname{Eval}(\mathbf{x})$ is the canonical level-$n$ encoding of $\prod_r x_r$. Apply the compatibility law with levels $n$ and $1$, and with plaintexts $\prod_r x_r$ and $x$. The output level is $n+1$ and the output plaintext is their product. $\square$

The theorem is the one-step form of multilinear evaluation. Iteration computes the canonical encoding of a product while ensuring that each input raises the level by exactly one.

### 2.4 Multilinear Diffie–Hellman source and transcript

Fix $k\in\mathbb{N}$. A $k$-ary source challenge is a tuple

$$
\mathbf{a}=(a_1,\ldots,a_k)\in R^k.
$$

Its multilinear target is

$$
T(\mathbf{a})=\prod_{i=1}^{k}a_i.
$$

**Definition 2.3 (Canonical graded challenge transcript).** The canonical transcript associated with $\mathbf{a}$ consists of the public level-one encodings

$$
E_1(a_1),\ldots,E_1(a_k)
$$

and the level-$k$ target encoding

$$
E_k(T(\mathbf{a})).
$$

**Theorem 2.4 (Canonical challenge-target identity).** The target component of the canonical graded transcript of $\mathbf{a}$ is

$$
E_k\!\left(\prod_{i=1}^{k}a_i\right).
$$

**Proof sketch.** Substitute the definition $T(\mathbf{a})=\prod_i a_i$ into the target component $E_k(T(\mathbf{a}))$. $\square$

Although elementary, this identity is the precise interface between the source tuple and the target transcript. It prevents ambiguity about whether the challenge target represents a sum, product, iterated operation, or differently indexed level.

## 3. Finite decisional games

### 3.1 Two challenge worlds

Let $\Omega$ be a finite set of transcripts. A finite two-world decision game $G$ specifies two mass functions

$$
P^G_0,P^G_1:\Omega\to\mathbb{R},
$$

where world $0$ is the random world and world $1$ is the real world. In probabilistic applications these functions are nonnegative and sum to one. The reduction theorems use only finite summation and the stated mass relations, so their algebraic statements remain meaningful for real-valued finite mass functions.

A deterministic Boolean distinguisher is a function

$$
A:\Omega\to\{0,1\}.
$$

It accepts the subset $S_A=\{\omega\in\Omega:A(\omega)=1\}$.

**Definition 3.1 (Acceptance probability).** The acceptance probability of $A$ in world $b\in\{0,1\}$ is

$$
\operatorname{Acc}^G_b(A)
=\sum_{\omega\in\Omega:A(\omega)=1}P^G_b(\omega).
$$

**Definition 3.2 (Distinguishing advantage).** The absolute distinguishing advantage of $A$ against $G$ is

$$
\operatorname{Adv}^G(A)
=\left|\operatorname{Acc}^G_1(A)-\operatorname{Acc}^G_0(A)\right|.
$$

This is an information-theoretic quantity. Computational restrictions can be imposed later by quantifying only over distinguishers belonging to a chosen efficient class. The present arguments preserve the composed algorithm, so they are compatible with such restrictions whenever the transcript map is efficiently computable.

**Lemma 3.3 (World-swap invariance).** For every game $G$ and distinguisher $A$,

$$
\left|\operatorname{Acc}^G_0(A)-\operatorname{Acc}^G_1(A)\right|
=\operatorname{Adv}^G(A).
$$

**Proof sketch.** This is the symmetry $|u-v|=|v-u|$ of absolute value. $\square$

## 4. Perfect reductions

Let $G_S$ be a source game on a finite set $S$ and $G_T$ a target game on a finite set $T$.

**Definition 4.1 (Perfect reduction).** A perfect reduction from $G_S$ to $G_T$ is a bijection $\phi:S\to T$ satisfying

$$
P^{G_T}_b(\phi(s))=P^{G_S}_b(s)
$$

for every $s\in S$ and both $b\in\{0,1\}$.

The bijection ensures that no transcript is duplicated or omitted. Pointwise mass preservation ensures exact simulation separately in the real and random worlds.

**Definition 4.2 (Reduced distinguisher).** Given a target distinguisher $A:T\to\{0,1\}$, define the source distinguisher $A\circ\phi:S\to\{0,1\}$ by

$$
(A\circ\phi)(s)=A(\phi(s)).
$$

Operationally, the reduction receives a source transcript, translates it through $\phi$, runs the target distinguisher, and returns the same Boolean answer.

### 4.1 Preservation of acceptance

**Theorem 4.3 (Acceptance preservation).** Let $\phi$ be a perfect reduction from $G_S$ to $G_T$. For every target distinguisher $A$ and every world $b$,

$$
\operatorname{Acc}^{G_S}_b(A\circ\phi)
=
\operatorname{Acc}^{G_T}_b(A).
$$

**Proof sketch.** Expand the source acceptance probability:

$$
\operatorname{Acc}^{G_S}_b(A\circ\phi)
=
\sum_{s\in S:A(\phi(s))=1}P^{G_S}_b(s).
$$

Replace each source mass by $P^{G_T}_b(\phi(s))$ using pointwise mass preservation. Since $\phi$ is a bijection, reindexing the finite sum by $t=\phi(s)$ visits every $t\in T$ exactly once. The condition $A(\phi(s))=1$ becomes $A(t)=1$, leaving

$$
\sum_{t\in T:A(t)=1}P^{G_T}_b(t)
=
\operatorname{Acc}^{G_T}_b(A).
$$

$\square$

### 4.2 Exact advantage and hardness transfer

**Theorem 4.4 (Exact advantage preservation).** Under the hypotheses of Theorem 4.3,

$$
\operatorname{Adv}^{G_S}(A\circ\phi)
=
\operatorname{Adv}^{G_T}(A)
$$

for every target distinguisher $A$.

**Proof sketch.** Expand both advantages as absolute differences. Apply Theorem 4.3 once in world $1$ and once in world $0$. Both terms inside the source absolute value become the corresponding target terms. $\square$

This is an equality, not merely an inequality. It identifies a tight security reduction.

**Corollary 4.5 (Lossless hardness transfer).** Suppose that for some $\varepsilon\in\mathbb{R}$ every source distinguisher $B:S\to\{0,1\}$ satisfies

$$
\operatorname{Adv}^{G_S}(B)\leq\varepsilon.
$$

Then every target distinguisher $A:T\to\{0,1\}$ satisfies

$$
\operatorname{Adv}^{G_T}(A)\leq\varepsilon.
$$

**Proof sketch.** Apply the source hardness hypothesis to $B=A\circ\phi$, then replace its source advantage by the equal target advantage using Theorem 4.4. $\square$

**Corollary 4.6 (Attack conversion).** If a target distinguisher $A$ has

$$
\varepsilon<\operatorname{Adv}^{G_T}(A),
$$

then its reduced source distinguisher satisfies

$$
\varepsilon<\operatorname{Adv}^{G_S}(A\circ\phi).
$$

**Proof sketch.** Substitute the equality from Theorem 4.4. $\square$

Corollaries 4.5 and 4.6 express the same reduction in complementary directions. The former says assumed source hardness implies target hardness. The latter says a target attack would violate the source bound.

## 5. Approximate game hops

Perfect transcript equivalences are an ideal case. To quantify imperfect simulation, let two games $G_S$ and $G_T$ be defined on the same finite transcript space $\Omega$.

**Definition 5.1 ($\ell^1$ gap).** For finite mass functions $P,Q:\Omega\to\mathbb{R}$, define

$$
d_1(P,Q)=\sum_{\omega\in\Omega}|P(\omega)-Q(\omega)|.
$$

For a Boolean distinguisher $A$, restricting the sum to its acceptance set gives

$$
\left|
\sum_{A(\omega)=1}P(\omega)
-
\sum_{A(\omega)=1}Q(\omega)
\right|
\leq d_1(P,Q).
$$

This follows by moving the difference inside the finite sum and applying the triangle inequality.

**Theorem 5.2 (Approximate game-hop bound).** Let $A:\Omega\to\{0,1\}$ be any deterministic distinguisher. Suppose

$$
d_1(P^{G_T}_0,P^{G_S}_0)\leq\delta_0
$$

and

$$
d_1(P^{G_T}_1,P^{G_S}_1)\leq\delta_1.
$$

Then

$$
\operatorname{Adv}^{G_T}(A)
\leq
\operatorname{Adv}^{G_S}(A)+\delta_0+\delta_1.
$$

**Proof sketch.** Write the target acceptance difference as

$$
\begin{aligned}
\operatorname{Acc}^{G_T}_1(A)-\operatorname{Acc}^{G_T}_0(A)
={}&\bigl(\operatorname{Acc}^{G_S}_1(A)-\operatorname{Acc}^{G_S}_0(A)\bigr)\\
&+\bigl(\operatorname{Acc}^{G_T}_1(A)-\operatorname{Acc}^{G_S}_1(A)\bigr)\\
&+\bigl(\operatorname{Acc}^{G_S}_0(A)-\operatorname{Acc}^{G_T}_0(A)\bigr).
\end{aligned}
$$

Apply the triangle inequality to the absolute value. The first term becomes source advantage. The absolute second and third terms are bounded by the $\ell^1$ gaps in worlds $1$ and $0$, respectively. Finally apply the assumed bounds $\delta_1$ and $\delta_0$. $\square$

**Corollary 5.3 (Approximate hardness transfer).** If every distinguisher $A$ satisfies

$$
\operatorname{Adv}^{G_S}(A)\leq\varepsilon,
$$

and the world-gap hypotheses of Theorem 5.2 hold, then every distinguisher satisfies

$$
\operatorname{Adv}^{G_T}(A)
\leq\varepsilon+\delta_0+\delta_1.
$$

**Proof sketch.** Combine Theorem 5.2 with the source bound and use transitivity of $\leq$. $\square$

The theorem separates three security costs: intrinsic source advantage, random-world simulation error, and real-world simulation error. This decomposition is useful when the two worlds are simulated by different procedures.

## 6. Algorithms

### 6.1 Canonical graded evaluation

Given plaintexts $x_1,\ldots,x_n$, canonical evaluation can be computed abstractly by multiplying the plaintexts and applying the level-$n$ encoding:

1. Initialize $p\leftarrow 1$.
2. For $i=1$ through $n$, update $p\leftarrow px_i$.
3. Return $E_n(p)$.

This uses $n$ monoid multiplications if the initialization is counted uniformly, or $n-1$ multiplications for a nonempty list initialized at $x_1$, plus one encoding. Alternatively, one may iteratively multiply level-one encodings; Theorem 2.2 certifies the one-step invariant.

### 6.2 Reduction of a target distinguisher

Given a transcript bijection $\phi:S\to T$ and target distinguisher $A$, the reduced algorithm on input $s\in S$ performs:

1. Compute $t\leftarrow\phi(s)$.
2. Compute $a\leftarrow A(t)$.
3. Return $a$.

Its runtime is the runtime of $\phi$ plus that of $A$, with constant composition overhead. In a computational security theorem, the efficiency of $\phi$ is therefore essential even though the information-theoretic equality depends only on bijectivity and mass preservation.

### 6.3 Finite reduction audit

For explicitly enumerated finite games, one can audit a proposed reduction numerically:

1. Verify that $\phi$ maps the source transcript list bijectively onto the target list.
2. For each source transcript $s$ and each world $b$, compare $P^{G_S}_b(s)$ with $P^{G_T}_b(\phi(s))$.
3. For a selected target distinguisher, compute both target acceptance probabilities.
4. Compose the distinguisher with $\phi$ and compute both source acceptance probabilities.
5. Report the two advantages and their difference.
6. If exact preservation fails, compute the corresponding $\ell^1$ world gaps and the additive upper bound.

For $N$ transcripts, each pass is $O(N)$ in time. Storage is $O(N)$ for tabulated distributions and $O(1)$ auxiliary space beyond the tables.

## 7. Numerical examples

### 7.1 Exact preservation under a permutation

Let $S=\{s_0,s_1,s_2,s_3\}$ and $T=\{t_0,t_1,t_2,t_3\}$. Define source masses

$$
P^{G_S}_0=(0.40,0.30,0.20,0.10),
\qquad
P^{G_S}_1=(0.10,0.20,0.30,0.40).
$$

Choose the bijection

$$
\phi(s_0)=t_2,\quad
\phi(s_1)=t_0,\quad
\phi(s_2)=t_3,\quad
\phi(s_3)=t_1,
$$

and define target masses by $P^{G_T}_b(\phi(s_i))=P^{G_S}_b(s_i)$. Let $A$ accept $t_3$ and $t_1$, which are the images of $s_2$ and $s_3$. Then

$$
\operatorname{Acc}^{G_T}_0(A)=0.20+0.10=0.30,
$$

$$
\operatorname{Acc}^{G_T}_1(A)=0.30+0.40=0.70,
$$

and therefore $\operatorname{Adv}^{G_T}(A)=0.40$. The reduced distinguisher accepts exactly $s_2$ and $s_3$, giving the same acceptance probabilities and advantage.

### 7.2 Approximate transfer

Retain the source masses and use target masses on the same ordered space:

$$
P^{G_T}_0=(0.39,0.31,0.21,0.09),
$$

$$
P^{G_T}_1=(0.12,0.19,0.29,0.40).
$$

The world gaps are

$$
\delta_0=0.01+0.01+0.01+0.01=0.04
$$

and

$$
\delta_1=0.02+0.01+0.01+0=0.04.
$$

For any Boolean distinguisher $A$,

$$
\operatorname{Adv}^{G_T}(A)
\leq\operatorname{Adv}^{G_S}(A)+0.08.
$$

If the source game has a universal advantage bound $\varepsilon=0.05$, the theorem yields the target bound $0.13$. The estimate is uniform over all acceptance subsets; it does not depend on selecting a favorable distinguisher after seeing the perturbation.

## 8. Cryptographic interpretation and applications

The framework supports a standard multilinear security narrative. A source experiment samples hidden factors and forms either a genuine encoded product target or a random comparison target. A target construction exposes a graded transcript. To establish a perfect reduction, one identifies every source transcript with exactly one target transcript and proves that this identification preserves mass in both worlds. The target attacker is then run after translation.

This architecture can serve several applications.

**Multipartite key exchange.** Several parties contribute level-one values, and a common level-$k$ expression represents their joint product. The incremental evaluation theorem supplies the algebraic invariant. A decisional security claim still requires suitable distributions and a reduction hypothesis; the algebra alone does not provide hardness.

**Hybrid proofs.** Concrete constructions often pass through intermediate games. The approximate theorem controls one hop. Repeated application yields a sum of per-hop errors, suggesting a general hybrid-chain theorem.

**Candidate comparison.** Two candidate transcript formats may differ only by a lossless reindexing. A perfect reduction shows that this representational difference has no effect on deterministic distinguishing advantage.

**Security accounting.** When simulators are approximate, separate bounds for the real and random worlds make the origin of each loss visible. This is preferable to folding all errors into an opaque constant.

Several limitations should be explicit. The present exact theorem requires a bijection and pointwise mass preservation. Many reductions are randomized, many map multiple source transcripts to one target transcript, and many introduce abort events. Those cases require Markov kernels, pushforward distributions, or subprobability analysis. The current distinguisher is deterministic; randomized distinguishers can be treated by averaging, but that extension is not included in the stated results. Finally, no concrete construction is declared secure solely from the graded compatibility law. Candidate security depends on proving that its actual transcript distributions satisfy the reduction assumptions.

## 9. Discussion

The exact and approximate theorems share a simple principle: distinguishing advantage depends only on acceptance mass in two worlds. A perfect reduction preserves that mass exactly by reindexing. An approximate hop controls its movement by a norm bound. This perspective cleanly separates representational issues from cryptographic assumptions.

The choice of absolute advantage makes the game invariant under swapping world labels. The choice of a finite transcript space makes every argument an elementary finite sum, avoiding measure-theoretic side conditions while covering executable finite experiments. The choice of a commutative monoid makes the algebraic interface minimal. These design decisions reveal which conclusions rely on which assumptions.

The approximate constant is conservative. For normalized probability distributions, the maximal difference in the mass of an event equals total variation distance, conventionally one half of the $\ell^1$ distance. Hence the bound should sharpen to

$$
\operatorname{Adv}^{G_T}(A)
\leq
\operatorname{Adv}^{G_S}(A)
+\frac{1}{2}\delta_0+rac{1}{2}\delta_1
$$

when normalization is available and the gaps are measured by full $\ell^1$ distance. Establishing this refinement requires using cancellation of the signed mass differences, a property unavailable for arbitrary unnormalized mass functions.

The graded algebra also invites a coherence analysis. The one-step theorem handles a canonical evaluation multiplied by one more canonical input. A full theorem should quantify over every binary parenthesization of level-one encodings and account for equalities such as $(i+j)+k=i+(j+k)$ in level expressions. Associativity and commutativity of plaintext multiplication suggest a common canonical result, but an abstract encoding interface may need corresponding coherence data for operations on arbitrary codes.

## 10. Future work

Five concrete directions emerge.

1. **Randomized-distinguisher lifting.** Replace deterministic Boolean distinguishers by Markov kernels to $\{0,1\}$. Exact preservation should follow by transporting acceptance probabilities through a perfect reduction and summing over internal randomness.

2. **Tight statistical loss.** For normalized challenge distributions, sharpen the additive loss from the sum of two $\ell^1$ gaps to half that sum by using total variation distance.

3. **Composable perfect reductions.** Prove that identity maps give perfect reductions, perfect reductions compose, and reduction of distinguishers is functorial. Any finite chain of perfect reductions should then remain exactly lossless.

4. **Hybrid-chain bounds.** For games $G_0,\ldots,G_n$ on a common transcript space, sum the corresponding real- and random-world errors of adjacent hops to bound the endpoint advantage difference.

5. **Canonical graded evaluation coherence.** Show that every binary parenthesization of canonical level-one encodings yields the canonical encoding of the total plaintext product at total level $n$, after identifying the associated natural-number level expressions.

Beyond these directions, computational cost should be integrated explicitly. A tight advantage reduction can still be unsuitable if transcript translation is expensive. Randomized and many-to-one simulations should be expressed through pushforwards or kernels. Concrete constructions should instantiate the algebraic interface and discharge the mass-preservation or gap hypotheses using their actual sampling procedures.

## 11. Conclusion

A graded encoding system turns plaintext multiplication into level-raising encoded multiplication. The canonical multilinear evaluation theorem and challenge-target identity establish the algebraic correctness of this translation. Finite decision games then provide a precise language for security: acceptance is the mass of an adversary’s accepting set, and advantage is the absolute gap between real and random acceptance.

When source and target transcripts are related by a mass-preserving bijection in both worlds, every target distinguisher pulls back to a source distinguisher with identical acceptance probabilities and identical advantage. Source hardness transfers without loss, and every target attack becomes an equally strong source attack. When simulation is approximate, target advantage increases by at most the sum of the two worldwise $\ell^1$ errors, yielding transparent additive security accounting.

Together, these results provide a compact foundation for multilinear Diffie–Hellman reductions in graded encoding systems. They distinguish algebraic correctness from distributional security, identify the hypotheses needed for tightness, and make both perfect and imperfect game transitions quantitatively explicit.
