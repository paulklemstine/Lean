import Novelty.HeightSpectrumTransfer

/-!
# Which preorders of consistency strength are realizable?

`Novelty.HeightSpectrumTransfer` computed the exact transfer spectrum of the
tag-sensitive finite-height theories `capC c N`:

  `Provable (capC c N) (Con i → Con j) ↔ min N (c i) ≤ c j`,

and observed that the resulting relation on tags is always a total preorder
(`capC_transfer_total_preorder`).  The accompanying conjecture list asked for the
converse: *which* relations arise this way.  This file settles that question with an
exact characterization.

Write `TransferRel c N i j` for `Provable (capC c N) (Con i → Con j)`, and call a
sequence `f 0, f 1, …, f k` a **strict chain of length `k`** for a relation `R` when
each step goes strictly up: `R (f a) (f (a+1))` but not conversely.  The main theorem
`transfer_preorder_characterization` says:

  `R` is a transfer relation for the bound `N`
    ↔ `R` is transitive, total, and has no strict chain of length `N + 1`.

Equivalently (`totalPreorder_iff_rank_representation`) `R` is the pullback of the
order on `{0, 1, …, N}` along a height function: `R i j ↔ h i ≤ h j` with `h i ≤ N`.
The height that works is the **rank** of a tag, the length of the longest strict chain
ending at it, and the realizing theory is literally `capC (rank R N) N`.

Two consequences are recorded: the quotient of a transfer relation has at most `N + 1`
classes in the strong sense that among any `N + 2` tags two are transfer-equivalent
(`transfer_pigeonhole`), and every finite bound is attained — the linear order on
`{0, …, N}` itself is realized (`transfer_linear_order_realized`), so the bound `N + 1`
on the number of consistency strengths is sharp.

Section §6 explains *why* the truncated height is the right invariant: it is the exact
depth of provable inconsistency of a tag, `Provable (capC c N) (□_i^k ⊥) ↔
1 ≤ k ∧ min N (c i) < k` (`capC_provable_boxPow_bot_iff`), and the transfer spectrum
is computed for all iterated boxed falsa (`capC_boxPow_transfer_iff`), of which
`capC_transfer_iff` is the case `k = l = 1`.

Section §7 records that the depth vector `i ↦ min N (c i)` is a complete invariant
(`capC_ne_of_min_ne`), but that inclusion of these theories is *not* the pointwise
order on depth vectors (`theory_inclusion_not_pointwise`).
-/

namespace PhysicsConsistency

open ProofSystemCollapse
open Form

/-! ## §1. The transfer relation -/

/-- The **provable-transfer relation** of the theory `capC c N`: tag `i` is at most as
strong as tag `j` when the theory proves `Con i → Con j`. -/
def TransferRel (c : ℕ → ℕ) (N : ℕ) (i j : ℕ) : Prop :=
  Provable (capC c N) (imp (Con i) (Con j))

/-- The transfer relation is the pullback of `≤` along the truncated height. -/
theorem transferRel_iff (c : ℕ → ℕ) (N i j : ℕ) :
    TransferRel c N i j ↔ min N (c i) ≤ min N (c j) := by
  rw [TransferRel, capC_transfer_iff]
  omega

/-! ## §2. Strict chains -/

/-- `i` is **strictly below** `j` for `R`: `R i j` holds but `R j i` does not. -/
def StrictBelow (R : ℕ → ℕ → Prop) (i j : ℕ) : Prop := R i j ∧ ¬ R j i

/-- `f` is a strict `R`-chain of length `k`: each of the `k` steps goes strictly up. -/
def StrictChain (R : ℕ → ℕ → Prop) (k : ℕ) (f : ℕ → ℕ) : Prop :=
  ∀ a < k, StrictBelow R (f a) (f (a + 1))

/-- There is a strict `R`-chain of length `k` whose top element is `i`. -/
def HasChainTo (R : ℕ → ℕ → Prop) (k i : ℕ) : Prop :=
  ∃ f : ℕ → ℕ, f k = i ∧ StrictChain R k f

/-- The empty chain: every tag is the top of a chain of length `0`. -/
theorem hasChainTo_zero (R : ℕ → ℕ → Prop) (i : ℕ) : HasChainTo R 0 i :=
  ⟨fun _ => i, rfl, fun a ha => absurd ha (by omega)⟩

/-- Chains can be truncated from below. -/
theorem hasChainTo_mono {R : ℕ → ℕ → Prop} {k k' i : ℕ} (hk : k' ≤ k)
    (h : HasChainTo R k i) : HasChainTo R k' i := by
  obtain ⟨f, hf, hchain⟩ := h
  refine ⟨fun a => f (a + (k - k')), by simpa [Nat.add_sub_cancel' hk] using hf, ?_⟩
  intro a ha
  have : a + (k - k') < k := by omega
  simpa [Nat.add_right_comm] using hchain _ this

/-- A chain to `i` becomes a chain to any `j` above `i`. -/
theorem hasChainTo_of_rel {R : ℕ → ℕ → Prop}
    (htrans : ∀ x y z, R x y → R y z → R x z) {k i j : ℕ}
    (h : HasChainTo R k i) (hij : R i j) : HasChainTo R k j := by
  obtain ⟨f, hf, hchain⟩ := h
  refine ⟨fun a => if a = k then j else f a, by simp, ?_⟩
  intro a ha
  have hak : a ≠ k := by omega
  by_cases hsucc : a + 1 = k
  · have hstep := hchain a ha
    rw [hsucc, hf] at hstep
    show StrictBelow R (if a = k then j else f a) (if a + 1 = k then j else f (a + 1))
    rw [if_neg hak, if_pos hsucc]
    exact ⟨htrans _ _ _ hstep.1 hij, fun hji => hstep.2 (htrans _ _ _ hij hji)⟩
  · simpa [hak, hsucc] using hchain a ha

/-- A chain to `j` extends by one step to any `i` strictly above `j`. -/
theorem hasChainTo_succ {R : ℕ → ℕ → Prop} {k i j : ℕ}
    (h : HasChainTo R k j) (hs : StrictBelow R j i) : HasChainTo R (k + 1) i := by
  obtain ⟨f, hf, hchain⟩ := h
  refine ⟨fun a => if a ≤ k then f a else i, by simp, ?_⟩
  intro a ha
  by_cases hak : a < k
  · have h1 : a ≤ k := by omega
    have h2 : a + 1 ≤ k := by omega
    simpa [h1, h2] using hchain a hak
  · have hak' : a = k := by omega
    subst hak'
    have h2 : ¬ (a + 1 ≤ a) := by omega
    simpa [h2, hf] using hs

/-! ## §3. Rank -/

/-- The **rank** of a tag: the length of the longest strict `R`-chain ending at it,
capped at `N`. -/
noncomputable def rank (R : ℕ → ℕ → Prop) (N i : ℕ) : ℕ :=
  @Nat.findGreatest (fun k => HasChainTo R k i) (Classical.decPred _) N

/-- Ranks are bounded by `N`. -/
theorem rank_le (R : ℕ → ℕ → Prop) (N i : ℕ) : rank R N i ≤ N :=
  @Nat.findGreatest_le (fun k => HasChainTo R k i) (Classical.decPred _) N

/-- The rank is attained by a chain. -/
theorem hasChainTo_rank (R : ℕ → ℕ → Prop) (N i : ℕ) :
    HasChainTo R (rank R N i) i := by
  letI : DecidablePred (fun k => HasChainTo R k i) := Classical.decPred _
  exact Nat.findGreatest_spec (P := fun k => HasChainTo R k i) (m := 0)
    (Nat.zero_le N) (hasChainTo_zero R i)

/-- The rank is maximal among chain lengths bounded by `N`. -/
theorem le_rank {R : ℕ → ℕ → Prop} {N i k : ℕ} (hk : k ≤ N)
    (h : HasChainTo R k i) : k ≤ rank R N i := by
  letI : DecidablePred (fun k => HasChainTo R k i) := Classical.decPred _
  exact Nat.le_findGreatest hk h

/-- **Rank representation.**  A transitive, total relation without strict chains of
length `N + 1` is the pullback of `≤` along its rank function, which is bounded by
`N`. -/
theorem rank_represents {R : ℕ → ℕ → Prop} {N : ℕ}
    (htrans : ∀ x y z, R x y → R y z → R x z)
    (htotal : ∀ x y, R x y ∨ R y x)
    (hchain : ∀ i, ¬ HasChainTo R (N + 1) i) (i j : ℕ) :
    R i j ↔ rank R N i ≤ rank R N j := by
  constructor
  · intro hij
    exact le_rank (rank_le R N i) (hasChainTo_of_rel htrans (hasChainTo_rank R N i) hij)
  · intro hle
    by_contra hij
    have hji : R j i := (htotal i j).resolve_left hij
    have hs : StrictBelow R j i := ⟨hji, hij⟩
    have hext : HasChainTo R (rank R N j + 1) i :=
      hasChainTo_succ (hasChainTo_rank R N j) hs
    have hlt : rank R N j + 1 ≤ N := by
      by_contra hgt
      have : rank R N j + 1 = N + 1 := by have := rank_le R N j; omega
      exact hchain i (this ▸ hext)
    have := le_rank hlt hext
    omega

/-! ## §4. The characterization -/

/-- Along a strictly increasing numerical invariant, a chain of length `k` forces the
invariant of its top element to be at least `k`. -/
theorem chain_le_height {R : ℕ → ℕ → Prop} {h : ℕ → ℕ}
    (hmono : ∀ x y, StrictBelow R x y → h x < h y) {k : ℕ} {f : ℕ → ℕ}
    (hf : StrictChain R k f) : ∀ a ≤ k, a ≤ h (f a) := by
  intro a
  induction a with
  | zero => intro _; omega
  | succ a ih =>
      intro hak
      have h1 := ih (by omega)
      have := hmono _ _ (hf a (by omega))
      omega

/-- **Transfer relations are total preorders of rank at most `N + 1`.** -/
theorem transferRel_properties (c : ℕ → ℕ) (N : ℕ) :
    (∀ x y z, TransferRel c N x y → TransferRel c N y z → TransferRel c N x z) ∧
      (∀ x y, TransferRel c N x y ∨ TransferRel c N y x) ∧
      (∀ i, ¬ HasChainTo (TransferRel c N) (N + 1) i) := by
  refine ⟨fun x y z hxy hyz => ?_, fun x y => ?_, ?_⟩
  · rw [transferRel_iff] at hxy hyz ⊢; omega
  · rw [transferRel_iff, transferRel_iff]; omega
  · rintro i ⟨f, hf, hchain⟩
    have hmono : ∀ x y, StrictBelow (TransferRel c N) x y →
        min N (c x) < min N (c y) := by
      rintro x y ⟨h1, h2⟩
      rw [transferRel_iff] at h1
      rw [transferRel_iff] at h2
      omega
    have := chain_le_height hmono hchain (N + 1) le_rfl
    have hb : min N (c (f (N + 1))) ≤ N := by omega
    omega

/-- **Realization.**  Every transitive, total relation without strict chains of length
`N + 1` is the provable-transfer relation of an explicit finite-height theory, namely
`capC (rank R N) N`. -/
theorem transferRel_rank_eq {R : ℕ → ℕ → Prop} {N : ℕ}
    (htrans : ∀ x y z, R x y → R y z → R x z)
    (htotal : ∀ x y, R x y ∨ R y x)
    (hchain : ∀ i, ¬ HasChainTo R (N + 1) i) (i j : ℕ) :
    TransferRel (rank R N) N i j ↔ R i j := by
  rw [transferRel_iff, rank_represents htrans htotal hchain i j]
  have hi := rank_le R N i
  have hj := rank_le R N j
  omega

/-- **The characterization of realizable consistency-strength preorders.**  A relation
on tags is the provable-transfer relation of some tag-sensitive theory of height bound
`N` **iff** it is transitive, total, and admits no strict chain of length `N + 1`. -/
theorem transfer_preorder_characterization (N : ℕ) (R : ℕ → ℕ → Prop) :
    (∃ c : ℕ → ℕ, ∀ i j, TransferRel c N i j ↔ R i j) ↔
      ((∀ x y z, R x y → R y z → R x z) ∧ (∀ x y, R x y ∨ R y x) ∧
        (∀ i, ¬ HasChainTo R (N + 1) i)) := by
  constructor
  · rintro ⟨c, hc⟩
    obtain ⟨htrans, htotal, hchain⟩ := transferRel_properties c N
    have hstrict : ∀ x y, StrictBelow R x y ↔ StrictBelow (TransferRel c N) x y := by
      intro x y
      simp only [StrictBelow, hc]
    refine ⟨fun x y z hxy hyz => (hc x z).1 (htrans x y z ((hc x y).2 hxy) ((hc y z).2 hyz)),
      fun x y => ((htotal x y).imp (hc x y).1 (hc y x).1), ?_⟩
    rintro i ⟨f, hf, hch⟩
    exact hchain i ⟨f, hf, fun a ha => (hstrict _ _).1 (hch a ha)⟩
  · rintro ⟨htrans, htotal, hchain⟩
    exact ⟨rank R N, transferRel_rank_eq htrans htotal hchain⟩

/-- **Equivalent formulation: bounded numerical representation.**  The realizable
relations are exactly the pullbacks of the order on `{0, 1, …, N}`. -/
theorem totalPreorder_iff_rank_representation (N : ℕ) (R : ℕ → ℕ → Prop) :
    ((∀ x y z, R x y → R y z → R x z) ∧ (∀ x y, R x y ∨ R y x) ∧
        (∀ i, ¬ HasChainTo R (N + 1) i)) ↔
      ∃ h : ℕ → ℕ, (∀ i, h i ≤ N) ∧ ∀ i j, R i j ↔ h i ≤ h j := by
  constructor
  · rintro ⟨htrans, htotal, hchain⟩
    exact ⟨rank R N, rank_le R N, rank_represents htrans htotal hchain⟩
  · rintro ⟨h, hb, hR⟩
    refine ⟨fun x y z hxy hyz => ?_, fun x y => ?_, ?_⟩
    · rw [hR] at hxy hyz ⊢; omega
    · rw [hR, hR]; omega
    · rintro i ⟨f, hf, hch⟩
      have hmono : ∀ x y, StrictBelow R x y → h x < h y := by
        rintro x y ⟨h1, h2⟩
        rw [hR] at h1
        rw [hR] at h2
        omega
      have := chain_le_height hmono hch (N + 1) le_rfl
      have := hb (f (N + 1))
      omega

/-! ## §5. Consequences -/

/-- **At most `N + 1` consistency strengths.**  Among any `N + 2` tags, two distinct
indices are transfer-equivalent: the theory `capC c N` cannot separate more than
`N + 1` strengths. -/
theorem transfer_pigeonhole (c : ℕ → ℕ) (N : ℕ) (t : Fin (N + 2) → ℕ) :
    ∃ a b : Fin (N + 2), a ≠ b ∧
      TransferRel c N (t a) (t b) ∧ TransferRel c N (t b) (t a) := by
  have hcard : Fintype.card (Fin (N + 1)) < Fintype.card (Fin (N + 2)) := by
    simp
  obtain ⟨a, b, hab, heq⟩ :=
    Fintype.exists_ne_map_eq_of_card_lt
      (fun a : Fin (N + 2) => (⟨min N (c (t a)), by omega⟩ : Fin (N + 1))) hcard
  have heq' : min N (c (t a)) = min N (c (t b)) := congrArg Fin.val heq
  exact ⟨a, b, hab, (transferRel_iff c N _ _).2 (by omega),
    (transferRel_iff c N _ _).2 (by omega)⟩

/-- **The bound is attained.**  The linear order on `{0, 1, …, N}`, pulled back along
any tagging `t i = min N i`, is realized by an explicit theory: `capC id N` separates
exactly `N + 1` consistency strengths. -/
theorem transfer_linear_order_realized (N : ℕ) :
    (∀ i j, TransferRel (fun k => k) N i j ↔ min N i ≤ min N j) ∧
      (∀ a ≤ N, ∀ b ≤ N, TransferRel (fun k => k) N a b ↔ a ≤ b) ∧
      (∀ a b, a < b → b ≤ N → ¬ TransferRel (fun k => k) N b a) := by
  refine ⟨fun i j => by rw [transferRel_iff], fun a ha b hb => ?_, fun a b hab hb => ?_⟩
  · rw [transferRel_iff]; omega
  · rw [transferRel_iff]; omega

/-! ## §6. Iterated consistency: the truncated height is a depth

The truncated height `min N (c i)` is not only the invariant governing transfer of the
consistency sentences; it is literally the **depth of provable inconsistency** of the
tag: `capC c N` proves `□_i^k ⊥` exactly when `k` exceeds `min N (c i)`.  This
generalizes `capC_provable_neg_Con_iff` (the case `k = 1`) and yields the transfer
spectrum for all iterated boxed falsa, of which `capC_transfer_iff` is the case
`k = l = 1`. -/

/-- **Iterated boxed falsum in the tag-sensitive semantics.**  For `k ≥ 1`, `□_i^k ⊥`
holds at `m` iff `m < k` (the world is too shallow to see a `k`-step chain) or the
world lies above the tag's height. -/
theorem satC_boxPow_bot (c : ℕ → ℕ) (i : ℕ) :
    ∀ (k m : ℕ), satC c m (boxPow i k bot) = true ↔ (1 ≤ k ∧ (m < k ∨ c i < m)) := by
  intro k
  induction k with
  | zero => intro m; simp [boxPow]
  | succ k ih =>
      intro m
      rw [boxPow, satC_box]
      by_cases hle : m ≤ c i
      · constructor
        · intro h
          refine ⟨by omega, ?_⟩
          left
          by_contra hm
          have hk : k < m := by omega
          have := (ih k).1 (h hle k hk)
          omega
        · rintro ⟨-, hm⟩ - n hn
          rw [ih n]
          omega
      · constructor
        · intro _; exact ⟨by omega, by omega⟩
        · intro _ hle'; omega

/-- **The depth of provable inconsistency.**  `capC c N` proves `□_i^k ⊥` iff `k` is
positive and exceeds the truncated height of the tag.  So the truncated height is
exactly the largest `k` with `□_i^k ⊥` unprovable. -/
theorem capC_provable_boxPow_bot_iff (c : ℕ → ℕ) (N i k : ℕ) :
    Provable (capC c N) (boxPow i k bot) ↔ (1 ≤ k ∧ min N (c i) < k) := by
  rw [provable_capC]
  constructor
  · intro h
    have h0 := (satC_boxPow_bot c i k 0).1 (h 0 (Nat.zero_le N))
    have hm := (satC_boxPow_bot c i k (min N (c i))).1 (h (min N (c i)) (by omega))
    omega
  · rintro ⟨hk, hlt⟩ m hm
    rw [satC_boxPow_bot]
    omega

/-- **The full transfer spectrum for iterated consistency.**  `capC c N` proves
`□_i^k ⊥ → □_j^l ⊥` iff the antecedent is falsum (`k = 0`), or the consequent already
holds throughout (`min N (c j) < l`), or the depths are ordered (`k ≤ l`) and the
truncated height of `j` is below the height of `i`.  For `k = l = 1` this is the
contrapositive form of `capC_transfer_iff`. -/
theorem capC_boxPow_transfer_iff (c : ℕ → ℕ) (N i j k l : ℕ) :
    Provable (capC c N) (imp (boxPow i k bot) (boxPow j l bot)) ↔
      (k = 0 ∨ min N (c j) < l ∨ (k ≤ l ∧ min N (c j) ≤ c i)) := by
  rw [provable_capC]
  constructor
  · intro h
    by_contra hx
    push_neg at hx
    obtain ⟨hk, hl, hkl⟩ := hx
    rcases Nat.lt_or_ge l k with hlk | hlk
    · have hm := (satC_imp c l _ _).1 (h l (by omega))
      have h1 := (satC_boxPow_bot c i k l).2 ⟨by omega, Or.inl hlk⟩
      have := (satC_boxPow_bot c j l l).1 (hm h1)
      omega
    · have hci : c i < min N (c j) := by
        have := hkl hlk
        omega
      set m := min N (c j) with hmdef
      have hm := (satC_imp c m _ _).1 (h m (by omega))
      have h1 := (satC_boxPow_bot c i k m).2 ⟨by omega, Or.inr (by omega)⟩
      have := (satC_boxPow_bot c j l m).1 (hm h1)
      omega
  · intro hx m hm
    rw [satC_imp]
    intro ha
    have := (satC_boxPow_bot c i k m).1 ha
    rw [satC_boxPow_bot]
    omega

/-! ## §7. Depth vectors do not order the theories -/

/-- **Distinct depth vectors give distinct theories.**  If two height functions differ
in their truncated depth at some tag, the theories they generate differ — witnessed by
an iterated boxed falsum.  (The converse is `provable_capC_congr_of_min_eq`.) -/
theorem capC_ne_of_min_ne {c c' : ℕ → ℕ} {N i : ℕ} (h : min N (c i) ≠ min N (c' i)) :
    ∃ a : Form, ¬ (Provable (capC c N) a ↔ Provable (capC c' N) a) := by
  rcases Nat.lt_or_ge (min N (c i)) (min N (c' i)) with hlt | hge
  · refine ⟨boxPow i (min N (c i) + 1) bot, ?_⟩
    rw [capC_provable_boxPow_bot_iff, capC_provable_boxPow_bot_iff]
    omega
  · refine ⟨boxPow i (min N (c' i) + 1) bot, ?_⟩
    rw [capC_provable_boxPow_bot_iff, capC_provable_boxPow_bot_iff]
    omega

/-- **Inclusion of these theories is not the pointwise order on depths.**  Take
`N = 1`, `c = (0, 1, 1, …)` and `c' = (1, 1, …)`, so that the truncated depth of `c` is
pointwise below that of `c'`.  Nevertheless `□_0 ⊥ → □_1 ⊥` is provable in `capC c' 1`
and refuted in `capC c 1`: raising a single tag's depth is not a conservative move,
because the *relative* order of the depths also matters. -/
theorem theory_inclusion_not_pointwise :
    ∃ (c c' : ℕ → ℕ) (N : ℕ) (a : Form),
      (∀ i, min N (c i) ≤ min N (c' i)) ∧
        Provable (capC c' N) a ∧ ¬ Provable (capC c N) a := by
  refine ⟨fun k => if k = 0 then 0 else 1, fun _ => 1, 1,
    imp (box 0 bot) (box 1 bot), fun i => ?_, ?_, ?_⟩
  · by_cases h : i = 0 <;> simp [h]
  · rw [provable_capC]
    intro m hm
    rw [satC_imp]
    intro hant
    rw [satC_box_bot_iff] at hant
    replace hant : m = 0 ∨ 1 < m := hant
    rw [satC_box_bot_iff]
    show m = 0 ∨ 1 < m
    exact hant
  · rw [provable_capC]
    intro hprov
    have h1 := hprov 1 le_rfl
    rw [satC_imp] at h1
    have hante : satC (fun k => if k = 0 then 0 else 1) 1 (box 0 bot) = true := by
      rw [satC_box_bot_iff]; simp
    have := (satC_box_bot_iff (fun k => if k = 0 then 0 else 1) 1 1).1 (h1 hante)
    simp at this

/-- **Summary.**  The conjecture on realizable transfer preorders is confirmed in the
chain formulation, and the realizing theory is explicit. -/
theorem transfer_preorder_summary (N : ℕ) (R : ℕ → ℕ → Prop)
    (htrans : ∀ x y z, R x y → R y z → R x z) (htotal : ∀ x y, R x y ∨ R y x)
    (hchain : ∀ i, ¬ HasChainTo R (N + 1) i) :
    Consistent (capC (rank R N) N) ∧ (∀ i, IsGLTheory i (capC (rank R N) N)) ∧
      ∀ i j, Provable (capC (rank R N) N) (imp (Con i) (Con j)) ↔ R i j :=
  ⟨consistent_capC _ _, fun i => isGL_capC _ _ i,
    transferRel_rank_eq htrans htotal hchain⟩

end PhysicsConsistency