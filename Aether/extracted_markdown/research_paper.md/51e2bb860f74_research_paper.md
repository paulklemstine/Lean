# Composite-Index Fibonacci Primitive Divisors via Entry-Point Divisibility and GCD Control

## Abstract

We present a formalization of the entry-point bridge for Fibonacci primitive prime divisors in Lean 4, building a reusable interface between the statement "a prime divides F(n)" and the arithmetic consequence "that prime's entry point divides n." Using this bridge combined with the strong divisibility property gcd(F(m), F(n)) = F(gcd(m,n)), we reduce the verification of Carmichael's theorem (1913) — that F(n) has a primitive prime divisor for all n ≥ 13 — to a computational check on a finite range plus a single analytic bound on the primitive part. The prime case follows from coprimality, and the composite case for n ≤ 50,000 is verified by `native_decide`. We discuss the remaining asymptotic step and its connection to cyclotomic Fibonacci numbers.

## 1. Introduction

The Fibonacci sequence F(0) = 0, F(1) = 1, F(n+2) = F(n+1) + F(n) is among the most studied objects in number theory. A prime p is called a **primitive prime divisor** of F(n) if p | F(n) but p ∤ F(k) for all 0 < k < n. In 1913, R. D. Carmichael proved that F(n) has a primitive prime divisor for every n ≥ 13, with the bound being sharp since F(12) = 144 = 2⁴·3² has no primitive divisor (2 | F(3) and 3 | F(4)).

The proof of Carmichael's theorem rests on two pillars:

1. **Entry-point theory:** Every prime p has an entry point α(p) — the smallest positive index k such that p | F(k). The key property is that p | F(n) if and only if α(p) | n.

2. **Primitive part bounds:** The "cyclotomic Fibonacci number" Ψ_n = ∏_{d|n} F(d)^{μ(n/d)} satisfies Ψ_n ≈ φ^{φ(n)} for large n, guaranteeing Ψ_n > 1 for n ≥ 13 composite.

Our formalization in Lean 4 with Mathlib makes the entry-point bridge the central reusable interface, reducing primitivity arguments to simple divisibility contradictions.

## 2. Mathematical Framework

### 2.1 Strong Divisibility and the GCD Identity

The Fibonacci sequence satisfies the **strong divisibility property**:

$$\gcd(F(m), F(n)) = F(\gcd(m, n))$$

This identity, available in Mathlib as `Nat.fib_gcd`, is the foundation of all entry-point arguments. Its immediate corollary is that m | n implies F(m) | F(n).

### 2.2 Entry Points (Ranks of Apparition)

For each prime p, the **entry point** α(p) is the smallest positive k with p | F(k). Its existence follows from the pigeonhole principle applied to pairs (F(n) mod p, F(n+1) mod p) — there are only p² possible pairs, so a repetition forces the zero pair F(0) = 0 to recur.

**Theorem (Entry-point divisibility).** If p is prime, n > 0, and p | F(n), then α(p) | n.

*Proof.* Let g = gcd(α(p), n). By the GCD identity, p | F(g). By minimality of α(p), g ≥ α(p). Since g | α(p), equality holds: g = α(p). Therefore α(p) | n. ∎

This theorem is formalized as `entry_dvd_of_fib_dvd` in our `FibEntry.lean` file. Combined with the converse (α(p) | n implies p | F(n), since p | F(α(p)) and F(α(p)) | F(n)), we obtain the biconditional:

$$p \mid F(n) \iff \alpha(p) \mid n$$

### 2.3 The Bridge from Divisors to Primitivity

The entry-point bridge converts the primitivity question — does p divide F(k) for some 0 < k < n? — into a pure index-divisibility question — does α(p) properly divide n?

**Lemma (Bridge).** Let p be prime with p | F(n). Then p is a primitive prime divisor of F(n) if and only if α(p) = n.

*Proof.* If α(p) = n: for any 0 < k < n, α(p) = n does not divide k, so p ∤ F(k). If α(p) < n: since α(p) | n, α(p) is a proper divisor, so 0 < α(p) < n and p | F(α(p)). ∎

**Corollary (Reduction to proper divisors).** A prime p | F(n) is primitive if and only if p ∤ F(d) for all proper divisors d of n (i.e., d | n, 0 < d < n).

*Proof.* (⇒) Clear. (⇐) If p | F(k) for 0 < k < n, then p | F(gcd(k,n)) by the GCD identity. Since gcd(k,n) is a proper divisor of n, this contradicts the hypothesis. ∎

This reduction is crucial for computation: instead of checking all indices 0 < k < n, we only check proper divisors of n.

### 2.4 The Primitive Part

We define the **primitive part** of F(n) computationally by iteratively removing all common factors with F(d) for proper divisors d of n. The result, `primPart(n)`, satisfies:

- `primPart(n)` divides F(n)
- `primPart(n)` is coprime to F(d) for every proper divisor d of n
- If `primPart(n) > 1`, then any prime factor of `primPart(n)` is a primitive prime divisor of F(n)

The third property follows because a prime p | primPart(n) cannot divide F(d) for any proper divisor d (by coprimality), and by the bridge lemma, p cannot divide F(k) for any 0 < k < n.

## 3. Formalization in Lean 4

### 3.1 Entry-Point Infrastructure

The entry point is defined using `Nat.find`, Lean's constructive witness for the least element satisfying a predicate:

```lean
noncomputable def fibEntryPoint (p : ℕ) (hp : p.Prime) : ℕ :=
  Nat.find (fib_entry_exists p hp)
```

The key theorems are:

```lean
lemma entry_dvd_of_fib_dvd (p : ℕ) (hp : p.Prime) (n : ℕ) (hn : 0 < n)
    (hpn : p ∣ Nat.fib n) : fibEntryPoint p hp ∣ n

lemma fib_dvd_iff_entry_dvd (p : ℕ) (hp : p.Prime) (n : ℕ) (hn : 0 < n) :
    p ∣ Nat.fib n ↔ fibEntryPoint p hp ∣ n
```

### 3.2 The Prime Case

For prime n ≥ 13, every prime factor of F(n) is automatically primitive:

```lean
theorem fib_primitive_divisor_prime (n : ℕ) (hn : 13 ≤ n) (hp : Nat.Prime n) :
    ∃ p, Nat.Prime p ∧ p ∣ Nat.fib n ∧ ∀ k, 0 < k → k < n → ¬(p ∣ Nat.fib k)
```

The proof: for prime n, the only divisors are 1 and n. If q | F(n) and q | F(k) for 0 < k < n, then q | F(gcd(n,k)) = F(1) = 1 (since gcd(n,k) = 1 for prime n and 0 < k < n), contradiction.

### 3.3 The Composite Case: Computational Verification

For composite n ∈ [13, 50000], we verify `primPart(n) > 1` by `native_decide`:

```lean
theorem primPart_check : ∀ n ∈ Finset.Icc 13 50000,
    Nat.Prime n ∨ 1 < primPart n := by native_decide
```

This takes advantage of Lean's ability to certify arbitrary decidable propositions by evaluation.

### 3.4 The Asymptotic Case

For composite n > 50000, the remaining step is to show `primPart(n) > 1`. This requires the cyclotomic Fibonacci bound:

$$\Psi_n = \prod_{d \mid n} F(d)^{\mu(n/d)} \geq \varphi^{\varphi(n)} - 1$$

where φ = (1+√5)/2 is the golden ratio and φ(n) is Euler's totient. For composite n > 50000, φ(n) ≥ √(n/2) > 158, giving Ψ_n > 10^{33}, far exceeding n. This bound ensures that Ψ_n has prime factors not dividing n, which are primitive for F(n).

This asymptotic step remains as the single `sorry` in the formalization. Its proof requires approximately 500 lines of infrastructure:
- Möbius inversion for multiplicative Fibonacci identities
- Algebraic bounds on the golden ratio powers
- Euler totient lower bounds vs. the radical of n

### 3.5 Supporting Lemmas

The formalization includes several useful lemmas:

1. **Fibonacci quotient GCD bound:** gcd(F(km)/F(m), F(m)) | k, proved by induction using the mod F(m)² congruence F(km) ≡ k·F(m)·F(m-1)^{k-1}.

2. **Fibonacci coprime products:** For coprime a, b: F(a)·F(b) | F(ab), since gcd(F(a), F(b)) = F(1) = 1.

3. **Fibonacci growth bounds:** F(n) ≥ n for n ≥ 5, and F(n) ≤ 2^n for all n.

## 4. The Chain of Reasoning

The complete proof of Carmichael's theorem follows this chain:

```
p | F(n)
  → α(p) | n                     [entry-point divisibility]
  → if α(p) = n then p is primitive at n  [bridge lemma]
  → any prime dividing primPart(n) gives a primitive divisor  [coprimality]
  → primPart(n) > 1 for composite n ≥ 13   [computational + asymptotic]
```

This chain is the main contribution of the formalization: it isolates a clean, reusable interface for Fibonacci divisibility arguments.

## 5. Discussion: Making Deep Number Theory Accessible

### 5.1 A Theorem with a Story

Carmichael's theorem has a beautiful structure that mirrors a common pattern in mathematics: a simple statement hiding a deep proof. The statement — "F(n) always gains a new prime factor for n ≥ 13" — is easy to check computationally for small n. The challenge is proving it for ALL n.

The proof strategy is like checking into a hotel. Each Fibonacci number F(n) is a "room" that houses certain prime guests. A prime p checks into the room F(α(p)) and visits every room whose number is a multiple of α(p). The question is: does every room n ≥ 13 get at least one guest who has never visited any earlier room?

For prime-numbered rooms, the answer is obvious: the only earlier room a guest could have visited is room 1 (which is empty), so every guest is new. For composite rooms, you need to argue that not all guests are recycled from earlier rooms. This requires understanding how many "new" guests enter at each composite step — which is exactly the cyclotomic Fibonacci bound.

### 5.2 The Exceptional Cases

The exceptions n ∈ {1, 2, 6, 12} are not accidental. They correspond to the indices where the "primitive part" Ψ_n equals 1:
- Ψ_1 = F(1) = 1
- Ψ_2 = F(2) = 1  
- Ψ_6 = F(6)·F(1)/(F(3)·F(2)) = 8/(2·1) = 4... 

Wait, Ψ_6 = 4, not 1! The issue is that 4 = 2², and 2 | 6, so the prime factor 2 of Ψ_6 divides n = 6 and thus is an "intrinsic factor" rather than a primitive divisor. The primitive part (in our computational sense) strips these, yielding 1.

So the exceptions arise from a conspiracy: the cyclotomic part Ψ_n is supported entirely on primes dividing n.

### 5.3 Connections and Future Directions

**Zsigmondy's theorem.** Carmichael's result is a special case of Zsigmondy's theorem for linear recurrences. The general theorem states that for a non-degenerate linear recurrence a^n - b^n (or more generally, Lucas sequences), the n-th term has a primitive prime divisor for all sufficiently large n.

**Computational number theory.** Entry-point theory has applications to:
- Fibonacci-based primality testing
- Period computation for Fibonacci sequences modulo m (Pisano periods)
- Factoring algorithms using algebraic group structure

**Formal verification.** Our formalization demonstrates that deep number-theoretic results can be partially verified in proof assistants. The computational component (native_decide on [13, 50000]) provides high confidence, while the formal framework ensures the mathematical argument is sound.

## 6. Applications

### 6.1 Primality Certificates

If F(p) has a prime factor q with entry point α(q) = p, this certifies that p is prime (since α(q) must divide p, and α(q) > 1 forces p to be prime or α(q) = p). Carmichael's theorem guarantees such certificates exist for all primes p ≥ 13.

### 6.2 Large Prime Generation

The primitive part Ψ_n often yields large primes. Since Ψ_n ≈ φ^{φ(n)}, these primes grow exponentially with the totient of n. For prime n, Ψ_n = F(n) itself, and many Fibonacci primes are known.

### 6.3 Fibonacci Pseudoprimes

The entry-point framework characterizes Fibonacci pseudoprimes: composite n with F(n) ≡ (n/5) (mod n), where (n/5) is the Jacobi symbol. Understanding which composites "look prime" to the Fibonacci test requires precise control of entry points.

## 7. Conclusion

We have formalized the entry-point bridge for Fibonacci primitive divisors in Lean 4, creating a reusable interface that converts divisibility statements about Fibonacci values into index-divisibility statements. The prime case of Carmichael's theorem follows cleanly, and the composite case is verified computationally for n ≤ 50,000. The remaining asymptotic step — showing the cyclotomic Fibonacci bound Ψ_n > 1 for composite n > 50,000 — requires substantial additional infrastructure but is well-understood mathematically.

The key insight is that the entry-point bridge provides a clean abstraction: once established, primitivity arguments reduce to simple divisibility contradictions, independent of the specific properties of Fibonacci numbers.

## References

1. R. D. Carmichael, "On the numerical factors of the arithmetic forms α^n ± β^n," *Annals of Mathematics*, Second Series, Vol. 15 (1913), pp. 30–70.

2. M. Ward, "The prime divisors of Fibonacci numbers," *Pacific Journal of Mathematics*, Vol. 11, No. 1 (1961), pp. 379–386.

3. Y. Bilu, G. Hanrot, and P. M. Voutier, "Existence of primitive divisors of Lucas and Lehmer numbers," *Journal für die reine und angewandte Mathematik*, Vol. 539 (2001), pp. 75–122.
