# Computational Evidence — Berggren Groupoid and Braiding

All numerical claims below were used to *guide* the formalization. Statements marked
**[Lean]** are proved sorry-free in `Catalog/Shared/BerggrenTQC/`; statements marked
**[scratch]** come from ad-hoc exploratory computation and are *not* machine-verified.

## 1. The Euclid-parameter lift of the Berggren generators

Berggren's three tree moves on Pythagorean triples lift to `GL(2,ℤ)` acting on the
Euclid parameters `(m,n)` with `(a,b,c) = (m²−n², 2mn, m²+n²)`:

| generator | matrix | det |
|---|---|---|
| `U₁` | `!![2,-1; 1,0]` | `+1` |
| `U₂` | `!![2, 1; 1,0]` | `−1` |
| `U₃` | `!![1, 2; 0,1]` | `+1` |

Small-case check, starting from `(m,n) = (2,1)`, i.e. the triple `(3,4,5)`:

| step | new `(m,n)` | new triple |
|---|---|---|
| `U₁` | `(3,2)` | `(5,12,13)` |
| `U₂` | `(5,2)` | `(21,20,29)` |
| `U₃` | `(4,1)` | `(15,8,17)` |

**[Lean]** `euclid_U₁`, `euclid_U₂`, `euclid_U₃`, `euclid_step` (in `EuclidLift.lean`)
prove the lift is exact for all `(m,n)`, and `aSpine_examples` (in `DepthBounds.lean`)
verifies the concrete hypotenuses.

## 2. Counterexample hunt for the braid relation

The moonshot needs a pair `X ≠ Y` of Berggren elements with `XYX = YXY`.

* All three generator pairs fail:
  `U₁U₂U₁ ≠ U₂U₁U₂`, `U₁U₃U₁ ≠ U₃U₁U₃`, `U₂U₃U₂ ≠ U₃U₂U₃`. **[Lean]**
  (`braid_fails_lift_12/13/23`, and the same for the catalog `3×3` matrices
  `B₁_mat, B₂_mat, B₃_mat`).
* All three generators have trace `2`. **[Lean]** `berggren_traces`. Hence the classical
  `SL₂` trace test is *inconclusive* here — one needs an actual obstruction, which is why
  the mod-2 argument was developed.
* **[scratch]** An exhaustive search over all words of length `≤ 3` in
  `U₁^{±1}, U₂^{±1}, U₃^{±1}` (216 ordered pairs of such words tested) found **zero**
  pairs `X ≠ Y` satisfying `XYX = YXY`. This motivated, but does not replace, the
  general theorem.
* The general obstruction actually proved **[Lean]**: reduction mod 2 sends every Berggren
  element to `1` or `J = !![0,1;1,0]` (`berggren_mod_two`), hence the standard braiding pair
  `T = !![1,1;0,1]`, `L = !![1,0;−1,1]` of `SL(2,ℤ)` is *not* in the group
  (`braid_generators_not_berggren`), and the mod-2 charge is invariant under braiding
  (`braid_pair_charge_eq`).

## 3. Growth data (silver ratio / Pell)

`B`-spine hypotenuses (repeated `U₂`, i.e. `W = U₂² = !![5,2;2,1]`, eigenvalue `3+2√2`):

```
5, 29, 169, 985, 5741, ...      c_{n+1} = 6 c_n − c_{n−1}
```

`A`-spine hypotenuses (repeated `U₁`, Euclid parameters `(d+2, d+1)`):

```
5, 13, 25, 41, 61, ...          c_d = (d+2)² + (d+1)²
```

**[Lean]** `bSpine_recurrence`, `bSpine_hyp` (the `B`-spine hypotenuse equals the catalog's
`bHyp`), `bHyp_lower : 5^(n+1) ≤ bHyp n`, `bHyp_upper : bHyp n ≤ 5·6^n`,
`aSpine_param`, `aSpine_hyp`.

The two spines realize the two extremes of the proven two-sided depth bound
`(d+2)² < c ≤ 5·9^d` at depth `d` (**[Lean]** `depth_bounds`): polynomial depth growth
along the `A`-spine, exponential along the `B`-spine.

## 4. Density test

`3+2√2 ≈ 5.828…` is a real hyperbolic eigenvalue, not a root of unity, so no power of `W`
is orthogonal: **[Lean]** `W_pow_entry_lower : 5^n ≤ (Wⁿ)₀₀` and `W_pow_not_orthogonal`.
The integral orthogonal `2×2` matrices are exactly the `8` signed permutations
(**[Lean]** `intOrthogonal_iff`, `signedPerms_card = 8`), a finite set — so the integral
Berggren action can never approximate a generic unitary. Concretely, the phase gate
`S = diag(i,1)` is unitary but non-integral, and integral matrices are closed, so
`S ∉ closure(Berggren image)` (**[Lean]** `berggrenRep_not_dense`).

For the `√2`-flavoured *Ising* braid pair built from the same spectral field
(`A = diag(e^{iπ/4}, e^{−iπ/4})`, `B = (1 + iX)/√2`, **[Lean]** `ising_braid`), the image
lies in the Clifford set, which is closed and misses `T = diag(1, e^{iπ/4})`
(**[Lean]** `isingMonoid_le_cliff`, `isClosed_cliff`, `tgate_not_cliff`, `ising_not_dense`).

## 5. OEIS

* `5, 29, 169, 985, 5741, …` — the `B`-spine hypotenuses satisfy `a(n+1) = 6a(n) − a(n−1)`
  (NSW/Pell-related family). **[scratch]** identification by recurrence only; no OEIS lookup
  was performed from this environment, so no ID is asserted.
* `5, 13, 25, 41, 61, …` — centred square numbers `(d+2)² + (d+1)²`. **[Lean]** `aSpine_hyp`.

## Summary

Every computational probe pointed the same way: the Berggren generators do **not** braid,
their growth is Pell/silver-ratio governed, and their image is too rigid (integral, mod-2
graded) to be dense in a unitary group. The formal files turn each of these probes into a
theorem.
