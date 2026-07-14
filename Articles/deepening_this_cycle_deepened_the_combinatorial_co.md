# The Many Worlds of Mathematics: What Forcing Can and Cannot Do

## A universe that refuses to sit still

For most of us, mathematics feels like the most solid thing in the world. Two plus two is four, a triangle has three sides, and there is exactly one way things *are*. Yet deep inside the foundations of set theory — the theory of infinite collections on which the rest of mathematics rests — there lives a strange and beautiful instability. Some perfectly natural questions about infinity simply *cannot be settled* by the usual rules. The most famous is the **Continuum Hypothesis** ($\mathrm{CH}$): is there any size of infinity strictly between the infinity of the whole numbers and the infinity of the real numbers?

Kurt Gödel and Paul Cohen proved something astonishing: the standard axioms of set theory can neither prove nor disprove $\mathrm{CH}$. It is *independent*. There are consistent mathematical universes where $\mathrm{CH}$ is true, and equally consistent universes where it is false. No experiment, no cleverer proof, will ever break the tie from within.

The tool Cohen invented to show this is called **forcing**. Think of forcing as a machine for building a new mathematical universe out of an old one, by carefully adding a "generic" object that adjusts what is true. Start in a universe where $\mathrm{CH}$ holds, run the machine, and you land in a new, larger universe where $\mathrm{CH}$ fails. Forcing is how set theorists travel between worlds.

Once you accept that there is not one universe of sets but *many* — a whole **multiverse** of them, linked by forcing — a wonderful question appears. If forcing lets us move from world to world, then the relationship "*this world can be forced from that one*" is a kind of map of possible destinations. And whenever you have a map of possible destinations, you have the raw material for a **logic of possibility and necessity**.

## Two little words: *possible* and *necessary*

Modal logic is the branch of logic that studies the words "necessarily" and "possibly." Its two symbols are a box and a diamond:

- $\Box p$ means "$p$ is **necessary**";
- $\Diamond p$ means "$p$ is **possible**."

The genius of modern modal logic, due to Saul Kripke, is to explain these words using *worlds*. Imagine a collection of possible worlds and an "accessibility" relation telling you which worlds you can reach from which. Then:

- $\Box p$ is true at a world when $p$ is true in **every** world you can reach;
- $\Diamond p$ is true at a world when $p$ is true in **some** world you can reach.

The two are perfect mirror images of each other, captured by the duality
$$\Diamond p \;\longleftrightarrow\; \lnot\,\Box\,\lnot p,$$
which just says: "$p$ is possible" means "it is not the case that $p$ is necessarily false."

Now comes the idea at the heart of this work. Take the worlds to be **mathematical universes**, and take "accessible" to mean "reachable by forcing." Suddenly the box and diamond acquire a precise, powerful meaning:

- $\Box p$ — "$p$ holds in **every** forcing extension" — reads as **$p$ is *necessary*** in the forcing sense: no matter how you force, $p$ stays true.
- $\Diamond p$ — "$p$ holds in **some** forcing extension" — reads as **$p$ is *forceable*, or *possible***: there is a way to force $p$ true.

This is the **modal logic of forcing**, and the question it asks is deceptively simple: *which laws of "necessary" and "possible" does forcing actually obey?*

## The rules forcing plays by

Not every conceivable modal law is valid; which ones hold depends entirely on the *shape* of the accessibility map. The forcing map turns out to have three decisive features, and each one hands us a specific law.

**You can always force over yourself (reflexivity).** Doing nothing is a (trivial) kind of forcing, so every universe is a forcing extension of itself. Geometrically, every world has an arrow to itself. This makes the law
$$\Box p \to p$$
valid: if $p$ holds in *every* extension, then in particular it holds *here* — because here is one of the extensions. Necessity implies truth. (Its mirror image, $p \to \Diamond p$, says every actual truth is at least possible.)

**Forcing on top of forcing is still forcing (transitivity).** If you can reach world $v$ from $w$, and world $u$ from $v$, then iterated forcing lets you reach $u$ directly from $w$. This gives the law
$$\Box p \to \Box\Box p:$$
if $p$ is unavoidable now, it stays unavoidable in every future universe.

**Any two extensions can be merged (directedness).** This is the deepest and most characteristic feature of forcing. If from your universe you can force your way to two different universes $v_1$ and $v_2$, then there is always a *further* universe $u$ reachable from both — you can amalgamate the two forcings into one (using the product of the two forcing notions). No two roads through the multiverse diverge forever; they can always be made to meet again. Directedness validates the elegant law
$$\Diamond\Box p \to \Box\Diamond p,$$
known as the **.2 axiom**. In words: if it is *possible to make $p$ permanently true*, then it is *unavoidable that $p$ remains possible*.

To these three we add two laws that hold in *any* Kripke frame whatsoever, purely from the meaning of "true in all accessible worlds":

- the **distribution law** $\Box(p \to q) \to (\Box p \to \Box q)$ — necessity respects logical implication;
- the **necessitation rule** — anything that is universally valid is also necessarily valid.

Bundle these together — distribution, necessitation, $\Box p \to p$, $\Box p \to \Box\Box p$, and $\Diamond\Box p \to \Box\Diamond p$ — and you have exactly the modal system logicians call **S4.2**. The central result of this work is a clean, from-first-principles proof that

> **Every forcing frame is sound for S4.2:** each of the five laws above holds in every universe of any multiverse whose accessibility relation is reflexive, transitive, and directed.

## The law that fails — and why it matters

Here is where the story turns subtle and surprising. There is a stronger, more famous modal system called **S5**, the logic of "genuine possibility" where accessibility is fully symmetric — if you can get *there*, you can always get *back*. S5 is the logic of, say, logical possibility itself. Its signature law is
$$B:\quad p \to \Box\Diamond p,$$
which says: *whatever is actually true is necessarily still possible* — you can never wander so far that the truth becomes unrecoverable.

Does forcing obey $B$? It would if forcing were reversible — if from every generic extension you could always force your way *back* to where you started. But forcing is a one-way street. **You cannot, in general, un-force.** Once you have added a generic object, no further forcing can delete it and return you home.

This work makes that intuition into a theorem. Consider a tiny multiverse with just two worlds: a world $w_T$ where a certain statement is *true*, and a "sink" world $w_F$ where it is *false* — a world from which every forcing leads only back to itself. This little frame is perfectly reflexive, transitive, and directed (so it is a legitimate forcing frame and satisfies all of S4.2), yet the axiom $B$ **fails** at $w_T$: the statement is true there, but by forcing to the sink $w_F$ you reach a universe from which its truth can never be recovered. Therefore:

> **Forcing is genuinely S4.2, and not S5.** The modal logic of forcing is *properly* weaker than the logic of pure possibility, precisely because forcing cannot be reversed.

There is real poetry here. The failure of one abstract-looking axiom is the exact logical fingerprint of a concrete mathematical fact: *forcing has no undo button.*

## Independence, seen through the modal lens

The modal picture pays an immediate dividend: it gives the old notion of *independence* a crisp new name. Recall that a statement is **independent** when it is true in some universe of the multiverse and false in another. In modal language this is exactly **contingency**:
$$\Diamond p \;\wedge\; \Diamond \lnot p$$
— "$p$ is possible *and* its negation is possible." Neither $p$ nor its denial is forced upon us.

This work makes the correspondence exact. In the **full-accessibility** forcing frame — the multiverse in which every universe is reachable from every other — a statement is contingent at some world if and only if it is independent across the multiverse. The two ideas, one from set theory and one from modal logic, are revealed to be the very same thing. Moreover, in this frame contingency is a *global* property: if a statement is contingent anywhere, it is contingent everywhere. Independence is a feature of the multiverse as a whole, not an accident of where you happen to be standing.

The flagship example is, of course, the Continuum Hypothesis. Starting from a universe like Gödel's constructible universe (where $\mathrm{CH}$ holds), one can force to a Cohen extension where $\mathrm{CH}$ fails. So both $\Diamond\,\mathrm{CH}$ and $\Diamond\,\lnot\mathrm{CH}$ hold: $\mathrm{CH}$ is contingent. And therefore $\mathrm{CH}$ is **not necessary** — $\lnot\,\Box\,\mathrm{CH}$ — a one-line modal restatement of Cohen's landmark theorem that no amount of forcing can pin the Continuum Hypothesis down.

## Why this is beautiful

There is something almost vertiginous about taking the machinery mathematicians use to *study* different universes and turning it into a *logic that those universes obey*. The multiverse stops being a loose metaphor and becomes a structured object with its own laws — laws we can name, prove, and even watch fail at exactly the right moment.

The takeaways are worth pausing on:

- **Possibility and necessity are mathematical, not just philosophical.** By reading $\Box$ as "in all forcing extensions" and $\Diamond$ as "in some forcing extension," the ancient words of modal logic become precise tools for talking about what mathematics *could* have been.
- **The logic of forcing is exactly strong enough — and no stronger.** It validates S4.2 because forcing is reflexive, transitive, and directed; it stops short of S5 because forcing is irreversible. The boundary between the two is a genuine feature of the mathematical landscape.
- **Independence is contingency.** The most famous unsolvable problems of set theory are not defects to be repaired but *contingent truths* — statements the multiverse leaves genuinely open, glowing with the double possibility $\Diamond p \wedge \Diamond \lnot p$.

The Continuum Hypothesis, it turns out, is not a broken question. It is a *possible* one — possibly true, possibly false — and the modal logic of forcing is the language that finally lets us say so, precisely and provably. In a discipline built on certainty, that may be the most surprising truth of all: some of the deepest facts about mathematics are facts about what mathematics is free to become.
