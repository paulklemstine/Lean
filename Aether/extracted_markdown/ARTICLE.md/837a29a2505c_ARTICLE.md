# When Distance Lives in the Primes: How Number Theory Learns to Be Nonexpansive

## A different kind of nearness

Ask a child how far apart two numbers are, and they will subtract them: 7 and 10 are three apart, 100 and 103 are also three apart. This is the everyday, "archimedean" idea of distance, the one our rulers and odometers obey. It is so deeply wired into us that we rarely notice it is a *choice*.

But there is another way to measure how close two numbers are — one that mathematicians have used for over a century, and that has quietly become central to cryptography, error-correcting codes, and the search for certified, robust machine-learning systems. In this other geometry, two numbers are close not when their difference is *small*, but when their difference is *deeply divisible by a fixed prime*.

Pick the prime 2. In this world, 1 and 9 are fairly close, because their difference 8 = 2³ is divisible by 2 three times. But 1 and 2 are far apart, because their difference 1 is not divisible by 2 at all. The numbers 1, 3, 5, 7, … are all the same comfortable distance from each other, while 1 and 1,048,577 (which differ by 2²⁰) are almost on top of one another. The deeper a difference sinks into the prime, the nearer the two numbers become.

This is the *p-adic* world, and its geometry is strange and beautiful. Its defining feature is a souped-up triangle inequality. In ordinary geometry, the shortest path between two towns is a straight line, but a detour through a third town can only make the trip *somewhat* longer: the distance from A to C is at most the distance from A to B plus the distance from B to C. In the p-adic world, something far stronger holds. The distance from A to C is at most the **larger** of the two legs:

> distance(A, C) ≤ **max**( distance(A, B), distance(B, C) ).

This is the *ultrametric*, or "strong triangle," inequality. It has a startling consequence: **every triangle is isosceles**, with the two longest sides equal. There are no scalene triangles in p-adic space. Distances come in discrete tiers, and you can never sneak between them by adding up small steps. It is a world of nested shells rather than smooth expanses.

This article tells the story of a bridge — a precise, fully verified theorem — connecting two ideas that mathematicians had described separately but never formally linked: a way of measuring the *complexity* of a fraction, and the prime-flavored geometry just described. The punchline is a cautionary tale and a triumph at once. The natural first guess turns out to be **false**, and the failure points the way to the correct construction, which then delivers exactly the kind of guarantee that engineers building trustworthy systems crave: a guarantee that a computation **cannot amplify error**.

## How big is a fraction, really?

Before we can talk about distance, we need a way to talk about the size or complexity of a rational number. Not its magnitude — we already know how to measure that — but how complicated it is to *write down*.

Consider the fraction 3/4. To write it, you need the numerator 3 and the denominator 4. A natural measure of its complexity is simply the sum of those two parts: 3 + 4 = 7. The fraction 1/1000 looks small on a number line, but it is genuinely complicated to specify — you need a thousand in the denominator — so its complexity is 1 + 1000 = 1001. This quantity is called the **arithmetic height** of the fraction. Formally, for a fraction written in lowest terms as a ratio of a whole-number numerator and a positive denominator, the height is

> height(q) = |numerator of q| + denominator of q.

Heights are the workhorses of modern number theory. They power the great finiteness theorems — the statements that say "there are only finitely many solutions of such-and-such bounded complexity" — and they let mathematicians do induction on how complicated a number is. The height has three reassuring properties that we can check by hand. It is always at least 1, because every fraction needs a positive denominator (height of 0 is 0 + 1 = 1). It never sees a difference between a number and its negative: the height of 3/4 equals the height of −3/4, because flipping a sign does not change |numerator| + denominator. And it grows as fractions get more elaborate.

So here is the tempting idea. We have a notion of "size" for fractions (the height) and we want a notion of "distance." Why not define the distance between two fractions as the height of their difference, and hope the strong triangle inequality falls out? That would instantly fuse number theory's favorite complexity measure with the elegant ultrametric world. It is exactly the kind of unification that makes a mathematician's pulse quicken.

It is also wrong.

## The instructive failure

The honest first move in any such project is to try to break your own idea before someone else does. So we test the strong triangle inequality on the simplest possible example: does the height obey

> height(q + r) ≤ max( height(q), height(r) )?

Take q = 1 and r = 1. Each has height 1 + 1 = 2, so the right-hand side is max(2, 2) = 2. Their sum is 2, written as the fraction 2/1, whose height is 2 + 1 = 3. And 3 is not less than or equal to 2.

The inequality fails — and it fails at the very first nontrivial number you could try, 1 + 1. This is recorded as a formal theorem in its own right, a *falsifier*:

> **Theorem (the height is not an ultranorm).** It is not true that for all fractions q and r, height(q + r) ≤ max(height(q), height(r)). The inequality already breaks at q = r = 1, where height(2) = 3 exceeds max(height(1), height(1)) = 2.

Why does it break? Because the height is sensitive to *magnitude*. Adding 1 to 1 makes a genuinely bigger number, and the height dutifully reports that growth. But the ultrametric world refuses to let sums grow — that is the entire content of the strong triangle inequality. The two philosophies are in direct conflict. The height is an *archimedean* creature; the ultrametric is *nonarchimedean*. You cannot make one into the other by wishing.

This is not a dead end. It is a signpost. The failure tells us precisely what to fix: we need a notion of size that *ignores magnitude and listens only to divisibility by a prime*. We need, in other words, the p-adic valuation we met at the start.

## The right normalization

For a fixed prime p, define the p-adic size of a nonzero number by asking how many times p divides it (counting denominators as negative). If a number is divisible by p exactly k times, its p-adic size is p^(−k): the more divisible it is, the *smaller* it is. The number 8 = 2³ has 2-adic size 2^(−3) = 1/8, very small. The number 1/2 has 2-adic size 2, larger than 1. Odd numbers all have 2-adic size 1. And the special number 0 is assigned size 0, infinitely divisible, infinitely close to everything.

This is the **p-adic absolute value**, and unlike the height it is built for the ultrametric world. We can package its essential properties into a clean checklist — a *rational ultravaluation* — which is any size function on the fractions that is never negative; is zero only for the number 0; is blind to sign; turns multiplication into multiplication (the size of a product is the product of the sizes); and, crucially, obeys the strong triangle inequality

> size(x + y) ≤ max( size(x), size(y) ).

The p-adic absolute value passes every item on this checklist. It is a genuine rational ultravaluation — the corrected object that the failed height pointed us toward.

From any such valuation we get a distance in the obvious way: the distance between x and y is the size of their difference,

> dist(x, y) = size(x − y).

A few lines of bookkeeping confirm this deserves to be called a distance. It is never negative; the distance from a point to itself is 0; it is symmetric, because the size is blind to sign, so the size of (x − y) equals the size of −(x − y) = (y − x); and it separates points, meaning the distance is zero only when the two numbers are equal. Most importantly, it inherits the strong triangle inequality. The proof is a single elegant observation: the difference x − z can be split as (x − y) + (y − z), and then the valuation's own strong triangle inequality finishes the job:

> **Theorem (strong triangle law).** For any fractions x, y, z and any rational ultravaluation, dist(x, z) ≤ max( dist(x, y), dist(y, z) ).

So we now possess a genuine ultrametric on the rational numbers, built from a prime. Every triangle is isosceles; distances live in tiers; the geometry is the nested-shell world of the p-adics. The naive bridge collapsed, but the corrected bridge stands.

## The payoff: computations that cannot make things worse

A distance is only as interesting as the maps that respect it. Here is where the story turns from geometry to guarantees.

Call a function **nonexpansive** if it never increases distances: applying it to two inputs leaves the outputs at most as far apart as the inputs were. Nonexpansive maps are the gold standard of stability. If your data has some uncertainty — a measurement error, an adversarial perturbation, a rounding mistake — a nonexpansive map promises that the uncertainty in the output is no larger than the uncertainty in the input. Errors cannot snowball. In an age of fragile machine-learning models that can be fooled by imperceptible tweaks, a *certified* nonexpansiveness is exactly the kind of ironclad robustness guarantee that researchers chase.

When is an arithmetic operation nonexpansive in our prime-flavored geometry? The central result of this work — the **bridge theorem** — gives a sharp, two-part answer:

> **Bridge theorem (valuation monotonicity implies nonexpansiveness).** Let f be a function on the fractions that (i) is *additive on differences*, meaning f(a − b) = f(a) − f(b), and (ii) does not increase the valuation, meaning size(f(a)) ≤ size(a) for every a. Then f is nonexpansive: dist(f(x), f(y)) ≤ dist(x, y) for all x and y.

The logic is beautifully tight. The distance between f(x) and f(y) is, by definition, the size of f(x) − f(y). Additivity lets us rewrite that difference as f(x − y). Valuation monotonicity then says the size of f(x − y) is no bigger than the size of x − y, which is exactly dist(x, y). Two hypotheses, one clean conclusion.

And both hypotheses are *necessary* — this is the "sharp" in sharp result. Drop additivity, and the trick of pulling the difference inside the function fails: f(x) − f(y) is no longer f(x − y), and the valuation bound on f has nothing to attach to. The theorem isolates the exact conditions under which a prime-flavored computation is guaranteed safe. That is the difference between a slogan and a theorem: a theorem tells you precisely where the guarantee lives and where it evaporates.

## Building safe pipelines

Real systems are not single operations; they are chains of them — pipelines, layers, compositions. So the natural next question is whether safety survives composition. It does, and gracefully.

> **Composition closure.** If f and g are both nonexpansive, then so is their composition g ∘ f. More generally, if f is C-Lipschitz (it scales distances by at most a factor C) and g is D-Lipschitz, then g ∘ f is (C·D)-Lipschitz.

This is the engineer's dream: build your guarantee once for each component, and the guarantee for the whole assembled system follows automatically, with the constants simply multiplying. A stack of nonexpansive layers is nonexpansive. A pipeline of mildly expansive stages has a worst-case amplification that is just the product of the stage-by-stage factors — and you can read it off the parts without ever analyzing the whole.

Concretely, the simplest safe operations are multiplication by a fixed integer and integer affine maps (multiply by an integer, then add a constant). Both are additive on differences, and scaling by an integer can only make a number *more* divisible by the prime, never less — so the valuation cannot increase. They are certified nonexpansive, and they can be chained at will.

## Two worlds, reconciled

There is a final, satisfying thread that ties the discarded height back to the prime geometry that replaced it. Although the height fails to *be* an ultravaluation, it still *dominates* the prime data inside it. For any whole number n and any prime p, the largest power of p dividing n is no larger than the height of n:

> **Height comparison.** p^(number of times p divides n) ≤ height(n).

In words: the height, that crude sum of numerator and denominator, already contains within it an upper bound on the depth to which any single prime can divide a number. The height is too blunt to serve as a distance, but it is a faithful *ceiling* on the prime-by-prime valuations that do. The two worlds, archimedean and nonarchimedean, are not enemies after all; one bounds the other. And on whole-number data, the prime distance is always at most 1 — integers live inside the unit shell of the p-adic world, a tidy boundedness statement that anchors the whole picture.

## Why this matters

It is tempting to dismiss prime-flavored distances as a curiosity, but they are anything but. The p-adic numbers underlie modern number theory, from the proof of Fermat's Last Theorem to the Langlands program. Ultrametric spaces are the natural habitat of lattice-based cryptography — the leading candidate for encryption that can withstand quantum computers — and of the algebraic codes that keep your data intact as it crosses noisy channels. And nonexpansiveness, the property at the heart of this bridge, is the mathematical bedrock of certified robustness in machine learning, where the goal is to *prove*, not merely hope, that a small change in input cannot trigger a catastrophic change in output.

The deeper lesson is methodological. The most valuable step in this entire story was the moment we proved our own first idea wrong. The height-as-distance dream was elegant, plausible, and false, and discovering its falseness at 1 + 1 was not a setback but the key insight. It told us exactly what to replace and how. The corrected construction — built on the p-adic valuation — then yielded a genuine ultrametric, a sharp bridge theorem certifying when arithmetic is nonexpansive, and a clean calculus for composing safe operations into safe pipelines.

Distance, it turns out, is not one thing. It is a choice, and different choices reveal different structures. Choosing to measure nearness through the primes turns the familiar number line into a landscape of nested shells, where every triangle is isosceles and certain computations are guaranteed never to make things worse. That is a world worth knowing — and now, a world with a rigorously charted bridge connecting it back to the everyday arithmetic we thought we already understood.
