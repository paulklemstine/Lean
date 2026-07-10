# Computational Evidence

Mission: *Does the Borsuk–Ulam theorem imply Arrow's impossibility, so that "any
social choice function on `n` alternatives is either discontinuous or
dictatorial"?* We work in **contrarian** mode.

## 1. The topological kernel (1-D Borsuk–Ulam) — small cases

Borsuk–Ulam in dimension 1: a continuous `2π`-periodic `f : ℝ → ℝ` has an
antipodal pair `x, x+π` with `f x = f (x+π)`. Test functions (all verified to
have an antipodal coincidence by solving `f(x) = f(x+π)`):

| f(x)              | antipodal equation f(x)=f(x+π)        | a solution x |
|-------------------|----------------------------------------|--------------|
| cos x             | cos x = cos(x+π) = −cos x ⇒ cos x = 0  | x = π/2      |
| sin x             | sin x = −sin x ⇒ sin x = 0             | x = 0        |
| cos 2x            | cos 2x = cos(2x+2π) = cos 2x           | every x      |
| cos x + sin 3x    | reduces to cos x = 0 (odd part)        | x = π/2      |

For any `f`, the auxiliary `g(x) = f(x) − f(x+π)` satisfies `g(x+π) = −g(x)`, so
`g(0) = −g(π)`; the two endpoints have opposite sign, and the intermediate value
theorem forces a zero. This is exactly the Lean proof of `borsuk_ulam_1d`.

**Consequence tested:** one cannot have `f(x+π) < f(x)` for *all* `x` (a strictly
consistent antipodal preference). Any attempted example (e.g. `f = cos`, `f = a
linear ramp made periodic`) fails at the coincidence point. Formalized as
`no_strict_antipodal_preference`.

## 2. Counterexample hunt against "continuous ⟹ dictatorial"

The strong conjecture claims every continuous aggregation rule is dictatorial.
We hunt for a continuous, unanimous, anonymous, **non-dictatorial** rule on the
contractible preference domain `ℝ` (positions on a line). The **mean** is the
obvious candidate:

`avg(p₁,…,p_n) = (p₁+…+p_n)/n`.

Small cases (n = 2):

| profile (p₁,p₂) | avg  | dictator-1? (=p₁) | dictator-2? (=p₂) |
|-----------------|------|-------------------|-------------------|
| (0,0)           | 0    | yes               | yes               |
| (0,1)           | 0.5  | **no**            | **no**            |
| (1,0)           | 0.5  | **no**            | **no**            |
| (3,3)           | 3    | yes (unanimity)   | yes               |

The profile `(0,1)` already witnesses non-dictatorship for **both** agents:
`avg = 0.5` equals neither coordinate. More generally the profile
`p_j = [j = i] ? 0 : 1` gives `avg = (n−1)/n ≠ 0 = p_i`, refuting dictator `i`
for every `i` when `n ≥ 2`. This is the Lean proof of `avg_not_dictatorial`.

Meanwhile `avg` is continuous (finite sum of projections / n), unanimous
(`avg(c,…,c) = c`), and anonymous (symmetric in its arguments). **Counterexample
found — the strong conjecture is false.**

## 3. Why Borsuk–Ulam does not rescue the conjecture

The Borsuk–Ulam / Chichilnisky obstruction lives on **non-contractible** spaces
(spheres). On the line/interval (contractible) there is no obstruction, and the
mean is a perfectly good continuous non-dictatorial rule. The description's
"preference sphere" only produces an obstruction when the preference space is
genuinely a sphere; Arrow's *discrete* theorem is not literally a corollary of
Borsuk–Ulam. See `FUTURE_DIRECTIONS.md`.

## No OEIS sequence

No integer sequence arises; the content is analytic/topological, so an OEIS
search is not applicable.
