# Computational Evidence — "the character captures exactly one bit"

This is the exploratory stage that preceded the Lean formalisation in
`Catalog/NumberTheory/CharacterOneBit.lean` and
`Catalog/NumberTheory/AbelianQuotientCeiling.lean`.  Everything reported as *verified* below is a
theorem in those files with a machine-checked, `sorry`-free proof; the table entries marked
*exploratory* are ordinary floating-point computations over the finite Galois groups (Chebotarev
densities = uniform counting measure on `G`) and are **not** by themselves proofs.

## 1. Small-case calculations (exploratory)

Uniform measure on `G`, read-out `T` = cycle type, character = sign.

| `G`  | `\|G\|` | `H(T)`   | `H(T \| sign)` | `I(T ; sign)` |
|------|------|----------|----------------|---------------|
| `S₃` | 6    | 1.459148 | 0.459148       | **1.000000**  |
| `S₄` | 24   | 2.094361 | 1.094361       | **1.000000**  |
| `S₅` | 120  | 2.557344 | 1.557344       | **1.000000**  |

`S₃` densities: `P('111') = 1/6`, `P('12') = 1/2`, `P('3') = 1/3`, exactly the Chebotarev densities
quoted for `x³ + x + 1` (`disc = -31`).

Beyond `C₂` quotients — read-out = conjugacy class, character = projection to `G^ab`:

| `G`   | `G^ab` | `H(class)` | `H(class \| G^ab)` | `I`          | `log₂ \|G^ab\|` |
|-------|--------|------------|--------------------|--------------|-----------------|
| `A₄`  | `C₃`   | 1.855389   | 0.270426           | **1.584963** | 1.584963        |
| `C₂`  | `C₂`   | 1          | 0                  | 1            | 1               |
| `C₃`  | `C₃`   | 1.584963   | 0                  | 1.584963     | 1.584963        |
| `C₄`  | `C₄`   | 2          | 0                  | 2            | 2               |

The `A₄` row is the observation that upgraded the conjecture: the answer is not "one bit" but
`log₂ |G^ab|`, and "one bit" is the case `|G^ab| = 2`.

## 2. Counterexample hunt (exploratory)

Searched for a finite group + surjective abelian character with
`I(conjugacy class ; character) ≠ log₂ |C|` among `S₃, S₄, S₅, A₄, C₂, C₃, C₄` and all their
quotient characters: **none found**; the identity held to machine precision in every case.  The
Lean proof (`mutInfo_conjClasses_character_eq_logb`) then explains why no counterexample can
exist: a hom into an abelian group is a class function, so the class read-out determines it, and
the fibres of a surjective hom are equal cosets.

A near-counterexample worth recording: the *coarsened* read-out "does `p` split completely?"
gives `I ≈ 0.19088 < 1` for `S₃`.  This is why the refinement hypothesis in the general theorem is
not decoration — it is verified in Lean as
`S3.mutInfo_splitsCompletely_sign_lt_one`.

## 3. What is machine-verified in Lean (sorry-free)

* `S3.uEnt_splitType : H(T) = 2/3 + (log₂ 3)/2` and the bracket `1.4591 < H(T) < 1.4594`;
* `S3.condEnt_splitType_sign : H(T | sign) = (log₂ 3)/2 - 1/3` and `0.4591 < · < 0.4594`, plus the
  paper's decomposition `H(T | sign) = (1/2)·H(1/3, 2/3)`;
* `S3.mutInfo_splitType_sign_eq_one : I(T ; sign) = 1` exactly;
* `mutInfo_cycleType_sign_eq_one` — the same for every symmetric group;
* `mutInfo_conjClasses_character_eq_logb : I = log₂ |C|` for any finite group and any surjective
  character into an abelian group, and `mutInfo_le_logb_card_of_factors` — the ceiling for every
  read-out visible through that character;
* `S3.exists_mixed_type_same_sign` — mixed-type residues are forced, not anomalies;
* `mutInfo_cyclic_cubic : log₂ 3` for the cyclic cubic, the abelian contrast.

## 4. OEIS

No new integer sequence arises: the fibre-count data for `S₃` is `(1, 3, 2)` and the general
statement is a closed form, not a sequence.  (The cycle-type class counts of `Sₙ` are the partition
numbers, OEIS A000041, which is classical and not a finding of this cycle.)
