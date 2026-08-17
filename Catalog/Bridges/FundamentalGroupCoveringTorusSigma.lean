/-
# The torus has exactly `σ(n)` connected `n`-sheeted coverings

This file closes the counting half of sub-conjecture **C2b** of the thread in full
generality, for every degree `n` and not only for primes:

> the number of connected `n`-sheeted coverings of the torus `K(ℤ²,1)` is
> `σ(n) = ∑_{d ∣ n} d`.

Earlier files verified the cases `n = 2` (`σ(2) = 3`), `n = 3` (`σ(3) = 4`) by explicit
enumeration and every prime `n = p` (`σ(p) = p + 1`) by character theory.  The present
proof is the Hermite normal form of a sublattice of `ℤ²`:

* `torusLat a c d` is the sublattice spanned by `(a,0)` and `(c,d)` — the range of the
  endomorphism with matrix `[[a,c],[0,d]]` — and `mem_torusLat_iff'` describes it by
  congruences;
* `index_torusLat`: its index is `a·d`.  The proof is a two-step tower: the sublattice sits
  inside `ℤ × dℤ`, which has index `d` as the kernel of reduction of the second coordinate,
  and its relative index there is `a`, computed as the kernel of the homomorphism
  `(x,y) ↦ x − (y/d)·c mod a`;
* `exists_hnf`: **every** finite-index subgroup is a `torusLat a c d` in normal form,
  `a, d > 0` and `0 ≤ c < a`, obtained from the generators of the two cyclic subgroups
  `{x : (x,0) ∈ H}` and `{y : ∃ x, (x,y) ∈ H}` of `ℤ`;
* `hnf_unique`: the normal form is unique;
* `card_index_n_subgroups_torus`: assembling the two, the index-`n` subgroups biject with
  the pairs `(a, c)` where `a ∣ n` and `0 ≤ c < a`, so there are `∑_{a ∣ n} a = σ(n)` of
  them;
* `torus_sigma_classification`: the covering-theoretic form — `σ(n)` pairwise
  non-isomorphic connected `n`-sheeted coverings, each with total space again a torus.
-/
import Mathlib
import Bridges.FundamentalGroupCoveringGalois
import Bridges.FundamentalGroupCoveringTorus
import Bridges.FundamentalGroupCoveringTorusFinite
import Bridges.FundamentalGroupCoveringTorusPrime

open CategoryTheory MulAction

namespace FundamentalGroupCovering

namespace TorusSigma

/-! ## Sublattices in Hermite normal form -/

/-- The endomorphism of `ℤ²` with matrix `[[a,c],[0,d]]`. -/
def latAdd (a c d : ℤ) : (ℤ × ℤ) →+ (ℤ × ℤ) :=
  AddMonoidHom.mk' (fun x => (a * x.1 + c * x.2, d * x.2)) (by
    intro x y
    apply Prod.ext
    · show a * (x.1 + y.1) + c * (x.2 + y.2) = _
      simp [mul_add]; ring
    · show d * (x.2 + y.2) = _
      simp [mul_add])

/-- The same endomorphism, written multiplicatively on the fundamental group of the
torus. -/
def latHom (a c d : ℤ) : Torus →* Torus := AddMonoidHom.toMultiplicative (latAdd a c d)

/-- The sublattice of `ℤ²` spanned by `(a,0)` and `(c,d)`. -/
def torusLat (a c d : ℤ) : Subgroup Torus := (latHom a c d).range

theorem mem_torusLat_iff (a c d : ℤ) (x : ℤ × ℤ) :
    Multiplicative.ofAdd x ∈ torusLat a c d ↔ ∃ u v : ℤ, a * u + c * v = x.1 ∧ d * v = x.2 := by
  constructor
  · rintro ⟨z, hz⟩
    exact ⟨(Multiplicative.toAdd z).1, (Multiplicative.toAdd z).2,
      congrArg Prod.fst (Multiplicative.ofAdd.injective hz),
      congrArg Prod.snd (Multiplicative.ofAdd.injective hz)⟩
  · rintro ⟨u, v, h1, h2⟩
    exact ⟨Multiplicative.ofAdd (u, v), congrArg Multiplicative.ofAdd (Prod.ext h1 h2)⟩

/-- The congruence description of the sublattice. -/
theorem mem_torusLat_iff' {a c d : ℤ} (hd : d ≠ 0) (x : ℤ × ℤ) :
    Multiplicative.ofAdd x ∈ torusLat a c d ↔ d ∣ x.2 ∧ a ∣ (x.1 - (x.2 / d) * c) := by
  rw [mem_torusLat_iff]
  constructor
  · rintro ⟨u, v, h1, h2⟩
    refine ⟨⟨v, h2.symm⟩, ?_⟩
    have hv : x.2 / d = v := by rw [← h2]; exact Int.mul_ediv_cancel_left v hd
    rw [hv, ← h1]
    exact ⟨u, by ring⟩
  · rintro ⟨⟨v, hv⟩, ⟨u, hu⟩⟩
    refine ⟨u, v, ?_, hv.symm⟩
    have hdv : x.2 / d = v := by rw [hv]; exact Int.mul_ediv_cancel_left v hd
    rw [hdv] at hu
    linarith [hu]

theorem dvd_snd_of_mem_kSub {d : ℤ} {z : Torus} (hz : z ∈ torusLat 1 0 d) :
    d ∣ (Multiplicative.toAdd z).2 := by
  obtain ⟨_, v, -, h2⟩ := (mem_torusLat_iff 1 0 d (Multiplicative.toAdd z)).mp hz
  exact ⟨v, h2.symm⟩

theorem le_kSub {a c d : ℤ} : torusLat a c d ≤ torusLat 1 0 d := by
  intro z hz
  obtain ⟨_, v, -, h2⟩ := (mem_torusLat_iff a c d (Multiplicative.toAdd z)).mp hz
  exact (mem_torusLat_iff 1 0 d (Multiplicative.toAdd z)).mpr
    ⟨(Multiplicative.toAdd z).1, v, by ring, h2⟩

/-! ## The index of a sublattice in normal form -/

/-- Reduction of the second coordinate modulo `m`. -/
def torusSnd (m : ℕ) : Torus →* Multiplicative (ZMod m) :=
  AddMonoidHom.toMultiplicative (AddMonoidHom.mk' (fun x : ℤ × ℤ => ((x.2 : ℤ) : ZMod m)) (by
    intro x y
    show (((x.2 + y.2 : ℤ)) : ZMod m) = _
    push_cast
    ring))

theorem torusSnd_surjective (m : ℕ) : Function.Surjective (torusSnd m) := by
  intro y
  obtain ⟨k, hk⟩ := ZMod.intCast_surjective (n := m) (Multiplicative.toAdd y)
  exact ⟨Multiplicative.ofAdd ((0, k) : ℤ × ℤ), by
    show Multiplicative.ofAdd ((k : ZMod m)) = y
    rw [hk]
    rfl⟩

theorem ker_torusSnd {d : ℤ} (hd : 0 < d) : (torusSnd d.toNat).ker = torusLat 1 0 d := by
  ext z
  obtain ⟨x, rfl⟩ : ∃ x : ℤ × ℤ, Multiplicative.ofAdd x = z := ⟨Multiplicative.toAdd z, rfl⟩
  rw [mem_torusLat_iff' (ne_of_gt hd)]
  constructor
  · intro hz
    have h0 : ((x.2 : ℤ) : ZMod d.toNat) = 0 := hz
    refine ⟨?_, one_dvd _⟩
    have := (ZMod.intCast_zmod_eq_zero_iff_dvd x.2 d.toNat).mp h0
    rwa [Int.toNat_of_nonneg hd.le] at this
  · rintro ⟨hdvd, -⟩
    show ((x.2 : ℤ) : ZMod d.toNat) = 0
    rw [ZMod.intCast_zmod_eq_zero_iff_dvd, Int.toNat_of_nonneg hd.le]
    exact hdvd

theorem index_kSub {d : ℤ} (hd : 0 < d) : (torusLat 1 0 d).index = d.toNat := by
  rw [← ker_torusSnd hd, Subgroup.index_ker,
    MonoidHom.range_eq_top.mpr (torusSnd_surjective d.toNat), Subgroup.card_top]
  haveI : NeZero d.toNat := ⟨by omega⟩
  show Nat.card (ZMod d.toNat) = d.toNat
  rw [Nat.card_eq_fintype_card, ZMod.card]

/-- On `ℤ × dℤ`, the homomorphism `(x,y) ↦ x − (y/d)·c mod a`, whose kernel is the
sublattice `torusLat a c d`. -/
def relHom (a c d : ℤ) : (torusLat 1 0 d) →* Multiplicative (ZMod a.toNat) :=
  MonoidHom.mk' (fun z => Multiplicative.ofAdd
      ((((Multiplicative.toAdd (z : Torus)).1
        - ((Multiplicative.toAdd (z : Torus)).2 / d) * c : ℤ) : ZMod a.toNat)))
    (by
      intro z w
      have hz := dvd_snd_of_mem_kSub z.2
      show Multiplicative.ofAdd ((((Multiplicative.toAdd ((z : Torus) * (w : Torus))).1
        - ((Multiplicative.toAdd ((z : Torus) * (w : Torus))).2 / d) * c : ℤ) : ZMod a.toNat))
        = _
      have h1 : (Multiplicative.toAdd ((z : Torus) * (w : Torus))).1
          = (Multiplicative.toAdd (z : Torus)).1 + (Multiplicative.toAdd (w : Torus)).1 := rfl
      have h2 : (Multiplicative.toAdd ((z : Torus) * (w : Torus))).2
          = (Multiplicative.toAdd (z : Torus)).2 + (Multiplicative.toAdd (w : Torus)).2 := rfl
      rw [h1, h2, Int.add_ediv_of_dvd_left hz, ← ofAdd_add]
      congr 1
      push_cast
      ring)

theorem relHom_apply (a c d : ℤ) (z : torusLat 1 0 d) :
    relHom a c d z = Multiplicative.ofAdd
      ((((Multiplicative.toAdd (z : Torus)).1
        - ((Multiplicative.toAdd (z : Torus)).2 / d) * c : ℤ) : ZMod a.toNat)) := rfl

theorem relHom_surjective (a c d : ℤ) : Function.Surjective (relHom a c d) := by
  intro t
  obtain ⟨k, hk⟩ := ZMod.intCast_surjective (n := a.toNat) (Multiplicative.toAdd t)
  refine ⟨⟨Multiplicative.ofAdd ((k, 0) : ℤ × ℤ),
    (mem_torusLat_iff 1 0 d ((k, 0) : ℤ × ℤ)).mpr ⟨k, 0, by ring, by ring⟩⟩, ?_⟩
  rw [relHom_apply]
  show Multiplicative.ofAdd (((k - (0 / d) * c : ℤ) : ZMod a.toNat)) = t
  rw [Int.zero_ediv, zero_mul, sub_zero, hk]
  rfl

theorem ker_relHom {a c d : ℤ} (ha : 0 < a) (hd : 0 < d) :
    (relHom a c d).ker = (torusLat a c d).subgroupOf (torusLat 1 0 d) := by
  ext z
  rw [Subgroup.mem_subgroupOf, MonoidHom.mem_ker, relHom_apply]
  have hz := dvd_snd_of_mem_kSub z.2
  have hiff := mem_torusLat_iff' (a := a) (c := c) (ne_of_gt hd)
    (Multiplicative.toAdd (z : Torus))
  constructor
  · intro h
    have h0 : (((Multiplicative.toAdd (z : Torus)).1
        - ((Multiplicative.toAdd (z : Torus)).2 / d) * c : ℤ) : ZMod a.toNat) = 0 := h
    refine hiff.mpr ⟨hz, ?_⟩
    have := (ZMod.intCast_zmod_eq_zero_iff_dvd _ a.toNat).mp h0
    rwa [Int.toNat_of_nonneg ha.le] at this
  · intro hmem
    obtain ⟨-, hdvd⟩ := hiff.mp hmem
    show (((Multiplicative.toAdd (z : Torus)).1
        - ((Multiplicative.toAdd (z : Torus)).2 / d) * c : ℤ) : ZMod a.toNat) = 0
    rw [ZMod.intCast_zmod_eq_zero_iff_dvd, Int.toNat_of_nonneg ha.le]
    exact hdvd

/-- **The index of the sublattice spanned by `(a,0)` and `(c,d)` is `a·d`.** -/
theorem index_torusLat {a c d : ℤ} (ha : 0 < a) (hd : 0 < d) :
    (torusLat a c d).index = a.toNat * d.toNat := by
  have hrel : (torusLat a c d).relIndex (torusLat 1 0 d) = a.toNat := by
    show ((torusLat a c d).subgroupOf (torusLat 1 0 d)).index = a.toNat
    rw [← ker_relHom ha hd, Subgroup.index_ker,
      MonoidHom.range_eq_top.mpr (relHom_surjective a c d), Subgroup.card_top]
    haveI : NeZero a.toNat := ⟨by omega⟩
    show Nat.card (ZMod a.toNat) = a.toNat
    rw [Nat.card_eq_fintype_card, ZMod.card]
  have h2 := Subgroup.relIndex_mul_index (le_kSub (a := a) (c := c) (d := d))
  rw [hrel, index_kSub hd] at h2
  exact h2.symm

/-! ## Existence of the normal form -/

/-- A subgroup of `ℤ` containing a positive element has a positive generator. -/
theorem exists_pos_gen (S : AddSubgroup ℤ) {n : ℤ} (hn : 0 < n) (hnS : n ∈ S) :
    ∃ a : ℤ, 0 < a ∧ ∀ x : ℤ, x ∈ S ↔ a ∣ x := by
  obtain ⟨g, hg⟩ := Int.subgroup_cyclic S
  have hmem : ∀ x : ℤ, x ∈ S ↔ g ∣ x := by
    intro x
    rw [hg, AddSubgroup.mem_closure_singleton]
    constructor
    · rintro ⟨k, rfl⟩
      exact ⟨k, by rw [mul_comm]; simp⟩
    · rintro ⟨k, rfl⟩
      exact ⟨k, by simp [mul_comm]⟩
  have hg0 : g ≠ 0 := by
    intro h
    rw [h] at hmem
    have := (hmem n).mp hnS
    omega
  refine ⟨|g|, abs_pos.mpr hg0, fun x => ?_⟩
  rw [hmem x]
  exact (abs_dvd g x).symm

/-- The subgroup of first coordinates of elements of `H` with vanishing second
coordinate. -/
def fstSub (H : Subgroup Torus) : AddSubgroup ℤ where
  carrier := {x : ℤ | Multiplicative.ofAdd ((x, 0) : ℤ × ℤ) ∈ H}
  add_mem' {x y} hx hy := by
    have : Multiplicative.ofAdd (((x + y, 0)) : ℤ × ℤ)
        = Multiplicative.ofAdd ((x, 0) : ℤ × ℤ) * Multiplicative.ofAdd ((y, 0) : ℤ × ℤ) := by
      apply congrArg Multiplicative.ofAdd
      apply Prod.ext <;> simp
    rw [Set.mem_setOf_eq, this]
    exact H.mul_mem hx hy
  zero_mem' := H.one_mem
  neg_mem' {x} hx := by
    have : Multiplicative.ofAdd (((-x, 0)) : ℤ × ℤ)
        = (Multiplicative.ofAdd ((x, 0) : ℤ × ℤ))⁻¹ := by
      apply congrArg Multiplicative.ofAdd
      apply Prod.ext <;> simp
    rw [Set.mem_setOf_eq, this]
    exact H.inv_mem hx

/-- The subgroup of second coordinates of elements of `H`. -/
def sndSub (H : Subgroup Torus) : AddSubgroup ℤ where
  carrier := {y : ℤ | ∃ x : ℤ, Multiplicative.ofAdd ((x, y) : ℤ × ℤ) ∈ H}
  add_mem' {y y'} hy hy' := by
    obtain ⟨x, hx⟩ := hy
    obtain ⟨x', hx'⟩ := hy'
    refine ⟨x + x', ?_⟩
    have : Multiplicative.ofAdd (((x + x', y + y')) : ℤ × ℤ)
        = Multiplicative.ofAdd ((x, y) : ℤ × ℤ) * Multiplicative.ofAdd ((x', y') : ℤ × ℤ) := rfl
    rw [this]
    exact H.mul_mem hx hx'
  zero_mem' := ⟨0, H.one_mem⟩
  neg_mem' {y} hy := by
    obtain ⟨x, hx⟩ := hy
    refine ⟨-x, ?_⟩
    have : Multiplicative.ofAdd (((-x, -y)) : ℤ × ℤ)
        = (Multiplicative.ofAdd ((x, y) : ℤ × ℤ))⁻¹ := rfl
    rw [this]
    exact H.inv_mem hx

/-- `n · x ∈ H` for `n` the index of `H`. -/
theorem index_smul_mem (H : Subgroup Torus) (x : ℤ × ℤ) :
    Multiplicative.ofAdd (((H.index : ℤ)) • x) ∈ H := by
  rw [natCast_zsmul, ofAdd_nsmul]
  exact Subgroup.pow_index_mem H _

/-- **Hermite normal form**: every finite-index subgroup of `ℤ²` is the sublattice spanned
by `(a,0)` and `(c,d)` for a unique triple with `a, d > 0` and `0 ≤ c < a`, and its index
is `a·d`. -/
theorem exists_hnf {H : Subgroup Torus} (hH : H.index ≠ 0) :
    ∃ a c d : ℤ, 0 < a ∧ 0 < d ∧ 0 ≤ c ∧ c < a ∧ a.toNat * d.toNat = H.index ∧
      H = torusLat a c d := by
  set n : ℤ := (H.index : ℤ) with hn
  have hnpos : 0 < n := by
    rw [hn]
    exact_mod_cast Nat.pos_of_ne_zero hH
  -- the two cyclic subgroups of `ℤ`
  have hnfst : n ∈ fstSub H := by
    have := index_smul_mem H ((1, 0) : ℤ × ℤ)
    have he : ((H.index : ℤ)) • ((1, 0) : ℤ × ℤ) = ((n, 0) : ℤ × ℤ) := by
      apply Prod.ext <;> simp [hn]
    rwa [he] at this
  have hnsnd : n ∈ sndSub H := by
    refine ⟨0, ?_⟩
    have := index_smul_mem H ((0, 1) : ℤ × ℤ)
    have he : ((H.index : ℤ)) • ((0, 1) : ℤ × ℤ) = ((0, n) : ℤ × ℤ) := by
      apply Prod.ext <;> simp [hn]
    rwa [he] at this
  obtain ⟨a, hapos, ha⟩ := exists_pos_gen (fstSub H) hnpos hnfst
  obtain ⟨d, hdpos, hd⟩ := exists_pos_gen (sndSub H) hnpos hnsnd
  obtain ⟨c₀, hc₀⟩ : ∃ x : ℤ, Multiplicative.ofAdd ((x, d) : ℤ × ℤ) ∈ H :=
    (hd d).mpr dvd_rfl
  set c : ℤ := c₀ % a with hc
  have hcnonneg : 0 ≤ c := Int.emod_nonneg c₀ (ne_of_gt hapos)
  have hclt : c < a := Int.emod_lt_of_pos c₀ hapos
  have hcmem : Multiplicative.ofAdd ((c, d) : ℤ × ℤ) ∈ H := by
    have hdiff : ((c, d) : ℤ × ℤ) = ((c₀, d) : ℤ × ℤ) + ((-(a * (c₀ / a)), 0) : ℤ × ℤ) := by
      apply Prod.ext
      · show c = c₀ + -(a * (c₀ / a))
        rw [hc]
        have := Int.emod_add_mul_ediv c₀ a
        linarith
      · show d = d + 0
        ring
    have hamem : Multiplicative.ofAdd ((-(a * (c₀ / a)), 0) : ℤ × ℤ) ∈ H :=
      (ha _).mpr ⟨-(c₀ / a), by ring⟩
    have : Multiplicative.ofAdd ((c, d) : ℤ × ℤ)
        = Multiplicative.ofAdd ((c₀, d) : ℤ × ℤ)
          * Multiplicative.ofAdd ((-(a * (c₀ / a)), 0) : ℤ × ℤ) := by
      rw [hdiff]; rfl
    rw [this]
    exact H.mul_mem hc₀ hamem
  have hamem : Multiplicative.ofAdd ((a, 0) : ℤ × ℤ) ∈ H := (ha a).mpr dvd_rfl
  have hHeq : H = torusLat a c d := by
    apply le_antisymm
    · intro z hz
      obtain ⟨x, rfl⟩ : ∃ x : ℤ × ℤ, Multiplicative.ofAdd x = z := ⟨Multiplicative.toAdd z, rfl⟩
      -- the second coordinate is a multiple of `d`
      obtain ⟨k, hk⟩ : d ∣ x.2 := (hd x.2).mp ⟨x.1, hz⟩
      -- subtract `k · (c,d)` to land in the first cyclic subgroup
      have hsub : Multiplicative.ofAdd ((x.1 - k * c, 0) : ℤ × ℤ) ∈ H := by
        have hzk : Multiplicative.ofAdd ((x.1 - k * c, 0) : ℤ × ℤ)
            = Multiplicative.ofAdd x * (Multiplicative.ofAdd ((c, d) : ℤ × ℤ)) ^ (-k) := by
          apply congrArg Multiplicative.ofAdd
          have : (Multiplicative.ofAdd ((c, d) : ℤ × ℤ)) ^ (-k)
              = Multiplicative.ofAdd ((-(k * c), -(k * d)) : ℤ × ℤ) := by
            rw [← ofAdd_zsmul]
            apply congrArg Multiplicative.ofAdd
            apply Prod.ext <;> simp
          rw [this]
          show ((x.1 - k * c, 0) : ℤ × ℤ) = x + ((-(k * c), -(k * d)) : ℤ × ℤ)
          apply Prod.ext
          · show x.1 - k * c = x.1 + -(k * c)
            ring
          · show (0 : ℤ) = x.2 + -(k * d)
            rw [hk]; ring
        rw [hzk]
        exact H.mul_mem hz (H.zpow_mem hcmem _)
      obtain ⟨m, hm⟩ : a ∣ (x.1 - k * c) := (ha _).mp hsub
      refine (mem_torusLat_iff a c d x).mpr ⟨m, k, ?_, hk.symm⟩
      linarith [hm]
    · intro z hz
      obtain ⟨x, rfl⟩ : ∃ x : ℤ × ℤ, Multiplicative.ofAdd x = z := ⟨Multiplicative.toAdd z, rfl⟩
      obtain ⟨u, v, h1, h2⟩ := (mem_torusLat_iff a c d x).mp hz
      have hx : Multiplicative.ofAdd x
          = (Multiplicative.ofAdd ((a, 0) : ℤ × ℤ)) ^ u
            * (Multiplicative.ofAdd ((c, d) : ℤ × ℤ)) ^ v := by
        have e1 : (Multiplicative.ofAdd ((a, 0) : ℤ × ℤ)) ^ u
            = Multiplicative.ofAdd ((a * u, 0) : ℤ × ℤ) := by
          rw [← ofAdd_zsmul]
          apply congrArg Multiplicative.ofAdd
          apply Prod.ext <;> simp [mul_comm]
        have e2 : (Multiplicative.ofAdd ((c, d) : ℤ × ℤ)) ^ v
            = Multiplicative.ofAdd ((c * v, d * v) : ℤ × ℤ) := by
          rw [← ofAdd_zsmul]
          apply congrArg Multiplicative.ofAdd
          apply Prod.ext <;> simp [mul_comm]
        rw [e1, e2]
        apply congrArg Multiplicative.ofAdd
        apply Prod.ext
        · show x.1 = a * u + c * v
          rw [h1]
        · show x.2 = 0 + d * v
          rw [h2]; ring
      rw [hx]
      exact H.mul_mem (H.zpow_mem hamem _) (H.zpow_mem hcmem _)
  refine ⟨a, c, d, hapos, hdpos, hcnonneg, hclt, ?_, hHeq⟩
  rw [← index_torusLat (c := c) hapos hdpos, ← hHeq]

/-! ## Uniqueness of the normal form -/

theorem snd_gen_eq {a c d : ℤ} (hd : 0 < d) (y : ℤ) :
    (∃ x : ℤ, Multiplicative.ofAdd ((x, y) : ℤ × ℤ) ∈ torusLat a c d) ↔ d ∣ y := by
  constructor
  · rintro ⟨x, hx⟩
    exact ((mem_torusLat_iff' (ne_of_gt hd) ((x, y) : ℤ × ℤ)).mp hx).1
  · rintro ⟨k, rfl⟩
    exact ⟨a * 0 + c * k, (mem_torusLat_iff a c d _).mpr ⟨0, k, rfl, rfl⟩⟩

theorem fst_gen_eq {a c d : ℤ} (hd : 0 < d) (x : ℤ) :
    Multiplicative.ofAdd ((x, 0) : ℤ × ℤ) ∈ torusLat a c d ↔ a ∣ x := by
  rw [mem_torusLat_iff' (ne_of_gt hd) ((x, 0) : ℤ × ℤ)]
  constructor
  · rintro ⟨-, h⟩
    show a ∣ x
    have hz : ((0 : ℤ) / d) * c = 0 := by simp
    rw [show ((x, (0:ℤ)) : ℤ × ℤ).1 = x from rfl, show ((x, (0:ℤ)) : ℤ × ℤ).2 = 0 from rfl,
      hz, sub_zero] at h
    exact h
  · intro h
    refine ⟨dvd_zero d, ?_⟩
    have hz : (((x, (0:ℤ)) : ℤ × ℤ).2 / d) * c = 0 := by simp
    rw [hz, sub_zero]
    exact h

/-- **The normal form is unique.** -/
theorem hnf_unique {a c d a' c' d' : ℤ} (ha : 0 < a) (hd : 0 < d) (ha' : 0 < a')
    (hd' : 0 < d') (hc : 0 ≤ c) (hca : c < a) (hc' : 0 ≤ c') (hca' : c' < a')
    (heq : torusLat a c d = torusLat a' c' d') : a = a' ∧ c = c' ∧ d = d' := by
  have hdd : d = d' := by
    have h1 : d ∣ d' := by
      have := (snd_gen_eq (a := a) (c := c) hd d').mp
        (by rw [heq]; exact (snd_gen_eq (a := a') (c := c') hd' d').mpr dvd_rfl)
      exact this
    have h2 : d' ∣ d := by
      have := (snd_gen_eq (a := a') (c := c') hd' d).mp
        (by rw [← heq]; exact (snd_gen_eq (a := a) (c := c) hd d).mpr dvd_rfl)
      exact this
    exact Int.dvd_antisymm hd.le hd'.le h1 h2
  have haa : a = a' := by
    have h1 : a ∣ a' := by
      have hmem : Multiplicative.ofAdd ((a', 0) : ℤ × ℤ) ∈ torusLat a c d := by
        rw [heq]
        exact (fst_gen_eq hd' a').mpr dvd_rfl
      exact (fst_gen_eq hd a').mp hmem
    have h2 : a' ∣ a := by
      have hmem : Multiplicative.ofAdd ((a, 0) : ℤ × ℤ) ∈ torusLat a' c' d' := by
        rw [← heq]
        exact (fst_gen_eq hd a).mpr dvd_rfl
      exact (fst_gen_eq hd' a).mp hmem
    exact Int.dvd_antisymm ha.le ha'.le h1 h2
  refine ⟨haa, ?_, hdd⟩
  -- the two shear parameters differ by a multiple of `a`, and both lie in `[0, a)`
  have hmem : Multiplicative.ofAdd ((c, d) : ℤ × ℤ) ∈ torusLat a' c' d' := by
    rw [← heq]
    exact (mem_torusLat_iff a c d ((c, d) : ℤ × ℤ)).mpr ⟨0, 1, by ring, by ring⟩
  rw [mem_torusLat_iff' (ne_of_gt hd') ((c, d) : ℤ × ℤ)] at hmem
  obtain ⟨-, hdvd⟩ := hmem
  have hq : ((c, d) : ℤ × ℤ).2 / d' = 1 := by
    show d / d' = 1
    rw [hdd]
    exact Int.ediv_self (ne_of_gt hd')
  rw [hq, one_mul] at hdvd
  have hdvd' : a ∣ (c - c') := by rw [haa]; exact hdvd
  obtain ⟨k, hk⟩ := hdvd'
  have hc'a : c' < a := by rw [haa]; exact hca'
  have hk0 : k = 0 := by
    rcases lt_trichotomy k 0 with h | h | h
    · exfalso
      have hle : a * k ≤ -a := by nlinarith
      linarith
    · exact h
    · exfalso
      have hge : a ≤ a * k := by nlinarith
      linarith
  rw [hk0, mul_zero] at hk
  omega

/-! ## Counting the subgroups of index `n` -/

/-- The parametrisation of the index-`n` subgroups by pairs `(a, c)` with `a ∣ n` and
`0 ≤ c < a`. -/
def hnfOfPair (n : ℕ) (p : (a : n.divisors) × Fin (a : ℕ)) : Subgroup Torus :=
  torusLat ((p.1 : ℕ) : ℤ) ((p.2 : ℕ) : ℤ) ((n / (p.1 : ℕ) : ℕ) : ℤ)

theorem index_hnfOfPair {n : ℕ} (hn : n ≠ 0) (p : (a : n.divisors) × Fin (a : ℕ)) :
    (hnfOfPair n p).index = n := by
  obtain ⟨⟨a, ha⟩, c⟩ := p
  have hadvd : a ∣ n := (Nat.mem_divisors.mp ha).1
  have hapos : 0 < a := Nat.pos_of_ne_zero (by
    rintro rfl
    exact hn (Nat.eq_zero_of_zero_dvd hadvd))
  have hdpos : 0 < n / a := Nat.div_pos (Nat.le_of_dvd (Nat.pos_of_ne_zero hn) hadvd) hapos
  show (torusLat (a : ℤ) ((c : ℕ) : ℤ) (((n / a : ℕ)) : ℤ)).index = n
  rw [index_torusLat (by exact_mod_cast hapos) (by exact_mod_cast hdpos)]
  simp only [Int.toNat_natCast]
  exact Nat.mul_div_cancel' hadvd

/-- **The index-`n` subgroups of `ℤ²` biject with the pairs `(a, c)`, `a ∣ n`,
`0 ≤ c < a`.** -/
theorem card_index_n_subgroups_torus {n : ℕ} (hn : n ≠ 0) :
    Nat.card {H : Subgroup Torus // H.index = n} = ∑ a ∈ n.divisors, a := by
  classical
  have hbij : Function.Bijective
      (fun p : (a : n.divisors) × Fin (a : ℕ) =>
        (⟨hnfOfPair n p, index_hnfOfPair hn p⟩ : {H : Subgroup Torus // H.index = n})) := by
    constructor
    · rintro ⟨⟨a, ha⟩, c⟩ ⟨⟨a', ha'⟩, c'⟩ hEq
      have hadvd : a ∣ n := (Nat.mem_divisors.mp ha).1
      have hadvd' : a' ∣ n := (Nat.mem_divisors.mp ha').1
      have hapos : 0 < a := Nat.pos_of_ne_zero (by
        rintro rfl; exact hn (Nat.eq_zero_of_zero_dvd hadvd))
      have hapos' : 0 < a' := Nat.pos_of_ne_zero (by
        rintro rfl; exact hn (Nat.eq_zero_of_zero_dvd hadvd'))
      have hdpos : 0 < n / a := Nat.div_pos (Nat.le_of_dvd (Nat.pos_of_ne_zero hn) hadvd) hapos
      have hdpos' : 0 < n / a' := Nat.div_pos (Nat.le_of_dvd (Nat.pos_of_ne_zero hn) hadvd') hapos'
      have hlat : torusLat (a : ℤ) ((c : ℕ) : ℤ) (((n / a : ℕ)) : ℤ)
          = torusLat (a' : ℤ) ((c' : ℕ) : ℤ) (((n / a' : ℕ)) : ℤ) := congrArg Subtype.val hEq
      obtain ⟨h1, h2, -⟩ := hnf_unique (by exact_mod_cast hapos) (by exact_mod_cast hdpos)
        (by exact_mod_cast hapos') (by exact_mod_cast hdpos')
        (by positivity) (by exact_mod_cast c.2) (by positivity) (by exact_mod_cast c'.2) hlat
      have haa : a = a' := by exact_mod_cast h1
      subst haa
      have hcc : (c : ℕ) = (c' : ℕ) := by exact_mod_cast h2
      simp only [Sigma.mk.injEq, heq_eq_eq, true_and]
      exact Fin.ext hcc
    · rintro ⟨H, hH⟩
      obtain ⟨a, c, d, hapos, hdpos, hcnn, hclt, hindex, hHeq⟩ :=
        exists_hnf (H := H) (by rw [hH]; exact hn)
      have hadvd : a.toNat ∣ n := ⟨d.toNat, by rw [hindex]; exact hH.symm⟩
      have hamem : a.toNat ∈ n.divisors := Nat.mem_divisors.mpr ⟨hadvd, hn⟩
      have hcfin : c.toNat < a.toNat := by omega
      refine ⟨⟨⟨a.toNat, hamem⟩, ⟨c.toNat, hcfin⟩⟩, ?_⟩
      apply Subtype.ext
      show torusLat ((a.toNat : ℕ) : ℤ) ((c.toNat : ℕ) : ℤ) (((n / a.toNat : ℕ)) : ℤ) = H
      have hna : n / a.toNat = d.toNat := by
        rw [← hH, ← hindex]
        exact Nat.mul_div_cancel_left _ (by omega)
      rw [hna, hHeq]
      congr 1 <;> omega
  rw [← Nat.card_congr (Equiv.ofBijective _ hbij), Nat.card_sigma]
  simp [Finset.sum_attach n.divisors (fun a => a)]

/-- **The torus has exactly `σ(n)` subgroups of index `n`.** -/
theorem card_index_n_subgroups_torus_sigma {n : ℕ} (hn : n ≠ 0) :
    Nat.card {H : Subgroup Torus // H.index = n} = ArithmeticFunction.sigma 1 n := by
  rw [ArithmeticFunction.sigma_one_apply]
  exact card_index_n_subgroups_torus hn

/-- The checkpoint predicted by the previous cycle: the torus has exactly `σ(4) = 7`
connected four-sheeted coverings. -/
theorem card_index_four_subgroups_torus :
    Nat.card {H : Subgroup Torus // H.index = 4} = 7 := by
  have h := card_index_n_subgroups_torus (n := 4) (by norm_num)
  have hsum : ∑ a ∈ Nat.divisors 4, a = 7 := by decide
  rw [hsum] at h
  exact h

/-- **The complete classification of the finite coverings of the torus.**  For every `n ≥ 1`
the torus has exactly `σ(n)` connected `n`-sheeted coverings; they are pairwise
non-isomorphic, and the total space of each one is again a torus. -/
theorem torus_sigma_classification {n : ℕ} (hn : n ≠ 0) :
    Nat.card {H : Subgroup Torus // H.index = n} = ArithmeticFunction.sigma 1 n ∧
      (∀ H L : {H : Subgroup Torus // H.index = n},
        Nonempty (GEquiv Torus (Torus ⧸ H.1) (Torus ⧸ L.1)) ↔ H = L) ∧
      (∀ H : {H : Subgroup Torus // H.index = n}, Nonempty (H.1 ≃* Torus)) := by
  refine ⟨card_index_n_subgroups_torus_sigma hn, ?_, ?_⟩
  · intro H L
    rw [abelian_gEquiv_iff_eq]
    exact ⟨fun h => Subtype.ext h.symm, fun h => by rw [h]⟩
  · intro H
    exact torus_finite_index_subgroup_mulEquiv (by rw [H.2]; exact hn)

end TorusSigma

end FundamentalGroupCovering