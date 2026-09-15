# Computational evidence for the type-channel law

All numbers below were first computed by exhaustive enumeration over the six Galois
groups, and **then re-derived inside Lean 4** in closed form, so every entry of every
table in this file is backed by a `sorry`-free theorem in
`Catalog/Cryptography/NonabelianTypeChannel/`.  Nothing here rests on a floating-point
computation alone.

Throughout `L3 = log₂ 3 = 1.5849625...` and `L5 = log₂ 5 = 2.3219281...`.

## 1. The model

The Chebotarev picture reduces "an unramified prime `p` of a Galois field with group
`G`" to "a uniform element `g ∈ G`":

* the **splitting type** of `p` is the cycle type of `g` on the roots, recorded as
  `splitType g = (#fixed points, #points on 2-cycles)` (a faithful encoding of the
  cycle type in degrees 3 and 4, and a class function — `TypeChannel.splitType_conj`);
* the **residue class of `p`** modulo the conductor of the abelian characters of `G` is
  the coset of `g` modulo the derived subgroup `[G,G]` (class field theory), modelled
  by a readout whose level sets are the cosets (`TypeChannel.IsCosetReadout`).

The six fields, with the permutation models used:

| field | `G` | model | `N = [G,G]` |
|---|---|---|---|
| `x³ + x + 1`, `x³ - x + 1` | `S₃` | all of `Perm (Fin 3)` | `A₃` |
| `x⁴ - x - 1` | `S₄` | all of `Perm (Fin 4)` | `A₄` |
| `x⁴ + 8x + 12` | `A₄` | even permutations | `V₄` |
| `x⁴ - 2` | `D₄` | stabiliser of the pairing `{{0,2},{1,3}}` of `α, iα, -α, -iα` | centre `{1,(02)(13)}` |
| `x⁴ - 2x² + 9` | `V₄` | double transpositions + identity | `1` |
| `Φ₅` | `C₄` | the four rotations | `1` |

Each `N` is certified in Lean as *the* derived subgroup: every commutator of `G` lies
in `N` and every element of `N` is itself a commutator (`IsDerivedFinset`, checked by
kernel evaluation over all `|G|²` pairs).

## 2. Prime level — small-case enumeration

Exhaustive enumeration over `G` (all `|G|` elements, no sampling) gives the joint
distribution of (coset, type).  For example `A₄` (12 elements):

| coset of `V₄` | type `[1,1,1,1]` | `[2,2]` | `[3,1]` |
|---|---|---|---|
| `0` | 1 | 3 | 0 |
| `1` | 0 | 0 | 4 |
| `2` | 0 | 0 | 4 |

and `D₄` (8 elements):

| coset of the centre | `[1,1,1,1]` | `[4]` | `[2,1,1]` | `[2,2]` |
|---|---|---|---|---|
| `0` (`1`, `(02)(13)`) | 1 | 0 | 0 | 1 |
| `1` (`(02)`, `(13)`) | 0 | 0 | 2 | 0 |
| `2` (`(01)(23)`, `(03)(12)`) | 0 | 0 | 0 | 2 |
| `3` (`(0123)`, `(0321)`) | 0 | 2 | 0 | 0 |

The resulting channel table (`I₁ = I(coset ; type)`):

| field | `H(T)` | `I₁` exact | `I₁` numeric | dial `log₂[G:G']` | loss |
|---|---|---|---|---|---|
| `S₃` | `2/3 + L3/2` | `1` | 1.00000 | 1 | 0 |
| `S₄` | `3/2 + 3L3/8` | `1` | 1.00000 | 1 | 0 |
| `A₄` | `3L3/4` | `L3 - 2/3` | 0.91830 | `L3` | `2/3` |
| `D₄` | `5/2 - 3L3/8` | `9/4 - 3L3/8` | 1.65564 | 2 | `3L3/8 - 1/4` |
| `V₄` | `2 - 3L3/4` | `2 - 3L3/4` | 0.81128 | 2 | `3L3/4` |
| `C₄` | `3/2` | `3/2` | 1.50000 | 2 | `1/2` |

These agree with the measured prime-level values reported for ~23k primes per field
(`1.0000`, `1.0100`, `0.9188`, `1.6555`, `0.8092`, `1.4989`) to within the quoted
finite-sample margins.  In Lean: `S3_channel`, `S4_channel`, `A4_channel`,
`D4_channel`, `V4_channel`, `C4_channel` in `Fields.lean`.

Two structural facts visible in the table and proved in Lean:

* `S₄` carries `3/2 + 3L3/8 = 2.0944` bits of splitting entropy across five types and
  leaks exactly one (`S4_cap_strict`): the cap is set by the abelianization `C₂`, not
  by the type count.
* **the reversal**: `V₄` (abelian) sits at `0.8113` while `D₄` (non-abelian) sits at
  `1.6556` (`reversal_V4_lt_D4`).

## 3. Semiprime level — the pair law

Two independent uniform Frobenius elements `(x, y)` (the two prime factors of `N = pq`);
the residue of `N` is the coset of `x·y`, the factorisation reader sees the *unordered*
pair of types.  Exhaustive enumeration over all `|G|²` pairs gives

| field | `I₂` exact | `I₂` numeric | reported |
|---|---|---|---|
| `S₃` | `1` | 1.00000 | 1.0001 |
| `S₄` | `1` | 1.00000 | 1.0034 |
| `A₄` | `L3 - 10/9` | 0.47385 | 0.4729 |
| `D₄` | `39/16 - 3L3/4 + 5L5/64` | 1.43018 | 1.4325 |
| `V₄` | `19/8 - 21L3/16` | 0.29474 | 0.2902 |
| `C₄` | `5/4` | 1.25000 | 1.2461 |

(the "reported" column is the Monte-Carlo estimate from the experiment; the exact
column is the theorem).  In Lean: `S3_semi_channel` … `C4_semi_channel`.

**Which-factor wall.**  Enumeration also shows that replacing the unordered pair of
types by the ordered pair leaves `I₂` unchanged, to the last bit, for all six fields;
this is proved exactly in Lean (`*_which_factor_wall`), so the measured wall of
`0.0000–0.0001` is a theorem, not a coincidence of sampling.

## 4. Counterexample hunt

* *Does abelianness order the channels?*  No — `V₄` (abelian) `< D₄` (non-abelian) at
  both levels; the ordering by the earlier fork readout is the opposite.  Both are
  instances of the same law, so this is a counterexample to the naive reading, not to
  the law.
* *Can a field with many types beat its abelianization?*  No, and this was checked
  against the worst case available here (`S₄`, five types, fifteen unordered pairs,
  `H(T) > 2` bits): both channels are exactly `1`.  The general obstruction is
  `typeChannel_le_logb_index`.
* *Is the cap always attained?*  No: `A₄`, `D₄`, `V₄`, `C₄` all fall short, and
  `typeChannel_complete_iff` says exactly when this happens — the type must determine
  the coset.  Enumeration confirms the type fails to determine the coset in precisely
  those four cases.

## 5. OEIS

The channel values are not integer sequences; no OEIS entry is relevant.  The cell
counts that occur are the conjugacy-class sizes of the six groups
(`1,3,8`; `1,6,3,8,6`; `1,2,2,3`; `1,3`; `1,2,1`), which are standard.
