# Non-Archimedean Factoring Oracle: When Factoring Meets the Future

## LEDE

In 1801, Carl Friedrich Gauss published *Disquisitiones Arithmeticae*, a book that would shape number theory for centuries. In it, he proved a fact so fundamental it seems almost too simple to state: every integer greater than one is either prime — an indivisible atom of arithmetic — or it can be broken into smaller pieces. Two hundred and twenty-five years later, a computer was asked to verify a modern version of this claim, dressed up in the exotic language of p-adic numbers. The computer said no.

Not because the math was too hard. Because the math was wrong.

## THE MATHEMATICAL HEART

Imagine you have a bag of marbles. Someone hands you a number — say, 12 — and asks: can you split these marbles into two non-trivial groups? Of course. Six and two, four and three, any number of ways. But what if they hand you 7? Or 13? Or 41? These are prime numbers, the stubborn loners of arithmetic. No matter how you try, you cannot split 7 marbles into two groups each containing more than one marble. It's 7 or nothing.

The original theorem — the "p-adic factoring oracle" — claimed something seductive: that *every* number greater than 1 could be split into two such groups. It wrapped this claim in sophisticated mathematics, invoking p-adic numbers, Newton polygons, and Hensel's lemma — tools from a branch of mathematics where distance itself is redefined. In the p-adic world, numbers that are divisible by a prime p are considered "close to zero." It's as if you measured the size of a city not by its population but by how many times it could be evenly divided into boroughs.

The allure of p-adic methods is real. They have powered breakthroughs in algebraic geometry, spawned entire fields of research, and even contributed to Andrew Wiles's proof of Fermat's Last Theorem. But no amount of p-adic sophistication can make 7 composite. The corrected theorem states what Gauss knew all along: every integer greater than 1 is either prime, or it can be factored. There is no third option.

## WHY IT MATTERS

This story matters not because of the mathematics — which is elementary — but because of what it reveals about the process of mathematical discovery in the age of artificial intelligence.

**For cryptography**, the question of factoring is existential. The RSA cryptosystem, which secures trillions of dollars in digital transactions, relies on the fact that while multiplying two large primes is easy, reversing the process is extraordinarily hard. The corrected theorem tells us that composite numbers *do* have factors — the challenge is finding them efficiently. No p-adic oracle changes the computational landscape, but understanding exactly what can and cannot be claimed is the first line of defense against false confidence.

**For artificial intelligence**, this episode is a parable. AI systems increasingly generate mathematical conjectures, write proofs, and propose theorems. When a system produces a statement that *sounds* sophisticated — invoking Newton polygons and Hensel's lemma — it can be tempting to trust the result. Formal verification, the process of checking proofs with computer assistance, acts as an incorruptible referee. The Lean proof assistant caught an error that might have slipped past a hurried human reviewer.

**For mathematics itself**, the incident underscores a timeless truth: elegance and correctness are not the same thing. A beautifully motivated false theorem is still false.

## THE BEAUTY

There is, however, genuine beauty in the corrected result — and in the process that led to it.

The proof in Lean 4 is startlingly concise: three lines of code. It performs a case split — is the number prime or not? — and in the composite case, it invokes a single Mathlib lemma that produces a proper divisor. From that divisor, the two factors materialize like pulling a thread to unravel a knot.

The beauty lies in the *inevitability*. Every composite number carries within it the seeds of its own decomposition. The smallest factor of any composite number n is at most √n — a fact that connects factoring to geometry (the square root!) and gives trial division its basic efficiency guarantee. This is mathematics at its most crystalline: a statement so clean it feels like it was always true, waiting to be noticed rather than invented.

There is beauty, too, in the failure. The p-adic framing, while ultimately a red herring for this particular claim, points toward real and deep mathematics. Newton polygons *do* reveal the structure of polynomials over p-adic fields. Hensel's lemma *does* lift approximate solutions to exact ones. These tools are genuine factoring oracles — not for integers, but for polynomials. The error was not in the tools but in the application.

## LOOKING AHEAD

What doors does this open? Three directions beckon.

First, **formal verification at scale**. As AI systems generate more mathematical content, the need for automated proof checking will only grow. Projects like Lean's Mathlib — a vast library of machine-verified mathematics — are building the infrastructure for a future where no published theorem goes unchecked. The factoring oracle incident is a small example of a large trend.

Second, **p-adic algorithms**. While the p-adic factoring oracle failed as stated, p-adic methods genuinely contribute to polynomial factoring algorithms. The Berlekamp-Zassenhaus algorithm, used in every modern computer algebra system, relies on Hensel lifting to factor polynomials over the integers by first factoring modulo a prime and then "lifting" the result. Formalizing these algorithms in Lean would be a significant contribution to verified computation.

Third, **the sociology of error**. Mathematics has a self-correction mechanism — proof — that is unmatched in any other discipline. But proofs are checked by humans, and humans make mistakes. The rise of formal verification does not replace human intuition; it augments it. The mathematician who proposed the p-adic factoring oracle had a genuine insight about the power of non-Archimedean methods. The computer that rejected the false theorem had no insight at all — just an unerring ability to check logical steps. Together, human creativity and machine rigor form a partnership that is more powerful than either alone.

## CLOSING

There is something deeply satisfying about a theorem that says: every number has a nature. It is either indivisible — prime, atomic, fundamental — or it contains within itself a hidden structure waiting to be revealed. This dichotomy is not just a fact about numbers. It is a metaphor for knowledge itself.

Some truths are atomic: they cannot be broken down further, they must simply be accepted. The axioms of mathematics, the speed of light, the irreducibility of consciousness. Other truths are composite: they can be decomposed, analyzed, understood in terms of simpler parts. The art of mathematics — and perhaps of all inquiry — is learning to tell the difference.

The p-adic factoring oracle promised a shortcut: a way to factor every number, no exceptions. Reality, as checked by a computer running Lean 4, was more nuanced. Some numbers resist factoring not because we lack cleverness, but because they are genuinely irreducible. And recognizing that — knowing when to stop looking for factors that don't exist — is itself a form of mathematical wisdom.
