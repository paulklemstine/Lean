# When Analogy Becomes Arithmetic

## The most human thing a mind can do

Douglas Hofstadter once argued that analogy is not a party trick of the intellect but its beating heart. When a child realizes that sharing candy is "like" sharing time, when a physicist sees an electric circuit as "like" water in pipes, when a mathematician notices that prime numbers behave "like" points on a line — something extraordinary happens. Two separate worlds are quietly stitched together, and knowledge flows across the seam.

But here is a question that sounds almost impertinent: *Can analogy itself be measured?* Can we say that one analogy is better than another the way we say one bridge is stronger than another? And if analogy has a quality we can measure, does making the *best* analogy become a problem we can *solve*, like finding the shortest route between two cities?

This article tells the story of a small mathematical theory that answers "yes" to all three questions. It turns analogy into an operation with rules, gives it a number that grades its quality, and reveals — surprisingly — that finding the best analogy is a single stroke of a strange but beautiful arithmetic where *adding two numbers means keeping the smaller one*.

## What is an analogy, precisely?

Start with the intuition. An analogy connects two structures — call them $A$ and $B$. To "see $A$ as $B$" you need a way to translate every element of $A$ into an element of $B$. Call that forward translation $F$. But an analogy is only useful if you can come back: you need a way $G$ to translate elements of $B$ back into $A$. The pair $(F, G)$ *is* the analogy.

$$F : A \to B, \qquad G : B \to A.$$

Now, when is the analogy *good*? Hofstadter's insight, stripped to its mathematical bone, is this: a good analogy is one you can travel out on and come home from without getting lost. Take any element $a$ of $A$, send it across to $B$ via $F$, and bring it back via $G$. If the analogy is faithful, you should land back very close to where you started. The round trip $G \circ F$ should behave almost like doing nothing at all — almost like the identity.

This lets us define the **distortion** of an analogy. If the elements of $A$ live in a space where distances make sense, the distortion is the largest gap between a starting point $a$ and its round-trip image $G(F(a))$:

$$\text{distortion}(F,G) = \sup_{a \in A} \ \text{dist}\big(a, \ G(F(a))\big).$$

A distortion of zero means every point comes home exactly. The bigger the distortion, the more the analogy warps and blurs. We say an analogy has **fidelity $\varepsilon$** if its distortion is at most $\varepsilon$ — every point returns within distance $\varepsilon$ of where it began.

## The perfect analogy: seeing a thing as itself

The simplest analogy of all is the one Hofstadter's own model, *Copycat*, takes as its starting point: seeing a structure as *itself*. Here $A = B$, and both $F$ and $G$ are the identity map — translate nothing, change nothing. Its round trip is literally the identity, so its distortion is exactly zero.

**Theorem (The copycat is perfect).** *The identity analogy, where $F$ and $G$ both leave every element untouched, has fidelity $0$.*

This is not a joke result. It is the anchor of the whole theory: it establishes that distortion $0$ is achievable, and that "seeing a thing as itself" is the gold standard against which every other analogy is measured. Distortion, moreover, is never negative — you cannot do *better* than a perfect round trip — so $0$ genuinely is the optimum.

**Theorem (Zero distortion means perfect return).** *In a space where distinct points are genuinely far apart, an analogy has fidelity $0$ if and only if the round trip $G(F(a)) = a$ holds for every element $a$.* 

In other words, "zero distortion" and "$G$ perfectly undoes $F$" are the same statement. Fidelity is not a vague adjective; it is an exact characterization.

## A dangerous temptation, and why it is wrong

Here is a tempting leap. If $G$ perfectly undoes $F$ — if you always come home exactly — surely $F$ and $G$ are genuine mirror images, and $F$ must perfectly undo $G$ as well? Surely a perfect analogy is a perfect *equivalence*, a two-way dictionary with no words lost on either side?

It feels obvious. It is false.

**Theorem (A perfect one-way analogy need not be an equivalence).** *There exists an analogy whose round trip $G \circ F$ is the identity — zero distortion, every point returns exactly — yet whose reverse round trip $F \circ G$ is not the identity.*

The counterexample is disarmingly simple. Let $A$ be a single point, and let $B$ be the entire real line. Send the lone point of $A$ to the number $0$, and send *every* real number back to that lone point. Going out and back within $A$ is flawless: there is only one place to be, and you are always there. But going out and back within $B$ collapses the whole real line onto $0$ — the number $1$, sent across and back, becomes $0 \neq 1$.

This is the mathematical shadow of something every teacher knows: an analogy can be perfectly reliable *in one direction* while losing enormous information in the other. "An atom is like a tiny solar system" helps you picture electrons orbiting — a faithful trip in one direction — but run it backwards and you would wrongly conclude planets obey quantum mechanics. Faithfulness is directional. The theory makes that folk wisdom precise, and warns us not to over-trust our own metaphors.

## Analogies chain together — and the errors add up gently

Creativity, Hofstadter suspected, is rarely a single bolt of lightning. It is more often a *chain* of analogies: $A$ is like $B$, which is like $C$, and by the time you reach $C$ you have discovered something about $A$ you could never have seen directly. But if each link in the chain distorts a little, does the whole chain fall apart?

The answer is reassuring, and it takes the form of a *triangle inequality for analogies*.

**Theorem (Good analogies compose).** *Suppose the analogy from $A$ to $B$ has fidelity $\varepsilon_f$, the analogy from $B$ to $C$ has fidelity $\varepsilon_g$, and the backward map of the first analogy is $L$-Lipschitz (it stretches distances by a factor of at most $L$). Then the composite analogy from $A$ to $C$ has fidelity*

$$\varepsilon_f + L \cdot \varepsilon_g.$$

The total distortion of a chain is controlled by the distortions of its links. It does not explode; it accumulates predictably, damped or amplified only by how much each translation stretches distances. This is the formal skeleton of the conjecture that *every creative mathematical insight can be decomposed into a sequence of analogy operations* — because a sequence of good analogies is provably still a good analogy, with an error budget you can track from end to end.

## The concept lattice, and the analogy that is its own inverse

There is a deeper, more rigid kind of analogy that appears when the structures being compared are not just sets of points but *ordered* webs of concepts — lattices, where "this concept is more general than that one." In the study of concepts, the natural structure-preserving analogy between two such webs is a **Galois connection**: a forward map $l$ and a backward map $u$ locked together by the elegant law

$$l(a) \le b \quad \Longleftrightarrow \quad a \le u(b).$$

Read aloud: "the translation of $a$ sits below $b$" says exactly the same thing as "$a$ sits below the translation of $b$." This single equivalence forces a cascade of beautiful behavior. We call such a pair an **adjoint analogy**.

**Every concept is refined, never degraded.** Going out and coming back, a concept can only become *more* refined: $a \le u(l(a))$. The round trip never loses you — at worst it sharpens you.

**The round trip is stable.** Do the round trip once, and doing it again changes nothing: $u(l(u(l(a)))) = u(l(a))$. In the language of order theory, $u \circ l$ is a *closure operator* — it settles into a fixed, stable concept and stays there. The mirror-image composite $l \circ u$ is likewise stable. The "best" analogies, in this world, are exactly these stable ones: apply them and you reach a resting point that further analogizing cannot disturb.

And then the crown jewel:

**Theorem (The best inverse is unique).** *If a forward analogy $l$ admits an adjoint backward map at all, that backward map is completely determined — there is exactly one.* 

This is a striking statement about creativity and constraint. It says that once you fix how you translate concepts *forward*, the *best possible* way to translate them back is not a matter of taste or luck. It is forced. The optimal inverse of a good structural analogy is unique.

Applied to Hofstadter's *Copycat* itself — where $A = B$ is a single concept lattice seen as itself — this says the copycat is *rigid*: the identity analogy's one and only adjoint partner is the identity again. Seeing a thing as itself admits no alternative "best" translation back. The copycat is a perfect, self-dual analogy with zero distortion, and it is unique in being so.

## The punchline: finding the best analogy is a single addition

We now arrive at the most surprising turn. Suppose you have a whole *pool* of candidate analogies — finitely many ways of seeing $A$ as $B$ — and each candidate $i$ carries a cost $c_i$, namely its distortion. The best analogy is the candidate of least cost. This is an optimization problem: minimize over the pool.

Minimization feels like a *process* — scan the list, keep the running smallest. But there is a corner of mathematics, the **tropical semiring**, in which minimization is not a process but an *operation*, as basic as addition is in ordinary arithmetic. In the tropical world, the "sum" of two numbers is defined to be their *minimum*:

$$x \oplus y := \min(x, y).$$

It sounds like a redefinition for its own sake, but it obeys all the laws you expect of addition — it is associative, commutative, and has an identity element ($+\infty$, since $\min(x, +\infty) = x$). And in this world, the following is simply *true by computation*:

**Theorem (The best analogy is a tropical sum).** *Over a nonempty finite pool of candidate analogies with costs $c_1, \dots, c_n$, the tropical sum*

$$c_1 \oplus c_2 \oplus \cdots \oplus c_n$$

*equals the cost of the best analogy: it is achieved by some candidate in the pool, and it lower-bounds every candidate.*

The optimization problem — "make the best analogy" — collapses into a single tropical addition. There is no search, no loop, no algorithm beyond adding up the scores in the right arithmetic. Aggregating candidate costs by tropical addition *is* choosing the best analogy. (We even allow a candidate to be marked "infeasible" by giving it cost $+\infty$, the tropical zero, so it never wins — exactly as it should.)

This is the quiet miracle at the center of the theory. Hofstadter asked whether making a good analogy could be posed as an optimization problem. Not only can it be posed as one — in the tropical semiring, the answer to that optimization is a *formula*.

## Why this matters

None of this claims to reduce human creativity to a slogan. Analogy in the wild is fluid, context-soaked, and gloriously hard to pin down. What this theory offers is a *scaffold*: precise definitions where before there were only metaphors, and theorems where before there were only hunches.

It tells us that analogies have a measurable quality, that perfect analogies are directional and not to be over-trusted, that chains of good analogies stay good with a traceable error budget, that the best structural inverse of an analogy is forced and unique, and — most vividly — that choosing the best analogy from a field of candidates is a single operation in an arithmetic where addition means "take the smaller."

That last fact hints at something worth chasing. If the act of *selecting* the best analogy is tropical addition, then perhaps the larger process of creative reasoning — chaining, selecting, refining — has a hidden algebraic shape, one we are only beginning to sketch. Hofstadter gave us the vision that analogy is the core of thought. Here we have turned a corner of that vision into arithmetic. The rest of the map is waiting.
