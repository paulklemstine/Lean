# The Hidden Order in Number Sequences: One Law to Rule Their Divisibility

## A puzzle that's older than it looks

Write down the Fibonacci numbers, the sequence everyone meets in school:

```
1, 1, 2, 3, 5, 8, 13, 21, 34, 55, 89, 144, 233, 377, 610, ...
```

Now ask a simple-sounding question: *which* Fibonacci numbers are even? Look closely and a rhythm appears — 2, 8, 34, 144, 610 — every **third** one, like clockwork. Which are divisible by 5? They are 5, 55, 610, 6765 — every **fifth** one. Which are divisible by 8? Every sixth. By 13? Every seventh.

There is no exception, no drift, no eventual breakdown. Each number you might want to divide by carves the Fibonacci sequence into a perfectly periodic comb of "hits," and the spacing of the teeth depends only on that divisor. This regularity is so clean it almost feels like cheating. Where does it come from?

The standard explanation reaches for the famous recurrence $F_{n+2} = F_{n+1} + F_n$ and grinds through induction. But that explanation hides the real reason, and worse, it makes the phenomenon look like a special quirk of the Fibonacci numbers. It is not. The same astonishing regularity governs a whole zoo of sequences — Mersenne-type numbers $2^n - 1$, the so-called Lucas sequences, and many more — and they share it for a single, beautifully compact reason. This article is about that reason, and about a recent effort to nail it down with complete, machine-checked rigor.

## The one identity that explains everything

Here is the secret. For the Fibonacci numbers, the greatest common divisor (gcd) of two terms equals the term sitting at the gcd of their positions:

$$\gcd(F_m, F_n) = F_{\gcd(m,n)}.$$

Read that slowly, because it is doing something remarkable. On the left we take the gcd of two **values** in the sequence. On the right we take the gcd of their two **indices** — their positions — and then look up that single value. The identity says these two operations agree. Divisibility among the values is a faithful mirror of divisibility among the positions.

For example, $F_{12} = 144$ and $F_{18} = 2584$. Their gcd is $8$. And $\gcd(12, 18) = 6$, with $F_6 = 8$. They match. Try any pair you like; it always works.

A sequence with this property has a name: a **strong divisibility sequence**. The definition is exactly the identity above, written for a general sequence $u$ instead of $F$:

> A sequence $u(0), u(1), u(2), \dots$ of whole numbers is a **strong divisibility sequence** if
> $$u(\gcd(m,n)) = \gcd(u(m), u(n)) \quad \text{for all } m, n.$$

That single line, it turns out, is the entire engine. Every regularity we noticed at the start — the periodic combs, the clockwork spacing — is a logical consequence of it. Nothing about the Fibonacci recurrence is needed. The recurrence is how you *build* the sequence; the strong divisibility law is what makes its divisibility behave.

## From one law, a cascade of consequences

Once you adopt the strong divisibility law as your starting point, the rest of the theory tumbles out in a satisfying chain. Let me walk through the highlights in plain language; precise statements follow.

**Divisibility of positions forces divisibility of values.** If $m$ divides $n$, then $u(m)$ divides $u(n)$. (For Fibonacci: $F_6 = 8$ divides $F_{12} = 144$.) This is the "weak" divisibility law, and it falls out of the strong law in one line: if $m \mid n$ then $\gcd(m,n) = m$, so $u(m) = u(\gcd(m,n)) = \gcd(u(m), u(n))$, which certainly divides $u(n)$.

**A sharp "meet" law.** For *any* candidate divisor $d$ whatsoever,
$$d \mid u(\gcd(m,n)) \iff d \mid u(m) \text{ and } d \mid u(n).$$
In words: a number divides the term at the gcd-position exactly when it divides both original terms. This is the precise sense in which the sequence translates the lattice of positions into the lattice of values.

**Primitive divisors are unique landmarks.** Call a number $p$ a *primitive divisor* of $u(n)$ if $p$ divides $u(n)$ but divides none of the earlier terms $u(1), \dots, u(n-1)$. Primitive divisors are the "first appearances." A wonderful rigidity holds: a given $p$ can be a primitive divisor of **at most one** term in the whole sequence. Once a divisor makes its debut, it never gets a second premiere.

**A primitive divisor pins down its entire shadow.** If $p$ is a primitive divisor of $u(n)$, then for *every* index $m$,
$$p \mid u(m) \iff n \mid m.$$
This is the law that produced all those periodic combs at the start. The divisor $p$ first appears at position $n$, and from then on it reappears at exactly the multiples of $n$ — never anywhere else. The spacing of the teeth is $n$, full stop. This is classically called the **law of apparition**, and here it is derived purely from the strong divisibility law.

**Two divisors interleave by least common multiple.** Suppose $p$ first appears at position $a$ and $q$ first appears at position $b$. When do they appear *together*? Exactly at the multiples of $\operatorname{lcm}(a,b)$:
$$\big(p \mid u(n) \text{ and } q \mid u(n)\big) \iff \operatorname{lcm}(a,b) \mid n.$$
Two periodic combs overlap on a coarser comb whose spacing is their lcm — the same rule that governs when two gears' teeth line up. And this generalizes cleanly to any finite collection of divisors at once.

**Exact density of appearances.** Because the appearances of a primitive divisor of index $n$ are precisely the multiples of $n$, you can simply *count* them. Among the first $N$ positions, the number of appearances is exactly $\lfloor N/n \rfloor$. So a primitive divisor of index $n$ shows up with density precisely $1/n$. For two divisors at once, the joint density is $1/\operatorname{lcm}(a,b)$. The qualitative "clockwork" becomes a sharp quantitative count.

## Why this is more than a Fibonacci story

Here is the punchline that makes the whole exercise worthwhile. Nowhere in any of the arguments above did we use the Fibonacci recurrence. We used only two things: the strong divisibility identity, and the fact that primitive divisors are "first appearances." That means **every** sequence obeying the strong divisibility law inherits the *entire* theory for free.

Two concrete examples make this vivid.

**The Fibonacci numbers themselves.** The identity $\gcd(F_m, F_n) = F_{\gcd(m,n)}$ is a classical theorem, so the Fibonacci sequence is a strong divisibility sequence, and every result above applies. This recovers the school-room observations we started with — now as theorems rather than coincidences.

**The Mersenne-type numbers $u(n) = a^n - 1$.** Fix any base $a$ (think $a = 2$, giving $1, 3, 7, 15, 31, 63, \dots$). A classical identity says
$$\gcd(a^m - 1, a^n - 1) = a^{\gcd(m,n)} - 1,$$
which is *exactly* the strong divisibility law. So the numbers $2^n - 1$ — the hunting ground for Mersenne primes — carry the same apparition theory, the same uniqueness of primitive divisors, the same lcm-interleaving and the same densities. The proofs are not adapted or re-run; they are *literally the same theorems*, instantiated at a different sequence.

This is the quiet power of finding the right abstraction. A fact that looked like a fingerprint of the Fibonacci numbers turns out to be a property of a whole species, and recognizing the species lets one argument do the work of many.

## The results, stated precisely

For the reader who wants the exact claims, here is the full list, phrased for an arbitrary sequence $u : \mathbb{N} \to \mathbb{N}$. Throughout, "strong divisibility sequence" means $u(\gcd(m,n)) = \gcd(u(m), u(n))$ for all $m, n$, and "$p$ is a primitive divisor of $u(n)$" means $p \mid u(n)$ and $p \nmid u(k)$ for all $k$ with $0 < k < n$.

1. **Weak divisibility.** If $m \mid n$ then $u(m) \mid u(n)$.
2. **Meet law.** For all $d, m, n$: $\;d \mid u(\gcd(m,n)) \iff d \mid u(m) \text{ and } d \mid u(n)$.
3. **Uniqueness of primitive divisors.** If $p$ is a primitive divisor of both $u(m)$ and $u(n)$ with $m, n > 0$, then $m = n$. (This one needs no strong divisibility hypothesis at all — it is pure rigidity of the "first appearance" definition.)
4. **Law of apparition.** If $p$ is a primitive divisor of $u(n)$ with $n > 0$, then for all $m$: $\;p \mid u(m) \iff n \mid m$.
5. **Join law (two divisors).** If $p$ is primitive for $u(a)$ and $q$ for $u(b)$, with $a, b > 0$, then $\;\big(p \mid u(n) \wedge q \mid u(n)\big) \iff \operatorname{lcm}(a,b) \mid n$.
6. **Join law (finite family).** For a finite family of primitive divisors $f(i)$ of $u(g(i))$ with each $g(i) > 0$, all $f(i)$ divide $u(n)$ simultaneously iff $\operatorname{lcm}_i\, g(i) \mid n$.
7. **Counting.** Among the first $N$ indices, the number of $e$ with $p \mid u(e+1)$ is exactly $\lfloor N/n \rfloor$; the joint count for two divisors is $\lfloor N/\operatorname{lcm}(a,b)\rfloor$.
8. **Instances.** $\,u = F$ (Fibonacci) and $u(n) = a^n - 1$ (Mersenne-type) are strong divisibility sequences, so 1–7 apply to both.

## Why bother proving what "everyone knows"?

A skeptic might shrug: number theorists have known these facts for over a century. True. But there is a difference between *believing* a chain of reasoning and *certifying* it. The results above were not merely written down; they were formalized and verified in complete logical detail, with no gaps, by a proof-checking system that accepts an argument only when every last inference is justified.

That process did more than rubber-stamp the textbook. It clarified exactly which hypotheses each result truly requires. The classical "law of apparition" is often stated only for prime divisors. The formalization revealed that primality is irrelevant — the law holds for *any* divisor that has a first appearance, because the only ingredients are the meet law and the minimality of the first appearance. Stripping away an unnecessary hypothesis is a small thing, but it is the kind of clarity you only reliably get when a machine refuses to let you wave your hands.

It also drew sharp boundaries. The pretty statement "$u(m) \mid u(n) \iff m \mid n$" is, for the Fibonacci numbers, *false* at the very start: $F_1 = F_2 = 1$ divides everything, so positions 1 and 2 misbehave. The honest theorems are the ones above, which sidestep that degeneracy by working with primitive divisors and positivity. Formalization forces you to confront such edge cases rather than gloss over them.

## The bigger lesson

Mathematics is full of moments where a tangle of special cases suddenly resolves into a single clean principle, and the special cases become mere instances. The strong divisibility law is a small, perfect example. It takes a grab-bag of facts about Fibonacci numbers — their evens, their multiples of five, their primitive divisors, their periodic appearances — and reveals them all as shadows of one identity, an identity shared by Mersenne numbers and a whole family of cousins.

The next time you watch the even Fibonacci numbers march by in perfect lockstep, every third one without fail, you can know exactly why. It is not the recurrence. It is not luck. It is that the Fibonacci sequence translates the arithmetic of *positions* into the arithmetic of *values* without distortion — and once a sequence does that, all the order you could ask for comes along for free.
