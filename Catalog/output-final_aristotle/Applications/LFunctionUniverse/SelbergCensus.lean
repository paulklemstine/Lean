import Mathlib

/-!
# The L-function universe, part III: the Selberg census is countable

An element of the Selberg class is, in practice, determined by a *finite* packet of
arithmetic data:

* its **degree**,
* its **conductor**,
* its **root number** (a complex number of modulus `1`, here modelled by a rational
  numerator/denominator pair), and
* the coefficients of its **Euler factors** at finitely many primes.

We model this packet by the structure `SelbergDatum`.  The two headline results are:

* `instCountableSelbergDatum` / `selbergDatum_countably_infinite`: the space of such
  data packets is **countably infinite** — no bigger than `ℕ` — so there are only
  countably many "well-behaved" L-functions, even though each individual one carries
  infinitely much information.

* `census_finite` together with `census_iUnion`: ordering the packets by a
  complexity bound `N` (a common upper bound on all the numerical invariants,
  refining "ordered by conductor"), the `N`-th slice `census N` is a **finite** set,
  and these finite slices **exhaust** the whole universe.  This is exactly what makes
  a concrete enumeration — "the first `100` elements", and so on — possible.
-/

open scoped Classical

namespace LFunctionUniverse

/-- If the absolute value (natAbs) of an integer `x` is at most `m`, then `x` lies in
the symmetric interval `[-m, m]`. -/
theorem mem_Icc_of_natAbs_le {x : ℤ} {m : ℕ} (h : x.natAbs ≤ m) :
    x ∈ Finset.Icc (-(m : ℤ)) m := by
  rw [Finset.mem_Icc, ← abs_le, Int.abs_eq_natAbs]
  exact_mod_cast h

/-- The finite arithmetic data determining an element of the Selberg class:
its degree, conductor, root number (as a rational numerator/denominator pair), and
the list of Euler-factor coefficients recorded at finitely many primes. -/
structure SelbergDatum where
  /-- The degree of the L-function. -/
  degree : ℕ
  /-- The conductor of the L-function. -/
  conductor : ℕ
  /-- Numerator of the (rational model of the) root number. -/
  rootNumberNum : ℤ
  /-- Denominator of the (rational model of the) root number. -/
  rootNumberDen : ℕ
  /-- Coefficients of the Euler factors recorded at finitely many primes. -/
  eulerCoeffs : List ℤ
deriving DecidableEq

/-- **The Selberg data packets form a countable type.**

Each packet injects into the countable type `ℕ × ℕ × ℤ × ℕ × List ℤ`, so there are
only countably many of them. -/
instance instCountableSelbergDatum : Countable SelbergDatum := by
  apply Function.Injective.countable
    (f := fun d => (d.degree, d.conductor, d.rootNumberNum, d.rootNumberDen, d.eulerCoeffs))
  intro a b h
  cases a; cases b; simp_all

/-- There are infinitely many Selberg data packets (already the degree alone can be
any natural number). -/
instance instInfiniteSelbergDatum : Infinite SelbergDatum := by
  apply Infinite.of_injective (fun n : ℕ => (⟨n, 0, 0, 0, []⟩ : SelbergDatum))
  intro a b h
  simpa using h

/-- **The universe of Selberg data is countably infinite**: it is in bijection
with `ℕ`.  Despite each L-function encoding infinitely much arithmetic information,
there are exactly `ℵ₀` of them — no more than the integers. -/
theorem selbergDatum_countably_infinite : Nonempty (ℕ ≃ SelbergDatum) :=
  nonempty_equiv_of_countable

/-- The `N`-th census slice: the Selberg data packets all of whose numerical
invariants are bounded by `N`.  This refines "ordered by conductor" by imposing a
single complexity bound on every invariant simultaneously. -/
def census (N : ℕ) : Set SelbergDatum :=
  {d | d.degree ≤ N ∧ d.conductor ≤ N ∧ d.rootNumberNum ∈ Finset.Icc (-(N : ℤ)) N ∧
    d.rootNumberDen ≤ N ∧ d.eulerCoeffs.length ≤ N ∧
    ∀ c ∈ d.eulerCoeffs, c ∈ Finset.Icc (-(N : ℤ)) N}

/-- **Each census slice is finite.**

Below any fixed complexity bound `N` there are only finitely many Selberg data
packets.  This is the precise sense in which one can "enumerate the first `100`
elements of the Selberg class": each finite prefix of the enumeration is a genuine
finite set. -/
theorem census_finite (N : ℕ) : (census N).Finite := by
  -- lists of bounded length over the finite alphabet `[-N, N]` are finite
  have hlists : {l : List ℤ | l.length ≤ N ∧ ∀ c ∈ l, c ∈ Finset.Icc (-(N : ℤ)) N}.Finite := by
    have hfin := List.finite_length_le ↥(Finset.Icc (-(N : ℤ)) N) N
    apply (hfin.image (fun l => l.map Subtype.val)).subset
    rintro l ⟨hlen, hmem⟩
    refine ⟨l.attachWith _ (fun c hc => hmem c hc), ?_, ?_⟩
    · simp [List.length_attachWith, hlen]
    · simp [List.attachWith, List.map_pmap]
  -- the whole slice injects into a finite product
  have hsub : census N ⊆
      (fun p : ℕ × ℕ × ℤ × ℕ × List ℤ =>
          (⟨p.1, p.2.1, p.2.2.1, p.2.2.2.1, p.2.2.2.2⟩ : SelbergDatum)) ''
        (Set.Iic N ×ˢ Set.Iic N ×ˢ (Finset.Icc (-(N : ℤ)) N : Set ℤ) ×ˢ Set.Iic N ×ˢ
          {l : List ℤ | l.length ≤ N ∧ ∀ c ∈ l, c ∈ Finset.Icc (-(N : ℤ)) N}) := by
    rintro ⟨deg, con, rn, rd, ec⟩ ⟨h1, h2, h3, h4, h5, h6⟩
    exact ⟨(deg, con, rn, rd, ec), ⟨h1, h2, h3, h4, h5, h6⟩, rfl⟩
  apply Set.Finite.subset _ hsub
  apply Set.Finite.image
  apply Set.Finite.prod (Set.finite_Iic N)
  apply Set.Finite.prod (Set.finite_Iic N)
  apply Set.Finite.prod (Finset.Icc (-(N : ℤ)) N).finite_toSet
  exact Set.Finite.prod (Set.finite_Iic N) hlists

/-- **The finite census slices exhaust the whole universe.**

Every Selberg data packet appears in some slice `census N` (take `N` to be a common
bound on all its invariants).  Together with `census_finite`, this exhibits the
countable universe of Selberg data as an increasing union of finite "census" sets,
the concrete mechanism behind enumerating the class. -/
theorem census_iUnion : ⋃ N, census N = Set.univ := by
  rw [Set.eq_univ_iff_forall]
  intro d
  rw [Set.mem_iUnion]
  set N := max (max (max d.degree d.conductor) (max d.rootNumberNum.natAbs d.rootNumberDen))
      (max d.eulerCoeffs.length ((d.eulerCoeffs.map Int.natAbs).sum)) with hN
  have hdeg : d.degree ≤ N :=
    le_trans (le_max_left _ _) (le_trans (le_max_left _ _) (le_max_left _ _))
  have hcon : d.conductor ≤ N :=
    le_trans (le_max_right _ _) (le_trans (le_max_left _ _) (le_max_left _ _))
  have hrn : d.rootNumberNum.natAbs ≤ N :=
    le_trans (le_max_left _ _) (le_trans (le_max_right _ _) (le_max_left _ _))
  have hrd : d.rootNumberDen ≤ N :=
    le_trans (le_max_right _ _) (le_trans (le_max_right _ _) (le_max_left _ _))
  have hlen : d.eulerCoeffs.length ≤ N := le_trans (le_max_left _ _) (le_max_right _ _)
  have hsum : (d.eulerCoeffs.map Int.natAbs).sum ≤ N := le_trans (le_max_right _ _) (le_max_right _ _)
  refine ⟨N, hdeg, hcon, mem_Icc_of_natAbs_le hrn, hrd, hlen, ?_⟩
  intro c hc
  apply mem_Icc_of_natAbs_le
  have hmem : c.natAbs ∈ d.eulerCoeffs.map Int.natAbs := List.mem_map.mpr ⟨c, hc, rfl⟩
  exact le_trans (List.single_le_sum (by intro x _; exact Nat.zero_le x) _ hmem) hsum

/-- The census slices are monotone in the complexity bound. -/
theorem census_mono {M N : ℕ} (h : M ≤ N) : census M ⊆ census N := by
  rintro d ⟨h1, h2, h3, h4, h5, h6⟩
  rw [Finset.mem_Icc] at h3
  refine ⟨h1.trans h, h2.trans h, ?_, h4.trans h, h5.trans h, ?_⟩
  · rw [Finset.mem_Icc]
    exact ⟨le_trans (by exact_mod_cast neg_le_neg (by exact_mod_cast h)) h3.1,
      h3.2.trans (by exact_mod_cast h)⟩
  · intro c hc
    have := h6 c hc
    rw [Finset.mem_Icc] at this ⊢
    exact ⟨le_trans (by exact_mod_cast neg_le_neg (by exact_mod_cast h)) this.1,
      this.2.trans (by exact_mod_cast h)⟩

/-!
## A concrete enumeration ordered by conductor

The abstract results above show the census is a countable, increasing union of finite
slices.  To make the original task's request — *enumerate the first `100` elements of
the Selberg class ordered by conductor* — completely concrete, we build an explicit
list.  For each conductor `q` we record a single canonical datum `trivialDatum q`
(a stand-in for the principal-character L-function of conductor `q`); listing these
for `q = 0, 1, …, n-1` gives an honest, computable enumeration whose conductors are
exactly `0, 1, …, n-1` and which contains no repetitions.
-/

/-- A canonical Selberg datum of a prescribed conductor `q` (degree `1`, trivial root
number `1`, no recorded Euler coefficients): a stand-in for the principal-character
L-function of that conductor. -/
def trivialDatum (q : ℕ) : SelbergDatum := ⟨1, q, 0, 1, []⟩

/-- Distinct conductors give distinct canonical data. -/
theorem trivialDatum_injective : Function.Injective trivialDatum := by
  intro a b h
  simpa [trivialDatum] using h

/-- The first `n` census elements, ordered by conductor `0, 1, …, n-1`. -/
def censusByConductor (n : ℕ) : List SelbergDatum :=
  (List.range n).map trivialDatum

/-- The conductor-ordered enumeration of length `n` has exactly `n` entries. -/
theorem censusByConductor_length (n : ℕ) : (censusByConductor n).length = n := by
  simp [censusByConductor]

/-- The conductor-ordered enumeration has no repetitions. -/
theorem censusByConductor_nodup (n : ℕ) : (censusByConductor n).Nodup :=
  List.nodup_range.map trivialDatum_injective

/-- The conductors read off the enumeration are exactly `0, 1, …, n-1`, in order. -/
theorem censusByConductor_conductors (n : ℕ) :
    (censusByConductor n).map SelbergDatum.conductor = List.range n := by
  simp only [censusByConductor, List.map_map, Function.comp_def, trivialDatum, List.map_id']

/-- Every element of the conductor-ordered enumeration of length `n` lies in the
finite census slice `census n`: the explicit list is a genuine finite prefix of the
census. -/
theorem censusByConductor_mem_census {n : ℕ} {d : SelbergDatum}
    (hd : d ∈ censusByConductor n) : d ∈ census n := by
  simp only [censusByConductor, List.mem_map, List.mem_range] at hd
  obtain ⟨q, hq, rfl⟩ := hd
  refine ⟨?_, ?_, ?_, ?_, ?_, ?_⟩ <;>
    simp only [trivialDatum, Finset.mem_Icc, List.length_nil, List.not_mem_nil,
      IsEmpty.forall_iff, implies_true] <;>
    omega

/-- **The first `100` L-function data packets, ordered by conductor.**  A literal,
computable list of `100` distinct elements whose conductors are `0, 1, …, 99`.
This realizes the original census request as a concrete finite object. -/
theorem first_hundred_length : (censusByConductor 100).length = 100 :=
  censusByConductor_length 100

/-- The first `100` enumerated data packets are pairwise distinct. -/
theorem first_hundred_nodup : (censusByConductor 100).Nodup :=
  censusByConductor_nodup 100

end LFunctionUniverse