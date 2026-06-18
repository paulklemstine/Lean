# Future Directions: The Multiplicative Independence Barrier behind Cobham's Theorem

## Synthesis

This cycle isolated the *arithmetic core* of Cobham's theorem (1972) — the hypothesis of
**multiplicative independence** of the two bases — and formalized it as a self-contained,
sorry-free theory in `Catalog/Bridges/CobhamMultiplicativeIndependence.lean`. The central
object is the relation `MultDep j k := ∃ a b > 0, j^a = k^b` ("bases `j` and `k` share a common
power", equivalently `log j / log k ∈ ℚ`). We proved that `MultDep` is an equivalence relation
on bases (reflexive, symmetric, and — the only substantive part — transitive by exponent
bookkeeping `j^(ac) = k^(bc) = l^(db)`), that powers of a fixed base are always dependent, and,
most importantly, the **barrier theorem**: a base `j ≥ 2` coprime to `k` is *never*
multiplicatively dependent on `k`. The concrete witness `¬ MultDep 2 3` shows this barrier is
non-empty, which is exactly what makes Cobham's theorem non-vacuous.

The structural insight is that the geometric Cobham-invariance machinery already in the catalog
(`Catalog/Bridges/OracleCobhamInvariance.lean`: prefix ultrametrics, `AdmissibleSimulation`,
`traceBall` rigidity) and the arithmetic obstruction proved here are two faces of one coin: a
base change is an *admissible simulation* with bounded depth loss precisely when the bases are
multiplicatively dependent. The geometric side measures *how cheaply* one model simulates
another; the arithmetic side measures *whether a finite-distortion simulation can exist at all*.
What failed (productively) was the analytic framing `log j / log k ∈ ℚ`: it pulls in real-
analytic machinery for what is, for integer bases `≥ 2`, an entirely elementary multiplicative
statement. Recognizing this collapse to pure exponent arithmetic is what let every result land
with `decide`-free, `native_decide`-free proofs.

The single open conjecture seeded for the next cycle (`multDep_iff_common_root`) upgrades the
barrier into a full classification: multiplicatively dependent bases are exactly the bases that
are common powers of a single primitive integer. Proving it would turn the qualitative barrier
into a quantitative normal form and is the natural bridge toward a Lean statement of Cobham's
theorem itself.

## Results Summary

- `multDep_refl`: proved — every base is multiplicatively dependent on itself (witness `a=b=1`).
- `multDep_symm`: proved — `MultDep` is symmetric (swap the exponent witnesses).
- `multDep_trans`: proved — `MultDep` is transitive; the only nontrivial axiom of the
  equivalence relation, via `j^(ac) = k^(bc) = l^(db)`.
- `multDep_pow_self`: proved — powers `j^m`, `j^n` of a fixed base are always dependent.
- `coprime_not_multDep`: proved — **the barrier**: `j ≥ 2` coprime to `k` is never
  multiplicatively dependent on `k` (sharper one-sided form, `2 ≤ k` unnecessary).
- `not_multDep_two_three`: proved — concrete witness `¬ MultDep 2 3`; the obstruction that makes
  Cobham's theorem non-vacuous.
- `multDep_iff_common_root`: conjecture — multiplicative dependence of bases `≥ 2` is equivalent
  to being common powers of a single base `g ≥ 2`.

## Research Directions

### Direction 1: Common-root normal form for dependent bases
**Hypothesis**: For `j, k ≥ 2`, `MultDep j k ↔ ∃ g p q, 2 ≤ g ∧ 0 < p ∧ 0 < q ∧ j = g^p ∧ k = g^q`
(the conjecture `multDep_iff_common_root`).
**Test**: Prove the forward direction by taking `g` to be the largest integer of which both `j`
and `k` are powers (equivalently, derived from `Nat.factorization` with the gcd of exponent
vectors); the reverse direction is `multDep_pow_self` plus transitivity.
**Why now**: This cycle already proved transitivity and `multDep_pow_self`, which supply the
entire reverse direction for free; only the forward (factorization) direction remains.
**If true**: `MultDep` acquires a computable normal form, enabling a *decidable* test for
multiplicative dependence of two given numerals and a clean restatement of Cobham's hypothesis.
**If false**: There would exist dependent bases with no common integer root, exposing a subtle
gap between "shared power" and "shared base" — surprising and worth a counterexample hunt.

### Direction 2: `MultDep` as a `Setoid` and the quotient of bases
**Hypothesis**: `MultDep` restricted to `{n : ℕ // 2 ≤ n}` is an equivalence relation whose
quotient is in bijection with the set of non-perfect-power bases (the "primitive" bases).
**Test**: Bundle `multDep_refl/symm/trans` into a `Setoid`, then exhibit the quotient map sending
each base to its primitive root from Direction 1.
**Why now**: The three equivalence axioms are already proved this cycle; only the bundling and
the quotient description (which reuses Direction 1's normal form) remain.
**If true**: Gives the precise index set over which Cobham's "j-automatic" classes are genuinely
distinct, i.e. a clean parameter space for automatic-sequence theory.
**If false**: The quotient is coarser/finer than expected, revealing hidden collisions among
automatic-sequence classes.

### Direction 3: Bridging the barrier to `AdmissibleSimulation`
**Hypothesis**: If a length-respecting base-`j`-to-base-`k` transducer is an
`AdmissibleSimulation` (in the sense of `OracleCobhamInvariance.lean`) with finite `depth_loss`,
then `MultDep j k`. Contrapositively, `coprime_not_multDep` forbids any finite-distortion
simulation between coprime bases.
**Test**: Formalize base-`b` digit expansion as an `OracleTrace`, show a finite-`depth_loss`
prefix-Lipschitz base converter forces a common power, and combine with `coprime_not_multDep`.
**Why now**: Both halves now exist in the catalog — the geometric simulation calculus and the
arithmetic barrier — so this is a connect-the-dots theorem rather than new theory.
**If true**: Unifies the geometric and arithmetic catalog strands into a single machine-checked
"no admissible simulation across independent bases" statement, the crux of Cobham.
**If false**: Some finite-distortion simulation sneaks across independent bases, which would be a
genuinely new (and alarming) collapse of base-dependent complexity.

### Direction 4: Quantitative barrier via prime valuations
**Hypothesis**: For coprime `j, k ≥ 2` there is an explicit prime `p` and a strictly positive
lower bound `|a·v_p(j) − b·v_p(k)| ≥ 1` for all `a, b > 0`, certifying `j^a ≠ k^b` *with a gap*.
**Test**: Refine the `Nat.factorization` argument inside `coprime_not_multDep` to extract the
witnessing prime and its valuation gap, rather than only deriving a contradiction.
**Why now**: The current barrier proof already produces a witnessing prime `p ∣ j`; promoting
the contradiction to a quantitative valuation gap is a localized strengthening.
**If true**: Yields effective separation bounds — the seed of a Baker-style lower bound on
`|j^a − k^b|` in the formal library.
**If false**: The valuation gap is not uniform, pointing toward genuinely transcendental
(rather than `p`-adic) obstructions and motivating analytic methods.

### Direction 5: From the barrier to a Lean statement of Cobham's theorem
**Hypothesis**: A sequence simultaneously `j`-automatic and `k`-automatic with `¬ MultDep j k`
is eventually periodic (Cobham 1972).
**Test**: Define `b`-automatic sequences via deterministic finite automata reading base-`b`
digits, then attempt the eventual-periodicity conclusion under the `¬ MultDep` hypothesis,
using the barrier as the non-degeneracy input.
**Why now**: With multiplicative independence now a first-class, sorry-free predicate, the
hypothesis of Cobham's theorem can finally be *stated* faithfully in Lean — the prerequisite for
any proof attempt.
**If true**: A landmark formalization; even the *statement* with a verified non-vacuity witness
(`not_multDep_two_three`) is new infrastructure for the automatic-sequences corner of the library.
**If false**: An automaton-theoretic counterexample would overturn a 50-year-old theorem — the
far more likely outcome is that the proof requires Semenov-style or first-order-logic machinery
not yet in the catalog, which itself maps out the next several cycles.
