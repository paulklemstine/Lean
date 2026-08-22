import Mathlib
import Catalog.NumberTheory.BerggrenTreeCompleteness

/-!
# The Berggren tree is free, and it is extremely unbalanced

Building on `Catalog.NumberTheory.BerggrenTreeCompleteness`, this file studies the
*word structure* of the Berggren tree.  A word `w : List (Fin 3)` (read right to left,
i.e. the head is the last matrix applied) produces the triple `run w`.

* `run_valid`, `reach_iff_exists_word` : the tree is precisely the image of `run`;
* `run_injective` : **the tree is free** — different words give different triples.
  Equivalently, every positive primitive Pythagorean triple with odd first leg has a
  *unique* Berggren factorisation.  The proof uses the two linear forms
  `u = a + 2b - 2c` and `v = 2a + b - 2c`, which read off the branch that was taken.
* `hyp_le_of_run` : a word of length `d` produces a hypotenuse at most `5 · 6^d`, so a
  triple at depth `d` has `c ≤ 5·6^d`, i.e. `d ≥ log₆(c/5)`;
* `spine_run` : the all-`B₃` branch produces `(4(k+1)² - 1, 4(k+1), 4(k+1)² + 1)` at
  depth `k` — a hypotenuse growing only *quadratically* in the depth.

So depth `d` nodes can have hypotenuse anywhere between `≍ d²` and `≍ 6^d`: the tree
is exponentially unbalanced, which is exactly why the counting function of the tree
inside a box is `Θ(H)` rather than a power of `H` determined by the branching number.
-/

namespace BerggrenTree

/-- The three Berggren matrices, indexed by `Fin 3`. -/
def step : Fin 3 → Tri → Tri
  | 0 => bA
  | 1 => bB
  | _ => bC

/-- The triple produced by a word; the head of the list is the *last* matrix applied. -/
def run : List (Fin 3) → Tri
  | [] => (3, 4, 5)
  | x :: w => step x (run w)

lemma valid_step (x : Fin 3) {t : Tri} (h : Valid t) : Valid (step x t) := by
  fin_cases x
  · exact valid_bA h
  · exact valid_bB h
  · exact valid_bC h

lemma run_valid (w : List (Fin 3)) : Valid (run w) := by
  induction w with
  | nil => exact reach_valid Reach.root
  | cons x w ih => exact valid_step x ih

lemma run_reach (w : List (Fin 3)) : Reach (run w) := (reach_iff_valid _).mpr (run_valid w)

/-- The Berggren tree is exactly the set of triples produced by words. -/
theorem reach_iff_exists_word (t : Tri) : Reach t ↔ ∃ w : List (Fin 3), run w = t := by
  constructor
  · intro h
    induction h with
    | root => exact ⟨[], rfl⟩
    | @stepA t _ ih => obtain ⟨w, hw⟩ := ih; exact ⟨0 :: w, by simp [run, step, hw]⟩
    | @stepB t _ ih => obtain ⟨w, hw⟩ := ih; exact ⟨1 :: w, by simp [run, step, hw]⟩
    | @stepC t _ ih => obtain ⟨w, hw⟩ := ih; exact ⟨2 :: w, by simp [run, step, hw]⟩
  · rintro ⟨w, rfl⟩
    exact run_reach w

/-! ### Freeness of the tree -/

/-- The linear form reading off the first coordinate of the parent. -/
def uform (t : Tri) : ℤ := t.1 + 2 * t.2.1 - 2 * t.2.2

/-- The linear form reading off (± ) the second coordinate of the parent. -/
def vform (t : Tri) : ℤ := 2 * t.1 + t.2.1 - 2 * t.2.2

lemma uform_bA (t : Tri) : uform (bA t) = t.1 := by simp only [uform, bA]; ring
lemma uform_bB (t : Tri) : uform (bB t) = t.1 := by simp only [uform, bB]; ring
lemma uform_bC (t : Tri) : uform (bC t) = -t.1 := by simp only [uform, bC]; ring
lemma vform_bA (t : Tri) : vform (bA t) = -t.2.1 := by simp only [vform, bA]; ring
lemma vform_bB (t : Tri) : vform (bB t) = t.2.1 := by simp only [vform, bB]; ring
lemma vform_bC (t : Tri) : vform (bC t) = t.2.1 := by simp only [vform, bC]; ring

lemma step_injective (x : Fin 3) : Function.Injective (step x) := by
  intro p q h
  fin_cases x <;>
  · obtain ⟨a, b, c⟩ := p
    obtain ⟨a', b', c'⟩ := q
    simp only [step, bA, bB, bC, Prod.mk.injEq] at h
    obtain ⟨h1, h2, h3⟩ := h
    refine Prod.ext ?_ (Prod.ext ?_ ?_) <;> simp only <;> omega

/-- Two different Berggren matrices never send valid triples to the same triple:
the branch taken is determined by the signs of `u` and `v`. -/
theorem step_ne_step {x y : Fin 3} (hxy : x ≠ y) {p q : Tri} (hp : Valid p) (hq : Valid q) :
    step x p ≠ step y q := by
  intro h
  have hp1 : 0 < p.1 := hp.1
  have hp2 : 0 < p.2.1 := hp.2.1
  have hq1 : 0 < q.1 := hq.1
  have hq2 : 0 < q.2.1 := hq.2.1
  have hu : uform (step x p) = uform (step y q) := by rw [h]
  have hv : vform (step x p) = vform (step y q) := by rw [h]
  fin_cases x <;> fin_cases y <;>
    simp only [step, uform_bA, uform_bB, uform_bC, vform_bA, vform_bB, vform_bC] at hu hv <;>
    first
      | exact absurd rfl hxy
      | omega

/-- The root is not a child of any valid triple. -/
theorem step_ne_root (x : Fin 3) {p : Tri} (hp : Valid p) : step x p ≠ (3, 4, 5) := by
  intro h
  have hp2 : 0 < p.2.1 := hp.2.1
  have hv : vform (step x p) = 0 := by rw [h]; simp [vform]
  fin_cases x <;> simp only [step, vform_bA, vform_bB, vform_bC] at hv <;> omega

/-- **Freeness.**  Distinct words produce distinct triples: the Berggren tree is a free
ternary tree, so every positive primitive Pythagorean triple with odd first leg has a
unique factorisation into Berggren matrices. -/
theorem run_injective : Function.Injective run := by
  intro w1
  induction w1 with
  | nil =>
    intro w2 h
    cases w2 with
    | nil => rfl
    | cons y w =>
      exact absurd h.symm (step_ne_root y (run_valid w))
  | cons x w ih =>
    intro w2 h
    cases w2 with
    | nil => exact absurd h (step_ne_root x (run_valid w))
    | cons y w' =>
      have hxy : x = y := by
        by_contra hne
        exact step_ne_step hne (run_valid w) (run_valid w') h
      subst hxy
      have : run w = run w' := step_injective x h
      rw [ih this]

/-! ### Depth versus size -/

/-- One Berggren step multiplies the hypotenuse by at most `6`. -/
lemma hyp_step_le (x : Fin 3) {t : Tri} (h : Valid t) : (step x t).2.2 ≤ 6 * t.2.2 := by
  obtain ⟨a, b, c⟩ := t
  obtain ⟨ha, hb, hc, hpy, _, _⟩ := h
  simp only at ha hb hc hpy
  have h1 : (a + b) ^ 2 ≤ 2 * c ^ 2 := by nlinarith [sq_nonneg (a - b)]
  have hsum : 2 * (a + b) ≤ 3 * c := by
    by_contra hcon
    push_neg at hcon
    nlinarith [h1, hcon, hc, ha, hb]
  fin_cases x <;> simp only [step, bA, bB, bC] <;> omega

/-- A triple at depth `d` in the tree has hypotenuse at most `5 · 6^d`; equivalently a
triple with hypotenuse `c` sits at depth at least `log₆ (c/5)`. -/
theorem hyp_le_of_run (w : List (Fin 3)) : (run w).2.2 ≤ 5 * 6 ^ w.length := by
  induction w with
  | nil => simp [run]
  | cons x w ih =>
    have h1 : (run (x :: w)).2.2 ≤ 6 * (run w).2.2 := hyp_step_le x (run_valid w)
    have h2 : (6 : ℤ) * (run w).2.2 ≤ 6 * (5 * 6 ^ w.length) := by linarith
    calc (run (x :: w)).2.2 ≤ 6 * (5 * 6 ^ w.length) := le_trans h1 h2
      _ = 5 * 6 ^ (x :: w).length := by simp [List.length_cons, pow_succ]; ring

/-- The `B₃`-spine: applying the third matrix `k` times to the root gives the triple
`(4(k+1)² - 1, 4(k+1), 4(k+1)² + 1)`, whose hypotenuse grows only quadratically. -/
theorem spine_run (k : ℕ) :
    run (List.replicate k 2) =
      (4 * ((k : ℤ) + 1) ^ 2 - 1, 4 * ((k : ℤ) + 1), 4 * ((k : ℤ) + 1) ^ 2 + 1) := by
  induction k with
  | zero => norm_num [run]
  | succ n ih =>
    rw [List.replicate_succ, run, ih]
    simp only [step, bC]
    push_cast
    refine Prod.ext ?_ (Prod.ext ?_ ?_) <;> simp only <;> ring

/-- **The tree is exponentially unbalanced.**  For every depth `k` there is a node at
depth exactly `k` whose hypotenuse is only `4(k+1)² + 1`, while the general bound at
depth `k` is `5·6^k`. -/
theorem spine_depth_large (k : ℕ) :
    ∃ w : List (Fin 3), w.length = k ∧ (run w).2.2 = 4 * ((k : ℤ) + 1) ^ 2 + 1 := by
  refine ⟨List.replicate k 2, by simp, ?_⟩
  rw [spine_run k]

end BerggrenTree