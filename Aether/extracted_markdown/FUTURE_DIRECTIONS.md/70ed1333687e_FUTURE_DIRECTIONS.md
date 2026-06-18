# Future Directions: Tropical Geometric Representation Theory

## Conjecture 1: Full sl₂ Crystal Inverse Property

**Precise Statement:** For every binary word `w` of length `g` and every word `q`, the crystal raising operator satisfies `e(w) = q` if and only if the crystal lowering operator satisfies `f(q) = w`. More precisely, if `pos` is the rightmost unmatched down in `w`, then `pos` is the leftmost unmatched up in `w.set(pos, up)`.

**Test:** The inverse property has been computationally verified for all binary words of length ≤ 10 (2^10 = 1024 words). The formal proof reduces to two helper lemmas:
1. `rightmost_down_becomes_leftmost_up`: If pos is the rightmost unmatched down in w, then pos is the leftmost unmatched up in w[pos ↦ up].
2. `leftmost_up_becomes_rightmost_down`: The symmetric statement.

Both can be tested exhaustively and have been verified computationally. The formal proof requires tracking the bracket-matching state across a word modification, specifically showing that the upCount at the rightmost unmatched down position is 0, and that the suffix after this position has no unmatched downs.

**Refutation Criterion:** Any binary word `w` where `e(w) = q` but `f(q) ≠ w` would refute this. Exhaustive search up to length 10 has found no counterexample.

**Impact:** Completing this proof would give the full certified sl₂ Kashiwara crystal structure on binary words, yielding the first formally verified crystal in the tropical Brill-Noether setting.

---

## Conjecture 2: CDPR Paths Form a Demazure Subcrystal

**Precise Statement:** For rank r = 1, genus g, and starting height h ≥ 1, the set of valid CDPR paths (binary words staying non-negative) is closed under the crystal raising operator ẽ (proved) but NOT always closed under the lowering operator f̃. However, for h ≥ g/2, the CDPR paths form a full subcrystal (closed under both ẽ and f̃). For h < g/2, they form a Demazure subcrystal — a truncation of a full sl₂ crystal by a Weyl group element.

**Test:**
- Computationally enumerate CDPR paths for (g, h) ∈ {1,...,8} × {0,...,8}.
- For each (g, h), test whether every CDPR path `p` with `f(p) ≠ None` yields a valid CDPR path `f(p)`.
- Identify the critical height h*(g) where f-closure first holds.
- Verify: h*(g) = ⌈g/2⌉ for all tested cases.

**Refutation Criterion:** If CDPR paths with h ≥ g/2 are NOT closed under f̃ for some (g, h), the "full subcrystal" claim fails. If they ARE closed under f̃ for some h < ⌈g/2⌉, the critical height formula is wrong.

**Impact:** This would connect tropical divisor theory with Demazure module theory, opening the path to compute tropical Brill-Noether dimensions using Demazure character formulas.

---

## Conjecture 3: Type-A Crystal Extension for General Rank r

**Precise Statement:** For rank r ≥ 2 and the chain of g loops, the set of valid CDPR paths (walks in the Weyl chamber {x ∈ ℤʳ : x₁ > x₂ > ⋯ > xᵣ > 0}) admits candidate crystal operators eⱼ, fⱼ for j = 1, ..., r defined by the signature rule applied to the j-th and (j+1)-th coordinates. These operators satisfy:
- Weight shift: wt(eⱼ(p)) = wt(p) + αⱼ where αⱼ is the j-th simple root.
- Partial inverse: eⱼ(p) = q ↔ fⱼ(q) = p.
- Serre relations: eⱼ ∘ eₖ = eₖ ∘ eⱼ when |j - k| > 1.

**Test:** Implement the type-A signature rule for r = 2, 3 on CDPR paths of small genus g ≤ 6. For each (g, r, d):
1. Enumerate all valid Weyl-chamber paths.
2. Apply candidate operators eⱼ, fⱼ.
3. Check preservation, inverse, and Serre relations.

**Refutation Criterion:** Any violation of the Serre relations eⱼ ∘ eₖ = eₖ ∘ eⱼ for |j-k| > 1 would show that the naive coordinate-wise signature rule does not produce a type-A crystal.

**Impact:** If true, this extends the tropical crystal theory to sl_{r+1}, connecting tropical Brill-Noether theory for all ranks to Kashiwara crystal theory. This would imply that tropical divisor counts equal Kostka numbers.

---

## Conjecture 4: Crystal Character Equals Tropical Divisor Count

**Precise Statement:** For the chain of g loops with degree d and rank r = 1, the number of valid CDPR paths of weight λ equals the weight multiplicity m_λ in the crystal decomposition of B(1)^⊗g restricted to CDPR-valid paths. Specifically, the generating function

  ∑_{valid CDPR paths p} q^{wt(p)}

equals a sum of sl₂ characters:

  ∑_{components C} χ_{V(hw(C))}(q)

where the sum is over connected components C of the crystal restricted to CDPR paths, and hw(C) is the highest weight of C.

**Test:** For (g, start) ∈ {1,...,8} × {0,...,8}:
1. Enumerate CDPR paths and compute the weight generating function.
2. Decompose into crystal components.
3. Verify the character identity by comparing weight multiplicities.

**Refutation Criterion:** If the CDPR paths do not decompose into complete crystal strings (which happens when f̃ exits the CDPR set), the character formula needs modification. The test should identify whether truncated components still have characters equal to Demazure characters.

**Impact:** Establishes that tropical Brill-Noether counting is literally representation-theoretic: counting divisors = computing weight multiplicities.

---

## Conjecture 5: Tropical RSK Correspondence

**Precise Statement:** There exists an explicit bijection (a "tropical RSK correspondence") between:
- CDPR paths of genus g, degree d, and rank r on chains of loops, and
- Pairs (P, Q) where P is a semistandard Young tableau of shape λ(g, d, r) with entries in {1, ..., r+1}, and Q is a standard Young tableau of the same shape.

Under this bijection:
- The crystal operators eⱼ, fⱼ on CDPR paths correspond to the standard crystal operators on semistandard tableaux.
- The chip-firing equivalence classes of CDPR paths correspond to pairs with the same Q-tableau.
- The rank of the divisor encoded by a CDPR path equals the number of columns of λ.

**Test:** For r = 1 and small g:
1. Enumerate CDPR paths and semistandard tableaux.
2. Attempt to construct a weight-preserving, crystal-equivariant bijection.
3. Verify that the bijection intertwines crystal operators.

**Refutation Criterion:** If no weight-preserving bijection exists (the multisets of weights differ), the correspondence cannot exist in the stated form. If a bijection exists but does not intertwine crystal operators, the RSK interpretation fails.

**Impact:** Would provide a complete combinatorial dictionary between tropical divisor theory and classical representation theory, unifying two major branches of algebraic combinatorics.
