# Why Every Fair Voting System Must Sometimes Flip a Coin

## A hidden bridge between the geometry of spheres and the politics of voting

Imagine you are designing the perfect voting system. You want it to be
*fair*. Specifically, you want three things that sound almost too modest to
argue with. First, if **every single voter** prefers chocolate to vanilla,
then society should prefer chocolate to vanilla — no committee should be able
to overrule a unanimous public. Second, no single person should secretly be a
dictator whose ballot always decides the outcome. And third, the system should
behave *smoothly*: a tiny shift in how the electorate feels should produce only
a tiny shift in the result, never a sudden, violent lurch.

These wishes feel separate, almost unrelated. One is about respecting unanimity.
One is about democracy. One is about stability. Yet there is a theorem — old,
beautiful, and at first glance about something else entirely — which says that
**you cannot have all three at once**. And the astonishing part is *where* this
theorem comes from. It does not come from economics, or political science, or
game theory. It comes from the geometry of spheres.

This is the story of how a fact about wrapping rubber bands around circles turns
out to be a fact about the impossibility of perfect democracy. The slogan, which
we will earn by the end, is simple and a little vertiginous: **social choice is
topology.**

---

## A walk around the world, and a guarantee about temperature

Let us start far away from politics, with a claim that sounds like a magic
trick.

> *At this very moment, somewhere on the equator of the Earth, there are two
> points exactly opposite each other — antipodal points — that have exactly the
> same temperature.*

This isn't a coincidence about today's weather. It is *guaranteed*, every single
day, by pure logic. Here is why.

Walk all the way around the equator and record the temperature as you go. Call
the temperature at position $\theta$ (an angle from $0$ to $360°$) the number
$T(\theta)$. Now look at the **difference** between the temperature at a point
and the temperature directly across the globe from it:

$$ g(\theta) = T(\theta) - T(\theta + 180°). $$

Here is the trick. Suppose at your starting point the difference $g(0)$ is
*positive* — your side is warmer than the far side. Then walk halfway around, to
the antipode of your start. From *there*, the "far side" is your original
starting point, so the difference is exactly reversed:

$$ g(180°) = T(180°) - T(360°) = T(180°) - T(0°) = -g(0). $$

So $g$ starts positive and ends negative (or vice versa). Temperature changes
continuously — it does not teleport — so somewhere in between, the difference
$g$ must pass through **zero**. At that spot, $T(\theta) = T(\theta + 180°)$: a
pair of antipodal points with identical temperature. Always. Guaranteed.

This little argument is the **one-dimensional Borsuk–Ulam theorem**. In its
full generality, proved by Karol Borsuk in 1933 (conjectured by Stanisław Ulam),
it says something breathtaking about every dimension at once: any continuous way
of assigning $n$ numbers to the points of an $n$-dimensional sphere must give the
**same** $n$ numbers to some pair of antipodal points. On the ordinary globe
(a 2-sphere), assign to each point its temperature *and* its barometric pressure;
Borsuk–Ulam promises a pair of antipodal points that agree on **both** at once.

The engine underneath the one-dimensional case is something every calculus
student meets: the **Intermediate Value Theorem**. If a continuous quantity is
negative here and positive there, it must be zero somewhere in between. You
cannot get from below the water to above the water without, at some instant,
breaking the surface. That homely fact — that continuity forbids teleportation —
is the entire secret. Everything that follows is this fact in disguise.

---

## The preference circle

Now we cross the bridge to voting. The leap is to realize that **preferences can
be arranged on a circle**, and that a circle is exactly the 1-dimensional sphere
on which Borsuk–Ulam lives.

Picture an electorate trying to decide between two candidates, $A$ and $B$.
Each possible "mood" of the electorate — how strongly it leans, on balance,
toward one or the other — can be encoded as a single angle $\theta$ running
around a circle. As $\theta$ sweeps from $0$ all the way around and back, the
public mood slides continuously through every possible configuration of opinion.

The crucial structure is the **antipodal map**. Standing at angle $\theta$ is a
particular profile of opinions; standing directly across the circle, at
$\theta + 180°$, is its perfect mirror image — *every voter's ranking reversed*.
Where one profile says "$A$ over $B$," its antipode says "$B$ over $A$," voter
by voter, all the way down. The antipode is the political opposite, the photo
negative of the electorate.

A **social welfare function** — call it $\mathrm{swf}$ — is the voting rule
itself. It reads the public mood $\theta$ and returns a single number,
$\mathrm{swf}(\theta)$: the **social margin** of $A$ over $B$. A positive number
means society favors $A$; a negative number means society favors $B$; and zero
means a dead tie. We demand three properties of an ideal rule.

**Continuity.** The rule reacts smoothly. Nudge the public mood a little and the
social margin moves a little. No cliffs, no sudden reversals from a hair's-breadth
change of opinion. Formally, $\mathrm{swf}$ is a continuous function. (We also
ask that it be periodic — going all the way around the circle of moods returns
you to where you started — which is just what it means to live on a circle.)

**Reversal symmetry.** If you reverse every voter's opinion, the social verdict
should reverse too. If the whole electorate flips from leaning $A$ to leaning
$B$, the rule cannot keep insisting on $A$. In symbols:

$$ \mathrm{swf}(\theta + 180°) = -\,\mathrm{swf}(\theta). $$

This is the mathematical heart of fairness between the two candidates — neutrality,
no thumb on the scale. It is the continuous shadow of the unanimity principle:
flip everyone, and the answer flips. It also rules out a dictator, who would
cling to a fixed verdict regardless of the public.

**Decisiveness.** The rule always actually decides. It never returns a tie. For
every mood $\theta$, the margin $\mathrm{swf}(\theta)$ is nonzero — society always
comes down on one side.

Three reasonable wishes. A smooth rule, a neutral rule, a rule that always picks
a winner. Now watch them collide.

---

## The collision

Feed our smooth, reversal-respecting rule $\mathrm{swf}$ into the temperature
argument from before. It *is* a continuous quantity on the circle, so the
1-dimensional Borsuk–Ulam theorem applies word for word. There must exist some
public mood $\theta^\star$ where the rule gives the *same* value to that mood and
to its antipode:

$$ \mathrm{swf}(\theta^\star) = \mathrm{swf}(\theta^\star + 180°). $$

But reversal symmetry tells us the right-hand side is the *negative* of the
left-hand side:

$$ \mathrm{swf}(\theta^\star + 180°) = -\,\mathrm{swf}(\theta^\star). $$

Put these together and you get

$$ \mathrm{swf}(\theta^\star) = -\,\mathrm{swf}(\theta^\star), $$

which forces

$$ \mathrm{swf}(\theta^\star) = 0. $$

A tie. At that particular configuration of the electorate, the smooth, neutral
rule is *mathematically compelled* to throw up its hands and declare a dead
heat. Decisiveness is dead on arrival. There is no escape, no clever rule, no
patch. We have proved:

> **The Continuous Arrow Impossibility.** *There is no voting rule that is
> simultaneously continuous, reversal-respecting, and decisive. Any smooth,
> neutral rule must produce a tie at some configuration of voters.*

This is the same shape as Kenneth Arrow's celebrated 1951 impossibility
theorem, for which he won the Nobel Prize: no voting system can satisfy a short
list of innocent-looking fairness axioms at once. Arrow worked in a discrete,
combinatorial world of finite lists of preferences. Here, the *continuous* face
of the same impossibility falls out of a fact about spheres — a viewpoint
pioneered by the economist Graciela Chichilnisky in the 1980s. The obstruction
that Arrow uncovered by hand is, in this guise, **a topological coincidence you
cannot avoid.**

---

## Why honesty matters: the theorem is not a cheat

A skeptic should immediately worry: maybe the impossibility is empty. Maybe no
rule satisfies *any* of these axioms, so saying "no rule satisfies all three" is
a hollow victory, like proving no unicorn can fly.

It is not hollow, and we can prove it by exhibiting rules that satisfy the
axioms *individually*. The function $\mathrm{swf}(\theta) = \sin\theta$ is
perfectly continuous, perfectly periodic, and perfectly reversal-respecting:
$\sin(\theta + 180°) = -\sin\theta$ is a classic identity. So continuity and
reversal can absolutely coexist — but $\sin$ has zeros (it ties twice per
circuit), so it sacrifices decisiveness, exactly as the theorem demands.

Going the other way, a constant nonzero rule like $\mathrm{swf}(\theta) = 1$
("$A$ always wins, by one point") is continuous and gloriously decisive — but it
flunks reversal, because flipping every voter leaves the verdict stubbornly at
$A$. It is, in fact, a dictator in disguise.

So each axiom is satisfiable; pairs of them are satisfiable; it is only the
**full trio** that is forbidden. The impossibility is real, sharp, and earned.

---

## The escape hatch — and what it costs

If continuity is the culprit, what happens when we *abandon* it? We get our
decisiveness back, but at a price that reveals exactly what continuity was buying.

Consider the **square-wave rule**: starting at one mood, it declares "$A$ wins"
in one half of the circle and "$B$ wins" in the other half, snapping abruptly
between $+1$ and $-1$. Formally, $\mathrm{socialWave}(\theta) = (-1)^{\lfloor
\theta/180°\rfloor}$. This rule *is* decisive — it never returns zero — and it
*does* respect reversal, since crossing to the antipode lands you in the opposite
half and flips the sign. It satisfies two of our three axioms and dodges the
tie.

But our impossibility theorem now does something delightful: it *forces a
conclusion about the real world* from pure logic. Since the square-wave rule is
decisive and reversal-respecting, and since no rule can be all three, the
square-wave rule **must be discontinuous.** We never had to inspect its graph or
hunt for the jump; the existence of the jump is *deduced*. And of course there it
is, at the boundary between the two halves, where an infinitesimal change of mood
flips society violently from "$A$ wins outright" to "$B$ wins outright." That
cliff is the price of decisiveness. Smoothness and a guaranteed winner cannot
share a circle.

---

## The deepest layer: an impossibility made of symmetry

There is one more turn of the screw, and it is the most beautiful. *Why*,
structurally, must the tie exist? The answer is a single algebraic fact about the
antipodal map.

Going to the antipode and then to the antipode *again* brings you home: applying
"reverse every voter" twice is the same as doing nothing. That makes the
antipodal map an **involution** — a symmetry of order two, an action of the
two-element group $\mathbb{Z}/2$. And this particular involution is **free**: no
profile is its own antipode. No configuration of the electorate is identical to
its own complete reversal. There is no perfectly balanced fixed point sitting
still under the flip. In the crisp language of the group, the nonzero element
acts without fixed points: $1 + x \neq x$ for every $x$ in $\mathbb{Z}/2$.

This is the secret heart of the whole matter. The **analytic** obstruction — the
forced tie, the zero of a continuous function — is the visible shadow of an
**algebraic** obstruction — a free symmetry with nowhere to rest. The
Intermediate Value Theorem and the fixed-point-freeness of $\mathbb{Z}/2$ are two
faces of one coin. A continuous odd function on the circle cannot avoid zero for
*exactly* the same reason that flipping the electorate has no fixed point. The
impossibility of perfect democracy is, at bottom, a statement that a certain
symmetry of the political sphere can never sit still.

---

## So what?

Step back and feel the size of the claim. Kenneth Arrow's theorem is usually
taught as a cautionary tale of economics: democracy is hard, fairness is
delicate, paradoxes lurk. What this perspective reveals is that the paradox is
not really about economics at all. It is about the **shape of the space of
opinions**. Preferences live on a sphere. Reversing everyone is the antipodal
map. Fairness is symmetry under that map. Stability is continuity. And the moment
you write the problem in that language, the impossibility is no longer surprising
— it is *inevitable*, a special case of a theorem about wrapping spheres that has
been sitting in the topology textbooks since 1933.

This is what mathematics does at its best: it shows you that two things you
thought were strangers are secretly the same thing wearing different clothes. The
temperature on the equator, the impossibility of fair voting, a rubber band that
cannot be combed flat, the free flip of a two-element group — all of them are the
single, stubborn fact that **continuity forbids teleportation**, viewed from
different angles.

There is no fair, smooth, decisive voting system. Not because economists haven't
been clever enough, but because the topology of the preference sphere will not
allow it. Every such system must, somewhere, fall silent and flip a coin. And
the coin it flips is, in the end, geometry.
