# The Topology of Impossible Objects: Escher Stairs and Klein Bottles

Look at a Penrose triangle — three sturdy wooden beams joined into a loop, each one apparently turning a corner and receding into the distance, so that after three turns you arrive back where you started, only *lower* than you began. Or climb an Escher staircase, where every single step goes *up*, and yet the flight closes into a perfect loop that returns you to your starting landing. Something is clearly wrong. But *where*, exactly, is the mistake?

That question is subtler than it sounds, and its answer is one of the loveliest pieces of everyday mathematics. The astonishing fact is this: **there is no mistake anywhere in the picture.** Cover the Penrose triangle with your hands so that only one corner shows. That corner is a perfectly ordinary, perfectly buildable joint — you could carve it out of oak. Slide your hands to reveal the next corner. Also fine. Every *local* piece of an impossible figure is entirely consistent. The impossibility is not hiding in any corner. It only appears when you go **all the way around**.

This is the signature of a *global* phenomenon, and mathematicians have a precise name for the invisible quantity that accumulates as you travel around a loop: **holonomy**. The purpose of this article is to make that idea exact, to prove rigorously that the Penrose triangle and the Escher staircase cannot exist, to show that the very same idea explains why a Möbius band has only one side and why a Klein bottle cannot be built in ordinary space — and, most surprisingly, to show that impossibility is a *number* you can measure.

## Cutting the loop into patches

Here is the model. Take any figure that loops back on itself, and slice it into $n$ overlapping patches arranged in a cycle: patch $0$, patch $1$, and so on up to patch $n-1$, with patch $n-1$ overlapping back onto patch $0$ to close the ring. Think of the three beams of the Penrose triangle ($n = 3$), or the flights of an Escher staircase.

Wherever two neighbouring patches overlap, we need a rule that says how to reconcile them. In the depth picture, when we pass from patch $i$ to patch $i+1$, the drawing tells us the second patch lies a little *deeper* (or higher, or further away) than the first, by some amount $t_i$. Collect all these local instructions into a single object, a function

$$t : \{0, 1, \dots, n-1\} \to \mathbb{R}, \qquad i \mapsto t_i,$$

where the indices are read cyclically (patch $n$ *is* patch $0$). We call $t$ the **local increment data** of the figure. Each $t_i$ is a completely reasonable, completely realizable instruction on its own. The drama is in how they fit together.

## The one honest question: is there a global height?

What would it *mean* for the figure to be genuine — actually buildable in space rather than merely drawn? It would mean there is an honest global assignment of depth: a single number $h_i$ attached to each patch, a true "height above the floor," such that every local instruction is simply the difference of two honest heights:

$$h_{i+1} - h_i = t_i \quad \text{for every } i.$$

If such an $h$ exists we say the figure is **realizable**. The local rules are then not really rules at all — they are just bookkeeping, recording the differences of an underlying height field that was there all along. You could build the object out of oak.

Now watch what happens if we simply *add up* all the local increments as we walk once around the entire loop. Define the **holonomy** of the figure to be the total accumulated increment:

$$\mathrm{hol}(t) \;=\; t_0 + t_1 + \cdots + t_{n-1} \;=\; \sum_{i} t_i.$$

If the figure is realizable, this sum *telescopes*. Substituting $t_i = h_{i+1} - h_i$:

$$\sum_i (h_{i+1} - h_i) = (h_1 - h_0) + (h_2 - h_1) + \cdots + (h_0 - h_{n-1}).$$

Every height appears once with a plus sign and once with a minus sign, so the whole thing collapses to **zero**. This is nothing but the discrete Fundamental Theorem of Calculus: if you climb by honest height differences and return to where you started, your net change of altitude is exactly nothing.

So we have proved half of a beautiful equivalence:

> **If a figure is realizable, its holonomy is zero.**

The converse is equally true and just as important. Suppose the holonomy vanishes, $\sum_i t_i = 0$. Then we can *build* a height field by hand: start at $h_0 = 0$ and let each patch's height be the running total of the increments so far,

$$h_i = t_0 + t_1 + \cdots + t_{i-1}.$$

By construction $h_{i+1} - h_i = t_i$ for the steps inside the loop, and the assumption that the total is zero is *exactly* what makes the field close up consistently when we wrap around from the last patch back to the first. So:

> **If a figure's holonomy is zero, it is realizable.**

Putting the two directions together gives the central theorem, clean as a bell:

> **Realizability Theorem.** *A cyclic figure is realizable if and only if its holonomy $\sum_i t_i$ is zero.*

That single equivalence is the whole secret of impossible figures. Impossibility is *precisely* nonzero holonomy — a global sum that refuses to cancel.

## The Penrose triangle, dispatched

Now we can convict the Penrose triangle. It has three beams ($n = 3$), and each beam, by the perfectly symmetric way it is drawn, recedes by the same unit amount: $t_0 = t_1 = t_2 = 1$. Its holonomy is

$$1 + 1 + 1 = 3 \neq 0.$$

By the Realizability Theorem, no global height field exists. **The Penrose triangle is impossible** — provably, and for a reason we can point to. Not because any corner is wrong, but because the honest depths would have to increase by three units over a journey that returns to its start.

Notice what this reveals about the *nature* of the illusion. The local data of the Penrose triangle is perfectly **uniform**: every overlap says exactly the same thing, "go one unit deeper." There is nothing to distinguish one corner from another, nothing locally suspicious at all. And yet the figure is impossible. **Uniform, innocent-looking local data can be globally impossible.** You cannot detect the paradox by inspecting the pieces; you must add them up.

## The Escher staircase, and a warning against local reasoning

The same argument, in one stroke, kills the endlessly ascending staircase. Suppose every step genuinely rises: $t_i > 0$ for all $i$. Then the holonomy is a sum of strictly positive numbers, so it is strictly positive, hence nonzero. By the theorem, the staircase cannot close up into an honest loop. **A closed flight of stairs on which every step ascends cannot exist.** Escher's *Ascending and Descending* is, as promised, a lie — but a globally consistent, locally flawless one.

It is tempting, having seen the uniform Penrose triangle fail, to guess the opposite: perhaps *varied* local data is the culprit, and figures whose overlaps all say different things are the impossible ones. This guess is also wrong, and spectacularly so. Consider a triangle whose three increments are the three *distinct* numbers $1$, $2$, and $-3$. They could hardly be more different from one another. Yet their sum is

$$1 + 2 + (-3) = 0,$$

so this maximally non-uniform figure is **perfectly realizable**. You can build it. Together, the uniform-but-impossible triangle and the varied-but-buildable triangle deliver the moral with full force: **you cannot read impossibility off the local data at all.** Only the global sum — the holonomy — knows the answer.

## Impossibility is a number

Here is the final twist in the depth story. We have been treating holonomy as a yes/no gate: zero means possible, nonzero means impossible. But holonomy is a *real number*, and it turns out every real number is achievable. Given any target $r$, the figure whose first overlap prescribes increment $r$ and whose remaining overlaps prescribe $0$ has holonomy exactly $r$. So the holonomy can be tuned to any value we like.

This means the "impossibility class" of a figure is not merely a flag but a full, continuous measurement — a single real number that both *detects* impossibility (it is zero exactly when the figure is buildable) and *quantifies* it (its magnitude is how badly the figure fails to close). In the language of topology, the space of all impossibility classes is a perfect copy of the real line, $H^1 \cong \mathbb{R}$. Impossibility, it turns out, comes in degrees.

## One-sided worlds: Möbius and Klein

Depth is not the only quantity that can fail to close up. Suppose that instead of tracking *how deep* a patch is, we track *which way it faces* — its orientation. Now the only information at each overlap is a single bit: does the neighbouring patch keep the same handedness ($0$), or flip it ($1$)? The increments live in the two-element arithmetic $\mathbb{Z}/2$, where $1 + 1 = 0$: two flips cancel and restore the original orientation.

Everything we proved goes through verbatim, with "add up the increments" now meaning "count the flips, modulo two." The holonomy is the total number of orientation reversals around the loop, taken mod $2$. It is zero when the flips are even and one when they are odd. And the theorem says: a global, consistent choice of orientation exists **iff** the holonomy is zero.

An **odd** number of flips therefore forbids any global orientation. This is exactly the mathematics of the **Möbius band**: take a strip, give it a single half-twist, and glue the ends. One overlap, one flip, holonomy $1$. There is no way to paint one side red and the other blue, because there is only *one* side — the band is non-orientable, and now we know precisely why. The **Klein bottle** is the same story writ larger: a surface that reverses orientation around a loop, impossible to build in three-dimensional space without passing through itself, for the identical reason that an odd holonomy admits no global fix.

The Penrose triangle and the Klein bottle, objects that seem to belong to utterly different worlds — optical trickery versus abstract topology — are revealed to be two performances of a single theme. In one the accumulating quantity is a real-valued depth; in the other it is a mod-two orientation bit. Both are *impossible* for precisely the same reason: a nonzero holonomy that no local repair can ever remove.

## A twist of scale: developable surfaces

There is one more variation worth telling, because it was the form in which Roger Penrose originally cast the idea. Instead of *adding* depths, imagine each overlap introduces an ambiguity of *scale* — the freedom to rescale the apparent size of the next patch by some positive factor $g_i$. Reconciling scales as we go around means *multiplying* rather than adding, and the accumulated quantity, the **monodromy**, is the product

$$\prod_i g_i.$$

A figure can be assembled into a genuine flat, unbent — technically, *developable* — surface exactly when this product is the identity, $\prod_i g_i = 1$. Everything transposes from the additive world to the multiplicative one: telescoping becomes cancellation, and the impossibility class is now a group element rather than a number, but it remains a complete invariant. A triangle that scales every beam by the same factor $g$ has monodromy $g^3$; if $g^3 \neq 1$ it cannot be flattened. And the same contrarian warning applies: a two-patch figure that scales by $g$ and then by $g^{-1}$ has *both* factors nontrivial, yet builds perfectly, because the scalings cancel around the loop. Once again, impossibility lives in the whole, never in the parts.

## Why it matters

The lesson of impossible figures reaches far beyond optical illusions. The pattern — *everything is fine locally, yet something is broken globally, and the obstruction is a quantity that accumulates around loops* — is one of the great organizing ideas of modern mathematics and physics. It is why a compass carried around a closed path on a curved surface comes back rotated (the holonomy of curvature). It is why an electron circling a magnetic flux picks up a measurable phase even where the field is zero (the Aharonov–Bohm effect). It is why some differential equations have no global solution despite being solvable at every point (the theory of cohomology). Every one of these is a Penrose triangle in disguise: a loop, a locally harmless rule, and a global sum that refuses to vanish.

Escher and Penrose drew their impossible objects to delight and unsettle the eye. What they were really drawing, it turns out, was a picture of holonomy — the mathematics of what you carry with you when you go around and come back changed.
