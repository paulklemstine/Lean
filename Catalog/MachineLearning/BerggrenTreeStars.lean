import MachineLearning.BerggrenChargeQuantization

/-!
# A star at every node: the boundary picture of the whole tree

The previous files show that the parabolic generators produce a star at the two
distinguished ideal points `(1,0)` and `(0,1)`.  The plot, however, shows stars at *many*
boundary points.  This file explains why: the Berggren monoid transports the star.

Because every word `W` in the generators is a Lorentz isometry, it maps the horocycle
based at `(1,0)` to a horocycle based at `W·(1,0,1)`, preserving the charge.  Since
`mA (1,0,1) = mB (1,0,1) = (3,4,5) = root` and `mC (1,0,1) = (1,0,1)`, the orbit of the
ideal point `(1,0)` under the monoid is exactly `{(1,0)} ∪ {ideal points of tree nodes}`.
Hence:

**every node of the tree is itself the centre of a star.**

The star at the node `v = W·root` is the family `j ↦ W·(mA (mC^j root))`, i.e. the
descendants of `v` reached by the word `mC^j` read in the *middle* of the address; its
Lorentz charge relative to `v` is the constant `2`, inherited from the root.

## Main results

* `adm_applyWord`, `hyp_mono_applyWord` — the monoid preserves admissibility (cone,
  nonnegative legs, positive hypotenuse) and never decreases the hypotenuse.
* `bil_applyWord` — words act by Lorentz isometries.
* `star_at_every_tree_node` — for every word `W`, the plotted points of the family
  `j ↦ W·(mA (mC^j root))` converge to the plotted point of the node `W·root`.
* `star_at_root` — the special case: the root `(3,4,5)` is itself a star centre.
-/

namespace BerggrenStars

open Filter Topology

/-- Applying a word (a list of generators) to a vector. -/
def applyWord (W : List (Vec → Vec)) (v : Vec) : Vec := W.foldr (fun f x => f x) v

/-- A word of Berggren generators. -/
def IsBerggrenWord (W : List (Vec → Vec)) : Prop := ∀ f ∈ W, f = mA ∨ f = mB ∨ f = mC

@[simp] theorem applyWord_nil (v : Vec) : applyWord [] v = v := rfl

@[simp] theorem applyWord_cons (f : Vec → Vec) (W : List (Vec → Vec)) (v : Vec) :
    applyWord (f :: W) v = f (applyWord W v) := rfl

theorem applyWord_append (W V : List (Vec → Vec)) (v : Vec) :
    applyWord (W ++ V) v = applyWord W (applyWord V v) := by
  simp [applyWord, List.foldr_append]

/-- Admissible vectors: the future light cone with nonnegative legs. -/
def Adm (v : Vec) : Prop := OnCone v ∧ 0 ≤ v.1 ∧ 0 ≤ v.2.1 ∧ 0 < v.2.2

theorem Adm.leg_le_hyp {v : Vec} (h : Adm v) : v.1 ≤ v.2.2 ∧ v.2.1 ≤ v.2.2 := by
  obtain ⟨hcone, h1, h2, h3⟩ := h
  obtain ⟨a, b, c⟩ := v
  simp only at h1 h2 h3 ⊢
  rw [onCone_iff] at hcone
  constructor <;> nlinarith

theorem adm_mA {v : Vec} (h : Adm v) : Adm (mA v) := by
  obtain ⟨hle1, hle2⟩ := h.leg_le_hyp
  obtain ⟨hcone, h1, h2, h3⟩ := h
  obtain ⟨a, b, c⟩ := v
  simp only at h1 h2 h3 hle1 hle2
  exact ⟨onCone_mA hcone, by simp only [mA]; omega, by simp only [mA]; omega,
    by simp only [mA]; omega⟩

theorem adm_mB {v : Vec} (h : Adm v) : Adm (mB v) := by
  obtain ⟨hcone, h1, h2, h3⟩ := h
  obtain ⟨a, b, c⟩ := v
  simp only at h1 h2 h3
  exact ⟨onCone_mB hcone, by simp only [mB]; omega, by simp only [mB]; omega,
    by simp only [mB]; omega⟩

theorem adm_mC {v : Vec} (h : Adm v) : Adm (mC v) := by
  obtain ⟨hle1, hle2⟩ := h.leg_le_hyp
  obtain ⟨hcone, h1, h2, h3⟩ := h
  obtain ⟨a, b, c⟩ := v
  simp only at h1 h2 h3 hle1 hle2
  exact ⟨onCone_mC hcone, by simp only [mC]; omega, by simp only [mC]; omega,
    by simp only [mC]; omega⟩

theorem adm_applyWord {W : List (Vec → Vec)} (hW : IsBerggrenWord W) {v : Vec} (h : Adm v) :
    Adm (applyWord W v) := by
  induction W with
  | nil => simpa using h
  | cons f t ih =>
      have ht : IsBerggrenWord t := fun g hg => hW g (List.mem_cons_of_mem _ hg)
      have hrec := ih ht
      rcases hW f (List.mem_cons_self ..) with rfl | rfl | rfl
      · simpa using adm_mA hrec
      · simpa using adm_mB hrec
      · simpa using adm_mC hrec

/-- The generators never decrease the hypotenuse on admissible vectors. -/
theorem hyp_mono_gen {v : Vec} (h : Adm v) :
    v.2.2 ≤ (mA v).2.2 ∧ v.2.2 ≤ (mB v).2.2 ∧ v.2.2 ≤ (mC v).2.2 := by
  obtain ⟨hle1, hle2⟩ := h.leg_le_hyp
  obtain ⟨hcone, h1, h2, h3⟩ := h
  obtain ⟨a, b, c⟩ := v
  simp only at h1 h2 h3 hle1 hle2
  refine ⟨?_, ?_, ?_⟩ <;> simp only [mA, mB, mC] <;> omega

theorem hyp_mono_applyWord {W : List (Vec → Vec)} (hW : IsBerggrenWord W) {v : Vec}
    (h : Adm v) : v.2.2 ≤ (applyWord W v).2.2 := by
  induction W with
  | nil => simp
  | cons f t ih =>
      have ht : IsBerggrenWord t := fun g hg => hW g (List.mem_cons_of_mem _ hg)
      have hrec := ih ht
      have hadm : Adm (applyWord t v) := adm_applyWord ht h
      obtain ⟨hA, hB, hC⟩ := hyp_mono_gen hadm
      rcases hW f (List.mem_cons_self ..) with rfl | rfl | rfl
      · exact le_trans hrec hA
      · exact le_trans hrec hB
      · exact le_trans hrec hC

/-- Words act by Lorentz isometries: the charge is a word-invariant. -/
theorem bil_applyWord {W : List (Vec → Vec)} (hW : IsBerggrenWord W) (v p : Vec) :
    bil (applyWord W v) (applyWord W p) = bil v p := by
  induction W with
  | nil => simp
  | cons f t ih =>
      have ht : IsBerggrenWord t := fun g hg => hW g (List.mem_cons_of_mem _ hg)
      have hrec := ih ht
      rcases hW f (List.mem_cons_self ..) with rfl | rfl | rfl
      · rw [applyWord_cons, applyWord_cons, bil_mA]; exact hrec
      · rw [applyWord_cons, applyWord_cons, bil_mB]; exact hrec
      · rw [applyWord_cons, applyWord_cons, bil_mC]; exact hrec

theorem adm_e1 : Adm (1, 0, 1) := ⟨onCone_e1, by norm_num, by norm_num, by norm_num⟩

theorem adm_root : Adm root := ⟨onCone_root, by norm_num [root], by norm_num [root],
  by norm_num [root]⟩

/-- The parabolic fixed point is carried to the root by the first two generators; this is
why the star gets transported to every node of the tree. -/
theorem mA_e1_eq_root : mA (1, 0, 1) = root := by decide

theorem adm_mC_iterate_root (j : ℕ) : Adm (mC^[j] root) := by
  induction j with
  | zero => simpa using adm_root
  | succ n ih => rw [Function.iterate_succ_apply']; exact adm_mC ih

/-- The `mC`-ray out of the root has charge `2` relative to the ideal point `(1,0)`. -/
theorem charge_mC_iterate_root (j : ℕ) : bil (mC^[j] root) (1, 0, 1) = -2 := by
  rw [bil_with_e1]
  have := mC_iterate_charge root j
  simp only [root] at this ⊢
  omega

theorem hyp_mC_iterate_root_ge (j : ℕ) : (j : ℤ) < (mC^[j] root).2.2 := by
  simpa [root] using
    mC_iterate_hyp_ge (a := 3) (b := 4) (c := 5) (by simpa [root] using onCone_root)
      (by norm_num) (by norm_num) j

/-- **A star at every node of the tree.**  Fix any node `W·root` of the Berggren tree.
Then the tree contains a family of nodes — the images under `W` of the `mC`-ray out of the
root — whose plotted points converge to the plotted point of `W·root`.  Every node of the
tree is therefore the centre of a star of curves in the disc. -/
theorem star_at_every_tree_node {W : List (Vec → Vec)} (hW : IsBerggrenWord W) :
    Tendsto (fun j => dirx (applyWord W (mA (mC^[j] root)))) atTop
        (𝓝 (dirx (applyWord W root))) ∧
      Tendsto (fun j => diry (applyWord W (mA (mC^[j] root)))) atTop
        (𝓝 (diry (applyWord W root))) := by
  have hp : Adm (applyWord W root) := adm_applyWord hW adm_root
  have hwj : ∀ j : ℕ, Adm (applyWord W (mA (mC^[j] root))) := fun j =>
    adm_applyWord hW (adm_mA (adm_mC_iterate_root j))
  have hgrowj : ∀ j : ℕ, (j : ℤ) < (applyWord W (mA (mC^[j] root))).2.2 := by
    intro j
    have h1 : (mA (mC^[j] root)).2.2 ≤ (applyWord W (mA (mC^[j] root))).2.2 :=
      hyp_mono_applyWord hW (adm_mA (adm_mC_iterate_root j))
    have h2 : (mC^[j] root).2.2 ≤ (mA (mC^[j] root)).2.2 :=
      (hyp_mono_gen (adm_mC_iterate_root j)).1
    have h3 := hyp_mC_iterate_root_ge j
    omega
  refine tendsto_dir_of_constant_charge (applyWord W root) hp.1 hp.2.2.2
    (fun j => applyWord W (mA (mC^[j] root))) (fun j => (hwj j).1) (fun j => (hwj j).2.2.2) 2 ?_ ?_
  · intro j
    show bil (applyWord W (mA (mC^[j] root))) (applyWord W root) = -2
    have hroot : applyWord W root = applyWord W (mA (1, 0, 1)) := by rw [mA_e1_eq_root]
    rw [hroot]
    have h1 : applyWord W (mA (mC^[j] root)) = applyWord W (applyWord [mA] (mC^[j] root)) := rfl
    have h2 : applyWord W (mA (1, 0, 1)) = applyWord W (applyWord [mA] (1, 0, 1)) := rfl
    rw [h1, h2, ← applyWord_append, ← applyWord_append,
      bil_applyWord (W := W ++ [mA]) ?_ (mC^[j] root) (1, 0, 1)]
    · exact charge_mC_iterate_root j
    · intro f hf
      rcases List.mem_append.mp hf with hf' | hf'
      · exact hW f hf'
      · simp at hf'; exact Or.inl hf'
  · apply tendsto_atTop_mono (f := fun j : ℕ => (j : ℝ))
    · intro j; exact_mod_cast (hgrowj j).le
    · exact tendsto_natCast_atTop_atTop

/-- The root is a star centre: the family `mA (mC^j (3,4,5))` converges to `(3/5, 4/5)`. -/
theorem star_at_root :
    Tendsto (fun j => dirx (mA (mC^[j] root))) atTop (𝓝 (3 / 5)) ∧
      Tendsto (fun j => diry (mA (mC^[j] root))) atTop (𝓝 (4 / 5)) := by
  have h := star_at_every_tree_node (W := []) (by intro f hf; simp at hf)
  simpa [applyWord, dirx, diry, root] using h

end BerggrenStars