# Computational Evidence — Escher staircases in polynomial rings over an arbitrary base

This cycle proves the sharp variable-count criterion for the existence of an
*Escher staircase* (an infinite strictly ascending chain of ideals) in a polynomial
ring `MvPolynomial σ R`. The claims below are elementary and were checked by hand and
by small Lean `#eval`/`example` sanity checks before the full proof was written.

## 1. The rung chain, small cases

Fix an embedding `e : ℕ ↪ σ`. The rung is
`V n = ⟨ X (e 0), …, X (e (n-1)) ⟩`.

| `n` | generators of `V n`        | new generator vs `V (n-1)` |
|-----|----------------------------|----------------------------|
| 0   | (none) → `V 0 = ⟨∅⟩ = (0)` | —                          |
| 1   | `X (e 0)`                  | `X (e 0)`                  |
| 2   | `X (e 0), X (e 1)`         | `X (e 1)`                  |
| 3   | `X (e 0), X (e 1), X (e 2)`| `X (e 2)`                  |

Strictness test at each step: `X (e n) ∈ V (n+1)` but `X (e n) ∉ V n`.

## 2. The separating homomorphism (the only non-order-theoretic input)

To certify `X (e n) ∉ V n` we evaluate the specialisation algebra map
`φ_s = aeval (fun i => if i ∈ s then 0 else X i)` with `s = e '' Iio n`.

* Every generator `X (e i)` (`i < n`) satisfies `φ_s (X (e i)) = 0`, so
  `V n ⊆ ker φ_s`.
* But `e n ∉ s` (injectivity of `e`), so `φ_s (X (e n)) = X (e n) ≠ 0`.

Hence `X (e n) ∉ V n`. Over any **nontrivial** ring `R`, `X (e n) ≠ 0`
(`MvPolynomial.X_ne_zero`), so the argument needs only nontriviality of the base — no
field, no integral domain, no Noetherian hypothesis.

## 3. Boundary behaviour (the dichotomy)

* **Finite `σ`, Noetherian base:** Hilbert's basis theorem makes `MvPolynomial σ R`
  Noetherian, so *no* staircase exists.  Checked instance: `MvPolynomial (Fin n) ℤ`
  is Noetherian for every `n`.
* **Infinite `σ`, any nontrivial base:** the chain above is an explicit staircase.
  Sampled index types: `ℕ`, `ℤ`, `ℝ` (uncountable) — all infinite, all give a
  staircase.
* **Non-Noetherian base, any `σ` (even a single variable):** `constantCoeff` is a
  surjection `MvPolynomial σ R ↠ R`; a Noetherian ring has Noetherian quotients, so a
  non-Noetherian `R` forces `MvPolynomial σ R` non-Noetherian. Checked instance:
  `MvPolynomial (Fin 1) (MvPolynomial ℕ ℤ)` has a staircase.

## 4. Counterexample hunt

The universal claim "infinite `σ` + nontrivial `R` ⇒ staircase" was probed for a
possible failure at a *nontrivial but non-reduced / non-domain* base (e.g.
`R = ZMod 4`, `R = ℤ × ℤ`). The separating-homomorphism argument is insensitive to
zero-divisors or nilpotents: it only uses `X (e n) ≠ 0`, which holds for every
nontrivial `R`. No counterexample exists, consistent with the proved theorem.

## 5. No OEIS sequence

The invariant here is a Boolean dichotomy (staircase exists / does not), governed by
`Infinite σ` together with Noetherianity of the base, not an integer sequence, so no
OEIS entry is relevant.
