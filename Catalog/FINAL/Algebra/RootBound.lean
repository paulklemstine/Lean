/-
  # Polynomial Root Bound and Schwartz–Zippel Soundness

  The univariate finite-field root bound is a cornerstone of modern
  algebraic verification: it powers Reed–Solomon distance, STARK/SNARK
  soundness, and polynomial identity testing.

  ## Main Results

  - `card_roots_le_natDegree_filter`: For nonzero p, the number of roots
    of p inside any finite set S is at most p.natDegree.
  - `zero_set_card_le_natDegree`: Specialization to the full finite field.
  - `random_point_soundness_bound`: Probability form: Pr[p(a)=0] ≤ deg(p)/|F|.
  - `schwartz_zippel_univariate`: Named soundness theorem for PIT.
-/

import Mathlib

open Classical Polynomial Finset

/-! ## Core root-count bound -/

/-- **Root-count bound (filter form)**: For a nonzero polynomial `p` over a
field `F`, the number of elements of any finite set `S ⊆ F` at which `p`
evaluates to zero is at most `p.natDegree`.

This is the univariate Schwartz–Zippel lemma and equivalently the
minimum-distance statement for Reed–Solomon codes. -/
theorem card_roots_le_natDegree_filter
    {F : Type*} [Field F]
    (p : Polynomial F) (hp : p ≠ 0) (s : Finset F) :
    (s.filter fun a => p.eval a = 0).card ≤ p.natDegree := by
  have hroots : p.roots.card ≤ p.natDegree := by
    have h := Polynomial.card_roots hp
    rw [Polynomial.degree_eq_natDegree hp] at h
    exact_mod_cast h
  calc (s.filter fun a => p.eval a = 0).card
      ≤ p.roots.toFinset.card := by
        apply Finset.card_le_card
        intro a ha
        simp only [Finset.mem_filter] at ha
        rw [Multiset.mem_toFinset, Polynomial.mem_roots hp]
        exact ha.2
    _ ≤ p.roots.card := Multiset.toFinset_card_le _
    _ ≤ p.natDegree := hroots

/-! ## Finite-field specialization -/

/-- **Zero-set bound over finite fields**: For a nonzero polynomial `p`
over a finite field `F`, the number of field elements at which `p`
vanishes is at most `p.natDegree`. -/
theorem zero_set_card_le_natDegree
    {F : Type*} [Field F] [Fintype F]
    (p : Polynomial F) (hp : p ≠ 0) :
    (Finset.univ.filter fun a : F => p.eval a = 0).card ≤ p.natDegree :=
  card_roots_le_natDegree_filter p hp Finset.univ

/-! ## Probability / soundness form -/

/-- **Random-point soundness**: For a nonzero polynomial `p` over a
finite field `F`, the fraction of field elements at which `p` vanishes
is at most `deg(p) / |F|`. This is the probability that a uniformly
random evaluation point fails to detect that `p ≠ 0`. -/
theorem random_point_soundness_bound
    {F : Type*} [Field F] [Fintype F]
    (p : Polynomial F) (hp : p ≠ 0) :
    ((Finset.univ.filter fun a : F => p.eval a = 0).card : ℚ) / Fintype.card F
      ≤ (p.natDegree : ℚ) / Fintype.card F := by
  apply div_le_div_of_nonneg_right _ (by positivity)
  exact_mod_cast zero_set_card_le_natDegree p hp

/-- **Schwartz–Zippel univariate soundness**: Alternative name emphasizing
the connection to polynomial identity testing. If `p ≠ 0` over a finite
field, then a uniformly random point detects nonzeroness with probability
at least `1 - deg(p)/|F|`. -/
theorem schwartz_zippel_univariate
    {F : Type*} [Field F] [Fintype F]
    (p : Polynomial F) (hp : p ≠ 0) :
    ((Finset.univ.filter fun a : F => p.eval a = 0).card : ℚ) / Fintype.card F
      ≤ (p.natDegree : ℚ) / Fintype.card F :=
  random_point_soundness_bound p hp

/-! ## Complement form: nonvanishing probability -/

/-- The number of points where a nonzero polynomial does NOT vanish is at
least `|F| - deg(p)`. -/
theorem card_nonroots_ge
    {F : Type*} [Field F] [Fintype F]
    (p : Polynomial F) (hp : p ≠ 0) :
    Fintype.card F - p.natDegree
      ≤ (Finset.univ.filter fun a : F => p.eval a ≠ 0).card := by
  have htotal : (Finset.univ.filter fun a : F => p.eval a = 0).card +
      (Finset.univ.filter fun a : F => p.eval a ≠ 0).card = Fintype.card F := by
    rw [← Finset.card_union_of_disjoint]
    · congr 1
      ext a
      simp only [Finset.mem_union, Finset.mem_filter, Finset.mem_univ, true_and]
      tauto
    · exact Finset.disjoint_filter.mpr (fun a _ h1 h2 => h2 h1)
  have hle := zero_set_card_le_natDegree p hp
  omega

/-! ## Reed–Solomon distance interpretation -/

/-- **Reed–Solomon minimum distance**: A nonzero codeword (polynomial of
degree ≤ d evaluated over all of F) has Hamming weight at least |F| - d.
Equivalently, the minimum distance of the Reed–Solomon code RS[F, d] is
|F| - d. This is a direct restatement of the root bound. -/
theorem reed_solomon_min_distance
    {F : Type*} [Field F] [Fintype F]
    (p : Polynomial F) (hp : p ≠ 0) :
    Fintype.card F - p.natDegree
      ≤ (Finset.univ.filter fun a : F => p.eval a ≠ 0).card :=
  card_nonroots_ge p hp