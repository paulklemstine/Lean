# Computational Evidence — Prime-degree abelian layers and Hilbert class fields

This cycle extends the Kronecker–Weber / Hilbert-12 catalog files
(`CyclotomicGL1Langlands`, `CyclotomicGaloisDegree`, `KroneckerWeberRealization`,
`HilbertClassFieldReciprocity`). The central claim proved is:

> A finite Galois extension whose Galois group has **prime** order has **no** intermediate
> fields, and its Galois group is cyclic.

Below is the small-case evidence that motivated the targets.

## 1. Cyclotomic Galois-group orders `#Gal(ℚ(ζₙ)/ℚ) = φ(n)`

| n | φ(n) | prime? | proper subfields of ℚ(ζₙ)? |
|---|------|--------|-----------------------------|
| 3 | 2    | yes    | none (minimal)              |
| 4 | 2    | yes    | none (minimal)              |
| 5 | 4    | no     | ℚ(√5)                       |
| 6 | 2    | yes    | none (minimal)              |
| 7 | 6    | no     | ℚ(√-7), cubic subfield      |
| 8 | 4    | no     | ℚ(i), ℚ(√2), ℚ(√-2)         |
| 11| 10   | no     | ℚ(√-11), quintic subfield   |

The prime-order rows (n = 3, 4, 6) are exactly the cyclotomic fields with **no** proper
subfields. This is the concrete pattern behind
`AbelianExtensionPrimeDegree.cyclotomic3_intermediate_eq_bot_or_top`
(instantiated at n = 3, order 2). The composite-order rows exhibit genuine intermediate
fields, confirming primality of the order is load-bearing, not decorative.

## 2. Class numbers of imaginary quadratic fields `ℚ(√-d)` and cyclic class groups

| d  | h_K | prime? | class group | Hilbert class field degree |
|----|-----|--------|-------------|-----------------------------|
| 1  | 1   | no     | trivial     | 1                           |
| 5  | 2   | yes    | C₂          | 2 (cyclic)                  |
| 23 | 3   | yes    | C₃          | 3 (cyclic)                  |
| 47 | 5   | yes    | C₅          | 5 (cyclic)                  |
| 21 | 4   | no     | C₂ × C₂     | 4 (non-cyclic!)             |

Every prime-`h_K` row has a **cyclic** class group and therefore (by Artin reciprocity) a
cyclic Hilbert class field Galois group with no proper intermediate layers — the content of
`HilbertClassFieldStructure.gal_isCyclic_of_classNumber_prime` and
`AbelianExtensionPrimeDegree.hilbertClassField_intermediate_eq_bot_or_top`. The `d = 21`
row (h_K = 4, class group C₂ × C₂) is the counterexample showing the primality hypothesis
cannot be dropped: there the class field genuinely has three quadratic intermediate layers
(genus theory).

## 3. Counterexample hunt for the universal claim

Claim tested: "every intermediate field of a prime-order Galois extension is trivial."
No counterexample exists — the Galois correspondence sends intermediate fields to subgroups,
and a prime-order group has only the two trivial subgroups. The `d = 21` and `n = 8` rows
above confirm the claim genuinely *fails* once the order is composite, so the theorem is
sharp at the primality boundary.

## Conclusion

The evidence is entirely finite/tabular and directly motivates the formal statements: the
prime-order rows collapse the subfield lattice; the composite rows do not. All proved
theorems build without `sorry` and depend only on the standard axioms
`propext`, `Classical.choice`, `Quot.sound`.
