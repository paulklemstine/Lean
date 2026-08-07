/-
  Hadwiger's Conjecture is Monotone in `k`
  ========================================

  A structural theorem about the conjecture itself rather than about a single
  graph: **if Hadwiger's conjecture holds for the parameter `k+1`, it holds for
  `k`**.  The proof is the classical *apex* (cone) construction: adjoin to `G` a
  new vertex joined to everything.  The cone needs one colour more than `G`, so
  the assumed case produces a `K_{k+2}` model in the cone; deleting the (unique)
  branch set that contains the apex leaves a `K_{k+1}` model inside `G`.

  Main results:

  * `Hadwiger.cone`                      : the apex construction.
  * `Hadwiger.not_colorable_cone`        : `¬ G.Colorable k → ¬ (cone G).Colorable (k+1)`.
  * `Hadwiger.completeMinor_of_cone`     : a `K_{n+1}` minor of `cone G` yields a
                                           `Kₙ` minor of `G`.
  * `Hadwiger.hadwiger_monotone`         : `HadwigerProperty (k+1) → HadwigerProperty k`.

  -- !-- Lab Notes -- !--
  Hypothesis (Hypothesizer): the conjecture should get *harder* as `k` grows, so
    the family `HadwigerProperty k` should be decreasing.  The apex construction
    is the standard tool.
  Experiment (Experimenter): two independent halves.  (i) Colouring: from a
    `(k+1)`-colouring of the cone, the apex colour `a` is missed by every other
    vertex, and the "delete colour `a`" map `Fin (k+1) → Fin k` is injective off
    `a`, producing a `k`-colouring of `G`.  (ii) Minors: the apex lies in at most
    one branch set (disjointness), so `Fin.succAbove` selects `k+1` branch sets
    avoiding it; each is contained in the copy of `V`, and walks inside them
    never see the apex, so they pull back to `G` along `Sum.inl`.
  Analysis (Analyst): the walk pull-back is the only genuinely inductive step; it
    needs that the branch set contains no apex, which is exactly the reason for
    discarding one branch set rather than intersecting.
  Critique (Critic): the case `k = 0` must be treated separately, since there is
    no injection `Fin 1 ∖ {a} → Fin 0`; there the cone contains an edge and so is
    not `1`-colourable directly.
  Synthesis (PI): `HadwigerProperty` is antitone, so the conjecture for a single
    large `k` subsumes all smaller ones — and the unresolved cases `k ≥ 5` are
    genuinely the hardest.
  -- !-- Lab Notes -- !--
-/
import Mathlib
import Probability.HadwigerSmallCases

namespace Hadwiger

open SimpleGraph

variable {V : Type*} {G : SimpleGraph V}

/-! ### The apex construction -/

/-- `cone G` adjoins to `G` a new (apex) vertex adjacent to every old vertex. -/
def cone (G : SimpleGraph V) : SimpleGraph (V ⊕ Unit) where
  Adj x y :=
    match x, y with
    | Sum.inl a, Sum.inl b => G.Adj a b
    | Sum.inl _, Sum.inr _ => True
    | Sum.inr _, Sum.inl _ => True
    | Sum.inr _, Sum.inr _ => False
  symm := by
    rintro (a | a) (b | b) h <;> simp_all
    exact h.symm
  loopless := ⟨by
    rintro (a | a) h
    · exact G.irrefl h
    · exact h⟩

@[simp] theorem cone_adj_inl {a b : V} : (cone G).Adj (Sum.inl a) (Sum.inl b) ↔ G.Adj a b :=
  Iff.rfl

@[simp] theorem cone_adj_apex_right {a : V} {u : Unit} : (cone G).Adj (Sum.inl a) (Sum.inr u) :=
  trivial

@[simp] theorem cone_adj_apex_left {a : V} {u : Unit} : (cone G).Adj (Sum.inr u) (Sum.inl a) :=
  trivial

/-! ### The cone needs one more colour -/

/-- Deleting the colour `a` from `Fin (k+1)`. -/
private def dropColor (k : ℕ) (a : Fin (k + 1)) (hk : 0 < k) (c : Fin (k + 1)) : Fin k :=
  if h : c.val < a.val then ⟨c.val, by omega⟩ else ⟨c.val - 1, by omega⟩

private theorem dropColor_injOn {k : ℕ} {a : Fin (k + 1)} (hk : 0 < k) {c d : Fin (k + 1)}
    (hc : c ≠ a) (hd : d ≠ a) (h : dropColor k a hk c = dropColor k a hk d) : c = d := by
  have hc' : c.val ≠ a.val := fun hcon => hc (Fin.ext hcon)
  have hd' : d.val ≠ a.val := fun hcon => hd (Fin.ext hcon)
  have hcv := c.isLt
  have hdv := d.isLt
  unfold dropColor at h
  split_ifs at h with h1 h2 h2 <;>
    · have := congrArg Fin.val h
      simp at this
      exact Fin.ext (by omega)

/-- **The cone needs one more colour than `G`.** -/
theorem not_colorable_cone {k : ℕ} (h : ¬ G.Colorable k) : ¬ (cone G).Colorable (k + 1) := by
  rintro ⟨C⟩
  rcases Nat.eq_zero_or_pos k with rfl | hk
  · -- `G` is not `0`-colourable, so it has a vertex, which is adjacent to the apex
    have : Nonempty V := by
      by_contra hcon
      exact h (colorable_zero_iff.mpr (not_nonempty_iff.mp hcon))
    obtain ⟨v⟩ := this
    have hne : C (Sum.inl v) ≠ C (Sum.inr ()) := C.valid cone_adj_apex_right
    have h1 := (C (Sum.inl v)).isLt
    have h2 := (C (Sum.inr ())).isLt
    exact hne (Fin.ext (by omega))
  · set a := C (Sum.inr ()) with ha
    have hne : ∀ v : V, C (Sum.inl v) ≠ a := fun v => C.valid cone_adj_apex_right
    refine h ⟨Coloring.mk (fun v => dropColor k a hk (C (Sum.inl v))) ?_⟩
    intro x y hxy hcon
    exact C.valid (cone_adj_inl.mpr hxy)
      (dropColor_injOn hk (hne x) (hne y) hcon)

/-! ### Pulling a minor of the cone back to `G` -/

/-- Walks of `cone G` that avoid the apex come from walks of `G`. -/
private theorem pullback_walk {S : Set (V ⊕ Unit)} (hS : ∀ z ∈ S, ∃ c : V, z = Sum.inl c) :
    ∀ {x y : V ⊕ Unit} (p : (cone G).Walk x y), (∀ z ∈ p.support, z ∈ S) →
      ∀ {a b : V}, x = Sum.inl a → y = Sum.inl b →
        ∃ q : G.Walk a b, ∀ z ∈ q.support, Sum.inl z ∈ S := by
  intro x y p
  induction p with
  | @nil u =>
    intro hsup a b hxa hyb
    have hab : a = b := by
      have := hxa.symm.trans hyb
      exact Sum.inl_injective this
    subst hab
    subst hxa
    exact ⟨Walk.nil, by simpa using hsup _ (by simp)⟩
  | @cons u w y' huw p ih =>
    intro hsup a b hxa hyb
    subst hxa
    have hwS : w ∈ S := hsup w (by simp)
    obtain ⟨c, rfl⟩ := hS w hwS
    have hac : G.Adj a c := cone_adj_inl.mp huw
    obtain ⟨q, hq⟩ := ih (fun z hz => hsup z (by simp [hz])) rfl hyb
    refine ⟨Walk.cons hac q, ?_⟩
    intro z hz
    rcases List.mem_cons.mp (by simpa using hz) with rfl | hz'
    · exact hsup _ (by simp)
    · exact hq z hz'

/-- Connectivity of an apex-free set of the cone descends to `G`. -/
private theorem setConnected_pullback {S : Set (V ⊕ Unit)}
    (hS : ∀ z ∈ S, ∃ c : V, z = Sum.inl c) (h : SetConnected (cone G) S) :
    SetConnected G (Sum.inl ⁻¹' S) := by
  obtain ⟨⟨z, hz⟩, hconn⟩ := h
  obtain ⟨c, rfl⟩ := hS z hz
  refine ⟨⟨c, hz⟩, ?_⟩
  intro x hx y hy
  obtain ⟨p, hp⟩ := hconn (show Sum.inl x ∈ S from hx) (show Sum.inl y ∈ S from hy)
  obtain ⟨q, hq⟩ := pullback_walk hS p hp rfl rfl
  exact ⟨q, hq⟩

/-- **Removing the apex branch set.**  A `K_{n+1}` minor of `cone G` yields a
`Kₙ` minor of `G`. -/
theorem completeMinor_of_cone {n : ℕ} (h : CompleteMinor (n + 1) (cone G)) :
    CompleteMinor n G := by
  classical
  obtain ⟨M⟩ := walkMinor_iff_isMinor.mpr h
  -- the index of the branch set containing the apex (or a dummy index)
  set i0 : Fin (n + 1) :=
    if hex : ∃ i, (Sum.inr () : V ⊕ Unit) ∈ M.branch i then hex.choose else 0 with hi0
  have hapex : ∀ i, i ≠ i0 → (Sum.inr () : V ⊕ Unit) ∉ M.branch i := by
    intro i hi hmem
    by_cases hex : ∃ i, (Sum.inr () : V ⊕ Unit) ∈ M.branch i
    · have hchoose : (Sum.inr () : V ⊕ Unit) ∈ M.branch hex.choose := hex.choose_spec
      have hi0eq : i0 = hex.choose := by simp [hi0, hex]
      exact (Set.disjoint_left.mp (M.branch_disjoint (hi0eq ▸ hi))) hmem hchoose
    · exact hex ⟨i, hmem⟩
  have hnoapex : ∀ j : Fin n, ∀ z ∈ M.branch (i0.succAbove j), ∃ c : V, z = Sum.inl c := by
    intro j z hz
    cases z with
    | inl c => exact ⟨c, rfl⟩
    | inr u =>
      exact absurd (show (Sum.inr () : V ⊕ Unit) ∈ M.branch (i0.succAbove j) by
        cases u; exact hz) (hapex _ (i0.succAbove_ne j))
  refine completeMinor_of_branches (fun j => Sum.inl ⁻¹' M.branch (i0.succAbove j)) ?_ ?_ ?_ ?_
  · intro j
    obtain ⟨z, hz⟩ := M.branch_nonempty (i0.succAbove j)
    obtain ⟨c, rfl⟩ := hnoapex j z hz
    exact ⟨c, hz⟩
  · intro j j' hjj'
    have hne : i0.succAbove j ≠ i0.succAbove j' := fun hcon =>
      hjj' (Fin.succAbove_right_injective hcon)
    exact (M.branch_disjoint hne).preimage _
  · intro j
    exact setConnected_pullback (hnoapex j) (M.branch_connected (i0.succAbove j))
  · intro j j' hjj'
    have hne : i0.succAbove j ≠ i0.succAbove j' := fun hcon =>
      hjj' (Fin.succAbove_right_injective hcon)
    obtain ⟨x, hx, y, hy, hxy⟩ := M.edge_lift (show (⊤ : SimpleGraph (Fin (n + 1))).Adj _ _ from hne)
    obtain ⟨c, rfl⟩ := hnoapex j x hx
    obtain ⟨d, rfl⟩ := hnoapex j' y hy
    exact ⟨c, hx, d, hy, cone_adj_inl.mp hxy⟩

/-- **Hadwiger's conjecture is antitone in `k`.** -/
theorem hadwiger_monotone {k : ℕ} (h : HadwigerProperty (k + 1)) : HadwigerProperty k := by
  intro V _ G hG
  have hcone : ¬ (cone G).Colorable (k + 1) := not_colorable_cone hG
  have := h (V ⊕ Unit) (cone G) hcone
  exact completeMinor_of_cone this

end Hadwiger