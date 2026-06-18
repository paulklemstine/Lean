# Future Directions: The Multiplicative Independence Barrier behind Cobham's Theorem

## Synthesis

This cycle isolated the *arithmetic core* of Cobham's theorem (1972) — the hypothesis of
**multiplicative independence** of the two numeration bases — and formalized it as a
single, self-contained predicate `MultDep k l := ∃ a b, 0 < a ∧ 0 < b ∧ k^a = l^b` in
`Logic/MultiplicativeIndependenceCore.lean`. Around this predicate we built three layers
of understanding, each fully machine-checked (`sorry = 0`, axioms limited to
`propext`, `Classical.choice`, `Quot.sound`):

1. **Algebraic skeleton.** `MultDep` is an *equivalence relation* on `ℕ`
   (`multDep_equivalence`), with transitivity carried by exponent interleaving
   `k^a = l^b ∧ l^c = m^d ⟹ k^{ac} = m^{bd}`. This is the structural reason the
   "multiplicative dependence class" of a base is well-defined.
2. **Number-theoretic barrier.** Coprime bases `≥ 2` are always independent
   (`not_multDep_of_coprime`): any prime dividing one base must divide the other.
   This recovers the textbook fact that `2` and `3` are multiplicatively independent
   (`not_multDep_two_three`) while `2` and `4` are dependent (`multDep_two_four`).
3. **Transcendence bridge.** For bases `≥ 2`, `MultDep k l` holds **iff**
   `log k / log l ∈ ℚ` (`multDep_iff_log_ratio_rational`). This re-expresses Cobham's
   combinatorial hypothesis as a single statement about the rationality of one real
   ratio — the doorway to Diophantine approximation and Baker-style transcendence.

## Results Summary

| Theorem | Statement | Role |
|---|---|---|
| `multDep_equivalence` | `Equivalence MultDep` | Algebraic skeleton |
| `multDep_of_common_base` | `MultDep (n^s) (n^t)` for `s,t>0` | Sufficient condition |
| `multDep_two_four` | `MultDep 2 4` | Witness of dependence |
| `not_multDep_of_coprime` | coprime, `k≥2` ⟹ `¬ MultDep k l` | Independence barrier |
| `not_multDep_two_three` | `¬ MultDep 2 3` | Canonical instance |
| `multDep_iff_log_ratio_rational` | `MultDep k l ↔ ∃ q:ℚ, log k/log l = q` | Transcendence bridge |

A documented *failure* shaped the design: characterizing dependence by "shared prime
support" is **wrong** (`6` and `12` share support `{2,3}` yet `6^a = 12^b` forces
`a=b=0`). The correct invariant is the projective ratio of exponent vectors, captured
cleanly by `log k / log l`.

## Research Directions

### Direction 1 — Independence is decidable, and the witness is the gcd of valuations.

Conjecture: for fixed `k, l ≥ 2`, `MultDep k l` is decidable, and moreover
`MultDep k l ↔ k.factorization` and `l.factorization` are proportional as functions on
the shared prime support (i.e. there exist positive `a, b` with `a • k.factorization =
b • l.factorization`). **The key insight is** that `k^a = l^b` is, after taking
`Nat.factorization`, a *linear* system over the primes, so dependence is exactly
proportionality of two integer vectors — checkable by comparing `padicValNat p k` ratios.
*Why now?* We already have `not_multDep_of_coprime` (the support-disjoint extreme) and the
log bridge (the support-equal extreme); the factorization-proportionality statement is the
common generalization that unifies both, and Mathlib's `Nat.factorization` API makes it
directly attackable.

### Direction 2 — A `Setoid`/quotient packaging of multiplicative dependence classes.

Conjecture: `MultDep` descends to a `Setoid ℕ` whose nontrivial classes are exactly the
sets `{ n^j : j ≥ 1 }` for `n` *not a perfect power*; equivalently every class has a unique
"primitive root" base. **The key insight is** that transitivity (already proved) gives a
genuine equivalence, so the only missing content is canonical representatives, and a base
is canonical iff it is not itself a proper power. *Why now?* `multDep_equivalence` is in
hand, so we can immediately form the `Setoid` and the remaining work — existence/uniqueness
of the primitive base — reduces to Mathlib's existing perfect-power machinery
(`Nat.exists_eq_pow_of_...`).

### Direction 3 — From the log bridge to irrationality / transcendence of `log k / log l`.

Conjecture: for multiplicatively independent `k, l ≥ 2`, `log k / log l` is not merely
irrational but transcendental (a consequence of the Gelfond–Schneider theorem). **The key
insight is** that `multDep_iff_log_ratio_rational` already converts independence into
irrationality of `log k / log l`; upgrading "irrational" to "transcendental" is exactly the
content of Gelfond–Schneider applied to `k = l^{log k / log l}`. *Why now?* The rational
case is fully formalized, cleanly separating the elementary part (done) from the deep
analytic part, giving a precise, falsifiable target whose statement is already in Lean.

### Direction 4 — Cobham's theorem proper: periodicity of doubly recognizable sets.

Conjecture: a set `S ⊆ ℕ` recognizable in two multiplicatively independent bases is
eventually periodic. **The key insight is** that `MultDep` is the *only* place the two bases
interact, so a Lean development can take `¬ MultDep k l` as a clean hypothesis and reduce
the theorem to an automata-theoretic density/syndeticity argument that never again mentions
arithmetic of the bases. *Why now?* With the arithmetic core fully abstracted and proved,
the next cycle can build the automaton/`k`-recognizable layer on top of a stable, verified
foundation rather than entangling the two.

### Direction 5 — Quantitative independence: explicit gaps in the power lattice.

Conjecture: for multiplicatively independent `k, l ≥ 2` there is an effective lower bound
`|a log k - b log l| ≥ C(k,l) / max(a,b)^{N}` for all positive `a, b` (a Baker-type linear
forms in logarithms estimate). **The key insight is** that `not_multDep_of_coprime` and the
log bridge only assert the gap is *nonzero*; making the gap *effective* is what turns the
qualitative barrier into a usable tool for bounding the structure of doubly recognizable
sets. *Why now?* The qualitative `≠ 0` statement is formalized, so the effective refinement
is a well-posed strengthening with an exact Lean signature to aim at, and partial effective
bounds (rational `a/b` denominators) are reachable with current Mathlib analysis.
