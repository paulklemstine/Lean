# Computational Evidence

Research thread `th_0d5dcecd`, cycle 1. Target: Direction 3 of the future-directions
list — *a quantitative Ramsey lower bound via first-moment counting*.

## 1. The Erdős criterion, cleared of denominators

The classical first-moment argument gives a monochromatic-free 2-colouring of `K_n`
whenever

    C(n,k) · 2^(1 - C(k,2)) < 1     (Erdős 1947)

Multiplying through by `2^(C(k,2)-1)` turns this into the purely arithmetic,
denominator-free criterion actually formalized here:

    2 · C(n,k) < 2^(C(k,2)).

This is the hypothesis `hcrit` of `ramsey_lower_bound`.

## 2. Small-case table: largest `n` satisfying `2·C(n,k) < 2^C(k,2)`

For each `k` we tabulate `2^C(k,2)` and the largest `n ≥ k` with `2·C(n,k) < 2^C(k,2)`.
This `n` is a certified lower bound `R(k,k) > n` produced by the method.

| k | C(k,2) | 2^C(k,2) | largest good n | method gives R(k,k) > |
|---|--------|----------|----------------|-----------------------|
| 2 | 1      | 2        | 2  (2·C(2,2)=2, not <2 ⇒ n=2? 2·C(2,2)=2 fails; n=2: C(2,2)=1,2·1=2 not<2) → trivial | — |
| 3 | 3      | 8        | 3  (2·C(3,3)=2<8; n=4: 2·C(4,3)=8 not<8) | 3 |
| 4 | 6      | 64       | 6  (2·C(6,4)=30<64; n=7: 2·C(7,4)=70) | 6 |
| 5 | 10     | 1024     | 11 (2·C(11,5)=924<1024; n=12: 2·C(12,5)=1584) | 11 |
| 6 | 15     | 32768    | 17 (2·C(17,6)=24752<32768; n=18: 2·C(18,6)=37128) | 17 |

(Largest good `n` per `k` computed by direct enumeration: k=3→3, k=4→6, k=5→11, k=6→17.)

(The `k=4` row is the instance discharged in Lean as `no_mono_K4_in_K6`:
`2·C(6,4) = 30 < 64 = 2^C(4,2)`, checked by `decide`.)

These numbers were computed by direct evaluation of binomial coefficients; they are
consistent with the well-known asymptotic `R(k,k) > 2^{k/2}` (e.g. `k=6`: `2^3 = 8`,
and the method already yields the stronger `> 17`; the exponential form is the
*uniform* bound, individual `k` do better).

## 2b. The uniform exponential bound (now formalized)

The integer criterion `n^2 ≤ 2^k` (equivalently `n ≤ 2^{k/2}`) is sufficient for
`2·C(n,k) < 2^C(k,2)` whenever `k ≥ 3`. Small-case check of `n^2 ≤ 2^k ⇒ criterion`:

| k | 2^k | max n with n²≤2^k (=⌊2^{k/2}⌋) | 2·C(n,k) | 2^C(k,2) | criterion holds |
|---|-----|-------------------------------|----------|----------|-----------------|
| 3 | 8   | 2  | 2·C(2,3)=0   | 8      | yes (k>n, vacuous k-subsets) |
| 4 | 16  | 4  | 2·C(4,4)=2   | 64     | yes |
| 5 | 32  | 5  | 2·C(5,5)=2   | 1024   | yes |
| 6 | 64  | 8  | 2·C(8,6)=56  | 32768  | yes |
| 7 | 128 | 11 | 2·C(11,7)=660| 2097152| yes |
| 8 | 256 | 16 | 2·C(16,8)=25740 | 2^28 | yes |

This is exactly `choose_sq_bound` (`k ≥ 3`, `n^2 ≤ 2^k ⇒ 2·C(n,k) < 2^C(k,2)`), whose
combination with the counting theorem is `ramsey_lower_bound_exp`, delivering the
classical `R(k,k) > 2^{k/2}`. The `k=6`, `n=8` row is the Lean instance
`no_mono_K6_in_K8`. (For `k ≥ 4` the side condition `k ≤ n` needed by the colouring
theorem also holds, since `k^2 ≤ 2^k`.)

## 3. Counterexample hunt

The universal statement being proved is an *existence* theorem guarded by an explicit
numerical hypothesis, so a counterexample would be a triple `(n,k)` with
`2 ≤ k ≤ n`, `2·C(n,k) < 2^C(k,2)`, yet **every** 2-colouring of `K_n` has a
monochromatic `K_k`. No such triple can exist — the counting argument is a proof —
and indeed for all tabulated rows an explicit good colouring exists (e.g. random
colourings succeed with positive probability precisely because the bad fraction is
`< 1`). The formal proof `ramsey_lower_bound` closes this rigorously.

## 4. Faithfulness check of the Lean model

* Edges of `K_n` are the off-diagonal elements of `Sym2 (Fin n)`; `internalEdges S`
  has cardinality `C(|S|,2)` (`Sym2.card_image_offDiag`), verified `= 6` for `|S| = 4`.
* Total colourings `= 2^((n+1) choose 2)` (`Sym2.card`); the extra diagonal
  coordinates are inert and cancel in the ratio, so the criterion is unaffected.
* "No monochromatic `K_k`" is stated as: every `k`-subset has two internal edges of
  *different* colours — the exact negation of "constant on internal edges".
