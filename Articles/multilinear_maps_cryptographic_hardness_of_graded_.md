# The Algebraic Elevator: Why Graded Encodings Carry Cryptographic Hardness Upward

## A controlled way to multiply secrets

Some cryptographic ideas begin with a lock, a key, and a message. Multilinear cryptography begins with a stranger image: an elevator whose buttons are numbered by algebraic “levels.” At level one, we may hold encodings of individual hidden quantities. Multiplying two such encodings takes us to level two; multiplying again takes us to level three. The elevator moves upward, but it does not offer a convenient way back down.

That asymmetry is useful. It lets a system reveal a carefully limited computation on hidden data—most importantly, the product of several secret factors—without simply revealing those factors. Such mechanisms are called **graded encoding systems**. They have been proposed as ingredients for advanced cryptographic constructions, including multipartite key exchange, constrained computation, and forms of functional encryption.

The central question is not merely whether this algebra works. It is whether security travels with it. Suppose a familiar multilinear Diffie–Hellman source problem is assumed hard: no efficient observer can reliably distinguish the genuine product of hidden inputs from a random impostor. If that source challenge is translated into a graded encoding transcript, does the target system inherit exactly the same hardness? And what happens if the translation is only approximate?

The mathematical framework developed here gives sharp answers for finite transcript spaces and deterministic Boolean distinguishers. Under a perfect translation, distinguishing advantage is preserved **exactly**—not just bounded, and not diminished by an unspecified constant. Under an approximate translation, the security loss is at most the sum of the errors in the two challenge worlds.

## Levels as an algebraic type system

Begin with a commutative monoid $R$. This means that elements of $R$ can be multiplied, multiplication is associative and commutative, and there is a multiplicative identity. No inverses are required. This deliberately spare assumption covers a broad range of plaintext structures.

A graded encoding system assigns a collection $C_i$ of encodings to every level $i\in\mathbb{N}$. It supplies a canonical encoding map

$$
E_i:R\longrightarrow C_i
$$

and a graded multiplication operation

$$
\odot:C_i\times C_j\longrightarrow C_{i+j}.
$$

The essential compatibility law is

$$
E_i(x)\odot E_j(y)=E_{i+j}(xy).
$$

This single equation is the algebraic engine. It says that multiplying encodings both multiplies their hidden plaintexts and adds their public levels.

For a list $x_1,\ldots,x_n$ of plaintext values, define its canonical multilinear evaluation to be

$$
\mathcal{E}(x_1,\ldots,x_n)=E_n\!\left(\prod_{r=1}^{n}x_r\right).
$$

The first structural result is an incremental evaluation law. If one more plaintext $x$ is appended, then

$$
\mathcal{E}(x_1,\ldots,x_n)\odot E_1(x)
=E_{n+1}\!\left(\left(\prod_{r=1}^{n}x_r\right)x\right).
$$

The proof is immediate from the compatibility law: the existing evaluation is a level-$n$ canonical encoding, the new input is at level one, and graded multiplication lands at level $n+1$ while multiplying the plaintexts. Simple as it looks, this law makes the bookkeeping exact. The number of combined inputs and the output level can never drift apart.

## The multilinear Diffie–Hellman challenge

Fix a positive arity $k$. A source challenge consists of plaintext exponents

$$
a_1,a_2,\ldots,a_k\in R,
$$

with target

$$
t=\prod_{i=1}^{k}a_i.
$$

Its canonical public transcript contains the level-one encodings $E_1(a_i)$ and the level-$k$ target encoding $E_k(t)$. The challenge-target theorem states that this final component is exactly

$$
E_k\!\left(\prod_{i=1}^{k}a_i\right).
$$

This may sound definitional, but it fixes the bridge between two descriptions of the challenge: one as a tuple of source values and their product, the other as a typed, graded transcript. Security arguments become fragile when these layers are left implicit. Here the bridge is explicit and exact.

A decision problem then offers one of two worlds. In the **real world**, the target is related to the public inputs in the prescribed multilinear way. In the **random world**, it is sampled according to the comparison distribution. An observer receives the transcript and outputs either true or false.

For a finite transcript space $\Omega$, let $P_b(\omega)$ be the probability mass of transcript $\omega$ in world $b\in\{0,1\}$. If a distinguisher $A:\Omega\to\{0,1\}$ accepts some subset of transcripts, its acceptance probability in world $b$ is

$$
\operatorname{Acc}_b(A)=\sum_{\omega:A(\omega)=1}P_b(\omega).
$$

Its distinguishing advantage is

$$
\operatorname{Adv}(A)=
\left|\operatorname{Acc}_1(A)-\operatorname{Acc}_0(A)\right|.
$$

Swapping the names “real” and “random” does not change this quantity, because $|u-v|=|v-u|$. This symmetry is useful: security should not depend on which Boolean label happens to name which world.

## A lossless security bridge

Now imagine a source game with transcript space $S$ and a target graded-encoding game with transcript space $T$. A **perfect reduction** consists of a bijection

$$
\phi:S\longrightarrow T
$$

that preserves probability mass point by point in both worlds:

$$
P^{T}_b(\phi(s))=P^{S}_b(s)
\qquad
\text{for every }s\in S\text{ and }b\in\{0,1\}.
$$

Given a target distinguisher $A:T\to\{0,1\}$, the reduction constructs a source distinguisher by composition:

$$
B(s)=A(\phi(s)).
$$

The Acceptance Preservation Theorem says that, in each world separately,

$$
\operatorname{Acc}^{S}_b(B)=\operatorname{Acc}^{T}_b(A).
$$

Why? The bijection merely renames the finite transcripts. Summing over all source points accepted by $B$ is the same as summing over their target images accepted by $A$, and corresponding points have equal mass.

Taking the absolute difference of the two preserved acceptance probabilities yields the **Exact Advantage Preservation Theorem**:

$$
\operatorname{Adv}^{S}(B)=\operatorname{Adv}^{T}(A).
$$

This equality is the heart of the reduction. There is no security loss hidden in notation. Every successful target attack becomes an equally successful source attack.

Two consequences follow immediately. First, if every source distinguisher has advantage at most $\varepsilon$, then every target distinguisher also has advantage at most $\varepsilon$. Second, if a target attacker achieves advantage strictly greater than $\varepsilon$, its composed source distinguisher also achieves advantage strictly greater than $\varepsilon$. The first statement transfers hardness forward; the second turns an attack backward into a solver for the assumed-hard source problem.

This is cryptographic reductionism in its cleanest form. The target construction need not be argued secure from scratch. Instead, a hypothetical crack in the graded system is wired into a crack in the multilinear Diffie–Hellman source game, with precisely the same statistical strength.

## When the elevator shakes: approximate simulation

Real cryptographic simulations are often imperfect. A translated game may not preserve each transcript probability exactly. The framework therefore also measures approximation.

For two finite mass functions $P$ and $Q$ on the same transcript space, define their $\ell^1$ gap by

$$
\|P-Q\|_1=\sum_{\omega\in\Omega}|P(\omega)-Q(\omega)|.
$$

Suppose source and target games share the same transcript space. Assume the random worlds differ by at most $\delta_0$ and the real worlds by at most $\delta_1$:

$$
\|P^T_0-P^S_0\|_1\leq\delta_0,
\qquad
\|P^T_1-P^S_1\|_1\leq\delta_1.
$$

Then the **Approximate Game-Hop Theorem** states that every deterministic Boolean distinguisher satisfies

$$
\operatorname{Adv}^{T}(A)
\leq
\operatorname{Adv}^{S}(A)+\delta_0+\delta_1.
$$

The idea is a three-part triangle inequality. Insert the two source acceptance probabilities between the target real and target random acceptance probabilities. The middle difference is the source advantage. The two outer differences are controlled by the $\ell^1$ discrepancies in the corresponding worlds. Adding these three contributions gives the bound.

Consequently, if the source game is $\varepsilon$-hard, then the target game is at most

$$
\varepsilon+\delta_0+\delta_1
$$

distinguishable. Perfect reductions are recovered as the special case $\delta_0=\delta_1=0$.

## A numerical glimpse

Consider four transcripts with source masses

$$
P^S_0=(0.40,0.30,0.20,0.10),
\qquad
P^S_1=(0.10,0.20,0.30,0.40).
$$

Let a distinguisher accept the last two transcripts. Its random-world acceptance is $0.30$, its real-world acceptance is $0.70$, and its advantage is $0.40$. Any perfect mass-preserving permutation of the transcript labels produces a target distinguisher with exactly the same two acceptance probabilities and the same $0.40$ advantage.

Now perturb the target worlds slightly. If their $\ell^1$ gaps from the source worlds are $0.04$ and $0.06$, then regardless of the acceptance rule, target advantage is bounded by source advantage plus $0.10$. The actual loss may be smaller; the theorem supplies a universal guarantee.

## Why this architecture matters

The algebra and the probability theory play distinct roles. The graded system proves that canonical multiplication reaches the intended level and represents the intended plaintext product. The decision-game layer then treats transcripts abstractly, caring only about finite probability masses and the observer’s acceptance set. This separation makes the reduction reusable: the security theorem does not depend on a particular candidate encoding scheme, and the algebraic interface does not depend on a particular adversary.

There are practical lessons here. A cryptographic construction should expose its transcript transformation clearly enough to ask whether it is bijective and mass preserving. If it is, the reduction is tight. If not, one should quantify the discrepancy in each world rather than hiding approximation behind an informal claim that two games are “close.” The resulting security budget becomes auditable: source hardness contributes $\varepsilon$, random-world simulation contributes $\delta_0$, and real-world simulation contributes $\delta_1$.

The framework also points toward richer developments. Randomized distinguishers can be modeled by probabilities of acceptance rather than Boolean subsets. Normalized distributions should permit the familiar factor of one half relating total variation distance to $\ell^1$ distance. Perfect reductions ought to compose, so a long chain of lossless translations remains lossless. Approximate hops should accumulate along hybrid arguments. Finally, the algebraic side invites a coherence theorem showing that every parenthesization of many level-one products yields the same canonical result at the same total level.

The larger message is simple. Multilinear cryptography asks us to trust a ladder of encodings whose levels rise as hidden values multiply. A sound security argument needs a ladder of its own: plaintext products become graded transcripts, target observers become source observers, and distributional errors become explicit additive terms. When every rung is stated precisely, hardness can be carried upward without mystery—and, in the perfect case, without losing even a fraction of advantage.
