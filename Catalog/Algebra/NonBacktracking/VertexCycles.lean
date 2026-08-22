import Algebra.NonBacktracking.HashimotoTrace

/-!
# The vertex form of the non-backtracking trace formula

`Hashimoto.trace_hashimoto_pow` counts rooted closed non-backtracking walks as lists of
*darts*.  Classically one prefers the *vertex* description: a rooted closed
non-backtracking walk of length `n` is a cyclic word `u₀ u₁ … u_{n-1}` of vertices with

* `uᵢ` adjacent to `u_{i+1}` for all `i` **cyclically**, and
* `u_{i+2} ≠ uᵢ` for all `i` **cyclically** (no immediate backtracking, including across
  the seam).

Cyclic conditions are expressed with `List.rotate`: "`∀ i, R uᵢ u_{i+1 mod n}`" is exactly
`List.Forall₂ R u (u.rotate 1)`.

## Main results

* `Hashimoto.isChain_seam_iff_forall₂_rotate` — a list is a chain *and* closes up under
  the relation iff it is `Forall₂`-related to its own rotation. This converts the linear
  (chain) description of closed walks into the genuinely cyclic one.
* `Hashimoto.mem_cyclicNBVertexSeqs` — the vertex description above really describes the
  image of the dart cycles under `d ↦ d.fst`.
* `Hashimoto.trace_hashimoto_pow_eq_card_cyclicNBVertexSeqs` —
  `trace (B ^ n) = #{cyclically non-backtracking closed vertex words of length n}`
  for `n ≥ 1`.
-/

open Finset RelWalkCount SimpleGraph List

namespace Hashimoto

/-! ## List lemmas -/

section ListLemmas

variable {α β γ γ' : Type*}

/-- A `Forall₂` for a conjunction splits. -/
lemma forall₂_and_iff {R S : α → β → Prop} {l₁ : List α} {l₂ : List β} :
    Forall₂ (fun a b => R a b ∧ S a b) l₁ l₂ ↔ Forall₂ R l₁ l₂ ∧ Forall₂ S l₁ l₂ := by
  induction l₁ generalizing l₂ with
  | nil =>
      cases l₂ with
      | nil => simp
      | cons b t => simp
  | cons a s ih =>
      cases l₂ with
      | nil => simp
      | cons b t =>
          simp only [List.forall₂_cons, ih]
          tauto

/-- Pushing `Forall₂` through maps on both sides. -/
lemma forall₂_map_map {R : γ → γ' → Prop} {f : α → γ} {g : β → γ'} {l₁ : List α}
    {l₂ : List β} :
    Forall₂ (fun a b => R (f a) (g b)) l₁ l₂ ↔ Forall₂ R (l₁.map f) (l₂.map g) := by
  rw [List.forall₂_map_left_iff, List.forall₂_map_right_iff]

/-- `Forall₂ (· = ·)` between two mapped lists is equality of the mapped lists. -/
lemma forall₂_eq_iff_map_eq {f : α → γ} {g : β → γ} {l₁ : List α} {l₂ : List β} :
    Forall₂ (fun a b => f a = g b) l₁ l₂ ↔ l₁.map f = l₂.map g := by
  rw [forall₂_map_map (R := (· = ·)), List.forall₂_eq_eq_eq]

/-- Auxiliary form of the cyclic-chain criterion with an explicit closing element. -/
private lemma isChain_append_singleton_iff {R : α → α → Prop} :
    ∀ (t : List α) (x z : α),
      (IsChain R (x :: t) ∧ ∀ w ∈ (x :: t).getLast?, R w z) ↔ Forall₂ R (x :: t) (t ++ [z]) := by
  intro t
  induction t with
  | nil =>
      intro x z
      simp [List.forall₂_cons]
  | cons y s ih =>
      intro x z
      rw [List.cons_append, List.forall₂_cons, ← ih y z]
      simp only [List.isChain_cons_cons, List.getLast?_cons_cons]
      tauto

/-- **Cyclic chain criterion.** A nonempty list is a chain for `R` which additionally
closes up (`R` relates its last entry to its first) exactly when it is `Forall₂`-related
to its own rotation by one. -/
theorem isChain_seam_iff_forall₂_rotate {R : α → α → Prop} {l : List α} (hne : l ≠ []) :
    (IsChain R l ∧ ∀ x ∈ l.getLast?, ∀ y ∈ l.head?, R x y) ↔ Forall₂ R l (l.rotate 1) := by
  match l, hne with
  | x :: t, _ =>
      rw [List.rotate_cons_succ, List.rotate_zero, ← isChain_append_singleton_iff t x x]
      simp only [List.head?_cons, Option.mem_def, Option.some.injEq]
      constructor
      · rintro ⟨hchain, hseam⟩
        exact ⟨hchain, fun w hw => hseam w hw x rfl⟩
      · rintro ⟨hchain, hseam⟩
        refine ⟨hchain, fun w hw y hy => ?_⟩
        subst hy
        exact hseam w hw

end ListLemmas

/-! ## Cyclic dart words -/

variable {V : Type*} [Fintype V] [DecidableEq V] (G : SimpleGraph V) [DecidableRel G.Adj]

/-- Membership in `nbCycles` in genuinely cyclic form. -/
theorem mem_nbCycles_iff_forall₂ {n : ℕ} (hn : 1 ≤ n) {c : List G.Dart} :
    c ∈ nbCycles G n ↔ c.length = n ∧ Forall₂ (NBAdj G) c (c.rotate 1) := by
  rw [mem_nbCycles hn]
  constructor
  · rintro ⟨hlen, hchain, hseam⟩
    have hne : c ≠ [] := by intro h; rw [h] at hlen; simp at hlen; omega
    exact ⟨hlen, (isChain_seam_iff_forall₂_rotate hne).1 ⟨hchain, hseam⟩⟩
  · rintro ⟨hlen, hf⟩
    have hne : c ≠ [] := by intro h; rw [h] at hlen; simp at hlen; omega
    obtain ⟨hchain, hseam⟩ := (isChain_seam_iff_forall₂_rotate hne).2 hf
    exact ⟨hlen, hchain, hseam⟩

variable {G}

omit [Fintype V] [DecidableEq V] [DecidableRel G.Adj] in
/-- A list of darts is determined by the lists of its tails and of its heads. -/
lemma dartList_ext : ∀ {c c' : List G.Dart},
    c.map (fun d => d.toProd.1) = c'.map (fun d => d.toProd.1) →
    c.map (fun d => d.toProd.2) = c'.map (fun d => d.toProd.2) → c = c' := by
  intro c
  induction c with
  | nil =>
      intro c' h1 _
      cases c' with
      | nil => rfl
      | cons d t => simp at h1
  | cons d t ih =>
      intro c' h1 h2
      cases c' with
      | nil => simp at h1
      | cons d' t' =>
          simp only [List.map_cons, List.cons.injEq] at h1 h2
          rw [ih h1.2 h2.2]
          exact congrArg (· :: t') (SimpleGraph.Dart.ext _ _ (Prod.ext h1.1 h2.1))

omit [Fintype V] [DecidableEq V] [DecidableRel G.Adj] in
/-- Any `Forall₂`-adjacent pair of vertex lists is realised by a list of darts. -/
lemma exists_dartList {u v : List V} (h : Forall₂ G.Adj u v) :
    ∃ c : List G.Dart, c.map (fun d => d.toProd.1) = u ∧ c.map (fun d => d.toProd.2) = v := by
  induction h with
  | nil => exact ⟨[], rfl, rfl⟩
  | @cons a b l₁ l₂ hab _ ih =>
      obtain ⟨c, h1, h2⟩ := ih
      exact ⟨(⟨(a, b), hab⟩ : G.Dart) :: c, by simp [h1], by simp [h2]⟩

variable (G)

/-! ## Cyclic vertex words -/

/-- The finset of **cyclically non-backtracking closed vertex words** of length `n`: the
vertex trace of the dart cycles counted by `trace (B ^ n)`. -/
def cyclicNBVertexSeqs (n : ℕ) : Finset (List V) :=
  (nbCycles G n).image (List.map fun d => d.toProd.1)

variable {G}

omit [Fintype V] [DecidableEq V] [DecidableRel G.Adj] in
/-- The heads of a cyclic dart word are the tails, rotated by one. -/
private lemma map_snd_eq_rotate {c : List G.Dart} (hf : Forall₂ (NBAdj G) c (c.rotate 1)) :
    c.map (fun d => d.toProd.2) = (c.map fun d => d.toProd.1).rotate 1 := by
  have h := forall₂_eq_iff_map_eq.1 (forall₂_and_iff.1 hf).1
  rwa [List.map_rotate] at h

/-- **Vertex description.** A word `u` of length `n ≥ 1` arises from a closed
non-backtracking walk exactly when consecutive letters (cyclically) are adjacent and
letters two apart (cyclically) are distinct. -/
theorem mem_cyclicNBVertexSeqs {n : ℕ} (hn : 1 ≤ n) {u : List V} :
    u ∈ cyclicNBVertexSeqs G n ↔
      u.length = n ∧ Forall₂ G.Adj u (u.rotate 1) ∧ Forall₂ (· ≠ ·) (u.rotate 2) u := by
  constructor
  · rintro hu
    simp only [cyclicNBVertexSeqs, Finset.mem_image] at hu
    obtain ⟨c, hc, rfl⟩ := hu
    rw [mem_nbCycles_iff_forall₂ G hn] at hc
    obtain ⟨hlen, hf⟩ := hc
    have hcomp := map_snd_eq_rotate hf
    refine ⟨by simpa using hlen, ?_, ?_⟩
    · have hadj : Forall₂ G.Adj (c.map fun d => d.toProd.1) (c.map fun d => d.toProd.2) := by
        rw [← forall₂_map_map]
        exact List.forall₂_same.2 fun d _ => d.adj
      rwa [hcomp] at hadj
    · have hflip : Forall₂ (fun x y : G.Dart => x.toProd.2 ≠ y.toProd.1) (c.rotate 1) c :=
        (forall₂_and_iff.1 hf).2.flip
      rw [forall₂_map_map (R := (· ≠ ·)), List.map_rotate, hcomp, List.rotate_rotate] at hflip
      exact hflip
  · rintro ⟨hlen, hadj, hnb⟩
    obtain ⟨c, hfst, hsnd⟩ := exists_dartList hadj
    have hlenc : c.length = n := by
      have : c.length = u.length := by rw [← hfst, List.length_map]
      rw [this, hlen]
    have hmem : c ∈ nbCycles G n := by
      rw [mem_nbCycles_iff_forall₂ G hn]
      refine ⟨hlenc, forall₂_and_iff.2 ⟨?_, ?_⟩⟩
      · rw [forall₂_eq_iff_map_eq, List.map_rotate, hfst, hsnd]
      · have key : Forall₂ (fun x y : G.Dart => x.toProd.2 ≠ y.toProd.1) (c.rotate 1) c := by
          rw [forall₂_map_map (R := (· ≠ ·)), List.map_rotate, hsnd, hfst, List.rotate_rotate]
          exact hnb
        exact key.flip
    exact Finset.mem_image.2 ⟨c, hmem, hfst⟩

/-- The vertex trace map is injective on dart cycles, so the two counts agree. -/
theorem card_cyclicNBVertexSeqs {n : ℕ} (hn : 1 ≤ n) :
    (cyclicNBVertexSeqs G n).card = (nbCycles G n).card := by
  refine Finset.card_image_of_injOn ?_
  intro c₁ h₁ c₂ h₂ hEq
  rw [Finset.mem_coe, mem_nbCycles_iff_forall₂ G hn] at h₁ h₂
  have e₁ := map_snd_eq_rotate h₁.2
  have e₂ := map_snd_eq_rotate h₂.2
  exact dartList_ext hEq (by rw [e₁, e₂, hEq])

variable (G)

/-- **Vertex form of the trace formula.** For `n ≥ 1`, `trace (B ^ n)` is the number of
cyclically non-backtracking closed vertex words of length `n`. -/
theorem trace_hashimoto_pow_eq_card_cyclicNBVertexSeqs {n : ℕ} (hn : 1 ≤ n) :
    (hashimoto G ^ n).trace = (cyclicNBVertexSeqs G n).card := by
  rw [trace_hashimoto_pow_eq_card_nbCycles G hn, card_cyclicNBVertexSeqs hn]

end Hashimoto