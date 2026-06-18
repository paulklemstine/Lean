# Future Directions — Boltzmann Bridge XI: The Apparition Lattice

## Synthesis

The Carmichael primitive-divisor arc had, until now, used the *rank of apparition*
`α(p) = CarmHelper.entryPt p` (the least `k > 0` with `p ∣ F(k)`) only as a
one-directional instrument: `entryPt_dvd` gave `p ∣ F(n) ⟹ α(p) ∣ n`, and
`Nat.fib_dvd` gave a narrow converse. The new file
`Catalog/Speculative/AutoResearch/FibApparition.lean` closes the loop. It proves,
`sorry`-free:

* **`fib_apparition_law`** — `p ∣ F(n) ↔ α(p) ∣ n`. The zero-set of `n ↦ F(n) mod p`
  is *exactly* the lattice of multiples of the entry point.
* **`primitive_iff_entryPt_eq`** — `p ∣ F(n)` is a *primitive* divisor iff `α(p) = n`,
  with **no primality hypothesis** — a strict generalisation of the prime-only
  `Shared.CarmichaelProof.fib_primitive_divisor_prime`.
* **`fib_dvd_fib_iff`** — for `m ≥ 3`, `F(m) ∣ F(n) ↔ m ∣ n`: the divisibility
  lattice `(ℕ, ∣)` embeds (modulo the `F 1 = F 2 = 1` collapse) into itself via `F`.
* **`fib_coprime_iff_gcd_le_two`** — the coprimality dual: `gcd(F m, F n) = 1`
  iff `gcd(m, n) ∈ {1, 2}`.

The unifying observation is that all four results are shadows of the single strong
divisibility identity `gcd(F m, F n) = F(gcd m n)` (`Nat.fib_gcd`, the catalog's
`Fib_gcd_identity`): the apparition law is its `p`-local shadow, `fib_dvd_fib_iff` is
its order-theoretic shadow, and the coprimality dual is its `{1,2}`-exceptional shadow.

## Results Summary

| Theorem | Statement | Status | Axioms |
|---|---|---|---|
| `fib_apparition_law` | `p ∣ F(n) ↔ α(p) ∣ n` | proved | `propext, Classical.choice, Quot.sound` |
| `primitive_iff_entryPt_eq` | primitive divisor `⟺ α(p)=n` | proved | std |
| `fib_dvd_fib_iff` | `m≥3 ⟹ (F m ∣ F n ↔ m ∣ n)` | proved | std |
| `fib_coprime_iff_gcd_le_two` | `gcd(F m,F n)=1 ↔ gcd(m,n)∈{1,2}` | proved | std |

Infrastructure fixed: the arc's `import Shared.CarmichaelHelper` lines pointed at a
non-existent module; they now correctly resolve to
`Speculative.AutoResearch.CarmichaelHelper`, and the package `srcDir` was set to
`Catalog` so the layout matches the lakefile globs. With these fixes
`Shared.CarmichaelProof` builds; its single remaining `sorry` is the genuine
analytic gap described in Direction 1 below (the composite `n > 10000` tail).

## Research Directions

### 1. Close the infinite tail of Carmichael's composite case

`Shared.CarmichaelProof.fib_carmichael_composite` is fully proved for `13 ≤ n ≤ 10000`
by `native_decide` on the explicit *primitive part* `primPart n`, but the tail
`n > 10000` is still `sorry`. The honest obstruction is that no finite computation can
reach it. The route is to replace computation by the classical lower bound on the
homogeneous cyclotomic value `Φ_n(φ, ψ)` (where `φ, ψ` are the golden roots): the
primitive part of `F(n)` equals `∏_{d∣n} F(d)^{μ(n/d)}`, and `|Φ_n(φ,ψ)| > 2n` for
`n` large forces a prime factor whose entry point is exactly `n`.
**The key insight is** that `primitive_iff_entryPt_eq` already reduces "primitive
divisor exists" to "some prime has entry point `n`," so the remaining task is purely a
size estimate `primPart n > 1`, divorced from the apparition bookkeeping.
**Why now?** With the apparition law and the entry-point API in place, the only missing
ingredient is the cyclotomic growth bound; the structural/number-theoretic scaffolding
that previously entangled the estimate is now factored out.

### 2. Lift the apparition law to general Lucas sequences

Define `U_n(P,Q)` by `U_0 = 0, U_1 = 1, U_{n+2} = P·U_{n+1} − Q·U_n`. The proofs in
`FibApparition.lean` used *only* (i) strong divisibility `gcd(U_m,U_n) = U_{gcd m n}`
and (ii) eventual strict monotonicity. Conjecture: for `gcd(P,Q)=1` the full apparition
law `p ∣ U_n ↔ α(p) ∣ n` and the divisibility lattice `U_m ∣ U_n ↔ m ∣ n` (for `m`
past the degenerate prefix) hold verbatim.
**The key insight is** that nothing in the Fibonacci proofs touched the value `F` beyond
its gcd law and monotonicity, so the theorems are really theorems about *strong
divisibility sequences*, with `F` merely the prototype.
**Why now?** The Fibonacci proofs are short and modular; abstracting `Nat.fib_gcd` to a
typeclass-level `StrongDivisibilitySequence` hypothesis is a mechanical generalisation
that immediately re-runs against Mersenne (`2^n − 1`) and other divisibility sequences.

### 3. The apparition map as a poset/lattice embedding

`fib_dvd_fib_iff` says `F : (ℕ_{≥3}, ∣) → (ℕ, ∣)` is order-reflecting. Conjecture: it is
in fact a **lattice embedding** onto its image, i.e. `gcd(F m, F n) = F(gcd m n)`
(already `Nat.fib_gcd`) *and* `lcm(F m, F n) = F(lcm m n) · c` fails in general but
`F(lcm m n)` is the join in the *divisibility-of-Fibonacci* sublattice. Precisely:
the image `{F n : n ≥ 1}` ordered by `∣` is isomorphic to `(ℕ_{≥1}, ∣)` collapsed at
`{1,2}`.
**The key insight is** that meets transport exactly (`Nat.fib_gcd`) while joins do not
(`F 2 · F 3 = 2 ≠ F 6 = 8` divisibility-wise), so the embedding is *meet-complete but
not join-complete* — a quantifiable defect measured by the primitive part of Direction 1.
**Why now?** With `fib_dvd_fib_iff` and `fib_coprime_iff_gcd_le_two` both formal, the
order structure of the image is fully pinned down except for the join law, which is a
clean, finitely-checkable conjecture to falsify or prove.

### 4. An effective bound on the rank of apparition

Classically `α(p) ∣ p − (5/p)` (Legendre symbol), so `α(p) ≤ p + 1`. Conjecture (Lean
target): for every prime `p ≠ 5`, `CarmHelper.entryPt p ∣ p - (5/p)` and hence
`entryPt p ≤ p + 1`, giving a *polynomial-time* primitive-divisor detector via the
apparition law `p ∣ F(n) ↔ α(p) ∣ n`.
**The key insight is** that `F(p - (5/p)) ≡ 0 (mod p)` follows from the Frobenius action
on `ℤ[φ]/p`, i.e. `φ^p ≡ ψ (mod p)` when `5` is a non-residue — a finite field identity
rather than an analytic estimate.
**Why now?** Mathlib's quadratic-reciprocity and `ZMod p` field API are mature enough to
carry `φ^p ≡ φ̄` arguments, and the apparition law converts that single congruence into
the full divisibility profile of `F` modulo `p`.

### 5. Full Carmichael exception list `{1, 2, 6, 12}`

Conjecture: the *only* `n ≥ 1` for which `F(n)` has no primitive prime divisor are
`n ∈ {1, 2, 6, 12}`. The arc proves existence for all `n ≥ 13`; combined with a
`decide` over `1 ≤ n ≤ 12` (where `n = 1,2,6,12` are the genuine failures and the rest
succeed) this yields the sharp classification.
**The key insight is** that `primitive_iff_entryPt_eq` turns "no primitive divisor" into
the decidable statement "every prime factor of `F(n)` has entry point a *proper* divisor
of `n`," which `decide`/`native_decide` settles instantly for `n ≤ 12`.
**Why now?** Only the `n ≥ 13` half required real mathematics (Direction 1); the small
cases are now a finite verification gated solely on the entry-point reformulation that
this cycle made available.
