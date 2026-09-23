/-
# The Euler Brick Tree, VI: tree-ness and exact growth

The Berggren descent theorem of `Tropical.EulerBrickTree.Descent` says that the
three generators reach every primitive triple with odd first leg.  Here we prove
that they do so *exactly once*: the generated graph really is a ternary tree.

* each generator is injective;
* the images of the three generators on tree nodes are pairwise disjoint, so a
  node determines both its parent and the generator used (`unique parent`);
* hence the path map `applyPath` from words in three letters to nodes is
  injective, and the set of nodes at depth `n` has **exactly `3ⁿ`** elements;
* every node at depth `n` carries a nondegenerate Euler brick, so the brick tree
  grows at the exact rate `3ⁿ` as well.
-/
import Mathlib
import Tropical.EulerBrickTree.Core
import Tropical.EulerBrickTree.Descent
import Tropical.EulerBrickTree.Obstruction

namespace EulerBrickTree

/-! ## The three generators as a single family -/

/-- The three Berggren generators indexed by `Fin 3`. -/
def gen : Fin 3 → ℤ × ℤ × ℤ → ℤ × ℤ × ℤ
  | 0, t => bergA t.1 t.2.1 t.2.2
  | 1, t => bergB t.1 t.2.1 t.2.2
  | _, t => bergC t.1 t.2.1 t.2.2

theorem gen_ppt {i : Fin 3} {t : ℤ × ℤ × ℤ} (h : IsPPT t.1 t.2.1 t.2.2) :
    IsPPT (gen i t).1 (gen i t).2.1 (gen i t).2.2 := by
  fin_cases i
  · exact bergA_ppt h
  · exact bergB_ppt h
  · exact bergC_ppt h

theorem gen_reach {i : Fin 3} {t : ℤ × ℤ × ℤ} (h : TreeReach t.1 t.2.1 t.2.2) :
    TreeReach (gen i t).1 (gen i t).2.1 (gen i t).2.2 := by
  fin_cases i
  · exact TreeReach.stepA h
  · exact TreeReach.stepB h
  · exact TreeReach.stepC h

/-- The hypotenuse grows strictly along every generator. -/
theorem gen_hyp_lt {i : Fin 3} {t : ℤ × ℤ × ℤ} (h : IsPPT t.1 t.2.1 t.2.2) :
    t.2.2 < (gen i t).2.2 := by
  fin_cases i
  · exact (hyp_increase h).1
  · exact (hyp_increase h).2.1
  · exact (hyp_increase h).2.2

/-! ## Injectivity and disjointness -/

theorem gen_injective (i : Fin 3) : Function.Injective (gen i) := by
  intro t t' he
  fin_cases i <;>
    simp only [gen, bergA, bergB, bergC, Prod.mk.injEq] at he <;>
    obtain ⟨h1, h2, h3⟩ := he <;>
    exact Prod.ext (by omega) (Prod.ext (by omega) (by omega))

/-- A child produced by the first generator has a *negative* second coordinate
after applying the second inverse Berggren map: this is what distinguishes the
generators. -/
theorem invB2_bergA {a b c : ℤ} :
    (invB2 (bergA a b c).1 (bergA a b c).2.1 (bergA a b c).2.2).2.1 = -b := by
  simp only [invB2, bergA]
  ring

theorem invB3_bergA {a b c : ℤ} :
    (invB3 (bergA a b c).1 (bergA a b c).2.1 (bergA a b c).2.2).1 = -a := by
  simp only [invB3, bergA]
  ring

theorem invB1_bergB {a b c : ℤ} :
    (invB1 (bergB a b c).1 (bergB a b c).2.1 (bergB a b c).2.2).2.1 = -b := by
  simp only [invB1, bergB]
  ring

theorem invB3_bergB {a b c : ℤ} :
    (invB3 (bergB a b c).1 (bergB a b c).2.1 (bergB a b c).2.2).1 = -a := by
  simp only [invB3, bergB]
  ring

theorem invB1_bergC {a b c : ℤ} :
    (invB1 (bergC a b c).1 (bergC a b c).2.1 (bergC a b c).2.2).1 = -a := by
  simp only [invB1, bergC]
  ring

theorem invB2_bergC {a b c : ℤ} :
    (invB2 (bergC a b c).1 (bergC a b c).2.1 (bergC a b c).2.2).1 = -a := by
  simp only [invB2, bergC]
  ring

/-- Recovery of a node from its `bergA`-child. -/
theorem invB1_bergA {a b c : ℤ} :
    invB1 (bergA a b c).1 (bergA a b c).2.1 (bergA a b c).2.2 = (a, b, c) := by
  rw [invB1_eq_invA]
  exact fwd_inv_A a b c

theorem invB2_bergB {a b c : ℤ} :
    invB2 (bergB a b c).1 (bergB a b c).2.1 (bergB a b c).2.2 = (a, b, c) := by
  rw [invB2_eq_invB]
  exact fwd_inv_B a b c

theorem invB3_bergC {a b c : ℤ} :
    invB3 (bergC a b c).1 (bergC a b c).2.1 (bergC a b c).2.2 = (a, b, c) := by
  rw [invB3_eq_invC]
  exact fwd_inv_C a b c

/-- Children of the first and second generators are never equal. -/
theorem bergA_ne_bergB {a b c a' b' c' : ℤ} (hb : 0 < b) (hb' : 0 < b') :
    bergA a b c ≠ bergB a' b' c' := by
  intro he
  have key : (invB2 (bergA a b c).1 (bergA a b c).2.1 (bergA a b c).2.2).2.1 = -b := invB2_bergA
  rw [he, invB2_bergB] at key
  simp only at key
  omega

/-- Children of the first and third generators are never equal. -/
theorem bergA_ne_bergC {a b c a' b' c' : ℤ} (ha : 0 < a) (ha' : 0 < a') :
    bergA a b c ≠ bergC a' b' c' := by
  intro he
  have key : (invB3 (bergA a b c).1 (bergA a b c).2.1 (bergA a b c).2.2).1 = -a := invB3_bergA
  rw [he, invB3_bergC] at key
  simp only at key
  omega

/-- Children of the second and third generators are never equal. -/
theorem bergB_ne_bergC {a b c a' b' c' : ℤ} (ha : 0 < a) (ha' : 0 < a') :
    bergB a b c ≠ bergC a' b' c' := by
  intro he
  have key : (invB3 (bergB a b c).1 (bergB a b c).2.1 (bergB a b c).2.2).1 = -a := invB3_bergB
  rw [he, invB3_bergC] at key
  simp only at key
  omega

/-- **The images of two different generators are disjoint on tree nodes.** -/
theorem gen_disjoint {i j : Fin 3} {t t' : ℤ × ℤ × ℤ} (hij : i ≠ j)
    (h : IsPPT t.1 t.2.1 t.2.2) (h' : IsPPT t'.1 t'.2.1 t'.2.2) :
    gen i t ≠ gen j t' := by
  obtain ⟨ha, hb, -, -, -, -⟩ := h
  obtain ⟨ha', hb', -, -, -, -⟩ := h'
  fin_cases i <;> fin_cases j <;> simp only [gen]
  · exact absurd rfl hij
  · exact bergA_ne_bergB hb hb'
  · exact bergA_ne_bergC ha ha'
  · exact (bergA_ne_bergB hb' hb).symm
  · exact absurd rfl hij
  · exact bergB_ne_bergC ha ha'
  · exact (bergA_ne_bergC ha' ha).symm
  · exact (bergB_ne_bergC ha' ha).symm
  · exact absurd rfl hij

/-! ## Paths and exact growth -/

/-- The node reached by a word in the three generators (the head of the list is
the *last* generator applied). -/
def applyPath : List (Fin 3) → ℤ × ℤ × ℤ
  | [] => (3, 4, 5)
  | i :: p => gen i (applyPath p)

theorem root_isPPT : IsPPT 3 4 5 :=
  ⟨by norm_num, by norm_num, by norm_num, by norm_num [IsPT], by decide, by decide⟩

theorem applyPath_ppt (p : List (Fin 3)) :
    IsPPT (applyPath p).1 (applyPath p).2.1 (applyPath p).2.2 := by
  induction p with
  | nil => exact root_isPPT
  | cons i q ih => exact gen_ppt ih

theorem applyPath_reach (p : List (Fin 3)) :
    TreeReach (applyPath p).1 (applyPath p).2.1 (applyPath p).2.2 := by
  induction p with
  | nil => exact TreeReach.root
  | cons i q ih => exact gen_reach ih

/-- Every path node has hypotenuse at least `5`. -/
theorem applyPath_hyp_ge : ∀ p : List (Fin 3), 5 ≤ (applyPath p).2.2
  | [] => by norm_num [applyPath]
  | i :: q => by
      have h1 := applyPath_hyp_ge q
      have h2 := gen_hyp_lt (i := i) (applyPath_ppt q)
      simp only [applyPath]
      omega

/-- The hypotenuse of a nonempty path node exceeds `5`, so the root is not a
child of anything. -/
theorem applyPath_hyp_gt (i : Fin 3) (p : List (Fin 3)) : 5 < (applyPath (i :: p)).2.2 := by
  have h1 := applyPath_hyp_ge p
  have h2 := gen_hyp_lt (i := i) (applyPath_ppt p)
  simp only [applyPath]
  omega

/-- **The path map is injective**: distinct words give distinct nodes.  Together
with `ppt_treeReach` this says that the Berggren tree is a genuine ternary tree
on the primitive triples. -/
theorem applyPath_injective : Function.Injective applyPath := by
  intro p
  induction p with
  | nil =>
    intro q hq
    cases q with
    | nil => rfl
    | cons j r =>
      exfalso
      have := applyPath_hyp_gt j r
      rw [← hq] at this
      simp [applyPath] at this
  | cons i p ih =>
    intro q hq
    cases q with
    | nil =>
      exfalso
      have := applyPath_hyp_gt i p
      rw [hq] at this
      simp [applyPath] at this
    | cons j r =>
      have hij : i = j := by
        by_contra hne
        exact gen_disjoint hne (applyPath_ppt p) (applyPath_ppt r) hq
      subst hij
      have := gen_injective i hq
      rw [ih this]

/-- The set of nodes at depth `n` of the Berggren tree. -/
noncomputable def depthNodes (n : ℕ) : Finset (ℤ × ℤ × ℤ) :=
  (Finset.univ : Finset (List.Vector (Fin 3) n)).image fun v => applyPath v.1

theorem mem_depthNodes {n : ℕ} {t : ℤ × ℤ × ℤ} (h : t ∈ depthNodes n) :
    TreeReach t.1 t.2.1 t.2.2 := by
  simp only [depthNodes, Finset.mem_image] at h
  obtain ⟨v, -, rfl⟩ := h
  exact applyPath_reach v.1

/-- **Exact growth.**  Level `n` of the Berggren tree contains exactly `3ⁿ`
distinct nodes. -/
theorem depthNodes_card (n : ℕ) : (depthNodes n).card = 3 ^ n := by
  have hinj : Function.Injective fun v : List.Vector (Fin 3) n => applyPath v.1 := by
    intro v w hvw
    exact Subtype.ext (applyPath_injective hvw)
  rw [depthNodes, Finset.card_image_of_injective _ hinj, Finset.card_univ, card_vector]
  simp

/-- **Exact growth of the brick tree.**  Level `n` of the brick tree consists of
`3ⁿ` bricks, each a nondegenerate Euler brick. -/
theorem brick_tree_level_growth (n : ℕ) :
    (depthNodes n).card = 3 ^ n ∧
      ∀ t ∈ depthNodes n,
        IsBrick (brick t.1 t.2.1 t.2.2).1 (brick t.1 t.2.1 t.2.2).2.1
            (brick t.1 t.2.1 t.2.2).2.2 ∧
          Nondegenerate (brick t.1 t.2.1 t.2.2).1 (brick t.1 t.2.1 t.2.2).2.1
            (brick t.1 t.2.1 t.2.2).2.2 := by
  refine ⟨depthNodes_card n, fun t ht => ?_⟩
  obtain ⟨ha, hb, hc, hpt, hgcd, -⟩ := treeReach_ppt (mem_depthNodes ht)
  exact ⟨brick_isBrick hpt, brick_nondegenerate hpt ha hb hc hgcd⟩

/-! ## Distinct nodes carry distinct bricks -/

/-- In a primitive triple with odd first leg the second leg is even. -/
theorem ppt_snd_even {a b c : ℤ} (h : IsPPT a b c) : b % 2 = 0 := by
  obtain ⟨-, -, -, hpt, -, hodd⟩ := h
  rcases Int.emod_two_eq_zero_or_one b with h0 | h1
  · exact h0
  · exact absurd hpt (no_two_odd_legs hodd h1)

/-- **The Saunderson generator is injective on tree nodes.**  Hence distinct
nodes really do carry distinct bricks. -/
theorem brick_injective_on_ppt {u v w u' v' w' : ℤ} (h : IsPPT u v w) (h' : IsPPT u' v' w')
    (he : brick u v w = brick u' v' w') : u = u' ∧ v = v' ∧ w = w' := by
  have hv'even : v' % 2 = 0 := ppt_snd_even h'
  obtain ⟨hu, hv, hw, hpt, -, hodd⟩ := h
  obtain ⟨hu', hv', hw', hpt', -, -⟩ := h'
  simp only [brick, Prod.mk.injEq] at he
  obtain ⟨hx, hy, hz⟩ := he
  -- the first face diagonal is `w³`, so `w⁶ = w'⁶`
  have hw6 : w ^ 6 = w' ^ 6 := by
    have e1 := brick_face_xy hpt
    have e2 := brick_face_xy hpt'
    rw [hx, hy] at e1
    rw [e2] at e1
    linarith [e1]
  have hwnat : w.natAbs ^ 6 = w'.natAbs ^ 6 := by
    have : (w ^ 6).natAbs = (w' ^ 6).natAbs := by rw [hw6]
    simpa [Int.natAbs_pow] using this
  have hweq : w = w' := by
    have := Nat.pow_left_injective (by norm_num) hwnat
    omega
  subst hweq
  -- the third edge gives `uv = u'v'`
  have huv : u * v = u' * v' := by
    have h4w : (4 : ℤ) * w ≠ 0 := by positivity
    have : 4 * w * (u * v) = 4 * w * (u' * v') := by linarith [hz]
    exact mul_left_cancel₀ h4w this
  -- and the Pythagorean equations give `u + v = u' + v'`
  have hsum : u + v = u' + v' := by
    have hsq : (u + v) ^ 2 = (u' + v') ^ 2 := by
      unfold IsPT at hpt hpt'
      nlinarith [huv, hpt, hpt']
    nlinarith [hsq, hu, hv, hu', hv']
  have hfac : (u - u') * (u - v') = 0 := by nlinarith [hsum, huv]
  have hueq : u = u' := by
    rcases mul_eq_zero.mp hfac with h0 | h0
    · omega
    · -- `u = v'` is impossible: `u` is odd while `v'` is even
      omega
  subst hueq
  exact ⟨rfl, by
    have : u * v = u * v' := by linarith [huv]
    exact mul_left_cancel₀ (by omega) this, rfl⟩

/-- **Exact growth of the brick tree.**  Level `n` carries exactly `3ⁿ` pairwise
distinct Euler bricks. -/
theorem brickLevel_card (n : ℕ) :
    ((depthNodes n).image fun t => brick t.1 t.2.1 t.2.2).card = 3 ^ n := by
  rw [Finset.card_image_of_injOn, depthNodes_card]
  intro s hs t ht hst
  have hps := treeReach_ppt (mem_depthNodes hs)
  have hpt := treeReach_ppt (mem_depthNodes ht)
  obtain ⟨h1, h2, h3⟩ := brick_injective_on_ppt hps hpt hst
  exact Prod.ext h1 (Prod.ext h2 h3)

end EulerBrickTree