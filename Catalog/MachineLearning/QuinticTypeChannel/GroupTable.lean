/-
# Empirical type/coset tables of a finite group

Chebotarev's theorem says the Frobenius classes of a Galois extension equidistribute over
the Galois group.  Consequently the joint law of the pair (factorization type,
abelianization coset) of a random unramified prime is the joint law of that pair of
observables at a *uniformly random group element*.

This file builds that table, `TypeChannel.ofGroup G T C`, for any finite nonempty `G` and
any pair of observables `T : G → ι`, `C : G → κ`, and records the group-level form of the
laws of `Core.lean`:

* `ofGroup_p_eq` — the cell probabilities are class counts over `|G|`;
* `ofGroup_mutualInfo_eq_Hcoset` — **the abelianization law at group level**: if the type
  observable refines the coset observable, then `I(T;C) = H(C)`;
* `ofGroup_mutualInfo_eq_Htype` — dual version;
* `Hcoset_ofGroup_hom` — if `C` is a surjective homomorphism onto a finite abelian group
  `A`, the coset marginal is uniform, so `H(C) = log₂ |A|`; combined with the previous
  law this gives `I(T;C) = log₂|G^ab|` for a type observable refining the abelianization.
-/
import MachineLearning.QuinticTypeChannel.Core

open Finset

namespace TypeChannel

/-- Two joint tables with the same cell probabilities are equal. -/
lemma Joint.ext' {ι κ : Type} [Fintype ι] [Fintype κ] {J J' : Joint ι κ}
    (h : J.p = J'.p) : J = J' := by
  cases J; cases J'; simp_all

variable {ι κ : Type} [Fintype ι] [Fintype κ] [DecidableEq ι] [DecidableEq κ]

/-- The joint type/coset table of a uniformly random element of a finite group `G`
(more generally of any finite nonempty type). -/
noncomputable def ofGroup (G : Type) [Fintype G] [Nonempty G] [DecidableEq G]
    (T : G → ι) (C : G → κ) : Joint ι κ where
  p t c := ((univ.filter (fun g : G => T g = t ∧ C g = c)).card : ℝ) / Fintype.card G
  nonneg := by
    intro t c
    have : (0:ℝ) < Fintype.card G := by
      exact_mod_cast Fintype.card_pos_iff.mpr inferInstance
    positivity
  total := by
    have hcard : (0:ℝ) < Fintype.card G := by
      exact_mod_cast Fintype.card_pos_iff.mpr inferInstance
    have hfib : (Fintype.card G : ℕ)
        = ∑ x ∈ (univ : Finset (ι × κ)),
            (univ.filter (fun g : G => (T g, C g) = x)).card := by
      rw [← Finset.card_univ]
      exact Finset.card_eq_sum_card_fiberwise (fun g _ => mem_univ (T g, C g))
    have hsplit : ∑ t : ι, ∑ c : κ,
        ((univ.filter (fun g : G => T g = t ∧ C g = c)).card : ℝ)
        = (Fintype.card G : ℝ) := by
      rw [hfib]
      push_cast
      rw [Fintype.sum_prod_type]
      refine Finset.sum_congr rfl fun t _ => Finset.sum_congr rfl fun c _ => ?_
      congr 1
      congr 1
      ext g
      simp [Prod.ext_iff]
    calc ∑ t : ι, ∑ c : κ,
          ((univ.filter (fun g : G => T g = t ∧ C g = c)).card : ℝ) / Fintype.card G
        = (∑ t : ι, ∑ c : κ,
            ((univ.filter (fun g : G => T g = t ∧ C g = c)).card : ℝ)) / Fintype.card G := by
          rw [Finset.sum_div]
          exact Finset.sum_congr rfl fun t _ => (Finset.sum_div _ _ _).symm
      _ = 1 := by rw [hsplit]; field_simp

@[simp] lemma ofGroup_p (G : Type) [Fintype G] [Nonempty G] [DecidableEq G]
    (T : G → ι) (C : G → κ) (t : ι) (c : κ) :
    (ofGroup G T C).p t c
      = ((univ.filter (fun g : G => T g = t ∧ C g = c)).card : ℝ) / Fintype.card G := rfl

/-- A positive cell of the group table is witnessed by an actual group element. -/
lemma exists_of_pos_p {G : Type} [Fintype G] [Nonempty G] [DecidableEq G]
    {T : G → ι} {C : G → κ} {t : ι} {c : κ} (h : 0 < (ofGroup G T C).p t c) :
    ∃ g : G, T g = t ∧ C g = c := by
  rw [ofGroup_p] at h
  have hcard : (0:ℝ) < Fintype.card G := by
    exact_mod_cast Fintype.card_pos_iff.mpr inferInstance
  have hpos : 0 < ((univ.filter (fun g : G => T g = t ∧ C g = c)).card : ℝ) := by
    by_contra hle
    push_neg at hle
    have : ((univ.filter (fun g : G => T g = t ∧ C g = c)).card : ℝ) / Fintype.card G ≤ 0 :=
      div_nonpos_of_nonpos_of_nonneg hle (le_of_lt hcard)
    linarith
  have : (univ.filter (fun g : G => T g = t ∧ C g = c)).Nonempty := by
    rw [← Finset.card_pos]
    exact_mod_cast hpos
  obtain ⟨g, hg⟩ := this
  exact ⟨g, (mem_filter.mp hg).2⟩

/-- **The abelianization law, group form.**  If the type observable refines the coset
observable — i.e. elements with the same type always have the same coset — then the
information the type carries about the coset is the full coset entropy. -/
theorem ofGroup_mutualInfo_eq_Hcoset (G : Type) [Fintype G] [Nonempty G] [DecidableEq G]
    (T : G → ι) (C : G → κ) (h : ∀ g g' : G, T g = T g' → C g = C g') :
    (ofGroup G T C).mutualInfo = (ofGroup G T C).Hcoset := by
  refine Joint.mutualInfo_eq_Hcoset_of_determines _ ?_
  intro t c c' hc hc'
  obtain ⟨g, hgt, hgc⟩ := exists_of_pos_p hc
  obtain ⟨g', hgt', hgc'⟩ := exists_of_pos_p hc'
  rw [← hgc, ← hgc']
  exact h g g' (hgt.trans hgt'.symm)

/-- Dual law: if the coset observable refines the type observable, the information is the
full type entropy. -/
theorem ofGroup_mutualInfo_eq_Htype (G : Type) [Fintype G] [Nonempty G] [DecidableEq G]
    (T : G → ι) (C : G → κ) (h : ∀ g g' : G, C g = C g' → T g = T g') :
    (ofGroup G T C).mutualInfo = (ofGroup G T C).Htype := by
  refine Joint.mutualInfo_eq_Htype_of_codetermines _ ?_
  intro t t' c hc hc'
  obtain ⟨g, hgt, hgc⟩ := exists_of_pos_p hc
  obtain ⟨g', hgt', hgc'⟩ := exists_of_pos_p hc'
  rw [← hgt, ← hgt']
  exact h g g' (hgc.trans hgc'.symm)

/-- **Fibres of a surjective homomorphism onto a finite group all have size `|G|/|A|`.** -/
theorem card_fiber_hom {G A : Type} [Fintype G] [DecidableEq G] [Group G]
    [Group A] [Fintype A] [DecidableEq A]
    (φ : G →* A) (hφ : Function.Surjective φ) (a : A) :
    (univ.filter (fun g : G => φ g = a)).card * Fintype.card A = Fintype.card G := by
  classical
  have hker : Fintype.card φ.ker * Fintype.card A = Fintype.card G := by
    have e : (G ⧸ φ.ker) ≃ A := (QuotientGroup.quotientKerEquivOfSurjective φ hφ).toEquiv
    have h1 : Nat.card (G ⧸ φ.ker) = Nat.card A := Nat.card_congr e
    have h2 : Nat.card G = Nat.card (G ⧸ φ.ker) * Nat.card φ.ker := by
      simpa using (Subgroup.card_eq_card_quotient_mul_card_subgroup φ.ker)
    simp only [Nat.card_eq_fintype_card] at h1 h2
    rw [h1] at h2
    rw [h2]
    exact mul_comm _ _
  obtain ⟨g₀, hg₀⟩ := hφ a
  have hbij : (univ.filter (fun g : G => φ g = a)).card = Fintype.card φ.ker := by
    rw [← Fintype.card_coe]
    refine Fintype.card_congr ?_ |>.symm
    refine ⟨fun x => ⟨g₀ * x.1, by simp [mem_filter, MonoidHom.mem_ker.mp x.2, hg₀]⟩,
      fun y => ⟨g₀⁻¹ * y.1, ?_⟩, ?_, ?_⟩
    · have hy : φ y.1 = a := (mem_filter.mp y.2).2
      simp [MonoidHom.mem_ker, hy, ← hg₀]
    · intro x; ext; simp
    · intro y; ext; simp
  rw [hbij, hker]

/-- For a surjective homomorphism onto a finite group `A`, the coset marginal of the group
table is uniform: `H(C) = log₂|A|`. -/
theorem cosetMarg_ofGroup_hom {G A : Type} [Fintype G] [Nonempty G] [DecidableEq G]
    [Group G] [Group A] [Fintype A] [DecidableEq A]
    (T : G → ι) (φ : G →* A) (hφ : Function.Surjective φ) (a : A) :
    (ofGroup G T φ).cosetMarg a = 1 / Fintype.card A := by
  have hcardG : (0:ℝ) < Fintype.card G := by
    exact_mod_cast Fintype.card_pos_iff.mpr inferInstance
  have hfib := card_fiber_hom φ hφ a
  have hAcard : (0:ℝ) < Fintype.card A := by
    exact_mod_cast Fintype.card_pos_iff.mpr ⟨1⟩
  have hsum : (ofGroup G T φ).cosetMarg a
      = ((univ.filter (fun g : G => φ g = a)).card : ℝ) / Fintype.card G := by
    simp only [Joint.cosetMarg, ofGroup_p]
    rw [← Finset.sum_div]
    congr 1
    have hnat : ∑ t : ι, (univ.filter (fun g : G => T g = t ∧ φ g = a)).card
        = (univ.filter (fun g : G => φ g = a)).card := by
      rw [Finset.card_eq_sum_card_fiberwise
        (f := T) (s := univ.filter (fun g : G => φ g = a)) (t := univ)
        (fun g _ => mem_univ (T g))]
      refine Finset.sum_congr rfl fun t _ => ?_
      congr 1
      ext g
      simp [mem_filter, and_comm]
    exact_mod_cast hnat
  rw [hsum, div_eq_div_iff (ne_of_gt hcardG) (ne_of_gt hAcard), one_mul]
  exact_mod_cast hfib

/-- **The abelianization law in closed form.**  If the type observable refines a
surjective homomorphism `φ : G →* A` onto a finite abelian quotient, then the type channel
transmits exactly `log₂|A|` bits about the coset. -/
theorem abelianization_law {G A : Type} [Fintype G] [Nonempty G] [DecidableEq G]
    [Group G] [Group A] [Fintype A] [DecidableEq A]
    (T : G → ι) (φ : G →* A) (hφ : Function.Surjective φ)
    (hdet : ∀ g g' : G, T g = T g' → φ g = φ g') :
    (ofGroup G T φ).mutualInfo = Real.logb 2 (Fintype.card A) := by
  rw [ofGroup_mutualInfo_eq_Hcoset G T φ hdet]
  exact Joint.Hcoset_of_uniform _ (cosetMarg_ofGroup_hom T φ hφ)

/-- Dual of `cosetMarg_ofGroup_hom`: a surjective homomorphism in the *type* slot has a
uniform marginal. -/
theorem typeMarg_ofGroup_hom {G A : Type} [Fintype G] [Nonempty G] [DecidableEq G]
    [Group G] [Group A] [Fintype A] [DecidableEq A]
    (φ : G →* A) (hφ : Function.Surjective φ) (C : G → κ) (a : A) :
    (ofGroup G φ C).typeMarg a = 1 / Fintype.card A := by
  have hcardG : (0:ℝ) < Fintype.card G := by
    exact_mod_cast Fintype.card_pos_iff.mpr inferInstance
  have hAcard : (0:ℝ) < Fintype.card A := by
    exact_mod_cast Fintype.card_pos_iff.mpr ⟨1⟩
  have hfib := card_fiber_hom φ hφ a
  have hsum : (ofGroup G φ C).typeMarg a
      = ((univ.filter (fun g : G => φ g = a)).card : ℝ) / Fintype.card G := by
    simp only [Joint.typeMarg, ofGroup_p]
    rw [← Finset.sum_div]
    congr 1
    have hnat : ∑ c : κ, (univ.filter (fun g : G => φ g = a ∧ C g = c)).card
        = (univ.filter (fun g : G => φ g = a)).card := by
      rw [Finset.card_eq_sum_card_fiberwise
        (f := C) (s := univ.filter (fun g : G => φ g = a)) (t := univ)
        (fun g _ => mem_univ (C g))]
      refine Finset.sum_congr rfl fun c _ => ?_
      congr 1
      ext g
      simp [mem_filter]
    exact_mod_cast hnat
  rw [hsum, div_eq_div_iff (ne_of_gt hcardG) (ne_of_gt hAcard), one_mul]
  exact_mod_cast hfib

/-- If a *pair* of homomorphisms is jointly surjective, the group table they generate is
uniform on the product alphabet: every cell has probability `1/(|A|·|B|)`. -/
theorem p_ofGroup_hom_pair {G A B : Type} [Fintype G] [Nonempty G] [DecidableEq G]
    [Group G] [Group A] [Fintype A] [DecidableEq A] [Group B] [Fintype B] [DecidableEq B]
    (φ : G →* A) (ψ : G →* B) (h : Function.Surjective (fun g => (φ g, ψ g)))
    (a : A) (b : B) :
    (ofGroup G φ ψ).p a b = 1 / (Fintype.card A * Fintype.card B) := by
  have hprodsurj : Function.Surjective (φ.prod ψ) := h
  have hfib := card_fiber_hom (φ.prod ψ) hprodsurj (a, b)
  have hcardG : (0:ℝ) < Fintype.card G := by
    exact_mod_cast Fintype.card_pos_iff.mpr inferInstance
  have hAB : (0:ℝ) < (Fintype.card A : ℝ) * Fintype.card B := by
    have hA : (0:ℝ) < Fintype.card A := by exact_mod_cast Fintype.card_pos_iff.mpr ⟨1⟩
    have hB : (0:ℝ) < Fintype.card B := by exact_mod_cast Fintype.card_pos_iff.mpr ⟨1⟩
    positivity
  have hfilter : (univ.filter (fun g : G => φ g = a ∧ ψ g = b)).card
      = (univ.filter (fun g : G => (φ.prod ψ) g = (a, b))).card := by
    congr 1
    ext g
    simp [MonoidHom.prod_apply, Prod.ext_iff]
  rw [ofGroup_p, hfilter, div_eq_div_iff (ne_of_gt hcardG) (ne_of_gt hAB), one_mul]
  rw [Fintype.card_prod] at hfib
  exact_mod_cast hfib

end TypeChannel