# Future Directions — The Rank-of-Apparition Engine

## Synthesis

This cycle unified two parallel catalog threads — the Fibonacci-only rank machinery of
`Catalog/Applications/RankOfApparition.lean` and the abstract `IsStrongDivSeq` framework of
`Catalog/Applications/StrongDivisibilitySequences.lean` — into a single generic engine in
`Catalog/Applications/UnifiedRankOfApparition.lean`. From the bare meet law
`u (gcd m n) = gcd (u m) (u n)` we derived, for an *arbitrary* strong divisibility sequence,
the spine `rank_dvd_iff : m ∣ u n ↔ rank u m ∣ n`, the order-morphism law `rank_dvd_of_dvd`,
the rigidity `rank_self : rank u (u k) = k`, and the value biconditional
`value_dvd_iff : u a ∣ u b ↔ a ∣ b`. Two classical theorems then fell out as instances of one
truth: the Fibonacci law `fib_dvd_fib_iff` (`F a ∣ F b ↔ a ∣ b`, `a ≥ 3`) and — newly derived —
the Mersenne law `mersenne_dvd_iff` (`aᵐ − 1 ∣ aⁿ − 1 ↔ m ∣ n`, `a ≥ 2`, `m ≥ 1`).

## Results Summary

- `rank_dvd_iff` — generic spine, no primitivity hypothesis (generalizes `fibRank_dvd_iff`).
- `rank_dvd_of_dvd` — `rank` is a morphism of divisibility posets.
- `rank_self` / `value_dvd_iff` — rigidity and the index biconditional from positivity + growth.
- `fib_dvd_fib_iff`, `mersenne_dvd_iff` — two classical divisibility laws as one engine's instances.
- All four headline theorems verified with axioms `[propext, Classical.choice, Quot.sound]`, `sorry = 0`.

## Research Directions

### 1. A generic primitive-divisor existence theorem (Zsygmondy through one engine)
Conjecture: for any strong divisibility sequence `u` that is *eventually super-linearly growing*
(`∀ d ≥ 1, ∃ N, ∀ n ≥ N, u n > u d · (number of proper divisors of n)`), every `u n` with `n`
large has a primitive divisor, i.e. `IsPrimitive p n` for some prime `p`. Falsifiable: a single
SDS with unbounded growth but a primitive-divisor gap at some large `n` would refute it.
**The key insight is** that `value_dvd_iff` already pins every non-primitive contribution to
`u d` for proper divisors `d ∣ n`, so a counting bound `u n > ∏_{d∣n, d<n} u d` mechanically
forces a leftover primitive factor — primitivity becomes a growth inequality, not a new idea.
**Why now?** The engine supplies the exact divisibility bookkeeping (the spine + rigidity) that
Zsygmondy-style arguments hand-wave; only the arithmetic growth estimate remains to be formalized.

### 2. Closing the Carmichael composite tail via the engine
Conjecture: the `sorry` in `Catalog/Shared/CarmichaelProof.lean` (composite `n > 10000`) is
discharged by instantiating Direction 1 to `Nat.fib`, since `F n` grows like `φⁿ` while the
product of `F d` over proper divisors `d ∣ n` grows like `φ^{n/2 + o(n)}`. Falsifiable: exhibit a
composite `n` where `primPart n = 1` despite `n > 10000` (none should exist).
**The key insight is** that the catalog's `primPart` is literally the leftover after stripping all
`F d` for proper divisors `d`, so a clean lower bound `primPart n ≥ φ^{n/2}/poly > 1` is exactly
the growth inequality of Direction 1 specialized to Fibonacci.
**Why now?** The computational `native_decide` base case is already proved up to 10000; only the
asymptotic tail is open, and the unified rigidity result makes the divisor bookkeeping rigorous.

### 3. Lucas sequences `Uₙ(P,Q)` as a third instance
Conjecture: every nondegenerate Lucas sequence of the first kind `U` is a strong divisibility
sequence, so `value_dvd_iff` gives `U_a ∣ U_b ↔ a ∣ b` for `a` past the degenerate prefix.
Falsifiable: a nondegenerate `(P,Q)` whose `U` fails `U(gcd m n) = gcd(U m, U n)` would refute it.
**The key insight is** that Fibonacci (`P=1,Q=-1`) and Mersenne (`Uₙ = (aⁿ−1)/(a−1)` for `P=a+1,
Q=a`) are the two endpoints of the Lucas family, and both already factor through the engine, so
the whole one-parameter family should plug into the *same* `IsStrongDivSeq` hypothesis.
**Why now?** Mathlib has gained `LucasLehmer` and companion-matrix infrastructure; the SDS law for
`U` is a determinant identity over `ℤ` that is finally within reach without new foundations.

### 4. `rank` as a functor on the divisibility category
Conjecture: for a fixed totally-apparitioned SDS `u`, the map `rank u : (ℕ_{>0}, ∣) → (ℕ_{>0}, ∣)`
is a (monotone, meet-semilattice) functor, and on the Fibonacci instance it is *idempotent on its
image* (`rank (F (rank m)) = rank m`). Falsifiable: a divisibility pair `b ∣ a` with
`rank u b ∤ rank u a` would break functoriality.
**The key insight is** that `rank_dvd_of_dvd` is exactly the morphism-action of a functor, so the
remaining content is naturality of the rank under the strong-divisibility comparison — a
categorical repackaging that makes "rank of apparition" a universal construction.
**Why now?** Mathlib's order-category and `OrderHom` API are mature enough to state the functor
laws directly, turning a number-theoretic gadget into a clean categorical object.

### 5. Joint apparition lattice from the generic spine
Conjecture: for primitive divisors `p` of `u a` and `q` of `u b`, the join law
`(p ∣ u n ∧ q ∣ u n) ↔ lcm a b ∣ n` extends to arbitrary finite families and computes the
*density* `1 / lcm(a₁,…,a_k)` of indices with simultaneous apparition — uniformly across Fibonacci,
Mersenne, and Lucas. Falsifiable: a family whose simultaneous-apparition density deviates from
`1/lcm` would refute it.
**The key insight is** that the spine reduces simultaneous apparition to a single `lcm`-divisibility
condition on indices, so density becomes the Cesàro density of an arithmetic progression — purely
order-theoretic, independent of which SDS is chosen.
**Why now?** `StrongDivisibilitySequences.lean` already proves the two-modulus and finset versions
for counting; merging them with this cycle's `rank` engine yields the density statement with no new
analytic machinery.
