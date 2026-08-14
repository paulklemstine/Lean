# Computational evidence — PERMORD (permutation readout of individual orders)

All claims below were first checked numerically (exploratory scripts, reported
here as *exploratory*), and the general statements were then **proved in Lean 4**
in `Catalog/Physics/PermutationReadout{Core,Asymmetry,Burnside,Examples,
Zolotarev,Jacobi,Excess,ParityLocalization}.lean`.
Individual numeric instances marked **(Lean)** are additionally certified inside
the kernel by a theorem in `PermutationReadoutExamples.lean`.

## 1. Cycle structure of `x ↦ a·x` on `Z/NZ`

Full enumeration of the permutation (visiting all `N` points) versus the
prediction of the stratification law
`#cycles = ∑_{d ∣ N} φ(N/d) / ord_{N/d}(a)` (theorem
`Physics.PermReadout.cycleCount_eq_sum`).

| N | factorisation | a | ord_N(a) | cycle lengths (multiplicities) | #cycles measured | #cycles predicted |
|---|---|---|---|---|---|---|
| 143 | 11·13 | 2 | 60 | 1×1, 10×1, 12×1, 60×2 | 5 | 5 |
| 221 | 13·17 | 7 | 48 | 1×1, 12×1, 16×1, 48×4 | 7 | 7 |
| 899 | 29·31 | 3 | 420 | 1×1, 28×1, 30×1, 420×2 | 5 | 5 |
| 3127 | 53·59 | 2 | 1508 | 1×1, 52×1, 58×1, 1508×2 | 5 | 5 |
| 65 | 5·13 | 57 | 4 | 1×1, 4×16 | 17 | 17 |
| 65 | 5·13 | 31 | 4 | 1×5, 4×15 | 20 | 20 |
| 15 | 3·5 | 2 | 4 | 1×1, 2×1, 4×3 | 5 | 5 |
| 35 | 5·7 | 3 | 12 | 1×1, 4×1, 6×1, 12×2 | 5 | 5 |
| 1001 | 7·11·13 | 5 | 60 | 1×1, 4×3, 5×2, 6×1, 12×6, 20×6, 30×2, 60×12 | 33 | 33 |

Prediction matched measurement in every case, including the three-prime modulus
`1001`, which is outside the semiprime specialisation and exercises the general
divisor-sum theorem.

**(Lean)** `cycleCount_143 : cycleCount (11*13) 2 = 5`,
`cycleCount_899 : cycleCount (29*31) 3 = 5`,
`readout_separates_65 : … cycleCount (5*13) 57 = 17 ∧ cycleCount (5*13) 31 = 20`.

## 2. Factor recovery from the two nontrivial cycle lengths

For a primitive multiplier the cycle through the ring element `p` has length
`ord_q(a) = q − 1` and vice versa, so `{p, q}` is read off directly.

| N | a | length at p | length at q | recovered pair |
|---|---|---|---|---|
| 143 | 2 | 12 | 10 | {13, 11} |
| 221 | 7 | 16 | 12 | {17, 13} |
| 899 | 3 | 30 | 28 | {31, 29} |
| 3127 | 2 | 58 | 52 | {59, 53} |

**(Lean)** `readout_143`, `readout_221`, `readout_899`, `readout_3127`.

## 3. Counterexample hunt: is the readout strictly finer than `ord_N`?

Searched small semiprimes for two multipliers with equal `ord_N` but different
individual orders. Smallest found: `N = 65`, `a = 57`, `b = 31`:

* `ord_65(57) = ord_65(31) = 4` — a unit-group probe cannot distinguish them;
* `ord_5(57) = 4` but `ord_5(31) = 1` — the stratum of `13` has cycle length `4`
  for `57` and `1` for `31`;
* consequently `#cycles = 17` versus `20`.

So the loophole *is* closed: the permutation readout is strictly richer than the
lcm datum. **(Lean)** `lcm_blind_65`, `readout_separates_65`.

No counterexample to the stratification law itself was found in any of the
`(N, a)` pairs enumerated with `N ≤ 1001` and `gcd(a, N) = 1`.

## 4. Where the extra information comes from: Burnside vs Pollard

Exploratory check of the orbit-counting identity
`ord_N(a) · #cycles = ∑_{k < ord_N(a)} gcd(N, a^k − 1)`:

| N | a | ord·#cycles | ∑ gcd(N, a^k−1) | equal? |
|---|---|---|---|---|
| 143 | 2 | 300 | 300 | ✓ |
| 221 | 7 | 336 | 336 | ✓ |
| 899 | 3 | 2100 | 2100 | ✓ |
| 3127 | 2 | 7540 | 7540 | ✓ |
| 65 | 57 | 68 | 68 (= 65+1+1+1) | ✓ |
| 65 | 31 | 80 | 80 (= 65+5+5+5) | ✓ |
| 15 | 2 | 20 | 20 | ✓ |
| 35 | 3 | 60 | 60 | ✓ |
| 1001 | 5 | 1980 | 1980 | ✓ |

The `65` rows are the decisive ones: the *extra* cycles of `31` are paid for
entirely by nontrivial gcds `gcd(65, 31^k − 1) = 5`, i.e. by successful Pollard
`p − 1` probes.  **(Lean)** `orderOf_mul_cycleCount_eq_sum_gcd`,
`burnside_65_57`, `burnside_65_31`, `pollard_hit_65_31`,
`no_pollard_hit_65_57`, and the general equivalence
`cycleCount_minimal_iff_no_pollard_hit`.

## 5. Cost measurements (barrier 4)

A permutation on `Z/NZ` must be enumerated to be read: the strata partition all
`N` ring elements (`sum_stratum_card`), and the unit stratum alone has `φ(N)`
of them: `N = 3127 → φ = 3016`, `N = 34571 (181·191) → φ = 34200`. Both exceed
`√N` by orders of magnitude, and `√N` is already the cost of trial division.
**(Lean)** `sqrt_lt_totient`, `totient_ge_half`.

The informative points — those outside the unit stratum — number exactly
`p + q − 1` (**(Lean)** `card_informative_semiprime`), a fraction `≤ 2/p` of the
ring (**(Lean)** `informative_density`), and for balanced semiprimes a fraction
`≤ 6/√N` (**(Lean)** `informative_density_sqrt`): random entry is hopeless, and
any informative point *is* a factor (**(Lean)** `factor_of_nontrivial_stratum`).

## 6. The sign of the readout is the Jacobi symbol

Exhaustive check over **all** semiprimes `N = p·q` with `3 ≤ p < q < 60` and
**all** `a` coprime to `N` (80 976 pairs): the parity of `N − #cycles` — the
sign of the permutation `x ↦ a·x` — agreed with the Jacobi symbol `J(a|N)` in
every single case (0 violations).

| N | a | ord_p | ord_q | i_p | i_q | gcd | #cyc(p)·#cyc(q) | excess | #cycles | N−#cyc | J(a\|N) |
|---|---|-------|-------|-----|-----|-----|-----------------|--------|---------|--------|--------|
| 65 | 57 | 4 | 4 | 1 | 3 | 4 | 8 | 9 | 17 | 48 (even) | +1 |
| 65 | 31 | 1 | 4 | 4 | 3 | 1 | 20 | 0 | 20 | 45 (odd) | −1 |
| 143 | 2 | 10 | 12 | 1 | 1 | 2 | 4 | 1 | 5 | 138 (even) | +1 |
| 221 | 7 | 12 | 16 | 1 | 1 | 4 | 4 | 3 | 7 | 214 (even) | +1 |
| 899 | 3 | 28 | 30 | 1 | 1 | 2 | 4 | 1 | 5 | 894 (even) | +1 |
| 3127 | 2 | 52 | 58 | 1 | 1 | 2 | 4 | 1 | 5 | 3122 (even) | +1 |

The prime-modulus version (Zolotarev's lemma) was checked on the same script:

| p | a | ord_p | index | #cycles | p−#cyc | QR? | Legendre |
|---|---|-------|-------|---------|--------|-----|----------|
| 7 | 2 | 3 | 2 | 3 | 4 | yes | +1 |
| 7 | 3 | 6 | 1 | 2 | 5 | no | −1 |
| 11 | 2 | 10 | 1 | 2 | 9 | no | −1 |
| 11 | 3 | 5 | 2 | 3 | 8 | yes | +1 |
| 13 | 3 | 3 | 4 | 5 | 8 | yes | +1 |
| 13 | 5 | 4 | 3 | 4 | 9 | no | −1 |
| 17 | 2 | 8 | 2 | 3 | 14 | yes | +1 |
| 17 | 3 | 16 | 1 | 2 | 15 | no | −1 |

**(Lean)** `zolotarev_parity` (prime modulus), `jacobi_readout_parity`
(semiprime modulus), `parity_bit_is_free`, and the certified instance
`jacobi_from_readout_65` / `jacobi_direct_65`, where the two Jacobi symbols are
first *predicted* from the kernel-certified cycle counts `17` and `20` and then
*confirmed* by an independent evaluation of `J(·|65)`.

*Exploratory extension (not proved):* the same agreement was observed for **all
odd `N < 600`** and all `a` coprime to `N` (72 936 pairs, 0 violations), i.e.
for arbitrary odd moduli, not only semiprimes.  This is conjecture C1 of
`FUTURE_DIRECTIONS.md`; the key structural step towards it is proved here as
`unit_stratum_even_permutation`.

## 7. The excess formula

For every one of the 80 976 pairs above the identity

`#cycles(pq) = #cycles(p)·#cycles(q) + (gcd(ord_p a, ord_q a) − 1)·i_p·i_q`

held exactly (0 violations).  The `excess` column of the table in §6 shows the
surplus; it vanishes precisely when `gcd(ord_p a, ord_q a) = 1` (row `N = 65,
a = 31`) and is maximal when the two local orders coincide (row `N = 65,
a = 57`).  **(Lean)** `cycleCount_excess`,
`cycleCount_eq_prod_iff_coprime_orders`, `cycleCount_supermultiplicative`,
`excess_pos_of_primitive`, and the certified instances `excess_65_57`,
`excess_65_31_eq_zero`.

## 8. OEIS

The counts produced here are values of the divisor sum
`∑_{d ∣ N} φ(d)/ord_d(a)`, which is determined by `N` and `a` through the
theorems proved in this project; we did not search for or claim an OEIS
identification, and none of the results depend on one.

## 9. The sign law at every modulus (this cycle)

The parity of `N − #cycles` was recomputed by **brute-force orbit enumeration**
of the permutation `x ↦ a·x` (visiting all `N` points, no divisor formula) for
every `1 ≤ N < 200` and every `a` coprime to `N`, and compared with the
prediction

* `N` odd: even permutation ⟺ `J(a | N) = 1`;
* `N ≡ 2 (mod 4)`: always an even permutation;
* `4 ∣ N`: even permutation ⟺ `a ≡ 1 (mod 4)`.

All pairs agreed (0 violations).  Sample of the even-modulus data (parity of
`N − #cycles`, listed for `a` running over the units in increasing order):

| N | parities |
|---|---|
| 6 | 0, 0 |
| 8 | 0, 1, 0, 1 |
| 10 | 0, 0, 0, 0 |
| 12 | 0, 0, 1, 1 |
| 20 | 0, 1, 1, 0, 1, 0, 0, 1 |
| 24 | 0, 0, 1, 1, 0, 0, 1, 1 |

The `4 ∣ N` rows follow `a mod 4` exactly, and the `N ≡ 2 (mod 4)` rows are
identically `0`.

Both halves are now **theorems**, not observations: the odd case is
`Physics.PermReadout.zolotarev_general` (conjecture C1 of the previous cycle,
closed), the even case is `Physics.PermReadout.parity_readout_even`, and the two
are combined in `Physics.PermReadout.permutation_sign_law`
(`Catalog/Physics/PermutationReadoutZolotarevGeneral.lean` and
`Catalog/Physics/PermutationReadoutEvenModulus.lean`).  The enumeration above is
exploratory cross-checking only; the guarantee comes from the Lean proofs.

## 10. The affine family (this cycle)

Exploratory enumeration of the affine permutations `σ_{a,b}(x) = a·x + b` of
`Z/NZ` (direct orbit walk, no formula) for every `1 ≤ N < 120`, every `a`
coprime to `N` and every shift `0 ≤ b < N` — 4354 pairs `(N, a)`, all shifts:

* whenever `gcd(a − 1, N) = 1`, the cycle count is **constant in `b`**
  (0 violations);
* the pure translations satisfy `#cycles(x ↦ x + b) = gcd(N, b)` for every
  `N < 80` and every `b` (0 violations).

Both observations are now theorems, proved in
`Catalog/Physics/PermutationReadoutAffine.lean`:
`cycleCountOf_affine` (`#cycles(σ_{a,b}) = #cycles(σ_{a,0}) = cycleCount N a`
whenever `1 − a` is a unit) and `cycleCountOf_add`
(`#cycles(x ↦ x + b) = gcd(N, b)`).

The invertibility hypothesis is not cosmetic.  For `N = 15`, `a = 4`
(`gcd(a − 1, N) = 3`) the counts do move with the shift:

| b | 0 | 1 | 2 | 3 | 4 | 5 |
|---|---|---|---|---|---|---|
| `#cycles(4x + b)` | 9 | 3 | 3 | 9 | 3 | 3 |

whereas for `N = 15`, `a = 2` (`1 − a = −1`, a unit) the count is `5` for every
`b`, equal to `cycleCount 15 2`.  Note that the moving values `9, 3` are both
odd: the *parity* — the only datum the sign law uses — is still constant, which
is exactly what the remaining half of conjecture C1 asserts.


## The affine sign law, the affine classification and the power readout

All the enumerations in this section are exploratory (brute-force cycle counting
on the concrete permutations); the guarantees come from the Lean proofs named
alongside them.

**Affine sign law.**  For every `N < 60`, every `a` with `gcd(a, N) = 1` and
every shift `0 ≤ b < N`, the parity identity

`(N − #cycles(a·x + b)) ≡ (N − #cycles(a·x)) + (N − #cycles(x + b))  (mod 2)`

holds — 0 violations over the full enumeration.  This is now the theorem
`affine_sign_law` (`Catalog/Physics/PermutationReadoutSign.lean`), proved for
every modulus via the sign bridge `sign σ = (−1)^(card − #orbits σ)` and the
multiplicativity of `Equiv.Perm.sign`.

**Affine classification.**  For every `2 ≤ N < 80`, every `a` coprime to `N` and
every shift `b`, the cycle count `#cycles(a·x + b)` is constant on the classes of
shifts with a fixed value of `gcd(b, gcd(a − 1, N))` — 0 violations.  This is the
theorem `cycleCountOf_affine_of_gcd_eq`
(`Catalog/Physics/PermutationReadoutAffineClass.lean`).  For example at
`N = 15`, `a = 4` (so `g = 3`) the counts are

| b | 0 | 1 | 2 | 3 | 4 | 5 |
|---|---|---|---|---|---|---|
| `#cycles(4x + b)` | 9 | 3 | 3 | 9 | 3 | 3 |
| `gcd(b, 3)` | 3 | 1 | 1 | 3 | 1 | 1 |

— exactly the predicted dependence.

**Power readout at a prime.**  For every prime `p < 100` and every `k < 40` with
`gcd(k, p − 1) = 1`,

`#cycles(x ↦ x^k on Z/pZ) = #cycles(y ↦ k·y on Z/(p−1)Z) + 1`

with 0 violations.  This is the theorem `cycleCountOf_pow_prime`
(`Catalog/Physics/PermutationReadoutPowerMap.lean`).

**Power readout at a composite modulus (open conjecture C1).**  For every odd
squarefree `N < 200` and every `k < 30` such that `x ↦ x^k` permutes `Z/NZ`, the
predicted rule

`N − #cycles(x ↦ x^k)` odd  ⟺  `k ≡ 3 (mod 4)` and `#{p ∣ N : p ≡ 1 (mod 4)}` odd

held in every case (0 violations).  The prime case is proved
(`power_readout_sign_law`); the composite case is conjecture C1 of
`FUTURE_DIRECTIONS.md`.
