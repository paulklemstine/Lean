# Computational evidence (Teichmüller / moduli of tori)

All numbers below were produced by `#eval` on `Float` arithmetic inside Lean before the
corresponding statements were formalized.  They are *evidence*, not proof; every claim listed
here is subsequently proved in `Catalog/Geometry/Teichmuller/`.

## 1. Extremal dilatation vs. hyperbolic distance

For marked tori `τ = x₁ + i y₁`, `τ' = x₂ + i y₂`, set

    p = ‖τ' - conj τ‖ ,  q = ‖τ' - τ‖ ,  K = (p+q)² / (4 y₁ y₂) .

Conjecture (later `teichDist_eq_half_dist`): `(K + K⁻¹)/2 = cosh d_ℍ(τ,τ')`.

| (x₁,y₁) | (x₂,y₂) | (K + 1/K)/2 | cosh d_ℍ |
|---|---|---|---|
| (0.3, 1.7) | (−1.1, 0.4) | 3.683824 | 3.683824 |
| (2.0, 0.5) | (0.25, 3.25) | 4.269231 | 4.269231 |

Agreement to all displayed digits; the identity `p² − q² = 4 y₁ y₂` was checked at the same
sample points.  Equivalently `K = exp(d_ℍ)` and `d_T = d_ℍ/2`.

## 2. Displacement of Arnold's cat map `!![2,1;1,1]`

Predicted displacement function (later `cosh_dist_smul`):

    cosh d(z, g z) = (t² − 2)/2 + (c(x²+y²) − (a−d)x − b)² / (2y²),   t = tr g = 3 .

Trace bound: `(9−2)/2 = 3.5`.  Sample values:

| (x, y) | on axis `x²+y²−x−1 = 0`? | cosh d |
|---|---|---|
| (0.5, √5/2 ≈ 1.118034) | yes | 3.500000 |
| (1.0, 1.0) | yes | 3.500000 |
| (0.0, 1.0) | yes | 3.500000 |
| (0.0, 2.0) | no | 4.625000 |

The minimum `3.5` is attained exactly on the circle `x² + y² − x − 1 = 0`, i.e. the axis of the
cat map — matching the "perfect square over `2y²`" shape of the identity.  The resulting
Teichmüller translation length is `arcosh(3.5)/2 = log((3+√5)/2) ≈ 0.962424`, which is the value
proved in `isLeast_teichDist_catMap`.

## 3. Parabolic class `T : τ ↦ τ + 1` (the cusp)

Predicted `cosh d(τ, T τ) = 1 + 1/(2y²)`:

| y | 1 | 10 | 100 |
|---|---|---|---|
| cosh d | 1.500000 | 1.005000 | 1.000050 |

Strictly `> 1` for every `y`, tending to `1`: the displacement is positive everywhere but its
infimum `0` is not attained (`teichDist_T_pos`, `exists_teichDist_T_lt`).  This is the numerical
signature of the cusp of the moduli space of tori.

## 4. Counterexample hunt

* Naive composition bound.  The termwise inequality `‖A‖ − ‖B‖ ≥ (‖a‖−‖b‖)(‖c‖−‖d‖)` for the
  composite of two real-linear maps was tested and *fails* (the triangle inequality loses
  `2‖b‖‖d‖`), which is why `dil_comp_le` is proved through the exact Jacobian identity
  `‖A‖² − ‖B‖² = (‖a‖²−‖b‖²)(‖c‖²−‖d‖²)` instead.
* Integer traces.  Scanning integer traces `|t| > 2`, the smallest stretch factor is at `|t| = 3`,
  giving `λ = (3+√5)/2 ≈ 2.618034` (square of the golden ratio) and translation length
  `≈ 0.962424`; no Anosov class of the torus beats it (`goldenRatio_sq_le_stretch`).
* No sequence from this project appeared to require an OEIS lookup; the only integer datum is
  the trace spectrum `{3, 4, 5, …}` of hyperbolic classes, whose associated stretch factors
  `(t+√(t²−4))/2` are the Lucas-type quadratic units.

## 5. The systolic ratio on the moduli space (second research cycle)

For `τ = x + iy` put `S(τ) = min_{(m,n) ≠ (0,0)} |m + nτ|² / Im τ` (the squared systole divided
by the area of the flat torus `ℂ/(ℤ+τℤ)`).  Minimising over `|m|,|n| ≤ 4` by `#eval`:

| τ | `S(τ)` |
|---|---|
| `i` | 1.000000 |
| `2i` | 0.500000 |
| `i/2` | 0.500000 |
| `1/4 + i` | 1.000000 |
| `1/2 + 0.9i` | 1.111111 |
| `−0.4 + 0.9i` | 1.077778 |
| `ρ = −1/2 + i√3/2` | **1.154701** |

and `2/√3 = 1.154701`.  No sampled point exceeded `2/√3`; the maximum is attained at the
hexagonal torus and the value degenerates to `0` as `Im τ → ∞` (the cusp), matching the
parabolic data of §3.  The two flat values `S(i) = S(1/4+i) = 1` illustrate that the square
torus is *not* the maximiser — a common first guess, and the counterexample that motivated
proving `le_normSq_rho` at `ρ` rather than at `i`.

Formalized as `exists_short_lattice_vector` (the bound `S(τ) ≤ 2/√3` for every `τ`),
`le_normSq_rho` (equality at `ρ`) and `hermite_two_sharp` (no smaller constant works), i.e.
Hermite's constant in dimension two is exactly `2/√3`.

## 6. Order of the stabilizers of the two special tori

Brute-force scan of all `g ∈ SL(2,ℤ)` with entries in `[−3,3]`: the matrices fixing `i` are
exactly `±1, ±S` (four of them, two in `PSL(2,ℤ)`, all squaring to `±1`), while those fixing
`ρ = e^{2πi/3}` are `±1, ±ST, ±(ST)²` (six of them, three in `PSL(2,ℤ)`).  The only matrices
fixing both are `±1`, which fix every point.  This motivated, and is now superseded by, the
proofs of
`sq_eq_one_of_smul_I_eq`, `exists_order_three_stabilizer` and `smul_rho_ne_I`.

## 7. The length spectrum and the systolic functional (third research cycle)

All numbers below come from `#eval` on `Float` arithmetic; each is followed by the theorem that
now proves the corresponding exact statement.

### 7.1 Translation lengths `ℓ(n) = log((n + √(n²−4))/2)` of the trace-`n` Anosov classes

| n | 3 | 4 | 5 | 6 | 7 | 8 | 9 | 10 |
|---|---|---|---|---|---|---|---|---|
| `ℓ(n)` | 0.962424 | 1.316958 | 1.566799 | 1.762747 | 1.924847 | 2.063437 | 2.184644 | 2.292432 |

Successive gaps `ℓ(n+1) − ℓ(n)`:

| n | 3 | 4 | 5 | 6 | 7 | 8 |
|---|---|---|---|---|---|---|
| gap | 0.354534 | 0.249841 | 0.195948 | 0.162100 | 0.138590 | 0.121207 |

The sequence is strictly increasing, unbounded, and its gaps are strictly decreasing (evidence
for conjecture **D3** below, which is *not* yet proved).  Each `n ≥ 3` is realized by the
explicit matrix `!![n, −1; 1, 0]` of determinant `1` and trace `n`.
Formalized: `mem_lengthSpectrum_iff` (the spectrum is exactly `{ℓ(n) : n ∈ ℤ, n ≥ 3}`),
`spectrumValue_strictMonoOn`, `finite_lengthSpectrum_le` (discreteness, with the explicit bound
`|tr g| ≤ 2e^M`), `lengthSpectrum_unbounded`, `isLeast_lengthSpectrum` (minimum `ℓ(3)`).

### 7.2 The systolic functional as a minimum

Minimising `|m + nτ|²/Im τ` over `|m|, |n| ≤ 6`:

| τ | `sys τ` | comment |
|---|---|---|
| `i` | 1.000000 | square torus, `sys_I` |
| `ρ = −1/2 + i√3/2` | 1.154701 | `= 2/√3`, `sys_rho` |
| `5i` | 0.200000 | `= 1/Im τ`, cusp direction |
| `0.3 + 1.7i` | 0.588235 | `= 1/1.7`, the vector `(1,0)` is shortest |

The minimum is always attained by a vector with `|m|, |n| ≤ 2` in these samples — the finiteness
that makes `sys` well defined is now proved in general (`finite_normSq_le`, `sys_isLeast`).
The last two rows illustrate `sys τ ≤ 1/Im τ`, the inequality used to produce the cusp and hence
the infinite diameter of the moduli space (`moduliDist_unbounded`).

### 7.3 Successive minima and the thick–thin decomposition

`#eval` (Float arithmetic in Lean, `|m|, |n| ≤ 6`) of the systole `λ₁ = sys τ`, of the second
minimum `λ₂` (the shortest lattice vector independent of the shortest one), and of their
product:

| τ | `λ₁` | `λ₂` | `λ₁ λ₂` |
|---|---|---|---|
| `ρ = −1/2 + i√3/2` | 1.154701 | 1.154701 | 1.333333 |
| `i` | 1.000000 | 1.000000 | 1.000000 |
| `1.5 i` | 0.666667 | 1.500000 | 1.000000 |
| `3 i` | 0.333333 | 3.000000 | 1.000000 |
| `0.25 + 1.1 i` | 0.909091 | 1.156818 | 1.051653 |
| `−0.5 + 0.9 i` | 1.111111 | 1.177778 | 1.308642 |

The product never leaves `[1, 4/3] = [1, 1.333…]`, it equals `4/3` exactly at the hexagonal
torus and equals `1` exactly on the imaginary axis above `i`.  Both observations are now
theorems: the lower bound is `one_le_latticeValue_mul` (the determinant inequality, valid for
*every* independent pair), the upper bound is `exists_basis_second_le` (Minkowski's second
theorem, proved by reduction to the standard fundamental domain), the two together are
`sys_mul_second_mem_Icc`, and sharpness is `second_minimum_rho` and `second_minimum_cusp`.

Note also the third and fourth rows: as `λ₁ → 0` the second minimum blows up like `1/λ₁`.  This
reciprocal behaviour is the collar lemma `collar_lemma`, and the uniqueness of the shortest
vector on the thin part (`λ₁ < 1`) is `shortest_unique_of_sys_lt_one`; the row `τ = i` shows why
the strict inequality is needed there — the square torus has the four shortest vectors `±1`,
`±i`.

### 7.4 The systole is continuous, and the thick part is compact

Sampling `sys` along the horizontal segment `x + 1.2 i`, `x = 0, 0.1, …, 0.5`, gives
`0.833333, 0.833333, 0.833333, 0.833333, 0.833333, 0.833333`: on the region `Im τ ≥ 1` the
systole is exactly `1/Im τ` (`sys_eq_one_div_im`), hence locally constant there, whereas along
the vertical segment `0.5 + i y` it varies continuously and reaches its maximum `2/√3` at
`y = √3/2`.  Continuity of `sys` — needed to know that the thick part is *closed*, and hence
compact — is now proved in general as `continuous_sys`, via the Lipschitz estimate
`abs_log_sys_sub_le_dist`.
