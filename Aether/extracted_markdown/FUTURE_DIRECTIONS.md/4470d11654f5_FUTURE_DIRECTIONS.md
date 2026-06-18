# Future Directions: Paley, Conference Matrices, and the Hadamard Frontier

This cycle formalized the **Paley construction** in `Algebra/Hadamard/Paley.lean`,
building on the catalog foundations in `Algebra/Hadamard/Basic.lean`
(`IsHadamard`, `HadamardOrder`, `four_dvd_of_hadamardOrder`). The completed,
sorry-free results are:

* `jacobsthal_sum` — the character-sum identity `∑ₓ χ(x)·χ(x+a) = -1` for `a ≠ 0`,
  the analytic heart of quadratic-residue constructions.
* `paleyConf_mul_transpose` — the Jacobsthal/conference matrix `C a b = χ(b-a)`
  satisfies `C·Cᵀ = q·I − J`.
* `paleyConf_transpose_eq_neg` — `C` is skew-symmetric exactly when `−1` is a
  non-residue.
* `paley_hadamardOrder` / `paley_hadamardOrder_of_mod_four` — the bordered
  matrix `M + I` is Hadamard, so every finite field with `|F| ≡ 3 (mod 4)`
  yields a Hadamard matrix of order `|F| + 1`. (`ZMod 3 → order 4`, `ZMod 7 →
  order 8` are checked as examples.)

The following directions extend this frontier. Each is testable: it can be stated
as a precise Lean theorem and either proved or refuted.

## 1. Paley Type II: the symmetric conference construction for `q ≡ 1 (mod 4)`

When `|F| = q ≡ 1 (mod 4)`, the quadratic character satisfies `χ(−1) = +1`, so the
conference matrix `C` from `paleyConf_mul_transpose` is *symmetric* rather than
skew. The bordered symmetric conference matrix `S` of order `q+1` then admits the
doubling `[[S+I, S−I],[S−I, −S−I]]`, a Hadamard matrix of order `2(q+1)`.

The key insight is that the same identity `C·Cᵀ = q·I − J` already proven here
serves *both* parities of `q`; only the sign of `χ(−1)` (governed by
`quadraticChar_neg_one` and `ZMod.χ₄`) decides whether we border into a skew
(Type I) or symmetric (Type II) conference matrix, and the symmetric case needs a
`2×2` block doubling instead of the `+I` shift.

Why now? `paleyConf_mul_transpose` is *parity-agnostic* — it holds for all odd `q`.
The remaining work is purely the block-matrix bookkeeping over `Option F × Bool`,
exactly the `Fintype.sum_option`/`Fintype.sum_bool` style already used in
`paleyBorder_mul_transpose`. This would push the proven Hadamard orders from
`{q+1 : q ≡ 3}` to also include `{2(q+1) : q ≡ 1}`, e.g. order `12` from `q = 5`.

## 2. Closure of `HadamardOrder` under the Sylvester (Kronecker) product

`HadamardOrder` should be closed under multiplication: if orders `m` and `n` are
Hadamard, so is `m·n`, via the Kronecker product `H ⊗ K`. Combined with this
cycle's Paley family and the base case `HadamardOrder 2`, this yields Hadamard
matrices of every order `2^k·(q+1)` with `q ≡ 3 (mod 4)` prime power.

The key insight is that `(H ⊗ K)·(H ⊗ K)ᵀ = (H·Hᵀ) ⊗ (K·Kᵀ) = (m·I) ⊗ (n·I) =
(m·n)·I`, so orthogonality is *multiplicative* under `Matrix.kroneckerMap`, and the
`±1` entry condition is preserved because `(±1)·(±1) = ±1`.

Why now? `hadamardOrder_of_fintype` already transports a Hadamard matrix over any
fintype index (here `ι × κ`) back to `Fin (m·n)`, removing the only awkward step.
Mathlib's `Matrix.kroneckerMap` and `Matrix.mul_kronecker_mul` supply the algebra
directly. This turns the Paley single orders into an entire multiplicative monoid
of proven orders.

## 3. The maximal-determinant (Hadamard bound) characterization

For any integer (indeed real) matrix `M` of order `n` with `|Mᵢⱼ| ≤ 1`, one has
`(det M)² ≤ nⁿ`, with equality **iff** `M·Mᵀ = n·I`, i.e. `M` is Hadamard. The
catalog already has `det(H)² = nⁿ` for Hadamard `H`; the open half is the converse.

The key insight is Hadamard's inequality applied to the Gram matrix `G = M·Mᵀ`:
`det G = ∏ λᵢ ≤ (tr G / n)ⁿ` by AM–GM on the (nonnegative) eigenvalues, and
`tr G ≤ n²` since each row has squared norm `≤ n`; equality in AM–GM forces all
`λᵢ` equal, and equality in the trace bound forces `|Mᵢⱼ| = 1`, together giving
`G = n·I`.

Why now? The forward computation `det(H)² = nⁿ` is in `Spectral.lean`, and Mathlib's
`Matrix.IsHermitian` spectral theory plus `inner_mul_le_norm_mul_norm` give the
eigenvalue/AM–GM machinery. This would complete `IsHadamard ↔ maximal determinant`,
turning a definition into a characterization.

## 4. Tightening the necessary condition: `8 ∣ n` is **false**, but `n = q+1` realizes `4 ∣ n`

The catalog proves `four_dvd_of_hadamardOrder` (`4 ∣ n` for `n > 2`). A natural
"stress test" is the *falsifiable* conjecture that `8 ∣ n` is necessary — it is
**not**: the Paley matrix of order `q+1` with `q ≡ 3 (mod 8)` has order
`n = q+1 ≡ 4 (mod 8)`. The smallest instance is `q = 11`, giving the Hadamard
order `n = 12` with `8 ∤ 12`.

The key insight is that the Paley construction *certifies sharpness* of
`four_dvd_of_hadamardOrder`: it exhibits explicit Hadamard orders `≡ 4 (mod 8)`,
so no stronger fixed divisibility law can hold. Formalizing "`12` is a Hadamard
order but `8 ∤ 12`" turns the necessary condition from a one-sided bound into a
*tight* one.

Why now? `paley_hadamardOrder_of_mod_four` already delivers order `12` from
`ZMod 11`; pairing it with the trivial `¬ 8 ∣ 12` (by `decide`) immediately refutes
the over-strong conjecture and demonstrates that the catalog's divisibility bound
cannot be improved to any modulus `> 4`.

## 5. The Hadamard ↔ symmetric-BIBD bridge via the conference matrix

A normalized Hadamard matrix of order `4t` encodes a symmetric
`2-(4t−1, 2t−1, t−1)` design. The Paley conference matrix gives the cleanest route:
the `{0,1}`-image `(J + C)/2` of the Paley (skew) conference matrix is, up to the
border, exactly the incidence matrix of a **Paley biplane / Hadamard design**, and
its pair-intersection counts are forced by `paleyConf_mul_transpose`.

The key insight is that `C·Cᵀ = q·I − J` translates *verbatim* into the BIBD
balance equation: substituting `C = 2N − J` (with `N` the `0/1` incidence matrix)
turns the conference identity into `N·Nᵀ = (t)·I + (t−1)·J`, the defining equation
of a symmetric design, so the analytic content is *already proven* — only the
combinatorial repackaging remains.

Why now? `paleyConf_mul_transpose` provides the exact algebraic identity the BIBD
axioms need, and the catalog's `SymmetricBIBD`/`normalized_row_pair_ones`
infrastructure (in `Design.lean`) supplies the target structure. This would yield
the first construction in the catalog producing *infinitely many explicit
symmetric designs* directly from finite-field arithmetic, unifying the Hadamard,
conference-matrix, and design-theory branches.
