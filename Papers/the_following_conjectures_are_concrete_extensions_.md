# Computational Evidence — Arithmetic Mirror Symmetry, cycle 1

All numbers below were computed before formalization and drove the statements that are now
proved (without `sorry`) in `Catalog/Novelty/`.  Where a number appears inside a Lean
theorem it is re-derived there by `norm_num`/`decide`-free arithmetic, so nothing in the
formal development rests on this file.

---

## 1. Conjecture 1 — genus-zero BPS invariants vs. `rank Pic`

Named toric mirror family: the quintic `X₅ ⊂ ℙ⁴` and its Greene–Plesser mirror
`Y = X₅/(ℤ/5)³`.

| datum | value |
|---|---|
| `h^{1,1}(X)`, `h^{2,1}(X)` | `1`, `101` |
| `χ(X) = 2(h^{1,1} − h^{2,1})` | `−200` |
| `rank Pic(Y) = h^{1,1}(Y) = h^{2,1}(X)` | `101` |
| `n⁰₁, …, n⁰₅` (genus-0 BPS) | `2875`, `609250`, `317206375`, `242467530000`, `229305888887625` |

Counterexample hunt: the target is `101`; the smallest available summand is `2875`.
Every one of the `2⁵ = 32` subsets `S ⊆ {1,…,5}` gives either `0` (empty) or `≥ 2875`.
So no `S` realizes `101`.  Formalized (for all `S`, by an order argument rather than by
enumeration) as `quintic_bps_sum_ne_picardRank`.

## 2. Conjecture 3 — mirror point-count congruence

Hodge–Tate model `#X(𝔽_q) = ∑_{k≤n} c_k qᵏ`, mirror `c_k ↦ c_{n−k}`.

| example | `#X(𝔽₅)` | `#Y(𝔽₅)` | `#X − #Y` | `#X + #Y` |
|---|---|---|---|---|
| `ℙ³`, `c = (1,1,1,1)` | `156` | `156` | `0` (`≡0 mod 5`) | `312 ≡ 2 (mod 5)` |
| `c = (1,2,5,1)` | `1 + 10 + 125 + 125 = 261` | `1 + 25 + 50 + 125 = 201` | `60` (`≡0 mod 5`, `≢0 mod 25`) | `462 ≡ 2 (mod 5)` |

Unsigned congruence: holds in every case tested (and is now a theorem).
Signed congruence `#X ≡ (−1)³#Y`: fails in every case tested, because both counts are
`≡ 1 (mod p)` whenever `c₀ = c_n = 1`.  Formalized as `signed_mirror_congruence_fails`.
The second row also shows the modulus `q²` genuinely needs `c₁ = c₂`
(`mirror_pointCount_congruence_sharp`).

## 3. Conjecture 4 — reciprocal middle zeta factor

Test: supersingular elliptic curve `a = 0` over `𝔽₂`, `P(T) = 1 + 2T²`, `n = 1`, `d = 2`,
`nd/2 = 1`.

```
T² P(1/(2T))  = T² + 1/2      → at T = 1: 3/2
ε · 2 · P(T)                  → at T = 1: ±6
2 · T² · P(1/(2T))            → at T = 1: 3 = P(1)   ✓
```

So the displayed exponent is off by a sign: the correct identity carries `q^{nd/2}` on the
**left**.  Formalized: `prompt_exponent_is_refuted` (refutation) and
`middleFactor_functional_equation` (corrected general theorem).

Further check, CY3 shape `P(T) = 1 − aT + q³T²` with `q = 2`, `a = 3`, `T = 1`:
`q³T²P(1/(q³T)) = 8·(1 − 3/8 + 8/64) = 8 − 3 + 1 = 6 = P(1)`. ✓ (`ε = +1`.)

## 4. Conjecture 5 — weight-four modularity of a rigid CY threefold

Newform `f = η(3z)^8` (weight `4`, level `9`, CM by `ℚ(√−3)`), `q`-expansion computed to
`q²⁰⁰`:

```
a₂=0  a₃=0  a₅=0  a₇=20   a₁₁=0  a₁₃=−70  a₁₇=0  a₁₉=56
a₂₃=0 a₂₉=0 a₃₁=308 a₃₇=110 a₄₁=0 a₄₃=−520 a₅₃=0 a₆₁=182 a₆₇=−880
```

* Every prime `p ≡ 2 (mod 3)` in range has `a_p = 0` (tested for all `p < 200`).
  Structural reason found and proved: `4p = L² + 27M²` is insoluble mod `3`
  (`no_cm_representation_of_inert`).
* Split primes match the CM formula `a_p = 3pL − L³` with `4p = L² + 27M²`, `L ≡ 1 (mod 3)`:

  | `p` | `(L, M)` | `3pL − L³` | `a_p` from `η(3z)^8` |
  |---|---|---|---|
  | 7 | `(1, 1)` | `21 − 1 = 20` | `20` |
  | 13 | `(−5, 1)` | `−195 + 125 = −70` | `−70` |
  | 19 | `(7, 1)` | `399 − 343 = 56` | `56` |
  | 31 | `(4, 2)` | `372 − 64 = 308` | `308` |
  | 37 | `(−11, 1)` | `−1221 + 1331 = 110` | `110` |

* Ramanujan bound `a_p² ≤ 4p³` verified for all `p < 200`, and then discovered to be an
  exact identity `4p³ − a_p² = 27M²(L² − p)²` (e.g. `p = 7`: `1372 − 400 = 972 = 27·1·36`).
  Formalized as `cm_weil_identity` and `cm_ramanujan_bound`.

## 5. Conjecture 2 — SYZ monodromy duality

Focus-focus (Lefschetz) loop, `M = [[1,1],[0,1]]`:

```
M⁻¹     = [[1,−1],[0,1]]
(M⁻¹)ᵀ  = [[1,0],[−1,1]] ≠ M
J M J⁻¹ = [[0,−1],[1,0]]·[[1,1],[0,1]]·[[0,1],[−1,0]] = [[1,0],[−1,1]]  ✓
```

so the dual monodromy is *not equal* to the original but *is* conjugate to it by the
symplectic matrix — verified symbolically for a general `SL₂` matrix
`[[a,b],[c,d]]`, `ad − bc = 1`: `(M⁻¹)ᵀ = [[d,−c],[−b,a]] = J M J⁻¹`.
Formalized as `focusFocus_dual_ne`, `focusFocus_dual_conj`, `sl2_dual_conj`.

## Sequence identification

* `2875, 609250, 317206375, 242467530000, 229305888887625` are the classical genus-zero
  Gromov–Witten/BPS numbers of the quintic threefold (Candelas–de la Ossa–Green–Parkes and
  successors).  No OEIS lookup was performed in this run, so no OEIS identifier is claimed.
* `1, 0, 0, −8, 0, 0, 20, 0, 0, 0, 0, 0, −70, …` are the Fourier coefficients of
  `η(3z)^8`, the weight-`4` level-`9` CM newform; they were recomputed here directly from
  the eta product rather than looked up.

---

# Cycle 2 — evidence for the four follow-up conjectures

The numbers below were computed inside Lean (`#eval`) before the corresponding theorems
were stated; each is now backed by a `sorry`-free proof, referenced at the end of its
section.

## 6. Conjecture A — coefficient-level functional equation

Test object: the Calabi–Yau-threefold middle factor with `q = 2`, `n = 3`, reciprocal roots
`α = (2, 4)` (so `α₀α₁ = 8 = q³`).  Then `P(X) = X² − 6X + 8`, `d = 2`, `m = nd/2 = 3`, and
the coefficient vector is `b = (b₀, b₁, b₂) = (8, −6, 1)`.

| `i` | `q^m·b_{d−i}` | `q^{n i}·b_i` | equal? |
|-----|---------------|---------------|--------|
| 0   | `8·1 = 8`     | `1·8 = 8`     | ✓ (ε = +1) |
| 1   | `8·(−6) = −48`| `8·(−6) = −48`| ✓ |
| 2   | `8·8 = 64`    | `64·1 = 64`   | ✓ |

The exponent **as displayed** in Conjecture A (`b_{d−i} = ε q^{m−n i} b_i`, i.e.
`q^{n i} b_{d−i} = ε q^m b_i`) fails at the very first slot: `1·1 = 1` versus
`ε·8·8 = ±64`.  Formalized as `corrected_exponent_holds` and
`prompt_coefficient_exponent_refuted`; the general theorem is
`middlePoly_coeff_palindromy` / `middlePoly_graded_palindromy`.

## 7. Conjecture B — sharpness of the congruence filtration

Family: dimension `n = 2r + 1`, Tate multiplicities `(1, …, 1, 2, 1, …, 1)` with the bump in
slot `r`; the Hodge–Tate mirror moves the bump to slot `r + 1`.  Point-count difference at
`q = 5`:

| `r` | `#X(𝔽₅) − #Y(𝔽₅)` | `q^r(1 − q)` | `5^r ∣ ·` | `5^{r+1} ∣ ·` |
|-----|-------------------|--------------|-----------|----------------|
| 0   | `−4`              | `−4`         | ✓         | ✗ |
| 1   | `−20`             | `−20`        | ✓         | ✗ |
| 2   | `−100`            | `−100`       | ✓         | ✗ |
| 3   | `−500`            | `−500`       | ✓         | ✗ |
| 4   | `−2500`           | `−2500`      | ✓         | ✗ |

The unit factor is always `1 − q`, which is invertible mod `q`.  In even dimension `2r` the
same bump is self-mirror and the difference is identically `0` (`sharp_even_degenerate`).
Formalized as `sharp_pointCount_difference`, `mirror_congruence_sharp_uniform`,
`mirror_congruence_filtration_strict`.

## 8. Conjecture C — non-innerness of T-duality in every rank

Trace data of the stabilized witnesses (`A ⊕ I_k`):

| witness | `det` | `tr M` | `tr M⁻¹` | ranks covered |
|---------|-------|--------|----------|----------------|
| companion of `x³ − 2x² + x − 1` | `+1` | `2 + k` | `1 + k` | `n = 3 + k ≥ 3` |
| `[[2,1],[1,0]]` | `−1` | `2 + k` | `−2 + k` | `n = 2 + k ≥ 2` |

Since conjugation and transposition both preserve the trace, `tr M⁻¹ ≠ tr M` obstructs
innerness.  The rank-two datum was the surprise of this cycle: it shows the positive result
`sl2_dual_conj` needs `det M = 1`, and indeed for `M = [[2,1],[1,0]]` one computes
`J M J⁻¹ = [[0,−1],[−1,2]] = −(M⁻¹)ᵀ`.  Formalized as
`dualMon_not_inner_rank_ge_three`, `dualMon_not_inner_rank_ge_two`,
`sl2_dual_conj_fails_for_det_neg_one`, `dualMon_inner_iff_rank_le_one`.

## 9. Conjecture D — CM representability at split primes

Exhaustive search for `4p = L² + 27M²` over all primes `p < 200`:

* every prime with `p ≡ 1 (mod 3)` has a solution —
  `7 = (1,1)`, `13 = (5,1)`, `19 = (7,1)`, `31 = (4,2)`, `37 = (11,1)`, `43 = (8,2)`,
  `61 = (1,3)`, `67 = (5,3)`, `73 = (7,3)`, `79 = (17,1)`, `97 = (19,1)`, `103 = (13,3)`,
  `109 = (2,4)`, `127 = (20,2)`, `139 = (23,1)`, `151 = (19,3)`, `157 = (14,4)`,
  `163 = (25,1)`, `181 = (7,5)`, `193 = (23,3)`, `199 = (11,5)` (listed as `p = (L, M)`);
* no prime with `p ≡ 2 (mod 3)` has one:
  `2, 5, 11, 17, 23, 29, 41, 47, 53, 59, 71, 83, 89, 101, 107, 113, 131, 137, 149, 167,
  173, 179, 191, 197` all return "none".

This is exactly the dichotomy now proved for all primes at once in `cm_representation_iff`
(existence: `four_mul_prime_eq_sq_add_27_sq`; non-existence: the cycle-1 theorem
`no_cm_representation_of_inert`).  The table also matches the CM trace values
`a_p = 3pL − L³` of `η(3z)^8` recorded in §4.

---

## 10. Cycle 3 — Hodge divisibility of Frobenius coefficients and the reciprocity sign

Middle factors `P(X) = ∏ (X − α_i)` were expanded by convolution (low index first) and the
Hodge bound `q^j ∣ b_i` (`n·i + j = m`) checked against the predicted exponents.

| data | `n` | `d` | `m` | coefficient vector `(b_0, …, b_d)` | predicted `q^j ∣ b_i` | observed |
|---|---|---|---|---|---|---|
| `q = 2`, roots `2, 4` (`α₀α₁ = 2³`) | 3 | 2 | 3 | `(8, −6, 1)` | `2³ ∣ b_0` | `8 = 2³` ✓ |
| `q = 2`, roots `1, 4, 2, 2` (`1·4 = 2·2 = 2²`) | 2 | 4 | 4 | `(16, −36, 28, −9, 1)` | `2⁴ ∣ b_0`, `2² ∣ b_1` | `16 = 2⁴`, `36 = 2²·9` ✓ |
| `q = 1`, roots `1, −1` (self-dual) | 1 | 2 | 1 | `(−1, 0, 1)` | `1 ∣ b_0` | ✓ (vacuous) |

Sign of the functional equation, read off the same vectors via
`q^{2m}·b_{d−i} = ε·q^{m+n i}·b_i` at `i = 0`:

| data | `b_{d/2}` | forced `ε` |
|---|---|---|
| `q = 2`, roots `2, 4` | `b_1 = −6 ≠ 0` | `+1` |
| `q = 2`, roots `1, 4, 2, 2` | `b_2 = 28 ≠ 0` | `+1` |
| `q = 1`, roots `1, −1` | `b_1 = 0` | `−1` |

The third row is the *only* sign flip found in the sample, and it is exactly the case where
the middle coefficient vanishes.  This is the numerical origin of
`middlePoly_sign_eq_one_of_even_degree` and of its formal counterexample
`middlePoly_sign_neg_one_witness`; the divisibility rows are the numerical origin of
`middlePoly_hodge_divisibility`.  Counterexample hunt: no even-degree example with
`b_{d/2} ≠ 0` and `ε = −1` was found, consistent with the theorem now proved.

---

## 11. Cycle 4 — the reciprocity sign, Newton reflection, `D = −4` descent, slope detection

### 11.1 The sign as a normalized determinant

Cycle 3 left the sign `ε` of the graded palindromy as a case distinction.  Reading it off the
identity at `i = 0` (`q^{2m}·b_d = ε·q^m·b_0`, with `b_d = 1` and `b_0 = (−1)^d ∏ α_i`) gives
the closed formula `∏ α_i = ε·(−1)^d·q^m`.  Checked against every datum in §10 and two new
odd-degree data:

| data | `d` | `n` | `m` | `∏ α_i` | `q^m` | `ε = (−1)^d ∏α / q^m` |
|---|---|---|---|---|---|---|
| `q = 2`, roots `2, 4` | 2 | 3 | 3 | `8` | `8` | `+1` |
| `q = 2`, roots `1, 4, 2, 2` | 4 | 2 | 4 | `16` | `16` | `+1` |
| `q = 1`, roots `1, −1` | 2 | 1 | 1 | `−1` | `1` | `−1` |
| `q = 2`, root `−2` (self-dual, `α² = q²`) | 1 | 2 | 1 | `−2` | `2` | `+1` |
| `q = 2`, root `+2` (self-dual, `α² = q²`) | 1 | 2 | 1 | `2` | `2` | `−1` |

The last two rows are the **counterexample hunt for sub-conjecture N2′** ("odd degree forces
`ε = −1`"): both signs occur at `d = 1`, so N2′ is false.  Formalized as
`middlePoly_sign_eq_normalized_det`, `middlePoly_sign_unique`, `middlePoly_sign_iff_det`,
`odd_degree_sign_not_determined`, `N2_prime_refuted`.

### 11.2 Newton-polygon reflection (`v_p(b_{d−i}) + a·m = v_p(b_i) + a·n·i`)

`2`-adic valuations of the coefficient vectors of §10, with `q = p^a`, `p = 2`:

| data | `(b_0, …, b_d)` | `(v₂(b_0), …, v₂(b_d))` | `a·m` | check `v(b_{d−i}) + a·m = v(b_i) + a·n·i` |
|---|---|---|---|---|
| `q = 2`, `n = 3`, `d = 2`, `m = 3` | `(8, −6, 1)` | `(3, 1, 0)` | `3` | `i=0: 0+3=3+0`; `i=1: 1+3=1+3`; `i=2: 3+3=0+6` ✓ |
| `q = 2`, `n = 2`, `d = 4`, `m = 4` | `(16, −36, 28, −9, 1)` | `(4, 2, 2, 0, 0)` | `4` | `i=0: 0+4=4`; `i=1: 0+4=2+2`; `i=2: 2+4=2+4`; `i=3: 2+4=0+6`; `i=4: 4+4=0+8` ✓ |

No violation was found.  The K3 row also exhibits the sharpness criterion: the Hodge bound at
`i = 1` (`v₂(b_1) + 2 = 4`) is attained exactly because the reflected coefficient `b_3 = −9` is
a `2`-adic unit.  Formalized as `middlePoly_newton_reflection`, `middlePoly_newton_extreme`,
`middlePoly_hodge_bound_sharp_iff`, `k3_newton_reflection`.

### 11.3 Thue descent at `D = −4` (sub-conjecture N3)

Search for `p = L² + 4M²` over all primes `p < 100`:

* every prime with `p ≡ 1 (mod 4)` has a solution —
  `5 = (1,1)`, `13 = (3,1)`, `17 = (1,2)`, `29 = (5,1)`, `37 = (1,3)`, `41 = (5,2)`,
  `53 = (7,1)`, `61 = (5,3)`, `73 = (3,4)`, `89 = (5,4)`, `97 = (9,2)` (listed `p = (L, M)`);
* no prime with `p ≡ 3 (mod 4)` has one: `3, 7, 11, 19, 23, 31, 43, 47, 59, 67, 71, 79, 83`
  all return "none"; and `p = 2` has none either, which is why the equivalence is stated for
  odd primes.

Formalized for all primes at once as `prime_eq_sq_add_sq_of_one_mod_four`,
`prime_eq_sq_add_four_sq`, `prime_sq_add_four_sq_iff`.

### 11.4 The Gaussian weight-four trace, and the failure of Conjecture I's displayed shape

With `p = a² + b²` and `a_p = 2a(a² − 3b²)`:

| `p` | `(a, b)` | `a_p` | `4p³ − a_p²` | `4b²(3a² − b²)²` | `|D| M² (L² − p)²` (displayed) |
|---|---|---|---|---|---|
| `5` | `(1, 2)` | `−22` | `500 − 484 = 16` | `4·4·(3−4)² = 16` ✓ | `4·1·(1−5)² = 64` ✗ |
| `13` | `(3, 2)` | `−18` | `8788 − 324 = 8464` | `4·4·(27−4)² = 8464` ✓ | — |
| `13` | `(2, 3)` | `−92` | `8788 − 8464 = 324` | `4·9·(12−9)² = 324` ✓ | — |

The `p = 5` row is the counterexample: the displayed shape gives `64`, the true value is `16`.
The Ramanujan bound is nearly attained there (`|a_p| = 22` against `2p^{3/2} ≈ 22.36`).
Formalized as `gaussian_cm_weil_identity`, `gaussian_cm_ramanujan_bound`,
`gaussian_cm_trace_ne_zero`, `conjecture_I_shape_refuted`.

The *uniform* replacement `4n³ − (s³ − 3ns)² = −(s² − 4n)(s² − n)²` was checked to specialize
correctly in both directions: at `D = −3`, `p = 7`, `L = 1`, `M = 1` (so `4p = 1 + 27`) it gives
`a_p = 20` and `4·343 − 400 = 972 = 27·1·(1 − 7)²` ✓, reproducing cycle 2's identity; at
`D = −4` it reproduces the table above.  Formalized as `cm_trace_identity_symmetric`,
`cm_trace_identity_eisenstein`, `cm_trace_identity_gaussian`.

### 11.5 The exact slope detector (Conjecture H)

Tate multiplicity vectors `c` in dimension `n = 3`, mirror `c_k ↦ c_{3−k}`, difference
`Σ_k (c_k − c_{3−k}) q^k`:

| `c` | first discrepancy `r` | `c_r − c_{n−r}` | difference | `q = 5` value | `v₅` | `a·r` |
|---|---|---|---|---|---|---|
| `(1, 2, 1, 1)` | `1` | `1` | `q − q²` | `−20` | `1` | `1` ✓ |
| `(1, 1, 3, 1)` | `1` | `−2` | `−2q + 2q²` | `40` | `1` | `1` ✓ |
| `(1, 1, 3, 1)` at `p = 2`, `q = 2` | `1` | `−2` (not a unit) | `−2q + 2q²` | `4` | `2` | `1` ✗ |

The third row is the **boundary**: when the first discrepancy is itself divisible by `p` the
detector under-reports, which is exactly why `mirror_slope_padic_exact` carries the hypothesis
`p ∤ (c_r − c_{n−r})`.  Formalized as `mirror_pointCount_diff_factor`,
`mirror_slope_unit_congruence`, `mirror_slope_exact`, `mirror_slope_padic_exact`,
`sharp_family_padic_valuation`.
