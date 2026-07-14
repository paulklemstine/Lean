# Alien Number Systems: How a Single Complex Digit-Base Names Every Point on a Grid

## A world without the minus sign

Imagine handing a pocket calculator to a visitor from another world and asking them to write down numbers. We take our decimal system for granted — ten digits, place values that climb by powers of ten, a minus sign bolted on for anything below zero, and a decimal point for anything in between. But none of these choices is forced by mathematics. They are conventions, and remarkably fragile ones. Change the base from ten to two and you get binary. Change it to a *negative* number and something surprising happens: the minus sign disappears entirely, because the alternating signs of the powers already reach every integer, positive and negative alike.

This article is about a stranger and more beautiful possibility still. What if the base itself were a *complex number* — a number with an imaginary part? Could a single such base, with just the two digits $0$ and $1$, name not only every whole number on the number line but every point on an entire two-dimensional grid of numbers, each exactly once, with no minus sign, no second "imaginary digit," and no decimal point?

The answer, astonishingly, is yes. The magic base is $\beta = i - 1$, and the result is a theorem first observed by Walter Penney in 1965. This article tells its story.

## The grid of Gaussian integers

The two-dimensional grid in question is the set of **Gaussian integers**: complex numbers of the form $a + b\,i$ where $a$ and $b$ are ordinary integers and $i$ is the imaginary unit satisfying $i^2 = -1$. Written $\mathbb{Z}[i]$, this set forms a perfect square lattice in the plane — think of graph paper where every intersection of grid lines is a number. The point $3 + 2i$ sits three units east and two units north of the origin; the point $-1 - i$ sits one unit west and one unit south.

Gaussian integers can be added, subtracted, and multiplied just like ordinary integers, and they obey all the familiar algebraic laws. They are the natural home for a two-dimensional theory of "whole numbers." The question Penney answered is: **can we write every one of these lattice points using a positional number system built on a single base?**

## Why a complex base can reach everywhere

Here is the crux of the idea. In ordinary base ten, the value of a string of digits $d_k \ldots d_1 d_0$ is
$$ d_0 + d_1 \cdot 10 + d_2 \cdot 10^2 + \cdots + d_k \cdot 10^k. $$
Each digit is multiplied by a power of the base and the results are summed. The powers $1, 10, 100, \ldots$ all point in the same direction along the number line, so no matter how you choose the digits you can only ever reach non-negative numbers. That is why base ten needs a minus sign.

Now replace the base by $\beta = i - 1$ and keep only the digits $0$ and $1$. A digit string now has value
$$ d_0 + d_1 \beta + d_2 \beta^2 + d_3 \beta^3 + \cdots, \qquad d_j \in \{0, 1\}. $$
The powers of $\beta$ no longer march in a single direction. Let us compute the first few:
$$ \beta^0 = 1, \quad \beta^1 = -1 + i, \quad \beta^2 = -2i, \quad \beta^3 = 2 + 2i, \quad \beta^4 = -4. $$
They spiral outward through the plane, pointing in every direction — east, northwest, south, northeast, west — and growing in size as they go. Because the powers of $\beta$ fan out across all directions of the plane rather than lining up on a ray, sums of them can land *anywhere* on the grid. The two-dimensionality of the complex numbers is exactly what removes the need for a sign and for a separate imaginary digit. One base does all the work.

A small taste: the imaginary unit $i$ itself, which you might think would need its own symbol, is simply
$$ i = 1 + \beta = 1 + (i - 1). $$
In digit form (least-significant digit first) that is the string $11$. And the humble number $-1$, which in decimal demands a minus sign, becomes the string $11101$, meaning
$$ 1 + \beta + \beta^2 + 0\cdot\beta^3 + \beta^4 = 1 + (i-1) + (-2i) + 0 + (-4) = -1. $$
No sign in sight.

## The two halves of the theorem

Penney's theorem makes two claims at once, and they pull in opposite directions.

**Existence:** *every* Gaussian integer can be written as such a string. Nothing on the grid is missed.

**Uniqueness:** *no* Gaussian integer can be written in two genuinely different ways. Nothing on the grid is named twice.

To state uniqueness cleanly we must, as with ordinary numbers, forbid pointless leading zeros: just as $007$ and $7$ should not count as different, we require that a digit string not end (in its most-significant position) with a $0$. A string obeying this rule is called **canonical**. The precise statement is then:

> **Theorem (Penney, 1965).** The map sending each canonical string of $0$s and $1$s to its value in base $\beta = i - 1$ is a bijection onto the Gaussian integers. Every Gaussian integer has exactly one canonical representation.

## Uniqueness: a parity fingerprint

Why can't two different canonical strings collide? The key is a beautifully simple observation about the *last* digit — the units digit $d_0$.

Take any Gaussian integer $z = a + b\,i$. Look at the sum $a + b$ of its two coordinates and ask whether it is even or odd. It turns out this single bit of information *is* the units digit:
$$ d_0 = (a + b) \bmod 2. $$
The reason is that every power $\beta^1, \beta^2, \beta^3, \ldots$ has coordinates whose sum is even — you can check this for the list above ($-1+1 = 0$, $0 + (-2) = -2$, $2 + 2 = 4$, and so on) — so all of the higher digits contribute an *even* amount to $a + b$. Only the units digit $d_0$, contributing $1$ when it is $1$, can tip the parity. The parity of $a + b$ therefore reads off $d_0$ with no ambiguity whatsoever.

Once the units digit is forced, subtract it and divide by $\beta$. This peels off one digit and leaves a smaller Gaussian integer whose units digit is forced in turn, and so on. Since each step is completely determined, two canonical strings with the same value must agree digit by digit — they are the same string. Uniqueness follows.

## Existence: the peeling process, and a treacherous trap

The same peeling process suggests how to *build* a representation: read off the forced digit $d_0 = (a+b) \bmod 2$, subtract it, divide by $\beta$, and repeat until you reach $0$. Concretely, dividing $z = a + b\,i$ (after subtracting its digit) by $\beta = i - 1$ sends it to the new Gaussian integer with coordinates
$$ \left( \frac{b - a}{2},\ -\frac{a + b}{2} \right), $$
and the subtraction of the digit guarantees both of these are whole numbers. Iterating this map should march any starting point down to zero, and the digits collected along the way are its representation.

But *why* does the process always terminate? The natural guess is to track the **size** of the number — its squared distance from the origin, $a^2 + b^2$, the so-called Gaussian norm — and hope it shrinks at every step. If it always got strictly smaller, the process could not run forever, and existence would be a one-line argument.

Here lies the trap, and it is the genuinely deep feature of a complex base. **The norm does not always shrink.** The cleanest counterexample is the imaginary unit itself:
$$ i \ \longmapsto\ 1, $$
a single peeling step that carries the point $i$ (norm $1$) to the point $1$ (norm $1$) with *no decrease at all*. A naive "the size always drops" induction is therefore simply false, and any honest proof must confront this.

The resolution is both concrete and satisfying. The size *does* strictly decrease at every step **except** at a small, explicitly identifiable set of exceptional points — precisely five of them:
$$ i, \quad -i, \quad -1, \quad -2 + i, \quad -2 - i. $$
Everywhere else on the infinite grid, one peeling step brings you strictly closer to the origin. At each of these five special points, one checks by hand that a couple of further steps escort it safely down into the shrinking region. With the five exceptions handled individually and the rest handled by the size argument, the process is guaranteed to terminate for every Gaussian integer. Existence is proved, and with uniqueness already in hand, Penney's theorem is complete.

That the entire subtlety of a two-dimensional, complex, sign-free number system distills down to *five* misbehaving points is the kind of small miracle that makes the subject a delight.

## A family of alien radices

Base $i - 1$ is one of three headline "alien" number systems, each defying a different assumption baked into base ten.

- **Negative bases** (such as base $-2$, "negabinary") throw out the minus sign. Because the powers of a negative base alternate in sign, the digits alone reach both positive and negative integers.
- **The complex base $i - 1$** throws out both the sign *and* the extra dimension, folding an entire two-dimensional lattice of numbers into strings over a single two-symbol alphabet — the story of this article.
- **Irrational bases**, most famously base $\varphi$ built on the golden ratio $\varphi = (1 + \sqrt 5)/2$, throw out the assumption that a base must be a whole number. In the golden-ratio system every positive integer has a representation, and a natural canonical form (forbidding two adjacent $1$s) makes it unique — a cousin of the classical Zeckendorf representation by Fibonacci numbers.

Together these three show just how much of "the way numbers work" is convention rather than necessity. Negative, complex, and irrational bases each expand the notion of a positional number system in a different direction, and each turns out to be perfectly consistent.

## Why anyone should care

Beyond their intrinsic charm, complex bases have a real engineering pedigree. Because base $i - 1$ encodes a complex number as a *single* stream of bits — with no separate handling of real and imaginary parts, no sign bit, and no special case for negatives — it was proposed early in the history of computing for hardware that manipulates complex quantities directly, from signal processing to certain arithmetic units. A single uniform representation means a single uniform adder and multiplier.

There is also a hauntingly beautiful geometric side. If you allow infinite digit strings after a "radix point," the set of complex numbers representable in base $i - 1$ fills out a fractal region of the plane known as the **twin dragon** — a self-similar tile whose copies interlock to cover the entire plane without gaps or overlaps. The clean, discrete uniqueness theorem for Gaussian integers is the whole-number shadow of this continuous, fractal tiling. The same base that tidily names every lattice point also paints one of the most striking self-similar shapes in all of mathematics.

## The moral

Strip away the accidents of history — ten fingers, a minus sign, a decimal point — and ask what a number system *must* be, and you find a landscape far wider than the one we were taught. In it lives a single complex base, $\beta = i - 1$, wielding only the digits $0$ and $1$, that names every point of a two-dimensional grid once and only once. Its proof hinges on a one-bit parity fingerprint for uniqueness and, for existence, on the discovery that a natural measure of size shrinks everywhere but at five stubborn points. It is a compact, complete, and genuinely alien way to count — and it was hiding inside the complex numbers all along.
