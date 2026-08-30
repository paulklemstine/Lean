import Mathlib
import Bridges.TwoTreeClosure.TreeCore
import Bridges.TwoTreeClosure.AscentWord
import Bridges.TwoTreeClosure.AscentEconomics

/-!
# Search lower bounds and exact letter counts on the Berggren/Price tree

Third cycle of the two-tree programme.  `TreeCore` shows that no cheap probe reads
the ascent letter from `N`; `AscentWord` shows that the letters *are* a normal form.
This file quantifies what a searcher who cannot read the letters must pay, and how
much letter information the tree measure itself carries.

* `words h` enumerates the `{A,B,C}`-words of length `h`; `card_words` : there are
  exactly `3 ^ h` of them and `mem_words_iff` characterises membership by length.
* `depthNodes h` is the set of nodes at depth `h` below the root; `card_depthNodes`
  gives it exactly `3 ^ h` elements (an ascent-word refinement of `card_desc`).
* `card_depthNodes_letter` : **exact letter equidistribution over the tree measure** —
  for every letter `L`, exactly `3 ^ h` of the `3 ^ (h+1)` nodes at depth `h + 1`
  carry the letter `L`.  So a *uniform* node at depth `h+1` carries a full
  `log₂ 3` bits of last-letter entropy, while the blindness theorems of `TreeCore`
  say that none of it is readable from the hypotenuse.
* `exists_unvisited_node`, `majority_unvisited` : the adversary/pigeonhole lower
  bound.  A blind searcher who visits fewer than `3 ^ h` nodes misses some depth-`h`
  node, and one who visits fewer than `3 ^ h / 2` misses a strict majority of them.
* `restart_beats_exhaustive_half`, `guided_beats_exhaustive_of_gt_third`,
  `exhaustive_beats_guided_of_lt_third` : the accuracy threshold at which the
  restarted guided ascent overtakes exhaustive search is exactly `1/3` — the
  reciprocal of the branching base pinned by `card_desc`.  This is the *cost* side of
  the closure, complementing the *budget* side `0.85 < α* ≤ 0.86` of
  `AscentEconomics`.
-/

namespace TwoTreeClosure

open Finset Filter

/-- The root of the Berggren/Price tree is an arithmetic node. -/
theorem isNode_root : IsNode 2 1 := by
  refine ⟨by norm_num, by norm_num, ?_, by norm_num⟩
  simp [Nat.Coprime]

/-! ### Counting words -/

/-- All `{A,B,C}`-words of a given length, built by appending a final letter. -/
def words : ℕ → Finset (List Letter)
  | 0 => {[]}
  | h + 1 =>
      (words h).image (fun w => w ++ [Letter.A]) ∪
        ((words h).image (fun w => w ++ [Letter.B]) ∪
          (words h).image (fun w => w ++ [Letter.C]))

theorem mem_words_iff : ∀ (h : ℕ) (w : List Letter), w ∈ words h ↔ w.length = h := by
  intro h
  induction h with
  | zero =>
      intro w
      simp only [words, Finset.mem_singleton, List.length_eq_zero_iff]
  | succ h ih =>
      intro w
      simp only [words, Finset.mem_union, Finset.mem_image]
      constructor
      · rintro (⟨u, hu, rfl⟩ | ⟨u, hu, rfl⟩ | ⟨u, hu, rfl⟩) <;>
          simp [(ih u).mp hu]
      · intro hlen
        rcases List.eq_nil_or_concat w with rfl | ⟨u, l, rfl⟩
        · simp at hlen
        · rw [List.concat_eq_append] at hlen ⊢
          have hu : u.length = h := by
            simp only [List.length_append, List.length_singleton] at hlen
            omega
          have hmem : u ∈ words h := (ih u).mpr hu
          cases l
          · exact Or.inl ⟨u, hmem, rfl⟩
          · exact Or.inr (Or.inl ⟨u, hmem, rfl⟩)
          · exact Or.inr (Or.inr ⟨u, hmem, rfl⟩)

theorem append_letter_injective (l : Letter) :
    Function.Injective (fun w : List Letter => w ++ [l]) := by
  intro u v huv
  simpa using huv

/-- There are exactly `3 ^ h` words of length `h`. -/
theorem card_words : ∀ h : ℕ, (words h).card = 3 ^ h := by
  intro h
  induction h with
  | zero => simp [words]
  | succ h ih =>
      have hA : ((words h).image (fun w => w ++ [Letter.A])).card = 3 ^ h := by
        rw [Finset.card_image_of_injective _ (append_letter_injective Letter.A), ih]
      have hB : ((words h).image (fun w => w ++ [Letter.B])).card = 3 ^ h := by
        rw [Finset.card_image_of_injective _ (append_letter_injective Letter.B), ih]
      have hC : ((words h).image (fun w => w ++ [Letter.C])).card = 3 ^ h := by
        rw [Finset.card_image_of_injective _ (append_letter_injective Letter.C), ih]
      have hlast : ∀ (l : Letter) (u : List Letter), (u ++ [l]).getLast? = some l := by
        intro l u
        simp
      have hdisj : ∀ l l' : Letter, l ≠ l' →
          Disjoint ((words h).image (fun w => w ++ [l]))
            ((words h).image (fun w => w ++ [l'])) := by
        intro l l' hll
        rw [Finset.disjoint_left]
        rintro a ha ha'
        simp only [Finset.mem_image] at ha ha'
        obtain ⟨u, -, rfl⟩ := ha
        obtain ⟨v, -, hv⟩ := ha'
        have := hlast l u
        rw [← hv, hlast l' v] at this
        exact hll (Option.some_injective _ this).symm
      have hBC : Disjoint ((words h).image (fun w => w ++ [Letter.B]))
          ((words h).image (fun w => w ++ [Letter.C])) := hdisj _ _ (by decide)
      have hAB : Disjoint ((words h).image (fun w => w ++ [Letter.A]))
          ((words h).image (fun w => w ++ [Letter.B]) ∪
            (words h).image (fun w => w ++ [Letter.C])) := by
        rw [Finset.disjoint_union_right]
        exact ⟨hdisj _ _ (by decide), hdisj _ _ (by decide)⟩
      simp only [words]
      rw [Finset.card_union_of_disjoint hAB, Finset.card_union_of_disjoint hBC, hA, hB, hC]
      ring

/-! ### Counting nodes at a fixed depth -/

/-- The nodes at depth `h` below the root, indexed by their ascent words. -/
def depthNodes (h : ℕ) : Finset (ℕ × ℕ) := (words h).image (fun w => follow w (2, 1))

/-- **The depth-`h` level has exactly `3 ^ h` nodes**, each with its own ascent word. -/
theorem card_depthNodes (h : ℕ) : (depthNodes h).card = 3 ^ h := by
  rw [depthNodes, Finset.card_image_of_injective _ ?_, card_words]
  intro u v huv
  exact follow_injective isNode_root u v huv

theorem mem_depthNodes {h : ℕ} {p : ℕ × ℕ} :
    p ∈ depthNodes h ↔ ∃ w : List Letter, w.length = h ∧ follow w (2, 1) = p := by
  simp only [depthNodes, Finset.mem_image]
  constructor
  · rintro ⟨w, hw, rfl⟩
    exact ⟨w, (mem_words_iff h w).mp hw, rfl⟩
  · rintro ⟨w, hw, rfl⟩
    exact ⟨w, (mem_words_iff h w).mpr hw, rfl⟩

/-- Every depth-`h` node is an arithmetic node. -/
theorem depthNodes_isNode {h : ℕ} {p : ℕ × ℕ} (hp : p ∈ depthNodes h) : IsNode p.1 p.2 := by
  obtain ⟨w, -, rfl⟩ := mem_depthNodes.mp hp
  exact follow_isNode isNode_root w

/-- The last letter of a word is the ascent letter of the node it reaches. -/
theorem letterOf_follow_concat (u : List Letter) (l : Letter) :
    letterOf (follow (u ++ [l]) (2, 1)).1 (follow (u ++ [l]) (2, 1)).2 = l := by
  rw [follow_append]
  exact letterOf_childOf l (follow_isNode isNode_root u)

/-- The depth-`(h+1)` nodes with ascent letter `l` are exactly the nodes reached by a
length-`h` word followed by `l`. -/
theorem filter_depthNodes_letter (h : ℕ) (l : Letter) :
    (depthNodes (h + 1)).filter (fun p => letterOf p.1 p.2 = l)
      = (words h).image (fun w => follow (w ++ [l]) (2, 1)) := by
  ext p
  simp only [Finset.mem_filter, Finset.mem_image, mem_depthNodes]
  constructor
  · rintro ⟨⟨w, hw, rfl⟩, hl⟩
    rcases List.eq_nil_or_concat w with rfl | ⟨u, l', rfl⟩
    · simp at hw
    · rw [List.concat_eq_append] at hw hl ⊢
      have hu : u.length = h := by
        simp only [List.length_append, List.length_singleton] at hw
        omega
      have : l' = l := by rw [← letterOf_follow_concat u l']; exact hl
      subst this
      exact ⟨u, (mem_words_iff h u).mpr hu, rfl⟩
  · rintro ⟨u, hu, rfl⟩
    have hu' : u.length = h := (mem_words_iff h u).mp hu
    refine ⟨⟨u ++ [l], by simp [hu'], rfl⟩, letterOf_follow_concat u l⟩

/-- **Exact letter equidistribution over the tree measure.**  At depth `h + 1` each of
the three ascent letters is carried by exactly `3 ^ h` of the `3 ^ (h+1)` nodes: the
tree measure spreads the letters perfectly evenly, so a uniformly chosen node at that
depth carries a full `log₂ 3` bits of last-letter entropy — none of which, by
`magnitude_probe_letterBlind`, is a function of its hypotenuse. -/
theorem card_depthNodes_letter (h : ℕ) (l : Letter) :
    ((depthNodes (h + 1)).filter (fun p => letterOf p.1 p.2 = l)).card = 3 ^ h := by
  rw [filter_depthNodes_letter h l, Finset.card_image_of_injective _ ?_, card_words]
  intro u v huv
  have : follow (u ++ [l]) (2, 1) = follow (v ++ [l]) (2, 1) := huv
  have := follow_injective isNode_root _ _ this
  exact append_letter_injective l this

/-- The three letter classes at depth `h + 1` account for all `3 ^ (h+1)` nodes. -/
theorem sum_card_depthNodes_letter (h : ℕ) :
    ((depthNodes (h + 1)).filter (fun p => letterOf p.1 p.2 = Letter.A)).card +
        ((depthNodes (h + 1)).filter (fun p => letterOf p.1 p.2 = Letter.B)).card +
        ((depthNodes (h + 1)).filter (fun p => letterOf p.1 p.2 = Letter.C)).card
      = (depthNodes (h + 1)).card := by
  rw [card_depthNodes_letter, card_depthNodes_letter, card_depthNodes_letter,
    card_depthNodes]
  ring

/-! ### The blind-search adversary bound -/

/-- **Pigeonhole adversary bound.**  A searcher that visits a set `V` of fewer than
`3 ^ h` nodes always misses some node at depth `h`: since the letters are unreadable
from `N`, an adversary may place the target there. -/
theorem exists_unvisited_node (V : Finset (ℕ × ℕ)) (h : ℕ) (hV : V.card < 3 ^ h) :
    ∃ w : List Letter, w.length = h ∧ follow w (2, 1) ∉ V := by
  by_contra hcon
  push_neg at hcon
  have hsub : depthNodes h ⊆ V := by
    intro p hp
    obtain ⟨w, hw, rfl⟩ := mem_depthNodes.mp hp
    exact hcon w hw
  have := Finset.card_le_card hsub
  rw [card_depthNodes] at this
  omega

/-- **A strict majority of the level is missed** by any searcher whose budget is below
half the level size. -/
theorem majority_unvisited (V : Finset (ℕ × ℕ)) (h : ℕ) (hV : 2 * V.card < 3 ^ h) :
    3 ^ h < 2 * ((depthNodes h) \ V).card := by
  have hsplit : ((depthNodes h) \ V).card + (depthNodes h ∩ V).card = (depthNodes h).card :=
    Finset.card_sdiff_add_card_inter _ _
  have hle : (depthNodes h ∩ V).card ≤ V.card :=
    Finset.card_le_card Finset.inter_subset_right
  rw [card_depthNodes] at hsplit
  omega

/-- **Adaptive searchers gain nothing.**  Model a searcher as a sequence of guessed
ascent words `S : ℕ → List Letter`; because the letters are unreadable from `N`
(`magnitude_probe_letterBlind`), the only feedback before a hit is "miss", so the
sequence of guesses is determined and the adversary may keep it consistent.  If the
searcher makes `k < 3 ^ h` guesses then some depth-`h` word is never guessed. -/
theorem adaptive_search_lower_bound (S : ℕ → List Letter) (k h : ℕ) (hk : k < 3 ^ h) :
    ∃ w : List Letter, w.length = h ∧ ∀ i < k, S i ≠ w := by
  by_contra hcon
  push_neg at hcon
  have hsub : words h ⊆ (Finset.range k).image S := by
    intro w hw
    obtain ⟨i, hi, hiw⟩ := hcon w ((mem_words_iff h w).mp hw)
    exact Finset.mem_image.mpr ⟨i, Finset.mem_range.mpr hi, hiw⟩
  have h1 : (words h).card ≤ ((Finset.range k).image S).card := Finset.card_le_card hsub
  have h2 : ((Finset.range k).image S).card ≤ k := by
    calc ((Finset.range k).image S).card ≤ (Finset.range k).card := Finset.card_image_le
      _ = k := Finset.card_range k
  rw [card_words] at h1
  omega

/-- Budget form of the adaptive bound: to be sure of hitting the depth-`h` target the
searcher must issue at least `3 ^ h` guesses. -/
theorem adaptive_search_budget (S : ℕ → List Letter) (k h : ℕ)
    (hcover : ∀ w : List Letter, w.length = h → ∃ i < k, S i = w) : 3 ^ h ≤ k := by
  by_contra hc
  push_neg at hc
  obtain ⟨w, hw, hmiss⟩ := adaptive_search_lower_bound S k h hc
  obtain ⟨i, hi, hiw⟩ := hcover w hw
  exact hmiss i hi hiw

/-! ### The cost threshold: accuracy `1/3` -/

/-- At per-step accuracy `1/2` the restarted guided ascent is cheaper than exhaustive
search at **every** depth: `h · 2 ^ h < 3 ^ h` for all `h`. -/
theorem restart_beats_exhaustive_half : ∀ h : ℕ, h * 2 ^ h < 3 ^ h := by
  intro h
  induction h with
  | zero => norm_num
  | succ h ih =>
      rcases Nat.lt_or_ge h 2 with hlt | hge
      · interval_cases h <;> norm_num
      · have hstep : 2 * (h + 1) ≤ 3 * h := by omega
        calc (h + 1) * 2 ^ (h + 1) = (2 * (h + 1)) * 2 ^ h := by ring
          _ ≤ (3 * h) * 2 ^ h := Nat.mul_le_mul_right _ hstep
          _ = 3 * (h * 2 ^ h) := by ring
          _ < 3 * 3 ^ h := (Nat.mul_lt_mul_left (by norm_num)).mpr ih
          _ = 3 ^ (h + 1) := by ring

/-- Above accuracy `1/3` the restart energy eventually falls below the exhaustive
cost `3 ^ h`: the guided ascent wins in the deep regime. -/
theorem guided_beats_exhaustive_of_gt_third {a : ℝ} (ha : 1 / 3 < a) :
    ∃ H : ℕ, ∀ h ≥ H, restartEnergy h a < 3 ^ h := by
  have ha0 : (0 : ℝ) < a := lt_trans (by norm_num) ha
  have h3a : (1 : ℝ) < 3 * a := by linarith
  set r : ℝ := (3 * a)⁻¹ with hr
  have hr0 : 0 ≤ r := by positivity
  have hr1 : r < 1 := by
    rw [hr, inv_lt_one₀ (by linarith)]
    exact h3a
  have hlim : Tendsto (fun n : ℕ => (n : ℝ) * r ^ n) atTop (nhds 0) :=
    tendsto_self_mul_const_pow_of_lt_one hr0 hr1
  obtain ⟨H, hH⟩ := eventually_atTop.mp (hlim.eventually (eventually_lt_nhds (by norm_num : (0:ℝ) < 1)))
  refine ⟨H, fun h hh => ?_⟩
  have hkey : (h : ℝ) * r ^ h < 1 := hH h hh
  have hpow : (0 : ℝ) < (3 * a) ^ h := pow_pos (by linarith) h
  have hrh : r ^ h = ((3 * a) ^ h)⁻¹ := by
    rw [hr, ← inv_pow]
  rw [hrh, ← div_eq_mul_inv, div_lt_one hpow] at hkey
  have hah : (0 : ℝ) < a ^ h := pow_pos ha0 h
  rw [restartEnergy, div_lt_iff₀ hah]
  calc (h : ℝ) < (3 * a) ^ h := hkey
    _ = 3 ^ h * a ^ h := by rw [mul_pow]

/-- Below accuracy `1/3` the restart energy eventually exceeds the exhaustive cost:
a low-accuracy probe is worse than brute force in the deep regime.  Together with
`guided_beats_exhaustive_of_gt_third` this pins the cost threshold at exactly the
reciprocal `1/3` of the branching base of `card_desc`. -/
theorem exhaustive_beats_guided_of_lt_third {a : ℝ} (ha0 : 0 < a) (ha : a < 1 / 3) :
    ∃ H : ℕ, ∀ h ≥ H, (3 : ℝ) ^ h < restartEnergy h a := by
  have h3a0 : (0 : ℝ) ≤ 3 * a := by linarith
  have h3a : 3 * a < 1 := by linarith
  have hlim : Tendsto (fun n : ℕ => (3 * a) ^ n) atTop (nhds 0) :=
    tendsto_pow_atTop_nhds_zero_of_lt_one h3a0 h3a
  obtain ⟨H, hH⟩ :=
    eventually_atTop.mp (hlim.eventually (eventually_lt_nhds (by norm_num : (0:ℝ) < 1)))
  refine ⟨max H 1, fun h hh => ?_⟩
  have hh1 : 1 ≤ h := le_trans (le_max_right H 1) hh
  have hhH : H ≤ h := le_trans (le_max_left H 1) hh
  have hkey : (3 * a) ^ h < 1 := hH h hhH
  have hah : (0 : ℝ) < a ^ h := pow_pos ha0 h
  have hone : (1 : ℝ) ≤ (h : ℝ) := by exact_mod_cast hh1
  rw [restartEnergy, lt_div_iff₀ hah]
  calc (3 : ℝ) ^ h * a ^ h = (3 * a) ^ h := by rw [mul_pow]
    _ < 1 := hkey
    _ ≤ (h : ℝ) := hone

/-- **Cost side of the closure.**  The threshold is exactly `1/3`: a per-step oracle of
accuracy above `1/3` eventually beats exhaustive search, one below `1/3` eventually
loses to it, and at accuracy `1/2` the guided ascent wins at every depth. -/
theorem guided_cost_threshold_one_third :
    (∀ a : ℝ, 1 / 3 < a → ∃ H : ℕ, ∀ h ≥ H, restartEnergy h a < 3 ^ h) ∧
      (∀ a : ℝ, 0 < a → a < 1 / 3 → ∃ H : ℕ, ∀ h ≥ H, (3 : ℝ) ^ h < restartEnergy h a) ∧
      (∀ h : ℕ, h * 2 ^ h < 3 ^ h) :=
  ⟨fun _ ha => guided_beats_exhaustive_of_gt_third ha,
    fun _ ha0 ha => exhaustive_beats_guided_of_lt_third ha0 ha,
    restart_beats_exhaustive_half⟩

end TwoTreeClosure