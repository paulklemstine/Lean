# The Prime That Fibonacci Has Not Yet Revealed

## A rare alignment hidden in a familiar sequence

The Fibonacci sequence begins almost innocently:

$$
0,1,1,2,3,5,8,13,21,34,55,89,144,\ldots
$$

Each term is the sum of the preceding two. This rule is so simple that it appears in school exercises, recreational puzzles, plant-growth models, and algorithms. Yet the sequence also carries delicate information about prime numbers. One of its most elusive secrets concerns a hypothetical kind of prime called a **Wall–Sun–Sun prime**, or **Fibonacci–Wieferich prime**.

No such prime is known as of 2026. Nor has anyone proved that none exist. The open question is therefore not merely to find the first member of a rare species, but to determine whether the species exists at all.

The defining test is precise. For a positive integer $p$, first choose an index $I(p)$ by looking at the residue of $p$ modulo $5$:

$$
I(p)=
\begin{cases}
p-1, & p\equiv 1 \text{ or }4\pmod 5,\\
p+1, & \text{otherwise}.
\end{cases}
$$

A number $p$ is a Wall–Sun–Sun prime when two conditions hold: $p$ is prime, and

$$
p^2\mid F_{I(p)},
$$

where $F_n$ is the $n$th Fibonacci number, defined by $F_0=0$, $F_1=1$, and $F_{n+2}=F_{n+1}+F_n$.

For primes other than the exceptional primes $2$ and $5$, the index $I(p)$ is the natural-number expression of $p-(p\mid 5)$, where $(p\mid 5)$ denotes the quadratic character modulo $5$. The residue classes $1$ and $4$ are the nonzero squares modulo $5$, so they select $p-1$; the classes $2$ and $3$ select $p+1$. This is why the apparently arbitrary modulus $5$ is woven into the definition.

## Why the square matters

A standard divisibility pattern places a factor of $p$ in a nearby Fibonacci number. The Wall–Sun–Sun condition asks for something much stronger: not just divisibility by $p$, but divisibility by $p^2$. The first factor is part of a broad modular rhythm; the second is an exceptional coincidence.

One can picture Fibonacci numbers moving around a clock with $p^2$ positions. The recurrence still works on the clock: every new position is the sum of the previous two, reduced modulo $p^2$. A Wall–Sun–Sun prime is one for which the specially selected term lands exactly at zero. Testing the condition therefore does not require writing down the enormous integer $F_{I(p)}$. It is enough to compute the recurrence modulo $p^2$.

That observation turns a definition into a search algorithm. For each candidate prime $p$:

1. compute $p\bmod 5$;
2. choose $I(p)=p-1$ or $p+1$;
3. compute $F_{I(p)}\bmod p^2$;
4. accept $p$ only if the remainder is zero.

A fast-doubling method makes the third step especially efficient. From $F_k$ and $F_{k+1}$ one obtains

$$
F_{2k}=F_k\bigl(2F_{k+1}-F_k\bigr)
$$

and

$$
F_{2k+1}=F_k^2+F_{k+1}^2.
$$

Reducing after every multiplication keeps the numbers small, while repeatedly halving the index gives logarithmic recursion depth.

## The first candidates fall away

The smallest cases already show how restrictive the square-divisibility condition is. For $p=2$, the rule gives $I(2)=3$, and $F_3=2$. Since $4$ does not divide $2$, the test fails. For $p=3$, the index is $4$ and $F_4=3$; $9$ does not divide $3$. For $p=5$, the index is $6$ and $F_6=8$; $25$ does not divide $8$.

The next two primes behave similarly:

| Prime $p$ | Index $I(p)$ | Fibonacci value $F_{I(p)}$ | Square test |
|---:|---:|---:|:---|
| $2$ | $3$ | $2$ | $4\nmid 2$ |
| $3$ | $4$ | $3$ | $9\nmid 3$ |
| $5$ | $6$ | $8$ | $25\nmid 8$ |
| $7$ | $8$ | $21$ | $49\nmid 21$ |
| $11$ | $10$ | $55$ | $121\nmid 55$ |

These computations establish a complete small-range result: **there is no Wall–Sun–Sun prime below $12$**. Indeed, the only primes below $12$ are exactly the five listed above, and each fails its divisibility test. Consequently, if a Wall–Sun–Sun prime exists, it is at least $12$. Since it must itself be prime, the first still-eligible candidate after this range is $13$.

Two individual conclusions are worth isolating. The prime $3$ is not a Wall–Sun–Sun prime because its relevant Fibonacci number is $3$, not a multiple of $9$. The prime $5$ is not one because its relevant Fibonacci number is $8$, not a multiple of $25$. The latter is also the ramified exceptional prime in the quadratic-residue interpretation, so checking it directly avoids pretending that the residue rule has no exceptions.

## Residues guide the index, but do not settle the test

It is tempting to confuse the branch of the definition with the property itself. Primes congruent to $1$ or $4$ modulo $5$ use the index $p-1$. Could that favorable-looking residue already force square divisibility?

No. The prime $11$ is a decisive counterexample. It satisfies

$$
11\equiv 1\pmod 5,
$$

so the chosen index is $I(11)=10$. But

$$
F_{10}=55,
$$

and $121$ does not divide $55$. Thus being a prime congruent to $\pm1$ modulo $5$ is **not sufficient** for being a Wall–Sun–Sun prime. Residue information tells us where to look; it does not tell us what we will find there.

This distinction is a recurring theme in number theory. Congruence classes often organize a problem into cases, but a higher-power divisibility condition can carry extra information invisible modulo the smaller number. Passing from $p$ to $p^2$ is not a cosmetic strengthening. It asks whether a modular coincidence “lifts” one level farther than expected.

## A careful boundary with Fermat’s Last Theorem

Wall–Sun–Sun primes are sometimes discussed near historical criteria related to Fermat-type equations. That proximity can invite an overstatement: perhaps Fermat’s Last Theorem at prime exponent $p$ is equivalent to $p$ being Wall–Sun–Sun.

The statement is false, and the smallest odd prime supplies the counterexample. Fermat’s Last Theorem at exponent $3$ says that there are no positive integers $a,b,c$ satisfying

$$
a^3+b^3=c^3.
$$

That theorem holds. Yet $3$ is not a Wall–Sun–Sun prime, since $9\nmid F_4=3$. Therefore the universal equivalence

$$
\text{“Fermat’s Last Theorem holds at exponent }p\text{”}
\quad\Longleftrightarrow\quad
\text{“}p\text{ is Wall–Sun–Sun”}
$$

cannot hold for every prime $p$.

This negative result is mathematically useful. It clears away a seductive but incorrect shortcut and leaves room for subtler, accurately stated one-way criteria. A relationship between two subjects need not be an equivalence, and a historical connection need not turn every result on one side into a characterization of the other.

## What has—and has not—been established

The central existence statement can be written succinctly:

$$
\exists p\text{ prime such that }p^2\mid F_{I(p)}.
$$

This remains a conjecture, not a theorem. The elementary results here do not claim otherwise. They establish the definition, eliminate every candidate below $12$, prove the resulting lower bound, and refute two incorrect simplifications: residue $\pm1$ modulo $5$ is not sufficient, and the property is not equivalent prime-by-prime to Fermat’s Last Theorem.

That combination of positive and negative knowledge matters. Open problems are shaped not only by what has been proved, but also by which plausible routes have been closed. The small calculations show exactly how the test behaves. The counterexamples show exactly where intuitive analogies fail.

There is also a useful lesson here about mathematical naming. Calling an integer a “candidate” does not mean it nearly passes. It means only that it has reached the stage at which the decisive test makes sense. Primality is the entrance ticket; the residue modulo $5$ chooses one of two doors; the Fibonacci remainder modulo $p^2$ decides what lies behind it. For every small prime in the table, that last remainder is nonzero.

The condition belongs to a wider family of Wieferich-type questions. In such problems, a congruence that naturally holds modulo $p$ is asked to persist modulo $p^2$. That extra power of $p$ transforms an ordinary divisibility pattern into an exceptional lifting event. Similar questions arise for powers, recurrence sequences, and arithmetic objects whose modular behavior can be followed from one prime-power level to the next. Wall–Sun–Sun primes are the Fibonacci version of this general tension between expected first-order behavior and rare second-order alignment.

## Searching farther without losing the mathematics

A serious search should use fast doubling modulo $p^2$. To test all primes up to a bound $B$, one may first enumerate primes, then perform an $O(\log p)$ modular Fibonacci calculation for each. With a sieve, prime generation costs about $O(B\log\log B)$ elementary marking operations; the modular arithmetic then contributes roughly one logarithmic-index calculation per prime. Memory can be kept near-linear in $B$ for a basic sieve, or reduced with segmented methods.

But a larger finite search cannot by itself prove existence unless it finds a witness, and it cannot prove nonexistence unless it somehow covers all primes—which no finite bound does. This logical asymmetry is essential. One zero remainder would settle existence immediately. A billion nonzero remainders would only move the frontier.

The next mathematical steps are therefore both computational and conceptual: prove the modular fast-doubling procedure agrees with the ordinary Fibonacci sequence, package large searches into independently checkable remainder certificates, and sharpen the bridge between the residue description and the quadratic character $(p\mid5)$. Historical links with Fermat-type criteria should be stated only in their precise one-way forms.

The Fibonacci sequence looks predictable because every term is forced by the previous two. Prime numbers look unpredictable because their spacing refuses a simple recurrence. Wall–Sun–Sun primes stand at the intersection: a rigid sequence asked to perform an extraordinarily rare trick at a prime-dependent index. We know exactly what the trick is. We know that the first few performers fail. What no one yet knows is whether, somewhere beyond the visible horizon, one prime finally succeeds.
