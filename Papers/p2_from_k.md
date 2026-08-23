# Computational Evidence — duality eigensystems and the functional-equation sign

Scope: exploratory brute force used **before** formalisation, to test the mission
conjecture and to locate the exact boundary of its hypotheses.  All statements that
matter are afterwards proved in Lean 4 (see `Catalog/Applications/WeilDualitySign/`);
the tables below are *evidence*, not verification.

## Setup

A **duality eigensystem** of degree `d` over a field `K` is a triple `(Q, α, σ)` with
`Q ≠ 0`, `α : {1..d} → K`, `σ` a permutation with `σ∘σ = id` and
`α_i · α_{σ(i)} = Q²` for all `i` (`Q = q^{n/2}`, `Q² = q^n`).

Quantities measured:

* `∏ α_i` (the eigenvalue product, `= q^{m}` iff it equals `Q^d`);
* `#neg-fixed = #{i : σ(i) = i, α_i = −Q}`;
* `m₊ = #{i : α_i = +Q}` (the central multiplicity);
* `ε = (−1)^d · (∏ α_i)/Q^d` (the functional-equation sign).

Search: `Q = 2` over `ℚ`, eigenvalues drawn from `{±2, ±1, ±4, 1/2, 8}` (a set closed
under `x ↦ Q²/x`), all permutations of `{1..d}`, `d ≤ 6`.

## 1. Involutive duality: the two sign laws

| `d` | #systems | `∏ α = (−1)^{#neg-fixed} Q^d` holds | `ε = (−1)^{m₊}` holds |
|----|----------|--------------------------------------|------------------------|
| 1 | 2 | 2 | 2 |
| 2 | 12 | 12 | 12 |
| 3 | 56 | 56 | 56 |
| 4 | 400 | 400 | 400 |
| 5 | 2592 | 2592 | 2592 |

No counterexample in 3062 systems.  Both laws are now theorems:
`prod_alpha_eq_sign_mul_pow` and `rootSign_eq_neg_one_pow_centralOrder`.

## 2. Counterexample hunt against the *mission* conjecture

The mission conjecture — "`σ` involutive with **no** fixed point carrying `α = −Q`
implies `∏ α_i = Q^d`, hence `ε = (−1)^d`" — survived the same search with zero
counterexamples, and is proved in `prod_alpha_eq_pow` / `rootSign_eq_neg_one_pow_deg`.

Two boundary phenomena were located:

* **Necessity fails, parity is what matters.**  Systems with an *even* number of `−Q`
  fixed points satisfy the conclusion while violating the hypothesis (smallest case
  `d = 2`, `σ = id`, `α = (−Q, −Q)`, `∏ α = Q²`).  Formalised as
  `prod_alpha_eq_pow_iff_even` and witnessed by `Witnesses.twoNegFixed_deg_two`.
* **Involutivity is indispensable.**  Dropping `σ∘σ = id` breaks the law immediately:

  | `d` | #non-involutive systems | # violating `∏ α = (−1)^{#neg-fixed} Q^d` |
  |----|--------------------------|--------------------------------------------|
  | 2 | 0 | 0 |
  | 3 | 4 | 2 |
  | 4 | 80 | 16 |
  | 5 | 1008 | 264 |
  | 6 | 14816 | 2608 |

  The smallest violation is the 3-cycle `σ = (1 2 3)` with `α ≡ −Q`: it has **no fixed
  point at all**, so the mission hypothesis is vacuously true, yet `∏ α = −Q³`.  This
  is formalised as `Witnesses.three_cycle_no_fixed_point_sign_flip`.

## 3. The `d = 1` sign flip highlighted in the mission statement

| system (`d = 1`) | `∏ α` | `#neg-fixed` | `m₊` | `ε` |
|------------------|-------|--------------|------|-----|
| `σ = id`, `α = +Q` | `Q` | 0 | 1 | `−1` |
| `σ = id`, `α = −Q` | `−Q` | 1 | 0 | `+1` |

So the `+Q` fixed point is exactly what produces `ε = (−1)^1 = −1`, and a `−Q` fixed
point flips it to `+1` — confirmed in Lean by `Witnesses.posFixed_deg_one` and
`Witnesses.negFixed_deg_one`.

## 4. OEIS

The system counts `2, 12, 56, 400, 2592` are artefacts of the finite candidate set used
in the search (they change with the candidate list), so they are not a canonical
sequence and no OEIS identification is claimed.

## 5. What the evidence did *not* settle

The evidence is finite-degree and rational; the Lean development proves all the laws
over an arbitrary field, adds the characteristic-2 caveat (`−1 ≠ 1`) that no rational
search can see, and supplies the analytic bridge (`AnalyticBridge.lean`) that no finite
computation could test.
