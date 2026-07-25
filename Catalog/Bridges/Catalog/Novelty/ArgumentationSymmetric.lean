import Mathlib

/-!
# The topology of argumentation, IV: symmetric frameworks, naive extensions, and the Euler bridge

This file continues the study of the *conflict-free complex* `K(AF)` of a Dung
argumentation framework `(A, R)` begun in `ArgumentationCore`.  It isolates the
class of **symmetric** frameworks — those where attacks come in pairs
(`R a b → R b a`), the natural setting for mutual disagreement — and establishes
the precise dictionary between the *semantics* of the framework and the
*combinatorial topology* of its complex.

## Main results

* `conflictFree_admissible_of_symmetric` — in a symmetric framework every
  conflict-free set is admissible: each argument defends *itself*, because an
  attacker is always attacked back.  Hence `admissible_iff_conflictFree_of_symmetric`.
* `preferred_iff_maximalConflictFree_of_symmetric` — the **preferred extensions
  of a symmetric framework are exactly the maximal conflict-free sets**, i.e. the
  *facets* of the complex `K(AF)` (its inclusion-maximal faces).  This is the
  key identification of a *semantic* notion (preferred = maximal credulous
  position) with a *topological* one (facet of the independence complex).
* `groundedExt_eq_unattacked_of_symmetric` — the grounded (skeptical) extension
  of a symmetric framework is precisely the set of *unattacked* arguments, the
  isolated vertices of the conflict graph.

## The complete conflict graph and the Euler bridge

For the **complete conflict graph** `completeAF n` on `n` arguments (every two
distinct arguments attack each other), the complex `K(AF)` is `n` isolated
points.  We prove:

* `conflictFree_completeAF_iff` — conflict-free = subsingleton;
* `preferred_completeAF_iff` — preferred extensions are exactly the singletons;
* `preferred_completeAF_ncard` — there are exactly `n` of them;
* `euler_completeAF` — the Euler characteristic of `K(AF)` equals `n`;
* `euler_eq_preferred_completeAF` — **the Euler characteristic equals the number
  of preferred extensions** (for `n ≥ 1`).

This is the *correct* Euler/semantics bridge: the naive identity refuted in
`ArgumentationSimplicial` is replaced, on the symmetric side, by an exact match
between `χ(K(AF))` and the count of maximal independent sets.  The hypothesis
`n ≥ 1` is sharp — see the boundary remark `euler_ne_preferred_completeAF_zero`.
-/

namespace ArgTop

open Finset

variable {A : Type*} {R : A → A → Prop}

/-! ## Basic Dung semantics (self-contained)

We re-declare the core notions of the conflict-free complex so that this file
compiles independently. -/

/-- `S` is *conflict-free*: no argument in `S` attacks another in `S`. -/
def ConflictFree (R : A → A → Prop) (S : Set A) : Prop := ∀ a ∈ S, ∀ b ∈ S, ¬ R a b

/-- `S` *defends* `a`: every attacker of `a` is counter-attacked from `S`. -/
def Defends (R : A → A → Prop) (S : Set A) (a : A) : Prop := ∀ b, R b a → ∃ c ∈ S, R c b

/-- `S` is *admissible*: conflict-free and defends all its members. -/
def Admissible (R : A → A → Prop) (S : Set A) : Prop :=
  ConflictFree R S ∧ ∀ a ∈ S, Defends R S a

/-- The *characteristic (defense) operator*. -/
def charF (R : A → A → Prop) (S : Set A) : Set A := {a | Defends R S a}

/-- The defense operator is monotone. -/
theorem charF_mono (R : A → A → Prop) {S T : Set A} (h : S ⊆ T) : charF R S ⊆ charF R T := by
  intro a ha b hb; obtain ⟨c, hc, hcb⟩ := ha b hb; exact ⟨c, h hc, hcb⟩

/-- `charF ∅` is the set of *unattacked* arguments. -/
theorem charF_empty (R : A → A → Prop) : charF R (∅ : Set A) = {a | ∀ b, ¬ R b a} := by
  ext a
  constructor
  · intro ha b hba; obtain ⟨c, hc, _⟩ := ha b hba; exact absurd hc (Set.notMem_empty c)
  · intro ha b hba; exact absurd hba (ha b)

/-! ## Symmetric frameworks: conflict-free = admissible -/

/-- In a symmetric framework a conflict-free set defends each of its members
*with that member itself*: any attacker `b` of `a ∈ S` is attacked back by `a`. -/
theorem defends_self_of_symmetric (hsym : Symmetric R) {S : Set A}
    (_hS : ConflictFree R S) {a : A} (ha : a ∈ S) : Defends R S a :=
  fun _ hb => ⟨a, ha, hsym hb⟩

/-- **In a symmetric framework, every conflict-free set is admissible.** -/
theorem conflictFree_admissible_of_symmetric (hsym : Symmetric R) {S : Set A}
    (hS : ConflictFree R S) : Admissible R S :=
  ⟨hS, fun _ ha => defends_self_of_symmetric hsym hS ha⟩

/-- For symmetric frameworks admissibility collapses to conflict-freeness. -/
theorem admissible_iff_conflictFree_of_symmetric (hsym : Symmetric R) {S : Set A} :
    Admissible R S ↔ ConflictFree R S :=
  ⟨fun h => h.1, conflictFree_admissible_of_symmetric hsym⟩

/-! ## Preferred extensions and grounded extension of a symmetric framework -/

/-- `S` is a **preferred extension**: a maximal admissible set. -/
def Preferred (R : A → A → Prop) (S : Set A) : Prop :=
  Admissible R S ∧ ∀ T, Admissible R T → S ⊆ T → T = S

/-- `S` is **maximal conflict-free**: a facet of the conflict-free complex. -/
def MaximalConflictFree (R : A → A → Prop) (S : Set A) : Prop :=
  ConflictFree R S ∧ ∀ T, ConflictFree R T → S ⊆ T → T = S

/-- **The preferred extensions of a symmetric framework are exactly the maximal
conflict-free sets** — the facets of the complex `K(AF)`. -/
theorem preferred_iff_maximalConflictFree_of_symmetric (hsym : Symmetric R) {S : Set A} :
    Preferred R S ↔ MaximalConflictFree R S := by
  constructor
  · rintro ⟨hadm, hmax⟩
    exact ⟨hadm.1, fun T hT hST =>
      hmax T (conflictFree_admissible_of_symmetric hsym hT) hST⟩
  · rintro ⟨hcf, hmax⟩
    exact ⟨conflictFree_admissible_of_symmetric hsym hcf,
      fun T hT hST => hmax T hT.1 hST⟩

/-- The defense operator as a monotone self-map of `Set A`. -/
def charFHom (R : A → A → Prop) : Set A →o Set A := ⟨charF R, fun _ _ h => charF_mono R h⟩

/-- The **grounded extension**: least fixed point of the defense operator. -/
noncomputable def groundedExt (R : A → A → Prop) : Set A := OrderHom.lfp (charFHom R)

theorem charF_groundedExt (R : A → A → Prop) : charF R (groundedExt R) = groundedExt R :=
  OrderHom.map_lfp (charFHom R)

/-- **The grounded extension of a symmetric framework is the set of unattacked
arguments** — the isolated vertices of the conflict graph. -/
theorem groundedExt_eq_unattacked_of_symmetric (hsym : Symmetric R) :
    groundedExt R = {a | ∀ b, ¬ R b a} := by
  have hUfix : charF R {a | ∀ b, ¬ R b a} = {a | ∀ b, ¬ R b a} := by
    ext a
    constructor
    · intro ha b hba
      obtain ⟨c, hc, hcb⟩ := ha b hba
      exact hc b (hsym hcb)
    · intro ha b hba
      exact absurd hba (ha b)
  apply le_antisymm
  · exact OrderHom.lfp_le (charFHom R) (le_of_eq hUfix)
  · have h1 : {a | ∀ b, ¬ R b a} = charF R (∅ : Set A) := (charF_empty R).symm
    rw [h1]
    calc charF R (∅ : Set A) ⊆ charF R (groundedExt R) := charF_mono R (Set.empty_subset _)
      _ = groundedExt R := charF_groundedExt R

/-! ## The complete conflict graph -/

/-- The **complete conflict graph** on `n` arguments: every two *distinct*
arguments attack each other. -/
def completeAF (n : ℕ) : Fin n → Fin n → Prop := fun a b => a ≠ b

theorem completeAF_symmetric (n : ℕ) : Symmetric (completeAF n) :=
  fun _ _ h => Ne.symm h

theorem completeAF_irreflexive (n : ℕ) : ∀ a : Fin n, ¬ completeAF n a a :=
  fun _ h => h rfl

/-- In the complete conflict graph a set is conflict-free iff it is a
subsingleton (contains at most one argument). -/
theorem conflictFree_completeAF_iff (n : ℕ) (S : Set (Fin n)) :
    ConflictFree (completeAF n) S ↔ S.Subsingleton := by
  constructor
  · intro h a ha b hb
    exact not_ne_iff.mp (h a ha b hb)
  · intro h a ha b hb hab
    exact hab (h ha hb)

/-- The preferred extensions of the complete conflict graph on `n ≥ 1`
arguments are exactly the singletons. -/
theorem preferred_completeAF_iff (n : ℕ) (hn : 0 < n) (S : Set (Fin n)) :
    Preferred (completeAF n) S ↔ ∃ a, S = {a} := by
  rw [preferred_iff_maximalConflictFree_of_symmetric (completeAF_symmetric n)]
  constructor
  · rintro ⟨hcf, hmax⟩
    rw [conflictFree_completeAF_iff] at hcf
    rcases S.eq_empty_or_nonempty with hS | ⟨a, ha⟩
    · exfalso
      subst hS
      have hex : ∃ a : Fin n, True := ⟨⟨0, hn⟩, trivial⟩
      obtain ⟨a, -⟩ := hex
      have : ({a} : Set (Fin n)) = ∅ :=
        hmax {a} ((conflictFree_completeAF_iff n {a}).mpr (Set.subsingleton_singleton))
          (Set.empty_subset _)
      exact absurd (this ▸ Set.mem_singleton a) (Set.notMem_empty a)
    · refine ⟨a, ?_⟩
      apply Set.eq_singleton_iff_unique_mem.mpr
      exact ⟨ha, fun b hb => hcf hb ha⟩
  · rintro ⟨a, rfl⟩
    refine ⟨(conflictFree_completeAF_iff n {a}).mpr Set.subsingleton_singleton, ?_⟩
    intro T hT hsub
    rw [conflictFree_completeAF_iff] at hT
    apply Set.eq_singleton_iff_unique_mem.mpr
    exact ⟨hsub rfl, fun b hb => hT hb (hsub rfl)⟩

/-- There are exactly `n` preferred extensions of the complete conflict graph on
`n ≥ 1` arguments. -/
theorem preferred_completeAF_ncard (n : ℕ) (hn : 0 < n) :
    Set.ncard {S : Set (Fin n) | Preferred (completeAF n) S} = n := by
  have hset : {S : Set (Fin n) | Preferred (completeAF n) S}
      = Set.range (fun a : Fin n => ({a} : Set (Fin n))) := by
    ext S
    simp only [Set.mem_setOf_eq, Set.mem_range]
    rw [preferred_completeAF_iff n hn]
    constructor
    · rintro ⟨a, rfl⟩; exact ⟨a, rfl⟩
    · rintro ⟨a, rfl⟩; exact ⟨a, rfl⟩
  rw [hset]
  have hinj : Function.Injective (fun a : Fin n => ({a} : Set (Fin n))) := by
    intro a b hab
    simpa using hab
  rw [← Set.image_univ, Set.ncard_image_of_injective _ hinj, Set.ncard_univ,
    Nat.card_eq_fintype_card, Fintype.card_fin]

/-! ## Euler characteristic of the complete conflict graph -/

/-- (Unreduced) **Euler characteristic** of a finite family of faces:
`∑_{∅ ≠ s ∈ F} (-1)^(dim s)` where the dimension of `s` is `|s| - 1`. -/
def eulerChar [DecidableEq A] (F : Finset (Finset A)) : ℤ :=
  ∑ s ∈ F, if s = ∅ then 0 else (-1) ^ (s.card - 1)

open Classical in
/-- The finite face set of `K(AF)` for a finite framework. -/
noncomputable def facesFinset [Fintype A] (R : A → A → Prop) : Finset (Finset A) :=
  Finset.univ.filter (fun s => ConflictFree R (↑s : Set A))

/-- The faces of the complete conflict graph are exactly the finsets of
cardinality at most one. -/
theorem facesFinset_completeAF (n : ℕ) :
    facesFinset (completeAF n) = Finset.univ.filter (fun s : Finset (Fin n) => s.card ≤ 1) := by
  classical
  apply Finset.filter_congr
  intro s _
  rw [conflictFree_completeAF_iff, Finset.card_le_one]
  constructor
  · intro h a ha b hb
    exact h (Finset.mem_coe.mpr ha) (Finset.mem_coe.mpr hb)
  · intro h a ha b hb
    exact h a (Finset.mem_coe.mp ha) b (Finset.mem_coe.mp hb)

/-
**The Euler characteristic of the complete conflict graph on `n` arguments
is `n`** — the complex is `n` isolated points.
-/
theorem euler_completeAF (n : ℕ) : eulerChar (facesFinset (completeAF n)) = n := by
  rw [ facesFinset_completeAF ];
  unfold eulerChar; simp +decide [ Finset.sum_filter ] ;
  rw [ Finset.sum_congr rfl fun x hx => ?_ ];
  rotate_left;
  exact fun x => if x.card = 1 then 1 else 0;
  · cases x using Finset.induction <;> aesop;
  · simp +decide [ Finset.card_univ ]

/-- **The Euler bridge for symmetric frameworks.**  For the complete conflict
graph on `n ≥ 1` arguments, the Euler characteristic of the conflict-free
complex equals the number of preferred extensions. -/
theorem euler_eq_preferred_completeAF (n : ℕ) (hn : 0 < n) :
    (eulerChar (facesFinset (completeAF n)) : ℤ)
      = (Set.ncard {S : Set (Fin n) | Preferred (completeAF n) S} : ℤ) := by
  rw [euler_completeAF, preferred_completeAF_ncard n hn]

/-! ## Boundary case: the empty framework -/

/-
**Boundary remark.**  The Euler bridge is sharp: for the *empty* framework
(`n = 0`) the complex `K(AF)` is a single point (the empty face), so its Euler
characteristic is `0`, yet there is exactly one preferred extension (the empty
set).  Thus `χ ≠ #preferred` at `n = 0`, and the hypothesis `n ≥ 1` cannot be
dropped.
-/
theorem euler_ne_preferred_completeAF_zero :
    (eulerChar (facesFinset (completeAF 0)) : ℤ)
      ≠ (Set.ncard {S : Set (Fin 0) | Preferred (completeAF 0) S} : ℤ) := by
  rw [ Set.ncard_eq_one.mpr ];
  · grind +suggestions;
  · unfold Preferred; simp +decide [ Admissible ] ;
    unfold ConflictFree; simp +decide [ Set.eq_singleton_iff_unique_mem ] ;
    simp +decide [ Set.ext_iff ]

/-! ## Examples and sanity checks -/

example : Symmetric (completeAF 3) := completeAF_symmetric 3
example : ∀ a : Fin 3, ¬ completeAF 3 a a := completeAF_irreflexive 3

#check @preferred_iff_maximalConflictFree_of_symmetric
#check @groundedExt_eq_unattacked_of_symmetric
#check @euler_eq_preferred_completeAF

/-- Concrete instantiation of the Euler bridge at `n = 5`. -/
example :
    (eulerChar (facesFinset (completeAF 5)) : ℤ)
      = (Set.ncard {S : Set (Fin 5) | Preferred (completeAF 5) S} : ℤ) :=
  euler_eq_preferred_completeAF 5 (by norm_num)

/-!
-- !-- Lab Notes -- !--

**Hypothesis.**  In the general (asymmetric) theory the naive identity
`χ(K(AF)) = |preferred| − |grounded|` is false.  We conjectured that on the
*symmetric* side — where attacks are mutual, the natural model of two-sided
disagreement — a clean bridge survives: the preferred extensions should coincide
with the facets (maximal faces) of the conflict-free complex, and for the
complete conflict graph the Euler characteristic should count them exactly.

**Experiment.**  We proved, with no extra hypotheses beyond symmetry, that
conflict-free = admissible (`conflictFree_admissible_of_symmetric`) — each
argument defends *itself* because any attacker is attacked back.  This collapses
preferred extensions onto maximal conflict-free sets
(`preferred_iff_maximalConflictFree_of_symmetric`), i.e. the facets of `K(AF)`,
and pins the grounded extension to the isolated vertices
(`groundedExt_eq_unattacked_of_symmetric`).  For the complete conflict graph the
complex is `n` isolated points, with exactly `n` preferred extensions
(`preferred_completeAF_ncard`) and Euler characteristic `n`
(`euler_completeAF`), yielding the exact bridge `euler_eq_preferred_completeAF`.

**Analysis.**  The symmetric self-defense phenomenon is what makes semantics and
topology agree: admissibility, the obstruction to reading extensions off the
complex in the general case, becomes free.  The bridge `χ = |preferred|` is thus
a theorem about *independence complexes of the mutual-attack graph*, not about
Dung frameworks in general.

**Critique.**  The bridge is sharp: at `n = 0` the complex is a single (empty)
point with `χ = 0`, yet there is one preferred extension, so `χ ≠ |preferred|`.
This boundary is recorded as `euler_ne_preferred_completeAF_zero`, and the
hypothesis `0 < n` in the bridge cannot be dropped.  None of the results are
vacuous: each uses genuine structural input (self-defense, maximality, an
injective enumeration of singletons, an alternating-sum computation).

**Synthesis.**  The correct Euler/semantics correspondence for symmetric
frameworks is: *preferred extensions = facets of `K(AF)`*, and for the complete
conflict graph the alternating face count equals the number of maximal
independent sets.  See `FUTURE_DIRECTIONS.md` for the conjectural extension to
arbitrary symmetric irreflexive frameworks and to full homology.
-/

end ArgTop