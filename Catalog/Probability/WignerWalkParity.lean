/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license.

# The sign-flip involution at arbitrary order: parity of edge multiplicities

`Probability.WignerRademacherEnsemble` kills the expectation of a closed **4**-walk
whose first edge is traversed exactly once, by flipping the Rademacher variable
attached to that edge.  This file isolates the mechanism and proves it at
**arbitrary order**, for an arbitrary walk of arbitrary length:

* `RademacherWigner.prod_entry_flipEdge` — flipping the sign of one edge `p`
  multiplies the product of matrix entries along a walk by `(-1)^c`, where `c` is
  the number of steps of the walk that traverse `p`;
* `RademacherWigner.expect_prod_entry_eq_zero` — hence, if some edge is traversed
  an **odd** number of times, the ensemble average of the walk monomial is `0`.

This is the exact combinatorial reason why only walks whose edge multiset has all
multiplicities even survive in `E [ tr W^m ]`, which is the input to the
moment-method proof of the semicircle law at every order.  Two instantiations are
given: the length-four case, which reproves
`RademacherWigner.expect_term_eq_zero`, and the length-six case, which is the first
case not covered by the earlier files (and the first step towards the exact sixth
trace moment).
-/
import Probability.WignerRademacherEnsemble

open Matrix BigOperators Finset

namespace RademacherWigner

variable {N : ℕ}

/-! ### Edge multiplicities along a walk -/

/-- The number of the first `m` steps of the walk `w` that traverse the edge `p`. -/
noncomputable def edgeCount (m : ℕ) (w : ℕ → Fin N) (p : Fin N × Fin N) : ℕ :=
  ((Finset.range m).filter fun t => edgeOf (w t) (w (t + 1)) = p).card

/-- The monomial attached to the first `m` steps of the walk `w`. -/
def walkProd (g : Config N) (m : ℕ) (w : ℕ → Fin N) : ℝ :=
  ∏ t ∈ Finset.range m, entry g (w t) (w (t + 1))

/-- **The sign-flip rule at arbitrary order.**  Flipping the Rademacher variable
attached to the edge `p` multiplies the walk monomial by `(-1)` once for every step
of the walk that traverses `p`. -/
theorem prod_entry_flipEdge (g : Config N) (m : ℕ) (w : ℕ → Fin N) (p : Fin N × Fin N) :
    walkProd (flipEdge p g) m w = (-1) ^ edgeCount m w p * walkProd g m w := by
  have h : ∀ t : ℕ, entry (flipEdge p g) (w t) (w (t + 1))
      = (if edgeOf (w t) (w (t + 1)) = p then (-1 : ℝ) else 1)
          * entry g (w t) (w (t + 1)) := by
    intro t
    rw [entry_flipEdge]
    split <;> ring
  unfold walkProd
  rw [Finset.prod_congr rfl fun t _ => h t, Finset.prod_mul_distrib]
  congr 1
  rw [Finset.prod_ite, Finset.prod_const, Finset.prod_const_one, mul_one, edgeCount]

/-- **Parity obstruction.**  If some edge is traversed an odd number of times by the
walk, the ensemble average of the walk monomial vanishes — at every finite `N`, for
every walk, of every length. -/
theorem expect_prod_entry_eq_zero (m : ℕ) (w : ℕ → Fin N) (p : Fin N × Fin N)
    (hodd : Odd (edgeCount m w p)) :
    expect (fun g : Config N => walkProd g m w) = 0 := by
  have hneg : ∀ g : Config N, walkProd (flipEdge p g) m w = -walkProd g m w := by
    intro g
    rw [prod_entry_flipEdge, hodd.neg_one_pow, neg_one_mul]
  have hsum : (∑ g : Config N, walkProd g m w) = 0 := by
    have h1 := Equiv.sum_comp (flipEdge (N := N) p) (fun g => walkProd g m w)
    rw [Finset.sum_congr rfl fun g _ => hneg g, Finset.sum_neg_distrib] at h1
    linarith
  unfold expect
  rw [hsum, zero_div]

/-- A walk that traverses the edge `p` at exactly one of its steps has vanishing
ensemble average. -/
theorem expect_prod_entry_eq_zero_of_unique_step (m : ℕ) (w : ℕ → Fin N)
    (p : Fin N × Fin N)
    (hstep : ((Finset.range m).filter fun t => edgeOf (w t) (w (t + 1)) = p) = {0}) :
    expect (fun g : Config N => walkProd g m w) = 0 := by
  refine expect_prod_entry_eq_zero m w p ?_
  rw [edgeCount, hstep]
  simp

/-! ### The closed four-walk, revisited -/

/-- The closed 4-walk `i → j → k → l → i`, as a `4`-periodic function on `ℕ`. -/
def walk4 (i j k l : Fin N) : ℕ → Fin N := fun t =>
  if t % 4 = 0 then i else if t % 4 = 1 then j else if t % 4 = 2 then k else l

@[simp] theorem walkProd_walk4 (g : Config N) (i j k l : Fin N) :
    walkProd g 4 (walk4 i j k l)
      = entry g i j * entry g j k * entry g k l * entry g l i := by
  simp [walkProd, walk4, Finset.prod_range_succ]

/-- In a nondegenerate closed 4-walk the edge `{i,j}` is traversed at the first step
only. -/
theorem filter_edge_walk4 {i j k l : Fin N} (hij : i ≠ j) (hjk : j ≠ k) (hkl : k ≠ l)
    (hli : l ≠ i) (hik : i ≠ k) (hjl : j ≠ l) :
    ((Finset.range 4).filter fun t =>
        edgeOf (walk4 i j k l t) (walk4 i j k l (t + 1)) = edgeOf i j) = {0} := by
  obtain ⟨e2, e3, e4⟩ := edges_ne_first hij hjk hkl hli hik hjl
  ext t
  simp only [Finset.mem_filter, Finset.mem_range, Finset.mem_singleton]
  constructor
  · rintro ⟨ht, hedge⟩
    interval_cases t
    · rfl
    · exact absurd (by simpa [walk4] using hedge) e2
    · exact absurd (by simpa [walk4] using hedge) e3
    · exact absurd (by simpa [walk4] using hedge) e4
  · rintro rfl
    exact ⟨by norm_num, by simp [walk4]⟩

/-- The length-four instance of the general parity obstruction: it reproves
`expect_term_eq_zero`. -/
theorem expect_walk4_eq_zero {i j k l : Fin N} (hij : i ≠ j) (hjk : j ≠ k) (hkl : k ≠ l)
    (hli : l ≠ i) (hik : i ≠ k) (hjl : j ≠ l) :
    expect (fun g : Config N => entry g i j * entry g j k * entry g k l * entry g l i) = 0 := by
  have h := expect_prod_entry_eq_zero_of_unique_step 4 (walk4 i j k l) (edgeOf i j)
    (filter_edge_walk4 hij hjk hkl hli hik hjl)
  simpa using h

/-! ### The closed six-walk -/

/-- The closed 6-walk `i → j → k → l → m → n → i`, as a `6`-periodic function. -/
def walk6 (i j k l m n : Fin N) : ℕ → Fin N := fun t =>
  if t % 6 = 0 then i else if t % 6 = 1 then j else if t % 6 = 2 then k
  else if t % 6 = 3 then l else if t % 6 = 4 then m else n

@[simp] theorem walkProd_walk6 (g : Config N) (i j k l m n : Fin N) :
    walkProd g 6 (walk6 i j k l m n)
      = entry g i j * entry g j k * entry g k l * entry g l m * entry g m n * entry g n i := by
  simp [walkProd, walk6, Finset.prod_range_succ]

/-- If none of the five later steps of a closed 6-walk repeats its first edge
`{i,j}`, then that edge is traversed exactly once. -/
theorem filter_edge_walk6 {i j k l m n : Fin N}
    (e2 : edgeOf j k ≠ edgeOf i j) (e3 : edgeOf k l ≠ edgeOf i j)
    (e4 : edgeOf l m ≠ edgeOf i j) (e5 : edgeOf m n ≠ edgeOf i j)
    (e6 : edgeOf n i ≠ edgeOf i j) :
    ((Finset.range 6).filter fun t =>
        edgeOf (walk6 i j k l m n t) (walk6 i j k l m n (t + 1)) = edgeOf i j) = {0} := by
  ext t
  simp only [Finset.mem_filter, Finset.mem_range, Finset.mem_singleton]
  constructor
  · rintro ⟨ht, hedge⟩
    interval_cases t
    · rfl
    · exact absurd (by simpa [walk6] using hedge) e2
    · exact absurd (by simpa [walk6] using hedge) e3
    · exact absurd (by simpa [walk6] using hedge) e4
    · exact absurd (by simpa [walk6] using hedge) e5
    · exact absurd (by simpa [walk6] using hedge) e6
  · rintro rfl
    exact ⟨by norm_num, by simp [walk6]⟩

/-- **Sixth-order parity obstruction.**  A closed 6-walk that traverses its first
edge exactly once has vanishing ensemble average.  This is the first case beyond the
reach of the fourth-moment analysis of `Probability.WignerRademacherEnsemble`, and it
is the vanishing input for the exact sixth trace moment. -/
theorem expect_walk6_eq_zero {i j k l m n : Fin N}
    (e2 : edgeOf j k ≠ edgeOf i j) (e3 : edgeOf k l ≠ edgeOf i j)
    (e4 : edgeOf l m ≠ edgeOf i j) (e5 : edgeOf m n ≠ edgeOf i j)
    (e6 : edgeOf n i ≠ edgeOf i j) :
    expect (fun g : Config N =>
        entry g i j * entry g j k * entry g k l * entry g l m * entry g m n * entry g n i) = 0 := by
  have h := expect_prod_entry_eq_zero_of_unique_step 6 (walk6 i j k l m n) (edgeOf i j)
    (filter_edge_walk6 e2 e3 e4 e5 e6)
  simpa using h

end RademacherWigner