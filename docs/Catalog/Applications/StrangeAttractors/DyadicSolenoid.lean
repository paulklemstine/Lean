/-
# Strange Attractors as Algebraic Objects — II. The Dyadic Solenoid Invariant

The **dyadic solenoid** is the inverse limit of the doubling map of the circle,

      S¹  ⟵×2—  S¹  ⟵×2—  S¹  ⟵  ⋯ .

It is the simplest "strange" attractor that is genuinely an inverse limit of
finite/1-dimensional pieces (it appears as the Smale solenoid attractor and as a
cross-section model of Lorenz-type flows).  Its first Čech cohomology is the
*direct limit* of the cohomologies of the circles under the maps induced by the
doubling map, namely

      H¹(solenoid) ≅ colim( ℤ —×2→ ℤ —×2→ ⋯ ) ≅ ℤ[1/2],

the additive group of **dyadic rationals**.  This file makes that group precise
as an `AddSubgroup ℚ` and proves the two facts that make it an honest *algebraic
invariant of chaos*:

## Main results

* `Dyadic`                  — the dyadic rationals `ℤ[1/2] ≤ ℚ`.
* `Dyadic.inv_two_pow_mem`  — every `1/2ⁿ` is dyadic.
* `Dyadic.two_divisible`    — **multiplication by `2` is surjective on `Dyadic`**:
    the doubling map is *invertible* on cohomology (the localization/colimit
    signature that no finite graph's `H¹` possesses).
* `Dyadic.not_fg`           — **`ℤ[1/2]` is not finitely generated**.  Hence the
    solenoid is not homotopy equivalent to any finite directed graph, whose first
    cohomology is always a finitely generated abelian group.  This is the precise
    sense in which the attractor is *strictly more complex* than its finite
    approximants.

This is the **cross-domain bridge** target: a topological/dynamical invariant
(Čech `H¹`) is computed and distinguished purely by abelian-group algebra.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): The inverse limit of the doubling map is NOT
homotopy equivalent to any finite graph, and this can be certified algebraically
because its `H¹ = ℤ[1/2]` is not finitely generated.
Experiment (Experimenter): Modelled `ℤ[1/2]` as the subgroup of `ℚ` of elements
with a power-of-two denominator.  Proved (a) `2·_` is onto it (division by two is
internal), (b) it is not finitely generated, by trapping any finite generating
set inside a fixed `boundedDen N` (denominator dividing `2ᴺ`) and exhibiting the
escapee `1/2^{N+1}`.
Analysis (Analyst): The whole obstruction is *unbounded denominators*; finite
generation forces a uniform denominator bound, which the dyadic tower violates.
"True and moderately hard": the work is the directed-union bound on a finite set.
Critique (Critic): Not vacuous — `not_fg` is a strict negation with an explicit
witness; `two_divisible` is a genuine surjectivity statement, not `rfl`.  The
contrast with finite graphs (whose `H¹` is f.g.) is what gives it teeth.
Synthesis (PI): `ℤ[1/2]` is the certificate: chaos ⇒ non-finite-generation.
-- !-- Lab Notes -- !--
-/
import Mathlib

namespace StrangeAttractors

open scoped Classical

/-- The dyadic rationals `ℤ[1/2]`, as the additive subgroup of `ℚ` consisting of
rationals `q` such that `2ᵏ · q` is an integer for some `k`.  This is the first
Čech cohomology group of the dyadic solenoid. -/
def Dyadic : AddSubgroup ℚ where
  carrier := {q : ℚ | ∃ (k : ℕ) (m : ℤ), (m : ℚ) = 2 ^ k * q}
  add_mem' := by
    rintro a b ⟨k₁, m₁, h₁⟩ ⟨k₂, m₂, h₂⟩
    refine ⟨k₁ + k₂, 2 ^ k₂ * m₁ + 2 ^ k₁ * m₂, ?_⟩
    push_cast
    rw [pow_add]
    have e₁ : (2 : ℚ) ^ k₂ * (m₁ : ℚ) = 2 ^ k₂ * (2 ^ k₁ * a) := by rw [h₁]
    have e₂ : (2 : ℚ) ^ k₁ * (m₂ : ℚ) = 2 ^ k₁ * (2 ^ k₂ * b) := by rw [h₂]
    rw [e₁, e₂]; ring
  zero_mem' := ⟨0, 0, by simp⟩
  neg_mem' := by
    rintro a ⟨k, m, h⟩
    exact ⟨k, -m, by push_cast; rw [h]; ring⟩

/-- Unfolding membership in `Dyadic`. -/
theorem mem_Dyadic {q : ℚ} : q ∈ Dyadic ↔ ∃ (k : ℕ) (m : ℤ), (m : ℚ) = 2 ^ k * q :=
  Iff.rfl

/-- Every `1/2ⁿ` is a dyadic rational. -/
theorem Dyadic.inv_two_pow_mem (n : ℕ) : (1 / 2 ^ n : ℚ) ∈ Dyadic := by
  refine ⟨n, 1, ?_⟩
  have : (2 : ℚ) ^ n ≠ 0 := by positivity
  push_cast
  field_simp

/-- **Division by two is internal to the dyadic rationals**: multiplication by
`2` is surjective onto `Dyadic`.  Equivalently, the map induced by the doubling
map on `H¹` is invertible — the colimit/localization signature of the solenoid.-/
theorem Dyadic.two_divisible : ∀ q ∈ Dyadic, ∃ r ∈ Dyadic, 2 * r = q := by
  rintro q ⟨k, m, h⟩
  refine ⟨q / 2, ⟨k + 1, m, ?_⟩, by ring⟩
  rw [pow_succ]
  have : (2 : ℚ) ^ k * 2 * (q / 2) = 2 ^ k * q := by ring
  rw [this, h]

/-- Auxiliary subgroup: rationals whose denominator divides `2ᴺ`, i.e. `2ᴺ · q`
is an integer.  These are the dyadics of *bounded* level. -/
def boundedDen (N : ℕ) : AddSubgroup ℚ where
  carrier := {q : ℚ | ∃ m : ℤ, (m : ℚ) = 2 ^ N * q}
  add_mem' := by
    rintro a b ⟨m₁, h₁⟩ ⟨m₂, h₂⟩
    exact ⟨m₁ + m₂, by push_cast; rw [h₁, h₂]; ring⟩
  zero_mem' := ⟨0, by simp⟩
  neg_mem' := by
    rintro a ⟨m, h⟩
    exact ⟨-m, by push_cast; rw [h]; ring⟩

theorem mem_boundedDen {N : ℕ} {q : ℚ} :
    q ∈ boundedDen N ↔ ∃ m : ℤ, (m : ℚ) = 2 ^ N * q := Iff.rfl

/-- The bounded-denominator subgroups grow with the bound. -/
theorem boundedDen_mono {k N : ℕ} (h : k ≤ N) : boundedDen k ≤ boundedDen N := by
  rintro q ⟨m, hm⟩
  refine ⟨2 ^ (N - k) * m, ?_⟩
  push_cast
  rw [hm]
  rw [← mul_assoc, ← pow_add, Nat.sub_add_cancel h]

/-
A finite set of dyadic rationals has a uniform denominator bound.
-/
theorem exists_uniform_bound {S : Set ℚ} (hS : S.Finite) (hsub : S ⊆ (Dyadic : Set ℚ)) :
    ∃ N, S ⊆ (boundedDen N : Set ℚ) := by
  obtain ⟨N, hN⟩ : ∃ N : ℕ, ∀ q ∈ S, ∃ k : ℕ, k ≤ N ∧ q ∈ boundedDen k := by
    exact ⟨ hS.toFinset.sup fun q => if hq : q ∈ S then Classical.choose ( mem_Dyadic.mp ( hsub hq ) ) else 0, fun q hq => ⟨ if hq' : q ∈ S then Classical.choose ( mem_Dyadic.mp ( hsub hq' ) ) else 0, Finset.le_sup ( f := fun q => if hq' : q ∈ S then Classical.choose ( mem_Dyadic.mp ( hsub hq' ) ) else 0 ) ( hS.mem_toFinset.mpr hq ), by simpa [ hq ] using Classical.choose_spec ( mem_Dyadic.mp ( hsub hq ) ) ⟩ ⟩;
  exact ⟨ N, fun q hq => by obtain ⟨ k, hk₁, hk₂ ⟩ := hN q hq; exact boundedDen_mono hk₁ hk₂ ⟩

/-- The escapee: `1/2^{N+1}` has denominator `2^{N+1}` which does not divide
`2ᴺ`, so it is not in `boundedDen N`. -/
theorem inv_two_pow_not_mem_boundedDen (N : ℕ) :
    (1 / 2 ^ (N + 1) : ℚ) ∉ boundedDen N := by
  rintro ⟨m, hm⟩
  rw [pow_succ] at hm
  have h2 : (2 : ℚ) ^ N ≠ 0 := by positivity
  -- hm : (m : ℚ) = 2^N * (1 / (2^N * 2)) = 1/2
  have : (m : ℚ) = 1 / 2 := by
    rw [hm]; field_simp
  have : (2 * m : ℤ) = 1 := by
    have := this
    have h2m : ((2 * m : ℤ) : ℚ) = 1 := by push_cast; rw [this]; ring
    exact_mod_cast h2m
  omega

/-- **The dyadic rationals `ℤ[1/2]` are not finitely generated.**  Therefore the
dyadic solenoid (the doubling-map inverse limit) is not homotopy equivalent to
any finite directed graph, whose first cohomology is finitely generated. -/
theorem Dyadic.not_fg : ¬ (Dyadic.FG) := by
  rw [AddSubgroup.fg_iff]
  rintro ⟨S, hclose, hfin⟩
  obtain ⟨N, hN⟩ := exists_uniform_bound hfin (by
    rw [← hclose]; exact AddSubgroup.subset_closure)
  -- closure S ≤ boundedDen N, since boundedDen N is a subgroup containing S
  have hsub : Dyadic ≤ boundedDen N := by
    rw [← hclose]
    exact AddSubgroup.closure_le _ |>.mpr hN
  have hmem : (1 / 2 ^ (N + 1) : ℚ) ∈ Dyadic := Dyadic.inv_two_pow_mem (N + 1)
  exact inv_two_pow_not_mem_boundedDen N (hsub hmem)

end StrangeAttractors