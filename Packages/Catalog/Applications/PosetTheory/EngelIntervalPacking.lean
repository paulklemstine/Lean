/-
# Engel's Interval Packing Theorem — constructions, thresholds, and a contrarian analysis

Engel's interval packing problem concerns the Boolean lattice `2^[n]` restricted to
the levels `l, l+1, …, l+r`.  An *interval* is a set of the form `[T, T ∪ C]` where
`T` is an `l`-element "bottom" and `C` is an `r`-element set disjoint from `T`; the
top is `T ∪ C` (of size `l + r`).  Two intervals `[T₁, T₁ ∪ C₁]`, `[T₂, T₂ ∪ C₂]`
are **disjoint** (as sub-posets of the Boolean lattice) exactly when there is no set
`S` lying in both, and one checks that

  `[T₁,B₁] ∩ [T₂,B₂] ≠ ∅  ↔  (T₁ ⊆ B₂ ∧ T₂ ⊆ B₁)`,

where `Bᵢ = Tᵢ ∪ Cᵢ` (the witness being `S = T₁ ∪ T₂`).  A collection of pairwise
disjoint intervals, one for **every** `l`-set `T`, is an interval packing of the
maximum possible size `C(n, l)` (one interval per level-`l` element).

Engel's theorem: such a maximum packing exists whenever `n ≥ (l+1)·r + l`.

This file develops the theory around the correct (disjointness) formulation and
proves several genuine results:

* `IsMaxIntervalPacking` — the correct notion (pairwise interval **disjointness**).
* `engel_r_zero` — the `r = 0` case for all `n, l`: the singleton intervals `{T}`
  form a maximum packing.
* `cycC` and `engel_l_one` — the `l = 1` case: an explicit **cyclic** construction
  `C_{t} = {t+1, …, t+r} (mod n)` gives a maximum packing whenever `n ≥ 2r + 1`,
  which is exactly the Engel threshold `(l+1)r + l` at `l = 1`.
* `no_maxpacking_two_one_one` — a **disproof** below the threshold: for
  `n = 2, l = 1, r = 1` (so `n = 2 < 3 = (l+1)r+l`) *no* maximum packing exists.
* `IsNaivePacking` and `naive_packing_impossible` — a contrarian observation: the
  *literal* reading of the informal statement (asking for `T₁ ⊄ B₂` **and**
  `T₂ ⊄ B₁` for **all** distinct pairs) is unsatisfiable as soon as `l, r ≥ 1`.
  This is why the disjointness formulation `¬(T₁ ⊆ B₂ ∧ T₂ ⊆ B₁)` is the right one.
-/
import Mathlib

open Finset

namespace EngelIntervalPacking

/-- `T` is an `l`-element subset of the ground set `[n] = {0, …, n-1}`. -/
def IsLSet (n l : ℕ) (T : Finset ℕ) : Prop := T ⊆ Finset.range n ∧ T.card = l

/-- The interval `[T, T ∪ f T]`, for `T` an `l`-set, is a valid interval of "height"
`r`: its `C`-part `f T` is an `r`-set of the ground set, disjoint from `T`. -/
def IsValidAssignment (n l r : ℕ) (f : Finset ℕ → Finset ℕ) : Prop :=
  ∀ T, IsLSet n l T → f T ⊆ Finset.range n ∧ (f T).card = r ∧ Disjoint T (f T)

/-- A **maximum interval packing**: an assignment `f` (of an `r`-set `C_T = f T` to
every `l`-set `T`) whose intervals `[T, T ∪ f T]` are pairwise **disjoint**.  Two
intervals meet iff `T₁ ⊆ T₂ ∪ f T₂ ∧ T₂ ⊆ T₁ ∪ f T₁`, so disjointness is the
negation of that conjunction.  Because there is one interval for every `l`-set, the
packing has the maximum possible size `C(n, l)`. -/
def IsMaxIntervalPacking (n l r : ℕ) (f : Finset ℕ → Finset ℕ) : Prop :=
  IsValidAssignment n l r f ∧
    ∀ T₁, IsLSet n l T₁ → ∀ T₂, IsLSet n l T₂ → T₁ ≠ T₂ →
      ¬ (T₁ ⊆ T₂ ∪ f T₂ ∧ T₂ ⊆ T₁ ∪ f T₁)

/-! ## The `r = 0` case: singleton intervals -/

/-- With `r = 0` the empty assignment gives a maximum packing for every `n, l`:
the intervals are the singletons `{T}`, which are trivially pairwise disjoint. -/
theorem engel_r_zero (n l : ℕ) :
    IsMaxIntervalPacking n l 0 (fun _ => ∅) := by
  constructor
  · intro T hT; aesop
  · grind +qlia

/-! ## The `l = 1` case: an explicit cyclic construction -/

/-- The cyclic `C`-set anchored at `a`: the `r` elements `a+1, a+2, …, a+r` taken
modulo `n`.  For `l = 1` and a bottom `T = {a}` we take `C_T = cycC n r a`. -/
def cycC (n r a : ℕ) : Finset ℕ := (Finset.range r).image (fun j => (a + 1 + j) % n)

/-- Membership in `cycC`. -/
theorem mem_cycC {n r a x : ℕ} :
    x ∈ cycC n r a ↔ ∃ j, j < r ∧ (a + 1 + j) % n = x := by
  unfold cycC; aesop

/-- If `n > r`, the map `j ↦ (a+1+j) % n` is injective on `{0, …, r-1}`, so `cycC`
has exactly `r` elements. -/
theorem cycC_card {n r a : ℕ} (h : r < n) : (cycC n r a).card = r := by
  have h_inj : ∀ i j : ℕ, i < r → j < r → (a + 1 + i) % n = (a + 1 + j) % n → i = j := by
    intros i j hi hj h_eq
    exact Nat.mod_eq_of_lt ( by linarith : i < n ) ▸ Nat.mod_eq_of_lt ( by linarith : j < n ) ▸ by simpa [ ← ZMod.natCast_eq_natCast_iff' ] using h_eq
  rw [ cycC, Finset.card_image_of_injOn fun i hi j hj hij => h_inj i j ( Finset.mem_range.mp hi ) ( Finset.mem_range.mp hj ) hij, Finset.card_range ]

/-- Every element of `cycC n r a` lies in the ground set `[n]` (needs `n > 0`). -/
theorem cycC_subset {n r a : ℕ} (hn : 0 < n) : cycC n r a ⊆ Finset.range n := by
  exact Finset.image_subset_iff.mpr fun x hx => Finset.mem_range.mpr <| Nat.mod_lt _ hn

/-- If `r < n` then the anchor `a`'s class is not hit, so `{a}` is disjoint from
`cycC n r a`. -/
theorem cycC_disjoint {n r a : ℕ} (h : r < n) : a ∉ cycC n r a := by
  simp +decide [ cycC ]
  intro x hx H; have := Nat.mod_add_div ( a + 1 + x ) n; simp_all +decide
  nlinarith [ show ( a + 1 + x ) / n = 0 by nlinarith ]

/-- The key "no digon" lemma.  If `n ≥ 2r + 1`, then we cannot simultaneously have
`a` in the cyclic set anchored at `b` and `b` in the cyclic set anchored at `a`
(regardless of whether `a = b`): adding the two cyclic offsets would force
`n ∣ (2 + j + k)` with `0 < 2 + j + k ≤ 2r < n`. -/
theorem cycC_no_digon {n r a b : ℕ} (hn : 2 * r + 1 ≤ n)
    (h1 : a ∈ cycC n r b) (h2 : b ∈ cycC n r a) : False := by
  obtain ⟨ j, hj, hj' ⟩ := mem_cycC.mp h1
  obtain ⟨ k, hk, hk' ⟩ := mem_cycC.mp h2
  -- By adding the two congruences, we get `2 + j + k ≡ 0 [MOD n]`.
  have h_sum : (2 + j + k : ℕ) ≡ 0 [MOD n] := by
    simp_all +decide [ ← ZMod.natCast_eq_natCast_iff ]
    grind +extAll
  rw [ Nat.modEq_zero_iff_dvd ] at h_sum; linarith [ Nat.le_of_dvd ( by linarith ) h_sum ]

/-
**Engel's theorem, `l = 1`.**  For `n ≥ 2r + 1`, assigning to each singleton
`T = {a}` the cyclic `r`-set `C_T = {a+1, …, a+r} (mod n)` yields a maximum interval
packing of the levels `1, …, 1+r`.  The threshold `2r + 1` is exactly `(l+1)r + l`
at `l = 1`.
-/
theorem engel_l_one (n r : ℕ) (hn : 2 * r + 1 ≤ n) :
    IsMaxIntervalPacking n 1 r (fun T => cycC n r (T.sum id)) := by
  constructor;
  · intro T hT; simp_all +decide [ IsLSet ] ;
    obtain ⟨ x, hx ⟩ := Finset.card_eq_one.mp hT.2; simp_all +decide [ Finset.subset_iff ] ;
    exact ⟨ fun y hy => Finset.mem_range.mp ( cycC_subset ( by linarith ) hy ), cycC_card ( by linarith ), cycC_disjoint ( by linarith ) ⟩;
  · intro T₁ hT₁ T₂ hT₂ hne h; rcases Finset.card_eq_one.mp hT₁.2 with ⟨ a, rfl ⟩ ; rcases Finset.card_eq_one.mp hT₂.2 with ⟨ b, rfl ⟩ ; simp_all +decide [ Finset.subset_iff ] ;
    exact cycC_no_digon ( by linarith ) h.1 ( h.2.resolve_left ( Ne.symm hne ) )

/-! ## A disproof below the threshold -/

/-- **Disproof.**  For `n = 2, l = 1, r = 1` — where `n = 2 < 3 = (l+1)r + l` — there
is *no* maximum interval packing.  The two singletons `{0}` and `{1}` force
`f {0} = {1}` and `f {1} = {0}`, and then the intervals `[{0},{0,1}]` and
`[{1},{0,1}]` share the top `{0,1}`. -/
theorem no_maxpacking_two_one_one :
    ¬ ∃ f, IsMaxIntervalPacking 2 1 1 f := by
  intro ⟨ f, hf₁, hf₂ ⟩
  have h_lsets : IsLSet 2 1 {0} ∧ IsLSet 2 1 {1} := by
    exact ⟨ ⟨ by decide, by decide ⟩, ⟨ by decide, by decide ⟩ ⟩
  have := hf₁ { 0 } h_lsets.1; have := hf₁ { 1 } h_lsets.2
  simp_all +decide [ Finset.card_eq_one ]
  grind +qlia

/-! ## Contrarian analysis: the naive literal reading is impossible -/

/-- The **naive** (literal) reading of the informal statement: for every ordered pair
of distinct `l`-sets one asks `T₁ ⊄ T₂ ∪ f T₂` *and* `T₂ ⊄ T₁ ∪ f T₁`.  (Compare the
correct `IsMaxIntervalPacking`, which negates the *conjunction*.) -/
def IsNaivePacking (n l r : ℕ) (f : Finset ℕ → Finset ℕ) : Prop :=
  IsValidAssignment n l r f ∧
    ∀ T₁, IsLSet n l T₁ → ∀ T₂, IsLSet n l T₂ → T₁ ≠ T₂ →
      ¬ (T₁ ⊆ T₂ ∪ f T₂) ∧ ¬ (T₂ ⊆ T₁ ∪ f T₁)

/-- **Contrarian result.**  Whenever `1 ≤ l ≤ n` and `1 ≤ r`, the naive literal
reading is unsatisfiable: any top `B = T ∪ f T` has size `l + r > l`, so it contains
some *other* `l`-set `T'` (`T' = T \ {t} ∪ {c}`), and `T' ⊆ B` contradicts the naive
demand.  This shows the disjointness formulation is the mathematically correct one. -/
theorem naive_packing_impossible (n l r : ℕ) (hl : 1 ≤ l) (hln : l ≤ n) (hr : 1 ≤ r) :
    ¬ ∃ f, IsNaivePacking n l r f := by
  intro ⟨ f, hf_valid, hf_cond ⟩
  obtain ⟨T₁, hT₁⟩ : ∃ T₁ : Finset ℕ, IsLSet n l T₁ ∧ ∃ t ∈ T₁, ∃ c ∈ f T₁, c ∉ T₁ := by
    obtain ⟨T₁, hT₁⟩ : ∃ T₁ : Finset ℕ, IsLSet n l T₁ := by
      exact ⟨ Finset.range l, Finset.range_mono hln, by simp ⟩
    obtain ⟨c, hc⟩ : ∃ c ∈ f T₁, c ∉ T₁ := by
      exact Exists.elim ( Finset.card_pos.mp ( by linarith [ hf_valid T₁ hT₁ ] ) ) fun x hx => ⟨ x, hx, fun hx' => Finset.disjoint_left.mp ( hf_valid T₁ hT₁ |>.2.2 ) hx' hx ⟩
    exact ⟨ T₁, hT₁, Classical.choose ( Finset.card_pos.mp ( by linarith [ hT₁.2 ] ) ), Classical.choose_spec ( Finset.card_pos.mp ( by linarith [ hT₁.2 ] ) ), c, hc ⟩
  obtain ⟨ t, ht₁, c, hc₁, hc₂ ⟩ := hT₁.2
  specialize hf_cond T₁ hT₁.1 ( Insert.insert c ( T₁.erase t ) )
  simp_all +decide [ Finset.subset_iff ]
  grind +locals

end EngelIntervalPacking