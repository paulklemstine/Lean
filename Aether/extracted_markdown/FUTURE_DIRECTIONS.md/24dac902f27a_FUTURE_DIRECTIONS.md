# Future Directions — Arithmetic of the Fibonacci Rank of Apparition

## Synthesis

This cycle closed the two remaining *code-level* `sorry` placeholders in the
self-contained entry-point thread of the catalog and then pushed the theory
forward. The unifying object is the **rank of apparition** (Fibonacci entry
point) `α(m) = fibEntryPt m`, the least `k > 0` with `m ∣ F(k)`. The upstream
characterization theorem `fib_dvd_iff_entryPt_dvd` says the index set
`{k | m ∣ F(k)}` is *exactly* the principal ideal `(α(m)) ⊆ ℕ`, for **any**
modulus `m` (its proof never uses primality). Treating that as an axiom of
behaviour, all arithmetic of `α` becomes the arithmetic of principal ideals.

Two files carry the work:

* `Catalog/Speculative/AutoResearch/FibonacciEntryPointCharacterization.lean`
  — the previously-open conjecture `fibEntryPt_mul_coprime` (the binary lcm law
  `α(a·b) = lcm(α a, α b)` for coprime `a, b`) is now **proved**.
* `Catalog/Speculative/AutoResearch/FibEntryPointMultiplicative.lean` (new) —
  develops `α` as an arithmetic function: `α(1) = 1`; the index set is an
  additive sub-semigroup of `(ℕ,+)` (`fib_dvd_add`, `fib_dvd_sub`); the explicit
  base table `α(2)=3, α(3)=4, α(5)=5, α(7)=8`; the boundary computation
  `α(6) = 12`; and the **full multiplicativity law** `fibEntryPt_prod`,
  `α(∏ᵢ mᵢ) = lcm ᵢ α(mᵢ)` for any finite pairwise-coprime family, with its
  existence companion `prod_has_entryPt`.

## Results summary

| Theorem | Statement | Status |
|---|---|---|
| `fibEntryPt_mul_coprime` | `α(a·b) = lcm(α a, α b)`, coprime `a,b` | proved (was `sorry`) |
| `fibEntryPt_prod` | `α(∏ᵢ mᵢ) = lcm ᵢ α(mᵢ)`, pairwise coprime | proved |
| `prod_has_entryPt` | finite coprime product has a rank of apparition | proved |
| `fib_dvd_add` / `fib_dvd_sub` | index set closed under `+` and truncated `−` | proved |
| `fibEntryPt_{one,two,three,five,seven}` | base table of ranks | proved |
| `fibEntryPt_six` | `α(6)=12`, the `F(12)` boundary, arithmetically | proved |

All main results carry only `propext, Classical.choice, Quot.sound`.

The arithmetically interesting payoff is `fibEntryPt_six`: because `6 = 2·3`
with `2,3` coprime, `α(6) = lcm(α2, α3) = lcm(3,4) = 12`, so `6` first divides
`F(12)`. This is the exact arithmetic reason `F(12) = 144 = 2^4·3^2` carries no
*primitive* prime divisor — the single composite exception Carmichael's theorem
must exclude.

## Research directions for the next cycle

**1. Prime-power ranks and the full reconstruction of `α`.**
Combine `fibEntryPt_prod` with a theory of `α(pᵏ)` for prime powers. Empirically
`α(pᵏ) = α(p)·p^{max(0, k − e_p)}` where `e_p = v_p(F(α(p)))` is the exact power
of `p` in the first Fibonacci hit (the "Wall–Sun–Sun" exponent), so that
`α(m) = lcm_{p^k ‖ m} α(pᵏ)` is computable from the factorization of `m`. *The
key insight is* that `prod_has_entryPt` + `fibEntryPt_prod` already reduce the
general modulus to prime powers, so only the single-prime lifting law remains to
be formalized. *Why now?* The multiplicativity law proved this cycle is exactly
the missing glue; the prime-power case is a focused `p`-adic-valuation lemma about
`F(α(p)·p^j)` and is independently testable by `decide` on small primes.

**2. Close the Carmichael large-`n` gap by reconstructing the broken dependency.**
`Shared/CarmichaelProof.lean` still contains the lone deep `sorry`: composite
`n > 10000 ⟹ F(n)` has a primitive prime divisor. That file currently does not
even build, because it imports a missing `Shared/CarmichaelHelper.lean`
(supplying `fib_primitive_divisor_prime`); rebuilding that helper is a
prerequisite. *The key insight is* that the file's own
`primitive_of_fibCoprimePart_pos` already reduces the goal to a single growth
statement: `1 < fibCoprimePart n` for composite `n`, i.e. `F(n)` strictly exceeds
the product of its non-primitive factors. *Why now?* The entry-point machinery
completed here gives the clean criterion (`α(p) = n ↔ p` primitive), so the only
remaining ingredient is the Fibonacci growth bound `F(n) > ∏_{d | n, d < n} F(d)`
for large `n`, an elementary `φ = (1+√5)/2` estimate.

**3. The rank of apparition is the period of `F mod m` divided by a small factor.**
Conjecture: for every `m` with a rank of apparition, the Pisano period `π(m)`
satisfies `α(m) ∣ π(m)` and `π(m) / α(m) ∈ {1, 2, 4}`, with the value determined
by `m mod ...`. *The key insight is* that `fib_dvd_iff_entryPt_dvd` already
identifies `α(m)` as the generator of the zero-set of `F mod m`, and the Pisano
period is the full period of the pair `(F(k), F(k+1)) mod m`, so the ratio
measures the order of `F(α(m)+1) mod m` in `(ℤ/m)ˣ`. *Why now?* The index-set =
principal-ideal theorem makes `α(m)` a first-class object, so the period/rank
ratio becomes a concrete, `decide`-checkable group-order statement.

**4. Lucas-sequence universality of the entry-point characterization.**
Every theorem here used only `Nat.fib_gcd`, `Nat.fib_dvd`, and `F 0 = 0`. The
same proofs should go through verbatim for any *strong divisibility sequence*
(e.g. Lucas sequences `U_n(P,Q)` with `gcd(U_m,U_n) = U_{gcd(m,n)}`). *The key
insight is* that primality of the modulus is never used, and `gcd`-compatibility
is the only structural input, so the entry-point theory is a theorem about strong
divisibility sequences, not about Fibonacci specifically. *Why now?* Abstracting
`Nat.fib` to a typeclass `StrongDivisibilitySeq` would let one re-derive
`fibEntryPt_prod` once and instantiate it for Fibonacci, Lucas, Mersenne
`2^n − 1`, and `q`-integers simultaneously — high reuse, low marginal cost.

**5. Density and the inverse problem: which `n` are ranks of apparition?**
`entryPt_eq_iff_primitive` recasts Carmichael's theorem as the statement that
`α : Primes → ℕ` is *surjective onto `ℕ \ {1,2,6,12}`* restricted appropriately.
Conjecture: the image of `α` (over all moduli) is cofinite, missing exactly a
computable finite set, and the counting function `#{p ≤ x : α(p) = n}` is governed
by the splitting of `x² − x − 1` mod `p`. *The key insight is* that `α(p) = n`
forces `p ∣ F(n)` *primitively*, so the fibre `α⁻¹(n)` is exactly the set of
primitive prime divisors of `F(n)`, whose existence (for `n ∉ {1,2,6,12}`) is
direction 2. *Why now?* With `fibEntryPt_six` pinning the lone exceptional fibre
`α⁻¹` behaviour at `n = 12`, the surjectivity statement is now precisely
formulated and reduces to the same growth bound as direction 2.
