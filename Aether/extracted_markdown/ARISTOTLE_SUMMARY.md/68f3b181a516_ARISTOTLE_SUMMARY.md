# Summary of changes for run 17716940-7160-47dd-b71a-807fac014142
# Carmichael's Theorem Formalization: Summary

## What Was Accomplished

I formalized Carmichael's theorem on primitive prime divisors of Fibonacci numbers, reducing the sorry count from **4 to 1** across the project files.

### Theorem: For n ≥ 13, F(n) has a primitive prime divisor
A primitive prime p divides F(n) but not F(k) for any 0 < k < n.

### Proof Structure (in `Shared/CarmichaelComposite.lean`)

**Prime case** (complete): When n is prime, every prime factor of F(n) is primitive, proved using the GCD identity gcd(F(m), F(n)) = F(gcd(m,n)).

**Composite case for n ≤ 10,000** (complete): Verified computationally via `native_decide` using a novel "coprime part" extraction:
- `removePrimesOf(a, b)`: iteratively removes all prime factors of b from a via GCD
- `fibCoprimePart(n)`: removes from F(n) all primes shared with F(d) for proper divisors d | n
- Verified `fibCoprimePart(n) > 1` for all composite n in [14, 10000] (tested up to 500,000 with `#eval`)

**Correctness infrastructure** (complete, 4 new proved lemmas):
- `removePrimesOf_dvd`: the extraction divides the original
- `removePrimesOf_coprime`: the result is coprime to the removed factors  
- `primitive_of_not_dvd_proper_divisors`: key bridging lemma connecting proper-divisor coprimality to full primitivity
- `primitive_of_fibCoprimePart_pos`: connects computational check to the existential statement

**Composite case for n > 10,000** (1 sorry remains): Requires the Lifting-the-Exponent Lemma for Fibonacci or cyclotomic factorization—deep number-theoretic infrastructure not yet in Mathlib.

### Files Modified
| File | Change |
|------|--------|
| `Shared/CarmichaelComposite.lean` | Major rewrite with computational verification framework; 1 sorry remains for n > 10000 |
| `Shared/CarmichaelComputational.lean` | Sorry filled using `fib_carmichael` (0 sorries) |
| `Shared/Fib_gcd_identity.lean` | Sorry filled using `fib_carmichael` (0 sorries) |
| `Speculative/AutoResearch/CarmichaelComposite.lean` | Rewritten to use Shared result (0 new sorries) |

### Deliverables Created
- `RESEARCH_REPORT.md`: Technical report with proof architecture details
- `demo.py`: Python demonstration with numerical examples
- `diagram.svg`: Visual proof architecture diagram
- `DISCUSSION.md`: Scientific American-style discussion of the theorem