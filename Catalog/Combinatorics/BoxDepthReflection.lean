import Novelty.ArithmetizedQFTReflection

/-!
# The depth-graded reflection hierarchy of the finite-height GL theories

`Novelty.ArithmetizedQFTReflection` built the infinite family `capSysN n` of
finite-height GL theories (the formulas valid at the worlds `0, …, n` of the standard
Kripke frame `(ℕ, <)`) and showed that each of them is consistent, minimally sound and
refutes the *uniform reflection rule* exactly at iteration depth `n`: it proves
`□^{n+1}⊥` while refusing `□^n ⊥` (`capSysN_separating`).

The accompanying conjecture list (item 2, "depth-graded failure of reflection")
proposed that the failure is graded by the **box depth** of the reflected formula: for
every `n` the restricted rule

  `DepthReflection d i S` :  `⊢ □_i a` implies `⊢ a`, for all `a` with `boxDepth a < d`

should hold in `capSysN n` for `d ≤ n` and fail for `d = n + 1`, so that 1-consistency
stratifies into a strictly increasing chain of conditions.

This file proves the conjecture, in the sharp form of an exact biconditional
(`capSysN_depthReflection_iff`):

  `DepthReflection d i (capSysN n) ↔ d ≤ n`.

The combinatorial engine is a *depth–horizon* lemma for the standard frame
(`sat_eq_of_boxDepth_le`, `sat_eq_min_boxDepth`): a formula of box depth `d` cannot
distinguish two worlds that are both at height `≥ d`, so the truth value of `a` at the
world `m` depends only on `min m (boxDepth a)` — the frame `(ℕ, <)` has exactly
`d + 1` worlds up to depth-`d` modal equivalence.  Consequences:

* `capSysN_depthReflection` — the restricted rule holds below the height;
* `capSysN_depthReflection_fails` — and fails one step higher, witnessed by `□^n ⊥`;
* `capSysN_provable_congr_of_boxDepth_le` — the whole hierarchy *stabilizes* on
  formulas of small box depth: for `boxDepth a ≤ n ≤ n'`, the theories `capSysN n` and
  `capSysN n'` agree about `a`.  So although the hierarchy is strictly decreasing, all
  of its differences at stage `n` live in box depth exactly `n`;
* `uniformReflection_iff_all_depths` — uniform reflection is the conjunction of the
  whole chain, and `depthReflection_hierarchy_strict` shows the chain is strictly
  decreasing as a family of conditions on theories;
* `depthReflection_one_implies_minSoundness` together with
  `minSoundness_not_implies_depthReflection_two` locate the minimal soundness condition
  `⊬ □⊥` strictly below the chain.

-- !-- Lab Notes -- !--
Hypothesis (Stage 1): failure of reflection in `capSysN n` is a *horizon* phenomenon:
  the theory sees `n + 1` worlds, and only a formula able to count up to `n` boxes can
  notice that the top world has no `n`-step chain below it.
Experiment (Stage 2): evaluate `sat m a` for all formulas of box depth `≤ 3` at worlds
  `m ≤ 6`; the truth table depends on `m` only through `min m (boxDepth a)`, and the
  first formula separating world `n` from world `n - 1` is `□^n ⊥`.
Analysis (Stage 3): the pattern is exactly the depth-horizon lemma below, and it turns
  the conjectured hierarchy into an equivalence `DepthReflection d i (capSysN n) ↔
  d ≤ n`, which also pins the *only* obstruction: the formula `□^n ⊥`.
Critique (Stage 4): the equivalence is not vacuous — the failing direction produces an
  explicit formula, and the positive direction is proved for arbitrary formulas, not
  only for iterated boxed falsa.
-/

namespace PhysicsConsistency

open ProofSystemCollapse
open Form

/-! ## §1. Box depth and the depth horizon -/

/-- The **box depth** (modal degree) of a formula: the maximal nesting of `box`. -/
def boxDepth : Form → ℕ
  | bot => 0
  | atom _ => 0
  | imp a b => max (boxDepth a) (boxDepth b)
  | box _ a => boxDepth a + 1

@[simp] theorem boxDepth_bot : boxDepth bot = 0 := rfl

@[simp] theorem boxDepth_box (i : ℕ) (a : Form) : boxDepth (box i a) = boxDepth a + 1 :=
  rfl

/-- The box depth of an iterated boxed falsum is the iteration count. -/
@[simp] theorem boxDepth_boxPow_bot (i k : ℕ) : boxDepth (boxPow i k bot) = k := by
  induction k with
  | zero => rfl
  | succ k ih => rw [boxPow, boxDepth_box, ih]

/-- **Depth horizon.**  A formula of box depth `d` cannot distinguish two worlds of the
standard frame that both lie at height `≥ d`: modal degree `d` can only count `d`
steps down, and both worlds have at least `d` steps available. -/
theorem sat_eq_of_boxDepth_le :
    ∀ (a : Form) (m m' : ℕ), boxDepth a ≤ m → boxDepth a ≤ m' → sat m a = sat m' a := by
  intro a
  induction a with
  | bot => intro m m' _ _; rfl
  | atom _ => intro m m' _ _; rfl
  | imp p q ihp ihq =>
      intro m m' hm hm'
      have h1 : boxDepth p ≤ m := le_trans (le_max_left _ _) hm
      have h2 : boxDepth p ≤ m' := le_trans (le_max_left _ _) hm'
      have h3 : boxDepth q ≤ m := le_trans (le_max_right _ _) hm
      have h4 : boxDepth q ≤ m' := le_trans (le_max_right _ _) hm'
      simp only [sat, ihp m m' h1 h2, ihq m m' h3 h4]
  | box i b ih =>
      intro m m' hm hm'
      have key : ∀ p q : ℕ, boxDepth b + 1 ≤ p → boxDepth b + 1 ≤ q →
          (∀ k, k < p → sat k b = true) → ∀ k, k < q → sat k b = true := by
        intro p q hp _ h k hk
        by_cases hd : boxDepth b ≤ k
        · rw [ih k (boxDepth b) hd le_rfl]
          exact h (boxDepth b) (by omega)
        · exact h k (by omega)
      rw [Bool.eq_iff_iff, sat_box, sat_box]
      exact ⟨key m m' hm hm', key m' m hm' hm⟩

/-- **The world is only seen up to the depth horizon.**  The truth value of `a` at the
world `m` depends on `m` only through `min m (boxDepth a)`; equivalently the standard
frame has exactly `boxDepth a + 1` worlds up to `a`-equivalence. -/
theorem sat_eq_min_boxDepth (a : Form) (m : ℕ) :
    sat m a = sat (min m (boxDepth a)) a := by
  rcases Nat.lt_or_ge m (boxDepth a) with h | h
  · rw [Nat.min_eq_left (le_of_lt h)]
  · rw [Nat.min_eq_right h]
    exact sat_eq_of_boxDepth_le a m (boxDepth a) h le_rfl

/-! ## §2. Depth-restricted reflection -/

/-- The **depth-restricted reflection rule**: whatever the theory proves to be
provable, it proves — but only for formulas of box depth `< d`.  For `d = 0` the rule
is vacuous, and the union over all `d` is the uniform reflection rule. -/
def DepthReflection (d i : ℕ) (S : ProofSys Form) : Prop :=
  ∀ a : Form, boxDepth a < d → Provable S (box i a) → Provable S a

/-- **Uniform reflection is the conjunction of the whole depth chain.** -/
theorem uniformReflection_iff_all_depths (i : ℕ) (S : ProofSys Form) :
    UniformReflectionRule i S ↔ ∀ d, DepthReflection d i S := by
  constructor
  · intro h d a _ ha
    exact h a ha
  · intro h a ha
    exact h (boxDepth a + 1) a (by omega) ha

/-- The depth chain is decreasing in `d`: a deeper rule implies all shallower ones. -/
theorem depthReflection_mono {d d' i : ℕ} {S : ProofSys Form} (hd : d ≤ d')
    (h : DepthReflection d' i S) : DepthReflection d i S :=
  fun a ha hb => h a (lt_of_lt_of_le ha hd) hb

/-! ## §3. The exact depth-graded hierarchy of `capSysN n` -/

/-- **Reflection holds below the height.**  In the height-`n` theory the restricted
reflection rule is valid for every formula of box depth `< n`: such a formula cannot
tell the top world `n` apart from the world `n - 1`, where the hypothesis `⊢ □_i a`
already forces it to be true. -/
theorem capSysN_depthReflection (n i : ℕ) : DepthReflection n i (capSysN n) := by
  intro a hdep hbox
  rw [provable_capSysN] at hbox ⊢
  intro m hm
  have hlow : ∀ k, k < n → sat k a = true := by
    intro k hk
    have := (sat_box n i a).1 (hbox n le_rfl)
    exact this k hk
  rcases Nat.lt_or_ge m n with h | h
  · exact hlow m h
  · have hmn : m = n := by omega
    subst hmn
    have h1 : sat (boxDepth a) a = true := hlow _ hdep
    rw [sat_eq_of_boxDepth_le a m (boxDepth a) (by omega) le_rfl]
    exact h1

/-- **Reflection fails one step higher**, witnessed by the iterated boxed falsum
`□_i^n ⊥`, of box depth exactly `n`: the theory proves it to be provable but refutes
it. -/
theorem capSysN_depthReflection_fails (n i : ℕ) :
    ¬ DepthReflection (n + 1) i (capSysN n) := by
  intro h
  have hbox : Provable (capSysN n) (box i (boxPow i n bot)) :=
    (provable_capSysN_boxPow_bot n i (n + 1)).2 (by omega)
  have := h (boxPow i n bot) (by simp) hbox
  exact absurd ((provable_capSysN_boxPow_bot n i n).1 this) (by omega)

/-- **The exact depth-graded reflection spectrum.**  The height-`n` theory satisfies
the depth-`d` restricted reflection rule precisely when `d ≤ n`. -/
theorem capSysN_depthReflection_iff (n d i : ℕ) :
    DepthReflection d i (capSysN n) ↔ d ≤ n := by
  constructor
  · intro h
    by_contra hlt
    exact capSysN_depthReflection_fails n i
      (depthReflection_mono (by omega) h)
  · intro hd
    exact depthReflection_mono hd (capSysN_depthReflection n i)

/-- **The depth chain of conditions is strictly decreasing.**  For every `n` the
height-`n` theory is a consistent GL theory satisfying the depth-`n` rule but not the
depth-`(n+1)` rule; hence no two conditions in the chain are equivalent. -/
theorem depthReflection_hierarchy_strict (n i : ℕ) :
    Consistent (capSysN n) ∧ IsGLTheory i (capSysN n) ∧
      DepthReflection n i (capSysN n) ∧ ¬ DepthReflection (n + 1) i (capSysN n) :=
  ⟨consistent_capSysN n, isGL_capSysN n i, capSysN_depthReflection n i,
    capSysN_depthReflection_fails n i⟩

/-! ## §4. Where the minimal soundness condition sits -/

/-- **The bottom of the chain implies minimal soundness.**  For a consistent theory,
even the depth-`1` rule (reflection for box-free formulas) already forbids proving
`□_i ⊥`. -/
theorem depthReflection_one_implies_minSoundness {i : ℕ} {S : ProofSys Form}
    (hcon : Consistent S) (h : DepthReflection 1 i S) : MinSoundness i S :=
  fun hbox => hcon (h bot (by simp) hbox)

/-- **Minimal soundness is strictly weaker than the depth-`2` rule.**  The two-world
theory `capSysN 1` is a consistent GL theory that does not prove `□_i ⊥`, yet it
violates the depth-`2` reflection rule (at the formula `□_i ⊥`, of box depth `1`). -/
theorem minSoundness_not_implies_depthReflection_two (i : ℕ) :
    Consistent (capSysN 1) ∧ IsGLTheory i (capSysN 1) ∧ MinSoundness i (capSysN 1) ∧
      ¬ DepthReflection 2 i (capSysN 1) :=
  ⟨consistent_capSysN 1, isGL_capSysN 1 i, capSys_not_provable_box_bot i,
    capSysN_depthReflection_fails 1 i⟩

/-! ## §5. Depth stabilization of the hierarchy -/

/-- **Depth stabilization.**  Although the family `capSysN n` is strictly decreasing,
two members of it agree about every formula whose box depth is below the smaller
height: all the disagreements at stage `n` occur at box depth exactly `n`. -/
theorem capSysN_provable_congr_of_boxDepth_le {a : Form} {n n' : ℕ}
    (hdep : boxDepth a ≤ n) (hnn : n ≤ n') :
    Provable (capSysN n) a ↔ Provable (capSysN n') a := by
  rw [provable_capSysN, provable_capSysN]
  constructor
  · intro h m _
    rcases Nat.lt_or_ge m n with hm | hm
    · exact h m (by omega)
    · rw [sat_eq_of_boxDepth_le a m (boxDepth a) (by omega) le_rfl]
      exact h (boxDepth a) hdep
  · intro h m hm
    exact h m (by omega)

/-- **The stabilization bound is sharp.**  For `a = □_i^{n+1} ⊥`, of box depth
`n + 1`, the theories `capSysN n` and `capSysN (n + 1)` disagree. -/
theorem capSysN_stabilization_sharp (n i : ℕ) :
    boxDepth (boxPow i (n + 1) bot) = n + 1 ∧
      Provable (capSysN n) (boxPow i (n + 1) bot) ∧
      ¬ Provable (capSysN (n + 1)) (boxPow i (n + 1) bot) := by
  refine ⟨by simp, (provable_capSysN_boxPow_bot n i (n + 1)).2 (by omega), ?_⟩
  intro h
  exact absurd ((provable_capSysN_boxPow_bot (n + 1) i (n + 1)).1 h) (by omega)

/-- **Summary: the depth-graded reflection conjecture is a theorem.**  Restricted
reflection in `capSysN n` holds exactly up to depth `n`, the chain of restricted rules
is strictly decreasing, and it sits strictly above the minimal soundness condition. -/
theorem depth_graded_reflection_summary (n i : ℕ) (hn : 1 ≤ n) :
    (∀ d, DepthReflection d i (capSysN n) ↔ d ≤ n) ∧
      DepthReflection n i (capSysN n) ∧ ¬ DepthReflection (n + 1) i (capSysN n) ∧
      MinSoundness i (capSysN n) :=
  ⟨fun d => capSysN_depthReflection_iff n d i, capSysN_depthReflection n i,
    capSysN_depthReflection_fails n i, by
      intro hbox
      have : Provable (capSysN n) (boxPow i 1 bot) := hbox
      exact absurd ((provable_capSysN_boxPow_bot n i 1).1 this) (by omega)⟩

end PhysicsConsistency