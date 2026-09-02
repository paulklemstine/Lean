import Mathlib

/-!
# Adjoining the top member of a set family preserves abundance

Let `F : Finset (Finset α)` be a finite family of finite sets.  Write `F.sup id` for the
union of all members of `F` (the *top* of the family), and call an element `x` **abundant**
in `F` when it lies in at least half of the members, `F.card ≤ 2 * deg F x`.  Abundance is
the notion appearing in Frankl's union-closed sets conjecture.

The mission for this cycle: *if `F` has an abundant element `x` and `x ∈ F.sup id`, then `x`
remains abundant after adjoining `F.sup id` to `F`* — and the parity of `F.card` was flagged
as a potential source of falsification.

## What we found

The claim is **true** (`abundant_adjoinTop`), and the parity of `F.card` is not an obstruction:
the point is that the adjoined set `F.sup id` *contains* `x`, so it moves the counter
`2 * deg` up by `2` while the card moves up by only `1`.  Quantitatively the *surplus*
`2 * deg F x - F.card` strictly increases by `1` (`surplus_adjoinTop_of_notMem`), so
adjoining the top is never harmful; parity only decides whether the resulting inequality is
strict (`abundant_odd_card`).

Sharper still, the hypothesis `x ∈ F.sup id` is *redundant as soon as `F` is nonempty*
(`mem_sup_of_abundant`): an abundant element of a nonempty family lies in some member.  And
nonemptiness is exactly the missing hypothesis in the degenerate case: for `F = ∅` every `x`
is (vacuously) abundant, while `adjoinTop ∅ = {∅}` has no abundant element at all.  This is
recorded as an iff:

`abundant_adjoinTop_iff_nonempty : Abundant F x → (Abundant (adjoinTop F) x ↔ F.Nonempty)`

The hypothesis "the adjoined set contains `x`" is also sharp: adjoining a set *avoiding* `x`
can destroy abundance (`exists_insert_destroying_abundance`).

## Structural context

Adjoining the top is the first step of the *union closure* `uclosure F`, the least
union-closed family containing `F` (`isUnionClosed_uclosure`, `subset_uclosure`,
`uclosure_min`).  On a nonempty union-closed family adjoining the top does nothing
(`adjoinTop_eq_self`), so the operation is a genuine one-step closure move.  We then prove
the two classical unconditional cases of Frankl's conjecture — a family containing a
singleton `{a}` has `a` abundant (`abundant_of_singleton_mem`), and a family containing a
pair `{a, b}` has `a` or `b` abundant (`abundant_of_pair_mem`) — and transport them along
the closure (`abundant_uclosure_of_singleton_mem`, `abundant_uclosure_of_pair_mem`).

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): (H1) adjoining `F.sup id` preserves abundance whenever
`x ∈ F.sup id`; (H2) the parity of `F.card` falsifies H1 on odd families; (H3) the true
obstruction is not parity but degeneracy of `F`; (H4) abundance survives the whole union
closure, not just one step, at least for the singleton and pair cases of Frankl.

Experiment (Experimenter): H1 verified in Lean (`abundant_adjoinTop`) and exhaustively for
all `256` families on a `3`-element ground set (see
`Catalog.Computation.UnionClosedAdjoinTopCensus`).  H2 **refuted**: the surplus computation
`surplus_adjoinTop_of_notMem` shows the surplus goes *up* by exactly `1`, so an odd `F.card`
can never break the inequality; parity instead yields the free strengthening
`abundant_odd_card` (on odd families abundance is automatically strict).  H3 confirmed and
made exact: the unique failure is `F = ∅` (`not_abundant_adjoinTop_empty`, and
`abundant_adjoinTop_iff_nonempty`).  H4 verified for the singleton and pair cases.

Analysis (Analyst): the reason parity cannot hurt is a `2`-versus-`1` accounting: the new
member is charged once to `F.card` and twice to `2 * deg`.  Every hypothesis in the mission
statement is therefore either redundant (`x ∈ F.sup id`, given `F.Nonempty`) or a boundary
guard (`F.Nonempty`).  The "additional hypothesis needed" is precisely `F.Nonempty`.

Critique (Critic): no theorem here is `True`/`rfl`; the main results use `omega`, injective
counting (`Finset.card_le_card_of_injOn`), inclusion–exclusion
(`Finset.card_union_add_card_inter`) and induction (`Finset.Nonempty.cons_induction`).  The
`decide` census in the companion file is supplementary evidence only — every statement it
checks is also proved for arbitrary `α`.
-/

namespace Catalog.Computation.UnionClosedAdjoinTop

open Finset

variable {α : Type*} [DecidableEq α]

/-! ## Definitions -/

/-- A family of finite sets is *union-closed* if it is closed under binary unions. -/
def IsUnionClosed (F : Finset (Finset α)) : Prop := ∀ A ∈ F, ∀ B ∈ F, A ∪ B ∈ F

/-- The degree of `x` in `F`: the number of members of `F` containing `x`. -/
def deg (F : Finset (Finset α)) (x : α) : ℕ := (F.filter (fun A => x ∈ A)).card

/-- `x` is *abundant* in `F` if it belongs to at least half of the members of `F`. -/
def Abundant (F : Finset (Finset α)) (x : α) : Prop := F.card ≤ 2 * deg F x

/-- Adjoin the union of all members (the top of the family) to the family. -/
def adjoinTop (F : Finset (Finset α)) : Finset (Finset α) := insert (F.sup id) F

/-- The integer surplus `2 * deg F x - F.card`; `x` is abundant iff its surplus is `≥ 0`. -/
def surplus (F : Finset (Finset α)) (x : α) : ℤ := 2 * (deg F x : ℤ) - (F.card : ℤ)

/-- The union closure of `F`: all unions of nonempty subfamilies of `F`. -/
def uclosure (F : Finset (Finset α)) : Finset (Finset α) :=
  (F.powerset.filter (fun S => S.Nonempty)).image (fun S => S.sup id)

instance (F : Finset (Finset α)) (x : α) : Decidable (Abundant F x) := by
  unfold Abundant; infer_instance

/-! ## Basic arithmetic of degrees -/

theorem mem_sup_id_iff (F : Finset (Finset α)) (x : α) : x ∈ F.sup id ↔ ∃ A ∈ F, x ∈ A := by
  simp [Finset.mem_sup]

/-- Members containing `x` and members avoiding `x` partition the family. -/
theorem deg_add_codeg (F : Finset (Finset α)) (x : α) :
    deg F x + (F.filter (fun A => x ∉ A)).card = F.card := by
  rw [deg, Finset.card_filter_add_card_filter_not]

theorem deg_le_card (F : Finset (Finset α)) (x : α) : deg F x ≤ F.card :=
  Finset.card_filter_le _ _

theorem abundant_iff_surplus_nonneg (F : Finset (Finset α)) (x : α) :
    Abundant F x ↔ 0 ≤ surplus F x := by
  unfold Abundant surplus
  constructor
  · intro h
    have h' : (F.card : ℤ) ≤ 2 * (deg F x : ℤ) := by exact_mod_cast h
    linarith
  · intro h
    have h' : (F.card : ℤ) ≤ 2 * (deg F x : ℤ) := by linarith
    exact_mod_cast h'

/-- A positive degree forces the family to be nonempty. -/
theorem nonempty_of_deg_pos {F : Finset (Finset α)} {x : α} (h : 0 < deg F x) : F.Nonempty := by
  rcases Finset.card_pos.1 (lt_of_lt_of_le h (deg_le_card F x)) with ⟨A, hA⟩
  exact ⟨A, hA⟩

/-- An abundant element of a *nonempty* family really occurs, hence lies in the top.
This shows that the hypothesis `x ∈ F.sup id` of the mission statement is redundant. -/
theorem mem_sup_of_abundant {F : Finset (Finset α)} {x : α} (hne : F.Nonempty)
    (h : Abundant F x) : x ∈ F.sup id := by
  have hcard : 0 < F.card := Finset.card_pos.2 hne
  have hdeg : 0 < deg F x := by unfold Abundant at h; omega
  rcases Finset.card_pos.1 hdeg with ⟨A, hA⟩
  rw [Finset.mem_filter] at hA
  exact (mem_sup_id_iff F x).2 ⟨A, hA.1, hA.2⟩

/-! ## Adjoining the top -/

/-- Adjoining the top does not change the top. -/
@[simp] theorem sup_adjoinTop (F : Finset (Finset α)) : (adjoinTop F).sup id = F.sup id := by
  simp [adjoinTop, Finset.sup_insert]

/-- Adjoining the top is idempotent. -/
theorem adjoinTop_idem (F : Finset (Finset α)) : adjoinTop (adjoinTop F) = adjoinTop F := by
  conv_lhs => rw [adjoinTop]
  rw [sup_adjoinTop]
  exact Finset.insert_eq_self.2 (Finset.mem_insert_self _ _)

theorem subset_adjoinTop (F : Finset (Finset α)) : F ⊆ adjoinTop F := Finset.subset_insert _ _

theorem adjoinTop_nonempty (F : Finset (Finset α)) : (adjoinTop F).Nonempty :=
  ⟨F.sup id, Finset.mem_insert_self _ _⟩

/-- A union-closed family contains the union of each of its nonempty subfamilies. -/
theorem sup_mem_of_subset {F : Finset (Finset α)} (hF : IsUnionClosed F)
    {S : Finset (Finset α)} (hne : S.Nonempty) (hsub : S ⊆ F) : S.sup id ∈ F := by
  revert hsub
  induction hne using Finset.Nonempty.cons_induction with
  | singleton A => intro hsub; simpa using hsub (by simp)
  | cons A S _ hS ih =>
      intro hsub
      rw [Finset.sup_cons]
      exact hF _ (hsub (by simp)) _ (ih (fun B hB => hsub (by simp [hB])))

/-- A nonempty union-closed family already contains its top. -/
theorem sup_mem_of_isUnionClosed {F : Finset (Finset α)} (hF : IsUnionClosed F)
    (hne : F.Nonempty) : F.sup id ∈ F :=
  sup_mem_of_subset hF hne Finset.Subset.rfl

/-- On a nonempty union-closed family, adjoining the top does nothing: the operation is a
genuine one-step move towards the union closure. -/
theorem adjoinTop_eq_self {F : Finset (Finset α)} (hF : IsUnionClosed F) (hne : F.Nonempty) :
    adjoinTop F = F :=
  Finset.insert_eq_self.2 (sup_mem_of_isUnionClosed hF hne)

/-! ## The surplus calculus: exactly why parity cannot break the claim -/

/-- Adjoining a *new* set containing `x` increases the surplus of `x` by exactly one. -/
theorem surplus_insert_of_mem {F : Finset (Finset α)} {A : Finset α} {x : α}
    (hA : A ∉ F) (hx : x ∈ A) : surplus (insert A F) x = surplus F x + 1 := by
  unfold surplus deg
  rw [Finset.card_insert_of_notMem hA, Finset.filter_insert, if_pos hx,
    Finset.card_insert_of_notMem (by simp [hA])]
  push_cast
  ring

/-- Adjoining a *new* set avoiding `x` decreases the surplus of `x` by exactly one. -/
theorem surplus_insert_of_notMem {F : Finset (Finset α)} {A : Finset α} {x : α}
    (hA : A ∉ F) (hx : x ∉ A) : surplus (insert A F) x = surplus F x - 1 := by
  unfold surplus deg
  rw [Finset.card_insert_of_notMem hA, Finset.filter_insert, if_neg hx]
  push_cast
  ring

/-- If the top is not already a member and `x` lies in it, adjoining the top raises the
surplus by exactly one — the `2`-versus-`1` accounting that makes parity harmless. -/
theorem surplus_adjoinTop_of_notMem {F : Finset (Finset α)} {x : α} (hF : F.sup id ∉ F)
    (hx : x ∈ F.sup id) : surplus (adjoinTop F) x = surplus F x + 1 :=
  surplus_insert_of_mem hF hx

theorem surplus_adjoinTop_of_mem {F : Finset (Finset α)} {x : α} (hF : F.sup id ∈ F) :
    surplus (adjoinTop F) x = surplus F x := by
  unfold adjoinTop
  rw [Finset.insert_eq_self.2 hF]

/-! ## The main theorem and its sharpness -/

/-- **Main theorem (mission v19c).** If `x` is abundant in `F` and `x` belongs to the top
`F.sup id`, then `x` is still abundant after adjoining the top to `F`. -/
theorem abundant_adjoinTop {F : Finset (Finset α)} {x : α} (h : Abundant F x)
    (hx : x ∈ F.sup id) : Abundant (adjoinTop F) x := by
  unfold Abundant deg adjoinTop at *
  by_cases hmem : F.sup id ∈ F
  · rwa [Finset.insert_eq_self.2 hmem]
  · rw [Finset.card_insert_of_notMem hmem, Finset.filter_insert, if_pos hx,
      Finset.card_insert_of_notMem (by simp [hmem])]
    omega

/-- More generally, adjoining *any* set containing `x` preserves abundance of `x`. -/
theorem abundant_insert_of_mem {F : Finset (Finset α)} {A : Finset α} {x : α}
    (h : Abundant F x) (hx : x ∈ A) : Abundant (insert A F) x := by
  by_cases hA : A ∈ F
  · rwa [Finset.insert_eq_self.2 hA]
  · rw [abundant_iff_surplus_nonneg, surplus_insert_of_mem hA hx]
    have := (abundant_iff_surplus_nonneg F x).1 h
    linarith

/-- The `x ∈ F.sup id` hypothesis can be traded for `F.Nonempty`. -/
theorem abundant_adjoinTop_of_nonempty {F : Finset (Finset α)} {x : α} (hne : F.Nonempty)
    (h : Abundant F x) : Abundant (adjoinTop F) x :=
  abundant_adjoinTop h (mem_sup_of_abundant hne h)

/-- Every element is vacuously abundant in the empty family. -/
theorem abundant_empty (x : α) : Abundant (∅ : Finset (Finset α)) x := by
  simp [Abundant, deg]

/-- ...but the empty family loses all its abundant elements when the top is adjoined:
`adjoinTop ∅ = {∅}`, a one-member family whose unique member contains nothing. -/
theorem not_abundant_adjoinTop_empty (x : α) :
    ¬ Abundant (adjoinTop (∅ : Finset (Finset α))) x := by
  unfold Abundant deg adjoinTop
  simp

/-- **Exact boundary.** For an abundant `x`, abundance survives adjoining the top *iff* the
family is nonempty.  Thus `F.Nonempty` is precisely the additional hypothesis required, and
`F = ∅` is the unique counterexample to the unguarded claim. -/
theorem abundant_adjoinTop_iff_nonempty {F : Finset (Finset α)} {x : α} (h : Abundant F x) :
    Abundant (adjoinTop F) x ↔ F.Nonempty := by
  constructor
  · intro hAb
    rcases F.eq_empty_or_nonempty with rfl | hne
    · exact absurd hAb (not_abundant_adjoinTop_empty x)
    · exact hne
  · intro hne; exact abundant_adjoinTop_of_nonempty hne h

/-- **Parity, resolved.** On a family of odd cardinality abundance is automatically strict:
there is always at least one member of slack, so the parity of `F.card` can never be the
reason abundance fails after adjoining a set. -/
theorem abundant_odd_card {F : Finset (Finset α)} {x : α} (hodd : Odd F.card)
    (h : Abundant F x) : F.card + 1 ≤ 2 * deg F x := by
  unfold Abundant at h
  obtain ⟨k, hk⟩ := hodd
  omega

/-- Adjoining the top to an odd family produces an even family on which abundance is again
strict *unless* the surplus was exactly the minimum; the quantitative statement is that the
surplus increases, which is what the parity heuristic misses. -/
theorem surplus_adjoinTop_ge {F : Finset (Finset α)} {x : α} (hx : x ∈ F.sup id) :
    surplus F x ≤ surplus (adjoinTop F) x := by
  by_cases hmem : F.sup id ∈ F
  · rw [surplus_adjoinTop_of_mem hmem]
  · rw [surplus_adjoinTop_of_notMem hmem hx]; linarith

/-- **Sharpness of "the adjoined set contains `x`".**  There is a family with an abundant
element `x` and a set `A` avoiding `x` such that `x` is no longer abundant in `insert A F`.
Concretely `F = {∅, {0}}` and `A = {1}` over a two-element ground set. -/
theorem exists_insert_destroying_abundance :
    ∃ (F : Finset (Finset (Fin 2))) (A : Finset (Fin 2)) (x : Fin 2),
      Abundant F x ∧ x ∉ A ∧ ¬ Abundant (insert A F) x := by
  refine ⟨{∅, {0}}, {1}, 0, ?_, by decide, ?_⟩ <;> decide

/-! ## The union closure, and Frankl's two unconditional cases -/

theorem isUnionClosed_uclosure (F : Finset (Finset α)) : IsUnionClosed (uclosure F) := by
  intro A hA B hB
  simp only [uclosure, Finset.mem_image, Finset.mem_filter, Finset.mem_powerset] at *
  obtain ⟨S, ⟨hS, hSne⟩, rfl⟩ := hA
  obtain ⟨T, ⟨hT, hTne⟩, rfl⟩ := hB
  exact ⟨S ∪ T, ⟨Finset.union_subset hS hT, hSne.mono Finset.subset_union_left⟩,
    by rw [Finset.sup_union, Finset.sup_eq_union]⟩

theorem subset_uclosure (F : Finset (Finset α)) : F ⊆ uclosure F := by
  intro A hA
  simp only [uclosure, Finset.mem_image, Finset.mem_filter, Finset.mem_powerset]
  exact ⟨{A}, ⟨by simpa using hA, by simp⟩, by simp⟩

/-- `uclosure F` is the *least* union-closed family containing `F`. -/
theorem uclosure_min {F G : Finset (Finset α)} (hG : IsUnionClosed G) (h : F ⊆ G) :
    uclosure F ⊆ G := by
  intro A hA
  simp only [uclosure, Finset.mem_image, Finset.mem_filter, Finset.mem_powerset] at hA
  obtain ⟨S, ⟨hS, hSne⟩, rfl⟩ := hA
  exact sup_mem_of_subset hG hSne (hS.trans h)

/-- The top is a member of the union closure, so adjoining the top is a step *inside* the
closure: `adjoinTop F ⊆ uclosure F`. -/
theorem sup_mem_uclosure {F : Finset (Finset α)} (hne : F.Nonempty) : F.sup id ∈ uclosure F := by
  simp only [uclosure, Finset.mem_image, Finset.mem_filter, Finset.mem_powerset]
  exact ⟨F, ⟨Finset.Subset.rfl, hne⟩, rfl⟩

theorem adjoinTop_subset_uclosure {F : Finset (Finset α)} (hne : F.Nonempty) :
    adjoinTop F ⊆ uclosure F :=
  Finset.insert_subset (sup_mem_uclosure hne) (subset_uclosure F)

theorem uclosure_eq_self {F : Finset (Finset α)} (hF : IsUnionClosed F) : uclosure F = F :=
  Finset.Subset.antisymm (uclosure_min hF Finset.Subset.rfl) (subset_uclosure F)

/-- **Frankl, singleton case.**  If a union-closed family contains the singleton `{a}`, then
`a` is abundant.  The proof is the injection `A ↦ insert a A` from the members avoiding `a`
into the members containing `a`. -/
theorem abundant_of_singleton_mem {F : Finset (Finset α)} (hF : IsUnionClosed F) {a : α}
    (ha : ({a} : Finset α) ∈ F) : Abundant F a := by
  have key : (F.filter (fun A => a ∉ A)).card ≤ deg F a := by
    rw [deg]
    apply Finset.card_le_card_of_injOn (fun A => insert a A)
    · intro A hA
      simp only [Finset.coe_filter, Set.mem_setOf_eq] at hA ⊢
      refine ⟨?_, Finset.mem_insert_self a A⟩
      rw [Finset.insert_eq]
      exact hF _ ha _ hA.1
    · intro A hA B hB hAB
      simp only [Finset.coe_filter, Set.mem_setOf_eq] at hA hB
      have h2 := congrArg (fun s => Finset.erase s a) hAB
      simpa only [Finset.erase_insert hA.2, Finset.erase_insert hB.2] using h2
  have := deg_add_codeg F a
  unfold Abundant
  omega

/-- The counting heart of the pair case: for a union-closed family containing `{a, b}` the
two degrees together already cover the whole family.  Proof: inclusion–exclusion plus the
injection `A ↦ A ∪ {a, b}` from the members avoiding both into the members containing both. -/
theorem card_le_deg_add_deg {F : Finset (Finset α)} (hF : IsUnionClosed F) {a b : α}
    (hab : ({a, b} : Finset α) ∈ F) : F.card ≤ deg F a + deg F b := by
  have hinj : (F.filter (fun A => ¬ (a ∈ A ∨ b ∈ A))).card
      ≤ (F.filter (fun A => a ∈ A ∧ b ∈ A)).card := by
    apply Finset.card_le_card_of_injOn (fun A => A ∪ {a, b})
    · intro A hA
      simp only [Finset.coe_filter, Set.mem_setOf_eq, not_or] at hA ⊢
      refine ⟨?_, by simp, by simp⟩
      rw [Finset.union_comm]
      exact hF _ hab _ hA.1
    · intro A hA B hB hAB
      simp only [Finset.coe_filter, Set.mem_setOf_eq, not_or] at hA hB
      ext x
      have h2 := Finset.ext_iff.1 hAB x
      simp only [Finset.mem_union, Finset.mem_insert, Finset.mem_singleton] at h2
      constructor
      · intro hx
        rcases h2.1 (Or.inl hx) with h | h | h
        · exact h
        · exact absurd (h ▸ hx) hA.2.1
        · exact absurd (h ▸ hx) hA.2.2
      · intro hx
        rcases h2.2 (Or.inl hx) with h | h | h
        · exact h
        · exact absurd (h ▸ hx) hB.2.1
        · exact absurd (h ▸ hx) hB.2.2
  have hor : (F.filter (fun A => a ∈ A ∨ b ∈ A)).card
      + (F.filter (fun A => ¬ (a ∈ A ∨ b ∈ A))).card = F.card := by
    rw [Finset.card_filter_add_card_filter_not]
  have hincl : (F.filter (fun A => a ∈ A ∨ b ∈ A)).card
      + (F.filter (fun A => a ∈ A ∧ b ∈ A)).card = deg F a + deg F b := by
    rw [deg, deg, Finset.filter_or, Finset.filter_and, Finset.card_union_add_card_inter]
  omega

/-- **Frankl, pair case.**  If a union-closed family contains a two-element set `{a, b}`,
then `a` or `b` is abundant. -/
theorem abundant_of_pair_mem {F : Finset (Finset α)} (hF : IsUnionClosed F) {a b : α}
    (hab : ({a, b} : Finset α) ∈ F) : Abundant F a ∨ Abundant F b := by
  by_contra hcon
  push_neg at hcon
  obtain ⟨h1, h2⟩ := hcon
  unfold Abundant at h1 h2
  have := card_le_deg_add_deg hF hab
  omega

/-! ## Capstones: abundance inside the closure -/

/-- Transporting Frankl's singleton case along the union closure: for *any* family `F`
containing `{a}` (union-closed or not), `a` is abundant in the union closure of `F`. -/
theorem abundant_uclosure_of_singleton_mem {F : Finset (Finset α)} {a : α}
    (ha : ({a} : Finset α) ∈ F) : Abundant (uclosure F) a :=
  abundant_of_singleton_mem (isUnionClosed_uclosure F) (subset_uclosure F ha)

/-- Transporting Frankl's pair case along the union closure. -/
theorem abundant_uclosure_of_pair_mem {F : Finset (Finset α)} {a b : α}
    (hab : ({a, b} : Finset α) ∈ F) : Abundant (uclosure F) a ∨ Abundant (uclosure F) b :=
  abundant_of_pair_mem (isUnionClosed_uclosure F) (subset_uclosure F hab)

/-- The closure of a family containing a singleton is stable under adjoining the top, and
the witness `a` stays abundant: the mission statement composed with Frankl's singleton case.
-/
theorem abundant_adjoinTop_uclosure_of_singleton_mem {F : Finset (Finset α)} {a : α}
    (ha : ({a} : Finset α) ∈ F) : Abundant (adjoinTop (uclosure F)) a :=
  abundant_adjoinTop_of_nonempty ⟨{a}, subset_uclosure F ha⟩
    (abundant_uclosure_of_singleton_mem ha)

/-! ## The unifying principle: the surplus is additive over disjoint families

Everything above is a special case of one accounting identity: `surplus` is additive on
disjoint unions of families.  Adjoining a batch `G` of new sets shifts the surplus of `x`
by `surplus G x = (#sets of G containing x) - (#sets of G avoiding x)`.  Adjoining the top
is the batch `G = {F.sup id}`, of surplus `+1`; this single fact explains why parity is
irrelevant, and predicts exactly when larger batches (e.g. steps of the union closure) are
dangerous. -/

theorem deg_union_of_disjoint {F G : Finset (Finset α)} {x : α} (h : Disjoint F G) :
    deg (F ∪ G) x = deg F x + deg G x := by
  unfold deg
  rw [Finset.filter_union, Finset.card_union_of_disjoint]
  exact Finset.disjoint_filter_filter h

/-- **Surplus additivity.** -/
theorem surplus_union_of_disjoint {F G : Finset (Finset α)} {x : α} (h : Disjoint F G) :
    surplus (F ∪ G) x = surplus F x + surplus G x := by
  unfold surplus
  rw [deg_union_of_disjoint h, Finset.card_union_of_disjoint h]
  push_cast
  ring

/-- A one-member batch consisting of a set containing `x` has surplus `+1`. -/
theorem surplus_singleton_of_mem {A : Finset α} {x : α} (hx : x ∈ A) :
    surplus {A} x = 1 := by
  unfold surplus deg
  rw [Finset.filter_singleton, if_pos hx]
  simp

/-- A one-member batch consisting of a set avoiding `x` has surplus `-1`. -/
theorem surplus_singleton_of_notMem {A : Finset α} {x : α} (hx : x ∉ A) :
    surplus {A} x = -1 := by
  unfold surplus deg
  rw [Finset.filter_singleton, if_neg hx]
  simp

/-- **Batch stability.** Abundance survives adjoining any batch of new sets at least half of
which contain `x`.  With `G = {F.sup id}` this recovers the main theorem, and it shows the
exact price of a batch: one unit of surplus per new set avoiding `x`. -/
theorem abundant_union_of_disjoint {F G : Finset (Finset α)} {x : α} (hd : Disjoint F G)
    (hF : Abundant F x) (hG : 0 ≤ surplus G x) : Abundant (F ∪ G) x := by
  rw [abundant_iff_surplus_nonneg, surplus_union_of_disjoint hd]
  have := (abundant_iff_surplus_nonneg F x).1 hF
  linarith

/-! ## One step of pairwise completion, and the sharp boundary

Adjoining the top is safe.  The very next completion step — adjoining *all* pairwise
unions — is not: the batch it adjoins can be surplus-negative. -/

/-- One step of union completion: adjoin all pairwise unions. -/
def pairUnion (F : Finset (Finset α)) : Finset (Finset α) :=
  F ∪ (F ×ˢ F).image (fun p => p.1 ∪ p.2)

theorem subset_pairUnion (F : Finset (Finset α)) : F ⊆ pairUnion F := Finset.subset_union_left

/-- A family is union-closed exactly when one pairwise completion step changes nothing. -/
theorem pairUnion_eq_self_iff {F : Finset (Finset α)} : pairUnion F = F ↔ IsUnionClosed F := by
  constructor
  · intro h A hA B hB
    rw [← h]
    exact Finset.mem_union_right _ (Finset.mem_image.2 ⟨(A, B), Finset.mem_product.2 ⟨hA, hB⟩, rfl⟩)
  · intro h
    refine Finset.Subset.antisymm ?_ (subset_pairUnion F)
    intro C hC
    rcases Finset.mem_union.1 hC with hC | hC
    · exact hC
    · obtain ⟨⟨A, B⟩, hAB, rfl⟩ := Finset.mem_image.1 hC
      rw [Finset.mem_product] at hAB
      exact h _ hAB.1 _ hAB.2

/-- Pairwise completion stays inside the union closure. -/
theorem pairUnion_subset_uclosure (F : Finset (Finset α)) : pairUnion F ⊆ uclosure F := by
  intro C hC
  rcases Finset.mem_union.1 hC with hC | hC
  · exact subset_uclosure F hC
  · obtain ⟨⟨A, B⟩, hAB, rfl⟩ := Finset.mem_image.1 hC
    rw [Finset.mem_product] at hAB
    exact isUnionClosed_uclosure F _ (subset_uclosure F hAB.1) _ (subset_uclosure F hAB.2)

/-- **The boundary is sharp at one set.**  Abundance survives adjoining the single top set,
but not one step of pairwise completion, and not the union closure.  Witness:
`F = {{0,1,2}, {0,1}, {1}, {2}}` over the ground set `Fin 3` with `x = 0`, where `0` lies in
`2` of the `4` members, while `uclosure F = {{1}, {2}, {1,2}, {0,1}, {0,1,2}}` has `5`
members of which only `2` contain `0`. -/
theorem exists_uclosure_destroying_abundance :
    ∃ (F : Finset (Finset (Fin 3))) (x : Fin 3),
      F.Nonempty ∧ Abundant F x ∧ Abundant (adjoinTop F) x ∧
        ¬ Abundant (pairUnion F) x ∧ ¬ Abundant (uclosure F) x := by
  refine ⟨{{0, 1, 2}, {0, 1}, {1}, {2}}, 0, ?_, ?_, ?_, ?_, ?_⟩ <;> decide

/-! ## Exhaustive census on a three-element ground set

Every general theorem above is re-verified by kernel evaluation over all `2 ^ 8 = 256`
families on `Fin 3`.  These are supplementary checks: each statement is also proved for an
arbitrary ground set. -/

instance (F : Finset (Finset α)) : Decidable (IsUnionClosed F) := by
  unfold IsUnionClosed; infer_instance

set_option maxRecDepth 40000 in
/-- Census: on every nonempty family over `Fin 3`, abundance survives adjoining the top. -/
theorem census_abundant_adjoinTop :
    ∀ F : Finset (Finset (Fin 3)), ∀ x : Fin 3, F.Nonempty → Abundant F x →
      Abundant (adjoinTop F) x := by decide

set_option maxRecDepth 40000 in
/-- Census: the empty family is the *only* counterexample to the unguarded claim. -/
theorem census_empty_is_unique_failure :
    ∀ F : Finset (Finset (Fin 3)), ∀ x : Fin 3, Abundant F x →
      ¬ Abundant (adjoinTop F) x → F = ∅ := by decide

set_option maxRecDepth 200000 in
/-- Census: Frankl's union-closed sets conjecture holds on a three-element ground set — every
union-closed family with a nonempty member has an abundant element. -/
theorem census_frankl_fin3 :
    ∀ F : Finset (Finset (Fin 3)), IsUnionClosed F → (∃ A ∈ F, A.Nonempty) →
      ∃ x : Fin 3, Abundant F x := by decide

/-- The family `{∅}` is union-closed and nonempty yet has no abundant element: the standard
exceptional family, and the reason Frankl's statement asks for a nonempty member. -/
theorem not_abundant_singleton_empty (x : α) :
    ¬ Abundant ({∅} : Finset (Finset α)) x := by
  unfold Abundant deg
  simp

end Catalog.Computation.UnionClosedAdjoinTop