# Computational evidence for PLUSONE-SMOOTH-NULL (round-16 #2)

All numbers below were produced by direct enumeration before the Lean
formalisation, and every claim that ended up in a theorem is *also* checked
inside Lean (by `decide` / `norm_num` on the concrete instances, or by a general
proof). Numbers that are **not** re-checked in Lean are marked "exploratory".

## 1. Lucas `V`-sequence, base `P = 3` (`D = 3² − 4 = 5`)

| n | 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 12 |
|---|---|---|---|---|---|---|---|---|---|----|
| V_n(3) | 2 | 3 | 7 | 18 | 47 | 123 | 322 | 843 | 2207 | 103682 |

* `p = 7`: `p + 1 = 8`, `(5 | 7) = −1` (gate closed → method works).
  `V₈ − 2 = 2205 = 3²·5·7²`, and `gcd(2205, 91) = 7`.
  Formalised: `PlusOneSmoothNull.williams_example_seven`,
  `PlusOneSmoothNull.williams_example_gate`.
* `p = 11`: `p + 1 = 12`, but `(5 | 11) = +1` (`4² ≡ 5 mod 11`, gate open).
  `V₁₂ = 103682 ≡ 7 ≡ 3² − 2 (mod 11)`, so `11 ∤ V₁₂ − 2` and the method
  *fails* even though `12 = p + 1` divides the exponent.
  Formalised: `PlusOneSmoothNull.gate_failure_example`,
  `PlusOneSmoothNull.gate_failure_example_int`, and in general
  `PlusOneWilliams.lucasV_p_add_one_of_square_disc`
  (`V_{p+1} = P² − 2` whenever `D` is a square).

This pair is the whole "discriminant gating" phenomenon in miniature: the
success set is not `{p : (p+1) ∣ M}` but `{p : (p+1) ∣ M and (D | p) = −1}`.

## 2. Square-class coincidence of bases 3 and 7

`D₃ = 5`, `D₅ = 21`, `D₇ = 45 = 5·3²`. Enumerating `(D | p)` for the odd primes
`p < 200`, `p ≠ 3, 5` (43 primes), the vectors for `D = 5` and `D = 45` agree in
**every** position (exploratory check), as they must: they differ by a square.
Formalised in general form as
`PlusOneWilliams.legendreSym_mul_sq` and
`PlusOneSmoothNull.bases_three_and_seven_same_gate`.

## 3. Collision hunt for the invisibility barrier

Search space: all semiprimes `N = p·q`, `3 ≤ p < q < 6000`, `N` of bit length
22. Bucketed by the statistic `(N mod 60060, bitlength N)` where
`60060 = 2²·3·5·7·11·13`.

Result (the witness used in the Lean proofs):

| instance | p | q | N | N mod 60060 | bits(N) | bits(p) | bits(q) | `3 ∣ p+1` | `(5 \| p)` |
|---|---|---|---|---|---|---|---|---|---|
| A | 359 | 5849 | 2 099 791 | 57 751 | 22 | 9 | 13 | **true** | **+1** |
| B | 397 | 5743 | 2 279 971 | 57 751 | 22 | 9 | 13 | **false** | **−1** |

So a *single* matched pair defeats both channels simultaneously: the two
instances are indistinguishable by residues modulo every prime `≤ 13`, by every
Jacobi symbol whose discriminant is supported on those primes, and by bit
length — yet they carry opposite labels for the `+1`-divisibility class **and**
opposite labels for the base-3 discriminant gate.
Formalised: `PlusOneSmoothNull.matched_pair_collision`,
`plusOne_divisibility_invisible`, `williams_gate_invisible`.

Collisions of this kind are abundant, not rare: in the 22-bit band above there
are 10 665 statistic-buckets containing ≥ 2 instances, and 8 722 of them
(81.8%) already contain two instances with opposite `3 ∣ p+1` labels
(exploratory count, not re-checked in Lean).

## 4. The visible symmetric control

For primes `p, q ≠ 3`, enumeration of all `(p mod 3, q mod 3) ∈ {1,2}²` gives

| p mod 3 | q mod 3 | N mod 3 | `3∣p+1` | `3∣q+1` |
|---|---|---|---|---|
| 1 | 1 | 1 | no | no |
| 1 | 2 | 2 | no | yes |
| 2 | 1 | 2 | yes | no |
| 2 | 2 | 1 | yes | yes |

`N mod 3` is constant on the two rows with opposite "which factor" answers:
it determines the XOR and nothing more. Formalised exactly:
`PlusOneSmoothNull.mod_three_reveals_xor` (an iff) and
`symmetric_plusOne_visible_mod_three`.

## 5. Character channel

`J(5 | 21) = J(5|3)·J(5|7) = (−1)(−1) = +1` while `J(5 | 209) = J(5|11)·J(5|19)
= (+1)(+1) = +1`: the same `N`-computable value with opposite gates at the
smaller factor. Formalised: `jacobi_gate_product_uninformative`,
`jacobi_of_N_cannot_locate_gate`, and the multiplicativity
`jacobiSym_semiprime_split`.

## 6. Gate density

For `p = 11` the bad bases (those `P` with `P² − 4` a square) are
`P = 2, 3, 4, 7, 8, 9`: six of eleven, i.e. `(p+1)/2`. This is checked inside
Lean by `PlusOneGateDensity.card_disc_square_eleven`, and proved in general by
`PlusOneGateDensity.card_disc_square` / `card_gate_open`.

## 7. OEIS

The base-3 Lucas sequence `2, 3, 7, 18, 47, 123, 322, 843, 2207, …` is
A005248 (bisection of the Lucas numbers, `L_{2n}`); `V_n(3) = L_{2n}`. No new
sequence arises in this experiment, so no OEIS submission is warranted.
