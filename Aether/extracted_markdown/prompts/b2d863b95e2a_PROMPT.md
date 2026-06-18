Build on this cycle’s existing Rips-profile development, not on the accidental information-geometry scaffold. The goal is to complete a self-contained formalization of edge-count profiles of finite metric spaces and their functorial monotonicity into the tropical valuation object already suggested by `Core.lean` and `Functoriality.lean`.

Problem focus:
1. Define for a finite metric space `X` with decidable equality and finite type, and for a real threshold `r`, the number `edgeCount X r` of unordered pairs `{x,y}` with `x ≠ y` and `dist x y ≤ r`. If the existing code uses an equivalent oriented-edge or normalized convention, keep that convention and prove translation lemmas.
2. Define the profile `ripsProfile X : ℝ → ℝ` (or into the existing `tropicalization_base`) by this edge count, optionally normalized by the constant total number of possible edges. Prove it is monotone in `r`.
3. For an injective nonexpanding map `f : X → Y`, prove edge monotonicity at every scale: every edge of `Rips(X,r)` maps to an edge of `Rips(Y,r)`. Deduce `edgeCount X r ≤ edgeCount Y r` pointwise, and package this as the existing domination morphism (`RipsProfileDomination` or equivalent).
4. Prove a sharp step-structure theorem for finite spaces: for `r < s`, `edgeCount X r < edgeCount X s` iff there exists an unordered pair `(x,y)` with `r < dist x y ≤ s`. Equivalently, if no pairwise distance lies in `(r,s]`, then the profile is constant on that interval. This is the right formal substitute for the earlier vague “strict monotonicity across critical scales”.
5. If convenient, define the finite set or multiset of realized pairwise distances and prove the profile changes only at those values. Extract an algorithmic corollary: sorting the distinct pairwise distances determines the entire step profile.

Requirements:
- Keep the development fully finite/combinatorial; do not introduce differential, measure-theoretic, or information-geometric abstractions.
- Reuse the exact object/morphism interfaces already present in `Core.lean` and `Functoriality.lean` where possible.
- Prefer simple lemmas about finite sets, pair counting, and `dist` inequalities.
- Avoid placeholders and unrelated declarations; produce a coherent file set centered on Rips graphs.

Suggested theorem list (adapt names to the existing codebase):
- `edgeCount_mono`
- `map_edge_of_nonexpanding`
- `edgeCount_le_of_injective_nonexpanding`
- `ripsProfile_domination_of_injective_nonexpanding`
- `edgeCount_strict_increase_iff_exists_pair`
- `edgeCount_const_on_interval_iff_no_new_distances`
- `ripsProfile_determined_by_pairwiseDistances`

Why now? The object map and domination morphism were already partially built in `Core.lean` and `Functoriality.lean`; the missing work is a finite combinatorial closure of that program, and it should be tractable with existing Mathlib support for finite types, sums, and metric spaces.