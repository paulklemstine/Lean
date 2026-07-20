# Causal Loops in Composition: When Order Matters but Coherence Survives

Mathematics often hides its power in rules so familiar that we stop noticing them. One of those rules is associativity. When three actions are composed, we ordinarily assume that it does not matter which pair is combined first:

$$
(x\circ y)\circ z=x\circ(y\circ z).
$$

Addition obeys this law. Matrix multiplication obeys it. The composition of ordinary functions obeys it. Associativity is what lets us write a long chain without drowning in parentheses.

But many layered systems do care about intermediate grouping. A cryptographic protocol may replace one experiment at a time; a distributed computation may package messages in different batches; a parser may build different binary trees from the same string. Two executions can therefore be literally different while still carrying the same operational meaning. Insisting that they be equal erases useful structure. Allowing them to differ arbitrarily destroys predictability.

There is a third option: let the two composites differ, but require a reversible witness that relates them. This is **coherent composition**. It turns a troublesome loop in the order of operations into a controlled path through a higher-dimensional space.

## Equality is not the only kind of sameness

Consider a collection $M$ of arrows or operations. We equip it with a binary composition $x\circ y$, a unit $e$, and an equivalence relation $x\sim y$. Think of $x\sim y$ as saying that there is an invertible transformation from $x$ to $y$. A controlled composition has four requirements:

1. equivalent inputs have equivalent composites;
2. $(x\circ y)\circ z\sim x\circ(y\circ z)$;
3. $e\circ x\sim x$;
4. $x\circ e\sim x$.

The second condition is weak associativity. It does not identify the two parenthesizations as arrows; it supplies an **associator** between them. The last two conditions similarly supply left and right **unitors**.

The special setting studied here is locally thin: between any fixed source and target, there is at most one transformation. This modest condition has a dramatic consequence. Every diagram made from associators and unitors commutes automatically, because any two parallel transformation paths must be the same. In particular, the famous five-edge associator diagram—the pentagon—cannot fail. This is precisely the one-object, locally thin fragment of bicategorical composition. It is not a claim that arbitrary nonassociative systems are higher categories; the equivalence relation, compatibility, associators, unitors, and coherence are essential.

## Three arrows are enough

The distinction between equality and coherent equivalence already appears in a tiny multiplication table. Take three arrows $e$, $a$, and $b$. Let $e$ be a two-sided unit, and define the remaining products by

$$
\begin{array}{c|ccc}
\circ & e & a & b\\ \hline
e & e & a & b\\
a & a & b & a\\
b & b & e & b
\end{array}
$$

Now compose three copies of $a$. Grouping on the left gives

$$
(a\circ a)\circ a=b\circ a=e,
$$

while grouping on the right gives

$$
a\circ(a\circ a)=a\circ b=a.
$$

Since $e\ne a$, composition is genuinely nonassociative. This is not a typographical artifact or a philosophical distinction: the two table entries are different.

Next declare every pair of arrows equivalent. This indiscrete relation is intentionally simple. It gives an invertible transformation between $e$ and $a$, and therefore between the two triple composites. Because transformations are proposition-valued—there is at most one between fixed endpoints—all coherence diagrams commute.

**Three-Arrow Separation Theorem.** There exists a unital three-element composition system in which $(a\circ a)\circ a\ne a\circ(a\circ a)$, yet the two sides are connected by an invertible associator and all parallel coherence paths agree.

The example separates two ideas that ordinary algebra merges: strict equality of results and coherent sameness of results. Its simplicity is also a warning. Since every pair is equivalent, it reveals no competition among distinct higher transformations. Richer models must eventually replace this thin relation with genuine families of transformations.

## Parentheses as a landscape

A long composite is best pictured as a binary tree. Atoms label the leaves; every internal fork means “compose the values below.” For four atoms, for example, $((a\circ b)\circ c)\circ d$ and $a\circ(b\circ(c\circ d))$ are different trees.

A single reassociation rotates one local branch:

$$
((x\circ y)\circ z)\longleftrightarrow x\circ(y\circ z).
$$

We also allow rotations inside the left or right side of a larger expression, reverse moves, and chains of moves. The resulting network is the skeleton of an associahedron, a geometric object whose vertices are parenthesizations and whose edges are elementary rotations.

**Reassociation Soundness Theorem.** If one parenthesized expression can be transformed into another by a finite chain of elementary reassociations, reversals, transitive combinations, or reassociations inside a larger context, then their evaluations are coherently equivalent.

The proof follows the syntax of the chain. A stationary step uses reflexivity; a reversed step inverts its transformation; two consecutive chains compose vertically; a move inside a context uses compatibility of composition; and a basic rotation uses the associator. Thus every legal syntactic route has semantic meaning.

## Strictification: forgetting the route

Sometimes the route matters; sometimes only the destination class matters. We can collapse coherently equivalent arrows into equivalence classes $[x]$. Define

$$
[x]\star[y]=[x\circ y].
$$

Compatibility ensures that this definition does not depend on the chosen representatives. Weak laws then become strict laws.

**Strict Quotient Theorem.** The operation $\star$ on equivalence classes is associative, and $[e]$ is a strict two-sided identity:

$$
([x]\star[y])\star[z]=[x]\star([y]\star[z]),
$$

$$
[e]\star[x]=[x]=[x]\star[e].
$$

The reason is direct. The associator says that the representatives $(x\circ y)\circ z$ and $x\circ(y\circ z)$ lie in the same class. The unitors do the same for $e\circ x$, $x\circ e$, and $x$. In the three-arrow example, the unequal outputs $e$ and $a$ become equal after quotienting.

Strictification is therefore not a repair of a broken operation. It is a change of resolution. At high resolution, one sees different arrows and transformations between them. At low resolution, one sees only equivalence classes, where ordinary associativity returns.

## Fingerprints from bounded continuations

Weak composition raises a security-flavored question: can two words be distinguished before we collapse them? For a finite word $w$ and a length bound $R$, define its bounded right trace by

$$
T_R(w)=\{z:\ |z|\le R\text{ and }z=w\,t\text{ for some word }t\}.
$$

This trace records all bounded words that begin with $w$. If $|w|\le R$, then $w$ itself lies in $T_R(w)$ by choosing the empty continuation.

**Bounded Trace Separation Theorem.** If $|w|\le R$, $|w'|\le R$, and $T_R(w)=T_R(w')$, then $w=w'$. Consequently, embedding the letters of the words as atomic composition expressions also gives identical atomic lists.

Indeed, equality of traces places $w$ in the trace of $w'$, so $w'$ is a prefix of $w$. Reversing the roles shows that $w$ is a prefix of $w'$. Two finite words that are prefixes of one another are equal. The result gives a complete bounded fingerprint for atomic syntax.

This matters cryptographically because quotienting can introduce collisions: distinct strict words may become semantically equivalent. Bounded traces distinguish the strict syntax first, while coherent transformations describe which distinctions are intentionally forgotten.

## The hybrid argument hidden inside coherence

Cryptographic security proofs often compare two experiments through a sequence of hybrids. If each adjacent pair is difficult to distinguish, then the endpoints are difficult to distinguish. Coherent reassociation has exactly this shape.

Let $E_0,E_1,\ldots,E_{k+1}$ be parenthesized expressions, with each $E_i$ related to $E_{i+1}$ by reassociation. Let $s$ assign a real-valued score to each evaluated arrow. Suppose coherent equivalents change the score by at most $\delta$:

$$
|s(x)-s(y)|\le\delta\qquad\text{whenever }x\sim y.
$$

**Reassociation Hybrid Theorem.** The endpoint drift is bounded by

$$
|s(E_0)-s(E_{k+1})|\le(k+1)\delta.
$$

The proof is the triangle inequality written as a telescope:

$$
|p_0-p_{k+1}|\le\sum_{i=0}^{k}|p_i-p_{i+1}|,
$$

where $p_i$ is the score of the evaluation of $E_i$. Reassociation soundness makes each adjacent pair coherently equivalent, and local stability bounds every summand by $\delta$.

This theorem turns coherence into a quantitative resource. Each rotation spends at most $\delta$ units of observational drift. A shorter path through the associahedron yields a tighter security estimate. In future weighted models, different associators could carry different costs, making shortest coherent paths into measures of leakage.

## What loops teach us

The same viewpoint changes how one designs systems. Instead of demanding that every implementation erase its history, one can specify which histories count as equivalent, require composition to preserve that judgment, and budget the cost of moving between them. The strict quotient then supplies a clean public semantics, while the unreduced structure remains available for auditing, optimization, or security analysis. This two-level architecture is useful whenever an interface should look associative even though its execution traces are not.

The central lesson is not that associativity should be abandoned. It is that equality can be too rigid for systems with meaningful intermediate structure. Controlled composition keeps the distinctions while governing them with reversible transformations. Local thinness makes every higher ambiguity harmless; reassociation gives a complete syntax of movement; quotienting recovers strict algebra; traces preserve strict fingerprints; and the hybrid bound translates local coherence into global observational control.

A causal loop, in this sense, is not paradoxical. It is a path whose endpoints may differ as concrete arrows but agree at the appropriate semantic scale. The parentheses do not disappear. They become geometry—and that geometry can be used to reason about composition, algorithms, and security.