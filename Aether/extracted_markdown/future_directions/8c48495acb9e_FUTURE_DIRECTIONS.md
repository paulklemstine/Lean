# Future Directions — Fibonacci rank of apparition & Pisano period

This cycle proved that the Fibonacci **rank of apparition** `z(p) = fibEntry p` is a full
lattice homomorphism of `(ℕ, ∣)` (`fibEntry_lcm`, `fibEntry_dvd_of_dvd`, with the meet law
inherited from `fib_dvd_gcd_iff`), constructed the **Pisano period** `π(p) = fibPeriod p` from
the Fibonacci-shift dynamics on `ZMod p × ZMod p`, characterized its return-time ideal
(`fibPeriod_dvd_iff`), and proved the bridge `z(p) ∣ π(p)` (`fibEntry_dvd_fibPeriod`).
All results are in `Catalog/Novelty/FibEntryPisano.lean`, axiom-clean and sorry-free.

The conjectures below were each spot-checked computationally (moduli ≤ 60 unless noted) and are
stated so a follow-up cycle can drop them directly into Lean.

## C1 — The Pisano period is itself a lattice morphism

Mirror the `z`-theorems for `π`. Computationally verified for all `m, n ≤ 12`:
`π(lcm m n) = lcm (π m) (π n)` and `m ∣ n → π m ∣ π n`.

```lean
theorem fibPeriod_lcm (m n : ℕ) :
    fibPeriod (Nat.lcm m n) = Nat.lcm (fibPeriod m) (fibPeriod n) := by sorry
theorem fibPeriod_dvd_of_dvd {m n : ℕ} (h : m ∣ n) (hm : 1 ≤ m) :
    fibPeriod m ∣ fibPeriod n := by sorry
```
**Route:** lift `fibPeriod_dvd_iff` to a "period duality" `π p ∣ k ↔ (p ∣ F k ∧ p ∣ F (k+1) - 1)`
(read the two coordinates of `fibPair`), then transport `Nat.lcm_dvd_iff` across it exactly as
`fibEntry_lcm` does. The CRT step `ZMod (lcm m n) ≅ ZMod m × ZMod n` on coprime parts is the
only delicate ingredient.

## C2 — The period/entry cofactor is always in {1, 2, 4}

For every modulus `p ≥ 1`, `π(p) / z(p) ∈ {1, 2, 4}`, i.e. `π(p) ∣ 4 · z(p)`. Verified for all
primes `p < 60` (observed values: 1, 2, 4). This is the classical statement that the Fibonacci
sequence has multiplicative order 1, 2, or 4 of `(-1)` modulo `p` relative to its entry point.

```lean
theorem fibPeriod_dvd_four_mul_fibEntry {p : ℕ} (hp : 1 ≤ p) :
    fibPeriod p ∣ 4 * fibEntry p := by sorry
```
**Route:** `(F (z+1))^2 ≡ ±1` at the entry point forces the residual rotation in
`ZMod p × ZMod p` to be a 1st/2nd/4th root, so `π ∣ 4 z`.

## C3 — Wall's conjecture (entry point at prime powers)

For a prime `p` and `k ≥ 1`, `z(p^{k}) = p^{k-1} · z(p)` **unless** `p` is a Wall–Sun–Sun prime
(none are known). The clean unconditional sub-claim, equivalent to the nonexistence of
Wall–Sun–Sun primes, is `z(p^2) ≠ z(p)`:

```lean
theorem fibEntry_prime_sq_ne {p : ℕ} (hp : Nat.Prime p) :
    fibEntry (p ^ 2) ≠ fibEntry p := by sorry   -- famous OPEN problem
```
Combined with `fibEntry_squarefree` (already proved) and C1, a resolution would give a complete
multiplicative formula for `z` on all of `ℕ`.

## C4 — Carmichael primitive-divisor theorem, infinite tail

Close the single standing `sorry` in `Catalog/Shared/CarmichaelProof.lean`: every composite
`n > 12` makes the primitive part `primPart n > 1`, hence `F n` has a primitive prime divisor.
The finite range `n ≤ 10000` is already discharged by `native_decide`; the open part is the tail.

```lean
theorem fib_carmichael_composite_tail (n : ℕ) (hn : 10000 < n) (hnp : ¬ Nat.Prime n) :
    1 < primPart n := by sorry
```
**Route:** lower-bound the primitive part by `|Φ_n(φ, ψ)|` (Fibonacci cyclotomic factor) and use
`φ^{n} / n`-type growth to beat the product of small prime contributions — a Zsygmondy/Bang
analytic estimate. The lattice morphism `z` proven this cycle pinpoints *which* primes are
non-primitive (those with `z(p) ∣ d` for a proper divisor `d ∣ n`), sharpening the counting.

## C5 — Lattice morphism for general Lucas sequences

The proofs in `FibEntryPisano.lean` used only `Nat.fib_gcd`, `Nat.fib_dvd`, and the invertible
shift. Conjecture: for **every** nondegenerate Lucas sequence `U(P,Q)` with `gcd(P,Q)=1`, the
rank of apparition `z_U` is a lattice homomorphism of `(ℕ, ∣)` and `z_U(p) ∣ π_U(p)`.

```lean
-- with U : ℕ → ℤ the Lucas sequence and zU its rank of apparition
theorem lucasEntry_lcm (P Q m n : ℕ) (h : Nat.Coprime P Q) :
    zU P Q (Nat.lcm m n) = Nat.lcm (zU P Q m) (zU P Q n) := by sorry
```
**Route:** abstract this cycle's proofs over the divisibility-sequence axioms
`U_{gcd a b} = gcd(U_a, U_b)` and `m ∣ n → U_m ∣ U_n`; the shift `(a,b) ↦ (b, P·b - Q·a)` is the
companion-matrix `Equiv`, giving totality and the period verbatim.
