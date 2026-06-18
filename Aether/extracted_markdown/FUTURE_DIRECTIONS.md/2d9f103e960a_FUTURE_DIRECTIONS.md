# Future Directions: Closure Potential Descent and Certified Reconstruction

The file `Catalog/Bridges/ClosurePotentialDescent.lean` turns the catalog's
"closure potential" intuition into a *quantitative descent certificate*: an
abstract `PotentialDescentSystem` whose update map fixes terminal states and
strictly decreases a `ℕ`-valued potential off terminal states yields
monotonicity (`potential_mono_step`), strict descent
(`potential_strict_of_not_done`), a fixed-point/terminality correspondence
(`fixedPoint_iff_done`), and a termination bound (`terminates_within`). This is
instantiated by a concrete closure reconstruction process that adjoins witnesses
of non-closedness (`closureStep`), preserves the closure
(`closureStep_preserves_closure`), and reconstructs `cl s₀` within `pot s₀`
probe steps (`reconstruction_correct`), and finally packaged as a certified
`InfoEfficientAlgorithm` (`closureRecon`, `closureRecon_resource_bound`). The
directions below extend this scaffold.

## 1. Sharp potential = closure rank, not the trivial co-cardinality bound

The current potential `reconPot s = |α| − |s|` gives a worst-case bound of
`|α|` probe calls. But the number of *probe steps actually taken* equals
`|cl s₀| − |s₀|`, since each step adjoins one element of `cl s₀ \ s₀` and the
closure is invariant. **The key insight is** that the closure-invariance lemma
`closureStep_preserves_closure` already pins every iterate inside `cl s₀`, so the
honest potential is `|cl s| − |s|`, a strictly tighter, closure-aware measure
that still satisfies the descent axioms. Conjecture: with this potential the
reconstruction terminates in *exactly* `|cl s₀| − |s₀|` steps, and this count is
optimal among all monotone adjunction strategies. Why now: the invariance and
descent lemmas are already proven, so refining the measure is a localized change
that immediately yields a provably sharp (not merely sound) complexity bound —
the difference between an upper bound and an exact resource accounting.

## 2. Anti-monotone counterexamples: minimal hypotheses for strict descent

Strict descent is falsifiable. Drop idempotence, or replace the "adjoin one
genuinely new element" rule with an arbitrary probe, and the potential can stall
or oscillate. **The key insight is** that strict descent depends on exactly two
structural facts — extensivity (so `cl s \ s` witnesses non-closedness) and the
fact that a step strictly enlarges the carrier — and *neither monotonicity nor
idempotence is logically needed for termination*, only for the closure-equals-
target correctness conclusion. Conjecture: there is a non-idempotent extensive
operator and a probe family for which `closureStep` still terminates but the
limit is not a closure fixed point, exhibiting a clean separation between the
termination package (parts 1–3) and the correctness package (parts 4–5).
Why now: the abstract `PotentialDescentSystem` cleanly isolates the descent
axioms from the closure axioms, so building a small finite counterexample
(say on `Fin 3`) is a self-contained, machine-checkable falsification task.

## 3. Closure-stable probes as Koopman eigenobservables with descent guarantees

The catalog's `ClosureStableProbe` says an observable is invariant under closure
expansion. In our process every adjoined element is detected by such a probe.
**The key insight is** that a closure-stable probe is exactly an observable that
is *constant along the descent orbit* (a discrete Koopman eigenfunction with
eigenvalue 1), so the family of closure-stable probes spans the conserved
quantities of the reconstruction dynamics, while `reconPot` is the unique (up to
affine scaling) monotone Lyapunov function transverse to them. Conjecture: the
closed sets are precisely the common level sets stabilized by all
closure-stable probes, giving a probe-theoretic characterization of terminality
that refines `fixedPoint_iff_done`. Why now: `ClosureStableProbe` and our
`closureStep` already share the `cl s \ s` witness mechanism, so connecting the
conserved-observable viewpoint to the proven termination certificate is a direct
bridge between the EML closure-computation file and this descent framework.

## 4. Lattice-height composition: descent over towers of closure systems

Reconstruction often factors through a chain of coarser-to-finer closure
operators `cl₁ ≤ cl₂ ≤ … ≤ clₖ`. **The key insight is** that potentials compose
additively: running `closureStep` for `cl₁` to a fixed point, then for `cl₂`,
etc., is itself a `PotentialDescentSystem` whose potential is the lexicographic /
summed potential, so the total probe count is bounded by the sum of layer
potentials rather than the product. Conjecture: for a tower of height `k` on a
universe of size `n`, certified reconstruction costs at most `n` probes total
(not `k·n`), because closure invariance forbids re-expanding already-closed
layers. Why now: the abstract structure is closed under this kind of sequential
composition, and the additivity of `ℕ`-valued potentials makes the bound a
direct `omega`-style consequence once the per-layer descent lemmas are in hand.

## 5. From finite `ℕ` potentials to ordered-monoid potentials over infinite height

Our potential is `ℕ`-valued, which forces a finite universe. **The key insight
is** that the only property of `ℕ` used in `terminates_within` is that `<` is
well-founded, so the entire termination package generalizes verbatim to any
potential valued in a well-founded ordered commutative monoid (e.g. ordinals,
or `ℕ`-lexicographic tuples), covering algebraic closure systems of infinite but
well-founded height such as Noetherian ideal generation. Conjecture: replacing
`Φ : S → ℕ` by `Φ : S → Ω` for a well-ordered `Ω` preserves all four abstract
theorems, and instantiates against the catalog's Noetherian closure
certification (`Algebra/EMLClosureUnification/Core.lean`) to give certified
transfinite termination of ascending-chain stabilization. Why now: the proof of
`terminates_within` already uses strong induction on the potential value, so the
generalization is a matter of replacing `Nat.strong_induction_on` with
well-founded recursion — a small, high-leverage abstraction step that unifies the
finite reconstruction story with classical Noetherian descent.
