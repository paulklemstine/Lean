# Non-Archimedean Factoring Oracle: When Factoring Meets the Future

## LEDE

In 1977, Ron Rivest, Adi Shamir, and Leonard Adleman published a paper that would reshape the digital world. Their RSA cryptosystem rested on a single, bold bet: that multiplying two large prime numbers is easy, but reversing the process — factoring their product — is extraordinarily hard. Nearly five decades later, that bet still holds. Every time you buy something online, send an encrypted message, or log into your bank account, you are trusting that no one has found a shortcut to factoring large numbers.

So when a claim surfaces that a "factoring oracle" exists — a mathematical device that can decompose any integer into smaller pieces — it demands scrutiny. That is exactly what happened when an AI system attempted to prove that every integer greater than 1 can be split into two nontrivial factors. The machine set to work, marshaling the tools of p-adic number theory and Hensel's lemma. And then it discovered something that every number theorist already knows, but that carries a profound lesson about the nature of mathematical truth: the claim is *false*.

## THE MATHEMATICAL HEART

Imagine you have a bag of colored marbles. Some bags can be split into two smaller bags, each containing at least two marbles. A bag of six red marbles? Easy — three and three. A bag of fifteen? Five and three. But what about a bag of seven? No matter how you try, you cannot split seven marbles into two groups that each have more than one marble — not if you insist that both groups multiply back to seven. Seven is *prime*: it resists decomposition.

The original theorem claimed that *every* number greater than 1 could be split this way. That is like claiming every bag of marbles can be divided — ignoring the stubborn, indivisible primes. The corrected theorem adds a simple but crucial caveat: the number must be *composite* (not prime). With that fix, the statement becomes true, and the proof is almost trivially elegant.

The proof works by contradiction with the definition of primality. If a number is greater than 1 and not prime, then by definition it must have a divisor other than 1 and itself. That divisor and the corresponding quotient give you the two factors, each greater than 1. Done.

## WHY IT MATTERS

This might seem like a trivial fix — adding one hypothesis to a theorem. But in the world of formal verification, where every logical step is checked by a computer, this kind of precision is everything.

Consider what would happen if a cryptographic protocol were designed based on the *original*, false claim. An engineer might assume that any number can be factored and build a system around that assumption. The system would work perfectly — until someone fed it a prime number, at which point it would silently produce garbage. In cryptography, silent failures are catastrophic.

Formal verification catches these errors before they become vulnerabilities. The Lean proof assistant, armed with the Mathlib library of mathematical knowledge, can check every step of a proof in milliseconds. When the AI tried to prove the false statement, Lean refused. No amount of cleverness could make the proof go through, because the statement was simply wrong.

This is the promise of formal methods in an age of AI-generated mathematics: machines that can not only generate proofs but also serve as incorruptible referees, catching errors that human reviewers might miss.

## THE BEAUTY

There is an unexpected elegance in the interplay between what is true and what is false here. The original statement is *almost* right — it fails only on the thin, infinite set of prime numbers. And yet "almost right" is, in mathematics, completely wrong.

The corrected proof itself is a single line of Lean code. It calls upon a lemma called `Nat.exists_dvd_of_not_prime2`, which encapsulates centuries of number theory in a single type signature: if a number is greater than 1 and not prime, then it has a divisor strictly between 1 and itself. From there, simple arithmetic does the rest.

There is also beauty in the p-adic context that frames the problem. The p-adic numbers — a strange, alternative number system where "closeness" is measured by divisibility rather than distance on a number line — provide powerful tools for studying factorization. Hensel's lemma, the p-adic analogue of Newton's method, can lift approximate factorizations to exact ones. While the corrected theorem does not need these tools, they point toward deeper connections between number theory, geometry, and algebra that mathematicians are still exploring.

## LOOKING AHEAD

The dream of a true "factoring oracle" — an efficient algorithm that can decompose any composite number — remains one of the great open problems of mathematics and computer science. Quantum computers, if they can be built at sufficient scale, would achieve this via Shor's algorithm. But classical factoring algorithms remain stubbornly slow for large numbers.

The p-adic approach hinted at in the original problem statement is not mere fantasy. Researchers have explored connections between Newton polygons (geometric objects that encode the p-adic structure of polynomials) and factorization algorithms. The idea is tantalizing: instead of searching for factors by brute force, one might "read off" the factorization from the shape of a carefully constructed geometric object.

Formal verification will play an increasingly important role as these ideas develop. As mathematical proofs become more complex and AI systems generate more conjectures, having a mechanical referee becomes not just useful but essential. The next century of mathematics may be characterized not by the theorems humans prove, but by the theorems machines verify — and the false conjectures they catch before they cause harm.

## CLOSING

Mathematics has always been a dialogue between ambition and rigor. We reach for bold claims — "every number can be factored!" — and then reality, in the form of primes, pulls us back. But this is not a failure. It is the process by which we sharpen our understanding, replacing vague intuitions with precise truths.

The story of the non-Archimedean factoring oracle is, in miniature, the story of all mathematics. We conjecture, we test, we fail, and we correct. And in the correction, we find something more valuable than the original claim: a theorem that is not just plausible, but *true* — verified by machine, rooted in logic, and immune to the seductive errors of human intuition.

In the end, the most powerful oracle is not one that factors numbers. It is one that tells us, with absolute certainty, which of our beliefs are justified — and which are merely wishes dressed up as theorems.
