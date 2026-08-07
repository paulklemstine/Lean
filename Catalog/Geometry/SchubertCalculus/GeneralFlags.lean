/-
Copyright (c) 2026. Released under Apache 2.0 license.
-/
import Geometry.SchubertCalculus.Duality

/-!
# Schubert calculus V: duality for an arbitrary pair of opposite flags

`Geometry.SchubertCalculus.Duality` proves the duality theorem for the *coordinate* flag and
its reverse.  Here the argument is carried out for an arbitrary pair of complete flags in
general position in an arbitrary finite-dimensional vector space: no coordinates are used,
only the dimension identities of flag intersections.

* `SchubertCalculus.Opposite` : two complete flags are opposite when complementary members
  intersect trivially, `Fᵢ ⊓ G_{n-i} = 0`.
* `SchubertCalculus.finrank_line` : for opposite flags the spaces `L_s = F_{s+1} ⊓ G_{n-s}`
  are lines.
* `SchubertCalculus.line_le_of_transverse` : a transverse subspace contains `L_s` for every
  jump `s` of its `F`-filtration.
* `SchubertCalculus.finrank_sup_lines` : the lines `L_s`, `s ∈ S`, span a subspace of
  dimension `#S` (a staircase independence argument).
* `SchubertCalculus.transverse_unique` : **duality theorem.** Two transverse subspaces with
  the same jump set are equal, and each is the span of its jump lines. Thus a complementary
  pair of Schubert conditions with respect to flags in general position has at most one
  solution.
* `SchubertCalculus.inf_part_F_sup_lines` / `SchubertCalculus.inf_part_G_sup_lines` : the two
  flag filtrations of a span of jump lines are again spans of jump lines (modularity of the
  subspace lattice).
* `SchubertCalculus.isTransverseFlags_sup_lines` / `SchubertCalculus.jumpSet_sup_lines` : the
  existence half — every admissible Schubert datum `S ⊆ {0, …, n-1}` is realised.
* `SchubertCalculus.jumpSet_G_sup_lines` : the jump data of a transverse subspace with respect
  to the two flags are reverse to each other — the conditions are exactly complementary.
* `SchubertCalculus.transverse_setOf_eq_singleton_flags` : **enumerative duality theorem.**
  For flags in general position, a complementary pair of Schubert conditions has *exactly one*
  solution.
* `SchubertCalculus.ncard_transverse_eq_choose` : there are exactly `n.choose k` transverse
  `k`-dimensional subspaces, one per Schubert datum.
* `SchubertCalculus.opposite_stdFlag_oppFlag` / `SchubertCalculus.line_stdFlag_oppFlag` :
  the coordinate flags realise the hypotheses, and the abstract jump lines are the coordinate
  lines, so the theory is non-vacuous and specialises to `Duality`.
-/

namespace SchubertCalculus

open Module Submodule

variable {K V : Type*} [Field K] [AddCommGroup V] [Module K V] [FiniteDimensional K V]
variable {n : ℕ} (F G : CompleteFlag K V n)

/-- Two complete flags are *opposite* (in general position) if complementary members meet in
zero. -/
def Opposite : Prop := ∀ i ≤ n, F.part i ⊓ G.part (n - i) = ⊥

/-- The `s`-th intersection line of a pair of opposite flags. -/
def line (s : ℕ) : Submodule K V := F.part (s + 1) ⊓ G.part (n - s)

variable {F G}

omit [FiniteDimensional K V] in
lemma finrank_top_eq (F : CompleteFlag K V n) : finrank K V = n := by
  have h := F.finrank_part n (le_refl n)
  rw [F.part_top] at h
  simpa using h

/-- For opposite flags, `L_s` is one-dimensional. -/
theorem finrank_line (hFG : Opposite F G) {s : ℕ} (hs : s < n) :
    finrank K (line F G s) = 1 := by
  have hV : finrank K V = n := finrank_top_eq F
  have hlow : 1 ≤ finrank K (line F G s) := by
    have key := Submodule.finrank_sup_add_finrank_inf_eq (F.part (s + 1)) (G.part (n - s))
    have h1 : finrank K (F.part (s + 1)) = s + 1 := F.finrank_part (s + 1) hs
    have h2 : finrank K (G.part (n - s)) = n - s := G.finrank_part (n - s) (by omega)
    have h3 : finrank K ((F.part (s + 1) ⊔ G.part (n - s) : Submodule K V)) ≤ n := by
      exact le_trans (Submodule.finrank_le _) hV.le
    have h4 : finrank K (line F G s) =
        finrank K ((F.part (s + 1) ⊓ G.part (n - s) : Submodule K V)) := rfl
    rw [h1, h2] at key
    omega
  have hhigh : finrank K (line F G s) ≤ 1 := by
    set X : Submodule K V := line F G s with hX
    have hbot : X ⊓ G.part (n - s - 1) = ⊥ := by
      have hle : X ⊓ G.part (n - s - 1) ≤ F.part (s + 1) ⊓ G.part (n - (s + 1)) := by
        refine le_inf (le_trans inf_le_left inf_le_left) ?_
        have : n - (s + 1) = n - s - 1 := by omega
        rw [this]
        exact inf_le_right
      rw [hFG (s + 1) hs] at hle
      exact le_bot_iff.mp hle
    have hstep := G.finrank_inf_step_le X (i := n - s - 1) (by omega)
    have he : n - s - 1 + 1 = n - s := by omega
    rw [he, hbot] at hstep
    have hXle : X ⊓ G.part (n - s) = X := by
      rw [hX, line, inf_assoc, inf_idem]
    rw [hXle] at hstep
    simpa using hstep
  omega

/-- A subspace is *transverse* for the pair `(F, G)` if it achieves equality in the basic
inequality at every level. -/
def IsTransverseFlags (F G : CompleteFlag K V n) (W : Submodule K V) : Prop :=
  ∀ i ≤ n, finrank K ((W ⊓ F.part i : Submodule K V)) +
    finrank K ((W ⊓ G.part (n - i) : Submodule K V)) = finrank K W

/-- A transverse subspace contains the line `L_s` for every jump `s` of its `F`-filtration. -/
theorem line_le_of_transverse (hFG : Opposite F G) {W : Submodule K V}
    (hW : IsTransverseFlags F G W) {s : ℕ} (hs : s ∈ F.jumpSet W) : line F G s ≤ W := by
  obtain ⟨hsn, hstep⟩ := (CompleteFlag.mem_jumpSet F W).mp hs
  set A : Submodule K V := W ⊓ F.part (s + 1) with hA
  set B : Submodule K V := W ⊓ G.part (n - s) with hB
  have hAval : finrank K A = finrank K ((W ⊓ F.part s : Submodule K V)) + 1 := hstep
  have hBval : finrank K ((W ⊓ F.part s : Submodule K V)) + finrank K B = finrank K W :=
    hW s hsn.le
  have hsup : A ⊔ B ≤ W := sup_le inf_le_left inf_le_left
  have hmono : finrank K ((A ⊔ B : Submodule K V)) ≤ finrank K W := Submodule.finrank_mono hsup
  have key := Submodule.finrank_sup_add_finrank_inf_eq A B
  have hline : A ⊓ B ≤ line F G s :=
    le_inf (le_trans inf_le_left inf_le_right) (le_trans inf_le_right inf_le_right)
  have hone : finrank K (line F G s) = 1 := finrank_line hFG hsn
  have hge : 1 ≤ finrank K ((A ⊓ B : Submodule K V)) := by omega
  have hle : finrank K ((A ⊓ B : Submodule K V)) ≤ 1 := by
    rw [← hone]; exact Submodule.finrank_mono hline
  have heq : A ⊓ B = line F G s := Submodule.eq_of_le_of_finrank_eq hline (by omega)
  rw [← heq]
  exact le_trans inf_le_left inf_le_left

/-- The jump lines are in "staircase position": the lines indexed by a set `S` span a
subspace of dimension `#S`. -/
theorem finrank_sup_lines (hFG : Opposite F G) (S : Finset ℕ) (hS : S ⊆ Finset.range n) :
    finrank K ((S.sup (line F G) : Submodule K V)) = S.card := by
  classical
  induction S using Finset.induction_on_max with
  | h0 => simp
  | step a S hlt ih =>
      have hSsub : S ⊆ Finset.range n := fun x hx => hS (Finset.mem_insert_of_mem hx)
      have han : a < n := Finset.mem_range.mp (hS (Finset.mem_insert_self a S))
      have haS : a ∉ S := fun h => absurd (hlt a h) (lt_irrefl a)
      have hsupF : S.sup (line F G) ≤ F.part a := by
        refine Finset.sup_le fun x hx => ?_
        exact le_trans inf_le_left (F.mono (by have := hlt x hx; omega))
      have hbot : line F G a ⊓ S.sup (line F G) = ⊥ := by
        have hle : line F G a ⊓ S.sup (line F G) ≤ F.part a ⊓ G.part (n - a) :=
          le_inf (le_trans inf_le_right hsupF) (le_trans inf_le_left inf_le_right)
        rw [hFG a han.le] at hle
        exact le_bot_iff.mp hle
      have key := Submodule.finrank_sup_add_finrank_inf_eq (line F G a) (S.sup (line F G))
      rw [hbot, finrank_bot, finrank_line hFG han, ih hSsub] at key
      rw [Finset.sup_insert, Finset.card_insert_of_notMem haS]
      omega

/-- **Duality theorem for opposite flags.** A transverse subspace is the span of its jump
lines. -/
theorem transverse_eq_sup_lines (hFG : Opposite F G) {W : Submodule K V}
    (hW : IsTransverseFlags F G W) : W = ((F.jumpSet W).sup (line F G) : Submodule K V) := by
  have hle : ((F.jumpSet W).sup (line F G) : Submodule K V) ≤ W :=
    Finset.sup_le fun s hs => line_le_of_transverse hFG hW hs
  refine (Submodule.eq_of_le_of_finrank_eq hle ?_).symm
  rw [finrank_sup_lines hFG _ (F.jumpSet_subset W), F.card_jumpSet W]

/-- **Uniqueness in the duality theorem.** For flags in general position, two transverse
subspaces with the same Schubert datum coincide: a complementary pair of Schubert conditions
has at most one solution. -/
theorem transverse_unique (hFG : Opposite F G) {W₁ W₂ : Submodule K V}
    (h1 : IsTransverseFlags F G W₁) (h2 : IsTransverseFlags F G W₂)
    (hj : F.jumpSet W₁ = F.jumpSet W₂) : W₁ = W₂ := by
  rw [transverse_eq_sup_lines hFG h1, transverse_eq_sup_lines hFG h2, hj]

/-! ## Existence: every admissible Schubert datum is realised -/

omit [FiniteDimensional K V] in
/-- Lines indexed strictly below `i` span a subspace of `Fᵢ`. -/
lemma sup_lines_le_part_F (S : Finset ℕ) {i : ℕ} (hS : ∀ s ∈ S, s < i) :
    (S.sup (line F G) : Submodule K V) ≤ F.part i :=
  Finset.sup_le fun s hs => le_trans inf_le_left (F.mono (hS s hs))

omit [FiniteDimensional K V] in
/-- Lines indexed at or above `i` span a subspace of `G_{n-i}`. -/
lemma sup_lines_le_part_G (S : Finset ℕ) {i : ℕ} (hS : ∀ s ∈ S, i ≤ s) :
    (S.sup (line F G) : Submodule K V) ≤ G.part (n - i) :=
  Finset.sup_le fun s hs => le_trans inf_le_right (G.mono (by have := hS s hs; omega))

omit [FiniteDimensional K V] in
/-- The `F`-filtration of a span of jump lines is again a span of jump lines: only the lines
below level `i` survive the intersection with `Fᵢ`.  This is where modularity of the lattice
of subspaces enters. -/
theorem inf_part_F_sup_lines (hFG : Opposite F G) (S : Finset ℕ) {i : ℕ} (hi : i ≤ n) :
    ((S.sup (line F G) : Submodule K V) ⊓ F.part i : Submodule K V)
      = ((S.filter (fun s => s < i)).sup (line F G) : Submodule K V) := by
  classical
  set T := S.filter (fun s => s < i) with hT
  set U := S.filter (fun s => ¬ s < i) with hU
  have hSTU : T ∪ U = S := Finset.filter_union_filter_not_eq _ _
  have hTle : (T.sup (line F G) : Submodule K V) ≤ F.part i :=
    sup_lines_le_part_F T fun s hs => (Finset.mem_filter.mp hs).2
  have hUle : (U.sup (line F G) : Submodule K V) ≤ G.part (n - i) :=
    sup_lines_le_part_G U fun s hs => by have := (Finset.mem_filter.mp hs).2; omega
  have hUbot : ((U.sup (line F G) : Submodule K V) ⊓ F.part i : Submodule K V) = ⊥ := by
    have hle : ((U.sup (line F G) : Submodule K V) ⊓ F.part i : Submodule K V)
        ≤ F.part i ⊓ G.part (n - i) := le_inf inf_le_right (le_trans inf_le_left hUle)
    rw [hFG i hi] at hle
    exact le_bot_iff.mp hle
  calc ((S.sup (line F G) : Submodule K V) ⊓ F.part i : Submodule K V)
      = ((T.sup (line F G) ⊔ U.sup (line F G) : Submodule K V) ⊓ F.part i) := by
        rw [← Finset.sup_union, hSTU]
    _ = (T.sup (line F G) : Submodule K V) ⊔ ((U.sup (line F G) : Submodule K V) ⊓ F.part i) :=
        sup_inf_assoc_of_le _ hTle
    _ = (T.sup (line F G) : Submodule K V) := by rw [hUbot, sup_bot_eq]

omit [FiniteDimensional K V] in
/-- Dually, intersecting with `G_{n-i}` keeps exactly the lines of index `≥ i`. -/
theorem inf_part_G_sup_lines (hFG : Opposite F G) (S : Finset ℕ) {i : ℕ} (hi : i ≤ n) :
    ((S.sup (line F G) : Submodule K V) ⊓ G.part (n - i) : Submodule K V)
      = ((S.filter (fun s => ¬ s < i)).sup (line F G) : Submodule K V) := by
  classical
  set T := S.filter (fun s => s < i) with hT
  set U := S.filter (fun s => ¬ s < i) with hU
  have hSTU : T ∪ U = S := Finset.filter_union_filter_not_eq _ _
  have hTle : (T.sup (line F G) : Submodule K V) ≤ F.part i :=
    sup_lines_le_part_F T fun s hs => (Finset.mem_filter.mp hs).2
  have hUle : (U.sup (line F G) : Submodule K V) ≤ G.part (n - i) :=
    sup_lines_le_part_G U fun s hs => by have := (Finset.mem_filter.mp hs).2; omega
  have hTbot : ((T.sup (line F G) : Submodule K V) ⊓ G.part (n - i) : Submodule K V) = ⊥ := by
    have hle : ((T.sup (line F G) : Submodule K V) ⊓ G.part (n - i) : Submodule K V)
        ≤ F.part i ⊓ G.part (n - i) := le_inf (le_trans inf_le_left hTle) inf_le_right
    rw [hFG i hi] at hle
    exact le_bot_iff.mp hle
  calc ((S.sup (line F G) : Submodule K V) ⊓ G.part (n - i) : Submodule K V)
      = ((U.sup (line F G) ⊔ T.sup (line F G) : Submodule K V) ⊓ G.part (n - i)) := by
        rw [← Finset.sup_union, Finset.union_comm, hSTU]
    _ = (U.sup (line F G) : Submodule K V)
          ⊔ ((T.sup (line F G) : Submodule K V) ⊓ G.part (n - i)) :=
        sup_inf_assoc_of_le _ hUle
    _ = (U.sup (line F G) : Submodule K V) := by rw [hTbot, sup_bot_eq]

/-- **Existence, transversality half.** The span of the lines indexed by any admissible datum
`S` is transverse for the pair of opposite flags. -/
theorem isTransverseFlags_sup_lines (hFG : Opposite F G) (S : Finset ℕ)
    (hS : S ⊆ Finset.range n) :
    IsTransverseFlags F G ((S.sup (line F G) : Submodule K V)) := by
  classical
  intro i hi
  have hTs : S.filter (fun s => s < i) ⊆ Finset.range n :=
    (Finset.filter_subset _ _).trans hS
  have hUs : S.filter (fun s => ¬ s < i) ⊆ Finset.range n :=
    (Finset.filter_subset _ _).trans hS
  rw [inf_part_F_sup_lines hFG S hi, inf_part_G_sup_lines hFG S hi,
    finrank_sup_lines hFG _ hTs, finrank_sup_lines hFG _ hUs, finrank_sup_lines hFG S hS]
  exact Finset.card_filter_add_card_filter_not _

/-- **Existence, datum half.** The span of the lines indexed by `S` has jump set exactly `S`,
so every admissible Schubert datum is realised by a transverse subspace. -/
theorem jumpSet_sup_lines (hFG : Opposite F G) (S : Finset ℕ) (hS : S ⊆ Finset.range n) :
    F.jumpSet ((S.sup (line F G) : Submodule K V)) = S := by
  classical
  have hdim : ∀ i ≤ n,
      finrank K (((S.sup (line F G) : Submodule K V) ⊓ F.part i : Submodule K V))
        = (S.filter (fun s => s < i)).card := by
    intro i hi
    rw [inf_part_F_sup_lines hFG S hi,
      finrank_sup_lines hFG _ ((Finset.filter_subset _ _).trans hS)]
  ext i
  rw [CompleteFlag.mem_jumpSet]
  constructor
  · rintro ⟨hin, hstep⟩
    rw [hdim (i + 1) hin, hdim i hin.le] at hstep
    by_contra hiS
    have hfe : S.filter (fun s => s < i + 1) = S.filter (fun s => s < i) := by
      ext x
      simp only [Finset.mem_filter]
      constructor
      · rintro ⟨hx, hlt⟩
        refine ⟨hx, ?_⟩
        rcases Nat.lt_succ_iff_lt_or_eq.mp hlt with h | h
        · exact h
        · exact absurd (h ▸ hx) hiS
      · rintro ⟨hx, hlt⟩
        exact ⟨hx, by omega⟩
    rw [hfe] at hstep
    omega
  · intro hiS
    have hin : i < n := Finset.mem_range.mp (hS hiS)
    refine ⟨hin, ?_⟩
    rw [hdim (i + 1) hin, hdim i hin.le]
    have hfe : S.filter (fun s => s < i + 1) = insert i (S.filter (fun s => s < i)) := by
      ext x
      simp only [Finset.mem_filter, Finset.mem_insert]
      constructor
      · rintro ⟨hx, hlt⟩
        rcases Nat.lt_succ_iff_lt_or_eq.mp hlt with h | h
        · exact Or.inr ⟨hx, h⟩
        · exact Or.inl h
      · rintro (rfl | ⟨hx, hlt⟩)
        · exact ⟨hiS, Nat.lt_succ_self _⟩
        · exact ⟨hx, by omega⟩
    rw [hfe, Finset.card_insert_of_notMem (by simp)]

/-- **Complementarity of the two Schubert conditions.** The jump set of the transverse
subspace with respect to the *second* flag is the reverse `s ↦ n-1-s` of its jump set with
respect to the first.  Thus a transverse subspace satisfies exactly a complementary pair of
Schubert conditions, which is the intersection-theoretic content of Poincaré duality on the
Grassmannian. -/
theorem jumpSet_G_sup_lines (hFG : Opposite F G) (S : Finset ℕ) (hS : S ⊆ Finset.range n) :
    G.jumpSet ((S.sup (line F G) : Submodule K V)) = S.image (fun s => n - 1 - s) := by
  classical
  have hdim : ∀ j ≤ n,
      finrank K (((S.sup (line F G) : Submodule K V) ⊓ G.part j : Submodule K V))
        = (S.filter (fun s => ¬ s < n - j)).card := by
    intro j hj
    have hnn : n - (n - j) = j := by omega
    have h := inf_part_G_sup_lines (F := F) hFG S (i := n - j) (by omega)
    rw [hnn] at h
    rw [h, finrank_sup_lines hFG _ ((Finset.filter_subset _ _).trans hS)]
  ext j
  rw [CompleteFlag.mem_jumpSet, Finset.mem_image]
  constructor
  · rintro ⟨hjn, hstep⟩
    rw [hdim (j + 1) hjn, hdim j hjn.le] at hstep
    by_contra hno
    push_neg at hno
    have hnotmem : n - 1 - j ∉ S := fun h => hno _ h (by omega)
    have hfe : S.filter (fun s => ¬ s < n - (j + 1)) = S.filter (fun s => ¬ s < n - j) := by
      ext x
      simp only [Finset.mem_filter, not_lt]
      constructor
      · rintro ⟨hx, hle⟩
        refine ⟨hx, ?_⟩
        rcases eq_or_lt_of_le hle with h | h
        · exact absurd (by rw [show n - 1 - j = x by omega]; exact hx) hnotmem
        · omega
      · rintro ⟨hx, hle⟩
        exact ⟨hx, by omega⟩
    rw [hfe] at hstep
    omega
  · rintro ⟨s, hsS, rfl⟩
    have hsn : s < n := Finset.mem_range.mp (hS hsS)
    refine ⟨by omega, ?_⟩
    rw [hdim (n - 1 - s + 1) (by omega), hdim (n - 1 - s) (by omega)]
    have hfe : S.filter (fun t => ¬ t < n - (n - 1 - s + 1))
        = insert s (S.filter (fun t => ¬ t < n - (n - 1 - s))) := by
      ext x
      simp only [Finset.mem_filter, Finset.mem_insert, not_lt]
      constructor
      · rintro ⟨hx, hle⟩
        rcases eq_or_lt_of_le hle with h | h
        · exact Or.inl (by omega)
        · exact Or.inr ⟨hx, by omega⟩
      · rintro (rfl | ⟨hx, hle⟩)
        · exact ⟨hsS, by omega⟩
        · exact ⟨hx, by omega⟩
    rw [hfe, Finset.card_insert_of_notMem (by simp; omega)]

/-- **Enumerative duality theorem for flags in general position.**  For every admissible
Schubert datum `S ⊆ {0, …, n-1}` the pair of complementary Schubert conditions cut out by two
opposite flags has exactly one solution, namely the span of the corresponding jump lines.
This is the abstract, coordinate-free form of the elementary Schubert intersection count. -/
theorem transverse_setOf_eq_singleton_flags (hFG : Opposite F G) (S : Finset ℕ)
    (hS : S ⊆ Finset.range n) :
    {W : Submodule K V | IsTransverseFlags F G W ∧ F.jumpSet W = S}
      = {(S.sup (line F G) : Submodule K V)} := by
  ext W
  simp only [Set.mem_setOf_eq, Set.mem_singleton_iff]
  constructor
  · rintro ⟨hW, hjW⟩
    exact transverse_unique hFG hW (isTransverseFlags_sup_lines hFG S hS)
      (by rw [hjW, jumpSet_sup_lines hFG S hS])
  · rintro rfl
    exact ⟨isTransverseFlags_sup_lines hFG S hS, jumpSet_sup_lines hFG S hS⟩

/-- The transverse `k`-dimensional subspaces are exactly the spans of the jump lines indexed
by the `k`-element admissible data. -/
theorem transverse_eq_image_sup_lines (hFG : Opposite F G) (k : ℕ) :
    {W : Submodule K V | IsTransverseFlags F G W ∧ finrank K W = k}
      = (fun S : Finset ℕ => (S.sup (line F G) : Submodule K V))
          '' (((Finset.range n).powersetCard k : Finset (Finset ℕ)) : Set (Finset ℕ)) := by
  ext W
  simp only [Set.mem_setOf_eq, Set.mem_image, Finset.mem_coe, Finset.mem_powersetCard]
  constructor
  · rintro ⟨hW, hk⟩
    exact ⟨F.jumpSet W, ⟨F.jumpSet_subset W, by rw [F.card_jumpSet W, hk]⟩,
      (transverse_eq_sup_lines hFG hW).symm⟩
  · rintro ⟨S, ⟨hS, hcard⟩, rfl⟩
    exact ⟨isTransverseFlags_sup_lines hFG S hS, by
      rw [finrank_sup_lines hFG S hS, hcard]⟩

/-- **Enumerative count.** For a pair of flags in general position, the subspaces of dimension
`k` transverse to the pair are finite in number and there are exactly `n.choose k` of them —
one for each Schubert datum.  This is the Schubert-calculus statement that the intersection
numbers of complementary pairs of Schubert classes are all `1`. -/
theorem ncard_transverse_eq_choose (hFG : Opposite F G) (k : ℕ) :
    {W : Submodule K V | IsTransverseFlags F G W ∧ finrank K W = k}.ncard = n.choose k := by
  classical
  have hinj : Set.InjOn (fun S : Finset ℕ => (S.sup (line F G) : Submodule K V))
      (((Finset.range n).powersetCard k : Finset (Finset ℕ)) : Set (Finset ℕ)) := by
    intro S hS T hT hST
    rw [Finset.mem_coe] at hS hT
    have h1 := jumpSet_sup_lines hFG S (Finset.mem_powersetCard.mp hS).1
    have h2 := jumpSet_sup_lines hFG T (Finset.mem_powersetCard.mp hT).1
    rw [← h1, ← h2]
    exact congrArg (F.jumpSet ·) hST
  rw [transverse_eq_image_sup_lines hFG k, hinj.ncard_image, Set.ncard_coe_finset,
    Finset.card_powersetCard, Finset.card_range]

/-! ## Non-vacuity: the coordinate flags are a pair in general position -/

/-- The standard and opposite coordinate flags of `Kⁿ` are in general position, so the
hypothesis `Opposite` of the theorems above is satisfiable in every dimension. -/
theorem opposite_stdFlag_oppFlag : Opposite (stdFlag K n) (oppFlag K n) := by
  intro i hi
  simp only [stdFlag_part, oppFlag_part]
  rw [coord_inf, stdSet_inter_oppSet hi, coord_empty]

/-- For the coordinate flags the abstract jump line `L_s` is the coordinate line `K · e_s`,
so the general theory specialises to the concrete duality theorem of
`Geometry.SchubertCalculus.Duality`. -/
theorem line_stdFlag_oppFlag {s : ℕ} (hs : s < n) :
    line (stdFlag K n) (oppFlag K n) s = coord K {(⟨s, hs⟩ : Fin n)} := by
  show coord K (stdSet n (s + 1)) ⊓ coord K (oppSet n (n - s)) = _
  rw [coord_inf, stdSet_succ_inter_oppSet hs]

end SchubertCalculus