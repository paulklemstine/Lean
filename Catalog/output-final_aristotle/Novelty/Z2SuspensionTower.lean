/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Aristotle (Harmonic)
-/
import Novelty.Z2CoindexSuspension

/-!
# The suspension tower `Sᵏ(K)` of a free `ℤ₂`-complex

Building directly on the combinatorial model of free `ℤ₂`-complexes and their `ℤ₂`-maps
developed in `Novelty.Z2CoindexSuspension` (cross-polytope boundary spheres `Sⁿ`, the
antipodal action, and equivariant simplicial maps `Z2Map m n`), this file assembles the
**suspension tower** into a rigorous functorial object and proves a connected chain of
results about how the `ℤ₂`-coindex propagates through it.

The chain is built bottom-up, each result using the previous ones:

1. **Extensionality** (`Z2Map.map_ext`): a `ℤ₂`-map is determined by its underlying vertex
   map (the two structure fields are propositions).
2. **Functoriality of suspension** (`Z2Map.susp_id`, `Z2Map.susp_comp`): `susp` preserves
   identities and composition, so it is an endofunctor of the category of `ℤ₂`-maps.
3. **The iterated suspension / tower** (`Z2Map.suspIter`): the `k`-fold suspension
   `Sᵐ → Sⁿ ⟹ Sᵐ⁺ᵏ → Sⁿ⁺ᵏ`, with the functor laws lifted to it
   (`Z2Map.suspIter_id`, `Z2Map.suspIter_comp`).
4. **The constructive tower lower bounds** (`tower_raises_coindex`,
   `coindex_tower_lower_bound`, `base_point_tower`): iterating suspension raises every
   coindex witness by the height of the tower.
5. **Borsuk–Ulam descent** (`isEmpty_of_isEmpty_codomain_succ`,
   `isEmpty_of_isEmpty_domain`): non-existence of `ℤ₂`-maps is inherited by lowering the
   codomain or raising the domain, via the equatorial inclusion.
6. **General non-existence to low spheres** (`no_map_to_S0`, `no_map_to_S1`,
   `no_map_to_S2`): from the finite Borsuk–Ulam base instances plus descent, there is *no*
   `ℤ₂`-map from any sufficiently high sphere to `S⁰`, `S¹`, `S²`.
7. **The sharp diagonal and the excess spectrum at the base**
   (`borsuk_ulam_S3_S2`, `borsuk_ulam_diagonal_le_two`, `tower_coindex_sharp`): the coindex
   of `Sⁿ` is exactly `n` for `n ≤ 2`, so the suspension increment is exactly one at the
   bottom three levels of the tower.

Everything is unconditional and `sorry`-free.
-/

namespace Z2CoindexSuspension

namespace Z2Map

/-! ## Extensionality -/

/-- A `ℤ₂`-map is determined by its underlying vertex map: the equivariance and
simpliciality fields are propositions, hence irrelevant. -/
theorem map_ext {m n : ℕ} {F G : Z2Map m n} (h : F.toFun = G.toFun) : F = G := by
  cases F; cases G; cases h; rfl

/-! ## Functoriality of the suspension endofunctor -/

/-- Suspension preserves identities: `susp (id Sⁿ) = id Sⁿ⁺¹`. -/
theorem susp_id (n : ℕ) : (Z2Map.id n).susp = Z2Map.id (n + 1) := by
  refine Z2Map.map_ext ?_
  funext p; obtain ⟨i, b⟩ := p
  refine Fin.lastCases ?_ ?_ i <;>
    simp [Z2Map.susp, Z2Map.suspFun_last, Z2Map.suspFun_castSucc, Z2Map.id, suspV]

/-- Suspension preserves composition: `susp (G ∘ F) = susp G ∘ susp F`. -/
theorem susp_comp {m n k : ℕ} (G : Z2Map n k) (F : Z2Map m n) :
    (G.comp F).susp = (G.susp).comp (F.susp) := by
  refine Z2Map.map_ext ?_
  funext p; obtain ⟨i, b⟩ := p
  refine Fin.lastCases ?_ ?_ i <;>
    simp [Z2Map.susp, Z2Map.comp, Z2Map.suspFun_last, Z2Map.suspFun_castSucc, suspV]

/-! ## The iterated suspension tower -/

/-- The **`k`-fold suspension tower** of a `ℤ₂`-map: from a rung `Sᵐ → Sⁿ` it produces the
higher rung `Sᵐ⁺ᵏ → Sⁿ⁺ᵏ` by applying `susp` `k` times. -/
def suspIter {m n : ℕ} (F : Z2Map m n) : (k : ℕ) → Z2Map (m + k) (n + k)
  | 0 => F
  | k + 1 => (suspIter F k).susp

@[simp] theorem suspIter_zero {m n : ℕ} (F : Z2Map m n) : F.suspIter 0 = F := rfl

@[simp] theorem suspIter_succ {m n : ℕ} (F : Z2Map m n) (k : ℕ) :
    F.suspIter (k + 1) = (F.suspIter k).susp := rfl

/-- The tower of the identity is the identity, at every height. -/
theorem suspIter_id (n k : ℕ) : (Z2Map.id n).suspIter k = Z2Map.id (n + k) := by
  induction k with
  | zero => rfl
  | succ k ih => rw [Z2Map.suspIter_succ, ih, Z2Map.susp_id]; rfl

/-- The tower is functorial: it commutes with composition at every height. -/
theorem suspIter_comp {m n k : ℕ} (G : Z2Map n k) (F : Z2Map m n) (j : ℕ) :
    (G.comp F).suspIter j = (G.suspIter j).comp (F.suspIter j) := by
  induction j with
  | zero => rfl
  | succ j ih => rw [Z2Map.suspIter_succ, ih, Z2Map.susp_comp]; rfl

end Z2Map

/-! ## Constructive tower lower bounds -/

/-- **The suspension tower raises the coindex bound by its full height.** A `ℤ₂`-map
`Sᵐ → Sⁿ` yields, for every `k`, a `ℤ₂`-map `Sᵐ⁺ᵏ → Sⁿ⁺ᵏ`. -/
theorem tower_raises_coindex {m n : ℕ} (h : Nonempty (Z2Map m n)) (k : ℕ) :
    Nonempty (Z2Map (m + k) (n + k)) :=
  h.elim (fun F => ⟨F.suspIter k⟩)

/-- **Constructive tower lower bound.** If `m ≤ n`, then for every tower height `k` there is
an explicit `ℤ₂`-map `Sᵐ⁺ᵏ → Sⁿ⁺ᵏ`; i.e. the diagonal coindex lower bound is preserved by
the suspension tower. -/
theorem coindex_tower_lower_bound {m n : ℕ} (h : m ≤ n) (k : ℕ) :
    Nonempty (Z2Map (m + k) (n + k)) :=
  tower_raises_coindex (coindex_lower_bound h) k

/-- The base point of the tower: from the constructive equatorial map `S⁰ → Sⁿ` one obtains,
by suspending `k` times, a `ℤ₂`-map `Sᵏ → Sⁿ⁺ᵏ`. -/
theorem base_point_tower (n k : ℕ) : Nonempty (Z2Map k (n + k)) := by
  have h := tower_raises_coindex (coindex_lower_bound (Nat.zero_le n)) k
  simpa [Nat.zero_add] using h

/-! ## Borsuk–Ulam descent -/

/-- **Codomain descent.** If there is no `ℤ₂`-map `Sᵐ → Sⁿ⁺¹`, then there is none
`Sᵐ → Sⁿ` either: any such map, post-composed with the equatorial inclusion
`Sⁿ ↪ Sⁿ⁺¹`, would give one to `Sⁿ⁺¹`. -/
theorem isEmpty_of_isEmpty_codomain_succ {m n : ℕ} (h : IsEmpty (Z2Map m (n + 1))) :
    IsEmpty (Z2Map m n) := by
  rw [← not_nonempty_iff] at h ⊢
  rintro ⟨F⟩
  exact h ⟨(Z2Map.incl n).comp F⟩

/-- **Domain ascent.** If there is no `ℤ₂`-map `Sᵐ → Sⁿ`, then there is none
`Sᵐ⁺¹ → Sⁿ`: any such map, pre-composed with the equatorial inclusion `Sᵐ ↪ Sᵐ⁺¹`, would
give one from `Sᵐ`. -/
theorem isEmpty_of_isEmpty_domain {m n : ℕ} (h : IsEmpty (Z2Map m n)) :
    IsEmpty (Z2Map (m + 1) n) := by
  rw [← not_nonempty_iff] at h ⊢
  rintro ⟨F⟩
  exact h ⟨F.comp (Z2Map.incl m)⟩

/-! ## General non-existence of `ℤ₂`-maps to low spheres -/

/-- **No `ℤ₂`-map from any positive-dimensional sphere to `S⁰`.** From the Borsuk–Ulam base
instance `S¹ ↛ S⁰` and domain ascent, `Sᵐ⁺¹ ↛ S⁰` for every `m`. This is the full
Borsuk–Ulam statement `coind(S⁰) = 0` for the whole tower over `S⁰`. -/
theorem no_map_to_S0 (m : ℕ) : IsEmpty (Z2Map (m + 1) 0) := by
  induction m with
  | zero => exact borsuk_ulam_S1_S0
  | succ k ih => exact isEmpty_of_isEmpty_domain ih

/-- **No `ℤ₂`-map from any sphere of dimension `≥ 2` to `S¹`.** From `S² ↛ S¹` and domain
ascent, `Sᵐ⁺² ↛ S¹` for every `m`: the coindex of `S¹` is `1` against the whole tower. -/
theorem no_map_to_S1 (m : ℕ) : IsEmpty (Z2Map (m + 2) 1) := by
  induction m with
  | zero => exact borsuk_ulam_S2_S1
  | succ k ih => exact isEmpty_of_isEmpty_domain ih

set_option maxRecDepth 100000 in
/-- **The next finite Borsuk–Ulam instance `S³ ↛ S²`.** Verified by `decide` over the finite
positive-vertex reformulation `nonempty_iff_exists_pos`. -/
theorem borsuk_ulam_S3_S2 : IsEmpty (Z2Map 3 2) := by
  rw [← not_nonempty_iff, nonempty_iff_exists_pos]
  decide

/-- **No `ℤ₂`-map from any sphere of dimension `≥ 3` to `S²`.** From `S³ ↛ S²` and domain
ascent, `Sᵐ⁺³ ↛ S²` for every `m`. -/
theorem no_map_to_S2 (m : ℕ) : IsEmpty (Z2Map (m + 3) 2) := by
  induction m with
  | zero => exact borsuk_ulam_S3_S2
  | succ k ih => exact isEmpty_of_isEmpty_domain ih

/-! ## The sharp diagonal: the excess spectrum at the base of the tower -/

/-- **The sharp Borsuk–Ulam diagonal for `n ≤ 2`:** there is no `ℤ₂`-map `Sⁿ⁺¹ → Sⁿ`,
equivalently `coind(Sⁿ) < n + 1`. Together with `coindex_self` this pins `coind(Sⁿ) = n`
for `n ∈ {0, 1, 2}`. -/
theorem borsuk_ulam_diagonal_le_two {n : ℕ} (hn : n ≤ 2) : IsEmpty (Z2Map (n + 1) n) := by
  interval_cases n
  · exact borsuk_ulam_S1_S0
  · exact borsuk_ulam_S2_S1
  · exact borsuk_ulam_S3_S2

/-- **Sharpness of the tower's coindex increment at the base.** For `n ≤ 2`, the sphere `Sⁿ`
admits a `ℤ₂`-self-map (coindex `≥ n`) but admits *no* `ℤ₂`-map from `Sⁿ⁺¹` (coindex
`< n + 1`); hence `coind(Sⁿ) = n` exactly, and each rung of the suspension tower gains
precisely one unit of coindex. -/
theorem tower_coindex_sharp {n : ℕ} (hn : n ≤ 2) :
    Nonempty (Z2Map n n) ∧ IsEmpty (Z2Map (n + 1) n) :=
  ⟨coindex_self n, borsuk_ulam_diagonal_le_two hn⟩

end Z2CoindexSuspension