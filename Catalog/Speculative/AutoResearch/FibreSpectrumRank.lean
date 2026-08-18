import Speculative.AutoResearch.MoonshineFibreSpectrumBridge

/-!
# The fibre spectrum of the orbit–pattern map is a function of the rank

This file continues the research thread

* `Catalog/Bridges/MoonshineBellTransitivityBridge.lean` (orbit–pattern map, Bell floor,
  `k`-transitivity criterion),
* `Catalog/Speculative/AutoResearch/MoonshineFibreSpectrumBridge.lean` (the fibre numbers
  `m_P = patternMultiplicity k G X P`, `Σ_P m_P = #(X^k/G)`, `m_P ≥ 1`, and the fibrewise
  transitivity criterion `∀ P, m_P = 1 ↔ KTransitive`).

The previous cycle treated the numbers `m_P` as `B_k` independent unknowns.  The main theorem
here shows that they are *not* independent: the whole spectrum is controlled by the `k + 1`
numbers

  `t_r = injOrbits r = ` (number of `G`-orbits of injective `r`-tuples),

by the **rank collapse**

  `m_P = t_{rank P}`   (`patternMultiplicity_eq_injOrbits_rank`),

where `rank P` is the number of blocks of the partition `P`.  This holds with *no* hypothesis
relating `k` and `|X|`, strictly generalising the previous cycle's results, which all assumed
`k ≤ |X|`.

Consequences proved here:

* `card_orbits_eq_sum_stirling` : `#(X^k/G) = Σ_{r ≤ k} S(k,r) · t_r`, where `S(k,r)` is the
  number of patterns of rank `r` (a Stirling number of the second kind, `stirling`).
* `bell_eq_sum_stirling` : `B_k = Σ_{r ≤ k} S(k,r)`, the classical row-sum identity, here a
  by-product of the same fibration.
* `injOrbits_le_succ`, `injOrbits_monotone` : the spectrum `t_0 ≤ t_1 ≤ ⋯ ≤ t_{|X|}` is
  monotone; the engine is the surjectivity of "forget the last coordinate" on injective tuples.
* `injOrbits_eq_one_iff` : `t_r = 1 ↔ r`-transitivity.
* `kTransitive_iff_top_fibre` : **a single fibre decides everything** — the action is
  `k`-transitive iff the *one* fibre over the discrete pattern is a singleton.  Together with
  monotonicity this re-proves, and sharpens, `patternMultiplicity_eq_one_iff`.

There are no `sorry`s, no `native_decide`, and no new axioms.
-/

open Finset MulAction Function

namespace FibreSpectrum

open MoonshineBell MoonshineFibre

/-! ## Part 1: a hypothesis-free recognition lemma for kernel patterns -/

section Kernel

variable {X : Type*} {k : ℕ}

/-- **Recognition lemma.**  If a tuple's equality relation is *exactly* the fibre relation of a
pattern `p`, then its kernel pattern is `p`.  Unlike `kerPat_comp_of_pattern` this needs no
injective tuple `Fin k → X`, hence no hypothesis `k ≤ |X|`; it is the technical key that removes
the cardinality hypotheses from the whole file. -/
theorem kerPat_eq_of_rel {p : Fin k → Fin k} (hp : IsPattern p) {w : Fin k → X}
    (h : ∀ i j, w i = w j ↔ p i = p j) : kerPat w = p := by
  classical
  funext i
  have h1 : kerPat w i ≤ p i := by
    refine Finset.min'_le _ _ ?_
    simp only [Finset.mem_filter, Finset.mem_univ, true_and]
    exact (h (p i) i).2 (hp.2 i)
  have h2 : p i ≤ kerPat w i := by
    have hpe : p (kerPat w i) = p i := (h _ i).1 (kerPat_apply_eq w i)
    calc p i = p (kerPat w i) := hpe.symm
      _ ≤ kerPat w i := hp.1 _
  exact le_antisymm h1 h2

/-- Injectivity is exactly the statement that the kernel pattern is the identity. -/
theorem injective_iff_kerPat_eq_id {f : Fin k → X} : Injective f ↔ kerPat f = id := by
  refine ⟨kerPat_of_injective, fun h i j hij => ?_⟩
  have := (kerPat_eq_iff f i j).2 hij
  rw [h] at this
  exact this

end Kernel

/-! ## Part 2: rank, block leaders, and the shrink/grow correspondence -/

section Rank

variable {k : ℕ}

/-- The **block leaders** of a pattern: the set of indices fixed by `P`, equivalently the image
of `P`.  Each block of the partition contributes its least element. -/
def leaders (P : Pattern k) : Finset (Fin k) := Finset.univ.image P.1

/-- The **rank** of a pattern: the number of blocks of the corresponding set partition. -/
def rank (P : Pattern k) : ℕ := (leaders P).card

theorem card_leaders (P : Pattern k) : (leaders P).card = rank P := rfl

theorem leader_mem (P : Pattern k) (i : Fin k) : P.1 i ∈ leaders P :=
  Finset.mem_image_of_mem _ (Finset.mem_univ i)

theorem leader_fixed {P : Pattern k} {i : Fin k} (hi : i ∈ leaders P) : P.1 i = i := by
  obtain ⟨j, -, hj⟩ := Finset.mem_image.1 hi
  rw [← hj]
  exact P.2.2 j

theorem rank_le (P : Pattern k) : rank P ≤ k := by
  have := Finset.card_image_le (s := (Finset.univ : Finset (Fin k))) (f := P.1)
  simpa [rank, leaders] using this

/-- The monotone enumeration of the block leaders of `P` by `Fin (rank P)`. -/
def leaderEquiv (P : Pattern k) : Fin (rank P) ≃o {x // x ∈ leaders P} :=
  (leaders P).orderIsoOfFin (card_leaders P)

theorem leaderEquiv_fixed (P : Pattern k) (j : Fin (rank P)) :
    P.1 ((leaderEquiv P j : Fin k)) = (leaderEquiv P j : Fin k) :=
  leader_fixed (leaderEquiv P j).2

variable {X : Type*}

/-- **Shrink**: restrict a `k`-tuple to the block leaders of `P`, obtaining a `rank P`-tuple. -/
def shrink (P : Pattern k) (f : Fin k → X) : Fin (rank P) → X :=
  fun j => f ((leaderEquiv P j : Fin k))

/-- **Grow**: spread a `rank P`-tuple over all of `Fin k` along the blocks of `P`. -/
def grow (P : Pattern k) (h : Fin (rank P) → X) : Fin k → X :=
  fun i => h ((leaderEquiv P).symm ⟨P.1 i, leader_mem P i⟩)

theorem shrink_injective {P : Pattern k} {f : Fin k → X} (hf : kerPat f = P.1) :
    Injective (shrink P f) := by
  intro a b hab
  have hfe : f ((leaderEquiv P a : Fin k)) = f ((leaderEquiv P b : Fin k)) := hab
  have h1 := (kerPat_eq_iff f ((leaderEquiv P a : Fin k)) ((leaderEquiv P b : Fin k))).2 hfe
  rw [hf, leaderEquiv_fixed, leaderEquiv_fixed] at h1
  exact (leaderEquiv P).injective (Subtype.ext h1)

theorem kerPat_grow {P : Pattern k} {h : Fin (rank P) → X} (hh : Injective h) :
    kerPat (grow P h) = P.1 := by
  refine kerPat_eq_of_rel P.2 fun i j => ?_
  constructor
  · intro hij
    have := hh hij
    have h2 : ((leaderEquiv P) ((leaderEquiv P).symm ⟨P.1 i, leader_mem P i⟩) : Fin k)
        = ((leaderEquiv P) ((leaderEquiv P).symm ⟨P.1 j, leader_mem P j⟩) : Fin k) := by
      rw [this]
    simpa using h2
  · intro hij
    show h _ = h _
    congr 2
    exact Subtype.ext hij

theorem grow_shrink {P : Pattern k} {f : Fin k → X} (hf : kerPat f = P.1) :
    grow P (shrink P f) = f := by
  funext i
  show f ((leaderEquiv P ((leaderEquiv P).symm ⟨P.1 i, leader_mem P i⟩) : Fin k)) = f i
  rw [OrderIso.apply_symm_apply]
  show f (P.1 i) = f i
  rw [← hf]
  exact kerPat_apply_eq f i

theorem shrink_grow (P : Pattern k) (h : Fin (rank P) → X) : shrink P (grow P h) = h := by
  funext j
  show h ((leaderEquiv P).symm ⟨P.1 ((leaderEquiv P j : Fin k)), leader_mem P _⟩) = h j
  congr 1
  rw [show (⟨P.1 ((leaderEquiv P j : Fin k)), leader_mem P _⟩ : {x // x ∈ leaders P})
      = leaderEquiv P j from Subtype.ext (leaderEquiv_fixed P j)]
  exact (leaderEquiv P).symm_apply_apply j

variable {G : Type*} [Group G] [MulAction G X]

theorem shrink_smul (P : Pattern k) (g : G) (f : Fin k → X) :
    shrink P (g • f) = g • shrink P f := rfl

theorem grow_smul (P : Pattern k) (g : G) (h : Fin (rank P) → X) :
    grow P (g • h) = g • grow P h := rfl

end Rank

/-! ## Part 3: the induced maps on orbit quotients and the fibre bijection -/

section Fibre

variable {k : ℕ} {G : Type*} [Group G] {X : Type*} [MulAction G X]

/-- The discrete pattern (all blocks singletons) of rank `r`. -/
def idPattern (r : ℕ) : Pattern r := ⟨id, fun _ => le_refl _, fun _ => rfl⟩

theorem rank_idPattern (r : ℕ) : rank (idPattern r) = r := by
  classical
  have : leaders (idPattern r) = (Finset.univ : Finset (Fin r)) := by
    ext i
    simp [leaders, idPattern]
  simp [rank, this]

/-- `shrink` descends to orbit quotients: it is `G`-equivariant. -/
def shrinkOrbit (P : Pattern k) :
    orbitRel.Quotient G (Fin k → X) → orbitRel.Quotient G (Fin (rank P) → X) :=
  Quotient.map (shrink P) <| by
    intro a b hab
    obtain ⟨g, hg⟩ := (orbitRel_apply).1 hab
    exact (orbitRel_apply).2 ⟨g, by rw [← hg, shrink_smul]⟩

/-- `grow` descends to orbit quotients: it is `G`-equivariant. -/
def growOrbit (P : Pattern k) :
    orbitRel.Quotient G (Fin (rank P) → X) → orbitRel.Quotient G (Fin k → X) :=
  Quotient.map (grow P) <| by
    intro a b hab
    obtain ⟨g, hg⟩ := (orbitRel_apply).1 hab
    exact (orbitRel_apply).2 ⟨g, by rw [← hg, grow_smul]⟩

theorem orbitPattern_shrinkOrbit {P : Pattern k}
    {o : orbitRel.Quotient G (Fin k → X)} (ho : orbitPattern o = P) :
    orbitPattern (shrinkOrbit (G := G) (X := X) P o) = idPattern (rank P) := by
  induction o using Quotient.inductionOn with
  | h f =>
    have hf : kerPat f = P.1 := congrArg Subtype.val ho
    refine Subtype.ext ?_
    show kerPat (shrink P f) = id
    exact kerPat_of_injective (shrink_injective hf)

theorem orbitPattern_growOrbit (P : Pattern k)
    {o : orbitRel.Quotient G (Fin (rank P) → X)} (ho : orbitPattern o = idPattern (rank P)) :
    orbitPattern (growOrbit (G := G) (X := X) P o) = P := by
  induction o using Quotient.inductionOn with
  | h h =>
    have hh : kerPat h = id := congrArg Subtype.val ho
    exact Subtype.ext (kerPat_grow (injective_iff_kerPat_eq_id.2 hh))

theorem growOrbit_shrinkOrbit {P : Pattern k}
    {o : orbitRel.Quotient G (Fin k → X)} (ho : orbitPattern o = P) :
    growOrbit (G := G) (X := X) P (shrinkOrbit (G := G) (X := X) P o) = o := by
  induction o using Quotient.inductionOn with
  | h f =>
    have hf : kerPat f = P.1 := congrArg Subtype.val ho
    show Quotient.mk _ (grow P (shrink P f)) = Quotient.mk _ f
    rw [grow_shrink hf]

theorem shrinkOrbit_growOrbit (P : Pattern k)
    (o : orbitRel.Quotient G (Fin (rank P) → X)) :
    shrinkOrbit (G := G) (X := X) P (growOrbit (G := G) (X := X) P o) = o := by
  induction o using Quotient.inductionOn with
  | h h =>
    show Quotient.mk _ (shrink P (grow P h)) = Quotient.mk _ h
    rw [shrink_grow]

/-- **The fibre bijection.**  The fibre of the orbit–pattern map over a pattern `P` is in natural
bijection with the fibre over the *discrete* pattern of rank `rank P`, i.e. with the set of
orbits of injective `rank P`-tuples. -/
def fibreEquiv (P : Pattern k) :
    {o : orbitRel.Quotient G (Fin k → X) // orbitPattern o = P} ≃
      {o : orbitRel.Quotient G (Fin (rank P) → X) // orbitPattern o = idPattern (rank P)} where
  toFun o := ⟨shrinkOrbit P o.1, orbitPattern_shrinkOrbit o.2⟩
  invFun o := ⟨growOrbit P o.1, orbitPattern_growOrbit P o.2⟩
  left_inv o := Subtype.ext (growOrbit_shrinkOrbit o.2)
  right_inv o := Subtype.ext (shrinkOrbit_growOrbit P o.1)

end Fibre

/-! ## Part 4: the rank collapse of the fibre spectrum -/

section Spectrum

variable (k : ℕ) (G : Type*) [Group G] (X : Type*) [MulAction G X]

/-- `t_r`: the number of `G`-orbits of *injective* `r`-tuples, i.e. the multiplicity of the
discrete pattern at level `r`.  These are the fundamental invariants of the spectrum. -/
noncomputable def injOrbits (r : ℕ) : ℕ := patternMultiplicity r G X (idPattern r)

variable {k}

/-- **Rank collapse.**  The multiplicity of a pattern depends only on its rank (number of
blocks).  No relation between `k` and `|X|` is assumed. -/
theorem patternMultiplicity_eq_injOrbits_rank (P : Pattern k) :
    patternMultiplicity k G X P = injOrbits G X (rank P) := by
  have h := Nat.card_congr (fibreEquiv (G := G) (X := X) P)
  simpa [patternMultiplicity, injOrbits] using h

end Spectrum

/-! ## Part 5: Stirling numbers and the spectral expansion of the orbit count -/

section Stirling

/-- The **Stirling number of the second kind** `S(k, r)`, realized as the number of patterns of
`Fin k` with exactly `r` blocks. -/
def stirling (k r : ℕ) : ℕ :=
  (Finset.univ.filter fun P : Pattern k => rank P = r).card

/-- Row sums of the Stirling triangle are the Bell numbers. -/
theorem bell_eq_sum_stirling (k : ℕ) : bell k = ∑ r ∈ Finset.range (k + 1), stirling k r := by
  classical
  have hmaps : ∀ P ∈ (Finset.univ : Finset (Pattern k)), rank P ∈ Finset.range (k + 1) :=
    fun P _ => Finset.mem_range.2 (Nat.lt_succ_of_le (rank_le P))
  have := Finset.sum_fiberwise_of_maps_to (g := fun P : Pattern k => rank P) hmaps
    (fun _ : Pattern k => (1 : ℕ))
  simp only [Finset.sum_const, smul_eq_mul, mul_one, Finset.card_univ] at this
  rw [bell, ← this]
  rfl

-- Sanity checks against the classical Stirling triangle (OEIS A008277).
example : stirling 3 0 = 0 := by decide
example : stirling 3 1 = 1 := by decide
example : stirling 3 2 = 3 := by decide
example : stirling 3 3 = 1 := by decide
example : stirling 4 2 = 7 := by decide

variable (k : ℕ) (G : Type*) [Group G] (X : Type*) [MulAction G X] [Finite X]

/-- **Spectral expansion of the orbit count.**  The number of orbits on `k`-tuples is the
Stirling transform of the injective-orbit spectrum `t_0, t_1, …`.  No hypothesis relating `k` and
`|X|` is needed. -/
theorem card_orbits_eq_sum_stirling :
    Nat.card (orbitRel.Quotient G (Fin k → X))
      = ∑ r ∈ Finset.range (k + 1), stirling k r * injOrbits G X r := by
  classical
  have hmaps : ∀ P ∈ (Finset.univ : Finset (Pattern k)), rank P ∈ Finset.range (k + 1) :=
    fun P _ => Finset.mem_range.2 (Nat.lt_succ_of_le (rank_le P))
  have hfib := Finset.sum_fiberwise_of_maps_to (g := fun P : Pattern k => rank P) hmaps
    (fun P : Pattern k => injOrbits G X (rank P))
  rw [← sum_patternMultiplicity k G X]
  have hcongr : ∑ P : Pattern k, patternMultiplicity k G X P
      = ∑ P : Pattern k, injOrbits G X (rank P) :=
    Finset.sum_congr rfl fun P _ => patternMultiplicity_eq_injOrbits_rank G X P
  rw [hcongr, ← hfib]
  refine Finset.sum_congr rfl fun r _ => ?_
  rw [Finset.sum_congr rfl (fun P hP => by rw [(Finset.mem_filter.1 hP).2]),
    Finset.sum_const, smul_eq_mul, stirling]

end Stirling

/-! ## Part 6: monotonicity of the spectrum and the top-fibre criterion -/

section Monotone

variable {G : Type*} [Group G] {X : Type*} [MulAction G X]

/-- Forgetting the last coordinate, as a map of orbit quotients. -/
def dropOrbit (r : ℕ) :
    orbitRel.Quotient G (Fin (r + 1) → X) → orbitRel.Quotient G (Fin r → X) :=
  Quotient.map (fun f => f ∘ Fin.castSucc) <| by
    intro a b hab
    obtain ⟨g, hg⟩ := (orbitRel_apply).1 hab
    exact (orbitRel_apply).2 ⟨g, by rw [← hg]; rfl⟩

variable (G X)

/-- On the discrete fibres, forgetting the last coordinate is **surjective**: every orbit of
injective `r`-tuples is the restriction of an orbit of injective `(r+1)`-tuples, provided there
are enough points. -/
theorem dropOrbit_fibre_surjective [Finite X] {r : ℕ} (hr : r + 1 ≤ Nat.card X) :
    Surjective (fun o : {o : orbitRel.Quotient G (Fin (r + 1) → X)
        // orbitPattern o = idPattern (r + 1)} =>
      (⟨dropOrbit r o.1, by
        obtain ⟨o, ho⟩ := o
        induction o using Quotient.inductionOn with
        | h f =>
          have hf : Injective f := injective_iff_kerPat_eq_id.2 (congrArg Subtype.val ho)
          exact Subtype.ext (kerPat_of_injective (hf.comp (Fin.castSucc_injective r)))⟩ :
        {o : orbitRel.Quotient G (Fin r → X) // orbitPattern o = idPattern r})) := by
  rintro ⟨o, ho⟩
  induction o using Quotient.inductionOn with
  | h h =>
    have hh : Injective h := injective_iff_kerPat_eq_id.2 (congrArg Subtype.val ho)
    obtain ⟨F, hF, hFe⟩ := exists_injective_succ hr h hh
    have hFpat : orbitPattern (Quotient.mk (orbitRel G (Fin (r + 1) → X)) F)
        = idPattern (r + 1) := Subtype.ext (kerPat_of_injective hF)
    refine ⟨⟨Quotient.mk (orbitRel G (Fin (r + 1) → X)) F, hFpat⟩, ?_⟩
    refine Subtype.ext ?_
    show Quotient.mk (orbitRel G (Fin r → X)) (F ∘ Fin.castSucc)
      = Quotient.mk (orbitRel G (Fin r → X)) h
    congr 1
    exact funext hFe

/-- **The spectrum is monotone.**  There are at least as many orbits of injective `(r+1)`-tuples
as of injective `r`-tuples. -/
theorem injOrbits_le_succ [Finite X] {r : ℕ} (hr : r + 1 ≤ Nat.card X) :
    injOrbits G X r ≤ injOrbits G X (r + 1) :=
  Nat.card_le_card_of_surjective _ (dropOrbit_fibre_surjective G X hr)

/-- The spectrum `t_0 ≤ t_1 ≤ ⋯ ≤ t_{|X|}` is monotone up to the size of `X`. -/
theorem injOrbits_monotone [Finite X] {r s : ℕ} (hrs : r ≤ s) (hs : s ≤ Nat.card X) :
    injOrbits G X r ≤ injOrbits G X s := by
  induction s with
  | zero => simp_all
  | succ n ih =>
    rcases Nat.lt_or_ge r (n + 1) with h | h
    · exact le_trans (ih (Nat.lt_succ_iff.1 h) (le_trans (Nat.le_succ n) hs))
        (injOrbits_le_succ G X hs)
    · have : r = n + 1 := le_antisymm hrs h
      subst this
      exact le_rfl

end Monotone

/-! ## Part 7: a single fibre decides `k`-transitivity -/

section TopFibre

variable (G : Type*) [Group G] (X : Type*) [MulAction G X] [Finite X]

/-- The `r`-th entry of the spectrum is `1` exactly for `r`-transitive actions: `t_r` literally
counts the orbits of injective `r`-tuples. -/
theorem injOrbits_eq_one_iff {r : ℕ} (hr : r ≤ Nat.card X) :
    injOrbits G X r = 1 ↔ KTransitive r G X := by
  constructor
  · intro h f f' hf hf'
    have hsub : Subsingleton {o : orbitRel.Quotient G (Fin r → X)
        // orbitPattern o = idPattern r} := (Nat.card_eq_one_iff_unique.1 h).1
    have hfe : orbitPattern (Quotient.mk (orbitRel G (Fin r → X)) f) = idPattern r :=
      Subtype.ext (kerPat_of_injective hf)
    have hfe' : orbitPattern (Quotient.mk (orbitRel G (Fin r → X)) f') = idPattern r :=
      Subtype.ext (kerPat_of_injective hf')
    have := congrArg Subtype.val (hsub.elim ⟨_, hfe⟩ ⟨_, hfe'⟩)
    obtain ⟨g, hg⟩ := (orbitRel_apply).1 (Quotient.exact this)
    exact ⟨g⁻¹, by rw [← hg, inv_smul_smul]⟩
  · intro htr
    refine Nat.card_eq_one_iff_unique.2 ⟨⟨?_⟩, ?_⟩
    · rintro ⟨a, ha⟩ ⟨b, hb⟩
      refine Subtype.ext ?_
      induction a using Quotient.inductionOn with
      | h f =>
        induction b using Quotient.inductionOn with
        | h f' =>
          have hf : Injective f := injective_iff_kerPat_eq_id.2 (congrArg Subtype.val ha)
          have hf' : Injective f' := injective_iff_kerPat_eq_id.2 (congrArg Subtype.val hb)
          obtain ⟨g, hg⟩ := htr f f' hf hf'
          exact Quotient.sound ((orbitRel_apply).2 ⟨g⁻¹, by rw [← hg]; exact inv_smul_smul g f⟩)
    · obtain ⟨u, hu⟩ := exists_injective_tuple (X := X) hr
      exact ⟨⟨Quotient.mk (orbitRel G (Fin r → X)) u, Subtype.ext (kerPat_of_injective hu)⟩⟩

/-- **Top-fibre criterion.**  The action is `k`-transitive iff the *single* fibre over the
discrete pattern is a singleton.  This sharpens `patternMultiplicity_eq_one_iff`, which tests all
`B_k` fibres. -/
theorem kTransitive_iff_top_fibre {k : ℕ} (hk : k ≤ Nat.card X) :
    KTransitive k G X ↔ patternMultiplicity k G X (idPattern k) = 1 :=
  (injOrbits_eq_one_iff G X hk).symm

/-- **One fibre controls the whole spectrum.**  If the discrete fibre is a singleton, then so is
every other fibre — by rank collapse plus monotonicity of the spectrum. -/
theorem all_fibres_eq_one_iff_top_fibre {k : ℕ} (hk : k ≤ Nat.card X) :
    (∀ P : Pattern k, patternMultiplicity k G X P = 1)
      ↔ patternMultiplicity k G X (idPattern k) = 1 := by
  refine ⟨fun h => h _, fun h P => ?_⟩
  have hrank : rank P ≤ Nat.card X := le_trans (rank_le P) hk
  have hlow : 1 ≤ injOrbits G X (rank P) :=
    one_le_patternMultiplicity (rank P) G X hrank (idPattern (rank P))
  have hhigh : injOrbits G X (rank P) ≤ injOrbits G X k :=
    injOrbits_monotone G X (rank_le P) hk
  rw [patternMultiplicity_eq_injOrbits_rank]
  have : injOrbits G X k = 1 := h
  omega

end TopFibre

/-! ## Part 8: the moment form -/

section Moments

variable (k : ℕ) (G : Type*) [Group G] [Fintype G] (X : Type*) [MulAction G X] [Finite X]

/-- **Stirling expansion of the trace moments.**  The `k`-th moment of the fixed-point family
expands in the Stirling basis with coefficients the injective-orbit spectrum. -/
theorem sum_fixedPoints_pow_eq_sum_stirling :
    ∑ g : G, Nat.card (fixedBy X g) ^ k
      = (∑ r ∈ Finset.range (k + 1), stirling k r * injOrbits G X r) * Nat.card G := by
  rw [← card_orbits_eq_sum_stirling k G X, sum_fixedPoints_pow_eq_orbits_mul_card G X k]

/-- **The Bell defect, resolved by rank.**  The excess of the `k`-th moment over the Bell value
`B_k·|G|` is `|G|·Σ_r S(k,r)·(t_r − 1)`: each rank contributes its own excess, weighted by the
number of patterns of that rank. -/
theorem bell_defect_stirling (hk : k ≤ Nat.card X) :
    ∑ g : G, Nat.card (fixedBy X g) ^ k
      = (bell k + ∑ r ∈ Finset.range (k + 1), stirling k r * (injOrbits G X r - 1))
        * Nat.card G := by
  rw [sum_fixedPoints_pow_eq_sum_stirling k G X, bell_eq_sum_stirling k, ← Finset.sum_add_distrib]
  congr 1
  refine Finset.sum_congr rfl fun r hr => ?_
  have hrk : r ≤ Nat.card X :=
    le_trans (Nat.lt_succ_iff.1 (Finset.mem_range.1 hr)) hk
  have h1 : 1 ≤ injOrbits G X r :=
    one_le_patternMultiplicity r G X hrk (idPattern r)
  obtain ⟨c, hc⟩ := Nat.exists_eq_add_of_le h1
  rw [hc, Nat.add_sub_cancel_left]
  ring

end Moments

end FibreSpectrum