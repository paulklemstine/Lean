# Three Letters Are Enough to Break the Rules

## How a tiny change of alphabet turns rigid, predictable reversibility into a wild zoo — and what that means for building ciphers

Imagine a circular necklace of beads. Each bead carries one of a small number of colours. A clock ticks, and at every tick each bead looks at itself and at its two immediate neighbours, then recolours itself according to a fixed rule — the *same* rule for every bead, forever. That is a **radius-one cellular automaton**: the simplest interesting model of a world where information moves only locally, one step at a time.

Now ask the question that has haunted this model since John von Neumann and Stanislaw Ulam invented cellular automata in the 1940s, and that Tommaso Toffoli and Norman Margolus turned into an engineering discipline in the 1980s:

> **When can you run the clock backwards?**

A rule is called **reversible** if, no matter how long the necklace is, the map "one tick of the clock" is a bijection on colourings: different starting patterns always lead to different next patterns, so the past is uniquely recoverable from the present. Reversibility matters far beyond mathematics. Physics is reversible at the microscopic level, so reversible automata are the natural discrete models of physical dynamics. Reversible computing promises circuits that in principle dissipate no heat. And for cryptography, a reversible automaton is exactly what a block cipher round needs: a permutation of the state space that is cheap to compute in parallel, uniformly, everywhere at once.

There is an obvious way to build reversible rules, and it is boring. Let the new colour of a bead be a fixed recolouring — a permutation $\sigma$ of the colour set — applied to *one* of the three cells it can see: itself, or its left neighbour, or its right neighbour. In symbols, the local rule $g(a,b,c)$ (where $a$ is the left neighbour's colour, $b$ is your own, $c$ is the right neighbour's) is one of
$$g(a,b,c)=\sigma(a),\qquad g(a,b,c)=\sigma(b),\qquad g(a,b,c)=\sigma(c).$$
These *single-coordinate rules* just rotate the whole necklace by one position (or keep it in place) and repaint the colours. Of course they are reversible: rotate back and unpaint. With three colours there are exactly $3 \times 6 = 18$ of them, three choices of window cell times the six permutations of three colours.

The question that drives this article is brutally simple:

> **Are these all?**

For two colours, remarkably, the answer is *yes*. For three colours, the answer is *no* — spectacularly no. And the boundary between the two worlds sits exactly between two letters and three.

---

## The binary world is rigid

Start with two colours, say $0$ and $1$. There are $2^8 = 256$ possible local rules, since a rule is a choice of output for each of the eight possible neighbourhood patterns. One can simply check all of them, and the result is clean:

> **The Binary Rigidity Theorem.** *Over a two-letter alphabet, a radius-one rule whose global map is bijective on every finite cycle must be a single window cell followed by a permutation of the alphabet. There are exactly six such rules.*

Even better, the infinite test collapses at once. It is not necessary to check every necklace length: bijectivity on the cycles of length $1$, $2$, $3$ and $4$ already forces the single-coordinate form. And four is exactly the right cut-off, not an artefact — twenty of the $256$ binary rules survive the weaker test using only lengths $1$, $2$ and $3$, and fourteen of those twenty are impostors, exposed only when a necklace of length $4$ is tried.

So the binary world is *rigid*: reversibility there means "shift and repaint", and nothing else. A cryptographer looking at binary radius-one automata finds no raw material at all. Every reversible rule is a relabelled rotation, which mixes nothing.

---

## Three colours, and the sign twist

Add a single colour and the picture explodes. The cleanest way to see this is to stop thinking of the three colours as decorations and start thinking of them as *numbers*: the field $\mathbb{F}_3=\{0,1,2\}$, where arithmetic is done modulo $3$. In this field the nonzero elements are $1$ and $2 = -1$, the two "signs", and each squares to $1$.

Define a function that reads a *sign* off a colour:
$$\operatorname{sgn}(x) = \begin{cases} 1 & x = 0,\\ -1 & x \neq 0.\end{cases}$$
It is deliberately crude: it does not see *which* nonzero colour it is given, only *whether* the colour is zero.

Now build the rule
$$g^\star(a,b,c) \;=\; \operatorname{sgn}(a)\cdot b\cdot \operatorname{sgn}(c).$$
In words: keep your own colour, but flip its sign once for each nonzero neighbour. This rule visibly uses all three cells of its window — change either neighbour from $0$ to something nonzero and the output flips — so it is not a rotation in disguise.

And yet it is reversible. Why? Because of a small conspiracy between the two ingredients:

1. Multiplying a colour by $\pm 1$ never changes *whether* it is zero. So the pattern of zeros and nonzeros — the only thing $\operatorname{sgn}$ can see — is exactly the same in the output necklace as in the input necklace.
2. Signs square to $1$.

Put these together. Given the output necklace, you can read off which cells were nonzero originally, hence recompute the twisting factor $\operatorname{sgn}(a)\cdot \operatorname{sgn}(c)$ at every position from the output alone, and undo it by multiplying again. In other words the rule *decodes itself*: applying $g^\star$ twice returns you exactly where you started, on every necklace length, all at once.

> **The Sign-Twist Theorem.** *For each choice of signs $u,v \in \{1,-1\}$, the rule $g_{u,v}(a,b,c)=\operatorname{sgn}_u(a)\, b \,\operatorname{sgn}_v(c)$ — where $\operatorname{sgn}_u(x)$ equals $1$ if $x=0$ and $u$ otherwise — is an involution on every finite cycle, hence reversible. For $u=v=-1$ it genuinely depends on all three cells of its window, and is therefore not a single window cell followed by a permutation.*

That one rule already refutes the classification claim. But the refutation can be made insulting. Post-compose $g_{u,v}$ with any affine repainting $x \mapsto cx+d$ where $c \in \{1,-1\}$ and $d$ is any colour; reversibility survives, and as long as at least one of the two twists is nontrivial the resulting rule still reads two or more window cells. Counting the parameters $(u,v,c,d)$ with $u,v,c$ signs and $(u,v)\neq(1,1)$ gives $3 \times 2 \times 3 = 18$ distinct rules.

> **The Counting Refutation.** *There are at least eighteen radius-one ternary rules that are bijective on every finite cycle and are not of the predicted single-coordinate form — exactly as many counterexamples as the claim allows rules in total.*

The classification claim does not merely leak. It misses at least as many rules as it names.

---

## It was never about three: it was about "more than two"

The sign trick uses arithmetic in $\mathbb{F}_3$, which might look like a lucky accident of the number three. It is not. Here is the same idea stripped of algebra, valid over *any* alphabet with at least three letters $x_0, x_1, x_2$:

$$g(a,b,c) \;=\; \begin{cases} b \text{ with } x_1 \text{ and } x_2 \text{ swapped}, & \text{if } c = x_0,\\ b, & \text{otherwise.} \end{cases}$$

Read your right neighbour; if it displays the special marker $x_0$, transpose the two other letters in your own cell; otherwise do nothing. The transposition *fixes the marker* $x_0$, so the positions displaying $x_0$ are exactly the same before and after the tick. Therefore the output tells you, at each site, whether the transposition fired — and a transposition is its own inverse. Once again the rule decodes itself and is an involution on every cycle. It reads its own cell and its right neighbour, so it is not a single-coordinate rule.

> **The Size-Two Dichotomy.** *For an alphabet with $q$ letters, "every rule that is bijective on all finite cycles is a single window cell followed by a permutation" is true if and only if $q \le 2$.*

Rigidity is a two-letter phenomenon. It dies the moment a third letter enters, and it never comes back.

---

## Where rigidity survives: the linear world

Nothing so unruly happens if you insist on *linearity*. Consider rules built from the arithmetic of $\mathbb{F}_3$ alone,
$$g(a,b,c) = \alpha a + \beta b + \gamma c + \delta ,$$
with fixed coefficients $\alpha,\beta,\gamma,\delta$. On a necklace of length $n$ this is nothing but multiplication by the Laurent polynomial $\alpha x^{-1} + \beta + \gamma x$ in the ring $\mathbb{F}_3[x]/(x^n-1)$, plus a constant. Reversibility for *all* $n$ says the polynomial $\alpha + \beta x + \gamma x^2$ must not vanish at any root of unity in any extension of $\mathbb{F}_3$ — that is, it must have no nonzero root at all. A polynomial of degree at most two with no nonzero root is a monomial.

> **The Affine Classification.** *The rule $g(a,b,c)=\alpha a+\beta b+\gamma c+\delta$ over the three-letter field is bijective on every finite cycle if and only if exactly one of $\alpha, \beta, \gamma$ is nonzero — that is, if and only if it is a single window cell followed by the permutation $x \mapsto \alpha x + \delta$.*

So the failed claim is exactly right inside the linear world, and the counterexamples are, unavoidably, nonlinear. That is not a footnote: it is a design lesson. Cryptographic mixing in this setting is a nonlinear resource.

The linear world also hands us a beautiful piece of arithmetic. If a linear rule is *not* reversible, on which necklace length does it first betray itself? The answer is governed by roots of unity over $\mathbb{F}_3$. The multiplicative group of the nine-element field $\mathbb{F}_9$ is cyclic of order $8$, so the only orders of roots of unity available are $1, 2, 4, 8$ — and those are exactly the necklace lengths on which a failing linear rule can first fail. Since all four divide $8$, one length rules them all:

> **The One-Length Test.** *A linear ternary rule is bijective on every finite cycle as soon as its map on the single necklace of length $8$ is injective — a finite check on $3^8=6561$ states.*

And $8$ cannot be lowered. The rule $g(a,b,c) = a+b+2c$ is injective on every necklace of length $1$ through $7$, and fails at length $8$: the configuration $(1,1,2,0,2,2,1,0)$ is annihilated, so it collides with the all-zero configuration. Its characteristic polynomial $2x^2+x+1$ has roots of multiplicative order exactly $8$ in $\mathbb{F}_9$. Once it fails, it fails forever: reversibility descends to divisors, so the failure at length $8$ propagates to $16$, $24$, $32$, and every other multiple.

That last sentence is a general principle worth isolating. Reducing indices modulo a divisor is a ring homomorphism, so a configuration on a short necklace can be repeated to fill a longer one, and the tick commutes with the repetition. Hence:

> **Divisor Monotonicity.** *If the tick map is injective on the necklace of length $n$, it is injective on the necklace of every length dividing $n$.* Equivalently: failures propagate upward to all multiples.

---

## Taming an infinite test

Reversibility, as defined, quantifies over infinitely many necklace lengths. Is it even *decidable*? Yes — and the reason is a pigeonhole argument that deserves to be seen.

Suppose a rule fails to be injective on some necklace. Unrolling the two colliding configurations into doubly-periodic sequences $S$ and $T$, we obtain two infinite strings that are *locally indistinguishable* — the rule produces the same output at every position — and that differ somewhere. Watch the pair of strings advance, and record at each step the four letters
$$(S_k,\; S_{k+1},\; T_k,\; T_{k+1}).$$
There are only $q^4$ possible records over an alphabet of $q$ letters. So on a necklace longer than $q^4$ the same record must occur twice, at positions $i<j$. At such a repetition the cyclic word can be cut in two ways: **keep** the loop between $i$ and $j$, producing a valid collision of period $j-i$; or **delete** it, producing a valid collision of period $n-(j-i)$. Both splices are legitimate, precisely because the two boundary records agree, so the local three-cell condition still holds across the seam. Whichever half retains a position where $S$ and $T$ differ is a genuinely shorter collision. Induct.

> **The Finite Test.** *Over an alphabet with $q$ letters, a radius-one rule is bijective on every finite cycle as soon as its map is injective on the cycles of length $1, 2, \dots, q^4$. In particular, reversibility is a decidable property of the rule table. For three letters, the lengths up to $81$ decide everything.*

Combine this with divisor monotonicity and even the *list* of lengths collapses: every length up to $q^4$ divides $(q^4)!$, so injectivity on the single cycle of length $(q^4)!$ is equivalent to full reversibility. That length is astronomically large and of purely theoretical interest — but the phenomenon it expresses is the same one that makes the crisp length-$8$ criterion work in the linear world.

Exhaustive computation suggests the truth is far friendlier than $q^4$. The longest first-failure length observed is $4=2^2$ for two letters and $8$ for three letters, against the proved bound $81$ — which is why the natural conjecture is that $q^2$ suffices, with the three-letter case pinched between the proved-attainable $8$ and the conjectured $9$.

---

## The inverse can be wider than the rule

Here is the final surprise, and the one with the sharpest engineering edge. All the counterexamples so far were involutions: they were their own inverse, so the inverse automaton had the same radius as the rule. Must that always happen? No.

Let $\operatorname{swap}$ denote the transposition of $0$ and $1$ that fixes $2$, and define
$$g(a,b,c) = \begin{cases} \operatorname{swap}(a), & \text{if } b \neq 0 \text{ and } c = 2,\\ a, & \text{otherwise.}\end{cases}$$
This rule copies the left neighbour, applying the transposition exactly when a specific pattern occurs to the right.

> **The Inverse-Radius Theorem.** *This rule is bijective on every finite cycle: an explicit decoder recovers each cell from the four output cells to its right. But no decoder of window three exists — at any of the five possible offsets — and there is no radius-one inverse automaton at all. Its decoding width is exactly four.*

The mechanism is worth savouring. The transposition fixes the letter $2$, so the sites carrying $2$ remain visible in the output — that much is like the earlier tricks. But deciding whether the transposition *fired* at a given cell requires knowing whether its right neighbour is nonzero, which itself requires peeking one cell further right. Information needed to invert therefore travels a bounded but strictly *greater* distance than the rule's own reach. Concretely, on a necklace of length $5$, the all-zero configuration and $(0,0,1,1,2)$ produce outputs that agree in three consecutive positions yet come from configurations differing in the middle of that window: a radius-one inverse would have to give two different answers from identical inputs.

---

## Why a cryptographer should care

Take stock of what the three-letter alphabet gives you that the two-letter alphabet does not.

**Nontrivial reversible mixing exists.** Over two letters, reversible radius-one dynamics is nothing but shift-and-repaint: no diffusion, no mixing, no cryptographic value. Over three, there are reversible rules that genuinely read the whole window. Those rules are permutations of the state space $\{0,1,2\}^n$ for every $n$, computable in parallel in one pass, with a local circuit of constant size — the profile a lightweight round function wants.

**The useful ones are nonlinear.** The classification is exactly true inside the linear world, so every nontrivial reversible rule is nonlinear. Linear round functions are the ones cryptanalysis eats for breakfast; here, nonlinearity is not an add-on but a structural consequence.

**Reversibility is checkable.** A designer does not need to gamble on invertibility. Reversibility is decidable, and the check is a bounded, mechanical search. In the linear case, the whole infinite question reduces to one injectivity test on $6561$ states. In general, the number of relevant states is a constant depending on the alphabet only, not on the message length: the pair-record graph above is the algorithm, and it runs in time polynomial in the size of the rule table.

**The forward/backward asymmetry is real.** The last theorem shows that a rule with a two-gate forward circuit can require a strictly wider circuit to invert. That is precisely the shape of trapdoor-flavoured asymmetry designers hunt for in lightweight primitives: cheap one way, measurably less cheap the other, with the gap being a provable statement about neighbourhood width rather than a heuristic about effort.

Two caveats keep the picture honest. Involutions — such as the sign-twisted family — are a liability, not an asset, if used naively as a round function: applying them twice returns the input. And a *single* pass of a radius-one rule moves information only one cell, so any real design must iterate; the theory here characterises the round function's building blocks, not a whole cipher.

---

## The moral

A single extra letter transforms a rigid, fully classified world into one rich enough to require a decision procedure. The dividing line is exactly at two letters, and the mechanism of the transition is elegant: with three letters you can mark a site with a colour that a permutation fixes, and use that marker as a *self-erasing instruction*. The instruction is visible in the output because the permutation cannot destroy the marker, so the reader can undo whatever the writer did. Reversibility, in this world, is not about doing nothing much — it is about leaving a trace of what you did.

That such a small world hides a decision procedure, a sharp arithmetic threshold at the multiplicative order $8$ of roots of unity over $\mathbb{F}_9$, and a provable gap between the width of a rule and the width of its inverse — that is the pleasure of the subject.
