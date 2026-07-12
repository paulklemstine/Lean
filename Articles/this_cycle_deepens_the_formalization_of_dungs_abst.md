# When Winning Every Argument Is Impossible

## The geometry of disagreement

Imagine a debate. Not a polite exchange of views, but a genuine clash: a room full of claims, each one attacking some of the others. "The defendant was at home." "No — a witness places him at the scene." "That witness is unreliable." Every serious argument has enemies, and the question every jury, every committee, every reasoning machine must answer is the same: *which of these claims can we accept together, as a coherent position?*

This is the problem that abstract argumentation was invented to solve. Strip away the content of the claims — forget *what* each argument says — and keep only the essential structure: a collection of arguments, and a relation that records which argument attacks which. What remains is a directed graph, a network of pointed disagreements. Remarkably, almost everything we care about when we reason under conflict can be recovered from this bare skeleton.

Within this framework, a "reasonable position" is a set $S$ of arguments that can stand together. The minimal requirement is that the position be **conflict-free**: no argument in $S$ attacks another argument in $S$. You cannot simultaneously hold two claims when one refutes the other. But conflict-freeness alone is weak — it lets you accept a lonely claim while ignoring every objection to it. A stronger notion demands that a position **defend itself**: whenever an outside argument $b$ attacks a member $a$ of your position, some member of your position must strike back at $b$. A conflict-free set that defends all of its members is called **admissible** — it is a position you can hold without contradicting yourself *and* without being defenceless.

Among admissible positions, the boldest are the **stable** ones. A stable position doesn't merely survive attacks; it *dominates the entire debate*. Formally, a set $S$ is stable when it is conflict-free and it **attacks every argument it does not contain**: for each argument $a \notin S$, some member of $S$ attacks $a$. There are no abstentions, no undecided claims left on the table. Every argument in the whole framework is either accepted (it's in $S$) or explicitly defeated (something in $S$ attacks it). Stability is the dream of a perfectly decisive verdict.

## The dream that sometimes cannot come true

Here is the twist that this article is about. Weaker notions of a reasonable position always exist — every finite debate has at least one maximal admissible position, called a **preferred extension**, even if that position is the empty set (the verdict "we can commit to nothing"). Stable positions carry no such guarantee. **A debate can be structured so that no decisive verdict exists at all.**

The smallest example is a piece of folklore that turns out to be a theorem. Consider three arguments arranged in a cycle:

$$0 \longrightarrow 1 \longrightarrow 2 \longrightarrow 0.$$

Argument $0$ attacks $1$, argument $1$ attacks $2$, and argument $2$ attacks $0$ — a perfect rock-paper-scissors of refutation. Try to find a stable position. A single argument, say $\{0\}$, is conflict-free, but it fails to attack $1$: nothing in $\{0\}$ points at $1$, since it is $2$ that attacks $0$ and $0$ that attacks $1$ — wait, $0$ does attack $1$, so $\{0\}$ handles $1$; but $\{0\}$ does not attack $2$ (only $1$ attacks $2$), so $2$ is left undefeated. Every single-argument set leaves one argument neither accepted nor attacked. Two arguments together always contain an attacking pair, so no two-element set is conflict-free. The full set of three is riddled with conflict. And the empty set attacks nothing. **The odd cycle has no stable extension whatsoever.**

We prove this exhaustively: after checking every one of the eight possible subsets, none is stable. Quantitatively, the number of stable positions of the 3-cycle is exactly **zero**. Contrast this with a fully symmetric debate on $n$ arguments where everyone attacks everyone else: there the stable positions are precisely the $n$ single-argument verdicts, and their count is exactly $n$. The odd cycle collapses that count all the way to nothing.

The same 3-cycle delivers a second lesson. What *is* the best position one can take there? The answer is the **empty set** — and it is not merely one option among many, it is the *unique* admissible position. Any nonempty candidate contains an argument whose attacker it cannot counter (because in the cycle each argument's sole attacker is itself attacked only by a third party outside any small set). So the empty set is the preferred extension: the maximal admissible position is to commit to nothing. Yet the empty set is emphatically *not* stable — it attacks no one. This is a clean, concrete witness to a strict hierarchy: **every stable position is preferred, but not every preferred position is stable.** The gap between "the boldest verdict we can defend" and "a truly decisive verdict" is real, and the humble 3-cycle exhibits it.

## When decisiveness is guaranteed

If odd cycles sabotage stability, what kind of structure restores it? The answer is a beautiful dividing line, and it hinges on two properties of the attack relation.

Call a debate **symmetric** when disagreement is mutual: if $a$ attacks $b$, then $b$ attacks $a$. This is the world of pure incompatibility — two claims that simply cannot both hold, with no directional "who refutes whom." Call it **irreflexive** when no argument attacks itself: no claim is self-defeating.

In this symmetric, irreflexive world, decisiveness is always achievable. **Every finite symmetric irreflexive debate has a stable position.** The reason is elegant. In a symmetric framework, conflict-freeness already buys you admissibility for free: if an outside argument $b$ attacks your member $a$, then by symmetry $a$ attacks $b$ right back, so your position defends itself automatically. Now take a conflict-free position that is *maximal* — one you cannot enlarge without introducing a conflict. Such a maximal position must exist, because in a finite debate there are only finitely many candidate positions, so some conflict-free set is inclusion-largest. This maximal position is exactly a "facet" of the geometry of the debate, the analogue of a maximal face in a shape built from all the mutually compatible collections of arguments.

Why is this maximal position stable? Suppose some argument $a$ lies outside it. If nothing in the position attacked $a$, then — because the relation is symmetric and irreflexive — we could add $a$ to the position without creating any conflict, contradicting maximality. So something must attack $a$. Every outsider is defeated; the position is stable. In one stroke, *maximality of a conflict-free set becomes decisiveness.* The existence gap closes completely on the symmetric side.

## The role of the self-attack

One might hope that symmetry alone is the magic ingredient. It is not — and the counterexample is almost comically small. Take a single argument that attacks *itself*. This relation is vacuously symmetric (there are no two distinct arguments to disagree asymmetrically), but it is reflexive: the lone argument is self-defeating. Now no position can be stable. The only conflict-free set is the empty set, because including the self-attacking argument immediately violates conflict-freeness. And the empty set cannot attack the one argument in the universe. So even this tiny symmetric debate has no stable position.

The lesson is sharp: **irreflexivity is not a technical convenience — it is necessary.** A single self-defeating claim, even in an otherwise perfectly symmetric world, is enough to make a decisive verdict impossible. More generally, any debate in which *every* argument attacks itself admits no stable position at all, because the only conflict-free set is empty and it can never dominate a nonempty universe.

## Four bold claims, four verdicts

The heart of this work is a quartet of tempting conjectures about when decisive verdicts exist. Each is the kind of clean statement one might guess to be true. Two of them are; two are not.

- **"Every finite debate has a stable position."** *False.* The 3-cycle is the counterexample.
- **"Every maximal defensible position is stable."** *False.* The empty set in the 3-cycle is preferred but not stable.
- **"Every finite symmetric irreflexive debate has a stable position."** *True.* Maximal conflict-free sets are stable there.
- **"Symmetry alone guarantees a stable position."** *False.* One self-attacking argument destroys it.

The pattern that emerges is a precise map of the terrain. Decisiveness is fragile: a single odd cycle or a single self-attack can eliminate it entirely. But it is also *recoverable*: impose mutual disagreement and forbid self-defeat, and a decisive verdict is always guaranteed — not by luck, but because the largest coherent position you can hold turns out, of necessity, to leave no argument undecided.

## Why this matters beyond the puzzle

Abstract argumentation is not a parlour game. It is a foundational model for reasoning under conflict, and it sits underneath legal reasoning systems, automated negotiation, multi-agent decision-making, and the design of AI that must weigh contradictory evidence. When such a system searches for a "stable verdict" — a complete assignment of *accepted* or *rejected* to every claim — it is searching for exactly the stable positions studied here. Knowing *when that search is doomed* is as important as knowing how to run it. A negotiation protocol built on the assumption that a decisive settlement always exists will hang forever on a three-way standoff; a legal reasoner that treats "the boldest defensible position" as synonymous with "a complete verdict" will silently conflate two genuinely different things.

The geometry makes the story memorable. Picture the collection of all coherent positions in a debate as a shape, glued together from every set of mutually compatible arguments — a landscape whose peaks are the maximal coherent positions. In the symmetric, self-consistent world, every peak is a decisive verdict, and there is always a peak. In the world of directed cycles, the landscape can twist so that no peak reaches all the way to decisiveness. The difference between a debate that can be settled and one that cannot is, quite literally, a difference of shape.

There is even a numerical fingerprint. For the fully symmetric all-against-all debate on $n$ arguments, a global topological invariant of this landscape of positions — its Euler characteristic — equals $n$, which is exactly the number of stable verdicts. The count of decisive verdicts is written into the topology of the space of coherent positions. The odd cycle, with its zero stable positions, is the warning that this beautiful correspondence lives in a specific world, and that stepping outside it — through a single directed loop or a single self-attack — can make the boldest kind of agreement vanish.

Sometimes, it turns out, you simply cannot win every argument at once. The surprise is that we can say *exactly* when.
