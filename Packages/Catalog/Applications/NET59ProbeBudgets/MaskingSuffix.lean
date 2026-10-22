import Applications.NET59ProbeBudgets.Dichotomy

/-!
# Masking suffixes: every pruning instance hides from every solo probe

`Probability.NET59NonIdentifiability` exhibits one witness family
(`fullStack` / `prunedStack` on `Fin 2`, probed at the single input `d0`) whose
solo profile vanishes while the joint damage is any prescribed `t`.  Here the
construction is turned into a *universal transformation*.

`maskStack F d` / `maskPruned P d` wrap an arbitrary intact stack `F` and pruned
stack `P` between

* a **collapsing prefix** `constK d` (shared by both stacks), which sends every
  upstream state to the probe state `d`, and
* a **masking suffix**: the intact stack ends with the forgetful layer
  `constK (chain F d)`, the pruned stack with the transparent layer `idK`.

`masking_suffix` proves, for **every** input law `μ` (so in particular for every
finite or infinite set of probe inputs, spanning or not):

* the joint damage of the wrapped pair equals the original joint damage
  `tv (chain F d) (chain P d)`, and
* the solo profile of the wrapped pair is identically `0`.

So no budget computed from solo (one-layer-at-a-time, output-level) measurements
— at any number of probe inputs — can bound joint damage
(`solo_certificate_unsound`).  Every pruning instance, however damaging, can be
made invisible to solo probing at the cost of two extra layers.
-/

namespace Catalog.Probability.NET59.ProbeBudgets

open Finset

variable {α : Type*} [Fintype α]

/-- The wrapped intact stack: collapse to `d`, run `F`, then forget everything
and output the intact answer `chain F d`. -/
def maskStack (F : List (Kern α α)) (d : Dist α) : List (Kern α α) :=
  constK d :: (F ++ [constK (chain F d)])

/-- The wrapped pruned stack: collapse to `d`, run `P`, then pass through. -/
def maskPruned [DecidableEq α] (P : List (Kern α α)) (d : Dist α) : List (Kern α α) :=
  constK d :: (P ++ [idK])

theorem length_maskStack (F : List (Kern α α)) (d : Dist α) :
    (maskStack F d).length = F.length + 2 := by simp [maskStack]

theorem length_maskPruned [DecidableEq α] (P : List (Kern α α)) (d : Dist α) :
    (maskPruned P d).length = P.length + 2 := by simp [maskPruned]

/-- The wrapped intact stack outputs `chain F d` from every input. -/
theorem chain_maskStack (F : List (Kern α α)) (d μ : Dist α) :
    chain (maskStack F d) μ = chain F d := by
  rw [maskStack, chain_cons, chain_snoc_constK]

/-- The wrapped pruned stack outputs `chain P d` from every input. -/
theorem chain_maskPruned [DecidableEq α] (P : List (Kern α α)) (d μ : Dist α) :
    chain (maskPruned P d) μ = chain P d := by
  rw [maskPruned, chain_cons, push_constK, chain_append, chain_cons, chain_nil, push_idK]

/-- Ablating any single layer of the wrapped intact stack leaves its output
unchanged, from every input. -/
theorem chain_maskStack_set [DecidableEq α] (F P : List (Kern α α))
    (hlen : F.length = P.length) (d μ : Dist α) (j : ℕ) :
    chain ((maskStack F d).set j ((maskPruned P d).getD j idK)) μ = chain F d := by
  rcases j with _ | i
  · -- the collapsing prefix is shared, so ablating it changes nothing
    simp only [maskStack, maskPruned, List.getD_cons_zero, List.set_cons_zero]
    rw [chain_cons, chain_snoc_constK]
  · simp only [maskStack, maskPruned, List.getD_cons_succ, List.set_cons_succ, chain_cons,
      push_constK]
    rcases lt_trichotomy i F.length with hi | hi | hi
    · -- an inner layer: the forgetful suffix masks it
      rw [List.set_append_left _ _ hi, chain_snoc_constK]
    · -- the suffix itself: replacing it by `idK` reproduces the intact output
      subst hi
      have hg : (P ++ [idK]).getD F.length idK = idK := by
        rw [List.getD_eq_getElem?_getD]
        rcases h : (P ++ [idK])[F.length]? with _ | k
        · rfl
        · rw [hlen, List.getElem?_append_right le_rfl] at h
          simp at h
          simp [h]
      rw [hg, List.set_append_right _ _ le_rfl]
      simp [chain_append]
    · -- out of range: nothing is replaced
      rw [List.set_eq_of_length_le (by simp; omega), chain_snoc_constK]

/-- **Masking-suffix theorem.**  For every intact stack `F`, every pruned stack
`P` of the same depth and every probe state `d`, the wrapped pair
`maskStack F d` / `maskPruned P d`

* has the same depth (two more layers),
* has joint damage exactly `tv (chain F d) (chain P d)` from **every** input,
* has solo profile identically `0` from **every** input. -/
theorem masking_suffix [DecidableEq α] (F P : List (Kern α α)) (hlen : F.length = P.length)
    (d : Dist α) :
    (maskStack F d).length = (maskPruned P d).length ∧
    (∀ μ : Dist α, tv (chain (maskStack F d) μ) (chain (maskPruned P d) μ)
        = tv (chain F d) (chain P d)) ∧
    (∀ μ : Dist α, ∀ j : ℕ,
        tv (chain (maskStack F d) μ)
          (chain ((maskStack F d).set j ((maskPruned P d).getD j idK)) μ) = 0) := by
  refine ⟨by rw [length_maskStack, length_maskPruned, hlen], fun μ => ?_, fun μ j => ?_⟩
  · rw [chain_maskStack, chain_maskPruned]
  · rw [chain_maskStack, chain_maskStack_set F P hlen, tv_self]

/-- The solo profile of a stack pair at input `μ`: the output-level damage of
ablating layer `j` alone. -/
def soloCost [DecidableEq α] (F P : List (Kern α α)) (μ : Dist α) (j : ℕ) : ℚ :=
  tv (chain F μ) (chain (F.set j (P.getD j idK)) μ)

/-- **Generalised witness family.**  For any two laws `d, c` and any depth
`n + 3`, there is a stack pair whose solo profile vanishes at every input and
every layer, while its joint damage is `tv d c` at every input.  On `Fin 2`
with `d = d0` and `c = bern t` this recovers the NET-59 witness family, now
uniformly over all inputs instead of at the single probe `d0`. -/
theorem witness_family [DecidableEq α] (d c : Dist α) (n : ℕ) :
    ∃ F P : List (Kern α α), F.length = n + 3 ∧ P.length = n + 3 ∧
      (∀ μ j, soloCost F P μ j = 0) ∧ (∀ μ, tv (chain F μ) (chain P μ) = tv d c) := by
  obtain ⟨hl, hjoint, hsolo⟩ := masking_suffix (List.replicate (n + 1) (idK : Kern α α))
    (List.replicate (n + 1) (constK c)) (by simp) d
  refine ⟨_, _, by rw [length_maskStack]; simp, by rw [length_maskPruned]; simp, hsolo,
    fun μ => ?_⟩
  rw [hjoint μ, chain_replicate_idK', chain_replicate_constK]

/-- **Solo certificates are unsound, at any set of probe inputs.**  Let `Φ` be any
rule turning the solo profiles of a stack pair (observed at any family of probe
inputs, finite or not) into a damage certificate, subject only to `Φ` returning
`0` on an identically zero profile.  If `α` has two points, `Φ` certifies `0` for
some stack pair whose joint damage is `1` at every input. -/
theorem solo_certificate_unsound [DecidableEq α] {ι : Type*} (probes : ι → Dist α)
    (Φ : (ι → ℕ → ℚ) → ℚ) (hΦ : Φ (fun _ _ => 0) = 0) {x y : α} (hxy : x ≠ y) :
    ∃ F P : List (Kern α α), F.length = P.length ∧
      Φ (fun i j => soloCost F P (probes i) j) = 0 ∧
      ∀ μ, tv (chain F μ) (chain P μ) = 1 := by
  obtain ⟨F, P, hF, hP, hsolo, hjoint⟩ := witness_family (dirac x) (dirac y) 0
  refine ⟨F, P, by rw [hF, hP], ?_, fun μ => by rw [hjoint μ, tv_dirac_ne hxy]⟩
  have : (fun i j => soloCost F P (probes i) j) = fun _ _ => 0 := by
    funext i j; exact hsolo _ _
  rw [this, hΦ]

/-! ## Lab notes

The NET-59 parameters: `Fin 2`, probe `d0`, target `t = 17/1000`.  The masked
witness has depth `n + 3`; its solo profile is `0` at every input and its joint
damage is `17/1000` at every input — not just at the single input `d0` probed by
the original family. -/

example (n : ℕ) : ∃ F P : List (Kern (Fin 2) (Fin 2)), F.length = n + 3 ∧ P.length = n + 3 ∧
    (∀ μ j, soloCost F P μ j = 0) ∧ (∀ μ, tv (chain F μ) (chain P μ) = 17 / 1000) := by
  obtain ⟨F, P, h1, h2, h3, h4⟩ := witness_family d0 (bern (17 / 1000) (by norm_num) (by norm_num)) n
  refine ⟨F, P, h1, h2, h3, fun μ => ?_⟩
  rw [h4, d0, tv_bern]; norm_num

end Catalog.Probability.NET59.ProbeBudgets