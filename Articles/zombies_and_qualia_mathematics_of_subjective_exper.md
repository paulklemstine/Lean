# The Shape of What Observation Leaves Out

## Zombies, qualia, and the geometry of indistinguishability

Imagine two systems placed behind a wall. Ask them questions, inspect every available signal, test their memories, measure their reactions, and challenge them with new situations. Every answer is the same. Every observable transition is the same. If one recoils from pain, the other recoils at precisely the same moment. If one writes a poem about the redness of sunset, so does the other.

Now suppose—only as a mathematical thought experiment—that one system has experience and the other does not. Nothing in their measured behavior separates them. Yet one has an inner light and the other is dark.

This is the philosophical-zombie scenario. Mathematics cannot decide whether such creatures exist in nature. It can, however, expose exactly what must be assumed before the scenario is coherent, what observation can and cannot recover, and why a similar shape appears in mathematical incompleteness.

The central idea is geometric: observation compresses a total state into a behavioral profile. Whenever several total states receive the same profile, they form a **fibre**—a collection of possibilities that observation treats as one point. Subjective experience can be hidden inside such a fibre. The resulting gap is not mystical; it is the ordinary mathematical phenomenon of information discarded by a map.

## A map that forgets

Let $X$ be a space of total states and $B$ a space of observable behavioral profiles. A functional description is a map

$$
F:X\to B.
$$

Two states $x,y\in X$ are **functionally identical** when

$$
F(x)=F(y).
$$

Let experience be represented, in the simplest possible model, by a Boolean observable

$$
E:X\to\{0,1\},
$$

where $E(x)=1$ means “aware” and $E(x)=0$ means “experientially void.” An **oriented zombie pair** is a pair $(x,z)$ satisfying

$$
F(x)=F(z),\qquad E(x)=1,\qquad E(z)=0.
$$

The orientation matters: the first state is aware, the second is void. This definition says nothing about biology or metaphysics. It identifies the precise structural claim at issue: experience varies while all recorded function remains fixed.

The cleanest laboratory is the **split model**

$$
X=B\times\{0,1\}.
$$

A total state $(b,q)$ contains a behavioral profile $b$ and an experiential bit $q$. Functional observation keeps the first coordinate and forgets the second:

$$
F(b,q)=b,\qquad E(b,q)=q.
$$

This construction deliberately builds the disputed gap into the state space. That is a feature, not a trick: it makes the hidden assumption visible.

## The reversible switch

In the split model there is a canonical operation that changes experience while preserving behavior:

$$
Q(b,q)=(b,1-q).
$$

Call this the **qualia flip**. It has two immediate properties. First, it leaves the functional profile unchanged: $F(Q(b,q))=b=F(b,q)$. Second, applying it twice returns the original state:

$$
Q(Q(b,q))=(b,q).
$$

Thus the qualia flip is a fibre-preserving involution: a reversible switch operating entirely inside each observational fibre.

From this comes the **Unique Zombie Twin Theorem**: for every aware split state $(b,1)$, there is exactly one functionally identical void state, namely $(b,0)$. Existence is obvious from the construction; uniqueness follows because matching the behavior forces the first coordinate to equal $b$, while being void forces the second coordinate to equal $0$.

This theorem is conditional. It does not claim that real conscious systems possess an independent Boolean switch. It says that once total state has the split form $B\times\{0,1\}$, the zombie twin is neither vague nor ambiguous: it is canonical and unique.

## A whole universe of gaps, classified

Consider all oriented zombie pairs in the split model. Each one must look like

$$
((b,1),(b,0))
$$

for one and only one profile $b\in B$. Therefore the space of experiential gaps is in one-to-one correspondence with the behavioral space $B$ itself.

This is the **Experiential Gap Classification Theorem**. The correspondence sends a gap to its common behavioral label $b$; the inverse sends $b$ to the pair $((b,1),(b,0))$. Going there and back changes nothing in either direction.

This result offers an unusual perspective. Adding an invisible experiential contrast does not double the number of *oriented gaps*. There is exactly one aware-to-void gap over each behavioral profile. The moduli space—the space classifying all such gaps—is simply $B$.

Suppose $B$ also carries a distance $d$, measuring functional dissimilarity. Pull that distance back to total states by comparing only their observed profiles:

$$
d_F(x,y)=d(F(x),F(y)).
$$

Then every zombie pair has zero functional distance. Indeed, $F(x)=F(z)$, so

$$
d_F(x,z)=d(F(x),F(z))=d(F(x),F(x))=0.
$$

This is the **Zero Functional Distance Theorem**. The experiential contrast is maximal in the Boolean coordinate, yet invisible to the functional metric. It resembles situations in data science where two objects occupy the same point after feature extraction even though they differ in a discarded attribute. A metric on the compressed representation cannot recover information that compression erased.

## When can behavior recover experience?

The most important boundary result applies to any state space, not only the split model. Ask whether experience can be reconstructed from functional data. More precisely, does there exist a rule $e$ on the actually attained behavioral profiles such that

$$
E(x)=e(F(x))
$$

for every $x\in X$?

The **Fibre-Constancy Criterion** answers exactly:

> Experience factors through functional observation if and only if experience is constant on every functional fibre.

In symbols, such an $e$ exists precisely when

$$
F(x)=F(y)\implies E(x)=E(y)
$$

for all $x,y\in X$.

One direction is immediate. If $E=e\circ F$, functionally identical states have equal experience because they are fed the same input to $e$. Conversely, if experience is constant on each fibre, define $e(b)$ to be the experience of any state whose observed profile is $b$. The choice of representative does not matter: fibre constancy guarantees the same answer.

This criterion sharply separates two regimes. If experience is fibre-constant, functional observation contains enough information to determine it. If experience varies inside even one fibre, no reconstruction from behavior alone can succeed everywhere. The obstruction is not computational difficulty; it is information loss.

## Why function alone does not produce zombies

It is tempting to jump from “functional descriptions may omit experience” to “every aware system has a zombie twin.” That conclusion is invalid without an additional premise.

Here is the decisive counterexample. On any state space, define experience to be constantly present:

$$
E(x)=1\quad\text{for every }x\in X.
$$

No matter how complicated the observation map $F$ is, there cannot be a void twin, because there is no state $z$ with $E(z)=0$. This is the **Functionalism-Alone Countermodel**.

The lesson is logical hygiene. Functional equivalence alone says only that two states share an observed profile. It does not guarantee that experience differs within that profile. Zombie existence requires a fibre-splitting premise, such as the explicit Boolean factor in the split model, or at least the assumption that $E$ varies on some fibre.

## A bridge to incompleteness

A parallel geometry appears in logic. Fix a family of theories indexed by natural numbers $i$, and for each index let $C_i$ be a designated consistency sentence in a standard provability system. Assume the established two-sided independence property

$$
C_i\text{ is not provable},\qquad \neg C_i\text{ is not provable}.
$$

For a behavioral label $b\in B$, form the labelled incompleteness gap $(b,C_i)$ together with this certificate of two-sided unprovability. Since the logical component is fixed once $i$ is fixed, there is exactly one such gap over each $b$. Consequently, the space of indexed incompleteness gaps is also classified by $B$.

Now two spaces have the same classifier. An experiential gap over $b$ is

$$
((b,1),(b,0)),
$$

while an incompleteness gap over $b$ is

$$
(b,C_i),
$$

with neither $C_i$ nor its negation derivable. Matching equal labels produces the **Experiential–Incompleteness Gap Isomorphism**: for every behavioral space $B$ and every index $i$, oriented experiential gaps correspond bijectively to labelled two-sided incompleteness gaps. The correspondence preserves $b$ and sends the experiential contrast to the designated independent sentence.

This is a structural analogy, not an identity. It does not say that consciousness is arithmetic, that qualia are sentences, or that incompleteness explains phenomenology. The common shape is more modest and more precise: in both constructions, a visible label remains fixed while a two-sided contrast lies beyond the chosen observational or derivational channel.

## The geometry of humility

The mathematics draws a disciplined map of the debate.

First, forgetting creates fibres. Second, hidden variation inside a fibre blocks reconstruction. Third, a globally split Boolean model supplies a unique, reversible aware–void contrast over every behavioral profile. Fourth, any metric based only on behavior assigns that contrast zero distance. Fifth, the resulting gap space shares a label-preserving classification with a family of logical independence gaps. Finally—and crucially—none of this lets functional organization alone conjure a zombie. The split must be assumed or independently established.

That final restriction is not a weakness. It is the point. Good mathematics does not turn a philosophical intuition into a theorem by hiding its controversial premise. It isolates the premise, follows its consequences, and shows the exact boundary beyond which the conclusion fails.

The hard problem of consciousness remains hard. But its information geometry becomes clear: what an observation map forgets lives in its fibres; what varies within those fibres cannot be reconstructed from the image; and any claim that the hidden contrast exists must be justified separately from the functional description that omits it.
