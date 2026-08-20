/-
# Functoriality of the Chebotarev geodesic theorem under group quotients

Motivated by *"Chebotarev geodesic theorem: non-split case"*.  A Chebotarev-type statement is
attached to a finite Galois group `G` of a covering of the base (arithmetic) surface: for each
conjugacy class `C ⊆ G` one counts the primitive closed geodesics whose Frobenius class is `C`,
and the theorem asserts

  `π_C(x) = (|C|/|G|) · li(x) + O(x^{θ+ε})`.

An intermediate covering corresponds to a **surjective homomorphism** `f : G →* H`, and the
counting function of a class `D ⊆ H` is the sum of the counting functions of the `G`-classes
lying above it.  The purely arithmetic content of "the theorem for the top covering implies the
theorem for every intermediate covering" is the density identity

  `∑_{C ↦ D} |C|/|G| = |D|/|H|`,

i.e. the Chebotarev densities push forward along `ConjClasses.map f`.  This file proves that
identity from scratch (fibre counting for a surjective group homomorphism, plus the partition of
`G` into conjugacy classes) and deduces the analytic transfer statement, using the exponent
calculus of `ChebotarevGeodesic.lean`.

Main results:

* `card_filter_preimage_mul_card` : for a surjective `f : G →* H` and `S : Finset H`,
  `|f⁻¹ S| · |H| = |S| · |G|` (all fibres of `f` have the same cardinality);
* `sum_classSize_fiber` : `∑_{C ↦ D} |C| = |f⁻¹(D)|`;
* `sum_classDensity_fiber` : `∑_{C ↦ D} |C|/|G| = |D|/|H|`;
* `chebotarev_pushforward` : the Chebotarev geodesic theorem with exponent `θ` for `G` implies
  it with the *same* exponent `θ` for every quotient `H` of `G`;
* `chebotarev_pushforward_25_36` : the numerical instance of the paper;
* `chebotarev_pushforward_comp` : functoriality of the pushforward along a tower `G ↠ H ↠ K`.
-/

import Mathlib
import Catalog.Shared.ChebotarevGeodesic

open Finset Filter Function

namespace ChebotarevGeodesic

section Quotient

variable {G H : Type*} [Group G] [Fintype G] [DecidableEq G]
  [Group H] [Fintype H] [DecidableEq H]

omit [DecidableEq G] in
/-- All fibres of a group homomorphism over its image have the same size; consequently, for a
**surjective** `f : G →* H` and any `S : Finset H`, the preimage of `S` has cardinality
`|S| · |G| / |H|`.  Stated multiplicatively to stay inside `ℕ`. -/
theorem card_filter_preimage_mul_card (f : G →* H) (hf : Surjective f) (S : Finset H) :
    ({g : G | f g ∈ S} : Finset G).card * Fintype.card H
      = S.card * Fintype.card G := by
  classical
  -- every fibre has the same cardinality `N`
  set N : ℕ := ({g : G | f g = 1} : Finset G).card with hN
  have hfib : ∀ h : H, ({g : G | f g = h} : Finset G).card = N := by
    intro h
    exact MonoidHom.card_fiber_eq_of_mem_range f (hf h) ⟨1, map_one f⟩
  -- cardinality of a preimage
  have hpre : ∀ S : Finset H, ({g : G | f g ∈ S} : Finset G).card = S.card * N := by
    intro S
    have hmaps : Set.MapsTo (fun g : G => f g) (({g : G | f g ∈ S} : Finset G) : Set G)
        (S : Set H) := by
      intro g hg
      simpa using (by simpa using hg : f g ∈ S)
    have := Finset.card_eq_sum_card_fiberwise (f := fun g : G => f g)
      (s := ({g : G | f g ∈ S} : Finset G)) (t := S) hmaps
    rw [this]
    have hcong : ∀ h ∈ S,
        ({g ∈ ({g : G | f g ∈ S} : Finset G) | f g = h}).card = N := by
      intro h hh
      have : ({g ∈ ({g : G | f g ∈ S} : Finset G) | f g = h}) = ({g : G | f g = h} : Finset G) := by
        ext g
        simp only [Finset.mem_filter, Finset.mem_filter, Finset.mem_univ, true_and]
        constructor
        · rintro ⟨-, hg⟩; exact hg
        · intro hg; exact ⟨by rw [hg]; exact hh, hg⟩
      rw [this, hfib]
    rw [Finset.sum_congr rfl hcong, Finset.sum_const, smul_eq_mul]
  -- the total count gives `|G| = |H| * N`
  have htot : Fintype.card G = Fintype.card H * N := by
    have h1 : ({g : G | f g ∈ (Finset.univ : Finset H)} : Finset G) = Finset.univ := by
      ext g; simp
    have := hpre (Finset.univ : Finset H)
    rw [h1, Finset.card_univ, Finset.card_univ] at this
    exact this
  rw [hpre S, htot]
  ring

variable [Fintype (ConjClasses G)] [Fintype (ConjClasses H)]

omit [Fintype (ConjClasses H)] in
/-- The `G`-conjugacy classes lying above a fixed `H`-conjugacy class `D` partition the
preimage of `D`. -/
theorem sum_classSize_fiber (f : G →* H) (D : ConjClasses H) :
    ∑ C ∈ ({C : ConjClasses G | ConjClasses.map f C = D} : Finset (ConjClasses G)),
        classSize G C
      = ({g : G | ConjClasses.mk (f g) = D} : Finset G).card := by
  classical
  have hmaps : Set.MapsTo (fun g : G => ConjClasses.mk g)
      (({g : G | ConjClasses.mk (f g) = D} : Finset G) : Set G)
      ((({C : ConjClasses G | ConjClasses.map f C = D} : Finset (ConjClasses G))) : Set _) := by
    intro g hg
    have hg' : ConjClasses.mk (f g) = D := by simpa using hg
    simp only [Finset.coe_filter, Set.mem_setOf_eq, Finset.mem_univ, true_and]
    show ConjClasses.map f (ConjClasses.mk g) = D
    simpa using hg'
  have hcard := Finset.card_eq_sum_card_fiberwise
    (f := fun g : G => ConjClasses.mk g)
    (s := ({g : G | ConjClasses.mk (f g) = D} : Finset G))
    (t := ({C : ConjClasses G | ConjClasses.map f C = D} : Finset (ConjClasses G))) hmaps
  rw [hcard]
  refine Finset.sum_congr rfl ?_
  intro C hC
  have hCD : ConjClasses.map f C = D := by simpa using hC
  have hset : ({g ∈ ({g : G | ConjClasses.mk (f g) = D} : Finset G) | ConjClasses.mk g = C})
      = ({g : G | ConjClasses.mk g = C} : Finset G) := by
    ext g
    simp only [Finset.mem_filter, Finset.mem_univ, true_and]
    constructor
    · rintro ⟨-, hg⟩; exact hg
    · intro hg
      refine ⟨?_, hg⟩
      have : ConjClasses.map f (ConjClasses.mk g) = D := by rw [hg]; exact hCD
      simpa using this
  rw [hset]
  simp [classSize]

omit [Fintype (ConjClasses G)] [DecidableEq G] in
/-- The preimage of a conjugacy class `D ⊆ H` under a surjective `f : G →* H` has
`|D| · |G| / |H|` elements. -/
theorem card_preimage_class_mul_card (f : G →* H) (hf : Surjective f) (D : ConjClasses H) :
    ({g : G | ConjClasses.mk (f g) = D} : Finset G).card * Fintype.card H
      = classSize H D * Fintype.card G := by
  classical
  have h1 : ({g : G | ConjClasses.mk (f g) = D} : Finset G)
      = ({g : G | f g ∈ ({h : H | ConjClasses.mk h = D} : Finset H)} : Finset G) := by
    ext g; simp
  rw [h1, card_filter_preimage_mul_card f hf]
  simp [classSize]

/-- **Pushforward of Chebotarev densities.**  For a surjective homomorphism `f : G →* H` the
densities of the `G`-classes lying above an `H`-class `D` add up to the density of `D`. -/
theorem sum_classDensity_fiber (f : G →* H) (hf : Surjective f) (D : ConjClasses H) :
    ∑ C ∈ ({C : ConjClasses G | ConjClasses.map f C = D} : Finset (ConjClasses G)),
        classDensity G C
      = classDensity H D := by
  classical
  have hG : (0 : ℝ) < Fintype.card G := by exact_mod_cast Fintype.card_pos (α := G)
  have hH : (0 : ℝ) < Fintype.card H := by exact_mod_cast Fintype.card_pos (α := H)
  have hkey := card_preimage_class_mul_card f hf D
  have hsum := sum_classSize_fiber f D
  have hcast : (({g : G | ConjClasses.mk (f g) = D} : Finset G).card : ℝ) * Fintype.card H
      = (classSize H D : ℝ) * Fintype.card G := by exact_mod_cast hkey
  simp only [classDensity]
  rw [← Finset.sum_div]
  have : ∑ C ∈ ({C : ConjClasses G | ConjClasses.map f C = D} : Finset (ConjClasses G)),
      (classSize G C : ℝ)
      = (({g : G | ConjClasses.mk (f g) = D} : Finset G).card : ℝ) := by
    exact_mod_cast congrArg (fun n : ℕ => (n : ℝ)) hsum
  rw [this]
  field_simp
  linarith [hcast]

/-- **The Chebotarev geodesic theorem descends to quotients, with the same error exponent.**
If for every conjugacy class `C` of `G` the counting function `piC C` satisfies
`π_C(x) = (|C|/|G|)·li(x) + O(x^{θ+ε})`, then for every conjugacy class `D` of a quotient `H`
of `G` the aggregated counting function `∑_{C ↦ D} π_C` satisfies
`π_D(x) = (|D|/|H|)·li(x) + O(x^{θ+ε})`. -/
theorem chebotarev_pushforward (f : G →* H) (hf : Surjective f)
    (piC : ConjClasses G → ℝ → ℝ) (li : ℝ → ℝ) (θ : ℝ)
    (h : ∀ C, HasErrorExponent (piC C) (fun x => classDensity G C * li x) θ) (D : ConjClasses H) :
    HasErrorExponent
      (fun x => ∑ C ∈ ({C : ConjClasses G | ConjClasses.map f C = D} : Finset (ConjClasses G)),
        piC C x)
      (fun x => classDensity H D * li x) θ := by
  classical
  have hsum := HasErrorExponent.sum
    (({C : ConjClasses G | ConjClasses.map f C = D} : Finset (ConjClasses G))) piC
    (fun C x => classDensity G C * li x) θ (fun C _ => h C)
  have e : (fun x => ∑ C ∈ ({C : ConjClasses G | ConjClasses.map f C = D} :
        Finset (ConjClasses G)), classDensity G C * li x)
      = fun x => classDensity H D * li x := by
    funext x
    rw [← Finset.sum_mul, sum_classDensity_fiber f hf D]
  rwa [e] at hsum

/-- The numerical instance of the paper: exponent `25/36` is inherited by every quotient. -/
theorem chebotarev_pushforward_25_36 (f : G →* H) (hf : Surjective f)
    (piC : ConjClasses G → ℝ → ℝ) (li : ℝ → ℝ)
    (h : ∀ C, HasErrorExponent (piC C) (fun x => classDensity G C * li x) (25 / 36))
    (D : ConjClasses H) :
    HasErrorExponent
      (fun x => ∑ C ∈ ({C : ConjClasses G | ConjClasses.map f C = D} : Finset (ConjClasses G)),
        piC C x)
      (fun x => classDensity H D * li x) (25 / 36) :=
  chebotarev_pushforward f hf piC li (25 / 36) h D

omit [Fintype G] [DecidableEq G] [Fintype H] [DecidableEq H] [Fintype (ConjClasses G)]
  [Fintype (ConjClasses H)] in
/-- Compatibility of `ConjClasses.map` with composition of homomorphisms. -/
theorem conjClasses_map_comp {K : Type*} [Group K] (f : G →* H) (f' : H →* K)
    (C : ConjClasses G) :
    ConjClasses.map (f'.comp f) C = ConjClasses.map f' (ConjClasses.map f C) := by
  induction C using Quotient.inductionOn with
  | h g => rfl

/-- **Functoriality along a tower.**  Densities push forward compatibly through
`G ↠ H ↠ K`: pushing forward twice is pushing forward along the composite. -/
theorem sum_classDensity_fiber_comp {K : Type*} [Group K] [Fintype K] [DecidableEq K]
    [Fintype (ConjClasses K)] (f : G →* H) (f' : H →* K) (E : ConjClasses K) :
    ∑ D ∈ ({D : ConjClasses H | ConjClasses.map f' D = E} : Finset (ConjClasses H)),
        ∑ C ∈ ({C : ConjClasses G | ConjClasses.map f C = D} : Finset (ConjClasses G)),
          classDensity G C
      = ∑ C ∈ ({C : ConjClasses G | ConjClasses.map (f'.comp f) C = E} :
          Finset (ConjClasses G)), classDensity G C := by
  classical
  have hcomp : ({C : ConjClasses G | ConjClasses.map (f'.comp f) C = E} : Finset (ConjClasses G))
      = ({C : ConjClasses G | ConjClasses.map f' (ConjClasses.map f C) = E} :
          Finset (ConjClasses G)) := by
    ext C
    simp [conjClasses_map_comp f f' C]
  rw [hcomp]
  -- regroup the sum over `C` according to the intermediate class `ConjClasses.map f C`
  rw [← Finset.sum_fiberwise_of_maps_to
    (s := ({C : ConjClasses G | ConjClasses.map f' (ConjClasses.map f C) = E} :
      Finset (ConjClasses G)))
    (t := ({D : ConjClasses H | ConjClasses.map f' D = E} : Finset (ConjClasses H)))
    (g := fun C : ConjClasses G => ConjClasses.map f C)
    (f := fun C : ConjClasses G => classDensity G C)
    (by
      intro C hC
      have : ConjClasses.map f' (ConjClasses.map f C) = E := by simpa using hC
      simpa using this)]
  refine Finset.sum_congr rfl ?_
  intro D hD
  have hDE : ConjClasses.map f' D = E := by simpa using hD
  refine Finset.sum_congr ?_ (fun _ _ => rfl)
  ext C
  simp only [Finset.mem_filter, Finset.mem_univ, true_and]
  constructor
  · intro hCD
    exact ⟨by rw [hCD]; exact hDE, hCD⟩
  · rintro ⟨-, hCD⟩; exact hCD

/-- **Consistency with the prime geodesic theorem.**  Summing the pushed-forward counting
functions over all classes of the quotient `H` recovers the total counting function of `G`
with main term `li`, i.e. the prime geodesic theorem with the same exponent. -/
theorem prime_geodesic_of_chebotarev_pushforward (f : G →* H) (hf : Surjective f)
    (piC : ConjClasses G → ℝ → ℝ) (li : ℝ → ℝ) (θ : ℝ)
    (h : ∀ C, HasErrorExponent (piC C) (fun x => classDensity G C * li x) θ) :
    HasErrorExponent
      (fun x => ∑ D : ConjClasses H,
        ∑ C ∈ ({C : ConjClasses G | ConjClasses.map f C = D} : Finset (ConjClasses G)), piC C x)
      li θ := by
  classical
  have hsum := HasErrorExponent.sum (Finset.univ : Finset (ConjClasses H))
    (fun D x => ∑ C ∈ ({C : ConjClasses G | ConjClasses.map f C = D} :
      Finset (ConjClasses G)), piC C x)
    (fun D x => classDensity H D * li x) θ
    (fun D _ => chebotarev_pushforward f hf piC li θ h D)
  have e : (fun x => ∑ D : ConjClasses H, classDensity H D * li x) = li := by
    funext x
    rw [← Finset.sum_mul, sum_classDensity H, one_mul]
  rwa [e] at hsum

end Quotient

end ChebotarevGeodesic