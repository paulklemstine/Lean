import MachineLearning.CayleyCensusMoments

/-!
# Beyond group symmetry: graph automorphisms, and the failure of the converse

`MachineLearning.CayleyCensusInvariance` shows that the census
`walkCount S n g` is invariant under inversion and under `S`-preserving group
automorphisms.  Two natural questions remain, and both are settled here.

**Is group symmetry the only source of census invariance?**  No.  The census is
invariant under every *graph* automorphism of `Cay(G, S)` fixing the identity —
a strictly larger supply of symmetries in general, since such a permutation need
not respect the multiplication of `G` at all.  This is `walkCount_graphAut`,
proved through the adjacency-power bridge `walkCount_eq_adj_pow`: the inductive
step is a reindexing of the intermediate vertex along the permutation.  The
group-automorphism theorem is recovered as the corollary
`walkCount_mulAut_of_graphAut`.

**Is the converse of the main theorem true — do equal census rows force census
equivalence?**  No, and the failure is already visible in a group of order 8.
For `G = ℤ/8` (written multiplicatively) with connection set the four odd
residues, `Cay(G, S)` is the complete bipartite graph `K₄,₄`.  Its census has
exactly two distinct rows,

`n = 0..4`:  `[1,0,0,0,0,0,0,0]`, `[0,1,0,1,0,1,0,1]`, `[4,0,4,0,4,0,4,0]`,
`[0,16,0,16,0,16,0,16]`, `[64,0,64,0,64,0,64,0]`,

whereas `⟨inversion, Aut(G,S)⟩` has four orbits `{0}, {4}, {2,6}, {1,3,5,7}`.
Concretely `2` and `4` have identical censuses but are *not* census-equivalent:
`4` is an involution and `2` is not, and `CensusEquiv_sq_eq_one_iff` shows that
census equivalence must preserve being an involution.  The extra coincidence is
explained instead by the transposition `(2 4)`, a graph automorphism of `K₄,₄`
fixing the identity that is not induced by any group automorphism.

## Main results

* `adjPow_graphAut`, `walkCount_graphAut`
* `walkCount_mulAut_of_graphAut`
* `CensusEquiv_sq_eq_one_iff`
* `census_eq_but_not_censusEquiv` — the converse of the invariance theorem is
  false; the census orbits are strictly coarser than the `⟨inv, Aut(G,S)⟩`
  orbits.
-/

namespace CayleyCensus

variable {G : Type*} [Group G] [Fintype G] [DecidableEq G]

/-! ### Invariance under graph automorphisms fixing the identity -/

/-- A permutation of `G` preserving the `S`-step relation preserves all entries
of all adjacency powers. -/
theorem adjPow_graphAut {S : Finset G} (φ : G ≃ G)
    (hstep : ∀ x y : G, ((φ x)⁻¹ * φ y ∈ S ↔ x⁻¹ * y ∈ S)) (n : ℕ) (x y : G) :
    (adj S ^ n) (φ x) (φ y) = (adj S ^ n) x y := by
  have hadj : ∀ x y : G, adj S (φ x) (φ y) = adj S x y := by
    intro x y
    show (if (φ x)⁻¹ * φ y ∈ S then 1 else 0) = if x⁻¹ * y ∈ S then 1 else 0
    exact if_congr (hstep x y) rfl rfl
  induction n generalizing x y with
  | zero =>
      simp only [pow_zero, Matrix.one_apply, φ.injective.eq_iff]
  | succ n ih =>
      rw [pow_succ']
      simp only [Matrix.mul_apply]
      rw [← Equiv.sum_comp φ (fun z => adj S (φ x) z * (adj S ^ n) z (φ y))]
      exact Finset.sum_congr rfl fun z _ => by rw [hadj, ih]

/-- **Census invariance under graph automorphisms.**  If `φ` permutes `G`, fixes
the identity, and preserves adjacency in `Cay(G, S)`, then it preserves the whole
census.  This is strictly stronger than `walkCount_mulAut`: `φ` is not assumed to
be compatible with the group law. -/
theorem walkCount_graphAut {S : Finset G} (φ : G ≃ G) (hone : φ 1 = 1)
    (hstep : ∀ x y : G, ((φ x)⁻¹ * φ y ∈ S ↔ x⁻¹ * y ∈ S)) (n : ℕ) (g : G) :
    walkCount S n (φ g) = walkCount S n g := by
  have h1 : walkCount S n (φ g) = (adj S ^ n) (φ 1) (φ g) := by
    rw [walkCount_eq_adj_pow, hone, inv_one, one_mul]
  have h2 : (adj S ^ n) 1 g = walkCount S n g := by
    rw [walkCount_eq_adj_pow, inv_one, one_mul]
  rw [h1, adjPow_graphAut φ hstep, h2]

/-- The group-automorphism invariance is the special case of the graph
version in which `φ` is a multiplicative equivalence preserving `S`. -/
theorem walkCount_mulAut_of_graphAut {S : Finset G} {σ : MulAut G}
    (h : Preserves σ S) (n : ℕ) (g : G) : walkCount S n (σ g) = walkCount S n g := by
  refine walkCount_graphAut σ.toEquiv (by simp) (fun x y => ?_) n g
  have hrw : (σ x)⁻¹ * σ y = σ (x⁻¹ * y) := by simp
  show ((σ x)⁻¹ * σ y ∈ S ↔ x⁻¹ * y ∈ S)
  rw [hrw]
  exact h _

/-! ### An invariant of census equivalence -/

omit [Fintype G] [DecidableEq G] in
/-- Census-equivalent elements are simultaneously involutions or not: both
inversion and group automorphisms preserve the equation `g ^ 2 = 1`.  This gives
a computable obstruction to census equivalence. -/
theorem CensusEquiv_sq_eq_one_iff {S : Finset G} {g h : G} (hgh : CensusEquiv S g h) :
    g ^ 2 = 1 ↔ h ^ 2 = 1 := by
  induction hgh with
  | refl => exact Iff.rfl
  | @inv h _ ih =>
      refine ih.trans ⟨fun hh => ?_, fun hh => ?_⟩
      · rw [inv_pow, hh, inv_one]
      · rwa [inv_pow, inv_eq_one] at hh
  | @aut h σ _ _ ih =>
      refine ih.trans ⟨fun hh => ?_, fun hh => ?_⟩
      · rw [← map_pow, hh, map_one]
      · rw [← map_pow] at hh
        exact (map_eq_one_iff σ σ.injective).mp hh

/-! ### The converse fails: `K₄,₄` as a Cayley graph on `ℤ/8` -/

open Multiplicative

/-- `ℤ/8` written multiplicatively. -/
abbrev Z8 := Multiplicative (ZMod 8)

/-- The four odd residues; the resulting Cayley graph is `K₄,₄`. -/
def oddSet : Finset Z8 := {ofAdd 1, ofAdd 3, ofAdd 5, ofAdd 7}

theorem oddSet_invClosed : InvClosed oddSet := by decide

/-- The transposition exchanging `2` and `4`.  It fixes the identity and
preserves the bipartition of `K₄,₄`, hence is a graph automorphism; it is not a
group automorphism, since `2` and `4` have different orders. -/
def swap24 : Z8 ≃ Z8 := Equiv.swap (ofAdd (2 : ZMod 8)) (ofAdd (4 : ZMod 8))

theorem swap24_one : swap24 (1 : Z8) = 1 := by decide

theorem swap24_step (x y : Z8) :
    ((swap24 x)⁻¹ * swap24 y ∈ oddSet ↔ x⁻¹ * y ∈ oddSet) := by
  revert x y
  decide

/-- The census cannot distinguish `2` from `4` in `Cay(ℤ/8, odd)`. -/
theorem oddSet_census_two_eq_four (n : ℕ) :
    walkCount oddSet n (ofAdd (2 : ZMod 8)) = walkCount oddSet n (ofAdd (4 : ZMod 8)) := by
  have hmap : swap24 (ofAdd (4 : ZMod 8)) = ofAdd (2 : ZMod 8) := by decide
  rw [← hmap, walkCount_graphAut swap24 swap24_one swap24_step]

/-- **The converse of the invariance theorem is false.**  In `Cay(ℤ/8, odd)` the
elements `2` and `4` have identical censuses at every length, yet they are not
census-equivalent: `4` is an involution and `2` is not, and census equivalence
preserves that property.  Hence the orbits of `⟨inversion, Aut(G,S)⟩` are a
strict refinement of the level sets of the census, and the bound
`card_census_image_le` can be strict. -/
theorem census_eq_but_not_censusEquiv :
    (∀ n, walkCount oddSet n (ofAdd (2 : ZMod 8))
        = walkCount oddSet n (ofAdd (4 : ZMod 8))) ∧
      ¬ CensusEquiv oddSet (ofAdd (2 : ZMod 8)) (ofAdd (4 : ZMod 8)) := by
  refine ⟨oddSet_census_two_eq_four, fun hc => ?_⟩
  have h4 : (ofAdd (4 : ZMod 8) : Z8) ^ 2 = 1 := by decide
  have h2 : ¬ ((ofAdd (2 : ZMod 8) : Z8) ^ 2 = 1) := by decide
  exact h2 ((CensusEquiv_sq_eq_one_iff hc).mpr h4)

end CayleyCensus