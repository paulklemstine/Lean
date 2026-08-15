# The Birthday Paradox Has a Hard Floor

## How three numbers that add to nothing can betray a secret — and why that trick can never be made fast

### A party trick with primes

Here is a small piece of magic. I am thinking of a number, $N = 143$. It is the product of two primes, and I am not telling you which. You are allowed to pick three whole numbers between $1$ and $12$ — say $2$, $4$ and $5$ — add them up, and hand me the total. If I like your total, I will hand you back one of my secret primes.

Try $2 + 4 + 5 = 11$. Compute the greatest common divisor of $11$ and $143$. It is $11$. That *is* one of my primes; the other is $13$.

Try again: $1 + 3 + 7 = 11$. Same answer. Try $3 + 8 + 10 = 21$: the greatest common divisor of $21$ and $143$ is $1$, and you learn nothing. Try $1 + 9 + 12 = 22$: the greatest common divisor is $11$ again, and you win.

The pattern is not luck, and it is not special to $143$. It is a theorem, and it is the seed from which an entire hierarchy of factoring algorithms grows — a hierarchy that, as we shall see, turns out to be an elaborate illusion.

### The reveal lemma

Suppose $N = pq$ where $p$ and $q$ are distinct primes. Suppose $s$ is a whole number with $0 < s < N$, and suppose $p$ divides $s$. Then
$$\gcd(s, N) = p.$$

That is the whole statement. Let us call it the **reveal lemma**, because a single greatest-common-divisor computation — a handful of nanoseconds, even for numbers hundreds of digits long — turns a fact about divisibility that you *cannot see* into a factor that you *can*.

The proof is three lines. Let $g = \gcd(s, N)$. Since $p$ divides both $s$ and $N$, we know $p$ divides $g$; write $g = pd$. Since $g$ divides $N = pq$, we get that $d$ divides $q$, and since $q$ is prime, $d$ is either $1$ or $q$. If $d = 1$ then $g = p$ and we are done. If $d = q$, then $g = pq = N$, so $N$ divides $s$ — impossible for a positive $s$ smaller than $N$.

That last sentence deserves a moment. Textbook statements of this idea usually carry an extra hypothesis: "provided $q$ does not also divide $s$." It is a natural thing to insist on, because if both primes divided $s$ the greatest common divisor would return the whole of $N$ and tell you nothing. But the hypothesis is **redundant**. If $p$ and $q$ both divided $s$, then $N = pq$ would divide $s$, forcing $s \geq N$ — and we assumed $s < N$. Smallness alone rules the bad case out.

This is exactly why my party trick had no failures. Every triple $a < b < c$ drawn from $\{1, \dots, 12\}$ has $a+b+c \leq 33$, comfortably below $143$. So no triple can be divisible by both $11$ and $13$; the "both" column of the experiment is *structurally* empty, not merely empirically empty. A census over all such triples confirms it: exactly $20$ of them have a sum divisible by $11$ and not by $13$, and exactly $0$ have a sum divisible by both. (The count depends on the range you allow: restrict to $1 \le a<b<c \le 11$ and there are $15$.)

### From a trick to an algorithm

The reveal lemma converts factoring into a *search* problem. To split $N = pq$, you no longer need to guess $p$. You only need to stumble on some quantity, smaller than $N$, that happens to be a multiple of $p$ — without knowing $p$, and without any way to check directly. You just compute the greatest common divisor and see.

How do you stumble on multiples of an invisible prime? With the birthday paradox.

Recall the classical version: in a room of $23$ people, the odds are better than even that two share a birthday, even though there are $365$ days. Collisions arrive far sooner than intuition expects, because the number of *pairs* grows quadratically in the number of people. Now replace "birthday" with "remainder modulo $p$." If you produce more than $p$ different quantities, two of them must leave the same remainder when divided by $p$ — and their difference is a multiple of $p$. Feed that difference into the reveal lemma, and out comes the factor.

This is not a hypothetical scheme. It is the shape of some of the oldest ideas in computational number theory, and it comes in flavours of increasing sophistication:

- **The sumset scheme.** Store $k$ numbers and form all $k^2$ pairwise sums $a + b$. A collision $a + b \equiv c + d \pmod p$ gives the multiple $(a+b) - (c+d)$.
- **The 3SUM scheme.** Store $k$ numbers and form all $k^3$ triple sums $a+b+c$. A collision $a+b+c \equiv d+e+f \pmod p$ does the same job.
- **The $r$-SUM scheme.** More generally, form all $k^r$ sums of $r$-tuples.

And here is where the story becomes seductive. To be *guaranteed* a collision modulo $p$, your search space has to exceed $p$ in size. For the sumset scheme, $k^2 > p$, so you must store about $k \approx p^{1/2}$ numbers. For 3SUM, $k^3 > p$, so you need only $k \approx p^{1/3}$. Push $r$ higher and the exponent drops to $p^{1/4}$, $p^{1/5}$, and on down.

The exponent is improving. Surely, somewhere up that ladder, factoring gets easier?

### The collapse

It does not, and the reason is a theorem so simple it is almost rude.

**The threshold theorem.** Fix a modulus $p \geq 1$ and a finite search space $S$. Then a collision is *guaranteed* — meaning: for every possible assignment of residues in $\{0, 1, \dots, p-1\}$ to the points of $S$, two distinct points of $S$ receive the same residue — **if and only if** $p < |S|$.

One direction is the pigeonhole principle: with more than $p$ objects and only $p$ available residues, two objects must share. The other direction is an adversary argument: if $|S| \leq p$, one can explicitly build an assignment that is injective on $S$, simply by embedding $S$ into the $p$ available residues. Against that assignment, the scheme finds nothing. So the guarantee holds exactly when $|S| \geq p+1$, never sooner.

Read the criterion carefully. It mentions the *cardinality of the search space*, and nothing else. It does not mention the arity $r$. It does not mention how the tuples were built, whether the sums are $2$-fold or $17$-fold, whether the underlying set has clever additive structure. Every member of the hierarchy — sumset, 3SUM, $r$-SUM, and any collision scheme anyone will ever invent — faces exactly the same threshold: **$p + 1$ inspected objects, necessary and sufficient.**

The exponent games were never about work. They were about *storage*. Raising the arity lets you generate a huge search space from a small stored set — that is real, and it is genuinely useful for memory-constrained computation. But the number of tuples you must actually look at is pinned to $p+1$, forever.

Now add the arithmetic fact that makes this fatal. If $N = pq$ with $q \leq p$, then $p \geq \sqrt{N}$: the larger prime factor of a semiprime is at least the square root. (Indeed $N = pq \le p\cdot p$, so $\sqrt N \le p$.) Combining, we get:

**The barrier.** Any collision scheme guaranteed to produce a collision modulo the larger factor $p$ of $N = pq$ must inspect more than $\sqrt{N}$ objects. In the $r$-SUM case: whatever the arity, $k^r > \sqrt{N}$.

For a $2048$-bit RSA modulus, $\sqrt{N}$ is around $10^{308}$. It does not matter that the 3SUM scheme stores only $10^{205}$ elements instead of $10^{308}$: it still has to *look at* $10^{308}$ triples. The improvement is entirely cosmetic.

A concrete instance makes the shape of the illusion vivid. Take $p = 997$. A sumset scheme needs $k \geq 32$ stored elements (since $31^2 = 961 \le 997 < 1024 = 32^2$). A 3SUM scheme needs only $k \geq 10$ (since $9^3 = 729 \le 997 < 1000 = 10^3$). Storage has fallen by more than a factor of three — a real, measurable improvement, exactly the promised $p^{1/2} \to p^{1/3}$. And yet: $32^2 = 1024$ and $10^3 = 1000$. Both schemes inspect a bit over a thousand objects. The work is identical to within $2\%$.

### Two further walls

The threshold theorem is a *counting* obstruction: it says you must look at many things. Remarkably, two entirely independent obstructions block the same road, and neither has anything to do with counting.

**The amplitude barrier.** Suppose your building blocks are drawn from a set $A$ contained in $\{1, \dots, M\}$. Then every $r$-tuple sum lies between $r$ and $rM$, so there are at most $rM + 1$ *distinct* sums available — no matter that there are $|A|^r$ tuples. Now suppose $rM < p$. Then two tuple sums congruent modulo $p$ must be *equal as integers*, because two distinct numbers congruent mod $p$ differ by at least $p$, and no two of our sums are that far apart. Every collision you find is trivial: the difference is $0$, the greatest common divisor step returns $N$, and you learn nothing.

The consequence is stark. A collision scheme with small entries cannot factor *at all*, however many tuples it inspects. To have any hope you need $p \leq rM$, so your numbers themselves must be of size at least $p/r$ — again of order $\sqrt{N}$. And note what the bound depends on: only the interval containing $A$. Not on $A$'s additive structure. Sidon sets, geometric progressions, smooth numbers, cleverness of every kind — none of it moves the wall, because the wall was never about structure.

**The span barrier.** Strip away every detail of how a scheme works and keep only this: it has a finite collection of search points, it attaches a whole number to each, and it extracts factors by taking greatest common divisors of differences of those numbers with $N$. Then: *if such a scheme reveals a factor $f$ of $N$, two of its values differ by at least $f$.* The proof is one line — the revealed factor divides the positive difference, so it is at most the difference. For $f = p \ge \sqrt N$, this says any scheme that factors a semiprime must manipulate numbers spanning a range of at least $\sqrt{N}$. Equivalently: a scheme all of whose values lie below $\sqrt{N}$ can never reveal the larger factor. This is not about how many operations you do; it is about the *arithmetic size of the objects you touch*.

The span barrier has a pleasant corollary about a more exotic member of the hierarchy. Some schemes evaluate a function whose values are constrained to a structured subset $B$ of the residues — think of an evaluation indexed by a class group, so that $|B| \approx p/h$ for a class number $h$. Such a scheme does beat the counting threshold: collisions appear after only $|B| + 1$ evaluations, a factor of $h$ sooner, because the general form of the threshold theorem is that the collision count is set by the size of the *value set*, whatever it may be. But the span barrier is untouched. Structure can compress the number of evaluations; it cannot shrink the numbers themselves.

**The coverage barrier.** One last wall, of a completely different character. It answers the question: could a *single, fixed* scheme be secretly universal — a magic table of numbers that factors everything? No. If the scheme has $k$ search points and all its values are below $B$, then it has at most $k^2$ pairwise differences, and each difference, being a positive integer below $B$, has at most $\log_P B$ distinct prime divisors that are $\geq P$ (because $s$ such primes multiply to something $\geq P^s$, which must divide the difference). So the total number of large primes the scheme can ever expose is at most
$$\log_P(B) \cdot k^2.$$
A scheme required to crack $T$ different semiprimes with larger factor $\geq P$ therefore needs $k^2 \geq T / \log_P B$. The arity games change how $k$ relates to the tuple count; they do not touch this counting bound at all.

### What is actually true

It would be easy to read all this as pure negation, so let us state the positive result, which is genuine and sharp.

**Collision factoring works, once both barriers are cleared.** Let $N = pq$ with $p, q$ prime. Let $A$ be a set of positive integers bounded by $M$, with $rM < N$, and suppose the set of $r$-tuple sums over $A$ contains more than $p$ distinct values. Then there exist two achieved sums $t < s$ with
$$\gcd(s - t, N) = p.$$
The method succeeds, provably, and outputs the factor. Its cost, equally provably, is $\Omega(\sqrt N)$ in tuples inspected *and* $\Omega(\sqrt N)$ in the size of the integers manipulated. Both prices must be paid; neither can be negotiated down by increasing the arity.

### Why this is worth knowing

There is a real connection here between two problems that live in different neighbourhoods of theoretical computer science. **3SUM** — given a list of numbers, are there three summing to zero? — is one of the canonical "fine-grained complexity" problems, a fixed point around which a whole web of conditional lower bounds is organised. **Factoring** is the canonical hard problem of public-key cryptography. The reveal lemma says that a 3SUM instance taken modulo a hidden prime factor is, quite literally, a factoring oracle: solve it and the prime falls out of a greatest common divisor.

That is a bridge. What the birthday-bound hierarchy then tells us is exactly how much traffic the bridge will bear. The naive hope — that pushing arity upward converts a $\sqrt{N}$ algorithm into an $N^{1/3}$ algorithm — is refuted by a pigeonhole argument and its adversarial converse. And the refutation is robust in a way that specific algorithm analyses rarely are: the threshold theorem is an *if and only if*, so it is not an artefact of a particular proof technique or a particular scheme. Anything that waits for a repeated residue is bound by it.

There is a broader lesson in the shape of the argument. In algorithm design one often improves an exponent and declares victory. But an exponent is a measurement of *one* resource, and a method has several. Here the arity ladder genuinely improves storage — from $p^{1/2}$ down to $p^{1/3}$ and beyond — while leaving work, amplitude, and coverage all frozen at $\sqrt{N}$. Three independent barriers, three different reasons, one number. The barrier is not an accident of how we counted; it is where the mathematics actually lives.

Modern factoring records are set by methods — sieves — that are not collision searches at all, and they run in time far below $\sqrt{N}$. That is not a contradiction; it is the point. The birthday paradox is a beautiful and powerful engine, but it is bolted to the floor. To go faster you must get off it entirely.

And still, there is something delightful about the fact that we began with three small numbers adding to $11$, and ended with a proof about the limits of an entire family of algorithms. The trick was real. The magic, as usual, was a theorem in disguise.
