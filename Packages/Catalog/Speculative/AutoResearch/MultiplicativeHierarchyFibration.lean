import Bridges.MultiplicativeHierarchyCore

/-!
# Conjecture M, exact form: the restriction fibration of injective-tuple orbits

Cutting an injective `(r+s)`-tuple into its first `r` and last `s` coordinates gives a map
`restrictOrbit : InjOrbit G X (r+s) → InjOrbit G X r`.  Its fibre over the orbit of `u` is in
bijection (`extendOrbit_bijective`) with the orbits of the stabiliser `Stab(u)` on injective
`s`-tuples avoiding the image of `u` (`RelOrbit`).  Hence

* `tInj_add_eq_sum_relCount` : `t_{r+s} = Σ_{[u]} #(Stab(u) \ Inj_s(X ∖ u))`,

the relative statement of which `descFactorial_injOrbits_one_le` is the case `r = 0`.
Consequences:

* `avoidCount_le_relCount`, `sum_avoidCount_le_sum_relCount` : the fibration refines the
  avoidance bound term by term;
* `relCount_le_one_of_tInj_eq_one` : `(r+s)`-transitivity forces every relative count `≤ 1`;
* `card_avoiding_injective`, `relCount_of_stabilizer_trivial`, `tInj_add_eq_of_free` :
  when injective `r`-tuples have trivial stabilisers, `t_{r+s} = t_r · (|X| − r)^{\underline{s}}`;
* `relCount_le`, `tInj_add_le` : in general `t_{r+s} ≤ t_r · (|X| − r)^{\underline{s}}`;
* `tInj_le_avoidCount_add`, `tInj_mul_sub_correction_le` : the coarse inequality
  `t_{r+s} ≥ t_r · (t_s − r)` (false in general) becomes true once the correction `r` is replaced
  by `|X|^{\underline{s}} − (|X| − r)^{\underline{s}}`, the number of injective `s`-tuples meeting a
  fixed injective `r`-tuple.

No `sorry`, no `native_decide`, no new axioms.
-/

open MulAction Function

namespace MultiplicativeHierarchy

section Fibration

variable (G : Type*) [Group G] {X : Type*} [MulAction G X]

/-- Restricting an orbit of injective `(r+s)`-tuples to its first `r` coordinates. -/
def restrictOrbit (r s : ℕ) (F : InjOrbit G X (r + s)) : InjOrbit G X r :=
  ⟨Quotient.map (fun F : Fin (r + s) → X => F ∘ Fin.castAdd s) (by
      intro a b hab
      obtain ⟨g, hg⟩ := (orbitRel_apply).1 hab
      exact (orbitRel_apply).2 ⟨g, by rw [← hg]; rfl⟩) F.1, by
    obtain ⟨F₀, hF₀, he⟩ := F.2
    exact ⟨F₀ ∘ Fin.castAdd s, hF₀.comp (Fin.castAdd_injective _ _), by rw [← he]; rfl⟩⟩

theorem restrictOrbit_val {r s : ℕ} (F : InjOrbit G X (r + s)) {F₁ : Fin (r + s) → X}
    (he : Quotient.mk (orbitRel G (Fin (r + s) → X)) F₁ = F.1) :
    (restrictOrbit G r s F).1 = Quotient.mk (orbitRel G (Fin r → X)) (F₁ ∘ Fin.castAdd s) := by
  obtain ⟨F, hF⟩ := F
  simp only at he
  subst he
  rfl

/-- **Relative orbits.**  The orbits of the stabiliser of the tuple `u` on those `s`-tuples that
are injective and avoid the image of `u`. -/
def RelOrbit {r : ℕ} (u : Fin r → X) (s : ℕ) : Type _ :=
  {c : orbitRel.Quotient (stabilizer G u) (Fin s → X) //
    ∃ v : Fin s → X, Injective v ∧ Disjoint (Set.range u) (Set.range v) ∧
      Quotient.mk (orbitRel (stabilizer G u) (Fin s → X)) v = c}

/-- The number of relative orbits. -/
noncomputable def relCount {r : ℕ} (u : Fin r → X) (s : ℕ) : ℕ := Nat.card (RelOrbit G u s)

instance [Finite X] {r : ℕ} (u : Fin r → X) (s : ℕ) : Finite (RelOrbit G u s) := by
  unfold RelOrbit; infer_instance

variable {G}

theorem smul_append {r s : ℕ} (g : G) (u : Fin r → X) (v : Fin s → X) :
    g • Fin.append u v = Fin.append (g • u) (g • v) := by
  funext i
  refine Fin.addCases (fun i => ?_) (fun i => ?_) i
  · show g • Fin.append u v (Fin.castAdd s i) = _
    rw [Fin.append_left, Fin.append_left]; rfl
  · show g • Fin.append u v (Fin.natAdd r i) = _
    rw [Fin.append_right, Fin.append_right]; rfl

/-- Every representative of a relative orbit is injective and avoids `u`. -/
theorem RelOrbit.spec_of_mk_eq {r s : ℕ} {u : Fin r → X} (c : RelOrbit G u s) {v : Fin s → X}
    (hv : Quotient.mk (orbitRel (stabilizer G u) (Fin s → X)) v = c.1) :
    Injective v ∧ Disjoint (Set.range u) (Set.range v) := by
  obtain ⟨v₀, hinj, hdisj, he⟩ := c.2
  obtain ⟨⟨h, hh⟩, hhv⟩ := (orbitRel_apply).1 (Quotient.exact (he.trans hv.symm))
  have hhv' : h • v = v₀ := hhv
  have hhu : h • u = u := mem_stabilizer_iff.1 hh
  refine ⟨injective_of_smul_eq hhv' hinj, ?_⟩
  rw [Set.disjoint_left]
  rintro _ ⟨i, rfl⟩ ⟨j, hj⟩
  have h1 : u i = v₀ j := by
    rw [← hhu, ← hhv']
    show h • u i = h • v j
    rw [hj]
  exact Set.disjoint_left.1 hdisj ⟨i, rfl⟩ ⟨j, h1.symm⟩

/-- The fibre map: extend the fixed representative `u` of `o` by a relative orbit. -/
noncomputable def extendOrbit {r s : ℕ} (o : InjOrbit G X r) (c : RelOrbit G o.1.out s) :
    {F : InjOrbit G X (r + s) // restrictOrbit G r s F = o} :=
  have hc := c.spec_of_mk_eq (Quotient.out_eq c.1)
  ⟨⟨Quotient.mk _ (Fin.append o.1.out c.1.out), Fin.append o.1.out c.1.out,
    Fin.append_injective_iff.2 ⟨o.injective_of_mk_eq (Quotient.out_eq o.1), hc.1,
      fun i j hij => Set.disjoint_left.1 hc.2 ⟨i, rfl⟩ ⟨j, hij.symm⟩⟩, rfl⟩, by
    apply Subtype.ext
    show Quotient.mk _ (Fin.append o.1.out c.1.out ∘ Fin.castAdd s) = o.1
    have : Fin.append o.1.out c.1.out ∘ Fin.castAdd s = o.1.out := funext fun i => by
      simp [Fin.append_left]
    rw [this, Quotient.out_eq]⟩

theorem extendOrbit_bijective {r s : ℕ} (o : InjOrbit G X r) :
    Bijective (extendOrbit (s := s) o) := by
  constructor
  · intro c c' hcc
    have h := congrArg (fun F => F.1.1) hcc
    simp only [extendOrbit] at h
    obtain ⟨g, hg⟩ := exists_smul_of_mk_eq h
    rw [smul_append] at hg
    have hgu : g • o.1.out = o.1.out := by
      funext i
      have := congrFun hg (Fin.castAdd s i)
      simpa [Fin.append_left] using this
    have hgv : g • c'.1.out = c.1.out := by
      funext i
      have := congrFun hg (Fin.natAdd r i)
      simpa [Fin.append_right] using this
    apply Subtype.ext
    rw [← Quotient.out_eq c.1, ← Quotient.out_eq c'.1]
    exact Quotient.sound ((orbitRel_apply).2 ⟨⟨g, mem_stabilizer_iff.2 hgu⟩, hgv⟩)
  · rintro ⟨F, hF⟩
    obtain ⟨F₁, hF₁, he⟩ := F.2
    have hr : Quotient.mk (orbitRel G (Fin r → X)) (F₁ ∘ Fin.castAdd s) = o.1 := by
      have := congrArg Subtype.val hF
      rw [← this, restrictOrbit_val G F he]
    obtain ⟨g, hg⟩ := exists_smul_of_mk_eq (hr.trans (Quotient.out_eq o.1).symm)
    set u := o.1.out with hu_def
    set F₀ := g⁻¹ • F₁ with hF₀
    have hF₀u : F₀ ∘ Fin.castAdd s = u := by
      funext i
      show g⁻¹ • F₁ (Fin.castAdd s i) = u i
      rw [show F₁ (Fin.castAdd s i) = g • u i from (congrFun hg i).symm]
      exact inv_smul_smul g (u i)
    have hF₀inj : Injective F₀ := injective_of_smul_eq (smul_inv_smul g F₁) hF₁
    set v := F₀ ∘ Fin.natAdd r with hv
    have happ : Fin.append u v = F₀ := by
      rw [← hF₀u]
      exact Fin.append_castAdd_natAdd
    have hvinj : Injective v := hF₀inj.comp (Fin.natAdd_injective _ _)
    have hdisj : Disjoint (Set.range u) (Set.range v) := by
      rw [Set.disjoint_left]
      rintro _ ⟨i, rfl⟩ ⟨j, hj⟩
      rw [← hF₀u] at hj
      have := hF₀inj hj
      exact absurd (congrArg Fin.val this) (by simp; omega)
    refine ⟨⟨Quotient.mk _ v, v, hvinj, hdisj, rfl⟩, ?_⟩
    apply Subtype.ext
    apply Subtype.ext
    obtain ⟨⟨h, hh⟩, hhv⟩ := (orbitRel_apply).1
      (Quotient.mk_out (s := orbitRel (stabilizer G u) (Fin s → X)) v)
    have hhv' : h • v = (Quotient.mk (orbitRel (stabilizer G u) (Fin s → X)) v).out := hhv
    have hhu : h • u = u := mem_stabilizer_iff.1 hh
    show Quotient.mk _ (Fin.append u
      (Quotient.mk (orbitRel (stabilizer G u) (Fin s → X)) v).out) = F.1
    rw [← hhv', ← he]
    calc Quotient.mk (orbitRel G (Fin (r + s) → X)) (Fin.append u (h • v))
        = Quotient.mk _ (Fin.append (h • u) (h • v)) := by rw [hhu]
      _ = Quotient.mk _ (h • F₀) := by rw [← smul_append, happ]
      _ = Quotient.mk _ F₀ := Quotient.sound ((orbitRel_apply).2 ⟨h, rfl⟩)
      _ = Quotient.mk _ F₁ := Quotient.sound ((orbitRel_apply).2 ⟨g⁻¹, rfl⟩)

/-- The fibre of the restriction map over `o` has exactly `relCount G o.out s` elements. -/
theorem card_restrict_fibre {r s : ℕ} (o : InjOrbit G X r) :
    Nat.card {F : InjOrbit G X (r + s) // restrictOrbit G r s F = o} = relCount G o.1.out s :=
  (Nat.card_eq_of_bijective _ (extendOrbit_bijective (s := s) o)).symm

variable (G X)

/-- **The fibration formula (exact form of Conjecture M).**  Cutting an injective `(r+s)`-tuple
into its first `r` and last `s` coordinates fibres the orbits at level `r+s` over the orbits at
level `r`; the fibre over the orbit of `u` is the set of stabiliser-orbits of injective `s`-tuples
avoiding `u`.  Hence `t_{r+s} = Σ_{[u]} #(Stab(u) \ Inj_s(X ∖ u))`. -/
theorem tInj_add_eq_sum_relCount [Finite X] (r s : ℕ) :
    tInj G X (r + s) = ∑ᶠ o : InjOrbit G X r, relCount G o.1.out s := by
  classical
  letI : Fintype (InjOrbit G X r) := Fintype.ofFinite _
  rw [finsum_eq_sum_of_fintype, tInj,
    ← Nat.card_congr (Equiv.sigmaFiberEquiv (restrictOrbit G r s)), Nat.card_sigma]
  exact Finset.sum_congr rfl fun o _ => card_restrict_fibre o

variable {G X}

/-- Every avoiding orbit is hit by a relative orbit: stabiliser-orbits refine the `G`-orbits. -/
theorem avoidCount_le_relCount [Finite X] {r : ℕ} (o : InjOrbit G X r) (s : ℕ) :
    avoidCount G X o s ≤ relCount G o.1.out s := by
  refine Nat.card_le_card_of_surjective
    (fun c : RelOrbit G o.1.out s =>
      (⟨⟨Quotient.mk (orbitRel G (Fin s → X)) c.1.out, c.1.out,
        (c.spec_of_mk_eq (Quotient.out_eq c.1)).1, rfl⟩,
        o.1.out, c.1.out, Quotient.out_eq o.1, rfl,
        (c.spec_of_mk_eq (Quotient.out_eq c.1)).2⟩ : {q : InjOrbit G X s // Avoids o q})) ?_
  rintro ⟨q, u, v, hu', hv, hd⟩
  obtain ⟨g, hg⟩ := exists_smul_of_mk_eq (hu'.trans (Quotient.out_eq o.1).symm)
  set w := o.1.out
  have hvinj : Injective v := q.injective_of_mk_eq hv
  have hv'inj : Injective (g⁻¹ • v) := injective_of_smul_eq (smul_inv_smul g v) hvinj
  have hd' : Disjoint (Set.range w) (Set.range (g⁻¹ • v)) := by
    rw [Set.disjoint_left]
    rintro _ ⟨i, rfl⟩ ⟨j, hj⟩
    have h1 : u i = v j := by
      rw [← hg]
      show g • w i = v j
      rw [← hj]
      exact smul_inv_smul g (v j)
    exact Set.disjoint_left.1 hd ⟨i, rfl⟩ ⟨j, h1.symm⟩
  refine ⟨⟨Quotient.mk _ (g⁻¹ • v), g⁻¹ • v, hv'inj, hd', rfl⟩, ?_⟩
  obtain ⟨⟨h, hmem⟩, hh⟩ := (orbitRel_apply).1
    (Quotient.mk_out (s := orbitRel (stabilizer G w) (Fin s → X)) (g⁻¹ • v))
  have hh' : h • (g⁻¹ • v) = (Quotient.mk (orbitRel (stabilizer G w) (Fin s → X))
    (g⁻¹ • v)).out := hh
  apply Subtype.ext
  apply Subtype.ext
  show Quotient.mk _ (Quotient.mk (orbitRel (stabilizer G w) (Fin s → X)) (g⁻¹ • v)).out = q.1
  rw [← hh', ← hv]
  exact Quotient.sound ((orbitRel_apply).2 ⟨h * g⁻¹, mul_smul h g⁻¹ v⟩)

variable (G X)

/-- The fibration formula recovers the refined avoidance bound
`Σ_o a(o, s) ≤ t_{r+s}` term by term. -/
theorem sum_avoidCount_le_sum_relCount [Finite X] (r s : ℕ) :
    ∑ᶠ o : InjOrbit G X r, avoidCount G X o s ≤ ∑ᶠ o : InjOrbit G X r, relCount G o.1.out s := by
  classical
  letI : Fintype (InjOrbit G X r) := Fintype.ofFinite _
  rw [finsum_eq_sum_of_fintype, finsum_eq_sum_of_fintype]
  exact Finset.sum_le_sum fun o _ => avoidCount_le_relCount o s

/-- **Transitivity through the fibration.**  If `G` is transitive on injective `(r+s)`-tuples
(`t_{r+s} = 1`), then the relative orbit count over every injective `r`-tuple orbit is `≤ 1`, and
there is exactly one injective `r`-tuple orbit carrying the fibre. -/
theorem relCount_le_one_of_tInj_eq_one [Finite X] (r s : ℕ) (h : tInj G X (r + s) = 1)
    (o : InjOrbit G X r) : relCount G o.1.out s ≤ 1 := by
  classical
  letI : Fintype (InjOrbit G X r) := Fintype.ofFinite _
  have := tInj_add_eq_sum_relCount G X r s
  rw [h, finsum_eq_sum_of_fintype] at this
  have hle := Finset.single_le_sum (f := fun o : InjOrbit G X r => relCount G o.1.out s)
    (fun _ _ => Nat.zero_le _) (Finset.mem_univ o)
  simp only at hle
  omega

variable {G X}

/-- The injective `s`-tuples avoiding an injective `r`-tuple number `(|X| - r)^{\underline{s}}`. -/
theorem card_avoiding_injective [Finite X] {r : ℕ} {u : Fin r → X} (hu : Injective u) (s : ℕ) :
    Nat.card {v : Fin s → X // Injective v ∧ Disjoint (Set.range u) (Set.range v)}
      = (Nat.card X - r).descFactorial s := by
  classical
  letI := Fintype.ofFinite X
  let e : {v : Fin s → X // Injective v ∧ Disjoint (Set.range u) (Set.range v)} ≃
      (Fin s ↪ {x : X // x ∉ Set.range u}) :=
    { toFun := fun v => ⟨fun i => ⟨v.1 i, fun hx => Set.disjoint_left.1 v.2.2 hx ⟨i, rfl⟩⟩,
        fun i j hij => v.2.1 (congrArg Subtype.val hij)⟩
      invFun := fun w => ⟨fun i => (w i).1, fun i j hij => w.injective (Subtype.ext hij), by
        rw [Set.disjoint_left]
        rintro _ hx ⟨j, rfl⟩
        exact (w j).2 hx⟩
      left_inv := fun v => rfl
      right_inv := fun w => rfl }
  rw [Nat.card_congr e, Nat.card_eq_fintype_card, Fintype.card_embedding_eq, Fintype.card_fin,
    Fintype.card_subtype_compl, Nat.card_eq_fintype_card]
  have hr : Fintype.card {x // x ∈ Set.range u} = r := by
    have := Set.card_range_of_injective hu
    rw [Fintype.card_fin] at this
    convert this
  rw [hr]

/-- If the stabiliser of `u` is trivial, the relative orbits are just the avoiding injective
tuples. -/
theorem relCount_of_stabilizer_trivial [Finite X] {r : ℕ} {u : Fin r → X} (hu : Injective u)
    (hstab : ∀ g : G, g • u = u → g = 1) (s : ℕ) :
    relCount G u s = (Nat.card X - r).descFactorial s := by
  rw [← card_avoiding_injective hu s, relCount]
  symm
  refine Nat.card_eq_of_bijective (fun v => ⟨Quotient.mk _ v.1, v.1, v.2.1, v.2.2, rfl⟩) ⟨?_, ?_⟩
  · intro v v' h
    obtain ⟨⟨g, hg⟩, hgv⟩ := (orbitRel_apply).1 (Quotient.exact (congrArg Subtype.val h))
    have h1 : g = 1 := hstab g (mem_stabilizer_iff.1 hg)
    subst h1
    apply Subtype.ext
    exact hgv.symm.trans (one_smul G v'.1)
  · rintro ⟨c, v, hinj, hd, rfl⟩
    exact ⟨⟨v, hinj, hd⟩, rfl⟩

variable (G X)

/-- **Free actions saturate the fibration.**  If every injective `r`-tuple has trivial stabiliser
(e.g. `r ≥ 1` and the action is free), then `t_{r+s} = t_r · (|X| - r)^{\underline{s}}`
exactly. -/
theorem tInj_add_eq_of_free [Finite X] (r s : ℕ)
    (hfree : ∀ u : Fin r → X, Injective u → ∀ g : G, g • u = u → g = 1) :
    tInj G X (r + s) = tInj G X r * (Nat.card X - r).descFactorial s := by
  classical
  letI : Fintype (InjOrbit G X r) := Fintype.ofFinite _
  rw [tInj_add_eq_sum_relCount, finsum_eq_sum_of_fintype]
  rw [Finset.sum_congr rfl fun o _ => relCount_of_stabilizer_trivial
    (o.injective_of_mk_eq (Quotient.out_eq o.1)) (hfree _ (o.injective_of_mk_eq
      (Quotient.out_eq o.1))) s]
  rw [Finset.sum_const, Finset.card_univ, smul_eq_mul, tInj, ← Nat.card_eq_fintype_card]

variable {G X}

/-- Relative orbits are at most as numerous as the avoiding injective tuples. -/
theorem relCount_le [Finite X] {r : ℕ} {u : Fin r → X} (hu : Injective u) (s : ℕ) :
    relCount G u s ≤ (Nat.card X - r).descFactorial s := by
  rw [← card_avoiding_injective hu s, relCount]
  refine Nat.card_le_card_of_surjective
    (fun v => (⟨Quotient.mk _ v.1, v.1, v.2.1, v.2.2, rfl⟩ : RelOrbit G u s)) ?_
  rintro ⟨c, v, hinj, hd, rfl⟩
  exact ⟨⟨v, hinj, hd⟩, rfl⟩

variable (G X)

/-- **Upper half of the sandwich:** `t_{r+s} ≤ t_r · (|X| − r)^{\underline{s}}`, with equality for
free actions (`tInj_add_eq_of_free`). -/
theorem tInj_add_le [Finite X] (r s : ℕ) :
    tInj G X (r + s) ≤ tInj G X r * (Nat.card X - r).descFactorial s := by
  classical
  letI : Fintype (InjOrbit G X r) := Fintype.ofFinite _
  rw [tInj_add_eq_sum_relCount, finsum_eq_sum_of_fintype, tInj, Nat.card_eq_fintype_card,
    ← Finset.card_univ, ← smul_eq_mul, ← Finset.sum_const]
  exact Finset.sum_le_sum fun o _ =>
    relCount_le (o.injective_of_mk_eq (Quotient.out_eq o.1)) s

variable {G X}

/-- **The correct correction term.**  At most `|X|^{\underline{s}} − (|X| − r)^{\underline{s}}`
orbits of injective `s`-tuples (the number of injective `s`-tuples meeting a given injective
`r`-tuple) fail to avoid an orbit of injective `r`-tuples.  For `s = 1` the correction is `r`. -/
theorem tInj_le_avoidCount_add [Finite X] {r : ℕ} (o : InjOrbit G X r) (s : ℕ) :
    tInj G X s ≤ avoidCount G X o s
      + ((Nat.card X).descFactorial s - (Nat.card X - r).descFactorial s) := by
  classical
  letI := Fintype.ofFinite X
  letI : Fintype (InjOrbit G X s) := Fintype.ofFinite _
  obtain ⟨u, hu, hu'⟩ := o.2
  let B := {v : {v : Fin s → X // Injective v} // ¬ Disjoint (Set.range u) (Set.range v.1)}
  have hB : Nat.card B = (Nat.card X).descFactorial s - (Nat.card X - r).descFactorial s := by
    have h1 : Nat.card {v : Fin s → X // Injective v} = (Nat.card X).descFactorial s := by
      rw [Nat.card_congr (Equiv.subtypeInjectiveEquivEmbedding (Fin s) X),
        Nat.card_eq_fintype_card, Fintype.card_embedding_eq, Fintype.card_fin,
        Nat.card_eq_fintype_card]
    have h2 : Nat.card {v : {v : Fin s → X // Injective v} //
        Disjoint (Set.range u) (Set.range v.1)} = (Nat.card X - r).descFactorial s := by
      rw [← card_avoiding_injective hu s]
      exact Nat.card_congr (Equiv.subtypeSubtypeEquivSubtypeInter
        (fun v : Fin s → X => Injective v) (fun v => Disjoint (Set.range u) (Set.range v)))
    rw [← h1, ← h2]
    simp only [B, Nat.card_eq_fintype_card]
    exact Fintype.card_subtype_compl _
  have hbad : ∀ q : {q : InjOrbit G X s // ¬ Avoids o q},
      ¬ Disjoint (Set.range u) (Set.range (Classical.choose q.1.2)) := fun q hd =>
    q.2 ⟨u, _, hu', (Classical.choose_spec q.1.2).2, hd⟩
  have hle : Nat.card {q : InjOrbit G X s // ¬ Avoids o q} ≤ Nat.card B := by
    refine Nat.card_le_card_of_injective
      (fun q => (⟨⟨Classical.choose q.1.2, (Classical.choose_spec q.1.2).1⟩, hbad q⟩ : B)) ?_
    intro q q' hqq
    have hv : Classical.choose q.1.2 = Classical.choose q'.1.2 :=
      congrArg (fun b : B => b.1.1) hqq
    apply Subtype.ext
    apply Subtype.ext
    rw [← (Classical.choose_spec q.1.2).2, ← (Classical.choose_spec q'.1.2).2, hv]
  have hsplit : Nat.card {q : InjOrbit G X s // Avoids o q}
      + Nat.card {q : InjOrbit G X s // ¬ Avoids o q} = tInj G X s := by
    rw [tInj, Nat.card_eq_fintype_card, Nat.card_eq_fintype_card, Nat.card_eq_fintype_card,
      Fintype.card_subtype_compl]
    have := Fintype.card_subtype_le (fun q : InjOrbit G X s => Avoids o q)
    omega
  rw [avoidCount]
  omega

variable (G X)

/-- **The coarse form of Conjecture M, repaired:**
`t_{r+s} ≥ t_r · (t_s − (|X|^{\underline{s}} − (|X| − r)^{\underline{s}}))`.
For `s = 1` this is `t_{r+1} ≥ t_r · (t_1 − r)`, and for trivial actions it is an equality. -/
theorem tInj_mul_sub_correction_le [Finite X] (r s : ℕ) :
    tInj G X r * (tInj G X s - ((Nat.card X).descFactorial s - (Nat.card X - r).descFactorial s))
      ≤ tInj G X (r + s) :=
  tInj_mul_le_of_avoidCount G X r s _ fun o => by
    have := tInj_le_avoidCount_add o s
    omega

end Fibration

end MultiplicativeHierarchy