# Future Directions: The Fibonacci Entry Point as a Lattice-Respecting Arithmetic Function

## Synthesis of this cycle

This cycle closed the open `sorry` in
`Catalog/Speculative/AutoResearch/FibonacciEntryPointCharacterization.lean` and
promoted the *entry point* (rank of apparition) `α(m) = least k > 0 with m ∣ F(k)`
from a single divisibility identity into a fully fledged arithmetic function on
the divisibility lattice of moduli admitting an apparition index.

Concretely, four theorems are now proved sorry-free (axioms: `propext`,
`Classical.choice`, `Quot.sound` only):

* `fibEntryPt_mul_coprime` — **the lcm law** `α(a·b) = lcm(α a, α b)` for coprime
  `a, b` (this was the cycle's target `sorry`).
* `fibEntryPt_dvd_of_dvd` — **monotonicity** `a ∣ b ⟹ α(a) ∣ α(b)`.
* `fib_dvd_mul_coprime_iff` — **product criterion** `a·b ∣ F(k) ↔ lcm(α a, α b) ∣ k`.
* `fib_dvd_mul_setOf_eq_inter` — **set form** the index set of `a·b` is the
  intersection of the index sets of `a` and `b`.

The unifying engine is the catalog's characterization theorem
`fib_dvd_iff_entryPt_dvd` (`m ∣ F(k) ↔ α(m) ∣ k`), whose proof never uses
primality and is therefore the *universal property* of `α`: the index set of any
modulus is the principal ideal `(α(m)) ⊆ ℕ`. Every result above is a short
consequence of that universal property plus elementary lattice facts.

## Results summary

| Theorem | Statement | Status |
|---|---|---|
| `fibEntryPt_mul_coprime` | `α(a·b) = lcm(α a, α b)`, `gcd(a,b)=1` | proved |
| `fibEntryPt_dvd_of_dvd` | `a ∣ b ⟹ α a ∣ α b` | proved |
| `fib_dvd_mul_coprime_iff` | `a·b ∣ F k ↔ lcm(α a, α b) ∣ k` | proved |
| `fib_dvd_mul_setOf_eq_inter` | index set of `a·b` = intersection | proved |
| `fib_carmichael_composite` (tail) | primitive divisor for composite `n > 10000` | **open** |

The boundary obstruction `fib_twelve_no_primitive` (`F(12) = 144` has no
primitive prime divisor) remains the structural reason any primitive-divisor
statement must exclude `n = 12`.

## Research directions

### 1. Full factorization reconstruction of the entry point

Conjecture: for every `m > 0` admitting an apparition index,
`α(m) = ` the lcm, taken over the prime-power factors `pᵉ ∥ m`, of `α(pᵉ)`. This
is the multi-factor closure of the binary lcm law proved this cycle, and is
*falsifiable*: a single `m` whose entry point differs from that lcm refutes it.
**The key insight is** that coprimality is the only hypothesis the binary law
needs, so an induction over the coprime factorization `m = ∏ pᵉ` should lift it
verbatim — the lcm law is associative-commutative precisely because `lcm` is. **Why
now?** With `fibEntryPt_mul_coprime` and `fibEntryPt_dvd_of_dvd` in hand, the
inductive step (`α(a·b) = lcm(α a, α b)` plus monotonicity to glue the pieces) is
fully mechanized; only a `Nat.factorization`/`Finset.prod` bookkeeping layer is
missing.

### 2. The prime-power growth law (lifting the exponent)

Conjecture: there is an integer `e₀(p) ≥ 1` such that for all `k ≥ e₀(p)`,
`α(pᵏ) = pᵏ⁻ᵉ⁰⁽ᵖ⁾ · α(p)`; equivalently `α(pᵏ⁺¹) ∈ {α(pᵏ), p·α(pᵏ)}` and equals
`p·α(pᵏ)` once the "Wall–Sun–Sun" threshold is passed. This is sharply
falsifiable on any explicit prime. **The key insight is** that the `p`-adic
valuation of `F(α(p)·pʲ)` increases by exactly one each time `j` increments
(a lifting-the-exponent phenomenon for Lucas sequences), so the entry point
multiplies by `p` in lockstep. **Why now?** The entry-point API already isolates
`α(pᵏ)` as a clean object; combined with Mathlib's `multiplicity`/`padicValNat`
lemmas, the LTE step is the only analytic input required, and direction (1) then
turns this into a complete formula for `α(m)`.

### 3. Carmichael's primitive-divisor theorem for the infinite tail

Conjecture (the remaining `sorry` in `Shared/CarmichaelProof.lean`): every
composite `n > 12` makes `F(n)` carry a primitive prime divisor; in particular
the `n > 10000` tail left open this cycle holds. **The key insight is** that
`entryPt_eq_iff_primitive` recasts "primitive divisor exists" as "`α` is
surjective onto `n`", i.e. some prime power in the factorization of the
*primitive part* `Φₙ(φ, ψ)` has entry point exactly `n`; a primitive divisor
fails to exist only when the entire primitive part is absorbed by the bounded
"intrinsic" factor `n`, which a size estimate `Φₙ > n` rules out for large `n`.
**Why now?** The entry-point characterization supplies the missing bridge between
the computational finite check (already done up to `10000`) and an asymptotic
lower bound on the primitive part — turning a monolithic number-theory theorem
into a clean "primitive part dominates" inequality. (Note: the current file also
needs its missing `Shared.CarmichaelHelper` import restored before this can
compile.)

### 4. Entry point versus Pisano period

Conjecture: for every modulus `m` with an apparition index, `α(m) ∣ π(m)` (the
Pisano period) and the ratio `π(m)/α(m) ∈ {1, 2, 4}`. The finite ratio set makes
this immediately falsifiable. **The key insight is** that `π(m)` is the order of
the Fibonacci shift matrix `[[1,1],[1,0]]` in `GL₂(ℤ/m)`, while `α(m)` is the
order of its image in the quotient by scalar matrices, so the ratio is the order
of a determinant-type character and is constrained to small values. **Why now?**
The set-level result `fib_dvd_setOf_eq_multiples` already identifies the index
set with `(α(m))`; pairing it with Mathlib's matrix-order machinery for
`Matrix.SpecialLinearGroup` makes the period/entry-point comparison a group-order
computation rather than an ad hoc recurrence argument.

### 5. Density of moduli with maximal entry point

Conjecture: the set of primes `p` with `α(p) = (p − (5/p))` (the largest possible
entry point, where `(5/p)` is the Legendre symbol) has a positive natural density
strictly between `0` and `1`. This is a falsifiable statistical claim. **The key
insight is** that `α(p)` divides `p − (5/p)` always (Fibonacci's analogue of
Fermat's little theorem), so "maximal entry point" is exactly the primitive-root
condition for `φ mod p`, whose density is governed by an Artin-type heuristic.
**Why now?** The monotonicity and characterization theorems pin down `α(p)` as a
divisor-constrained order, so the density question reduces to a known
Artin-primitive-root framework that Mathlib's growing analytic-number-theory
library is beginning to support.
