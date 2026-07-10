# Computational Evidence — Spectral Theory of Abelian Cayley Graphs

The formal file `QuantumWalkCayley.lean` proves that the characters of a finite
abelian group diagonalize the Cayley-graph walk operator, and computes the second
eigenvalue of the cycle `Cay(ℤ/nℤ, {±1})`.  Below is the numerical/small-case
evidence that guided the formalization.

## 1. Eigenvalues of the cycle `Cay(ℤ/nℤ, {±1})`

For the walk operator `A f(x) = f(x+1) + f(x-1)` the characters
`χ_k(x) = exp(2πi k x / n)` are eigenvectors with eigenvalue

    λ_k = χ_k(1) + χ_k(-1) = 2 cos(2π k / n),   k = 0,…,n-1.

| n | eigenvalues `2cos(2πk/n)` (k=0..n-1)                 | top λ₀ | second λ₁ = 2cos(2π/n) | gap 2−λ₁ |
|---|-----------------------------------------------------|--------|------------------------|----------|
| 3 | 2, −1, −1                                            | 2      | −1.000                 | 3.000    |
| 4 | 2, 0, −2, 0                                          | 2      | 0.000                  | 2.000    |
| 5 | 2, 0.618, −1.618, −1.618, 0.618                      | 2      | 0.618                  | 1.382    |
| 6 | 2, 1, −1, −2, −1, 1                                  | 2      | 1.000                  | 1.000    |
| 8 | 2, 1.414, 0, −1.414, −2, −1.414, 0, 1.414           | 2      | 1.414                  | 0.586    |

Observations matching the proved theorems:

* `λ₀ = 2 = |S|` always (trivial character = degree eigenvalue,
  cf. `charEigenvalue_trivial`).
* every `|λ_k| ≤ 2 = |S|` (Perron bound, cf. `charEigenvalue_norm_le`).
* all `λ_k` are real because `{±1}` is symmetric (cf. `charEigenvalue_real_of_symmetric`).
* the spectral gap `2 − 2cos(2π/n)` is strictly positive for `n ≥ 3` and
  behaves like `(2π/n)²` as `n → ∞` (cf. `cycle_spectral_gap_pos`); this is the
  classical `Θ(1/n²)` gap of the cycle.

## 2. Periodicity of the single-generator walk

`shift 1` on `ℤ/nℤ` satisfies `(shift 1)^n = id` since `addOrderOf (1 : ℤ/nℤ) = n`.
Directly checked for `n = 2,3,4,5`: iterating the shift `n` times returns every
basis vector to itself, as proved in general by `shift_periodic`.

## 3. Counterexample hunt on the general claims

* "Every additive character is an eigenvector of `adjacency S`": tested on
  `ℤ/6ℤ`, `ℤ/4ℤ × ℤ/2ℤ` with several generating sets `S` and every character —
  no counterexample; this is exactly `adjacency_addChar_eigen`, which the proof
  shows holds for *every* finite abelian group and *every* generating set.
* "Eigenvalues real ⇔ generating set symmetric": on `ℤ/5ℤ` with the asymmetric
  set `S = {1}`, the character `χ_1` gives eigenvalue `exp(2πi/5)`, which is
  **not** real — confirming that the symmetry hypothesis in
  `charEigenvalue_real_of_symmetric` is genuinely needed.

## 4. Note on the mission's "quadratic speedup" conjecture

The mission's headline conjecture (`τ_mix = O(√|G| · log|G|)`, universal quadratic
speedup) is *false as stated* for the operator `U = Σ_{g∈S}|g⟩⟨0|`, which is not
unitary (it has rank 1), so no honest "mixing time" statement can be attached to
it.  The mathematically sound and provable content in this area is the spectral
diagonalization by characters and the resulting exact eigenvalues / spectral gap,
which is what the Lean file establishes.
