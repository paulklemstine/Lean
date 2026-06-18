# Future Directions — Korselt Criterion & Divisor-Lattice Tropical Flatness

Derived from the cycle that produced `Shared/KorseltCarmichael.lean` and
`Bridges/KorseltTropicalFlatness.lean`. In that cycle we proved:

- `Korselt n → FermatProperty n` (Korselt's criterion forces the universal Fermat
  congruence `a^(n-1) ≡ 1 [MOD n]`), via Fermat-little-theorem lifting and
  squarefree recombination;
- `Korselt n ↔ Squarefree n ∧ ∀ p∣n, (p-1).factorization ≤ (n-1).factorization`
  (Korselt = pointwise domination of prime-exponent / valuation profiles);
- `dvd_iff_factorization_le` (divisibility = valuation-profile domination = tropical
  flatness);
- the Berggren shear law `berggren_M₃'^k = !![1,2k;0,1]` and
  `berggren_M3_pow_reduces_iff : (M₃'^k mod m = 1) ↔ m ∣ 2k`.

The conjectures below extend these findings.

---

## Conjecture 1 — Korselt is *equivalent* to the Carmichael/Fermat property

**Statement.** For composite `n ≥ 2`, `FermatProperty n ↔ Korselt n`. We have proved
`←`; the open part is `→` (composite Fermat ⟹ squarefree and `(p-1)∣(n-1)`).

*The key insight is* that the converse is a *local* extraction: pick a primitive root
`g` mod each prime power `p^e ∥ n`; the order of `g` is `φ(p^e)`, and `FermatProperty`
forces `φ(p^e) ∣ n-1`. If `e ≥ 2` then `p ∣ φ(p^e) ∣ n-1` while `p ∣ n`, contradicting
`gcd(n,n-1)=1`; hence `n` is squarefree and `(p-1)∣(n-1)`. The whole argument is the
*inverse* of the recombination lemma already formalized.

**Why now?** The forward recombination engine (`dvd_of_squarefree_of_forall_prime_dvd`)
and the local Fermat lemma (`pow_modEq_one_of_sub_one_dvd`) are already in the catalog,
so only the primitive-root extraction (`ZMod.exists_primitiveRoot` / `IsCyclic` of
`(ZMod p)ˣ`) remains to be wired in.

## Conjecture 2 — Every Carmichael number has at least three prime factors

**Statement.** If `Korselt n` and `n` is composite, then `n.primeFactors.card ≥ 3`.

*The key insight is* that tropical flatness is *obstructed* in low dimension: if
`n = p·q` with `p < q` then `(q-1) ∣ (n-1) = pq-1 = p(q-1) + (p-1)` forces `(q-1)∣(p-1)`,
impossible for `0 < p-1 < q-1`. So the valuation profile of `n-1` cannot dominate the
profile of the *largest* `q-1` with only two prime coordinates.

**Why now?** This is a direct, fully arithmetic corollary of `korselt_iff_flat`: it needs
only the two-factor case analysis plus `omega`/divisibility, no new heavy machinery, and
it sharpens the non-vacuousness already witnessed by `561, 1105, 1729`.

## Conjecture 3 — Quantitative flatness defect and a Korselt certificate

**Statement.** Define the *flatness defect*
`δ(n) = ∑_{q prime} max(0, (max_{p∣n} v_q(p-1)) − v_q(n-1))`. Then `Korselt n` (for
squarefree `n`) holds iff `δ(n) = 0`, and `δ` is computable, giving a decision procedure
that avoids primality testing of `n` itself.

*The key insight is* that `δ` linearizes the lattice condition: divisibility becomes a
single nonnegativity test on a finitely-supported valuation vector (the tropical/`max`
structure of `Bridges/CategoricalTropicalUltrametric.lean`), turning "`(p-1)∣(n-1)` for
all `p`" into one scalar.

**Why now?** `korselt_iff_flat` already expresses Korselt as `factorization ≤`; packaging
the gap as a `Finsupp`-supported sum is a short step and connects directly to the
existing tropical valuation objects and `vdepth_sum_le` in `Computation/PadicValuationDepth.lean`.

## Conjecture 4 — Berggren shear order equals the additive order of `2` mod `m`

**Statement.** The order of the reduced Berggren shear `M₃' mod m` in `GL₂(ZMod m)` is
`m / gcd(2,m)`, i.e. the least `k > 0` with `m ∣ 2k`.

*The key insight is* that `berggren_M3_pow_reduces_iff` already isolates the *only*
nontrivial coordinate (`2k`); the order is therefore governed by a one-dimensional
additive-order computation, the matrix analogue of the single divisibility test
`(p-1)∣(n-1)` in Korselt's criterion.

**Why now?** `berggren_M3_pow` and `berggren_M3_pow_reduces_iff` reduce the problem to
`Nat`-level: `IsLeast {k | 0 < k ∧ m ∣ 2k} (m / gcd 2 m)`, provable by `omega`-style
divisibility reasoning with no matrix theory left.

## Conjecture 5 — Flat reduction preserves Pythagorean primitivity across all prime divisors

**Statement.** For the Berggren generators acting on primitive triples, the reduction mod
`n` preserves primitivity of the orbit simultaneously at every prime `p ∣ n` exactly when
`n` is squarefree with a flat valuation profile (a Korselt-type condition on the shear
exponents arising along tree paths).

*The key insight is* that both phenomena are the *same* simultaneous-domination event:
the Carmichael condition makes one exponent `n-1` annihilate every local order `p-1`, and
flat Berggren reduction makes one path-length exponent annihilate the shear order at every
`p ∣ n`. The bridge file already exhibits both as instances of `dvd_iff_factorization_le`.

**Why now?** With `berggren_M3_pow_reduces_iff` and `korselt_iff_flat` both formalized in
`Bridges/KorseltTropicalFlatness.lean`, the remaining content is to package the
generator-orbit reduction (using `BerggrenLorentz` Pythagorean preservation from
`Algebra/BerggrenLorentz/Core.lean`) and quantify the simultaneity, completing the
three-domain Shared ↔ Computation ↔ Pythagorean bridge.
