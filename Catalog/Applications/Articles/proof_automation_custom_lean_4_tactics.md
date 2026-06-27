# Three Little Robots That Prove Theorems

## The art of teaching a machine to be lazy in the right way

Every working mathematician keeps a mental toolbox of moves so routine they
barely register as thinking. "That follows by checking the cases." "That's
just the triangle inequality." "Reduce it mod $p$ and the rest is bookkeeping."
These reflexes are the connective tissue of real proofs — the unglamorous steps
between the ideas that actually matter.

What if you could bottle those reflexes? What if, instead of writing out the
same boring case-check for the hundredth time, you could hand the boring part to
a small, trustworthy assistant and spend your energy on the part that's genuinely
hard?

That is the idea behind a *proof tactic*: a reusable piece of automation that
recognizes a common pattern and dispatches it. This article is about three such
assistants — three "little robots," each specialized for one corner of
mathematics — and about the surprisingly subtle question that hangs over all of
them: **how do you know a robot that proves theorems isn't lying to you?**

The three robots are:

- **`tropical_simp`**, which simplifies expressions in a strange arithmetic
  where "plus" means "take the minimum";
- **`number_theory_decide`**, which closes out the finite, grind-it-out steps
  that lurk inside number-theoretic arguments; and
- **`spectral_bound`**, which estimates how large the eigenvalues of a matrix
  can get.

Each one is small. Each one is *sound* — meaning it provably cannot certify a
false statement. And each one, it turns out, is most powerful not when it works
alone, but when it teams up with a genuine mathematical idea that it could never
discover on its own. That partnership — automation handling the routine,
insight handling the rest — is the real story.

---

## Robot #1: `tropical_simp`, the minimum-plus simplifier

Start with a thought experiment. Take ordinary arithmetic and play a little
game of substitution. Wherever you'd normally write "$+$" (addition), instead
write "take the smaller of the two." And wherever you'd normally write
"$\times$" (multiplication), instead write ordinary "$+$." This bizarre-looking
swap defines the **min-plus**, or **tropical**, semiring. Its addition is
$a \oplus b = \min(a, b)$, and its multiplication is $a \odot b = a + b$.

It sounds like a joke, but tropical arithmetic is a serious and useful object.
It shows up wherever you care about *shortest paths*, *cheapest routes*, or
*critical bottlenecks*: the cost of a journey is the sum of the legs (tropical
multiplication), and the best journey is the minimum over all options (tropical
addition). Scheduling, network routing, dynamic programming, and even parts of
algebraic geometry all speak this dialect.

Now, the whole point of arithmetic is that the usual laws hold. In tropical
land, the analogue of the distributive law $a(b+c) = ab + ac$ becomes a clean,
provable fact about real numbers:

$$a + \min(b, c) = \min(a + b,\ a + c).$$

Read it slowly: adding a fixed cost $a$ to "the cheaper of $b$ and $c$" gives the
same answer as "the cheaper of ($a$ plus $b$) and ($a$ plus $c$)." Of course it
does — adding a constant to both options doesn't change which one is smaller.
There's a mirror-image version too,

$$\min(a, b) + c = \min(a + c,\ b + c),$$

and both are genuinely true, not by convention but by a two-line case split on
whether $b \le c$.

The robot `tropical_simp` is built **only** out of facts like these — proven
equalities of real numbers — together with the obvious shuffling rules: that
$\min$ doesn't care about order ($\min(a,b) = \min(b,a)$), that it can be
re-bracketed freely, and that $\min(a, a) = a$. Because every rule it knows is a
theorem, the robot is *sound by construction*: anything it simplifies away is
genuinely equal to what it started with. It cannot accidentally "prove" a false
tropical identity, because it has no false rule to apply.

So `tropical_simp` will instantly verify chains like

$$a + \min(\min(b, c), d) = \min(a + b,\ \min(a + c,\ a + d)),$$

pushing a shared cost into a nested minimum, and it will recognize re-ordered
versions of the same identity even when the terms are scrambled.

But here's where the story gets interesting — and honest. A simplifier that
only knows finitely many rewrite rules can handle expressions of *fixed* shape,
but mathematics loves the word "for all." What about distributing a cost over a
sum of arbitrary length — a route with not two or three legs, but $n$ of them?

That requires a genuine theorem, proved by induction, that no finite bag of
rewrite rules can replace. Call it the **scalar fold law**. Model a tropical
sum as a running minimum over a list of values $[a_1, a_2, \dots, a_k]$ — fold
$\min$ across the list, ending at a base value $d$. The theorem says: adding a
constant $c$ to the whole tropical sum equals adding $c$ to every single term
first:

$$c + \min(a_1, a_2, \dots, a_k, d) = \min(c + a_1,\ c + a_2,\ \dots,\ c + a_k,\ c + d).$$

This is the closed-form guarantee that the robot's one-step instinct scales up
correctly to sums of any size. The robot performs the rewrite one step at a
time; the induction certifies that doing so forever lands in the right place.
The lesson is already visible: **the automation handles each step; a human-style
proof certifies the whole.**

There's a charming epilogue. Some people prefer the *max-plus* convention,
where tropical addition is $\max$ instead of $\min$. The two worlds are mirror
images, swapped by negation: $\min(a, b) = -\max(-a, -b)$. Using exactly this
reflection, the min-plus distributive law can be derived *from* its max-plus
twin — a small bridge showing the two dialects are one language seen in a mirror.

---

## Robot #2: `number_theory_decide`, the finite-case closer

Number theory has a personality split. Its theorems are often about *all*
integers — infinitely many — yet their proofs frequently collapse to checking a
*finite* handful of cases. "Every prime bigger than 3 is $1$ or $5$ modulo $6$."
"This recurrence repeats with some period." The infinite claim is the headline;
a finite check is the engine room.

The robot `number_theory_decide` is that engine room, packaged. It is, quite
literally, a disjunction of trustworthy primitive tactics: try straightforward
linear-arithmetic reasoning; if that fails, try direct computation; if that
fails, try the numeric normalizer; if that fails, split into cases and compute
each. Every branch is individually sound, so the combination is sound: it can
only ever close a finite goal that is *actually true*.

What can it knock out cold? Genuinely useful finite facts. That $561$ is **not**
prime — it's $3 \times 11 \times 17$, the smallest of the eerie *Carmichael
numbers* that masquerade as primes in Fermat's test. That $17$ *is* prime. That
$561$ and $560$ share no common factor. And the curious divisibility data
$(3-1) \mid 560$, $(11-1) \mid 560$, $(17-1) \mid 560$ — which is no accident,
but **Korselt's criterion**, the exact fingerprint that makes $561$ a Carmichael
number in the first place. The robot dispatches all of these without a murmur.

But, exactly as with the tropical simplifier, the robot's true value appears only
when it's paired with a real idea. Three classic patterns show it off.

**Pattern one: induction with a finite base.** Consider the claim that
$n^2 < 2^n$ for every $n \ge 5$ — exponential growth eventually crushes
quadratic growth. The proof is by induction. The inductive *step* — showing
that if it holds at $k$ it holds at $k+1$ — is real algebra, an honest
inequality estimate; no robot can guess it. But the *base case*, checking the
claim at $n = 5$ and confirming the small values below it behave, is a finite
computation. The robot owns the base; the human owns the step.

**Pattern two: reduce modulo $p$, then compute.** Fermat's Little Theorem says
that for a prime $p$, the integer $n^p - n$ is always divisible by $p$ — for
*every* integer $n$, of which there are infinitely many. The decisive move is a
change of scenery: instead of working with all integers, work in the finite
world of remainders modulo $p$, where there are only $p$ values to consider.
In that finite world, the statement becomes "$x^p = x$ for every one of the $p$
residues" — and *that* the robot checks by brute force. For $p = 5$ it checks
five values; for $p = 7$, seven. The reduction from "all integers" to "five
residues" is the insight; the five-way check is the robot. The same trick even
works for the composite modulus $6$, proving $6 \mid n^3 - n$ for every integer
$n$ by checking six residues.

**Pattern three: periodicity from two seeds.** Here is the most beautiful
example. The Fibonacci numbers $1, 1, 2, 3, 5, 8, 13, 21, \dots$ are famous for
never repeating — they march off to infinity. But look at them through the lens
of remainders, say modulo $2$: their pattern of even-and-odd is
$1, 1, 0, 1, 1, 0, \dots$, repeating with period $3$ forever. Modulo $3$, the
remainders cycle with period $8$. This phenomenon — that the Fibonacci sequence
is *eventually periodic modulo any number* — is named the **Pisano period**,
after Leonardo of Pisa (Fibonacci himself).

Why does it happen, and how short is the cycle? The clean statement is this: if
you can find some position $p$ where the Fibonacci number $F_p$ leaves remainder
$0$ and the next one $F_{p+1}$ leaves remainder $1$ (modulo $m$), then the whole
sequence repeats with period $p$:

$$F_{n+p} \equiv F_n \pmod{m} \quad\text{for every } n.$$

The proof is a small gem. A *single*-variable induction won't work, because the
Fibonacci rule $F_{n+2} = F_{n+1} + F_n$ couples each term to its neighbor —
to advance one step you need to know about two. So you run a **paired
induction**, carrying *two* facts forward in lockstep:

$$F_{n+p} \equiv F_n \quad\text{and}\quad F_{n+p+1} \equiv F_{n+1} \pmod{m}.$$

Knowing both at stage $n$, the recurrence lets you push both to stage $n+1$, and
the chain never breaks. This "two-track" trick — keeping a paired invariant so
the recurrence has everything it needs — is the genuine mathematical content,
and no decision procedure could have invented it.

And the robot? The robot's job is to verify the two *seeds*. To prove the
period-$3$ fact modulo $2$, someone has to check that $F_3 \equiv 0$ and
$F_4 \equiv 1$. To get period $8$ modulo $3$, check $F_8 = 21 \equiv 0$ and
$F_9 = 34 \equiv 1$. Those are exactly the finite computations
`number_theory_decide` exists to do. The structural theorem provides the
machine; the robot provides the fuel. Together they manufacture infinitely many
true statements from two tiny checks.

There's even a bridge to a classical jewel. **Cassini's identity** states that
for Fibonacci numbers,

$$F_{n+2}\, F_n - F_{n+1}^2 = (-1)^{n+1},$$

a perfect, alternating $\pm 1$ that never decays. Read modulo any $m$, it stays
true, and a concrete instance — say modulo $5$ at $n = 4$, where
$F_6 \cdot F_4 - F_5^2 = 8 \cdot 3 - 25 = -1$ — falls instantly to the robot.

---

## Robot #3: `spectral_bound`, the eigenvalue estimator

The third robot lives in linear algebra, and it answers a question that
engineers, physicists, and data scientists ask constantly: **how big can the
eigenvalues of a matrix get?**

Eigenvalues are the secret growth rates hidden inside a matrix. If a system
evolves by repeatedly multiplying a state vector by a matrix $M$, then the
eigenvalues of $M$ decide whether the system explodes, decays, or settles. An
eigenvalue is a number $\lambda$ for which there's a nonzero vector $v$ — the
eigenvector — with

$$M v = \lambda v.$$

Multiplying by $M$ just stretches $v$ by the factor $\lambda$. Knowing the
eigenvalues are all small (in magnitude) is often exactly what you need to
guarantee a system is stable, an iteration converges, or a model is well-behaved.

Computing eigenvalues exactly can be painful. But *bounding* them is
surprisingly easy, thanks to a classical idea associated with the
**Gershgorin** circle theorem. The robot `spectral_bound` packages a clean,
self-contained version of that bound, which we can state precisely.

Suppose every **absolute row sum** of $M$ is at most some number $B$ — that is,
for each row $i$,

$$\sum_j |M_{ij}| \le B.$$

Then **every** eigenvalue $\lambda$ of $M$ satisfies

$$|\lambda| \le B.$$

In words: a matrix can't stretch by more than its biggest row can account for.
The proof is a small masterpiece of "look at the extreme case." Take an
eigenvector $v$ and find the coordinate $v_i$ that is largest in absolute value.
Because $v$ is nonzero, that biggest coordinate is genuinely positive — and this
is exactly where the assumption $v \neq 0$ earns its keep; a fake "zero
eigenvector" would let *any* number masquerade as an eigenvalue. Now write down
the $i$-th line of the equation $Mv = \lambda v$:

$$\lambda v_i = \sum_j M_{ij} v_j.$$

Take absolute values, apply the triangle inequality, and use that every $|v_j|$
is no bigger than $|v_i|$:

$$|\lambda|\,|v_i| = \left|\sum_j M_{ij} v_j\right| \le \sum_j |M_{ij}|\,|v_j| \le \left(\sum_j |M_{ij}|\right)|v_i| \le B\,|v_i|.$$

Divide through by the positive number $|v_i|$, and out pops $|\lambda| \le B$.
That's the entire soundness certificate behind the robot.

Concretely, take the matrix

$$M = \begin{pmatrix} 1 & 2 \\ 0 & 3 \end{pmatrix}.$$

Its row sums of absolute values are $|1| + |2| = 3$ and $|0| + |3| = 3$, both at
most $3$. So the robot certifies that every eigenvalue has magnitude at most $3$
— and indeed the true eigenvalues are $1$ and $3$, comfortably inside. For a
*real* eigenvalue the bound immediately becomes a two-sided trap,
$-B \le \lambda \le B$, which is precisely the form a stability or convergence
argument wants to consume downstream.

The robot is candid about its limits, too. This is the *weak* Gershgorin bound —
a single disc that captures all eigenvalues, rather than the sharper picture of
one disc per row. It trades a little precision for a lot of reusability, which
is exactly the right trade for an automated assistant.

---

## The moral: trustworthy laziness

Step back and the three robots tell one story. Each is deliberately small. Each
is *sound* — incapable, by its very construction, of certifying a falsehood:
the tropical simplifier only ever applies proven equalities; the number-theory
closer only ever runs sound decision procedures; the eigenvalue estimator only
ever invokes a fully proved bound. And crucially, each reaches its full power
only in partnership with a genuine idea it cannot generate on its own — the
inductive scalar-fold law, the reduce-mod-$p$ and paired-Pisano arguments, the
extremal-coordinate trick behind Gershgorin.

This is what good automation looks like in mathematics, and increasingly in
software, science, and engineering broadly. The goal is not a single oracle that
"does everything." It is a *division of labor*: let the machine be reliably,
verifiably lazy about the routine, so the human can be creative about what's
hard. The robots don't replace the mathematician. They clear the underbrush, so
the real climbing can begin.

And because each robot is sound by construction, you never have to wonder whether
it's bluffing. When one of these little machines says a thing is true, it is —
not because it's clever, but because it is, in the most literal sense, incapable
of saying otherwise.
