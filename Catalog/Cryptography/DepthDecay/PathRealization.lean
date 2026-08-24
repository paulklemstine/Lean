import Cryptography.DepthDecay.WindowSensor

/-!
# Realizing paths, and an entropy form of the depth decay

The first two files study the descent map `parent` and what a fixed-precision
magnitude probe can read off it.  Here we go the other way: we *build* states
from words, prove that the descent reads the word back letter by letter, and use
that to obtain a counting (pigeonhole) form of the depth decay which is
independent of the explicit straddling construction of
`Cryptography.DepthDecay.NullBeyondInversion`.

## Main results

* `Adm.child`, `letterOf_child`, `parent_child` : the three Berggren children are
  admissibility-preserving sections of the descent, and each child is tagged by
  its own letter.
* `letterAt_build` : the descent path of `build w` is the word `w`.  Every word
  is realized, so the tree really carries `3^k` distinct depth-`k` behaviours.
* `probe_mem_Ico` : on the stratum of states built from `{A,B}`-words the ratio
  stays in `(1,3)`, so a `W`-window probe takes at most `2·2^W` distinct values
  there.
* `probe_collision_of_depth` : **entropy form of the depth decay.**  Once
  `2·2^W < 2^k`, i.e. once the depth exceeds the window budget by two bits, the
  `W`-window sensor must confuse two admissible states whose paths differ at some
  depth below `k`.  The magnitude channel simply does not have the capacity to
  carry the deep letters.
-/

namespace DepthDecay

/-- The three Berggren children in `(m,n)` coordinates. -/
def child : Letter → ℕ × ℕ → ℕ × ℕ
  | Letter.A, s => (2 * s.1 - s.2, s.1)
  | Letter.B, s => (2 * s.1 + s.2, s.1)
  | Letter.C, s => (s.1 + 2 * s.2, s.2)

/-- The state built from a word, the head of the word being the last child taken
(hence the first letter of the descent). -/
def build : List Letter → ℕ × ℕ
  | [] => root
  | x :: w => child x (build w)

theorem adm_root : Adm root := by
  refine ⟨by norm_num [root], by norm_num [root], by norm_num [root], by norm_num [root]⟩

/-- Each Berggren child of an admissible state is admissible. -/
theorem Adm.child {s : ℕ × ℕ} (h : Adm s) (x : Letter) : Adm (DepthDecay.child x s) := by
  obtain ⟨hp, hlt, hg, hpar⟩ := h
  cases x with
  | A =>
    refine ⟨by simp [DepthDecay.child]; omega, by simp [DepthDecay.child]; omega, ?_,
      by simp [DepthDecay.child]; omega⟩
    have hdvd : Nat.gcd (2 * s.1 - s.2) s.1 ∣ Nat.gcd s.1 s.2 := by
      refine Nat.dvd_gcd (Nat.gcd_dvd_right _ _) ?_
      have h1 : Nat.gcd (2 * s.1 - s.2) s.1 ∣ 2 * s.1 :=
        Dvd.dvd.mul_left (Nat.gcd_dvd_right _ _) 2
      have h2 : Nat.gcd (2 * s.1 - s.2) s.1 ∣ 2 * s.1 - s.2 := Nat.gcd_dvd_left _ _
      have h3 := Nat.dvd_sub h1 h2
      rwa [show 2 * s.1 - (2 * s.1 - s.2) = s.2 by omega] at h3
    rw [hg] at hdvd
    simpa [DepthDecay.child] using Nat.eq_one_of_dvd_one hdvd
  | B =>
    refine ⟨by simp [DepthDecay.child]; omega, by simp [DepthDecay.child]; omega, ?_,
      by simp [DepthDecay.child]; omega⟩
    have hdvd : Nat.gcd (2 * s.1 + s.2) s.1 ∣ Nat.gcd s.1 s.2 := by
      refine Nat.dvd_gcd (Nat.gcd_dvd_right _ _) ?_
      have h1 : Nat.gcd (2 * s.1 + s.2) s.1 ∣ 2 * s.1 :=
        Dvd.dvd.mul_left (Nat.gcd_dvd_right _ _) 2
      have h2 : Nat.gcd (2 * s.1 + s.2) s.1 ∣ 2 * s.1 + s.2 := Nat.gcd_dvd_left _ _
      have h3 := Nat.dvd_sub h2 h1
      rwa [show 2 * s.1 + s.2 - 2 * s.1 = s.2 by omega] at h3
    rw [hg] at hdvd
    simpa [DepthDecay.child] using Nat.eq_one_of_dvd_one hdvd
  | C =>
    refine ⟨by simp [DepthDecay.child]; omega, by simp [DepthDecay.child]; omega, ?_,
      by simp [DepthDecay.child]; omega⟩
    have hdvd : Nat.gcd (s.1 + 2 * s.2) s.2 ∣ Nat.gcd s.1 s.2 := by
      refine Nat.dvd_gcd ?_ (Nat.gcd_dvd_right _ _)
      have h1 : Nat.gcd (s.1 + 2 * s.2) s.2 ∣ 2 * s.2 :=
        Dvd.dvd.mul_left (Nat.gcd_dvd_right _ _) 2
      have h2 : Nat.gcd (s.1 + 2 * s.2) s.2 ∣ s.1 + 2 * s.2 := Nat.gcd_dvd_left _ _
      have h3 := Nat.dvd_sub h2 h1
      rwa [show s.1 + 2 * s.2 - 2 * s.2 = s.1 by omega] at h3
    rw [hg] at hdvd
    simpa [DepthDecay.child] using Nat.eq_one_of_dvd_one hdvd

/-- Each child is tagged by its own descent letter. -/
theorem letterOf_child {s : ℕ × ℕ} (h : Adm s) (x : Letter) :
    letterOf (DepthDecay.child x s) = x := by
  obtain ⟨hp, hlt, _, _⟩ := h
  cases x with
  | A => simp [letterOf, DepthDecay.child]; omega
  | B =>
    have h1 : ¬ (2 * s.1 + s.2 < 2 * s.1) := by omega
    have h2 : 2 * s.1 + s.2 < 3 * s.1 := by omega
    simp [letterOf, DepthDecay.child, h1, h2]
  | C =>
    have h1 : ¬ (s.1 + 2 * s.2 < 2 * s.2) := by omega
    have h2 : ¬ (s.1 + 2 * s.2 < 3 * s.2) := by omega
    simp [letterOf, DepthDecay.child, h1, h2]

/-- The descent undoes each child. -/
theorem parent_child {s : ℕ × ℕ} (h : Adm s) (x : Letter) :
    parent (DepthDecay.child x s) = s := by
  obtain ⟨hp, hlt, _, _⟩ := h
  cases x with
  | A =>
    have h1 : 2 * s.1 - s.2 < 2 * s.1 := by omega
    have harith : 2 * s.1 - (2 * s.1 - s.2) = s.2 := by omega
    simp only [parent, DepthDecay.child, h1, if_true, harith]
  | B =>
    have h1 : ¬ (2 * s.1 + s.2 < 2 * s.1) := by omega
    have h2 : 2 * s.1 + s.2 < 3 * s.1 := by omega
    have harith : 2 * s.1 + s.2 - 2 * s.1 = s.2 := by omega
    simp only [parent, DepthDecay.child, h1, h2, if_true, if_false, harith]
  | C =>
    have h1 : ¬ (s.1 + 2 * s.2 < 2 * s.2) := by omega
    have h2 : ¬ (s.1 + 2 * s.2 < 3 * s.2) := by omega
    have harith : s.1 + 2 * s.2 - 2 * s.2 = s.1 := by omega
    simp only [parent, DepthDecay.child, h1, h2, if_false, harith]

theorem adm_build : ∀ w : List Letter, Adm (build w)
  | [] => adm_root
  | x :: w => (adm_build w).child x

/-- **Every word is realized.**  The descent path of `build w` reads back `w`. -/
theorem letterAt_build : ∀ (w : List Letter) (j : ℕ) (hj : j < w.length),
    letterAt j (build w) = w[j] := by
  intro w
  induction w with
  | nil => intro j hj; simp at hj
  | cons x w ih =>
    intro j hj
    cases j with
    | zero => simpa [letterAt, build] using letterOf_child (adm_build w) x
    | succ j =>
      rw [letterAt_succ, build, parent_child (adm_build w) x]
      simpa using ih j (by simpa using hj)

/-! ### The bounded-ratio stratum -/

/-- Words over `{A,B}` keep the ratio below `3`. -/
theorem build_lt_three : ∀ w : List Letter, (∀ x ∈ w, x = Letter.A ∨ x = Letter.B) →
    (build w).1 < 3 * (build w).2
  | [], _ => by norm_num [build, root]
  | x :: w, hw => by
    have hAdm := adm_build w
    obtain ⟨hp, hlt, _, _⟩ := hAdm
    rcases hw x (by simp) with h | h <;> subst h
    · simp [build, DepthDecay.child]; omega
    · simp [build, DepthDecay.child]; omega

/-- On that stratum the `W`-window probe takes at most `2·2^W` values. -/
theorem probe_mem_Ico (W : ℕ) (w : List Letter) (hw : ∀ x ∈ w, x = Letter.A ∨ x = Letter.B) :
    probe W (build w) ∈ Finset.Ico (2 ^ W) (3 * 2 ^ W) := by
  have hAdm := adm_build w
  obtain ⟨hp, hlt, _, _⟩ := hAdm
  have h3 := build_lt_three w hw
  have hpow : 0 < 2 ^ W := Nat.two_pow_pos W
  refine Finset.mem_Ico.2 ⟨?_, ?_⟩
  · exact (Nat.le_div_iff_mul_le hp).2 (by nlinarith)
  · exact (Nat.div_lt_iff_lt_mul hp).2 (by nlinarith)

/-- The `{A,B}`-word attached to a Boolean vector. -/
def boolWord {k : ℕ} (v : Fin k → Bool) : List Letter :=
  List.ofFn (fun i : Fin k => if v i then Letter.A else Letter.B)

theorem boolWord_length {k : ℕ} (v : Fin k → Bool) : (boolWord v).length = k := by
  simp [boolWord]

theorem boolWord_mem {k : ℕ} (v : Fin k → Bool) :
    ∀ x ∈ boolWord v, x = Letter.A ∨ x = Letter.B := by
  intro x hx
  rw [boolWord, List.mem_ofFn] at hx
  obtain ⟨i, hi⟩ := hx
  by_cases hv : v i <;> simp [hv] at hi <;> simp [← hi]

theorem letterAt_boolWord {k : ℕ} (v : Fin k → Bool) (j : ℕ) (hj : j < k) :
    letterAt j (build (boolWord v)) = if v ⟨j, hj⟩ then Letter.A else Letter.B := by
  have hlen : j < (boolWord v).length := by simpa [boolWord_length] using hj
  rw [letterAt_build (boolWord v) j hlen]
  simp [boolWord]

/-! ### Entropy form of the depth decay -/

/-- **Capacity bound.**  As soon as the depth `k` exceeds the window budget by two
bits (`2 · 2^W < 2^k`), the `W`-window magnitude sensor confuses two admissible
states whose descent paths already differ at a depth below `k`.  No fixed-budget
magnitude functional can transmit `k` letters of the path. -/
theorem probe_collision_of_depth (W k : ℕ) (hk : 2 * 2 ^ W < 2 ^ k) :
    ∃ s s' : ℕ × ℕ, Adm s ∧ Adm s' ∧ probe W s = probe W s' ∧
      ∃ j < k, letterAt j s ≠ letterAt j s' := by
  classical
  have hcard : (Finset.Ico (2 ^ W) (3 * 2 ^ W)).card <
      (Finset.univ : Finset (Fin k → Bool)).card := by
    simp [Nat.card_Ico]
    omega
  obtain ⟨v, -, v', -, hne, heq⟩ :=
    Finset.exists_ne_map_eq_of_card_lt_of_maps_to hcard
      (f := fun v : Fin k → Bool => probe W (build (boolWord v)))
      (fun v _ => probe_mem_Ico W (boolWord v) (boolWord_mem v))
  obtain ⟨i, hi⟩ := Function.ne_iff.1 hne
  refine ⟨build (boolWord v), build (boolWord v'), adm_build _, adm_build _, heq, i, i.isLt, ?_⟩
  rw [letterAt_boolWord v i i.isLt, letterAt_boolWord v' i i.isLt]
  cases hv : v i <;> cases hv' : v' i <;> simp [hv, hv'] at hi ⊢

end DepthDecay