# The Squeeze: How Far Can a Polynomial Shrink a Set of Numbers?

Take a handful of whole numbers — say $-2, -1, 0, 1, 2$ — and feed each one through a simple machine: the squaring map $f(x) = x^2$. Out come $4, 1, 0, 1, 4$. Strip away the duplicates and you are left with the *set* $\{0, 1, 4\}$. Five numbers went in; only three came out.

This tiny experiment hides one of the central questions of modern additive combinatorics. When you push a finite set of integers through a polynomial, how much can the set shrink, and how much must it grow? The answer turns out to be governed by two crisp, universal barriers — a floor and a ceiling — that hold for *every* polynomial and *every* finite set at once. This article is about those two barriers, why they exist, and what the surprisingly delicate gap between them tells us.

## Two forces in tension

A polynomial map does two contradictory things to a set.

On one hand, it can **collapse** the set by mapping different inputs to the same output. Squaring collapses $2$ and $-2$ into the single value $4$. That is why $\{-2,-1,0,1,2\}$ shrank.

On the other hand, a polynomial is not *free* to collapse a set as much as it likes. The equation $x^2 = 4$ has only two solutions. More generally, the equation $f(x) = b$ can have at most $k$ solutions when $f$ has degree $k$, because a degree-$k$ polynomial has at most $k$ roots. This is the oldest fact in the theory of equations, and it is the hero of our story.

Let us write $|A|$ for the number of elements in a finite set $A$, and $f(A)$ for the image set $\{f(a) : a \in A\}$ with duplicates removed. The two forces translate into two clean inequalities.

## The floor: a polynomial cannot crush a set too hard

Here is the first barrier. Suppose $f$ is a polynomial of degree $k \ge 1$. Then for any finite set of integers $A$,
$$|f(A)| \ \ge\ \frac{|A|}{k}.$$

In words: the image can be at most $k$ times smaller than the original. The map cannot squeeze the set by more than a factor equal to its degree.

The reason is beautifully simple, and it is exactly the root-counting fact from above. Group the elements of $A$ according to where they land. Each *fiber* — the set of inputs sharing a common output value $b$ — is a set of solutions to $f(x) = b$, and there can be at most $k$ of them. So $A$ is carved into fibers, each of size at most $k$, and there are exactly $|f(A)|$ of these fibers (one per output value). Counting elements,
$$|A| \ \le\ k \cdot |f(A)|,$$
which rearranges into the floor. For the squaring map, $k = 2$, so the image can be at most twice as small as the domain — and the symmetric window $\{-n, \dots, n\}$ shows this factor of $2$ is genuinely achieved, since almost every value is hit by exactly the pair $\{a, -a\}$.

This "fiber estimate" is the exact, finitary skeleton underneath every so-called *power-saving lower bound* in the subject. Those deeper theorems are wrapped in incidence geometry and asymptotics, but at their core lives this one-line observation: a degree-$k$ equation has at most $k$ solutions, so the image cannot collapse by more than a factor of $k$.

## The ceiling: the image is never bigger than the domain

The second barrier is even more elementary, but stating it carefully reveals a subtlety that trips up the whole field. Since $f(A)$ is obtained by applying a function to $A$ and discarding repeats, we always have
$$|f(A)| \ \le\ |A|.$$

You can never get more output values than input values. That is the ceiling.

But researchers like to phrase the ceiling in a fancier, more suggestive way. They write it as a *power-saving* estimate,
$$|f(A)| \ \le\ |A|^{\,k - c},$$
for some positive constant $c$ called the *power saving*. The idea is that as the degree grows, the exponent $k - c$ measures how far the image is from the naive worst case of $|A|^k$ that one might fear from a degree-$k$ object.

How large a power saving $c$ can we honestly guarantee? Here is the clean answer for the elementwise image. Set
$$c(k) \ =\ \frac{1}{k^2}.$$
Then for every polynomial of degree $k \ge 2$ and every nonempty finite set $A$,
$$|f(A)| \ \le\ |A|^{\,k - 1/k^2}.$$

Why is this true, and why this particular constant? It rests on a single real-number inequality: for $k \ge 2$,
$$1 \ \le\ k - \frac{1}{k^2}.$$
Indeed $\tfrac{1}{k^2} \le 1 \le k - 1$, so subtracting $\tfrac{1}{k^2}$ from $k$ never drops the exponent below $1$. Combined with the plain ceiling $|f(A)| \le |A|$ — which is $|f(A)| \le |A|^1$ — raising the base $|A| \ge 1$ to the larger exponent $k - 1/k^2$ only increases the right-hand side. So the fancy power-saving bound holds, with the explicit, unconditional constant $c = 1/k^2$.

## The sandwich

Put the floor and the ceiling together and you trap the image cardinality inside a corridor:
$$\frac{|A|}{k} \ \le\ |f(A)| \ \le\ |A|^{\,k - 1/k^2}.$$

This is the headline result: a two-sided estimate, valid for every monic integer polynomial of degree $k \ge 2$ and every nonempty finite set of integers. The left wall is genuine root-counting content; the right wall packages the trivial ceiling in the language the subject prefers.

Let us sanity-check the corridor on our opening example. Take $f(x) = x^2$, so $k = 2$, and $A = \{-2,-1,0,1,2\}$ with $|A| = 5$. The image is $\{0,1,4\}$ with $|f(A)| = 3$. The corridor predicts
$$\frac{5}{2} = 2.5 \ \le\ 3 \ \le\ 5^{\,2 - 1/4} = 5^{1.75} \approx 16.72,$$
and indeed $2.5 \le 3 \le 16.72$. The image sits comfortably inside its predicted band.

## The honest confession

Now for the twist that makes this story more than a pair of textbook inequalities. The two walls of the corridor are wildly asymmetric in how tight they are.

The floor is *sharp*. The squaring map on a symmetric window pushes $|f(A)|$ right down to roughly $|A|/2$, saturating the factor $k = 2$. You cannot do better; the floor is the truth.

The ceiling, by contrast, is almost embarrassingly loose — and deliberately so. Can a polynomial ever *expand* a set, making $|f(A)|$ genuinely larger than $|A|$? No. It is impossible. There exist arithmetic progressions on which a polynomial is perfectly injective — every input yields a distinct output — so that $|f(A)| = |A|$ exactly. On such sets the image neither shrinks nor grows. This means the exponent in the upper bound can *never* be pushed below $1$. The much-advertised power saving of $1/k^2$ is, for the single elementwise image, mostly cosmetic: the real and unavoidable content is that the exponent is pinned to exactly $1$ from below.

This is a genuinely useful clarification. The constant $1/k^2$ is quoted throughout the literature as *the* power saving, but for the univariate elementwise image it describes slack in a bound that is dominated by the trivial ceiling. The honest phenomenon is entirely on the floor side — the root-counting obstruction — and the corridor above makes that separation precise and unconditional.

## Where the real expansion hides

If a single polynomial image refuses to expand, where does the celebrated "expansion" of additive combinatorics actually live? The answer is that you must look at *combinations* of images rather than a single one.

Consider the **difference set** $f(A) - f(A)$, the collection of all differences $f(a) - f(b)$. A single image cannot grow, but the difference set should expand strictly: the conjecture in this circle of ideas is that
$$|f(A) - f(A)| \ \ge\ c_k \cdot |A|^{\,1 + 1/k^2}$$
for degree $k \ge 2$. Here the exponent finally climbs above $1$ — genuine power gain. The mechanism is that coincidences of the form $f(a) - f(b) = f(c) - f(d)$ correspond to integer points on a fixed algebraic surface, and the at-most-$k$-to-one structure limits how many such coincidences can happen. Fewer coincidences means smaller *additive energy*, which forces the difference set to be large. The very same root-counting fact that built our floor becomes, one level up, the engine of expansion.

There is a second frontier too. Because the fibers of $f$ are exactly the orbits of the finite symmetry group permuting the roots of $f(x) = b$, one can *engineer* sets on which every fiber has the full size $k$ by assembling the domain out of whole orbits. This should drive the image down to its theoretical minimum for *every* even polynomial, not just squaring — a clean orbit-counting phenomenon waiting to be nailed down. And a third: the small constant $1/k^2$ appears to be the correct order of magnitude not for the univariate image at all, but for the multivariate $k$-fold image $f(A_1, \dots, A_k)$, suggesting that the folklore constant secretly belongs to a different, genuinely multivariate problem.

## Why it matters

These questions are not idle. The interplay between multiplication (through polynomials) and addition (through sums and differences of sets) is the beating heart of the *sum–product phenomenon*, which underpins results in analytic number theory, the theory of exponential sums, pseudorandomness, and even the construction of expander graphs used in computer science and cryptography. Understanding exactly how a polynomial reshapes a set — how much it can compress, when it must expand — is a foundational step toward those applications.

What is satisfying here is how much can be said with complete certainty and almost no machinery. Two inequalities, one of them merely the fact that a degree-$k$ equation has at most $k$ roots, are enough to trap the image of any polynomial in a precise corridor. The floor is sharp, the ceiling is honest about being loose, and the gap between them points like a signpost toward where the real mathematics — expansion — begins. Sometimes the most valuable thing a theorem can do is tell you, exactly and provably, which of your hopes are already settled and which still lie open.
