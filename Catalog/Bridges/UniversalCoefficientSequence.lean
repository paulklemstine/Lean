import Mathlib

/-!
# The universal coefficient exact sequence in the homotopy category

Let `V` be an abelian category, `c` a complex shape and `j₁ → j₀` two consecutive degrees.
Let `i : P₁ ⟶ P₀` be a map of **projective** objects and `A := coker i`, so that
`P₁ → P₀ → A → 0` is a projective presentation of `A`, and let
`Q := double i` be the two-term complex `P₁ ⟶ P₀` placed in degrees `j₁, j₀`
(a projective resolution of `A[j₀]` when `i` is mono).

For any complex `K` this file establishes the **universal coefficient exact sequence**

`Hom(P₀, H_{j₁} K) --(i ≫ ·)--> Hom(P₁, H_{j₁} K) --Ψ--> [Q, K] --Φ--> Hom(A, H_{j₀} K) → 0`

where `[Q, K]` denotes the hom-group in the homotopy category of complexes.  Since
`Ext¹(A, B)` is the cokernel of `Hom(P₀, B) → Hom(P₁, B)` computed from the presentation,
this is precisely the universal coefficient theorem

`0 → Ext¹(A, H_{j₁} K) → [Q, K] → Hom(A, H_{j₀} K) → 0`.

Main statements:

* `Catalog.Bridges.UCT.phi_surjective` / `phiBar_surjective` — surjectivity of the
  edge map `Φ`;
* `Catalog.Bridges.UCT.exact_middle` — exactness at `[Q, K]`;
* `Catalog.Bridges.UCT.exact_left` — exactness at `Hom(P₁, H_{j₁} K)`, identifying the
  kernel of `Ψ` with the image of `i^*`, i.e. the `Ext¹` term;
* `Catalog.Bridges.UCT.universal_coefficient_theorem` — the three statements packaged as
  the exactness of the four-term sequence;
* `Catalog.Bridges.UCT.deltaExt_surjective` / `deltaExt_eq_zero_iff` — `Ext¹(A, Y)` is the
  cokernel of `i^*`, computed from the projective presentation;
* `Catalog.Bridges.UCT.uct_short_exact` — the classical short exact sequence
  `0 ⟶ Ext¹(A, H_{j₁}K) ⟶ [Q,K] ⟶ Hom(A, H_{j₀}K) ⟶ 0`;
* `Catalog.Bridges.UCT.uct_mod_two` — a concrete non-vacuous instance over `ℤ`.
-/

universe w v u

namespace Catalog.Bridges.UCT

open CategoryTheory Category Limits HomologicalComplex

variable {V : Type u} [Category.{v} V] [Abelian V] {ι : Type*}
  {c : ComplexShape ι} {j₁ j₀ : ι} {P₁ P₀ : V}

section Basic

variable (hrel : c.Rel j₁ j₀) (hne : j₁ ≠ j₀) (i : P₁ ⟶ P₀) (K : HomologicalComplex V c)

/-- The two-term complex `P₁ ⟶ P₀` in degrees `j₁` and `j₀`. -/
noncomputable abbrev dbl : HomologicalComplex V c := HomologicalComplex.double i hrel

variable {i K}

/-- The degree-`j₀` component of a chain map out of the two-term complex. -/
noncomputable def comp₀ (f : dbl hrel i ⟶ K) : P₀ ⟶ K.X j₀ :=
  (doubleXIso₁ i hrel hne).inv ≫ f.f j₀

/-- The degree-`j₁` component of a chain map out of the two-term complex. -/
noncomputable def comp₁ (f : dbl hrel i ⟶ K) : P₁ ⟶ K.X j₁ :=
  (doubleXIso₀ i hrel).inv ≫ f.f j₁

lemma comp₀_comp_d (f : dbl hrel i ⟶ K) :
    comp₀ hrel hne f ≫ K.d j₀ (c.next j₀) = 0 := by
  rw [comp₀, assoc, f.comm j₀ (c.next j₀),
    HomologicalComplex.double_d_eq_zero₀ i hrel j₀ (c.next j₀) hne.symm, zero_comp, comp_zero]

lemma i_comp_comp₀ (f : dbl hrel i ⟶ K) :
    i ≫ comp₀ hrel hne f = comp₁ hrel f ≫ K.d j₁ j₀ := by
  have h := f.comm j₁ j₀
  rw [HomologicalComplex.double_d i hrel hne] at h
  rw [comp₁, comp₀, assoc, h]
  simp

end Basic


section Phi

variable (hrel : c.Rel j₁ j₀) (hne : j₁ ≠ j₀) {i : P₁ ⟶ P₀} {K : HomologicalComplex V c}

/-- The cycle in degree `j₀` determined by a chain map out of the two-term complex. -/
noncomputable def cycles₀ (f : dbl hrel i ⟶ K) : P₀ ⟶ K.cycles j₀ :=
  K.liftCycles (comp₀ hrel hne f) (c.next j₀) rfl (comp₀_comp_d hrel hne f)

@[simp]
lemma cycles₀_i (f : dbl hrel i ⟶ K) :
    cycles₀ hrel hne f ≫ K.iCycles j₀ = comp₀ hrel hne f :=
  K.liftCycles_i _ _ _ _

/-- The homology class in degree `j₀` determined by a chain map out of the two-term
complex. -/
noncomputable def class₀ (f : dbl hrel i ⟶ K) : P₀ ⟶ K.homology j₀ :=
  cycles₀ hrel hne f ≫ K.homologyπ j₀

lemma i_comp_class₀ (f : dbl hrel i ⟶ K) : i ≫ class₀ hrel hne f = 0 := by
  have hb : (i ≫ comp₀ hrel hne f) ≫ K.d j₀ (c.next j₀) = 0 := by
    rw [assoc, comp₀_comp_d, comp_zero]
  have h1 : i ≫ cycles₀ hrel hne f
      = K.liftCycles (i ≫ comp₀ hrel hne f) (c.next j₀) rfl hb := by
    apply (cancel_mono (K.iCycles j₀)).1
    rw [assoc, cycles₀_i, K.liftCycles_i]
  rw [class₀, ← assoc, h1]
  exact K.liftCycles_homologyπ_eq_zero_of_boundary _ (c.next j₀) rfl (comp₁ hrel f)
    (i_comp_comp₀ hrel hne f)

/-- The edge map of the universal coefficient sequence: a chain map `Q ⟶ K` induces a
map `A = coker i ⟶ H_{j₀} K`. -/
noncomputable def phi (f : dbl hrel i ⟶ K) : cokernel i ⟶ K.homology j₀ :=
  cokernel.desc i (class₀ hrel hne f) (i_comp_class₀ hrel hne f)

@[reassoc (attr := simp)]
lemma cokernel_π_comp_phi (f : dbl hrel i ⟶ K) :
    cokernel.π i ≫ phi hrel hne f = class₀ hrel hne f :=
  cokernel.π_desc _ _ _

lemma comp₀_add (f g : dbl hrel i ⟶ K) :
    comp₀ hrel hne (f + g) = comp₀ hrel hne f + comp₀ hrel hne g := by
  simp [comp₀, Preadditive.comp_add]

lemma class₀_add (f g : dbl hrel i ⟶ K) :
    class₀ hrel hne (f + g) = class₀ hrel hne f + class₀ hrel hne g := by
  have h : cycles₀ hrel hne (f + g) = cycles₀ hrel hne f + cycles₀ hrel hne g := by
    apply (cancel_mono (K.iCycles j₀)).1
    rw [cycles₀_i, Preadditive.add_comp, cycles₀_i, cycles₀_i, comp₀_add]
  rw [class₀, h, Preadditive.add_comp]
  rfl

lemma phi_add (f g : dbl hrel i ⟶ K) :
    phi hrel hne (f + g) = phi hrel hne f + phi hrel hne g := by
  apply (cancel_epi (cokernel.π i)).1
  rw [cokernel_π_comp_phi, Preadditive.comp_add, cokernel_π_comp_phi, cokernel_π_comp_phi,
    class₀_add]

lemma class₀_eq_of_homotopy {f g : dbl hrel i ⟶ K} (ho : Homotopy f g) :
    class₀ hrel hne f = class₀ hrel hne g := by
  have hsub : class₀ hrel hne (f - g) = 0 := by
    have hcomm : (f - g).f j₀ = ho.hom j₀ j₁ ≫ K.d j₁ j₀ := by
      have hc := ho.comm j₀
      have hd : (dNext j₀) ho.hom = 0 := by
        simp [dNext, HomologicalComplex.double_d_eq_zero₀ i hrel j₀ (c.next j₀) hne.symm]
      have hp : (prevD j₀) ho.hom = ho.hom j₀ (c.prev j₀) ≫ K.d (c.prev j₀) j₀ := by
        simp [prevD]
      rw [HomologicalComplex.sub_f_apply, hc, hd, hp, c.prev_eq' hrel]
      abel
    have : comp₀ hrel hne (f - g)
        = ((doubleXIso₁ i hrel hne).inv ≫ ho.hom j₀ j₁) ≫ K.d j₁ j₀ := by
      rw [comp₀, hcomm, assoc]
    rw [class₀, cycles₀]
    exact K.liftCycles_homologyπ_eq_zero_of_boundary _ (c.next j₀) rfl _ this
  have hadd := class₀_add hrel hne (f - g) g
  rw [sub_add_cancel, hsub, zero_add] at hadd
  exact hadd

lemma phi_eq_of_homotopy {f g : dbl hrel i ⟶ K} (ho : Homotopy f g) :
    phi hrel hne f = phi hrel hne g := by
  apply (cancel_epi (cokernel.π i)).1
  rw [cokernel_π_comp_phi, cokernel_π_comp_phi, class₀_eq_of_homotopy hrel hne ho]

end Phi


section Psi

variable (hrel : c.Rel j₁ j₀) (hne : j₁ ≠ j₀) {i : P₁ ⟶ P₀} {K : HomologicalComplex V c}

/-- The chain map `Q ⟶ K` attached to a cycle `z : P₁ ⟶ Z_{j₁} K`.  It is zero in
degree `j₀`, so it is invisible to the edge map `Φ`. -/
noncomputable def ofCycle (z : P₁ ⟶ K.cycles j₁) : dbl hrel i ⟶ K :=
  mkHomFromDouble hrel hne (z ≫ K.iCycles j₁) 0 (by simp) (by simp)

@[simp]
lemma ofCycle_f₁ (z : P₁ ⟶ K.cycles j₁) :
    (ofCycle hrel hne (i := i) z).f j₁ = (doubleXIso₀ i hrel).hom ≫ z ≫ K.iCycles j₁ := by
  rw [ofCycle, mkHomFromDouble_f₀]

@[simp]
lemma ofCycle_f₀ (z : P₁ ⟶ K.cycles j₁) :
    (ofCycle hrel hne (i := i) z).f j₀ = 0 := by
  rw [ofCycle, mkHomFromDouble_f₁, comp_zero]

lemma comp₀_ofCycle (z : P₁ ⟶ K.cycles j₁) :
    comp₀ hrel hne (ofCycle hrel hne (i := i) z) = 0 := by
  rw [comp₀, ofCycle_f₀, comp_zero]

lemma phi_ofCycle (z : P₁ ⟶ K.cycles j₁) :
    phi hrel hne (ofCycle hrel hne (i := i) z) = 0 := by
  apply (cancel_epi (cokernel.π i)).1
  rw [cokernel_π_comp_phi, comp_zero, class₀]
  have : cycles₀ hrel hne (ofCycle hrel hne (i := i) z) = 0 := by
    apply (cancel_mono (K.iCycles j₀)).1
    rw [cycles₀_i, comp₀_ofCycle, zero_comp]
  rw [this, zero_comp]

open Classical in
/-- The family of maps underlying the homotopy between two maps `ofCycle`. -/
noncomputable def htpyHom (hh : P₁ ⟶ K.X (c.prev j₁)) (a b : ι) :
    (dbl hrel i).X a ⟶ K.X b :=
  if h : a = j₁ ∧ b = c.prev j₁ ∧ c.Rel b a then
    eqToHom (by rw [h.1]) ≫ (doubleXIso₀ i hrel).hom ≫ hh ≫ eqToHom (by rw [h.2.1])
  else 0

lemma htpyHom_eq_zero_of_not_rel (hh : P₁ ⟶ K.X (c.prev j₁)) (a b : ι) (hab : ¬ c.Rel b a) :
    htpyHom hrel (i := i) hh a b = 0 := by
  rw [htpyHom, dif_neg]
  tauto

lemma htpyHom_eq_zero_of_ne (hh : P₁ ⟶ K.X (c.prev j₁)) {a : ι} (ha : a ≠ j₁) (b : ι) :
    htpyHom hrel (i := i) hh a b = 0 := by
  rw [htpyHom, dif_neg]
  tauto

/-- The only possibly nonzero component of `htpyHom`. -/
lemma prevD_htpyHom (hh : P₁ ⟶ K.X (c.prev j₁)) :
    (prevD j₁) (htpyHom hrel (i := i) hh)
      = (doubleXIso₀ i hrel).hom ≫ hh ≫ K.d (c.prev j₁) j₁ := by
  by_cases hr : c.Rel (c.prev j₁) j₁
  · have hv : htpyHom hrel (i := i) hh j₁ (c.prev j₁) = (doubleXIso₀ i hrel).hom ≫ hh := by
      rw [htpyHom, dif_pos ⟨rfl, rfl, hr⟩]
      simp
    simp only [prevD, AddMonoidHom.mk'_apply, hv, assoc]
  · rw [K.shape _ _ hr, comp_zero, comp_zero]
    simp only [prevD, AddMonoidHom.mk'_apply]
    rw [htpyHom_eq_zero_of_not_rel hrel hh _ _ hr, zero_comp]

/-- Two cycle-maps whose cycles differ by a boundary give homotopic chain maps. -/
noncomputable def homotopyOfCycle {z z' : P₁ ⟶ K.cycles j₁} (hh : P₁ ⟶ K.X (c.prev j₁))
    (hcomm : z ≫ K.iCycles j₁ = hh ≫ K.d (c.prev j₁) j₁ + z' ≫ K.iCycles j₁) :
    Homotopy (ofCycle hrel hne (i := i) z) (ofCycle hrel hne (i := i) z') where
  hom := htpyHom hrel hh
  zero a b hab := htpyHom_eq_zero_of_not_rel hrel hh a b hab
  comm k := by
    by_cases hk₁ : k = j₁
    · subst hk₁
      rw [dNext_eq _ hrel, htpyHom_eq_zero_of_ne hrel hh hne.symm, comp_zero, zero_add,
        prevD_htpyHom, ofCycle_f₁, ofCycle_f₁, hcomm, Preadditive.comp_add]
    · by_cases hk₀ : k = j₀
      · subst hk₀
        rw [ofCycle_f₀, ofCycle_f₀, add_zero]
        simp only [dNext, prevD, AddMonoidHom.mk'_apply]
        rw [HomologicalComplex.double_d_eq_zero₀ i hrel k (c.next k) hk₁, zero_comp,
          htpyHom_eq_zero_of_ne hrel hh hk₁, zero_comp, add_zero]
      · exact (isZero_double_X i hrel k hk₁ hk₀).eq_of_src _ _

/-- Given two cycles with the same homology class and `P₁` projective, their difference
is a boundary. -/
lemma exists_boundary [Projective P₁] {z z' : P₁ ⟶ K.cycles j₁}
    (h : z ≫ K.homologyπ j₁ = z' ≫ K.homologyπ j₁) :
    ∃ hh : P₁ ⟶ K.X (c.prev j₁),
      z ≫ K.iCycles j₁ = hh ≫ K.d (c.prev j₁) j₁ + z' ≫ K.iCycles j₁ := by
  have hex : (ShortComplex.mk (K.toCycles (c.prev j₁) j₁) (K.homologyπ j₁)
      (K.toCycles_comp_homologyπ _ _)).Exact :=
    ShortComplex.exact_of_g_is_cokernel _ (K.homologyIsCokernel (c.prev j₁) j₁ rfl)
  have hw : (z - z') ≫ (ShortComplex.mk (K.toCycles (c.prev j₁) j₁) (K.homologyπ j₁)
      (K.toCycles_comp_homologyπ _ _)).g = 0 := by
    dsimp
    rw [Preadditive.sub_comp, h, sub_self]
  refine ⟨hex.liftFromProjective (z - z') hw, ?_⟩
  have h2 := hex.liftFromProjective_comp (z - z') hw
  dsimp at h2
  rw [← K.toCycles_i (c.prev j₁) j₁, ← assoc, h2, Preadditive.sub_comp]
  abel

variable [Projective P₁]

/-- The map `Ψ : Hom(P₁, H_{j₁} K) ⟶ [Q, K]` of the universal coefficient sequence,
at the level of chain maps. -/
noncomputable def psi (u : P₁ ⟶ K.homology j₁) : dbl hrel i ⟶ K :=
  ofCycle hrel hne (Projective.factorThru u (K.homologyπ j₁))

lemma phi_psi (u : P₁ ⟶ K.homology j₁) :
    phi hrel hne (psi hrel hne (i := i) u) = 0 :=
  phi_ofCycle hrel hne _

end Psi


section GeneralLemmas

variable {K : HomologicalComplex V c}

/-- Two cycles differing by a boundary have the same homology class. -/
lemma homologyπ_eq_of_boundary {P : V} {j : ι} {z z' : P ⟶ K.cycles j} (hh : P ⟶ K.X (c.prev j))
    (h : z ≫ K.iCycles j = hh ≫ K.d (c.prev j) j + z' ≫ K.iCycles j) :
    z ≫ K.homologyπ j = z' ≫ K.homologyπ j := by
  have hz : z - z' = hh ≫ K.toCycles (c.prev j) j := by
    apply (cancel_mono (K.iCycles j)).1
    rw [Preadditive.sub_comp, h, assoc, K.toCycles_i]
    abel
  have h2 : (z - z') ≫ K.homologyπ j = 0 := by
    rw [hz, assoc, K.toCycles_comp_homologyπ, comp_zero]
  rw [Preadditive.sub_comp, sub_eq_zero] at h2
  exact h2

/-- A cycle in a projective object with vanishing homology class is a boundary. -/
lemma exists_lift_of_homologyπ_eq_zero {P : V} [Projective P] {j j' : ι} (hj : c.prev j = j')
    {b : P ⟶ K.cycles j} (hb : b ≫ K.homologyπ j = 0) :
    ∃ w : P ⟶ K.X j', w ≫ K.d j' j = b ≫ K.iCycles j := by
  subst hj
  have hex : (ShortComplex.mk (K.toCycles (c.prev j) j) (K.homologyπ j)
      (K.toCycles_comp_homologyπ _ _)).Exact :=
    ShortComplex.exact_of_g_is_cokernel _ (K.homologyIsCokernel (c.prev j) j rfl)
  refine ⟨hex.liftFromProjective b hb, ?_⟩
  have h2 := hex.liftFromProjective_comp b hb
  dsimp at h2
  rw [← K.toCycles_i (c.prev j) j, ← assoc, h2]

end GeneralLemmas

section Exactness

variable (hrel : c.Rel j₁ j₀) (hne : j₁ ≠ j₀) {i : P₁ ⟶ P₀} {K : HomologicalComplex V c}

lemma ofCycle_add (z z' : P₁ ⟶ K.cycles j₁) :
    ofCycle hrel hne (i := i) (z + z') = ofCycle hrel hne z + ofCycle hrel hne z' := by
  apply from_double_hom_ext (hi₀₁ := hrel) <;>
    simp [Preadditive.add_comp, Preadditive.comp_add]

lemma ofCycle_zero : ofCycle hrel hne (i := i) (0 : P₁ ⟶ K.cycles j₁) = 0 := by
  apply from_double_hom_ext (hi₀₁ := hrel) <;> simp

open Classical in
/-- The family of maps underlying the homotopy correcting the degree-`j₀` component. -/
noncomputable def htpyHom' (w : P₀ ⟶ K.X j₁) (a b : ι) : (dbl hrel i).X a ⟶ K.X b :=
  if h : a = j₀ ∧ b = j₁ then
    eqToHom (by rw [h.1]) ≫ (doubleXIso₁ i hrel hne).hom ≫ w ≫ eqToHom (by rw [h.2])
  else 0

lemma htpyHom'_apply (w : P₀ ⟶ K.X j₁) :
    htpyHom' hrel hne (i := i) w j₀ j₁ = (doubleXIso₁ i hrel hne).hom ≫ w := by
  rw [htpyHom', dif_pos ⟨rfl, rfl⟩]
  simp

lemma htpyHom'_eq_zero_of_ne (w : P₀ ⟶ K.X j₁) {a : ι} (ha : a ≠ j₀) (b : ι) :
    htpyHom' hrel hne (i := i) w a b = 0 := by
  rw [htpyHom', dif_neg]
  tauto

lemma htpyHom'_zero (w : P₀ ⟶ K.X j₁) (a b : ι) (hab : ¬ c.Rel b a) :
    htpyHom' hrel hne (i := i) w a b = 0 := by
  rw [htpyHom', dif_neg]
  rintro ⟨rfl, rfl⟩
  exact hab hrel

/-- The comparison homotopy: a chain map `f : Q ⟶ K` whose degree-`j₀` component is the
boundary of `w` is homotopic to the map `ofCycle z` determined by the corrected
degree-`j₁` component. -/
noncomputable def homotopyOfCycle' {f : dbl hrel i ⟶ K} {z : P₁ ⟶ K.cycles j₁}
    (w : P₀ ⟶ K.X j₁)
    (h₀ : w ≫ K.d j₁ j₀ = comp₀ hrel hne f)
    (h₁ : comp₁ hrel f = i ≫ w + z ≫ K.iCycles j₁) :
    Homotopy f (ofCycle hrel hne (i := i) z) where
  hom := htpyHom' hrel hne w
  zero a b hab := htpyHom'_zero hrel hne w a b hab
  comm k := by
    by_cases hk₁ : k = j₁
    · subst hk₁
      have hd : (dNext k) (htpyHom' hrel hne (i := i) w)
          = (doubleXIso₀ i hrel).hom ≫ i ≫ w := by
        rw [dNext_eq _ hrel, htpyHom'_apply, HomologicalComplex.double_d i hrel hne]
        simp
      have hp : (prevD k) (htpyHom' hrel hne (i := i) w) = 0 := by
        simp only [prevD, AddMonoidHom.mk'_apply]
        rw [htpyHom'_eq_zero_of_ne hrel hne w hne, zero_comp]
      rw [hd, hp, add_zero, ofCycle_f₁, ← Preadditive.comp_add, ← h₁, comp₁,
        Iso.hom_inv_id_assoc]
    · by_cases hk₀ : k = j₀
      · subst hk₀
        have hd : (dNext k) (htpyHom' hrel hne (i := i) w) = 0 := by
          simp only [dNext, AddMonoidHom.mk'_apply]
          rw [HomologicalComplex.double_d_eq_zero₀ i hrel k (c.next k) hk₁, zero_comp]
        have hp : (prevD k) (htpyHom' hrel hne (i := i) w)
            = (doubleXIso₁ i hrel hne).hom ≫ comp₀ hrel hne f := by
          rw [prevD_eq _ hrel, htpyHom'_apply, assoc, h₀]
        rw [hd, hp, zero_add, ofCycle_f₀, add_zero, comp₀, Iso.hom_inv_id_assoc]
      · exact (isZero_double_X i hrel k hk₁ hk₀).eq_of_src _ _

/-- Maps of the form `Ψ(i^* v)` are null-homotopic. -/
noncomputable def homotopyOfCycleComp (v : P₀ ⟶ K.cycles j₁) :
    Homotopy (ofCycle hrel hne (i := i) (i ≫ v)) 0 :=
  (homotopyOfCycle' hrel hne (z := 0) (v ≫ K.iCycles j₁)
    (by rw [comp₀_ofCycle, assoc]; simp)
    (by rw [comp₁, ofCycle_f₁, Iso.inv_hom_id_assoc, zero_comp, add_zero, assoc])).trans
    (Homotopy.ofEq (ofCycle_zero hrel hne))

/-- **Surjectivity of the edge map `Φ`.** -/
lemma phi_surjective [Projective P₀] [Projective P₁] (γ : cokernel i ⟶ K.homology j₀) :
    ∃ f : dbl hrel i ⟶ K, phi hrel hne f = γ := by
  have hepi : Epi (K.homologyπ j₀) := inferInstance
  set b : P₀ ⟶ K.cycles j₀ :=
    Projective.factorThru (cokernel.π i ≫ γ) (K.homologyπ j₀) with hbdef
  have hbπ : b ≫ K.homologyπ j₀ = cokernel.π i ≫ γ := Projective.factorThru_comp _ _
  have hb : (i ≫ b) ≫ K.homologyπ j₀ = 0 := by
    rw [assoc, hbπ, ← assoc, cokernel.condition, zero_comp]
  obtain ⟨w, hw⟩ :=
    exists_lift_of_homologyπ_eq_zero (K := K) (P := P₁) (c.prev_eq' hrel) hb
  refine ⟨mkHomFromDouble hrel hne w (b ≫ K.iCycles j₀) (by rw [hw, assoc]) (by
      intro k hk
      rw [assoc, K.iCycles_d, comp_zero]), ?_⟩
  apply (cancel_epi (cokernel.π i)).1
  rw [cokernel_π_comp_phi, class₀, ← hbπ]
  congr 1
  apply (cancel_mono (K.iCycles j₀)).1
  rw [cycles₀_i, comp₀, mkHomFromDouble_f₁, Iso.inv_hom_id_assoc]

end Exactness


section Exactness2

variable (hrel : c.Rel j₁ j₀) (hne : j₁ ≠ j₀) {i : P₁ ⟶ P₀} {K : HomologicalComplex V c}

/-- **Exactness at `[Q, K]`, hard direction.**  A chain map killed by the edge map `Φ`
is homotopic to one coming from a cycle in degree `j₁`. -/
lemma exists_ofCycle_homotopy [Projective P₀] (f : dbl hrel i ⟶ K) (hf : phi hrel hne f = 0) :
    ∃ z : P₁ ⟶ K.cycles j₁, Nonempty (Homotopy f (ofCycle hrel hne (i := i) z)) := by
  have h0 : cycles₀ hrel hne f ≫ K.homologyπ j₀ = 0 := by
    have h := cokernel_π_comp_phi hrel hne f
    rw [hf, comp_zero] at h
    exact h.symm
  obtain ⟨w, hw⟩ := exists_lift_of_homologyπ_eq_zero (K := K) (P := P₀) (c.prev_eq' hrel) h0
  have hw' : w ≫ K.d j₁ j₀ = comp₀ hrel hne f := by rw [hw, cycles₀_i]
  have hz : (comp₁ hrel f - i ≫ w) ≫ K.d j₁ j₀ = 0 := by
    rw [Preadditive.sub_comp, assoc, hw', ← i_comp_comp₀ hrel hne f, sub_self]
  refine ⟨K.liftCycles (comp₁ hrel f - i ≫ w) j₀ (c.next_eq' hrel) hz,
    ⟨homotopyOfCycle' hrel hne w hw' ?_⟩⟩
  rw [K.liftCycles_i]
  abel

/-- **Exactness at `Hom(P₁, H_{j₁} K)`, hard direction.**  If `ofCycle z` is null-homotopic,
then the class of `z` comes from `P₀` along `i`. -/
lemma exists_lift_of_homotopy_zero {z : P₁ ⟶ K.cycles j₁}
    (ho : Homotopy (ofCycle hrel hne (i := i) z) 0) :
    ∃ v : P₀ ⟶ K.homology j₁, i ≫ v = z ≫ K.homologyπ j₁ := by
  have hj₀ := ho.comm j₀
  rw [ofCycle_f₀, HomologicalComplex.zero_f_apply, add_zero] at hj₀
  have hdz : (dNext j₀) ho.hom = 0 := by
    simp only [dNext, AddMonoidHom.mk'_apply]
    rw [HomologicalComplex.double_d_eq_zero₀ i hrel j₀ (c.next j₀) hne.symm, zero_comp]
  rw [hdz, zero_add, prevD_eq _ hrel] at hj₀
  have hwd : ((doubleXIso₁ i hrel hne).inv ≫ ho.hom j₀ j₁) ≫ K.d j₁ j₀ = 0 := by
    rw [assoc, ← hj₀, comp_zero]
  refine ⟨K.liftCycles ((doubleXIso₁ i hrel hne).inv ≫ ho.hom j₀ j₁) j₀ (c.next_eq' hrel) hwd
    ≫ K.homologyπ j₁, ?_⟩
  rw [← assoc]
  symm
  apply homologyπ_eq_of_boundary ((doubleXIso₀ i hrel).inv ≫ ho.hom j₁ (c.prev j₁))
  have hj₁ := ho.comm j₁
  rw [ofCycle_f₁, HomologicalComplex.zero_f_apply, add_zero, dNext_eq _ hrel,
    HomologicalComplex.double_d i hrel hne] at hj₁
  apply (cancel_epi (doubleXIso₀ i hrel).hom).1
  rw [Preadditive.comp_add, hj₁, add_comm]
  congr 1
  · simp only [prevD, AddMonoidHom.mk'_apply]
    rw [← assoc, Iso.hom_inv_id_assoc]
  · simp

end Exactness2


section HomotopyLevel

variable (hrel : c.Rel j₁ j₀) (hne : j₁ ≠ j₀) (i : P₁ ⟶ P₀) (K : HomologicalComplex V c)

/-- The hom-group `[Q, K]` in the homotopy category of complexes. -/
abbrev QHom : Type _ :=
  (HomotopyCategory.quotient V c).obj (dbl hrel i) ⟶ (HomotopyCategory.quotient V c).obj K

variable {i K}

lemma phi_zero : phi hrel hne (0 : dbl hrel i ⟶ K) = 0 := by
  have h := phi_ofCycle hrel hne (i := i) (0 : P₁ ⟶ K.cycles j₁)
  rwa [ofCycle_zero] at h

lemma phi_out_eq (x : QHom hrel i K) (f : dbl hrel i ⟶ K)
    (hf : (HomotopyCategory.quotient V c).map f = x) :
    phi hrel hne x.out = phi hrel hne f :=
  (phi_eq_of_homotopy hrel hne
    (HomotopyCategory.homotopyOfEq f x.out (by rw [hf, HomotopyCategory.quotient_map_out]))).symm

/-- The edge map `Φ : [Q, K] → Hom(A, H_{j₀} K)` of the universal coefficient sequence. -/
noncomputable def phiBar : QHom hrel i K →+ (cokernel i ⟶ K.homology j₀) where
  toFun x := phi hrel hne x.out
  map_zero' := by
    rw [phi_out_eq hrel hne 0 0 (by simp), phi_zero]
  map_add' x y := by
    rw [phi_out_eq hrel hne (x + y) (x.out + y.out) (by
      rw [Functor.map_add, HomotopyCategory.quotient_map_out,
        HomotopyCategory.quotient_map_out]), phi_add]

@[simp]
lemma phiBar_quotient_map (f : dbl hrel i ⟶ K) :
    phiBar hrel hne ((HomotopyCategory.quotient V c).map f) = phi hrel hne f :=
  phi_out_eq hrel hne _ f rfl

variable [Projective P₁]

lemma quotient_map_ofCycle_congr {z z' : P₁ ⟶ K.cycles j₁}
    (h : z ≫ K.homologyπ j₁ = z' ≫ K.homologyπ j₁) :
    (HomotopyCategory.quotient V c).map (ofCycle hrel hne (i := i) z)
      = (HomotopyCategory.quotient V c).map (ofCycle hrel hne (i := i) z') := by
  obtain ⟨hh, hhh⟩ := exists_boundary h
  exact HomotopyCategory.eq_of_homotopy _ _ (homotopyOfCycle hrel hne hh hhh)

/-- The map `Ψ : Hom(P₁, H_{j₁} K) → [Q, K]` of the universal coefficient sequence. -/
noncomputable def psiBar (u : P₁ ⟶ K.homology j₁) : QHom hrel i K :=
  (HomotopyCategory.quotient V c).map (psi hrel hne (i := i) u)

lemma psiBar_ofCycle {z : P₁ ⟶ K.cycles j₁} :
    psiBar hrel hne (i := i) (z ≫ K.homologyπ j₁)
      = (HomotopyCategory.quotient V c).map (ofCycle hrel hne (i := i) z) := by
  refine quotient_map_ofCycle_congr hrel hne ?_
  simp [Projective.factorThru_comp]

lemma psiBar_add (u u' : P₁ ⟶ K.homology j₁) :
    psiBar hrel hne (i := i) (u + u') = psiBar hrel hne u + psiBar hrel hne u' := by
  rw [psiBar, psiBar, psiBar, psi, psi, psi, ← Functor.map_add, ← ofCycle_add]
  refine quotient_map_ofCycle_congr hrel hne ?_
  simp [Preadditive.add_comp, Projective.factorThru_comp]

/-- The composite `Φ ∘ Ψ` vanishes. -/
lemma phiBar_psiBar (u : P₁ ⟶ K.homology j₁) :
    phiBar hrel hne (psiBar hrel hne (i := i) u) = 0 := by
  rw [psiBar, phiBar_quotient_map, phi_psi]

/-- **The universal coefficient sequence is surjective on the right.** -/
theorem phiBar_surjective [Projective P₀] (γ : cokernel i ⟶ K.homology j₀) :
    ∃ x : QHom hrel i K, phiBar hrel hne x = γ := by
  obtain ⟨f, hf⟩ := phi_surjective hrel hne γ
  exact ⟨(HomotopyCategory.quotient V c).map f, by rw [phiBar_quotient_map, hf]⟩

/-- **Exactness of the universal coefficient sequence at `[Q, K]`.** -/
theorem exact_middle [Projective P₀] (x : QHom hrel i K) :
    phiBar hrel hne x = 0 ↔ ∃ u : P₁ ⟶ K.homology j₁, psiBar hrel hne (i := i) u = x := by
  constructor
  · intro hx
    obtain ⟨z, ⟨ho⟩⟩ := exists_ofCycle_homotopy hrel hne x.out hx
    refine ⟨z ≫ K.homologyπ j₁, ?_⟩
    rw [psiBar_ofCycle, ← HomotopyCategory.eq_of_homotopy _ _ ho,
      HomotopyCategory.quotient_map_out]
  · rintro ⟨u, rfl⟩
    exact phiBar_psiBar hrel hne u

/-- **Exactness of the universal coefficient sequence at `Hom(P₁, H_{j₁} K)`.**  The kernel
of `Ψ` is exactly the image of `i^* : Hom(P₀, H_{j₁} K) → Hom(P₁, H_{j₁} K)`, i.e. the
cokernel of `i^*` — which is `Ext¹(A, H_{j₁} K)` — injects into `[Q, K]`. -/
theorem exact_left [Projective P₀] (u : P₁ ⟶ K.homology j₁) :
    psiBar hrel hne (i := i) u = 0 ↔ ∃ v : P₀ ⟶ K.homology j₁, i ≫ v = u := by
  constructor
  · intro hu
    rw [psiBar, psi] at hu
    have ho := HomotopyCategory.homotopyOfEq _ (0 : dbl hrel i ⟶ K) (by
      rw [hu, Functor.map_zero])
    obtain ⟨v, hv⟩ := exists_lift_of_homotopy_zero hrel hne ho
    exact ⟨v, by rw [hv, Projective.factorThru_comp]⟩
  · rintro ⟨v, rfl⟩
    rw [psiBar, psi]
    have hcongr : (HomotopyCategory.quotient V c).map
        (ofCycle hrel hne (i := i) (Projective.factorThru (i ≫ v) (K.homologyπ j₁)))
        = (HomotopyCategory.quotient V c).map
          (ofCycle hrel hne (i := i) (i ≫ Projective.factorThru v (K.homologyπ j₁))) := by
      refine quotient_map_ofCycle_congr hrel hne ?_
      rw [Projective.factorThru_comp, assoc, Projective.factorThru_comp]
    rw [hcongr, HomotopyCategory.eq_of_homotopy _ _ (homotopyOfCycleComp hrel hne _),
      Functor.map_zero]


lemma psiBar_zero : psiBar hrel hne (i := i) (0 : P₁ ⟶ K.homology j₁) = 0 := by
  rw [psiBar, psi]
  have h : (HomotopyCategory.quotient V c).map (ofCycle hrel hne (i := i)
      (Projective.factorThru (0 : P₁ ⟶ K.homology j₁) (K.homologyπ j₁)))
      = (HomotopyCategory.quotient V c).map (ofCycle hrel hne (i := i) 0) := by
    refine quotient_map_ofCycle_congr hrel hne ?_
    simp [Projective.factorThru_comp]
  rw [h, ofCycle_zero, Functor.map_zero]

/-- `Ψ` as a group homomorphism. -/
noncomputable def psiBarHom : (P₁ ⟶ K.homology j₁) →+ QHom hrel i K where
  toFun := psiBar hrel hne
  map_zero' := psiBar_zero hrel hne
  map_add' := psiBar_add hrel hne

/-- The restriction map `i^* : Hom(P₀, H_{j₁} K) → Hom(P₁, H_{j₁} K)`, whose cokernel is
`Ext¹(A, H_{j₁} K)` for the projective presentation `P₁ → P₀ → A`. -/
noncomputable def iStarHom {Q₁ Q₀ : V} (f : Q₁ ⟶ Q₀) (L : HomologicalComplex V c) (j : ι) :
    (Q₀ ⟶ L.homology j) →+ (Q₁ ⟶ L.homology j) where
  toFun v := f ≫ v
  map_zero' := comp_zero
  map_add' g g' := by simp

/-- **The universal coefficient theorem.**  For a projective presentation
`P₁ --i--> P₀ ⟶ A ⟶ 0` and the associated two-term complex `Q` concentrated in degrees
`j₁, j₀`, the four-term sequence of abelian groups

`Hom(P₀, H_{j₁} K) --i^*--> Hom(P₁, H_{j₁} K) --Ψ--> [Q, K] --Φ--> Hom(A, H_{j₀} K) ⟶ 0`

is exact.  Since the cokernel of `i^*` is `Ext¹(A, H_{j₁} K)`, this is the short exact
sequence `0 ⟶ Ext¹(A, H_{j₁} K) ⟶ [Q, K] ⟶ Hom(A, H_{j₀} K) ⟶ 0`. -/
theorem universal_coefficient_theorem [Projective P₀] :
    Function.Surjective (phiBar hrel hne (i := i) (K := K)) ∧
    (∀ x : QHom hrel i K,
      phiBar hrel hne x = 0 ↔ x ∈ Set.range (psiBarHom hrel hne (i := i) (K := K))) ∧
    (∀ u : P₁ ⟶ K.homology j₁,
      psiBarHom hrel hne (i := i) u = 0 ↔ u ∈ Set.range (iStarHom i K j₁)) := by
  refine ⟨fun γ => phiBar_surjective hrel hne γ, fun x => ?_, fun u => ?_⟩
  · rw [exact_middle hrel hne x]
    rfl
  · rw [show psiBarHom hrel hne (i := i) u = psiBar hrel hne u from rfl,
      exact_left hrel hne u]
    rfl

end HomotopyLevel


section ExtIdentification

open Abelian

variable {V : Type u} [Category.{v} V] [Abelian V] [HasExt.{w} V] {ι : Type*}
  {c : ComplexShape ι} {j₁ j₀ : ι} {P₁ P₀ : V}

variable (i : P₁ ⟶ P₀)

/-- A projective presentation `P₁ --i--> P₀ ⟶ A ⟶ 0`, read as a short complex. -/
noncomputable def presentation : ShortComplex V :=
  ShortComplex.mk i (cokernel.π i) (cokernel.condition i)

omit [HasExt.{w} V] in
lemma presentation_shortExact [Mono i] : (presentation i).ShortExact where
  exact := ShortComplex.exact_cokernel i
  mono_f := inferInstanceAs (Mono i)
  epi_g := inferInstanceAs (Epi (cokernel.π i))

variable {i}

/-- The connecting map `Hom(P₁, Y) ⟶ Ext¹(A, Y)` of a projective presentation.  When `P₀`
is projective it is surjective with kernel the image of `i^*`, so it identifies
`Ext¹(A, Y)` with the cokernel of `i^*`. -/
noncomputable def deltaExt [Mono i] (Y : V) : (P₁ ⟶ Y) →+ Ext.{w} (cokernel i) Y 1 where
  toFun x := (presentation_shortExact i).extClass.comp (Ext.mk₀ x) (add_zero 1)
  map_zero' := by simp
  map_add' x y := by simp [Ext.mk₀_add]

lemma deltaExt_surjective [Mono i] [Projective P₀] (Y : V) :
    Function.Surjective (deltaExt (i := i) Y : (P₁ ⟶ Y) →+ Ext.{w} (cokernel i) Y 1) := by
  haveI : Projective (presentation i).X₂ := inferInstanceAs (Projective P₀)
  intro x₃
  obtain ⟨x₁, hx₁⟩ := Ext.contravariant_sequence_exact₃ (presentation_shortExact i) Y x₃
    (Ext.eq_zero_of_projective _) (n₀ := 0) rfl
  refine ⟨Ext.addEquiv₀ x₁, ?_⟩
  show (presentation_shortExact i).extClass.comp (Ext.mk₀ (Ext.addEquiv₀ x₁)) (add_zero 1) = x₃
  rw [Ext.mk₀_addEquiv₀_apply]
  exact hx₁

/-- `Ext¹(A, Y)` is the cokernel of `i^* : Hom(P₀, Y) → Hom(P₁, Y)`. -/
lemma deltaExt_eq_zero_iff [Mono i] [Projective P₀] (Y : V) (x : P₁ ⟶ Y) :
    (deltaExt (i := i) Y : (P₁ ⟶ Y) →+ Ext.{w} (cokernel i) Y 1) x = 0 ↔
      ∃ v : P₀ ⟶ Y, i ≫ v = x := by
  constructor
  · intro h
    obtain ⟨x₂, hx₂⟩ := Ext.contravariant_sequence_exact₁ (presentation_shortExact i) Y
      (Ext.mk₀ x) (n₁ := 1) rfl h
    refine ⟨Ext.addEquiv₀ x₂, ?_⟩
    apply Ext.addEquiv₀.symm.injective
    simp only [Ext.addEquiv₀_symm_apply, ← Ext.mk₀_comp_mk₀, Ext.mk₀_addEquiv₀_apply]
    exact hx₂
  · rintro ⟨v, rfl⟩
    show (presentation_shortExact i).extClass.comp (Ext.mk₀ (i ≫ v)) (add_zero 1) = 0
    rw [← Ext.mk₀_comp_mk₀]
    exact ShortComplex.ShortExact.extClass_comp_assoc _ _

variable (hrel : c.Rel j₁ j₀) (hne : j₁ ≠ j₀) {K : HomologicalComplex V c}
  [Mono i] [Projective P₀] [Projective P₁]

lemma psiBarHom_eq_zero_of_mem_ker
    (x : (deltaExt (i := i) (K.homology j₁) : (P₁ ⟶ K.homology j₁) →+ _).ker) :
    psiBarHom hrel hne (i := i) (x : P₁ ⟶ K.homology j₁) = 0 :=
  (exact_left hrel hne _).2 ((deltaExt_eq_zero_iff _ _).1 x.2)

/-- **`Ext¹` sits inside the homotopy-category hom-group.**  The map
`Ext¹(A, H_{j₁} K) ⟶ [Q, K]` induced by `Ψ` through the identification of `Ext¹` with the
cokernel of `i^*`. -/
noncomputable def extToQHom :
    Ext.{w} (cokernel i) (K.homology j₁) 1 →+ QHom hrel i K :=
  (QuotientAddGroup.lift (deltaExt (i := i) (K.homology j₁)).ker (psiBarHom hrel hne)
      (fun x hx => psiBarHom_eq_zero_of_mem_ker hrel hne ⟨x, hx⟩)).comp
    (QuotientAddGroup.quotientKerEquivOfSurjective (deltaExt (i := i) (K.homology j₁))
      (deltaExt_surjective _)).symm.toAddMonoidHom

@[simp]
lemma extToQHom_deltaExt (x : P₁ ⟶ K.homology j₁) :
    extToQHom hrel hne (deltaExt (i := i) (K.homology j₁) x) = psiBarHom hrel hne x := by
  have h1 : (QuotientAddGroup.quotientKerEquivOfSurjective
      (deltaExt (i := i) (K.homology j₁)) (deltaExt_surjective _)).symm
      (deltaExt (i := i) (K.homology j₁) x) = QuotientAddGroup.mk x :=
    (AddEquiv.symm_apply_eq _).2 rfl
  rw [extToQHom, AddMonoidHom.comp_apply, AddEquiv.coe_toAddMonoidHom, h1]
  rfl

lemma extToQHom_injective : Function.Injective (extToQHom hrel hne (i := i) (K := K)) := by
  rw [injective_iff_map_eq_zero]
  intro e he
  obtain ⟨x, rfl⟩ := deltaExt_surjective (i := i) (K.homology j₁) e
  rw [extToQHom_deltaExt] at he
  exact (deltaExt_eq_zero_iff _ _).2 ((exact_left hrel hne x).1 he)

lemma range_extToQHom :
    Set.range (extToQHom hrel hne (i := i) (K := K))
      = Set.range (psiBarHom hrel hne (i := i) (K := K)) := by
  ext y
  constructor
  · rintro ⟨e, rfl⟩
    obtain ⟨x, rfl⟩ := deltaExt_surjective (i := i) (K.homology j₁) e
    exact ⟨x, (extToQHom_deltaExt hrel hne x).symm⟩
  · rintro ⟨x, rfl⟩
    exact ⟨deltaExt (i := i) (K.homology j₁) x, extToQHom_deltaExt hrel hne x⟩

/-- **The universal coefficient theorem, classical form.**  For a projective presentation
`0 ⟶ P₁ --i--> P₀ ⟶ A ⟶ 0` with `P₀`, `P₁` projective and `i` a monomorphism, and for the
two-term complex `Q = (P₁ ⟶ P₀)` in consecutive degrees `j₁, j₀`, the sequence

`0 ⟶ Ext¹(A, H_{j₁} K) ⟶ [Q, K] ⟶ Hom(A, H_{j₀} K) ⟶ 0`

of abelian groups is short exact, where `[Q, K]` is the hom-group in the homotopy
category of complexes. -/
theorem uct_short_exact :
    Function.Injective (extToQHom hrel hne (i := i) (K := K)) ∧
    (∀ x : QHom hrel i K,
      phiBar hrel hne x = 0 ↔ x ∈ Set.range (extToQHom hrel hne (i := i) (K := K))) ∧
    Function.Surjective (phiBar hrel hne (i := i) (K := K)) := by
  refine ⟨extToQHom_injective hrel hne, fun x => ?_, fun γ => phiBar_surjective hrel hne γ⟩
  rw [range_extToQHom, exact_middle hrel hne x]
  rfl

end ExtIdentification


section Concrete

open Abelian

/-- Multiplication by `n` on `ℤ`, as a morphism of `ℤ`-modules. -/
noncomputable def intMul (n : ℤ) : ModuleCat.of ℤ ℤ ⟶ ModuleCat.of ℤ ℤ :=
  ModuleCat.ofHom (LinearMap.lsmul ℤ ℤ n)

lemma mono_intMul {n : ℤ} (hn : n ≠ 0) : Mono (intMul n) := by
  rw [ModuleCat.mono_iff_injective]
  intro a b h
  have h' : n * a = n * b := by simpa [intMul] using h
  exact mul_left_cancel₀ hn h'

instance : Mono (intMul 2) := mono_intMul (by norm_num)

/-- The two consecutive degrees `1, 0` of a chain complex. -/
lemma rel_one_zero : (ComplexShape.down ℕ).Rel 1 0 := rfl

/-- **A concrete, non-vacuous instance of the universal coefficient theorem.**
For the projective presentation `0 ⟶ ℤ --·2--> ℤ ⟶ ℤ/2 ⟶ 0` of `ℤ/2` and any chain
complex `K` of abelian groups, the sequence
`0 ⟶ Ext¹(ℤ/2, H₁K) ⟶ [Q, K] ⟶ Hom(ℤ/2, H₀K) ⟶ 0` is short exact.  This witnesses that
the hypotheses of `uct_short_exact` (a monomorphic map between projective objects) are
simultaneously satisfiable. -/
theorem uct_mod_two (K : HomologicalComplex (ModuleCat.{0} ℤ) (ComplexShape.down ℕ)) :
    Function.Injective
      (extToQHom (i := intMul 2) (K := K) rel_one_zero one_ne_zero) ∧
    (∀ x : QHom rel_one_zero (intMul 2) K,
      phiBar rel_one_zero one_ne_zero x = 0 ↔
        x ∈ Set.range (extToQHom (i := intMul 2) (K := K) rel_one_zero one_ne_zero)) ∧
    Function.Surjective
      (phiBar (i := intMul 2) (K := K) rel_one_zero one_ne_zero) :=
  uct_short_exact rel_one_zero one_ne_zero

end Concrete

end Catalog.Bridges.UCT