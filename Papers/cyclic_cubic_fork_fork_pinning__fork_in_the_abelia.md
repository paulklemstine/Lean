# Computational evidence for the fork-pinning criterion

All numbers below were produced by evaluating the corresponding `Finset` computations in Lean 4
(`#eval` on `Equiv.Perm (Fin 3)`, `Equiv.Perm (Fin 4)` and `ZMod 3 × ZMod 3`), i.e. by exact
enumeration of the groups.  Every count that a theorem depends on is re-checked inside the proofs
themselves by `decide`, so the tables are not merely exploratory — they are kernel-verified as
part of `Catalog/Probability/ForkPinningGalois.lean` and
`Catalog/Probability/ForkPinningSemiprime.lean`.

The model: by Chebotarev, a random unramified prime gives a uniform Frobenius element of the
Galois group `G` of the splitting field, and the splitting type of the defining polynomial is the
cycle type of that element on the roots.  Congruence conditions on the prime see exactly the
abelian quotients of `G`.

## 1. Cyclic cubic (`G = C₃`, e.g. `x³+x²−2x−1`, conductor 7)

| fork value | count | probability |
|---|---|---|
| `[1,1,1]` (Frobenius `= 0`) | 1 / 3 | 1/3 |
| not split                   | 2 / 3 | 2/3 |

The residue class *determines* the fork, so `I = H(fork)`:

```
I = log 3 − (2/3) log 2  =  0.918296 bits
```
(experiment: 0.9182, i.e. `H(1/3)` exactly).

## 2. `S₃` cubic (e.g. `x³+x+1`)

Enumeration of `S₃` (6 elements), `sign` versus the `[1,1,1]` fork:

| | fork `[1,1,1]` | other |
|---|---|---|
| even (`sign = +1`) | 1 | 2 |
| odd  (`sign = −1`) | 0 | 3 |

```
H(fork) = log 6 − (5/6) log 5                      = 0.650022 bits
I(sign ; fork) = (4/3)log2 + (1/2)log3 − (5/6)log5 = 0.190875 bits
```
(experiment: `I(p mod 31; fork) = 0.1906 = I(sign; fork)` exactly).
The fork is *not* a function of the sign (the identity and a 3-cycle are both even), so the
pinning is strictly partial, and — proved in Lean — **no** abelian character pins it.

## 3. `S₄` quartic (e.g. `x⁴−x−1`, disc −283)

Fixed-point (root-count) profile of `S₄`, by enumeration:

| roots | 4 | 2 | 1 | 0 |
|---|---|---|---|---|
| count (out of 24) | 1 | 6 | 8 | 9 |

which is the `1 : 6 : 8 : 9` law of a genuine `S₄` quartic.  Even face (`A₄`, 12 elements):
`(4 roots, 0 roots, 1 root) = (1, 3, 8)`, i.e. the densities `1/12 : 3/12 : 8/12` reported for
the "A₄ fork".

`sign` versus the has-a-root fork:

| | has a root | no root |
|---|---|---|
| even | 9 | 3 |
| odd  | 6 | 6 |

```
H(has-a-root) = 3log2 − (5/8)log5 − (3/8)log3 = 0.954434 bits
I(sign ; has-a-root) = (3/2)log2 − (5/8)log5  = 0.048795 bits
```
(experiment: 0.0483, predicted 0.0488).

## 4. Semiprime level (`C₃ × C₃`)

`N = pq`, observable = the cubic-residue class `a+b` of `N`, fork `OR = [a=0 ∨ b=0]`:

| class of `N` | 0 | 1 | 2 |
|---|---|---|---|
| `OR` true | 1/3 | 2/3 | 2/3 |

`P(OR) = 5/9`, and

```
I(class of N ; OR) = log 3 − (5/9)log5 − (2/9)log2 = 0.072780 bits
```
(experiment 0.0718, predicted 0.0728).  The "which factor splits" label is *exactly* independent
of the class of `N` (each of the 6 joint cells factorizes), so its mutual information is `0`
(experiment: 0.0001).

## 5. Counterexample hunt

* Is the `S₃` fork pinned by some finer modulus?  No: it fails commutator invariance
  (`1` and `⁅(0 1),(1 2)⁆` are in the same commutator coset but have different fork values),
  and this is proved to obstruct pinning by *every* abelian character.
* Is flatness a class-number effect?  No: the flat/pinned dichotomy is entirely decided by
  whether the fork is constant on cosets of the commutator subgroup.
* Could a within-face fork be pinned?  No: on the commutator subgroup every abelian character is
  constant, so the mutual information is identically `0` — proved for arbitrary forks.

No counterexample to the criterion was found; instead the criterion is proved in both directions
in `Catalog/Probability/ForkPinningCore.lean` and `Catalog/Probability/ForkPinningGalois.lean`.

## 6. The general semiprime dial (later cycle)

The semiprime model was re-run for an arbitrary finite group `G` of order `n` (observable
`class(N) = class(p)·class(q)`, fork `OR = [class p = 1 ∨ class q = 1]`).  Counting the fibres
gives `P(OR | class N = 1) = 1/n` and `P(OR | class N = s ≠ 1) = 2/n`, whence the exact value
(proved as `semiprime_OR_mutualInfo_general`)

```
I(n) = log n + ( −(2n−1)log(2n−1) + (n−1)(3−2n)log(n−1)
                 + 2(n−1)log 2 + (n−1)(n−2)log(n−2) ) / n²   (nats).
```

Numerical evaluation of that closed form (`#eval` on `Float`):

| n | I(n) (nats) | n²·I(n) | prime-level H(1/n) | ratio H/I |
|---|---|---|---|---|
| 2 | 0.215762 | 0.863046 | 0.693147 | 3.21 |
| 3 | 0.050447 | 0.454027 | 0.636514 | 12.62 |
| 4 | 0.024870 | 0.397921 | 0.562335 | 22.61 |
| 5 | 0.014928 | 0.373209 | 0.500402 | 33.52 |
| 6 | 0.009976 | 0.359146 | 0.450561 | 45.16 |
| 7 | 0.007144 | 0.350034 | 0.410116 | 57.41 |
| 10 | 0.003352 | 0.335249 | | |
| 100 | | 0.309382 | | |
| 10000 | | 0.306878 | | |

The value at `n = 3` is `0.050447` nats `= 0.0728` bits, exactly the measured cyclic-cubic dial,
and `n²·I(n)` decreases to `1 − log 2 = 0.306853…` (matching the second-order expansion
`I(n) = (1 − log 2)/n² + O(1/n³)`).  The proved bound
`I(n) ≤ 1/((2n−1)(n−1))` (`semiprime_collapse_rate`) gives `n²I ≤ n²/((2n−1)(n−1)) → 1/2`, i.e.
it is within a factor `1.63` of the truth uniformly in `n`.

---

## Cycle 2 evidence (for the newly closed conjectures)

These are exploratory computations (exact rational counting, floating-point logs) that were run
*before* the corresponding Lean proofs; they are not themselves formal verifications — the formal
statements are the Lean theorems named in each item.

### 1. The extremal profile `C(d) = binEntropy d − binEntropy(2d)/2` (C1)

Brute force over *all* `2⁶` forks of a 6-element sample space with a balanced observable
(3 elements in each coset), recording the maximum of `I(X;Y)` at each density `d`:

| d | max over forks of I(X;Y) | C(d) |
|---|---|---|
| 0 | 0.000000 | 0.000000 |
| 1/6 | 0.132304 | 0.132304 |
| 1/3 | 0.318257 | 0.318257 |
| 1/2 | 0.693147 | 0.693147 = log 2 |

The maximum equals `C(d)` at every density, and the maximisers are exactly the forks contained in
one coset — the pattern proved as `mutualInfo_le_singleCoset` / `mutualInfo_singleCoset_eq`.
At `d = 1/2` the maximum is `log 2`, matching `capacity_attained_iff` (C2).

### 2. The `k`-factor wall and the `k`-factor dial (C7)

`N = p₁⋯p_k` with independent uniform classes in `Z/n`, observable `class N = Σ classes`:

| n | k | I(class N ; statistic of the first k−1 factors) | I(class N ; [some pᵢ splits]) | k²/n² |
|---|---|---|---|---|
| 3 | 2 | 0.000e+00 | 0.050447 | 0.4444 |
| 3 | 3 | 0.000e+00 | 0.006782 | 1.0000 |
| 3 | 4 | 0.000e+00 | 0.000948 | 1.7778 |
| 4 | 2 | 0.000e+00 | 0.024870 | 0.2500 |
| 4 | 3 | 0.000e+00 | 0.001514 | 0.5625 |
| 4 | 4 | 0.000e+00 | 0.000105 | 1.0000 |

The middle column is exactly zero in every case — this is the wall, now proved for all `k` as
`kfactor_wall`.  The dial column satisfies the conjectured `k²/n²` budget of C7 with room to spare and in fact
*decreases* rapidly in `k`, so the C7 bound — still open — appears to be far from tight; a sharp
`k`-dependence is the natural next target.

## Cycle 3 evidence (sharp constant C6, capacity profile C9)

Again exploratory floating-point computations run *before* the Lean proofs; the formal statements
are the named theorems in `Catalog/Probability/ForkPinningSharpConstant.lean` and
`Catalog/Probability/ForkPinningProfile.lean`.

### 1. The sharp semiprime constant (C6)

Evaluating the proved closed form `I(n)` (`semiprime_OR_mutualInfo_general`):

| n | I(n) | n² I(n) |
|---|------|---------|
| 2 | 0.21576155 | 0.863046 |
| 3 | 0.05044741 | 0.454027 |
| 4 | 0.02487004 | 0.397921 |
| 10 | 0.00335249 | 0.335249 |
| 100 | 0.00003094 | 0.309382 |
| 1000 | 0.00000031 | 0.307103 |
| 10⁴ | 3.0688e-09 | 0.306878 |

against `1 − log 2 = 0.30685282`.  The column `n² I(n)` stays below `1` and decreases towards the
constant — the two statements now proved as `n_sq_mutualInfo_lt_one` and
`semiprimeDial_sharp_constant` (with the quantitative rate `|n²I(n) − (1 − log 2)| ≤ 24/n`,
`abs_n_sq_semiprimeDial_sub_le`).  Monotonicity of `n² I(n)` itself is still only observed, not
proved.

### 2. The capacity profile of an index-two conductor (C9)

`C(d) = binEntropy d − binEntropy(2d)/2`, `H(d) = binEntropy d`:

| d | C(d) | C(d)/d | C(d)/H(d) |
|---|------|--------|-----------|
| 1/4 | 0.21576155 | 0.863046 | 0.383689 |
| 0.1 | 0.07488176 | 0.748818 | 0.230347 |
| 0.01 | 0.00698198 | 0.698198 | 0.124675 |
| 0.001 | 0.00069365 | 0.693648 | 0.087723 |
| 10⁻⁵ | 6.9315e-06 | 0.693152 | 0.055395 |

`C(d)/d → log 2 = 0.6931472` (proved: `cosetProfile_div_tendsto`), *not* `log(1/d)`, and the
pinned fraction `C(d)/H(d)` drifts to `0` rather than to `1/2` (proved:
`pinnedFraction_tendsto_zero`).  Both numbers falsified the corresponding guesses of the cycle-2
conjecture C9 before the proofs were written.
