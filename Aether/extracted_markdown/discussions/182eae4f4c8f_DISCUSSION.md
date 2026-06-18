# The Hidden Structure of Fibonacci Primes

*How a 113-year-old theorem connects tropical geometry, tree algorithms, and the secret lives of prime numbers*

---

In 1913, a young American mathematician named Robert Carmichael proved something remarkable about the Fibonacci sequence — those famous numbers 1, 1, 2, 3, 5, 8, 13, 21, 34, ... where each term is the sum of the two before it. His theorem says that starting from the 13th Fibonacci number, every term in the sequence has at least one prime factor that has never appeared before.

Think about that for a moment. The 13th Fibonacci number is 233, which happens to be prime — and it's the first time 233 has shown up as a factor. The 14th is 377 = 13 × 29, and while 13 already divided F(7), the prime 29 is brand new. The 15th is 610 = 2 × 5 × 61, and 61 makes its debut here.

Carmichael's theorem guarantees this pattern continues forever. No matter how far along the sequence you go, fresh primes keep appearing.

## Why Should Anyone Care?

At first glance, this might seem like a curiosity about a specific sequence. But Fibonacci numbers are woven into the fabric of mathematics in ways that connect to some of the deepest ideas in modern number theory.

The key is the *entry point* — for any prime p, the entry point α(p) is the smallest positive n where p divides F(n). For example, α(2) = 3 (since 2 first divides F(3) = 2), and α(7) = 8 (since 7 first divides F(8) = 21).

A beautiful identity ties everything together: the greatest common divisor of F(m) and F(n) equals F(gcd(m,n)). This means that if a prime p divides both F(m) and F(n), it must also divide F(gcd(m,n)). The entry point of p therefore divides every n for which p divides F(n).

## The Computer-Assisted Proof

Our formalization takes a hybrid approach that would have seemed like science fiction in Carmichael's day. For every value of n from 13 to 10,000, we have a computer verify — with mathematical certainty — that F(n) has a primitive prime divisor.

The algorithm works by computing what we call the "coprime part" of F(n). Start with F(n) itself. For each proper divisor d of n, remove from F(n) every prime factor it shares with F(d). Whatever remains must be a primitive contribution — primes whose entry point is exactly n.

For F(14) = 377, the proper divisors of 14 are 1, 2, and 7. We check:
- F(1) = 1 contributes nothing
- F(2) = 1 contributes nothing  
- F(7) = 13 shares the factor 13 with 377

After removing 13, we're left with 29 — the primitive prime divisor.

This computation, repeated 10,000 times with numbers that grow exponentially large (F(10000) has over 2,000 digits), is verified by Lean's `native_decide` tactic — a proof strategy where the computer executes the algorithm and certifies the result as a mathematical theorem.

## The Tropical Connection

What does this have to do with tropical geometry? The tropical semiring replaces ordinary addition with "min" and ordinary multiplication with "plus." In this exotic arithmetic, the Fibonacci-like structures take on new meaning.

Consider the Berggren tree, which generates all primitive Pythagorean triples starting from (3, 4, 5). Each node branches into three children via specific matrix transformations. The p-adic valuations of numbers along these paths create matrices whose "tropical rank" — a measure of complexity in the min-plus world — reveals information about prime factorization.

A natural conjecture was that the tropical rank of these valuation matrices equals the number of distinct prime factors of the hypotenuse. Our formalization *disproves* this conjecture with machine-verified counterexamples: for N = 169 = 13², the tropical rank is at least 2 while the number of distinct prime factors is just 1.

## What Remains

The case of Carmichael's theorem for n beyond 10,000 remains open in our formalization. The mathematical proof exists — it involves showing that the "cyclotomic Fibonacci numbers" (products over primitive roots of unity) grow like φ^{φ(n)}, where φ is the golden ratio and φ(n) is Euler's totient function. For n ≥ 13, this growth ensures the result exceeds 1.

Formalizing this growth bound requires infrastructure that doesn't yet exist in Lean's mathematical library: the Binet formula connecting Fibonacci numbers to the golden ratio, Möbius inversion for multiplicative arithmetic functions, and precise estimates on products over roots of unity. Building this infrastructure is an active area of work in the formalized mathematics community.

## The Bigger Picture

Carmichael's theorem is part of a broader pattern. The Fibonacci sequence is a special case of a *Lucas sequence*, and analogous primitive divisor theorems hold for many such sequences. These results connect to the Langlands program — one of the most ambitious frameworks in modern mathematics — through the representation theory of GL₂.

In the tropical world, these connections take on a combinatorial flavor. The Hecke operators of classical number theory become max-plus linear maps, eigenforms become functions shifted by additive constants, and the trace formula becomes a statement about tropical convolutions.

The formalization of these ideas — turning centuries of mathematical insight into machine-verified proofs — is not just an exercise in rigor. It's a new way of doing mathematics, where computers and humans collaborate to push the boundaries of what we can know with absolute certainty.

---

*The full formalization, including all proofs and counterexamples, is available in the accompanying Lean 4 project.*
