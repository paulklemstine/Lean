/-
# Frobenius orbits and the semiprime pair channel at conductor 56

Two structural laws behind the degree-12 rung, each proved first as a general
theorem and then instantiated at `G⁺ = C₆ × C₂`:

* **Orbit purity / the `efg` law.**  Frobenius acts on the 12 cosets of `Q(ζ₅₆)⁺`
  by translation by its own class `g`.  We show (`card_transOrbit`,
  `card_orbits_mul_addOrderOf`) that *every* orbit has exactly `addOrderOf g`
  elements — no short orbits, no mixed lengths — and that the number of orbits
  times the orbit length is the group order.  Instantiated at conductor 56 this is
  `1 · f · g = 12` with `f = resDeg p` and `g = 12 / resDeg p`: the reported
  "orbit purity 12/12".

* **Semiprime pair channel.**  For a product of two primes the type is governed by
  the translation-invariant counting law `#{(u,v) : T(uv) = t} = |S| · #{w : T w = t}`
  (`pair_channel_card`): the type of a semiprime is *uniformly* distributed over the
  same profile as the type of a prime.  Hence the semiprime channel carries exactly
  the same `1.7296` bits (`pair_channel_Units56`).

Both are stated for arbitrary finite abelian groups / translation-invariant finite
sample sets, so they apply verbatim to every rung of the ladder.
-/
import Mathlib
import Pythagorean.Degree12Composite

set_option maxRecDepth 40000

namespace Catalog.Pythagorean.Degree12Composite

open Finset

/-! ## Frobenius orbits in a finite abelian group -/

section Orbits

variable {A : Type*} [AddCommGroup A] [Fintype A] [DecidableEq A]

/-- The Frobenius orbit of `x` under translation by `g`: `{x, g+x, 2g+x, ...}`. -/
noncomputable def transOrbit (g x : A) : Finset A :=
  (Finset.range (addOrderOf g)).image (fun k => k • g + x)

omit [Fintype A] in
/-- **Orbit purity, local form**: every translation orbit has exactly `addOrderOf g`
elements (the residue degree), independently of the base point. -/
theorem card_transOrbit (g x : A) : (transOrbit g x).card = addOrderOf g := by
  rw [transOrbit, Finset.card_image_of_injOn, Finset.card_range]
  intro i hi j hj hij
  simp only [Finset.coe_range, Set.mem_Iio] at hi hj
  exact nsmul_injOn_Iio_addOrderOf hi hj (by simpa using add_right_cancel hij)

theorem self_mem_transOrbit (g x : A) : x ∈ transOrbit g x :=
  Finset.mem_image.2 ⟨0, Finset.mem_range.2 (addOrderOf_pos g), by simp⟩

theorem nsmul_add_mem_transOrbit (g x : A) (n : ℕ) : n • g + x ∈ transOrbit g x :=
  Finset.mem_image.2 ⟨n % addOrderOf g, Finset.mem_range.2 (Nat.mod_lt _ (addOrderOf_pos g)),
    by rw [mod_addOrderOf_nsmul]⟩

/-- Orbits are equal or disjoint: membership determines the orbit. -/
theorem transOrbit_eq_of_mem {g x y : A} (h : y ∈ transOrbit g x) :
    transOrbit g y = transOrbit g x := by
  rw [transOrbit, Finset.mem_image] at h
  obtain ⟨k, hk, rfl⟩ := h
  have hk' : k < addOrderOf g := Finset.mem_range.1 hk
  apply Finset.Subset.antisymm
  · intro z hz
    rw [transOrbit, Finset.mem_image] at hz
    obtain ⟨j, _, rfl⟩ := hz
    have hj : j • g + (k • g + x) = (j + k) • g + x := by rw [add_nsmul]; abel
    rw [hj]
    exact nsmul_add_mem_transOrbit g x (j + k)
  · intro z hz
    rw [transOrbit, Finset.mem_image] at hz
    obtain ⟨j, _, rfl⟩ := hz
    have hord : (addOrderOf g - k) • g + k • g = 0 := by
      rw [← add_nsmul, Nat.sub_add_cancel hk'.le, addOrderOf_nsmul_eq_zero]
    have hj : j • g + x = (j + (addOrderOf g - k)) • g + (k • g + x) := by
      rw [add_nsmul]
      have h' : (j • g + (addOrderOf g - k) • g) + (k • g + x)
          = j • g + ((addOrderOf g - k) • g + k • g) + x := by abel
      rw [h', hord]; abel
    rw [hj]
    exact nsmul_add_mem_transOrbit g (k • g + x) _

/-- The set of Frobenius orbits. -/
noncomputable def orbitSet (g : A) : Finset (Finset A) := Finset.univ.image (transOrbit g)

/-- **Orbit purity, global form / the `efg` law.**  The number of Frobenius orbits
times their common length `addOrderOf g` is the order of the group.  With `e = 1`
(unramified) this is exactly `e · f · g = n`. -/
theorem card_orbits_mul_addOrderOf (g : A) :
    (orbitSet g).card * addOrderOf g = Fintype.card A := by
  have hfib : ∀ o ∈ orbitSet g,
      ({x ∈ (Finset.univ : Finset A) | transOrbit g x = o}).card = addOrderOf g := by
    intro o ho
    obtain ⟨y, -, rfl⟩ := Finset.mem_image.1 ho
    have hset :
        {x ∈ (Finset.univ : Finset A) | transOrbit g x = transOrbit g y} = transOrbit g y := by
      ext x
      simp only [Finset.mem_filter, Finset.mem_univ, true_and]
      exact ⟨fun hx => hx ▸ self_mem_transOrbit g x, fun hx => transOrbit_eq_of_mem hx⟩
    rw [hset, card_transOrbit]
  have hsum := Finset.card_eq_sum_card_fiberwise
    (f := transOrbit g) (s := (Finset.univ : Finset A)) (t := orbitSet g)
    (fun x _ => Finset.mem_image_of_mem _ (mem_univ x))
  rw [Finset.card_univ] at hsum
  rw [hsum, Finset.sum_congr rfl hfib, Finset.sum_const, smul_eq_mul]

end Orbits

/-! ## Instantiation at `G⁺ = C₆ × C₂` -/

/-- Every Frobenius orbit on the 12 cosets of `Q(ζ₅₆)⁺` has exactly `resDeg`
elements: the residue degree of the prime.  (Orbit purity 12/12.) -/
theorem card_transOrbit_Gplus (g x : ZMod 6 × ZMod 2) :
    (transOrbit g x).card = resDeg (cls g) := by
  rw [card_transOrbit, addOrderOf_eq_resDeg_cls]

/-- **`e·f·g = 12` at conductor 56.**  For every Frobenius class the number of
primes above `p` times the residue degree equals the degree 12 of `Q(ζ₅₆)⁺`. -/
theorem efg_law (g : ZMod 6 × ZMod 2) :
    (orbitSet g).card * resDeg (cls g) = 12 := by
  rw [← addOrderOf_eq_resDeg_cls, card_orbits_mul_addOrderOf]
  rfl

private theorem resDeg_cls_pos' : ∀ g : ZMod 6 × ZMod 2, 0 < resDeg (cls g) := by decide

private theorem resDeg_cls_types : ∀ g : ZMod 6 × ZMod 2,
    resDeg (cls g) = 1 ∨ resDeg (cls g) = 2 ∨ resDeg (cls g) = 3 ∨ resDeg (cls g) = 6 := by decide

/-- The number of primes above `p` is `12 / f`. -/
theorem card_orbits_eq (g : ZMod 6 × ZMod 2) :
    (orbitSet g).card = 12 / resDeg (cls g) := by
  have h := efg_law g
  have hpos : 0 < resDeg (cls g) := resDeg_cls_pos' g
  exact (Nat.div_eq_of_eq_mul_left hpos h.symm).symm

/-- The four possible splitting shapes of an unramified prime in `Q(ζ₅₆)⁺`:
`(f, g) ∈ {(1,12), (2,6), (3,4), (6,2)}`. -/
theorem splitting_shapes (g : ZMod 6 × ZMod 2) :
    (resDeg (cls g), (orbitSet g).card) = (1, 12) ∨
    (resDeg (cls g), (orbitSet g).card) = (2, 6) ∨
    (resDeg (cls g), (orbitSet g).card) = (3, 4) ∨
    (resDeg (cls g), (orbitSet g).card) = (6, 2) := by
  have h := card_orbits_eq g
  have htype := resDeg_cls_types g
  rcases htype with h1 | h1 | h1 | h1 <;> rw [h, h1] <;> norm_num

/-! ## The semiprime pair channel -/

/-- **Translation-invariant pair law.**  If `S` is invariant under left translation
by each of its elements, then for any channel `φ` the number of ordered pairs whose
product has type `t` is `|S|` times the number of single elements of type `t`.
Consequently the "semiprime" channel `(u,v) ↦ φ(uv)` has exactly the same output
distribution — and hence the same entropy — as the prime channel `φ`. -/
theorem pair_channel_card {α T : Type*} [DecidableEq α] [DecidableEq T] [Monoid α]
    (S : Finset α) (φ : α → T) (t : T)
    (hinj : ∀ u ∈ S, Function.Injective (fun v => u * v))
    (hS : ∀ u ∈ S, S.image (fun v => u * v) = S) :
    ((S ×ˢ S).filter (fun p => φ (p.1 * p.2) = t)).card
      = S.card * (S.filter (fun w => φ w = t)).card := by
  rw [Finset.card_filter, Finset.sum_product]
  have key : ∀ u ∈ S, (∑ v ∈ S, if φ (u * v) = t then 1 else 0)
      = (S.filter (fun w => φ w = t)).card := by
    intro u hu
    rw [← Finset.card_filter]
    conv_rhs => rw [← hS u hu]
    rw [Finset.filter_image, Finset.card_image_of_injective _ (hinj u hu)]
  rw [Finset.sum_congr rfl key, Finset.sum_const, smul_eq_mul]

/-- `Units56` is invariant under translation by any of its elements. -/
theorem Units56_translation_invariant :
    ∀ u ∈ Units56, Units56.image (fun v => u * v) = Units56 := by decide

theorem Units56_mul_injective :
    ∀ u ∈ Units56, Function.Injective (fun v : ZMod 56 => u * v) := by
  intro u hu
  exact (mem_Units56_iff_isUnit.1 hu).mul_right_injective

/-- **The semiprime pair channel at conductor 56.**  For every type `d`, the number
of ordered pairs of reduced residues whose product has type `d` is `24 · typeCount d`
— the exact enumeration law.  The type profile of a semiprime `p·q` therefore
coincides with the Chebotarev profile `{1/12, 1/4, 1/6, 1/2}` of a single prime. -/
theorem pair_channel_Units56 (d : ℕ) :
    ((Units56 ×ˢ Units56).filter (fun p => resDeg (p.1 * p.2) = d)).card = 24 * typeCount d := by
  rw [pair_channel_card Units56 resDeg d Units56_mul_injective Units56_translation_invariant,
    card_Units56]
  rfl

/-- The semiprime channel is *balanced*: the pair-type density equals the
prime-type density, so the semiprime channel transmits exactly the same
`H(T) = 4/3 + (log₂ 3)/4` bits. -/
theorem pair_channel_density (d : ℕ) :
    (((Units56 ×ˢ Units56).filter (fun p => resDeg (p.1 * p.2) = d)).card : ℚ)
        / ((Units56 ×ˢ Units56).card : ℚ)
      = (typeCount d : ℚ) / (Units56.card : ℚ) := by
  rw [pair_channel_Units56, Finset.card_product, card_Units56]
  push_cast
  ring

end Catalog.Pythagorean.Degree12Composite