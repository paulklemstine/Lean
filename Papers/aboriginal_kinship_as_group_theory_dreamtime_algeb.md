# Computational Evidence — Dreamtime Algebra

This note records the small-case checks that motivated the formal development in
`Catalog/Bridges/DreamtimeKinshipAlgebra.lean`.

## 1. The four-section (Kariera) system

Model the four sections as `ℤ/2 × ℤ/2`:

| section | code |
|---------|------|
| A       | (0,0) |
| B       | (1,0) |
| C       | (0,1) |
| D       | (1,1) |

Kinship steps are translations:

* `spouse = +(1,0)`   (marriage)
* `mother = +(0,1)`   (mother → child)
* `father = +(1,1)`   (father → child)

**Involution check** (every step applied twice is the identity), since `v+v=0`
in `ℤ/2 × ℤ/2`:

```
spouse∘spouse = +(1,0)+(1,0) = +(0,0) = id
mother∘mother = +(0,1)+(0,1) = +(0,0) = id
father∘father = +(1,1)+(1,1) = +(0,0) = id
```

**Descent consistency**: `father = spouse ∘ mother` because
`(1,0)+(0,1)=(1,1)`. A father's child is in the same section as the mother's
child (parents are spouses).

**Group structure**: the translations `{+(0,0),+(1,0),+(0,1),+(1,1)}` form a
group of order 4. Its Cayley table (component-wise XOR) is the Klein four-group.
Every non-identity element has order 2, so the group is `ℤ/2 × ℤ/2`, **not**
`ℤ/4` (which would need an element of order 4).

**Marriage as coset restriction**: with the matrimoiety subgroup
`H = {(a,0) : a ∈ ℤ/2} = {(0,0),(1,0)}` (kernel of the second coordinate),
each coset of `H` has exactly two sections and marriage pairs precisely the two
distinct members of a common coset:

```
coset with 2nd coord 0 : {A=(0,0), B=(1,0)}  →  A marries B
coset with 2nd coord 1 : {C=(0,1), D=(1,1)}  →  C marries D
```

This matches the ethnographic Kariera marriage rule and is exactly the statement
`marriage_iff_sameMatriMoiety`.

## 2. The eight-subsection (Warlpiri) system

Model the eight subsections as `(ℤ/2)³`. Again every element satisfies `v+v=0`,
so the transformation group has exponent 2 and order 8, i.e. `(ℤ/2)³`, and is not
cyclic.

**Double cover**: the forgetful map `(ℤ/2)³ → (ℤ/2)²`, `(a,b,c) ↦ (a,b)`, is a
surjective group homomorphism whose kernel `{(0,0,c) : c ∈ ℤ/2}` is `ℤ/2`. Hence
each of the 4 sections splits into exactly 2 subsections, and the subsection
system is a `ℤ/2`-extension of the section system:

```
1 → ℤ/2 → (ℤ/2)³ → (ℤ/2)² → 1
```

## 3. Counterexample hunt

* *Is the section group cyclic?* Enumerating all four elements shows the maximal
  order is 2, so no generator of order 4 exists — confirmed no counterexample to
  "not cyclic".
* *Does marriage stay within one coset?* Checking all ordered pairs `(x,y)` with
  `y = x+(1,0)` shows `y-x` always lies in the matrimoiety subgroup and `x≠y`;
  the converse also holds by exhaustive check (this exhaustive check is exactly
  what `decide` verifies in the Lean proof of `marriage_iff_sameMatriMoiety`).

## 4. OEIS

No integer sequence beyond the finite group orders (4 and 8) arises, so no OEIS
lookup is relevant. The relevant "sequence" is simply the group orders of the
elementary abelian 2-groups `(ℤ/2)ⁿ`: `1, 2, 4, 8, 16, …`.
