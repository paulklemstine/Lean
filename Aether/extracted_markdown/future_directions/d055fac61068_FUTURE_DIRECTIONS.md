# Future Directions — Hilbert 15 / Schubert Calculus Rigorization

This cycle formalized (0 sorries, file `Catalog/Algebra/SchubertCalculus.lean`) the
cohomology ring `H*(Gr(2,n);ℤ) = ℤ[c₁,c₂]/(h_{n-1},h_n)` with Schubert classes as
Schur polynomials, proving Pieri, Giambelli/Jacobi–Trudi, Poincaré duality in
`Gr(2,4)`, the enumerative number `σ₁⁴ = 2·σ_{2,2}` (2 lines meet 4 general lines
in ℙ³), and the degree sequence `2, 5, 14, 42` for `Gr(2,n)`, `n = 4,5,6,7`.

The following conjectures are precise, falsifiable, and Lean-ready.

## C1 — General Catalan degree of `Gr(2,n)` (the main open target)
For every `n ≥ 2`, inside `R_n = ℤ[c₁,c₂]/(h_{n-1}, h_n)`,
```
σ₁^{2(n-2)} = Cₙ₋₂ · c₂^{n-2},   where Cₘ = (2m)! / (m!(m+1)!) is the Catalan number.
```
Equivalently `c₁^{2(n-2)} - Cₙ₋₂·c₂^{n-2} ∈ (h_{n-1}, h_n)`. Verified for `n=4,5,6,7`.
Proof strategy: establish the reduction `c₁²·c₂^{j} ≡ c₂^{j+1}` and a Catalan
recurrence on the witnesses, or route through the SYT count of the `2×(n-2)`
rectangle (`f^{(n-2,n-2)} = Cₙ₋₂`). This is the genuine Hilbert-15 payoff:
a fully verified closed form for an infinite family of intersection numbers.

## C2 — Full Pieri rule in `Gr(2,n)`
For `0 ≤ b ≤ a ≤ n-2` the special multiplication is
```
σ₁ · s_{(a,b)} = s_{(a+1,b)} + s_{(a,b+1)}   (each term kept only if it fits the box).
```
Conjecture: every such identity holds in `R_n`, and the truncation rule (drop a
term iff its first part exceeds `n-2`) is exactly "the term lies in the relation
ideal". A clean inductive proof would give a complete, machine-checked
multiplication table for all two-row Grassmannians.

## C3 — Littlewood–Richardson positivity for `Gr(2,n)`
All structure constants `c^ν_{λμ}` (coefficients of `s_λ · s_μ` in the Schur
basis of `R_n`) are non-negative integers, and for two-row shapes equal the
explicit LR numbers `0` or `1`. Conjecture: in `Gr(2,n)`, `c^ν_{λμ} ∈ {0,1}` and
`σ_λ · σ_μ = Σ_ν σ_ν` over the `ν` obtained by the two-row LR rule. Falsifiable:
exhibit any product whose expansion has a coefficient `≥ 2` or `< 0`.

## C4 — Poincaré duality is perfect in every `Gr(2,n)`
The complement map `(a,b) ↦ (n-2-b, n-2-a)` on partitions in the `2×(n-2)` box
satisfies `σ_λ · σ_{λ^c} = c₂^{n-2}` (the point class) and `σ_λ · σ_μ ≡ 0` for
`μ ≠ λ^c` with `|λ|+|μ| = dim`. Conjecture: this holds for all `n`, i.e. the
intersection pairing `R_n × R_n → ℤ·c₂^{n-2}` is unimodular. Verified for `n=4`.

## C5 — Generalization to `Gr(3,n)` and the three-variable model
Model `H*(Gr(3,n)) = ℤ[c₁,c₂,c₃]/(h_{n-2},h_{n-1},h_n)` with `h_k` the three-
variable complete homogeneous polynomials (recurrence
`h_k = c₁h_{k-1} - c₂h_{k-2} + c₃h_{k-3}`). Conjecture: `deg Gr(3,n)` equals the
number of SYT of the `3×(n-3)` rectangle, e.g. `deg Gr(3,6) = 42`. The first
testable instance is the classical "`Gr(3,6)`: 42 conics / lines" count; a Lean
verification would extend the rigorization beyond the two-row case.
