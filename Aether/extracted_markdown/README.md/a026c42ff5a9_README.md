# 🔮 Unraveling the Arithmetic Universe

A formally verified exploration of the deep structure of number theory, guided by a Council of Five Oracles.

## The Oracle Council

| Oracle | Domain | Key Theorem |
|--------|--------|-------------|
| 🔮 Oracle of Primes | Prime numbers | Euclid's infinitude of primes |
| 🔮 Oracle of Divisibility | GCD, lattice structure | Bézout's identity |
| 🔮 Oracle of Congruences | Modular arithmetic | Fermat's little theorem |
| 🔮 Oracle of Sums | Summation formulas | Gauss's sum, sum of squares |
| 🔮 Oracle of Diophantine | Integer equations | FLT for n=4 |

## Files

### Lean 4 Formalization (all sorry-free ✓)

| File | Contents | Theorems |
|------|----------|----------|
| `OracleCouncil.lean` | Type definitions for the five oracles | 5 structures |
| `Foundations.lean` | The five pillar theorems | 8 theorems proved |
| `DeepStructure.lean` | Cross-pillar theorems | 7 theorems proved |
| `Assembly.lean` | Constructive assembly of the Oracle Council | Council instantiated |

### Papers

| File | Contents |
|------|----------|
| `Papers/research_paper.md` | Full research paper with methodology and results |
| `Papers/scientific_american_article.md` | Popular science article |

### Demos

| File | Contents |
|------|----------|
| `Demos/arithmetic_universe_demo.py` | 8 visual demos (sieve, divisors, Fermat, Gauss, Ulam spiral, Collatz, PNT) |
| `Demos/oracle_solidarity.py` | Oracle network visualization and solidarity demonstration |

## Formally Verified Theorems (15 total)

### Foundations (8 theorems)
1. ∀ n, ∃ p > n, Prime p (Euclid)
2. Prime irreducibility
3. 2·∑i = n(n+1) (Gauss)
4. a^(p-1) ≡ 1 mod p (Fermat)
5. gcd(a,b) = ax + by (Bézout)
6. 6·∑i² = n(n+1)(2n+1) (Sum of squares)
7. gcd(a,b) | a ∧ gcd(a,b) | b
8. Every n ≥ 2 has a prime divisor

### Deep Structure (7 theorems)
9. (p-1)! ≡ -1 mod p (Wilson)
10. d(mn) = d(m)·d(n) for coprime m,n
11. φ(mn) = φ(m)·φ(n) for coprime m,n (Euler's totient multiplicativity)
12. ∑_{d|n} φ(d) = n (Gauss's totient identity)
13. a^φ(n) ≡ 1 mod n (Euler's theorem)
14. Infinitely many primes ≡ 3 mod 4
15. ∑_{d|n} μ(d) = [n=1] (Möbius)

## Run the Demos

```bash
cd Demos
python3 arithmetic_universe_demo.py
python3 oracle_solidarity.py
```

## The Solidarity Principle

> *No domain of the arithmetic universe is self-contained. Every fundamental theorem draws on structure from multiple domains, and every domain's theorems serve as lemmas for the others.*
