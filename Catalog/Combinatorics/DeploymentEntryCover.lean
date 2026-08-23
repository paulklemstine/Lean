import Combinatorics.MathReadsAsProse

/-!
# Deployment entries as an interval point-cover (NET-70, cycle 2)

NET-70 ends with an operational claim: *"prose + math workloads share one entry;
only code shifts"*.  This file makes that claim a theorem of extremal
combinatorics and then asks — and answers — the sharper question it raises:

> given the three-domain knee set `{prose ↦ 16, code ↦ 12, math ↦ 16}` and an
> over-provisioning tolerance `δ` (how many keys of waste a deployment is
> willing to pay on the cheapest domain), how many distinct cache-size entries
> does a fleet actually need?

A single served entry `b` for a domain of knee `k` must satisfy `k ≤ b` (else
quality falls below the gate) and `b ≤ k + δ` (else the waste budget is blown).
So an entry is a *point* and a domain is the *interval* `[k, k+δ]`: the number
of entries is the minimum number of points meeting a family of equal-length
integer intervals.

Results:

* `single_entry_iff` — one entry suffices **iff** the knee spread is at most
  `δ`.  This is the exact criterion behind the NET-70 deployment sentence.
* `card_le_of_separated` — a **packing lower bound**: `δ`-separated knees force
  distinct entries (pigeonhole via an injection into any entry set).
* `exists_entrySet_card_le` — a **greedy upper bound**: knees inside `[a, b]`
  are always served by the arithmetic progression `a, a+δ+1, …`, of size
  `(b-a)/(δ+1) + 1`.
* `min_entries_eq_of_arithmetic` — the two bounds **meet** on the extremal
  configuration: for an arithmetic progression of knees with common difference
  `δ+1` the minimum number of entries is exactly its length.  A genuine min–max
  (packing = covering) duality for this deployment problem.
* `net70_three_domains_one_entry`, `net70_three_domains_need_two` — the measured
  table: with `δ ≥ 4` the whole three-domain fleet collapses to the *single*
  entry `16`; with `δ ≤ 3` it provably needs two.  The NET-70 sentence is
  therefore the `δ ≤ 3` regime, and `δ = 4` — exactly one scale increment
  (NET-67) — is the point where code rejoins prose and math.
-/

namespace Combinatorics.DeploymentEntryCover

open Finset

/-- A cache-size entry `b` **serves** a domain of knee `k` at waste tolerance
`δ` when it is large enough to clear the gate and not wasteful by more than
`δ`. -/
def Serves (δ b k : ℕ) : Prop := k ≤ b ∧ b ≤ k + δ

instance (δ b k : ℕ) : Decidable (Serves δ b k) := by unfold Serves; infer_instance

/-- `E` is a valid **entry set** for the knee set `K`. -/
def IsEntrySet (δ : ℕ) (K E : Finset ℕ) : Prop := ∀ k ∈ K, ∃ b ∈ E, Serves δ b k

/-! ## One entry -/

/-- **The single-entry criterion.**  A fleet of domains can be served by one
cache size iff its knee spread does not exceed the waste tolerance. -/
theorem single_entry_iff {δ : ℕ} {K : Finset ℕ} (hK : K.Nonempty) :
    (∃ b, ∀ k ∈ K, Serves δ b k) ↔ K.max' hK ≤ K.min' hK + δ := by
  constructor
  · rintro ⟨b, hb⟩
    obtain ⟨hmax, _⟩ := hb _ (K.max'_mem hK)
    obtain ⟨_, hmin⟩ := hb _ (K.min'_mem hK)
    omega
  · intro h
    refine ⟨K.max' hK, fun k hk => ⟨K.le_max' k hk, ?_⟩⟩
    have := K.min'_le k hk
    omega

/-! ## The packing lower bound -/

/-- Two knees further than `δ` apart cannot share an entry. -/
theorem not_serves_both {δ b k l : ℕ} (hkl : k + δ < l) :
    ¬ (Serves δ b k ∧ Serves δ b l) := by
  rintro ⟨⟨_, h2⟩, ⟨h3, _⟩⟩
  omega

/-- **Packing bound.**  If `S ⊆ K` is pairwise `δ`-separated, then every entry
set for `K` has at least `#S` entries: distinct separated knees are served by
distinct entries. -/
theorem card_le_of_separated {δ : ℕ} {K S E : Finset ℕ} (hSK : S ⊆ K)
    (hsep : ∀ k ∈ S, ∀ l ∈ S, k < l → k + δ < l) (hE : IsEntrySet δ K E) :
    S.card ≤ E.card := by
  classical
  choose f hf hfs using fun k (hk : k ∈ S) => hE k (hSK hk)
  refine Finset.card_le_card_of_injOn (fun k => if hk : k ∈ S then f k hk else 0) ?_ ?_
  · intro k hk
    have hk' : k ∈ S := hk
    simp only [dif_pos hk']
    exact hf k hk'
  · intro k hk l hl hkl
    have hk : k ∈ S := hk
    have hl : l ∈ S := hl
    simp only [dif_pos hk, dif_pos hl] at hkl
    by_contra hne
    rcases lt_or_gt_of_ne hne with h | h
    · exact not_serves_both (hsep k hk l hl h) ⟨hfs k hk, hkl ▸ hfs l hl⟩
    · exact not_serves_both (hsep l hl k hk h) ⟨hfs l hl, hkl ▸ hfs k hk⟩

/-! ## The greedy upper bound -/

/-- The greedy entry set on `[a, b]`: the arithmetic progression of step
`δ + 1` counted **down** from the top of the knee range (an entry must be at
least as large as the knee it serves, so the progression is anchored above). -/
def greedyEntries (δ b m : ℕ) : Finset ℕ := (range m).image fun i => b - (δ + 1) * i

theorem greedyEntries_card_le (δ b m : ℕ) : (greedyEntries δ b m).card ≤ m := by
  unfold greedyEntries
  exact le_trans (card_image_le) (by simp)

/-- **Greedy covering bound.**  Any knee set inside `[a, b]` is served by
`(b - a) / (δ + 1) + 1` entries. -/
theorem exists_entrySet_card_le {δ a b : ℕ} {K : Finset ℕ}
    (hK : ∀ k ∈ K, a ≤ k ∧ k ≤ b) :
    ∃ E : Finset ℕ, IsEntrySet δ K E ∧ E.card ≤ (b - a) / (δ + 1) + 1 := by
  refine ⟨greedyEntries δ b ((b - a) / (δ + 1) + 1), ?_, greedyEntries_card_le _ _ _⟩
  intro k hk
  obtain ⟨hak, hkb⟩ := hK k hk
  set y := b - k with hy
  have hyk : k + y = b := by omega
  have hyba : y ≤ b - a := by omega
  have hdm : y % (δ + 1) + (δ + 1) * (y / (δ + 1)) = y := Nat.mod_add_div y (δ + 1)
  have hmod : y % (δ + 1) < δ + 1 := Nat.mod_lt _ (Nat.succ_pos δ)
  refine ⟨b - (δ + 1) * (y / (δ + 1)), ?_, ?_, ?_⟩
  · unfold greedyEntries
    refine mem_image.mpr ⟨y / (δ + 1), mem_range.mpr ?_, rfl⟩
    exact Nat.lt_succ_of_le (Nat.div_le_div_right (c := δ + 1) hyba)
  · generalize (δ + 1) * (y / (δ + 1)) = q at hdm ⊢
    omega
  · generalize (δ + 1) * (y / (δ + 1)) = q at hdm ⊢
    omega

/-! ## Packing meets covering -/

/-- The extremal knee configuration: `m` knees spaced exactly `δ + 1` apart. -/
def apKnees (δ a m : ℕ) : Finset ℕ := (range m).image fun i => a + (δ + 1) * i

theorem apKnees_card (δ a m : ℕ) : (apKnees δ a m).card = m := by
  unfold apKnees
  have hinj : Function.Injective fun i => a + (δ + 1) * i := by
    intro x y hxy
    simp only at hxy
    exact Nat.eq_of_mul_eq_mul_left (Nat.succ_pos δ) (Nat.add_left_cancel hxy)
  rw [card_image_of_injective _ hinj, card_range]

theorem apKnees_separated (δ a m : ℕ) :
    ∀ k ∈ apKnees δ a m, ∀ l ∈ apKnees δ a m, k < l → k + δ < l := by
  intro k hk l hl hkl
  unfold apKnees at hk hl
  obtain ⟨i, _, rfl⟩ := mem_image.mp hk
  obtain ⟨j, _, rfl⟩ := mem_image.mp hl
  have hlt : (δ + 1) * i < (δ + 1) * j := Nat.lt_of_add_lt_add_left hkl
  have hij : i < j := Nat.lt_of_mul_lt_mul_left hlt
  have hstep : (δ + 1) * (i + 1) ≤ (δ + 1) * j := Nat.mul_le_mul_left _ hij
  have hexp : (δ + 1) * (i + 1) = (δ + 1) * i + δ + 1 := by ring
  rw [hexp] at hstep
  linarith

theorem apKnees_bounds {δ a m : ℕ} :
    ∀ k ∈ apKnees δ a m, a ≤ k ∧ k ≤ a + (δ + 1) * (m - 1) := by
  intro k hk
  unfold apKnees at hk
  obtain ⟨i, hi, rfl⟩ := mem_image.mp hk
  have hi' : i ≤ m - 1 := by have := mem_range.mp hi; omega
  refine ⟨by omega, ?_⟩
  have := Nat.mul_le_mul_left (δ + 1) hi'
  linarith

/-- **Min–max duality for deployment entries.**  On the extremal configuration
(`m` knees spaced `δ + 1` apart) the greedy covering bound and the packing lower
bound coincide: the minimum number of cache-size entries is *exactly* `m`.
Neither bound can be improved. -/
theorem min_entries_eq_of_arithmetic (δ a m : ℕ) (hm : 0 < m) :
    (∃ E : Finset ℕ, IsEntrySet δ (apKnees δ a m) E ∧ E.card ≤ m) ∧
      (∀ E : Finset ℕ, IsEntrySet δ (apKnees δ a m) E → m ≤ E.card) := by
  constructor
  · obtain ⟨E, hE, hcard⟩ :=
      exists_entrySet_card_le (δ := δ) (a := a) (b := a + (δ + 1) * (m - 1))
        (K := apKnees δ a m) apKnees_bounds
    refine ⟨E, hE, le_trans hcard ?_⟩
    have hsub : a + (δ + 1) * (m - 1) - a = (δ + 1) * (m - 1) := by omega
    have hdiv : (a + (δ + 1) * (m - 1) - a) / (δ + 1) = m - 1 := by
      rw [hsub, Nat.mul_div_cancel_left _ (by omega : 0 < δ + 1)]
    omega
  · intro E hE
    have := card_le_of_separated (K := apKnees δ a m) (S := apKnees δ a m)
      (Subset.refl _) (apKnees_separated δ a m) hE
    rwa [apKnees_card] at this

/-! ## The measured three-domain table -/

/-- The NET-70 knee set at ctx 512: `code ↦ 12`, `prose ↦ 16`, `math ↦ 16`. -/
def net70Knees : Finset ℕ := {12, 16}

theorem net70Knees_nonempty : net70Knees.Nonempty := ⟨12, by decide⟩

theorem net70Knees_min : net70Knees.min' net70Knees_nonempty = 12 := by decide

theorem net70Knees_max : net70Knees.max' net70Knees_nonempty = 16 := by decide

/-- **With four keys of slack the fleet collapses to one entry.**  `δ = 4` is
exactly one scale increment (NET-67): at that tolerance the single cache size
`16` serves prose, mathematics **and** code. -/
theorem net70_three_domains_one_entry {δ : ℕ} (hδ : 4 ≤ δ) :
    ∃ b, ∀ k ∈ net70Knees, Serves δ b k := by
  rw [single_entry_iff net70Knees_nonempty, net70Knees_min, net70Knees_max]
  omega

/-- **Below four keys of slack two entries are unavoidable** — and two always
suffice.  This is the regime the NET-70 deployment sentence describes: prose and
math share an entry, code shifts. -/
theorem net70_three_domains_need_two {δ : ℕ} (hδ : δ ≤ 3) :
    (¬ ∃ b, ∀ k ∈ net70Knees, Serves δ b k) ∧
      ∃ E : Finset ℕ, IsEntrySet δ net70Knees E ∧ E.card = 2 := by
  constructor
  · rw [single_entry_iff net70Knees_nonempty, net70Knees_min, net70Knees_max]
    omega
  · refine ⟨{12, 16}, ?_, by decide⟩
    intro k hk
    fin_cases hk
    · exact ⟨12, by decide, by unfold Serves; omega⟩
    · exact ⟨16, by decide, by unfold Serves; omega⟩

/-- The exact threshold: the three-domain table has one entry precisely when the
tolerance reaches the scale increment `4`. -/
theorem net70_entry_threshold (δ : ℕ) :
    (∃ b, ∀ k ∈ net70Knees, Serves δ b k) ↔ 4 ≤ δ := by
  rw [single_entry_iff net70Knees_nonempty, net70Knees_min, net70Knees_max]
  omega

end Combinatorics.DeploymentEntryCover