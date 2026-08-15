import Mathlib
import Novelty.SplitCountArity

/-!
# The arithmetic anchor of the split-count law: zero-sum tuples of non-identity classes

The arity-`r` fork table of `SplitCountArity.lean` is built out of the quantity

`altCount n m = ((n−1)^m + (n−1)(−1)^m) / n`,

which was *postulated* there as the (normalised) number of `m`-tuples of
non-identity classes whose product is the identity.  This file proves that this
is exactly what it counts, in the concrete group `ZMod n`:

* `card_zeroFree_zero` : `#{f : Fin m → ZMod n | ∀ i, f i ≠ 0, ∑ f = 0} · n
  = (n−1)^m + (n−1)(−1)^m`;
* `card_zeroFree_ne` : for `c ≠ 0`, `#{f | ∀ i, f i ≠ 0, ∑ f = c} · n
  = (n−1)^m − (−1)^m` — in particular the count is the *same for every* nonzero
  target, even when `n` is composite (there is no unit acting transitively on
  the nonzero classes, so this is a genuine two-term recursion, not a symmetry);
* `altCount_eq_card` : `altCount (n : ℝ) m` is the cardinality of the zero-sum
  set, so the fork table of the previous file is the exact law of the uniform
  model on `(ZMod n)^r`.

The proof is the coupled recursion `A_{m+1} = (n−1) B_m`,
`B_{m+1} = A_m + (n−2) B_m` obtained by peeling off the first coordinate.
-/

namespace SplitCountZeroSum

open Finset

variable {n : ℕ} [NeZero n]

/-- The non-identity classes. -/
def nonzeros (n : ℕ) [NeZero n] : Finset (ZMod n) := Finset.univ.filter (fun y => y ≠ 0)

/-- `m`-tuples of non-identity classes with prescribed sum. -/
def zeroFree (m : ℕ) (c : ZMod n) : Finset (Fin m → ZMod n) :=
  Finset.univ.filter (fun f => (∀ i, f i ≠ 0) ∧ ∑ i, f i = c)

lemma mem_zeroFree {m : ℕ} {c : ZMod n} {f : Fin m → ZMod n} :
    f ∈ zeroFree m c ↔ (∀ i, f i ≠ 0) ∧ ∑ i, f i = c := by
  simp [zeroFree]

lemma mem_nonzeros {y : ZMod n} : y ∈ nonzeros n ↔ y ≠ 0 := by simp [nonzeros]

lemma card_nonzeros : (nonzeros n).card = n - 1 := by
  have h : nonzeros n = Finset.univ.erase (0 : ZMod n) := by
    ext y; simp [nonzeros, Finset.mem_erase]
  rw [h, Finset.card_erase_of_mem (Finset.mem_univ _), Finset.card_univ, ZMod.card]

/-! ## Peeling off the first coordinate -/

lemma card_zeroFree_succ (m : ℕ) (c : ZMod n) :
    (zeroFree (m + 1) c).card = ∑ y ∈ nonzeros n, (zeroFree m (c - y)).card := by
  have hfib : (zeroFree (m + 1) c).card
      = ∑ y ∈ nonzeros n, ((zeroFree (m + 1) c).filter (fun f => f 0 = y)).card := by
    refine Finset.card_eq_sum_card_fiberwise ?_
    intro f hf
    exact mem_nonzeros.mpr ((mem_zeroFree.mp hf).1 0)
  rw [hfib]
  refine Finset.sum_congr rfl (fun y hy => ?_)
  refine Finset.card_bij (fun f _ => Fin.tail f) ?_ ?_ ?_
  · intro f hf
    simp only [Finset.mem_filter] at hf
    obtain ⟨hf1, hf2⟩ := hf
    obtain ⟨hne, hsum⟩ := mem_zeroFree.mp hf1
    refine mem_zeroFree.mpr ⟨fun i => hne i.succ, ?_⟩
    have := Fin.sum_univ_succ (f := f)
    rw [hf2] at this
    simp only [Fin.tail]
    rw [← hsum, this]
    ring
  · intro f hf g hg hfg
    simp only [Finset.mem_filter] at hf hg
    funext i
    refine Fin.cases ?_ ?_ i
    · rw [hf.2, hg.2]
    · intro j
      exact congrFun hfg j
  · intro g hg
    obtain ⟨hne, hsum⟩ := mem_zeroFree.mp hg
    refine ⟨Fin.cons y g, ?_, ?_⟩
    · simp only [Finset.mem_filter]
      refine ⟨mem_zeroFree.mpr ⟨?_, ?_⟩, by simp⟩
      · intro i
        refine Fin.cases ?_ ?_ i
        · simpa using mem_nonzeros.mp hy
        · intro j; simpa using hne j
      · rw [Fin.sum_univ_succ]
        simp only [Fin.cons_zero, Fin.cons_succ]
        rw [hsum]
        ring
    · funext j
      simp [Fin.tail]

/-! ## The coupled recursion, solved -/

/-- The two counts, proved simultaneously by induction on the length. -/
theorem card_zeroFree_pair (hn : 2 ≤ n) (m : ℕ) :
    (((zeroFree m (0 : ZMod n)).card : ℤ) * n = ((n : ℤ) - 1) ^ m + ((n : ℤ) - 1) * (-1) ^ m)
      ∧ ∀ c : ZMod n, c ≠ 0 →
        ((zeroFree m c).card : ℤ) * n = ((n : ℤ) - 1) ^ m - (-1) ^ m := by
  induction m with
  | zero =>
      constructor
      · have h : zeroFree 0 (0 : ZMod n) = Finset.univ := by
          ext f; simp [zeroFree]
        rw [h]
        simp
      · intro c hc
        have h : zeroFree 0 c = ∅ := by
          refine Finset.eq_empty_of_forall_notMem (fun f hf => ?_)
          exact hc (by simpa using (mem_zeroFree.mp hf).2.symm)
        rw [h]
        simp
  | succ m ih =>
      obtain ⟨ihA, ihB⟩ := ih
      have hcard : (nonzeros n).card = n - 1 := card_nonzeros
      have hn1 : ((n - 1 : ℕ) : ℤ) = (n : ℤ) - 1 := by omega
      have hn2 : ((n - 2 : ℕ) : ℤ) = (n : ℤ) - 2 := by omega
      constructor
      · -- A_{m+1} = (n−1) B_m
        rw [card_zeroFree_succ]
        have hterm : ∀ y ∈ nonzeros n,
            ((zeroFree m ((0 : ZMod n) - y)).card : ℤ) * n = ((n : ℤ) - 1) ^ m - (-1) ^ m := by
          intro y hy
          refine ihB _ ?_
          simpa using (neg_ne_zero.mpr (mem_nonzeros.mp hy))
        have hsum : ((∑ y ∈ nonzeros n, (zeroFree m ((0 : ZMod n) - y)).card : ℕ) : ℤ) * n
            = ∑ y ∈ nonzeros n, (((zeroFree m ((0 : ZMod n) - y)).card : ℤ) * n) := by
          push_cast [Finset.sum_mul]
          ring
        rw [hsum, Finset.sum_congr rfl hterm, Finset.sum_const, hcard, nsmul_eq_mul, hn1]
        ring
      · -- B_{m+1} = A_m + (n−2) B_m
        intro c hc
        rw [card_zeroFree_succ]
        have hsplit : nonzeros n = insert c ((nonzeros n).erase c) := by
          rw [Finset.insert_erase (mem_nonzeros.mpr hc)]
        have hterm : ∀ y ∈ (nonzeros n).erase c,
            ((zeroFree m (c - y)).card : ℤ) * n = ((n : ℤ) - 1) ^ m - (-1) ^ m := by
          intro y hy
          rw [Finset.mem_erase] at hy
          exact ihB _ (sub_ne_zero.mpr (fun h => hy.1 h.symm))
        have hcarderase : ((nonzeros n).erase c).card = n - 2 := by
          rw [Finset.card_erase_of_mem (mem_nonzeros.mpr hc), card_nonzeros]
          omega
        have hgoal : (((zeroFree (m + 1) c).card : ℤ)) * n
            = ∑ y ∈ nonzeros n, (((zeroFree m (c - y)).card : ℤ) * n) := by
          rw [card_zeroFree_succ]
          push_cast [Finset.sum_mul]
          ring
        rw [← card_zeroFree_succ, hgoal, hsplit, Finset.sum_insert (Finset.notMem_erase _ _),
          Finset.sum_congr rfl hterm, Finset.sum_const, hcarderase]
        rw [sub_self, ihA, nsmul_eq_mul, hn2]
        ring

theorem card_zeroFree_zero (hn : 2 ≤ n) (m : ℕ) :
    ((zeroFree m (0 : ZMod n)).card : ℤ) * n = ((n : ℤ) - 1) ^ m + ((n : ℤ) - 1) * (-1) ^ m :=
  (card_zeroFree_pair hn m).1

theorem card_zeroFree_ne (hn : 2 ≤ n) (m : ℕ) (c : ZMod n) (hc : c ≠ 0) :
    ((zeroFree m c).card : ℤ) * n = ((n : ℤ) - 1) ^ m - (-1) ^ m :=
  (card_zeroFree_pair hn m).2 c hc

/-- **The arithmetic meaning of `altCount`.**  The coefficient used to build the
arity-`r` fork table is exactly the number of `m`-tuples of non-identity classes
whose product is the identity. -/
theorem altCount_eq_card (hn : 2 ≤ n) (m : ℕ) :
    SplitCountArity.altCount (n : ℝ) m = ((zeroFree m (0 : ZMod n)).card : ℝ) := by
  have hn0 : (0:ℝ) < (n : ℝ) := by
    have : (0:ℕ) < n := by omega
    exact_mod_cast this
  have h := card_zeroFree_zero hn m
  have hR : ((zeroFree m (0 : ZMod n)).card : ℝ) * (n : ℝ)
      = ((n : ℝ) - 1) ^ m + ((n : ℝ) - 1) * (-1) ^ m := by
    exact_mod_cast congrArg (fun z : ℤ => (z : ℝ)) h
  rw [SplitCountArity.altCount, div_eq_iff (ne_of_gt hn0), hR]

end SplitCountZeroSum