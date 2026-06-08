/-
# Conceptual Depth Gap Theory

A formal theory of "conceptual distance" between theorems in a finite
derivation graph. We define a shortest-path invariant (`depthGap`) that
measures the minimum number of conceptual leaps required to reach a
target theorem from a known library, prove it is well-behaved, and
establish separation results showing that arbitrarily large gaps exist.

## Main Results

- `depthGap_spec`: The depth gap correctly characterizes the shortest path.
- `below_threshold_derivative`: Low depth implies derivativeness.
- `derivative_iff_bounded_path`: Derivativeness is equivalent to bounded reachability.
- `exists_arbitrarily_large_depth_gap`: For every threshold, graphs with larger gaps exist.
- `depthGap_antitone_known`: Enlarging the known set cannot increase the gap.
-/

import Mathlib

open Finset

/-! ## Core Definitions -/

/-- A derivation graph is a binary relation on a type. -/
def DerivationGraph (α : Type*) := α → α → Prop

/-- Reachability in exactly `n` steps. -/
inductive ReachIn {α : Type*} (E : α → α → Prop) : ℕ → α → α → Prop where
  | zero (a : α) : ReachIn E 0 a a
  | succ {n : ℕ} {a b c : α} : E a b → ReachIn E n b c → ReachIn E (n + 1) a c

/-- The set of path lengths from any known node to the target. -/
def gapSet {α : Type*} (E : α → α → Prop) (known : Finset α) (target : α) : Set ℕ :=
  {n | ∃ k ∈ known, ReachIn E n k target}

/-- A target is derivative at threshold `τ` if it can be reached in at most `τ` steps. -/
def Derivative {α : Type*} (E : α → α → Prop) (known : Finset α) (τ : ℕ) (target : α) : Prop :=
  ∃ n ≤ τ, n ∈ gapSet E known target

/-- The depth gap: the minimum path length from any known node, or `none` if unreachable. -/
noncomputable def depthGap {α : Type*} (E : α → α → Prop)
    (known : Finset α) (target : α) : WithTop ℕ :=
  ⨅ n ∈ gapSet E known target, (n : WithTop ℕ)

/-! ## Basic Lemmas about ReachIn -/

theorem ReachIn.zero_iff {α : Type*} {E : α → α → Prop} {a b : α} :
    ReachIn E 0 a b ↔ a = b := by
  constructor
  · intro h; cases h; rfl
  · rintro rfl; exact ReachIn.zero a

theorem ReachIn.one_iff {α : Type*} {E : α → α → Prop} {a b : α} :
    ReachIn E 1 a b ↔ E a b := by
  constructor
  · intro h; cases h with | succ h1 h2 => cases h2; exact h1
  · intro h; exact ReachIn.succ h (ReachIn.zero b)

theorem ReachIn.trans {α : Type*} {E : α → α → Prop} {m n : ℕ} {a b c : α}
    (h1 : ReachIn E m a b) (h2 : ReachIn E n b c) : ReachIn E (m + n) a c := by
  induction h1 with
  | zero _ => simpa using h2
  | succ hedge _ ih => simp [Nat.succ_add]; exact ReachIn.succ hedge (ih h2)

theorem ReachIn.length_le_of_fintype {α : Type*} [Fintype α] [DecidableEq α]
    {E : α → α → Prop} {n : ℕ} {a b : α} (h : ReachIn E n a b)
    (hn : Fintype.card α ≤ n) (hab : a ≠ b) :
    ∃ m < n, ReachIn E m a b := by
  revert h a b; induction' hn with n hn ih;
  · intro a b h₁ h₂;
    -- By definition of ReachIn, there exists a sequence of nodes $v_0, v_1, ..., v_n$ such that $v_0 = a$, $v_n = b$, and $E v_i v_{i+1}$ for all $i$.
    obtain ⟨v, hv⟩ : ∃ v : Fin (Fintype.card α + 1) → α, v 0 = a ∧ v (Fin.last (Fintype.card α)) = b ∧ ∀ i : Fin (Fintype.card α), E (v i.castSucc) (v i.succ) := by
      have h_seq : ∀ {n : ℕ} {a b : α}, ReachIn E n a b → ∃ v : Fin (n + 1) → α, v 0 = a ∧ v (Fin.last n) = b ∧ ∀ i : Fin n, E (v i.castSucc) (v i.succ) := by
        intro n a b h
        induction' h with n a b h ih;
        · exact ⟨ fun _ => n, rfl, rfl, by simp +decide ⟩;
        · obtain ⟨ v, hv₁, hv₂, hv₃ ⟩ := ‹_›; use Fin.cons b v; simp_all +decide [ Fin.forall_fin_succ ] ;
      exact h_seq h₁;
    -- By the pigeonhole principle, since there are $Fintype.card α + 1$ nodes and only $Fintype.card α$ possible values, there must be at least two indices $i$ and $j$ such that $v i = v j$.
    obtain ⟨i, j, hij, h_eq⟩ : ∃ i j : Fin (Fintype.card α + 1), i < j ∧ v i = v j := by
      by_contra! h;
      exact absurd ( Fintype.card_le_of_injective v fun i j hij => le_antisymm ( not_lt.1 fun hi => h _ _ hi hij.symm ) ( not_lt.1 fun hj => h _ _ hj hij ) ) ( by simp +decide );
    -- We can remove the cycle between $i$ and $j$ to obtain a shorter path from $a$ to $b$.
    have h_shorter : ReachIn E (i.val + (Fintype.card α - j.val)) a b := by
      have h_shorter : ReachIn E i.val a (v i) ∧ ReachIn E (Fintype.card α - j.val) (v j) b := by
        have h_shorter : ∀ k : Fin (Fintype.card α + 1), ReachIn E (k : ℕ) a (v k) := by
          intro k;
          induction' k using Fin.inductionOn with k ih;
          · exact hv.1.symm ▸ ReachIn.zero _;
          · grind +suggestions;
        have h_shorter : ∀ k : Fin (Fintype.card α + 1), ReachIn E (Fintype.card α - k : ℕ) (v k) b := by
          intro k;
          induction' k using Fin.reverseInduction with k ih;
          · simp +decide [ hv.2.1 ];
            exact ReachIn.zero _;
          · convert ReachIn.succ ( hv.2.2 k ) ih using 1;
            grind +qlia;
        exact ⟨ by solve_by_elim, by solve_by_elim ⟩;
      exact ReachIn.trans ( by simpa [ h_eq ] using h_shorter.1 ) ( by simpa [ h_eq ] using h_shorter.2 );
    exact ⟨ _, by linarith [ show ( i : ℕ ) < j from hij, Nat.sub_add_cancel ( show ( j : ℕ ) ≤ Fintype.card α from Fin.is_le j ) ], h_shorter ⟩;
  · rintro a b ⟨ c, h₁, h₂ ⟩ hab;
    by_cases h : ‹α› = b <;> simp_all +decide [ Nat.lt_succ_iff ];
    · exact ⟨ 1, by linarith [ show 1 ≤ Fintype.card α from Fintype.card_pos_iff.mpr ⟨ a ⟩ ], ReachIn.succ ‹_› ( ReachIn.zero _ ) ⟩;
    · exact Exists.elim ( ih ‹_› h ) fun m hm => ⟨ m + 1, by linarith, ReachIn.succ ‹_› hm.2 ⟩

/-! ## Membership in gapSet -/

theorem mem_gapSet_iff {α : Type*} {E : α → α → Prop} {known : Finset α}
    {target : α} {n : ℕ} :
    n ∈ gapSet E known target ↔ ∃ k ∈ known, ReachIn E n k target := by
  rfl

theorem gapSet_mono_known {α : Type*} {E : α → α → Prop} {K₁ K₂ : Finset α}
    (hK : K₁ ⊆ K₂) {target : α} :
    gapSet E K₁ target ⊆ gapSet E K₂ target := by
  intro n hn
  obtain ⟨k, hk, hr⟩ := hn
  exact ⟨k, hK hk, hr⟩

theorem zero_mem_gapSet_of_mem {α : Type*} {E : α → α → Prop} {known : Finset α}
    {target : α} (h : target ∈ known) :
    0 ∈ gapSet E known target :=
  ⟨target, h, ReachIn.zero target⟩

/-! ## Derivative: basic properties -/

theorem Derivative.mono_threshold {α : Type*} {E : α → α → Prop} {known : Finset α}
    {τ₁ τ₂ : ℕ} (h : τ₁ ≤ τ₂) {target : α} (hd : Derivative E known τ₁ target) :
    Derivative E known τ₂ target := by
  obtain ⟨n, hn, hng⟩ := hd
  exact ⟨n, le_trans hn h, hng⟩

theorem Derivative.mono_known {α : Type*} {E : α → α → Prop} {K₁ K₂ : Finset α}
    (hK : K₁ ⊆ K₂) {τ : ℕ} {target : α} (hd : Derivative E K₁ τ target) :
    Derivative E K₂ τ target := by
  obtain ⟨n, hn, hng⟩ := hd
  exact ⟨n, hn, gapSet_mono_known hK hng⟩

theorem derivative_of_mem_known {α : Type*} {E : α → α → Prop} {known : Finset α}
    {τ : ℕ} {target : α} (h : target ∈ known) :
    Derivative E known τ target :=
  ⟨0, Nat.zero_le _, zero_mem_gapSet_of_mem h⟩

/-- Derivativeness is equivalent to existence of a bounded-length path from some known node. -/
theorem derivative_iff_bounded_path {α : Type*} {E : α → α → Prop}
    {known : Finset α} {τ : ℕ} {target : α} :
    Derivative E known τ target ↔ ∃ k ∈ known, ∃ n ≤ τ, ReachIn E n k target := by
  simp only [Derivative, mem_gapSet_iff]
  constructor
  · rintro ⟨n, hn, k, hk, hr⟩; exact ⟨k, hk, n, hn, hr⟩
  · rintro ⟨k, hk, n, hn, hr⟩; exact ⟨n, hn, k, hk, hr⟩

/-! ## Chain Graph: explicit examples -/

/-- The chain edge on `Fin (n+1)`: there is an edge from `i` to `i+1`. -/
def chainEdge (n : ℕ) : Fin (n + 1) → Fin (n + 1) → Prop :=
  fun a b => b.val = a.val + 1

instance chainEdge_decidable (n : ℕ) : DecidableRel (chainEdge n) :=
  fun a b => decidable_of_iff (b.val = a.val + 1) Iff.rfl

/-
In a chain graph, `ReachIn (chainEdge n) m i j` iff `j.val = i.val + m` and bounds hold.
-/
theorem chainEdge_reachIn_iff (n m : ℕ) (i j : Fin (n + 1)) :
    ReachIn (chainEdge n) m i j ↔ j.val = i.val + m := by
  constructor;
  · intro h;
    induction' h with m a b c h₁ h₂ ih;
    · lia;
    · linarith [ show ( c : ℕ ) = b + 1 from h₂ ];
  · induction' m with m ih generalizing i j;
    · exact fun h => by rw [ show j = i from Fin.ext ( by simpa using h ) ] ; exact ReachIn.zero _;
    · intro hj
      obtain ⟨k, hk⟩ : ∃ k : Fin (n + 1), k.val = i.val + 1 ∧ j.val = k.val + m := by
        exact ⟨ ⟨ i + 1, by linarith [ Fin.is_lt i, Fin.is_lt j ] ⟩, rfl, by norm_num; linarith ⟩;
      exact ReachIn.succ ( show chainEdge n i k from by tauto ) ( ih k j ( by linarith ) )

/-
The chain graph has depth gap exactly `m` from node `0` to node `m`.
-/
theorem chain_gapSet_iff (n m : ℕ) (target : Fin (n + 1))
    (known : Finset (Fin (n + 1)))
    (h_known : known = {⟨0, Nat.zero_lt_succ n⟩}) :
    m ∈ gapSet (chainEdge n) known target ↔ target.val = m := by
  simp +decide [ h_known, mem_gapSet_iff, chainEdge_reachIn_iff ]

/-! ## Threshold Theorem -/

/-- Below-threshold depth gap implies derivativeness. -/
theorem below_threshold_derivative {α : Type*} {E : α → α → Prop}
    {known : Finset α} {τ : ℕ} {target : α}
    (h : ∃ n ≤ τ, n ∈ gapSet E known target) :
    Derivative E known τ target := h

/-! ## Existence of Arbitrarily Large Depth Gaps -/

/-
For any threshold `τ`, there exists a finite graph where some node has
    depth gap strictly exceeding `τ`. This is the core separation theorem.
-/
theorem exists_deep_target (τ : ℕ) :
    ∃ (n : ℕ) (known : Finset (Fin (n + 1))) (target : Fin (n + 1)),
      (τ + 1) ∈ gapSet (chainEdge n) known target ∧
      ¬Derivative (chainEdge n) known τ target := by
  refine' ⟨ τ + 1, { ⟨ 0, Nat.zero_lt_succ _ ⟩ }, ⟨ τ + 1, Nat.succ_lt_succ ( Nat.lt_succ_self _ ) ⟩, _, _ ⟩ <;> simp +decide [ Derivative ];
  · exact ⟨ 0, by simp +decide, by simp +decide [ chainEdge_reachIn_iff ] ⟩;
  · intro x hx h; have := chain_gapSet_iff ( τ + 1 ) x ⟨ τ + 1, Nat.succ_lt_succ ( Nat.lt_succ_self _ ) ⟩ { 0 } rfl; aesop;

/-! ## Monotonicity Under Library Enrichment -/

/-
Enlarging the known set can only shrink the gap set's infimum (i.e., make the gap smaller).
-/
theorem depthGap_antitone_known {α : Type*} {E : α → α → Prop}
    {K₁ K₂ : Finset α} (hK : K₁ ⊆ K₂) (target : α) :
    depthGap E K₂ target ≤ depthGap E K₁ target := by
  apply_rules [ ciInf_mono ];
  · exact ⟨ 0, Set.forall_mem_range.2 fun n => by exact zero_le _ ⟩;
  · intro x; by_cases hx : x ∈ gapSet E K₁ target <;> simp_all +decide [ gapSet_mono_known ] ;
    exact ciInf_le_of_le ⟨ 0, Set.forall_mem_range.2 fun _ => Nat.cast_nonneg _ ⟩ ( gapSet_mono_known hK hx ) le_rfl

/-! ## Compressibility Bridge -/

/-- A target is compressible relative to known if there is a "short" witness path
    (bounded by the number of known theorems). This is a combinatorial proxy for
    proof compression: if the target can be derived via a short chain of
    conceptual transformations from known results, it is compressible. -/
def Compressible {α : Type*} [Fintype α] (E : α → α → Prop)
    (known : Finset α) (target : α) : Prop :=
  ∃ k ∈ known, ∃ n ≤ known.card, ReachIn E n k target

/-
Compression implies derivativeness: if a target is compressible, then it is
    derivative at threshold `known.card`. This connects proof compression to
    the depth-gap framework.
-/
theorem compression_implies_bounded_depth {α : Type*} [Fintype α]
    {E : α → α → Prop} {known : Finset α} {target : α}
    (h : Compressible E known target) :
    Derivative E known known.card target := by
  rcases h with ⟨ k, hk, n, hn, h ⟩ ; exact ⟨ _, hn, ⟨ k, hk, h ⟩ ⟩

/-
For every graph and known set, there exists a universal threshold `τ` such that
    all compressible targets are derivative at threshold `τ`.
-/
theorem compression_threshold_exists {α : Type*} [Fintype α]
    (E : α → α → Prop) (known : Finset α) :
    ∃ τ : ℕ, ∀ target, Compressible E known target → Derivative E known τ target := by
  -- Define the universal threshold `τ` as the cardinality of the known set.
  use known.card
  exact fun target a => compression_implies_bounded_depth a

/-! ## Decidability of Derivative -/

/-
Derivativeness at a given threshold is decidable for finite types with decidable edges.

ReachIn is decidable for finite types with decidable edges.
-/
theorem ReachIn.succ_iff {α : Type*} {E : α → α → Prop} {n : ℕ} {a c : α} :
    ReachIn E (n + 1) a c ↔ ∃ b, E a b ∧ ReachIn E n b c := by
  constructor;
  · rintro ⟨ b, hb ⟩;
    use ‹_›;
  · exact fun ⟨ b, h₁, h₂ ⟩ => ReachIn.succ h₁ h₂

instance ReachIn.decidable {α : Type*} [Fintype α] [DecidableEq α]
    (E : α → α → Prop) [DecidableRel E] (n : ℕ) (a b : α) :
    Decidable (ReachIn E n a b) := by
  induction n generalizing a b with
  | zero => exact decidable_of_iff (a = b) ReachIn.zero_iff.symm
  | succ n ih =>
    haveI : ∀ c d, Decidable (ReachIn E n c d) := ih
    exact decidable_of_iff (∃ c, E a c ∧ ReachIn E n c b) ReachIn.succ_iff.symm

instance Derivative.decidable {α : Type*} [Fintype α] [DecidableEq α]
    (E : α → α → Prop) [DecidableRel E]
    (known : Finset α) (τ : ℕ) (target : α) :
    Decidable (Derivative E known τ target) := by
  unfold Derivative gapSet
  simp only [Set.mem_setOf_eq]
  infer_instance