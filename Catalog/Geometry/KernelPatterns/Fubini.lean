import Geometry.KernelPatterns.Faces
import Geometry.KernelPatterns.Stirling

/-!
# The Fubini (ordered Bell) formula for faces of the braid arrangement

`Faces.lean` introduced the *ordered pattern* `rank v` of a tuple and showed it
is a complete invariant of the face of the braid arrangement spanned by `v`.
This file counts the ordered patterns exactly:

`#(ordPatterns n) = ∑_{k ≤ n} S(n, k) · k!`,

the ordered Bell (Fubini) numbers `1, 1, 3, 13, 75, 541` (OEIS A000670), where
`S(n, k) = Nat.stirlingSecond n k` counts the kernel patterns with `k` blocks
(`Stirling.lean`).  Geometrically: every face of the braid arrangement is
obtained from a flat (a kernel pattern, i.e. a set partition into `k` blocks) by
choosing one of the `k!` linear orders of its blocks.

The proof fibres `ordPatterns n` first over the number of blocks and then over
the underlying kernel pattern, and identifies each fibre with `Equiv.Perm (Fin k)`
by transporting along the order isomorphism `Fin k ≃o` (block representatives).

Main results:
* `card_reps` — the block representatives biject with the distinct values.
* `rank_val_eq_of_surjective` — for a *surjective* `v : Fin n → Fin k` the rank
  function is the tuple itself; this is the rigidity statement that makes the
  fibres rigid.
* `card_fibre_ordPatterns` — the ordered patterns refining a fixed kernel
  pattern with `k` blocks number exactly `k!`.
* `card_ordPatternsWith` — `#{faces with k blocks} = S(n,k) · k!`.
* `card_ordPatterns_eq_sum_stirlingSecond` — the Fubini formula.
-/

namespace Geometry.KernelPatterns

open Finset

variable {n k : ℕ} {X : Type*} [LinearOrder X]

/-! ### Block representatives -/

/-- The set of block representatives of a tuple: the indices of first
occurrences. -/
def reps (v : Fin n → X) : Finset (Fin n) := univ.filter fun j => pat v j = j

@[simp] lemma mem_reps {v : Fin n → X} {j : Fin n} : j ∈ reps v ↔ pat v j = j := by
  simp [reps]

/-- The representatives biject with the distinct values. -/
theorem card_reps (v : Fin n → X) : (reps v).card = (univ.image v).card := by
  refine Finset.card_bij (fun j _ => v j) (fun a _ => Finset.mem_image_of_mem _ (mem_univ a))
    ?_ ?_
  · intro a ha b hb hab
    rw [mem_reps] at ha hb
    rw [← ha, ← hb]
    exact pat_eq_iff.2 hab
  · intro b hb
    simp only [Finset.mem_image, mem_univ, true_and] at hb
    obtain ⟨i, rfl⟩ := hb
    exact ⟨pat v i, by rw [mem_reps]; exact pat_apply_pat v i, apply_pat v i⟩

@[simp] lemma reps_pat (v : Fin n → X) : reps (pat v) = reps v := by
  ext j; simp

lemma card_image_pat (v : Fin n → X) :
    (univ.image (pat v)).card = (univ.image v).card := by
  rw [← card_reps, ← card_reps, reps_pat]

/-! ### Rank versus the number of blocks -/

theorem rank_val_lt_card_reps (v : Fin n → X) (i : Fin n) :
    (rank v i : ℕ) < (reps v).card := by
  have hsub : (univ.filter fun j => pat v j = j ∧ v j < v i) ⊂ reps v := by
    refine ⟨fun j hj => ?_, fun hcon => ?_⟩
    · simp only [mem_filter, mem_univ, true_and] at hj
      rw [mem_reps]; exact hj.1
    · have hmem : pat v i ∈ reps v := by rw [mem_reps]; exact pat_apply_pat v i
      have hcon' := hcon hmem
      simp at hcon'
  rw [rank_val]
  exact Finset.card_lt_card hsub

/-- An ordered pattern takes values below its number of blocks. -/
theorem val_lt_card_image_of_rank_eq {r : Fin n → Fin n} (hr : rank r = r) (i : Fin n) :
    (r i : ℕ) < (univ.image r).card := by
  have h := rank_val_lt_card_reps r i
  rw [hr] at h
  rwa [card_reps] at h

/-- **Rigidity.**  A surjective tuple `v : Fin n → Fin k` coincides with its own
rank function. -/
theorem rank_val_eq_of_surjective {v : Fin n → Fin k} (hv : Function.Surjective v)
    (i : Fin n) : (rank v i : ℕ) = (v i : ℕ) := by
  rw [rank_val]
  have hb : (univ.filter fun j => pat v j = j ∧ v j < v i).card
      = ((univ : Finset (Fin k)).filter fun y => y < v i).card := by
    refine Finset.card_bij (fun j _ => v j) ?_ ?_ ?_
    · intro a ha
      simp only [mem_filter, mem_univ, true_and] at ha ⊢
      exact ha.2
    · intro a ha b hb hab
      simp only [mem_filter, mem_univ, true_and] at ha hb
      rw [← ha.1, ← hb.1]
      exact pat_eq_iff.2 hab
    · intro b hb
      simp only [mem_filter, mem_univ, true_and] at hb
      obtain ⟨j, rfl⟩ := hv b
      refine ⟨pat v j, ?_, apply_pat v j⟩
      simp only [mem_filter, mem_univ, true_and]
      exact ⟨pat_apply_pat v j, by rw [apply_pat v j]; exact hb⟩
  rw [hb]
  have h2 : ((univ : Finset (Fin k)).filter fun y => y < v i) = Finset.Iio (v i) := by
    ext x; simp
  rw [h2, Fin.card_Iio]

/-! ### The fibres of `pat` on ordered patterns -/

/-- **Each flat carries exactly `k!` faces.**  The ordered patterns refining a
fixed kernel pattern `p` with `k` blocks are in bijection with the linear orders
of the blocks. -/
theorem card_fibre_ordPatterns {p : Fin n → Fin n} (hp : pat p = p)
    (hk : (univ.image p).card = k) :
    ((ordPatterns n).filter fun r => pat r = p).card = k.factorial := by
  classical
  have hcard : (reps p).card = k := by rw [card_reps, hk]
  set e := (reps p).orderIsoOfFin hcard with he
  have hmem : ∀ i, p i ∈ reps p := fun i => by
    rw [mem_reps, hp]
    have h := pat_apply_pat p i
    rwa [hp] at h
  have hfix : ∀ x : Fin k, p ((e x : Fin n)) = (e x : Fin n) := by
    intro x
    have h2 := (e x).2
    rw [mem_reps, hp] at h2
    exact h2
  have hkey : ∀ x : Fin k, e.symm ⟨p ((e x : Fin n)), hmem _⟩ = x := by
    intro x
    have hsub : (⟨p ((e x : Fin n)), hmem _⟩ : ↥(reps p)) = e x := Subtype.ext (hfix x)
    rw [hsub]
    exact e.symm_apply_apply x
  -- the tuple attached to a permutation of the blocks
  set v : Equiv.Perm (Fin k) → Fin n → Fin k :=
    fun σ i => σ (e.symm ⟨p i, hmem i⟩) with hv
  have hvsurj : ∀ σ, Function.Surjective (v σ) := by
    intro σ x
    refine ⟨(e (σ.symm x) : Fin n), ?_⟩
    simp only [hv, hkey (σ.symm x)]
    exact σ.apply_symm_apply x
  have hvpat : ∀ σ, pat (v σ) = p := by
    intro σ
    have hcg : pat (v σ) = pat p := by
      refine pat_congr fun a b => ?_
      simp [hv, Subtype.ext_iff]
    rw [hcg, hp]
  have hbij : (univ : Finset (Equiv.Perm (Fin k))).card
      = ((ordPatterns n).filter fun r => pat r = p).card := by
    refine Finset.card_bij (fun σ _ => rank (v σ)) ?_ ?_ ?_
    · intro σ _
      simp only [mem_filter]
      exact ⟨(mem_ordPatterns _).2 (rank_idem _), by rw [pat_rank]; exact hvpat σ⟩
    · intro σ _ τ _ hst
      have hst' : rank (v σ) = rank (v τ) := hst
      have hval : ∀ i, v σ i = v τ i := by
        intro i
        apply Fin.ext
        rw [← rank_val_eq_of_surjective (hvsurj σ) i, ← rank_val_eq_of_surjective (hvsurj τ) i,
          hst']
      apply Equiv.ext
      intro x
      have := hval ((e x : Fin n))
      simpa only [hv, hkey x] using this
    · intro r hr
      simp only [mem_filter] at hr
      obtain ⟨hr1, hr2⟩ := hr
      have hrr : rank r = r := (mem_ordPatterns r).1 hr1
      have hrepsr : reps r = reps p := by
        ext j
        simp [hr2, hp]
      have hkr : (univ.image r).card = k := by
        rw [← card_reps, hrepsr, hcard]
      have hlt : ∀ x : Fin k, (r ((e x : Fin n)) : ℕ) < k := by
        intro x
        have := val_lt_card_image_of_rank_eq hrr ((e x : Fin n))
        rwa [hkr] at this
      set f : Fin k → Fin k := fun x => ⟨(r ((e x : Fin n)) : ℕ), hlt x⟩ with hf
      have hfinj : Function.Injective f := by
        intro x y hxy
        have h1 : r ((e x : Fin n)) = r ((e y : Fin n)) := by
          apply Fin.ext
          simpa [hf] using congrArg Fin.val hxy
        have h2 : pat r ((e x : Fin n)) = pat r ((e y : Fin n)) := pat_eq_iff.2 h1
        rw [hr2] at h2
        rw [hfix x, hfix y] at h2
        exact e.injective (Subtype.ext h2)
      set σ : Equiv.Perm (Fin k) := Equiv.ofBijective f (Finite.injective_iff_bijective.1 hfinj)
        with hsig
      refine ⟨σ, Finset.mem_univ _, ?_⟩
      have hvv : ∀ i, (v σ i : ℕ) = (r i : ℕ) := by
        intro i
        have hpi : (⟨p i, hmem i⟩ : ↥(reps p)) = e (e.symm ⟨p i, hmem i⟩) :=
          (e.apply_symm_apply _).symm
        have hei : ((e (e.symm ⟨p i, hmem i⟩) : Fin n)) = p i := by
          rw [← hpi]
        have hrp : r (p i) = r i := by
          have := apply_pat r i
          rwa [hr2] at this
        simp only [hv, hsig, Equiv.ofBijective_apply, hf, hei, hrp]
      have hrk : rank (v σ) = rank r := by
        refine rank_congr fun a b => ?_
        rw [Fin.lt_def, Fin.lt_def, hvv a, hvv b]
      show rank (v σ) = r
      rw [hrk, hrr]
  rw [← hbij, Finset.card_univ, Fintype.card_perm, Fintype.card_fin]

/-! ### The Fubini formula -/

/-- Ordered patterns (faces) with exactly `k` blocks. -/
def ordPatternsWith (n k : ℕ) : Finset (Fin n → Fin n) :=
  (ordPatterns n).filter fun r => (univ.image r).card = k

/-- **Faces with `k` blocks are counted by `S(n,k)·k!`.** -/
theorem card_ordPatternsWith (n k : ℕ) :
    (ordPatternsWith n k).card = Nat.stirlingSecond n k * k.factorial := by
  classical
  have hmaps : Set.MapsTo pat ((ordPatternsWith n k : Finset (Fin n → Fin n)) : Set (Fin n → Fin n))
      ((patternsWith n k : Finset (Fin n → Fin n)) : Set (Fin n → Fin n)) := by
    intro r hr
    simp only [Finset.coe_filter, Set.mem_setOf_eq, ordPatternsWith] at hr
    simp only [Finset.mem_coe, mem_patternsWith]
    exact ⟨pat_idem r, by rw [card_image_pat]; exact hr.2⟩
  rw [Finset.card_eq_sum_card_fiberwise hmaps]
  have hfil : ∀ p ∈ patternsWith n k,
      ((ordPatternsWith n k).filter fun r => pat r = p).card = k.factorial := by
    intro p hp
    rw [mem_patternsWith] at hp
    have hset : ((ordPatternsWith n k).filter fun r => pat r = p)
        = ((ordPatterns n).filter fun r => pat r = p) := by
      ext r
      simp only [ordPatternsWith, mem_filter, and_assoc]
      constructor
      · rintro ⟨h1, -, h3⟩; exact ⟨h1, h3⟩
      · rintro ⟨h1, h3⟩
        refine ⟨h1, ?_, h3⟩
        rw [← card_image_pat r, h3]
        exact hp.2
    rw [hset]
    exact card_fibre_ordPatterns hp.1 hp.2
  rw [Finset.sum_congr rfl hfil, Finset.sum_const, smul_eq_mul,
    card_patternsWith_eq_stirlingSecond]

/-- **The Fubini formula.**  The faces of the braid arrangement in `ℝⁿ` — i.e.
the ordered patterns of `n`-tuples — number `∑_k S(n,k)·k!`, the ordered Bell
numbers (OEIS A000670).  Contrast `card_patterns_eq_bell`: forgetting the order
of the blocks turns the Fubini numbers into the Bell numbers. -/
theorem card_ordPatterns_eq_sum_stirlingSecond (n : ℕ) :
    (ordPatterns n).card = ∑ k ∈ range (n + 1), Nat.stirlingSecond n k * k.factorial := by
  classical
  have hmaps : Set.MapsTo (fun r : Fin n → Fin n => (univ.image r).card)
      ↑(ordPatterns n) ↑(range (n + 1)) := by
    intro r _
    simp only [Finset.coe_range, Set.mem_Iio]
    exact Nat.lt_succ_of_le (by simpa using Finset.card_le_univ (univ.image r))
  rw [Finset.card_eq_sum_card_fiberwise hmaps]
  exact Finset.sum_congr rfl fun k _ => card_ordPatternsWith n k

/-- Consistency check: the Fubini formula reproduces the `decide`-verified face
counts for `n ≤ 4`, and predicts `541` for `n = 5`. -/
theorem fubini_values :
    (∑ k ∈ range 1, Nat.stirlingSecond 0 k * k.factorial) = 1 ∧
    (∑ k ∈ range 2, Nat.stirlingSecond 1 k * k.factorial) = 1 ∧
    (∑ k ∈ range 3, Nat.stirlingSecond 2 k * k.factorial) = 3 ∧
    (∑ k ∈ range 4, Nat.stirlingSecond 3 k * k.factorial) = 13 ∧
    (∑ k ∈ range 5, Nat.stirlingSecond 4 k * k.factorial) = 75 ∧
    (∑ k ∈ range 6, Nat.stirlingSecond 5 k * k.factorial) = 541 := by
  refine ⟨by decide, by decide, by decide, by decide, by decide, by decide⟩

/-- The number of faces of the braid arrangement on `Fin 5` is `541`. -/
theorem card_ordPatterns_five : (ordPatterns 5).card = 541 := by
  rw [card_ordPatterns_eq_sum_stirlingSecond]
  decide

/-! ### Faces versus chambers and flats -/

/-- **Every chamber is a face**, quantitatively: the `n !` chambers of the braid
arrangement (`card_chambers`) are among its faces. -/
theorem card_chambers_le_card_ordPatterns (n : ℕ) :
    Nat.card (chambers n) ≤ (ordPatterns n).card := by
  rw [card_chambers, card_ordPatterns_eq_sum_stirlingSecond]
  have hmem : n ∈ range (n + 1) := by simp
  calc n.factorial = Nat.stirlingSecond n n * n.factorial := by
        rw [Nat.stirlingSecond_self, one_mul]
    _ ≤ ∑ k ∈ range (n + 1), Nat.stirlingSecond n k * k.factorial :=
        Finset.single_le_sum (f := fun k => Nat.stirlingSecond n k * k.factorial)
          (fun _ _ => Nat.zero_le _) hmem

/-- **Every flat carries at least one face**: the Bell number of flats is at most
the Fubini number of faces, termwise `S(n,k) ≤ S(n,k)·k!`. -/
theorem card_braidFlats_le_card_ordPatterns (n : ℕ) :
    Nat.card (braidFlats n) ≤ (ordPatterns n).card := by
  rw [card_braidFlats_eq_bell, bell_eq_sum_stirlingSecond,
    card_ordPatterns_eq_sum_stirlingSecond]
  refine Finset.sum_le_sum fun k _ => ?_
  calc Nat.stirlingSecond n k = Nat.stirlingSecond n k * 1 := (mul_one _).symm
    _ ≤ Nat.stirlingSecond n k * k.factorial :=
        Nat.mul_le_mul_left _ k.factorial_pos

end Geometry.KernelPatterns