# Non-Archimedean Factoring Oracle: When Factoring Meets the Future

## LEDE

Imagine you hold a number — say 91 — and someone asks you to break it apart. Is it prime, an atomic building block of arithmetic? Or can it be split into smaller pieces? You might try dividing by 2, then 3, then 5, then 7 — and there it is: 91 = 7 × 13. Two primes, hiding in plain sight.

Now imagine a different world. Instead of our familiar decimal system, you view 91 through a p-adic lens — a strange, fractal-like number system where "closeness" is measured not by how near two numbers sit on a ruler, but by how many times a prime *p* divides their difference. In this alien arithmetic, 91 looks completely different. Its factors practically announce themselves.

This is the idea behind the *non-archimedean factoring oracle* — a theorem that guarantees every composite number can be cracked open into non-trivial pieces. It sounds obvious, almost trivially true. But proving it with mathematical certainty — and discovering that the original conjecture was subtly *wrong* — reveals depths that even experienced mathematicians find surprising.

## THE MATHEMATICAL HEART

Think of integers greater than 1 as Lego structures. Some are single bricks — the primes. You can't break a prime into smaller pieces without cheating (using 1 as a factor, which doesn't really count). The number 7 is a single brick. So is 2, and 101, and the enormous primes that guard your bank transactions.

But composite numbers? They're assembled structures. The number 12 is built from 4 and 3, or equivalently from 2 and 6. The factoring oracle theorem says: *if a number isn't a single brick, you can always pull it apart into at least two non-trivial pieces.*

Here's where it gets interesting. The original version of this theorem — inspired by exotic p-adic number theory — claimed that *every* number greater than 1 could be factored this way. But that's false! Primes exist, and they can't be split. It's like claiming every molecule can be broken into smaller molecules — atoms stubbornly refuse.

The corrected theorem adds a single condition: the number must not be prime. With that patch, the result becomes true, provable, and — crucially — *machine-verified*. A computer checked every logical step, from axioms to conclusion, leaving no room for human error.

The proof itself is elegantly simple. Given a composite number *n*, find its smallest factor *k* (which must be at least 2, since *n* isn't prime). Then *n* = *k* × (*n*/*k*), and both pieces are strictly larger than 1. The smallest factor is at least 2 (it's prime), and the quotient *n*/*k* must also exceed 1 (otherwise *n* = *k*, which would make *n* prime — a contradiction).

## WHY IT MATTERS

"But wait," you might object, "everyone knows composite numbers can be factored. Why formalize something so obvious?"

Three reasons.

**First, for cryptography.** The security of RSA encryption — which protects everything from your email to national defense communications — rests on the assumption that factoring large numbers is *computationally hard*. Our theorem doesn't say factoring is easy; it says a factorization always *exists*. This existence guarantee is the foundation on which complexity-theoretic hardness results are built. You can't study how hard it is to find something if you're not sure it's there.

**Second, for formal verification.** As software controls more of our critical infrastructure — nuclear reactors, aircraft, medical devices — we need mathematical guarantees that are beyond human error. Machine-checked proofs like this one set the standard. The Lean theorem prover verified our proof using only three axioms: propositional extensionality, the axiom of choice, and quotient soundness. Every step is accountable.

**Third, for intellectual honesty.** The original conjecture was wrong. It took careful formalization to catch the error — a missing hypothesis that would have slipped past most informal reviews. This is formal mathematics doing what it does best: catching the mistakes that human intuition glosses over.

## THE BEAUTY

There is something deeply satisfying about the proof's structure. It mirrors a fundamental pattern in mathematics: to understand a whole, find a minimal piece.

The key move is finding the *smallest* factor. Not just any factor — the smallest one. This is `Nat.minFac` in Lean's Mathlib library, and it's elegant for a reason: the smallest factor of any composite number is always prime. This gives you a clean decomposition in one step.

The p-adic inspiration adds another layer of beauty. In the p-adic world, every integer lives simultaneously in infinitely many "parallel" number systems — one for each prime *p*. The p-adic valuation v_p(n) counts how many times *p* divides *n*, and when you factor *n* = *a* × *b*, the valuations add: v_p(a) + v_p(b) = v_p(n). It's as if factoring a number is like splitting a chord into harmonics — each prime frequency contributes independently.

The connection to Newton polygons — geometric objects that encode the p-adic behavior of polynomials — hints at deeper waters. Hensel's lemma, the p-adic analog of Newton's method, shows that approximate factorizations can be "lifted" to exact ones. Our simple theorem captures the shadow of this lifting principle: if a number is composite, an exact factorization exists.

## LOOKING AHEAD

This formalization opens several doors.

The most immediate is *certified factoring algorithms*. Can we formally verify not just that factors exist, but that specific algorithms — trial division, Pollard's rho, the quadratic sieve, the general number field sieve — actually find them? Each algorithm embodies a different mathematical insight, and verifying their correctness would strengthen our confidence in the cryptographic systems that depend on their presumed difficulty.

Further out, there's the quantum frontier. Shor's algorithm factors integers in polynomial time on a quantum computer, threatening RSA's security. Formalizing Shor's algorithm in Lean — including the number-theoretic components like continued fractions and order-finding — would be a landmark achievement in formal verification.

And then there are the truly speculative connections. Can tropical geometry — a "shadow" of algebraic geometry where addition replaces multiplication — illuminate new factoring strategies? Can the Berggren tree, a ternary structure that generates all Pythagorean triples, be adapted to navigate the space of factor pairs? These are open questions, and the formal foundations we've laid make them precise enough to pursue.

## CLOSING

Mathematics is often described as the art of the obvious made rigorous. The factoring oracle theorem exemplifies this perfectly. Everyone "knows" that composite numbers can be factored. But to *prove* it — to state it precisely, catch a subtle error in the original formulation, and verify every step with a machine — is to transform intuition into certainty.

In an age of deepfakes and misinformation, there is something reassuring about a proof checked by a computer down to its axioms. Three axioms, one theorem, zero doubt. The number 91 is 7 times 13, and mathematics can prove it must be so — not because we checked, but because the structure of arithmetic demands it.

The p-adic lens that inspired this theorem reminds us that numbers are richer than they appear. Viewed from the right angle, every composite number carries within it the seeds of its own decomposition. The factoring oracle simply reads what was always written there.
