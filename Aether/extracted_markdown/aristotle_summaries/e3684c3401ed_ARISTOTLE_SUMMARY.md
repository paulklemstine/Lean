# Summary of changes for run 45e7cac1-b8c6-45e4-b45a-a3c96fce84a2
## Carmichael Primitive Divisor Theorem — Progress Report

### Lean 4 Formal Mathematics

I made significant progress on the formalization infrastructure, though the deep analytical sorry for composite n > 10,000 remains open.

#### Sorry-Free Results (New Files)

1. **`Catalog/Shared/FibGrowth.lean`** — 7 lemmas, all proved without sorry:
   - `fib_add_one_ge_mul`: F(m+1)·F(n+1) ≤ F(m+n+1)
   - `fib_add_ge_mul`: F(a)·F(b) ≤ F(a+b) for a,b ≥ 1 (sub-multiplicativity)
   - `fib_mul_ge_pow`: F(a)^b ≤ F(a·b) for a,b ≥ 1
   - `fib_strictMono_of_ge_two`: Strict monotonicity for indices ≥ 2
   - `fib_ge_self`: F(n) ≥ n for n ≥ 5
   - `div_lt_of_prime_dvd`: n/p < n for prime divisors
   - `fib_div_gt_one`: F(n)/F(d) > 1 when d | n and 2 ≤ d < n

2. **`Catalog/Shared/CarmichaelWork.lean`** — Entry point theory, 5 lemmas proved:
   - `fibEntry'_pos`: Entry point is positive when p | F(n)
   - `fibEntry'_dvd`: Entry point divides n (the key divisibility property)
   - `fibEntry'_dvd_fib`: p divides F(entry point)
   - `fibEntry'_min`: Entry point is minimal (no smaller index works)
   - `bridge'`: Bridge lemma — checking proper divisors of n suffices for primitivity

#### Remaining Sorry

The sorry in `Catalog/Shared/CarmichaelProof.lean` (line 131) for composite n > 10,000 could not be resolved. This is Carmichael's deep theorem requiring the primitive part Ψ(n) = ∏_{d|n} F(d)^{μ(n/d)} > 1 for all composite n > 12. The proof needs:
- The Binet formula (available in Mathlib as `Real.coe_fib_eq`)
- Möbius inversion showing log Ψ(n) ≈ φ(n)·log(φ) > 0
- Error analysis bounding the Binet approximation error

The mirror sorry in `Catalog/Speculative/AutoResearch/CarmichaelComposite.lean` (line 164) is the same mathematical content.

### Python Demos

- **`demos/carmichael_demo.py`**: Interactive demonstration showing primitive prime divisors for F(n) with n up to 200, entry point tables, and primitive part growth
- **`demos/applications.py`**: Three practical applications — primality certificates, guided Fibonacci factorization, and LFSR period analysis

### Research Paper

- **`docs/carmichael_paper.md`**: Complete mathematical paper covering the proof architecture, formalized results, applications, and a Scientific American-style discussion explaining why every large Fibonacci number must have a "secret prime."

### What Would Complete the Project

The remaining sorry requires ~300-500 lines of new Lean infrastructure to formalize the analytical bound Ψ(n) ≈ φ^{φ(n)} >> 1. The key steps are: (1) connect the Binet formula to logarithmic bounds on F(d), (2) apply Möbius inversion to get log Ψ(n) = φ(n)·log(φ) + error, (3) bound the error by ~1.24, which is negligible compared to the main term φ(n)·log(φ) ≥ 2400 for n > 10,000.