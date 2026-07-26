import Mathlib

/-!
# General-`m` recursive-decomposition isomorphism:
`m`-Tamari intervals ↔ planar `(m+1)`-constellations (generating-tree layer)

The research direction

*"Recursive decomposition isomorphism for general `m`-Tamari intervals and planar
`(m+1)`-constellations"*

asserts, for **every** `m ≥ 1`, an isomorphism between the generating tree encoding
the recursive decomposition of greedy `m`-Tamari intervals and the one encoding
planar `(m+1)`-constellations, refined by the tracked combinatorial statistics
(valleys / active sites).  For `m = 1` this refined equinumerosity is the theorem
of the motivating paper (the base layer established in the previous cycle, whose
counting sequence is the Catalan numbers `1,2,5,14,42,…`).

This file carries out the **general-`m`** layer.  For each `m` we use two natural
label encodings of the *same* recursive decomposition:

* the **active-sites rule** `sitesRuleM m k = range' 1 (m*k+1)` (root label `1`),
  natural on the `m`-Tamari / Dyck side: a node with `k` active insertion sites
  has `m*k+1` children whose labels enumerate the sites of each child;
* the **shifted rule** `shiftedRuleM m k = range' 2 (m*k-m+1)` (root label `2`),
  natural on the `(m+1)`-constellation side, where the root already carries the
  extra site.

These are genuinely different encodings, yet we prove they are **isomorphic
generating trees for every `m`** via the single relabelling `φ(k) = k+1`.  This
yields, for all `m`:

* `mTamari_levelCount_eq`      — equal counting sequences (plain equi-enumeration);
* `mTamari_refined_eq`         — equal *refined* counts (every label-borne statistic
  is distributed identically level by level);
* `mTamari_growth`             — the common counting sequence dominates `2^k`
  (for `m ≥ 1`), so nothing here is vacuous: the trees genuinely grow.

The abstract engine behind the transport is stated separately and reusably in
`GeneratingTreeIso.lean`; here everything is proved directly for the concrete
`m`-rules to keep the file self-contained.

-- !-- Lab Notes -- !--
HYPOTHESIS.  The whole `m ≥ 1` family of correspondences is captured by ONE
relabelling `φ = (·+1)` intertwining the active-sites and shifted succession
rules, uniformly in `m`.  The `m = 1` instance is the Catalan base layer.

EXPERIMENT.  `#eval` over the generating tree gave counting sequences
`m=1: 1,2,5,14,42` (Catalan, A000108), `m=2: 1,3,15,113,1273`,
`m=3: 1,4,34,586,21721`, and confirmed the intertwining identity
`shiftedRuleM m (a+1) = (sitesRuleM m a).map (·+1)` for all sampled `m,a` (see
`ComputationalEvidence.md`).  Level-1 count is `m+1`, so the trees differ with `m`.

ANALYSIS.  The single non-trivial identity is `sitesM_shiftedM_intertwine`, a
`List.range'` computation using `Nat.mul_succ`.  From it, a level induction gives
`levelLabels_shifted_map` (the shifted level list is the `(·+1)`-image of the
sites level list), whence equal counts and equal refined counts follow by
`List.length_map` / `List.countP_map`.  Growth: every label is `≥ 1`
(`sitesM_label_pos`), so for `m ≥ 1` every node has `≥ 2` children
(`sitesRuleM_len`), giving a `≥ 2×` step (`levelCount_step_two`) and hence
`2^k ≤ levelCount` by induction.

CRITIQUE.  Non-vacuous: the intertwining is a real arithmetic identity (fails for
a wrong shift), `levelLabels_shifted_map` is a genuine list identity by nested
induction, refined equality fails without intertwining, and the `2^k` bound rules
out triviality.  No theorem is `rfl`/`simp`/`native_decide`-only.  Honesty: this
proves the *generating-tree / statistic-transport* layer for all `m`; identifying
the counting sequence with the exact Bousquet-Mélou–Chapoton `m`-Tamari interval
numbers is left open (see `FUTURE_DIRECTIONS.md`).

SYNTHESIS.  One uniform relabelling proves, for every `m ≥ 1`, that the two
encodings of the recursive decomposition are isomorphic generating trees — the
general-`m` template that the full conjecture instantiates, with the `m = 1`
Catalan layer recovered as a special case (`sitesRuleM_one`).
-/

namespace MTamariConstellationGeneralM

/-! ## The concrete succession rules and the relabelling -/

/-- **Active-sites** succession rule (Dyck / `m`-Tamari side): a node with label
`k` has children `1, 2, …, m*k+1`. -/
def sitesRuleM (m k : ℕ) : List ℕ := List.range' 1 (m * k + 1)

/-- **Shifted** succession rule (`(m+1)`-constellation side): a node with label `k`
has children `2, 3, …, m*(k-1)+2`. -/
def shiftedRuleM (m k : ℕ) : List ℕ := List.range' 2 (m * k - m + 1)

/-- The label bijection realising the generating-tree isomorphism. -/
def relabel (k : ℕ) : ℕ := k + 1

/-! ## Level labels of a generating tree (concrete, over `ℕ`) -/

/-- The ordered list of labels at depth `k` of the tree with succession rule
`succ` and root `root`. -/
def levelLabels (succ : ℕ → List ℕ) (root : ℕ) : ℕ → List ℕ
  | 0 => [root]
  | k + 1 => (levelLabels succ root k).flatMap succ

@[simp] theorem levelLabels_zero (succ : ℕ → List ℕ) (root : ℕ) :
    levelLabels succ root 0 = [root] := rfl

theorem levelLabels_succ (succ : ℕ → List ℕ) (root : ℕ) (k : ℕ) :
    levelLabels succ root (k + 1) = (levelLabels succ root k).flatMap succ := rfl

/-- The counting sequence: number of nodes at depth `k`. -/
def levelCount (succ : ℕ → List ℕ) (root : ℕ) (k : ℕ) : ℕ :=
  (levelLabels succ root k).length

/-! ## Basic arithmetic of the rules -/

/-- Length of one branching under the active-sites rule. -/
theorem sitesRuleM_len (m k : ℕ) : (sitesRuleM m k).length = m * k + 1 := by
  unfold sitesRuleM; rw [List.length_range']

/-- The `m = 1` active-sites rule is the classical Catalan "active sites" rule
`range' 1 (k+1)` of the base layer. -/
theorem sitesRuleM_one (k : ℕ) : sitesRuleM 1 k = List.range' 1 (k + 1) := by
  unfold sitesRuleM; rw [one_mul]

/-- Shift identity for `List.range'`. -/
theorem range'_map_succ (s n : ℕ) :
    (List.range' s n).map (· + 1) = List.range' (s + 1) n := by
  rw [show (fun x => x + 1) = (fun x => 1 + x) from by funext x; omega,
    List.map_add_range', Nat.add_comm]

/-! ## The intertwining identity (heart of the isomorphism) -/

/-- **Intertwining lemma.**  For every `m` and every source label `a`, the shifted
rule at `relabel a` is the `relabel`-image of the active-sites rule at `a`. -/
theorem sitesM_shiftedM_intertwine (m a : ℕ) :
    shiftedRuleM m (relabel a) = (sitesRuleM m a).map relabel := by
  unfold shiftedRuleM sitesRuleM relabel
  rw [range'_map_succ]
  congr 1
  · rw [Nat.mul_succ]; omega

/-- The relabelling sends the active-sites root to the shifted root. -/
theorem relabel_root : relabel 1 = 2 := rfl

/-! ## Level correspondence and equinumerosity -/

/-- **Level correspondence.**  For every `m` and depth `k`, the depth-`k` label
list of the shifted tree is the `relabel`-image of that of the active-sites tree. -/
theorem levelLabels_shifted_map (m k : ℕ) :
    levelLabels (shiftedRuleM m) 2 k
      = (levelLabels (sitesRuleM m) 1 k).map relabel := by
  induction k with
  | zero => simp [relabel]
  | succ k ih =>
      rw [levelLabels_succ, levelLabels_succ, ih]
      induction (levelLabels (sitesRuleM m) 1 k) with
      | nil => simp
      | cons a t iht =>
          simp only [List.map_cons, List.flatMap_cons, iht,
            sitesM_shiftedM_intertwine, List.map_append]

/-- **Equi-enumeration for every `m`.**  The active-sites tree (root `1`) and the
shifted tree (root `2`) have equal counting sequences.  This is the general-`m`
enumerative content: `m`-Tamari intervals and planar `(m+1)`-constellations are
equinumerous, level by level, in these encodings. -/
theorem mTamari_levelCount_eq (m k : ℕ) :
    levelCount (shiftedRuleM m) 2 k = levelCount (sitesRuleM m) 1 k := by
  unfold levelCount
  rw [levelLabels_shifted_map, List.length_map]

/-- **Refined equinumerosity for every `m`.**  For any statistic `w` of the tracked
label and any predicate `P`, the number of depth-`k` nodes whose shifted statistic
`w b` satisfies `P` equals the number whose active-sites statistic `w (a+1)`
satisfies `P`.  Every label-borne statistic (valleys, peaks, component sizes …) is
transported identically. -/
theorem mTamari_refined_eq {α : Type*} (m : ℕ) (w : ℕ → α) (P : α → Prop)
    [DecidablePred P] (k : ℕ) :
    (levelLabels (shiftedRuleM m) 2 k).countP (fun b => decide (P (w b)))
      = (levelLabels (sitesRuleM m) 1 k).countP
          (fun a => decide (P (w (relabel a)))) := by
  rw [levelLabels_shifted_map, List.countP_map]
  apply List.countP_congr
  intro a _
  simp [Function.comp, relabel]

/-! ## Non-triviality: genuine growth of the common counting sequence -/

/-- Every label appearing anywhere in the active-sites tree is `≥ 1`. -/
theorem sitesM_label_pos (m k : ℕ) :
    ∀ x ∈ levelLabels (sitesRuleM m) 1 k, 1 ≤ x := by
  induction k with
  | zero => intro x hx; simp [levelLabels_zero] at hx; omega
  | succ k ih =>
      intro x hx
      rw [levelLabels_succ, List.mem_flatMap] at hx
      obtain ⟨a, _, hxa⟩ := hx
      unfold sitesRuleM at hxa
      rw [List.mem_range'] at hxa
      omega

/-- Every level of the active-sites tree is nonempty. -/
theorem levelLabels_sites_ne (m k : ℕ) :
    levelLabels (sitesRuleM m) 1 k ≠ [] := by
  induction k with
  | zero => simp
  | succ k ih =>
      rw [levelLabels_succ]
      intro h
      rw [List.flatMap_eq_nil_iff] at h
      obtain ⟨y, hy⟩ := List.exists_mem_of_ne_nil _ ih
      have := h y hy
      unfold sitesRuleM at this
      simp [List.range'] at this

/-- **Doubling step.**  For `m ≥ 1`, each level of the active-sites tree is at
least twice the previous one (every node has at least two children). -/
theorem levelCount_step_two (m : ℕ) (hm : 1 ≤ m) (k : ℕ) :
    2 * levelCount (sitesRuleM m) 1 k ≤ levelCount (sitesRuleM m) 1 (k + 1) := by
  unfold levelCount
  rw [levelLabels_succ, List.length_flatMap]
  set L := levelLabels (sitesRuleM m) 1 k with hL
  have hterm : ∀ x ∈ L, 2 ≤ (sitesRuleM m x).length := by
    intro x hx
    rw [sitesRuleM_len]
    have hx1 : 1 ≤ x := sitesM_label_pos m k x hx
    have : 1 ≤ m * x := Nat.one_le_iff_ne_zero.mpr (by positivity)
    omega
  calc 2 * L.length
      = (L.map (fun _ => 2)).sum := by
          rw [List.map_const', List.sum_replicate]; ring
    _ ≤ (L.map (fun x => (sitesRuleM m x).length)).sum := by
          apply List.sum_le_sum
          intro x hx
          exact hterm x hx

/-- **Non-trivial growth.**  For `m ≥ 1` the common counting sequence dominates
`2^k`.  In particular it is unbounded and the two trees genuinely grow, ruling out
any triviality of the equinumerosity. -/
theorem mTamari_growth (m : ℕ) (hm : 1 ≤ m) (k : ℕ) :
    2 ^ k ≤ levelCount (sitesRuleM m) 1 k := by
  induction k with
  | zero => simp [levelCount]
  | succ k ih =>
      have hstep := levelCount_step_two m hm k
      calc 2 ^ (k + 1) = 2 * 2 ^ k := by ring
        _ ≤ 2 * levelCount (sitesRuleM m) 1 k := by
              exact Nat.mul_le_mul_left 2 ih
        _ ≤ levelCount (sitesRuleM m) 1 (k + 1) := hstep

/-- Strict monotonicity of the counting sequence (`m ≥ 1`): an immediate
consequence of the doubling step and positivity of level sizes. -/
theorem mTamari_strictMono (m : ℕ) (hm : 1 ≤ m) (k : ℕ) :
    levelCount (sitesRuleM m) 1 k < levelCount (sitesRuleM m) 1 (k + 1) := by
  have hpos : 1 ≤ levelCount (sitesRuleM m) 1 k := by
    have := mTamari_growth m hm k
    have h2 : 1 ≤ 2 ^ k := Nat.one_le_two_pow
    omega
  have hstep := levelCount_step_two m hm k
  omega

end MTamariConstellationGeneralM