module

public import Catalog.Geometry.DualityMoves.Classification

/-!
# Verdict on the double-minus-move conjecture

*Conjecture.*  Two duality eigensystems of the same degree (and weight) have the
same sign iff they are related by twists, permutations and insertions/deletions
of pairs of `-Q` fixed points.

* The "if" direction is true in every degree: `Moves.sign_eq`.
* The "only if" direction (completeness) holds in degree `d` **iff `d ≤ 1`**
  (`conjectureInDegree_iff`).  For every `d ≥ 2` the eigensystems
  `[n s, s/n, s, …, s]` with `n = 2, 3, 4, …` all have sign `+1` but are pairwise
  not move-equivalent (`fam_moves_iff`), so a single sign class contains
  infinitely many move classes: the core (the non-fixed eigenvalues, up to the
  twist `α ↦ -α`) is a finer invariant than the fixed-point parity, and by
  `moves_iff_core` it is, together with fixed-point counts, the *complete*
  invariant.
* Completeness does hold for *core-free* (all eigenvalues `±√Q`) eigensystems of
  even degree (`complete_coreFree_even`), and fails for core-free ones of odd
  degree `≥ 3` (`coreFree_odd_counterexample`).
-/

@[expose] public section

noncomputable section

namespace DualityMoves

/-- Completeness of the moves in degree `d`: equal sign implies move-equivalence. -/
def ConjectureInDegree (s : ℂ) (d : ℕ) : Prop :=
  ∀ l l' : List ℂ, IsEigensystem s l → IsEigensystem s l' → l.length = d → l'.length = d →
    sign s l = sign s l' → Moves s l l'

/-- The test family `[n s, s / n, s, …, s]` (`k` trailing copies of `s`). -/
def fam (s : ℂ) (n k : ℕ) : List ℂ := (n : ℂ) * s :: s / n :: List.replicate k s

section Arith

variable {s : ℂ} (hs : s ≠ 0)
include hs

lemma natMul_ne_s {n : ℕ} (hn : 2 ≤ n) : (n : ℂ) * s ≠ s := by
  intro h
  have : ((n : ℂ) - 1) * s = 0 := by linear_combination h
  rcases mul_eq_zero.1 this with h1 | h1
  · have : (n : ℂ) = (1 : ℕ) := by push_cast; linear_combination h1
    have := Nat.cast_injective this; omega
  · exact hs h1

lemma natMul_ne_neg_s {n : ℕ} : (n : ℂ) * s ≠ -s := by
  intro h
  have : ((n : ℂ) + 1) * s = 0 := by linear_combination h
  rcases mul_eq_zero.1 this with h1 | h1
  · have : ((n + 1 : ℕ) : ℂ) = (0 : ℕ) := by push_cast; linear_combination h1
    have := Nat.cast_injective this; omega
  · exact hs h1

lemma natMul_ne_div {n m : ℕ} (hn : 2 ≤ n) (hm : 2 ≤ m) : (n : ℂ) * s ≠ s / m := by
  intro h
  have hm0 : (m : ℂ) ≠ 0 := by exact_mod_cast (show m ≠ 0 by omega)
  rw [eq_div_iff hm0] at h
  have : ((n : ℂ) * m - 1) * s = 0 := by linear_combination h
  rcases mul_eq_zero.1 this with h1 | h1
  · have : ((n * m : ℕ) : ℂ) = (1 : ℕ) := by push_cast; linear_combination h1
    have := Nat.cast_injective this
    nlinarith
  · exact hs h1

lemma negNatMul_ne_div {n m : ℕ} (hm : 2 ≤ m) : -((n : ℂ) * s) ≠ s / m := by
  intro h
  have hm0 : (m : ℂ) ≠ 0 := by exact_mod_cast (show m ≠ 0 by omega)
  rw [eq_div_iff hm0] at h
  have : ((n : ℂ) * m + 1) * s = 0 := by linear_combination -h
  rcases mul_eq_zero.1 this with h1 | h1
  · have : ((n * m + 1 : ℕ) : ℂ) = (0 : ℕ) := by push_cast; linear_combination h1
    have := Nat.cast_injective this; omega
  · exact hs h1

lemma natMul_inj {n m : ℕ} (h : (n : ℂ) * s = (m : ℂ) * s) : n = m := by
  exact_mod_cast mul_right_cancel₀ hs h

lemma negNatMul_ne_natMul {n m : ℕ} (hn : 2 ≤ n) : -((n : ℂ) * s) ≠ (m : ℂ) * s := by
  intro h
  have : (((n + m : ℕ) : ℂ)) * s = 0 := by push_cast; linear_combination -h
  rcases mul_eq_zero.1 this with h1 | h1
  · have := Nat.cast_injective (h1.trans (Nat.cast_zero).symm); omega
  · exact hs h1

lemma div_ne_s {n : ℕ} (hn : 2 ≤ n) : s / n ≠ s := by
  intro h
  have hn0 : (n : ℂ) ≠ 0 := by exact_mod_cast (show n ≠ 0 by omega)
  apply natMul_ne_s hs hn
  rw [div_eq_iff hn0] at h; linear_combination -h

lemma div_ne_neg_s {n : ℕ} (hn : 2 ≤ n) : s / n ≠ -s := by
  intro h
  have hn0 : (n : ℂ) ≠ 0 := by exact_mod_cast (show n ≠ 0 by omega)
  apply natMul_ne_neg_s hs (n := n)
  rw [div_eq_iff hn0] at h; linear_combination h

end Arith

/-- The test family consists of duality eigensystems. -/
lemma fam_isEigensystem (s : ℂ) (hs : s ≠ 0) (n k : ℕ) (hn : 2 ≤ n) :
    IsEigensystem s (fam s n k) := by
  have hn0 : (n : ℂ) ≠ 0 := by exact_mod_cast (show n ≠ 0 by omega)
  refine ⟨?_, ?_⟩
  · intro a ha
    simp only [fam, List.mem_cons, List.mem_replicate] at ha
    rcases ha with rfl | rfl | ⟨_, rfl⟩
    · exact mul_ne_zero hn0 hs
    · exact div_ne_zero hs hn0
    · exact hs
  · have h1 : dual s ((n : ℂ) * s) = s / n := by unfold dual; field_simp
    have h2 : dual s (s / n) = (n : ℂ) * s := by unfold dual; field_simp
    have h3 : (List.replicate k s).map (dual s) = List.replicate k s := by
      rw [List.map_replicate, dual_self_s s hs]
    simp only [fam, List.map_cons, h1, h2, h3]
    exact List.Perm.swap _ _ _

/-- Every member of the test family has sign `+1`. -/
lemma fam_sign (s : ℂ) (hs : s ≠ 0) (n k : ℕ) (hn : 2 ≤ n) : sign s (fam s n k) = 1 := by
  rw [sign_eq s hs _ (fam_isEigensystem s hs n k hn)]
  have hsn : s ≠ -s := fun h => hs (by linear_combination h / 2)
  have : negFix s (fam s n k) = 0 := by
    unfold negFix fam
    apply List.count_eq_zero_of_not_mem
    simp only [List.mem_cons, List.mem_replicate, not_or]
    exact ⟨(natMul_ne_neg_s hs).symm, (div_ne_neg_s hs hn).symm, fun h => hsn h.2.symm⟩
  rw [this, pow_zero]

/-- **Finer invariant.**  Members of the test family (same degree `k + 2`, same
sign `+1`) are move-equivalent only when they coincide. -/
theorem fam_moves_iff (s : ℂ) (hs : s ≠ 0) (n m k : ℕ) (hn : 2 ≤ n) (hm : 2 ≤ m) :
    Moves s (fam s n k) (fam s m k) ↔ n = m := by
  constructor
  · intro h
    have hx1 := natMul_ne_s hs hn
    have hx2 := natMul_ne_neg_s hs (n := n)
    obtain ⟨hy1, hy2⟩ := neg_ne_pm hx1 hx2
    have hpos : 0 < (fam s n k).count ((n : ℂ) * s) := by
      rw [List.count_pos_iff]; simp [fam]
    rcases h.relR hs with ⟨h1, -, -⟩ | ⟨h1, -, -⟩
    · have := h1 _ hx1 hx2
      rw [← this, List.count_pos_iff] at hpos
      simp only [fam, List.mem_cons, List.mem_replicate] at hpos
      rcases hpos with h' | h' | ⟨_, h'⟩
      · exact natMul_inj hs h'
      · exact absurd h' (natMul_ne_div hs hn hm)
      · exact absurd h' hx1
    · have := h1 _ hy1 hy2
      rw [neg_neg] at this
      rw [← this, List.count_pos_iff] at hpos
      simp only [fam, List.mem_cons, List.mem_replicate] at hpos
      rcases hpos with h' | h' | ⟨_, h'⟩
      · exact absurd h' (negNatMul_ne_natMul hs hn)
      · exact absurd h' (negNatMul_ne_div hs hm)
      · exact absurd h' hy1
  · rintro rfl; exact Moves.perm (List.Perm.refl _)

/-- **The conjecture fails in every degree `d ≥ 2`.** -/
theorem not_conjectureInDegree (s : ℂ) (hs : s ≠ 0) (d : ℕ) (hd : 2 ≤ d) :
    ¬ ConjectureInDegree s d := by
  intro H
  have h := H (fam s 2 (d - 2)) (fam s 3 (d - 2)) (fam_isEigensystem s hs 2 _ le_rfl)
    (fam_isEigensystem s hs 3 _ (by norm_num)) (by simp [fam]; omega) (by simp [fam]; omega)
    (by rw [fam_sign s hs 2 _ le_rfl, fam_sign s hs 3 _ (by norm_num)])
  have := (fam_moves_iff s hs 2 3 (d - 2) le_rfl (by norm_num)).1 h
  omega

/-- A singleton eigensystem is `[s]` or `[-s]`. -/
lemma singleton_eigen {s a : ℂ} (h : IsEigensystem s [a]) : a = s ∨ a = -s := by
  have ha := h.1 a (by simp)
  have hp := h.2
  simp only [List.map_cons, List.map_nil] at hp
  have : dual s a = a := by simpa using hp
  exact (dual_eq_self_iff ha).1 this

/-- **The conjecture holds in degrees `0` and `1`.** -/
theorem conjectureInDegree_le_one (s : ℂ) (hs : s ≠ 0) (d : ℕ) (hd : d ≤ 1) :
    ConjectureInDegree s d := by
  intro l l' hl hl' hld hld' hsign
  have hsn : s ≠ -s := fun h => hs (by linear_combination h / 2)
  rcases Nat.le_one_iff_eq_zero_or_eq_one.1 hd with rfl | rfl
  · rw [List.length_eq_zero_iff.1 hld, List.length_eq_zero_iff.1 hld']
    exact Moves.perm (List.Perm.refl _)
  · obtain ⟨a, rfl⟩ := List.length_eq_one_iff.1 hld
    obtain ⟨b, rfl⟩ := List.length_eq_one_iff.1 hld'
    have hpar := (sign_eq_sign_iff s hs _ _ hl hl').1 hsign
    have hab : a = b := by
      rcases singleton_eigen hl with rfl | rfl <;> rcases singleton_eigen hl' with rfl | rfl
      · rfl
      · simp [negFix, hsn] at hpar
      · simp [negFix, hsn] at hpar
      · rfl
    subst hab
    exact Moves.perm (List.Perm.refl _)

/-- **Exact boundary of the conjecture.**  Completeness of the moves holds in
degree `d` if and only if `d ≤ 1`. -/
theorem conjectureInDegree_iff (s : ℂ) (hs : s ≠ 0) (d : ℕ) :
    ConjectureInDegree s d ↔ d ≤ 1 := by
  constructor
  · intro H
    by_contra h
    exact not_conjectureInDegree s hs d (by omega) H
  · exact conjectureInDegree_le_one s hs d

/-- **Completeness for core-free eigensystems of even degree.**  If all
eigenvalues are `±√Q` and the common degree is even, equal sign implies
move-equivalence. -/
theorem complete_coreFree_even (s : ℂ) (hs : s ≠ 0) (l l' : List ℂ)
    (hl : ∀ a ∈ l, a = s ∨ a = -s) (hl' : ∀ a ∈ l', a = s ∨ a = -s)
    (hlen : l.length = l'.length) (he : l.length % 2 = 0) (hsign : sign s l = sign s l') :
    Moves s l l' := by
  have eig : ∀ L : List ℂ, (∀ a ∈ L, a = s ∨ a = -s) → IsEigensystem s L := by
    intro L hL
    refine ⟨fun a ha => ?_, ?_⟩
    · rcases hL a ha with rfl | rfl
      · exact hs
      · exact neg_ne_zero.2 hs
    · have : L.map (dual s) = L := by
        conv_rhs => rw [← List.map_id L]
        apply List.map_congr_left
        intro a ha
        rcases hL a ha with rfl | rfl
        · exact dual_self_s _ hs
        · exact dual_self_neg_s s hs
      rw [this]
  have hpar := (sign_eq_sign_iff s hs l l' (eig l hl) (eig l' hl')).1 hsign
  have hcore : ∀ L : List ℂ, (∀ a ∈ L, a = s ∨ a = -s) → (coreList s L).length = 0 := by
    intro L hL
    rw [List.length_eq_zero_iff, coreList, List.filter_eq_nil_iff]
    intro a ha
    rcases hL a ha with rfl | rfl <;> simp
  have e1 := length_eq_counts s hs l
  have e2 := length_eq_counts s hs l'
  rw [hcore l hl] at e1
  rw [hcore l' hl'] at e2
  unfold negFix at hpar
  rw [moves_iff s hs]
  refine Or.inr ⟨he, Or.inl ⟨fun x h1 h2 => ?_, by omega, by omega⟩⟩
  rw [List.count_eq_zero_of_not_mem (fun hx => (hl' x hx).elim h1 h2),
    List.count_eq_zero_of_not_mem (fun hx => (hl x hx).elim h1 h2)]

/-- **Core-free counterexample in odd degree.**  `[s, s, s]` and `[s, -s, -s]`
are eigensystems of degree `3` with the same sign `+1`, but are not
move-equivalent (in odd degree the number of `+Q` fixed points is invariant). -/
theorem coreFree_odd_counterexample (s : ℂ) (hs : s ≠ 0) :
    IsEigensystem s [s, s, s] ∧ IsEigensystem s [s, -s, -s] ∧
      sign s [s, s, s] = sign s [s, -s, -s] ∧ ¬ Moves s [s, s, s] [s, -s, -s] := by
  have hsn : s ≠ -s := fun h => hs (by linear_combination h / 2)
  have hn : -s ≠ 0 := neg_ne_zero.2 hs
  have e1 : IsEigensystem s [s, s, s] :=
    ⟨by simp [hs], by simp [dual_self_s s hs]⟩
  have e2 : IsEigensystem s [s, -s, -s] :=
    ⟨by simp [hs], by simp [dual_self_s s hs, dual_self_neg_s s hs]⟩
  refine ⟨e1, e2, ?_, ?_⟩
  · rw [sign_eq_sign_iff s hs _ _ e1 e2]
    simp [negFix, hsn]
  · intro h
    have := (h.relO hs (by simp)).2.1
    simp [hsn.symm] at this

end DualityMoves

end