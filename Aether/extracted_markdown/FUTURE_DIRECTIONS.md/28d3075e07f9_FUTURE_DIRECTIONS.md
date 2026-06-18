# Future Directions: The Multiplicative Independence Barrier behind Cobham's Theorem

## Synthesis

This cycle isolated the *arithmetic core* of Cobham's theorem (1972) — the hypothesis of
**multiplicative independence** of two numeration bases — and formalized it as a self-contained,
sorry-free theory in `Catalog/Bridges/CobhamMultiplicativeIndependence.lean`. The central object
is the relation `MultDep j k := ∃ a b > 0, j^a = k^b` ("bases `j` and `k` share a common power",
the elementary integer-base form of `log j / log k ∈ ℚ`).

We proved that `MultDep` is an **equivalence relation** on bases — reflexive and symmetric
trivially, and transitive by the exponent bookkeeping `j^(ac) = k^(bc) = l^(db)` — and bundled
this into a `Setoid`. We proved that powers of a fixed base are always dependent
(`multDep_pow_self`), and the **barrier theorem** `coprime_not_multDep`: a base `j ≥ 2` coprime to
`k` is *never* multiplicatively dependent on `k`, witnessed concretely by `not_multDep_two_three`
(`¬ MultDep 2 3`), the obstruction that makes Cobham's theorem non-vacuous.

The headline advance over the originally-seeded plan is that the conjectured classification was
not merely stated but **proved**: `multDep_iff_common_root` shows that for bases `≥ 2`,
multiplicative dependence is *equivalent* to being positive powers of a single primitive base
`g ≥ 2`. The reverse direction is `multDep_pow_self` plus transitivity; the forward direction
runs through Mathlib's `Nat.exists_eq_pow_of_pow_eq_pow`, taking `g` to be the integer root
extracted from `j^a = k^b` at the gcd of the exponents. A clean corollary, `multDep_forces_two_le`,
shows that a genuine base `j ≥ 2` can only be dependent on another genuine base `k ≥ 2`.

The structural insight is that the geometric Cobham-invariance machinery already in the catalog
(`Catalog/Bridges/OracleCobhamInvariance.lean`: prefix ultrametrics, `AdmissibleSimulation`,
`traceBall` rigidity) and the arithmetic obstruction proved here are two faces of one coin: a base
change is an admissible simulation with bounded depth loss precisely when the bases are
multiplicatively dependent. The geometric side measures *how cheaply* one model simulates another;
the arithmetic side measures *whether a finite-distortion simulation can exist at all*. What failed
productively was the analytic framing `log j / log k ∈ ℚ`: it imports real-analytic machinery for
a statement that, over integer bases `≥ 2`, is pure exponent arithmetic — recognizing this
collapse is what let every result land with `decide`-free, `native_decide`-free proofs.

## Results Summary

- `multDep_refl`, `multDep_symm`, `multDep_trans` — proved: `MultDep` is an equivalence relation.
- `multDep_setoid` — proved: the bundled `Setoid` on bases.
- `multDep_pow_self` — proved: positive powers of a fixed base are always dependent.
- `coprime_not_multDep` — proved: **the barrier**, `j ≥ 2` coprime to `k` ⇒ `¬ MultDep j k`
  (sharper one-sided form; `2 ≤ k` unnecessary).
- `not_multDep_two_three` — proved: the concrete non-vacuity witness `¬ MultDep 2 3`.
- `multDep_iff_common_root` — **proved (upgraded from conjecture)**: dependence of bases `≥ 2` is
  equivalent to being common powers of a single base `g ≥ 2`.
- `multDep_forces_two_le` — proved: dependence on a genuine base `j ≥ 2` forces `k ≥ 2`.

## Research Directions

### Direction 1: The quotient of bases is the set of primitive (non-perfect-power) bases
Now that `multDep_iff_common_root` supplies a normal form, the natural next object is the quotient
`ℕ / multDep_setoid` restricted to `{n // 2 ≤ n}`. Conjecture: the quotient is in canonical
bijection with the set of *primitive* bases — those `g ≥ 2` that are not themselves perfect powers
(`¬ ∃ h e, 2 ≤ h ∧ 2 ≤ e ∧ g = h^e`) — via the map sending each base to its smallest root.
**The key insight is** that `multDep_iff_common_root` already turns "are `j, k` dependent?" into
"do they have a common integer root?", so the equivalence class of a base is exactly the tower of
powers of its primitive root, and primitivity is the canonical class representative.
**Why now?** The three equivalence axioms and the common-root classification are all proved this
cycle, so only the existence-and-uniqueness of the primitive root (a `Nat.factorization`-gcd
argument) and the bijection bookkeeping remain. **If true**, Cobham's `j`-automatic classes acquire
a clean, decidable parameter space; **if false**, there are hidden collisions among automatic
classes worth a counterexample hunt.

### Direction 2: Decidability of `MultDep` for concrete numerals
Conjecture: `MultDep j k` is decidable for `j, k ≥ 2`, with a terminating algorithm: factor both,
compute the primitive root and exponent of each, and compare roots. Formally, exhibit a
`Decidable (MultDep j k)` instance (or a `Bool`-valued `decMultDep` with a correctness theorem)
that does not enumerate exponents. **The key insight is** that `multDep_iff_common_root` replaces
the unbounded existential `∃ a b > 0` by a *bounded, computable* check on prime-factorization
exponent vectors — the gcd of the two exponent vectors must be proportional. **Why now?** The
equivalence to a common-root statement is in hand; promoting it to a `Decidable` instance is a
direct, localized engineering step on top of `Nat.factorization`. **If true**, the library gains a
runnable test for Cobham's hypothesis on any concrete pair of bases; **if false**, some genuinely
non-effective obstruction hides inside an apparently elementary relation.

### Direction 3: Quantitative barrier via prime valuations (a `p`-adic gap)
The current `coprime_not_multDep` produces a *qualitative* contradiction from a witnessing prime
`p ∣ j`. Conjecture: for coprime `j, k ≥ 2` there is an explicit prime `p` and a strictly positive
lower bound `|a · v_p(j) − b · v_p(k)| ≥ 1` for all `a, b > 0`, certifying `j^a ≠ k^b` *with a
gap* rather than merely `≠`. **The key insight is** that the prime `p` extracted in the barrier
proof has `v_p(k) = 0` (by coprimality) but `v_p(j) ≥ 1`, so the valuation of `j^a` is `a·v_p(j) ≥ 1`
while that of `k^b` is `0` — a uniform integer gap, not just inequality. **Why now?** The barrier
proof already isolates the witnessing prime; refining the contradiction into a valuation gap is a
strengthening of an existing argument. **If true**, this seeds Baker-style effective separation
bounds for `|j^a − k^b|` in the formal library; **if false**, the gap is non-uniform, pointing to
genuinely transcendental rather than `p`-adic obstructions.

### Direction 4: Bridging the arithmetic barrier to `AdmissibleSimulation`
Conjecture: if a length-respecting base-`j`-to-base-`k` digit transducer is an
`AdmissibleSimulation` (in the sense of `Catalog/Bridges/OracleCobhamInvariance.lean`) with finite
`depth_loss`, then `MultDep j k`; contrapositively, `coprime_not_multDep` forbids any
finite-distortion simulation between coprime bases. **The key insight is** that both halves now
exist in the catalog — the geometric simulation calculus (prefix ultrametrics, `traceBall`
rigidity) and the arithmetic barrier — so this is a *connect-the-dots* theorem: formalize base-`b`
expansion as an `OracleTrace` and show that a finite-`depth_loss` prefix-Lipschitz base converter
forces a common power. **Why now?** This is the first cycle in which both the geometric and
arithmetic strands are simultaneously available and sorry-free. **If true**, the catalog gains a
single machine-checked "no admissible simulation across independent bases" statement — the crux of
Cobham; **if false**, a finite-distortion simulation sneaks across independent bases, a genuinely
new collapse of base-dependent complexity.

### Direction 5: A faithful Lean *statement* of Cobham's theorem with verified non-vacuity
With multiplicative independence now a first-class, sorry-free, *classified* predicate, the
hypothesis of Cobham's theorem can finally be stated faithfully: define `b`-automatic sequences via
deterministic finite automata reading base-`b` digits, and state that a sequence simultaneously
`j`-automatic and `k`-automatic with `¬ MultDep j k` is eventually periodic. **The key insight is**
that `not_multDep_two_three` already certifies the hypothesis is non-vacuous, so even the
*statement* — with a checked witness that the independence premise can hold — is new infrastructure
for the automatic-sequences corner of the library. **Why now?** The non-degeneracy input is exactly
what was missing to phrase the theorem honestly; everything downstream is automaton theory that can
be built incrementally. **If true** (the statement and its non-vacuity), it is the prerequisite for
any formal proof attempt; the proof itself will likely require Semenov-style or first-order-logic
machinery not yet in the catalog, which maps out the next several cycles. **If false** at the level
of an automaton-theoretic counterexample, a 50-year-old theorem would be overturned — overwhelmingly
unlikely, so the real outcome is a precise inventory of the machinery still to be built.
