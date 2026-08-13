# Buttons, Switches, and the Shape of the Mathematical Multiverse

## A machine with no undo

Imagine a control panel. On the left, a row of **buttons**. On the right, a row of **switches**. The buttons have a peculiar property: once you press one, it stays pressed forever. There is no undo. The switches, by contrast, can be flipped up and down as often as you like, endlessly, in any order.

This little machine — a handful of irreversible buttons and a handful of reversible switches — turns out to be an astonishingly accurate model of something that sounds far grander: the space of all possible universes of mathematics, and the logic of what is *necessarily* true across them.

That claim needs unpacking.

## One mathematics, or many?

At the foundations of mathematics sits set theory: almost everything mathematicians do can be encoded as sets, and the standard axioms are the rules governing them. For a long time the hope was that these axioms would settle every mathematical question. They do not. The most famous casualty is the **Continuum Hypothesis** (CH), which asks whether there is any size of infinity strictly between the infinity of the whole numbers and the infinity of the real line. In the 1960s it was shown that the standard axioms can neither prove nor refute it. The technique invented for this — **forcing** — does something remarkable: starting from a universe of sets, it manufactures a *larger* universe, containing new objects, in which a chosen statement (CH, or its negation) comes out true.

Forcing is not an isolated trick; it is a machine for building universes. From any universe you can force, and from the result force again, indefinitely. What emerges is not a single fixed mathematical reality but a sprawling network of them: the **set-theoretic multiverse**, whose nodes are universes and whose edges are the forcing constructions linking a universe to its extensions.

Once you have such a network, a new kind of question appears. Not "is this statement true?" but "is this statement true *no matter where you go*?" Write $\Box p$ for "*$p$ holds in every forcing extension*" and $\Diamond p$ for "*$p$ holds in some forcing extension*". These are the modal operators of necessity and possibility, transplanted into set theory. The **modal logic of forcing** asks: which combinations of $\Box$ and $\Diamond$ are universally valid?

And here the control panel reappears.

## Buttons and switches

Some statements, once made true by forcing, can never be made false again. Push, and it stays pushed. Formally, a **button** is an assertion $p$ such that whenever $p$ holds at a universe it holds at every extension: $p \to \Box p$ is guaranteed. Set theory is full of these; certain statements about the failure of definability, once forced, are permanent because forcing can only add objects, never remove them.

Other statements are **switches**: from any universe you can force them true and force them false, over and over. CH is the standard example, and neither move ever locks you in. A switch satisfies $\Diamond p \wedge \Diamond \neg p$ at *every* universe — indeed $\Box(\Diamond p \wedge \Diamond \neg p)$, since it stays a switch forever.

So the abstract picture is a **control frame**. A world is a pair $(S, g)$: a finite set $S$ of buttons already pushed, together with a setting $g$ assigning to each switch the value on or off. One world can reach another, written $(S,g) \sqsubseteq (T,h)$, exactly when $S \subseteq T$ — you may push more buttons and reset the switches however you please, but you can never unpush.

Three structural facts follow immediately, and they are precisely the facts that pin down the logic.

**Reflexivity.** Every world reaches itself: the trivial forcing changes nothing. **Transitivity.** An extension of an extension is an extension. **Directedness.** Any two extensions of a world have a common further extension: $(T_1,h_1)$ and $(T_2,h_2)$ both reach $(T_1 \cup T_2, h_1)$ — push the union of the buttons. In set theory this is the fact that two forcing extensions can always be amalgamated inside a third, by forcing with the product of the two notions of forcing.

A frame that is reflexive, transitive and directed validates exactly the modal principles of the system called **S4.2**: the base logic $K$ (necessity distributes over implication), the axiom $T$ ($\Box p \to p$), the axiom $4$ ($\Box p \to \Box\Box p$), and the directedness axiom, traditionally named $.2$:
$$\Diamond \Box p \;\to\; \Box \Diamond p .$$
Read it aloud in forcing language: if some extension makes $p$ permanently true, then in every extension it remains at least possible to make $p$ true. The reason is exactly amalgamation — go to the world where $p$ is locked in, go to the other extension, and meet in the common extension above them both.

## Why exactly S4.2, and not more?

The sharper question is whether the frame validates *more* than S4.2 — whether the logic secretly collapses into something stronger. It does not, and buttons are the reason.

The strongest classical modal system, **S5**, adds the axiom $5$: $\Diamond p \to \Box \Diamond p$ — whatever is possible is always possible. In S5, possibility never expires. But a button destroys this at once. Let $p$ be "button $b$ has *not* been pushed". At the world where nothing has been pushed, $p$ is true, so certainly $\Diamond p$ holds. Now push $b$. In that extension, and in everything above it, $p$ is false and can never be made true again — the possibility has expired. So $\Box \Diamond p$ fails. One single button kills $5$.

In fact one can say precisely when $5$ survives. The axiom corresponds to the frame condition of being *Euclidean*: any two worlds reachable from a common world are reachable from each other. The control frame is Euclidean **if and only if there are no buttons at all** — a clean dichotomy identifying buttons as the exact obstruction to S5. The same argument, in a milder form, kills the Brouwer axiom $p \to \Box \Diamond p$.

What about going in the other direction — is the logic perhaps *linear*, so that the network of universes is essentially a single chain? Linearity is the axiom $.3$:
$$\Box(\Box p \to q) \;\vee\; \Box(\Box q \to p),$$
valid exactly when accessibility is total, so that any two worlds are comparable. Two **independent** buttons refute it. Take $p$ = "button $b_1$ pushed", $q$ = "button $b_2$ pushed", and evaluate at the world where neither is pushed. Pushing $b_1$ alone makes $\Box p$ true while $q$ remains false, so the left disjunct fails; pushing $b_2$ alone breaks the right disjunct symmetrically. The multiverse genuinely *branches*: it is a directed order, not a line.

So the logic of the control frame lies strictly between S4.2 and each of S5 and S4.3. And because a deduction calculus for S4.2 can be proved sound on *every* directed preorder, these two refutations do double duty: a finite counter-frame refuting $5$, or refuting linearity, shows that the axiom in question is not a theorem of S4.2. The buttons are not merely intuitive; they are *proofs of independence*.

## Where do the buttons come from?

Here is the uncomfortable part of the story so far. Reflexivity, transitivity, directedness, the button law, the switch law — all of these were *assumed*. We drew a picture and declared it a model of forcing. But a picture is not a construction. Can one build an actual mathematical universe in which these laws are theorems rather than stipulations?

Yes. And the machinery is the same machinery that built forcing in the first place: **Boolean-valued models**.

The idea is beautiful. Instead of asking whether a statement is *true* or *false*, assign to each statement $p$ a value $\llbracket p \rrbracket$ in a Boolean algebra $B$ — an algebra of "degrees of truth". Atomic statements get values by fiat; compound ones inherit them algebraically. In the minimal language built from falsity and implication:
$$\llbracket \bot \rrbracket = \bot, \qquad \llbracket p \to q \rrbracket = \llbracket p \rrbracket \Rightarrow \llbracket q \rrbracket,$$
where $a \Rightarrow b$ is the Boolean implication $a^{\complement} \vee b$. Negation, conjunction and disjunction come out as complement, meet and join, as they must.

Two theorems make this into a genuine semantics for forcing.

**Forcing closure.** *Every theorem of classical propositional logic receives value $\top$, in every Boolean-valued universe.* The proof is an induction on formal derivations. It suffices to check that the three Hilbert axioms have value $\top$ — these become Boolean identities such as $a \Rightarrow (b \Rightarrow a) = \top$ and $a^{\complement\complement} \Rightarrow a = \top$, each provable by pure lattice manipulation — and that modus ponens preserves value $\top$, which follows from $a \wedge (a \Rightarrow b) \le b$. Logic is therefore not something imposed on the Boolean universe from outside; it is *validated* by it.

**The truth lemma.** A Boolean-valued universe is not yet a universe in the ordinary two-valued sense. To collapse it, choose a **generic filter** $U \subseteq B$: a collection of Boolean values containing $\top$, omitting $\bot$, closed upward and under meets, and — this is the genericity — *deciding* every element, in the sense that for each $a$ either $a \in U$ or $a^{\complement} \in U$. Think of $U$ as a coherent verdict on all the degrees of truth. Now define the **generic quotient**: the two-valued world in which an atomic statement is true precisely when its Boolean value lies in $U$. Then, for *every* statement $p$:
$$p \text{ is true in the generic quotient} \iff \llbracket p \rrbracket \in U .$$
The proof is a short induction on formulas; the only real content is that a generic filter respects Boolean implication, $a \Rightarrow b \in U$ iff ($a \in U$ implies $b \in U$), which is where properness and decisiveness are both used.

The truth lemma is the hinge of forcing: it converts algebra into truth. A condition $b \in B$ **forces** $p$ when $b \le \llbracket p \rrbracket$; forcing is then monotone, closed under modus ponens, and — by the truth lemma — anything forced by a condition inside the generic filter is genuinely true in the quotient.

## Independence, derived

Now the payoff. Suppose a statement $p$ has a Boolean value that is neither $\bot$ nor $\top$ — *undecided* by the algebra — and suppose the algebra is **rich**: every nonzero element belongs to some generic filter. (For a powerset algebra this is free: the principal filter at any point of a nonempty set does the job, with no appeal to choice.) Then:

> **Branching Theorem.** If $\llbracket p \rrbracket \ne \bot$ and $\llbracket p \rrbracket \ne \top$, there are two generic filters $U$ and $V$ such that $p$ is true in the quotient by $U$ and false in the quotient by $V$.

Both worlds are quotients of *one and the same* Boolean-valued universe. Independence is no longer something you prove by two separate constructions; it is the immediate shadow of a single element of a Boolean algebra failing to be $0$ or $1$. Richness applied to $\llbracket p \rrbracket$ produces a filter containing it, and richness applied to the complement produces a filter containing that; the two quotients disagree.

## The control panel, realized

Everything is now in place to close the loop. Take the switches to be the coordinates of a space $G$ of **generic objects**: a generic object $g$ assigns on/off to each switch. Take the Boolean algebra to be the powerset of $G$ — *sets of generic objects*, with union, intersection and complement. At **stage** $S$, assign Boolean values to atoms as follows:

- a button atom $b$ gets value $G$ if $b \in S$, and $\varnothing$ otherwise;
- a switch atom $s$ gets value $\{\, g : g(s) = \text{on} \,\}$.

Buttons are all-or-nothing: at a given stage a button is decided outright. A switch gets a genuinely intermediate value, neither empty nor everything. The main theorem says the picture and the construction coincide exactly:

> **Realization Theorem.** For every stage $S$, every generic object $g$, and every statement $p$,
> $$p \text{ is true at the control world } (S,g) \iff g \in \llbracket p \rrbracket_S .$$

In words: the world $(S,g)$ of the hand-drawn control frame *is* the generic quotient of the stage-$S$ Boolean-valued universe by the principal generic filter at $g$. The abstract frame is not an analogy for forcing; it is a forcing construction in disguise.

And now the frame laws stop being assumptions.

**Buttons are derived.** Call a statement a *positive button formula* if it is built from button atoms by conjunction and disjunction. Their Boolean values are monotone in the stage — if $S \subseteq T$ then $\llbracket p \rrbracket_S \subseteq \llbracket p \rrbracket_T$, by a two-line induction — and combined with the realization theorem this yields the button law $p \to \Box p$, not stipulated but *proved*.

**Both CH branches are derived.** Designate one switch as CH. Its Boolean value is the set of generic objects turning it on: not empty (the all-on object is in it) and not everything (the all-off one is not). So the Branching Theorem applies verbatim, giving two generic quotients of the very same Boolean-valued universe, one satisfying CH and one refuting it. Nothing about CH was assumed; the branching fell out of the algebra. Inside the frame the same fact reappears as $\Diamond \mathrm{CH} \wedge \Diamond \neg \mathrm{CH}$ at every world.

**Directedness is derived**, from the union of stages, matching on the algebra side the fact that a button's value at a union of stages is the union of its values.

So a single satisfaction relation — the Boolean-valued one — simultaneously validates reflexivity, transitivity, directedness, the button law, the switch law, and both CH branch conditions. That is precisely the falsifiable obligation that a semantic realization was supposed to discharge.

## What is true *everywhere*?

A multiverse invites a new notion of truth: not "true here" but "true in every universe of the network". Which statements are like that?

The answer is exact and, in hindsight, obvious. Moving through the multiverse changes the buttons, but a statement that never mentions buttons cannot notice. Call a statement **button-free** if it is built from switch atoms alone. Then:

> **Invariant Fragment Theorem.** A statement has the same truth value at all worlds sharing a switch setting — equivalently, it is preserved both by passing to forcing extensions *and* by passing back down to grounds — **if and only if** it is equivalent to a button-free statement.

The forward direction has a pretty proof: given an invariant $p$, substitute $\bot$ for every button atom. The result is button-free, and a substitution lemma shows it computes the truth value of $p$ at the button-free stage; invariance transfers this to every stage. The theorem is sharp — a bare button atom is *not* invariant.

The lesson generalizes beyond the toy. Preservation upward alone does not give multiverse truth; it gives necessity *above* a world, a strictly weaker thing. Genuine invariance demands **bidirectional** control: preserved by extensions and by grounds. That motivates a second modality. Alongside $\Box$ ("in all forcing extensions"), introduce $\check{\Diamond}$ ("in some ground", i.e. in some universe of which this one is a forcing extension). Grounds are downward directed — two grounds of a world have a common ground, obtained by intersecting the pushed sets — and, in this frame, there is a least one: the world with no button pushed, the analogue of the **mantle**, the intersection of all grounds. The mixed principle
$$p \to \Box \check{\Diamond} p$$
is valid: whatever is true now remains, in every extension, true in *some* ground — namely the world you started from. Yet its unimodal shadow, the Brouwer axiom $p \to \Box \Diamond p$, *fails* on the very same frame. The two-way logic of the multiverse is strictly richer than the one-way logic of forcing.

## Counting the panel

There is a last, pleasingly concrete fact. With $n$ buttons and $m$ switches the frame has $2^{n+m}$ worlds. How many accessible pairs?

$$3^n \cdot 4^m .$$

The reasoning is a small gem. Each button contributes three states to a pair $(w, v)$ with $w \sqsubseteq v$: unpushed in both, pushed in $v$ only, or pushed in both — the fourth combination, pushed in $w$ but not $v$, is exactly what the no-undo rule forbids. Each switch contributes four, because its value before and its value after are entirely unconstrained. The exponents $3$ and $4$ are the arithmetical signature of the difference between irreversibility and freedom.

The frames also relate to one another. Forgetting the switch settings is a *bounded morphism* onto the pure button order — a map preserving and reflecting accessibility, along which modal truth is invariant — so switches, for all their conceptual importance, are semantically free: they add no validities. Counting pushed buttons is another such map, onto the $(n+1)$-element chain; since bounded images inherit validities, the logic of the control frame sits inside the logic of chains, strictly so, since linearity holds on every chain. The multiverse can be projected onto a line, but it is not one.

## The point

None of this decides the Continuum Hypothesis; it was never going to. What it does is change the register of the question. Instead of asking which set-theoretic statements are true, we get a precise, structural account of how truth *moves* — which assertions lock in once achieved, which oscillate forever, which are invisible to the motion altogether, and exactly which laws of necessity and possibility that motion obeys.

And the account is not merely descriptive. Every law in it has been derived from a construction: a Boolean algebra of degrees of truth, generic filters collapsing it to ordinary worlds, and a truth lemma linking the two. The control panel with its irreversible buttons and its endlessly flippable switches is not a metaphor for the multiverse of set theory.

It is a picture of one.
