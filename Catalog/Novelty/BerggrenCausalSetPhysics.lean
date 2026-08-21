import Novelty.BerggrenCausalSet

/-!
# The Berggren causal set II: Lorentz symmetry, null cone, and the dimension verdict

Building on `Novelty.BerggrenCausalSet` (which proves that the Berggren tree of primitive
Pythagorean triples satisfies the causal-set axioms of Bombelli–Lee–Meyer–Sorkin), this
file investigates the *physical* half of the moonshot hypothesis: is the Berggren causal
set a discrete model of `2+1`-dimensional Minkowski space?

The answer is a precise, two-sided **no**, with a substantial positive residue.

## Positive results (the geometry really is Lorentzian)

* `event_null` — every event is a future-directed null vector of the Lorentz form
  `Q(a,b,c) = a² + b² − c²`: the causal set lives exactly on the null cone of `ℝ^{2,1}`.
* `matOf_lorentz`, `wordMat_lorentz` — each Berggren move is an integral Lorentz
  transformation `Mᵀ Q M = Q`, and so is every word in the moves: the tree carries a
  genuine action of a subgroup of `O(2,1;ℤ)`.
* `wordMat_action` — the group action is the tree: the matrix of a word transports the
  root vector to the event reached by that word.
* `wordMat_det` — the determinant of a word is `(−1)^{#B}`: the middle Berggren move is
  the orientation-reversing generator, the other two lie in `SO(2,1;ℤ)`.
* `dir_mem_circle`, `dir_injective` — the *celestial map* sending an event to its null
  direction `(a/c, b/c)` is injective into the rational points of the unit circle.  The
  conformal boundary of the model is therefore a set of rational points of the celestial
  circle, one for each event.

## Negative results (the order is not the Minkowski causal order)

* `distinct_events_spacelike` — **any two distinct events are spacelike separated**:
  `Q(u − t) > 0`.  In particular `edge_spacelike` and `causal_pairs_spacelike`: the tree
  edges, i.e. the causal relations of the causal set, are *spacelike* intervals of the
  ambient Minkowski space.  The Berggren order is a genealogical order, not the induced
  Minkowski causal order — the identification of the two, which the hypothesis proposes,
  is false.
* `interval_growth_linear`, `not_myrheim_meyer_dim_two` — the Alexandrov intervals have
  exactly `k+1` elements at proper time `k`.  A causal set faithfully embedded in
  `d`-dimensional Minkowski space has interval cardinality growing like the volume,
  `≍ kᵈ`.  Here the growth is exactly linear, so no Myrheim–Meyer dimension `≥ 2` is
  possible: the effective dimension of the Berggren causal set is `1`, not `2+1`.
* `level_growth_superpolynomial` — the silver/`3^k` growth of the tree is *branching*, not
  volume: level cardinalities beat every polynomial, which is incompatible with the
  polynomial volume growth of a fixed-dimensional Minkowski slice.
-/

namespace BerggrenCausalSet

open scoped Matrix

/-! ## Part A. The null cone -/

/-- Every event is a null vector of the Lorentz form `a² + b² − c²`. -/
theorem event_null {t : Event} (h : IsEvent t) : lorentzQ t.1 t.2.1 t.2.2 = 0 :=
  (isPythag_iff_lorentzQ_zero _ _ _).mp h.1

/-! ## Part B. The Lorentz group action -/

/-- The integral Lorentz matrix of a Berggren move. -/
def matOf : BerggrenStep → Matrix (Fin 3) (Fin 3) ℤ
  | .A => B₁_mat
  | .B => B₂_mat
  | .C => B₃_mat

/-- Each Berggren move is an integral Lorentz transformation of signature `(2,1)`. -/
theorem matOf_lorentz (s : BerggrenStep) : (matOf s)ᵀ * QLor * matOf s = QLor := by
  cases s
  · show (B₁_mat)ᵀ * QLor * B₁_mat = QLor; decide
  · show (B₂_mat)ᵀ * QLor * B₂_mat = QLor; decide
  · show (B₃_mat)ᵀ * QLor * B₃_mat = QLor; decide

/-- The coordinate vector of an event. -/
def vec (t : Event) : Fin 3 → ℤ := ![t.1, t.2.1, t.2.2]

theorem matOf_mulVec (s : BerggrenStep) (t : Event) :
    (matOf s).mulVec (vec t) = vec (applyStep s t) := by
  obtain ⟨a, b, c⟩ := t
  funext i
  fin_cases i <;>
    cases s <;>
      simp [matOf, vec, B₁_mat, B₂_mat, B₃_mat, bergA, bergB, bergC, Matrix.mulVec,
        dotProduct, Fin.sum_univ_three] <;> ring

/-- The Lorentz matrix of a word of Berggren moves (leftmost move applied first). -/
def wordMat : List BerggrenStep → Matrix (Fin 3) (Fin 3) ℤ
  | [] => 1
  | s :: w => wordMat w * matOf s

/-- **The tree is a group action**: the matrix of a word transports an event to the event
reached by running that word. -/
theorem wordMat_action (w : List BerggrenStep) (t : Event) :
    (wordMat w).mulVec (vec t) = vec (run w t) := by
  induction w generalizing t with
  | nil => simp [wordMat, vec]
  | cons s w ih =>
      rw [wordMat, run_cons, ← ih, ← Matrix.mulVec_mulVec, matOf_mulVec]

/-- **Every word of Berggren moves is an integral Lorentz transformation.** -/
theorem wordMat_lorentz (w : List BerggrenStep) :
    (wordMat w)ᵀ * QLor * wordMat w = QLor := by
  induction w with
  | nil => simp [wordMat]
  | cons s w ih =>
      have : (wordMat w * matOf s)ᵀ * QLor * (wordMat w * matOf s)
          = (matOf s)ᵀ * ((wordMat w)ᵀ * QLor * wordMat w) * matOf s := by
        rw [Matrix.transpose_mul]; noncomm_ring
      rw [wordMat, this, ih, matOf_lorentz]

/-- The determinant of a Berggren word is `(−1)` to the number of middle moves: `B` is the
orientation-reversing generator, `A` and `C` lie in `SO(2,1;ℤ)`. -/
theorem wordMat_det (w : List BerggrenStep) :
    (wordMat w).det = (-1) ^ (w.count BerggrenStep.B) := by
  induction w with
  | nil => simp [wordMat]
  | cons s w ih =>
      rw [wordMat, Matrix.det_mul, ih, List.count_cons]
      cases s
      · simp [matOf, det_B₁]
      · simp [matOf, det_B₂, pow_succ]
      · simp [matOf, det_B₃]

/-! ## Part C. Primitive events and the celestial circle -/

/-- A *primitive* event: an event whose legs are coprime, i.e. a node of the Berggren tree
of primitive Pythagorean triples. -/
def IsPrimEvent (t : Event) : Prop := IsEvent t ∧ Int.gcd t.1 t.2.1 = 1

theorem root_isPrimEvent : IsPrimEvent root := ⟨root_isEvent, by decide⟩

theorem step_isPrimEvent (s : BerggrenStep) {t : Event} (h : IsPrimEvent t) :
    IsPrimEvent (applyStep s t) := by
  obtain ⟨he, hg⟩ := h
  refine ⟨step_isEvent s he, ?_⟩
  obtain ⟨a, b, c⟩ := t
  cases s
  · exact bergA_prim a b c he.1 hg
  · exact bergB_prim a b c he.1 hg
  · exact bergC_prim a b c he.1 hg

theorem run_isPrimEvent (w : List BerggrenStep) {t : Event} (h : IsPrimEvent t) :
    IsPrimEvent (run w t) := by
  induction w generalizing t with
  | nil => simpa using h
  | cons s w ih => exact ih (step_isPrimEvent s h)

theorem eq_of_sq_eq_sq_of_pos {x y : ℤ} (hx : 0 < x) (hy : 0 < y) (h : x ^ 2 = y ^ 2) :
    x = y := by
  have h1 : (x - y) * (x + y) = 0 := by linear_combination h
  rcases mul_eq_zero.mp h1 with h2 | h2 <;> omega

/-- **Rigidity of null rays.**  Two primitive events on the same null ray coincide. -/
theorem prim_ray_eq {t u : Event} (ht : IsPrimEvent t) (hu : IsPrimEvent u)
    (h1 : t.1 * u.2.2 = u.1 * t.2.2) (h2 : t.2.1 * u.2.2 = u.2.1 * t.2.2) : t = u := by
  obtain ⟨⟨_, ha, hb, hc⟩, hg⟩ := ht
  obtain ⟨⟨_, ha', hb', hc'⟩, hg'⟩ := hu
  have hgcd : Int.gcd (t.1 * u.2.2) (t.2.1 * u.2.2) = Int.gcd (u.1 * t.2.2) (u.2.1 * t.2.2) := by
    rw [h1, h2]
  rw [Int.gcd_mul_right, Int.gcd_mul_right, hg, hg'] at hgcd
  have hcc : u.2.2 = t.2.2 := by
    have : u.2.2.natAbs = t.2.2.natAbs := by simpa using hgcd
    omega
  have hfst : t.1 = u.1 := by
    rw [hcc] at h1
    exact mul_right_cancel₀ (by omega) h1
  have hsnd : t.2.1 = u.2.1 := by
    rw [hcc] at h2
    exact mul_right_cancel₀ (by omega) h2
  obtain ⟨a, b, c⟩ := t
  obtain ⟨a', b', c'⟩ := u
  simp only at hfst hsnd hcc
  simp [hfst, hsnd, hcc]

/-- If two primitive events have proportional legs they are equal. -/
theorem prim_parallel_eq {t u : Event} (ht : IsPrimEvent t) (hu : IsPrimEvent u)
    (h : t.1 * u.2.1 = u.1 * t.2.1) : t = u := by
  have hp := ht.1.1
  have hp' := hu.1.1
  unfold IsPythag at hp hp'
  obtain ⟨_, ha, hb, hc⟩ := ht.1
  obtain ⟨_, ha', hb', hc'⟩ := hu.1
  have h0 : t.1 * u.2.1 - u.1 * t.2.1 = 0 := sub_eq_zero_of_eq h
  refine prim_ray_eq ht hu ?_ ?_
  · refine eq_of_sq_eq_sq_of_pos (mul_pos ha hc') (mul_pos ha' hc) ?_
    have key : (t.1 * u.2.2) ^ 2 - (u.1 * t.2.2) ^ 2
        = (t.1 * u.2.1 - u.1 * t.2.1) * (t.1 * u.2.1 + u.1 * t.2.1) := by
      linear_combination u.1 ^ 2 * hp - t.1 ^ 2 * hp'
    rw [h0] at key
    linarith [key]
  · refine eq_of_sq_eq_sq_of_pos (mul_pos hb hc') (mul_pos hb' hc) ?_
    have key : (t.2.1 * u.2.2) ^ 2 - (u.2.1 * t.2.2) ^ 2
        = (t.1 * u.2.1 - u.1 * t.2.1) * (-(t.1 * u.2.1) - u.1 * t.2.1) := by
      linear_combination u.2.1 ^ 2 * hp - t.2.1 ^ 2 * hp'
    rw [h0] at key
    linarith [key]

/-- The celestial map: the null direction of an event, a rational point of the unit circle. -/
def dir (t : Event) : ℚ × ℚ := ((t.1 : ℚ) / (t.2.2 : ℚ), (t.2.1 : ℚ) / (t.2.2 : ℚ))

theorem dir_mem_circle {t : Event} (h : IsEvent t) : (dir t).1 ^ 2 + (dir t).2 ^ 2 = 1 := by
  obtain ⟨hp, _, _, hc⟩ := h
  unfold IsPythag at hp
  have hcq : (t.2.2 : ℚ) ≠ 0 := by
    simpa using (by omega : t.2.2 ≠ 0)
  have hpq : (t.1 : ℚ) ^ 2 + (t.2.1 : ℚ) ^ 2 = (t.2.2 : ℚ) ^ 2 := by exact_mod_cast hp
  simp only [dir]
  field_simp
  linarith [hpq]

/-- **The celestial map is injective**: distinct events of the tree have distinct null
directions, so the events inject into the rational points of the celestial circle. -/
theorem dir_injective {t u : Event} (ht : IsPrimEvent t) (hu : IsPrimEvent u)
    (h : dir t = dir u) : t = u := by
  obtain ⟨_, _, _, hc⟩ := ht.1
  obtain ⟨_, _, _, hc'⟩ := hu.1
  have hcq : (t.2.2 : ℚ) ≠ 0 := by simpa using (by omega : t.2.2 ≠ 0)
  have hcq' : (u.2.2 : ℚ) ≠ 0 := by simpa using (by omega : u.2.2 ≠ 0)
  have h1 : (t.1 : ℚ) / (t.2.2 : ℚ) = (u.1 : ℚ) / (u.2.2 : ℚ) := congrArg Prod.fst h
  have h2 : (t.2.1 : ℚ) / (t.2.2 : ℚ) = (u.2.1 : ℚ) / (u.2.2 : ℚ) := congrArg Prod.snd h
  rw [div_eq_div_iff hcq hcq'] at h1 h2
  refine prim_ray_eq ht hu ?_ ?_
  · exact_mod_cast h1
  · exact_mod_cast h2

/-! ## Part D. The Minkowski interval: all events are mutually spacelike -/

/-- The Minkowski interval between two events, `Q(u − t)` for the form of signature `(2,1)`. -/
def mink (t u : Event) : ℤ :=
  (u.1 - t.1) ^ 2 + (u.2.1 - t.2.1) ^ 2 - (u.2.2 - t.2.2) ^ 2

theorem mink_eq_of_null {t u : Event} (ht : IsEvent t) (hu : IsEvent u) :
    mink t u = 2 * (t.2.2 * u.2.2 - t.1 * u.1 - t.2.1 * u.2.1) := by
  have hp := ht.1
  have hp' := hu.1
  unfold IsPythag at hp hp'
  unfold mink
  linear_combination hp + hp'

/-- **The central negative result.**  Two distinct events of the Berggren causal set are
*spacelike* separated in the ambient Minkowski space `ℝ^{2,1}`.  (Two distinct points of
the null cone always are; the content here is that distinct tree nodes are never on the
same null ray, which uses primitivity.) -/
theorem distinct_events_spacelike {t u : Event} (ht : IsPrimEvent t) (hu : IsPrimEvent u)
    (hne : t ≠ u) : 0 < mink t u := by
  have hp := ht.1.1
  have hp' := hu.1.1
  unfold IsPythag at hp hp'
  obtain ⟨_, ha, hb, hc⟩ := ht.1
  obtain ⟨_, ha', hb', hc'⟩ := hu.1
  have hpar : t.1 * u.2.1 - u.1 * t.2.1 ≠ 0 := by
    intro h0
    exact hne (prim_parallel_eq ht hu (sub_eq_zero.mp h0))
  have hsq : 0 < (t.1 * u.2.1 - u.1 * t.2.1) ^ 2 := by positivity
  have hkey : (t.2.2 * u.2.2) ^ 2
      = (t.1 * u.1 + t.2.1 * u.2.1) ^ 2 + (t.1 * u.2.1 - u.1 * t.2.1) ^ 2 := by
    linear_combination (-(u.1 ^ 2 + u.2.1 ^ 2)) * hp - t.2.2 ^ 2 * hp'
  rw [mink_eq_of_null ht.1 hu.1]
  nlinarith [mul_pos hc hc', hkey, hsq]

/-- Every *tree edge* — i.e. every generating causal relation of the Berggren causal set —
is a spacelike interval of Minkowski space. -/
theorem edge_spacelike (s : BerggrenStep) {t : Event} (ht : IsPrimEvent t) :
    0 < mink t (applyStep s t) := by
  refine distinct_events_spacelike ht (step_isPrimEvent s ht) ?_
  intro hcontra
  exact no_closed_causal_curve ht.1 (w := [s]) (by simp) (by simpa using hcontra.symm)

/-- **The Berggren order is not the Minkowski causal order.**  Whenever `u` is a strict
Berggren descendant of `t`, the two events are spacelike separated, hence causally
*unrelated* in `ℝ^{2,1}`. -/
theorem causal_pairs_spacelike {t u : Event} (ht : IsPrimEvent t) (h : Causal t u)
    (hne : t ≠ u) : 0 < mink t u := by
  obtain ⟨w, rfl⟩ := h
  exact distinct_events_spacelike ht (run_isPrimEvent w ht) hne

/-! ## Part E. The dimension verdict -/

/-- The `B`-spine: the Pell branch of pure middle moves. -/
def spine (k : ℕ) : Event := run (List.replicate k BerggrenStep.B) root

/-- **Interval volume is exactly linear in proper time.** -/
theorem interval_growth_linear (k : ℕ) :
    (causalInterval root (spine k)).ncard = k + 1 := by
  unfold spine
  rw [causalInterval_ncard root_isEvent]
  simp

/-- **No Myrheim–Meyer dimension `≥ 2`.**  For a causal set faithfully embedded in
`d`-dimensional Minkowski space the cardinality of an interval of proper time `k` grows
like the volume `kᵈ`.  For the Berggren causal set no quadratic lower bound holds: the
Alexandrov intervals are chains, and the effective dimension is `1`. -/
theorem not_myrheim_meyer_dim_two :
    ¬ ∃ rho : ℝ, 0 < rho ∧ ∀ k : ℕ,
      rho * (k : ℝ) ^ 2 ≤ ((causalInterval root (spine k)).ncard : ℝ) := by
  rintro ⟨rho, hrho, hle⟩
  obtain ⟨n, hn⟩ := exists_nat_gt (2 / rho)
  have hk := hle (n + 1)
  rw [interval_growth_linear] at hk
  have hn1 : (2 : ℝ) / rho < (n : ℝ) + 1 := by linarith
  have h2 : (2 : ℝ) < rho * ((n : ℝ) + 1) := by
    rw [div_lt_iff₀ hrho] at hn1
    linarith
  have hpos : (0 : ℝ) < (n : ℝ) + 1 := by positivity
  push_cast at hk
  nlinarith [hk, h2, hpos]

/-- The `1`-dimensional lower bound *does* hold, with density `1`: the Berggren causal set
has a well-defined Myrheim–Meyer-style dimension, and it equals `1`. -/
theorem myrheim_meyer_dim_one (k : ℕ) :
    (k : ℝ) ≤ ((causalInterval root (spine k)).ncard : ℝ) ∧
      ((causalInterval root (spine k)).ncard : ℝ) ≤ (k : ℝ) + 1 := by
  rw [interval_growth_linear]
  push_cast
  constructor <;> linarith

/-- **Level growth is superpolynomial.**  The `3^k` growth of the Berggren levels beats
every polynomial, so it cannot be the volume growth of a spatial slice of a
fixed-dimensional Minkowski space; the silver-ratio growth exponent measures branching,
not spacetime volume. -/
theorem level_growth_superpolynomial (d : ℕ) :
    ∃ k : ℕ, (k : ℝ) ^ d < ((levelFinset root k).card : ℝ) := by
  have h3 : (1 : ℝ) < 3 := by norm_num
  have htend := tendsto_pow_const_div_const_pow_of_one_lt d h3
  have : ∀ᶠ k : ℕ in Filter.atTop, (k : ℝ) ^ d / (3 : ℝ) ^ k < 1 := by
    have := htend.eventually (gt_mem_nhds (show (0 : ℝ) < 1 by norm_num))
    exact this
  obtain ⟨k, hk⟩ := this.exists
  refine ⟨k, ?_⟩
  have hpow : (0 : ℝ) < (3 : ℝ) ^ k := by positivity
  rw [div_lt_one hpow] at hk
  rw [level_card root_isEvent k]
  push_cast
  exact hk

end BerggrenCausalSet