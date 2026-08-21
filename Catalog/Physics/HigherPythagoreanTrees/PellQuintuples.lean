import Mathlib
import Catalog.Physics.HigherPythagoreanTrees.DescentComplex

/-!
# Dimension four: the descent complex acquires edges

`HigherPythagoreanDescent.DescendsOn.card_le` bounds every face `S` of the descent complex of
a Pythagorean `n`-tuple by `#S ≤ n − 2`, and
`HigherPythagoreanDescent.descent_singleton_unique_of_three` shows that for `n = 3` the complex
is at most a point plus one vertex (`#S ≤ 1`).

Here we prove that the bound is **attained** in dimension four: there are infinitely many
primitive Pythagorean quintuples whose descent complex contains a **two-element face**, i.e.
whose reflection graph has a parent obtained by flipping *two* signs simultaneously.  Such
faces are impossible in dimension three, so the geometry of the higher trees genuinely gets
richer with the dimension.

The family is Pell-theoretic: the quintuples `(1, 1, t, t ; d)` with `d² = 2t² + 2`, whose
solutions are generated from `(t, d) = (1, 2)` by the automorphism `(t,d) ↦ (3t+2d, 4t+3d)`
of the Pell form `d² − 2t²`.

Main results.

* `pell_norm` : the recursion stays on the conic `d² = 2t² + 2`.
* `pell_snd_ge` : the heights grow without bound.
* `quintuple_two_face` : for `t ≥ 4` the set `{0,1}` is a face of the descent complex of
  `(1,1,t,t;d)`.
* `dim_four_descent_bound_sharp` : arbitrarily high primitive Pythagorean quintuples with a
  two-element descent face; the bound `#S ≤ n − 2` is sharp for `n = 4`.
-/

namespace HigherPythagoreanPell

open Finset HigherPythagoreanDescent

/-- The automorphism of the Pell conic `d² − 2t² = 2`. -/
def pellStep (p : ℤ × ℤ) : ℤ × ℤ := (3 * p.1 + 2 * p.2, 4 * p.1 + 3 * p.2)

/-- The Pell solutions `(t, d)` of `d² = 2t² + 2`, starting from `(1,2)`. -/
def pell : ℕ → ℤ × ℤ
  | 0 => (1, 2)
  | (n + 1) => pellStep (pell n)

/-- The quintuple attached to a Pell solution. -/
def quintuple (t : ℤ) : Fin 4 → ℤ := ![1, 1, t, t]

theorem pell_norm (n : ℕ) : (pell n).2 ^ 2 = 2 * (pell n).1 ^ 2 + 2 := by
  induction n with
  | zero => simp [pell]
  | succ k ih =>
      simp only [pell, pellStep]
      nlinarith [ih]

theorem pell_pos (n : ℕ) : 1 ≤ (pell n).1 ∧ 2 ≤ (pell n).2 := by
  induction n with
  | zero => simp [pell]
  | succ k ih =>
      obtain ⟨h1, h2⟩ := ih
      simp only [pell, pellStep]
      constructor <;> omega

/-- The Pell heights grow at least linearly, so they are unbounded. -/
theorem pell_snd_ge (n : ℕ) : (n : ℤ) + 2 ≤ (pell n).2 := by
  induction n with
  | zero => simp [pell]
  | succ k ih =>
      obtain ⟨h1, h2⟩ := pell_pos k
      simp only [pell, pellStep]
      push_cast
      omega

/-- From the second solution on, the Pell parameter is at least `7`. -/
theorem pell_fst_ge_seven (n : ℕ) : 7 ≤ (pell (n + 1)).1 := by
  obtain ⟨h1, h2⟩ := pell_pos n
  simp only [pell, pellStep]
  omega

/-- The quintuple of a Pell solution lies on the null cone. -/
theorem quintuple_isPythTuple {t d : ℤ} (h : d ^ 2 = 2 * t ^ 2 + 2) :
    IsPythTuple (quintuple t) d := by
  unfold IsPythTuple quintuple
  simp [Fin.sum_univ_four]
  linarith

/-- The quintuple of a Pell solution has non-negative coordinates. -/
theorem quintuple_nonneg {t : ℤ} (ht : 0 ≤ t) (i : Fin 4) : 0 ≤ quintuple t i := by
  fin_cases i <;> simp [quintuple] <;> linarith

/-- **A two-element face.**  For `t ≥ 4` the two-fold sign flip on the coordinates equal to `1`
strictly lowers the height of `(1,1,t,t;d)`. -/
theorem quintuple_two_face {t d : ℤ} (ht : 4 ≤ t) (hd : 0 < d) (h : d ^ 2 = 2 * t ^ 2 + 2) :
    DescendsOn ({0, 1} : Finset (Fin 4)) (quintuple t) d := by
  have hlt : d < 2 * t - 2 := by nlinarith
  unfold DescendsOn signedSum quintuple
  simp [Fin.sum_univ_four]
  linarith

/-- The two-element face really has two elements. -/
theorem two_face_card : ({0, 1} : Finset (Fin 4)).card = 2 := by decide

/-- The quintuples `(1,1,t,t;d)` are primitive: a common divisor of all coordinates is a unit. -/
theorem quintuple_primitive {t : ℤ} (g : ℤ) (hg : ∀ i, g ∣ quintuple t i) : IsUnit g := by
  have h0 : g ∣ (1 : ℤ) := by simpa [quintuple] using hg 0
  exact isUnit_of_dvd_one h0

/-- **Sharpness of the dimension bound in dimension four.**  For every bound `N` there is a
primitive Pythagorean quintuple of height `> N`, with non-negative coordinates, whose descent
complex contains a face of size `2 = n − 2`.  Contrast with
`HigherPythagoreanDescent.descent_singleton_unique_of_three`: in dimension three all faces are
singletons. -/
theorem dim_four_descent_bound_sharp (N : ℤ) :
    ∃ (x : Fin 4 → ℤ) (d : ℤ) (S : Finset (Fin 4)),
      IsPythTuple x d ∧ (∀ i, 0 ≤ x i) ∧ N < d ∧ (∀ g : ℤ, (∀ i, g ∣ x i) → IsUnit g) ∧
        S.card = 2 ∧ DescendsOn S x d := by
  obtain ⟨n, hn⟩ : ∃ n : ℕ, N < (n : ℤ) + 2 := by
    refine ⟨(N + 1).toNat, ?_⟩
    have := Int.self_le_toNat (N + 1)
    omega
  set t := (pell (n + 1)).1 with hts
  set d := (pell (n + 1)).2 with hds
  have hnorm : d ^ 2 = 2 * t ^ 2 + 2 := pell_norm (n + 1)
  have ht7 : 7 ≤ t := pell_fst_ge_seven n
  have hdN : N < d := by
    have h1 : ((n : ℤ) + 1) + 2 ≤ d := by
      have := pell_snd_ge (n + 1)
      push_cast at this
      linarith
    linarith
  have hdpos : 0 < d := by linarith [(pell_pos (n + 1)).2]
  refine ⟨quintuple t, d, {0, 1}, quintuple_isPythTuple hnorm,
    quintuple_nonneg (by linarith), hdN, ?_, two_face_card, ?_⟩
  · intro g hg
    exact quintuple_primitive (t := t) g hg
  · exact quintuple_two_face (by linarith) hdpos hnorm

end HigherPythagoreanPell