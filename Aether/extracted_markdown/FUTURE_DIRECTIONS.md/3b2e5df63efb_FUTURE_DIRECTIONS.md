# Future Directions: From the Finite Veblen Tower to Full Ordinal Analysis

The module `Catalog/Logic/VeblenHierarchy.lean` builds the finite-level Veblen
hierarchy `veblenN : ℕ → Ordinal → Ordinal` by iterating Mathlib's fixed-point
enumerator `Ordinal.deriv`, and proves that this tower is *coherent*: every level
is normal, each level-`n+1` value is a fixed point of level `n`, the tower is
monotone (and strictly separating away from fixed points) in the level, and the
least level-`1` fixed point `epsilon0` genuinely satisfies `ω ^ ε₀ = ε₀` with
`ω ≤ ε₀`. The following conjectures extend this verified core.

## 1. The Two-Argument (Transfinite) Veblen Function `φ : Ordinal → Ordinal → Ordinal`

Our `veblenN` is indexed by natural numbers. The classical Veblen function is
indexed by *ordinals*, with `φ α` for a limit `α` enumerating the common fixed
points of all `φ β`, `β < α`. The conjecture is that `veblenN n` agrees with the
restriction of the transfinite `φ` to finite first arguments, i.e. there is a
normal `φ : Ordinal → Ordinal → Ordinal` with `φ (n : Ordinal) = veblenN n` for
all `n : ℕ`, `φ (succ α) = Ordinal.deriv (φ α)`, and `φ` continuous in the first
argument.

The key insight is that `veblenN_succ_fp` and `veblenN_isNormal` are *exactly*
the successor-step obligations of the transfinite recursion, so the only genuinely
new content is the limit case, which should be packaged as
`Ordinal.derivFamily` over the family `fun (β : Set.Iio α) => φ β`. Our finite
results then become the base instances that pin down the recursion.

Why now? Mathlib already ships `Ordinal.derivFamily` and `Ordinal.nfpFamily`,
and our `veblenN_mono_level` shows the level-indexed compatibility that any
transfinite extension must restrict to — so the finite tower is a ready-made
correctness oracle for the ordinal-indexed definition.

## 2. The Diagonal Γ₀ and Its Fixed-Point Equation

Define `Gamma0 := Ordinal.nfp (fun α => /- φ α 0 -/) 0`, the Feferman–Schütte
ordinal, as the first fixed point of the level-diagonal `n ↦ veblenN n 0`
(extended transfinitely as in Direction 1). The conjecture is the analogue of our
`omega_opow_epsilon0`: `Gamma0` is the least ordinal closed under the entire
two-argument Veblen function, i.e. `φ Gamma0 0 = Gamma0`.

The key insight is that the diagonal `n ↦ veblenN n 0` is itself increasing —
this is precisely the content of our `veblenN_mono_level` specialized to `o = 0` —
so its normalized fixed point exists and the proof mirrors, one level up, the
`epsilon0` argument we already formalized.

Why now? We have a fully verified template (`omega_le_epsilon0`,
`omega_opow_epsilon0`) for "least fixed point of an inflationary normal map
satisfies its defining equation"; `Γ₀` is the same theorem applied to the
diagonal map, so the reasoning transfers with the transfinite `φ` in hand.

## 3. Strict Separation and the Exact Fixed-Point Locus

We proved `veblenN_lt_succ_of_not_fp`: levels separate strictly *except* at fixed
points of the lower level. The natural completion is a biconditional
characterization: `veblenN n o = veblenN (n+1) o ↔ veblenN n o = o`, and moreover
the fixed-point set of `veblenN n` is exactly the range of `veblenN (n+1)`.

The key insight is that for a normal `f`, `Ordinal.deriv f` enumerates *all and
only* the fixed points of `f`; combining this with our single-step bound
`veblenN_le_succ` collapses the inequality to an equivalence, turning the
one-directional `veblenN_lt_succ_of_not_fp` into a complete description of where
the tower is locally constant.

Why now? Mathlib's `Ordinal.deriv` API already characterizes the fixed-point
range (`Ordinal.range_deriv`-style lemmas), and our coherence lemmas supply the
missing inflationary half — the two halves meet exactly at this biconditional.

## 4. Bridge to `ONote`: a Decidable Notation for the `veblenN` Range Below ε₀

Mathlib's `ONote` gives a decidable Cantor-normal-form notation system for the
ordinals below `ε₀`. The conjecture is a soundness bridge: every ordinal of the
form `veblenN 0 o = ω ^ o` with `o < epsilon0` is denoted by some `ONote`, and
the `ONote` ordering agrees with the ordinal ordering induced by `veblenN 0`.

The key insight is that `veblenN 0 = (ω ^ ·)` is *literally* the constructor that
`ONote.oadd`/`ONote.repr` is built from, so the bridge is not an analogy but a
definitional match: `ONote.repr` is a concrete, executable section of `veblenN 0`
restricted below `ε₀`.

Why now? `epsilon0` is now formalized as an honest fixed point (`omega_opow_epsilon0`),
so "below ε₀" is a statement we can quantify over, and `ONote` provides the
decidable counterpart needed to make the correspondence computational.

## 5. Slow-Growing Complexity Bounds Indexed by `veblenN`

A longer-range application: assign to each level `n` the complexity class of
functions whose termination is certified by a descent in `veblenN n`. The
conjecture is a hierarchy theorem — the classes are strictly increasing in `n`,
with level `0` capturing exactly the primitive-recursive bounds and the diagonal
(Direction 2) capturing the predicative ones.

The key insight is that our strict-separation lemma `veblenN_lt_succ_of_not_fp`
gives, for free, witnesses that level `n+1` strictly dominates level `n` away
from fixed points — exactly the gap needed to separate the corresponding
complexity classes by a diagonalization argument.

Why now? Lean 4's termination checker already emits well-founded relations for
recursive definitions, and the verified coherence of `veblenN` provides a
mathematically rigorous yardstick against which those relations can be calibrated,
turning proof-theoretic ordinals into machine-checkable complexity certificates.
