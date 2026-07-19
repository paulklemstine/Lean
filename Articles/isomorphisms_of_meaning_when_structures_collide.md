# Isomorphisms of Meaning: When Structures Collide

Two subway maps can look utterly different and still describe the same network. One bends a river into a neat horizontal line; another preserves geography. Stations move across the page, colors change, and names may be translated, yet the pattern of connections survives. If every station and every link in one map has exactly one counterpart in the other, then the maps share a structure.

Mathematics has a precise word for this: **isomorphism**. An isomorphism is a reversible relabeling that preserves all the relationships under discussion. It is one of the discipline’s most powerful ideas because it tells us which differences are merely cosmetic. But it also raises a difficult question. If two systems are structurally identical, must they mean the same thing?

The answer developed here is both strong and carefully limited. For a fixed language of observations, structural isomorphism preserves every truth expressible in that language. Chains of analogies preserve truth as well, and an analogy can be rewritten in new coordinates without changing what it carries. Yet an interpretation attached outside the observational structure need not be preserved. Structure determines structural truth; it does not, by itself, determine every possible meaning.

## A small language for navigating possible worlds

Imagine a collection of worlds. From each world, some other worlds are accessible: they may be possible next states of a program, alternative scenarios in a plan, rooms reachable in a game, or hypotheses compatible with current evidence. At each world, certain atomic observations are true.

A **relational model** consists of three ingredients:

1. a set $W$ of worlds;
2. a transition relation $R\subseteq W\times W$, where $R(w,x)$ means that $x$ is accessible from $w$;
3. a valuation $V(w,a)$ saying whether atomic observation $a$ holds at world $w$.

From atoms we build formulas using falsity $\bot$, implication $\varphi\to\psi$, and necessity $\Box\varphi$. Their meanings are recursive. An atom $a$ is true at $w$ exactly when $V(w,a)$ holds. Falsity is never true. The implication $\varphi\to\psi$ is true when truth of $\varphi$ entails truth of $\psi$. Finally,

$$
w\models\Box\varphi
\quad\text{exactly when}\quad
\text{every }x\text{ with }R(w,x)\text{ satisfies }\varphi.
$$

This compact language already describes safety, inevitability, and constraints across branching possibilities. Other connectives can be defined from the primitives. For example, negation is $\neg\varphi:=\varphi\to\bot$.

## The structural invariance theorem

Suppose we compare two models. A **model isomorphism** consists of a bijection $f$ between their worlds and a bijection $g$ between their atomic vocabularies. These bijections must preserve both kinds of observable structure:

$$
R'(f(w),f(x))\Longleftrightarrow R(w,x)
$$

and

$$
V'(f(w),g(a))\Longleftrightarrow V(w,a).
$$

A formula is transported by replacing every atom $a$ with $g(a)$ while leaving falsity, implication, and the box operator unchanged.

The central result is the **Structural Invariance Theorem**: for every formula $\varphi$ and every world $w$,

$$
f(w)\models' g(\varphi)
\Longleftrightarrow
w\models\varphi.
$$

In words, simultaneously rename the worlds and the observable vocabulary, preserving transitions and atomic facts, and every modal statement keeps its truth value.

Why does this hold? The proof follows the construction of formulas. It is immediate for atoms because the valuation is preserved, and immediate for falsity. For implication, apply the result to its two parts. The interesting case is necessity. Suppose $\Box\varphi$ is true at $w$. Any successor of $f(w)$ in the second model comes from a unique successor of $w$, because $f$ is reversible and preserves transitions. The inner formula is true at that source successor, so its renamed version is true at the target successor. The reverse direction uses the inverse bijection in exactly the same way.

A direct consequence is the **Theory Invariance Corollary**: a formula is true at every world of one model exactly when its transported formula is true at every world of an isomorphic model. Isomorphic models therefore validate the same theory, once vocabulary is translated.

## Analogies that compose

An analogy is rarely isolated. We may compare a melody to a geometric pattern, that pattern to a sequence of moves, and those moves to a story. A useful mathematics of analogy must allow correspondences to compose.

Model isomorphisms do. There is an identity analogy from a model to itself, every analogy has a reverse, and two consecutive analogies compose into a third. These operations obey the familiar laws of a **groupoid**: arrows can be composed whenever endpoints match, composition is associative, identities do nothing, and reversal undoes an arrow.

This gives the **Compositional Truth-Transport Theorem**. If one isomorphism carries a model $M$ to $N$ and a second carries $N$ to $P$, then their composite carries every truth at every world of $M$ to the corresponding truth in $P$. No semantic drift occurs merely because the translation was performed in stages.

There is a subtler freedom too: we can change the representation of the source and target while retaining the analogy between them. Suppose $L$ identifies an old source with a new source, $E$ is the original analogy, and $R$ identifies the old target with a new target. The transported analogy is

$$
L^{-1}\circ E\circ R,
$$

with composition read along the matching systems. This is an “isomorphism of isomorphisms”: not merely a relabeling of objects, but a coherent re-expression of the correspondence itself. The **Conjugated-Analogy Invariance Theorem** states that this re-expressed analogy preserves every transported modal truth.

This matters for analogical reasoning in the spirit of Copycat. A correspondence may be discovered under one description and then reframed under another. “Successor” in a letter sequence might become “one step clockwise” in a diagram. The groupoid laws identify the structural core that remains stable through such reframing. They do not explain all human analogy, but they isolate a rigorous backbone: reversible correspondence, composition, and invariance under changes of coordinates.

## Where meaning escapes structure

Now comes the collision. Enrich a relational model with an **external interpretation**, a label $I(w)$ attached to each world but deliberately omitted from the observational vocabulary. An isomorphism is **meaning-compatible** when it also preserves those labels:

$$
I'(f(w))=I(w)
$$

for every world $w$.

Consider the smallest possible model: one world, one atom, a self-transition, and the atom true. Make two copies with exactly the same structure. In the first copy, attach the external label $\mathrm{false}$; in the second, attach $\mathrm{true}$.

The identity correspondence is a model isomorphism. By structural invariance, every formula in the modal language has the same truth value in both copies. This includes formulas of arbitrary size and arbitrary modal depth. Nevertheless, the external interpretations disagree, and the isomorphism is not meaning-compatible.

This is the **Meaning-Collision Theorem**: there exist structurally isomorphic interpreted models such that every formula in the chosen observational language agrees under the isomorphism, while their external interpretations are unequal.

The theorem does not say that no language could distinguish the labels. Add an atom explicitly naming the interpretation and the collision disappears. The point is sharper: information absent from an observational signature cannot be recovered merely by inspecting all truths expressible in that signature. The boundary is not between mathematics and meaning in general. It is between what a language observes and what has been left outside it.

## Why the boundary matters

In software, two state machines may have identical transition graphs while one state represents “payment authorized” and the other “emergency shutdown.” Structural analysis can certify matching behavior relative to chosen observations, but domain interpretation still depends on how states connect to the world.

In data science, two databases may be identical up to renaming rows and columns. An algorithm sensitive only to relational structure cannot know whether a node represents a patient, a city, or a protein. Privacy techniques sometimes exploit this gap, while re-identification attacks show how quickly it closes when external information is added.

In scientific modeling, equations can recur across fluid flow, electrical circuits, and population dynamics. The shared form licenses powerful analogies, but voltage is not literally pressure and population is not charge. The isomorphism carries inferential structure; the interpretation tells us what the variables concern.

The same distinction appears whenever information passes through an interface. A navigation service might expose roads, junctions, and travel times while hiding whether a route is scenic, politically sensitive, or emotionally important to a traveler. Any process restricted to the exposed fields can make reliable, representation-independent deductions about connectivity. It cannot manufacture the hidden attributes from structural agreement alone. Better inference requires a richer interface, not merely a longer calculation. This is why the theorem concerns every formula: it rules out the hope that enough clever nesting of the existing observations will somehow reconstruct a feature that was never represented.

And in artificial intelligence, analogy engines must balance two tasks. They must recognize invariant patterns beneath superficial changes, yet avoid mistaking structural fit for complete semantic identity. The results here separate those tasks cleanly. Structural correspondence guarantees preservation of truths formulated in the shared language. Choosing, extending, or grounding that language is an additional act.

The lesson is not that structure is weak. On the contrary, structure is strong enough to preserve an unlimited family of formulas, stable under chains of analogies and changes in representation. The lesson is that every claim of sameness has a scope. An isomorphism says: with respect to these objects, these relations, and these observations, nothing distinguishable has changed. Meaning can coincide with that structure—but when meaning lives outside it, mathematics tells us exactly why the collision cannot be seen.