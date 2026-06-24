# Theorem Trace (internal, anti-hallucination)

Source of truth: `Catalog/EML/Transseries/MonomialOrder.lean`
(namespace `EMLTransseries.MonomialOrder`).

## Definitions

| Lean name | Mathematical statement | Article | Paper |
|---|---|---|---|
| `TransMono` | `Lex (ℤ →₀ ℝ)`: ordered value group of transmonomials (finitely supported real exponents indexed by integer tower height, lexicographic order). | §"A ladder of magnitudes" | Def. 2.1 |
| `TSeries` | `Lex (HahnSeries TransMono ℝ)`: ordered field of transseries (Hahn series over `TransMono`, lexicographically ordered). | §"A ladder of magnitudes" | Def. 2.2 |
| `term g a` | `toLex (HahnSeries.single g a)`: one-term series, coefficient `a` on monomial `g`. | §"One brick at a time" | Def. 2.3 |
| `posExp` | `toLex (Finsupp.single (0:ℤ) (1:ℝ))`: the exponent of `x` itself. | §"Building an infinitesimal" | Def. 2.4 |

## Theorems / lemmas

| Lean name | Statement | Article | Paper |
|---|---|---|---|
| `single_pos_iff_coeff_pos` | `0 < term g a ↔ 0 < a` | §"Signs from a single number" | Thm 3.1 |
| `single_neg_of_coeff_neg` | `a < 0 → term g a < 0` | §"Signs from a single number" | Thm 3.2 |
| `term_mul_term` | `term g a * term h b = term (g + h) (a * b)` | §"The monomial law" | Thm 3.3 |
| `single_square_of_double_exponent` | `g = k + k → 0 ≤ a → term k (Real.sqrt a) ^ 2 = term g a` | §"Taking a square root" | Thm 3.4 |
| `not_square_negative_monomial` | `a < 0 → ¬ IsSquare (term g a)` | §"What cannot be a square" | Thm 3.5 |
| `natCast_eq_term` | `(n : TSeries) = term 0 (n : ℝ)` | §"Constants" | Lem 3.6 |
| `one_eq_term` | `(1 : TSeries) = term 0 1` | §"Constants" | Lem 3.7 |
| `positive_infinitesimal_monomial` | `0 < δ → (0 < term δ 1 ∧ ∀ n:ℕ, (n:TSeries) * term δ 1 < 1)` | §"Building an infinitesimal" | Thm 3.8 |
| `posExp_pos` | `0 < posExp` | §"Building an infinitesimal" | Lem 3.9 |
| `explicit_positive_infinitesimal` | concrete instance of `positive_infinitesimal_monomial` at `δ = posExp` | §"Building an infinitesimal" | Cor 3.10 |

## Honesty constraints (from Lean docstring "Scope")
- This is NOT a proof of real closure of the transseries field.
- This is NOT square-root closure in general.
- It IS a verified base layer: monomial signs, monomial arithmetic, valid square
  roots of positive square-compatible monomials, and infinitesimals.
- Real closure / general square roots / divisibility of the value group are FUTURE work.
