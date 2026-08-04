# Computational Evidence

Target claim: with `Ω = ω₁` and

`ψ(a) = min { b : b is not generated from {0, Ω} ∪ {ψ(c) : c < a} by ordinal addition and x ↦ ω^x }`

we have `ψ(0) = ε₀` and `ε₀ < ψ(Ω^ω)`, and the Cantor normal form notations of PA embed
order-preservingly below `ψ(Ω^ω) ≤ ψ(ε_{Ω+1})` (Bachmann–Howard, the ordinal of KP).

## 1. Small-case calculations (hull `C(0)` generated from `{0, Ω}`)

Generating from `0` with `+` and `x ↦ ω^x`, the countable part of the hull is exactly the
set of ordinals with a Cantor normal form built from `0`:

| stage | new ordinals obtained | supremum reached |
|-------|-----------------------|------------------|
| 0 | `0` | `0` |
| 1 | `1 = ω^0` | `1` |
| 2 | `2, 3, …` (`1+1`, …), `ω = ω^1` | `ω` |
| 3 | `ω+1, ω·2, ω^2, ω^ω`, … | `ω^ω` |
| n | all CNF terms of height `< n` | tower `ω^ω^···^ω` (`n` times) |
| sup | all ordinals `< ε₀` | `ε₀` |

So `C(0) ∩ Ω = Iio ε₀`, i.e. the least ordinal not generated is `ε₀`, matching `ψ(0) = ε₀`.
The towers are the iterates `(ω^·)^[n] 0`: `0, 1, ω, ω^ω, ω^ω^ω, …` whose supremum is `ε₀`
(this is exactly Mathlib's `nfp (ω ^ ·) 0`, the definition used in the Lean file).

The numeric shadow of these towers (the "tower of exponents" sequence `1, 2, 4, 16, 65536, …`,
OEIS **A014221**, `a(n+1) = 2^a(n)`) is the standard finitary analogue; the ordinal
`fastGrowingε₀` values in Mathlib (`fastGrowingε₀ 2 = 2048`) confirm the same tower shape.

## 2. Why `ε₀ < ψ(Ω^ω)` is forced

`Ω^ω > 0`, hence `ψ(0) = ε₀` is itself one of the generators of the hull `C(Ω^ω)`.
Therefore every `b ≤ ε₀` belongs to `C(Ω^ω)`:

* `b < ε₀`: already in `C(0) ⊆ C(Ω^ω)` (Cantor normal form, table above);
* `b = ε₀`: it is the generator `ψ(0)`.

Since `ψ(Ω^ω)` is *not* in the hull, `ψ(Ω^ω) > ε₀`. The same argument gives the sharper
statement proved in Lean: `ε₀ < ψ(a)` for **every** `a > 0`.

## 3. Counterexample hunt

The universal statements we formalise are:

* `Gen S x → x < m` whenever every generator is below an epsilon number `m`
  (tested mentally on `S = {0, Ω}`, `m = ε_{Ω+1}`: `Ω + Ω`, `ω^(Ω+Ω)`, … all stay below);
* monotonicity `a ≤ a' → ψ(a) ≤ ψ(a')` (the hulls increase, the minimum of the complement
  can only increase);
* order preservation of the translation `ONote → OTerm`; here the value map is
  `val (ofONote o) = ONote.repr o`, so a counterexample would be a Cantor normal form whose
  translated term has a different value. Structural checks on
  `0, 1, ω, ω+1, ω·3, ω^ω, ω^ω·2 + ω + 5` all agree, since
  `repeatAdd (ω^e) n a` evaluates to `ω^e · n + a`, which is literally the definition of
  `ONote.repr (oadd e n a)`.

No counterexample was found; all three statements are proved in Lean in
`Catalog/Bridges/OrdinalAnalysisBridge.lean`.

## 4. Rewriting system: weight table

The termination measure `weight` used for the rewriting system:

| term | weight |
|------|--------|
| `0`, `Ω` | `1` |
| `a + b` | `2·w(a) + w(b) + 1` |
| `ω^a`, `ψ(a)` | `w(a) + 1` |

Checks for the three rules (with `x = w a`, `y = w b`, `z = w c`):

* `0 + t ⟶ t`: `2 + y + 1 > y` ✓
* `t + 0 ⟶ t`: `2x + 2 > x` ✓
* `(a+b)+c ⟶ a+(b+c)`: `4x + 2y + z + 3 > 2x + 2y + z + 2` ✓

Hence every rewrite strictly decreases a natural number: the system terminates, which is
proved formally as `Step.weight_lt` and `step_wf`.

*(All numbers above are hand/symbolic computations used to guide the formalisation; the
authoritative statements are the machine-checked Lean theorems.)*

## Addendum: the unrestricted hull makes `psi` strictly increasing

A small "counterexample hunt" on the *shape* of the definition rather than on numbers:
at stage `b`, the generator set `gens b` contains `psi a` for every `a < b`, while
`psi b` is by construction outside the hull of `gens b`. Hence `psi a ≠ psi b` whenever
`a < b`, so no value can ever be repeated: `psi` is strictly increasing, therefore
inflationary (`a ≤ psi a`), therefore `psi Ω ≥ Ω`. So the "collapse stays countable"
expectation (conjecture C1 of the first draft of `FUTURE_DIRECTIONS.md`) fails for this
presentation; the genuine Madore collapse restricts the generators to those `psi c` with
`c` itself in the hull. Both the strictness and the refutation are formalised in
`Catalog/Bridges/OrdinalAnalysisBridgeExtras.lean`
(`psi_strictMono`, `not_forall_psi_lt_Om`).

## Addendum 2: the stage-by-stage table, and what it predicts

Working out the first stages of the hull by hand (each row: the generators available, and
the least ordinal they fail to generate) gives

| stage `a` | `gens a` | `psi a` |
|---|---|---|
| `0` | `{0, Ω}` | `ε₀` |
| `1` | `{0, Ω, ε₀}` | `ε₁` |
| `n` | `{0, Ω, ε₀, …, ε_{n-1}}` | `ε_n` |
| `ω` | `{0, Ω} ∪ {ε_n}` | `ε_ω` |
| `c < Ω` | `{0, Ω} ∪ {ε_d : d < c}` | `ε_c` |
| `Ω` | `{0, Ω} ∪ {ε_c : c < Ω}` | `ε_{Ω+1}` (note the jump: `ε_Ω = Ω`) |
| `Ω + b` | above plus the earlier collapses | `ε_{Ω+1+b}` |

Every row of this table is now a theorem: `psi_zero`, `psi_eq_epsilon_of_lt_Om`,
`psi_Om_eq_epsilon`, `psi_add_eq_epsilon` in
`Catalog/Bridges/OrdinalAnalysisBridgeContinuity.lean`. The table also predicted the two
qualitative facts proved there: the sequence is continuous at every limit except `Ω`
(`psi_of_limit`, `psi_discontinuous_at_Om`), and exactly one epsilon number, namely
`Ω = ε_Ω` itself, is missing from the range (`range_psi`).

Read off at the ordinals of interest: `ψ(0) = ε₀`, `ψ(Ω^ω) = ε_{Ω^ω}` and
`ψ(ε_{Ω+1}) = ε_{ε_{Ω+1}}`, which is the numerical content of the chain
`ε₀ < ψ(Ω^ω) ≤ ψ(ε_{Ω+1})` proved in the first file.
