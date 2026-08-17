# Tangled Hierarchies: What Happens When a System Trusts Itself

## The loop you can't unloop

There is an old and comfortable picture of how careful reasoning is supposed to work. At the bottom sits the object level: statements about numbers, sets, machines. Above it sits the metalevel: statements about the object level — "that proof is valid", "this theory is consistent". Above that sits the meta-metalevel, and so on upward, each floor commenting on the floor below and never on itself. The picture is comfortable because it is well founded: every chain of "is about" relations terminates. Nothing ever comes back around.

The trouble is that we constantly want to say something the picture forbids. We want a system to certify *itself* — to contain, as one of its own theorems, the statement *whatever I prove is true*. Call this the **reflection schema**, written
$$\Box\varphi \to \varphi,$$
where $\Box\varphi$ reads "$\varphi$ is provable". It is the most natural thing in the world to believe about a system you trust. It is also, as we will see, exactly the thing that snaps the well-founded picture.

This article is about a precise answer to the question: *what does internalised self-trust cost, and can you avoid paying?* The answer, in one line: **self-trust is a loop, exactly one loop, and no amount of clever restructuring will remove it.**

## Worlds, arrows, and the meaning of $\Box$

To make this exact, replace the informal hierarchy by a **frame**: a collection of *worlds* $W$ together with an *accessibility* relation $R$. Read $R\,w\,v$ as "from vantage point $w$, the state of affairs $v$ is a live possibility" — or, in the reading that matters here, "the system at level $w$ quantifies over level $v$ when it says 'provable'." A **valuation** assigns to each atomic proposition the set of worlds where it holds, and truth of compound formulas is defined as usual, with the crucial clause
$$w \models \Box\varphi \quad\text{iff}\quad \varphi \text{ holds at every } v \text{ with } R\,w\,v .$$
So $\Box\varphi$ at $w$ means: $\varphi$ survives everywhere the system at $w$ can see.

The well-founded picture is the class of **provability frames**: transitive, with no infinite ascending chains of arrows (equivalently, converse well-founded). These are the frames of the logic of provability, the ones that validate Löb's axiom
$$\Box(\Box\varphi\to\varphi)\to\Box\varphi$$
— the modal fingerprint of Gödel's incompleteness phenomena. Provability frames are the mathematics of stratification done right: they are irreflexive, so no world sees itself, and every ascent terminates.

Now say a world $w$ is **internally sound** if *every* instance of reflection holds there, for every formula and under every valuation: whatever the system at $w$ certifies as provable really is the case.

## Theorem 1: soundness *is* the loop

**Soundness = Tangle Theorem.** *A world $w$ of a frame is internally sound if and only if $w$ accesses itself: $R\,w\,w$.*

Both directions are two lines, and both are illuminating. If $w$ sees itself, then $\Box\varphi$ at $w$ says "$\varphi$ holds at all worlds $w$ sees", and $w$ is one of them — so $\varphi$ holds at $w$. Self-reference gives you self-trust for free.

The converse is the surprising one, and it is proved by a *diagonal valuation*. Suppose $w$ is internally sound. Pick an atom $p$ and interpret it as the set of worlds $w$ can see: $p$ is true at $v$ precisely when $R\,w\,v$. Then $\Box p$ holds at $w$ trivially — by construction $p$ is true at everything $w$ sees. Internal soundness then forces $p$ itself to be true at $w$, that is, $R\,w\,w$. The system's own trust in itself, applied to a proposition that names the system's field of vision, folds the field of vision back onto its centre.

This is Hofstadter's *strange loop* made into a theorem, and it is unforgiving in both directions.

## Theorem 2: you cannot buy a smaller version

You might hope to keep a weak, harmless fragment of self-trust: trust yourself only about atomic facts, not about complicated compound claims. Nothing doing.

**Atomic Reflection Theorem.** *If a world validates $\Box p\to p$ for propositional variables $p$ alone — under every valuation — then it validates the full reflection schema for every formula whatsoever.*

The diagonal valuation above only ever used an atom, so the weakest fragment already produces the loop, and the loop produces everything. There is no non-trivial safe fragment of soundness. Self-trust is all or nothing.

## Theorem 3: what the loop destroys

Once a frame contains one internally sound world, several structural goods vanish at once, and not by a little.

*Levels vanish.* There is no function assigning each world a natural-number "level" that strictly increases along arrows — indeed no assignment into any well-founded order that strictly decreases along arrows, ordinals included. A self-loop would have to have a level below itself. The tidy floor plan of object level, metalevel, meta-metalevel simply cannot be drawn.

*Löb induction vanishes.* The box operator acts on sets of worlds: $\Box X$ is the set of worlds all of whose successors lie in $X$. Its least fixed point $\mu X.\,\Box X$ is exactly the well-founded part of the frame, and it equals the whole frame precisely when the frame is converse well founded. This is Löb's theorem in set form: "everything follows by induction on the accessibility relation" is *equivalent* to well-foundedness. An internally sound world lies outside that least fixed point, permanently beyond the reach of any Löb-style induction.

*Coexistence vanishes.* A world validating every instance of Löb's axiom must be irreflexive, and so no world can be both internally sound and Löbian. A frame validating both schemas everywhere has no worlds at all. That is the semantic shadow of Gödel's second incompleteness theorem: a well-founded provability discipline and internalised soundness are jointly unsatisfiable, not merely jointly unproven.

The same story at the level of proof systems is even blunter. Consider any system of modal theorems closed under modus ponens and necessitation. **Löb's rule** says that in a system proving Löb's axiom, proving *an instance* of your own soundness already gets you the conclusion: from $\Box\varphi\to\varphi$ as a theorem, necessitation gives $\Box(\Box\varphi\to\varphi)$, Löb's axiom gives $\Box\varphi$, and reflection gives $\varphi$. Apply this with $\varphi=\bot$: a Löbian system that proves its own soundness schema proves falsehood. Contrapositively, a consistent Löbian system can neither prove its own soundness nor prove its own consistency statement $\neg\Box\bot$ — Gödel's second theorem in three lines.

## Theorem 4: the cost is exactly one loop

So far the news is negative. Here is the positive half, and it is the reason "tangled hierarchy" is not a synonym for "collapse".

Given any frame $F$, build its **soundness extension** by adjoining a single new world at the top which sees every old world *and itself*. This new world is the system that reasons about $F$ while remaining inside the picture.

**Conservation Theorem.** *The old worlds form a generated submodel: every formula has exactly the same truth value at every old world before and after the extension. The new top world is internally sound. If the base frame was irreflexive, the extension has exactly one self-loop and exactly one internally sound world.*

So the tangle is real but surgically local. The old hierarchy notices nothing: all of its truths are untouched. Every provability frame — every well-founded stratification — embeds truth-preservingly into a frame with a unique self-trusting world at the top. Hofstadter's intuition that a strange loop need not corrupt the levels beneath it is here a theorem.

What if you try to escape upwards, adding a new certifying level each time? Iterate the extension: stage $n+1$ reasons about, and validates the soundness of, stage $n$. Then **stage $n$ has exactly $n$ self-loops and exactly $n$ internally sound worlds**, and — over any nonempty irreflexive base — **some world at every stage is still not internally sound**. Stratification never converges. Each reflection step buys exactly one loop's worth of self-trust, and never buys the last one.

## Theorem 5: how weak can self-trust be? A spectrum

If you cannot weaken the schema, perhaps you can *delay* it. Instead of "what I prove is true", assert "what I prove, that I prove, that I prove … ($n$ times) … is true":
$$\Box^n\varphi\to\varphi .$$

**Spectrum Theorem.** *A world validates the $n$-fold reflection principle, uniformly in the valuation, if and only if it lies on a closed walk of exactly $n$ steps.* For $n=1$ this is the self-loop of Theorem 1.

This calibrates the phenomenon perfectly, because every point of the spectrum is realised. Take the **cycle frame** on $n$ worlds $0,1,\dots,n-1$, each accessing the next and the last accessing the first. For $n\ge 2$ it has *no self-loops at all* — no world sees itself in one step — and yet every world validates $\Box^n\varphi\to\varphi$, while refuting $\Box^k\varphi\to\varphi$ for every $0<k<n$. Delayed self-trust genuinely exists, comes in strictly increasing degrees, and each degree is strictly stronger than nothing and incomparable with the smaller ones.

But delay is not escape. Every degree of internal soundness still tangles the reference graph: a closed walk of any positive length is a loop in the transitive closure, so there is still no level function, still no well-founded rank. And on a provability frame — transitive and converse well founded — *no* degree is available at any world: transitivity collapses a closed walk to a self-loop, and irreflexivity forbids it. You can spread the loop out over $n$ levels; you cannot make it disappear.

There is also a pleasant arithmetic to this. The set of degrees a world enjoys always contains $0$ and is closed under addition — walks concatenate — so "how self-sound a world is" is measured by a submonoid of the natural numbers.

## Theorem 6: where the boundary really lies

Is *all* self-reference this expensive? No, and the boundary is sharp.

Internal **consistency** — the statement $\neg\Box\bot$, "I do not prove falsehood" — holds at a world exactly when that world has at least one successor. That is *seriality*, and seriality is cheap. The two-world chain $t \to f$ is loop-free, converse well founded, an entirely respectable well-founded hierarchy, and the world $t$ asserts its own consistency under every valuation. The same world is not internally sound, not even atomically.

**Consistency costs nothing; reflection costs a loop.** That is the precise frame-theoretic location of the Gödel phenomenon: the jump from harmless to tangled happens exactly at reflection.

There is a beautiful finite caveat. If a *proof system* actually proves its own consistency, then every frame validating that system is serial — and a finite nonempty serial frame must contain a cycle. So **every finite semantics for a self-consistent system is tangled**, with no level grading of any kind. Finiteness is essential: the infinite chain $0\to1\to2\to\cdots$ is serial and completely loop-free, even in its transitive closure. Infinity is the one legitimate way to be self-consistent without tangling, and it is exactly the escape route Gödel's theorem leaves open.

## A tale of two systems

The whole story can be compressed into two concrete proof systems and one impossibility.

The first is the system of formulas valid on all well-founded provability frames. It is consistent, it proves every instance of Löb's axiom — and it does not prove its own soundness schema, nor its own consistency statement. It is Gödel's world: disciplined, stratified, and permanently unable to vouch for itself.

The second is the system of formulas true at the single self-accessing world. It is consistent, it proves every instance of $\Box\varphi\to\varphi$, and it proves $\neg\Box\bot$. It vouches for itself completely. Its price: it refutes Löb's axiom. It has abandoned the well-founded reading of its own provability operator.

And the impossibility: **no** modal proof system whatsoever, closed under modus ponens and necessitation, can be consistent while proving both its own soundness schema and Löb's axiom.

There are exactly two coherent ways to be a system that talks about itself. You can be well founded, and silent about your own truth. Or you can be self-certifying, and tangled. The middle option — stratified *and* self-trusting — is not merely hard to build. It does not exist.

## Why it matters beyond logic

The mathematics here is about modal frames, but the shape of the result is not confined to them. Anywhere a structure is asked to certify its own outputs — a compiler that verifies compilers, a legal system whose constitution authorises its own amendment, a learning system that scores its own reliability, a mind modelling itself modelling the world — the same trade-off appears in the same place. Full internal certification requires the certifying vantage point to lie inside its own field of view. That loop is not a design flaw to be engineered away; it is what internal certification *is*.

What the theorems add to the intuition is a costing. The loop can be added to any well-founded structure without disturbing a single one of its existing truths. It comes in degrees, spread over cycles of any length. It can never be reached by finitely many stratification steps. And it is the price of *soundness*, not of *consistency* — mere self-declared coherence remains free, so long as you are willing to be infinite.
