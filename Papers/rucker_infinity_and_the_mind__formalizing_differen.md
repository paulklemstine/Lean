# Computational Evidence

The objects here (`ℵ₀`, `2^ℵ₀`, `ℵ₁`, `𝔠`, `ℵ_ω`, cofinalities) are infinite
cardinals, so they are not directly computable by `#eval`. The appropriate
"computation" is symbolic/structural, and each observation below is discharged
by a corresponding machine-checked theorem in
`Catalog/Bridges/RuckerInfinityHierarchy.lean`.

## 1. The Cantor tower — small cases

`cantorTower n` is the truncated beth sequence:

| n | cantorTower n | size |
|---|---------------|------|
| 0 | ℵ₀            | countable |
| 1 | 2^ℵ₀ = 𝔠     | continuum |
| 2 | 2^𝔠          | > continuum |
| 3 | 2^(2^𝔠)      | larger still |

Each step is *strictly* larger by Cantor's theorem `c < 2^c`
(`Cardinal.cantor`). Verified: `cantorTower_lt_succ`, `cantorTower_strictMono`,
and `aleph0_le_cantorTower` (every stage is infinite).

## 2. Ordering facts

* `ℵ₀ < ℵ₁` — verified (`aleph0_lt_aleph1`).
* `ℵ₁ ≤ 𝔠` — verified (`aleph1_le_continuum`); the "easy half" of CH.
* `𝔠 = 2^ℵ₀` — `Cardinal.two_power_aleph0`, used throughout.

## 3. Counterexample hunt (contrarian claim)

Naive claim tested: *"the continuum could be `ℵ_ω`."*

Cofinality distinguishes them:
* `cof(𝔠) > ℵ₀`  (König: `Cardinal.lt_cof_power`) — `aleph0_lt_cof_continuum`.
* `cof(ℵ_ω) = ℵ₀`  (since `(aleph ω).ord = ω_ ω` and `cof ω = ℵ₀`) —
  `cof_aleph_omega`.

Since a would-be equality `𝔠 = ℵ_ω` forces equal cofinalities, it is impossible.
**Counterexample to the naive equality found and formally refuted**:
`continuum_ne_aleph_omega`.

## 4. Sanity checks on `ℵ₀`'s "inaccessibility"

* `ℵ₀ ≤ cof(ℵ₀)` (regular) — `aleph0_regular`.
* For all finite `x < ℵ₀`, `2^x < ℵ₀` (strong limit) — `aleph0_strong_limit`.
* Yet `ℵ₀` is **not** `IsInaccessible` (the definition demands `ℵ₀ < c`) —
  `aleph0_inaccessible_except_uncountable`.

All observations above correspond to theorems that compile with no `sorry` and
no extra axioms beyond Mathlib's standard `propext`, `Classical.choice`,
`Quot.sound`.
