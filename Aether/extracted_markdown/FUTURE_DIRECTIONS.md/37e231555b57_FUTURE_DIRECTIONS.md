# Future Directions: From the ε₀ Barrier to a Hierarchy of Closure Ordinals

The file `ProofTheoreticOrdinalsEpsilon.lean` connects the abstract `OrdinalTheory`
framework (catalog: `ProofTheoreticOrdinals.lean`, `ProofTheoreticOrdinalsLattice.lean`)
to the concrete proof-theoretic landmarks `ε₀` and `Γ₀` through a single organising
notion — **exponential closure** (`ExpClosed`: the set of provably well-ordered ordinals
is closed under `α ↦ ω^α`). The central results are:

- `expClosed_ofOrdinal_iff_isFixed`: for a *limit* theory, exponential closure ⇔ the
  ε-number equation `ω^α = α`;
- `epsilon0_is_least_expClosed_pto`: `ε₀` is the least PTO of an exponentially-closed
  limit theory (the **ε₀ barrier**);
- a boundary triple (`expClosed_succ_epsilon0`, `not_isLimitTheory_succ_epsilon0`,
  `not_isFixed_succ_epsilon0`) showing the limit hypothesis is *necessary*;
- `pto_lt_pto_epsilon0_gamma0`: the ε₀ barrier sits strictly below the predicative
  barrier `Γ₀`.

The following conjectures extend this work. Each is testable and falsifiable in Lean
against Mathlib's Veblen/epsilon API.

## 1. The Veblen barrier: `Γ₀` is the least Veblen-closed limit PTO

Define `VeblenClosed T` to mean `T.provablyWO` is closed under `α ↦ veblen α 0` (the
analogue of `ExpClosed` one Veblen level up). Conjecture: for a *limit* theory
`ofOrdinal α`, `VeblenClosed` is equivalent to the fixed-point equation `veblen α 0 = α`,
and consequently `Γ₀` is the *least* PTO of a Veblen-closed limit theory — exactly mirroring
`epsilon0_is_least_expClosed_pto` one ordinal-collapsing level higher.

**The key insight is** that `expClosed_ofOrdinal_iff_isFixed` never used any special
feature of `ω^·` beyond *normality* (it only used `opow_le_of_isSuccLimit`,
`right_le_opow`, and strict monotonicity); the same proof skeleton therefore lifts
verbatim to any normal function `f`, with the least closed limit PTO being `nfp f 0` — and
`veblen · 0` is normal (`isNormal_veblen_zero`) with `nfp (veblen · 0) 0 = Γ₀`
(`gamma_zero_eq_nfp`). **Why now?** Mathlib already proves `Γ₀` is the relevant `nfp`
and provides `gamma_zero_le_of_veblen_le`, the exact analogue of
`epsilon_zero_le_of_omega0_opow_le` used in `epsilon0_least_expClosed`, so the lower-bound
half is immediately in reach.

## 2. A normal-function abstraction: `ClosedUnder f` and its least limit PTO

Replace the bespoke `ExpClosed` by a parametric `ClosedUnder f T := ∀ β ∈ T.provablyWO,
f β ∈ T.provablyWO` for an arbitrary `IsNormal f`. Conjecture: for a limit theory,
`ClosedUnder f (ofOrdinal α) ↔ f α = α`, and the least such limit PTO is `nfp f 0`. This
single theorem would subsume both the `ε₀` barrier (Conjecture 0, proven) and the `Γ₀`
barrier (Conjecture 1) as instances `f = (ω^·)` and `f = (veblen · 0)`.

**The key insight is** that the entire `ExpClosed` development factors through three
normality lemmas (`IsNormal.le_apply`/`right_le_opow`, the `IsSuccLimit` sup
characterization, and strict monotonicity), so abstracting `f` removes all arithmetic and
leaves a purely order-theoretic statement. **Why now?** `Order.IsNormal` is a first-class
Mathlib structure with `nfp_le_fp`, `nfp_fp`, `IsNormal.map_isSuccLimit`, and
`IsNormal.le_iff_forall_le`; the abstraction turns several future cycles' worth of
landmark-by-landmark theorems into corollaries of one lemma.

## 3. Exponential closure is a *complete sublattice* of `OrdinalTheory`

The catalog lattice file proved `OrdinalTheory` is totally ordered and `pto` is a lattice
homomorphism. Conjecture: the exponentially-closed theories form a complete sublattice —
closed under arbitrary `join`/`meet` and arbitrary suprema — and `pto` restricts to an
*order isomorphism* between exponentially-closed limit theories and the ε-numbers
(`range epsilon`).

**The key insight is** that `pto_join_eq_max`/`pto_meet_eq_min` (catalog) plus
`expClosed_ofOrdinal_iff_isFixed` reduce the closure question to: *the ε-numbers are
closed under `min`, `max`, and `sSup`* — which holds because `range (ω^·)`-fixed-points
form a closed set (the image of the normal `epsilon`/`deriv (ω^·)`). **Why now?** Mathlib's
`epsilon_eq_deriv` identifies ε-numbers with the range of a `deriv`, and `deriv` of a
normal function is itself normal (`isNormal_deriv`), so its range is provably closed under
suprema — exactly the missing ingredient.

## 4. Quantitative depth above the barrier: `depthDist (ofOrdinal ε₀) (ofOrdinal Γ₀) = Γ₀`

Using the catalog quasi-metric `depthDist`, conjecture an *exact* computation of the gap
between the two barriers: `depthDist (ofOrdinal ε₀) (ofOrdinal Γ₀) = Γ₀` (because
`Γ₀ - ε₀ = Γ₀`, as `ε₀ + Γ₀ = Γ₀` by left-absorption of the much larger `Γ₀`). More
generally, `depthDist (ofOrdinal (ε_ a)) (ofOrdinal (ε_ b)) = ε_ b` whenever `ε_ a + ε_ b
= ε_ b`, giving a clean closed form for the proof-theoretic "distance" between epsilon
landmarks.

**The key insight is** that ordinal *left*-absorption (`a + b = b` when `a` is small
relative to the additively-principal `b`) makes the symmetric subtraction in `depthDist`
collapse to the larger PTO, so the metric between widely-separated landmarks is just the
upper landmark itself. **Why now?** The catalog already proved
`depthDist_eq_sub_of_le` and `pto_ofOrdinal_*` evaluations, and Mathlib supplies
`Ordinal.add_absorp`/principal-ordinal lemmas (`Principal.add` for `ω^·` powers), so the
absorption fact `ε₀ + Γ₀ = Γ₀` is directly provable.

## 5. Reflection strength: closure under iterated exponentiation pins down `ε₀` exactly

Define the iteration tower `expTower n β := (ω^·)^[n] β`. Conjecture: a limit theory is
exponentially closed **iff** it is closed under every finite tower `expTower n`, and the
*least* theory closed under all towers starting from any `β < ε₀` has PTO exactly `ε₀`.
This recasts the ε₀ barrier as the closure ordinal of the finite-tower process, matching
the informal description "ε₀ is the limit of `ω, ω^ω, ω^ω^ω, …`".

**The key insight is** that `lt_epsilon_zero` already characterizes `o < ε₀` as
`∃ n, o < (ω^·)^[n] 0`, so the tower-closure ordinal is *definitionally* `nfp (ω^·) 0 =
ε₀`; the conjecture upgrades this pointwise fact to a statement about whole theories within
the `OrdinalTheory` lattice. **Why now?** `iterate_omega0_opow_lt_epsilon_zero` and
`lt_nfp_iff` give both bounding directions immediately, so the only new work is packaging
them as an `OrdinalTheory`-level closure theorem — a natural next cycle deliverable.
