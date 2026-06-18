# Future Directions — Monodromy-Driven Quantum Advantage in Hypergeometric Period Sampling

## Synthesis of this cycle

This cycle isolated the *group-theoretic engine* underneath the conjecture that
non-virtually-solvable monodromy of rigid hypergeometric local systems is a
source of provable quantum advantage. Rather than chase the full
complexity-theoretic separation (currently out of reach of any formal system),
we extracted the parts that are genuinely *true and provable now*, and proved
them with zero `sorry` (every result below depends only on the standard kernel
axioms `propext`, `Classical.choice`, `Quot.sound`):

* **The non-solvable core** (`FreeMonodromy.lean`). The fundamental group of the
  thrice-punctured sphere is free on two of its loops; we proved
  `FreeGroup (Fin 2)` is **not solvable** (`freeGroup_two_not_solvable`) by
  exhibiting a *surjection* `toS5 : Loops →* S₅` (a 5-cycle `finRotate 5` and the
  adjacent transposition `swap 0 (finRotate 5 0)` generate `S₅` via
  `Equiv.Perm.closure_cycle_adjacent_swap`, transported across
  `FreeGroup.range_lift_eq_closure`) and pulling back
  `Equiv.Perm.fin_5_not_solvable` along `solvable_of_surjective`. From this,
  `faithful_monodromy_not_solvable` and `faithful_monodromy_range_not_solvable`
  show that *any faithful* monodromy representation already has a non-solvable
  image — the geometric "rigidity = faithfulness" hypothesis is exactly the input
  that makes the monodromy non-virtually-solvable.

* **The classical/quantum dichotomy** (`phase_blind_to_commutator`,
  `classical_phase_blindness`). Every *abelian phase character* — the only datum
  a classical period-phase sampler can read — annihilates the commutator
  subgroup, which is nonetheless non-trivial (witnessed concretely by
  `toS5 ⁅of 0, of 1⁆ ≠ 1`). So the non-abelian (non-solvable) content of the
  monodromy is provably invisible to phase sampling. This is the formal kernel of
  the conjectured gap: abelian data is classically simulable, the non-abelian
  remainder is not.

* **A concrete realisation** (`HypergeometricTriangle.lean`). The puncture
  relation `γ₀γ₁γ∞ = 1` is realised by explicit *integer* `SL₂` matrices — the
  Sanov pair `M₀ = [[1,2],[0,1]]`, `M₁ = [[1,0],[2,1]]` and the inverse
  `M∞ = [[1,-2],[-2,5]]` of their product (`monodromy_triangle_relation`); the
  monodromy is non-abelian (`monodromy_noncommutative`) and unimodular
  (`monodromy_unimodular`). The eigenvalue *period phase* lives in the
  phase-estimation register `ℝ/2πℤ = Real.Angle`, is additive along composed
  loops (`monodromy_phase_additive`), and — for the elliptic quarter-turn
  `R = [[0,-1],[1,0]]` — has order exactly `4` matching the matrix order
  (`rotation_order_four`, `phase_order_matches_monodromy`).

## Results summary

| Theorem | Statement | Status |
|---|---|---|
| `freeGroup_two_not_solvable` | the free monodromy group on two loops is not solvable | proved |
| `toS5_surjective` | the canonical map `Loops →* S₅` is surjective | proved |
| `faithful_monodromy_not_solvable` | faithful monodromy ⟹ non-solvable structure group | proved |
| `faithful_monodromy_range_not_solvable` | the faithful monodromy image is non-solvable | proved |
| `phase_blind_to_commutator` | every abelian character kills commutators | proved |
| `classical_phase_blindness` | a non-trivial loop killed by every abelian phase character | proved |
| `monodromy_triangle_relation` | `M₀ M₁ M∞ = 1` over `ℤ` | proved |
| `monodromy_unimodular` / `monodromy_noncommutative` | `SL₂`, non-abelian | proved |
| `rotation_order_four` | the elliptic generator has matrix-order `4` | proved |
| `monodromy_phase_additive` | period phases add along loops in `ℝ/2πℤ` | proved |
| `phase_order_matches_monodromy` | phase-order = matrix-order = `4` | proved |

## Bold, falsifiable research directions

### 1. Sanov faithfulness: the missing geometric input, formalised by ping-pong
**Conjecture.** The lift `FreeGroup (Fin 2) →* SL₂(ℤ)` sending the generators to
`[[1,2],[0,1]]` and `[[1,0],[2,1]]` (the Sanov pair already realised here as
`M₀`, `M₁`) is **injective**; consequently, by
`faithful_monodromy_range_not_solvable`, the Legendre/hypergeometric monodromy
group is non-solvable on the nose, not merely conditionally.
**The key insight is** that Mathlib already ships
`FreeGroup.injective_lift_of_ping_pong`, so the only thing to supply is the two
cones `X = {|x| > |y|}`, `Y = {|x| < |y|}` in `ℝ²` and the inequalities showing
`a^{±1}` map the complement of one into the other — a finite analytic checklist,
not new theory.
**Why now?** This cycle proved every *conditional* consequence of faithfulness
(`faithful_monodromy_not_solvable`, `..._range_not_solvable`); discharging the
single ping-pong hypothesis would upgrade all of them to unconditional theorems
about the explicit integer matrices of `HypergeometricTriangle.lean`, and is the
highest-leverage next step.
**Falsifiable:** if any reduced word maps to the identity matrix, the conjecture
(and Sanov's theorem) is refuted.

### 2. Exponential word growth as a complexity lower-bound certificate
**Conjecture.** The faithful monodromy group has **exponential growth**: the
number of distinct matrices reachable by reduced words of length `≤ n` is
`≥ 3·2^{n-1}`, while its eigenvalue-phase shadow grows only polynomially (`~ n`)
because it factors through the abelianization.
**The key insight is** that growth rate is a *quasi-isometry invariant* that
separates the full monodromy (free, exponential) from its phase shadow (cyclic,
polynomial) — turning the qualitative "classical blindness"
(`classical_phase_blindness`) of this cycle into a quantitative `exp` vs `poly`
gap that mirrors the conjectured runtime separation.
**Why now?** `freeGroup_two_not_solvable` and `classical_phase_blindness` give
both endpoints; a growth-counting lemma over `FreeGroup.reduce`d words is
elementary and makes the separation numerical and testable.
**Falsifiable:** any sub-exponential bound on reduced-word images refutes it.

### 3. Phase-character cohomology classifies the simulable layer exactly
**Conjecture.** The group of phase characters `Hom(π₁, Real.Angle)` is naturally
isomorphic to `Hom(H₁(ℙ¹∖S; ℤ), Real.Angle)`, i.e. the classically simulable
layer is *exactly* `H¹` of the punctured curve, with the commutator subgroup
spanning the entire non-simulable remainder.
**The key insight is** that `Abelianization.lift` makes "phase character" and
"first cohomology class" the same object, so the classical/quantum cut coincides
with the `H¹` vs higher-monodromy filtration — a precise structural home for the
informal "abelian = easy" intuition that `phase_blind_to_commutator` already half
formalises.
**Why now?** `phase_blind_to_commutator` already proves one containment (every
character kills commutators); the reverse — every abelianization character lifts
to a phase character — is a direct application of the universal property of
`Abelianization` and closes the classification.
**Falsifiable:** a phase character not factoring through `H₁`, or a commutator
detected by some character, refutes it.

### 4. Rigidity transfer: solvable monodromy ⟹ classically samplable phases
**Conjecture.** For the *complementary* regime — one-parameter families whose
monodromy is virtually solvable (resonant/degenerate hypergeometric parameters)
— the period-phase sampling problem reduces to a polynomial-time classical
computation, because solvable groups are built from abelian layers each of which
is phase-detectable.
**The key insight is** that solvability is the exact negation of the obstruction
proved here: where `freeGroup_two_not_solvable` blocks classical simulation, a
solvable derived series provides a *finite tower of phase characters* (one per
quotient `derivedSeries n / derivedSeries (n+1)`) that reconstructs the whole
representation.
**Why now?** Mathlib's `derivedSeries`/`IsSolvable` API lets one induct on the
solvable length; pairing it with `monodromy_phase_additive` yields a clean
"solvable ⟹ samplable" companion theorem, completing the dichotomy whose hard
half this cycle established.
**Falsifiable:** a solvable monodromy family with provably hard phase sampling
refutes it.

### 5. Arithmetic monodromy and a Galois-action obstruction to dequantization
**Conjecture.** When the hypergeometric parameters are rational, the monodromy
matrices lie in `SL₂` over a number field and the absolute Galois group acts on
the phase data; the orbit of a period phase under this action is polynomially
bounded iff the monodromy is solvable, giving an *arithmetic* certificate of
quantum hardness independent of the geometric one.
**The key insight is** that the integer realisation in
`HypergeometricTriangle.lean` already lives over `ℤ ⊂ ℚ̄`, so the Galois action is
concrete, and non-solvable monodromy forces large Galois orbits — converting a
geometric obstruction into an arithmetic one and connecting to the catalog's
`Algebra/ZetaZeroFree` and L-function threads.
**Why now?** The explicit unimodular integer matrices `M₀`, `M₁`, `M∞`, `R` make
the number-theoretic side fully computable today; even the rank-1 (phase) case is
a tractable first theorem about cyclotomic orbits of `Real.Angle`/`Complex.arg`
values, building directly on `phase_order_matches_monodromy`.
**Falsifiable:** a non-solvable rational family with uniformly small Galois phase
orbits refutes it.
