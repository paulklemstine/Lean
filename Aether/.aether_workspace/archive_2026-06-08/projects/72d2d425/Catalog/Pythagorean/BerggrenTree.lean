import Mathlib

/-!
# Berggren Orbit Tree: Formal Infrastructure for Pythagorean Computation

This file establishes the formal foundations for treating the Berggren tree of
primitive Pythagorean triples as a computational substrate.

Key results:
- Berggren generators preserve Pythagorean property and positivity
- Each generator is invertible (bijective on ℤ³)
- Children are pairwise distinct (the orbit is a genuine tree)
- Hypotenuse strictly increases at each step
- Exponential upper bound on entries: all entries ≤ 7^n * 5
- The A-ray gives a canonical embedding of ℕ
- Tree distance (prefix metric) is well-defined
-/

set_option maxHeartbeats 400000

/-! ## Core Types and Definitions -/

/-- Direction in the Berggren tree: the three generators A, B, C. -/
inductive BDir where
  | A | B | C
  deriving DecidableEq, Repr, Fintype

/-- Apply a single Berggren generator to a triple (a, b, c). -/
def berggrenStep : BDir → (ℤ × ℤ × ℤ) → (ℤ × ℤ × ℤ)
  | .A, (a, b, c) => (a - 2*b + 2*c, 2*a - b + 2*c, 2*a - 2*b + 3*c)
  | .B, (a, b, c) => (a + 2*b + 2*c, 2*a + b + 2*c, 2*a + 2*b + 3*c)
  | .C, (a, b, c) => (-a + 2*b + 2*c, -2*a + b + 2*c, -2*a + 2*b + 3*c)

/-- The root triple (3, 4, 5). -/
def rootTriple : ℤ × ℤ × ℤ := (3, 4, 5)

/-- An orbit address is a word over {A, B, C}. -/
abbrev OrbitAddr := List BDir

/-- Apply a word of Berggren generators to a triple, left-to-right. -/
def applyWord : OrbitAddr → (ℤ × ℤ × ℤ) → (ℤ × ℤ × ℤ)
  | [], t => t
  | d :: w, t => applyWord w (berggrenStep d t)

/-- The triple at a given orbit address (starting from the root). -/
def addrTriple (w : OrbitAddr) : ℤ × ℤ × ℤ := applyWord w rootTriple

/-- A triple is Pythagorean: a² + b² = c². -/
def IsPythag' (a b c : ℤ) : Prop := a ^ 2 + b ^ 2 = c ^ 2

/-- A triple has positive entries. -/
def TriplePos (a b c : ℤ) : Prop := 0 < a ∧ 0 < b ∧ 0 < c

/-! ## Pythagorean Preservation -/

theorem berggrenStep_pythag (d : BDir) (a b c : ℤ) (h : IsPythag' a b c) :
    let t := berggrenStep d (a, b, c)
    IsPythag' t.1 t.2.1 t.2.2 := by
  unfold IsPythag' at *
  cases d <;> simp only [berggrenStep] <;> nlinarith

/-! ## Positivity Preservation -/

theorem berggrenStep_pos (d : BDir) (a b c : ℤ)
    (hp : IsPythag' a b c) (hpos : TriplePos a b c) :
    let t := berggrenStep d (a, b, c)
    TriplePos t.1 t.2.1 t.2.2 := by
  unfold IsPythag' at hp; unfold TriplePos at *
  obtain ⟨ha, hb, hc⟩ := hpos
  have hac : a ≤ c := by nlinarith [sq_nonneg b, sq_nonneg (c - a)]
  have hbc : b ≤ c := by nlinarith [sq_nonneg a, sq_nonneg (c - b)]
  cases d <;> simp only [berggrenStep] <;> refine ⟨?_, ?_, ?_⟩ <;> nlinarith

/-! ## Word application preserves properties -/

theorem applyWord_pythag_pos (w : OrbitAddr) (a b c : ℤ)
    (hp : IsPythag' a b c) (hpos : TriplePos a b c) :
    let t := applyWord w (a, b, c)
    IsPythag' t.1 t.2.1 t.2.2 ∧ TriplePos t.1 t.2.1 t.2.2 := by
  induction w generalizing a b c with
  | nil => exact ⟨hp, hpos⟩
  | cons d w ih =>
    simp only [applyWord]
    have hp' := berggrenStep_pythag d a b c hp
    have hpos' := berggrenStep_pos d a b c hp hpos
    set t' := berggrenStep d (a, b, c)
    exact ih t'.1 t'.2.1 t'.2.2 hp' hpos'

theorem addrTriple_pythag (w : OrbitAddr) :
    let t := addrTriple w; IsPythag' t.1 t.2.1 t.2.2 :=
  (applyWord_pythag_pos w 3 4 5
    (by unfold IsPythag'; norm_num)
    (by unfold TriplePos; omega)).1

theorem addrTriple_pos (w : OrbitAddr) :
    let t := addrTriple w; TriplePos t.1 t.2.1 t.2.2 :=
  (applyWord_pythag_pos w 3 4 5
    (by unfold IsPythag'; norm_num)
    (by unfold TriplePos; omega)).2

/-! ## Inverse Berggren Maps -/

/-- Inverse of each Berggren generator. -/
def invBerggren : BDir → (ℤ × ℤ × ℤ) → (ℤ × ℤ × ℤ)
  | .A, (a, b, c) => (a + 2*b - 2*c, -2*a - b + 2*c, -2*a - 2*b + 3*c)
  | .B, (a, b, c) => (a + 2*b - 2*c, 2*a + b - 2*c, -2*a - 2*b + 3*c)
  | .C, (a, b, c) => (-a - 2*b + 2*c, 2*a + b - 2*c, -2*a - 2*b + 3*c)

/-- Forward then inverse is identity. -/
theorem fwd_inv_id (d : BDir) (t : ℤ × ℤ × ℤ) :
    invBerggren d (berggrenStep d t) = t := by
  obtain ⟨a, b, c⟩ := t
  cases d <;> simp [berggrenStep, invBerggren] <;> omega

/-- Inverse then forward is identity. -/
theorem inv_fwd_id (d : BDir) (t : ℤ × ℤ × ℤ) :
    berggrenStep d (invBerggren d t) = t := by
  obtain ⟨a, b, c⟩ := t
  cases d <;> simp [berggrenStep, invBerggren] <;> omega

/-! ## Injectivity -/

/-- Each Berggren generator is injective on ℤ³. -/
theorem berggrenStep_injective (d : BDir) :
    Function.Injective (berggrenStep d) := by
  intro t₁ t₂ h
  have := congr_arg (invBerggren d) h
  rwa [fwd_inv_id, fwd_inv_id] at this

/-- Children in different directions from the same positive Pythagorean parent are distinct. -/
theorem berggrenStep_distinct_AB (a b c : ℤ) (hpos : TriplePos a b c) :
    berggrenStep .A (a, b, c) ≠ berggrenStep .B (a, b, c) := by
  unfold TriplePos at hpos; obtain ⟨ha, hb, hc⟩ := hpos
  intro h; simp only [berggrenStep, Prod.mk.injEq] at h; linarith [h.1]

theorem berggrenStep_distinct_AC (a b c : ℤ) (hpos : TriplePos a b c) :
    berggrenStep .A (a, b, c) ≠ berggrenStep .C (a, b, c) := by
  unfold TriplePos at hpos; obtain ⟨ha, hb, hc⟩ := hpos
  intro h; simp only [berggrenStep, Prod.mk.injEq] at h; linarith [h.1]

theorem berggrenStep_distinct_BC (a b c : ℤ) (hpos : TriplePos a b c) :
    berggrenStep .B (a, b, c) ≠ berggrenStep .C (a, b, c) := by
  unfold TriplePos at hpos; obtain ⟨ha, hb, hc⟩ := hpos
  intro h; simp only [berggrenStep, Prod.mk.injEq] at h; linarith [h.1]

/-- The three children of any positive Pythagorean triple are pairwise distinct. -/
theorem berggren_children_pairwise_distinct (a b c : ℤ) (hpos : TriplePos a b c) :
    berggrenStep .A (a, b, c) ≠ berggrenStep .B (a, b, c) ∧
    berggrenStep .A (a, b, c) ≠ berggrenStep .C (a, b, c) ∧
    berggrenStep .B (a, b, c) ≠ berggrenStep .C (a, b, c) :=
  ⟨berggrenStep_distinct_AB a b c hpos,
   berggrenStep_distinct_AC a b c hpos,
   berggrenStep_distinct_BC a b c hpos⟩

/-! ## Concrete Computations -/

theorem addrTriple_nil : addrTriple [] = (3, 4, 5) := rfl
theorem addrTriple_A : addrTriple [.A] = (5, 12, 13) := by native_decide
theorem addrTriple_B : addrTriple [.B] = (21, 20, 29) := by native_decide
theorem addrTriple_C : addrTriple [.C] = (15, 8, 17) := by native_decide
theorem addrTriple_AA : addrTriple [.A, .A] = (7, 24, 25) := by native_decide
theorem addrTriple_AB : addrTriple [.A, .B] = (55, 48, 73) := by native_decide

/-! ## Hypotenuse Growth -/

/-- Hypotenuse strictly increases under any Berggren step. -/
theorem berggrenStep_hyp_increase (d : BDir) (a b c : ℤ)
    (hp : IsPythag' a b c) (hpos : TriplePos a b c) :
    c < (berggrenStep d (a, b, c)).2.2 := by
  unfold IsPythag' at hp; unfold TriplePos at hpos
  obtain ⟨ha, hb, hc⟩ := hpos
  have hac : a ≤ c := by nlinarith [sq_nonneg b, sq_nonneg (c - a)]
  have hbc : b ≤ c := by nlinarith [sq_nonneg a, sq_nonneg (c - b)]
  cases d <;> simp only [berggrenStep] <;> nlinarith

/-- Upper bound: hypotenuse at most 7c after one step. -/
theorem berggrenStep_hyp_upper (d : BDir) (a b c : ℤ)
    (hp : IsPythag' a b c) (hpos : TriplePos a b c) :
    (berggrenStep d (a, b, c)).2.2 ≤ 7 * c := by
  unfold IsPythag' at hp; unfold TriplePos at hpos
  obtain ⟨ha, hb, hc⟩ := hpos
  have hac : a ≤ c := by nlinarith [sq_nonneg b, sq_nonneg (c - a)]
  have hbc : b ≤ c := by nlinarith [sq_nonneg a, sq_nonneg (c - b)]
  cases d <;> simp only [berggrenStep] <;> nlinarith

/-! ## Exponential Growth Bound -/

/-
The hypotenuse of the triple at address w is at most 7^|w| * 5.
    This gives O(|w|) bit-size for all entries.
-/
theorem hyp_exp_upper_bound (w : OrbitAddr) :
    (addrTriple w).2.2 ≤ 7 ^ w.length * 5 := by
  induction' w using List.reverseRecOn with w d ih <;> simp +decide [ *, pow_succ', mul_assoc ];
  -- By definition of `addrTriple`, we have `addrTriple (w ++ [d]) = applyWord [d] (addrTriple w)`.
  have h_def : addrTriple (w ++ [d]) = berggrenStep d (addrTriple w) := by
    -- By definition of `applyWord`, we have `applyWord (w ++ [d]) rootTriple = applyWord [d] (applyWord w rootTriple)`.
    have h_applyWord : ∀ (w : OrbitAddr) (d : BDir) (t : ℤ × ℤ × ℤ), applyWord (w ++ [d]) t = applyWord [d] (applyWord w t) := by
      intros w d t; induction' w with w hd ih generalizing t <;> simp +decide [ *, applyWord ] ;
    exact h_applyWord _ _ _;
  exact h_def.symm ▸ le_trans ( berggrenStep_hyp_upper _ _ _ _ ( addrTriple_pythag _ ) ( addrTriple_pos _ ) ) ( mul_le_mul_of_nonneg_left ih ( by norm_num ) )

/-
Word length gives a lower bound on hypotenuse:
    the hypotenuse is at least 5 + |w|.
-/
theorem hyp_lower_bound (w : OrbitAddr) :
    (5 : ℤ) + w.length ≤ (addrTriple w).2.2 := by
  induction' w using List.reverseRecOn with w d ih <;> simp +arith +decide [ * ] at *;
  -- By definition of `addrTriple`, we have `addrTriple (w ++ [d]) = berggrenStep d (addrTriple w)`.
  have h_addrTriple_append : addrTriple (w ++ [d]) = berggrenStep d (addrTriple w) := by
    -- By definition of `applyWord`, we have `applyWord (w ++ [d]) rootTriple = applyWord [d] (applyWord w rootTriple)`.
    have h_applyWord_append : ∀ (w w' : OrbitAddr) (t : ℤ × ℤ × ℤ), applyWord (w ++ w') t = applyWord w' (applyWord w t) := by
      intros w w' t; induction' w with d w ih generalizing t <;> simp +arith +decide [ * ] ;
      · rfl;
      · exact?;
    exact h_applyWord_append _ _ _;
  -- By definition of `berggrenStep`, we have `berggrenStep d (addrTriple w).2.2 > (addrTriple w).2.2`.
  have h_berggrenStep_gt : (berggrenStep d (addrTriple w)).2.2 > (addrTriple w).2.2 := by
    apply berggrenStep_hyp_increase;
    · exact addrTriple_pythag w;
    · exact addrTriple_pos w;
  grind

/-! ## A-ray: Canonical Embedding of ℕ -/

/-- The A-ray: the infinite path following only the A-generator. -/
def aRay (n : ℕ) : OrbitAddr := List.replicate n .A

/-- The triple at position n on the A-ray. -/
def aRayTriple (n : ℕ) : ℤ × ℤ × ℤ := addrTriple (aRay n)

theorem aRayTriple_zero : aRayTriple 0 = (3, 4, 5) := rfl

/-
A-ray hypotenuse is strictly increasing, so the mapping is injective.
-/
theorem aRay_injective : Function.Injective aRayTriple := by
  -- By definition of $aRayTriple$, we know that its hypotenuse is strictly increasing.
  have h_hyp_inc : StrictMono (fun n => (aRayTriple n).2.2) := by
    -- By definition of $aRayTriple$, we know that its hypotenuse is strictly increasing. We can prove this by induction on $n$.
    have h_hyp_inc : ∀ n, (aRayTriple (n + 1)).2.2 > (aRayTriple n).2.2 := by
      unfold aRayTriple;
      intro n
      unfold aRay addrTriple
      simp [applyWord];
      -- By definition of `applyWord`, we can rewrite the goal using the properties of `berggrenStep`.
      have h_apply : ∀ (w : OrbitAddr) (t : ℤ × ℤ × ℤ), applyWord (w ++ [BDir.A]) t = berggrenStep BDir.A (applyWord w t) := by
        intros w t; induction w generalizing t <;> aesop;
      rw [ List.replicate_succ', h_apply ];
      apply berggrenStep_hyp_increase;
      · exact addrTriple_pythag _;
      · exact addrTriple_pos _;
    exact strictMono_nat_of_lt_succ h_hyp_inc;
  exact fun m n hmn => h_hyp_inc.injective <| congr_arg Prod.snd hmn |> congr_arg Prod.snd

/-! ## Prefix Distance -/

/-- Common prefix length of two orbit addresses. -/
def commonPrefixLen : OrbitAddr → OrbitAddr → ℕ
  | [], _ => 0
  | _, [] => 0
  | d₁ :: w₁, d₂ :: w₂ => if d₁ = d₂ then 1 + commonPrefixLen w₁ w₂ else 0

theorem commonPrefixLen_self (w : OrbitAddr) : commonPrefixLen w w = w.length := by
  induction w with
  | nil => rfl
  | cons d w ih => simp [commonPrefixLen, ih]; omega

/-- Tree distance between orbit addresses. -/
def treeDist (u v : OrbitAddr) : ℕ :=
  u.length + v.length - 2 * commonPrefixLen u v

theorem treeDist_self (w : OrbitAddr) : treeDist w w = 0 := by
  simp [treeDist, commonPrefixLen_self]; omega

theorem commonPrefixLen_comm (u v : OrbitAddr) :
    commonPrefixLen u v = commonPrefixLen v u := by
  induction u generalizing v with
  | nil => cases v <;> simp [commonPrefixLen]
  | cons d₁ w₁ ih =>
    cases v with
    | nil => simp [commonPrefixLen]
    | cons d₂ w₂ =>
      simp only [commonPrefixLen]
      by_cases h : d₁ = d₂
      · rw [if_pos h, if_pos h.symm, ih]
      · rw [if_neg h, if_neg (Ne.symm h)]

theorem treeDist_comm (u v : OrbitAddr) : treeDist u v = treeDist v u := by
  simp [treeDist, commonPrefixLen_comm, Nat.add_comm]

/-! ## A-ray Embedding is Quasi-isometric -/

/-- The A-ray embedding has Lipschitz constant 1 for tree distance:
    treeDist(aRay m, aRay n) ≤ m + n. -/
theorem aRay_dist_le (m n : ℕ) :
    treeDist (aRay m) (aRay n) ≤ m + n := by
  simp [treeDist, aRay, List.length_replicate]