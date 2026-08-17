# Computational Evidence

All numbers below were produced by evaluating Lean 4 expressions (`#eval`) inside this
project's toolchain, using brute-force enumeration over finite groups and finite sets. They
informed — and are consistent with — the theorems proved in
`Catalog/Bridges/MoonshineMomentLaurentBridge.lean`. The theorems themselves are proved in
full generality; the data here is orientation, not the argument.

## 1. Moment hierarchy of fixed-point ("trace") series

For a finite group `G` acting on a finite set `X`, define

```
a_g := #{ x ∈ X : g • x = x },      r_k := (1/|G|) Σ_{g ∈ G} a_g^k .
```

The theorem `sum_fixedPoints_pow_eq_orbits_mul_card` says `r_k` is exactly the number of
`G`-orbits on `k`-tuples `X^k`. Computed values:

| action | `(a_g)_{g ∈ G}` | `r_1, r_2, r_3, r_4` |
|---|---|---|
| `S₃` on `3` points | `3, 1, 1, 0, 1, 0` | `1, 2, 5, 14` |
| `S₄` on `4` points | (fixed-point counts of all 24 permutations) | `1, 2, 5, 15` |
| `ℤ/4` on itself (regular) | `4, 0, 0, 0` | `1, 4, 16` |

Observations:

* For `S_n` on `n` points, `r_k` is the number of set partitions of a `k`-set into at most `n`
  blocks. For `k ≤ n` this is the Bell number `B_k` (OEIS **A000110**: `1, 1, 2, 5, 15, 52, …`);
  the `S₄` row reproduces `1, 2, 5, 15` exactly, and the `S₃` row drops from `15` to `14` at
  `k = 4` precisely because partitions into `4` blocks are unavailable with only `3` points.
* For the regular action of a group of order `m`, the data `1, m, m²` matches the general
  theorem `card_orbits_pi_regular`: `r_{k+1} = m^k`, proved in the file.

## 2. Superadditivity `r_1^k ≤ r_k` (counterexample hunt)

The proved inequality is `orbits_pow_le_orbits_pi`. Testing the boundary case
`r_1² ≤ r_2`:

| action | `r_1²` | `r_2` | strict? |
|---|---|---|---|
| `S₃` on `3` points | `1` | `2` | yes |
| `S₄` on `4` points | `1` | `2` | yes |
| `ℤ/4` regular | `1` | `4` | yes |
| trivial action of any `G` on `X` | `|X|²` | `|X|²` | no (equality) |

No counterexample to the inequality was found. Every equality case observed was a trivial
action, which is exactly the content of the proved rigidity theorem
`orbits_sq_eq_orbitals_iff_trivial`.

## 3. Pole orders of products of normalized series

McKay–Thompson series are normalized as `q⁻¹ + O(q)`, i.e. order `-1` at the cusp. Direct
computation with Hahn/Laurent series over `ℤ`:

| number of factors | order of the product |
|---|---|
| `1` | `-1` |
| `2` | `-2` |
| `194` | `-194` |

This linear growth is proved in general (`orderTop_prod_normalized`), with the Monster-sized
case isolated as `orderTop_prod_194` / `orderTop_prod_traceLaurent_194`. It confirms that a
product over the 194 Monster conjugacy classes is meromorphic with a pole of order 194 at the
cusp, hence not a holomorphic modular form.

## 4. Information loss of the product aggregate

With two factors, `(q⁻¹) · (2q⁻¹)` and `(2q⁻¹) · (q⁻¹)` are equal while the ordered families
differ, giving the smallest possible counterexample to injectivity of the unlabeled product;
formalized as `prod_aggregate_not_injective`. By contrast the interleaved aggregate separates
the same two families, since its coefficient at index `2n + i` is the `n`-th coefficient of the
`i`-th member (`interleave_coeff`, `interleave_injective`).

---

# Cycle 2 evidence: Bell numbers and `k`-transitivity

All numbers below were again produced by `#eval` in Lean over brute-force enumerations. They
supported the conjecture that is now the proved main theorem of
`Catalog/Bridges/MoonshineBellTransitivityBridge.lean`.

## 5. Bell numbers as counts of patterns

`bell k` is defined in the Lean file as the number of *patterns* (restricted growth functions)
`p : Fin k → Fin k`, i.e. maps with `p i ≤ i` and `p ∘ p = p`. Enumerating them:

| `k` | `0` | `1` | `2` | `3` | `4` | `5` |
|---|---|---|---|---|---|---|
| `bell k` | `1` | `1` | `2` | `5` | `15` | `52` |

This is OEIS **A000110** (Bell numbers). The values for `k ≤ 5` are not merely evaluated but
*proved* inside the Lean file by `decide` (`bell_zero` … `bell_five`).

## 6. Moments `Σ_g |X^g|^k` against the Bell bound `B_k·|G|`

| action | `|G|` | `k=1` | `k=2` | `k=3` | `k=4` | Bell bound `B_k·|G|` |
|---|---|---|---|---|---|---|
| `S₃` on `3` points | `6` | `6` | `12` | `30` | — | `6, 12, 30` — **attained** |
| `S₄` on `4` points | `24` | `24` | `48` | `120` | `360` | `24, 48, 120, 360` — **attained** |
| `A₄` on `4` points | `12` | `12` | `24` | `72` | — | `12, 24, 60` — attained for `k ≤ 2` only |
| `ℤ/4` regular on `4` points | `4` | `4` | `16` | `64` | — | `4, 8, 20` — attained for `k = 1` only |

Reading of the table, all of it consistent with the proved criterion
`sum_fixedPoints_pow_eq_bell_mul_card_iff`:

* `S₃`, `S₄`: `k`-transitive for all `k ≤ n`, and every moment sits exactly on the bound.
* `A₄`: 2-transitive but not 3-transitive; the moments sit on the bound at `k = 1, 2` and jump
  strictly above it (`72 > 60`) at `k = 3`.
* `ℤ/4` acting regularly: transitive but not 2-transitive; on the bound at `k = 1` and strictly
  above (`16 > 8`) from `k = 2` on.

## 7. Counterexample hunt against the lower bound

No action in the sample violates `B_k·|G| ≤ Σ_g |X^g|^k` for `k ≤ |X|`, as required by
`bell_mul_card_le_sum_fixedPoints_pow`; and in every sampled case where a moment met the bound,
all lower moments did too, matching the proved monotonicity
(`sum_fixedPoints_pow_eq_bell_of_succ`).

The hypothesis `k ≤ |X|` in the theorems is not decorative. For `S₃` on `3` points at `k = 4`
the moment is `3⁴ + 3·1⁴ = 84`, while `B₄·|G| = 15·6 = 90`; so beyond `k = |X|` the Bell bound
fails, as it must — there are no injective `4`-tuples in a `3`-element set, orbits on `4`-tuples
can only realize partitions with at most `3` blocks, and `14 < 15` of the `4`-set partitions
occur.

---

# Cycle 3 evidence — moments vs. distributions (Conjecture A)

## 8. Exhaustive counterexample hunt for power-sum inversion

All functions `f : Fin n → {0,…,N}` were enumerated in Lean (`#eval`) and every ordered pair
`(a, b)` was tested for: *equal power sums `Σ f i ^ k` for all `k ≤ K`, but different value
multisets*.

| `n` | `N` | `K` | # pairs with equal moments but different distribution |
|---|---|---|---|
| `3` | `2` | `2` | `0` |
| `3` | `2` | `1` | `48` |
| `4` | `3` | `3` | `0` |
| `4` | `3` | `2` | `32` |
| `2` | `2` | `1` | `> 0`, e.g. `(0,2)` vs `(1,1)` |

The `K = N` rows are empty, exactly as `count_eq_of_powerSums` predicts; the `K = N - 1` rows are
non-empty, confirming that the range `k ≤ N` in the theorem is sharp. Smallest witnesses found:

* `n = 3, N = 2`: `(0,0,2)` vs `(0,1,1)` — sums `2 = 2`, but distributions `{0,0,2} ≠ {0,1,1}`.
* `n = 4, N = 3`: `(0,2,2,2)` vs `(1,1,1,3)` — sums `6 = 6` and squares `12 = 12`, but
  cubes `24 ≠ 30`, so they are separated exactly at `k = 3 = N`.
* `n = 2, N = 2`: `(0,2)` vs `(1,1)` — the two-point witness that is proved in Lean as
  `powerSums_not_determined_of_lt`.

## 9. Two actions with the same trace distribution

For the Klein four-group `K = Perm(Fin 2) × Perm(Fin 2)` acting on two points through the first
factor (`FstPoint`) and through the second factor (`SndPoint`):

| `g = (σ, τ)` | `(1,1)` | `(1,s)` | `(s,1)` | `(s,s)` |
|---|---|---|---|---|
| `|FstPoint^g|` | `2` | `2` | `0` | `0` |
| `|SndPoint^g|` | `2` | `0` | `2` | `0` |

Both trace distributions are the multiset `{2, 2, 0, 0}`, so all moments — and hence all orbit
counts on `k`-tuples — agree; yet the two actions have different kernels and are not
equivariantly isomorphic. This is the content of `traceDistribution_not_complete_invariant`:
moment data determines the distribution completely, but not the action.

## 10. Fibre spectrum of the orbit–pattern map (`k = 3`, four points)

Orbits of `3`-tuples were enumerated in Lean (`#eval`) for `S₄` and `A₄` acting on `4` points, and
each orbit was labelled by the kernel pattern of a representative.

| action | # orbits on triples | pattern multiplicities `(m_P)` | `B₃` | defect `Σ_P (m_P − 1)` |
|---|---|---|---|---|
| `S₄` | `5` | `1` for each of the `5` patterns | `5` | `0` |
| `A₄` | `6` | `1` for the four non-injective patterns, `2` for the injective pattern | `5` | `1` |

Both rows match the proved formula `Σ_g |X^g|³ = (B₃ + Σ_P (m_P − 1))·|G|`:

* `S₄`: `(5 + 0)·24 = 120 = Σ_g |X^g|³` (see §6), and every fibre is a singleton, i.e. `S₄` is
  3-transitive.
* `A₄`: `(5 + 1)·12 = 72 = Σ_g |X^g|³` (see §6). The single excess sits on the injective pattern:
  the `24` injective triples split into two `A₄`-orbits of size `12`, which is precisely the
  failure of 3-transitivity.
