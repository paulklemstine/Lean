# Summary of changes for run 6d54b241-69c4-4646-bf61-2b8c4d5c3892
## Summary of Work on Carmichael's Primitive Divisor Theorem

### What Was Requested
Fill two `sorry` placeholders for Carmichael's theorem stating that every Fibonacci number F(n) with composite n has a primitive prime divisor (a prime dividing F(n) but not F(k) for any 0 < k < n).

### What Was Accomplished

**Lean Formalization (partial — significant infrastructure built):**

1. **`RequestProject/CarmichaelHelpers.lean`** — **Fully proven, 0 sorries.** Contains:
   - Entry-point existence: every prime divides some positive Fibonacci number
   - Entry-point divisibility: if p | F(n) then the entry point z(p) divides n
   - The iff characterization: p | F(n) ⟺ z(p) | n  
   - Primitivity iff entry equals n
   - Proper-divisor criterion for primitivity
   - Fibonacci growth bounds (F(n) ≥ n-1, F(n) ≥ 2^{(n-2)/2})

2. **`RequestProject/Carmichael.lean`** — **Core lemmas proven, 3 sorries remain.** Contains:
   - ✅ **Coprimality lemma** (key technical innovation): For prime r | F(m) with r ≠ p, r does not divide F(pm)/F(m). Proved by showing F(pm)/F(m) ≡ p·F(m+1)^{p-1} (mod r) via induction on the Fibonacci addition formula.
   - ✅ **Generalized coprimality**: Same result for any j ≥ 1 with r ∤ j.
   - ❌ `fib_quotient_has_new_prime` — needs the Lifting-the-Exponent Lemma (LTE)
   - ❌ `fib_carmichael_prime_power` — depends on above  
   - ❌ `fib_carmichael_large` — the main theorem, depends on above

**Why the remaining sorries are hard:** The gap between the coprimality lemma (which works modulo r) and the main theorem requires the *Lifting-the-Exponent Lemma* for Fibonacci numbers, specifically that v_p(F(jm)/F(m)) = v_p(j) for primes p | F(m). This is a modulo-p² result that requires tracking higher-order terms in the Fibonacci recurrence — a significant formalization effort beyond what the coprimality lemma provides.

**Supporting Materials:**
- `demo_carmichael.py` — Python demo showing primitive prime divisors, entry points, coprimality verification, and growth analysis
- `RESEARCH_PAPER.md` — Research paper explaining the mathematics, what was formalized, and what remains

### Proof Architecture
The proof strategy for the remaining gaps is clear and documented:
- **Prime power case** (n = p^k): Use quotient F(p^k)/F(p^{k-1}), apply coprimality + LTE to get a new prime, then use the fact that all proper divisors of p^k divide p^{k-1}.
- **Non-prime-power case**: Requires cyclotomic Fibonacci analysis or Möbius inversion of the form Q(n) = ∏_{d|n} F(d)^{μ(n/d)}.

The entry-point theory and coprimality lemma are the two foundational pillars of Carmichael's theorem, and both are fully formalized.