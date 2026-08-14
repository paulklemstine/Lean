# Computational Evidence — Class-Group Representation Vectors as Residue Dials

All numbers below were first produced by direct enumeration and then **certified
in Lean** where indicated; every "certified" line corresponds to a `sorry`-free
theorem in `Catalog/Algebra/`.

## 1. Residues represented by each reduced form (units only)

Enumerating `f(x,y) mod m` over all `(x,y)` and keeping values coprime to `m`:

| discriminant | form | residues represented (units) |
|---|---|---|
| `-20` | `x² + 5y²` | `{1, 9}` mod 20 |
| `-20` | `2x² + 2xy + 3y²` | `{3, 7}` mod 20 |
| `-84` | `x² + 21y²` | `{1, 25, 37}` mod 84 |
| `-84` | `2x² + 2xy + 11y²` | `{11, 23, 71}` mod 84 |
| `-84` | `3x² + 7y²` | `{19, 31, 55}` mod 84 |
| `-84` | `5x² + 4xy + 5y²` | `{5, 17, 41}` mod 84 |
| `-23` | `x² + xy + 6y²` | `{1,2,3,4,6,8,9,12,13,16,18}` mod 23 |
| `-23` | `2x² + xy + 3y²` | `{1,2,3,4,6,8,9,12,13,16,18}` mod 23 |

The residue sets are **pairwise disjoint** for `D = -20` and `D = -84`
(one class per genus) and **identical** for `D = -23` (one genus, three classes).

*Certified*: `sound20`, `disj20`, `sound84`, `disj84`,
`genus23_no_separation`.

## 2. Representation counts on semiprimes (`r_Q(N) = #{(x,y) : Q(x,y) = N}`)

| `N` | factorisation | class type | `N mod \|D\|` | vector |
|---|---|---|---|---|
| `21` | `3 · 7` | NN (both non-principal) | `1` | `(8, 0)` |
| `1189` | `29 · 41` | PP (both principal) | `9` | `(8, 0)` |
| `87` | `3 · 29` | PN (mixed) | `7` | `(0, 8)` |
| `253` | `11 · 23` | `f₂ · f₂` | `1` | `(8, 0, 0, 0)` |
| `589` | `19 · 31` | `f₃ · f₃` | `1` | `(8, 0, 0, 0)` |

The PP row and the NN row are **identical**, and at `D = -84` three different
same-class pair types all read `(8,0,0,0)`.

*Certified*: `reps_21_ncard`, `reps_21_Q_ncard`, `reps_1189_ncard`,
`reps_87_ncard`, `reps_87_P_ncard`, `reps_253_ncard`, `reps_589_ncard`
(each proved by an exhaustive search inside a box that is *proved* to contain
every representation — see `repsP_eq_boxP`, `repsQ_eq_boxQ`, `repsf1_eq_boxf1`).

The value `8` for a squarefree semiprime with both primes split, and `4` for a
split prime (`r_P(29) = r_P(41) = 4`, `r_Q(3) = r_Q(7) = 4`), matches the
classical `w · Σ_{d|N} χ_D(d)` count with `w = 2`.  The factor `4` in every entry
is not an accident of these examples: it is forced by the free action of the
four sign changes `(±x, ±y)`.

*Certified*: `four_dvd_repP_ncard` — for `N > 0` coprime to `20` and not a perfect
square, `4 ∣ r_P(N)`.

## 3. Counterexample hunt: is the dial universal?

Sweeping discriminants for a pair `N ≡ M (mod |D|)`, both coprime to `D`, with
different representation status:

* `D = -20`, `D = -84`: **no counterexample** in the swept range — consistent
  with the theorem that none exists (`dial20_factor_blind`, `dial84_factor_blind`).
* `D = -23`: counterexample found immediately, `N = 59`, `M = 13`:
  `59 ≡ 13 (mod 23)`, `59 = 5² + 5·2 + 6·2²` is principal, `13 = 2·2² + 2·1 + 3·1²`
  is represented only by the non-principal class, and `13` is *not* of the form
  `x² + xy + 6y²`.

*Certified*: `dial_fails_at_23`, `not_reprP23_13`, `no_residueDial_23`.

## 4. Multiplicative structure

The four residues `{1,3,7,9}` occurring mod 20 form a group, and the "which
class" bit is a homomorphism onto `ℤ/2`:

```
1·1=1  1·3=3  1·7=7  1·9=9
3·3=9  3·7=1  3·9=7  7·7=9  7·9=3  9·9=1
```

so `bit(ab) = bit(a) ⊕ bit(b)` and `bit(a²) = 0` for every `a`.

*Certified*: `D20_mul_mem`, `dialBit_mul`, `dialBit_sq`.

## 5. Stacking two discriminants

Searching for primes that are principal (resp. non-principal) simultaneously at
`D = -20` and `D = -84`:

* principal at both: `109 = 8² + 5·3² = 5² + 21·2²`, `421 = 4² + 5·9² = 20² + 21·1²`, …
* non-principal at both: `23 = 2·(-1)² + 2(-1)(3) + 3·3² = 2·2² + 2·2·1 + 11·1²`,
  `107`, …

So the joint `(-20, -84)` observation is confronted with a genuine PP pair
(`109 · 421`) and a genuine NN pair (`23 · 107`) — and reports the principal
class for both.

*Certified*: `stacked_witness`, `stacked_pp_nn_blind`, `joint_factor_blind`.

## 6. OEIS

No OEIS lookup was performed (no network access in this environment), and none
is needed: the sequences occurring here are the coefficient sequences of the
theta series of the reduced forms of discriminant `-20`, `-84` and `-23`, which
are classical objects rather than new sequences.  That is itself consistent with
the "repackaging" verdict: the data produced by the extrinsic-discriminant
construction is the classical representation data of binary quadratic forms.
