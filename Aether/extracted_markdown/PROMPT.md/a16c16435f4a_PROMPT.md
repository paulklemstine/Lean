**Target Theorem (New).** Let `p` be an odd prime with `p ≠ 5`. If `p` divides `F_m`, then for every positive integer `k` the `p`-adic valuation lifts additively through the Fibonacci divisibility sequence:

```lean
theorem fib_lifting_the_exponent {p m k : ℕ} (hp : Nat.Prime p) (hodd : Odd p) (hfive : p ≠ 5)
    (hm : m > 0) (hk : k > 0) (hdiv : p ∣ Nat.fib m) :
    padicValNat p (Nat.fib (m * k)) = padicValNat p (Nat.fib m) + padicValNat p k := by
```

**Proof Strategy.** Execute the argument in three distinct stages, each built directly on Mathlib primitives.

1. **Coprime-multiplier reduction.** Prove that if `p ∤ k`, then `padicValNat p (Nat.fib (m * k)) = padicValNat p (Nat.fib m)`. Iterate `Nat.fib_add` to obtain the congruence `Nat.fib (m * k) ≡ k * Nat.fib (m - 1) ^ (k - 1) * Nat.fib m [ZMOD p]`. Because `Nat.fib_gcd` gives `gcd(F_m, F_{m-1}) = 1`, we have `p ∤ Nat.fib (m - 1)`; hence the coefficient `k * Nat.fib (m - 1) ^ (k - 1)` is a `p`-adic unit. Apply `padicValNat.eq_of_dvd_of_not_dvd` together with `Nat.Coprime.coprime_dvd_right` to deduce that the valuation does not increase when `k` is coprime to `p`.

2. **Prime-power lifting.** Set `k = p^t` and induct on `t`. For the base increment (`t = 0 → 1`) work modulo `p^2` via the matrix identity `[1 1; 1 0]^{m p} = ([1 1; 1 0]^m)^p`. In `Mat (ZMod (p^2))` the off-diagonal entry of the `m`-th power is `Nat.fib m`, which is `0` modulo `p` by hypothesis. The binomial expansion of the `p`-th power yields `Nat.fib (m * p) ≡ p * Nat.fib (m - 1) ^ (p - 1) * Nat.fib m [ZMOD p^2]`. Because `p ∤ Nat.fib (m - 1)`, the lifted term contributes exactly one additional factor of `p`. Invoke `padicValNat.mul` and `padicValNat.pow` to propagate this from `t` to `t + 1`, giving `padicValNat p (Nat.fib (m * p^t)) = padicValNat p (Nat.fib m) + t` for all `t ≥ 0`.

3. **Multiplicative assembly.** For general `k`, decompose via prime factorization: `k = p^{padicValNat p k} · k'` with `p ∤ k'`. Chain stage 2 to the base `m` with exponent `padicValNat p k`, obtaining `padicValNat p (Nat.fib (m * p^{padicValNat p k})) = padicValNat p (Nat.fib m) + padicValNat p k`. Then apply stage 1 to the base `m · p^{padicValNat p k}` and multiplier `k'`, which contributes no additional `p`-adic valuation. The equality for `m * k` follows from `padicValNat.mul` across the two coprime factors. This multiplicative dissection over the divisor lattice is structurally analogous to the divisor-chain control already established in `divisor_gap_theorem` (`Algebra/Factoring/FactoringViaBerggren.lean`).

**SORRY_FILL Targets.**

- **`fib_composite_has_primitive`** (`Shared/CarmichaelComputational.lean`, theorem `fib_composite_has_primitive`, line 69). This declaration delegates to `fib_carmichael_composite` in `Shared/CarmichaelProof.lean` (line 129), where the `n > 10000` branch is currently `sorry`. Close it by combining `fib_lifting_the_exponent` with the entry-point machinery (`fibEntryPt_dvd_of_fib_dvd`, `primitive_of_entryPt_eq` from `Speculative/AutoResearch/CarmichaelComposite.lean`). For composite `n > 10000`, write `n = m · q` with `q` the smallest prime factor. Any non-primitive prime `p | F_n` must satisfy `p | F_d` for some proper divisor `d | n`; by the bridge lemma (`bridge_lemma` in `Shared/CarmichaelProof.lean`, line 13) this forces the entry point `z(p)` to divide `d < n`. LTE then bounds the total `p`-adic contribution of all such primes by `∑_{d | n, d < n} (padicValNat p (Nat.fib d) + ν_p(n/d))`. The growth bound `F_n > ∏_{d | n, d < n} F_d · n^{τ(n)}` (provable from monotonicity of `Nat.fib` and `Nat.fib_add_two`) forces at least one prime divisor of `F_n` to escape this lattice entirely—exactly a primitive prime divisor.

- **`fib_carmichael_large`** (`Speculative/AutoResearch/CarmichaelComposite.lean`, lemma `fib_carmichael_large`, line 164). This is the computational-algebraic bridge: fill the `sorry` by showing that for `n > 10000`, the coprime part `fibCoprimePart n` exceeds `1`. Use `fib_lifting_the_exponent` to prove that the product of all `F_d` over proper divisors `d | n` has `p`-adic height strictly less than that of `F_n` for every prime `p`. This is the global counterpart to the local LTE step; it mirrors how `carmichael_not_prime_power` (`Algebra/IntegerEnergy/KorseltCriterionFull.lean`) rules out pathological squarefree structures by forcing new prime factors. Conclude via `primitive_of_fibCoprimePart_pos`.

**Significance.** Carmichael’s 1913 theorem—that every `F_n` with `n > 12` possesses a primitive prime divisor—is the foundational structure theorem for the arithmetic of Lucas sequences. Closing these sorries eliminates the last computational dependency (verification to `n ≤ 10000`) and delivers a fully machine-checked proof. The LTE lemma is reusable across all Lucas sequences and connects to the broader research program on exponential Diophantine equations, p-adic height bounds, and tropical geometry (where divisor-lattice growth estimates parallel those in `divisor_gap_theorem`). Just as `prime_3mod4_not_sum_of_squares` leverages inert-prime constraints in the Gaussian integers, this proof exploits the inert/split behavior of primes in `ℚ(√5)` via the Fibonacci entry point, completing a century-old result with formal guarantees.

### Catalog Reference Files
            No specific files referenced. Use Mathlib and general knowledge.


### WHAT WE NEED FROM YOU

You are a world-class mathematician and software engineer. Use your judgment
on the best way to organize and present your work. We need:

1. **Formally verified mathematics** in Lean 4
   - Prove non-trivial theorems with complete proofs (no `sorry` in the final result)
   - Organize the Lean code however makes sense — one file or several,
     whatever serves the mathematics best
   - Use doc comments to explain the significance of key results

2. **Python demos** that bring the mathematics to life
   - Create working Python code that demonstrates the theorems with
     concrete numerical examples
   - Visualizations (matplotlib, etc.) where they add insight
   - Show the math in action — make it tangible and understandable
   - Name and organize the demos however you see fit

3. **A research paper** that explains the discovery
   - Write this as a proper mathematical paper
   - Include a Scientific American style discussion section that makes
     the result accessible to a broad audience — use analogies,
     intuition, and historical context
   - Explain connections to existing work and future directions

4. **Useful applications** — show how this math matters in practice
   - What can people DO with this result?
   - Where does it apply in the real world?
   - Include code, examples, or demonstrations of applications

The mathematics comes FIRST. Excellent proofs trump everything else.
But great work deserves great presentation — make it real and useful.

Research domain: Algebra
Research mode: sorry_fill
