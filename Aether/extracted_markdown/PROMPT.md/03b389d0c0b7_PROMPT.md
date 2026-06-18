Produce a single complete Lean 4 file formalizing an explicit toy model of Schubert calculus for Gr(2,4) and Gr(2,5), with no placeholders, no unrelated code, and no claims beyond what is proved.

Target: a self-contained algebraic formalization in concrete polynomial quotient rings, not a general development of Grassmannians, intersection theory, or flag varieties.

Scope requirements:
1. Work with the polynomial ring Z[c1,c2] (for example via MvPolynomial over a two-element variable type, or another clean concrete encoding available in Mathlib).
2. Define the complete homogeneous polynomials h_k in two variables by recursion:
   - h_0 = 1
   - h_1 = c1
   - h_{k+2} = c1 * h_{k+1} - c2 * h_k
   Prove the first few explicit formulas needed downstream (at least h_2, h_3, h_4, h_5).
3. For Gr(2,4), define the quotient ring R4 := Z[c1,c2]/(h_3,h_4). For Gr(2,5), define R5 := Z[c1,c2]/(h_4,h_5). Use whatever quotient-by-ideal API in Mathlib is most robust, but keep the construction explicit and local.
4. Define explicit Schubert classes only for the partitions needed in these two cases. For example, in terms of the quotient images of concrete polynomials:
   - sigma1 = c1
   - sigma2 = h_2
   - sigma11 = c2
   - sigma3 = h_3 when working before quotient / or its image where meaningful
   - sigma21 = c1*c2
   - sigma22 = c2^2
   - sigma31, sigma32, sigma33 similarly as explicit polynomial classes if needed in R5
   Use only definitions you will actually use.
5. Prove concrete identities, split by ring:
   In R4:
   - Giambelli-style identity sigma2 = sigma1^2 - sigma11
   - Pieri identity sigma1 * sigma1 = sigma2 + sigma11
   - Pieri identity sigma1 * sigma2 = sigma21
   - Pieri identity sigma1 * sigma11 = sigma21
   - sigma1^4 = 2 * sigma22
   - optionally derive sigma2^2 = sigma22 and/or sigma21 * sigma1 = 2 * sigma22 if convenient
   In R5:
   - analogous explicit identities among sigma1, sigma2, sigma11, sigma3, sigma21, sigma22, sigma31, sigma32, sigma33 as far as needed
   - sigma1^6 = 5 * sigma33
6. If quotient-ring calculations are awkward, it is acceptable to prove polynomial congruence modulo the defining ideal and then restate as equality in the quotient. But every theorem should be fully proved in Lean.
7. Include only a modest module docstring accurately describing the file as a finite explicit formalization for Gr(2,4) and Gr(2,5). Do not claim a complete solution to Hilbert 15 or general Schubert calculus.

Implementation guidance:
- Favor small explicit computations over abstract generality.
- Prefer ring_nf, simp, and direct ideal-membership lemmas with explicit witnesses.
- Define every symbol before use; avoid undeclared names like sigma2, sigma11, grIdeal, cls.
- Do not include any unrelated fragments from other projects.
- The file must compile with zero sorries.

Deliverable standard:
A researcher should be able to open the file and see a coherent finite formalization of enumerative identities in Gr(2,4) and Gr(2,5), with all theorem bodies present and no declaration-only artifacts.