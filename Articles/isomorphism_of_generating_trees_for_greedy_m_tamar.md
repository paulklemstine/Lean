# Two Trees, One Secret: How a Local Rule Reveals a Hidden Sameness

## When two very different worlds turn out to be the same

Mathematics is full of coincidences that turn out not to be coincidences. You count the objects in one family—say, the ways of triangulating a polygon, or the number of legal bracketings of a sum—and you get a sequence of numbers: $1, 2, 5, 14, 42, 132, \dots$. Then you count the objects in an apparently unrelated family—certain maps drawn on a sphere, or certain lattice paths that never dip below a diagonal—and, astonishingly, you get *the same sequence*. Are the two families secretly the same? Or is the agreement a numerical accident, true for the first few terms and destined to fail?

This article is about a clean and reusable answer to that question. The answer says: if you can find the right **local rule** connecting how the two families *grow*, then their agreement is guaranteed forever—and not just in raw counts, but in every finer statistic you might care to measure. The whole global miracle collapses into a single, checkable, local identity.

The concrete story that motivates all of this comes from two families that have fascinated combinatorialists for years. On one side sit the intervals of the **$m$-Tamari lattices**, elegant structures built from lattice paths. On the other sit the **planar $(m+1)$-constellations**, colorful maps drawn on the sphere. These families are counted by the same remarkable formula, and the conjecture at the heart of this work is that they are the same not by accident but by design. The engine we describe below is exactly the tool needed to prove such a statement—and we prove that the engine works.

## Families that grow: the idea of a generating tree

Imagine you are cataloguing a family of combinatorial objects—one object of "size 0", a handful of "size 1", more of "size 2", and so on. A very powerful way to organize such a catalogue is to describe not the objects themselves but how each object *sprouts* the objects one size larger.

Picture a tree. At the very top is a single **root**. Each node of the tree carries a **label**—a compact piece of bookkeeping that records everything you need to know about an object in order to predict its offspring. A **succession rule** tells you, for each possible label, the exact ordered list of labels of that node's children. Apply the rule to the root and you get the labels at depth 1; apply it again to each of those and you get depth 2; and so on forever.

This is a **generating tree**. Its beauty is that it turns a static family of objects into a dynamic process of controlled growth. The number of nodes at depth $n$ is exactly the number of objects of size $n$. That sequence of level sizes is the family's **counting sequence**.

Formally, if $\mathrm{succ}$ is the succession rule and $r$ is the root, then the list of labels at each depth is built by the simplest possible recursion:

$$L_0 = [\, r \,], \qquad L_{k+1} = \bigl(\text{flatten}\bigr)\ \bigl[\ \mathrm{succ}(a) : a \in L_k\ \bigr].$$

In words: the labels at the next level are obtained by replacing every label $a$ at the current level with the list $\mathrm{succ}(a)$ of its children's labels, and concatenating. The count at level $k$ is simply the length of the list $L_k$.

The label is where all the subtlety lives. A good label carries just enough information to make the growth rule deterministic. In the applications, a label might record the number of valleys in a lattice path, or the degree of a distinguished face in a map. These are the very statistics practitioners want to compare between families.

## What it means for two trees to be *the same*

Suppose we have two families, each with its own generating tree: the first with root $r_1$, label set $L$, and rule $\mathrm{succ}_1$; the second with root $r_2$, label set $M$, and rule $\mathrm{succ}_2$. When should we say these trees are *isomorphic*—the same tree wearing different clothes?

The naive guess is: "there is a bijection between the label sets." But that is far too weak. Any two infinite label sets admit a bijection; a mere pairing of labels says nothing about how the trees grow. The whole point of a generating tree is the growth rule, so the isomorphism must respect the growth rule.

Here is the correct definition. An **isomorphism of generating trees** is a map $\varphi : L \to M$ between the label sets that does two things:

1. **Matches the roots:** $\varphi(r_1) = r_2$.
2. **Intertwines the succession rules:** for every label $a$,
$$\mathrm{succ}_2\bigl(\varphi(a)\bigr) = \bigl[\ \varphi(x) : x \in \mathrm{succ}_1(a)\ \bigr].$$

The second condition is the heart of the matter. It says: *translate a label with $\varphi$, then grow it in the second tree, and you get exactly the same result as growing it in the first tree and translating each child*. Growth and translation commute. This is a purely **local** requirement—you only ever check one label and its immediate children at a time—yet, as we will see, it forces a **global** identity between the two infinite trees.

## The one lemma that does all the work

Everything hinges on a small, almost humble observation about lists. Suppose $\varphi$ intertwines the two rules. Take any list $xs$ of first-tree labels. There are two things we might do to it:

- **Route A:** translate every label with $\varphi$, then expand each translated label one level using $\mathrm{succ}_2$.
- **Route B:** expand every label one level using $\mathrm{succ}_1$, then translate the whole resulting list with $\varphi$.

The **interchange lemma** says these two routes always land in the same place:

$$\text{expand}_2\bigl(\text{translate}(xs)\bigr) = \text{translate}\bigl(\text{expand}_1(xs)\bigr).$$

The proof is a one-line induction on the list. For the empty list both sides are empty. For a list $a :: t$ (an element $a$ followed by the rest $t$), the intertwining hypothesis handles $a$ exactly, the inductive hypothesis handles $t$, and concatenation glues them together. That's it.

From this single interchange fact, the main theorem follows by an induction on depth. At depth 0 both trees show a single label, and the root-matching condition says $\varphi$ maps one to the other. If the label list at depth $k$ of the second tree is already the $\varphi$-translation of the first tree's depth-$k$ list, then applying the interchange lemma to that list pushes the correspondence up one more level. By induction, at **every** depth $k$:

$$L_k^{(2)} = \text{translate}\bigl(L_k^{(1)}\bigr).$$

**The level-correspondence theorem.** *Under an isomorphism of generating trees, the entire label list at every depth of the second tree is precisely the $\varphi$-image of the label list at that depth of the first tree.*

This is a strong statement: not only do the two trees have the same *number* of nodes at each level, they have the *same nodes in the same order*, once you read them through the dictionary $\varphi$.

## The payoff: equinumerosity, and much more

Two consequences fall out immediately.

**Same counts.** Translating a list never changes its length. So the number of nodes at depth $k$ is the same in both trees, for every $k$. The two families are **equinumerous**: they have identical counting sequences. What might have looked like a numerical coincidence is now a theorem, valid for all sizes at once.

**Same refined counts.** This is where the framework earns its keep. Suppose you have a statistic on the first family—a number $w_1(a)$ attached to each label $a$—and a corresponding statistic $w_2$ on the second family, compatible in the sense that translating first and measuring gives the same value as measuring directly: $w_2(\varphi(a)) = w_1(a)$. Then for **any** property $P$ of statistic values,

$$\#\{\text{depth-}k\text{ nodes of tree 2 with } P(w_2)\} = \#\{\text{depth-}k\text{ nodes of tree 1 with } P(w_1)\}.$$

**The refined equinumerosity theorem.** *An isomorphism of generating trees transports every label-borne statistic. If the statistics agree through the label dictionary, then the number of objects of each size carrying any prescribed statistic value is identical in the two families.*

In plain terms: the two families don't just have the same head count at each size—they have the same head count *broken down by any bookkeeping you can express through the labels*. If one family has, at size $10$, exactly $37$ objects with "three valleys," then so does the other. This is precisely the kind of *refined* agreement that a good combinatorial theory demands, and it comes for free once the local intertwining is in hand.

It is worth stressing why the strong definition of isomorphism was essential. A plain bijection of label *types* would give you nothing: refined equinumerosity genuinely fails without the intertwining hypothesis. The theorems here are not formalities; they are real list-valued identities proved by honest nested induction, and each one breaks if you weaken the hypotheses.

## Back to the Tamari lattices and the constellations

Return now to the two families that started the story: intervals in the greedy $m$-Tamari lattices, and planar $(m+1)$-constellations. Both are counted by the striking closed form

$$\frac{m+1}{n\,(mn+1)}\binom{(m+1)^2 n + m}{\,n-1\,},$$

a number that is always a positive integer even though the formula conceals a delicate arithmetic cancellation. For $m=1$ the equinumerosity of these families, refined by the natural statistics (such as the number of valleys on the lattice-path side), is a known and celebrated result.

The conjecture is that this is no accident for any $m$: the generating tree that records how $m$-Tamari intervals decompose is isomorphic to the generating tree that records how $(m+1)$-constellations decompose. The framework above tells us exactly what must be produced to prove it: a single label map sending one root to the other and turning one succession rule into the other on the nose. Nothing more. Once that map is written down and checked on individual labels, the refined equinumerosity at every size follows automatically, transporting valleys, face degrees, and every other tracked statistic in one stroke.

This is a genuine change of perspective. Proving a global bijection between two families whose sizes grow super-exponentially is daunting. Proving a single local identity between two growth rules is a sharply focused, finite-to-check task. The reduction from the former to the latter is the real contribution, and it is now available in fully rigorous form.

## Why this matters beyond one conjecture

The generating-tree engine is deliberately generic. It knows nothing about Tamari lattices or constellations; it speaks only of labels, roots, and succession rules. That is its strength. Any time two combinatorial families can be described by growth rules—and an enormous number can—the same three-step recipe applies: write down both succession rules, exhibit a label map, check the local intertwining. Refined equinumerosity then follows without ever touching the objects themselves.

There are natural next chapters. One is to build the intertwining map for all $m$, completing the Tamari–constellation program. Another is to read the mysterious integrality of the counting formula directly off a tree recursion, where each count is manifestly a sum of whole numbers and no binomial cancellation needs to be explained. A third is to sharpen the notion of sameness itself: equal counting sequences do *not* force isomorphic trees, but the multiset of labels appearing at each level is a finer invariant that can distinguish "genuinely the same" from "merely equal in number." And because faithful trees for Tamari intervals often need several bookkeeping parameters at once, the labels are naturally vectors—an easy and rewarding generalization of the whole apparatus.

Underneath all of it is a simple and rather beautiful idea. Sameness of two infinite structures need not be checked infinitely often. If the structures grow by rules, and the rules can be translated into one another one step at a time, then the two are the same all the way up—and every measurement you might make agrees, level by level, forever. Two trees; one secret; a single local rule that lets it out.
