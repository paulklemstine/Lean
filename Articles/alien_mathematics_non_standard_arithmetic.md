# Alien Arithmetic: What Counting Looks Like in a Universe with Infinite Integers

## A thought experiment

Imagine a civilization whose mathematicians count exactly as we do — they add, multiply, factor, prove that primes never run out — but whose number system contains integers larger than every integer we will ever write down. Not "very large." *Larger than all of them.* Their number $\omega$ exceeds $1$, $10$, $10^{100}$, and every numeral any human could produce, yet it is a perfectly good number: it has a successor $\omega+1$, a predecessor $\omega-1$, a parity, a prime factorization, a remainder when divided by $7$.

The startling fact is that such a civilization is not a fantasy. A number system of this kind exists, it can be built in a few lines from the ordinary natural numbers, and — this is the punchline — **it satisfies every single first-order theorem of ordinary arithmetic**. There is no sentence of the language of arithmetic (built from $0$, $+$, $\times$, $<$, and quantifiers over numbers) that we could send to the aliens as a test, no property expressible in that language that would let them detect that their numbers are strange.

And yet their world is not ours. It is uncountable where ours is countable. Its order has no least infinite element. Some regions of it are entirely free of primes. Below we take a guided tour of exactly what survives the trip and what breaks.

## Building the alien numbers

The construction is the *ultrapower*, and its idea is beautifully simple: **a new number is an infinite sequence of old numbers, and two sequences count as the same number when they agree "almost everywhere."**

To make "almost everywhere" precise we need a way of deciding, for every set $S \subseteq \mathbb{N}$ of coordinate positions, whether $S$ is *large* or *small*, in a way that is consistent:

- $\mathbb{N}$ itself is large, $\varnothing$ is small;
- the intersection of two large sets is large;
- of any set and its complement, exactly one is large;
- every finite set is small.

Such a device is a *nonprincipal ultrafilter* on $\mathbb{N}$. Its existence follows from Zorn's lemma; no explicit example can be written down, which is the first hint that we are building something genuinely new.

With largeness in hand, define the **hypernaturals** $\,{}^\ast\mathbb{N}$: elements are sequences $f : \mathbb{N} \to \mathbb{N}$, and $f$ and $g$ name the same hypernatural, written $f \sim g$, when $\{i : f(i) = g(i)\}$ is large. The equivalence class of $f$ is written $[f]$. Arithmetic and order are defined coordinatewise:
$$[f] + [g] = [\,i \mapsto f(i)+g(i)\,], \qquad [f] < [g] \iff \{i : f(i) < g(i)\}\ \text{is large}.$$
Because largeness decides every set, the order is *total*: exactly one of $<$, $=$, $>$ holds for any two hypernaturals, even when the underlying sequences cross each other infinitely often.

Two special inhabitants:

- Each ordinary number $n$ appears as the constant sequence, the **standard** hypernatural $n^\ast = [\,i \mapsto n\,]$.
- The identity sequence gives $\omega = [\,i \mapsto i\,]$. For each fixed $n$, the set of coordinates where $i > n$ is cofinite, hence large, so $n^\ast < \omega$ for *every* $n$. The number $\omega$ is **unlimited**: bigger than every standard number.

That is the whole construction. Everything below is consequence.

## Nothing you can say will detect the difference

The first theorem is the reason the aliens pass every test.

> **Transfer Principle (Łoś's Theorem).** Let $M$ be any first-order structure and let ${}^\ast M$ be its ultrapower along an ultrafilter. Then a first-order sentence holds in ${}^\ast M$ if and only if it holds in $M$. In particular ${}^\ast\mathbb{N}$ and $\mathbb{N}$ satisfy exactly the same first-order sentences: they are *elementarily equivalent*.

The proof is by induction on the structure of a formula, the interesting step being negation, where the ultrafilter's "exactly one of $S$, $S^c$ is large" rule converts "not almost-everywhere true" into "almost-everywhere false." Existential quantifiers require the axiom of choice: from a coordinatewise supply of witnesses one assembles a single witnessing sequence.

Concretely, transfer means the alien number system is a commutative semiring with a linear order compatible with $+$ and $\times$; every element has a unique successor; every number greater than $1$ has a prime divisor; the primes are infinite in number. Their textbooks are ours, word for word.

## The two kinds of set: internal and external

If transfer settles everything, where does the strangeness live? In the *sets*.

Transfer speaks about sentences quantifying over numbers. It says nothing about arbitrary collections of hypernaturals. And here the ultrapower splits the world in two.

A subset of ${}^\ast\mathbb{N}$ is **internal** if it too is a sequence: given ordinary sets $A_0, A_1, A_2, \dots \subseteq \mathbb{N}$, the internal set $[A]$ consists of exactly those $[f]$ with $\{i : f(i) \in A_i\}$ large. Internal sets are the sets the aliens themselves can talk about — the ones assembled coordinatewise out of legitimate finite-level data. All other subsets are **external**: they exist in our meta-mathematical view of the model, but are invisible from inside.

The dividing line is razor sharp, and two "spilling" theorems police it.

> **Overspill.** If an internal set contains every standard hypernatural, it must also contain an unlimited one.

The proof is a lovely diagonal trick. Suppose the internal set $[A]$ contains every $n^\ast$; then for each $n$, $n \in A_i$ for almost all $i$. Define $f(i)$ to be the *largest* element of $A_i$ below $i$ (or $0$ if none). At almost every coordinate this reaches at least any prescribed level, so $[f]$ is unlimited, and by construction $[f] \in [A]$.

> **Underspill.** If an internal set contains every unlimited hypernatural, it already contains a standard one.

This follows by applying overspill to the complement — and complements behave perfectly, because in an ultrapower $[f] \notin [A]$ if and only if $[f] \in [A^c]$.

The immediate corollary is the most important structural fact about the model:

> **The standard cut is external.** No internal set has exactly the standard numbers as its members. Likewise, no internal set consists exactly of the unlimited numbers.

The aliens cannot see which of their numbers are "real." From inside, the boundary between finite and infinite does not exist.

## Which classical laws survive?

Now we can be precise about the title question. Every classical property of $\mathbb{N}$ has an *internal* version and an *external* version, and the pattern is uncannily consistent: **internal survives, external fails.**

**Least number principle.** Every nonempty internal set has a least element — take, coordinatewise, the minimum $\min A_i$; the resulting germ is in the set and below everything in it. But the external set of unlimited numbers has *no* least element: if $H$ is unlimited so is $H - 1$, and $H - 1 < H$. Well-ordering, the very soul of $\mathbb{N}$, holds internally and fails externally.

**Induction.** If an internal set contains $0$ and is closed under successor, it is everything. (Proof: if some $[h]$ escaped, then at almost every coordinate $A_i$ contains $0$ but not $h(i)$, so it has a "last element before $h(i)$", $c(i)$, with $c(i) \in A_i$ and $c(i)+1 \notin A_i$; the germ $[c]$ then contradicts closure under successor.) But induction fails for the external predicate "is standard": $0$ is standard, the successor of a standard number is standard, and yet $\omega$ is not standard.

**Completeness.** In $\mathbb{N}$, every nonempty set bounded above has a greatest element. Internally this survives verbatim: if $[A]$ is nonempty and bounded above by $[b]$, then a transfer argument shows almost every $A_i$ is pointwise bounded by $b(i)$, and the coordinatewise maximum gives an element of $[A]$ that is simultaneously the maximum and the least upper bound. Externally it fails as badly as possible: the standard cut is bounded above (by $\omega$), yet it has *no* least upper bound at all — every upper bound is unlimited, and unlimited numbers admit strictly smaller unlimited ones.

Three classical pillars, three clean splits.

## The model is enormous

How many alien numbers are there? Exactly as many as there are real numbers.

> **Cardinality Theorem.** $|{}^\ast\mathbb{N}| = \mathfrak{c}$, the cardinality of the continuum. Moreover the set of unlimited hypernaturals alone already has size $\mathfrak{c}$, while the standard part has size $\aleph_0$. In particular ${}^\ast\mathbb{N}$ is uncountable, so there is no bijection between it and $\mathbb{N}$.

The upper bound is free: hypernaturals are a quotient of $\mathbb{N}^{\mathbb{N}}$, which has size $\aleph_0^{\aleph_0} = \mathfrak{c}$. The lower bound uses a pretty analytic construction. For a positive real $r$, form the *staircase* $S_r = [\,i \mapsto \lfloor i \cdot r \rfloor\,]$. Each $S_r$ is unlimited, since $\lfloor i r \rfloor$ passes any level $c$ once $i > (c+1)/r$. And if $0 < r < s$, then once $i > 1/(s-r)$ we have $i s \ge i r + 1 > \lfloor i r \rfloor + 1$, so $\lfloor i r\rfloor < \lfloor i s\rfloor$ at almost every coordinate: $S_r < S_s$. Distinct slopes give distinct — indeed strictly ordered — hypernaturals, so continuum-many unlimited numbers exist.

A countable standard part, an uncountable body of unlimited elements, and no first-order sentence able to tell any of it apart from ordinary $\mathbb{N}$: elementary equivalence is a far weaker relation than isomorphism, and here is the proof in the flesh.

## Galaxies: infinitely many scales of infinity

Non-Archimedean means: there are numbers $H < K$ with $K$ larger than $H + n$ for every standard $n$. So the model breaks into *galaxies*. Say $H$ and $K$ are in the **same galaxy** when $|H - K|$ is standard — formally, when $K \le H + n^\ast$ and $H \le K + n^\ast$ for some ordinary $n$. This is an equivalence relation and is compatible with addition. Write $H \prec K$ ("$K$ is far above $H$") when $H + n^\ast < K$ for every $n$; for $H<K$ this is exactly the statement that they lie in different galaxies, and $\prec$ descends to a strict linear order on galaxies.

What does that order look like?

> **Galaxy Structure Theorem.** The galaxy order has a least element, the standard galaxy $\mathbb{N}$ (a galaxy is above it precisely when its members are unlimited). Above that least element the order is **dense** — between any two galaxies lies a third — and has **no greatest element** and **no least nonstandard element**. Consequently there is an infinite strictly decreasing chain of galaxies of unlimited numbers.

Each claim has a one-line witness. Density: given $H \prec K$, the pointwise midpoint $[\,i \mapsto f(i) + (g(i)-f(i))/2\,]$ is far above $H$ and far below $K$. No maximum: $H \prec H + \omega$. No least nonstandard galaxy: if $H$ is unlimited, so is $H/2$, and $H/2 \prec H$. Iterating the halving produces $\omega \succ \omega/2 \succ \omega/4 \succ \cdots$, an infinite descending sequence of *scales*.

So the failure of the Archimedean property is not a single blemish. It is a densely ordered continuum of incomparable magnitudes — the order type $\mathbb{N}$ followed by a dense unbounded order.

## Number theory among the aliens: what holds, what breaks

The hypernaturals have primes: call $P$ a **hyperprime** if almost all of its coordinates are ordinary primes. Then the classical theory transfers with remarkable fidelity.

- **Unlimited primes exist.** The germ of the sequence of primes $[\,i \mapsto p_i\,]$ is a hyperprime larger than every standard number.
- **Euclid, sharpened.** Above every hypernatural $H$ there is not merely a hyperprime but a *least* hyperprime — a statement combining pointwise Euclid with the internal least number principle. (Interestingly, the sharp form is *false* for the external world it lives in: the unlimited numbers have no least element at all.)
- **Fermat's little theorem** holds with both base and exponent nonstandard: $P \mid A^P - A$, exponentiation by an infinite exponent included.
- **Wilson's theorem** holds for the internal factorial: $P \mid (P-1)! + 1$ — the residue of an unimaginably long factorial, pinned down exactly.
- **Parity survives:** an unlimited hyperprime is odd.
- **Euclidean division survives, with uniqueness:** for $B \ne 0$ there are unique $Q, R$ with $A = BQ + R$ and $R < B$ — even though the order is not a well-order, which is how one usually proves this. Greatest common divisors behave correctly too, and every hypernatural $> 1$ has a hyperprime divisor.

Then comes the surprise. Since primes are unbounded, one naturally conjectures that they are *distributed* everywhere: that every galaxy contains a hyperprime. That conjecture is **false**, and the counterexample is the classical construction of long prime gaps.

Recall that $i! + 2, i! + 3, \dots, i! + i$ are all composite, since $j \mid i! + j$ for $2 \le j \le i$. This is a run of $i-1$ consecutive composites — and $i-1$ eventually exceeds every fixed standard bound. So place a hypernatural in the *middle* of that run:
$$C = [\,i \mapsto i! + \lfloor i/2 \rfloor\,].$$

> **Prime-Free Galaxy Theorem.** $C$ is unlimited, and no hyperprime lies within a standard distance of $C$: the entire galaxy of $C$ consists of composite hypernaturals. More strongly, the galaxies of $[\,i \mapsto i!\,]$ and $[\,i \mapsto i! + i\,]$ are far apart, and **no galaxy strictly between them carries a hyperprime**. Meanwhile other galaxies — for instance the galaxy of $[\,i \mapsto p_i\,]$ — do contain hyperprimes.

So the prime-carrying galaxies are not merely non-universal; they are not even dense in the galaxy order. There are whole intervals of scales that primes never visit. This is the transferred shadow of a completely classical fact — arbitrarily long prime gaps — but in the nonstandard model it becomes a *structural* statement about the geometry of the number line, not an asymptotic one.

What survives on a coarser scale? The right invariant seems multiplicative rather than additive: Bertrand's postulate places a prime in every interval $(x, 2x)$, and $[x]$ and $[2x]$, while typically in different galaxies, are always within a *bounded power* of each other. The natural conjecture is that every *commensurability class* — the classes of "$H \le K^n$ and $K \le H^n$ for some standard $n$" — contains a hyperprime.

## The payoff: infinite numbers prove finite theorems

None of this would matter much if the alien world were only a curiosity. The reason nonstandard analysis is a working tool is that statements about the ordinary world become *pointwise algebra* about the alien one, and the algebra is often easier.

**Limits become evaluations.** A real sequence $a_n$ extends canonically to alien indices: $a^\ast(H)$ is the germ of $i \mapsto a_{f(i)}$ where $H = [f]$. Then:

> **Robinson's Criterion.** $a_n \to L$ if and only if $a^\ast(H)$ is infinitely close to $L$ — that is, has standard part $L$ — for *every* unlimited index $H$. Similarly $a_n \to +\infty$ if and only if $a^\ast(H)$ exceeds every real number for every unlimited $H$.

The epsilons and the $N$'s are gone; convergence has become a statement about the values of a function at infinite points. As an immediate illustration, $(-1)^n$ diverges because the two unlimited indices $[2i]$ and $[2i+1]$ give values $1$ and $-1$, with different standard parts. No subsequence bookkeeping required.

**Infinitude becomes membership.** A set $S \subseteq \mathbb{N}$ is infinite exactly when its star-extension contains an unlimited element. Since an ultrafilter concentrates on a single value of any map into a finite set, the infinite pigeonhole principle follows in one line: if finitely many sets cover $\mathbb{N}$, then $\omega$ lies in the star-extension of one of them, which is therefore infinite.

**Bolzano–Weierstrass becomes a rounding operation.** Let $a_n$ be a bounded real sequence, $|a_n| \le C$. Its value at the infinite index $\omega$ is a hyperreal squeezed between $-(C+1)$ and $C+1$, hence *finite*, hence infinitely close to a unique real number $L$ — its standard part. That $L$ is automatically a cluster point of the sequence: if the sequence eventually stayed $\varepsilon$-far from $L$, the same would hold at the infinite index, contradicting infinite closeness. Compactness has become the observation that a finite hyperreal can be rounded to a real.

**Compactness becomes a counting argument.** The deepest structural property of the model is *countable saturation*: any countable family of internal sets, every finite subfamily of which has a common element, has a common element outright. The proof is again a diagonal — at coordinate $i$, satisfy as many of the first conditions as that coordinate allows — and it yields a statement with no analogue in $\mathbb{N}$: a decreasing chain of nonempty internal sets always has a common element, whereas in $\mathbb{N}$ the sets $\{k : k \ge n\}$ do not.

## What this teaches us

Three lessons emerge from the tour.

*First, first-order language is weaker than we imagine.* The alien numbers pass every first-order examination and yet are uncountable, non-Archimedean, and stratified into a dense continuum of scales. Whatever pins $\mathbb{N}$ down, it is not the theory of $\mathbb{N}$.

*Second, the internal/external distinction is the real content of "nonstandard."* Every classical theorem we tested survives in its internal form; every failure we found — no least unlimited element, induction breaking on "is standard", no supremum for the standard cut — was external. The model is not a place where arithmetic is false; it is a place where more sets exist than arithmetic can describe, and the extra sets are exactly the ones that see the boundary of infinity.

*Third, the alien world is a computational device for our own.* Limits become evaluations at infinite points; compactness becomes rounding; pigeonhole becomes ultrafilter concentration. The infinite integers are not an escape from rigorous mathematics but a change of coordinates in which some rigorous mathematics becomes easy.

And occasionally the alien world tells us something we would not have thought to ask. That whole intervals of scales are prime-free — that primality is a *galaxy-dependent* property, present at some magnitudes and provably absent at others — is a fact about the ordinary primes, dressed in the geometry of a number line long enough to see it.
