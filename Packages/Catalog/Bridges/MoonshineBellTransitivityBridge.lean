import Mathlib

/-!
# Moonshine beyond the j-function III: Bell numbers, moments of trace series, and
# `k`-transitivity

This file closes **Conjecture B** of the previous cycle of this research thread
(`Catalog/Bridges/MoonshineMomentLaurentBridge.lean`, `FUTURE_DIRECTIONS.md`), which asked
whether the `k`-th moment of the fixed-point ("permutation character" / trace) series of a
finite group action attains the value `B_k · |G|` — with `B_k` the `k`-th Bell number —
*exactly* for the `k`-transitive actions.  Cycle 1 proved only the case `k = 2`
(`sum_fixedPoints_sq_eq_two_mul_card_iff`).  Here the full statement is proved for every `k`.

## The bridge

Three a priori unrelated quantities are identified:

* **Character theory / moonshine side.**  The `k`-th moment `∑_{g∈G} |X^g|^k` of the family of
  trace series `T_g(q)` attached to a graded finite `G`-set.
* **Enumerative combinatorics side.**  The Bell number `B_k`, realized here as the number of
  *restricted growth functions* `p : Fin k → Fin k` (`IsPattern`: `p i ≤ i` and `p ∘ p = p`),
  a standard encoding of the set partitions of a `k`-element set.
* **Permutation group side.**  `k`-transitivity of the action.

The main results are:

* `bell_le_card_orbits` : `B_k ≤ #((Fin k → X)/G)` whenever `k ≤ |X|` — the number of orbits on
  `k`-tuples is always at least the number of set partitions of `{1,…,k}`, because the kernel
  pattern of a tuple is a complete `G`-invariant of "which coordinates agree".
* `bell_mul_card_le_sum_fixedPoints_pow` : consequently every moment of the trace family obeys
  the universal lower bound `B_k·|G| ≤ ∑_{g∈G}|X^g|^k`; Burnside's lemma (`k = 1`) is the
  degenerate case `B_1 = 1`.
* `card_orbits_eq_bell_iff` and `sum_fixedPoints_pow_eq_bell_mul_card_iff` : the bound is
  attained **iff the action is `k`-transitive**.  So a single integer moment of the
  moonshine-type trace family decides a purely group-theoretic transitivity property.
* `sum_traceSeries_pow_eq_bell_of_kTransitive` : the graded ("q-series") form — if every grade
  of a graded `G`-set is `k`-transitive, the coefficientwise `k`-th moment of the trace series
  is the constant series `B_k·|G|`.
* `perm_kTransitive` and `sum_fixedPoints_pow_perm` : the bound is attained — the full symmetric
  group of a finite set is `k`-transitive for every `k`, so `∑_{σ∈S_n}|fix σ|^k = B_k·n!`.
  In particular the criterion is not vacuous.
* `kTransitive_of_succ` and `sum_fixedPoints_pow_eq_bell_of_succ` : the hierarchy is decreasing,
  so extremality of one moment propagates downwards to all lower moments.

## Proof architecture

1. `kerPat f` is the canonical *kernel pattern* of a tuple `f : Fin k → X`: the `i`-th value is
   the least index `j` with `f j = f i`.  It is a restricted growth function
   (`isPattern_kerPat`), it is a complete invariant of the equality pattern of `f`
   (`kerPat_eq_iff`), and it is `G`-invariant (`kerPat_smul`).
2. `exists_injective_extension` : an injective partial tuple defined on a finset of indices
   extends to a globally injective tuple as soon as `k ≤ |X|`.  This is what makes the kernel
   pattern map *surjective* onto all patterns, and it is also the engine of step 3.
3. `exists_smul_eq_of_kerPat_eq` : for a `k`-transitive action, two tuples with the same kernel
   pattern lie in the same orbit — obtained by extending both tuples, restricted to their block
   leaders, to injective tuples and applying `k`-transitivity there.
4. Hence `orbitPattern : (Fin k → X)/G → Pattern k` is always surjective, and it is injective
   iff the action is `k`-transitive; comparing cardinalities gives the main theorems, which are
   then transported to the moment side through the moment identity
   `∑_g |X^g|^k = #((Fin k → X)/G)·|G|` (re-proved here so that the file is self-contained).

`Pattern k` is a decidable finite type, so the Bell numbers `1, 1, 2, 5, 15, 52`
(OEIS A000110) are verified by `decide` in `bell_zero` … `bell_five`; these are auxiliary
sanity checks, not the mathematical content.
-/

namespace MoonshineBell

open MulAction Function

/-! ## Part 1: Burnside's lemma and the moment hierarchy (self-contained restatement) -/

section Burnside

variable (G : Type*) [Group G] [Fintype G] (X : Type*) [MulAction G X] [Finite X]

/-- Burnside's orbit-counting lemma in `Nat.card` form. -/
theorem sum_card_fixedBy_eq_orbits_mul_card :
    ∑ g : G, Nat.card (fixedBy X g) = Nat.card (orbitRel.Quotient G X) * Nat.card G := by
  classical
  letI := Fintype.ofFinite X
  letI : ∀ g : G, Fintype (fixedBy X g) := fun g => Fintype.ofFinite _
  letI : Fintype (orbitRel.Quotient G X) := Fintype.ofFinite _
  simpa [Nat.card_eq_fintype_card] using
    MulAction.sum_card_fixedBy_eq_card_orbits_mul_card_group G X

end Burnside

section Moments

variable {G : Type*} [Group G] {X : Type*} [MulAction G X]

/-- Fixed points on the `k`-fold power are `k`-tuples of fixed points. -/
def fixedByPiEquiv (k : ℕ) (g : G) :
    fixedBy (Fin k → X) g ≃ (Fin k → fixedBy X g) where
  toFun x i := ⟨x.1 i, congrFun x.2 i⟩
  invFun y := ⟨fun i => (y i).1, funext fun i => (y i).2⟩
  left_inv _ := by ext i; rfl
  right_inv _ := by ext i; rfl

theorem card_fixedBy_pi (k : ℕ) (g : G) [Finite X] :
    Nat.card (fixedBy (Fin k → X) g) = Nat.card (fixedBy X g) ^ k := by
  simp [Nat.card_congr (fixedByPiEquiv k g), Nat.card_fun]

variable (G X)

/-- **Moment identity.** The `k`-th moment of the fixed-point counting function is `|G|` times
the number of orbits on `k`-tuples. -/
theorem sum_fixedPoints_pow_eq_orbits_mul_card [Fintype G] [Finite X] (k : ℕ) :
    ∑ g : G, Nat.card (fixedBy X g) ^ k =
      Nat.card (orbitRel.Quotient G (Fin k → X)) * Nat.card G := by
  have h := sum_card_fixedBy_eq_orbits_mul_card G (Fin k → X)
  simp only [card_fixedBy_pi] at h
  exact h

end Moments

/-! ## Part 2: patterns (restricted growth functions) and Bell numbers -/

/-- A *pattern*, i.e. a restricted growth function: an idempotent, index-non-increasing self-map
of `Fin k`.  Patterns are in canonical bijection with the set partitions of `Fin k`: `p i` is the
least element of the block of `i`. -/
def IsPattern {k : ℕ} (p : Fin k → Fin k) : Prop := (∀ i, p i ≤ i) ∧ ∀ i, p (p i) = p i

instance {k : ℕ} (p : Fin k → Fin k) : Decidable (IsPattern p) := by
  unfold IsPattern; infer_instance

/-- The type of patterns on `Fin k`; a finite decidable type modelling set partitions. -/
def Pattern (k : ℕ) : Type := {p : Fin k → Fin k // IsPattern p}

instance (k : ℕ) : Fintype (Pattern k) := by unfold Pattern; infer_instance
instance (k : ℕ) : DecidableEq (Pattern k) := by unfold Pattern; infer_instance

/-- The `k`-th Bell number, defined as the number of patterns (set partitions) on `Fin k`. -/
def bell (k : ℕ) : ℕ := Fintype.card (Pattern k)

theorem nat_card_pattern (k : ℕ) : Nat.card (Pattern k) = bell k :=
  Nat.card_eq_fintype_card

theorem bell_zero : bell 0 = 1 := by decide
theorem bell_one : bell 1 = 1 := by decide
theorem bell_two : bell 2 = 2 := by decide
theorem bell_three : bell 3 = 5 := by decide
theorem bell_four : bell 4 = 15 := by decide

set_option maxRecDepth 8000 in
theorem bell_five : bell 5 = 52 := by decide

/-! ## Part 3: the kernel pattern of a tuple -/

section Kernel

variable {X : Type*} {k : ℕ} {f f' : Fin k → X}

/-- The kernel pattern of a tuple `f : Fin k → X`: the least index taking the same value. -/
noncomputable def kerPat {k : ℕ} (f : Fin k → X) (i : Fin k) : Fin k :=
  haveI := Classical.decEq X
  (Finset.univ.filter (fun j => f j = f i)).min' ⟨i, by simp⟩

theorem kerPat_apply_eq (f : Fin k → X) (i : Fin k) : f (kerPat f i) = f i := by
  classical
  have h := Finset.min'_mem (Finset.univ.filter (fun j => f j = f i)) ⟨i, by simp⟩
  simpa [kerPat, Finset.mem_filter] using h

theorem kerPat_le (f : Fin k → X) (i : Fin k) : kerPat f i ≤ i := by
  classical
  exact Finset.min'_le _ _ (by simp)

/-- The kernel pattern only depends on the equality pattern of the tuple. -/
theorem kerPat_congr (h : ∀ i j, f i = f j ↔ f' i = f' j) : kerPat f = kerPat f' := by
  classical
  funext i
  have : (Finset.univ.filter (fun j => f j = f i))
      = (Finset.univ.filter (fun j => f' j = f' i)) := by
    ext j; simp [Finset.mem_filter, h j i]
  simp only [kerPat]
  congr 1

/-- Two coordinates get the same kernel representative exactly when the tuple agrees on them:
the kernel pattern is a *complete* invariant of the equality pattern. -/
theorem kerPat_eq_iff (f : Fin k → X) (i j : Fin k) :
    kerPat f i = kerPat f j ↔ f i = f j := by
  classical
  constructor
  · intro h
    have h1 := kerPat_apply_eq f i
    have h2 := kerPat_apply_eq f j
    rw [← h1, ← h2, h]
  · intro h
    have : (Finset.univ.filter (fun l => f l = f i))
        = (Finset.univ.filter (fun l => f l = f j)) := by
      ext l; simp [Finset.mem_filter, h]
    simp only [kerPat]
    congr 1

theorem kerPat_idem (f : Fin k → X) (i : Fin k) : kerPat f (kerPat f i) = kerPat f i :=
  (kerPat_eq_iff f _ i).2 (kerPat_apply_eq f i)

theorem isPattern_kerPat (f : Fin k → X) : IsPattern (kerPat f) :=
  ⟨kerPat_le f, kerPat_idem f⟩

/-- Injective tuples are exactly those whose kernel pattern is the identity (discrete
partition). -/
theorem kerPat_of_injective (hf : Injective f) : kerPat f = id :=
  funext fun i => hf (kerPat_apply_eq f i)

/-- Every pattern is realized as a kernel pattern, by composing it with an injective tuple. -/
theorem kerPat_comp_of_pattern {p : Fin k → Fin k} (hp : IsPattern p) {u : Fin k → X}
    (hu : Injective u) : kerPat (u ∘ p) = p := by
  classical
  funext i
  have hval : ∀ j l : Fin k, (u ∘ p) j = (u ∘ p) l ↔ p j = p l := fun j l =>
    ⟨fun h => hu h, fun h => by simp [Function.comp, h]⟩
  have h1 : kerPat (u ∘ p) i ≤ p i := Finset.min'_le _ _ (by simp [hp.2 i])
  have h2 : p i ≤ kerPat (u ∘ p) i := by
    have hpe : p (kerPat (u ∘ p) i) = p i := (hval _ i).1 (kerPat_apply_eq (u ∘ p) i)
    calc p i = p (kerPat (u ∘ p) i) := hpe.symm
      _ ≤ kerPat (u ∘ p) i := hp.1 _
  exact le_antisymm h1 h2

variable {G : Type*} [Group G] [MulAction G X]

/-- The kernel pattern is a `G`-invariant of a tuple. -/
theorem kerPat_smul (g : G) (f : Fin k → X) : kerPat (g • f) = kerPat f :=
  kerPat_congr fun i j => by
    show g • f i = g • f j ↔ f i = f j
    exact smul_left_cancel_iff g

end Kernel

/-! ## Part 4: extending injective partial tuples -/

/-- An injective partial assignment defined on a finset of indices extends to a globally
injective tuple, provided the target set has at least `k` elements. -/
theorem exists_injective_extension {X : Type*} [Finite X] {k : ℕ} (hk : k ≤ Nat.card X)
    (f : Fin k → X) (s : Finset (Fin k)) (hs : Set.InjOn f ↑s) :
    ∃ u : Fin k → X, Injective u ∧ ∀ i ∈ s, u i = f i := by
  classical
  letI := Fintype.ofFinite X
  set t : Finset X := s.image f with ht
  have htcard : t.card = s.card := Finset.card_image_of_injOn hs
  have hcompl : sᶜ.card = k - s.card := by
    rw [Finset.card_compl]; simp
  have hsk : s.card ≤ k := by simpa using Finset.card_le_univ s
  have hX : k ≤ Fintype.card X := by rwa [Nat.card_eq_fintype_card] at hk
  have h2 : (tᶜ : Finset X).card = Fintype.card X - s.card := by
    rw [Finset.card_compl, htcard]
  have hle : sᶜ.card ≤ (tᶜ : Finset X).card := by omega
  obtain ⟨t', ht'sub, ht'card⟩ := Finset.exists_subset_card_eq hle
  let e := Finset.equivOfCardEq ht'card.symm
  refine ⟨fun i => if h : i ∈ s then f i else (e ⟨i, by simp [h]⟩ : X), ?_, ?_⟩
  · intro a b hab
    by_cases ha : a ∈ s <;> by_cases hb : b ∈ s <;> simp [ha, hb] at hab
    · exact hs (by simpa using ha) (by simpa using hb) hab
    · exfalso
      have h1 : f a ∈ t := Finset.mem_image_of_mem f ha
      have h2 : ((e ⟨b, by simp [hb]⟩ : X)) ∈ t' := (e ⟨b, by simp [hb]⟩).2
      have hmem := ht'sub h2
      rw [hab] at h1
      simp only [Finset.mem_compl] at hmem
      exact hmem h1
    · exfalso
      have h1 : f b ∈ t := Finset.mem_image_of_mem f hb
      have h2 : ((e ⟨a, by simp [ha]⟩ : X)) ∈ t' := (e ⟨a, by simp [ha]⟩).2
      have hmem := ht'sub h2
      rw [← hab] at h1
      simp only [Finset.mem_compl] at hmem
      exact hmem h1
    · exact hab
  · intro i hi; simp [hi]

/-- There is an injective `k`-tuple whenever `k ≤ |X|`. -/
theorem exists_injective_tuple {X : Type*} [Finite X] {k : ℕ} (hk : k ≤ Nat.card X) :
    ∃ u : Fin k → X, Injective u := by
  classical
  letI := Fintype.ofFinite X
  have : Fintype.card (Fin k) ≤ Fintype.card X := by
    simpa [Nat.card_eq_fintype_card] using hk
  obtain ⟨u⟩ := Function.Embedding.nonempty_of_card_le this
  exact ⟨u, u.injective⟩

/-! ## Part 5: `k`-transitivity and orbits of tuples -/

section Transitivity

variable (k : ℕ) (G : Type*) [Group G] (X : Type*) [MulAction G X]

/-- `k`-transitivity: the group acts transitively on injective `k`-tuples. -/
def KTransitive : Prop :=
  ∀ f f' : Fin k → X, Injective f → Injective f' → ∃ g : G, g • f = f'

variable {k G X}

/-- **Key step.** In a `k`-transitive action, two tuples with the same kernel pattern lie in the
same orbit.  Both tuples are extended, off their block leaders, to injective tuples; transitivity
on injective tuples then moves one to the other, and the extension is irrelevant because each
tuple is determined by its values at the leaders. -/
theorem exists_smul_eq_of_kerPat_eq [Finite X] (hk : k ≤ Nat.card X)
    (htr : KTransitive k G X) (f f' : Fin k → X) (h : kerPat f = kerPat f') :
    ∃ g : G, g • f = f' := by
  classical
  obtain ⟨L, hmemL⟩ : ∃ L : Finset (Fin k), ∀ i, i ∈ L ↔ kerPat f i = i :=
    ⟨Finset.univ.filter (fun i => kerPat f i = i), by intro i; simp⟩
  have hpL : ∀ i, kerPat f i ∈ L := fun i => (hmemL _).2 (kerPat_idem f i)
  have hinj : Set.InjOn f ↑L := by
    intro a ha b hb hab
    have ha' : kerPat f a = a := (hmemL a).1 (by simpa using ha)
    have hb' : kerPat f b = b := (hmemL b).1 (by simpa using hb)
    have h1 : kerPat f a = kerPat f b := (kerPat_eq_iff f a b).2 hab
    rwa [ha', hb'] at h1
  have hinj' : Set.InjOn f' ↑L := by
    intro a ha b hb hab
    have ha' : kerPat f a = a := (hmemL a).1 (by simpa using ha)
    have hb' : kerPat f b = b := (hmemL b).1 (by simpa using hb)
    have h1 : kerPat f' a = kerPat f' b := (kerPat_eq_iff f' a b).2 hab
    rw [← h, ha', hb'] at h1
    exact h1
  obtain ⟨u, hu, hue⟩ := exists_injective_extension hk f L hinj
  obtain ⟨u', hu', hue'⟩ := exists_injective_extension hk f' L hinj'
  obtain ⟨g, hg⟩ := htr u u' hu hu'
  refine ⟨g, funext fun i => ?_⟩
  have hfu : u (kerPat f i) = f i := by
    rw [hue _ (hpL i)]; exact kerPat_apply_eq f i
  have hfu' : u' (kerPat f i) = f' i := by
    rw [hue' _ (hpL i), h]; exact kerPat_apply_eq f' i
  show g • f i = f' i
  rw [← hfu, ← hfu', ← hg]
  rfl

end Transitivity

/-! ## Part 6: the orbit–pattern correspondence -/

section OrbitPattern

variable {k : ℕ} {G : Type*} [Group G] {X : Type*} [MulAction G X]

/-- The kernel pattern descends to the orbit space of `k`-tuples. -/
noncomputable def orbitPattern : orbitRel.Quotient G (Fin k → X) → Pattern k :=
  Quotient.lift (fun f => (⟨kerPat f, isPattern_kerPat f⟩ : Pattern k)) <| by
    intro a b hab
    have hmem : a ∈ orbit G b := (orbitRel_apply).1 hab
    obtain ⟨g, hg⟩ := hmem
    have : kerPat a = kerPat b := by
      rw [← hg]; exact kerPat_smul g b
    exact Subtype.ext this

theorem orbitPattern_mk (f : Fin k → X) :
    orbitPattern (Quotient.mk (orbitRel G (Fin k → X)) f) = ⟨kerPat f, isPattern_kerPat f⟩ :=
  rfl

/-- Every pattern occurs: the orbit–pattern map is surjective when `k ≤ |X|`. -/
theorem orbitPattern_surjective [Finite X] (hk : k ≤ Nat.card X) :
    Surjective (orbitPattern (k := k) (G := G) (X := X)) := by
  obtain ⟨u, hu⟩ := exists_injective_tuple (X := X) hk
  intro p
  refine ⟨Quotient.mk (orbitRel G (Fin k → X)) (u ∘ p.1), ?_⟩
  rw [orbitPattern_mk]
  exact Subtype.ext (kerPat_comp_of_pattern p.2 hu)

/-- The orbit–pattern map is injective exactly for `k`-transitive actions. -/
theorem orbitPattern_injective_iff [Finite X] (hk : k ≤ Nat.card X) :
    Injective (orbitPattern (k := k) (G := G) (X := X)) ↔ KTransitive k G X := by
  constructor
  · intro hinj f f' hf hf'
    have hker : kerPat f = kerPat f' := by
      rw [kerPat_of_injective hf, kerPat_of_injective hf']
    have : (Quotient.mk (orbitRel G (Fin k → X)) f)
        = Quotient.mk (orbitRel G (Fin k → X)) f' := by
      apply hinj
      rw [orbitPattern_mk, orbitPattern_mk]
      exact Subtype.ext hker
    have hrel : (orbitRel G (Fin k → X)) f f' := Quotient.exact this
    obtain ⟨g, hg⟩ := (orbitRel_apply).1 hrel
    exact ⟨g⁻¹, by rw [← hg, inv_smul_smul]⟩
  · intro htr a b hab
    induction a using Quotient.inductionOn with
    | h f =>
      induction b using Quotient.inductionOn with
      | h f' =>
        have hker : kerPat f = kerPat f' := by
          have := congrArg Subtype.val hab
          simpa [orbitPattern_mk] using this
        obtain ⟨g, hg⟩ := exists_smul_eq_of_kerPat_eq hk htr f f' hker
        apply Quotient.sound
        exact (orbitRel_apply).2 ⟨g⁻¹, by rw [← hg]; exact inv_smul_smul g f⟩

variable (k G X)

/-- **Universal lower bound.** The number of orbits on `k`-tuples is at least the `k`-th Bell
number: the kernel pattern of a tuple is a `G`-invariant taking every pattern as a value. -/
theorem bell_le_card_orbits [Finite X] (hk : k ≤ Nat.card X) :
    bell k ≤ Nat.card (orbitRel.Quotient G (Fin k → X)) := by
  have := Nat.card_le_card_of_surjective _ (orbitPattern_surjective (k := k) (G := G) (X := X) hk)
  rwa [nat_card_pattern] at this

/-- **Bell-number criterion for `k`-transitivity.** The number of orbits on `k`-tuples equals the
`k`-th Bell number iff the action is `k`-transitive. -/
theorem card_orbits_eq_bell_iff [Finite X] (hk : k ≤ Nat.card X) :
    Nat.card (orbitRel.Quotient G (Fin k → X)) = bell k ↔ KTransitive k G X := by
  classical
  letI : Fintype (orbitRel.Quotient G (Fin k → X)) := Fintype.ofFinite _
  have hsurj := orbitPattern_surjective (k := k) (G := G) (X := X) hk
  rw [← orbitPattern_injective_iff (k := k) (G := G) (X := X) hk]
  constructor
  · intro hcard
    have hc : Fintype.card (orbitRel.Quotient G (Fin k → X)) = Fintype.card (Pattern k) := by
      rw [← Nat.card_eq_fintype_card]
      exact hcard
    exact ((Fintype.bijective_iff_surjective_and_card _).2 ⟨hsurj, hc⟩).1
  · intro hinj
    have hbij : Bijective (orbitPattern (k := k) (G := G) (X := X)) := ⟨hinj, hsurj⟩
    have := Fintype.card_of_bijective hbij
    rw [Nat.card_eq_fintype_card, this]
    rfl

end OrbitPattern

/-! ## Part 7: the moment form — Bell numbers as extremal values of trace moments -/

section MomentCriterion

variable (k : ℕ) (G : Type*) [Group G] [Fintype G] (X : Type*) [MulAction G X] [Finite X]

/-- Every moment of the fixed-point/trace family is bounded below by `B_k·|G|`. -/
theorem bell_mul_card_le_sum_fixedPoints_pow (hk : k ≤ Nat.card X) :
    bell k * Nat.card G ≤ ∑ g : G, Nat.card (fixedBy X g) ^ k := by
  rw [sum_fixedPoints_pow_eq_orbits_mul_card G X k]
  exact Nat.mul_le_mul_right _ (bell_le_card_orbits k G X hk)

/-- **Main theorem (Conjecture B of the previous cycle).**  The `k`-th moment of the
fixed-point (trace) series of a finite group action equals `B_k·|G|`, with `B_k` the `k`-th Bell
number, **if and only if** the action is `k`-transitive.  For `k = 1` this is Burnside's lemma
together with `B_1 = 1` (transitivity); for `k = 2` it is the classical rank-two criterion. -/
theorem sum_fixedPoints_pow_eq_bell_mul_card_iff (hk : k ≤ Nat.card X) :
    (∑ g : G, Nat.card (fixedBy X g) ^ k) = bell k * Nat.card G ↔ KTransitive k G X := by
  rw [sum_fixedPoints_pow_eq_orbits_mul_card G X k, ← card_orbits_eq_bell_iff k G X hk]
  constructor
  · intro h; exact Nat.eq_of_mul_eq_mul_right Nat.card_pos h
  · intro h; rw [h]

/-- Specialization to `k = 1`: Burnside's lemma detects transitivity. -/
theorem sum_fixedPoints_eq_card_iff (hk : 1 ≤ Nat.card X) :
    (∑ g : G, Nat.card (fixedBy X g)) = Nat.card G ↔ KTransitive 1 G X := by
  have h := sum_fixedPoints_pow_eq_bell_mul_card_iff 1 G X hk
  simpa [bell_one] using h

/-- Specialization to `k = 2`: the second moment equals `2|G|` iff the action is 2-transitive. -/
theorem sum_fixedPoints_sq_eq_two_mul_card_iff (hk : 2 ≤ Nat.card X) :
    (∑ g : G, Nat.card (fixedBy X g) ^ 2) = 2 * Nat.card G ↔ KTransitive 2 G X := by
  have h := sum_fixedPoints_pow_eq_bell_mul_card_iff 2 G X hk
  rwa [bell_two] at h

/-- Specialization to `k = 3`: the third moment equals `5|G|` iff the action is 3-transitive. -/
theorem sum_fixedPoints_cube_eq_five_mul_card_iff (hk : 3 ≤ Nat.card X) :
    (∑ g : G, Nat.card (fixedBy X g) ^ 3) = 5 * Nat.card G ↔ KTransitive 3 G X := by
  have h := sum_fixedPoints_pow_eq_bell_mul_card_iff 3 G X hk
  rwa [bell_three] at h

end MomentCriterion

/-! ## Part 9: the extremal example — full symmetric groups attain the Bell bound -/

section Symmetric

/-- The full symmetric group of a finite set is `k`-transitive for every `k`: an injective
`k`-tuple can be moved to any other by a permutation extending the induced bijection between
their ranges. -/
theorem perm_kTransitive {X : Type*} [Finite X] (k : ℕ) :
    KTransitive k (Equiv.Perm X) X := by
  classical
  letI := Fintype.ofFinite X
  intro f f' hf hf'
  let F : Fin k ↪ X := ⟨f, hf⟩
  let F' : Fin k ↪ X := ⟨f', hf'⟩
  let e : {x // x ∈ Set.range F} ≃ {x // x ∈ Set.range F'} :=
    F.toEquivRange.symm.trans F'.toEquivRange
  refine ⟨e.extendSubtype, funext fun i => ?_⟩
  show e.extendSubtype (f i) = f' i
  have hmem : (f i) ∈ Set.range F := ⟨i, rfl⟩
  rw [Equiv.extendSubtype_apply_of_mem e (f i) hmem]
  show ((F'.toEquivRange (F.toEquivRange.symm ⟨f i, hmem⟩) : {x // x ∈ Set.range F'}) : X) = f' i
  rw [show (⟨f i, hmem⟩ : {x // x ∈ Set.range F}) = ⟨F i, ⟨i, rfl⟩⟩ from rfl,
    Function.Embedding.toEquivRange_symm_apply_self F i,
    Function.Embedding.toEquivRange_apply F' i]
  rfl

/-- The Bell bound is attained: for the symmetric group of an `n`-element set and any `k ≤ n`,
the `k`-th moment of the fixed-point series equals `B_k · n!`.  (For `k = 1` this is the
classical fact that the average number of fixed points of a permutation is `1`.)  In particular
the main criterion is not vacuous. -/
theorem sum_fixedPoints_pow_perm {X : Type*} [Fintype X] [DecidableEq X] (k : ℕ)
    (hk : k ≤ Fintype.card X) :
    ∑ g : Equiv.Perm X, Nat.card (fixedBy X g) ^ k
      = bell k * Nat.factorial (Fintype.card X) := by
  have hk' : k ≤ Nat.card X := by rwa [Nat.card_eq_fintype_card]
  have h := (sum_fixedPoints_pow_eq_bell_mul_card_iff k (Equiv.Perm X) X hk').2
    (perm_kTransitive k)
  rw [h, Nat.card_eq_fintype_card (α := Equiv.Perm X), Fintype.card_perm]

end Symmetric

/-! ## Part 10: monotonicity of the hierarchy -/

section Monotone

variable {X : Type*} {k : ℕ}

/-- An injective `k`-tuple extends to an injective `(k+1)`-tuple when `k + 1 ≤ |X|`. -/
theorem exists_injective_succ [Finite X] (hk : k + 1 ≤ Nat.card X) (f : Fin k → X)
    (hf : Injective f) :
    ∃ F : Fin (k + 1) → X, Injective F ∧ ∀ i : Fin k, F i.castSucc = f i := by
  classical
  letI := Fintype.ofFinite X
  have hcard : (Finset.univ.image f).card = k := by
    rw [Finset.card_image_of_injective _ hf]; simp
  have hne : ∃ y : X, y ∉ Finset.univ.image f := by
    by_contra hcon
    push_neg at hcon
    have huniv : (Finset.univ.image f) = Finset.univ := Finset.eq_univ_iff_forall.2 hcon
    rw [huniv, Finset.card_univ, ← Nat.card_eq_fintype_card] at hcard
    omega
  obtain ⟨y, hy⟩ := hne
  refine ⟨Fin.snoc f y, ?_, fun i => by simp⟩
  intro a b hab
  induction a using Fin.lastCases with
  | last =>
    induction b using Fin.lastCases with
    | last => rfl
    | cast j =>
      exfalso
      simp only [Fin.snoc_last, Fin.snoc_castSucc] at hab
      exact hy (Finset.mem_image.2 ⟨j, Finset.mem_univ j, hab.symm⟩)
  | cast i =>
    induction b using Fin.lastCases with
    | last =>
      exfalso
      simp only [Fin.snoc_last, Fin.snoc_castSucc] at hab
      exact hy (Finset.mem_image.2 ⟨i, Finset.mem_univ i, hab⟩)
    | cast j =>
      simp only [Fin.snoc_castSucc] at hab
      rw [hf hab]

variable (G : Type*) [Group G] [MulAction G X]

/-- The transitivity hierarchy is decreasing: `(k+1)`-transitivity implies `k`-transitivity
(provided there are at least `k + 1` points, so that tuples can be extended). -/
theorem kTransitive_of_succ [Finite X] (hk : k + 1 ≤ Nat.card X)
    (h : KTransitive (k + 1) G X) : KTransitive k G X := by
  intro f f' hf hf'
  obtain ⟨F, hF, hFe⟩ := exists_injective_succ hk f hf
  obtain ⟨F', hF', hFe'⟩ := exists_injective_succ hk f' hf'
  obtain ⟨g, hg⟩ := h F F' hF hF'
  refine ⟨g, funext fun i => ?_⟩
  have := congrFun hg i.castSucc
  show g • f i = f' i
  rw [← hFe i, ← hFe' i]
  exact this

/-- Consequently, extremality of one moment propagates downwards: if the `(k+1)`-st moment of the
trace family attains the Bell value, so does the `k`-th. -/
theorem sum_fixedPoints_pow_eq_bell_of_succ [Fintype G] [Finite X] (hk : k + 1 ≤ Nat.card X)
    (h : (∑ g : G, Nat.card (fixedBy X g) ^ (k + 1)) = bell (k + 1) * Nat.card G) :
    (∑ g : G, Nat.card (fixedBy X g) ^ k) = bell k * Nat.card G := by
  have hk' : k ≤ Nat.card X := le_trans (Nat.le_succ k) hk
  refine (sum_fixedPoints_pow_eq_bell_mul_card_iff k G X hk').2 ?_
  exact kTransitive_of_succ G hk ((sum_fixedPoints_pow_eq_bell_mul_card_iff (k + 1) G X hk).1 h)

end Monotone

/-! ## Part 8: the graded (q-series) form -/

section Graded

variable (G : Type*) [Group G] [Fintype G] (Y : ℕ → Type*) [∀ n, MulAction G (Y n)]
  [∀ n, Finite (Y n)]

/-- The trace ("McKay–Thompson"-type) series of `g`: the `n`-th coefficient is the number of
points of grade `n` fixed by `g`. -/
noncomputable def traceSeries (g : G) : ℕ → ℕ := fun n => Nat.card (fixedBy (Y n) g)

/-- **Graded Bell rigidity.**  If every grade of a graded finite `G`-set is `k`-transitive, then
the coefficientwise `k`-th moment of the family of trace series is the constant series
`B_k·|G|`, and conversely this value at a grade forces `k`-transitivity there. -/
theorem sum_traceSeries_pow_eq_bell_iff (k : ℕ) (n : ℕ) (hk : k ≤ Nat.card (Y n)) :
    (∑ g : G, traceSeries G Y g n ^ k) = bell k * Nat.card G ↔ KTransitive k G (Y n) :=
  sum_fixedPoints_pow_eq_bell_mul_card_iff k G (Y n) hk

theorem sum_traceSeries_pow_eq_bell_of_kTransitive (k : ℕ)
    (hk : ∀ n, k ≤ Nat.card (Y n)) (htr : ∀ n, KTransitive k G (Y n)) (n : ℕ) :
    (∑ g : G, traceSeries G Y g n ^ k) = bell k * Nat.card G :=
  (sum_traceSeries_pow_eq_bell_iff G Y k n (hk n)).2 (htr n)

/-- Unconditional graded lower bound: every coefficient of the `k`-th moment series of a
moonshine-type trace family dominates `B_k·|G|`. -/
theorem bell_mul_card_le_sum_traceSeries_pow (k : ℕ) (n : ℕ) (hk : k ≤ Nat.card (Y n)) :
    bell k * Nat.card G ≤ ∑ g : G, traceSeries G Y g n ^ k :=
  bell_mul_card_le_sum_fixedPoints_pow k G (Y n) hk

end Graded

end MoonshineBell