# Computational Evidence — Arithmetic Mirror Symmetry for Calabi–Yau

This note records the small-case checks that preceded the Lean formalization in
`HodgeMirror.lean`, `SYZDuality.lean`, and `ZetaModularity.lean`. All claims below
are subsequently proved (0 sorries) in those files; the tables are evidence, not proof.

## 1. Hodge mirror involution and the Euler-number flip

A Calabi–Yau threefold is encoded by `(h¹¹, h²¹)` with `χ = 2·(h¹¹ − h²¹)`. The mirror
swaps the pair. Sample diamonds (mirror pairs from the Kreuzer–Skarke landscape shape):

| X = (h¹¹, h²¹) | χ(X) | mirror Y = (h²¹, h¹¹) | χ(Y) |
|----------------|------|-----------------------|------|
| (1, 101)       | −200 | (101, 1)              | +200 |
| (2, 86)        | −168 | (86, 2)               | +168 |
| (11, 11)       | 0    | (11, 11)              | 0    |
| (251, 251)     | 0    | (251, 251)            | 0    |

Observations confirmed numerically and then proved:
* `χ(Y) = −χ(X)` always (`euler_mirror`).
* `Y = X ⇔ χ(X) = 0 ⇔ h¹¹ = h²¹` (`selfMirror_iff_euler_zero`).
* **Histogram symmetry.** Over the bounded box `0 ≤ h¹¹, h²¹ ≤ B`, counting diamonds with
  a fixed Euler number `e` gives a histogram symmetric under `e ↦ −e`
  (`countEuler_neg`). For `B = 3`, the multiset of Euler numbers
  `{2·(a−b) : 0 ≤ a,b ≤ 3}` is `{−6,−4,−4,−2,−2,−2,0,0,0,0,2,2,2,4,4,6}`, visibly
  symmetric about `0`.

## 2. SYZ torus fiber `T^n` (T-duality)

Betti numbers `b_k(T^n) = C(n,k)`:

| n | (b_0,…,b_n)        | Σ b_k | χ = Σ(−1)^k b_k | even sum | odd sum |
|---|--------------------|-------|------------------|----------|---------|
| 1 | (1,1)              | 2     | 0                | 1        | 1       |
| 2 | (1,2,1)            | 4     | 0                | 2        | 2       |
| 3 | (1,3,3,1)          | 8     | 0                | 4        | 4       |
| 4 | (1,4,6,4,1)        | 16    | 0                | 8        | 8       |

Observations confirmed and proved:
* Palindromy `b_k = b_{n−k}` (`bettiTorus_poincare`, Poincaré / T-duality).
* `Σ b_k = 2ⁿ` (`bettiTorus_total`).
* `χ(T^n) = 0` for `n ≥ 1` (`eulerTorus_eq_zero`) — so `T^n` is a valid CY fiber.
* even-degree sum = odd-degree sum (`evenBetti_eq_oddBetti`), each equal to `2^{n−1}`.

## 3. Calabi–Yau zeta function (elliptic / CY 1-fold)

Local zeta `Z(T) = (1 − aT + pT²)/((1−T)(1−pT))`. Frobenius eigenvalues `α,β` satisfy
`α+β = a`, `αβ = p`. Example: `p = 5`, curve with `a = 1` (e.g. a count `#E(𝔽₅)=5`).

* Numerator `P(T) = 1 − T + 5T²`; reciprocal roots are `α,β = (1 ± √−19)/2`,
  `|α| = |β| = √5 ≈ 2.236` — the Weil bound `a² = 1 ≤ 20 = 4p` holds.
* `P(1) = 1 − 1 + 5 = 5 = #E(𝔽₅)` (`eulerFactor_at_one`).
* Functional equation: `5·T²·P(1/(5T)) = 5T² − T + 1 = P(T)` (`eulerFactor_funeq`), and
  `Z(1/(5T)) = Z(T)` (`localZeta_funeq`), checked at e.g. `T = 2`:
  `Z(1/10) = Z(2)` numerically.
* The reflection `T ↦ 1/(pT)` sends reciprocal root `1/α ↦ 1/β` (`funeq_permutes_recip_roots`),
  since `p/α = β`.

## OEIS / LMFDB connections

* The torus Betti vectors are rows of **Pascal's triangle** (OEIS A007318); row sums
  `2ⁿ` (A000079) and vanishing alternating sums for `n ≥ 1` (A000007 shifted).
* The Weil/Deligne bound `|a_p| ≤ 2√p` for weight-2 newforms is the Ramanujan–Petersson
  bound; coefficient data for such newforms is catalogued in **LMFDB** (modular forms).

No counterexamples were found in any sampled range; every sampled instance became a
theorem in the accompanying Lean files.
