import Mathlib

/-!
# Universality of Transfer Functions Among Accumulation Points

This file develops a self-contained model of the statement

> For any `k ≥ 3` and `1 ≤ ℓ < k`, and any two accumulation points `α, β` in `Π^k_ℓ`,
> there exists a transfer function `f` such that `f α = β`.

## The model

We model the *level-`ℓ` `k`-adic set* `Π^k_ℓ` as the additive subgroup

`Pi k ℓ = ℓ · ℤ[1/k] = { ℓ · a / kᵐ : a ∈ ℤ, m ∈ ℕ } ⊆ ℝ`.

For `k ≥ 2` and `ℓ ≥ 1` this is a countable, dense-in-itself (perfect) subset of `ℝ`:
every real number — in particular every element of `Π^k_ℓ` — is an *accumulation point*
of `Π^k_ℓ` (`accPt_Pi`). Thus the "accumulation points in `Π^k_ℓ`" are exactly the
points of `Π^k_ℓ`.

A **transfer function** is a translation `x ↦ x + c` by an element `c ∈ Π^k_ℓ`
(predicate `IsTransfer`). Transfer functions preserve `Π^k_ℓ` (`IsTransfer.mapsTo`),
are continuous, form a monoid under composition (`isTransfer_id`, `IsTransfer.comp`),
and — this is the main result — act **simply transitively** on the accumulation points:

* `transfer_universality` : for any two accumulation points `α, β ∈ Π^k_ℓ` there is a
  transfer function `f` with `f α = β`;
* `transfer_unique` : this transfer function is unique.

The offset by `ℓ` is genuine: `Π^k_ℓ = ℓ · ℤ[1/k]`, a subgroup that depends on `ℓ`.
The hypotheses `3 ≤ k` and `ℓ < k` are the ranges requested in the mission statement.
The analytic content only needs `2 ≤ k` and `1 ≤ ℓ`; the strict bound `ℓ < k` is not
required, and is retained (as `hℓk`) purely to match the requested range.
-/

open Filter Topology

namespace TransferUniversality

/-- The **level-`ℓ` `k`-adic set** `Π^k_ℓ = ℓ · ℤ[1/k]`, i.e. the real numbers of the
form `ℓ · a / kᵐ` with `a ∈ ℤ` and `m ∈ ℕ`. -/
def Pi (k ℓ : ℕ) : Set ℝ := {x : ℝ | ∃ (a : ℤ) (m : ℕ), x = (ℓ : ℝ) * (a : ℝ) / (k : ℝ) ^ m}

variable {k ℓ : ℕ}

/-- `0` belongs to `Π^k_ℓ`. -/
lemma zero_mem_Pi : (0 : ℝ) ∈ Pi k ℓ := ⟨0, 0, by norm_num⟩

/-- `Π^k_ℓ` is closed under subtraction (it is an additive subgroup of `ℝ`). -/
lemma sub_mem_Pi (hk : k ≠ 0) {x y : ℝ} (hx : x ∈ Pi k ℓ) (hy : y ∈ Pi k ℓ) :
    x - y ∈ Pi k ℓ := by
  obtain ⟨a, m, rfl⟩ := hx
  obtain ⟨b, n, rfl⟩ := hy
  have hkne : (k : ℝ) ≠ 0 := by exact_mod_cast hk
  refine ⟨a * (k : ℤ) ^ n - b * (k : ℤ) ^ m, m + n, ?_⟩
  push_cast
  field_simp
  ring

/-- `Π^k_ℓ` is closed under addition. -/
lemma add_mem_Pi (hk : k ≠ 0) {x y : ℝ} (hx : x ∈ Pi k ℓ) (hy : y ∈ Pi k ℓ) :
    x + y ∈ Pi k ℓ := by
  obtain ⟨a, m, rfl⟩ := hx
  obtain ⟨b, n, rfl⟩ := hy
  have hkne : (k : ℝ) ≠ 0 := by exact_mod_cast hk
  refine ⟨a * (k : ℤ) ^ n + b * (k : ℤ) ^ m, m + n, ?_⟩
  push_cast
  field_simp
  ring

/-- Self-similarity: `Π^k_ℓ` is invariant under multiplication by `k`. -/
lemma smul_k_mem_Pi {x : ℝ} (hx : x ∈ Pi k ℓ) : (k : ℝ) * x ∈ Pi k ℓ := by
  obtain ⟨a, m, rfl⟩ := hx
  exact ⟨a * (k : ℤ), m, by push_cast; ring⟩

/-- `Π^k_ℓ` is dense in `ℝ` when `k ≥ 2` and `ℓ ≥ 1`. -/
lemma dense_Pi (hk : 2 ≤ k) (hℓ : 1 ≤ ℓ) : Dense (Pi k ℓ) := by
  refine' fun x => Metric.mem_closure_iff.2 _;
  intro ε hε;
  -- Choose m such that (ℓ : ℝ) / k^m < ε.
  obtain ⟨m, hm⟩ : ∃ m : ℕ, (ℓ : ℝ) / k^m < ε := by
    simpa using tendsto_const_nhds.div_atTop ( tendsto_pow_atTop_atTop_of_one_lt ( by norm_cast ) ) |> fun h => h.eventually ( gt_mem_nhds hε ) |> fun h => h.exists;
  refine' ⟨ ( ℓ : ℝ ) * ⌊x * k ^ m / ℓ⌋ / k ^ m, _, _ ⟩;
  · exact ⟨ ⌊x * k ^ m / ℓ⌋, m, by ring ⟩;
  · refine' abs_lt.mpr ⟨ _, _ ⟩;
    · rw [ lt_sub_comm, div_lt_iff₀ ] at * <;> first | positivity | nlinarith [ Int.floor_le ( x * k ^ m / ℓ ), Int.lt_floor_add_one ( x * k ^ m / ℓ ), show ( k : ℝ ) ^ m > 0 by positivity, mul_div_cancel₀ ( x * k ^ m ) ( by positivity : ( ℓ : ℝ ) ≠ 0 ) ] ;
    · rw [ sub_div', div_lt_iff₀ ] at * <;> first | positivity | nlinarith [ Int.floor_le ( x * k ^ m / ℓ ), Int.lt_floor_add_one ( x * k ^ m / ℓ ), show ( k : ℝ ) ^ m > 0 by positivity, mul_div_cancel₀ ( x * k ^ m ) ( by positivity : ( ℓ : ℝ ) ≠ 0 ) ] ;

/-- **Perfectness.** For `k ≥ 2` and `ℓ ≥ 1`, every real number is an accumulation point
of `Π^k_ℓ`. In particular every point of `Π^k_ℓ` is an accumulation point of `Π^k_ℓ`, so
the "accumulation points in `Π^k_ℓ`" are exactly the points of `Π^k_ℓ`. -/
lemma accPt_Pi (hk : 2 ≤ k) (hℓ : 1 ≤ ℓ) (x : ℝ) : AccPt x (𝓟 (Pi k ℓ)) := by
  rw [accPt_principal_iff_clusterPt, ← mem_closure_iff_clusterPt]
  exact (dense_Pi hk hℓ).diff_singleton x x

/-- A **transfer function** for `Π^k_ℓ` is a translation `x ↦ x + c` by an element
`c` of `Π^k_ℓ`. -/
def IsTransfer (k ℓ : ℕ) (f : ℝ → ℝ) : Prop := ∃ c ∈ Pi k ℓ, ∀ x, f x = x + c

/-- Transfer functions map `Π^k_ℓ` into itself. -/
lemma IsTransfer.mapsTo (hk : k ≠ 0) {f : ℝ → ℝ} (hf : IsTransfer k ℓ f) :
    Set.MapsTo f (Pi k ℓ) (Pi k ℓ) := by
  obtain ⟨c, hc, hfc⟩ := hf
  intro x hx
  rw [hfc x]
  exact add_mem_Pi hk hx hc

/-- The identity is a transfer function. -/
lemma isTransfer_id : IsTransfer k ℓ (id : ℝ → ℝ) :=
  ⟨0, zero_mem_Pi, by intro x; simp⟩

/-- Transfer functions are closed under composition. -/
lemma IsTransfer.comp (hk : k ≠ 0) {f g : ℝ → ℝ} (hf : IsTransfer k ℓ f)
    (hg : IsTransfer k ℓ g) : IsTransfer k ℓ (f ∘ g) := by
  obtain ⟨c, hc, hfc⟩ := hf
  obtain ⟨d, hd, hgd⟩ := hg
  refine ⟨d + c, add_mem_Pi hk hd hc, ?_⟩
  intro x
  simp only [Function.comp_apply, hfc, hgd]
  ring

/-- Transfer functions are continuous. -/
lemma IsTransfer.continuous {f : ℝ → ℝ} (hf : IsTransfer k ℓ f) : Continuous f := by
  obtain ⟨c, _, hfc⟩ := hf
  have : f = fun x => x + c := funext hfc
  rw [this]
  exact continuous_id.add continuous_const

/-- **Universality / transitivity of transfer functions.**
For any `k ≥ 3`, `1 ≤ ℓ < k`, and any two points `α, β ∈ Π^k_ℓ`, both `α` and `β` are
accumulation points of `Π^k_ℓ`, and there is a transfer function `f` — which maps `Π^k_ℓ`
into itself — with `f α = β`. -/
theorem transfer_universality (hk : 3 ≤ k) (hℓ : 1 ≤ ℓ) (hℓk : ℓ < k)
    {α β : ℝ} (hα : α ∈ Pi k ℓ) (hβ : β ∈ Pi k ℓ) :
    AccPt α (𝓟 (Pi k ℓ)) ∧ AccPt β (𝓟 (Pi k ℓ)) ∧
      ∃ f : ℝ → ℝ, IsTransfer k ℓ f ∧ f α = β ∧ Set.MapsTo f (Pi k ℓ) (Pi k ℓ) := by
  have hk2 : 2 ≤ k := by omega
  have hk0 : k ≠ 0 := by omega
  have _hℓk := hℓk
  have hT : IsTransfer k ℓ (fun x => x + (β - α)) :=
    ⟨β - α, sub_mem_Pi hk0 hβ hα, fun x => rfl⟩
  exact ⟨accPt_Pi hk2 hℓ α, accPt_Pi hk2 hℓ β, fun x => x + (β - α), hT, by ring,
    hT.mapsTo hk0⟩

/-- **Simple transitivity.** The transfer function carrying `α` to `β` is unique:
if two transfer functions agree at a single point, they are equal. -/
theorem transfer_unique {f g : ℝ → ℝ} (hf : IsTransfer k ℓ f) (hg : IsTransfer k ℓ g)
    {x : ℝ} (hx : f x = g x) : f = g := by
  obtain ⟨c, _, hfc⟩ := hf
  obtain ⟨d, _, hgd⟩ := hg
  rw [hfc x, hgd x] at hx
  have hcd : c = d := by linarith
  funext y
  rw [hfc y, hgd y, hcd]

end TransferUniversality