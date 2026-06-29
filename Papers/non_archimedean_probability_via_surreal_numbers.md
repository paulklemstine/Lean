# Computational Evidence — Non-Archimedean Probability via Surreal Numbers

This cycle's claims are *exact order facts* in the Hahn-series field
`K = Lex (ℝ⟦ℚ⟧)` (a set-sized ordered subfield of Conway's surreals), so the
"evidence" below is the finite leading-coefficient computation that each formal
proof carries out, sanity-checked on small cases. Everything here is subsumed by the
machine-checked theorems in `SurrealInfinitesimalField.lean` and
`SurrealProbability.lean`.

## 1. The infinitesimal `eps = ω^{-1} = single 1 1`

Order comparisons reduce to the *leading* (lowest-exponent) coefficient
(`HahnSeries.leadingCoeff_pos_iff`). Writing a series as its exponent→coefficient table:

| element            | table (exponent : coeff)      | leading term | sign |
|--------------------|-------------------------------|--------------|------|
| `eps`              | `1 : 1`                       | `+1` at exp 1| `> 0`|
| `q - eps`  (q>0)   | `0 : q`, `1 : -1`             | `+q` at exp 0| `> 0` ⇒ `eps < q` |
| `1 - n·eps`        | `0 : 1`, `1 : -n`             | `+1` at exp 0| `> 0` ⇒ `n·eps < 1` |

Spot checks (all confirmed by the lowest-exponent rule):

* `eps < 1/2, 1/10, 1/1000, …` — yes, since the order-0 coefficient of `q - eps` is
  `q > 0` for every positive rational `q` (`eps_lt_ratCast`).
* `1·eps, 2·eps, 10·eps, 10^6·eps` are all `< 1` — yes, order-0 coeff of `1 - n·eps`
  is `1 > 0` independent of `n` (`nat_mul_eps_lt_one`).

These say `eps` is a genuine non-Archimedean infinitesimal: positive but below every
positive real, with no finite multiple reaching `1`.

## 2. The measure `emeasure ⟨c, A⟩ = (c : K) + |A|·eps`

Small disjoint-union checks of finite additivity (`emeasure_join_disjoint`):

| `E₁`          | `E₂`          | `E₁ ⊔ E₂`        | `μ E₁`      | `μ E₂`      | `μ(E₁⊔E₂)`   |
|---------------|---------------|------------------|-------------|-------------|--------------|
| `⟨1/2, {a}⟩`  | `⟨1/2, {b}⟩`  | `⟨1, {a,b}⟩`     | `1/2 + eps` | `1/2 + eps` | `1 + 2·eps`  |
| `⟨1, ∅⟩`      | `⟨0, {a}⟩`    | `⟨1, {a}⟩`       | `1`         | `eps`       | `1 + eps`    |
| `⟨0, {a}⟩`    | `⟨0, {b}⟩`    | `⟨0, {a,b}⟩`     | `eps`       | `eps`       | `2·eps`      |

All rows satisfy `μ(E₁⊔E₂) = μ E₁ + μ E₂` (requires `a ≠ b` for disjoint atoms).

## 3. Counterexample hunt for the naive conjecture

Claim tested: "the infinitesimal point masses of a subset sum to its measure."
* Finite subset `S` of `n` points: total atomic mass `n·eps`, which is `< 1` for
  *every* `n` (`finite_atoms_lt_one`). So no finite point set reaches mass `1`.
* Therefore the whole-space mass `1` (`emeasure_univ`) is **not** obtained by summing
  point masses: it lives in the continuous content, and `[0,1]` is not a finite
  disjoint union of points. The naive "sum equals 1" reading is *false*; the
  finitely-additive reading is *true*. This dichotomy is the cycle's main finding.

## OEIS

No integer sequence arises (the objects are infinitesimal/field-valued, not integer
counting sequences), so no OEIS lookup applies.
