module

public import Catalog.Geometry.DualityMoves.Moves

/-!
# Complete classification of eigenvalue lists up to the moves

We show that the invariants `RelO` (odd degree) and `RelR` (even degree) found
in `Moves.lean` are *complete*: two lists are related by the moves exactly when
these invariants agree.  The proof is a normal-form argument: every list is
move-equivalent to

  `nf a b C = [s, …, s] ++ [-s, …, -s] ++ C`   (`a` copies of `s`, `b` of `-s`)

where `C` is its core, `b ∈ {0, 1}`, and in even degree also `a ∈ {0, 1}`
(even-degree twists let one cancel pairs of `+Q` fixed points as well).
-/

@[expose] public section

noncomputable section

namespace DualityMoves

/-- The normal form `[s]^a ++ [-s]^b ++ C`. -/
def nf (s : ℂ) (a b : ℕ) (C : List ℂ) : List ℂ :=
  List.replicate a s ++ List.replicate b (-s) ++ C

lemma moves_of_count {s : ℂ} {l l' : List ℂ} (h : ∀ x, l.count x = l'.count x) :
    Moves s l l' := Moves.perm (List.perm_iff_count.2 h)

lemma Moves.refl' (s : ℂ) (l : List ℂ) : Moves s l l := Moves.perm (List.Perm.refl l)

/-- Deleting `k` pairs of `-Q` fixed points. -/
lemma negPairs (s : ℂ) (k : ℕ) : ∀ (l l' : List ℂ),
    (∀ x, x ≠ -s → l.count x = l'.count x) → l.count (-s) = l'.count (-s) + 2 * k →
      Moves s l l' := by
  induction k with
  | zero =>
    intro l l' h1 h2
    apply moves_of_count
    intro x
    by_cases hx : x = -s
    · subst hx; simpa using h2
    · exact h1 x hx
  | succ k ih =>
    intro l l' h1 h2
    refine Moves.trans (ih l (-s :: -s :: l') ?_ ?_) (Moves.symm (Moves.insertPair l'))
    · intro x hx; rw [count_pair, if_neg hx, add_zero]; exact h1 x hx
    · rw [count_pair, if_pos rfl]; omega

/-- In even degree one can also insert a pair of `+Q` fixed points: twist,
insert a `-Q` pair, twist back. -/
lemma posInsert (s : ℂ) (l : List ℂ) (he : Even l.length) : Moves s l (s :: s :: l) := by
  have h1 := Moves.twist (s := s) l he
  have h2 := Moves.insertPair (s := s) (l.map Neg.neg)
  have he' : Even (-s :: -s :: l.map Neg.neg).length := by
    simp only [List.length_cons, List.length_map]
    rw [Nat.even_iff] at he ⊢; omega
  have h3 := Moves.twist (s := s) _ he'
  have : (-s :: -s :: l.map Neg.neg).map Neg.neg = s :: s :: l := by
    simp [List.map_map]
  rw [this] at h3
  exact h1.trans (h2.trans h3)

/-- Deleting `k` pairs of `+Q` fixed points in even degree. -/
lemma posPairs (s : ℂ) (hs : s ≠ 0) (k : ℕ) : ∀ (l l' : List ℂ), Even l'.length →
    (∀ x, x ≠ s → l.count x = l'.count x) → l.count s = l'.count s + 2 * k →
      Moves s l l' := by
  have hsn : -s ≠ s := fun h => hs (by linear_combination -h / 2)
  induction k with
  | zero =>
    intro l l' _ h1 h2
    apply moves_of_count
    intro x
    by_cases hx : x = s
    · subst hx; simpa using h2
    · exact h1 x hx
  | succ k ih =>
    intro l l' he h1 h2
    have hcs : ∀ x, (s :: s :: l').count x = l'.count x + if x = s then 2 else 0 := by
      intro x
      by_cases h : x = s
      · subst h; simp
      · rw [List.count_cons, List.count_cons]; simp [Ne.symm h, h]
    refine Moves.trans (ih l (s :: s :: l') ?_ ?_ ?_) (Moves.symm (posInsert s l' he))
    · simp only [List.length_cons]; rw [Nat.even_iff] at he ⊢; omega
    · intro x hx; rw [hcs, if_neg hx, add_zero]; exact h1 x hx
    · rw [hcs, if_pos rfl]; omega

lemma count_nf (s : ℂ) (hs : s ≠ 0) (a b : ℕ) (C : List ℂ) (x : ℂ) :
    (nf s a b C).count x = (if x = s then a else 0) + (if x = -s then b else 0) + C.count x := by
  have hsn : s ≠ -s := fun h => hs (by linear_combination h / 2)
  unfold nf
  rw [List.count_append, List.count_append, List.count_replicate, List.count_replicate]
  have e1 : (s = x) ↔ (x = s) := eq_comm
  have e2 : (-s = x) ↔ (x = -s) := eq_comm
  simp only [beq_iff_eq, e1, e2]

/-- Every list is a permutation of its normal form `[s]^a ++ [-s]^b ++ core`. -/
lemma perm_nf (s : ℂ) (hs : s ≠ 0) (l : List ℂ) :
    l.Perm (nf s (l.count s) (l.count (-s)) (coreList s l)) := by
  have hsn : s ≠ -s := fun h => hs (by linear_combination h / 2)
  rw [List.perm_iff_count]
  intro x
  rw [count_nf s hs, count_coreList]
  by_cases h1 : x = s
  · rw [if_pos h1, if_neg (by rw [h1]; exact hsn), if_neg (fun h => h.1 h1), h1]; simp
  · by_cases h2 : x = -s
    · rw [if_neg h1, if_pos h2, if_neg (fun h => h.2 h2), h2]; simp
    · rw [if_neg h1, if_neg h2, if_pos ⟨h1, h2⟩]; simp

lemma length_eq_counts (s : ℂ) (hs : s ≠ 0) (l : List ℂ) :
    l.length = l.count s + l.count (-s) + (coreList s l).length := by
  rw [(perm_nf s hs l).length_eq]
  simp only [nf, List.length_append, List.length_replicate]

/-- Odd-degree (in fact any-degree) reduction: cancel pairs of `-Q` fixed points. -/
lemma reduce_neg (s : ℂ) (hs : s ≠ 0) (l : List ℂ) :
    Moves s l (nf s (l.count s) (l.count (-s) % 2) (coreList s l)) := by
  have hsn : s ≠ -s := fun h => hs (by linear_combination h / 2)
  refine (Moves.perm (perm_nf s hs l)).trans (negPairs s (l.count (-s) / 2) _ _ ?_ ?_)
  · intro x hx
    rw [count_nf s hs, count_nf s hs, if_neg hx, if_neg hx]
  · rw [count_nf s hs, count_nf s hs, if_neg hsn.symm, if_pos rfl, if_pos rfl]
    omega

/-- Even-degree reduction: cancel pairs of both kinds of fixed points. -/
lemma reduce_even (s : ℂ) (hs : s ≠ 0) (l : List ℂ) (he : l.length % 2 = 0) :
    Moves s l (nf s (l.count s % 2) (l.count (-s) % 2) (coreList s l)) := by
  have hsn : s ≠ -s := fun h => hs (by linear_combination h / 2)
  refine (reduce_neg s hs l).trans (posPairs s hs (l.count s / 2) _ _ ?_ ?_ ?_)
  · have := length_eq_counts s hs l
    rw [Nat.even_iff]; simp only [nf, List.length_append, List.length_replicate]
    omega
  · intro x hx
    rw [count_nf s hs, count_nf s hs, if_neg hx, if_neg hx]
  · simp only [count_nf s hs, if_neg hsn, if_true]
    omega

lemma coreList_perm {s : ℂ} {l l' : List ℂ}
    (h : ∀ x, x ≠ s → x ≠ -s → l'.count x = l.count x) : (coreList s l).Perm (coreList s l') := by
  rw [List.perm_iff_count]
  intro x
  rw [count_coreList, count_coreList]
  split_ifs with h'
  · exact (h x h'.1 h'.2).symm
  · rfl

lemma nf_perm (s : ℂ) (a b : ℕ) {C C' : List ℂ} (h : C.Perm C') :
    Moves s (nf s a b C) (nf s a b C') := Moves.perm (List.Perm.append_left _ h)

/-- Completeness, first branch of `RelR`, in even degree. -/
lemma complete_even_same (s : ℂ) (hs : s ≠ 0) (l l' : List ℂ) (he : l.length % 2 = 0)
    (h1 : ∀ x, x ≠ s → x ≠ -s → l'.count x = l.count x)
    (h2 : l'.count s % 2 = l.count s % 2) (h3 : l'.count (-s) % 2 = l.count (-s) % 2) :
    Moves s l l' := by
  have hC := coreList_perm h1
  have he' : l'.length % 2 = 0 := by
    have e1 := length_eq_counts s hs l
    have e2 := length_eq_counts s hs l'
    have e3 := hC.length_eq
    omega
  have r1 := reduce_even s hs l he
  have r2 := reduce_even s hs l' he'
  rw [h2, h3] at r2
  exact r1.trans ((nf_perm s _ _ hC).trans r2.symm)

/-- **Complete classification of the move relation.**  Two eigenvalue lists are
related by permutations, insertions/deletions of pairs of `-Q` fixed points and
even-degree quadratic twists iff
* (odd degree) they have the same core, the same number of `+Q` fixed points and
  the same parity of the number of `-Q` fixed points; or
* (even degree) the invariant `RelR` holds: same core and same fixed-point
  parities, or negated core and swapped fixed-point parities. -/
theorem moves_iff (s : ℂ) (hs : s ≠ 0) (l l' : List ℂ) :
    Moves s l l' ↔
      (l.length % 2 = 1 ∧ RelO s l l') ∨ (l.length % 2 = 0 ∧ RelR s l l') := by
  constructor
  · intro h
    rcases Nat.mod_two_eq_zero_or_one l.length with he | ho
    · exact Or.inr ⟨he, h.relR hs⟩
    · exact Or.inl ⟨ho, h.relO hs ho⟩
  · rintro (⟨_, h1, h2, h3⟩ | ⟨he, hR⟩)
    · have r1 := reduce_neg s hs l
      have r2 := reduce_neg s hs l'
      rw [h2, h3] at r2
      exact r1.trans ((nf_perm s _ _ (coreList_perm h1)).trans r2.symm)
    · rcases hR with ⟨h1, h2, h3⟩ | ⟨h1, h2, h3⟩
      · exact complete_even_same s hs l l' he h1 h2 h3
      · -- twist `l'` first
        have he' : Even l'.length := by
          have e1 := length_eq_counts s hs l
          have e2 := length_eq_counts s hs l'
          have hC : (coreList s (l.map Neg.neg)).Perm (coreList s l') := by
            apply coreList_perm
            intro x a b
            rw [h1 x a b, count_map_neg]
          have e3 := hC.length_eq
          have e4 : (coreList s (l.map Neg.neg)).length = (coreList s l).length := by
            have := congrArg Multiset.card (core_map_neg s l)
            simpa [core] using this
          rw [Nat.even_iff]; omega
        refine Moves.trans ?_ (Moves.symm (Moves.twist l' he'))
        apply complete_even_same s hs l _ he
        · intro x a b
          obtain ⟨a', b'⟩ := neg_ne_pm a b
          rw [count_map_neg, h1 (-x) a' b', neg_neg]
        · rw [count_map_neg]; exact h3
        · rw [count_map_neg, neg_neg]; exact h2

/-- The classification restated with the core multiset. -/
theorem moves_iff_core (s : ℂ) (hs : s ≠ 0) (l l' : List ℂ) :
    Moves s l l' ↔
      (l.length % 2 = 1 ∧ core s l' = core s l ∧ l'.count s = l.count s ∧
          negFix s l' % 2 = negFix s l % 2) ∨
      (l.length % 2 = 0 ∧
        ((core s l' = core s l ∧ l'.count s % 2 = l.count s % 2 ∧
            negFix s l' % 2 = negFix s l % 2) ∨
         (core s l' = (core s l).map Neg.neg ∧ l'.count s % 2 = negFix s l % 2 ∧
            negFix s l' % 2 = l.count s % 2))) := by
  rw [moves_iff s hs, RelO, RelR, ← core_map_neg, core_eq_iff, core_eq_iff]
  simp only [negFix, count_map_neg]

end DualityMoves

end