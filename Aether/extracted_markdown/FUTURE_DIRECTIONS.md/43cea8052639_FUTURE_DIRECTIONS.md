# Future Directions: The Rank of Apparition as a Cross-Domain Invariant

## Synthesis

The previous cycle isolated the *rank of apparition* `r(p) = min { k > 0 : p ∣ F(k) }`
as the organizing principle behind Fibonacci divisibility, and the catalog already
contains two complementary developments: a **Fibonacci-specific** rank theory
(`Catalog/Applications/RankOfApparition.lean`: `fibRank`, the spine
`m ∣ F n ↔ r(m) ∣ n`, `fibRank_fib`, `fib_prime_index_has_primitive`) and a
**structure-only** theory of strong divisibility sequences
(`Catalog/Applications/StrongDivisibilitySequences.lean`: `IsStrongDivSeq`,
`IsPrimitive`, `isPrimitive_unique`, the counting laws) which, crucially, *carried
no rank function at all*.

This cycle (`Catalog/Shared/StrongDivisibilityRankBridge.lean`, `sorry = 0`) fuses
the two strands and pushes them across a domain boundary:

- it equips an **arbitrary** strong divisibility sequence `u` with a rank-of-apparition
  function `seqRank u`, and proves the **spine** `m ∣ u n ↔ seqRank u m ∣ n` and the
  **primitivity characterization** `IsPrimitive u p n ↔ seqRank u p = n` at full
  generality — so the catalog's entire Fibonacci apparition theory becomes a single
  instantiation rather than a parallel re-derivation;
- it then closes a genuinely cross-domain loop on the **Mersenne family** `u(n) = aⁿ − 1`:
  `seqRank (mer a) m = orderOf (a : ZMod m)`. The number-theoretic apparition invariant
  `r(m)` and the group-theoretic invariant *multiplicative order of `a` mod `m`* are
  literally the same natural number.

The decisive realization is that **none of the divisibility scaffolding ever used a
property of Fibonacci beyond the strong-divisibility law `u(gcd m n) = gcd(u m)(u n)`**.
Once that is abstracted, the rank function and its spine are forced, and they specialize
verbatim to Fibonacci, to `aⁿ − 1`, and (with the strong-divisibility input swapped) to
any nondegenerate Lucas sequence.

## Results Summary

| Theorem | Statement | Status |
|---|---|---|
| `seqRank_spine` | `m ∣ u n ↔ seqRank u m ∣ n` for any strong divisibility sequence | proved |
| `isPrimitive_iff_seqRank_eq` | primitive at `n` ↔ `seqRank u p = n` | proved |
| `mer_dvd_iff_orderOf_dvd` | `m ∣ aⁿ − 1 ↔ orderOf (a : ZMod m) ∣ n` | proved |
| `seqRank_mer_eq_orderOf` | rank of apparition `= orderOf (a : ZMod m)` | proved |

Supporting, also proved: `IsStrongDivSeq.dvd_of_dvd`, `mer_isStrongDivSeq`,
`mer_hasRank_of_coprime` (existence via Euler's totient), `fib_isStrongDivSeq`.

## Research Directions

### 1. A typeclass `StrongDivisibilitySequence` that absorbs Fibonacci, Mersenne, and Lucas at once

The four catalog files developing apparition theory each re-prove the same lemmas for
their own sequence. The conjecture is operational: bundling `IsStrongDivSeq u`, `u 0 = 0`,
`u 1 = 1`, and a `HasRank`-totality field into a single typeclass yields an interface from
which `seqRank_spine`, `isPrimitive_iff_seqRank_eq`, the lattice meet/join laws, and the
density counts all follow with **no per-sequence proof**, and every catalog Fibonacci
theorem becomes one `instance` line. **The key insight is** that the present file already
proves the spine and primitivity law using *only* the strong-divisibility hypothesis, so
the typeclass is not a hope but a refactor: the load-bearing content is done and merely
needs repackaging behind a class with `Nat.fib`, `fun n => aⁿ − 1`, and a generic Lucas
`U(P,Q)` as instances. **Why now?** With both the abstract spine (this file) and the
abstract counting laws (`StrongDivisibilitySequences.lean`) formalized, the only missing
ingredient is the strong-divisibility law for Lucas sequences `gcd(U_m,U_n)=U_{gcd}`, which
is itself a clean, finite induction — after which a single typeclass eliminates the
duplication the catalog-synthesis brief explicitly flags.

### 2. Rank divides `p ± 1`: the entry-point law from the order bridge

Conjecture: for a prime `p ∉ {2,5}`, `r(p) ∣ p − 1` when `5` is a quadratic residue mod `p`
and `r(p) ∣ p + 1` otherwise; equivalently `r(p) ∣ p − (5/p)` (Legendre symbol). The
Mersenne analogue is already a theorem in disguise here: `seqRank_mer_eq_orderOf` plus
Fermat's little theorem gives `r_a(p) = orderOf(a : ZMod p) ∣ p − 1` immediately, for the
`aⁿ − 1` sequence. **The key insight is** that `seqRank_mer_eq_orderOf` turns "rank divides
`p − 1`" into "the order of a finite-field unit divides the group order", i.e. Lagrange's
theorem — and the Fibonacci case is the same statement transported through the
`x² = x + 1` quadratic extension `ZMod p[φ]`, where Frobenius pins the order to divide
`p − (5/p)`. **Why now?** The order-theoretic half is *finished* for Mersenne in this file;
the Fibonacci half only needs the companion-matrix / `ZMod p`-algebra embedding of `φ`,
turning a hard-looking apparition bound into a Lagrange-order computation.

### 3. An effective, `decide`-checkable rank algorithm with a proven search bound

Conjecture: define `rankBudget a m := m.totient`; then for `Nat.Coprime a m` we have
`seqRank (mer a) m ≤ rankBudget a m`, hence `seqRank (mer a)` is computable by a bounded
search, and for Fibonacci `r(m) ≤ ` (Pisano-period bound) `≤ 6m`. **The key insight is**
that `mer_hasRank_of_coprime` already exhibits `φ(m)` as an explicit apparition witness, so
`seqRank ≤ φ(m)` is a one-line corollary of `seqRank_min`/`Nat.find_le`; the noncomputable
`if … Nat.find … else 0` then collapses to a verified `List.find?` over `[1 .. φ(m)]`.
**Why now?** The existence witness (Euler's totient) is in hand and totally explicit, so
upgrading `seqRank` from `noncomputable` to an executable, `decide`-friendly function is
pure bookkeeping — and it immediately makes the catalog's `native_decide` Carmichael-range
checks expressible directly in terms of `seqRank` rather than ad-hoc divisibility loops.

### 4. Density of joint apparition and a Mersenne ↔ Fibonacci comparison theorem

Conjecture: for fixed coprime bases the natural density of indices `n` with `m ∣ aⁿ − 1` is
exactly `1 / orderOf(a : ZMod m)`, and combining two sequences (e.g. Fibonacci and `2ⁿ − 1`)
the joint apparition density is `1 / lcm(r_F(m), r_2(m))`. **The key insight is** that
`apparition_count` in `StrongDivisibilitySequences.lean` already gives density `1/r` from a
primitive divisor, and `seqRank_mer_eq_orderOf` identifies `r` with a computable order, so
the density statement becomes a concrete arithmetic-progression count with an *explicit*
modulus rather than an abstract `r`. **Why now?** Both the abstract density law and the
rank=order identity are proved; the remaining step is to feed one into the other and read
off the lcm, a finite combinatorial merge with no new analysis.

### 5. Primitive divisors of `aⁿ − 1` (Zsygmondy) via the abstract primitivity law

Conjecture: for `a ≥ 2` and `n ∉ {1, 2, 6}` (the Zsygmondy exceptions, plus `a = 2, n = 6`),
`aⁿ − 1` has a prime `p` with `seqRank (mer a) p = n`, i.e. a *primitive* prime divisor;
equivalently `orderOf(a : ZMod p) = n` for some prime `p ∣ aⁿ − 1`. **The key insight is**
that `isPrimitive_iff_seqRank_eq` reduces "primitive divisor exists" to "some prime has
rank exactly `n`", and via `seqRank_mer_eq_orderOf` that is "some prime `p ∣ aⁿ−1` has
`a` of order exactly `n` mod `p`" — exactly the statement Zsygmondy's cyclotomic argument
proves, now phrased entirely inside the formalized rank/order dictionary. **Why now?** The
primitivity ⟺ rank characterization is finished and sequence-agnostic, so a future cycle can
attack Zsygmondy and Carmichael's Fibonacci theorem *through the same lemma*, with only the
sequence-specific cyclotomic size estimate left to supply.
