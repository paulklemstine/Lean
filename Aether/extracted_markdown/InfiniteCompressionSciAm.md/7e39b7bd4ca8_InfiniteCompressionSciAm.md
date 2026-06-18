# Can You Compress Infinity into a Point? What Stereographic Projection Reveals About the Limits of Data

*A mathematical proof, verified by computer, shows why a beautiful geometric trick can't break the laws of information.*

---

Imagine you could take every photograph ever taken, every book ever written, every song ever recorded, and compress it all down to a single point. Not a hard drive, not a data center — a mathematical *point*, infinitely small, containing infinite information.

It sounds like science fiction. And according to a new set of machine-verified mathematical proofs, it *is* — but the reason why is more subtle and more beautiful than you might expect.

## The Trick: Stereographic Projection

The story begins with one of mathematics' most elegant constructions: the stereographic projection. Take a sphere — like a beach ball — and place it on a flat table. Now imagine a light at the very top of the ball (the "north pole"). Every point on the ball casts a shadow on the table. Points near the bottom of the ball cast shadows close to where the ball touches the table. Points near the top cast shadows far away.

Here's the magical part: *every* point on the ball (except the north pole itself) maps to exactly one point on the table, and vice versa. The entire infinite plane maps onto the finite sphere. The north pole corresponds to "infinity."

This means you can take an infinite amount of geometric real estate and wrap it up into a compact sphere. Points that are far apart on the plane get squeezed together near the north pole. The farther out you go, the more compressed things become.

## The Dream: Infinite Compression

This squeezing effect inspired a provocative idea: what if you could use it for data compression? Encode your data as points on the plane, then project everything onto the sphere. Pack data closer and closer to the north pole. The "solid angle" — the amount of sphere surface you're using — shrinks toward zero, while the data keeps piling up.

The "informational mass density" — bits per unit of sphere surface — climbs toward infinity. In principle, you could pack *all the data in the world* into an infinitesimally small region near the pole.

## The Catch: Pigeonhole Meets Geometry

So why doesn't this work? The answer comes from one of the simplest ideas in all of mathematics: the pigeonhole principle.

If you have 10 pigeons and 9 pigeonholes, at least one hole must contain two pigeons. If you have 256 possible messages and only 128 possible compressed representations, at least two messages must share a representation. You can't tell them apart. Information is lost.

The stereographic projection works beautifully in the *continuous* world — the world of real numbers with infinite precision. In that world, you really can pack infinitely many points near the pole, because real numbers have infinitely many decimal places. Every point is distinct.

But data compression lives in the *discrete* world — the world of bits. Your data comes in chunks: bytes, kilobytes, gigabytes. And no matter how cleverly you map those chunks onto a sphere, you need enough *distinct, distinguishable* codewords at the other end to represent each unique input. If you have 2ⁿ possible inputs and only 2ⁿ⁻¹ possible outputs, you *will* lose information.

## Machine-Verified Certainty

What makes this analysis unusual is that every claim has been formally verified by a computer. Using Lean 4, a proof assistant developed for mathematical formalization, researchers proved 18 theorems covering:

- **The stereographic projection really works:** The formula maps any point in the plane to the unit sphere (verified algebraically).
- **The roundtrip identity holds:** Projecting to the sphere and back recovers the original point (verified).
- **Solid angle really does shrink:** As data moves toward the pole, the angle subtended decreases monotonically (verified).
- **But compression is impossible:** No injective (lossless) function exists from 2ⁿ elements to fewer than 2ⁿ elements (verified via pigeonhole).
- **The impossibility theorem:** Any lossless encoder-decoder system mapping 2ⁿ values to 2ⁿ⁻¹ values leads to a logical contradiction (verified).

The computer checked every logical step. No hand-waving, no "it's obvious" — just pure, verified deduction from axioms.

## What This Means

The result isn't that stereographic projection is useless — far from it. It's used throughout mathematics, physics, and computer graphics. It's how cartographers project the round Earth onto flat maps (with the famous property of preserving angles). It's how complex analysis connects the complex plane to the Riemann sphere.

What the result *does* tell us is that **geometric tricks can't circumvent counting arguments**. You can make your data *look* compressed — squeezed into a tiny region of a sphere — but unless you reduce the number of distinguishable states, you haven't actually compressed anything.

In the language of the proof: information density can diverge to infinity (`density_diverges`), but the pigeonhole principle still prevents any injection from a larger discrete set to a smaller one (`density_vs_pigeonhole`).

## The Deeper Lesson

This story illustrates a recurring theme in mathematics and computer science: the tension between the continuous and the discrete. The real number line is infinitely divisible — between any two numbers, there's always another. But digital data is made of bits: zeros and ones, finite and countable.

Many beautiful ideas from continuous mathematics — infinite series, smooth curves, limits at infinity — translate imperfectly to the digital domain. Stereographic projection is one more example: a perfect bijection in the continuous world that becomes lossy the moment you discretize.

The machine-verified proofs give us absolute certainty about where the line is. Not "probably impossible" or "we think it can't work" — but *proved impossible*, with every step checked by computer, right down to the axioms.

---

*The full Lean 4 formalization is available at `Stereographic/InfiniteCompression.lean`. The accompanying research paper provides complete mathematical details.*
