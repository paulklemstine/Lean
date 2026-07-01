# When the Shape of a Question Doesn't Matter: Sign Changes over Sums of Squares

## A number theorist's favorite kind of surprise

Some of the most satisfying moments in mathematics arrive when a question that looked like it needed a hundred separate answers turns out to need only one. You expect a long, case-by-case grind, and instead a single structural observation sweeps the entire problem away. This article is about one such moment, in a corner of number theory where deep analytic machinery meets a childishly simple counting idea about squares.

The story revolves around a phenomenon called *sign changes*. Many of the most important sequences in number theory are lists of real numbers — some positive, some negative — attached to the whole numbers $1, 2, 3, \dots$. A natural and surprisingly stubborn question is: **does the sequence keep flipping sign forever, or does it eventually settle down and stay positive (or stay negative)?** For the sequences we care about here, the answer is that they flip forever. And the surprise is that this remains true even when you are only allowed to *look* at the sequence on a very restricted set of positions.

## The sequences: fingerprints of modular forms

The sequences at the heart of this story come from *modular forms*. A modular form is an extraordinarily symmetric function on the upper half of the complex plane, and it is one of the central objects of modern number theory — modular forms are the machines behind Fermat's Last Theorem, behind the theory of elliptic curves, and behind much of the Langlands program.

Each such form (more precisely, each *normalized Hecke eigenform* of even weight $k \ge 2$) comes with a sequence of numbers that acts like its arithmetic fingerprint. From this one form you can build an entire tower of related sequences, the *symmetric power* coefficients, written $\lambda_{\mathrm{sym}^j f}(n)$ for $j = 1, 2, 3, \dots$. Here $f$ is the modular form, $j$ picks out which "power" in the tower we are looking at, and $n$ runs over the positive integers. Each $\lambda_{\mathrm{sym}^j f}(n)$ is a real number, and the sign of that number encodes subtle arithmetic information. These are exactly the coefficients that appear when one writes the symmetric power $L$-functions as Dirichlet series, and understanding their signs is a recurring theme in analytic number theory.

The one fact we need about them is qualitative: for every choice of $f$ and every power $j$, the full sequence $\lambda_{\mathrm{sym}^j f}(n)$ changes sign infinitely often as $n$ runs over *all* the whole numbers. It is never eventually one-signed.

## The twist: only look at sums of squares

Here is where the problem becomes interesting. Instead of watching the sequence at every position $n$, suppose you are only permitted to read it at positions that are **sums of $m$ squares**.

A number is a *sum of $m$ squares* if you can write it as
$$n = x_1^2 + x_2^2 + \cdots + x_m^2$$
for some whole numbers $x_1, \dots, x_m$ (zeros are allowed). For example, $5 = 1^2 + 2^2$ is a sum of two squares; $6 = 1^2 + 1^2 + 2^2$ is a sum of three squares but *not* a sum of two; and $7$ is famously not a sum of three squares at all.

So the question becomes: if you only ever look at the sequence at the sum-of-$m$-squares positions, do you still see it flip sign infinitely often? Concretely, are both of the sets
$$\{\, n : n \text{ is a sum of } m \text{ squares and } \lambda_{\mathrm{sym}^j f}(n) > 0 \,\}$$
$$\{\, n : n \text{ is a sum of } m \text{ squares and } \lambda_{\mathrm{sym}^j f}(n) < 0 \,\}$$
infinite?

The existing literature answered "yes," but only for the values $m = 2, 3, 4, \dots, 12$ — a finite range, worked out with genuine effort. The natural conjecture was that the answer stays "yes" for every even $m$, and the goal here was to prove exactly that: **for all even $m \ge 2$, the symmetric power coefficients change sign infinitely often over sums of $m$ squares.**

## The idea that dissolves the problem

The heart of the matter is embarrassingly simple once you see it, and it has nothing to do with modular forms at all. It is about the *shape* of the sets of sums of squares.

**Observation 1: the sets are nested.** Every sum of two squares is automatically a sum of three squares, and a sum of four, and so on. Why? Because you can always pad with zeros:
$$5 = 1^2 + 2^2 = 1^2 + 2^2 + 0^2 = 1^2 + 2^2 + 0^2 + 0^2.$$
If we write $S_m$ for the set of numbers that are sums of $m$ squares, this padding argument gives a clean chain of inclusions,
$$S_2 \subseteq S_3 \subseteq S_4 \subseteq S_5 \subseteq \cdots$$
The bigger $m$ is, the more numbers you are allowed to look at.

**Observation 2: the chain stops growing almost immediately.** This is the punchline, and it rests on a classical gem, **Lagrange's four-square theorem** from 1770: *every* whole number is a sum of four squares. There are no exceptions — $7 = 2^2 + 1^2 + 1^2 + 1^2$, $23 = 3^2 + 3^2 + 2^2 + 1^2$, and so on forever. Combined with the padding observation, this means that from $m = 4$ onward the "restricted" set is not restricted at all:
$$S_m = \{\text{all whole numbers}\} \qquad \text{for every } m \ge 4.$$

Put the two observations side by side and the whole landscape snaps into focus. The sampling sets grow, but they saturate: $S_2$ is genuinely sparse, $S_3$ is slightly less sparse (it misses exactly the numbers of the form $8k+7$, by Legendre's three-square theorem), and then $S_4, S_5, S_6, \dots$ are all just the entire number line. There is only **one genuinely hard case**, and it is the smallest one, $m = 2$.

## From structure to sign changes

Now watch how these two elementary facts demolish the sign-change problem.

Because $S_2 \subseteq S_m$ for every $m \ge 2$, any sign change that happens *inside* the sparse set $S_2$ is also a sign change inside the bigger set $S_m$. Positive positions in $S_2$ are still positive positions in $S_m$; negative positions stay negative. So if the sequence flips sign infinitely often over sums of two squares, it automatically flips sign infinitely often over sums of $m$ squares — for *every* $m \ge 2$ at once.

This is the **reduction**: the entire family of problems, one for each even $m$, collapses to a single base case. Prove it for $m = 2$ and you have proved it for all even $m$ (indeed for all $m \ge 2$) as a free corollary. The finite window $2 \le m \le 12$ in the literature was never a fundamental barrier; it was an artifact of proving each case by hand.

We can say even more in the large-$m$ regime. For $m \ge 4$, since $S_m$ *is* the whole number line, "infinitely many sign changes over sums of $m$ squares" is not merely implied by, it is **logically identical to**, "infinitely many sign changes over all the integers." The restricted question and the unrestricted question are one and the same. All of the interesting $m$-dependence in the entire problem is squeezed into the two sparse cases $m = 2$ and $m = 3$.

## The oscillation engine

There is one more ingredient worth describing, because it explains *why* the base case is true and packages the analytic heart of the matter into a clean, reusable principle.

Suppose you have any sequence of real numbers $a_1, a_2, a_3, \dots$ and you form its *running totals* (partial sums)
$$P(X) = \sum_{n < X} a_n.$$
Imagine you are told just one thing: that these running totals are **unbounded in both directions** — they climb arbitrarily high and also plunge arbitrarily low as $X$ grows. Then the sequence must be positive infinitely often *and* negative infinitely often.

The reasoning is soft and almost visual. If the sequence were eventually never positive, its running total could only decrease from some point on, and could never climb back up to new record highs — contradicting the assumption that it soars arbitrarily high. Symmetrically, if the sequence were eventually never negative, the running total could never sink to new record lows. So two-sided unboundedness of the running totals *forces* oscillation of the sequence, with no delicate cancellation estimates required.

This is a Landau-style principle, and it is exactly the shape of engine that the deep analytic tools of the subject — the Rankin–Selberg method and its relatives — are built to feed. Those tools deliver precisely the two-sided growth of the summatory functions that the oscillation principle needs, converting a hard-won *growth* estimate into a *sign-change* statement for free.

## Why this is a satisfying story

Zoom out and the shape of the argument is a small parable about mathematical taste. A problem was posed as an infinite ladder of separate cases — one rung for each even $m$ — and the published state of the art had climbed the first several rungs with real effort. The temptation is to keep climbing. The better move is to notice that the ladder is bolted to a wall: the sampling sets $S_m$ are nested and saturate at $m = 4$, so all but the very first rung are either free consequences of the base case or literally the same as the unrestricted problem.

Three ideas do all the work, and none of them requires the heavy machinery of $L$-functions:

- **Padding with zeros** gives the nesting $S_2 \subseteq S_3 \subseteq \cdots$, so sign changes on a smaller set transfer to every larger set.
- **Lagrange's four-square theorem** collapses $S_m$ to the entire number line for all $m \ge 4$, so those cases are the unrestricted problem in disguise.
- **A two-sided partial-sum criterion** turns growth of running totals directly into infinitely many sign changes.

Together they reduce an entire infinite family of theorems to a single base case, and they explain — cleanly, structurally, and once and for all — why the *shape* of the constraint "sum of $m$ squares" ultimately doesn't matter. The answer was hiding not in the analysis of modular forms, but in the elementary geometry of which numbers are sums of squares. That is the kind of surprise number theorists live for.
