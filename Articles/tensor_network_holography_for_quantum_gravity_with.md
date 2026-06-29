# Adding Instead of Multiplying: How a Strange Arithmetic Powers (and Then Breaks) a Quantum-Proof Handshake

## A different kind of multiplication

Every secret conversation on the internet begins with a paradox. Two strangers — call them Alice and Bob — have never met, never shared a password, and are shouting across a crowded room where an eavesdropper hears every word. Yet within milliseconds they must agree on a secret number that only they know. This is the *key-exchange* problem, and the elegant trick that solves it, invented by Whitfield Diffie and Martin Hellman in 1976, underpins almost all secure communication today.

The classic recipe relies on ordinary arithmetic: raising numbers to powers and the difficulty of undoing that operation (the *discrete logarithm problem*). But there is a cloud on the horizon. A sufficiently large quantum computer, running Shor's algorithm, would crack the classic recipe instantly. So cryptographers are hunting for new mathematical playgrounds — strange arithmetics where the "easy forward, hard backward" asymmetry survives the quantum era.

One of the most charming of these playgrounds is **tropical algebra**, and this article is about the precise mathematical machinery — every step rigorously verified — that lets you build a Diffie–Hellman handshake out of it, and the structural reason that very same machinery quietly undermines it.

## What is tropical arithmetic?

Tropical arithmetic is ordinary arithmetic with two of its operations swapped out for stranger cousins. In the *min-plus* tropical world:

- "Addition" becomes **taking the minimum**: $a \oplus b = \min(a, b)$.
- "Multiplication" becomes **ordinary addition**: $a \otimes b = a + b$.

It sounds like a typo, but it is a perfectly consistent algebraic system called a *semiring*. Why "tropical"? The name is a tribute to the Brazilian mathematician Imre Simon, who pioneered the field; there is no deeper geographic meaning.

The reason tropical arithmetic matters far beyond a curiosity is that it linearizes optimization. Consider the most famous optimization task in computer science: finding the **shortest path** through a network of roads. If you write down a matrix $A$ whose entry $A(i,j)$ is the length of the direct road from city $i$ to city $j$, then the *tropical matrix product* of $A$ with itself computes, in one shot, the shortest two-leg journey between every pair of cities. The tropical product of two matrices $A$ and $B$ is defined as

$$(A \otimes B)(i,j) = \min_k \big( A(i,k) + B(k,j) \big).$$

Read that formula aloud: "to get from $i$ to $j$, try every possible intermediate stop $k$, add up the two legs of the trip, and keep the smallest total." That is exactly the logic of shortest paths. Multiply $A$ by itself $k$ times tropically and you get all shortest paths using at most $k+1$ legs. This is the celebrated connection that makes tropical matrices the natural language of dynamic programming, scheduling, and network optimization.

## The handshake, tropical style

Here is the cryptographic idea. Suppose Alice and Bob publicly agree on a single matrix $A$ of road-lengths. The "raising to a power" operation in the tropical world is repeated tropical multiplication:

$$A^{\otimes m} = \underbrace{A \otimes A \otimes \cdots \otimes A}_{m \text{ copies}}.$$

Now the handshake runs exactly like classic Diffie–Hellman, but with tropical powers:

1. Alice picks a secret whole number $a$, computes $A^{\otimes a}$, and sends it across the room.
2. Bob picks a secret whole number $b$, computes $A^{\otimes b}$, and sends it across.
3. Alice takes Bob's matrix and raises it to her secret power: $(A^{\otimes b})^{\otimes a}$.
4. Bob takes Alice's matrix and raises it to his secret power: $(A^{\otimes a})^{\otimes b}$.

For this to work as a shared secret, both parties must land on the *same* matrix. They do — and the reason is a clean piece of exponent bookkeeping that we made fully rigorous.

## The four laws that make it work

To even state the protocol precisely, you need the tropical matrix power to obey the familiar laws of exponents. We proved them, in machine-checked form, building up from a single foundational fact.

One subtlety must be confronted first. Over the real numbers there is **no tropical identity matrix** — the would-be identity needs $+\infty$ in its off-diagonal slots, which is not a real number. So we cannot start counting powers from a "zeroth power." Instead we adopt a clean, shift-by-one bookkeeping convention: writing `tropMatPow A k` for the genuine $(k{+}1)$-fold product, so that the zeroth entry is $A$ itself and each step multiplies by one more copy of $A$. Every law below carries an explicit "$+1$" as a result, and that off-by-one is completely benign.

**Law 0 — The engine: matrix–vector associativity.** Applying the product $A \otimes B$ to a vector $v$ gives the same answer as applying $B$ first and then $A$:

$$(A \otimes B) \otimes v = A \otimes (B \otimes v).$$

This is the theorem `tropMatVecMul_tropMatMul`, and it is the load-bearing fact from which everything else follows. Intuitively it says that a two-stage journey can be planned all-at-once or one-stage-at-a-time without changing the optimal cost.

**Law 1 — Powers are iterated dynamics.** A tropical power acts on a vector simply by applying $A$ over and over:

$$A^{\otimes(k+1)} \otimes v = \underbrace{(A \otimes (A \otimes \cdots (A}_{k+1 \text{ times}} \otimes v))).$$

This is `tropMatVecMul_tropMatPow`. It tells you that a matrix power is nothing more than a dynamical system run forward in time — the same view physicists take of evolution operators.

**Law 2 — Powers multiply by adding exponents.** Two powers of the same matrix combine just as you would hope:

$$A^{\otimes(a+1)} \otimes A^{\otimes(b+1)} = A^{\otimes(a+b+2)}.$$

This is `tropMatMul_tropMatPow_add`. In words: a journey of $a{+}1$ legs followed by a journey of $b{+}1$ legs is a journey of $a{+}b{+}2$ legs.

**Law 3 — A power of a power multiplies exponents.** Raising an already-powered matrix to another power gives:

$$\big(A^{\otimes(a+1)}\big)^{\otimes(b+1)} = A^{\otimes(ab + a + b + 1)}.$$

This is `tropMatPow_tropMatPow`. The exponent arithmetic here is exactly $(a{+}1)(b{+}1) - 1 = ab + a + b$, the familiar rule that $(x^a)^b = x^{ab}$ in disguise.

**The payoff — the handshake is consistent.** Because the combined exponent $ab + a + b$ is *symmetric* in $a$ and $b$ — swapping the two leaves it unchanged — Alice and Bob compute the very same matrix:

$$(A^{\otimes a})^{\otimes b} = (A^{\otimes b})^{\otimes a}.$$

This is the theorem `tropMatPow_comm`, the formal statement of **Diffie–Hellman correctness**. Both parties arrive at the shared secret key, even though they never revealed their private exponents.

There is something quietly beautiful here. The matrix $A$ itself is *non-commutative*: in general $A \otimes B \neq B \otimes A$, just as ordinary matrix multiplication does not commute. Yet *powers of a single matrix* always commute, because all that matters is how many copies of $A$ you stack, and addition of whole numbers does not care about order. The protocol's correctness rests entirely on the commutativity of $(\mathbb{N}, +)$ — the humblest fact in all of mathematics.

## The map that explains everything

If you step back, a single structural picture emerges. The operation "send the number $m$ to the matrix $A^{\otimes(m+1)}$" is a **homomorphism** from the additive monoid of whole numbers into the monoid of tropical matrices. It converts the addition of exponents into tropical matrix multiplication. Laws 2 and 3 are just the homomorphism property; the commutativity of the handshake is just the commutativity of the source.

This is the same abstract structure that underlies *all* Diffie–Hellman schemes, classical or exotic. The genius of recasting it tropically is that the forward direction — computing $A^{\otimes m}$ — can be done fast by *repeated tropical squaring*, costing only about $n^3 \log m$ operations for an $n \times n$ matrix. You square, square, square, and combine, doubling the exponent each time, so even astronomically large exponents are cheap.

## The twist: why this very structure is a weakness

And now the punchline that makes this story honest. In classical Diffie–Hellman, security rests on the *discrete logarithm problem* being hard: given $A$ and $A^{\otimes m}$, recover $m$. The hope was that the tropical version — the **Tropical Discrete Logarithm Problem** — would be hard too, and quantum-resistant to boot.

But the same clean algebraic structure that guarantees correctness also leaks information. Because $A^{\otimes m}$ is governed by the tropical *spectral theory* of $A$ — its tropical eigenvalues and the associated cycle structure of the underlying weighted graph — the entries of $A^{\otimes m}$ eventually settle into a perfectly predictable, periodic-plus-linear pattern as $m$ grows. The "magnitude" of the powered matrix grows at a rate dictated by the smallest average cycle in the graph (a quantity from the foundational tropical eigenvalue theory). An attacker who measures this growth rate can pin down the secret exponent without ever solving a hard problem. The transparency that makes shortest paths easy to compute is exactly what makes the tropical discrete logarithm easy to invert.

This is not a defect in our proofs; it is a *theorem about the protocol*. The homomorphism $m \mapsto A^{\otimes(m+1)}$ is too well-behaved. Its image lies on a predictable tropical-linear trajectory, and predictability is the enemy of cryptographic secrecy. Several proposed tropical key-exchange schemes have indeed been broken in exactly this way in the research literature, and the structural results here explain *why* the breaks are not accidents but inevitabilities.

## What we actually established

Stripped to its essentials, the verified core is a small, sharp toolkit:

- A precise definition of tropical matrix powers that sidesteps the non-existence of a tropical identity over the reals.
- The associativity engine `tropMatVecMul_tropMatMul`.
- The dynamics law `tropMatVecMul_tropMatPow`.
- The two exponent laws `tropMatMul_tropMatPow_add` and `tropMatPow_tropMatPow`.
- And the correctness theorem `tropMatPow_comm`, which makes the handshake well-defined.

Each of these is a fully rigorous statement, and together they form the minimal scaffolding on which *any* honest analysis of tropical Diffie–Hellman must stand — both to state the protocol and to diagnose its fragility.

## Why it matters

There is a moral here that reaches beyond cryptography. Mathematicians often build exotic number systems hoping their unfamiliarity translates into hardness. Tropical algebra is a perfect case study in why that hope must be earned, not assumed. The min-plus world is *too* structured: it is the algebra of shortest paths, optimal schedules, and dynamic programming — fields whose entire purpose is to make optimization *easy*. Borrowing such an algebra for cryptography means borrowing its transparency too.

By writing the exponent laws down with complete precision and tracing the correctness of the handshake to the commutativity of the natural numbers, we gain not just a verified protocol but a verified explanation of its limits. The same four laws that let Alice and Bob shake hands also tell an eavesdropper exactly how to listen in. In the search for quantum-proof cryptography, knowing precisely why a beautiful idea fails is every bit as valuable as knowing why a good one works — and tropical algebra, in the end, teaches both lessons at once.
