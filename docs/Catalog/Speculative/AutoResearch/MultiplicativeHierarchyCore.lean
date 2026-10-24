import Mathlib

/-!
# Conjecture M: the multiplicative hierarchy of the injective-orbit spectrum (core)

Let a group `G` act on a finite set `X` and let `t_r` be the number of `G`-orbits of injective
`r`-tuples (`tInj G X r`; it coincides with the catalog invariant `FibreSpectrum.injOrbits`, see
`Catalog/Bridges/MultiplicativeHierarchyBridge.lean`).

## Main results

* `sum_avoidCount_le` (refined form of Conjecture M): concatenation of representatives is an
  injection, so `Σ_{[u]} a([u], s) ≤ t_{r+s}`, where `a([u], s)` counts the orbits of injective
  `s`-tuples that can be placed disjointly from `u`.
* `tInj_mul_le_of_avoidCount`: `t_{r+s} ≥ t_r · m` when every `a([u], s) ≥ m`.
* `tInj_one_le_avoidCount_add`: `a([u], 1) ≥ t_1 − r`.
* `tInj_mul_sub_le_succ`: `t_{r+1} ≥ t_r · (t_1 − r)`.
* `tInj_mul_descFactorial_le` (**corrected Conjecture M**):
  `t_{r+s} ≥ t_r · (t_1 − r)^{\underline{s}}` for all `r, s`, with base case
  `descFactorial_tInj_one_le : t_s ≥ t_1^{\underline{s}}`.
* `tInj_of_trivial`, `tInj_hierarchy_eq_of_trivial`: for trivial actions `t_r = |X|^{\underline{r}}`
  and every inequality of the hierarchy is an equality (sharpness).
* `coarse_conjecture_false`: the coarse form `t_{r+s} ≥ t_r · (t_s − r)` is **false**
  (trivial group on three points, `r = 1`, `s = 2`: `6 < 3 · 5`).

No `sorry`, no `native_decide`, no new axioms.
-/

open MulAction Function

namespace MultiplicativeHierarchy

section Basic

variable (G : Type*) [Group G] (X : Type*) [MulAction G X]

/-- Orbits of injective `r`-tuples. -/
def InjOrbit (r : ℕ) : Type _ :=
  {o : orbitRel.Quotient G (Fin r → X) //
    ∃ f : Fin r → X, Injective f ∧ Quotient.mk (orbitRel G (Fin r → X)) f = o}

/-- `t_r`: the number of orbits of injective `r`-tuples. -/
noncomputable def tInj (r : ℕ) : ℕ := Nat.card (InjOrbit G X r)

instance [Finite X] (r : ℕ) : Finite (InjOrbit G X r) := by
  unfold InjOrbit; infer_instance

variable {G X}

/-- Two tuples in the same orbit are related by a group element. -/
theorem exists_smul_of_mk_eq {r : ℕ} {f f' : Fin r → X}
    (h : Quotient.mk (orbitRel G (Fin r → X)) f = Quotient.mk (orbitRel G (Fin r → X)) f') :
    ∃ g : G, g • f' = f :=
  (orbitRel_apply).1 (Quotient.exact h)

theorem injective_of_smul_eq {r : ℕ} {f f' : Fin r → X} {g : G} (h : g • f' = f)
    (hf : Injective f) : Injective f' := by
  intro i j hij
  apply hf
  rw [← h]
  show g • f' i = g • f' j
  rw [hij]

/-- Every representative of an injective orbit is injective. -/
theorem InjOrbit.injective_of_mk_eq {r : ℕ} (o : InjOrbit G X r) {f : Fin r → X}
    (hf : Quotient.mk (orbitRel G (Fin r → X)) f = o.1) : Injective f := by
  obtain ⟨f₀, hf₀, he⟩ := o.2
  obtain ⟨g, hg⟩ := exists_smul_of_mk_eq (he.trans hf.symm)
  exact injective_of_smul_eq hg hf₀

/-- The **avoidance relation**: the orbit `o` of injective `r`-tuples and the orbit `q` of
injective `s`-tuples admit representatives with disjoint images. -/
def Avoids {r s : ℕ} (o : InjOrbit G X r) (q : InjOrbit G X s) : Prop :=
  ∃ u : Fin r → X, ∃ v : Fin s → X, Quotient.mk (orbitRel G (Fin r → X)) u = o.1 ∧
    Quotient.mk (orbitRel G (Fin s → X)) v = q.1 ∧ Disjoint (Set.range u) (Set.range v)

variable (G X)

/-- `a(o, s)`: the number of orbits of injective `s`-tuples that can be placed so as to avoid a
representative of the injective `r`-tuple orbit `o`. -/
noncomputable def avoidCount {r : ℕ} (o : InjOrbit G X r) (s : ℕ) : ℕ :=
  Nat.card {q : InjOrbit G X s // Avoids o q}

end Basic

/-! ## The concatenation injection -/

section Concat

variable {G : Type*} [Group G] {X : Type*} [MulAction G X]

theorem append_injective_of_avoids {r s : ℕ} {o : InjOrbit G X r} {q : InjOrbit G X s}
    {u : Fin r → X} {v : Fin s → X} (hu : Quotient.mk (orbitRel G (Fin r → X)) u = o.1)
    (hv : Quotient.mk (orbitRel G (Fin s → X)) v = q.1)
    (hd : Disjoint (Set.range u) (Set.range v)) : Injective (Fin.append u v) := by
  refine Fin.append_injective_iff.2 ⟨o.injective_of_mk_eq hu, q.injective_of_mk_eq hv, ?_⟩
  intro i j hij
  exact Set.disjoint_left.1 hd ⟨i, rfl⟩ ⟨j, hij.symm⟩

/-- Concatenate chosen representatives of an avoiding pair, giving an orbit of injective
`(r+s)`-tuples. -/
noncomputable def concatOrbit {r s : ℕ}
    (p : Σ o : InjOrbit G X r, {q : InjOrbit G X s // Avoids o q}) : InjOrbit G X (r + s) :=
  let u := Classical.choose p.2.2
  let hv := Classical.choose_spec p.2.2
  let v := Classical.choose hv
  have h := Classical.choose_spec hv
  ⟨Quotient.mk _ (Fin.append u v), Fin.append u v, append_injective_of_avoids h.1 h.2.1 h.2.2, rfl⟩

theorem concatOrbit_spec {r s : ℕ}
    (p : Σ o : InjOrbit G X r, {q : InjOrbit G X s // Avoids o q}) :
    ∃ u : Fin r → X, ∃ v : Fin s → X, Quotient.mk (orbitRel G (Fin r → X)) u = p.1.1 ∧
      Quotient.mk (orbitRel G (Fin s → X)) v = p.2.1.1 ∧
      (concatOrbit p).1 = Quotient.mk (orbitRel G (Fin (r + s) → X)) (Fin.append u v) := by
  have hv := Classical.choose_spec p.2.2
  have h := Classical.choose_spec hv
  exact ⟨_, _, h.1, h.2.1, rfl⟩

/-- Concatenation is injective: an orbit of `(r+s)`-tuples remembers the orbits of its first `r`
and last `s` coordinates. -/
theorem concatOrbit_injective {r s : ℕ} :
    Injective (concatOrbit (G := G) (X := X) (r := r) (s := s)) := by
  intro p p' hpp
  obtain ⟨u, v, hu, hv, he⟩ := concatOrbit_spec p
  obtain ⟨u', v', hu', hv', he'⟩ := concatOrbit_spec p'
  have hq := congrArg Subtype.val hpp
  rw [he, he'] at hq
  obtain ⟨g, hg⟩ := exists_smul_of_mk_eq hq
  have hgu : g • u' = u := by
    funext i
    have := congrFun hg (Fin.castAdd s i)
    simpa [Fin.append_left] using this
  have hgv : g • v' = v := by
    funext i
    have := congrFun hg (Fin.natAdd r i)
    simpa [Fin.append_right] using this
  have h1 : p.1 = p'.1 := by
    apply Subtype.ext
    rw [← hu, ← hu', ← hgu]
    exact Quotient.sound ((orbitRel_apply).2 ⟨g, rfl⟩)
  have h2 : p.2.1.1 = p'.2.1.1 := by
    rw [← hv, ← hv', ← hgv]
    exact Quotient.sound ((orbitRel_apply).2 ⟨g, rfl⟩)
  obtain ⟨o, q, hq⟩ := p
  obtain ⟨o', q', hq'⟩ := p'
  simp only at h1 h2
  subst h1
  have : q = q' := Subtype.ext h2
  subst this
  rfl

variable (G X)

/-- **Relative multiplicativity (refined form).**  Summing the avoidance counts over all orbits of
injective `r`-tuples gives a lower bound for `t_{r+s}`. -/
theorem sum_avoidCount_le [Finite X] (r s : ℕ) :
    ∑ᶠ o : InjOrbit G X r, avoidCount G X o s ≤ tInj G X (r + s) := by
  classical
  letI : Fintype (InjOrbit G X r) := Fintype.ofFinite _
  rw [finsum_eq_sum_of_fintype]
  have hσ := Nat.card_sigma (β := fun o : InjOrbit G X r => {q : InjOrbit G X s // Avoids o q})
  simp only [avoidCount]
  rw [← hσ]
  exact Nat.card_le_card_of_injective _ concatOrbit_injective

/-- **Relative multiplicativity (uniform form).**  If every orbit of injective `r`-tuples is
avoided by at least `m` orbits of injective `s`-tuples, then `t_{r+s} ≥ t_r · m`. -/
theorem tInj_mul_le_of_avoidCount [Finite X] (r s m : ℕ)
    (hm : ∀ o : InjOrbit G X r, m ≤ avoidCount G X o s) :
    tInj G X r * m ≤ tInj G X (r + s) := by
  classical
  letI : Fintype (InjOrbit G X r) := Fintype.ofFinite _
  refine le_trans ?_ (sum_avoidCount_le G X r s)
  rw [finsum_eq_sum_of_fintype, tInj, Nat.card_eq_fintype_card, ← Finset.card_univ,
    ← smul_eq_mul, ← Finset.sum_const]
  exact Finset.sum_le_sum fun o _ => hm o

end Concat

/-! ## Small levels: `t_0 = 1` and `t_1 = #(X/G)` -/

section SmallLevels

variable (G : Type*) [Group G] (X : Type*) [MulAction G X]

theorem tInj_zero : tInj G X 0 = 1 := by
  refine Nat.card_eq_one_iff_unique.2 ⟨⟨fun a b => Subtype.ext (Subsingleton.elim _ _)⟩, ?_⟩
  exact ⟨⟨Quotient.mk _ finZeroElim, finZeroElim, fun i => i.elim0, rfl⟩⟩

/-- `t_1` is the number of orbits of `G` on `X`. -/
theorem tInj_one : tInj G X 1 = Nat.card (orbitRel.Quotient G X) := by
  refine Nat.card_eq_of_bijective (fun o => Quotient.mk (orbitRel G X) (o.1.out 0)) ⟨?_, ?_⟩
  · intro o o' h
    obtain ⟨g, hg⟩ := (orbitRel_apply).1 (Quotient.exact h)
    apply Subtype.ext
    rw [← Quotient.out_eq o.1, ← Quotient.out_eq o'.1]
    refine Quotient.sound ((orbitRel_apply).2 ⟨g, ?_⟩)
    funext i
    rw [Subsingleton.elim i 0]
    exact hg
  · intro q
    induction q using Quotient.inductionOn with
    | h x =>
      refine ⟨⟨Quotient.mk _ (fun _ => x), fun _ => x,
        fun i j _ => Subsingleton.elim i j, rfl⟩, ?_⟩
      obtain ⟨g, hg⟩ := (orbitRel_apply).1
        (Quotient.mk_out (s := orbitRel G (Fin 1 → X)) (fun _ : Fin 1 => x))
      exact Quotient.sound ((orbitRel_apply).2 ⟨g, congrFun hg 0⟩)

variable {G X}

/-- **The one-coordinate avoidance bound.**  At most `r` orbits of points fail to avoid a given
injective `r`-tuple orbit, so `a(o, 1) ≥ t_1 − r`. -/
theorem tInj_one_le_avoidCount_add [Finite X] {r : ℕ} (o : InjOrbit G X r) :
    tInj G X 1 ≤ avoidCount G X o 1 + r := by
  classical
  obtain ⟨u, -, hu⟩ := o.2
  letI : Fintype (InjOrbit G X 1) := Fintype.ofFinite _
  have hbad : ∀ q : {q : InjOrbit G X 1 // ¬ Avoids o q},
      ∃ i : Fin r, u i = (Classical.choose q.1.2) 0 := by
    intro q
    by_contra hne
    push_neg at hne
    apply q.2
    refine ⟨u, Classical.choose q.1.2, hu, (Classical.choose_spec q.1.2).2, ?_⟩
    rw [Set.disjoint_left]
    rintro _ ⟨i, rfl⟩ ⟨j, hj⟩
    rw [Subsingleton.elim j 0] at hj
    exact hne i hj.symm
  have hle : Nat.card {q : InjOrbit G X 1 // ¬ Avoids o q} ≤ r := by
    have := Nat.card_le_card_of_injective (fun q => Classical.choose (hbad q)) (by
      intro q q' hqq
      have h1 := Classical.choose_spec (hbad q)
      have h2 := Classical.choose_spec (hbad q')
      simp only at hqq
      rw [hqq] at h1
      have hv : Classical.choose q.1.2 = Classical.choose q'.1.2 := by
        funext i
        rw [Subsingleton.elim i 0, ← h1]; exact h2
      apply Subtype.ext
      apply Subtype.ext
      rw [← (Classical.choose_spec q.1.2).2, ← (Classical.choose_spec q'.1.2).2, hv])
    simpa using this
  have hsplit : Nat.card {q : InjOrbit G X 1 // Avoids o q}
      + Nat.card {q : InjOrbit G X 1 // ¬ Avoids o q} = tInj G X 1 := by
    rw [tInj, Nat.card_eq_fintype_card, Nat.card_eq_fintype_card, Nat.card_eq_fintype_card,
      Fintype.card_subtype_compl]
    have := Fintype.card_subtype_le (fun q : InjOrbit G X 1 => Avoids o q)
    omega
  rw [avoidCount]
  omega

end SmallLevels

/-! ## The multiplicative hierarchy -/

section Hierarchy

variable (G : Type*) [Group G] (X : Type*) [MulAction G X] [Finite X]

/-- **One step of the hierarchy:** `t_{r+1} ≥ t_r · (t_1 − r)`.  No hypothesis on `r` is needed. -/
theorem tInj_mul_sub_le_succ (r : ℕ) :
    tInj G X r * (tInj G X 1 - r) ≤ tInj G X (r + 1) :=
  tInj_mul_le_of_avoidCount G X r 1 _ fun o => by
    have := tInj_one_le_avoidCount_add o
    omega

/-- **Conjecture M, corrected form (the full multiplicative hierarchy):**
`t_{r+s} ≥ t_r · (t_1 − r)^{\underline{s}}` (falling factorial), for all `r, s`. -/
theorem tInj_mul_descFactorial_le (r s : ℕ) :
    tInj G X r * (tInj G X 1 - r).descFactorial s ≤ tInj G X (r + s) := by
  induction s with
  | zero => simp
  | succ s ih =>
    have hstep := tInj_mul_sub_le_succ G X (r + s)
    rw [Nat.descFactorial_succ, ← add_assoc]
    have h1 : tInj G X 1 - r - s = tInj G X 1 - (r + s) := by omega
    rw [h1]
    calc tInj G X r * ((tInj G X 1 - (r + s)) * (tInj G X 1 - r).descFactorial s)
        = (tInj G X r * (tInj G X 1 - r).descFactorial s) * (tInj G X 1 - (r + s)) := by ring
      _ ≤ tInj G X (r + s) * (tInj G X 1 - (r + s)) := Nat.mul_le_mul_right _ ih
      _ ≤ tInj G X (r + s + 1) := hstep

/-- The case `r = 0`: `t_s ≥ t_1 (t_1 − 1) ⋯ (t_1 − s + 1)`. -/
theorem descFactorial_tInj_one_le (s : ℕ) :
    (tInj G X 1).descFactorial s ≤ tInj G X s := by
  simpa [tInj_zero] using tInj_mul_descFactorial_le G X 0 s

/-- Corollary: monotonicity of the spectrum within the range `r < t_1`, in multiplicative form
`t_r · (t_1 − r) ≤ t_{r+1}`; in particular `t_r ≤ t_{r+1}` whenever `r < t_1`. -/
theorem tInj_le_succ_of_lt (r : ℕ) (hr : r < tInj G X 1) : tInj G X r ≤ tInj G X (r + 1) := by
  have := tInj_mul_sub_le_succ G X r
  calc tInj G X r = tInj G X r * 1 := (mul_one _).symm
    _ ≤ tInj G X r * (tInj G X 1 - r) := Nat.mul_le_mul_left _ (by omega)
    _ ≤ _ := this

end Hierarchy

/-! ## Sharpness: trivial actions, and the failure of the coarse conjecture -/

section Trivial

variable (G : Type*) [Group G] (X : Type*) [MulAction G X]

/-- For a trivial action, `t_r` is the number of injective `r`-tuples, `|X|^{\underline{r}}`. -/
theorem tInj_of_trivial [Finite X] (htriv : ∀ (g : G) (x : X), g • x = x) (r : ℕ) :
    tInj G X r = (Nat.card X).descFactorial r := by
  classical
  letI := Fintype.ofFinite X
  have hb : Bijective (fun f : {f : Fin r → X // Injective f} =>
      (⟨Quotient.mk _ f.1, f.1, f.2, rfl⟩ : InjOrbit G X r)) := by
    constructor
    · intro f f' h
      obtain ⟨g, hg⟩ := exists_smul_of_mk_eq (congrArg Subtype.val h)
      apply Subtype.ext
      rw [← hg]
      funext i
      exact htriv g _
    · rintro ⟨o, f, hf, rfl⟩
      exact ⟨⟨f, hf⟩, rfl⟩
  have hc : Nat.card {f : Fin r → X // Injective f} = Nat.card (InjOrbit G X r) :=
    Nat.card_eq_of_bijective _ hb
  rw [tInj, ← hc,
    Nat.card_congr (Equiv.subtypeInjectiveEquivEmbedding (Fin r) X),
    Nat.card_eq_fintype_card, Fintype.card_embedding_eq, Fintype.card_fin,
    Nat.card_eq_fintype_card]

/-- Falling factorials multiply along a cut: `n^{\underline{r+s}} = n^{\underline{r}} ·
(n-r)^{\underline{s}}`. -/
theorem descFactorial_add_eq_mul (n r s : ℕ) :
    n.descFactorial (r + s) = n.descFactorial r * (n - r).descFactorial s := by
  induction s with
  | zero => simp
  | succ s ih =>
    rw [← add_assoc, Nat.descFactorial_succ, ih, Nat.descFactorial_succ]
    have : n - (r + s) = n - r - s := by omega
    rw [this]
    ring

/-- **Sharpness of the hierarchy.**  For a trivial action the bound
`t_{r+s} ≥ t_r · (t_1 − r)^{\underline{s}}` is an equality, for all `r, s`. -/
theorem tInj_hierarchy_eq_of_trivial [Finite X] (htriv : ∀ (g : G) (x : X), g • x = x)
    (r s : ℕ) :
    tInj G X (r + s) = tInj G X r * (tInj G X 1 - r).descFactorial s := by
  rw [tInj_of_trivial G X htriv, tInj_of_trivial G X htriv, tInj_of_trivial G X htriv,
    Nat.descFactorial_one, descFactorial_add_eq_mul]

end Trivial

/-- **The coarse form of Conjecture M is false.**  The inequality `t_{r+s} ≥ t_r · (t_s − r)`
fails already for the trivial group acting on three points with `r = 1`, `s = 2`
(`t_1 = 3`, `t_2 = t_3 = 6`, and `6 < 3 · 5`). -/
theorem coarse_conjecture_false :
    ¬ ∀ (G : Type) [Group G] (X : Type) [MulAction G X] [Finite X] (r s : ℕ),
      r + s ≤ Nat.card X → tInj G X r * (tInj G X s - r) ≤ tInj G X (r + s) := by
  intro h
  have htriv : ∀ (g : (⊥ : Subgroup (Equiv.Perm (Fin 3)))) (x : Fin 3), g • x = x := by
    rintro ⟨g, hg⟩ x
    rw [Subgroup.mem_bot] at hg
    subst hg
    rfl
  have := h (⊥ : Subgroup (Equiv.Perm (Fin 3))) (Fin 3) 1 2 (by simp)
  rw [tInj_of_trivial _ _ htriv, tInj_of_trivial _ _ htriv, tInj_of_trivial _ _ htriv] at this
  simp [Nat.descFactorial] at this

end MultiplicativeHierarchy