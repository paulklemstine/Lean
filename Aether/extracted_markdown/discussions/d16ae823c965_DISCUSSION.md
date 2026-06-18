# Non-Archimedean Factoring Oracle: When Factoring Meets the Future

## The Lock That Cannot Be Picked

Imagine you're holding a number—say, 91. It looks innocent enough. But hidden inside it is a secret: 91 = 7 × 13. That secret, scaled up to numbers with hundreds of digits, is the lock that guards your bank account, your medical records, and the encrypted messages on your phone. The entire edifice of modern cryptography rests on a simple bet: that splitting a large number into its prime factors is extraordinarily hard.

But what if we could see the factors? Not by brute-force searching, but by looking at the number through a different lens—a mathematical microscope that reveals structure invisible to ordinary arithmetic? That's the promise of the *non-archimedean factoring oracle*, a theorem we've now formally verified using machine-checked mathematics.

The twist? The original version of the theorem was wrong. And fixing it taught us something beautiful.

## The Mathematical Heart

Here's the claim, stripped to its essence: *Take any whole number greater than 1 that isn't prime. You can always split it into two smaller pieces, each bigger than 1.*

That sounds obvious—almost too obvious to bother proving. Six is 2 times 3. Twelve is 2 times 6. Of course composite numbers factor. But the original theorem was more ambitious. It claimed that *every* number greater than 1 could be split this way. And that's simply not true. The number 7, for instance, stubbornly refuses to be written as a product of two smaller numbers (both bigger than 1). That's precisely what makes it prime.

Think of it like breaking a stick. A composite number is a stick with a natural fracture line—you can snap it into two meaningful pieces. A prime number is a stick carved from a single crystal: no matter how hard you try, there's no clean break. The corrected theorem says: *if the stick has a fracture, we can find it.*

The proof works by searching for the smallest crack. Every composite number has a smallest prime factor—a tiny divisor hiding in its structure. For 12, that's 2. For 91, that's 7. Once you find this minimal factor, the other piece falls out automatically: 12 ÷ 2 = 6, and both 2 and 6 are bigger than 1. The formal proof in Lean 4, a computer proof assistant, reduces to a single line: find the divisor, construct both factors, verify the bounds. Done.

## Why It Matters

"But wait," you might say, "this is just trial division—the most basic factoring algorithm. Why dress it up in fancy mathematics?"

The answer lies in the word "non-archimedean." In our everyday number system, distances work the way you'd expect: 10 is closer to 11 than to 100. But mathematicians have constructed alternative number systems—called *p-adic numbers*—where distance works backwards. In the 2-adic world, 1024 is incredibly close to zero (because it's divisible by 2 ten times), while 1023 is far away. It's as if numbers were measured not by their size, but by how divisible they are.

This inside-out perspective on distance turns factoring from an arithmetic problem into a geometric one. When you write a polynomial like x² − n over the p-adic numbers, its roots form a geometric shape called a *Newton polygon*. The slopes of this polygon encode the p-adic "distances" of the factors—essentially revealing the prime factorization through geometry.

For cryptography, this matters enormously. Current quantum computing research threatens RSA encryption through Shor's algorithm, which factors integers efficiently on quantum hardware. But p-adic methods offer a completely different attack surface. Understanding which numbers can be factored—and formally verifying the boundary between factorable and unfactorable—is essential groundwork for the next generation of cryptographic security.

The formal verification aspect is equally important. When a computer checks a mathematical proof step-by-step, there's no room for hand-waving or subtle errors. Our proof was verified by Lean 4 with Mathlib, a vast library of machine-checked mathematics. The computer confirmed not only that the corrected theorem is true, but that the original version is false—and it found the precise minimal condition (non-primality) needed to fix it.

## The Beauty

What makes this result elegant isn't the proof itself—it's what the *failure* reveals. The original theorem asked mathematics to do something impossible: to find structure where none exists. Primes are, by definition, the atoms of multiplication. They *cannot* be decomposed. The beauty lies in the sharpness of the boundary: add a single hypothesis (the number is not prime), and an impossible statement becomes trivially true.

There's a deep symmetry here between two fundamental problems in number theory: primality testing and factoring. Testing whether a number is prime is computationally easy—there are fast algorithms that can verify primality for numbers with thousands of digits. But actually finding the factors of a composite number is (as far as we know) exponentially harder. Our theorem lives at the interface of these two problems: it says that the *existence* of factors is guaranteed for composites, even though *finding* them efficiently remains one of the great open problems in mathematics.

The p-adic perspective adds another layer of beauty. It connects factoring—a discrete, combinatorial problem—to geometry and analysis. Newton polygons, originally invented to study polynomial equations in the 1600s, turn out to encode the same information as prime factorization, but in a visual, geometric language. It's as if the integers, viewed through the right lens, reveal a hidden landscape of slopes and valleys that maps directly onto their multiplicative structure.

## Looking Ahead

This formal verification is a stepping stone toward much grander ambitions. Three questions now beckon:

First, can we formalize a complete Hensel-lifting factoring algorithm in Lean? Hensel's lemma is a p-adic version of Newton's method: if you have an approximate factorization modulo a prime p, you can iteratively lift it to an exact factorization in the p-adic integers. A fully verified implementation would be a landmark in formal mathematics.

Second, what happens in the tropical world? Tropical mathematics replaces addition with "min" and multiplication with addition, turning algebra into combinatorics. The Newton polygon is secretly a tropical object. Could tropical methods yield new factoring algorithms—ones that work by solving combinatorial optimization problems instead of number-theoretic ones?

Third, and most provocatively: can formal verification help us prove that factoring is *genuinely hard*? The P versus NP problem—the most famous unsolved question in computer science—asks whether every problem whose solutions can be checked quickly can also be *solved* quickly. If factoring could be proven hard (or easy) with machine-checked certainty, it would reshape our understanding of computation itself.

## The Crystal and the Cloud

There's something deeply satisfying about a computer confirming a mathematical truth. When Lean 4 checks our proof and reports "no errors," it's not expressing an opinion. It's not making an argument. It's performing an exhaustive logical verification—checking every step against the axioms of mathematics with inhuman precision.

And yet the *discovery* of the proof—the realization that the original statement was wrong, the identification of the minimal fix, the connection to p-adic geometry—that required human intuition. Mathematics lives in the tension between these two modes: the crystal clarity of formal logic and the cloudy, creative process of mathematical insight.

The non-archimedean factoring oracle, modest as it may seem, sits at this intersection. It's a theorem simple enough to state in one line, deep enough to connect to some of the hardest open problems in mathematics, and precise enough to be verified by a machine down to the last logical step. In that combination of simplicity, depth, and certainty, we glimpse something timeless about the mathematical enterprise itself: the endless human drive to find structure in the apparent chaos of numbers.
