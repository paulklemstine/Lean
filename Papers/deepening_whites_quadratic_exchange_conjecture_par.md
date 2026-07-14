# Computational Evidence — White's Quadratic Exchange (Part 3), deepening

All checks below were performed with Lean's `#eval` / `decide` on concrete finite
instances before the formal theorems were stated, and each is now backed by a
`sorry`-free Lean theorem in this directory.

## 1. Rank-1 determinism (basis of `whitePart3_rank1`)

For the rank-1 uniform matroid `U_{1,n}` a configuration is a multiset of
singletons. Its total multiset union is just the multiset of chosen elements, and
mapping each element back to its singleton recovers the configuration:

    C = ({0} ::ₘ {1} ::ₘ {1} ::ₘ 0)   -- Fin 3
    unionMS C = {0, 1, 1}
    (unionMS C).map (fun a => {a}) = {0} ::ₘ {1} ::ₘ {1} ::ₘ 0 = C   ✓

Hence for rank 1 the multiset union *determines* the configuration, so equal union
⇒ equal configuration ⇒ (trivially) reachable. Verified on several `n` and
multiplicities; formalized as `rank1_config_eq_map` and `whitePart3_rank1`.

## 2. The redistribution realization formula (basis of `uniform_redistribute`)

Claim: for `r`-subsets `B₁, B₂` and any `r`-subset `C₁` with
`B₁ ∩ B₂ ⊆ C₁ ⊆ B₁ ∪ B₂`, the set

    C₂ := (B₁ ∪ B₂) \ (C₁ \ (B₁ ∩ B₂))

is again an `r`-subset with `B₁.val + B₂.val = C₁.val + C₂.val`.

Concrete check in `U_{3,6}`:

    B₁ = {0,1,2}, B₂ = {2,3,4}   (r = 3, B₁∩B₂ = {2})
    C₁ = {0,2,3}                 (contains {2}, ⊆ {0,1,2,3,4})
    C₂ = {1,2,4}                 -- computed by the formula
    #C₂ = 3                                                      ✓
    B₁.val + B₂.val = {0,1,2,2,3,4} = C₁.val + C₂.val            ✓ (decide)

Tested on further triples; the intersection-splitting hypothesis
`B₁ ∩ B₂ ⊆ C₁` is exactly what is needed for the leftover to be repetition-free.
Formalized as `uniform_redistribute`.

## 3. Two-basis White (basis of `uniform_whitePart3_two`)

The three perfect matchings of `U_{2,4}`,

    {0,1},{2,3}   {0,2},{1,3}   {0,3},{1,2}

all share the union `{0,1,2,3}` and are pairwise one quadratic move apart
(`decide` on the multiset identity). This is the smallest case with genuine
content and matches `Uniform.U24_matchings_rreachable`; the general two-basis
statement of any rank is `uniform_whitePart3_two`.

## 4. Counterexample hunt / boundary

- **Rank 0 is a genuine boundary.** `U_{0,n}` has the single basis `∅`; every
  configuration has union `0`, but two configurations of different sizes have
  equal union yet different `card`, and reachability preserves `card`. So White's
  Part 3 as "equal union ⇒ reachable" is *false* for `r = 0`; for `r ≥ 1` the
  union determines the card (`card(union) = r · #config`), removing the obstruction.
  All theorems here are stated for `r ≥ 1`-relevant families or are `card`-safe.
- No counterexample was found to the two-basis or rank-1 statements on any tested
  instance, consistent with the proved theorems.

## OEIS

No new integer sequence is central to this deepening (the objects are
configurations/relations, not a counting sequence), so no OEIS lookup applies.
The number of bases of `U_{2,4}` is `C(4,2)=6` (`Uniform.lean` example), a
binomial coefficient, not a novel sequence.
