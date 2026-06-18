# Future Directions — Pisano period as a lattice morphism, and the entry-point cofactor

This cycle (files `Catalog/Logic/FibPisanoLattice.lean` and
`Catalog/Logic/FibPisanoEntryCofactor.lean`) proved, axiom-clean and sorry-free, building on
the catalog's shift representation (`Applications/FibonacciPisanoRepresentation.lean`) and
entry-point duality (`Novelty/FibonacciEntryPointDuality.lean`):

* **C1 (unconditional join law).** `fibPeriod_lcm : π(lcm a b) = lcm(π a, π b)` for *all*
  `a, b` — removing the coprimality hypothesis of the catalog's `pisano_mul_coprime`.
  Plus `fibPeriod_dvd_of_dvd` (monotone) and `fibPeriod_gcd_dvd` (meet bound).
* **C2 (cofactor bound).** `fibPeriod_dvd_four_mul_apparition`/`fibPeriod_dvd_four_mul_fibEntry`:
  `π(p) ∣ 4·z(p)`, and the sandwich `z(p) ∣ π(p) ∣ 4·z(p)`
  (`fibEntry_dvd_fibPeriod_dvd_four_mul`), so the cofactor `π(p)/z(p) ∈ {1,2,4}`.

The decisive new tool, `pisano_dvd_iff_nat : π(m) ∣ k ↔ m ∣ F k ∧ m ∣ F(k+1)-1`, turns every
lattice statement about `π` into elementary ℕ-divisibility, and `fibStep_scalar` shows the
shift acts as the scalar `F(z+1)` at the entry point. These suggest the following testable
conjectures.

## D1 — The cofactor is determined by `z(p) mod 2` and a Legendre symbol

**Conjecture.** For an odd prime `p`, the cofactor `c(p) := π(p)/z(p) ∈ {1,2,4}` is
governed by Cassini's sign `(-1)^{z(p)}` together with the 2-adic valuation of `z(p)`:
`c(p) = 4` iff `z(p)` is odd; `c(p) = 1` iff `(-1)^{z(p)} = 1` is a 4th-power-compatible
rotation; `c(p) = 2` otherwise. Equivalently `c(p)` equals the multiplicative order of
`(-1)^{z(p)}·F(z(p)+1)^{-2}`-type unit, all of which are roots of unity of order dividing 4.

The key insight is that `fibStep_scalar` already proves `Q^{z(p)} = F(z(p)+1)·I` and
`F(z(p)+1)^2 = (-1)^{z(p)}` (`fib_succ_sq`), so the exact cofactor is *literally* the order
of the scalar `F(z(p)+1)` in `(ZMod p)ˣ` — a finite, already-isolated unit, not a new object.

Why now? C2 reduces the cofactor to a single explicit unit `c = F(z(p)+1)` with `c^4 = 1`;
the only remaining work is the case split on `ord(c) ∈ {1,2,4}`, which `fib_succ_sq` makes a
2-line `interval_cases`-style argument rather than an analytic estimate.

## D2 — `π` is a join-morphism but provably NOT a meet-morphism

**Conjecture.** The meet bound `fibPeriod_gcd_dvd` is strict for infinitely many pairs:
there exist `a, b` with `π(gcd a b) ⪇ gcd(π a, π b)`, mirroring the catalog's
`fibEntry_gcd_not_exact`. Concretely `a = 4, b = 6` is conjectured to witness strictness for
`π` exactly as it does for `z`.

The key insight is that `π = orderOf(fibStep)` and `z` share the same divisor lattice via
`pisano_dvd_iff_nat`/`fib_dvd_iff_fibEntry_dvd`, so any meet-strictness witness for `z`
should lift to `π` through the sandwich `z ∣ π ∣ 4z`.

Why now? The lattice machinery (`pisano_dvd_iff_nat`) lets one *compute* `π` on small moduli
purely from ℕ-divisibility of `F k` and `F(k+1)-1`, sidestepping the noncomputability of
`orderOf` and making a `decide`-style boundary certificate feasible.

## D3 — Wall's conjecture / `z(p²) ≠ z(p)` (Wall–Sun–Sun primes)

**Conjecture (famous open).** For every prime `p`, `z(p²) ≠ z(p)`; equivalently no
Wall–Sun–Sun prime exists. With `fibEntry_squarefree` (catalog) and C1 this would give a
complete multiplicative formula `z(p^k) = p^{k-1} z(p)`.

The key insight is that `z(p²) = z(p)` iff `p² ∣ F(z(p))`, a single LTE/valuation condition
on one Fibonacci number, which the scalar identity `Q^{z(p)} = F(z(p)+1)·I` recasts as a
statement about the second-order term of the shift power modulo `p²`.

Why now? The shift representation makes the `mod p²` obstruction an explicit `2×2` companion
matrix computation; pairing it with the catalog's LTE file
(`Algebra/Tropical_p_adic_..._Lifting_the_Exponent_for_Fibonacci_...`) isolates exactly the
valuation `v_p(F(z(p)))` whose value `=1` is the whole conjecture.

## D4 — Carmichael primitive-divisor theorem, the infinite tail

**Conjecture.** Every composite `n > 12` has `primPart n > 1` (so `F n` has a primitive prime
divisor), closing the single `sorry` in `Catalog/Shared/CarmichaelProof.lean`; the range
`n ≤ 10000` is already a `native_decide` certificate.

The key insight is that the join-morphism `z` proven this cycle pinpoints *which* primes are
non-primitive (those with `z(p) ∣ d` for a proper divisor `d ∣ n`), so the primitive part is
controlled by `∏_{p : z(p) = n} p`, sharpening the cyclotomic lower bound `|Φ_n(φ,ψ)|`.

Why now? With `fibEntry_lcm`/`fibEntry_squarefree` and `fibPeriod_lcm` in hand, the counting
of non-primitive primes is now a lattice statement, reducing Zsygmondy/Bang's analytic tail
to a clean comparison between `φ^n/n` growth and the lcm-controlled non-primitive product.

## D5 — Lattice morphism for general nondegenerate Lucas sequences

**Conjecture.** For every Lucas sequence `U(P,Q)` with `gcd(P,Q)=1`, the rank of apparition
`z_U` and the period `π_U` are join-morphisms of `(ℕ, ∣)`, with `z_U(p) ∣ π_U(p) ∣ k·z_U(p)`
for a fixed small `k` depending only on `Q`.

The key insight is that *every* proof in this cycle used only three abstract facts:
`U_{gcd a b} = gcd(U_a, U_b)`, `m ∣ n → U_m ∣ U_n`, and the invertible companion shift
`(a,b) ↦ (b, P·b - Q·a)`; nothing was special to `(P,Q) = (1,-1)`.

Why now? `pisano_dvd_iff_nat` and `fibStep_scalar` are stated entirely through the shift
`Equiv` and the divisibility-sequence identities, so re-deriving them over the companion
matrix of `U(P,Q)` is a verbatim abstraction — the Cassini input becomes `det = Q`, giving
`c^2 = Q^k` and hence a cofactor dividing `2·ord(Q)`.
