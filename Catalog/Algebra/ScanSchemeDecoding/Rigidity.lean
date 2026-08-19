import Algebra.ScanSchemeDecoding.Optimum

/-!
# Rigidity of the optimum, collision-freeness, and symmetry of the cost

The lower bound of `Algebra.ScanSchemeDecoding.Optimum` is not only sharp, it is
*rigid*: the tangent-line argument leaves a slack `(d)(d-1)/2` in each bucket, where
`d` is the deviation of the bucket size from `⌊N/m⌋`.  Since `d(d-1) = 0` only for
`d ∈ {0, 1}`, the optimum is attained **exactly** by the balanced size profiles.

## Main results

* `ScanSchemeDecoding.sum_triangle_eq_opt_iff` — rigidity at the level of size profiles.
* `ScanSchemeDecoding.ScanScheme.decodeCost_eq_opt_iff` — a scan scheme is cost-optimal
  iff every bucket has size `⌊N/m⌋` or `⌈N/m⌉`.
* `ScanSchemeDecoding.ScanScheme.decodeCost_eq_one_iff` — unit decoding cost everywhere
  is *equivalent* to injectivity of the bucket map (perfect hashing).
* `ScanSchemeDecoding.ScanScheme.exists_two_le_decodeCost` — fewer buckets than keys
  forces a key of cost `≥ 2`.
* `ScanSchemeDecoding.ScanScheme.decodeCost_perm_invariant`,
  `ScanSchemeDecoding.ScanScheme.decodeCost_relabel` — the total cost is invariant under
  the natural `Sym(α) × Sym(β)`-action, i.e. it is a function of the bucket-size
  partition alone.
-/

namespace ScanSchemeDecoding

open Finset

/-- **Rigidity of the pigeonhole optimum.**  A size profile realises the optimum iff
every bucket size deviates from the mean `⌊N/m⌋` by at most one *upwards* and not at
all downwards. -/
theorem sum_triangle_eq_opt_iff {m : ℕ} (hm : 0 < m) (f : Fin m → ℕ) (N : ℕ)
    (hf : ∑ i, f i = N) :
    ∑ i, triangle (f i) = triangleOpt N m ↔ ∀ i, N / m ≤ f i ∧ f i ≤ N / m + 1 := by
  classical
  constructor
  · intro hopt i
    have hnn : ∀ j ∈ (Finset.univ : Finset (Fin m)),
        0 ≤ (triangle (f j) : ℤ)
          - ((triangle (N / m) : ℤ) + (((N / m : ℕ) : ℤ) + 1) * ((f j : ℤ) - ((N / m : ℕ) : ℤ))) :=
      fun j _ => by linarith [triangle_tangent (N / m) (f j)]
    have hsum0 : ∑ j : Fin m, ((triangle (f j) : ℤ)
        - ((triangle (N / m) : ℤ)
          + (((N / m : ℕ) : ℤ) + 1) * ((f j : ℤ) - ((N / m : ℕ) : ℤ)))) = 0 := by
      rw [Finset.sum_sub_distrib, sum_tangent_eq hm f N hf, ← Nat.cast_sum, hopt]
      ring
    have hzero := (Finset.sum_eq_zero_iff_of_nonneg hnn).mp hsum0 i (Finset.mem_univ i)
    have h2k : (2 : ℤ) * triangle (f i) = (f i : ℤ) * ((f i : ℤ) + 1) := by
      exact_mod_cast congrArg (fun n : ℕ => (n : ℤ)) (two_mul_triangle (f i))
    have h2q : (2 : ℤ) * triangle (N / m) = ((N / m : ℕ) : ℤ) * (((N / m : ℕ) : ℤ) + 1) := by
      exact_mod_cast congrArg (fun n : ℕ => (n : ℤ)) (two_mul_triangle (N / m))
    have hd : ((f i : ℤ) - ((N / m : ℕ) : ℤ)) * ((f i : ℤ) - ((N / m : ℕ) : ℤ) - 1) = 0 := by
      linear_combination 2 * hzero - h2k + h2q
    rcases mul_eq_zero.mp hd with h | h
    · have hcast : (f i : ℤ) = ((N / m : ℕ) : ℤ) := by linarith
      have hnat : f i = N / m := by exact_mod_cast hcast
      exact ⟨hnat.ge, by rw [hnat]; exact Nat.le_succ _⟩
    · have hcast : (f i : ℤ) = ((N / m : ℕ) : ℤ) + 1 := by linarith
      have hnat : f i = N / m + 1 := by exact_mod_cast hcast
      exact ⟨by rw [hnat]; exact Nat.le_succ _, hnat.le⟩
  · intro hb
    have hcast : ∀ i : Fin m,
        triangle (f i) = triangle (N / m) + (f i - N / m) * (N / m + 1) := by
      intro i
      rcases Nat.eq_or_lt_of_le (hb i).1 with h | h
      · rw [← h]
        simp
      · have hub := (hb i).2
        have hfi : f i = N / m + 1 := by omega
        rw [hfi, triangle_succ]
        simp
    have hsplit : ∑ i : Fin m, f i = ∑ i : Fin m, (N / m + (f i - N / m)) :=
      Finset.sum_congr rfl (fun i _ => (Nat.add_sub_cancel' (hb i).1).symm)
    rw [Finset.sum_add_distrib] at hsplit
    simp only [Finset.sum_const, Finset.card_univ, Fintype.card_fin, smul_eq_mul] at hsplit
    have hsumc : ∑ i : Fin m, (f i - N / m) = N % m := by
      have h1 : m * (N / m) + ∑ i : Fin m, (f i - N / m) = m * (N / m) + N % m := by
        rw [← hsplit, hf]
        exact (Nat.div_add_mod N m).symm
      exact Nat.add_left_cancel h1
    rw [Finset.sum_congr rfl (fun i _ => hcast i), Finset.sum_add_distrib, ← Finset.sum_mul,
      hsumc, triangleOpt_eq hm]
    simp

namespace ScanScheme

variable {α β : Type*} [Fintype α] [LinearOrder α] [Fintype β] [DecidableEq β]
variable (S : ScanScheme α β)

/-- **Structure of the optimal schemes.**  A scan scheme decodes at optimal total cost
iff its bucket loads are balanced to within one key. -/
theorem decodeCost_eq_opt_iff (hβ : 0 < Fintype.card β) :
    ∑ x, S.decodeCost x = triangleOpt (Fintype.card α) (Fintype.card β) ↔
      ∀ b : β, Fintype.card α / Fintype.card β ≤ (S.fiber b).card ∧
        (S.fiber b).card ≤ Fintype.card α / Fintype.card β + 1 := by
  classical
  set m := Fintype.card β with hm
  let e : β ≃ Fin m := Fintype.equivFin β
  have hsum : ∑ i : Fin m, (S.fiber (e.symm i)).card = Fintype.card α := by
    rw [Equiv.sum_comp e.symm (fun b => (S.fiber b).card)]
    exact S.sum_fiber_card
  have htri : ∑ i : Fin m, triangle (S.fiber (e.symm i)).card
      = ∑ b, triangle (S.fiber b).card :=
    Equiv.sum_comp e.symm (fun b => triangle (S.fiber b).card)
  have hiff := sum_triangle_eq_opt_iff hβ (fun i => (S.fiber (e.symm i)).card)
    (Fintype.card α) hsum
  rw [htri] at hiff
  rw [S.decodeCost_eq, hiff]
  constructor
  · intro h b
    have := h (e b)
    simpa using this
  · intro h i
    exact h (e.symm i)

omit [Fintype β] in
/-- **Perfect hashing.**  Every key decodes in one step iff the bucket map is injective. -/
theorem decodeCost_eq_one_iff : (∀ x, S.decodeCost x = 1) ↔ Function.Injective S.bucket := by
  classical
  constructor
  · intro h x y hxy
    have hx : S.idx x = 0 := by have := h x; simp [decodeCost] at this; omega
    have hy : S.idx y = 0 := by have := h y; simp [decodeCost] at this; omega
    have : S.encode x = S.encode y := by simp [encode, hxy, hx, hy]
    exact S.encode_injective this
  · intro hinj x
    have hfib : S.fiber (S.bucket x) = {x} := by
      ext y
      constructor
      · intro hy
        have : S.bucket y = S.bucket x := by simpa using hy
        simp [hinj this]
      · intro hy
        have : y = x := by simpa using hy
        simp [this]
    have hcard : (S.fiber (S.bucket x)).card = 1 := by rw [hfib]; simp
    have := S.idx_lt_card x
    rw [hcard] at this
    simp [decodeCost]
    omega

/-- **Failure analysis.**  Fewer buckets than keys forces a key that costs at least two
comparisons: no scheme with compression can be collision-free. -/
theorem exists_two_le_decodeCost (h : Fintype.card β < Fintype.card α) :
    ∃ x, 2 ≤ S.decodeCost x := by
  classical
  by_contra hcon
  push_neg at hcon
  have hone : ∀ x, S.decodeCost x = 1 := by
    intro x
    have h1 : 1 ≤ S.decodeCost x := Nat.le_add_left 1 _
    have h2 := hcon x
    omega
  have hinj := (S.decodeCost_eq_one_iff).mp hone
  have := Fintype.card_le_of_injective S.bucket hinj
  omega

/-- The total decoding cost only depends on the bucket-size profile: it is invariant
under relabelling the keys by an arbitrary permutation. -/
theorem decodeCost_perm_invariant (sigma : α ≃ α) :
    ∑ x, (⟨S.bucket ∘ sigma⟩ : ScanScheme α β).decodeCost x = ∑ x, S.decodeCost x := by
  classical
  rw [ScanScheme.decodeCost_eq, ScanScheme.decodeCost_eq]
  refine Finset.sum_congr rfl (fun b _ => ?_)
  congr 1
  apply Finset.card_bij' (fun x _ => sigma x) (fun y _ => sigma.symm y)
  · intro x hx
    simpa [ScanScheme.fiber] using hx
  · intro y hy
    have : S.bucket y = b := by simpa using hy
    simpa [ScanScheme.fiber, Function.comp] using this
  · intro x _; simp
  · intro y _; simp

/-- The total decoding cost is invariant under relabelling the buckets. -/
theorem decodeCost_relabel {β' : Type*} [Fintype β'] [DecidableEq β'] (e : β ≃ β') :
    ∑ x, (⟨fun x => e (S.bucket x)⟩ : ScanScheme α β').decodeCost x = ∑ x, S.decodeCost x := by
  classical
  rw [ScanScheme.decodeCost_eq, ScanScheme.decodeCost_eq]
  rw [← Equiv.sum_comp e (fun b' => triangle ((⟨fun x => e (S.bucket x)⟩ :
    ScanScheme α β').fiber b').card)]
  refine Finset.sum_congr rfl (fun b _ => ?_)
  congr 2
  ext x
  simp [ScanScheme.fiber]

end ScanScheme

end ScanSchemeDecoding