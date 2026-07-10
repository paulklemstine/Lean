import Mathlib
import Shared.KruskalKatonaShadow

/-!
# Knots and Lattices, I: monotone lattice paths as a combinatorial substrate

This file develops the elementary combinatorics of **monotone lattice paths** from
`(0,0)` to `(n,n)`, the geometric objects that the state-sum picture of the
Alexander polynomial is conjectured to enumerate.

A monotone lattice path from `(0,0)` to `(n,n)` consists of `2n` unit steps, `n`
of them East and `n` of them North.  Recording *which* of the `2n` steps go North
identifies such a path with an `n`-element subset of `Fin (2*n)`.  Under this
dictionary:

* the total number of paths is the central binomial coefficient `C(2n, n)`;
* the family of all paths is `n`-uniform, so the Kruskal–Katona theorem applies
  to any sub-family and forces a *large shadow of sub-paths* whenever the
  sub-family itself is large.

The last statement is the bridge to extremal set theory: it says a dense family
of `n`-step paths cannot avoid having many `(n-1)`-step "predecessors".

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): monotone paths `(0,0) → (n,n)` are exactly the
  `n`-subsets of the `2n` step slots; hence their count is `C(2n,n)` and the
  family is `n`-uniform, opening the door to Kruskal–Katona shadow bounds.
Experiment (Experimenter): `latticePaths n := powersetCard n univ`; the count is
  `card_powersetCard` composed with `Fintype.card_fin`; uniformity is
  `mem_powersetCard`.  The shadow bound is a direct specialization of the
  catalog result `shadow_card_ge`.
Analysis (Analyst): the encoding is a genuine bijection with paths, and the
  shadow of a path family is precisely the family of paths obtained by deleting
  one North step (moving the endpoint from `(n,n)` toward the diagonal).
Critique (Critic): the shadow bound needs `1 ≤ n ≤ k ≤ 2n` and uniformity;
  these are inherited from Kruskal–Katona and are load-bearing.  Nothing here is
  `decide`-only: the count uses `powersetCard` algebra and the bound routes
  through the deep Kruskal–Katona theorem.
Synthesis (PI): lattice paths ≅ uniform set family ⇒ counting `C(2n,n)` and a
  Kruskal–Katona shadow bound for path sub-families.
-/

open Finset
open scoped FinsetFamily

namespace KnotLattice

/-- **Monotone lattice paths** from `(0,0)` to `(n,n)`, encoded by the set of
positions (among the `2n` steps) at which the path goes North.  These are exactly
the `n`-element subsets of `Fin (2*n)`. -/
def latticePaths (n : ℕ) : Finset (Finset (Fin (2 * n))) :=
  (univ : Finset (Fin (2 * n))).powersetCard n

/-- A path family element has exactly `n` North steps. -/
theorem mem_latticePaths {n : ℕ} {S : Finset (Fin (2 * n))} :
    S ∈ latticePaths n ↔ S.card = n := by
  simp [latticePaths, mem_powersetCard]

/-- **Counting paths.** There are exactly `C(2n, n)` monotone lattice paths from
`(0,0)` to `(n,n)`. -/
theorem card_latticePaths (n : ℕ) : (latticePaths n).card = (2 * n).choose n := by
  rw [latticePaths, card_powersetCard, card_univ, Fintype.card_fin]

/-- The family of all paths is `n`-uniform. -/
theorem latticePaths_sized (n : ℕ) :
    ((latticePaths n : Finset (Finset (Fin (2 * n)))) :
      Set (Finset (Fin (2 * n)))).Sized n := by
  intro S hS
  rw [Finset.mem_coe] at hS
  exact mem_latticePaths.mp hS

/-- Any sub-family of paths is `n`-uniform. -/
theorem subfamily_sized {n : ℕ} {𝒜 : Finset (Finset (Fin (2 * n)))}
    (hsub : 𝒜 ⊆ latticePaths n) :
    ((𝒜 : Finset (Finset (Fin (2 * n)))) : Set (Finset (Fin (2 * n)))).Sized n := by
  intro S hS
  rw [Finset.mem_coe] at hS
  exact mem_latticePaths.mp (hsub hS)

/-- **Kruskal–Katona for lattice paths.** If a family `𝒜` of `n`-step paths has at
least `C(k, n)` members (with `1 ≤ n ≤ k ≤ 2n`), then the family of its
`(n-1)`-step sub-paths (the shadow) has at least `C(k, n-1)` members.

This is the extremal-combinatorics counterpart of the topological state sum: a
dense family of knot states forces a dense family of "lower" states. It is a
direct application of the catalog's single-shadow Kruskal–Katona bound. -/
theorem latticePaths_shadow_lower_bound {n k : ℕ}
    (𝒜 : Finset (Finset (Fin (2 * n)))) (hsub : 𝒜 ⊆ latticePaths n)
    (hn : 1 ≤ n) (hnk : n ≤ k) (hk : k ≤ 2 * n)
    (hsize : k.choose n ≤ 𝒜.card) :
    k.choose (n - 1) ≤ (∂ 𝒜).card := by
  have hsz := subfamily_sized hsub
  exact shadow_card_ge hn hnk hk hsz hsize

end KnotLattice