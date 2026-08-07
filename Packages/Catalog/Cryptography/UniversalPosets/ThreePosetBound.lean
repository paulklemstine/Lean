import Cryptography.UniversalPosets.ExactSmall

/-!
# A three-poset overlap bound: `U(n) ≥ 3n - ⌈n/2⌉ - 3`

`ExactSmall.lean` proved `2n - 1 ≤ U(n)` by playing the `n`-chain against the
`n`-antichain: two induced copies of posets with no large common induced
subposet cannot overlap much inside a host.  Here the method is pushed to a
*third* poset, the disjoint union of two chains of lengths `⌈n/2⌉` and `⌊n/2⌋`
(`twoChains`), whose common induced subposets with the chain and with the
antichain have at most `⌈n/2⌉` and `2` points respectively.  Bonferroni's
inequality for three sets then gives

`3n - (1 + ⌈n/2⌉ + 2) ≤ U(n)`,

i.e. asymptotically `U(n) ≥ 5n/2 - 3`, which improves `2n - 1` from `n = 6` on
(and agrees with it for `n ≤ 5`, where the earlier bound is already sharp for
`n ≤ 3`).

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer).  The overlap method is not limited to two posets: any
family `P₁,…,P_k` gives `U(n) ≥ kn - Σ_{i<j} s_{ij}` where `s_{ij}` bounds the
common induced subposets.  The optimisation is a genuine extremal problem; the
first nontrivial instance is `k = 3` with chain, antichain, and two chains.

Experiment (Experimenter).  Numerically, `3n - ⌈n/2⌉ - 3` beats `2n - 1` exactly
for `n ≥ 6` (`n = 6`: `12` versus `11`; `n = 10`: `22` versus `19`); both are
dwarfed by the counting bound `2^{(n-1)/4}` from about `n = 24` on.  Adding a
fourth poset was tested on paper and does *not* help: any fourth `n`-element
poset has a chain or an antichain of size at least `√n`, and its overlaps with
the three posets above already exceed the `n` points it contributes.

Analysis (Analyst).  The method is intrinsically linear: `k` posets contribute
`kn` but a fixed pair contributes an overlap at least `Ω(log n)` by
Dilworth/Erdős–Szekeres, and for large `k` the sum of overlaps dominates.  So no
choice of family can push the overlap method past `O(n log n)`; the exponential
lower bound must come from counting, as it does in `LogBounds.lean`.

Critique (Critic).  The bound is stated with truncated natural subtraction, so it
is vacuously weak for very small `n` and no hypothesis `n ≥ 6` is needed; the
sharper claim (that it *improves* on `2n-1`) is a numerical remark, not a
theorem, and is left to the table above.
-/

namespace UniversalPosets

open Function

/-! ## Bonferroni for three finsets -/

theorem card_union_three_ge {α : Type*} [DecidableEq α] (A B C : Finset α) :
    A.card + B.card + C.card ≤
      (A ∪ B ∪ C).card + (A ∩ B).card + (A ∩ C).card + (B ∩ C).card := by
  have h1 := Finset.card_union_add_card_inter A B
  have h2 := Finset.card_union_add_card_inter (A ∪ B) C
  have h3 : ((A ∪ B) ∩ C).card ≤ (A ∩ C).card + (B ∩ C).card := by
    have : (A ∪ B) ∩ C = (A ∩ C) ∪ (B ∩ C) := by
      ext x; simp only [Finset.mem_inter, Finset.mem_union]; tauto
    rw [this]
    exact Finset.card_union_le _ _
  omega

/-! ## The third poset: two disjoint chains -/

/-- The disjoint union of a chain on `{0, …, ⌈n/2⌉-1}` and a chain on the rest:
`x ≤ y` exactly when `x ≤ y` in `Fin n` *and* `x, y` lie on the same side. -/
def twoChains (n : ℕ) : Fin n → Fin n → Prop :=
  fun x y => x ≤ y ∧ (((x : ℕ) < (n + 1) / 2) ↔ ((y : ℕ) < (n + 1) / 2))

theorem twoChains_isPartialOrder (n : ℕ) : IsPartialOrder (Fin n) (twoChains n) :=
  haveI : Std.Refl (twoChains n) := ⟨fun x => ⟨le_refl x, Iff.rfl⟩⟩
  haveI : IsTrans (Fin n) (twoChains n) :=
    ⟨fun _ _ _ h1 h2 => ⟨le_trans h1.1 h2.1, h1.2.trans h2.2⟩⟩
  haveI : IsPreorder (Fin n) (twoChains n) := ⟨⟩
  haveI : Std.Antisymm (twoChains n) := ⟨fun _ _ h1 h2 => le_antisymm h1.1 h2.1⟩
  ⟨⟩

/-- Two points on the same side of `twoChains` are comparable. -/
theorem twoChains_comparable_of_same_side {n : ℕ} (x y : Fin n)
    (hside : ((x : ℕ) < (n + 1) / 2) ↔ ((y : ℕ) < (n + 1) / 2)) :
    twoChains n x y ∨ twoChains n y x := by
  rcases le_total x y with h | h
  · exact Or.inl ⟨h, hside⟩
  · exact Or.inr ⟨h, hside.symm⟩

/-- The lower side has `⌈n/2⌉` points. -/
theorem card_low_side (n : ℕ) :
    (Finset.univ.filter (fun i : Fin n => (i : ℕ) < (n + 1) / 2)).card ≤ (n + 1) / 2 := by
  classical
  have hmaps : Set.MapsTo (fun i : Fin n => (i : ℕ))
      ↑(Finset.univ.filter (fun i : Fin n => (i : ℕ) < (n + 1) / 2))
      ↑(Finset.range ((n + 1) / 2)) := by
    intro i hi
    rw [Finset.mem_coe, Finset.mem_filter] at hi
    exact Finset.mem_coe.2 (Finset.mem_range.2 hi.2)
  have hinj : Set.InjOn (fun i : Fin n => (i : ℕ))
      ↑(Finset.univ.filter (fun i : Fin n => (i : ℕ) < (n + 1) / 2)) :=
    fun a _ b _ hab => Fin.ext hab
  have hle := Finset.card_le_card_of_injOn _ hmaps hinj
  simpa using hle

/-- The upper side has `⌊n/2⌋ ≤ ⌈n/2⌉` points. -/
theorem card_high_side (n : ℕ) :
    (Finset.univ.filter (fun i : Fin n => ¬ ((i : ℕ) < (n + 1) / 2))).card ≤ (n + 1) / 2 := by
  classical
  have hmaps : Set.MapsTo (fun i : Fin n => (i : ℕ) - (n + 1) / 2)
      ↑(Finset.univ.filter (fun i : Fin n => ¬ ((i : ℕ) < (n + 1) / 2)))
      ↑(Finset.range (n - (n + 1) / 2)) := by
    intro i hi
    rw [Finset.mem_coe, Finset.mem_filter] at hi
    obtain ⟨-, hi2⟩ := hi
    have hi3 : (n + 1) / 2 ≤ (i : ℕ) := Nat.not_lt.1 hi2
    have hlt := i.isLt
    have hgoal : (i : ℕ) - (n + 1) / 2 < n - (n + 1) / 2 := by omega
    exact Finset.mem_coe.2 (Finset.mem_range.2 hgoal)
  have hinj : Set.InjOn (fun i : Fin n => (i : ℕ) - (n + 1) / 2)
      ↑(Finset.univ.filter (fun i : Fin n => ¬ ((i : ℕ) < (n + 1) / 2))) := by
    intro a ha b hb hab
    rw [Finset.mem_coe, Finset.mem_filter] at ha hb
    obtain ⟨-, ha2⟩ := ha
    obtain ⟨-, hb2⟩ := hb
    have ha3 : (n + 1) / 2 ≤ (a : ℕ) := Nat.not_lt.1 ha2
    have hb3 : (n + 1) / 2 ≤ (b : ℕ) := Nat.not_lt.1 hb2
    simp only at hab
    exact Fin.ext (by omega)
  have hle := Finset.card_le_card_of_injOn _ hmaps hinj
  have hcard : (Finset.range (n - (n + 1) / 2)).card = n - (n + 1) / 2 := Finset.card_range _
  omega

/-! ## The two new overlap bounds -/

/-- A chain and two disjoint chains share at most `⌈n/2⌉` points: a chain inside
`twoChains` lies entirely on one side. -/
theorem commonInducedBound_chain_twoChains (n : ℕ) :
    CommonInducedBound (fun x y : Fin n => x ≤ y) (twoChains n) ((n + 1) / 2) := by
  classical
  intro A φ hinj hiso
  rcases A.eq_empty_or_nonempty with rfl | ⟨a₀, ha₀⟩
  · simp
  -- every point of `φ '' A` is on the same side as `φ a₀`
  have hside : ∀ x ∈ A, (((φ x : ℕ) < (n + 1) / 2) ↔ ((φ a₀ : ℕ) < (n + 1) / 2)) := by
    intro x hx
    rcases le_total x a₀ with h | h
    · exact ((hiso x hx a₀ ha₀).1 h).2
    · exact (((hiso a₀ ha₀ x hx).1 h).2).symm
  by_cases hlow : (φ a₀ : ℕ) < (n + 1) / 2
  · have hmaps : Set.MapsTo φ ↑A
        ↑(Finset.univ.filter (fun i : Fin n => (i : ℕ) < (n + 1) / 2)) := by
      intro x hx
      exact Finset.mem_coe.2
        (Finset.mem_filter.2 ⟨Finset.mem_univ _, (hside x (Finset.mem_coe.1 hx)).2 hlow⟩)
    exact (Finset.card_le_card_of_injOn φ hmaps hinj).trans (card_low_side n)
  · have hmaps : Set.MapsTo φ ↑A
        ↑(Finset.univ.filter (fun i : Fin n => ¬ ((i : ℕ) < (n + 1) / 2))) := by
      intro x hx
      exact Finset.mem_coe.2 (Finset.mem_filter.2
        ⟨Finset.mem_univ _, fun hc => hlow ((hside x (Finset.mem_coe.1 hx)).1 hc)⟩)
    exact (Finset.card_le_card_of_injOn φ hmaps hinj).trans (card_high_side n)

/-- An antichain and two disjoint chains share at most two points: an antichain
inside `twoChains` has at most one point on each side. -/
theorem commonInducedBound_antichain_twoChains (n : ℕ) :
    CommonInducedBound (fun x y : Fin n => x = y) (twoChains n) 2 := by
  classical
  intro A φ hinj hiso
  by_contra hcon
  push_neg at hcon
  obtain ⟨a, b, c, ha, hb, hc, hab, hac, hbc⟩ := Finset.two_lt_card_iff.1 hcon
  -- distinct points of `A` land on different sides
  have hdiff : ∀ x ∈ A, ∀ y ∈ A, x ≠ y →
      ¬ (((φ x : ℕ) < (n + 1) / 2) ↔ ((φ y : ℕ) < (n + 1) / 2)) := by
    intro x hx y hy hxy hside
    rcases twoChains_comparable_of_same_side (φ x) (φ y) hside with h | h
    · exact hxy ((hiso x hx y hy).2 h)
    · exact hxy ((hiso y hy x hx).2 h).symm
  have h1 := hdiff a ha b hb hab
  have h2 := hdiff a ha c hc hac
  have h3 := hdiff b hb c hc hbc
  tauto

/-! ## The three-poset lower bound -/

/--
**Three-poset overlap bound.**  Every host containing all `n`-element posets has
at least `3n - (3 + ⌈n/2⌉)` points.
-/
theorem three_poset_bound_of_isUniversalPosetOfSize {N n : ℕ}
    (h : IsUniversalPosetOfSize N n) : 3 * n - (3 + (n + 1) / 2) ≤ N := by
  classical
  obtain ⟨H, hH, hu⟩ := h
  obtain ⟨f, hf⟩ := hu (fun x y : Fin n => x ≤ y) inferInstance
  obtain ⟨g, hg⟩ := hu (fun x y : Fin n => x = y) (isPartialOrder_eq _)
  obtain ⟨k, hk⟩ := hu (twoChains n) (twoChains_isPartialOrder n)
  have hfinj : Injective f := injective_of_host_witness hH inferInstance hf
  have hginj : Injective g := injective_of_host_witness hH (isPartialOrder_eq _) hg
  have hkinj : Injective k := injective_of_host_witness hH (twoChains_isPartialOrder n) hk
  have hFcard : (Finset.image f Finset.univ).card = n := by
    rw [Finset.card_image_of_injective _ hfinj]; simp
  have hGcard : (Finset.image g Finset.univ).card = n := by
    rw [Finset.card_image_of_injective _ hginj]; simp
  have hKcard : (Finset.image k Finset.univ).card = n := by
    rw [Finset.card_image_of_injective _ hkinj]; simp
  have hunion :
      ((Finset.image f Finset.univ) ∪ (Finset.image g Finset.univ) ∪
        (Finset.image k Finset.univ)).card ≤ N := by
    simpa using Finset.card_le_univ
      ((Finset.image f (Finset.univ : Finset (Fin n))) ∪ (Finset.image g Finset.univ) ∪
        (Finset.image k Finset.univ))
  have hbon := card_union_three_ge (Finset.image f (Finset.univ : Finset (Fin n)))
    (Finset.image g Finset.univ) (Finset.image k Finset.univ)
  have h12 := card_inter_images_le hH inferInstance (isPartialOrder_eq _)
    (commonInducedBound_chain_antichain n) hf hg
  have h13 := card_inter_images_le hH inferInstance (twoChains_isPartialOrder n)
    (commonInducedBound_chain_twoChains n) hf hk
  have h23 := card_inter_images_le hH (isPartialOrder_eq _) (twoChains_isPartialOrder n)
    (commonInducedBound_antichain_twoChains n) hg hk
  omega

/-- **`U(n) ≥ 3n - ⌈n/2⌉ - 3`.**  For `n ≥ 6` this improves the bound
`2n - 1` of `ExactSmall.lean`; asymptotically it is `5n/2`. -/
theorem three_poset_le_minUniversalSize (n : ℕ) :
    3 * n - (3 + (n + 1) / 2) ≤ minUniversalSize n :=
  three_poset_bound_of_isUniversalPosetOfSize (isUniversalPosetOfSize_minUniversalSize n)

/-- The best linear lower bound proved in this project. -/
theorem linear_lower_bound (n : ℕ) :
    max (2 * n - 1) (3 * n - (3 + (n + 1) / 2)) ≤ minUniversalSize n :=
  max_le (two_mul_sub_one_le_minUniversalSize n) (three_poset_le_minUniversalSize n)

end UniversalPosets