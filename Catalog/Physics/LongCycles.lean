import Mathlib

/-!
# Long nontrivial cycles in a Hamiltonian graph on `ZMod n`

This file formalizes a fragment of the *long nontrivial cycles conjecture* in the
concrete setting of a Hamiltonian graph whose vertex set is the cyclic group
`ZMod n`.

## Setting

* The vertex type is `V := ZMod n`.
* The *Hamiltonian frame* is the reference Hamiltonian cycle `0 ~ 1 ~ ⋯ ~ (n-1) ~ 0`.
  A pair `{i, j}` is a frame edge when the two vertices are cyclically consecutive,
  i.e. `FrameAdj i j`.
* The ambient graph is an arbitrary `G : SimpleGraph (ZMod n)` that *contains* the
  frame (`hframe : ∀ i, G.Adj i (i + 1)`).
* A *chord* is any edge of `G` that is not a frame edge (`IsChord`).
* A *cycle* is an injective cyclic sequence of length `≥ 3`: this is packaged as the
  structure `GraphCycle`, whose vertices are indexed by `ZMod len` so that the
  "wrap-around" adjacency `toFun (len-1) ~ toFun 0` is automatic (it is the case
  `i + 1 = 0` of the `adj` field).
* The reference Hamiltonian cycle itself is `hamiltonianCycle`, which has
  `len = n`.  We record that any cycle of length `< n` is *distinct* from it
  (`second_cycle_ne_hamiltonian`); this is the sense in which the cycles produced
  below are "second cycles".

## Main results

* `chordArcCycle` : every chord `{a, b}` determines a cycle whose length is
  `(b - a).val + 1`, which lies strictly between `2` and `n`.  In particular it is
  a genuine cycle (length `≥ 3`) that is different from the Hamiltonian cycle
  (length `< n`).
* `longSecondCycle` : if `G` has minimum degree `≥ 3` (every vertex has at least
  three neighbours), then there is a cycle of length `≥ n/2 + 1` that is distinct
  from the Hamiltonian cycle.
* `everyVertexOnSecondCycle` : under the same minimum-degree hypothesis, every
  vertex lies on some second cycle.

## Proof strategy (no circular dependencies)

The core construction is `arcCycle`: given a starting vertex `a`, a step
`2 ≤ k ≤ n - 2`, and the closing edge `G.Adj (a + k) a`, it walks along the frame
`a, a+1, …, a+k` and then closes up with the given edge.  All interior edges are
frame edges (hence in `G`); the single closing edge is supplied by the caller.

* `chordArcCycle` feeds a chord `{a, b}` into `arcCycle` with step `k = (b - a).val`.
* `longSecondCycle` extracts a chord from the degree hypothesis
  (`exists_chord_at`: the frame already uses up the two neighbours `v ± 1`, so a
  third neighbour must be a chord endpoint), builds the two arc cycles for `{a, b}`
  and `{b, a}` of lengths `k + 1` and `(n - k) + 1`, and keeps the longer one.
  Since the two lengths sum to `n + 2`, the larger is `≥ n/2 + 1`.  This argument
  never refers to the statement of `longSecondCycle` itself.
* `everyVertexOnSecondCycle` applies `exists_chord_at` at the given vertex `v`; the
  resulting arc cycle starts at `v`, so `v` lies on it.

## Next steps toward the full conjecture

The general conjecture asserts the existence of a *long* second cycle in far more
general graphs (arbitrary Hamiltonian graphs, not just those on `ZMod n` with the
standard frame).  Natural continuations are: strengthen `longSecondCycle` to a
sharp `2n/3`-type bound using several chords and their crossing pattern; drop the
cyclic-group indexing in favour of an abstract Hamiltonian cycle in a general
`SimpleGraph`; and analyse how chords may be combined (rerouting along several
chords) to lengthen the second cycle beyond a single arc.
-/

namespace LongCycles

/-- The Hamiltonian *frame* adjacency on `ZMod n`: two vertices are frame-adjacent
iff they are cyclically consecutive. -/
def FrameAdj {n : ℕ} (i j : ZMod n) : Prop := j = i + 1 ∨ i = j + 1

/-- A cycle in `G`: an injective cyclic sequence of length `≥ 3`.  The vertices are
indexed by `ZMod len`, so consecutive-vertex adjacency (`adj`) automatically
includes the wrap-around edge `toFun (len - 1) ~ toFun 0`. -/
structure GraphCycle {n : ℕ} (G : SimpleGraph (ZMod n)) where
  /-- The number of vertices of the cycle. -/
  len : ℕ
  /-- A cycle has at least three vertices. -/
  three_le : 3 ≤ len
  /-- The vertices of the cycle, listed cyclically. -/
  toFun : ZMod len → ZMod n
  /-- The vertices are pairwise distinct. -/
  inj : Function.Injective toFun
  /-- Consecutive vertices (cyclically) are adjacent in `G`. -/
  adj : ∀ i : ZMod len, G.Adj (toFun i) (toFun (i + 1))

/-- A *chord* of `G` (relative to the frame): an edge of `G` that is not a frame edge. -/
def IsChord {n : ℕ} (G : SimpleGraph (ZMod n)) (a b : ZMod n) : Prop :=
  G.Adj a b ∧ ¬ FrameAdj a b

/-- The vertex sequence of the arc cycle starting at `a` with step `k`:
`j ↦ a + j` for `j = 0, 1, …, k`. -/
def arcToFun {n : ℕ} (a : ZMod n) (k : ℕ) : ZMod (k + 1) → ZMod n :=
  fun j => a + (j.val : ZMod n)

/-
The arc sequence `a, a+1, …, a+k` has distinct entries as long as `k + 1 ≤ n`.
-/
lemma arcToFun_injective {n : ℕ} [NeZero n] (a : ZMod n) (k : ℕ) (hkn : k + 1 ≤ n) :
    Function.Injective (arcToFun a k) := by
  intro i j hij
  have h_eq : (i.val : ZMod n) = (j.val : ZMod n) := by
    unfold arcToFun at hij; aesop;
  rw [ ZMod.natCast_eq_natCast_iff ] at h_eq;
  exact ZMod.val_injective _ <| Nat.mod_eq_of_lt ( show i.val < n from lt_of_lt_of_le ( ZMod.val_lt i ) hkn ) ▸ Nat.mod_eq_of_lt ( show j.val < n from lt_of_lt_of_le ( ZMod.val_lt j ) hkn ) ▸ h_eq

/-
Consecutive vertices of the arc cycle are adjacent: interior steps are frame
edges (supplied by `hframe`), and the single closing step `a + k ↦ a` uses `hclose`.
-/
lemma arcToFun_adj {n : ℕ} [NeZero n] (G : SimpleGraph (ZMod n))
    (hframe : ∀ i : ZMod n, G.Adj i (i + 1))
    (a : ZMod n) (k : ℕ) (hkn : k + 2 ≤ n)
    (hclose : G.Adj (a + (k : ZMod n)) a) :
    ∀ i : ZMod (k + 1), G.Adj (arcToFun a k i) (arcToFun a k (i + 1)) := by
  intro i
  by_cases h_m : i.val < k;
  · convert hframe _ using 2;
    unfold arcToFun; norm_num [ ZMod.val_add, h_m ] ;
    erw [ Nat.mod_eq_of_lt ];
    · erw [ ZMod.val_cast_of_lt ] <;> norm_num [ add_assoc ] ; linarith;
    · rcases k with ( _ | _ | k ) <;> simp_all +arith +decide [ ZMod.val ];
  · -- Since $¬i.val < k$, we must have $i.val = k$.
    have h_m_eq : i.val = k := by
      exact le_antisymm ( Nat.le_of_lt_succ i.val_lt ) ( not_lt.mp h_m );
    simp [arcToFun, h_m_eq];
    convert hclose using 1;
    rw [ show i = -1 from by { exact eq_neg_of_add_eq_zero_left <| by { rw [ ← ZMod.natCast_zmod_val i ] ; aesop } } ] ; norm_num

/-- The **arc cycle**: walk along the frame from `a` to `a + k`, then close up with
the edge `G.Adj (a + k) a`.  Requires `2 ≤ k ≤ n - 2` (so `3 ≤ len = k + 1 < n`). -/
def arcCycle {n : ℕ} [NeZero n] (G : SimpleGraph (ZMod n))
    (hframe : ∀ i : ZMod n, G.Adj i (i + 1))
    (a : ZMod n) (k : ℕ) (hk2 : 2 ≤ k) (hkn : k + 2 ≤ n)
    (hclose : G.Adj (a + (k : ZMod n)) a) : GraphCycle G where
  len := k + 1
  three_le := by omega
  toFun := arcToFun a k
  inj := arcToFun_injective a k (by omega)
  adj := arcToFun_adj G hframe a k hkn hclose

/-- The reference Hamiltonian cycle `0 ~ 1 ~ ⋯ ~ (n-1) ~ 0`, of length `n`. -/
def hamiltonianCycle {n : ℕ} (G : SimpleGraph (ZMod n)) (hn : 3 ≤ n)
    (hframe : ∀ i : ZMod n, G.Adj i (i + 1)) : GraphCycle G where
  len := n
  three_le := hn
  toFun := id
  inj := Function.injective_id
  adj := fun i => hframe i

/-- Frame adjacency is symmetric. -/
lemma frameAdj_symm {n : ℕ} {a b : ZMod n} (h : FrameAdj a b) : FrameAdj b a := by
  rcases h with h | h
  · exact Or.inr h
  · exact Or.inl h

/-- The chord relation is symmetric. -/
lemma chord_symm {n : ℕ} {G : SimpleGraph (ZMod n)} {a b : ZMod n} (h : IsChord G a b) :
    IsChord G b a := ⟨h.1.symm, fun hf => h.2 (frameAdj_symm hf)⟩

/-- For a chord `{a, b}`, the cyclic distance `(b - a).val` from `a` to `b` lies
strictly between `1` and `n - 1`, i.e. `2 ≤ (b - a).val ≤ n - 2`.  Indeed `a ≠ b`
rules out distance `0`, and *not* being a frame edge rules out distances `1`
(`b = a + 1`) and `n - 1` (`a = b + 1`). -/
lemma chord_val_bounds {n : ℕ} [NeZero n] {G : SimpleGraph (ZMod n)} {a b : ZMod n}
    (hchord : IsChord G a b) : 2 ≤ (b - a).val ∧ (b - a).val + 2 ≤ n := by
  obtain ⟨h_ne, h_not_frame⟩ := hchord;
  have h_k_ge_2 : (b - a).val ≠ 0 ∧ (b - a).val ≠ 1 ∧ (b - a).val ≠ n - 1 := by
    refine' ⟨ _, _, _ ⟩ <;> intro h_eq <;> simp_all +decide [ FrameAdj ];
    · simp_all +decide [ sub_eq_zero ];
    · rw [ ZMod.val_eq_one ] at h_eq;
      · exact h_not_frame.1 ( by linear_combination' h_eq );
      · contrapose! h_not_frame; interval_cases n <;> simp_all +decide ;
        fin_cases a ; fin_cases b ; trivial;
    · -- From `h_eq`, we have `(b - a).val = n - 1`. Since `n` is a positive integer, this implies `b - a = -1`.
      have h_ba_neg_one : b - a = -1 := by
        rcases n with ( _ | _ | n ) <;> simp_all +decide;
        exact ZMod.val_injective _ <| by aesop;
      exact h_not_frame.2 ( by linear_combination' -h_ba_neg_one );
  grind

/-- For `a ≠ b`, the two cyclic distances `(b - a).val` and `(a - b).val` sum to `n`
(they are `x.val` and `(-x).val` for the nonzero element `x = b - a`). -/
lemma val_neg_sum {n : ℕ} [NeZero n] {a b : ZMod n} (hab : a ≠ b) :
    (b - a).val + (a - b).val = n := by
  rw [ ← neg_sub, ZMod.neg_val ];
  grind

/-- **Lemma 1 (chordArcCycle).**  Any chord `{a, b}` determines a cycle of length
`(b - a).val + 1`, which is strictly between `2` and `n`; in particular it is a
genuine cycle (length `> 2`) that is different from the Hamiltonian cycle
(length `< n`, cf. `second_cycle_ne_hamiltonian`).  The cycle passes through `a`. -/
theorem chordArcCycle {n : ℕ} [NeZero n] (G : SimpleGraph (ZMod n))
    (hframe : ∀ i : ZMod n, G.Adj i (i + 1)) {a b : ZMod n} (hchord : IsChord G a b) :
    ∃ c : GraphCycle G,
      c.len = (b - a).val + 1 ∧ 2 < c.len ∧ c.len < n ∧ a ∈ Set.range c.toFun := by
  obtain ⟨hk2, hkn⟩ := chord_val_bounds hchord
  have hclose : G.Adj (a + (((b - a).val : ℕ) : ZMod n)) a := by
    have h : a + (((b - a).val : ℕ) : ZMod n) = b := by rw [ZMod.natCast_zmod_val]; ring
    rw [h]; exact hchord.1.symm
  refine ⟨arcCycle G hframe a ((b - a).val) hk2 hkn hclose, rfl, ?_, ?_, ?_⟩
  · show 2 < (b - a).val + 1; omega
  · show (b - a).val + 1 < n; omega
  · exact ⟨0, by simp [arcCycle, arcToFun]⟩

/-- From minimum degree `≥ 3`: at most the two frame vertices `v + 1` and `v - 1`
can be frame-adjacent to `v`, so among the (at least) three neighbours of `v` some
neighbour `w` is not frame-adjacent, i.e. `{v, w}` is a chord.  (The frame edges
themselves are not needed here: minimum degree three alone forces a chord.) -/
lemma exists_chord_at {n : ℕ} [NeZero n] {G : SimpleGraph (ZMod n)}
    (hdeg : ∀ v : ZMod n, 3 ≤ (G.neighborSet v).ncard) (v : ZMod n) :
    ∃ w : ZMod n, IsChord G v w := by
  by_contra! h;
  -- By assumption, $G.neighborSet v \subseteq {v + 1, v - 1}$.
  have h_subset : G.neighborSet v ⊆ {v + 1, v - 1} := by
    intro w hw; specialize h w; simp_all +decide [ IsChord ] ;
    cases h <;> simp_all +decide [ eq_sub_iff_add_eq ];
  exact absurd ( Set.ncard_le_ncard h_subset ) ( by have := hdeg v; exact not_le_of_gt ( lt_of_le_of_lt ( Set.ncard_insert_le _ _ ) ( by norm_num; linarith ) ) ) ;

/-- **Lemma 2 (longSecondCycle).**  If `G` contains the frame and has minimum
degree `≥ 3`, then there exists a cycle distinct from the Hamiltonian one (its
length is `< n`) of length at least `n / 2 + 1`.

The proof takes any chord `{a, b}` (which exists by `exists_chord_at`), forms the
two arc cycles of lengths `(b - a).val + 1` and `(a - b).val + 1` (via
`chordArcCycle`), and keeps the longer one: the two lengths sum to `n + 2`, so the
larger is at least `n / 2 + 1`.  This does not use the statement being proved. -/
theorem longSecondCycle {n : ℕ} [NeZero n] (G : SimpleGraph (ZMod n))
    (hframe : ∀ i : ZMod n, G.Adj i (i + 1))
    (hdeg : ∀ v : ZMod n, 3 ≤ (G.neighborSet v).ncard) :
    ∃ c : GraphCycle G, n / 2 + 1 ≤ c.len ∧ c.len < n := by
  obtain ⟨b, hchord⟩ := exists_chord_at hdeg 0
  obtain ⟨c1, hlen1, _, hlt1, _⟩ := chordArcCycle G hframe hchord
  obtain ⟨c2, hlen2, _, hlt2, _⟩ := chordArcCycle G hframe (chord_symm hchord)
  have hne : (0 : ZMod n) ≠ b := fun h => (hchord.1.ne) h
  have hsum : (b - 0).val + (0 - b).val = n := val_neg_sum hne
  by_cases h : n / 2 + 1 ≤ c1.len
  · exact ⟨c1, h, hlt1⟩
  · exact ⟨c2, by omega, hlt2⟩

/-- **Lemma 3 (everyVertexOnSecondCycle).**  Under the same hypotheses, every
vertex `v` lies on some second cycle (a cycle of length `< n`, hence distinct from
the Hamiltonian cycle).  Apply `exists_chord_at` at `v`; the resulting arc cycle
starts at `v`. -/
theorem everyVertexOnSecondCycle {n : ℕ} [NeZero n] (G : SimpleGraph (ZMod n))
    (hframe : ∀ i : ZMod n, G.Adj i (i + 1))
    (hdeg : ∀ v : ZMod n, 3 ≤ (G.neighborSet v).ncard) (v : ZMod n) :
    ∃ c : GraphCycle G, 2 < c.len ∧ c.len < n ∧ v ∈ Set.range c.toFun := by
  obtain ⟨w, hchord⟩ := exists_chord_at hdeg v
  obtain ⟨c, _, h2, hlt, hmem⟩ := chordArcCycle G hframe hchord
  exact ⟨c, h2, hlt, hmem⟩

/-- Any cycle of length `< n` is genuinely different from the Hamiltonian cycle
(which has length `n`).  This justifies calling the cycles above "second cycles". -/
theorem second_cycle_ne_hamiltonian {n : ℕ} (G : SimpleGraph (ZMod n)) (hn : 3 ≤ n)
    (hframe : ∀ i : ZMod n, G.Adj i (i + 1)) (c : GraphCycle G) (hc : c.len < n) :
    c ≠ hamiltonianCycle G hn hframe := by
  intro h
  have : c.len = n := congrArg GraphCycle.len h
  omega

end LongCycles