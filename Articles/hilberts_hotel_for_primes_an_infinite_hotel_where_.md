# Hilbert’s Hotel for Primes

## How an infinite hotel can absorb any finite shuffle without disturbing its horizon

Imagine a hotel with rooms numbered $0,1,2,\ldots$. There is no last room. In the familiar Hilbert’s Hotel paradox, infinity allows a manager to make space even when every room is occupied: move the guest in room $n$ to room $n+1$, and room $0$ becomes free.

Now impose a stricter rule. Every guest is a prime number. Choose any enumeration $p_0,p_1,p_2,\ldots$ of primes, with room $n$ occupied by $p_n$. A rearrangement is a permutation $\sigma$ of the nonnegative integers: after the move, room $n$ receives the guest formerly indexed by $\sigma(n)$, namely $p_{\sigma(n)}$.

How visible is the rearrangement far down the corridor? A natural measuring device is the ratio

$$
\frac{p_{\sigma(n)}}{p_n}.
$$

If this ratio approaches $1$ as $n$ tends to infinity, then the rearrangement becomes asymptotically invisible. The occupants may differ, but their numerical sizes become indistinguishable on a relative scale.

One might expect a theorem about prime numbers to drive the story. After all, the $n$th prime is governed by the prime number theorem, roughly growing like $n\log n$. Surprisingly, the central result needs none of that. Its engine is a much simpler fact about infinity: any finite glimpse of an arbitrary rearrangement can be completed so that, sufficiently far along the corridor, no guest moves at all.

## What “dense” means in an infinite hotel

To make that claim precise, we need a topology—a notion of when two infinite rearrangements are close. In the pointwise topology, an observer can inspect only finitely many rooms. A neighborhood of a permutation $\sigma$ is specified by choosing a cutoff $k$ and demanding agreement in rooms $0,1,\ldots,k-1$.

A collection of permutations is called **prefix-dense** if, for every permutation $\sigma$ and every finite cutoff $k$, there is a member $\tau$ of the collection satisfying

$$
\tau(n)=\sigma(n)\qquad\text{for every }n<k.
$$

Thus density does not mean that “most” rearrangements are good, nor does it assign a probability. It means that no finite observation can rule out a good rearrangement. However bizarre the first million assignments may look, they can be continued into one whose distant behavior is perfectly tame.

Call a rearrangement **well behaved for a nonzero sequence** $a_0,a_1,a_2,\ldots$ if

$$
\lim_{n\to\infty}\frac{a_{\sigma(n)}}{a_n}=1.
$$

The prime hotel is one example, but the underlying result applies to every real sequence whose terms are nonzero from some point onward.

## The finite-extension trick

Here is the main combinatorial construction. Suppose the observer prescribes the first $k$ values

$$
\sigma(0),\sigma(1),\ldots,\sigma(k-1).
$$

Because this list is finite, choose an integer $N$ larger than $k$ and larger than every prescribed image. All sources and targets seen by the observer now lie in the finite set

$$
\{0,1,\ldots,N-1\}.
$$

The prescribed assignments form an injective partial matching: distinct source rooms have distinct target rooms because $\sigma$ is a permutation. In a finite set, any such partial matching with equally many unmatched sources and unmatched targets can be completed to a bijection. Match the remaining sources to the remaining targets in any order. This produces a permutation of the first $N$ rooms agreeing with every observed assignment.

Now extend it to the infinite hotel by fixing every room numbered at least $N$. The resulting infinite permutation $\tau$ satisfies two properties:

1. $\tau(n)=\sigma(n)$ for every $n<k$;
2. $\tau(n)=n$ for every $n\ge N$.

This is the **Finite-Prefix Extension Theorem**: every finite prefix of every infinite permutation extends to a permutation that is eventually the identity.

The theorem turns an arbitrary finite tangle into a finite collection of cycles. Outside one sufficiently large finite lobby, the entire hotel remains untouched.

## Why every eventually fixed shuffle disappears

Suppose a real sequence $a_n$ is eventually nonzero and $\tau(n)=n$ for all sufficiently large $n$. Then eventually

$$
\frac{a_{\tau(n)}}{a_n}
=
\frac{a_n}{a_n}
=1.
$$

The quotient is not merely close to $1$; it is exactly $1$ from some point onward. Therefore it converges to $1$.

Combining this observation with the finite-extension trick yields the central result.

**Dense Asymptotic-Invisibility Theorem.** Let $a_0,a_1,a_2,\ldots$ be a real sequence with $a_n\ne 0$ for all sufficiently large $n$. For every permutation $\sigma$ and every cutoff $k$, there is a permutation $\tau$ such that

$$
\tau(n)=\sigma(n)\quad(n<k)
$$

and

$$
\lim_{n\to\infty}\frac{a_{\tau(n)}}{a_n}=1.
$$

In other words, ratio-one rearrangements are prefix-dense.

For primes, nonvanishing is automatic. If every $p_n$ is prime, then $p_n\ge 2$, so every denominator is nonzero. We immediately obtain the **Prime-Hotel Density Theorem**: for any prime-valued enumeration $p_n$, any finite initial behavior of any permutation can be matched by another permutation $\tau$ for which

$$
\lim_{n\to\infty}\frac{p_{\tau(n)}}{p_n}=1.
$$

Notice the strength and the restraint of this statement. It proves that good rearrangements lie arbitrarily close to every rearrangement in the pointwise topology. It does **not** prove that every rearrangement is good, or that a random permutation is likely to be good. Topological density is possibility in every finite window, not prevalence.

## Why random finite shuffles tell a different story

A tempting experiment is to randomly permute the first million primes and inspect the ratios. But a uniformly random permutation of a finite block usually moves an index by a macroscopic fraction of the block. Since the $n$th prime behaves approximately like $n\log n$, sending $n$ near a very different index can create ratios far from $1$.

Worse, a finite experiment has no literal limit as $n\to\infty$ unless one specifies how finite samples are embedded into an infinite model. If the finite permutation is extended by the identity beyond one million, then all later ratios are exactly $1$, making convergence automatic. If instead one studies a growing sequence of random blocks, the answer depends on the probability model and the coupling between blocks.

The theorem therefore corrects an intuitive but misleading slogan. The primes are not robust under arbitrary rearrangement. Rather, asymptotically invisible rearrangements form a topologically dense core because every finite rearrangement can be sealed inside a finite region.

## Counting the finite lobby: factorial codes

How many different rearrangements can occur inside the first $k$ rooms while the rest of the hotel remains fixed? Exactly $k!$.

One elegant encoding uses a Lehmer code. For a permutation of $k$ objects, record at each stage how many unused smaller objects lie before the selected one. The digits satisfy bounds of the form

$$
0\le c_i<k-i,
$$

so the total number of codes is

$$
k(k-1)\cdots 2\cdot 1=k!.
$$

Different codes produce different finite permutations. Extending each finite permutation by the identity preserves distinctness, because two different arrangements already disagree in the finite lobby. This gives the **Factorial Family Theorem**: the $k!$ Lehmer codes yield $k!$ distinct infinite permutations supported in the first $k$ rooms, and each is asymptotically invisible to every eventually nonzero sequence.

This result gives the dense core a concrete combinatorial skeleton. For each lobby size $k$, there are exactly $k!$ canonical finite shuffles, all harmless at infinity.

## A small example

Take the first few primes

$$
2,3,5,7,11,13,17,19,\ldots
$$

and prescribe

$$
0\mapsto 3,\qquad 1\mapsto 0,\qquad 2\mapsto 4.
$$

The targets are distinct. Choose $N=5$. The used targets are $0,3,4$, leaving $1,2$ for sources $3,4$. One completion is

$$
3\mapsto 1,
\qquad
4\mapsto 2.
$$

Fix every index $n\ge 5$. The resulting rearranged prime list begins

$$
7,2,11,3,5,13,17,19,\ldots
$$

The early ratios jump around:

$$
\frac72,\quad \frac23,\quad \frac{11}{5},\quad \frac37,\quad \frac5{11}.
$$

But from room $5$ onward, each ratio equals $1$. An arbitrarily dramatic finite disturbance leaves no asymptotic trace.

## Beyond primes

The proof barely uses arithmetic. Replace primes by stock prices, frequencies, masses, matrix norms, or any real measurements that are eventually nonzero. If only finitely many coordinates are moved, then termwise ratios eventually equal $1$. The phenomenon belongs to the geometry of infinite permutation space, not to the distribution of primes.

That distinction opens more difficult questions. Which infinitely supported permutations still produce ratio $1$ for primes? The prime number theorem suggests that a displacement condition such as

$$
\frac{\sigma(n)}n\longrightarrow 1
$$

should be closely related to

$$
\frac{p_{\sigma(n)}}{p_n}\longrightarrow 1.
$$

Can every positive constant occur as a limiting ratio? Are ratio-one permutations dense but small in the sense of Baire category? What happens in random infinite permutation models built from blocks of varying length?

The finite-extension theorem does not answer these questions, but it isolates the exact baseline from which they should be asked. Finite observations impose no asymptotic obstruction. Any genuine obstruction must arise from infinitely many coordinated moves.

## The exact shape of the achievement

There are three nested ideas. First, finite assignments can be completed to a finite permutation. Second, that finite permutation can be installed in the infinite hotel by leaving every later room alone. Third, any relative comparison then stabilizes because unchanged nonzero entries satisfy $a_n/a_n=1$. The prime theorem is therefore a specialization of a universal sequence theorem, while the factorial count describes how richly the finite core can vary.

This hierarchy also supplies a practical test for proposed generalizations. Ask whether the observed assignment is injective, whether all prescribed sources and targets fit inside a finite region, and whether the relevant quotient is defined on the tail. If all three answers are yes, the same construction works. If one fails, genuinely new mathematics is required.

Hilbert’s Hotel remains strange for a precise reason: its finite lobby and infinite horizon obey different laws. In the lobby, guests may dance through any prescribed pattern. At the horizon, the manager can restore perfect stillness. For primes—and, in fact, for every eventually nonzero sequence—that is enough to make asymptotic invisibility unavoidable in every finite neighborhood.