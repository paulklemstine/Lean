import Pythagorean.DistinguishingWordSharpness

/-!
# An explicit finite test suite for behavioural equivalence

The length bounds of `DistinguishingWordBound.lean` and `DistinguishingWordMoore.lean`
say that *some short* experiment separates inequivalent states.  This file turns that
into a literally finite object: over a finite alphabet the words of bounded length form
a `Finset`, and behavioural equivalence is decided by running the two machines on the
members of that single explicit suite.

## Main definitions and results

* `wordsUpTo k` — the `Finset` of all words of length `≤ k` over a finite alphabet,
  with `mem_wordsUpTo` characterising membership.
* `card_wordsUpTo_le` — the suite has at most `(|A| + 1) ^ k` elements.
* `Machine.testSuite` / `Machine.testSuite_complete` — the suite
  `wordsUpTo (|S| + |T| - 2)` is **complete**: agreement on it is equivalent to full
  behavioural equivalence.
* `Machine.testSuite_card_le` — the suite has at most `(|A| + 1) ^ (|S| + |T| - 2)`
  tests, an explicit finite bound on the number of experiments needed.
-/

namespace Pythagorean.DistinguishingWord

universe u v w x

variable {A : Type u} [Fintype A] [DecidableEq A]

/-- All words of length at most `k` over a finite alphabet. -/
def wordsUpTo (A : Type u) [Fintype A] [DecidableEq A] : ℕ → Finset (List A)
  | 0 => {[]}
  | k + 1 =>
      wordsUpTo A k ∪
        (Finset.univ (α := A) ×ˢ wordsUpTo A k).image (fun p => p.1 :: p.2)

@[simp] theorem mem_wordsUpTo (k : ℕ) (w : List A) : w ∈ wordsUpTo A k ↔ w.length ≤ k := by
  induction k generalizing w with
  | zero =>
      simp only [wordsUpTo, Finset.mem_singleton, Nat.le_zero]
      constructor
      · rintro rfl; simp
      · intro h; exact List.length_eq_zero_iff.mp h
  | succ k ih =>
      simp only [wordsUpTo, Finset.mem_union, Finset.mem_image, Finset.mem_product,
        Finset.mem_univ, true_and, Prod.exists]
      constructor
      · rintro (h | ⟨a, v, hv, rfl⟩)
        · exact le_trans ((ih w).mp h) (Nat.le_succ k)
        · simpa using Nat.succ_le_succ ((ih v).mp hv)
      · intro h
        match w with
        | [] => exact Or.inl ((ih []).mpr (Nat.zero_le k))
        | a :: v =>
            refine Or.inr ⟨a, v, (ih v).mpr ?_, rfl⟩
            simpa using Nat.succ_le_succ_iff.mp h

/-- The bounded-length test suite is small: at most `(|A| + 1) ^ k` words. -/
theorem card_wordsUpTo_le (k : ℕ) :
    (wordsUpTo A k).card ≤ (Fintype.card A + 1) ^ k := by
  induction k with
  | zero => simp [wordsUpTo]
  | succ k ih =>
      have h1 : (wordsUpTo A (k + 1)).card ≤
          (wordsUpTo A k).card +
            ((Finset.univ (α := A) ×ˢ wordsUpTo A k).image (fun p => p.1 :: p.2)).card :=
        Finset.card_union_le _ _
      have h2 : ((Finset.univ (α := A) ×ˢ wordsUpTo A k).image (fun p => p.1 :: p.2)).card
          ≤ Fintype.card A * (wordsUpTo A k).card := by
        refine le_trans Finset.card_image_le ?_
        rw [Finset.card_product, Finset.card_univ]
      calc (wordsUpTo A (k + 1)).card
          ≤ (wordsUpTo A k).card + Fintype.card A * (wordsUpTo A k).card := le_trans h1 (by omega)
        _ = (Fintype.card A + 1) * (wordsUpTo A k).card := by ring
        _ ≤ (Fintype.card A + 1) * (Fintype.card A + 1) ^ k := by
            exact Nat.mul_le_mul_left _ ih
        _ = (Fintype.card A + 1) ^ (k + 1) := by ring

namespace Machine

variable {O : Type v} {S : Type w} {T : Type x}

/-- The canonical test suite for a pair of finite machines: all words of length at most
`|S| + |T| - 2`. -/
def testSuite (A : Type u) [Fintype A] [DecidableEq A] (S : Type w) (T : Type x)
    [Fintype S] [Fintype T] : Finset (List A) :=
  wordsUpTo A (Fintype.card S + Fintype.card T - 2)

/-- **Complete finite test suite.**  Two initial states of finite Moore machines are
behaviourally equivalent iff they produce the same observation on every word of the
finite suite `testSuite A S T`. -/
theorem testSuite_complete [Fintype S] [Fintype T] (M : Machine A O S) (N : Machine A O T)
    (s : S) (t : T) :
    Equivalent M N s t ↔ ∀ w ∈ testSuite A S T, M.obs s w = N.obs t w := by
  constructor
  · intro h w _; exact h w
  · intro h
    by_contra hcon
    obtain ⟨w, hlen, hne⟩ := exists_distinguishing_word_moore M N s t hcon
    exact hne (h w (by rw [testSuite, mem_wordsUpTo]; exact hlen))

/-- The complete test suite is of explicitly bounded size. -/
theorem testSuite_card_le [Fintype S] [Fintype T] :
    (testSuite A S T).card ≤ (Fintype.card A + 1) ^ (Fintype.card S + Fintype.card T - 2) :=
  card_wordsUpTo_le _

omit [Fintype A] in
/-- Every incomplete suite fails: if a finite suite `W` omits some word of length at most
`|S| + |T| - 2`, it is not complete for *all* machine pairs of that size, because the
free construction realises the missing behaviour.  Here is the concrete two-state
instance: a suite that omits `w` cannot detect the difference between the machine that
outputs `true` exactly at `w` and the constantly-`false` machine. -/
theorem suite_must_contain [Nonempty A] (W : Finset (List A)) (w : List A) (hw : w ∉ W) :
    ∃ f g : List A → Bool,
      (∀ v ∈ W, (freeMachine f).obs [] v = (freeMachine g).obs [] v) ∧
      ¬ Equivalent (freeMachine f) (freeMachine g) [] [] := by
  classical
  refine ⟨fun _ => false, fun v => decide (v = w), ?_, ?_⟩
  · intro v hv
    rw [freeMachine_obs_nil, freeMachine_obs_nil]
    have : v ≠ w := by rintro rfl; exact hw hv
    simp [this]
  · intro hEq
    have := hEq w
    rw [freeMachine_obs_nil, freeMachine_obs_nil] at this
    simp at this

/-- **The finite-test dichotomy.**  Fix any bound `k` and the corresponding finite suite
`wordsUpTo A k`.  On the one hand the suite is complete for *every* pair of finite-state
machines whose sizes satisfy `|S| + |T| - 2 ≤ k`.  On the other hand it is never complete
for arbitrary behaviours: two machines on the infinite state set `List A` pass the whole
suite yet are inequivalent.  Finiteness of the state sets is exactly what makes a fixed
finite test suite possible. -/
theorem finite_test_dichotomy [Nonempty A] (O : Type v) (k : ℕ) :
    (∀ (S : Type w) (T : Type x) (_ : Fintype S) (_ : Fintype T)
        (M : Machine A O S) (N : Machine A O T) (s : S) (t : T),
        Fintype.card S + Fintype.card T - 2 ≤ k →
        ((∀ w ∈ wordsUpTo A k, M.obs s w = N.obs t w) ↔ Equivalent M N s t)) ∧
      (∃ f g : List A → Bool,
        (∀ w ∈ wordsUpTo A k, (freeMachine f).obs [] w = (freeMachine g).obs [] w) ∧
        ¬ Equivalent (freeMachine f) (freeMachine g) [] []) := by
  classical
  obtain ⟨a⟩ := ‹Nonempty A›
  constructor
  · intro S T _ _ M N s t hk
    constructor
    · intro h
      by_contra hcon
      obtain ⟨w, hlen, hne⟩ := exists_distinguishing_word_moore M N s t hcon
      exact hne (h w ((mem_wordsUpTo k w).mpr (hlen.trans hk)))
    · intro h w _
      exact h w
  · refine Machine.suite_must_contain (wordsUpTo A k) (List.replicate (k + 1) a) ?_
    rw [mem_wordsUpTo]
    simp

end Machine

end Pythagorean.DistinguishingWord