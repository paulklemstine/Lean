/-
# The diagonal part `MH_{2,2}` of the magnitude homology of tope graphs

This file continues `Geometry/MagnitudeTopeGraphs.lean`, where the magnitude chain
generators `Gen1`, `Gen2`, the differential `δ₂`, the tope graph of the coordinate
arrangement in `ℝⁿ` and its Cayley-graph model were introduced, and where the group of
`(2,2)`-cycles was identified up to a splitting.  Here we finish that computation:

7. **Degree-3 chains.** `Gen3 G ℓ` is empty for `ℓ < 3`; consequently *any* differential
   `δ₃` into the `(2,2)`-cycles is zero, and therefore
   `MH_{2,2}(G) = ker δ₂` (`MH22_equiv_cycles`).

8. **The rank of the cycles.** For a connected graph with finitely many chains,
   `rk (ker δ₂) + #Gen1 = #Gen2` in every length `ℓ ≥ 2`
   (`finrank_ker_delta2_add`), because `δ₂` is surjective onto a free module.

9. **The bidegree `(2,2)` magnitude homology of the tope graph.** Combining 8 with the
   counts `#Gen1 = 2ⁿ·C(n,2)` and `#Gen2 = 2ⁿ·n²` and the identity
   `C(n,2) + C(n+1,2) = n²`, we get
   `MH_{2,2}(topeGraph n) ≅ ℤ^{2ⁿ·C(n+1,2)}`,
   i.e. the rank is `2ⁿ` times `C(n+1,2)`, the value at degree `2` of the Hilbert
   function of the polynomial ring in `n` variables — the Stanley–Reisner ring of the
   simplex attached to each tope of the Boolean arrangement.

10. **Transport to the Coxeter Cayley graph.** Magnitude chains in degree 2 and the
    differential `δ₂` are natural under graph isomorphisms, so the same computation holds
    for the Cayley graph of the Coxeter group `(ℤ/2)ⁿ`.

Everything is self-contained: only `Mathlib` and the companion file are imported.
-/

import Mathlib
import Geometry.MagnitudeTopeGraphs

namespace MagnitudeTope

open scoped Classical

/-! ## 7. Degree-3 chains vanish in length 2, so `MH_{2,2} = ker δ₂` -/

section Degree3

variable {V : Type*} {G : SimpleGraph V}

/-- Generators of the magnitude chain group `MC_{3,ℓ}(G)`: quadruples of vertices with
consecutive entries distinct and total length `ℓ`. -/
def Gen3 (G : SimpleGraph V) (ℓ : ℕ) : Type _ :=
  {p : V × V × V × V // p.1 ≠ p.2.1 ∧ p.2.1 ≠ p.2.2.1 ∧ p.2.2.1 ≠ p.2.2.2 ∧
      G.dist p.1 p.2.1 + G.dist p.2.1 p.2.2.1 + G.dist p.2.2.1 p.2.2.2 = ℓ}

/-- Magnitude chains in degree 3 vanish in lengths `< 3`. -/
lemma Gen3_isEmpty_of_lt (hG : G.Connected) {ℓ : ℕ} (h : ℓ < 3) : IsEmpty (Gen3 G ℓ) := by
  constructor
  rintro ⟨⟨x, y, z, w⟩, h1, h2, h3, h4⟩
  have := dist_pos_of_ne hG h1
  have := dist_pos_of_ne hG h2
  have := dist_pos_of_ne hG h3
  omega

/-- Any linear map out of the degree-3 chains of length `< 3` is zero. -/
theorem delta3_range_eq_bot (hG : G.Connected) {ℓ : ℕ} (h : ℓ < 3) {M : Type*}
    [AddCommGroup M] [Module ℤ M] (d : (Gen3 G ℓ →₀ ℤ) →ₗ[ℤ] M) :
    LinearMap.range d = ⊥ := by
  rw [Submodule.eq_bot_iff]
  rintro x ⟨y, rfl⟩
  have hy : y = 0 := by ext a; exact ((Gen3_isEmpty_of_lt hG h).false a).elim
  simp [hy]

/-- **`MH_{2,2}(G)` is the group of `(2,2)`-cycles.**  Whatever the degree-3 part `d` of
the magnitude differential is, it vanishes in length `2` because there are no `(3,2)`
chains; hence the homology at the `(2,2)` spot is the full cycle group. -/
noncomputable def MH22_equiv_cycles (hG : G.Connected)
    (d : (Gen3 G 2 →₀ ℤ) →ₗ[ℤ] (LinearMap.ker (delta2 hG 2)))
    (N : Submodule ℤ (LinearMap.ker (delta2 hG 2))) (hN : N = LinearMap.range d) :
    ((LinearMap.ker (delta2 hG 2)) ⧸ N) ≃ₗ[ℤ] (LinearMap.ker (delta2 hG 2)) :=
  Submodule.quotEquivOfEqBot _ (by rw [hN]; exact delta3_range_eq_bot hG (by norm_num) d)

end Degree3

/-! ### Finiteness of the chain groups of a finite graph -/

section Finiteness

variable {V : Type*} [Finite V] (G : SimpleGraph V) (ℓ : ℕ)

instance instFiniteGen1 : Finite (Gen1 G ℓ) := Subtype.finite

instance instFiniteGen2 : Finite (Gen2 G ℓ) := Subtype.finite

instance instFiniteGen3 : Finite (Gen3 G ℓ) := Subtype.finite

end Finiteness

/-! ## 8. The rank of the `(2,ℓ)`-cycles of a finite graph -/

section Rank

variable {V : Type*} {G : SimpleGraph V}

/-- **Rank of the cycle group.** For `ℓ ≥ 2` the differential `δ₂` is surjective onto the
free module on `Gen1 G ℓ`, so the chain group splits and the ranks add up. -/
theorem finrank_ker_delta2_add (hG : G.Connected) {ℓ : ℕ} (h : 2 ≤ ℓ)
    [Finite (Gen1 G ℓ)] [Finite (Gen2 G ℓ)] :
    Module.finrank ℤ (LinearMap.ker (delta2 hG ℓ)) + Nat.card (Gen1 G ℓ)
      = Nat.card (Gen2 G ℓ) := by
  classical
  obtain ⟨e⟩ := chain_split hG h
  haveI : Fintype (Gen1 G ℓ) := Fintype.ofFinite _
  haveI : Fintype (Gen2 G ℓ) := Fintype.ofFinite _
  have h1 : Module.finrank ℤ (Gen1 G ℓ →₀ ℤ) = Nat.card (Gen1 G ℓ) := by
    rw [Module.finrank_finsupp_self, Nat.card_eq_fintype_card]
  have h2 : Module.finrank ℤ (Gen2 G ℓ →₀ ℤ) = Nat.card (Gen2 G ℓ) := by
    rw [Module.finrank_finsupp_self, Nat.card_eq_fintype_card]
  have h3 := e.finrank_eq
  rw [Module.finrank_prod, h1, h2] at h3
  exact h3

/-- A finitely generated free `ℤ`-module is the free module on `Fin` of its rank. -/
theorem free_of_finrank_eq {M : Type*} [AddCommGroup M] [Module ℤ M] [Module.Free ℤ M]
    [Module.Finite ℤ M] {r : ℕ} (hr : Module.finrank ℤ M = r) :
    Nonempty (M ≃ₗ[ℤ] (Fin r →₀ ℤ)) := by
  subst hr
  exact ⟨(Module.finBasis ℤ M).repr⟩

end Rank

/-! ## 9. `MH_{2,2}` of the tope graph -/

section TopeDiagonal

variable {n : ℕ}

/-- The arithmetic identity behind the Hilbert-function description:
`C(n,2) + C(n+1,2) = n²`. -/
theorem choose_two_add_choose_two (n : ℕ) : n.choose 2 + (n + 1).choose 2 = n * n := by
  induction n with
  | zero => rfl
  | succ m ih =>
    have h1 : (m + 1).choose 2 = m + m.choose 2 := Nat.choose_succ_succ m 1 ▸ by
      simp [Nat.choose_one_right]
    have h2 : (m + 1 + 1).choose 2 = (m + 1) + (m + 1).choose 2 :=
      Nat.choose_succ_succ (m + 1) 1 ▸ by simp [Nat.choose_one_right]
    have h3 : (m + 1) * (m + 1) = m * m + 2 * m + 1 := by ring
    omega

/-- **The rank of `MH_{2,2}` of the tope graph of the coordinate arrangement in `ℝⁿ` is
`2ⁿ · C(n+1,2) = 2ⁿ · n(n+1)/2`** — that is, `2ⁿ` times the value at degree `2` of the
Hilbert function of the polynomial ring in the `n` hyperplanes. -/
theorem topeMH22_finrank (n : ℕ) :
    Module.finrank ℤ (LinearMap.ker (delta2 (topeGraph_connected n) 2))
      = 2 ^ n * (n + 1).choose 2 := by
  have h := finrank_ker_delta2_add (topeGraph_connected n) (le_refl 2)
  rw [card_tope_gen1 n 2 (by norm_num), card_tope_gen2 n,
    ← choose_two_add_choose_two n, Nat.mul_add] at h
  omega

/-- **`MH_{2,2}` of the tope graph is free abelian of rank `2ⁿ · C(n+1,2)`.** -/
theorem topeMH22_free (n : ℕ) :
    Nonempty (LinearMap.ker (delta2 (topeGraph_connected n) 2) ≃ₗ[ℤ]
      (Fin (2 ^ n * (n + 1).choose 2) →₀ ℤ)) :=
  free_of_finrank_eq (topeMH22_finrank n)

end TopeDiagonal

/-! ## 10. Transport along graph isomorphisms, and the Coxeter Cayley graph -/

section Transport

variable {V W : Type*} {G : SimpleGraph V} {H : SimpleGraph W}

/-- Degree-2 magnitude chain generators are transported along a graph isomorphism. -/
def genEquiv2 (e : G ≃g H) (ℓ : ℕ) : Gen2 G ℓ ≃ Gen2 H ℓ where
  toFun g := ⟨(e g.1.1, e g.1.2.1, e g.1.2.2), by
      simpa using (e.toEquiv.injective.ne_iff).mpr g.2.1, by
      simpa using (e.toEquiv.injective.ne_iff).mpr g.2.2.1, by
      rw [iso_dist_eq, iso_dist_eq]; exact g.2.2.2⟩
  invFun g := ⟨(e.symm g.1.1, e.symm g.1.2.1, e.symm g.1.2.2), by
      simpa using (e.symm.toEquiv.injective.ne_iff).mpr g.2.1, by
      simpa using (e.symm.toEquiv.injective.ne_iff).mpr g.2.2.1, by
      rw [iso_dist_eq, iso_dist_eq]; exact g.2.2.2⟩
  left_inv g := by apply Subtype.ext; simp
  right_inv g := by apply Subtype.ext; simp

/-- **Naturality of the magnitude differential.** -/
theorem delta2_naturality (e : G ≃g H) (hG : G.Connected) (hH : H.Connected) (ℓ : ℕ) :
    (Finsupp.lmapDomain ℤ ℤ (genEquiv1 e ℓ)).comp (delta2 hG ℓ)
      = (delta2 hH ℓ).comp (Finsupp.lmapDomain ℤ ℤ (genEquiv2 e ℓ)) := by
  refine Finsupp.lhom_ext' fun g => LinearMap.ext_ring ?_
  simp only [LinearMap.comp_apply, Finsupp.lsingle_apply, Finsupp.lmapDomain_apply,
    Finsupp.mapDomain_single, delta2, Finsupp.linearCombination_single, one_smul]
  obtain ⟨⟨x, y, z⟩, h1, h2, h3⟩ := g
  simp only [delta2gen, genEquiv2, Equiv.coe_fn_mk]
  by_cases hc : G.dist x z = G.dist x y + G.dist y z
  · rw [dif_pos hc, dif_pos (by rw [iso_dist_eq, iso_dist_eq, iso_dist_eq]; exact hc)]
    rw [Finsupp.mapDomain_single]
    congr 1
  · rw [dif_neg hc, dif_neg (by rw [iso_dist_eq, iso_dist_eq, iso_dist_eq]; exact hc)]
    simp

/-- The `(2,ℓ)`-cycles are isomorphic along a graph isomorphism. -/
theorem ker_delta2_equiv (e : G ≃g H) (hG : G.Connected) (hH : H.Connected) (ℓ : ℕ) :
    Nonempty (LinearMap.ker (delta2 hG ℓ) ≃ₗ[ℤ] LinearMap.ker (delta2 hH ℓ)) := by
  set E1 : (Gen1 G ℓ →₀ ℤ) ≃ₗ[ℤ] (Gen1 H ℓ →₀ ℤ) := Finsupp.domLCongr (genEquiv1 e ℓ) with hE1
  set E2 : (Gen2 G ℓ →₀ ℤ) ≃ₗ[ℤ] (Gen2 H ℓ →₀ ℤ) := Finsupp.domLCongr (genEquiv2 e ℓ) with hE2
  have hnat : ∀ v, E1 (delta2 hG ℓ v) = delta2 hH ℓ (E2 v) := by
    intro v
    have := congrArg (fun (f : (Gen2 G ℓ →₀ ℤ) →ₗ[ℤ] (Gen1 H ℓ →₀ ℤ)) => f v)
      (delta2_naturality e hG hH ℓ)
    simpa [hE1, hE2, Finsupp.domLCongr_apply, Finsupp.lmapDomain_apply,
      Finsupp.equivMapDomain_eq_mapDomain] using this
  have hmap : Submodule.map (E2 : (Gen2 G ℓ →₀ ℤ) →ₗ[ℤ] _) (LinearMap.ker (delta2 hG ℓ))
      = LinearMap.ker (delta2 hH ℓ) := by
    ext w
    constructor
    · rintro ⟨v, hv, rfl⟩
      simp only [LinearMap.mem_ker, LinearEquiv.coe_coe] at hv ⊢
      rw [← hnat v, hv, map_zero]
    · intro hw
      refine ⟨E2.symm w, ?_, by simp⟩
      simp only [LinearMap.mem_ker] at hw ⊢
      apply E1.injective
      rw [hnat, E2.apply_symm_apply, hw, map_zero]
  exact ⟨(E2.submoduleMap (LinearMap.ker (delta2 hG ℓ))).trans (LinearEquiv.ofEq _ _ hmap)⟩

/-- **The rank of `MH_{2,2}` of the Cayley graph of the Coxeter group `(ℤ/2)ⁿ`** is
`2ⁿ · C(n+1,2)`. -/
theorem cayleyMH22_finrank (n : ℕ) :
    Module.finrank ℤ (LinearMap.ker (delta2 (cayleyGraph_connected n) 2))
      = 2 ^ n * (n + 1).choose 2 := by
  obtain ⟨f⟩ := ker_delta2_equiv (topeIsoCayley n) (topeGraph_connected n)
    (cayleyGraph_connected n) 2
  rw [← f.finrank_eq, topeMH22_finrank n]

/-- **`MH_{2,2}` of the Cayley graph of the Coxeter group `(ℤ/2)ⁿ`** is free abelian of
rank `2ⁿ · C(n+1,2)`. -/
theorem cayleyMH22_free (n : ℕ) :
    Nonempty (LinearMap.ker (delta2 (cayleyGraph_connected n) 2) ≃ₗ[ℤ]
      (Fin (2 ^ n * (n + 1).choose 2) →₀ ℤ)) := by
  obtain ⟨f⟩ := ker_delta2_equiv (topeIsoCayley n) (topeGraph_connected n)
    (cayleyGraph_connected n) 2
  obtain ⟨g⟩ := topeMH22_free n
  exact ⟨f.symm.trans g⟩

end Transport

end MagnitudeTope