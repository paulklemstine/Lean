# Computational evidence — Weil pairing and BLS signatures

All computations below were run inside Lean 4 (mathlib4 v4.28.0) on the determinant
model `(ZMod n)²` with pairing form `detForm n v w = v₁w₂ − v₂w₁`, the model that
`Catalog/Cryptography/WeilPairingDeterminant.lean` proves realises the Weil-pairing
axioms of the catalog.  Every table below that supports a universally quantified claim
was *also* turned into a kernel-checked `decide` theorem in
`Catalog/Cryptography/PairingEvidence.lean`; the `#eval` numbers here are the
quantitative summary.

## 1. Nondegeneracy: how many vectors pair trivially with everything?

For each modulus `n`, the number of `v ∈ (ZMod n)²` with `detForm n v w = 0` for **all**
`w`:

| n | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9 |
|---|---|---|---|---|---|---|---|---|
| # degenerate vectors | 1 | 1 | 1 | 1 | 1 | 1 | 1 | 1 |

Only the zero vector is degenerate — including at composite moduli `n = 4, 6, 8, 9`,
where `ZMod n` is not a field.  This is the numerical content of
`detPairing_nondegenerate_left` / `detPairing_nondegenerate_right`, and it is the reason
the existence theorem `weilPairingOfEquiv` needs no primality hypothesis.
Kernel-checked instance: `detForm_nondegenerate_zmod_five`.

## 2. Value distribution of the pairing

Number of ordered pairs `(v, w) ∈ ((ZMod n)²)²` attaining each value `t ∈ ZMod n`:

* `n = 4`: `t = 0 : 88`, `t = 1 : 48`, `t = 2 : 72`, `t = 3 : 48`  (total 256 = 4⁴)
* `n = 5`: `t = 0 : 145`, `t = 1,2,3,4 : 120` each  (total 625 = 5⁴)

For the prime `n = 5` the four nonzero values are equidistributed (120 pairs each),
while the value `0` is attained 145 times — exactly the number of linearly dependent
pairs (`25` pairs with `v = 0`, plus `24 · 5 = 120` pairs with `v ≠ 0` and `w ∈ ⟨v⟩`).
At the composite modulus `4` the distribution is *not* uniform: the zero divisor `2` is
attained 72 times against 48 for each unit.  This asymmetry is the numerical fingerprint
of the fact that `orderOf ζ = n` (see `alt_pairing_orderOf_eq_of_nondegenerate`) is a
genuine constraint rather than an automatic consequence.

## 3. Counterexample hunt: is the pairing ever degenerate on a cyclic subgroup?

Exhaustive scan over `(ZMod 5)²` of `detForm 5 (a • v) (b • v)` for all `a, b < 5` and
all `v`: **all 625 values are zero**; no counterexample to total degeneracy on cyclic
subgroups was found, as predicted by `AltPairing.pair_smul_smul_self`.  This is the
computational counterpart of the rank obstruction
`WeilPairing.torsion_trivial_of_cyclic`: a *nondegenerate* alternating pairing simply
cannot exist on cyclic torsion.  Kernel-checked:
`detForm_cyclic_degenerate_zmod_five`.

## 4. Endomorphism determinant law

Exhaustive scan over all 81 endomorphisms `!![a,b;c,d]` of `(ZMod 3)²` and all 81 pairs
`(v,w)`: the identity `detForm(φv, φw) = (ad − bc)·detForm(v,w)` holds in all 6561
cases; no counterexample.  Kernel-checked: `detForm_linMap_zmod_three`.  Specialising to
`φ = m·I` recovers the degree law `e(mP, mQ) = e(P,Q)^{m²}`.

## 5. DDH is broken by the pairing

With `P = (1,0)`, `Q = (0,1)` over `ZMod 5`, the test
`e(aP, bQ) = e(P, cQ)` was compared with the arithmetic predicate `ab ≡ c (mod 5)` for
all `125` triples `(a,b,c)`: **perfect agreement (`true`)**.  This is the small-case
evidence for `AltPairing.ddh_iff`, i.e. the decisional Diffie–Hellman problem in a
pairing group is solvable from group elements alone — hence BLS must be reduced to CDH
and not to DDH.

## 6. Rogue-key attack

Exhaustive scan over `(ZMod 5)²`: for all victim keys `pk`, all message hashes `H` and
all adversarial scalars `y < 5`, the forged aggregate `σ = y • H` (which uses **no**
secret key) satisfies the two-signer aggregate verification equation with the rogue key
`pk₂ = y•G − pk`.  All 3125 instances verify; the attack never fails.  Kernel-checked:
`rogue_key_identity_zmod_five`, proved abstractly as `BLSParams.rogue_key_attack`.

## 7. End-to-end BLS run in the corrected model over `ZMod 7`

Using `detBLSSetting 7` (signature generator `(1,0)`, key generator `(0,1)`, pairing value
of exact order 7):

* **Correctness**: for all `7 × 7 = 49` pairs `(sk, h)` the honest signature `(sk·h) • gen₁`
  is accepted.  Kernel-checked: `bls_correct_zmod_seven`.
* **Uniqueness / soundness**: over all `343` triples `(sk, h, s)`, the candidate `s • gen₁`
  is accepted **iff** `s = sk·h mod 7` — exactly one of the seven candidates passes.
  Kernel-checked: `bls_unique_signature_zmod_seven`.

This is the concrete counterpart of `BLSSetting.verifies_iff_modEq`, and it is precisely
the property that the previous catalog model could not have: its injectivity axiom is
provably unsatisfiable on nontrivial torsion (`BLSParams.torsion_trivial`).

## 8. OEIS

The only integer sequence produced here is the trivially constant sequence of
degeneracy counts (all `1`) and the value distributions above; no OEIS entry is
relevant, and no search was performed.
