# Non-Archimedean Factoring Oracle: When Factoring Meets the Future

## LEDE

In 1920, the Indian mathematician Srinivasa Ramanujan lay in a nursing home in Putney, England, visited by his collaborator G. H. Hardy. Hardy mentioned that his taxi had the number 1729 — "a rather dull number," he remarked. Ramanujan instantly disagreed: "No, it is a very interesting number; it is the smallest number expressible as the sum of two cubes in two different ways."

What Ramanujan saw in a flash — that numbers carry hidden structure — is the same instinct that drives a modern question at the intersection of number theory, cryptography, and computer science: given a large number, can you find its factors? Today, the security of every online banking transaction, every encrypted email, every digital signature rests on the assumption that this question is hard. But what if there were an oracle — a mathematical black box — that could decompose any composite number into its building blocks?

A recent formal verification project attempted to construct exactly such an oracle, inspired by the exotic world of p-adic numbers. What happened next reveals something profound about the nature of mathematical truth.

## THE MATHEMATICAL HEART

Imagine you have a jar of marbles, and someone tells you the total count. Can you always split them into two smaller groups, each with at least two marbles? If there are six marbles, sure — three and three, or two and four. If there are twelve, easy — three and four, or two and six.

But what if there are exactly seven marbles? You can split them into one and six, or two and five, or three and four. That works — seven is not prime... wait. Actually seven *is* prime. But you can still split the *marbles* into groups. The catch is that the mathematical question is more specific: can you split them so that the *product* (not sum) of the two group sizes equals seven? That means finding two numbers, both bigger than one, that multiply to give seven. And you can't — because seven is prime.

This is the heart of the matter. The original conjecture claimed that every integer greater than one can be "factored" into two pieces, both greater than one. It drew inspiration from p-adic numbers — a strange alternative number system invented by Kurt Hensel in 1897, where "closeness" is measured not by ordinary distance but by divisibility by a prime p. In the p-adic world, every number has a clean decomposition based on powers of p, which creates the illusion that everything factors nicely.

But the illusion breaks. Primes exist. The number 2 cannot be written as a product of two numbers both greater than 1. Neither can 3, or 5, or 7, or the infinitely many primes stretching to infinity. The conjecture, elegant as it sounded, was false.

## WHY IT MATTERS

The story might seem like a simple mistake — but the way it was caught illuminates a revolution in mathematics. The conjecture was not disproven by a human mathematician staring at a blackboard. It was caught by a computer — specifically, by a formal proof assistant called Lean 4, running a vast mathematical library called Mathlib.

When the conjecture was fed into Lean, the system could not prove it. Not because the software wasn't powerful enough, but because the statement was genuinely false. This is the promise of formal verification: it doesn't just check proofs, it catches lies. In a world where mathematical results underpin the security of the internet, the safety of autonomous vehicles, and the reliability of AI systems, the ability to mechanically verify claims is not academic — it's essential.

The corrected theorem — that every *composite* number greater than one factors non-trivially — was proven in a single line of Lean code. The proof extracts the *minimal factor* of a composite number (the smallest divisor greater than 1), then shows that both this factor and the quotient exceed 1. Clean, mechanical, indisputable.

For cryptography, this distinction between primes and composites is everything. RSA encryption works precisely because primes cannot be factored, while their products can be — but finding the factors is computationally expensive. The corrected theorem tells us that the factors *exist* (an existential guarantee), but says nothing about how quickly we can *find* them. That gap — between existence and computation — is where all of modern cryptography lives.

## THE BEAUTY

There is an unexpected elegance in the failure of the original conjecture. The p-adic numbers, with their fractal geometry and non-Archimedean metric (where a million can be "smaller" than one), seem to promise a world where every number decomposes cleanly. And in a sense they do — but the decomposition is by *valuation*, not by *multiplication*. The p-adic valuation tells you how many times a prime p divides a number, painting a beautiful landscape of divisibility. But this landscape is a *fingerprint* of the number, not a *factorization*.

The corrected theorem captures what remains true after the false hope is stripped away: the fundamental theorem of arithmetic guarantees that composites factor, and the minimal factor provides a constructive witness. The proof is three lines. The insight took centuries.

## LOOKING AHEAD

This episode points toward several frontiers:

**Formal mathematics at scale.** As mathematical libraries like Mathlib grow — now containing hundreds of thousands of formally verified theorems — the bar for publishing new results will rise. Journals may one day require machine-checked proofs alongside traditional arguments. The era of "trust me, I checked it" is ending.

**AI-assisted conjecture and verification.** The original conjecture was generated algorithmically, tested against a formal verifier, and corrected automatically. This loop — conjecture, verify, correct — could accelerate mathematical discovery by orders of magnitude, with AI systems proposing thousands of candidates per hour and proof assistants filtering out the false ones.

**P-adic methods in computation.** While the naive "p-adic factoring oracle" doesn't work, genuine p-adic techniques do play roles in computational number theory. Hensel's lemma — which lifts solutions modulo p to solutions modulo higher powers of p — is used in algorithms for polynomial factoring, and p-adic methods appear in modern approaches to the Birch and Swinnerton-Dyer conjecture. The dream of a p-adic factoring breakthrough is not dead, merely dormant.

## CLOSING

Mathematics is often described as the discovery of eternal truths. But this story suggests something more interesting: mathematics is also the discovery of eternal *falsehoods*. Knowing what is NOT true is as valuable as knowing what is. The primes — those indivisible atoms of arithmetic — stand as sentinels guarding the boundary between structure and chaos, between what can be decomposed and what must remain whole.

Ramanujan, looking at the number 1729, saw hidden structure where Hardy saw none. A computer, looking at the same theorem, saw hidden falsity where its creators expected truth. Both moments — the human flash of insight and the mechanical verification of failure — are acts of mathematical seeing. And in that seeing, we glimpse something universal: the deep, stubborn honesty of numbers, which care nothing for our theories and reward only our attention.

*The formal proof is verified in Lean 4 with Mathlib v4.28.0, using only the standard axioms: propext, Classical.choice, and Quot.sound.*
