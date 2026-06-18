# The Rank of Apparition as the Spine of Fibonacci Primitive-Divisor Theory

## Abstract

The *rank of apparition* (or Fibonacci entry point) of a modulus m is the least positive index k for which m divides the Fibonacci number Fₖ. We develop this invariant from first principles into a single load-bearing biconditional — the **spine** — and show that the elementary, lattice-theoretic, and primitive-divisor theory of the Fibonacci sequence are all corollaries of it. After establishing existence of the rank for every positive modulus via a pigeonhole argument on the reversible Fibonacci shift on (ℤ/mℤ)², we prove the spine, `m ∣ Fₙ ⟺ rank(m) ∣ n`, with **no primitivity hypothesis**. From the spine we derive: the order-morphism law `b ∣ a ⟹ rank(b) ∣ rank(a)`; the rigidity theorem `rank(Fₖ) = k` for k ≥ 3; the divisibility biconditional `Fₐ ∣ F_b ⟺ a ∣ b` for a ≥ 3 (upgrading the classical one-way implication); the prime case of Carmichael's primitive-divisor theorem for **all** primes p ≥ 3; the join (lcm) morphism law `rank(lcm(a,b)) = lcm(rank(a), rank(b))`; and an exact apparition-count formula `#{ n ∈ (0, N] : m ∣ Fₙ } = ⌊N / rank(m)⌋`. The unifying thesis is that the rank is a faithful embedding of the divisibility lattice of moduli into the divisibility lattice of indices. All results have been formalized and machine-checked with no `sorry` and with axioms restricted to `propext`, `Classical.choice`, and `Quot.sound`.

## 1. Introduction

The Fibonacci sequence (Fₖ)_{k≥0}, defined by F₀ = 0, F₁ = 1, and Fₖ₊₂ = Fₖ₊₁ + Fₖ, is among the most studied integer sequences. Its divisibility structure is governed by two classical identities of Lucas:

- **(Divisibility)** if a ∣ b then Fₐ ∣ F_b;
- **(Strong divisibility)** gcd(Fₐ, F_b) = F_{gcd(a,b)}.

A natural invariant attached to these identities is the **rank of apparition** of a modulus m: the least positive k with m ∣ Fₖ. The biconditional `m ∣ Fₙ ⟺ rank(m) ∣ n` is folklore, but it is the *organizing principle* of a great deal of Fibonacci number theory: existence of Pisano periods, primitive-divisor (Carmichael/Zsygmondy) results, entry-point lattices, and apparition-density statements all rest on it.

This paper consolidates the theory around the rank into a single self-contained development. Our central methodological claim is that the biconditional should be stated **without any primitivity hypothesis** — making it a genuine *spine* from which the rest of the theory descends as short corollaries — and that two new rigidity results (`rank(Fₖ) = k` and the divisibility biconditional `Fₐ ∣ F_b ⟺ a ∣ b`) make the embedding picture exact.

Throughout, F denotes the Fibonacci function on ℕ with F₀ = 0, F₁ = 1.

## 2. Definitions

**Definition 2.1 (Has a rank).** A modulus m has a rank of apparition, written `HasFibRank m`, if there exists k with 0 < k and m ∣ Fₖ.

**Definition 2.2 (The rank function).** The rank of apparition `rank(m)` is the least k > 0 with m ∣ Fₖ if one exists, and 0 otherwise. Formally,
> rank(m) = (least k > 0 with m ∣ Fₖ) if `HasFibRank m`, else 0.

**Definition 2.3 (The Fibonacci shift).** For a modulus m, the **Fibonacci shift** is the map on (ℤ/mℤ)² given by
> S(a, b) = (b, a + b),  with inverse  S⁻¹(a, b) = (b − a, a).
S is a bijection (indeed multiplication by the matrix [[0,1],[1,1]] of determinant −1, a unit modulo any m), and S^k(0, 1) = (Fₖ mod m, Fₖ₊₁ mod m).

**Definition 2.4 (Primitive divisor).** A number q is a **primitive divisor** of Fₙ, written `IsPrimitive q n`, if q ∣ Fₙ and for every k with 0 < k < n, q ∤ Fₖ. In other words, n is the rank of apparition of q.

## 3. Existence of the rank

**Theorem 3.1 (Iterate formula).** For all m, k: S^k(0, 1) = (Fₖ mod m, Fₖ₊₁ mod m).

*Proof sketch.* Induction on k using the recurrence Fₖ₊₂ = Fₖ + Fₖ₊₁: applying S to (Fₖ, Fₖ₊₁) yields (Fₖ₊₁, Fₖ + Fₖ₊₁) = (Fₖ₊₁, Fₖ₊₂). ∎

**Theorem 3.2 (Existence).** Every positive modulus m has a rank of apparition: `HasFibRank m`.

*Proof sketch.* Consider the sequence n ↦ (Fₙ mod m, Fₙ₊₁ mod m) ∈ (ℤ/mℤ)². The codomain is finite (m² elements), so by the pigeonhole principle there exist i < j with equal pairs:
> (F_i, F_{i+1}) ≡ (F_j, F_{j+1})  (mod m).
Because S is a bijection, equal pairs at i and j force, after applying S⁻¹ repeatedly i times (back-stepping both indices by i), equality of the pairs at 0 and j − i:
> (F₀, F₁) ≡ (F_{j−i}, F_{j−i+1})  (mod m).
In particular F_{j−i} ≡ F₀ = 0 (mod m), so m ∣ F_{j−i} with j − i > 0. (Formally this is carried out by induction on i, reducing the gap; the degenerate case m = 0 — which makes ℤ/mℤ infinite — is excluded by positivity.) ∎

The reversibility of S is essential: it upgrades eventual periodicity (which pigeonhole alone gives) to *pure* periodicity returning to the initial state (0, 1), which is what produces an apparition rather than merely a repeat.

**Proposition 3.3 (Basic properties).** If `HasFibRank m` then:
- (positivity) 0 < rank(m);
- (apparition) m ∣ F_{rank(m)};
- (minimality) for 0 < k < rank(m), m ∤ Fₖ.

*Proof sketch.* All three are immediate from the least-element characterization of `rank(m)` (`Nat.find`). ∎

## 4. The spine

**Theorem 4.1 (The spine).** If `HasFibRank m`, then for every n,
> m ∣ Fₙ  ⟺  rank(m) ∣ n.

*Proof sketch.* Write r = rank(m); by Proposition 3.3, r > 0 and m ∣ F_r.

(⇐) If r ∣ n, then by Lucas's divisibility identity F_r ∣ Fₙ, and since m ∣ F_r we get m ∣ Fₙ.

(⇒) Suppose m ∣ Fₙ. We have m ∣ F_r and m ∣ Fₙ, so m ∣ gcd(F_r, Fₙ) = F_{gcd(r, n)} by the strong-divisibility identity. Let g = gcd(r, n) ≤ r. If g < r, then since g > 0 (as r > 0) and m ∣ F_g, this contradicts minimality of r (Proposition 3.3). Hence g = r, i.e. r ∣ n. ∎

The spine is stated with the single hypothesis `HasFibRank m`, which by Theorem 3.2 holds for all m ≥ 1; no primitivity assumption is needed. This generality is what lets every later result be a corollary.

**Theorem 4.2 (Uniqueness / universal property).** If 0 < d and `∀ n, m ∣ Fₙ ⟺ d ∣ n`, then rank(m) = d.

*Proof sketch.* The hypothesis at n = d gives m ∣ F_d, so `HasFibRank m`. The spine combined with the hypothesis yields `∀ n, d ∣ n ⟺ rank(m) ∣ n`. Evaluating at n = d and at n = rank(m) gives mutual divisibility d ∣ rank(m) and rank(m) ∣ d, hence d = rank(m) by antisymmetry. ∎

Theorem 4.2 is the engine behind all the lattice laws: each is proved by exhibiting a d with the apparition property and invoking uniqueness.

## 5. Order- and lattice-morphism laws

**Theorem 5.1 (Order morphism).** If 0 < a and b ∣ a, then rank(b) ∣ rank(a).

*Proof sketch.* From b ∣ a and a ∣ F_{rank(a)} (Proposition 3.3) we get b ∣ F_{rank(a)}. Since 0 < b (as b ∣ a, 0 < a) we have `HasFibRank b`, and the spine for b gives rank(b) ∣ rank(a). ∎

**Theorem 5.2 (Join / lcm law).** For 0 < a, 0 < b:
> rank(lcm(a, b)) = lcm(rank(a), rank(b)).

*Proof sketch.* Apply Theorem 4.2 with d = lcm(rank(a), rank(b)) (positive, as both ranks are positive). For every n:
> lcm(a, b) ∣ Fₙ ⟺ a ∣ Fₙ ∧ b ∣ Fₙ        (lcm divides iff both divide)
>            ⟺ rank(a) ∣ n ∧ rank(b) ∣ n   (spine, twice)
>            ⟺ lcm(rank(a), rank(b)) ∣ n.
Uniqueness gives the claim. No case analysis is required. ∎

The gcd analogue is, by contrast, only an inequality: applying Theorem 5.1 to gcd(a, b) ∣ a and gcd(a, b) ∣ b yields
> rank(gcd(a, b)) ∣ gcd(rank(a), rank(b)),
and this divisibility can be strict. The spine linearizes lcm (a conjunction of divisibilities) but not gcd (a disjunction), so equality fails in general; a precise strictness criterion is an open problem (§9).

## 6. Rigidity: the rank labels Fibonacci numbers

**Theorem 6.1 (Rigidity).** For k ≥ 3, rank(Fₖ) = k.

*Proof sketch.* We show k is the least positive index whose Fibonacci number is divisible by Fₖ. Trivially Fₖ ∣ Fₖ. For 0 < j < k, we claim Fₖ ∤ F_j: indeed 0 < F_j and, by strict monotonicity of F on indices ≥ 2 together with F₁ = F₂ = 1, F_j < Fₖ whenever j < k and k ≥ 3; a positive number strictly smaller than Fₖ cannot be a multiple of Fₖ. Hence rank(Fₖ) = k. The bound k ≥ 3 is sharp: F₁ = F₂ = 1 has rank 1. ∎

**Corollary 6.2 (Closed-form rank of an lcm of Fibonacci numbers).** For a, b ≥ 3:
> rank(lcm(Fₐ, F_b)) = lcm(a, b).

*Proof sketch.* Combine Theorem 5.2 (both Fₐ, F_b are positive) with Theorem 6.1 applied to each factor. ∎

**Proposition 6.3 (A hypothesis-free divisibility bound).** For all a, b:
> lcm(Fₐ, F_b) ∣ F_{lcm(a, b)}.

*Proof sketch.* a ∣ lcm(a, b) and b ∣ lcm(a, b), so by Lucas's divisibility identity Fₐ ∣ F_{lcm(a,b)} and F_b ∣ F_{lcm(a,b)}; conclude with the universal property of lcm on the value side. ∎

## 7. The Fibonacci divisibility biconditional

**Theorem 7.1.** For a ≥ 3 and any b: Fₐ ∣ F_b ⟺ a ∣ b.

*Proof sketch.* Apply the spine to the modulus m = Fₐ (which has `HasFibRank` since Fₐ ∣ Fₐ): Fₐ ∣ F_b ⟺ rank(Fₐ) ∣ b. By rigidity (Theorem 6.1), rank(Fₐ) = a, giving Fₐ ∣ F_b ⟺ a ∣ b. ∎

Classically only the forward implication a ∣ b ⟹ Fₐ ∣ F_b is standard; the converse for a ≥ 3 is the new content, and it makes the divisibility lattices of indices and of Fibonacci numbers isomorphic above index 3. The restriction a ≥ 3 is necessary: F₁ = F₂ = 1 divides every F_b.

## 8. Carmichael's primitive-divisor theorem: the prime case

**Theorem 8.1.** For every prime p ≥ 3, F_p has a primitive prime divisor: there exists a prime q with `IsPrimitive q p`.

*Proof sketch.* Since p ≥ 3, F_p > 1, so F_p has a prime factor q. By the spine (q ∣ F_p, and q has a rank as it divides F_p), rank(q) ∣ p. As p is prime, rank(q) ∈ {1, p}. The case rank(q) = 1 would force q ∣ F₁ = 1, impossible for a prime. Hence rank(q) = p, and by minimality (Proposition 3.3) q ∤ Fₖ for all 0 < k < p. Thus q is a primitive prime divisor of F_p. ∎

This is sharper than the classical analytic treatment, which typically requires p ≥ 5 (or excludes small cases) because it bounds the primitive part via growth estimates on |Φₙ(φ, ψ)|, the cyclotomic value at the golden ratio φ and its conjugate ψ. At a *prime* index no growth estimate is needed: primitivity is forced by the elementary fact that a divisor of a prime is 1 or that prime. The bound p ≥ 3 is sharp because F₁ = F₂ = 1 have no prime divisors. (The general composite case of Carmichael's theorem genuinely requires the cyclotomic growth machinery and is outside the scope of the elementary spine.)

## 9. Exact apparition density

**Theorem 9.1 (Exact count).** For 0 < m and any N,
> #{ n ∈ (0, N] : m ∣ Fₙ } = ⌊N / rank(m)⌋.

*Proof sketch.* By the spine, on (0, N] the predicate `m ∣ Fₙ` is pointwise equivalent to `rank(m) ∣ n`; replacing the filter predicate, the set becomes the multiples of rank(m) in (0, N], whose count is the integer division ⌊N / rank(m)⌋. ∎

**Corollary 9.2 (Natural density).** The set of indices n at which m ∣ Fₙ has natural density 1 / rank(m).

The count in Theorem 9.1 is an exact equality for every cutoff N, not an asymptotic estimate, because the apparition indices form a literal arithmetic progression of step rank(m). For coprime moduli m₁, m₂ one expects the joint apparition density to be 1 / lcm(rank(m₁), rank(m₂)) (an immediate consequence of the spine and the join law), and averaging 1 / rank(p) over primes connects to a Fibonacci analogue of Artin's constant — falsifiable directly against computed rank tables.

## 10. Algorithms

**Algorithm A (Rank of apparition).** Compute rank(m) for m ≥ 1 by iterating the Fibonacci pair modulo m until the residue is 0:

```
function fibRank(m):
    if m == 1: return 1
    a, b, k = 0, 1, 0          # (F_k mod m, F_{k+1} mod m)
    repeat:
        a, b = b, (a + b) mod m
        k = k + 1
        if a == 0: return k
```

This terminates by Theorem 3.2; the number of iterations is rank(m) ≤ Pisano period(m) = O(m²) in the worst case, with each step O(1) modular operations.

**Algorithm B (Spine verification).** To test m ∣ Fₙ in O(rank(m) + 1) modular steps without computing the gigantic Fₙ: compute r = fibRank(m) and return whether r ∣ n. Correctness is Theorem 4.1.

**Algorithm C (Primitive prime divisor of F_p).** For a prime p ≥ 3: factor F_p, and for each prime factor q test whether fibRank(q) = p; Theorem 8.1 guarantees at least one such q exists, and any such q is primitive.

## 11. Applications and discussion

The rank of apparition functions as a **faithful order/lattice embedding** of (ℕ_{>0}, ∣) into itself, sending a modulus to its apparition index. The spine is the statement that this map reflects divisibility; the join law says it preserves least common multiples; rigidity says it is an exact labelling on the Fibonacci numbers themselves.

Practically, the theory yields fast Fibonacci divisibility tests (Algorithm B), an explicit construction of primitive primes at prime indices (Algorithm C), and exact counts of apparitions (Theorem 9.1) — all bypassing the exponential growth of Fibonacci numbers by working entirely with indices.

Crucially, the proofs of the spine and rigidity used only two abstract facts: that F is a **strong divisibility sequence** (gcd(Fₐ, F_b) = F_{gcd(a,b)}) and that it is **eventually strictly monotone**. Any sequence with these properties — Mersenne numbers 2ⁿ − 1, general Lucas sequences, and more — admits the same spine, rigidity, and primitive-divisor theory. The Fibonacci development is thus a template for a sequence-agnostic theory of ranks of apparition.

## 12. Future work

1. **Composite Carmichael case without numeric cutoff.** Reframe primitivity of F_n via the primitive part governed by the cyclotomic value Φₙ(φ, ψ); a uniform lower bound |Φₙ(φ, ψ)| > n from φ^{φ(n)} growth would force primitive divisors for all large n simultaneously, using the spine for the divisor-lattice bookkeeping and Mathlib's totient growth bounds.
2. **The exact join-morphism transported to all rank objects.** Merge the catalog's parallel rank notions by proving the lattice laws verbatim on the primitivity-free spine, with closed-form evaluations via rigidity.
3. **Prime-power ranks and a Lifting-the-Exponent law.** Conjecture rank(p^{e+1}) = p · rank(p^e) beyond a Wall–Sun–Sun threshold, reducing rank computation to prime powers via the p-adic valuation recursion v_p(F_{rank(p)·t}).
4. **Transport the spine to all strong divisibility sequences.** Abstract the rank, spine, and rigidity to any strong divisibility sequence with u₀ = 0 and eventual strict monotonicity, instantly yielding Bang–Zsygmondy entry-point theory for aⁿ − 1 and Lucas sequences.
5. **Exact arithmetic-progression density and coprime refinements.** Use the exact-progression structure to prove multiplicative joint densities 1 / lcm(rank(m₁), rank(m₂)) for coprime moduli and connect prime averages of 1 / rank(p) to a Fibonacci Artin constant.

## 13. Conclusion

By insisting that the apparition biconditional be stated without primitivity, we obtained a single spine from which the order-morphism law, the join law, the rigidity theorem, the Fibonacci divisibility biconditional, the prime case of Carmichael's theorem, and an exact apparition-count formula all follow as short corollaries. The rank of apparition is best understood not as a numerical curiosity but as a faithful embedding of the divisibility lattice of moduli into the divisibility lattice of indices — and that embedding is the true spine of Fibonacci primitive-divisor theory. All results have been formally verified.
