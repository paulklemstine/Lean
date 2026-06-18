# Future Directions: A Hierarchy of Closure Ordinals above the ε₀/Γ₀ Barriers

## Synthesis

This cycle delivered `Catalog/Pythagorean/ProofTheoreticOrdinalsEpsilon.lean`, which
fuses the *abstract* `OrdinalTheory` lattice (catalog files
`ProofTheoreticOrdinals.lean` and `ProofTheoreticOrdinalsLattice.lean`) with the
*concrete* proof-theoretic landmarks `ε₀` and `Γ₀`, through a single organising notion:
**closure of a theory under an ordinal function** (`ClosedUnder f T`).

The central new result is a **normal-function master theorem**,
`nfp_isLeast_limit_closedUnder`: for any normal `f` whose least fixed point above `0` is
a limit ordinal, `nfp f 0` is the *least* ordinal whose limit theory `ofOrdinal α` is
closed under `f`. Both classical barriers fall out as one-line instantiations:

* `f = (ω ^ ·)` ⟹ `epsilon0_isLeast_expClosed`  — the **ε₀ barrier**;
* `f = (veblen · 0)` ⟹ `gamma0_isLeast_veblenClosed` — the **Γ₀ barrier**.

We also proved the fixed-point criterion `closedUnder_ofOrdinal_iff_isFixed` (closure of a
*limit* theory ⇔ the fixed-point equation `f α = α`), its two specialisations
`expClosed_ofOrdinal_iff_isFixed` and `veblenClosed_ofOrdinal_iff_isFixed`, a boundary
triple at `ε₀ + 1` showing the limit hypothesis is *necessary*
(`expClosed_succ_epsilon0`, `not_isLimitTheory_succ_epsilon0`,
`not_isFixed_succ_epsilon0`), and the strict separation
`pto_lt_pto_epsilon0_gamma0`.

## Results Summary

| Theorem | Statement | `sorry`? |
|---|---|---|
| `closedUnder_ofOrdinal_iff_isFixed` | limit-theory closure ⇔ `f α = α` (normal `f`) | none |
| `nfp_isLeast_limit_closedUnder` | `nfp f 0` is the least limit closure ordinal | none |
| `epsilon0_isLeast_expClosed` | `ε₀` is the least exp-closed limit PTO | none |
| `gamma0_isLeast_veblenClosed` | `Γ₀` is the least Veblen-closed limit PTO | none |
| `expClosed_succ_epsilon0` + triple | limit hypothesis is necessary | none |
| `pto_lt_pto_epsilon0_gamma0` | the ε₀ barrier is strictly below Γ₀ | none |

The previously-conjectured "Veblen barrier" and "normal-function abstraction" (Conjectures
1 and 2 of the seeding document) are therefore now **proven**, the second in maximally
general form. The directions below chart what remains.

## 1. The φ-hierarchy of barriers: `veblen α 0`-towers and a closure spectrum

Iterate the master theorem *up the Veblen hierarchy*. For each ordinal `a`, the function
`veblen a` is normal, so it has a least limit closure ordinal `nfp (veblen a) 0`.
Conjecture: the assignment `a ↦ (least limit PTO closed under veblen a)` is itself a
strictly increasing, continuous (normal) map of `a`, and its own diagonal fixed point is
exactly `Γ₀` — recovering the Feferman–Schütte ordinal as the *closure ordinal of the
closure-ordinal operator*.

**The key insight is** that `nfp_isLeast_limit_closedUnder` is parametric in the normal
function `f`, so feeding it the family `{veblen a}ₐ` turns a single theorem into an
ordinal-indexed *spectrum* of barriers, and the diagonal `a ↦ veblen a 0` is the unique
normal function whose own master-theorem output coincides with the parameter — precisely
the Γ₀ self-reference. **Why now?** Mathlib already supplies `isNormal_veblen`,
`veblen_veblen_of_lt`, and `gamma_zero_eq_nfp`; the diagonalisation is a clean fixed-point
argument over the proven master theorem, requiring no new ordinal arithmetic.

## 2. Exponential closure is a complete sublattice of `OrdinalTheory`

Building on the catalog's `pto_join_eq_max` / `pto_meet_eq_min`, conjecture that the
exponentially-closed limit theories form a *complete sublattice*: closed under arbitrary
`join`, `meet`, and suprema, with `pto` restricting to an order isomorphism onto the
ε-numbers `range epsilon`.

**The key insight is** that `expClosed_ofOrdinal_iff_isFixed` reduces sublattice closure
to the statement *the set of `ω^·`-fixed points is closed under `min`, `max`, and `sSup`*,
which holds because that set is the range of the normal function `deriv (ω^·) = epsilon`,
and ranges of normal functions are closed under suprema. **Why now?** `epsilon_eq_deriv`
identifies the ε-numbers with `range (deriv (ω^·))`, and `isNormal_deriv` gives the
normality that forces supremum-closure — the one missing ingredient is now in scope.

## 3. Quantitative depth between barriers via left-absorption

Using the catalog quasi-metric `depthDist`, conjecture the exact value
`depthDist (ofOrdinal ε₀) (ofOrdinal Γ₀) = Γ₀`, and more generally
`depthDist (ofOrdinal (ε_ a)) (ofOrdinal (ε_ b)) = ε_ b` whenever `ε_ a + ε_ b = ε_ b`.

**The key insight is** that ordinal *left*-absorption (`x + y = y` when `x` is small
relative to the additively-principal `y`) collapses the symmetric subtraction in
`depthDist` to the larger PTO, so the metric between widely separated landmarks is just the
upper landmark. **Why now?** The catalog already proves `depthDist_eq_sub_of_le` and the
`pto_ofOrdinal_*` evaluations, while Mathlib's principal-ordinal API (`Principal.add` for
`ω^·`-powers, hence for the additively principal `Γ₀`) makes `ε₀ + Γ₀ = Γ₀` directly
provable, and `pto_lt_pto_epsilon0_gamma0` from this cycle supplies the ordering.

## 4. The finite-tower characterisation: `ε₀` as a reflection closure ordinal

Define the iteration tower `expTower n β := (ω ^ ·)^[n] β`. Conjecture: a limit theory is
exponentially closed **iff** it is closed under every finite tower `expTower n`, and the
least limit theory closed under all towers from any seed `β < ε₀` has PTO exactly `ε₀`.
This recasts the proven `epsilon0_isLeast_expClosed` as the closure ordinal of the
finite-tower process, matching the informal slogan "ε₀ is the limit of `ω, ωᵚ, ωᵚᵚ, …`".

**The key insight is** that `lt_epsilon_zero` already characterises `o < ε₀` as
`∃ n, o < (ω^·)^[n] 0`, so the tower-closure ordinal is *definitionally* `nfp (ω^·) 0 =
ε₀`; the conjecture upgrades this pointwise fact to a statement about whole theories in the
`OrdinalTheory` lattice. **Why now?** `iterate_omega0_opow_lt_epsilon_zero` and
`lt_nfp_iff` give both bounding directions immediately, so the only work is packaging them
through `ClosedUnder`, reusing this cycle's `closedUnder_ofOrdinal_iff_isFixed`.

## 5. A Galois connection: closure operators and the derivative

Conjecture that `T ↦ (least closed-under-`f` theory ≥ T)` is the closure operator of a
genuine Galois connection on `OrdinalTheory`, whose closed elements are exactly the
limit theories with `pto ∈ range (deriv f)`, and that this connection is *natural* in the
normal function `f` (a morphism of normal functions induces a morphism of closure
operators).

**The key insight is** that the master theorem already exhibits `nfp f 0` as a *least*
closed object; promoting "least closed object above `0`" to "least closed object above an
arbitrary `T`" is exactly `deriv f` evaluated at `pto T`, so the whole closure theory is
governed by `deriv`, and `deriv`'s functoriality in `f` gives the naturality. **Why now?**
`deriv` is a first-class Mathlib citizen with `deriv_fp`, `nfp_le_fp`, and `isNormal_deriv`;
the proven `nfp_isLeast_limit_closedUnder` is the `T = ofOrdinal 0` base case of the
desired Galois adjunction, so the general statement is the natural next abstraction.
