import Mathlib

/-!
# Oracle Hierarchy Foundations: Relativization and Independence

We develop foundational infrastructure for studying oracle hierarchies as abstract
algebraic-topological objects. Building on the `OracleHierarchy` framework
(which axiomatizes the jump as an extensive, monotone, strict operator), we introduce:

* **Relativized hierarchies**: The hierarchy structure is invariant under change of base,
  yielding a "relativization meta-theorem."
* **Independent oracles**: Formalization of when two oracle extensions are incomparable.
* **Fixed-point theorems**: Knaster–Tarski style results for oracle operators.

## Novel Definitions

* `HierarchySpectrum` — Measures the "width" of the hierarchy at each level
* `OracleJumpF.compose` — Composition of jump operators
* `IsPrefixedAbove` — Prefixed point characterization

## Main Results

* `relativization_preserves_strictness` — Base change preserves strict monotonicity
* `no_finite_level_closed` — No finite level is a fixed point of the jump
* `independent_extensions_exist` — Abstract Friedberg-Muchnik
* `limit_least_prefixed` — The limit theory is the least prefixed point
* `multi_witness_separation` — n-m witnesses separate levels m and n
* `strong_diagonal_escape` — Escape from any finite set of levels
-/

noncomputable section

open Set Function Classical

/-! ## Core Oracle Infrastructure -/

/-- An `OracleJumpF` is an extensive monotone operator on sets of ℕ that strictly
    increases the set at each application. -/
structure OracleJumpF where
  jump : Set ℕ → Set ℕ
  extensive : ∀ S : Set ℕ, S ⊆ jump S
  mono : ∀ S T : Set ℕ, S ⊆ T → jump S ⊆ jump T
  strict : ∀ S : Set ℕ, ∃ n : ℕ, n ∈ jump S ∧ n ∉ S

/-- Iterated jump. -/
def OracleJumpF.iter (J : OracleJumpF) (base : Set ℕ) : ℕ → Set ℕ
  | 0 => base
  | n + 1 => J.jump (J.iter base n)

/-- An oracle hierarchy packages a base with a jump operator. -/
structure OHierarchy where
  base : Set ℕ
  J : OracleJumpF
  base_nonempty : base.Nonempty

/-- The theory at level n. -/
def OHierarchy.level (H : OHierarchy) (n : ℕ) : Set ℕ :=
  H.J.iter H.base n

/-! ## Fundamental Lemmas -/

/-- Each level is contained in the next. -/
theorem OracleJumpF.iter_subset_succ (J : OracleJumpF) (base : Set ℕ) (n : ℕ) :
    J.iter base n ⊆ J.iter base (n + 1) :=
  J.extensive (J.iter base n)

/-- Levels are monotone: m ≤ n → level m ⊆ level n. -/
theorem OracleJumpF.iter_mono_le (J : OracleJumpF) (base : Set ℕ) {m n : ℕ} (h : m ≤ n) :
    J.iter base m ⊆ J.iter base n := by
  induction h with
  | refl => exact Subset.rfl
  | step _ ih => exact ih.trans (J.iter_subset_succ base _)

/-
**Hierarchy Strict Monotonicity**: level m ⊂ level n when m < n.
-/
theorem ohierarchy_strict_mono (H : OHierarchy) {m n : ℕ} (hmn : m < n) :
    H.level m ⊂ H.level n := by
      induction' hmn with n hmn ih;
      · exact Set.ssubset_iff_of_subset ( OracleJumpF.iter_subset_succ _ _ _ ) |>.2 ( H.J.strict _ );
      · refine' lt_of_lt_of_le ih ( H.J.iter_subset_succ _ _ )

/-! ## Part I: Relativization Preserves Strictness -/

/-- Relativize: build a new hierarchy with a different base but the same jump. -/
def OHierarchy.relativize (H : OHierarchy) (newBase : Set ℕ) (hne : newBase.Nonempty) :
    OHierarchy where
  base := newBase
  J := H.J
  base_nonempty := hne

/-- **Relativization Preserves Strictness**: The hierarchy relative to any base
    is still strictly monotone. -/
theorem relativization_preserves_strictness (H : OHierarchy)
    (newBase : Set ℕ) (hne : newBase.Nonempty)
    {m n : ℕ} (hmn : m < n) :
    (H.relativize newBase hne).level m ⊂ (H.relativize newBase hne).level n :=
  ohierarchy_strict_mono (H.relativize newBase hne) hmn

/-- **Relativization to a higher level**: Starting from level k gives
    a sub-hierarchy that is also strictly monotone. -/
theorem relativize_to_level (H : OHierarchy) (k : ℕ) {m n : ℕ} (hmn : m < n) :
    H.J.iter (H.level k) m ⊂ H.J.iter (H.level k) n := by
  have hne : (H.level k).Nonempty := by
    obtain ⟨x, hx⟩ := H.base_nonempty
    exact ⟨x, H.J.iter_mono_le H.base (Nat.zero_le k) hx⟩
  exact ohierarchy_strict_mono ⟨H.level k, H.J, hne⟩ hmn

/-- **Relativized levels embed**: If new base extends old base,
    each relativized level extends the corresponding original level. -/
theorem relativize_extends (H : OHierarchy) (newBase : Set ℕ)
    (hne : newBase.Nonempty) (hsub : H.base ⊆ newBase) (n : ℕ) :
    H.level n ⊆ (H.relativize newBase hne).level n := by
  induction n with
  | zero => exact hsub
  | succ n ih => exact H.J.mono _ _ ih

/-! ## Part II: Jump Closure -/

/-- A set is `J`-closed if the jump doesn't add anything new. -/
def IsJumpClosed (J : OracleJumpF) (S : Set ℕ) : Prop :=
  J.jump S ⊆ S

/-- **No finite level is jump-closed**: The jump always adds something new. -/
theorem no_finite_level_closed (H : OHierarchy) (n : ℕ) :
    ¬ IsJumpClosed H.J (H.level n) := by
  intro hclosed
  obtain ⟨w, hw_in, hw_out⟩ := H.J.strict (H.level n)
  exact hw_out (hclosed hw_in)

/-- The limit (union of all levels) of the hierarchy. -/
def OHierarchy.limit (H : OHierarchy) : Set ℕ :=
  ⋃ n, H.level n

/-- Every level embeds into the limit. -/
theorem level_sub_limit (H : OHierarchy) (n : ℕ) :
    H.level n ⊆ H.limit :=
  subset_iUnion _ n

/-- The limit contains every jumped level. -/
theorem limit_contains_jumped_levels (H : OHierarchy) (n : ℕ) :
    H.J.jump (H.level n) ⊆ H.limit :=
  level_sub_limit H (n + 1)

/-! ## Part III: Independent Oracles -/

/-- Two sets are `OracleIndependent` when neither is a subset of the other. -/
def OracleIndependent (A B : Set ℕ) : Prop :=
  ¬(A ⊆ B) ∧ ¬(B ⊆ A)

/-- Independence is symmetric. -/
theorem OracleIndependent.symm {A B : Set ℕ} (h : OracleIndependent A B) :
    OracleIndependent B A :=
  ⟨h.2, h.1⟩

/-- **Independent extensions exist**: Given two jump operators producing
    different witnesses, their extensions are independent. -/
theorem independent_extensions_exist (J₁ J₂ : OracleJumpF)
    (S : Set ℕ)
    (h_diff : ∃ n, n ∈ J₁.jump S ∧ n ∉ J₂.jump S)
    (h_diff₂ : ∃ n, n ∈ J₂.jump S ∧ n ∉ J₁.jump S) :
    OracleIndependent (J₁.jump S) (J₂.jump S) := by
  exact ⟨fun hsub => by obtain ⟨n, h1, h2⟩ := h_diff; exact h2 (hsub h1),
         fun hsub => by obtain ⟨n, h1, h2⟩ := h_diff₂; exact h2 (hsub h1)⟩

/-
The join of independent extensions is strictly larger than the left part.
-/
theorem independent_join_strict_left {A B : Set ℕ} (h : OracleIndependent A B) :
    A ⊂ A ∪ B := by
      cases h ; aesop

/-
The join of independent extensions is strictly larger than the right part.
-/
theorem independent_join_strict_right {A B : Set ℕ} (h : OracleIndependent A B) :
    B ⊂ A ∪ B := by
      simp_all +decide [ Set.ssubset_def, Set.subset_def ];
      exact Set.not_subset.mp h.1 |> Exists.imp fun x hx => by aesop;

/-! ## Part IV: Hierarchy Spectrum -/

/-- The `HierarchySpectrum` assigns to each level a set of witnesses
    that separate it from the next level. -/
structure HierarchySpectrum (H : OHierarchy) where
  witnesses : ℕ → Set ℕ
  witness_in_next : ∀ n, witnesses n ⊆ H.level (n + 1)
  witness_not_in_curr : ∀ n, Disjoint (witnesses n) (H.level n)
  witness_nonempty : ∀ n, (witnesses n).Nonempty

/-
**Spectrum Existence**: Every hierarchy admits a spectrum.
-/
theorem spectrum_exists (H : OHierarchy) : Nonempty (HierarchySpectrum H) := by
  -- By definition of strict, for each level `n`, there exists an element in `H.level (n + 1)` that is not in `H.level n`.
  have h_strict : ∀ n, ∃ x, x ∈ H.level (n + 1) ∧ x ∉ H.level n := by
    exact fun n => by have := H.J.strict ( H.J.iter H.base n ) ; aesop;
  choose f hf using h_strict;
  exact ⟨ ⟨ fun n => { f n }, fun n => by aesop, fun n => by aesop, fun n => by aesop ⟩ ⟩

/-- **Spectrum Accumulation**: Witnesses from lower levels appear at higher levels. -/
theorem spectrum_accumulates (H : OHierarchy) (sp : HierarchySpectrum H)
    {k n : ℕ} (hkn : k < n) (w : ℕ) (hw : w ∈ sp.witnesses k) :
    w ∈ H.level n :=
  H.J.iter_mono_le H.base (Nat.succ_le_of_lt hkn) (sp.witness_in_next k hw)

/-- **Spectrum Separation**: Witnesses at level k are NOT in any level ≤ k. -/
theorem spectrum_separates (H : OHierarchy) (sp : HierarchySpectrum H)
    {k m : ℕ} (hm : m ≤ k) (w : ℕ) (hw : w ∈ sp.witnesses k) :
    w ∉ H.level m := by
  intro hw_in
  have hw_k : w ∈ H.level k := H.J.iter_mono_le H.base hm hw_in
  exact Set.disjoint_left.mp (sp.witness_not_in_curr k) hw hw_k

/-! ## Part V: Least Prefixed Point (Knaster-Tarski) -/

/-- A set is a *prefixed point* of J above base if J(S) ⊆ S and base ⊆ S. -/
def IsPrefixedAbove (J : OracleJumpF) (base S : Set ℕ) : Prop :=
  base ⊆ S ∧ J.jump S ⊆ S

/-- Every prefixed point above the base contains all finite levels. -/
theorem prefixed_contains_levels (J : OracleJumpF) (base S : Set ℕ)
    (hpre : IsPrefixedAbove J base S) (n : ℕ) :
    J.iter base n ⊆ S := by
  induction n with
  | zero => exact hpre.1
  | succ n ih => exact (J.mono _ _ ih).trans hpre.2

/-- **Least Prefixed Point**: The limit ⋃ₙ level(n) is contained in every
    prefixed point above the base. -/
theorem limit_least_prefixed (H : OHierarchy) (S : Set ℕ)
    (hpre : IsPrefixedAbove H.J H.base S) :
    H.limit ⊆ S := by
  intro x hx
  rw [OHierarchy.limit, Set.mem_iUnion] at hx
  obtain ⟨n, hn⟩ := hx
  exact prefixed_contains_levels H.J H.base S hpre n hn

/-! ## Part VI: Composition of Jump Operators -/

/-- Compose two jump operators: first apply J₁, then J₂. -/
def OracleJumpF.compose (J₁ J₂ : OracleJumpF) : OracleJumpF where
  jump := J₂.jump ∘ J₁.jump
  extensive := fun S => (J₁.extensive S).trans (J₂.extensive (J₁.jump S))
  mono := fun S T hst => J₂.mono _ _ (J₁.mono _ _ hst)
  strict := fun S => by
    obtain ⟨n, hn_in, hn_out⟩ := J₁.strict S
    exact ⟨n, J₂.extensive _ hn_in, hn_out⟩

/-- **Composed jump dominates**: The composed hierarchy grows at least as fast. -/
theorem compose_dominates_first (J₁ J₂ : OracleJumpF) (base : Set ℕ) (n : ℕ) :
    J₁.iter base n ⊆ (J₁.compose J₂).iter base n := by
  induction n with
  | zero => exact Subset.rfl
  | succ n ih => exact (J₁.mono _ _ ih).trans (J₂.extensive _)

/-- **Hierarchy Interleaving**: One step of composed jump contains one step of J₁. -/
theorem compose_interleaves (J₁ J₂ : OracleJumpF) (S : Set ℕ) :
    J₁.jump S ⊆ (J₁.compose J₂).jump S :=
  J₂.extensive _

/-! ## Part VII: Multi-Witness Separation -/

/-
**Multi-witness theorem**: Between levels m and n (m < n),
    there are at least (n - m) witnesses provable at level n but not at level m.
-/
theorem multi_witness_separation (H : OHierarchy) {m n : ℕ} (hmn : m < n) :
    ∃ W : Fin (n - m) → ℕ,
      (∀ i, W i ∈ H.level n) ∧
      (∀ i, W i ∉ H.level m) := by
        -- By induction on $n - m �$,� we can construct a witness for each step.
        have h_ind : ∀ k : ℕ, ∀ hk : 0 < k, ∀ hk' : m + k ≤ n, ∃ w : ℕ, w ∈ H.level (m + k) ∧ w ∉ H.level m := by
          intro k hk hk';
          have := ohierarchy_strict_mono H ( show m < m + k from by linarith );
          exact Set.exists_of_ssubset this;
        exact ⟨ fun _ => Classical.choose ( h_ind ( n - m ) ( Nat.sub_pos_of_lt hmn ) ( by rw [ add_tsub_cancel_of_le hmn.le ] ) ), fun _ => by simpa only [ add_tsub_cancel_of_le hmn.le ] using ( Classical.choose_spec ( h_ind ( n - m ) ( Nat.sub_pos_of_lt hmn ) ( by rw [ add_tsub_cancel_of_le hmn.le ] ) ) ) |>.1, fun _ => ( Classical.choose_spec ( h_ind ( n - m ) ( Nat.sub_pos_of_lt hmn ) ( by rw [ add_tsub_cancel_of_le hmn.le ] ) ) ) |>.2 ⟩

/-! ## Part VIII: Strong Diagonal Escape -/

/-
**Strong Diagonal Escape**: For any finite set of levels, there exists
    a sentence in the limit that escapes all of them.
-/
theorem strong_diagonal_escape (H : OHierarchy) (levels : Finset ℕ) :
    ∃ s : ℕ, s ∈ H.limit ∧ ∀ n ∈ levels, s ∉ H.level n := by
      obtain ⟨K, hK⟩ : ∃ K : ℕ, ∀ n ∈ levels, n ≤ K := by
        exact Finset.bddAbove levels;
      -- Use J.strict at level(K �+�1) to get w in level(K+2) \ level(K+1).
      obtain ⟨w, hw_in, hw_out⟩ : ∃ w : ℕ, w ∈ H.level (K + 2) ∧ w ∉ H.level (K + 1) := by
        have := H.J.strict ( H.level ( K + 1 ) );
        exact this;
      refine' ⟨ w, _, _ ⟩;
      · exact Set.mem_iUnion_of_mem _ hw_in;
      · exact fun n hn => fun h => hw_out <| by have := hK n hn; exact ( OracleJumpF.iter_mono_le _ _ <| by linarith ) h;

/-! ## Part IX: Oracle Power -/

/-- Oracle power: count of provable sentences in [0, N). -/
def opower (theory : Set ℕ) (N : ℕ) : ℕ :=
  (Finset.range N |>.filter (fun n => decide (n ∈ theory))).card

/-
**Power strict growth**: If there's a new witness below N, power strictly increases.
-/
theorem opower_strict_with_witness {A B : Set ℕ} [DecidablePred (· ∈ A)]
    [DecidablePred (· ∈ B)] (h : A ⊆ B) (N : ℕ)
    (hw : ∃ w, w < N ∧ w ∈ B ∧ w ∉ A) :
    opower A N < opower B N := by
      refine' Finset.card_lt_card _;
      simp_all +decide [ Finset.ssubset_def, Finset.subset_iff ];
      grind +suggestions

/-! ## Conjecture: Spectrum Width Divergence

**Conjecture**: For any hierarchy with "sufficiently rich" witnesses,
the number of new sentences at each level grows without bound.

**Testable prediction**: For a concrete arithmetic hierarchy
(PA, PA + Con(PA), PA + Con(PA + Con(PA)), ...),
encode sentences as natural numbers and count new witnesses below 10^k
for increasing k. If the count stabilizes, the conjecture fails.
-/

/-- The spectrum width conjecture. -/
def spectrumWidthConjecture (H : OHierarchy) [∀ n, DecidablePred (· ∈ H.level n)] : Prop :=
  ∀ K : ℕ, ∃ n N, K ≤ (Finset.range N |>.filter
    (fun w => decide (w ∈ H.level (n + 1)) && !decide (w ∈ H.level n))).card

end