import Catalog.Cryptography.SurrealZeroDimensional

/-!
# The surreal line is nowhere locally compact

The archimedean monads of `Catalog.Cryptography.SurrealZeroDimensional` are clopen, hence
one might hope that some of them are compact — that would make `Surreal` a locally compact,
zero-dimensional topological group, i.e. the kind of space on which Haar measure and
Pontryagin duality live.  We show that this hope fails as badly as possible:

* `Surreal.not_isCompact_of_mem_nhds` — **no neighbourhood of any surreal is compact**.
  The obstruction is the *upper half of a monad*: the set of surreals above `c` and
  infinitesimally close to `c` at scale `d` has no least upper bound at all, whereas a
  compact set in a linear order must contain the least upper bound of each of its
  (closure-completed) nonempty subsets.
* `Surreal.not_locallyCompactSpace` — the surreal line is not locally compact.

This is the sharpest possible complement to zero-dimensionality: `Surreal` is a
zero-dimensional Hausdorff topological group in which *no* point has a compact
neighbourhood.
-/

open SetTheory PGame Filter Set Topology

namespace Surreal

/-- The upper half of the archimedean monad of `c` at scale `d`. -/
def upperMonad (c d : Surreal.{u}) : Set Surreal.{u} := monad c d ∩ Ioi c

theorem upperMonad_nonempty {c d : Surreal.{u}} (hd : 0 < d) : (upperMonad c d).Nonempty := by
  obtain ⟨e, he0, he⟩ := exists_pos_lt_mul_powHalf hd
  refine ⟨c + e, ⟨fun n => ?_, fun n => ?_⟩, by simpa using he0⟩
  · have : c + e - c = e := by ring
    rw [this]; exact he n
  · have : c - (c + e) = -e := by ring
    rw [this]
    have := mul_powHalf_pos hd n
    linarith

theorem upperMonad_subset_Ioo {c d : Surreal.{u}} : upperMonad c d ⊆ Ioo c (c + d) := by
  rintro z ⟨hz, hzc⟩
  exact ⟨hzc, (monad_subset_Ioo hz).2⟩

/-- The upper half of a monad has **no least upper bound**: doubling the distance to `c`
stays inside the monad, while any element outside the monad is beaten by
`c + d * powHalf (n+1)`. -/
theorem not_isLUB_upperMonad {c d x : Surreal.{u}} (hd : 0 < d) :
    ¬ IsLUB (upperMonad c d) x := by
  rintro ⟨hub, hleast⟩
  obtain ⟨w, hw⟩ := upperMonad_nonempty (c := c) (d := d) hd
  have hcx : c < x := lt_of_lt_of_le hw.2 (hub hw)
  by_cases hx : x ∈ monad c d
  · -- `x` is itself infinitesimally close to `c`; then so is `c + 2·(x - c) > x`.
    refine absurd (hub (a := c + (x - c) + (x - c)) ⟨⟨fun n => ?_, fun n => ?_⟩, by
      simp only [mem_Ioi]; linarith⟩) (by simp; linarith)
    · have h1 : x - c < d * powHalf (n + 1) := hx.1 (n + 1)
      have h2 := double_mul_powHalf_succ (d := d) n
      have hrw : c + (x - c) + (x - c) - c = (x - c) + (x - c) := by ring
      rw [hrw]; linarith
    · have hrw : c - (c + (x - c) + (x - c)) = -((x - c) + (x - c)) := by ring
      rw [hrw]
      have := mul_powHalf_pos hd n
      linarith
  · -- `x` is far from `c`; then a strictly smaller upper bound exists.
    have hfar : ∃ n : ℕ, d * powHalf n ≤ x - c := by
      by_contra hcon
      push_neg at hcon
      exact hx ⟨fun n => hcon n, fun n => by
        have := mul_powHalf_pos hd n; linarith⟩
    obtain ⟨n, hn⟩ := hfar
    have hsmall : c + d * powHalf (n + 1) < x := by
      have := mul_powHalf_succ_lt hd n
      linarith
    refine absurd (hleast (a := c + d * powHalf (n + 1)) ?_) (not_le.2 hsmall)
    rintro z ⟨hz, -⟩
    have := hz.1 (n + 1)
    linarith

/-- **No neighbourhood of a surreal number is compact.** -/
theorem not_isCompact_of_mem_nhds (c : Surreal.{u}) {K : Set Surreal.{u}} (hK : K ∈ 𝓝 c) :
    ¬ IsCompact K := by
  intro hcomp
  obtain ⟨l, r, ⟨hl, hr⟩, hsub⟩ := mem_nhds_iff_exists_Ioo_subset.1 hK
  set d : Surreal.{u} := r - c with hdef
  have hd : 0 < d := by simp [hdef]; linarith
  have hSK : upperMonad c d ⊆ K := by
    intro z hz
    have hz' := upperMonad_subset_Ioo hz
    refine hsub ⟨lt_trans hl hz'.1, ?_⟩
    have : c + d = r := by simp [hdef]
    rw [this] at hz'
    exact hz'.2
  -- the closure of the upper monad is a compact subset of `K` with the same suprema
  have hKclosed : IsClosed K := hcomp.isClosed
  have hclsub : closure (upperMonad c d) ⊆ K := hKclosed.closure_subset_iff.2 hSK
  have hclcomp : IsCompact (closure (upperMonad c d)) :=
    hcomp.of_isClosed_subset isClosed_closure hclsub
  obtain ⟨x, -, hlub⟩ :=
    hclcomp.exists_isLUB ((upperMonad_nonempty hd).mono subset_closure)
  -- an LUB of the closure is an LUB of the set itself
  refine not_isLUB_upperMonad (c := c) (d := d) (x := x) hd ⟨?_, ?_⟩
  · exact fun z hz => hlub.1 (subset_closure hz)
  · intro y hy
    refine hlub.2 ?_
    have : closure (upperMonad c d) ⊆ Iic y := by
      refine closure_minimal hy isClosed_Iic
    exact this

/-- **The surreal line is not locally compact.** -/
theorem not_locallyCompactSpace : ¬ LocallyCompactSpace Surreal.{u} := by
  intro hloc
  obtain ⟨K, hKmem, -, hKcomp⟩ := hloc.local_compact_nhds (0 : Surreal.{u}) univ univ_mem
  exact not_isCompact_of_mem_nhds 0 hKmem hKcomp

end Surreal