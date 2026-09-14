import Mathlib
import Probability.CollatzBerggrenFibre

/-!
# The Collatz–Berggren bridge, V: what *does* transfer — a ternary subtree

Files I–IV proved four independent obstructions to the moonshot hypothesis: the
inverse Syracuse tree is not ternary, it is rank one, it has a self-loop, and it
admits no polynomial invariant.  This final file establishes the *positive*
residue of the hypothesis, which is the strongest statement that survives the
obstructions:

> The Berggren ternary branching **embeds** into the inverse Collatz tree as a
> subtree of live, strictly increasing nodes — the transfer exists as a
> *branching embedding*, even though (by Files I–IV) it can never be a
> branching isomorphism and never carries an invariant.

The construction is explicit and computable.  Over a live node `n` (odd,
`3 ∤ n`) the predecessor fibre is the `L`-orbit `predFam n 0, predFam n 1, …`
whose residues mod `3` cycle with period `3` (`predFam_mod_three`).  Hence among
the indices `1, …, 5` at least three give *live* predecessors, and
`liveIdx` selects three of them uniformly in the residue `predFam n 0 % 3`.

Main results.

* `predFam_mod_three` — the residue of the fibre is `(m₀ + j) mod 3`.
* `climb_pred`, `climb_live`, `climb_gt` — each of the three chosen lifts is a
  genuine Collatz predecessor, again live, and strictly larger than the node.
* `climb_injective_letters` — the three lifts of a node are pairwise distinct,
  so the branching really is ternary at each node of the subtree.
* `embed_edge`, `embed_live`, `embed_lt`, `embed_children_distinct` — the
  induced map from Berggren words to odd numbers is an edge-preserving,
  strictly increasing, locally injective embedding of the ternary tree.
* `berggren_ternary_subtree_of_collatz` — packaged statement.
-/

namespace CollatzBerggren

/-! ## The residue clock of a fibre -/

/-- Along the fibre of `n`, the residue mod `3` advances by one at each step:
`predFam n j ≡ predFam n 0 + j (mod 3)`.  Exactly one predecessor in three is a
dead (multiple of `3`) node. -/
theorem predFam_mod_three {n : ℕ} (h1 : n % 3 ≠ 0) (j : ℕ) :
    predFam n j % 3 = (predFam n 0 + j) % 3 := by
  induction j with
  | zero => simp
  | succ i ih =>
      have hstep := predFam_succ h1 i
      omega

/-- The three indices used to lift a node, as a function of the residue
`predFam n 0 % 3`.  Each choice avoids the dead index and is `≥ 1`. -/
def liveIdx (r : ℕ) : BerggrenStep → ℕ
  | .A => if r = 2 then 2 else 1
  | .B => if r = 0 then 2 else 3
  | .C => if r = 0 then 4 else if r = 1 then 4 else 5

theorem liveIdx_pos (r : ℕ) (s : BerggrenStep) : 1 ≤ liveIdx r s := by
  cases s <;> unfold liveIdx <;> split_ifs <;> norm_num

theorem liveIdx_injective {r : ℕ} (hr : r < 3) {s t : BerggrenStep} (h : s ≠ t) :
    liveIdx r s ≠ liveIdx r t := by
  interval_cases r <;> cases s <;> cases t <;> simp_all [liveIdx]

/-- The chosen index always avoids the dead residue. -/
theorem liveIdx_avoids_dead (m : ℕ) (s : BerggrenStep) :
    (m + liveIdx (m % 3) s) % 3 ≠ 0 := by
  have hr : m % 3 = 0 ∨ m % 3 = 1 ∨ m % 3 = 2 := by omega
  cases s <;> rcases hr with hr | hr | hr <;> simp only [liveIdx, hr] <;> norm_num <;> omega

/-! ## The three lifts -/

/-- The lift of a live node `n` along the Berggren letter `s`. -/
def climb (n : ℕ) (s : BerggrenStep) : ℕ := predFam n (liveIdx (predFam n 0 % 3) s)

/-- Each lift is a genuine Collatz predecessor. -/
theorem climb_pred {n : ℕ} (hn : Odd n) (h1 : n % 3 ≠ 0) (s : BerggrenStep) :
    SyrPred (climb n s) n := predFam_mem hn h1 _

/-- Each lift is odd. -/
theorem climb_odd {n : ℕ} (hn : Odd n) (h1 : n % 3 ≠ 0) (s : BerggrenStep) :
    Odd (climb n s) := (climb_pred hn h1 s).odd_left

/-- Each lift is again a live node, so the construction can be iterated. -/
theorem climb_live {n : ℕ} (h1 : n % 3 ≠ 0) (s : BerggrenStep) :
    climb n s % 3 ≠ 0 := by
  have h := predFam_mod_three h1 (liveIdx (predFam n 0 % 3) s)
  have := liveIdx_avoids_dead (predFam n 0) s
  simp only [climb]
  omega

/-- Each lift strictly exceeds the node: the subtree grows. -/
theorem climb_gt {n : ℕ} (hn : Odd n) (h1 : n % 3 ≠ 0) (s : BerggrenStep) :
    n < climb n s := by
  have hpos : 0 < n := hn.pos
  -- the first index is at least 1, hence `3 · climb + 1 = 2 ^ (k₀ + 2j) n ≥ 8 n`
  have hidx : 1 ≤ liveIdx (predFam n 0 % 3) s := liveIdx_pos _ s
  set j := liveIdx (predFam n 0 % 3) s with hj
  have hval := three_mul_predFam_add_one h1 j
  have hexp : 8 * n ≤ 2 ^ (startExp n + 2 * j) * n := by
    have h8 : (8 : ℕ) ≤ 2 ^ (startExp n + 2 * j) := by
      have : (3 : ℕ) ≤ startExp n + 2 * j := by
        have := startExp_pos n
        omega
      calc (8 : ℕ) = 2 ^ 3 := by norm_num
        _ ≤ 2 ^ (startExp n + 2 * j) := Nat.pow_le_pow_right (by norm_num) this
    exact Nat.mul_le_mul_right n h8
  simp only [climb, ← hj]
  omega

/-- Distinct Berggren letters give distinct lifts: the branching is ternary. -/
theorem climb_injective_letters {n : ℕ} (h1 : n % 3 ≠ 0) {s t : BerggrenStep}
    (hst : s ≠ t) : climb n s ≠ climb n t := by
  have hr : predFam n 0 % 3 < 3 := Nat.mod_lt _ (by norm_num)
  have hidx := liveIdx_injective hr hst
  intro hcon
  exact hidx ((predFam_strictMono h1).injective hcon)

/-! ## The embedding of the free ternary tree -/

/-- The embedding of Berggren words into odd numbers, started at the root `1`. -/
def embed (w : List BerggrenStep) : ℕ := w.foldl climb 1

@[simp] theorem embed_nil : embed [] = 1 := rfl

theorem embed_concat (w : List BerggrenStep) (s : BerggrenStep) :
    embed (w ++ [s]) = climb (embed w) s := by
  simp [embed]

/-- Every node of the embedded tree is odd and live. -/
theorem embed_odd_live (w : List BerggrenStep) : Odd (embed w) ∧ embed w % 3 ≠ 0 := by
  induction w using List.reverseRecOn with
  | nil => exact ⟨odd_one, by norm_num⟩
  | append_singleton l s ih =>
      rw [embed_concat]
      exact ⟨climb_odd ih.1 ih.2 s, climb_live ih.2 s⟩

theorem embed_odd (w : List BerggrenStep) : Odd (embed w) := (embed_odd_live w).1

theorem embed_live (w : List BerggrenStep) : embed w % 3 ≠ 0 := (embed_odd_live w).2

/-- **Edges go to edges.**  The child of a Berggren word maps to a Collatz
predecessor of the image of the word. -/
theorem embed_edge (w : List BerggrenStep) (s : BerggrenStep) :
    SyrPred (embed (w ++ [s])) (embed w) := by
  rw [embed_concat]
  exact climb_pred (embed_odd w) (embed_live w) s

/-- The embedding strictly increases along every edge. -/
theorem embed_lt (w : List BerggrenStep) (s : BerggrenStep) :
    embed w < embed (w ++ [s]) := by
  rw [embed_concat]
  exact climb_gt (embed_odd w) (embed_live w) s

/-- The three children of a node have distinct images. -/
theorem embed_children_distinct (w : List BerggrenStep) {s t : BerggrenStep} (hst : s ≠ t) :
    embed (w ++ [s]) ≠ embed (w ++ [t]) := by
  rw [embed_concat, embed_concat]
  exact climb_injective_letters (embed_live w) hst

/-- **Positive transfer theorem.**  The free ternary tree on the Berggren
alphabet embeds into the inverse Collatz tree: there is an explicit map from
Berggren words to odd numbers which sends every tree edge to a Collatz
predecessor edge, keeps every node live (so the construction never stalls),
strictly increases along edges, and is injective on the three children of each
node.  Together with Files I–IV this pins the truth exactly: the ternary
Berggren branching transfers as a *subtree*, never as an isomorphism, and the
Lorentz invariant does not transfer at all. -/
theorem berggren_ternary_subtree_of_collatz :
    ∃ F : List BerggrenStep → ℕ,
      F [] = 1 ∧
      (∀ w, Odd (F w) ∧ F w % 3 ≠ 0) ∧
      (∀ w s, SyrPred (F (w ++ [s])) (F w)) ∧
      (∀ w s, F w < F (w ++ [s])) ∧
      (∀ w s t, s ≠ t → F (w ++ [s]) ≠ F (w ++ [t])) :=
  ⟨embed, embed_nil, embed_odd_live, embed_edge, embed_lt,
    fun _ _ _ h => embed_children_distinct _ h⟩

/-- The first two levels of the embedded tree over the root `1`. -/
theorem embed_root_children :
    embed [.A] = 5 ∧ embed [.B] = 85 ∧ embed [.C] = 341 := by
  refine ⟨?_, ?_, ?_⟩ <;>
    norm_num [embed, climb, liveIdx, predFam, startExp]

end CollatzBerggren