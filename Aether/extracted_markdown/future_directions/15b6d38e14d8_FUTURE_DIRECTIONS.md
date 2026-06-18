# Future Directions — Fibonacci Entry Points, the Rank of Apparition, and the Join Law

## Synthesis of this cycle

The Fibonacci **entry point** (rank of apparition) `α(m)` is the least `k > 0` with
`m ∣ F(k)`. Earlier catalog cycles established the *meet* side of its lattice
structure — `α` respects `gcd` (`Nat.fib_gcd`) — together with a one-directional
divisibility law and a full *iff* characterization
(`FibEntryChar.fib_dvd_iff_entryPt_dvd`: `m ∣ F(k) ↔ α(m) ∣ k`). What remained open
were the *join*-side computations.

This cycle closed them.

1. **Binary join law (sorry filled).** In
   `Catalog/Speculative/AutoResearch/FibonacciEntryPointCharacterization.lean`, the
   long-standing `sorry` in `FibEntryChar.fibEntryPt_mul_coprime` is now a complete
   proof: for coprime `a, b` each admitting an entry point,
   `α(a·b) = lcm(α a, α b)`. The proof equates the two naturals by
   divisibility-extensionality, feeding the principal-ideal characterization
   `fib_dvd_iff_entryPt_dvd` through the coprime split `a·b ∣ F(k) ↔ a ∣ F(k) ∧ b ∣ F(k)`.
   The composite `a·b` is shown to admit an entry point for free, with `F(lcm(α a, α b))`
   as the canonical witness.

2. **Finite join law (new theory).** A new self-contained file,
   `Catalog/Speculative/AutoResearch/FibonacciEntryPointFiniteProduct.lean`, lifts the
   binary law to arbitrary finite products. Working abstractly with any **strong
   divisibility sequence** `u` (`gcd(u m, u n) = u(gcd m n)`) with `u 0 = 0`, it proves
   `FibFiniteProduct.entry_list_prod_coprime`:
   for a list `l` of pairwise-coprime appearing moduli,
   `entry u l.prod = (l.map (entry u)).foldr lcm 1`.
   Supporting results `entry_one` (`entry u 1 = 1`, the empty-product base case) and
   `appears_list_prod` (products of pairwise-coprime appearing moduli again appear) are
   proved with no `sorry`. Two instantiations follow immediately: the Fibonacci sequence
   (`fib_entry_list_prod_coprime`) and the Mersenne/repunit family `u n = aⁿ − 1`
   (`mersenne_entry_list_prod_coprime`, which is the classical
   `ord_{∏ mᵢ} = lcm ord_{mᵢ}`).

Together with the catalog's `gcd ↦ gcd` half, `α` is now exhibited as a genuine
divisibility-lattice morphism, and entry-point computation is fully reduced to the
prime-power factors of the modulus.

## Results summary

- `FibEntryChar.fibEntryPt_mul_coprime` — proved (`sorry` removed); axioms `propext`,
  `Classical.choice`, `Quot.sound`.
- `FibFiniteProduct.entry_one`, `appears_list_prod`, `entry_list_prod_coprime` — proved.
- `FibFiniteProduct.fib_entry_list_prod_coprime`,
  `FibFiniteProduct.mersenne_entry_list_prod_coprime` — proved instantiations.

All new results compile under the catalog's Lean/Mathlib toolchain with no `sorry` and no
nonstandard axioms.

---

## Direction 1 — Prime-power factorization formula for `α(m)`

The finite join law expresses `α(m)` as an `lcm`-fold over *any* pairwise-coprime
factorization. The natural endpoint is the canonical statement in terms of the prime
factorization itself: for `m ≥ 1`,
`α(m) = lcm_{p^e ‖ m} α(p^e)`,
where the join runs over the maximal prime powers dividing `m`. The key insight is that
`Nat.factorization` already packages `m` as a finitely-supported product of coprime prime
powers, so this is the finite join law `entry_list_prod_coprime` applied to the list
`m.factorization.support.map (fun p => p ^ m.factorization p)`, whose pairwise coprimality
is `Nat.Coprime.pow` on distinct primes. Why now? Both ingredients are in place in this
project — the finite join law (this cycle) and unconditional existence of `α(m)` for every
`m ≥ 1` (`FibApparition.fib_apparition_exists`) — so the only remaining work is the
bookkeeping translating `Finsupp.prod` into a pairwise-coprime list. This is falsifiable:
a single `decide`/`native_decide` check on, e.g., `m = 12, 60, 100` against the brute-force
least-`k` either confirms or refutes the formula.

## Direction 2 — `α(p^{e+1}) ∈ {α(p^e), p · α(p^e)}` (the Wall lifting step)

Combined with Direction 1, computing `α(m)` reduces to the prime-power ranks `α(p^e)`, and
those satisfy a sharp recursion: `α(p^{e+1})` is either `α(p^e)` or `p · α(p^e)`.
The key insight is that `p^{e+1} ∣ F(k)` forces `p^e ∣ F(k)` (so `α(p^e) ∣ α(p^{e+1})`), while the
multiplier can only be `1` or `p` because the `p`-adic valuation of `F` along the arithmetic
progression `α(p^e)·ℕ` increases by exactly one per factor of `p` in the index — a
lifting-the-exponent phenomenon. Why now? The entry-point ideal structure
(`fib_dvd_iff_entryPt_dvd`) already reduces the claim to a statement about `v_p(F(α(p^e)·t))`,
turning a divisibility question into a valuation question that LTE-style lemmas in Mathlib
(`multiplicity`, `Nat.Prime`) can attack. Falsifiable: the "Wall–Sun–Sun" anomaly would be
the first prime where the step from `e=1` to `e=2` fails to multiply by `p`; an exhaustive
`α(p)` vs `α(p²)` scan over small primes is a direct empirical test.

## Direction 3 — `α(p) ∣ p − (5/p)` via the Legendre symbol

For a prime `p ≠ 2, 5`, the rank of apparition divides `p − (5|p)`, where `(5|p)` is the
Legendre symbol: `α(p) ∣ p − 1` when `p ≡ ±1 (mod 5)` and `α(p) ∣ p + 1` when
`p ≡ ±2 (mod 5)`. The key insight is that the Fibonacci recurrence is the trace of powers of
the golden-ratio matrix `[[1,1],[1,0]]`, whose order in `GL₂(𝔽_p)` is governed by whether
`5` is a quadratic residue mod `p`; the entry point is exactly the order of this matrix's
action, and Lagrange's theorem in the relevant cyclic/quadratic-extension multiplicative
group gives the divisibility. Why now? The entry-point characterization already identifies
`α(p)` as an order-like invariant, and Mathlib has both `ZMod.legendreSym` and the matrix /
`ZMod p` finite-field machinery; bridging them via the `2×2` companion matrix is the missing
link. Falsifiable: for every prime `p < N`, check `(p − legendreSym p 5) % α(p) == 0`; a
single failure refutes it.

## Direction 4 — Carmichael's primitive-divisor theorem for the infinite tail

`Catalog/Shared/CarmichaelProof.lean` proves that `F(n)` has a primitive prime divisor for
every composite `13 ≤ n ≤ 10000` by `native_decide`, leaving the genuinely hard infinite
tail (`n > 10000`) as a `sorry`. The key insight is that the entry-point viewpoint reframes
primitivity cleanly: a prime `p` is a primitive divisor of `F(n)` iff `α(p) = n`
(`FibEntryChar.entryPt_eq_iff_primitive`), so a primitive divisor exists iff the primitive
part `Φ_n` (the analogue of the cyclotomic factor of `F(n)`) has a prime factor `p` with
`α(p) = n` rather than `α(p) ∣ n` properly — and the only obstructions are "intrinsic"
divisors `p ∣ n`, whose contribution is bounded by Direction 3. Why now? The lower bound
`F(n) ≈ φⁿ` grows exponentially while the intrinsic part is polynomially bounded (each
`p ∣ n` contributes at most one extra factor by the Wall lifting step of Direction 2), so for
`n` past an explicit threshold the primitive part exceeds the intrinsic part and must carry a
new prime. Falsifiable: the claimed threshold is explicit, so any composite `n` above it
whose `F(n)` has no primitive divisor would refute the bound — and `n = 12` is the known
boundary that any correct argument must (and this framing does) exclude.

## Direction 5 — Entry-point lattice morphisms for general Lucas sequences

The abstract `FibFiniteProduct` development depends only on the strong-divisibility identity
and `u 0 = 0`; Fibonacci and Mersenne are merely two models. The key insight is that *every*
non-degenerate Lucas sequence `U_n(P, Q)` is a strong divisibility sequence when
`gcd(P, Q) = 1`, so the entire entry-point lattice theory — meet law, join law, finite join
law, primitive-divisor rigidity — transfers verbatim, unifying the rank of apparition of
Fibonacci numbers, the multiplicative order (`aⁿ − 1`), and Pell/Lucas ranks under one
theorem. Why now? The abstract theorems in this cycle are already stated for an arbitrary
`u` satisfying `IsSDS`; the only new content is a proof that `Nat.gcd (U_m) (U_n) = U_{gcd m n}`
for Lucas sequences, a self-contained induction that does not touch the lattice theory at
all. Falsifiable: pick `(P, Q) = (2, -1)` (Pell) and verify the strong-divisibility identity
and the join law on small indices; failure of the gcd identity for any coprime `(P, Q)` would
refute the unification.
