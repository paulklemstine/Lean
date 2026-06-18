# Future Directions — Boltzmann Bridge X: Primitive Divisors as a Strong-Divisibility Phenomenon

## Synthesis

The Carmichael arc of this catalog set out to prove that every Fibonacci number `F(n)`
with `n ≥ 13` carries a *primitive prime divisor* — a prime dividing `F(n)` but no earlier
term. Two cycles back this was split into a prime-index case and a composite-index case,
with the prime case delegated to a file `Shared.CarmichaelHelper` that **was never written**
(the catalog imported a phantom lemma `fib_primitive_divisor_prime`), and the composite case
delegated to `Shared.CarmichaelProof.fib_carmichael_composite`, whose *infinite tail*
(`n > 10000`, beyond the `native_decide` window) was left as `sorry`.

This cycle closes the prime case **honestly and at full generality**, and in doing so
discovers that the prime case is not a Fibonacci fact at all — it is a fact about *every
strong divisibility sequence normalized by `u 1 = 1`*. The catalog's generic
rank-of-apparition engine (`Applications.UnifiedRankOfApparition`: `IsStrongDivSeq`, `rank`,
`HasRank`, the spine `rank_dvd_iff`, `rank_min`, `dvd_rank`) turns out to be exactly the
machine needed: a prime `q ∣ u(p)` has rank dividing the prime `p`, and the rank cannot be
`1` (else `q ∣ u(1) = 1`), so the rank equals `p` and `q` is primitive. The *same* one-line
engine call yields the Fibonacci/Carmichael prime case **and** Bang's theorem at prime
exponents (`2^p − 1` has a primitive prime divisor). The two classical theorems are facets of
one truth.

What remains genuinely open is the *composite* case for large `n`. That is where the "every
prime divisor is automatically primitive" miracle breaks: a prime dividing `u(mk)` may have
rank a proper divisor of `mk`. This is the true mathematical content of Carmichael/Zsygmondy,
and it is the spine of the next cycle.

## Results Summary (this cycle, all `sorry = 0`, axioms = {propext, Classical.choice, Quot.sound})

- `Shared/CarmichaelHelper.lean`
  - `fib_primitive_divisor_prime` — the previously-phantom prime case of Carmichael, now a
    real theorem. Restores compilation of both `Shared.CarmichaelProof` and
    `Speculative.AutoResearch.CarmichaelComposite`.
  - Supporting entry-point (rank of apparition) API: `entryPt`, `entryPt_dvd`, `entryPt_min`,
    `entryPt_ne_one`, `dvd_fib_gcd`.
- `Novelty/PrimitiveDivisorEntryLaw.lean`
  - `sds_primitive_divisor_prime` — primitive prime divisor at prime index for **any** strong
    divisibility sequence with `u 1 = 1`. Generalizes the Fibonacci result.
  - `sds_primitive_divisor_apparition` — sharp form: the primitive prime's apparition set is
    exactly the multiples of `p` (`q ∣ u n ↔ p ∣ n`).
  - `fib_primitive_at_prime` — Fibonacci/Carmichael prime case, re-derived from the engine.
  - `mersenne_primitive_at_prime` — Bang's theorem at prime exponents (`2^p − 1`), a
    cross-domain corollary of the *same* abstract theorem.
- Infrastructure: registered the orphaned `Applications` and `Novelty` source trees as Lake
  libraries and set the package `srcDir` so the catalog sources actually build.

The one remaining `sorry` in the arc is `Shared.CarmichaelProof.fib_carmichael_composite`,
the composite case for `n > 10000`. The directions below lay out how to kill it.

---

## Direction 1 — The composite infinite tail via a Lean theory of the Fibonacci primitive part

Prove `fib_carmichael_composite` for all `n > 10000` (hence Carmichael in full) by formalizing
the cyclotomic factorization `F(n) = ∏_{d ∣ n} Φ_d`, where `Φ_d` is the homogeneous
"Fibonacci cyclotomic" value, together with the growth bound `Φ_n > n` for `n ∉ {1,2,6,12}` and
the lemma that at most one prime (the largest prime factor `P` of `n`, to the first power) can
be non-primitive in `Φ_n`. Then `primPart n ≥ Φ_n / P > 1`.

The key insight is that the computational `primPart` already defined in `CarmichaelProof.lean`
is, up to the single possible "intrinsic" prime, exactly `Φ_n`; so the missing analytic input
is purely the inequality `Φ_n > P_max(n)`, which reduces to a `φ(n)`-many-factor lower bound on
`|α^n − β^n|` against the elementary bound `P_max(n) ≤ n`.

Why now? The prime case is closed and the entry-point/rank engine (`rank_dvd_iff`,
`rank_min`) is in place, so the *only* missing ingredient is the cyclotomic growth estimate —
a self-contained analytic lemma rather than a whole theory. Falsifiable: if one exhibits a
composite `n > 10000` with `primPart n = 1`, the conjecture (and Carmichael) is false; the
`native_decide` check already certifies no such `n ≤ 10000` exists.

## Direction 2 — Generic Zsygmondy for Lucas sequences `u 1 = 1`

Conjecture: for every nondegenerate Lucas-type strong divisibility sequence `u` with `u 1 = 1`
and strict eventual growth, there is `N` such that for all `n > N`, `u(n)` has a primitive
prime divisor. This subsumes both Carmichael (Fibonacci) and Bang/Zsygmondy (`a^n − 1`) as the
*composite* counterparts of the prime-case corollaries proved this cycle.

The key insight is that `sds_primitive_divisor_apparition` already isolates the exact failure
mode for composites — a divisor whose rank is a proper divisor of `n` — so a generic proof
needs only a generic "primitive part > 1" estimate, abstracting Direction 1's growth bound
away from Fibonacci specifics.

Why now? We have a *single* abstract theorem covering both classical prime-index results, which
strongly suggests the composite results are also a single abstract theorem; the abstraction
barrier (`IsStrongDivSeq` + `u 1 = 1` + growth) is now explicit and minimal. Falsifiable by any
growing `u 1 = 1` SDS with infinitely many primitive-divisor-free terms.

## Direction 3 — Effective entry-point (rank) bounds and the Wall–Sun–Sun frontier

Conjecture: for a prime `q`, the Fibonacci entry point `entryPt q` satisfies
`entryPt q ∣ (q − (5/q))` (Legendre symbol), and `entryPt q = entryPt(q^2)` would force a
Wall–Sun–Sun prime. Formalize `entryPt q ∣ q − (5∣q)` and the rank-lifting law
`entryPt(q^k) = q^{k-1} · entryPt q` under the non-Wall–Sun–Sun hypothesis.

The key insight is that the entry point `entryPt` is already a first-class object in
`CarmichaelHelper`, so quadratic-reciprocity-driven divisibility of `entryPt q` is now a
statement we can *write down*, turning a folklore table into theorems.

Why now? `entryPt`, `entryPt_dvd`, and `entryPt_min` give the precise interface; the missing
piece is the period/order bridge to `ZMod q`, which Mathlib supports. Falsifiable: a computer
search verifying `entryPt q ∣ q − (5∣q)` for many primes is a direct sanity check, and a single
counterexample refutes it.

## Direction 4 — A lattice/order-theoretic packaging of `rank` as a poset morphism

Conjecture: for a strong divisibility sequence with all ranks existing, `rank u` is a
surjective-onto-its-image morphism of the divisibility lattice `(ℕ_{>0}, ∣, gcd, lcm)` that
*reflects* meets: `rank u (gcd a b)`-type identities hold, dualizing `Nat.fib_gcd`. Combine with
the catalog's `RankLatticeMorphism` to show the apparition map is a *Galois connection* between
"values" and "indices".

The key insight is that `rank_dvd_iff` already says `rank` is left adjoint to the value map in
the divisibility order — `m ∣ u n ↔ rank m ∣ n` is literally an adjunction unit — so the entire
apparition theory is a Galois connection waiting to be named.

Why now? Both halves exist in the catalog (`UnifiedRankOfApparition` and `RankLatticeMorphism`)
but were never connected; the adjunction framing would make every apparition lemma a formal
consequence of one categorical statement. Falsifiable: if `rank` failed the adjunction
triangle identities on some SDS, the framing collapses.

## Direction 5 — Carmichael exception classification as a finite, certified set

Conjecture: the complete set of `n` for which `F(n)` has *no* primitive prime divisor is exactly
`{1, 2, 6, 12}`, and this can be certified in Lean by combining (a) the prime case (done),
(b) the composite case for `n ≤ 10000` (done, `native_decide`), and (c) Direction 1's growth
bound for `n > 10000`, with a small finite exceptional analysis at `6` and `12`.

The key insight is that the exceptions are *forced* by the few `n` where `Φ_n ≤ P_max(n)`, a
finite condition once the growth bound is effective, so the classification is a corollary of
Direction 1 plus a `decide`-checkable finite list.

Why now? Two of the three ingredients are already formalized and `sorry`-free in this very arc;
only the growth bound stands between the catalog and a *fully certified* statement of
Carmichael's theorem with its exact exception set. Falsifiable: exhibiting a fifth exceptional
`n` refutes it outright.
