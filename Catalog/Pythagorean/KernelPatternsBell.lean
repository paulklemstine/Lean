import Pythagorean.KernelPatterns

/-!
# Kernel patterns are counted by the Bell numbers, in every arity

`Pythagorean.KernelPatterns` verifies by `decide` that the number of equality patterns of an
`n`-tuple is `1, 1, 2, 5, 15, 52` for `n ≤ 5`, matching Mathlib's `Nat.bell`.  Here we prove
the statement for **all** `n`:

`KernelPattern.card_patterns_eq_bell : (Patterns n).card = Nat.bell n`.

Mathlib defines `Nat.bell` by the recursion
`bell (n+1) = ∑ i : Fin (n+1), (n.choose i) * bell (n - i)`
and explicitly leaves "`Nat.bell` counts partitions" as a TODO.  The proof below supplies
exactly that statement, in the guise of kernel patterns.

The chain of reductions is:

1. `card_patterns_eq_kerCount`: patterns of length `n` biject with equivalence relations on
   `Fin n` (a relation `r` is encoded by the tuple `i ↦ r i` of its Boolean columns);
2. `kerCount_congr`: the count depends only on the index type up to bijection;
3. `kerCount_option`: an equivalence relation on `Option ι` is the same data as a subset
   `s ⊆ ι` — the block of the adjoined point — together with an equivalence relation on the
   complement of `s`;
4. `KC_succ`: summing over subsets grouped by cardinality turns 3 into the binomial
   recursion defining `Nat.bell`;
5. `KC_eq_bell`: strong induction.
-/

open Finset

namespace KernelPattern

/-! ## Boolean equivalence relations -/

/-- A `Bool`-valued equivalence relation. -/
def IsKerRel {ι : Type*} (r : ι → ι → Bool) : Prop :=
  (∀ a, r a a) ∧ (∀ a b, r a b → r b a) ∧ (∀ a b c, r a b → r b c → r a c)

instance {ι : Type*} [Fintype ι] : DecidablePred (IsKerRel (ι := ι)) := fun r => by
  unfold IsKerRel; infer_instance

/-- The finite set of equivalence relations on `ι`. -/
def KerRels (ι : Type*) [Fintype ι] [DecidableEq ι] : Finset (ι → ι → Bool) :=
  univ.filter IsKerRel

@[simp] theorem mem_kerRels {ι : Type*} [Fintype ι] [DecidableEq ι] {r : ι → ι → Bool} :
    r ∈ KerRels ι ↔ IsKerRel r := by simp [KerRels]

/-- The number of equivalence relations (equivalently, of set partitions) on `ι`. -/
def kerCount (ι : Type*) [Fintype ι] [DecidableEq ι] : ℕ := (KerRels ι).card

/-! ## Step 1: patterns biject with equivalence relations -/

section Step1

variable {n : ℕ}

/-- The equality relation of a pattern. -/
def relOfPat (p : Fin n → Fin n) : Fin n → Fin n → Bool := fun i j => decide (p i = p j)

theorem isKerRel_relOfPat (p : Fin n → Fin n) : IsKerRel (relOfPat p) := by
  refine ⟨fun a => by simp [relOfPat], ?_, ?_⟩
  · intro a b h
    simp only [relOfPat, decide_eq_true_eq] at h ⊢
    exact h.symm
  · intro a b c h₁ h₂
    simp only [relOfPat, decide_eq_true_eq] at h₁ h₂ ⊢
    exact h₁.trans h₂

/-- The tuple of Boolean columns of a relation.  Its kernel is the relation itself, when
the relation is an equivalence relation. -/
def colsOfRel (r : Fin n → Fin n → Bool) : Fin n → (Fin n → Bool) := fun i => r i

theorem cols_eq_iff {r : Fin n → Fin n → Bool} (hr : IsKerRel r) (i j : Fin n) :
    colsOfRel r i = colsOfRel r j ↔ r i j := by
  constructor
  · intro h
    have := congrFun h j
    simp only [colsOfRel] at this
    rw [this]
    exact hr.1 j
  · intro h
    funext k
    simp only [colsOfRel]
    by_cases hik : r i k
    · have : r j k := hr.2.2 j i k (hr.2.1 i j h) hik
      simp [hik, this]
    · have : ¬ r j k := by
        intro hjk
        exact hik (hr.2.2 i j k h hjk)
      simp [hik, this]

theorem card_patterns_eq_kerCount (n : ℕ) : (Patterns n).card = kerCount (Fin n) := by
  refine Finset.card_nbij' relOfPat (fun r => canon (colsOfRel r)) ?_ ?_ ?_ ?_
  · intro p _
    exact mem_kerRels.2 (isKerRel_relOfPat p)
  · intro r _
    exact canon_mem_patterns _
  · intro p hp
    simp only [Finset.mem_coe, mem_patterns_iff] at hp
    have hker : Ker (colsOfRel (relOfPat p)) = Ker p := by
      funext i j
      refine propext ⟨fun h => ?_, fun h => ?_⟩
      · have h2 : decide (p i = p i) = decide (p j = p i) := congrFun h i
        rw [decide_eq_decide] at h2
        exact (h2.mp rfl).symm
      · have h' : p i = p j := h
        funext k
        simp only [colsOfRel, relOfPat, h']
    show canon (colsOfRel (relOfPat p)) = p
    rw [canon_congr hker, hp]
  · intro r hr
    simp only [Finset.mem_coe, mem_kerRels] at hr
    funext i j
    show decide (canon (colsOfRel r) i = canon (colsOfRel r) j) = r i j
    have hiff : (canon (colsOfRel r) i = canon (colsOfRel r) j) ↔ (r i j = true) := by
      rw [← eq_iff_canon_eq (colsOfRel r) i j]
      exact cols_eq_iff hr i j
    have hdec : decide (canon (colsOfRel r) i = canon (colsOfRel r) j) = decide (r i j = true) := by
      rw [decide_eq_decide]; exact hiff
    rw [hdec]; simp

end Step1

/-! ## Step 2: the count only depends on the index type up to bijection -/

theorem kerCount_congr {ι κ : Type*} [Fintype ι] [DecidableEq ι] [Fintype κ] [DecidableEq κ]
    (e : ι ≃ κ) : kerCount ι = kerCount κ := by
  refine Finset.card_nbij' (fun r x y => r (e.symm x) (e.symm y))
    (fun r x y => r (e x) (e y)) ?_ ?_ ?_ ?_
  · intro r hr
    simp only [Finset.mem_coe, mem_kerRels] at hr ⊢
    exact ⟨fun a => hr.1 _, fun a b h => hr.2.1 _ _ h, fun a b c h₁ h₂ => hr.2.2 _ _ _ h₁ h₂⟩
  · intro r hr
    simp only [Finset.mem_coe, mem_kerRels] at hr ⊢
    exact ⟨fun a => hr.1 _, fun a b h => hr.2.1 _ _ h, fun a b c h₁ h₂ => hr.2.2 _ _ _ h₁ h₂⟩
  · intro r _; funext x y; simp
  · intro r _; funext x y; simp

/-- The count depends only on the cardinality of the index type. -/
theorem kerCount_eq_kerCount_fin (ι : Type*) [Fintype ι] [DecidableEq ι] :
    kerCount ι = kerCount (Fin (Fintype.card ι)) :=
  kerCount_congr (Fintype.equivFin ι)

/-! ## Step 3: the block of the adjoined point -/

section Lift

variable {A B : Type*}

/-- Pull back an equivalence relation `r` on `A` along a partial map `φ : B → Option A`,
declaring all points outside the domain of `φ` to be equivalent to each other. -/
def liftRel (φ : B → Option A) (r : A → A → Bool) : B → B → Bool := fun u v =>
  match φ u, φ v with
  | none, none => true
  | some a, some b => r a b
  | _, _ => false

theorem liftRel_eq_true_iff (φ : B → Option A) (r : A → A → Bool) (u v : B) :
    liftRel φ r u v = true ↔
      (φ u = none ∧ φ v = none) ∨ ∃ a b, φ u = some a ∧ φ v = some b ∧ r a b := by
  unfold liftRel
  cases hu : φ u <;> cases hv : φ v <;> simp

/-- The lift of an equivalence relation is an equivalence relation. -/
theorem isKerRel_liftRel (φ : B → Option A) {r : A → A → Bool} (hr : IsKerRel r) :
    IsKerRel (liftRel φ r) := by
  obtain ⟨hrfl, hsym, htrn⟩ := hr
  refine ⟨fun u => ?_, fun u v h => ?_, fun u v w h₁ h₂ => ?_⟩
  · rw [liftRel_eq_true_iff]
    cases hu : φ u
    · exact Or.inl ⟨rfl, rfl⟩
    · exact Or.inr ⟨_, _, rfl, rfl, hrfl _⟩
  · rw [liftRel_eq_true_iff] at h ⊢
    rcases h with ⟨h1, h2⟩ | ⟨a, b, h1, h2, hab⟩
    · exact Or.inl ⟨h2, h1⟩
    · exact Or.inr ⟨b, a, h2, h1, hsym _ _ hab⟩
  · rw [liftRel_eq_true_iff] at h₁ h₂ ⊢
    rcases h₁ with ⟨h1, h2⟩ | ⟨a, b, h1, h2, hab⟩
    · rcases h₂ with ⟨h3, h4⟩ | ⟨a, b, h3, h4, hab⟩
      · exact Or.inl ⟨h1, h4⟩
      · exact absurd h3 (by rw [h2]; simp)
    · rcases h₂ with ⟨h3, h4⟩ | ⟨a', b', h3, h4, hab'⟩
      · exact absurd h3 (by rw [h2]; simp)
      · have : b = a' := by rw [h2] at h3; exact Option.some.inj h3
        subst this
        exact Or.inr ⟨a, b', h1, h4, htrn _ _ _ hab hab'⟩

end Lift

section Option

variable {ι : Type*} [Fintype ι] [DecidableEq ι]

/-- The partial map collapsing `none` and the block `s` to a single point. -/
def optRestrict (s : Finset ι) : Option ι → Option {x : ι // x ∈ sᶜ}
  | none => none
  | some x => if hx : x ∈ sᶜ then some ⟨x, hx⟩ else none

@[simp] theorem optRestrict_none (s : Finset ι) : optRestrict s none = none := rfl

theorem optRestrict_some_of_mem {s : Finset ι} {x : ι} (hx : x ∈ s) :
    optRestrict s (some x) = none := by
  simp [optRestrict, Finset.mem_compl, hx]

theorem optRestrict_some_of_notMem {s : Finset ι} {x : ι} (hx : x ∈ sᶜ) :
    optRestrict s (some x) = some ⟨x, hx⟩ := by
  simp [optRestrict, hx]

/-- Rebuild an equivalence relation on `Option ι` from the block `s` of the adjoined point
and an equivalence relation on the complement of `s`. -/
def extendRel (s : Finset ι) (r : {x : ι // x ∈ sᶜ} → {x : ι // x ∈ sᶜ} → Bool) :
    Option ι → Option ι → Bool := liftRel (optRestrict s) r

theorem isKerRel_extendRel {s : Finset ι} {r : {x : ι // x ∈ sᶜ} → {x : ι // x ∈ sᶜ} → Bool}
    (hr : IsKerRel r) : IsKerRel (extendRel s r) := isKerRel_liftRel _ hr

/-- The block of the adjoined point in a relation on `Option ι`. -/
def blockOfNone (ρ : Option ι → Option ι → Bool) : Finset ι :=
  univ.filter (fun x => ρ (some x) none)

theorem blockOfNone_extendRel (s : Finset ι)
    (r : {x : ι // x ∈ sᶜ} → {x : ι // x ∈ sᶜ} → Bool) :
    blockOfNone (extendRel s r) = s := by
  ext x
  simp only [blockOfNone, Finset.mem_filter, Finset.mem_univ, true_and]
  rw [extendRel, liftRel_eq_true_iff, optRestrict_none]
  constructor
  · rintro (⟨h1, -⟩ | ⟨a, b, -, hb, -⟩)
    · by_contra hx
      rw [optRestrict_some_of_notMem (Finset.mem_compl.2 hx)] at h1
      simp at h1
    · simp at hb
  · intro hx
    exact Or.inl ⟨optRestrict_some_of_mem hx, rfl⟩

theorem extendRel_some_some_of_mem_compl {s : Finset ι}
    {r : {x : ι // x ∈ sᶜ} → {x : ι // x ∈ sᶜ} → Bool} {x y : ι} (hx : x ∈ sᶜ) (hy : y ∈ sᶜ) :
    extendRel s r (some x) (some y) = r ⟨x, hx⟩ ⟨y, hy⟩ := by
  simp [extendRel, liftRel, optRestrict_some_of_notMem hx, optRestrict_some_of_notMem hy]

/-- The restriction of a relation on `Option ι` to the complement of the block of `none`. -/
def restrictRel (ρ : Option ι → Option ι → Bool) (s : Finset ι) :
    {x : ι // x ∈ sᶜ} → {x : ι // x ∈ sᶜ} → Bool := fun x y => ρ (some x.1) (some y.1)

theorem isKerRel_restrictRel {ρ : Option ι → Option ι → Bool} (hρ : IsKerRel ρ) (s : Finset ι) :
    IsKerRel (restrictRel ρ s) :=
  ⟨fun _ => hρ.1 _, fun _ _ h => hρ.2.1 _ _ h, fun _ _ _ h₁ h₂ => hρ.2.2 _ _ _ h₁ h₂⟩

/-- Reconstruction: an equivalence relation on `Option ι` is determined by the block of
`none` together with its restriction to the complement of that block. -/
theorem extendRel_restrictRel {ρ : Option ι → Option ι → Bool} (hρ : IsKerRel ρ)
    {s : Finset ι} (hs : blockOfNone ρ = s) : extendRel s (restrictRel ρ s) = ρ := by
  have hmem : ∀ x : ι, x ∈ s ↔ ρ (some x) none := by
    intro x
    rw [← hs]
    simp [blockOfNone]
  funext u v
  match u, v with
  | none, none =>
      simp [extendRel, liftRel, hρ.1 none]
  | none, some y =>
      by_cases hy : y ∈ s
      · rw [show extendRel s (restrictRel ρ s) none (some y) = true by
          simp [extendRel, liftRel, optRestrict_some_of_mem hy]]
        exact (hρ.2.1 _ _ ((hmem y).1 hy)).symm
      · have hy' : y ∈ sᶜ := Finset.mem_compl.2 hy
        rw [show extendRel s (restrictRel ρ s) none (some y) = false by
          simp [extendRel, liftRel, optRestrict_some_of_notMem hy']]
        have : ¬ (ρ none (some y) = true) := by
          intro h
          exact hy ((hmem y).2 (hρ.2.1 _ _ h))
        simpa using this
  | some x, none =>
      by_cases hx : x ∈ s
      · rw [show extendRel s (restrictRel ρ s) (some x) none = true by
          simp [extendRel, liftRel, optRestrict_some_of_mem hx]]
        exact ((hmem x).1 hx).symm
      · have hx' : x ∈ sᶜ := Finset.mem_compl.2 hx
        rw [show extendRel s (restrictRel ρ s) (some x) none = false by
          simp [extendRel, liftRel, optRestrict_some_of_notMem hx']]
        have : ¬ (ρ (some x) none = true) := fun h => hx ((hmem x).2 h)
        simpa using this
  | some x, some y =>
      by_cases hx : x ∈ s <;> by_cases hy : y ∈ s
      · rw [show extendRel s (restrictRel ρ s) (some x) (some y) = true by
          simp [extendRel, liftRel, optRestrict_some_of_mem hx, optRestrict_some_of_mem hy]]
        exact (hρ.2.2 _ _ _ ((hmem x).1 hx) (hρ.2.1 _ _ ((hmem y).1 hy))).symm
      · have hy' : y ∈ sᶜ := Finset.mem_compl.2 hy
        rw [show extendRel s (restrictRel ρ s) (some x) (some y) = false by
          simp [extendRel, liftRel, optRestrict_some_of_mem hx,
            optRestrict_some_of_notMem hy']]
        have : ¬ (ρ (some x) (some y) = true) := by
          intro h
          exact hy ((hmem y).2 (hρ.2.2 _ _ _ (hρ.2.1 _ _ h) ((hmem x).1 hx)))
        simpa using this
      · have hx' : x ∈ sᶜ := Finset.mem_compl.2 hx
        rw [show extendRel s (restrictRel ρ s) (some x) (some y) = false by
          simp [extendRel, liftRel, optRestrict_some_of_notMem hx',
            optRestrict_some_of_mem hy]]
        have : ¬ (ρ (some x) (some y) = true) := by
          intro h
          exact hx ((hmem x).2 (hρ.2.2 _ _ _ h ((hmem y).1 hy)))
        simpa using this
      · have hx' : x ∈ sᶜ := Finset.mem_compl.2 hx
        have hy' : y ∈ sᶜ := Finset.mem_compl.2 hy
        rw [extendRel_some_some_of_mem_compl hx' hy']
        rfl

/-- The fibre over a block `s` of the "block of `none`" map has exactly as many elements as
there are equivalence relations on the complement of `s`. -/
theorem card_fiber_blockOfNone (s : Finset ι) :
    ((KerRels (Option ι)).filter (fun ρ => blockOfNone ρ = s)).card
      = kerCount {x : ι // x ∈ sᶜ} := by
  refine Finset.card_nbij' (fun ρ => restrictRel ρ s) (fun r => extendRel s r) ?_ ?_ ?_ ?_
  · intro ρ hρ
    simp only [Finset.mem_coe, Finset.mem_filter, mem_kerRels] at hρ
    exact mem_kerRels.2 (isKerRel_restrictRel hρ.1 s)
  · intro r hr
    simp only [Finset.mem_coe, mem_kerRels] at hr
    simp only [Finset.mem_coe, Finset.mem_filter, mem_kerRels]
    exact ⟨isKerRel_extendRel hr, blockOfNone_extendRel s r⟩
  · intro ρ hρ
    simp only [Finset.mem_coe, Finset.mem_filter, mem_kerRels] at hρ
    exact extendRel_restrictRel hρ.1 hρ.2
  · intro r _
    funext x y
    exact extendRel_some_some_of_mem_compl x.2 y.2

theorem kerCount_option :
    kerCount (Option ι) = ∑ s : Finset ι, kerCount {x : ι // x ∈ sᶜ} := by
  rw [kerCount, Finset.card_eq_sum_card_fiberwise
    (f := blockOfNone) (t := (univ : Finset (Finset ι))) (fun x _ => Finset.mem_univ _)]
  exact Finset.sum_congr rfl fun s _ => card_fiber_blockOfNone s

end Option

/-! ## Step 4: the binomial recursion -/

/-- The number of kernel patterns of length `n`. -/
def KC (n : ℕ) : ℕ := kerCount (Fin n)

theorem KC_succ (n : ℕ) : KC (n + 1) = ∑ k ∈ range (n + 1), (n.choose k) * KC (n - k) := by
  have h1 : KC (n + 1) = kerCount (Option (Fin n)) := kerCount_congr (finSuccEquiv n)
  have h2 : ∀ s : Finset (Fin n), kerCount {x : Fin n // x ∈ sᶜ} = KC (n - s.card) := by
    intro s
    have he : {x : Fin n // x ∈ sᶜ} ≃ Fin (n - s.card) := by
      refine Fintype.equivFinOfCardEq ?_
      rw [Fintype.card_coe, Finset.card_compl, Fintype.card_fin]
    rw [kerCount_congr he, KC]
  rw [h1, kerCount_option]
  simp_rw [h2]
  rw [← Finset.sum_fiberwise_of_maps_to (g := fun s : Finset (Fin n) => s.card)
    (t := range (n + 1)) (fun s _ => Finset.mem_range.2 (Nat.lt_succ_of_le
      (le_trans (Finset.card_le_univ s) (le_of_eq (Finset.card_fin n))))) ]
  refine Finset.sum_congr rfl ?_
  intro k hk
  have hfil : (univ.filter (fun s : Finset (Fin n) => s.card = k)) = Finset.powersetCard k univ := by
    ext s
    simp [Finset.mem_powersetCard, Finset.subset_univ]
  have hconst : ∀ s ∈ univ.filter (fun s : Finset (Fin n) => s.card = k),
      KC (n - s.card) = KC (n - k) := by
    intro s hs
    rw [(Finset.mem_filter.1 hs).2]
  rw [Finset.sum_congr rfl hconst, Finset.sum_const, hfil, Finset.card_powersetCard,
    Finset.card_fin, smul_eq_mul]

/-! ## Step 5: comparison with `Nat.bell` -/

theorem KC_zero : KC 0 = 1 := by decide

theorem KC_eq_bell (n : ℕ) : KC n = Nat.bell n := by
  induction n using Nat.strong_induction_on with
  | _ n ih =>
    match n with
    | 0 => rw [KC_zero, Nat.bell_zero]
    | (m + 1) =>
        rw [KC_succ, Nat.bell_succ,
          Fin.sum_univ_eq_sum_range (fun i => m.choose i * Nat.bell (m - i))]
        refine Finset.sum_congr rfl ?_
        intro k hk
        rw [Finset.mem_range] at hk
        rw [ih (m - k) (by omega)]

/-- **Main theorem.**  For every `n`, the number of equality patterns of an `n`-tuple is the
`n`-th Bell number.  Equivalently, by `KernelPattern.exists_perm_iff_ker_eq`, the number of
orbits of `(Fin n)`-tuples under the symmetric group of the codomain is `Nat.bell n`.

Mathlib defines `Nat.bell` by its binomial recursion and leaves the partition-counting
interpretation as a TODO; this theorem supplies it. -/
theorem card_patterns_eq_bell (n : ℕ) : (Patterns n).card = Nat.bell n := by
  rw [card_patterns_eq_kerCount, ← KC, KC_eq_bell]

/-- The number of equivalence relations on any `n`-element type is `Nat.bell n`. -/
theorem kerCount_eq_bell (ι : Type*) [Fintype ι] [DecidableEq ι] :
    kerCount ι = Nat.bell (Fintype.card ι) := by
  rw [kerCount_eq_kerCount_fin, ← KC, KC_eq_bell]

end KernelPattern