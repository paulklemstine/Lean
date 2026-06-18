# Future Directions — Möbius Arithmetic

## Synthesis

We set out to test the bold conjecture that the *Möbius integers*
`Z̃ = ℤ × {+1,-1} / (n,+1)~(-n,-1)` form a genuinely new oriented number system
with exotic factorization and an Ore-failure powering off-critical-line zeros of
a "Möbius zeta function". The adversarial verdict is sharp and, we believe,
instructive: **the orientation is pure gauge**. The de-orientation map
`φ(n,s) = n·sgn(s)` is a bijection `Z̃ ≃ ℤ`, upgrades to a ring isomorphism
`Z̃ ≃+* ℤ` (`MobiusArithmetic.ringEquivInt`), and transports `ℤ`'s
`UniqueFactorizationMonoid`/`IsDomain` structure verbatim. Of the three headline
claims, exactly one survives — "class number 1" (because `Z̃` is a PID) — while
"non-Ore ring" is refuted at the root (`Z̃` is commutative, hence Ore) and the
"prime spectrum is a double cover" claim is demoted to the elementary statement
that each prime `p` has the two oriented lifts `p₊ ↦ p`, `p₋ ↦ -p`, which are
merely the associate pair `{p, -p}` (`MobiusArithmetic.prime_double_cover`).

The mathematically honest residue is genuinely pretty: `6 = 2₊·3₊ = 2₋·3₋` are
two distinct *oriented* factorizations agreeing up to a global orientation flip
(`MobiusArithmetic.factor_six_orientation`), and the intrinsic "twisted" product
`(a,s)·(b,t) = (ab, s·t)` provably equals integer multiplication
(`MobiusArithmetic.twistMulM_eq_mul`). The topology-flavored construction is a
faithful, computable re-coordinatization of `ℤ` by `(|value|·sign, orientation)`.

## Results summary (all `sorry`-free, axioms = propext/Classical.choice/Quot.sound)

- **T1 `equivInt` / `collapse_bijective`** — the double cover collapses: `Z̃ ≃ ℤ`.
- **T2 `ringEquivInt` (+ instances)** — `Z̃ ≃+* ℤ`; `Z̃` is a domain and a UFD.
- **T3 `prime_double_cover`** — each prime `p` lifts to `p₊ ↦ p` and `p₋ ↦ -p`,
  distinct, i.e. the associate pair.
- **T4 `factor_six_orientation`** — `6 = 2₊·3₊ = 2₋·3₋`, distinct up to orientation.
- **T5 `twistMulM_eq_mul` / `twistAddM_eq_add` / `twistMulM_comm`** — intrinsic
  twisted arithmetic *is* integer arithmetic; the ring is commutative (Ore).

## Falsifiable research directions

### 1. The non-collapse rigidity theorem
**Conjecture.** Every binary operation `⋆` on `ℤ × {±1}` that (i) descends to the
Möbius quotient and (ii) makes `φ` a homomorphism is forced to be the `φ`-pullback
of an operation on `ℤ`; equivalently, *no* exotic ring structure exists on the
Möbius carrier.
*The key insight is* that `collapse` is injective, so any quotient-respecting law
is determined by its values on collapsed classes — descent is a straitjacket, not
a freedom. **Why now?** Lemmas `collapse_twistMul`/`collapse_twistAdd` already
prove the pattern for two specific laws; abstracting them into a universal "any
descending hom-compatible law factors through `φ`" statement is a direct, provable
generalization that converts our case studies into a no-go theorem.

### 2. Multi-fold twist covers `ℤ × C_k` and when they collapse
**Conjecture.** The `k`-fold analogue `ℤ × C_k / (n,1)~(ζ·n, g)` collapses to `ℤ`
iff the cyclic action by `C_k` on values lands inside the unit group `{±1}`;
for `k > 2` (forcing a non-unit "rotation") the quotient is **not** a ring on the
naive carrier, and the obstruction is exactly the failure of the action to be by
units.
*The key insight is* that the `k=2` collapse worked only because `-1` is a *unit*
of `ℤ`, so the twist was an automorphism; larger twists demand non-units and break
multiplicativity. **Why now?** Our `signVal` machinery is parametric in the sign
group; swapping `{±1}` for `C_k` is a small refactor that immediately exposes the
unit-group obstruction as a testable dichotomy.

### 3. The Möbius zeta is the ordinary zeta, doubled
**Conjecture.** The "Möbius zeta" `ζ̃(s) = Σ_{x≠0} |φ(x)|^{-s}` over nonzero
Möbius integers equals `2·ζ(s)` for `Re(s) > 1` (every absolute value `m>0` is hit
by exactly the two oriented classes `m₊, m₋`), hence has its zeros **on** the
critical line, refuting the off-line conjecture; at `0` the branch point removes
the only would-be double count.
*The key insight is* that `φ` is a bijection and `|φ(m₊)| = |φ(m₋)| = |m|`, so the
oriented norm multiset is just two copies of `ℕ_{>0}` — no new analytic content can
appear. **Why now?** `collapse_bijective` plus `fiber_orientation`/`fiber_distinct`
already pin down the fiber structure (2-to-1 off `0`, branch at `0`); formalizing
the norm-counting bijection `{x : φ(x)=m} ↔ {±}` is the last step before a clean
`ζ̃ = 2ζ` identity (even purely formally as Dirichlet series in Mathlib).

### 4. Orientation as the unique nontrivial `Z/2`-grading of `ℤ`
**Conjecture.** The Möbius construction is the (essentially unique) way to realize
the sign automorphism `n ↦ -n` of `ℤ` as a `Z/2`-torsor of "orientations"; any
`Z/2`-equivariant relabeling of `ℤ` that is free away from a fixed point is
isomorphic to `(Z̃, fiber_orientation)` with branch locus the `2`-torsion `{0}`.
*The key insight is* that `fiber_orientation : plus n = minus (-n)` exhibits the
identification as the graph of the order-2 automorphism, whose unique fixed point
is `0`. **Why now?** We have the fixed-point/branch behavior isolated as theorems;
recasting them via `Equiv.Perm` of order 2 and a torsor statement is a natural and
checkable categorification that connects to existing Mathlib group-action API.

### 5. Gauge-collapse as a reusable certified pattern (catalog cross-link)
**Conjecture.** The "novelty = de-orientation gauge" phenomenon recurs across the
catalog's *Novelty* domain: many proposed exotic carriers (e.g. quotients adding a
formal symmetry that is already an automorphism of the base) admit a `collapse`
bijection to a classical object, and this can be *detected* by the
`Metric.infDist`-style novelty score of `Catalog/Novelty/CertifiedNovelty.lean`
returning `0` after collapse.
*The key insight is* that genuine novelty must survive every base-automorphism
quotient; a construction collapses precisely when its "new" relation is the graph
of an existing symmetry. **Why now?** With `CertifiedNovelty`'s quantitative
`IsNovel`/`noveltyScore` already in the catalog, pairing it with a `collapse`-style
certificate gives a falsifiable, automatable test ("is this carrier secretly `ℤ`?")
that we can run against future Novelty-domain proposals before investing in them.
