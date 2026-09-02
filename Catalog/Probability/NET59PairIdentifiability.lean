import Probability.NET59LosslessIdentifiability

/-!
# NET-59, round 4: pair ablations identify what solo ablations cannot

`Probability.NET59NonIdentifiability` produced a family of stacks whose **solo**
ablation profile is identically zero while the joint pruning cost is an
arbitrary `t ∈ [0,1]`: the masking is done by a downstream layer that erases
every upstream difference.  `Probability.NET59DobrushinMasking` showed the
phenomenon is generic (contraction damps solo damage exponentially) and
`Probability.NET59LosslessIdentifiability` showed the exact converse (a lossless
suffix makes solo measurement faithful).

This file closes the loop by proving the *positive* half of direction **D2**:
the masking layer can itself be put into the ablation set, and as soon as it is,
the hidden per-layer damage is recovered **exactly**.

Main results.

* `pair_diff_eq_point_of_lossless_after_ablation` — the general mechanism.  If
  ablating layer `k` turns the suffix after an earlier layer `j` lossless, then
  the *differential* pair cost (layer `j` ablated on top of layer `k`) equals the
  point cost of layer `j` at its intact upstream state.  Ablating one extra layer
  converts an uninformative measurement into an exact one.
* `witness_pair_cost` — on the non-identifiability witness the differential pair
  cost of any transparent layer with the tail layer is exactly the pruning
  strength `t`, while every solo cost is `0`.
* `pair_arity_is_enough` / `net59_pair_identifiability` — at the measured depth
  `24`: two stacks whose solo profiles are *identical and identically zero* have
  differential pair costs `0.017` and `1` at every transparent layer.  Arity `2`
  therefore separates exactly the pair of stacks that arity `1` provably cannot,
  so the NET-59 "next step" (pairwise/joint tail ablations) is not a refinement
  of the experiment but the minimal experiment with any resolving power at all.
* `solo_arity_is_not_enough` — the matching negative statement, packaged from the
  previous round, so that the dichotomy is visible in one place.
-/

namespace Catalog.Probability.NET59

open Finset

variable {α : Type*} [Fintype α] [DecidableEq α]

/-! ## 1. Lossless bookkeeping -/

/-- The identity channel is the lossless channel of the identity relabelling. -/
theorem permK_refl_eq_idK : permK (Equiv.refl α) = (idK : Kern α α) := rfl

/-- A block of identity layers is a block of lossless layers. -/
theorem replicate_idK_eq_map_permK (m : ℕ) :
    List.replicate m (idK : Kern α α) = (List.replicate m (Equiv.refl α)).map permK := by
  rw [List.map_replicate, permK_refl_eq_idK]

/-- A block of identity layers followed by one more identity layer is lossless. -/
theorem replicate_idK_snoc_eq_map_permK (m : ℕ) :
    List.replicate m (idK : Kern α α) ++ [idK]
      = (List.replicate m (Equiv.refl α) ++ [Equiv.refl α]).map permK := by
  rw [List.map_append, ← replicate_idK_eq_map_permK]
  simp [permK_refl_eq_idK]

/-! ## 2. Pair ablations -/

/-- Ablate two layers at once: layer `k` is replaced by `q` and layer `j` by `p`. -/
def pairAblate (F : List (Kern α α)) (j k : ℕ) (p q : Kern α α) : List (Kern α α) :=
  (F.set k q).set j p

omit [DecidableEq α] in
@[simp] theorem pairAblate_length (F : List (Kern α α)) (j k : ℕ) (p q : Kern α α) :
    (pairAblate F j k p q).length = F.length := by
  simp [pairAblate]

omit [DecidableEq α] in
/-- Ablating a later layer does not change the state entering an earlier one. -/
theorem upstream_set_of_lt (F : List (Kern α α)) {j k : ℕ} (hjk : j ≤ k) (q : Kern α α)
    (μ : Dist α) : upstream (F.set k q) j μ = upstream F j μ := by
  unfold upstream
  congr 1
  refine List.ext_getElem (by simp) fun i h1 h2 => ?_
  have hij : i < j := by
    have h1' := h1
    simp only [List.length_take] at h1'
    omega
  simp only [List.getElem_take]
  rw [List.getElem_set_ne (show k ≠ i by omega)]

/-- **The pair mechanism.**  Suppose ablating layer `k` makes everything after an
earlier layer `j` lossless.  Then the extra damage caused by additionally
ablating layer `j` is *exactly* the point cost of layer `j`, measured at the
intact upstream state.

So a single companion ablation converts the (provably uninformative) solo
measurement at `j` into an exact measurement of the per-layer damage. -/
theorem pair_diff_eq_point_of_lossless_after_ablation (F : List (Kern α α)) (j k : ℕ)
    (f p q : Kern α α) (hjk : j < k) (hj : j < F.length) (hf : F[j] = f)
    (E : List (α ≃ α)) (hdown : (F.set k q).drop (j + 1) = E.map permK) (μ : Dist α) :
    tv (chain (F.set k q) μ) (chain (pairAblate F j k p q) μ)
      = tv (push f (upstream F j μ)) (push p (upstream F j μ)) := by
  have hj' : j < (F.set k q).length := by simpa using hj
  have hf' : (F.set k q)[j] = f := by
    rw [List.getElem_set_ne (by omega)]; exact hf
  have hmain := solo_eq_point_of_lossless (F.set k q) j f p hj' hf' E hdown μ
  rw [upstream_set_of_lt F hjk.le q μ] at hmain
  unfold pairAblate
  exact hmain

/-! ## 3. Running the pair experiment on the witness family -/

/-- A block of identity layers transports any law unchanged (the general-alphabet
form of `chain_replicate_idK`). -/
theorem chain_replicate_idK_general (m : ℕ) (μ : Dist α) :
    chain (List.replicate m (idK : Kern α α)) μ = μ := by
  induction m generalizing μ with
  | zero => simp
  | succ m ih => rw [List.replicate_succ, chain_cons, push_idK, ih]

/-- A block of identity layers with one constant layer inserted outputs that
layer's law, whatever the input. -/
theorem chain_replicate_idK_set (m j : ℕ) (hj : j < m) (c : Dist α) (μ : Dist α) :
    chain ((List.replicate m (idK : Kern α α)).set j (constK c)) μ = c := by
  have hlen : j < (List.replicate m (idK : Kern α α)).length := by simpa using hj
  rw [List.set_eq_take_cons_drop _ hlen, chain_append, List.take_replicate,
    chain_replicate_idK_general, chain_cons, push_constK, List.drop_replicate,
    chain_replicate_idK_general]

/-- Ablating the final (forgetful) layer of the witness stack to the identity
turns the whole stack into a transparent one. -/
theorem chain_fullStack_set_last (n : ℕ) (μ : Dist (Fin 2)) :
    chain ((fullStack n).set n idK) μ = μ := by
  have hset : (fullStack n).set n idK = List.replicate n idK ++ [idK] := by
    rw [fullStack, List.set_append_right _ _ (by simp)]
    simp
  rw [hset, chain_append, chain_replicate_idK_general, chain_cons, chain_nil, push_idK]

/-- The pair ablation `{j, n}` of the witness stack outputs `Bernoulli(t)`. -/
theorem chain_pairAblate_witness (n : ℕ) (t : ℚ) (h0 : 0 ≤ t) (h1 : t ≤ 1) (j : ℕ) (hj : j < n)
    (μ : Dist (Fin 2)) :
    chain (pairAblate (fullStack n) j n (constK (bern t h0 h1)) idK) μ = bern t h0 h1 := by
  have hset : (fullStack n).set n idK = List.replicate n idK ++ [idK] := by
    rw [fullStack, List.set_append_right _ _ (by simp)]
    simp
  have hpair : pairAblate (fullStack n) j n (constK (bern t h0 h1)) idK
      = (List.replicate n idK).set j (constK (bern t h0 h1)) ++ [idK] := by
    rw [pairAblate, hset, List.set_append_left]
    simpa using hj
  rw [hpair, chain_append, chain_replicate_idK_set _ _ hj, chain_cons, chain_nil, push_idK]

/-- **The pair experiment recovers the hidden damage.**  On the witness family the
differential pair cost of a transparent layer `j` together with the tail layer is
exactly the pruning strength `t` — the layer's true point cost — even though its
solo cost is `0`. -/
theorem witness_pair_cost (n : ℕ) (t : ℚ) (h0 : 0 ≤ t) (h1 : t ≤ 1) (j : ℕ) (hj : j < n) :
    tv (chain ((fullStack n).set n idK) d0)
        (chain (pairAblate (fullStack n) j n (constK (bern t h0 h1)) idK) d0) = t := by
  rw [chain_fullStack_set_last, chain_pairAblate_witness n t h0 h1 j hj, d0, tv_bern,
    zero_sub, abs_neg, abs_of_nonneg h0]

/-- The same number, obtained instead from the general pair mechanism: the
witness's suffix becomes lossless once the tail layer is ablated, so
`pair_diff_eq_point_of_lossless_after_ablation` applies and returns the point
cost `t`.  The two routes agree, which certifies that the explicit computation
is an instance of the general theorem. -/
theorem witness_pair_cost_via_mechanism (n : ℕ) (t : ℚ) (h0 : 0 ≤ t) (h1 : t ≤ 1) (j : ℕ)
    (hj : j < n) :
    tv (chain ((fullStack n).set n idK) d0)
        (chain (pairAblate (fullStack n) j n (constK (bern t h0 h1)) idK) d0)
      = tv (push idK (upstream (fullStack n) j d0))
          (push (constK (bern t h0 h1)) (upstream (fullStack n) j d0)) := by
  have hj' : j < (fullStack n).length := by simp; omega
  have hf : (fullStack n)[j] = idK := by
    simp only [fullStack]
    rw [List.getElem_append_left (by simpa using hj)]
    simp
  have hset : (fullStack n).set n idK = List.replicate n idK ++ [idK] := by
    rw [fullStack, List.set_append_right _ _ (by simp)]
    simp
  have hdown : ((fullStack n).set n idK).drop (j + 1)
      = (List.replicate (n - (j + 1)) (Equiv.refl (Fin 2))
          ++ [Equiv.refl (Fin 2)]).map permK := by
    rw [hset, List.drop_append_of_le_length (by simpa using hj), List.drop_replicate,
      replicate_idK_snoc_eq_map_permK]
  exact pair_diff_eq_point_of_lossless_after_ablation (fullStack n) j n idK
    (constK (bern t h0 h1)) idK hj hj' hf _ hdown d0

/-! ## 4. The arity dichotomy at the measured depth -/

/-- **Arity `2` suffices.**  Two depth-`24` stacks with identical, identically
zero solo profiles are separated at *every* transparent layer by the differential
pair cost with the tail layer: `0.017` for one, `1` for the other.

Compare `net59_nonidentifiability`, which says arity `1` separates them nowhere.
The minimal informative ablation arity for this family is therefore exactly
`2`. -/
theorem net59_pair_identifiability :
    ∃ (F : List (Kern (Fin 2) (Fin 2))) (p q : Kern (Fin 2) (Fin 2)),
      F.length = 24 ∧
      (∀ j, j < 23 →
        tv (chain F d0) (chain (F.set j p) d0) = 0 ∧
        tv (chain F d0) (chain (F.set j q) d0) = 0) ∧
      (∀ j, j < 23 →
        tv (chain (F.set 23 idK) d0) (chain (pairAblate F j 23 p idK) d0)
          = net59JointMeasured ∧
        tv (chain (F.set 23 idK) d0) (chain (pairAblate F j 23 q idK) d0) = 1) := by
  have h0 : (0 : ℚ) ≤ net59JointMeasured := by norm_num [net59JointMeasured]
  have h1 : net59JointMeasured ≤ 1 := by norm_num [net59JointMeasured]
  refine ⟨fullStack 23, constK (bern net59JointMeasured h0 h1), constK (bern 1 zero_le_one le_rfl),
    by simp, fun j hj => ⟨?_, ?_⟩, fun j hj => ⟨?_, ?_⟩⟩
  · have hlayer : prunedLayer 23 net59JointMeasured h0 h1 j
        = constK (bern net59JointMeasured h0 h1) := by simp [prunedLayer, hj]
    have := soloCost_eq_zero 23 net59JointMeasured h0 h1 j (by omega)
    rwa [hlayer] at this
  · have hlayer : prunedLayer 23 1 zero_le_one le_rfl j = constK (bern 1 zero_le_one le_rfl) := by
      simp [prunedLayer, hj]
    have := soloCost_eq_zero 23 1 zero_le_one le_rfl j (by omega)
    rwa [hlayer] at this
  · exact witness_pair_cost 23 net59JointMeasured h0 h1 j hj
  · exact witness_pair_cost 23 1 zero_le_one le_rfl j hj

/-- **Arity `1` does not suffice** (restated from the previous round for the
dichotomy).  The two stacks separated above have literally the same solo
profile. -/
theorem solo_arity_is_not_enough :
    ∃ (F P Q : List (Kern (Fin 2) (Fin 2))),
      F.length = 24 ∧ P.length = 24 ∧ Q.length = 24 ∧
      (∀ j, j < 24 → tv (chain F d0) (chain (F.set j (P[j]!)) d0) = 0) ∧
      (∀ j, j < 24 → tv (chain F d0) (chain (F.set j (Q[j]!)) d0) = 0) ∧
      tv (chain F d0) (chain P d0) = net59JointMeasured ∧
      tv (chain F d0) (chain Q d0) = 1 :=
  net59_nonidentifiability

/-- **The arity dichotomy, packaged.**  There is a depth-`24` intact stack and two
prunings of it such that: every solo ablation of either pruning is invisible,
yet every pair ablation that includes the tail layer separates them by the full
gap `1 - 0.017`. -/
theorem net59_minimal_informative_arity :
    ∃ (F : List (Kern (Fin 2) (Fin 2))) (p q : Kern (Fin 2) (Fin 2)),
      F.length = 24 ∧
      (∀ j, j < 23 →
        tv (chain F d0) (chain (F.set j p) d0) = tv (chain F d0) (chain (F.set j q) d0)) ∧
      (∀ j, j < 23 →
        tv (chain (F.set 23 idK) d0) (chain (pairAblate F j 23 q idK) d0)
          - tv (chain (F.set 23 idK) d0) (chain (pairAblate F j 23 p idK) d0)
          = 983 / 1000) := by
  obtain ⟨F, p, q, hlen, hsolo, hpair⟩ := net59_pair_identifiability
  refine ⟨F, p, q, hlen, fun j hj => ?_, fun j hj => ?_⟩
  · rw [(hsolo j hj).1, (hsolo j hj).2]
  · rw [(hpair j hj).1, (hpair j hj).2]
    norm_num [net59JointMeasured]

/-! ## 5. Lab notes

Exact values on the depth-`24` witness (`t` the pruning strength):

```
solo cost   at any layer j < 23, either pruning : 0
pair cost   {j, 23}, t = 0.017                  : 17/1000
pair cost   {j, 23}, t = 1                      : 1
separation achieved by arity 2                  : 983/1000
separation achieved by arity 1                  : 0
```

The `t = 1` line is the essential one: a stack in which pruning is *maximally*
destructive is, to a solo-ablation experiment, indistinguishable from one in
which it costs `1.7%`; one extra simultaneous ablation makes the difference
visible in full. -/

section LabNotes

/-- Pair cost of the depth-`11` witness at the measured strength. -/
example (j : ℕ) (hj : j < 10) :
    tv (chain ((fullStack 10).set 10 idK) d0)
      (chain (pairAblate (fullStack 10) j 10 (constK (bern labT labT_nonneg labT_le_one)) idK) d0)
      = labT :=
  witness_pair_cost 10 labT labT_nonneg labT_le_one j hj

/-- Pair cost of the depth-`11` witness at maximal strength. -/
example (j : ℕ) (hj : j < 10) :
    tv (chain ((fullStack 10).set 10 idK) d0)
      (chain (pairAblate (fullStack 10) j 10 (constK (bern 1 zero_le_one le_rfl)) idK) d0) = 1 :=
  witness_pair_cost 10 1 zero_le_one le_rfl j hj

end LabNotes

end Catalog.Probability.NET59