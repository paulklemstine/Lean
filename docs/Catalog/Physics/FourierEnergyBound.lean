/-
# From Fourier energy to additive energy: what `FourierAdd.card_support_rep_ge` really says

`Catalog.Shared.FourierAdditive` proves the quantitative covering bound

  `|{c : r_{A,B}(c) > 0}| ≥ |G| (|A||B|)² / ((|A||B|)² + E)`,     (★)

where `E = ∑_{ψ ≠ 0} |1̂_A(ψ)|² |1̂_B(ψ)|²` is the *nonprincipal Fourier energy*.
The inequality is proved there; what was left open is (i) computing `E` for explicit
families and (ii) exhibiting families where (★) is *strictly stronger* than the
pigeonhole bound `|A + B| ≥ max(|A|,|B|)`.

This file supplies the structural half of the answer.  The key observation
(`fourierEnergy_eq`) is that Plancherel pins `E` down completely in terms of the purely
combinatorial **additive energy**

  `Ẽ(A,B) = ∑_c r_{A,B}(c)²  =  #{(a,b,a',b') ∈ A×B×A×B : a + b = a' + b'}`,

namely `E = |G| · Ẽ(A,B) − (|A||B|)²`.  Consequently the whole right-hand side of (★)
collapses (`fourierBound_eq_addEnergy_ratio`) to

  `|G| (|A||B|)² / ((|A||B|)² + E)  =  (|A||B|)² / Ẽ(A,B)`,

i.e. **the Fourier/Cauchy–Schwarz covering bound is exactly the elementary
second-moment bound `|supp r| ≥ (∑ r)²/(∑ r²)`**, with no loss and no gain.  This is the
structural reason why `E` is computable for any family for which one can count additive
quadruples, and it turns the open second half of the problem into a finite combinatorial
computation, carried out for two infinite families in
`Catalog.Physics.FourierEnergyFamilies`.

Main results:

* `FourierEnergy.support_rep_eq_add` : the support of `r_{A,B}` is the sumset `A + B`.
* `FourierEnergy.sum_rep_sq_eq_sum_over_pairs` : `Ẽ(A,B) = ∑_{(a,b) ∈ A×B} r_{A,B}(a+b)`,
  the quadruple-counting form of additive energy (this is the workhorse for computations).
* `FourierEnergy.fourierEnergy_eq` : `E = |G| Ẽ(A,B) − (|A||B|)²` (Plancherel).
* `FourierEnergy.fourierBound_eq_addEnergy_ratio` : (★) *is* the second-moment bound.
* `FourierEnergy.card_add_ge_addEnergy_ratio` : `(|A||B|)² / Ẽ(A,B) ≤ |A + B|`.
* `FourierEnergy.card_add_ge_pigeonhole` : the pigeonhole benchmark `max(|A|,|B|) ≤ |A+B|`.
* `FourierEnergy.beats_pigeonhole_iff` : an exact criterion for (★) to beat pigeonhole.
* `FourierEnergy.addEnergy_eq_finsetAddEnergy` : `Ẽ` is Mathlib's `Finset.addEnergy`.
* `FourierEnergy.beats_pigeonhole_iff_card_add_gt`, `FourierEnergy.gain_or_coset` : the
  dichotomy — (★) beats pigeonhole for *every* set of strictly positive doubling, the
  sole exceptions being cosets of subgroups.
* `FourierEnergy.addEnergy_subgroup`, `FourierEnergy.subgroup_no_gain` : for `A = B = H`
  a subgroup, `E = |G||H|³ − |H|⁴` and (★) returns *exactly* `|H|`, so subgroups are
  simultaneously the equality case of (★) and the obstruction to beating pigeonhole.
-/

import Mathlib
import Shared.FourierAdditive

open Finset FourierFA FourierAdd
open scoped Pointwise RightActions

namespace FourierEnergy

variable {G : Type*} [AddCommGroup G] [Fintype G] [DecidableEq G]

/-! ## The two energies -/

/-- The nonprincipal Fourier energy `E = ∑_{ψ ≠ 0} |1̂_A(ψ)|² |1̂_B(ψ)|²` occurring in
`FourierAdd.card_support_rep_ge`. -/
noncomputable def fourierEnergy (A B : Finset G) : ℝ :=
  ∑ ψ ∈ (univ : Finset (AddChar G ℂ)).erase 0,
    ‖dft (indF A) ψ‖ ^ 2 * ‖dft (indF B) ψ‖ ^ 2

/-- The (combinatorial) additive energy `Ẽ(A,B) = ∑_c r_{A,B}(c)²`. -/
def addEnergy (A B : Finset G) : ℕ := ∑ c : G, rep A B c ^ 2

/-- The right-hand side of the covering bound `FourierAdd.card_support_rep_ge`. -/
noncomputable def fourierBound (A B : Finset G) : ℝ :=
  (Fintype.card G : ℝ) * ((A.card : ℝ) * (B.card : ℝ)) ^ 2
    / (((A.card : ℝ) * (B.card : ℝ)) ^ 2 + fourierEnergy A B)

/-! ## The support of the representation function is the sumset -/

omit [Fintype G] in
/-- `r_{A,B}(c) > 0` exactly when `c` lies in the sumset `A + B`. -/
theorem rep_pos_iff (A B : Finset G) (c : G) : 0 < rep A B c ↔ c ∈ A + B := by
  constructor
  · intro h
    obtain ⟨a, ha⟩ := Finset.card_pos.1 h
    rw [Finset.mem_filter] at ha
    exact Finset.mem_add.2 ⟨a, ha.1, c - a, ha.2, by abel⟩
  · intro h
    obtain ⟨a, ha, b, hb, hab⟩ := Finset.mem_add.1 h
    refine Finset.card_pos.2 ⟨a, Finset.mem_filter.2 ⟨ha, ?_⟩⟩
    have : c - a = b := by rw [← hab]; abel
    rwa [this]

/-- The support of the representation function is exactly the sumset `A + B`. -/
theorem support_rep_eq_add (A B : Finset G) :
    (univ : Finset G).filter (fun c => 0 < rep A B c) = A + B := by
  ext c
  simp [Finset.mem_filter, rep_pos_iff A B c]

/-! ## Additive energy as a count of additive quadruples -/

omit [Fintype G] in
/-- The representation function counts the pairs of `A ×ˢ B` lying over `c`. -/
theorem rep_eq_card_fiber (A B : Finset G) (c : G) :
    rep A B c = ((A ×ˢ B).filter (fun p => p.1 + p.2 = c)).card := by
  classical
  rw [rep]
  refine Finset.card_bij (fun a _ => (a, c - a)) ?_ ?_ ?_
  · intro a ha
    rw [Finset.mem_filter] at ha ⊢
    refine ⟨Finset.mem_product.2 ⟨ha.1, ha.2⟩, ?_⟩
    simp
  · intro a₁ h₁ a₂ h₂ h
    exact congrArg Prod.fst h
  · rintro ⟨a, b⟩ hp
    rw [Finset.mem_filter, Finset.mem_product] at hp
    have hcb : c - a = b := by rw [← hp.2]; abel
    exact ⟨a, Finset.mem_filter.2 ⟨hp.1.1, by rw [hcb]; exact hp.1.2⟩, by simp [hcb]⟩

/-- `∑_c r(c)² = ∑_{(a,b) ∈ A×B} r(a+b)`: grouping the additive quadruples
`(a,b,a',b')` with `a+b = a'+b'` by their first pair.  This is the form used in all
explicit computations. -/
theorem sum_rep_sq_eq_sum_over_pairs (A B : Finset G) :
    addEnergy A B = ∑ p ∈ A ×ˢ B, rep A B (p.1 + p.2) := by
  classical
  rw [← Finset.sum_fiberwise (A ×ˢ B) (fun p : G × G => p.1 + p.2)
      (fun p => rep A B (p.1 + p.2))]
  rw [addEnergy]
  refine Finset.sum_congr rfl fun c _ => ?_
  have h : ∀ p ∈ (A ×ˢ B).filter (fun p : G × G => p.1 + p.2 = c),
      rep A B (p.1 + p.2) = rep A B c := by
    intro p hp
    rw [(Finset.mem_filter.1 hp).2]
  rw [Finset.sum_congr rfl h, Finset.sum_const, smul_eq_mul, ← rep_eq_card_fiber]
  ring

/-! ## Plancherel: the Fourier energy is determined by the additive energy -/

/-- **Plancherel identity in energy form**: the nonprincipal Fourier energy is
`E = |G| · Ẽ(A,B) − (|A||B|)²`. -/
theorem fourierEnergy_eq (A B : Finset G) :
    fourierEnergy A B
      = (Fintype.card G : ℝ) * (addEnergy A B : ℝ) - ((A.card : ℝ) * (B.card : ℝ)) ^ 2 := by
  have h := energy_identity A B
  have hcast : ((addEnergy A B : ℕ) : ℝ) = ∑ c : G, ((rep A B c : ℝ)) ^ 2 := by
    rw [addEnergy]; push_cast; ring
  rw [fourierEnergy, hcast]
  linarith [h]

/-- Positivity of the additive energy for nonempty sets. -/
theorem addEnergy_pos (A B : Finset G) (hA : A.Nonempty) (hB : B.Nonempty) :
    0 < addEnergy A B := by
  obtain ⟨a, ha⟩ := hA
  obtain ⟨b, hb⟩ := hB
  have hpos : 0 < rep A B (a + b) := by
    refine Finset.card_pos.2 ⟨a, Finset.mem_filter.2 ⟨ha, ?_⟩⟩
    have : a + b - a = b := by abel
    rwa [this]
  refine lt_of_lt_of_le ?_ (Finset.single_le_sum (f := fun c : G => rep A B c ^ 2)
    (fun c _ => Nat.zero_le _) (Finset.mem_univ (a + b)))
  positivity

/-! ## The covering bound is exactly the second-moment bound -/

/-- **Collapse of the Fourier bound.**  The right-hand side of
`FourierAdd.card_support_rep_ge` equals the elementary second-moment ratio
`(∑ r)² / (∑ r²) = (|A||B|)² / Ẽ(A,B)`. -/
theorem fourierBound_eq_addEnergy_ratio (A B : Finset G) (hA : A.Nonempty) (hB : B.Nonempty) :
    fourierBound A B = ((A.card : ℝ) * (B.card : ℝ)) ^ 2 / (addEnergy A B : ℝ) := by
  have hG : (0 : ℝ) < (Fintype.card G : ℝ) := by exact_mod_cast Fintype.card_pos (α := G)
  have hE : (0 : ℝ) < (addEnergy A B : ℝ) := by
    exact_mod_cast addEnergy_pos A B hA hB
  rw [fourierBound, fourierEnergy_eq]
  have hden : ((A.card : ℝ) * (B.card : ℝ)) ^ 2
      + ((Fintype.card G : ℝ) * (addEnergy A B : ℝ) - ((A.card : ℝ) * (B.card : ℝ)) ^ 2)
      = (Fintype.card G : ℝ) * (addEnergy A B : ℝ) := by ring
  rw [hden]
  field_simp

/-- The covering bound, in its collapsed combinatorial form:
`(|A||B|)² / Ẽ(A,B) ≤ |A + B|`. -/
theorem card_add_ge_addEnergy_ratio (A B : Finset G) (hA : A.Nonempty) (hB : B.Nonempty) :
    ((A.card : ℝ) * (B.card : ℝ)) ^ 2 / (addEnergy A B : ℝ) ≤ (((A + B).card : ℕ) : ℝ) := by
  have h := card_support_rep_ge A B hA hB
  rw [support_rep_eq_add] at h
  rw [← fourierBound_eq_addEnergy_ratio A B hA hB]
  exact h

/-! ## Sums over the support -/

/-- The representation function vanishes off the sumset, so its total mass may be summed
over `A + B`. -/
theorem sum_rep_support (A B : Finset G) :
    ∑ c ∈ A + B, rep A B c = A.card * B.card := by
  have h : ∑ c ∈ A + B, rep A B c = ∑ c : G, rep A B c := by
    refine Finset.sum_subset (Finset.subset_univ (A + B)) ?_
    intro c _ hc
    by_contra hne
    exact hc ((rep_pos_iff A B c).1 (Nat.pos_of_ne_zero hne))
  rw [h, sum_rep]

/-- Likewise for the squared representation function. -/
theorem sum_rep_sq_support (A B : Finset G) :
    ∑ c ∈ A + B, rep A B c ^ 2 = addEnergy A B := by
  have h : ∑ c ∈ A + B, rep A B c ^ 2 = ∑ c : G, rep A B c ^ 2 := by
    refine Finset.sum_subset (Finset.subset_univ (A + B)) ?_
    intro c _ hc
    have hz : rep A B c = 0 := by
      by_contra hne
      exact hc ((rep_pos_iff A B c).1 (Nat.pos_of_ne_zero hne))
    rw [hz]
    ring
  rw [h, addEnergy]

/-! ## Agreement with Mathlib's additive energy -/

/-- The second moment `∑_c r_{A,B}(c)²` is Mathlib's additive energy `E[A, B]`, i.e. the
number of additive quadruples `(a₁, a₂, b₁, b₂) ∈ A × A × B × B` with
`a₁ + b₁ = a₂ + b₂`. -/
theorem addEnergy_eq_finsetAddEnergy (A B : Finset G) :
    addEnergy A B = Finset.addEnergy A B := by
  classical
  have h1 : Finset.addEnergy A B
      = ∑ p ∈ ((A ×ˢ B) ×ˢ (A ×ˢ B) : Finset ((G × G) × G × G)),
          if p.2.1 + p.2.2 = p.1.1 + p.1.2 then 1 else 0 := by
    rw [Finset.addEnergy, Finset.card_filter]
    refine Finset.sum_nbij' (fun x => ((x.1.1, x.2.1), (x.1.2, x.2.2)))
      (fun p => ((p.1.1, p.2.1), (p.1.2, p.2.2))) ?_ ?_ ?_ ?_ ?_
    · rintro ⟨⟨a₁, a₂⟩, ⟨b₁, b₂⟩⟩ hx
      simp only [Finset.mem_product] at hx ⊢
      exact ⟨⟨hx.1.1, hx.2.1⟩, ⟨hx.1.2, hx.2.2⟩⟩
    · rintro ⟨⟨a₁, b₁⟩, ⟨a₂, b₂⟩⟩ hx
      simp only [Finset.mem_product] at hx ⊢
      exact ⟨⟨hx.1.1, hx.2.1⟩, ⟨hx.1.2, hx.2.2⟩⟩
    · rintro ⟨⟨a₁, a₂⟩, ⟨b₁, b₂⟩⟩ _; rfl
    · rintro ⟨⟨a₁, b₁⟩, ⟨a₂, b₂⟩⟩ _; rfl
    · rintro ⟨⟨a₁, a₂⟩, ⟨b₁, b₂⟩⟩ _
      simp only [eq_comm]
  rw [h1, Finset.sum_product, sum_rep_sq_eq_sum_over_pairs]
  refine Finset.sum_congr rfl fun p _ => ?_
  rw [rep_eq_card_fiber, Finset.card_filter]

/-! ## The pigeonhole benchmark -/

omit [Fintype G] in
/-- The trivial pigeonhole bound `max(|A|,|B|) ≤ |A + B|`. -/
theorem card_add_ge_pigeonhole (A B : Finset G) (hA : A.Nonempty) (hB : B.Nonempty) :
    max A.card B.card ≤ (A + B).card := by
  obtain ⟨a, ha⟩ := hA
  obtain ⟨b, hb⟩ := hB
  have h1 : B.card ≤ (A + B).card := by
    refine Finset.card_le_card_of_injOn (fun y => a + y) (fun y hy => ?_) ?_
    · exact Finset.mem_add.2 ⟨a, ha, y, hy, rfl⟩
    · intro x _ y _ h
      exact add_left_cancel h
  have h2 : A.card ≤ (A + B).card := by
    refine Finset.card_le_card_of_injOn (fun x => x + b) (fun x hx => ?_) ?_
    · exact Finset.mem_add.2 ⟨x, hx, b, hb, rfl⟩
    · intro x _ y _ h
      exact add_right_cancel h
  exact max_le h2 h1

/-- Exact criterion for the Fourier covering bound to be *strictly stronger* than
pigeonhole: it happens precisely when the additive energy is smaller than
`(|A||B|)² / max(|A|,|B|)`. -/
theorem beats_pigeonhole_iff (A B : Finset G) (hA : A.Nonempty) (hB : B.Nonempty) :
    ((max A.card B.card : ℕ) : ℝ) < fourierBound A B ↔
      ((max A.card B.card : ℕ) : ℝ) * (addEnergy A B : ℝ)
        < ((A.card : ℝ) * (B.card : ℝ)) ^ 2 := by
  have hE : (0 : ℝ) < (addEnergy A B : ℝ) := by exact_mod_cast addEnergy_pos A B hA hB
  rw [fourierBound_eq_addEnergy_ratio A B hA hB, lt_div_iff₀ hE]

/-! ## An exact dichotomy: when does the bound beat pigeonhole? -/

omit [Fintype G] in
theorem rep_le_card (A B : Finset G) (c : G) : rep A B c ≤ A.card :=
  Finset.card_filter_le _ _

/-- If `A` has strictly positive doubling then its additive energy is *strictly* below
the trivial maximum `|A|³`. -/
theorem addEnergy_lt_card_cube (A : Finset G) (hA : A.Nonempty) (hd : A.card < (A + A).card) :
    addEnergy A A < A.card ^ 3 := by
  have hk : 0 < A.card := Finset.card_pos.2 hA
  have hex : ∃ c ∈ A + A, rep A A c < A.card := by
    by_contra hcon
    push_neg at hcon
    have heq : ∀ c ∈ A + A, rep A A c = A.card :=
      fun c hc => le_antisymm (rep_le_card A A c) (hcon c hc)
    have hsum := sum_rep_support A A
    rw [Finset.sum_congr rfl heq, Finset.sum_const, smul_eq_mul] at hsum
    have hcancel : (A + A).card = A.card := Nat.eq_of_mul_eq_mul_right hk hsum
    omega
  obtain ⟨c₀, hc₀, hlt⟩ := hex
  have hstep : ∑ c ∈ A + A, rep A A c ^ 2 < ∑ c ∈ A + A, A.card * rep A A c := by
    refine Finset.sum_lt_sum (fun c _ => ?_) ⟨c₀, hc₀, ?_⟩
    · have h := rep_le_card A A c
      nlinarith [Nat.zero_le (rep A A c)]
    · have hpos : 0 < rep A A c₀ := (rep_pos_iff A A c₀).2 hc₀
      nlinarith
  rw [sum_rep_sq_support, ← Finset.mul_sum, sum_rep_support] at hstep
  calc addEnergy A A < A.card * (A.card * A.card) := hstep
    _ = A.card ^ 3 := by ring

/-- **Dichotomy.**  The Fourier covering bound is strictly stronger than the pigeonhole
bound `|A| ≤ |A + A|` *exactly* for the sets of strictly positive doubling.  Equivalently
(by `Finset.vadd_stabilizer_of_no_doubling`), the only sets for which the bound fails to
improve on pigeonhole are the cosets of subgroups — for which, by `subgroup_no_gain`, it
is nevertheless exactly sharp. -/
theorem beats_pigeonhole_iff_card_add_gt (A : Finset G) (hA : A.Nonempty) :
    ((A.card : ℕ) : ℝ) < fourierBound A A ↔ A.card < (A + A).card := by
  have hE : (0 : ℝ) < (addEnergy A A : ℝ) := by exact_mod_cast addEnergy_pos A A hA hA
  have hk : (0 : ℝ) < (A.card : ℝ) := by exact_mod_cast Finset.card_pos.2 hA
  constructor
  · intro hlt
    by_contra hcon
    push_neg at hcon
    have h1 : (((A + A).card : ℕ) : ℝ) ≤ (A.card : ℝ) := by exact_mod_cast hcon
    have h2 := card_add_ge_addEnergy_ratio A A hA hA
    rw [← fourierBound_eq_addEnergy_ratio A A hA hA] at h2
    linarith
  · intro hgt
    have h3 : (addEnergy A A : ℝ) < (A.card : ℝ) ^ 3 := by
      have := addEnergy_lt_card_cube A hA hgt
      exact_mod_cast this
    rw [fourierBound_eq_addEnergy_ratio A A hA hA, lt_div_iff₀ hE]
    nlinarith

/-- **Structural form of the dichotomy.**  For every nonempty `A`, either the covering
bound strictly beats pigeonhole, or `A` is a translate of its stabilizer subgroup, i.e. a
coset (Mathlib's `Finset.vadd_stabilizer_of_no_doubling`). -/
theorem gain_or_coset (A : Finset G) {a : G} (ha : a ∈ A) :
    ((A.card : ℕ) : ℝ) < fourierBound A A ∨
      a +ᵥ> (AddAction.stabilizer G A : Set G) = (A : Set G) := by
  by_cases h : A.card < (A + A).card
  · exact Or.inl ((beats_pigeonhole_iff_card_add_gt A ⟨a, ha⟩).2 h)
  · push_neg at h
    exact Or.inr (Finset.vadd_stabilizer_of_no_doubling h ha)

/-! ## Subgroups: the equality case, and the obstruction -/

section Subgroup

variable (H : AddSubgroup G) [DecidablePred (· ∈ H)]

/-- For a subgroup `H`, the representation function of `H` with itself is `|H|` on `H`
and `0` off `H`. -/
theorem rep_subgroup (c : G) :
    rep (H : Set G).toFinset (H : Set G).toFinset c
      = if c ∈ H then (H : Set G).toFinset.card else 0 := by
  by_cases hc : c ∈ H
  · rw [if_pos hc, rep]
    congr 1
    refine Finset.filter_true_of_mem fun y hy => ?_
    simp only [Set.mem_toFinset, SetLike.mem_coe] at hy ⊢
    exact H.sub_mem hc hy
  · rw [if_neg hc, rep, Finset.card_eq_zero]
    refine Finset.filter_false_of_mem fun y hy => ?_
    simp only [Set.mem_toFinset, SetLike.mem_coe] at hy ⊢
    intro hcy
    exact hc (by simpa using H.add_mem hcy hy)

/-- The additive energy of a subgroup with itself is `|H|³`. -/
theorem addEnergy_subgroup :
    addEnergy (H : Set G).toFinset (H : Set G).toFinset
      = (H : Set G).toFinset.card ^ 3 := by
  classical
  rw [addEnergy]
  have h : ∀ c : G, rep (H : Set G).toFinset (H : Set G).toFinset c ^ 2
      = if c ∈ (H : Set G).toFinset then (H : Set G).toFinset.card ^ 2 else 0 := by
    intro c
    rw [rep_subgroup H c]
    by_cases hc : c ∈ H <;> simp [hc]
  simp_rw [h]
  rw [Finset.sum_ite_mem, Finset.univ_inter, Finset.sum_const, smul_eq_mul]
  ring

/-- The nonprincipal Fourier energy of a subgroup: `E = |G| |H|³ − |H|⁴`. -/
theorem fourierEnergy_subgroup :
    fourierEnergy (H : Set G).toFinset (H : Set G).toFinset
      = (Fintype.card G : ℝ) * ((H : Set G).toFinset.card : ℝ) ^ 3
        - ((H : Set G).toFinset.card : ℝ) ^ 4 := by
  rw [fourierEnergy_eq, addEnergy_subgroup]
  push_cast
  ring

/-- **Subgroups are the equality case.**  For `A = B = H` the covering bound returns
exactly `|H| = |H + H|`, i.e. it is sharp but gives no improvement over pigeonhole. -/
theorem subgroup_no_gain :
    fourierBound (H : Set G).toFinset (H : Set G).toFinset
      = ((H : Set G).toFinset.card : ℝ) := by
  have hne : ((H : Set G).toFinset).Nonempty :=
    ⟨0, by simp⟩
  have hcard : (0 : ℝ) < ((H : Set G).toFinset.card : ℝ) := by
    exact_mod_cast Finset.card_pos.2 hne
  rw [fourierBound_eq_addEnergy_ratio _ _ hne hne, addEnergy_subgroup]
  push_cast
  field_simp

end Subgroup

end FourierEnergy