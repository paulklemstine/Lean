# Future Directions — The apparition lattice and the road past Carmichael's tail

## Synthesis

This cycle stopped treating the *rank of apparition* as a one-dimensional arithmetic gadget and
started treating it as a **morphism of lattices**. The spine `m ∣ u n ↔ rank u m ∣ n` for a strong
divisibility sequence `IsStrongDivSeq u : u (gcd m n) = gcd (u m) (u n)` is, read carefully, an
order isomorphism between the divisibility poset of *moduli* and the divisibility poset of *indices*.
Order isomorphisms transport meets and joins. So the rank function must intertwine `gcd` with `gcd`
and `lcm` with `lcm`. We proved exactly this, generically and with zero `sorry`:

- `dvd_value_lcm_iff` — two moduli divide `u n` **simultaneously** iff `lcm (rank m₁) (rank m₂) ∣ n`;
  equivalently, the *first common apparition index* of `m₁` and `m₂` is `lcm` of their ranks.
- `rank_lcm_value` / `rank_gcd_value` — `rank u (lcm (u a) (u b)) = lcm a b` and
  `rank u (gcd (u a) (u b)) = gcd a b`. The gcd law is *free*: it is the defining meet law of
  `IsStrongDivSeq` composed with the rigidity lemma `rank_self`.
- `rank_eq_of_dvd_iff` — a reusable "pin": any divisibility-iff with a positive period `D` identifies
  the rank with `D`.

Two classical theorems then fall out as **one-line instances of one engine**, demonstrating a genuine
cross-domain bridge:

- Fibonacci: `fib_lcm_apparition`, `fib_rank_lcm` (for `a, b ≥ 3`);
- Mersenne / `aⁿ − 1`: `mersenne_lcm_apparition` (for `a ≥ 2`, `p, q ≥ 1`).

All results live in `Catalog/Applications/RankApparitionLcmEngine.lean`, are self-contained against
`import Mathlib`, and reuse the catalog's existing notion of `IsStrongDivSeq` from
`UnifiedRankOfApparition.lean` and `StrongDivisibilitySequences.lean`.

## Results summary

| Theorem | Statement | Status |
|---|---|---|
| `dvd_value_lcm_iff` | `(m₁ ∣ u n ∧ m₂ ∣ u n) ↔ lcm (rank m₁) (rank m₂) ∣ n` | proved, no sorry |
| `rank_lcm_value` | `rank u (lcm (u a) (u b)) = lcm a b` | proved, no sorry |
| `rank_gcd_value` | `rank u (gcd (u a) (u b)) = gcd a b` | proved, no sorry |
| `rank_eq_of_dvd_iff` | divisibility-iff pins the rank to `D` | proved, no sorry |
| `fib_lcm_apparition` | `lcm (F a) (F b) ∣ F n ↔ lcm a b ∣ n` | proved, no sorry |
| `fib_rank_lcm` | `rank F (lcm (F a) (F b)) = lcm a b` | proved, no sorry |
| `mersenne_lcm_apparition` | `lcm (aᵖ−1) (aᵠ−1) ∣ (aⁿ−1) ↔ lcm p q ∣ n` | proved, no sorry |

## Open status of Carmichael's tail

The single genuine `sorry` remaining in the wider corpus is the *infinite tail* of Carmichael's
primitive-divisor theorem (`fib_carmichael_composite` in `Catalog/Shared/CarmichaelProof.lean`, the
case "composite `n > 10000`"). The finite window `13 ≤ n ≤ 10000` is closed by `native_decide`; the
tail is the full classical theorem and is **not** reachable by computation. The directions below are
chosen to build the machinery that tail actually needs.

---

## Direction 1 — A finite `lcm`-of-ranks closure operator and "joint Pisano period"

Generalize `dvd_value_lcm_iff` from two moduli to a `Finset` of moduli: for `S : Finset ℕ` each with a
rank, `(∀ m ∈ S, m ∣ u n) ↔ (S.lcm (rank u ·)) ∣ n`, and prove that the rank of `S.lcm (u ·)` equals
`S.lcm id` on the index side. **The key insight is** that the apparition spine is not merely an order
iso but a *lattice* iso, so it commutes with arbitrary finite joins, turning "the first index where a
whole family of moduli simultaneously appears" into a single `Finset.lcm` computation. **Why now?**
We already have the two-element join law and the `rank_eq_of_dvd_iff` pin in hand; the finite version
is the inductive closure of exactly these two lemmas and immediately yields a constructive algorithm
for the joint Pisano period of any finite modulus set — a falsifiable, `#eval`-checkable claim.

## Direction 2 — Repunits and Lucas sequences as a third and fourth instance

Instantiate the engine on base-`b` repunits `R_n = (bⁿ − 1)/(b − 1)` and on general Lucas sequences
`U_n(P,Q)` with `gcd(Q, ...) = 1`, proving `R_a ∣ R_b ↔ a ∣ b` and the corresponding `lcm` apparition
law as further one-liners. **The key insight is** that the *only* hypotheses the engine consumes are
`IsStrongDivSeq u` plus strict growth, so any sequence satisfying the gcd meet-law is automatically a
client — the Fibonacci/Mersenne pair is just the first two members of an open-ended family. **Why now?**
Mathlib already carries `Nat.sub_one_lt`, `Nat.pow_sub_one_gcd_pow_sub_one`, and the Lucas-sequence
divisibility API; the repunit meet-law reduces to the Mersenne one we already instantiated, so the
marginal cost per new instance is near zero and each instance is independently testable.

## Direction 3 — The primitive part as the Möbius/`lcm`-complement of the apparition lattice

Define, for a strong divisibility sequence, the *intrinsic* (primitive) part of `u n` as the part of
`u n` coprime to every `u d` with `d` a proper divisor of `n`, and prove it equals the lattice
complement of `lcm_{d ∣ n, d < n} (u d)` inside `u n`. **The key insight is** that "primitive prime
divisor" is precisely "a prime whose rank is exactly `n`", and the join law `dvd_value_lcm_iff` makes
the set of non-primitive primes equal to those dividing `lcm` of proper-divisor values — so primitivity
becomes a *lattice-complement* statement rather than an ad-hoc sieve. **Why now?** The catalog already
contains a computational `primPart`/`fibCoprimePart` sieve (in `CarmichaelProof.lean` and
`CarmichaelComposite.lean`); recasting it through the proven join law would give it a *closed-form
algebraic characterization*, the missing conceptual bridge between the finite `native_decide` window
and the infinite tail.

## Direction 4 — A growth/counting bound to attack the Carmichael tail

Combine the lattice-complement description of the primitive part (Direction 3) with the Fibonacci
growth estimate `φ^{n-2} ≤ F n ≤ φ^{n-1}` to show that for composite `n` large enough, the product of
all proper-divisor values `∏_{d ∣ n, d < n} F d` is strictly smaller than `F n`, hence the primitive
part exceeds `1`. **The key insight is** that the tail of Carmichael's theorem is fundamentally a
*size race* — the intrinsic part wins because `F n` grows exponentially in `n` while the extrinsic part
is bounded by a product over the (sparse, smaller) proper divisors — and the lattice picture isolates
exactly which quantity must be bounded. **Why now?** Mathlib has `Nat.fib` growth lemmas and the
golden-ratio bounds; with Direction 3 turning "primitive divisor exists" into "extrinsic product `< F n`",
the tail reduces to a clean, falsifiable analytic inequality rather than deep cyclotomic algebra.

## Direction 5 — Decidable apparition spectra and an effective rank algorithm

Package `rank` as a *computable* function `rankCompute u fuel m` with a proof that it agrees with the
noncomputable `rank` once `fuel` exceeds the true rank, and expose `#eval`-able apparition spectra
`{rank u p : p prime ≤ N}`. **The key insight is** that although `rank` is defined via `Nat.find`
(noncomputable), the spine `rank_dvd_iff` plus the `rank_eq_of_dvd_iff` pin give a *terminating
bounded search* whose correctness is already proven, so constructivity is recoverable without any new
mathematics. **Why now?** The engine's lemmas are exactly the loop invariant and termination
certificate such an algorithm needs; turning the abstract rank into a verified algorithm makes every
theorem in this file empirically checkable and feeds concrete data (apparition spectra) into the
size-race conjecture of Direction 4.
