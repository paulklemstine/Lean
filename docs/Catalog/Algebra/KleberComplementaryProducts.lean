/-
# Complementary products of monomial symmetric functions

This file develops, from scratch inside `MvPolynomial (Fin N) R`, the theory needed to
attack the *componentwise splitting independence* phenomenon studied in the paper
"Kleber's conjecture and complementary products of symmetric functions":

> for a partition `θ`, the products `s_α s_β` are linearly independent as `{α, β}` ranges
> over unordered pairs of partitions with `α + β = θ`,

together with its stated analogue for **monomial** symmetric functions over fields of
characteristic zero and over `ℤ`.

Mathlib has no ring of symmetric functions and no Schur functions, so everything here is
built by hand.  We work with *monomial symmetric polynomials* `msym R d`, the sum of all
distinct permutations of a monomial `x^d` in `N` variables; these are exactly the monomial
symmetric functions `m_λ` when `N` is at least the number of parts involved.

## Main results

* `KleberSplit.linearIndependent_msym_mul`: if `{α_i, β_i}` is a finite family of pairs of
  exponent vectors whose *multiset unions* `parts α_i + parts β_i` are pairwise distinct
  (and which fit into `N` variables), then the products `m_{α_i} m_{β_i}` are linearly
  independent over any characteristic-zero domain (in particular over `ℤ` and over any
  field of characteristic zero).
* `KleberSplit.linearIndependent_msym_complementary`: the specialisation to
  componentwise splittings `α_i + β_i = θ` of a fixed `θ`.
* `KleberSplit.linearIndependent_msym`: the monomial symmetric polynomials themselves are
  linearly independent (the case `β = 0`).
* `KleberSplit.linearIndependent_kleber_complementary`: the Kleber-style form, for
  complementary pairs `(λ, ρ - λ)` inside a fixed shape `ρ` (e.g. a rectangle), where the
  hypothesis that the variables suffice is derived rather than assumed.
* `KleberSplit.linearIndependent_row_splittings`: the full one-row case
  `θ = (n)`: the products `m_{(k)} m_{(n-k)}`, `2 * k ≤ n`, are linearly independent.
* `KleberSplit.parts_union_eq_of_msym_mul_eq`: a product `m_α m_β` determines the multiset
  union `parts α + parts β`.
* `KleberSplit.not_linearIndependent_of_too_few_variables` and
  `KleberSplit.linearIndependent_collision_pair_two` (with its special case
  `KleberSplit.linearIndependent_collision_pair`): the two hypotheses are, respectively,
  necessary and not necessary.

The generalisation to products of arbitrarily many factors is in
`Algebra.KleberManyFoldProducts`.

## The mechanism

The Schur-function proof cannot use the dominance-leading term of `s_α s_β`, since every
splitting of `θ` has the *same* leading term `s_θ`.  The mechanism isolated here is the
opposite end of the expansion, controlled by the quadratic statistic
`Qstat d = ∑ i, (d i)^2`:

* `Qstat (u + v) = Qstat u + Qstat v + 2 * dotp u v` (`Qstat_add`), so any monomial
  occurring in `m_α m_β` has `Qstat` **at least** `Qstat α + Qstat β`;
* equality holds exactly when the two exponent vectors have disjoint supports
  (`dotp_eq_zero_iff`), in which case the resulting monomial has part multiset
  `parts α + parts β`, the multiset union.

So the `Qstat`-minimal monomials of `m_α m_β` remember precisely the multiset union of
`α` and `β`, which yields a genuine (non-dominance) triangularity argument.

## Boundary

The hypothesis that the unions are distinct is *not* automatic for componentwise
splittings: `KleberSplit.union_collision_five_three` exhibits two distinct splittings of
`θ = (5,3)` with the same union.  This is exactly the obstruction that makes the full
theorem of the paper hard, and it is recorded here honestly rather than hidden.
-/

import Mathlib

namespace KleberSplit

open Finsupp MvPolynomial Finset

variable {N : ℕ}

/-- Exponent vectors of monomials in `N` variables. -/
abbrev Exp (N : ℕ) := Fin N →₀ ℕ

/-! ### Parts, orbits and the quadratic statistic -/

/-- The multiset of nonzero parts of an exponent vector, i.e. the partition it rearranges
to (as an unordered multiset). -/
def parts (d : Exp N) : Multiset ℕ := d.support.val.map d

/-- The orbit of an exponent vector under permutations of the `N` variables. -/
def orbit (d : Exp N) : Finset (Exp N) :=
  Finset.univ.image (fun e : Equiv.Perm (Fin N) => Finsupp.equivMapDomain e d)

/-- The quadratic statistic `∑ i, d i ^ 2`; it is permutation invariant and superadditive
with an explicit error term. -/
def Qstat (d : Exp N) : ℕ := ∑ i : Fin N, (d i) ^ 2

/-- The inner product of two exponent vectors. -/
def dotp (u v : Exp N) : ℕ := ∑ i : Fin N, u i * v i

lemma self_mem_orbit (d : Exp N) : d ∈ orbit d :=
  Finset.mem_image.2 ⟨Equiv.refl _, Finset.mem_univ _, by simp⟩

lemma equivMapDomain_mem_orbit (e : Equiv.Perm (Fin N)) (d : Exp N) :
    Finsupp.equivMapDomain e d ∈ orbit d :=
  Finset.mem_image.2 ⟨e, Finset.mem_univ _, rfl⟩

lemma support_equivMapDomain (e : Equiv.Perm (Fin N)) (d : Exp N) :
    (Finsupp.equivMapDomain e d).support = d.support.map e.toEmbedding :=
  Finset.val_inj.mp rfl

lemma parts_equivMapDomain (e : Equiv.Perm (Fin N)) (d : Exp N) :
    parts (Finsupp.equivMapDomain e d) = parts d := by
  unfold parts
  rw [support_equivMapDomain]
  simp [Finset.map_val, Multiset.map_map, Function.comp]

lemma Qstat_equivMapDomain (e : Equiv.Perm (Fin N)) (d : Exp N) :
    Qstat (Finsupp.equivMapDomain e d) = Qstat d := by
  unfold Qstat
  rw [← Equiv.sum_comp e (fun i => ((Finsupp.equivMapDomain e d) i) ^ 2)]
  simp [Finsupp.equivMapDomain_apply]

lemma parts_of_mem_orbit {d u : Exp N} (h : u ∈ orbit d) : parts u = parts d := by
  obtain ⟨e, -, rfl⟩ := Finset.mem_image.1 h
  exact parts_equivMapDomain e d

lemma Qstat_of_mem_orbit {d u : Exp N} (h : u ∈ orbit d) : Qstat u = Qstat d := by
  obtain ⟨e, -, rfl⟩ := Finset.mem_image.1 h
  exact Qstat_equivMapDomain e d

/-- The exact defect in superadditivity of `Qstat`. -/
lemma Qstat_add (u v : Exp N) : Qstat (u + v) = Qstat u + Qstat v + 2 * dotp u v := by
  unfold Qstat dotp
  rw [← Finset.sum_add_distrib, Finset.mul_sum, ← Finset.sum_add_distrib]
  refine Finset.sum_congr rfl fun i _ => ?_
  simp only [Finsupp.add_apply]
  ring

lemma dotp_eq_zero_iff (u v : Exp N) : dotp u v = 0 ↔ Disjoint u.support v.support := by
  unfold dotp
  rw [Finset.sum_eq_zero_iff]
  constructor
  · intro h
    rw [Finset.disjoint_left]
    intro i hu hv
    have hzero := h i (Finset.mem_univ i)
    simp only [Finsupp.mem_support_iff] at hu hv
    exact absurd hzero (by positivity)
  · intro h i _
    rw [Finset.disjoint_left] at h
    by_cases hu : i ∈ u.support
    · have hv : v i = 0 := Finsupp.notMem_support_iff.mp (h hu)
      simp [hv]
    · have hu' : u i = 0 := Finsupp.notMem_support_iff.mp hu
      simp [hu']

/-- For disjointly supported exponent vectors, the parts of the sum are the multiset union
of the parts. -/
lemma parts_add_of_disjoint {u v : Exp N} (h : Disjoint u.support v.support) :
    parts (u + v) = parts u + parts v := by
  unfold parts
  have hs : (u + v).support = u.support.disjUnion v.support h := by
    rw [Finset.disjUnion_eq_union]
    exact Finsupp.support_add_eq h
  rw [hs, Finset.disjUnion_val, Multiset.map_add]
  congr 1
  · refine Multiset.map_congr rfl fun i hi => ?_
    have hv : v i = 0 := by
      rw [Finset.disjoint_left] at h
      exact Finsupp.notMem_support_iff.mp (h hi)
    simp [hv]
  · refine Multiset.map_congr rfl fun i hi => ?_
    have hu : u i = 0 := by
      rw [Finset.disjoint_right] at h
      exact Finsupp.notMem_support_iff.mp (h hi)
    simp [hu]

/-- Two exponent vectors that fit into `N` variables can be placed with disjoint supports
after permuting the variables of the second one. -/
lemma exists_placement_avoiding (F : Finset (Fin N)) (b : Exp N)
    (h : F.card + b.support.card ≤ N) :
    ∃ e : Equiv.Perm (Fin N), Disjoint F (Finsupp.equivMapDomain e b).support := by
  have hcompl : b.support.card ≤ (Fᶜ : Finset (Fin N)).card := by
    rw [Finset.card_compl]
    simp only [Fintype.card_fin]
    omega
  obtain ⟨T, hTsub, hTcard⟩ := Finset.exists_subset_card_eq hcompl
  let φ : {x // x ∈ b.support} ≃ {x // x ∈ T} := Finset.equivOfCardEq (by simp [hTcard])
  refine ⟨Equiv.extendSubtype φ, ?_⟩
  rw [support_equivMapDomain, Finset.disjoint_right]
  intro j hj
  simp only [Finset.mem_map, Equiv.coe_toEmbedding] at hj
  obtain ⟨i, hi, rfl⟩ := hj
  have hmem : (Equiv.extendSubtype φ) i ∈ T := by
    rw [Equiv.extendSubtype_apply_of_mem φ i hi]
    exact (φ ⟨i, hi⟩).2
  simpa using hTsub hmem

lemma exists_disjoint_placement (a b : Exp N)
    (h : a.support.card + b.support.card ≤ N) :
    ∃ e : Equiv.Perm (Fin N), Disjoint a.support (Finsupp.equivMapDomain e b).support :=
  exists_placement_avoiding a.support b h

/-! ### Monomial symmetric polynomials -/

/-- The monomial symmetric polynomial attached to an exponent vector: the sum of all
distinct rearrangements of the monomial `x ^ d`. -/
noncomputable def msym (R : Type*) [CommSemiring R] (d : Exp N) : MvPolynomial (Fin N) R :=
  ∑ w ∈ orbit d, MvPolynomial.monomial w (1 : R)

variable {R : Type*} [CommRing R] {S : Type*} [CommSemiring S]

lemma coeff_msym (d w : Exp N) :
    MvPolynomial.coeff w (msym S d) = if w ∈ orbit d then 1 else 0 := by
  unfold msym
  rw [MvPolynomial.coeff_sum]
  simp [MvPolynomial.coeff_monomial, Finset.sum_ite_eq']

/-- The coefficients of a product of two monomial symmetric polynomials are the counts of
the ways of splitting the monomial. -/
lemma coeff_msym_mul (a b w : Exp N) :
    MvPolynomial.coeff w (msym S a * msym S b)
      = (((Finset.antidiagonal w).filter
          (fun x : Exp N × Exp N => x.1 ∈ orbit a ∧ x.2 ∈ orbit b)).card : S) := by
  rw [MvPolynomial.coeff_mul, ← Finset.sum_boole]
  refine Finset.sum_congr rfl fun x _ => ?_
  rw [coeff_msym, coeff_msym]
  by_cases h1 : x.1 ∈ orbit a <;> by_cases h2 : x.2 ∈ orbit b <;> simp [h1, h2]

/-- A monomial occurring in `m_a * m_b` really is a sum of a rearrangement of `a` and a
rearrangement of `b`. -/
lemma exists_split_of_coeff_ne_zero {a b w : Exp N}
    (h : MvPolynomial.coeff w (msym S a * msym S b) ≠ 0) :
    ∃ u ∈ orbit a, ∃ v ∈ orbit b, u + v = w := by
  rw [coeff_msym_mul] at h
  have hcard : (((Finset.antidiagonal w).filter
      (fun x : Exp N × Exp N => x.1 ∈ orbit a ∧ x.2 ∈ orbit b)).card) ≠ 0 := by
    intro h0
    rw [h0] at h
    simp at h
  obtain ⟨x, hx⟩ := Finset.card_ne_zero.1 hcard
  rw [Finset.mem_filter, Finset.mem_antidiagonal] at hx
  exact ⟨x.1, hx.2.1, x.2, hx.2.2, hx.1⟩

/-- Any monomial of the form `u + v` with `u` a rearrangement of `a` and `v` a
rearrangement of `b` really occurs in `m_a * m_b` (over a characteristic-zero ring). -/
lemma coeff_add_mem_orbit_ne_zero [CharZero S] {a b u v : Exp N}
    (hu : u ∈ orbit a) (hv : v ∈ orbit b) :
    MvPolynomial.coeff (u + v) (msym S a * msym S b) ≠ 0 := by
  classical
  set w := u + v with hw
  rw [coeff_msym_mul]
  have hne : (((Finset.antidiagonal w).filter
      (fun x : Exp N × Exp N => x.1 ∈ orbit a ∧ x.2 ∈ orbit b))).Nonempty := by
    refine ⟨(u, v), ?_⟩
    rw [Finset.mem_filter, Finset.mem_antidiagonal]
    exact ⟨rfl, hu, hv⟩
  exact Nat.cast_ne_zero.2 (Finset.card_ne_zero.2 hne)

/-! ### The independence theorem -/

/-- **Independence of products with distinct multiset unions.**

If a finite family of pairs of exponent vectors `(α i, β i)` fits into `N` variables and
the multiset unions `parts (α i) + parts (β i)` are pairwise distinct, then the products
of monomial symmetric polynomials `m_{α i} * m_{β i}` are linearly independent over any
characteristic-zero domain.

Since the union is invariant under swapping `α` and `β`, the hypothesis in particular
forces the unordered pairs `{α i, β i}` to be pairwise distinct: this is the "unordered
pairs" indexing of the paper. -/
theorem linearIndependent_msym_mul [IsDomain R] [CharZero R]
    {ι : Type*} [Fintype ι] (a b : ι → Exp N)
    (hcard : ∀ i, (a i).support.card + (b i).support.card ≤ N)
    (hinj : Function.Injective fun i => parts (a i) + parts (b i)) :
    LinearIndependent R (fun i => msym R (a i) * msym R (b i)) := by
  classical
  rw [Fintype.linearIndependent_iff]
  by_contra hcon
  push_neg at hcon
  obtain ⟨g, hg, i₁, hi₁⟩ := hcon
  set S : Finset ι := Finset.univ.filter (fun i => g i ≠ 0) with hS
  have hSne : S.Nonempty := ⟨i₁, by simp [hS, hi₁]⟩
  obtain ⟨i₀, hi₀S, hmin⟩ :=
    S.exists_min_image (fun i => Qstat (a i) + Qstat (b i)) hSne
  have hg₀ : g i₀ ≠ 0 := by simpa [hS] using hi₀S
  obtain ⟨e, he⟩ := exists_disjoint_placement (a i₀) (b i₀) (hcard i₀)
  set w₀ : Exp N := a i₀ + Finsupp.equivMapDomain e (b i₀) with hw₀
  -- the `Qstat` of the chosen monomial
  have hQw₀ : Qstat w₀ = Qstat (a i₀) + Qstat (b i₀) := by
    rw [hw₀, Qstat_add, (dotp_eq_zero_iff _ _).2 he, Qstat_equivMapDomain]
    omega
  have hpartsw₀ : parts w₀ = parts (a i₀) + parts (b i₀) := by
    rw [hw₀, parts_add_of_disjoint he, parts_equivMapDomain]
  -- take the coefficient of `w₀` in the vanishing relation
  have hcoeff := congrArg (MvPolynomial.coeff w₀) hg
  rw [MvPolynomial.coeff_sum] at hcoeff
  simp only [smul_eq_mul, MvPolynomial.coeff_smul, MvPolynomial.coeff_zero] at hcoeff
  have hvanish : ∀ i ∈ Finset.univ, i ≠ i₀ →
      g i * MvPolynomial.coeff w₀ (msym R (a i) * msym R (b i)) = 0 := by
    intro i _ hne
    by_cases hgi : g i = 0
    · simp [hgi]
    have hiS : i ∈ S := by simp [hS, hgi]
    by_cases hc : MvPolynomial.coeff w₀ (msym R (a i) * msym R (b i)) = 0
    · simp [hc]
    exfalso
    obtain ⟨u, hu, v, hv, huv⟩ := exists_split_of_coeff_ne_zero hc
    have hQ : Qstat w₀ = Qstat (a i) + Qstat (b i) + 2 * dotp u v := by
      rw [← huv, Qstat_add, Qstat_of_mem_orbit hu, Qstat_of_mem_orbit hv]
    have hle : Qstat (a i₀) + Qstat (b i₀) ≤ Qstat (a i) + Qstat (b i) := hmin i hiS
    have hdot : dotp u v = 0 := by omega
    have hdisj : Disjoint u.support v.support := (dotp_eq_zero_iff u v).1 hdot
    have : parts (a i) + parts (b i) = parts (a i₀) + parts (b i₀) := by
      rw [← parts_of_mem_orbit hu, ← parts_of_mem_orbit hv, ← parts_add_of_disjoint hdisj,
        huv, hpartsw₀]
    exact hne (hinj this)
  rw [Finset.sum_eq_single_of_mem i₀ (Finset.mem_univ i₀) hvanish] at hcoeff
  have hne0 : MvPolynomial.coeff w₀ (msym R (a i₀) * msym R (b i₀)) ≠ 0 :=
    coeff_add_mem_orbit_ne_zero (self_mem_orbit _) (equivMapDomain_mem_orbit e (b i₀))
  rcases mul_eq_zero.1 hcoeff with h | h
  · exact hg₀ h
  · exact hne0 h

/-- **Complementary (componentwise) splittings of a fixed `θ`.**  The products
`m_α * m_{θ - α}` over a family of complementary splittings of `θ` with pairwise distinct
multiset unions are linearly independent.  This is the monomial-symmetric-function form of
the componentwise splitting statement, with the second partition of the pair given
explicitly as the complement `θ - α`. -/
theorem linearIndependent_msym_complementary [IsDomain R] [CharZero R]
    {ι : Type*} [Fintype ι] (θ : Exp N) (a : ι → Exp N)
    (hcard : ∀ i, (a i).support.card + (θ - a i).support.card ≤ N)
    (hinj : Function.Injective fun i => parts (a i) + parts (θ - a i)) :
    LinearIndependent R (fun i => msym R (a i) * msym R (θ - a i)) :=
  linearIndependent_msym_mul _ _ hcard hinj

lemma support_subset_of_le {a b : Exp N} (h : a ≤ b) : a.support ⊆ b.support := by
  intro i hi
  have hai : a i ≠ 0 := Finsupp.mem_support_iff.1 hi
  have : a i ≤ b i := h i
  exact Finsupp.mem_support_iff.2 (by omega)

lemma support_tsub_subset (a b : Exp N) : (a - b).support ⊆ a.support := by
  intro i hi
  have hi' : (a - b) i ≠ 0 := Finsupp.mem_support_iff.1 hi
  rw [Finsupp.tsub_apply] at hi'
  exact Finsupp.mem_support_iff.2 (by omega)

/-- **Kleber-style complementary products.**

Fix a shape `ρ` (for Kleber's conjecture, a rectangle `(c^r)`) and consider the
complementary pairs `(λ, ρ - λ)` for `λ ≤ ρ`.  If the number of variables is at least twice
the number of rows of `ρ` — so that both members of a pair always fit — and the multiset
unions of the pairs are pairwise distinct, then the complementary products
`m_λ m_{λ^∨}` are linearly independent over any characteristic-zero domain.

Here the fitting hypothesis is *derived*, not assumed.  Note that `parts` is invariant under
permuting variables, so it is irrelevant whether the complement is read off in reverse
order, as in the usual definition of the rectangular complement. -/
theorem linearIndependent_kleber_complementary [IsDomain R] [CharZero R]
    {ι : Type*} [Fintype ι] (rho : Exp N) (lam : ι → Exp N) (hle : ∀ i, lam i ≤ rho)
    (hN : 2 * rho.support.card ≤ N)
    (hinj : Function.Injective fun i => parts (lam i) + parts (rho - lam i)) :
    LinearIndependent R (fun i => msym R (lam i) * msym R (rho - lam i)) := by
  refine linearIndependent_msym_mul _ _ (fun i => ?_) hinj
  have h1 : (lam i).support.card ≤ rho.support.card :=
    Finset.card_le_card (support_subset_of_le (hle i))
  have h2 : (rho - lam i).support.card ≤ rho.support.card :=
    Finset.card_le_card (support_tsub_subset rho (lam i))
  omega

/-- **Integral form.**  Linear independence over `ℤ` of the complementary products, which is
the integrality statement in the setting of monomial symmetric functions. -/
theorem linearIndependent_msym_mul_int
    {ι : Type*} [Fintype ι] (a b : ι → Exp N)
    (hcard : ∀ i, (a i).support.card + (b i).support.card ≤ N)
    (hinj : Function.Injective fun i => parts (a i) + parts (b i)) :
    LinearIndependent ℤ (fun i => msym ℤ (a i) * msym ℤ (b i)) :=
  linearIndependent_msym_mul a b hcard hinj

/-- **Rational form.**  The same statement over `ℚ` (and hence over any field of
characteristic zero, by `linearIndependent_msym_mul`). -/
theorem linearIndependent_msym_mul_rat
    {ι : Type*} [Fintype ι] (a b : ι → Exp N)
    (hcard : ∀ i, (a i).support.card + (b i).support.card ≤ N)
    (hinj : Function.Injective fun i => parts (a i) + parts (b i)) :
    LinearIndependent ℚ (fun i => msym ℚ (a i) * msym ℚ (b i)) :=
  linearIndependent_msym_mul a b hcard hinj

lemma parts_single (i : Fin N) (x : ℕ) :
    parts (Finsupp.single i x) = if x = 0 then 0 else {x} := by
  by_cases hx : x = 0
  · simp [hx, parts]
  · simp [parts, Finsupp.support_single_ne_zero i hx, hx]

/-- Monomial symmetric polynomials with distinct part multisets are linearly independent.
This is the degenerate case `β = 0` of the main theorem. -/
theorem linearIndependent_msym [IsDomain R] [CharZero R]
    {ι : Type*} [Fintype ι] (a : ι → Exp N)
    (hinj : Function.Injective fun i => parts (a i)) :
    LinearIndependent R (fun i => msym R (a i)) := by
  have h := linearIndependent_msym_mul (R := R) a (fun _ => (0 : Exp N))
    (by
      intro i
      have : (a i).support.card ≤ N := by
        simpa using Finset.card_le_univ (a i).support
      simpa using this)
    (by
      intro i j hij
      simp only [parts, Finsupp.support_zero, Finset.empty_val, Multiset.map_zero,
        add_zero] at hij
      exact hinj hij)
  have hmsym0 : msym R (0 : Exp N) = 1 := by
    unfold msym orbit
    have : (Finset.univ.image (fun e : Equiv.Perm (Fin N) => Finsupp.equivMapDomain e (0 : Exp N)))
        = {(0 : Exp N)} := by
      ext x
      simp [Finsupp.equivMapDomain]
      constructor
      · rintro ⟨e, rfl⟩; ext j; simp
      · rintro rfl; exact ⟨Equiv.refl _, by ext j; simp⟩
    rw [this]
    simp
  simpa [hmsym0] using h

/-! ### The one-row case, unconditionally -/

lemma card_support_single_le (i : Fin N) (x : ℕ) :
    (Finsupp.single i x).support.card ≤ 1 := by
  simpa using Finset.card_le_card (Finsupp.support_single_subset (a := i) (b := x))

/-- **The one-row case of the componentwise splitting theorem, unconditionally.**

For `θ = (n)` the componentwise splittings are `(k) + (n - k)` with `2 * k ≤ n`, and
`m_{(k)}` is the power sum `p_k`.  The products `m_{(k)} * m_{(n-k)}`, indexed by
`0 ≤ k ≤ n / 2`, are linearly independent over any characteristic-zero domain.  Here the
hypothesis of distinct multiset unions is *verified*, not assumed. -/
theorem linearIndependent_row_splittings [IsDomain R] [CharZero R] (n : ℕ) :
    LinearIndependent R (fun k : Fin (n / 2 + 1) =>
      msym R (Finsupp.single (0 : Fin (N + 2)) (k : ℕ)) *
        msym R (Finsupp.single (0 : Fin (N + 2)) (n - (k : ℕ)))) := by
  refine linearIndependent_msym_mul _ _ (fun k => ?_) ?_
  · have h1 := card_support_single_le (0 : Fin (N + 2)) (k : ℕ)
    have h2 := card_support_single_le (0 : Fin (N + 2)) (n - (k : ℕ))
    omega
  · intro k l hkl
    have hk : 2 * (k : ℕ) ≤ n := by have := k.2; omega
    have hl : 2 * (l : ℕ) ≤ n := by have := l.2; omega
    simp only [parts_single] at hkl
    refine Fin.ext ?_
    by_cases hk0 : (k : ℕ) = 0
    · by_cases hl0 : (l : ℕ) = 0
      · omega
      · exfalso
        have hnk : n - (k : ℕ) ≠ 0 := by omega
        have hnl : n - (l : ℕ) ≠ 0 := by omega
        rw [if_pos hk0, if_neg hnk, if_neg hl0, if_neg hnl] at hkl
        have hcard := congrArg Multiset.card hkl
        simp at hcard
    · by_cases hl0 : (l : ℕ) = 0
      · exfalso
        have hnk : n - (k : ℕ) ≠ 0 := by omega
        have hnl : n - (l : ℕ) ≠ 0 := by omega
        rw [if_neg hk0, if_neg hnk, if_pos hl0, if_neg hnl] at hkl
        have hcard := congrArg Multiset.card hkl
        simp at hcard
      · have hnk : n - (k : ℕ) ≠ 0 := by omega
        have hnl : n - (l : ℕ) ≠ 0 := by omega
        rw [if_neg hk0, if_neg hnk, if_neg hl0, if_neg hnl] at hkl
        have h1 : (k : ℕ) ∈ ({(l : ℕ)} : Multiset ℕ) + {n - (l : ℕ)} := by
          rw [← hkl]; simp
        have h2 : (l : ℕ) ∈ ({(k : ℕ)} : Multiset ℕ) + {n - (k : ℕ)} := by
          rw [hkl]; simp
        simp at h1 h2
        omega

/-! ### The boundary: unions can collide -/

/-- Two distinct componentwise splittings of `θ = (5,3)` with the **same** multiset union:
`(3,1) + (2,2) = (5,3) = (3,2) + (2,1)` and `{3,1} ∪ {2,2} = {3,2,2,1} = {3,2} ∪ {2,1}`.

Consequently the hypothesis of `linearIndependent_msym_mul` is a genuine restriction: the
`Qstat`-minimal ("multiset union") layer of the expansion of a product does *not* separate
all componentwise splittings of a partition.  This is precisely the difficulty that the
paper's full theorem has to overcome. -/
theorem union_collision_five_three :
    ∃ a₁ b₁ a₂ b₂ : Exp 2,
      a₁ + b₁ = a₂ + b₂ ∧
      parts a₁ + parts b₁ = parts a₂ + parts b₂ ∧
      a₁ ≠ a₂ ∧ a₁ ≠ b₂ := by
  classical
  set z : Fin 2 := 0 with hz
  set o : Fin 2 := 1 with ho
  have hzo : z ≠ o := by decide
  refine ⟨Finsupp.single z 3 + Finsupp.single o 1, Finsupp.single z 2 + Finsupp.single o 2,
    Finsupp.single z 3 + Finsupp.single o 2, Finsupp.single z 2 + Finsupp.single o 1,
    ?_, ?_, ?_, ?_⟩
  · rw [show (Finsupp.single z 3 + Finsupp.single o 1 + (Finsupp.single z 2 + Finsupp.single o 2))
        = (Finsupp.single z 3 + Finsupp.single z 2) + (Finsupp.single o 1 + Finsupp.single o 2)
        from by abel,
      show (Finsupp.single z 3 + Finsupp.single o 2 + (Finsupp.single z 2 + Finsupp.single o 1))
        = (Finsupp.single z 3 + Finsupp.single z 2) + (Finsupp.single o 2 + Finsupp.single o 1)
        from by abel]
    rw [add_comm (Finsupp.single o 2) (Finsupp.single o 1)]
  · have hd : ∀ x y : ℕ, x ≠ 0 → y ≠ 0 →
        parts (Finsupp.single z x + Finsupp.single o y) = {x, y} := by
      intro x y hx hy
      have hdisj : Disjoint (Finsupp.single z x).support (Finsupp.single o y).support := by
        rw [Finsupp.support_single_ne_zero z hx, Finsupp.support_single_ne_zero o hy]
        simpa using hzo
      rw [parts_add_of_disjoint hdisj, parts_single, parts_single, if_neg hx, if_neg hy]
      rfl
    rw [hd 3 1 (by norm_num) (by norm_num), hd 2 2 (by norm_num) (by norm_num),
      hd 3 2 (by norm_num) (by norm_num), hd 2 1 (by norm_num) (by norm_num)]
    decide
  · intro h
    have := congrArg (fun d : Exp 2 => d o) h
    simp [hz, ho] at this
  · intro h
    have := congrArg (fun d : Exp 2 => d z) h
    simp [hz, ho] at this

/-! ### The product determines the multiset union -/

/-- The `Qstat`-minimal layer of a product of two monomial symmetric functions recovers the
multiset union of the two exponent vectors.  Hence the product `m_α m_β` **determines**
`parts α + parts β`, over any characteristic-zero ring.  (No domain hypothesis needed.) -/
theorem parts_union_eq_of_msym_mul_eq [CharZero R] {a b a' b' : Exp N}
    (hcard : a.support.card + b.support.card ≤ N)
    (hcard' : a'.support.card + b'.support.card ≤ N)
    (h : msym R a * msym R b = msym R a' * msym R b') :
    parts a + parts b = parts a' + parts b' := by
  obtain ⟨e, he⟩ := exists_disjoint_placement a b hcard
  obtain ⟨e', he'⟩ := exists_disjoint_placement a' b' hcard'
  set w : Exp N := a + Finsupp.equivMapDomain e b with hw
  set w' : Exp N := a' + Finsupp.equivMapDomain e' b' with hw'
  have hQw : Qstat w = Qstat a + Qstat b := by
    rw [hw, Qstat_add, (dotp_eq_zero_iff _ _).2 he, Qstat_equivMapDomain]; omega
  have hQw' : Qstat w' = Qstat a' + Qstat b' := by
    rw [hw', Qstat_add, (dotp_eq_zero_iff _ _).2 he', Qstat_equivMapDomain]; omega
  have hpw : parts w = parts a + parts b := by
    rw [hw, parts_add_of_disjoint he, parts_equivMapDomain]
  -- the chosen monomial of one product occurs in the other
  have hne : MvPolynomial.coeff w (msym R a' * msym R b') ≠ 0 := by
    rw [← h]
    exact coeff_add_mem_orbit_ne_zero (self_mem_orbit _) (equivMapDomain_mem_orbit e b)
  have hne' : MvPolynomial.coeff w' (msym R a * msym R b) ≠ 0 := by
    rw [h]
    exact coeff_add_mem_orbit_ne_zero (self_mem_orbit _) (equivMapDomain_mem_orbit e' b')
  obtain ⟨u, hu, v, hv, huv⟩ := exists_split_of_coeff_ne_zero hne
  obtain ⟨u', hu', v', hv', huv'⟩ := exists_split_of_coeff_ne_zero hne'
  have hQ1 : Qstat w = Qstat a' + Qstat b' + 2 * dotp u v := by
    rw [← huv, Qstat_add, Qstat_of_mem_orbit hu, Qstat_of_mem_orbit hv]
  have hQ2 : Qstat w' = Qstat a + Qstat b + 2 * dotp u' v' := by
    rw [← huv', Qstat_add, Qstat_of_mem_orbit hu', Qstat_of_mem_orbit hv']
  have hdot : dotp u v = 0 := by omega
  have hdisj : Disjoint u.support v.support := (dotp_eq_zero_iff u v).1 hdot
  rw [← hpw, ← huv, parts_add_of_disjoint hdisj, parts_of_mem_orbit hu, parts_of_mem_orbit hv]

/-! ### Sharpness: enough variables are needed -/

lemma orbit_fin_one (d : Exp 1) : orbit d = {d} := by
  ext w
  simp only [orbit, Finset.mem_image, Finset.mem_univ, true_and, Finset.mem_singleton]
  constructor
  · rintro ⟨e, rfl⟩
    have : e = Equiv.refl _ := Subsingleton.elim _ _
    subst this
    simp
  · rintro rfl
    exact ⟨Equiv.refl _, by simp⟩

lemma msym_fin_one (d : Exp 1) : msym R d = MvPolynomial.monomial d (1 : R) := by
  rw [msym, orbit_fin_one, Finset.sum_singleton]

/-- **The hypothesis that the variables suffice cannot be dropped.**

In a single variable, the two pairs `((1), (1))` and `((2), ∅)` have *different* multiset
unions `{1,1} ≠ {2}`, yet the corresponding products of monomial symmetric polynomials
coincide (both equal `x₀²`), so the family is linearly dependent.  Thus the counting
hypothesis `hcard` in `linearIndependent_msym_mul` is necessary: the theorem is a statement
about symmetric *functions*, i.e. about having enough variables. -/
theorem not_linearIndependent_of_too_few_variables :
    parts (Finsupp.single (0 : Fin 1) 1) + parts (Finsupp.single (0 : Fin 1) 1)
        ≠ parts (Finsupp.single (0 : Fin 1) 2) + parts (0 : Exp 1) ∧
      ¬ LinearIndependent ℚ
        ![msym ℚ (Finsupp.single (0 : Fin 1) 1) * msym ℚ (Finsupp.single (0 : Fin 1) 1),
          msym ℚ (Finsupp.single (0 : Fin 1) 2) * msym ℚ (0 : Exp 1)] := by
  have h0 : parts (0 : Exp 1) = 0 := by simp [parts]
  constructor
  · simp only [parts_single, h0, if_neg (show ¬(1 : ℕ) = 0 by norm_num),
      if_neg (show ¬(2 : ℕ) = 0 by norm_num), add_zero]
    decide
  · intro hli
    have hinj := hli.injective
    have hprod : msym ℚ (Finsupp.single (0 : Fin 1) 1) * msym ℚ (Finsupp.single (0 : Fin 1) 1)
        = msym ℚ (Finsupp.single (0 : Fin 1) 2) * msym ℚ (0 : Exp 1) := by
      rw [msym_fin_one, msym_fin_one, msym_fin_one, MvPolynomial.monomial_mul,
        MvPolynomial.monomial_mul]
      congr 1
      simp [← Finsupp.single_add]
    have := hinj (a₁ := 0) (a₂ := 1) (by simpa using hprod)
    simp at this

/-! ### Beyond the criterion: the smallest collision class -/

lemma msym_zero : msym R (0 : Exp N) = 1 := by
  unfold msym orbit
  have horb : (Finset.univ.image
      (fun e : Equiv.Perm (Fin N) => Finsupp.equivMapDomain e (0 : Exp N)))
      = {(0 : Exp N)} := by
    ext x
    simp only [Finset.mem_image, Finset.mem_univ, true_and, Finset.mem_singleton]
    constructor
    · rintro ⟨e, rfl⟩
      ext j
      simp
    · rintro rfl
      exact ⟨Equiv.refl _, by ext j; simp⟩
  rw [horb]
  simp

/-- **The two-element collision classes are independent.**

Let `a, b` be nonzero.  The unordered pairs `{∅, (a,b)}` and `{(a), (b)}` have the *same*
multiset union `{a, b}`, so `linearIndependent_msym_mul` does not apply; nevertheless the
products `m_{(a,b)} · 1` and `m_{(a)} · m_{(b)}` are linearly independent.  The separating
monomial is `x₀^{a+b}`, which lies in a *higher* `Qstat` layer: for `a ≠ b` one has
`m_{(a)} m_{(b)} = m_{(a,b)} + m_{(a+b)}`. -/
theorem linearIndependent_collision_pair_two [IsDomain R] [CharZero R] {a b : ℕ}
    (ha : a ≠ 0) (hb : b ≠ 0) :
    LinearIndependent R
      ![msym R (Finsupp.single (0 : Fin (N + 2)) a + Finsupp.single 1 b)
          * msym R (0 : Exp (N + 2)),
        msym R (Finsupp.single (0 : Fin (N + 2)) a)
          * msym R (Finsupp.single (0 : Fin (N + 2)) b)] := by
  classical
  have hdisj : Disjoint (Finsupp.single (0 : Fin (N + 2)) a).support
      (Finsupp.single (1 : Fin (N + 2)) b).support := by
    rw [Finsupp.support_single_ne_zero _ ha, Finsupp.support_single_ne_zero _ hb]
    simp
  have hpartsA :
      parts (Finsupp.single (0 : Fin (N + 2)) a + Finsupp.single 1 b) = {a, b} := by
    rw [parts_add_of_disjoint hdisj, parts_single, parts_single, if_neg ha, if_neg hb]
    rfl
  have hBB : (Finsupp.single (0 : Fin (N + 2)) a) + (Finsupp.single (0 : Fin (N + 2)) b)
      = Finsupp.single (0 : Fin (N + 2)) (a + b) := (Finsupp.single_add _ _ _).symm
  have hpartsBB :
      parts ((Finsupp.single (0 : Fin (N + 2)) a) + (Finsupp.single (0 : Fin (N + 2)) b))
        = {a + b} := by
    rw [hBB, parts_single, if_neg (by omega)]
  rw [LinearIndependent.pair_iff]
  intro s t hst
  rw [msym_zero, mul_one] at hst
  have h1 : MvPolynomial.coeff
      ((Finsupp.single (0 : Fin (N + 2)) a) + (Finsupp.single (0 : Fin (N + 2)) b))
      (msym R (Finsupp.single (0 : Fin (N + 2)) a + Finsupp.single 1 b)) = 0 := by
    rw [coeff_msym, if_neg]
    intro hmem
    have hp := parts_of_mem_orbit hmem
    rw [hpartsBB, hpartsA] at hp
    have hcard := congrArg Multiset.card hp
    simp at hcard
  have h2 : MvPolynomial.coeff
      ((Finsupp.single (0 : Fin (N + 2)) a) + (Finsupp.single (0 : Fin (N + 2)) b))
      (msym R (Finsupp.single (0 : Fin (N + 2)) a)
        * msym R (Finsupp.single (0 : Fin (N + 2)) b)) ≠ 0 :=
    coeff_add_mem_orbit_ne_zero (self_mem_orbit _) (self_mem_orbit _)
  have hcoeff := congrArg (MvPolynomial.coeff
    ((Finsupp.single (0 : Fin (N + 2)) a) + (Finsupp.single (0 : Fin (N + 2)) b))) hst
  simp only [MvPolynomial.coeff_add, MvPolynomial.coeff_smul, smul_eq_mul,
    MvPolynomial.coeff_zero, h1, mul_zero, zero_add] at hcoeff
  have ht : t = 0 := by
    rcases mul_eq_zero.1 hcoeff with h | h
    · exact h
    · exact absurd h h2
  subst ht
  refine ⟨?_, rfl⟩
  have hcoeffA := congrArg (MvPolynomial.coeff
    (Finsupp.single (0 : Fin (N + 2)) a + Finsupp.single 1 b)) hst
  simp only [MvPolynomial.coeff_smul, smul_eq_mul, MvPolynomial.coeff_zero, zero_smul,
    add_zero] at hcoeffA
  rw [coeff_msym, if_pos (self_mem_orbit _)] at hcoeffA
  simpa using hcoeffA

/-- **The distinct-union criterion is sufficient but not necessary.**

The two pairs `{∅, (v,v)}` and `{(v), (v)}` have the *same* multiset union `{v, v}`, so
`linearIndependent_msym_mul` does not apply; nevertheless the two products
`m_{(v,v)} · 1` and `m_{(v)} · m_{(v)}` are linearly independent.  The separating monomial is
`x₀^{2v}`, which lies in a *higher* `Qstat` layer: `m_{(v)} m_{(v)} = 2 m_{(v,v)} + m_{(2v)}`.

For `v = 2` this is exactly the collision produced by Kleber's `2 × 2` rectangle, where
`∅` and `(2,2)`, resp. `(2)` and `(2)`, are complementary. -/
theorem linearIndependent_collision_pair [IsDomain R] [CharZero R] {v : ℕ} (hv : v ≠ 0) :
    LinearIndependent R
      ![msym R (Finsupp.single (0 : Fin (N + 2)) v + Finsupp.single 1 v)
          * msym R (0 : Exp (N + 2)),
        msym R (Finsupp.single (0 : Fin (N + 2)) v)
          * msym R (Finsupp.single (0 : Fin (N + 2)) v)] :=
  linearIndependent_collision_pair_two hv hv

end KleberSplit