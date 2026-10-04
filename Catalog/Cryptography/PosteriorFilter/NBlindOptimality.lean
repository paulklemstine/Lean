import Cryptography.PosteriorFilter.KeepRate

/-!
# Paper 131, cycle 2 — reading `N` never helps, and where the sham law stops

Two refinements of the keep-rate law, produced by the second pass of the research loop.

## 1. Non-uniform priors: `N`-blind filters are optimal

`KeepRate.lean` assumes both factor residues are uniform.  Here the target residue `a`
may follow an *arbitrary* prior weight `μ`, and only the cofactor residue `b` is uniform
(the equidistribution input).  Then a filter's success weight is
`∑_c ∑_{a ∈ K c} μ a` (`hitWeight_eq`), and for every keep-policy there is an `N`-blind
policy — one that ignores the public residue altogether — with the same keep sizes and at
least the same success weight (`nBlind_optimal`).  The prior can be exploited, but the
public number adds nothing on top of it.

## 2. The ordered target is essential

Trial division up to `√N` must find the *smaller* factor.  If one (incorrectly) scores a
filter on the unordered event "some factor lies in a kept class", the sham law fails: the
success count becomes `∑_c |K c ∪ c · (K c)⁻¹|` (`symHitCount_eq`), which does depend on
which classes are kept.  A keep-set that covers every mirror pair `{x, c x⁻¹}` catches
every factor pair (`symHit_of_cover`), and on `Multiplicative (ZMod 3)` two keep-policies
of the same size give different unordered scores (`symHit_real_ne_sham`).  This is the
exact boundary of the real-equals-sham theorem, and one more way a cost-accounting error
could manufacture a spurious speedup.
-/

namespace PosteriorFilter

open Finset

variable {G : Type*} [Group G] [Fintype G] [DecidableEq G]

section Prior

/-- Success weight of the keep-policy `K` when the target residue has prior weight `μ` and
the cofactor residue is uniform. -/
def hitWeight (μ : G → ℝ) (K : G → Finset G) : ℝ :=
  ∑ w : G × G, if w.1 ∈ K (w.1 * w.2) then μ w.1 else 0

/-- **Weighted keep law.**  The success weight is the prior mass of the kept classes,
summed over public residues. -/
theorem hitWeight_eq (μ : G → ℝ) (K : G → Finset G) :
    hitWeight μ K = ∑ c : G, ∑ a ∈ K c, μ a := by
  unfold hitWeight
  rw [flat_transport (fun a c => if a ∈ K c then μ a else 0)]
  refine Finset.sum_congr rfl (fun c _ => ?_)
  rw [← Finset.sum_filter]
  congr 1
  ext a; simp

/-- With a uniform prior the weighted law reduces to the keep-rate law. -/
theorem hitWeight_const (K : G → Finset G) :
    hitWeight (fun _ => (1 : ℝ)) K = hitCount K := by
  rw [hitWeight_eq, hitCount_eq_sum_card]
  push_cast
  simp

/-- **`N`-blind optimality.**  For every keep-policy `K` there is a public residue `c₀`
such that the `N`-blind policy "always keep `K c₀`" has at least the same success weight.
If all keep-sets of `K` have the same size, the blind policy has that size too: reading the
public number never beats the best filter that ignores it. -/
theorem nBlind_optimal (μ : G → ℝ) (K : G → Finset G) :
    ∃ c₀ : G, hitWeight μ K ≤ hitWeight μ (fun _ => K c₀) := by
  obtain ⟨c₀, -, hc₀⟩ := Finset.exists_max_image (univ : Finset G)
    (fun c => ∑ a ∈ K c, μ a) univ_nonempty
  refine ⟨c₀, ?_⟩
  rw [hitWeight_eq, hitWeight_eq]
  exact Finset.sum_le_sum (fun c hc => hc₀ c hc)

/-- The best success weight with keep size `k` is attained by an `N`-blind policy: for any
policy whose keep-sets all have size `k`, some fixed `k`-set does at least as well. -/
theorem nBlind_optimal_of_size (μ : G → ℝ) (K : G → Finset G) (k : ℕ)
    (hk : ∀ c, (K c).card = k) :
    ∃ T : Finset G, T.card = k ∧ hitWeight μ K ≤ hitWeight μ (fun _ => T) := by
  obtain ⟨c₀, h⟩ := nBlind_optimal μ K
  exact ⟨K c₀, hk c₀, h⟩

end Prior

section Unordered

/-- The mirror of a keep-set at the public residue `c`: the cofactor classes `c x⁻¹`. -/
def mirror (c : G) (T : Finset G) : Finset G := T.image (fun x => c * x⁻¹)

/-- Number of factor pairs in which *some* factor lies in a kept class. -/
def symHitCount (K : G → Finset G) : ℕ :=
  (univ.filter (fun w : G × G => w.1 ∈ K (w.1 * w.2) ∨ w.2 ∈ K (w.1 * w.2))).card

omit [Fintype G] in
lemma mem_mirror_iff (c a : G) (T : Finset G) : a ∈ mirror c T ↔ a⁻¹ * c ∈ T := by
  unfold mirror
  constructor
  · rintro h
    obtain ⟨x, hx, rfl⟩ := mem_image.mp h
    simpa [mul_assoc] using hx
  · intro h
    exact mem_image.mpr ⟨a⁻¹ * c, h, by group⟩

/-- **The unordered score.**  Counting a success whenever either factor is kept gives
`∑_c |K c ∪ mirror c (K c)|`, which depends on the shape of the keep-sets. -/
theorem symHitCount_eq (K : G → Finset G) :
    symHitCount K = ∑ c : G, (K c ∪ mirror c (K c)).card := by
  unfold symHitCount
  have h2 : ∀ w : G × G, w.2 = w.1⁻¹ * (w.1 * w.2) := fun w => by group
  rw [Finset.card_filter]
  rw [Finset.sum_congr rfl (fun w _ => by rw [h2 w])]
  rw [show (∑ w : G × G, if w.1 ∈ K (w.1 * (w.1⁻¹ * (w.1 * w.2))) ∨
      w.1⁻¹ * (w.1 * w.2) ∈ K (w.1 * (w.1⁻¹ * (w.1 * w.2))) then 1 else 0) =
      ∑ w : G × G, (if w.1 ∈ K (w.1 * w.2) ∨ w.1⁻¹ * (w.1 * w.2) ∈ K (w.1 * w.2)
        then 1 else 0) by
    refine Finset.sum_congr rfl (fun w _ => ?_)
    rw [show w.1 * (w.1⁻¹ * (w.1 * w.2)) = w.1 * w.2 by group]]
  rw [flat_transport (fun a c => if a ∈ K c ∨ a⁻¹ * c ∈ K c then 1 else 0)]
  refine Finset.sum_congr rfl (fun c _ => ?_)
  rw [← Finset.card_filter]
  congr 1
  ext a
  simp [mem_mirror_iff]

/-- The unordered score is always at least the ordered one. -/
theorem hitCount_le_symHitCount (K : G → Finset G) : hitCount K ≤ symHitCount K := by
  rw [hitCount_eq_sum_card, symHitCount_eq]
  exact Finset.sum_le_sum (fun c _ => Finset.card_le_card Finset.subset_union_left)

/-- A keep-set closed under the mirror scores no better on the unordered event than on the
ordered one. -/
theorem symHit_of_closed (K : G → Finset G) (hK : ∀ c, mirror c (K c) ⊆ K c) :
    symHitCount K = hitCount K := by
  rw [hitCount_eq_sum_card, symHitCount_eq]
  exact Finset.sum_congr rfl (fun c _ => by rw [Finset.union_eq_left.mpr (hK c)])

/-- A keep-set that covers every mirror pair catches *every* factor pair on the unordered
event, whatever its size. -/
theorem symHit_of_cover (K : G → Finset G) (hK : ∀ c, K c ∪ mirror c (K c) = univ) :
    symHitCount K = Fintype.card (G × G) := by
  rw [symHitCount_eq, Finset.sum_congr rfl (fun c _ => by rw [hK c]), Finset.sum_const,
    Finset.card_univ, Fintype.card_prod, smul_eq_mul]

/-- **Boundary of the sham law.**  On `Multiplicative (ZMod 3)` (the cyclic group of order
3), keep one class per public residue.  The policy `c ↦ {1}` and the policy `c ↦ {c²}` have
the same keep sizes, hence the same ordered score (`3`), but different unordered scores:
`{c²}` is mirror-closed (its mirror at `c` is `{c⁻¹} = {c²}`), scoring `3`, while the mirror
of `{1}` at `c` is `{c}`, scoring `1 + 2 + 2 = 5`. -/
theorem symHit_real_ne_sham :
    let K₁ : Multiplicative (ZMod 3) → Finset (Multiplicative (ZMod 3)) := fun _ => {1}
    let K₂ : Multiplicative (ZMod 3) → Finset (Multiplicative (ZMod 3)) := fun c => {c ^ 2}
    hitCount K₁ = hitCount K₂ ∧ symHitCount K₁ ≠ symHitCount K₂ := by
  intro K₁ K₂
  refine ⟨real_filter_eq_sham K₁ K₂ (fun c => by simp [K₁, K₂]), ?_⟩
  rw [symHitCount_eq, symHitCount_eq]
  decide

end Unordered

end PosteriorFilter