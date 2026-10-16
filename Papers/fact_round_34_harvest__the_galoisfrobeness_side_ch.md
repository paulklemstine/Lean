# Computational Evidence — Galois/Frobenius side channel (round 34)

Status legend: **[Lean]** = machine-checked in `Catalog/Probability/GaloisSideChannel*.lean`
(or in the catalog files they import); **[exploratory]** = a scratch Python enumeration run
while designing the conjectures. These numbers are not Lean-verified and are listed only
as a cross-check.

## 1. Small cases: the semiprime residue channel (Frobenius pair uniform on G × G)

`c` is the abelianization coset (sign for S₃/S₄), `T` the cycle type (splitting type).

| group | I(c(σpσq); T(p)) | I(c(σpσq); T(q)) | I(c; {Tp,Tq}) | I(c; (Tp,Tq)) | cap log₂[G:G'] |
|---|---|---|---|---|---|
| S₃ | 0 [exploratory] | 0 [exploratory] | 1 [Lean, catalog] | 1 [Lean, catalog] | 1 |
| S₄ | **0 [Lean]** | **0 [Lean]** | **1 [Lean]** | = unordered [Lean, structural] | 1 [Lean] |
| D₄ | **0 [Lean]** | **0 [Lean]** | **> 1 [Lean]** (39/16 − ¾·log₂3 + 5/64·log₂5 ≈ 1.430) | = unordered [Lean, structural] | 2 [Lean] |

[exploratory] Python output: `S3: I(c;T(p))=0 I(c;T(q))=0 I(c;sym)=1 I(c;ord)=1`,
`S4: I(c;T(p))=0 I(c;T(q))=0 I(c;sym)=1 I(c;ord)=1`.

Pattern: the residue of `N` is blind to each factor on its own, yet shares up to
`log₂[G:G']` bits with the *unordered pair*. All of the leaked information is synergistic.
This is now a theorem for every group (`semiprime_residue_blind_to_each_factor`,
`semiprime_residue_cap`).

## 2. Multi-prime wall, m + 1 = 3 factors, types in {0,…,4} pairwise distinct

[exploratory] 60 ordered tuples. H(argmin label) = 1.584963 = log₂3. I(label; sorted
multiset) = 0. I(label; sum of types mod 3) = 0. I(label; ordered tuple) = 1.584963.
The general statement `multiFactor_wall` is **[Lean]**.

## 3. OEIS
No integer sequence appears: the computed quantities are constants (0, 1, log₂(m+1)),
so an OEIS search is not applicable.

## 4. Counterexample hunt
- Tried: does the one-time pad fail in non-abelian groups? Enumerated S₃ and S₄ (all
  readouts of σ_p tested: cycle type and sign): no counterexample [exploratory]. Then
  proved for every group [Lean] (`frobenius_one_time_pad`).
- Tried: does the ordered-type channel ever exceed the unordered one? None of the six
  catalog fields does (catalog [Lean], numerical). Proved impossible for every group,
  every class function and every type readout [Lean]
  (`semiprime_whichFactor_wall_general`).
- Boundary: the pad breaks once the cofactor's Frobenius is revealed
  (`frobenius_pad_breaks_with_cofactor`, full log₂|A| bits) [Lean]. So the zero is an
  independence phenomenon, not a lack of entropy.
